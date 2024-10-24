EXEC DropIfExist 'usp_ProcedureNotCarriedOut_UpdateReason','S';
GO

CREATE PROCEDURE dbo.usp_ProcedureNotCarriedOut_UpdateReason
(
	  @ProcedureId	AS INT
	, @DNA_ReasonId	AS TINYINT
	, @PP_DNA		AS VARCHAR(100)=''
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN -- UPDATE RECORDS IN TWO TABLE-> ERS_Procedures, and ERS_ProceduresReporting
		UPDATE dbo.ERS_Procedures
		   SET 
			   DNA = @DNA_ReasonId,
			   NEDEnabled = 0
		 WHERE ProcedureId = @ProcedureId;

		--## Now the ERS_ProceduresReporting Table- For the PP fields!
		BEGIN		
			UPDATE dbo.ERS_ProceduresReporting
			   SET 
				   PP_DNA = @PP_DNA
			 WHERE ProcedureId = @ProcedureId;

			IF @@ROWCOUNT=0 
				BEGIN
				-- Means No Records found in the dbo.ERS_ProceduresReporting table. So- Insert/Create the record.
					INSERT INTO dbo.ERS_ProceduresReporting (ProcedureId, PP_DNA) VALUES (@ProcedureId, @PP_DNA);
				END
		END
		
		SELECT '1' Success; --## Just for the EntityFrame work StoredProc usage! They need this Lollypop!
	END 

END 

GO
----------------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'common_requiredfields','S';
GO

CREATE Procedure [dbo].[common_requiredfields]
(
       @ProcedureId INT
)
AS
BEGIN

	DECLARE @TextMessage varchar(1000), @PageURL varchar(500), @Required bit, @ProcedureType int, @ProcedureDNA BIT

	SET @ProcedureType = (SELECT Proceduretype FROM ERS_Procedures WHERE ProcedureID = @ProcedureID)
	SELECT @ProcedureDNA = CASE WHEN DNA IS NULL THEN 0 ELSE 1 END FROM ERS_Procedures WHERE ProcedureId = @ProcedureId


	--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='Indications' AND FieldName='Indications' AND [Required]=1)
 --   BEGIN
	SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='Indications' AND FieldName='Indications' AND [Required]=1
	IF @@ROWCOUNT > 0
	BEGIN
		DECLARE @Proced int
		SELECT top 1 @Proced=ProcedureId  FROM ERS_UpperGIIndications WHERE ProcedureId = @ProcedureId

		IF @Proced IS NULL 
		BEGIN
			SELECT @TextMessage + '|' + @PageURL
			RETURN
		END
	END

	IF @ProcedureDNA = 0 
	BEGIN
	--exclude some procedures that don't use this
	--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='PreMed' AND FieldName='Drugs administered' AND [Required]=1)
 --   BEGIN
	SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='PreMed' AND FieldName='Drugs administered' AND [Required]=1
	IF @@ROWCOUNT > 0
	BEGIN
		DECLARE @drugCount tinyint
		SET @drugCount = (SELECT COUNT(DrugNo) FROM ERS_UpperGIPremedication WHERE ProcedureId=@ProcedureId)

		IF @drugCount IS NULL OR @drugCount < 1
		BEGIN
			SELECT @TextMessage + '|' + @PageURL
			RETURN
		END
    END

	
	--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='QA' AND FieldName='Patient Sedation' AND [Required]=1)
 --   BEGIN
	SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='QA' AND FieldName='Patient Sedation' AND [Required]=1
	IF @@ROWCOUNT > 0
	BEGIN
		DECLARE @PatSedation tinyint, @PatSedationAsleepResponseState tinyint
		SELECT   @PatSedation=PatSedation, @PatSedationAsleepResponseState= PatSedationAsleepResponseState  FROM ERS_UpperGIQA WHERE      ProcedureId = @ProcedureId

		IF (@PatSedation IS NULL OR @PatSedation = 0) OR (@PatSedation = 4 AND (@PatSedationAsleepResponseState is null OR @PatSedationAsleepResponseState =0))
		BEGIN
			SELECT @TextMessage + '|' + @PageURL
			RETURN
		END
    END

	--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='QA' AND FieldName='Patient Discomfort' AND [Required]=1)
 --   BEGIN
	SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='QA' AND FieldName='Patient Discomfort' AND [Required]=1
	IF @@ROWCOUNT > 0
	BEGIN
		DECLARE @PatDiscomfortNurse tinyint
		SELECT   @PatDiscomfortNurse=PatDiscomfortNurse  FROM ERS_UpperGIQA WHERE      ProcedureId = @ProcedureId

		IF @PatDiscomfortNurse IS NULL OR @PatDiscomfortNurse =0
		BEGIN
			SELECT @TextMessage + '|' + @PageURL
			RETURN
		END
    END

	--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='QA' AND FieldName='Complications' AND [Required]=1)
 --   BEGIN
	SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='QA' AND FieldName='Complications' AND [Required]=1
	IF @@ROWCOUNT > 0
	BEGIN
		DECLARE @ComplicationsNone BIT,@PoorlyTolerated BIT,@PatientDiscomfort BIT,@PatientDistress BIT,@InjuryToMouth BIT,@FailedIntubation BIT,@DifficultIntubation BIT,@DamageToScope BIT,@GastricContentsAspiration BIT,@ShockHypotension BIT,@Haemorrhage BIT,@SignificantHaemorrhage BIT,@Hypoxia BIT,@RespiratoryDepression BIT,@RespiratoryArrest BIT,@CardiacArrest BIT,@CardiacArrythmia BIT,@Death BIT,@TechnicalFailure NVARCHAR(1000),@Perforation BIT,@ComplicationsOther BIT
		SELECT  @ComplicationsNone = ComplicationsNone  ,          @PoorlyTolerated =        PoorlyTolerated ,                 @PatientDiscomfort = PatientDiscomfort  ,              @PatientDistress = PatientDistress  ,                  @InjuryToMouth = InjuryToMouth  ,
						@FailedIntubation = FailedIntubation ,                 @DifficultIntubation = DifficultIntubation  ,                   @DamageToScope = DamageToScope ,         @GastricContentsAspiration=GastricContentsAspiration  ,
						@ShockHypotension=ShockHypotension ,                   @Haemorrhage=Haemorrhage ,                    @SignificantHaemorrhage=SignificantHaemorrhage ,                     @Hypoxia=Hypoxia ,                @RespiratoryDepression=RespiratoryDepression ,
						@RespiratoryArrest=RespiratoryArrest ,                 @CardiacArrest=CardiacArrest  ,          @CardiacArrythmia=CardiacArrythmia ,                   @Death=Death  ,                   @TechnicalFailure=TechnicalFailure ,
						@Perforation=Perforation ,               @ComplicationsOther=ComplicationsOther FROM ERS_UpperGIQA WHERE ProcedureId=@ProcedureId

		IF (@ComplicationsNone IS NULL OR @ComplicationsNone = 0) AND        (@PoorlyTolerated IS NULL OR @PoorlyTolerated=0) AND (@PatientDiscomfort is null OR @PatientDiscomfort=0)          AND (@PatientDistress is null OR @PatientDistress=0) 
						AND (@InjuryToMouth is null OR @InjuryToMouth=0) AND (@FailedIntubation is null OR @FailedIntubation=0) AND (@DifficultIntubation is null OR @DifficultIntubation=0)                   AND (@DamageToScope is null OR @DamageToScope =0) AND (@GastricContentsAspiration is null OR @GastricContentsAspiration=0) AND (@ShockHypotension is null OR @ShockHypotension=0)
						AND (@Haemorrhage is null OR @Haemorrhage =0) AND (@SignificantHaemorrhage is null OR @SignificantHaemorrhage=0) AND (@Hypoxia is null OR @Hypoxia=0) AND (@RespiratoryDepression is null OR @RespiratoryDepression=0)
						AND (@RespiratoryArrest is null OR @RespiratoryArrest=0) AND (@CardiacArrest is null OR @CardiacArrest=0) AND (@CardiacArrythmia is null OR @CardiacArrythmia=0) AND (@Death is null OR @Death=0)               AND (@TechnicalFailure is null OR @TechnicalFailure='') AND (@Perforation is null OR @Perforation=0) AND (@ComplicationsOther is null Or @ComplicationsOther=0)
		BEGIN
			SELECT @TextMessage + '|' + @PageURL
			RETURN
		END
    END

	--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='PatientProcedure' AND FieldName='Instruments' AND [Required]=1)
 --   BEGIN
    SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='PatientProcedure' AND FieldName='Instruments' AND [Required]=1
	IF @@ROWCOUNT > 0
	BEGIN
       DECLARE @Instr1 tinyint, @Instr2 tinyint
       SELECT   @Instr1 = [Instrument1], @Instr2 = [Instrument2] FROM ERS_Procedures WHERE ProcedureId = @ProcedureId
       IF (@Instr1 IS NULL AND @Instr2 IS NULL) OR (@Instr1=0 AND @Instr2=0)
        BEGIN
			SELECT @TextMessage + '|' + @PageURL
			RETURN
        END
    END

	--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='Diagnoses' AND FieldName='Diagnoses' AND [Required]=1)
 --   BEGIN
    SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='Diagnoses' AND FieldName='Diagnoses' AND [Required]=1
	IF @@ROWCOUNT > 0
	BEGIN   
	   DECLARE @DiagnosesID int
	  -- IF @ProcedureType IN (2, 7)
		--SELECT TOP 1 @DiagnosesID=ID  FROM ERS_ERCPDiagnoses WHERE ProcedureId = @ProcedureId
	  -- ELSE
		SELECT top 1 @DiagnosesID=DiagnosesID  FROM [ERS_Diagnoses] WHERE ProcedureId = @ProcedureId AND [VALUE] <> 'False' AND [VALUE] <> '0' AND MatrixCode <> 'Summary' 

       IF @DiagnosesID IS NULL 
        BEGIN
			SELECT @TextMessage + '|' + @PageURL
			RETURN
        END
    END


	IF @ProcedureType= 3 OR @ProcedureType= 4 --only applies to colon
    BEGIN
		--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='PreMed' AND FieldName='Bowel preparation' AND [Required]=1) 
  --      BEGIN
		SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='PreMed' AND FieldName='Bowel preparation' AND [Required]=1
		IF @@ROWCOUNT > 0
		BEGIN 
			DECLARE @BostonBowelPrepScale bit
			SELECT TOP(1) @BostonBowelPrepScale = BostonBowelPrepScale FROM ERS_SystemConfig

			IF @BostonBowelPrepScale = 1
            BEGIN
				Declare @OnNoBowelPrep bit, @OnFormulation varchar(500), @OnRight int, @OnTransverse int, @OnLeft int
				SELECT @OnNoBowelPrep = [OnNoBowelPrep], @OnFormulation=[OnFormulation],  @OnRight=[OnRight], @OnTransverse=[OnTransverse], @OnLeft=[OnLeft] FROM [ERS_BowelPreparation] WHERE ProcedureID=@ProcedureID

				IF (@OnNoBowelPrep IS NULL OR @OnNoBowelPrep = 0) AND (@OnFormulation is null OR @OnFormulation=0) AND (@OnRight is null OR @OnTransverse is null OR @OnLeft is null)
				BEGIN
					SELECT @TextMessage + '|' + @PageURL
					RETURN
				END
            END
            ELSE
            BEGIN
				DECLARE @OffNoBowelPrep bit, @OffFormulation varchar(50), @BowelPrepQuality tinyint
                SELECT @OffNoBowelPrep=[OffNoBowelPrep]  ,@OffFormulation =[OffFormulation] , @BowelPrepQuality = [BowelPrepQuality] FROM [ERS_BowelPreparation] WHERE ProcedureID=@ProcedureID
                
				IF (@OffNoBowelPrep IS NULL OR @OffNoBowelPrep=0) AND (@OffFormulation is null OR @OffFormulation=0) 
                BEGIN
					SELECT @TextMessage + '|' + @PageURL
                    RETURN
                END
			END    
		END


		--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='ExtentLim' AND FieldName='Rectal exam (PR)' AND [Required]=1)
		--BEGIN
		SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='ExtentLim' AND FieldName='Rectal exam (PR)' AND [Required]=1
		IF @@ROWCOUNT > 0
		BEGIN 
			DECLARE @RectalExam bit
			SELECT @RectalExam = [RectalExam] FROM [dbo].[ERS_ColonExtentOfIntubation] WHERE ProcedureId=@ProcedureId

			IF @RectalExam IS NULL 
            BEGIN
				SELECT @TextMessage + '|' + @PageURL
				RETURN
            END
		END

		--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='ExtentLim' AND FieldName='Retroflexion in rectum' AND [Required]=1)
		--BEGIN
		--	SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='ExtentLim' AND FieldName='Retroflexion in rectum'
		--	DECLARE @Retroflexion bit
		--	SELECT @Retroflexion = [Retroflexion] FROM [dbo].[ERS_ColonExtentOfIntubation] WHERE ProcedureId=@ProcedureId

		--	IF @Retroflexion IS NULL 
		--	BEGIN
		--		SELECT @TextMessage + '|' + @PageURL
		--		RETURN
		--	END
		--END

		--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='ExtentLim' AND FieldName='Insertion via' AND [Required]=1)
		--BEGIN
		SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='ExtentLim' AND FieldName='Insertion via' AND [Required]=1
		IF @@ROWCOUNT > 0
		BEGIN 
			DECLARE @InsertionVia tinyint
			SELECT @InsertionVia = [InsertionVia] FROM [dbo].[ERS_ColonExtentOfIntubation] WHERE ProcedureId=@ProcedureId
		   
			IF @InsertionVia IS NULL OR @InsertionVia=0
			BEGIN
				SELECT @TextMessage + '|' + @PageURL
				RETURN
			END
		END

		--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='ExtentLim' AND FieldName='Insertion to' AND [Required]=1)
		--BEGIN
		--	SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='ExtentLim' AND FieldName='Insertion to'
		--	DECLARE @InsertionTo tinyint
		--	SELECT @InsertionTo = [InsertionTo] FROM [dbo].[ERS_ColonExtentOfIntubation] WHERE ProcedureId=@ProcedureId
			
		--	IF @InsertionTo IS NULL OR @InsertionTo=0
		--	BEGIN
		--		SELECT @TextMessage + '|' + @PageURL
		--		RETURN
		--	END
		--END

		--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='ExtentLim' AND FieldName='Insertion limited by' AND [Required]=1)
		--BEGIN
		--	SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='ExtentLim' AND FieldName='Insertion limited by'
		--	DECLARE @InsertionLimitedBy int, @ExtInsertionTo int
		--	SELECT @InsertionLimitedBy = InsertionLimitedBy, @ExtInsertionTo = InsertionTo FROM [dbo].[ERS_ColonExtentOfIntubation] WHERE ProcedureId=@ProcedureId		
																		
		--	IF ISNULL(@InsertionLimitedBy,0) = 0 AND @ExtInsertionTo > 2 AND @ExtInsertionTo NOT IN (5,9,13)
		--	BEGIN
		--		SELECT @TextMessage + '|' + @PageURL
		--		RETURN
		--	END
		--END
	END


	IF @ProcedureType =1 Or @ProcedureType = 6 --only applies to upper GI
    BEGIN
		--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='ExtentOfIntubation' AND FieldName='ExtentOfIntubation' AND [Required]=1)
		--BEGIN
		SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='ExtentOfIntubation' AND FieldName='ExtentOfIntubation' AND [Required]=1
		IF @@ROWCOUNT > 0
		BEGIN 
			DECLARE @CompletionStatus TINYINT
			SELECT @CompletionStatus = CASE WHEN ISNULL(TrainerCompletionStatus,0) = 0 THEN CompletionStatus
										ELSE TrainerCompletionStatus END FROM ERS_UpperGIExtentOfIntubation WHERE ProcedureId = @ProcedureId

			IF @CompletionStatus IS NULL OR @CompletionStatus=0 
			BEGIN
				SELECT @TextMessage + '|' + @PageURL
				RETURN
			END
		END
	END

	IF @ProcedureType = 2 --only applies to ERCP
    BEGIN
		--IF EXISTS(SELECT 1 FROM ERS_RequiredFields WHERE PageName='ExtentOfIntubation' AND FieldName='ExtentOfIntubation' AND [Required]=1)
		--BEGIN
		SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='PapillaryAnatomy' AND FieldName='PapillaryAnatomy' AND [Required]=1
		IF @@ROWCOUNT > 0
		BEGIN 
			DECLARE @FirstERCP BIT
			SELECT @FirstERCP=FirstERCP FROM ERS_Procedures WHERE ProcedureId = @ProcedureId

			IF @FirstERCP IS NULL 
			BEGIN
				SELECT @TextMessage + '|' + @PageURL
				RETURN
			END
		END

		SELECT @TextMessage = TextMessage, @PageURL = PageURL, @Required = [Required] FROM ERS_RequiredFields WHERE PageName='Visualisation' AND FieldName='Duct intended for cannulation' AND [Required]=1
		IF @@ROWCOUNT > 0
		BEGIN 
			DECLARE @IntendedBileDuct tinyint
			SELECT @IntendedBileDuct = CASE WHEN ISNULL(IntendedBileDuct,0)=0 AND
											ISNULL(IntendedPancreaticDuct,0)=0 AND
											ISNULL(IntendedBileDuct_ER,0)=0 AND
											ISNULL(IntendedPancreaticDuct_ER,0)=0 THEN 0
										ELSE 1 END
		    FROM ERS_Visualisation WHERE ProcedureId=@ProcedureId

			IF @IntendedBileDuct IS NULL OR @IntendedBileDuct=0
			BEGIN
				SELECT @TextMessage + '|' + @PageURL
				RETURN
			END
		END
	END
	END
	--All required fields entered, update flag ProcedureCompleted
	IF (SELECT ISNULL(ProcedureCompleted,0) FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)  = 0
	BEGIN
		UPDATE ERS_Procedures SET ProcedureCompleted = 1 WHERE ProcedureId = @ProcedureId
	END

END

GO
----------------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'usp_IsValidToExportNED','S';
GO
CREATE PROCEDURE [dbo].[usp_IsValidToExportNED] 
	  @ProcedureId int
	, @ProcedureType INT
	, @OperatingHospitalId INT
	, @OutputResult AS BIT = 0
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE   @IsNED_Enabled				AS BIT
			, @IsNED_RequiredForProcedure	AS BIT
			, @NEDExported					AS BIT
			, @ProcedureNEDEnabled			AS BIT;

	--## 1) Is NED Enabled for this Hospital...?
	SELECT @IsNED_Enabled= NEDEnabled FROM [dbo].[ERS_SystemConfig] WHERE OperatingHospitalId = @OperatingHospitalId;

	--## 2) Is NED Required for this type of Procedure...?
	SELECT 
		@IsNED_RequiredForProcedure= PT.NedExportRequired
		, @NEDExported = IsNull(NEDExported, 0)				--## 3) Was This procedure record already been Exported to NED...?
		, @ProcedureNEDEnabled = IsNull(P.NEDEnabled,1)		-- Some procedures we may not want to send to NED eg DNA procedures
	FROM [dbo].[ERS_ProcedureTypes] AS PT
	INNER JOIN dbo.ERS_Procedures AS P ON PT.ProcedureTypeId = P.ProcedureType
	WHERE ProcedureTypeId = @ProcedureType AND P.ProcedureId = @ProcedureId;

	--## Now take your time and think.... go to meeting room and decide- whether to send NED report or not... grab a cooffee!!
	IF  @IsNED_Enabled = 1 AND @IsNED_RequiredForProcedure=1 AND @NEDExported=0 AND @ProcedureNEDEnabled = 1
		SELECT @OutputResult = 1;
	ELSE
		SELECT @OutputResult = 0;

	SELECT @OutputResult;	--## This is the actual OutputParam Return;
	
END
GO
----------------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_UpperGIAbnoPolyps_Insert', 'TR';
GO

CREATE TRIGGER TR_UpperGIAbnoPolyps_Insert
ON ERS_UpperGIAbnoPolyps
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @Polyp VARCHAR(10), @TumorBenign VARCHAR(10), @TumorMalignant VARCHAR(10)
	SELECT @site_id=SiteId,
			@Polyp = (CASE WHEN (Sessile=1 OR Pedunculated=1 OR Submucosal=1) THEN 'True' ELSE 'False' END),
			@TumorBenign = (CASE WHEN (Sessile=1 OR Pedunculated=1 OR Submucosal=1) AND SessileBenignType > 0 THEN 'True' ELSE 'False' END),
			@TumorMalignant = (CASE WHEN (Sessile=1 OR Pedunculated=1 OR Submucosal=1) AND SessileBenignType > 0 THEN 'True' ELSE 'False' END)
	FROM INSERTED

	EXEC abnormalities_polyps_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D40P1', @Polyp			-- 'Polyp'
	EXEC diagnoses_control_save @site_id, 'D86P1', @TumorBenign		-- 'Tumor Benign'
	EXEC diagnoses_control_save @site_id, 'D87P1', @TumorMalignant	-- 'Tumor Malignant'
GO

----------------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'usp_NED_Update_Export_Settings', 'S';
GO
CREATE PROCEDURE dbo.usp_NED_Update_Export_Settings(
	  @OrganisationCode AS VARCHAR(20)
	, @APIKey AS VARCHAR(100)
	, @BatchId AS VARCHAR(15)
	, @LoggedInUserId AS INT
)
AS
-- =============================================
-- Description:	This will update Five fields related to the 'NED Export' operations
-- =============================================
BEGIN
	SET NOCOUNT ON;
	UPDATE dbo.ERS_SystemConfig
	SET   NED_OrganisationCode  = @OrganisationCode
		, NED_APIKey			= @APIKey
		, NED_BatchId			= @BatchId
		, WhoUpdatedId			= @LoggedInUserId
		, WhenUpdated			= GETDATE();

    
END
GO

----------------------------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

EXEC dbo.DropIfExist 'ERS_ORU_ProcedureData', 'V';
GO	

CREATE VIEW ERS_ORU_ProcedureData
AS
SELECT
	ep.ProcedureId,
	ep.CreatedOn as DateDone,
	ept.HL7Code AS Exam, 
	ept.ProcedureType AS ExamTitle, 
	ps.Description AS PatientClass, 
	ISNULL(pw.Description,'') AS Ward, 
	ISNULL(ec.Title,'') + ' ' + ISNULL(ec.Forename,'') + ' ' + ISNULL(ec.Surname,'') AS ReferringConsultant,
	ISNULL(eu.Title,'') + ' ' + ISNULL(eu.Forename,'') + ' ' + ISNULL(eu.Surname,'') AS AdmittingConsultant
FROM dbo.ERS_Procedures ep
	INNER JOIN dbo.ERS_ProcedureTypes ept ON ep.ProcedureType = ept.ProcedureTypeId
	INNER JOIN dbo.ERS_Consultant ec ON ec.ConsultantID	= ep.ReferralConsultantNo
	INNER JOIN dbo.ERS_Users eu ON eu.UserID = ep.Endoscopist1
	INNER JOIN (SELECT el.ListItemNo, el.ListItemText AS [Description] FROM dbo.ERS_Lists el WHERE el.ListDescription='Patient Status') ps ON ep.PatientStatus = ps.ListItemNo
	LEFT OUTER JOIN (SELECT el.ListItemNo, el.ListItemText AS [Description] FROM dbo.ERS_Lists el WHERE el.ListDescription='Ward') pw ON ep.Ward = pw.ListItemNo

GO
----------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Initial' AND Object_ID = Object_ID(N'ERS_Consultant'))
	ALTER TABLE dbo.ERS_Consultant ADD Initial VARCHAR(10)
GO
----------------------------------------------------------------------------------------------------------------------------------------------------

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'common_consultant_save','S';
GO

CREATE PROCEDURE [dbo].[common_consultant_save]
(
	@ConsultantID INT,
	@Title varchar(10),
	@Initial varchar(10),
	@Forename varchar(100),
	@Surname varchar(100),
	@GroupID varchar(5),
	@AllHospitals tinyint,
	@GMCCode varchar(10),
	@HospitalList varchar(100),
	@LoggedInUserId int
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	Declare @Hospital varchar(20) = null
	IF @ConsultantID IS NULL OR @ConsultantID=0
		BEGIN
		INSERT INTO [ERS_Consultant]([Title],[Initial],[Forename],[Surname],[GroupID],[AllHospitals],[GMCCode],WhoCreatedId, WhenCreated) VALUES(@Title,@Initial,@Forename,@Surname,@GroupID,@AllHospitals,@GMCCode,@LoggedInUserId,GETDATE())
		SET @ConsultantID = (SELECT SCOPE_IDENTITY())
		IF @AllHospitals = 0 AND @HospitalList is not null
			BEGIN			    
			WHILE LEN(@HospitalList) > 0
				BEGIN
				IF PATINDEX('%|%',@HospitalList) > 0
					BEGIN
					SET @Hospital = SUBSTRING(@HospitalList, 0, PATINDEX('%|%',@HospitalList))
					IF  @Hospital IS NOT NULL AND NOT EXISTS(SELECT 1 FROM [ERS_ConsultantsHospital] WHERE [HospitalID] = @Hospital AND [ConsultantID] = @ConsultantID )
						BEGIN
						INSERT INTO [ERS_ConsultantsHospital] ([ConsultantID],[HospitalID], WhoCreatedId, WhenCreated) VALUES(@consultantid,@Hospital,@LoggedInUserId, GETDATE())
						END
					SET @HospitalList = SUBSTRING(@HospitalList, LEN(@Hospital + '|') + 1, LEN(@HospitalList))
					END
				ELSE
					BEGIN
					SET @Hospital = @HospitalList
					SET @HospitalList = NULL
					IF  @Hospital IS NOT NULL AND NOT EXISTS(SELECT 1 FROM [ERS_ConsultantsHospital] WHERE [HospitalID] = @Hospital AND [ConsultantID] = @ConsultantID )
						BEGIN
						INSERT INTO [ERS_ConsultantsHospital] ([ConsultantID],[HospitalID], WhoCreatedId, WhenCreated) VALUES(@consultantid,@Hospital,@LoggedInUserId, GETDATE())
						END
					END
				END
			END
		END
	ELSE
		BEGIN
		UPDATE [ERS_Consultant] SET Title = @Title,Initial = @Initial, Forename = @Forename,Surname = @Surname, GroupID = @GroupID, AllHospitals = @AllHospitals,GMCCode = @GMCCode, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE ConsultantID = @ConsultantID
		DELETE FROM [ERS_ConsultantsHospital] WHERE ConsultantID   = @ConsultantID
		IF @AllHospitals = 0 AND @HospitalList is not null
			BEGIN			
		   	WHILE LEN(@HospitalList) > 0
				BEGIN
				IF PATINDEX('%|%',@HospitalList) > 0
					BEGIN
					SET @Hospital = SUBSTRING(@HospitalList, 0, PATINDEX('%|%',@HospitalList))
					IF  @Hospital IS NOT NULL AND NOT EXISTS(SELECT 1 FROM [ERS_ConsultantsHospital] WHERE [HospitalID] = @Hospital AND [ConsultantID] = @ConsultantID )
						BEGIN
						INSERT INTO [ERS_ConsultantsHospital] ([ConsultantID],[HospitalID],WhoCreatedId,WhenCreated) VALUES(@consultantid,@Hospital,@LoggedInUSerId,GETDATE())
						END
					SET @HospitalList = SUBSTRING(@HospitalList, LEN(@Hospital + '|') + 1, LEN(@HospitalList))
					END
				ELSE
					BEGIN
					SET @Hospital = @HospitalList
					SET @HospitalList = NULL
					IF  @Hospital IS NOT NULL AND NOT EXISTS(SELECT 1 FROM [ERS_ConsultantsHospital] WHERE [HospitalID] = @Hospital AND [ConsultantID] = @ConsultantID )
						BEGIN
						INSERT INTO [ERS_ConsultantsHospital] ([ConsultantID],[HospitalID],WhoCreatedId,WhenCreated) VALUES(@consultantid,@Hospital,@LoggedInUserId,GETDATE())
						END
					END
				END
			END
		END
		SELECT @ConsultantID
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
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
