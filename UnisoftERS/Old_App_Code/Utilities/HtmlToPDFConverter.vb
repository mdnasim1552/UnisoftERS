Imports System
Imports System.Net
Imports System.IO
Imports iTextSharp.text
Imports iTextSharp.text.pdf
Imports iTextSharp.tool.xml
Imports iTextSharp.tool.xml.html
Imports iTextSharp.tool.xml.parser
Imports iTextSharp.tool.xml.pipeline.html
Imports iTextSharp.tool.xml.pipeline.css
Imports iTextSharp.tool.xml.pipeline.end
Imports System.Web.Services
Imports System.Web.Script.Services
Imports Telerik.Web.UI
Imports System.Text.RegularExpressions
Imports System.Web.Hosting
Public Class HtmlToPDFConverter
    Inherits System.Web.UI.Page
    Private Shared ReadOnly _instance As New Lazy(Of HtmlToPDFConverter)(Function() New HtmlToPDFConverter(), System.Threading.LazyThreadSafetyMode.ExecutionAndPublication)
    Private Shared singleInstance As HtmlToPDFConverter

    Public Shared ReadOnly Property HtmlToPDFConverterInstance() As HtmlToPDFConverter
        Get
            If singleInstance Is Nothing Then
                singleInstance = New HtmlToPDFConverter
            End If
            Return singleInstance
        End Get
    End Property
    Function GetEnvironmentRoot() As String
        Dim RetValue As String = HostingEnvironment.MapPath("~")
        If RetValue.Last() <> "\" Then
            RetValue += "\"
        End If
        Return RetValue
    End Function
    Public Function GetByteArrayFromPageUrl(strURL As String) As Byte()
        'Dim bytesArray As Byte()
        Try
            Dim pdfDoc As New Document(PageSize.A4, 50.0F, 50.0F, 10.0F, 20.0F)
            Dim outputSteam As New MemoryStream()
            Dim pdfW = PdfWriter.GetInstance(pdfDoc, outputSteam)
            Dim sHtml As String = ""
            sHtml = GetHtmlResponseFromURL(strURL)

            'ClinicalHistoryNotes RadEditor keeps <br/> as &lt;br/&gt; along with Line Break. Need to remove
            sHtml = sHtml.Replace("&lt;br/&gt;", "")

            pdfDoc.Open()

            Dim tagProcessors = DirectCast(Tags.GetHtmlTagProcessorFactory(), DefaultTagProcessorFactory)
            tagProcessors.RemoveProcessor(HTML.Tag.IMG)

            Dim htmlContext = New HtmlPipelineContext(Nothing)
            htmlContext.SetAcceptUnknown(True).AutoBookmark(True).SetTagFactory(tagProcessors)


            Dim cssResolver As ICSSResolver = XMLWorkerHelper.GetInstance().GetDefaultCssResolver(False)
            cssResolver.AddCssFile(HttpContext.Current.Server.MapPath("~/Styles/PrintReport.css"), True)
            cssResolver.AddCssFile(HttpContext.Current.Server.MapPath("~/Styles/Scheduler.css"), True)
            cssResolver.AddCssFile(HttpContext.Current.Server.MapPath("~/Styles/Site.css"), True)

            Dim pipeLine = New CssResolverPipeline(cssResolver, New HtmlPipeline(htmlContext, New PdfWriterPipeline(pdfDoc, pdfW)))

            Dim worker = New XMLWorker(pipeLine, True)
            Dim parser = New XMLParser(worker)

            pdfDoc.NewPage()

            Using msHtml = New MemoryStream(Encoding.UTF8.GetBytes(sHtml))
                parser.Parse(msHtml)
            End Using

            pdfDoc.Close()

            'Dim objMMF As MemoryMappedFiles.MemoryMappedFile
            'Dim objMMVS As MemoryMappedFiles.MemoryMappedViewStream
            'Dim objHtmlReader As New StringReader(sHtml)

            'objMMF = MemoryMappedFiles.MemoryMappedFile.CreateNew("SamplePdfReport.PDF", 1000000)
            'objMMVS = objMMF.CreateViewStream()
            'Dim writer As PdfWriter = PdfWriter.GetInstance(pdfDoc, objMMVS)

            'pdfDoc.Open()


            'XMLWorkerHelper.GetInstance().ParseXHtml(writer, pdfDoc, objHtmlReader)


            'Dim objBRD As New BinaryReader(objMMF.CreateViewStream)
            'Dim bytesArray(objMMF.CreateViewStream().Length - 1) As Byte

            'objBRD.Read(bytesArray, 0, objMMF.CreateViewStream().Length)

            'pdfDoc.Close()
            'objMMF.Dispose()
            'objMMVS.Dispose()

            Return outputSteam.GetBuffer()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : GetByteArrayFromPageUrl()", ex)
            Return Nothing
        End Try
    End Function
    Private Function GetHtmlResponseFromURL(strURL As String) As String
        Try
            Dim strHTMLResponse As String = ""

            Dim objWR As HttpWebRequest
            Dim objResponse As HttpWebResponse
            objWR = HttpWebRequest.Create(strURL)
            objResponse = objWR.GetResponse()
            Dim objstream As Stream
            objstream = objResponse.GetResponseStream()
            strHTMLResponse = New StreamReader(objstream, System.Text.Encoding.Default).ReadToEnd()

            strHTMLResponse = strHTMLResponse.Replace("<br>", "<br />")
            strHTMLResponse = strHTMLResponse.Replace("<br/>", "<br />")
            strHTMLResponse = strHTMLResponse.Replace("<br\>", "<br />")
            strHTMLResponse = strHTMLResponse.Replace("</br>", "<br />")
            strHTMLResponse = strHTMLResponse.Replace("<br /.", "<br />")
            strHTMLResponse = strHTMLResponse.Replace("<br/.", "<br />")


            If Not IsNothing(objstream) Then
                objstream.Close()
                objstream = Nothing
            End If
            If Not IsNothing(objResponse) Then
                objResponse.Close()
                objResponse = Nothing
            End If

            Return strHTMLResponse
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError("Error occured in : GetHtmlResponseFromURL()", ex)
        End Try
    End Function
End Class
