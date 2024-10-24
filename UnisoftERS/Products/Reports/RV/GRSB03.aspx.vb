Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class GRSB03
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
            localReport.ReportPath = "Products/Reports/RV/GRSB03.rdlc"
            Dim UserID As String = Session("PKUserID").ToString
            Dim AppId As String = ""
            Dim Endoscopist1 As String = Request.QueryString("Endoscopist1")
            Dim Endoscopist2 As String = Request.QueryString("Endoscopist2")
            Dim FromAge As String = Request.QueryString("FromAge")
            Dim ToAge As String = Request.QueryString("ToAge")
            If Reports.ShowOldProcedures = True Then
                AppId = "U"
            End If
            Dim ds As New DataSet()
            ds = Reports.GetGRSB03(UserID, Endoscopist1, Endoscopist2, FromAge, ToAge, AppId)
            'Create a report data source for the sales order data
            Dim RDS As New ReportDataSource()
            RDS.Name = "DataSet1"
            RDS.Value = ds.Tables(0)

            localReport.DataSources.Add(RDS)
        End If
    End Sub

End Class