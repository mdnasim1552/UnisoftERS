Imports Telerik.Web.UI


Public Class LowerExtent
    Inherits ProcedureControls

    Public Event Extent_ToggleLimited(isLimited As Boolean)

    Public Shared procType As Integer

    Public Shared endoscopipstId As Integer

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        If Not Page.IsPostBack Then
            procType = CInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            Try
                'CaecumStartDateRadTimeInput.SelectedDate = Session(Constants.SESSION_PROCEDURE_DATE)
                If procType <> CInt(ProcedureType.Proctoscopy) Then
                    bindExtentRepeater() 'bindExtent()
                Else
                    LowerExtentContent.Visible = False
                End If
            Catch ex As Exception
                Dim ref = LogManager.LogManagerInstance.LogError("There was an error loading extent", ex)
                Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was a problem loading lower extent")
                RadNotification1.Show()
            End Try
        End If
        'bindExtentRepeater()
    End Sub

    'Public Sub ShowOrHideInsertionLimitedByLowerExtent()
    '    bindExtentRepeater()
    'End Sub

    'Public Sub PlannedShowOrHideLowerExtent()
    '    bindExtentRepeater(0)
    'End Sub

    Private Sub bindExtentRepeater()
        Try
            Dim endoExtents As New List(Of ProcedureExtent)
            Dim procedureEndoscopists = DataAdapter.getProcedureEndoscopists(CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            Dim extentOptions = DataAdapter.LoadExtent(procType)
            Dim procedureExtent = DataAdapter.getProcedureLowerExtent(Session(Constants.SESSION_PROCEDURE_ID))

            For Each endo In procedureEndoscopists.Rows
                Dim endoExtent As New ProcedureExtent
                With endoExtent
                    .EndoscopistId = CInt(endo("EndoscopistId"))
                    .EndoscopistName = endo("EndoscopistName")
                    .TraineeTrainer = endo("TraineeTrainer").ToString() 'Added by rony tfs-3761
                    If procedureExtent.AsEnumerable.Any(Function(x) x("EndoscopistId") = CInt(endo("EndoscopistId"))) Then
                        Dim dr = procedureExtent.AsEnumerable.Where(Function(x) x("EndoscopistId") = CInt(endo("EndoscopistId"))).FirstOrDefault
                        If Not dr.IsNull("ExtentId") Then .ExtentId = CInt(dr("ExtentId"))
                        If Not dr.IsNull("RectalExamPerformed") Then .PRDone = CBool(dr("RectalExamPerformed"))
                        If Not dr.IsNull("RetroflectionPerformed") Then .Retroflexion = CBool(dr("RetroflectionPerformed"))
                        If Not dr.IsNull("NoRetroflectionReason") Then .NoRetroflexionReason = dr("NoRetroflectionReason")
                        If Not dr.IsNull("InsertionAccessViaId") Then .InsertionViaId = CInt(dr("InsertionAccessViaId"))
                        If Not dr.IsNull("ConfirmedById") Then .InsertionConfirmedById = CInt(dr("ConfirmedById"))
                        .CaecumIdentifiedByIds = New List(Of Integer)
                        If Not dr.IsNull("LimitationId") Then .LimitedById = CInt(dr("LimitationId"))
                        If Not dr.IsNull("DifficultiesEncounteredId") Then .DifficultiesId = CInt(dr("DifficultiesEncounteredId"))
                        If Not dr.IsNull("Abandoned") Then .ProcedureAbandoned = CInt(dr("Abandoned"))
                        If Not dr.IsNull("IntubationFailed") Then .IntubationFailed = CInt(dr("IntubationFailed"))
                    Else
                        .ExtentId = 0
                        .InsertionViaId = 0
                        .InsertionConfirmedById = 0
                        .CaecumIdentifiedByIds = New List(Of Integer)
                        .LimitedById = 0
                        .DifficultiesId = 0
                        .ProcedureAbandoned = False
                        .IntubationFailed = False
                        .NoRetroflexionReason = ""

                        'insert entry to DB
                        DataAdapter.saveProcedureLowerExtent(Session(Constants.SESSION_PROCEDURE_ID), 0, "", endo("EndoscopistId"), 0, "", 0, 0, 0, "", -1, -1, "", 0, "", Nothing, Nothing)

                    End If
                End With
                'procedureExtent = DataAdapter.getProcedureLowerExtent(Session(Constants.SESSION_PROCEDURE_ID)) 'do this after insertion to  issue solved
                endoExtents.Add(endoExtent)


            Next

            rptLowerExtent.DataSource = endoExtents
            rptLowerExtent.DataBind()

            rptFailedOutcomes.DataSource = extentOptions.AsEnumerable.Where(Function(x) CInt(x("ListOrderBy")) = -1 And Not CBool(x("AdditionalInfo"))).CopyToDataTable '-1 is for failed results
            rptFailedOutcomes.DataBind()

            For Each itm As RepeaterItem In rptLowerExtent.Items
                Dim endoId As Integer = CType(itm.FindControl("EndoscopistIdHiddenValue"), HiddenField).Value

                Dim InsertionViaRadComboBox As RadComboBox = itm.FindControl("InsertionViaRadComboBox")
                InsertionViaRadComboBox.DataSource = DataAdapter.LoadExtentInsertionMethod(procType)
                InsertionViaRadComboBox.DataBind()
                InsertionViaRadComboBox.Items.Insert(0, New RadComboBoxItem("", 0))
                InsertionViaRadComboBox.Attributes.Add("data-endoscopistid", endoId)
                endoscopipstId = endoId 'By ferdowsi
                Dim LowerExtentComboBox As RadComboBox = itm.FindControl("LowerExtentComboBox")
                LowerExtentComboBox.DataSource = extentOptions.AsEnumerable.Where(Function(x) x("ListOrderBy") >= 0 And Not CBool(x("AdditionalInfo"))).CopyToDataTable '-1 is for failed results
                LowerExtentComboBox.DataBind()
                LowerExtentComboBox.Items.Insert(0, New RadComboBoxItem("", 0))
                LowerExtentComboBox.Attributes.Add("data-endoscopistid", endoId)

                Dim InsertionLimitedRadComboBox As RadComboBox = itm.FindControl("InsertionLimitedRadComboBox")
                InsertionLimitedRadComboBox.DataSource = DataAdapter.LoadExtentLimitations(procType)
                InsertionLimitedRadComboBox.DataBind()
                InsertionLimitedRadComboBox.Items.Insert(0, New RadComboBoxItem("", 0))
                InsertionLimitedRadComboBox.Attributes.Add("data-endoscopistid", endoId)

                Dim RetroflexionDoneRadComboBox As RadComboBox = itm.FindControl("RetroflexionDoneRadComboBox")
                RetroflexionDoneRadComboBox.Items.Insert(0, New RadComboBoxItem("", -1))
                RetroflexionDoneRadComboBox.Attributes.Add("data-endoscopistid", endoId)

                Dim PRDoneRadComboBox As RadComboBox = itm.FindControl("PRDoneRadComboBox")
                PRDoneRadComboBox.Items.Insert(0, New RadComboBoxItem("", -1))
                PRDoneRadComboBox.Attributes.Add("data-endoscopistid", endoId)

                Dim OtherLimitationTextBox As TextBox = itm.FindControl("OtherLimitationTextBox")
                OtherLimitationTextBox.Attributes.Add("data-endoscopistid", endoId)

                Dim OtherConfirmedByTextBox As TextBox = itm.FindControl("OtherConfirmedByTextBox")
                OtherConfirmedByTextBox.Attributes.Add("data-endoscopistid", endoId)

                Dim OtherDifficultyTextBox As TextBox = itm.FindControl("OtherDifficultyTextBox")
                OtherDifficultyTextBox.Attributes.Add("data-endoscopistid", endoId)

                Dim NoRetroflexionReasonTextBox As TextBox = itm.FindControl("NoRetroflexionReasonTextBox")
                NoRetroflexionReasonTextBox.Attributes.Add("data-endoscopistid", endoId)

                Dim DifficultiesEncounteredRadComboBox As RadComboBox = itm.FindControl("DifficultiesEncounteredRadComboBox")
                DifficultiesEncounteredRadComboBox.DataSource = DataAdapter.LoadExtentDifficultiesEncountered()
                DifficultiesEncounteredRadComboBox.DataBind()
                DifficultiesEncounteredRadComboBox.Items.Insert(0, New RadComboBoxItem("", 0))
                DifficultiesEncounteredRadComboBox.Attributes.Add("data-endoscopistid", endoId)

                Dim InsertionComfirmedRadComboBox As RadComboBox = itm.FindControl("InsertionComfirmedRadComboBox")
                InsertionComfirmedRadComboBox.DataSource = DataAdapter.LoadExtentConfirmedList(True)
                InsertionComfirmedRadComboBox.DataBind()
                InsertionComfirmedRadComboBox.Items.Insert(0, New RadComboBoxItem("", 0))
                InsertionComfirmedRadComboBox.Attributes.Add("data-endoscopistid", endoId)

                'Dim InsertLimitedTrID As HtmlTableRow = TryCast(itm.FindControl("InsertionLimitedTrID"), HtmlTableRow)
                'Dim DifficultiesEncounterTr As HtmlTableRow = TryCast(itm.FindControl("DifficultiesEncounteredTr"), HtmlTableRow)
                'Dim InsertionConfirmTrId As HtmlTableRow = TryCast(itm.FindControl("InsertionConfirmedTr"), HtmlTableRow)
                'Dim CeacumTimingTr As HtmlTableRow = TryCast(itm.FindControl("CaecumTimingTR"), HtmlTableRow)
                'Dim CeacumIdentifiedTr As HtmlTableRow = TryCast(itm.FindControl("CaecumIdentifiedTr"), HtmlTableRow)
                'Dim InsertionLimitedOtherTr As HtmlTableRow = TryCast(itm.FindControl("InsertionLimitedOtherTrID"), HtmlTableRow)

                'Dim DifficultiesEncounteredOtherTr As HtmlTableRow = TryCast(itm.FindControl("DifficultiesEncounteredOtherTrID"), HtmlTableRow)


                Dim CaecumIdentifiedByRepeater As Repeater = itm.FindControl("CaecumIdentifiedByRepeater")
                bindRepeater(CaecumIdentifiedByRepeater, endoId)

                If procedureExtent.Rows.Count > 0 Then
                    If Not procedureExtent.AsEnumerable.Any(Function(x) x("EndoscopistId") = endoId) Then Continue For
                    Dim dr = procedureExtent.AsEnumerable.Where(Function(x) x("EndoscopistId") = endoId).CopyToDataTable.Rows(0)
                    If Not dr.IsNull("ExtentId") Then
                        'check if any of the failure options have been returned

                        If LowerExtentComboBox.FindItemIndexByValue(dr("ExtentId")) > -1 Then
                            LowerExtentComboBox.SelectedIndex = LowerExtentComboBox.FindItemIndexByValue(dr("ExtentId"))
                            'ScriptManager.RegisterStartupScript(Me.Page, GetType(Page), "sethideextent", "$('.lower-extent-options').show();", True)
                        End If

                    End If

                    'Dim InsertLimitedTrID As HtmlTableRow = TryCast(itm.FindControl("InsertionLimitedTrID"), HtmlTableRow)
                    'Dim DifficultiesEncounterTr As HtmlTableRow = TryCast(itm.FindControl("DifficultiesEncounteredTr"), HtmlTableRow)

                    'loop through the failed repeater and check the relevant checkbox
                    For Each itm2 As RepeaterItem In rptFailedOutcomes.Items
                        'if abandoned then tick
                        If endoExtents.Any(Function(x) x.ProcedureAbandoned) Then
                            'tick abandoned checkbox
                            Dim cb As CheckBox = CType(itm2.FindControl("cbFailedOption"), CheckBox)
                            If cb IsNot Nothing Then
                                If cb.Attributes("data-failuretype").ToLower() = "abandoned" Then
                                    cb.Checked = True
                                    'InsertLimitedTrID.Visible = True
                                    'DifficultiesEncounterTr.Visible = True

                                End If
                            End If
                        End If

                        'if intubation failed then tick 
                        If endoExtents.Any(Function(x) x.IntubationFailed) Then
                            'tick intubation failed checkbox
                            Dim cb As CheckBox = CType(itm2.FindControl("cbFailedOption"), CheckBox)
                            If cb IsNot Nothing Then
                                If cb.Attributes("data-failuretype").ToLower() = "intubationfailed" Then
                                    cb.Checked = True
                                    'InsertLimitedTrID.Visible = True
                                    'DifficultiesEncounterTr.Visible = True
                                End If
                            End If
                        End If
                    Next

                    If Not dr.IsNull("ConfirmedById") Then InsertionComfirmedRadComboBox.SelectedIndex = InsertionComfirmedRadComboBox.FindItemIndexByValue(dr("ConfirmedById"))
                    'If Not dr.IsNull("ConfirmedById") Then
                    '    InsertionComfirmedRadComboBox.SelectedIndex = InsertionComfirmedRadComboBox.FindItemIndexByValue(dr("ConfirmedById"))

                    'End If
                    If Not dr.IsNull("CaecumIdentifiedById") Then
                        For Each itm2 As RepeaterItem In CaecumIdentifiedByRepeater.Items
                            CType(itm2.FindControl("DataboundCheckbox"), CheckBox).Checked = (CType(itm.FindControl("CaecumIdentifierHiddenField"), HiddenField).Value = CInt(dr("CaecumIdentifiedById")))
                        Next
                        'CaecumIdentifiedByRadComboBox.SelectedIndex = CaecumIdentifiedByRadComboBox.FindItemIndexByValue(dr("CaecumIdentifiedById"))
                    End If
                    If Not dr.IsNull("LimitationId") Then InsertionLimitedRadComboBox.SelectedIndex = InsertionLimitedRadComboBox.FindItemIndexByValue(dr("LimitationId"))
                    If Not dr.IsNull("DifficultiesEncounteredId") Then DifficultiesEncounteredRadComboBox.SelectedIndex = DifficultiesEncounteredRadComboBox.FindItemIndexByValue(dr("DifficultiesEncounteredId"))
                    If Not dr.IsNull("InsertionAccessViaId") Then InsertionViaRadComboBox.SelectedIndex = InsertionViaRadComboBox.FindItemIndexByValue(dr("InsertionAccessViaId"))
                    If Not dr.IsNull("RectalExamPerformed") Then PRDoneRadComboBox.SelectedIndex = If(dr("RectalExamPerformed"), 1, 2)
                    If Not dr.IsNull("RetroflectionPerformed") Then RetroflexionDoneRadComboBox.SelectedIndex = If(dr("RetroflectionPerformed"), 1, 2)

                    If Not dr.IsNull("LimitationOther") Then OtherLimitationTextBox.Text = dr("LimitationOther").ToString()
                    If Not dr.IsNull("NoRetroflectionReason") Then NoRetroflexionReasonTextBox.Text = dr("NoRetroflectionReason")
                    'If Not dr.IsNull("EndoscopistId") Then EndoscopistRadioButtonList.SelectedValue = CInt(dr("EndoscopistId"))




                    'If CInt(dr("ListOrderBy") >= PlannedExtent.PlannedExtentIdValue) Then

                    '    InsertLimitedTrID.Visible = False
                    '    InsertionLimitedRadComboBox.ClearSelection()
                    '    InsertionLimitedRadComboBox.SelectedValue = 0
                    '    OtherLimitationTextBox.Text = Nothing

                    '    DifficultiesEncounterTr.Visible = False
                    '    DifficultiesEncounteredRadComboBox.ClearSelection()
                    '    DifficultiesEncounteredRadComboBox.SelectedValue = 0
                    '    OtherDifficultyTextBox.Text = Nothing 'added today

                    '    InsertionConfirmTrId.Visible = True

                    '    If LowerExtentComboBox.SelectedItem.Text = "Caecum" Or LowerExtentComboBox.SelectedItem.Text = "Terminal ileum" Then

                    '        '    CeacumTimingTr.Visible = True
                    '        InsertionConfirmTrId.Visible = False
                    '        InsertionComfirmedRadComboBox.ClearSelection()
                    '        InsertionComfirmedRadComboBox.SelectedValue = 0
                    '        OtherConfirmedByTextBox.Text = Nothing
                    '        CeacumIdentifiedTr.Visible = True

                    '    Else
                    '        '  CeacumTimingTr.Visible = False
                    '        CaecumTimeRadTimePicker.Clear() 'might get error here 
                    '        CeacumIdentifiedTr.Visible = False
                    '        InsertionConfirmTrId.Visible = True

                    '    End If

                    'Else
                    '    InsertLimitedTrID.Visible = True
                    '    InsertionConfirmTrId.Visible = True
                    '    DifficultiesEncounterTr.Visible = True
                    '    ' CeacumTimingTr.Visible = False
                    '    CaecumTimeRadTimePicker.Clear() 'might get error here 

                    '    CeacumIdentifiedTr.Visible = False
                    '    InsertionComfirmedRadComboBox.ClearSelection()
                    '    InsertionComfirmedRadComboBox.SelectedValue = 0
                    '    OtherConfirmedByTextBox.Text = Nothing
                    'End If
                    ''If InsertLimitedTrID.Visible = True And InsertionComfirmedRadComboBox.SelectedItem.Text = "Other" Then
                    ''    InsertionLimitedOtherTr.Visible = True
                    ''    OtherLimitationTextBox.Visible = True

                    ''End If
                    ''If DifficultiesEncounterTr.Visible = True And DifficultiesEncounteredRadComboBox.SelectedItem.Text = "Other" Then
                    ''    DifficultiesEncounteredOtherTr.Visible = True
                    ''    OtherDifficultyTextBox.Visible = True
                    ''End If

                    'Dim selectedvalueInsertion As RadComboBoxItem = InsertionComfirmedRadComboBox.SelectedItem
                    'If selectedvalueInsertion IsNot Nothing AndAlso selectedvalueInsertion.Text = "Other" Then
                    '    InsertionLimitedOtherTr.Visible = True
                    'End If

                    'Dim selectedvalueDifficulties As RadComboBoxItem = DifficultiesEncounteredRadComboBox.SelectedItem
                    'If selectedvalueDifficulties IsNot Nothing AndAlso selectedvalueDifficulties.Text = "Other" Then
                    '    DifficultiesEncounteredOtherTr.Visible = True
                    'End If

                End If

            Next
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Public Structure ProcedureExtent
        Property EndoscopistName As String
        Property EndoscopistId As Integer
        Property InsertionViaId As Integer
        Property PRDone As Boolean
        Property Retroflexion As Boolean
        Property NoRetroflexionReason As String
        Property ExtentId As Integer
        Property InsertionConfirmedById As Integer
        Property CaecumIdentifiedByIds As List(Of Integer)
        Property LimitedById As Integer
        Property DifficultiesId As Integer
        Property CaecumStartDateTime As DateTime
        Property WithdrawalMinutes As Integer
        Property ProcedureAbandoned As Boolean
        Property IntubationFailed As Boolean
        Property TraineeTrainer As String 'Added by rony tfs-3761
    End Structure

    Private Sub bindRepeater(CaecumIdentifiedByRepeater As Repeater, endoscopistId As Integer)
        'do client side? this may never be needed so could be a pointless load.
        Dim confirmedList = DataAdapter.LoadExtentConfirmedList(False)
        Dim procedureConfirmedList = DataAdapter.getProcedureCaecumComfirmedBy(Session(Constants.SESSION_PROCEDURE_ID))

        CaecumIdentifiedByRepeater.DataSource = confirmedList.AsEnumerable.Where(Function(x) CInt(x("ParentId")) = 0).CopyToDataTable
        CaecumIdentifiedByRepeater.DataBind()
        'CaecumIdentifiedByRadComboBox.Items.Insert(0, New RadComboBoxItem("", 0))


        For Each itm As RepeaterItem In CaecumIdentifiedByRepeater.Items
            Dim chk As New CheckBox

            For Each ctrl As Control In itm.Controls
                If TypeOf ctrl Is CheckBox Then
                    chk = CType(ctrl, CheckBox)
                End If
            Next

            If chk IsNot Nothing Then
                Dim uniqueId = CInt(chk.Attributes.Item("data-uniqueid"))
                chk.Attributes.Add("data-endoscopistid", endoscopistId)

                Dim confirmedRow = confirmedList.AsEnumerable.FirstOrDefault(Function(x) CInt(x("UniqueId")) = uniqueId)
                If confirmedRow IsNot Nothing Then
                    chk.Attributes.Add("data-suppressed", confirmedRow("Suppressed").ToString())
                End If

                chk.Checked = procedureConfirmedList.AsEnumerable.Any(Function(x) CInt(x("ExtentIdentifiedById")) = uniqueId And x("EndoscopistId") = endoscopistId)
                'get the checkbox- dataitem as nothing so cant get the values in that way :(
                If confirmedList.AsEnumerable.Any(Function(x) x("ParentId") = uniqueId) Then
                    Dim childItems = confirmedList.AsEnumerable.Where(Function(x) x("ParentId") = uniqueId)

                    'create a dropdown list and bind child items to it
                    Dim ddlChildren As New RadComboBox
                    With ddlChildren
                        .AutoPostBack = False
                        .Skin = "Metro"
                        .CssClass = "identifiedby-child"
                        .Attributes.Add("data-uniqueid", uniqueId)
                        .Attributes.Add("data-endoscopistid", endoscopistId)
                        .OnClientSelectedIndexChanged = "childDDL_changed"
                        If Not chk.Checked Then .Style.Add("display", "none") Else .Style.Add("display", "inline-block")
                    End With


                    For Each ci In childItems
                        ddlChildren.Items.Add(New RadComboBoxItem(ci("Description"), ci("UniqueId")))
                    Next
                    ddlChildren.Items.Insert(0, New RadComboBoxItem("", 0))

                    If True Then
                        ddlChildren.Items.Add(New RadComboBoxItem() With {
                                .Text = "Add new",
                                .Value = -55,
                                .ImageUrl = "~/images/icons/add.png",
                                .CssClass = "comboNewItem"
                                })
                        ddlChildren.Attributes.Add("onchange", "if (typeof AddNewItemPopUp === 'function') { AddNewItemPopUp(" & ddlChildren.ClientID & "); } else { window.parent.AddNewItemPopUp(" & ddlChildren.ClientID & ");" & " }")
                    End If

                    ddlChildren.Sort = RadComboBoxSort.Ascending

                    If procedureConfirmedList.AsEnumerable.Any(Function(x) CInt(x("ExtentIdentifiedById")) = uniqueId And CInt(x("ChildId")) > 0) Then
                        Dim childId = (From pi In procedureConfirmedList.AsEnumerable
                                       Where CInt(pi("ExtentIdentifiedById")) = uniqueId And pi("EndoscopistId") = endoscopistId
                                       Select CInt(pi("ChildId"))).FirstOrDefault

                        ddlChildren.SelectedIndex = ddlChildren.Items.FindItemIndexByValue(childId)
                    End If

                    'add the control to the relevant td
                    itm.Controls.AddAt(itm.Controls.Count - 1, ddlChildren)
                End If

            End If
        Next
    End Sub

    Protected Sub LowerExtentComboBox_ItemDataBound(sender As Object, e As RadComboBoxItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            Dim dr = CType(e.Item.DataItem, DataRowView)
            'Added by ronytfs-2830
            e.Item.Attributes.Add("data-lower-extent", dr("ListOrderBy").ToString)
            e.Item.Attributes.Add("data-successstatus", dr("IsSuccess").ToString)
        End If
    End Sub

    Protected Sub rptLowerExtent_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        Try
            If e.Item.DataItem IsNot Nothing Then
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Protected Sub rptFailedOutcomes_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)

    End Sub
End Class