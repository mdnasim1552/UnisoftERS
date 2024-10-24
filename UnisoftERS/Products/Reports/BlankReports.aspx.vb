Imports System
Imports System.IO
Imports iTextSharp.text
Imports iTextSharp.text.pdf
Imports iTextSharp.tool.xml
Imports iTextSharp.tool.xml.html
Imports iTextSharp.tool.xml.parser
Imports iTextSharp.tool.xml.css
Imports iTextSharp.tool.xml.pipeline.html
Imports iTextSharp.tool.xml.pipeline.css
Imports iTextSharp.tool.xml.pipeline.end

Imports System.Web.Services
Imports System.Web.Script.Services
Imports System.Drawing
Imports System.Drawing.Imaging
Imports Telerik.Web.UI
Imports System.Data.SqlClient

Public Class Products_Reports_BlankReports
    Inherits System.Web.UI.Page
    Public Const margin1 As Single = 20.0F
    Public Const margin2 As Single = 300
    Public Const margin11 As Single = 40.0F
    Public Const margin22 As Single = 400

    Public ReadOnly Property PrintParams() As PrintOptions
        Get
            Return DirectCast(Session("PrintOptions"), PrintOptions)
        End Get
    End Property
    Private Function GetPrintTimeText() As String
        Return "Printed on " & DateTime.Now.ToString("dd/MM/yyyy") & " at " & DateTime.Now.ToString("HH:mm")
    End Function
    Private Function GetPdfFileName() As String
        Dim fname As String = "BlankReports.pdf"
        'If Not fname.EndsWith(".pdf") Then fname = fname & ".pdf"
        Return fname
    End Function
    Function GetData(ByVal sqlQuery As String) As DataTable
        Dim dsData As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sqlQuery, connection)
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsData)
        End Using

        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
    Function GetValue(ByVal Qry As String) As String
        Dim str As String = ""
        Dim DT As DataTable = GetData(Qry)
        Dim Row As DataRow
        For Each Row In DT.Rows
            str = Row(0).ToString
            Exit For
        Next
        Return str
    End Function
    Protected Sub Print_Click(sender As Object, e As EventArgs) Handles Print.Click
        'Products_Common_PrintReport.GenerateDiagram(1, 0, 3, 0)
        'Exit Sub
        Dim headerCount As Single = 25.0F
        Dim documentPDF As New Document(PageSize.A4, 20.0F, 45.0F, headerCount, 80.0F)
        Dim TextStream As String = "BlankReports.pdf"
        Dim HospitalName As String = GetValue("Select Top 1 HospitalName From [dbo].[ERS_OperatingHospitals]")
        Dim OGDCopies As Integer = 0
        Dim ERCCopies As Integer = 0
        Dim EUSCopies As Integer = 0
        Dim COLCopies As Integer = 0
        Dim SIGCopies As Integer = 0
        Dim HPBCopies As Integer = 0
        Dim PROCopies As Integer = 0
        Dim BROCopies As Integer = 0
        Dim TotalPages As Integer = 0
        Dim CurrentPage As Integer = 0
        Dim i As Integer = 0
        Dim image As iTextSharp.text.Image
        If OGD.Checked Then OGDCopies = NOGD.Value
        If EUS.Checked Then EUSCopies = NEUS.Value
        If COL.Checked Then COLCopies = NCOL.Value
        If SIG.Checked Then SIGCopies = NSIG.Value
        If PRO.Checked Then PROCopies = NPRO.Value
        If ERC.Checked Then ERCCopies = NERC.Value
        If BRO.Checked Then BROCopies = NBRO.Value
        If HPB.Checked Then HPBCopies = NHPB.Value
        TotalPages = OGDCopies + EUSCopies + COLCopies + SIGCopies + PROCopies + ERCCopies + BROCopies + HPBCopies
        'Creamos el objeto documento PDF
        Dim iList As New List(Of String)()
        For i = 1 To OGDCopies
            iList.Add("OGD")
        Next
        For i = 1 To ERCCopies
            iList.Add("ERC")
        Next
        For i = 1 To COLCopies
            iList.Add("COL")
        Next
        For i = 1 To SIGCopies
            iList.Add("SIG")
        Next
        For i = 1 To PROCopies
            iList.Add("PRO")
        Next
        For i = 1 To EUSCopies
            iList.Add("EUS")
        Next
        For i = 1 To HPBCopies
            iList.Add("HPB")
        Next
        For i = 1 To BROCopies
            iList.Add("BRO")
        Next
        PdfWriter.GetInstance(documentPDF,
            New FileStream(TextStream, FileMode.Create))
        Using outputStream As New MemoryStream()
            Dim w = PdfWriter.GetInstance(documentPDF, outputStream)
            Dim pe = New UnisoftPdfPageEvent() _
                With
                {
                    .ReportHeading = HospitalName,
                    .TrustType = "",
                    .ReportSubHeading = "",
                    .ReportName = "",
                    .LogoPath = HttpContext.Current.Server.MapPath("~/Images/NHS-RGB.jpg"),
                    .PrintTimeText = GetPrintTimeText(),
                    .EndoscopistName = "",
                    .GPReportPageCount = 1}
            '.PhotosReportPageCount = 1,
            '.PatientCopyReportPageCount = 1
            w.PageEvent = pe
            documentPDF.Open()
            For Each rpt As String In iList
                'Escribimos el texto en el objeto documento PDF
                documentPDF.NewPage()
                Select Case rpt
                    Case "OGD"
                        pe.ReportName = "GASTROSCOPY REPORT"
                    Case "ERC"
                        pe.ReportName = "ERCP REPORT"
                    Case "COL"
                        pe.ReportName = "COLONOSCOPY REPORT"
                    Case "SIG"
                        pe.ReportName = "SIGMOIDOSCOPY REPORT"
                    Case "PRO"
                        pe.ReportName = "PROCTOSCOPY REPORT"
                    Case "EUS"
                        pe.ReportName = "ENDOSCOPY ULTRASOUND (UGI) REPORT"
                    Case "HPB"
                        pe.ReportName = "ENDOSCOPY ULTRASOUND (HPB) REPORT"
                    Case "BRO"
                        pe.ReportName = "BRONCHOSCOPY REPORT"
                End Select
                documentPDF.Add(New iTextSharp.text.Paragraph(" ", FontFactory.GetFont(FontFactory.HELVETICA, 8.0F, iTextSharp.text.Font.NORMAL)))
                Dim cb As PdfContentByte = w.DirectContent
                Dim FontColour As BaseColor = New BaseColor(0, 162, 232)

                cb.SetLineWidth(0.2F)
                cb.MoveTo(margin1, 720)
                cb.LineTo(documentPDF.PageSize.Width - margin1, 720)
                cb.Stroke()
                cb.SetLineWidth(0.2F)
                cb.MoveTo(margin1, 25)
                cb.LineTo(documentPDF.PageSize.Width - margin1, 25)
                cb.SetLineWidth(0.2F)
                cb.MoveTo(margin1, 70)
                cb.LineTo(margin1 + 175, 70)
                cb.Stroke()
                cb.BeginText()
                Dim bf = BaseFont.CreateFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED)
                cb.SetFontAndSize(bf, 10)
                cb.SetTextMatrix(margin1, 762)
                cb.ShowText("Name: ")
                cb.SetTextMatrix(margin1, 748)
                cb.ShowText(Session(Constants.SESSION_HEALTH_SERVICE_NAME) & " No: ")
                cb.SetTextMatrix(margin1, 734)
                cb.ShowText("District No: ")
                cb.SetTextMatrix(margin2, 762)
                cb.ShowText("Address: ")
                cb.SetTextMatrix(margin1, 695)
                cb.ShowText("GP: ")
                cb.SetTextMatrix(margin2, 695)
                cb.ShowText("Procedure date: ")
                cb.SetTextMatrix(margin2, 681)
                cb.ShowText("Priority: ")
                cb.SetTextMatrix(margin2, 667)
                cb.ShowText("Status: ")
                cb.SetTextMatrix(margin2, 653)
                cb.ShowText("Hospital: ")
                cb.SetTextMatrix(margin2, 639)
                cb.ShowText("Referring Cons: ")
                cb.SetFontAndSize(bf, 8)
                cb.SetTextMatrix(margin1, 15)
                cb.ShowText("Produced by Solus ERS Tool (v" & HttpContext.Current.Session(Constants.SESSION_APPVERSION) & ")")
                cb.SetTextMatrix(documentPDF.PageSize.Width / 2, 15)
                cb.ShowText("Page 1 of 1")
                cb.ShowTextAligned(PdfContentByte.ALIGN_RIGHT, GetPrintTimeText(), documentPDF.PageSize.Width - margin1, 15, 0)
                cb.SetColorFill(FontColour)
                cb.SetFontAndSize(bf, 11)
                cb.SetTextMatrix(margin1, 600)
                cb.ShowText("Indications")
                cb.SetTextMatrix(margin1, 500)
                cb.ShowText("Report")
                cb.SetTextMatrix(margin1, 250)
                cb.ShowText("Advice/comments")
                cb.SetTextMatrix(margin1, 150)
                cb.ShowText("Follow up")
                cb.ShowTextAligned(PdfContentByte.ALIGN_RIGHT, "Consultant/Endoscopist", documentPDF.PageSize.Width - margin1, 600, 0)
                cb.ShowTextAligned(PdfContentByte.ALIGN_RIGHT, "Instrument", documentPDF.PageSize.Width - margin1, 520, 0)
                cb.ShowTextAligned(PdfContentByte.ALIGN_RIGHT, "Premedication", documentPDF.PageSize.Width - margin1, 480, 0)
                cb.EndText()
                Select Case rpt
                    Case "OGD"
                        image = iTextSharp.text.Image.GetInstance(HttpContext.Current.Server.MapPath("~/Images/Stomach.png"))
                        image.ScalePercent(50)
                        image.SetAbsolutePosition(margin22, 200)
                        image.Border = iTextSharp.text.Rectangle.TOP_BORDER Or iTextSharp.text.Rectangle.RIGHT_BORDER Or iTextSharp.text.Rectangle.BOTTOM_BORDER Or iTextSharp.text.Rectangle.LEFT_BORDER
                        image.BorderWidth = 1
                        documentPDF.Add(image)
                    Case "ERC"
                        image = iTextSharp.text.Image.GetInstance(HttpContext.Current.Server.MapPath("~/Images/ERCP.png"))
                        image.ScalePercent(30)
                        image.SetAbsolutePosition(margin22, 200)
                        image.Border = iTextSharp.text.Rectangle.TOP_BORDER Or iTextSharp.text.Rectangle.RIGHT_BORDER Or iTextSharp.text.Rectangle.BOTTOM_BORDER Or iTextSharp.text.Rectangle.LEFT_BORDER
                        image.BorderWidth = 1
                        documentPDF.Add(image)
                    Case "COL"
                        image = iTextSharp.text.Image.GetInstance(HttpContext.Current.Server.MapPath("~/Images/Colon.png"))
                        image.ScalePercent(40)
                        image.SetAbsolutePosition(margin22, 200)
                        image.Border = iTextSharp.text.Rectangle.TOP_BORDER Or iTextSharp.text.Rectangle.RIGHT_BORDER Or iTextSharp.text.Rectangle.BOTTOM_BORDER Or iTextSharp.text.Rectangle.LEFT_BORDER
                        image.BorderWidth = 1
                        documentPDF.Add(image)
                    Case "SIG"
                        image = iTextSharp.text.Image.GetInstance(HttpContext.Current.Server.MapPath("~/Images/Colon.png"))
                        image.ScalePercent(40)
                        image.SetAbsolutePosition(margin22, 200)
                        image.Border = iTextSharp.text.Rectangle.TOP_BORDER Or iTextSharp.text.Rectangle.RIGHT_BORDER Or iTextSharp.text.Rectangle.BOTTOM_BORDER Or iTextSharp.text.Rectangle.LEFT_BORDER
                        image.BorderWidth = 1
                        documentPDF.Add(image)
                    Case "PRO"
                        image = iTextSharp.text.Image.GetInstance(HttpContext.Current.Server.MapPath("~/Images/Colon.png"))
                        image.ScalePercent(40)
                        image.SetAbsolutePosition(margin22, 200)
                        image.Border = iTextSharp.text.Rectangle.TOP_BORDER Or iTextSharp.text.Rectangle.RIGHT_BORDER Or iTextSharp.text.Rectangle.BOTTOM_BORDER Or iTextSharp.text.Rectangle.LEFT_BORDER
                        image.BorderWidth = 1
                        documentPDF.Add(image)
                    Case "EUS"
                        image = iTextSharp.text.Image.GetInstance(HttpContext.Current.Server.MapPath("~/Images/Stomach.png"))
                        image.ScalePercent(50)
                        image.SetAbsolutePosition(margin22, 200)
                        image.Border = iTextSharp.text.Rectangle.TOP_BORDER Or iTextSharp.text.Rectangle.RIGHT_BORDER Or iTextSharp.text.Rectangle.BOTTOM_BORDER Or iTextSharp.text.Rectangle.LEFT_BORDER
                        image.BorderWidth = 1
                        documentPDF.Add(image)
                    Case "HPB"
                        image = iTextSharp.text.Image.GetInstance(HttpContext.Current.Server.MapPath("~/Images/ERCP.png"))
                        image.ScalePercent(30)
                        image.SetAbsolutePosition(margin22, 200)
                        image.Border = iTextSharp.text.Rectangle.TOP_BORDER Or iTextSharp.text.Rectangle.RIGHT_BORDER Or iTextSharp.text.Rectangle.BOTTOM_BORDER Or iTextSharp.text.Rectangle.LEFT_BORDER
                        image.BorderWidth = 1
                        documentPDF.Add(image)
                    Case "BRO"
                        Dim MyImageStream As MemoryStream = New MemoryStream()

                        Dim svgFileName As String = HttpContext.Current.Server.MapPath("~/Images/brt-1-a.svg")
                        Dim PngRelativeDirectory As String = HttpContext.Current.Server.MapPath("")
                        Dim pngName As String = "svgpieresult.png"
                        Dim pngFileName As String = HttpContext.Current.Server.MapPath("pngName")
                        'myChart.SaveImage(MyImageStream)
                        'pe.ReportName = "BRONCHOSCOPY REPORT"
                End Select
                documentPDF.Add(New iTextSharp.text.Paragraph(" ", FontFactory.GetFont(FontFactory.HELVETICA, 8.0F, iTextSharp.text.Font.NORMAL)))
            Next

            documentPDF.AddAuthor("ERS Reporting System")
            documentPDF.AddCreator("HD Clinical Ltd")
            documentPDF.AddKeywords("Blank report")
            documentPDF.AddSubject("Blank report")
            documentPDF.AddTitle("Blank report")
            documentPDF.AddCreationDate()
            'Cerramos el objeto documento, guardamos y creamos el PDF
            documentPDF.Close()

            'Clear the response buffer
            System.Web.HttpContext.Current.Response.Clear()
            'Set the output type as a PDF
            System.Web.HttpContext.Current.Response.ContentType = "application/pdf"
            'Disable caching'
            System.Web.HttpContext.Current.Response.AddHeader("Expires", "0")
            System.Web.HttpContext.Current.Response.AddHeader("Cache-Control", "")
            'Set the filename'
            System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", "inline; filename=""" & GetPdfFileName() & """")
            'Set the length of the file so the browser can display an accurate progress bar
            System.Web.HttpContext.Current.Response.AddHeader("Content-length", outputStream.GetBuffer().Length.ToString())
            'Write the contents of the memory stream
            System.Web.HttpContext.Current.Response.OutputStream.Write(outputStream.GetBuffer(), 0, outputStream.GetBuffer().Length)
            'Close the response stream
            'System.Web.HttpContext.Current.Response.End()
            HttpContext.Current.Response.Flush() ' Sends all currently buffered output to the client.
            HttpContext.Current.Response.SuppressContent = True ' Gets or sets a value indicating whether to send HTTP content to the client.
            HttpContext.Current.ApplicationInstance.CompleteRequest() ' Causes ASP.NET to bypass all events and filtering in the HTTP pipeline chain of execution and directly execute the EndRequest event.

        End Using
    End Sub
End Class