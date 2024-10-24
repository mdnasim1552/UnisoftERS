Imports Telerik.Web.UI
Imports System.Data.SqlClient

Partial Class Products_Gastro_Abnormalities_ERCP_Tumour
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_ERCP_Tumour_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtTu As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_tumour_ercp_select")
            If dtTu.Rows.Count > 0 Then
                PopulateData(dtTu.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drTu As DataRow)
        NoneCheckBox.Checked = CBool(drTu("None"))
        FirmCheckBox.Checked = CBool(drTu("Firm"))
        FriableCheckBox.Checked = CBool(drTu("Friable"))
        UlceratedCheckBox.Checked = CBool(drTu("Ulcerated"))
        VillousCheckBox.Checked = CBool(drTu("Villous"))
        PolypoidCheckBox.Checked = CBool(drTu("Polypoid"))
        SubMucosalCheckBox.Checked = CBool(drTu("SubMucosal"))
        If Not IsDBNull(drTu("Size")) Then SizeNumericTextBox.Value = CInt(drTu("Size"))
        OcclusionChekBox.Checked = CBool(drTu("Occlusion"))
        BiliaryLeakCheckBox.Checked = CBool(drTu("BiliaryLeak"))
        PreviousSurgeryCheckBox.Checked = CBool(drTu("PreviousSurgery"))
        IPMTCheckBox.Checked = CBool(drTu("IPMT"))

        If Not IsDBNull(drTu("Other")) AndAlso Not String.IsNullOrEmpty(drTu("Other")) Then
            OtherCheckBox.Checked = True
            OtherTextBox.Text = drTu("Other")
        End If

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            AbnormalitiesDataAdapter.SaveTumourData(
                siteId,
                NoneCheckBox.Checked,
                FirmCheckBox.Checked,
                FriableCheckBox.Checked,
                UlceratedCheckBox.Checked,
                VillousCheckBox.Checked,
                PolypoidCheckBox.Checked,
                SubMucosalCheckBox.Checked,
                SizeNumericTextBox.Value,
                OcclusionChekBox.Checked,
                BiliaryLeakCheckBox.Checked,
                PreviousSurgeryCheckBox.Checked,
                IPMTCheckBox.Checked,
                OtherTextBox.Text)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            'If saveAndClose Then
            '    ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            'End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving ERCP Abnormalities - Tumour.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click

    End Sub
End Class