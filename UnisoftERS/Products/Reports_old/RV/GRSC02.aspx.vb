Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class GRSC02
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

            localReport.ReportPath = "Products/Reports/RV/GRSC02.rdlc"
            Dim UserID As String = Session("PKUserID").ToString
            Dim Summary As String = Request.QueryString("Summary")
            Dim Endoscopist1 As String = Request.QueryString("Endoscopist1")
            Dim Endoscopist2 As String = Request.QueryString("Endoscopist2")

            Dim p0 As New ReportParameter("UserId", UserID)
            Dim p1 As New ReportParameter("Summary", Summary)
            Dim p2 As New ReportParameter("Endoscopist1", Endoscopist1)
            Dim p4 As New ReportParameter("Endoscopist2", Endoscopist2)
            localReport.SetParameters(New ReportParameter() {p0, p1, p2, p4})

            Dim ds As New DataSet()

            ds = Reports.GetGRSC02(UserID, Summary, Endoscopist1, Endoscopist2)

            'Create a report data source for the sales order data
            Dim RDS As New ReportDataSource()
            RDS.Name = "DataSet1"
            RDS.Value = ds.Tables(0)

            localReport.DataSources.Add(RDS)
        End If
    End Sub
End Class