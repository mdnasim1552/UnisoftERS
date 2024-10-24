Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class GRSC03
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

            localReport.ReportPath = "Products/Reports/RV/GRSC03.rdlc"
            Dim UserID As String = Session("PKUserID").ToString
            Dim ProcType As String = Request.QueryString("ProcType")
            Dim Complications As String = Request.QueryString("Complications")
            Dim ReversalAgents As String = Request.QueryString("ReversalAgents")
            Dim Endoscopist1 As String = Request.QueryString("Endoscopist1")
            Dim Endoscopist2 As String = Request.QueryString("Endoscopist2")
            Dim AppId As String = ""
            If Reports.ShowOldProcedures = True Then
                AppId = "U"
            End If
            Dim p0 As New ReportParameter("UserID", UserID)
            Dim p1 As New ReportParameter("ProcType", ProcType)
            Dim p2 As New ReportParameter("Complications", Complications)
            Dim p3 As New ReportParameter("ReversalAgents", ReversalAgents)
            Dim p4 As New ReportParameter("Endoscopist1", Endoscopist1)
            Dim p5 As New ReportParameter("Endoscopist2", Endoscopist2)
            Dim p6 As New ReportParameter("AppId", AppId)
            localReport.SetParameters(New ReportParameter() {p0, p1, p2, p3, p4, p5, p6})

            Dim ds As New DataSet()

            ds = Reports.GetGRSC03(UserID, ProcType, Complications, ReversalAgents, Endoscopist1, Endoscopist2, AppId)

            'Create a report data source for the sales order data
            Dim RDS As New ReportDataSource()
            RDS.Name = "DataSet1"
            RDS.Value = ds.Tables(0)

            localReport.DataSources.Add(RDS)
        End If
    End Sub

End Class