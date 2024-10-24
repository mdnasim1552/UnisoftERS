Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Options_Scopes
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load

    End Sub
    Protected Sub HideSuppressButton_Click(sender As Object, e As EventArgs)
        Dim iSuppress As Integer = SuppressedComboBox.SelectedIndex
        Select Case iSuppress
            Case 0
                ScopesObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = Nothing
            Case 1
                ScopesObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 1
            Case 2
                ScopesObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 0
        End Select
        ScopesRadGrid.DataBind()
    End Sub

    Protected Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
        ScopesRadGrid.Rebind()
    End Sub
    Protected Sub SearchScope()
        ScopesRadGrid.MasterTableView.SortExpressions.Clear()
        ScopesRadGrid.MasterTableView.CurrentPageIndex = 0
        ScopesRadGrid.DataBind()
    End Sub

    Private Sub ScopesRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles ScopesRadGrid.ItemCommand
        If e.CommandName = "SuppressScope" Then
            Dim bSuppress As Boolean = True
            If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                bSuppress = False
            End If
            DataAdapter.SuppressScope(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("ScopeId")), bSuppress)
            ScopesRadGrid.Rebind()
        End If
    End Sub

    Protected Sub ScopesRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles ScopesRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            EditLinkButton.Attributes("onclick") = String.Format("return editScope('{0}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ScopeId"))
        End If
    End Sub

    Protected Sub ScopesRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles ScopesRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
            e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            If row("Suppressed") = "Yes" Then
                SuppressLinkButton.ForeColor = Color.Gray
                SuppressLinkButton.ToolTip = "Unsuppress Scope"
                SuppressLinkButton.OnClientClick = ""
                SuppressLinkButton.Text = "Unsuppress"
                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0")
            End If
        End If
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        If e.Argument = "Rebind" Then
            ScopesRadGrid.MasterTableView.SortExpressions.Clear()
            ScopesRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            ScopesRadGrid.MasterTableView.SortExpressions.Clear()
            ScopesRadGrid.MasterTableView.CurrentPageIndex = ScopesRadGrid.MasterTableView.PageCount - 1
            ScopesRadGrid.Rebind()
        End If
    End Sub
End Class
