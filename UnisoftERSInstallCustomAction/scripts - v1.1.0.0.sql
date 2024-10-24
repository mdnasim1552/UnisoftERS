-- Add 'single' for Quantity under Diverticulum

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'abnormalities_colon_diverticulum_summary_update','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_colon_diverticulum_summary_update]
(
	@SiteId INT
)
AS
SET NOCOUNT ON
	
DECLARE 
	@summary VARCHAR (8000),
	@tempsummary VARCHAR (1000),
	@None BIT,
	@MucosalInflammation BIT,
	@Quantity TINYINT,
	@Distribution TINYINT,
	@NarrowingTortuosity BIT,
	@Severity TINYINT,
	@CircMuscleHypertrophy BIT

SET @summary = ''
SET @tempsummary = ''

SELECT 
	@None=[None],
	@MucosalInflammation=MucosalInflammation,
	@Quantity=Quantity,
	@Distribution=Distribution,
	@NarrowingTortuosity=NarrowingTortuosity,
	@Severity=Severity,
	@CircMuscleHypertrophy=CircMuscleHypertrophy
FROM
	ERS_ColonAbnoDiverticulum
WHERE
	SiteId = @SiteId
	
IF @None = 1 SET @summary = 'No diverticula'

ELSE
BEGIN
	IF @Quantity > 0 
	BEGIN
		SET @summary =	CASE @Quantity 
							WHEN 1 THEN 'a few'
							WHEN 2 THEN 'several'
							WHEN 3 THEN 'multiple'
							WHEN 4 THEN 'single'
						END

		SET @summary =	@summary + 
						CASE @Distribution 
							WHEN 0 THEN ''
							WHEN 1 THEN ' scattered'
							WHEN 2 THEN ' localised'
						END
	END

	IF @NarrowingTortuosity = 1
	BEGIN
		SET @tempsummary =	CASE @Severity
								WHEN 0 THEN ''
								WHEN 1 THEN 'mild '
								WHEN 2 THEN 'moderate '
								WHEN 3 THEN 'severe '
							END

		SET @tempsummary = @tempsummary + 'narrowing/tortuosity of the diverticular segment'

		IF @summary <> '' SET @summary = @summary + ' with ' + @tempsummary
		ELSE SET @summary = @tempsummary
	END

	
	IF @MucosalInflammation = 1
		IF @summary = ''
			SET @summary = 'mucosal inflammation'
		ELSE IF CHARINDEX('with', @summary) > 0 
			SET @summary = @summary + '$$' + 'mucosal inflammation'
		ELSE
			SET @summary = @summary + ' with ' + 'mucosal inflammation'

	
	IF @CircMuscleHypertrophy = 1 SET @summary = @summary + '$$' + 'circular muscle hypertrophy'
	
	-- Set the last occurence of $$ to "and"
	IF CHARINDEX('$$', @summary) > 0 
	SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 2, ' and ')
	IF LEFT(@summary,5) = ' and ' SET @summary = RIGHT(@summary, LEN(@summary)-5)

	-- Replace all other occurences of $$ with commas
	SET @summary = REPLACE(@summary, '$$', ', ')
END

-- Finally, update the summary in Diverticulum table
UPDATE ERS_ColonAbnoDiverticulum 
SET Summary = @summary 
WHERE SiteId = @SiteId

GO
--------------------------------------------------------------------------------------------------------------------
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
		
		EXEC procedure_summary_update @ProcedureId
		SELECT '1' Success; --## Just for the EntityFrame work StoredProc usage! They need this Lollypop!
	END 

END 

GO
--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
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

	
	IF @ProcedureType IN (3,4,5)   ---------- Colonoscopy, Sigmoidscopy, Proctoscopy ----------------------
	BEGIN
		SET @Region=(select x.Region from [ERS_AbnormalitiesMatrixColon] x inner join ERS_Regions r on x.region = r.Region AND r.ProcedureType= x.ProcedureType inner join ers_sites s on r.RegionId = s.RegionId where s.SiteId = @siteID )
		SET @MatrixSection= 'Colon'

		--ColonicPolyp (D12P3) should not be in region 'Rectum'
		--RectalPolyp (D4P3) should be in region 'Rectum'
		IF @DiagnosesMatrixCode IN ('D12P3') AND @Region = 'Rectum'		SET @ProcedureID = NULL
		ELSE IF @DiagnosesMatrixCode IN ('D4P3') AND @Region <> 'Rectum'		SET @ProcedureID = NULL
		ELSE IF @DiagnosesMatrixCode = 'D8P3' AND @Region = 'Rectum'	SET @DiagnosesMatrixCode = 'D13P3' -- D8P3 for 'Malignant colonic tumour', D13P3 for Malignant rectal tumour
		ELSE IF @DiagnosesMatrixCode = 'D5P3' AND @ProcedureType = 4	SET @DiagnosesMatrixCode = 'S5P3' --Sigmo code is S5P3
		ELSE IF @DiagnosesMatrixCode = 'D1P3' AND @ProcedureType = 4	SET @DiagnosesMatrixCode = 'S1P3'
		ELSE IF @DiagnosesMatrixCode = 'D12P3' AND @ProcedureType = 4	SET @DiagnosesMatrixCode = 'S12P3' --not worrying about doing the region check as the one above would've handled and set procedure id to 0 and thins is checked below and acted on accordingly
		ELSE IF @DiagnosesMatrixCode = 'D4P3' AND @ProcedureType = 4    SET @DiagnosesMatrixCode = 'S4P3'  --not worrying about doing the region check as the one above would've handled and set procedure id to 0 and thins is checked below and acted on accordingly
		ELSE IF @DiagnosesMatrixCode = 'D8P3' AND @ProcedureType = 4	SET @DiagnosesMatrixCode = 'S8P3'  --not worrying about doing the region check as the one above would've handled and set procedure id to 0 and thins is checked below and acted on accordingly
		ELSE IF @DiagnosesMatrixCode IN ('D6P3') 
			BEGIN
				IF @SiteNo = -77	AND @XCoordinate >= 17		SET @DiagnosesMatrixCode = 'D11P3' -- D6P3 for 'Benign colonic tumour', D11P3 for Benign rectal tumour
				ELSE IF @SiteNo > 0 AND @Region = 'Rectum'		SET @DiagnosesMatrixCode = 'D11P3' -- D6P3 for 'Benign colonic tumour', D11P3 for Benign rectal tumour
			END
		ELSE IF @DiagnosesMatrixCode IN ('D15P3') 
			BEGIN
				IF @SiteNo = -77	AND @XCoordinate >= 17		SET @ProcedureID = NULL -- By distance, "Redundant anterior rectal mucosa" should be in region 'Rectum' and rectal is if the site is < 17 cm
				ELSE IF @SiteNo > 0 AND @Region <> 'Rectum'		SET @ProcedureID = NULL -- Redundant anterior rectal mucosa (D15P3) should be in region 'Rectum'
			END
		ELSE IF @DiagnosesMatrixCode IN ('D80P3') 
			BEGIN
				IF @SiteNo = -77	AND @XCoordinate >= 17		SET @DiagnosesMatrixCode = 'D83P3' -- By distance, D80P3 for 'Rectal ulcer(s)', D83P3 for 'Colonic ulcer(s)'
				ELSE IF @SiteNo > 0 AND @Region <> 'Rectum'		SET @DiagnosesMatrixCode = 'D83P3'   --D80P3 for 'Rectal ulcer(s)', D83P3 for 'Colonic ulcer(s)'
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
	IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE ProcedureTypeID = @ProcedureType AND Code = @DiagnosesMatrixCode) GOTO RETURN_NULL


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
--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'abnormalities_colon_lesions_save','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_colon_lesions_save]
(
	@SiteId INT,
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
	@TattooedQty INT,
	@TattooedBy INT,
	@LoggedInUserId INT)
AS

SET NOCOUNT ON

DECLARE @proc_id INT
DECLARE @proc_type INT
DECLARE @Insert BIT = 0

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
	

	IF (@None = 0 AND @Sessile = 0 AND @Pedunculated = 0 AND @Pseudopolyps = 0 AND @Submucosal = 0 AND @Villous = 0 AND @Ulcerative = 0 AND @Stricturing = 0 AND @Polypoidal = 0 AND @Granuloma = 0 AND @Dysplastic = 0 AND @PneumatosisColi = 0)
	BEGIN
		IF EXISTS (SELECT 1 FROM [ERS_ColonAbnoLesions] WHERE SiteId = @SiteId)
		BEGIN
			DELETE FROM [ERS_ColonAbnoLesions] 
			WHERE SiteId = @SiteId

			DELETE FROM ERS_RecordCount 
			WHERE SiteId = @SiteId
			AND Identifier = 'Lesions'
		END
	END

	ELSE IF NOT EXISTS (SELECT 1 FROM [ERS_ColonAbnoLesions] WHERE SiteId = @SiteId)
	BEGIN
		INSERT INTO [ERS_ColonAbnoLesions] (
			SiteId,
			[None],
			Sessile,
			SessileQuantity,
			SessileLargest,
			SessileExcised,
			SessileRetrieved,
			SessileToLabs,
			SessileRemoval,
			SessileRemovalMethod,
			SessileProbably,
			SessileType,
			SessileParisClass,
			SessilePitPattern,
			Pedunculated,
			PedunculatedQuantity,
			PedunculatedLargest,
			PedunculatedExcised,
			PedunculatedRetrieved,
			PedunculatedToLabs,
			PedunculatedRemoval,
			PedunculatedRemovalMethod,
			PedunculatedProbably,
			PedunculatedType,
			PedunculatedParisClass,
			PedunculatedPitPattern,
			Pseudopolyps,
			PseudopolypsMultiple,
			PseudopolypsQuantity,
			PseudopolypsLargest,
			PseudopolypsExcised,
			PseudopolypsRetrieved,
			PseudopolypsToLabs,
			PseudopolypsInflam,
			PseudopolypsPostInflam,
			PseudopolypsRemoval,
			PseudopolypsRemovalMethod,
			Submucosal,
			SubmucosalQuantity,
			SubmucosalLargest,
			SubmucosalProbably,
			SubmucosalType,
			Villous,
			VillousQuantity,
			VillousLargest,
			VillousProbably,
			VillousType,
			Ulcerative,
			UlcerativeQuantity,
			UlcerativeLargest,
			UlcerativeProbably,
			UlcerativeType,
			Stricturing,
			StricturingQuantity,
			StricturingLargest,
			StricturingProbably,
			StricturingType,
			Polypoidal,
			PolypoidalQuantity,
			PolypoidalLargest,
			PolypoidalProbably,
			PolypoidalType,
			Granuloma,
			GranulomaQuantity,
			GranulomaLargest,
			Dysplastic,
			DysplasticQuantity,
			DysplasticLargest,
			PneumatosisColi,
			Tattooed,
			PreviouslyTattooed,
			TattooType,
			TattooedQuantity,
			TattooedBy,
			WhoCreatedId,
			WhenCreated) 
		VALUES (
			@SiteId,
			@None,
			@Sessile,
			@SessileQuantity,
			@SessileLargest,
			@SessileExcised,
			@SessileRetrieved,
			@SessileToLabs,
			@SessileRemoval,
			@SessileRemovalMethod,
			@SessileProbably,
			@SessileType,
			@SessileParisClass,
			@SessilePitPattern,
			@Pedunculated,
			@PedunculatedQuantity,
			@PedunculatedLargest,
			@PedunculatedExcised,
			@PedunculatedRetrieved,
			@PedunculatedToLabs,
			@PedunculatedRemoval,
			@PedunculatedRemovalMethod,
			@PedunculatedProbably,
			@PedunculatedType,
			@PedunculatedParisClass,
			@PedunculatedPitPattern,
			@Pseudopolyps,
			@PseudopolypsMultiple,
			@PseudopolypsQuantity,
			@PseudopolypsLargest,
			@PseudopolypsExcised,
			@PseudopolypsRetrieved,
			@PseudopolypsToLabs,
			@PseudopolypsInflam,
			@PseudopolypsPostInflam,
			@PseudopolypsRemoval,
			@PseudopolypsRemovalMethod,
			@Submucosal,
			@SubmucosalQuantity,
			@SubmucosalLargest,
			@SubmucosalProbably,
			@SubmucosalType,
			@Villous,
			@VillousQuantity,
			@VillousLargest,
			@VillousProbably,
			@VillousType,
			@Ulcerative,
			@UlcerativeQuantity,
			@UlcerativeLargest,
			@UlcerativeProbably,
			@UlcerativeType,
			@Stricturing,
			@StricturingQuantity,
			@StricturingLargest,
			@StricturingProbably,
			@StricturingType,
			@Polypoidal,
			@PolypoidalQuantity,
			@PolypoidalLargest,
			@PolypoidalProbably,
			@PolypoidalType,
			@Granuloma,
			@GranulomaQuantity,
			@GranulomaLargest,
			@Dysplastic,
			@DysplasticQuantity,
			@DysplasticLargest,
			@PneumatosisColi,
			@Tattooed,
			@PreviouslyTattooed,
			@TattooType,
			@TattooedQty,
			@TattooedBy,
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
			'Lesions',
			1)

			SET @Insert = 1
	END

	ELSE
	BEGIN
		UPDATE 
			[ERS_ColonAbnoLesions]
		SET 
			[None] = @None,
			Sessile = @Sessile,
			SessileQuantity = @SessileQuantity,
			SessileLargest = @SessileLargest,
			SessileExcised = @SessileExcised,
			SessileRetrieved = @SessileRetrieved,
			SessileToLabs = @SessileToLabs,
			SessileRemoval = @SessileRemoval,
			SessileRemovalMethod = @SessileRemovalMethod,
			SessileProbably = @SessileProbably,
			SessileType = @SessileType,
			SessileParisClass = @SessileParisClass,
			SessilePitPattern = @SessilePitPattern,
			Pedunculated = @Pedunculated,
			PedunculatedQuantity = @PedunculatedQuantity,
			PedunculatedLargest = @PedunculatedLargest,
			PedunculatedExcised = @PedunculatedExcised,
			PedunculatedRetrieved = @PedunculatedRetrieved,
			PedunculatedToLabs = @PedunculatedToLabs,
			PedunculatedRemoval = @PedunculatedRemoval,
			PedunculatedRemovalMethod = @PedunculatedRemovalMethod,
			PedunculatedProbably = @PedunculatedProbably,
			PedunculatedType = @PedunculatedType,
			PedunculatedParisClass = @PedunculatedParisClass,
			PedunculatedPitPattern = @PedunculatedPitPattern,
			Pseudopolyps = @Pseudopolyps,
			PseudopolypsMultiple = @PseudopolypsMultiple,
			PseudopolypsQuantity = @PseudopolypsQuantity,
			PseudopolypsLargest = @PseudopolypsLargest,
			PseudopolypsExcised = @PseudopolypsExcised,
			PseudopolypsRetrieved = @PseudopolypsRetrieved,
			PseudopolypsToLabs = @PseudopolypsToLabs,
			PseudopolypsInflam = @PseudopolypsInflam,
			PseudopolypsPostInflam = @PseudopolypsPostInflam,
			PseudopolypsRemoval = @PseudopolypsRemoval,
			PseudopolypsRemovalMethod = @PseudopolypsRemovalMethod,
			Submucosal = @Submucosal,
			SubmucosalQuantity = @SubmucosalQuantity,
			SubmucosalLargest = @SubmucosalLargest,
			SubmucosalProbably = @SubmucosalProbably,
			SubmucosalType = @SubmucosalType,
			Villous = @Villous,
			VillousQuantity = @VillousQuantity,
			VillousLargest = @VillousLargest,
			VillousProbably = @VillousProbably,
			VillousType = @VillousType,
			Ulcerative = @Ulcerative,
			UlcerativeQuantity = @UlcerativeQuantity,
			UlcerativeLargest = @UlcerativeLargest,
			UlcerativeProbably = @UlcerativeProbably,
			UlcerativeType = @UlcerativeType,
			Stricturing = @Stricturing,
			StricturingQuantity = @StricturingQuantity,
			StricturingLargest = @StricturingLargest,
			StricturingProbably = @StricturingProbably,
			StricturingType = @StricturingType,
			Polypoidal = @Polypoidal,
			PolypoidalQuantity = @PolypoidalQuantity,
			PolypoidalLargest = @PolypoidalLargest,
			PolypoidalProbably = @PolypoidalProbably,
			PolypoidalType = @PolypoidalType,
			Granuloma = @Granuloma,
			GranulomaQuantity = @GranulomaQuantity,
			GranulomaLargest = @GranulomaLargest,
			Dysplastic = @Dysplastic,
			DysplasticQuantity = @DysplasticQuantity,
			DysplasticLargest = @DysplasticLargest,
			PneumatosisColi = @PneumatosisColi,
			Tattooed = @Tattooed,
			PreviouslyTattooed = @PreviouslyTattooed,
			TattooType = @TattooType,
			TattooedQuantity = @TattooedQty,
			TattooedBy = @TattooedBy,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = GETDATE()
		WHERE 
			SiteId = @SiteId
	END

	--Save Polypectomy in ERS_UpperGITherapeutics
	IF (@Insert=1) --only on an insert?.. so if they go and change in Therapeutic types and come back here and alter changes wont be carried across again
	BEGIN
	DECLARE @RemovalType tinyint
	DECLARE @Removal tinyint
	DECLARE @SentToLabs int

		IF @Sessile = 1 OR @Pedunculated = 1 OR @Pseudopolyps = 1
		BEGIN
			IF @Sessile = 1
			BEGIN
				SET @Removal = @SessileRemoval
				SET @RemovalType = @SessileRemovalMethod
				SET @SentToLabs = ISNULL(@SessileToLabs,0)
			END
			ELSE IF @Pedunculated = 1
			BEGIN
				SET @Removal = @PedunculatedRemoval
				SET @RemovalType = @PedunculatedRemovalMethod
				SET @SentToLabs = ISNULL(@PedunculatedToLabs,0)
			END
			ELSE IF @Pseudopolyps = 1
			BEGIN
				SET @Removal = @PseudopolypsRemoval
				SET @RemovalType = @PseudopolypsRemovalMethod
				SET @SentToLabs = ISNULL(@PseudopolypsToLabs,0)
			END	

			IF @Removal > 0 OR @RemovalType > 0
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM ERS_UpperGITherapeutics WHERE SiteId = @SiteId)
				BEGIN
					INSERT INTO ERS_UpperGITherapeutics (SiteId,	Polypectomy,	PolypectomyRemoval, PolypectomyRemovalType, CarriedOutRole, WhoCreatedId, WhenCreated) 
					VALUES (@SiteId,	1,	@Removal, @RemovalType, 1, @LoggedInUserId, GETDATE())

					IF NOT EXISTS (SELECT 1 FROM ERS_RecordCount WHERE ProcedureId = @proc_id AND SiteId = @SiteId AND Identifier = 'Therapeutic Procedures')
					BEGIN
						INSERT INTO ERS_RecordCount ([ProcedureId],	[SiteId], [Identifier], [RecordCount])
						VALUES (@proc_id, @SiteId, 'Therapeutic Procedures', 1)
					END 
				END
				ELSE IF EXISTS (SELECT 1 FROM ERS_UpperGITherapeutics WHERE SiteId = @SiteId AND CarriedOutRole = 1)
				BEGIN
					UPDATE ERS_UpperGITherapeutics
					SET Polypectomy = 1,						
						PolypectomyRemoval = @Removal,
						PolypectomyRemovalType = @RemovalType,
						WhoUpdatedId = @LoggedInUserId,
						WhenUpdated = GETDATE()
					WHERE
						SiteId = @SiteId AND
						CarriedOutRole = 1
				END
				ELSE
				BEGIN
					UPDATE ERS_UpperGITherapeutics
					SET Polypectomy = 1,						
						PolypectomyRemoval = @Removal,
						PolypectomyRemovalType = @RemovalType,
						WhoUpdatedId = @LoggedInUserId,
						WhenUpdated = GETDATE()
					WHERE 
						SiteId = @SiteId AND
						CarriedOutRole = 2
				END
			END

			IF @SentToLabs > 0 
			BEGIN
				--update specimens as endo took a polypectomy which is a specimen
				IF NOT EXISTS (SELECT 1 FROM ERS_UpperGISpecimens WHERE SiteId = @SiteId)
				BEGIN
					INSERT INTO ERS_UpperGISpecimens (SiteId, Polypectomy, PolypectomyQty, WhoCreatedId, WhenCreated)
					VALUES (@SiteId, 1, @SentToLabs, @LoggedInUserId, GETDATE())
				END
				ELSE
					UPDATE ERS_UpperGISpecimens 
					SET Polypectomy = 1, 
						PolypectomyQty = (ISNULL(PolypectomyQty, 0) + @SentToLabs), 
						WhoUpdatedId = @LoggedInUserId, 
						WhenUpdated = GETDATE() 
					WHERE SiteId = @SiteId

				IF NOT EXISTS (SELECT 1 FROM ERS_RecordCount WHERE SiteId= @SiteId AND Identifier = 'Specimens Taken')
					INSERT INTO ERS_RecordCount ([ProcedureId],	[SiteId], [Identifier], [RecordCount])
					VALUES (@proc_id, @SiteId, 'Specimens Taken', 1)

				--prefill follow up tab as endo is now awaiting pathology results as a specimen was taken
				IF NOT EXISTS (SELECT 1 FROM ERS_UpperGIFollowUp WHERE ProcedureId = @proc_id)
				BEGIN
					INSERT INTO ERS_UpperGIFollowUp (ProcedureId, AwaitingPathologyResults, WhoCreatedId, WhenCreated)
					VALUES (@proc_id, 1, @LoggedInUserId, GETDATE())
				END
				ELSE
					UPDATE ERS_UpperGIFollowUp 
					SET AwaitingPathologyResults = 1, 
						WhoUpdatedId = @LoggedInUserId, 
						WhenUpdated = GETDATE()  
					WHERE ProcedureId = @proc_id


			END
		END	

		IF @Tattooed =1 
		BEGIN
			--Save Tattoo/Marking in ERS_UpperGITherapeutics
			IF NOT EXISTS(SELECT 1 FROM dbo.ERS_UpperGITherapeutics eug WHERE eug.SiteId = @SiteId AND eug.CarriedOutRole = @TattooedBy)
			BEGIN
				INSERT INTO ERS_UpperGITherapeutics (SiteId,	Marking,	MarkingType, MarkedQuantity, CarriedOutRole, WhoCreatedId, WhenCreated) 
				VALUES (@SiteId,	@Tattooed,	@TattooType, @TattooedQty, @TattooedBy, @LoggedInUserId, GETDATE())

				IF NOT EXISTS (SELECT 1 FROM ERS_RecordCount WHERE ProcedureId = @proc_id AND SiteId = @SiteId AND Identifier = 'Therapeutic Procedures')
				BEGIN
					INSERT INTO ERS_RecordCount ([ProcedureId],	[SiteId], [Identifier], [RecordCount])
					VALUES (@proc_id, @SiteId, 'Therapeutic Procedures', 1)
				END 
			END
			ELSE
			BEGIN
				UPDATE ERS_UpperGITherapeutics
				SET Marking = @Tattooed,						
					MarkingType = @TattooType,
					MarkedQuantity = @TattooedQty,
					WhoUpdatedId = @LoggedInUserId,
					WhenUpdated = GETDATE()
				WHERE 
					SiteId = @SiteId AND
					CarriedOutRole = @TattooedBy
			END
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
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'CanEditDropdowns' AND Object_ID = Object_ID(N'ERS_Users'))
BEGIN
	SET QUOTED_IDENTIFIER ON
	SET ANSI_NULLS ON
	ALTER TABLE ERS_Users ADD CanEditDropdowns BIT NOT NULL CONSTRAINT DF_Users_CanEditDropdowns DEFAULT 1
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'CanEditDropdowns' AND Object_ID = Object_ID(N'ERSAudit.ERS_Users_Audit'))
BEGIN
	SET QUOTED_IDENTIFIER ON
	SET ANSI_NULLS ON
	ALTER TABLE ERSAudit.ERS_Users_Audit ADD CanEditDropdowns BIT NOT NULL CONSTRAINT DF_Users_Audit_CanEditDropdowns DEFAULT 1
END

--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'abnormalities_polyps_save','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_polyps_save]
(
	@SiteId INT,
	@None BIT,
	@Sessile BIT,
	@SessileType TINYINT,
	@SessileBenignType TINYINT,
	@SessileQty INT,
	@SessileMultiple BIT,
	@SessileLargest DECIMAL(6,2),
	@SessileNumExcised INT,
	@SessileNumRetrieved INT,
	@SessileNumToLabs INT,
	@SessileEroded BIT,
	@SessileUlcerated BIT,
	@SessileOverlyingClot BIT,
	@SessileActiveBleeding BIT,
	@SessileOverlyingOldBlood BIT,
	@Pedunculated BIT,
	@PedunculatedType TINYINT,
	@PedunculatedBenignType TINYINT,
	@PedunculatedQty INT,
	@PedunculatedMultiple BIT,
	@PedunculatedLargest DECIMAL(6,2),
	@PedunculatedNumExcised INT,
	@PedunculatedNumRetrieved INT,
	@PedunculatedNumToLabs INT,
	@PedunculatedEroded BIT,
	@PedunculatedUlcerated BIT,
	@PedunculatedOverlyingClot BIT,
	@PedunculatedActiveBleeding BIT,
	@PedunculatedOverlyingOldBlood BIT,
	@Submucosal BIT,
	@SubmucosalType TINYINT,
	@SubmucosalBenignType TINYINT,
	@SubmucosalQty INT,
	@SubmucosalMultiple BIT,
	@SubmucosalLargest DECIMAL(6,2),
	@SubmucosalNumExcised INT,
	@SubmucosalNumRetrieved INT,
	@SubmucosalNumToLabs INT,
	@SubmucosalEroded BIT,
	@SubmucosalUlcerated BIT,
	@SubmucosalOverlyingClot BIT,
	@SubmucosalActiveBleeding BIT,
	@SubmucosalOverlyingOldBlood BIT,
	@PolypectomyRemoval TINYINT,
	@PolypectomyRemovalType TINYINT,
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
			
	IF NOT EXISTS (SELECT 1 FROM ERS_UpperGIAbnoPolyps WHERE SiteId = @SiteId)
	BEGIN
		INSERT INTO ERS_UpperGIAbnoPolyps (
			SiteId,
			[None],
			Sessile,
			SessileType,
			SessileBenignType,
			SessileQty,
			SessileMultiple,
			SessileLargest,
			SessileNumExcised,
			SessileNumRetrieved,
			SessileNumToLabs,
			SessileEroded,
			SessileUlcerated,
			SessileOverlyingClot,
			SessileActiveBleeding,
			SessileOverlyingOldBlood,
			Pedunculated,
			PedunculatedType,
			PedunculatedBenignType,
			PedunculatedQty,
			PedunculatedMultiple,
			PedunculatedLargest,
			PedunculatedNumExcised,
			PedunculatedNumRetrieved,
			PedunculatedNumToLabs,
			PedunculatedEroded,
			PedunculatedUlcerated,
			PedunculatedOverlyingClot,
			PedunculatedActiveBleeding,
			PedunculatedOverlyingOldBlood,
			Submucosal,
			SubmucosalType,
			SubmucosalBenignType,
			SubmucosalQty,
			SubmucosalMultiple,
			SubmucosalLargest,
			SubmucosalNumExcised,
			SubmucosalNumRetrieved,
			SubmucosalNumToLabs,
			SubmucosalEroded,
			SubmucosalUlcerated,
			SubmucosalOverlyingClot,
			SubmucosalActiveBleeding,
			SubmucosalOverlyingOldBlood,
			WhoCreatedId,
			WhenCreated) 
		VALUES (
			@SiteId,
			@None,
			@Sessile,
			@SessileType,
			@SessileBenignType,
			@SessileQty,
			@SessileMultiple,
			@SessileLargest,
			@SessileNumExcised,
			@SessileNumRetrieved,
			@SessileNumToLabs,
			@SessileEroded,
			@SessileUlcerated,
			@SessileOverlyingClot,
			@SessileActiveBleeding,
			@SessileOverlyingOldBlood,
			@Pedunculated,
			@PedunculatedType,
			@PedunculatedBenignType,
			@PedunculatedQty,
			@PedunculatedMultiple,
			@PedunculatedLargest,
			@PedunculatedNumExcised,
			@PedunculatedNumRetrieved,
			@PedunculatedNumToLabs,
			@PedunculatedEroded,
			@PedunculatedUlcerated,
			@PedunculatedOverlyingClot,
			@PedunculatedActiveBleeding,
			@PedunculatedOverlyingOldBlood,
			@Submucosal,
			@SubmucosalType,
			@SubmucosalBenignType,
			@SubmucosalQty,
			@SubmucosalMultiple,
			@SubmucosalLargest,
			@SubmucosalNumExcised,
			@SubmucosalNumRetrieved,
			@SubmucosalNumToLabs,
			@SubmucosalEroded,
			@SubmucosalUlcerated,
			@SubmucosalOverlyingClot,
			@SubmucosalActiveBleeding,
			@SubmucosalOverlyingOldBlood,
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
			'Polyps',
			1)
	END
	
	ELSE IF (@None=0 AND @Sessile=0 AND @Pedunculated=0 AND @Submucosal=0)
	BEGIN
		DELETE FROM ERS_UpperGIAbnoPolyps 
		WHERE SiteId = @SiteId

		DELETE FROM ERS_RecordCount 
		WHERE SiteId = @SiteId
		AND Identifier = 'Polyps'
	END

	ELSE
	BEGIN
		UPDATE 
			ERS_UpperGIAbnoPolyps
		SET 
			[None] = @None,
			Sessile = @Sessile,
			SessileType = @SessileType,
			SessileBenignType = @SessileBenignType,
			SessileQty = @SessileQty,
			SessileMultiple = @SessileMultiple,
			SessileLargest = @SessileLargest,
			SessileNumExcised = @SessileNumExcised,
			SessileNumRetrieved = @SessileNumRetrieved,
			SessileNumToLabs = @SessileNumToLabs,
			SessileEroded = @SessileEroded,
			SessileUlcerated = @SessileUlcerated,
			SessileOverlyingClot = @SessileOverlyingClot,
			SessileActiveBleeding = @SessileActiveBleeding,
			SessileOverlyingOldBlood = @SessileOverlyingOldBlood,
			Pedunculated = @Pedunculated,
			PedunculatedType = @PedunculatedType,
			PedunculatedBenignType = @PedunculatedBenignType,
			PedunculatedQty = @PedunculatedQty,
			PedunculatedMultiple = @PedunculatedMultiple,
			PedunculatedLargest = @PedunculatedLargest,
			PedunculatedNumExcised = @PedunculatedNumExcised,
			PedunculatedNumRetrieved = @PedunculatedNumRetrieved,
			PedunculatedNumToLabs = @PedunculatedNumToLabs,
			PedunculatedEroded = @PedunculatedEroded,
			PedunculatedUlcerated = @PedunculatedUlcerated,
			PedunculatedOverlyingClot = @PedunculatedOverlyingClot,
			PedunculatedActiveBleeding = @PedunculatedActiveBleeding,
			PedunculatedOverlyingOldBlood = @PedunculatedOverlyingOldBlood,
			Submucosal = @Submucosal,
			SubmucosalType = @SubmucosalType,
			SubmucosalBenignType = @SubmucosalBenignType,
			SubmucosalQty = @SubmucosalQty,
			SubmucosalMultiple = @SubmucosalMultiple,
			SubmucosalLargest = @SubmucosalLargest,
			SubmucosalNumExcised = @SubmucosalNumExcised,
			SubmucosalNumRetrieved = @SubmucosalNumRetrieved,
			SubmucosalNumToLabs = @SubmucosalNumToLabs,
			SubmucosalEroded = @SubmucosalEroded,
			SubmucosalUlcerated = @SubmucosalUlcerated,
			SubmucosalOverlyingClot = @SubmucosalOverlyingClot,
			SubmucosalActiveBleeding = @SubmucosalActiveBleeding,
			SubmucosalOverlyingOldBlood = @SubmucosalOverlyingOldBlood,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = GETDATE()
		WHERE 
			SiteId = @SiteId
	END

	--Check the related Therapeutics checkboxes for Polyps
	IF @PolypectomyRemoval > 0 OR @PolypectomyRemovalType > 0
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ERS_UpperGITherapeutics WHERE SiteId = @SiteId)
		BEGIN
			INSERT INTO ERS_UpperGITherapeutics (SiteId,	Polypectomy,	PolypectomyRemoval,	PolypectomyRemovalType, CarriedOutRole) 
			VALUES (@SiteId,	1,	@PolypectomyRemoval,	@PolypectomyRemovalType, 1)

			INSERT INTO ERS_RecordCount ([ProcedureId],	[SiteId],	[Identifier],	[RecordCount])
			VALUES (@proc_id,	@SiteId,	'Therapeutic Procedures',	1)
		END
		ELSE IF EXISTS (SELECT 1 FROM ERS_UpperGITherapeutics WHERE SiteId = @SiteId AND CarriedOutRole = 1)
		BEGIN
			UPDATE 
				ERS_UpperGITherapeutics
			SET 
				Polypectomy = 1,
				PolypectomyRemoval = @PolypectomyRemoval,
				PolypectomyRemovalType = @PolypectomyRemovalType
			WHERE 
				SiteId = @SiteId AND
				CarriedOutRole = 1
		END
		ELSE 
		BEGIN
			UPDATE 
				ERS_UpperGITherapeutics
			SET 
				Polypectomy = 1,
				PolypectomyRemoval = @PolypectomyRemoval,
				PolypectomyRemovalType = @PolypectomyRemovalType
			WHERE 
				SiteId = @SiteId AND
				CarriedOutRole = 2
		END
	END

	--Check the related Specimens checkboxes for Polyps
	IF @SessileNumToLabs > 0 OR @PedunculatedNumToLabs > 0 OR @SubmucosalNumToLabs > 0
	BEGIN
		DECLARE @SentToLabs INT
		IF @Sessile = 1
		BEGIN
			SET @SentToLabs = ISNULL(@SessileNumToLabs,0)
		END
		ELSE IF @Pedunculated = 1
		BEGIN
			SET @SentToLabs = ISNULL(@PedunculatedNumToLabs,0)
		END
		ELSE IF @Submucosal = 1
		BEGIN
			SET @SentToLabs = ISNULL(@SubmucosalNumToLabs,0)
		END	

		IF NOT EXISTS (SELECT 1 FROM ERS_UpperGISpecimens WHERE SiteId = @SiteId)
		BEGIN
			INSERT INTO ERS_UpperGISpecimens (SiteId, Polypectomy, PolypectomyQty) 
			VALUES (@SiteId,	1, @SentToLabs)

			INSERT INTO ERS_RecordCount ([ProcedureId],	[SiteId],	[Identifier],	[RecordCount])
			VALUES (@proc_id,	@SiteId,	'Specimens Taken',	1)
		END
		ELSE
		BEGIN
			UPDATE 
				ERS_UpperGISpecimens
			SET 
				Polypectomy = 1,
				PolypectomyQty = @SentToLabs
			WHERE 
				SiteId = @SiteId
		END

		IF NOT EXISTS (SELECT 1 FROM ERS_UpperGIFollowUp WHERE ProcedureId = @proc_id)
		BEGIN
			INSERT INTO ERS_UpperGIFollowUp (ProcedureId, AwaitingPathologyResults, WhoCreatedId, WhenCreated)
			VALUES (@proc_id, 1, @LoggedInUserId, GETDATE())
		END
		ELSE
		BEGIN
			UPDATE ERS_UpperGIFollowUp 
			SET AwaitingPathologyResults = 1, 
				WhoUpdatedId = @LoggedInUserId, 
				WhenUpdated = GETDATE()  
			WHERE ProcedureId = @proc_id
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
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------
--Follow up not to be highlighted after Specimen selection
-----------------------------------------------------

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC DropIfExist 'specimens_ogd_save', 'S';
GO

CREATE PROCEDURE [dbo].[specimens_ogd_save]
(
	@SiteId INT,
	@None BIT,
	@BrushCytology BIT,
	@Biopsy BIT,
	@biopsiesTakenAtRandom BIT,
	@BiopsyQtyHistology INT,
	@BiopsyQtyMicrobiology INT,
	@BiopsyQtyVirology INT,
	@BiopsyDistance DECIMAL(6,2) = NULL,
	@ForcepType INT,
	@ForcepSerialNo NVARCHAR(50),
	@Urease BIT,
	@UreaseResult TINYINT, --1=Positive/2=Negative
	@Polypectomy BIT,
	@PolypectomyQty INT,
	@HotBiopsy BIT,
	@NeedleAspirate BIT,	
	@NeedleAspirateHistology BIT,
	@NeedleAspirateMicrobiology BIT, 
	@NeedleAspirateVirology BIT,
	@GastricWashing BIT,
	@Bile_PanJuice BIT,
    @Bile_PanJuiceCytology BIT,
    @Bile_PanJuiceBacteriology BIT,
    @Bile_PanJuiceAnalysis BIT,
	@EUSFNANumberOfPasses INT,
	@EUSFNANeedleGauge INT,
	@FNB BIT,
	@EUSFNBNumberOfPasses INT,
	@EUSFNBNeedleGauge INT,
	@BrushBiopsy BIT,
	@TumourMarkers BIT,
	@AmylaseLipase BIT,
	@CytologyHistology BIT,
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

	IF NOT EXISTS (SELECT 1 FROM ERS_UpperGISpecimens WHERE SiteId = @SiteId)
	BEGIN
		UPDATE ERS_Procedures
		SET ForcepType = @ForcepType, ForcepSerialNo = @ForcepSerialNo
		WHERE ProcedureId = @proc_id

		INSERT INTO ERS_UpperGISpecimens (
			SiteId,
			[None],
			BrushCytology,
			Biopsy,
			BiopsiesTakenAtRandom,
			BiopsyQtyHistology,
			BiopsyQtyMicrobiology,
			BiopsyQtyVirology,
			BiopsyDistance,
			Urease,
			UreaseResult,
			Polypectomy,
			PolypectomyQty,
			HotBiopsy,
			NeedleAspirate,
			NeedleAspirateHistology,
			NeedleAspirateMicrobiology,
			NeedleAspirateVirology,
			GastricWashing,
			Bile_PanJuice,
			Bile_PanJuiceCytology,
			Bile_PanJuiceBacteriology,
			Bile_PanJuiceAnalysis,
			EUSFNANumberOfPasses,
			EUSFNANeedleGauge,
			FNB,
			EUSFNBNumberOfPasses,
			EUSFNBNeedleGauge,
			BrushBiopsy,
			TumourMarkers,
			AmylaseLipase,
			CytologyHistology,
			WhoCreatedId,
			WhenCreated)
		VALUES (
			@SiteId,
			@None,
			@BrushCytology,
			@Biopsy,
			@BiopsiesTakenAtRandom,
			@BiopsyQtyHistology,
			@BiopsyQtyMicrobiology,
			@BiopsyQtyVirology,
			@BiopsyDistance,
			@Urease,
			@UreaseResult,
			@Polypectomy,
			@PolypectomyQty,
			@HotBiopsy,
			@NeedleAspirate,
			@NeedleAspirateHistology,
			@NeedleAspirateMicrobiology,
			@NeedleAspirateVirology,
			@GastricWashing,
			@Bile_PanJuice,
			@Bile_PanJuiceCytology,
			@Bile_PanJuiceBacteriology,
			@Bile_PanJuiceAnalysis,
			@EUSFNANumberOfPasses,
			@EUSFNANeedleGauge,
			@FNB,
			@EUSFNBNumberOfPasses,
			@EUSFNBNeedleGauge,
			@BrushBiopsy,
			@TumourMarkers,
			@AmylaseLipase,
			@CytologyHistology,
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
			'Specimens Taken',
			1)
	END

	ELSE IF (@None = 0 AND @BrushCytology = 0 AND @Biopsy = 0 AND @Urease = 0 AND @Polypectomy = 0 AND @HotBiopsy = 0 
			AND @NeedleAspirate = 0 AND @NeedleAspirateHistology = 0 AND @NeedleAspirateMicrobiology = 0 AND @NeedleAspirateVirology = 0 AND @GastricWashing = 0 
			AND @Bile_PanJuice = 0 AND @FNB = 0 AND @BrushBiopsy = 0 AND @TumourMarkers = 0 AND @AmylaseLipase = 0 AND @CytologyHistology = 0)
	BEGIN
		UPDATE ERS_Procedures
		SET ForcepType = NULL, ForcepSerialNo = NULL
		WHERE ProcedureId = @proc_id

		DELETE FROM ERS_UpperGISpecimens
		WHERE SiteId = @SiteId

		DELETE FROM ERS_RecordCount 
		WHERE SiteId = @SiteId
		AND Identifier = 'Specimens Taken'
	END
	
	ELSE
	BEGIN
		UPDATE ERS_Procedures
		SET ForcepType = @ForcepType, ForcepSerialNo = @ForcepSerialNo
		WHERE ProcedureId = @proc_id

		UPDATE 
			ERS_UpperGISpecimens
		SET 
			[None] = @None,
			BrushCytology = @BrushCytology,
			Biopsy = @Biopsy,
			BiopsiesTakenAtRandom = @BiopsiesTakenAtRandom,
			BiopsyQtyHistology = @BiopsyQtyHistology,
			BiopsyQtyMicrobiology = @BiopsyQtyMicrobiology,
			BiopsyQtyVirology = @BiopsyQtyVirology,
			BiopsyDistance = @BiopsyDistance,
			Urease = @Urease,
			UreaseResult = @UreaseResult,
			Polypectomy = @Polypectomy,
			PolypectomyQty = @PolypectomyQty,
			HotBiopsy = @HotBiopsy,
			NeedleAspirate = @NeedleAspirate,
			NeedleAspirateHistology = @NeedleAspirateHistology,
			NeedleAspirateMicrobiology = @NeedleAspirateMicrobiology,
			NeedleAspirateVirology = @NeedleAspirateVirology,
			GastricWashing = @GastricWashing,
			Bile_PanJuice = @Bile_PanJuice,
			Bile_PanJuiceCytology = @Bile_PanJuiceCytology,
			Bile_PanJuiceBacteriology = @Bile_PanJuiceBacteriology,
			Bile_PanJuiceAnalysis = @Bile_PanJuiceAnalysis,
			EUSFNANumberOfPasses = @EUSFNANumberOfPasses,
			EUSFNANeedleGauge = @EUSFNANeedleGauge,
			FNB = @FNB,
			EUSFNBNumberOfPasses = @EUSFNBNumberOfPasses,
			EUSFNBNeedleGauge = @EUSFNBNeedleGauge,
			BrushBiopsy = @BrushBiopsy,
			TumourMarkers = @TumourMarkers,
			AmylaseLipase = @AmylaseLipase,
			CytologyHistology = @CytologyHistology,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = GETDATE()
		WHERE 
			SiteId = @SiteId
	END

	--Awaiting pathology results want to be automatically checked if any specimens have been taken EXCEPT Urease.
	IF (@BrushCytology = 1 OR @Biopsy = 1 OR @Polypectomy = 1 OR @HotBiopsy = 1 
			OR @NeedleAspirate = 1 OR @NeedleAspirateHistology = 1 OR @NeedleAspirateMicrobiology = 1 OR @NeedleAspirateVirology = 1 OR @GastricWashing = 1 
			OR @Bile_PanJuice = 1 OR @FNB = 1 OR @BrushBiopsy = 1 OR @TumourMarkers = 1 OR @AmylaseLipase = 1 OR @CytologyHistology = 1)
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ERS_UpperGIFollowUp WHERE ProcedureId = @proc_id)
		BEGIN
			INSERT INTO ERS_UpperGIFollowUp (ProcedureId, AwaitingPathologyResults) 
			VALUES (@proc_id, 1)

			-------Not to highlight followup button under Specimen window (Highlight only when user click on save in the FollowUp screen)
			--INSERT INTO ERS_RecordCount ([ProcedureId], [SiteId], [Identifier],[RecordCount])
			--VALUES (@proc_id,NULL,'Follow Up', 1)
		END
		ELSE
		BEGIN
			UPDATE ERS_UpperGIFollowUp
			SET AwaitingPathologyResults = 1
			WHERE ProcedureId = @proc_id
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

--------------------------------------------------------------------------------------------------------------------
--Highlight followUp button only when user click on Save
--------------------------------------------------------------------------------------------------------------------

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'ogd_followup_save','S';
GO

CREATE PROCEDURE [dbo].[ogd_followup_save]
(
	@ProcedureId INT,
	@NoFurtherTestsRequired BIT,
	@AwaitingPathologyResults BIT,
	@FurtherProcedure INT,
	@FurtherProcedureDueCount INT,
	@FurtherProcedureDueType TINYINT,
	@FurtherProcedureText NVARCHAR(500),
	@ReturnTo SMALLINT,
	@NoFurtherFollowUp BIT,
	@ReviewLocation SMALLINT,
	@ReviewDueCount INT,
	@ReviewDueType TINYINT,
	@ReviewText NVARCHAR(500),
	@Comments NVARCHAR(500),
	@PP_PFRFollowUp NVARCHAR(500),
	@CopyToPatient TINYINT,
	@CopyToPatientText NVARCHAR(500),
	@PatientNotCopiedReason NVARCHAR(500),
	@CopyToRefCon BIT,
	@CopyToRefConText NVARCHAR(500),
	@CopyToOther BIT,
	@CopyToOtherText NVARCHAR(500),
	@Salutation NVARCHAR(200),
	@LoggedInUserId INT

)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
			
	IF NOT EXISTS (SELECT 1 FROM ERS_UpperGIFollowUp WHERE ProcedureId = @ProcedureId)
	BEGIN
		INSERT INTO ERS_UpperGIFollowUp (
			ProcedureId,
			NoFurtherTestsRequired,
			AwaitingPathologyResults,
			FurtherProcedure,
			FurtherProcedureDueCount,
			FurtherProcedureDueType,
			FurtherProcedureText,
			ReturnTo,
			NoFurtherFollowUp,
			ReviewLocation,
			ReviewDueCount,
			ReviewDueType,
			ReviewText,
			Comments,
			PP_PFRFollowUp,
			CopyToPatient,
			CopyToPatientText,
			PatientNotCopiedReason,
			CopyToRefCon,
			CopyToRefConText,
			CopyToOther,
			CopyToOtherText,
			Salutation,
			WhoCreatedId,
			WhenCreated) 
		VALUES (
			@ProcedureId,
			@NoFurtherTestsRequired,
			@AwaitingPathologyResults,
			@FurtherProcedure,
			@FurtherProcedureDueCount,
			@FurtherProcedureDueType,
			@FurtherProcedureText,
			@ReturnTo,
			@NoFurtherFollowUp,
			@ReviewLocation,
			@ReviewDueCount,
			@ReviewDueType,
			@ReviewText,
			@Comments,
			@PP_PFRFollowUp,
			@CopyToPatient,
			@CopyToPatientText,
			@PatientNotCopiedReason,
			@CopyToRefCon,
			@CopyToRefConText,
			@CopyToOther,
			@CopyToOtherText,
			@Salutation,
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
			'Follow Up',
			1)
	END
	
	ELSE
	BEGIN
		UPDATE 
			ERS_UpperGIFollowUp
		SET 
			NoFurtherTestsRequired = @NoFurtherTestsRequired,
			AwaitingPathologyResults = @AwaitingPathologyResults,
			FurtherProcedure = @FurtherProcedure,
			FurtherProcedureDueCount = @FurtherProcedureDueCount,
			FurtherProcedureDueType = @FurtherProcedureDueType,
			FurtherProcedureText = @FurtherProcedureText,
			ReturnTo = @ReturnTo,
			NoFurtherFollowUp = @NoFurtherFollowUp,
			ReviewLocation = @ReviewLocation,
			ReviewDueCount = @ReviewDueCount,
			ReviewDueType = @ReviewDueType,
			ReviewText = @ReviewText,
			Comments = @Comments,
			PP_PFRFollowUp = @PP_PFRFollowUp,
			CopyToPatient = @CopyToPatient,
			CopyToPatientText = @CopyToPatientText,
			PatientNotCopiedReason = @PatientNotCopiedReason,
			CopyToRefCon = @CopyToRefCon,
			CopyToRefConText = @CopyToRefConText,
			CopyToOther = @CopyToOther,
			CopyToOtherText = @CopyToOtherText,
			Salutation = @Salutation,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = GETDATE()
		WHERE 
			ProcedureId = @ProcedureId

		IF NOT EXISTS(SELECT 1 FROM ERS_RecordCount WHERE ProcedureId = @ProcedureId AND [Identifier] = 'Follow Up')
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
				'Follow Up',
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
--------------------------------------------------------------------------------------------------------------------
----- Double procedure should retain; Patient Demographics, Co-Morbidity, ASA, premed
--------------------------------------------------------------------------------------------------------------------

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC DropIfExist 'usp_Procedure_Replicate','S';
GO

CREATE PROCEDURE [dbo].[usp_Procedure_Replicate]
(
	@ProcedureID		INT,
	@ProcedureType		INT
)
AS

SET NOCOUNT ON

DECLARE @newProcId INT

BEGIN TRANSACTION

BEGIN TRY								

	INSERT INTO [dbo].[ERS_Procedures]
           ([ProcedureType]							,[CreatedBy]					,[CreatedOn]					,[ModifiedOn]
			,[PatientId]					        ,[OperatingHospitalID]	        ,[DiagramNumber]				,[ListConsultant]
			,[Endoscopist1]							,[Endoscopist2]					,[Assistant]					,[Nurse1]
			,[Nurse2]								,[Nurse3]						--,[Instrument1]					,[Instrument2]
			,[ReferralHospitalNo]					,[ReferralConsultantNo]			,[GPReferralFlag]				,[PatientStatus]
			,[Ward]									,[PatientType]					,[ReferralConsultantSpeciality]	
			,[PatientConsent]						,[GPCode]						,[CategoryListId]				,[EmergencyProcType]				
			,[GPPracticeCode]						,[ListType]						,[Endo1Role]					,[Endo2Role]					
			,[FormerProcedureId]					,[ImagePortId]					,[WhoCreatedId])
		SElECT 
			@ProcedureType							,p.[CreatedBy]					,p.[CreatedOn]					,GETDATE()
			,p.[PatientId]					        ,p.[OperatingHospitalID]	    ,p.[DiagramNumber]				,p.[ListConsultant]
			,p.[Endoscopist1]						,p.[Endoscopist2]				,p.[Assistant]					,p.[Nurse1]
			,p.[Nurse2]								,p.[Nurse3]						--,p.[Instrument1]				,p.[Instrument2]
			,p.[ReferralHospitalNo]					,p.[ReferralConsultantNo]		,p.[GPReferralFlag]				,p.[PatientStatus]
			,p.[Ward]								,p.[PatientType]				,p.[ReferralConsultantSpeciality]	
			,p.[PatientConsent]						,p.[GPCode]						,p.[CategoryListId]				,p.[EmergencyProcType]
			,p.[GPPracticeCode]						,p.[ListType]					,p.[Endo1Role]					,p.[Endo2Role]					
			,@ProcedureID							,p.[ImagePortId]				,p.[WhoCreatedId]	
		FROM ERS_Procedures p 
		WHERE p.ProcedureId = @ProcedureID

	SET @newProcId = SCOPE_IDENTITY()

	--Copy ProceduresReporting (PP fields)
	INSERT INTO [dbo].[ERS_ProceduresReporting]
           ( [PP_PatAddress]						,[PP_RefHosp]					,[PP_CNN]						,[PP_RepDateAndTime]
			,[PP_RepType]							,[PP_GP]						,[PP_PatStatus]					,[PP_Ward]
			,[PP_RefCons]							,[PP_Endos]						,[PP_Premed]
			--,[PP_Indic]								,[PP_MainReportBody]			,[PP_Diagnoses]				,[PP_Instrument]	
			,[PP_Endo1]						
			,[PP_CCRefCons]							,[PP_CCOther]					,[PP_CCPatient]					,[PP_RepHead]					
			,[PP_RepSubHead]						,[PP_OpHosp]					,[PP_Room_ID]					,[PP_Priority]					
			,[PP_GPName]							,[PP_GPAddress]
			,ProcedureId)
		SElECT 	
			 pr.[PP_PatAddress]						,pr.[PP_RefHosp]				,pr.[PP_CNN]					,pr.[PP_RepDateAndTime]
			,pr.[PP_RepType]						,pr.[PP_GP]						,pr.[PP_PatStatus]				,pr.[PP_Ward]
			,pr.[PP_RefCons]						,pr.[PP_Endos]					,pr.[PP_Premed]
			--,pr.[PP_Indic]							,pr.[PP_MainReportBody]			,pr.[PP_Diagnoses]			,pr.[PP_Instrument]	
			,pr.[PP_Endo1]						
			,pr.[PP_CCRefCons]						,pr.[PP_CCOther]				,pr.[PP_CCPatient]				,pr.[PP_RepHead]					
			,pr.[PP_RepSubHead]						,pr.[PP_OpHosp]					,pr.[PP_Room_ID]				,pr.[PP_Priority]					
			,pr.[PP_GPName]							,pr.[PP_GPAddress]								
			,@newProcId
		FROM ERS_ProceduresReporting pr 
		WHERE pr.ProcedureId = @ProcedureID

	--Copy Premedication
	INSERT INTO ERS_UpperGIPremedication (ProcedureId, DrugNo, DrugName, Dose, Units, DeliveryMethod)
	SELECT @newProcId, DrugNo, DrugName, Dose, Units, DeliveryMethod
	FROM ERS_UpperGIPremedication
	WHERE ProcedureId = @ProcedureID

	IF @@ROWCOUNT > 0
	BEGIN
		--INSERT INTO ERS_RecordCount ([ProcedureId], [SiteId], [Identifier], [RecordCount])
		--VALUES (@newProcId, NULL, 'Premed', 1)

		EXEC ogd_premedication_summary_update @newProcId
	END 

	--Copy Co-Morbidity, ASA from Indications
	INSERT INTO ERS_UpperGIIndications (ProcedureId, CoMorbidityNone,
			Angina,			Asthma,				COPD,			DiabetesMellitus,		DiabetesMellitusType,
			Epilepsy,		HemiPostStroke,		Hypertension,	MI,						Obesity,
			TIA,			OtherCoMorbidity,	ASAStatus, 
			ColonFamilyAdditionalText, ColonAlterBowelHabit, ColonRectalBleeding, ColonAnaemiaType, ColonAssessment, 
			ColonAssessmentType, ColonSurveillance, ColonFamily, ColonFamilyType, ColonCarcinoma, ColonPolyps, ColonDysplasia)
	SELECT @newProcId, CoMorbidityNone,
			Angina,			Asthma,				COPD,			DiabetesMellitus,		DiabetesMellitusType,
			Epilepsy,		HemiPostStroke,		Hypertension,	MI,						Obesity,
			TIA,			OtherCoMorbidity,	ASAStatus,
			'',0,0,0,0,0,0,0,0,0,0,0
	FROM ERS_UpperGIIndications WHERE ProcedureId = @ProcedureID
	
	IF @@ROWCOUNT > 0
	BEGIN
		--INSERT INTO ERS_RecordCount ([ProcedureId], [SiteId], [Identifier], [RecordCount])
		--VALUES (@newProcId, NULL, 'Indications', 1)

		EXEC ogd_indications_summary_update @newProcId
	END 

	--Copy QA (Management & Sedation/Comfort score) - NOT TO BE COPIED (DAWN CONFIRMED @ 21/06/2019)
	--INSERT INTO ERS_UpperGIQA (
	--	[ProcedureId]			,[NoNotes]			,[ReferralLetter]					,[ManagementNone]		,[PulseOximetry]
	--	,[IVAccess]				,[IVAntibiotics]	,[Oxygenation]						,[OxygenationMethod]	,[OxygenationFlowRate]
	--	,[ContinuousECG]		,[BP]				,[BPSystolic]						,[BPDiastolic]			,[ManagementOther]
	--	,[ManagementOtherText]	,[PatSedation]      ,[PatSedationAsleepResponseState]   ,[PatDiscomfortNurse]	,[PatDiscomfortEndo])
	--SELECT 
	--	@newProcId				,[NoNotes]			,[ReferralLetter]					,[ManagementNone]		,[PulseOximetry]
	--	,[IVAccess]				,[IVAntibiotics]	,[Oxygenation]						,[OxygenationMethod]	,[OxygenationFlowRate]
	--	,[ContinuousECG]		,[BP]				,[BPSystolic]						,[BPDiastolic]			,[ManagementOther]
	--	,[ManagementOtherText]	,[PatSedation]      ,[PatSedationAsleepResponseState]   ,[PatDiscomfortNurse]	,[PatDiscomfortEndo]
	--FROM ERS_UpperGIQA
	--WHERE ProcedureId = @ProcedureID

	--IF @@ROWCOUNT > 0
	--BEGIN
	--	INSERT INTO ERS_RecordCount ([ProcedureId], [SiteId], [Identifier], [RecordCount])
	--	VALUES (@newProcId, NULL, 'QA', 1)

	--	EXEC ogd_qa_summary_update @newProcId
	--END 

	SELECT @newProcId AS ProcedureId

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

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'usp_Procedures_SelectByPatient','S';
GO

CREATE PROCEDURE [dbo].[usp_Procedures_SelectByPatient]
(
	@PatientId INT,
	@IncludeOldProcs BIT = 1,
	@ActiveProceduresOnly BIT = 1 -- Only Select the Active Records-> IsActive=True!
)
AS

SET NOCOUNT ON

	-- NEW System procedures
	SELECT * INTO #procs FROM (
		SELECT 
			p.ProcedureId AS ProcedureId,
			0 AS EpisodeNo,
			p.ProcedureType AS ProcedureType,
			CONVERT(VARCHAR(50),'') AS PatientComboId,
			p.DiagramNumber AS DiagramNumber,
			CONVERT(VARCHAR(100), CONVERT(VARCHAR, p.CreatedOn, 103) + 
			' - ' + 
			CASE pt.ProcedureType 
				WHEN 'Gastroscopy' THEN 'Upper GI' 
				--WHEN 'Sigmoidoscopy' THEN 'Colonoscopy' 
				--WHEN 'Proctoscopy' THEN 'Colonoscopy' 
				ELSE pt.ProcedureType 
						END)    AS DisplayName,
			1 AS ERS,
			p.CreatedOn,
			p.ModifiedOn,
			0 AS Locked,--ISNULL(pa.Locked,0), 
			0 AS LockedBy,--ISNULL(pa.LockedBy,0), 
			NULL AS LockedOn,--pa.LockedOn,
			ISNULL(CAST(SurgicalSafetyCheckListCompleted AS VARCHAR(50)),'') AS SurgicalSafetyCheckListCompleted,
			(SELECT TOP(1) CASE s.ReportLocking WHEN 1 THEN 0
												ELSE 
							CASE WHEN  CAST(CAST(CONVERT(DATE,DATEADD(day,s.LockingDays, p.CreatedOn)) as varchar(50)) + ' ' +s.LockingTime as datetime) <= GETDATE() THEN 1 ELSE 0 END
								END  
							FROM ERS_SystemConfig s) AS isProcedureLocked, -1 AS  ColonType, CONVERT(INT,ISNULL(ProcedureCompleted,0)) AS ProcedureCompleted
			, IsNull(P.DNA,'')		AS DNA_Reason	
			, IsNull(PR.PP_DNA,'')	AS DNA_Reason_PP_Text	
			,p.BreathTestResult AS BreathTest
			,CASE WHEN pho.photoCount IS NULL THEN 0 ELSE 1 END HasPhotos
		FROM 
			ERS_Procedures p
		INNER JOIN 
			ERS_ProcedureTypes pt ON p.ProcedureType = pt.ProcedureTypeId
		INNER JOIN 
			ERS_VW_Patients pa ON p.PatientId = pa.PatientId
		LEFT JOIN ERS_ProceduresReporting AS PR ON p.ProcedureId=PR.ProcedureId
		LEFT JOIN (SELECT count(dbo.ers_photos.PhotoId) AS photoCount, procedureid FROM ers_photos GROUP BY procedureid) as pho ON p.ProcedureId = pho.ProcedureId
		WHERE 
			p.PatientId = @PatientId
			AND p.IsActive  = @ActiveProceduresOnly
	) AS temptemp



	-- OLD System procedures
	IF @IncludeOldProcs = 1
	BEGIN
	
		DECLARE @PatientComboId VARCHAR(24)
		SELECT @PatientComboId = [Combo ID] FROM Patient p INNER JOIN ERS_VW_Patients v ON p.[Patient No] = v.UGIPatientId WHERE v.PatientId =  @PatientId

       --SELECT * INTO #oldprocs FROM (
       --       SELECT [Episode No], 1 AS ProcTypeNum, -1 as ColonType ,[Episode Date] FROM  Episode
       --       WHERE [Patient No] = @PatientComboId AND @IncludeOldProcs = 1 AND [Status] IS NOT NULL       AND SUBSTRING([Status], 1, 1) = 1 
       --UNION
       --       SELECT        [Episode No], 2 AS ProcTypeNum, -1 as ColonType,[Episode Date]       FROM Episode
       --       WHERE  [Patient No] = @PatientComboId    AND @IncludeOldProcs = 1 AND [Status] IS NOT NULL AND SUBSTRING([Status], 2, 1) = 1 
       --UNION
       --       SELECT e.[Episode No],   3 AS ProcTypeNum, c.[Procedure type] as ColonType ,e.[Episode Date] FROM Episode e inner join [Colon Procedure] c on e.[Episode No]=c.[Episode No]
       --       WHERE e.[Patient No] = @PatientComboId AND @IncludeOldProcs = 1 AND e.[Status] IS NOT NULL AND SUBSTRING(e.[Status], 3, 1) = 1  AND c.[Procedure type] <> 2      
       --UNION
       --       SELECT [Episode No], 4 AS ProcTypeNum, 2 as ColonType  ,[Episode Date]      FROM Episode
       --       WHERE [Patient No] = @PatientComboId AND @IncludeOldProcs = 1 AND [Status] IS NOT NULL AND SUBSTRING([Status], 4, 1) = 1 
       --UNION 
       --       SELECT [Episode No], 5 AS ProcTypeNum     , -1 as ColonType    ,[Episode Date]      FROM Episode
       --       WHERE [Patient No] = @PatientComboId    AND @IncludeOldProcs = 1          AND [Status] IS NOT NULL AND SUBSTRING([Status], 5, 1) = 1 
       --UNION 
       --       SELECT [Episode No], 6 AS ProcTypeNum     , -1 as ColonType    ,[Episode Date]      FROM Episode
       --       WHERE [Patient No] = @PatientComboId    AND @IncludeOldProcs = 1 AND [Status] IS NOT NULL   AND SUBSTRING([Status], 6, 1) = 1 
       --UNION
       --       SELECT [Episode No], 8 AS ProcTypeNum     , -1 as ColonType    ,[Episode Date]      FROM Episode
       --       WHERE [Patient No] = @PatientComboId AND @IncludeOldProcs = 1 AND [Status] IS NOT NULL       AND SUBSTRING([Status], 7, 1) = 1 
       --UNION
       --       SELECT [Episode No], 9 AS ProcTypeNum    , -1 as ColonType    ,[Episode Date]      FROM Episode
       --       WHERE [Patient No] = @PatientComboId AND @IncludeOldProcs = 1 AND [Status] IS NOT NULL       AND SUBSTRING([Status], 8, 1) = 1 
       --UNION
       --       SELECT [Episode No], 9 AS ProcTypeNum, -1 as ColonType ,[Episode Date]      FROM Episode
       --       WHERE [Patient No] = @PatientComboId AND @IncludeOldProcs = 1 AND [Status] IS NOT NULL       AND SUBSTRING([Status], 9, 1) = 1 
       --UNION
       --       SELECT [Episode No], 10 AS ProcTypeNum   , -1 as ColonType    ,[Episode Date]      FROM Episode
       --       WHERE [Patient No] = @PatientComboId    AND @IncludeOldProcs = 1   AND [Status] IS NOT NULL      AND SUBSTRING([Status], 10, 1) = 1 
       --) AS eEpisode 
	
		SELECT * INTO #oldprocs FROM (
			SELECT [Episode No],   
				CASE WHEN CHARINDEX('1',[Status]) = 1
					THEN CASE WHEN SUBSTRING([Status], 6, 1) = 1 THEN 6 ELSE 1 END -- EUS-HPB (ProcType 7) has '1' in position 1 and 6, e.g: '1000010000'
					ELSE CHARINDEX('1',[Status]) 
				END ProcTypeNum, 
			-1 as ColonType ,[Episode Date], [Procedure time]
			FROM  Episode
			WHERE [Patient No] = @PatientComboId AND [Status] IS NOT NULL       
		) AS tempOldProc
			  
		UPDATE #oldprocs SET ColonType = 2 WHERE ProcTypeNum = '4'  -- PROCTOSCOPY, ProcTypeNum will set to 5 on the next query

		UPDATE #oldprocs SET ProcTypeNum = ProcTypeNum + 1 WHERE ProcTypeNum > 3   --Align with ERS Procedure types (FROM ERS_ProcedureTypes)

		--- SET Procedure type (ColonType) to 0 for Colonoscopy and 1 for Sigmoidscopy;   ProcTypeNum -> 3 for Col and 4 for Sig
		UPDATE o
		SET o.ColonType = c.[Procedure type] 
			--,o.ProcTypeNum = CASE WHEN c.[Procedure type] = 1 THEN 4 ELSE 3 END
		FROM #oldprocs o
		INNER JOIN [Colon Procedure] c ON o.[Episode No]=c.[Episode No] AND c.[Patient No] = @PatientComboId AND c.[Procedure type] <> 2
		WHERE ProcTypeNum = '3'  
		
		--Fill up the Procedure Type where it's blank
		IF EXISTS (SELECT 1 FROM #oldprocs WHERE ProcTypeNum = 0 OR ProcTypeNum = '')
		BEGIN
			DECLARE @episode_counter INT
			DECLARE cm CURSOR READ_ONLY FOR
			SELECT [Episode No] FROM #oldprocs WHERE ProcTypeNum = 0 OR ProcTypeNum = ''
			OPEN cm
			FETCH NEXT FROM cm INTO @episode_counter
			WHILE @@fetch_status = 0 
			BEGIN	
				IF EXISTS (SELECT 1 FROM [Upper GI Procedure] WHERE [Episode No] = @episode_counter)
					UPDATE #oldprocs SET ProcTypeNum = 1 WHERE [Episode No] = @episode_counter
				ELSE IF EXISTS (SELECT 1 FROM [ERCP Procedure] WHERE [Episode No] = @episode_counter)
					UPDATE #oldprocs SET ProcTypeNum = 2 WHERE [Episode No] = @episode_counter
				ELSE IF EXISTS (SELECT 1 FROM [Colon Procedure] WHERE [Episode No] = @episode_counter)
					UPDATE #oldprocs SET ProcTypeNum = 3 WHERE [Episode No] = @episode_counter
				FETCH NEXT FROM cm INTO @episode_counter
			END
			DEALLOCATE cm
		END 

		-- OLD System procedures
		INSERT INTO #procs
			SELECT 
				0 AS ProcedureId,
				a.[Episode No] AS EpisodeNo,
				ProcTypeNum AS ProcedureType,
				@PatientComboId AS PatientComboId,
				0 AS DiagramNumber,
				CONVERT(VARCHAR, [Episode date], 103) + 
				CASE ProcTypeNum
					WHEN 1 THEN ' - Upper GI' 
					WHEN 2 THEN ' - ERCP' 
					WHEN 3 THEN 
						CASE (ColonType) WHEN 0 THEN ' - Colonoscopy'
										WHEN 1 THEN ' - Sigmoidoscopy'
										ELSE ''
						END
					WHEN 5 THEN ' - Proctoscopy'      
					WHEN 6 THEN ' - EUS (OGD)' 
					WHEN 7 THEN ' - EUS (HPB)' 
					WHEN 8 THEN ' - Ent - Antegrade'
					WHEN 9 THEN ' - Ent - Retrograde'
					ELSE ''
				END    AS DisplayName,
				0 AS ERS,
				[Episode Date] AS CreatedOn, 
				[Procedure time] AS ModifiedOn,
				0 AS Locked, 0 AS LockedBy, NULL AS LockedOn,
				'' AS SurgicalSafetyCheckListCompleted,
						 0 AS isProcedureLocked, ColonType, -1 AS ProcedureCompleted
				, 0		AS DNA_Reason	--## New field... Shawkat Osman; 2017-07-10
				, ''	AS DNA_Reason_PP_Text	--## New field... Shawkat Osman; 2017-07-10
				,NULL AS BreathTest
				,CASE WHEN pho.[Photo No] IS NULL THEN 0 ELSE 1 END AS HasPhotos
			FROM #oldprocs a
			LEFT JOIN Photos pho ON a.[Episode No] = pho.[Episode No]

		DROP TABLE #oldprocs
	END

       ----To differentiate between Colonoscopy & Sigmoidoscopy (both '3' in Episode table) 
       ----FROM [colon procedure] table : When [Procedure type] is 0 then Colonoscopy     -    When [Procedure type] is 1 then Sigmoidoscopy
       --IF EXISTS (SELECT TOP 1 [Episode No] FROM #oldprocs WHERE ProcTypeNum = 3)
       --BEGIN
       --     UPDATE op
       --     SET op.ProcTypeNum = CASE WHEN cp.[Procedure type] = 1 THEN 4 ELSE 3 END
       --     FROM #oldprocs AS op
       --     INNER JOIN [colon procedure] AS cp
       --     ON op.[Episode No] = cp.[Episode No]
       --     AND [Patient No] = @PatientComboId
       --     WHERE op.ProcTypeNum = 3 ;
       --END 

	SELECT * FROM #procs ORDER BY CreatedOn DESC, ModifiedOn DESC

	DROP TABLE #procs
GO


--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Description:	A Common stored proc to list the Consultants- by Type- All, or either Endoscopist, List Consultant, Nurse or Traineee!!
-- =============================================
EXEC DropIfExist 'usp_rep_ConsultantSelectByType','S';
GO
CREATE PROCEDURE dbo.usp_rep_ConsultantSelectByType
(
	@ConsultantType AS VARCHAR(20) = 'all'
	, @HideInactiveConsultants AS BIT = 0	-- ## Initially Show all, unless reqested!
)
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @Consultant VARCHAR(20) = LOWER(@ConsultantType);
    WITH AllConsultants AS(	-- This CTE will make the primary list - with Operators Only- Consultants and Nurses! On the later SELECT atatement- you can do further filer on Consulant OR Nurse!
	select -- ERS Consultants!
		  U.UserId
		, LTRIM(Surname) + 
				CASE WHEN ISNULL(LTRIM(Forename),'') = '' THEN '' 
						ELSE ', ' + LTRIM(Forename)	
				END	AS Consultant	
		, U.JobTitleID					AS TitleId
		, IsNull(T.Description, '')		AS Consultant_Title
		, IsListConsultant
		, IsNull(IsEndoscopist1,0)	AS IsEndoscopist1
		, IsNUll(IsEndoscopist2,0)	AS IsEndoscopist2
		, IsAssistantOrTrainee
		, IsNull(IsNurse1,0)		AS IsNurse1
		, IsNull(IsNurse2,0)		AS IsNurse2
	FROM  dbo.ERS_Users AS U
		LEFT JOIN [dbo].[ERS_JobTitles] AS T ON	 U.JobTitleID = T.JobTitleID
		    WHERE ((@HideInactiveConsultants= 0 AND 1=1) /*OR (@HideInactiveConsultants=1 AND U.Active = 1)*/ )
			  AND ( ISNULL(U.IsListConsultant, 0)	= 1 OR
					ISNULL(U.IsEndoscopist1, 0)		= 1 OR
					ISNULL(U.IsEndoscopist2, 0)		= 1 OR
					ISNULL(U.IsAssistantOrTrainee, 0)=1 OR
					ISNULL(U.IsNurse1, 0)			= 1 OR
					ISNULL(U.IsNurse2, 0)			= 1 
					)
	)
	Select * 
	from AllConsultants AS Con
	Where 1=1
		AND 
			(
			(@Consultant='all'						AND (1=1)) 	-- Select All Endoscopist/Nurses
				OR
			((@Consultant LIKE '%list%')			AND ( Con.IsListConsultant = 1))
				OR 
			((@Consultant LIKE '%endoscopist1%')	AND ( Con.IsEndoscopist1 = 1))
				OR 
			((@Consultant LIKE '%endoscopist2%')	AND ( Con.IsEndoscopist2 = 1))
				OR
			((@Consultant LIKE '%assistant%')		AND ( Con.IsAssistantOrTrainee = 1))
				OR 
			((@Consultant LIKE '%nurse1%')			AND ( Con.IsNurse1 = 1))
				OR 			  
			((@Consultant LIKE '%nurse2')			AND ( Con.IsNurse2 = 1))			
			)
		AND (@HideInactiveConsultants=0 /*AND Con.IsActive = 1*/)
	ORDER BY Consultant
	END 
GO
--------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'procedure_default_qa_save','S';
GO
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-------------------------------------367 Create Triggers on ColonAbnoLesions.sql-------------------------------------
--------------------------------------------------------------------------------------------------------------------

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
				OR (Polypoidal=1 AND PolypoidalType=1)) THEN 'True' ELSE 'False' END)
	FROM INSERTED

	EXEC abnormalities_colon_lesions_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D12P3', @ColonicPolyp			-- 'ColonicPolyp'
	EXEC diagnoses_control_save @site_id, 'D4P3', @RectalPolyp				-- 'RectalPolyp'
	EXEC diagnoses_control_save @site_id, 'D69P3', @ColorectalCancer		-- 'Colorectal cancer'
	EXEC diagnoses_control_save @site_id, 'D6P3', @BenignTumour				-- 'Benign colonic tumour'
	EXEC diagnoses_control_save @site_id, 'D8P3', @ProbablyMalignantTumour	-- 'Malignant colonic tumour'
GO


--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------


SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC DropIfExist 'fnGetSiteTitle','F';
GO

CREATE FUNCTION [dbo].[fnGetSiteTitle] (@siteNo INT, @OperatingHospitalID TINYINT)
RETURNS
  VARCHAR(5)
AS
BEGIN
	DECLARE @site_no_ch VARCHAR(5)

	DECLARE @SiteIdentifier INT

	SELECT @SiteIdentifier = esc.SiteIdentification FROM dbo.ERS_SystemConfig esc WHERE OperatingHospitalID = @OperatingHospitalID

	IF @SiteIdentifier = 1
	BEGIN
		SET @site_no_ch = convert(varchar(5), @SiteNo)
	END
	ELSE
	BEGIN
		IF @siteNo <= 26
			SET @site_no_ch = CHAR(64+@siteNo)
		ELSE
		BEGIN
			DECLARE @div INT, @rem INT
			SET @div = @siteNo / 26
			SET @rem = @siteNo % 26
			IF @rem = 0 BEGIN SET @rem = 26 SET @div = @div - 1 END
			SET @site_no_ch = CHAR(64+@div) + CHAR(64+@rem)
		END
	END
	RETURN @site_no_ch
END

GO

--------------------------------------------------------------------------------------------------------------------


SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC DropIfExist 'printreport_specimens_select','S';
GO

CREATE PROCEDURE [dbo].[printreport_specimens_select]
(
	@ProcedureId INT
)
AS

SET NOCOUNT ON

DECLARE 
       @procType INT,
       @siteIdentification TINYINT,
       @siteId INT, 
       @siteNo INT,
       @siteTitle VARCHAR(3),
	   @OperatingHospitalID TINYINT
DECLARE 
       @SpecimensSummary TABLE (
              SiteId INT,
              LabRequestReportName VARCHAR(200),
              SpecimenKey VARCHAR(1000),
              Specimen VARCHAR(2000))

SELECT @procType = ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureId
SELECT @OperatingHospitalID = OperatingHospitalID FROM ERS_Procedures WHERE ProcedureId = @ProcedureId


       SELECT s.SiteNo, Case @procType WHEN 1 THEN ISNULL(m.Area,'') ELSE '' END AS RegionSection, sp.*
       INTO #specimens
       FROM ERS_UpperGISpecimens sp
       JOIN ERS_Sites s ON sp.SiteId = s.SiteId
       JOIN ERS_Regions r ON s.RegionId = r.RegionId
       LEFT JOIN ERS_AbnormalitiesMatrixUpperGI m ON r.Region = m.Region AND m.ProcedureType = @procType
       LEFT JOIN [ERS_AbnormalitiesMatrixERCP] n ON r.Region = n.Region AND n.ProcedureType = @procType
       LEFT JOIN [ERS_AbnormalitiesMatrixColon] o ON r.Region = o.Region AND o.ProcedureType = @procType
       WHERE s.ProcedureId = @ProcedureId 

UPDATE #specimens SET RegionSection = CASE RegionSection WHEN 'Oesophagus' THEN 'oesophageal' WHEN 'Stomach' THEN 'gastric' WHEN 'Duodenum' THEN 'duodenal' ELSE '' END


DECLARE Site_Cursor CURSOR FOR
SELECT SiteId, SiteNo FROM #specimens ORDER BY SiteNo
       
OPEN Site_Cursor
FETCH NEXT FROM Site_Cursor INTO @siteId , @siteNo

WHILE @@FETCH_STATUS = 0
BEGIN
       SET @siteTitle = dbo.fnGetSiteTitle(@siteNo, @OperatingHospitalID)

       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Cytology', 
              CONVERT(VARCHAR, @siteId) + 'Brush', 
              LOWER(RegionSection) + ' brushings for cytology from (' + LOWER(@siteTitle) + ')'
       FROM #specimens 
       WHERE SiteId = @siteId AND BrushCytology > 0
              
       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Histology', 
              CONVERT(VARCHAR, @siteId) + 'BiopsyHistology', 
              CONVERT(VARCHAR,BiopsyQtyHistology) + ' ' + LOWER(RegionSection) + CASE WHEN BiopsyQtyHistology > 1 THEN ' biopsies' ELSE ' biopsy' END + ' for histology from (' + LOWER(@siteTitle) + ')'
       FROM #specimens 
       WHERE SiteId = @siteId AND BiopsyQtyHistology > 0

       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Microbiology', 
              CONVERT(VARCHAR, @siteId) + 'BiopsyMicrobiology', 
              CONVERT(VARCHAR,BiopsyQtyMicrobiology) + ' ' + LOWER(RegionSection) + CASE WHEN BiopsyQtyMicrobiology > 1 THEN ' biopsies' ELSE ' biopsy' END + ' for microbiology from (' + LOWER(@siteTitle) + ')'
       FROM #specimens 
       WHERE SiteId = @siteId AND Biopsy = 1 AND BiopsyQtyMicrobiology > 0
              
       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Virology', 
              CONVERT(VARCHAR, @siteId) + 'BiopsyVirology', 
              CONVERT(VARCHAR,BiopsyQtyVirology) + ' ' + LOWER(RegionSection) + CASE WHEN BiopsyQtyVirology > 1 THEN ' biopsies' ELSE ' biopsy' END + ' for virology from (' + LOWER(@siteTitle) + ')'
       FROM #specimens 
       WHERE SiteId = @siteId AND Biopsy = 1 AND BiopsyQtyVirology > 0
       
       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Histology', 
              CONVERT(VARCHAR, @siteId) + 'Polypectomy', 
              CONVERT(VARCHAR,PolypectomyQty) + ' ' + LOWER(RegionSection) + CASE WHEN PolypectomyQty > 1 THEN ' polyps' ELSE ' polyp' END + ' for histology from (' + LOWER(@siteTitle) + ')'
       FROM #specimens 
       WHERE SiteId = @siteId AND Polypectomy = 1 AND PolypectomyQty > 0

       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Histology', 
              CONVERT(VARCHAR, @siteId) + 'HotBiopsy', 
              LOWER(RegionSection) + ' hot biopsy for histology from (' + LOWER(@siteTitle) + ')' + CASE WHEN HotBiopsyDistance > 0 THEN ' at ' + CONVERT(VARCHAR, HotBiopsyDistance) + 'cm' ELSE '' END
       FROM #specimens 
       WHERE SiteId = @siteId AND HotBiopsy = 1
       
       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Histology', 
              CONVERT(VARCHAR, @siteId) + 'NeedleAspirateHistology', 
              LOWER(RegionSection) + ' needle aspirate for histology from (' + LOWER(@siteTitle) + ')'
       FROM #specimens 
       WHERE SiteId = @siteId AND NeedleAspirate = 1 AND NeedleAspirateHistology = 1

       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Histology', 
              CONVERT(VARCHAR, @siteId) + 'NeedleAspirateMicrobiology', 
              LOWER(RegionSection) + ' needle aspirate for microbiology from (' + LOWER(@siteTitle) + ')'
       FROM #specimens 
       WHERE SiteId = @siteId AND NeedleAspirate = 1 AND NeedleAspirateMicrobiology = 1

       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Histology', 
              CONVERT(VARCHAR, @siteId) + 'NeedleAspirateVirology', 
              LOWER(RegionSection) + ' needle aspirate for virology from (' + LOWER(@siteTitle) + ')'
       FROM #specimens 
       WHERE SiteId = @siteId AND NeedleAspirate = 1 AND NeedleAspirateVirology = 1

       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Microbiology', 
              CONVERT(VARCHAR, @siteId) + 'GastricWashing', 
              'gastric washing for microbiology from (' + LOWER(@siteTitle) + ')'
       FROM #specimens 
       WHERE SiteId = @siteId AND GastricWashing = 1

       FETCH NEXT FROM Site_Cursor INTO @siteId, @siteNo
END
CLOSE Site_Cursor;
DEALLOCATE Site_Cursor;

IF OBJECT_ID('tempdb..#specimens') IS NOT NULL DROP TABLE #specimens 
SELECT * FROM @SpecimensSummary 


GO


--------------------------------------------------------------------------------------------------------------------


SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC DropIfExist 'sites_insert','S';
GO

CREATE PROCEDURE [dbo].[sites_insert]
(
	@ProcedureId INT, 
	@RegionId INT,
	@XCoordinate INT, 
	@YCoordinate INT, 
	@AntPos TINYINT,
	@PositionSpecified BIT,
	@AreaNo INT,
	@DiagramHeight INT,
	@DiagramWidth INT,
	@LoggedInUserId INT
)
AS

SET NOCOUNT ON

DECLARE @latest_site_no INT
DECLARE @site_no INT
DECLARE @newSiteId INT
DECLARE @newSiteInfo VARCHAR(20)
DECLARE @OperatingHospitalID TINYINT

BEGIN TRANSACTION

BEGIN TRY
	--SiteNo is set to -77 for sites By Distance (Col & Sig only)
	IF @RegionId = -77
	BEGIN
		SET @site_no = -77
	END
	ELSE
	BEGIN
		SET @latest_site_no = ISNULL((SELECT TOP 1 SiteNo FROM ERS_Sites WHERE ProcedureId = @ProcedureId ORDER BY SiteNo DESC), 0)
		SET @site_no = @latest_site_no + 1
	END

	SELECT @OperatingHospitalID = OperatingHospitalID FROM ERS_Procedures WHERE ProcedureId = @ProcedureId

	INSERT INTO ERS_Sites (
		ProcedureId,
		SiteNo,
		AreaNo,
		RegionId, 
		XCoordinate, 
		YCoordinate, 
		AntPos,
		PositionSpecified,
		DiagramHeight,
		DiagramWidth,
		WhoCreatedId,
		WhenCreated) 
	VALUES (
		@ProcedureId,
		@site_no,
		@AreaNo,
		CASE WHEN @RegionId = -77 THEN 0 ELSE @RegionId END, 
		@XCoordinate, 
		@YCoordinate, 
		@AntPos,
		@PositionSpecified,
		@DiagramHeight,
		@DiagramWidth,
		@LoggedInUserId,
		GETDATE())
	
	SET @newSiteId = SCOPE_IDENTITY()

	IF @RegionId = -77
	BEGIN
		--EXEC procedure_summary_update @ProcedureId
		SELECT CAST(@newSiteId AS VARCHAR(5))
	END
	ELSE
	BEGIN
		EXEC sites_reorder @ProcedureId
		--EXEC procedure_summary_update @ProcedureId

		SELECT @site_no = SiteNo FROM ERS_Sites WHERE SiteId = @newSiteId

		SELECT CAST(@newSiteId AS VARCHAR(5)) +  ';' + dbo.fnGetSiteTitle(@site_no, @OperatingHospitalID)
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


--------------------------------------------------------------------------------------------------------------------


SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC DropIfExist 'sites_select','S';
GO

CREATE PROCEDURE [dbo].[sites_select]
(
	@ProcedureId INT,
	@Height INT,
	@Width INT,
	@isERS BIT,
	@OperatingHospitalID SMALLINT,
	@ProcedureType TINYINT,
    @EpisodeNo INT,
    @ColonType INT
)
AS
	SET NOCOUNT ON

--Dependency : printreport_photos_select
	
	DECLARE @SiteId INT, @SiteNo INT, @AreaNo INT, @YCoordinate INT, @Cnt TINYINT, @SiteTitle VARCHAR(3), @SiteIdentification TINYINT

	SELECT @SiteIdentification = ISNULL(SiteIdentification,0) FROM ERS_SystemConfig WHERE OperatingHospitalID = @OperatingHospitalID
	

	IF (@isERS = 1)  -- Check if procedure is from new software
	BEGIN
		SELECT 
			SiteId,
			SiteNo,
			dbo.fnGetSiteTitle(SiteNo, @OperatingHospitalID) AS SiteTitle,
			AreaNo,
			r.RegionId,
			r.Region, 
			convert(decimal(5,2), (XCoordinate * (convert(decimal(5,2),@Width)/DiagramWidth))) AS XCoordinate,
			convert(decimal(5,2), (YCoordinate * (convert(decimal(5,2),@Height)/DiagramHeight))) AS YCoordinate,
			CASE AntPos WHEN 1 THEN 'Anterior' WHEN 2 THEN 'Posterior' WHEN 3 THEN 'BothOrEither' END AS AntPos,
			PositionSpecified, 
			r.is3D AS In3DRegion
		FROM
			ERS_Sites s
			JOIN ERS_Procedures p ON s.ProcedureId = p.ProcedureId
			JOIN ERS_Regions r ON s.RegionId = r.RegionId
		WHERE
			s.ProcedureId = @ProcedureId
		ORDER BY 
			AreaNo, 
			SiteNo DESC
	END
	
	ELSE
	BEGIN
		DECLARE @AreaNumber TINYINT, @IsArea SMALLINT, @AreaStart SMALLINT, @AreaEnd INT, @OrderBy INT, 
				@SQL NVARCHAR(MAX), @XCoor VARCHAR(10), @YCoor VARCHAR(10), @tableName VARCHAR(300), @fldSiteNo VARCHAR(50);
	

		CREATE TABLE #temp1(SiteId INT,SiteNo INT, SiteTitle VARCHAR(3), AreaNo TINYINT, Region VARCHAR(3), 
							XCoordinate INT, YCoordinate INT, ProcedureId INT, OrderBy INT,
							IsArea SMALLINT, AreaStart SMALLINT, AreaEnd SMALLINT, AntPos VARCHAR(100))
	
		IF @ProcedureType IN (1, 6) --OGD, EUS(OGD)
		BEGIN 
			SET @tableName = ' CASE AntPost WHEN 1 THEN ''Anterior'' WHEN 2 THEN ''Posterior'' WHEN 3 THEN ''BothOrEither'' END AS AntPos FROM [Upper GI Sites] '
                     SET @XCoor =  '2.033';     SET @YCoor = '1.7235'
		END
		ELSE IF @ProcedureType IN (2, 7) --ERCP, EUS (HPB)
		BEGIN 
			SET @tableName = ' CASE AntPost WHEN 1 THEN ''Anterior'' WHEN 2 THEN ''Posterior'' WHEN 3 THEN ''BothOrEither'' END AS AntPos FROM [ERCP Sites] '
                     SET @XCoor =  '1.95';      SET @YCoor = '2.43'
		END
		ELSE IF @ProcedureType IN (3, 4, 5, 9, 12) --Colonoscopy, Sigmoidscopy, Proctoscopy, Ent - Retrograde, Thoracoscopy
		BEGIN 
			SET @tableName = ' Region AS AntPos FROM [Colon Sites] '
			SET @XCoor =  '1.93'; SET @YCoor = '2.01'
		END
		ELSE
		BEGIN
			SET @tableName = ' CASE AntPost WHEN 1 THEN ''Anterior'' WHEN 2 THEN ''Posterior'' WHEN 3 THEN ''BothOrEither'' END AS AntPos FROM [Upper GI Sites] '
                     SET @XCoor =  '2.033';     SET @YCoor = '1.7235'
		END

		IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'Sorted Site No' AND Object_ID = Object_ID(N'Photos'))
			SET @fldSiteNo = ' ISNULL([Sorted Site No],[Site No]) '
		ELSE
			SET @fldSiteNo = '[Site No]'


              SET @SQL = N'SELECT ' + @fldSiteNo + ' AS SiteId, ' + @fldSiteNo + ' AS SiteNo,       SPACE(3) AS SiteTitle,     0 AS AreaNo,  '''' AS Region, 
				convert(decimal(9,2), ([Left] * ' + @XCoor + ')) AS XCoordinate,
				convert(decimal(9,2), ([Top] * ' + @YCoor + ')) AS YCoordinate,
				[Episode No] AS ProcedureId, ' + @fldSiteNo + ' * 100 AS OrderBy,
				Continuous AS IsArea, [Continuous Start] AS AreaStart, ISNULL([Continuous close],0) AS AreaEnd, '
                           + @tableName + ' WHERE [Episode No] = ' + CONVERT(VARCHAR,@EpisodeNo)  
              IF @ColonType >= 0  SET @SQL = @SQL + ' AND [Procedure Type] = '+ CONVERT(VARCHAR,@ColonType)
              SET @SQL = @SQL + ' ORDER BY 1 ' --+ @fldSiteNo
		INSERT INTO #temp1 EXECUTE (@SQL)
			
		DECLARE Site_Cursor CURSOR FOR
							
		--Get the sites and the first record of an area (start by [Continuous Start] = -1)
		SELECT SiteId, IsArea, AreaStart, AreaEnd, OrderBy
		FROM #temp1 
		ORDER BY orderBy
		OPEN Site_Cursor;
		FETCH NEXT FROM Site_Cursor INTO @SiteId, @IsArea, @AreaStart, @AreaEnd, @OrderBy;

		SET @Cnt = 1;
		SET @AreaNumber = 0;

		--loop to assign title and area no. of sites 
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @SiteTitle = dbo.fnGetSiteTitle(@Cnt, @OperatingHospitalID) 

				IF (@IsArea = 0 AND @AreaStart = 0) -- Site without area
				BEGIN 
					UPDATE #temp1 SET SiteTitle = @SiteTitle, AreaNo = 0 WHERE SiteId = @SiteId
					SET @Cnt = @Cnt + 1
				END
				ELSE IF (@IsArea = 0 AND @AreaStart = 0) OR (@IsArea = -1 AND @AreaStart = -1)  -- Starting site record for area
				BEGIN 
					SET @AreaNumber = @AreaNumber + 1
					UPDATE #temp1 SET SiteTitle = @SiteTitle, AreaNo = @AreaNumber WHERE SiteId = @SiteId
					SET @Cnt = @Cnt + 1
				END
				ELSE IF (@IsArea = -1 AND @AreaStart = 0) -- Coordinates of the area
				BEGIN
					UPDATE #temp1 SET SiteTitle = '', AreaNo = @AreaNumber WHERE SiteId = @SiteId
					IF (@IsArea = -1 AND @AreaEnd = -1) -- Last coordinate to close area
					BEGIN
                                         INSERT INTO #temp1 (SiteId, SiteNo,      SiteTitle,       AreaNo,       Region, XCoordinate, YCoordinate, AntPos, ProcedureId, orderBy, IsArea, AreaStart, AreaEnd)
                                         SELECT TOP 1 SiteId, SiteNo, '',  AreaNo,       Region, XCoordinate, YCoordinate, AntPos, ProcedureId, @OrderBy + 50 , 0, 0, 0
						FROM #temp1 WHERE SiteId < @SiteId AND AreaStart = -1 ORDER BY SiteId DESC
					END
				END
			FETCH NEXT FROM Site_Cursor INTO @SiteId, @IsArea, @AreaStart, @AreaEnd, @OrderBy;
		END;
		CLOSE Site_Cursor;
		DEALLOCATE Site_Cursor;

		DELETE  #temp1  WHERE AntPos = ''

		SELECT * FROM #temp1 ORDER BY orderBy 

		DROP TABLE #temp1

	END

GO




--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

UPDATE ERS_MenuMap SET ParentID = (SELECT MapId FROM ERS_MenuMap WHERE NodeName = 'Admin Utilities') WHERE NodeName = 'Rooms'


IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'RoomId' AND Object_ID = Object_ID(N'ERS_ImagePort'))
	ALTER TABLE ERS_ImagePort ADD RoomId INT NULL 
GO

IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ERSAudit' AND TABLE_NAME = 'ERS_ImagePort_Audit'))
	IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'RoomId' AND Object_ID = Object_ID(N'ERSAudit.ERS_ImagePort_Audit'))
		ALTER TABLE ERSAudit.ERS_ImagePort_Audit ADD RoomId INT NULL 
GO

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------