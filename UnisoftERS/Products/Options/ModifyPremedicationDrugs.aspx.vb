Imports Telerik.Web.UI

Partial Class Products_Options_ModifyPremedicationDrugs
    Inherits OptionsBase

    Private newDrugId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            DrugTypeRadComboBox.SelectedValue = Request.QueryString("option")
            'DrugsObjectDataSource.DataBind()
        End If
    End Sub

    Protected Sub DrugsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles DrugsRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"

            Dim dataRow As DataRowView = DirectCast(e.Item.DataItem, DataRowView)
            EditLinkButton.Attributes("onclick") = String.Format("return ShowEditForm('{0}','{1}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("DrugNo"), e.Item.ItemIndex)
        End If
    End Sub
    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        If e.Argument = "Rebind" Then
            DrugsRadGrid.MasterTableView.SortExpressions.Clear()
            DrugsRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            DrugsRadGrid.MasterTableView.SortExpressions.Clear()
            DrugsRadGrid.MasterTableView.CurrentPageIndex = DrugsRadGrid.MasterTableView.PageCount - 1
            DrugsRadGrid.Rebind()
        End If
    End Sub

End Class
