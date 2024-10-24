Imports Telerik.Web.UI
Imports Telerik
Imports Telerik.Charting
Imports System.Drawing
Public Class OGDDrugs
    Inherits System.Web.UI.Page
    Public Shared ReadOnly Property ConnectionStr() As String
        Get
            Return DataAccess.ConnectionStr
        End Get
    End Property
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If IsNothing(Session("PKUserId")) Then
            Response.Redirect("/")
        End If
    End Sub
    Protected Sub Page_Init(sender As Object, e As System.EventArgs)
        'Dim ds As New Charts
        'RadHtmlChartGroupDataSource.GroupDataSource(RadHtmlChartW, ds.GetOGDDrugs, "AgeLimit", "Dose", "DrugName", "Mean premedication dosage depending of the age limit")
    End Sub
End Class