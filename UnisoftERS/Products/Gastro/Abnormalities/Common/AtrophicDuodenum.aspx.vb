Imports Telerik.Web.UI


Partial Class Products_Gastro_Abnormalities_Common_AtrophicDuodenum
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtVa As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_atrophic_select")
            If dtVa.Rows.Count > 0 Then
                PopulateData(dtVa.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drVa As DataRow)
        NoneCheckBox.Checked = CBool(drVa("None"))
        TypeRadioButtonList.Text = CInt(drVa("Type"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            AbnormalitiesDataAdapter.SaveAtrophicDuodenumData(
                siteId,
                NoneCheckBox.Checked,
                Utilities.GetRadioValue(TypeRadioButtonList))

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            'If saveAndClose Then
            '    ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            'End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Atrophic Duodenum.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
