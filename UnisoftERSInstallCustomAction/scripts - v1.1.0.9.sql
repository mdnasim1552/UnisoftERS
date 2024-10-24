
/*******************************************************
**  Cancellation Reasons - Setup table & Audit table  **
*******************************************************/


IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'CancelledByHospital' AND Object_ID = Object_ID(N'ERS_CancelReasons'))
  alter table ERS_CancelReasons add Active bit default 1 NOT NULL,
									CancelledByHospital bit default 0 NOT NULL 
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'CancelledByHospital' AND Object_ID = Object_ID(N'ERSAudit.ERS_CancelReasons_Audit'))
  alter table [ERSAudit].[ERS_CancelReasons_Audit] add Active bit,
									CancelledByHospital bit
GO
  
  Exec DropIfExist 'trg_ERS_CancelReasons_Delete', 'TR'
  GO
  Create TRIGGER [dbo].[trg_ERS_CancelReasons_Delete] 
							ON [dbo].[ERS_CancelReasons] 
							AFTER DELETE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_CancelReasons_Audit] (CancelReasonId, tbl.[Code], tbl.[CancelCodeId], tbl.[Detail], tbl.[SortOrder],  LastActionId, ActionDateTime, ActionUserId, Active, CancelledByHospital)
							SELECT tbl.CancelReasonId , tbl.[Code], tbl.[CancelCodeId], tbl.[Detail], tbl.[SortOrder],  3, GETDATE(), tbl.WhoUpdatedId, tbl.Active, tbl.CancelledByHospital
							FROM deleted tbl
GO

  Exec DropIfExist 'trg_ERS_CancelReasons_Insert', 'TR'
  GO
  Create TRIGGER [dbo].[trg_ERS_CancelReasons_Insert] 
							ON [dbo].[ERS_CancelReasons] 
							AFTER INSERT
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_CancelReasons_Audit] (CancelReasonId, tbl.[Code], tbl.[CancelCodeId], tbl.[Detail], tbl.[SortOrder],  LastActionId, ActionDateTime, ActionUserId, Active, CancelledByHospital)
							SELECT tbl.CancelReasonId , tbl.[Code], tbl.[CancelCodeId], tbl.[Detail], tbl.[SortOrder],  1, GETDATE(), tbl.WhoCreatedId, tbl.Active, tbl.CancelledByHospital
							FROM inserted tbl
GO

Exec DropIfExist 'trg_ERS_CancelReasons_Update', 'TR'
  GO
  Create TRIGGER [dbo].[trg_ERS_CancelReasons_Update] 
							ON [dbo].[ERS_CancelReasons] 
							AFTER UPDATE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_CancelReasons_Audit] (CancelReasonId, tbl.[Code], tbl.[CancelCodeId], tbl.[Detail], tbl.[SortOrder],  LastActionId, ActionDateTime, ActionUserId, Active, CancelledByHospital)
							SELECT tbl.CancelReasonId , tbl.[Code], tbl.[CancelCodeId], tbl.[Detail], tbl.[SortOrder],  2, GETDATE(), i.WhoUpdatedId, tbl.Active, tbl.CancelledByHospital
							FROM deleted tbl INNER JOIN inserted i ON tbl.CancelReasonId = i.CancelReasonId
GO


EXEC DropIfExist 'sch_cancellationReasons_select', 'S'
GO

CREATE PROCEDURE [dbo].[sch_cancellationReasons_select]
AS
SET NOCOUNT ON
	SELECT CancelReasonId, Code, Detail, ISNULL(CancelledByHospital, 0) AS CancelledByHospital, Active, WhoUpdatedId, WhoCreatedId, WhenCreated, WhenUpdated
	FROM ERS_CancelReasons
	Order By CancelReasonId asc


GO



EXEC DropIfExist 'sch_CancellationReasons_insert_update', 'S'
GO

CREATE PROCEDURE [dbo].[sch_CancellationReasons_insert_update](
	@CancelReasonId int,
	@Code VARCHAR(30),
	@Detail varChar(50),
	@CancelledByHospital bit,
	@Active bit,
	@UserId Int
)

AS 
	SET NOCOUNT ON
	BEGIN TRANSACTION
	BEGIN TRY
		IF Exists (SELECT CancelReasonId FROM ERS_CancelReasons WHERE CancelReasonId = @CancelReasonId)
		BEGIN
			--exists so Update with new values
			UPDATE ERS_CancelReasons
			SET Code = @Code,
				Detail = @Detail,
				CancelledByHospital = @CancelledByHospital,
				Active = @Active,
				WhoUpdatedId = @UserId,
				WhenUpdated = GetDate()
			WHERE CancelReasonId = @CancelReasonId 
		END
		ELSE
		BEGIN
			INSERT ERS_CancelReasons(
				Code,
				CancelCodeId,
				Detail,
				CancelledByHospital,
				Active,
				WhoCreatedId,
				WhenCreated,
				WhoUpdatedId,
				WhenUpdated)
			VALUES (@Code,
					1,
					@Detail,
					@CancelledByHospital,
					@Active,
					@UserId,
					GetDate(),
					@UserId,
					GetDate())
		END
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
    
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	END CATCH
	IF @@TRANCOUNT > 0 COMMIT TRANSACTION;


GO



-----------------------------------------------------------------------------------------------------------
IF not exists(Select 1 from ERS_MenuMap where NodeName = 'Cancellation Reasons')
BEGIN
	IF NOT EXISTS (SELECT * FROM ERS_Pages WHERE Pageid=270)
	BEGIN
		insert into ERS_Pages
			(PageId, PageName, PageAlias, AppPageName, GroupId, PageURL)
		Values (270, 'CancellationReasons', 'Cancellation Reasons', 'products_options_scheduler_cancellationreasons_aspx', 9, '~/Products/Options/Scheduler/CancellationReasons.aspx')
	END

	Insert into ERS_MenuMap
		(ParentID, NodeName, MenuCategory, MenuUrl, isViewer, isDemoVersion, PageID)
	Values ((Select MapId from ERS_MenuMap where NodeName = 'Scheduler Setup' AND parentid IS NULL), 'Cancellation Reasons', 'Configure', '~/Products/Options/Scheduler/CancellationReasons.aspx', 1, 0, 270)

	Insert into ERS_PagesByRole (RoleId, PageId, AccessLevel)
	Select RoleId, 270, 9 from ERS_Roles where RoleName = 'System Administrators'

	Insert into ERS_PagesByRole (RoleId, PageId, AccessLevel)
	Select RoleId, 270, 9 from ERS_Roles where RoleName = 'Unisoft'
END
Go

EXEC DropIfExist 'sch_cancellationReasons_select','S';
GO
CREATE PROCEDURE [dbo].[sch_cancellationReasons_select]
AS
SET NOCOUNT ON
	SELECT CancelReasonId, Code, Detail, ISNULL(CancelledByHospital, 0) AS CancelledByHospital, Active, WhoUpdatedId, WhoCreatedId, WhenCreated, WhenUpdated
	FROM ERS_CancelReasons
	Order By CancelReasonId asc
GO
EXEC DropIfExist 'sch_CancellationReasons_insert_update','S';
GO
CREATE PROCEDURE [dbo].[sch_CancellationReasons_insert_update](
	@CancelReasonId int,
	@Code VARCHAR(30),
	@Detail varChar(50),
	@CancelledByHospital bit,
	@Active bit,
	@UserId Int
)

AS 
	SET NOCOUNT ON
	BEGIN TRANSACTION
	BEGIN TRY
		IF Exists (SELECT CancelReasonId FROM ERS_CancelReasons WHERE CancelReasonId = @CancelReasonId)
		BEGIN
			--exists so Update with new values
			UPDATE ERS_CancelReasons
			SET Code = @Code,
				Detail = @Detail,
				CancelledByHospital = @CancelledByHospital,
				Active = @Active,
				WhoUpdatedId = @UserId,
				WhenUpdated = GetDate()
			WHERE CancelReasonId = @CancelReasonId 
		END
		ELSE
		BEGIN
			INSERT ERS_CancelReasons(
				Code,
				CancelCodeId,
				Detail,
				CancelledByHospital,
				Active,
				WhoCreatedId,
				WhenCreated,
				WhoUpdatedId,
				WhenUpdated)
			VALUES (@Code,
					1,
					@Detail,
					@CancelledByHospital,
					@Active,
					@UserId,
					GetDate(),
					@UserId,
					GetDate())
		END
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
    
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	END CATCH
	IF @@TRANCOUNT > 0 COMMIT TRANSACTION;
GO
-----------------------------------------------------------------------------------------------------------
-- Bug 211 Take Defaecation Disorder out of the dropdown list in Colon indications and make it its own checkbox


IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ColonDefaecationDisorder' AND Object_ID = Object_ID(N'ERS_UpperGIIndications'))
  alter table ERS_UpperGIIndications add ColonDefaecationDisorder bit default 0 NOT NULL
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ColonDefaecationDisorder' AND Object_ID = Object_ID(N'ERSAudit.ERS_UpperGIIndications_Audit'))
  alter table [ERSAudit].ERS_UpperGIIndications_Audit add ColonDefaecationDisorder bit default 0 NOT NULL
GO

  Exec DropIfExist 'trg_ERS_UpperGIIndications_Delete', 'TR'
  GO
  Create TRIGGER [dbo].[trg_ERS_UpperGIIndications_Delete] 
							ON [dbo].[ERS_UpperGIIndications] 
							AFTER DELETE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_UpperGIIndications_Audit] (IndicationId, tbl.[ProcedureId], tbl.[Anaemia], tbl.[AnaemiaType], tbl.[AbdominalPain], tbl.[AbnormalCapsuleStudy], tbl.[AbnormalMRI], tbl.[AbnormalityOnBarium], tbl.[ChestPain], tbl.[ChronicLiverDisease], tbl.[CoffeeGroundsVomit], tbl.[Diarrhoea], tbl.[DrugTrial], tbl.[Dyspepsia], tbl.[DyspepsiaAtypical], tbl.[DyspepsiaUlcerType], tbl.[Dysphagia], tbl.[Haematemesis], tbl.[Melaena], tbl.[NauseaAndOrVomiting], tbl.[Odynophagia], tbl.[PositiveTTG_EMA], tbl.[RefluxSymptoms], tbl.[UlcerExclusion], tbl.[WeightLoss], tbl.[PreviousHPyloriTest], tbl.[SerologyTest], tbl.[SerologyTestResult], tbl.[BreathTest], tbl.[BreathTestResult], tbl.[UreaseTest], tbl.[UreaseTestResult], tbl.[StoolAntigenTest], tbl.[StoolAntigenTestResult], tbl.[OpenAccess], tbl.[OtherIndication], tbl.[ClinicallyImpComments], tbl.[UrgentTwoWeekReferral], tbl.[Cancer], tbl.[WHOStatus], tbl.[BariatricPreAssessment], tbl.[BalloonInsertion], tbl.[BalloonRemoval], tbl.[SingleBalloonEnteroscopy], tbl.[DoubleBalloonEnteroscopy], tbl.[PostBariatricSurgeryAssessment], tbl.[EUS], tbl.[GastrostomyInsertion], tbl.[InsertionOfPHProbe], tbl.[JejunostomyInsertion], tbl.[NasoDuodenalTube], tbl.[OesophagealDilatation], tbl.[PEGRemoval], tbl.[PEGReplacement], tbl.[PushEnteroscopy], tbl.[SmallBowelBiopsy], tbl.[StentRemoval], tbl.[StentInsertion], tbl.[StentReplacement], tbl.[EUSRefGuidedFNABiopsy], tbl.[EUSOesophagealStricture], tbl.[EUSAssessmentOfSubmucosalLesion], tbl.[EUSTumourStagingOesophageal], tbl.[EUSTumourStagingGastric], tbl.[EUSTumourStagingDuodenal], tbl.[OtherPlannedProcedure], tbl.[CoMorbidityNone], tbl.[Angina], tbl.[Asthma], tbl.[COPD], tbl.[DiabetesMellitus], tbl.[DiabetesMellitusType], tbl.[Epilepsy], tbl.[HemiPostStroke], tbl.[Hypertension], tbl.[MI], tbl.[Obesity], tbl.[TIA], tbl.[OtherCoMorbidity], tbl.[ASAStatus], tbl.[PotentiallyDamagingDrug], tbl.[Allergy], tbl.[AllergyDesc], tbl.[CurrentMedication], tbl.[IncludeCurrentRxInReport], tbl.[SurgeryFollowUpProc], tbl.[SurgeryFollowUpProcPeriod], tbl.[SurgeryFollowUpText], tbl.[DiseaseFollowUpProc], tbl.[DiseaseFollowUpProcPeriod], tbl.[BarrettsOesophagus], tbl.[CoeliacDisease], tbl.[Dysplasia], tbl.[Gastritis], tbl.[Malignancy], tbl.[OesophagealDilatationFollowUp], tbl.[OesophagealVarices], tbl.[Oesophagitis], tbl.[UlcerHealing], tbl.[ColonSreeningColonoscopy], tbl.[ColonBowelCancerScreening], tbl.[ColonFOBT], tbl.[ColonAlterBowelHabit], tbl.[ColonRectalBleeding], tbl.[ColonAnaemia], tbl.[ColonAnaemiaType], tbl.[ColonAbnormalCTScan], tbl.[ColonAbnormalSigmoidoscopy], tbl.[ColonAbnormalBariumEnema], tbl.[ColonAbdominalMass], tbl.[ColonColonicObstruction], tbl.[ColonAbdominalPain], tbl.[ColonAssessment], tbl.[ColonAssessmentType], tbl.[ColonSurveillance], tbl.[ColonFamily], tbl.[ColonFamilyType], tbl.[ColonFamilyAdditionalText], tbl.[ColonCarcinoma], tbl.[ColonPolyps], tbl.[ColonDysplasia], tbl.[ColonMelaena], tbl.[ColonPolyposisSyndrome], tbl.[ColonRaisedFaecalCalprotectin], tbl.[ColonTumourAssessment], tbl.[ColonWeightLoss], tbl.[ERSAbdominalPain], tbl.[ERSChronicPancreatisis], tbl.[ERSSphincter], tbl.[ERSAbnormalEnzymes], tbl.[ERSJaundice], tbl.[ERSStentOcclusion], tbl.[ERSAcutePancreatitisAcute], tbl.[ERSObstructedCBD], tbl.[ERSSuspectedPapillary], tbl.[ERSBiliaryLeak], tbl.[ERSOpenAccess], tbl.[ERSCholangitis], tbl.[ERSPrelaparoscopic], tbl.[ERSRecurrentPancreatitis], tbl.[ERSBileDuctInjury], tbl.[ERSPurulentCholangitis], tbl.[ERSPancreaticPseudocyst], tbl.[ERSPancreatobiliaryPain], tbl.[ERSPapillaryDysfunction], tbl.[ERSPriSclerosingChol], tbl.[ERSImgUltrasound], tbl.[ERSImgCT], tbl.[ERSImgMRI], tbl.[ERSImgMRCP], tbl.[ERSImgIDA], tbl.[ERSImgEUS], tbl.[ERSNormal], tbl.[ERSChronicPancreatitis], tbl.[ERSAcutePancreatitis], tbl.[ERSGallBladder], tbl.[ERSFluidCollection], tbl.[ERSPancreaticMass], tbl.[ERSDilatedPancreatic], tbl.[ERSStonedBiliary], tbl.[ERSHepaticMass], tbl.[ERSObstructed], tbl.[ERSDilatedDucts], tbl.[AmpullaryMass], tbl.[BiliaryLeak], tbl.[GallBladderMass], tbl.[GallBladderPolyp], tbl.[ERSDilatedDuctsType1], tbl.[ERSDilatedDuctsType2], tbl.[ERSImgOthersTextBox], tbl.[EPlanCanunulate], tbl.[EplanManometry], tbl.[EplanStentremoval], tbl.[EplanCombinedProcedure], tbl.[EplanNasoPancreatic], tbl.[EplanStentReplacement], tbl.[EPlanEndoscopicCyst], tbl.[EplanPapillotomy], tbl.[EplanStoneRemoval], tbl.[EplanStentInsertion], tbl.[EplanStrictureDilatation], tbl.[EplanOthersTextBox], tbl.[ERSFollowPrevious], tbl.[ERSFollowCarriedOut], tbl.[ERSFollowBileDuct], tbl.[ERSFollowMalignancy], tbl.[ERSFollowBiliaryStricture], tbl.[ERSFollowStentReplacement], tbl.[PolypTumourAssess], tbl.[EMR], tbl.[EUSProcType], tbl.[Summary],  LastActionId, ActionDateTime, ActionUserId, ColonDefaecationDisorder)
							SELECT tbl.IndicationId , tbl.[ProcedureId], tbl.[Anaemia], tbl.[AnaemiaType], tbl.[AbdominalPain], tbl.[AbnormalCapsuleStudy], tbl.[AbnormalMRI], tbl.[AbnormalityOnBarium], tbl.[ChestPain], tbl.[ChronicLiverDisease], tbl.[CoffeeGroundsVomit], tbl.[Diarrhoea], tbl.[DrugTrial], tbl.[Dyspepsia], tbl.[DyspepsiaAtypical], tbl.[DyspepsiaUlcerType], tbl.[Dysphagia], tbl.[Haematemesis], tbl.[Melaena], tbl.[NauseaAndOrVomiting], tbl.[Odynophagia], tbl.[PositiveTTG_EMA], tbl.[RefluxSymptoms], tbl.[UlcerExclusion], tbl.[WeightLoss], tbl.[PreviousHPyloriTest], tbl.[SerologyTest], tbl.[SerologyTestResult], tbl.[BreathTest], tbl.[BreathTestResult], tbl.[UreaseTest], tbl.[UreaseTestResult], tbl.[StoolAntigenTest], tbl.[StoolAntigenTestResult], tbl.[OpenAccess], tbl.[OtherIndication], tbl.[ClinicallyImpComments], tbl.[UrgentTwoWeekReferral], tbl.[Cancer], tbl.[WHOStatus], tbl.[BariatricPreAssessment], tbl.[BalloonInsertion], tbl.[BalloonRemoval], tbl.[SingleBalloonEnteroscopy], tbl.[DoubleBalloonEnteroscopy], tbl.[PostBariatricSurgeryAssessment], tbl.[EUS], tbl.[GastrostomyInsertion], tbl.[InsertionOfPHProbe], tbl.[JejunostomyInsertion], tbl.[NasoDuodenalTube], tbl.[OesophagealDilatation], tbl.[PEGRemoval], tbl.[PEGReplacement], tbl.[PushEnteroscopy], tbl.[SmallBowelBiopsy], tbl.[StentRemoval], tbl.[StentInsertion], tbl.[StentReplacement], tbl.[EUSRefGuidedFNABiopsy], tbl.[EUSOesophagealStricture], tbl.[EUSAssessmentOfSubmucosalLesion], tbl.[EUSTumourStagingOesophageal], tbl.[EUSTumourStagingGastric], tbl.[EUSTumourStagingDuodenal], tbl.[OtherPlannedProcedure], tbl.[CoMorbidityNone], tbl.[Angina], tbl.[Asthma], tbl.[COPD], tbl.[DiabetesMellitus], tbl.[DiabetesMellitusType], tbl.[Epilepsy], tbl.[HemiPostStroke], tbl.[Hypertension], tbl.[MI], tbl.[Obesity], tbl.[TIA], tbl.[OtherCoMorbidity], tbl.[ASAStatus], tbl.[PotentiallyDamagingDrug], tbl.[Allergy], tbl.[AllergyDesc], tbl.[CurrentMedication], tbl.[IncludeCurrentRxInReport], tbl.[SurgeryFollowUpProc], tbl.[SurgeryFollowUpProcPeriod], tbl.[SurgeryFollowUpText], tbl.[DiseaseFollowUpProc], tbl.[DiseaseFollowUpProcPeriod], tbl.[BarrettsOesophagus], tbl.[CoeliacDisease], tbl.[Dysplasia], tbl.[Gastritis], tbl.[Malignancy], tbl.[OesophagealDilatationFollowUp], tbl.[OesophagealVarices], tbl.[Oesophagitis], tbl.[UlcerHealing], tbl.[ColonSreeningColonoscopy], tbl.[ColonBowelCancerScreening], tbl.[ColonFOBT], tbl.[ColonAlterBowelHabit], tbl.[ColonRectalBleeding], tbl.[ColonAnaemia], tbl.[ColonAnaemiaType], tbl.[ColonAbnormalCTScan], tbl.[ColonAbnormalSigmoidoscopy], tbl.[ColonAbnormalBariumEnema], tbl.[ColonAbdominalMass], tbl.[ColonColonicObstruction], tbl.[ColonAbdominalPain], tbl.[ColonAssessment], tbl.[ColonAssessmentType], tbl.[ColonSurveillance], tbl.[ColonFamily], tbl.[ColonFamilyType], tbl.[ColonFamilyAdditionalText], tbl.[ColonCarcinoma], tbl.[ColonPolyps], tbl.[ColonDysplasia], tbl.[ColonMelaena], tbl.[ColonPolyposisSyndrome], tbl.[ColonRaisedFaecalCalprotectin], tbl.[ColonTumourAssessment], tbl.[ColonWeightLoss], tbl.[ERSAbdominalPain], tbl.[ERSChronicPancreatisis], tbl.[ERSSphincter], tbl.[ERSAbnormalEnzymes], tbl.[ERSJaundice], tbl.[ERSStentOcclusion], tbl.[ERSAcutePancreatitisAcute], tbl.[ERSObstructedCBD], tbl.[ERSSuspectedPapillary], tbl.[ERSBiliaryLeak], tbl.[ERSOpenAccess], tbl.[ERSCholangitis], tbl.[ERSPrelaparoscopic], tbl.[ERSRecurrentPancreatitis], tbl.[ERSBileDuctInjury], tbl.[ERSPurulentCholangitis], tbl.[ERSPancreaticPseudocyst], tbl.[ERSPancreatobiliaryPain], tbl.[ERSPapillaryDysfunction], tbl.[ERSPriSclerosingChol], tbl.[ERSImgUltrasound], tbl.[ERSImgCT], tbl.[ERSImgMRI], tbl.[ERSImgMRCP], tbl.[ERSImgIDA], tbl.[ERSImgEUS], tbl.[ERSNormal], tbl.[ERSChronicPancreatitis], tbl.[ERSAcutePancreatitis], tbl.[ERSGallBladder], tbl.[ERSFluidCollection], tbl.[ERSPancreaticMass], tbl.[ERSDilatedPancreatic], tbl.[ERSStonedBiliary], tbl.[ERSHepaticMass], tbl.[ERSObstructed], tbl.[ERSDilatedDucts], tbl.[AmpullaryMass], tbl.[BiliaryLeak], tbl.[GallBladderMass], tbl.[GallBladderPolyp], tbl.[ERSDilatedDuctsType1], tbl.[ERSDilatedDuctsType2], tbl.[ERSImgOthersTextBox], tbl.[EPlanCanunulate], tbl.[EplanManometry], tbl.[EplanStentremoval], tbl.[EplanCombinedProcedure], tbl.[EplanNasoPancreatic], tbl.[EplanStentReplacement], tbl.[EPlanEndoscopicCyst], tbl.[EplanPapillotomy], tbl.[EplanStoneRemoval], tbl.[EplanStentInsertion], tbl.[EplanStrictureDilatation], tbl.[EplanOthersTextBox], tbl.[ERSFollowPrevious], tbl.[ERSFollowCarriedOut], tbl.[ERSFollowBileDuct], tbl.[ERSFollowMalignancy], tbl.[ERSFollowBiliaryStricture], tbl.[ERSFollowStentReplacement], tbl.[PolypTumourAssess], tbl.[EMR], tbl.[EUSProcType], tbl.[Summary],  3, GETDATE(), tbl.WhoUpdatedId, tbl.ColonDefaecationDisorder
							FROM deleted tbl
GO

  Exec DropIfExist 'trg_ERS_UpperGIIndications_Insert', 'TR'
  GO
  Create TRIGGER [dbo].[trg_ERS_UpperGIIndications_Insert] 
							ON [dbo].[ERS_UpperGIIndications] 
							AFTER INSERT
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_UpperGIIndications_Audit] (IndicationId, tbl.[ProcedureId], tbl.[Anaemia], tbl.[AnaemiaType], tbl.[AbdominalPain], tbl.[AbnormalCapsuleStudy], tbl.[AbnormalMRI], tbl.[AbnormalityOnBarium], tbl.[ChestPain], tbl.[ChronicLiverDisease], tbl.[CoffeeGroundsVomit], tbl.[Diarrhoea], tbl.[DrugTrial], tbl.[Dyspepsia], tbl.[DyspepsiaAtypical], tbl.[DyspepsiaUlcerType], tbl.[Dysphagia], tbl.[Haematemesis], tbl.[Melaena], tbl.[NauseaAndOrVomiting], tbl.[Odynophagia], tbl.[PositiveTTG_EMA], tbl.[RefluxSymptoms], tbl.[UlcerExclusion], tbl.[WeightLoss], tbl.[PreviousHPyloriTest], tbl.[SerologyTest], tbl.[SerologyTestResult], tbl.[BreathTest], tbl.[BreathTestResult], tbl.[UreaseTest], tbl.[UreaseTestResult], tbl.[StoolAntigenTest], tbl.[StoolAntigenTestResult], tbl.[OpenAccess], tbl.[OtherIndication], tbl.[ClinicallyImpComments], tbl.[UrgentTwoWeekReferral], tbl.[Cancer], tbl.[WHOStatus], tbl.[BariatricPreAssessment], tbl.[BalloonInsertion], tbl.[BalloonRemoval], tbl.[SingleBalloonEnteroscopy], tbl.[DoubleBalloonEnteroscopy], tbl.[PostBariatricSurgeryAssessment], tbl.[EUS], tbl.[GastrostomyInsertion], tbl.[InsertionOfPHProbe], tbl.[JejunostomyInsertion], tbl.[NasoDuodenalTube], tbl.[OesophagealDilatation], tbl.[PEGRemoval], tbl.[PEGReplacement], tbl.[PushEnteroscopy], tbl.[SmallBowelBiopsy], tbl.[StentRemoval], tbl.[StentInsertion], tbl.[StentReplacement], tbl.[EUSRefGuidedFNABiopsy], tbl.[EUSOesophagealStricture], tbl.[EUSAssessmentOfSubmucosalLesion], tbl.[EUSTumourStagingOesophageal], tbl.[EUSTumourStagingGastric], tbl.[EUSTumourStagingDuodenal], tbl.[OtherPlannedProcedure], tbl.[CoMorbidityNone], tbl.[Angina], tbl.[Asthma], tbl.[COPD], tbl.[DiabetesMellitus], tbl.[DiabetesMellitusType], tbl.[Epilepsy], tbl.[HemiPostStroke], tbl.[Hypertension], tbl.[MI], tbl.[Obesity], tbl.[TIA], tbl.[OtherCoMorbidity], tbl.[ASAStatus], tbl.[PotentiallyDamagingDrug], tbl.[Allergy], tbl.[AllergyDesc], tbl.[CurrentMedication], tbl.[IncludeCurrentRxInReport], tbl.[SurgeryFollowUpProc], tbl.[SurgeryFollowUpProcPeriod], tbl.[SurgeryFollowUpText], tbl.[DiseaseFollowUpProc], tbl.[DiseaseFollowUpProcPeriod], tbl.[BarrettsOesophagus], tbl.[CoeliacDisease], tbl.[Dysplasia], tbl.[Gastritis], tbl.[Malignancy], tbl.[OesophagealDilatationFollowUp], tbl.[OesophagealVarices], tbl.[Oesophagitis], tbl.[UlcerHealing], tbl.[ColonSreeningColonoscopy], tbl.[ColonBowelCancerScreening], tbl.[ColonFOBT], tbl.[ColonAlterBowelHabit], tbl.[ColonRectalBleeding], tbl.[ColonAnaemia], tbl.[ColonAnaemiaType], tbl.[ColonAbnormalCTScan], tbl.[ColonAbnormalSigmoidoscopy], tbl.[ColonAbnormalBariumEnema], tbl.[ColonAbdominalMass], tbl.[ColonColonicObstruction], tbl.[ColonAbdominalPain], tbl.[ColonAssessment], tbl.[ColonAssessmentType], tbl.[ColonSurveillance], tbl.[ColonFamily], tbl.[ColonFamilyType], tbl.[ColonFamilyAdditionalText], tbl.[ColonCarcinoma], tbl.[ColonPolyps], tbl.[ColonDysplasia], tbl.[ColonMelaena], tbl.[ColonPolyposisSyndrome], tbl.[ColonRaisedFaecalCalprotectin], tbl.[ColonTumourAssessment], tbl.[ColonWeightLoss], tbl.[ERSAbdominalPain], tbl.[ERSChronicPancreatisis], tbl.[ERSSphincter], tbl.[ERSAbnormalEnzymes], tbl.[ERSJaundice], tbl.[ERSStentOcclusion], tbl.[ERSAcutePancreatitisAcute], tbl.[ERSObstructedCBD], tbl.[ERSSuspectedPapillary], tbl.[ERSBiliaryLeak], tbl.[ERSOpenAccess], tbl.[ERSCholangitis], tbl.[ERSPrelaparoscopic], tbl.[ERSRecurrentPancreatitis], tbl.[ERSBileDuctInjury], tbl.[ERSPurulentCholangitis], tbl.[ERSPancreaticPseudocyst], tbl.[ERSPancreatobiliaryPain], tbl.[ERSPapillaryDysfunction], tbl.[ERSPriSclerosingChol], tbl.[ERSImgUltrasound], tbl.[ERSImgCT], tbl.[ERSImgMRI], tbl.[ERSImgMRCP], tbl.[ERSImgIDA], tbl.[ERSImgEUS], tbl.[ERSNormal], tbl.[ERSChronicPancreatitis], tbl.[ERSAcutePancreatitis], tbl.[ERSGallBladder], tbl.[ERSFluidCollection], tbl.[ERSPancreaticMass], tbl.[ERSDilatedPancreatic], tbl.[ERSStonedBiliary], tbl.[ERSHepaticMass], tbl.[ERSObstructed], tbl.[ERSDilatedDucts], tbl.[AmpullaryMass], tbl.[BiliaryLeak], tbl.[GallBladderMass], tbl.[GallBladderPolyp], tbl.[ERSDilatedDuctsType1], tbl.[ERSDilatedDuctsType2], tbl.[ERSImgOthersTextBox], tbl.[EPlanCanunulate], tbl.[EplanManometry], tbl.[EplanStentremoval], tbl.[EplanCombinedProcedure], tbl.[EplanNasoPancreatic], tbl.[EplanStentReplacement], tbl.[EPlanEndoscopicCyst], tbl.[EplanPapillotomy], tbl.[EplanStoneRemoval], tbl.[EplanStentInsertion], tbl.[EplanStrictureDilatation], tbl.[EplanOthersTextBox], tbl.[ERSFollowPrevious], tbl.[ERSFollowCarriedOut], tbl.[ERSFollowBileDuct], tbl.[ERSFollowMalignancy], tbl.[ERSFollowBiliaryStricture], tbl.[ERSFollowStentReplacement], tbl.[PolypTumourAssess], tbl.[EMR], tbl.[EUSProcType], tbl.[Summary],  LastActionId, ActionDateTime, ActionUserId, ColonDefaecationDisorder)
							SELECT tbl.IndicationId , tbl.[ProcedureId], tbl.[Anaemia], tbl.[AnaemiaType], tbl.[AbdominalPain], tbl.[AbnormalCapsuleStudy], tbl.[AbnormalMRI], tbl.[AbnormalityOnBarium], tbl.[ChestPain], tbl.[ChronicLiverDisease], tbl.[CoffeeGroundsVomit], tbl.[Diarrhoea], tbl.[DrugTrial], tbl.[Dyspepsia], tbl.[DyspepsiaAtypical], tbl.[DyspepsiaUlcerType], tbl.[Dysphagia], tbl.[Haematemesis], tbl.[Melaena], tbl.[NauseaAndOrVomiting], tbl.[Odynophagia], tbl.[PositiveTTG_EMA], tbl.[RefluxSymptoms], tbl.[UlcerExclusion], tbl.[WeightLoss], tbl.[PreviousHPyloriTest], tbl.[SerologyTest], tbl.[SerologyTestResult], tbl.[BreathTest], tbl.[BreathTestResult], tbl.[UreaseTest], tbl.[UreaseTestResult], tbl.[StoolAntigenTest], tbl.[StoolAntigenTestResult], tbl.[OpenAccess], tbl.[OtherIndication], tbl.[ClinicallyImpComments], tbl.[UrgentTwoWeekReferral], tbl.[Cancer], tbl.[WHOStatus], tbl.[BariatricPreAssessment], tbl.[BalloonInsertion], tbl.[BalloonRemoval], tbl.[SingleBalloonEnteroscopy], tbl.[DoubleBalloonEnteroscopy], tbl.[PostBariatricSurgeryAssessment], tbl.[EUS], tbl.[GastrostomyInsertion], tbl.[InsertionOfPHProbe], tbl.[JejunostomyInsertion], tbl.[NasoDuodenalTube], tbl.[OesophagealDilatation], tbl.[PEGRemoval], tbl.[PEGReplacement], tbl.[PushEnteroscopy], tbl.[SmallBowelBiopsy], tbl.[StentRemoval], tbl.[StentInsertion], tbl.[StentReplacement], tbl.[EUSRefGuidedFNABiopsy], tbl.[EUSOesophagealStricture], tbl.[EUSAssessmentOfSubmucosalLesion], tbl.[EUSTumourStagingOesophageal], tbl.[EUSTumourStagingGastric], tbl.[EUSTumourStagingDuodenal], tbl.[OtherPlannedProcedure], tbl.[CoMorbidityNone], tbl.[Angina], tbl.[Asthma], tbl.[COPD], tbl.[DiabetesMellitus], tbl.[DiabetesMellitusType], tbl.[Epilepsy], tbl.[HemiPostStroke], tbl.[Hypertension], tbl.[MI], tbl.[Obesity], tbl.[TIA], tbl.[OtherCoMorbidity], tbl.[ASAStatus], tbl.[PotentiallyDamagingDrug], tbl.[Allergy], tbl.[AllergyDesc], tbl.[CurrentMedication], tbl.[IncludeCurrentRxInReport], tbl.[SurgeryFollowUpProc], tbl.[SurgeryFollowUpProcPeriod], tbl.[SurgeryFollowUpText], tbl.[DiseaseFollowUpProc], tbl.[DiseaseFollowUpProcPeriod], tbl.[BarrettsOesophagus], tbl.[CoeliacDisease], tbl.[Dysplasia], tbl.[Gastritis], tbl.[Malignancy], tbl.[OesophagealDilatationFollowUp], tbl.[OesophagealVarices], tbl.[Oesophagitis], tbl.[UlcerHealing], tbl.[ColonSreeningColonoscopy], tbl.[ColonBowelCancerScreening], tbl.[ColonFOBT], tbl.[ColonAlterBowelHabit], tbl.[ColonRectalBleeding], tbl.[ColonAnaemia], tbl.[ColonAnaemiaType], tbl.[ColonAbnormalCTScan], tbl.[ColonAbnormalSigmoidoscopy], tbl.[ColonAbnormalBariumEnema], tbl.[ColonAbdominalMass], tbl.[ColonColonicObstruction], tbl.[ColonAbdominalPain], tbl.[ColonAssessment], tbl.[ColonAssessmentType], tbl.[ColonSurveillance], tbl.[ColonFamily], tbl.[ColonFamilyType], tbl.[ColonFamilyAdditionalText], tbl.[ColonCarcinoma], tbl.[ColonPolyps], tbl.[ColonDysplasia], tbl.[ColonMelaena], tbl.[ColonPolyposisSyndrome], tbl.[ColonRaisedFaecalCalprotectin], tbl.[ColonTumourAssessment], tbl.[ColonWeightLoss], tbl.[ERSAbdominalPain], tbl.[ERSChronicPancreatisis], tbl.[ERSSphincter], tbl.[ERSAbnormalEnzymes], tbl.[ERSJaundice], tbl.[ERSStentOcclusion], tbl.[ERSAcutePancreatitisAcute], tbl.[ERSObstructedCBD], tbl.[ERSSuspectedPapillary], tbl.[ERSBiliaryLeak], tbl.[ERSOpenAccess], tbl.[ERSCholangitis], tbl.[ERSPrelaparoscopic], tbl.[ERSRecurrentPancreatitis], tbl.[ERSBileDuctInjury], tbl.[ERSPurulentCholangitis], tbl.[ERSPancreaticPseudocyst], tbl.[ERSPancreatobiliaryPain], tbl.[ERSPapillaryDysfunction], tbl.[ERSPriSclerosingChol], tbl.[ERSImgUltrasound], tbl.[ERSImgCT], tbl.[ERSImgMRI], tbl.[ERSImgMRCP], tbl.[ERSImgIDA], tbl.[ERSImgEUS], tbl.[ERSNormal], tbl.[ERSChronicPancreatitis], tbl.[ERSAcutePancreatitis], tbl.[ERSGallBladder], tbl.[ERSFluidCollection], tbl.[ERSPancreaticMass], tbl.[ERSDilatedPancreatic], tbl.[ERSStonedBiliary], tbl.[ERSHepaticMass], tbl.[ERSObstructed], tbl.[ERSDilatedDucts], tbl.[AmpullaryMass], tbl.[BiliaryLeak], tbl.[GallBladderMass], tbl.[GallBladderPolyp], tbl.[ERSDilatedDuctsType1], tbl.[ERSDilatedDuctsType2], tbl.[ERSImgOthersTextBox], tbl.[EPlanCanunulate], tbl.[EplanManometry], tbl.[EplanStentremoval], tbl.[EplanCombinedProcedure], tbl.[EplanNasoPancreatic], tbl.[EplanStentReplacement], tbl.[EPlanEndoscopicCyst], tbl.[EplanPapillotomy], tbl.[EplanStoneRemoval], tbl.[EplanStentInsertion], tbl.[EplanStrictureDilatation], tbl.[EplanOthersTextBox], tbl.[ERSFollowPrevious], tbl.[ERSFollowCarriedOut], tbl.[ERSFollowBileDuct], tbl.[ERSFollowMalignancy], tbl.[ERSFollowBiliaryStricture], tbl.[ERSFollowStentReplacement], tbl.[PolypTumourAssess], tbl.[EMR], tbl.[EUSProcType], tbl.[Summary],  1, GETDATE(), tbl.WhoCreatedId, tbl.ColonDefaecationDisorder
							FROM inserted tbl
GO

  Exec DropIfExist 'trg_ERS_UpperGIIndications_Update', 'TR'
  GO
  Create TRIGGER [dbo].[trg_ERS_UpperGIIndications_Update] 
								ON [dbo].[ERS_UpperGIIndications] 
								AFTER UPDATE
							AS 
								SET NOCOUNT ON; 
								IF NOT UPDATE(Summary)
								BEGIN
									INSERT INTO [ERSAudit].[ERS_UpperGIIndications_Audit] (IndicationId, tbl.[ProcedureId], tbl.[Anaemia], tbl.[AnaemiaType], tbl.[AbdominalPain], tbl.[AbnormalCapsuleStudy], tbl.[AbnormalMRI], tbl.[AbnormalityOnBarium], tbl.[ChestPain], tbl.[ChronicLiverDisease], tbl.[CoffeeGroundsVomit], tbl.[Diarrhoea], tbl.[DrugTrial], tbl.[Dyspepsia], tbl.[DyspepsiaAtypical], tbl.[DyspepsiaUlcerType], tbl.[Dysphagia], tbl.[Haematemesis], tbl.[Melaena], tbl.[NauseaAndOrVomiting], tbl.[Odynophagia], tbl.[PositiveTTG_EMA], tbl.[RefluxSymptoms], tbl.[UlcerExclusion], tbl.[WeightLoss], tbl.[PreviousHPyloriTest], tbl.[SerologyTest], tbl.[SerologyTestResult], tbl.[BreathTest], tbl.[BreathTestResult], tbl.[UreaseTest], tbl.[UreaseTestResult], tbl.[StoolAntigenTest], tbl.[StoolAntigenTestResult], tbl.[OpenAccess], tbl.[OtherIndication], tbl.[ClinicallyImpComments], tbl.[UrgentTwoWeekReferral], tbl.[Cancer], tbl.[WHOStatus], tbl.[BariatricPreAssessment], tbl.[BalloonInsertion], tbl.[BalloonRemoval], tbl.[SingleBalloonEnteroscopy], tbl.[DoubleBalloonEnteroscopy], tbl.[PostBariatricSurgeryAssessment], tbl.[EUS], tbl.[GastrostomyInsertion], tbl.[InsertionOfPHProbe], tbl.[JejunostomyInsertion], tbl.[NasoDuodenalTube], tbl.[OesophagealDilatation], tbl.[PEGRemoval], tbl.[PEGReplacement], tbl.[PushEnteroscopy], tbl.[SmallBowelBiopsy], tbl.[StentRemoval], tbl.[StentInsertion], tbl.[StentReplacement], tbl.[EUSRefGuidedFNABiopsy], tbl.[EUSOesophagealStricture], tbl.[EUSAssessmentOfSubmucosalLesion], tbl.[EUSTumourStagingOesophageal], tbl.[EUSTumourStagingGastric], tbl.[EUSTumourStagingDuodenal], tbl.[OtherPlannedProcedure], tbl.[CoMorbidityNone], tbl.[Angina], tbl.[Asthma], tbl.[COPD], tbl.[DiabetesMellitus], tbl.[DiabetesMellitusType], tbl.[Epilepsy], tbl.[HemiPostStroke], tbl.[Hypertension], tbl.[MI], tbl.[Obesity], tbl.[TIA], tbl.[OtherCoMorbidity], tbl.[ASAStatus], tbl.[PotentiallyDamagingDrug], tbl.[Allergy], tbl.[AllergyDesc], tbl.[CurrentMedication], tbl.[IncludeCurrentRxInReport], tbl.[SurgeryFollowUpProc], tbl.[SurgeryFollowUpProcPeriod], tbl.[SurgeryFollowUpText], tbl.[DiseaseFollowUpProc], tbl.[DiseaseFollowUpProcPeriod], tbl.[BarrettsOesophagus], tbl.[CoeliacDisease], tbl.[Dysplasia], tbl.[Gastritis], tbl.[Malignancy], tbl.[OesophagealDilatationFollowUp], tbl.[OesophagealVarices], tbl.[Oesophagitis], tbl.[UlcerHealing], tbl.[ColonSreeningColonoscopy], tbl.[ColonBowelCancerScreening], tbl.[ColonFOBT], tbl.[ColonAlterBowelHabit], tbl.[ColonRectalBleeding], tbl.[ColonAnaemia], tbl.[ColonAnaemiaType], tbl.[ColonAbnormalCTScan], tbl.[ColonAbnormalSigmoidoscopy], tbl.[ColonAbnormalBariumEnema], tbl.[ColonAbdominalMass], tbl.[ColonColonicObstruction], tbl.[ColonAbdominalPain], tbl.[ColonAssessment], tbl.[ColonAssessmentType], tbl.[ColonSurveillance], tbl.[ColonFamily], tbl.[ColonFamilyType], tbl.[ColonFamilyAdditionalText], tbl.[ColonCarcinoma], tbl.[ColonPolyps], tbl.[ColonDysplasia], tbl.[ColonMelaena], tbl.[ColonPolyposisSyndrome], tbl.[ColonRaisedFaecalCalprotectin], tbl.[ColonTumourAssessment], tbl.[ColonWeightLoss], tbl.[ERSAbdominalPain], tbl.[ERSChronicPancreatisis], tbl.[ERSSphincter], tbl.[ERSAbnormalEnzymes], tbl.[ERSJaundice], tbl.[ERSStentOcclusion], tbl.[ERSAcutePancreatitisAcute], tbl.[ERSObstructedCBD], tbl.[ERSSuspectedPapillary], tbl.[ERSBiliaryLeak], tbl.[ERSOpenAccess], tbl.[ERSCholangitis], tbl.[ERSPrelaparoscopic], tbl.[ERSRecurrentPancreatitis], tbl.[ERSBileDuctInjury], tbl.[ERSPurulentCholangitis], tbl.[ERSPancreaticPseudocyst], tbl.[ERSPancreatobiliaryPain], tbl.[ERSPapillaryDysfunction], tbl.[ERSPriSclerosingChol], tbl.[ERSImgUltrasound], tbl.[ERSImgCT], tbl.[ERSImgMRI], tbl.[ERSImgMRCP], tbl.[ERSImgIDA], tbl.[ERSImgEUS], tbl.[ERSNormal], tbl.[ERSChronicPancreatitis], tbl.[ERSAcutePancreatitis], tbl.[ERSGallBladder], tbl.[ERSFluidCollection], tbl.[ERSPancreaticMass], tbl.[ERSDilatedPancreatic], tbl.[ERSStonedBiliary], tbl.[ERSHepaticMass], tbl.[ERSObstructed], tbl.[ERSDilatedDucts], tbl.[AmpullaryMass], tbl.[BiliaryLeak], tbl.[GallBladderMass], tbl.[GallBladderPolyp], tbl.[ERSDilatedDuctsType1], tbl.[ERSDilatedDuctsType2], tbl.[ERSImgOthersTextBox], tbl.[EPlanCanunulate], tbl.[EplanManometry], tbl.[EplanStentremoval], tbl.[EplanCombinedProcedure], tbl.[EplanNasoPancreatic], tbl.[EplanStentReplacement], tbl.[EPlanEndoscopicCyst], tbl.[EplanPapillotomy], tbl.[EplanStoneRemoval], tbl.[EplanStentInsertion], tbl.[EplanStrictureDilatation], tbl.[EplanOthersTextBox], tbl.[ERSFollowPrevious], tbl.[ERSFollowCarriedOut], tbl.[ERSFollowBileDuct], tbl.[ERSFollowMalignancy], tbl.[ERSFollowBiliaryStricture], tbl.[ERSFollowStentReplacement], tbl.[PolypTumourAssess], tbl.[EMR], tbl.[EUSProcType], tbl.[Summary],  LastActionId, ActionDateTime, ActionUserId, ColonDefaecationDisorder)
									SELECT tbl.IndicationId , tbl.[ProcedureId], tbl.[Anaemia], tbl.[AnaemiaType], tbl.[AbdominalPain], tbl.[AbnormalCapsuleStudy], tbl.[AbnormalMRI], tbl.[AbnormalityOnBarium], tbl.[ChestPain], tbl.[ChronicLiverDisease], tbl.[CoffeeGroundsVomit], tbl.[Diarrhoea], tbl.[DrugTrial], tbl.[Dyspepsia], tbl.[DyspepsiaAtypical], tbl.[DyspepsiaUlcerType], tbl.[Dysphagia], tbl.[Haematemesis], tbl.[Melaena], tbl.[NauseaAndOrVomiting], tbl.[Odynophagia], tbl.[PositiveTTG_EMA], tbl.[RefluxSymptoms], tbl.[UlcerExclusion], tbl.[WeightLoss], tbl.[PreviousHPyloriTest], tbl.[SerologyTest], tbl.[SerologyTestResult], tbl.[BreathTest], tbl.[BreathTestResult], tbl.[UreaseTest], tbl.[UreaseTestResult], tbl.[StoolAntigenTest], tbl.[StoolAntigenTestResult], tbl.[OpenAccess], tbl.[OtherIndication], tbl.[ClinicallyImpComments], tbl.[UrgentTwoWeekReferral], tbl.[Cancer], tbl.[WHOStatus], tbl.[BariatricPreAssessment], tbl.[BalloonInsertion], tbl.[BalloonRemoval], tbl.[SingleBalloonEnteroscopy], tbl.[DoubleBalloonEnteroscopy], tbl.[PostBariatricSurgeryAssessment], tbl.[EUS], tbl.[GastrostomyInsertion], tbl.[InsertionOfPHProbe], tbl.[JejunostomyInsertion], tbl.[NasoDuodenalTube], tbl.[OesophagealDilatation], tbl.[PEGRemoval], tbl.[PEGReplacement], tbl.[PushEnteroscopy], tbl.[SmallBowelBiopsy], tbl.[StentRemoval], tbl.[StentInsertion], tbl.[StentReplacement], tbl.[EUSRefGuidedFNABiopsy], tbl.[EUSOesophagealStricture], tbl.[EUSAssessmentOfSubmucosalLesion], tbl.[EUSTumourStagingOesophageal], tbl.[EUSTumourStagingGastric], tbl.[EUSTumourStagingDuodenal], tbl.[OtherPlannedProcedure], tbl.[CoMorbidityNone], tbl.[Angina], tbl.[Asthma], tbl.[COPD], tbl.[DiabetesMellitus], tbl.[DiabetesMellitusType], tbl.[Epilepsy], tbl.[HemiPostStroke], tbl.[Hypertension], tbl.[MI], tbl.[Obesity], tbl.[TIA], tbl.[OtherCoMorbidity], tbl.[ASAStatus], tbl.[PotentiallyDamagingDrug], tbl.[Allergy], tbl.[AllergyDesc], tbl.[CurrentMedication], tbl.[IncludeCurrentRxInReport], tbl.[SurgeryFollowUpProc], tbl.[SurgeryFollowUpProcPeriod], tbl.[SurgeryFollowUpText], tbl.[DiseaseFollowUpProc], tbl.[DiseaseFollowUpProcPeriod], tbl.[BarrettsOesophagus], tbl.[CoeliacDisease], tbl.[Dysplasia], tbl.[Gastritis], tbl.[Malignancy], tbl.[OesophagealDilatationFollowUp], tbl.[OesophagealVarices], tbl.[Oesophagitis], tbl.[UlcerHealing], tbl.[ColonSreeningColonoscopy], tbl.[ColonBowelCancerScreening], tbl.[ColonFOBT], tbl.[ColonAlterBowelHabit], tbl.[ColonRectalBleeding], tbl.[ColonAnaemia], tbl.[ColonAnaemiaType], tbl.[ColonAbnormalCTScan], tbl.[ColonAbnormalSigmoidoscopy], tbl.[ColonAbnormalBariumEnema], tbl.[ColonAbdominalMass], tbl.[ColonColonicObstruction], tbl.[ColonAbdominalPain], tbl.[ColonAssessment], tbl.[ColonAssessmentType], tbl.[ColonSurveillance], tbl.[ColonFamily], tbl.[ColonFamilyType], tbl.[ColonFamilyAdditionalText], tbl.[ColonCarcinoma], tbl.[ColonPolyps], tbl.[ColonDysplasia], tbl.[ColonMelaena], tbl.[ColonPolyposisSyndrome], tbl.[ColonRaisedFaecalCalprotectin], tbl.[ColonTumourAssessment], tbl.[ColonWeightLoss], tbl.[ERSAbdominalPain], tbl.[ERSChronicPancreatisis], tbl.[ERSSphincter], tbl.[ERSAbnormalEnzymes], tbl.[ERSJaundice], tbl.[ERSStentOcclusion], tbl.[ERSAcutePancreatitisAcute], tbl.[ERSObstructedCBD], tbl.[ERSSuspectedPapillary], tbl.[ERSBiliaryLeak], tbl.[ERSOpenAccess], tbl.[ERSCholangitis], tbl.[ERSPrelaparoscopic], tbl.[ERSRecurrentPancreatitis], tbl.[ERSBileDuctInjury], tbl.[ERSPurulentCholangitis], tbl.[ERSPancreaticPseudocyst], tbl.[ERSPancreatobiliaryPain], tbl.[ERSPapillaryDysfunction], tbl.[ERSPriSclerosingChol], tbl.[ERSImgUltrasound], tbl.[ERSImgCT], tbl.[ERSImgMRI], tbl.[ERSImgMRCP], tbl.[ERSImgIDA], tbl.[ERSImgEUS], tbl.[ERSNormal], tbl.[ERSChronicPancreatitis], tbl.[ERSAcutePancreatitis], tbl.[ERSGallBladder], tbl.[ERSFluidCollection], tbl.[ERSPancreaticMass], tbl.[ERSDilatedPancreatic], tbl.[ERSStonedBiliary], tbl.[ERSHepaticMass], tbl.[ERSObstructed], tbl.[ERSDilatedDucts], tbl.[AmpullaryMass], tbl.[BiliaryLeak], tbl.[GallBladderMass], tbl.[GallBladderPolyp], tbl.[ERSDilatedDuctsType1], tbl.[ERSDilatedDuctsType2], tbl.[ERSImgOthersTextBox], tbl.[EPlanCanunulate], tbl.[EplanManometry], tbl.[EplanStentremoval], tbl.[EplanCombinedProcedure], tbl.[EplanNasoPancreatic], tbl.[EplanStentReplacement], tbl.[EPlanEndoscopicCyst], tbl.[EplanPapillotomy], tbl.[EplanStoneRemoval], tbl.[EplanStentInsertion], tbl.[EplanStrictureDilatation], tbl.[EplanOthersTextBox], tbl.[ERSFollowPrevious], tbl.[ERSFollowCarriedOut], tbl.[ERSFollowBileDuct], tbl.[ERSFollowMalignancy], tbl.[ERSFollowBiliaryStricture], tbl.[ERSFollowStentReplacement], tbl.[PolypTumourAssess], tbl.[EMR], tbl.[EUSProcType], tbl.[Summary],  2, GETDATE(), i.WhoUpdatedId, tbl.ColonDefaecationDisorder
									FROM deleted tbl INNER JOIN inserted i ON tbl.IndicationId = i.IndicationId
								END
GO

EXEC DropIfExist 'OGD_Indications_Select','S';
GO

--Don't want to lose any data, so any procedure that hase Defaecation Disorder already on it needs to have the flag set.
update ERS_UpperGIIndications
set ColonDefaecationDisorder = 1
where ColonAlterBowelHabit = (select ListItemNo from ERS_Lists where ListDescription = 'Indications Colon Altered Bowel Habit' and ListItemText = 'defaecation disorder')

Delete from ERS_Lists where ListDescription = 'Indications Colon Altered Bowel Habit' and ListItemText = 'defaecation disorder'
GO

CREATE  PROCEDURE [dbo].[OGD_Indications_Select]
(
	@ProcedureId INT
)
AS

SET NOCOUNT ON

	SELECT	ProcedureId,
		Anaemia,
		AnaemiaType,
		AbdominalPain,
		AbnormalCapsuleStudy,
		AbnormalMRI,
		AbnormalityOnBarium,
		ChestPain,
		ChronicLiverDisease,
		CoffeeGroundsVomit,
		Diarrhoea,
		DrugTrial,
		Dyspepsia,
		DyspepsiaAtypical,
		DyspepsiaUlcerType,	
		Dysphagia,
		Haematemesis,
		Melaena,
		NauseaAndOrVomiting,
		Odynophagia,
		PositiveTTG_EMA,
		RefluxSymptoms,
		UlcerExclusion,
		WeightLoss,
		PreviousHPyloriTest,
		SerologyTest,
		SerologyTestResult,
		BreathTest,
		BreathTestResult,
		UreaseTest,
		UreaseTestResult,
		StoolAntigenTest,
		StoolAntigenTestResult,
		OpenAccess,
		OtherIndication,
		ClinicallyImpComments,
		UrgentTwoWeekReferral,
		Cancer,
		WHOStatus,
		BariatricPreAssessment,
		BalloonInsertion,
		SingleBalloonEnteroscopy,
		DoubleBalloonEnteroscopy,
		BalloonRemoval,
		PostBariatricSurgeryAssessment,
		EUS,
		GastrostomyInsertion,
		InsertionOfPHProbe,
		JejunostomyInsertion,
		NasoDuodenalTube,
		OesophagealDilatation,
		PEGRemoval,
		PEGReplacement,
		PushEnteroscopy,
		SmallBowelBiopsy,
		StentRemoval,
		StentInsertion,
		StentReplacement,
		EUSRefGuidedFNABiopsy,
		EUSOesophagealStricture,
		EUSAssessmentOfSubmucosalLesion,
		EUSTumourStagingOesophageal,
		EUSTumourStagingGastric,
		EUSTumourStagingDuodenal,
		OtherPlannedProcedure,
		CoMorbidityNone,
		Angina,
		Asthma,
		COPD,
		DiabetesMellitus,
		DiabetesMellitusType,
		Epilepsy,
		HemiPostStroke,
		Hypertension,
		MI,
		Obesity,
		TIA,
		OtherCoMorbidity,
		ASAStatus,
		PotentiallyDamagingDrug,
		Allergy,
		AllergyDesc,
		CurrentMedication,
		IncludeCurrentRxInReport,
		SurgeryFollowUpProc,
		SurgeryFollowUpProcPeriod,
		SurgeryFollowUpText,
		DiseaseFollowUpProc,
		DiseaseFollowUpProcPeriod,
		BarrettsOesophagus,
		CoeliacDisease,
		Dysplasia,
		Gastritis,
		Malignancy,
		OesophagealDilatationFollowUp,
		OesophagealVarices,
		Oesophagitis,
		UlcerHealing,
		[ColonSreeningColonoscopy],
		[ColonBowelCancerScreening],
		[ColonFOBT],
		[ColonFIT],
		[ColonIndicationSurveillance],
		[ColonAlterBowelHabit],
		[NationalBowelScopeScreening],
		[ColonRectalBleeding],
		[ColonAnaemia],
		[ColonAnaemiaType],
		[ColonAbnormalCTScan],
		[ColonAbnormalSigmoidoscopy],
		[ColonAbnormalBariumEnema],
		[ColonAbdominalMass],
		ColonDefaecationDisorder,
		[ColonColonicObstruction],
		[ColonAbdominalPain],
		ColonTumourAssessment, 
		ColonMelaena, 
		ColonPolyposisSyndrome, 
		ColonRaisedFaecalCalprotectin,
		ColonWeightLoss,
		ColonFamily,ColonFamilyType,
		ColonAssessment,ColonAssessmentType,
		ColonSurveillance,
		ColonFamilyAdditionalText,
		ColonCarcinoma,
		ColonPolyps,
		ColonDysplasia,
		ERSAbdominalPain,
		ERSChronicPancreatisis,
		ERSSphincter,
		ERSAbnormalEnzymes,
		ERSJaundice,
		ERSStentOcclusion,
		ERSAcutePancreatitisAcute,
		ERSObstructedCBD,
		ERSSuspectedPapillary,
		ERSBiliaryLeak,
		ERSOpenAccess,
		ERSCholangitis,
		ERSPrelaparoscopic,
		ERSRecurrentPancreatitis,
		ERSBileDuctInjury,
		ERSPurulentCholangitis,
		ERSPancreaticPseudocyst,
		ERSPancreatobiliaryPain,
		ERSPapillaryDysfunction,
		ERSPriSclerosingChol,
		ERSImgUltrasound,
		ERSImgCT,
		ERSImgMRI,
		ERSImgMRCP,
		ERSImgIDA,
		ERSImgEUS,
		ERSNormal,
		ERSChronicPancreatitis,
		ERSAcutePancreatitis,
		ERSGallBladder,
		ERSFluidCollection,
		ERSPancreaticMass,
		ERSDilatedPancreatic,
		ERSStonedBiliary,
		ERSHepaticMass,
		ERSObstructed,
		ERSDilatedDucts,
		AmpullaryMass,
		GallBladderMass,
		GallBladderPolyp,
		BiliaryLeak,
		ERSDilatedDuctsType1,
		ERSDilatedDuctsType2,     
		ERSImgOthersTextBox,
		EPlanCanunulate,
		EplanManometry,
		EplanStentremoval,
		EplanCombinedProcedure,
		EplanNasoPancreatic,
		EplanStentReplacement,
		EPlanEndoscopicCyst,
		EplanPapillotomy,
		EplanStoneRemoval,
		EplanStentInsertion,
		EplanStrictureDilatation,
		EplanOthersTextBox,
		EPlanCanunulate,
		EplanManometry,
		EplanStentremoval,
		EplanCombinedProcedure,
		EplanNasoPancreatic,
		EplanStentReplacement,
		EPlanEndoscopicCyst,
		EplanPapillotomy,
		EplanStoneRemoval,
		EplanStentInsertion,
		EplanStrictureDilatation,
		EplanOthersTextBox,
		ERSFollowPrevious,
		ERSFollowCarriedOut,
		ERSFollowBileDuct,
		ERSFollowMalignancy,
		ERSFollowBiliaryStricture,
		ERSFollowStentReplacement,
		PolypTumourAssess,
		EMR,
		EPlanNGTubeInsertion,
		EPlanNGTubeRemoval
	FROM
		ERS_UpperGIIndications
	WHERE 
		ProcedureId = @ProcedureId;

GO

EXEC DropIfExist 'ogd_indications_save','S';
GO

CREATE PROCEDURE [dbo].[ogd_indications_save]
(
	@ProcedureId INT,
	@Anaemia BIT,
	@AnaemiaType SMALLINT,
	@AbdominalPain BIT,
	@AbnormalCapsuleStudy BIT,
	@AbnormalMRI BIT,
	@AbnormalityOnBarium BIT,
	@ChestPain BIT,
	@ChronicLiverDisease BIT,
	@CoffeeGroundsVomit BIT,
	@Diarrhoea BIT,
	@DrugTrial BIT,
	@Dyspepsia BIT,
	@DyspepsiaAtypical BIT,
	@DyspepsiaUlcerType BIT,	
	@Dysphagia BIT,
	@Haematemesis BIT,
	@Melaena BIT,
	@NauseaAndOrVomiting BIT,
	@Odynophagia BIT,
	@PositiveTTG BIT,
	@RefluxSymptoms BIT,
	@UlcerExclusion BIT,
	@WeightLoss BIT,
	@PreviousHPyloriTest BIT,
	@SerologyTest BIT,
	@SerologyTestResult TINYINT,
	@BreathTest BIT,
	@BreathTestResult TINYINT,
	@UreaseTest BIT,
	@UreaseTestResult TINYINT,
	@StoolAntigenTest BIT,
	@StoolAntigenTestResult TINYINT,
	@OpenAccess BIT,
	@OtherIndication NVARCHAR(1000),
	@ClinicallyImpComments NVARCHAR(4000),
	@UrgentTwoWeekReferral BIT,
	@Cancer INT,
	@WHOStatus SMALLINT,
	@BariatricPreAssessment BIT,
	@BalloonInsertion BIT,
	@BalloonRemoval BIT,
	@SingleBalloonEnteroscopy BIT,
	@DoubleBalloonEnteroscopy BIT,
	@PostBariatricSurgeryAssessment BIT,
	@EUS BIT,
	@GastrostomyInsertion BIT,
	@InsertionOfPHProbe BIT,
	@JejunostomyInsertion BIT,
	@NasoDuodenalTube BIT,
	@OesophagealDilatation BIT,
	@PEGRemoval BIT,
	@PEGReplacement BIT,
	@PushEnteroscopy BIT,
	@SmallBowelBiopsy BIT,
	@StentRemoval BIT,
	@StentInsertion BIT,
	@StentReplacement BIT,
	@EUSRefGuidedFNABiopsy BIT,
	@EUSOesophagealStricture BIT,
	@EUSAssessmentOfSubmucosalLesion BIT,
	@EUSTumourStagingOesophageal BIT,
	@EUSTumourStagingGastric BIT,
	@EUSTumourStagingDuodenal BIT,
	@OtherPlannedProcedure NVARCHAR(1000),
	@CoMorbidityNone BIT,
	@Angina BIT,
	@Asthma BIT,
	@COPD BIT,
	@DiabetesMellitus BIT,
	@DiabetesMellitusType TINYINT,
	@Epilepsy BIT,
	@HemiPostStroke BIT,
	@Hypertension BIT,
	@MI BIT,
	@Obesity BIT,
	@TIA BIT,
	@OtherCoMorbidity NVARCHAR(1000),
	@ASAStatus TINYINT,
	@PotentiallyDamagingDrug NVARCHAR(1000),
	@Allergy TINYINT,
	@AllergyDesc NVARCHAR(1000),
	@CurrentMedication NVARCHAR(4000),
	@IncludeCurrentRxInReport BIT,
	@SurgeryFollowUpProc INT,
	@SurgeryFollowUpProcPeriod INT,
	@SurgeryFollowUpText NVARCHAR(1000),
	@DiseaseFollowUpProc INT,
	@DiseaseFollowUpProcPeriod INT,
	@BarrettsOesophagus BIT,
	@CoeliacDisease BIT,
	@Dysplasia BIT,
	@Gastritis BIT,
	@Malignancy BIT,
	@OesophagealDilatationFollowUp BIT,
	@OesophagealVarices BIT,
	@Oesophagitis BIT,
	@UlcerHealing BIT,
	@ColonSreeningColonoscopy bit,
	@ColonBowelCancerScreening bit,
	@ColonFOBT bit,
	@ColonFIT bit,
	@ColonIndicationSurveillance bit,
	@ColonAlterBowelHabit int,
	@NationalBowelScopeScreening bit,
	@ColonRectalBleeding int,
	@ColonAnaemia bit,
	@ColonAnaemiaType int,
	@ColonAbnormalCTScan bit,
	@ColonAbnormalSigmoidoscopy bit,
	@ColonAbnormalBariumEnema bit,
	@ColonAbdominalMass bit,
	@ColonDefaecationDisorder bit,
	@ColonColonicObstruction bit,
	@ColonAbdominalPain bit,
	@ColonTumourAssessment BIT,
	@ColonMelaena BIT,
	@ColonPolyposisSyndrome BIT,
	@ColonRaisedFaecalCalprotectin BIT,
	@ColonWeightLoss BIT,
	@ColonFamily bit, 
	@ColonFamilyType int,
	@ColonAssessment bit,
	@ColonAssessmentType int,
	@ColonSurveillance bit,
	@ColonFamilyAdditionalText varchar(7000),
	@ColonCarcinoma bit,
	@ColonPolyps bit,
	@ColonDysplasia bit,
	@ERSAbdominalPain bit,
	@ERSChronicPancreatisis bit,
	@ERSSphincter bit,
	@ERSAbnormalEnzymes bit,
	@ERSJaundice bit,
	@ERSStentOcclusion bit,
	@ERSAcutePancreatitisAcute bit,
	@ERSObstructedCBD bit, 
	@ERSSuspectedPapillary bit,	
	@ERSBiliaryLeak bit,
	@ERSOpenAccess bit, 
	@ERSCholangitis bit,
	@ERSPrelaparoscopic bit,
	@ERSRecurrentPancreatitis bit,
	@ERSBileDuctInjury bit,
	@ERSPurulentCholangitis bit,
	@ERSPancreaticPseudocyst bit,
	@ERSPancreatobiliaryPain bit,
	@ERSPapillaryDysfunction bit,
	@ERSPriSclerosingChol bit,
	@ERSImgUltrasound bit,
	@ERSImgCT bit,
	@ERSImgMRI bit,
	@ERSImgMRCP bit,
	@ERSImgIDA bit,
	@ERSImgEUS bit,
	@ERSNormal bit,
	@ERSChronicPancreatitis bit,
	@ERSAcutePancreatitis bit,
	@ERSGallBladder bit,
	@ERSFluidCollection bit,
	@ERSPancreaticMass bit,
	@ERSDilatedPancreatic bit,
	@ERSStonedBiliary bit,
	@ERSHepaticMass bit,
	@ERSObstructed bit,
	@ERSDilatedDucts bit,
	@AmpullaryMass BIT,
	@GallBladderMass AS BIT,
	@GallBladderPolyp AS BIT,
	@BiliaryLeak bit,
	@ERSDilatedDuctsType1 bit,
	@ERSDilatedDuctsType2 bit,
	@ERSImgOthersTextBox varchar(2000),
	@EPlanCanunulate bit,
	@EplanManometry bit,
	@EplanStentremoval bit,
	@EplanCombinedProcedure bit,
	@EplanNasoPancreatic bit,
	@EplanStentReplacement bit,
	@EPlanEndoscopicCyst bit,
	@EplanPapillotomy bit,
	@EplanStoneRemoval bit,
	@EplanStentInsertion bit,
	@EplanStrictureDilatation bit,
	@EplanOthersTextBox varchar(2000),
	@ERSFollowPrevious smallint,
	@ERSFollowCarriedOut smallint,
	@ERSFollowBileDuct bit,
	@ERSFollowMalignancy bit,
	@ERSFollowBiliaryStricture bit,
	@ERSFollowStentReplacement bit,
	@PolypTumourAssess bit,
	@EMR bit,
	@EPlanNGTubeInsertion bit,
	@EPlanNGTubeRemoval bit,
	@LoggedInUserId INT

)
AS

SET NOCOUNT OFF --## Need to know Whether a Record is INSERTED, from ASP.Net

BEGIN TRANSACTION

BEGIN TRY
			
	IF @SerologyTest = 0 SET @SerologyTestResult = 0
	IF @BreathTest = 0 SET @BreathTestResult = 0
	IF @UreaseTest = 0 SET @UreaseTestResult = 0
	IF @StoolAntigenTest = 0 SET @StoolAntigenTestResult = 0

	IF NOT EXISTS (SELECT 1 FROM ERS_UpperGIIndications WHERE ProcedureId = @ProcedureId)
	BEGIN
		INSERT INTO ERS_UpperGIIndications (
			ProcedureId,
			Anaemia,
			AnaemiaType,
			AbdominalPain,
			AbnormalCapsuleStudy,
			AbnormalMRI,
			AbnormalityOnBarium,
			ChestPain,
			ChronicLiverDisease,
			CoffeeGroundsVomit,
			Diarrhoea,
			DrugTrial,
			Dyspepsia,
			DyspepsiaAtypical,
			DyspepsiaUlcerType,			
			Dysphagia,
			Haematemesis,
			Melaena,
			NauseaAndOrVomiting,
			Odynophagia,
			PositiveTTG_EMA,
			RefluxSymptoms,
			UlcerExclusion,
			WeightLoss,
			PreviousHPyloriTest,
			SerologyTest,
			SerologyTestResult,
			BreathTest,
			BreathTestResult,
			UreaseTest,
			UreaseTestResult,
			StoolAntigenTest,
			StoolAntigenTestResult,
			OpenAccess,
			OtherIndication,
			ClinicallyImpComments,
			UrgentTwoWeekReferral,
			Cancer,
			WHOStatus,
			BariatricPreAssessment,
			BalloonInsertion,
			BalloonRemoval,
			SingleBalloonEnteroscopy,
			DoubleBalloonEnteroscopy,
			PostBariatricSurgeryAssessment,
			EUS,
			GastrostomyInsertion,
			InsertionOfPHProbe,
			JejunostomyInsertion,
			NasoDuodenalTube,
			OesophagealDilatation,
			PEGRemoval,
			PEGReplacement,
			PushEnteroscopy,
			SmallBowelBiopsy,
			StentRemoval,
			StentInsertion,
			StentReplacement,
			EUSRefGuidedFNABiopsy,
			EUSOesophagealStricture,
			EUSAssessmentOfSubmucosalLesion,
			EUSTumourStagingOesophageal,
			EUSTumourStagingGastric,
			EUSTumourStagingDuodenal,
			OtherPlannedProcedure,
			CoMorbidityNone,
			Angina,
			Asthma,
			COPD,
			DiabetesMellitus,
			DiabetesMellitusType,
			Epilepsy,
			HemiPostStroke,
			Hypertension,
			MI,
			Obesity,
			TIA,
			OtherCoMorbidity,
			ASAStatus,
			PotentiallyDamagingDrug,
			Allergy,
			AllergyDesc,
			CurrentMedication,
			IncludeCurrentRxInReport,
			SurgeryFollowUpProc,
			SurgeryFollowUpProcPeriod,
			SurgeryFollowUpText,
			DiseaseFollowUpProc,
			DiseaseFollowUpProcPeriod,
			BarrettsOesophagus,
			CoeliacDisease,
			Dysplasia,
			Gastritis,
			Malignancy,
			OesophagealDilatationFollowUp,
			OesophagealVarices,
			Oesophagitis,
			UlcerHealing,
			ColonSreeningColonoscopy,
			ColonBowelCancerScreening,
			ColonFOBT,
			ColonFIT,
			ColonIndicationSurveillance,
			ColonAlterBowelHabit,
			NationalBowelScopeScreening,
			ColonRectalBleeding,
			ColonAnaemia,
			ColonAnaemiaType,	
			ColonAbnormalCTScan,
			ColonAbnormalSigmoidoscopy,
			ColonAbnormalBariumEnema,
			ColonAbdominalMass,
			ColonDefaecationDisorder,
			ColonColonicObstruction,
			ColonAbdominalPain,
			ColonTumourAssessment,
			ColonMelaena,
			ColonPolyposisSyndrome,
			ColonRaisedFaecalCalprotectin,
			ColonWeightLoss,
			ColonFamily,
			ColonAssessment,
			ColonSurveillance,
			ColonCarcinoma,
			ColonPolyps,
			ColonDysplasia,
			ColonFamilyType,
			ColonAssessmentType,
			ColonFamilyAdditionalText,
			ERSAbdominalPain,
			ERSChronicPancreatisis,
			ERSSphincter,
			ERSAbnormalEnzymes,
			ERSJaundice,
			ERSStentOcclusion,
			ERSAcutePancreatitisAcute,
			ERSObstructedCBD,
			ERSSuspectedPapillary,
			ERSBiliaryLeak,
			ERSOpenAccess,
			ERSCholangitis,
			ERSPrelaparoscopic,
			ERSRecurrentPancreatitis,
			ERSBileDuctInjury,
			ERSPurulentCholangitis,
			ERSPancreaticPseudocyst,
			ERSPancreatobiliaryPain,
			ERSPapillaryDysfunction,
			ERSPriSclerosingChol,
			ERSImgUltrasound,
			ERSImgCT,
			ERSImgMRI,
			ERSImgMRCP,
			ERSImgIDA,
			ERSImgEUS,
			ERSNormal,
			ERSChronicPancreatitis,
			ERSAcutePancreatitis,
			ERSGallBladder,
			ERSFluidCollection,
			ERSPancreaticMass,
			ERSDilatedPancreatic,
			ERSStonedBiliary,
			ERSHepaticMass,
			ERSObstructed,
			ERSDilatedDucts,
			AmpullaryMass,
			GallBladderMass,
			GallBladderPolyp,
			BiliaryLeak,
			ERSDilatedDuctsType1,
			ERSDilatedDuctsType2,
			ERSImgOthersTextBox,
			EPlanCanunulate,
			EplanManometry,
			EplanStentremoval,
			EplanCombinedProcedure,
			EplanNasoPancreatic,
			EplanStentReplacement,
			EPlanEndoscopicCyst,
			EplanPapillotomy,
			EplanStoneRemoval,
			EplanStentInsertion,
			EplanStrictureDilatation,
			EplanOthersTextBox,
			ERSFollowPrevious,
			ERSFollowCarriedOut,
			ERSFollowBileDuct,
			ERSFollowMalignancy,
			ERSFollowBiliaryStricture,
			ERSFollowStentReplacement,
			PolypTumourAssess,
			EMR,
			EPlanNGTubeInsertion,
			EPlanNGTubeRemoval,
			WhoCreatedId,
			WhenCreated) 
		VALUES (
			@ProcedureId,
			@Anaemia,
			@AnaemiaType,
			@AbdominalPain,
			@AbnormalCapsuleStudy,
			@AbnormalMRI,
			@AbnormalityOnBarium,
			@ChestPain,
			@ChronicLiverDisease,
			@CoffeeGroundsVomit,
			@Diarrhoea,
			@DrugTrial,
			@Dyspepsia,
			@DyspepsiaAtypical,
			@DyspepsiaUlcerType,			
			@Dysphagia,
			@Haematemesis,
			@Melaena,
			@NauseaAndOrVomiting,
			@Odynophagia,
			@PositiveTTG,
			@RefluxSymptoms,
			@UlcerExclusion,
			@WeightLoss,
			@PreviousHPyloriTest,
			@SerologyTest,
			@SerologyTestResult,
			@BreathTest,
			@BreathTestResult,
			@UreaseTest,
			@UreaseTestResult,
			@StoolAntigenTest,
			@StoolAntigenTestResult,
			@OpenAccess,
			@OtherIndication,
			@ClinicallyImpComments,
			@UrgentTwoWeekReferral,
			@Cancer,
			@WHOStatus,
			@BariatricPreAssessment,
			@BalloonInsertion,
			@BalloonRemoval,
			@SingleBalloonEnteroscopy,
			@DoubleBalloonEnteroscopy,
			@PostBariatricSurgeryAssessment,
			@EUS,
			@GastrostomyInsertion,
			@InsertionOfPHProbe,
			@JejunostomyInsertion,
			@NasoDuodenalTube,
			@OesophagealDilatation,
			@PEGRemoval,
			@PEGReplacement,
			@PushEnteroscopy,
			@SmallBowelBiopsy,
			@StentRemoval,
			@StentInsertion,
			@StentReplacement,
			@EUSRefGuidedFNABiopsy,
			@EUSOesophagealStricture,
			@EUSAssessmentOfSubmucosalLesion,
			@EUSTumourStagingOesophageal,
			@EUSTumourStagingGastric,
			@EUSTumourStagingDuodenal,
			@OtherPlannedProcedure,
			@CoMorbidityNone,
			@Angina,
			@Asthma,
			@COPD,
			@DiabetesMellitus,
			@DiabetesMellitusType,
			@Epilepsy,
			@HemiPostStroke,
			@Hypertension,
			@MI,
			@Obesity,
			@TIA,
			@OtherCoMorbidity,
			@ASAStatus,
			@PotentiallyDamagingDrug,
			@Allergy,
			@AllergyDesc,
			@CurrentMedication,
			@IncludeCurrentRxInReport,
			@SurgeryFollowUpProc,
			@SurgeryFollowUpProcPeriod,
			@SurgeryFollowUpText,
			@DiseaseFollowUpProc,
			@DiseaseFollowUpProcPeriod,
			@BarrettsOesophagus,
			@CoeliacDisease,
			@Dysplasia,
			@Gastritis,
			@Malignancy,
			@OesophagealDilatationFollowUp,
			@OesophagealVarices,
			@Oesophagitis,
			@UlcerHealing,
			@ColonSreeningColonoscopy,
			@ColonBowelCancerScreening,
			@ColonFOBT,
			@ColonFIT,
			@ColonIndicationSurveillance,
			@ColonAlterBowelHabit,
			@NationalBowelScopeScreening,
			@ColonRectalBleeding,
			@ColonAnaemia,
			@ColonAnaemiaType,
			@ColonAbnormalCTScan,
			@ColonAbnormalSigmoidoscopy,
			@ColonAbnormalBariumEnema,
			@ColonAbdominalMass,
			@ColonDefaecationDisorder,
			@ColonColonicObstruction,
			@ColonAbdominalPain,
			@ColonTumourAssessment,
			@ColonMelaena,
			@ColonPolyposisSyndrome,
			@ColonRaisedFaecalCalprotectin,
			@ColonWeightLoss,
			@ColonFamily,
			@ColonAssessment,
			@ColonSurveillance,
			@ColonCarcinoma,
			@ColonPolyps,
			@ColonDysplasia,
			@ColonFamilyType,
			@ColonAssessmentType,
			@ColonFamilyAdditionalText, 
			@ERSAbdominalPain,
			@ERSChronicPancreatisis,
			@ERSSphincter,
			@ERSAbnormalEnzymes,
			@ERSJaundice,
			@ERSStentOcclusion,
			@ERSAcutePancreatitisAcute,
			@ERSObstructedCBD,
			@ERSSuspectedPapillary,
			@ERSBiliaryLeak,
			@ERSOpenAccess,
			@ERSCholangitis,
			@ERSPrelaparoscopic,
			@ERSRecurrentPancreatitis,
			@ERSBileDuctInjury,
			@ERSPurulentCholangitis,
			@ERSPancreaticPseudocyst,
			@ERSPancreatobiliaryPain,
			@ERSPapillaryDysfunction,
			@ERSPriSclerosingChol,
			@ERSImgUltrasound,
			@ERSImgCT,
			@ERSImgMRI,
			@ERSImgMRCP,
			@ERSImgIDA,
			@ERSImgEUS,
			@ERSNormal,
			@ERSChronicPancreatitis,
			@ERSAcutePancreatitis,
			@ERSGallBladder,
			@ERSFluidCollection,
			@ERSPancreaticMass,
			@ERSDilatedPancreatic,
			@ERSStonedBiliary,
			@ERSHepaticMass,
			@ERSObstructed,
			@ERSDilatedDucts,
			@AmpullaryMass,
			@GallBladderMass,
			@GallBladderPolyp,
			@BiliaryLeak,
			@ERSDilatedDuctsType1,
			@ERSDilatedDuctsType2,
			@ERSImgOthersTextBox,
			@EPlanCanunulate,
			@EplanManometry,
			@EplanStentremoval,
			@EplanCombinedProcedure,
			@EplanNasoPancreatic,
			@EplanStentReplacement,
			@EPlanEndoscopicCyst,
			@EplanPapillotomy,
			@EplanStoneRemoval,
			@EplanStentInsertion,
			@EplanStrictureDilatation,
			@EplanOthersTextBox,
			@ERSFollowPrevious,
			@ERSFollowCarriedOut,
			@ERSFollowBileDuct,
			@ERSFollowMalignancy,
			@ERSFollowBiliaryStricture,
			@ERSFollowStentReplacement,
			@PolypTumourAssess,
			@EMR,
			@EPlanNGTubeInsertion,
			@EPlanNGTubeRemoval,
			@LoggedInUserId,
			GETDATE())

		INSERT INTO ERS_RecordCount (
			[ProcedureId],
			[SiteId],
			[Identifier],
			[RecordCount]
		)
		VALUES (
			@ProcedureId,
			NULL,
			'Indications',
			1)
	END
ELSE
	BEGIN
		UPDATE 
			ERS_UpperGIIndications
		SET 
			Anaemia = @Anaemia,
			AnaemiaType = @AnaemiaType,
			AbdominalPain = @AbdominalPain,
			AbnormalCapsuleStudy = @AbnormalCapsuleStudy,
			AbnormalMRI = @AbnormalMRI,
			AbnormalityOnBarium = @AbnormalityOnBarium,
			ChestPain = @ChestPain,
			ChronicLiverDisease = @ChronicLiverDisease,
			CoffeeGroundsVomit = @CoffeeGroundsVomit,
			Diarrhoea = @Diarrhoea,
			DrugTrial = @DrugTrial,
			Dyspepsia = @Dyspepsia,
			DyspepsiaAtypical = @DyspepsiaAtypical,
			DyspepsiaUlcerType = @DyspepsiaUlcerType,			
			Dysphagia = @Dysphagia,
			Haematemesis = @Haematemesis,
			Melaena = @Melaena,
			NauseaAndOrVomiting = @NauseaAndOrVomiting,
			Odynophagia = @Odynophagia,
			PositiveTTG_EMA = @PositiveTTG,
			RefluxSymptoms = @RefluxSymptoms,
			UlcerExclusion = @UlcerExclusion,
			WeightLoss = @WeightLoss,
			PreviousHPyloriTest = @PreviousHPyloriTest,
			SerologyTest = @SerologyTest,
			SerologyTestResult = @SerologyTestResult,
			BreathTest = @BreathTest,
			BreathTestResult = @BreathTestResult,
			UreaseTest = @UreaseTest,
			UreaseTestResult = @UreaseTestResult,
			StoolAntigenTest = @StoolAntigenTest,
			StoolAntigenTestResult = @StoolAntigenTestResult,
			OpenAccess = @OpenAccess,
			OtherIndication = @OtherIndication,
			ClinicallyImpComments = @ClinicallyImpComments,
			UrgentTwoWeekReferral = @UrgentTwoWeekReferral,
			Cancer = @Cancer,
			WHOStatus = @WHOStatus,
			BariatricPreAssessment = @BariatricPreAssessment,
			BalloonInsertion = @BalloonInsertion,
			BalloonRemoval = @BalloonRemoval,
			SingleBalloonEnteroscopy = @SingleBalloonEnteroscopy,
			DoubleBalloonEnteroscopy = @DoubleBalloonEnteroscopy,
			PostBariatricSurgeryAssessment = @PostBariatricSurgeryAssessment,
			EUS = @EUS,
			GastrostomyInsertion = @GastrostomyInsertion,
			InsertionOfPHProbe = @InsertionOfPHProbe,
			JejunostomyInsertion = @JejunostomyInsertion,
			NasoDuodenalTube = @NasoDuodenalTube,
			OesophagealDilatation = @OesophagealDilatation,
			PEGRemoval = @PEGRemoval,
			PEGReplacement = @PEGReplacement,
			PushEnteroscopy = @PushEnteroscopy,
			SmallBowelBiopsy = @SmallBowelBiopsy,
			StentRemoval = @StentRemoval,
			StentInsertion = @StentInsertion,
			StentReplacement = @StentReplacement,
			EUSRefGuidedFNABiopsy = @EUSRefGuidedFNABiopsy,
			EUSOesophagealStricture = @EUSOesophagealStricture,
			EUSAssessmentOfSubmucosalLesion = @EUSAssessmentOfSubmucosalLesion,
			EUSTumourStagingOesophageal = @EUSTumourStagingOesophageal,
			EUSTumourStagingGastric = @EUSTumourStagingGastric,
			EUSTumourStagingDuodenal = @EUSTumourStagingDuodenal,
			OtherPlannedProcedure = @OtherPlannedProcedure,
			CoMorbidityNone = @CoMorbidityNone,
			Angina = @Angina,
			Asthma = @Asthma,
			COPD = @COPD,
			DiabetesMellitus = @DiabetesMellitus,
			DiabetesMellitusType = @DiabetesMellitusType,
			Epilepsy = @Epilepsy,
			HemiPostStroke = @HemiPostStroke,
			Hypertension = @Hypertension,
			MI = @MI,
			Obesity = @Obesity,
			TIA = @TIA,
			OtherCoMorbidity = @OtherCoMorbidity,
			ASAStatus = @ASAStatus,
			PotentiallyDamagingDrug = @PotentiallyDamagingDrug,
			Allergy = @Allergy,
			AllergyDesc = @AllergyDesc,
			CurrentMedication = @CurrentMedication,
			IncludeCurrentRxInReport = @IncludeCurrentRxInReport,
			SurgeryFollowUpProc = @SurgeryFollowUpProc,
			SurgeryFollowUpProcPeriod = @SurgeryFollowUpProcPeriod,
			SurgeryFollowUpText = @SurgeryFollowUpText,
			DiseaseFollowUpProc = @DiseaseFollowUpProc,
			DiseaseFollowUpProcPeriod = @DiseaseFollowUpProcPeriod,
			BarrettsOesophagus = @BarrettsOesophagus,
			CoeliacDisease = @CoeliacDisease,
			Dysplasia = @Dysplasia,
			Gastritis = @Gastritis,
			Malignancy = @Malignancy,
			OesophagealDilatationFollowUp = @OesophagealDilatationFollowUp,
			OesophagealVarices = @OesophagealVarices,
			Oesophagitis = @Oesophagitis,
			UlcerHealing = @UlcerHealing,
			ColonSreeningColonoscopy = @ColonSreeningColonoscopy,
			ColonBowelCancerScreening = @ColonBowelCancerScreening,
			ColonFOBT = @ColonFOBT,
			ColonFIT = @ColonFIT,
			ColonIndicationSurveillance = @ColonIndicationSurveillance,
			ColonAlterBowelHabit = @ColonAlterBowelHabit,
			NationalBowelScopeScreening = @NationalBowelScopeScreening,
			ColonRectalBleeding = @ColonRectalBleeding,
			ColonAnaemia = @ColonAnaemia,
			ColonAnaemiaType = @ColonAnaemiaType,
			ColonAbnormalCTScan = @ColonAbnormalCTScan,
			ColonAbnormalSigmoidoscopy = @ColonAbnormalSigmoidoscopy,
			ColonAbnormalBariumEnema  = @ColonAbnormalBariumEnema,
			ColonAbdominalMass = @ColonAbdominalMass,
			ColonDefaecationDisorder = @ColonDefaecationDisorder,
			ColonColonicObstruction =	@ColonColonicObstruction,
			ColonAbdominalPain =		@ColonAbdominalPain,
			ColonTumourAssessment =		@ColonTumourAssessment,
			ColonMelaena =				@ColonMelaena,
			ColonPolyposisSyndrome =	@ColonPolyposisSyndrome,
			ColonRaisedFaecalCalprotectin =	@ColonRaisedFaecalCalprotectin,
			ColonWeightLoss =			@ColonWeightLoss,
			ColonFamily =				@ColonFamily,
			ColonAssessment = @ColonAssessment,
			ColonSurveillance = @ColonSurveillance,
			ColonCarcinoma = @ColonCarcinoma,
			ColonPolyps = @ColonPolyps,
			ColonDysplasia = @ColonDysplasia,
			ColonFamilyType = @ColonFamilyType,
			ColonAssessmentType = @ColonAssessmentType,
			ColonFamilyAdditionalText = @ColonFamilyAdditionalText,
			ERSAbdominalPain = @ERSAbdominalPain,
			ERSChronicPancreatisis = @ERSChronicPancreatisis,
			ERSSphincter = @ERSSphincter,
			ERSAbnormalEnzymes = @ERSAbnormalEnzymes,
			ERSJaundice = @ERSJaundice,
			ERSStentOcclusion = @ERSStentOcclusion,
			ERSAcutePancreatitisAcute = @ERSAcutePancreatitisAcute,
			ERSObstructedCBD = @ERSObstructedCBD,
			ERSSuspectedPapillary = @ERSSuspectedPapillary,
			ERSBiliaryLeak = @ERSBiliaryLeak,
			ERSOpenAccess = @ERSOpenAccess,
			ERSCholangitis = @ERSCholangitis,
			ERSPrelaparoscopic = @ERSPrelaparoscopic,
			ERSRecurrentPancreatitis = @ERSRecurrentPancreatitis,
			ERSBileDuctInjury = @ERSBileDuctInjury,
			ERSPurulentCholangitis = @ERSPurulentCholangitis,
			ERSPancreaticPseudocyst = @ERSPancreaticPseudocyst,
			ERSPancreatobiliaryPain = @ERSPancreatobiliaryPain,
			ERSPapillaryDysfunction = @ERSPapillaryDysfunction,
			ERSPriSclerosingChol = @ERSPriSclerosingChol,
			ERSImgUltrasound = @ERSImgUltrasound,
			ERSImgCT = @ERSImgCT,
			ERSImgMRI = @ERSImgMRI,
			ERSImgMRCP = @ERSImgMRCP,
			ERSImgIDA = @ERSImgIDA,
			ERSImgEUS = @ERSImgEUS,
			ERSNormal = @ERSNormal,
			ERSChronicPancreatitis = @ERSChronicPancreatitis,
			ERSAcutePancreatitis = @ERSAcutePancreatitis,
			ERSGallBladder = @ERSGallBladder,
			ERSFluidCollection = @ERSFluidCollection,
			ERSPancreaticMass = @ERSPancreaticMass,
			ERSDilatedPancreatic = @ERSDilatedPancreatic,
			ERSStonedBiliary = @ERSStonedBiliary,
			ERSHepaticMass = @ERSHepaticMass,
			ERSObstructed = @ERSObstructed,
			ERSDilatedDucts = @ERSDilatedDucts,
			AmpullaryMass =  @AmpullaryMass,
			GallBladderMass = @GallBladderMass,
			GallBladderPolyp = @GallBladderPolyp,
			BiliaryLeak = @BiliaryLeak,
			ERSDilatedDuctsType1 = @ERSDilatedDuctsType1,
			ERSDilatedDuctsType2 = @ERSDilatedDuctsType2,
			ERSImgOthersTextBox = @ERSImgOthersTextBox,
			EPlanCanunulate = @EPlanCanunulate,
			EplanManometry = @EplanManometry,
			EplanStentremoval = @EplanStentremoval,
			EplanCombinedProcedure = @EplanCombinedProcedure,
			EplanNasoPancreatic = @EplanNasoPancreatic,
			EplanStentReplacement = @EplanStentReplacement,
			EPlanEndoscopicCyst = @EPlanEndoscopicCyst,
			EplanPapillotomy = @EplanPapillotomy,
			EplanStoneRemoval = @EplanStoneRemoval,
			EplanStentInsertion = @EplanStentInsertion,
			EplanStrictureDilatation = @EplanStrictureDilatation,
			EplanOthersTextBox = @EplanOthersTextBox,
			ERSFollowPrevious = @ERSFollowPrevious,
		   ERSFollowCarriedOut = @ERSFollowCarriedOut,
		   ERSFollowBileDuct = @ERSFollowBileDuct,
		   ERSFollowMalignancy = @ERSFollowMalignancy,
		   ERSFollowBiliaryStricture = @ERSFollowBiliaryStricture,
			ERSFollowStentReplacement = @ERSFollowStentReplacement,
			PolypTumourAssess = @PolypTumourAssess,	
			EMR = @EMR,
			EPlanNGTubeRemoval = @EPlanNGTubeRemoval,
			EPlanNGTubeInsertion = @EPlanNGTubeInsertion,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = GETDATE()
		WHERE 
			ProcedureId = @ProcedureId;

		IF NOT EXISTS (SELECT 1 FROM ERS_RecordCount WHERE ProcedureId = @ProcedureId AND Identifier = 'Indications')
		BEGIN
			INSERT INTO ERS_RecordCount (
			[ProcedureId],
			[SiteId],
			[Identifier],
			[RecordCount]
			)
			VALUES (
			@ProcedureId,
			NULL,
			'Indications',
			1)
		END
	END

END TRY

BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();
    
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH

IF @@TRANCOUNT > 0 COMMIT TRANSACTION;
GO

-----------------------------------------------------------------------------------------------------------
-- Bug 187 fix to Anaemia types on the report
-- Bug 188 Planned procedures for colon not on report
-- Bug 201 Incorrect Indication on report for 'Abdominal pain'
-- ERCP Procedure, if scan did not indicate anything, report <scanType> Imaging. 
-- Bug 202 some Planned Procedures not displaying for ERCP
-- bug 211 adding Defaecation disorder to the indications summary
EXEC DropIfExist 'ogd_indications_summary_update','S';
GO

CREATE PROCEDURE [dbo].[ogd_indications_summary_update]
(
       @ProcedureId INT
)
AS
       SET NOCOUNT ON

       DECLARE
              @summary VARCHAR(4000),
              @summaryTemp VARCHAR(4000),
              @Anaemia BIT,
              @AnaemiaType SMALLINT,
              @PreviousHPyloriTest BIT,
              @SerologyTest BIT,
              @SerologyTestResult TINYINT,
              @BreathTest BIT,
              @BreathTestResult TINYINT,
              @UreaseTest BIT,
              @UreaseTestResult TINYINT,
              @StoolAntigenTest BIT,
              @StoolAntigenTestResult TINYINT,
              @OpenAccess BIT,
              @OtherIndication NVARCHAR(1000),
              @ClinicallyImpComments NVARCHAR(4000),
              @UrgentTwoWeekReferral BIT,
              @Cancer INT,
              @WHOStatus SMALLINT,
			  @Diarrhoea BIT,			--
			  @PositiveTTG BIT,			--
			  @AmpullaryMass BIT,
			  @GallBladderMass BIT,
			  @GallBladderPolyp BIT,		--
              @EUSRefGuidedFNABiopsy BIT,
              @EUSOesophagealStricture BIT,
              @EUSAssessmentOfSubmucosalLesion BIT,
              @EUSTumourStagingOesophageal BIT,
              @EUSTumourStagingGastric BIT,
              @EUSTumourStagingDuodenal BIT,
              @OtherPlannedProcedure NVARCHAR(1000),
              @CoMorbidityNone BIT,
              @DiabetesMellitusType TINYINT,
              @OtherCoMorbidity NVARCHAR(1000),
              @ASAStatus TINYINT,
              @PotentiallyDamagingDrug NVARCHAR(1000),
              @Allergy TINYINT,
              @AllergyDesc NVARCHAR(1000),
              @CurrentMedication NVARCHAR(4000),
              @IncludeCurrentRxInReport BIT,
              @SurgeryFollowUpProc INT,
              @SurgeryFollowUpProcPeriod INT,
              @SurgeryFollowUpText NVARCHAR(1000),
              @DiseaseFollowUpProc INT,
              @DiseaseFollowUpProcPeriod INT,
              @ColonSreeningColonoscopy bit,
			  @ColonPolyposisSyndrome bit,
			  @ColonMelaena bit,
			  @ColonWeightLoss bit,
			  @ColonTumourAssessment bit,
			  @ColonRaisedFaecalCalprotectin bit,
              @ColonBowelCancerScreening bit,
              @ColonFOBT bit,
              @ColonIndicationsSurveillance bit,
              @ColonAlterBowelHabit int,
              @ColonRectalBleeding int,
              @ColonAnaemia bit,
              @ColonAnaemiaType int,
              @ColonAbnormalCTScan bit,
              @ColonAbnormalSigmoidoscopy bit,
              @ColonAbnormalBariumEnema bit,
              @ColonAbdominalMass bit,
			  @ColonDefaecationDisorder bit,
              @ColonColonicObstruction bit,
              @ColonAbdominalPain bit,
              @ColonFamily bit,
              @ColonAssessment bit,
              @ColonSurveillance bit,
              @ColonFamilyType int,
              @ColonAssessmentType int,
              @ColonFamilyAdditionalText varchar(7000),
              @ColonCarcinoma bit,
              @ColonPolyps bit,
              @ColonDysplasia bit,
              @ERSAbdominalPain bit,
              @ERSChronicPancreatisis bit,
              @ERSSphincter bit,
              @ERSAbnormalEnzymes bit,
              @ERSJaundice bit,
              @ERSStentOcclusion bit,
              @ERSAcutePancreatitisAcute bit,
              @ERSObstructedCBD bit,
              @ERSSuspectedPapillary bit,
              @ERSBiliaryLeak bit,
              @ERSOpenAccess bit,
              @ERSCholangitis bit,
              @ERSPrelaparoscopic bit,
              @ERSRecurrentPancreatitis bit,
			  @ERSBileDuctInjury bit,
			  @ERSPurulentCholangitis bit,
			  @ERSPancreaticPseudocyst bit,
			  @ERSPancreatobiliaryPain bit,
			  @ERSPapillaryDysfunction bit,
			  @ERSPriSclerosingChol bit,
              @ERSImgUltrasound bit,
              @ERSImgCT bit,
              @ERSImgMRI bit,
              @ERSImgMRCP bit,
              @ERSImgIDA bit,
              @ERSImgEUS bit,
              @ERSNormal bit,
              @ERSChronicPancreatitis bit,
              @ERSAcutePancreatitis bit,
              @ERSGallBladder bit,
              @ERSFluidCollection bit,
              @ERSPancreaticMass bit,
              @ERSDilatedPancreatic bit,
              @ERSStonedBiliary bit,
              @ERSHepaticMass bit,
              @ERSObstructed bit,
              @ERSDilatedDucts bit,
              @BiliaryLeak bit,
              @ERSDilatedDuctsType1 bit,
              @ERSDilatedDuctsType2 bit,
              @ERSImgOthersTextBox varchar(2000),
              @EPlanCanunulate bit,
              @EplanManometry bit,
              @EplanStentremoval bit,
              @EplanCombinedProcedure bit,
              @EplanNasoPancreatic bit,
              @EplanStentReplacement bit,
              @EPlanEndoscopicCyst bit,
              @EplanPapillotomy bit,
              @EplanStoneRemoval bit,
              @EplanStentInsertion bit,
              @EplanStrictureDilatation bit,
              @EplanOthersTextBox varchar(2000) ,
              @ERSFollowPrevious smallint ,
              @ERSFollowCarriedOut smallint ,
              @ERSFollowBileDuct bit ,
              @ERSFollowMalignancy bit,
              @ERSFollowBiliaryStricture bit,
              @ERSFollowStentReplacement bit,
			  @EPlanNGTubeInsertion bit,
			  @EPlanNGTubeRemoval bit,
			  @NationalBowelScopeScreening bit,
			  @StentRemoval bit,
			  @StentInsertion bit,
			  @StentReplacement bit, 
			  @PolypTumourAssess bit,
			  @EMR bit

       SELECT 
              @Anaemia=Anaemia,
              @AnaemiaType=AnaemiaType,
              @PreviousHPyloriTest=PreviousHPyloriTest,
              @SerologyTest=SerologyTest,
              @SerologyTestResult=SerologyTestResult,
              @BreathTest=BreathTest,
              @BreathTestResult=BreathTestResult,
              @UreaseTest=UreaseTest,
              @UreaseTestResult=UreaseTestResult,
              @StoolAntigenTest=StoolAntigenTest,
              @StoolAntigenTestResult=StoolAntigenTestResult,
              @OpenAccess=OpenAccess,
              @OtherIndication=OtherIndication,
              @ClinicallyImpComments=ClinicallyImpComments,
              @UrgentTwoWeekReferral=UrgentTwoWeekReferral,
              @Cancer=Cancer,
              @WHOStatus=WHOStatus,
			  @Diarrhoea = Diarrhoea,
			  @PositiveTTG = PositiveTTG_EMA,
			  @AmpullaryMass = AmpullaryMass,
			  @GallBladderMass = GallBladderMass,
			  @GallBladderPolyp = GallBladderPolyp,
              @EUSRefGuidedFNABiopsy=EUSRefGuidedFNABiopsy,
              @EUSOesophagealStricture=EUSOesophagealStricture,
              @EUSAssessmentOfSubmucosalLesion=EUSAssessmentOfSubmucosalLesion,
              @EUSTumourStagingOesophageal=EUSTumourStagingOesophageal,
              @EUSTumourStagingGastric=EUSTumourStagingGastric,
              @EUSTumourStagingDuodenal=EUSTumourStagingDuodenal,
              @OtherPlannedProcedure=OtherPlannedProcedure,
              @CoMorbidityNone=CoMorbidityNone,
              @DiabetesMellitusType=DiabetesMellitusType,
              @OtherCoMorbidity=OtherCoMorbidity,
              @ASAStatus=ASAStatus,
              @PotentiallyDamagingDrug=PotentiallyDamagingDrug,
              @Allergy=Allergy,
              @AllergyDesc=AllergyDesc,
              @CurrentMedication=CurrentMedication,
              @IncludeCurrentRxInReport=IncludeCurrentRxInReport,
              @SurgeryFollowUpProc=SurgeryFollowUpProc,
              @SurgeryFollowUpProcPeriod=SurgeryFollowUpProcPeriod,
              @SurgeryFollowUpText=SurgeryFollowUpText,
              @DiseaseFollowUpProc=DiseaseFollowUpProc,
              @DiseaseFollowUpProcPeriod=DiseaseFollowUpProcPeriod,
			  @ColonPolyposisSyndrome = ColonPolyposisSyndrome,
			  @ColonMelaena = ColonMelaena,
			  @ColonWeightLoss = ColonWeightLoss,
			  @ColonTumourAssessment = ColonTumourAssessment,
			  @ColonRaisedFaecalCalprotectin = ColonRaisedFaecalCalprotectin,
              @ColonSreeningColonoscopy=ColonSreeningColonoscopy, 
              @ColonBowelCancerScreening = ColonBowelCancerScreening,
              @ColonFOBT = ColonFOBT,
              @ColonAlterBowelHabit =ColonAlterBowelHabit, 
              @ColonRectalBleeding= ColonRectalBleeding,
              @ColonAnaemia =ColonAnaemia,
              @ColonAnaemiaType=ColonAnaemiaType,
              @ColonAbnormalCTScan = ColonAbnormalCTScan,
              @ColonAbnormalSigmoidoscopy = ColonAbnormalSigmoidoscopy,
              @ColonAbnormalBariumEnema = ColonAbnormalBariumEnema,
              @ColonAbdominalMass = ColonAbdominalMass,
			  @ColonDefaecationDisorder = ColonDefaecationDisorder,
              @ColonColonicObstruction = ColonColonicObstruction,
              @ColonAbdominalPain = ColonAbdominalPain,
              @ColonFamily = ColonFamily,
              @ColonAssessment= ColonAssessment,
              @ColonSurveillance =ColonSurveillance,
              @ColonFamilyType = ColonFamilyType,
              @ColonAssessmentType = ColonAssessmentType,
              @ColonFamilyAdditionalText = ColonFamilyAdditionalText,
              @ColonCarcinoma = ColonCarcinoma,
              @ColonPolyps = ColonPolyps,
              @ColonDysplasia =ColonDysplasia ,
              @ERSAbdominalPain=ERSAbdominalPain ,
              @ERSChronicPancreatisis=ERSChronicPancreatisis ,
              @ERSSphincter=ERSSphincter ,
              @ERSAbnormalEnzymes=ERSAbnormalEnzymes ,
              @ERSJaundice=ERSJaundice ,
              @ERSStentOcclusion=ERSStentOcclusion ,
              @ERSAcutePancreatitisAcute=ERSAcutePancreatitisAcute ,
              @ERSObstructedCBD=ERSObstructedCBD ,
              @ERSSuspectedPapillary=ERSSuspectedPapillary ,
              @ERSBiliaryLeak=ERSBiliaryLeak ,
              @ERSOpenAccess=ERSOpenAccess ,
              @ERSCholangitis=ERSCholangitis ,
              @ERSPrelaparoscopic=ERSPrelaparoscopic ,
              @ERSRecurrentPancreatitis=ERSRecurrentPancreatitis ,
			  @ERSBileDuctInjury=ERSBileDuctInjury,
			  @ERSPurulentCholangitis=ERSPurulentCholangitis,
			  @ERSPancreaticPseudocyst=ERSPancreaticPseudocyst,
			  @ERSPancreatobiliaryPain=ERSPancreatobiliaryPain,
			  @ERSPapillaryDysfunction=ERSPapillaryDysfunction,
			  @ERSPriSclerosingChol=ERSPriSclerosingChol,
              @ERSImgUltrasound=ERSImgUltrasound ,
              @ERSImgCT=ERSImgCT ,
              @ERSImgMRI=ERSImgMRI ,
              @ERSImgMRCP=ERSImgMRCP ,
              @ERSImgIDA=ERSImgIDA ,
              @ERSImgEUS=ERSImgEUS ,
              @ERSNormal=ERSNormal ,
              @ERSChronicPancreatitis=ERSChronicPancreatitis ,
              @ERSAcutePancreatitis=ERSAcutePancreatitis ,
              @ERSGallBladder=ERSGallBladder ,
              @ERSFluidCollection=ERSFluidCollection ,
              @ERSPancreaticMass=ERSPancreaticMass ,
              @ERSDilatedPancreatic=ERSDilatedPancreatic ,
              @ERSStonedBiliary=ERSStonedBiliary ,
              @ERSHepaticMass=ERSHepaticMass ,
              @ERSObstructed=ERSObstructed ,
              @ERSDilatedDucts=ERSDilatedDucts ,
              @BiliaryLeak = BiliaryLeak,
              @ERSDilatedDuctsType1=ERSDilatedDuctsType1,
              @ERSDilatedDuctsType2=ERSDilatedDuctsType2,
              @ERSImgOthersTextBox=ERSImgOthersTextBox,
              @EPlanCanunulate=EPlanCanunulate ,
              @EplanManometry=EplanManometry,
              @EplanStentremoval=EplanStentremoval,
              @EplanCombinedProcedure=EplanCombinedProcedure,
              @EplanNasoPancreatic=EplanNasoPancreatic,
              @EplanStentReplacement=EplanStentReplacement,
              @EPlanEndoscopicCyst=EPlanEndoscopicCyst,
              @EplanPapillotomy=EplanPapillotomy,
              @EplanStoneRemoval=EplanStoneRemoval,
              @EplanStentInsertion=EplanStentInsertion,
              @EplanStrictureDilatation=EplanStrictureDilatation,
              @EplanOthersTextBox=EplanOthersTextBox,
              @ERSFollowPrevious=ERSFollowPrevious ,
              @ERSFollowCarriedOut = ERSFollowCarriedOut ,
              @ERSFollowBileDuct = ERSFollowBileDuct ,
              @ERSFollowMalignancy = ERSFollowMalignancy,
              @ERSFollowBiliaryStricture  = ERSFollowBiliaryStricture,
              @ERSFollowStentReplacement = ERSFollowStentReplacement,
			  @EPlanNGTubeInsertion = EPlanNGTubeInsertion,
			  @EPlanNGTubeRemoval = EPlanNGTubeRemoval,
			  @ColonIndicationsSurveillance = ColonIndicationSurveillance,
			  @NationalBowelScopeScreening = NationalBowelScopeScreening,
			  @StentRemoval = StentRemoval,
			  @StentInsertion = StentInsertion,
			  @StentReplacement = StentReplacement,
			  @PolypTumourAssess = PolypTumourAssess,
			  @EMR = EMR
       FROM
              ERS_UpperGIIndications
       WHERE
              ProcedureId = @ProcedureId

       DECLARE @ProcType int
       DECLARE @tmpDiv TABLE(Val VARCHAR(MAX))

       SET @ProcType = (SELECT ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)

       SET @Summary = ''
       SET @summaryTemp = ''
		DELETE FROM @tmpDiv
       ------------------------------------------------------------------------
       --If procedure type is colonoscopy
       ------------------------------------------------------------------------
       IF @ProcType = 3 OR @ProcType=4
              BEGIN
               DECLARE @msg varchar(1000) =''
               DECLARE @Details varchar(1000) =''             
     
              IF @ColonAlterBowelHabit > 0  SET @msg = (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Indications Colon Altered Bowel Habit' AND [ListItemNo] = @ColonAlterBowelHabit)
              IF @ColonRectalBleeding > 0   
              BEGIN
				  IF @msg <> '' 
					SET @msg = @msg  + ' with ' +(SELECT LOWER([ListItemText]) FROM ERS_Lists WHERE ListDescription = 'Indications Colon Rectal Bleeding' AND [ListItemNo] = @ColonRectalBleeding) +' rectal bleeding'
				  ELSE 
					SET @msg = @msg +(SELECT LOWER([ListItemText]) FROM ERS_Lists WHERE ListDescription = 'Indications Colon Rectal Bleeding' AND [ListItemNo] = @ColonRectalBleeding) +' rectal bleeding'
              END

              INSERT INTO @tmpDiv (Val) VALUES(@msg)
              SET @msg=''
			  
			  IF	 @NationalBowelScopeScreening = 1 INSERT INTO @tmpDiv (Val) VALUES ('national bowel scope screening')
			  IF	 @ColonIndicationsSurveillance = 1 INSERT INTO @tmpDiv (Val) VALUES ('surveillance')
              IF     @ColonAbnormalCTScan =1 INSERT INTO @tmpDiv (Val) VALUES('abnormal CT scan')
			  IF	 @ColonPolyposisSyndrome = 1 INSERT INTO @tmpDiv (Val) VALUES('polyposis syndrome')
			  IF	 @ColonMelaena = 1 INSERT INTO @tmpDiv (Val) VALUES('melaena')
			  IF	 @ColonWeightLoss = 1 INSERT INTO @tmpDiv (Val) VALUES('weight loss')
			  IF	 @ColonTumourAssessment = 1 INSERT INTO @tmpDiv (Val) VALUES('tumour assessment')
			  IF	 @ColonRaisedFaecalCalprotectin = 1 INSERT INTO @tmpDiv (Val) Values('raised faecal calprotectin')
              IF     @ColonAbdominalMass =1 INSERT INTO @tmpDiv (Val) VALUES('abdominal mass')
			  IF	@ColonDefaecationDisorder = 1 INSERT INTO @tmpDiv (val) VALUES('defaecation disorder')
              IF     @ColonAbdominalPain =1 INSERT INTO @tmpDiv (Val) VALUES('abdominal pain')
              IF     @ColonAbnormalBariumEnema =1 INSERT INTO @tmpDiv (Val) VALUES('abnormal barium enema')
              IF     @ColonAbnormalSigmoidoscopy =1 INSERT INTO @tmpDiv (Val) VALUES('abnormal sigmoidoscopy')
              IF     @ColonAnaemia =1 
                     BEGIN
                     IF @ColonAnaemiaType = 1   INSERT INTO @tmpDiv (Val) VALUES('anaemia') 
                     ELSE IF @ColonAnaemiaType = 2     INSERT INTO @tmpDiv (Val) VALUES('microcytic anaemia') 
                     ELSE IF @ColonAnaemiaType = 3     INSERT INTO @tmpDiv (Val) VALUES('normocytic anaemia')
                     ELSE IF @ColonAnaemiaType = 4     INSERT INTO @tmpDiv (Val) VALUES('macrocytic anaemia')
                     ELSE INSERT INTO @tmpDiv (Val) VALUES('anaemia')
                     END
              IF     @ColonColonicObstruction =1 INSERT INTO @tmpDiv (Val) VALUES('colonic obstruction')
              IF @OtherIndication <> '' INSERT INTO @tmpDiv (Val) VALUES(@OtherIndication)

			  IF @StentRemoval = 1 INSERT INTO @tmpDiv (Val) VALUES ('stent removal')
			  IF @StentInsertion = 1 INSERT INTO @tmpDiv (Val) VALUES ('stent insertion')
			  IF @StentReplacement = 1 INSERT INTO @tmpDiv (Val) VALUES ('stent replacement') 
			  IF @PolypTumourAssess = 1 INSERT INTO @tmpDiv (Val) VALUES ('polyp/tumour assessment')
			  IF @EMR = 1 INSERT INTO @tmpDiv (Val) VALUES ('EMR')	
              
              DECLARE @Urgent varchar(3000) = '' , @CarIndic varchar(1000) =''
              IF @UrgentTwoWeekReferral = 1 SET @Urgent = 'urgent two week referral'
              IF @Cancer = 1 SET @CarIndic= 'definite cancer'
              ELSE IF @Cancer = 2 SET @CarIndic= 'suspected cancer'
              ELSE IF @Cancer = 3 SET @CarIndic= 'cancer excluded'

              IF @CarIndic <> ''
              BEGIN
              IF @Urgent = '' SET @Urgent = dbo.fnFirstLetterUpper(@CarIndic)
              ELSE SET @Urgent = @Urgent + ' - ' + @CarIndic
              END
              
              IF @WHOStatus <> null AND @WHOStatus >= 0
              BEGIN
              --Add full stop 
                     SET @Urgent = RTrim(LTRIM(@Urgent))
                     IF @Urgent <> ''  AND (@Urgent NOT LIKE '%.')  SET @Urgent = @Urgent + '. </br>'

                     SET @Urgent =  @Urgent + ' WHO performance status ' + cast(@WHOStatus as varchar(50))
              END

       IF @Urgent <> ''  AND (@Urgent NOT LIKE '%.')  SET @Urgent = @Urgent + '. </br>'
       IF @Urgent<>'' SET @msg = @Urgent
              IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
              BEGIN
              DECLARE @XMLlist XML
                     SET @XMLlist = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
                     SET @Details = dbo.fnBuildString(@XMLlist)
                     DELETE FROM @tmpDiv
              END  
         
       IF @Details <> ''
       BEGIN
         SET @Details= dbo.fnFirstLetterUpper(RTrim(LTRIM(@Details)))
         IF (@Details NOT LIKE '%.')  SET @Details = @Details + '.'
         SET @details =@details + '</br>'
         END

       DECLARE @FOBT varchar(1000) =''
       IF @ColonFOBT = 1 SET @FOBT = 'FOBT'

       DECLARE @ScreenColon varchar(5000) =''
       IF @ColonSreeningColonoscopy =1
              BEGIN
              IF @FOBT <> '' SET @ScreenColon = 'screening colonoscopy  and ' + @FOBT + '.' + '</br>'
              ELSE SET @ScreenColon = 'screening colonoscopy.' + '</br>'
              END
       IF @ColonBowelCancerScreening = 1 
              BEGIN
              IF @FOBT <> '' SET @ScreenColon = @ScreenColon + 'bowel cancer screening programme (' + @FOBT +') </br>'
              ELSE SET @ScreenColon =@ScreenColon + 'bowel cancer screening programme. </br>'
              END
       IF @ScreenColon ='' AND @FOBT<>''
              BEGIN
              SET @ScreenColon = @FOBT + '.' + '</br>'
              END
              
		  

       DECLARE @A varchar(500) ='' , @FamHistory Varchar(5000) = '' , @FollUp varchar(5000) = ''
       If  @ColonFamily = 1
              BEGIN         
              IF @ColonFamilyType = 1 SET @A = @A+ 'risk unknown'
              ELSE IF @ColonFamilyType = 2 SET @A = @A+ 'no risk'
              ELSE IF @ColonFamilyType = 3 SET @A = @A+ 'familial adenomatous polyposis'
              ELSE IF @ColonFamilyType = 4 SET @A = @A+ 'family history of colorectal cancer'
              ELSE IF @ColonFamilyType = 5 SET @A = @A+ 'hereditary non-polyposis colorectal cancer'
              ELSE IF @ColonFamilyType = 6 SET @A = @A+ 'gene carrier, hereditary non-polyposis colorectal cancer'
              END
       IF @ColonFamilyAdditionalText <> '' SET @A = @A + '(' +@ColonFamilyAdditionalText +')'

       IF @A <> ''   SET @FamHistory = 'family history taken: ' + @A + '. </br>' 

       IF @SurgeryFollowUpText<> '' SET @FollUp = @SurgeryFollowUpText + '. </br>'

       DECLARE @B varchar(1000) = ''

       --IF @ColonAssessmentType  = 0
       --     BEGIN
       --     SET @B ='colitis'
       --     IF @ColonAssessment = 1 SET @B = @B + ' assessment'
       --     IF @ColonAssessment = 1 AND @ColonSurveillance = 1 SET @B = @B + ' and surveillance'
       --     ELSE IF @ColonSurveillance = 1 SET @B = @B + ' surveillance'
       --     END
       --ELSE 
       IF @ColonAssessmentType  > 0
       BEGIN
              SET @B='inflammatory bowel disease'
              IF @ColonAssessment = 1 
				SET @B = @B + ' assessment'
              IF @ColonAssessment = 1 AND @ColonSurveillance = 1 
				SET @B = @B + ' and surveillance'
              ELSE IF @ColonSurveillance = 1 
				SET @B = @B + ' surveillance'
              IF @ColonAssessmentType = 2 
				SET @B =   @B + '(Crohn''s)'
              ELSE IF @ColonAssessmentType = 3 
				SET @B =   @B + '(Ulcerative Colitis)'
       END

       DECLARE @D VArchar(3000) =''
       IF @ColonCarcinoma = 1 INSERT INTO @tmpDiv (Val) VALUES('carcinoma')
       IF @ColonPolyps = 1 INSERT INTO @tmpDiv (Val) VALUES('polyps')
       IF @ColonDysplasia = 1 INSERT INTO @tmpDiv (Val) VALUES('dysplasia')
       IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
              BEGIN
                     SET @XMLlist = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
                     SET @D = dbo.fnBuildString(@XMLlist)
                     DELETE FROM @tmpDiv
              END    
       IF @D <> ''
       BEGIN
		   IF @B <> '' 
				SET @B = @B + ' and previous ' + RTrim(LTRIM(@D))
		   ELSE 
				SET @B = dbo.fnFirstLetterUpper('previous ' + RTrim(LTRIM(@D)))
       END

       Declare @clinicalComment varchar(5000) =''
       If @ClinicallyImpComments<> '' SET @clinicalComment = 'Clinical important comments: ' +@ClinicallyImpComments
       IF @clinicalComment <> ''  AND (@clinicalComment NOT LIKE '%.')  SET @clinicalComment = dbo.fnFirstLetterUpper(@clinicalComment) + '. </br>'

       Declare @damagingDrug varchar(5000) =''
       If @PotentiallyDamagingDrug <> '' SET @damagingDrug = 'Potential damaging drug: ' +@PotentiallyDamagingDrug
       IF @damagingDrug <> ''  AND (@damagingDrug NOT LIKE '%.')  SET @damagingDrug = dbo.fnFirstLetterUpper(@damagingDrug) + '.</br>'

         Declare @allerg varchar(5000) =''
         IF @Allergy = 1 SET @allerg = @allerg + 'uknown'
              ELSE IF @Allergy = 2 SET @allerg = @allerg + 'none'
              ELSE IF @Allergy = 3 
              BEGIN
                     IF @AllergyDesc = '' SET @allerg = @allerg + 'unspecified'
                     ELSE SET @allerg = @allerg + @AllergyDesc
              END
       If @Allerg <> '' SET @allerg = 'allergy: ' +@allerg
       IF @allerg <> ''  AND (@allerg NOT LIKE '%.')  SET @allerg = dbo.fnFirstLetterUpper(@allerg) + '. </br>'
       

       ------------------------------------------------------------------
       --CO-MORBIDITY
       ------------------------------------------------------------------
       DECLARE @CoMordi varchar(1000) = ''

       SELECT 
              CoMorbidityItem,
              CASE CoMorbidityItem 
					 WHEN 'Angina' THEN 'angina'
					 WHEN 'Asthma' THEN 'asthma'
					 WHEN 'COPD' THEN 'COPD'
					 WHEN 'DiabetesMellitus' THEN 'diabetes mellitus**'
					 WHEN 'Epilepsy' THEN 'epilepsy'
					 WHEN 'HemiPostStroke' THEN 'hemi post stroke'
					 WHEN 'Hypertension' THEN 'hypertension'
					 WHEN 'MI' THEN 'MI'
					 WHEN 'Obesity' THEN 'obesity'
					 WHEN 'TIA' THEN 'TIA'
                     ELSE CoMorbidityItem 
              END AS CoMorbidityItemDesc, 
              Selected
              INTO #coMorbidity1
       FROM 
       (SELECT * FROM ERS_UpperGIIndications WHERE ProcedureId = @ProcedureId) a
       UNPIVOT
       (      Selected 
              FOR CoMorbidityItem IN (Angina, Asthma, COPD, DiabetesMellitus, Epilepsy, HemiPostStroke, Hypertension, MI, Obesity, TIA)
       ) b
       WHERE Selected = 1

       IF (SELECT COUNT(*) FROM #coMorbidity1) > 0
       BEGIN
              -- Get the concatenated string separated by a delimiter, say $$
              SELECT @CoMordi = COALESCE (
                                                CASE WHEN @CoMordi = '' THEN CoMorbidityItemDesc
                                                ELSE @CoMordi + '$$' + CoMorbidityItemDesc END
                                         ,'')
              FROM #coMorbidity1

              IF @OtherCoMorbidity <> '' SET @CoMordi = @CoMordi + '$$' + @OtherCoMorbidity

              -- Set the last occurence of $$ to "and"
              IF CHARINDEX('$$', @CoMordi) > 0 SET @CoMordi = STUFF(@CoMordi, len(@CoMordi) - charindex('$$', reverse(@CoMordi)), 2, ' and ')
              -- Replace all other occurences of $$ with commas
              IF CHARINDEX('$$', @CoMordi) > 0 SET @CoMordi = REPLACE(@CoMordi, '$$', ', ')
       END

       IF CHARINDEX('**', @CoMordi) > 0
       BEGIN
              IF @DiabetesMellitusType = 0 SET @CoMordi = REPLACE(@CoMordi, '**', '')
              ELSE IF @DiabetesMellitusType = 1 SET @CoMordi = REPLACE(@CoMordi, '**', ' (unknown)')
              ELSE IF @DiabetesMellitusType = 2 SET @CoMordi = REPLACE(@CoMordi, '**', ' (type 1)')
              ELSE IF @DiabetesMellitusType = 3 SET @CoMordi = REPLACE(@CoMordi, '**', ' (type 2)')
       END

       --finally, add to the main summary field
       IF @CoMordi <> '' SET @CoMordi = 'Co-morbidity: ' + @CoMordi + '. </br>'

       
       DECLARE @ASAstat varchar(1000)=''
              ------------------------------------------------------------------
       --ASA STATUS
       ------------------------------------------------------------------
       IF @ASAStatus IS NOT NULL
       BEGIN
       SET @ASAstat = 'ASA status: '
              IF @ASAStatus = 0 SET @ASAstat = @ASAstat + 'not assessed'
              ELSE IF @ASAStatus = 1 SET @ASAstat = @ASAstat + 'ASA I - patient is normal and healthy'
              ELSE IF @ASAStatus = 2 SET @ASAstat = @ASAstat + 'ASA II - patient has mild systemic disease'
              ELSE IF @ASAStatus = 3 SET @ASAstat = @ASAstat + 'ASA III - patient has severe systemic disease'
              ELSE IF @ASAStatus = 4 SET @ASAstat = @ASAstat + 'ASA IV - patient has severe systemic disease that is a constant threat to life'
              ELSE IF @ASAStatus = 5 SET @ASAstat = @ASAstat + 'ASA V - patient is moribund and is not expected to survive without the procedure/operation'
       END
       SET @ASAstat = @ASAstat +  '. </br>'
		SET @B = dbo.fnFirstLetterUpper(@B)
        IF @B <> ''  AND (@B NOT LIKE '%.') SET @B= @B + '.<br/>'
       SET @summary = (CASE WHEN @summary= '' THEN @summary ELSE @summary + '</br>' END) +       
						dbo.fnFirstLetterUpper(@ScreenColon)+ dbo.fnFirstLetterUpper(@FamHistory) + dbo.fnFirstLetterUpper(@FollUp) +  
						dbo.fnFirstLetterUpper(@B) + dbo.fnFirstLetterUpper(@msg) + dbo.fnFirstLetterUpper(@details) + 
						dbo.fnFirstLetterUpper(@damagingDrug) + dbo.fnFirstLetterUpper(@allerg) + dbo.fnFirstLetterUpper(@CoMordi)+ 
						dbo.fnFirstLetterUpper(@ASAstat) + dbo.fnFirstLetterUpper(@clinicalComment)
END
ELSE IF @ProcType= 2 OR @ProcType=7
BEGIN
       ------------------------------------------------------------------
       --URGENT/CANCER
       ------------------------------------------------------------------
       IF @UrgentTwoWeekReferral = 1
       BEGIN
              SET @Summary = 'urgent two week referral'
              
              IF @Cancer = 1 SET @Summary = @Summary + ' - definite cancer'
              ELSE IF @Cancer = 2 SET @Summary = @Summary + ' - suspected cancer'
              ELSE IF @Cancer = 3 SET @Summary = @Summary + ' - excluded cancer'

              IF @WHOStatus > 0 SET @Summary = @Summary + '. WHO performance status ' + CONVERT(VARCHAR(1), @WHOStatus)
       END

       ------------------------------------------------------------------
       --INDICATIONS
       ------------------------------------------------------------------
       SET @summaryTemp = ''
          DECLARE @ms varchar(max)=''

                    IF @ERSAbdominalPain=1 INSERT INTO @tmpDiv (Val) VALUES('abdominal pain')
                    IF @ERSAbnormalEnzymes=1 INSERT INTO @tmpDiv (Val) VALUES('abnormal enzymes')
                    IF @ERSAcutePancreatitisAcute=1 INSERT INTO @tmpDiv (Val) VALUES('acute pancreatitis')
					--IF @AmpullaryMass=1 INSERT INTO @tmpDiv (Val) VALUES('ampullary mass');	--## New
                    IF @ERSCholangitis=1 INSERT INTO @tmpDiv (Val) VALUES('cholangitis')
                    IF @ERSChronicPancreatisis=1 INSERT INTO @tmpDiv (Val) VALUES('chronic pancreatitis')
                    IF @ERSBiliaryLeak=1 INSERT INTO @tmpDiv (Val) VALUES('biliary leak')
					IF @GallBladderMass=1 INSERT INTO @tmpDiv (Val) VALUES('gall bladder mass');		--##
					IF @GallBladderPolyp=1 INSERT INTO @tmpDiv (Val) VALUES('gall bladder polyp');		--##
                    IF @ERSJaundice=1 INSERT INTO @tmpDiv (Val) VALUES('jaundice')
                    IF @ERSOpenAccess=1 INSERT INTO @tmpDiv (Val) VALUES('open access')               
                    IF @ERSPrelaparoscopic=1 INSERT INTO @tmpDiv (Val) VALUES('pre-laparoscopic cholecystectomy')
                    IF @ERSRecurrentPancreatitis=1 INSERT INTO @tmpDiv (Val) VALUES('recurrent pancreatitis')
					IF @ERSBileDuctInjury=1 INSERT INTO @tmpDiv (Val) VALUES('bile duct injury')
					IF @OpenAccess = 1 INSERT INTO @tmpDiv (Val) VALUES('open access')
					IF @ERSPurulentCholangitis=1 INSERT INTO @tmpDiv (Val) VALUES('purulent cholangitis')
					IF @ERSPancreaticPseudocyst=1 INSERT INTO @tmpDiv (Val) VALUES('pancreatic pseudocyst')
					IF @ERSPancreatobiliaryPain=1 INSERT INTO @tmpDiv (Val) VALUES('pancreatobiliary pain')
					IF @ERSPapillaryDysfunction=1 INSERT INTO @tmpDiv (Val) VALUES('papillary dysfunction')
					IF @ERSPriSclerosingChol=1 INSERT INTO @tmpDiv (Val) VALUES('primary sclerosing cholangitis')

                    IF @ERSSphincter=1 INSERT INTO @tmpDiv (Val) VALUES('sphincter of Oddi dysfunction')        
                    IF @ERSStentOcclusion=1 INSERT INTO @tmpDiv (Val) VALUES('stent occlusion')
                    IF @ERSSuspectedPapillary=1 INSERT INTO @tmpDiv (Val) VALUES('suspected papillary stenosis')
                    IF @OtherIndication<> '' INSERT INTO @tmpDiv (Val) VALUES(@OtherIndication)
                    IF @ERSObstructedCBD=1 INSERT INTO @tmpDiv (Val) VALUES('obstructed CBD/CHD')
					IF @PolypTumourAssess = 1 INSERT INTO @tmpDiv (Val) VALUES ('polyp/tumour assessment')
					IF @EMR = 1 INSERT INTO @tmpDiv (Val) VALUES ('EMR')			  

                     
                      IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
              BEGIN
              DECLARE @XMLlis XML
                     SET @XMLlis = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
                     SET @ms = dbo.fnBuildString(@XMLlis)
                     DELETE FROM @tmpDiv
              END  
              SET @summaryTemp = @summaryTemp + @ms       
       --finally, add to the main summary field
       IF @summaryTemp <> ''
       BEGIN
              IF @summary = '' SET @summary = dbo.fnFirstLetterUpper(@summaryTemp)
              ELSE SET @summary = @summary + '. <br />' + dbo.fnFirstLetterUpper(@summaryTemp)
       END

          ------------------------------------------------------------------------
          --IMAGING
          ------------------------------------------------------------------------
           DECLARE @mt varchar(max)=''
              DELETE FROM @tmpDiv
              SET @ms = ''
						   
                           IF @ERSImgUltrasound =1 INSERT INTO @tmpDiv (Val) VALUES('ultrasound')
                           IF @ERSImgCT =1 INSERT INTO @tmpDiv (Val) VALUES('CT')
                           IF @ERSImgMRI =1 INSERT INTO @tmpDiv (Val) VALUES('MRI')
                           IF @ERSImgMRCP =1 INSERT INTO @tmpDiv (Val) VALUES('MRCP')
                           IF @ERSImgIDA =1 INSERT INTO @tmpDiv (Val) VALUES('IDA isotope scan')
                           IF @ERSImgEUS =1 INSERT INTO @tmpDiv (Val) VALUES('EUS')
              IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
              BEGIN
              DECLARE @XMLli XML
                     SET @XMLli = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
                     SET @ms = dbo.fnBuildString(@XMLli)
                     DELETE FROM @tmpDiv
              END

              SET @mt = @ms  

              DELETE FROM @tmpDiv
              SET @ms = ''
                     IF     @ERSNormal = 1 SET @mt = @mt + ' images were normal'
                     ELSE
                           BEGIN
						   IF @AmpullaryMass = 1 INSERT INTO @tmpDiv (Val) VALUES('ampullary mass')
                           IF @ERSChronicPancreatitis =1 INSERT INTO @tmpDiv (Val) VALUES('chronic pancreatitis')
                           IF @ERSPancreaticMass =1 INSERT INTO @tmpDiv (Val) VALUES('pancreatic mass')
                           IF @ERSHepaticMass =1 INSERT INTO @tmpDiv (Val) VALUES('hepatic mass')
                           IF @BiliaryLeak=1  INSERT INTO @tmpDiv (Val) VALUES('biliary leak')
                           IF @ERSAcutePancreatitis =1 INSERT INTO @tmpDiv (Val) VALUES('acute pancreatitis')
                           IF @ERSDilatedPancreatic =1 INSERT INTO @tmpDiv (Val) VALUES('dilated pancreatic duct')
                           IF @ERSDilatedDucts =1
                                  BEGIN 
                                  IF @ERSDilatedDuctsType1 =1 INSERT INTO @tmpDiv (Val) VALUES('dilated extrahepatic ducts')
                                  IF @ERSDilatedDuctsType2 = 1 INSERT INTO @tmpDiv (Val) VALUES('dilated intrahepatic ducts')
                                  IF @ERSDilatedDuctsType1 <>1 AND @ERSDilatedDuctsType2 <> 1 INSERT INTO @tmpDiv (Val) VALUES('dilated bile ducts')
                                  END
                           IF @ERSStonedBiliary =1 INSERT INTO @tmpDiv (Val) VALUES('stone(s) in biliary tree')
                           IF @ERSGallBladder =1 INSERT INTO @tmpDiv (Val) VALUES('gall bladder stone(s)')
                           IF @ERSFluidCollection =1 INSERT INTO @tmpDiv (Val) VALUES('fluid collection')               
                           IF @ERSImgOthersTextBox <> '' INSERT INTO @tmpDiv (Val) VALUES(@ERSImgOthersTextBox)                    
                           IF @ERSObstructed =1 INSERT INTO @tmpDiv (Val) VALUES('obstructed CBD/CHD')
                           
                     IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
              BEGIN
              DECLARE @XMLl XML
                     SET @XMLl = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
                     SET @ms = dbo.fnBuildString(@XMLl)
                     DELETE FROM @tmpDiv
              END
               IF @mt <> ''
			   BEGIN
					IF @MS <> '' 
						SET @mt =LTRIM(RTRIM( @mt + ' imaging revealed ' +@ms))
					ELSE
						SET @mt =LTRIM(RTRIM( @mt + ' imaging'))
					IF @summary = '' 
						SET @summary = dbo.fnFirstLetterUpper(@mt)
					ELSE 
						SET @summary = @summary + '. <br />' + dbo.fnFirstLetterUpper(@mt)
			   END
                           

       END
       -----------------------------------------------------------------------
       --FOLLOW UP
       -----------------------------------------------------------------------
       DELETE FROM @tmpDiv
       DECLARE @ao varchar(max) ='',     @bo varchar(max)='' , @co varchar(max)='', @to varchar(max)=''            

       IF @ERSFollowPrevious > 0 
	   BEGIN
			SET @ao = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription = 'follow up disease/proc ERCP' AND  ListItemNo = @ERSFollowPrevious),'')
			SET @bo =  (SELECT CASE @ERSFollowCarriedOut 
              WHEN 1 THEN ' within the last month'
              WHEN 2 THEN  ' one to two months ago'
              WHEN 3 THEN  ' three to four months ago'
              WHEN 4 THEN  ' five to six months ago'
              WHEN 5 THEN ' seven to twelve months ago'
              WHEN 6 THEN ' one to three years ago'
              WHEN 7 THEN ' more than three years ago' END)

                           IF @ERSFollowBileDuct = 1 INSERT INTO @tmpDiv (Val) VALUES('bile duct stone(s)')
                           IF @ERSFollowMalignancy =1 INSERT INTO @tmpDiv (Val) VALUES('malignancy')
                           IF @ERSFollowBiliaryStricture = 1 INSERT INTO @tmpDiv (Val) VALUES('biliary stricture')
                           IF @ERSFollowStentReplacement= 1 INSERT INTO @tmpDiv (Val) VALUES('stent replacement')

                           IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
                                    BEGIN
                                    DECLARE @XMLo XML
                                                SET @XMLo = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
                                                SET @co = dbo.fnBuildString(@XMLo)
                                                DELETE FROM @tmpDiv
                                    END
              IF @ao IS NOT NULL AND @ao <> '' SET @to = 'a previous '+ @ao ELSE SET @to= 'a previous examination '
              IF @bo IS NOT NULL AND @bo <> '' SET @to = @to + @bo
              IF @co IS NOT NULL AND  @co <> '' SET @to = @to + ' for ' + @co
              IF @summary = '' SET @summary = dbo.fnFirstLetterUpper(@to)
                ELSE SET @summary = @summary + '. <br />' + dbo.fnFirstLetterUpper(@to)
       END    
       ------------------------------------------------------------------
       ---PLANNED PROCEDURES
       ------------------------------------------------------------------
       DELETE FROM @tmpDiv
       SET @ms = ''
                     IF @EplanPapillotomy=1 INSERT INTO @tmpDiv (Val) VALUES('papillotomy/sphincterotomy')
                     IF @EPlanCanunulate=1 INSERT INTO @tmpDiv (Val) VALUES('cannulate and opacify the biliary tree')
                     IF @EplanStentremoval=1 INSERT INTO @tmpDiv (Val) VALUES('stent removal')
                     IF @EplanStentInsertion=1 INSERT INTO @tmpDiv (Val) VALUES('stent insertion')
                     IF @EplanStentReplacement=1 INSERT INTO @tmpDiv (Val) VALUES('stent replacement')
                     IF @EplanStoneRemoval=1 INSERT INTO @tmpDiv (Val) VALUES('stone removal')
                     IF @EplanNasoPancreatic=1 INSERT INTO @tmpDiv (Val) VALUES('naso-pancreatic/biliary drains')
                     IF @EPlanEndoscopicCyst=1 INSERT INTO @tmpDiv (Val) VALUES('endoscopic cyst puncture')
                           IF @EplanCombinedProcedure=1 INSERT INTO @tmpDiv (Val) VALUES('combined procedure (Rendezvous)')   
                     IF @EplanStrictureDilatation=1 INSERT INTO @tmpDiv (Val) VALUES('stricture dilatation')
                     IF @EplanManometry=1 INSERT INTO @tmpDiv (Val) VALUES('manometry')
                           IF @EplanOthersTextBox <> '' INSERT INTO @tmpDiv (Val) VALUES(@EplanOthersTextBox)
                           DECLARE @l int =0
                           IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
                             BEGIN
                             DECLARE @XMLi XML
                           SET @l = (SELECT COUNT(Val) FROM @tmpDiv)
                                         SET @XMLi = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
                                         SET @ms = dbo.fnBuildString(@XMLi)
                                         DELETE FROM @tmpDiv
                             END
       
                     IF @ms <> ''
                        BEGIN
                        SET @ms = CASE WHEN @l > 1 THEN 'Planned procedures: ' ELSE 'Planned procedure: ' END + LTRIM(RTRIM(dbo.fnFirstLetterUpper(@ms)))
                                    IF @summary = '' SET @summary = @ms
                                    ELSE SET @summary = @summary + '. <br />' + @ms
                        END
              
              ------------------------------------------------------------------
       --CO-MORBIDITY
       ------------------------------------------------------------------
       SET @summaryTemp = ''
           SELECT 
              CoMorbidityItem,
              CASE CoMorbidityItem 
					 WHEN 'Angina' THEN 'angina'
					 WHEN 'Asthma' THEN 'asthma'
					 WHEN 'COPD' THEN 'COPD'
					 WHEN 'DiabetesMellitus' THEN 'diabetes mellitus**'
					 WHEN 'Epilepsy' THEN 'epilepsy'
					 WHEN 'HemiPostStroke' THEN 'hemi post stroke'
					 WHEN 'Hypertension' THEN 'hypertension'
					 WHEN 'MI' THEN 'MI'
					 WHEN 'Obesity' THEN 'obesity'
					 WHEN 'TIA' THEN 'TIA'
                     ELSE CoMorbidityItem 
              END AS CoMorbidityItemDesc, 
              Selected
              INTO #ecoMorbidity
       FROM 
       (SELECT * FROM ERS_UpperGIIndications WHERE ProcedureId = @ProcedureId) a
       UNPIVOT
       (      Selected 
              FOR CoMorbidityItem IN (Angina, Asthma, COPD, DiabetesMellitus, Epilepsy, HemiPostStroke, Hypertension, MI, Obesity, TIA)
       ) b
       WHERE Selected = 1

       IF (SELECT COUNT(*) FROM #ecoMorbidity) > 0
       BEGIN
              -- Get the concatenated string separated by a delimiter, say $$
              SELECT @summaryTemp = COALESCE (
                                                CASE WHEN @summaryTemp = '' THEN CoMorbidityItemDesc
                                                ELSE @summaryTemp + '$$' + CoMorbidityItemDesc END
                                         ,'')
              FROM #ecoMorbidity

              


       END
	   
	   IF @OtherCoMorbidity <> '' 
			IF @summaryTemp <> '' 
				SET @summaryTemp = @summaryTemp + '$$' + @OtherCoMorbidity
			ELSE
				SET @summaryTemp = @summaryTemp + @OtherCoMorbidity
	    -- Set the last occurence of $$ to "and"
        IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = STUFF(@summaryTemp, len(@summaryTemp) - charindex('$$', reverse(@summaryTemp)), 2, ' and ')
        -- Replace all other occurences of $$ with commas
        IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = REPLACE(@summaryTemp, '$$', ', ')
       IF CHARINDEX('**', @summaryTemp) > 0
       BEGIN
              IF @DiabetesMellitusType = 0 SET @summaryTemp = REPLACE(@summaryTemp, '**', '')
              ELSE IF @DiabetesMellitusType = 1 SET @summaryTemp = REPLACE(@summaryTemp, '**', ' (unknown)')
              ELSE IF @DiabetesMellitusType = 2 SET @summaryTemp = REPLACE(@summaryTemp, '**', ' (type 1)')
              ELSE IF @DiabetesMellitusType = 3 SET @summaryTemp = REPLACE(@summaryTemp, '**', ' (type 2)')
       END

       --finally, add to the main summary field
       IF @summaryTemp <> ''
       BEGIN
              IF @summary = '' SET @summary = 'Co-morbidity: ' + @summaryTemp
              ELSE SET @summary = @summary + '. <br />Co-morbidity: ' + @summaryTemp
       END

   ------------------------------------------------------------------
       --ASA STATUS
       ------------------------------------------------------------------
       IF @ASAStatus IS NOT NULL
       BEGIN
              IF @summary <> '' SET @summary = @summary + '. <br />ASA status: '
              ELSE SET @summary = @summary + 'ASA status: '

              IF @ASAStatus = 0 SET @summary = @summary + 'Not assessed'
              ELSE IF @ASAStatus = 1 SET @summary = @summary + 'ASA I - patient is normal and healthy'
              ELSE IF @ASAStatus = 2 SET @summary = @summary + 'ASA II - patient has mild systemic disease'
              ELSE IF @ASAStatus = 3 SET @summary = @summary + 'ASA III - patient has severe systemic disease'
              ELSE IF @ASAStatus = 4 SET @summary = @summary + 'ASA IV - patient has severe systemic disease that is a constant threat to life'
              ELSE IF @ASAStatus = 5 SET @summary = @summary + 'ASA V - patient is moribund and is not expected to survive without the procedure/operation'
       END

     ------------------------------------------------------------------
       --Important COMMENTS
       ------------------------------------------------------------------
       IF @ClinicallyImpComments <> ''
              IF @summary = '' SET @summary = @ClinicallyImpComments
              ELSE SET @summary = @summary + '. <br />Clinically important comments: ' + @ClinicallyImpComments

END
ELSE
       BEGIN
       ------------------------------------------------------------------
       --URGENT/CANCER
       ------------------------------------------------------------------
       IF @UrgentTwoWeekReferral = 1
       BEGIN
              SET @Summary = 'Urgent two week referral'
              
              IF @Cancer = 1 SET @Summary = @Summary + ' - definite cancer'
              ELSE IF @Cancer = 2 SET @Summary = @Summary + ' - suspected cancer'
              ELSE IF @Cancer = 3 SET @Summary = @Summary + ' - excluded cancer'

              IF @WHOStatus > 0 SET @Summary = @Summary + '. WHO performance status ' + CONVERT(VARCHAR(1), @WHOStatus)
       END

       ------------------------------------------------------------------
       --INDICATIONS
       ------------------------------------------------------------------
       SET @summaryTemp = ''

       IF @Anaemia = 1
       BEGIN
              IF @AnaemiaType = 1
                     SET @summaryTemp = @summaryTemp + 'unspecified'
              ELSE IF @AnaemiaType = 2
                     SET @summaryTemp = @summaryTemp + 'microcytic'
              ELSE IF @AnaemiaType = 3
                     SET @summaryTemp = @summaryTemp + 'normocytic'
              ELSE IF @AnaemiaType = 4
                     SET @summaryTemp = @summaryTemp + 'macrocytic'

              IF @summaryTemp = '' SET @summaryTemp = @summaryTemp + 'anaemia'
              ELSE SET @summaryTemp = @summaryTemp + ' anaemia'
       END

       SELECT 
              IndicationItem,
              CASE IndicationItem 
                     WHEN 'AbdominalPain' THEN 'abdominal pain' 
					 WHEN 'AbnormalCapsuleStudy' THEN 'abnormal capsule study' 
					 WHEN 'AbnormalMRI' THEN 'abnormal MRI' 
                     WHEN 'AbnormalityOnBarium' THEN 'abnormality on barium' 
                     WHEN 'ChestPain' THEN 'chest pain' 
                     WHEN 'ChronicLiverDisease' THEN 'chronic liver disease' 
                     WHEN 'CoffeeGroundsVomit' THEN 'coffee grounds vomit'
					 WHEN 'DrugTrial' THEN 'drug trial'
					 WHEN 'Diarrhoea' THEN 'diarrhoea'
                     WHEN 'PositiveTTG_EMA' THEN 'positive TTG/EMA'
					 WHEN 'Dyspepsia' THEN 'dyspepsia'
                     WHEN 'DyspepsiaAtypical' THEN 'dyspepsia - atypical'
                     WHEN 'DyspepsiaUlcerType' THEN 'dyspepsia - ulcer type'
					 WHEN 'Dysphagia' THEN 'dysphagia'
					 WHEN 'Haematemesis' THEN 'haematemesis'
					 WHEN 'Melaena' THEN 'melaena'
                     WHEN 'NauseaAndOrVomiting' THEN 'nausea and/or vomiting'
					 WHEN 'Odynophagia' THEN 'odynophagia'
                     WHEN 'RefluxSymptoms' THEN 'reflux symptoms'
                     WHEN 'UlcerExclusion' THEN 'ulcer exclusion'
                     WHEN 'WeightLoss' THEN 'weight loss'
                     ELSE IndicationItem 
              END AS IndicationItemDesc, 
              Selected
              INTO #indications
       FROM 
       (SELECT * FROM ERS_UpperGIIndications WHERE ProcedureId = @ProcedureId) a
       UNPIVOT
       (      Selected 
              FOR IndicationItem IN (AbdominalPain, AbnormalCapsuleStudy, AbnormalMRI, AbnormalityOnBarium, ChestPain, ChronicLiverDisease, CoffeeGroundsVomit, Diarrhoea, PositiveTTG_EMA, DrugTrial, Dyspepsia, DyspepsiaAtypical,
                                                       DyspepsiaUlcerType, Dysphagia, Haematemesis, Melaena, NauseaAndOrVomiting, Odynophagia, RefluxSymptoms, UlcerExclusion, WeightLoss)
       ) b
       WHERE Selected = 1
       
	   IF @OtherIndication <> '' INSERT INTO #indications VALUES ('OtherIndication',@OtherIndication,1) 
 
       IF (SELECT COUNT(*) FROM #indications) > 0
       BEGIN
              -- Get the concatenated string separated by a delimiter, say $$
              SELECT @summaryTemp = COALESCE (
                                                CASE WHEN @summaryTemp = '' THEN IndicationItemDesc
                                                ELSE @summaryTemp + '$$' + IndicationItemDesc END
                                         ,'')
              FROM #indications

              --IF @OtherIndication <> '' SET @summaryTemp = @summaryTemp + '$$' + @OtherIndication
              
              -- Set the last occurence of $$ to "and"
              IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = STUFF(@summaryTemp, len(@summaryTemp) - charindex('$$', reverse(@summaryTemp)), 2, ' and ')
              -- Replace all other occurences of $$ with commas
              IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = REPLACE(@summaryTemp, '$$', ', ')
       END
       
       --finally, add to the main summary field
       IF @summaryTemp <> ''
       BEGIN
			SET @summaryTemp = dbo.fnFirstLetterUpper(@summaryTemp)

            IF @summary = '' SET @summary = @summaryTemp
            ELSE SET @summary = @summary + '. <br />' + @summaryTemp
       END
       

       ------------------------------------------------------------------
       --PREVIOUS H PYLORI
       ------------------------------------------------------------------
       SET @summaryTemp = ''
       IF @PreviousHPyloriTest = 1
       BEGIN
			DECLARE @cnt TINYINT = 0
			DECLARE @HPylori TABLE (result tinyint, test nvarchar(100), descrip nvarchar(100))
			INSERT INTO @HPylori SELECT 1, 'positive',''
			INSERT INTO @HPylori SELECT 2, 'negative',''
			INSERT INTO @HPylori SELECT 3, 'inconclusive',''
			INSERT INTO @HPylori SELECT 0, '',''

			IF @BreathTest = 1 
            BEGIN
				IF @BreathTestResult >= 0 UPDATE @HPylori SET descrip = descrip + '$$' + 'breath' WHERE result = @BreathTestResult
				SET @cnt = @cnt + 1
                    --IF @BreathTestResult = 0 INSERT INTO @HPylori SELECT 0, 'breath', 'breath test was carried out'
                    --ELSE IF @BreathTestResult = 1 INSERT INTO @HPylori SELECT 1, 'breath', 'positive'
                    --ELSE IF @BreathTestResult = 2 INSERT INTO @HPylori SELECT 2, 'breath', 'negative'
                    --ELSE IF @BreathTestResult = 3 INSERT INTO @HPylori SELECT 3, 'breath', 'inconclusive'
            END

            IF @SerologyTest = 1 
            BEGIN
				IF @SerologyTestResult >= 0 UPDATE @HPylori SET descrip = 'serology' WHERE result = @SerologyTestResult
				SET @cnt = @cnt + 1
            END

            IF @StoolAntigenTest = 1 
            BEGIN
				IF @StoolAntigenTestResult >= 0 UPDATE @HPylori SET descrip = descrip + '$$' + 'stool antigen' WHERE result = @StoolAntigenTestResult
				SET @cnt = @cnt + 1
            END

            IF @UreaseTest = 1 
            BEGIN
				IF @UreaseTestResult >= 0 UPDATE @HPylori SET descrip = descrip + '$$' + 'urease' WHERE result = @UreaseTestResult
				SET @cnt = @cnt + 1
            END

              DELETE @HPylori  WHERE descrip = ''

              IF (SELECT COUNT(*) FROM @HPylori) > 0 
              BEGIN
					--remove the first 2 '$$'
					UPDATE @HPylori SET descrip = RIGHT(descrip, LEN(descrip) -2) WHERE LEFT(descrip,2) = '$$'

					UPDATE @HPylori SET test = ' (' + test + ')' WHERE result <> 0
                     
					SELECT @summaryTemp = COALESCE (CASE WHEN @summaryTemp = '' THEN descrip + test
													ELSE @summaryTemp + '$$' + descrip + test END,'')
					FROM @HPylori --WHERE result <> 0

					IF @cnt > 0 SET @summaryTemp = 'test carried out for ' + @summaryTemp 

					-- Set the last occurence of $$ to "and"
					IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = STUFF(@summaryTemp, len(@summaryTemp) - charindex('$$', reverse(@summaryTemp)), 2, ' and ')
					-- Replace all other occurences of $$ with commas
					IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = REPLACE(@summaryTemp, '$$', ', ')
					IF @summaryTemp <> '' SET @summaryTemp = 'Previous Helicobacter pylori ' + @summaryTemp
              END
              ELSE
                     SET @summaryTemp = 'Previous Helicobacter pylori test carried out'
              
              --finally, add to the main summary field
              IF @summary = '' SET @summary = @summaryTemp
              ELSE SET @summary = @summary + '. <br />' + @summaryTemp
       END


       ------------------------------------------------------------------
       --PLANNED PROCEDURES
       ------------------------------------------------------------------
       SET @summaryTemp = ''

       SELECT 
              PlannedProcedureItem,
              CASE PlannedProcedureItem 
                     WHEN 'BariatricPreAssessment' THEN 'bariatric pre-assessment'
                     WHEN 'BalloonInsertion' THEN 'balloon insertion'
                     WHEN 'BalloonRemoval' THEN 'balloon removal'
					 WHEN 'SingleBalloonEnteroscopy' THEN 'single balloon enteroscopy'
					 WHEN 'DoubleBalloonEnteroscopy' THEN 'double balloon enteroscopy (push-pull enteroscopy)'
                     WHEN 'PostBariatricSurgeryAssessment' THEN 'post bariatric surgery assessment'
                     WHEN 'GastrostomyInsertion' THEN 'gastrostomy insertion (PEG)'
                     WHEN 'InsertionOfPHProbe' THEN 'insertion of pH probe'
                     WHEN 'JejunostomyInsertion' THEN 'jejunostomy insertion (PEJ)'
                     WHEN 'NasoDuodenalTube' THEN 'nasojejunal tube (NJT)'
                     WHEN 'OesophagealDilatation' THEN 'oesophageal dilatation'
                     WHEN 'PEGRemoval' THEN 'PEG removal'
					 WHEN 'PEGReplacement' THEN 'PEG Replacement'
                     WHEN 'PushEnteroscopy' THEN 'push enteroscopy'
                     WHEN 'SmallBowelBiopsy' THEN 'small bowel biopsy'
                     WHEN 'StentRemoval' THEN 'stent removal'
                     WHEN 'StentInsertion' THEN 'stent insertion'
                     WHEN 'StentReplacement' THEN 'stent replacement'
                     WHEN 'EPlanNGTubeInsertion' THEN 'NG tube insertion'
                     WHEN 'EPlanNGTubeRemoval' THEN 'NG tube removal'
                     ELSE PlannedProcedureItem 
              END AS PlannedProcedureItemDesc, 
              Selected
              INTO #plannedProcedures
       FROM 
       (SELECT * FROM ERS_UpperGIIndications WHERE ProcedureId = @ProcedureId) a
       UNPIVOT
       (      Selected 
              FOR PlannedProcedureItem IN (BariatricPreAssessment, BalloonInsertion, BalloonRemoval, SingleBalloonEnteroscopy, DoubleBalloonEnteroscopy, PostBariatricSurgeryAssessment, EUS, GastrostomyInsertion, InsertionOfPHProbe,
                                         JejunostomyInsertion, NasoDuodenalTube, OesophagealDilatation, PEGRemoval, PEGReplacement, PushEnteroscopy, SmallBowelBiopsy, StentRemoval, StentInsertion, StentReplacement, EPlanNGTubeInsertion, EPlanNGTubeRemoval)
       ) b
       WHERE Selected = 1

	   IF @OtherPlannedProcedure <> '' INSERT INTO #plannedProcedures VALUES ('OtherPlannedProcedure',@OtherPlannedProcedure,1) 

       IF (SELECT COUNT(*) FROM #plannedProcedures) > 0
       BEGIN
              -- Get the concatenated string separated by a delimiter, say $$
              SELECT @summaryTemp = COALESCE (
                                                CASE WHEN @summaryTemp = '' THEN PlannedProcedureItemDesc
                                                ELSE @summaryTemp + '$$' + PlannedProcedureItemDesc END
                                         ,'')
              FROM #plannedProcedures

              --IF @OtherPlannedProcedure <> '' SET @summaryTemp = @summaryTemp + '$$' + @OtherPlannedProcedure

              -- Set the last occurence of $$ to "and"
              IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = STUFF(@summaryTemp, len(@summaryTemp) - charindex('$$', reverse(@summaryTemp)), 2, ' and ')
              -- Replace all other occurences of $$ with commas
              IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = REPLACE(@summaryTemp, '$$', ', ')
       END

       --finally, add to the main summary field
       IF @summaryTemp <> ''
       BEGIN
              IF @summary = '' SET @summary = @summaryTemp
              ELSE SET @summary = @summary + '. <br />Planned procedures: ' + @summaryTemp
       END

       ------------------------------------------------------------------
       --CO-MORBIDITY
       ------------------------------------------------------------------
       SET @summaryTemp = ''

       SELECT 
              CoMorbidityItem,
              CASE CoMorbidityItem 
					 WHEN 'Angina' THEN 'angina'
					 WHEN 'Asthma' THEN 'asthma'
					 WHEN 'COPD' THEN 'COPD'
					 WHEN 'DiabetesMellitus' THEN 'diabetes mellitus**'
					 WHEN 'Epilepsy' THEN 'epilepsy'
					 WHEN 'HemiPostStroke' THEN 'hemi post stroke'
					 WHEN 'Hypertension' THEN 'hypertension'
					 WHEN 'MI' THEN 'MI'
					 WHEN 'Obesity' THEN 'obesity'
					 WHEN 'TIA' THEN 'TIA'
                     ELSE CoMorbidityItem 
              END AS CoMorbidityItemDesc, 
              Selected
              INTO #coMorbidity
       FROM 
       (SELECT * FROM ERS_UpperGIIndications WHERE ProcedureId = @ProcedureId) a
       UNPIVOT
       (      Selected 
              FOR CoMorbidityItem IN (Angina, Asthma, COPD, DiabetesMellitus, Epilepsy, HemiPostStroke, Hypertension, MI, Obesity, TIA)
       ) b
       WHERE Selected = 1

	   IF @OtherCoMorbidity <> '' INSERT INTO #coMorbidity VALUES ('OtherCoMorbidity',@OtherCoMorbidity,1) 

       IF (SELECT COUNT(*) FROM #coMorbidity) > 0
       BEGIN
              -- Get the concatenated string separated by a delimiter, say $$
              SELECT @summaryTemp = COALESCE (
                                                CASE WHEN @summaryTemp = '' THEN CoMorbidityItemDesc
                                                ELSE @summaryTemp + '$$' + CoMorbidityItemDesc END
                                         ,'')
              FROM #coMorbidity

              --IF @OtherCoMorbidity <> '' SET @summaryTemp = @summaryTemp + '$$' + @OtherCoMorbidity

              -- Set the last occurence of $$ to "and"
              IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = STUFF(@summaryTemp, len(@summaryTemp) - charindex('$$', reverse(@summaryTemp)), 2, ' and ')
              -- Replace all other occurences of $$ with commas
              IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = REPLACE(@summaryTemp, '$$', ', ')
       END

       IF CHARINDEX('**', @summaryTemp) > 0
       BEGIN
              IF @DiabetesMellitusType = 0 SET @summaryTemp = REPLACE(@summaryTemp, '**', '')
              ELSE IF @DiabetesMellitusType = 1 SET @summaryTemp = REPLACE(@summaryTemp, '**', ' (unknown)')
              ELSE IF @DiabetesMellitusType = 2 SET @summaryTemp = REPLACE(@summaryTemp, '**', ' (type 1)')
              ELSE IF @DiabetesMellitusType = 3 SET @summaryTemp = REPLACE(@summaryTemp, '**', ' (type 2)')
       END

       --finally, add to the main summary field
       IF @summaryTemp <> ''
       BEGIN
              IF @summary = '' SET @summary = 'Co-morbidity: ' + @summaryTemp
              ELSE SET @summary = @summary + '. <br />Co-morbidity: ' + @summaryTemp
       END


       ------------------------------------------------------------------
       --ASA STATUS
       ------------------------------------------------------------------
       IF @ASAStatus IS NOT NULL
       BEGIN
              IF @summary <> '' SET @summary = @summary + '. <br />ASA status: '
              ELSE SET @summary = @summary + 'ASA status: '

              IF @ASAStatus = 0 SET @summary = @summary + 'Not assessed'
              ELSE IF @ASAStatus = 1 SET @summary = @summary + 'ASA I - patient is normal and healthy'
              ELSE IF @ASAStatus = 2 SET @summary = @summary + 'ASA II - patient has mild systemic disease'
              ELSE IF @ASAStatus = 3 SET @summary = @summary + 'ASA III - patient has severe systemic disease'
              ELSE IF @ASAStatus = 4 SET @summary = @summary + 'ASA IV - patient has severe systemic disease that is a constant threat to life'
              ELSE IF @ASAStatus = 5 SET @summary = @summary + 'ASA V - patient is moribund and is not expected to survive without the procedure/operation'
       END

       Declare @dmagingDrug varchar(5000) =''
       If @PotentiallyDamagingDrug <> '' SET @dmagingDrug = '.</br>Potential damaging drug: ' + dbo.fnFirstLetterUpper(@PotentiallyDamagingDrug)
       SET @summary = @summary + @dmagingDrug
       ------------------------------------------------------------------
       --ASA STATUS
       ------------------------------------------------------------------
       IF @Allergy > 0
       BEGIN
              IF @summary = '' SET @summary = @summary + 'allergy: '
              ELSE SET @summary = @summary + '. <br/>Allergy: '

              IF @Allergy = 1 SET @summary = @summary + 'uknown'
              ELSE IF @Allergy = 2 SET @summary = @summary + 'none'
              ELSE IF @Allergy = 3 
              BEGIN
                     IF @AllergyDesc = '' SET @summary = @summary + 'unspecified'
                     ELSE SET @summary = @summary + @AllergyDesc
              END
              
       END


       ------------------------------------------------------------------
       --FOLLOWING UP SURGERY
       ------------------------------------------------------------------
       IF @SurgeryFollowUpText <> ''
              IF @summary <> '' SET @summary = @summary + '. <br />Previous surgery: ' + @SurgeryFollowUpText
              ELSE SET @summary = @summary + 'Previous surgery: ' + @SurgeryFollowUpText


       ------------------------------------------------------------------
       --FOLLOWING UP DISEASE
       ------------------------------------------------------------------
       SET @summaryTemp = ''
       
       IF @DiseaseFollowUpProc > 0
              SELECT @summaryTemp = [ListItemText] FROM ERS_Lists where [ListDescription] = 'Follow up disease/proc Upper GI' AND [ListItemNo] = @DiseaseFollowUpProc
       
       IF @DiseaseFollowUpProcPeriod = 1
              SET @summaryTemp = @summaryTemp + ' within the last month'
       ELSE IF @DiseaseFollowUpProcPeriod = 2
              SET @summaryTemp = @summaryTemp + ' one to two months ago'
       ELSE IF @DiseaseFollowUpProcPeriod = 3
              SET @summaryTemp = @summaryTemp + ' three to four months ago'
       ELSE IF @DiseaseFollowUpProcPeriod = 4
              SET @summaryTemp = @summaryTemp + ' five to six months ago'
       ELSE IF @DiseaseFollowUpProcPeriod = 5
              SET @summaryTemp = @summaryTemp + ' seven to twelve months ago'
       ELSE IF @DiseaseFollowUpProcPeriod = 6
              SET @summaryTemp = @summaryTemp + ' one to three years ago'
       ELSE IF @DiseaseFollowUpProcPeriod = 7
              SET @summaryTemp = @summaryTemp + ' more than three years ago'
       
       SELECT 
              DiseaseItem,
              CASE DiseaseItem 
                     WHEN 'BarrettsOesophagus' THEN 'Barrett''s oesophagus'
                     WHEN 'CoeliacDisease' THEN 'coeliac disease'
					 WHEN 'Dysplasia' THEN 'dysplasia'
					 WHEN 'Gastritis' THEN 'gastritis'
					 WHEN 'Malignancy' THEN 'malignancy'
                     WHEN 'OesophagealDilatationFollowUp' THEN 'oesophageal dilatation'
                     WHEN 'OesophagealVarices' THEN 'oesophageal varices'
					 WHEN 'Oesophagitis' THEN 'oesophagitis'
                     WHEN 'UlcerHealing' THEN 'ulcer healing'
                     ELSE DiseaseItem 
              END AS DiseaseItemDesc, 
              Selected
              INTO #diseases
       FROM 
       (SELECT * FROM ERS_UpperGIIndications WHERE ProcedureId = @ProcedureId) a
       UNPIVOT
       (      Selected 
              FOR DiseaseItem IN (BarrettsOesophagus, CoeliacDisease, Dysplasia, Gastritis, Malignancy, OesophagealDilatationFollowUp, OesophagealVarices, 
                                         Oesophagitis, UlcerHealing)
       ) b
       WHERE Selected = 1

       IF (SELECT COUNT(*) FROM #diseases) > 0
       BEGIN
              -- Get the concatenated string separated by a delimiter, say $$
              SELECT @summaryTemp = COALESCE (
                                                CASE WHEN @summaryTemp = '' THEN DiseaseItemDesc
                                                ELSE @summaryTemp + '$$' + DiseaseItemDesc END
                                         ,'')
              FROM #diseases

              -- Set the last occurence of $$ to "and"
              IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = STUFF(@summaryTemp, len(@summaryTemp) - charindex('$$', reverse(@summaryTemp)), 2, ' and ')
              -- Replace all other occurences of $$ with commas
              IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = REPLACE(@summaryTemp, '$$', ', ')
       END

       IF @summaryTemp <> ''
       BEGIN
              IF @summary = '' SET @summary = @summaryTemp
              ELSE SET @summary = @summary + '. <br />Previous diseases/procedures: ' + @summaryTemp
       END

       ------------------------------------------------------------------
       --Important COMMENTS
       ------------------------------------------------------------------
       IF @ClinicallyImpComments <> ''
              IF @summary = '' SET @summary = @ClinicallyImpComments
              ELSE SET @summary = @summary + '. <br />Clinically important comments: ' + @ClinicallyImpComments

END
       --IF @summary <> '' SET @summary = @summary + '.'
       
       --PRINT @summary

       -- Finally update the summary column in indications and procedures tables
       UPDATE ERS_UpperGIIndications
       SET Summary = @summary 
       WHERE ProcedureId = @ProcedureId;

       UPDATE ERS_ProceduresReporting
       SET PP_Indic = @summary 
       WHERE ProcedureId = @ProcedureId;

          IF OBJECT_ID('tempdb..#indications') IS NOT NULL DROP TABLE #indications
          IF OBJECT_ID('tempdb..#plannedProcedures') IS NOT NULL DROP TABLE #plannedProcedures
          IF OBJECT_ID('tempdb..#coMorbidity') IS NOT NULL DROP TABLE #coMorbidity
          IF OBJECT_ID('tempdb..#ecoMorbidity') IS NOT NULL DROP TABLE #ecoMorbidity
          IF OBJECT_ID('tempdb..#diseases') IS NOT NULL DROP TABLE #diseases
		  IF OBJECT_ID('tempdb..#coMorbidity1') IS NOT NULL DROP TABLE #coMorbidity1
       --IF @ProcType<> 3 OR @ProcType=4
       --BEGIN

       --       DROP TABLE #indications
       --       DROP TABLE #plannedProcedures
       --       DROP TABLE #coMorbidity
       --       DROP TABLE #diseases
       --END 
GO
-----------------------------------------------------------------------------------------------------------
-- Bug 194 Colon Procedure Technical Failure reason not appearing on report
EXEC DropIfExist 'ogd_qa_summary_update','S';
GO

CREATE PROCEDURE [dbo].[ogd_qa_summary_update]
(
       @ProcedureId INT
)
AS
       SET NOCOUNT ON

       DECLARE
              @summary VARCHAR(4000),
              @summaryTemp VARCHAR(4000),
              @summaryTemp2 VARCHAR(500),
              @NoNotes BIT,
              @ReferralLetter BIT,
              @ManagementNone BIT,
              @PulseOximetry BIT,
              @IVAccess BIT,
              @IVAntibiotics BIT,
              @Oxygenation BIT,
              @OxygenationMethod TINYINT,
              @OxygenationFlowRate DECIMAL(6,2),
              @ContinuousECG BIT,
              @BP BIT,
              @BPSystolic DECIMAL(6,2),
              @BPDiastolic DECIMAL(6,2),
              @ManagementOther BIT,
              @ManagementOtherText NVARCHAR(1000),
              @PatSedation TINYINT,
              @PatSedationAsleepResponseState TINYINT,
              @PatDiscomfortNurse TINYINT,
			  @PatDiscomfortEndo TINYINT,
              @ComplicationsNone BIT,
              @PoorlyTolerated BIT,
              @PatientDiscomfort BIT,
              @PatientDistress BIT,
              @InjuryToMouth BIT,
              @FailedIntubation BIT,
              @DifficultIntubation BIT,
              @DamageToScope BIT,
              @DamageToScopeType TINYINT,
              @GastricContentsAspiration BIT,
              @ShockHypotension BIT,
              @Haemorrhage BIT,
              @SignificantHaemorrhage BIT,
              @Hypoxia BIT,
              @RespiratoryDepression BIT,
              @RespiratoryArrest BIT,
              @CardiacArrest BIT,
              @CardiacArrythmia BIT,
              @Death BIT,
              @TechnicalFailure NVARCHAR(1000),
              @Perforation BIT,
              @PerforationText NVARCHAR(500),
              @ComplicationsOther BIT,
              @ComplicationsOtherText NVARCHAR(1000),
			  @Bleeding BIT,
			  @BleedingSeverity TINYINT,
			  @BleedingAdrenalineUsed BIT,
			  @BleedingAdrenalineAmount DECIMAL(8,2),
			  @BleedingColdSalineUsed BIT,
			  @BleedingBlockingDeviceUsed BIT,
			  @Pneumothorax BIT,
			  @PneumothoraxAspirChestDrain BIT,
			  @Hospitalisation BIT,
			  @MyocardInfarction BIT,
			  @Oversedation BIT,
			  @AdmissionToICU BIT

       SELECT 
              @NoNotes=NoNotes,
              @ReferralLetter=ReferralLetter,
              @ManagementNone=ManagementNone,
              @PulseOximetry=PulseOximetry,
              @IVAccess=IVAccess,
              @IVAntibiotics=IVAntibiotics,
              @Oxygenation=Oxygenation,
              @OxygenationMethod=OxygenationMethod,
              @OxygenationFlowRate=OxygenationFlowRate,
              @ContinuousECG=ContinuousECG,
              @BP=BP,
              @BPSystolic=BPSystolic,
              @BPDiastolic=BPDiastolic,
              @ManagementOther=ManagementOther,
              @ManagementOtherText=ManagementOtherText,
              @PatSedation=PatSedation,
              @PatSedationAsleepResponseState=PatSedationAsleepResponseState,
              @PatDiscomfortNurse=PatDiscomfortNurse,
			  @PatDiscomfortEndo=PatDiscomfortEndo,
              @ComplicationsNone=ComplicationsNone,
              @PoorlyTolerated=PoorlyTolerated,
              @PatientDiscomfort=PatientDiscomfort,
              @PatientDistress=PatientDistress,
              @InjuryToMouth=InjuryToMouth,
              @FailedIntubation=FailedIntubation,
              @DifficultIntubation=DifficultIntubation,
              @DamageToScope=DamageToScope,
              @DamageToScopeType=DamageToScopeType,
              @GastricContentsAspiration=GastricContentsAspiration,
              @ShockHypotension=ShockHypotension,
              @Haemorrhage=Haemorrhage,
              @SignificantHaemorrhage=SignificantHaemorrhage,
              @Hypoxia=Hypoxia,
              @RespiratoryDepression=RespiratoryDepression,
              @RespiratoryArrest=RespiratoryArrest,
              @CardiacArrest=CardiacArrest,
              @CardiacArrythmia=CardiacArrythmia,
              @Death=Death,
              @TechnicalFailure=TechnicalFailure,
              @Perforation=Perforation,
              @PerforationText=PerforationText,
              @ComplicationsOther=ComplicationsOther,
              @ComplicationsOtherText=ComplicationsOtherText,
			  @Bleeding=Bleeding,
			  @BleedingSeverity=BleedingSeverity,
			  @BleedingAdrenalineUsed=BleedingAdrenalineUsed,
			  @BleedingAdrenalineAmount=BleedingAdrenalineAmount,
			  @BleedingColdSalineUsed=BleedingColdSalineUsed,
			  @BleedingBlockingDeviceUsed=BleedingBlockingDeviceUsed,
			  @Pneumothorax=Pneumothorax,
			  @PneumothoraxAspirChestDrain=PneumothoraxAspirChestDrain,
			  @Hospitalisation=Hospitalisation,
			  @MyocardInfarction=MyocardInfarction,
			  @Oversedation=Oversedation,
			  @AdmissionToICU=AdmissionToICU
       FROM
              ERS_UpperGIQA
       WHERE
              ProcedureId = @ProcedureId

       SET @summary = ''
       SET @summaryTemp = ''

       IF @NoNotes = 1 AND @ReferralLetter = 1
              SET @summary = 'Patient notes NOT available but referral letter/documentation WAS available'
       ELSE IF @NoNotes = 1 AND @ReferralLetter = 0
              SET @summary = 'Patient notes NOT available '
       ELSE 
              SET @summary = 'Patient notes available'
       
       
       --------------------------------------------------
       ------------------- MANAGEMENT ------------------- 
       -------------------------------------------------- 
       SET @summaryTemp = ''
       IF @ManagementNone = 1 
       BEGIN
              IF @summary = '' SET @summary = 'Management: None'
              ELSE SET @summary = @summary + '. <br/>Management: None'
       END

       ELSE
       BEGIN
              SELECT 
                     ManagementItem,
                     CASE ManagementItem 
                           WHEN 'PulseOximetry' THEN 'Pulse oximetry' 
                           WHEN 'IVAccess' THEN 'IV access' 
                           WHEN 'IVAntibiotics' THEN 'IV antibiotics' 
                           WHEN 'ContinuousECG' THEN 'Continuous ECG' 
                           WHEN 'ManagementOther' THEN 'Other'
                           ELSE ManagementItem 
                     END AS ManagementItemDesc, 
                     Selected
                     INTO #Management
              FROM 
              (SELECT * FROM ERS_UpperGIQA WHERE ProcedureId = @ProcedureId) a
              UNPIVOT
              (      Selected 
                     FOR ManagementItem IN (PulseOximetry,IVAccess,IVAntibiotics,Oxygenation,ContinuousECG,BP,ManagementOther)
              ) b
              WHERE Selected = 1

              IF (SELECT COUNT(*) FROM #Management) > 0
              BEGIN
                     -- Get the concatenated string separated by a delimiter, say $$
                     SELECT @summaryTemp = COALESCE (
                                                       CASE WHEN @summaryTemp = '' THEN ManagementItemDesc
                                                       ELSE @summaryTemp + '$$' + ManagementItemDesc END
                                                ,'')
                     FROM #Management

                     IF @ManagementOtherText <> '' SET @summaryTemp = REPLACE(@summaryTemp, 'Other' , @ManagementOtherText)

                     IF @OxygenationMethod > 0 OR @OxygenationFlowRate > 0 
                     BEGIN
                           SET @summaryTemp2 = ''
                           IF @OxygenationMethod = 1 
                                  IF @OxygenationFlowRate > 0 SET @summaryTemp2 = '(Cannulae ' + CONVERT(VARCHAR(10), @OxygenationFlowRate) + ' l/min)'
                                  ELSE SET @summaryTemp2 = '(Cannulae)'
                           ELSE IF @OxygenationMethod = 2 
                                  IF @OxygenationFlowRate > 0 SET @summaryTemp2 = '(Mask ' + CONVERT(VARCHAR(10), @OxygenationFlowRate) + ' l/min)'
                                  ELSE SET @summaryTemp2 = '(Mask)'
                           SET @summaryTemp = REPLACE(@summaryTemp, 'Oxygenation' , @summaryTemp2)
                     END

                     IF @BPSystolic > 0 OR @BPDiastolic > 0
                     BEGIN
                           SET @summaryTemp2 = 'BP ('
                           IF @BPSystolic > 0
                                  SET @summaryTemp2 = @summaryTemp2 + 'Systolic ' + CONVERT(VARCHAR(10), @BPSystolic) + ' mm'
                           IF @BPDiastolic > 0
                                  IF @summaryTemp2 <> '' SET @summaryTemp2 = @summaryTemp2 + ', Diastolic ' + CONVERT(VARCHAR(10), @BPDiastolic) + ' mm'
                                  ELSE SET @summaryTemp2 = @summaryTemp2 + 'Diastolic ' + CONVERT(VARCHAR(10), @BPDiastolic) + ' mm'
                           SET @summaryTemp2 = @summaryTemp2  + ')'
                           SET @summaryTemp = REPLACE(@summaryTemp, 'BP' , @summaryTemp2)
                     END
                     
                     -- Set the last occurence of $$ to "and"
                     IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = STUFF(@summaryTemp, len(@summaryTemp) - charindex('$$', reverse(@summaryTemp)), 2, ' and ')
                     -- Replace all other occurences of $$ with commas
                     IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = REPLACE(@summaryTemp, '$$', ', ')
              END

              DROP TABLE #Management

              --finally, add to the main summary field
              IF @summaryTemp <> ''
              BEGIN
                     IF @summary = '' SET @summary = 'Management: ' + @summaryTemp
                     ELSE SET @summary = @summary + '. <br/>Management: ' + @summaryTemp
              END
       END


       --------------------------------------------------
       ------------------- Nurse Assessment -------------
       -------------------------------------------------- 
       SET @summaryTemp = ''
       IF @PatSedation > 0
       BEGIN
              SET @summaryTemp = 'Patient Sedation'
              IF @PatSedation = 1 SET @summaryTemp = @summaryTemp + ' - Not recorded'
              ELSE IF @PatSedation = 2 SET @summaryTemp = @summaryTemp + ' - Awake'
              ELSE IF @PatSedation = 3 SET @summaryTemp = @summaryTemp + ' - Drowsy'
              ELSE IF @PatSedation = 4 
              BEGIN
                     SET @summaryTemp = @summaryTemp + ' - Asleep'
                     IF @PatSedationAsleepResponseState = 1 SET @summaryTemp = @summaryTemp + ' but responding to name'
                     ELSE IF @PatSedationAsleepResponseState = 2 SET @summaryTemp = @summaryTemp + ' but responding to touch'
                     ELSE IF @PatSedationAsleepResponseState = 3 SET @summaryTemp = @summaryTemp + ' but unresponsive'
              END
       END

       IF @PatDiscomfortNurse > 0
       BEGIN
              SET @summaryTemp2 = 'Patient Discomfort'
              IF @PatDiscomfortNurse = 1 SET @summaryTemp2 = @summaryTemp2 + ' - Not recorded'
              IF @PatDiscomfortNurse = 2 SET @summaryTemp2 = @summaryTemp2 + ' - None-resting comfortably throughout'
              IF @PatDiscomfortNurse = 3 SET @summaryTemp2 = @summaryTemp2 + ' - One or two episode of mild discomfort, well tolerated'
              IF @PatDiscomfortNurse = 4 SET @summaryTemp2 = @summaryTemp2 + ' - More than two episodes of discomfort, adequately tolerated'
              IF @PatDiscomfortNurse = 5 SET @summaryTemp2 = @summaryTemp2 + ' - Significant discomfort, experienced several times during procedure'
              IF @PatDiscomfortNurse = 6 SET @summaryTemp2 = @summaryTemp2 + ' - Extreme discomfort frequently during test'
              
              IF @summaryTemp = '' SET @summaryTemp = @summaryTemp2
              ELSE SET @summaryTemp = @summaryTemp + '. ' + @summaryTemp2
       END

       IF @summary = '' SET @summary = 'Nurse Assessment: ' + @summaryTemp
       ELSE SET @summary = @summary + '. <br/>Nurse Assessment: ' + @summaryTemp


       --------------------------------------------------
       ------------------- Complications ----------------
       -------------------------------------------------- 
       SET @summaryTemp = ''
       IF @ComplicationsNone = 1 
       BEGIN
              IF @summary = '' SET @summary = 'No complications'
              ELSE SET @summary = @summary + '. <br/>No complications'

			  UPDATE ERS_UpperGIQA SET ComplicationsSummary = 'No complications' WHERE ProcedureId = @ProcedureId
       END

       ELSE
       BEGIN
              SELECT 
                     ComplicationsItem,
                     CASE ComplicationsItem 
                           WHEN 'PoorlyTolerated' THEN 'poorly tolerated' 
                           WHEN 'PatientDiscomfort' THEN 'patient discomfort' 
                           WHEN 'PatientDistress' THEN 'patient distress' 
                           WHEN 'InjuryToMouth' THEN 'injury to mouth' 
                           WHEN 'FailedIntubation' THEN 'failed intubation'
                           WHEN 'DifficultIntubation' THEN 'difficult intubation'
                           WHEN 'DamageToScope' THEN 'damage to scope' + CASE @DamageToScopeType WHEN 1 THEN ' (mechanical)' WHEN 2 THEN ' (patient initiated)' WHEN 9 THEN ' (mechanical and patient initiated)' ELSE '' END
                           WHEN 'GastricContentsAspiration' THEN 'gastric contents aspiration'
                           WHEN 'ShockHypotension' THEN 'shock/hypotension'
						   WHEN 'Haemorrhage' THEN 'haemorrhage'
                           WHEN 'SignificantHaemorrhage' THEN 'significant haemorrhage'
						   WHEN 'Hypoxia' THEN 'hypoxia'
                           WHEN 'RespiratoryDepression' THEN 'respiratory depression'
                           WHEN 'RespiratoryArrest' THEN 'respiratory arrest'
                           WHEN 'CardiacArrest' THEN 'cardiac arrest'
						   WHEN 'CardiacArrythmia' THEN 'cardiac arrythmia'
						   WHEN 'Death' THEN 'death'
						   WHEN 'Perforation' THEN 'perforation' + CASE WHEN @PerforationText <> '' THEN ' (site: ' + @PerforationText + ')' ELSE '' END
						   WHEN 'Pneumothorax' THEN 'pneumothorax' + CASE WHEN @PneumothoraxAspirChestDrain = 1 THEN ' (required aspiration/chest drain)' ELSE '' END
						   WHEN 'Hospitalisation' THEN 'hospitalisation'
						   WHEN 'MyocardInfarction' THEN 'myocardial infarction/pulmonary oedema'
						   WHEN 'Oversedation' THEN 'oversedation requiring ventilatory support or reversal'
						   WHEN 'AdmissionToICU' THEN 'admission to ICU'
                           WHEN 'ComplicationsOther' THEN CASE WHEN @ComplicationsOtherText <> '' THEN @ComplicationsOtherText ELSE 'other' END
                           ELSE ComplicationsItem 
                     END AS ComplicationsItemDesc, 
                     Selected
                     INTO #Complications
              FROM 
              (SELECT * FROM ERS_UpperGIQA WHERE ProcedureId = @ProcedureId) a
              UNPIVOT
              (      Selected 
                     FOR ComplicationsItem IN (PoorlyTolerated,PatientDiscomfort,PatientDistress,InjuryToMouth,FailedIntubation,DifficultIntubation,DamageToScope,
                                                              GastricContentsAspiration,ShockHypotension,Haemorrhage,SignificantHaemorrhage,Hypoxia,RespiratoryDepression,RespiratoryArrest,
                                                              CardiacArrest,CardiacArrythmia,Death,Perforation,
															  Pneumothorax,Hospitalisation,MyocardInfarction,Oversedation,AdmissionToICU,
															  ComplicationsOther)
              ) b
              WHERE Selected = 1
			  
			  IF @Bleeding = 1
			  BEGIN
				DECLARE @bleedingsummary VARCHAR(500) = '', @actiontakensummary VARCHAR(500) = ''
				IF @BleedingSeverity = 1 SET @bleedingsummary = 'mild bleeding'
				ELSE IF @BleedingSeverity = 2 SET @bleedingsummary = 'moderate bleeding'
				ELSE IF @BleedingSeverity = 3 SET @bleedingsummary = 'severe bleeding'
				ELSE SET @bleedingsummary = 'bleeding'

				IF @BleedingColdSalineUsed = 1 OR @BleedingBlockingDeviceUsed = 1 OR @BleedingAdrenalineUsed = 1
				BEGIN
					SET @actiontakensummary = ' (action taken: '

					IF @BleedingColdSalineUsed = 1 SET @actiontakensummary = @actiontakensummary + '$$cold saline'
					IF @BleedingBlockingDeviceUsed = 1 SET @actiontakensummary = @actiontakensummary + '$$blocking device used'
					IF @BleedingAdrenalineUsed = 1
					BEGIN
						SET @actiontakensummary = @actiontakensummary + '$$adrenaline used'
						IF @BleedingAdrenalineAmount > 0 SET @actiontakensummary = @actiontakensummary + ' ' + CONVERT(VARCHAR, @BleedingAdrenalineAmount) + ' ml'
					END
					SET @actiontakensummary = @actiontakensummary + ')'

					-- Remove the first occurence of $$
					IF CHARINDEX('$$', @actiontakensummary) > 0 SET @actiontakensummary = REPLACE(@actiontakensummary, ': $$', ': ')
					-- Set the last occurence of $$ to "and"
					IF CHARINDEX('$$', @actiontakensummary) > 0 SET @actiontakensummary = STUFF(@actiontakensummary, len(@actiontakensummary) - charindex('$$', reverse(@actiontakensummary)), 2, ' and ')
					-- Replace all other occurences of $$ with commas
					IF CHARINDEX('$$', @actiontakensummary) > 0 SET @actiontakensummary = REPLACE(@actiontakensummary, '$$', ', ')
				END
				INSERT INTO #Complications VALUES ('Bleeding', @bleedingsummary + @actiontakensummary, 1)
			  END

              IF (SELECT COUNT(*) FROM #Complications) > 0
              BEGIN
                     -- Get the concatenated string separated by a delimiter, say $$
                     SELECT @summaryTemp = COALESCE (
                                                       CASE WHEN @summaryTemp = '' THEN ComplicationsItemDesc
                                                       ELSE @summaryTemp + '$$' + ComplicationsItemDesc END
                                                ,'')
                     FROM #Complications

                     --IF @PerforationText <> '' SET @summaryTemp = REPLACE(@summaryTemp, 'Perforation' , 'perforation (site: ' + @PerforationText + ')')
                     --IF @ComplicationsOtherText <> '' SET @summaryTemp = REPLACE(@summaryTemp, 'Other' , @ComplicationsOtherText)
                     

                     --IF @DamageToScopeType > 0
                     --BEGIN
                     --      SET @summaryTemp2 = ''
                     --      IF @DamageToScopeType = 1 
                     --             SET @summaryTemp2 = 'Damage to scope (mechanical)'
                     --      ELSE IF @DamageToScopeType = 2 
                     --             SET @summaryTemp2 = 'Damage to scope (patient initiated)'
                     --      SET @summaryTemp = REPLACE(@summaryTemp, 'Damage to scope' , @summaryTemp2)
                     --END

              END
			  IF @TechnicalFailure <> '' 
				IF @summaryTemp = ''
					SET @summaryTemp = @summaryTemp + 'technical failure (' + @TechnicalFailure + ')'
				ELSE
					SET @summaryTemp = @summaryTemp + '$$technical failure (' + @TechnicalFailure + ')'

              -- Set the last occurence of $$ to "and"
              IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = STUFF(@summaryTemp, len(@summaryTemp) - charindex('$$', reverse(@summaryTemp)), 2, ' and ')
              -- Replace all other occurences of $$ with commas
              IF CHARINDEX('$$', @summaryTemp) > 0 SET @summaryTemp = REPLACE(@summaryTemp, '$$', ', ')

              DROP TABLE #Complications

              --finally, add to the main summary field
              IF @summaryTemp <> ''
              BEGIN
				  UPDATE ERS_UpperGIQA SET ComplicationsSummary = 'Complications: ' + @summaryTemp WHERE ProcedureId = @ProcedureId
				  IF @summary = '' SET @summary = 'Complications: ' + @summaryTemp
				  ELSE SET @summary = @summary + '. <br/>Complications: ' + @summaryTemp
              END
			  ELSE
			  BEGIN
				UPDATE ERS_UpperGIQA SET ComplicationsSummary = '' WHERE ProcedureId = @ProcedureId
			  END
       END

       --PRINT @summary

       --Update the summary column in diagnoses table and procedures table
       UPDATE ERS_UpperGIQA
       SET Summary = @summary 
       WHERE ProcedureId = @ProcedureId

       EXEC procedure_summary_update @procedureID

GO-----------------------------------------------------------------------------------------------------------
-- Bug 192 CO2 insufflation not displayed on report
EXEC DropIfExist 'common_bowelprep_summary_update','S';
GO

CREATE PROCEDURE [dbo].[common_bowelprep_summary_update]
(
	@ProcedureId INT
)
AS
SET NOCOUNT ON
DECLARE		
	@OnNoBowelPrep bit,
    @OnFormulation int,
    @onright int,
    @OnTransverse int,
    @OnLeft int,
    @OnTotalScore int,
	@OffNoBowelPrep bit,
    @OffFormulation int,
    @BowelPrepQuality int,
	@Summary varchar(5000),
	@BowelSettings bit,
	@CO2Insufflation bit

	SELECT 
		@OnNoBowelPrep = OnNoBowelPrep,
        @OnFormulation = cast(OnFormulation as int),
		@onright =onright,
		@OnTransverse =OnTransverse ,
		@OnLeft  = OnLeft,
		@OnTotalScore = OnTotalScore,
		@OffNoBowelPrep = OffNoBowelPrep,
		@OffFormulation = cast(OffFormulation as int),
		@BowelPrepQuality = BowelPrepQuality,
		@BowelSettings = BowelPrepSettings,
		@CO2Insufflation = CO2Insufflation
	FROM
		[ERS_BowelPreparation]
	WHERE
		ProcedureId = @ProcedureId

	--SELECT @BowelSettings = s.[BostonBowelPrepScale] FROM [ERS_SystemConfig] as s LEFT JOIN [ERS_Procedures] as p ON s.[HospitalID] = p.[OperatingHospitalID] WHERE p.[ProcedureId] = @ProcedureID
	SET @Summary = ''

	IF @BowelSettings = 1
		BEGIN
		IF @OnNoBowelPrep = 1
			BEGIN
			SET @Summary =  'No bowel preparation.'
			END
		ELSE
			BEGIN
			SET @Summary = '<b><font color=''#0072c6''>Bowel Preparation</font></b><br/>'
			IF @OnFormulation > 0 SET @Summary = @Summary +  (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Bowel_Preparation' AND [ListItemNo] = @OnFormulation ) + '<br />'
			SET @Summary = @Summary + 'Boston Bowel Prep Total Score ' +  cast( @OnTotalScore as varchar(10))
			IF @CO2Insufflation = 1 SET @Summary = @Summary + ' The colon was insufflated with CO2.'
			END
		END
	ELSE
		BEGIN
		IF @OffNoBowelPrep = 1
			BEGIN
			SET @Summary = 'No bowel preparation.'
			END
		ELSE
			BEGIN
				SET @Summary = 'Bowel preparation'
				IF @OffFormulation > 0 SET @Summary = @Summary + ' with ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Bowel_Preparation' AND [ListItemNo] = @OffFormulation)
				DECLARE @Quality VARCHAR(50)
				SELECT @Quality	= ListItemText FROM ERS_Lists WHERE ListDescription = 'Bowel_Preparation_Quality' AND ListItemNo = @BowelPrepQuality
				IF (@Quality IS NOT NULL)
				BEGIN
					SET @Summary = @Summary + ' was ' + LOWER(@Quality) + '.'
				END
				IF @CO2Insufflation = 1 SET @Summary = @Summary + ' The colon was insufflated with CO2.'
			END
		END

	UPDATE  [ERS_BowelPreparation] SET Summary = @Summary WHERE ProcedureID=@ProcedureId
	UPDATE [ERS_ProceduresReporting] SET [PP_Bowel_Prep] = @Summary WHERE ProcedureID=@ProcedureId
	EXEC procedure_summary_update @ProcedureId
GO

EXEC DropIfExist 'tvfNED_ProcedureIndication', 'F';
GO
-----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[tvfNED_ProcedureIndication]
(
	@ProcedureId AS INT
)
-- =============================================
-- Description:	This will return the list of 'Indication' for each Procedure- required for NED Export!
-- =============================================
RETURNS TABLE 
AS
RETURN 
(
	SELECT	  UP.ProcedureId
			, IT.Indication
			, IT.NedName
			, NULL AS Comment
			, IndicationID
	FROM 
		(SELECT        P.ProcedureId, 
			CASE WHEN UT.ColonAbdominalMass = 1 THEN 0 END																		AS AbdominalMass,
			CASE WHEN UT.AbdominalPain = 1 OR UT.ERSAbdominalPain = 1 OR UT.ColonAbdominalPain = 1 THEN 1 END					AS AbdominalPain,
			CASE WHEN UT.ERSAbnormalEnzymes=1 THEN 2 END																		AS AbnormalLiverEnzymes,
			CASE WHEN UT.ColonAbnormalSigmoidoscopy = 1 THEN 3 END																AS AbnormalSigmoidoscopy,
			CASE WHEN UT.AbnormalityOnBarium = 1 OR UT.ColonAbnormalBariumEnema = 1 OR UT.ColonAbnormalCTScan = 1 THEN 4 END	AS AbnormalityOnBarium,
			CASE WHEN UT.ERSAcutePancreatitis = 1 THEN 5 END																	AS AcutePancreatitis,
			CASE WHEN UT.AmpullaryMass = 1 THEN 6 END																			AS AmpullaryMass,
			CASE WHEN UT.Anaemia = 1 OR UT.ColonAnaemia = 1	THEN 7 END															AS Anaemia, 
			CASE WHEN UT.BarrettsOesophagus = 1 THEN 8 END																		AS BarrettsOesophagus,
			CASE WHEN UT.ColonBowelCancerScreening = 1 OR UT.ColonSreeningColonoscopy = 1 THEN 9 END							AS BCSP,
			CASE WHEN UT.ERSBileDuctInjury = 1 THEN 10 END																		AS BileDuctInjury,
			CASE WHEN UT.BiliaryLeak = 1 THEN 11 END																			AS BileDuctLeak,
			CASE WHEN UT.ERSCholangitis = 1 THEN 12 END																			AS Cholangitis,
			CASE WHEN ColonAlterBowelHabit = 4 THEN 13 END																		AS ChronicAlternatingDiarrhoea,
			CASE WHEN UT.ERSChronicPancreatisis = 1 THEN 14 END																	AS ChronicPancreatitis,
			CASE WHEN P.ProcedureType IN (3, 13, 4) AND UT.Cancer = 1 THEN 15 END												AS Cancer,
			CASE WHEN ColonAlterBowelHabit = 2 THEN 16 END																		AS ConstipationAcute,
			CASE WHEN ColonAlterBowelHabit = 5 THEN 17 END																		AS ConstipationChronic,
			CASE WHEN UT.ColonDefaecationDisorder = 1 THEN 18 END																AS DefaecationDisorder,
			CASE WHEN UT.Diarrhoea = 1 THEN 19 END																				AS Diarrhoea,
			CASE WHEN ColonAlterBowelHabit = 3 THEN 20 END																		AS DiarrhoeaAcute,
			CASE WHEN ColonAlterBowelHabit = 6 AND ColonRectalBleeding = 0 THEN 21 END											AS DiarrhoeaChronic,
			CASE WHEN ColonAlterBowelHabit = 6 AND ColonRectalBleeding > 0 THEN 22 END											AS DiarrhoeaChronicWithBlood,
			CASE WHEN UT.Dyspepsia = 1 OR UT.DyspepsiaAtypical = 1 OR UT.DyspepsiaUlcerType = 1 THEN 23 END						AS Dyspepsia, 
			CASE WHEN UT.Dysphagia = 1 THEN 24 END																				AS Dysphagia, 
			CASE WHEN UT.ColonFOBT = 1 THEN 25 END																				AS FOBT,
			CASE WHEN UT.UlcerHealing = 1 THEN 26 END																			AS UlcerHealing,
			CASE WHEN UT.GallBladderMass = 1 THEN 27 END																		AS GallbladderMass,
			CASE WHEN UT.GallBladderPolyp = 1 THEN 28 END																		AS GallbladderPolyp,
			CASE WHEN UT.Haematemesis = 1 THEN 29 END																			AS Haematemesis, 
			CASE WHEN UT.RefluxSymptoms = 1 THEN 30 END																			AS RefluxSymptoms,
			CASE WHEN UT.ERSHepaticMass = 1 THEN 31 END																			AS HepatobiliaryMass,
			CASE WHEN IsNull(UT.ColonAssessmentType, 0) >0 THEN 32 END															AS IBDAssessment,
			CASE WHEN UT.ERSJaundice = 1 THEN 33 END																			AS Jaundice,
			CASE WHEN UT.Melaena = 1 OR ColonMelaena = 1 THEN 34 END															AS Melaena,
			CASE WHEN UT.NauseaAndOrVomiting = 1 THEN 35 END																	AS NauseaAndOrVomiting,
			CASE WHEN UT.Odynophagia = 1 THEN 36 END																			AS Odynophagia,
			CASE WHEN UT.ERSPancreaticMass = 1 THEN 38 END																		AS PancreaticMass,
			CASE WHEN UT.ERSPancreaticPseudocyst = 1 THEN 39 END																AS PancreaticPseudocyst,
			CASE WHEN UT.ERSPancreatobiliaryPain = 1 THEN 40 END																AS PancreatobiliaryPain,
			CASE WHEN UT.ERSPapillaryDysfunction = 1 THEN 41 END																AS PapillaryDysfunction,
			CASE WHEN UT.PEGReplacement	= 1	THEN 42 END																			AS PEGChange,
			CASE WHEN UT.JejunostomyInsertion=1 OR UT.PEGReplacement = 1 THEN 43 END											AS PEGPlacement,
			CASE WHEN UT.PEGRemoval	= 1 THEN 44 END																				AS PEGRemoval,
			CASE WHEN UT.ColonPolyposisSyndrome	= 1 THEN 45 END																	AS PolyposisSyndrome,
			CASE WHEN UT.PositiveTTG_EMA = 1 THEN 46 END																		AS PositiveTTG_EMA,
			CASE WHEN UT.ColonRectalBleeding>=1 AND UT.ColonRectalBleeding= 
				(SELECT el.ListItemNo 
				 FROM dbo.ERS_Lists el 
				 WHERE LOWER(el.ListItemText) = 'altered blood [ned]') THEN 47 END												AS BleedAltered,
			CASE WHEN UT.ColonRectalBleeding>=1 AND UT.ColonRectalBleeding= 
				(SELECT el.ListItemNo 
				 FROM dbo.ERS_Lists el 
				 WHERE LOWER(el.ListItemText) = 'anorectal bleeding [ned]')	THEN 48 END											AS BleedAnorectal,
			CASE WHEN UT.ERSPrelaparoscopic = 1	THEN 49 END																		AS PreLapCholedocholithiasis,
			CASE WHEN UT.ColonPolyps = 1 THEN 50 END																			AS PreviousPolyps,	
			CASE WHEN UT.ERSPriSclerosingChol = 1 THEN 51 END																	AS PrimarySclerosingCholangitis,
			CASE WHEN UT.ERSPurulentCholangitis = 1 THEN 52 END																	AS PurulentCholangitis,
			CASE WHEN UT.ERSStentOcclusion = 1 THEN 53 END																		AS StentDysfunction,
			CASE WHEN P.ProcedureType IN (1, 3, 13, 4) AND UT.StentReplacement = 1 THEN 56 END									AS StentReplacement,
			CASE WHEN P.ProcedureType IN (1, 3, 13, 4) AND UT.StentInsertion = 1 THEN 54 END									AS StentInsertion,  
			CASE WHEN P.ProcedureType IN (1, 3, 13, 4) AND UT.StentRemoval = 1 THEN 55 END										AS StentRemoval,
			CASE WHEN UT.ColonTumourAssessment = 1 THEN 57 END																	AS TumourAssessment,
			CASE WHEN UT.OesophagealVarices = 1 THEN 58 END																		AS OesophagealVarices,
			CASE WHEN UT.ColonWeightLoss = 1 OR UT.WeightLoss = 1 THEN 59 END													AS WeightLoss
		FROM            dbo.ERS_Procedures P (NOLOCK)
			LEFT OUTER JOIN dbo.ERS_UpperGIIndications UT (NOLOCK) ON P.ProcedureId = UT.ProcedureId
			Where UT.ProcedureId = @ProcedureId
			) 
		AS PT UNPIVOT 
		(IndicationID FOR Therapies IN (AbdominalMass,
										AbdominalPain,
										AbnormalLiverEnzymes,
										AbnormalSigmoidoscopy,
										AbnormalityOnBarium,
										AcutePancreatitis,
										AmpullaryMass,
										Anaemia, 
										BarrettsOesophagus,
										BCSP,
										BileDuctInjury,
										BileDuctLeak,
										Cholangitis,
										ChronicAlternatingDiarrhoea,
										ChronicPancreatitis,
										Cancer,
										ConstipationAcute,
										ConstipationChronic,
										DefaecationDisorder,
										Diarrhoea,
										DiarrhoeaAcute,
										DiarrhoeaChronic,
										DiarrhoeaChronicWithBlood,
										Dyspepsia, 
										Dysphagia, 
										FOBT,
										UlcerHealing,
										GallbladderMass,
										GallbladderPolyp,
										Haematemesis, 
										RefluxSymptoms,
										HepatobiliaryMass,
										IBDAssessment,
										Jaundice,
										Melaena,
										NauseaAndOrVomiting,
										Odynophagia,
										PancreaticMass,
										PancreaticPseudocyst,
										PancreatobiliaryPain,
										PapillaryDysfunction,
										PEGChange,
										PEGPlacement,
										PEGRemoval,
										PolyposisSyndrome,
										PositiveTTG_EMA,
										BleedAltered,
										BleedAnorectal,
										PreLapCholedocholithiasis,
										PreviousPolyps,	
										PrimarySclerosingCholangitis,
										PurulentCholangitis,
										StentDysfunction,
										StentReplacement,
										StentInsertion,  
										StentRemoval,
										TumourAssessment,
										OesophagealVarices,
										WeightLoss)
		) 
		AS UP 
		LEFT OUTER JOIN	dbo.ERS_IndicationTypes IT ON UP.IndicationID = IT.Id

	
		UNION ALL	--## Get the 'Other' Row seperately!

		SELECT	  @ProcedureId AS ProcedureId
				, 'Other' AS Indication
				, 'Other' AS NedName
				, dbo.fnNED_GetOtherTypeIndications(@ProcedureId) AS Comment
				, 0 AS IndicationID
		where dbo.fnNED_GetOtherTypeIndications(@ProcedureId) != ''
);

GO

-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'usp_NED_Generate_Report', 'S';
GO
-----------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[usp_NED_Generate_Report]
(
	@ProcedureId AS INT
)
AS
BEGIN
	SET NOCOUNT ON;

/*
	<xs:schema xmlns="http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd" 
	xmlns:mstns="http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	targetNamespace="http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd" 
	elementFormDefault="qualified" 
	id="SendBatchMessageFile">		

*/
Declare @site AS VARCHAR(50);
DECLARE 
		@description	AS VARCHAR(1000),
		@uniqueid		AS VARCHAR(15),
		@previousLocalProcedureId AS VARCHAR(15),
		@PatientId		AS INT,
		@sessionType	AS VARCHAR(50),
		@operatingHospitalId AS INT,
		@ExportFolderPath AS VARCHAR(100);	--## XML Export Folder path.. Set by Admin in the [ERS_SystemConfig] Table

DECLARE @returnXML XML;

	Set @description = 'NED List';
	SELECT @operatingHospitalId = OperatingHospitalId FROM ERS_Procedures WHERE ProcedureId = @ProcedureId;
	SELECT @site = [NED_HospitalSiteCode], @ExportFolderPath=[NED_ExportPath] FROM [dbo].[ERS_SystemConfig] WHERE OperatingHospitalId = @operatingHospitalId;

	SELECT @uniqueid = RIGHT(('00000' + CAST(@ProcedureId AS VARCHAR(6))),6) --## Procedure Id
							+ RIGHT(('0' + CAST(ProcedureType AS VARCHAR(2))),2)  --## Procedure Type; ie: OGD=1/ERCP=2/COLON=3/FLEXI=13
								+ (CASE ProcedureType	WHEN  1 THEN 'o' 
														WHEN  2 THEN 'e' 
														WHEN  3 THEN 'c'
														WHEN  4 THEN 's'
														WHEN 13 THEN 'f'
									END)	--## Procedure Letter
		 , @sessionType=Case ListType	When 1 Then 'Dedicated Training List' 
										When 2 Then 'Adhoc Training List' 
											   Else 'Service List' End 
		, @PatientId = PatientId
	From dbo.ERS_Procedures Where ProcedureId=@ProcedureId;


	--## UniqueId is generated- so UPDATE this new value now in the ERS_Procedures Table
	UPDATE dbo.ERS_Procedures
	SET [NEDProcedureId] = @uniqueid
	WHERE ProcedureId=@ProcedureId;

	--## Now get the Previous NED Unique Id- of the same Patient... We know the Patient Id already! Use it!!
	SELECT @previousLocalProcedureId = IsNull([NEDProcedureId], '') 
			 FROM dbo.ERS_Procedures 
			WHERE PatientId = @PatientId AND ProcedureId<@ProcedureId
		 ORDER BY ProcedureID DESC;

	print '@uniqueid: ' + @uniqueid;

SET @returnXML=(
SELECT 
	  @uniqueid											AS '@uniqueId'
	, @description										AS '@description'
	, REPLACE(convert(varchar, getdate(), 106), ' ', '/')	AS '@date'	--### '10 Oct 2020' ==> '10/Oct/2020'
	, (CASE WHEN (DATEPART(hour, P.ModifiedOn))<13 THEN 'AM' ELSE 'PM' END)	AS '@time'
	, @sessionType										AS '@type'	-- SessionTypeEnum
	, @site												AS '@site'	--## Hospital Code

	/*	##### Procedure info	*/
	, (
	Select 
		  @uniqueid										AS '@localProcedureId'
		, @previousLocalProcedureId						AS '@previousLocalProcedureId'
		, (CASE P.ProcedureType WHEN 1 THEN 'OGD' WHEN 2 THEN 'ERCP' WHEN 3 THEN 'COLON' WHEN 13 THEN 'FLEXI' WHEN 4 THEN 'FLEXI' END) AS '@procedureName'

		, Case QA.PatDiscomfortEndo		When 6 Then 'Severe' When 5 Then 'Moderate' When 4 Then 'Mild' When 3 Then 'Minimal' When 2 Then 'Comfortable' Else 'Not Specified' End As '@endoscopistDiscomfort'
		, Case QA.PatDiscomfortNurse	When 6 Then 'Severe' When 5 Then 'Moderate' When 4 Then 'Mild' When 3 Then 'Minimal' When 2 Then 'Comfortable' Else 'Not Specified' End As '@nurseDiscomfort'
		, CASE WHEN P.ProcedureType IN(3,13) THEN (Case BP.BowelPrepQuality	When 1 Then 'inadequate' When 2 Then 'fair' When 3 Then 'good'  WHEN 4 THEN 'excellent' Else 'Not Specified' END) ELSE NULL END As '@bowelPrep'
		, dbo.fnNED_ProcedureExtent(@ProcedureId, 0)					AS '@extent'	--## OverAll Extent info - EE/ER- whoever has gone Furthest distance!!
		, (CASE WHEN Drug.entonox IS NULL THEN 'No' ELSE 'Yes' END)		AS '@entonox'	--## '06/10/2017 UGI - Entonox added
		, CASE WHEN ISNULL((Select DrugNo from ERS_UpperGIPremedication where ProcedureId = @ProcedureID and DrugNo = -2), 0) = -2 THEN 'Yes' ELSE 'No' END AS '@generalAnaes'
		, (CASE WHEN P.ProcedureType IN (1, 3, 13) THEN (SELECT IsNull(SUM([Detected]), 0) from dbo.tvfNED_PolypsDetailsView(P.ProcedureType, @ProcedureId)) ELSE 0 END)  As '@polypsDetected' --## Applies to OGD, Colon and Flexi.
		, (CASE WHEN P.ProcedureType IN(3,13) THEN (CASE EL.RectalExam When 1 Then 'Yes' When 0 Then 'No' Else NULL End) END)  As '@digitalRectalExamination' -- ers_colon_extentOfIntubation
		, (CASE WHEN P.ProcedureType IN(3,13) THEN (CASE ScopeGuide WHEN 1 THEN 'Yes' ELSE 'No' END) END) AS '@magneticEndoscopeImagerUsed'
		, (CASE WHEN P.ProcedureType IN(3,13) THEN (case when ISNULL(EL.TimeForWithdrawalMin_Photo, EL.TimeForWithdrawalMin) = 0 then EL.NED_TimeForWithdrawalMin END + (Case When case when ISNULL(EL.TimeForWithdrawalSec_Photo, EL.TimeForWithdrawalSec) = 0 then EL.NED_TimeForWithdrawalSec end >30 Then 1 Else 0 End)) END	)  As '@scopeWithdrawalTime' --## Applies to Colon only
		/*	##### Patient Info	*/		
		, (CASE Pat.Gender WHEN 'Not Known' THEN 'Unknown' WHEN 'Not Specified' THEN 'Unknown' ELSE Pat.Gender END)		AS 'patient/@gender'
		, (0+ FORMAT(getdate(),'yyyyMMdd') - FORMAT(Pat.DateOfBirth,'yyyyMMdd') ) /10000 AS 'patient/@age'
		, (Case P.PatientStatus	When 1 Then 'Inpatient' 
								When 2 Then 'Outpatient' 
								When 3 Then 'Not Specified' 
			End)											AS 'patient/@admissionType'
		, (CASE P.CategoryListId	WHEN 2 THEN 'Urgent' 
									WHEN 3 THEN 'Emergency' 
									WHEN 1 THEN 'Routine' 
									WHEN 4 THEN 'Surveillance' 
									ELSE 'Not Specified' 
			END)											AS 'patient/@urgencyType'

		/*	##### Drugs	*/
		, IsNull(Drug.pethidine,0)	As 'drugs/@pethidine'	--## Required
		, IsNull(Drug.midazolam,0)	As 'drugs/@midazolam'	--## Req
		, IsNull(Drug.fentanyl,0)	As 'drugs/@fentanyl'	--## Req
		, Drug.buscopan				As 'drugs/@buscopan'	--## Optional; Let the following be NULL
		, Drug.propofol				As 'drugs/@propofol'
		, Drug.flumazenil				As 'drugs/@flumazenil'
		, Drug.noDrugsAdministered	As 'drugs/@noDrugsAdministered'
		/*	##### Staff.Members: 1 Procedure to MANY staff.. So - need a SQL Subquery- to return a RecordSet		*/
		,(
			SELECT 
			  Staff.professionalBodyCode AS '@professionalBodyCode'
			, Staff.EndoscopistRole		AS '@endoscopistRole'
			, Staff.ProcedureRole		AS '@procedureRole'	-- ProcedureRoleTypeEnum
			, Staff.Extent				AS '@extent'
			, (CASE WHEN P.ProcedureType <> 2 THEN Staff.[jManoeuvre] ELSE NULL END)		AS '@jManoeuvre'	-- Opt -- Mandatory for OGD, Colon and Flexi procedures (Rectal retroversion)
			/*	##### Therapeutic = Sesion->Procedure-> Staff.members-> Staff-> Therapeutic; 1 [Staff] to Many [Therapeutic sessions]	*/
			, (
				Select * from (select 
					   T.NedName	AS '@type'	-- M	--## The type of therapeutic procedure.
					 , CASE WHEN rc.RegionId IS NULL THEN T.[Site] ELSE 'Ileo-colon anastomosis' END		AS '@site'	-- O -- BiopsyEnum  --## The location where the therapeutic procedure was performed.
					 , T.EndoRole AS '@role' -- O	-- ProcedureRoleTypeEnum
					 , T.polypSize	AS '@polypSize' -- O	-- PolypSizeEnum --## The size of polyp (if found) -> is ONLY for COLON/FLEXI
					 , T.Tattooed	AS '@tattooed'	-- O	-- TattooEnum
					 , sum(T.Performed)	AS '@performed'	-- M	-- REQUIRED; INT	-- ## Number performed
					 , sum(T.Successful)	AS '@successful' -- M	-- REQUIRED; INT -- Number of successful
					 , sum(T.Retrieved)	AS '@retrieved'	-- O	-- INT	-- ## Number of Polyp retrieved -> is ONLY for COLON/FLEXI
					 , T.comment 	AS '@comment'	-- O	--## Use this field to define what “Other” is when selected.

				FROM dbo.tvfNED_ProcedureTherapeutic(P.ProcedureType, @ProcedureId, Staff.ConsultantTypeId) AS T --## Which Consultant's Record in the Procedure?
					LEFT JOIN dbo.ERS_Sites ES ON es.SiteId = T.SiteId
					LEFT JOIN tvfProcedureResectedColon(@ProcedureId) RC ON RC.RegionId = ES.RegionId
				group by T.NedName, 
						CASE WHEN rc.RegionId IS NULL THEN T.[Site] ELSE 'Ileo-colon anastomosis' END,
						T.EndoRole,
						T.polypSize, 
						T.Tattooed, 
						T.comment) as a
				FOR XML PATH('therapeutic'), ROOT('therapeutics'), TYPE
			)/* End of: Therapeutic List- for a Staff Member		*/
			FROM dbo.tvfNED_ProcedureConsultants(@ProcedureId, P.ProcedureType) AS Staff
			WHERE Staff.EndosId > 0
			FOR XML PATH('Staff'), ROOT('staff.members'), TYPE
		)
			
			/*	##### Indications: -- 1 or Many	*/		
			, (
				SELECT 
					  I.NedName As '@indication'
					, i.Comment AS '@comment'
					FROM dbo.tvfNED_ProcedureIndication(@ProcedureId) AS I
					FOR XML PATH('indication'), ROOT('indications'), TYPE
			)
			/*	##### Limitations: Colon/Flexi ONLY		-- 0 or Many	*/
			,(
				Select 	
					  L.Limitation As '@limitation'
					, L.Comment As '@comment'
				from [dbo].[tvfNED_ProcedureLimitation](P.ProcedureType, @ProcedureId) AS L
					FOR XML PATH('limitation'), ROOT('limitations'), TYPE
			)	
			/*	##### Biopsy: 0 or Many		*/ --## For Colon/Flexi/OGD. Not for ERCP!
			, (	SELECT 
						  B.BiopsySite		AS '@biopsySite'
						, B.NumberPerformed AS '@numberPerformed'
					FROM [dbo].[tvfNED_ProcedureBiopsy](p.ProcedureType, @ProcedureId) AS B				
					 FOR XML PATH('Biopsy'), ROOT('biopsies'), TYPE
			)
			/*	##### Diagnoses: 1 or Many		*/ 
			, (	SELECT 
						  D.Ned_Name	AS '@diagnosis'
						, D.tattooed	AS '@tattooed'
						, D.Site		AS '@site'
						, CASE WHEN RIGHT(D.Comment,2)=', ' 
							THEN (LEFT(D.Comment, LEN(D.Comment)-1)) 
							ELSE D.Comment END
									AS '@comment'	--## Remove the extra ',' at the end!
					FROM [dbo].[tvfNED_Diagnoses](p.ProcedureType, @ProcedureId) AS D
					 FOR XML PATH('Diagnose'), ROOT('diagnoses'), TYPE
			)
			/*	##### Adverse events: -- 1 or Many	*/
			,(	SELECT 
					  IsNull(AD.adverseEvent,'None')	As '@adverseEvent'
					, (CASE WHEN AD.adverseEvent = 'Other' THEN AD.Comment END) 						As '@comment'
				FROM dbo.tvfNED_ProcedureAdverseEvents(@ProcedureId)		AS AD
				FOR XML PATH('adverse.event'), ROOT('adverse.events'), TYPE			
			)
		from ERS_Procedures AS P Where P.ProcedureId=@ProcedureId
		FOR XML PATH('procedure'), ROOT('procedures'), TYPE
		)	
		FROM dbo.ERS_Procedures AS P
  INNER JOIN dbo.ERS_VW_Patients			AS Pat  ON P.PatientId=Pat.[PatientId]
   LEFT JOIN dbo.tvfNED_ProcedureDrugList(@ProcedureId)	AS Drug		ON P.ProcedureId = Drug.ProcedureId	
   LEFT JOIN dbo.ERS_UpperGIQA				AS QA   ON P.ProcedureId = QA.ProcedureId	-- Patient DIscomfort
   LEFT JOIN dbo.ERS_BowelPreparation		AS BP   ON P.ProcedureId=BP.ProcedureID	-- DIscomfort for Nurse
   LEFT JOIN dbo.ERS_ColonExtentOfIntubation   EL	ON P.ProcedureId = EL.ProcedureId
	   where P.ProcedureId= @ProcedureId
		 for XML PATH ('session'), ROOT('hospital.SendBatchMessage'), ELEMENTS
);

DECLARE   @xmlFileName AS varchar(100)
		, @ReportDate AS VARCHAR(10)
		, @ReportTime AS VARCHAR(8)
		, @xmlPreviousExportFileName AS VARCHAR(100);

SELECT    @ReportDate = CONVERT(VARCHAR(10), CreatedOn, 103)
		, @ReportTime = CONVERT(VARCHAR(8), ModifiedOn, 108) 
FROM dbo.ERS_Procedures WHERE ProcedureId=@ProcedureId;

--== Check whether Admin has added/removed the '\' at the end of the Path.. 
SET @ExportFolderPath = (CASE WHEN RIGHT(@ExportFolderPath, 1)='\' THEN @ExportFolderPath ELSE (@ExportFolderPath + '\') END);

SELECT top 1 @xmlPreviousExportFileName = xmlFileName FROM [dbo].[ERS_NedFilesLog] WHERE ProcedureId=@ProcedureId ORDER BY [LogId] desc;

--### File Path and Name example: 'NED_xml_output\74_22-09-2017_09-32-53_00831101o.xml' vs '99_19-10-2017_16-24-16_00205602e.xml'
SET @xmlFileName =    @ExportFolderPath 
					+ @site + '_' 
					+ replace(@ReportDate, '/', '-') + '_' 
					+ replace(@ReportTime, ':', '-') + '_' 
					+ @uniqueid	
					+ '.xml';					

SELECT @returnXML AS returnXML
				 , '<hospital.SendBatchMessage xmlns:xsd="http://www.w3.org/2001/XMLSchema"'
				  + 
				 ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
				  +
				 ' xmlns="http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd"' AS NS_Info		--## These extra info will be added to the Actual XML file in .NET while exporting;
				 , @xmlFileName AS xmlFileName
				 , IsNull(@xmlPreviousExportFileName, 'x') AS PreviousFileName;

END
GO
-----------------------------------------------------------------------------------------------------------
-- Polyp size of 20mm now correctly displaying as 20 or greater
-- Polyp unsuccessful if not Retrieved
EXEC DropIfExist 'tvfNED_ProcedureTherapeutic', 'F';
GO
-----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[tvfNED_ProcedureTherapeutic]
(	
	  @ProcedureType AS INT
	, @ProcedureId AS INT
	, @CarriedOutRole AS INT --## 1: Endo1; 2: Endo2
)
RETURNS TABLE 
AS
RETURN 
(

WITH CTE AS ( --## Just wrapping the selection in the CTE to use later for a COUNT() operation
	
	SELECT      
		  UP.ProcedureId
		, UP.ProcedureType
		, UP.SiteId
		, UP.[Site] AS Saite
		, dbo.fnNED_GetBiopsySiteName(UP.ProcedureId, UP.[Site]) As [Site]
		--, UP.TherapyTypeId
		--, TT.[Description]
		, TT.NedName
		, UP.EndoRole 
		--, UT_CarriedOutRole
		--, ERCP_CarriedOutRole
		, (CASE WHEN TT.NedName LIKE 'Polyp%' THEN UP.Tattooed ELSE NULL END) AS Tattooed
		, (CASE WHEN TT.NedName LIKE 'Stent placement%' then COALESCE(UGI_StentQty, ER_StentQty)				else 1 END) AS StentPerformed --## 'Stent Placement' for O/C/F; And 'Stent placement - pancreas/CBD' for ERCP
		--, UGI_StentQty, ER_StentQty --#############
		, dbo.fnNED_GetTherapTypeSuccess(ProcedureType, SiteId, @CarriedOutRole, NedName) AS Successful
		, (CASE WHEN UP.TherapyTypeId=2 THEN	--## Any Therap in 'Other' Category
			dbo.fnNED_GetOtherTypeTheraps(ProcedureType, UP.SiteId, @CarriedOutRole) 
			END --## ELSE Return NULL... Should only be available when 'Other' Therap is present
		  ) AS Comment
	FROM            
		(SELECT			
				P.ProcedureId,  
				P.ProcedureType,
				S.SiteId, 
				R.Region AS [Site], --## Link to [dbo.ERS_Regions] via Sites.Id
				NULL [role]
				, UT.CarriedOutRole											AS UGI_CarriedOutRole
				, ER.CarriedOutRole											AS ERCP_CarriedOutRole				
				, (CASE WHEN L.Tattooed = 1 THEN 'Yes'  WHEN L.PreviouslyTattooed = 1 THEN 'Previously Tattooed' ELSE 'No' END)		AS Tattooed
				, UT.StentInsertionQty										AS UGI_StentQty
				, ER.StentInsertionQty										AS ER_StentQty,
				CASE WHEN (UT.[None] = 1 OR T.[None] = 1) THEN 1 END AS [None], 
				CASE WHEN @ProcedureType IN (1,3,13,4) AND UT.ArgonBeamDiathermy = 1 THEN 3 END								AS ArgonBeamDiathermy, --## C/F/O
				CASE WHEN @ProcedureType IN (1,2,3,13,4) AND (UT.BalloonDilation = 1 OR ER.BalloonDilation = 1) THEN  4 END	AS BalloonDilation,		--## ALL: Balloon sphicteroplasty	
				CASE WHEN @ProcedureType = 2 AND ER.BalloonTrawl = 1 THEN 5 END												AS BalloonTrawl,
				CASE WHEN @ProcedureType = 1 AND (UT.BandLigation = 1 OR UT.VaricealBanding = 1) THEN  6 END					AS BandLigation, 
				CASE WHEN @ProcedureType IN (3,13,4) AND UT.BandingPiles = 1 THEN 7 END										AS BandingPiles,		--## O / C / F
				CASE WHEN @ProcedureType = 1 AND UT.BotoxInjection	= 1 THEN  8 END											AS BotoxInjection,
				CASE WHEN @ProcedureType IN (1,2) and ((UT.OesophagealDilatation=1 AND UT.DilatorType=2)
														OR (ER.BalloonTrawlDilatorType=2 or ER.DilatorType=2)) --## Need to confirm this Logic!
														THEN 9 END															AS BougieDilation, --## O / E	
				CASE WHEN @ProcedureType=2 AND T.BrushCytology = 1 THEN 10 END												AS Brush,
				CASE WHEN @ProcedureType=2 AND ER.Cannulation = 1 THEN 11 END												AS Cannulation,
				CASE WHEN @ProcedureType IN (1,3,13,4) AND UT.Clip = 1 THEN 12 END											AS Clip,
				CASE WHEN @ProcedureType=2 AND ER.RendezvousProcedure = 1 THEN 13 END										AS RendezvousProcedure,
				CASE WHEN @ProcedureType=2 AND ER.DiagCholangiogram	= 1 THEN 14 END											AS DiagCholangiogram,
				CASE WHEN @ProcedureType=2 AND ER.DiagPancreatogram		= 1 THEN 15 END										AS DiagPancreatogram,
				CASE WHEN @ProcedureType=1 AND UT.EMR = 1 THEN 
														(CASE WHEN ISNULL(UT.EMRType, 0)<> 0 THEN 
															(CASE UT.EMRType WHEN 1 THEN 16 ELSE 19 END) 
														END) END															AS EMR,
				CASE WHEN @ProcedureType IN (1,3,13,4) AND UT.EndoloopPlacement = 1 THEN 17 END								AS EndoloopPlacement,
				CASE WHEN @ProcedureType=2 AND ER.EndoscopicCystPuncture = 1 THEN 18 END									AS Cyst,
				CASE WHEN @ProcedureType IN (1,3,13,4) AND UT.ForeignBody = 1 THEN 20 END									AS ForeignBody,
				CASE WHEN @ProcedureType=2 AND ER.Haemostasis = 1 THEN 21 END												AS Haemostasis,
				CASE WHEN @ProcedureType=1 AND UT.HeatProbe = 1 THEN 22 END													AS HeatProbe, 
				CASE WHEN @ProcedureType=1 AND (UT.HotBiopsy = 1 OR T.HotBiopsy = 1) THEN 23 END							AS HotBiopsy,
				CASE WHEN UT.Injection = 1 OR ER.Injection = 1	THEN 24 END													AS Injection,
				CASE WHEN @ProcedureType=2 AND ER.Manometry = 1 THEN 25 END													AS Manometry,
				CASE WHEN @ProcedureType IN (1,3,13,4) AND UT.Marking = 1 THEN 26 END										AS Marking,
				CASE WHEN @ProcedureType=2 AND ER.NasopancreaticDrain = 1 THEN 27 END										AS NasopancreaticDrain,
				CASE WHEN @ProcedureType=1 AND UT.GastrostomyInsertion = 1 AND UT.GastrostomyRemoval = 1 THEN 28 END		AS PEGChange,
				CASE WHEN @ProcedureType=1 AND UT.GastrostomyInsertion = 1 AND UT.GastrostomyRemoval = 0 THEN 29 END		AS PEGInsertion,
				CASE WHEN @ProcedureType=1 AND UT.GastrostomyInsertion = 0 AND UT.GastrostomyRemoval = 1 THEN 30 END		AS PEGRemoval,
				CASE WHEN @ProcedureType IN (3,13,4) AND UT.Polypectomy = 1 AND IsNull(UT.PolypectomyRemovalType, 0) > 0 THEN 
					CASE UT.PolypectomyRemovalType 
													WHEN 2 THEN 35 --## 'Polyp - snare cold'
													WHEN 3 THEN 36 --## 'Polyp - snare hot'
													WHEN 4 THEN 34 --## 'Polyp - hot biopsy'
													WHEN 5 THEN 31 --## 'Polyp - cold biopsy'
													WHEN 6 THEN 32 --## 'Polyp - EMR'
													WHEN 7 THEN 33 --## 'Polyp - ESD'
													--## Notes: EMR and ESD are already dealt above...
					END 
				END																											AS PolypRemovalType, 			
				CASE WHEN @ProcedureType=1 AND UT.Polypectomy = 1 THEN 37 END												AS Polypectomy,			
				CASE WHEN @ProcedureType=1 AND UT.RFA = 1 THEN 38 END														AS RFA, 
				CASE WHEN @ProcedureType=2 AND (ER.PanOrificeSphincterotomy = 1 OR ER.Papillotomy = 1) THEN 39 END			AS Sphincterotomy,
				CASE WHEN @ProcedureType IN (1,2,3,13,4) AND ((UT.StentRemoval = 1 AND UT.StentInsertion = 1) OR
															  (ER.StentRemoval = 1 AND ER.StentInsertion = 1)) THEN 40 END  AS StentChange,
				CASE WHEN @ProcedureType IN (1,3,13,4) AND UT.StentRemoval = 0 AND UT.StentInsertion = 1 THEN 41 END		AS StentPlacement,
				CASE WHEN @ProcedureType=2 AND ER.StentInsertion = 1 AND LOWER(R.Region)='Common bile duct' THEN 42 END 	AS StentPlacementCBD,
				CASE WHEN @ProcedureType=2 AND ER.StentInsertion = 1 AND LOWER(R.Region)<>'Common bile duct' THEN 43 END	AS StentPlacementPAN,
				CASE WHEN @ProcedureType IN (1,2,3,13,4) AND ((UT.StentRemoval = 1 AND UT.StentInsertion = 0) OR
															  (ER.StentRemoval = 1 AND ER.StentInsertion = 0)) THEN 44 END	AS StentRemoval,
				CASE WHEN @ProcedureType=2 AND Abn.StonesSize>= 10 THEN 45 END												AS StoneExtractionGT10, --## Stone Size in mm
				CASE WHEN @ProcedureType=2 AND Abn.StonesSize < 10 THEN 46 END												AS StoneExtractionLT10,
				CASE WHEN @ProcedureType=1 AND UT.VaricealSclerotherapy = 1 THEN 47 END										AS VaricealSclerotherapy,
				CASE WHEN @ProcedureType IN (1,3,13,4) AND UT.YAGLaser = 1 THEN 48 END										AS YAGLaser,

				/* 
					There are many other fields in the OGD/ERCP Therap Tables, but NED isn't interested in each and every Theraps.
					The Valid/Acceptable names are given in the XSD/Documentation file. Few other Theraps are put in 
					the 'Other' Category- instructions found in the Excel file, by Steve!
				*/

				(CASE  
						WHEN P.ProcedureType = 1 THEN							--## OGD / Gastroscopy
							(CASE WHEN 
									(UT.BicapElectro = 1 OR UT.Diathermy = 1 OR UT.PyloricDilatation = 1 OR
									UT.pHProbeInsert = 1 OR UT.EndoClot = 1 OR 
									UT.Haemospray = 1 OR LEN(UT.Other) > 1) THEN 2
								END)
						WHEN P.ProcedureType = 2 THEN							--## ERCP
							(CASE WHEN 
									(ER.SnareExcision = 1 OR 
									ER.YAGLaser = 1 OR ER.ArgonBeamDiathermy = 1 OR
									ER.BandLigation = 1 OR ER.BotoxInjection = 1 OR
									ER.EndoloopPlacement = 1 OR ER.HeatProbe = 1 OR
									ER.BicapElectro = 1 OR ER.Diathermy = 1 OR
									ER.ForeignBody = 1 OR ER.HotBiopsy = 1 OR
									ER.EMR = 1 OR ER.Marking = 1 OR
									ER.Clip = 1 OR ER.PyloricDilatation = 1 OR
									ER.StrictureDilatation = 1 OR ER.GastrostomyInsertion = 1 OR -- GastrostomyInsertion = Nasojejunal tube (NJT) 
									ER.GastrostomyRemoval = 1 OR LEN(ER.Other) > 1  --GastrostomyRemoval = Nasojejunal Removal (NJT) 
									) THEN 2
							  END)
						WHEN P.ProcedureType IN (3, 13, 4) THEN					-- ## COLON / FLEXI
							(CASE WHEN 
									(UT.BandLigation = 1 OR UT.VaricealBanding = 1 OR 
									UT.BotoxInjection = 1 OR UT.HeatProbe = 1 OR
									UT.BicapElectro = 1 OR UT.Diathermy = 1 OR
									UT.HotBiopsy = 1 OR UT.EMR = 1 OR
									UT.Sigmoidopexy = 1 OR UT.EndoClot = 1 OR
									LEN(UT.Other) > 1) THEN 2
							  END)							

				END) AS Other,
				CASE isnull(UT.EndoRole, ER.EndoRole) 
					when 1 then 'Independent'
					when 4 then 'Independent'
					when 2 then (case when @CarriedOutRole = 1 then 'I observed' else 'Was observed' END)
					when 3 then (case when @CarriedOutRole = 1 then 'I assisted' else 'Was assisted' END)
				END	AS EndoRole
			FROM            dbo.ERS_Procedures	AS	P	
				INNER JOIN				[dbo].ERS_Sites					AS  S ON P.ProcedureId = S.ProcedureId 
				LEFT JOIN				[dbo].ERS_Regions				AS  R ON S.RegionId = R.RegionId --## To Get SiteName
				LEFT OUTER JOIN			[dbo].ERS_ERCPTherapeutics		AS ER ON S.SiteId = ER.SiteId -- ER.CarriedOutRole  = @CarriedOutRole
				--LEFT OUTER JOIN			[dbo].ERS_ColonTherapeutics		AS CT ON S.SiteId = CT.SiteId
				LEFT OUTER JOIN				[dbo].ERS_UpperGITherapeutics	AS UT ON S.SiteId = UT.SiteId -- UT.CarriedOutRole  = @CarriedOutRole
				LEFT OUTER JOIN			[dbo].[ERS_ColonAbnoLesions]	AS  L ON S.SiteId = L.SiteId 
				LEFT OUTER JOIN			[dbo].[ERS_UpperGISpecimens]	AS  T ON S.SiteId = T .SiteId
				LEFT OUTER JOIN			[dbo].[ERS_ERCPAbnoDuct]		AS Abn ON S.SiteId = Abn.SiteId
				Where P.ProcedureId= @ProcedureId
				AND (((UT.EndoRole in (1, 2, 3) AND @CarriedOutRole = 1)
				     OR
					 (UT.EndoRole in (2, 3, 4) AND @CarriedOutRole = 2))
					OR
					((ER.EndoRole in (1, 2, 3) AND @CarriedOutRole = 1)
				     OR
					 (ER.EndoRole in (2, 3, 4) AND @CarriedOutRole = 2)))
		) AS PT 
				UNPIVOT (TherapyTypeId FOR Therapies IN 
												([None], Other
												, ArgonBeamDiathermy, BalloonDilation, BandLigation, BotoxInjection, BougieDilation, Clip, EndoloopPlacement, EMR, BandingPiles	--, Colon Fields: (ESD,EMR)
												, ForeignBody, HeatProbe, HotBiopsy,  Marking, PEGChange, PEGInsertion, PEGRemoval, Polypectomy, RFA
												, StentRemoval, StentChange, StentPlacement, YAGLaser, Injection, PolypRemovalType
											--## Add ERCP Fields
												, BalloonTrawl,Brush, Cannulation, RendezvousProcedure, DiagCholangiogram, DiagPancreatogram
												, Cyst, Haemostasis, Manometry, Sphincterotomy, NasopancreaticDrain, StentPlacementCBD, 
												StentPlacementPAN, StoneExtractionGT10, StoneExtractionLT10, VaricealSclerotherapy)
						)  AS UP 
		LEFT JOIN dbo.ERS_TherapeuticTypes TT ON UP.TherapyTypeId = TT.Id
			WHERE 1=1
	) --## End of CTE.. Now just select the desired fields from this CTE

	SELECT ProcedureId, ProcedureType, CTE.SiteId, Saite, [Site], NedName, EndoRole,
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.PolypSizeText ELSE NULL END)		As polypSize,
		Tattooed,
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.Detected ELSE (CASE WHEN StentPerformed>Successful THEN StentPerformed ELSE Successful END) END)		As Performed, --### Successful and Performed should be same!
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.Retrieved ELSE (CASE WHEN StentPerformed>Successful THEN StentPerformed ELSE Successful END) END) AS Successful, --## 'CTE.StentPerformed' watches on the 'Stent placement% (CBD/PAN)' Qty' for Overall level.. better accuracy!
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.Retrieved ELSE NULL END)			As Retrieved,
		Comment 
		FROM CTE
		INNER JOIN (SELECT 
						SiteId, Detected, Retrieved
						, PolypSizeText = (CASE WHEN Size IS NULL OR Size=0 THEN NULL WHEN Size<10 THEN 'ItemLessThan10mm' WHEN Size BETWEEN 10 AND 19 THEN 'Item10to19mm' ELSE 'Item20OrLargermm' END)
					FROM dbo.tvfNED_PolypsDetailsView(@ProcedureType, @ProcedureId) )AS PS ON PS.SiteId = CTE.SiteId

	
	UNION SELECT ProcedureId, ProcedureType, CTE.SiteId, Saite, [Site], NedName, EndoRole,
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.PolypSizeText ELSE NULL END)		As polypSize,
		Tattooed,
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.Detected ELSE (CASE WHEN StentPerformed>Successful THEN StentPerformed ELSE Successful END) END)		As Performed, --### Successful and Performed should be same!
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.Retrieved ELSE (CASE WHEN StentPerformed>Successful THEN StentPerformed ELSE Successful END) END) AS Successful, --## 'CTE.StentPerformed' watches on the 'Stent placement% (CBD/PAN)' Qty' for Overall level.. better accuracy!
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.Retrieved ELSE NULL END)			As Retrieved,
		Comment 
		FROM CTE
		INNER JOIN (SELECT 
						SiteId, Detected, Retrieved
						, PolypSizeText = (CASE WHEN Size IS NULL OR Size=0 THEN NULL WHEN Size<10 THEN 'ItemLessThan10mm' WHEN Size BETWEEN 10 AND 19 THEN 'Item10to19mm' ELSE 'Item20OrLargermm' END)
					FROM dbo.tvfNED_PolypsDetailsView(@ProcedureType, @ProcedureId) )AS PS ON PS.SiteId = CTE.SiteId

	
	UNION ALL -- ## A Default Blank ROW.. ONLY when no Therap Record exist..
		SELECT TOP 1
			@ProcedureId AS ProcedureId, @ProcedureType	AS ProcedureType, NULL AS SiteId, NULL AS Saite
			, NULL AS [Site]
			, 'None' AS NedName
			, NULL AS EndoRole
			, NULL AS polypSize
			, NULL AS Tattooed, 0 AS Performed, 0 AS Successful, NULL AS Retrieved, NULL  AS Comment
		WHERE (SELECT IsNull(count(*), 0) FROM CTE)<1


);
GO

-----------------------------------------------------------------------------------------------------------
--Change "PreMedication" to "Drugs"
update ERS_XMLMap set NodeName = 'Drugs' where NodeName = 'Premedication'
GO

EXEC DropIfExist 'report_summary_select', 'S';
GO
CREATE PROCEDURE [dbo].[report_summary_select]
(
	@ProcedureId INT
)
AS
	SET NOCOUNT ON

	DECLARE @ProcedureType INT
	DECLARE @SQLString NVARCHAR(MAX)
	DECLARE @FieldName VARCHAR(50)
	DECLARE @NodeName VARCHAR(50)
	
	CREATE TABLE #Summary (NodeName VARCHAR(200), NodeSummary NVARCHAR(MAX))

	SELECT @ProcedureType = p.ProcedureType
	FROM ERS_Procedures p
	WHERE p.ProcedureId = @ProcedureId
	
	SELECT *
	INTO #xmlmap
	FROM ERS_XMLMap 
	WHERE [Group] = 'LS' OR (NodeName  IN ('Drugs', 'Specimens Taken', 'Instrument'))
	AND NodeName NOT IN ('InstForCareHeading')
	ORDER BY OrderID

	DECLARE report_cursor CURSOR FOR 
	SELECT FieldName FROM #xmlmap

	OPEN report_cursor 
    FETCH NEXT FROM report_cursor INTO @FieldName

    WHILE @@FETCH_STATUS = 0
    BEGIN
		SELECT @NodeName = NodeName FROM #xmlmap WHERE FieldName = @FieldName
		
		IF @FieldName = 'Endoscribe comments' SET @FieldName = 'EndoscribeComments'
		SET @SQLString = 'INSERT INTO #Summary ' + 
							' SELECT ''' + @NodeName + ''', [' + @FieldName + '] ' +
							' FROM ERS_Procedures' + 
							' WHERE ProcedureId = @ProcedureId'
		
		--print @sqlstring
		IF EXISTS(SELECT * FROM sys.columns WHERE Name =  @FieldName AND Object_ID = Object_ID(N'ERS_Procedures'))
		BEGIN
			EXEC sp_executesql @SQLString,
			N'@ProcedureId INT',
			@ProcedureId
		END
		
		-- Special case for PEG care field
		IF @NodeName = 'InstForCare'
		BEGIN
			SET @SQLString = 'UPDATE #Summary ' + 
								' SET NodeName = (SELECT [' + (SELECT FieldName FROM ERS_XMLMap WHERE NodeName = 'InstForCareHeading') + '] ' +
								' FROM ERS_Procedures' + 
								' WHERE ProcedureId = @ProcedureId)' +
								' WHERE NodeName = ''InstForCare'''
								
			IF EXISTS(SELECT * FROM sys.columns WHERE Name =  @FieldName AND Object_ID = Object_ID(N'ERS_Procedures'))
			BEGIN
				EXEC sp_executesql @SQLString,
				N'@ProcedureId INT',
				@ProcedureId
			END
		END
		-- Special case END

		FETCH NEXT FROM report_cursor INTO @FieldName
	END

    CLOSE report_cursor
    DEALLOCATE report_cursor

	SELECT * FROM #Summary

	DROP TABLE #Summary
	DROP TABLE #xmlmap
GO
-----------------------------------------------------------------------------------------------------------
-- Bug fix 248, 249, 251, 247
EXEC DropIfExist 'therapeutics_ogd_summary_update','S';
GO
CREATE PROCEDURE [dbo].[therapeutics_ogd_summary_update]
(
	@TherapeuticId AS INT,
	@SiteId INT
)
AS
	SET NOCOUNT ON
	DECLARE   @msg varchar(1000)
			, @Details varchar(1000)
			, @Summary varchar(4000)=''
			, @Area varchar(500)=''
			, @br VARCHAR(6) = '<br />';

	DECLARE 
		@None bit,
		@YAGLaser bit,
		@YAGLaserWatts int,
		@YAGLaserPulses int,
		@YAGLaserSecs decimal(8,2),
		@YAGLaserKJ decimal(8,2),
		@ArgonBeamDiathermy bit,
		@ArgonBeamDiathermyWatts int,
		@ArgonBeamDiathermyPulses int,
		@ArgonBeamDiathermySecs decimal(8,2),
		@ArgonBeamDiathermyKJ decimal(8,2),
		@BalloonDilation bit,
		@BandLigation bit,
		@BotoxInjection bit,
		@EndoloopPlacement bit,
		@HeatProbe bit,
		@BicapElectro bit,
		@Diathermy bit,
		@ForeignBody bit,
		@HotBiopsy bit,
		@Injection bit,
		@InjectionType int,
		@InjectionVolume int,
		@InjectionNumber int,
		@OesophagealDilatation bit,
		@DilatedTo int,
		@DilatationUnits tinyint,
		@DilatorType tinyint,
		@DilatorScopePass bit,
		@OesoDilNilByMouth bit,
		@OesoDilNilByMouthHrs int,
		@OesoDilXRay bit,
		@OesoDilXRayHrs int,
		@OesoDilSoftDiet bit,
		@OesoDilSoftDietDays int,
		@OesoDilWarmFluids bit,
		@OesoDilWarmFluidsHrs int,
		@OesoDilMedicalReview bit,
		@OesoYAGNilByMouth bit,
		@OesoYAGNilByMouthHrs int,
		@OesoYAGWarmFluids bit,
		@OesoYAGWarmFluidsHrs int,
		@OesoYAGSoftDiet bit,
		@OesoYAGSoftDietDays int,
		@OesoYAGMedicalReview bit,
		@Polypectomy bit,
		@PolypectomyRemoval tinyint,
		@PolypectomyRemovalType tinyint,
		@BandingPiles bit,
		@BandingNum int,
		@GastrostomyInsertion bit,
		@GastrostomyInsertionSize int,
		@GastrostomyInsertionUnits tinyint,
		@GastrostomyInsertionType tinyint,
		@GastrostomyInsertionBatchNo varchar(100),
		@CorrectPEGPlacement tinyint,
		@PEGPlacementFailureReason varchar(500),
		@NilByMouth bit,
		@NilByMouthHrs int,
		@NilByProc bit,
		@NilByProcHrs int,
		@FlangePosition int,
		@AttachmentToWard bit,
		@GastrostomyRemoval bit,
		@PyloricDilatation bit,
		@VaricealSclerotherapy bit,
		@VaricealSclerotherapyInjectionType smallint,
		@VaricealSclerotherapyInjectionVol int,
		@VaricealSclerotherapyInjectionNum int,
		@VaricealBanding bit,
		@VaricealBandingNum int,
		@VaricealClip bit,
		@StentInsertion bit,
		@StentInsertionQty int,
		@StentInsertionType smallint,
		@StentInsertionLength int,
		@StentInsertionDiameter int,
		@StentInsertionDiameterUnits tinyint,
		@StentInsertionBatchNo varchar(100),
		@CorrectStentPlacement tinyint,
		@StentPlacementFailureReason varchar(500),
		@StentRemoval bit,
		@StentRemovalTechnique int,
		@EMR bit,
		@EMRType tinyint,
		@EMRFluid int,
		@EMRFluidVolume int,
		@RFA bit,
		@RFAType tinyint,
		@RFATreatmentFrom int,
		@RFATreatmentTo int,
		@RFAEnergyDel int,
		@RFANumSegTreated int,
		@RFANumTimesSegTreated int,
		@pHProbeInsert bit,
		@pHProbeInsertAt int,
		@pHProbeInsertChk bit,
		@pHProbeInsertChkTopTo int,
		@Haemospray bit,
		@Sigmoidopexy bit,
		@SigmoidopexyQty smallint,
		@SigmoidopexyMake smallint,
		@SigmoidopexyFluidsDays smallint,
		@SigmoidopexyAntibioticsDays smallint,
		@Marking bit,
		@MarkingType int,
		@Clip bit,
		@ClipNum int,
		@Other varchar(1000),
		@EUSProcType smallint,
		@EndoClot bit;

	SELECT * INTO #tmp_UpperGITherapeutics 
	FROM dbo.[ERS_UpperGITherapeutics] 
	WHERE (Id = @TherapeuticId OR SiteID = @SiteId)

--## 1) If 'CarriedOutRole=2 (EE)' record is found for a SiteId in [ERS_UpperGITherapeutics] means it has both EE/ER Entries...
	--IF EXISTS(SELECT 'ER' FROM dbo.[ERS_UpperGITherapeutics] WHERE SiteId=@SiteId AND CarriedOutRole=2)
	--	BEGIN
			--PRINT '[ERS_UpperGITherapeutics] has both EE/ER Entries...';
			;WITH eeRecord AS(
				SELECT * FROM #tmp_UpperGITherapeutics WHERE CarriedOutRole = (SELECT MAX(CarriedOutRole) FROM #tmp_UpperGITherapeutics) --## 2 is EE
				--WHERE SiteId=@SiteId AND CarriedOutRole=2
			)
			SELECT
				@None							= (CASE WHEN IsNull(ER.[None], 0) = 0 THEN EE.[None] ELSE ER.[None] END),
				@YAGLaser						= (CASE WHEN IsNull(ER.[YAGLaser], 0) = 0 THEN EE.[YAGLaser] ELSE ER.[YAGLaser] END),
				@YAGLaserWatts					= (CASE WHEN IsNull(ER.[YAGLaserWatts], 0) = 0 THEN EE.[YAGLaserWatts] ELSE ER.[YAGLaserWatts] END),
				@YAGLaserPulses					= (CASE WHEN IsNull(ER.[YAGLaserPulses], 0) = 0 THEN EE.[YAGLaserPulses] ELSE ER.[YAGLaserPulses] END),
				@YAGLaserSecs					= (CASE WHEN IsNull(ER.[YAGLaserSecs], 0) = 0 THEN EE.[YAGLaserSecs] ELSE ER.[YAGLaserSecs] END),
				@YAGLaserKJ						= (CASE WHEN IsNull(ER.[YAGLaserKJ], 0) = 0 THEN EE.[YAGLaserKJ] ELSE ER.[YAGLaserKJ] END),
				@ArgonBeamDiathermy				= (CASE WHEN IsNull(ER.[ArgonBeamDiathermy], 0) = 0 THEN EE.[ArgonBeamDiathermy] ELSE ER.[ArgonBeamDiathermy] END),
				@ArgonBeamDiathermyWatts		= (CASE WHEN IsNull(ER.[ArgonBeamDiathermyWatts], 0) = 0 THEN EE.[ArgonBeamDiathermyWatts] ELSE ER.[ArgonBeamDiathermyWatts] END),
				@ArgonBeamDiathermyPulses		= (CASE WHEN IsNull(ER.[ArgonBeamDiathermyPulses], 0) = 0 THEN EE.[ArgonBeamDiathermyPulses] ELSE ER.[ArgonBeamDiathermyPulses] END),
				@ArgonBeamDiathermySecs			= (CASE WHEN IsNull(ER.[ArgonBeamDiathermySecs], 0) = 0 THEN EE.[ArgonBeamDiathermySecs] ELSE ER.[ArgonBeamDiathermySecs] END),
				@ArgonBeamDiathermyKJ			= (CASE WHEN IsNull(ER.[ArgonBeamDiathermyKJ], 0) = 0 THEN EE.[ArgonBeamDiathermyKJ] ELSE ER.[ArgonBeamDiathermyKJ] END),
				@BalloonDilation				= (CASE WHEN IsNull(ER.[BalloonDilation], 0) = 0 THEN EE.[BalloonDilation] ELSE ER.[BalloonDilation] END),
				@BandLigation					= (CASE WHEN IsNull(ER.[BandLigation], 0) = 0 THEN EE.[BandLigation] ELSE ER.[BandLigation] END),
				@BotoxInjection					= (CASE WHEN IsNull(ER.[BotoxInjection], 0) = 0 THEN EE.[BotoxInjection] ELSE ER.[BotoxInjection] END),
				@EndoloopPlacement				= (CASE WHEN IsNull(ER.[EndoloopPlacement], 0) = 0 THEN EE.[EndoloopPlacement] ELSE ER.[EndoloopPlacement] END),
				@HeatProbe						= (CASE WHEN IsNull(ER.[HeatProbe], 0) = 0 THEN EE.[HeatProbe] ELSE ER.[HeatProbe] END),
				@BicapElectro					= (CASE WHEN IsNull(ER.[BicapElectro], 0) = 0 THEN EE.[BicapElectro] ELSE ER.[BicapElectro] END),
				@Diathermy						= (CASE WHEN IsNull(ER.[Diathermy], 0) = 0 THEN EE.[Diathermy] ELSE ER.[Diathermy] END),
				@ForeignBody					= (CASE WHEN IsNull(ER.[ForeignBody], 0) = 0 THEN EE.[ForeignBody] ELSE ER.[ForeignBody] END),
				@HotBiopsy						= (CASE WHEN IsNull(ER.[HotBiopsy], 0) = 0 THEN EE.[HotBiopsy] ELSE ER.[HotBiopsy] END),
				@Injection						= (CASE WHEN IsNull(ER.[Injection], 0) = 0 THEN EE.[Injection] ELSE ER.[Injection] END),
				@InjectionType					= (CASE WHEN IsNull(ER.[InjectionType], 0) = 0 THEN EE.[InjectionType] ELSE ER.[InjectionType] END),
				@InjectionVolume				= (CASE WHEN IsNull(ER.[InjectionVolume], 0) = 0 THEN EE.[InjectionVolume] ELSE ER.[InjectionVolume] END),
				@InjectionNumber				= (CASE WHEN IsNull(ER.[InjectionNumber], 0) = 0 THEN EE.[InjectionNumber] ELSE ER.[InjectionNumber] END),
				@OesophagealDilatation			= (CASE WHEN IsNull(ER.[OesophagealDilatation], 0) = 0 THEN EE.[OesophagealDilatation] ELSE ER.[OesophagealDilatation] END),
				@DilatedTo						= (CASE WHEN IsNull(ER.[DilatedTo], 0) = 0 THEN EE.[DilatedTo] ELSE ER.[DilatedTo] END),
				@DilatationUnits				= (CASE WHEN IsNull(ER.[DilatationUnits], 0) = 0 THEN EE.[DilatationUnits] ELSE ER.[DilatationUnits] END),
				@DilatorType					= (CASE WHEN IsNull(ER.[DilatorType], 0) = 0 THEN EE.[DilatorType] ELSE ER.[DilatorType] END),
				@DilatorScopePass				= (CASE WHEN IsNull(ER.[DilatorScopePass], 0) = 0 THEN EE.[DilatorScopePass] ELSE ER.[DilatorScopePass] END),
				@OesoDilNilByMouth				= (CASE WHEN IsNull(ER.[OesoDilNilByMouth], 0) = 0 THEN EE.[OesoDilNilByMouth] ELSE ER.[OesoDilNilByMouth] END),
				@OesoDilNilByMouthHrs			= (CASE WHEN IsNull(ER.[OesoDilNilByMouthHrs], 0) = 0 THEN EE.[OesoDilNilByMouthHrs] ELSE ER.[OesoDilNilByMouthHrs] END),
				@OesoDilXRay					= (CASE WHEN IsNull(ER.[OesoDilXRay], 0) = 0 THEN EE.[OesoDilXRay] ELSE ER.[OesoDilXRay] END),
				@OesoDilXRayHrs					= (CASE WHEN IsNull(ER.[OesoDilXRayHrs], 0) = 0 THEN EE.[OesoDilXRayHrs] ELSE ER.[OesoDilXRayHrs] END),
				@OesoDilSoftDiet				= (CASE WHEN IsNull(ER.[OesoDilSoftDiet], 0) = 0 THEN EE.[OesoDilSoftDiet] ELSE ER.[OesoDilSoftDiet] END),
				@OesoDilSoftDietDays			= (CASE WHEN IsNull(ER.[OesoDilSoftDietDays], 0) = 0 THEN EE.[OesoDilSoftDietDays] ELSE ER.[OesoDilSoftDietDays] END),
				@OesoDilWarmFluids				= (CASE WHEN IsNull(ER.[OesoDilWarmFluids], 0) = 0 THEN EE.[OesoDilWarmFluids] ELSE ER.[OesoDilWarmFluids] END),
				@OesoDilWarmFluidsHrs			= (CASE WHEN IsNull(ER.[OesoDilWarmFluidsHrs], 0) = 0 THEN EE.[OesoDilWarmFluidsHrs] ELSE ER.[OesoDilWarmFluidsHrs] END),
				@OesoDilMedicalReview			= (CASE WHEN IsNull(ER.[OesoDilMedicalReview], 0) = 0 THEN EE.[OesoDilMedicalReview] ELSE ER.[OesoDilMedicalReview] END),
				@OesoYAGNilByMouth				= (CASE WHEN IsNull(ER.[OesoYAGNilByMouth], 0) = 0 THEN EE.[OesoYAGNilByMouth] ELSE ER.[OesoYAGNilByMouth] END),
				@OesoYAGNilByMouthHrs			= (CASE WHEN IsNull(ER.[OesoYAGNilByMouthHrs], 0) = 0 THEN EE.[OesoYAGNilByMouthHrs] ELSE ER.[OesoYAGNilByMouthHrs] END),
				@OesoYAGWarmFluids				= (CASE WHEN IsNull(ER.[OesoYAGWarmFluids], 0) = 0 THEN EE.[OesoYAGWarmFluids] ELSE ER.[OesoYAGWarmFluids] END),
				@OesoYAGWarmFluidsHrs			= (CASE WHEN IsNull(ER.[OesoYAGWarmFluidsHrs], 0) = 0 THEN EE.[OesoYAGWarmFluidsHrs] ELSE ER.[OesoYAGWarmFluidsHrs] END),
				@OesoYAGSoftDiet				= (CASE WHEN IsNull(ER.[OesoYAGSoftDiet], 0) = 0 THEN EE.[OesoYAGSoftDiet] ELSE ER.[OesoYAGSoftDiet] END),
				@OesoYAGSoftDietDays			= (CASE WHEN IsNull(ER.[OesoYAGSoftDietDays], 0) = 0 THEN EE.[OesoYAGSoftDietDays] ELSE ER.[OesoYAGSoftDietDays] END),
				@OesoYAGMedicalReview			= (CASE WHEN IsNull(ER.[OesoYAGMedicalReview], 0) = 0 THEN EE.[OesoYAGMedicalReview] ELSE ER.[OesoYAGMedicalReview] END),
				@Polypectomy					= (CASE WHEN IsNull(ER.[Polypectomy], 0) = 0 THEN EE.[Polypectomy] ELSE ER.[Polypectomy] END),
				@PolypectomyRemoval				= (CASE WHEN IsNull(ER.[PolypectomyRemoval], 0) = 0 THEN EE.[PolypectomyRemoval] ELSE ER.[PolypectomyRemoval] END),
				@PolypectomyRemovalType			= (CASE WHEN IsNull(ER.[PolypectomyRemovalType], 0) = 0 THEN EE.[PolypectomyRemovalType] ELSE ER.[PolypectomyRemovalType] END),
				@BandingPiles					= (CASE WHEN IsNull(ER.BandingPiles, 0) = 0 THEN EE.BandingPiles ELSE ER.BandingPiles END),
				@BandingNum						= (CASE WHEN IsNull(ER.BandingNum, 0) = 0 THEN EE.BandingNum ELSE ER.BandingNum END),
				@GastrostomyInsertion			= (CASE WHEN IsNull(ER.[GastrostomyInsertion], 0) = 0 THEN EE.[GastrostomyInsertion] ELSE ER.[GastrostomyInsertion] END),
				@GastrostomyInsertionSize		= (CASE WHEN IsNull(ER.[GastrostomyInsertionSize], 0) = 0 THEN EE.[GastrostomyInsertionSize] ELSE ER.[GastrostomyInsertionSize] END),
				@GastrostomyInsertionUnits		= (CASE WHEN IsNull(ER.[GastrostomyInsertionUnits], 0) = 0 THEN EE.[GastrostomyInsertionUnits] ELSE ER.[GastrostomyInsertionUnits] END),
				@GastrostomyInsertionType		= (CASE WHEN IsNull(ER.[GastrostomyInsertionType], 0) = 0 THEN EE.[GastrostomyInsertionType] ELSE ER.[GastrostomyInsertionType] END),
				@GastrostomyInsertionBatchNo	= (SELECT isnull((CASE WHEN IsNull(ER.[GastrostomyInsertionBatchNo], '') = '' THEN EE.[GastrostomyInsertionBatchNo] ELSE ER.[GastrostomyInsertionBatchNo] END), '') as [text()] FOR XML PATH('')),
				@CorrectPEGPlacement			= (CASE WHEN IsNull(ER.[CorrectPEGPlacement], 0) = 0 THEN EE.[CorrectPEGPlacement] ELSE ER.[CorrectPEGPlacement] END),
				@PEGPlacementFailureReason		= (SELECT isnull((CASE WHEN IsNull(ER.[PEGPlacementFailureReason], '') = '' THEN EE.[PEGPlacementFailureReason] ELSE ER.[PEGPlacementFailureReason] END), '') as [text()] FOR XML PATH('')),
				@NilByMouth						= (CASE WHEN IsNull(ER.[NilByMouth], 0) = 0 THEN EE.[NilByMouth] ELSE ER.[NilByMouth] END),
				@NilByMouthHrs					= (CASE WHEN IsNull(ER.[NilByMouthHrs], 0) = 0 THEN EE.[NilByMouthHrs] ELSE ER.[NilByMouthHrs] END),
				@NilByProc						= (CASE WHEN IsNull(ER.[NilByProc], 0) = 0 THEN EE.[NilByProc] ELSE ER.[NilByProc] END),
				@NilByProcHrs					= (CASE WHEN IsNull(ER.[NilByProcHrs], 0) = 0 THEN EE.[NilByProcHrs] ELSE ER.[NilByProcHrs] END),
				@FlangePosition					= (CASE WHEN IsNull(ER.[FlangePosition], 0) = 0 THEN EE.[FlangePosition] ELSE ER.[FlangePosition] END),
				@AttachmentToWard				= (CASE WHEN IsNull(ER.[AttachmentToWard], 0) = 0 THEN EE.[AttachmentToWard] ELSE ER.[AttachmentToWard] END),
				@GastrostomyRemoval				= (CASE WHEN IsNull(ER.[GastrostomyRemoval], 0) = 0 THEN EE.[GastrostomyRemoval] ELSE ER.[GastrostomyRemoval] END),
				@PyloricDilatation				= (CASE WHEN IsNull(ER.[PyloricDilatation], 0) = 0 THEN EE.[PyloricDilatation] ELSE ER.[PyloricDilatation] END),
				@VaricealSclerotherapy			= (CASE WHEN IsNull(ER.[VaricealSclerotherapy], 0) = 0 THEN EE.[VaricealSclerotherapy] ELSE ER.[VaricealSclerotherapy] END),
				@VaricealSclerotherapyInjectionType = (CASE WHEN IsNull(ER.[VaricealSclerotherapyInjectionType], 0) = 0 THEN EE.[VaricealSclerotherapyInjectionType] ELSE ER.[VaricealSclerotherapyInjectionType] END),
				@VaricealSclerotherapyInjectionVol  = (CASE WHEN IsNull(ER.[VaricealSclerotherapyInjectionVol], 0) = 0 THEN EE.[VaricealSclerotherapyInjectionVol] ELSE ER.[VaricealSclerotherapyInjectionVol] END),
				@VaricealSclerotherapyInjectionNum  = (CASE WHEN IsNull(ER.[VaricealSclerotherapyInjectionNum], 0) = 0 THEN EE.[VaricealSclerotherapyInjectionNum] ELSE ER.[VaricealSclerotherapyInjectionNum] END),
				@VaricealBanding				= (CASE WHEN IsNull(ER.[VaricealBanding], 0) = 0 THEN EE.[VaricealBanding] ELSE ER.[VaricealBanding] END),
				@VaricealBandingNum				= (CASE WHEN IsNull(ER.[VaricealBandingNum], 0) = 0 THEN EE.[VaricealBandingNum] ELSE ER.[VaricealBandingNum] END),
				@VaricealClip					= (CASE WHEN IsNull(ER.[VaricealClip], 0) = 0 THEN EE.[VaricealClip] ELSE ER.[VaricealClip] END),
				@StentInsertion					= (CASE WHEN IsNull(ER.[StentInsertion], 0) = 0 THEN EE.[StentInsertion] ELSE ER.[StentInsertion] END),
				@StentInsertionQty				= (CASE WHEN IsNull(ER.[StentInsertionQty], 0) = 0 THEN EE.[StentInsertionQty] ELSE ER.[StentInsertionQty] END),
				@StentInsertionType				= (CASE WHEN IsNull(ER.[StentInsertionType], 0) = 0 THEN EE.[StentInsertionType] ELSE ER.[StentInsertionType] END),
				@StentInsertionLength			= (CASE WHEN IsNull(ER.[StentInsertionLength], 0) = 0 THEN EE.[StentInsertionLength] ELSE ER.[StentInsertionLength] END),
				@StentInsertionDiameter			= (CASE WHEN IsNull(ER.[StentInsertionDiameter], 0) = 0 THEN EE.[StentInsertionDiameter] ELSE ER.[StentInsertionDiameter] END),
				@StentInsertionDiameterUnits	= (CASE WHEN IsNull(ER.[StentInsertionDiameterUnits], 0) = 0 THEN EE.[StentInsertionDiameterUnits] ELSE ER.[StentInsertionDiameterUnits] END),
				@StentInsertionBatchNo			= (CASE WHEN IsNull(ER.[StentInsertionBatchNo], '') = '' THEN EE.[StentInsertionBatchNo] ELSE ER.[StentInsertionBatchNo] END),
				@CorrectStentPlacement			= (CASE WHEN IsNull(ER.[CorrectStentPlacement], 0) = 0 THEN EE.[CorrectStentPlacement] ELSE ER.[CorrectStentPlacement] END),
				@StentPlacementFailureReason	= (SELECT isnull((CASE WHEN IsNull(ER.[StentPlacementFailureReason], '') = '' THEN EE.[StentPlacementFailureReason] ELSE ER.[StentPlacementFailureReason] END), '') as [text()] FOR XML PATH('')),
				@StentRemoval					= (CASE WHEN IsNull(ER.[StentRemoval], 0) = 0 THEN EE.[StentRemoval] ELSE ER.[StentRemoval] END),
				@StentRemovalTechnique			= (CASE WHEN IsNull(ER.[StentRemovalTechnique], 0) = 0 THEN EE.[StentRemovalTechnique] ELSE ER.[StentRemovalTechnique] END),
				@EMR							= (CASE WHEN IsNull(ER.[EMR], 0) = 0 THEN EE.[EMR] ELSE ER.[EMR] END),
				@EMRType						= (CASE WHEN IsNull(ER.[EMRType], 0) = 0 THEN EE.[EMRType] ELSE ER.[EMRType] END),
				@EMRFluid						= (CASE WHEN IsNull(ER.[EMRFluid], 0) = 0 THEN EE.[EMRFluid] ELSE ER.[EMRFluid] END),
				@EMRFluidVolume					= (CASE WHEN IsNull(ER.[EMRFluidVolume], 0) = 0 THEN EE.[EMRFluidVolume] ELSE ER.[EMRFluidVolume] END),
				@RFA							= (CASE WHEN IsNull(ER.[RFA], 0) = 0 THEN EE.[RFA] ELSE ER.[RFA] END),
				@RFAType						= (CASE WHEN IsNull(ER.[RFAType], 0) = 0 THEN EE.[RFAType] ELSE ER.[RFAType] END),
				@RFATreatmentFrom				= (CASE WHEN IsNull(ER.[RFATreatmentFrom], 0) = 0 THEN EE.[RFATreatmentFrom] ELSE ER.[RFATreatmentFrom] END),				
				@RFATreatmentTo					= (CASE WHEN IsNull(ER.[RFATreatmentTo], 0) = 0 THEN EE.[RFATreatmentTo] ELSE ER.[RFATreatmentTo] END),				
				@RFAEnergyDel					= (CASE WHEN IsNull(ER.[RFAEnergyDel], 0) = 0 THEN EE.[RFAEnergyDel] ELSE ER.[RFAEnergyDel] END),
				@RFANumSegTreated				= (CASE WHEN IsNull(ER.[RFANumSegTreated], 0) = 0 THEN EE.[RFANumSegTreated] ELSE ER.[RFANumSegTreated] END),
				@RFANumTimesSegTreated			= (CASE WHEN IsNull(ER.[RFANumTimesSegTreated], 0) = 0 THEN EE.[RFANumTimesSegTreated] ELSE ER.[RFANumTimesSegTreated] END),
				@pHProbeInsert					= (CASE WHEN IsNull(ER.[pHProbeInsert], 0) = 0 THEN EE.[pHProbeInsert] ELSE ER.[pHProbeInsert] END),
				@pHProbeInsertAt				= (CASE WHEN IsNull(ER.[pHProbeInsertAt], 0) = 0 THEN EE.[pHProbeInsertAt] ELSE ER.[pHProbeInsertAt] END),
				@pHProbeInsertChk				= (CASE WHEN IsNull(ER.[pHProbeInsertChk], 0) = 0 THEN EE.[pHProbeInsertChk] ELSE ER.[pHProbeInsertChk] END),
				@pHProbeInsertChkTopTo			= (CASE WHEN IsNull(ER.[pHProbeInsertChkTopTo], 0) = 0 THEN EE.[pHProbeInsertChkTopTo] ELSE ER.[pHProbeInsertChkTopTo] END),
				@Haemospray						= (CASE WHEN IsNull(ER.[Haemospray], 0) = 0 THEN EE.[Haemospray] ELSE ER.[Haemospray] END),
				@Sigmoidopexy					= (CASE WHEN IsNull(ER.[Sigmoidopexy], 0) = 0 THEN EE.[Sigmoidopexy] ELSE ER.[Sigmoidopexy] END),
				@SigmoidopexyQty				= (CASE WHEN IsNull(ER.[SigmoidopexyQty], 0) = 0 THEN EE.[SigmoidopexyQty] ELSE ER.[SigmoidopexyQty] END),
				@SigmoidopexyMake				= (CASE WHEN IsNull(ER.[SigmoidopexyMake], 0) = 0 THEN EE.[SigmoidopexyMake] ELSE ER.[SigmoidopexyMake] END),
				@SigmoidopexyFluidsDays			= (CASE WHEN IsNull(ER.[SigmoidopexyFluidsDays], 0) = 0 THEN EE.[SigmoidopexyFluidsDays] ELSE ER.[SigmoidopexyFluidsDays] END),
				@SigmoidopexyAntibioticsDays	= (CASE WHEN IsNull(ER.[SigmoidopexyAntibioticsDays], 0) = 0 THEN EE.[SigmoidopexyAntibioticsDays] ELSE ER.[SigmoidopexyAntibioticsDays] END),
				@Marking						= (CASE WHEN IsNull(ER.[Marking], 0) = 0 THEN EE.[Marking] ELSE ER.[Marking] END),
				@MarkingType					= (CASE WHEN IsNull(ER.[MarkingType], 0) = 0 THEN EE.[MarkingType] ELSE ER.[MarkingType] END),
				@Clip							= (CASE WHEN IsNull(ER.[Clip], 0) = 0 THEN EE.[Clip] ELSE ER.[Clip] END),
				@ClipNum						= (CASE WHEN IsNull(ER.[ClipNum], 0) = 0 THEN EE.[ClipNum] ELSE ER.[ClipNum] END),
				@Other							= (SELECT isnull((CASE WHEN IsNull(ER.[Other], '') = '' THEN EE.[Other] ELSE ER.[Other] END), '') as [text()] FOR XML PATH('')),
				@EUSProcType					= (CASE WHEN IsNull(ER.[EUSProcType], 0) = 0 THEN EE.[EUSProcType] ELSE ER.[EUSProcType] END),
				@EndoClot						= (CASE WHEN IsNull(ER.[EndoClot], 0) = 0 THEN EE.[EndoClot] ELSE ER.[EndoClot] END)
			FROM eeRecord AS EE
	  INNER JOIN #tmp_UpperGITherapeutics AS ER ON EE.SiteId = ER.SiteId

	SELECT @Area = m.Area FROM ERS_AbnormalitiesMatrixUpperGI m LEFT JOIN ERS_Regions r ON m.Region = r.Region LEFT JOIN ERS_Sites s ON r.RegionId  = s.RegionID  WHERE s.siteId = @SiteId;
	
	IF @None = 1
		SET @summary = @summary + 'No therapeutic procedures'
	ELSE
	BEGIN
		IF @YAGLaser = 1
			BEGIN
			SET @msg =' YAG Laser'
			SET @Details = ''
			IF @YAGLaserWatts > 0 SET @Details = @Details + ' ' + CAST(@YAGLaserWatts as varchar(50)) + 'W'
			IF @YAGLaserSecs > 0 SET @Details = @Details + ' for ' + cast(CAST(@YAGLaserSecs AS FLOAT) as varchar(50)) + CASE WHEN @YAGLaserSecs <= 1 THEN ' second' else ' seconds' END
			IF @YAGLaserPulses > 0 SET @Details = @Details + ' in ' + cast(@YAGLaserPulses as varchar(50)) + CASE WHEN @YAGLaserPulses <= 1 THEN ' pulse' else ' pulses' END
			IF @YAGLaserKJ > 0 SET @Details = @Details + ' ('+ cast(CAST(@YAGLaserKJ AS FLOAT) as varchar(50)) + 'kJ)'
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + @br
			END
		
		IF @ArgonBeamDiathermy= 1
			BEGIN
			SET @msg ='  Argon beam diathermy'
			SET @Details = ''
			IF @ArgonBeamDiathermyWatts > 0 SET @Details = @Details + ' ' + cast(@ArgonBeamDiathermyWatts as varchar(50)) + 'W'
			IF @ArgonBeamDiathermySecs > 0 SET @Details = @Details + ' for ' + cast(CAST(@ArgonBeamDiathermySecs AS FLOAT) as varchar(50)) + CASE WHEN @ArgonBeamDiathermySecs <= 1 THEN ' second' else ' seconds' END
			IF @ArgonBeamDiathermyPulses > 0 SET @Details = @Details + ' in ' + cast(@ArgonBeamDiathermyPulses as varchar(50)) + CASE WHEN @ArgonBeamDiathermyPulses <= 1 THEN ' pulse' else ' pulses' END
			IF @ArgonBeamDiathermyKJ > 0 SET @Details = @Details + ' ('+ cast(CAST(@ArgonBeamDiathermyKJ AS FLOAT) as varchar(50)) + 'kJ)'
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
			END

			
		IF @Injection= 1
			BEGIN
			SET @msg =' Injection therapy'
			SET @Details = ''
			IF @InjectionVolume > 0 SET @Details = @Details + '  ' + cast(@InjectionVolume as varchar(50)) + 'ml'
			IF @InjectionVolume > 0  AND @InjectionType > 0 SET @Details = @Details + ' of'
			IF @InjectionType > 0 SET @Details = @Details + ' ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Agent Upper GI' AND [ListItemNo] = @InjectionType)
			IF @InjectionVolume> 0  AND @InjectionNumber > 0 SET @Details = @Details + ' via'
			IF @InjectionNumber >0 SET @Details = @Details + ' ' + CASE WHEN @InjectionNumber > 1 THEN cast(@InjectionNumber as varchar(50)) + ' injections' ELSE cast(@InjectionNumber as varchar(50)) + ' injection' END
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END
		
	
	
		IF @Polypectomy= 1  
			BEGIN
			SET @msg =' Polypectomy'
			SET @Details = ''
			DECLARE @Se bit, @SeExcised int, @Pe bit, @PeExcised int, @Su bit, @SuExcised int, @countExcised int = 0
			SELECT @Se = [Sessile],@SeExcised =[SessileNumExcised], @Pe = [Pedunculated], @PeExcised= [PedunculatedNumExcised], @Su =[Submucosal], @SuExcised = [SubmucosalNumExcised] FROM [ERS_UpperGIAbnoPolyps] WHERE SiteId =@SiteId
			IF @Se =1 AND @SeExcised <> null SET @countExcised= @countExcised + @SeExcised 
			IF  @Pe = 1 AND @PeExcised <> null SET @countExcised= @countExcised + @peExcised
			IF  @Su = 1 AND @suExcised <> null SET @countExcised= @countExcised + @suExcised

			IF @countExcised > 0 SET @Details = @Details + cast(@countExcised as varchar(50)) +' excised '

			IF @PolypectomyRemoval <> 0 OR @PolypectomyRemovalType <> 0
			BEGIN
			SET @Details = @Details + '('
            IF @PolypectomyRemoval = 1 SET @Details = @Details + 'removed entirely ' ELSE IF @PolypectomyRemoval = 2 SET @Details = @Details + 'removed piecemeal '
			IF @PolypectomyRemovalType = 1 SET @Details = @Details + ' using partial snare'
			ELSE IF  @PolypectomyRemovalType = 2 SET @Details = @Details + 'using cold snare'
			ELSE IF  @PolypectomyRemovalType = 3 SET @Details = @Details + 'using hot snare cauterisation'
			ELSE IF  @PolypectomyRemovalType = 4 SET @Details = @Details + 'using hot biopsy'
			ELSE IF  @PolypectomyRemovalType = 5 SET @Details = @Details + 'using cold biopsy'
			ELSE IF  @PolypectomyRemovalType = 6 SET @Details = @Details + 'using hot snare EMR'
			ELSE IF  @PolypectomyRemovalType = 7 SET @Details = @Details + 'using cold snare by EMR'
			SET @Details = @Details + ')'
			END

			If @Details<>'' SET @msg = @msg + ': ' + @Details
				--Add full stop 
				SET @msg = RTrim(LTRIM(@msg))
				IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
				--------------
				SET @summary = @summary + @msg + @br
			
		END

		IF @BandingPiles= 1
		BEGIN 
			SET @msg = CASE WHEN @BandingNum > 1 THEN ': ' + CAST(@BandingNum as varchar(5)) + ' bands'
							WHEN @BandingNum = 1 THEN ': ' + CAST(@BandingNum as varchar(5)) + ' band'
							ELSE ''
						END
			--Add full stop 
			SET @msg = 'Banding of piles' + RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

	
		IF @Diathermy = 1
		BEGIN
			SET @msg = ' Diathermy'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @BicapElectro = 1
		BEGIN
			SET @msg = ' Bicap electrocautery'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @HeatProbe = 1
		BEGIN
			SET @msg = ' Heater probe coagulation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		--IF @BallDil = 1
		--	BEGIN
		--	SET @msg = ' Balloon dilatation'
		--	--Add full stop 
		--	SET @msg = RTrim(LTRIM(@msg))
		--	IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
		--	--------------
		--	SET @summary = @summary + @msg + @br
		--END
		
		IF @HotBiopsy = 1
		BEGIN
			SET @msg = ' Hot biopsy'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @BandLigation = 1
		BEGIN
			SET @msg = ' Band ligation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

			IF @BalloonDilation = 1
		BEGIN
			SET @msg = ' Balloon Dilation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @BotoxInjection = 1
		BEGIN
			SET @msg = ' Botox injection'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @EndoloopPlacement = 1
		BEGIN
			SET @msg = ' Endoloop placement'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @ForeignBody = 1
		BEGIN
			SET @msg = ' Foreign body removal'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @StentInsertion= 1
			BEGIN
			SET @msg =' Stent insertion'
			SET @Details = ''
			IF @StentInsertionQty > 0 SET @Details = @Details + '  ' + cast(@StentInsertionQty as varchar(50))
			IF @StentInsertionType > 0 
				BEGIN
				IF @Area = 'Oesophagus'	 SET @Details = @Details + ' ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Therapeutic Stent Insertion Types' AND [ListItemNo] = @StentInsertionType)
				ELSE SET @Details = @Details + ' ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Therapeutic Stomach Stent Insertion Types' AND [ListItemNo] = @StentInsertionType)
				END	
			IF @StentInsertionLength > 0 AND @StentInsertionDiameter > 0 
				BEGIN
				SET @Details = @Details + ' (' 
				IF @StentInsertionLength > 0 SET @Details = @Details + ' length ' + cast(@StentInsertionLength as varchar(50)) + 'cm'
				IF @StentInsertionDiameter > 0 SET @Details = @Details + ', ' 
				SET @Details = @Details + ' diameter ' + cast(@StentInsertionDiameter as varchar(50))
				IF @StentInsertionDiameterUnits >= 0 SET @Details = @Details+ ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilatation units' AND [ListItemNo] = @StentInsertionDiameterUnits)
				SET @Details = @Details + ')' 
				END
			IF @StentInsertionBatchNo <> ''  SET @Details = @Details + ' batch ' + LTRIM(RTRIM(@StentInsertionBatchNo))
			
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @StentRemoval= 1
			BEGIN
			SET @msg =' Stent removal'
			SET @Details = ''
			IF @StentRemovalTechnique > 0  SET @Details = @Details + 'using ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Therapeutic Stent Removal Technique' AND [ListItemNo] = @StentRemovalTechnique)
			IF @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @EMR= 1
			BEGIN
			IF @EMRType = 2
				SET @msg =' Endoscopic submucosal dissection'
			ELSE
				SET @msg =' Endoscopic mucosal resection'
			SET @Details = ''
			IF @EMRFluid > 0  SET @Details = @Details + 'using ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Therapeutic EMR Fluid' AND [ListItemNo] = @EMRFluid)
			IF @EMRFluidVolume >0 
				BEGIN
				IF @EMRFluid >0 SET  @Details = @Details + ', '
				SET  @Details = @Details + 'total volume ' + cast(@emrfluidvolume AS varchar(50)) + 'ml'
				END
			IF @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		
		IF @OesophagealDilatation= 1
			BEGIN
			SET @msg =' Oesophageal dilatation'
			SET @Details = ''
			IF @DilatedTo > 0  SET @Details = @Details + ' dilated to ' + cast(@dilatedto as varchar(50)) +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilatation units' AND [ListItemNo] = @DilatationUnits)
			IF @DilatorType > 0
				BEGIN
				DECLARE @DilatorStr varchar(500) = (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilator' AND [ListItemNo] = @DilatorType)
				IF @DilatorStr like 'with%' OR @DilatorStr like 'by%'  SET @Details = @Details + ' ' +  @DilatorStr
				ELSE SET @Details = @Details + ' with ' +  @DilatorStr
				END
			IF @DilatorScopePass = 1 SET  @Details = @Details + '(scope could pass)'
			
			IF @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @VaricealSclerotherapy= 1
			BEGIN
			SET @msg =' Oesophagus variceal sclerotherapy'
			SET @Details = ''
			IF @VaricealSclerotherapyInjectionVol > 0  SET @Details = @Details + ' ' + cast(@VaricealSclerotherapyInjectionVol as varchar(50)) + 'ml' 
			IF @VaricealSclerotherapyInjectionVol > 0 AND  @VaricealSclerotherapyInjectiontype > 0  SET @Details = @Details + ' of'
			IF @VaricealSclerotherapyInjectiontype > 0 SET @Details = @Details + ' ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Agent Upper GI' AND [ListItemNo] = @VaricealSclerotherapyInjectiontype)
			IF @VaricealSclerotherapyInjectionVol > 0 AND  @VaricealSclerotherapyInjectionNum > 0  SET @Details = @Details + ' via'
			IF @VaricealSclerotherapyInjectionNum > 0 SET @Details = @Details + ' ' + CASE WHEN @VaricealSclerotherapyInjectionNum >1 THEN CAST(@VaricealSclerotherapyInjectionNum as varchar(50))+' injections' ELSE  CAST(@VaricealSclerotherapyInjectionNum as varchar(50))+' injection' END
			IF @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @VaricealBanding= 1
			BEGIN
			IF @Area ='Oesophagus' SET @msg =' Oesophagus variceal banding' ELSE SET @msg =' Gastric variceal banding'
			SET @Details = ''
			IF @VaricealBandingNum > 0 SET @Details = @Details + ' ' + CASE WHEN @VaricealBandingNum >1 THEN CAST(@VaricealBandingNum as varchar(50))+' bands' ELSE  CAST(@VaricealBandingNum as varchar(50)) + ' band' END
			IF @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @RFA = 1
			BEGIN
			SET @msg =' Radio Frequency Ablation'
			SET @Details = ''
			IF @RFAType = 1	SET @Details = @Details + ' circumferential'
			ELSE IF @RFAType = 2 SET @Details = @Details + ' focal'
			IF ISNULL(@RFAEnergyDel,0) <> 0 SET @Details = @Details + ', ' + cast(@RFAEnergyDel as varchar(50)) + ' joules'
			IF ISNULL(@RFANumSegTreated,0) <> 0
				BEGIN
				SET @Details = @Details + ' delivered to ' + cast(@RFANumSegTreated as varchar(50))
				IF @RFAType =1 SET @Details = @Details + ' x 3cm'
				SET @Details = @Details + ' segment'
				IF @RFANumSegTreated > 1 SET @Details = @Details + 's'
				END
			IF ISNULL(@RFANumTimesSegTreated,0)<>0
				BEGIN
				SET @Details = @Details + ', treated '
				If @RFANumTimesSegTreated = 1 SET @Details = @Details + 'once'
				ELSE SET @Details = @Details + cast(@RFANumTimesSegTreated as varchar(50)) + ' times'
				END
			IF ISNULL(@RFATreatmentFrom,0) <>0 OR ISNULL(@RFATreatmentTo,0) <>0
				BEGIN
				IF ISNULL(@RFATreatmentFrom,0) <> 0  SET @Details = @Details + ', starting at ' + cast(@RFATreatmentFrom as varchar(50)) +' cm'
				IF ISNULL(@RFATreatmentTo,0) <> 0 
				BEGIN
				IF ISNULL(@RFATreatmentFrom,0) <> 0 SET @Details = @Details + ' and ending at ' + cast(@RFATreatmentTo as varchar(50)) +' cm'
				ELSE  SET @Details = @Details + ' ending at ' + cast(@RFATreatmentTo as varchar(50)) +' cm'
				END
				SET @Details = @Details + ' from the incisors'
				END				

			IF @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @GastrostomyInsertion =1
			BEGIN
			DECLARE @G bit, @J bit, @N bit
			SELECT @j = i.[JejunostomyInsertion], @G =i.[GastrostomyInsertion],@N = i.[NasoDuodenalTube] FROM [ERS_UpperGIIndications] i LEFT JOIN [ERS_Sites] s ON i.ProcedureId = s.ProcedureId WHERE s.SiteId = @SiteID
			IF @N = 1 SET @msg =' Nasojejunal tube (NJT)' ELSE IF @J= 1 SET @msg =' Jejunostomy insertion (PEJ)' ELSE SET @msg =' Gastrostomy insertion (PEG)'
			SET @Details = ''

			IF @GastrostomyInsertionType > 0
				BEGIN
				IF @GastrostomyInsertionSize>0
					BEGIN
					SET @Details = @Details + cast(@GastrostomyInsertionSize as varchar(50))
					IF @J=1 SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG units' AND [ListItemNo] = @GastrostomyInsertionUnits)
					ELSE IF @N =1 SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG units' AND [ListItemNo] = @GastrostomyInsertionUnits)
					ELSE SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG units' AND [ListItemNo] = @GastrostomyInsertionUnits)
					END
				END
				IF @GastrostomyInsertionType>0
						BEGIN
						IF @J=1 SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG type' AND [ListItemNo] = @GastrostomyInsertiontype)
						ELSE IF @N =1 SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG type' AND [ListItemNo] = @GastrostomyInsertiontype)
						ELSE SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG type' AND [ListItemNo] = @GastrostomyInsertiontype)
						END
				IF ISNULL(@GastrostomyInsertionBatchNo, '') <> ''  SET @Details = @Details + ' batch ' + @GastrostomyInsertionBatchNo
				
				IF @CorrectPEGPlacement = 2 SET @Details = @Details + ' incorrectly placed ' + isnull(@PEGPlacementFailureReason, '')
				    
				
				IF @Details<>'' SET @msg = @msg + ': ' + @Details
				--Add full stop 
				SET @msg = RTrim(LTRIM(@msg))
				IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
				--------------
				SET @summary = @summary + @msg + @br
				END

		IF @GastrostomyRemoval = 1
		BEGIN
			SET @msg =' Gastrostomy PEG Removal'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END
		IF @PyloricDilatation= 1
		BEGIN
			SET @msg =' Pyloric dilatation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @pHProbeInsert= 1
			BEGIN
			SET @msg =' pH probe insertion'
			SET @Details = ''
			IF @pHProbeInsertAt > 0 SET @Details = @Details + ' inserted at ' + CAST(@pHProbeInsertAt as varchar(50))+' cm'
			IF ISNULL(@pHProbeInsertChkTopTo,0) <> 0 
			BEGIN
				IF @Details <> '' SET @Details = @Details + ', '
				SET @Details = @Details + 'endoscopic check performed, top of probe at ' + CAST(@pHProbeInsertChkTopTo as varchar(50))+' cm'
			END
			--ELSE  SET @Details = @Details + ', insertion checked endoscopically'

			IF @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @Haemospray= 1
		BEGIN
			SET @msg =' Haemospray'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @Sigmoidopexy= 1
		BEGIN
			
			SET @msg =' Sigmoidopexy'
			SET @Details = ''
			IF @SigmoidopexyQty > 0 SET @Details = @Details + CONVERT(VARCHAR, @SigmoidopexyQty)
			IF @SigmoidopexyMake > 0 SET @Details = @Details + ' ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Sigmoidopexy make' AND [ListItemNo] = @SigmoidopexyMake)

			IF @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @Marking= 1
		BEGIN
			SET @msg =' Abnormality marked'
			SET @Details = ''
			IF @MarkingType > 0 SET @Details = @Details + ' by ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Abno marking' AND [ListItemNo] = @MarkingType)

			IF @Details<>'' SET @msg = @msg + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @Clip= 1
		BEGIN 
			SET @msg = CASE WHEN @ClipNum > 1 THEN  CAST(@ClipNum as varchar(5)) + ' clips'
							WHEN @ClipNum = 1 THEN  CAST(@ClipNum as varchar(5)) + ' clip'
							ELSE 'Clip'
						END
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @EndoClot = 1
		BEGIN 
			SET @msg = 'EndoClot used'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF LTRIM(RTRIM(@other)) <> ''
			BEGIN
			SET @msg =' ' + LTRIM(RTRIM(@other))
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary =  @summary + @msg  +@br
		END

		--Remove last <br />
		IF RIGHT(RTRIM(@summary),6) = '<br />'
		BEGIN
			SET @summary = RTRIM(@summary)
			SET @summary = LEFT(@summary, LEN(@summary) - 6)
END

END

	-- Finally, update the summary in Therapeutics  table
	UPDATE dbo.ERS_UpperGITherapeutics 
	SET Summary=@summary 
	WHERE SiteId = @SiteId -- AND CarriedOutRole=1;	--### Summary text is Applicable only for TrainER....
	--WHERE Id = @TherapeuticId

	DECLARE @region VARCHAR(100)
	DECLARE @AreaNo INT
	DECLARE @insertionType VARCHAR(100)
	DECLARE @htmlAnchorCode VARCHAR(500)
	DECLARE @SummaryWithLinks VARCHAR(MAX)

	SELECT @region = CASE WHEN s.SiteNo = -77 THEN						--SiteNo is set to -77 for sites By Distance (Col & Sig only)
						CONVERT(VARCHAR,XCoordinate) +  
							CASE WHEN YCoordinate IS NULL OR YCoordinate=0 THEN ' cm' 
							ELSE (' to ' + CONVERT(VARCHAR,YCoordinate) + ' cm' ) 
							END
					ELSE (SELECT r.Region FROM ERS_Regions r WHERE r.RegionId = s.RegionId)
					END, 
			@AreaNo = ISNULL(AreaNo,0)
	FROM ERS_Sites s
	JOIN ERS_Procedures p ON s.ProcedureId = p.ProcedureId
	WHERE SiteId = @SiteId

	SET @htmlAnchorCode = '<a href="#" class="sitesummary" onclick="OpenSiteDetails(''' + @region + ''',' + CONVERT(VARCHAR(10),@SiteId) + ',''Therapeutic Procedures'', ''{0}'' , '''+ CONVERT(VARCHAR,@AreaNo) +  ''');">{1}</a>'

	SET @Summary = ''
	SET @SummaryWithLinks = ''
	DECLARE @SummaryHeading VARCHAR(200) = 'Post procedure patient care'

	IF @GastrostomyInsertion = 1
	BEGIN
		SET @insertionType = 'PEG'
		SET @SummaryHeading = 'Instructions for PEG care'
		IF @FlangePosition > 0 SET @Summary = 'Flange at ' + CONVERT(varchar, @FlangePosition) + ' cm.'
		IF @NilByMouth = 1
		BEGIN
			IF @Summary <> '' SET @Summary = @Summary + ' Nil by mouth' ELSE SET @Summary = 'Nil by mouth'
			IF @NilByMouthHrs > 0
			BEGIN
				SET @Summary = @Summary + ' for ' + CONVERT(varchar, @NilByMouthHrs)
				IF @NilByMouthHrs = 1
					SET @Summary = @Summary + ' hour'
				ELSE
					SET @Summary = @Summary + ' hours'
			END
		END
		IF @NilByProc = 1
		BEGIN
			IF @Summary <> '' SET @Summary = @Summary + ', nil by PEG' ELSE SET @Summary = 'Nil by PEG'
			IF @NilByProcHrs > 0
			BEGIN
				SET @Summary = @Summary + ' for ' + CONVERT(varchar, @NilByProcHrs)
				IF @NilByProcHrs = 1
					SET @Summary = @Summary + ' hour'
				ELSE
					SET @Summary = @Summary + ' hours'
			END
		END
		IF @Summary <> '' SET @Summary = @Summary + '.'
		IF @AttachmentToWard = 1
		BEGIN
			IF @Summary <> '' SET @Summary = @Summary + ' All attachments for feeding returned to the ward with patient.' ELSE SET @Summary = 'All attachments for feeding returned to the ward with patient.'
		END
	END

	ELSE
	BEGIN

		IF @YAGLaser = 1
		BEGIN
			SET @insertionType = 'YAG'
			IF @OesoYAGNilByMouth = 1
			BEGIN
				SET @Summary = 'Nil by mouth'
				IF @OesoYAGNilByMouthHrs > 0
				BEGIN
					SET @Summary = @Summary + ' for ' + CONVERT(varchar, @OesoYAGNilByMouthHrs)
					IF @OesoYAGNilByMouthHrs = 1
						SET @Summary = @Summary + ' hour'
					ELSE
						SET @Summary = @Summary + ' hours'
				END
			END

			IF @OesoYAGWarmFluids = 1
			BEGIN
				IF @Summary <> '' SET @Summary = @Summary + ', warm fluids only' ELSE SET @Summary = 'Warm fluids only'
				IF @OesoYAGWarmFluidsHrs > 0
				BEGIN
					SET @Summary = @Summary + ' for ' + CONVERT(varchar, @OesoYAGWarmFluidsHrs)
					IF @OesoYAGWarmFluidsHrs = 1
						SET @Summary = @Summary + ' hour'
					ELSE
						SET @Summary = @Summary + ' hours'
				END
			END

			IF @OesoYAGSoftDiet = 1
			BEGIN
				IF @Summary <> '' SET @Summary = @Summary + ', soft diet' ELSE SET @Summary = 'Soft diet'
				IF @OesoYAGSoftDietDays > 0
				BEGIN
					SET @Summary = @Summary + ' for ' + CONVERT(varchar, @OesoYAGSoftDietDays)
					IF @OesoYAGSoftDietDays = 1
						SET @Summary = @Summary + ' day'
					ELSE
						SET @Summary = @Summary + ' days'
				END
			END

			IF @Summary <> '' SET @Summary = @Summary + '.'

			IF @OesoYAGMedicalReview = 1
			BEGIN
				IF @Summary <> '' SET @Summary = @Summary + ' Medical review before discharge.' ELSE SET @Summary = 'Medical review before discharge.'
			END
		END

		IF @OesophagealDilatation = 1 OR @StentInsertion = 1
		BEGIN
			SET @insertionType = 'STENT'
			IF @OesoDilNilByMouth = 1
			BEGIN
				IF @Summary <> '' SET @Summary = @Summary + ' Nil by mouth' ELSE SET @Summary = 'Nil by mouth'
				IF @OesoDilNilByMouthHrs > 0
				BEGIN
					SET @Summary = @Summary + ' for ' + CONVERT(varchar, @OesoDilNilByMouthHrs)
					IF @OesoDilNilByMouthHrs = 1
						SET @Summary = @Summary + ' hour'
					ELSE
						SET @Summary = @Summary + ' hours'
				END
			END

			IF @OesoDilWarmFluids = 1
			BEGIN
				IF @Summary <> '' SET @Summary = @Summary + ', warm fluids only' ELSE SET @Summary = 'Warm fluids only'
				IF @OesoDilWarmFluidsHrs > 0
				BEGIN
					SET @Summary = @Summary + ' for ' + CONVERT(varchar, @OesoDilWarmFluidsHrs)
					IF @OesoDilWarmFluidsHrs = 1
						SET @Summary = @Summary + ' hour'
					ELSE
						SET @Summary = @Summary + ' hours'
				END
			END

			IF @OesoDilSoftDiet = 1
			BEGIN
				IF @Summary <> '' SET @Summary = @Summary + ', soft diet' ELSE SET @Summary = 'Soft diet'
				IF @OesoDilSoftDietDays > 0
				BEGIN
					SET @Summary = @Summary + ' for ' + CONVERT(varchar, @OesoDilSoftDietDays)
					IF @OesoDilSoftDietDays = 1
						SET @Summary = @Summary + ' day'
					ELSE
						SET @Summary = @Summary + ' days'
				END
			END

			IF @OesoDilXRay = 1
			BEGIN
				IF @Summary <> '' SET @Summary = @Summary + ', chest X-ray' ELSE SET @Summary = 'Chest X-ray'
				IF @OesoDilXRayHrs > 0
				BEGIN
					SET @Summary = @Summary + ' after ' + CONVERT(varchar, @OesoDilXRayHrs)
					IF @OesoDilXRayHrs = 1
						SET @Summary = @Summary + ' hour'
					ELSE
						SET @Summary = @Summary + ' hours'
				END
			END

			IF @Summary <> '' SET @Summary = @Summary + '.'

			IF @OesoDilMedicalReview = 1
			BEGIN
				IF @Summary <> '' SET @Summary = @Summary + ' Medical review before discharge.' ELSE SET @Summary = 'Medical review before discharge.'
			END
		END

		IF @Sigmoidopexy= 1
		BEGIN
			SET @SummaryHeading = 'Ward instructions'
			IF ISNULL(@SigmoidopexyFluidsDays,0) > 0
			BEGIN
				IF @Summary <> '' SET @Summary = @Summary + ' '
				SET @Summary = @Summary + 'Clear fluids for ' + CONVERT(varchar, @SigmoidopexyFluidsDays) 
								+ CASE WHEN @SigmoidopexyFluidsDays > 1 THEN ' days.' else ' day.' END
			END
			IF ISNULL(@SigmoidopexyAntibioticsDays,0) > 0
			BEGIN
				IF @Summary <> '' SET @Summary = @Summary + ' '
				SET @Summary = @Summary + 'Antibiotics for ' + CONVERT(varchar, @SigmoidopexyAntibioticsDays) 
								+ CASE WHEN @SigmoidopexyAntibioticsDays > 1 THEN ' days.' ELSE ' day.' END
			END
		END
	END

	IF @Summary = '' SET @SummaryHeading = ''

	-- Finally, update the summary in PP_InstForCare  table
	UPDATE p
	SET PP_InstForCare = @Summary
		, PP_InstForCareHeading = @SummaryHeading
		, PP_InstForCareWithLinks = REPLACE(REPLACE(@htmlAnchorCode, '{0}', @insertionType), '{1}', @Summary)
	FROM ERS_ProceduresReporting p
	INNER JOIN ERS_Sites s ON p.ProcedureId = s.ProcedureId
	WHERE s.SiteId = @SiteId;

	DROP TABLE #tmp_UpperGITherapeutics;
GO

-----------------------------------------------------------------------------------------------------------
Exec DropIfExist 'TR_Upper_GI_Therapeutic_Delete', 'TR'
  GO

CREATE TRIGGER [dbo].[TR_Upper_GI_Therapeutic_Delete]
ON [dbo].[ERS_UpperGITherapeutics]
AFTER DELETE
AS 
	--DECLARE @PatientNo VARCHAR(50)
	--DECLARE @EpisodeNo INT
	--DECLARE @SiteNo INT
	DECLARE @site_id INT

	--SELECT @PatientNo=[Patient No], @EpisodeNo=[Episode No], @SiteNo=[Site No] FROM DELETED
	SELECT @site_id=SiteId FROM DELETED

	EXEC ogd_kpi_stricture_perforation @site_id --Update perforation text in QA for OGD KPI

	EXEC sites_summary_update @site_id

	UPDATE p
	SET PP_InstForCare = ''
		, PP_InstForCareHeading = ''
		, PP_InstForCareWithLinks = ''
	FROM ERS_ProceduresReporting p
	INNER JOIN ERS_Sites s ON p.ProcedureId = s.ProcedureId
	WHERE s.SiteId = @site_id;

GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'therapeutics_ercp_summary_update','S';
GO
CREATE PROCEDURE [dbo].[therapeutics_ercp_summary_update]
(
	@TherapeuticId AS INT,
	@SiteId INT
)
AS
	SET NOCOUNT ON
	DECLARE	  @msg		VARCHAR(1000)
			, @Details	VARCHAR(1000)
			, @Summary	VARCHAR(4000)=''
			, @Area		VARCHAR(500)=''
			, @br VARCHAR(6) = '<br />';

	DECLARE
	@None BIT,
	@YAGLaser BIT,
	@YAGLaserWatts INT,
	@YAGLaserPulses INT,
	@YAGLaserSecs decimal(8,2),
	@YAGLaserKJ decimal(8,2),
	@ArgonBeamDiathermy BIT,
	@ArgonBeamDiathermyWatts INT,
	@ArgonBeamDiathermyPulses INT,
	@ArgonBeamDiathermySecs decimal(8,2),
	@ArgonBeamDiathermyKJ decimal(8,2),		
	@HeatProbe BIT,					
	@BicapElectro BIT,				
	@Diathermy BIT,						
	@HotBiopsy BIT,
	@BandLigation BIT,
    @BotoxInjection BIT,
    @EndoloopPlacement BIT,
    @ForeignBody BIT,
	@Injection BIT,
	@InjectionType INT,
	@InjectionVolume INT,
	@InjectionNumber INT,
	@GastrostomyInsertion BIT,
	@GastrostomyInsertionSize INT,
	@GastrostomyInsertionUnits TINYINT,
	@GastrostomyInsertionType TINYINT,
	@GastrostomyInsertionBatchNo VARCHAR(100),
	@NilByMouth BIT,
	@NilByMouthHrs INT,
	@NilByProc BIT,
	@NilByProcHrs INT,
	@AttachmentToWard BIT,
	@PyloricDilatation BIT,	
	@StentInsertion BIT,
	@StentInsertionQty INT,
	@RadioactiveWirePlaced BIT,	
	@StentInsertionBatchNo VARCHAR(100),
	@StentRemoval BIT,
	@StentRemovalTechnique INT,
	@EMR BIT,
	@EMRType TINYINT,
	@EMRFluid INT,
	@EMRFluidVolume INT,
	@Marking BIT,
	@MarkingType INT,
	@Clip BIT,						
	@ClipNum INT,
	@Papillotomy BIT,
	@Sphincterotome TINYINT,
	@PapillotomyLength REAL,
	@PapillotomyAcceptBalloonSize REAL,
	@ReasonForPapillotomy TINYINT,
	@PapillotomyBleeding TINYINT,
	@SphincterDecompressed TINYINT,
	@PanOrificeSphincterotomy BIT,
	@StoneRemoval BIT,
	@RemovalUsing TINYINT,
	@ExtractionOutcome TINYINT,
	@InadequateSphincterotomy BIT,
	@StoneSize BIT,
	@QuantityOfStones BIT,
	@ImpactedStones BIT,
	@OtherReason BIT,
	@OtherReasonText VARCHAR(200),
	@StoneDecompressed TINYINT,
	@StrictureDilatation BIT,
	@DilatedTo REAL,
	@DilatationUnits TINYINT,
	@DilatorType TINYINT,
	@EndoscopicCystPuncture BIT,
	@CystPunctureDevice TINYINT,
	@CystPunctureVia TINYINT,
	@Cannulation BIT,
	@Manometry BIT,
	@Haemostasis BIT,
	@NasopancreaticDrain BIT,
	@RendezvousProcedure BIT,
	@SnareExcision SMALLINT,
	@BalloonDilation BIT,
	@BalloonDilatedTo REAL,
	@BalloonDilatationUnits SMALLINT,
	@BalloonDilatorType SMALLINT,
	@BalloonTrawl BIT,
	@BalloonTrawlDilatorType SMALLINT,
	@BalloonTrawlDilatorSize REAL,
	@BalloonTrawlDilatorUnits SMALLINT,
	@BalloonDecompressed TINYINT,
	@DiagCholangiogram SMALLINT,
	@DiagPancreatogram SMALLINT,
	@EndoscopistRole SMALLINT,
	@Other VARCHAR(1000),
		@EUSProcType SMALLINT;

--BEGIN TRY

	SELECT * INTO #tmp_ERCPTherapeutics 
	FROM dbo.ERS_ERCPTherapeutics 
	WHERE (Id = @TherapeuticId OR SiteID = @SiteId)

--## 1) If 'CarriedOutRole=2 (EE)' record is found for a SiteId in [ERS_ERCPTherapeutics] means it has both EE/ER Entries...
	--IF EXISTS(SELECT 'ER' FROM dbo.ERS_ERCPTherapeutics WHERE SiteId=@SiteId AND CarriedOutRole=2)
		BEGIN
			--PRINT '[ERS_ERCPTherapeutics] has both EE/ER Entries...';
			;WITH eeRecord AS(
				SELECT * FROM #tmp_ERCPTherapeutics WHERE CarriedOutRole = (SELECT MAX(CarriedOutRole) FROM #tmp_ERCPTherapeutics) --## 2 is EE
			)
			SELECT
				@None				= (CASE WHEN IsNull(ER.[None], 0) = 0 THEN EE.[None] ELSE ER.[None] END),
				@YAGLaser			= (CASE WHEN IsNull(ER.YAGLaser, 0) = 0 THEN EE.YAGLaser ELSE ER.YAGLaser END),
				@YAGLaserWatts		= (CASE WHEN IsNull(ER.YAGLaserWatts, 0) = 0 THEN EE.YAGLaserWatts ELSE ER.YAGLaserWatts END),
				@YAGLaserPulses		= (CASE WHEN IsNull(ER.YAGLaserPulses, 0) = 0 THEN EE.YAGLaserPulses ELSE ER.YAGLaserPulses END),
				@YAGLaserSecs		= (CASE WHEN IsNull(ER.YAGLaserSecs, 0) = 0 THEN EE.YAGLaserSecs ELSE ER.YAGLaserSecs END),
				@YAGLaserKJ			= (CASE WHEN IsNull(ER.YAGLaserKJ, 0) = 0 THEN EE.YAGLaserKJ ELSE ER.YAGLaserKJ END),
				@ArgonBeamDiathermy	= (CASE WHEN IsNull(ER.ArgonBeamDiathermy, 0) = 0 THEN EE.ArgonBeamDiathermy ELSE ER.ArgonBeamDiathermy END),
				@ArgonBeamDiathermyWatts		= (CASE WHEN IsNull(ER.ArgonBeamDiathermyWatts, 0) = 0 THEN EE.ArgonBeamDiathermyWatts ELSE ER.ArgonBeamDiathermyWatts END),
				@ArgonBeamDiathermyPulses		= (CASE WHEN IsNull(ER.ArgonBeamDiathermyPulses, 0) = 0 THEN EE.ArgonBeamDiathermyPulses ELSE ER.ArgonBeamDiathermyPulses END),
				@ArgonBeamDiathermySecs			= (CASE WHEN IsNull(ER.ArgonBeamDiathermySecs, 0) = 0 THEN EE.ArgonBeamDiathermySecs ELSE ER.ArgonBeamDiathermySecs END),
				@ArgonBeamDiathermyKJ			= (CASE WHEN IsNull(ER.ArgonBeamDiathermyKJ, 0) = 0 THEN EE.ArgonBeamDiathermyKJ ELSE ER.ArgonBeamDiathermyKJ END),
				@HeatProbe			= (CASE WHEN IsNull(ER.HeatProbe, 0) = 0 THEN EE.HeatProbe ELSE ER.HeatProbe END),
				@BicapElectro		= (CASE WHEN IsNull(ER.BicapElectro, 0) = 0 THEN EE.BicapElectro ELSE ER.BicapElectro END),
				@Diathermy			= (CASE WHEN IsNull(ER.Diathermy, 0) = 0 THEN EE.Diathermy ELSE ER.Diathermy END),
				@HotBiopsy			= (CASE WHEN IsNull(ER.HotBiopsy, 0) = 0 THEN EE.HotBiopsy ELSE ER.HotBiopsy END),
				@BandLigation= (CASE WHEN IsNull(ER.BandLigation, 0) = 0 THEN EE.BandLigation ELSE ER.BandLigation END),
				@BotoxInjection = (CASE WHEN IsNull(ER.BotoxInjection, 0) = 0 THEN EE.BotoxInjection ELSE ER.BotoxInjection END),
				@EndoloopPlacement = (CASE WHEN IsNull(ER.EndoloopPlacement, 0) = 0 THEN EE.EndoloopPlacement ELSE ER.EndoloopPlacement END),
				@ForeignBody= (CASE WHEN IsNull(ER.ForeignBody, 0) = 0 THEN EE.ForeignBody ELSE ER.ForeignBody END),
				@Injection			= (CASE WHEN IsNull(ER.Injection, 0) = 0 THEN EE.Injection ELSE ER.Injection END),
				@InjectionType		= (CASE WHEN IsNull(ER.InjectionType, 0) = 0 THEN EE.InjectionType ELSE ER.InjectionType END),
				@InjectionVolume	= (CASE WHEN IsNull(ER.InjectionVolume, 0) = 0 THEN EE.InjectionVolume ELSE ER.InjectionVolume END),
				@InjectionNumber	= (CASE WHEN IsNull(ER.InjectionNumber, 0) = 0 THEN EE.InjectionNumber ELSE ER.InjectionNumber END),
				@GastrostomyInsertion			= (CASE WHEN IsNull(ER.GastrostomyInsertion, 0) = 0 THEN EE.GastrostomyInsertion ELSE ER.GastrostomyInsertion END),
				@GastrostomyInsertionSize		= (CASE WHEN IsNull(ER.GastrostomyInsertionSize, 0) = 0 THEN EE.GastrostomyInsertionSize ELSE ER.GastrostomyInsertionSize END),
				@GastrostomyInsertionUnits		= (CASE WHEN ER.GastrostomyInsertionUnits IS NULL THEN EE.GastrostomyInsertionUnits ELSE ER.GastrostomyInsertionUnits END),
				@GastrostomyInsertionType		= (CASE WHEN IsNull(ER.GastrostomyInsertionType, 0) = 0 THEN EE.GastrostomyInsertionType ELSE ER.GastrostomyInsertionType END),
				@GastrostomyInsertionBatchNo	= (SELECT isnull((CASE WHEN IsNull(ER.GastrostomyInsertionBatchNo, '') = '' THEN EE.GastrostomyInsertionBatchNo ELSE ER.GastrostomyInsertionBatchNo END), '') as [text()] FOR XML PATH('')),
				@NilByMouth			= (CASE WHEN IsNull(ER.NilByMouth, 0) = 0 THEN EE.NilByMouth ELSE ER.NilByMouth END),
				@NilByMouthHrs		= (CASE WHEN IsNull(ER.NilByMouthHrs, 0) = 0 THEN EE.NilByMouthHrs ELSE ER.NilByMouthHrs END),
				@NilByProc			= (CASE WHEN IsNull(ER.NilByProc, 0) = 0 THEN EE.NilByProc ELSE ER.NilByProc END),
				@NilByProcHrs		= (CASE WHEN IsNull(ER.NilByProcHrs, 0) = 0 THEN EE.NilByProcHrs ELSE ER.NilByProcHrs END),
				@AttachmentToWard	= (CASE WHEN IsNull(ER.AttachmentToWard, 0) = 0 THEN EE.AttachmentToWard ELSE ER.AttachmentToWard END),
				@PyloricDilatation	= (CASE WHEN IsNull(ER.PyloricDilatation, 0) = 0 THEN EE.PyloricDilatation ELSE ER.PyloricDilatation END),
				@StentInsertion		= (CASE WHEN IsNull(ER.StentInsertion, 0) = 0 THEN EE.StentInsertion ELSE ER.StentInsertion END),
				@StentInsertionQty	= (CASE WHEN IsNull(ER.StentInsertionQty, 0) = 0 THEN EE.StentInsertionQty ELSE ER.StentInsertionQty END),
				@RadioactiveWirePlaced			= (CASE WHEN IsNull(ER.RadioactiveWirePlaced, 0) = 0 THEN EE.RadioactiveWirePlaced ELSE ER.RadioactiveWirePlaced END),
				@StentInsertionBatchNo			= (SELECT isnull((CASE WHEN IsNull(ER.StentInsertionBatchNo,'')= '' THEN EE.StentInsertionBatchNo ELSE ER.StentInsertionBatchNo END), '') as [text()] FOR XML PATH('')),
				@StentRemoval					= (CASE WHEN IsNull(ER.StentRemoval, 0) = 0 THEN EE.StentRemoval ELSE ER.StentRemoval END),
				@StentRemovalTechnique			= (CASE WHEN IsNull(ER.StentRemovalTechnique, 0) = 0 THEN EE.StentRemovalTechnique ELSE ER.StentRemovalTechnique END),
				@EMR				= (CASE WHEN IsNull(ER.EMR, 0) = 0 THEN EE.EMR ELSE ER.EMR END),
				@EMRType			= (CASE WHEN IsNull(ER.EMRType, 0) = 0 THEN EE.EMRType ELSE ER.EMRType END),
				@EMRFluid			= (CASE WHEN IsNull(ER.EMRFluid, 0) = 0 THEN EE.EMRFluid ELSE ER.EMRFluid END),
				@EMRFluidVolume		= (CASE WHEN IsNull(ER.EMRFluidVolume, 0) = 0 THEN EE.EMRFluidVolume ELSE ER.EMRFluidVolume END),
				@Marking			= (CASE WHEN IsNull(ER.Marking, 0) = 0 THEN EE.Marking ELSE ER.Marking END),
				@MarkingType		= (CASE WHEN IsNull(ER.MarkingType, 0) = 0 THEN EE.MarkingType ELSE ER.MarkingType END),
				@Clip				= (CASE WHEN IsNull(ER.Clip, 0) = 0 THEN EE.Clip ELSE ER.Clip END),
				@ClipNum			= (CASE WHEN IsNull(ER.ClipNum, 0) = 0 THEN EE.ClipNum ELSE ER.ClipNum END),
				@Papillotomy		= (CASE WHEN IsNull(ER.Papillotomy, 0) = 0 THEN EE.Papillotomy ELSE ER.Papillotomy END),
				@Sphincterotome		= (CASE WHEN IsNull(ER.Sphincterotome, 0) = 0 THEN EE.Sphincterotome ELSE ER.Sphincterotome END),
				@PapillotomyLength	= (CASE WHEN IsNull(ER.PapillotomyLength, 0) = 0 THEN EE.PapillotomyLength ELSE ER.PapillotomyLength END),
				@PapillotomyAcceptBalloonSize	= (CASE WHEN IsNull(ER.PapillotomyAcceptBalloonSize, 0) = 0 THEN EE.PapillotomyAcceptBalloonSize ELSE ER.PapillotomyAcceptBalloonSize END),
				@ReasonForPapillotomy		= (CASE WHEN IsNull(ER.ReasonForPapillotomy, 0) = 0 THEN EE.ReasonForPapillotomy ELSE ER.ReasonForPapillotomy END),
				@PapillotomyBleeding		= (CASE WHEN IsNull(ER.PapillotomyBleeding, 0) = 0 THEN EE.PapillotomyBleeding ELSE ER.PapillotomyBleeding END),
				@SphincterDecompressed		= (CASE WHEN IsNull(ER.SphincterDecompressed, 0) = 0 THEN EE.SphincterDecompressed ELSE ER.SphincterDecompressed END),
				@PanOrificeSphincterotomy	= (CASE WHEN IsNull(ER.PanOrificeSphincterotomy, 0) = 0 THEN EE.PanOrificeSphincterotomy ELSE ER.PanOrificeSphincterotomy END),
				@StoneRemoval				= (CASE WHEN IsNull(ER.StoneRemoval, 0) = 0 THEN EE.StoneRemoval ELSE ER.StoneRemoval END),
				@RemovalUsing				= (CASE WHEN IsNull(ER.RemovalUsing, 0) = 0 THEN EE.RemovalUsing ELSE ER.RemovalUsing END),
				@ExtractionOutcome			= (CASE WHEN IsNull(ER.ExtractionOutcome, 0) = 0 THEN EE.ExtractionOutcome ELSE ER.ExtractionOutcome END),
				@InadequateSphincterotomy	= (CASE WHEN IsNull(ER.InadequateSphincterotomy, 0) = 0 THEN EE.InadequateSphincterotomy ELSE ER.InadequateSphincterotomy END),
				@StoneSize			= (CASE WHEN IsNull(ER.StoneSize, 0) = 0 THEN EE.StoneSize ELSE ER.StoneSize END),
				@QuantityOfStones	= (CASE WHEN IsNull(ER.QuantityOfStones, 0) = 0 THEN EE.QuantityOfStones ELSE ER.QuantityOfStones END),
				@ImpactedStones		= (CASE WHEN IsNull(ER.ImpactedStones, 0) = 0 THEN EE.ImpactedStones ELSE ER.ImpactedStones END),
				@OtherReason		= (CASE WHEN IsNull(ER.OtherReason, 0) = 0 THEN EE.OtherReason ELSE ER.OtherReason END),
				@OtherReasonText	= (SELECT isnull((CASE WHEN IsNull(ER.OtherReasonText, '') = '' THEN EE.OtherReasonText ELSE ER.OtherReasonText END), '') as [text()] FOR XML PATH('')),
				@StoneDecompressed	= (CASE WHEN IsNull(ER.StoneDecompressed, 0) = 0 THEN EE.StoneDecompressed ELSE ER.StoneDecompressed END),
				@StrictureDilatation= (CASE WHEN IsNull(ER.StrictureDilatation, 0) = 0 THEN EE.StrictureDilatation ELSE ER.StrictureDilatation END),
				@DilatedTo			= (CASE WHEN IsNull(ER.DilatedTo, 0) = 0 THEN EE.DilatedTo ELSE ER.DilatedTo END),
				@DilatationUnits	= (CASE WHEN ER.DilatationUnits IS NULL THEN EE.DilatationUnits ELSE ER.DilatationUnits END),
				@DilatorType		= (CASE WHEN IsNull(ER.DilatorType, 0) = 0 THEN EE.DilatorType ELSE ER.DilatorType END),
				@EndoscopicCystPuncture	= (CASE WHEN IsNull(ER.EndoscopicCystPuncture, 0) = 0 THEN EE.EndoscopicCystPuncture ELSE ER.EndoscopicCystPuncture END),
				@CystPunctureDevice		= (CASE WHEN IsNull(ER.CystPunctureDevice, 0) = 0 THEN EE.CystPunctureDevice ELSE ER.CystPunctureDevice END),
				@CystPunctureVia		= (CASE WHEN IsNull(ER.CystPunctureVia, 0) = 0 THEN EE.CystPunctureVia ELSE ER.CystPunctureVia END),
				@Cannulation			= (CASE WHEN IsNull(ER.Cannulation, 0) = 0 THEN EE.Cannulation ELSE ER.Cannulation END),
				@Manometry				= (CASE WHEN IsNull(ER.Manometry, 0) = 0 THEN EE.Manometry ELSE ER.Manometry END),
				@Haemostasis			= (CASE WHEN IsNull(ER.Haemostasis, 0) = 0 THEN EE.Haemostasis ELSE ER.Haemostasis END),
				@NasopancreaticDrain	= (CASE WHEN IsNull(ER.NasopancreaticDrain, 0) = 0 THEN EE.NasopancreaticDrain ELSE ER.NasopancreaticDrain END),
				@RendezvousProcedure	= (CASE WHEN IsNull(ER.RendezvousProcedure, 0) = 0 THEN EE.RendezvousProcedure ELSE ER.RendezvousProcedure END),
				@SnareExcision			= (CASE WHEN IsNull(ER.SnareExcision, 0) = 0 THEN EE.SnareExcision ELSE ER.SnareExcision END),
				@BalloonDilation		= (CASE WHEN IsNull(ER.BalloonDilation, 0) = 0 THEN EE.BalloonDilation ELSE ER.BalloonDilation END),
				@BalloonDilatedTo		= (CASE WHEN IsNull(ER.BalloonDilatedTo, 0) = 0 THEN EE.BalloonDilatedTo ELSE ER.BalloonDilatedTo END),
				@BalloonDilatationUnits	= (CASE WHEN IsNull(ER.BalloonDilatationUnits, 0) = 0 THEN EE.BalloonDilatationUnits ELSE ER.BalloonDilatationUnits END),
				@BalloonDilatorType		= (CASE WHEN IsNull(ER.BalloonDilatorType, 0) = 0 THEN EE.BalloonDilatorType ELSE ER.BalloonDilatorType END),
				@BalloonTrawl			= (CASE WHEN IsNull(ER.BalloonTrawl, 0) = 0 THEN EE.BalloonTrawl ELSE ER.BalloonTrawl END),
				@BalloonTrawlDilatorType	= (CASE WHEN IsNull(ER.BalloonTrawlDilatorType, 0) = 0 THEN EE.BalloonTrawlDilatorType ELSE ER.BalloonTrawlDilatorType END),
				@BalloonTrawlDilatorSize	= (CASE WHEN IsNull(ER.BalloonTrawlDilatorSize, 0) = 0 THEN EE.BalloonTrawlDilatorSize ELSE ER.BalloonTrawlDilatorSize END),
				@BalloonTrawlDilatorUnits	= (CASE WHEN IsNull(ER.BalloonTrawlDilatorUnits, 0) = 0 THEN EE.BalloonTrawlDilatorUnits ELSE ER.BalloonTrawlDilatorUnits END),
				@BalloonDecompressed		= (CASE WHEN IsNull(ER.BalloonDecompressed, 0) = 0 THEN EE.BalloonDecompressed ELSE ER.BalloonDecompressed END),
				@DiagCholangiogram			= (CASE WHEN IsNull(ER.DiagCholangiogram, 0) = 0 THEN EE.DiagCholangiogram ELSE ER.DiagCholangiogram END),
				@DiagPancreatogram			= (CASE WHEN IsNull(ER.DiagPancreatogram, 0) = 0 THEN EE.DiagPancreatogram ELSE ER.DiagPancreatogram END),
				@EndoscopistRole			= (CASE WHEN IsNull(ER.CarriedOutRole, 0) = 0 THEN EE.CarriedOutRole ELSE ER.CarriedOutRole END),
				@Other						= (CASE WHEN IsNull(ER.Other, '') ='' THEN EE.Other ELSE ER.Other END),
				@EUSProcType				= (CASE WHEN IsNull(ER.EUSProcType, 0) = 0 THEN EE.EUSProcType ELSE ER.EUSProcType END)
			FROM eeRecord AS EE
	  INNER JOIN #tmp_ERCPTherapeutics AS ER ON EE.SiteId = ER.SiteId;
		END	--## Selecting from Combine
				
	
	IF @None = 1
		SET @summary = @summary + 'No specimens taken'
	ELSE
	BEGIN
		----------------------
        -- Sphincterotomy
        ----------------------
		IF @Papillotomy = 1
		BEGIN
			SET @msg =' Sphincterotomy'
			SET @Details = ''
			IF @ReasonForPapillotomy > 0 
			BEGIN
				SET @Details = @Details + ' ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'ERCP papillotomy reason' AND [ListItemNo] = @ReasonForPapillotomy)

				--Place the word 'for' in front of the reason for the papillotomy if required.
				IF LEFT(UPPER(LTRIM(@Details)),4) <> 'FOR ' SET @Details = ' for ' + @Details
				SET @msg = @msg + ' (' + @Details + ')'
				SET @Details = ''
			END
			IF @PapillotomyLength > 0 SET @Details = @Details + ' ' + CAST(@PapillotomyLength as varchar(50)) + 'mm'
			IF @Sphincterotome > 0 SET @Details = @Details + ' using ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Therapeutic ERCP sphincterotomes' AND [ListItemNo] = @Sphincterotome)
			IF @PapillotomyBleeding > 0 
			BEGIN
				If LEN(RTRIM(LTRIM(@Details))) > 0 SET @Details = @Details + ','
				SET @Details = @Details + CASE @PapillotomyBleeding
											WHEN 1 THEN ' with no bleeding'   
											WHEN 2 THEN ' with minor bleeding'  
											WHEN 3 THEN ' with major bleeding'
											ELSE '' 
										END   
			END
			IF @PapillotomyAcceptBalloonSize > 0 
			BEGIN
				If LEN(RTRIM(LTRIM(@Details))) > 0 SET @Details = @Details + ','
				SET @Details = @Details + ' incision accepted ' + cast(@PapillotomyAcceptBalloonSize as varchar(50)) + 'ml balloon'
			END
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END
		
		----------------------
        -- Pancreatic orifice sphincterotomy
        ----------------------
		IF @PanOrificeSphincterotomy = 1
		BEGIN
			SET @msg =' Pancreatic orifice sphincterotomy'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		----------------------
        -- Stone removal
        ----------------------
		IF @StoneRemoval = 1
		BEGIN
			SET @msg =' Stone removal'
			SET @Details = ''

			IF @ExtractionOutcome > 0 
			BEGIN
				SET @Details = @Details + CASE @ExtractionOutcome
											WHEN 1 THEN ' complete extraction'   
											WHEN 2 THEN ' fragmented'  
											WHEN 3 THEN ' partial extraction'
											WHEN 4 THEN ' unable to extract'
											ELSE '' 
										END   
				DECLARE @cnt bit = 0
				IF @ExtractionOutcome BETWEEN 3 AND 4
				BEGIN
					DECLARE @tmpDiv TABLE(Val VARCHAR(MAX))
					DECLARE @XMLlist XML

					IF @InadequateSphincterotomy > 0
					BEGIN
						INSERT INTO @tmpDiv (Val) VALUES('inadequate sphincterotomy')
					END

					IF @StoneSize > 0
					BEGIN
						INSERT INTO @tmpDiv (Val) VALUES('stone size')
					END

					IF @QuantityOfStones > 0
					BEGIN
						INSERT INTO @tmpDiv (Val) VALUES('quantity of stones')
					END

					IF @ImpactedStones > 0
					BEGIN
						INSERT INTO @tmpDiv (Val) VALUES('impacted stone(s)')
					END

					IF @OtherReason > 0
					BEGIN
						IF LTRIM(RTRIM(ISNULL(@OtherReasonText,''))) <> ''
						BEGIN
							INSERT INTO @tmpDiv (Val) VALUES(@OtherReasonText)
						END
					END

					IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
					BEGIN
						SET @XMLlist = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
						SET @Details = @Details + ' due to ' + dbo.fnBuildString(@XMLlist)
					END
				END
			END

			IF @RemovalUsing > 0 SET @Details = @Details + ' using ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'ERCP stone removal method' AND [ListItemNo] = @RemovalUsing)


			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		----------------------
        -- Stricture dilatation
        ----------------------
		IF @StrictureDilatation= 1
			BEGIN
			SET @msg =' Stricture dilatation'
			SET @Details = ''

			IF @DilatedTo > 0 
			BEGIN
				SET @Details = @Details + ' dilated to ' + cast(@DilatedTo as varchar(50)) + ' ' + 
									ISNULL((SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilatation units' AND [ListItemNo] = @DilatationUnits),'')
			END

			--Dilator type
			IF @DilatorType > 0 
			BEGIN
				DECLARE @tmpDilatorType VARCHAR(100) = (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilator' AND [ListItemNo] = @DilatorType)
				IF UPPER(LEFT(LTRIM(@tmpDilatorType),5)) = 'WITH ' OR UPPER(LEFT(LTRIM(@tmpDilatorType),3)) = 'BY ' 
					SET @Details = @Details + ' ' + @tmpDilatorType
				ELSE
					SET @Details = @Details + ' with ' + @tmpDilatorType
			END	
			
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		----------------------
        -- Endoscopic cyst puncture
        ----------------------
		IF @EndoscopicCystPuncture = 1
		BEGIN
			SET @msg =' Endoscopic cyst puncture'
			SET @Details = ''
			IF @CystPunctureDevice > 0 SET @Details = @Details + ' using ' + 
															(SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'ERCP cyst punct device' AND [ListItemNo] = @CystPunctureDevice)

			SET @Details = @Details + CASE @CystPunctureVia
							WHEN 1 THEN ' via papilla'   
							WHEN 2 THEN ' via medial wall of duodenum (cyst-duodenostomy)'  
							WHEN 3 THEN ' via stomach (cyst-gastrostomy)'
							ELSE '' 
						END   

			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Nasobiliary/pancreatic drain
        -------------------------------
		IF @NasopancreaticDrain = 1
		BEGIN
			IF EXISTS ( SELECT r.Region FROM ERS_AbnormalitiesMatrixERCP m 
							LEFT JOIN ERS_Regions r ON m.Region = r.Region 
									AND r.Region IN ('Uncinate Process', 'Head', 'Neck', 'Body', 'Tail', 'Accessory Pancreatic Duct', 'Main Pancreatic Duct')
							LEFT JOIN ERS_Sites s ON r.RegionId  = s.RegionID  
							WHERE s.siteId = @SiteId)
				SET @msg =' Nasopancreatic drain'
			ELSE
				SET @msg =' Nasobiliary drain'


			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Combined procedure
        -------------------------------
		IF @RendezvousProcedure = 1
		BEGIN
			SET @msg =' Combined procedure (rendezvous)'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Snare excision
        -------------------------------
		IF @SnareExcision = 1
		BEGIN
			SET @msg =' Snare excision'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		----------------------
        -- Balloon sphincteroplasty
        ----------------------
		IF @BalloonDilation= 1
			BEGIN
			SET @msg =' Balloon sphincteroplasty'
			SET @Details = ''

			IF @BalloonDilatedTo > 0 
			BEGIN
				SET @Details = @Details + ' dilated to ' + cast(@BalloonDilatedTo as varchar(50)) + ' ' + 
									(SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilatation units' AND [ListItemNo] = @BalloonDilatationUnits)
			END

			--Balloon Dilator type
			IF @BalloonDilatorType > 0 
			BEGIN
				DECLARE @tmpBalloonDilatorType VARCHAR(100) = (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'ERCP balloon dilator' AND [ListItemNo] = @BalloonDilatorType)
				IF UPPER(LEFT(LTRIM(@tmpBalloonDilatorType),5)) = 'WITH ' OR UPPER(LEFT(LTRIM(@tmpBalloonDilatorType),3)) = 'BY ' 
					SET @Details = @Details + ' ' + @tmpBalloonDilatorType
				ELSE
					SET @Details = @Details + ' with ' + @tmpBalloonDilatorType
			END	
			
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END


		----------------------
        -- Balloon trawl
        ----------------------
		IF @BalloonTrawl = 1
			BEGIN
			SET @msg =' Balloon trawl'
			SET @Details = ''

			IF @BalloonTrawlDilatorType > 0 
			BEGIN
				DECLARE @DilType VARCHAR(100) = (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'ERCP Balloon dilator' AND [ListItemNo] = @BalloonTrawlDilatorType)
				IF LTRIM(RTRIM(@DilType)) <> ''
				BEGIN
					
					IF UPPER(LEFT(@DilType,1)) in ('A','E','I','O','U') 
						SET @Details = @Details + ' using an' 
					ELSE
						SET @Details = @Details + ' using a'

					SET @Details = @Details + ' ' + @DilType
				END
			END

			IF @BalloonTrawlDilatorUnits >= 0 
			BEGIN
				IF @BalloonTrawlDilatorSize > 0 
				BEGIN
					SET @Details = @Details + ' dilated to ' + cast(@BalloonTrawlDilatorSize as varchar(50)) + ' ' + 
									(SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilatation units' AND [ListItemNo] = @BalloonTrawlDilatorUnits)
				END
			END
			
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Cannulation
        -------------------------------
		IF @Cannulation = 1
		BEGIN
			SET @msg =' Cannulation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Manometry
        -------------------------------
		IF @Manometry = 1
		BEGIN
			SET @msg =' Manometry'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Haemostasis
        -------------------------------
		IF @Haemostasis = 1
		BEGIN
			SET @msg =' Haemostasis'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Diagnostic cholangiogram
        -------------------------------
		IF @DiagCholangiogram = 1
		BEGIN
			SET @msg =' Diagnostic cholangiogram'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Diagnostic pancreatogram
        -------------------------------
		IF @DiagPancreatogram = 1
		BEGIN
			SET @msg =' Diagnostic pancreatogram'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

	-- DUODENUM -----
		IF @YAGLaser = 1
			BEGIN
				SET @msg =' YAG Laser'
				SET @Details = ''
				IF @YAGLaserWatts > 0 SET @Details = @Details + ' ' + CAST(@YAGLaserWatts as varchar(50)) + 'W'
				IF @YAGLaserSecs > 0 SET @Details = @Details + ' for ' + cast(CAST(@YAGLaserSecs AS FLOAT) as varchar(50)) + CASE WHEN @YAGLaserSecs <= 1 THEN ' second' else ' seconds' END
				IF @YAGLaserPulses > 0 SET @Details = @Details + ' in ' + cast(@YAGLaserPulses as varchar(50)) + CASE WHEN @YAGLaserPulses <= 1 THEN ' pulse' else ' pulses' END
				IF @YAGLaserKJ > 0 SET @Details = @Details + ' ('+ cast(CAST(@YAGLaserKJ AS FLOAT) as varchar(50)) + 'kJ)'
				If @Details<>'' SET @msg = @msg + ': ' + @Details
				--Add full stop 
				SET @msg = RTrim(LTRIM(@msg))
				IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
				--------------
				SET @summary = @summary + @msg + '<br/>'
			END
		
		IF @ArgonBeamDiathermy= 1
			BEGIN
			SET @msg ='  Argon beam diathermy'
			SET @Details = ''
			IF @ArgonBeamDiathermyWatts > 0 SET @Details = @Details + ' ' + cast(@ArgonBeamDiathermyWatts as varchar(50)) + 'W'
			IF @ArgonBeamDiathermySecs > 0 SET @Details = @Details + ' for ' + cast(CAST(@ArgonBeamDiathermySecs AS FLOAT) as varchar(50)) + CASE WHEN @ArgonBeamDiathermySecs <= 1 THEN ' second' else ' seconds' END
			IF @ArgonBeamDiathermyPulses > 0 SET @Details = @Details + ' in ' + cast(@ArgonBeamDiathermyPulses as varchar(50)) + CASE WHEN @ArgonBeamDiathermyPulses <= 1 THEN ' pulse' else ' pulses' END
			IF @ArgonBeamDiathermyKJ > 0 SET @Details = @Details + ' ('+ cast(CAST(@ArgonBeamDiathermyKJ AS FLOAT) as varchar(50)) + 'kJ)'
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
			END

			
		IF @Injection= 1
			BEGIN
			SET @msg =' Injection'
			SET @Details = ''
			IF @InjectionVolume > 0 SET @Details = @Details + '  ' + cast(@InjectionVolume as varchar(50)) + 'ml'
			IF @InjectionVolume > 0  AND @InjectionType > 0 SET @Details = @Details + ' of'
			IF @InjectionType > 0 SET @Details = @Details + ' ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Agent Upper GI' AND [ListItemNo] = @InjectionType)
			IF @InjectionVolume> 0  AND @InjectionNumber > 0 SET @Details = @Details + ' via'
			IF @InjectionNumber >0 SET @Details = @Details + ' ' + CASE WHEN @InjectionNumber > 1 THEN cast(@InjectionNumber as varchar(50)) + ' injections' ELSE cast(@InjectionNumber as varchar(50)) + ' injection' END
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END
	
		IF @Diathermy = 1
			BEGIN
			SET @msg = ' Diathermy'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @BicapElectro = 1
			BEGIN
			SET @msg = ' Bicap electrocautery'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @HeatProbe = 1
			BEGIN
			SET @msg = ' Heater probe coagulation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END
		
		IF @HotBiopsy = 1
			BEGIN
			SET @msg = ' Hot biopsy'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @BandLigation = 1
			BEGIN
			SET @msg = ' Band ligation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @BotoxInjection = 1
			BEGIN
			SET @msg = ' Botox injection'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @EndoloopPlacement = 1
			BEGIN
			SET @msg = ' Endoloop placement'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @ForeignBody = 1
			BEGIN
			SET @msg = ' Foreign body removal'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		----------------------
        -- Stent insertion
        ----------------------
		IF @StentInsertion= 1
			BEGIN
			SET @msg =' Stent insertion'
			SET @Details = ''

			--Qty of stents used
			IF @StentInsertionQty > 0 SET @Details = @Details + '  ' + cast(@StentInsertionQty as varchar(50))

			SET @Details = @Details + dbo.ercp_stentinsertions_summary(@TherapeuticId)

			IF @RadioactiveWirePlaced > 0  SET @Details = @Details + ', radiotherapeutic wire placed' 
			IF ISNULL(@StentInsertionBatchNo,'') <> ''  SET @Details = @Details + ', batch ' + LTRIM(RTRIM(@StentInsertionBatchNo))
			
			If @Details<>'' SET @msg = @msg + ': ' + @Details 
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		----------------------
        -- Stent removal
        ----------------------
		IF @StentRemoval= 1
			BEGIN
			SET @msg =' Stent removal'
			SET @Details = ''
			IF @StentRemovalTechnique > 0  SET @Details = @Details + 'using ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Therapeutic Stent Removal Technique' AND [ListItemNo] = @StentRemovalTechnique)
			IF @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @EMR= 1
			BEGIN
			IF @EMRType = 2
				SET @msg =' Endoscopic submucosal dissection'
			ELSE
				SET @msg =' Endoscopic mucosal resection'
			SET @Details = ''
			IF @EMRFluid > 0  SET @Details = @Details + 'using ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Therapeutic EMR Fluid' AND [ListItemNo] = @EMRFluid)
			IF @EMRFluidVolume >0 
				BEGIN
				IF @EMRFluid >0 SET  @Details = @Details + ', '
				SET  @Details = @Details + 'total volume ' + cast(@emrfluidvolume AS varchar(50)) + 'ml'
				END
			IF @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @GastrostomyInsertion =1
			BEGIN
			DECLARE @G bit, @J bit, @N bit
			--SELECT @j = i.[JejunostomyInsertion], @G =i.[GastrostomyInsertion],@N = i.[NasoDuodenalTube] FROM [ERS_UpperGIIndications] i LEFT JOIN [ERS_Sites] s ON i.ProcedureId = s.ProcedureId WHERE s.SiteId = @SiteID
			--IF @N = 1 SET @msg =' Nasojejunal tube (NJT)' ELSE IF @J= 1 SET @msg =' Jejunostomy insertion (PEJ)' ELSE SET @msg =' Gastrostomy insertion (PEG)'
			SET @msg =' Nasojejunal tube (NJT)' -- For ERCP, it is Nasojejunal
			SET @Details = ''

			IF @GastrostomyInsertionType > 0
				BEGIN
				IF @GastrostomyInsertionSize>0
					BEGIN
					SET @Details = @Details + cast(@GastrostomyInsertionSize as varchar(50))
					--IF @J=1 
					SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG units' AND [ListItemNo] = @GastrostomyInsertionUnits)
					--ELSE IF @N =1 SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG units' AND [ListItemNo] = @GastrostomyInsertionUnits)
					--ELSE SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG units' AND [ListItemNo] = @GastrostomyInsertionUnits)
					END
				END
				IF @GastrostomyInsertionType>0
						BEGIN
						IF @J=1 SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG type' AND [ListItemNo] = @GastrostomyInsertiontype)
						ELSE IF @N =1 SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG type' AND [ListItemNo] = @GastrostomyInsertiontype)
						ELSE SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG type' AND [ListItemNo] = @GastrostomyInsertiontype)
						END
				IF @GastrostomyInsertionBatchNo <> null AND @GastrostomyInsertionBatchNo <> ''  SET @Details = @Details + ' batch ' + @GastrostomyInsertionBatchNo
				
				IF @Details<>'' SET @msg = @msg + ': ' + @Details
				--Add full stop 
				SET @msg = RTrim(LTRIM(@msg))
				IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
				--------------
				SET @summary = @summary + @msg + '<br/>'
				END

		IF @Marking= 1
		BEGIN
			SET @msg =' Abnormality marked'
			SET @Details = ''
			IF @MarkingType > 0 SET @Details = @Details + ' by ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Abno marking' AND [ListItemNo] = @MarkingType)

			IF @Details<>'' SET @msg = @msg + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @Clip= 1
		BEGIN 
			SET @msg = CASE WHEN @ClipNum > 1 THEN  CAST(@ClipNum as varchar(5)) + ' clips'
							WHEN @ClipNum = 1 THEN  CAST(@ClipNum as varchar(5)) + ' clip'
							ELSE 'Clip'
						END
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		-------------------------------
        -- Pyloric/duodenal dilatation
        -------------------------------
		IF @PyloricDilatation= 1
		BEGIN
			SET @msg =' Pyloric dilatation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF LTRIM(RTRIM(@other)) <> ''
			BEGIN
			SET @msg =' ' + LTRIM(RTRIM(@other))
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary =  @summary + @msg  +'<br/>'
		END

	END;

	UPDATE dbo.ERS_ERCPTherapeutics 
	SET Summary=@summary 
	WHERE SiteID = @SiteId; --Id = @TherapeuticId

	DROP TABLE #tmp_ERCPTherapeutics;

GO
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
