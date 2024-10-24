Imports Telerik.Web.UI

Partial Class Products_Common_SiteSummary
    Inherits SiteDetailsBase

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        abnorHeader.InnerText = "Site summary: Site " + Request.QueryString("SiteName")
        Dim siteId As Integer = CInt(Request.QueryString("SiteId"))
        loadSiteSummary(siteId)
    End Sub
    Protected Sub loadSiteSummary(siteID As Integer)
        Dim ds As New DataAccess
        SiteSummaryLabel.Text = ds.GetReportSummaryWithHyperlinks(CStr(Session(Constants.SESSION_PROCEDURE_ID)), siteID).Replace("href=""#""", "style=""cursor: pointer;""")
    End Sub
End Class
