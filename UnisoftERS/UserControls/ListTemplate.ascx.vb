Imports Telerik.Web.UI

Public Class ListTemplate
    Inherits System.Web.UI.UserControl


    Property ListRulesId As Integer
    Property OperatingHospitalId As Integer
    Property GIProcedure As Boolean
    Property IsTraining As Boolean

    Public intDefaultSlothLengthMinutes As Integer = 0
    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If ListRulesId > 0 Then
            fillEditForm(ListRulesId)
            SelectList()
            calculatePoints()
        Else
            'GIProcedureRBL.SelectedValue = 1
            SlotsRadGrid.DataSource = New DataTable
            SlotsRadGrid.DataBind()
        End If
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

    Private Sub calculatePoints()
        Dim totalPoints As Decimal = 0
        For Each item As GridDataItem In SlotsRadGrid.Items
            Dim PointsNumericTextBox As RadNumericTextBox = item.FindControl("PointsRadNumericTextBox")
            Dim SlotPoints As Decimal = Convert.ToDecimal(PointsNumericTextBox.Value)
            totalPoints += SlotPoints
        Next

        TotalPointsLabel.Text = totalPoints
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
                                                    (ORDER BY [ListSlotId]) LstSlotId, SlotId, esls.ProcedureTypeId, esls.ListRulesId, ISNULL(esls.Points,1) as Points, 
                                                    ISNULL(esls.Suppressed, 0) AS Suppressed, ISNULL(esls.SlotMinutes ,15) AS [Minutes], 0 AS ParentId
                        FROM [dbo].[ERS_SCH_ListSlots] esls
	                    INNER JOIN dbo.ERS_SCH_ListRules eslr ON esls.ListRulesId = eslr.ListRulesId
                        WHERE esls.OperatingHospitalId = " & OperatingHospitalId & " 
                          AND esls.ListRulesId = " & CStr(ListRulesId) & "
                          AND esls.Active = 1 
                        ORDER BY ListSlotId"


                SlotsRadGrid.DataSource = DataAccess.ExecuteSQL(sqlStr.ToString(), Nothing)

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
            Dim iOperatingHospitalId = 1 'OperatingHospitalDropdown.SelectedValue
            Dim iProcedureTypeId = ProcedureTypeDDL.SelectedValue
            'If TrainingCheckbox.Checked Then
            '    isTraining = 1
            'Else
            '    isTraining = 0
            'End If

            If ProcedureTypeDDL.SelectedValue > 0 Then
                Dim sqlStr = "SELECT Points, Minutes FROM ERS_SCH_PointMappings WHERE ProcedureTypeId = " & iProcedureTypeId & " AND OperatingHospitalId = " & iOperatingHospitalId & " AND Training = " & isTraining & " AND NonGI = 0"
                Dim dt = DataAccess.ExecuteSQL(sqlStr, Nothing)
                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    Points = Convert.ToDecimal(dt.Rows(0)("Points"))
                    Minutes = CInt(dt.Rows(0)("Minutes"))
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
            Dim GuidelineComboBox As RadComboBox = e.Item.FindControl("GuidelineComboBox")
            If GuidelineComboBox IsNot Nothing Then
                Dim da As New DataAccess_Sch
                GuidelineComboBox.DataSource = da.GetGuidelines(GIProcedure, OperatingHospitalId)
                GuidelineComboBox.DataBind()
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
    End Sub

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
                    .ListName = listName
                    .OperatingHospitalId = OperatingHospitalId
                    .GIProcedure = GIProcedure
                    .Training = IsTraining
                    .NonGIProcedureTypeId = nonGIProcedureTypeId
                    .NonGIProcedureMinutesPerPoint = nonGIPointsPerMinute
                    .NonGIDiagnosticCallInTime = diagnosticCallinTime
                    .NonGIDiagnosticProcedurePoints = diagnosticPoints
                    .NonGITherapeuticCallInTime = therapeuticCallInTime
                    .NonGITherapeuticProcedurePoints = therapeuticPoints
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
                    .OperatingHospitalId = OperatingHospitalId,
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

                'ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind(" & ERS_ListRules.ListRulesId & ");", True)
            Catch ex As Exception
                'Dim errorLogRef As String
                'errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving scheduler templates.", ex)
                'Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
                'RadNotification1.Show()
                Throw ex
            End Try
        End Using
    End Function
End Class

