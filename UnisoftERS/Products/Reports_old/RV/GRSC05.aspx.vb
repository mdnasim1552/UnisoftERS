Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class GRSC05
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

            localReport.ReportPath = "Products/Reports/RV/GRSC05.rdlc"

            Dim ds1 As New DataSet()
            Dim UserID As String = Session("PKUserID").ToString
            Dim ProcType As String = Request.QueryString("ProcType")
            ds1 = Reports.GetGRSC05A(UserID, ProcType)
            'Create a report data source for the sales order data
            Dim RDS1 As New ReportDataSource()
            RDS1.Name = "DataSet1"
            RDS1.Value = ds1.Tables(0)
            localReport.DataSources.Add(RDS1)

            Dim ds2 As New DataSet()
            ds2 = Reports.GetGRSC05B()
            'Create a report data source for the sales order data
            Dim RDS2 As New ReportDataSource()
            RDS2.Name = "DataSet2"
            RDS2.Value = ds2.Tables(0)
            localReport.DataSources.Add(RDS2)
        End If
    End Sub

End Class