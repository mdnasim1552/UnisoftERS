Imports Telerik.Web.UI

Public Class ListTemplateSlots
    Inherits System.Web.UI.UserControl

    Public Property ListRulesId As Integer
        Set(value As Integer)
            ListRulesIdHiddenField.Value = value
        End Set
        Get
            Return ListRulesIdHiddenField.Value
        End Get
    End Property

    Public Property OperatingHospitalId As Integer
        Get
            Return OperatingHospitalIdHiddenField.Value
        End Get
        Set(value As Integer)
            OperatingHospitalIdHiddenField.Value = value
        End Set
    End Property

    Public Property GIProcedure As Boolean
        Get
            Return GIProcedureHiddenField.Value
        End Get
        Set(value As Boolean)
            GIProcedureHiddenField.Value = value
        End Set
    End Property

    Public Property IsTraining As Boolean
        Get
            Return IsTrainingHiddenField.Value
        End Get
        Set(value As Boolean)
            IsTrainingHiddenField.Value = value
        End Set
    End Property

    Public Property StartTime As DateTime
        Get
            Return StartTimeHiddenField.Value
        End Get
        Set(value As DateTime)
            StartTimeHiddenField.Value = value
        End Set
    End Property

    Public Property EndTime As DateTime
        Get
            Return EndTimeHiddenField.Value
        End Get
        Set(value As DateTime)
            EndTimeHiddenField.Value = value
        End Set
    End Property

    Public Property intDefaultSlothLengthMinutes As Integer = 0

    Public ReadOnly Property TotalPoints As Decimal
        Get
            Dim points As Integer

            For Each item As GridDataItem In SlotsRadGrid.Items
                Dim PointsRadNumericTextBox As RadNumericTextBox = item.FindControl("PointsRadNumericTextBox")
                points += CDec(PointsRadNumericTextBox.Text)
            Next

            Return points
        End Get
    End Property

    Public ReadOnly Property TotalMinutes As Integer
        Get
            Dim mins As Integer

            For Each item As GridDataItem In SlotsRadGrid.Items
                Dim SlotLengthRadNumericTextBox As RadNumericTextBox = item.FindControl("SlotLengthRadNumericTextBox")
                mins += CInt(SlotLengthRadNumericTextBox.Text)
            Next

            Return mins
        End Get
    End Property
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
    End Sub

    Public Function initSlotDT(ByRef tblSlots As DataTable) As DataTable
        'tblSlots.Columns.Add("SlotRowId", GetType(Decimal))
        tblSlots.Columns.Add("LstSlotId", GetType(Decimal))
        tblSlots.Columns.Add("SlotId", GetType(Integer))
        tblSlots.Columns.Add("ProcedureTypeId", GetType(Integer))
        tblSlots.Columns.Add("Points", GetType(Decimal))
        tblSlots.Columns.Add("Suppressed", GetType(Boolean))
        tblSlots.Columns.Add("ParentId", GetType(Integer))
        tblSlots.Columns.Add("Minutes", GetType(Integer))
        tblSlots.Columns.Add("AppointmentId", GetType(Integer))

        Return tblSlots
    End Function

    Public Sub initGrid()
        Dim tblSlots As DataTable = New DataTable
        SlotsRadGrid.DataSource = tblSlots
        SlotsRadGrid.DataBind()
        TotalPointsLabel.Text = 0
        GenerateaSlotButton.Enabled = True


    End Sub

    Public Sub calculateTime()
        Dim endTime = StartTime.AddMinutes(TotalMinutes)
        ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "set-end-time", "setEndTime('" & endTime.ToShortTimeString & "');", True)
    End Sub

    Private Sub calculatePoints()
        'Dim totalPoints As Decimal = 0
        'For Each item As GridDataItem In SlotsRadGrid.Items
        '    Dim PointsNumericTextBox As RadNumericTextBox = item.FindControl("PointsRadNumericTextBox")
        '    Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)
        '    totalPoints += SlotPoints
        'Next

        TotalPointsLabel.Text = TotalPoints
    End Sub

    Private Sub fillEditForm(ListRulesId As Integer)
        Dim da As New DataAccess_Sch
        Dim dt As DataRow = da.GetTemplate(ListRulesId).Rows(0)
        'If dt("GIProcedure") Then
        '    GIProcedureRBL.SelectedValue = "1"
        'Else
        '    'SlotsRadGrid.Style.Item("height") = 280
        '    GIProcedureRBL.SelectedValue = "0"
        'End If
        TotalPointsLabel.Text = dt("Points")

    End Sub

    Public Sub SelectList(Optional slotQty As Integer = 1, Optional procedureTypeId As Integer = 0, Optional points As Decimal = 1, Optional length As Integer = 15, Optional slotType As Integer = 0)
        Try
            Dim totalPoints = 0

            '#### First time page is loaded (ListRulesId > 0), get data from db - else generate slots from codebehind 
            If ListRulesId > 0 Then
                Dim sqlStr As String = "SELECT row_number() OVER 
                                                    (ORDER BY esls.[ListSlotId]) LstSlotId, SlotId, esls.ProcedureTypeId, esls.ListRulesId, ISNULL(esls.Points,1) as Points, 
                                                    ISNULL(esls.Suppressed, 0) AS Suppressed, ISNULL(esls.SlotMinutes ,15) AS [Minutes], 0 AS ParentId, ISNULL(AppointmentId,0) AppointmentId
                        FROM [dbo].[ERS_SCH_ListSlots] esls
	                    INNER JOIN dbo.ERS_SCH_ListRules eslr ON esls.ListRulesId = eslr.ListRulesId
                        LEFT JOIN ERS_Appointments a ON a.ListSlotId = esls.ListSlotId
                        WHERE esls.OperatingHospitalId = " & OperatingHospitalId & " 
                          AND esls.ListRulesId = " & CStr(ListRulesId) & "
                          AND esls.Active = 1 
                        ORDER BY esls.ListSlotId"


                SlotsRadGrid.DataSource = DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)

                If SlotsRadGrid.DataSource Is Nothing Then
                    Dim tblSlots As DataTable = New DataTable
                    initSlotDT(tblSlots)
                    SlotsRadGrid.DataSource = tblSlots
                    SlotsRadGrid.DataBind()
                Else
                    SlotsRadGrid.DataBind()
                    calculatePoints()
                    calculateTime()
                End If
            Else
                Dim cnt As Integer = 1
                Dim rowId As Decimal = 1

                Dim tblSlots As DataTable = New DataTable
                initSlotDT(tblSlots)

                Dim da As New DataAccess_Sch

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
            Throw ex
        End Try
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
            calculateTime()
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("There was an error in SlotsRadGrid_ItemCommand", ex)
            Throw ex
        End Try
    End Sub

    Protected Sub SlotComboBox_ItemDataBound(sender As Object, e As RadComboBoxItemEventArgs)
        Dim dataItemForeColor = CType(e.Item.DataItem, DataRowView).Row("ForeColor").ToString()
        e.Item.BackColor = System.Drawing.ColorTranslator.FromHtml(dataItemForeColor)
    End Sub

    Protected Sub GuidelineComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            Dim ProcedureTypeDDL = CType(sender, RadComboBox)
            Dim gridItem = CType(ProcedureTypeDDL.NamingContainer, GridItem)

            Dim Points As Decimal = 1
            Dim Minutes As Integer = 15
            Dim iOperatingHospitalId = OperatingHospitalId
            Dim iProcedureTypeId = ProcedureTypeDDL.SelectedValue

            If ProcedureTypeDDL.SelectedValue > 0 Then
                Dim sqlStr = "SELECT Points, Minutes FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & iProcedureTypeId & " AND OperatingHospitalId = " & iOperatingHospitalId & " AND Training = " & IsTraining & " AND NonGI = 0"
                Dim da As New DataAccess_Sch
                Dim dt = da.GetProcedurePointMappings(iProcedureTypeId, iOperatingHospitalId, IsTraining, 0)
                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    Points = Convert.ToDecimal(dt.Rows(0)("DiagnosticPoints"))
                    Minutes = CInt(dt.Rows(0)("DiagnosticMinutes"))
                End If
            End If

            CType(gridItem.FindControl("PointsRadNumericTextBox"), RadNumericTextBox).Text = Points
            CType(gridItem.FindControl("SlotLengthRadNumericTextBox"), RadNumericTextBox).Text = Minutes

            calculatePoints()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured on edit templates page.", ex)
            Throw ex
        End Try
    End Sub

    Protected Sub SlotsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs)
        Try
            Dim i = 0
            If e.Item.ItemType = GridItemType.Item Or e.Item.ItemType = GridItemType.AlternatingItem Then
                Dim j = 0
                If DirectCast(e.Item.DataItem, System.Data.DataRowView).Row("AppointmentId") > 0 Then

                End If
            End If
        Catch ex As Exception

        End Try
    End Sub

    Protected Sub ProcedureTypesComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            Dim ProcedureTypeDDL = CType(sender, RadComboBox)

            Dim Points As Decimal = 1
            Dim Minutes As Integer = 15
            Dim iOperatingHospitalId = OperatingHospitalId 'OperatingHospitalDropdown.SelectedValue
            Dim iProcedureTypeId = ProcedureTypeDDL.SelectedValue

            'If ProcedureTypeDDL.SelectedValue > 0 Then
            Dim sqlStr = "SELECT Points, Minutes FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & iProcedureTypeId & " AND OperatingHospitalId = " & iOperatingHospitalId & " AND Training = " & Convert.ToByte(IsTraining) & " AND NonGI = " & Convert.ToByte(GIProcedure)
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
            'Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error retrieving procedure points")
            'RadNotification1.Show()

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
        calculateTime()
    End Sub

    Public Function saveListSlots(listRulesId As Integer) As List(Of ERS.Data.ERS_SCH_ListSlots)
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
                    .ListRulesId = listRulesId,
                    .ProcedureTypeId = Guideline,
                    .Suppressed = Suppressed,
                    .SlotId = SlotId,
                    .OperatingHospitalId = OperatingHospitalId,
                    .WhoCreatedId = CInt(Session("PKUserID")),
                    .WhenCreated = Now,
                    .SlotMinutes = SlotMinutes,
                    .Points = SlotPoints,
                    .Active = True
                    })
        Next

        Return ERS_ListSlots
    End Function

    Public Function SaveSlots(listName As String) As Integer

        Using db As New ERS.Data.GastroDbEntities
            Try
                'If CInt(TotalPointsLabel.Text) = 0 And SlotsRadGrid.Items.Count = 0 Then
                '    'Utilities.SetNotificationStyle(RadNotification1, "This template contains 0 slots", True, "Please correct")
                '    'RadNotification1.Show()
                '    'Exit Sub
                'End If

                If Not GIProcedure Then 'non gi template
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
                        'Utilities.SetNotificationStyle(RadNotification1, "Non-GI templates cannot contain non-reserved slots.", True, "Please correct")
                        'RadNotification1.Show()
                        'Exit Sub
                    End If
                End If

                Dim sqlStr As String = ""
                Dim sqlSlots As String = ""

                Dim nonGIProcedureTypeId As Integer = 0
                Dim nonGIPointsPerMinute As Integer = 0
                Dim diagnosticCallinTime As Integer = 0
                Dim diagnosticPoints As Integer = 0
                Dim therapeuticCallInTime As Integer = 0
                Dim therapeuticPoints As Integer = 0


                Dim ERS_ListRules As New ERS.Data.ERS_SCH_ListRules

                With ERS_ListRules
                    .Points = TotalPointsLabel.Text
                    .ListName = listName
                    .OperatingHospitalId = OperatingHospitalIdHiddenField.Value
                    .GIProcedure = GIProcedure
                    .Training = IsTraining
                    .NonGIProcedureTypeId = nonGIProcedureTypeId
                    .NonGIProcedureMinutesPerPoint = nonGIPointsPerMinute
                    .NonGIDiagnosticCallInTime = diagnosticCallinTime
                    .NonGIDiagnosticProcedurePoints = diagnosticPoints
                    .NonGITherapeuticCallInTime = therapeuticCallInTime
                    .NonGITherapeuticProcedurePoints = therapeuticPoints
                    '.GenderId = If(cbListGender.SelectedValue = 0, Nothing, cbListGender.SelectedValue)
                    .IsTemplate = False 'Always false unless created from the Templates page
                End With

                ERS_ListRules.WhoCreatedId = CInt(Session("PKUserID"))
                ERS_ListRules.WhenCreated = Now
                db.ERS_SCH_ListRules.Add(ERS_ListRules)

                db.SaveChanges() 'to get the list rules id for the list slots

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
                    .OperatingHospitalId = OperatingHospitalIdHiddenField.Value,
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


                Return ERS_ListRules.ListRulesId
            Catch ex As Exception
                Throw ex
            End Try
        End Using
    End Function

    Protected Sub PointsRadNumericTextBox_TextChanged(sender As Object, e As EventArgs)
        calculatePoints()
    End Sub

    Protected Sub SlotLengthRadNumericTextBox_TextChanged(sender As Object, e As EventArgs)
        calculateTime()
    End Sub
End Class