Imports DevExpress.Xpo
Imports Telerik.Web.UI

Partial Class Products_Options_EditUser
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


                'edited by mostafizur issue 3575
                Dim loggedUser As String = HttpContext.Current.Session("UserId").ToString()
                Dim isAdmin As Boolean = True 'DataAdapter.IsUserSystemAdministratorOrGlobalAdmin(loggedUser)

                'edited by mostafizur issue 3575


                Dim sRole As String() = Request.QueryString("RoleID").Split(",")
                Dim RolesComboBox As RadComboBox = DirectCast(UserDetailsFormView.FindControl("PermissionsDropDownList"), RadComboBox)

                RolesComboBox.Enabled = isAdmin 'edited by mostafizur issue 3575
                For Each s In sRole
                    Try
                        If RolesComboBox.FindItemByValue(s) IsNot Nothing Then
                            RolesComboBox.SelectedValue = RolesComboBox.FindItemByValue(s).Value
                            RolesComboBox.SelectedItem.Checked = True
                        End If
                    Catch ex As Exception
                    End Try
                Next

                Dim OperatingHospitalsComboBox As RadComboBox = DirectCast(UserDetailsFormView.FindControl("OperatingHospitalsRadComboBox"), RadComboBox)
                Dim OHDT = DataAdapter.GetUserOperatingHospitals(editUserId)
                For Each oh In OHDT.Rows
                    Try
                        OperatingHospitalsComboBox.SelectedValue = OperatingHospitalsComboBox.FindItemByValue(oh("OperatingHospitalId")).Value
                        OperatingHospitalsComboBox.SelectedItem.Checked = True
                    Catch ex As Exception
                    End Try
                Next
                Dim UserNameTextBox As RadTextBox = DirectCast(UserDetailsFormView.FindControl("UserNameTextBox"), RadTextBox)

                If UserNameTextBox IsNot Nothing Then
                    UserNameTextBox.Enabled = False
                End If
            Else
                HeadingLabel.Text = "Add new User"
                'Me.Title = "Adding User"

                UserDetailsFormView.DefaultMode = FormViewMode.Insert
                UserDetailsFormView.DataBind()
                If ConfigurationManager.AppSettings("Unisoft.ActiveDirectoryLogin") = False Then
                    Dim tdMsgPassword As HtmlTableCell = DirectCast(UserDetailsFormView.FindControl("tdMsgPassword"), HtmlTableCell)
                    If tdMsgPassword IsNot Nothing Then tdMsgPassword.Visible = True
                End If
                'UserDetailsFormView.ChangeMode(FormViewMode.Insert)
            End If
            'Dim PermissionsDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("PermissionsDropDownList"), RadDropDownList)
            'PermissionsDropDownList.DataSource = DataAdapter.GetDistinctList()
            'PermissionsDropDownList.DataTextField = "RoleName"
            'PermissionsDropDownList.DataValueField = "RoleID"
            'PermissionsDropDownList.DataBind()
        End If
        If ConfigurationManager.AppSettings("Unisoft.ActiveDirectoryLogin") = True Then
            Dim btnResetPassword As RadButton = DirectCast(UserDetailsFormView.FindControl("ResetPasswordButton"), RadButton)
            btnResetPassword.Visible = False
        End If
    End Sub

    Protected Sub UserDetailsFormView_Init(sender As Object, e As EventArgs) Handles UserDetailsFormView.Init
        If Not IsPostBack Then
            UserDetailsFormView.InsertItemTemplate = UserDetailsFormView.EditItemTemplate
        End If
    End Sub

    Protected Sub UserDetailsFormView_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles UserDetailsFormView.ItemCommand
        Try
            Dim UserNameTextBox As RadTextBox = DirectCast(UserDetailsFormView.FindControl("UserNameTextBox"), RadTextBox)
            Dim userId As Integer = Request.QueryString("UserID")
            Dim GMCCodeTextBox As RadTextBox = DirectCast(UserDetailsFormView.FindControl("GMCCodeTextBox"), RadTextBox)

            Dim operatingHospitalIds As String = GetSelectedOperatingHospitals()
            Dim existingUserId As Integer = DataAdapter.UserNameExists(UserNameTextBox.Text)

            If String.IsNullOrWhiteSpace(operatingHospitalIds) Then
                Utilities.SetNotificationStyle(RadNotification1, "You must select at least 1 operating hospital.", True)
                RadNotification1.Width = "400"
                RadNotification1.Show()
                Exit Sub
            End If

            Dim validateGMC As Boolean
            If Boolean.TryParse(ConfigurationManager.AppSettings("ValidateGMCCode"), validateGMC) Then
                If validateGMC Then
                    'GMC code
                    If Not String.IsNullOrWhiteSpace(GMCCodeTextBox.Text) AndAlso DataAdapter.GMCCodeExists(GMCCodeTextBox.Text, userId) Then
                        Utilities.SetNotificationStyle(RadNotification1, "GMCCode is in use. Please choose another and try again.", True)
                        RadNotification1.Width = "400"
                        RadNotification1.Show()
                        Exit Sub
                    End If

                    If Not String.IsNullOrWhiteSpace(GMCCodeTextBox.Text) AndAlso Not NedClass.ValidateGMCCode(GMCCodeTextBox.Text) Then
                        Utilities.SetNotificationStyle(RadNotification1, "Unregistered GMC code. Please provide valid code and try again.", True)
                        RadNotification1.Width = "400"
                        RadNotification1.Show()
                        Exit Sub
                    End If
                End If
            End If


            If e.CommandName = "InsertAndClose" Then
                        If existingUserId > 0 Then
                            Utilities.SetNotificationStyle(RadNotification1, "Username already exists for one operating hospital. Please choose another and try again.", True)
                            RadNotification1.Width = "400"
                            RadNotification1.Show()
                            Exit Sub
                        End If

                        UserDetailsFormView.InsertItem(True)
                        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Insert_CloseAndRebind", "CloseAndRebind('navigateToInserted');", True)
                    ElseIf e.CommandName = "UpdateAndClose" Then
                        If existingUserId > 0 And existingUserId <> userId Then
                            Utilities.SetNotificationStyle(RadNotification1, "Username already exists for one operating hospital. Please choose another and try again.", True)
                            RadNotification1.Width = "400"
                            RadNotification1.Show()
                            Exit Sub
                        End If

                        UserDetailsFormView.UpdateItem(True)
                        ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind();", True)
                        DataAdapter.UpdateUsersOperatingHospitals(userId, operatingHospitalIds)
                    End If
                    If (Session("PKUserId") = userId) Then
                        Dim canUserEditDropDowns As CheckBox = DirectCast(UserDetailsFormView.FindControl("CanEditDropdownsCheckBox"), CheckBox)
                'Session("CanEditDropdowns") = canUserEditDropDowns.Checked
                Dim CanOverrideSchedule As CheckBox = DirectCast(UserDetailsFormView.FindControl("CanOverrideSchedule"), CheckBox)
                Session("CanOverrideSchedule") = CanOverrideSchedule.Checked
            End If
        Catch ex As Exception
            Dim errorLogRef As String = LogManager.LogManagerInstance.LogError("Error occured while saving user details.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
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
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)

        e.Values("JobTitleId") = TitleRadDropDownList.SelectedValue
        e.Values("RoleID") = GetSelectedRoles()
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

    Protected Sub UserDetailsFormView_ItemUpdating(sender As Object, e As FormViewUpdateEventArgs) Handles UserDetailsFormView.ItemUpdating
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
        Dim OperatingHospitalsRadComboBox As RadComboBox = DirectCast(UserDetailsFormView.FindControl("OperatingHospitalsRadComboBox"), RadComboBox)

        e.NewValues("JobTitleId") = TitleRadDropDownList.SelectedValue
        e.NewValues("RoleID") = GetSelectedRoles()
    End Sub

    Function GetSelectedRoles() As String
        Dim RolesComboBox As RadComboBox = DirectCast(UserDetailsFormView.FindControl("PermissionsDropDownList"), RadComboBox)
        Dim sRole As String = ""
        For Each itm As RadComboBoxItem In RolesComboBox.CheckedItems
            sRole = sRole & IIf(sRole = Nothing, itm.Value, "," & itm.Value)
        Next
        Return sRole
    End Function

    Function GetSelectedOperatingHospitals() As String
        Dim OperatingHospitalsComboBox As RadComboBox = DirectCast(UserDetailsFormView.FindControl("OperatingHospitalsRadComboBox"), RadComboBox)
        Dim sOperatingHospital As String = ""
        For Each itm As RadComboBoxItem In OperatingHospitalsComboBox.CheckedItems
            sOperatingHospital = sOperatingHospital & IIf(sOperatingHospital = Nothing, itm.Value, "," & itm.Value)
        Next
        Return sOperatingHospital
    End Function

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

        Dim operatingHospitalIds = GetSelectedOperatingHospitals()
        DataAdapter.UpdateUsersOperatingHospitals(newUserId, operatingHospitalIds)

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

    Private Sub ShowMessage(ByVal errorMessage As String)
        ServerErrorLabel.Visible = True
        ServerErrorLabel.Text = String.Format("<ul><li>{0}</li></ul>", errorMessage)
        ValidationNotification.Show()
    End Sub

    Protected Sub UserDetailsObjectDataSource_Inserted1(sender As Object, e As ObjectDataSourceStatusEventArgs)
        Dim userId = e.ReturnValue
        Dim operatingHospitalIds = GetSelectedOperatingHospitals()
        DataAdapter.UpdateUsersOperatingHospitals(userId, operatingHospitalIds)
    End Sub

    Protected Sub ResetPasswordButton_Click(sender As Object, e As EventArgs)
        Try
            Dim UserNameTextBox As RadTextBox = DirectCast(UserDetailsFormView.FindControl("UserNameTextBox"), RadTextBox)
            Dim da As New DataAccess
            da.ResetUserPassword(CInt(Request.QueryString("UserID")), UserNameTextBox.Text.ToLower(), True)
            Dim sMess As String = "alert('Password reset successfully for " & UserNameTextBox.Text & ". \nNew password is : " & UserNameTextBox.Text.ToLower & "');"
            ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "ResetPasswordSuccess", sMess, True)
        Catch ex As Exception
            ShowMessage("Error when resetting password. Please contact your administrator.")
        End Try


        ' ShowInfo("Password changed successfully. Please login with your new password.")
    End Sub
End Class
