Imports Telerik.Web.UI

Partial Class Products_Options_RequiredFieldsSetup
    Inherits OptionsBase

    'Protected Sub Products_Options_RequiredFieldsSetup_Error(sender As Object, e As EventArgs) Handles Me.Error
    '    Server.ClearError()
    '    ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "CloseLoadingPanel", "alert(1); window.parent.HideLoadingPanel();", True)
    'End Sub

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then

        End If
    End Sub

    Protected Sub RequiredCheckBox_CheckedChanged(sender As Object, e As EventArgs)
        Dim chkbox As CheckBox = DirectCast(sender, CheckBox)
        Dim row As GridDataItem = DirectCast(chkbox.NamingContainer, GridDataItem)
        Dim reqFldId As Integer = CInt(row.GetDataKeyValue("RequiredFieldId"))

        OptionsDataAdapter.UpdateRequiredFields(reqFldId, chkbox.Checked)
    End Sub

    Protected Sub ReqFieldsObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles ReqFieldsObjectDataSource.Selected
        'Utilities.LoadDropdown(ProcedureComboBox, DirectCast(e.ReturnValue, DataTable), "ProcedureTypeText", "ProcedureType", "")
        ViewState("DataTable") = e.ReturnValue
    End Sub

    Protected Sub RequiredFieldsGrid_ItemCreated(sender As Object, e As GridItemEventArgs) Handles RequiredFieldsGrid.ItemCreated
        If e.Item.ItemType = GridItemType.FilteringItem Then
            If ViewState("DataTable") IsNot Nothing Then
                Dim row As GridFilteringItem = DirectCast(e.Item, GridFilteringItem)
                Dim ProcedureTypeComboBox As RadComboBox = DirectCast(row.FindControl("ProcedureTypeComboBox"), RadComboBox)
                If ProcedureTypeComboBox IsNot Nothing Then
                    'Dim da As New DataAccess
                    'Utilities.LoadDropdown(ProcedureTypeComboBox, da.GetProcedureTypes(), "List item text", "List item no", "All")
                    Dim dt As DataTable = DirectCast(ViewState("DataTable"), DataTable)
                    Dim distinctDT As DataTable = dt.DefaultView.ToTable(True, "ProcedureType")
                    Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{ProcedureTypeComboBox, ""}}, distinctDT, "ProcedureType", "ProcedureType", False)
                    ProcedureTypeComboBox.Items.Insert(0, "All")
                    'Utilities.LoadDropdown(ProcedureTypeComboBox, distinctDT, "ProcedureType", "ProcedureType", "All", False)
                End If

                Dim PageNameComboBox As RadComboBox = DirectCast(row.FindControl("PageNameComboBox"), RadComboBox)
                If PageNameComboBox IsNot Nothing Then
                    Dim dt As DataTable = DirectCast(ViewState("DataTable"), DataTable)
                    Dim distinctDT As DataTable = dt.DefaultView.ToTable(True, "PageName")
                    Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{PageNameComboBox, ""}}, distinctDT, "PageName", "PageName", False)
                    PageNameComboBox.Items.Insert(0, "All")
                    'Utilities.LoadDropdown(PageNameComboBox, distinctDT, "PageName", "PageName", "All", False)
                End If
            End If
            ViewState("DataTable") = Nothing

            'ElseIf e.Item.ItemType = GridItemType.AlternatingItem Or e.Item.ItemType = GridItemType.Item Then
            '    Dim item As GridDataItem
            '    item = e.Item
            '    Dim RequiredCheckBox As CheckBox
            '    RequiredCheckBox = item("RequiredColumn").FindControl("RequiredCheckBox")
            '    'RequiredCheckBox.Enabled = False
        End If
    End Sub

    Protected Sub ProcedureTypeComboBox_SelectedIndexChanged(o As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Dim ProcedureTypeComboBox As RadComboBox = TryCast(o, RadComboBox)

        'save the combo selected value  
        ViewState("ProcedureTypeComboBoxValue") = ProcedureTypeComboBox.SelectedValue

        ''filter the grid  
        'RadGrid1.MasterTableView.FilterExpression = "ProcedureType LIKE '%" + ProcedureTypeComboBox.SelectedValue & "%'"
        'RadGrid1.Rebind()
    End Sub

    Protected Sub ProcedureTypeComboBox_PreRender(sender As Object, e As EventArgs)
        'persist the combo selected value  
        If ViewState("ProcedureTypeComboBoxValue") IsNot Nothing Then
            Dim ProcedureTypeComboBox As RadComboBox = TryCast(sender, RadComboBox)
            ProcedureTypeComboBox.SelectedValue = ViewState("ProcedureTypeComboBoxValue").ToString()
        End If
    End Sub

    Protected Sub PageNameComboBox_SelectedIndexChanged(o As Object, e As RadComboBoxSelectedIndexChangedEventArgs)
        Dim PageNameComboBox As RadComboBox = TryCast(o, RadComboBox)

        'save the combo selected value  
        ViewState("PageNameComboBoxValue") = PageNameComboBox.SelectedValue

        ''filter the grid  
        'RadGrid1.MasterTableView.FilterExpression = "ProcedureType LIKE '%" + PageNameComboBox.SelectedValue & "%'"
        'RadGrid1.Rebind()
    End Sub

    Protected Sub PageNameComboBox_PreRender(sender As Object, e As EventArgs)
        'Persist the combo selected value  
        If ViewState("PageNameComboBoxValue") IsNot Nothing Then
            Dim PageNameComboBox As RadComboBox = TryCast(sender, RadComboBox)
            PageNameComboBox.SelectedValue = ViewState("PageNameComboBoxValue").ToString()
        End If
    End Sub
End Class
