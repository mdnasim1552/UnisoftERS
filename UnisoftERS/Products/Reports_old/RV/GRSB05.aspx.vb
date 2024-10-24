Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.Reporting.WebForms
Public Class GRSB05
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
            localReport.ReportPath = "Products/Reports/RV/GRSB05.rdlc"
            Dim UserId As String = Session("PKUserID").ToString
            Dim AppId As String = ""
            Dim Endoscopist1 As String = Request.QueryString("Endoscopist1")
            Dim Endoscopist2 As String = Request.QueryString("Endoscopist2")
            Dim Sessile As String = Request.QueryString("Sessile")
            Dim SessileN As String = Request.QueryString("SessileN")
            Dim Pedunculated As String = Request.QueryString("Pedunculated")
            Dim PedunculatedN As String = Request.QueryString("PedunculatedN")
            Dim Submucosal As String = Request.QueryString("Submucosal")
            Dim SubmucosalN As String = Request.QueryString("SubmucosalN")
            Dim Villous As String = Request.QueryString("Villous")
            Dim VillousN As String = Request.QueryString("VillousN")
            Dim Ulcerative As String = Request.QueryString("Ulcerative")
            Dim UlcerativeN As String = Request.QueryString("UlcerativeN")
            Dim Stricturing As String = Request.QueryString("Stricturing")
            Dim StricturingN As String = Request.QueryString("StricturingN")
            Dim Polypoidal As String = Request.QueryString("Polypoidal")
            Dim PolypoidalN As String = Request.QueryString("PolypoidalN")
            Dim FromAge As String = Request.QueryString("FromAge")
            Dim ToAge As String = Request.QueryString("ToAge")
            If Reports.ShowOldProcedures = True Then
                AppId = "U"
            End If
            If IsNothing(Endoscopist1) Then Endoscopist1 = "0"
            If IsNothing(Endoscopist2) Then Endoscopist2 = "0"
            If IsNothing(SessileN) Then SessileN = "0"
            If IsNothing(PedunculatedN) Then PedunculatedN = "0"
            If IsNothing(SubmucosalN) Then SubmucosalN = "0"
            If IsNothing(VillousN) Then VillousN = "0"
            If IsNothing(UlcerativeN) Then UlcerativeN = "0"
            If IsNothing(StricturingN) Then StricturingN = "0"
            If IsNothing(PolypoidalN) Then PolypoidalN = "0"
            'Dim p0 As New ReportParameter("UserId", UserID)
            'Dim p1 As New ReportParameter("AppId", AppId)
            'Dim p2 As New ReportParameter("Endoscopist1", Endoscopist1)
            'Dim p3 As New ReportParameter("Endoscopist2", Endoscopist2)
            'Dim p4 As New ReportParameter("Sessile", Sessile)
            'Dim p5 As New ReportParameter("SessileN", SessileN)
            'Dim p6 As New ReportParameter("Pedunculated", Pedunculated)
            'Dim p7 As New ReportParameter("PedunculatedN", PedunculatedN)
            'Dim p8 As New ReportParameter("Submucosal", Submucosal)
            'Dim p9 As New ReportParameter("SubmucosalN", SubmucosalN)
            'Dim p10 As New ReportParameter("Villous", Villous)
            'Dim p11 As New ReportParameter("VillousN", VillousN)
            'Dim p12 As New ReportParameter("Ulcerative", Ulcerative)
            'Dim p13 As New ReportParameter("UlcerativeN", UlcerativeN)
            'Dim p14 As New ReportParameter("Stricturing", Stricturing)
            'Dim p15 As New ReportParameter("StricturingN", StricturingN)
            'Dim p16 As New ReportParameter("Polypoidal", Polypoidal)
            'Dim p17 As New ReportParameter("PolypoidalN", PolypoidalN)
            'Dim p18 As New ReportParameter("FromAge", FromAge)
            'Dim p19 As New ReportParameter("ToAge", ToAge)
            'localReport.SetParameters(New ReportParameter() {p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19})
            Dim ds As New DataSet()
            ds = Reports.GetGRSB05(UserId, AppId, Endoscopist1, Endoscopist2, Sessile, SessileN, Pedunculated, PedunculatedN, Submucosal, SubmucosalN, Villous, VillousN, Ulcerative, UlcerativeN, Stricturing, StricturingN, Polypoidal, PolypoidalN, FromAge, ToAge)
            'Create a report data source for the sales order data
            Dim RDS As New ReportDataSource()
            RDS.Name = "DataSet1"
            RDS.Value = ds.Tables(0)

            localReport.DataSources.Add(RDS)
        End If
    End Sub

End Class