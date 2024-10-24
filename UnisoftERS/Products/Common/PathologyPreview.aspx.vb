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

Public Class PathologyPreview
    Inherits PageBase

    Private procedureID As Integer

    Public ReadOnly Property PreviewParams() As PrintOptions
        Get
            Return DirectCast(Session("PreviewOptions"), PrintOptions)
        End Get
    End Property

    Public ReadOnly Property RepEnableNHSStyle As String
        Get
            Return ConfigurationManager.AppSettings("Unisoft.RepEnableNHSStyle")
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        procedureID = CInt(Request.QueryString("ProcedureID"))

        If Not Page.IsPostBack Then
            SetPrintOptions()
            PopulateReport()
        End If
    End Sub

    Private Sub PopulateReport()
        Dim ProcedureId = Session(Constants.SESSION_PROCEDURE_ID)
        Dim ProcedureTypeId = Session(Constants.SESSION_PROCEDURE_TYPE)
        Dim EpisodeNo = Session(Constants.SESSION_EPISODE_NO)
        Dim ColonType = Session(Constants.SESSION_PROCEDURE_COLONTYPE)
        Dim PatientComboId = Session(Constants.SESSION_PATIENT_COMBO_ID)

        Dim dtPat As DataTable = DataAdapter.GetPatientSummary(ProcedureId, ProcedureTypeId, EpisodeNo, PatientComboId)
        If Not dtPat Is Nothing AndAlso dtPat.Rows.Count > 0 Then
            NameLabel.Text = CStr(dtPat.Rows(0)("PatientName")) & " (" & CStr(dtPat.Rows(0)("Gender")) & ")"
            DobLabel.Text = dtPat.Rows(0)("DateOfBirth").ToString("dd/MM/yyyy")
            NhsNoLabel.Text = CStr(dtPat.Rows(0)("NHSNo"))
            CaseNoteNoLabel.Text = CStr(dtPat.Rows(0)("CaseNoteNo"))
            AddressLabel.Text = CStr(dtPat.Rows(0)("Address")).Replace(Char.ConvertFromUtf32(10), "<br />")

            ProcedureDateLabel.Text = CStr(dtPat.Rows(0)("ProcedureDate"))
            LabReportNumberLabel.Text = Request.QueryString("LabReportNo")
            PathologyReportDateLabel.Text = Request.QueryString("ReportDate")

            Dim sCaseNoteNo As String = DataAdapter.GetCountryLabel("CNN")
            Dim sNHSNo As String = DataAdapter.GetCountryLabel("NHSNo")
            lblCaseNoteNo.Text = sCaseNoteNo

            lblNHSNo.Text = sNHSNo
        End If

        SummaryListView.DataBind()
    End Sub

    Private Sub SetPrintOptions()
        Dim po As PrintOptions = LogicAdapter.GetPrintOptions()

        Session("PreviewOptions") = po

        po.ProcedureId = Session(Constants.SESSION_PROCEDURE_ID)
        po.ProcedureTypeId = Session(Constants.SESSION_PROCEDURE_TYPE)
        po.EpisodeNo = Session(Constants.SESSION_EPISODE_NO)
        po.ColonType = Session(Constants.SESSION_PROCEDURE_COLONTYPE)
        po.PatientComboId = Session(Constants.SESSION_PATIENT_COMBO_ID)

        po.IncludeGPReport = True
        po.IncludePhotosReport = False
        po.IncludePatientCopyReport = False
        po.IncludeLabRequestReport = False
        po.PreviewOnly = True
    End Sub

    Protected Overrides Sub Render(output As HtmlTextWriter)
        GenerateReport()
    End Sub

    Protected Sub SummaryListView_DataBound(sender As Object, e As EventArgs) Handles SummaryListView.DataBound
        If SummaryListView.Items.Count > 0 Then
            If SummaryListView.Items.Where(Function(i As ListViewDataItem) i.Visible).Count = 0 Then
                SummaryListView.Visible = False
            End If
        Else
            SummaryListView.Visible = False
        End If
    End Sub

    Public Sub GenerateReport()
        Dim bRepEnableNHSStyle As Boolean = CBool(RepEnableNHSStyle)

        Dim dtPat As DataTable = DataAdapter.GetPrintReportHeader(CInt(Session("OperatingHospitalID")), CInt(Session(Constants.SESSION_PROCEDURE_ID)), CInt(Session(Constants.SESSION_EPISODE_NO)), CStr(Session(Constants.SESSION_PATIENT_COMBO_ID)), CInt(Session(Constants.SESSION_PROCEDURE_TYPE)), bRepEnableNHSStyle)
        'Dim dtPat As DataTable = DataAdapter.GetPrintReportHeader(CInt(Session("OperatingHospitalID")))
        If dtPat.Rows.Count = 0 Then
            'NothingToPrint()
            Return
        End If

        'calculate start position base on the number of header lines
        Dim headerCount As Single = 25.0F
        If Not IsDBNull(dtPat.Rows(0)("ReportHeading")) AndAlso Not IsNothing(dtPat.Rows(0)("ReportHeading")) AndAlso dtPat.Rows(0)("ReportHeading") <> "" Then
            headerCount += 20.0F
        End If
        If Not IsDBNull(dtPat.Rows(0)("ReportTrustType")) AndAlso Not IsNothing(dtPat.Rows(0)("ReportTrustType")) AndAlso dtPat.Rows(0)("ReportTrustType") <> "" Then
            headerCount += 20.0F
        End If
        If Not IsDBNull(dtPat.Rows(0)("ReportSubHeading")) AndAlso Not IsNothing(dtPat.Rows(0)("ReportSubHeading")) AndAlso dtPat.Rows(0)("ReportSubHeading") <> "" Then
            headerCount += 20.0F
        End If
        If Not IsDBNull(dtPat.Rows(0)("ReportHeader")) AndAlso Not IsNothing(dtPat.Rows(0)("ReportHeader")) AndAlso dtPat.Rows(0)("ReportHeader") <> "" Then
            headerCount += 20.0F
        End If
        'If Not IsNothing(GetReportName()) AndAlso GetReportName() <> "" Then
        '    headerCount += 20.0F
        'End If

        'Dim document As New Document(PageSize.A4, 10.0F, 10.0F, 100.0F, 80.0F)
        'Dim document As New Document(PageSize.A4, Left, Right, Top, Bottom)
        Dim document As New Document(PageSize.A4, 20.0F, 45.0F, headerCount, 80.0F)

        Dim htmlText As String

        Using outputStream As New MemoryStream()
            Dim w = PdfWriter.GetInstance(document, outputStream)
            Dim pe = New UnisoftPdfPageEvent() _
                With
                {
                    .ReportHeading = dtPat.Rows(0)("ReportHeading"),
                    .TrustType = dtPat.Rows(0)("ReportTrustType"),
                    .ReportSubHeading = dtPat.Rows(0)("ReportSubHeading"),
                    .ReportName = dtPat.Rows(0)("ReportHeader").ToString().Replace("REPORT", "PATHOLOGY REPORT"),
                    .LogoPath = HttpContext.Current.Server.MapPath("~/Images/NHS-RGB.jpg"),
                    .PrintTimeText = Now.ToShortDateString(),
                    .EndoscopistName = "",
                    .CCRefConName = "",
                    .PrintOptionValues = PreviewParams
                }
            w.PageEvent = pe

            'Open the PDF for writing
            document.Open()

            Dim tagProcessors = DirectCast(Tags.GetHtmlTagProcessorFactory(), DefaultTagProcessorFactory)
            tagProcessors.RemoveProcessor(html.Tag.IMG)

            'Remove the default processor and use our new processor
            tagProcessors.AddProcessor(html.Tag.IMG, New CustomImageTagProcessor())

            'iTextSharp.text.FontFactory.Register("c:\windows\fonts\cambria.ttc", "Segoe UI")

            Dim htmlContext = New HtmlPipelineContext(Nothing)

            'For img embed
            htmlContext.SetAcceptUnknown(True).AutoBookmark(True).SetTagFactory(tagProcessors)

            Dim cssResolver As ICSSResolver = XMLWorkerHelper.GetInstance().GetDefaultCssResolver(False)
            cssResolver.AddCssFile(HttpContext.Current.Server.MapPath("~/Styles/PrintReport.css"), True)

            Dim pipeline = New CssResolverPipeline(cssResolver, New HtmlPipeline(htmlContext, New PdfWriterPipeline(document, w)))
            Dim worker = New XMLWorker(pipeline, True)
            Dim p = New XMLParser(worker)
            Dim sb = New StringBuilder()

            'MAIN REPORT
            GPReportDiv.RenderControl(New HtmlTextWriter(New StringWriter(sb)))
            htmlText = sb.ToString().Replace("</br>", "<br />")
            htmlText = htmlText.Replace("<br>", "<br />")

            Using srHtml = New MemoryStream(Encoding.UTF8.GetBytes(htmlText))
                p.Parse(srHtml)
            End Using

            'Always add a new page after report is done, irrespective of whether there will be a next report - this is to get the accurate page number
            document.NewPage()

            pe.GPReportPageCount = w.PageNumber - 1

            'Always add a new page after report is done, irrespective of whether there will be a next report - this is to get the accurate page number
            document.NewPage()

            pe.PhotosReportPageCount = w.PageNumber - 1 - pe.GPReportPageCount

            'Change the margins for Lab Request report as no header/footer required
            document.SetMargins(10.0F, 10.0F, 1.0F, 1.0F)

            'Always add a new page after report is done, irrespective of whether there will be a next report - this is to get the accurate page number
            document.NewPage()

            pe.PatientCopyReportPageCount = w.PageNumber - 1 - pe.GPReportPageCount - pe.PhotosReportPageCount

            'Close the PDF
            document.Close()

            'Clear the response buffer
            System.Web.HttpContext.Current.Response.Clear()
            'Set the output type as a PDF
            System.Web.HttpContext.Current.Response.ContentType = "application/pdf"
            'Disable caching'
            System.Web.HttpContext.Current.Response.AddHeader("Expires", "0")
            System.Web.HttpContext.Current.Response.AddHeader("Cache-Control", "")
            'Set the filename'
            System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", "inline; filename=""Pathology Preview""")
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