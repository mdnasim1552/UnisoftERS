
Imports System.IO
Imports DevExpress.Web.Office
Imports DevExpress.XtraRichEdit

Public Class EditLetterWindow
    Inherits System.Web.UI.Page

    Private _LetterQueueId As Long

    Private Property LetterQueueId As Long
        Get
            Return _LetterQueueId
        End Get
        Set(value As Long)
            _LetterQueueId = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        If Not Page.IsPostBack Then
            Using letterGenerationLogicObject As New LetterGenerationLogic()
                LetterQueueId = letterGenerationLogicObject.GetLetterQueueIdForAppointmentId(Request.QueryString("AppointmentId"))
                hdnLetterQueueId.Value = LetterQueueId
                Dim letterDoc = letterGenerationLogicObject.GetLetterForLetterQueueId(LetterQueueId)
                Dim fileType = letterGenerationLogicObject.GetFileType(letterDoc)
                If letterDoc IsNot Nothing Then
                    PopulateRichEdit(LetterQueueId, letterDoc, fileType)
                Else
                    Utilities.SetNotificationStyle(LetterPrintRadNotification, "There was an problem loading the Letter.", True, "Document not found")
                    LetterPrintRadNotification.Show()
                End If
            End Using

        End If
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
        Using letterGeneration As New LetterGenerationLogic
            letterGeneration.SaveLetter(CType(hdnLetterQueueId.Value, Long), ASPxRichEdit1.SaveCopy(DocumentFormat.Doc))
        End Using

    End Sub

    Protected Sub SaveAndPrintButton_Click(sender As Object, e As EventArgs)

        ASPxRichEdit1.Save()
        Dim url As String = "../Letters/DisplayAndPrintPDF.aspx?LetterQueueIds=" & hdnLetterQueueId.Value & "*False"
        Dim s As String = "window.open('" & url & "', '_blank');"
        ScriptManager.RegisterStartupScript(Me.Page, Page.GetType(), "text", s, True)
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs)
        DocumentManager.CloseDocument(ASPxRichEdit1.DocumentId)
        Response.Redirect("LetterPrinting.aspx", False)
    End Sub

End Class