Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Options_ListItem
    Inherits OptionsBase

    Private newUserId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{FilterByComboBox, ""}}, DataAdapter.GetUniqueListDescription(), "ListDescription", "ListDescription")
            'Utilities.LoadDropdown(FilterByComboBox, DataAdapter.GetUniqueListDescription(), "ListDescription", "ListDescription", Nothing)
        End If
    End Sub

    Protected Sub HideSuppressButton_Click(sender As Object, e As EventArgs)
        Dim iSuppress As Integer = SuppressedComboBox.SelectedIndex
        Select Case iSuppress
            Case 0
                UsersObjectDataSource.SelectParameters.Item("showSuppressed").DefaultValue = Nothing
            Case 1
                UsersObjectDataSource.SelectParameters.Item("showSuppressed").DefaultValue = "true"
            Case 2
                UsersObjectDataSource.SelectParameters.Item("showSuppressed").DefaultValue = "false"
        End Select
        ListsRadGrid.DataBind()
    End Sub
    Protected Sub ListsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles ListsRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim sItemName As String = ""
            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            If (DataBinder.Eval(e.Item.DataItem, "ListItemText") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "ListItemText").ToString())) Then
                sItemName = e.Item.DataItem("ListItemText").ToString()
            Else
                sItemName = ""
            End If

            'EditLinkButton.Attributes("onclick") = "javascript:if(!confirm('Are you sure you want to suppress this user?')){return false;}"
            'EditLinkButton.Attributes("onclick") = "openAddItemWindow();" 'e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("LisdId"), e.Item.ItemIndex)
            EditLinkButton.Attributes("onclick") = String.Format("return openAddItemWindow('{0}','{1}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ListId"), sItemName)


            'Dim iItemId As Integer = 0
            'Dim sItemName As String = ""
            'Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            ''EditLinkButton.Attributes("href") = "javascript:void(0);"
            'iItemId = e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ItemId")

            'If (DataBinder.Eval(e.Item.DataItem, "ListItemText") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "ListItemText").ToString())) Then
            '    sItemName = e.Item.DataItem("ListItemText").ToString()
            'Else
            '    sItemName = ""
            'End If
            ''sroleName = IIf(e.Item.DataItem, "", e.Item.DataItem("RoleName").ToString())
            'EditLinkButton.Attributes("onclick") = String.Format("return openAddItemWindow('{0}','{1}');", iItemId, sItemName) 'e.Item.ItemIndex)



            'Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            'EditLinkButton.Attributes("href") = "javascript:void(0);"
            'EditLinkButton.Attributes("onclick") = String.Format("return ShowEditForm('{0}','{1}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("ListId"), e.Item.ItemIndex)

            'Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            'SuppressLinkButton.Attributes("href") = "javascript:void(0);"
            'SuppressLinkButton.Attributes("onclick") = "javascript:if(!confirm('Are you sure you want to suppress this user?')){return false;}"
            'SuppressLinkButton.Attributes("onclick") = "javascript:return confirm('Are you sure you want to suppress this user?')"
            'SuppressLinkButton.Attributes.Add("onclick", "return Show();")
        End If

        'If TypeOf e.Item Is GridHeaderItem Then
        '    Dim item As GridHeaderItem = TryCast(e.Item, GridHeaderItem)
        '    Dim header As GridHeaderItem = DirectCast(e.Item, GridHeaderItem)

        '    Dim chkBox As New RadButton
        '    chkBox.Text = "Show suppressed items"
        '    If Session("SkinName").ToString <> "" Then
        '        chkBox.Skin = Session("SkinName").ToString()
        '    Else
        '        chkBox.Skin = "Windows7"
        '    End If
        '    chkBox.AutoPostBack = False
        '    chkBox.ButtonType = RadButtonType.ToggleButton
        '    chkBox.ToggleType = ButtonToggleType.CheckBox
        '    chkBox.ForeColor = Color.DarkSlateGray      '  ColorTranslator.FromHtml("#384e76")
        '    chkBox.CssClass = "suppressChkBox"
        '    chkBox.OnClientCheckedChanged = "showSuppressedItems"
        '    If hiddenShowSuppressedItems.Value = True Then
        '        chkBox.Checked = True
        '    End If
        '    header("ListItemText").Controls.Add(chkBox)
        'End If

        If TypeOf e.Item Is GridFooterItem Then
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
        End If
    End Sub

    Protected Sub ListsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles ListsRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or
            e.Item.ItemType = GridItemType.AlternatingItem Then
            'Dim SuppressLinkButton As ImageButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), ImageButton)
            Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            If CBool(row("Suppressed")) Then
                'SuppressLinkButton.Enabled = True
                SuppressLinkButton.ForeColor = Color.Gray
                'SuppressLinkButton.ImageUrl = "~/Images/suppress_grey.png"
                SuppressLinkButton.ToolTip = "Unsuppress this item"
                SuppressLinkButton.OnClientClick = ""
                SuppressLinkButton.Text = "Unsuppress"
                Dim dataItem As GridDataItem = e.Item
                dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0 ")
            End If
        End If
    End Sub

    Protected Sub ListsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles ListsRadGrid.ItemCommand
        If e.CommandName = "SuppressItem" Then
            Dim bSuppress As Boolean = True
            If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                bSuppress = False
            End If
            DataAdapter.SuppressItemList(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("ListId")), bSuppress)
            ListsRadGrid.Rebind()
        End If
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
        If e.Argument = "Rebind" Then
            ListsRadGrid.MasterTableView.SortExpressions.Clear()
            ListsRadGrid.Rebind()
        ElseIf e.Argument = "RebindAndNavigate" Then
            ListsRadGrid.MasterTableView.SortExpressions.Clear()
            ListsRadGrid.MasterTableView.CurrentPageIndex = ListsRadGrid.MasterTableView.PageCount - 1
            ListsRadGrid.Rebind()
        End If
    End Sub

    'Protected Sub ItemsButton_Click(sender As Object, e As EventArgs) Handles ItemsButton.Click
    'If IsNumeric(ItemsTextBox.Text) AndAlso CInt(ItemsTextBox.Text) > 0 Then
    '    UsersRadGrid.MasterTableView.SortExpressions.Clear()
    '    UsersRadGrid.MasterTableView.GroupByExpressions.Clear()
    '    UsersRadGrid.PageSize = CInt(ItemsTextBox.Text)
    '    UsersRadGrid.CurrentPageIndex = 0
    '    UsersRadGrid.Rebind()
    'Else
    '    ItemsTextBox.Text = UsersRadGrid.PageSize
    'End If
    'End Sub

    Protected Sub AddNewItemSaveRadButton_Click(sender As Object, e As EventArgs) Handles AddNewItemSaveRadButton.Click
        Dim da As New DataAccess
        Dim newItemId As Integer

        If AddNewItemSaveRadButton.Text = "Update" Then
            da.UpdateItemList(CInt(hiddenItemId.Value), AddNewItemRadTextBox.Text)
            ListsRadGrid.Rebind()
        ElseIf AddNewItemRadTextBox.Text <> "" Then
            newItemId = da.InsertListItem(FilterByComboBox.SelectedValue.ToString, AddNewItemRadTextBox.Text)
            AddNewItemRadTextBox.Text = ""
            ListsRadGrid.Rebind()
        End If
        Page.ClientScript.RegisterStartupScript(Me.GetType(), "clse", "closeAddItemWindow();", True)
    End Sub
End Class
