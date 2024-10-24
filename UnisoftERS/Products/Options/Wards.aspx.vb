Imports Telerik.Web.UI
Imports System.Drawing

Public Class Wards
    Inherits OptionsBase

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub
    Protected Sub HideSuppressButton_Click(sender As Object, e As EventArgs)
        Dim iSuppress As Integer = SuppressedComboBox.SelectedIndex
        Select Case iSuppress
            Case 0
                WardsObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = Nothing
            Case 1
                WardsObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 1
            Case 2
                WardsObjectDataSource.SelectParameters.Item("Suppressed").DefaultValue = 0
        End Select
        WardsObjectDataSource.DataBind()
    End Sub

    Protected Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
        WardsRadGrid.Rebind()
    End Sub

    Protected Sub SearchWard()
        WardsRadGrid.MasterTableView.SortExpressions.Clear()
        WardsRadGrid.MasterTableView.CurrentPageIndex = 0
        WardsRadGrid.DataBind()
    End Sub

    Private Sub WardsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles WardsRadGrid.ItemCommand
        If e.CommandName = "SuppressWard" Then
            Dim bSuppress As Boolean = True
            If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                bSuppress = False
            End If
            DataAdapter.SuppressWard(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("WardId")), bSuppress)
            WardsRadGrid.Rebind()
        End If
    End Sub

    Protected Sub WardsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles WardsRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            EditLinkButton.Attributes("onclick") = String.Format("return editWard('{0}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("WardId"))
        End If
    End Sub

    Protected Sub WardsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles WardsRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
            e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            If row("Suppressed") = "Yes" Then
                SuppressLinkButton.ForeColor = Color.Gray
                SuppressLinkButton.ToolTip = "Unsuppress Ward"
                SuppressLinkButton.OnClientClick = ""
                SuppressLinkButton.Text = "Unsuppress"
                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0")
            End If
        End If
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        If e.Argument = "Rebind" Then
            WardsRadGrid.MasterTableView.SortExpressions.Clear()
            WardsRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            WardsRadGrid.MasterTableView.SortExpressions.Clear()
            WardsRadGrid.MasterTableView.CurrentPageIndex = WardsRadGrid.MasterTableView.PageCount - 1
            WardsRadGrid.Rebind()
        End If
    End Sub


    Protected Sub ScopesRadGrid_NeedDataSource(sender As Object, e As GridNeedDataSourceEventArgs)
        WardsRadGrid.DataSource = DataAdapter.GetWardsLst("", Nothing)
    End Sub

End Class