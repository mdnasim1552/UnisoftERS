Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_OGD_HiatusHernia
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtHh As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_hiatus_hernia_select")
            If dtHh.Rows.Count > 0 Then
                PopulateData(dtHh.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drHh As DataRow)
        NoneCheckBox.Checked = CBool(drHh("None"))
        SlidingCheckBox.Checked = CBool(drHh("Sliding"))
        ParaoesophagealCheckBox.Checked = CBool(drHh("Paraoesophageal"))
        If Not IsDBNull(drHh("SlidingLength")) Then SlidingLengthTextBox.Value = CDbl(drHh("SlidingLength"))
        If Not IsDBNull(drHh("ParaLength")) Then ParaLengthTextBox.Value = CDbl(drHh("ParaLength"))

    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            AbnormalitiesDataAdapter.SaveHiatusHerniaData(
                siteId,
                NoneCheckBox.Checked,
                SlidingCheckBox.Checked,
                ParaoesophagealCheckBox.Checked,
                SlidingLengthTextBox.Value,
                ParaLengthTextBox.Value)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If


        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Hiatus Hernia.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
