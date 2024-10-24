Imports Azure.Core
Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_Colon_Haemorrhage
    Inherits SiteDetailsBase

    Private Shared siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_Colon_Haemorrhage_Load(sender As Object, e As EventArgs) Handles Me.Load, ArtificialCheckBox.CheckedChanged, LesionsCheckBox.CheckedChanged, MelaenaCheckBox.CheckedChanged, MucosalCheckBox.CheckedChanged, PurpuraCheckBox.CheckedChanged, TransportedCheckBox.CheckedChanged
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            LoadPage()
        End If
    End Sub

    Private Sub LoadPage()
        Dim dtMu As DataTable = AbnormalitiesColonDataAdapter.GetHaemorrhageData(siteId)
        If dtMu.Rows.Count > 0 Then
            PopulateData(dtMu.Rows(0))
        End If
    End Sub
    Private Sub PopulateData(drMu As DataRow)
        NoneCheckBox.Checked = CBool(drMu("None"))
        ArtificialCheckBox.Checked = CBool(drMu("Artificial"))
        LesionsCheckBox.Checked = CBool(drMu("Lesions"))
        MelaenaCheckBox.Checked = CBool(drMu("Melaena"))
        MucosalCheckBox.Checked = CBool(drMu("Mucosal"))
        PurpuraCheckBox.Checked = CBool(drMu("Purpura"))
        TransportedCheckBox.Checked = CBool(drMu("Transported"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            AbnormalitiesColonDataAdapter.SaveHaemorrhageData(
                    siteId,
                    NoneCheckBox.Checked,
                    ArtificialCheckBox.Checked,
                    LesionsCheckBox.Checked,
                    MelaenaCheckBox.Checked,
                    MucosalCheckBox.Checked,
                    PurpuraCheckBox.Checked,
                    TransportedCheckBox.Checked)
            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Colon Abnormalities - Haemorrhage.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
