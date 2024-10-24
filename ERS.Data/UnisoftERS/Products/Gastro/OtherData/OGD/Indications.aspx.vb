Imports Telerik.Web.UI

Partial Class Products_Gastro_OtherData_OGD_Indications
    Inherits PageBase
    Private Shared procType As Integer
    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            'SaveButton.Text = IIf(Session("AdvancedMode") = True, "Save Record", "Save & Close")
            procType = IInt(Session(Constants.SESSION_PROCEDURE_TYPE))

            Utilities.LoadDropdown(New Dictionary(Of RadComboBox, String)() From {
                        {SurgeryFollowUpProcComboBox, "Surgery follow up proc Upper GI"},
                        {DiseaseFollowUpProcComboBox, DataAdapter.GetDiseaseFollowUpProc(IInt(Session(Constants.SESSION_PROCEDURE_TYPE)))},
                        {DiseaseFollowUpProcPeriodComboBox, "Follow up disease Period"},
                        {ERSCarriedOutRadComboBox, "Follow up disease Period"},
                        {DamagingDrugsComboBox, "Indications_Potential_Damaging_Drugs"},
                        {ColonAlterBowelRadComboBox, "Indications Colon Altered Bowel Habit"},
                        {ColonRectalRadComboBox, "Indications Colon Rectal Bleeding"},
                        {ERSPreviousRadComboBox, "Follow up disease/proc ERCP"},
                        {ColonFollowUpLeftRadComboBox, "Follow up disease/proc Colon"},
                        {DiabetesMellitusTypeComboBox, "Diabetes Mellitus"}
                  })

            DamagingDrugsComboBox.Items.Remove(0) ' Remove first blank entry
            'Utilities.LoadDropdown(SurgeryFollowUpProcComboBox, DataAdapter.GetSurgeryFollowUpProc(), "ListItemText", "ListItemNo")
            'Utilities.LoadDropdown(DiseaseFollowUpProcComboBox, DataAdapter.GetDiseaseFollowUpProc(IInt(Session(Constants.SESSION_PROCEDURE_TYPE))), "ListItemText", "ListItemNo")
            'Utilities.LoadDropdown(DamagingDrugsComboBox, DataAdapter.GetDamagingDrugs, "ListItemText", "ListItemNo", Nothing)

            'Utilities.LoadDropdown(ColonAlterBowelRadComboBox, DataAdapter.GetAlteredBowel, "ListItemText", "ListItemNo", Nothing)
            'Utilities.LoadDropdown(ColonRectalRadComboBox, DataAdapter.GetRectal, "ListItemText", "ListItemNo", Nothing)

            'Utilities.LoadDropdown(ERSPreviousRadComboBox, DataAdapter.ERCPFollowPrev, "ListItemText", "ListItemNo", Nothing)
            Display()
            Dim da As New OtherData
            Dim dtIn As DataTable = da.GetUpperGIIndications(IInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtIn.Rows.Count > 0 Then
                PopulateData(dtIn.Rows(0))
            End If

            If Session("GIBleedsData") IsNot Nothing Then
                Try
                    Session.Remove("GIBleedsData")
                    Session.Remove("GIBAgeRange")
                    Session.Remove("GIBGender")
                    Session.Remove("GIBMelaena")
                    Session.Remove("GIBSyncope")
                    Session.Remove("GIBLowestSystolicBP")
                    Session.Remove("GIBHighestPulseGreaterThan100")
                    Session.Remove("GIBUrea")
                    Session.Remove("GIBHaemoglobin")
                    Session.Remove("GIBHeartFailure")
                    Session.Remove("GIBLiverFailure")
                    Session.Remove("GIBRenalFailure")
                    Session.Remove("GIBMetastaticCancer")
                    Session.Remove("GIBDiagnosis")
                    Session.Remove("GIBBleeding")
                    Session.Remove("GIBOverallRiskAssessment")
                    Session.Remove("BlatchfordScore")
                    Session.Remove("RockallScore")
                Catch
                End Try
            End If
            Dim dtBl As DataTable = da.GetUpperGIBleeds(IInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtBl.Rows.Count > 0 Then
                PopulateGIBleeds(dtBl.Rows(0))
            End If

            '#Set focus on the required tab page
            If Not String.IsNullOrEmpty(Request.QueryString("tab")) Then
                Dim tab As String = Request.QueryString("tab")
                If Not RadTabStrip1.FindTabByValue(tab) Is Nothing AndAlso RadTabStrip1.FindTabByValue(tab).Visible Then
                    RadTabStrip1.FindTabByValue(tab).Selected = True
                    RadMultiPage1.SelectedIndex = RadMultiPage1.FindPageViewByID(RadTabStrip1.FindTabByValue(tab).PageViewID).Index
                End If
            End If
        End If
        Dim myAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Page)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveButton, RadTabStrip1, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(CancelButton, RadTabStrip1, RadAjaxLoadingPanel1)
        myAjaxMgr.AjaxSettings.AddAjaxSetting(SaveButton, RadNotification1)
        'myAjaxMgr.AjaxSettings.AddAjaxSetting(CancelButton, ButtonsRadPane, RadAjaxLoadingPanel1)
        'DirectCast(FindAControl(Me.Master.Controls, "RadScriptManager1"), ScriptManager).RegisterPostBackControl(RadTabStrip1)
        'Dim PatProcAjaxMgr As RadAjaxManager = RadAjaxManager.GetCurrent(Page)
        'PatProcAjaxMgr.AjaxSettings.AddAjaxSetting(AddButton, DamagingDrugsMultiTextBox)
    End Sub
    Protected Sub Display()
        If procType = ProcedureType.Colonoscopy Or procType = ProcedureType.Sigmoidscopy Or procType = ProcedureType.Proctoscopy Or procType = ProcedureType.Retrograde Then
            RadTabStrip1.FindTabByValue("1").Visible = True
            RadTabStrip1.FindTabByValue("2").Visible = True
            RadTabStrip1.FindTabByValue("3").Visible = True
            RadTabStrip1.FindTabByValue("5").Visible = True
            RadTabStrip1.FindTabByValue("1").Selected = True
            RadPageView9.Selected = True
            ColonFITCheckBox.Visible = True 'Available for colon and flexi only
            ColonIndicationSurveillanceCheckbox.Visible = True 'Available for colon and flexi only
            If procType = ProcedureType.Sigmoidscopy Then
                ColonScreeningTD.Visible = False
                ColonScreeningCheckBox.Visible = False
                ColonFOBTCheckBox.Visible = False
            ElseIf procType = ProcedureType.Proctoscopy Then
                ColonScreeningTR.Visible = False
                ColonFITCheckBox.Visible = False
            End If
        ElseIf procType = ProcedureType.ERCP Or procType = ProcedureType.EUS_HPB Then
            RadTabStrip1.FindTabByValue("6").Visible = True
            RadTabStrip1.FindTabByValue("3").Visible = True
            RadTabStrip1.FindTabByValue("7").Visible = True
            RadTabStrip1.FindTabByValue("2").Visible = True
            RadTabStrip1.FindTabByValue("8").Visible = True
            RadTabStrip1.FindTabByValue("9").Visible = True
            RadTabStrip1.FindTabByValue("6").Selected = True
            ERCPRadPageView4.Selected = True
        ElseIf procType = ProcedureType.Gastroscopy Or procType = ProcedureType.EUS_OGD Then
            RadTabStrip1.FindTabByValue("0").Visible = True
            RadTabStrip1.FindTabByValue("2").Visible = True
            RadTabStrip1.FindTabByValue("3").Visible = True
            RadTabStrip1.FindTabByValue("4").Visible = True
            RadTabStrip1.FindTabByValue("0").Selected = True
            RadPageView0.Selected = True
        ElseIf procType = ProcedureType.Antegrade Then
            RadTabStrip1.FindTabByValue("0").Visible = True
            RadTabStrip1.FindTabByValue("2").Visible = True
            RadTabStrip1.FindTabByValue("3").Visible = True
            RadTabStrip1.FindTabByValue("4").Visible = True
            RadTabStrip1.FindTabByValue("0").Selected = True
            RadPageView0.Selected = True
            EnteroscopyIndicationsDiv.Visible = True
            EnteroscopyPlannedProceduresRow.Visible = True
            PlannedProceduresRow.Visible = False
        End If

        If procType = ProcedureType.EUS_OGD Then
            hideIndications.Visible = False
            ogdIndications.Visible = True
        Else
            ogdIndications.Visible = False
        End If
    End Sub

    Private Sub PopulateData(drIn As DataRow)
        If procType = ProcedureType.Colonoscopy Or procType = ProcedureType.Sigmoidscopy Or procType = ProcedureType.Proctoscopy Then
            ColonScreeningCheckBox.Checked = IBool(drIn("ColonSreeningColonoscopy"))
            ColonBowelCancerCheckBox.Checked = IBool(drIn("ColonBowelCancerScreening"))
            ColonFOBTCheckBox.Checked = IBool(drIn("ColonFOBT"))
            ColonFITCheckBox.Checked = IBool(drIn("ColonFIT"))
            ColonIndicationSurveillanceCheckbox.Checked = IBool(drIn("ColonIndicationSurveillance"))
            ColonAlterBowelRadComboBox.SelectedValue = IInt(drIn("ColonAlterBowelHabit"))
            NationalBowelScopeScreeningCheckBox.Checked = IBool(drIn("NationalBowelScopeScreening"))
            ColonRectalRadComboBox.SelectedValue = IInt(drIn("ColonRectalBleeding"))
            ColonLeadingToHaematemesisCheckBox.Checked = IBool(drIn("Haematemesis"))
            ColonAnamemiaCheckBox.Checked = IBool(drIn("ColonAnaemia"))
            If IBool(drIn("ColonAnaemia")) Then
                ColonAnaemiaRadComboBox.SelectedValue = IInt(drIn("ColonAnaemiaType"))
                ColonAnaemiaRadComboBox.Attributes.Add("style", "display:normal")
            Else
                ColonAnaemiaRadComboBox.Attributes.Add("style", "display:none")
            End If

            ColonAbnormalCTScanCheckBox.Checked = IBool(drIn("ColonAbnormalCTScan"))
            ColonAbnormalSigmoidoscopyCheckBox.Checked = IBool(drIn("ColonAbnormalSigmoidoscopy"))
            ColonAbnormalBariumEnemaCheckBox.Checked = IBool(drIn("ColonAbnormalBariumEnema"))
            ColonAbdominalMassCheckBox.Checked = IBool(drIn("ColonAbdominalMass"))
            ColonDefaecationDisorder.Checked = IBool(drIn("ColonDefaecationDisorder"))
            ColonColonicObstructionCheckBox.Checked = IBool(drIn("ColonColonicObstruction"))
            ColonAbdominalPainCheckBox.Checked = IBool(drIn("ColonAbdominalPain"))
            ColonTumourAssessmentCheckBox.Checked = IBool(drIn("ColonTumourAssessment"))
            ColonMelaenaCheckBox.Checked = IBool(drIn("ColonMelaena"))
            PolyposisSyndromeCheckBox.Checked = IBool(drIn("ColonPolyposisSyndrome"))
            ColonRaisedFaecalCalprotectinCheckBox.Checked = IBool(drIn("ColonRaisedFaecalCalprotectin"))
            ColonWeightLossCheckBox.Checked = IBool(drIn("ColonWeightLoss"))

            ColonFamilyCheckBox.Checked = IBool(drIn("ColonFamily"))
            If IBool(drIn("ColonFamily")) Then
                familydiv.Attributes.Add("style", "display:normal")
            Else
                familydiv.Attributes.Add("style", "display:none")
            End If

            ColonAssessmentCheckBox.Checked = IBool(drIn("ColonAssessment"))
            ColonSurveillanceCheckBox.Checked = IBool(drIn("ColonSurveillance"))
            If IBool(drIn("ColonAssessment")) Or IBool(drIn("ColonSurveillance")) Then
                ibddiv.Attributes.Add("style", "display:normal")
            Else
                ibddiv.Attributes.Add("style", "display:none")
            End If

            Select Case IInt(drIn("ColonAssessmentType"))
                Case 1
                    ColonUnspecifiedRadioButton.Checked = True
                Case 2
                    ColonCrohnRadioButton.Checked = True
                Case 3
                    ColonUlcerativeRadioButton.Checked = True
            End Select

            Select Case drIn("ColonFamilyType")
                Case 1
                    ColonRiskRadioButton.Checked = True
                Case 2
                    ColonNoRiskRadioButton.Checked = True
                Case 3
                    ColonFamilialRadioButton.Checked = True
                Case 4
                    ColonHistoryRadioButton.Checked = True
                Case 5
                    ColonHereditoryRadioButton.Checked = True
                Case 6
                    ColonHnpccRadioButton.Checked = True
            End Select

            If Not IsDBNull(drIn("ColonFamilyAdditionalText")) Then
                ColonAdditionalRadTextBox.Text = Server.HtmlDecode(drIn("ColonFamilyAdditionalText"))
            End If

            ColonCarcinomaCheckBox.Checked = IBool(drIn("ColonCarcinoma"))
            ColonPolypsCheckBox.Checked = IBool(drIn("ColonPolyps"))
            ColonDysplasiaCheckBox.Checked = IBool(drIn("ColonDysplasia"))


            ColonOtherRadTextBox.Text = Server.HtmlDecode(IStr(drIn("OtherIndication")))
            ColonImportantCommentsRadTextBox.Text = Server.HtmlDecode(IStr(drIn("ClinicallyImpComments")))
            cUrgentCheckBox.Checked = IBool(drIn("UrgentTwoWeekReferral"))
            ColonCancerRadComboBox.SelectedValue = IInt(drIn("Cancer"))

            If Not IsDBNull(drIn("WHOStatus")) Then
                cWhoPerformanceStatusTextBox.Text = Server.HtmlDecode(drIn("WHOStatus").ToString)
                WHOStatusRadioButtonList.SelectedValue = IInt(drIn("WHOStatus"))
            End If

            ColonFollowUpLeftRadComboBox.SelectedValue = IInt(drIn("SurgeryFollowUpProc"))
            ColonFollowUpRightRadComboBox.SelectedValue = IInt(drIn("SurgeryFollowUpProcPeriod"))
            ColonFollowUpRadTextBox.Text = Server.HtmlDecode(IStr(drIn("SurgeryFollowUpText")))

            ColonStentRemovalCheckBox.Checked = IBool(drIn("StentRemoval"))
            ColonStentInsertionCheckBox.Checked = IBool(drIn("StentInsertion"))
            ColonStentReplacementCheckBox.Checked = IBool(drIn("StentReplacement"))

            ColonPolypTumourAssessCheckBox.Checked = IBool(drIn("PolypTumourAssess"))
            ColonEMRCheckBox.Checked = IBool(drIn("EMR"))
            ColonPlannedPolypectomy.Checked = IBool(drIn("ColonPlannedPolypectomy"))


        ElseIf procType = ProcedureType.ERCP Or procType = ProcedureType.EUS_HPB Then
            'For ERS/EUS(HPB) Clinical Indications
            ERSAbdominalPainCheckBox.Checked = IBool(drIn("ERSAbdominalPain"))
            ERSChronicPancreatisisCheckBox.Checked = IBool(drIn("ERSChronicPancreatisis"))
            ERSSphincterCheckBox.Checked = IBool(drIn("ERSSphincter"))
            ERSAbnormalEnzymesCheckBox.Checked = IBool(drIn("ERSAbnormalEnzymes"))
            ERSJaundiceCheckBox.Checked = IBool(drIn("ERSJaundice"))
            ERSStentOcclusionCheckBox.Checked = IBool(drIn("ERSStentOcclusion"))
            ERSAcutePancreatitisAcuteCheckBox.Checked = IBool(drIn("ERSAcutePancreatitisAcute"))
            ERSObstructedCBDCheckBox.Checked = IBool(drIn("ERSObstructedCBD"))
            ERSCBDStonesCheckBox.Checked = IBool(drIn("ERSCBDStones"))
            ERSSuspectedPapillaryCheckBox.Checked = IBool(drIn("ERSSuspectedPapillary"))
            ERSBiliaryLeakCheckBox.Checked = IBool(drIn("ERSBiliaryLeak"))
            ERSOpenAccessCheckBox.Checked = IBool(drIn("ERSOpenAccess"))
            ERSCholangitisCheckBox.Checked = IBool(drIn("ERSCholangitis"))
            ERSPrelaparoscopicCheckBox.Checked = IBool(drIn("ERSPrelaparoscopic"))
            ERSRecurrentPancreatitisCheckBox.Checked = IBool(drIn("ERSRecurrentPancreatitis"))

            ERSBileDuctInjuryCheckBox.Checked = IBool(drIn("ERSBileDuctInjury"))
            ERSPurulentCholangitisCheckBox.Checked = IBool(drIn("ERSPurulentCholangitis"))
            ERSPancreaticPseudocystCheckBox.Checked = IBool(drIn("ERSPancreaticPseudocyst"))
            ERSPancreatobiliaryPainCheckBox.Checked = IBool(drIn("ERSPancreatobiliaryPain"))
            ERSPapillaryDysfunctionCheckBox.Checked = IBool(drIn("ERSPapillaryDysfunction"))
            ERSPriSclerosingCholCheckBox.Checked = IBool(drIn("ERSPriSclerosingChol"))

            ERSOtherRadTextBox.Text = Server.HtmlDecode(IStr(drIn("OtherIndication")))
            ERSImportantCommentsRadTextBox.Text = Server.HtmlDecode(IStr(drIn("ClinicallyImpComments")))
            ERSUrgentCheckBox.Checked = IBool(drIn("UrgentTwoWeekReferral"))
            ERSCancerRadComboBox.SelectedValue = IInt(drIn("Cancer"))
            If Not IsDBNull(drIn("WHOStatus")) Then
                ERSWHOPerformanceRadTextBox.Text = Server.HtmlDecode(drIn("WHOStatus").ToString)
                WHOStatusRadioButtonList.SelectedValue = IInt(drIn("WHOStatus"))
            End If
            'FOR ERS/EUS(HPB) PLANNED PROCEDURES
            EPlanCanunulateCheckBox.Checked = IBool(drIn("EPlanCanunulate"))
            EplanManometryCheckBox.Checked = IBool(drIn("EplanManometry"))
            EplanStentremovalCheckBox.Checked = IBool(drIn("EplanStentremoval"))
            EplanCombinedProcedureCheckBox.Checked = IBool(drIn("EplanCombinedProcedure"))
            EplanNasoPancreaticCheckBox.Checked = IBool(drIn("EplanNasoPancreatic"))
            EplanStentReplacementCheckBox.Checked = IBool(drIn("EplanStentReplacement"))
            EPlanEndoscopicCystCheckBox.Checked = IBool(drIn("EPlanEndoscopicCyst"))
            EplanPapillotomyCheckBox.Checked = IBool(drIn("EplanPapillotomy"))
            EplanStoneRemovalCheckBox.Checked = IBool(drIn("EplanStoneRemoval"))
            EplanStentInsertionCheckBox.Checked = IBool(drIn("EplanStentInsertion"))
            EplanStrictureDilatationCheckBox.Checked = IBool(drIn("EplanStrictureDilatation"))
            EplanOthersTextBox.Text = Server.HtmlDecode(IStr(drIn("EplanOthersTextBox")))
            Microlithiasis.Checked = IBool(drIn("ExcludeMicrolithiasis"))

            'FOR ERS/EUS(HPB) FOLLOWUP
            ERSPreviousRadComboBox.SelectedValue = IStr(drIn("ERSFollowPrevious"))
            ERSCarriedOutRadComboBox.SelectedValue = IStr(drIn("ERSFollowCarriedOut"))
            ERSBileDuctCheckBox.Checked = IBool(drIn("ERSFollowBileDuct"))
            ERSMalignancyCheckBox.Checked = IBool(drIn("ERSFollowMalignancy"))
            ERSBiliaryStrictureCheckBox.Checked = IBool(drIn("ERSFollowBiliaryStricture"))
            ERSStentReplacementCheckBox.Checked = IBool(drIn("ERSFollowStentReplacement"))
            ' FOR ERS/EUS(HPB) Imaging
            UltrasoundCheckBox.Checked = IBool(drIn("ERSImgUltrasound"))
            CTCheckBox.Checked = IBool(drIn("ERSImgCT"))
            MRICheckBox.Checked = IBool(drIn("ERSImgMRI"))
            MRCPCheckBox.Checked = IBool(drIn("ERSImgMRCP"))
            IDACheckBox.Checked = IBool(drIn("ERSImgIDA"))
            EUSCheckBoxe.Checked = IBool(drIn("ERSImgEUS"))

            ERSNormalCheckBox.Checked = IBool(drIn("ERSNormal"))
            ERSChronicPancreatitisCheckBox.Checked = IBool(drIn("ERSChronicPancreatitis"))
            ERSAcutePancreatitisCheckBox.Checked = IBool(drIn("ERSAcutePancreatitis"))
            ERSGallBladderCheckBox.Checked = IBool(drIn("ERSGallBladder"))
            AmpullaryMassCheckBox.Checked = IBool(drIn("AmpullaryMass"))
            ERSGallBladderMassCheckBox.Checked = IBool(drIn("GallBladderMass"))
            ERSGallBladderPolypCheckBox.Checked = IBool(drIn("GallBladderPolyp"))
            ERSFluidCollectionCheckBox.Checked = IBool(drIn("ERSFluidCollection"))
            ERSPancreaticMassCheckBox.Checked = IBool(drIn("ERSPancreaticMass"))
            ERSDilatedPancreaticCheckBox.Checked = IBool(drIn("ERSDilatedPancreatic"))
            ERSStonedBiliaryCheckBox.Checked = IBool(drIn("ERSStonedBiliary"))
            ERSHepaticMassCheckBox.Checked = IBool(drIn("ERSHepaticMass"))
            ERSObstructedCheckBox.Checked = IBool(drIn("ERSObstructed"))
            CysticLesionCheckBox.Checked = IBool(drIn("CysticLesion"))
            EUSCysticLesion.Checked = IBool(drIn("EUSCysticLesion"))
            ERSDilatedDuctsCheckBox.Checked = IBool(drIn("ERSDilatedDucts"))
            BiliaryLeakCheckBox.Checked = IBool(drIn("BiliaryLeak"))
            ERSDilatedDuctType1.Checked = IBool(drIn("ERSDilatedDuctsType1"))
            ERSDilatedDuctType2.Checked = IBool(drIn("ERSDilatedDuctsType2"))
            ERSImgOthersTextBox.Text = Server.HtmlDecode(IStr(drIn("ERSImgOthersTextBox")))

            EplanPolypTumourAssessCheckBox.Checked = IBool(drIn("PolypTumourAssess"))
            EplanEMRCheckBox.Checked = IBool(drIn("EMR"))


        Else
            OtherIndicationTextBox.Text = Server.HtmlDecode(IStr(drIn("OtherIndication")))
            ClinicallyImportantCommentsTextBox.Text = Server.HtmlDecode(IStr(drIn("ClinicallyImpComments")))
            UrgentTwoWeekCheckBox.Checked = IBool(drIn("UrgentTwoWeekReferral"))
            CancerComboBox.SelectedValue = IInt(drIn("Cancer"))
            If Not IsDBNull(drIn("WHOStatus")) Then
                WhoPerformanceStatusTextBox.Text = Server.HtmlDecode(drIn("WHOStatus").ToString)
                WHOStatusRadioButtonList.SelectedValue = IInt(drIn("WHOStatus"))
            End If


            StentRemovalCheckBox.Checked = IBool(drIn("StentRemoval"))
            StentInsertionCheckBox.Checked = IBool(drIn("StentInsertion"))
            StentReplacementCheckBox.Checked = IBool(drIn("StentReplacement"))
            BarrettsCheckBox.Checked = IBool(drIn("BarrettsSurveillance"))


            SurgeryFollowUpProcComboBox.SelectedValue = IInt(drIn("SurgeryFollowUpProc"))
            SurgeryFollowUpProcPeriodComboBox.SelectedValue = IInt(drIn("SurgeryFollowUpProcPeriod"))
            SurgeryFollowUpTextBox.Text = Server.HtmlDecode(IStr(drIn("SurgeryFollowUpText")))
        End If

        AnaemiaCheckBox.Checked = IBool(drIn("Anaemia"))
        AnaemiaTypeComboBox.SelectedValue = IInt(drIn("AnaemiaType"))
        AbdominalPainCheckBox.Checked = IBool(drIn("AbdominalPain"))
        AbnormalCapsuleStudyCheckBox.Checked = IBool(drIn("AbnormalCapsuleStudy"))
        AbnormalMRICheckBox.Checked = IBool(drIn("AbnormalMRI"))
        AbnormalityOnBariumCheckBox.Checked = IBool(drIn("AbnormalityOnBarium"))
        ChestPainCheckBox.Checked = IBool(drIn("ChestPain"))
        ChronicLiverCheckBox.Checked = IBool(drIn("ChronicLiverDisease"))
        CoffeeGroundsVomitCheckBox.Checked = IBool(drIn("CoffeeGroundsVomit"))
        DiarrhoeaCheckBox.Checked = IBool(drIn("Diarrhoea"))
        DrugTrialCheckBox.Checked = IBool(drIn("DrugTrial"))
        DyspepsiaCheckBox.Checked = IBool(drIn("Dyspepsia"))
        DyspepsiaAtypicalCheckBox.Checked = IBool(drIn("DyspepsiaAtypical"))
        DyspepsiaUlcerTypeCheckBox.Checked = IBool(drIn("DyspepsiaUlcerType"))
        DysphagiaCheckBox.Checked = IBool(drIn("Dysphagia"))
        HaematemesisCheckBox.Checked = IBool(drIn("Haematemesis"))
        MelaenaCheckBox.Checked = IBool(drIn("Melaena"))
        NauseaAndOrVomitingCheckBox.Checked = IBool(drIn("NauseaAndOrVomiting"))
        OdynophagiaCheckBox.Checked = IBool(drIn("Odynophagia"))
        PositiveTTGCheckBox.Checked = IBool(drIn("PositiveTTG_EMA"))
        RefluxSymptomsCheckBox.Checked = IBool(drIn("RefluxSymptoms"))
        UlcerExclusionCheckBox.Checked = IBool(drIn("UlcerExclusion"))
        WeightLossCheckBox.Checked = IBool(drIn("WeightLoss"))
        PrevHPyloriCheckBox.Checked = IBool(drIn("PreviousHPyloriTest"))
        SerologyCheckBox.Checked = IBool(drIn("SerologyTest"))
        SerologyResultComboBox.SelectedValue = IInt(drIn("SerologyTestResult"))
        BreathCheckBox.Checked = IBool(drIn("BreathTest"))
        BreathResultComboBox.SelectedValue = IInt(drIn("BreathTestResult"))
        UreaseCheckBox.Checked = IBool(drIn("UreaseTest"))
        UreaseResultComboBox.SelectedValue = IInt(drIn("UreaseTestResult"))
        StoolAntigenCheckBox.Checked = IBool(drIn("StoolAntigenTest"))
        StoolAntigenResultComboBox.SelectedValue = IInt(drIn("StoolAntigenTestResult"))
        'OpenAccessCheckbox.Checked = IBool(drIn("OpenAccess"))

        'RadTabStrip1.Tabs(0).ForeColor = Color.Blue

        BariatricPreAssessmentCheckBox.Checked = IBool(drIn("BariatricPreAssessment"))
        BalloonInsertionCheckBox.Checked = IBool(drIn("BalloonInsertion"))
        SingleBalloonEnteroscopyCheckBox.Checked = IBool(drIn("SingleBalloonEnteroscopy"))
        DoubleBalloonEnteroscopyCheckBox.Checked = IBool(drIn("DoubleBalloonEnteroscopy"))
        BalloonRemovalCheckBox.Checked = IBool(drIn("BalloonRemoval"))
        PostBariatricSurgeryAssessmentCheckBox.Checked = IBool(drIn("PostBariatricSurgeryAssessment"))
        EusCheckBox.Checked = IBool(drIn("EUS"))
        GastrostomyInsertionCheckBox.Checked = IBool(drIn("GastrostomyInsertion"))
        InsertionOfPhProbeCheckBox.Checked = IBool(drIn("InsertionOfPHProbe"))
        JejunostomyInsertionCheckBox.Checked = IBool(drIn("JejunostomyInsertion"))
        NasojejunalCheckBox.Checked = IBool(drIn("NasoDuodenalTube"))
        OesophagealDilatationCheckBox.Checked = IBool(drIn("OesophagealDilatation"))
        PegRemovalCheckBox.Checked = IBool(drIn("PEGRemoval"))
        PEGReplacementCheckBox.Checked = IBool(drIn("PEGReplacement"))
        PushEnteroscopyCheckBox.Checked = IBool(drIn("PushEnteroscopy"))
        SmallBowelBiopsyCheckBox.Checked = IBool(drIn("SmallBowelBiopsy"))

        'EUSRefGuidedFNABiopsyCheckbox.Checked = IBool(drIn("EUSRefGuidedFNABiopsy"))
        'EUSOesophagealStrictureCheckbox.Checked = IBool(drIn("EUSOesophagealStricture"))
        'EUSAssessmentOfSubmucosalLesionCheckbox.Checked = IBool(drIn("EUSAssessmentOfSubmucosalLesion"))
        'EUSTumourStagingOesophagealCheckbox.Checked = IBool(drIn("EUSTumourStagingOesophageal"))
        'EUSTumourStagingGastricCheckbox.Checked = IBool(drIn("EUSTumourStagingGastric"))
        'EUSTumourStagingDuodenalCheckbox.Checked = IBool(drIn("EUSTumourStagingDuodenal"))
        OtherPlannedProcedureTextBox.Text = Server.HtmlDecode(IStr(drIn("OtherPlannedProcedure")))
        CoMorbidityNoneCheckbox.Checked = IBool(drIn("CoMorbidityNone"))
        AnginaCheckBox.Checked = IBool(drIn("Angina"))
        AsthmaCheckBox.Checked = IBool(drIn("Asthma"))
        CopdCheckBox.Checked = IBool(drIn("COPD"))
        DiabetesMellitusCheckBox.Checked = IBool(drIn("DiabetesMellitus"))
        DiabetesMellitusTypeComboBox.SelectedValue = IInt(drIn("DiabetesMellitusType"))
        EpilepsyCheckBox.Checked = IBool(drIn("Epilepsy"))
        HemiparesisPostStrokeCheckBox.Checked = IBool(drIn("HemiPostStroke"))
        HypertensionCheckBox.Checked = IBool(drIn("Hypertension"))
        MICheckBox.Checked = IBool(drIn("MI"))
        ObesityCheckBox.Checked = IBool(drIn("Obesity"))
        TiaCheckBox.Checked = IBool(drIn("TIA"))
        OtherCoMorbidityTextBox.Text = Server.HtmlDecode(IStr(drIn("OtherCoMorbidity")))
        If Not IsDBNull(drIn("ASAStatus")) Then AsaStatusRadioButtonList.SelectedValue = IInt(drIn("ASAStatus"))
        DamagingDrugsMultiTextBox.Text = Server.HtmlDecode(IStr(drIn("PotentiallyDamagingDrug")))
        If IInt(drIn("Allergy")) = 1 Then
            AllergyUnknownRadioButton.Checked = True
        ElseIf IInt(drIn("Allergy")) = 2 Then
            AllergyNoneRadioButton.Checked = True
        ElseIf IInt(drIn("Allergy")) = 3 Then
            AllergyYesRadioButton.Checked = True
        End If
        AllergyDescTextBox.Text = Server.HtmlDecode(IStr(drIn("AllergyDesc")))
        'CurrentMedicationTextBox.Text = IStr(drIn("CurrentMedication"))
        'IncludeCurrentRxInReportCheckbox.Checked = IBool(drIn("IncludeCurrentRxInReport"))

        DiseaseFollowUpProcComboBox.SelectedValue = IInt(drIn("DiseaseFollowUpProc"))
        DiseaseFollowUpProcPeriodComboBox.SelectedValue = IInt(drIn("DiseaseFollowUpProcPeriod"))
        BarrettsOesophagusCheckBox.Checked = IBool(drIn("BarrettsOesophagus"))
        CoeliacDiseaseCheckBox.Checked = IBool(drIn("CoeliacDisease"))
        DysplasiaCheckBox.Checked = IBool(drIn("Dysplasia"))
        GastritisCheckbox.Checked = IBool(drIn("Gastritis"))
        MalignancyCheckBox.Checked = IBool(drIn("Malignancy"))
        OesophagealDilatationFollowUpCheckBox.Checked = IBool(drIn("OesophagealDilatationFollowUp"))
        OesophagealVaricesCheckBox.Checked = IBool(drIn("OesophagealVarices"))
        OesophagitisCheckBox.Checked = IBool(drIn("Oesophagitis"))
        UlcerHealingCheckBox.Checked = IBool(drIn("UlcerHealing"))

        PolypTumourAssessCheckBox.Checked = IBool(drIn("PolypTumourAssess"))
        EMRCheckBox.Checked = IBool(drIn("EMR"))

        NGTubeInsertionCheckBox.Checked = IBool(drIn("EPlanNGTubeInsertion"))
        NGTubeRemovalCheckBox.Checked = IBool(drIn("EPlanNGTubeRemoval"))
        AntiCoagRadioButtonList.SelectedValue = IIf(drIn("AntiCoagDrugs"), 1, 0)
        TumourStagingCheckbox.Checked = IBool(drIn("TumourStaging"))
        MediastinalAbnoCheckbox.Checked = IBool(drIn("MediastinalAbnormality"))
        LymphNodeCheckBox.Checked = IBool(drIn("LymphNodeSampling"))
        SubmucosalCheckBox.Checked = IBool(drIn("SubmucosalLesion"))
        FNAMassCheckbox.Checked = IBool(drIn("FNAMass"))
        FNACheckbox.Checked = IBool(drIn("FNA"))
        FNBCheckbox.Checked = IBool(drIn("FNB"))
        IBDSprayCheckbox.Checked = IBool(drIn("IBDSpraySurveillance"))

        'RadTabStrip1.Tabs(1).ImageUrl= "~/images/ok.png"
    End Sub

    Private Sub PopulateGIBleeds(drBl As DataRow)
        Session("GIBAgeRange") = IInt(drBl("AgeRange"))
        Session("GIBGender") = IInt(drBl("Gender"))
        Session("GIBMelaena") = IInt(drBl("Melaena"))
        Session("GIBSyncope") = IInt(drBl("Syncope"))
        Session("GIBLowestSystolicBP") = IInt(drBl("LowestSystolicBP"))
        Session("GIBHighestPulseGreaterThan100") = IInt(drBl("HighestPulseGreaterThan100"))
        Session("GIBUrea") = IInt(drBl("Urea"))
        Session("GIBHaemoglobin") = IInt(drBl("Haemoglobin"))
        Session("GIBHeartFailure") = IInt(drBl("HeartFailure"))
        Session("GIBLiverFailure") = IInt(drBl("LiverFailure"))
        Session("GIBRenalFailure") = IInt(drBl("RenalFailure"))
        Session("GIBMetastaticCancer") = IInt(drBl("MetastaticCancer"))
        Session("GIBDiagnosis") = IInt(drBl("Diagnosis"))
        Session("GIBBleeding") = IInt(drBl("Bleeding"))
        Session("GIBOverallRiskAssessment") = IStr(drBl("OverallRiskAssessment"))
        Session("BlatchfordScore") = IStr(drBl("BlatchfordScore"))
        Session("RockallScore") = IStr(drBl("RockallScore"))
        Session("GIBleedsData") = "set"
    End Sub

    Protected Sub SaveButton_Click(sender As Object, e As EventArgs) Handles SaveButton.Click
        SaveRecord(True)
    End Sub

    Protected Sub SaveOnly_Click(sender As Object, e As EventArgs) Handles SaveOnly.Click
        SaveRecord(False)
    End Sub

    Private Sub SaveRecord(isSaveAndClose As Boolean)
        Dim od As New OtherData
        Dim allergyType As Integer
        Dim whoStatus As Integer
        Dim asaStatus As Nullable(Of Integer) = Nothing
        Dim _FamilyType As Integer
        Dim _AssesmmentType As Integer
        Dim PolypTumourCheck As Boolean
        Dim EMRCheck As Boolean

        Try
            'Dim gogo As Integer = 0
            'Dim hey As Integer = 100 / gogo

            If AllergyUnknownRadioButton.Checked Then
                allergyType = 1
            ElseIf AllergyNoneRadioButton.Checked Then
                allergyType = 2
            ElseIf AllergyYesRadioButton.Checked Then
                allergyType = 3
            End If

            If ColonRiskRadioButton.Checked Then
                _FamilyType = 1
            ElseIf ColonNoRiskRadioButton.Checked Then
                _FamilyType = 2
            ElseIf ColonFamilialRadioButton.Checked Then
                _FamilyType = 3
            ElseIf ColonHistoryRadioButton.Checked Then
                _FamilyType = 4
            ElseIf ColonHereditoryRadioButton.Checked Then
                _FamilyType = 5
            ElseIf ColonHnpccRadioButton.Checked Then
                _FamilyType = 6
            Else
                _FamilyType = 0
            End If

            If ColonUnspecifiedRadioButton.Checked Then
                _AssesmmentType = 1
            ElseIf ColonCrohnRadioButton.Checked Then
                _AssesmmentType = 2
            ElseIf ColonUlcerativeRadioButton.Checked Then
                _AssesmmentType = 3
            Else
                _AssesmmentType = 0
            End If

            Dim Haematemesis As Boolean = False
            Dim AntiCoagDrugs As Boolean = False

            If procType = ProcedureType.Colonoscopy Or procType = ProcedureType.Sigmoidscopy Or procType = ProcedureType.Proctoscopy Then
                If Integer.TryParse(cWhoPerformanceStatusTextBox.Text, whoStatus) = False Then whoStatus = -1
                PolypTumourCheck = ColonPolypTumourAssessCheckBox.Checked
                EMRCheck = ColonEMRCheckBox.Checked
                Haematemesis = ColonLeadingToHaematemesisCheckBox.Checked
                If AntiCoagRadioButtonList.SelectedValue <> "" Then
                    AntiCoagDrugs = AntiCoagRadioButtonList.SelectedValue
                End If
            ElseIf procType = ProcedureType.ERCP Or procType = ProcedureType.EUS_HPB Then
                If Integer.TryParse(ERSWHOPerformanceRadTextBox.Text, whoStatus) = False Then whoStatus = -1
                PolypTumourCheck = EplanPolypTumourAssessCheckBox.Checked
                EMRCheck = EplanEMRCheckBox.Checked
                AntiCoagDrugs = 0
            Else
                If Integer.TryParse(WhoPerformanceStatusTextBox.Text, whoStatus) = False Then whoStatus = -1
                PolypTumourCheck = PolypTumourAssessCheckBox.Checked
                EMRCheck = EMRCheckBox.Checked
                Haematemesis = HaematemesisCheckBox.Checked
                If AntiCoagRadioButtonList.SelectedValue <> "" Then
                    AntiCoagDrugs = AntiCoagRadioButtonList.SelectedValue
                End If
            End If


            'IInt(WHOStatusRadioButtonList.SelectedValue)
            If AsaStatusRadioButtonList.SelectedIndex <> -1 Then asaStatus = IInt(AsaStatusRadioButtonList.SelectedValue)
            Dim iERSPreviousRadComboBox As Integer
            If (procType = ProcedureType.ERCP Or procType = ProcedureType.EUS_HPB) AndAlso ERSPreviousRadComboBox.Text <> "" Then
                If ERSPreviousRadComboBox.SelectedValue = -99 Then 'New Item
                    Dim da As New DataAccess
                    iERSPreviousRadComboBox = da.InsertListItem("Follow up disease/proc ERCP", ERSPreviousRadComboBox.Text)
                Else
                    iERSPreviousRadComboBox = ERSPreviousRadComboBox.SelectedValue
                End If
            End If

            If Session("GIBleedsData") IsNot Nothing AndAlso (HaematemesisCheckBox.Checked Or MelaenaCheckBox.Checked) Then
                Dim gibleeds As GIBleeds = New GIBleeds With {
                .AgeRange = Session("GIBAgeRange"),
                .Gender = Session("GIBGender"),
                .Melaena = Session("GIBMelaena"),
                .Syncope = Session("GIBSyncope"),
                .LowestSystolicBP = Session("GIBLowestSystolicBP"),
                .HighestPulseGreaterThan100 = Session("GIBHighestPulseGreaterThan100"),
                .Urea = Session("GIBUrea"),
                .Haemoglobin = Session("GIBHaemoglobin"),
                .HeartFailure = Session("GIBHeartFailure"),
                .LiverFailure = Session("GIBLiverFailure"),
                .RenalFailure = Session("GIBRenalFailure"),
                .MetastaticCancer = Session("GIBMetastaticCancer"),
                .Diagnosis = Session("GIBDiagnosis"),
                .Bleeding = Session("GIBBleeding"),
                .OverallRiskAssessment = Session("GIBOverallRiskAssessment"),
                .BlatchfordScore = Session("BlatchfordScore"),
                .RockallScore = Session("RockallScore")
                }
                od.SaveUpperGIBleeds(IInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                    gibleeds.AgeRange,
                                    gibleeds.Gender,
                                    gibleeds.Melaena,
                                    gibleeds.Syncope,
                                    gibleeds.LowestSystolicBP,
                                    gibleeds.HighestPulseGreaterThan100,
                                    gibleeds.Urea,
                                    gibleeds.Haemoglobin,
                                    gibleeds.HeartFailure,
                                    gibleeds.LiverFailure,
                                    gibleeds.RenalFailure,
                                    gibleeds.MetastaticCancer,
                                    gibleeds.Diagnosis,
                                    gibleeds.Bleeding,
                                    gibleeds.OverallRiskAssessment,
                                    gibleeds.BlatchfordScore,
                                    gibleeds.RockallScore)
            Else
                od.ClearUpperGIBleeds(IInt(Session(Constants.SESSION_PROCEDURE_ID)))
            End If


            od.SaveUpperGIIndications(IInt(Session(Constants.SESSION_PROCEDURE_ID)),
                                        AnaemiaCheckBox.Checked,
                                        Utilities.GetComboBoxValue(AnaemiaTypeComboBox),
                                        AbdominalPainCheckBox.Checked,
                                        AbnormalCapsuleStudyCheckBox.Checked,
                                        AbnormalMRICheckBox.Checked,
                                        AbnormalityOnBariumCheckBox.Checked,
                                        ChestPainCheckBox.Checked,
                                        ChronicLiverCheckBox.Checked,
                                        CoffeeGroundsVomitCheckBox.Checked,
                                        DiarrhoeaCheckBox.Checked,
                                        DrugTrialCheckBox.Checked,
                                        DyspepsiaCheckBox.Checked,
                                        DyspepsiaAtypicalCheckBox.Checked,
                                        DyspepsiaUlcerTypeCheckBox.Checked,
                                        DysphagiaCheckBox.Checked,
                                        Haematemesis,
                                        MelaenaCheckBox.Checked,
                                        NauseaAndOrVomitingCheckBox.Checked,
                                        PositiveTTGCheckBox.Checked,
                                        OdynophagiaCheckBox.Checked,
                                        RefluxSymptomsCheckBox.Checked,
                                        UlcerExclusionCheckBox.Checked,
                                        WeightLossCheckBox.Checked,
                                        PrevHPyloriCheckBox.Checked,
                                        SerologyCheckBox.Checked,
                                        Utilities.GetComboBoxValue(SerologyResultComboBox),
                                        BreathCheckBox.Checked,
                                        Utilities.GetComboBoxValue(BreathResultComboBox),
                                        UreaseCheckBox.Checked,
                                        Utilities.GetComboBoxValue(UreaseResultComboBox),
                                        StoolAntigenCheckBox.Checked,
                                        Utilities.GetComboBoxValue(StoolAntigenResultComboBox),
                                        False,
                                         returnValue(procType, Server.HtmlEncode(ColonOtherRadTextBox.Text), Server.HtmlEncode(ERSOtherRadTextBox.Text), Server.HtmlEncode(OtherIndicationTextBox.Text)),
                                          returnValue(procType, Server.HtmlEncode(ColonImportantCommentsRadTextBox.Text), Server.HtmlEncode(ERSImportantCommentsRadTextBox.Text), Server.HtmlEncode(ClinicallyImportantCommentsTextBox.Text)),
                                        returnValue(procType, cUrgentCheckBox.Checked, ERSUrgentCheckBox.Checked, UrgentTwoWeekCheckBox.Checked),
                                         returnValue(procType, Utilities.GetComboBoxValue(ColonCancerRadComboBox), Utilities.GetComboBoxValue(ERSCancerRadComboBox), Utilities.GetComboBoxValue(CancerComboBox)),
                                       whoStatus,
                                        BariatricPreAssessmentCheckBox.Checked,
                                        BalloonInsertionCheckBox.Checked,
                                        BalloonRemovalCheckBox.Checked,
                                        SingleBalloonEnteroscopyCheckBox.Checked,
                                        DoubleBalloonEnteroscopyCheckBox.Checked,
                                        PostBariatricSurgeryAssessmentCheckBox.Checked,
                                        EusCheckBox.Checked,
                                        GastrostomyInsertionCheckBox.Checked,
                                        InsertionOfPhProbeCheckBox.Checked,
                                        JejunostomyInsertionCheckBox.Checked,
                                        NasojejunalCheckBox.Checked,
                                        OesophagealDilatationCheckBox.Checked,
                                        PegRemovalCheckBox.Checked,
                                        PEGReplacementCheckBox.Checked,
                                        PushEnteroscopyCheckBox.Checked,
                                        SmallBowelBiopsyCheckBox.Checked,
                                        IIf(procType = 3 Or procType = 4, ColonStentRemovalCheckBox.Checked, StentRemovalCheckBox.Checked),
                                        IIf(procType = 3 Or procType = 4, ColonStentInsertionCheckBox.Checked, StentInsertionCheckBox.Checked),
                                        IIf(procType = 3 Or procType = 4, ColonStentReplacementCheckBox.Checked, StentReplacementCheckBox.Checked),
                                        BarrettsCheckBox.Checked,
                                        False,
                                        False,
                                        False,
                                        False,
                                        False,
                                        False,
                                        Server.HtmlEncode(OtherPlannedProcedureTextBox.Text),
                                        CoMorbidityNoneCheckbox.Checked,
                                        AnginaCheckBox.Checked,
                                        AsthmaCheckBox.Checked,
                                        CopdCheckBox.Checked,
                                        DiabetesMellitusCheckBox.Checked,
                                        Utilities.GetComboBoxValue(DiabetesMellitusTypeComboBox),
                                        EpilepsyCheckBox.Checked,
                                        HemiparesisPostStrokeCheckBox.Checked,
                                        HypertensionCheckBox.Checked,
                                        MICheckBox.Checked,
                                        ObesityCheckBox.Checked,
                                        TiaCheckBox.Checked,
                                        Server.HtmlEncode(OtherCoMorbidityTextBox.Text),
                                        asaStatus,
                                        Server.HtmlEncode(DamagingDrugsMultiTextBox.Text),
                                        allergyType,
                                        Server.HtmlEncode(AllergyDescTextBox.Text),
                                        "",
                                        False,
                                         IIf(procType = 3 Or procType = 4, Utilities.GetComboBoxValue(ColonFollowUpLeftRadComboBox), Utilities.GetComboBoxValue(SurgeryFollowUpProcComboBox)),
                                          IIf(procType = 3 Or procType = 4, Utilities.GetComboBoxValue(ColonFollowUpRightRadComboBox), Utilities.GetComboBoxValue(SurgeryFollowUpProcPeriodComboBox)),
                                          IIf(procType = 3 Or procType = 4, Server.HtmlEncode(ColonFollowUpRadTextBox.Text), Server.HtmlEncode(SurgeryFollowUpTextBox.Text)),
                                        Utilities.GetComboBoxValue(DiseaseFollowUpProcComboBox),
                                        Utilities.GetComboBoxText(DiseaseFollowUpProcComboBox),
                                        Utilities.GetComboBoxValue(DiseaseFollowUpProcPeriodComboBox),
                                        BarrettsOesophagusCheckBox.Checked,
                                        CoeliacDiseaseCheckBox.Checked,
                                        DysplasiaCheckBox.Checked,
                                        GastritisCheckbox.Checked,
                                        MalignancyCheckBox.Checked,
                                        OesophagealDilatationFollowUpCheckBox.Checked,
                                        OesophagealVaricesCheckBox.Checked,
                                        OesophagitisCheckBox.Checked,
                                        UlcerHealingCheckBox.Checked,
                                         ColonScreeningCheckBox.Checked,
                                        ColonBowelCancerCheckBox.Checked,
                                        ColonFOBTCheckBox.Checked,
                                        ColonFITCheckBox.Checked,
                                        ColonIndicationSurveillanceCheckbox.Checked,
                                        IInt(ColonAlterBowelRadComboBox.SelectedValue),
                                        Utilities.GetComboBoxText(ColonAlterBowelRadComboBox),
                                        NationalBowelScopeScreeningCheckBox.Checked,
                                        IInt(ColonRectalRadComboBox.SelectedValue),
                                        Utilities.GetComboBoxText(ColonRectalRadComboBox),
                                        ColonAnamemiaCheckBox.Checked,
                                        IInt(ColonAnaemiaRadComboBox.SelectedValue),
                                        ColonAbnormalCTScanCheckBox.Checked,
                                        ColonAbnormalSigmoidoscopyCheckBox.Checked,
                                        ColonAbnormalBariumEnemaCheckBox.Checked,
                                        ColonAbdominalMassCheckBox.Checked,
                                        ColonDefaecationDisorder.Checked,
                                        ColonColonicObstructionCheckBox.Checked,
                                        ColonAbdominalPainCheckBox.Checked,
                                        ColonFamilyCheckBox.Checked,
                                        _FamilyType,
                                        _AssesmmentType,
                                        Server.HtmlEncode(ColonAdditionalRadTextBox.Text),
                                        ColonAssessmentCheckBox.Checked,
                                        ColonSurveillanceCheckBox.Checked,
                                        ColonCarcinomaCheckBox.Checked,
                                        ColonPolypsCheckBox.Checked,
                                        ColonDysplasiaCheckBox.Checked,
                                        ColonTumourAssessmentCheckBox.Checked,
                                        ColonMelaenaCheckBox.Checked,
                                        PolyposisSyndromeCheckBox.Checked,
                                        ColonRaisedFaecalCalprotectinCheckBox.Checked,
                                        ColonWeightLossCheckBox.Checked,
                                        ERSAbdominalPainCheckBox.Checked,
                                        ERSChronicPancreatisisCheckBox.Checked,
                                        ERSSphincterCheckBox.Checked,
                                        ERSAbnormalEnzymesCheckBox.Checked,
                                        ERSJaundiceCheckBox.Checked,
                                        ERSStentOcclusionCheckBox.Checked,
                                        ERSAcutePancreatitisAcuteCheckBox.Checked,
                                        ERSObstructedCBDCheckBox.Checked,
                                        ERSCBDStonesCheckBox.Checked,
                                        ERSSuspectedPapillaryCheckBox.Checked,
                                        ERSBiliaryLeakCheckBox.Checked,
                                        ERSOpenAccessCheckBox.Checked,
                                        ERSCholangitisCheckBox.Checked,
                                        ERSPrelaparoscopicCheckBox.Checked,
                                        ERSRecurrentPancreatitisCheckBox.Checked,
                                        ERSBileDuctInjuryCheckBox.Checked,
                                        ERSPurulentCholangitisCheckBox.Checked,
                                        ERSPancreaticPseudocystCheckBox.Checked,
                                        ERSPancreatobiliaryPainCheckBox.Checked,
                                        ERSPapillaryDysfunctionCheckBox.Checked,
                                        ERSPriSclerosingCholCheckBox.Checked,
                                        UltrasoundCheckBox.Checked,
                                        CTCheckBox.Checked,
                                        MRICheckBox.Checked,
                                        MRCPCheckBox.Checked,
                                        IDACheckBox.Checked,
                                        EUSCheckBoxe.Checked,
                                        ERSNormalCheckBox.Checked,
                                        ERSChronicPancreatitisCheckBox.Checked,
                                        ERSAcutePancreatitisCheckBox.Checked,
                                        ERSGallBladderCheckBox.Checked,
                                        ERSFluidCollectionCheckBox.Checked,
                                        ERSPancreaticMassCheckBox.Checked,
                                        ERSDilatedPancreaticCheckBox.Checked,
                                        ERSStonedBiliaryCheckBox.Checked,
                                        ERSHepaticMassCheckBox.Checked,
                                        ERSObstructedCheckBox.Checked,
                                        CysticLesionCheckBox.Checked,
                                        ERSDilatedDuctsCheckBox.Checked,
                                        AmpullaryMassCheckBox.Checked,
                                        ERSGallBladderMassCheckBox.Checked,
                                        ERSGallBladderPolypCheckBox.Checked,
                                        BiliaryLeakCheckBox.Checked,
                                        ERSDilatedDuctType1.Checked,
                                        ERSDilatedDuctType2.Checked,
                                        Server.HtmlEncode(ERSImgOthersTextBox.Text),
                                        EPlanCanunulateCheckBox.Checked,
                                        EplanManometryCheckBox.Checked,
                                        EplanStentremovalCheckBox.Checked,
                                        EplanCombinedProcedureCheckBox.Checked,
                                        EplanNasoPancreaticCheckBox.Checked,
                                        EplanStentReplacementCheckBox.Checked,
                                        EPlanEndoscopicCystCheckBox.Checked,
                                        EplanPapillotomyCheckBox.Checked,
                                        EplanStoneRemovalCheckBox.Checked,
                                        EplanStentInsertionCheckBox.Checked,
                                        EplanStrictureDilatationCheckBox.Checked,
                                        Server.HtmlEncode(EplanOthersTextBox.Text),
                                        Microlithiasis.Checked,
                                        iERSPreviousRadComboBox,
                                        IInt(ERSCarriedOutRadComboBox.SelectedValue),
                                        ERSBileDuctCheckBox.Checked,
                                        ERSMalignancyCheckBox.Checked,
                                        ERSBiliaryStrictureCheckBox.Checked,
                                        ERSStentReplacementCheckBox.Checked,
                                        PolypTumourCheck,
                                        EMRCheck,
                                        ColonPlannedPolypectomy.Checked,
                                        NGTubeInsertionCheckBox.Checked,
                                        NGTubeRemovalCheckBox.Checked,
                                        AntiCoagDrugs,
                                        TumourStagingCheckbox.Checked,
                                        MediastinalAbnoCheckbox.Checked,
                                        LymphNodeCheckBox.Checked,
                                        SubmucosalCheckBox.Checked,
                                        FNAMassCheckbox.Checked,
                                        FNACheckbox.Checked,
                                        FNBCheckbox.Checked,
                                        IBDSprayCheckbox.Checked,
                                        EUSCysticLesion.Checked,
                                        isSaveAndClose
)
            If isSaveAndClose Then
                ExitForm()
            End If


            Dim dtIn As DataTable = od.GetUpperGIIndications(IInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtIn.Rows.Count > 0 Then
                PopulateData(dtIn.Rows(0))
            End If
            'Me.Master.SetButtonStyle()

        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while saving Upper GI Indications.", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There is a problem saving data.")
            RadNotification1.Show()
        End Try
    End Sub

    Function returnValue(ProType As Integer, ColonValue As Object, ERCPValue As Object, otherValue As Object) As Object
        If ProType = ProcedureType.Colonoscopy Or ProType = ProcedureType.Sigmoidscopy Or procType = ProcedureType.Proctoscopy Then
            Return ColonValue
        ElseIf ProType = ProcedureType.ERCP Or ProType = ProcedureType.EUS_HPB Then
            Return ERCPValue
        Else
            Return otherValue
        End If
    End Function
    Protected Sub CancelButton_Click(sender As Object, e As EventArgs) Handles CancelButton.Click
        ExitForm()
    End Sub

    Sub ExitForm()
        Try
            If AntiCoagRadioButtonList.SelectedValue = "" Then
                AntiCoagRadioButtonList.SelectedValue = 0
            End If

            'If (AntiCoagRadioButtonList.SelectedValue = 1) And Not IsRxComplete() Then
            'Response.Clear()
            'Response.Redirect("~/Products/Gastro/OtherData/OGD/Rx.aspx", False)
            'Else
            Response.Clear()
            Response.Redirect("~/Products/PatientProcedure.aspx", False)
            'End If

        Catch ex As Exception
        End Try
    End Sub

    Private Function IsRxComplete() As Boolean
        Dim od As New OtherData
        od = New OtherData()
        Return od.IsRxComplete(IInt(Session(Constants.SESSION_PROCEDURE_ID)))
    End Function


    'Initilalise this when the page loads and when data is bound
    Protected Sub AddButton_Click(sender As Object, e As EventArgs)

        Dim sb As New StringBuilder()
        Dim collection As IList(Of RadComboBoxItem) = DamagingDrugsComboBox.CheckedItems
        Dim last As RadComboBoxItem
        If collection.Count > 0 Then
            last = collection.Last

            Dim iSelectionCount As Integer = collection.Count
            Dim bFirstItem As Boolean = True

            If (iSelectionCount <> 0) Then
                For Each item As RadComboBoxItem In collection

                    If item.Value = -55 Then Continue For

                    If iSelectionCount > 1 And Not bFirstItem Then
                        If item.Equals(last) Then
                            If InStr(item.Text, " and ") > 0 Then
                                sb.Append(", ")
                            Else
                                sb.Append(" and ")
                            End If
                        Else
                            sb.Append(", ")
                        End If
                    End If
                    If InStr(item.Text, "NSAID") > 0 Then
                        item.Text = Replace(item.Text.ToLower, "nsaid", "NSAID")
                    Else
                        item.Text = item.Text.ToLower
                    End If
                    sb.Append(item.Text)
                    bFirstItem = False
                Next
                DamagingDrugsMultiTextBox.Text = Server.HtmlDecode(sb.ToString())
            End If
        Else
            DamagingDrugsMultiTextBox.Text = ""
        End If

        'Exit Sub
        'If DamagingDrugsComboBox.SelectedItem.Text = "(none)" AndAlso DamagingDrugsMultiTextBox.Text = "" Then
        '    DamagingDrugsMultiTextBox.Text = "(none)"
        '    Exit Sub
        'End If

        'If DamagingDrugsMultiTextBox.Text = "(none)" Or DamagingDrugsMultiTextBox.Text = "" Then
        '    DamagingDrugsMultiTextBox.Text = ""
        '    DamagingDrugsMultiTextBox.Text = DamagingDrugsComboBox.SelectedItem.Text
        '    Exit Sub
        'End If

        'Dim str As String = DamagingDrugsMultiTextBox.Text
        'Dim lstr As New Dictionary(Of String, String)

        'For i = 0 To DamagingDrugsComboBox.Items.Count - 1
        '    Dim itm As String = DamagingDrugsComboBox.Items(i).Text
        '    If itm.Contains(" and ") Then
        '        Dim lcount As String = lstr.Count.ToString
        '        str = str.Replace(itm, lstr.Count.ToString)
        '        lstr.Add(lcount, itm.ToLower)
        '    End If
        'Next
        'If Not str.Contains(" and ") Then
        '    For Each g In lstr
        '        str = str.Replace(g.Key, g.Value)
        '    Next
        '    DamagingDrugsMultiTextBox.Text = str + " and " + DamagingDrugsComboBox.SelectedItem.Text
        'Else

        '    Dim firstpart As String = str.Substring(0, str.LastIndexOf(" and "))
        '    Dim lastpart As String = str.Substring(str.LastIndexOf(" and ") + 1).Replace("and ", ", ")

        '    str = firstpart + lastpart
        '    For Each g In lstr
        '        str = str.Replace(g.Key, g.Value)
        '    Next

        '    DamagingDrugsMultiTextBox.Text = str + " and " + DamagingDrugsComboBox.SelectedItem.Text
        'End If
        'ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key00", "MedicationsTab", True)
    End Sub

    'Protected Sub CurrentRXButton_Click(sender As Object, e As EventArgs) Handles CurrentRXButton.Click
    '    Dim script As String = "function f(){$find(""" + CurrentRXWindow.ClientID & """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
    '    ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key", script, True)
    'End Sub

    'Protected Sub ShowSetMedicationWindow(sender As Object, e As EventArgs)

    '    Dim script As String = "function f(){$find(""" + SetMedicationWindow.ClientID & """).show(); Sys.Application.remove_load(f);}Sys.Application.add_load(f);"
    '    ScriptManager.RegisterStartupScript(Me, Me.[GetType](), "key1", script, True)
    'End Sub

End Class