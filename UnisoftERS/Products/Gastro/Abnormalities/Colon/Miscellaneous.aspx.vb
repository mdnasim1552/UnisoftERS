Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_Colon_Miscellaneous
    Inherits SiteDetailsBase

    Private Shared siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_Colon_Miscellaneous_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtCa As DataTable = AbnormalitiesColonDataAdapter.GetMiscellaneousData(siteId)
            If dtCa.Rows.Count > 0 Then
                PopulateData(dtCa.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drCa As DataRow)
        NormalCheckBox.Checked = CBool(drCa("None"))
        CrohnCheckBox.Checked = CBool(drCa("Crohn"))
        FistulaCheckBox.Checked = CBool(drCa("Fistula"))
        ForeignBodyCheckBox.Checked = CBool(drCa("ForeignBody"))
        LipomaCheckBox.Checked = CBool(drCa("Lipoma"))
        MelanosisCheckBox.Checked = CBool(drCa("Melanosis"))
        ParasitesCheckBox.Checked = CBool(drCa("Parasites"))
        PneumatosisColiCheckBox.Checked = CBool(drCa("PneumatosisColi"))
        PolyposisSyndromeCheckBox.Checked = CBool(drCa("PolyposisSyndrome"))
        PostoperativeAppearanceCheckBox.Checked = CBool(drCa("PostoperativeAppearance"))
        PseudoobstructionCheckBox.Checked = CBool(drCa("PseudoObstruction"))
        VolvulusCheckBox.Checked = CBool(drCa("Volvulus"))
        AmpullaryAdenomaCheckBox.Checked = CBool(drCa("AmpullaryAdenoma"))
        PouchitisCheckBox.Checked = CBool(drCa("Pouchitis"))
        StentInSituCheckBox.Checked = CBool(drCa("StentInSitu"))
        PEGInSituCheckBox.Checked = CBool(drCa("PEGInSitu"))
        StentOcclusionCheckBox.Checked = CBool(drCa("StentOcclusion"))
        MiscOtherCheckBox.Checked = CBool(Not String.IsNullOrEmpty(drCa("Other")))
        MiscOtherTextBox.Text = drCa("Other")
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            AbnormalitiesColonDataAdapter.SaveMiscellaneousData(
                siteId,
                NormalCheckBox.Checked,
                CrohnCheckBox.Checked,
                FistulaCheckBox.Checked,
                ForeignBodyCheckBox.Checked,
                LipomaCheckBox.Checked,
                MelanosisCheckBox.Checked,
                ParasitesCheckBox.Checked,
                PneumatosisColiCheckBox.Checked,
                PolyposisSyndromeCheckBox.Checked,
                PostoperativeAppearanceCheckBox.Checked,
                PseudoobstructionCheckBox.Checked,
                PouchitisCheckBox.Checked,
                VolvulusCheckBox.Checked,
                AmpullaryAdenomaCheckBox.Checked,
                StentInSituCheckBox.Checked,
                PEGInSituCheckBox.Checked,
                StentOcclusionCheckBox.Checked,
                If(MiscOtherCheckBox.Checked, MiscOtherTextBox.Text, ""))

            If saveAndClose Then
                'Utilities.SetNotificationStyle(RadNotification1)
                'RadNotification1.Show()
                'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Colon Abnormalities - Miscellaneous.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class
