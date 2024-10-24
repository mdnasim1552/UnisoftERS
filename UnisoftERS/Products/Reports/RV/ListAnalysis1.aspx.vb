Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class ListAnalysis1
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub
    Protected Sub Page_Tnit(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        If IsNothing(Session("PKUserId")) Then
            Response.Redirect("/", False)
        End If

        If Not Page.IsPostBack Then
            Dim analysisReport As LocalReport
            'Set the processing mode for the ReportViewer to Local
            analysisReport = RV.LocalReport

            'localReport.ReportPath = "Products/Reports/RV/ListAnalysis-1A.rdlc"
            'localReport.DataSources.Clear()

            Dim UserID As String = Session("PKUserID").ToString
            Dim IncludeIndications As String = Reports.IncludeIndications
            Dim IncludeTherapeutics As String = Reports.IncludeTherapeutics
            Dim DailyTotalsConsultant As String = Reports.DailyTotals1
            Dim DailyTotals As String = Reports.DailyTotals2
            Dim GrandTotal As String = Reports.DailyTotals3

            Dim paramUserId As New ReportParameter("UserID", UserID)
            'Dim p1 As New ReportParameter("ListOfPatients", "1")
            'Dim p2 As New ReportParameter("FromAge", Reports.FromAge)
            'Dim p3 As New ReportParameter("ToAge", Reports.ToAge)
            Dim paramIncludeIndications As New ReportParameter("IncludeIndications", IncludeIndications)
            Dim paramIncludeTherapeutics As New ReportParameter("IncludeTherapeutics", IncludeTherapeutics)
            'Dim p6 As New ReportParameter("RadioButtonNHS", Reports.CNNvsNHS)
            Dim paramDailyTotalsConsultant As New ReportParameter("DailyTotalsConsultant", DailyTotalsConsultant)
            Dim paramDailyTotals As New ReportParameter("DailyTotals", DailyTotals)
            Dim paramGrandTotal As New ReportParameter("GrandTotal", GrandTotal)

            Dim reportSubHeader As String
            reportSubHeader = String.Format("Covering: from {0} to {1}, {2} consultants", Reporting.FromDate, Reporting.ToDate, IIf(Reporting.TypeOfEndoscopist = "0", "All", "selected"))
            Dim paramSubHeader As New ReportParameter("SubHeader", reportSubHeader)
            Dim paramConsultantTypeId As New ReportParameter("ConsultantTypeId", Reporting.TypeOfConsultant)
            'Dim p10 As New ReportParameter("Summary", "0")
            'Dim p11 As New ReportParameter("DiagVsThera", "0")
            'Dim p12 As New ReportParameter("DNA", "0")
            'Dim p13 As New ReportParameter("Priority", "")
            'Dim p14 As New ReportParameter("OrderBy", Reports.ReportOrder)
            'Dim p15 As New ReportParameter("PatientStatusId", Reports.PatientStatusId)
            'Dim p16 As New ReportParameter("PatientTypeId", Reports.PatientTypeId)
            'localReport.SetParameters(New ReportParameter() {p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16})

            'localReport.SetParameters(New ReportParameter() {p0, p4, p5, p7, p8, p9})

            'Dim ds1 As New DataSet()
            'ds1 = Reports.GetListAnalysis1(UserID, IncludeIndications, IncludeTherapeutics)
            ''Create a report data source for the sales order data
            'Dim RDS1 As New ReportDataSource()
            'RDS1.Name = "DataSet1"
            'If Not IsNothing(ds1) Then
            '    RDS1.Value = ds1.Tables(0)
            '    localReport.DataSources.Add(RDS1)
            'Else
            '    RV.Visible = False
            'End If

            Try
                With analysisReport
                    '.ProcessingMode = ProcessingMode.Local
                    .ReportPath = "Products/Reports/RV/ListAnalysis-1A.rdlc"
                    .DataSources.Clear()

                    .DataSources.Add(New ReportDataSource("DataSet1", Reports.GetListAnalysis1(UserID, IncludeIndications, IncludeTherapeutics)))

                    '### Pass the Param again; These are 'Report Only'- not to be processed in StoredProc... Something like Show/Hide options.. Yes- for 'Cosmetic Surgery'
                    .SetParameters(New ReportParameter() {paramUserId, paramIncludeIndications, paramIncludeTherapeutics, paramDailyTotalsConsultant, paramDailyTotals, paramGrandTotal, paramConsultantTypeId, paramSubHeader})

                    If IsNothing(.DataSources(0).Value) Then
                        RV.Visible = False
                    Else
                        .Refresh()
                    End If
                End With
            Catch ex As Exception
                '#### Log the Error!
            End Try

            'localReport.Refresh()
        End If
    End Sub

End Class