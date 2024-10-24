Imports Telerik.Web.UI

Partial Class Products_Options_Scheduler_EditTemplates
    Inherits OptionsBase
    Public intDefaultSlothLengthMinutes As Integer = 0

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{OperatingHospitalDropdown, ""}}, DataAdapter.GetTemplateOperatingHospitals, "HospitalName", "OperatingHospitalId")
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{EndoscopistDropDown, ""}}, DataAdapter_Sch.GetEndoscopist, "EndoName", "UserId")
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{ListConsultantDropDown, ""}}, DataAdapter_Sch.GetEndoscopist, "EndoName", "UserId")

            EndoscopistDropDown.Items.Insert(0, New RadComboBoxItem("", 0))
            ListConsultantDropDown.Items.Insert(0, New RadComboBoxItem("", 0))

            Dim ListRulesId As Integer = 0
            ListRulesId = GetListRulesId()
            If ListRulesId > 0 Then
                fillEditForm(ListRulesId)
                SelectList()
                calculatePoints()
            Else
                GIProcedureRBL.SelectedValue = 1
                SlotsRadGrid.DataSource = New DataTable
                SlotsRadGrid.DataBind()
            End If

            'slotSetup2()
            enableDisableEdit(ListRulesId)
            SetGIAndNonGIDefaultSlothLenghMinutes()
        End If

    End Sub

    Private Sub enableDisableEdit(ListRulesId As Integer)
        Try
            Dim templateCount = DataAdapter_Sch.checkTemplateBookings(ListRulesId)
            If templateCount > 0 Then
                For Each row As GridDataItem In SlotsRadGrid.Items
                    Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
                    If SlotComboBox IsNot Nothing Then SlotComboBox.Enabled = False

                    Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
                    If GuidelineComboBox IsNot Nothing Then GuidelineComboBox.Enabled = False

                    Dim SuppressedCheckBox As CheckBox = DirectCast(row.FindControl("SuppressedCheckBox"), CheckBox)
                    If SuppressedCheckBox IsNot Nothing Then SuppressedCheckBox.Enabled = False

                    Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
                    If PointsNumericTextBox IsNot Nothing Then PointsNumericTextBox.Enabled = False

                    Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
                    If SlotLengthNumericTextBox IsNot Nothing Then SlotLengthNumericTextBox.Enabled = False

                Next
                OperatingHospitalDropdown.Enabled = False
                ListNameTextBox.Enabled = False
                TemplateNotificationRadLabel.Visible = True
                TrainingCheckbox.Enabled = False
                GIProcedureRBL.Enabled = False
                GenerateSlotButton.Enabled = False
            End If
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error setting templates edit endabled state", ex)
        End Try
    End Sub

    Private Sub fillEditForm(ListRulesId As Integer)
        Dim da As New DataAccess_Sch
        Dim dt As DataRow = da.GetTemplate(ListRulesId).Rows(0)
        If dt("GIProcedure") Then
            GIProcedureRBL.SelectedValue = "1"
        Else
            'SlotsRadGrid.Style.Item("height") = 280
            GIProcedureRBL.SelectedValue = "0"
        End If
        listRuleId.Value = ListRulesId
        ListNameTextBox.Text = CStr(dt("ListName"))
        TotalPointsLabel.Text = dt("Points")
        'PointMinutesNumericTextBox.Value = CInt(dt("PointMins"))
        TrainingCheckbox.Checked = CBool(dt("Training"))
        If Not dt.IsNull("Endoscopist") Then EndoscopistDropDown.SelectedValue = CStr(dt("Endoscopist"))
        If Not dt.IsNull("ListConsultantId") Then ListConsultantDropDown.SelectedValue = CStr(dt("ListConsultantId"))
        If Not dt.IsNull("OperatingHospitalId") Then OperatingHospitalDropdown.SelectedValue = dt("OperatingHospitalId")

    End Sub

    Protected Sub SaveSlots()

        Using db As New ERS.Data.GastroDbEntities
            Try
                If CInt(TotalPointsLabel.Text) = 0 And SlotsRadGrid.Items.Count = 0 Then
                    Utilities.SetNotificationStyle(RadNotification1, "This template contains 0 slots", True, "Please correct")
                    RadNotification1.Show()
                    Exit Sub
                End If

                If GIProcedureRBL.SelectedValue = 0 Then 'non gi template
                    'check a procedure types been set
                    Dim canContinue = True
                    For Each row As GridDataItem In SlotsRadGrid.Items
                        If row.CssClass = "slot-point" Then Continue For
                        Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
                        Dim Guideline As String = If(SlotsRadGrid.Columns(2).Display, GuidelineComboBox.SelectedValue, "0")
                        If Guideline = "0" Then
                            canContinue = False
                            Exit For
                        End If
                    Next

                    If Not canContinue Then
                        Utilities.SetNotificationStyle(RadNotification1, "Non-GI templates cannot contain non-reserved slots.", True, "Please correct")
                        RadNotification1.Show()
                        Exit Sub
                    End If
                End If

                Dim ListRulesId As Integer = GetListRulesId()

                ''check if is an existing template on a diary and if end date may clash with any other diaries
                'If ListRulesId > 0 Then
                '    Dim templateDiaries As DataTable = DataAdapter_Sch.getTemplateDiaries(ListRulesId)
                '    For Each diary In templateDiaries.Rows
                '        If diary("roomId") = 0 Then
                '            'get templates in those rooms and check times

                '        End If
                '    Next

                '    'get room id or all diaries with this template
                '    'get start times of any other diaries on that page
                '    'check if the end time of this template overlaps with the start time of any of the other diaries
                'End If

                Dim HospitalId = OperatingHospitalDropdown.SelectedValue
                Dim sqlStr As String = ""
                Dim sqlSlots As String = ""

                Dim nonGIProcedureTypeId As Integer = 0
                Dim nonGIPointsPerMinute As Integer = 0
                Dim diagnosticCallinTime As Integer = 0
                Dim diagnosticPoints As Integer = 0
                Dim therapeuticCallInTime As Integer = 0
                Dim therapeuticPoints As Integer = 0

                Dim ERS_ListRules As ERS.Data.ERS_SCH_ListRules

                If ListRulesId > 0 Then
                    ERS_ListRules = db.ERS_SCH_ListRules.Where(Function(x) x.ListRulesId = ListRulesId).FirstOrDefault
                Else
                    ERS_ListRules = New ERS.Data.ERS_SCH_ListRules()
                End If

                With ERS_ListRules
                    .Points = TotalPointsLabel.Text
                    .Endoscopist = EndoscopistDropDown.SelectedValue
                    .ListConsultantId = ListConsultantDropDown.SelectedValue
                    .ListName = ListNameTextBox.Text
                    .OperatingHospitalId = HospitalId
                    .GIProcedure = GIProcedureRBL.SelectedValue
                    .Training = IIf(TrainingCheckbox.Checked, 1, 0)
                    .NonGIProcedureTypeId = nonGIProcedureTypeId
                    .NonGIProcedureMinutesPerPoint = nonGIPointsPerMinute
                    .NonGIDiagnosticCallInTime = diagnosticCallinTime
                    .NonGIDiagnosticProcedurePoints = diagnosticPoints
                    .NonGITherapeuticCallInTime = therapeuticCallInTime
                    .NonGITherapeuticProcedurePoints = therapeuticPoints
                    'MH added on 12 Jan 2023
                    .IsTemplate = 1

                End With

                If ERS_ListRules.ListRulesId = 0 Then
                    ERS_ListRules.WhoCreatedId = CInt(Session("PKUserID"))
                    ERS_ListRules.WhenCreated = Now
                    db.ERS_SCH_ListRules.Add(ERS_ListRules)
                Else
                    ERS_ListRules.WhoUpdatedId = CInt(Session("PKUserID"))
                    ERS_ListRules.WhenUpdated = Now
                    db.ERS_SCH_ListRules.Attach(ERS_ListRules)
                    db.Entry(ERS_ListRules).State = Entity.EntityState.Modified

                    Dim existingSlots = db.ERS_SCH_ListSlots.Where(Function(x) x.ListRulesId = ListRulesId And x.Active = True)
                    For Each slot In existingSlots
                        slot.Active = False
                        slot.DeactivatedDateTime = Now
                        db.ERS_SCH_ListSlots.Attach(slot)
                        db.Entry(slot).State = Entity.EntityState.Modified
                    Next
                End If

                db.SaveChanges()


                Dim ERS_ListSlots As New List(Of ERS.Data.ERS_SCH_ListSlots)
                Dim totalMinutes As Integer

                For Each row As GridDataItem In SlotsRadGrid.Items
                    If row.CssClass = "slot-point" Then Continue For
                    Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
                    Dim SlotId As String = SlotComboBox.SelectedValue
                    Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
                    Dim Guideline As String = If(SlotsRadGrid.Columns(2).Display, GuidelineComboBox.SelectedValue, "0")
                    Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
                    Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)

                    Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
                    Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)
                    totalMinutes += SlotMinutes

                    Dim Suppressed As Byte = 0
                    Dim SuppressedCheckBox As CheckBox = DirectCast(row.FindControl("SuppressedCheckBox"), CheckBox)
                    If ((Not (SuppressedCheckBox) Is Nothing) AndAlso SuppressedCheckBox.Checked) Then Suppressed = 1

                    ERS_ListSlots.Add(New ERS.Data.ERS_SCH_ListSlots With {
                    .ListRulesId = ERS_ListRules.ListRulesId,
                    .ProcedureTypeId = Guideline,
                    .Suppressed = Suppressed,
                    .SlotId = SlotId,
                    .OperatingHospitalId = HospitalId,
                    .WhoCreatedId = CInt(Session("PKUserID")),
                    .WhenCreated = Now,
                    .SlotMinutes = SlotMinutes,
                    .Points = SlotPoints,
                    .Active = True
                    })
                Next

                ERS_ListRules.TotalMins = totalMinutes
                db.ERS_SCH_ListRules.Attach(ERS_ListRules)
                db.Entry(ERS_ListRules).State = Entity.EntityState.Modified

                db.ERS_SCH_ListSlots.AddRange(ERS_ListSlots)
                db.SaveChanges()



                ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind(" & ERS_ListRules.ListRulesId & ");", True)
            Catch ex As Exception
                Dim errorLogRef As String
                errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving scheduler templates.", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
                RadNotification1.Show()
            End Try
        End Using
    End Sub

    Protected Sub GenerateSlotButton_Click(sender As Object, e As EventArgs)
        Try
            SelectList()
            calculatePoints()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on edit templates page.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading your data.")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub calculatePoints()
        Dim totalPoints As Decimal = 0
        For Each item As GridDataItem In SlotsRadGrid.Items
            Dim PointsNumericTextBox As RadNumericTextBox = item.FindControl("PointsRadNumericTextBox")
            Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)
            totalPoints += SlotPoints
        Next

        TotalPointsLabel.Text = totalPoints
    End Sub

    Private Function GetListRulesId() As Integer
        Dim ListRulesId As Integer = 0
        If Not IsDBNull(Request.QueryString("ListRulesId")) AndAlso Request.QueryString("ListRulesId") <> "" Then
            ListRulesId = CInt(Request.QueryString("ListRulesId"))
        End If
        Return ListRulesId
    End Function

    Private Sub SelectList(Optional slotQty As Integer = 1, Optional procedureTypeId As Integer = 0, Optional points As Decimal = 1, Optional length As Integer = 15, Optional slotType As Integer = 0)
        Try
            Dim totalPoints = 0

            Dim ListRulesId As Integer = -1
            If Not Page.IsPostBack Then
                ListRulesId = GetListRulesId()
            End If

            '#### First time page is loaded (ListRulesId > 0), get data from db - else generate slots from codebehind 
            If ListRulesId > 0 Then
                SlotsRadGrid.DataSource = DataAdapter_Sch.getListSlots(CInt(OperatingHospitalDropdown.SelectedValue), ListRulesId)

                If SlotsRadGrid.DataSource Is Nothing Then
                    Dim tblSlots As DataTable = New DataTable
                    initSlotDT(tblSlots)
                    SlotsRadGrid.DataSource = tblSlots
                    SlotsRadGrid.DataBind()
                Else
                    SlotsRadGrid.DataBind()
                End If
            Else
                Dim cnt As Integer = 1
                Dim rowId As Decimal = 1

                Dim tblSlots As DataTable = New DataTable
                initSlotDT(tblSlots)

                '## Looping through grid just to repopulate the same values already displayed or from user amendments
                For Each row As GridDataItem In SlotsRadGrid.Items
                    Dim LstSlotId As String = (row("LstSlotId").Text)
                    Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
                    Dim SlotId As String = SlotComboBox.SelectedValue
                    Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
                    Dim Guideline As String = GuidelineComboBox.SelectedValue
                    Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
                    Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)
                    Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
                    Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)
                    Dim Suppressed As Boolean = False
                    Dim SuppressedCheckBox As CheckBox = DirectCast(row.FindControl("SuppressedCheckBox"), CheckBox)
                    If ((Not (SuppressedCheckBox) Is Nothing) AndAlso SuppressedCheckBox.Checked) Then Suppressed = True


                    tblSlots.Rows.Add(cnt, SlotId, Guideline, SlotPoints, Suppressed, 0, SlotMinutes)
                    cnt = cnt + 1
                Next

                If slotQty > 0 Then
                    For i = 0 To slotQty - 1
                        tblSlots.Rows.Add(i, slotType, procedureTypeId, points, False, 0, length)
                        cnt = cnt + 1
                    Next
                Else
                    tblSlots.Rows.Add(cnt, 1, 0, 1, False, 0, 15)
                    cnt = cnt + 1
                End If


                SlotsRadGrid.DataSource = tblSlots
                SlotsRadGrid.DataBind()
            End If
        Catch ex As Exception

        End Try
    End Sub

    Function initSlotDT(ByRef tblSlots As DataTable) As DataTable
        'tblSlots.Columns.Add("SlotRowId", GetType(Decimal))
        tblSlots.Columns.Add("LstSlotId", GetType(Decimal))
        tblSlots.Columns.Add("SlotId", GetType(Integer))
        tblSlots.Columns.Add("ProcedureTypeId", GetType(Integer))
        tblSlots.Columns.Add("Points", GetType(Decimal))
        tblSlots.Columns.Add("Suppressed", GetType(Boolean))
        tblSlots.Columns.Add("ParentId", GetType(Integer))
        tblSlots.Columns.Add("Minutes", GetType(Integer))

        Return tblSlots
    End Function
    Protected Sub SetGIAndNonGIDefaultSlothLenghMinutes()
        Try


            Dim Points As Decimal = 1
            Dim Minutes As Integer = 10
            Dim iOperatingHospitalId = OperatingHospitalDropdown.SelectedValue
            Dim iProcedureTypeId As Integer = 0


            'If ProcedureTypeDDL.SelectedValue > 0 Then
            Dim sqlStr = "SELECT Points, Minutes FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & iProcedureTypeId & " AND OperatingHospitalId = " & iOperatingHospitalId & " AND Training = " & Convert.ToByte(TrainingCheckbox.Checked) & " AND NonGI = " & Convert.ToByte(GIProcedureRBL.SelectedValue = 0)
            Dim dt = DataAccess.ExecuteSQL(sqlStr, Nothing)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                Points = Convert.ToDecimal(dt.Rows(0)("Points"))
                Minutes = CInt(dt.Rows(0)("Minutes"))
            Else
                PointsRadNumericTextBox.Text = 1
                SlotLengthRadNumericTextBox.Text = 15
            End If
            'End If

            PointsRadNumericTextBox.Text = Points
            SlotLengthRadNumericTextBox.Text = Minutes

            intDefaultSlothLengthMinutes = Minutes

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("SetGIAndNonGIDefaultSlothLenghMinutes()", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading your data.")
            RadNotification1.Show()
        End Try
    End Sub
    Protected Sub GuidelineComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            Dim ProcedureTypeDDL = CType(sender, RadComboBox)
            Dim gridItem = CType(ProcedureTypeDDL.NamingContainer, GridItem)

            Dim Points As Decimal = 1
            Dim Minutes As Integer = 15
            Dim iOperatingHospitalId = OperatingHospitalDropdown.SelectedValue
            Dim iProcedureTypeId = ProcedureTypeDDL.SelectedValue
            Dim isTraining As Integer
            If TrainingCheckbox.Checked Then
                isTraining = 1
            Else
                isTraining = 0
            End If

            If ProcedureTypeDDL.SelectedValue > 0 Then
                Dim sqlStr = "SELECT Points, Minutes FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & iProcedureTypeId & " AND OperatingHospitalId = " & iOperatingHospitalId & " AND Training = " & isTraining & " AND NonGI = 0"
                Dim dt = DataAccess.ExecuteSQL(sqlStr, Nothing)
                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    Points = Convert.ToDecimal(dt.Rows(0)("Points"))
                    Minutes = CInt(dt.Rows(0)("Minutes"))
                Else
                    PointsRadNumericTextBox.Text = 1
                    SlotLengthRadNumericTextBox.Text = 15
                End If
            End If

            CType(gridItem.FindControl("PointsRadNumericTextBox"), RadNumericTextBox).Text = Points
            CType(gridItem.FindControl("SlotLengthRadNumericTextBox"), RadNumericTextBox).Text = Minutes

            calculatePoints()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on edit templates page.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading your data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub GIProcedureRBL_SelectedIndexChanged(sender As Object, e As EventArgs)
        Try
            SetGIAndNonGIDefaultSlothLenghMinutes()
            changeGIType()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on edit templates page.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem loading your data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub SlotComboBox_ItemDataBound(sender As Object, e As RadComboBoxItemEventArgs)
        Dim dataItemForeColor = CType(e.Item.DataItem, DataRowView).Row("ForeColor").ToString()
        e.Item.BackColor = System.Drawing.ColorTranslator.FromHtml(dataItemForeColor)
    End Sub

    Protected Sub PointsRadNumericTextBox_TextChanged(sender As Object, e As EventArgs)
        calculatePoints()
    End Sub

    Protected Sub ProcedureTypesComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            Dim ProcedureTypeDDL = CType(sender, RadComboBox)

            Dim Points As Decimal = 1
            Dim Minutes As Integer = 15
            Dim iOperatingHospitalId = OperatingHospitalDropdown.SelectedValue
            Dim iProcedureTypeId = ProcedureTypeDDL.SelectedValue

            'If ProcedureTypeDDL.SelectedValue > 0 Then
            Dim sqlStr = "SELECT Points, Minutes FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & iProcedureTypeId & " AND OperatingHospitalId = " & iOperatingHospitalId & " AND Training = " & Convert.ToByte(TrainingCheckbox.Checked) & " AND NonGI = " & Convert.ToByte(GIProcedureRBL.SelectedValue = 0)
                Dim dt = DataAccess.ExecuteSQL(sqlStr, Nothing)
                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    Points = Convert.ToDecimal(dt.Rows(0)("Points"))
                    Minutes = CInt(dt.Rows(0)("Minutes"))
                Else
                    PointsRadNumericTextBox.Text = 1
                    SlotLengthRadNumericTextBox.Text = 15
                End If
            'End If

            PointsRadNumericTextBox.Text = Points
            SlotLengthRadNumericTextBox.Text = Minutes
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error during procedure dropdown postback", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error retrieving procedure points")
            RadNotification1.Show()

            PointsRadNumericTextBox.Text = 1
            SlotLengthRadNumericTextBox.Text = 15
        End Try
    End Sub

    Protected Sub btnSaveAndApply_Click(sender As Object, e As EventArgs)
        SelectList(SlotQtyRadNumericTextBox.Value, ProcedureTypesComboBox.SelectedValue, PointsRadNumericTextBox.Value, SlotLengthRadNumericTextBox.Value, SlotComboBox.SelectedValue)

        SlotQtyRadNumericTextBox.Value = 1
        ProcedureTypesComboBox.SelectedIndex = 0
        PointsRadNumericTextBox.Value = 1
        SlotLengthRadNumericTextBox.Value = 15
        SlotComboBox.SelectedIndex = 0

        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "applyandclose", "closeAddNewWindow();", True)
        calculatePoints()
    End Sub

    Protected Sub SlotsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs)
        Try
            Dim selectedIndex = e.Item.ItemIndex
            Dim cnt As Integer = 1
            Dim rowId As Decimal = 1

            Dim tblSlots As DataTable = New DataTable
            initSlotDT(tblSlots)

            For Each row As GridDataItem In SlotsRadGrid.Items
                Dim LstSlotId As String = (row("LstSlotId").Text)
                Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
                Dim SlotId As String = SlotComboBox.SelectedValue
                Dim GuidelineComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
                Dim Guideline As String = GuidelineComboBox.SelectedValue
                Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
                Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)
                Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
                Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)
                Dim Suppressed As Boolean = False
                Dim SuppressedCheckBox As CheckBox = DirectCast(row.FindControl("SuppressedCheckBox"), CheckBox)
                If ((Not (SuppressedCheckBox) Is Nothing) AndAlso SuppressedCheckBox.Checked) Then Suppressed = True


                tblSlots.Rows.Add(cnt, SlotId, Guideline, SlotPoints, Suppressed, 0, SlotMinutes)

                cnt = cnt + 1
            Next

            tblSlots.Rows.RemoveAt(selectedIndex)

            SlotsRadGrid.DataSource = tblSlots
            SlotsRadGrid.DataBind()
            calculatePoints()
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error in SlotsRadGrid_ItemCommand", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "An error occured")
        End Try
    End Sub

    Protected Sub TrainingCheckbox_CheckedChanged(sender As Object, e As EventArgs)
        Try
            'update points
            For Each row As GridDataItem In SlotsRadGrid.Items
                Dim ProcedureTypesComboBox As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
                Dim ProcedureTypeId As Integer = ProcedureTypesComboBox.SelectedValue

                Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
                Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)

                Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
                Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)

                'Dim sqlStr = "SELECT Points, Minutes FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & ProcedureTypeId & " AND OperatingHospitalId = " & OperatingHospitalDropdown.SelectedValue & " AND Training = " & Convert.ToByte(TrainingCheckbox.Checked) & " AND NonGI = " & Convert.ToByte(GIProcedureRBL.SelectedValue = 0)
                Dim sqlStr = "Select Case when " & ProcedureTypeId & " = 2 then TherapeuticPoints else Points END Points, case when " & ProcedureTypeId & " = 2 then TherapeuticMinutes else [Minutes] END as [Minutes] FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & ProcedureTypeId & " AND Training = " & Convert.ToByte(TrainingCheckbox.Checked) & " AND NonGI = " & Convert.ToByte(GIProcedureRBL.SelectedValue = 0)
                Dim dt = DataAccess.ExecuteSQL(sqlStr, Nothing)
                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    PointsNumericTextBox.Text = Convert.ToDecimal(dt.Rows(0)("Points"))
                    SlotLengthNumericTextBox.Text = CInt(dt.Rows(0)("Minutes"))
                Else
                    PointsNumericTextBox.Text = 1
                    SlotLengthNumericTextBox.Text = 15
                End If
            Next

            calculatePoints()
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error getting training minutes", ex)
            Utilities.SetNotificationStyle(RadNotification1, "There was an error retrieving slot lengths. Default ones have been set", )
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub OperatingHospitalDropdown_SelectedIndexChanged(sender As Object, e As EventArgs)
        Dim tblSlots As DataTable = New DataTable
        initSlotDT(tblSlots)

        For Each row As GridDataItem In SlotsRadGrid.Items
            Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
            Dim SlotId As String = SlotComboBox.SelectedValue

            Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
            Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)


            Dim ProcedureType As String = 0
            Dim SlotMinutes As Decimal
            If GIProcedureRBL.SelectedValue = 1 Then
                Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
                SlotMinutes = Convert.ToDecimal(SlotLengthNumericTextBox.Value)
                Dim ProcedureTypeCombo As RadComboBox = DirectCast(row.FindControl("GuidelineComboBox"), RadComboBox)
                ProcedureType = ProcedureTypeCombo.SelectedValue
                Dim sqlStr = "SELECT Points, Minutes FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & ProcedureType & " AND OperatingHospitalId = " & OperatingHospitalDropdown.SelectedValue & " AND Training = " & Convert.ToByte(TrainingCheckbox.Checked) & " AND NonGI = " & Convert.ToByte(GIProcedureRBL.SelectedValue = 0)
                Dim dt = DataAccess.ExecuteSQL(sqlStr, Nothing)
                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    SlotPoints = IIf(Convert.ToDecimal(dt.Rows(0)("Points")) = 0, 1, Convert.ToDecimal(dt.Rows(0)("Points")))
                    SlotMinutes = IIf(CInt(dt.Rows(0)("Minutes")) = 0, 15, CInt(dt.Rows(0)("Minutes")))
                Else
                    SlotPoints = 1
                    SlotMinutes = 15
                End If
            Else
                SlotPoints = 1
                SlotMinutes = 15
            End If



            tblSlots.Rows.Add(row.ItemIndex, SlotId, ProcedureType, SlotPoints, False, 0, SlotMinutes)
        Next

        SlotsRadGrid.DataSource = tblSlots
        SlotsRadGrid.DataBind()
        calculatePoints()
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        If e.Argument = "changeGIType" Then
            changeGIType()
        End If
    End Sub

    Private Sub changeGIType()
        Dim tblSlots As DataTable = New DataTable
        initSlotDT(tblSlots)

        For Each row As GridDataItem In SlotsRadGrid.Items
            Dim SlotComboBox As RadComboBox = DirectCast(row.FindControl("SlotComboBox"), RadComboBox)
            Dim SlotId As String = SlotComboBox.SelectedValue

            Dim PointsNumericTextBox As RadNumericTextBox = row.FindControl("PointsRadNumericTextBox")
            Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)

            Dim SlotLengthNumericTextBox As RadNumericTextBox = row.FindControl("SlotLengthRadNumericTextBox")
            Dim SlotMinutes As Decimal = Convert.ToDecimal(SlotLengthNumericTextBox.Value)

            tblSlots.Rows.Add(row.ItemIndex, SlotId, 0, SlotPoints, False, 0, SlotMinutes)
        Next

        SlotsRadGrid.DataSource = tblSlots
        SlotsRadGrid.DataBind()
    End Sub
End Class
