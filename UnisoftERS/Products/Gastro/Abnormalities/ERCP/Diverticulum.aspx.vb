Imports Telerik.Web.UI
Imports System.Data.SqlClient

Partial Class Products_Gastro_Abnormalities_ERCP_Diverticulum
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_ERCP_Diverticulum_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtDi As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_diverticulum_ercp_select")
            If dtDi.Rows.Count > 0 Then
                PopulateData(dtDi.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drDi As DataRow)
        NoneCheckBox.Checked = CBool(drDi("Normal"))

        If Not IsDBNull(drDi("Quantity")) Then QuantityNumericTextBox.Value = CInt(drDi("Quantity"))
        If Not IsDBNull(drDi("SizeOfLargest")) Then SizeOfLargestNumericTextBox.Value = CInt(drDi("SizeOfLargest"))
        If Not IsDBNull(drDi("Proximity")) Then ProximityRadioButtonList.SelectedValue = CInt(drDi("Proximity"))
        OcclusionChekBox.Checked = CBool(drDi("Occlusion"))
        BiliaryLeakCheckBox.Checked = CBool(drDi("BiliaryLeak"))
        PreviousSurgeryCheckBox.Checked = CBool(drDi("PreviousSurgery"))
        If Not IsDBNull(drDi("Other")) AndAlso Not String.IsNullOrWhiteSpace(drDi("Other")) Then
            OtherCheckBox.Checked = True
            OtherTextBox.Text = drDi("Other")
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
            AbnormalitiesDataAdapter.SaveDiverticulumData(
                siteId,
                NoneCheckBox.Checked,
                QuantityNumericTextBox.Value,
                SizeOfLargestNumericTextBox.Value,
                Utilities.GetRadioValue(ProximityRadioButtonList),
                OcclusionChekBox.Checked,
                BiliaryLeakCheckBox.Checked,
                PreviousSurgeryCheckBox.Checked,
                OtherTextBox.Text)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            'If saveAndClose Then
            '    ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            'End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving ERCP Abnormalities - Diverticulum.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click

    End Sub
End Class