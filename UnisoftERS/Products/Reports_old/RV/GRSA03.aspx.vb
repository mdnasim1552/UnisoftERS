Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class GRSA032
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

            localReport.ReportPath = "Products/Reports/RV/GRSA03.rdlc"

            Dim ds As New DataSet()
            Dim UserID As String = Session("PKUserID").ToString
            Dim Endoscopist1 As String = Request.QueryString("Endoscopist1")
            Dim Endoscopist2 As String = Request.QueryString("Endoscopist2")
            Dim FromAge As String = Request.QueryString("FromAge")
            Dim ToAge As String = Request.QueryString("ToAge")
            Dim CountOfProcedures As String = Request.QueryString("CountOfProcedures")
            Dim ListOfPatients As String = Request.QueryString("ListOfPatients")
            Dim OesophagealStent As String = Request.QueryString("OesophagealStent")
            Dim DuodenalStent As String = Request.QueryString("DuodenalStent")
            Dim UnitAsAWhole As String = Request.QueryString("UnitAsAWhole")
            Dim ColonicStent As String = Request.QueryString("ColonicStent")
            Dim PEG As String = Request.QueryString("PEG")
            Dim PEJ As String = Request.QueryString("PEJ")

            ds = Reports.GetGRSA03(UserID, Endoscopist1, Endoscopist2, FromAge, ToAge, CountOfProcedures, ListOfPatients, OesophagealStent, DuodenalStent, UnitAsAWhole, ColonicStent, PEG, PEJ)

            'Create a report data source for the sales order data
            Dim RDS As New ReportDataSource()
            RDS.Name = "DataSet1"
            RDS.Value = ds.Tables(0)

            localReport.DataSources.Add(RDS)
        End If
    End Sub

End Class