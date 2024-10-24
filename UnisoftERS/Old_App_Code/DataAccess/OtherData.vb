Imports Microsoft.VisualBasic
Imports UnisoftERS.Constants
Imports System.Data.SqlClient


Public Class OtherData

    Private ReadOnly Property LoggedInUserId As Integer
        Get
            Return CInt(HttpContext.Current.Session("PKUserID"))
        End Get
    End Property

#Region "Upper GI Indications"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUpperGIIndications(ByVal procedureId As Integer) As DataTable
        Using da As New DataAccess
            Return da.ExecuteSP("OGD_Indications_Select", New SqlParameter() {New SqlParameter("@ProcedureId", procedureId)})
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveUpperGIIndications(ByVal ProcedureId As Integer,
                                            ByVal Anaemia As Boolean,
                                            ByVal AnaemiaType As Integer,
                                            ByVal AbdominalPain As Boolean,
                                            ByVal AbnormalCapsuleStudy As Boolean,
                                            ByVal AbnormalMRI As Boolean,
                                            ByVal AbnormalityOnBarium As Boolean,
                                            ByVal ChestPain As Boolean,
                                            ByVal ChronicLiverDisease As Boolean,
                                            ByVal CoffeeGroundsVomit As Boolean,
                                            ByVal Diarrhoea As Boolean,
                                            ByVal DrugTrial As Boolean,
                                            ByVal Dyspepsia As Boolean,
                                            ByVal DyspepsiaAtypical As Boolean,
                                            ByVal DyspepsiaUlcerType As Boolean,
                                            ByVal Dysphagia As Boolean,
                                            ByVal Haematemesis As Boolean,
                                            ByVal Melaena As Boolean,
                                            ByVal NauseaAndOrVomiting As Boolean,
                                            ByVal PositiveTTG As Boolean,
                                            ByVal Odynophagia As Boolean,
                                            ByVal RefluxSymptoms As Boolean,
                                            ByVal UlcerExclusion As Boolean,
                                            ByVal WeightLoss As Boolean,
                                            ByVal PreviousHPyloriTest As Boolean,
                                            ByVal SerologyTest As Boolean,
                                            ByVal SerologyTestResult As Integer,
                                            ByVal BreathTest As Boolean,
                                            ByVal BreathTestResult As Integer,
                                            ByVal UreaseTest As Boolean,
                                            ByVal UreaseTestResult As Integer,
                                            ByVal StoolAntigenTest As Boolean,
                                            ByVal StoolAntigenTestResult As Integer,
                                            ByVal OpenAccess As Boolean,
                                            ByVal OtherIndication As String,
                                            ByVal ClinicallyImpComments As String,
                                            ByVal UrgentTwoWeekReferral As Boolean,
                                            ByVal Cancer As Integer,
                                            ByVal WHOStatus As Nullable(Of Integer),
                                            ByVal BariatricPreAssessment As Boolean,
                                            ByVal BalloonInsertion As Boolean,
                                            ByVal BalloonRemoval As Boolean,
                                            ByVal SingleBalloonEnteroscopy As Boolean,
                                            ByVal DoubleBalloonEnteroscopy As Boolean,
                                            ByVal PostBariatricSurgeryAssessment As Boolean,
                                            ByVal EUS As Boolean,
                                            ByVal GastrostomyInsertion As Boolean,
                                            ByVal InsertionOfPHProbe As Boolean,
                                            ByVal JejunostomyInsertion As Boolean,
                                            ByVal NasoDuodenalTube As Boolean,
                                            ByVal OesophagealDilatation As Boolean,
                                            ByVal PEGRemoval As Boolean,
                                            ByVal PEGReplacement As Boolean,
                                            ByVal PushEnteroscopy As Boolean,
                                            ByVal SmallBowelBiopsy As Boolean,
                                            ByVal StentRemoval As Boolean,
                                            ByVal StentInsertion As Boolean,
                                            ByVal StentReplacement As Boolean,
                                           ByVal BarrettsSurveillance As Boolean,
                                            ByVal EUSRefGuidedFNABiopsy As Boolean,
                                            ByVal EUSOesophagealStricture As Boolean,
                                            ByVal EUSAssessmentOfSubmucosalLesion As Boolean,
                                            ByVal EUSTumourStagingOesophageal As Boolean,
                                            ByVal EUSTumourStagingGastric As Boolean,
                                            ByVal EUSTumourStagingDuodenal As Boolean,
                                            ByVal OtherPlannedProcedure As String,
                                            ByVal CoMorbidityNone As Boolean,
                                            ByVal Angina As Boolean,
                                            ByVal Asthma As Boolean,
                                            ByVal COPD As Boolean,
                                            ByVal DiabetesMellitus As Boolean,
                                            ByVal DiabetesMellitusType As Integer,
                                            ByVal Epilepsy As Boolean,
                                            ByVal HemiPostStroke As Boolean,
                                            ByVal Hypertension As Boolean,
                                            ByVal MI As Boolean,
                                            ByVal Obesity As Boolean,
                                            ByVal TIA As Boolean,
                                            ByVal OtherCoMorbidity As String,
                                            ByVal ASAStatus As Nullable(Of Integer),
                                            ByVal PotentiallyDamagingDrug As String,
                                            ByVal Allergy As Integer,
                                            ByVal AllergyDesc As String,
                                            ByVal CurrentMedication As String,
                                            ByVal IncludeCurrentRxInReport As Boolean,
                                            ByVal SurgeryFollowUpProc As Integer,
                                            ByVal SurgeryFollowUpProcPeriod As Integer,
                                            ByVal SurgeryFollowUpText As String,
                                            ByVal DiseaseFollowUpProc As Integer,
                                            ByVal DiseaseFollowUpProcText As String,
                                            ByVal DiseaseFollowUpProcPeriod As Integer,
                                            ByVal BarrettsOesophagus As Boolean,
                                            ByVal CoeliacDisease As Boolean,
                                            ByVal Dysplasia As Boolean,
                                            ByVal Gastritis As Boolean,
                                            ByVal Malignancy As Boolean,
                                            ByVal OesophagealDilatationFollowUp As Boolean,
                                            ByVal OesophagealVarices As Boolean,
                                            ByVal Oesophagitis As Boolean,
                                            ByVal UlcerHealing As Boolean,
                                            ByVal ColonSreeningColonoscopy As Boolean,
                                            ByVal ColonBowelCancerScreening As Boolean,
                                            ByVal ColonFOBT As Boolean,
                                            ByVal ColonFIT As Boolean,
                                           ByVal ColonIndicationSurveillance As Boolean,
                                            ByVal ColonAlterBowelHabit As Integer,
                                            ByVal ColonAlterBowelHabitNewItemText As String,
                                           ByVal NationalBowelScopeScreening As Boolean,
                                            ByVal ColonRectalBleeding As Integer,
                                            ByVal ColonRectalBleedingNewItemText As String,
                                            ByVal ColonAnaemia As Boolean,
                                            ByVal ColonAnaemiaType As Integer,
                                             ByVal ColonAbnormalCTScan As Boolean,
                                            ByVal ColonAbnormalSigmoidoscopy As Boolean,
                                            ByVal ColonAbnormalBariumEnema As Boolean,
                                            ByVal ColonAbdominalMass As Boolean,
                                            ByVal ColonDefaecationDisorder As Boolean,
                                            ByVal ColonColonicObstruction As Boolean,
                                            ByVal ColonAbdominalPain As Boolean,
                                            ByVal ColonFamily As Boolean,
                                            ByVal ColonFamilyType As Integer,
                                            ByVal ColonAssessmentType As Integer,
                                            ByVal ColonFamilyAdditionalText As String,
                                            ByVal ColonAssessment As Boolean,
                                            ByVal ColonSurveillance As Boolean,
                                            ByVal ColonCarcinoma As Boolean,
                                            ByVal ColonPolyps As Boolean,
                                            ByVal ColonDysplasia As Boolean,
                                            ByVal ColonTumourAssessment As Boolean,
                                            ByVal ColonMelaena As Boolean,
                                            ByVal ColonPolyposisSyndrome As Boolean,
                                            ByVal ColonRaisedFaecalCalprotectin As Boolean,
                                            ByVal ColonWeightLoss As Boolean,
                                           ERSAbdominalPain As Boolean,
                                            ERSChronicPancreatisis As Boolean,
                                            ERSSphincter As Boolean,
                                            ERSAbnormalEnzymes As Boolean,
                                            ERSJaundice As Boolean,
                                            ERSStentOcclusion As Boolean,
                                            ERSAcutePancreatitisAcute As Boolean,
                                            ERSObstructedCBD As Boolean,
                                            ERSCBDStones As Boolean,
                                            ERSSuspectedPapillary As Boolean,
                                            ERSBiliaryLeak As Boolean,
                                            ERSOpenAccess As Boolean,
                                            ERSCholangitis As Boolean,
                                            ERSPrelaparoscopic As Boolean,
                                            ERSRecurrentPancreatitis As Boolean,
                                            ERSBileDuctInjury As Boolean,
                                            ERSPurulentCholangitis As Boolean,
                                            ERSPancreaticPseudocyst As Boolean,
                                            ERSPancreatobiliaryPain As Boolean,
                                            ERSPapillaryDysfunction As Boolean,
                                            ERSPriSclerosingChol As Boolean,
                                            ERSImgUltrasound As Boolean,
                                            ERSImgCT As Boolean,
                                            ERSImgMRI As Boolean,
                                            ERSImgMRCP As Boolean,
                                            ERSImgIDA As Boolean,
                                            ERSImgEUS As Boolean,
                                            ERSNormal As Boolean,
                                            ERSChronicPancreatitis As Boolean,
                                            ERSAcutePancreatitis As Boolean,
                                            ERSGallBladder As Boolean,
                                            ERSFluidCollection As Boolean,
                                            ERSPancreaticMass As Boolean,
                                            ERSDilatedPancreatic As Boolean,
                                            ERSStonedBiliary As Boolean,
                                            ERSHepaticMass As Boolean,
                                            ERSObstructed As Boolean,
                                            CysticLesion As Boolean,
                                            ERSDilatedDucts As Boolean,
                                            AmpullaryMass As Boolean,
                                            GallBladderMass As Boolean,
                                            GallBladderPolyp As Boolean,
                                            BiliaryLeak As Boolean,
                                            ERSDilatedDuctsType1 As Boolean,
                                            ERSDilatedDuctsType2 As Boolean,
                                            ERSImgOthersTextBox As String,
                                            EPlanCanunulate As Boolean,
                                            EplanManometry As Boolean,
                                            EplanStentremoval As Boolean,
                                            EplanCombinedProcedure As Boolean,
                                            EplanNasoPancreatic As Boolean,
                                            EplanStentReplacement As Boolean,
                                            EPlanEndoscopicCyst As Boolean,
                                            EplanPapillotomy As Boolean,
                                            EplanStoneRemoval As Boolean,
                                            EplanStentInsertion As Boolean,
                                            EplanStrictureDilatation As Boolean,
                                            EplanOthersTextBox As String,
                                            Microlithiasis As String,
                                            ERSFollowPrevious As Integer,
                                            ERSFollowCarriedOut As Integer,
                                            ERSFollowBileDuct As Boolean,
                                            ERSFollowMalignancy As Boolean,
                                            ERSFollowBiliaryStricture As Boolean,
                                            ERSFollowStentReplacement As Boolean,
                                            PolypTumourAssess As Boolean,
                                            EMR As Boolean,
                                            ColonPlannedPolypectomy As Boolean,
                                            NGTubeInsertion As Boolean,
                                            NGTubeRemoval As Boolean,
                                            AntiCoagDrugs As Boolean,
                                           TumourStaging As Boolean,
                                           MediastinalAbno As Boolean,
                                           LymphNode As Boolean,
                                           SubmucosalLesion As Boolean,
                                           FNAMass As Boolean,
                                           FNA As Boolean,
                                           FNB As Boolean,
                                           IBDSpray As Boolean,
                                           EUSCysticLesion As Boolean,
                                            Optional ByVal setComplete As Boolean = True) As Integer
        Dim rowsAffected As Integer

        If DiseaseFollowUpProc = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Follow up disease/proc Upper GI", DiseaseFollowUpProcText)
            If newId > 0 Then
                DiseaseFollowUpProc = newId
            End If
        End If

        If ColonAlterBowelHabit = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Indications Colon Altered Bowel Habit", ColonAlterBowelHabitNewItemText)
            If newId > 0 Then
                ColonAlterBowelHabit = newId
            End If
        End If

        If ColonRectalBleeding = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Indications Colon Rectal Bleeding", ColonRectalBleedingNewItemText)
            If newId > 0 Then
                ColonRectalBleeding = newId
            End If
        End If

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("OGD_Indications_Save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@Anaemia", Anaemia))
            cmd.Parameters.Add(New SqlParameter("@AnaemiaType", AnaemiaType))
            cmd.Parameters.Add(New SqlParameter("@AbdominalPain", AbdominalPain))
            cmd.Parameters.Add(New SqlParameter("@AbnormalCapsuleStudy", AbnormalCapsuleStudy))
            cmd.Parameters.Add(New SqlParameter("@AbnormalMRI", AbnormalMRI))
            cmd.Parameters.Add(New SqlParameter("@AbnormalityOnBarium", AbnormalityOnBarium))
            cmd.Parameters.Add(New SqlParameter("@ChestPain", ChestPain))
            cmd.Parameters.Add(New SqlParameter("@ChronicLiverDisease", ChronicLiverDisease))
            cmd.Parameters.Add(New SqlParameter("@CoffeeGroundsVomit", CoffeeGroundsVomit))
            cmd.Parameters.Add(New SqlParameter("@Diarrhoea", Diarrhoea))
            cmd.Parameters.Add(New SqlParameter("@DrugTrial", DrugTrial))
            cmd.Parameters.Add(New SqlParameter("@Dyspepsia", Dyspepsia))
            cmd.Parameters.Add(New SqlParameter("@DyspepsiaAtypical", DyspepsiaAtypical))
            cmd.Parameters.Add(New SqlParameter("@DyspepsiaUlcerType", DyspepsiaUlcerType))
            cmd.Parameters.Add(New SqlParameter("@Dysphagia", Dysphagia))
            cmd.Parameters.Add(New SqlParameter("@Haematemesis", Haematemesis))
            cmd.Parameters.Add(New SqlParameter("@Melaena", Melaena))
            cmd.Parameters.Add(New SqlParameter("@NauseaAndOrVomiting", NauseaAndOrVomiting))
            cmd.Parameters.Add(New SqlParameter("@PositiveTTG", PositiveTTG))
            cmd.Parameters.Add(New SqlParameter("@Odynophagia", Odynophagia))
            cmd.Parameters.Add(New SqlParameter("@RefluxSymptoms", RefluxSymptoms))
            cmd.Parameters.Add(New SqlParameter("@UlcerExclusion", UlcerExclusion))
            cmd.Parameters.Add(New SqlParameter("@WeightLoss", WeightLoss))
            cmd.Parameters.Add(New SqlParameter("@PreviousHPyloriTest", PreviousHPyloriTest))
            cmd.Parameters.Add(New SqlParameter("@SerologyTest", SerologyTest))
            cmd.Parameters.Add(New SqlParameter("@SerologyTestResult", SerologyTestResult))
            cmd.Parameters.Add(New SqlParameter("@BreathTest", BreathTest))
            cmd.Parameters.Add(New SqlParameter("@BreathTestResult", BreathTestResult))
            cmd.Parameters.Add(New SqlParameter("@UreaseTest", UreaseTest))
            cmd.Parameters.Add(New SqlParameter("@UreaseTestResult", UreaseTestResult))
            cmd.Parameters.Add(New SqlParameter("@StoolAntigenTest", StoolAntigenTest))
            cmd.Parameters.Add(New SqlParameter("@StoolAntigenTestResult", StoolAntigenTestResult))
            cmd.Parameters.Add(New SqlParameter("@OpenAccess", OpenAccess))
            cmd.Parameters.Add(New SqlParameter("@OtherIndication", OtherIndication))
            cmd.Parameters.Add(New SqlParameter("@ClinicallyImpComments", ClinicallyImpComments))
            cmd.Parameters.Add(New SqlParameter("@UrgentTwoWeekReferral", UrgentTwoWeekReferral))
            cmd.Parameters.Add(New SqlParameter("@Cancer", Cancer))
            If WHOStatus.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@WHOStatus", WHOStatus))
            Else
                cmd.Parameters.Add(New SqlParameter("@WHOStatus", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@BariatricPreAssessment", BariatricPreAssessment))
            cmd.Parameters.Add(New SqlParameter("@BalloonInsertion", BalloonInsertion))
            cmd.Parameters.Add(New SqlParameter("@BalloonRemoval", BalloonRemoval))
            cmd.Parameters.Add(New SqlParameter("@SingleBalloonEnteroscopy", SingleBalloonEnteroscopy))
            cmd.Parameters.Add(New SqlParameter("@DoubleBalloonEnteroscopy", DoubleBalloonEnteroscopy))
            cmd.Parameters.Add(New SqlParameter("@PostBariatricSurgeryAssessment", PostBariatricSurgeryAssessment))
            cmd.Parameters.Add(New SqlParameter("@EUS", EUS))
            cmd.Parameters.Add(New SqlParameter("@GastrostomyInsertion", GastrostomyInsertion))
            cmd.Parameters.Add(New SqlParameter("@InsertionOfPHProbe", InsertionOfPHProbe))
            cmd.Parameters.Add(New SqlParameter("@JejunostomyInsertion", JejunostomyInsertion))
            cmd.Parameters.Add(New SqlParameter("@NasoDuodenalTube", NasoDuodenalTube))
            cmd.Parameters.Add(New SqlParameter("@OesophagealDilatation", OesophagealDilatation))
            cmd.Parameters.Add(New SqlParameter("@PEGRemoval", PEGRemoval))
            cmd.Parameters.Add(New SqlParameter("@PEGReplacement", PEGReplacement))
            cmd.Parameters.Add(New SqlParameter("@PushEnteroscopy", PushEnteroscopy))
            cmd.Parameters.Add(New SqlParameter("@SmallBowelBiopsy", SmallBowelBiopsy))
            cmd.Parameters.Add(New SqlParameter("@StentRemoval", StentRemoval))
            cmd.Parameters.Add(New SqlParameter("@StentInsertion", StentInsertion))
            cmd.Parameters.Add(New SqlParameter("@StentReplacement", StentReplacement))
            cmd.Parameters.Add(New SqlParameter("@BarrettsSurveillance", BarrettsSurveillance))
            cmd.Parameters.Add(New SqlParameter("@EUSRefGuidedFNABiopsy", EUSRefGuidedFNABiopsy))
            cmd.Parameters.Add(New SqlParameter("@EUSOesophagealStricture", EUSOesophagealStricture))
            cmd.Parameters.Add(New SqlParameter("@EUSAssessmentOfSubmucosalLesion", EUSAssessmentOfSubmucosalLesion))
            cmd.Parameters.Add(New SqlParameter("@EUSTumourStagingOesophageal", EUSTumourStagingOesophageal))
            cmd.Parameters.Add(New SqlParameter("@EUSTumourStagingGastric", EUSTumourStagingGastric))
            cmd.Parameters.Add(New SqlParameter("@EUSTumourStagingDuodenal", EUSTumourStagingDuodenal))
            cmd.Parameters.Add(New SqlParameter("@OtherPlannedProcedure", OtherPlannedProcedure))
            cmd.Parameters.Add(New SqlParameter("@CoMorbidityNone", CoMorbidityNone))
            cmd.Parameters.Add(New SqlParameter("@Angina", Angina))
            cmd.Parameters.Add(New SqlParameter("@Asthma", Asthma))
            cmd.Parameters.Add(New SqlParameter("@COPD", COPD))
            cmd.Parameters.Add(New SqlParameter("@DiabetesMellitus", DiabetesMellitus))
            cmd.Parameters.Add(New SqlParameter("@DiabetesMellitusType", DiabetesMellitusType))
            cmd.Parameters.Add(New SqlParameter("@Epilepsy", Epilepsy))
            cmd.Parameters.Add(New SqlParameter("@HemiPostStroke", HemiPostStroke))
            cmd.Parameters.Add(New SqlParameter("@Hypertension", Hypertension))
            cmd.Parameters.Add(New SqlParameter("@MI", MI))
            cmd.Parameters.Add(New SqlParameter("@Obesity", Obesity))
            cmd.Parameters.Add(New SqlParameter("@TIA", TIA))
            cmd.Parameters.Add(New SqlParameter("@OtherCoMorbidity", OtherCoMorbidity))
            If ASAStatus.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ASAStatus", ASAStatus))
            Else
                cmd.Parameters.Add(New SqlParameter("@ASAStatus", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@PotentiallyDamagingDrug", PotentiallyDamagingDrug))
            cmd.Parameters.Add(New SqlParameter("@Allergy", Allergy))
            cmd.Parameters.Add(New SqlParameter("@AllergyDesc", AllergyDesc))
            cmd.Parameters.Add(New SqlParameter("@CurrentMedication", CurrentMedication))
            cmd.Parameters.Add(New SqlParameter("@IncludeCurrentRxInReport", IncludeCurrentRxInReport))
            cmd.Parameters.Add(New SqlParameter("@SurgeryFollowUpProc", SurgeryFollowUpProc))
            cmd.Parameters.Add(New SqlParameter("@SurgeryFollowUpProcPeriod", SurgeryFollowUpProcPeriod))
            cmd.Parameters.Add(New SqlParameter("@SurgeryFollowUpText", SurgeryFollowUpText))
            cmd.Parameters.Add(New SqlParameter("@DiseaseFollowUpProc", DiseaseFollowUpProc))
            cmd.Parameters.Add(New SqlParameter("@DiseaseFollowUpProcPeriod", DiseaseFollowUpProcPeriod))
            cmd.Parameters.Add(New SqlParameter("@BarrettsOesophagus", BarrettsOesophagus))
            cmd.Parameters.Add(New SqlParameter("@CoeliacDisease", CoeliacDisease))
            cmd.Parameters.Add(New SqlParameter("@Dysplasia", Dysplasia))
            cmd.Parameters.Add(New SqlParameter("@Gastritis", Gastritis))
            cmd.Parameters.Add(New SqlParameter("@Malignancy", Malignancy))
            cmd.Parameters.Add(New SqlParameter("@OesophagealDilatationFollowUp", OesophagealDilatationFollowUp))
            cmd.Parameters.Add(New SqlParameter("@OesophagealVarices", OesophagealVarices))
            cmd.Parameters.Add(New SqlParameter("@Oesophagitis", Oesophagitis))
            cmd.Parameters.Add(New SqlParameter("@UlcerHealing", UlcerHealing))

            cmd.Parameters.Add(New SqlParameter("@ColonSreeningColonoscopy", ColonSreeningColonoscopy))
            cmd.Parameters.Add(New SqlParameter("@ColonBowelCancerScreening", ColonBowelCancerScreening))
            cmd.Parameters.Add(New SqlParameter("@ColonFOBT", ColonFOBT))
            cmd.Parameters.Add(New SqlParameter("@ColonFIT", ColonFIT))
            cmd.Parameters.Add(New SqlParameter("@ColonIndicationSurveillance", ColonIndicationSurveillance))
            cmd.Parameters.Add(New SqlParameter("@ColonAlterBowelHabit", ColonAlterBowelHabit))
            cmd.Parameters.Add(New SqlParameter("@NationalBowelScopeScreening", NationalBowelScopeScreening))
            cmd.Parameters.Add(New SqlParameter("@ColonRectalBleeding", ColonRectalBleeding))
            cmd.Parameters.Add(New SqlParameter("@ColonAnaemia", ColonAnaemia))
            cmd.Parameters.Add(New SqlParameter("@ColonAnaemiaType", ColonAnaemiaType))

            cmd.Parameters.Add(New SqlParameter("@ColonAbnormalCTScan", ColonAbnormalCTScan))
            cmd.Parameters.Add(New SqlParameter("@ColonAbnormalSigmoidoscopy", ColonAbnormalSigmoidoscopy))
            cmd.Parameters.Add(New SqlParameter("@ColonAbnormalBariumEnema", ColonAbnormalBariumEnema))
            cmd.Parameters.Add(New SqlParameter("@ColonAbdominalMass", ColonAbdominalMass))
            cmd.Parameters.Add(New SqlParameter("@ColonDefaecationDisorder", ColonDefaecationDisorder))
            cmd.Parameters.Add(New SqlParameter("@ColonColonicObstruction", ColonColonicObstruction))
            cmd.Parameters.Add(New SqlParameter("@ColonAbdominalPain", ColonAbdominalPain))

            cmd.Parameters.Add(New SqlParameter("@ColonTumourAssessment", ColonTumourAssessment))
            cmd.Parameters.Add(New SqlParameter("@ColonMelaena", ColonMelaena))
            cmd.Parameters.Add(New SqlParameter("@ColonPolyposisSyndrome", ColonPolyposisSyndrome))
            cmd.Parameters.Add(New SqlParameter("@ColonRaisedFaecalCalprotectin", ColonRaisedFaecalCalprotectin))
            cmd.Parameters.Add(New SqlParameter("@ColonWeightLoss", ColonWeightLoss))

            cmd.Parameters.Add(New SqlParameter("@ColonFamily", ColonFamily))
            cmd.Parameters.Add(New SqlParameter("@ColonAssessment", ColonAssessment))
            cmd.Parameters.Add(New SqlParameter("@ColonSurveillance", ColonSurveillance))
            cmd.Parameters.Add(New SqlParameter("@ColonFamilyType", ColonFamilyType))
            cmd.Parameters.Add(New SqlParameter("@ColonAssessmentType", ColonAssessmentType))
            cmd.Parameters.Add(New SqlParameter("@ColonFamilyAdditionalText", ColonFamilyAdditionalText))
            cmd.Parameters.Add(New SqlParameter("@ColonCarcinoma", ColonCarcinoma))
            cmd.Parameters.Add(New SqlParameter("@ColonPolyps", ColonPolyps))
            cmd.Parameters.Add(New SqlParameter("@ColonDysplasia", ColonDysplasia))

            cmd.Parameters.Add(New SqlParameter("@ERSAbdominalPain", ERSAbdominalPain))
            cmd.Parameters.Add(New SqlParameter("@ERSChronicPancreatisis", ERSChronicPancreatisis))
            cmd.Parameters.Add(New SqlParameter("@ERSSphincter", ERSSphincter))
            cmd.Parameters.Add(New SqlParameter("@ERSAbnormalEnzymes", ERSAbnormalEnzymes))
            cmd.Parameters.Add(New SqlParameter("@ERSJaundice", ERSJaundice))
            cmd.Parameters.Add(New SqlParameter("@ERSStentOcclusion", ERSStentOcclusion))
            cmd.Parameters.Add(New SqlParameter("@ERSAcutePancreatitisAcute", ERSAcutePancreatitisAcute))
            cmd.Parameters.Add(New SqlParameter("@ERSObstructedCBD", ERSObstructedCBD))
            cmd.Parameters.Add(New SqlParameter("@ERSCBDStones", ERSCBDStones))
            cmd.Parameters.Add(New SqlParameter("@ERSSuspectedPapillary", ERSSuspectedPapillary))
            cmd.Parameters.Add(New SqlParameter("@ERSBiliaryLeak", ERSBiliaryLeak))
            cmd.Parameters.Add(New SqlParameter("@ERSOpenAccess", ERSOpenAccess))
            cmd.Parameters.Add(New SqlParameter("@ERSCholangitis", ERSCholangitis))
            cmd.Parameters.Add(New SqlParameter("@ERSPrelaparoscopic", ERSPrelaparoscopic))
            cmd.Parameters.Add(New SqlParameter("@ERSRecurrentPancreatitis", ERSRecurrentPancreatitis))
            cmd.Parameters.Add(New SqlParameter("@ERSBileDuctInjury", ERSBileDuctInjury))
            cmd.Parameters.Add(New SqlParameter("@ERSPurulentCholangitis", ERSPurulentCholangitis))
            cmd.Parameters.Add(New SqlParameter("@ERSPancreaticPseudocyst", ERSPancreaticPseudocyst))
            cmd.Parameters.Add(New SqlParameter("@ERSPancreatobiliaryPain", ERSPancreatobiliaryPain))
            cmd.Parameters.Add(New SqlParameter("@ERSPapillaryDysfunction", ERSPapillaryDysfunction))
            cmd.Parameters.Add(New SqlParameter("@ERSPriSclerosingChol", ERSPriSclerosingChol))
            cmd.Parameters.Add(New SqlParameter("@ERSImgUltrasound", ERSImgUltrasound))
            cmd.Parameters.Add(New SqlParameter("@ERSImgCT", ERSImgCT))
            cmd.Parameters.Add(New SqlParameter("@ERSImgMRI", ERSImgMRI))
            cmd.Parameters.Add(New SqlParameter("@ERSImgMRCP", ERSImgMRCP))
            cmd.Parameters.Add(New SqlParameter("@ERSImgIDA", ERSImgIDA))
            cmd.Parameters.Add(New SqlParameter("@ERSImgEUS", ERSImgEUS))
            cmd.Parameters.Add(New SqlParameter("@ERSNormal", ERSNormal))
            cmd.Parameters.Add(New SqlParameter("@ERSChronicPancreatitis", ERSChronicPancreatitis))
            cmd.Parameters.Add(New SqlParameter("@ERSAcutePancreatitis", ERSAcutePancreatitis))
            cmd.Parameters.Add(New SqlParameter("@ERSGallBladder", ERSGallBladder))
            cmd.Parameters.Add(New SqlParameter("@ERSFluidCollection", ERSFluidCollection))
            cmd.Parameters.Add(New SqlParameter("@ERSPancreaticMass", ERSPancreaticMass))
            cmd.Parameters.Add(New SqlParameter("@ERSDilatedPancreatic", ERSDilatedPancreatic))
            cmd.Parameters.Add(New SqlParameter("@ERSStonedBiliary", ERSStonedBiliary))
            cmd.Parameters.Add(New SqlParameter("@ERSHepaticMass", ERSHepaticMass))
            cmd.Parameters.Add(New SqlParameter("@ERSObstructed", ERSObstructed))
            cmd.Parameters.Add(New SqlParameter("@CysticLesion", CysticLesion))
            'cmd.Parameters.Add(New SqlParameter("@CysticLesion", EUSCysticLesion))
            cmd.Parameters.Add(New SqlParameter("@ERSDilatedDucts", ERSDilatedDucts))
            cmd.Parameters.Add(New SqlParameter("@AmpullaryMass", AmpullaryMass))
            cmd.Parameters.Add(New SqlParameter("@GallBladderMass", GallBladderMass))
            cmd.Parameters.Add(New SqlParameter("@GallBladderPolyp", GallBladderPolyp))
            cmd.Parameters.Add(New SqlParameter("@BiliaryLeak", BiliaryLeak))
            cmd.Parameters.Add(New SqlParameter("@ERSDilatedDuctsType1", ERSDilatedDuctsType1))
            cmd.Parameters.Add(New SqlParameter("@ERSDilatedDuctsType2", ERSDilatedDuctsType2))
            cmd.Parameters.Add(New SqlParameter("@ERSImgOthersTextBox", ERSImgOthersTextBox))
            cmd.Parameters.Add(New SqlParameter("@EPlanCanunulate", EPlanCanunulate))
            cmd.Parameters.Add(New SqlParameter("@EplanManometry", EplanManometry))
            cmd.Parameters.Add(New SqlParameter("@EplanStentremoval", EplanStentremoval))
            cmd.Parameters.Add(New SqlParameter("@EplanCombinedProcedure", EplanCombinedProcedure))
            cmd.Parameters.Add(New SqlParameter("@EplanNasoPancreatic", EplanNasoPancreatic))
            cmd.Parameters.Add(New SqlParameter("@EplanStentReplacement", EplanStentReplacement))
            cmd.Parameters.Add(New SqlParameter("@EPlanEndoscopicCyst", EPlanEndoscopicCyst))
            cmd.Parameters.Add(New SqlParameter("@EplanPapillotomy", EplanPapillotomy))
            cmd.Parameters.Add(New SqlParameter("@EplanStoneRemoval", EplanStoneRemoval))
            cmd.Parameters.Add(New SqlParameter("@EplanStentInsertion", EplanStentInsertion))
            cmd.Parameters.Add(New SqlParameter("@EplanStrictureDilatation", EplanStrictureDilatation))
            cmd.Parameters.Add(New SqlParameter("@EplanOthersTextBox", EplanOthersTextBox))
            cmd.Parameters.Add(New SqlParameter("@ExcludeMicrolithiasis", Microlithiasis))
            cmd.Parameters.Add(New SqlParameter("@ERSFollowPrevious", ERSFollowPrevious))
            cmd.Parameters.Add(New SqlParameter("@ERSFollowCarriedOut", ERSFollowCarriedOut))
            cmd.Parameters.Add(New SqlParameter("@ERSFollowBileDuct", ERSFollowBileDuct))
            cmd.Parameters.Add(New SqlParameter("@ERSFollowMalignancy", ERSFollowMalignancy))
            cmd.Parameters.Add(New SqlParameter("@ERSFollowBiliaryStricture", ERSFollowBiliaryStricture))
            cmd.Parameters.Add(New SqlParameter("@ERSFollowStentReplacement", ERSFollowStentReplacement))
            cmd.Parameters.Add(New SqlParameter("@PolypTumourAssess", PolypTumourAssess))
            cmd.Parameters.Add(New SqlParameter("@EMR", EMR))
            cmd.Parameters.Add(New SqlParameter("@ColonPlannedPolypectomy", ColonPlannedPolypectomy))
            cmd.Parameters.Add(New SqlParameter("@EPlanNGTubeInsertion", NGTubeInsertion))
            cmd.Parameters.Add(New SqlParameter("@EPlanNGTubeRemoval", NGTubeRemoval))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            cmd.Parameters.Add(New SqlParameter("@AntiCoagDrugs", AntiCoagDrugs))
            cmd.Parameters.Add(New SqlParameter("@TumourStaging", TumourStaging))
            cmd.Parameters.Add(New SqlParameter("@MediastinalAbnormality", MediastinalAbno))
            cmd.Parameters.Add(New SqlParameter("@LymphNodeSampling", LymphNode))
            cmd.Parameters.Add(New SqlParameter("@SubmucosalLesion", SubmucosalLesion))
            cmd.Parameters.Add(New SqlParameter("@FNAMass", FNAMass))
            cmd.Parameters.Add(New SqlParameter("@FNA", FNA))
            cmd.Parameters.Add(New SqlParameter("@FNB", FNB))
            cmd.Parameters.Add(New SqlParameter("@IBDSpray", IBDSpray))
            cmd.Parameters.Add(New SqlParameter("@setComplete", IIf(setComplete, 1, 0)))
            cmd.Parameters.Add(New SqlParameter("@EUSCysticLesion", EUSCysticLesion))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

    Public Sub savePathwayPlanAnswers(procedureId As Integer, questionId As Integer, optionAnswer As Integer?, freeTextAnswer As String, comboBoxItemId As Integer)
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("procedure_pathway_plan_answers_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@QuestionId", questionId))

            If optionAnswer.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@OptionAnswer", optionAnswer))
            End If

            If Not String.IsNullOrWhiteSpace(freeTextAnswer) Then
                cmd.Parameters.Add(New SqlParameter("@FreeTextAnswer", freeTextAnswer))
            End If

            cmd.Parameters.Add(New SqlParameter("@ComboBoxItemId", comboBoxItemId))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Function GetPathwayPlanAnswers(procedureId As Integer) As DataTable
        Dim dsData As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("procedure_pathway_plan_answers_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

#End Region

#Region "Upper GI Bleeds"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUpperGIBleeds(ByVal procedureId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ogd_gibleeds_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveUpperGIBleeds(ByVal procedureId As Integer,
                                      ByVal ageRange As Integer,
                                      ByVal gender As String,
                                      ByVal melaena As Integer,
                                      ByVal syncope As Integer,
                                      ByVal lowestSystolicBP As Integer,
                                      ByVal highestPulseGreaterThan100 As Integer,
                                      ByVal urea As Integer,
                                      ByVal haemoglobin As Integer,
                                      ByVal heartFailure As Integer,
                                      ByVal liverFailure As Integer,
                                      ByVal renalFailure As Integer,
                                      ByVal metastaticCancer As Integer,
                                      ByVal diagnosis As Integer,
                                      ByVal bleeding As Integer,
                                      ByVal overallRiskAssessment As String,
                                      ByVal BlatchfordScore As Integer,
                                      ByVal RockallScore As Integer) As Integer
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)

            Dim cmd As SqlCommand = New SqlCommand("ogd_gibleeds_save", connection)
            cmd.CommandType = System.Data.CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@AgeRange", ageRange))
            cmd.Parameters.Add(New SqlParameter("@Gender", gender))
            cmd.Parameters.Add(New SqlParameter("@Melaena", melaena))
            cmd.Parameters.Add(New SqlParameter("@Syncope", syncope))
            cmd.Parameters.Add(New SqlParameter("@LowestSystolicBP", lowestSystolicBP))
            cmd.Parameters.Add(New SqlParameter("@HighestPulseGreaterThan100", highestPulseGreaterThan100))
            cmd.Parameters.Add(New SqlParameter("@Urea", urea))
            cmd.Parameters.Add(New SqlParameter("@Haemoglobin", haemoglobin))
            cmd.Parameters.Add(New SqlParameter("@HeartFailure", heartFailure))
            cmd.Parameters.Add(New SqlParameter("@LiverFailure", liverFailure))
            cmd.Parameters.Add(New SqlParameter("@RenalFailure", renalFailure))
            cmd.Parameters.Add(New SqlParameter("@MetastaticCancer", metastaticCancer))
            cmd.Parameters.Add(New SqlParameter("@Diagnosis", diagnosis))
            cmd.Parameters.Add(New SqlParameter("@Bleeding", bleeding))
            cmd.Parameters.Add(New SqlParameter("@OverallRiskAssessment", overallRiskAssessment))
            cmd.Parameters.Add(New SqlParameter("@BlatchfordScore", BlatchfordScore))
            cmd.Parameters.Add(New SqlParameter("@RockallScore", RockallScore))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
    Public Function ClearUpperGIBleeds(ByVal procedureId As Integer) As Integer
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)

            Dim cmd As SqlCommand = New SqlCommand("DELETE FROM ERS_UpperGIBleeds WHERE ProcedureId = @ProcedureId ;", connection)
            cmd.CommandType = System.Data.CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
    Public Function HasGIBleedsRecord(ByVal procedureId As Integer) As Boolean

        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ogd_gibleeds_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables(0).Rows.Count > 0 Then
            Return True
        End If

        Return False

    End Function

#End Region

#Region "Upper GI Extent of Intubation"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetTrainerTraineeEndo(ByVal procedureId As Integer, Optional siteId As Integer = 0) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("trainer_trainee_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@SiteId", siteId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUpperGIExtentOfIntubation(ByVal procedureId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ogd_extentofintubation_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveUpperGIExtentOfIntubation(ByVal ProcedureId As Integer,
                                                  ByVal CompletionStatus As Integer,
                                                  ByVal Extent As Integer,
                                                  ByVal FailureReason As Integer,
                                                  ByVal FailureReasonOther As String,
                                                  ByVal Jmanoeuvre As Integer,
                                                  ByVal TrainerCompletionStatus As Integer,
                                                  ByVal TrainerExtent As Integer,
                                                  ByVal TrainerFailureReason As Integer,
                                                  ByVal TrainerFailureReasonOther As String,
                                                  ByVal TrainerJmanoeuvre As Integer,
                                                  Optional ByVal setComplete As Boolean = True) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("OGD_ExtentOfIntubation_Save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@CompletionStatus", CompletionStatus))
            cmd.Parameters.Add(New SqlParameter("@Extent", Extent))
            cmd.Parameters.Add(New SqlParameter("@FailureReason", FailureReason))
            cmd.Parameters.Add(New SqlParameter("@FailureReasonOther", FailureReasonOther))
            cmd.Parameters.Add(New SqlParameter("@Jmanoeuvre", Jmanoeuvre))
            cmd.Parameters.Add(New SqlParameter("@TrainerCompletionStatus", TrainerCompletionStatus))
            cmd.Parameters.Add(New SqlParameter("@TrainerExtent", TrainerExtent))
            cmd.Parameters.Add(New SqlParameter("@TrainerFailureReason", TrainerFailureReason))
            cmd.Parameters.Add(New SqlParameter("@TrainerFailureReasonOther", TrainerFailureReasonOther))
            cmd.Parameters.Add(New SqlParameter("@TrainerJmanoeuvre", TrainerJmanoeuvre))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            cmd.Parameters.Add(New SqlParameter("@setComplete", IIf(setComplete, 1, 0)))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

#End Region

#Region "Upper GI PreMedication"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUpperGIPremedication(ByVal procedureId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ogd_premedication_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUpperGIPremedicationDefault(ByVal UserId As Integer, Optional ByVal ProcedureTypeId As Integer? = Nothing) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ogd_premedication_select_default", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
            If ProcedureTypeId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeId", ProcedureTypeId.Value))
            End If
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    Public Function SavePremedicationDefaults(ByVal UserId As Integer, Premedication As String) As Integer
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("set_default_values", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@fromPage", "Premedication"))
            cmd.Parameters.Add(New SqlParameter("@UserId", UserId))
            cmd.Parameters.Add(New SqlParameter("@Premedication", Premedication))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveUpperGIPremedication(ByVal ProcedureId As Integer, ByVal sSQLText As String) As Integer
        Dim sql As New StringBuilder
        Dim ut As Integer
        'Set PP_Premed to NULL in case all premedication are deleted (no insert, which is not going to execute the trigger '[TR_UpperGIPremedication_Insert]')
        sql.Append("UPDATE ERS_ProceduresReporting SET PP_Premed = NULL WHERE ProcedureId = @ProcedureId; Exec ProceduresReporting_Updated @ProcedureId ;")
        sql.Append("DELETE FROM ERS_UpperGIPremedication WHERE ProcedureId = @ProcedureId ")
        'sql.Append("DELETE FROM ERS_RecordCount WHERE ProcedureId = @ProcedureId AND Identifier = 'Premed' ")
        sql.Append(sSQLText)


        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            connection.Open()
            Dim transaction As SqlTransaction = connection.BeginTransaction()
            Dim cmd As New SqlCommand(sql.ToString(), connection)
            cmd.CommandType = CommandType.Text
            cmd.Transaction = transaction
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            Try
                ut = cmd.ExecuteNonQuery()
                transaction.Commit()
            Catch e As Exception
                Try
                    transaction.Rollback()
                Catch ex As SqlException
                    If Not transaction.Connection Is Nothing Then
                        Throw New Exception("An exception of type was encountered while saving", ex.InnerException)
                    End If
                End Try
                Throw New Exception("An exception of type was encountered while saving", e.InnerException)
            End Try

        End Using
        Return ut
    End Function
    Public Function SaveBowelPrepScale(ByVal ProcedureId As Integer, BowelPrepSettings As Boolean, OnNoBowelPrep As Boolean, OnFormulation As String, OnFormulationNewItemText As String,
                                       onright As Integer, OnTransverse As Integer, OnLeft As Integer, OnTotalScore As Integer, OffNoBowelPrep As Boolean,
                                       OffFormulation As String, BowelPrepQuality As Integer) As Integer

        If OnFormulation = "-99" Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Bowel_Preparation", OnFormulationNewItemText)
            If newId > 0 Then
                OnFormulation = newId.ToString()
            End If
        End If

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("Common_Bowel_Preparation_Save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@BowelPrepSettings", BowelPrepSettings))
            cmd.Parameters.Add(New SqlParameter("@OnNoBowelPrep", OnNoBowelPrep))
            cmd.Parameters.Add(New SqlParameter("@OnFormulation", OnFormulation))
            'cmd.Parameters.Add(New SqlParameter("@CO2Insufflation", CO2Insufflation))
            cmd.Parameters.Add(New SqlParameter("@onright", onright))
            cmd.Parameters.Add(New SqlParameter("@OnTransverse", OnTransverse))
            cmd.Parameters.Add(New SqlParameter("@OnLeft", OnLeft))
            cmd.Parameters.Add(New SqlParameter("@OnTotalScore", OnTotalScore))
            cmd.Parameters.Add(New SqlParameter("@OffNoBowelPrep", OffNoBowelPrep))
            cmd.Parameters.Add(New SqlParameter("@OffFormulation", OffFormulation))
            cmd.Parameters.Add(New SqlParameter("@BowelPrepQuality", BowelPrepQuality))
            connection.Open()
            Return cmd.ExecuteNonQuery()
        End Using
    End Function

    Function GetBostonBowelPrepScale(ProcedureID As Integer) As Integer
        Dim result As Integer = -1
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim querystr As String = "SELECT [BowelPrepSettings] from [ERS_BowelPreparation] where ProcedureID = @ProcedureID"
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.CommandType = CommandType.Text
            mycmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            connection.Open()
            Dim v As Object = mycmd.ExecuteScalar()
            If IsDBNull(v) Or IsNothing(v) Then
                result = -1
            Else
                result = IIf(CBool(v) = True, 1, 0)
            End If
        End Using
        Return result
    End Function

    Public Function BostonBowelPrepScale() As Boolean
        Dim value As Boolean
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim querystr As String = "SELECT TOP(1) BostonBowelPrepScale FROM ERS_SystemConfig"
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.CommandType = CommandType.Text
            'mycmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", OperatingHospitalID))
            'mycmd.Parameters.Add(New SqlParameter("@HospitalID", HospitalID))
            connection.Open()
            value = mycmd.ExecuteScalar()
        End Using
        Return CBool(value)
    End Function
    Public Function GetBostonBowelPrepText(ProcedureID As Integer) As String
        If GetBostonBowelPrepScale(ProcedureID) = 1 Then
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim querystr As String = "SELECT [PP_Bowel_Prep] from [ERS_ProceduresReporting] where ProcedureID = @ProcedureID"
                Dim mycmd As New SqlCommand(querystr, connection)
                mycmd.CommandType = CommandType.Text
                mycmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
                connection.Open()
                Dim v As Object = mycmd.ExecuteScalar()
                If IsDBNull(v) Or IsNothing(v) Then
                    Return Nothing
                Else
                    Return CStr(v)
                End If
            End Using
        End If
        Return Nothing
    End Function
    Public Function BostonBowelPrepScale(ProcedureID As Integer) As Boolean
        Dim r As Integer = GetBostonBowelPrepScale(ProcedureID)
        If r = -1 Then
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim querystr As String = "SELECT TOP(1) BostonBowelPrepScale FROM ERS_SystemConfig"
                Dim mycmd As New SqlCommand(querystr, connection)
                mycmd.CommandType = CommandType.Text
                'mycmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", OperatingHospitalID))
                'mycmd.Parameters.Add(New SqlParameter("@HospitalID", HospitalID))
                connection.Open()
                Return CBool(mycmd.ExecuteScalar())
            End Using
        Else
            Return CBool(r)
        End If
        Return Nothing
    End Function
    Public Function GetBowelPreparationData(ByVal ProcedureID As Integer, Status As Boolean) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim sqlText As String
            If Status Then
                sqlText = "SELECT TOP(1) [OnNoBowelPrep],[OnFormulation], [OnRight],[OnTransverse],[OnLeft],[OnTotalScore] FROM [ERS_BowelPreparation] WHERE ProcedureID=@ProcedureID"
            Else
                sqlText = "SELECT TOP(1) [OffNoBowelPrep],[OffFormulation],IsNull([CO2Insufflation], 0) AS CO2Insufflation,[BowelPrepQuality] FROM [ERS_BowelPreparation] WHERE ProcedureID=@ProcedureID"
            End If
            Dim cmd As New SqlCommand(sqlText, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

#End Region

#Region "Upper GI Diagnoses"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetDiagnosesData(ByVal procedureId As Integer) As DataTable
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_Diagnoses WHERE ProcedureID = @ProcedureId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsResult)
        End Using
        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    '<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)> _
    'Public Function GetERCPDiagnosesData(ByVal procedureId As Integer) As DataTable
    '    Dim dsResult As New DataSet
    '    Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '        Dim cmd As New SqlCommand("SELECT * FROM ERS_ERCPDiagnoses WHERE ProcedureID = @ProcedureId", connection)
    '        cmd.CommandType = CommandType.Text
    '        cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
    '        Dim adapter = New SqlDataAdapter(cmd)
    '        connection.Open()
    '        adapter.Fill(dsResult)
    '    End Using
    '    If dsResult.Tables.Count > 0 Then
    '        Return dsResult.Tables(0)
    '    End If
    '    Return Nothing
    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function DiagnosesSelect(ProcedureTypeID As Integer, Section As String) As DataTable
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand()
            Dim sql As String
            If String.IsNullOrEmpty(Section) Then
                sql = "SELECT * from ERS_DiagnosesMatrix WHERE ProcedureTypeID = @ProcedureTypeID ORDER BY OrderByNumber"
            Else
                sql = "SELECT * from ERS_DiagnosesMatrix WHERE ProcedureTypeID = @ProcedureTypeID  AND Section = @Section ORDER BY OrderByNumber"
                cmd.Parameters.Add(New SqlParameter("@Section", Section))
            End If
            cmd.CommandText = sql
            cmd.CommandType = CommandType.Text
            cmd.Connection = connection
            cmd.Parameters.Add(New SqlParameter("@ProcedureTypeID", ProcedureTypeID))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsResult)
            If dsResult.Tables.Count > 0 Then
                Return dsResult.Tables(0)
            End If
            Return Nothing
        End Using
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function DiagnoseSelect(DiagnosesMatrixID As Integer) As DataTable
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * from ERS_DiagnosesMatrix WHERE DiagnosesMatrixID = @DiagnosesMatrixID", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@DiagnosesMatrixID", DiagnosesMatrixID))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsResult)
        End Using
        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetAbnoDiagnoses(ProcedureID As Integer) As String
        Dim PP_DiagnosesText As String
        Using db As New ERS.Data.GastroDbEntities
            PP_DiagnosesText = db.ERS_ProceduresReporting.Find(ProcedureID).PP_Diagnoses & ""
        End Using
        Return PP_DiagnosesText


        'Dim dsResult As New DataSet
        'Using connection As New SqlConnection(DataAccess.ConnectionStr)
        '    Dim cmd As New SqlCommand("SELECT ISNULL([PP_Diagnoses],'') AS PP_Diagnoses FROM [ERS_ProceduresReporting] WHERE ProcedureId = @ProcedureID", connection)
        '    cmd.CommandType = CommandType.Text
        '    cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
        '    Dim adapter = New SqlDataAdapter(cmd)
        '    connection.Open()
        '    adapter.Fill(dsResult)
        'End Using
        'If dsResult.Tables.Count > 0 Then
        '    Return dsResult.Tables(0)
        'End If
        'Return Nothing
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function DiagnoseUpdate(DiagnosesMatrixID As Integer, DisplayName As String, EndoCode As String, Disabled As Boolean, OrderByNumber As Integer, ProcedureTypeID As Integer, Section As String) As Integer
        Dim rowsAffected As Integer
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("UPDATE [ERS_DiagnosesMatrix] SET DisplayName=@DisplayName, EndoCode=@EndoCode, [Disabled]=@Disabled,OrderByNumber=@OrderByNumber,ProcedureTypeID=@ProcedureTypeID,Section= @Section, WhoUpdatedId=@LoggedInUserId, WhenUpdated=GETDATE() WHERE  DiagnosesMatrixID =@DiagnosesMatrixID", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@DiagnosesMatrixID", DiagnosesMatrixID))
            cmd.Parameters.Add(New SqlParameter("@DisplayName", DisplayName))
            If Not String.IsNullOrEmpty(EndoCode) Then
                cmd.Parameters.Add(New SqlParameter("@EndoCode", EndoCode))
            Else
                cmd.Parameters.Add(New SqlParameter("@EndoCode", SqlTypes.SqlString.Null))
            End If
            'cmd.Parameters.Add(New SqlParameter("@EndoCode", EndoCode))
            cmd.Parameters.Add(New SqlParameter("@Disabled", Disabled))
            cmd.Parameters.Add(New SqlParameter("@OrderByNumber", OrderByNumber))
            cmd.Parameters.Add(New SqlParameter("@ProcedureTypeID", ProcedureTypeID))
            If Not String.IsNullOrEmpty(Section) Then
                cmd.Parameters.Add(New SqlParameter("@Section", Section))
            Else
                cmd.Parameters.Add(New SqlParameter("@Section", SqlTypes.SqlString.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using
        Return rowsAffected
    End Function
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Insert, False)>
    Public Function DiagnoseInsert(DiagnosesMatrixID As Integer, DisplayName As String, EndoCode As String, Disabled As Boolean, OrderByNumber As Integer, ProcedureTypeID As Integer, Section As String) As Integer
        Try

            Dim sql As String = "INSERT INTO [ERS_DiagnosesMatrix] (DisplayName, EndoCode, [Disabled], OrderByNumber, ProcedureTypeID, Section, WhoCreatedId, WhenCreated) " &
                            "VALUES (@DisplayName, @EndoCode, @Disabled, @OrderByNumber, @ProcedureTypeID, @Section, @LoggedInUserId, GETDATE()); " &
                            "SELECT @@identity "
            Using connection As New SqlConnection(DataAccess.ConnectionStr)
                Dim cmd As New SqlCommand(sql, connection)
                cmd.CommandType = CommandType.Text
                cmd.Parameters.Add(New SqlParameter("@DisplayName", DisplayName))
                If Not String.IsNullOrEmpty(EndoCode) Then
                    cmd.Parameters.Add(New SqlParameter("@EndoCode", EndoCode))
                Else
                    cmd.Parameters.Add(New SqlParameter("@EndoCode", SqlTypes.SqlString.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@Disabled", Disabled))
                cmd.Parameters.Add(New SqlParameter("@OrderByNumber", OrderByNumber))
                cmd.Parameters.Add(New SqlParameter("@ProcedureTypeID", ProcedureTypeID))
                If Not String.IsNullOrEmpty(Section) Then
                    cmd.Parameters.Add(New SqlParameter("@Section", Section))
                Else
                    cmd.Parameters.Add(New SqlParameter("@Section", SqlTypes.SqlString.Null))
                End If
                cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
                connection.Open()
                Return CInt(cmd.ExecuteScalar())
            End Using
        Catch ex As Exception

        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveUpperGIDiagnoses(ByVal ProcedureId As Integer,
                                         ByVal OverallNormal As Boolean,
                                         ByVal OesophagusNormal As Boolean,
                                         ByVal OesophagusNotEntered As Boolean,
                                         ByVal OesoList As String,
                                         ByVal StomachNormal As Boolean,
                                         ByVal StomachNotEntered As Boolean,
                                         ByVal stomachList As String,
                                         ByVal DuodenumNormal As Boolean,
                                         ByVal DuodenumNotEntered As Boolean,
                                         ByVal Duodenum2ndPartNotEntered As Boolean,
                                         ByVal DuoList As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)

            Dim cmd As SqlCommand = New SqlCommand("otherdata_ogd_diagnoses_save", connection)
            cmd.CommandType = System.Data.CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@OverallNormal", OverallNormal))
            cmd.Parameters.Add(New SqlParameter("@OesophagusNormal", OesophagusNormal))
            cmd.Parameters.Add(New SqlParameter("@OesophagusNotEntered", OesophagusNotEntered))
            cmd.Parameters.Add(New SqlParameter("@OesoList", OesoList))
            cmd.Parameters.Add(New SqlParameter("@StomachNotEntered", StomachNotEntered))
            cmd.Parameters.Add(New SqlParameter("@StomachNormal", StomachNormal))
            cmd.Parameters.Add(New SqlParameter("@stomachList", stomachList))
            cmd.Parameters.Add(New SqlParameter("@DuodenumNotEntered", DuodenumNotEntered))
            cmd.Parameters.Add(New SqlParameter("@Duodenum2ndPartNotEntered", Duodenum2ndPartNotEntered))
            cmd.Parameters.Add(New SqlParameter("@DuodenumNormal", DuodenumNormal))
            cmd.Parameters.Add(New SqlParameter("@DuoList", DuoList))
            'cmd.Parameters.Add(New SqlParameter("@OesophagusOtherDiagnosis", OesophagusOtherDiagnosis))
            'cmd.Parameters.Add(New SqlParameter("@StomachOtherDiagnosis", StomachOtherDiagnosis))
            'cmd.Parameters.Add(New SqlParameter("@DuodenumOtherDiagnosis", DuodenumOtherDiagnosis))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveERCPDiagnoses(ProcedureID As Integer,
                                        ByVal DuodenumNotEntered As Boolean,
                                        ByVal DuodenumNormal As Boolean,
                                        ByVal Duodenum2ndPartNotEntered As Boolean,
                                        ByVal WholePancreatic As Boolean,
                                        ByVal PapillaeNormal As Boolean,
                                        ByVal Stenosed As Boolean,
                                        ByVal ERCP_TumourBenign As Boolean,
                                        ByVal ERCP_TumourMalignant As Boolean,
                                        ByVal PancreasNormal As Boolean,
                                        ByVal PancreasNotEntered As Boolean,
                                        ByVal Annulare As Boolean,
                                        ByVal DuctInjury As Boolean,
                                        ByVal PanStentOcclusion As Boolean,
                                        ByVal IPMT As Boolean,
                                        ByVal PancreaticAndBiliaryOther As String,
                                        ByVal BiliaryNormal As Boolean,
                                        ByVal AnastomicStricture As Boolean,
                                        ByVal Haemobilia As Boolean,
                                        ByVal Cholelithiasis As Boolean,
                                        ByVal FistulaLeak As Boolean,
                                        ByVal Mirizzi As Boolean,
                                        ByVal CalculousObstruction As Boolean,
                                        ByVal Occlusion As Boolean,
                                        ByVal GallBladderTumour As Boolean,
                                        ByVal StentOcclusion As Boolean,
                                        ByVal NormalDucts As Boolean,
                                        ByVal Suppurative As Boolean,
                                        ByVal BiliaryLeakSite As Boolean,
                                        ByVal BiliaryLeakSiteVal As String,
                                        ByVal IntrahepaticTumourProbable As Boolean,
                                        ByVal IntrahepaticTumourPossible As Boolean,
                                        ByVal ExtrahepaticNormal As Boolean,
                                        ByVal ExtrahepaticLeakSite As Boolean,
                                        ByVal ExtrahepaticLeakSiteVal As String,
                                        ByVal BeningPancreatitis As Boolean,
                                        ByVal BeningPseudocyst As Boolean,
                                        ByVal BeningPrevious As Boolean,
                                        ByVal BeningSclerosing As Boolean,
                                        ByVal BeningProbable As Boolean,
                                        ByVal MalignantGallbladder As Boolean,
                                        ByVal MalignantMetastatic As Boolean,
                                        ByVal MalignantCholangiocarcinoma As Boolean,
                                        ByVal MalignantPancreatic As Boolean,
                                        ByVal MalignantProbable As Boolean,
                                        ByVal BiliaryOther As String,
                                        ByVal WholeOther As String) As Integer

        ''ByVal CysticDuct As Boolean,
        ''ByVal GallBladder As Boolean,
        ''ByVal CommonDuct As Boolean,

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)

            Dim cmd As SqlCommand = New SqlCommand("otherdata_ercp_diagnoses_save", connection)
            cmd.CommandType = System.Data.CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            cmd.Parameters.Add(New SqlParameter("@DuodenumNotEntered", DuodenumNotEntered))
            cmd.Parameters.Add(New SqlParameter("@DuodenumNormal", DuodenumNormal))
            cmd.Parameters.Add(New SqlParameter("@Duodenum2ndPartNotEntered", Duodenum2ndPartNotEntered))
            cmd.Parameters.Add(New SqlParameter("@WholePancreatic", WholePancreatic))
            cmd.Parameters.Add(New SqlParameter("@PapillaeNormal", PapillaeNormal))
            cmd.Parameters.Add(New SqlParameter("@Stenosed", Stenosed))
            cmd.Parameters.Add(New SqlParameter("@ERCP_TumourBenign", ERCP_TumourBenign))
            cmd.Parameters.Add(New SqlParameter("@ERCP_TumourMalignant", ERCP_TumourMalignant))
            cmd.Parameters.Add(New SqlParameter("@PancreasNormal", PancreasNormal))
            cmd.Parameters.Add(New SqlParameter("@PancreasNotEntered", PancreasNotEntered))
            cmd.Parameters.Add(New SqlParameter("@Annulare", Annulare))
            cmd.Parameters.Add(New SqlParameter("@DuctInjury", DuctInjury))
            cmd.Parameters.Add(New SqlParameter("@PanStentOcclusion", PanStentOcclusion))
            cmd.Parameters.Add(New SqlParameter("@IPMT", IPMT))
            cmd.Parameters.Add(New SqlParameter("@PancreaticAndBiliaryOther", PancreaticAndBiliaryOther))
            cmd.Parameters.Add(New SqlParameter("@BiliaryNormal", BiliaryNormal))
            cmd.Parameters.Add(New SqlParameter("@AnastomicStricture", AnastomicStricture))
            'cmd.Parameters.Add(New SqlParameter("@CysticDuct", CysticDuct))
            cmd.Parameters.Add(New SqlParameter("@Haemobilia", Haemobilia))
            cmd.Parameters.Add(New SqlParameter("@Cholelithiasis", Cholelithiasis))
            cmd.Parameters.Add(New SqlParameter("@FistulaLeak", FistulaLeak))
            cmd.Parameters.Add(New SqlParameter("@Mirizzi", Mirizzi))
            cmd.Parameters.Add(New SqlParameter("@CalculousObstruction", CalculousObstruction))
            'cmd.Parameters.Add(New SqlParameter("@GallBladder", GallBladder))
            cmd.Parameters.Add(New SqlParameter("@Occlusion", Occlusion))
            'cmd.Parameters.Add(New SqlParameter("@CommonDuct", CommonDuct))
            cmd.Parameters.Add(New SqlParameter("@GallBladderTumour", GallBladderTumour))
            cmd.Parameters.Add(New SqlParameter("@StentOcclusion", StentOcclusion))
            cmd.Parameters.Add(New SqlParameter("@NormalDucts", NormalDucts))
            cmd.Parameters.Add(New SqlParameter("@Suppurative", Suppurative))
            cmd.Parameters.Add(New SqlParameter("@BiliaryLeakSite", BiliaryLeakSite))
            cmd.Parameters.Add(New SqlParameter("@BiliaryLeakSiteVal", BiliaryLeakSiteVal))
            cmd.Parameters.Add(New SqlParameter("@IntrahepaticTumourProbable", IntrahepaticTumourProbable))
            cmd.Parameters.Add(New SqlParameter("@IntrahepaticTumourPossible", IntrahepaticTumourPossible))
            cmd.Parameters.Add(New SqlParameter("@ExtrahepaticNormal", ExtrahepaticNormal))
            cmd.Parameters.Add(New SqlParameter("@ExtrahepaticLeakSite", ExtrahepaticLeakSite))
            cmd.Parameters.Add(New SqlParameter("@ExtrahepaticLeakSiteVal", ExtrahepaticLeakSiteVal))
            cmd.Parameters.Add(New SqlParameter("@BeningPancreatitis", BeningPancreatitis))
            cmd.Parameters.Add(New SqlParameter("@BeningPseudocyst", BeningPseudocyst))
            cmd.Parameters.Add(New SqlParameter("@BeningPrevious", BeningPrevious))
            cmd.Parameters.Add(New SqlParameter("@BeningSclerosing", BeningSclerosing))
            cmd.Parameters.Add(New SqlParameter("@BeningProbable", BeningProbable))
            cmd.Parameters.Add(New SqlParameter("@MalignantGallbladder", MalignantGallbladder))
            cmd.Parameters.Add(New SqlParameter("@MalignantMetastatic", MalignantMetastatic))
            cmd.Parameters.Add(New SqlParameter("@MalignantCholangiocarcinoma", MalignantCholangiocarcinoma))
            cmd.Parameters.Add(New SqlParameter("@MalignantPancreatic", MalignantPancreatic))
            cmd.Parameters.Add(New SqlParameter("@MalignantProbable", MalignantProbable))
            cmd.Parameters.Add(New SqlParameter("@BiliaryOther", BiliaryOther))
            cmd.Parameters.Add(New SqlParameter("@WholeOther", WholeOther))


            'cmd.Parameters.Add(New SqlParameter("@OesoList", OesoList))
            'cmd.Parameters.Add(New SqlParameter("@StomachNotEntered", StomachNotEntered))
            'cmd.Parameters.Add(New SqlParameter("@StomachNormal", StomachNormal))
            'cmd.Parameters.Add(New SqlParameter("@stomachList", stomachList))
            'cmd.Parameters.Add(New SqlParameter("@DuodenumNotEntered", DuodenumNotEntered))
            'cmd.Parameters.Add(New SqlParameter("@Duodenum2ndPartNotEntered", Duodenum2ndPartNotEntered))
            'cmd.Parameters.Add(New SqlParameter("@DuodenumNormal", DuodenumNormal))
            'cmd.Parameters.Add(New SqlParameter("@DuoList", DuoList))
            'cmd.Parameters.Add(New SqlParameter("@OesophagusOtherDiagnosis", OesophagusOtherDiagnosis))
            'cmd.Parameters.Add(New SqlParameter("@StomachOtherDiagnosis", StomachOtherDiagnosis))
            'cmd.Parameters.Add(New SqlParameter("@DuodenumOtherDiagnosis", DuodenumOtherDiagnosis))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveERSGIDiagnoses(
                                      ProcedureID As Integer,
                                        DuodenumNormal As Boolean,
                                        Angiodysplasia As Boolean,
                                        Diverticulum As Boolean,
                                        Duodenitis As Boolean,
                                        Polyp As Boolean,
                                        Tumour As Boolean,
                                        Ulcer As Boolean,
                                        WholePancreatic As Boolean,
                                        PapillaeNormal As Boolean,
                                        ImpactedStone As Boolean,
                                        Inflamed As Boolean,
                                        Periampullary As Boolean,
                                        Stenosed As Boolean,
                                        PapillaeTumour As Boolean,
                                        PapillaeTumourType As Integer,
                                        PancreasNormal As Boolean,
                                        PancreaticStone As Boolean,
                                        Fistula As Boolean,
                                        Acute As Boolean,
                                        Chronic As Boolean,
                                        MinimalChange As Boolean,
                                        CommunicatingCyst As Boolean,
                                        NoncommunicatingCyst As Boolean,
                                        PseudocystCyst As Boolean,
                                        Dilatation As Boolean,
                                        NoObvious As Boolean,
                                        Stricture As Boolean,
                                        ProbablyMalignant As Boolean,
                                        Cystadenoma As Boolean,
                                        TumourOther As Boolean,
                                        TumourOtherText As String,
                                        PancreaticAndBiliaryOther As String,
                                        BiliaryNormal As Boolean,
                                        AnastomicStricture As Boolean,
                                        CysticDuct As Boolean,
                                        Haemobilia As Boolean,
                                        Cholelithiasis As Boolean,
                                        FistulaLeak As Boolean,
                                        Mirizzi As Boolean,
                                        CalculousObstruction As Boolean,
                                        GallBladder As Boolean,
                                        Occlusion As Boolean,
                                        CommonDuct As Boolean,
                                        GallBladderTumour As Boolean,
                                        StentOcclusion As Boolean,
                                        NormalDucts As Boolean,
                                        PolycysticLiver As Boolean,
                                        Cirrhosis As Boolean,
                                        Sclerosing As Boolean,
                                        HydratedCyst As Boolean,
                                        Suppurative As Boolean,
                                        LiverAbscess As Boolean,
                                        CaroliDisease As Boolean,
                                        BiliaryLeakSite As Boolean,
                                        BiliaryLeakSiteType As Integer,
                                        IntrahepaticTumour As Boolean,
                                        IntrahepaticTumourType As Integer,
                                        Cholangiocarcinoma As Boolean,
                                        Metastatic As Boolean,
                                        ExternalCompression As Boolean,
                                        HepatocellularCarcinoma As Boolean,
                                        ExtrahepaticNormal As Boolean,
                                        CholedochalCyst As Boolean,
                                        PostCholecystectomy As Boolean,
                                        DilatedDuct As Boolean,
                                        ExtrahepaticLeakSite As Boolean,
                                        ExtrahepaticLeakSiteText As Integer,
                                        ExtrahepaticTumour As Boolean,
                                        ExtrahepaticTumourType As Integer,
                                        ExtrahepaticProbable As Boolean,
                                        BeningPancreatitis As Boolean,
                                        BeningPseudocyst As Boolean,
                                        BeningPrevious As Boolean,
                                        BeningSclerosing As Boolean,
                                        BeningProbable As Boolean,
                                        MalignantGallbladder As Boolean,
                                        MalignantMetastatic As Boolean,
                                        MalignantCholangiocarcinoma As Boolean,
                                        MalignantPancreatic As Boolean,
                                        MalignantProbable As Boolean,
                                        BiliaryOther As String,
                                        WholeOther As Integer
                                      ) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim SQLstr As String = "otherdata_ercp_diagnoses_save"
            Dim cmd As SqlCommand = New SqlCommand(SQLstr, connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            cmd.Parameters.Add(New SqlParameter("@DuodenumNormal", DuodenumNormal))
            cmd.Parameters.Add(New SqlParameter("@Angiodysplasia", Angiodysplasia))
            cmd.Parameters.Add(New SqlParameter("@Diverticulum", Diverticulum))
            cmd.Parameters.Add(New SqlParameter("@Duodenitis", Duodenitis))
            cmd.Parameters.Add(New SqlParameter("@Polyp", Polyp))
            cmd.Parameters.Add(New SqlParameter("@Tumour", Tumour))
            cmd.Parameters.Add(New SqlParameter("@Ulcer", Ulcer))
            cmd.Parameters.Add(New SqlParameter("@WholePancreatic", WholePancreatic))
            cmd.Parameters.Add(New SqlParameter("@PapillaeNormal", PapillaeNormal))
            cmd.Parameters.Add(New SqlParameter("@ImpactedStone", ImpactedStone))
            cmd.Parameters.Add(New SqlParameter("@Inflamed", Inflamed))
            cmd.Parameters.Add(New SqlParameter("@Periampullary", Periampullary))
            cmd.Parameters.Add(New SqlParameter("@Stenosed", Stenosed))
            cmd.Parameters.Add(New SqlParameter("@PapillaeTumour", PapillaeTumour))
            cmd.Parameters.Add(New SqlParameter("@PapillaeTumourType", PapillaeTumourType))
            cmd.Parameters.Add(New SqlParameter("@PancreasNormal", PancreasNormal))
            cmd.Parameters.Add(New SqlParameter("@PancreaticStone", PancreaticStone))
            cmd.Parameters.Add(New SqlParameter("@Fistula", Fistula))
            cmd.Parameters.Add(New SqlParameter("@Acute", Acute))
            cmd.Parameters.Add(New SqlParameter("@Chronic", Chronic))
            cmd.Parameters.Add(New SqlParameter("@MinimalChange", MinimalChange))
            cmd.Parameters.Add(New SqlParameter("@CommunicatingCyst", CommunicatingCyst))
            cmd.Parameters.Add(New SqlParameter("@NoncommunicatingCyst", NoncommunicatingCyst))
            cmd.Parameters.Add(New SqlParameter("@PseudocystCyst", PseudocystCyst))
            cmd.Parameters.Add(New SqlParameter("@Dilatation", Dilatation))
            cmd.Parameters.Add(New SqlParameter("@NoObvious", NoObvious))
            cmd.Parameters.Add(New SqlParameter("@Stricture", Stricture))
            cmd.Parameters.Add(New SqlParameter("@ProbablyMalignant", ProbablyMalignant))
            cmd.Parameters.Add(New SqlParameter("@Cystadenoma", Cystadenoma))
            cmd.Parameters.Add(New SqlParameter("@TumourOther", TumourOther))
            cmd.Parameters.Add(New SqlParameter("@TumourOtherText", TumourOtherText))
            cmd.Parameters.Add(New SqlParameter("@PancreaticAndBiliaryOther", PancreaticAndBiliaryOther))
            cmd.Parameters.Add(New SqlParameter("@BiliaryNormal", BiliaryNormal))
            cmd.Parameters.Add(New SqlParameter("@AnastomicStricture", AnastomicStricture))
            cmd.Parameters.Add(New SqlParameter("@CysticDuct", CysticDuct))
            cmd.Parameters.Add(New SqlParameter("@Haemobilia", Haemobilia))
            cmd.Parameters.Add(New SqlParameter("@Cholelithiasis", Cholelithiasis))
            cmd.Parameters.Add(New SqlParameter("@FistulaLeak", FistulaLeak))
            cmd.Parameters.Add(New SqlParameter("@Mirizzi", Mirizzi))
            cmd.Parameters.Add(New SqlParameter("@CalculousObstruction", CalculousObstruction))
            cmd.Parameters.Add(New SqlParameter("@GallBladder", GallBladder))
            cmd.Parameters.Add(New SqlParameter("@Occlusion", Occlusion))
            cmd.Parameters.Add(New SqlParameter("@CommonDuct", CommonDuct))
            cmd.Parameters.Add(New SqlParameter("@GallBladderTumour", GallBladderTumour))
            cmd.Parameters.Add(New SqlParameter("@StentOcclusion", StentOcclusion))
            cmd.Parameters.Add(New SqlParameter("@NormalDucts", NormalDucts))
            cmd.Parameters.Add(New SqlParameter("@PolycysticLiver", PolycysticLiver))
            cmd.Parameters.Add(New SqlParameter("@Cirrhosis", Cirrhosis))
            cmd.Parameters.Add(New SqlParameter("@Sclerosing", Sclerosing))
            cmd.Parameters.Add(New SqlParameter("@HydratedCyst", HydratedCyst))
            cmd.Parameters.Add(New SqlParameter("@Suppurative", Suppurative))
            cmd.Parameters.Add(New SqlParameter("@LiverAbscess", LiverAbscess))
            cmd.Parameters.Add(New SqlParameter("@CaroliDisease", CaroliDisease))
            cmd.Parameters.Add(New SqlParameter("@BiliaryLeakSite", BiliaryLeakSite))
            cmd.Parameters.Add(New SqlParameter("@BiliaryLeakSiteType", BiliaryLeakSiteType))
            cmd.Parameters.Add(New SqlParameter("@IntrahepaticTumour", IntrahepaticTumour))
            cmd.Parameters.Add(New SqlParameter("@IntrahepaticTumourType", IntrahepaticTumourType))
            cmd.Parameters.Add(New SqlParameter("@Cholangiocarcinoma", Cholangiocarcinoma))
            cmd.Parameters.Add(New SqlParameter("@Metastatic", Metastatic))
            cmd.Parameters.Add(New SqlParameter("@ExternalCompression", ExternalCompression))
            cmd.Parameters.Add(New SqlParameter("@HepatocellularCarcinoma", HepatocellularCarcinoma))
            cmd.Parameters.Add(New SqlParameter("@ExtrahepaticNormal", ExtrahepaticNormal))
            cmd.Parameters.Add(New SqlParameter("@CholedochalCyst", CholedochalCyst))
            cmd.Parameters.Add(New SqlParameter("@PostCholecystectomy", PostCholecystectomy))
            cmd.Parameters.Add(New SqlParameter("@DilatedDuct", DilatedDuct))
            cmd.Parameters.Add(New SqlParameter("@ExtrahepaticLeakSite", ExtrahepaticLeakSite))
            cmd.Parameters.Add(New SqlParameter("@ExtrahepaticLeakSiteText", ExtrahepaticLeakSiteText))
            cmd.Parameters.Add(New SqlParameter("@ExtrahepaticTumour", ExtrahepaticTumour))
            cmd.Parameters.Add(New SqlParameter("@ExtrahepaticTumourType", ExtrahepaticTumourType))
            cmd.Parameters.Add(New SqlParameter("@ExtrahepaticProbable", ExtrahepaticProbable))
            cmd.Parameters.Add(New SqlParameter("@BeningPancreatitis", BeningPancreatitis))
            cmd.Parameters.Add(New SqlParameter("@BeningPseudocyst", BeningPseudocyst))
            cmd.Parameters.Add(New SqlParameter("@BeningPrevious", BeningPrevious))
            cmd.Parameters.Add(New SqlParameter("@BeningSclerosing", BeningSclerosing))
            cmd.Parameters.Add(New SqlParameter("@BeningProbable", BeningProbable))
            cmd.Parameters.Add(New SqlParameter("@MalignantGallbladder", MalignantGallbladder))
            cmd.Parameters.Add(New SqlParameter("@MalignantMetastatic", MalignantMetastatic))
            cmd.Parameters.Add(New SqlParameter("@MalignantCholangiocarcinoma", MalignantCholangiocarcinoma))
            cmd.Parameters.Add(New SqlParameter("@MalignantPancreatic", MalignantPancreatic))
            cmd.Parameters.Add(New SqlParameter("@MalignantProbable", MalignantProbable))
            cmd.Parameters.Add(New SqlParameter("@BiliaryOther", BiliaryOther))
            cmd.Parameters.Add(New SqlParameter("@WholeOther", WholeOther))
            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using
        Return rowsAffected
    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveColonDiagnoses(ByVal ProcedureId As Integer,
                                         ByVal ColonNormal As Boolean,
                                         ByVal ColonRestNormal As Boolean,
                                         ByVal ColitisType As String,
                                         ByVal ColonList As String) As Integer
        Dim rowsAffected As Integer

        'If ColitisExtent = "-99" Then
        '    Dim da As New DataAccess
        '    Dim newId = da.InsertListItem("Diagnoses Colon Extent", ColitisExtentNewItemText)
        '    If newId > 0 Then
        '        ColitisExtent = newId.ToString()
        '    End If
        'End If

        Using connection As New SqlConnection(DataAccess.ConnectionStr)

            Dim cmd As SqlCommand = New SqlCommand("otherdata_colon_diagnoses_save", connection)
            cmd.CommandType = System.Data.CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@ColonNormal", ColonNormal))
            cmd.Parameters.Add(New SqlParameter("@ColonRestNormal", ColonRestNormal))
            'cmd.Parameters.Add(New SqlParameter("@Colitis", Colitis))
            'cmd.Parameters.Add(New SqlParameter("@Ileitis", Ileitis))
            'cmd.Parameters.Add(New SqlParameter("@Proctitis", Proctitis))
            cmd.Parameters.Add(New SqlParameter("@ColitisType", ColitisType))
            'cmd.Parameters.Add(New SqlParameter("@ColitisExtent", ColitisExtent))
            cmd.Parameters.Add(New SqlParameter("@ColonList", ColonList))
            'cmd.Parameters.Add(New SqlParameter("@ColonOtherDiagnosis", ColonOtherDiagnosis))
            'cmd.Parameters.Add(New SqlParameter("@MayoScore", MayoScore))
            'cmd.Parameters.Add(New SqlParameter("@SEScore", SEScore))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Upper GI QA"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUpperGIQA(ByVal procedureId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ogd_qa_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    ''' <summary>
    ''' This will use Entity Framework to Load the UpperGIQA Record by Procedure Id
    ''' </summary>
    ''' <param name="procedureId">Procedure Id</param>
    ''' <returns>ERS_UpperGIQA Object Class</returns>
    ''' <remarks></remarks>
    Public Function UpperGIQA_Find(ByVal procedureId As Integer) As ERS.Data.ERS_UpperGIQA
        Dim result As ERS.Data.ERS_UpperGIQA
        Using db As New ERS.Data.GastroDbEntities
            result = db.ERS_UpperGIQA.Where(Function(qa) qa.ProcedureId = procedureId).FirstOrDefault()
        End Using

        Return result

    End Function


    Public Function UpperGI_Save(ByVal record As ERS.Data.ERS_UpperGIQA, ByVal procedureId As Integer, Optional ByVal setComplete As Boolean = True) As Boolean
        Try
            Using db As New ERS.Data.GastroDbEntities
                If record.Id = 0 Then
                    '### Add this Procedure Id in the new Record.. and then INSERT to the Table! This is the ONLY mandatory field for a new UpperGIQA Record
                    record.ProcedureId = procedureId
                    Dim result = db.ERS_UpperGIQA.Add(record) '### 1st INSERT in the TRANSACTION

                    If setComplete Then
                        Dim ersRecordCount As New ERS.Data.ERS_RecordCount
                        ersRecordCount.Identifier = "QA"
                        ersRecordCount.ProcedureId = procedureId
                        ersRecordCount.RecordCount = 1
                        db.ERS_RecordCount.Add(ersRecordCount)  '### 2nd INSERT in the TRANSACTION
                    End If

                    db.SaveChanges() '### Total Batch TRANSACTIONs will COMMIT now!

                Else '### Now Hapy to Update
                    db.ERS_UpperGIQA.Attach(record)
                    db.Entry(record).State = Entity.EntityState.Modified
                    db.SaveChanges()

                    If setComplete Then
                        If Not db.ERS_RecordCount.Any(Function(x) x.ProcedureId = procedureId And x.Identifier = "QA") Then
                            Dim ersRecordCount As New ERS.Data.ERS_RecordCount
                            ersRecordCount.Identifier = "QA"
                            ersRecordCount.ProcedureId = procedureId
                            ersRecordCount.RecordCount = 1

                            db.ERS_RecordCount.Add(ersRecordCount)  '### 2nd INSERT in the TRANSACTION

                            db.SaveChanges() '### Total Batch TRANSACTIONs will COMMIT now!

                        End If
                    End If
                End If
                Dim da As DataAccess = New DataAccess()
                da.Update_UpperGIQA(procedureId)
            End Using

            Return True

        Catch ex As Exception
            Return False
        End Try


    End Function

    Public Function GetDefaultManagement(ByVal procedureId As Integer) As DataTable
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("procedure_default_qa_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    'Public Function InsertToERSList(ByVal Desc As String, Text As String) As String
    '    If Trim(Text) <> "" Then
    '        Dim r As Object
    '        Dim sql As String = "IF NOT EXISTS(SELECT 1 FROM ERS_Lists WHERE ListDescription = @Desc AND ListItemText = @Text) " &
    '                            " BEGIN 	DECLARE @m int = ISNULL((SELECT MAX(listItemNo) FROM ERS_Lists WHERE ListDescription = @Desc),0) + 1 " &
    '                            " INSERT INTO ERS_Lists (ListDescription,ListItemNo,ListItemText) VALUES (@Desc,@m,@Text) END " &
    '                            " SELECT listItemNo FROM ERS_Lists WHERE ListDescription = @Desc AND ListItemText = @Text"

    '        Using connection As New SqlConnection(DataAccess.ConnectionStr)
    '            Dim cmd As New SqlCommand(sql.ToString(), connection)
    '            cmd.CommandType = CommandType.Text
    '            cmd.Parameters.Add(New SqlParameter("@Desc", Desc))
    '            cmd.Parameters.Add(New SqlParameter("@Text", Text))
    '            connection.Open()
    '            r = cmd.ExecuteScalar()
    '            If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
    '                Return CStr(r)
    '            Else
    '                Return ""
    '            End If
    '        End Using
    '    Else
    '        Return ""
    '    End If

    'End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveUpperGIQA(ByVal ProcedureId As Integer,
                                  ByVal NoNotes As Boolean,
                                  ByVal ReferralLetter As Boolean,
                                  ByVal ManagementNone As Boolean,
                                  ByVal PulseOximetry As Boolean,
                                  ByVal IVAccess As Boolean,
                                  ByVal IVAntibiotics As Boolean,
                                  ByVal Oxygenation As Boolean,
                                  ByVal OxygenationMethod As Integer,
                                  ByVal OxygenationFlowRate As Nullable(Of Decimal),
                                  ByVal ContinuousECG As Boolean,
                                  ByVal BP As Boolean,
                                  ByVal BPSystolic As Nullable(Of Decimal),
                                  ByVal BPDiastolic As Nullable(Of Decimal),
                                  ByVal ManagementOther As Boolean,
                                  ByVal ManagementOtherText As String,
                                  ByVal PatSedation As Integer,
                                  ByVal PatSedationAsleepResponseState As Integer,
                                  ByVal PatDiscomfortNurse As Integer,
                                  ByVal PatDiscomfortEndo As Integer,
                                  ByVal ComplicationsNone As Boolean,
                                  ByVal PoorlyTolerated As Boolean,
                                  ByVal PatientDiscomfort As Boolean,
                                  ByVal PatientDistress As Boolean,
                                  ByVal InjuryToMouth As Boolean,
                                  ByVal FailedIntubation As Boolean,
                                  ByVal DifficultIntubation As Boolean,
                                  ByVal DamageToScope As Boolean,
                                  ByVal DamageToScopeType As Integer,
                                  ByVal GastricContentsAspiration As Boolean,
                                  ByVal ShockHypotension As Boolean,
                                  ByVal Haemorrhage As Boolean,
                                  ByVal SignificantHaemorrhage As Boolean,
                                  ByVal Hypoxia As Boolean,
                                  ByVal RespiratoryDepression As Boolean,
                                  ByVal RespiratoryArrest As Boolean,
                                  ByVal CardiacArrest As Boolean,
                                  ByVal CardiacArrythmia As Boolean,
                                  ByVal Death As Boolean,
                                  ByVal TechnicalFailure As String,
                                  ByVal Perforation As Boolean,
                                  ByVal PerforationText As String,
                                  ByVal ComplicationsOther As Boolean,
                                  ByVal ComplicationsOtherText As String,
                                  ByVal AbandonedOther As Boolean,
                                  ByVal AbandonedOtherText As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("ogd_qa_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@NoNotes", NoNotes))
            cmd.Parameters.Add(New SqlParameter("@ReferralLetter", ReferralLetter))
            cmd.Parameters.Add(New SqlParameter("@ManagementNone", ManagementNone))
            cmd.Parameters.Add(New SqlParameter("@PulseOximetry", PulseOximetry))
            cmd.Parameters.Add(New SqlParameter("@IVAccess", IVAccess))
            cmd.Parameters.Add(New SqlParameter("@IVAntibiotics", IVAntibiotics))
            cmd.Parameters.Add(New SqlParameter("@Oxygenation", Oxygenation))
            cmd.Parameters.Add(New SqlParameter("@OxygenationMethod", OxygenationMethod))
            If OxygenationFlowRate.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@OxygenationFlowRate", OxygenationFlowRate))
            Else
                cmd.Parameters.Add(New SqlParameter("@OxygenationFlowRate", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@ContinuousECG", ContinuousECG))
            cmd.Parameters.Add(New SqlParameter("@BP", BP))
            If BPSystolic.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@BPSystolic", BPSystolic))
            Else
                cmd.Parameters.Add(New SqlParameter("@BPSystolic", SqlTypes.SqlDecimal.Null))
            End If
            If BPDiastolic.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@BPDiastolic", BPDiastolic))
            Else
                cmd.Parameters.Add(New SqlParameter("@BPDiastolic", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@ManagementOther", ManagementOther))
            cmd.Parameters.Add(New SqlParameter("@ManagementOtherText", ManagementOtherText))
            cmd.Parameters.Add(New SqlParameter("@PatSedation", PatSedation))
            cmd.Parameters.Add(New SqlParameter("@PatSedationAsleepResponseState", PatSedationAsleepResponseState))
            cmd.Parameters.Add(New SqlParameter("@PatDiscomfortNurse", PatDiscomfortNurse))
            cmd.Parameters.Add(New SqlParameter("@PatDiscomfortEndo", PatDiscomfortEndo))
            cmd.Parameters.Add(New SqlParameter("@ComplicationsNone", ComplicationsNone))
            cmd.Parameters.Add(New SqlParameter("@PoorlyTolerated", PoorlyTolerated))
            cmd.Parameters.Add(New SqlParameter("@PatientDiscomfort", PatientDiscomfort))
            cmd.Parameters.Add(New SqlParameter("@PatientDistress", PatientDistress))
            cmd.Parameters.Add(New SqlParameter("@InjuryToMouth", InjuryToMouth))
            cmd.Parameters.Add(New SqlParameter("@FailedIntubation", FailedIntubation))
            cmd.Parameters.Add(New SqlParameter("@DifficultIntubation", DifficultIntubation))
            cmd.Parameters.Add(New SqlParameter("@DamageToScope", DamageToScope))
            cmd.Parameters.Add(New SqlParameter("@DamageToScopeType", DamageToScopeType))
            cmd.Parameters.Add(New SqlParameter("@GastricContentsAspiration", GastricContentsAspiration))
            cmd.Parameters.Add(New SqlParameter("@ShockHypotension", ShockHypotension))
            cmd.Parameters.Add(New SqlParameter("@Haemorrhage", Haemorrhage))
            cmd.Parameters.Add(New SqlParameter("@SignificantHaemorrhage", SignificantHaemorrhage))
            cmd.Parameters.Add(New SqlParameter("@Hypoxia", Hypoxia))
            cmd.Parameters.Add(New SqlParameter("@RespiratoryDepression", RespiratoryDepression))
            cmd.Parameters.Add(New SqlParameter("@RespiratoryArrest", RespiratoryArrest))
            cmd.Parameters.Add(New SqlParameter("@CardiacArrest", CardiacArrest))
            cmd.Parameters.Add(New SqlParameter("@CardiacArrythmia", CardiacArrythmia))
            cmd.Parameters.Add(New SqlParameter("@Death", Death))
            cmd.Parameters.Add(New SqlParameter("@TechnicalFailure", TechnicalFailure))
            cmd.Parameters.Add(New SqlParameter("@Perforation", Perforation))
            cmd.Parameters.Add(New SqlParameter("@PerforationText", PerforationText))
            cmd.Parameters.Add(New SqlParameter("@ComplicationsOther", ComplicationsOther))
            cmd.Parameters.Add(New SqlParameter("@ComplicationsOtherText", ComplicationsOtherText))
            cmd.Parameters.Add(New SqlParameter("@AbandonedOther", ComplicationsOther))
            cmd.Parameters.Add(New SqlParameter("@AbandonedOtherText", ComplicationsOtherText))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
    Public Function SaveDefaultManagement(ByVal ProcedureId As Integer,
                                  ByVal ManagementNone As Boolean,
                                  ByVal PulseOximetry As Boolean,
                                  ByVal IVAccess As Boolean,
                                  ByVal IVAntibiotics As Boolean,
                                  ByVal Oxygenation As Boolean,
                                  ByVal OxygenationMethod As Integer,
                                  ByVal OxygenationFlowRate As Nullable(Of Decimal),
                                  ByVal ContinuousECG As Boolean,
                                  ByVal BP As Boolean,
                                  ByVal BPSystolic As Nullable(Of Decimal),
                                  ByVal BPDiastolic As Nullable(Of Decimal),
                                  ByVal ManagementOther As Boolean,
                                  ByVal ManagementOtherText As String) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("procedure_default_qa_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@ManagementNone", ManagementNone))
            cmd.Parameters.Add(New SqlParameter("@PulseOximetry", PulseOximetry))
            cmd.Parameters.Add(New SqlParameter("@IVAccess", IVAccess))
            cmd.Parameters.Add(New SqlParameter("@IVAntibiotics", IVAntibiotics))
            cmd.Parameters.Add(New SqlParameter("@Oxygenation", Oxygenation))
            cmd.Parameters.Add(New SqlParameter("@OxygenationMethod", OxygenationMethod))
            If OxygenationFlowRate.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@OxygenationFlowRate", OxygenationFlowRate))
            Else
                cmd.Parameters.Add(New SqlParameter("@OxygenationFlowRate", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@ContinuousECG", ContinuousECG))
            cmd.Parameters.Add(New SqlParameter("@BP", BP))
            If BPSystolic.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@BPSystolic", BPSystolic))
            Else
                cmd.Parameters.Add(New SqlParameter("@BPSystolic", SqlTypes.SqlDecimal.Null))
            End If
            If BPDiastolic.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@BPDiastolic", BPDiastolic))
            Else
                cmd.Parameters.Add(New SqlParameter("@BPDiastolic", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@ManagementOther", ManagementOther))
            cmd.Parameters.Add(New SqlParameter("@ManagementOtherText", ManagementOtherText))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using
        Return rowsAffected
    End Function
#End Region

#Region "Upper GI Follow Up"


    Public Function GetReferringConsultant(ByVal procedureId As Integer) As String
        Dim dsResult As New DataSet
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("Select ReferralConsultantNo from ERS_Procedures where ProcedureId = @ProcedureId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            Dim v As Object = cmd.ExecuteScalar()
            If IsDBNull(v) Or IsNothing(v) Then
                Return Nothing
            Else
                Return CStr(v)
            End If
        End Using
        Return Nothing
    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUpperGIFollowUp(ByVal procedureId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ogd_followup_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SavePatientCopyTo(ByVal ProcedureId As Integer,
                                      ByVal CopyToPatient As Integer,
                                      ByVal CopyToPatientText As String,
                                      ByVal PatientNotCopiedReason As String,
                                      ByVal PatientNotCopiedReasonNewItemText As String,
                                      ByVal CopyToRefCon As Boolean,
                                      ByVal CopyToRefConText As String,
                                      ByVal CopyToOther As Boolean,
                                      ByVal CopyToOtherText As String,
                                      ByVal Salutation As String,
                                      ByVal CopyToGPEmailAddressCheckBox As Boolean,
                                      ByVal CopyToGPEmailAddressTextBox As String) As Integer

        Dim rowsAffected As Integer

        If PatientNotCopiedReason = "-99" Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("PatientNotCopiedReason", PatientNotCopiedReasonNewItemText)
            If newId > 0 Then
                PatientNotCopiedReason = newId.ToString()
            End If
        End If

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("ogd_PatientCopyTo_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@CopyToPatient", CopyToPatient))
            cmd.Parameters.Add(New SqlParameter("@CopyToPatientText", IIf(CopyToPatientText Is Nothing, DBNull.Value, CopyToPatientText)))
            cmd.Parameters.Add(New SqlParameter("@PatientNotCopiedReason", IIf(PatientNotCopiedReason Is Nothing, DBNull.Value, PatientNotCopiedReason)))
            cmd.Parameters.Add(New SqlParameter("@CopyToRefCon", CopyToRefCon))
            cmd.Parameters.Add(New SqlParameter("@CopyToRefConText", IIf(CopyToRefConText Is Nothing, DBNull.Value, CopyToRefConText)))
            cmd.Parameters.Add(New SqlParameter("@CopyToOther", CopyToOther))
            cmd.Parameters.Add(New SqlParameter("@CopyToOtherText", IIf(CopyToOtherText Is Nothing, DBNull.Value, CopyToOtherText)))
            cmd.Parameters.Add(New SqlParameter("@Salutation", Salutation))
            cmd.Parameters.Add(New SqlParameter("@CopyToGPEmailAddress", CopyToGPEmailAddressCheckBox))
            cmd.Parameters.Add(New SqlParameter("@CopyToGPEmailAddressText", IIf(CopyToGPEmailAddressTextBox Is Nothing, DBNull.Value, CopyToGPEmailAddressTextBox)))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveUpperGIFollowUp(ByVal ProcedureId As Integer,
                                        ByVal ProcedureTypeId As Integer,
                                        ByVal chkNoFurtherTestsRequired As Boolean?,
                                        ByVal chkAwaitingPathologyResults As Boolean?,
                                        ByVal rblCancerEvidence As Integer?,
                                        ByVal chkPatientInformed As Boolean?,
                                        ByVal chkFastTrackRemoved As Boolean?,
                                        ByVal txtReasonWhyNotInformed As String,
                                        ByVal chkCnsMdtcInformed As Boolean?,
                                        ByVal FurtherProcedure As Integer?,
                                        ByVal FurtherProcedureNewItemText As String,
                                        ByVal FurtherProcedureDueCount As Nullable(Of Integer),
                                        ByVal FurtherProcedureDueType As Integer?,
                                        ByVal FurtherProcedureText As String,
                                        ByVal ReturnTo As Integer?,
                                        ByVal ReturnToNewItemText As String,
                                        ByVal NoFurtherFollowUp As Boolean?,
                                        ByVal ReviewLocation As Integer?,
                                        ByVal ReviewLocationNewItemText As String,
                                        ByVal ReviewDueCount As Nullable(Of Integer),
                                        ByVal ReviewDueType As Integer?,
                                        ByVal ReviewText As String,
                                        ByVal Comments As String,
                                        ByVal PP_PFRFollowUp As String,
                                        ByVal ReBleedPlanRepeatGastroscopy As Boolean?,
                                        ByVal ReBleedPlanRequestSurgicalReview As Boolean?,
                                        ByVal ReBleedPlanOtherOption As Boolean?,
                                        ByVal ReBleedPlanOtherText As String,
                                        ByVal chkFindingAlert As Boolean?,
                                        ByVal chkImagingRequested As Boolean?,
                                        ByVal UrgentTwoWeekReferral As Boolean?,
                                        ByVal CancerResultId As Integer?,
                                        ByVal WhoStatusId As Integer?,
                                        ByVal cancerNotDetected As Boolean?,
                                        ByVal setComplete As Boolean,
                                        Optional ByVal RiskCategoriesTypeId As Integer? = Nothing
                                        ) As Integer

        Dim rowsAffected As Integer

        If ReturnTo = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Return or referred to", ReturnToNewItemText)
            If newId > 0 Then
                ReturnTo = newId
            End If
        End If

        If ReviewLocation = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Review", ReviewLocationNewItemText)
            If newId > 0 Then
                ReviewLocation = newId
            End If
        End If

        If FurtherProcedure = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem(da.GetFutherProcedures(ProcedureTypeId), FurtherProcedureNewItemText)
            If newId > 0 Then
                FurtherProcedure = newId
            End If
        End If


        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("ogd_followup_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@NoFurtherTestsRequired", chkNoFurtherTestsRequired))
            cmd.Parameters.Add(New SqlParameter("@AwaitingPathologyResults", chkAwaitingPathologyResults))

            If Not IsNothing(rblCancerEvidence) Then
                cmd.Parameters.Add(New SqlParameter("@EvidenceOfCancerIdentified", rblCancerEvidence))
            Else
                cmd.Parameters.Add(New SqlParameter("@EvidenceOfCancerIdentified", DBNull.Value))
            End If

            cmd.Parameters.Add(New SqlParameter("@PatientInformed", chkPatientInformed))
            cmd.Parameters.Add(New SqlParameter("@PatientRemovedFromFastTrack", chkFastTrackRemoved))
            cmd.Parameters.Add(New SqlParameter("@NotInformedReason", txtReasonWhyNotInformed))
            cmd.Parameters.Add(New SqlParameter("@CnsMdtcInformed", chkCnsMdtcInformed))
            cmd.Parameters.Add(New SqlParameter("@ImagingRequested", chkImagingRequested))
            cmd.Parameters.Add(New SqlParameter("@FurtherProcedure", FurtherProcedure))
            If FurtherProcedureDueCount.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@FurtherProcedureDueCount", FurtherProcedureDueCount))
            Else
                cmd.Parameters.Add(New SqlParameter("@FurtherProcedureDueCount", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@FurtherProcedureDueType", FurtherProcedureDueType))
            cmd.Parameters.Add(New SqlParameter("@FurtherProcedureText", FurtherProcedureText))
            cmd.Parameters.Add(New SqlParameter("@ReturnTo", If(ReturnTo = -55, Nothing, ReturnTo)))
            cmd.Parameters.Add(New SqlParameter("@NoFurtherFollowUp", NoFurtherFollowUp))
            cmd.Parameters.Add(New SqlParameter("@ReviewLocation", If(ReviewLocation = -55, Nothing, ReviewLocation)))
            If ReviewDueCount.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@ReviewDueCount", ReviewDueCount))
            Else
                cmd.Parameters.Add(New SqlParameter("@ReviewDueCount", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@ReviewDueType", ReviewDueType))
            cmd.Parameters.Add(New SqlParameter("@ReviewText", ReviewText))
            cmd.Parameters.Add(New SqlParameter("@Comments", Comments))
            cmd.Parameters.Add(New SqlParameter("@PP_PFRFollowUp", PP_PFRFollowUp))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Parameters.Add(New SqlParameter("@ReBleedPlanRepeatGastroscopy", ReBleedPlanRepeatGastroscopy))
            cmd.Parameters.Add(New SqlParameter("@ReBleedPlanRequestSurgicalReview", ReBleedPlanRequestSurgicalReview))
            cmd.Parameters.Add(New SqlParameter("@ReBleedPlanOtherOption", ReBleedPlanOtherOption))
            cmd.Parameters.Add(New SqlParameter("@ReBleedPlanOtherText", ReBleedPlanOtherText))
            cmd.Parameters.Add(New SqlParameter("@ClinicalFindingAlert", chkFindingAlert))
            cmd.Parameters.Add(New SqlParameter("@setComplete", IIf(setComplete, 1, 0)))
            cmd.Parameters.Add(New SqlParameter("@UrgentTwoWeekReferral", UrgentTwoWeekReferral))
            cmd.Parameters.Add(New SqlParameter("@CancerResultId", CancerResultId))
            'cmd.Parameters.Add(New SqlParameter("@CancerNotDetected", cancerNotDetected))
            cmd.Parameters.Add(New SqlParameter("@WhoStatusId", If(WhoStatusId = -1, Nothing, WhoStatusId)))
            cmd.Parameters.Add(New SqlParameter("@RiskCategoriesTypeId", RiskCategoriesTypeId))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Upper GI Rx"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetUpperGIRx(ByVal procedureId As Integer) As DataTable
        Using da As New DataAccess
            Return da.ExecuteSP("ogd_rx_select", New SqlParameter() {New SqlParameter("@ProcedureId", procedureId)})
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveUpperGIRx(ByVal ProcedureId As Integer,
                                       ByVal ContMedication As Boolean,
                                       ByVal ContMedicationByGP As Boolean,
                                       ByVal ContPrescribeMedication As Boolean,
                                       ByVal SuggestPrescribe As Boolean,
                                       ByVal MedicationText As String,
                                       Optional ByVal IsModified As Nullable(Of Boolean) = Nothing,
                                       Optional ByVal setComplete As Boolean = True) As Integer
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("ogd_rx_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@ContMedication", ContMedication))
            cmd.Parameters.Add(New SqlParameter("@ContMedicationByGP", ContMedicationByGP))
            cmd.Parameters.Add(New SqlParameter("@ContPrescribeMedication", ContPrescribeMedication))
            cmd.Parameters.Add(New SqlParameter("@SuggestPrescribe", SuggestPrescribe))
            cmd.Parameters.Add(New SqlParameter("@MedicationText", MedicationText.Replace(vbLf, "<br />")))
            cmd.Parameters.Add(New SqlParameter("@IsUserModified", IsModified))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            cmd.Parameters.Add(New SqlParameter("@setComplete", IIf(setComplete, 1, 0)))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using
        Return rowsAffected
    End Function

    Public Function IsRxComplete(ProcedureId) As Boolean
        Dim value As Boolean
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim querystr As String = "SELECT TOP(1) * FROM ERS_PatientMedication where ProcedureNo = @ProcedureId"
            Dim mycmd As New SqlCommand(querystr, connection)
            mycmd.CommandType = CommandType.Text
            mycmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            connection.Open()
            value = mycmd.ExecuteScalar()
        End Using
        Return CBool(value)
    End Function
#End Region

#Region "Colon Extent/Limiting factors"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetColonExtentLimitingFactor(ByVal procedureId As Integer) As DataTable
        Using da As New DataAccess
            Return da.ExecuteSP("colon_extent_limiting_factors_select", New SqlParameter() {New SqlParameter("@ProcedureId", procedureId)})
        End Using
    End Function


    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveColonExtentLimitingFactor(ByVal ProcedureId As Integer,
                                       ByVal RectalExam As Boolean,
                                       ByVal Retroflexion As Boolean,
                                       ByVal InsertionVia As Integer,
                                       ByVal InsertionTo As Integer,
                                       ByVal SpecificDistanceCm As Integer,
                                       ByVal InsertionConfirmedBy As Integer,
                                       ByVal InsertionConfirmedByNewItemText As String,
                                       ByVal InsertionLimitedBy As Integer,
                                       ByVal InsertionLimitedByNewItemText As String,
                                       ByVal DifficultiesEncountered As Integer,
                                       ByVal DifficultiesEncounteredNewItemText As String,
                                       ByVal IleocecalValve As Boolean,
                                       ByVal TransIllumination As Boolean,
                                       ByVal IlealIntubation As Boolean,
                                       ByVal AppendicularOrifice As Boolean,
                                       ByVal TriRadiateCaecalFold As Boolean,
                                       ByVal DigitalPressure As Boolean,
                                       ByVal DegreeOfConfidence As Boolean,
                                       ByVal Positively As Boolean,
                                       ByVal WithReasonableConfidence As Boolean,
                                       ByVal TimeToCaecumMin As Integer,
                                       ByVal TimeToCaecumSec As Integer,
                                       ByVal TimeForWithdrawalMin As Integer,
                                       ByVal TimeForWithdrawalSec As Integer,
                                       ByVal Abandoned As Boolean,
                                       ByVal RectalExam_NED As Boolean,
                                       ByVal Retroflexion_NED As Boolean,
                                       ByVal InsertionTo_NED As Integer,
                                       ByVal SpecificDistanceCm_NED As Integer,
                                       ByVal InsertionConfirmedBy_NED As Integer,
                                       ByVal InsertionConfirmedByNewItemText_NED As String,
                                       ByVal InsertionLimitedBy_NED As Integer,
                                       ByVal InsertionLimitedByNewItemText_NED As String,
                                       ByVal DifficultiesEncountered_NED As Integer,
                                       ByVal DifficultiesEncounteredNewItemText_NED As String,
                                       ByVal IleocecalValve_NED As Boolean,
                                       ByVal TransIllumination_NED As Boolean,
                                       ByVal IlealIntubation_NED As Boolean,
                                       ByVal AppendicularOrifice_NED As Boolean,
                                       ByVal TriRadiateCaecalFold_NED As Boolean,
                                       ByVal DigitalPressure_NED As Boolean,
                                       ByVal DegreeOfConfidence_NED As Boolean,
                                       ByVal Positively_NED As Boolean,
                                       ByVal WithReasonableConfidence_NED As Boolean,
                                       ByVal TimeToCaecumMin_NED As Integer,
                                       ByVal TimeToCaecumSec_NED As Integer,
                                       ByVal TimeForWithdrawalMin_NED As Integer,
                                       ByVal TimeForWithdrawalSec_NED As Integer,
                                       ByVal Abandoned_NED As Boolean,
                                       isSaveAndClose As Boolean) As Integer
        Dim rowsAffected As Integer

        If InsertionConfirmedBy = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Colon_Extent_Insertion_Comfirmed_By", InsertionConfirmedByNewItemText)
            If newId > 0 Then
                InsertionConfirmedBy = newId.ToString()
            End If
        End If

        If InsertionLimitedBy = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Colon_Extent_Insertion_Limited_By", InsertionLimitedByNewItemText)
            If newId > 0 Then
                InsertionLimitedBy = newId.ToString()
            End If
        End If

        If DifficultiesEncountered = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Colon_Extent_Difficulty_Encountered", DifficultiesEncounteredNewItemText)
            If newId > 0 Then
                DifficultiesEncountered = newId.ToString()
            End If
        End If

        If InsertionConfirmedBy_NED = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Colon_Extent_Insertion_Comfirmed_By", InsertionConfirmedByNewItemText_NED)
            If newId > 0 Then
                InsertionConfirmedBy_NED = newId.ToString()
            End If
        End If

        If InsertionLimitedBy_NED = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Colon_Extent_Insertion_Limited_By", InsertionLimitedByNewItemText_NED)
            If newId > 0 Then
                InsertionLimitedBy_NED = newId.ToString()
            End If
        End If

        If DifficultiesEncountered_NED = -99 Then
            Dim da As New DataAccess
            Dim newId = da.InsertListItem("Colon_Extent_Difficulty_Encountered", DifficultiesEncounteredNewItemText_NED)
            If newId > 0 Then
                DifficultiesEncountered_NED = newId.ToString()
            End If
        End If

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("colon_extent_limiting_factors_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            cmd.Parameters.Add(New SqlParameter("@RectalExam", RectalExam))
            cmd.Parameters.Add(New SqlParameter("@Retroflexion", Retroflexion))
            cmd.Parameters.Add(New SqlParameter("@InsertionVia", InsertionVia))
            cmd.Parameters.Add(New SqlParameter("@InsertionTo", InsertionTo))
            cmd.Parameters.Add(New SqlParameter("@SpecificDistanceCm", SpecificDistanceCm))
            cmd.Parameters.Add(New SqlParameter("@InsertionConfirmedBy", InsertionConfirmedBy))
            cmd.Parameters.Add(New SqlParameter("@InsertionLimitedBy", InsertionLimitedBy))
            cmd.Parameters.Add(New SqlParameter("@DifficultiesEncountered", DifficultiesEncountered))
            cmd.Parameters.Add(New SqlParameter("@IleocecalValve", IleocecalValve))
            cmd.Parameters.Add(New SqlParameter("@TransIllumination", TransIllumination))
            cmd.Parameters.Add(New SqlParameter("@IlealIntubation", IlealIntubation))
            cmd.Parameters.Add(New SqlParameter("@AppendicularOrifice", AppendicularOrifice))
            cmd.Parameters.Add(New SqlParameter("@TriRadiateCaecalFold", TriRadiateCaecalFold))
            cmd.Parameters.Add(New SqlParameter("@DigitalPressure", DigitalPressure))
            cmd.Parameters.Add(New SqlParameter("@DegreeOfConfidence", DegreeOfConfidence))
            cmd.Parameters.Add(New SqlParameter("@Positively", Positively))
            cmd.Parameters.Add(New SqlParameter("@WithReasonableConfidence", WithReasonableConfidence))
            cmd.Parameters.Add(New SqlParameter("@TimeToCaecumMin", TimeToCaecumMin))
            cmd.Parameters.Add(New SqlParameter("@TimeToCaecumSec", TimeToCaecumSec))
            cmd.Parameters.Add(New SqlParameter("@TimeForWithdrawalMin", TimeForWithdrawalMin))
            cmd.Parameters.Add(New SqlParameter("@TimeForWithdrawalSec", TimeForWithdrawalSec))
            cmd.Parameters.Add(New SqlParameter("@Abandoned", Abandoned))

            cmd.Parameters.Add(New SqlParameter("@RectalExam_NED", RectalExam_NED))
            cmd.Parameters.Add(New SqlParameter("@Retroflexion_NED", Retroflexion_NED))
            cmd.Parameters.Add(New SqlParameter("@InsertionTo_NED", InsertionTo_NED))
            cmd.Parameters.Add(New SqlParameter("@SpecificDistanceCm_NED", SpecificDistanceCm_NED))
            cmd.Parameters.Add(New SqlParameter("@InsertionConfirmedBy_NED", InsertionConfirmedBy_NED))
            cmd.Parameters.Add(New SqlParameter("@InsertionLimitedBy_NED", InsertionLimitedBy_NED))
            cmd.Parameters.Add(New SqlParameter("@DifficultiesEncountered_NED", DifficultiesEncountered_NED))
            cmd.Parameters.Add(New SqlParameter("@IleocecalValve_NED", IleocecalValve_NED))
            cmd.Parameters.Add(New SqlParameter("@TransIllumination_NED", TransIllumination_NED))
            cmd.Parameters.Add(New SqlParameter("@IlealIntubation_NED", IlealIntubation_NED))
            cmd.Parameters.Add(New SqlParameter("@AppendicularOrifice_NED", AppendicularOrifice_NED))
            cmd.Parameters.Add(New SqlParameter("@TriRadiateCaecalFold_NED", TriRadiateCaecalFold_NED))
            cmd.Parameters.Add(New SqlParameter("@DigitalPressure_NED", DigitalPressure_NED))
            cmd.Parameters.Add(New SqlParameter("@DegreeOfConfidence_NED", DegreeOfConfidence_NED))
            cmd.Parameters.Add(New SqlParameter("@Positively_NED", Positively_NED))
            cmd.Parameters.Add(New SqlParameter("@WithReasonableConfidence_NED", WithReasonableConfidence_NED))
            cmd.Parameters.Add(New SqlParameter("@TimeToCaecumMin_NED", TimeToCaecumMin_NED))
            cmd.Parameters.Add(New SqlParameter("@TimeToCaecumSec_NED", TimeToCaecumSec_NED))
            cmd.Parameters.Add(New SqlParameter("@TimeForWithdrawalMin_NED", TimeForWithdrawalMin_NED))
            cmd.Parameters.Add(New SqlParameter("@TimeForWithdrawalSec_NED", TimeForWithdrawalSec_NED))
            cmd.Parameters.Add(New SqlParameter("@Abandoned_NED", Abandoned_NED))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            cmd.Parameters.Add(New SqlParameter("@setComplete", IIf(isSaveAndClose, 1, 0)))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

#End Region

#Region "Visualisation"
    Public Function SelectVisualisation(paramProcedureID As Integer) As ERS.Data.ERS_Visualisation
        'Return DataAccess.ExecuteSQL("SELECT * FROM [ERS_Visualisation] WHERE ProcedureID= @ProcedureID;", New SqlParameter() {New SqlParameter("@ProcedureID", procedureID)})
        Using db As New ERS.Data.GastroDbEntities
            Return db.ERS_Visualisation.Where(Function(vis) vis.ProcedureID = paramProcedureID).FirstOrDefault()
        End Using
    End Function
    Public Function SaveVisualisation(
                                     visRecordId As Integer,
                                      ProcedureID As Integer,
                                      CarriedOutRole As Integer,
                                      AccessVia As Integer,
                                     AccessViaOtherText As String,
                                     MajorPapillaBile As Integer,
                                        MajorPapillaBileReason As String,
                                        MajorPapillaPancreatic As Integer,
                                        MajorPapillaPancreaticReason As String,
                                        MinorPapilla As Integer,
                                        MinorPapillaReason As String,
                                        HepatobiliaryNotVisualised As Boolean,
                                        HepatobiliaryWholeBiliary As Boolean,
                                        ExceptBileDuct As Boolean,
                                        ExceptGallBladder As Boolean,
                                        ExceptCommonHepaticDuct As Boolean,
                                        ExceptRightHepaticDuct As Boolean,
                                        ExceptLeftHepaticDuct As Boolean,
                                        HepatobiliaryAcinarFilling As Boolean,
                                        HepatobiliaryLimitedBy As Integer,
                                        HepatobiliaryLimitedByOtherText As String,
                                        PancreaticNotVisualised As Boolean,
                                        PancreaticDivisum As Boolean,
                                        PancreaticWhole As Boolean,
                                        ExceptAccesoryPancreatic As Boolean,
                                        ExceptMainPancreatic As Boolean,
                                        ExceptUncinate As Boolean,
                                        ExceptHead As Boolean,
                                        ExceptNeck As Boolean,
                                        ExceptBody As Boolean,
                                        ExceptTail As Boolean,
                                        PancreaticAcinar As Boolean,
                                        PancreaticLimitedBy As Integer,
                                        PancreaticLimitedByOtherText As String,
                                        HepatobiliaryFirst As Integer,
                                        HepatobiliaryFirstML As String,
                                        HepatobiliarySecond As Integer,
                                        HepatobiliarySecondML As String,
                                        HepatobiliaryBalloon As Boolean,
                                        PancreaticFirst As Integer,
                                        PancreaticFirstML As String,
                                        PancreaticSecond As Integer,
                                        PancreaticSecondML As String,
                                        PancreaticBalloon As Boolean,
                                        Abandoned As Boolean
                                        ) As Integer

        Dim rowsAffected As Integer
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("otherdata_visualisation_save", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@Id", visRecordId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureID", ProcedureID))
            cmd.Parameters.Add(New SqlParameter("@CarriedOutRole", CarriedOutRole))
            cmd.Parameters.Add(New SqlParameter("@AccessVia", AccessVia))
            cmd.Parameters.Add(New SqlParameter("@AccessViaOtherText", AccessViaOtherText))
            cmd.Parameters.Add(New SqlParameter("@MajorPapillaBile", MajorPapillaBile))
            cmd.Parameters.Add(New SqlParameter("@MajorPapillaBileReason", MajorPapillaBileReason))
            cmd.Parameters.Add(New SqlParameter("@MajorPapillaPancreatic", MajorPapillaPancreatic))
            cmd.Parameters.Add(New SqlParameter("@MajorPapillaPancreaticReason", MajorPapillaPancreaticReason))
            cmd.Parameters.Add(New SqlParameter("@MinorPapilla", MinorPapilla))
            cmd.Parameters.Add(New SqlParameter("@MinorPapillaReason", MinorPapillaReason))
            cmd.Parameters.Add(New SqlParameter("@HepatobiliaryNotVisualised", HepatobiliaryNotVisualised))
            cmd.Parameters.Add(New SqlParameter("@HepatobiliaryWholeBiliary", HepatobiliaryWholeBiliary))
            cmd.Parameters.Add(New SqlParameter("@ExceptBileDuct", ExceptBileDuct))
            cmd.Parameters.Add(New SqlParameter("@ExceptGallBladder", ExceptGallBladder))
            cmd.Parameters.Add(New SqlParameter("@ExceptCommonHepaticDuct", ExceptCommonHepaticDuct))
            cmd.Parameters.Add(New SqlParameter("@ExceptRightHepaticDuct", ExceptRightHepaticDuct))
            cmd.Parameters.Add(New SqlParameter("@ExceptLeftHepaticDuct", ExceptLeftHepaticDuct))
            cmd.Parameters.Add(New SqlParameter("@HepatobiliaryAcinarFilling", HepatobiliaryAcinarFilling))
            cmd.Parameters.Add(New SqlParameter("@HepatobiliaryLimitedBy", HepatobiliaryLimitedBy))
            cmd.Parameters.Add(New SqlParameter("@HepatobiliaryLimitedByOtherText", HepatobiliaryLimitedByOtherText))
            cmd.Parameters.Add(New SqlParameter("@PancreaticNotVisualised", PancreaticNotVisualised))
            cmd.Parameters.Add(New SqlParameter("@PancreaticDivisum", PancreaticDivisum))
            cmd.Parameters.Add(New SqlParameter("@PancreaticWhole", PancreaticWhole))
            cmd.Parameters.Add(New SqlParameter("@ExceptAccesoryPancreatic", ExceptAccesoryPancreatic))
            cmd.Parameters.Add(New SqlParameter("@ExceptMainPancreatic", ExceptMainPancreatic))
            cmd.Parameters.Add(New SqlParameter("@ExceptUncinate", ExceptUncinate))
            cmd.Parameters.Add(New SqlParameter("@ExceptHead", ExceptHead))
            cmd.Parameters.Add(New SqlParameter("@ExceptNeck", ExceptNeck))
            cmd.Parameters.Add(New SqlParameter("@ExceptBody", ExceptBody))
            cmd.Parameters.Add(New SqlParameter("@ExceptTail", ExceptTail))
            cmd.Parameters.Add(New SqlParameter("@PancreaticAcinar", PancreaticAcinar))
            cmd.Parameters.Add(New SqlParameter("@PancreaticLimitedBy", PancreaticLimitedBy))
            cmd.Parameters.Add(New SqlParameter("@PancreaticLimitedByOtherText", PancreaticLimitedByOtherText))
            cmd.Parameters.Add(New SqlParameter("@HepatobiliaryFirst", HepatobiliaryFirst))
            cmd.Parameters.Add(New SqlParameter("@HepatobiliaryFirstML", HepatobiliaryFirstML))
            cmd.Parameters.Add(New SqlParameter("@HepatobiliarySecond", HepatobiliarySecond))
            cmd.Parameters.Add(New SqlParameter("@HepatobiliarySecondML", HepatobiliarySecondML))
            cmd.Parameters.Add(New SqlParameter("@HepatobiliaryBalloon", HepatobiliaryBalloon))
            cmd.Parameters.Add(New SqlParameter("@PancreaticFirst", PancreaticFirst))
            cmd.Parameters.Add(New SqlParameter("@PancreaticFirstML", PancreaticFirstML))
            cmd.Parameters.Add(New SqlParameter("@PancreaticSecond", PancreaticSecond))
            cmd.Parameters.Add(New SqlParameter("@PancreaticSecondML", PancreaticSecondML))
            cmd.Parameters.Add(New SqlParameter("@PancreaticBalloon", PancreaticBalloon))
            cmd.Parameters.Add(New SqlParameter("@Abandoned", Abandoned))
            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using
        Return rowsAffected
    End Function

    Public Function SaveVisualisation(ByVal record As ERS.Data.ERS_Visualisation, ByVal INSERT_NEW As Boolean, ByVal isSaveAndExit As Boolean)
        Try
            Using db As New ERS.Data.GastroDbEntities
                Dim VisRecord = SelectVisualisation(record.ProcedureID)

                If VisRecord IsNot Nothing Then
                    record.WhoUpdatedId = CInt(HttpContext.Current.Session("PKUserID"))
                    record.WhenUpdated = Now
                    db.ERS_Visualisation.Attach(record)
                    db.Entry(record).State = Entity.EntityState.Modified
                    db.SaveChanges()
                Else
                    record.WhoCreatedId = CInt(HttpContext.Current.Session("PKUserID"))
                    record.WhenCreated = Now
                    '### Add this Procedure Id in the new Record.. and then INSERT to the Table! This is the ONLY mandatory field for a new ERS_Visualisation Record
                    Dim result = db.ERS_Visualisation.Add(record) '### 1st INSERT in the TRANSACTION
                    Dim ersRecordCount As New ERS.Data.ERS_RecordCount
                    ersRecordCount.Identifier = "visualisation"
                    ersRecordCount.ProcedureId = record.ProcedureID
                    ersRecordCount.RecordCount = 1
                    db.ERS_RecordCount.Add(ersRecordCount)  '### 2nd INSERT in the TRANSACTION

                    db.SaveChanges() '### Total Batch TRANSACTIONs will COMMIT now!

                End If
                Dim da As DataAccess = New DataAccess()
                da.Visualisation_DuplicateCheck(record.ProcedureID)
                'If INSERT_NEW Then
                '    record.WhoCreatedId = CInt(HttpContext.Current.Session("PKUserID"))
                '    record.WhenCreated = Now
                '    '### Add this Procedure Id in the new Record.. and then INSERT to the Table! This is the ONLY mandatory field for a new ERS_Visualisation Record
                '    Dim result = db.ERS_Visualisation.Add(record) '### 1st INSERT in the TRANSACTION
                '    Dim ersRecordCount As New ERS.Data.ERS_RecordCount
                '    ersRecordCount.Identifier = "visualisation"
                '    ersRecordCount.ProcedureId = record.ProcedureID
                '    ersRecordCount.RecordCount = 1
                '    db.ERS_RecordCount.Add(ersRecordCount)  '### 2nd INSERT in the TRANSACTION

                '    db.SaveChanges() '### Total Batch TRANSACTIONs will COMMIT now!

                'Else '### Now Hapy to Update
                '    record.WhoUpdatedId = CInt(HttpContext.Current.Session("PKUserID"))
                '    record.WhenUpdated = Now
                '    db.ERS_Visualisation.Attach(record)
                '    db.Entry(record).State = Entity.EntityState.Modified
                '    db.SaveChanges()
                'End If
            End Using

            Return True

        Catch ex As Exception
            Return False
        End Try
    End Function
    Public Function Visualisation_Delete(visRecordId As Integer)

        Return DataAccess.ExecuteScalerSQL("DELETE FROM dbo.ERS_Visualisation WHERE ID=@Id", CommandType.Text, New SqlParameter() {New SqlParameter("@Id", visRecordId)})

    End Function

    Public Function GetVisualisationRecordInfo(ByVal procedureId As Integer) As ERS.Data.EndoscopistSearch_Result
        Dim result As IQueryable(Of ERS.Data.EndoscopistSearch_Result)
        Try
            Using db As New ERS.Data.GastroDbEntities
                '### First get the Details about the Endoscopist! Both 1 and 2 wherever applicable!
                result = db.EndoscopistSelectByProcedureSite(procedureId, 0)
                Return result.FirstOrDefault()
            End Using


        Catch ex As Exception

            Return Nothing
        End Try

    End Function
#End Region

#Region "ERCP Papillary Anatomy"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetERCPPapillaryAnatomy(ByVal procedureId As Integer) As DataTable
        Using da As New DataAccess
            Return da.ExecuteSP("ercp_papillaryanatomy_select", New SqlParameter() {New SqlParameter("@ProcedureId", procedureId)})
        End Using
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SavePapillaryAnatomyData(
                        ByVal ProcedureId As Integer,
                        ByVal MajorSiteLocation As Nullable(Of Integer),
                        ByVal MajorSize As Nullable(Of Integer),
                        ByVal MajorNoOfOpenings As Nullable(Of Integer),
                        ByVal MajorFloppy As Boolean,
                        ByVal MajorStenosed As Boolean,
                        ByVal MajorSurgeryNone As Boolean,
                        ByVal MajorEndoscopic As Boolean,
                        ByVal MajorEndoscopicSize As Nullable(Of Decimal),
                        ByVal MajorOperative As Boolean,
                        ByVal MajorOperativeSize As Nullable(Of Decimal),
                        ByVal MajorSphincteroplasty As Boolean,
                        ByVal MajorSphincteroplastySize As Nullable(Of Decimal),
                        ByVal MajorCholedochoduodenostomy As Boolean,
                        ByVal MinorSiteLocation As Nullable(Of Integer),
                        ByVal MinorSize As Nullable(Of Integer),
                        ByVal MinorStenosed As Boolean,
                        ByVal MinorSurgeryNone As Boolean,
                        ByVal MinorEndoscopic As Boolean,
                        ByVal MinorEndoscopicSize As Nullable(Of Decimal),
                        ByVal MinorOperative As Boolean,
                        ByVal MinorOperativeSize As Nullable(Of Decimal),
                        ByVal MajorBilrothRoux As Boolean) As Integer

        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("ercp_papillaryanatomy_save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", ProcedureId))
            If MajorSiteLocation.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MajorSiteLocation", MajorSiteLocation))
            Else
                cmd.Parameters.Add(New SqlParameter("@MajorSiteLocation", SqlTypes.SqlInt32.Null))
            End If
            If MajorSize.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MajorSize", MajorSize))
            Else
                cmd.Parameters.Add(New SqlParameter("@MajorSize", SqlTypes.SqlInt32.Null))
            End If
            If MajorNoOfOpenings.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MajorNoOfOpenings", MajorNoOfOpenings))
            Else
                cmd.Parameters.Add(New SqlParameter("@MajorNoOfOpenings", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@MajorFloppy", MajorFloppy))
            cmd.Parameters.Add(New SqlParameter("@MajorStenosed", MajorStenosed))
            cmd.Parameters.Add(New SqlParameter("@MajorSurgeryNone", MajorSurgeryNone))
            cmd.Parameters.Add(New SqlParameter("@MajorEndoscopic", MajorEndoscopic))
            If MajorEndoscopicSize.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MajorEndoscopicSize", MajorEndoscopicSize))
            Else
                cmd.Parameters.Add(New SqlParameter("@MajorEndoscopicSize", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@MajorOperative", MajorOperative))
            If MajorOperativeSize.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MajorOperativeSize", MajorOperativeSize))
            Else
                cmd.Parameters.Add(New SqlParameter("@MajorOperativeSize", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@MajorSphincteroplasty", MajorSphincteroplasty))
            If MajorSphincteroplastySize.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MajorSphincteroplastySize", MajorSphincteroplastySize))
            Else
                cmd.Parameters.Add(New SqlParameter("@MajorSphincteroplastySize", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@MajorCholedochoduodenostomy", MajorCholedochoduodenostomy))
            If MinorSiteLocation.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MinorSiteLocation", MinorSiteLocation))
            Else
                cmd.Parameters.Add(New SqlParameter("@MinorSiteLocation", SqlTypes.SqlInt32.Null))
            End If
            If MinorSize.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MinorSize", MinorSize))
            Else
                cmd.Parameters.Add(New SqlParameter("@MinorSize", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@MinorStenosed", MinorStenosed))
            cmd.Parameters.Add(New SqlParameter("@MinorSurgeryNone", MinorSurgeryNone))
            cmd.Parameters.Add(New SqlParameter("@MinorEndoscopic", MinorEndoscopic))
            cmd.Parameters.Add(New SqlParameter("@MajorBilrothRoux", MajorBilrothRoux))
            If MinorEndoscopicSize.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MinorEndoscopicSize", MinorEndoscopicSize))
            Else
                cmd.Parameters.Add(New SqlParameter("@MinorEndoscopicSize", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@MinorOperative", MinorOperative))
            If MinorOperativeSize.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@MinorOperativeSize", MinorOperativeSize))
            Else
                cmd.Parameters.Add(New SqlParameter("@MinorOperativeSize", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Broncho Drugs"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetBronchoPremedication(ByVal procedureId As Integer) As DataTable
        Dim dsSite As New DataSet
        Dim query As New StringBuilder

        query.Append("SELECT * FROM ERS_DrugList l left JOIN ERS_UpperGIPremedication m ON l.DrugNo = m.DrugNo AND ProcedureId = @ProcedureId WHERE UsedInBroncho = 1")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsSite)
        End Using

        If dsSite.Tables.Count > 0 Then
            Return dsSite.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetBronchoDrugs(ByVal procedureId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("broncho_drugs_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveBronchoPremedication(ByVal procedureId As Integer,
                                             ByVal drugNo As Integer,
                                             ByVal dose As Nullable(Of Decimal)) As Integer
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)

            Dim cmd As SqlCommand = New SqlCommand("ogd_premedication_save", connection)
            cmd.CommandType = System.Data.CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@DrugNo", drugNo))
            If dose.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Dose", dose))
            Else
                cmd.Parameters.Add(New SqlParameter("@Dose", SqlTypes.SqlDecimal.Null))
            End If

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveBronchoDrugs(ByVal procedureId As Integer,
                                     ByVal effectOfSedation As Integer?,
                                     ByVal lignocaineSpray As Boolean,
                                     ByVal lignocaineSprayTotal As Nullable(Of Decimal),
                                     ByVal lignocaineGel As Boolean,
                                     ByVal lignocaineViaScope1pc As Nullable(Of Decimal),
                                     ByVal lignocaineViaScope2pc As Nullable(Of Decimal),
                                     ByVal lignocaineViaScope4pc As Nullable(Of Decimal),
                                     ByVal lignocaineNebuliser2pc As Nullable(Of Decimal),
                                     ByVal lignocaineNebuliser4pc As Nullable(Of Decimal),
                                     ByVal lignocaineTranscricoid2pc As Nullable(Of Decimal),
                                     ByVal lignocaineTranscricoid4pc As Nullable(Of Decimal),
                                     ByVal lignocaineBronchial1pc As Nullable(Of Decimal),
                                     ByVal lignocaineBronchial2pc As Nullable(Of Decimal),
                                     ByVal supplyOxygen As Boolean,
                                     ByVal supplyOxygenPercentage As Nullable(Of Decimal),
                                     ByVal nasal As Nullable(Of Decimal),
                                     ByVal spO2Base As Nullable(Of Decimal),
                                     ByVal spO2Min As Nullable(Of Decimal),
                                     ByVal lignocaineSprayPercentage As Integer?) As Integer
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)

            Dim cmd As SqlCommand = New SqlCommand("broncho_drugs_save", connection)
            cmd.CommandType = System.Data.CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@EffectOfSedation", If(effectOfSedation.HasValue, effectOfSedation, Nothing)))
            cmd.Parameters.Add(New SqlParameter("@LignocaineSpray", lignocaineSpray))
            cmd.Parameters.Add(New SqlParameter("@LignocaineGel", lignocaineGel))
            If lignocaineSprayTotal.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@lignocaineSprayTotal", lignocaineSprayTotal))
            Else
                cmd.Parameters.Add(New SqlParameter("@lignocaineSprayTotal", SqlTypes.SqlDecimal.Null))
            End If
            If lignocaineViaScope1pc.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@LignocaineViaScope1pc", lignocaineViaScope1pc))
            Else
                cmd.Parameters.Add(New SqlParameter("@LignocaineViaScope1pc", SqlTypes.SqlDecimal.Null))
            End If
            If lignocaineViaScope2pc.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@LignocaineViaScope2pc", lignocaineViaScope2pc))
            Else
                cmd.Parameters.Add(New SqlParameter("@LignocaineViaScope2pc", SqlTypes.SqlDecimal.Null))
            End If
            If lignocaineViaScope4pc.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@LignocaineViaScope4pc", lignocaineViaScope4pc))
            Else
                cmd.Parameters.Add(New SqlParameter("@LignocaineViaScope4pc", SqlTypes.SqlDecimal.Null))
            End If
            If lignocaineNebuliser2pc.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@LignocaineNebuliser2pc", lignocaineNebuliser2pc))
            Else
                cmd.Parameters.Add(New SqlParameter("@LignocaineNebuliser2pc", SqlTypes.SqlDecimal.Null))
            End If
            If lignocaineNebuliser4pc.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@LignocaineNebuliser4pc", lignocaineNebuliser4pc))
            Else
                cmd.Parameters.Add(New SqlParameter("@LignocaineNebuliser4pc", SqlTypes.SqlDecimal.Null))
            End If
            If lignocaineTranscricoid2pc.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@LignocaineTranscricoid2pc", lignocaineTranscricoid2pc))
            Else
                cmd.Parameters.Add(New SqlParameter("@LignocaineTranscricoid2pc", SqlTypes.SqlDecimal.Null))
            End If
            If lignocaineTranscricoid4pc.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@LignocaineTranscricoid4pc", lignocaineTranscricoid4pc))
            Else
                cmd.Parameters.Add(New SqlParameter("@LignocaineTranscricoid4pc", SqlTypes.SqlDecimal.Null))
            End If
            If lignocaineBronchial1pc.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@LignocaineBronchial1pc", lignocaineBronchial1pc))
            Else
                cmd.Parameters.Add(New SqlParameter("@LignocaineBronchial1pc", SqlTypes.SqlDecimal.Null))
            End If
            If lignocaineBronchial2pc.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@LignocaineBronchial2pc", lignocaineBronchial2pc))
            Else
                cmd.Parameters.Add(New SqlParameter("@LignocaineBronchial2pc", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@SupplyOxygen", supplyOxygen))
            If supplyOxygenPercentage.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SupplyOxygenPercentage", supplyOxygenPercentage))
            Else
                cmd.Parameters.Add(New SqlParameter("@SupplyOxygenPercentage", SqlTypes.SqlDecimal.Null))
            End If
            If nasal.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@Nasal", nasal))
            Else
                cmd.Parameters.Add(New SqlParameter("@Nasal", SqlTypes.SqlDecimal.Null))
            End If
            If spO2Base.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SpO2Base", spO2Base))
            Else
                cmd.Parameters.Add(New SqlParameter("@SpO2Base", SqlTypes.SqlDecimal.Null))
            End If
            If spO2Min.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@SpO2Min", spO2Min))
            Else
                cmd.Parameters.Add(New SqlParameter("@SpO2Min", SqlTypes.SqlDecimal.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))
            cmd.Parameters.Add(New SqlParameter("@LignocaineSprayPercentage", lignocaineSprayPercentage))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Broncho Coding"

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetBronchoCoding(procedureId As Integer, section As BronchoCodeSection) As DataTable
        Dim dsCoding As New DataSet
        Dim query As New StringBuilder

        query.Append("SELECT l.*, ")
        query.Append("ISNULL(c.FibreOpticCodeValue, 0) AS FibreOpticCodeValue, ")
        query.Append("ISNULL(c.RigidCodeValue, 0) AS RigidCodeValue ")
        query.Append("FROM ERS_BRT_CodeList l  ")
        query.Append("LEFT JOIN ERS_BRT_BronchoCoding c ON l.CodeId = c.CodeId AND ProcedureId = @ProcedureId ")
        query.Append("WHERE l.Section = @Section ")

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(query.ToString, connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", CInt(procedureId)))
            cmd.Parameters.Add(New SqlParameter("@Section", CInt(section)))

            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsCoding)
        End Using

        If dsCoding.Tables.Count > 0 Then
            Return dsCoding.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveBronchoCoding(ByVal procedureId As Integer,
                                      ByVal codeId As Integer,
                                      ByVal checkboxStatus As Boolean?,
                                      ByVal checkboxType As String)
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)

            Dim cmd As SqlCommand = New SqlCommand("broncho_coding_save", connection)
            cmd.CommandType = System.Data.CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@CodeId", codeId))
            If checkboxStatus.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@checkboxStatus", checkboxStatus))
            Else
                cmd.Parameters.Add(New SqlParameter("@checkboxStatus", SqlTypes.SqlBoolean.Null))
            End If

            cmd.Parameters.Add(New SqlParameter("@checkboxType", checkboxType))
            'Else
            '    cmd.Parameters.Add(New SqlParameter("@RigidCodeValue", SqlTypes.SqlBoolean.Null))
            'End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

    Public Function getProcedureAddiotionalNotes(procedureId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("procedure_additional_notes_select", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function SaveProcedureAdditionalNotes(procedureId As Integer, additionalNotes As String)
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)

            Dim cmd As SqlCommand = New SqlCommand("procedure_additional_notes_save", connection)
            cmd.CommandType = System.Data.CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@AdditionalNotes", additionalNotes))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region

#Region "Broncho Pathology"
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetBronchoPathology(ByVal procedureId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("SELECT * FROM ERS_BRT_BronchoPathology WHERE ProcedureId = @ProcedureId", connection)
            cmd.CommandType = CommandType.Text
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveBronchoPathology(ByVal procedureId As Integer,
                                         ByVal asthmaThermoplasty As Boolean,
                                         ByVal emphysemaLungVolRed As Boolean,
                                         ByVal haemoptysis As Boolean,
                                         ByVal hilarMediaLymphadenopathy As Boolean,
                                         ByVal infection As Boolean,
                                         ByVal infectionImmunoSuppressed As Boolean,
                                         ByVal lungLobarCollapse As Boolean,
                                         ByVal radiologicalAbno As Boolean,
                                         ByVal suspectedLCa As Boolean,
                                         ByVal suspectedSarcoidosis As Boolean,
                                         ByVal suspectedTB As Boolean,
                                         ByVal clinicalDetails As String,
                                         ByVal atrialFibrillation As Boolean,
                                         ByVal chronicKidneyDisease As Boolean,
                                         ByVal copd As Boolean,
                                         ByVal enlargedLymphNodes As Boolean,
                                         ByVal essentialHyperTension As Boolean,
                                         ByVal heartFailure As Boolean,
                                         ByVal interstitialLungDisease As Boolean,
                                         ByVal ischaemicHeartDisease As Boolean,
                                         ByVal lungCancer As Boolean,
                                         ByVal obesity As Boolean,
                                         ByVal pleuralEffusion As Boolean,
                                         ByVal pneumonia As Boolean,
                                         ByVal rheumatoidArthritis As Boolean,
                                         ByVal secondaryCancer As Boolean,
                                         ByVal stroke As Boolean,
                                         ByVal type2Diabetes As Boolean,
                                         ByVal otherComorb As String,
                                         ByVal stagingInvestigations As Boolean,
                                         ByVal clinicalGrounds As Boolean,
                                         ByVal imagingOfThorax As Boolean,
                                         ByVal mediastinalSampling As Boolean,
                                         ByVal metastases As Boolean,
                                         ByVal pleuralHistology As Boolean,
                                         ByVal bronchoscopy As Boolean,
                                         ByVal stage As Boolean,
                                         ByVal stageT As Integer,
                                         ByVal stageN As Integer,
                                         ByVal stageM As Integer,
                                         ByVal stageType As Integer,
                                         ByVal stageDate As Nullable(Of DateTime),
                                         ByVal performanceStatus As Boolean,
                                         ByVal performanceStatusType As Nullable(Of Integer),
                                         ByVal dateBronchRequested As Nullable(Of DateTime),
                                         ByVal dateOfReferral As Nullable(Of DateTime),
                                         ByVal lCaSuspectedBySpecialist As Boolean,
                                         ByVal cTScanAvailable As Boolean,
                                         ByVal dateOfScan As Nullable(Of DateTime),
                                         ByVal fev1Result As Nullable(Of Decimal),
                                         ByVal fev1Percentage As Nullable(Of Decimal),
                                         ByVal fvcResult As Nullable(Of Decimal),
                                         ByVal fvcPercentage As Nullable(Of Decimal),
                                         ByVal whoPerformanceStatus As Nullable(Of Integer)) As Integer
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)

            Dim cmd As SqlCommand = New SqlCommand("broncho_pathology_save", connection)
            cmd.CommandType = System.Data.CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@AsthmaThermoplasty", asthmaThermoplasty))
            cmd.Parameters.Add(New SqlParameter("@EmphysemaLungVolRed", emphysemaLungVolRed))
            cmd.Parameters.Add(New SqlParameter("@Haemoptysis", haemoptysis))
            cmd.Parameters.Add(New SqlParameter("@HilarMediaLymphadenopathy", hilarMediaLymphadenopathy))
            cmd.Parameters.Add(New SqlParameter("@Infection", infection))
            cmd.Parameters.Add(New SqlParameter("@InfectionImmunoSuppressed", infectionImmunoSuppressed))
            cmd.Parameters.Add(New SqlParameter("@LungLobarCollapse", lungLobarCollapse))
            cmd.Parameters.Add(New SqlParameter("@RadiologicalAbno", radiologicalAbno))
            cmd.Parameters.Add(New SqlParameter("@SuspectedLCa", suspectedLCa))
            cmd.Parameters.Add(New SqlParameter("@SuspectedSarcoidosis", suspectedSarcoidosis))
            cmd.Parameters.Add(New SqlParameter("@SuspectedTB", suspectedTB))
            cmd.Parameters.Add(New SqlParameter("@ClinicalDetails", clinicalDetails))
            cmd.Parameters.Add(New SqlParameter("@AtrialFibrillation", atrialFibrillation))
            cmd.Parameters.Add(New SqlParameter("@ChronicKidneyDisease", chronicKidneyDisease))
            cmd.Parameters.Add(New SqlParameter("@COPD", copd))
            cmd.Parameters.Add(New SqlParameter("@EnlargedLymphNodes", enlargedLymphNodes))
            cmd.Parameters.Add(New SqlParameter("@EssentialHyperTension", essentialHyperTension))
            cmd.Parameters.Add(New SqlParameter("@HeartFailure", heartFailure))
            cmd.Parameters.Add(New SqlParameter("@InterstitialLungDisease", interstitialLungDisease))
            cmd.Parameters.Add(New SqlParameter("@IschaemicHeartDisease", ischaemicHeartDisease))
            cmd.Parameters.Add(New SqlParameter("@LungCancer", lungCancer))
            cmd.Parameters.Add(New SqlParameter("@Obesity", obesity))
            cmd.Parameters.Add(New SqlParameter("@PleuralEffusion", pleuralEffusion))
            cmd.Parameters.Add(New SqlParameter("@Pneumonia", pneumonia))
            cmd.Parameters.Add(New SqlParameter("@RheumatoidArthritis", rheumatoidArthritis))
            cmd.Parameters.Add(New SqlParameter("@SecondaryCancer", secondaryCancer))
            cmd.Parameters.Add(New SqlParameter("@Stroke", stroke))
            cmd.Parameters.Add(New SqlParameter("@Type2Diabetes", type2Diabetes))
            cmd.Parameters.Add(New SqlParameter("@OtherComorb", otherComorb))
            cmd.Parameters.Add(New SqlParameter("@StagingInvestigations", stagingInvestigations))
            cmd.Parameters.Add(New SqlParameter("@ClinicalGrounds", clinicalGrounds))
            cmd.Parameters.Add(New SqlParameter("@ImagingOfThorax", imagingOfThorax))
            cmd.Parameters.Add(New SqlParameter("@MediastinalSampling", mediastinalSampling))
            cmd.Parameters.Add(New SqlParameter("@Metastases", metastases))
            cmd.Parameters.Add(New SqlParameter("@PleuralHistology", pleuralHistology))
            cmd.Parameters.Add(New SqlParameter("@Bronchoscopy", bronchoscopy))
            cmd.Parameters.Add(New SqlParameter("@Stage", stage))
            cmd.Parameters.Add(New SqlParameter("@StageT", stageT))
            cmd.Parameters.Add(New SqlParameter("@StageN", stageN))
            cmd.Parameters.Add(New SqlParameter("@StageM", stageM))
            cmd.Parameters.Add(New SqlParameter("@StageType", stageType))
            If stageDate.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@StageDate", stageDate))
            Else
                cmd.Parameters.Add(New SqlParameter("@StageDate", SqlTypes.SqlDateTime.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@PerformanceStatus", performanceStatus))
            If performanceStatusType.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PerformanceStatusType", performanceStatusType))
            Else
                cmd.Parameters.Add(New SqlParameter("@PerformanceStatusType", SqlTypes.SqlInt32.Null))
            End If
            If dateBronchRequested.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DateBronchRequested", dateBronchRequested))
            Else
                cmd.Parameters.Add(New SqlParameter("@DateBronchRequested", SqlTypes.SqlDateTime.Null))
            End If
            If dateOfReferral.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DateOfReferral", dateOfReferral))
            Else
                cmd.Parameters.Add(New SqlParameter("@DateOfReferral", SqlTypes.SqlDateTime.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LCaSuspectedBySpecialist", lCaSuspectedBySpecialist))
            cmd.Parameters.Add(New SqlParameter("@CTScanAvailable", cTScanAvailable))
            If dateOfScan.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@DateOfScan", dateOfScan))
            Else
                cmd.Parameters.Add(New SqlParameter("@DateOfScan", SqlTypes.SqlDateTime.Null))
            End If
            If fev1Result.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@FEV1Result", fev1Result))
            Else
                cmd.Parameters.Add(New SqlParameter("@FEV1Result", SqlTypes.SqlDecimal.Null))
            End If
            If fev1Percentage.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@FEV1Percentage", fev1Percentage))
            Else
                cmd.Parameters.Add(New SqlParameter("@FEV1Percentage", SqlTypes.SqlDecimal.Null))
            End If
            If fvcResult.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@FVCResult", fvcResult))
            Else
                cmd.Parameters.Add(New SqlParameter("@FVCResult", SqlTypes.SqlDecimal.Null))
            End If
            If fvcPercentage.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@FVCPercentage", fvcPercentage))
            Else
                cmd.Parameters.Add(New SqlParameter("@FVCPercentage", SqlTypes.SqlDecimal.Null))
            End If
            If whoPerformanceStatus.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@WHOPerformanceStatus", whoPerformanceStatus))
            Else
                cmd.Parameters.Add(New SqlParameter("@WHOPerformanceStatus", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select, False)>
    Public Function GetBroncoStaging(ByVal procedureId As Integer) As DataTable
        Dim dsResult As New DataSet

        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("procedure_staging_select", connection)
            cmd.CommandType = System.Data.CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))

            Dim adapter = New SqlDataAdapter(cmd)

            connection.Open()
            adapter.Fill(dsResult)
        End Using

        If dsResult.Tables.Count > 0 Then
            Return dsResult.Tables(0)
        End If
        Return Nothing
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Update, False)>
    Public Function SaveBroncoStaging(ByVal procedureId As Integer,
                                      ByVal stagingInvestigations As Boolean,
                                      ByVal clinicalGrounds As Boolean,
                                      ByVal imagingOfThorax As Boolean,
                                      ByVal pleuralHistology As Boolean,
                                      ByVal mediastinalSampling As Boolean,
                                      ByVal metastases As Boolean,
                                      ByVal bronchoscopy As Boolean,
                                      ByVal stage As Boolean,
                                      ByVal stageT As Nullable(Of Integer),
                                      ByVal stageN As Nullable(Of Integer),
                                      ByVal stageM As Nullable(Of Integer),
                                      ByVal stageLocation As Nullable(Of Integer),
                                      ByVal performanceStatus As Boolean,
                                      ByVal performanceStatusType As Nullable(Of Integer))
        Dim rowsAffected As Integer

        Using connection As New SqlConnection(DataAccess.ConnectionStr)

            Dim cmd As SqlCommand = New SqlCommand("procedure_staging_save", connection)
            cmd.CommandType = System.Data.CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@ProcedureId", procedureId))
            cmd.Parameters.Add(New SqlParameter("@StagingInvestigations", stagingInvestigations))
            cmd.Parameters.Add(New SqlParameter("@ClinicalGrounds", clinicalGrounds))
            cmd.Parameters.Add(New SqlParameter("@ImagingOfThorax", imagingOfThorax))
            cmd.Parameters.Add(New SqlParameter("@MediastinalSampling", mediastinalSampling))
            cmd.Parameters.Add(New SqlParameter("@Metastases", metastases))
            cmd.Parameters.Add(New SqlParameter("@PleuralHistology", pleuralHistology))
            cmd.Parameters.Add(New SqlParameter("@Bronchoscopy", bronchoscopy))
            cmd.Parameters.Add(New SqlParameter("@Stage", stage))
            If stageT.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@StageT", stageT))
            Else
                cmd.Parameters.Add(New SqlParameter("@StageT", 0))
            End If
            If stageN.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@stageN", stageN))
            Else
                cmd.Parameters.Add(New SqlParameter("@stageN", 0))
            End If
            If stageM.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@stageM", stageM))
            Else
                cmd.Parameters.Add(New SqlParameter("@stageM", 0))
            End If
            ' Added by Ferdowsi
            If stageLocation.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@StageLocation", stageLocation))
            Else
                cmd.Parameters.Add(New SqlParameter("@StageLocation", 0))
            End If

            cmd.Parameters.Add(New SqlParameter("@PerformanceStatus", performanceStatus))
            If performanceStatusType.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@PerformanceStatusType", performanceStatusType))
            Else
                cmd.Parameters.Add(New SqlParameter("@PerformanceStatusType", SqlTypes.SqlInt32.Null))
            End If
            cmd.Parameters.Add(New SqlParameter("@Suppressed", 0))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", CInt(HttpContext.Current.Session("PKUserID"))))

            cmd.Connection.Open()
            rowsAffected = CInt(cmd.ExecuteNonQuery())
        End Using

        Return rowsAffected
    End Function
#End Region
#Region "PreAssessment"
    Public Sub SavePreAssessmentAnswers(preAssessmentId As Integer, questionId As Integer, answerId As Integer?, optionAnswer As Integer?, freeTextAnswer As String, dropdownAnswer As String)
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("Pre_Assessment_Answers_Save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@PreAssessmentId", preAssessmentId))
            cmd.Parameters.Add(New SqlParameter("@QuestionId", questionId))

            If optionAnswer.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@OptionAnswer", optionAnswer))
            End If

            If Not String.IsNullOrWhiteSpace(freeTextAnswer) Then
                cmd.Parameters.Add(New SqlParameter("@FreeTextAnswer", freeTextAnswer))
            End If

            If Not String.IsNullOrWhiteSpace(dropdownAnswer) Then
                cmd.Parameters.Add(New SqlParameter("@DropdownAnswer", dropdownAnswer))
            End If

            If answerId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@AnswerId", answerId))
            Else
                cmd.Parameters.Add(New SqlParameter("@AnswerId", DBNull.Value))
            End If

            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub
    Public Function SavePreAssessment(procedureType As String, preAssessmentId As Integer, PatinetId As Integer, IsComplete As Boolean, preDate As DateTime) As Integer
        Dim newId As Integer
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("ERS_PreAssessment_Save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@PreAssessmentId", preAssessmentId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureType))
            cmd.Parameters.Add(New SqlParameter("@PatientId", PatinetId))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@IsComplete", IsComplete))
            cmd.Parameters.Add(New SqlParameter("@PreAssessmentDate", preDate))
            cmd.Connection.Open()
            newId = Convert.ToInt32(cmd.ExecuteScalar())
        End Using
        Return newId
    End Function
#End Region

    Friend Function PrintCopiesDefault() As DataTable
        Dim dsData As New DataSet
        Dim sb As StringBuilder = New StringBuilder()
        sb.Append("SELECT gp.DefaultNumberOfCopies as gpCopies, gp.DefaultNumberOfPhotos as PhotosCopies, lab.DefaultNumberOfCopies as LabCopies, ")
        sb.Append("pat.DefaultNumberOfCopies as PatientCopies, DefaultPrintImageOnGp as ImagesOnGPReport FROM ERS_PrintOptionsGPReport gp, ERS_PrintOptionsLabRequestReport lab, ")
        sb.Append("ERS_PrintOptionsPatientFriendlyReport pat where gp.OperatingHospitalID = @OperatingHospitalID ")
        sb.Append("and lab.OperatingHospitalID = @OperatingHospitalID and pat.OperatingHospitalID = @OperatingHospitalID ")
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sb.ToString(), connection)
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", CInt(HttpContext.Current.Session("OperatingHospitalId"))))
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function

    Friend Function ImageSizeDefault() As DataTable
        Dim dsData As New DataSet
        Dim sb As StringBuilder = New StringBuilder()
        sb.Append("SELECT DefaultPhotoSize FROM ERS_PrintOptionsGPReport where OperatingHospitalID = @OperatingHospitalID ")
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand(sb.ToString(), connection)
            cmd.Parameters.Add(New SqlParameter("@OperatingHospitalID", CInt(HttpContext.Current.Session("OperatingHospitalId"))))
            cmd.CommandType = CommandType.Text
            Dim adapter = New SqlDataAdapter(cmd)
            connection.Open()
            adapter.Fill(dsData)
        End Using
        If dsData.Tables.Count > 0 Then
            Return dsData.Tables(0)
        End If
        Return Nothing
    End Function
    Public Function CheckRequiredQuestions(ByVal PreAssessmentId As Integer) As String
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ValidateMandatoryQuestions", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@PreAssessmentId", PreAssessmentId))

            connection.Open()
            Dim r As Object = cmd.ExecuteScalar
            If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                Return CStr(r)
            Else
                Return ""
            End If
        End Using
    End Function
    Public Function DeletePreAssessmentAndComorbidity(ByVal PreAssessmentId As Integer) As String
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("Remove_PreAssessment_And_Comorbidity", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@preAssessmentId", PreAssessmentId))
            connection.Open()
            Dim r As Object = cmd.ExecuteNonQuery
            If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                Return CStr(r)
            Else
                Return ""
            End If
        End Using
    End Function
#Region "Nurse Module"
    Public Function SaveNurseModule(procedureType As String, nurseModuleId As Integer, PatinetId As Integer, ProcedureDate As DateTime, isComplete As Boolean) As Integer
        Dim newId As Integer
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("ERS_NurseModuleProcedure_Save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@NurseModuleId", nurseModuleId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureType", procedureType))
            cmd.Parameters.Add(New SqlParameter("@PatientId", PatinetId))
            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))
            cmd.Parameters.Add(New SqlParameter("@ProcedureDate", ProcedureDate))
            cmd.Parameters.Add(New SqlParameter("@IsComplete", isComplete))
            cmd.Connection.Open()
            newId = Convert.ToInt32(cmd.ExecuteScalar())
        End Using
        Return newId
    End Function
    Public Sub SaveNurseModuleAnswers(nurseModuleId As Integer, questionId As Integer, answerId As Integer?, optionAnswer As Integer?, freeTextAnswer As String, dropdownAnswer As String)
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As SqlCommand = New SqlCommand("Nurse_Module_Answers_Save", connection)
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Parameters.Add(New SqlParameter("@NurseModuleId", nurseModuleId))
            cmd.Parameters.Add(New SqlParameter("@QuestionId", questionId))

            If optionAnswer.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@OptionAnswer", optionAnswer))
            End If

            If Not String.IsNullOrWhiteSpace(freeTextAnswer) Then
                cmd.Parameters.Add(New SqlParameter("@FreeTextAnswer", freeTextAnswer))
            End If

            If Not String.IsNullOrWhiteSpace(dropdownAnswer) Then
                cmd.Parameters.Add(New SqlParameter("@DropdownAnswer", dropdownAnswer))
            End If

            If answerId.HasValue Then
                cmd.Parameters.Add(New SqlParameter("@AnswerId", answerId))
            Else
                cmd.Parameters.Add(New SqlParameter("@AnswerId", DBNull.Value))
            End If

            cmd.Parameters.Add(New SqlParameter("@LoggedInUserId", LoggedInUserId))

            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
        End Using
    End Sub
    Public Function CheckNurseModuleRequiredQuestions(ByVal NurseModuleId As Integer) As String
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("ValidateNurseModuleMandatoryQuestions", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@NurseModuleId", NurseModuleId))

            connection.Open()
            Dim r As Object = cmd.ExecuteScalar
            If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                Return CStr(r)
            Else
                Return ""
            End If
        End Using
    End Function
    Public Function DeleteNurseModule(ByVal nurseModuleId As Integer) As String
        Using connection As New SqlConnection(DataAccess.ConnectionStr)
            Dim cmd As New SqlCommand("Delete_Nurse_Module", connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.Add(New SqlParameter("@nurseModuleId", nurseModuleId))
            connection.Open()
            Dim r As Object = cmd.ExecuteNonQuery
            If Not IsDBNull(r) AndAlso Not IsNothing(r) Then
                Return CInt(r)
            Else
                Return ""
            End If
        End Using
    End Function
#End Region
End Class
