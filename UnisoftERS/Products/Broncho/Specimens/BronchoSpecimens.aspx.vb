Imports Telerik.Web.UI
Imports System.Drawing

Partial Class Products_Broncho_Specimens_BronchoSpecimens
    Inherits SiteDetailsBase

    Private siteId As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        siteId = CInt(Request.QueryString("SiteId"))

        If Not Page.IsPostBack Then
            Dim dtSpecimens As DataTable = SpecimensDataAdapter.GetBronchoSpecimensData(siteId)
            If dtSpecimens.Rows.Count > 0 Then
                PopulateData(dtSpecimens.Rows(0))
            End If
        End If
    End Sub

    Private Sub PopulateData(drSpecimens As DataRow)

        NoneCheckBox.Checked = CBool(drSpecimens("None"))

        If CInt(drSpecimens("EBUSTB")) > 0 Then EbusSpecimenTBBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("EBUSTB"))
        If CInt(drSpecimens("EBUSHistology")) > 0 Then EbusSpecimenHistologyRadNumericTextBox.Value = CInt(drSpecimens("EBUSHistology"))
        If CInt(drSpecimens("EBUSCytology")) > 0 Then EbusSpecimenCytologyRadNumericTextBox.Value = CInt(drSpecimens("EBUSCytology"))
        If CInt(drSpecimens("EBUSBacteriology")) > 0 Then EbusSpecimenBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("EBUSBacteriology"))

        If CInt(drSpecimens("EndobronchialTB")) > 0 Then EndobronchialBiopsyTBBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("EndobronchialTB"))
        If CInt(drSpecimens("EndobronchialHistology")) > 0 Then EndobronchialBiopsyHistologyRadNumericTextBox.Value = CInt(drSpecimens("EndobronchialHistology"))
        If CInt(drSpecimens("EndobronchialBacteriology")) > 0 Then EndobronchialBiopsyBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("EndobronchialBacteriology"))
        If CInt(drSpecimens("EndobronchialVirology")) > 0 Then EndobronchialBiopsyVirologyRadNumericTextBox.Value = CInt(drSpecimens("EndobronchialVirology"))
        If CInt(drSpecimens("EndobronchialMycology")) > 0 Then EndobronchialBiopsyMycologyRadNumericTextBox.Value = CInt(drSpecimens("EndobronchialMycology"))

        If CInt(drSpecimens("BrushCytology")) > 0 Then BrushBiopsyCytologyRadNumericTextBox.Value = CInt(drSpecimens("BrushCytology"))
        If CInt(drSpecimens("BrushBacteriology")) > 0 Then BrushBiopsyBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("BrushBacteriology"))
        If CInt(drSpecimens("BrushVirology")) > 0 Then BrushBiopsyVirologyRadNumericTextBox.Value = CInt(drSpecimens("BrushVirology"))
        If CInt(drSpecimens("BrushMycology")) > 0 Then BrushBiopsyMycologyRadNumericTextBox.Value = CInt(drSpecimens("BrushMycology"))

        If CInt(drSpecimens("DistalBlindTB")) > 0 Then DistalBlindBiopsyTBBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("DistalBlindTB"))
        If CInt(drSpecimens("DistalBlindHistology")) > 0 Then DistalBlindBiopsyHistologyRadNumericTextBox.Value = CInt(drSpecimens("DistalBlindHistology"))
        If CInt(drSpecimens("DistalBlindBacteriology")) > 0 Then DistalBlindBiopsyBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("DistalBlindBacteriology"))
        If CInt(drSpecimens("DistalBlindVirology")) > 0 Then DistalBlindBiopsyVirologyRadNumericTextBox.Value = CInt(drSpecimens("DistalBlindVirology"))
        If CInt(drSpecimens("DistalBlindMycology")) > 0 Then DistalBlindBiopsyMycologyRadNumericTextBox.Value = CInt(drSpecimens("DistalBlindMycology"))

        If CInt(drSpecimens("TransbronchialTB")) > 0 Then TransbronchialBiopsyTBBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("TransbronchialTB"))
        If CInt(drSpecimens("TransbronchialHistology")) > 0 Then TransbronchialBiopsyHistologyRadNumericTextBox.Value = CInt(drSpecimens("TransbronchialHistology"))
        If CInt(drSpecimens("TransbronchialBacteriology")) > 0 Then TransbronchialBiopsyBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("TransbronchialBacteriology"))
        If CInt(drSpecimens("TransbronchialVirology")) > 0 Then TransbronchialBiopsyVirologyRadNumericTextBox.Value = CInt(drSpecimens("TransbronchialVirology"))
        If CInt(drSpecimens("TransbronchialMycology")) > 0 Then TransbronchialBiopsyMycologyRadNumericTextBox.Value = CInt(drSpecimens("TransbronchialMycology"))

        If CInt(drSpecimens("TranstrachealHistology")) > 0 Then TranstrachealBiopsyHistologyRadNumericTextBox.Value = CInt(drSpecimens("TranstrachealHistology"))
        If CInt(drSpecimens("TranstrachealBacteriology")) > 0 Then TranstrachealBiopsyBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("TranstrachealBacteriology"))
        If CInt(drSpecimens("TranstrachealVirology")) > 0 Then TranstrachealBiopsyVirologyRadNumericTextBox.Value = CInt(drSpecimens("TranstrachealVirology"))
        If CInt(drSpecimens("TranstrachealMycology")) > 0 Then TranstrachealBiopsyMycologyRadNumericTextBox.Value = CInt(drSpecimens("TranstrachealMycology"))

        If CInt(drSpecimens("TrapPCP")) > 0 Then TrapPcpRadNumericTextBox.Value = CInt(drSpecimens("TrapPCP"))
        If CInt(drSpecimens("TrapTB")) > 0 Then TrapTBBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("TrapTB"))
        If CInt(drSpecimens("TrapCytology")) > 0 Then TrapCytologyRadNumericTextBox.Value = CInt(drSpecimens("TrapCytology"))
        If CInt(drSpecimens("TrapBacteriology")) > 0 Then TrapBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("TrapBacteriology"))
        If CInt(drSpecimens("TrapVirology")) > 0 Then TrapVirologyRadNumericTextBox.Value = CInt(drSpecimens("TrapVirology"))
        If CInt(drSpecimens("TrapMycology")) > 0 Then TrapMycologyRadNumericTextBox.Value = CInt(drSpecimens("TrapMycology"))

        If CInt(drSpecimens("BALPCP")) > 0 Then BronchoalveolarLavagePcpRadNumericTextBox.Value = CInt(drSpecimens("BALPCP"))
        If CInt(drSpecimens("BALTB")) > 0 Then BronchoalveolarLavageTBBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("BALTB"))
        If CInt(drSpecimens("BALCytology")) > 0 Then BronchoalveolarLavageCytologyRadNumericTextBox.Value = CInt(drSpecimens("BALCytology"))
        If CInt(drSpecimens("BALBacteriology")) > 0 Then BronchoalveolarLavageBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("BALBacteriology"))
        If CInt(drSpecimens("BALVirology")) > 0 Then BronchoalveolarLavageVirologyRadNumericTextBox.Value = CInt(drSpecimens("BALVirology"))
        If CInt(drSpecimens("BALMycology")) > 0 Then BronchoalveolarLavageMycologyRadNumericTextBox.Value = CInt(drSpecimens("BALMycology"))
        If Not IsDBNull(drSpecimens("BALVolInfused")) Then BronchoalveolarLavageVolInfusedNumericTextBox.Value = CDec(drSpecimens("BALVolInfused"))
        If Not IsDBNull(drSpecimens("BALVolRecovered")) Then BronchoalveolarLavageVolRecoveredNumericTextBox.Value = CDec(drSpecimens("BALVolRecovered"))

        If CInt(drSpecimens("FNATB")) > 0 Then FnaTBRadNumericTextBox.Value = CInt(drSpecimens("FNATB"))
        If CInt(drSpecimens("FNACytology")) > 0 Then FnaCytologyRadNumericTextBox.Value = CInt(drSpecimens("FNACytology"))
        If CInt(drSpecimens("FNABacteriology")) > 0 Then FnaBacteriologyRadNumericTextBox.Value = CInt(drSpecimens("FNABacteriology"))
        If CInt(drSpecimens("FNAVirology")) > 0 Then FnaVirologyRadNumericTextBox.Value = CInt(drSpecimens("FNAVirology"))
        If CInt(drSpecimens("FNAMycology")) > 0 Then FnaMycologyRadNumericTextBox.Value = CInt(drSpecimens("FNAMycology"))
        If CInt(drSpecimens("FNAHistology")) > 0 Then FnaHistologyRadNumericTextBox.Value = CInt(drSpecimens("FNAHistology"))

        If CInt(drSpecimens("CryoHistology")) > 0 Then CryoHistologyRadNumericTextBox.Value = CInt(drSpecimens("CryoHistology"))

        If CInt(drSpecimens("FungalCultureMycology")) > 0 Then FungalCultureMycologyRadNumericTextBox.Value = CInt(drSpecimens("FungalCultureMycology"))
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        Try
            If siteId <= 0 Then
                siteId = AbnormalitiesDataAdapter.CommitEBUSite(Request.QueryString("Reg"))
            End If

            Session(Constants.SESSION_SITE_ID) = siteId

            SpecimensDataAdapter.SaveBRTSpecimensData(siteId,
                                        NoneCheckBox.Checked,
                                        EbusSpecimenTBBacteriologyRadNumericTextBox.Value,
                                        EbusSpecimenHistologyRadNumericTextBox.Value,
                                        EbusSpecimenCytologyRadNumericTextBox.Value,
                                        EbusSpecimenBacteriologyRadNumericTextBox.Value,
                                        EndobronchialBiopsyTBBacteriologyRadNumericTextBox.Value,
                                        EndobronchialBiopsyHistologyRadNumericTextBox.Value,
                                        EndobronchialBiopsyBacteriologyRadNumericTextBox.Value,
                                        EndobronchialBiopsyVirologyRadNumericTextBox.Value,
                                        EndobronchialBiopsyMycologyRadNumericTextBox.Value,
                                        BrushBiopsyCytologyRadNumericTextBox.Value,
                                        BrushBiopsyBacteriologyRadNumericTextBox.Value,
                                        BrushBiopsyVirologyRadNumericTextBox.Value,
                                        BrushBiopsyMycologyRadNumericTextBox.Value,
                                        DistalBlindBiopsyTBBacteriologyRadNumericTextBox.Value,
                                        DistalBlindBiopsyHistologyRadNumericTextBox.Value,
                                        DistalBlindBiopsyBacteriologyRadNumericTextBox.Value,
                                        DistalBlindBiopsyVirologyRadNumericTextBox.Value,
                                        DistalBlindBiopsyMycologyRadNumericTextBox.Value,
                                        TransbronchialBiopsyTBBacteriologyRadNumericTextBox.Value,
                                        TransbronchialBiopsyHistologyRadNumericTextBox.Value,
                                        TransbronchialBiopsyBacteriologyRadNumericTextBox.Value,
                                        TransbronchialBiopsyVirologyRadNumericTextBox.Value,
                                        TransbronchialBiopsyMycologyRadNumericTextBox.Value,
                                        TranstrachealBiopsyHistologyRadNumericTextBox.Value,
                                        TranstrachealBiopsyBacteriologyRadNumericTextBox.Value,
                                        TranstrachealBiopsyVirologyRadNumericTextBox.Value,
                                        TranstrachealBiopsyMycologyRadNumericTextBox.Value,
                                        TrapPcpRadNumericTextBox.Value,
                                        TrapTBBacteriologyRadNumericTextBox.Value,
                                        TrapCytologyRadNumericTextBox.Value,
                                        TrapBacteriologyRadNumericTextBox.Value,
                                        TrapVirologyRadNumericTextBox.Value,
                                        TrapMycologyRadNumericTextBox.Value,
                                        BronchoalveolarLavagePcpRadNumericTextBox.Value,
                                        BronchoalveolarLavageTBBacteriologyRadNumericTextBox.Value,
                                        BronchoalveolarLavageCytologyRadNumericTextBox.Value,
                                        BronchoalveolarLavageBacteriologyRadNumericTextBox.Value,
                                        BronchoalveolarLavageVirologyRadNumericTextBox.Value,
                                        BronchoalveolarLavageMycologyRadNumericTextBox.Value,
                                        Utilities.GetNumericTextBoxValue(BronchoalveolarLavageVolInfusedNumericTextBox, True),
                                        Utilities.GetNumericTextBoxValue(BronchoalveolarLavageVolRecoveredNumericTextBox, True),
                                        FnaTBRadNumericTextBox.Value,
                                        FnaCytologyRadNumericTextBox.Value,
                                        FnaBacteriologyRadNumericTextBox.Value,
                                        FnaVirologyRadNumericTextBox.Value,
                                        FnaMycologyRadNumericTextBox.Value,
                                        FnaHistologyRadNumericTextBox.Value,
                                        CryoHistologyRadNumericTextBox.Value,
                                        FungalCultureMycologyRadNumericTextBox.Value)

            'Utilities.SetNotificationStyle(RadNotification1)
            'RadNotification1.Show()

            'ScriptManager.RegisterStartupScript(Me, Page.GetType, "ScriptRefreshParent", "setRehideSummary();", True)

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occurred while saving Broncho Specimens Taken.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub
End Class
