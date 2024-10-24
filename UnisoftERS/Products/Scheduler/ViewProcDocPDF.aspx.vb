Imports System
Imports System.Data

Public Class ViewProcDocPDF
    Inherits System.Web.UI.Page
    Private _dataadapter As DataAccess = Nothing
    Private _dataadapter_sch As DataAccess_Sch = Nothing
    Private _ordercommsbl As OrderCommsBL = Nothing
    Private Shared intProcedureId As Integer
    Private Shared dtProcedureDate As DateTime
    Private Shared strDocumentSource As String
    Protected ReadOnly Property DataAdapter() As DataAccess
        Get
            If _dataadapter Is Nothing Then
                _dataadapter = New DataAccess
            End If
            Return _dataadapter
        End Get
    End Property
    Protected ReadOnly Property DataAdapter_Sch() As DataAccess_Sch
        Get
            If _dataadapter_sch Is Nothing Then
                _dataadapter_sch = New DataAccess_Sch
            End If
            Return _dataadapter_sch
        End Get
    End Property
    Protected ReadOnly Property OrderCommsBL() As OrderCommsBL
        Get
            If _ordercommsbl Is Nothing Then
                _ordercommsbl = New OrderCommsBL
            End If
            Return _ordercommsbl
        End Get
    End Property
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim blnAllParamOkay = True

            If Not IsDBNull(Request.QueryString("ProcedureId")) AndAlso Request.QueryString("ProcedureId") <> "" Then
                intProcedureId = Convert.ToInt32(Request.QueryString("ProcedureId"))
            Else
                blnAllParamOkay = False
            End If

            If Not IsDBNull(Request.QueryString("ProcedureMaxDate")) AndAlso Request.QueryString("ProcedureMaxDate") <> "" Then
                dtProcedureDate = Convert.ToDateTime(Request.QueryString("ProcedureMaxDate"))
            Else
                blnAllParamOkay = False
            End If

            If Not IsDBNull(Request.QueryString("ProcedureDocSource")) AndAlso Request.QueryString("ProcedureDocSource") <> "" Then
                strDocumentSource = Request.QueryString("ProcedureDocSource")
            Else
                blnAllParamOkay = False
            End If

            Dim dsPDF = New DataSet
            Dim bytes As Byte()

            If blnAllParamOkay Then
                dsPDF = OrderCommsBL.GetProcedurePDFReportByProcedureId(intProcedureId, dtProcedureDate, strDocumentSource)
                If Not IsNothing(dsPDF) Then
                    If dsPDF.Tables(0).Rows.Count > 0 Then
                        bytes = CType(dsPDF.Tables(0).Rows(0)("PDF"), Byte())

                        Response.ContentType = "application/pdf"
                        Response.AddHeader("content-length", bytes.Length.ToString())
                        Response.BinaryWrite(bytes)

                        'lblStatus.Visible = True
                        'lblStatus.Text = "Generating PDF. Please Wait..."

                    Else
                        lblStatus.Visible = True
                        lblStatus.Text = "No previous procedure was found for the selected patient."
                    End If
                Else
                    lblStatus.Visible = True
                    lblStatus.Text = "Sorry, something went wrong. Please try again later.<br>PDF report couldn't be retrieved."
                End If
            Else
                lblStatus.Visible = True
                lblStatus.Text = "No all required parameters have been provided.<br>PDF report couldn't be retrieved."
            End If

        End If

    End Sub


End Class