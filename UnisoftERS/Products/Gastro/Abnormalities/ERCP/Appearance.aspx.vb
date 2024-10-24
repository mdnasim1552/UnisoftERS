Imports Telerik.Web.UI
Imports System.Data.SqlClient

Partial Class Products_Gastro_Abnormalities_ERCP_Appearance
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_ERCP_Appearance_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtAp As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_appearance_select")
            If dtAp.Rows.Count > 0 Then
                PopulateData(dtAp.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drAp As DataRow)
        NormalCheckBox.Checked = CBool(drAp("Normal"))
        BleedingCheckBox.Checked = CBool(drAp("Bleeding"))
        SuprapapillaryCheckBox.Checked = CBool(drAp("Suprapapillary"))
        ImpactedStoneCheckBox.Checked = CBool(drAp("ImpactedStone"))
        PatulousCheckBox.Checked = CBool(drAp("Patulous"))
        InflamedCheckBox.Checked = CBool(drAp("Inflamed"))
        OedematousCheckBox.Checked = CBool(drAp("Oedematous"))
        PusExudingCheckBox.Checked = CBool(drAp("PusExuding"))
        ReddenedCheckBox.Checked = CBool(drAp("Reddened"))
        TumourCheckBox.Checked = CBool(drAp("Tumour"))
        OcclusionChekBox.Checked = CBool(drAp("Occlusion"))
        BiliaryLeakCheckBox.Checked = CBool(drAp("BiliaryLeak"))
        PreviousSurgeryCheckBox.Checked = CBool(drAp("PreviousSurgery"))
        OtherCheckBox.Checked = CBool(drAp("Other"))
        PapillaryStenosisCheckBox.Checked = CBool(drAp("PapillaryStenosis"))
        OtherTextBox.Text = CStr(drAp("OtherText"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            AbnormalitiesDataAdapter.SaveAppearanceData(
                siteId,
                NormalCheckBox.Checked,
                BleedingCheckBox.Checked,
                SuprapapillaryCheckBox.Checked,
                ImpactedStoneCheckBox.Checked,
                PatulousCheckBox.Checked,
                InflamedCheckBox.Checked,
                OedematousCheckBox.Checked,
                PusExudingCheckBox.Checked,
                ReddenedCheckBox.Checked,
                TumourCheckBox.Checked,
                OcclusionChekBox.Checked,
                BiliaryLeakCheckBox.Checked,
                PreviousSurgeryCheckBox.Checked,
                PapillaryStenosisCheckBox.Checked,
                OtherCheckBox.Checked,
                OtherTextBox.Text)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            'If saveAndClose Then
            '    ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            'End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving ERCP Abnormalities - Appearance.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click

    End Sub
End Class