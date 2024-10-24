Imports System.Drawing
Imports Telerik.Web.UI

Partial Class Products_Options_RoleMaintenance
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then

        End If
    End Sub

    Protected Sub RolesRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles RolesRadGrid.ItemCreated
        Dim iRoleId As Integer = 0
        Dim sroleName As String = ""
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            iRoleId = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("RoleId")

            If (DataBinder.Eval(e.Item.DataItem, "RoleName") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "RoleName").ToString())) Then
                sroleName = e.Item.DataItem("RoleName").ToString()
            Else
                sroleName = ""
            End If
            'sroleName = IIf(e.Item.DataItem, "", e.Item.DataItem("RoleName").ToString())
            EditLinkButton.Attributes("onclick") = String.Format("return openAddRoleWindow('{0}','{1}');", iRoleId, sroleName) 'e.Item.ItemIndex)


            '  If(DataBinder.Eval(e.Item.DataItem, "RoleName") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "Address_Line_1").ToString()), DataBinder.Eval(Container.DataItem, "Address_Line_1").ToString() & ",", "")

            'Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            'SuppressLinkButton.Attributes("href") = "javascript:void(0);"
            'SuppressLinkButton.Attributes("onclick") = "javascript:if(!confirm('Are you sure you want to suppress this user?')){return false;}"
            'SuppressLinkButton.Attributes("onclick") = "javascript:return confirm('Are you sure you want to suppress this user?')"
            'SuppressLinkButton.Attributes.Add("onclick", "return Show();")
        End If
    End Sub

    Protected Sub UsersRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles RolesRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or _
            e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim DeleteLinkButton As LinkButton = DirectCast(e.Item.FindControl("DeleteLinkButton"), LinkButton)
            'Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            'If CBool(row("Suppressed")) Then
            'SuppressLinkButton.Enabled = False
            'SuppressLinkButton.Enabled = False
            'SuppressLinkButton.ForeColor = Color.Gray
            'SuppressLinkButton.OnClientClick = ""
            'End If
        End If
    End Sub

    Protected Sub RolesRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles RolesRadGrid.ItemCommand

        If e.Item.ItemType = GridItemType.Item Or e.Item.ItemType = GridItemType.AlternatingItem Then
            If e.CommandName = "Delete" Then
                DataAdapter.DeleteRole(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("RoleID")))
                RolesRadGrid.Rebind()
                'ElseIf e.CommandName = "Update" Then

                '    Dim item As GridDataItem = DirectCast(e.Item, GridDataItem)

                '    Dim oRow As System.Data.DataRowView = DirectCast(item.DataItem, System.Data.DataRowView)
                '    Dim RoleId As Integer = Convert.ToInt32(item.GetDataKeyValue("RoleId"))

                '    DataAdapter.UpdateRoles(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("RoleID")), DirectCast(e.Item, GridDataItem).GetDataKeyValue("RoleName"))
                '    RolesRadGrid.Rebind()
            End If
        End If

    End Sub

    Protected Sub RolesRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles RolesRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
            e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            Dim DeleteLinkButton As LinkButton = DirectCast(e.Item.FindControl("DeleteLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            If row("IsEditable") = 0 Then
                EditLinkButton.Visible = False
                DeleteLinkButton.Visible = False
            End If
        End If
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        If e.Argument = "Rebind" Then
            RolesRadGrid.MasterTableView.SortExpressions.Clear()
            RolesRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            RolesRadGrid.MasterTableView.SortExpressions.Clear()
            RolesRadGrid.MasterTableView.CurrentPageIndex = RolesRadGrid.MasterTableView.PageCount - 1
            RolesRadGrid.Rebind()
        End If
    End Sub

    'UsersRadGrid.Rebind()


    Protected Sub AddNewRoleSaveRadButton_Click(sender As Object, e As EventArgs) Handles AddNewRoleSaveRadButton.Click
        Dim da As New DataAccess
        Dim newRoleId As Integer

        If AddNewRoleSaveRadButton.Text = "Update" Then
            'Dim item As GridDataItem = DirectCast(e.Item, GridDataItem)
            'Dim oRow As System.Data.DataRowView = DirectCast(item.DataItem, System.Data.DataRowView)
            'Dim RoleId As Integer = Convert.ToInt32(item.GetDataKeyValue("RoleId"))

            DataAdapter.UpdateRoles(CInt(hiddenRoleId.Value), AddNewRoleRadTextBox.Text)
            RolesRadGrid.Rebind()
        ElseIf AddNewRoleRadTextBox.Text <> "" Then
            newRoleId = da.InsertRole(AddNewRoleRadTextBox.Text)
            AddNewRoleRadTextBox.Text = ""
            RolesRadGrid.Rebind()
        End If
        Page.ClientScript.RegisterStartupScript(Me.GetType(), "clse", "closeAddRoleWindow();", True)
    End Sub
End Class
