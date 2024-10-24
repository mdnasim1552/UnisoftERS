Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Options_Scheduler_Templates
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Me.Master IsNot Nothing Then
                Dim leftPane As RadPane = DirectCast(Me.Master.FindControl("radLeftPane"), RadPane)
                Dim MainRadSplitBar As RadSplitBar = DirectCast(Me.Master.FindControl("MainRadSplitBar"), RadSplitBar)

                If leftPane IsNot Nothing Then leftPane.Visible = False
                If MainRadSplitBar IsNot Nothing Then MainRadSplitBar.Visible = False
            End If
        End If

        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Me.Page)

        myAjaxMgr.AjaxSettings.AddAjaxSetting(myAjaxMgr, TemplatesRadGrid, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(TemplatesRadGrid, TemplatesRadGrid, RadAjaxLoadingPanel1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(SuppressedComboBox, TemplatesRadGrid, RadAjaxLoadingPanel1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(FilterByGIRadComboBox, TemplatesRadGrid, RadAjaxLoadingPanel1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(SearchButton, TemplatesRadGrid, RadAjaxLoadingPanel1)

        AddHandler myAjaxMgr.AjaxRequest, AddressOf RadAjaxManager1_AjaxRequest


    End Sub

    Protected Sub HideSuppressButton_Click(sender As Object, e As EventArgs)
        Dim iSuppress As Integer = SuppressedComboBox.SelectedIndex
        Select Case iSuppress
            Case 0
                TemplatesObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = Nothing
            Case 1
                TemplatesObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 1
            Case 2
                TemplatesObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 0
        End Select
        TemplatesRadGrid.MasterTableView.SortExpressions.Clear()
        TemplatesRadGrid.MasterTableView.CurrentPageIndex = TemplatesRadGrid.MasterTableView.PageCount - 1
        TemplatesRadGrid.Rebind()
    End Sub

    Protected Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
        TemplatesObjectDataSource.SelectParameters.Item("Field").DefaultValue = SearchComboBox.SelectedValue
        TemplatesObjectDataSource.SelectParameters.Item("FieldValue").DefaultValue = SearchTextBox.Text
        TemplatesRadGrid.Rebind()
    End Sub
    Protected Sub SearchTemplate()
        TemplatesRadGrid.MasterTableView.SortExpressions.Clear()
        TemplatesRadGrid.MasterTableView.CurrentPageIndex = 0
        TemplatesRadGrid.DataBind()
    End Sub
    Protected Sub clearCosultant()
        SearchComboBox.SelectedIndex = 0
        SearchTextBox.Text = ""
        TemplatesRadGrid.DataBind()
    End Sub

    Private Sub TemplatesRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles TemplatesRadGrid.ItemCommand
        If e.CommandName = "SuppressTemplate" Then
            Dim bSuppress As Boolean = True
            If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                bSuppress = False
            End If
            DataAdapter_Sch.SuppressTemplate(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("ListRulesId")), bSuppress)
            TemplatesRadGrid.Rebind()
        ElseIf e.CommandName = "Rebind" Then
            TemplatesRadGrid.MasterTableView.SortExpressions.Clear()
            TemplatesRadGrid.Rebind()
        ElseIf e.CommandName = "RebindAndNavigate" Then
            TemplatesRadGrid.MasterTableView.SortExpressions.Clear()
            TemplatesRadGrid.MasterTableView.CurrentPageIndex = TemplatesRadGrid.MasterTableView.PageCount - 1
            TemplatesRadGrid.Rebind()
        End If
    End Sub

    Protected Sub TemplatesRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles TemplatesRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            EditLinkButton.Attributes("onclick") = String.Format("return editTemplate('{0}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ListRulesId"))

            'If CInt(e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("AppointmentCount")) > 0 Then
            '    Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            '    SuppressLinkButton.Attributes("href") = "javascript:void(0);"
            '    SuppressLinkButton.Attributes("onclick") = String.Format("checkAndSuppressTemplate({0}, '{1}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ListRulesId"), CDate(e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("LastAppointment")).ToShortDateString) 'alert('This template has bookings against it and therefore cannot be suppressed.'); return false;
            'Else

            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            SuppressLinkButton.Attributes("href") = "javascript:void(0);"
            SuppressLinkButton.OnClientClick = String.Format("return Show('{0}', 'suppress')", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ListRulesId"))

            'End If
        End If
    End Sub

    Protected Sub TemplatesRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles TemplatesRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
            e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)

            If row("Suppressed") Then
                SuppressLinkButton.ForeColor = Color.Gray
                SuppressLinkButton.ToolTip = "Unsuppress Template"
                SuppressLinkButton.OnClientClick = String.Format("return Show('{0}', 'unsuppress')", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ListRulesId"))
                SuppressLinkButton.Text = "Unsuppress"

                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0")
            End If
        End If
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs)
        If e.Argument = "Rebind" Then
            TemplatesRadGrid.MasterTableView.SortExpressions.Clear()
            TemplatesRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            TemplatesRadGrid.MasterTableView.SortExpressions.Clear()
            TemplatesRadGrid.MasterTableView.CurrentPageIndex = TemplatesRadGrid.MasterTableView.PageCount - 1
            TemplatesRadGrid.Rebind()
        End If
    End Sub

    <System.Web.Services.WebMethod()>
    Public Shared Function SuppressTemplate(templateId As Integer, suppressFrom As String) As Boolean
        Try
            Dim da As DataAccess_Sch = New DataAccess_Sch()
            If Not String.IsNullOrWhiteSpace(suppressFrom) Then
                da.SuppressTemplate(templateId, True, suppressFrom)
            Else
                da.SuppressTemplate(templateId, False)
            End If
            Return True
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error in DiaryPages>MoveTemplate", ex)
            Return False
        End Try
    End Function

End Class
