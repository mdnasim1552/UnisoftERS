Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class GRSA01
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub
    Protected Sub Page_Tnit(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        If IsNothing(Session("PKUserId")) Then
            Response.Redirect("/")
        End If
        If Not Page.IsPostBack Then
            'Set the processing mode for the ReportViewer to Local
            LoadReportPreviewWithData()


        End If
    End Sub

    Private Sub LoadReportPreviewWithData()
        RV.ProcessingMode = ProcessingMode.Local

        Dim localReport As LocalReport
        localReport = RV.LocalReport

        localReport.ReportPath = "Products/Reports/RV/GRSA01.rdlc"
        localReport.DataSources.Clear()

        'Dim UserID As String = Session("PKUserID").ToString
        Dim paramDateFrom As Date = Reporting.FromDate
        Dim paramDateTo As Date = Reporting.ToDate

        Dim GRS01_Diarrhoea As New Report_GRS01() '(paramDateFrom, paramDateTo)
        GRS01_Diarrhoea.StartDate = paramDateFrom
        GRS01_Diarrhoea.EndDate = paramDateTo

        Try
            'localReport.DataSources.Add(New ReportDataSource("DataSet1", Reports.GetGRSA01(paramDateFrom, paramDateTo)))
            localReport.DataSources.Add(New ReportDataSource("DataSet1", GetReportData.Result(GRS01_Diarrhoea)))

            '### Pass the Param again; Its a bit double work! but simpler! Simple <> Easy!
            localReport.SetParameters(New ReportParameter() {
                                                                New ReportParameter("DateFrom", paramDateFrom) _
                                                              , New ReportParameter("DateTo", paramDateTo)})
            localReport.Refresh()
        Catch ex As Exception
            '#### Log the Error!
        End Try
    End Sub

End Class