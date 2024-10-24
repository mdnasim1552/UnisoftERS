Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Options_FieldLabels
    Inherits OptionsBase

    Private newUserId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{FilterByComboBox, ""}}, DataAdapter.GetFieldUniqueFormName(), "FormName", "PageID")
            'Utilities.LoadDropdown(FilterByComboBox, DataAdapter.GetFieldUniqueFormName(), "FormName", "PageID", Nothing)
        End If
    End Sub

    Protected Sub ListsRadGrid_ItemCreated(ByVal sender As Object, ByVal e As GridItemEventArgs) Handles ListsRadGrid.ItemCreated
        If TypeOf e.Item Is GridDataItem Then
            Dim sItemName As String = ""
            Dim sItemID As String = ""
            Dim sOverride As String = ""
            Dim sPlural As String = ""
            Dim sDesc As String = ""
            Dim sColour As String = ""
            Dim sRequired As String = ""
            Dim sSuppressed As String = ""
            Dim sControlType As String = ""
            Dim sProcedureType As String = ""
            Dim bTextIsEditable As Boolean = False
            Dim sEditingType As String = ""
            Dim sFieldName As String = ""

            Dim EditLinkButton As LinkButton = DirectCast(e.Item.FindControl("EditLinkButton"), LinkButton)
            EditLinkButton.Attributes("href") = "javascript:void(0);"
            If (DataBinder.Eval(e.Item.DataItem, "LabelName") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "LabelName").ToString())) Then
                sItemName = e.Item.DataItem("LabelName").ToString()
            Else
                sItemName = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "LabelID") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "LabelID").ToString())) Then
                sItemID = e.Item.DataItem("LabelID").ToString()
            Else
                sItemID = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "Override") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "Override").ToString())) Then
                sOverride = e.Item.DataItem("Override").ToString()
            Else
                sOverride = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "Plural") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "Plural").ToString())) Then
                sPlural = e.Item.DataItem("Plural").ToString()
            Else
                sPlural = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "Hint") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "Hint").ToString())) Then
                sDesc = e.Item.DataItem("Hint").ToString()
            Else
                sDesc = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "Colour") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "Colour").ToString())) Then
                sColour = e.Item.DataItem("Colour").ToString()
                'sColour = Replace(sColour, "#", "")
                'RadColourPicker.SelectedColor = ColorTranslator.FromHtml(sColour)
            Else
                sColour = ""
            End If
            If DataBinder.Eval(e.Item.DataItem, "Required") IsNot Nothing Then
                sRequired = CBool(e.Item.DataItem("Required")).ToString()
                'sColour = Replace(sColour, "#", "")
                'RadColourPicker.SelectedColor = ColorTranslator.FromHtml(sColour)
            Else
                sRequired = "false"
            End If
            If (DataBinder.Eval(e.Item.DataItem, "FieldName") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "FieldName").ToString())) Then
                sFieldName = e.Item.DataItem("FieldName").ToString()
            Else
                sFieldName = ""
            End If
            If DataBinder.Eval(e.Item.DataItem, "RequiredCannotBeSuppressed") IsNot Nothing Then
                sSuppressed = CBool(e.Item.DataItem("RequiredCannotBeSuppressed")).ToString()
            Else
                sSuppressed = "false"
            End If
            If (DataBinder.Eval(e.Item.DataItem, "ControlType") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "ControlType").ToString())) Then
                sControlType = e.Item.DataItem("ControlType").ToString()
            Else
                sControlType = ""
            End If
            If (DataBinder.Eval(e.Item.DataItem, "ProcedureType") IsNot Nothing AndAlso Not [String].IsNullOrEmpty(DataBinder.Eval(e.Item.DataItem, "ProcedureType").ToString())) Then
                sProcedureType = e.Item.DataItem("ProcedureType").ToString()
            Else
                sProcedureType = ""
            End If

            If Not String.IsNullOrWhiteSpace(sControlType) Then
                Select Case sControlType.ToLower()
                    Case "radbutton"
                        sEditingType = "Button"
                        bTextIsEditable = True
                    Case "RadComboBox", "raddropdownlist"
                        sEditingType = "Dropdown"
                    Case "radnumerictextbox", "radtextbox"
                        sEditingType = "Textbox"
                    Case "label"
                        sEditingType = "Label"
                        bTextIsEditable = True
                    Case Else
                        sEditingType = "Control"
                End Select
            End If

            sOverride = sOverride.Replace("'", "~")
            sPlural = sPlural.Replace("'", "~")
            sDesc = sDesc.Replace("'", "~")
            Dim editString As String = String.Format("openAddItemWindow('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}');", e.Item.OwnerTableView.DataKeyValues(e.Item.ItemIndex)("FieldLabelID"), sItemName, sItemID, sOverride, sPlural, sDesc, sColour, sProcedureType, sRequired, sFieldName, sSuppressed, bTextIsEditable, sEditingType)
            EditLinkButton.Attributes("onclick") = editString
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
        '    header("LabelName").Controls.Add(chkBox)
        'End If

    End Sub

    Protected Sub ListsRadGrid_ItemDataBound(sender As Object, e As GridItemEventArgs) Handles ListsRadGrid.ItemDataBound
        If e.Item.ItemType = GridItemType.Item Or _
            e.Item.ItemType = GridItemType.AlternatingItem Then
            Dim TextColour As Label = DirectCast(e.Item.FindControl("ColourLabel"), Label)
            TextColour.BackColor = ColorTranslator.FromHtml((DataBinder.Eval(e.Item.DataItem, "Colour").ToString()))
            '    Dim SuppressLinkButton As LinkButton = DirectCast(e.Item.FindControl("SuppressLinkButton"), LinkButton)
            '    Dim row As DataRowView = DirectCast(DirectCast(e.Item, GridDataItem).DataItem, DataRowView)
            '    If CBool(row("Suppressed")) Then
            '        SuppressLinkButton.ForeColor = Color.Gray
            '        SuppressLinkButton.ToolTip = "Unsuppress this item"
            '        SuppressLinkButton.OnClientClick = ""
            '        SuppressLinkButton.Text = "Unsuppress"
            '        Dim dataItem As GridDataItem = e.Item
            '        dataItem.BackColor = ColorTranslator.FromHtml("#F0F0F0 ")
            '    End If
        End If
    End Sub

    Protected Sub ListsRadGrid_ItemCommand(sender As Object, e As GridCommandEventArgs) Handles ListsRadGrid.ItemCommand
        If e.CommandName = "SuppressItem" Then
            Dim bSuppress As Boolean = True
            If CType(e.CommandSource, LinkButton).Text.ToLower = "unsuppress" Then
                bSuppress = False
            End If
            DataAdapter.SuppressItemList(CInt(DirectCast(e.Item, GridDataItem).GetDataKeyValue("FieldLabelID")), bSuppress)
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

    Protected Sub AddNewItemSaveRadButton_Click(sender As Object, e As EventArgs) Handles AddNewItemSaveRadButton.Click
        Dim da As New Options

        If AddNewItemSaveRadButton.Text = "Update" Then
            Dim ProcedureType As String = ""
            For Each itm As RadComboBoxItem In ProcedureComboBox.CheckedItems
                ProcedureType = ProcedureType & IIf(ProcedureType = Nothing, itm.Value, "," & itm.Value)
            Next
            If ProcedureType = "" Then ProcedureType = "0"
            da.UpdateFieldLabels(CInt(hiddenItemId.Value), EditOverrideRadTextBox.Text, EditPluralTextBox.Text, EditHintTextBox.Text, System.Drawing.ColorTranslator.ToHtml(RadColourPicker.SelectedColor), ProcedureType, EditRequiredFieldCheckBox.Checked, EditFieldNameTextBox.Text)
            ListsRadGrid.Rebind()
            'ElseIf EditOverrideRadTextBox.Text <> "" Then
            '    newItemId = da.InsertListItem(FilterByComboBox.SelectedValue.ToString, EditOverrideRadTextBox.Text)
            '    EditOverrideRadTextBox.Text = ""
            '    ListsRadGrid.Rebind()
        End If
        Page.ClientScript.RegisterStartupScript(Me.GetType(), "clse", "closeAddItemWindow();", True)
    End Sub










    'Protected Sub RadGrid1_ItemUpdated(source As Object, e As GridUpdatedEventArgs) Handles RadGrid1.ItemUpdated
    '    Dim item As GridEditableItem = DirectCast(e.Item, GridEditableItem)
    '    Dim id As [String] = item.GetDataKeyValue("ProductID").ToString()
    '    If e.Exception IsNot Nothing Then
    '        e.KeepInEditMode = True
    '        e.ExceptionHandled = True
    '        NotifyUser("Product with ID " + id + " cannot be updated. Reason: " + e.Exception.Message)
    '    Else
    '        NotifyUser("Product with ID " + id + " is updated!")
    '    End If
    'End Sub

    'Protected Sub RadGrid1_ItemInserted(source As Object, e As GridInsertedEventArgs) Handles RadGrid1.ItemInserted
    '    If e.Exception IsNot Nothing Then
    '        e.ExceptionHandled = True
    '        NotifyUser("Product cannot be inserted. Reason: " + e.Exception.Message)
    '    Else
    '        NotifyUser("New product is inserted!")
    '    End If
    'End Sub

    'Protected Sub RadGrid1_ItemDeleted(source As Object, e As GridDeletedEventArgs) Handles RadGrid1.ItemDeleted
    '    Dim dataItem As GridDataItem = DirectCast(e.Item, GridDataItem)
    '    Dim id As [String] = dataItem.GetDataKeyValue("ProductID").ToString()
    '    If e.Exception IsNot Nothing Then
    '        e.ExceptionHandled = True
    '        NotifyUser("Product with ID " + id + " cannot be deleted. Reason: " + e.Exception.Message)
    '    Else
    '        NotifyUser("Product with ID " + id + " is deleted!")
    '    End If

    'End Sub

    'Protected Sub RadGrid1_PreRender(sender As Object, e As EventArgs) Handles RadGrid1.PreRender
    '    Dim unitsNumericTextBox As RadNumericTextBox = TryCast(RadGrid1.MasterTableView.GetBatchColumnEditor("UnitsInStock"), GridNumericColumnEditor).NumericTextBox
    '    unitsNumericTextBox.Width = Unit.Pixel(60)
    'End Sub

    'Private Sub NotifyUser(message As String)
    '    Dim commandListItem As New RadListBoxItem()
    '    commandListItem.Text = message
    '    'SavedChangesList.Items.Add(commandListItem)
    'End Sub
End Class
