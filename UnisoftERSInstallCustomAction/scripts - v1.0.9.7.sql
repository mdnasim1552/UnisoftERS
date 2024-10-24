SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC DropIfExist 'therapeutics_ogd_summary_update', 'S';
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
		@EUSProcType smallint;

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
				@GastrostomyInsertionBatchNo	= (CASE WHEN IsNull(ER.[GastrostomyInsertionBatchNo], '') = '' THEN EE.[GastrostomyInsertionBatchNo] ELSE ER.[GastrostomyInsertionBatchNo] END),
				@CorrectPEGPlacement			= (CASE WHEN IsNull(ER.[CorrectPEGPlacement], 0) = 0 THEN EE.[CorrectPEGPlacement] ELSE ER.[CorrectPEGPlacement] END),
				@PEGPlacementFailureReason		= (CASE WHEN IsNull(ER.[PEGPlacementFailureReason], '') = '' THEN EE.[PEGPlacementFailureReason] ELSE ER.[PEGPlacementFailureReason] END),
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
				@StentPlacementFailureReason	= (CASE WHEN IsNull(ER.[StentPlacementFailureReason], '') = '' THEN EE.[StentPlacementFailureReason] ELSE ER.[StentPlacementFailureReason] END),
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
				@Other							= (CASE WHEN IsNull(ER.[Other], '') = '' THEN EE.[Other] ELSE ER.[Other] END),
				@EUSProcType					= (CASE WHEN IsNull(ER.[EUSProcType], 0) = 0 THEN EE.[EUSProcType] ELSE ER.[EUSProcType] END) 
			FROM eeRecord AS EE
	  INNER JOIN #tmp_UpperGITherapeutics AS ER ON EE.SiteId = ER.SiteId
			WHERE ER.CarriedOutRole = 1; --## 1 is ER
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
	WHERE SiteId = @SiteId AND CarriedOutRole=1;	--### Summary text is Applicable only for TrainER....
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
					SET @Summary = @Summary + ' for ' + CONVERT(varchar, @OesoDilXRayHrs)
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
----------------------------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'abnormalities_colon_lesions_summary_update','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_colon_lesions_summary_update]
(
	@SiteId INT
)
AS
SET NOCOUNT ON
	
DECLARE 
	@summary VARCHAR (8000),
	@tempsummary VARCHAR (1000),
	@None BIT,
	@Sessile BIT,
	@SessileQuantity INT,
	@SessileLargest INT,
	@SessileExcised INT,
	@SessileRetrieved INT,
	@SessileToLabs INT,
	@SessileRemoval TINYINT,
	@SessileRemovalMethod TINYINT,
	@SessileProbably BIT,
	@SessileType TINYINT,
	@SessileParisClass TINYINT,
	@SessilePitPattern TINYINT,
	@Pedunculated BIT,
	@PedunculatedQuantity INT,
	@PedunculatedLargest INT,
	@PedunculatedExcised INT,
	@PedunculatedRetrieved INT,
	@PedunculatedToLabs INT,
	@PedunculatedRemoval TINYINT,
	@PedunculatedRemovalMethod TINYINT,
	@PedunculatedProbably BIT,
	@PedunculatedType TINYINT,
	@PedunculatedParisClass TINYINT,
	@PedunculatedPitPattern TINYINT,
	@Pseudopolyps BIT,
	@PseudopolypsMultiple BIT,
	@PseudopolypsQuantity INT,
	@PseudopolypsLargest INT,
	@PseudopolypsExcised INT,
	@PseudopolypsRetrieved INT,
	@PseudopolypsToLabs INT,
	@PseudopolypsInflam BIT,
	@PseudopolypsPostInflam BIT,
	@PseudopolypsRemoval TINYINT,
	@PseudopolypsRemovalMethod TINYINT,
	@Submucosal BIT,
	@SubmucosalQuantity INT,
	@SubmucosalLargest INT,
	@SubmucosalProbably BIT,
	@SubmucosalType TINYINT,
	@Villous BIT,
	@VillousQuantity INT,
	@VillousLargest INT,
	@VillousProbably BIT,
	@VillousType TINYINT,
	@Ulcerative BIT,
	@UlcerativeQuantity INT,
	@UlcerativeLargest INT,
	@UlcerativeProbably BIT,
	@UlcerativeType TINYINT,
	@Stricturing BIT,
	@StricturingQuantity INT,
	@StricturingLargest INT,
	@StricturingProbably BIT,
	@StricturingType TINYINT,
	@Polypoidal BIT,
	@PolypoidalQuantity INT,
	@PolypoidalLargest INT,
	@PolypoidalProbably BIT,
	@PolypoidalType TINYINT,
	@Granuloma BIT,
	@GranulomaQuantity INT,
	@GranulomaLargest INT,
	@Dysplastic BIT,
	@DysplasticQuantity INT,
	@DysplasticLargest INT,
	@PneumatosisColi BIT,
	@Tattooed BIT,
	@PreviouslyTattooed BIT,
	@TattooType INT,
	@TattooedQty INT

SET @summary = ''
SET @tempsummary = ''

SELECT 
	@None=[None],
	@Sessile=Sessile,
	@SessileQuantity=SessileQuantity,
	@SessileLargest=SessileLargest,
	@SessileExcised=SessileExcised,
	@SessileRetrieved=SessileRetrieved,
	@SessileToLabs=SessileToLabs,
	@SessileRemoval=SessileRemoval,
	@SessileRemovalMethod=SessileRemovalMethod,
	@SessileProbably=SessileProbably,
	@SessileType=SessileType,
	@SessileParisClass=SessileParisClass,
	@SessilePitPattern=SessilePitPattern,
	@Pedunculated=Pedunculated,
	@PedunculatedQuantity=PedunculatedQuantity,
	@PedunculatedLargest=PedunculatedLargest,
	@PedunculatedExcised=PedunculatedExcised,
	@PedunculatedRetrieved=PedunculatedRetrieved,
	@PedunculatedToLabs=PedunculatedToLabs,
	@PedunculatedRemoval=PedunculatedRemoval,
	@PedunculatedRemovalMethod=PedunculatedRemovalMethod,
	@PedunculatedProbably=PedunculatedProbably,
	@PedunculatedType=PedunculatedType,
	@PedunculatedParisClass=PedunculatedParisClass,
	@PedunculatedPitPattern=PedunculatedPitPattern,
	@Pseudopolyps=Pseudopolyps,
	@PseudopolypsMultiple=PseudopolypsMultiple,
	@PseudopolypsQuantity=PseudopolypsQuantity,
	@PseudopolypsLargest=PseudopolypsLargest,
	@PseudopolypsExcised=PseudopolypsExcised,
	@PseudopolypsRetrieved=PseudopolypsRetrieved,
	@PseudopolypsToLabs=PseudopolypsToLabs,
	@PseudopolypsInflam=PseudopolypsInflam,
	@PseudopolypsPostInflam=PseudopolypsPostInflam,
	@PseudopolypsRemoval=PseudopolypsRemoval,
	@PseudopolypsRemovalMethod=PseudopolypsRemovalMethod,
	@Submucosal=Submucosal,
	@SubmucosalQuantity=SubmucosalQuantity,
	@SubmucosalLargest=SubmucosalLargest,
	@SubmucosalProbably=SubmucosalProbably,
	@SubmucosalType=SubmucosalType,
	@Villous=Villous,
	@VillousQuantity=VillousQuantity,
	@VillousLargest=VillousLargest,
	@VillousProbably=VillousProbably,
	@VillousType=VillousType,
	@Ulcerative=Ulcerative,
	@UlcerativeQuantity=UlcerativeQuantity,
	@UlcerativeLargest=UlcerativeLargest,
	@UlcerativeProbably=UlcerativeProbably,
	@UlcerativeType=UlcerativeType,
	@Stricturing=Stricturing,
	@StricturingQuantity=StricturingQuantity,
	@StricturingLargest=StricturingLargest,
	@StricturingProbably=StricturingProbably,
	@StricturingType=StricturingType,
	@Polypoidal=Polypoidal,
	@PolypoidalQuantity=PolypoidalQuantity,
	@PolypoidalLargest=PolypoidalLargest,
	@PolypoidalProbably=PolypoidalProbably,
	@PolypoidalType=PolypoidalType,
	@Granuloma=Granuloma,
	@GranulomaQuantity=GranulomaQuantity,
	@GranulomaLargest=GranulomaLargest,
	@Dysplastic=Dysplastic,
	@DysplasticQuantity=DysplasticQuantity,
	@DysplasticLargest=DysplasticLargest,
	@PneumatosisColi=PneumatosisColi,
	@Tattooed = Tattooed,
	@PreviouslyTattooed = PreviouslyTattooed,
	@TattooType = TattooType,
	@TattooedQty = TattooedQuantity
FROM
	ERS_ColonAbnoLesions
WHERE
	SiteId = @SiteId

SET @Summary = ''


IF @None = 1 SET @summary = 'No lesions'

ELSE
BEGIN
	------------------------------------------------------------------------------------------
	-------	SESSILE	-------
	------------------------------------------------------------------------------------------
	IF @Sessile > 0
	BEGIN
		IF @SessileQuantity > 0 SET @summary = @summary + CONVERT(VARCHAR(20), @SessileQuantity) + ' '
		
		IF @SessileProbably = 1 SET @summary = @summary + 'probably '

		IF @SessileType = 1 SET @summary = @summary + 'benign '
		ELSE IF @SessileType = 2 SET @summary = @summary + 'malignant '

		IF @SessileQuantity > 1 SET @summary = @summary + 'sessile polyps ' ELSE SET @summary = @summary + 'sessile polyp ' 

		IF (@SessileQuantity > 0 AND @SessileLargest > 0) 
		BEGIN
			IF @SessileQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @SessileLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @SessileLargest) + 'mm) '
		END

		IF @SessileParisClass > 0 OR @SessilePitPattern > 0
		BEGIN
			SET @summary = @summary + '('

			IF @SessileParisClass > 0 
			SET @summary = @summary +
                     CASE @SessileParisClass
                           WHEN  1 THEN 'Paris Is'
                           WHEN  2 THEN 'Paris IIa'
                           WHEN  3 THEN 'Paris IIa + IIc'
                           WHEN 4 THEN 'Paris IIb'
                           WHEN  5 THEN 'Paris IIc'
                           WHEN  6 THEN 'Paris IIc + IIa'
                           ELSE ''
			END

			IF @SessilePitPattern > 0 
			BEGIN
				IF @SessileParisClass > 0 SET @summary = @summary + ', '
				
				SET @summary = @summary +
                           CASE @SessilePitPattern
                                  WHEN  1 THEN 'pit type I'
                                  WHEN 2 THEN 'pit type II'
                                  WHEN  3 THEN 'pit type IIIs'
                                  WHEN  4 THEN 'pit type IIIL'
                                  WHEN  5 THEN 'pit type IV'
                                  WHEN  6 THEN 'pit type V'
					ELSE ''
				END
			END

			SET @summary = @summary + ')'
		END

		IF @SessileExcised > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @SessileExcised <> @SessileQuantity SET @summary = @summary + CONVERT(VARCHAR(20), @SessileExcised) + ' '
			SET @summary = @summary + 'excised '

			IF @SessileRemoval > 0 OR @SessileRemovalMethod > 0
			BEGIN
				SET @summary = @summary + '(removed '
				
				IF @SessileRemoval = 1 SET @summary = @summary + 'entirely '
				ELSE IF @SessileRemoval = 2 SET @summary = @summary + 'piecemeal '
				
				IF @SessileRemovalMethod = 1 SET @summary = @summary + 'using partial snare'
				ELSE IF @SessileRemovalMethod = 2 SET @summary = @summary + 'using cold snare'
				ELSE IF @SessileRemovalMethod = 3 SET @summary = @summary + 'using hot snare'
				ELSE IF @SessileRemovalMethod = 4 SET @summary = @summary + 'using hot biopsy'
				ELSE IF @SessileRemovalMethod = 5 SET @summary = @summary + 'using cold biopsy'
				ELSE IF @SessileRemovalMethod =	6 SET @summary = @summary + 'using hot snare by EMR'
				ELSE IF @SessileRemovalMethod =	7 SET @summary = @summary + 'using cold snare by EMR'
					
				SET @summary = @summary + ')'
			END
		END

		IF @SessileRetrieved > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @SessileRetrieved <> @SessileExcised SET @summary = @summary + CONVERT(VARCHAR(20), @SessileRetrieved) + ' '
			SET @summary = @summary + 'retrieved '
		END

		IF @SessileToLabs > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @SessileToLabs <> @SessileRetrieved SET @summary = @summary + CONVERT(VARCHAR(20), @SessileToLabs) + ' '
			SET @summary = @summary + 'sent to labs '
		END

		-- Set the last occurence of $$ to "and"
		IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 3, ' and')
		-- Replace all other occurences of $$ with commas
		SET @summary = REPLACE(@summary, '$$', ',')
	END

	------------------------------------------------------------------------------------------
	-------	PEDUNCULATED -------
	------------------------------------------------------------------------------------------
	ELSE IF @Pedunculated > 0
	BEGIN
		IF @PedunculatedQuantity > 0 SET @summary = @summary + CONVERT(VARCHAR(20), @PedunculatedQuantity) + ' '
		
		IF @PedunculatedProbably = 1 SET @summary = @summary + 'probably '

		IF @PedunculatedType = 1 SET @summary = @summary + 'benign '
		ELSE IF @PedunculatedType = 2 SET @summary = @summary + 'malignant '

		IF @PedunculatedQuantity > 1 SET @summary = @summary + 'pedunculated polyps ' ELSE SET @summary = @summary + 'pedunculated polyp ' 

		IF (@PedunculatedQuantity > 0 AND @PedunculatedLargest > 0) 
		BEGIN
			IF @PedunculatedQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @PedunculatedLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @PedunculatedLargest) + 'mm) '
		END

		IF @PedunculatedParisClass > 0 OR @PedunculatedPitPattern > 0
		BEGIN
			SET @summary = @summary + '('

			IF @PedunculatedParisClass > 0 
			SET @summary = @summary +
			CASE 
                           WHEN @PedunculatedParisClass = 1 THEN 'Ip'
                           WHEN @PedunculatedParisClass = 2 THEN 'Isp'
				ELSE ''
			END

			IF @PedunculatedPitPattern > 0 
			BEGIN
				IF @PedunculatedParisClass > 0 SET @summary = @summary + ', '
				
				SET @summary = @summary +
				CASE 
					WHEN @PedunculatedPitPattern = 1 THEN 'pit type I'
					WHEN @PedunculatedPitPattern = 2 THEN 'pit type II'
					WHEN @PedunculatedPitPattern = 3 THEN 'pit type IIIs'
					WHEN @PedunculatedPitPattern = 4 THEN 'pit type IIIL'
					WHEN @PedunculatedPitPattern = 5 THEN 'pit type IV'
					WHEN @PedunculatedPitPattern = 6 THEN 'pit type V'
					ELSE ''
				END
			END

			SET @summary = @summary + ')'
		END

		IF @PedunculatedExcised > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @PedunculatedExcised <> @PedunculatedQuantity SET @summary = @summary + CONVERT(VARCHAR(20), @PedunculatedExcised) + ' '
			SET @summary = @summary + 'excised '

			IF @PedunculatedRemoval > 0 OR @PedunculatedRemovalMethod > 0
			BEGIN
				SET @summary = @summary + '(removed '
				
				IF @PedunculatedRemoval = 1 SET @summary = @summary + 'entirely '
				ELSE IF @PedunculatedRemoval = 2 SET @summary = @summary + 'piecemeal '
				
				IF @PedunculatedRemovalMethod = 1 SET @summary = @summary + 'using partial snare'
				ELSE IF @PedunculatedRemovalMethod = 2 SET @summary = @summary + 'using cold snare'
				ELSE IF @PedunculatedRemovalMethod = 3 SET @summary = @summary + 'using hot snare'
				ELSE IF @PedunculatedRemovalMethod = 4 SET @summary = @summary + 'using hot biopsy'
				ELSE IF @PedunculatedRemovalMethod = 5 SET @summary = @summary + 'using cold biopsy'
				ELSE IF @PedunculatedRemovalMethod = 6 SET @summary = @summary + 'using hot snare by EMR'
				ELSE IF @PedunculatedRemovalMethod = 7 SET @summary = @summary + 'using cold snare by EMR'
				
				SET @summary = @summary + ')'
			END
		END

		IF @PedunculatedRetrieved > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @PedunculatedRetrieved <> @PedunculatedExcised SET @summary = @summary + CONVERT(VARCHAR(20), @PedunculatedRetrieved) + ' '
			SET @summary = @summary + 'retrieved '
		END

		IF @PedunculatedToLabs > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @PedunculatedToLabs <> @PedunculatedRetrieved SET @summary = @summary + CONVERT(VARCHAR(20), @PedunculatedToLabs) + ' '
			SET @summary = @summary + 'sent to labs '
		END

		-- Set the last occurence of $$ to "and"
		IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 3, ' and')
		-- Replace all other occurences of $$ with commas
		SET @summary = REPLACE(@summary, '$$', ',')
	END

	------------------------------------------------------------------------------------------
	-------	PSEUDOPOLYPS -------
	------------------------------------------------------------------------------------------
	ELSE IF @Pseudopolyps > 0
	BEGIN
		IF @PseudopolypsQuantity > 0 SET @summary = @summary + CONVERT(VARCHAR(20), @PseudopolypsQuantity) + ' '
		ELSE IF @PseudopolypsMultiple = 1 SET @summary = @summary + 'multiple '

		IF @PseudopolypsInflam = 1 AND @PseudopolypsPostInflam = 0 SET @summary = @summary + 'inflammatory '
		ELSE IF @PseudopolypsInflam = 0 AND @PseudopolypsPostInflam = 1 SET @summary = @summary + 'post-inflammatory '
		ELSE IF @PseudopolypsInflam = 1 AND @PseudopolypsPostInflam = 1 SET @summary = @summary + 'inflammatory and post-inflammatory '
		
		IF (@PseudopolypsQuantity > 1 OR @PseudopolypsMultiple = 1) SET @summary = @summary + 'pseudopolyps ' ELSE SET @summary = @summary + 'pseudopolyp ' 

		IF (@PseudopolypsQuantity > 0 AND @PseudopolypsLargest > 0) 
		BEGIN
			IF @PseudopolypsQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @PseudopolypsLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @PseudopolypsLargest) + 'mm) '
		END

		IF @PseudopolypsExcised > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @PseudopolypsExcised <> @PseudopolypsQuantity SET @summary = @summary + CONVERT(VARCHAR(20), @PseudopolypsExcised) + ' '
			SET @summary = @summary + 'excised '

			IF @PseudopolypsRemoval > 0 OR @PseudopolypsRemovalMethod > 0
			BEGIN
				SET @summary = @summary + '(removed '
				
				IF @PseudopolypsRemoval = 1 SET @summary = @summary + 'entirely '
				ELSE IF @PseudopolypsRemoval = 2 SET @summary = @summary + 'piecemeal '
				
				IF @PseudopolypsRemovalMethod = 1 SET @summary = @summary + 'using partial snare'
				ELSE IF @PseudopolypsRemovalMethod = 2 SET @summary = @summary + 'using cold snare'
				ELSE IF @PseudopolypsRemovalMethod = 3 SET @summary = @summary + 'using hot snare'
				ELSE IF @PseudopolypsRemovalMethod = 4 SET @summary = @summary + 'using hot biopsy'
				ELSE IF @PseudopolypsRemovalMethod = 5 SET @summary = @summary + 'using cold biopsy'
				ELSE IF @PseudopolypsRemovalMethod = 6 SET @summary = @summary + 'using hot snare by EMR'
				ELSE IF @PseudopolypsRemovalMethod = 7 SET @summary = @summary + 'using cold snare by EMR'

				SET @summary = @summary + ')'
			END
		END

		IF @PseudopolypsRetrieved > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @PseudopolypsRetrieved <> @PseudopolypsExcised SET @summary = @summary + CONVERT(VARCHAR(20), @PseudopolypsRetrieved) + ' '
			SET @summary = @summary + 'retrieved '
		END

		IF @PseudopolypsToLabs > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @PseudopolypsToLabs <> @PseudopolypsRetrieved SET @summary = @summary + CONVERT(VARCHAR(20), @PseudopolypsToLabs) + ' '
			SET @summary = @summary + 'sent to labs '
		END

		-- Set the last occurence of $$ to "and"
		IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 3, ' and')
		-- Replace all other occurences of $$ with commas
		SET @summary = REPLACE(@summary, '$$', ',')
	END

	------------------------------------------------------------------------------------------
	-------	TUMOUR: SUBMUCOSAL -------
	------------------------------------------------------------------------------------------
	IF @Submucosal > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		IF @SubmucosalQuantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @SubmucosalQuantity) + ' '
		ELSE SET @summary = @summary + 'A '
		
		IF @SubmucosalProbably = 1 SET @summary = @summary + 'probably '

		IF @SubmucosalType = 1 SET @summary = @summary + 'benign '
		ELSE IF @SubmucosalType = 2 SET @summary = @summary + 'malignant '

		IF @SubmucosalQuantity > 1 SET @summary = @summary + 'submucosal tumours ' ELSE SET @summary = @summary + 'submucosal tumour ' 

		IF (@SubmucosalQuantity > 0 AND @SubmucosalLargest > 0) 
		BEGIN
			IF @SubmucosalQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @SubmucosalLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @SubmucosalLargest) + 'mm) '
		END
	END

	------------------------------------------------------------------------------------------
	-------	TUMOUR: VILLOUS -------
	------------------------------------------------------------------------------------------
	IF @Villous > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		IF @VillousQuantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @VillousQuantity) + ' '
		ELSE SET @summary = @summary + 'A '
		
		IF @VillousProbably = 1 SET @summary = @summary + 'probably '

		IF @VillousType = 1 SET @summary = @summary + 'benign '
		ELSE IF @VillousType = 2 SET @summary = @summary + 'malignant '

		IF @VillousQuantity > 1 SET @summary = @summary + 'villous tumours ' ELSE SET @summary = @summary + 'villous tumour ' 

		IF (@VillousQuantity > 0 AND @VillousLargest > 0) 
		BEGIN
			IF @VillousQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @VillousLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @VillousLargest) + 'mm) '
		END
	END

	------------------------------------------------------------------------------------------
	-------	TUMOUR: ULCERATIVE -------
	------------------------------------------------------------------------------------------
	IF @Ulcerative > 0
	BEGIN
		DECLARE @UlcerSummary VARCHAR(300) = ''
		IF @summary <> '' SET @summary = @summary + '##'

		IF @UlcerativeQuantity > 1 SET @UlcerSummary = @UlcerSummary + CONVERT(VARCHAR(20), @UlcerativeQuantity) + ' '
		
		IF @UlcerativeProbably = 1 SET @UlcerSummary = @UlcerSummary + 'probably '

		IF @UlcerativeType = 1 SET @UlcerSummary = @UlcerSummary + 'benign '
		ELSE IF @UlcerativeType = 2 SET @UlcerSummary = @UlcerSummary + 'malignant '

		IF @UlcerativeQuantity > 1 SET @UlcerSummary = @UlcerSummary + 'ulcerative tumours ' ELSE SET @UlcerSummary = @UlcerSummary + 'ulcerative tumour ' 

		IF LEFT(@UlcerSummary,1) = 'u' SET @UlcerSummary =  'An ' + @UlcerSummary
		ELSE IF ISNULL(@UlcerativeQuantity,0) <= 1 SET @UlcerSummary =  'A ' + @UlcerSummary

		IF (@UlcerativeQuantity > 0 AND @UlcerativeLargest > 0) 
		BEGIN
			IF @UlcerativeQuantity > 1
				SET @UlcerSummary = @UlcerSummary + '(largest ' + CONVERT(VARCHAR(20), @UlcerativeLargest) + 'mm) '
			ELSE
				SET @UlcerSummary = @UlcerSummary + '(' + CONVERT(VARCHAR(20), @UlcerativeLargest) + 'mm) '
		END

		SET @summary = @summary + @UlcerSummary
	END

	------------------------------------------------------------------------------------------
	-------	TUMOUR: STRICTURING -------
	------------------------------------------------------------------------------------------
	IF @Stricturing > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		IF @StricturingQuantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @StricturingQuantity) + ' '
		ELSE SET @summary = @summary + 'A '
		
		IF @StricturingProbably = 1 SET @summary = @summary + 'probably '

		IF @StricturingType = 1 SET @summary = @summary + 'benign '
		ELSE IF @StricturingType = 2 SET @summary = @summary + 'malignant '

		IF @StricturingQuantity > 1 SET @summary = @summary + 'stricturing tumours ' ELSE SET @summary = @summary + 'stricturing tumour ' 

		IF (@StricturingQuantity > 0 AND @StricturingLargest > 0) 
		BEGIN
			IF @StricturingQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @StricturingLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @StricturingLargest) + 'mm) '
		END
	END

	------------------------------------------------------------------------------------------
	-------	TUMOUR: POLYPOIDAL -------
	------------------------------------------------------------------------------------------
	IF @Polypoidal > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		IF @PolypoidalQuantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @PolypoidalQuantity) + ' '
		ELSE SET @summary = @summary + 'A '
		
		IF @PolypoidalProbably = 1 SET @summary = @summary + 'probably '

		IF @PolypoidalType = 1 SET @summary = @summary + 'benign '
		ELSE IF @PolypoidalType = 2 SET @summary = @summary + 'malignant '

		IF @PolypoidalQuantity > 1 SET @summary = @summary + 'polypoidal tumours ' ELSE SET @summary = @summary + 'polypoidal tumour ' 

		IF (@PolypoidalQuantity > 0 AND @PolypoidalLargest > 0) 
		BEGIN
			IF @PolypoidalQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @PolypoidalLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @PolypoidalLargest) + 'mm) '
		END
	END

	------------------------------------------------------------------------------------------
	-------	SUTURE GRANULOMA -------
	------------------------------------------------------------------------------------------
	IF @Granuloma > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		IF @GranulomaQuantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @GranulomaQuantity) + ' '
		ELSE SET @summary = @summary + 'A '
		
		IF @GranulomaQuantity > 1 SET @summary = @summary + 'granuloma tumours ' ELSE SET @summary = @summary + 'granuloma tumour ' 

		IF (@GranulomaQuantity > 0 AND @GranulomaLargest > 0) 
		BEGIN
			IF @GranulomaQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @GranulomaLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @GranulomaLargest) + 'mm) '
		END
	END

	------------------------------------------------------------------------------------------
	-------	DYSPLASTIC LESION -------
	------------------------------------------------------------------------------------------
	IF @Dysplastic > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		IF @DysplasticQuantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @DysplasticQuantity) + ' '
		ELSE SET @summary = @summary + 'A '
		
		IF @DysplasticQuantity > 1 SET @summary = @summary + 'dysplastic tumours ' ELSE SET @summary = @summary + 'dysplastic tumour ' 

		IF (@DysplasticQuantity > 0 AND @DysplasticLargest > 0) 
		BEGIN
			IF @DysplasticQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @DysplasticLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @DysplasticLargest) + 'mm) '
		END

	END

	------------------------------------------------------------------------------------------
	-------	PNEUMATOSIS COLI -------
	------------------------------------------------------------------------------------------
	IF @PneumatosisColi > 0
		BEGIN
			IF @summary <> '' SET @summary = @summary + '##'

			SET @summary = @summary + 'pneumatosis coli '
		END
	END	
	
	------------------------------------------------------------------------------------------
	-------	POLYPS TATTOO ----------
	------------------------------------------------------------------------------------------
	IF @Tattooed > 0 
	BEGIN
		DECLARE @TattooTypeText varchar(50)

		SELECT @TattooType = MarkingType, @TattooedQty = MarkedQuantity FROM dbo.ERS_UpperGITherapeutics WHERE SiteId = @SiteID AND Marking = 1
		
		IF @summary <> '' SET @summary = @summary + '##'

		SET @summary = @summary + ' tattooed, '
		
		IF @TattooType IS NOT NULL AND @TattooType > 0
		BEGIN
			SELECT @TattooTypeText = ListItemText FROM dbo.ERS_Lists el WHERE el.ListDescription = 'Abno marking' AND el.ListItemNo = @TattooType AND ListItemText IS NOT NULL

			SET @summary = @summary + CASE WHEN @TattooedQty IS NOT NULL AND @TattooedQty > 0 THEN + CONVERT(varchar(5), @TattooedQty) ELSE '' END + ' marked using ' + @TattooTypeText
		END	
	END	
	ELSE IF @PreviouslyTattooed > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		SET @summary = @summary + ' previously tattooed '
	END	


SET @summary = LTRIM(RTRIM(@summary))
SET @summary = REPLACE(@summary, '##', '. ')
SET @summary = REPLACE(@summary, ' ,', ',')
SET @summary = REPLACE(@summary, ' )', ')')
SET @summary = REPLACE(@summary, ' .', '.')

DECLARE @finalSummary VARCHAR(8000) =''
----Set first letter to upper after full stop.
SELECT @finalSummary = @finalSummary + COALESCE(dbo.fnFirstLetterUpper(item) + '. ', '') 
FROM dbo.fnSplitString(@summary, '.')

SET @summary = LTRIM(RTRIM(@finalSummary))
IF @None <> 1 SET @summary = LOWER(LEFT(@summary,1)) + RIGHT(@summary,LEN(@summary)-1)
IF RIGHT(@summary,1) = '.' SET @summary = LEFT(@summary, LEN(@summary)-1)

-- Finally, update the summary in Diverticulum table
UPDATE ERS_ColonAbnoLesions
SET Summary = @summary 
WHERE SiteId = @SiteId

GO
----------------------------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'ogd_previous_gastric_ulcer','S';
GO

CREATE PROCEDURE [dbo].[ogd_previous_gastric_ulcer]
(
	@ProcedureId INT,
	@DisplayAlertOnly BIT,
	@OperatingHospitalId INT
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
	DECLARE	@PatientId INT = 0
			,@returnValue VARCHAR(500) = ''
			,@procDate DATETIME
			,@FollowUp BIT = 0

	SELECT @PatientId=PatientId, @procDate=CreatedOn FROM ERS_Procedures WHERE ProcedureId = @ProcedureId


	--Check for this procedure if Ulcer or Healing Ulcer has been entered
	IF EXISTS(SELECT 1
					FROM [ERS_UpperGIAbnoGastricUlcer] g
					JOIN ERS_Sites s ON s.SiteId = g.SiteId
					JOIN ERS_Procedures p ON p.ProcedureId = s.ProcedureId AND p.ProcedureId = @ProcedureId AND p.PatientId = @PatientId
					WHERE HealingUlcer=1 OR NotHealed=1 OR HealedUlcer=1)
		SET @FollowUp = 1

	--If follow-up (Not Healed, Healing or Healed) = 1 -> has already been recorded, no need to display alert again
	--but patient had previous Ulcer

	IF @DisplayAlertOnly = 1 AND @FollowUp = 1 
		SELECT '' --Return empty string not to display alert 
	ELSE
	BEGIN
		CREATE TABLE #previousProc (regionName VARCHAR(100), procDate VARCHAR(25));

		--Check if patient had gastric ulcer previously
		INSERT INTO #previousProc
		SELECT  r.Region, CONVERT(VARCHAR(11),p.CreatedOn,106 )
		FROM ERS_UpperGIAbnoGastricUlcer g
		JOIN ERS_Sites s ON g.SiteId = s.SiteId
		JOIN ERS_Regions r ON s.RegionID = r.RegionId 
		JOIN ERS_Procedures p ON s.ProcedureId = p.ProcedureId 
						AND p.PatientId = @PatientId AND p.ProcedureId <> @ProcedureId AND p.CreatedOn <= @procDate AND p.IsActive = 1
		WHERE g.Ulcer = 1
		ORDER BY p.CreatedOn DESC

		IF (SELECT IncludeUGI FROM ERS_SystemConfig WHERE OperatingHospitalId=@OperatingHospitalId) = 1 
			DECLARE @sql nvarchar = '
			INSERT INTO #previousProc
			SELECT s.Region, CONVERT(VARCHAR(11),e.[Episode date],106 ) 
			FROM [AUpper GI Gastric Ulcer/Malignancy] a 
			JOIN Episode e ON a.[Episode No] = e.[Episode No] 
			JOIN [Upper GI Sites] s ON s.[Episode No] = e.[Episode No] 
			WHERE a.[Patient No] = (SELECT [Combo ID] FROM Patient WHERE [Patient No] = @PatientId)
			AND a.Ulcer = -1
			ORDER BY e.[Episode date] DESC'
			EXEC sp_executesql @sql

		IF (SELECT COUNT(*) FROM #previousProc) > 0
		BEGIN
			SELECT @returnValue = COALESCE(@returnValue + ', ', '') + ISNULL(LOWER(regionName),'') + ' on ' + procDate
			FROM #previousProc
			WHERE procDate IS NOT NULL
		END

		SET @returnValue = LTRIM(RTRIM(@returnValue))
		IF LEFT(@returnValue,2) = ', ' SET @returnValue = RIGHT(@returnValue, LEN(@returnValue) - 2)

		DROP TABLE #previousProc

		SELECT @returnValue
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
----------------------------------------------------------------------------------------------------------------------------------------------------
