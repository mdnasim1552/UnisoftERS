Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_Malignancy
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtMa As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_malignancy_select")
            If dtMa.Rows.Count > 0 Then
                PopulateData(dtMa.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drMa As DataRow)
        NoneCheckBox.Checked = CBool(drMa("None"))
        EarlyCarcinomaCheckBox.Checked = CBool(drMa("EarlyCarcinoma"))
        AdvCarcinomaCheckBox.Checked = CBool(drMa("AdvCarcinoma"))
        LymphomaCheckBox.Checked = CBool(drMa("Lymphoma"))

        EarlyCarcinomaLesionRadioButtonList.SelectedValue = CInt(drMa("EarlyCarcinomaLesion"))
        EarlyCarcinomaBleedingRadioButtonList.SelectedValue = CInt(drMa("EarlyCarcinomaBleeding"))
        EarlyTypeRadioButtonList.SelectedValue = CInt(drMa("EarlyType"))
        SubEarlyTypeRadioButtonList.SelectedValue = CInt(drMa("SubEarlyType"))
        If CInt(drMa("EarlyType")) = 1 Then EarlyBenignRadioButtonList.SelectedValue = CInt(drMa("EarlyBenignOrMalignantType")) Else EarlyMalignantRadioButtonList.SelectedValue = CInt(drMa("EarlyBenignOrMalignantType"))
        If Not IsDBNull(drMa("EarlyOtherText")) Or Not drMa("EarlyOtherText") = String.Empty Then
            If CInt(drMa("EarlyType")) = 1 Then
                EarlyBenignOtherTextBox.Text = drMa("EarlyOtherText").ToString()
            Else
                EarlyMalignantOtherTextBox.Text = drMa("EarlyOtherText").ToString()
            End If
        End If
        EarlyProbablyCheckBox.Checked = CBool(drMa("EarlyProbably"))
        If Not IsDBNull(drMa("EarlyCarcinomaStart")) Then EarlyCarcinomaStartNumericTextBox.Value = CInt(drMa("EarlyCarcinomaStart"))
        If Not IsDBNull(drMa("EarlyCarcinomaEnd")) Then EarlyCarcinomaEndNumericTextBox.Value = CInt(drMa("EarlyCarcinomaEnd"))
        If Not IsDBNull(drMa("EarlyCarcinomaLargest")) Then EarlyCarcinomaDiaNumericTextBox.Value = CDbl(drMa("EarlyCarcinomaLargest"))

        AdvCarcinomaLesionRadioButtonList.SelectedValue = CInt(drMa("AdvCarcinomaLesion"))
        AdvCarcinomaBleedingRadioButtonList.SelectedValue = CInt(drMa("AdvCarcinomaBleeding"))
        GastricTypeRadioButtonList.SelectedValue = CInt(drMa("GastricType"))
        SubGastricTypeRadioButtonList.SelectedValue = CInt(drMa("SubGastricType"))
        If CInt(drMa("GastricType")) = 1 Then GastricBenignRadioButtonList.SelectedValue = CInt(drMa("GastricBenignOrMalignantType")) Else GastricMalignantRadioButtonList.SelectedValue = CInt(drMa("GastricBenignOrMalignantType"))
        If Not IsDBNull(drMa("GastricOtherText")) Or Not drMa("GastricOtherText") = String.Empty Then
            If CInt(drMa("GastricType")) = 1 Then
                GastricBenignOtherTextBox.Text = drMa("GastricOtherText").ToString()
            Else
                GastricMalignantOtherTextBox.Text = drMa("GastricOtherText").ToString()
            End If
        End If
        GastricProbablyCheckBox.Checked = CBool(drMa("GastricProbably"))
        If Not IsDBNull(drMa("AdvCarcinomaStart")) Then AdvCarcinomaStartNumericTextBox.Value = CInt(drMa("AdvCarcinomaStart"))
        If Not IsDBNull(drMa("AdvCarcinomaEnd")) Then AdvCarcinomaEndNumericTextBox.Value = CInt(drMa("AdvCarcinomaEnd"))
        If Not IsDBNull(drMa("AdvCarcinomaLargest")) Then AdvCarcinomaDiaNumericTextBox.Value = CDbl(drMa("AdvCarcinomaLargest"))

        LymphomaLesionRadioButtonList.SelectedValue = CInt(drMa("LymphomaLesion"))
        LymphomaBleedingRadioButtonList.SelectedValue = CInt(drMa("LymphomaBleeding"))
        LymphomaTypeRadioButtonList.SelectedValue = CInt(drMa("LymphomaType"))
        SubLymphomaTypeRadioButtonList.SelectedValue = CInt(drMa("SubLymphomaType"))
        If CInt(drMa("LymphomaType")) = 1 Then LymphomaBenignRadioButtonList.SelectedValue = CInt(drMa("LymphomaBenignOrMalignantType")) Else LymphomaMalignantRadioButtonList.SelectedValue = CInt(drMa("LymphomaBenignOrMalignantType"))
        If Not IsDBNull(drMa("LymphomaOtherText")) Or Not drMa("LymphomaOtherText") = String.Empty Then
            If CInt(drMa("LymphomaType")) = 1 Then
                LymphomaBenignOtherTextBox.Text = drMa("LymphomaOtherText").ToString()
            Else
                LymphomaMalignantOthertextBox.Text = drMa("LymphomaOtherText").ToString()
            End If
        End If
        LymphomaProbablyCheckBox.Checked = CBool(drMa("LymphomaProbably"))
        If Not IsDBNull(drMa("LymphomaStart")) Then LymphomaStartNumericTextBox.Value = CInt(drMa("LymphomaStart"))
        If Not IsDBNull(drMa("LymphomaEnd")) Then LymphomaEndNumericTextBox.Value = CInt(drMa("LymphomaEnd"))
        If Not IsDBNull(drMa("LymphomaLargest")) Then LymphomaDiaNumericTextBox.Value = CDbl(drMa("LymphomaLargest"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)
        Try
            Dim earlySelectedRadioButton As Integer = Utilities.GetRadioValue(EarlyTypeRadioButtonList)
            Dim gastricSelectedRadioButton As Integer = Utilities.GetRadioValue(GastricTypeRadioButtonList)
            Dim lymphomaSelectedRadioButton As Integer = Utilities.GetRadioValue(LymphomaTypeRadioButtonList)
            AbnormalitiesDataAdapter.SaveMalignancyData(
                siteId, NoneCheckBox.Checked,
                EarlyCarcinomaCheckBox.Checked, Utilities.GetRadioValue(EarlyCarcinomaLesionRadioButtonList),
                EarlyCarcinomaStartNumericTextBox.Value, EarlyCarcinomaEndNumericTextBox.Value, EarlyCarcinomaDiaNumericTextBox.Value,
                Utilities.GetRadioValue(EarlyCarcinomaBleedingRadioButtonList),
                AdvCarcinomaCheckBox.Checked, Utilities.GetRadioValue(AdvCarcinomaLesionRadioButtonList),
                AdvCarcinomaStartNumericTextBox.Value, AdvCarcinomaEndNumericTextBox.Value, AdvCarcinomaDiaNumericTextBox.Value,
                Utilities.GetRadioValue(AdvCarcinomaBleedingRadioButtonList),
                LymphomaCheckBox.Checked, Utilities.GetRadioValue(LymphomaLesionRadioButtonList),
                LymphomaStartNumericTextBox.Value, LymphomaEndNumericTextBox.Value, LymphomaDiaNumericTextBox.Value,
                Utilities.GetRadioValue(LymphomaBleedingRadioButtonList),
                earlySelectedRadioButton,
                EarlyProbablyCheckBox.Checked, Utilities.GetRadioValue(SubEarlyTypeRadioButtonList), If(earlySelectedRadioButton = 1, Utilities.GetRadioValue(EarlyBenignRadioButtonList), Utilities.GetRadioValue(EarlyMalignantRadioButtonList)),
                If(earlySelectedRadioButton = 1, EarlyBenignOtherTextBox.Text, EarlyMalignantOtherTextBox.Text),
                gastricSelectedRadioButton,
                GastricProbablyCheckBox.Checked, Utilities.GetRadioValue(SubGastricTypeRadioButtonList), If(gastricSelectedRadioButton = 1, Utilities.GetRadioValue(GastricBenignRadioButtonList), Utilities.GetRadioValue(GastricMalignantRadioButtonList)),
                If(gastricSelectedRadioButton = 1, GastricBenignOtherTextBox.Text, GastricMalignantOtherTextBox.Text),
                lymphomaSelectedRadioButton,
                LymphomaProbablyCheckBox.Checked, Utilities.GetRadioValue(SubLymphomaTypeRadioButtonList), If(lymphomaSelectedRadioButton = 1, Utilities.GetRadioValue(LymphomaBenignRadioButtonList), Utilities.GetRadioValue(LymphomaMalignantRadioButtonList)),
                If(lymphomaSelectedRadioButton = 1, LymphomaBenignOtherTextBox.Text, LymphomaMalignantOthertextBox.Text)
            )

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If


        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Malignancy.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
