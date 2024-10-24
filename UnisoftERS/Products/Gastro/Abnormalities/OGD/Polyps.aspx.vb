Imports Telerik.Web.UI

Partial Class Products_Gastro_Abnormalities_OGD_Polyps
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtPo As DataTable = AbnormalitiesDataAdapter.GetAbnormalities(siteId, "abnormalities_polyps_select")
            If dtPo.Rows.Count > 0 Then
                PopulateData(dtPo.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drPo As DataRow)
        NoneCheckBox.Checked = CBool(drPo("None"))
        SessileCheckBox.Checked = CBool(drPo("Sessile"))
        SessileTypeRadioButtonList.SelectedValue = CInt(drPo("SessileType"))
        SessileBenignTypeRadioButtonList.SelectedValue = CInt(drPo("SessileBenignType"))
        If Not IsDBNull(drPo("SessileQty")) Then SessileQtyNumericTextBox.Value = CInt(drPo("SessileQty"))
        SessileMultipleCheckBox.Checked = CBool(drPo("SessileMultiple"))
        If Not IsDBNull(drPo("SessileLargest")) Then SessileLargestNumericTextBox.Value = CDec(drPo("SessileLargest"))
        If Not IsDBNull(drPo("SessileNumExcised")) Then SessileNumExcisedNumericTextBox.Value = CInt(drPo("SessileNumExcised"))
        If Not IsDBNull(drPo("SessileNumRetrieved")) Then SessileNumRetrievedNumericTextBox.Value = CInt(drPo("SessileNumRetrieved"))
        If Not IsDBNull(drPo("SessileNumToLabs")) Then SessileNumToLabsNumericTextBox.Value = CInt(drPo("SessileNumToLabs"))
        SessileErodedCheckBox.Checked = CBool(drPo("SessileEroded"))
        SessileUlceratedCheckBox.Checked = CBool(drPo("SessileUlcerated"))
        SessileOverlyingClotCheckBox.Checked = CBool(drPo("SessileOverlyingClot"))
        SessileActiveBleedingCheckBox.Checked = CBool(drPo("SessileActiveBleeding"))
        SessileOverlyingOldBloodCheckBox.Checked = CBool(drPo("SessileOverlyingOldBlood"))
        SessileHyperplastic.Checked = CBool(drPo("SessileHyperplastic"))
        PedunculatedCheckBox.Checked = CBool(drPo("Pedunculated"))
        PedunculatedTypeRadioButtonList.SelectedValue = CInt(drPo("PedunculatedType"))
        PedunculatedBenignTypeRadioButtonList.SelectedValue = CInt(drPo("PedunculatedBenignType"))
        If Not IsDBNull(drPo("PedunculatedQty")) Then PedunculatedQtyNumericTextBox.Value = CInt(drPo("PedunculatedQty"))
        PedunculatedMultipleCheckBox.Checked = CBool(drPo("PedunculatedMultiple"))
        If Not IsDBNull(drPo("PedunculatedLargest")) Then PedunculatedLargestNumericTextBox.Value = CDec(drPo("PedunculatedLargest"))
        If Not IsDBNull(drPo("PedunculatedNumExcised")) Then PedunculatedNumExcisedNumericTextBox.Value = CInt(drPo("PedunculatedNumExcised"))
        If Not IsDBNull(drPo("PedunculatedNumRetrieved")) Then PedunculatedNumRetrievedNumericTextBox.Value = CInt(drPo("PedunculatedNumRetrieved"))
        If Not IsDBNull(drPo("PedunculatedNumToLabs")) Then PedunculatedNumToLabsNumericTextBox.Value = CInt(drPo("PedunculatedNumToLabs"))
        PedunculatedErodedCheckBox.Checked = CBool(drPo("PedunculatedEroded"))
        PedunculatedUlceratedCheckBox.Checked = CBool(drPo("PedunculatedUlcerated"))
        PedunculatedOverlyingClotCheckBox.Checked = CBool(drPo("PedunculatedOverlyingClot"))
        PedunculatedActiveBleedingCheckBox.Checked = CBool(drPo("PedunculatedActiveBleeding"))
        PedunculatedOverlyingOldBloodCheckBox.Checked = CBool(drPo("PedunculatedOverlyingOldBlood"))
        PedunculatedHyperplastic.Checked = CBool(drPo("PedunculatedHyperplastic"))
        SubmucosalCheckBox.Checked = CBool(drPo("Submucosal"))
        If Not IsDBNull(drPo("SubmucosalQty")) Then SubmucosalQtyNumericTextBox.Value = CInt(drPo("SubmucosalQty"))
        SubmucosalMultipleCheckBox.Checked = CBool(drPo("SubmucosalMultiple"))
        SubmucosalTypeRadioButtonList.SelectedValue = CInt(drPo("SubmucosalType"))
        SubmucosalBenignTypeRadioButtonList.SelectedValue = CInt(drPo("SubmucosalBenignType"))
        If Not IsDBNull(drPo("SubmucosalLargest")) Then SubmucosalLargestNumericTextBox.Value = CDec(drPo("SubmucosalLargest"))
        If Not IsDBNull(drPo("SubmucosalNumExcised")) Then SubmucosalNumExcisedNumericTextBox.Value = CInt(drPo("SubmucosalNumExcised"))
        If Not IsDBNull(drPo("SubmucosalNumRetrieved")) Then SubmucosalNumRetrievedNumericTextBox.Value = CInt(drPo("SubmucosalNumRetrieved"))
        If Not IsDBNull(drPo("SubmucosalNumToLabs")) Then SubmucosalNumToLabsNumericTextBox.Value = CInt(drPo("SubmucosalNumToLabs"))
        SubmucosalErodedCheckBox.Checked = CBool(drPo("SubmucosalEroded"))
        SubmucosalUlceratedCheckBox.Checked = CBool(drPo("SubmucosalUlcerated"))
        SubmucosalOverlyingClotCheckBox.Checked = CBool(drPo("SubmucosalOverlyingClot"))
        SubmucosalActiveBleedingCheckBox.Checked = CBool(drPo("SubmucosalActiveBleeding"))
        SubmucosalOverlyingOldBloodCheckBox.Checked = CBool(drPo("SubmucosalOverlyingOldBlood"))
        SubmucosalHyperplastic.Checked = CBool(drPo("SubmucosalHyperplastic"))

        If SessileNumExcisedNumericTextBox.Value > 0 Then
            SessilePolyRemovalRadioButtonList.SelectedValue = CInt(drPo("PolypectomyRemoval"))
            SessilePolypRemovalTypeRadioButtonList.SelectedValue = CInt(drPo("PolypectomyRemovalType"))
        Else
            If PedunculatedNumExcisedNumericTextBox.Value > 0 Then
                PedunculatedPolyRemovalRadioButtonList.SelectedValue = CInt(drPo("PolypectomyRemoval"))
                PedunculatedPolypRemovalTypeRadioButtonList.SelectedValue = CInt(drPo("PolypectomyRemovalType"))
            End If
        End If
        'If CInt(drPo("SurgicalProcedure")) > 0 Then
        '    SurgicalProcedureCheckBox.Checked = True
        '    SurgicalProcedureComboBox.SelectedValue = CInt(drPo("SurgicalProcedure"))
        '    FindingsTextBox.Text = CStr(drPo("SurgicalProcedureFindings"))
        'End If

        'DuodenumCheckBox.Checked = Not CBool(drPo("DuodenumPresent"))
        'If CInt(drPo("JejunumState")) > 0 Then
        '    JejunumCheckBox.Checked = True
        '    JejunumStateRadioButtonList.SelectedValue = CInt(drPo("JejunumState"))
        '    AbnormalTextBox.Text = CStr(drPo("JejunumAbnormalText"))
        'End If
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)
        SaveRecord(False)
    End Sub

    Protected Sub SaveRecord(saveAndClose As Boolean)

        Dim PolypectomyRemoval As Integer = 0
        Dim PolypectomyRemovalType As Integer = 0
        If SessileNumExcisedNumericTextBox.Value > 0 Then
            If SessilePolyRemovalRadioButtonList.SelectedValue <> "" Then PolypectomyRemoval = SessilePolyRemovalRadioButtonList.SelectedValue
            If SessilePolypRemovalTypeRadioButtonList.SelectedValue <> "" Then PolypectomyRemovalType = SessilePolypRemovalTypeRadioButtonList.SelectedValue
        Else
            If PedunculatedNumExcisedNumericTextBox.Value > 0 Then
                If PedunculatedPolyRemovalRadioButtonList.SelectedValue <> "" Then PolypectomyRemoval = PedunculatedPolyRemovalRadioButtonList.SelectedValue
                If PedunculatedPolypRemovalTypeRadioButtonList.SelectedValue <> "" Then PolypectomyRemovalType = PedunculatedPolypRemovalTypeRadioButtonList.SelectedValue
            End If
        End If

        Try
            'AbnormalitiesDataAdapter.SavePolypsData(
            '    siteId,
            '    NoneCheckBox.Checked,
            '    SessileCheckBox.Checked,
            '    Utilities.GetRadioValue(SessileTypeRadioButtonList),
            '    Utilities.GetRadioValue(SessileBenignTypeRadioButtonList),
            '    SessileQtyNumericTextBox.Value,
            '    SessileMultipleCheckBox.Checked,
            '    SessileLargestNumericTextBox.Value,
            '    SessileNumExcisedNumericTextBox.Value,
            '    SessileNumRetrievedNumericTextBox.Value,
            '    SessileNumToLabsNumericTextBox.Value,
            '    SessileErodedCheckBox.Checked,
            '    SessileUlceratedCheckBox.Checked,
            '    SessileOverlyingClotCheckBox.Checked,
            '    SessileActiveBleedingCheckBox.Checked,
            '    SessileOverlyingOldBloodCheckBox.Checked,
            '    SessileHyperplastic.Checked,
            '    PedunculatedCheckBox.Checked,
            '    Utilities.GetRadioValue(PedunculatedTypeRadioButtonList),
            '    Utilities.GetRadioValue(PedunculatedBenignTypeRadioButtonList),
            '    PedunculatedQtyNumericTextBox.Value,
            '    PedunculatedMultipleCheckBox.Checked,
            '    PedunculatedLargestNumericTextBox.Value,
            '    PedunculatedNumExcisedNumericTextBox.Value,
            '    PedunculatedNumRetrievedNumericTextBox.Value,
            '    PedunculatedNumToLabsNumericTextBox.Value,
            '    PedunculatedErodedCheckBox.Checked,
            '    PedunculatedUlceratedCheckBox.Checked,
            '    PedunculatedOverlyingClotCheckBox.Checked,
            '    PedunculatedActiveBleedingCheckBox.Checked,
            '    PedunculatedOverlyingOldBloodCheckBox.Checked,
            '    PedunculatedHyperplastic.Checked,
            '    SubmucosalCheckBox.Checked,
            '    Utilities.GetRadioValue(SubmucosalTypeRadioButtonList),
            '    Utilities.GetRadioValue(SubmucosalBenignTypeRadioButtonList),
            '    SubmucosalQtyNumericTextBox.Value,
            '    SubmucosalMultipleCheckBox.Checked,
            '    SubmucosalLargestNumericTextBox.Value,
            '    SubmucosalNumExcisedNumericTextBox.Value,
            '    SubmucosalNumRetrievedNumericTextBox.Value,
            '    SubmucosalNumToLabsNumericTextBox.Value,
            '    SubmucosalErodedCheckBox.Checked,
            '    SubmucosalUlceratedCheckBox.Checked,
            '    SubmucosalOverlyingClotCheckBox.Checked,
            '    SubmucosalActiveBleedingCheckBox.Checked,
            '    SubmucosalOverlyingOldBloodCheckBox.Checked,
            '    SubmucosalHyperplastic.Checked,
            '    PolypectomyRemoval,
            '    PolypectomyRemovalType)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()
            If saveAndClose Then
                ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)
            End If


        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Abnormalities - Polyps.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

End Class
