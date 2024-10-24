Imports Telerik.Web.UI
Imports System.Net.Mail

Partial Class Security_Feedback
    Inherits PageBase
    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            Dim attach As Attachment = Nothing
            Dim sMessage As String = ""
            If AttachemnetAsyncUpload.UploadedFiles.Count > 0 Then
                Dim file As UploadedFile = AttachemnetAsyncUpload.UploadedFiles(0)
                attach = New Attachment(file.InputStream, file.FileName)
            End If
            DataAdapter.InsertFeedback(NameTextBox.Text, EmailAddressTextBox.Text, HttpUtility.HtmlEncode(FeedbackTextBox.Text))
            If CBool(ConfigurationManager.AppSettings("Unisoft.FeedbackSendEmail")) Then
                Dim eSender As New Email

                sMessage = Trim(NameTextBox.Text)
                If Trim(sMessage) <> "" Then
                    sMessage = "Name : " & sMessage & "<br />" & "Email address : " & Trim(EmailAddressTextBox.Text) & "<br /><hr><br />"
                Else
                    sMessage = "Email address : " & Trim(EmailAddressTextBox.Text) & "<br /><hr><br />"
                End If
                sMessage = sMessage & HttpUtility.HtmlEncode(Trim(FeedbackTextBox.Text)).Replace(System.Environment.NewLine, "<br />")
                sMessage = "<html><head><title></title></head><body><span style = 'font-family:Arial, Helvetica, sans-serif;font-size:10pt'>" & _
                                    sMessage & "</span></body><html>"
                eSender.sendEmail(sMessage, attach)
            End If
            ClearBoxes()
            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while sending feedback.", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
    Sub ClearBoxes()
        FormDiv.Style("display") = "none"
        SaveButton.Style("display") = "none"
        sentDiv.Style("display") = "normal"
    End Sub
End Class
