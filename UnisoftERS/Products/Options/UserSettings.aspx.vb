Imports Constants
Imports Utilities
Imports Telerik.Web.UI

Partial Class Products_Options_UserSettings
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            'If Not Session("SkinName") Is Nothing AndAlso Session("SkinName").ToString <> "" Then
            '    Dim item As RadComboBoxItem = SkinComboBox.FindItemByText(Session("SkinName"))
            '    item.Selected = True
            'End If
        End If
        If ConfigurationManager.AppSettings("Unisoft.ActiveDirectoryLogin") = True Then
            changePasswordTable.Visible = False
            NoUserSettings.Visible = True
        Else
            NoUserSettings.Visible = False
            PopulatePasswordRules()
        End If
        'TryCast(ControlsSkinManager, RadSkinManager).GetSkinChooser().Width = Unit.Pixel(200)
    End Sub

    Protected Sub PopulatePasswordRules()
        Dim rules As New StringBuilder
        Dim dtPr As DataTable = OptionsDataAdapter.GetPasswordRules() ' OptionsDataAdapter.GetPasswordRules(CInt(Session("OperatingHospitalID")))

        If dtPr.Rows.Count > 0 Then
            ' rules.Append("<ul>")
            If Not IsDBNull(dtPr.Rows(0)("PwdRuleMinLength")) Then
                rules.Append(String.Format("<li>must have at least {0} character(s)</li>", CStr(dtPr.Rows(0)("PwdRuleMinLength"))))
            End If
            If Not IsDBNull(dtPr.Rows(0)("PwdRuleNoOfSpecialChars")) Then
                rules.Append(String.Format("<li>must have at least {0} non-alphanumeric character(s)</li>", CStr(dtPr.Rows(0)("PwdRuleNoOfSpecialChars"))))
            End If
            If Not IsDBNull(dtPr.Rows(0)("PwdRuleNoSpaces")) AndAlso CBool(dtPr.Rows(0)("PwdRuleNoSpaces")) Then
                rules.Append("<li>cannot contain spaces</li>")
            End If
            If Not IsDBNull(dtPr.Rows(0)("PwdRuleCantBeUserId")) AndAlso CBool(dtPr.Rows(0)("PwdRuleCantBeUserId")) Then
                rules.Append("<li>cannot be the same as your user id</li>")
            End If
            If Not IsDBNull(dtPr.Rows(0)("PwdRuleNoOfPastPwdsToAvoid")) Then
                rules.Append(String.Format("<li>cannot be the last {0} password(s) used</li>", CStr(dtPr.Rows(0)("PwdRuleNoOfPastPwdsToAvoid"))))
            End If
            'rules.Append("</ul>")
        End If

        If Not String.IsNullOrEmpty(rules.ToString()) Then
            PasswordRulesDiv.Visible = True
            PasswordRulesLabel.Text = "<ul>" & rules.ToString() & "</ul>"
        Else
            PasswordRulesDiv.Visible = False
        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            If NewPasswordTextBox.Text <> ConfirmPasswordTextBox.Text Then
                ShowError("Passwords do not match")
                Exit Sub
            End If

            If Not LogicAdapter.IsPasswordValid(OldPasswordTextBox.Text) Then
                ShowError("Password you gave as current password is incorrect")
                Exit Sub
            End If

            Dim pwdFormatValid As Boolean
            Dim pwdFormatErrors As List(Of String) = LogicAdapter.IsPasswordFormatValid(NewPasswordTextBox.Text, pwdFormatValid)
            If Not pwdFormatValid Then
                ShowError(pwdFormatErrors)
                Exit Sub
            End If

            DataAdapter.UpdateUserResetPassword(CInt(Session("PKUserId")), NewPasswordTextBox.Text, LogicAdapter.GetPasswordExpiryDate(), False)

            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving new Password.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Private Sub ShowError(ByVal errorMessage As String)
        ServerErrorLabel.Visible = True
        ServerErrorLabel.Text = String.Format("<ul><li>{0}</li></ul>", errorMessage)
        ValidationNotification.Show()
    End Sub

    Private Sub ShowError(ByVal errorMessages As List(Of String))
        Dim errMsg As New StringBuilder

        If errorMessages IsNot Nothing AndAlso errorMessages.Count > 0 Then
            errMsg.Append("<ul>")
            For Each errorMessage As String In errorMessages
                errMsg.Append(String.Format("<li>{0}</li>", errorMessage))
            Next
            errMsg.Append("</ul>")

            ServerErrorLabel.Visible = True
            ServerErrorLabel.Text = errMsg.ToString()
            ValidationNotification.Show()
        End If
    End Sub

    'Protected Sub DiagramThemeComboBox_SelectedIndexChanged1(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles DiagramThemeComboBox.SelectedIndexChanged
    '    DataAdapter.UpdateTheme(CInt(Session("PKUserId")), "Diagram", e.Text)
    'End Sub

    'Protected Sub SkinComboBox_SelectedIndexChanged(sender As Object, e As RadComboBoxSelectedIndexChangedEventArgs) Handles SkinComboBox.SelectedIndexChanged
    '    Dim sSkin As String = ""
    '    If e.Text = "Unisoft" Then
    '        sSkin = ""
    '    Else
    '        sSkin = e.Text
    '    End If
    '    DataAdapter.UpdateTheme(CInt(Session("PKUserId")), "Controls", sSkin)
    '    Session("SkinName") = sSkin
    '    PageAccessLevel()
    '    If sSkin = "" Then
    '        Response.Redirect(Request.RawUrl)
    '    End If
    'End Sub
End Class
