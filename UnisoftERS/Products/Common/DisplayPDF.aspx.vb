Imports System.IO

Public Class DisplayPDF
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Response.Clear()
        Response.ContentType = "Application/pdf"
        Dim da As New DataAccess
        Dim procedurePDF As Byte()
        procedurePDF = da.getPreviousProcedurePDF(Request.QueryString("ProcedureId"))
        Response.AddHeader("content-length", procedurePDF.Length())
        Response.BinaryWrite(procedurePDF)
        Response.Flush()
        Response.End()
    End Sub

End Class