Imports Telerik.Web.UI


Partial Class Products_Gastro_Abnormalities_GastricUlcer
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Products_Gastro_Abnormalities_GastricUlcer_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtGU As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_gastric_ulcer_select")
            If dtGU.Rows.Count > 0 Then
                PopulateData(dtGU.Rows(0))
            End If

            Dim sPreviousGastricUlcer As String = AbnormalitiesDataAdapter.GetPreviousGastricUlcer(CInt(Session(Constants.SESSION_PROCEDURE_ID)), False)

            If sPreviousGastricUlcer <> "" Then 'Patient had previous gastric ulcer
                PrevUlcerLabel.Visible = True
                PrevUlcerLabel.Text = "Previous gastric ulcer recorded in " + sPreviousGastricUlcer + "<br/>Please record the follow up."
            Else
                divPrevUlcer.Visible = False
                NotHealedCheckBox.Visible = False
                HealedCheckBox.Visible = False
                NotHealedFieldset.Visible = False
            End If
        End If
    End Sub

    Private Sub PopulateData(drGU As DataRow)
        NoneCheckBox.Checked = CBool(drGU("None"))
        UlcerCheckBox.Checked = CBool(drGU("Ulcer"))
        HealingUlcerCheckBox.Checked = CBool(drGU("HealingUlcer"))

        TypeRadioButtonList.SelectedValue = CInt(drGU("UlcerType"))
        If Not IsDBNull(drGU("UlcerNumber")) Then UlcerNoRadNumericTextBox.Value = drGU("UlcerNumber").ToString()
        If Not IsDBNull(drGU("UlcerLargestDiameter")) Then UlcerDiameterRadNumericTextBox.Value = drGU("UlcerLargestDiameter").ToString()
        ActiveBleedingCheckBox.Checked = CBool(drGU("UlcerActiveBleeding"))
        ActiveBleedingRadioButtonList.SelectedValue = CInt(drGU("UlcerActiveBleedingType"))
        FreshClotCheckBox.Checked = CBool(drGU("UlcerClotInBase"))
        VisibleVesselCheckBox.Checked = CBool(drGU("UlcerVisibleVessel"))
        VisibleVesselRadioButtonList.SelectedValue = CInt(drGU("UlcerVisibleVesselType"))
        OverlyingCheckBox.Checked = CBool(drGU("UlcerOldBlood"))
        MalignantCheckBox.Checked = CBool(drGU("UlcerMalignantAppearance"))
        PerforationCheckBox.Checked = CBool(drGU("UlcerPerforation"))
        HealingUlcerRadioButtonList.SelectedValue = CInt(drGU("HealingUlcerType"))

        NotHealedCheckBox.Checked = CBool(drGU("NotHealed"))
        NotHealedRemarksTextBox.Text = CStr(drGU("NotHealedText"))
        HealedCheckBox.Checked = CBool(drGU("HealedUlcer"))
    End Sub

    Private Sub SetControls()
        If NoneCheckBox.Checked Then
            UlcerCheckBox.Enabled = False
            'UlcerFieldset.Style.Add("display", "none")
            HealingUlcerCheckBox.Enabled = False
            'HealingUlcerFieldset.Style.Add("display", "none")
            GastricUlcerMultiPage.Style.Add("display", "none")
        Else
            UlcerCheckBox.Enabled = True
            HealingUlcerCheckBox.Enabled = True
        End If

        'UlcerFieldset.Visible = UlcerCheckBox.Checked
        'HealingUlcerFieldset.Visible = HealingUlcerCheckBox.Checked
        ActiveBleedingRadioButtonListDiv.Visible = ActiveBleedingCheckBox.Checked
        VisibleVesselRadioButtonList.Visible = VisibleVesselCheckBox.Checked
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            AbnormalitiesDataAdapter.SaveGastricUlcerData(
                siteId,
                NoneCheckBox.Checked,
                UlcerCheckBox.Checked,
                HealingUlcerCheckBox.Checked,
                Utilities.GetRadioValue(TypeRadioButtonList),
                UlcerNoRadNumericTextBox.Value,
                UlcerDiameterRadNumericTextBox.Value,
                ActiveBleedingCheckBox.Checked,
                Utilities.GetRadioValue(ActiveBleedingRadioButtonList),
                FreshClotCheckBox.Checked,
                VisibleVesselCheckBox.Checked,
                Utilities.GetRadioValue(VisibleVesselRadioButtonList),
                OverlyingCheckBox.Checked,
                MalignantCheckBox.Checked,
                PerforationCheckBox.Checked,
                Utilities.GetRadioValue(HealingUlcerRadioButtonList),
                NotHealedCheckBox.Checked,
                NotHealedRemarksTextBox.Text.Trim(),
                HealedCheckBox.Checked)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If


        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Gastric Ulcer.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
