Public Class DownloadDocument
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Response.Clear()
        Response.ContentType = "Application/pdf"
        Dim da As New LetterGenerationLogic
        Dim additionalDocumentId = Request.QueryString("documentId")
        Dim additionalDocument = da.GetAdditionalDocument(additionalDocumentId)

        Response.AddHeader("content-length", additionalDocument.Length())
        Response.BinaryWrite(additionalDocument)
        Response.Flush()
        Response.End()

    End Sub

End Class