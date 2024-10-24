Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class GRSB01
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub
    Protected Sub Page_Tnit(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        If IsNothing(Session("PKUserId")) Then
            Response.Redirect("/")
        End If
        If Not Page.IsPostBack Then
            'Set the processing mode for the ReportViewer to Local
            RV.ProcessingMode = ProcessingMode.Local

            Dim localReport As LocalReport
            localReport = RV.LocalReport

            localReport.ReportPath = "Products/Reports/RV/GRSB01.rdlc"

            Dim ds As New DataSet()

            Dim UserID As String = Session("PKUserID").ToString
            Dim Endoscopist1 As String = Request.QueryString("Endoscopist1")
            Dim Endoscopist2 As String = Request.QueryString("Endoscopist2")
            Dim OGD As String = Request.QueryString("OGD")
            Dim COLSIG As String = Request.QueryString("COLSIG")
            Dim Sessile As String = Request.QueryString("Sessile")
            Dim Pedunculated As String = Request.QueryString("Pedunculated")
            Dim Pseudopolyp As String = Request.QueryString("Pseudopolyp")
            Dim GTPedunculated As String = Request.QueryString("GTPedunculated")
            Dim GTSessile As String = Request.QueryString("GTSessile")
            Dim GTPseudopolyp As String = Request.QueryString("GTPseudopolyp")
            Dim FromAge As String = Request.QueryString("FromAge")
            Dim ToAge As String = Request.QueryString("ToAge")

            ds = Reports.GetGRSB01(UserID, Endoscopist1, Endoscopist2, Sessile, Pedunculated, Pseudopolyp, GTSessile, GTPedunculated, GTPseudopolyp, FromAge, ToAge)

            'Create a report data source for the sales order data
            Dim RDS As New ReportDataSource()
            RDS.Name = "DataSet1"
            Try
                RDS.Value = ds.Tables(0)
            Catch ex As Exception

            End Try
            localReport.DataSources.Add(RDS)
        End If
    End Sub

End Class