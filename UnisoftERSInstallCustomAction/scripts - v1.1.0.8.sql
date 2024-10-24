--UPDATE Bowel Preparation to be spelt correctly
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
	@BowelSettings bit

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
		@BowelSettings = BowelPrepSettings
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
			END
		END

	UPDATE  [ERS_BowelPreparation] SET Summary = @Summary WHERE ProcedureID=@ProcedureId
	UPDATE [ERS_ProceduresReporting] SET [PP_Bowel_Prep] = @Summary WHERE ProcedureID=@ProcedureId
	EXEC procedure_summary_update @ProcedureId
GO
UPDATE ERS_ListsMain set ListDescription = 'Bowel_Preparation_Quality' where ListDescription = 'Bowel_Preperation_Quality'
UPDATE ERS_Lists set ListDescription = 'Bowel_Preparation_Quality' where ListDescription = 'Bowel_Preperation_Quality'
GO

--End of Bowel Prep update


-- New column for Therapeutics

    IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'EndoRole' AND Object_ID = Object_ID(N'ERS_UpperGITherapeutics'))
    alter table ERS_UpperGITherapeutics add EndoRole tinyint
  GO

  IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'EndoRole' AND Object_ID = Object_ID(N'ERSAudit.ERS_UpperGITherapeutics_Audit'))
    alter table [ERSAudit].[ERS_UpperGITherapeutics_Audit] add EndoRole bit
  GO


  Exec DropIfExist 'trg_ERS_UpperGITherapeutics_Delete', 'TR'
  GO
  Create TRIGGER [dbo].[trg_ERS_UpperGITherapeutics_Delete] 
							ON [dbo].[ERS_UpperGITherapeutics] 
							AFTER DELETE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_UpperGITherapeutics_Audit] (Id, tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BalloonDilation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[OesophagealDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[DilatorScopePass], tbl.[OesoDilNilByMouth], tbl.[OesoDilNilByMouthHrs], tbl.[OesoDilXRay], tbl.[OesoDilXRayHrs], tbl.[OesoDilSoftDiet], tbl.[OesoDilSoftDietDays], tbl.[OesoDilWarmFluids], tbl.[OesoDilWarmFluidsHrs], tbl.[OesoDilMedicalReview], tbl.[OesoYAGNilByMouth], tbl.[OesoYAGNilByMouthHrs], tbl.[OesoYAGWarmFluids], tbl.[OesoYAGWarmFluidsHrs], tbl.[OesoYAGSoftDiet], tbl.[OesoYAGSoftDietDays], tbl.[OesoYAGMedicalReview], tbl.[Polypectomy], tbl.[PolypectomyRemoval], tbl.[PolypectomyRemovalType], tbl.[BandingPiles], tbl.[BandingNum], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[CorrectPEGPlacement], tbl.[PEGPlacementFailureReason], tbl.[GastrostomyPEGOutcome], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[FlangePosition], tbl.[AttachmentToWard], tbl.[GastrostomyRemoval], tbl.[PyloricDilatation], tbl.[PyloricLeadingToPerforation], tbl.[VaricealSclerotherapy], tbl.[VaricealSclerotherapyInjectionType], tbl.[VaricealSclerotherapyInjectionVol], tbl.[VaricealSclerotherapyInjectionNum], tbl.[VaricealBanding], tbl.[VaricealBandingNum], tbl.[VaricealClip], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[StentInsertionType], tbl.[StentInsertionLength], tbl.[StentInsertionDiameter], tbl.[StentInsertionDiameterUnits], tbl.[StentInsertionBatchNo], tbl.[CorrectStentPlacement], tbl.[StentPlacementFailureReason], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Sigmoidopexy], tbl.[SigmoidopexyQty], tbl.[SigmoidopexyMake], tbl.[SigmoidopexyFluids], tbl.[SigmoidopexyFluidsDays], tbl.[SigmoidopexyAntibiotics], tbl.[SigmoidopexyAntibioticsDays], tbl.[RFA], tbl.[RFAType], tbl.[RFATreatmentFrom], tbl.[RFATreatmentTo], tbl.[RFAEnergyDel], tbl.[RFANumSegTreated], tbl.[RFANumTimesSegTreated], tbl.[pHProbeInsert], tbl.[pHProbeInsertAt], tbl.[pHProbeInsertChk], tbl.[pHProbeInsertChkTopTo], tbl.[Haemospray], tbl.[Marking], tbl.[MarkingType], tbl.[MarkedQuantity], tbl.[Clip], tbl.[ClipNum], tbl.[EndoClot], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  LastActionId, ActionDateTime, ActionUserId, EndoRole)
							SELECT tbl.Id , tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BalloonDilation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[OesophagealDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[DilatorScopePass], tbl.[OesoDilNilByMouth], tbl.[OesoDilNilByMouthHrs], tbl.[OesoDilXRay], tbl.[OesoDilXRayHrs], tbl.[OesoDilSoftDiet], tbl.[OesoDilSoftDietDays], tbl.[OesoDilWarmFluids], tbl.[OesoDilWarmFluidsHrs], tbl.[OesoDilMedicalReview], tbl.[OesoYAGNilByMouth], tbl.[OesoYAGNilByMouthHrs], tbl.[OesoYAGWarmFluids], tbl.[OesoYAGWarmFluidsHrs], tbl.[OesoYAGSoftDiet], tbl.[OesoYAGSoftDietDays], tbl.[OesoYAGMedicalReview], tbl.[Polypectomy], tbl.[PolypectomyRemoval], tbl.[PolypectomyRemovalType], tbl.[BandingPiles], tbl.[BandingNum], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[CorrectPEGPlacement], tbl.[PEGPlacementFailureReason], tbl.[GastrostomyPEGOutcome], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[FlangePosition], tbl.[AttachmentToWard], tbl.[GastrostomyRemoval], tbl.[PyloricDilatation], tbl.[PyloricLeadingToPerforation], tbl.[VaricealSclerotherapy], tbl.[VaricealSclerotherapyInjectionType], tbl.[VaricealSclerotherapyInjectionVol], tbl.[VaricealSclerotherapyInjectionNum], tbl.[VaricealBanding], tbl.[VaricealBandingNum], tbl.[VaricealClip], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[StentInsertionType], tbl.[StentInsertionLength], tbl.[StentInsertionDiameter], tbl.[StentInsertionDiameterUnits], tbl.[StentInsertionBatchNo], tbl.[CorrectStentPlacement], tbl.[StentPlacementFailureReason], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Sigmoidopexy], tbl.[SigmoidopexyQty], tbl.[SigmoidopexyMake], tbl.[SigmoidopexyFluids], tbl.[SigmoidopexyFluidsDays], tbl.[SigmoidopexyAntibiotics], tbl.[SigmoidopexyAntibioticsDays], tbl.[RFA], tbl.[RFAType], tbl.[RFATreatmentFrom], tbl.[RFATreatmentTo], tbl.[RFAEnergyDel], tbl.[RFANumSegTreated], tbl.[RFANumTimesSegTreated], tbl.[pHProbeInsert], tbl.[pHProbeInsertAt], tbl.[pHProbeInsertChk], tbl.[pHProbeInsertChkTopTo], tbl.[Haemospray], tbl.[Marking], tbl.[MarkingType], tbl.[MarkedQuantity], tbl.[Clip], tbl.[ClipNum], tbl.[EndoClot], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  3, GETDATE(), tbl.WhoUpdatedId, tbl.EndoRole
							FROM deleted tbl
GO

Exec DropIfExist 'trg_ERS_UpperGITherapeutics_Insert', 'TR'
  GO
Create TRIGGER [dbo].[trg_ERS_UpperGITherapeutics_Insert] 
						ON [dbo].[ERS_UpperGITherapeutics] 
						AFTER INSERT
					AS 
						SET NOCOUNT ON; 
						INSERT INTO [ERSAudit].[ERS_UpperGITherapeutics_Audit] (Id, tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BalloonDilation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[OesophagealDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[DilatorScopePass], tbl.[OesoDilNilByMouth], tbl.[OesoDilNilByMouthHrs], tbl.[OesoDilXRay], tbl.[OesoDilXRayHrs], tbl.[OesoDilSoftDiet], tbl.[OesoDilSoftDietDays], tbl.[OesoDilWarmFluids], tbl.[OesoDilWarmFluidsHrs], tbl.[OesoDilMedicalReview], tbl.[OesoYAGNilByMouth], tbl.[OesoYAGNilByMouthHrs], tbl.[OesoYAGWarmFluids], tbl.[OesoYAGWarmFluidsHrs], tbl.[OesoYAGSoftDiet], tbl.[OesoYAGSoftDietDays], tbl.[OesoYAGMedicalReview], tbl.[Polypectomy], tbl.[PolypectomyRemoval], tbl.[PolypectomyRemovalType], tbl.[BandingPiles], tbl.[BandingNum], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[CorrectPEGPlacement], tbl.[PEGPlacementFailureReason], tbl.[GastrostomyPEGOutcome], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[FlangePosition], tbl.[AttachmentToWard], tbl.[GastrostomyRemoval], tbl.[PyloricDilatation], tbl.[PyloricLeadingToPerforation], tbl.[VaricealSclerotherapy], tbl.[VaricealSclerotherapyInjectionType], tbl.[VaricealSclerotherapyInjectionVol], tbl.[VaricealSclerotherapyInjectionNum], tbl.[VaricealBanding], tbl.[VaricealBandingNum], tbl.[VaricealClip], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[StentInsertionType], tbl.[StentInsertionLength], tbl.[StentInsertionDiameter], tbl.[StentInsertionDiameterUnits], tbl.[StentInsertionBatchNo], tbl.[CorrectStentPlacement], tbl.[StentPlacementFailureReason], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Sigmoidopexy], tbl.[SigmoidopexyQty], tbl.[SigmoidopexyMake], tbl.[SigmoidopexyFluids], tbl.[SigmoidopexyFluidsDays], tbl.[SigmoidopexyAntibiotics], tbl.[SigmoidopexyAntibioticsDays], tbl.[RFA], tbl.[RFAType], tbl.[RFATreatmentFrom], tbl.[RFATreatmentTo], tbl.[RFAEnergyDel], tbl.[RFANumSegTreated], tbl.[RFANumTimesSegTreated], tbl.[pHProbeInsert], tbl.[pHProbeInsertAt], tbl.[pHProbeInsertChk], tbl.[pHProbeInsertChkTopTo], tbl.[Haemospray], tbl.[Marking], tbl.[MarkingType], tbl.[MarkedQuantity], tbl.[Clip], tbl.[ClipNum], tbl.[EndoClot], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  LastActionId, ActionDateTime, ActionUserId, EndoRole)
						SELECT tbl.Id , tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BalloonDilation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[OesophagealDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[DilatorScopePass], tbl.[OesoDilNilByMouth], tbl.[OesoDilNilByMouthHrs], tbl.[OesoDilXRay], tbl.[OesoDilXRayHrs], tbl.[OesoDilSoftDiet], tbl.[OesoDilSoftDietDays], tbl.[OesoDilWarmFluids], tbl.[OesoDilWarmFluidsHrs], tbl.[OesoDilMedicalReview], tbl.[OesoYAGNilByMouth], tbl.[OesoYAGNilByMouthHrs], tbl.[OesoYAGWarmFluids], tbl.[OesoYAGWarmFluidsHrs], tbl.[OesoYAGSoftDiet], tbl.[OesoYAGSoftDietDays], tbl.[OesoYAGMedicalReview], tbl.[Polypectomy], tbl.[PolypectomyRemoval], tbl.[PolypectomyRemovalType], tbl.[BandingPiles], tbl.[BandingNum], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[CorrectPEGPlacement], tbl.[PEGPlacementFailureReason], tbl.[GastrostomyPEGOutcome], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[FlangePosition], tbl.[AttachmentToWard], tbl.[GastrostomyRemoval], tbl.[PyloricDilatation], tbl.[PyloricLeadingToPerforation], tbl.[VaricealSclerotherapy], tbl.[VaricealSclerotherapyInjectionType], tbl.[VaricealSclerotherapyInjectionVol], tbl.[VaricealSclerotherapyInjectionNum], tbl.[VaricealBanding], tbl.[VaricealBandingNum], tbl.[VaricealClip], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[StentInsertionType], tbl.[StentInsertionLength], tbl.[StentInsertionDiameter], tbl.[StentInsertionDiameterUnits], tbl.[StentInsertionBatchNo], tbl.[CorrectStentPlacement], tbl.[StentPlacementFailureReason], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Sigmoidopexy], tbl.[SigmoidopexyQty], tbl.[SigmoidopexyMake], tbl.[SigmoidopexyFluids], tbl.[SigmoidopexyFluidsDays], tbl.[SigmoidopexyAntibiotics], tbl.[SigmoidopexyAntibioticsDays], tbl.[RFA], tbl.[RFAType], tbl.[RFATreatmentFrom], tbl.[RFATreatmentTo], tbl.[RFAEnergyDel], tbl.[RFANumSegTreated], tbl.[RFANumTimesSegTreated], tbl.[pHProbeInsert], tbl.[pHProbeInsertAt], tbl.[pHProbeInsertChk], tbl.[pHProbeInsertChkTopTo], tbl.[Haemospray], tbl.[Marking], tbl.[MarkingType], tbl.[MarkedQuantity], tbl.[Clip], tbl.[ClipNum], tbl.[EndoClot], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  1, GETDATE(), tbl.WhoCreatedId, tbl.EndoRole
						FROM inserted tbl
GO


Exec DropIfExist 'trg_ERS_UpperGITherapeutics_Update', 'TR'
  GO
Create TRIGGER [dbo].[trg_ERS_UpperGITherapeutics_Update] 
								ON [dbo].[ERS_UpperGITherapeutics] 
								AFTER UPDATE
							AS 
								SET NOCOUNT ON; 
								IF NOT UPDATE(Summary)
								BEGIN
									INSERT INTO [ERSAudit].[ERS_UpperGITherapeutics_Audit] (Id, tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BalloonDilation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[OesophagealDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[DilatorScopePass], tbl.[OesoDilNilByMouth], tbl.[OesoDilNilByMouthHrs], tbl.[OesoDilXRay], tbl.[OesoDilXRayHrs], tbl.[OesoDilSoftDiet], tbl.[OesoDilSoftDietDays], tbl.[OesoDilWarmFluids], tbl.[OesoDilWarmFluidsHrs], tbl.[OesoDilMedicalReview], tbl.[OesoYAGNilByMouth], tbl.[OesoYAGNilByMouthHrs], tbl.[OesoYAGWarmFluids], tbl.[OesoYAGWarmFluidsHrs], tbl.[OesoYAGSoftDiet], tbl.[OesoYAGSoftDietDays], tbl.[OesoYAGMedicalReview], tbl.[Polypectomy], tbl.[PolypectomyRemoval], tbl.[PolypectomyRemovalType], tbl.[BandingPiles], tbl.[BandingNum], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[CorrectPEGPlacement], tbl.[PEGPlacementFailureReason], tbl.[GastrostomyPEGOutcome], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[FlangePosition], tbl.[AttachmentToWard], tbl.[GastrostomyRemoval], tbl.[PyloricDilatation], tbl.[PyloricLeadingToPerforation], tbl.[VaricealSclerotherapy], tbl.[VaricealSclerotherapyInjectionType], tbl.[VaricealSclerotherapyInjectionVol], tbl.[VaricealSclerotherapyInjectionNum], tbl.[VaricealBanding], tbl.[VaricealBandingNum], tbl.[VaricealClip], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[StentInsertionType], tbl.[StentInsertionLength], tbl.[StentInsertionDiameter], tbl.[StentInsertionDiameterUnits], tbl.[StentInsertionBatchNo], tbl.[CorrectStentPlacement], tbl.[StentPlacementFailureReason], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Sigmoidopexy], tbl.[SigmoidopexyQty], tbl.[SigmoidopexyMake], tbl.[SigmoidopexyFluids], tbl.[SigmoidopexyFluidsDays], tbl.[SigmoidopexyAntibiotics], tbl.[SigmoidopexyAntibioticsDays], tbl.[RFA], tbl.[RFAType], tbl.[RFATreatmentFrom], tbl.[RFATreatmentTo], tbl.[RFAEnergyDel], tbl.[RFANumSegTreated], tbl.[RFANumTimesSegTreated], tbl.[pHProbeInsert], tbl.[pHProbeInsertAt], tbl.[pHProbeInsertChk], tbl.[pHProbeInsertChkTopTo], tbl.[Haemospray], tbl.[Marking], tbl.[MarkingType], tbl.[MarkedQuantity], tbl.[Clip], tbl.[ClipNum], tbl.[EndoClot], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  LastActionId, ActionDateTime, ActionUserId, EndoRole)
									SELECT tbl.Id , tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BalloonDilation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[OesophagealDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[DilatorScopePass], tbl.[OesoDilNilByMouth], tbl.[OesoDilNilByMouthHrs], tbl.[OesoDilXRay], tbl.[OesoDilXRayHrs], tbl.[OesoDilSoftDiet], tbl.[OesoDilSoftDietDays], tbl.[OesoDilWarmFluids], tbl.[OesoDilWarmFluidsHrs], tbl.[OesoDilMedicalReview], tbl.[OesoYAGNilByMouth], tbl.[OesoYAGNilByMouthHrs], tbl.[OesoYAGWarmFluids], tbl.[OesoYAGWarmFluidsHrs], tbl.[OesoYAGSoftDiet], tbl.[OesoYAGSoftDietDays], tbl.[OesoYAGMedicalReview], tbl.[Polypectomy], tbl.[PolypectomyRemoval], tbl.[PolypectomyRemovalType], tbl.[BandingPiles], tbl.[BandingNum], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[CorrectPEGPlacement], tbl.[PEGPlacementFailureReason], tbl.[GastrostomyPEGOutcome], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[FlangePosition], tbl.[AttachmentToWard], tbl.[GastrostomyRemoval], tbl.[PyloricDilatation], tbl.[PyloricLeadingToPerforation], tbl.[VaricealSclerotherapy], tbl.[VaricealSclerotherapyInjectionType], tbl.[VaricealSclerotherapyInjectionVol], tbl.[VaricealSclerotherapyInjectionNum], tbl.[VaricealBanding], tbl.[VaricealBandingNum], tbl.[VaricealClip], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[StentInsertionType], tbl.[StentInsertionLength], tbl.[StentInsertionDiameter], tbl.[StentInsertionDiameterUnits], tbl.[StentInsertionBatchNo], tbl.[CorrectStentPlacement], tbl.[StentPlacementFailureReason], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Sigmoidopexy], tbl.[SigmoidopexyQty], tbl.[SigmoidopexyMake], tbl.[SigmoidopexyFluids], tbl.[SigmoidopexyFluidsDays], tbl.[SigmoidopexyAntibiotics], tbl.[SigmoidopexyAntibioticsDays], tbl.[RFA], tbl.[RFAType], tbl.[RFATreatmentFrom], tbl.[RFATreatmentTo], tbl.[RFAEnergyDel], tbl.[RFANumSegTreated], tbl.[RFANumTimesSegTreated], tbl.[pHProbeInsert], tbl.[pHProbeInsertAt], tbl.[pHProbeInsertChk], tbl.[pHProbeInsertChkTopTo], tbl.[Haemospray], tbl.[Marking], tbl.[MarkingType], tbl.[MarkedQuantity], tbl.[Clip], tbl.[ClipNum], tbl.[EndoClot], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  2, GETDATE(), i.WhoUpdatedId, tbl.EndoRole
									FROM deleted tbl INNER JOIN inserted i ON tbl.Id = i.Id
								END
GO

update t set EndoRole = p.Endo1Role 
from ERS_Procedures p
join ERS_Sites s on p.ProcedureId = s.ProcedureId
join ERS_UpperGITherapeutics t on s.SiteId = t.SiteId 
GO


    IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'EndoRole' AND Object_ID = Object_ID(N'ERS_ERCPTherapeutics'))
    alter table ERS_ERCPTherapeutics add EndoRole tinyint
  GO

  IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'EndoRole' AND Object_ID = Object_ID(N'ERSAudit.ERS_ERCPTherapeutics_Audit'))
    alter table [ERSAudit].[ERS_ERCPTherapeutics_Audit] add EndoRole bit
  GO


  Exec DropIfExist 'trg_ERS_ERCPTherapeutics_Delete', 'TR'
  GO
  Create TRIGGER [dbo].[trg_ERS_ERCPTherapeutics_Delete] 
			ON [dbo].[ERS_ERCPTherapeutics] 
				AFTER DELETE
			AS 
				SET NOCOUNT ON; 
				INSERT INTO [ERSAudit].[ERS_ERCPTherapeutics_Audit] (Id, tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[GastrostomyRemoval], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[AttachmentToWard], tbl.[PyloricDilatation], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[RadioactiveWirePlaced], tbl.[StentInsertionBatchNo], tbl.[StentDecompressedDuct], tbl.[CorrectStentPlacement], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Marking], tbl.[MarkingType], tbl.[Clip], tbl.[ClipNum], tbl.[Papillotomy], tbl.[Sphincterotome], tbl.[PapillotomyLength], tbl.[PapillotomyAcceptBalloonSize], tbl.[ReasonForPapillotomy], tbl.[PapillotomyBleeding], tbl.[SphincterDecompressed], tbl.[PanOrificeSphincterotomy], tbl.[StoneRemoval], tbl.[RemovalUsing], tbl.[ExtractionOutcome], tbl.[InadequateSphincterotomy], tbl.[StoneSize], tbl.[QuantityOfStones], tbl.[ImpactedStones], tbl.[OtherReason], tbl.[OtherReasonText], tbl.[StoneDecompressed], tbl.[StrictureDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[StrictureDecompressed], tbl.[EndoscopicCystPuncture], tbl.[CystPunctureDevice], tbl.[CystPunctureVia], tbl.[Cannulation], tbl.[Manometry], tbl.[Haemostasis], tbl.[NasopancreaticDrain], tbl.[RendezvousProcedure], tbl.[SnareExcision], tbl.[BalloonDilation], tbl.[BalloonDilatedTo], tbl.[BalloonDilatationUnits], tbl.[BalloonDilatorType], tbl.[BalloonTrawl], tbl.[BalloonTrawlDilatorType], tbl.[BalloonTrawlDilatorSize], tbl.[BalloonTrawlDilatorUnits], tbl.[BalloonDecompressed], tbl.[DiagCholangiogram], tbl.[DiagPancreatogram], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  LastActionId, ActionDateTime, ActionUserId, tbl.EndoRole)
				SELECT tbl.Id , tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[GastrostomyRemoval], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[AttachmentToWard], tbl.[PyloricDilatation], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[RadioactiveWirePlaced], tbl.[StentInsertionBatchNo], tbl.[StentDecompressedDuct], tbl.[CorrectStentPlacement], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Marking], tbl.[MarkingType], tbl.[Clip], tbl.[ClipNum], tbl.[Papillotomy], tbl.[Sphincterotome], tbl.[PapillotomyLength], tbl.[PapillotomyAcceptBalloonSize], tbl.[ReasonForPapillotomy], tbl.[PapillotomyBleeding], tbl.[SphincterDecompressed], tbl.[PanOrificeSphincterotomy], tbl.[StoneRemoval], tbl.[RemovalUsing], tbl.[ExtractionOutcome], tbl.[InadequateSphincterotomy], tbl.[StoneSize], tbl.[QuantityOfStones], tbl.[ImpactedStones], tbl.[OtherReason], tbl.[OtherReasonText], tbl.[StoneDecompressed], tbl.[StrictureDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[StrictureDecompressed], tbl.[EndoscopicCystPuncture], tbl.[CystPunctureDevice], tbl.[CystPunctureVia], tbl.[Cannulation], tbl.[Manometry], tbl.[Haemostasis], tbl.[NasopancreaticDrain], tbl.[RendezvousProcedure], tbl.[SnareExcision], tbl.[BalloonDilation], tbl.[BalloonDilatedTo], tbl.[BalloonDilatationUnits], tbl.[BalloonDilatorType], tbl.[BalloonTrawl], tbl.[BalloonTrawlDilatorType], tbl.[BalloonTrawlDilatorSize], tbl.[BalloonTrawlDilatorUnits], tbl.[BalloonDecompressed], tbl.[DiagCholangiogram], tbl.[DiagPancreatogram], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  3, GETDATE(), tbl.WhoUpdatedId, tbl.EndoRole
				FROM deleted tbl
GO

Exec DropIfExist 'trg_ERS_ERCPTherapeutics_Insert', 'TR'
  GO
Create TRIGGER [dbo].[trg_ERS_ERCPTherapeutics_Insert] 
				ON [dbo].[ERS_ERCPTherapeutics] 
				AFTER INSERT
			AS 
				SET NOCOUNT ON; 
				INSERT INTO [ERSAudit].[ERS_ERCPTherapeutics_Audit] (Id, tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[GastrostomyRemoval], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[AttachmentToWard], tbl.[PyloricDilatation], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[RadioactiveWirePlaced], tbl.[StentInsertionBatchNo], tbl.[StentDecompressedDuct], tbl.[CorrectStentPlacement], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Marking], tbl.[MarkingType], tbl.[Clip], tbl.[ClipNum], tbl.[Papillotomy], tbl.[Sphincterotome], tbl.[PapillotomyLength], tbl.[PapillotomyAcceptBalloonSize], tbl.[ReasonForPapillotomy], tbl.[PapillotomyBleeding], tbl.[SphincterDecompressed], tbl.[PanOrificeSphincterotomy], tbl.[StoneRemoval], tbl.[RemovalUsing], tbl.[ExtractionOutcome], tbl.[InadequateSphincterotomy], tbl.[StoneSize], tbl.[QuantityOfStones], tbl.[ImpactedStones], tbl.[OtherReason], tbl.[OtherReasonText], tbl.[StoneDecompressed], tbl.[StrictureDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[StrictureDecompressed], tbl.[EndoscopicCystPuncture], tbl.[CystPunctureDevice], tbl.[CystPunctureVia], tbl.[Cannulation], tbl.[Manometry], tbl.[Haemostasis], tbl.[NasopancreaticDrain], tbl.[RendezvousProcedure], tbl.[SnareExcision], tbl.[BalloonDilation], tbl.[BalloonDilatedTo], tbl.[BalloonDilatationUnits], tbl.[BalloonDilatorType], tbl.[BalloonTrawl], tbl.[BalloonTrawlDilatorType], tbl.[BalloonTrawlDilatorSize], tbl.[BalloonTrawlDilatorUnits], tbl.[BalloonDecompressed], tbl.[DiagCholangiogram], tbl.[DiagPancreatogram], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  LastActionId, ActionDateTime, ActionUserId, tbl.EndoRole)
				SELECT tbl.Id , tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[GastrostomyRemoval], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[AttachmentToWard], tbl.[PyloricDilatation], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[RadioactiveWirePlaced], tbl.[StentInsertionBatchNo], tbl.[StentDecompressedDuct], tbl.[CorrectStentPlacement], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Marking], tbl.[MarkingType], tbl.[Clip], tbl.[ClipNum], tbl.[Papillotomy], tbl.[Sphincterotome], tbl.[PapillotomyLength], tbl.[PapillotomyAcceptBalloonSize], tbl.[ReasonForPapillotomy], tbl.[PapillotomyBleeding], tbl.[SphincterDecompressed], tbl.[PanOrificeSphincterotomy], tbl.[StoneRemoval], tbl.[RemovalUsing], tbl.[ExtractionOutcome], tbl.[InadequateSphincterotomy], tbl.[StoneSize], tbl.[QuantityOfStones], tbl.[ImpactedStones], tbl.[OtherReason], tbl.[OtherReasonText], tbl.[StoneDecompressed], tbl.[StrictureDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[StrictureDecompressed], tbl.[EndoscopicCystPuncture], tbl.[CystPunctureDevice], tbl.[CystPunctureVia], tbl.[Cannulation], tbl.[Manometry], tbl.[Haemostasis], tbl.[NasopancreaticDrain], tbl.[RendezvousProcedure], tbl.[SnareExcision], tbl.[BalloonDilation], tbl.[BalloonDilatedTo], tbl.[BalloonDilatationUnits], tbl.[BalloonDilatorType], tbl.[BalloonTrawl], tbl.[BalloonTrawlDilatorType], tbl.[BalloonTrawlDilatorSize], tbl.[BalloonTrawlDilatorUnits], tbl.[BalloonDecompressed], tbl.[DiagCholangiogram], tbl.[DiagPancreatogram], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  1, GETDATE(), tbl.WhoCreatedId, tbl.EndoRole
				FROM inserted tbl
GO


Exec DropIfExist 'trg_ERS_ERCPTherapeutics_Update', 'TR'
  GO
Create TRIGGER [dbo].[trg_ERS_ERCPTherapeutics_Update] 
				ON [dbo].[ERS_ERCPTherapeutics] 
				AFTER UPDATE
			AS 
				SET NOCOUNT ON; 
				IF NOT UPDATE(Summary)
				BEGIN
					INSERT INTO [ERSAudit].[ERS_ERCPTherapeutics_Audit] (Id, tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[GastrostomyRemoval], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[AttachmentToWard], tbl.[PyloricDilatation], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[RadioactiveWirePlaced], tbl.[StentInsertionBatchNo], tbl.[StentDecompressedDuct], tbl.[CorrectStentPlacement], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Marking], tbl.[MarkingType], tbl.[Clip], tbl.[ClipNum], tbl.[Papillotomy], tbl.[Sphincterotome], tbl.[PapillotomyLength], tbl.[PapillotomyAcceptBalloonSize], tbl.[ReasonForPapillotomy], tbl.[PapillotomyBleeding], tbl.[SphincterDecompressed], tbl.[PanOrificeSphincterotomy], tbl.[StoneRemoval], tbl.[RemovalUsing], tbl.[ExtractionOutcome], tbl.[InadequateSphincterotomy], tbl.[StoneSize], tbl.[QuantityOfStones], tbl.[ImpactedStones], tbl.[OtherReason], tbl.[OtherReasonText], tbl.[StoneDecompressed], tbl.[StrictureDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[StrictureDecompressed], tbl.[EndoscopicCystPuncture], tbl.[CystPunctureDevice], tbl.[CystPunctureVia], tbl.[Cannulation], tbl.[Manometry], tbl.[Haemostasis], tbl.[NasopancreaticDrain], tbl.[RendezvousProcedure], tbl.[SnareExcision], tbl.[BalloonDilation], tbl.[BalloonDilatedTo], tbl.[BalloonDilatationUnits], tbl.[BalloonDilatorType], tbl.[BalloonTrawl], tbl.[BalloonTrawlDilatorType], tbl.[BalloonTrawlDilatorSize], tbl.[BalloonTrawlDilatorUnits], tbl.[BalloonDecompressed], tbl.[DiagCholangiogram], tbl.[DiagPancreatogram], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  LastActionId, ActionDateTime, ActionUserId, tbl.EndoRole)
					SELECT tbl.Id , tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[GastrostomyRemoval], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[AttachmentToWard], tbl.[PyloricDilatation], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[RadioactiveWirePlaced], tbl.[StentInsertionBatchNo], tbl.[StentDecompressedDuct], tbl.[CorrectStentPlacement], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Marking], tbl.[MarkingType], tbl.[Clip], tbl.[ClipNum], tbl.[Papillotomy], tbl.[Sphincterotome], tbl.[PapillotomyLength], tbl.[PapillotomyAcceptBalloonSize], tbl.[ReasonForPapillotomy], tbl.[PapillotomyBleeding], tbl.[SphincterDecompressed], tbl.[PanOrificeSphincterotomy], tbl.[StoneRemoval], tbl.[RemovalUsing], tbl.[ExtractionOutcome], tbl.[InadequateSphincterotomy], tbl.[StoneSize], tbl.[QuantityOfStones], tbl.[ImpactedStones], tbl.[OtherReason], tbl.[OtherReasonText], tbl.[StoneDecompressed], tbl.[StrictureDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[StrictureDecompressed], tbl.[EndoscopicCystPuncture], tbl.[CystPunctureDevice], tbl.[CystPunctureVia], tbl.[Cannulation], tbl.[Manometry], tbl.[Haemostasis], tbl.[NasopancreaticDrain], tbl.[RendezvousProcedure], tbl.[SnareExcision], tbl.[BalloonDilation], tbl.[BalloonDilatedTo], tbl.[BalloonDilatationUnits], tbl.[BalloonDilatorType], tbl.[BalloonTrawl], tbl.[BalloonTrawlDilatorType], tbl.[BalloonTrawlDilatorSize], tbl.[BalloonTrawlDilatorUnits], tbl.[BalloonDecompressed], tbl.[DiagCholangiogram], tbl.[DiagPancreatogram], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  2, GETDATE(), i.WhoUpdatedId, tbl.EndoRole
					FROM deleted tbl INNER JOIN inserted i ON tbl.Id = i.Id		
				END
GO

update t set EndoRole = p.Endo1Role 
from ERS_Procedures p
join ERS_Sites s on p.ProcedureId = s.ProcedureId
join ERS_ERCPTherapeutics t on s.SiteId = t.SiteId 
GO

-- End of new column for Therapeutics
-- Changes to the Therapeutic summary
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
			--WHERE ER.CarriedOutRole = 1; --## 1 is ER
		--END	--## Selecting from Combine

	--ELSE
	--	--## 2) ELSE - THere is only ER present.. So- no need to Combine them...
	--	BEGIN
	--		--PRINT 'ONLY ER Exist- at ERS_UpperGITherapeutics';
	--		SELECT  		
	--			@None = [None],
	--			@YAGLaser = [YAGLaser],
	--			@YAGLaserWatts =[YAGLaserWatts] ,
	--			@YAGLaserPulses  = [YAGLaserPulses],
	--			@YAGLaserSecs = [YAGLaserSecs],
	--			@YAGLaserKJ = [YAGLaserKJ],
	--			@ArgonBeamDiathermy = [ArgonBeamDiathermy],
	--			@ArgonBeamDiathermyWatts  = [ArgonBeamDiathermyWatts],
	--			@ArgonBeamDiathermyPulses = [ArgonBeamDiathermyPulses],
	--			@ArgonBeamDiathermySecs= [ArgonBeamDiathermySecs],
	--			@ArgonBeamDiathermyKJ = [ArgonBeamDiathermyKJ],
	--			@BandLigation = [BandLigation],
	--			@BotoxInjection = [BotoxInjection],
	--			@EndoloopPlacement = [EndoloopPlacement],
	--			@HeatProbe = [HeatProbe],
	--			@BicapElectro = [BicapElectro],
	--			@Diathermy = [Diathermy],
	--			@ForeignBody = [ForeignBody],
	--			@HotBiopsy = [HotBiopsy],
	--			@Injection  = [Injection],
	--			@InjectionType = [InjectionType],
	--			@InjectionVolume = [InjectionVolume],
	--			@InjectionNumber = [InjectionNumber],
	--			@OesophagealDilatation = [OesophagealDilatation],
	--			@DilatedTo = [DilatedTo],
	--			@DilatationUnits = [DilatationUnits],
	--			@DilatorType = [DilatorType],
	--			@DilatorScopePass = [DilatorScopePass],
	--			@OesoDilNilByMouth = [OesoDilNilByMouth],
	--			@OesoDilNilByMouthHrs = [OesoDilNilByMouthHrs],
	--			@OesoDilXRay = [OesoDilXRay],
	--			@OesoDilXRayHrs = [OesoDilXRayHrs],
	--			@OesoDilSoftDiet = [OesoDilSoftDiet],
	--			@OesoDilSoftDietDays =[OesoDilSoftDietDays] ,
	--			@OesoDilWarmFluids = [OesoDilWarmFluids],
	--			@OesoDilWarmFluidsHrs = [OesoDilWarmFluidsHrs],
	--			@OesoDilMedicalReview = [OesoDilMedicalReview],
	--			@OesoYAGNilByMouth = [OesoYAGNilByMouth],
	--			@OesoYAGNilByMouthHrs = [OesoYAGNilByMouthHrs],
	--			@OesoYAGWarmFluids = [OesoYAGWarmFluids],
	--			@OesoYAGWarmFluidsHrs = [OesoYAGWarmFluidsHrs],
	--			@OesoYAGSoftDiet = [OesoYAGSoftDiet],
	--			@OesoYAGSoftDietDays  = [OesoYAGSoftDietDays],
	--			@OesoYAGMedicalReview  = [OesoYAGMedicalReview],
	--			@Polypectomy = [Polypectomy],
	--			@PolypectomyRemoval = [PolypectomyRemoval],
	--			@PolypectomyRemovalType = [PolypectomyRemovalType],
	--			@BandingPiles = BandingPiles,
	--			@BandingNum = BandingNum,
	--			@GastrostomyInsertion = [GastrostomyInsertion],
	--			@GastrostomyInsertionSize = [GastrostomyInsertionSize],
	--			@GastrostomyInsertionUnits = [GastrostomyInsertionUnits],
	--			@GastrostomyInsertionType = [GastrostomyInsertionType],
	--			@GastrostomyInsertionBatchNo = [GastrostomyInsertionBatchNo],
	--			@CorrectPEGPlacement = [CorrectPEGPlacement],
	--			@PEGPlacementFailureReason = [PEGPlacementFailureReason],
	--			@NilByMouth = [NilByMouth],
	--			@NilByMouthHrs = [NilByMouthHrs],
	--			@NilByProc = [NilByProc],
	--			@NilByProcHrs = [NilByProcHrs],
	--			@FlangePosition = [FlangePosition],
	--			@AttachmentToWard = [AttachmentToWard],
	--			@GastrostomyRemoval = [GastrostomyRemoval],
	--			@PyloricDilatation = [PyloricDilatation],
	--			@VaricealSclerotherapy = [VaricealSclerotherapy],
	--			@VaricealSclerotherapyInjectionType = [VaricealSclerotherapyInjectionType],
	--			@VaricealSclerotherapyInjectionVol  = [VaricealSclerotherapyInjectionVol],
	--			@VaricealSclerotherapyInjectionNum  = [VaricealSclerotherapyInjectionNum],
	--			@VaricealBanding  = [VaricealBanding],
	--			@VaricealBandingNum = [VaricealBandingNum],
	--			@VaricealClip = [VaricealClip],
	--			@StentInsertion  = [StentInsertion],
	--			@StentInsertionQty = [StentInsertionQty],
	--			@StentInsertionType = [StentInsertionType],
	--			@StentInsertionLength  = [StentInsertionLength],
	--			@StentInsertionDiameter = [StentInsertionDiameter],
	--			@StentInsertionDiameterUnits = [StentInsertionDiameterUnits],
	--			@StentInsertionBatchNo  = ISNULL([StentInsertionBatchNo],''),
	--			@CorrectStentPlacement  = [CorrectStentPlacement],
	--			@StentPlacementFailureReason = [StentPlacementFailureReason],
	--			@StentRemoval  = [StentRemoval],
	--			@StentRemovalTechnique = [StentRemovalTechnique],
	--			@EMR  = [EMR],
	--			@EMRType = [EMRType],
	--			@EMRFluid = [EMRFluid],
	--			@EMRFluidVolume = [EMRFluidVolume],
	--			@RFA = [RFA],
	--			@RFAType = [RFAType],
	--			@RFATreatmentFrom =[RFATreatmentFrom] ,
	--			@RFATreatmentTo = [RFATreatmentTo],
	--			@RFAEnergyDel = [RFAEnergyDel],
	--			@RFANumSegTreated = [RFANumSegTreated],
	--			@RFANumTimesSegTreated = [RFANumTimesSegTreated],
	--			@pHProbeInsert = [pHProbeInsert],
	--			@pHProbeInsertAt  = [pHProbeInsertAt],
	--			@pHProbeInsertChk = [pHProbeInsertChk],
	--			@pHProbeInsertChkTopTo = [pHProbeInsertChkTopTo],
	--			@Haemospray = [Haemospray],
	--			@Marking = [Marking],
	--			@MarkingType = [MarkingType],
	--			@Clip = [Clip],
	--			@ClipNum = [ClipNum],
	--			@Other = [Other],
	--			@EUSProcType =[EUSProcType] 
	--		FROM dbo.[ERS_UpperGITherapeutics]
	--		WHERE Id = @TherapeuticId;
	--	END --## Selecting from OGD Therap- Only ER Row...

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
				IF @GastrostomyInsertionBatchNo <> null AND @GastrostomyInsertionBatchNo <> ''  SET @Details = @Details + ' batch ' + @GastrostomyInsertionBatchNo
				
				IF @Details<>'' SET @msg = @msg + ': ' + @Details
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
				IF @Summary <> '' SET @Summary = @Summary + ', warm fluids' ELSE SET @Summary = 'Warm fluids'
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
				IF @Summary <> '' SET @Summary = @Summary + ', warm fluids' ELSE SET @Summary = 'Warm fluids'
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
	--ELSE
	--	--## 2) ELSE - THere is only ER present.. So- no need to Combine them...
	--	BEGIN
	--		--PRINT 'ONLY ER Exist- at ERS_UpperGITherapeutics';
	--		SELECT
	--			@None				=	[None],	
	--			@YAGLaser			=	YAGLaser,	
	--			@YAGLaserWatts		=	YAGLaserWatts,	
	--			@YAGLaserPulses		=	YAGLaserPulses,	
	--			@YAGLaserSecs		=	YAGLaserSecs,	
	--			@YAGLaserKJ			=	YAGLaserKJ,	
	--			@ArgonBeamDiathermy	=	ArgonBeamDiathermy,	
	--			@ArgonBeamDiathermyWatts		=	ArgonBeamDiathermyWatts,	
	--			@ArgonBeamDiathermyPulses		=	ArgonBeamDiathermyPulses,	
	--			@ArgonBeamDiathermySecs			=	ArgonBeamDiathermySecs,	
	--			@ArgonBeamDiathermyKJ			=	ArgonBeamDiathermyKJ,	
	--			@HeatProbe			=	HeatProbe,	
	--			@BicapElectro		=	BicapElectro,	
	--			@Diathermy			=	Diathermy,	
	--			@HotBiopsy			=	HotBiopsy,	
	--			@Injection			=	Injection,	
	--			@InjectionType		=	InjectionType,	
	--			@InjectionVolume	=	InjectionVolume,	
	--			@InjectionNumber	=	InjectionNumber,	
	--			@GastrostomyInsertion			=	GastrostomyInsertion,	
	--			@GastrostomyInsertionSize		=	GastrostomyInsertionSize,	
	--			@GastrostomyInsertionUnits		=	GastrostomyInsertionUnits,	
	--			@GastrostomyInsertionType		=	GastrostomyInsertionType,	
	--			@GastrostomyInsertionBatchNo	=	ISNULL(GastrostomyInsertionBatchNo,''),	
	--			@NilByMouth			=	NilByMouth,	
	--			@NilByMouthHrs		=	NilByMouthHrs,	
	--			@NilByProc			=	NilByProc,	
	--			@NilByProcHrs		=	NilByProcHrs,	
	--			@AttachmentToWard	=	AttachmentToWard,	
	--			@PyloricDilatation	=	PyloricDilatation,	
	--			@StentInsertion		=	StentInsertion,	
	--			@StentInsertionQty	=	StentInsertionQty,	
	--			@RadioactiveWirePlaced			=	RadioactiveWirePlaced,	
	--			@StentInsertionBatchNo			=	ISNULL(StentInsertionBatchNo,''),
	--			@StentRemoval					=	StentRemoval,	
	--			@StentRemovalTechnique			=	StentRemovalTechnique,	
	--			@EMR				=	EMR,	
	--			@EMRType			=	EMRType,	
	--			@EMRFluid			=	EMRFluid,	
	--			@EMRFluidVolume		=	EMRFluidVolume,	
	--			@Marking			=	Marking,	
	--			@MarkingType		=	MarkingType,	
	--			@Clip				=	Clip,	
	--			@ClipNum			=	ClipNum,	
	--			@Papillotomy		=	Papillotomy,	
	--			@Sphincterotome		=	Sphincterotome,	
	--			@PapillotomyLength	=	PapillotomyLength,	
	--			@PapillotomyAcceptBalloonSize	=	PapillotomyAcceptBalloonSize,	
	--			@ReasonForPapillotomy		=	ReasonForPapillotomy,	
	--			@PapillotomyBleeding		=	PapillotomyBleeding,	
	--			@SphincterDecompressed		=	SphincterDecompressed,	
	--			@PanOrificeSphincterotomy	=	PanOrificeSphincterotomy,	
	--			@StoneRemoval				=	StoneRemoval,	
	--			@RemovalUsing				=	RemovalUsing,	
	--			@ExtractionOutcome			=	ExtractionOutcome,	
	--			@InadequateSphincterotomy	=	InadequateSphincterotomy,	
	--			@StoneSize			=	StoneSize,	
	--			@QuantityOfStones	=	QuantityOfStones,	
	--			@ImpactedStones		=	ImpactedStones,	
	--			@OtherReason		=	OtherReason,	
	--			@OtherReasonText	=	OtherReasonText,	
	--			@StoneDecompressed	=	StoneDecompressed,	
	--			@StrictureDilatation=	StrictureDilatation,	
	--			@DilatedTo			=	DilatedTo,	
	--			@DilatationUnits	=	DilatationUnits,	
	--			@DilatorType		=	DilatorType,	
	--			@EndoscopicCystPuncture	=	EndoscopicCystPuncture,	
	--			@CystPunctureDevice		=	CystPunctureDevice,	
	--			@CystPunctureVia		=	CystPunctureVia,	
	--			@Cannulation			=	Cannulation,	
	--			@Manometry				=	Manometry,	
	--			@Haemostasis			=	Haemostasis,	
	--			@NasopancreaticDrain	=	NasopancreaticDrain,	
	--			@RendezvousProcedure	=	RendezvousProcedure,	
	--			@SnareExcision			=	SnareExcision,	
	--			@BalloonDilation		=	BalloonDilation,	
	--			@BalloonDilatedTo		=	BalloonDilatedTo,	
	--			@BalloonDilatationUnits	=	BalloonDilatationUnits,	
	--			@BalloonDilatorType		=	BalloonDilatorType,	
	--			@BalloonTrawl			=	BalloonTrawl,	
	--			@BalloonTrawlDilatorType	=	BalloonTrawlDilatorType,	
	--			@BalloonTrawlDilatorSize	=	BalloonTrawlDilatorSize,	
	--			@BalloonTrawlDilatorUnits	=	BalloonTrawlDilatorUnits,	
	--			@BalloonDecompressed		=	BalloonDecompressed,	
	--			@DiagCholangiogram			=	DiagCholangiogram,	
	--			@DiagPancreatogram			=	DiagPancreatogram,	
	--			@EndoscopistRole			=	CarriedOutRole,	
	--			@Other						=	Other,	
	--			@EUSProcType				=	EUSProcType
	--		FROM dbo.[ERS_ERCPTherapeutics]
 -- 		   WHERE Id= @TherapeuticId
	--	END --## Selecting from ERCP Therap- Only ER Row...						
	
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

			IF @DilatedTo > 0 
			BEGIN
				SET @Details = @Details + ' dilated to ' + cast(@DilatedTo as varchar(50)) + ' ' + 
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

-----------------------------------------------------------------------------------------------------------
GO
-- End of Changes to the Therapeutic summary


if exists (Select 1 from sysobjects where Name = 'ERS_IndicationTypes' and type = 'U')
	drop table dbo.ERS_IndicationTypes
GO

CREATE TABLE [dbo].[ERS_IndicationTypes](
	[Id] [int] IDENTITY(0,1) NOT NULL,
	[Indication] [varchar](128) NOT NULL,
	[NedName] [varchar](128) NULL,
	[Category] [varchar](128) NULL,
	[WhoUpdatedId] [int] NULL,
	[WhoCreatedId] [int] NULL,
	[WhenCreated] [datetime] NULL,
	[WhenUpdated] [datetime] NULL,
 CONSTRAINT [ERS_IndicationsTypes.PK.IndicationId] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ERS_IndicationTypes] ADD  DEFAULT ((0)) FOR [WhoCreatedId]
GO

ALTER TABLE [dbo].[ERS_IndicationTypes] ADD  DEFAULT (getdate()) FOR [WhenCreated]
GO

insert into ERS_IndicationTypes (Indication, NedName) values
('Abdominal mass ', 'Abdominal mass')
,('Abdominal pain ', 'Abdominal pain')
,('Abnormal enzymes ', 'Abnormal liver enzymes')
,('Abnormal sigmoidoscopy ', 'Abnormal sigmoidoscopy')
,('Abnormal barium enema', 'Abnormality on CT / barium')
,('Acute pancreatitis', 'Acute pancreatitis')
,('ampullary mass ', 'Ampullary mass')
,('Anaemia ', 'Anaemia')
,('Barrett''s oesophagus ', 'Barretts oesophagus')
,('bowel cancer screening programme ', 'BCSP')
,('Bile duct injury ', 'Bile duct injury')
,('Biliary leak ', 'Bile duct leak')
,('Cholangitis ', 'Cholangitis')
,('Altered bowel habit - chronic alternating constipation/diarrhoea', 'Chronic alternating diarrhoea / constipation')
,('Chronic pancreatisis ', 'Chronic pancreatitis')
,('Cancer', 'Colorectal cancer - follow up')
,('Altered bowel habit - acute constipation', 'Constipation - acute')
,('Altered bowel habit - chronic constipation', 'Constipation - chronic')
,('Altered bowel habit - defaecation dsorder', 'Defaecation disorder')
,('Diarrhoea ', 'Diarrhoea')
,('Altered bowel habit - acute diarrhoea', 'Diarrhoea - acute')
,('Altered bowel habit - chronic diarrhoea', 'Diarrhoea - chronic')
,('', 'Diarrhoea - chronic with blood')
,('Dyspepsia ', 'Dyspepsia')
,('Dysphagia ', 'Dysphagia')
,('', 'FOB +''ve')
,('Ulcer healing ', 'Follow up of gastric ulcer')
,('gall bladder mass', 'Gallbladder mass')
,('gall bladder polyp ', 'Gallbladder polyp')
,('Haematemesis ', 'Haematemesis')
,('Reflux symptoms ', 'Heartburn / reflux')
,('hepatic mass ', 'Hepatobiliary mass')
,('', 'IBD assessment / surveillance')
,('Jaundice ', 'Jaundice')
,('Melaena ', 'Melaena')
,('Nausea and/or vomiting ', 'Nausea / vomiting')
,('Odynophagia ', 'Odynophagia')
,('Other', 'Other')
,('pancreatic mass ', 'Pancreatic mass')
,('Pancreatic pseudocyst ', 'Pancreatic pseudocyst')
,('Pancreatobiliary pain ', 'Pancreatobiliary pain')
,('Papillary dysfunction ', 'Papillary dysfunction')
,('', 'PEG change')
,('PEG replacement ', 'PEG placement')
,('PEG removal ', 'PEG removal')
,('Polyposis syndrome', 'Polyposis syndrome')
,('Positive TTG / EMA ', 'Positive TTG / EMA')
,('Rectal Bleeding - Altered Blood [NED]', 'PR bleeding - altered blood')
,('Rectal Bleeding - Anorctal bleeding [NED]', 'PR bleeding - anorectal')
,('Pre-laparoscopic cholecystectomy ', 'Pre lap choledocholithiasis')
,('Polyp/Tumour Assessment ', 'Previous / known polyps')
,('Primary sclerosing cholangitis ', 'Primary sclerosing cholangitis')
,('Purulent cholangitis ', 'Purulent cholangitis')
,('Stent occlusion ', 'Stent dysfunction')
,('Stent insertion ', 'Stent placement')
,('Stent removal', 'Stent removal')
,('Stent replacement ', 'Stent change')
,('', 'Tumour assessment')
,('Oesophageal varices', 'Varices surveillance / screening')
,(' Weight loss  ', 'Weight loss')

GO
--------------------------------------------------------------------------------------------------------------
  IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('DF_ERS_DiagnosesMatrix_Disabled'))
    alter table ERS_DiagnosesMatrix
    drop constraint DF_ERS_DiagnosesMatrix_Disabled
  GO

  IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('DF_ERS_DiagnosesMatrix_Visible'))
    alter table ERS_DiagnosesMatrix
    drop constraint DF_ERS_DiagnosesMatrix_Visible
  GO

  IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'NED_Include' AND Object_ID = Object_ID(N'ERS_DiagnosesMatrix'))
    alter table ERS_DiagnosesMatrix add NED_Include bit
  GO

  IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'NED_Include' AND Object_ID = Object_ID(N'ERSAudit.ERS_DiagnosesMatrix_Audit'))
    alter table [ERSAudit].[ERS_DiagnosesMatrix_Audit] add NED_Include bit
  GO

  Exec DropIfExist 'trg_ERS_DiagnosesMatrix_Insert', 'TR'
  GO
  Create TRIGGER [dbo].[trg_ERS_DiagnosesMatrix_Insert] 
		ON [dbo].[ERS_DiagnosesMatrix] 
		AFTER INSERT
	AS 
		SET NOCOUNT ON; 
		INSERT INTO [ERSAudit].[ERS_DiagnosesMatrix_Audit] (DiagnosesMatrixID, tbl.[DisplayName], tbl.[NED_Name], tbl.[EndoCode], tbl.[ProcedureTypeID], tbl.[Section], tbl.[OrderByNumber], tbl.[Code],  LastActionId, ActionDateTime, ActionUserId, NED_Include)
		SELECT tbl.DiagnosesMatrixID , tbl.[DisplayName], tbl.[NED_Name], tbl.[EndoCode], tbl.[ProcedureTypeID], tbl.[Section], tbl.[OrderByNumber], tbl.[Code],  1, GETDATE(), tbl.WhoCreatedId, NED_Include
		FROM inserted tbl
  GO

  Exec DropIfExist 'trg_ERS_DiagnosesMatrix_Delete', 'TR'
  GO
  Create TRIGGER [dbo].[trg_ERS_DiagnosesMatrix_Delete] 
		ON [dbo].[ERS_DiagnosesMatrix] 
		AFTER DELETE
	AS 
		SET NOCOUNT ON; 
		INSERT INTO [ERSAudit].[ERS_DiagnosesMatrix_Audit] (DiagnosesMatrixID, tbl.[DisplayName], tbl.[NED_Name], tbl.[EndoCode], tbl.[ProcedureTypeID], tbl.[Section], tbl.[OrderByNumber], tbl.[Code],  LastActionId, ActionDateTime, ActionUserId, NED_Include)
		SELECT tbl.DiagnosesMatrixID , tbl.[DisplayName], tbl.[NED_Name], tbl.[EndoCode], tbl.[ProcedureTypeID], tbl.[Section], tbl.[OrderByNumber], tbl.[Code],  3, GETDATE(), tbl.WhoUpdatedId, NED_Include
		FROM deleted tbl
  GO

  Exec DropIfExist 'trg_ERS_DiagnosesMatrix_Update', 'TR'
  GO
  Create TRIGGER [dbo].[trg_ERS_DiagnosesMatrix_Update] 
		ON [dbo].[ERS_DiagnosesMatrix] 
		AFTER UPDATE
	AS 
		SET NOCOUNT ON; 
		INSERT INTO [ERSAudit].[ERS_DiagnosesMatrix_Audit] (DiagnosesMatrixID, tbl.[DisplayName], tbl.[NED_Name], tbl.[EndoCode], tbl.[ProcedureTypeID], tbl.[Section], tbl.[OrderByNumber], tbl.[Code],  LastActionId, ActionDateTime, ActionUserId, NED_Include)
		SELECT tbl.DiagnosesMatrixID , tbl.[DisplayName], tbl.[NED_Name], tbl.[EndoCode], tbl.[ProcedureTypeID], tbl.[Section], tbl.[OrderByNumber], tbl.[Code],  2, GETDATE(), i.WhoUpdatedId, tbl.NED_Include
		FROM deleted tbl INNER JOIN inserted i ON tbl.DiagnosesMatrixID = i.DiagnosesMatrixID
  GO

  IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'Disabled' AND Object_ID = Object_ID(N'ERS_DiagnosesMatrix'))
    alter table ERS_DiagnosesMatrix drop column [Disabled]
  GO

  IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'Visible' AND Object_ID = Object_ID(N'ERS_DiagnosesMatrix'))
    alter table ERS_DiagnosesMatrix drop column Visible
  GO

  IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'Disabled' AND Object_ID = Object_ID(N'ERSAudit.ERS_DiagnosesMatrix_Audit'))
  alter table [ERSAudit].[ERS_DiagnosesMatrix_Audit] drop column [Disabled]
  GO

  IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'Visible' AND Object_ID = Object_ID(N'ERSAudit.ERS_DiagnosesMatrix_Audit'))
  alter table [ERSAudit].[ERS_DiagnosesMatrix_Audit] drop column Visible
  GO

  update ERS_DiagnosesMatrix set NED_Include = 1 where NED_Name is not null and NED_Include is null

  update ERS_DiagnosesMatrix set NED_Include = 1 where ProcedureTypeID = 1 and NED_Include is null
  update ERS_DiagnosesMatrix set NED_Include = 1 where ProcedureTypeID = 2 and NED_Include is null and Code in ('D192P2', 'D193P2', 'D105P2', 'D110P2', 'D110P2', 'D52P2', 
																												'D53P2', 'D54P2', 'D55P2', 'D58P2', 'D59P2', 'D60P2', 'D64P2', 
																												'D275P2', 'D280P2', 'D285P2', 'D290P2', 'D295P2', 'D300P2', 'D305P2', 
																												'D315P2', 'D320P2', 'D325P2', 'D340P2', 'D345P2', 'D355P2', 'D200P2', 
																												'D220P2', 'D225P2', 'D230P2', 'D235P2', 'D240P2', 'D260P2', 'D35P2', 
																												'D37P2', 'D39P2', 'D130P2',
																												'D364P2','D365P2','D276P2','D366P2','D367P2','D370P2','D371P2',
																												'D373P2','D374P2','D375P2','D376P2','D379P2','D380P2','D381P2',
																												'D382P2','D372P2','D112P1','D111P2','D113P2','D114P2','D383P2',
																												'D384P2','D385P2','D386P2','D95P2','D112P1')
  
  update ERS_DiagnosesMatrix set NED_Include = 1 where ProcedureTypeID = 3 and NED_Include is null and Code in ('D87P3', 'D88P3', 'D89P3', 'D90P3', 'D91P3', 'D93P3', 'D95P3')
  update ERS_DiagnosesMatrix set NED_Include = 1 where ProcedureTypeID = 4 and NED_Include is null and Code in ('S86P3', 'S87P3', 'S88P3', 'S89P3', 'S90P3', 'S91P3', 'S92P3', 
																												'S93P3', 'S94P3', 'S95P3', 'S96P3')

  update ERS_DiagnosesMatrix set NED_Include = 1 where Section = 'Colon'and NED_Include is null and ProcedureTypeID in (1, 2, 3, 4, 13)  
GO 

-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'fnNED_ProcedureExtent', 'F';
GO
-----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[fnNED_ProcedureExtent]
(
	  @ProcedureId AS INT
	, @CarriedOutRole AS INT = 0			--## 0: 'Overall Extent'; 1: TrainER; 2: TrainEE
)
RETURNS VARCHAR(50)
AS
-- =============================================
-- Description:	This will return the 'Extent' of the Procedure...
/*
	The extent reached field is procedure specific. See the ExtentTypeEnum table for further information.
	An extent is mandatory for a trainee where they have a procedure role of “was assisted physically”.

	Notes: For the readability for later Support- pelase keep the @FurthestExtentId block seperate and Translation part separate (ID to NAME)
*/
-- =============================================
BEGIN
	DECLARE @ResultVar VARCHAR(50);
	DECLARE @ProcedureType AS INT;
	DECLARE @FurthestExtentId AS INT;
	
	SELECT @ProcedureType= ProcedureType FROM ERS_Procedures WHERE ProcedureId=@ProcedureId;

	--## 1) First get the 'Furthest Distance Examined' value for the respective Proc Type.. This can be used All over in the CASE statement!
	SELECT @FurthestExtentId = 
	(
		CASE 
			when @ProcedureType=1 THEN (
										SELECT 
											(CASE @CarriedOutRole 
												WHEN 0 THEN --## READ Overall Extent- means the Furthest Distance Examine/Inserted!
													(CASE WHEN (IsNull(Extent, 0)<=IsNull(TrainerExtent, 0) AND Extent > 0)THEN Extent ELSE  TrainerExtent END)  --## Smaller number are the Furthest, ie: Jejunum= 7, and 'Proximal Oesophegus' = 12 (Closest)
												WHEN 1 THEN IsNull(TrainerExtent, 0)
												WHEN 2 THEN IsNull(Extent, 0)
											END)
										FROM dbo.ERS_UpperGIExtentOfIntubation WHERE ProcedureId=@ProcedureId)
			WHEN @ProcedureType IN (3, 13, 4) THEN (
										SELECT 
											(CASE @CarriedOutRole 
												WHEN 0 THEN --## READ Overall Extent- means the Furthest Distance Examine/Inserted!
													(CASE WHEN IsNull(NED_InsertionTo, 0)>=IsNull(InsertionTo, 0) THEN NED_InsertionTo ELSE  InsertionTo END)  --## Larger number are the Furthest, ie: IleoColon= 31, and 'Proximal Sigmoid' = 3 (Closest)
												WHEN 1 THEN IsNull(NED_InsertionTo, 0)	--## TrainER
												WHEN 2 THEN IsNull(InsertionTo, 0)		--## TrainEE
											END)
										FROM dbo.ERS_ColonExtentOfIntubation WHERE ProcedureId=@ProcedureId
			)
		END
	)


	--## 2) Now get the Trasnlated 'Id' to 'Name' of the Extent Inserted to.. And pass the FailureReasonId, too... So- you get the Complete answer!
	SELECT @ResultVar = 
	(
		CASE WHEN @ProcedureType = 1 THEN (		--## OGD; EE and ER on the SAME Record!
				SELECT dbo.fnNED_ProcedureExtentIdToName(@ProcedureType, @FurthestExtentId, (CASE WHEN @CarriedOutRole in (0, 1) THEN IsNull(TrainerFailureReason, 0) ELSE  IsNull(FailureReason, 0) END) )   --## @CarriedOutRole: 0 for 'Overall';  for TrainER!
				FROM ERS_UpperGIExtentOfIntubation
				WHERE ProcedureId=@ProcedureId
				)
			WHEN @ProcedureType = 2 THEN (		--## ERCP
				--## Now take CarriedOutRole into consideration to Join the Appropriate fields!
				--## When Endoscopist has done something either in 'PapillaBile' or in 'Pancreaitc Bile' or 'MinorPapilla' 
				--				That's the ANSWER (Extent) we are looking for- doesn't matter- Success/Fail!
				SELECT 
					CASE WHEN @CarriedOutRole = 2 THEN --## TrainEE
						(CASE WHEN Vis.Abandoned = 1 THEN 'Abandoned'
						When (Vis.MajorPapillaBile >0 And Vis.MajorPapillaPancreatic > 0) 
							Then 'CBD and PD'
						Else 
							Case When Vis.MajorPapillaBile <= 2
								 Then 'Common bile duct'
							Else (Case When Vis.MajorPapillaPancreatic<=2 Then 'Pancreatic duct' 
										Else (Case When Vis.MinorPapilla > 0
												Then 'Papilla' 
												Else NULL End)
									End)
								End
						End)
					WHEN @CarriedOutRole = 1 THEN --## TrainER
						(CASE WHEN Vis.Abandoned_ER = 1 THEN 'Abandoned'
						When (Vis.MajorPapillaBile_ER > 0 And Vis.MajorPapillaPancreatic_ER > 0) 
							Then 'CBD and PD'
						Else 
							Case When Vis.MajorPapillaBile_ER > 0
								 Then 'Common bile duct'
							Else (Case When Vis.MajorPapillaPancreatic_ER > 0 Then 'Pancreatic duct' 
										Else (Case When Vis.MinorPapilla_ER > 0
												Then 'Papilla' 
												Else NULL End)
									End)
								End
						End)
					WHEN @CarriedOutRole = 0 THEN --## Overall Extent
					(
						CASE WHEN ( (Vis.MajorPapillaBile_ER > 0 And Vis.MajorPapillaPancreatic_ER > 0)  -- ## TainER
										OR
									(Vis.MajorPapillaBile > 0 And Vis.MajorPapillaPancreatic > 0)  )	-- ## TainER
							Then 'CBD and PD'
						Else 
							Case When (Vis.MajorPapillaBile > 0 OR Vis.MajorPapillaBile_ER > 0)
								 Then 'Common bile duct'
							Else (Case When (Vis.MajorPapillaPancreatic > 0 OR Vis.MajorPapillaPancreatic_ER > 0) Then 'Pancreatic duct' 
										Else (Case When (Vis.MinorPapilla > 0 OR Vis.MinorPapilla_ER > 0 )
												Then 'Papilla' End)
									End)
								End
						End
					)
					END
						FROM dbo.ERS_Procedures AS	P
						INNER JOIN dbo.ERS_Visualisation AS Vis ON P.ProcedureId = Vis.ProcedureId
					WHERE P.ProcedureId= @ProcedureId
				)
			WHEN @ProcedureType IN (3, 13, 4) THEN(			--##-- COLON / Flexi
				SELECT dbo.fnNED_ProcedureExtentIdToName(@ProcedureType, @FurthestExtentId, (CASE WHEN @CarriedOutRole in (0, 1) THEN IsNull(NED_Abandoned, 0) ELSE  IsNull(Abandoned, 0) END) )  --## @CarriedOutRole: 0 for 'Overall';  for TrainER!
				FROM dbo.ERS_ColonExtentOfIntubation
				WHERE ProcedureId=@ProcedureId
			)
		END
	);
	
	RETURN @ResultVar;

END
GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'tvfEndoscopistSelectByProcedureSite', 'F';
GO
-----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[tvfEndoscopistSelectByProcedureSite]
(
	@ProcedureId	AS INT = 0,
	@SiteId			AS INT = 0
)
-- =============================================
-- Description:	This will return the list of 'Consultants' for each Procedure- 
--						You can find by Procedure Id or by SiteId
-- =============================================
RETURNS TABLE 
AS
RETURN 
(
		SELECT 
			P.ProcedureId, 
			IsNull(S.SiteId, 0) AS SiteId,
			P.ListType,
			End1.GMCCode AS End1_GMCCode,
			P.Endoscopist1, p.Endo1Role, (End1.Forename + ' ' + End1.Surname) As End1_Name,
			(CASE p.Endo1Role WHEN 1 THEN 'Independent (no trainer)' WHEN 2 THEN 'I observed' WHEN 3 THEN 'I assisted physically' end ) AS RoleTypeEnd1,
			IsNull((SELECT Id FROM dbo.ERS_UpperGITherapeutics	AS  UGI WHERE UGI.SiteId = S.SiteId  AND  UGI.CarriedOutRole=1), 0) AS ER_TherapRecordId,
			IsNull((SELECT Id FROM dbo.ERS_ERCPTherapeutics		AS ERCP WHERE ERCP.SiteId = S.SiteId AND ERCP.CarriedOutRole=1), 0) AS ERCP_ER_TherapRecordId,
			P.Endoscopist2 AS Endoscopist2, p.Endo2Role,
			End2.GMCCode AS End2_GMCCode,
			(End2.Forename + ' ' + End2.Surname) As End2_Name,
			(CASE p.Endo2Role WHEN 1 THEN 'Independent (no trainer)' WHEN 2 THEN 'Was observed' WHEN 3 THEN 'Was assisted physically' end ) AS RoleTypeEnd2,
			IsNull((SELECT Id FROM dbo.ERS_UpperGITherapeutics AS  UGI WHERE UGI.SiteId=S.SiteId  AND  UGI.CarriedOutRole=2), 0) AS EE_TherapRecordId
			--IsNull((SELECT Id FROM dbo.ERS_ERCPTherapeutics	AS ERCP WHERE ERCP.SiteId=S.SiteId AND ERCP.CarriedOutRole=2), 0) AS ERCP_EE_TherapRecordId,
			--IsNull((SELECT Id FROM dbo.ERS_Visualisation AS  Vis WHERE Vis.ProcedureID=P.ProcedureId), 0) AS VisRecordId

		FROM dbo.ERS_Procedures AS P
   LEFT JOIN dbo.ERS_Sites AS S ON P.ProcedureId=S.ProcedureId
   LEFT JOIN dbo.ERS_Users as End1 ON P.Endoscopist1 = End1.UserID
   LEFT JOIN dbo.ERS_Users as End2 ON P.Endoscopist2 = End2.UserID
	   WHERE (@SiteId<>0 and s.SiteId=@SiteId) 
				OR
			(@ProcedureId<>0 AND P.ProcedureId=@ProcedureId)
)
GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'tvfNED_ProcedureConsultants', 'F';
GO

CREATE FUNCTION [dbo].[tvfNED_ProcedureConsultants]
(
	@ProcedureId as INT
	, @ProcedureType AS INT
)
-- =============================================
-- Description:	This will return the list of 'Consultants' for each Procedure- required for NED Export!
-- =============================================
RETURNS TABLE 
AS
RETURN 
(
	WITH EndoscopistSummary AS(
		select top 1 ProcedureId AS ProcedureId, End1_GMCCode, Endoscopist1, Endo1Role, RoleTypeEnd1, End2_GMCCode, Endoscopist2, Endo2Role, RoleTypeEnd2, ListType from tvfEndoscopistSelectByProcedureSite(@ProcedureId,0)	
	)
	Select E.ProcedureId
	--, C.GMCCode AS professionalBodyCode
	--, 'UNITrainer' AS professionalBodyCode	 --## Change it for LIVE. In TEST- we need this dummy data to pass the NED Validation check!
	, E.End1_GMCCode AS professionalBodyCode
	, E.Endoscopist1 AS EndosId, E.Endo1Role AS EndRole, E.ListType
	, E.RoleTypeEnd1 AS procedureRole
	, (Case E.Endo1Role When 1 Then 'Independent' Else 'Trainer' END) As endoscopistRole
	, 1 AS ConsultantTypeId
	, dbo.fnNED_ProcedureExtent(@ProcedureId, 1) AS Extent		--## TrainER Extent
	, (CASE WHEN @ProcedureType IN (1,2) THEN
		(CASE IsNull(Ex.TrainerJmanoeuvre, 1) When 1 Then 'No' WHEN 2 THEN 'Yes' End)
		 WHEN @ProcedureType IN (3, 13, 4) THEN
		 (CASE IsNull(COL.NED_Retroflexion, 0) When 0 Then 'No' WHEN 1 THEN 'Yes' End)
		END)	AS jManoeuvre
	 FROM EndoscopistSummary AS E
	 LEFT JOIN dbo.ERS_UpperGIExtentOfIntubation	AS EX  ON E.ProcedureId = EX.ProcedureId
	 LEFT JOIN dbo.ERS_ColonExtentOfIntubation		AS COL ON E.ProcedureId = COL.ProcedureId
	 LEFT JOIN dbo.ERS_Users						AS U   ON E.Endoscopist1 = U.UserId

	UNION ALL --## Now Combine the TrainEE Record!
	
	Select E.ProcedureId
	--, C.GMCCode AS professionalBodyCode
	--, 'UNITrainee' AS professionalBodyCode --## Change it for LIVE. In TEST- we need this dummy data to pass the NED Validation check!
	, E.End2_GMCCode AS professionalBodyCode
	, E.Endoscopist2 AS EndosId, E.Endo2Role  AS EndRole, E.listType
	, E.RoleTypeEnd2 AS procedureRole
	, (Case E.Endo2Role When 1 Then 'Independent' Else 'Trainee' END) As endoscopistRole
	, 2 AS ConsultantTypeId
	, dbo.fnNED_ProcedureExtent(@ProcedureId, 2) AS Extent	--## TrainEE Extent
	, (CASE WHEN @ProcedureType IN (1,2) THEN
		(CASE IsNull(Ex.Jmanoeuvre, 1) When 1 Then 'No' WHEN 2 THEN 'Yes' End)
		 WHEN @ProcedureType IN (3, 13, 4) THEN
		 (CASE IsNull(COL.Retroflexion, 0) When 0 Then 'No' WHEN 1 THEN 'Yes' End)
		END)	AS jManoeuvre
	--, (Case Ex.Jmanoeuvre When 1 Then 'No' WHEN 2 THEN 'Yes' ELSE 'Not Specified' End) AS jManoeuvre
	from EndoscopistSummary AS E 
		LEFT JOIN dbo.ERS_UpperGIExtentOfIntubation		AS EX  ON E.ProcedureId = EX.ProcedureId
		LEFT JOIN dbo.ERS_ColonExtentOfIntubation		AS COL ON E.ProcedureId = COL.ProcedureId
		LEFT JOIN dbo.ERS_Users							AS U   ON E.Endoscopist2 = U.UserId
	Where E.Endoscopist2 IS NOT NULL
	);

GO
-----------------------------------------------------------------------------------------------------------
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
			CASE WHEN ColonAlterBowelHabit = 7 THEN 18 END																		AS DefaecationDisorder,
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
			CASE WHEN P.ProcedureType IN (1, 3, 13, 4) AND UT.StentReplacement = 1 THEN 54 END									AS StentReplacement,
			CASE WHEN P.ProcedureType IN (1, 3, 13, 4) AND UT.StentInsertion = 1 THEN 55 END									AS StentInsertion,  
			CASE WHEN P.ProcedureType IN (1, 3, 13, 4) AND UT.StentRemoval = 1 THEN 56 END										AS StentRemoval,
			CASE WHEN UT.ColonTumourAssessment = 1 THEN 57 END																	AS TumourAssessment,
			CASE WHEN UT.OesophagealVarices = 1 THEN 58 END																		AS OesophagealVarices,
			CASE WHEN UT.ColonWeightLoss = 1 OR UT.WeightLoss = 1 THEN 59 END													AS WeightLoss
		FROM            dbo.ERS_Procedures P 
			LEFT OUTER JOIN dbo.ERS_UpperGIIndications UT ON P.ProcedureId = UT.ProcedureId
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
EXEC DropIfExist 'fnNED_GetOtherTypeIndications', 'F';
GO
-----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[fnNED_GetOtherTypeIndications]
(
	@ProcedureId	AS INT
)
-- =============================================
-- Description:	This will Concatenate the 'Other' Type of Indications which are not recognised by NED Schema.
--				So- when this function is called for a 'OTHER' indication type- it will concatenate some specific Indications,
--						like: ERSImgUltrasound, UT.ERSImgCT, UT.ERSImgMRI, UT.ERSImgMRCP=1  OR UT.ERSImgEUS, UT.ERSImgIDA, UT.ERSAcutePancreatitis and OTher Field's data itself
-- =============================================
RETURNS varchar(1000)
AS
BEGIN	
	DECLARE @ResultVar VARCHAR(1000);

		BEGIN
			SELECT @ResultVar = 
					  COALESCE(Cancer + ', ', '')
					+ COALESCE(StentReplacement + ', ', '')
					+ COALESCE(StentInsertion +   ', ', '')
					+ COALESCE(StentRemoval + ', ', '')
					+ COALESCE(ScreeningColonoscopy + ', ', '')
					+ COALESCE(FIT + ', ', '')
					+ COALESCE(Surveillance + ', ', '')
					+ COALESCE(AcuteAlternatingDiarrhoea + ', ', '')
					+ COALESCE(NatBowelScopeScreening + ', ', '')
					+ COALESCE(RaisedFaecalCalprotectin + ', ', '')
					+ COALESCE(ColonicObstruction + ', ', '')
					+ COALESCE(TumourAssessment + ', ', '')
					+ COALESCE(UrgentTwoWeekReferral + ', ', '')
					+ COALESCE(EMR + ', ', '')
					+ COALESCE(ChectPain + ', ', '')
					+ COALESCE(ChronicLiverDisease + ', ', '')
					+ COALESCE(PreviousHPyloriTest + ', ', '')
					+ COALESCE(CoffeeGroundsVomit + ', ', '')
					+ COALESCE(DrugTrial + ', ', '')
					+ COALESCE(UlcerExclusion + ', ', '')
					+ COALESCE(BariatricPreAssessment + ', ', '')
					+ COALESCE(BalloonInsertion + ', ', '')
					+ COALESCE(BalloonRemoval + ', ', '')
					+ COALESCE(PostBariatricSurgeryAssessment + ', ', '')
					+ COALESCE(EUS + ', ', '')
					+ COALESCE(InsertionOfPHProbe + ', ', '')
					+ COALESCE(JejunostomyInsertion + ', ', '')
					+ COALESCE(NasoDuodenalTube + ', ', '')
					+ COALESCE(OesophagealDilatation + ', ', '')
					+ COALESCE(Oesophagitis + ', ', '')
					+ COALESCE(ObstructedCBD + ', ', '')
					+ COALESCE(ERSOpenAccess + ', ', '')
					+ COALESCE(ERSRecurrentPancreatitis + ', ', '')
					+ COALESCE(ERSSphincter +', ', '')
					+ COALESCE(ERSPapillaryDysfunction + ', ', '')
					+ COALESCE(EPlanCanunulate + ', ', '')
					+ COALESCE(EplanCombinedProcedure + ', ', '')
					+ COALESCE(EPlanEndoscopicCyst + ', ', '')
					+ COALESCE(EplanManometry + ', ', '')
					+ COALESCE(EplanNasoPancreatic + ', ', '')
					+ COALESCE(EplanPapillotomy + ', ', '')
					+ COALESCE(EplanStoneRemoval + ', ', '')
					+ COALESCE(EplanStrictureDilatation + ', ', '')
					+ COALESCE(ERSBiliaryLeak + ', ', '')
					+ COALESCE(ERSDilatedDucts + ', ', '')
					+ COALESCE(ERSDilatedPancreatic + ', ', '')
					+ COALESCE(ERSFluidCollection + ', ', '')
					+ COALESCE(ERSGallBladder + ', ', '')
					+ COALESCE(ERSAcutePancreatitis + ', ', '')
					+ COALESCE(ERSChronicPancreatitis + ', ', '')
					+ COALESCE(ERSStonedBiliary + ', ', '')
					+ COALESCE(ERSImgOthersTextBox + ', ', '')
					+ COALESCE(EplanOthersTextBox + ', ', '')
					+ COALESCE(OtherIndication + ', ', '') 
			FROM
			(
				SELECT 
					CASE WHEN P.ProcedureType IN (1, 2) AND UT.Cancer = 1		THEN 'Cancer' END										AS Cancer,
					CASE WHEN P.ProcedureType = 2 AND UT.StentReplacement = 1	THEN 'Stent change' END									AS StentReplacement,
					CASE WHEN P.ProcedureType = 2 AND UT.StentInsertion = 1		THEN 'Stent placement' END								AS StentInsertion,  
					CASE WHEN P.ProcedureType = 2 AND UT.StentRemoval = 1		THEN 'Stent removal' END								AS StentRemoval,
					CASE WHEN UT.ColonSreeningColonoscopy = 1					THEN 'Screening Colonoscopy' END						AS ScreeningColonoscopy,
					CASE WHEN UT.ColonFIT = 1									THEN 'Fecal immuno chemical test' END					AS FIT,
					CASE WHEN UT.ColonIndicationSurveillance = 1				THEN 'Surveillance' END									AS Surveillance,
					CASE WHEN ColonAlterBowelHabit = 7							THEN 'Acute alternating diarrhoea / constipation' END	AS AcuteAlternatingDiarrhoea,
					CASE WHEN UT.NationalBowelScopeScreening = 1				THEN 'National Bowel Scope Screening' END				AS NatBowelScopeScreening,
					CASE WHEN UT.ColonRaisedFaecalCalprotectin = 1				THEN 'Raised Faecal Calprotectin' END					AS RaisedFaecalCalprotectin,
					CASE WHEN UT.ColonColonicObstruction = 1					THEN 'Colonic obstruction' END							AS ColonicObstruction,
					CASE WHEN UT.ColonTumourAssessment = 1						THEN 'Tumour Assessment' END							AS TumourAssessment,
					CASE WHEN UT.UrgentTwoWeekReferral = 1						THEN 'Urgent 2 Week Referral' END						AS UrgentTwoWeekReferral,
					CASE WHEN UT.EMR = 1										THEN 'EMR' END											AS EMR,
					CASE WHEN UT.ChestPain = 1									THEN 'Chect pain' END									AS ChectPain,
					CASE WHEN UT.ChronicLiverDisease = 1						THEN 'Chronic liver disease' END 						AS ChronicLiverDisease,
					CASE WHEN UT.PreviousHPyloriTest = 1						THEN 'Previous H. pylori test' END						AS PreviousHPyloriTest,
					CASE WHEN UT.CoffeeGroundsVomit = 1							THEN 'Coffee grounds vomit' END							AS CoffeeGroundsVomit,
					CASE WHEN UT.DrugTrial = 1									THEN 'Drug Trial' END									AS DrugTrial,
					CASE WHEN UT.UlcerExclusion = 1								THEN 'Ulcer Exclusion' END								AS UlcerExclusion,
					CASE WHEN UT.BariatricPreAssessment = 1						THEN 'Bariatric pre assessment' END						AS BariatricPreAssessment,
					CASE WHEN UT.BalloonInsertion = 1							THEN 'Balloon Insertion' END							AS BalloonInsertion,
					CASE WHEN UT.BalloonRemoval = 1								THEN 'Balloon Removal' END								AS BalloonRemoval,
					CASE WHEN UT.PostBariatricSurgeryAssessment = 1				THEN 'Post Bariatric Surgery Assessment' END			AS PostBariatricSurgeryAssessment,
					CASE WHEN UT.EUS = 1										THEN 'EUS' END											AS EUS,
					CASE WHEN UT.InsertionOfPHProbe = 1							THEN 'Insertion of PHProbe' END							AS InsertionOfPHProbe,
					CASE WHEN UT.JejunostomyInsertion = 1						THEN 'Jejunostomy insertion (PEJ)' END					AS JejunostomyInsertion,
					CASE WHEN UT.NasoDuodenalTube = 1							THEN 'Nasojejunal tube (NJT)' END						AS NasoDuodenalTube,
					CASE WHEN UT.OesophagealDilatation = 1						THEN 'Oesophageal dilatation' END						AS OesophagealDilatation,
					CASE WHEN UT.Oesophagitis = 1								THEN 'Oesophagitis' END									AS Oesophagitis,
					CASE WHEN UT.ERSObstructedCBD = 1							THEN 'Obstructed CBD' END								AS ObstructedCBD,
					CASE WHEN UT.ERSOpenAccess = 1								THEN 'Open Access' END									AS ERSOpenAccess,
					CASE WHEN UT.ERSRecurrentPancreatitis = 1					THEN 'Recurrent Pancreatitis' END						AS ERSRecurrentPancreatitis,
					CASE WHEN UT.ERSSphincter = 1								THEN 'Sphincter of Oddi dysfunction' END				AS ERSSphincter,
					CASE WHEN UT.ERSPapillaryDysfunction = 1					THEN 'Papillary Dysfunction' END						AS ERSPapillaryDysfunction,
					CASE WHEN UT.EPlanCanunulate = 1							THEN 'Canunulate and opacify the biliary tree' END		AS EPlanCanunulate,
					CASE WHEN UT.EplanCombinedProcedure = 1						THEN 'Combined procedure(Rendezvous) ' END				AS EplanCombinedProcedure,
					CASE WHEN UT.EPlanEndoscopicCyst = 1						THEN 'Endoscopic cyst puncture' END						AS EPlanEndoscopicCyst,
					CASE WHEN UT.EplanManometry = 1								THEN 'Manometry' END									AS EplanManometry,
					CASE WHEN UT.EplanNasoPancreatic = 1						THEN 'Naso-pancreatic/biliary drains' END				AS EplanNasoPancreatic,
					CASE WHEN UT.EplanPapillotomy = 1							THEN 'Papillotomy/sphincterotomy' END					AS EplanPapillotomy,
					CASE WHEN UT.EplanStoneRemoval = 1							THEN 'Stone Removal' END								AS EplanStoneRemoval,
					CASE WHEN UT.EplanStrictureDilatation = 1					THEN 'Stricture Dilatation' END							AS EplanStrictureDilatation,
					CASE WHEN UT.ERSBiliaryLeak = 1								THEN 'Bilaiary Leak' END								AS ERSBiliaryLeak,
					CASE WHEN UT.ERSDilatedDucts = 1							THEN 'Dilated Bile Ducts ' END							AS ERSDilatedDucts,
					CASE WHEN UT.ERSDilatedPancreatic = 1						THEN 'Dilated Pancreatic Duct' END						AS ERSDilatedPancreatic,
					CASE WHEN UT.ERSFluidCollection = 1							THEN 'Fluid Collection' END								AS ERSFluidCollection,
					CASE WHEN UT.ERSGallBladder = 1								THEN 'Gall Bladder Stones' END							AS ERSGallBladder,
					CASE WHEN UT.ERSAcutePancreatitis = 1						THEN 'Acute Pancreatitis' END							AS ERSAcutePancreatitis,
					CASE WHEN UT.ERSChronicPancreatitis	= 1						THEN 'Chronic Pancreatitis' END							AS ERSChronicPancreatitis,
					CASE WHEN UT.ERSStonedBiliary = 1							THEN 'Stone(s) in Biliary Tree' END						AS ERSStonedBiliary,
					CASE WHEN LEN(UT.ERSImgOthersTextBox) > 1					THEN UT.ERSImgOthersTextBox END							AS ERSImgOthersTextBox,
					CASE WHEN LEN(UT.EplanOthersTextBox) > 1					THEN UT.EplanOthersTextBox END							AS EplanOthersTextBox,
					CASE WHEN LEN(UT.OtherIndication) > 1						THEN UT.OtherIndication END								AS OtherIndication
				 FROM [dbo].ERS_UpperGIIndications UT
				 join ERS_Procedures P on UT.ProcedureId = P.ProcedureId 
				 WHERE UT.ProcedureId = @ProcedureId
			) AS ReadyMixMasala
		END
	SET @ResultVar = ltrim(rtrim(@ResultVar));
	--## Remove the Last ',' of the String; That's a virus! Bad for indigestion!
	SELECT @ResultVar= CASE 
						WHEN RIGHT(@ResultVar, 1)=',' THEN SUBSTRING(@ResultVar, 1, LEN(@ResultVar)-1)
						ELSE @ResultVar END;

	RETURN @ResultVar;

END

GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'tvfNED_ProcedureLimitation', 'F';
GO
-----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[tvfNED_ProcedureLimitation]
(
	  @ProcedureType AS INT
	, @ProcedureId AS INT

)
-- =============================================
-- Description:	This will return the list of 'Limitation' for each Procedure- required for NED Export!
--			Limitations- only applicable for 'Colon/Flexi'. Not for OGD or ERCP
-- =============================================
RETURNS TABLE
AS
RETURN 
(	
	WITH cteLimitationsFound AS (
	SELECT 
		(Case --## First identify- EE or ER - who has 'FurthestDistance Inserted'- then respective EE or ER's LimitedBy value will be used!
		(CASE WHEN (L.NED_InsertionTo>= L.InsertionTo) THEN L.NED_InsertionLimitedBy ELSE L.InsertionLimitedBy END)		--## Whoever has 'HigherInsertionTo' is the Furthest Traveller!
			WHEN  0 THEN  
				(CASE P.ProcedureType WHEN 13 THEN 'clinical intention achieved' else 'Not Limited' end)
			WHEN  7 then 'inadequate bowel prep'
			WHEN  9 THEN 'patient discomfort'
			WHEN  6 THEN 'benign stricture'
			WHEN  8 THEN 'malignant stricture'
			WHEN 10 THEN 'severe colitis'
			WHEN 11 THEN 'unresolved loop'
			WHEN 12 THEN 'clinical intention achieved'
		ELSE 'Other' --## And 'other' will come in the 'Comment' field!
		END)	As Limitation
		, NULL AS Comment

		FROM [dbo].ERS_ColonExtentOfIntubation L 
		INNER JOIN dbo.ERS_Procedures AS P ON L.ProcedureId = P.ProcedureId
		where L.ProcedureId = @ProcedureId AND P.ProcedureType IN (3,13)
	)
	SELECT * FROM cteLimitationsFound
		
	UNION ALL 

	SELECT 'Other' AS Limitation
	, (SELECT top 1 L.ListItemText	--## There can be ONE 'Other' Field anyway... But - you never know- dirty data can be an evil... So 'TOP 1' is safer!
			FROM [dbo].[ERS_ColonExtentOfIntubation] AS COL 
				INNER JOIN dbo.ERS_Lists AS L ON COL.InsertionLimitedBy=L.ListItemNo AND L.ListDescription = 'Colon_Extent_Insertion_Limited_By'
				WHERE Col.ProcedureId= @ProcedureId AND 
					(CASE WHEN (COL.NED_InsertionTo>= COL.InsertionTo) THEN COL.NED_InsertionLimitedBy ELSE COL.InsertionLimitedBy END)
				NOT IN (0,6,7,8,9,10,11) --### Anything other than SPecified in the NED Valid list- goes in the 'Other' Text!
	) As Comment --## Use this field to define what “Other” is when selected. There can be ONE value ONLY
	FROM cteLimitationsFound AS Lim
	WHERE Lim.Limitation IS NULL --## What I mean- when NO record found for Main Limitation..

	UNION ALL
	--Upper GI Procedure Other
	SELECT 'Other' AS Limitation 
	, Case (case when FailureReason > TrainerFailureReason then FailureReason else TrainerFailureReason end)
			when 1 then 'failed intubation '
			when 2 then 'oesophageal stricture'
			when 3 then (Case when FailureReasonOther = '' then TrainerFailureReasonOther else FailureReasonOther end)
			when 4 then 'Abandoned'
	 end As Comment
	from ERS_UpperGIExtentOfIntubation 
	where ProcedureId = @ProcedureId
	and (FailureReason > 0 or TrainerFailureReason > 0)

	UNION ALL
	--ERCP Procedure
	SELECT 'OTHER' AS Limitation 
	, isnull(case isnull(PancreaticLimitedBy, 0) 
		when 2
			then 'Pancreatic - ' + (SELECT case when ListItemText = '(none)' then 'Other' else ListItemText END 
				from ERS_Lists 
				where ListDescription = 'ERCP extent of visualisation limited by other' 
				and ListItemNo = PancreaticLimitedByOtherText)
		when 1 then 'Pancreatic - insufficient contrast injected'
		END, ' ') + 
		isnull(case isnull(HepatobiliaryLimitedBy, 0) 
		when 2
			then 'Hepatobiliary - ' + (SELECT case when ListItemText = '(none)' then 'Other' else ListItemText END 
				from ERS_Lists 
				where ListDescription = 'ERCP extent of visualisation limited by other' 
				and ListItemNo = HepatobiliaryLimitedByOtherText)
		when 1 then 'Hepatobiliary - insufficient contrast injected'
		END, ' ') As Comment
	from ERS_Visualisation
	where ProcedureID = @ProcedureId
	and (PancreaticLimitedBy is not null or HepatobiliaryLimitedBy is not null)

);

GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'fnNED_GetBiopsySiteName', 'F';
GO
-----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[fnNED_GetBiopsySiteName]
(
	  @ProcedureID AS INT
	, @RegionName AS VARCHAR(50)
)
RETURNS VARCHAR(100)
AS
-- =============================================
-- Description:	This will translate the Region name to Valid NED Site name
--				Will be used three times at least: 1) NED_Biopsy, 2) NED_Diagnoses, 3) Therapeutic Site
-- =============================================
BEGIN
	DECLARE @ResultVar VARCHAR(250);

	DECLARE @ResectedColonId int, @ProcedureType int
	SELECT @ResectedColonId	= ISNULL(ResectedColonNo,0), @ProcedureType = ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureID
	
	IF @ProcedureType=2 
		set @ResultVar = 'None' --## No BIOPSY info required for ERCP Procs

	IF @ProcedureType=1	
		BEGIN
			IF CHARINDEX(LOWER(@RegionName), 'upper oesophagus,middle oesophagus,lower oesophagus,right upper oesophagus,left upper oesophagus,right middle oesophagus,left middle oesophagus,right lower oesophagus,left lower oesophagus,cardia')>0
				set @ResultVar = 'Oesophagus';
			ELSE IF CHARINDEX(LOWER(@RegionName), 'fundus,upper body,middle body,lower body,antrum,prepyloric region,pylorus,lesser curve upper body,greater curve upper body,greater curve middle body,lesser curve middle body,angulus,greater curve lower body,lesser curve antrum,greater curve antrum,greater curve prepyloric region,lesser curve prepyloric region,superior pylorus,inferior pylorus')>0
				set @ResultVar = 'Stomach';
			ELSE IF CHARINDEX(LOWER(@RegionName), 'bulb,superior bulb,inferior bulb') > 0			
				set @ResultVar = 'Duodenal bulb'
			ELSE IF LOWER(@RegionName)='second part'	
				set @ResultVar = 'D2 - 2nd part of duodenum'
		END										
	
	--## Now colon/flexi Fields
	IF @ProcedureType=3	OR @ProcedureType=13 OR @ProcedureType=4
		BEGIN
			IF (@ResectedColonId IN (6,7,9) AND LOWER(@RegionName) = 'terminal ileum')
			BEGIN
				IF(@ResectedColonId = 6 OR @ResectedColonId = 7)
					set @RegionName = 'Neo-terminal ileum';
				ELSE IF (@ResectedColonId = 9)
					set @RegionName = 'ileal pouch';
			END
			
			--use charindex where multiple regions result in a single value, otherwise do a direct match- correct value could result in getting overwritten otherwise eg terminal ileum vs neo-terminal ileum. both returns a charindex of >0
			IF LOWER(@RegionName) = 'terminal ileum'
				set @ResultVar = 'Terminal ileum';
			IF LOWER(@RegionName) = 'ileal pouch'
				set @ResultVar = 'Pouch';
			IF LOWER(@RegionName) = 'anastomosis'
				set @ResultVar = 'Ileo-colon anastomosis';
			IF (CHARINDEX( LOWER(@RegionName), 'distal ascending, mid ascending, proximal ascending')>0 )
				set @ResultVar = 'Ascending Colon';
			IF (CHARINDEX( LOWER(@RegionName), 'distal transverse, mid transverse, proximal transverse')>0 )
				set @ResultVar = 'Transverse Colon';
			IF (CHARINDEX( LOWER(@RegionName), 'distal descending, mid descending, proximal descending')>0 )
				set @ResultVar = 'Descending Colon';
			IF (CHARINDEX( LOWER(@RegionName), 'distal sigmoid,proximal sigmoid,rectosigmoid junction')>0 )
				set @ResultVar = 'Sigmoid Colon';
			IF (CHARINDEX( LOWER(@RegionName), 'caecum,appendiceal orifice,ileocecal valve')>0 )
				set @ResultVar = 'Caecum';
			IF LOWER(@RegionName) = 'Neo-terminal ileum'
				set @ResultVar	= 'Neo-terminal ileum';
			IF LOWER(@RegionName) = 'hepatic flexure'
				set @ResultVar	= 'Hepatic flexure';
			IF (CHARINDEX( LOWER(@RegionName), 'distal transverse, mid transverse, proximal transverse')>0)
				set @ResultVar	= 'Transverse Colon';
			IF LOWER(@RegionName) = 'splenic flexure'
				set @ResultVar	= 'Splenic flexure';
			IF LOWER(@RegionName) = 'rectum'
				set @ResultVar	= 'Rectum';
			IF LOWER(@RegionName) = 'anal margin'
				set @ResultVar	= 'Anus';
		END
	RETURN @ResultVar;
END
GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'tvfNED_ProcedureBiopsy', 'F';
GO
-----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[tvfNED_ProcedureBiopsy]
(	
	    @ProcedureType AS INT
	  , @ProcedureId AS INT
)
-- =============================================
-- Description:	This will return the list of the Biopsies done on OGD/ERCP/Colon. NOT for ERCP!
-- =============================================
RETURNS TABLE 
AS
RETURN 
(
	WITH DetailedBiopsy AS (
		SELECT		R.RegionId,
			R.Region
			, CASE WHEN RC.RegionId IS NULL THEN dbo.fnNED_GetBiopsySiteName(P.ProcedureId, r.Region) ELSE 'Ileo-colon anastomosis' END As BiopsySite
			, (CASE WHEN P.ProcedureType=2 THEN 0 
				ELSE (IsNull(SP.BiopsyQtyHistology, 0) + IsNull(SP.BiopsyQtyMicrobiology, 0) + IsNull(SP.BiopsyQtyVirology,0))
				END)								As NumberPerformed
		FROM dbo.ERS_Procedures			P
			INNER JOIN dbo.ERS_Sites				S ON P.ProcedureId=S.ProcedureId
			LEFT JOIN tvfProcedureResectedColon(@ProcedureId) RC ON RC.RegionId = S.RegionId
			INNER JOIN dbo.ERS_UpperGISpecimens SP ON S.SiteId=SP.SiteId
			LEFT JOIN dbo.ERS_Regions			R ON S.RegionId=R.RegionId And P.ProcedureType=R.ProcedureType	
		WHERE P.ProcedureId = @ProcedureId
	)
	SELECT 
		  IsNull(B.BiopsySite, 'None')		AS BiopsySite
		, SUM(IsNull(B.NumberPerformed, 0)) AS NumberPerformed
	FROM DetailedBiopsy AS B
	GROUP BY B.BiopsySite
	HAVING SUM(IsNull(B.NumberPerformed, 0)) > 0 AND B.BiopsySite IS NOT NULL 
	
	UNION ALL
	
	SELECT 'None' BiopsySite, 0 AS NumberPerformed 
	where (SELECT COUNT(*) FROM DetailedBiopsy WHERE ISNULL (BiopsySite, 'None') != 'None')<1		--## INSERT  Blank row- if NO BIOPSY 'checked' found for that Procedure..
);

GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'tvfNED_Diagnoses', 'F';
GO
-----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[tvfNED_Diagnoses]
(	
	 @ProcedureType AS INT
	, @ProcedureId AS INT
)
RETURNS TABLE 
AS
RETURN 
(
	   SELECT 
				'Colorectal cancer' AS Ned_Name
			  , (
					--## There can be more than 1 record!  Maybe 2 sites- one Marked Tattooed, another Marked with Platue! 'Yes' will supercede 'No';
					SELECT CASE WHEN (
								COUNT( CASE T.MarkingType WHEN 1 THEN 1 ELSE NULL end) 
								>=
								COUNT( CASE WHEN T.MarkingType>1 THEN 1 ELSE NULL end)

						) THEN 'Yes' ELSE 'No' END 
						AS Result
					from dbo.ERS_UpperGITherapeutics AS T
					INNER JOIN dbo.ERS_Sites		AS S ON T.SiteId = S.SiteID
					LEFT JOIN dbo.ERS_Procedures	AS P ON S.ProcedureId = P.ProcedureId
					WHERE P.ProcedureId= @ProcedureId AND T.Marking = 1
				)	AS tattooed	--## 'Colonic polyps or Rectal polyps' => Colon/FLexi ONLY! 
				, dbo.fnNED_GetBiopsySiteName(P.ProcedureId, R.Region) As Site		--## Location of tattoo. BiopsyEnum (Page 42, in Business Spec.doc v.1.15): The Biopsy field is procedure specific. See the BiopsyEnum table for further information.
			  , NULL AS Comment
		 FROM [dbo].[ERS_Diagnoses] D
	--LEFT JOIN [dbo].[ERS_DiagnosesMatrix]	AS M ON D.MatrixCode = M.Code
	LEFT JOIN [dbo].[ERS_Procedures]		AS P ON D.ProcedureID = P.ProcedureId
	LEFT JOIN dbo.ERS_Sites		AS S ON D.SiteId = S.SiteId
	LEFT JOIN dbo.ERS_Regions	AS R ON S.RegionId = R.RegionId
		WHERE D.ProcedureId= @ProcedureId
		  AND P.ProcedureType IN(1,3,13)	--## Only for OGD/Colon/FLEXI! NOT for ERCP!
		  AND D.MatrixCode = 'S69P3'  --## 'Colorectal cancer'
	--## Combine the ColorectalCancerTattooedSite Result, if there is ANY!
	UNION ALL					

	--## There are few Exception 'Diagnoses' Code.. Which doesn't exist int he DiagnosesMatrix.Code field. So- read them separately
		--select TOP 1 --## 'Top 1' Because- it can be like: "'OverallNormal', 'DuodenumNormal', 'OesophagusNormal', 'StomachNormal'"- and we need only once to show 'Normal!'
		--	  'Normal' AS Ned_Name
		--	, NULL	AS Tattooed
		--	, NULL	AS site		
		--	, NULL	AS Comment
		--FROM ERS_diagnoses AS D
		--	where D.ProcedureId= @ProcedureId 
		--	AND MatrixCode IN ('D198P2', 'D265P2', 'D32P2', 'D33P2', 'D51P2', 'D67P2','D138P2','ColonRestNormal','DuodenumNormal','OesophagusNormal','StomachNormal','ColonNormal','OverallNormal') --## (Duodenum, Papillae, Pancreas, Biliary, Intrahepatic, Extrahepatic)
		--	AND D.ProcedureId not in (Select ProcedureId from ERS_diagnoses where SiteID is not null and ProcedureID = @ProcedureId)
		select TOP 1 --## 'Top 1' Because- it can be like: "'OverallNormal', 'DuodenumNormal', 'OesophagusNormal', 'StomachNormal'"- and we need only once to show 'Normal!'
			  'Normal' AS Ned_Name
			, NULL	AS Tattooed
			, NULL	AS site		
			, NULL	AS Comment
		FROM ERS_diagnoses AS D
			where D.ProcedureId= @ProcedureId 
			AND D.ProcedureId not in (Select ProcedureId from ERS_diagnoses where SiteID is not null and ProcedureID = @ProcedureId)
	UNION ALL					
	select DISTINCT --## DISTINCT REQUIRED- When in Stomach- 3 sites - all has Polyps and Gastric- then they will repeat.
		  M.Ned_Name
		, NULL	AS Tattooed
		, NULL	AS site		
		, NULL	AS Comment
	FROM ERS_diagnoses AS D
	INNER JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code
	where D.ProcedureId= @ProcedureId 
		AND M.Ned_Name IS NOT NULL --## I mean select the 'NED Mapped' fields ONLY!
		AND M.NED_Include = 1
		AND M.ProcedureTypeID = @ProcedureType

	UNION ALL					--## Combine 'OTHER' type of Diagnoses! Which Doesn't have a NED Name mapping!
		select top 1
		  'Other' AS DisplayName
		, NULL	AS Tattooed
		, NULL	AS site		
		, 
		(select 
			  (Section + ' ' + M.DisplayName) + ', ' 
		FROM ERS_diagnoses AS D 
		LEFT JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code
		where D.ProcedureId= @ProcedureId
			AND M.Ned_Name IS NULL --## 'NED Mapped' is Missing
			--AND D.MatrixCode NOT IN ('D198P2', 'D265P2', 'D32P2', 'D33P2', 'D51P2', 'D67P2','D138P2') --## Diagnoses thinks these Exceptions belongs to others.. Because these are not Mapped to NED seperately
			AND M.NED_Include = 1
			AND M.ProcedureTypeID = @ProcedureType
			FOR XML PATH('')
		) AS Comment		--## All the fields which are not in the 'NED Restricted Lookup' list!
	FROM ERS_diagnoses AS D
	INNER JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code --## InnerJoin- to avoid keeping anything which Codes (Summary, OverallNormal) don't exist in the Matrix Table.. WIll exclude them...
	where D.ProcedureId= @ProcedureId
		AND M.Ned_Name IS NULL --## Means when 'NED Mapped' is Missing- those belong to 'Other' type
		--AND D.MatrixCode NOT IN ('D198P2', 'D265P2', 'D32P2', 'D33P2', 'D51P2', 'D67P2','D138P2') --## Secondary filter- not to populate a blank 'Other' row.. So- don't return any OTHER row at all if any NORMAL found
		AND M.NED_Include = 1
		AND M.ProcedureTypeID = @ProcedureType

	UNION ALL--## Handles colotis diagnosis as the diagnoses matrix table is joined on ERS_Diagnoses 'value' column rather than the 'code' column
		SELECT 
		  ISNULL(NED_Name,'Colitis - unspecified') AS NED_Name
		, NULL	AS Tattooed
		, NULL	AS site		
		, NULL	AS Comment
		FROM ERS_Diagnoses 
			INNER JOIN dbo.ERS_DiagnosesMatrix edm	ON code=value
		WHERE dbo.ers_diagnoses.MatrixCode='ColitisType'  AND procedureid=@ProcedureId	
		AND edm.ProcedureTypeID = @ProcedureType
);

GO

-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'tvfNED_ProcedureAdverseEvents', 'F';
GO
-----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[tvfNED_ProcedureAdverseEvents]
(
	@ProcedureId as INT
)
-- =============================================
-- Description:	This will return the list of 'Adverse Events' for each Procedure- required for NED Export!
-- =============================================
RETURNS TABLE 
AS

RETURN 
(
WITH AdverseEffectsOther AS(	--## These are other Types.. All the 'Complications' fields. we don't have any EnumList for these types.. so- Hard Code them!
	SELECT 
		DISTINCT QA.ProcedureId, 
		  (CASE WHEN AllergyToMedium=1		THEN 'Allergy to medium, ' ELSE '' END)  
		+ (CASE WHEN Arcinarisation=1		THEN 'Arcinarisation, ' ELSE '' END)  
		+ (CASE WHEN CardiacArrythmia=1		THEN 'Cardiac arrythmia, ' ELSE '' END)  		
		+ (CASE WHEN ContrastExtravasation=1 THEN 'Contrast extravasation, ' ELSE '' END)  
		+ (CASE WHEN DamageToScope=1		THEN 'Damage to scope, ' ELSE '' END)
		+ (CASE WHEN DifficultIntubation=1	THEN 'Difficult intubation, ' ELSE '' END)  		
		+ (CASE WHEN FailedIntubation=1		THEN 'Failed intubation, ' ELSE '' END)  
		+ (CASE WHEN FailedERCP=1			THEN 'Failed ERC/ERP, ' ELSE '' END)  
		+ (CASE WHEN FailedCannulation=1	THEN 'Failed cannulation, ' ELSE '' END)  
		+ (CASE WHEN FailedStentInsertion=1 THEN 'Failed stentInsertion, ' ELSE '' END)  
		+ (CASE WHEN GastricContentsAspiration=1 THEN 'Gastric contents aspiration, ' ELSE '' END)  		
		+ (CASE WHEN InjuryToMouth=1		THEN 'Injury to mouth, ' ELSE '' END)  
		+ (CASE WHEN PoorlyTolerated=1		THEN 'Poorly tolerated, ' ELSE '' END)  
		+ (CASE WHEN PatientDiscomfort=1	THEN 'Patient discomfort, ' ELSE '' END)  
		+ (CASE WHEN Perforation=1			THEN COALESCE(PerforationText + ', ', '') ELSE '' END)  
		+ (CASE WHEN RespiratoryDepression=1 THEN 'Respiratory depression, ' ELSE '' END)  		
		+ (CASE WHEN RespiratoryArrest=1	THEN 'Respiratory arrest, ' ELSE '' END)  
		+ (CASE WHEN ShockHypotension=1		THEN 'Shock/hypotension, ' ELSE '' END)  
		+ (CASE WHEN LEN(TechnicalFailure)>=1 THEN TechnicalFailure + ', ' ELSE '' END) 
		+ (CASE WHEN ComplicationsOther=1	THEN IsNull(ComplicationsOtherText, '') ELSE '' END)

		AS Comment
	FROM ERS_UpperGIQA as QA
	WHERE QA.ProcedureId= @ProcedureId
)
		SELECT up.ProcedureId
		, (CASE WHEN adverseEvent='Other' THEN (CASE WHEN RIGHT(O.Comment, 2)=', ' THEN LEFT(O.Comment, LEN(O.Comment)-1) ELSE O.Comment END) ELSE NULL END) AS Comment
		, adverseEvent
		FROM (SELECT ProcedureId
				--, CASE WHEN Q.ComplicationsNone		= 1 THEN 1 END AS [None]
				--## Check whether there is Any 'Other' type of Adverse Events selected!
				, (CASE WHEN (Q.DifficultIntubation=1 OR Q.DamageToScope=1 OR Q.GastricContentsAspiration=1 OR Q.ShockHypotension=1 
					OR Q.RespiratoryDepression=1 OR Q.CardiacArrythmia=1 OR Q.CardiacArrest=1 OR Q.RespiratoryArrest=1 
					OR Q.FailedIntubation=1 OR Q.PoorlyTolerated=1 OR Q.PatientDiscomfort=1 OR Q.InjuryToMouth=1 
					OR LEN(Q.TechnicalFailure)>=1 OR Q.AllergyToMedium=1 OR Q.Arcinarisation=1 OR Q.ContrastExtravasation=1 OR Q.FailedERCP=1
					OR Q.FailedCannulation=1 OR Q.FailedStentInsertion=1 OR Q.FailedERCP=1 OR Q.ComplicationsOther=1 or RespiratoryArrest = 1
					)									THEN  2 END) AS Other					
				, (CASE WHEN (Q.Haemorrhage	= 1 OR SignificantHaemorrhage = 1) THEN  5 END) AS Bleeding
				, (CASE WHEN Q.ConsentSignedInRoom	= 1 THEN  9 END) AS ConsentSignedInRoom
				, (CASE WHEN Q.Death				= 1 THEN 13 END) AS Death					
				--, CASE WHEN Q.RespiratoryArrest		= 1 THEN  6 END AS RespiratoryArrest
				, CASE WHEN (Q.Hypoxia = 1 OR Q.O2Desaturation=1) THEN 6 END AS Hypoxia	--## '20/01/2017 - Now mapped to O2 desaturation
				--, CASE WHEN Q.Oxygenation			= 1 THEN  6 END AS Oxygenation
				, CASE WHEN Q.Pancreatitis			= 1 THEN 14 END AS Pancreatitis
				, CASE WHEN Q.Perforation			= 1 THEN  4 END AS Perforation
				, CASE WHEN Q.UnplannedAdmission	= 1 THEN 11 END AS UnplannedAdmission
				, CASE WHEN Q.UnsupervisedTrainee	= 1 THEN 12 END AS UnsupervisedTrainee
				, CASE WHEN Q.Ventilation			= 1 THEN  3 END AS Ventilation
				, CASE WHEN Q.WithdrawalOfConsent	= 1 THEN 10 END AS WithdrawalOfConsent
				
			FROM  ERS_UpperGIQA Q) AS cp1
						UNPIVOT (adverseId FOR adverse IN (Bleeding, Other, ConsentSignedInRoom, Death, Hypoxia, Pancreatitis, 
															Perforation,  UnplannedAdmission, UnsupervisedTrainee, Ventilation, WithdrawalOfConsent) --ComplicationsOther, Death, CardiacArrythmia, CardiacArrest, 
						) AS up 
		INNER JOIN [dbo].[ERS_ReportAdverse] RT ON up.adverseId = RT.AdverseId
		inner join AdverseEffectsOther as O ON up.ProcedureId = O.ProcedureId
		Where Up.ProcedureId = @ProcedureId

		UNION ALL
		Select ProcedureID,
				null,
				'None'
		from ERS_UpperGIQA 
		where ComplicationsNone = 1
		and Haemorrhage = 0
		and ConsentSignedInRoom = 0
		and Death = 0
		and RespiratoryArrest = 0
		and SignificantHaemorrhage = 0
		and Hypoxia = 0
		and O2Desaturation = 0
		and Pancreatitis = 0
		and Perforation = 0
		and UnplannedAdmission = 0
		and UnsupervisedTrainee = 0
		and Ventilation = 0
		and WithdrawalOfConsent = 0
		and  ProcedureId=@ProcedureId
);

GO

-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'fnNED_GetOtherTypeTheraps', 'F';
GO
-----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[fnNED_GetOtherTypeTheraps]
(
	@ProcType		AS INT,
	@SiteId			AS INT,
	@EndRole		AS INT
)
RETURNS varchar(250)
AS
-- =============================================
-- Description:	This will Concatenate the 'Other' Type of TherapProcs which are not recognised by NED Schema.
--				So- when only 'OTHER' is passed as parameter- it will concatenate some specific theraps,
--						like: Bicap, Diathermy, Snare Excision and OTher Field's data itself
-- =============================================
BEGIN	
	DECLARE @ResultVar VARCHAR(250);

--	IF Lower(@TherapName) = 'other'
		BEGIN
			IF @ProcType=1		--## OGD / Gastroscopy
				BEGIN
					SELECT @ResultVar=(
							COALESCE((CASE WHEN T.BicapElectro = 1		THEN 'Bicap electrocautery, '		END), '') +
							COALESCE((CASE WHEN T.Diathermy = 1			THEN 'Diathermy, '			END), '') +
							COALESCE((CASE WHEN T.PyloricDilatation = 1	THEN 'Pyloric Dilatation, '	END), '') +
							COALESCE((CASE WHEN T.pHProbeInsert = 1		THEN 'pHProbe Insert, '		END), '') +
							COALESCE((CASE WHEN T.EndoClot = 1 		THEN 'Endoclot, '		END), '') +
							COALESCE((CASE WHEN T.Haemospray = 1 		THEN 'Haemospray, '		END), '') +
							COALESCE(T.Other, '')  )
						FROM [dbo].ERS_UpperGITherapeutics AS T
						INNER JOIN dbo.ERS_Sites AS S ON T.SiteId=S.SiteId
						WHERE T.SiteId = @SiteId
						  AND T.CarriedOutRole = @EndRole
						  AND (IsNUll(BicapElectro, 0)<>0 OR IsNull(Diathermy, 0)<>0 OR 
							IsNUll(PyloricDilatation, 0)<>0 OR IsNull(pHProbeInsert, 0)<>0 OR 
							IsNUll(EndoClot, 0)<>0 OR IsNull(Haemospray, 0)<>0 OR 
							LEN(IsNull(Other, '')) >= 1)
				END
			ELSE IF @ProcType = 2 --## ERCP
				BEGIN	
					SELECT 
						@ResultVar =(
						  COALESCE(CASE WHEN SnareExcision = 1 THEN 'Snare Excision, ' END, '') +
						  COALESCE(CASE WHEN YAGLaser = 1 THEN 'YAG laser, ' END, '') +
						  COALESCE(CASE WHEN ArgonBeamDiathermy = 1 THEN 'Argon beam photocoagulation, ' END, '') +
						  COALESCE(CASE WHEN BandLigation = 1 THEN 'Band ligation, ' END, '') +
						  COALESCE(CASE WHEN BotoxInjection = 1 THEN 'Botox injection, ' END, '') +
						  COALESCE(CASE WHEN EndoloopPlacement = 1 THEN 'Endoloop placement, ' END, '') +
						  COALESCE(CASE WHEN HeatProbe = 1 THEN 'Heater probe, ' END, '') +
						  COALESCE(CASE WHEN BicapElectro = 1 THEN 'Bicap electrocautery, ' END, '') +
						  COALESCE(CASE WHEN Diathermy = 1 THEN 'Diathermy , ' END, '') +
						  COALESCE(CASE WHEN ForeignBody = 1 THEN 'Foreign body removal, ' END, '') +
						  COALESCE(CASE WHEN HotBiopsy = 1 THEN 'Hot biopsy, ' END, '') +
						  COALESCE(CASE WHEN EMR = 1 THEN 'EMR, ' END, '') +
						  COALESCE(CASE WHEN Marking = 1 THEN 'Marking / tattooing, ' END, '') +
						  COALESCE(CASE WHEN Clip = 1 THEN 'Clip placement, ' END, '') +
						  COALESCE(CASE WHEN PyloricDilatation = 1 THEN 'Pyloric/duodenal dilatation, ' END, '') +
						  COALESCE(CASE WHEN StrictureDilatation = 1 THEN 'Stricture dilatation, ' END, '') +
						  COALESCE(CASE WHEN GastrostomyInsertion = 1 THEN 'Nasojejunal tube (NJT), ' END, '') +
						  COALESCE(CASE WHEN GastrostomyRemoval = 1 THEN 'Nasojejunal removal (NJT), ' END, '') +
						  COALESCE(Other, '')
						)

						FROM dbo.ERS_ERCPTherapeutics AS T
						INNER JOIN dbo.ERS_Sites AS S ON T.SiteId=S.SiteId
						WHERE T.SiteId = @SiteId AND CarriedOutRole = @EndRole
						AND (IsNUll(SnareExcision, 0)<>0 OR IsNull(YAGLaser, 0)<>0 OR 
							IsNUll(ArgonBeamDiathermy, 0)<>0 OR IsNull(BandLigation, 0)<>0 OR 
							IsNUll(BotoxInjection, 0)<>0 OR IsNull(EndoloopPlacement, 0)<>0 OR 
							IsNUll(HeatProbe, 0)<>0 OR IsNull(BicapElectro, 0)<>0 OR 
							IsNUll(Diathermy, 0)<>0 OR IsNull(ForeignBody, 0)<>0 OR 
							IsNUll(HotBiopsy, 0)<>0 OR IsNull(EMR, 0)<>0 OR 
							IsNUll(Marking, 0)<>0 OR IsNull(Clip, 0)<>0 OR 
							IsNUll(PyloricDilatation, 0)<>0 OR IsNull(GastrostomyInsertion, 0)<>0 OR 
							IsNUll(GastrostomyRemoval, 0)<>0 OR IsNull(StrictureDilatation, 0)<>0 OR 
							LEN(IsNull(Other, '')) >= 1)
												
					END				
			ELSE IF @ProcType = 3 OR @ProcType = 13 --## FLEXY/COLON
				BEGIN
					SELECT @ResultVar=(
							COALESCE((CASE WHEN T.BandLigation = 1 OR T.VaricealBanding = 1	THEN 'Band ligation, '		END), '') +
							COALESCE((CASE WHEN T.BotoxInjection = 1		THEN 'Botox injection, '		END), '') +
							COALESCE((CASE WHEN T.HeatProbe = 1		THEN 'Heater probe, '		END), '') +
							COALESCE((CASE WHEN T.BicapElectro = 1		THEN 'Bicap electrocautery, '		END), '') +
							COALESCE((CASE WHEN T.Diathermy = 1		THEN 'Diathermy, '		END), '') +
							COALESCE((CASE WHEN T.HotBiopsy = 1		THEN 'Hot biopsy, '		END), '') +
							COALESCE((CASE WHEN T.EMR = 1		THEN 'EMR, '		END), '') +
							COALESCE((CASE WHEN T.EndoClot = 1		THEN 'Endoclot, '		END), '') +
							COALESCE((CASE WHEN T.Sigmoidopexy = 1		THEN 'Sigmoidopexy, '		END), '') +
							COALESCE(T.Other, '')  )
						FROM [dbo].ERS_UpperGITherapeutics AS T
						INNER JOIN dbo.ERS_Sites AS S ON T.SiteId=S.SiteId 
						WHERE T.SiteId = @SiteId
						  AND T.CarriedOutRole = @EndRole
						  AND (IsNUll(BandLigation, 0)<>0 OR IsNull(VaricealBanding, 0)<>0 OR 
							IsNUll(BotoxInjection, 0)<>0 OR IsNull(HeatProbe, 0)<>0 OR 
							IsNUll(BicapElectro, 0)<>0 OR IsNull(Diathermy, 0)<>0 OR 
							IsNUll(HotBiopsy, 0)<>0 OR IsNull(EMR, 0)<>0 OR 
							IsNUll(EndoClot, 0)<>0 OR IsNull(Sigmoidopexy, 0)<>0 OR 
							LEN(IsNull(Other, '')) >= 1)
							
				END
		END
	
	SET @ResultVar = ltrim(rtrim(@ResultVar));
	--## Remove the Last ',' of the String; That's a virus! Bad for indigestion!
	SELECT @ResultVar= CASE 
						WHEN RIGHT(@ResultVar, 1)=',' THEN SUBSTRING(@ResultVar, 1, LEN(@ResultVar)-1)
						ELSE @ResultVar END;

	RETURN @ResultVar;
END

--################## END Function: fnNED_GetOtherTypeTheraps; Scalar Function
GO
-----------------------------------------------------------------------------------------------------------
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
		(CASE WHEN StentPerformed>Successful THEN StentPerformed ELSE Successful END) AS Successful, --## 'CTE.StentPerformed' watches on the 'Stent placement% (CBD/PAN)' Qty' for Overall level.. better accuracy!
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.Retrieved ELSE NULL END)			As Retrieved,
		Comment 
		FROM CTE
		INNER JOIN (SELECT 
						SiteId, Detected, Retrieved
						, PolypSizeText = (CASE WHEN Size IS NULL OR Size=0 THEN NULL WHEN Size<10 THEN 'ItemLessThan10mm' WHEN Size BETWEEN 10 AND 20 THEN 'Item10to19mm' ELSE 'Item20OrLargermm' END)
					FROM dbo.tvfNED_PolypsDetailsView(@ProcedureType, @ProcedureId) )AS PS ON PS.SiteId = CTE.SiteId

	
	UNION SELECT ProcedureId, ProcedureType, CTE.SiteId, Saite, [Site], NedName, EndoRole,
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.PolypSizeText ELSE NULL END)		As polypSize,
		Tattooed,
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.Detected ELSE (CASE WHEN StentPerformed>Successful THEN StentPerformed ELSE Successful END) END)		As Performed, --### Successful and Performed should be same!
		(CASE WHEN StentPerformed>Successful THEN StentPerformed ELSE Successful END) AS Successful, --## 'CTE.StentPerformed' watches on the 'Stent placement% (CBD/PAN)' Qty' for Overall level.. better accuracy!
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.Retrieved ELSE NULL END)			As Retrieved,
		Comment 
		FROM CTE
		INNER JOIN (SELECT 
						SiteId, Detected, Retrieved
						, PolypSizeText = (CASE WHEN Size IS NULL OR Size=0 THEN NULL WHEN Size<10 THEN 'ItemLessThan10mm' WHEN Size BETWEEN 10 AND 20 THEN 'Item10to19mm' ELSE 'Item20OrLargermm' END)
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
		, (CASE WHEN P.ProcedureType IN(3,13) THEN (ISNULL(EL.TimeForWithdrawalMin_Photo, EL.TimeForWithdrawalMin) + (Case When ISNULL(EL.TimeForWithdrawalSec_Photo, EL.TimeForWithdrawalSec) >30 Then 1 Else 0 End)) END	)  As '@scopeWithdrawalTime' --## Applies to Colon only
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

EXEC DropIfExist 'ercp_stentinsertions_summary', 'F'
GO

CREATE FUNCTION [dbo].[ercp_stentinsertions_summary]
(
	@TherapeuticId INT
)
RETURNS varchar(max)
AS
BEGIN

	DECLARE
			@site_id int,
			@StentInsertion INT,
			@StentInsertionQty INT,
			@StentInsertionType INT, 
			@StentInsertionLength INT,
			@StentInsertionDiameter INT,
			@StentInsertionDiameterUnits INT,
			@RadioactiveWirePlaced BIT,
			@StentInsertionBatchNo VARCHAR(50),
			@summary varchar(max)

	--get values from inserted therap record
	SELECT @site_id = ee.SiteId, @StentInsertion = ee.StentInsertion, @StentInsertionQty = ee.StentInsertionQty, @summary = ee.Summary, @RadioactiveWirePlaced = ee.RadioactiveWirePlaced, @StentInsertionBatchNo = ee.StentInsertionBatchNo FROM dbo.ERS_ERCPTherapeutics ee WHERE Id = @TherapeuticId

	DECLARE @Details varchar(max), @Count int
	
	SET @Details = ''
	SET @Count = 1
	
	DECLARE si_cursor CURSOR FOR 

	--get insertion details (loop through each record for the therap record in question)
	(SELECT
		si.TherapeuticId, si.StentInsertionType, si.StentInsertionLength, si.StentInsertionDiameter, si.StentInsertionDiameterUnits  
	FROM dbo.ERS_ERCPTherapeuticStentInsertions si 
	WHERE si.TherapeuticId = @TherapeuticId)

	OPEN si_cursor
	FETCH NEXT FROM si_cursor INTO @TherapeuticId, @StentInsertionType, @StentInsertionLength, @StentInsertionDiameter, @StentInsertionDiameterUnits

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Stent type
		IF @StentInsertionType > 0 
		BEGIN
			SET @Details = @Details + CASE WHEN @StentInsertionQty > 1 THEN '<br /> &emsp; Insertion - ' +  CONVERT(varchar(10), @Count) ELSE '' END  + ' ' + ISNULL((SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Therapeutic Stomach Stent Insertion Types' AND [ListItemNo] = @StentInsertionType),'')
		END	

		--Recorded length & diameter of stent(s) used
		IF @StentInsertionLength > 0 OR @StentInsertionDiameter > 0 
		BEGIN
			IF @StentInsertionType = 0 --theres a chance the user may have chosen other values but no insertion type... handling this or the summary output will look a mess
				SET @Details = @Details + CASE WHEN @StentInsertionQty > 1 THEN '<br /> &emsp; Insertion - ' +  CONVERT(varchar(10), @Count) ELSE '' END

			SET @Details = @Details + ' (' 
			IF @StentInsertionLength > 0 SET @Details = @Details + 'length ' + cast(@StentInsertionLength as varchar(50)) + 'cm'
			IF @StentInsertionDiameter > 0 AND @StentInsertionLength > 0 SET @Details = @Details + ', ' 
			IF @StentInsertionDiameter > 0 SET @Details = @Details + 'diameter ' + cast(@StentInsertionDiameter as varchar(50))
			----What units were used?
			IF @StentInsertionDiameter > 0 AND @StentInsertionDiameterUnits >= 0 
					SET @Details = @Details+ ' ' + ISNULL((SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilatation units' AND [ListItemNo] = @StentInsertionDiameterUnits),'')
			SET @Details = LTRIM(@Details) + ')' 
		END
		--IF @RadioactiveWirePlaced > 0  SET @Details = @Details + ', radiotherapeutic wire placed' 
		--IF ISNULL(@StentInsertionBatchNo,'') <> ''  SET @Details = @Details + ', batch ' + LTRIM(RTRIM(@StentInsertionBatchNo))

		SET @Details = @Details
		--------------
		SET @Count = @Count +1
		FETCH NEXT FROM si_cursor INTO @TherapeuticId, @StentInsertionType, @StentInsertionLength, @StentInsertionDiameter, @StentInsertionDiameterUnits
	END

	CLOSE si_cursor
	DEALLOCATE si_cursor

	RETURN @Details
END	


GO

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'trainer_trainee_select','S';
GO

CREATE PROCEDURE [dbo].[trainer_trainee_select]
(
	@ProcedureId	AS INT = 0,
	@SiteId			AS INT = 0
)
AS

SET NOCOUNT ON

SELECT 
	(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName 
		FROM ERS_Users u WHERE u.UserId = p.Endoscopist1) AS TrainerEndoscopist,
	(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName 
		FROM ERS_Users u WHERE u.UserId = p.Endoscopist2
		AND p.Endoscopist1 <> IsNull(p.Endoscopist2, 0) ) AS TraineeEndoscopist,

	ISNULL(
		CASE WHEN @SiteId > 0 AND p.ProcedureType = 2 --ERCP
				THEN (SELECT TOP 1 Id FROM dbo.ERS_ERCPTherapeutics e WHERE e.SiteId = @SiteId)
			WHEN @SiteId > 0 AND p.ProcedureType <> 2 --UpperGI..
				THEN (SELECT TOP 1 Id FROM dbo.ERS_UpperGITherapeutics u WHERE u.SiteId = @SiteId)
			ELSE 0
		END, 0) AS TherapRecordId,

	ISNULL(
		CASE WHEN @SiteId > 0 AND p.ProcedureType = 2 --ERCP
				THEN (SELECT TOP 1 EndoRole FROM dbo.ERS_ERCPTherapeutics e WHERE e.SiteId = @SiteId)
			WHEN @SiteId > 0 AND p.ProcedureType <> 2 --UpperGI..
				THEN (SELECT TOP 1 EndoRole FROM dbo.ERS_UpperGITherapeutics u WHERE u.SiteId = @SiteId)
			ELSE 0
		END, p.Endo1Role) AS EndoRole

FROM ERS_Procedures p
WHERE ProcedureId = @ProcedureID
--AND p.Endoscopist1 <> IsNull(p.Endoscopist2, 0) --AND p.Endoscopist1 > 0 AND p.Endoscopist2 > 0
GO

-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'ercp_stentinsertions_summary', 'F'
GO

CREATE FUNCTION [dbo].[ercp_stentinsertions_summary]
(
	@TherapeuticId INT
)
RETURNS varchar(max)
AS
BEGIN

	DECLARE
			@site_id int,
			@StentInsertion INT,
			@StentInsertionQty INT,
			@StentInsertionType INT, 
			@StentInsertionLength INT,
			@StentInsertionDiameter INT,
			@StentInsertionDiameterUnits INT,
			@RadioactiveWirePlaced BIT,
			@StentInsertionBatchNo VARCHAR(50),
			@summary varchar(max)

	--get values from inserted therap record
	SELECT @site_id = ee.SiteId, @StentInsertion = ee.StentInsertion, @StentInsertionQty = ee.StentInsertionQty, @summary = ee.Summary, @RadioactiveWirePlaced = ee.RadioactiveWirePlaced, @StentInsertionBatchNo = ee.StentInsertionBatchNo FROM dbo.ERS_ERCPTherapeutics ee WHERE Id = @TherapeuticId

	DECLARE @Details varchar(max), @Count int
	
	SET @Details = ''
	SET @Count = 1
	
	DECLARE si_cursor CURSOR FOR 

	--get insertion details (loop through each record for the therap record in question)
	(SELECT
		si.TherapeuticId, si.StentInsertionType, si.StentInsertionLength, si.StentInsertionDiameter, si.StentInsertionDiameterUnits  
	FROM dbo.ERS_ERCPTherapeuticStentInsertions si 
	WHERE si.TherapeuticId = @TherapeuticId)

	OPEN si_cursor
	FETCH NEXT FROM si_cursor INTO @TherapeuticId, @StentInsertionType, @StentInsertionLength, @StentInsertionDiameter, @StentInsertionDiameterUnits

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Stent type
		IF @StentInsertionType > 0 
		BEGIN
			SET @Details = @Details + CASE WHEN @StentInsertionQty > 1 THEN '<br /> &emsp; Insertion - ' +  CONVERT(varchar(10), @Count) ELSE '' END  + ' ' + ISNULL((SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Therapeutic Stomach Stent Insertion Types' AND [ListItemNo] = @StentInsertionType),'')
		END	

		--Recorded length & diameter of stent(s) used
		IF @StentInsertionLength > 0 OR @StentInsertionDiameter > 0 
		BEGIN
			IF @StentInsertionType = 0 --theres a chance the user may have chosen other values but no insertion type... handling this or the summary output will look a mess
				SET @Details = @Details + CASE WHEN @StentInsertionQty > 1 THEN '<br /> &emsp; Insertion - ' +  CONVERT(varchar(10), @Count) ELSE '' END

			SET @Details = @Details + ' (' 
			IF @StentInsertionLength > 0 SET @Details = @Details + 'length ' + cast(@StentInsertionLength as varchar(50)) + 'cm'
			IF @StentInsertionDiameter > 0 AND @StentInsertionLength > 0 SET @Details = @Details + ', ' 
			IF @StentInsertionDiameter > 0 SET @Details = @Details + 'diameter ' + cast(@StentInsertionDiameter as varchar(50))
			----What units were used?
			IF @StentInsertionDiameter > 0 AND @StentInsertionDiameterUnits >= 0 
					SET @Details = @Details+ ' ' + ISNULL((SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilatation units' AND [ListItemNo] = @StentInsertionDiameterUnits),'')
			SET @Details = LTRIM(@Details) + ')' 
		END
		--IF @RadioactiveWirePlaced > 0  SET @Details = @Details + ', radiotherapeutic wire placed' 
		--IF ISNULL(@StentInsertionBatchNo,'') <> ''  SET @Details = @Details + ', batch ' + LTRIM(RTRIM(@StentInsertionBatchNo))

		SET @Details = @Details
		--------------
		SET @Count = @Count +1
		FETCH NEXT FROM si_cursor INTO @TherapeuticId, @StentInsertionType, @StentInsertionLength, @StentInsertionDiameter, @StentInsertionDiameterUnits
	END

	CLOSE si_cursor
	DEALLOCATE si_cursor

	RETURN @Details
END	


GO

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'EveningProcedures' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
	ALTER TABLE dbo.ERS_OperatingHospitals ADD EveningProcedures BIT NOT NULL CONSTRAINT [DF_OperatingHospitals_EveningProcedures] DEFAULT 0
GO
-----------------------------------------------------------------------------------------------------------
--Missing SIG Procedure codes
IF NOT EXISTS(Select 1 from ERS_DiagnosesMatrix where ProcedureTypeID = 4 and Code IN ('S24P3', 'S10P3', 'S16P3', 'S17P3', 'S23P3', 'S84P3', 'S22P3', 'S19P3', 'S20P3', 'S21P3', 'S18P3', 'S99P3', 'S97P3', 'S98P3', 'S25P3'))
BEGIN
	insert into ERS_DiagnosesMatrix (DisplayName, ProcedureTypeID, Section, OrderByNumber, Code, NED_Include)
	Select DisplayName, 4, Section, OrderByNumber, STUFF(Code, 1, 1, 'S'), NED_Include
	from ERS_DiagnosesMatrix where ProcedureTypeID = 3 and Code IN ('D24P3', 'D10P3', 'D16P3', 'D17P3', 'D23P3', 'D84P3', 'D22P3', 'D19P3', 'D20P3', 'D21P3', 'D18P3', 'D99P3', 'D97P3', 'D98P3', 'D25P3')
END
GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'diagnoses_control_save','S';
GO

CREATE PROCEDURE [dbo].[diagnoses_control_save]
(
       @SiteID int, 
       @DiagnosesMatrixCode varchar(50),
	   @Value varchar(50)
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
	DECLARE @DiagCount int, @ProcedureID int,  @Region varchar(50), @ProcedureType int, @MatrixSection varchar(50),
		@SiteNo int, @XCoordinate int

	SELECT @ProcedureID =p.ProcedureID, @ProcedureType = p.ProcedureType, @SiteNo = SiteNo, @XCoordinate=XCoordinate
	FROM ers_sites s INNER JOIN ers_procedures p ON s.ProcedureId = p.ProcedureId 
	WHERE SiteId = @SiteID

	--Change the @DiagnosesMatrixCode if procedure type is 2 (ERCP) for Duodenum
	IF @ProcedureType = 2 AND RIGHT(@DiagnosesMatrixCode,2) <> 'P2'
	BEGIN 
		SET @DiagnosesMatrixCode = STUFF(@DiagnosesMatrixCode, LEN(@DiagnosesMatrixCode) - 1, 2, 'P2')
	END
	IF @ProcedureType = 4 AND LEFT(@DiagnosesMatrixCode,1) <> 'S'
	BEGIN
		SET @DiagnosesMatrixCode = STUFF(@DiagnosesMatrixCode, 1, 1, 'S')
	END
	
	IF @ProcedureType IN (3,4,5)   ---------- Colonoscopy, Sigmoidscopy, Proctoscopy ----------------------
	BEGIN
		SET @Region=(select x.Region from [ERS_AbnormalitiesMatrixColon] x inner join ERS_Regions r on x.region = r.Region AND r.ProcedureType= x.ProcedureType inner join ers_sites s on r.RegionId = s.RegionId where s.SiteId = @siteID )
		SET @MatrixSection= 'Colon'

		--ColonicPolyp (D12P3) should not be in region 'Rectum'
		--RectalPolyp (D4P3) should be in region 'Rectum'
		IF @DiagnosesMatrixCode IN ('D12P3') AND @Region in ('Rectum', 'Anal Margin')		SET @ProcedureID = NULL
		ELSE IF @DiagnosesMatrixCode IN ('D4P3') AND @Region not in ('Rectum', 'Anal Margin')		SET @ProcedureID = NULL
		ELSE IF @DiagnosesMatrixCode = 'D8P3' AND @Region in ('Rectum', 'Anal Margin')	SET @DiagnosesMatrixCode = 'D13P3' -- D8P3 for 'Malignant colonic tumour', D13P3 for Malignant rectal tumour
		ELSE IF @DiagnosesMatrixCode IN ('D6P3') 
			BEGIN
				IF @SiteNo = -77	AND @XCoordinate >= 17		SET @DiagnosesMatrixCode = 'D11P3' -- D6P3 for 'Benign colonic tumour', D11P3 for Benign rectal tumour
				ELSE IF @SiteNo > 0 AND @Region in ('Rectum', 'Anal Margin')		SET @DiagnosesMatrixCode = 'D11P3' -- D6P3 for 'Benign colonic tumour', D11P3 for Benign rectal tumour
			END
		ELSE IF @DiagnosesMatrixCode IN ('D15P3') 
			BEGIN
				IF @SiteNo = -77	AND @XCoordinate >= 17		SET @ProcedureID = NULL -- By distance, "Redundant anterior rectal mucosa" should be in region 'Rectum' and rectal is if the site is < 17 cm
				ELSE IF @SiteNo > 0 AND @Region not in ('Rectum', 'Anal Margin')		SET @ProcedureID = NULL -- Redundant anterior rectal mucosa (D15P3) should be in region 'Rectum'
			END
		ELSE IF @DiagnosesMatrixCode IN ('D80P3') 
			BEGIN
				IF @SiteNo = -77	AND @XCoordinate >= 17		SET @DiagnosesMatrixCode = 'D83P3' -- By distance, D80P3 for 'Rectal ulcer(s)', D83P3 for 'Colonic ulcer(s)'
				ELSE IF @SiteNo > 0 AND @Region not in ('Rectum', 'Anal Margin')	SET @DiagnosesMatrixCode = 'D83P3'   --D80P3 for 'Rectal ulcer(s)', D83P3 for 'Colonic ulcer(s)'
			END	
	END
	ELSE IF @ProcedureType IN (1, 6)	--------------- Gastroscopy, EUS (OGD) ------------------------
	BEGIN
		SET @Region = (
			SELECT x.area
			FROM ERS_AbnormalitiesMatrixUpperGI x
			INNER JOIN ERS_Regions r ON x.region = r.Region AND x.ProcedureType = r.ProcedureType AND x.ProcedureType =  @ProcedureType
			INNER JOIN ers_sites s ON r.RegionId = s.RegionId AND SiteId = @siteid  
		)
		--SET @Region = (select x.area from ERS_AbnormalitiesMatrixUpperGI x inner join ERS_Regions r on x.region = r.Region inner join ers_sites s on r.RegionId = s.RegionId where SiteId =@siteid)
		IF @DiagnosesMatrixCode = 'D20P1' AND @Region <> 'Oesophagus'	SET @DiagnosesMatrixCode = 'D61P1'
		SET @MatrixSection= ISNULL((SELECT top(1)  Section FROM [ERS_DiagnosesMatrix] WHERE ProcedureTypeID = @ProcedureType AND Code=@DiagnosesMatrixCode),@Region)

		--Varices (D30P1) should be in region 'Oesophagus'
		--StomachVarices (D47P1) should be in region 'Stomach'
		--TelangiectasiaAngioma (D59P1) should be in region 'Duodenum'
		IF @DiagnosesMatrixCode = 'D30P1' AND @Region <> 'Oesophagus'		SET @ProcedureID = NULL
		ELSE IF @DiagnosesMatrixCode = 'D31P1' AND @Region <> 'Oesophagus'	SET @ProcedureID = NULL
		ELSE IF @DiagnosesMatrixCode = 'D47P1' AND @Region <> 'Stomach'		SET @ProcedureID = NULL
		ELSE IF @DiagnosesMatrixCode = 'D59P1' AND @Region <> 'Duodenum'	SET @ProcedureID = NULL

		--Remove noraml procedure diagnoses entry where applicapble
		IF LOWER(@Value) IN ('true', '1')
		BEGIN
			IF EXISTS (SELECT 1 FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureID AND MatrixCode = 'OverallNormal')
				DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureID AND MatrixCode = 'OverallNormal'
		END			

	END
	ELSE IF @ProcedureType IN (2, 7)	------------ ERCP, EUS(HPB) --------------------------
	BEGIN
		SET @Region = (
			SELECT x.area
			FROM ERS_AbnormalitiesMatrixERCP x
			INNER JOIN ERS_Regions r ON x.region = r.Region AND x.ProcedureType = r.ProcedureType AND x.ProcedureType =  @ProcedureType
			INNER JOIN ers_sites s ON r.RegionId = s.RegionId AND SiteId = @siteid  
		)
		--SET @Region = (select x.area from ERS_AbnormalitiesMatrixERCP x inner join ERS_Regions r on x.region = r.Region inner join ers_sites s on r.RegionId = s.RegionId where SiteId =@siteid)
		SET @MatrixSection= ISNULL((SELECT top(1)  Section FROM [ERS_DiagnosesMatrix] WHERE ProcedureTypeID = @ProcedureType AND Code=@DiagnosesMatrixCode),@Region)
	END

	IF @ProcedureID IS NULL GOTO RETURN_NULL

	--Check for correct Procedure Type
	IF CHARINDEX('notentered',LOWER(@DiagnosesMatrixCode)) = 0 AND NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE ProcedureTypeID = @ProcedureType AND Code = @DiagnosesMatrixCode) GOTO RETURN_NULL

	--Set correct region for not entered codes
	IF CHARINDEX('notentered',LOWER(@DiagnosesMatrixCode)) > 0
	BEGIN
		SET @siteid = NULL
		SELECT @MatrixSection = 
		CASE LOWER(@DiagnosesMatrixCode)
			WHEN 'stomachnotentered' THEN 'Stomach'
			WHEN 'duodenumnotentered' THEN 'Duodenum'
		END
	END

	IF LOWER(@Value) NOT IN ('true', '1') SET @Value = 'False'

	IF @Value = 'False'
	BEGIN
		DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode= @DiagnosesMatrixCode AND (SiteId = @siteid OR ISNULL(@siteid,'') = '')
	END
	ELSE
	BEGIN
		UPDATE [ERS_Diagnoses] SET [Value] = @Value, Region = @MatrixSection 
		WHERE ProcedureID = @ProcedureID AND MatrixCode= @DiagnosesMatrixCode
		AND (SiteId = @siteid OR ISNULL(@siteid,'') = '')

		IF @@ROWCOUNT=0 
		BEGIN
			--No records found in ERS_Diagnoses when updating, go ahead and insert it
			INSERT INTO [ERS_Diagnoses] (ProcedureID, SiteID, MatrixCode, [Value], [Region]) 
			VALUES (@ProcedureID, @SiteID, @DiagnosesMatrixCode,@Value,@MatrixSection) 
		END
	END

	EXEC ogd_diagnoses_summary_update @ProcedureID

	RETURN_NULL:
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
-- BUG 185
Exec DropIfExist 'TR_ColonAbnoLesions', 'TR'
  GO
  Create TRIGGER [dbo].[TR_ColonAbnoLesions]
ON [dbo].[ERS_ColonAbnoLesions]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @ColonicPolyp VARCHAR(10), @RectalPolyp VARCHAR(10), @ColorectalCancer VARCHAR(10), @BenignTumour VARCHAR(10),
			 @ProbablyMalignantTumour VARCHAR(10), @Tumour VARCHAR(10)

	IF EXISTS(SELECT * FROM INSERTED)
	BEGIN
		SELECT @site_id=SiteId,
				@ColonicPolyp = (CASE WHEN (Sessile=1 OR Pedunculated=1 OR Pseudopolyps = 1) THEN 'True' ELSE 'False' END),
				@RectalPolyp = (CASE WHEN (Sessile=1 OR Pedunculated=1 OR Pseudopolyps = 1) THEN 'True' ELSE 'False' END),
				@ColorectalCancer = (CASE WHEN ((Submucosal=1  AND SubmucosalProbably<>1 AND SubmucosalType=2) OR (Villous=1 AND VillousProbably<>1 AND VillousType=2) OR 
					(Ulcerative=1 AND UlcerativeProbably<>1 AND UlcerativeType=2) Or (Stricturing=1 AND StricturingProbably<>1 AND StricturingType=2) 
					OR (Polypoidal=1 AND PolypoidalProbably<>1 AND PolypoidalType=2)) THEN 'True' ELSE 'False' END),
				@ProbablyMalignantTumour = (CASE WHEN ((Submucosal=1  AND SubmucosalProbably=1 AND SubmucosalType=2) OR (Villous=1 AND VillousProbably=1 AND VillousType=2) OR 
					(Ulcerative=1 AND UlcerativeProbably=1 AND UlcerativeType=2) Or (Stricturing=1 AND StricturingProbably=1 AND StricturingType=2) 
					OR (Polypoidal=1 AND PolypoidalProbably=1 AND PolypoidalType=2)) THEN 'True' ELSE 'False' END),
				@BenignTumour = (CASE WHEN ((Submucosal=1 AND SubmucosalType=1) OR (Villous=1 AND VillousType=1) OR 
					(Ulcerative=1 AND UlcerativeType=1) Or (Stricturing=1 AND StricturingType=1) 
					OR (Polypoidal=1 AND PolypoidalType=1) OR (PneumatosisColi = 1) OR (Dysplastic = 1 AND DysplasticQuantity >0) 
					OR (Granuloma = 1 AND GranulomaQuantity > 0)) THEN 'True' ELSE 'False' END),
				@Tumour = (CASE WHEN ((Submucosal=1 AND SubmucosalType=0) OR (Villous=1 AND VillousType=0) OR 
					(Ulcerative=1 AND UlcerativeType=0) Or (Stricturing=1 AND StricturingType=0) 
					OR (Polypoidal=1 AND PolypoidalType=0) OR (PneumatosisColi = 1) OR (Dysplastic = 1 AND DysplasticQuantity >0) 
					OR (Granuloma = 1 AND GranulomaQuantity > 0)) THEN 'True' ELSE 'False' END)
		FROM INSERTED
		EXEC abnormalities_colon_lesions_summary_update @site_id
	END
	ELSE
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	IF @site_id IS NOT NULL
	BEGIN
		EXEC sites_summary_update @site_id
		EXEC diagnoses_control_save @site_id, 'D12P3', @ColonicPolyp			-- 'ColonicPolyp'
		EXEC diagnoses_control_save @site_id, 'D4P3', @RectalPolyp				-- 'RectalPolyp'
		EXEC diagnoses_control_save @site_id, 'D69P3', @ColorectalCancer		-- 'Colorectal cancer'
		EXEC diagnoses_control_save @site_id, 'D6P3', @BenignTumour				-- 'Benign colonic tumour'
		EXEC diagnoses_control_save @site_id, 'D8P3', @ProbablyMalignantTumour	-- 'Malignant colonic tumour'
		EXEC diagnoses_control_save @site_id, 'D10P3', @Tumour	-- 'Malignant colonic tumour'
	END

GO
-----------------------------------------------------------------------------------------------------------
UPDATE ers_requiredfields SET required = 0 WHERE pagename='Diagnoses'
-----------------------------------------------------------------------------------------------------------
UPDATE dbo.ERS_ProcedureTypes SET ProcedureType = 'Sigmoidoscopy' WHERE ProcedureTypeId=4
-----------------------------------------------------------------------------------------------------------
