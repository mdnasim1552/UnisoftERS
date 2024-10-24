Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class GRSA05A
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

            localReport.ReportPath = "Products/Reports/RV/GRSA05A.rdlc"

            Dim ds As New DataSet()

            Dim UserID As String = Session("PKUserID").ToString
            Dim UnitAsAWhole As String = Request.QueryString("UnitAsAWhole")
            ds = Reports.GetGRSA05A(UserID, UnitAsAWhole)

            'Create a report data source for the sales order data
            Dim RDS As New ReportDataSource()
            RDS.Name = "DataSet1"
            RDS.Value = ds.Tables(0)

            localReport.DataSources.Add(RDS)
        End If
    End Sub

End Class