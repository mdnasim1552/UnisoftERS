Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class GRSA04
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
            localReport.ReportPath = "Products/Reports/RV/GRSA04.rdlc"

            Dim UserID As String = Session("PKUserID").ToString
            Dim Summary As String = Request.QueryString("Summary")
            Dim Patients As String = Request.QueryString("Patients")

            Dim p0 As New ReportParameter("UserID", UserID)
            Dim p1 As New ReportParameter("Summary", Summary)
            Dim p2 As New ReportParameter("Patients", Patients)
            localReport.SetParameters(New ReportParameter() {p0, p1, p2})

            If Summary = "1" Then
                Dim ds1 As New DataSet()
                ds1 = Reports.GetGRSA04A(UserID, Summary)
                'Create a report data source for the sales order data
                Dim RDS1 As New ReportDataSource()
                RDS1.Name = "DataSet1"
                RDS1.Value = ds1.Tables(0)
                localReport.DataSources.Add(RDS1)
            End If

            If Patients = "1" Then
                Dim ds2 As New DataSet()
                ds2 = Reports.GetGRSA04B(UserID, Patients)
                'Create a report data source for the sales order data
                Dim RDS2 As New ReportDataSource()
                RDS2.Name = "DataSet2"
                RDS2.Value = ds2.Tables(0)

                localReport.DataSources.Add(RDS2)
            End If

            'localReport.Refresh()
        End If
    End Sub
End Class