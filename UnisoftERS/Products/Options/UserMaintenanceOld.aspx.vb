Imports Telerik.Web.UI

Partial Class Products_Options_UserMaintenanceOld
    Inherits OptionsBase

    Private newUserId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            UserDetailsFormView.DefaultMode = FormViewMode.Insert
            UserDetailsFormView.ChangeMode(FormViewMode.Insert)
        End If
        'Threading.Thread.Sleep(5000)
    End Sub

    Protected Sub UsersRadGrid_SelectedIndexChanged(sender As Object, e As EventArgs) Handles UsersRadGrid.SelectedIndexChanged
        UserDetailsObjectDataSource.SelectParameters("UserId").DefaultValue = UsersRadGrid.SelectedValue.ToString()
        UserDetailsFormView.ChangeMode(FormViewMode.Edit)
        UserDetailsFormView.DataBind()
    End Sub

    Protected Sub UserDetailsFormView_Init(sender As Object, e As EventArgs) Handles UserDetailsFormView.Init
        If Not IsPostBack Then
            UserDetailsFormView.InsertItemTemplate = UserDetailsFormView.EditItemTemplate
        End If
    End Sub

    Protected Sub UserDetailsFormView_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles UserDetailsFormView.ItemCommand
        If e.CommandName = "Cancel" Then
            UsersRadGrid.SelectedIndexes.Clear()
            UserDetailsFormView.DefaultMode = FormViewMode.Insert
            UserDetailsFormView.ChangeMode(FormViewMode.Insert)
        End If
    End Sub

    Protected Sub UserDetailsFormView_ItemCreated(sender As Object, e As EventArgs) Handles UserDetailsFormView.ItemCreated
        RefreshTitles()
    End Sub

    Protected Sub RefreshTitles()
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
        Dim da As New DataAccess
        Dim dtTitles As DataTable = da.GetJobTitles()
        TitleRadDropDownList.DataTextField = "Description"
        TitleRadDropDownList.DataValueField = "JobTitleId"
        TitleRadDropDownList.DataSource = dtTitles
        TitleRadDropDownList.DataBind()
    End Sub

    Protected Sub UserDetailsFormView_ItemInserting(sender As Object, e As FormViewInsertEventArgs) Handles UserDetailsFormView.ItemInserting
        Dim ActiveCheckBox As CheckBox = DirectCast(UserDetailsFormView.FindControl("ActiveCheckBox"), CheckBox)
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
        e.Values("active") = Not ActiveCheckBox.Checked
        e.Values("jobTitle") = TitleRadDropDownList.SelectedValue
    End Sub

    Protected Sub UserDetailsFormView_ItemInserted(sender As Object, e As FormViewInsertedEventArgs) Handles UserDetailsFormView.ItemInserted
        UserDetailsFormView.DefaultMode = FormViewMode.Edit
        UserDetailsFormView.ChangeMode(FormViewMode.Edit)
        UsersRadGrid.DataBind()

        If newUserId > 0 Then
            For Each item As GridDataItem In UsersRadGrid.MasterTableView.Items
                If item.GetDataKeyValue("UserId") = newUserId Then
                    item.Selected = True
                End If
            Next

            UserDetailsObjectDataSource.SelectParameters("UserId").DefaultValue = newUserId
            UserDetailsFormView.DataBind()
        End If
    End Sub

    Protected Sub UserDetailsFormView_ItemUpdating(sender As Object, e As FormViewUpdateEventArgs) Handles UserDetailsFormView.ItemUpdating
        Dim ActiveCheckBox As CheckBox = DirectCast(UserDetailsFormView.FindControl("ActiveCheckBox"), CheckBox)
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
        e.NewValues("active") = Not ActiveCheckBox.Checked
        e.NewValues("jobTitle") = TitleRadDropDownList.SelectedValue
    End Sub

    Protected Sub UserDetailsFormView_ItemUpdated(sender As Object, e As FormViewUpdatedEventArgs) Handles UserDetailsFormView.ItemUpdated
        If e.Exception Is Nothing Then
            UserDetailsFormView.DefaultMode = FormViewMode.Edit
            UserDetailsFormView.ChangeMode(FormViewMode.Edit)
            UsersRadGrid.DataBind()

            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()
        Else
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving user in the User Maintenance page.", e.Exception)

            e.ExceptionHandled = True
            e.KeepInEditMode = True

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End If
    End Sub

    Protected Sub UserDetailsFormView_PreRender(sender As Object, e As EventArgs) Handles UserDetailsFormView.PreRender
        Dim UpdateButton As RadButton

        If UserDetailsFormView.CurrentMode = FormViewMode.Edit Then
            UpdateButton = DirectCast(UserDetailsFormView.FindControl("UpdateButton"), RadButton)
            If UpdateButton IsNot Nothing Then UpdateButton.CommandName = "Update"

            Dim rowView As DataRowView = CType(UserDetailsFormView.DataItem, DataRowView)

            Dim ActiveCheckBox As CheckBox = DirectCast(UserDetailsFormView.FindControl("ActiveCheckBox"), CheckBox)
            If ActiveCheckBox IsNot Nothing AndAlso rowView IsNot Nothing Then
                ActiveCheckBox.Checked = Not CBool(rowView("Active"))
            End If

            Dim TitleRadDropDownList As RadDropDownList = DirectCast(UserDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
            If TitleRadDropDownList IsNot Nothing AndAlso rowView IsNot Nothing Then
                If Not IsDBNull(rowView("JobTitle")) Then
                    TitleRadDropDownList.SelectedValue = CStr(rowView("JobTitle"))
                End If
            End If

        ElseIf UserDetailsFormView.CurrentMode = FormViewMode.Insert Then
            UpdateButton = DirectCast(UserDetailsFormView.FindControl("UpdateButton"), RadButton)
            If UpdateButton IsNot Nothing Then UpdateButton.CommandName = "Insert"
        End If
    End Sub

    Protected Sub UserDetailsObjectDataSource_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles UserDetailsObjectDataSource.Inserted
        newUserId = CInt(e.ReturnValue)
    End Sub

    Protected Sub AddNewTitleSaveRadButton_Click(sender As Object, e As EventArgs) Handles AddNewTitleSaveRadButton.Click
        Dim da As New DataAccess
        If AddNewTitleRadTextBox.Text <> "" Then
            da.InsertJobTitle(AddNewTitleRadTextBox.Text)
            AddNewTitleRadTextBox.Text = ""
        End If

        RefreshTitles()

        Page.ClientScript.RegisterStartupScript(Me.GetType(), "clse", "closeAddTitleWindow();", True)
    End Sub

    'Protected Sub RadAjaxManager1_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs) Handles RadAjaxManager1.AjaxRequest
    '    If e.Argument = "InitialPageLoad" Then
    '        'simulate longer page load
    '        System.Threading.Thread.Sleep(2000)
    '        InnerPanel.Visible = True
    '    End If
    'End Sub
End Class
