Imports Telerik.Web.UI


Partial Class Products_Options_PreMedEditDrugs
    Inherits OptionsBase

    Private newUserId As Integer
    Private editUserId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Not String.IsNullOrEmpty(Request.QueryString("UserID")) Then
                HeadingLabel.Text = "Edit User"
                'Me.Title = "Editing User"

                editUserId = CInt(Request.QueryString("UserID"))
                UserDetailsObjectDataSource.SelectParameters("UserId").DefaultValue = editUserId
                UserDetailsFormView.DefaultMode = FormViewMode.Edit
                'UserDetailsFormView.ChangeMode(FormViewMode.Edit)
                UserDetailsFormView.DataBind()
            Else
                HeadingLabel.Text = "Add new User"
                'Me.Title = "Adding User"

                UserDetailsFormView.DefaultMode = FormViewMode.Insert
                'UserDetailsFormView.ChangeMode(FormViewMode.Insert)
            End If
        End If
    End Sub

    Protected Sub UserDetailsFormView_Init(sender As Object, e As EventArgs) Handles UserDetailsFormView.Init
        If Not IsPostBack Then
            UserDetailsFormView.InsertItemTemplate = UserDetailsFormView.EditItemTemplate
        End If
    End Sub

    Protected Sub UserDetailsFormView_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles UserDetailsFormView.ItemCommand
        If e.CommandName = "InsertAndClose" Then
            UserDetailsFormView.InsertItem(True)
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Insert_CloseAndRebind", "CloseAndRebind('navigateToInserted');", True)
        ElseIf e.CommandName = "UpdateAndClose" Then
            UserDetailsFormView.UpdateItem(True)
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind();", True)
        End If
    End Sub

    Protected Sub UserDetailsFormView_ItemCreated(sender As Object, e As EventArgs) Handles UserDetailsFormView.ItemCreated
        RefreshTitles()
    End Sub

    Protected Sub RefreshTitles(Optional valueToSelect As Integer = 0)
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
        Dim da As New DataAccess
        Dim dtTitles As DataTable = da.GetJobTitles()
        TitleRadDropDownList.DataTextField = "Description"
        TitleRadDropDownList.DataValueField = "JobTitleID"
        TitleRadDropDownList.DataSource = dtTitles
        TitleRadDropDownList.DataBind()

        If valueToSelect > 0 Then
            TitleRadDropDownList.SelectedValue = valueToSelect
        End If
    End Sub

    Protected Sub UserDetailsFormView_ItemInserting(sender As Object, e As FormViewInsertEventArgs) Handles UserDetailsFormView.ItemInserting
        Dim UserNameTextBox As RadTextBox = DirectCast(UserDetailsFormView.FindControl("UserNameTextBox"), RadTextBox)
        If Not LogicAdapter.IsUserNameUnique(UserNameTextBox.Text, CInt(Session("OperatingHospitalId"))) Then
            ShowError("This user id has been assigned to another user. Please try a different one.")
            e.Cancel = True
        End If

        Dim ActiveCheckBox As CheckBox = DirectCast(UserDetailsFormView.FindControl("ActiveCheckBox"), CheckBox)
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
        e.Values("active") = Not ActiveCheckBox.Checked
        e.Values("JobTitleId") = TitleRadDropDownList.SelectedValue
    End Sub

    Protected Sub UserDetailsFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles UserDetailsFormView.ItemInserted
        'UserDetailsFormView.DefaultMode = FormViewMode.Edit
        'UserDetailsFormView.ChangeMode(FormViewMode.Edit)
        'UsersRadGrid.DataBind()

        'If newUserId > 0 Then
        '    For Each item As GridDataItem In UsersRadGrid.MasterTableView.Items
        '        If item.GetDataKeyValue("UserId") = newUserId Then
        '            item.Selected = True
        '        End If
        '    Next

        '    UserDetailsObjectDataSource.SelectParameters("UserId").DefaultValue = newUserId
        '    UserDetailsFormView.DataBind()
        'End If
        If e.Exception Is Nothing Then
            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
        Else
            Dim bex As Exception = e.Exception.GetBaseException()
            Dim errorLogRef As String = LogManager.LogManagerInstance.LogError("Error occured while adding new user in the User Maintenance page.", bex)

            e.ExceptionHandled = True
            e.KeepInInsertMode = True

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()

            'Clear Script
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Insert_CloseAndRebind", "", True)
        End If
    End Sub

    'Protected Sub UserDetailsFormView_ItemUpdating(sender As Object, e As FormViewUpdateEventArgs) Handles UserDetailsFormView.ItemUpdating
    '    Dim UserNameTextBox As RadTextBox = DirectCast(UserDetailsFormView.FindControl("UserNameTextBox"), RadTextBox)
    '    If Not LogicAdapter.IsUserNameUnique(UserNameTextBox.Text, CInt(e.Keys("UserId"))) Then
    '        ShowError("This user id has been assigned to another user. Please try a different one.")
    '        e.Cancel = True
    '    End If

    '    Dim ActiveCheckBox As CheckBox = DirectCast(UserDetailsFormView.FindControl("ActiveCheckBox"), CheckBox)
    '    Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
    '    e.NewValues("active") = Not ActiveCheckBox.Checked
    '    e.NewValues("JobTitleId") = TitleRadDropDownList.SelectedValue
    'End Sub

    Protected Sub UserDetailsFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles UserDetailsFormView.ItemUpdated
        If e.Exception Is Nothing Then
            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
        Else
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving user in the User Maintenance page.", e.Exception)

            e.ExceptionHandled = True
            e.KeepInEditMode = True

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()

            'Clear Script
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "", True)
        End If
    End Sub

    Protected Sub UserDetailsFormView_PreRender(sender As Object, e As EventArgs) Handles UserDetailsFormView.PreRender
        Dim SaveButton As RadButton
        Dim SaveAndCloseButton As RadButton

        If UserDetailsFormView.CurrentMode = FormViewMode.Edit Then
            SaveButton = DirectCast(UserDetailsFormView.FindControl("SaveButton"), RadButton)
            SaveAndCloseButton = DirectCast(UserDetailsFormView.FindControl("SaveAndCloseButton"), RadButton)

            If SaveButton IsNot Nothing Then SaveButton.CommandName = "Update"
            If SaveAndCloseButton IsNot Nothing Then SaveAndCloseButton.CommandName = "UpdateAndClose"

            Dim rowView As DataRowView = CType(UserDetailsFormView.DataItem, DataRowView)

            Dim ActiveCheckBox As CheckBox = DirectCast(UserDetailsFormView.FindControl("ActiveCheckBox"), CheckBox)
            If ActiveCheckBox IsNot Nothing AndAlso rowView IsNot Nothing Then
                ActiveCheckBox.Checked = Not CBool(rowView("Active"))
            End If

            Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
            If TitleRadDropDownList IsNot Nothing AndAlso rowView IsNot Nothing Then
                If Not IsDBNull(rowView("JobTitleID")) Then
                    TitleRadDropDownList.SelectedValue = CStr(rowView("JobTitleID"))
                End If
            End If

        ElseIf UserDetailsFormView.CurrentMode = FormViewMode.Insert Then
            SaveButton = DirectCast(UserDetailsFormView.FindControl("SaveButton"), RadButton)
            SaveAndCloseButton = DirectCast(UserDetailsFormView.FindControl("SaveAndCloseButton"), RadButton)

            If SaveButton IsNot Nothing Then SaveButton.CommandName = "Insert"
            If SaveButton IsNot Nothing Then SaveAndCloseButton.CommandName = "InsertAndClose"
        End If
    End Sub

    Protected Sub UserDetailsObjectDataSource_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles UserDetailsObjectDataSource.Inserted
        newUserId = CInt(e.ReturnValue)
    End Sub

    Protected Sub AddNewTitleSaveRadButton_Click(sender As Object, e As EventArgs) Handles AddNewTitleSaveRadButton.Click
        Dim da As New DataAccess
        Dim newTitleId As Integer
        If AddNewTitleRadTextBox.Text <> "" Then
            newTitleId = da.InsertJobTitle(AddNewTitleRadTextBox.Text)
            AddNewTitleRadTextBox.Text = ""
        End If

        RefreshTitles(newTitleId)

        Page.ClientScript.RegisterStartupScript(Me.GetType(), "clse", "closeAddTitleWindow();", True)
    End Sub

    'Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
    '    If e.Argument = "InitialPageLoad" Then
    '        'simulate longer page load
    '        System.Threading.Thread.Sleep(2000)
    '        InnerPanel.Visible = True
    '    End If
    'End Sub

    Private Sub ShowError(ByVal errorMessage As String)
        ServerErrorLabel.Visible = True
        ServerErrorLabel.Text = String.Format("<ul><li>{0}</li></ul>", errorMessage)
        ValidationNotification.Show()
    End Sub
End Class
