Public Class DisplayAndPrintPDF
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Response.Clear()
        Response.ContentType = "Application/pdf"
        Dim da As New LetterGenerationLogic
        Dim letterQueueIds As New List(Of Tuple(Of Integer, Boolean))
        If Request.QueryString("LetterQueueIds") IsNot Nothing Then
            Dim LetterList = Request.QueryString("LetterQueueIds").Split("-"c).ToList()
            For Each letter In LetterList
                letterQueueIds.Add(ConvertToTuple(letter))
            Next
        End If

        If Request.QueryString("AppointmentId") IsNot Nothing Then
            Dim extract = Request.QueryString("AppointmentId").Split("*"c)
            Dim boolValue As Boolean

            If extract.Length > 1 Then
                boolValue = Boolean.Parse(extract(1))
            Else
                boolValue = False
            End If

            Dim appointmentId = da.GetLetterQueueIdForAppointmentId(Integer.Parse(extract(0)))
            letterQueueIds.Add(New Tuple(Of Integer, Boolean)(appointmentId, boolValue))
        End If
        Dim letterPdf = da.GetDocumentsForPrint(letterQueueIds)
        Response.AddHeader("content-length", letterPdf.Length())
        Response.BinaryWrite(letterPdf)
        Response.Flush()
        Response.End()
    End Sub

    Private Function ConvertToTuple(itemString As String) As Tuple(Of Integer, Boolean)
        Dim item = itemString.Split("*"c)
        Dim letterToAdd As Tuple(Of Integer, Boolean) = New Tuple(Of Integer, Boolean)(Integer.Parse(item(0)), Boolean.Parse(item(1)))
        Return letterToAdd
    End Function

End Class