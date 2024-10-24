Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class GRSC08
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
            'Try
            '    Dim p1 As New ReportParameter("UserID", Session("PKUserID").ToString)
            '    Dim p2 As New ReportParameter("UnitAsAWhole", Request.QueryString("UnitAsAWhole"))
            '    Dim p3 As New ReportParameter("ListPatients", Request.QueryString("ListPatients"))
            '    localReport.SetParameters(New ReportParameter() {p1, p2, p3})
            'Catch ex As Exception
            '    MsgBox(ex.Message)
            'End Try
            localReport.ReportPath = "Products/Reports/RV/GRSC08.rdlc"
            Dim ds As New DataSet()

            Dim UserID As String = Session("PKUserID").ToString
            Dim UnitAsAWhole As String = Request.QueryString("UnitAsAWhole")
            Dim ListPatients As String = Request.QueryString("ListPatients")

            ds = Reports.GetGRSC08(UserID, UnitAsAWhole, ListPatients)

            'Create a report data source for the sales order data
            Dim RDS As New ReportDataSource()
            RDS.Name = "DataSet1"
            RDS.Value = ds.Tables(0)


            localReport.DataSources.Add(RDS)
        End If
    End Sub

End Class