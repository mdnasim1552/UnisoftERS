Imports Constants
Imports Utilities
Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Options_UserMaintenance
    Inherits OptionsBase

    Private dtRoles As DataTable
    Private newUserId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then

        End If
        dtRoles = DataAdapter.GetRoles(True)
    End Sub

    Protected Sub UsersRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles UsersRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            EditLinkButton.Attributes("onclick") = String.Format("return ShowEditForm('{0}','{1}','{2}');", _
                                                                 e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("UserID"), _
                                                                 e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("RoleID"), _
                                                                 e.Item.ItemIndex)

            'Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            'SuppressLinkButton.Attributes("href") = "javascript:void(0);"
            'SuppressLinkButton.Attributes("onclick") = "javascript:if(!confirm('Are you sure you want to suppress this user?')){return false;}"
            'SuppressLinkButton.Attributes("onclick") = "javascript:return confirm('Are you sure you want to suppress this user?')"
            'SuppressLinkButton.Attributes.Add("onclick", "return Show();")
        End If

        'If TypeOf e.Item Is GridFooterItem Then
        '    Dim footerItem As GridFooterItem = DirectCast(e.Item, GridFooterItem)
        '    Dim filterComboBox As New RadComboBox
        '    Dim filterLabel As New Label
        '    RadScriptManager1.RegisterAsyncPostBackControl(filterComboBox)
        '    filterComboBox.Items.Insert(0, New RadComboBoxItem("All users", String.Empty))
        '    filterComboBox.Items.Insert(1, New RadComboBoxItem("Hide suppressed users", String.Empty))
        '    filterComboBox.Items.Insert(1, New RadComboBoxItem("Show suppressed users only", String.Empty))
        '    footerItem("TemplateColumn").ColumnSpan = 7
        '    footerItem("TemplateColumn").HorizontalAlign = HorizontalAlign.Right
        '    For i As Integer = 3 To 7
        '        footerItem.Cells(i).Visible = False
        '    Next
        '    filterComboBox.Skin = "Windows7"
        '    filterComboBox.Width = 200
        '    filterComboBox.AutoPostBack = True
        '    filterLabel.Text = "Filter by : "
        '    footerItem.Cells(2).Controls.Add(filterLabel)
        '    footerItem.Cells(2).Controls.Add(filterComboBox)
        'End If
    End Sub

    Protected Sub UsersRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles UsersRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or _
            e.Item.ItemType = GridItemType.AlternatingItem Then
            'Dim SuppressLinkButton As ImageButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), ImageButton)
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            If row("Username") = "admin" Then
                EditLinkButton.Visible = False
                EditLinkButton.OnClientClick = ""
                SuppressLinkButton.Visible = False
                SuppressLinkButton.OnClientClick = ""
            ElseIf CBool(row("Suppressed")) Then
                SuppressLinkButton.Enabled = False
                SuppressLinkButton.ForeColor = Color.Gray
                'SuppressLinkButton.ImageUrl = "~/Images/suppress_grey.png"
                SuppressLinkButton.ToolTip = If(row("Username") = "admin", "Admin can not be Suppressed", "User suppressed")
                SuppressLinkButton.OnClientClick = ""
            End If


            Dim item As GridDataItem = DirectCast(e.Item, GridDataItem)

            Dim sRole As String() = row("RoleID").Split(",")
            Dim sRoleDesc As New ArrayList
            For Each s In sRole
                Try
                    Dim rows As DataRow() = dtRoles.[Select]("RoleID = " & s)
                    If rows.Count() > 0 Then
                        sRoleDesc.Add(rows(0)(0))   'rows(0)(0) = RoleName
                    End If
                Catch ex As Exception
                End Try
            Next
            item("RoleName").Text = String.Join(", ", sRoleDesc.ToArray)
        End If





    End Sub

    Protected Sub UsersRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles UsersRadGrid.ItemCommand
        If e.CommandName = "SuppressUser" Then
            DataAdapter.UpdateUser(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("UserID")), True)
            UsersRadGrid.Rebind()
        End If
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        If e.Argument = "Rebind" Then
            UsersRadGrid.MasterTableView.SortExpressions.Clear()
            UsersRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            UsersRadGrid.MasterTableView.SortExpressions.Clear()
            UsersRadGrid.MasterTableView.CurrentPageIndex = UsersRadGrid.MasterTableView.PageCount - 1
            UsersRadGrid.Rebind()
        End If
    End Sub

    Protected Sub UserSearchButton_Click(sender As Object, e As EventArgs) Handles UserSearchButton.Click
        'UsersRadGrid.MasterTableView.FilterExpression = "([UserName] LIKE '%admin%') "
        'Dim column As GridColumn = UsersRadGrid.MasterTableView.GetColumnSafe("UserName")
        'column.CurrentFilterFunction = GridKnownFunction.Contains
        'column.CurrentFilterValue = "admin"
        'UsersRadGrid.MasterTableView.Rebind()
        UsersRadGrid.Rebind()
    End Sub

    Protected Sub ItemsButton_Click(sender As Object, e As EventArgs) Handles ItemsButton.Click
        If IsNumeric(ItemsTextBox.Text) AndAlso CInt(ItemsTextBox.Text) > 0 Then
            UsersRadGrid.MasterTableView.SortExpressions.Clear()
            UsersRadGrid.MasterTableView.GroupByExpressions.Clear()
            UsersRadGrid.PageSize = CInt(ItemsTextBox.Text)
            UsersRadGrid.CurrentPageIndex = 0
            UsersRadGrid.Rebind()
        Else
            ItemsTextBox.Text = UsersRadGrid.PageSize
        End If
    End Sub
End Class
