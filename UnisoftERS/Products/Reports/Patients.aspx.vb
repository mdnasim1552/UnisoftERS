Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class Products_Reports_Patients
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If IsNothing(Session("PKUserId")) Then
            Response.Redirect("/", False)
        End If
        If Not Page.IsPostBack Then
            'Set the processing mode for the ReportViewer to Local
            RV.ProcessingMode = ProcessingMode.Local

            Dim localReport As LocalReport
            localReport = RV.LocalReport

            localReport.ReportPath = "Products/Reports/Patients.rdlc"

            Dim dt As New DataTable()

            dt = Reports.GetPatients()

            'Create a report data source for the sales order data
            Dim RDS As New ReportDataSource()
            RDS.Name = "DataSet1"
            RDS.Value = dt

            localReport.DataSources.Add(RDS)
        End If
    End Sub

End Class