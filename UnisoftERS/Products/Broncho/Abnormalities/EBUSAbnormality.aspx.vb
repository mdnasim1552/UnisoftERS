Imports DevExpress.Web.ASPxHtmlEditor.Internal

Public Class EBUSAbnormality
    Inherits SiteDetailsBase
    Public siteId As Integer
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        EBUSAbnormalityDescriptionsRadWindow.VisibleOnPageLoad = False
        siteId = CInt(Request.QueryString("SiteId"))
        Dim dtDu As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_ebus_descriptions_select_by_side")
        Session("AbnormalityDescription") = dtDu
        EbusAbnormalityRepeater.DataSource = dtDu
        EbusAbnormalityRepeater.DataBind()
        If Not IsPostBack Then
        End If
    End Sub
    Protected Sub Page_PreLoad(sender As Object, e As EventArgs) Handles Me.PreLoad
    End Sub

    Protected Sub EnterDetailsRadButton_Click(sender As Object, e As EventArgs)
        'ScriptManager.RegisterStartupScript(Page, Page.GetType(), "NavigatePolypDetails", "NavigatePolypDetails();", True)
        EBUSAbnormalityDescriptionsRadWindow.NavigateUrl = "~/Products/Broncho/Abnormalities/EBUSAbnoDescriptions.aspx?siteid=" + siteId.ToString() & "&EBUSAbnoDescId=0" & "&mode=insert"
        EBUSAbnormalityDescriptionsRadWindow.VisibleOnPageLoad = True
    End Sub

    Protected Sub EbusAbnormalityRepeater_ItemCommand(source As Object, e As RepeaterCommandEventArgs)
        If e.CommandName.ToLower = "remove" AndAlso Not String.IsNullOrWhiteSpace(e.CommandArgument) Then
            Dim abnoid As Integer = CInt(e.CommandArgument)
            Dim deleteStatus As Integer = AbnormalitiesDataAdapter.DeleteAbnormalities(abnoid, siteId)
            'Dim rows = TryCast(Session("AbnormalityDescription"), DataTable).AsEnumerable().Where(Function(x) CInt(x("EBUSAbnoDescId")) <> abnoid)
            'Dim abnodt As DataTable
            'If rows.Any() Then
            '    abnodt = rows.CopyToDataTable()
            'Else
            '    abnodt = Nothing
            'End If
            Dim abnodt = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_ebus_descriptions_select_by_side")
            EbusAbnormalityRepeater.DataSource = abnodt
            EbusAbnormalityRepeater.DataBind()
            Session("AbnormalityDescription") = abnodt
            'dbResult = DataAdapter.LoadIndications(procType).AsEnumerable().Where(Function(x) CInt(x("SectionId")) <> 5).CopyToDataTable()
            'Dim sitePolyps = DirectCast(Session("AbnormalityDescription"), List(Of SitePolyps))
            'sitePolyps = sitePolyps.Where(Function(t) t.PolypId <> CInt(e.CommandArgument)).ToList()
            'PolypDetailsRepeater.DataSource = sitePolyps
            'PolypDetailsRepeater.DataBind()
            'Session("CommonPolypDetails") = sitePolyps
            'Dim x = AbnormalitiesDataAdapter.savepolypDetails(sitePolyps, siteId)
        ElseIf e.CommandName.ToLower = "edit" AndAlso Not String.IsNullOrWhiteSpace(e.CommandArgument) Then
            EBUSAbnormalityDescriptionsRadWindow.NavigateUrl = "~/Products/Broncho/Abnormalities/EBUSAbnoDescriptions.aspx?siteid=" & siteId.ToString() & "&EBUSAbnoDescId=" & CInt(e.CommandArgument) & "&mode=edit"
            EBUSAbnormalityDescriptionsRadWindow.VisibleOnPageLoad = True
            'Dim sitePolyps = DirectCast(Session("AbnormalityDescription"), List(Of SitePolyps))
            'Session("PolypDetailsEdit") = sitePolyps.Where(Function(t) t.PolypId = CInt(e.CommandArgument)).SingleOrDefault()
            'Dim mode = "edit"
            ''ScriptManager.RegisterStartupScript(Page, Page.GetType(), "NavigatePolypDetails", "NavigatePolypDetails();", True)
            'PolypDetailsRadWindow.NavigateUrl = "~/Products/Gastro/Abnormalities/Common/PolypDetails.aspx?siteid=" + siteId.ToString() + "&mode=" + mode
            'PolypDetailsRadWindow.VisibleOnPageLoad = True

        End If
    End Sub

    Protected Sub EbusAbnormalityRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)

    End Sub
End Class