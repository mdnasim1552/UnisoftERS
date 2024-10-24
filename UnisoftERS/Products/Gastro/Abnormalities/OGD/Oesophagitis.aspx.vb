Imports Telerik.Web.UI

Partial Class Products_Gastro_Oesophagitis_OGDOesophagitis
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Products_Gastro_Oesophagitis_OGDOesophagitis_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))
        If Not Page.IsPostBack Then
            SetControls()
            Dim dtOe As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_oesophagitis_select")
            If dtOe.Rows.Count > 0 Then
                PopulateData(dtOe.Rows(0))
            End If
        Else
            Dim val = If(hfLAClassification.Value = "", 0, hfLAClassification.Value)
            SetLAClassification(val)
        End If
    End Sub

    Private Sub PopulateData(dtOe As DataRow)

        Dim iLAClassification As Integer = 0

        NoneCheckBox.Checked = CBool(dtOe("None"))

        LA_RefluxCheckBox.Checked = CBool(dtOe("Reflux"))
        LA_ActiveBleedingCheckBox.Checked = CBool(dtOe("ActiveBleeding"))
        LA_ShortOesophagusCheckBox.Checked = CBool(dtOe("ShortOesophagus"))
        'LA_UlcerCheckBox.Checked = CBool(dtOe("Ulcer"))
        'LA_StrictureCheckBox.Checked = CBool(dtOe("Stricture"))
        SetLAClassification(CInt(dtOe("LAClassification")))


        'Other_CheckBox.Checked = CBool(dtOe("Other"))
        Suspected_Candida_CheckBox.Checked = CBool(dtOe("SuspectedCandida"))
        Caustic_Ingestion_CheckBox.Checked = CBool(dtOe("CausticIngestion"))
        Suspected_Herpes_CheckBox.Checked = CBool(dtOe("SuspectedHerpes"))
        Corrosive_Burns_CheckBox.Checked = CBool(dtOe("CorrosiveBurns"))
        Eosinophilic_CheckBox.Checked = CBool(dtOe("Eosinophilic"))
        Other_Other_CheckBox.Checked = CBool(dtOe("OtherTypeOther"))
        OtherTextBox.Text = dtOe("OtherTypeOtherDesc")
        Suspected_Candida_Other_ComboBox.SelectedValue = CInt(dtOe("SuspectedCandidaSeverity"))
        Caustic_Ingestion_Other_ComboBox.SelectedValue = CInt(dtOe("CausticIngestionSeverity"))
        Suspected_Herpes_Other_ComboBox.SelectedValue = CInt(dtOe("SuspectedHerpesSeverity"))
        Corrosive_Burns_Other_ComboBox.SelectedValue = CInt(dtOe("CorrosiveBurnsSeverity"))
        Eosinophilic_Other_ComboBox.SelectedValue = CInt(dtOe("EosinophilicSeverity"))
        ' added by ferdowsi ,  TFS - 4235
        Ulceration.Checked = CBool(dtOe("Ulceration"))
        UlcerationMultipleCheckBox.Checked = CBool(dtOe("UlcerationMultiple"))
        UlcerationQtyNumericTextBox.Value = CStr(dtOe("UlcerationQty"))
        UlcerationLengthNumericTextBox.Value = CStr(dtOe("UlcerationLength"))
        UlcerationClotInBase.Checked = CBool(dtOe("UlcerationClotInBase"))
        UlcerationReflux.Checked = CBool(dtOe("UlcerationReflux"))
        UlcerationPostSclero.Checked = CBool(dtOe("UlcerationPostSclero"))
        UlcerationPostBanding.Checked = CBool(dtOe("UlcerationPostBanding"))
    End Sub

    Private Sub SetLAClassification(val As Integer)
        LA_GradeARadButton.CssClass = "imageRemoveBorder"
        LA_GradeBRadButton.CssClass = "imageRemoveBorder"
        LA_GradeCRadButton.CssClass = "imageRemoveBorder"
        LA_GradeDRadButton.CssClass = "imageRemoveBorder"

        Select Case (val)
            Case 1
                LA_GradeARadButton.CssClass = "imageSetBorder"
            Case 2
                LA_GradeBRadButton.CssClass = "imageSetBorder"
            Case 3
                LA_GradeCRadButton.CssClass = "imageSetBorder"
            Case 4
                LA_GradeDRadButton.CssClass = "imageSetBorder"
        End Select

        hfLAClassification.Value = If(val = 0, "", val)
    End Sub

    Private Sub SetControls()
        For Each ctrl As Control In Fieldset1.Controls
            If TypeOf ctrl Is RadComboBox Then
                InsertComboBoxItem(ctrl)
            End If
        Next
    End Sub

    Private Sub InsertComboBoxItem(ctrl As RadComboBox)
        If ctrl.ID.LastIndexOf("_Other_ComboBox") > 0 Then
            ctrl.Items.Add(New RadComboBoxItem("", "0"))
            ctrl.Items.Add(New RadComboBoxItem("Mild", "1"))
            ctrl.Items.Add(New RadComboBoxItem("Moderate", "2"))
            ctrl.Items.Add(New RadComboBoxItem("Severe", "3"))
            ctrl.Width = "110"
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

            Dim bLA As Boolean = LAClassificationFieldset.Visible
            Dim iLAClassification As Integer = 0
            '--TFS--2959-Candida can only be reported if a grade of oesophagitis is added---
            If String.IsNullOrEmpty(hfLAClassification.Value) Then
                iLAClassification = 0
            Else
                iLAClassification = hfLAClassification.Value
            End If

            AbnormalitiesDataAdapter.SaveOesophagitisData(
                siteId,
                NoneCheckBox.Checked,
                0,
                IIf(bLA, LA_RefluxCheckBox.Checked, MSM_RefluxCheckBox.Checked),
                IIf(bLA, LA_ActiveBleedingCheckBox.Checked, MSM_ActiveBleedingCheckBox.Checked),
                IIf(bLA, 0, Grade1CheckBox_ME.Checked),
                IIf(bLA, 0, Grade2aCheckBox_ME.Checked),
                IIf(bLA, 0, Grade2bCheckBox_ME.Checked),
                IIf(bLA, 0, Grade3CheckBox_ME.Checked),
                IIf(bLA, 0, Grade4CheckBox.Checked),
                IIf(bLA, 0, Grade5CheckBox.Checked),
                IIf(bLA, LA_ShortOesophagusCheckBox.Checked, MSM_ShortOesophagusCheckBox.Checked),
                iLAClassification,
                (Suspected_Candida_CheckBox.Checked Or Eosinophilic_CheckBox.Checked Or Corrosive_Burns_CheckBox.Checked Or Caustic_Ingestion_CheckBox.Checked Or Suspected_Herpes_CheckBox.Checked Or Other_Other_CheckBox.Checked Or Ulceration.Checked),
                Suspected_Candida_CheckBox.Checked,
                Caustic_Ingestion_CheckBox.Checked,
                Suspected_Herpes_CheckBox.Checked,
                Corrosive_Burns_CheckBox.Checked,
                Eosinophilic_CheckBox.Checked,
                Other_Other_CheckBox.Checked,
                OtherTextBox.Text,
                Utilities.GetComboBoxValue(Suspected_Candida_Other_ComboBox),
                Utilities.GetComboBoxValue(Caustic_Ingestion_Other_ComboBox),
                Utilities.GetComboBoxValue(Suspected_Herpes_Other_ComboBox),
                Utilities.GetComboBoxValue(Eosinophilic_Other_ComboBox),
                Utilities.GetComboBoxValue(Corrosive_Burns_Other_ComboBox),
                Ulceration.Checked,  ' added by ferdowsi ,  TFS - 4235
                UlcerationMultipleCheckBox.Checked,
                Convert.ToInt32(UlcerationQtyNumericTextBox.Value),
                Convert.ToInt32(UlcerationLengthNumericTextBox.Value),
                UlcerationClotInBase.Checked,
                UlcerationReflux.Checked,
                UlcerationPostSclero.Checked,
                UlcerationPostBanding.Checked)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If


        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Varices.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
