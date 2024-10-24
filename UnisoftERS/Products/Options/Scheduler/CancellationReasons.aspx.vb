
Imports System.Drawing
Imports DevExpress.CodeParser
Imports Telerik.Web.UI
Public Class CancellationReasons
    Inherits OptionsBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Try
                If Me.Master IsNot Nothing Then
                    Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
                    Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

                    If leftPane IsNot Nothing Then leftPane.Visible = False
                    If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
                End If
            Catch ex As Exception

            End Try
        End If

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(RadWindowManager1, CancelReasonsRadGrid, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(CancelReasonsRadGrid, CancelReasonsRadGrid)

    End Sub

    Protected Sub AddNewCancelReasonSaveRadButton_Click(sender As Object, e As EventArgs)
        Try
            If DetailTextBox.Text IsNot "" Then
                Dim da As New DataAccess_Sch
                Dim ProcedureName As String
                Dim cancelTypeText As String = ReasonTypeRadComboBox.Text
                If cancelTypeText = "Cancellation reasons" Then
                    ProcedureName = "sch_CancellationReasons_insert_update"
                Else
                    ProcedureName = "sch_ScheduleList_Cancellation_Reasons_insert_update"
                End If
                If AddNewCancelReasonSaveRadButton.Text = "Update" Then
                    da.InsertUpdateCancellationReasons(ProcedureName, CodeTextBox.Text, DetailTextBox.Text, CancelledByHospitalRadCheckBox.Checked, Session("PKUserID").ToString, CancelReasonIDText.Text) ', HiddenID.Value)
                ElseIf AddNewCancelReasonSaveRadButton.Text <> "" Then
                    da.InsertUpdateCancellationReasons(ProcedureName, CodeTextBox.Text, DetailTextBox.Text, CancelledByHospitalRadCheckBox.Checked, Session("PKUserID").ToString)
                End If
                If (cancelTypeText = "Cancellation reasons") Then
                    CancelReasonsRadGrid.Rebind()
                Else
                    ShecheduleReasonsRadGrid.Rebind()
                End If
                ScriptManager.RegisterStartupScript(Me.Page, Page.GetType, "close_window_script", "CloseConfigWindow();", True)
            End If

        Catch ex As Exception
            Dim errorMsg = "Error saving cancellation reason"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub CancelReasonsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles CancelReasonsRadGrid.ItemCreated
        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
                EditLinkButton.Attributes("href") = "javascript:void(0);"
                EditLinkButton.Attributes("onclick") = String.Format("return addCancelReasons('{0}');", e.Item.ItemIndex)
            End If
        Catch ex As Exception
            Dim errorMsg = "Error in CancelReasonsRadGrid_ItemCreated"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub ShecheduleReasonsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles ShecheduleReasonsRadGrid.ItemCreated
        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("ListReasonsEditButton"), LinkButton)
                EditLinkButton.Attributes("href") = "javascript:void(0);"
                EditLinkButton.Attributes("onclick") = String.Format("return addCancelReasons('{0}');", e.Item.ItemIndex)
            End If
        Catch ex As Exception
            Dim errorMsg = "Error in ShecheduleReasonsRadGrid_ItemCreated"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub
    Protected Sub LetterEditReasonsGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles LetterEditReasonsGrid.ItemCreated
        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim LetterEditLinkButton As LinkButton = DirectCast(e.Item.FindControl("LetterEditLinkButton"), LinkButton)

                LetterEditLinkButton.Attributes("href") = "javascript:void(0);"
                LetterEditLinkButton.Attributes("onclick") = String.Format("return editLetterEditReason('{0}');", e.Item.ItemIndex)

            End If
        Catch ex As Exception
            Dim errorMsg = "Error in LetterEditReasonsGrid_ItemCreated"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub ReasonTypeRadComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Try
            Select Case ReasonTypeRadComboBox.SelectedValue
                Case 0
                    pnlCancellationReasons.Visible = True
                    pnlDiaryLockReasons.Visible = False
                    pnlLetterEditReasons.Visible = False
                    pnlListLockReasons.Visible = False
                    pnlTemplateReasons.Visible = False
                Case 1
                    pnlCancellationReasons.Visible = False
                    pnlDiaryLockReasons.Visible = True
                    pnlLetterEditReasons.Visible = False
                    pnlListLockReasons.Visible = False
                    pnlTemplateReasons.Visible = False
                Case 2
                    pnlCancellationReasons.Visible = False
                    pnlDiaryLockReasons.Visible = False
                    pnlLetterEditReasons.Visible = True
                    pnlListLockReasons.Visible = False
                    pnlTemplateReasons.Visible = False
                Case 3
                    pnlListLockReasons.Visible = True
                    pnlCancellationReasons.Visible = False
                    pnlDiaryLockReasons.Visible = False
                    pnlLetterEditReasons.Visible = False
                    pnlTemplateReasons.Visible = False
                Case 4
                    pnlTemplateReasons.Visible = True
                    pnlListLockReasons.Visible = False
                    pnlCancellationReasons.Visible = False
                    pnlDiaryLockReasons.Visible = False
                    pnlLetterEditReasons.Visible = False
            End Select
            'If ReasonTypeRadComboBox.SelectedValue = 0 Then
            '    pnlCancellationReasons.Visible = True
            '    pnlDiaryLockReasons.Visible = False
            'Else
            '    pnlCancellationReasons.Visible = False
            '    pnlDiaryLockReasons.Visible = True
            'End If
        Catch ex As Exception
            Dim errorMsg = "Error in ReasonTypeRadComboBox_SelectedIndexChanged"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub SaveLockReasonRadButton_Click(sender As Object, e As EventArgs)
        Try
            Dim lockReasonId = If(String.IsNullOrWhiteSpace(ReasonsIdHiddenField.Value), 0, CInt(ReasonsIdHiddenField.Value))
            Dim reason = DiaryLockReasonRadTextBox.Text
            Dim isLockReason = IsLockReasonRadioButtonList.SelectedValue = 1
            Dim isUnLockReason = IsLockReasonRadioButtonList.SelectedValue = 0

            DataAdapter_Sch.AddDiaryLockReason(lockReasonId, reason, isLockReason, isUnLockReason)
            DiaryLockReasonsRadGrid.MasterTableView.SortExpressions.Clear()
            DiaryLockReasonsRadGrid.MasterTableView.CurrentPageIndex = DiaryLockReasonsRadGrid.MasterTableView.PageCount - 1
            DiaryLockReasonsRadGrid.Rebind()

        Catch ex As Exception
            Dim errorMsg = "Error saving lock reason"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub SaveLLetterEditReasonRadButton_Click(sender As Object, e As EventArgs)
        Try
            Dim LetterEditReasonId = If(String.IsNullOrWhiteSpace(hdnLetterEditReasonId.Value), 0, CInt(hdnLetterEditReasonId.Value))
            Dim reason = LetterEditReasonText.Text
            Dim userid As Long = CType(Session("PKUserID").ToString, Long)
            Dim letterGenerationObject As LetterGeneration = New LetterGeneration()
            If (hdnLetterEditReasonId.Value = "") Then
                letterGenerationObject.InsertLetterEditReason(reason, userid)
            Else
                letterGenerationObject.UpdateLetterEditReason(CType(hdnLetterEditReasonId.Value, Long), reason, userid)
            End If

            LetterEditReasonsGrid.MasterTableView.SortExpressions.Clear()

            LetterEditReasonsGrid.MasterTableView.CurrentPageIndex = LetterEditReasonsGrid.MasterTableView.PageCount - 1
            LetterEditReasonsGrid.Rebind()

        Catch ex As Exception
            Dim errorMsg = "Error letter edit reason"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub DiaryLockReasonsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles DiaryLockReasonsRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
           e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLockReasonLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)

            If row("Suppressed") Then
                SuppressLinkButton.ForeColor = Color.Gray
                SuppressLinkButton.ToolTip = "Unsuppress Template"
                SuppressLinkButton.OnClientClick = String.Format("return Show('{0}', 'unsuppress')", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DiaryLockReasonId"))
                SuppressLinkButton.Text = "Unsuppress"

                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0")
            End If
        End If
    End Sub

    Protected Sub CancelReasonsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles CancelReasonsRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
           e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)

            If row("Suppressed") Then
                SuppressLinkButton.ForeColor = Color.Gray
                SuppressLinkButton.ToolTip = "Unsuppress Template"
                SuppressLinkButton.OnClientClick = String.Format("return Show('{0}', 'unsuppress')", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("CancelReasonId"))
                SuppressLinkButton.Text = "Unsuppress"
                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0")
            End If
        End If
    End Sub

    Protected Sub ScheduleListCancelReasonsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles ShecheduleReasonsRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
           e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim ScheduleSuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("ScheduleSuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)

            If row("Suppressed") Then
                ScheduleSuppressLinkButton.ForeColor = Color.Gray
                ScheduleSuppressLinkButton.ToolTip = "Unsuppress Template"
                ScheduleSuppressLinkButton.OnClientClick = String.Format("return Show('{0}', 'unsuppress')", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ListCancelReasonId"))
                ScheduleSuppressLinkButton.Text = "Unsuppress"
                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0")
            End If
        End If
    End Sub

    Protected Sub ListLockReasonsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles ListLockReasonsRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
           e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressListLockReasonLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)

            If row("Suppressed") Then
                SuppressLinkButton.ForeColor = Color.Gray
                SuppressLinkButton.ToolTip = "Unsuppress Template"
                SuppressLinkButton.OnClientClick = String.Format("return Show('{0}', 'unsuppress')", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ListLockReasonId"))
                SuppressLinkButton.Text = "Unsuppress"

                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0")
            End If
        End If
    End Sub

    Protected Sub LetterEditReasonsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles LetterEditReasonsGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
           e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLetterEditReasonLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)

            If row("Suppressed") Then
                SuppressLinkButton.ForeColor = Color.Gray
                SuppressLinkButton.ToolTip = "Unsuppress edit reason"
                SuppressLinkButton.OnClientClick = String.Format("return Show('{0}', 'unsuppress')", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("LetterEditReasonId"))
                SuppressLinkButton.Text = "Unsuppress"

                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0")
            End If
        End If
    End Sub
    Protected Sub DiaryLockReasonsRadGrid_ItemCreated(sender As Object, e As GridItemEventArgs)
        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLockReasonLinkButton"), LinkButton)
                EditLinkButton.Attributes("href") = "javascript:void(0);"
                EditLinkButton.Attributes("onclick") = String.Format("return editLockReason('{0}');", e.Item.ItemIndex)
            End If
        Catch ex As Exception
            Dim errorMsg = "Error in DiaryLockReasonsRadGrid_ItemCreated"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub CancelReasonsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles CancelReasonsRadGrid.ItemCommand
        Try
            Dim da As New DataAccess_Sch
            If e.CommandName = "SuppressCancelReason" Then
                Dim bSuppress As Boolean = True
                If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                    bSuppress = False
                End If

                da.SuppressCancellationReason(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("CancelReasonId")), bSuppress)
                CancelReasonsRadGrid.Rebind()
            End If
        Catch ex As Exception
            Dim errorMsg = "Error suppressing this cancellation reason"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub ShecheduleReasonsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles ShecheduleReasonsRadGrid.ItemCommand
        Try
            Dim da As New DataAccess_Sch
            If e.CommandName = "ShecheduleReasonsRadGrid" Then
                Dim bSuppress As Boolean = True
                If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                    bSuppress = False
                End If

                da.SuppressScheduleListCancelReason(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("ListCancelReasonId")), bSuppress)
                ShecheduleReasonsRadGrid.Rebind()
            End If
        Catch ex As Exception
            Dim errorMsg = "Error suppressing this cancellation reason"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub DiaryLockReasonsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles DiaryLockReasonsRadGrid.ItemCommand
        Try
            Dim da As New DataAccess_Sch
            If e.CommandName = "SuppressLockReason" Then
                Dim bSuppress As Boolean = True
                If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                    bSuppress = False
                End If

                da.SuppressLockReason(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("DiaryLockReasonId")), bSuppress)
                DiaryLockReasonsRadGrid.Rebind()
            End If
        Catch ex As Exception
            Dim errorMsg = "Error suppressing this diary lock reason"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub LetterEditReasonsGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles LetterEditReasonsGrid.ItemCommand
        Try
            Dim da As New DataAccess_Sch
            If e.CommandName = "SuppressEditLetterReason" Then
                Dim bSuppress As Boolean = True
                If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                    bSuppress = False
                End If

                Dim letterGenerationObject As LetterGeneration = New LetterGeneration()
                Dim userid = CInt(Session("PKUserID"))
                letterGenerationObject.UpdateLetterEditReasonStatus(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("LetterEditReasonId")), bSuppress, userid)


                LetterEditReasonsGrid.MasterTableView.SortExpressions.Clear()

                LetterEditReasonsGrid.MasterTableView.CurrentPageIndex = LetterEditReasonsGrid.MasterTableView.PageCount - 1
                LetterEditReasonsGrid.Rebind()

            End If
        Catch ex As Exception
            Dim errorMsg = "Error suppressing this diary lock reason"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub ListLockReasonsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles ListLockReasonsRadGrid.ItemCommand
        Try
            Dim da As New DataAccess_Sch
            If e.CommandName = "SuppressListLockReason" Then
                Dim bSuppress As Boolean = True
                If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                    bSuppress = False
                End If

                da.SuppressListLockReason(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("ListLockReasonId")), bSuppress)
                ListLockReasonsRadGrid.Rebind()
            End If
        Catch ex As Exception
            Dim errorMsg = "Error suppressing this list lock reason"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub

    Protected Sub SaveListLockReasonRadButton_Click(sender As Object, e As EventArgs)
        Try
            Dim lockReasonId = If(String.IsNullOrWhiteSpace(ReasonsIdHiddenField.Value), 0, CInt(ReasonsIdHiddenField.Value))
            Dim reason = ListLockReasonRadTextBox.Text
            Dim isLockReason = IsListLockReasonRadioButtonList.SelectedValue = 1
            Dim isUnLockReason = IsListLockReasonRadioButtonList.SelectedValue = 0

            DataAdapter_Sch.AddListLockReason(lockReasonId, reason, isLockReason, isUnLockReason)
            ListLockReasonsRadGrid.MasterTableView.SortExpressions.Clear()
            ListLockReasonsRadGrid.MasterTableView.CurrentPageIndex = ListLockReasonsRadGrid.MasterTableView.PageCount - 1
            ListLockReasonsRadGrid.Rebind()

        Catch ex As Exception
            Dim errorMsg = "Error saving list lock reason"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, errorMsg)
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub ListLockReasonsRadGrid_ItemCreated(sender As Object, e As GridItemEventArgs)
        Try
            If TypeOf e.Item Is GridDataItem Then
                Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditListLockReasonLinkButton"), LinkButton)
                EditLinkButton.Attributes("href") = "javascript:void(0);"
                EditLinkButton.Attributes("onclick") = String.Format("return editListLockReason('{0}');", e.Item.ItemIndex)
            End If
        Catch ex As Exception
            Dim errorMsg = "Error in ListLockReasonsRadGrid_ItemCreated"
            Dim ref = LogManager.LogManagerInstance.LogError(errorMsg, ex)
        End Try
    End Sub


End Class

