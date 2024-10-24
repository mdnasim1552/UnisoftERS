Imports Telerik.Web.UI

Public Class DrillDown
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim da As DataAccess = New DataAccess()
            Dim ConsultantId As Integer
            Integer.TryParse(Request.QueryString("consultantId"), ConsultantId)
            Dim procedureType As String = Request.QueryString("procType")
            Dim dt = da.GetJagReportDrillDown(procedureType, ConsultantId)
            RadGrid1.DataSource = dt
        End If
    End Sub
End Class