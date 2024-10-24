Imports System.IO
Imports DevExpress.Web.Office
Imports DevExpress.XtraRichEdit

Public Class EditLetter
    Inherits System.Web.UI.Page

    Protected LetterQueueId As Int64

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Try
            LetterQueueId = Request.QueryString("LetterQueueId")
            If Not Page.IsPostBack Then
                hdnLetterQueueId.Value = LetterQueueId
                Using letterGenerationLogicObject As New LetterGenerationLogic()
                    Dim letterDoc = letterGenerationLogicObject.GetLetterForLetterQueueId(LetterQueueId)
                    Dim fileType = letterGenerationLogicObject.GetFileType(letterDoc)
                    If letterDoc IsNot Nothing Then
                        PopulateRichEdit(LetterQueueId, letterDoc, fileType)
                    Else
                        Utilities.SetNotificationStyle(LetterPrintRadNotification, "There was an problem loading the Letter.", True, "Document not found")
                        LetterPrintRadNotification.Show()
                    End If
                End Using

                If Request.QueryString("Printed") = "Yes" Then
                    LetterEditReasonDropdown.Visible = True
                    LetterEditReasonText.Visible = True
                    EditReasonLabel.Visible = True
                    PopulateLetterEditReasonDownList()
                End If

            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured During Page load for Edit Letter .", ex)
            Utilities.SetErrorNotificationStyle(LetterPrintRadNotification, errorLogRef, "Page load Error for Edit Print Letter.")
            LetterPrintRadNotification.Show()
        End Try
    End Sub

    Private Sub PopulateRichEdit(LetterQueueId As Long, LetterContent As Byte(), Format As DocumentFormat)
        ASPxRichEdit1.Open(LetterQueueId, Format, Function()
                                                      Dim docBytes() As Byte = LetterContent
                                                      Return New MemoryStream(docBytes)
                                                  End Function)
    End Sub

    Protected Sub RichEdit_Saving(ByVal source As Object, ByVal e As DocumentSavingEventArgs)
        ' Save document with the Ribbon Save button
        e.Handled = True
        Dim editReason As Integer = If(String.IsNullOrEmpty(LetterEditReasonDropdown.SelectedText), 0, LetterEditReasonDropdown.SelectedValue)
        Using letterGeneration As New LetterGenerationLogic
            letterGeneration.SaveLetter(LetterQueueId, ASPxRichEdit1.SaveCopy(DocumentFormat.Doc), editReason, LetterEditReasonText.Text)
        End Using

    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs)

        Response.Redirect("LetterPrinting.aspx", False)


    End Sub


    Protected Sub SaveAndPrintButton_Click(sender As Object, e As EventArgs)

        ASPxRichEdit1.Save()
        Dim url As String = "../Letters/DisplayAndPrintPDF.aspx?LetterQueueIds=" & hdnLetterQueueId.Value & "*False"
        Dim s As String = "window.open('" & url & "', '_blank');"
        ScriptManager.RegisterStartupScript(Me.Page, Page.GetType(), "text", s, True)
    End Sub

    Private Sub PopulateLetterEditReasonDownList()
        Dim da As New LetterGeneration
        LetterEditReasonDropdown.Items.Clear()
        LetterEditReasonDropdown.AppendDataBoundItems = True
        LetterEditReasonDropdown.DataSource = da.GetLetterEditReasonsActiveOnly()
        LetterEditReasonDropdown.DataBind()
    End Sub

    Protected Sub CloseDocument_Click(sender As Object, e As EventArgs)
        Try
            DocumentManager.CloseDocument(ASPxRichEdit1.DocumentId)
        Catch ex As Exception
            'Document wasn't open
        End Try
        Response.Redirect("LetterPrinting.aspx", False)
    End Sub
End Class