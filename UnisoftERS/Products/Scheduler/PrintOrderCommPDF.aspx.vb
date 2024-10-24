Imports System
Imports System.Net
Imports System.IO
Imports System.Web.UI
Imports Telerik.Web.UI

Public Class PrintOrderCommPDF
    Inherits System.Web.UI.Page
    Private _dataadapter As DataAccess = Nothing
    Private _dataadapter_sch As DataAccess_Sch = Nothing
    Private _ordercommsbl As OrderCommsBL = Nothing
    Public Shared intOrderCommId As Integer
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then

        End If
        If Not IsDBNull(Request.QueryString("OrderCommId")) AndAlso Request.QueryString("OrderCommId") <> "" Then
            intOrderCommId = CInt(Request.QueryString("OrderCommId"))

            lblStatus.Text = intOrderCommId.ToString()
            Dim objWR As HttpWebRequest
            Dim objResponse As HttpWebResponse
            Dim strUrl As String

            strUrl = HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + ResolveUrl("./OrderCommsReportForPdf.aspx")
            strUrl = strUrl + "?OrderId=" + intOrderCommId.ToString()

            objWR = HttpWebRequest.Create(strUrl)
            objResponse = objWR.GetResponse()

            Dim objstream As Stream
            objstream = objResponse.GetResponseStream()
            Dim sHtml As String

            sHtml = New StreamReader(objstream, System.Text.Encoding.Default).ReadToEnd()



            If Not IsNothing(objstream) Then
                objstream.Close()
            End If

            If Not IsNothing(objResponse) Then
                objResponse.Close()
            End If

            'Response.Write(sHtml)

            'Dim objSW As StringWriter = New StringWriter()
            'Dim htw As HtmlTextWriter = New HtmlTextWriter(objSW)
            'Dim strHtml As String

            'Me.Render(htw)
            'strHtml = htw.ToString()
            Dim bytes As Byte()
            'bytes = System.Text.Encoding.Unicode.GetBytes(sHtml)
            bytes = HtmlToPDFConverter.HtmlToPDFConverterInstance().GetByteArrayFromPageUrl(strUrl)

            Response.Clear()
            Response.ClearContent()
            Response.Buffer = True
            Response.Charset = ""
            Response.Cache.SetCacheability(HttpCacheability.NoCache)
            Response.ContentType = "application/pdf"
            Response.AddHeader("Content-Disposition", "inline; filename=someFile.pdf")
            Response.AppendHeader("content-length", (bytes.Length).ToString())


            'Response.BinaryWrite(bytes)
            Response.OutputStream.Write(bytes, 0, bytes.Length)
            Response.End()
            Response.Close()

            'HttpContext.Current.Response.Clear()
            'HttpContext.Current.Response.ContentType = "applicaiton/pdf"
            'HttpContext.Current.Response.AddHeader("Expires", "0")
            'HttpContext.Current.Response.AddHeader("Cache-Control", "")
            'HttpContext.Current.Response.AddHeader("Content-Disposition", "inline;filename=samplepdfreport.pdf")
            'HttpContext.Current.Response.AddHeader("Content-length", bytes.Length.ToString())
            'HttpContext.Current.Response.OutputStream.Write(bytes, 0, bytes.Length)
            'HttpContext.Current.Response.Flush()
            'HttpContext.Current.Response.SuppressContent = True
            'HttpContext.Current.ApplicationInstance.CompleteRequest()
        End If


    End Sub

End Class