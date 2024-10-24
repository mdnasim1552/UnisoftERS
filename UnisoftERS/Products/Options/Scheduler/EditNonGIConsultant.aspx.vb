Imports Telerik.Web.UI

Public Class EditNonGIConsultant
    Inherits OptionsBase

    Private newUserId As Integer
    Private editUserId As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If Not String.IsNullOrEmpty(Request.QueryString("UserID")) Then
                HeadingLabel.Text = "Edit Consultant"
                'Me.Title = "Editing User"

                editUserId = CInt(Request.QueryString("UserID"))
                NonGIConsultantsDatasource.SelectParameters("UserId").DefaultValue = editUserId
                ConsultantDetailsFormView.DefaultMode = FormViewMode.Edit
                ConsultantDetailsFormView.DataBind()
            Else
                HeadingLabel.Text = "Add New Non-GI Consultant"

                ConsultantDetailsFormView.DefaultMode = FormViewMode.Insert
                ConsultantDetailsFormView.DataBind()
            End If
        End If
    End Sub

    Protected Sub ConsultantDetailsFormView_ItemCreated(sender As Object, e As EventArgs) Handles ConsultantDetailsFormView.ItemCreated
        RefreshTitles()
    End Sub

    Protected Sub ConsultantDetailsFormView_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles ConsultantDetailsFormView.ItemCommand
        Try

            Dim ForenameTextBox As RadTextBox = DirectCast(ConsultantDetailsFormView.FindControl("ForenameTextBox"), RadTextBox)
            Dim SurnameTextBox As RadTextBox = DirectCast(ConsultantDetailsFormView.FindControl("ForenameTextBox"), RadTextBox)
            Dim userId = CInt(Request.QueryString("UserID"))
            Dim GMCCodeTextBox As RadTextBox = DirectCast(ConsultantDetailsFormView.FindControl("GMCCodeTextBox"), RadTextBox)

            If DataAdapter.NonGIUserExists(ForenameTextBox.Text, SurnameTextBox.Text, GMCCodeTextBox.Text) Then
                Utilities.SetNotificationStyle(RadNotification1, "User already exists with the same name and GMC Code. Cannot add multiple", True)
                RadNotification1.Width = "400"
                RadNotification1.Show()
                Exit Sub
            End If

            ''GMC code
            If Not String.IsNullOrWhiteSpace(GMCCodeTextBox.Text) AndAlso DataAdapter.NonGIGMCCodeExists(GMCCodeTextBox.Text, userId) Then
                Utilities.SetNotificationStyle(RadNotification1, "GMCCode is in use. Please choose another and try again.", True)
                RadNotification1.Width = "400"
                RadNotification1.Show()
                Exit Sub
            End If


            If e.CommandName = "InsertAndClose" Then
                ConsultantDetailsFormView.InsertItem(True)
                ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Insert_CloseAndRebind", "CloseAndRebind('navigateToInserted');", True)
            ElseIf e.CommandName = "UpdateAndClose" Then
                ConsultantDetailsFormView.UpdateItem(True)
                ScriptManager.RegisterStartupScript(Me.Page, Me.GetType(), "Update_CloseAndRebind", "CloseAndRebind();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String = LogManager.LogManagerInstance.LogError("Error occured while saving user details.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
    Protected Sub NonGIConsultantsDatasource_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles NonGIConsultantsDatasource.Inserted
        Dim newUserId = CInt(e.ReturnValue)

        Dim operatingHospitalID = CInt(Session("OperatingHospitalID"))
        DataAdapter.UpdateUsersOperatingHospitals(newUserId, operatingHospitalID)
    End Sub
    Protected Sub ConsultantDetailsFormView_PreRender(sender As Object, e As EventArgs) Handles ConsultantDetailsFormView.PreRender
        Dim SaveButton As RadButton
        Dim SaveAndCloseButton As RadButton

        If ConsultantDetailsFormView.CurrentMode = FormViewMode.Edit Then
            SaveButton = DirectCast(ConsultantDetailsFormView.FindControl("SaveButton"), RadButton)
            SaveAndCloseButton = DirectCast(ConsultantDetailsFormView.FindControl("SaveAndCloseButton"), RadButton)

            If SaveButton IsNot Nothing Then SaveButton.CommandName = "Update"
            If SaveAndCloseButton IsNot Nothing Then SaveAndCloseButton.CommandName = "UpdateAndClose"

            Dim rowView As DataRowView = CType(ConsultantDetailsFormView.DataItem, DataRowView)

            Dim TitleRadDropDownList As RadDropDownList = DirectCast(ConsultantDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
            If TitleRadDropDownList IsNot Nothing AndAlso rowView IsNot Nothing Then
                If Not IsDBNull(rowView("JobTitleID")) Then
                    TitleRadDropDownList.SelectedValue = CStr(rowView("JobTitleID"))
                End If
            End If

        ElseIf ConsultantDetailsFormView.CurrentMode = FormViewMode.Insert Then
            SaveButton = DirectCast(ConsultantDetailsFormView.FindControl("SaveButton"), RadButton)
            SaveAndCloseButton = DirectCast(ConsultantDetailsFormView.FindControl("SaveAndCloseButton"), RadButton)

            If SaveButton IsNot Nothing Then SaveButton.CommandName = "Insert"
            If SaveButton IsNot Nothing Then SaveAndCloseButton.CommandName = "InsertAndClose"
        End If
    End Sub

    Protected Sub RefreshTitles(Optional valueToSelect As Integer = 0)
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(ConsultantDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
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

    Protected Sub ConsultantDetailsFormView_ItemInserting(sender As Object, e As FormViewInsertEventArgs)
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(ConsultantDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
        Dim ForenameTextBox As RadTextBox = DirectCast(ConsultantDetailsFormView.FindControl("ForenameTextBox"), RadTextBox)
        Dim SurnameTextBox As RadTextBox = DirectCast(ConsultantDetailsFormView.FindControl("SurnameTextBox"), RadTextBox)

        e.Values("JobTitleId") = TitleRadDropDownList.SelectedValue
        e.Values("Username") = ForenameTextBox.Text.Substring(0, 1) & SurnameTextBox.Text
        e.Values("Initials") = ForenameTextBox.Text.Substring(0, 1)
    End Sub

    Protected Sub ConsultantDetailsFormView_ItemUpdating(sender As Object, e As FormViewUpdateEventArgs)
        Dim TitleRadDropDownList As RadDropDownList = DirectCast(ConsultantDetailsFormView.FindControl("TitleRadDropDownList"), RadDropDownList)
        Dim ForenameTextBox As RadTextBox = DirectCast(ConsultantDetailsFormView.FindControl("ForenameTextBox"), RadTextBox)
        Dim SurnameTextBox As RadTextBox = DirectCast(ConsultantDetailsFormView.FindControl("SurnameTextBox"), RadTextBox)

        e.NewValues("JobTitleId") = TitleRadDropDownList.SelectedValue
        e.NewValues("Username") = ForenameTextBox.Text.Substring(0, 1) & SurnameTextBox.Text
        e.NewValues("Initials") = ForenameTextBox.Text.Substring(0, 1)
    End Sub
End Class