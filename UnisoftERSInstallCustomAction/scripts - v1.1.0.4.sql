--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D97P3'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Perianal skin tag', 3, 'Colon', 1, 97, 'D97P3', 0)
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D98P3'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Perianal warts', 3, 'Colon', 1, 98, 'D98P3', 0)
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D99P3'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Perianal herpes simplex', 3, 'Colon', 1, 99, 'D99P3', 0)
GO
--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_ColonAbnoLesions_Insert', 'TR';
GO

CREATE TRIGGER TR_ColonAbnoLesions_Insert
ON ERS_ColonAbnoLesions
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @ColonicPolyp VARCHAR(10), @RectalPolyp VARCHAR(10), @ColorectalCancer VARCHAR(10), @BenignTumour VARCHAR(10),
			 @ProbablyMalignantTumour VARCHAR(10)
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
				OR (Granuloma = 1 AND GranulomaQuantity > 0)) THEN 'True' ELSE 'False' END)
	FROM INSERTED

	EXEC abnormalities_colon_lesions_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D12P3', @ColonicPolyp			-- 'ColonicPolyp'
	EXEC diagnoses_control_save @site_id, 'D4P3', @RectalPolyp				-- 'RectalPolyp'
	EXEC diagnoses_control_save @site_id, 'D69P3', @ColorectalCancer		-- 'Colorectal cancer'
	EXEC diagnoses_control_save @site_id, 'D6P3', @BenignTumour				-- 'Benign colonic tumour'
	EXEC diagnoses_control_save @site_id, 'D8P3', @ProbablyMalignantTumour	-- 'Malignant colonic tumour'
GO


--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_ColonAbnoPerianalLesions_Insert', 'TR';
GO

CREATE TRIGGER TR_ColonAbnoPerianalLesions_Insert
ON ERS_ColonAbnoPerianalLesions
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @ColonAnalFissure VARCHAR(10), @ColonHaemorrhoids VARCHAR(10),
			@PerianalCancer VARCHAR(10), @PerianalFistula VARCHAR(10), @PerianalSkinTag VARCHAR(10),
			@PerianalWarts VARCHAR(10), @PerianalHerpes VARCHAR(10)

	SELECT @site_id=SiteId,
			@ColonAnalFissure = (CASE WHEN (AnalFissure=1) THEN 'True' ELSE 'False' END),
			@ColonHaemorrhoids = (CASE WHEN (Haemorrhoids=1) THEN 'True' ELSE 'False' END),
			@PerianalCancer = (CASE WHEN (PerianalCancer=1) THEN 'True' ELSE 'False' END),
			@PerianalFistula = (CASE WHEN (PerianalFistula=1) THEN 'True' ELSE 'False' END),
			@PerianalSkinTag = (CASE WHEN (PerianalSkin=1) THEN 'True' ELSE 'False' END),
			@PerianalWarts = (CASE WHEN (PerianalWarts=1) THEN 'True' ELSE 'False' END),
			@PerianalHerpes = (CASE WHEN (HerpesSimplex=1) THEN 'True' ELSE 'False' END)
	FROM INSERTED i

	EXEC abnormalities_colon_perianallesions_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D68P3', @ColonAnalFissure		-- 'ColonAnalFissure'
	EXEC diagnoses_control_save @site_id, 'D7P3', @ColonHaemorrhoids		-- 'ColonHaemorrhoids'
	--Colonoscopy
	EXEC diagnoses_control_save @site_id, 'D81P3', @PerianalCancer		-- 'PerianalCancer'
	EXEC diagnoses_control_save @site_id, 'D82P3', @PerianalFistula		-- 'PerianalFistula'
	--Sigmoidscopy
	--EXEC diagnoses_control_save @site_id, 'S81P3', @PerianalCancer		-- 'PerianalCancer'
	EXEC diagnoses_control_save @site_id, 'S82P3', @PerianalFistula		-- 'PerianalFistula'

	EXEC diagnoses_control_save @site_id, 'D97P3', @PerianalSkinTag		
	EXEC diagnoses_control_save @site_id, 'D98P3', @PerianalWarts		
	EXEC diagnoses_control_save @site_id, 'D99P3', @PerianalHerpes		

GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ColonAbnoPerianalLesions_Delete', 'TR';
GO

CREATE TRIGGER [dbo].[TR_ColonAbnoPerianalLesions_Delete]
ON [dbo].[ERS_ColonAbnoPerianalLesions]
AFTER DELETE
AS 
	DECLARE @site_id INT
	SELECT @site_id=SiteId FROM DELETED
	EXEC diagnoses_control_save @site_id, 'D68P3', 'False'		-- 'ColonAnalFissure'
	EXEC diagnoses_control_save @site_id, 'D7P3', 'False'		-- 'ColonHaemorrhoids'
	--Colonoscopy
	EXEC diagnoses_control_save @site_id, 'D81P3', 'False'		-- 'PerianalCancer'
	EXEC diagnoses_control_save @site_id, 'D82P3', 'False'		-- 'PerianalFistula'
	--Sigmoidscopy
	EXEC diagnoses_control_save @site_id, 'S81P3', 'False'		-- 'PerianalCancer'
	EXEC diagnoses_control_save @site_id, 'S82P3', 'False'		-- 'PerianalFistula'


	EXEC diagnoses_control_save @site_id, 'D97P3', 'False'		
	EXEC diagnoses_control_save @site_id, 'D98P3', 'False'		
	EXEC diagnoses_control_save @site_id, 'D99P3', 'False'

	EXEC sites_summary_update @site_id
GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D16P3'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Contracted lumen', 3, 'Colon', 1, 16, 'D16P3', 0)
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D17P3'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Dilated lumen', 3, 'Colon', 1, 17, 'D17P3', 0)
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D18P3'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Obstructed lumen', 3, 'Colon', 1, 18, 'D18P3', 0)
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D19P3'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Luminal spasm', 3, 'Colon', 1, 19, 'D19P3', 0)
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D20P3'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Luminal stricture', 3, 'Colon', 1, 20, 'D20P3', 0)
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D21P3'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Mucosa', 3, 'Colon', 1, 21, 'D21P3', 0)
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D22P3'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Indistinct vascularity', 3, 'Colon', 1, 22, 'D22P3', 0)
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D23P3'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Exaggerated vascularity', 3, 'Colon', 1, 23, 'D23P3', 0)
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D24P3'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Attenuated with neovascularisation vascularity ', 3, 'Colon', 1, 24, 'D24P3', 0)
GO


--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_ColonAbnoCalibre_Insert', 'TR';
GO

CREATE TRIGGER TR_ColonAbnoCalibre_Insert
ON ERS_ColonAbnoCalibre
AFTER INSERT, UPDATE 
AS 
		DECLARE @site_id INT, @StrictureInflammatory VARCHAR(10), @StrictureMalignant VARCHAR(10), @StricturePostoperative VARCHAR(10), @Stricture VARCHAR(10),
	@Spasm VARCHAR(10), @ObstructedLumen VARCHAR(10), @DilatedLumen VARCHAR(10), @ContractedLumen VARCHAR(10)
	SELECT @site_id=SiteId,
			@Stricture = (CASE WHEN (Stricture=1 AND StrictureType IN (1,2)) THEN 'True' ELSE 'False' END),
			@StrictureInflammatory = (CASE WHEN (Stricture=1 AND StrictureType=5) THEN 'True' ELSE 'False' END),
			@StrictureMalignant = (CASE WHEN (Stricture=1 AND StrictureType=4) THEN 'True' ELSE 'False' END),
			@StricturePostoperative = (CASE WHEN (Stricture=1 AND StrictureType=3) THEN 'True' ELSE 'False' END),
			@Spasm = (CASE WHEN (Spasm=1) THEN 'True' ELSE 'False' END),
			@ObstructedLumen = (CASE WHEN (Obstruction=1) THEN 'True' ELSE 'False' END),
			@DilatedLumen = (CASE WHEN (Dilated=1) THEN 'True' ELSE 'False' END),
			@ContractedLumen = (CASE WHEN (Contraction=1) THEN 'True' ELSE 'False' END)
	FROM INSERTED i

	EXEC abnormalities_calibre_summary_update @site_id
	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D65P3', @StrictureInflammatory		-- 'StrictureInflammatory'
	EXEC diagnoses_control_save @site_id, 'D66P3', @StrictureMalignant			-- 'StrictureMalignant'
	EXEC diagnoses_control_save @site_id, 'D67P3', @StricturePostoperative		-- 'StricturePostoperative'
	EXEC diagnoses_control_save @site_id, 'D20P3', @Stricture		-- 'StricturePostoperative'
	EXEC diagnoses_control_save @site_id, 'D19P3', @Spasm
	EXEC diagnoses_control_save @site_id, 'D18P3', @ObstructedLumen
	EXEC diagnoses_control_save @site_id, 'D17P3', @DilatedLumen
	EXEC diagnoses_control_save @site_id, 'D16P3', @ContractedLumen
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ColonAbnoCalibre_Delete', 'TR';
GO

CREATE TRIGGER [dbo].[TR_ColonAbnoCalibre_Delete]
ON [dbo].[ERS_ColonAbnoCalibre]
AFTER DELETE
AS 
	DECLARE @site_id INT
	SELECT @site_id=SiteId FROM DELETED
	EXEC diagnoses_control_save @site_id, 'D65P3', 'False'		-- 'StrictureInflammatory'
	EXEC diagnoses_control_save @site_id, 'D66P3', 'False'		-- 'StrictureMalignant'
	EXEC diagnoses_control_save @site_id, 'D67P3', 'False'		-- 'StricturePostoperative'
	EXEC diagnoses_control_save @site_id, 'D20P3', 'False'		-- 'StricturePostoperative'
	EXEC diagnoses_control_save @site_id, 'D19P3', 'False'
	EXEC diagnoses_control_save @site_id, 'D18P3', 'False'
	EXEC diagnoses_control_save @site_id, 'D17P3', 'False'
	EXEC diagnoses_control_save @site_id, 'D16P3', 'False'

	EXEC sites_summary_update @site_id
GO
--------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE dbo.ERS_ColonAbnoLesions ALTER COLUMN Tattooed BIT NULL
GO

ALTER TABLE dbo.ERS_ColonAbnoLesions ALTER COLUMN PreviouslyTattooed BIT NULL
GO

EXEC DropConstraint 'ERS_ColonAbnoLesions', 'DF_ColonAbnoLesions_Tattooed'
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'infer_mucosa_diagnoses', 'S'
GO

CREATE PROCEDURE [dbo].[infer_mucosa_diagnoses]
(
	@SiteId INT,
	@LoggedInUserId INT
)
AS
-- =============================================
-- All the items which were under Diagnoses screen (as UGI) are being saved under this SP
-- Diagnoses been moved to Miscellaneous and Mucosa under Abnormalities, to be inferred and report under “Diagnoses” section of the report
-- =============================================

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	DECLARE @ProcedureID INT,
	@ColonNormal BIT,
	@ColonRestNormal BIT,
	@Colitis BIT,
	@Ileitis BIT,
	@Proctitis BIT,
	@ColitisType VARCHAR(15),
	@ColitisExtent VARCHAR(15),
	@ColonList VARCHAR(1500),
	--@ColonOtherDiagnosis VARCHAR(MAX),
	@MayoScore VARCHAR(15),
	@SEScore VARCHAR(15)

	select * from ers_sites
	
  	SELECT @ProcedureId = p.ProcedureId
	FROM ERS_Sites s
	JOIN ERS_Procedures p ON s.ProcedureId = p.ProcedureId
	WHERE SiteId = @SiteId

	SELECT @ColonNormal = 1		FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND Value = '1' AND IsOtherData = 1 AND MatrixCode = 'ColonNormal'
	SELECT @ColonRestNormal = 1 FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND Value = '1' AND IsOtherData = 1 AND MatrixCode = 'ColonRestNormal'

	DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND IsOtherData = 1

	SELECT @ColonList = CASE WHEN [Crohn] = 1 THEN 'D70P3,' ELSE '' END +
      CASE WHEN [Fistula] = 1 THEN 'D71P3,' ELSE '' END +
      CASE WHEN [ForeignBody] = 1 THEN 'D72P3,' ELSE '' END +
      CASE WHEN [Lipoma] = 1 THEN 'D73P3,' ELSE '' END +
      CASE WHEN [Melanosis] = 1 THEN 'D74P3,' ELSE '' END +
      CASE WHEN [Parasites] = 1 THEN 'D75P3,' ELSE '' END +
      CASE WHEN [PneumatosisColi] = 1 THEN 'D76P3,' ELSE '' END +
      CASE WHEN [PolyposisSyndrome] = 1 THEN 'D77P3,' ELSE '' END +
      CASE WHEN [PostoperativeAppearance] = 1 THEN 'D78P3,' ELSE '' END +
      CASE WHEN [PseudoObstruction] = 1 THEN 'D9P3,' ELSE '' END 
	FROM ERS_ColonAbnoMiscellaneous
	WHERE SiteId = @SiteId

	select @ColonList
	IF ISNULL(@ColonList,'') <> ''
	BEGIN
		INSERT INTO [ERS_Diagnoses] (ProcedureID, MatrixCode, Value, Region, IsOtherData, WhoCreatedId, WhenCreated)
		SELECT @ProcedureId, [item], CONVERT(VARCHAR(MAX),'True'), 'Colon', 1, @LoggedInUserId, GETDATE() FROM dbo.fnSplitString(@ColonList,',')
	END

	SELECT @Colitis=[InflammatoryColitis]			,@Ileitis=[InflammatoryIleitis]			,@Proctitis=[InflammatoryProctitis]			,@ColitisType=[InflammatoryDisorder]
			,@ColitisExtent=[InflammatoryExtent]	,@MayoScore=[InflammatoryMayoScore]		,@SEScore=[InflammatorySESCrohn]
	FROM ERS_ColonAbnoMucosa
	WHERE SiteId = @SiteId


	INSERT INTO [ERS_Diagnoses] (ProcedureID, MatrixCode, SiteId, Value, Region, IsOtherData, WhoCreatedId, WhenCreated)
	--SELECT @ProcedureId, [item], CONVERT(VARCHAR(MAX),'True'), 'Colon', 1, @LoggedInUserId, GETDATE() FROM dbo.fnSplitString(@ColonList,',')
	--UNION
	SELECT @ProcedureId, 'ColonNormal', NULL, CONVERT(VARCHAR(MAX),@ColonNormal), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColonNormal = 1 
	UNION
	SELECT @ProcedureId, 'ColonRestNormal', NULL, CONVERT(VARCHAR(MAX),@ColonRestNormal), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColonRestNormal = 1 
	UNION
	SELECT @ProcedureId, 'Colitis', @SiteId, CONVERT(VARCHAR(MAX),@Colitis), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @Colitis = 1 
	UNION
	SELECT @ProcedureId, 'Ileitis', @SiteId, CONVERT(VARCHAR(MAX),@Ileitis), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @Ileitis = 1 
	UNION
	SELECT @ProcedureId, 'Proctitis', @SiteId, CONVERT(VARCHAR(MAX),@Proctitis), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @Proctitis = 1 
	UNION
	SELECT @ProcedureId, 'ColitisType', @SiteId, CONVERT(VARCHAR(MAX),@ColitisType), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColitisType <> '' 
	UNION
	SELECT @ProcedureId, 'ColitisExtent', @SiteId, CONVERT(VARCHAR(MAX),@ColitisExtent), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColitisExtent <> '' AND @ColitisExtent <> '0'
	UNION
	--SELECT @ProcedureId, 'ColonOtherDiagnosis', CONVERT(VARCHAR(MAX),@ColonOtherDiagnosis), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColonOtherDiagnosis <> '' 
	--UNION
	SELECT @ProcedureId, 'MayoScore', @SiteId, CONVERT(VARCHAR(MAX),@MayoScore), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @MayoScore <> ''  AND @MayoScore <> '0'
	UNION
	SELECT @ProcedureId, 'SEScore', @SiteId, CONVERT(VARCHAR(MAX),@SEScore), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @SEScore <> '' AND @SEScore <> '0'

	--EXEC ogd_diagnoses_summary_update @ProcedureId;

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

--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ProcedureId' AND Object_ID = Object_ID(N'ERS_OCS_Process'))
	ALTER TABLE ERS_OCS_Process ADD ProcedureId INT
GO
--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'usp_Insert_OCS_Record', 'S'
GO

CREATE PROCEDURE usp_Insert_OCS_Record
(
	@ProcedureId INT,
	@ProcessString varchar(max),
	@LoggedInUserId INT
)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ERS_OCS_Process WHERE ISNULL(ProcedureId,0) = @ProcedureId)
		UPDATE ERS_OCS_Process 
		SET Process = @ProcessString, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE()
		WHERE ProcedureId = @ProcedureId
	ELSE
		INSERT INTO ERS_OCS_Process (Process, ProcedureId, WhoCreatedId, WhenCreated) 
		VALUES (@ProcessString, @ProcedureId, @LoggedInUserId, GETDATE())
END
GO
--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_ColonAbnoMucosa_Insert', 'TR';
GO

CREATE TRIGGER [dbo].[TR_ColonAbnoMucosa_Insert]
ON [dbo].[ERS_ColonAbnoMucosa]
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @RedundantRectal VARCHAR(10), @HasUlcer VARCHAR(10), @UserID as int, @Mucosa VARCHAR(10)
	SELECT @site_id=SiteId, 
		@RedundantRectal = (CASE WHEN (RedundantRectal=1) THEN 'True' ELSE 'False' END),
		@HasUlcer = (CASE WHEN (SmallUlcers=1 OR LargeUlcers=1 OR PleomorphicUlcers=1 OR SerpiginousUlcers=1 
								OR AphthousUlcers=1 OR ConfluentUlceration=1 OR DeepUlceration=1 OR SolitaryUlcer=1)
								THEN 'True' ELSE 'False' END),
		@UserID = (CASE WHEN ISNULL(WhoUpdatedId,0) = 0 THEN WhoCreatedId ELSE WhoUpdatedId END),
		@Mucosa = (CASE WHEN ([None] = 0 AND Ulcerative = 0) THEN 'True' ELSE 'False' END)

	FROM INSERTED i

	EXEC abnormalities_mucosa_summary_update @site_id
	EXEC sites_summary_update @site_id

	EXEC infer_mucosa_diagnoses @site_id, @UserID

	EXEC diagnoses_control_save @site_id, 'D15P3', @RedundantRectal		-- 'Redundant anterior rectal mucosa'
	EXEC diagnoses_control_save @site_id, 'D80P3', @HasUlcer			-- 'Rectal ulcer(s)', D83P3 for 'Colonic ulcer(s)'
	EXEC diagnoses_control_save @site_id, 'D21P3', @Mucosa
GO


--------------------------------------------------------------------------------------------------------------------------------------------


EXEC DropIfExist 'TR_ColonAbnoMucosa_Delete', 'TR';
GO

CREATE TRIGGER TR_ColonAbnoMucosa_Delete
ON ERS_ColonAbnoMucosa
AFTER DELETE
AS 
	DECLARE @site_id INT
	SELECT @site_id=SiteId FROM DELETED

	
	EXEC infer_mucosa_diagnoses @site_id, 0

	EXEC diagnoses_control_save @site_id, 'D15P3', 'False'		-- 'Redundant anterior rectal mucosa'
	EXEC diagnoses_control_save @site_id, 'D21P3', 'False'
	EXEC diagnoses_control_save @site_id, 'D80P3', 'False'
	EXEC diagnoses_control_save @site_id, 'D83P3', 'False'

	EXEC sites_summary_update @site_id

GO
--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'fnNED_ProcedureExtent','F';
GO 
CREATE  FUNCTION dbo.fnNED_ProcedureExtent
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
													(CASE WHEN IsNull(Extent, 0)<=IsNull(TrainerExtent, 0) THEN Extent ELSE  TrainerExtent END)  --## Smaller number are the Furthest, ie: Jejunum= 7, and 'Proximal Oesophegus' = 12 (Closest)
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
						CASE WHEN Vis.Abandoned_ER = 1 OR Vis.Abandoned = 1 THEN 'Abandoned'
						When ( (Vis.MajorPapillaBile_ER > 0 And Vis.MajorPapillaPancreatic_ER > 0)  -- ## TainER
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
--################## End: tvfNED_ProcedureConsultants

GO
--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

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
				THEN (SELECT TOP 1 Id FROM dbo.ERS_ERCPTherapeutics e WHERE e.SiteId = @SiteId AND e.CarriedOutRole=1)
			WHEN @SiteId > 0 AND p.ProcedureType <> 2 --UpperGI..
				THEN (SELECT TOP 1 Id FROM dbo.ERS_UpperGITherapeutics u WHERE u.SiteId = @SiteId  AND  u.CarriedOutRole=1)
			ELSE 0
		END, 0) AS ER_TherapRecordId,

	ISNULL(
		CASE WHEN @SiteId > 0 AND p.ProcedureType = 2 --ERCP
				THEN (SELECT TOP 1 Id FROM dbo.ERS_ERCPTherapeutics e WHERE e.SiteId = @SiteId AND e.CarriedOutRole=2)
			WHEN @SiteId > 0 AND p.ProcedureType <> 2 --UpperGI..
				THEN (SELECT TOP 1 Id FROM dbo.ERS_UpperGITherapeutics u WHERE u.SiteId = @SiteId  AND  u.CarriedOutRole=2)
			ELSE 0
		END, 0) AS EE_TherapRecordId

FROM ERS_Procedures p
WHERE ProcedureId = @ProcedureID
--AND p.Endoscopist1 <> IsNull(p.Endoscopist2, 0) --AND p.Endoscopist1 > 0 AND p.Endoscopist2 > 0

GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'colon_extent_limiting_factors_summary_update', 'S'
GO

CREATE PROCEDURE [dbo].[colon_extent_limiting_factors_summary_update]
(
	@ProcedureId INT
)
AS

SET NOCOUNT ON
	
DECLARE 
	@RectalExam bit,
	@Retroflexion bit,
	@InsertionVia tinyint,
	@InsertionTo tinyint,
	@SpecificDistanceCm tinyint,
	@InsertionConfirmedBy int,
	@InsertionLimitedBy int,
	@DifficultiesEncountered int,
	@IleocecalValve bit,
	@TransIllumination bit,
	@IlealIntubation bit,
	@AppendicularOrifice bit,
	@TriRadiateCaecalFold bit,
	@DigitalPressure bit,
	@DegreeOfConfidence bit,
	@Positively bit,
	@WithReasonableConfidence bit,
	@TimeToCaecumMin tinyint,
	@TimeToCaecumSec tinyint,
	@TimeForWithdrawalMin tinyint,
	@TimeForWithdrawalSec tinyint,
	@Abandoned bit,
	@Abandoned_NED bit

	
SELECT 
    @RectalExam = RectalExam  ,
	@Retroflexion= Retroflexion ,
	@InsertionVia = InsertionVia ,
	@InsertionTo = InsertionTo,
	@SpecificDistanceCm = SpecificDistanceCm ,
	@InsertionConfirmedBy = InsertionConfirmedBy,
	@InsertionLimitedBy = InsertionLimitedBy,
	@DifficultiesEncountered = DifficultiesEncountered,
	@IleocecalValve = IleocecalValve ,
	@TransIllumination= TransIllumination,
	@IlealIntubation= IlealIntubation,
	@AppendicularOrifice= AppendicularOrifice,
	@TriRadiateCaecalFold=TriRadiateCaecalFold  ,
	@DigitalPressure= DigitalPressure,
	@DegreeOfConfidence=DegreeOfConfidence ,
	@Positively= Positively,
	@WithReasonableConfidence = WithReasonableConfidence ,
	@TimeToCaecumMin= TimeToCaecumMin,
	@TimeToCaecumSec= TimeToCaecumSec,
	@TimeForWithdrawalMin= TimeForWithdrawalMin,
	@TimeForWithdrawalSec=TimeForWithdrawalSec,
	@Abandoned = Abandoned,
	@Abandoned_NED = NED_Abandoned

FROM
	[ERS_ColonExtentOfIntubation]
WHERE
	ProcedureID = @ProcedureID
	
DECLARE @tmpDiv TABLE(Val VARCHAR(MAX))
DECLARE @XMLlist XML	
DECLARE @temp varchar(1000)
DECLARE @ScopeType varchar(50), @summary varchar(5000) =''
DECLARE @A varchar(5000), @B VARCHAR(5000), @Rectal varchar(500), @Retro varchar(500),@InsertionPoint varchar(50), @ProcType int, @AbandonedProcedure bit



SET @Rectal =''
SET @A =''
SET @Retro = ''
SELECT @AbandonedProcedure = (CASE WHEN @Abandoned = 1 OR @Abandoned_NED = 1 THEN 1 ELSE 0 END)

SET @ProcType = (SELECT  ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureID)

	IF @ProcType = 4 
		BEGIN
		SET @ScopeType = 'sigmoidoscope'
		END
	 ELSE 
		BEGIN 
		SET @ScopeType = 'colonoscope'
		END

	IF @RectalExam = 1 
		BEGIN
		SET @Rectal = 'A digital rectal examination was performed.'
		END
		ELSE 
		BEGIN
		SET @Rectal = 'A digital rectal examination was not performed.'
		END

	IF @Retroflexion = 1 SET @Retro = 'The scope was retroflexed in the rectum.'

	IF @InsertionTo= 6
		BEGIN
		SET @A = @A +  'There was complete insertion of the '  + @ScopeType
		END
		ELSE
		BEGIN
		SET @A = @A + 'The ' + @ScopeType +  ' was inserted'
		END
		
	SET @B= ''

	IF @InsertionTo= 1
	BEGIN
	IF @SpecificDistanceCm > 0 SET @B = ' to ' +  cast(@SpecificDistanceCm as varchar(50))  + 'cm'
	ELSE SET @B=''
	END

	IF @InsertionVia = 1 SET @A = @A + ' via the anus'  + @B
	IF @InsertionVia = 2 SET @A = @A + ' via colostomy'  + @B
	IF @InsertionVia = 3 SET @A = @A + ' via loop colostomy'  + @B
	IF @InsertionVia = 4 SET @A = @A + ' via caecostomy'  + @B
	IF @InsertionVia = 5 SET @A = @A + ' via ileostomy'  + @B

SET @InsertionPoint =''

IF @InsertionTo <> 1 AND @InsertionTo <> 6 
	BEGIN
	IF @InsertionTo = 10 SET @InsertionPoint = 'rectum'
	IF @InsertionTo = 14 SET @InsertionPoint = 'recto-sigmoid'
	IF @InsertionTo = 17 SET @InsertionPoint = 'distal sigmoid'
	IF @InsertionTo = 3 SET @InsertionPoint = 'proximal sigmoid'
	IF @InsertionTo = 7 SET @InsertionPoint = 'distal descending'
	IF @InsertionTo = 11 SET @InsertionPoint = 'proximal descending'	
	IF @InsertionTo = 15 SET @InsertionPoint = 'splenic flexure'
	IF @InsertionTo = 18 SET @InsertionPoint = 'distal transverse'
	IF @InsertionTo = 4 SET @InsertionPoint = 'mid transverse'
	IF @InsertionTo = 8 SET @InsertionPoint = 'proximal transverse'
	IF @InsertionTo = 12 SET @InsertionPoint = 'hepatic flexure'
	IF @InsertionTo = 16 SET @InsertionPoint = 'distal ascending'
	IF @InsertionTo = 19 SET @InsertionPoint = 'proximal ascending'	
	IF @InsertionTo = 5 SET @InsertionPoint = 'caecum'	
	IF @InsertionTo = 9 SET @InsertionPoint = 'terminal ileum'	
	IF @InsertionTo = 13 SET @InsertionPoint = 'neo-terminal ileum'
	IF @InsertionTo = 30 SET @InsertionPoint = 'anastomosis'
	IF @InsertionTo = 31 SET @InsertionPoint = 'ileo-colon anastomosis'
	IF @InsertionTo = 32 SET @InsertionPoint = 'pouch'
	END

IF @InsertionPoint <> '' SET @A = @A + ' to the ' + @InsertionPoint

IF charindex( 'to the',@A)  = 0 AND charindex( 'via the',@A)  = 0 SET @A = ''

SET @B = ''

IF @InsertionConfirmedBy > 0 SET @B = 'insertion confirmed by ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Colon_Extent_Insertion_Comfirmed_By' AND [ListItemNo] = @InsertionConfirmedBy)
IF @InsertionLimitedBy > 0 
	BEGIN
	IF LEN(@B) >0  SET @B = @B + ' and limited by ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Colon_Extent_Insertion_Limited_By' AND [ListItemNo] = @InsertionlimitedBy)
	ELSE SET @B = 'insertion limited by ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Colon_Extent_Insertion_Limited_By' AND [ListItemNo] = @InsertionlimitedBy)
	END

IF LEN(@B) > 0
	BEGIN
	IF LEN(@A) <= 0 SET @A = @B
	ELSE SET @A = @A + ', ' + @B
	END

DECLARE @c varchar(1000)
SET @c = ''

IF @IleocecalValve = 1 SET @c ='the ileocecal valve'
IF @TransIllumination = 1 
BEGIN
IF @c<> '' SET @c = @c + ', transillumination'
ELSE SET @c = 'transillumination'
END
IF @IlealIntubation= 1
BEGIN
IF @c<> '' SET @c = @c + ', ileal intubation' 
ELSE SET @c = 'ileal intubation' 
END
IF @AppendicularOrifice =1 
BEGIN
IF @c<> '' SET @c = @c + ', the appendicular orifice'
ELSE SET @c = 'the appendicular orifice'
END
IF @TriRadiateCaecalFold = 1 
BEGIN
IF @c<> '' SET @c = @c + ', the tri-radiate caecal fold'
ELSE SET @c = 'the tri-radiate caecal fold'
END
IF @DigitalPressure= 1 
BEGIN
IF @c<> '' SET @c = @c + ', digital pressure'
ELSE SET @c = 'digital pressure'
END

IF CHARINDEX(',', @c) > 0 SET @c = Reverse(Stuff(Reverse(@c), CharIndex(',',Reverse(@c)),1,'dna '))  

--Add full stop 
SET @A = RTrim(LTRIM(@A))
IF @A <> ''  AND (@A NOT LIKE '%.')  SET @A= @A +'.'

Declare @Which varchar(500) = ' The caecum'
IF @A <> ''
BEGIN
IF @A LIKE '%caecum.' 
	BEGIN
	SET @A = LEFT(@A,LEN(@A)-1) + ','
	SET @which = ' which'
	END
END

IF @DegreeOfConfidence= 1
	BEGIN
	IF @Positively = 1 SET @A = @A + @which + ' was identified positively'
	IF @WithReasonableConfidence = 1  SET @A = @A + @Which +' was identified with reasonable confidence'
	IF LEN(@c) >0 SET @A = @A + ' by ' + @c
	END
ELSE
	BEGIN
	IF LEN(@c) >0 SET @A = @A  + ' The caecum was indentified by ' + @c
	END

--Add full stop 
SET @A = RTrim(LTRIM(@A))
IF @A <> ''  AND (@A NOT LIKE '%.')  SET @A= @A +'.'

IF @DifficultiesEncountered > 0 SET @A = @A + ' Difficulties encountered: '+ (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Colon_Extent_Difficulty_Encountered' AND [ListItemNo] = @DifficultiesEncountered)

--Add full stop 
SET @A = RTrim(LTRIM(@A))
IF @A <> ''  AND (@A NOT LIKE '%.')  SET @A= @A +'.'

IF @Rectal <> '' SET @summary = @summary + @Rectal

IF @A <> ''
BEGIN
IF @summary <> '' SET @summary = @summary + ' ' + @A
ELSE SET @summary = @A
END

IF @Retro  <> ''
BEGIN
IF @summary <> '' SET @summary = @summary + ' ' + @Retro 
ELSE SET @summary = @Retro 
END

IF @AbandonedProcedure  =1
BEGIN
IF @summary <> '' SET @summary = @summary + ' Procedure abandoned' 
ELSE SET @summary	 = 'Procedure abandoned'
END

IF @Summary <> '' 
	BEGIN
		SET @Summary = dbo.fnFirstLetterUpper(@Summary)
	END

-- Finally, update the summary in ERS_ColonExtentOfIntubation table
UPDATE ERS_ColonExtentOfIntubation 
SET Summary = @summary 
WHERE procedureID = @ProcedureID

EXEC [procedure_summary_update] @procedureID
GO

UPDATE ERS_DiagnosesMatrix 
SET DisplayName = 'Lumen' 
WHERE Code='D89P1'

GO
--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_UpperGIAbnoPostSurgery_Delete', 'TR';
GO


CREATE TRIGGER [dbo].[TR_UpperGIAbnoPostSurgery_Delete]
ON [dbo].[ERS_UpperGIAbnoPostSurgery]
AFTER DELETE
AS 
	DECLARE @site_id INT
	SELECT @site_id=SiteId FROM DELETED
	EXEC diagnoses_control_save @site_id, 'D45P1', 'False'			-- 'PostSurgical'
	EXEC diagnoses_control_save @site_id, 'D97P1', 'False'			-- 'PostSurgical'

	DELETE FROM ERS_RecordCount 
	WHERE SiteId = @site_id
	AND Identifier = 'Post Surgery'

	EXEC sites_summary_update @site_id

GO

--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_miscellaneous_save', 'S'
GO


CREATE PROCEDURE [dbo].[abnormalities_miscellaneous_save]
(
	@SiteId INT,
	@None BIT,
	@Web BIT,
	@Mallory BIT,
	@SchatzkiRing BIT,
	@FoodResidue BIT,
	@Foreignbody BIT,
	@ExtrinsicCompression BIT,
	@Diverticulum BIT,
	@DivertMultiple BIT,
	@DivertQty SMALLINT,
	@Pharyngeal BIT,
	@DiffuseIntramural BIT,
	@TractionType BIT,
	@PulsionType BIT,
	@MotilityDisorder BIT,
	@ProbableAchalasia BIT,
	@ConfirmedAchalasia BIT,
	@Presbyoesophagus BIT,
	@MarkedTertiaryContractions BIT,
	@LaxLowerOesoSphincter BIT,
	@TortuousOesophagus BIT,
	@DilatedOesophagus BIT,
	@MotilityPoor BIT,
	@Ulceration BIT,
	@UlcerationType BIT,
	@UlcerationMultiple BIT,
	@UlcerationQty SMALLINT,
	@UlcerationLength SMALLINT,
	@UlcerationClotInBase BIT,
	@UlcerationReflux BIT,
	@UlcerationPostSclero BIT,
	@UlcerationPostBanding BIT,
	@Stricture BIT,
	@StrictureCompression TINYINT,
	@StrictureScopeNotPass BIT,
	@StrictureSeverity TINYINT,
	@StrictureType SMALLINT,
	@StrictureProbably BIT,
	@StrictureBenignType TINYINT,
	@StrictureBeginning SMALLINT,
	@StrictureLength SMALLINT,
	@StricturePerforation TINYINT,
	@Tumour BIT,
	@TumourType TINYINT,
	@TumourProbably BIT,
	@TumourExophytic TINYINT,
	@TumourBenignType TINYINT,
	@TumourBenignTypeOther NVARCHAR(100),
	@TumourBeginning SMALLINT,
	@TumourLength SMALLINT,
	@TumourScopeCouldNotPass BIT,
	@MiscOther NVARCHAR(150),
	@IsLAClassification BIT,
	@InletPatch BIT,
	@InletPatchMultiple BIT,
	@InletPatchQty SMALLINT,
	@LoggedInUserId INT

)
AS

SET NOCOUNT ON

DECLARE @proc_id INT
DECLARE @proc_type INT

BEGIN TRANSACTION

BEGIN TRY
	SELECT 
		@proc_id = p.ProcedureId,
		@proc_type = p.ProcedureType
	FROM 
		ERS_Sites s
	JOIN 
		ERS_Procedures p ON s.ProcedureId = p.ProcedureId
	WHERE 
		SiteId = @SiteId
			
	IF NOT EXISTS (SELECT 1 FROM ERS_UpperGIAbnoMiscellaneous WHERE SiteId = @SiteId)
	BEGIN
		INSERT INTO ERS_UpperGIAbnoMiscellaneous (
			SiteId,
			[None],
			Web,
			Mallory,
			SchatzkiRing,
			FoodResidue,
			Foreignbody,
			ExtrinsicCompression,
			Diverticulum,
			DivertMultiple,
			DivertQty,
			Pharyngeal,
			DiffuseIntramural,
			TractionType,
			PulsionType,
			MotilityDisorder,
			ProbableAchalasia,
			ConfirmedAchalasia,
			Presbyoesophagus,
			MarkedTertiaryContractions,
			LaxLowerOesoSphincter,
			TortuousOesophagus,
			DilatedOesophagus,
			MotilityPoor,
			Ulceration,
			UlcerationType,
			UlcerationMultiple,
			UlcerationQty,
			UlcerationLength,
			UlcerationClotInBase,
			UlcerationReflux,
			UlcerationPostSclero,
			UlcerationPostBanding,
			Stricture,
			StrictureCompression,
			StrictureScopeNotPass,
			StrictureSeverity,
			StrictureType,
			StrictureProbably,
			StrictureBenignType,
			StrictureBeginning,
			StrictureLength,
			StricturePerforation,
			Tumour,
			TumourType,
			TumourProbably,
			TumourExophytic,
			TumourBenignType,
			TumourBenignTypeOther,
			TumourBeginning,
			TumourLength,
			TumourScopeNotPass,
			MiscOther,
			IsLAClassification,
			InletPatch,
			InletPatchMultiple,
			InletPatchQty,
			WhoCreatedId,
			WhenCreated) 
		VALUES (@SiteId,
				@None,
				@Web,
				@Mallory,
				@SchatzkiRing,
				@FoodResidue,
				@Foreignbody,
				@ExtrinsicCompression,
				@Diverticulum,
				@DivertMultiple,
				@DivertQty,
				@Pharyngeal,
				@DiffuseIntramural,
				@TractionType,
				@PulsionType,
				@MotilityDisorder,
				@ProbableAchalasia,
				@ConfirmedAchalasia,
				@Presbyoesophagus,
				@MarkedTertiaryContractions,
				@LaxLowerOesoSphincter,
				@TortuousOesophagus,
				@DilatedOesophagus,
				@MotilityPoor,
				@Ulceration,
				@UlcerationType,
				@UlcerationMultiple,
				@UlcerationQty,
				@UlcerationLength,
				@UlcerationClotInBase,
				@UlcerationReflux,
				@UlcerationPostSclero,
				@UlcerationPostBanding,
				@Stricture,
				@StrictureCompression,
				@StrictureScopeNotPass,
				@StrictureSeverity,
				@StrictureType,
				@StrictureProbably,
				@StrictureBenignType,
				@StrictureBeginning,
				@StrictureLength,
				@StricturePerforation,
				@Tumour,
				@TumourType,
				@TumourProbably,
				@TumourExophytic,
				@TumourBenignType,
				@TumourBenignTypeOther,
				@TumourBeginning,
				@TumourLength,
				@TumourScopeCouldNotPass,
				@MiscOther,
				@IsLAClassification,
				@InletPatch,
				@InletPatchMultiple,
				@InletPatchQty,
				@LoggedInUserId,
				GETDATE())

		INSERT INTO ERS_RecordCount (
			[ProcedureId],
			[SiteId],
			[Identifier],
			[RecordCount]
		)
		VALUES (
			@proc_id,
			@SiteId,
			'Miscellaneous',
			1)
	END

	ELSE IF (@None = 0 AND @Web = 0 AND @Mallory = 0 AND @SchatzkiRing = 0 AND @FoodResidue = 0 
			AND @Diverticulum = 0 AND @MotilityDisorder = 0 AND @Ulceration = 0 AND @Stricture = 0 AND @Tumour = 0 
			AND @Foreignbody = 0 AND @InletPatch = 0
			AND RTRIM(LTRIM(@MiscOther)) = '')
	BEGIN
		DELETE FROM ERS_UpperGIAbnoMiscellaneous 
		WHERE SiteId = @SiteId

		DELETE FROM ERS_RecordCount 
		WHERE SiteId = @SiteId
		AND Identifier = 'Miscellaneous'
	END
	
	ELSE
	BEGIN
		UPDATE 
			ERS_UpperGIAbnoMiscellaneous
		SET 
			[None]				=	@None,
			Web					=	@Web,
			Mallory				=	@Mallory,
			SchatzkiRing		=	@SchatzkiRing,
			FoodResidue			=	@FoodResidue,
			Foreignbody = @Foreignbody,
			ExtrinsicCompression	=	@ExtrinsicCompression,
			Diverticulum		=	@Diverticulum,
			DivertMultiple		=	@DivertMultiple,
			DivertQty			=	@DivertQty,
			Pharyngeal			=	@Pharyngeal,
			DiffuseIntramural	=	@DiffuseIntramural,
			TractionType		=	@TractionType,
			PulsionType			=	@PulsionType,
			MotilityDisorder	=	@MotilityDisorder,
			ProbableAchalasia	=	@ProbableAchalasia,
			ConfirmedAchalasia	=	@ConfirmedAchalasia,
			Presbyoesophagus	=	@Presbyoesophagus,
			MarkedTertiaryContractions	=	@MarkedTertiaryContractions,
			LaxLowerOesoSphincter		=	@LaxLowerOesoSphincter,
			TortuousOesophagus		=	@TortuousOesophagus,
			DilatedOesophagus		=	@DilatedOesophagus,
			MotilityPoor			=	@MotilityPoor,
			Ulceration				=	@Ulceration,
			UlcerationType			=	@UlcerationType,
			UlcerationMultiple		=	@UlcerationMultiple,
			UlcerationQty			=	@UlcerationQty,
			UlcerationLength		=	@UlcerationLength,
			UlcerationClotInBase	=	@UlcerationClotInBase,
			UlcerationReflux		=	@UlcerationReflux,
			UlcerationPostSclero	=	@UlcerationPostSclero,
			UlcerationPostBanding	=	@UlcerationPostBanding,
			Stricture				=	@Stricture,
			StrictureCompression	=	@StrictureCompression,
			StrictureScopeNotPass	=	@StrictureScopeNotPass,
			StrictureSeverity		=	@StrictureSeverity,
			StrictureType			=	@StrictureType,
			StrictureProbably		=	@StrictureProbably,
			StrictureBenignType		=	@StrictureBenignType,
			StrictureBeginning		=	@StrictureBeginning,
			StrictureLength			=	@StrictureLength,
			StricturePerforation	=	@StricturePerforation,
			Tumour					=	@Tumour,
			TumourType				=	@TumourType,
			TumourProbably			=	@TumourProbably,
			TumourExophytic			=	@TumourExophytic,
			TumourBenignType		=	@TumourBenignType,
			TumourBenignTypeOther	=	@TumourBenignTypeOther,
			TumourBeginning			=	@TumourBeginning,
			TumourLength			=	@TumourLength,
			TumourScopeNotPass		=	@TumourScopeCouldNotPass,
			MiscOther				=	@MiscOther,
			IsLAClassification		=	@IsLAClassification,
			InletPatch				=	@InletPatch,
			InletPatchMultiple		=	@InletPatchMultiple,
			InletPatchQty			=	@InletPatchQty,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = GETDATE()
		WHERE 
			SiteId = @SiteId
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

--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_CommonAbnoAtrophic_Delete', 'TR';
GO

CREATE TRIGGER [dbo].[TR_CommonAbnoAtrophic_Delete]
ON [dbo].[ERS_CommonAbnoAtrophic]
AFTER DELETE
AS 
	DECLARE @site_id INT
	SELECT @site_id=SiteId FROM DELETED

	EXEC diagnoses_control_save @site_id, 'D96P1', 'False'

	EXEC sites_summary_update @site_id

GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_UpperGIAbnoMiscellaneous_Delete', 'TR';
GO

CREATE TRIGGER [dbo].[TR_UpperGIAbnoMiscellaneous_Delete]
ON [dbo].[ERS_UpperGIAbnoMiscellaneous]
AFTER DELETE
AS 
	DECLARE @site_id INT
	SELECT @site_id=SiteId FROM DELETED

	EXEC ogd_kpi_stricture_perforation @site_id --Update perforation text in QA for OGD KPI

	EXEC diagnoses_control_save @site_id, 'D32P1', 'False'		-- 'Diverticulum'
	EXEC diagnoses_control_save @site_id, 'D35P1', 'False'		-- 'Foreignbody'
	EXEC diagnoses_control_save @site_id, 'D24P1', 'False'		-- 'MaloryWeissTear'
	EXEC diagnoses_control_save @site_id, 'D28P1', 'False'		-- 'MotilityDisorder'
	EXEC diagnoses_control_save @site_id, 'D21P1', 'False'		-- 'Stricture'
	EXEC diagnoses_control_save @site_id, 'D72P1', 'False'		-- 'StrictureBenign'
	EXEC diagnoses_control_save @site_id, 'D73P1', 'False'		-- 'StrictureMalignant'
	EXEC diagnoses_control_save @site_id, 'D74P1', 'False'		-- 'Tumour'
	EXEC diagnoses_control_save @site_id, 'D25P1', 'False'		-- 'TumourBenign'
	EXEC diagnoses_control_save @site_id, 'D29P1', 'False'		-- 'TumourProbablyBenign'
	EXEC diagnoses_control_save @site_id, 'D34P1', 'False'		-- 'TumourMalignant'
	EXEC diagnoses_control_save @site_id, 'D37P1', 'False'		-- 'TumourProbablyMalignant'
	EXEC diagnoses_control_save @site_id, 'D26P1', 'False'		-- 'Ulcer'
	EXEC diagnoses_control_save @site_id, 'D38P1', 'False'		-- 'Web'
	EXEC diagnoses_control_save @site_id, 'D71P1', 'False'		-- 'SchatzkiRing'
	EXEC diagnoses_control_save @site_id, 'D67P1', 'False'		-- 'ExtrinsicCompression'
	EXEC diagnoses_control_save @site_id, 'D69P1', 'False'		-- 'Pharyngeal Pouch'
	EXEC diagnoses_control_save @site_id, 'D98P1', 'False'		-- 'Inlet Patch'
	EXEC diagnoses_control_save @site_id, 'StomachNotEntered', 'False'			-- 'scope could not pass
	EXEC diagnoses_control_save @site_id, 'DuodenumNotEntered', 'False'			-- 'scope could not pass

	EXEC sites_summary_update @site_id
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'usp_Procedures_Insert', 'S'
GO


CREATE PROCEDURE [dbo].[usp_Procedures_Insert]
(
	@ProcedureType		INT,
	--@PatientNo		VARCHAR(24),
	@PatientId			INT,
	@ProcedureDate		DATETIME,
	@PatientStatus		INT,
	@PatientWard		INT,
	@PatientType		INT,
	@OperatingHospitalId INT,
	@ListConsultant		INT,
	@Endoscopist1		INT,
	@Endoscopist2		INT,
	@Assistant			INT,
	@Nurse1				INT,
	@Nurse2				INT,
	@Nurse3				INT,
	@ReferralHospitalNo INT,
	@ReferralConsultantNo INT,
	@ReferralConsultantSpeciality INT,
	@PatientConsent		TINYINT,
	@DefaultCheckBox	BIT,
	@UserID				INT,
	@ProductType		TINYINT,
	@ListType			TINYINT,
	@Endo1Role			TINYINT,
	@Endo2Role			TINYINT,
	@CategoryListId	INT,
	@OnWaitingList		BIT,
	@OpenAccessProc		TINYINT,
	@EmergencyProcType	TINYINT,
	@NewProcedureId		INT OUTPUT,	-- This will return the newly created ProcedureId to the GUI! To play
	@ImagePortId		INT
)
AS

SET NOCOUNT ON

DECLARE @newProcId INT
DECLARE @ppEndos VARCHAR(2000), @GPName varchar(255), @GPAddress varchar(max), @Endo1 varchar(500), @RefCons varchar(50)

BEGIN TRANSACTION
--sp_help 'dbo.ERS_Procedures'
	BEGIN TRY
		INSERT INTO ERS_Procedures
			(ProcedureType,
			CreatedBy,	
			CreatedOn,
			ModifiedOn,
			PatientId,
			CategoryListId,
			OnWaitingList,
			OpenAccessProc,
			EmergencyProcType,
			OperatingHospitalID,
			ListConsultant,
			Endoscopist1,
			Endoscopist2,
			Assistant,
			Nurse1,
			Nurse2,
			Nurse3,
			ReferralHospitalNo,
			ReferralConsultantNo,
			ReferralConsultantSpeciality,
			PatientStatus,
			Ward,
			PatientType,
			PatientConsent,
			ListType,
			Endo1Role,
			Endo2Role,
			ImagePortId,
			WhoCreatedId,
			WhenCreated)
		VALUES (
			@ProcedureType,
			@UserID,
			@ProcedureDate, --CASE WHEN CONVERT(DATE, GETDATE()) = @ProcedureDate THEN GETDATE() ELSE @ProcedureDate END, --Insert date and time if Procedure date is current date
			GETDATE(),
			@PatientId,
			@CategoryListId,
			@OnWaitingList,
			@OpenAccessProc,
			@EmergencyProcType,
			@OperatingHospitalID,
			@ListConsultant,
			@Endoscopist1,
			@Endoscopist2,
			@Assistant,
			@Nurse1,
			@Nurse2,
			@Nurse3,
			@ReferralHospitalNo,
			@ReferralConsultantNo,
			@ReferralConsultantSpeciality,
			@PatientStatus,
			@PatientWard,
			@PatientType,
			@PatientConsent, 
			@ListType,
			@Endo1Role,
			@Endo2Role,
			@ImagePortId,
			@UserID,
			GETDATE())

		SET @newProcId = SCOPE_IDENTITY();
	
		--## Important Work- Insert a Blank Record in the ERS_ProceduresReorting- with this Unique ID! So, you can simply Update the PP fields later..!! 
		INSERT INTO dbo.ERS_ProceduresReporting(ProcedureId)VALUES(@newProcId);

		SET @ppEndos = ''
		IF @ListConsultant > 0 SELECT @ppEndos = @ppEndos + '$$List Consultant: ' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @ListConsultant
		IF @Endoscopist1 > 0 
		BEGIN
			SELECT @Endo1 = Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Endoscopist1
			SELECT @ppEndos = @ppEndos + '$$Endoscopist No1: ' + @Endo1
		END
		IF @Endoscopist2 > 0 SELECT @ppEndos = @ppEndos + '$$Endoscopist No2: ' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Endoscopist2
		IF @Nurse1 > 0 OR @Nurse2 > 0 OR @Nurse3 > 0 
		BEGIN
			SELECT @ppEndos = @ppEndos + '$$' + 'Nurses: '
			IF @Nurse1 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse1
			IF @Nurse2 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse2
			IF @Nurse3 > 0 SELECT @ppEndos =  @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse3
		END
		IF CHARINDEX('$$', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('$$', @ppEndos), 2, ''), '$$', '<br/>')
		IF CHARINDEX('##', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('##', @ppEndos), 2, ''), '##', '<br/>')
	
		SET @RefCons=''
		SELECT @RefCons = ec.CompleteName FROM dbo.ERS_Consultant ec WHERE ec.ConsultantID = @ReferralConsultantNo
		--SELECT @GPName = p.[GP Name] , @GPAddress = p.[GP Address] FROM Patient p left join  ERS_Procedures pr ON p.[Patient No]= pr.PatientId WHERE pr.ProcedureId = @newProcId
		--SELECT @GPName = p.[GP Name] , @GPAddress = p.[GP Address] FROM ERS_Patients p WHERE p.[Patient No]= @PatientId

		--Get GP practice name and address
		SELECT 	TOP 1 
				@GPName		= p.[GPName],
				@GPAddress	= p.GPAddress
		FROM ERS_VW_PatientswithGP p 
		WHERE p.PatientId = @PatientId

		UPDATE ERS_ProceduresReporting SET PP_Endos = @ppEndos, PP_GPName = @GPName, PP_GPAddress = @GPAddress, PP_Endo1 = @Endo1, PP_RefCons = @RefCons WHERE ProcedureId = @newProcId

		UPDATE ERS_Consultant SET SortOrder = ISNULL(SortOrder,0) + 1 WHERE ConsultantID = @ReferralConsultantNo

		--SELECT @newProcId AS ProcedureId
		SELECT @NewProcedureId=@newProcId;
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

EXEC DropIfExist 'usp_UpdateProcedureStaff', 'S'
GO


CREATE PROCEDURE [dbo].[usp_UpdateProcedureStaff]
(
	@ProcedureID		AS INT,
	@ListType			AS INT,
	@ListConsultant		AS VARCHAR(24),
	@Endoscopist1		AS VARCHAR(24),
	@Endoscopist1Role	AS INT, 
	@Endoscopist2		AS VARCHAR(24),
	@Endoscopist2Role	AS INT,
	@Nurse1				AS VARCHAR(24),
	@Nurse2				AS VARCHAR(24),
	@Nurse3				AS VARCHAR(24),
	@OperatingHospitalId AS INT,
	@LoggedInUserId		AS INT

)
AS
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @ppEndos VARCHAR(2000), @GPName varchar(255), @GPAddress varchar(max)

	UPDATE ERS_Procedures 
		SET 
			  ListType			= @ListType
			, ListConsultant	= @ListConsultant
			, Endoscopist1		= @Endoscopist1
			, Endo1Role			= @Endoscopist1Role
			, Endoscopist2		= @Endoscopist2
			, Endo2Role			= @Endoscopist2Role
			, Nurse1			= @Nurse1
			, Nurse2			= @Nurse2
			, Nurse3			= @Nurse3 
			, WhoUpdatedId		= @LoggedInUserId
			, WhenUpdated		= GETDATE()
	WHERE ProcedureId = @ProcedureId;

	SET @ppEndos = ''
       IF @ListConsultant > 0 SELECT @ppEndos = @ppEndos + '$$List Consultant: ' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @ListConsultant
       IF @Endoscopist1 > 0 SELECT @ppEndos = @ppEndos + '$$Endoscopist No1: ' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Endoscopist1
       IF @Endoscopist2 > 0 SELECT @ppEndos = @ppEndos + '$$Endoscopist No2: ' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Endoscopist2
       IF @Nurse1 > 0 OR @Nurse2 > 0 OR @Nurse3 > 0 
       BEGIN
              SELECT @ppEndos = @ppEndos + '$$' + 'Nurses: '
              IF @Nurse1 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Nurse1
              IF @Nurse2 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Nurse2
              IF @Nurse3 > 0 SELECT @ppEndos =  @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Nurse3
       END
       IF CHARINDEX('$$', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('$$', @ppEndos), 2, ''), '$$', '<br/>')
       IF CHARINDEX('##', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('##', @ppEndos), 2, ''), '##', '<br/>')
       
       SELECT @GPName = ISNULL(p.GPName,''), @GPAddress = ISNULL(p.GPAddress,'')
	   FROM ERS_VW_PatientswithGP p 
			LEFT JOIN  ERS_Procedures pr ON p.PatientId= pr.PatientId 
	   WHERE pr.ProcedureId = @ProcedureId;

       UPDATE ERS_ProceduresReporting SET PP_Endos = @ppEndos, PP_GPName = @GPName, PP_GPAddress = @GPAddress WHERE ProcedureId = @ProcedureId;

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

--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'ogd_indications_summary_update', 'S';
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
			  @NationalBowelScopeScreening bit

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
			  @NationalBowelScopeScreening = NationalBowelScopeScreening
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
              IF     @ColonAbdominalPain =1 INSERT INTO @tmpDiv (Val) VALUES('abdominal pain')
              IF     @ColonAbnormalBariumEnema =1 INSERT INTO @tmpDiv (Val) VALUES('abnormal barium enema')
              IF     @ColonAbnormalSigmoidoscopy =1 INSERT INTO @tmpDiv (Val) VALUES('abnormal sigmoidoscopy')
              IF     @ColonAnaemia =1 
                     BEGIN
                     IF @ColonAnaemiaType = 1   INSERT INTO @tmpDiv (Val) VALUES('microcytic anaemia')
                     ELSE IF @ColonAnaemiaType = 2     INSERT INTO @tmpDiv (Val) VALUES('normocytic anaemia')
                     ELSE IF @ColonAnaemiaType = 3     INSERT INTO @tmpDiv (Val) VALUES('macrocytic anaemia')
                     ELSE INSERT INTO @tmpDiv (Val) VALUES('anaemia')
                     END
              IF     @ColonColonicObstruction =1 INSERT INTO @tmpDiv (Val) VALUES('colonic obstruction')
              IF @OtherIndication <> '' INSERT INTO @tmpDiv (Val) VALUES(@OtherIndication)
              
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
              IF @ColonAssessment = 1 SET @B = @B + ' assessment'
              IF @ColonAssessment = 1 AND @ColonSurveillance = 1 SET @B = @B + ' and surveillance'
              ELSE IF @ColonSurveillance = 1 SET @B = @B + ' surveillance'
              IF @ColonAssessmentType = 2 SET @B =   @B + '(Crohn''s)'
              ELSE IF @ColonAssessmentType = 3 SET @B =   @B + '(Ulcerative Colitis)'
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
       IF @B <> '' SET @B = @B + ' and previous ' + RTrim(LTRIM(@D))
       ELSE SET @B = dbo.fnFirstLetterUpper('previous ' + RTrim(LTRIM(@D)))
       --IF @B <> ''  AND (@B NOT LIKE '%.')  SET @B = @B + '. </br>'
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

                     IF @ERSAbdominalPain=1 INSERT INTO @tmpDiv (Val) VALUES('abnormal CT scan')
                     IF @ERSAbnormalEnzymes=1 INSERT INTO @tmpDiv (Val) VALUES('abnormal enzymes')
                     IF @ERSAcutePancreatitisAcute=1 INSERT INTO @tmpDiv (Val) VALUES('acute pancreatitis')
					 IF @AmpullaryMass=1 INSERT INTO @tmpDiv (Val) VALUES('ampullary mass');	--## New
                     IF @ERSCholangitis=1 INSERT INTO @tmpDiv (Val) VALUES('cholangitis')
                     IF @ERSChronicPancreatisis=1 INSERT INTO @tmpDiv (Val) VALUES('chronic pancreatitis')
                     IF @ERSBiliaryLeak=1 INSERT INTO @tmpDiv (Val) VALUES('biliary leak')
					 IF @GallBladderMass=1 INSERT INTO @tmpDiv (Val) VALUES('gall bladder mass');		--##
					 IF @GallBladderPolyp=1 INSERT INTO @tmpDiv (Val) VALUES('gall bladder polyp');		--##
                     IF @ERSJaundice=1 INSERT INTO @tmpDiv (Val) VALUES('jaundice')
                     --Dec 1999 - commented out as open access is not an indication
                     --IF @ERSOpenAccess=1 INSERT INTO @tmpDiv (Val) VALUES('abnormal CT scan')               
                     IF @ERSPrelaparoscopic=1 INSERT INTO @tmpDiv (Val) VALUES('pre-laparoscopic cholecystectomy')
                     IF @ERSRecurrentPancreatitis=1 INSERT INTO @tmpDiv (Val) VALUES('recurrent pancreatitis')
					IF @ERSBileDuctInjury=1 INSERT INTO @tmpDiv (Val) VALUES('bile duct injury')
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
                     SET @mt =LTRIM(RTRIM( @mt + ' imaging revealed ' +@ms))
                     IF @mt <> ''
       BEGIN
              IF @summary = '' SET @summary = dbo.fnFirstLetterUpper(@mt)
              ELSE SET @summary = @summary + '. <br />' + dbo.fnFirstLetterUpper(@mt)
       END
                           

       END
       -----------------------------------------------------------------------
       --FOLLOW UP
       -----------------------------------------------------------------------
       DELETE FROM @tmpDiv
       DECLARE @ao varchar(max) ='',     @bo varchar(max)='' , @co varchar(max)='', @to varchar(max)=''            

       IF @ERSFollowPrevious > 0 SET @ao = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription = 'follow up disease/proc ERCP' AND  ListItemNo = @ERSFollowPrevious),'')
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
              
       ------------------------------------------------------------------
       ---PLANNED PROCEDURES
       ------------------------------------------------------------------
       DELETE FROM @tmpDiv
       SET @ms = ''
                     IF @EplanPapillotomy=1 INSERT INTO @tmpDiv (Val) VALUES('sphincterotomy')
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

              IF @OtherCoMorbidity <> '' SET @summaryTemp = @summaryTemp + '$$' + @OtherCoMorbidity

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
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_UpperGIExtentOfIntubation_Insert', 'TR'
GO

CREATE TRIGGER [dbo].[TR_UpperGIExtentOfIntubation_Insert]
ON [dbo].[ERS_UpperGIExtentOfIntubation]
AFTER INSERT, UPDATE 
AS 
	DECLARE @procedure_id INT, @failure VARCHAR(10), @stricture VARCHAR(10)
	SELECT @procedure_id=ProcedureId,
		   @failure = (CASE WHEN FailureReason > 0 OR TrainerFailureReason > 0 THEN 'True' ELSE 'False' END),
		   @stricture = (CASE WHEN FailureReason = 2 OR TrainerFailureReason= 2 THEN 'True' ELSE 'False' END)
	FROM INSERTED i

	--creating a temp table to avoid querying the DB 
	SELECT * INTO #tbl_ERS_Diagnoses FROM ERS_Diagnoses WHERE ProcedureId = @procedure_id

	IF @failure = 'True'
	BEGIN
		--check for noraml procedure entry and remove
		IF EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ed WHERE ed.MatrixCode = 'OverallNormal' AND Value = 1)
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @procedure_id AND MatrixCode = 'OverallNormal'

		--set normal diagnoses results to false
		IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ed WHERE MatrixCode = 'OesophagusNormal')
			INSERT INTO ERS_Diagnoses (ProcedureId, Region, MatrixCode, Value, IsOtherData)
			VALUES (@procedure_id, 'Oesophagus', 'OesophagusNormal', 'False', 1)
		ELSE
			UPDATE ERS_Diagnoses SET Value = 'False' WHERE ProcedureId = @procedure_id AND MatrixCode = 'OesophagusNormal' --Incase entry is there but wuith a value of flase

		IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ed WHERE MatrixCode = 'StomachNormal')
			INSERT INTO ERS_Diagnoses (ProcedureId, Region, MatrixCode, Value, IsOtherData)
			VALUES (@procedure_id, 'Stomach', 'StomachNormal', 'False', 1)
		ELSE
			UPDATE ERS_Diagnoses SET Value = 'False' WHERE ProcedureId = @procedure_id AND MatrixCode = 'StomachNormal' --Incase entry is there but wuith a value of flase
			

		IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ed WHERE MatrixCode = 'DuodenumNormal')
			INSERT INTO ERS_Diagnoses (ProcedureId, Region, MatrixCode, Value, IsOtherData)
			VALUES (@procedure_id, 'Duodenum', 'DuodenumNormal', 'False', 1)
		ELSE
			UPDATE ERS_Diagnoses SET Value = 'False' WHERE ProcedureId = @procedure_id AND MatrixCode = 'DuodenumNormal' --Incase entry is there but wuith a value of flase
			

		--check if failure due to stricture
		IF @stricture = 'True'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ed WHERE Region = 'Stomach' AND ed.MatrixCode = 'StomachNotEntered')
				INSERT INTO ERS_Diagnoses (ProcedureId, Region, MatrixCode, Value, IsOtherData)
				VALUES (@procedure_id, 'Stomach', 'StomachNotEntered', 'True', 1)
			ELSE
				UPDATE ERS_Diagnoses SET Value = 'True', IsOtherData = 1 WHERE ProcedureId = @procedure_id AND MatrixCode = 'StomachNotEntered' --Incase entry is there but wuith a value of flase

			IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ed WHERE Region = 'Duodenum' AND ed.MatrixCode = 'DuodenumNotEntered')
				INSERT INTO ERS_Diagnoses (ProcedureId, Region, MatrixCode, Value, IsOtherData)
				VALUES (@procedure_id, 'Duodenum', 'DuodenumNotEntered', 'True', 1)
			ELSE
				UPDATE ERS_Diagnoses SET Value = 'True', IsOtherData = 1 WHERE ProcedureId = @procedure_id AND MatrixCode = 'DuodenumNotEntered' --Incase entry is there but wuith a value of flase
		END
		ELSE
		BEGIN
			--remove any not entered entries
			IF EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ed WHERE ed.[Value] = 'True' AND ed.Region = 'Stomach' AND ed.MatrixCode = 'StomachNotEntered' AND IsOtherData = 1)
				DELETE FROM ERS_Diagnoses WHERE ProcedureID = @procedure_id AND Region = 'Stomach' AND [Value] = 'True' AND MatrixCode = 'StomachNotEntered' AND IsOtherData = 1-- Entry would've only been put in by this SP if 'IsOtherData' is 1 so safe to undo

			IF EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ed WHERE ed.[Value]='True' AND ed.Region = 'Duodenum' AND ed.MatrixCode = 'DuodenumNotEntered' AND IsOtherData = 1)
				DELETE FROM ERS_Diagnoses WHERE ProcedureID = @procedure_id AND Region = 'Duodenum' AND [Value]='True' AND MatrixCode = 'DuodenumNotEntered' AND IsOtherData = 1-- Entry would've only been put in by this SP if 'IsOtherData' is 1 so safe to undo
		END
	END

	DROP TABLE #tbl_ERS_Diagnoses

	EXEC ogd_diagnoses_summary_update @procedure_id
	EXEC ogd_extentofintubation_summary_update @procedure_id
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ProceduresReporting_Updated', 'TR'
GO

CREATE TRIGGER [dbo].[TR_ProceduresReporting_Updated]
   ON  [dbo].[ERS_ProceduresReporting]
   AFTER INSERT, UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @ProcedureId int

	SELECT @ProcedureId = ProcedureId FROM INSERTED
	
	UPDATE ERS_Procedures SET ReportUpdated = 1 WHERE ProcedureID = @ProcedureID AND ISNULL(ReportUpdated, 0) <> 1

	
	IF @ProcedureId IS NOT NULL 
	BEGIN
		--Toggle set normal proceudre
		DECLARE @ProcType INT, @Update BIT, @NormalProcedure BIT, @NormalMatrixCode VARCHAR(50), @Region VARCHAR(10), @UpdateSQL VARCHAR(MAX)
		SELECT @NormalProcedure	= dbo.fnNormalProcedure(@ProcedureId)
		SELECT @ProcType = ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureId
	
		IF @ProcType IN (1,6)
		BEGIN
			SELECT @Update = CASE WHEN EXISTS (SELECT 1 FROM ERS_UpperGIExtentOfIntubation WHERE ProcedureId = @ProcedureId) THEN 1 ELSE 0 END
		END
		ELSE IF @ProcType IN (3,4)
		BEGIN
			SELECT @Update = CASE WHEN EXISTS (SELECT 1 FROM ERS_ColonExtentOfIntubation WHERE ProcedureId = @ProcedureId) THEN 1 ELSE 0 END
		END
		
		IF @Update = 1 
		BEGIN
			SELECT * INTO #tbl_ERS_Diagnoses FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId

		
			SELECT @NormalMatrixCode = --Set normal procedure matrix code based on the procedure type
			CASE @ProcType
				WHEN 1 THEN 'OverallNormal'
				WHEN 2 THEN 'D32P2'
				WHEN 3 THEN 'ColonNormal'
				WHEN 4 THEN 'ColonNormal'
				WHEN 6 THEN 'OverallNormal'
				WHEN 7 THEN 'D32P2'
			END
		
			IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE IsOtherData = 1)
			BEGIN
				SELECT @Region = 
				CASE @ProcType
					WHEN 3 THEN 'Colon'
					WHEN 4 THEN 'Colon'
					ELSE ''
				END

				IF @NormalProcedure = 1
				BEGIN
					IF NOT EXISTS (SELECT 1 FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND MatrixCode=@NormalMatrixCode)
							INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, isOtherData)
							VALUES (@ProcedureId, @NormalMatrixCode, '1', @Region, 1)
					ELSE
						UPDATE ERS_Diagnoses SET Value = '1', IsOtherData = 1 WHERE ProcedureId = @ProcedureId AND MatrixCode = @NormalMatrixCode --Just incase its already in there but with a value of 'False'
				END
				ELSE
				BEGIN
				IF EXISTS (SELECT 1 FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND MatrixCode = @NormalMatrixCode AND LOWER([Value]) IN ('true','1'))
						DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND MatrixCode = @NormalMatrixCode
				END
			END 

			DROP TABLE #tbl_ERS_Diagnoses
			EXEC ogd_diagnoses_summary_update @ProcedureId
		END
	END
END
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'ogd_diagnoses_summary_update', 'S'
GO

CREATE PROCEDURE [dbo].[ogd_diagnoses_summary_update]
(
    @ProcedureId INT
)
AS

SET NOCOUNT ON

DECLARE @ProcedureType Int = (SELECT ProcedureType FROM ERS_Procedures WHERE ProcedureId=@ProcedureId )
DECLARE @Summary varchar(MAX)=''
DECLARE @tmpSummary varchar(MAX)=''
DECLARE @XMLlist XML

IF @ProcedureType IN (2, 7)    --For ERCP & EUS_HPB, execute a different SP
BEGIN
	EXEC ercp_diagnoses_summary_update @ProcedureId
	RETURN
END

BEGIN TRANSACTION

BEGIN TRY

SELECT * INTO #tbl_ERS_Diagnoses FROM ERS_Diagnoses WHERE ProcedureId=@ProcedureId 

IF @ProcedureType IN (1,6)   --Gastroscopy
BEGIN
	IF OBJECT_ID('tempdb..#Oesophagus') IS NOT NULL DROP TABLE #Oesophagus
	IF OBJECT_ID('tempdb..#Stomach') IS NOT NULL DROP TABLE #Stomach
	IF OBJECT_ID('tempdb..#Duodenum') IS NOT NULL DROP TABLE #Duodenum

    IF OBJECT_ID('tempdb..#OesophagusTemp') IS NOT NULL DROP TABLE #OesophagusTemp
                             create table #OesophagusTemp ([cx] Int null, [Text] varchar(3000) null)
    IF OBJECT_ID('tempdb..#StomachTemp') IS NOT NULL DROP TABLE #StomachTemp
                             create table #StomachTemp ([cx] Int null, [Text] varchar(3000) null)
    IF OBJECT_ID('tempdb..#DuodenumTemp') IS NOT NULL DROP TABLE #DuodenumTemp
                             create table #DuodenumTemp ([cx] Int null, [Text] varchar(3000) null)
	
	IF (SELECT COUNT(*) FROM #tbl_ERS_Diagnoses ted) = 0
	BEGIN
		INSERT INTO #tbl_ERS_Diagnoses (ProcedureID, MatrixCode, [Value], IsOtherData)
		VALUES (@ProcedureId, 'OverallNormal', '1', 1)
	END
	ELSE
	BEGIN
		/*OESOPHGAS REGION*/
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Oesophagus' AND Value = 'True' AND MatrixCode <>'OesophagusNormal')
		BEGIN
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OesophagusNormal') DELETE FROM [#tbl_ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OesophagusNormal' AND Value = 'True'
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal') DELETE FROM [#tbl_ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
		END
		ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Oesophagus' OR MatrixCode = 'OverallNormal')
			INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'OesophagusNormal', 'True', 'Oesophagus', 1)
	
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Oesophagus' AND Value = 'True' AND MatrixCode <>'OesophagusNotEntered')
		BEGIN
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OesophagusNotEntered') DELETE FROM [#tbl_ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OesophagusNotEntered' AND Value = 'True'
		END

		/*STOMACH REGION*/
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Stomach' AND Value ='True' AND MatrixCode <>'StomachNormal')
		BEGIN
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'StomachNormal')  DELETE FROM [#tbl_ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'StomachNormal' AND Value = 'True'
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal')  DELETE FROM [#tbl_ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
		END
		ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Stomach' OR MatrixCode = 'OverallNormal')
			INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'StomachNormal', 'True', 'Stomach', 1)

		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Stomach' AND Value ='True' AND MatrixCode <>'StomachNotEntered')
		BEGIN
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'StomachNotEntered')  DELETE FROM [#tbl_ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'StomachNotEntered' AND Value = 'True'
		END

		/*DUODENUM REGION*/
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND Value = 'True' AND MatrixCode <>'DuodenumNormal')
		BEGIN
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'DuodenumNormal')  DELETE FROM [#tbl_ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'DuodenumNormal' AND Value = 'True'
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal')   DELETE FROM [#tbl_ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
		END
		ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Duodenum' OR MatrixCode = 'OverallNormal')
			INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'DuodenumNormal', 'True', 'Duodenum', 1)

		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND Value = 'True' AND MatrixCode NOT IN ('DuodenumNotEntered','Duodenum2ndPartNotEntered'))
		BEGIN
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'DuodenumNotEntered')  DELETE FROM [#tbl_ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'DuodenumNotEntered' AND Value = 'True'
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'Duodenum2ndPartNotEntered')  DELETE FROM [#tbl_ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'Duodenum2ndPartNotEntered' AND Value = 'True'
		END
	END
	-- Don't repeat diagnoses
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode in ('D39P1', 'D84P1')) DELETE FROM #tbl_ERS_Diagnoses WHERE MatrixCode = 'D49P1'
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode in ('D90P1', 'D91P1')) DELETE FROM #tbl_ERS_Diagnoses WHERE MatrixCode = 'D53P1'

    SELECT  RowNum = ROW_NUMBER() OVER(ORDER BY [DiagnosesID]),d.*,m.DisplayName	INTO #Oesophagus	FROM #tbl_ERS_Diagnoses d	LEFT JOIN ERS_DiagnosesMatrix m ON d.matrixcode=m.Code WHERE Region='Oesophagus'	AND [Value] IS NOT NULL AND [Value]<>'False' AND [Value]<>'' AND MatrixCode <>'Summary'
    SELECT  RowNum = ROW_NUMBER() OVER(ORDER BY [DiagnosesID]),d.*, m.DisplayName	INTO #Stomach		FROM #tbl_ERS_Diagnoses d	LEFT JOIN ERS_DiagnosesMatrix m ON d.matrixcode=m.Code WHERE Region='Stomach'		AND [Value] IS NOT NULL AND [Value]<>'False' AND [Value]<>'' AND MatrixCode <>'Summary'
    SELECT  RowNum = ROW_NUMBER() OVER(ORDER BY [DiagnosesID]),d.*, m.DisplayName	INTO #Duodenum		FROM #tbl_ERS_Diagnoses d	LEFT JOIN ERS_DiagnosesMatrix m ON d.matrixcode=m.Code WHERE Region='Duodenum'		AND [Value] IS NOT NULL AND [Value]<>'False' AND [Value]<>'' AND MatrixCode <>'Summary'
	
	--Delete duplicates
	--DELETE FROM #Oesophagus WHERE RowNum NOT IN (SELECT MIN(RowNum) FROM #Oesophagus GROUP BY MatrixCode)
	--DELETE FROM #Stomach	WHERE RowNum NOT IN (SELECT MIN(RowNum) FROM #Stomach	GROUP BY MatrixCode)
	--DELETE FROM #Duodenum	WHERE RowNum NOT IN (SELECT MIN(RowNum) FROM #Duodenum	GROUP BY MatrixCode)

	--OESOPHAGUS
	INSERT INTO #OesophagusTemp ([cx],[Text]) 	--UNION to exclude duplicates for Abnormalities!
		--'Not Entered' or 'Normal' selected from the diagnoses screen
		SELECT 1, 'not entered' FROM #Oesophagus WHERE MatrixCode = 'OesophagusNotEntered'
		UNION
		SELECT 2, 'normal' FROM #Oesophagus WHERE MatrixCode = 'OesophagusNormal'
		UNION
		SELECT 3, CAST([Value] as Varchar(MAX)) FROM #Oesophagus WHERE MatrixCode = 'OesophagusOtherDiagnosis'
		UNION
		SELECT 0, LOWER(DisplayName) FROM #Oesophagus WHERE SiteId > 0 --Abnormalities for each sites 
	
	--STOMACH          
	INSERT INTO #StomachTemp ([cx],[Text]) 	--UNION to exclude duplicates for Abnormalities!
		--'Not Entered' or 'Normal' selected from the diagnoses screen
		SELECT 1, 'not entered' FROM #Stomach WHERE MatrixCode = 'StomachNotEntered'
		UNION
		SELECT 2, 'normal' FROM #Stomach WHERE MatrixCode = 'StomachNormal'
		UNION
		SELECT 3, CAST([Value] as Varchar(MAX)) FROM #Stomach WHERE MatrixCode = 'StomachOtherDiagnosis'
		UNION
		SELECT 0, LOWER(DisplayName) FROM #Stomach WHERE SiteId > 0 --Abnormalities for each sites 


	--DUODENUM      
	INSERT INTO #DuodenumTemp ([cx],[Text]) 	--UNION to exclude duplicates for Abnormalities!
		--'Not Entered' or 'Normal' selected from the diagnoses screen
		SELECT 1, 'not entered' FROM #Duodenum WHERE MatrixCode = 'DuodenumNotEntered'
		UNION
		SELECT 2, 'normal' FROM #Duodenum WHERE MatrixCode = 'DuodenumNormal'
		UNION
		SELECT 4, '2nd part not entered' FROM #Duodenum WHERE MatrixCode = 'Duodenum2ndPartNotEntered'
		UNION
		SELECT 3, CAST([Value] as Varchar(MAX)) FROM #Duodenum WHERE MatrixCode = 'DuodenumOtherDiagnosis'
		UNION
		SELECT 0, LOWER(DisplayName) FROM #Duodenum WHERE SiteId > 0 --Abnormalities for each sites 

	--Oesophagus
    IF EXISTS(select 1 from #OesophagusTemp)
    BEGIN
		SET @XMLlist = (SELECT [text] AS Val FROM #OesophagusTemp FOR XML  RAW, ELEMENTS, TYPE)
		SET @tmpSummary = dbo.fnBuildString(@XMLlist)
		IF @tmpSummary <> '' SET @Summary = @summary + '<b>Oesophagus: </b>' + @tmpSummary + '.<br/>'
    END

	--Stomach 
    IF EXISTS(select 1 from #StomachTemp)
    BEGIN
		SET @XMLlist = (SELECT [text] AS Val FROM #StomachTemp FOR XML  RAW, ELEMENTS, TYPE)
		SET @tmpSummary = dbo.fnBuildString(@XMLlist)
		IF @tmpSummary <> '' SET @Summary = @summary + '<b>Stomach: </b>' + @tmpSummary + '.<br/>'
    END

	--Duodenum 
    IF EXISTS(select 1 from #DuodenumTemp)
    BEGIN
		SET @XMLlist = (SELECT [text] AS Val FROM #DuodenumTemp FOR XML  RAW, ELEMENTS, TYPE)
		SET @tmpSummary = dbo.fnBuildString(@XMLlist)
		IF @tmpSummary <> '' SET @Summary = @summary + '<b>Duodenum: </b>' + @tmpSummary + '.<br/>'
    END
    
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value =1 AND MatrixCode = 'OverallNormal')         
	BEGIN
		SET @Summary = @summary + 'Whole upper gastro-intestinal tract normal.<br/>'
	END

	IF EXISTS(SELECT 1 FROM ERS_UpperGIBleeds WHERE ProcedureID = @ProcedureId)
	BEGIN
		SET @Summary = @summary +'<b>RISK OF REBLEED: </b>' + ISNULL((SELECT [OverallRiskAssessment] FROM ERS_UpperGIBleeds WHERE ProcedureID = @ProcedureId),'') + '. <br/> '
	END

    DROP TABLE #Oesophagus
    DROP TABLE #OesophagusTemp
    DROP TABLE #Stomach
    DROP TABLE #StomachTemp
    DROP TABLE #Duodenum
    DROP TABLE #DuodenumTemp
END
ELSE IF @ProcedureType IN (3,4,5) --Colonoscopy, Sigmoidscopy, Proctoscopy
BEGIN
	IF OBJECT_ID('tempdb..#Colon') IS NOT NULL DROP TABLE #Colon
	IF OBJECT_ID('tempdb..#ColonTemp') IS NOT NULL DROP TABLE #ColonTemp
		create table #ColonTemp ([cx] Int null,	[Text] VARCHAR(MAX) null)

	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value IN ('True','1') AND MatrixCode <> 'ColonNormal' )
	BEGIN
		DELETE [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'ColonNormal'
		DELETE #tbl_ERS_Diagnoses WHERE MatrixCode = 'ColonNormal'
	END;

	--Select first row in each group (in case there's more than 1 record for a given MatrixCode)
	WITH colSummary AS (
    SELECT p.DiagnosesID, p.MatrixCode, p.Value, p.Region,
           ROW_NUMBER() OVER(PARTITION BY p.MatrixCode ORDER BY p.DiagnosesID DESC) AS rk
    FROM #tbl_ERS_Diagnoses p)

	SELECT d.*, m.DisplayName 
	INTO #Colon
	FROM colSummary d 
	LEFT JOIN ERS_DiagnosesMatrix m ON d.matrixcode = m.Code AND m.ProcedureTypeID = @ProcedureType
	WHERE rk = 1 -- Get the first record only
	AND Region = 'Colon'	AND [Value] IS NOT NULL	AND [Value] <> 'False'
	AND [Value] <> ''		AND [Value] <> '0'		--AND MatrixCode <> 'Summary'


	INSERT INTO #ColonTemp ([cx],[Text]) 
	SELECT 1, CONVERT(VARCHAR(MAX), 'The examination to the point of insertion was normal.') FROM #Colon WHERE MatrixCode = 'ColonNormal'
	UNION
	SELECT 2, 'The rest of the examination to the point of insertion was normal' FROM #Colon WHERE MatrixCode = 'ColonRestNormal'
	UNION
	SELECT 4, MatrixCode FROM #Colon WHERE MatrixCode = 'Colitis' OR MatrixCode = 'Ileitis' OR MatrixCode = 'Proctitis'
	UNION
	SELECT 5, (SELECT m.DisplayName FROM ERS_DiagnosesMatrix m WHERE m.code= d.Value AND m.ProcedureTypeID = @ProcedureType)  FROM #Colon d WHERE d.MatrixCode = 'ColitisType' AND VALUE NOT IN ('D85P3', 'S85P3', 'P85P3') -- '?85P3' = None specified
	UNION
	SELECT 6, (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Diagnoses Colon Extent' AND [ListItemNo] = Value) FROM #Colon WHERE MatrixCode = 'ColitisExtent'
	UNION
	SELECT 7, (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Mayo Score' AND [ListItemNo] = Value) FROM #Colon WHERE MatrixCode = 'MayoScore'
	UNION
	SELECT 8, (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Simple Endoscopic Score – Crohn''s Disease' AND [ListItemNo] = Value) FROM #Colon WHERE MatrixCode = 'SEScore'
	UNION
	SELECT 0, LOWER(DisplayName) FROM #Colon WHERE RIGHT(MatrixCode,2) = 'P3'
	UNION
	SELECT 300, Value FROM #Colon WHERE MatrixCode = 'ColonOtherDiagnosis'

	IF EXISTS(select 1 from #ColonTemp)
	BEGIN
		SET @Summary = ''

		IF EXISTS(SELECT 1 FROM #ColonTemp WHERE cx =1) -- no need to check further if "point of insertion was normal"
			SET @Summary = (SELECT TOP 1 [text] from #ColonTemp where cx=1)
		ELSE 
		BEGIN 
			IF EXISTS(SELECT 1 FROM #ColonTemp WHERE cx =4) --Colitis or Ileitis checked
			BEGIN
				DECLARE @ck varchar(1000) =''
				DECLARE @ms varchar(1000) = ''
				DECLARE @ses varchar(1000) = ''
				DECLARE @ColitisType VARCHAR(200) = ''
				IF EXISTS(SELECT 1 FROM #ColonTemp WHERE cx =6) 
					SET @ck=  (SELECT CASE @ck WHEN '' THEN (SELECT TOP 1 [text] from #ColonTemp where cx=6) ELSE @ck + ' ' + (SELECT TOP 1 [text] from #ColonTemp where cx=6) END)

				IF EXISTS(SELECT 1 FROM #ColonTemp WHERE cx =7) 
					SET @ms=  (SELECT CASE @ms WHEN '' THEN (SELECT TOP 1 [text] from #ColonTemp where cx=7) ELSE @ms + ' ' + (SELECT TOP 1 [text] from #ColonTemp where cx=7) END)

				IF EXISTS(SELECT 1 FROM #ColonTemp WHERE cx =8) 
					SET @ses=  (SELECT CASE @ses WHEN '' THEN (SELECT TOP 1 [text] from #ColonTemp where cx=8) ELSE @ses + ' ' + (SELECT TOP 1 [text] from #ColonTemp where cx=8) END)

				IF EXISTS(SELECT 1 FROM #ColonTemp WHERE cx =5) 
				BEGIN
					 SET @ColitisType = ISNULL((SELECT TOP 1 [text] from #ColonTemp where cx=5),'')
				
					IF @ColitisType = '' SET @ColitisType = ISNULL((SELECT TOP 1 [text] from #ColonTemp where cx=4),'')

					IF @ms = '' AND @ses = ''
						SET @ColitisType = @ColitisType + (SELECT CASE @ck WHEN '' THEN '' ELSE ' (' + @ck +')' END)
					ELSE
					BEGIN
						IF @ms <> ''
							SET @ColitisType = @ColitisType + LOWER((SELECT CASE @ms WHEN '' THEN '' ELSE ': ' + @ms  END) + (SELECT CASE @ck WHEN '' THEN '' ELSE ', ' + @ck  END))
						
						IF @ses <> ''
							SET @ColitisType = @ColitisType + LOWER((SELECT CASE @ses WHEN '' THEN '' ELSE ': ' + @ses  END) + (SELECT CASE @ck WHEN '' THEN '' ELSE ', ' + @ck END))
					END
				END
				ELSE SET @ColitisType = LOWER((SELECT TOP 1 [text] from #ColonTemp where cx=4))

				--Concatnate text for colitis (4,5,6,7) and insert into #ColonTemp with id 100
				INSERT INTO #ColonTemp ([cx],[Text])  SELECT 100, @ColitisType
			END

			-- 0 = diag matrix ending with 'P3'  ;  100 = colitis   ;  300 = others
			SET @XMLlist = (SELECT [Text] AS Val FROM #ColonTemp WHERE [cx] in (0,100,300) ORDER BY [cx] FOR XML  RAW, ELEMENTS, TYPE)
			SET @Summary =  dbo.fnBuildString(@XMLlist) 

			SET @Summary = ISNULL((SELECT TOP 1 [text] + '.<br/>' FROM #ColonTemp WHERE cx=2),'')  + 
					CASE WHEN  @Summary <> '' THEN dbo.fnFirstLetterUpper(@Summary) + '.<br/>' ELSE '' END
		END

	END

	DROP TABLE #Colon
	DROP TABLE #ColonTemp
END

IF EXISTS(SELECT 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode='Summary') UPDATE [ERS_Diagnoses] SET [Value] = @summary WHERE Procedureid=@ProcedureID AND MatrixCode='Summary'
ELSE INSERT INTO [ERS_Diagnoses] (ProcedureID,MatrixCode,[Value]) VALUES (@ProcedureID,'Summary', @Summary)

UPDATE ERS_ProceduresReporting SET PP_Diagnoses = @summary WHERE ProcedureId = @ProcedureId

IF ISNULL(@Summary,'') = '' AND NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE [Value]<>'False' AND ISNULL([Value],'')<>'' AND MatrixCode <>'Summary')
	DELETE FROM ERS_RecordCount	WHERE [ProcedureId] = @ProcedureId AND [Identifier] = 'Diagnoses'
ELSE
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ERS_RecordCount WHERE [ProcedureId] = @ProcedureId AND [Identifier] = 'Diagnoses')
			INSERT INTO ERS_RecordCount ([ProcedureId], [SiteId], [Identifier], [RecordCount])
			VALUES (@ProcedureId, NULL, 'Diagnoses', 1)
	END

DROP TABLE #tbl_ERS_Diagnoses

--EXEC procedure_summary_update @procedureID

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
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
update ERS_DiagnosesMatrix
set DisplayName = 'Dieulafoy lesion'
where DisplayName = 'Diefulafoy lesion'
GO
--------------------------------------------------------------------------------------------------------------------------------------------
  update ers_lists
  set ListItemText = 'Surveillance [NED]'
  where ListItemText = 'Surveillence [NED]'
GO
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
