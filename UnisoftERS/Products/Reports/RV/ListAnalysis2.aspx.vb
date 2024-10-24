Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class ListAnalysis2
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub
    Protected Sub Page_Tnit(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        If IsNothing(Session("PKUserId")) Then
            Response.Redirect("/", False)
        End If
        If Not Page.IsPostBack Then
            'Set the processing mode for the ReportViewer to Local
            RV.ProcessingMode = ProcessingMode.Local
            Dim localReport As LocalReport
            localReport = RV.LocalReport
            localReport.ReportPath = "Products/Reports/RV/listAnalysis2.rdlc"

            Dim UserID As String = Session("PKUserID").ToString
            Dim DiagVsThera As String = Reports.DiagVsthera

            Dim p0 As New ReportParameter("UserID", UserID)
            'Dim p1 As New ReportParameter("ListOfPatients", "1")
            'Dim p2 As New ReportParameter("FromAge", Reports.FromAge)
            'Dim p3 As New ReportParameter("ToAge", Reports.ToAge)
            'Dim p4 As New ReportParameter("IncludeTherapeutics", IncludeTherapeutics)
            'Dim p5 As New ReportParameter("IncludeTherapeutics", IncludeTherapeutics)
            'Dim p6 As New ReportParameter("RadioButtonNHS", Reports.CNNvsNHS)
            'Dim p7 As New ReportParameter("DailyTotalsConsultant", "0")
            'Dim p8 As New ReportParameter("DailyTotals", "0")
            'Dim p9 As New ReportParameter("GrandTotal", "0")
            'Dim p10 As New ReportParameter("Summary", "0")
            Dim p11 As New ReportParameter("DiagVsThera", DiagVsThera)
            'Dim p12 As New ReportParameter("DNA", "0")
            'Dim p13 As New ReportParameter("Priority", "")
            'Dim p14 As New ReportParameter("OrderBy", Reports.ReportOrder)
            'Dim p15 As New ReportParameter("PatientStatusId", Reports.PatientStatusId)
            'Dim p16 As New ReportParameter("PatientTypeId", Reports.PatientTypeId)
            'localReport.SetParameters(New ReportParameter() {p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16})
            localReport.SetParameters(New ReportParameter() {p0, p11})

            Dim ds1 As New DataSet()
            ds1 = Reports.GetListAnalysis2(UserID, DiagVsThera)
            Dim RDS1 As New ReportDataSource()
            RDS1.Name = "DataSet1"
            If Not IsNothing(ds1) Then
                RDS1.Value = ds1.Tables(0)
                localReport.DataSources.Add(RDS1)
            Else
                RV.Visible = False
            End If

            'localReport.Refresh()
        End If
    End Sub

End Class