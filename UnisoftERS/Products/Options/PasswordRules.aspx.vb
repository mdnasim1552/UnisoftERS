Imports Constants
Imports Utilities
Imports Telerik.Web.UI

Partial Class Products_Options_PasswordRules
    Inherits OptionsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Dim dtPr As DataTable = OptionsDataAdapter.GetPasswordRules() 'OptionsDataAdapter.GetPasswordRules(CInt(Session("OperatingHospitalID")))
            If dtPr.Rows.Count > 0 Then
                PopulateData(dtPr.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drPr As DataRow)
        If Not IsDBNull(drPr("PwdRuleMinLength")) Then
            MinLengthCheckBox.Checked = True
            MinLengthNumericTextBox.Value = CInt(drPr("PwdRuleMinLength"))
        End If

        If Not IsDBNull(drPr("PwdRuleNoOfSpecialChars")) Then
            NonAlphaCharsCheckBox.Checked = True
            NonAlphaCharsNumericTextBox.Value = CInt(drPr("PwdRuleNoOfSpecialChars"))
        End If

        If Not IsDBNull(drPr("PwdRuleNoSpaces")) Then NoSpacesCheckBox.Checked = CBool(drPr("PwdRuleNoSpaces"))
        If Not IsDBNull(drPr("PwdRuleCantBeUserId")) Then CantBeUserIdCheckBox.Checked = CBool(drPr("PwdRuleCantBeUserId"))

        If Not IsDBNull(drPr("PwdRuleDaysToExpiration")) Then
            ChangeFrequencyCheckBox.Checked = True
            ChangeFrequencyNumericTextBox.Value = CInt(drPr("PwdRuleDaysToExpiration"))
        End If

        If Not IsDBNull(drPr("PwdRuleNoOfPastPwdsToAvoid")) Then
            DifferentToLastPwdsCheckBox.Checked = True
            DifferentToLastPwdsNumericTextBox.Value = CInt(drPr("PwdRuleNoOfPastPwdsToAvoid"))
        End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            OptionsDataAdapter.UpdatePasswordRules(MinLengthNumericTextBox.Value, _
                                                   NonAlphaCharsNumericTextBox.Value, _
                                                   NoSpacesCheckBox.Checked, _
                                                   CantBeUserIdCheckBox.Checked, _
                                                   ChangeFrequencyNumericTextBox.Value, _
                                                   DifferentToLastPwdsNumericTextBox.Value)
            Utilities.SetNotificationStyle(RadNotification1)
            RadNotification1.Show()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Password Rules under Options - Admin Utilities.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        Response.Redirect(Request.Url.AbsoluteUri, False)
    End Sub
End Class
