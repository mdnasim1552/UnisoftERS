Imports Telerik.Web.UI

Partial Class Products_Options_EditDrugs
    Inherits OptionsBase

    Private newDrugId As Integer
    Private EditDrugsId As Integer
    Shared DrugType As Int32

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            DrugType = CInt(Request.QueryString("DrugType"))

            If Not String.IsNullOrEmpty(Request.QueryString("DrugID")) Then
                EditDrugsId = CInt(Request.QueryString("DrugID"))
                If DrugType = 1 Then
                    HeadingLabel.Text = "Modify Medication Drug"
                Else
                    HeadingLabel.Text = "Modify Premedication Drug"
                End If


                DrugDetailsObjectDataSource.SelectParameters("DrugID").DefaultValue = EditDrugsId
                DrugDetailsFormView.DefaultMode = FormViewMode.Edit
                DrugDetailsFormView.DataBind()
            Else
                If DrugType = 1 Then
                    HeadingLabel.Text = "Add Medication Drug"
                Else
                    HeadingLabel.Text = "Add Drug"
                End If
                DrugDetailsFormView.DefaultMode = FormViewMode.Insert

            End If
        End If
    End Sub

    Protected Sub DrugDetailsFormView_Init(sender As Object, e As EventArgs) Handles DrugDetailsFormView.Init
        If Not IsPostBack Then
            DrugDetailsFormView.InsertItemTemplate = DrugDetailsFormView.EditItemTemplate
        End If
    End Sub

    Protected Sub DrugDetailsFormView_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles DrugDetailsFormView.ItemCommand
        Try

            If e.CommandName = "InsertAndClose" Then
                DrugDetailsFormView.InsertItem(True)
                ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Insert_CloseAndRebind", "CloseAndRebind('navigateToInserted');", True)
            ElseIf e.CommandName = "UpdateAndClose" Then
                DrugDetailsFormView.UpdateItem(True)
                ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind();", True)
            End If

        Catch ex As Exception

        End Try
    End Sub

    Protected Sub DrugDetailsFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles DrugDetailsFormView.ItemInserted
        If e.Exception Is Nothing Then
            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
        Else
            Dim bex As Exception = e.Exception.GetBaseException()
            Dim errorLogRef As String = LogManager.LogManagerInstance.LogError("Error occured while adding new premdication drug.", bex)

            e.ExceptionHandled = True
            e.KeepInInsertMode = True

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()

            'Clear Script
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Insert_CloseAndRebind", "", True)
        End If
    End Sub

    Protected Sub DrugDetailsFormView_ItemInserting(sender As Object, e As FormViewInsertEventArgs) Handles DrugDetailsFormView.ItemInserting
        Dim val As Int32 = DrugType
        DrugDetailsObjectDataSource.InsertParameters("DrugType").DefaultValue = val
    End Sub

    Protected Sub DrugDetailsFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles DrugDetailsFormView.ItemUpdated
        If e.Exception Is Nothing Then
            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
        Else
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving premedication drug.", e.Exception)

            e.ExceptionHandled = True
            e.KeepInEditMode = True

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()

            'Clear Script
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "", True)
        End If
    End Sub

    Protected Sub DrugDetailsFormView_PreRender(sender As Object, e As EventArgs) Handles DrugDetailsFormView.PreRender
        ' Dim SaveButton As RadButton
        Dim SaveAndCloseButton As RadButton

        If DrugDetailsFormView.CurrentMode = FormViewMode.Edit Then
            'SaveButton = DirectCast(DrugDetailsFormView.FindControl("SaveButton"), RadButton)
            SaveAndCloseButton = DirectCast(DrugDetailsFormView.FindControl("SaveAndCloseButton"), RadButton)

            ' If SaveButton IsNot Nothing Then SaveButton.CommandName = "Update"
            If SaveAndCloseButton IsNot Nothing Then SaveAndCloseButton.CommandName = "UpdateAndClose"

            Dim rowView As DataRowView = CType(DrugDetailsFormView.DataItem, DataRowView)

        ElseIf DrugDetailsFormView.CurrentMode = FormViewMode.Insert Then
            'SaveButton = DirectCast(DrugDetailsFormView.FindControl("SaveButton"), RadButton)
            SaveAndCloseButton = DirectCast(DrugDetailsFormView.FindControl("SaveAndCloseButton"), RadButton)

            'If SaveButton IsNot Nothing Then SaveButton.CommandName = "Insert"
            If SaveAndCloseButton IsNot Nothing Then SaveAndCloseButton.CommandName = "InsertAndClose"
        End If
    End Sub

    Protected Sub DrugDetailsObjectDataSource_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DrugDetailsObjectDataSource.Inserted
        newDrugId = CInt(e.ReturnValue)
    End Sub

    Private Sub DrugDetailsFormView_DataBound(sender As Object, e As EventArgs) Handles DrugDetailsFormView.DataBound
        Dim DeliveryDropDownList As RadComboBox = DirectCast(DrugDetailsFormView.FindControl("DeliveryDropDownList"), RadComboBox)
        Dim UnitsDropDown As RadComboBox = DirectCast(DrugDetailsFormView.FindControl("UnitsDropDown"), RadComboBox)

        Dim dataRow As DataRowView = DirectCast(DrugDetailsFormView.DataItem, DataRowView)
        If DeliveryDropDownList IsNot Nothing Then

            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {{DeliveryDropDownList, ""}}, DataAdapter.GetDeliveryMethods(), "ListItemText", "ListItemText")
            'Utilities.LoadDropdown(DeliveryDropDownList, DataAdapter.GetDeliveryMethods(), "ListItemText", "ListItemText", "")

            If dataRow IsNot Nothing AndAlso Not dataRow.Row.IsNull("Deliverymethod") Then
                Dim deliveryMethod = CStr(dataRow("Deliverymethod"))
                DeliveryDropDownList.SelectedValue = deliveryMethod
            End If
        End If

        If UnitsDropDown IsNot Nothing Then
            If dataRow IsNot Nothing AndAlso dataRow("Deliverymethod") IsNot Nothing Then
                If Not IsDBNull(dataRow("Units")) Then
                    Dim Units = CStr(dataRow("Units"))
                    UnitsDropDown.SelectedValue = Units
                End If
            End If
        End If
    End Sub

    Private Sub DrugDetailsObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles DrugDetailsObjectDataSource.Updating
        Dim DeliveryDropDownList As RadComboBox = DirectCast(DrugDetailsFormView.FindControl("DeliveryDropDownList"), RadComboBox)
        Dim UnitsDropDown As RadComboBox = DirectCast(DrugDetailsFormView.FindControl("UnitsDropDown"), RadComboBox)
        If DeliveryDropDownList IsNot Nothing Then
            Dim itemName As String = DeliveryDropDownList.SelectedItem.Text

            If DeliveryDropDownList.SelectedValue = "-99" Then  'new item
                Dim da As New DataAccess
                Dim iSelValue As Integer = da.InsertListItem("Premedication Delivery Method", itemName)
            End If

            e.InputParameters("Deliverymethod") = itemName
        End If
        If UnitsDropDown IsNot Nothing Then
            e.InputParameters("Units") = UnitsDropDown.SelectedItem.Text
        End If
    End Sub

    Private Sub DrugDetailsObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles DrugDetailsObjectDataSource.Inserting
        Dim DeliveryDropDownList As RadComboBox = DirectCast(DrugDetailsFormView.FindControl("DeliveryDropDownList"), RadComboBox)
        Dim UnitsDropDown As RadComboBox = DirectCast(DrugDetailsFormView.FindControl("UnitsDropDown"), RadComboBox)
        If DeliveryDropDownList IsNot Nothing Then
            Dim itemName As String = DeliveryDropDownList.SelectedItem.Text

            If DeliveryDropDownList.SelectedValue = "-99" Then  'new item
                Dim da As New DataAccess
                Dim iSelValue As Integer = da.InsertListItem("Premedication Delivery Method", itemName)
            End If

            e.InputParameters("Deliverymethod") = itemName
        End If
        If UnitsDropDown IsNot Nothing Then
            e.InputParameters("Units") = UnitsDropDown.SelectedItem.Text
        End If
    End Sub

    'Protected Sub AddNewTitleSaveRadButton_Click(sender As Object, e As EventArgs) Handles AddNewTitleSaveRadButton.Click
    '    Dim da As New DataAccess
    '    Dim newTitleId As Integer
    '    If AddNewTitleRadTextBox.Text <> "" Then
    '        newTitleId = da.InsertJobTitle(AddNewTitleRadTextBox.Text)
    '        AddNewTitleRadTextBox.Text = ""
    '    End If
    '    Page.ClientScript.RegisterStartupScript(Me.GetType(), "clse", "closeAddTitleWindow();", True)
    'End Sub

    Protected Sub DropDown_DataBound(sender As Object, e As EventArgs)
        Dim sdr As RadComboBox = DirectCast(sender, RadComboBox)
        Dim itm As New RadComboBoxItem
        itm.Text = ""
        itm.Value = ""
        sdr.Items.Insert(0, itm)
    End Sub

End Class
