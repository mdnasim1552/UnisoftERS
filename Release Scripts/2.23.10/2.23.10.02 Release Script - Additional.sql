

ALTER PROCEDURE [dbo].[abnormalities_common_lesions_summary_update]
(
	@SiteId INT
)
AS
SET NOCOUNT ON
	
DECLARE 
	@summary VARCHAR (8000),
	@tempsummary VARCHAR (1000),
	@None BIT,
	@Polyp BIT,

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
	@SubmucosalTypeId TINYINT,
	@Focal BIT,
	@FocalQuantity INT,
	@FocalLargest INT,
	@FocalProbably BIT,
	@FocalTypeId TINYINT,
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
	@FundicGlandPolyp BIT,
	@FundicGlandPolypQuantity INT,
	@FundicGlandPolypLargest Numeric(18,2),
	@PreviousESDScar BIT

SET @summary = ''
SET @tempsummary = ''

SELECT 
	@None=[None],
	@Polyp = Polyp,
	@Submucosal = Submucosal,
	@SubmucosalTypeId = SubmucosalTumourTypeId,
	@SubmucosalLargest = SubmucosalLargest,
	@SubmucosalProbably = SubmucosalProbably,
	@SubmucosalQuantity = SubmucosalQuantity,
	@Focal = Focal,
	@FocalTypeId = FocalTumourTypeId,
	@FocalLargest = FocalLargest,
	@FocalProbably = FocalProbably,
	@FocalQuantity = FocalQuantity,
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
	@TattooedQty = TattooedQuantity,
	@FundicGlandPolyp = FundicGlandPolyp,
	@FundicGlandPolypQuantity = FundicGlandPolypQuantity,
	@FundicGlandPolypLargest = FundicGlandPolypLargest,
	@PreviousESDScar = PreviousESDScar
FROM
	ERS_CommonAbnoLesions
WHERE
	SiteId = @SiteId

SET @Summary = ''

IF NOT EXISTS (SELECT 1 FROM ERS_CommonAbnoLesions WHERE SiteId = @SiteId) return

IF @None = 1 SET @summary = 'No lesions'

ELSE
BEGIN
	--saves calling the table multiple times :)
	DECLARE @TumourTypes TABLE (TypeId int, [Description] varchar(100))
	INSERT INTO @TumourTypes
	SELECT UniqueId, [Description] 
	FROM ERS_TumourTypes 
	WHERE Suppressed = 0
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
		BEGIN
			IF @summary <> '' SET @summary = @summary + '##'

			SET @summary = @summary + 'pneumatosis coli '
		END
	END	
	
	------------------------------------------------------------------------------------------
	-------	SUBMUCOSAL LESION -------
	------------------------------------------------------------------------------------------
	IF @Submucosal > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		IF @SubmucosalQuantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @SubmucosalQuantity) + ' '
		ELSE SET @summary = @summary + 'A '
		
		IF @SubmucosalProbably = 1 SET @summary = @summary + 'probably '

		SELECT @summary = @summary + LOWER([Description]) + ' ' FROM @TumourTypes WHERE TypeId = @SubmucosalTypeId

		IF @SubmucosalQuantity > 1 SET @summary = @summary + 'submucosal lesions ' ELSE SET @summary = @summary + 'submucosal lesion ' 

		IF (@SubmucosalQuantity > 0 AND @SubmucosalLargest > 0) 
		BEGIN
			IF @SubmucosalQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @SubmucosalLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @SubmucosalLargest) + 'mm) '
		END
	END

	------------------------------------------------------------------------------------------
	-------	FOCAL LESIONS -------
	------------------------------------------------------------------------------------------
	IF @Focal > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		IF @FocalQuantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @FocalQuantity) + ' '
		ELSE SET @summary = @summary + 'A '
		
		IF @FocalProbably = 1 SET @summary = @summary + 'probably '

		SELECT @summary = @summary + LOWER([Description]) + ' ' FROM @TumourTypes WHERE TypeId = @FocalTypeId

		IF @FocalQuantity > 1 SET @summary = @summary + 'focal lesions ' ELSE SET @summary = @summary + 'submucosal lesion ' 

		IF (@FocalQuantity > 0 AND @FocalLargest > 0) 
		BEGIN
			IF @FocalQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @FocalLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @FocalLargest) + 'mm) '
		END
	END

	-------------------------------------------------------------------------------------------
	-------	Fundic Gland Polyp -------
	------------------------------------------------------------------------------------------
	IF @FundicGlandPolyp > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		IF @FundicGlandPolypQuantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @FundicGlandPolypQuantity) + ' '
		ELSE SET @summary = @summary + 'A '
		
		IF @FundicGlandPolypQuantity > 1 SET @summary = @summary + 'Fundic Gland Polyp tumours found ' ELSE SET @summary = @summary + 'Fundic Gland Polyp tumour found ' 

		IF (@FundicGlandPolypQuantity > 0 AND @FundicGlandPolypLargest > 0) 
		BEGIN
			IF @FundicGlandPolypQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @FundicGlandPolypLargest) + ' mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @FundicGlandPolypLargest) + ' mm) '
		END
	END
	
	------------------------------------------------------------------------------------------
	-------	Previous ESD Scar -------
	------------------------------------------------------------------------------------------
	IF @PreviousESDScar > 0
	BEGIN
		BEGIN
			IF @summary <> '' SET @summary = @summary + '##'

			SET @summary = @summary + 'previous ESD scar '
		END
	END	

	------------------------------------------------------------------------------------------
	-------	POLYPS	-------
	------------------------------------------------------------------------------------------
	IF @Polyp = 1
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM dbo.ERS_CommonAbnoPolypDetails WHERE SiteId = @SiteId)
		BEGIN
			SET @summary = @summary + '<br />' + dbo.common_polpydetails_summary(@SiteId, NULL)
		END
	END


	------------------------------------------------------------------------------------------
	-------	POLYPS TATTOO ----------
	------------------------------------------------------------------------------------------
	/*IF @Tattooed > 0 
	BEGIN
		DECLARE @TattooTypeText varchar(50)

		SELECT @TattooType = MarkingType, @TattooedQty = MarkedQuantity FROM dbo.ERS_UpperGITherapeutics WHERE SiteId = @SiteID AND Marking = 1
		
		IF @summary <> '' SET @summary = @summary + '## <br />'

		SET @summary = @summary + ' Tattooed, '
		
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
	*/
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
UPDATE ERS_CommonAbnoLesions
SET Summary = @summary 
WHERE SiteId = @SiteId


EXEC sites_summary_update @SiteId
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Steve 04-MAR-2024
-- TFS#	
-- Description of change
-- Change to NED sender SP to only get Active procedures
-- Moved createdon column to end of selection as application needs OperatingHospital in 2nd column
------------------------------------------------------------------------------------------------------------------------
GO

ALTER PROCEDURE [dbo].[usp_NEDI2_Get_Unsent_Procedures]
AS
BEGIN
	select 
		prc.ProcedureId, 
		prc.operatingHospitalId, 
		ISNULL((SELECT TOP 1 ISNULL(ServiceId,'') FROM dbo.ERS_NedI2FilesLog enil WHERE enil.ProcedureID = prc.ProcedureId AND [Status] = 5),'') AS ServiceId, 
		createdon
	From dbo.ERS_Procedures prc 
		INNER JOIN ERS_ProcedureTypes pt ON pt.ProcedureTypeId = prc.ProcedureType, ERS_SystemConfig cnfg 
	where (ProcedureCompleted = 1 
			and IsActive = 1 
			and cnfg.NEDEnabled = 1 
			and prc.operatingHospitalId = cnfg.operatingHospitalId 
			AND pt.NedExportRequired = 1 
			AND ISNULL(prc.NEDExported,0) = 0) 
		and CreatedOn >= (select min(InstallDate) from DBVersion where VersionNum like '2%')
END
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------

GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Steve	On 20 Feb 2024
-- TFS#	No TFS - Fit Value Issue when creating report raised Post release of 2.23.10.02 by Practice Plus
-- Description of change
-- Fortmat FitValue for HTML for the report.
------------------------------------------------------------------------------------------------------------------------
GO

EXEC dbo.DropIfExist @ObjectName = 'procedure_fit_save',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[procedure_fit_save]
(
	@FITValue VARCHAR(50),
	@FITNotKnownId INT,
	@ProcedureId INT,
	@LoggedInUserId INT,
	@Selected BIT	
)
AS
BEGIN

	DECLARE @ReportSummaryText VARCHAR(MAX)

	IF @Selected = 1
	BEGIN
	    IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureFitValue WHERE ProcedureId = @ProcedureId)
		BEGIN
			INSERT INTO ERS_ProcedureFitValue (FITValue, FITNotKnownId, ProcedureId, WhoCreatedId, WhenCreated)
			VALUES (@FITValue, NULLIF(@FITNotKnownId,0), @ProcedureId, @LoggedInUserId, GETDATE())
		END
		ELSE
		BEGIN
			UPDATE ERS_ProcedureFitValue	    
			SET FITValue = @FITValue,
				FITNotKnownId = NULLIF(@FITNotKnownId,0),
				WhoUpdatedId = @LoggedInUserId,
				WhenUpdated = GETDATE()
			WHERE ProcedureId = @ProcedureId
		END	

		EXEC dbo.UI_update_procedure_summary @ProcedureId = @ProcedureId,  -- int
		                                     @Section = 'FIT results',     -- varchar(200)
		                                     @Summary = 'FIT Result:',     -- varchar(max)
		                                     @ResultId = 1,     -- int
		                                     @EndoscopistId = NULL -- int
		
		SET @ReportSummaryText = 'FIT value ' + CASE WHEN @FITValue = '' THEN 'unknown because ' + (SELECT Description FROM ERS_FITNotKnownReasons WHERE UniqueId = @FITNotKnownId) + '.' ELSE (SELECT @FITValue for XML PATH ('')) END	
		
	END
	ELSE
	BEGIN	
		DELETE FROM ERS_ProcedureFitValue WHERE ProcedureId = @ProcedureId

				EXEC dbo.UI_update_procedure_summary @ProcedureId = @ProcedureId,  -- int
		                                     @Section = 'FIT results',     -- varchar(200)
		                                     @Summary = 'FIT Result:',     -- varchar(max)
		                                     @ResultId = 0,     -- int
		                                     @EndoscopistId = NULL -- int
		SET @ReportSummaryText = NULL
	END

	IF EXISTS (SELECT 1 FROM dbo.ERS_ProceduresReporting WHERE ProcedureId = @ProcedureId)
	BEGIN
		UPDATE dbo.ERS_ProceduresReporting SET PP_FITResult = @ReportSummaryText WHERE ProcedureID = @ProcedureId
	END

	
END
GO
------------------------------------------------------------------------------------------------------------------------
-- END TFS#	No TFS - Fit Value Issue when creating report raised Post release of 2.23.10.02 by Practice Plus
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Changes for NED Sender
------------------------------------------------------------------------------------------------------------------------
GO


/****** Object:  StoredProcedure [dbo].[usp_NED_Generate_Report]    Script Date: 05/03/2024 14:14:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_NED_Generate_Report]
(
		@ProcedureId AS INT
)
AS
BEGIN
	SET NOCOUNT ON;

/*
	<xs:schema xmlns="https://www.jets.nhs.uk/schema/hospital.sendbatchmessage-version2.xsd" 
	xmlns:mstns="https://www.jets.nhs.uk/schema/hospital.sendbatchmessage-version2.xsd" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	targetNamespace="https://www.jets.nhs.uk/schema/hospital.sendbatchmessage-version2.xsd" 
	elementFormDefault="qualified" id="SendBatchMessageFile">		

*/
Declare @site AS VARCHAR(50);
DECLARE 
		@description	AS VARCHAR(1000),
		@uniqueid		AS VARCHAR(15),
		@previousLocalProcedureId AS VARCHAR(15),
		@PatientId		AS INT,
		@sessionType	AS VARCHAR(50),
		@operatingHospitalId AS INT,
		@ProcedureTypeId AS INT,
		@ExportFolderPath AS VARCHAR(100);	--## XML Export Folder path.. Set by Admin in the [ERS_SystemConfig] Table

DECLARE @returnXML XML;

	Set @description = 'NED List';
	SELECT @operatingHospitalId = OperatingHospitalId FROM ERS_Procedures WHERE ProcedureId = @ProcedureId;
	SELECT @site = [NED_HospitalSiteCode], @ExportFolderPath=[NED_ExportPath] FROM [dbo].[ERS_SystemConfig] WHERE OperatingHospitalId = @operatingHospitalId;

	SELECT @ProcedureTypeId = ProcedureType,
		   @uniqueid = RIGHT(('00000' + CAST(@ProcedureId AS VARCHAR(6))),6) --## Procedure Id
							+ RIGHT(('0' + CAST(ProcedureType AS VARCHAR(2))),2)  --## Procedure Type; ie: OGD=1/ERCP=2/COLON=3/FLEXI=13
								+ (CASE ProcedureType	WHEN  1 THEN 'o' 
														WHEN  2 THEN 'e'
														WHEN  4 THEN 's' 
														WHEN  3 THEN 'c'
														WHEN  6 THEN 'u'
														WHEN  7 THEN 'u'
														WHEN  8 THEN 'n'
														WHEN  9 THEN 't'
									END)	--## Procedure Letter
		 , @sessionType=Case ListType	When 1 Then 'Service List' 
										When 2 Then 'Adhoc Training List' 
											   Else 'Dedicated Training List' End 
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
	, REPLACE(convert(varchar, p.CreatedOn, 106), ' ', '/')	AS '@date'	--### '10 Oct 2020' ==> '10/Oct/2020'
	, P.ProcedureTime AS '@time'
	, @sessionType										AS '@type'	-- SessionTypeEnum
	, @site												AS '@site'	--## Hospital Code

	/*	##### Procedure info	*/
	, (
	Select 
		  @uniqueid										AS '@localProcedureId'
		, @previousLocalProcedureId						AS '@previousLocalProcedureId'
		, (CASE P.ProcedureType WHEN 1 THEN 'OGD' 
								WHEN 2 THEN 'ERCP' 
								WHEN 3 THEN 'COLON' 
								WHEN 4 THEN 'FLEXI' 
								WHEN 6 THEN 'EUS' 
								WHEN 7 THEN 'EUS' 
								WHEN 8 THEN 'ENT' 
								WHEN 9 THEN 'ENT' 
		   END) AS '@procedureName'
		, Dis.NEDTerm AS '@procedureDiscomfort'	
		, PPDD.NEDTerm AS '@postProcedureDiscomfort' -- **************************** TO DO *********************************
		, dbo.fnNED_ProcedureExtent(@ProcedureId, 0) AS '@extent'	--## OverAll Extent info - EE/ER- whoever has gone Furthest distance!!
		, (CASE WHEN Drug.entonox IS NULL THEN 'No' ELSE 'Yes' END) AS '@entonox'
		, CASE WHEN ISNULL((Select DrugNo from ERS_UpperGIPremedication where ProcedureId = @ProcedureID and DrugNo = -2), 0) = -2 THEN 'Yes' ELSE 'No' END AS '@generalAnaes'
		, convert(varchar, P.StartDateTime, 126) AS '@procedureStartTime'
		, convert(varchar, P.EndDateTime, 126) AS '@procedureEndTime'
		, Ins.NEDTerm AS '@insufflation' 
		, PS.NEDTerm AS '@providerSector'
		, RT.NEDTerm AS '@referrer'
		, CASE WHEN isnull(P.ReferrerTypeOther, '') = '' THEN NULL ELSE P.ReferrerTypeOther END AS '@referrerOther' -- ***************** Only if referrer is 'Other' *******************************
		, PO.NEDTerm AS '@providerOrganisation' 
		, CASE WHEN isnull(P.ProviderOther, '') = '' THEN NULL ELSE P.ProviderOther END AS '@providerOrganisationOther' -- **************** Only if providerOrganisation is 'Other' *************************
		, CASE WHEN P.ChecklistComplete = 0 THEN 'No' ELSE 'Yes' END AS '@checklist' 
		, CASE WHEN PatStat.ListItemText = 'Day patient' THEN 'Inpatient' ELSE PatStat.ListItemText END AS '@admissionType'
		, Urgency.Description AS '@urgencyType' 
		, Ext.NEDTerm AS '@plannedExtent'
		, ISNULL(AIS.NEDTerm, 'None')  AS '@artificialintelligence'
		, CASE WHEN AIS.NEDTerm = 'Other' THEN PAIS.AISoftwareOther ELSE NULL END AS '@artificialintelligenceOther' -- **************** Only if artificialintelligence is 'Other' *************************
		, CASE WHEN PAIS.AISoftwareName IS NULL OR AIS.NEDTerm = 'None' THEN NULL ELSE PAIS.AISoftwareName END AS '@nameOfAISoftware' -- **************** Only if artificialintelligence is NOT 'None' *************************
		, CASE WHEN CHARINDEX('.00',P.Points,0) > 0 THEN convert(varchar(10), convert(int, P.Points)) ELSE convert(varchar(10), P.Points) END AS '@procedurePoints'


		/*	##### Patient Info	*/		
		, (CASE Pat.Gender WHEN 'Not Known' THEN 'Other' WHEN 'Not Specif' THEN 'Other' ELSE Pat.Gender END)		AS 'patient/@gender'
		, (0+ FORMAT(getdate(),'yyyyMMdd') - FORMAT(Pat.DateOfBirth,'yyyyMMdd') ) /10000 AS 'patient/@age'


		/*	##### Drugs	*/
		, CASE WHEN CHARINDEX('.00',IsNull(Drug.pethidine,0),0) > 0 THEN convert(varchar(10), convert(int,IsNull(Drug.pethidine,0))) ELSE CONVERT(varchar(10),IsNull(Drug.pethidine,0)) END	As 'drugs/@pethidine'	--## Required
		, CASE WHEN CHARINDEX('.00',IsNull(Drug.midazolam,0),0) > 0 THEN convert(varchar(10), convert(int,IsNull(Drug.midazolam,0))) ELSE CONVERT(varchar(10),IsNull(Drug.midazolam,0)) END	As 'drugs/@midazolam'	--## Required
		, CASE WHEN CHARINDEX('.00',IsNull(Drug.fentanyl,0),0) > 0 THEN convert(varchar(10), convert(int,IsNull(Drug.fentanyl,0))) ELSE CONVERT(varchar(10),IsNull(Drug.fentanyl,0))	END As 'drugs/@fentanyl'	--## Required
		, CASE WHEN CHARINDEX('.00',IsNull(Drug.buscopan,0),0) > 0 THEN convert(varchar(10), convert(int,IsNull(Drug.buscopan,0))) ELSE CONVERT(varchar(10),IsNull(Drug.buscopan,0))	END As 'drugs/@buscopan'	--## Required
		, CASE WHEN CHARINDEX('.00',IsNull(Drug.remimazolam,0),0) > 0 THEN convert(varchar(10), convert(int,IsNull(Drug.remimazolam,0))) ELSE CONVERT(varchar(10),IsNull(Drug.remimazolam,0))	END As 'drugs/@remimazolam'	--## Required
		, CASE WHEN IsNull(Drug.propofol, 0) = 0 THEN 'No' ELSE	'Yes' END			As 'drugs/@propofol'	--## YesNo
		, ISNULL(Drug.noDrugsAdministered, 'Yes')	As 'drugs/@noDrugsAdministered'


		/*	##### Staff.Members: 1 Procedure to MANY staff.. So - need a SQL Subquery- to return a RecordSet		*/
		,(
			SELECT 
			  Staff.professionalBodyCode AS '@professionalBodyCode'
			, Staff.EndoscopistRole		AS '@endoscopistRole'
			, Staff.ProcedureRole		AS '@procedureRole'	-- ProcedureRoleTypeEnum
			, Staff.Extent				AS '@extent'
			, CASE Staff.[jManoeuvre] WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE NULL END 	AS '@jManoeuvre'	-- Opt -- Mandatory for OGD, Colon and Flexi procedures (Rectal retroversion)
			/*	##### Therapeutic = Sesion->Procedure-> Staff.members-> Staff-> Therapeutic; 1 [Staff] to Many [Therapeutic sessions]	*/
			, (
				Select * from (select 
					   T.NedName	AS '@type'	-- M	--## The type of therapeutic procedure.
					 , CASE WHEN rc.RegionId IS NULL THEN T.[Site] ELSE 'Ileo-colon anastomosis' END		AS '@site'	-- O -- BiopsyEnum  --## The location where the therapeutic procedure was performed.
					 , ISNULL(T.EndoRole, Staff.ProcedureRole) AS '@role' -- O	-- ProcedureRoleTypeEnum
					 , T.polypSize	AS '@polypSize' -- O	-- PolypSizeEnum --## The size of polyp (if found) -> is ONLY for COLON/FLEXI
					 , T.PolypSizeInt AS '@polypSizeInteger'  
					 , T.Detected AS '@observed' 
					 , T.Tattooed	AS '@tattooed'	-- O	-- TattooEnum
					 , sum(T.Performed)	AS '@performed'	-- M	-- REQUIRED; INT	-- ## Number performed
					 , sum(T.Successful)	AS '@successful' -- M	-- REQUIRED; INT -- Number of successful
					 , sum(T.Retrieved)	AS '@retrieved'	-- O	-- INT	-- ## Number of Polyp retrieved -> is ONLY for COLON/FLEXI
					 , T.comment 	AS '@comment'	-- O	--## Use this field to define what “Other” is when selected.
					 , T.Morphology AS '@morphology' -- **************************** TO DO *********************************

				FROM dbo.tvfNED_ProcedureTherapeutic(P.ProcedureType, @ProcedureId, Staff.ConsultantTypeId) AS T --## Which Consultant's Record in the Procedure?
					LEFT JOIN dbo.ERS_Sites ES ON es.SiteId = T.SiteId
					LEFT JOIN tvfProcedureResectedColon(@ProcedureId) RC ON RC.RegionId = ES.RegionId
				group by T.SiteId,T.NedName, 
						CASE WHEN rc.RegionId IS NULL THEN T.[Site] ELSE 'Ileo-colon anastomosis' END,
						T.EndoRole,
						T.polypSize,
						T.PolypSizeInt,
						T.Detected,
						T.Tattooed, 
						T.comment,
						T.Morphology) as a
				FOR XML PATH('therapeutic'), ROOT('therapeutics'), TYPE
			)/* End of: Therapeutic List- for a Staff Member		*/
			FROM dbo.tvfNED_ProcedureConsultants(@ProcedureId, P.ProcedureType) AS Staff
			WHERE Staff.EndosId > 0
			FOR XML PATH('Staff'), ROOT('staff.members'), TYPE
		)
			/*	##### Indications: -- 1 or Many	*/		
			, (
				SELECT 
					  dbo.HTMLDecode(I.NedTerm) As '@indication'
					, I.Comment AS '@comment'
					, I.elevatedCalprotectinValue AS '@elevatedCalprotectinValue' -- When indication is Elevated calprotectin then specify the value in (micrograms/gram)
					FROM dbo.tvfNED_ProcedureIndication(@ProcedureId) AS I
					FOR XML PATH('indication'), ROOT('indications'), TYPE
			)
			/*	##### subIndications: -- 0 or Many	*/	
			, (
				SELECT 
					  I.NedTerm As '@type'
					, I.Comment AS '@comment'
					FROM dbo.tvfNED_ProcedureSubIndication(@ProcedureId) AS I
					FOR XML PATH('subIndication'), ROOT('subIndications'), TYPE
			)
			
			/*	##### Limitations: */
			,(
				Select 	
					  L.Limitation As '@limitation'
					, L.Comment As '@comment'
				from [dbo].[tvfNED_ProcedureLimitation](P.ProcedureType, @ProcedureId) AS L
					FOR XML PATH('limitation'), ROOT('limitations'), TYPE
			)	

			/*	##### Biopsy: 0 or Many		*/ --## For Colon/Flexi/OGD
			, (	SELECT 
						  B.BiopsySite		AS '@biopsySite'
						, B.NumberPerformed AS '@numberPerformed'
					FROM [dbo].[tvfNED_ProcedureBiopsy](p.ProcedureType, @ProcedureId) AS B				
					 FOR XML PATH('biopsy'), ROOT('biopsies'), TYPE
			)
			/*	##### Diagnoses: 1 or Many		*/ 
			, (	SELECT 
						  D.Ned_Name	AS '@diagnosis'
						, D.tattooed	AS '@tattooed'
						, CASE WHEN RIGHT(D.Site,2) = ', '
							THEN (LEFT(D.Site, LEN(D.Site)-1))
							ELSE  D.Site END		AS '@site'
						, CASE WHEN RIGHT(D.Comment,2)=', ' 
							THEN (LEFT(D.Comment, LEN(D.Comment)-1)) 
							ELSE D.Comment END
									AS '@comment'	--## Remove the extra ',' at the end!
						,D.barrettsLengthCircumferential as '@barrettsLengthCircumferential' --Required for diagnosis of Barretts
						,D.barrettsLengthMaximum AS '@barrettsLengthMaximum'--, barrettsLengthMaximum --Required for diagnosis of Barretts
						,D.barretsInspectionTime AS '@barretsInspectionTime'--, barretsInspectionTime --Required for diagnosis of Barretts
						,D.gastricInspectiontime AS '@gastricInspectionTime'--, gastricInspectiontime --Required if diagnosis of gastric atrophy OR gastric intestinal metaplasia
						,D.oesophagitisLaClassification AS '@oesophagitisLAClassification'--, oesophagitisLaClassification --Required if diagnosis of Oesophagitis - reflux
						,D.DICAScore AS '@DICAScore'--, DICAScore --required if diagnosis of Diverticulosis
						,D.UCEIS AS '@UCEIS'--, UCEIS --If diagnosis is ‘Ulcerative Colitis’ either UCEIS or Mayo scores must be provided
						,D.mayoScore AS '@mayoScore'--, mayoScore --If diagnosis is ‘Ulcerative Colitis’ either UCEIS or Mayo scores must be provided
						--, site --If diagnosis is ‘Crohns Colitis’ or ‘Crohn`s- terminal ileum’ and [ExtentLookup]= ‘Neo-terminal ileum’
						,NULLIF(RutgeertsScore,'') AS '@rutgeertsScore' --If diagnosis is ‘Crohns Colitis’ or ‘Crohn`s- terminal ileum’ and [ExtentLookup]= ‘Neo-terminal ileum’
						, CDEIS AS '@CDEIS' --If diagnosis is ‘Crohns Colitis’ or ‘Crohn`s- terminal ileum’
					FROM [dbo].[tvfNED_Diagnoses](p.ProcedureType, @ProcedureId) AS D
					 FOR XML PATH('diagnose'), ROOT('diagnoses'), TYPE
			)
			/*	##### Adverse events: -- 1 or Many	*/
			,(	SELECT 
					  IsNull(AD.adverseEvent,'None')	As '@adverseEvent'
					, (CASE WHEN AD.adverseEvent = 'Other' THEN AD.Comment END) 						As '@comment'
				FROM dbo.tvfNED_ProcedureAdverseEvents(@ProcedureId)		AS AD
				FOR XML PATH('adverse.event'), ROOT('adverse.events'), TYPE			
			)
			, ( Select * from (Select isnull(scog.NEDTerm, 'other') as '@manufacturerGeneration'
						, CASE WHEN scog.NEDTerm IS NULL THEN scog.Description ELSE NULL END as '@other'
				from ERS_Scopes sco
				join ERS_Procedures p on p.Instrument1 = sco.ScopeId
				join ERS_ScopeGenerations scog on sco.ScopeGenerationId = scog.UniqueId
				where p.ProcedureId = @ProcedureId
				union
				Select isnull(scog.NEDTerm, 'other') as '@manufacturerGeneration'
						, CASE WHEN scog.NEDTerm IS NULL THEN scog.Description ELSE NULL END as '@other'
				from ERS_Scopes sco
				join ERS_Procedures p on p.Instrument2 = sco.ScopeId
				join ERS_ScopeGenerations scog on sco.ScopeGenerationId = scog.UniqueId
				where p.ProcedureId = @ProcedureId) as a
				FOR XML PATH('scopes'), ROOT('scopes'), TYPE
			   )
			 , (
				SELECT ISNULL(C.NEDTerm, 'None') AS '@type', 
				(CASE WHEN C.NEDTerm = 'Other' THEN PC.AdditionalInfo END) 						AS '@comment'

				 FROM ERS_Procedures p
				 LEFT JOIN ERS_ProcedureChromendosopy PC ON p.ProcedureId= PC.ProcedureId
				 LEFT JOIN ERS_Chromendoscopies C ON C.UniqueId = PC.ChromendoscopyId
				 WHERE P.ProcedureId = @ProcedureId 
				 FOR XML PATH('chromendoscopy'), ROOT('chromendoscopies'), TYPE
				)  
				 ,( 
					SELECT CASE 
						WHEN @ProcedureTypeId = 1 THEN
							(SELECT DISTINCT * FROM (SELECT 
								CASE WHEN (SELECT COUNT(*) FROM ERS_UpperGIPremedication WHERE DrugName = 'Pharyngeal Anaesthesia' AND ProcedureId = @ProcedureId) = 1 THEN 'Yes' ELSE 'No' END as '@pharyngealAnaes'
								,pe.WithdrawalMins as '@scopeWithdrawalTime'
								,ISNULL(DA.NEDTerm,'None') as '@distalAttachment'
								,CASE WHEN LOWER(DA.NEDTerm) = 'other' THEN PD.AdditionalInfo ELSE NULL END as '@distalAttachmentOther'
								,CASE WHEN p.Transnasal = 1 THEN 'Nasal' ELSE 'Oral' END as '@OGDRoute'
								,V.NEDTerm as '@OGDMucosalVisualisation'
								,CASE WHEN (SELECT COUNT(*) FROM ERS_ProcedureMucosalCleaning WHERE ProcedureId = @ProcedureId) > 1 THEN 'Other' ELSE ISNULL(C.NEDTerm, 'None') END as '@OGDMucosalCleaning'
								,CASE WHEN (SELECT COUNT(*) FROM ERS_ProcedureMucosalCleaning WHERE ProcedureId = @ProcedureId) > 1 THEN dbo.fnNED_MucosalCleaning(@ProcedureId) WHEN LOWER(C.NEDTerm) = 'other' THEN C.Description ELSE NULL END as '@OGDMucosalCleaningOther'
								,CASE WHEN P.FormerProcedureId IS NOT NULL THEN 'Yes' WHEN (SELECT COUNT(*) FROM ERS_Procedures pq WHERE pq.FormerProcedureId = p.ProcedureId) > 0 THEN 'Yes' ELSE 'No' END as '@dualProcedure'
								,CASE WHEN dbo.fnNED_GetOGDPhotoDocumentation(@ProcedureId) = 1 THEN 'Yes' ELSE 'No' END '@photoDocumentation'
								from ERS_Procedures AS P 
									LEFT JOIN ERS_ProcedureMucosalVisualisation PV ON PV.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_MucosalVisualisation V ON V.UniqueId = PV.MucosalVisualisationId
									LEFT JOIN ERS_ProcedureUpperExtent PE ON PE.ProcedureId = P.ProcedureId AND PE.WithdrawalMins IS NOT NULL /*there may be more than 1 record in the table where there's 2 endos on a procedure*/
									LEFT JOIN ERS_ProcedureDistalAttachment PD ON PD.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_DistalAttachments DA ON DA.UniqueId = PD.DistalAttachmentId
									LEFT JOIN ERS_ProcedureMucosalCleaning PC ON PC.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_MucosalCleaning C ON C.UniqueId = PC.MucosalCleaningId
								Where P.ProcedureId=@ProcedureId) ogd
							FOR XML PATH('OGD'),TYPE)
						WHEN @ProcedureTypeId = 2 THEN
							(SELECT * FROM (SELECT DISTINCT 
								CASE WHEN (SELECT COUNT(*) FROM ERS_UpperGIPremedication WHERE DrugName = 'Pharyngeal Anaesthesia' AND ProcedureId = @ProcedureId) = 1 THEN 'Yes' ELSE 'No' END as '@pharyngealAnaes'
								,CASE WHEN (SELECT COUNT(*) FROM ERS_UpperGIPremedication WHERE DrugName = 'Prophylactic Antibiotics' AND ProcedureId = @ProcedureId) = 1 THEN 'Yes' ELSE 'No' END as '@antibioticGiven'
								,NULLIF(CASE WHEN ((ev.IntendedBileDuct = 1 AND ev.MajorPapillaBile = 1) OR (ev.IntendedBileDuct_ER = 1 AND ev.MajorPapillaBile_ER = 1)) OR
												  ((ev.IntendedPancreaticDuct = 1 AND ev.MajorPapillaPancreatic = 1) OR (ev.IntendedPancreaticDuct_ER = 1 AND ev.MajorPapillaPancreatic_ER = 1)) THEN 'Yes' 
											 WHEN ((ev.IntendedBileDuct = 1 AND ev.MajorPapillaBile <> 1) OR (ev.IntendedBileDuct_ER = 1 AND ev.MajorPapillaBile_ER <> 1)) OR
												  ((ev.IntendedPancreaticDuct = 1 AND ev.MajorPapillaPancreatic <> 1) OR (ev.IntendedPancreaticDuct_ER = 1 AND ev.MajorPapillaPancreatic_ER <> 1)) THEN 'No'
											ELSE 'Not Applicable' END,'') as '@successfulCannulation'
								,ISNULL((SELECT MAX(ISNULL(convert(int, d.StonesSize),0)) FROM ERS_ERCPAbnoDuct d INNER JOIN ERS_Sites s ON S.SiteId = d.SiteId WHERE S.ProcedureId = @ProcedureId),0) AS '@sizeLargestStone'
								--,ISNULL(CASE WHEN ExtractionOutcome = 1 THEN CONVERT(varchar(max),'Yes') 
								--       WHEN ExtractionOutcome <> 0 THEN CONVERT(varchar(max),'No') END,'Not Applicable') AS '@completeStoneClearance'
								,ISNULL((SELECT TOP 1 CASE WHEN ISNULL(ExtractionOutcome,0) = 1 THEN convert(varchar(max),'Yes') 
											  WHEN StoneRemoval = 0 or ExtractionOutcome <> 1 THEN 'No' END 
								 FROM dbo.ERS_ERCPTherapeutics ET WHERE SiteId IN (SELECT SiteId FROM ERS_Sites WHERE ProcedureId = @ProcedureId)),'Not Applicable') as '@completeStoneClearance'
								,ISNULL((SELECT CASE WHEN LOWER(Region) LIKE '%hepatic%' THEN convert(varchar(max), 'Yes') ELSE convert(varchar(max), 'No') END
											FROM ERS_ERCPAbnoDuct eed 
											INNER JOIN dbo.ERS_Sites es ON eed.SiteId = es.SiteId
												INNER JOIN dbo.ERS_Regions er ON es.RegionId = er.RegionId
											WHERE es.ProcedureId = @ProcedureId AND Stricture = 1),convert(varchar(max), 'Not Applicable')) AS '@extraHepaticStricture'
								,ISNULL((SELECT CASE WHEN eed.Stricture = 1 AND eug.BrushCytology = 1 THEN convert(varchar(max),'Yes') WHEN eed.Stricture = 1 AND eug.BrushCytology = 0 THEN convert(varchar(max),'No') WHEN eed.Stricture = 0 THEN 'Not Applicable' END 
										 FROM ERS_ERCPAbnoDuct eed 
												INNER JOIN dbo.ERS_Sites es ON eed.SiteId = es.SiteId
												INNER JOIN dbo.ERS_Regions er ON es.RegionId = er.RegionId
												INNER JOIN dbo.ERS_UpperGISpecimens eug ON es.SiteId = eug.SiteId
											WHERE es.ProcedureId = @ProcedureId AND
												LOWER(Region) LIKE '%hepatic%'),convert(varchar(max),'Not Applicable')) AS '@extrahepaticStrictureCytologyHistologyTaken'
								,ISNULL((SELECT CASE WHEN eug.CorrectStentPlacement = 1 OR ert.CorrectStentPlacement = 1 THEN convert(varchar(max),'Yes') ELSE convert(varchar(max),'No') END
											FROM ERS_ERCPAbnoDuct eed 
												INNER JOIN dbo.ERS_Sites es ON eed.SiteId = es.SiteId
												INNER JOIN dbo.ERS_Regions er ON es.RegionId = er.RegionId
												LEFT JOIN dbo.ERS_UpperGITherapeutics eug ON es.SiteId = eug.SiteId
												LEFT JOIN dbo.ERS_ERCPTherapeutics ert ON es.SiteId = ert.SiteId
											WHERE es.ProcedureId = @ProcedureId AND eed.Stricture = 1 AND eug.StentInsertion = 1 AND
												LOWER(Region) LIKE '%hepatic%'),convert(varchar(max),'Not Applicable')) AS '@extrahepaticStrictureStentSuccessfullyPlaced'
								,CASE WHEN ISNULL(eea.MajorBilrothRoux,0) = 1 THEN 'Yes' ELSE 'No' END AS '@previousSurgeryBilrothRoux'
								,NULLIF(lc.NEDTerm,0) AS '@levelOfComplexity'
								,CASE WHEN (SELECT COUNT(*) FROM ERS_UpperGIPremedication WHERE DrugName = 'Prophylactic Rectal NSAIDS' AND ProcedureId = @ProcedureId) = 1 THEN 'Yes' ELSE 'No' END as '@prophylacticRectalNSAIDS'
								,CASE WHEN eea.MinorSiteLocation IN (1,2) THEN 'No' ELSE 'Yes' END AS '@nativePapilla'
								from ERS_Procedures AS P 
									LEFT JOIN (SELECT eed.AbnoDuctId, es.ProcedureId, eed.Stricture, er.Region 
												FROM ERS_ERCPAbnoDuct eed 
													INNER JOIN dbo.ERS_Sites es ON eed.SiteId = es.SiteId
													INNER JOIN dbo.ERS_Regions er ON es.RegionId = er.RegionId
											WHERE es.ProcedureId = @ProcedureId AND
												LOWER(Region) LIKE '%hepatic%')  ercs ON ercs.ProcedureId = P.ProcedureId
									LEFT JOIN (SELECT Stones, ISNULL(t.ExtractionOutcome,0) ExtractionOutcome, es.ProcedureId 
												FROM ERS_ERCPAbnoDuct a
													 INNER JOIN dbo.ERS_Sites es ON a.SiteId = es.SiteId
													 LEFT JOIN ERS_ERCPTherapeutics t ON t.siteId = a.SiteId
												 WHERE a.Stones = 1) estones ON estones.ProcedureId = P.ProcedureId
									LEFT JOIN dbo.ERS_ERCPPapillaryAnatomy eea ON P.ProcedureId = eea.ProcedureId
									LEFT JOIN dbo.ERS_Visualisation ev ON P.ProcedureId = ev.ProcedureID
									LEFT JOIN dbo.ERS_ProcedureLevelOfComplexity cl ON cl.ProcedureId = P.ProcedureId
									LEFT JOIN dbo.ERS_LevelOfComplexity lc ON lc.UniqueId = cl.ComplexityId
								Where P.ProcedureId=@ProcedureId) ercp
							FOR XML PATH('ERCP'),TYPE) 
						WHEN @ProcedureTypeId = 3 THEN
							(SELECT TOP 1 * FROM (SELECT 
								(SELECT ISNULL(SUM(Detected),0) FROM tvfNED_PolypsDetailsView(@ProcedureTypeId, @ProcedureId)) as '@polypsDetected'
								,CASE WHEN p.ScopeGuide = 1 THEN 'Yes' ELSE 'No' END AS '@magneticEndoscopeImagerUsed'
								,LE.WithdrawalMins AS '@scopeWithdrawalTime'
								,CASE WHEN LE.RectalExamPerformed = 1 THEN 'Yes' ELSE 'No' END AS '@digitalRectalExamination'
								,CONVERT(VARCHAR(19),LE.CaecumIntubationStart, 126) AS '@caecumTime'
								,ISNULL(DA.NEDTerm,'None') as '@distalAttachment'
								,NULLIF(CASE WHEN LOWER(DA.NEDTerm) = 'other' THEN PD.AdditionalInfo ELSE '' END,'') as '@distalAttachmentOther'
								,IT.NEDTerm as '@insertionTechnique'
								,PB.LeftPrepScore as '@bowelPrepLeft'
								,PB.RightPrepScore as '@bowelPrepRight'
								,PB.TransversePrepScore as '@bowelPrepTransverse'
								,PB.TotalPrepScore as '@bowelPrepTotal'
								,ISNULL(B.NEDTerm,'None') as '@bowelPrep'
								,NULLIF(CASE WHEN LOWER(B.NEDTerm) = 'other' THEN B.[Description] ELSE '' END,'') as '@bowelPrepOther'
								,CASE WHEN P.FormerProcedureId IS NOT NULL THEN 'Yes' WHEN (SELECT COUNT(*) FROM ERS_Procedures pq WHERE pq.FormerProcedureId = p.ProcedureId) > 0 THEN 'Yes' ELSE 'No' END as '@dualProcedure'
								,CASE WHEN NULLIF(fit.FITValue,'') IS NOT NULL THEN fit.FITValue END AS '@fitValue'
								,CASE WHEN fit.FITNotKnownId IS NOT NULL THEN fnk.NEDTerm END AS '@fitNotKnown'
								FROM ERS_Procedures AS P 
									LEFT JOIN ERS_ProcedureLowerExtent LE ON LE.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_ProcedureDistalAttachment PD ON PD.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_DistalAttachments DA ON DA.UniqueId = PD.DistalAttachmentId
									LEFT JOIN ERS_ProcedureInsertionTechnique PIT ON PIT.ProcedureId = p.ProcedureId
									LEFT JOIN ERS_InsertionTechniques IT ON IT.UniqueId = PIT.InsertionTechniqueId
									LEFT JOIN ERS_ProcedureBowelPrep PB ON PB.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_BowelPrep B ON B.UniqueId = PB.BowelPrepId
									LEFT JOIN ERS_ProcedureFITValue fit ON fit.ProcedureId = p.ProcedureId
									LEFT JOIN ERS_FitNotKnownReasons fnk ON fnk.UniqueId = fit.FITNotKnownId
								Where P.ProcedureId=@ProcedureId) col
							FOR XML PATH('Colon'),TYPE)
						WHEN @ProcedureTypeId = 4 THEN
							(SELECT * FROM (SELECT 
								(SELECT ISNULL(SUM(Detected),0) FROM tvfNED_PolypsDetailsView(@ProcedureTypeId, @ProcedureId)) as '@polypsDetected'
								,CASE WHEN LE.RectalExamPerformed = 1 THEN 'Yes' ELSE 'No' END AS '@digitalRectalExamination'
								,CASE WHEN p.ScopeGuide = 1 THEN 'Yes' ELSE 'No' END AS '@magneticEndoscopeImagerUsed'
								,ISNULL(DA.NEDTerm,'None') as '@distalAttachment'
								,CASE WHEN LOWER(DA.NEDTerm) = 'other' THEN PD.AdditionalInfo ELSE NULL END as '@distalAttachmentOther'
								,IT.NEDTerm as '@insertionTechnique'
								,PB.LeftPrepScore as '@bowelPrepLeft'
								,PB.TransversePrepScore as '@bowelPrepTransverse'
								,PB.RightPrepScore as '@bowelPrepRight'
								,PB.TotalPrepScore as '@bowelPrepTotal'
								,ISNULL(B.NEDTerm,'None') as '@bowelPrep'
								,CASE WHEN LOWER(B.NEDTerm) = 'other' THEN B.[Description] ELSE NULL END as '@bowelPrepOther'
								,CASE WHEN NULLIF(fit.FITValue,'') IS NOT NULL THEN fit.FITValue END AS '@fitValue'
								,CASE WHEN fit.FITNotKnownId IS NOT NULL THEN fnk.NEDTerm END AS '@fitNotKnown'
								FROM ERS_Procedures AS P 
									LEFT JOIN (Select ProcedureId, Max(CONVERT(int,RectalExamPerformed)) as RectalExamPerformed from ERS_ProcedureLowerExtent group by ProcedureId) LE ON LE.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_ProcedureDistalAttachment PD ON PD.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_DistalAttachments DA ON DA.UniqueId = PD.DistalAttachmentId
									LEFT JOIN ERS_ProcedureInsertionTechnique PIT ON PIT.ProcedureId = p.ProcedureId
									LEFT JOIN ERS_InsertionTechniques IT ON IT.UniqueId = PIT.InsertionTechniqueId
									LEFT JOIN ERS_ProcedureBowelPrep PB ON PB.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_BowelPrep B ON B.UniqueId = PB.BowelPrepId
									LEFT JOIN ERS_ProcedureFITValue fit ON fit.ProcedureId = p.ProcedureId
									LEFT JOIN ERS_FitNotKnownReasons fnk ON fnk.UniqueId = fit.FITNotKnownId
								Where P.ProcedureId=@ProcedureId) flexi
							FOR XML PATH('Flexi'),TYPE)  
						WHEN @ProcedureTypeId IN (6,7) THEN
							(SELECT * FROM (SELECT DISTINCT CASE WHEN pm.DrugName = '' THEN 'Yes' ELSE 'No' END AS '@prophylacticAntibioticsBeforeEUS',
												ISNULL(dbo.fnNED_FNAFNBSolidLesions(@ProcedureId, P.ProcedureType),'Not applicable') AS '@FNAorFNBSolidLesions',
												ISNULL(dbo.fnNED_FNAFNBTissueAdequacy(@ProcedureId),'Not Applicable') AS '@FNAorFNBTissueAdequacy'
											FROM ERS_UpperGIPremedication pm
												LEFT JOIN ERS_Sites s ON s.ProcedureId = pm.ProcedureId
												LEFT JOIN ERS_UpperGITherapeutics T ON S.SiteId = T.SiteId
												LEFT JOIN ERS_UpperGISpecimens AS SP  ON SP.SiteId = S.SiteId
												LEFT JOIN ERS_ERCPTherapeutics ET ON ET.SiteId = S.SiteId
											WHERE pm.ProcedureId = @ProcedureId) eushpb
								FOR XML PATH('EUS'),TYPE)  
						WHEN @ProcedureTypeId IN (8,9) THEN
							 (SELECT * FROM (SELECT DISTINCT 
								 (SELECT ISNULL(SUM(Detected),0) FROM tvfNED_PolypsTotalsView(@ProcedureId)) AS '@polypsDetected'
								 ,ISNULL(DA.NEDTerm,'None') as '@distalAttachment'
								 ,CASE WHEN LOWER(DA.NEDTerm) = 'other' THEN PDA.AdditionalInfo ELSE NULL END as '@distalAttachmentOther'
								 ,ISNULL(ET.NEDTerm,'None') as '@enteroscopyTechnique'
								 ,CASE WHEN LOWER(ET.NEDTerm) = 'other' THEN PET.AdditionalInfo ELSE NULL END as '@enteroscopyTechniqueOther'
								 ,PID.InsertionLength AS '@depthOfInsertion'
								 ,CASE PID.Tattooed WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE 'Not Applicable' END AS '@tattooMaxDepthInsertion'
								 ,CASE WHEN PE.RectalExamPerformed = 1 AND ET.NEDTerm IN ('Single balloon anal','Double balloon anal') THEN 'Yes' ELSE 'No' END AS '@digitalRectalExamination'
									FROM ERS_Procedures AS P 
										LEFT JOIN ERS_ProcedureDistalAttachment PDA ON PDA.ProcedureId = P.ProcedureId
										LEFT JOIN ERS_DistalAttachments DA ON DA.UniqueId = PDA.DistalAttachmentId
										LEFT JOIN ERS_ProcedureEnteroscopyTechniques PET ON PET.ProcedureId = P.ProcedureId
										LEFT JOIN ERS_EnteroscopyTechniques ET ON ET.UniqueId = PET.TechniqueId
										LEFT JOIN ERS_ProcedureInsertionDepth PID ON PID.ProcedureId = P.ProcedureId
										LEFT JOIN ERS_ProcedureLowerExtent PE ON PE.ProcedureId = P.ProcedureId
									Where P.ProcedureId=@ProcedureId) ent
								FOR XML PATH('ENT'),TYPE)
					END
				  )
		from ERS_Procedures AS P 
		Where P.ProcedureId=@ProcedureId
		FOR XML PATH('procedure'), ROOT('procedures'), TYPE
		)	

    FROM dbo.ERS_Procedures AS P
    LEFT join dbo.ERS_ProcedureDiscomfortScore as DisNo on P.ProcedureId = DisNo.ProcedureId
    LEFT Join dbo.ERS_DiscomfortScores as Dis on DisNo.DiscomfortScoreId = Dis.UniqueId
	LEFT join dbo.ERS_PostProcedureDiscomfortScore PPD on PPD.ProcedureId = P.ProcedureId 
	LEFT join dbo.ERS_DiscomfortScores as PPDD on PPD.DiscomfortScoreId = PPDD.UniqueId
	Left join dbo.ers_lists as PatStat on PatStat.ListDescription = 'Patient Status' and PatStat.ListItemNo = P.PatientStatus 
	Left Join dbo.ERS_UrgencyTypes as Urgency on P.CategoryListId = Urgency.UniqueId
	Left join dbo.ERS_ProcedurePlannedExtent as PPE on P.ProcedureId = PPE.ProcedureId 
	Left Join dbo.ERS_Extent as Ext on PPE.ExtentId = Ext.UniqueId 
	Left join dbo.ERS_ProcedureInsufflation as PIns on P.ProcedureId = PIns.ProcedureId
	Left Join dbo.ERS_Insufflation as Ins on PIns.InsufflationId = Ins.UniqueId 
	Left Join dbo.ERS_ProviderSectors as PS on P.PatientType = PS.UniqueId 
	Left Join dbo.ERS_ReferrerTypes as RT on P.ReferrerType = RT.UniqueId 
	Left join dbo.ERS_ProviderOrganisation as PO on P.ProviderTypeId = PO.UniqueId 
	Left Join dbo.ERS_ProcedureAISoftware as PAIS on P.ProcedureId = PAIS.ProcedureId 
	Left Join dbo.ERS_AISoftware as AIS on PAIS.AISoftwareId = AIS.UniqueId 
	Left Join dbo.ERS_ProcedureChromendosopy as PCHR on PCHR.ProcedureId = p.ProcedureId


  INNER JOIN dbo.ERS_VW_Patients			AS Pat  ON P.PatientId=Pat.[PatientId]
   LEFT JOIN dbo.tvfNED_ProcedureDrugList(@ProcedureId)	AS Drug		ON P.ProcedureId = Drug.ProcedureId	
   --LEFT JOIN dbo.ERS_UpperGIQA				AS QA   ON P.ProcedureId = QA.ProcedureId	-- Patient DIscomfort
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
				 ' xmlns="https://www.jets.nhs.uk/schema/hospital.sendbatchmessage-version2.xsd"'
				  +
				 ' softwareVersion="2"' AS NS_Info		--## These extra info will be added to the Actual XML file in .NET while exporting;
				 , @xmlFileName AS xmlFileName
				 , IsNull(@xmlPreviousExportFileName, 'x') AS PreviousFileName;

END
GO

/* List points converted to decimal to handle half points*/

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER PROCEDURE [dbo].[sch_get_diary_details]
(
	@DiaryId INT
)
AS

	SELECT DISTINCT
		d.DiaryId,
		d.DiaryStart, 
		d.[DiaryEnd],
		d.[UserID], 
		d.ListConsultantId,
		d.[RoomID], 
		d.ListRulesId, 
		d.Training,
		d.Subject,
		d.UserId EndoscopistId,
		d.ListConsultantId,
		(CASE WHEN  ISNULL(u.Title,'') <> '' THEN u.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Forename,'') <> '' THEN u.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Surname,'') <> '' THEN u.Surname + ' ' ELSE '' END) as EndoscopistName,
	  (CASE WHEN  ISNULL(c.Title,'') <> '' THEN c.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(c.Forename,'') <> '' THEN c.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(c.Surname,'') <> '' THEN c.Surname + ' ' ELSE '' END) as ListConsultant,
	  ls.TotalMinutes,
	  ls.TotalPoints,
	  ls.OverBookedPoints,
	  ISNULL(d.Notes,'') Notes,
	  d.ListGenderId,
	  ISNULL(g.Title,'') ListGender,
	  IsGI,
	  d.Locked,
	  CASE WHEN (SELECT count(a.AppointmentId) FROM ERS_Appointments a LEFT JOIN dbo.ERS_AppointmentStatus s ON s.UniqueId = a.AppointmentStatusId WHERE DiaryId = @DiaryId AND ISNULL(s.HDCKEY,'') NOT IN ('C', 'BS')) > 0 THEN convert(bit,1) ELSE convert(bit,0) END Appointments,
	  ISNULL((SELECT sum(pt.points) FROM ERS_AppointmentProcedureTypes pt INNER JOIN ERS_Appointments a ON a.AppointmentId = pt.AppointmentID LEFT JOIN dbo.ERS_AppointmentStatus s ON s.UniqueId = a.AppointmentStatusId WHERE DiaryId = @DiaryId AND ISNULL(s.HDCKEY,'') NOT IN ('C','BS')),0) AppointmentPoints,
	  ISNULL((SELECT sum(pt.points) FROM ERS_AppointmentProcedureTypes pt INNER JOIN ERS_Appointments a ON a.AppointmentId = pt.AppointmentID LEFT JOIN dbo.ERS_AppointmentStatus s ON s.UniqueId = a.AppointmentStatusId WHERE DiaryId = @DiaryId AND ISNULL(s.HDCKEY,'') = 'BS'),0) BlockedPoints,
	  CASE WHEN (SELECT count(a.AppointmentId) FROM ERS_Appointments a LEFT JOIN dbo.ERS_AppointmentStatus s ON s.UniqueId = a.AppointmentStatusId WHERE DiaryId = @DiaryId AND ISNULL(s.HDCKEY,'') = 'C') > 0 THEN convert(bit,1) ELSE convert(bit,0) END CancelledAppointments,
	  CASE WHEN ISNULL(RecurrenceParentID, 0) > 0 THEN convert(bit,1) ELSE convert(bit,0) END Recurring,
	  CASE WHEN ISNULL(RecurrenceParentID, 0) > 0 THEN 
		CASE RecurrenceFrequency WHEN 'd' THEN 'daily for ' + convert(varchar(10), RecurrenceCount) + ' day(s)'
							     WHEN 'w' THEN 'weekly for ' + convert(varchar(10), RecurrenceCount) + ' week(s)' 
								 when 'm' THEN 'montly for ' + convert(varchar(10), RecurrenceCount) + ' month(s)' 
		END 
	  END RecurrancePattern
	FROM ERS_SCH_DiaryPages d
		INNER JOIN ERS_Users u ON u.UserID = d.UserId
		LEFT JOIN ERS_Users c ON c.UserID = d.ListConsultantId
		INNER JOIN (SELECT ls.ListRulesId, (SUM(Points) - SUM(CONVERT(DECIMAL, IsOverBookedSlot))) TotalPoints, SUM(CONVERT(DECIMAL, IsOverBookedSlot)) OverBookedPoints, SUM(SlotMinutes) TotalMinutes FROM ERS_SCH_ListSlots ls WHERE ls.Active = 1 GROUP BY ListRulesId) ls ON ls.ListRulesId = d.ListRulesId
		LEFT JOIN ERS_GenderTypes g on g.GenderId = d.ListGenderId
	WHERE d.DiaryId = @DiaryId
GO


/* Scheduler transformation to set recurring diaries to suppressed */



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sys_transformed_diary_add]
(
	@DiaryId INT,
	@Subject VARCHAR(500), 
	@DiaryStart DATETIME, 
	@DiaryEnd DATETIME, 
	@RoomID INT, 
	@UserID INT, 
	@RecurrenceFrequency VARCHAR(500), 
	@RecurrenceCount INT, 
	@RecurrenceParentID int, 
	@ListRulesId int,
	@Description varchar(500),
	@OperatingHospitalId INT,
	@Training bit,
	@ListConsultant int,
	@ListGenderId int,
	@IsGI BIT,
	@ListNotes VARCHAR(max),
	@Add BIT
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	--create copy of list rules
	INSERT INTO dbo.ERS_SCH_ListRules
	(
	    Points,
	    PointMins,
	    Endoscopist,
	    ListName,
	    GIProcedure,
	    Training,
	    StartTime,
	    Suppressed,
	    OperatingHospitalId,
	    NonGIProcedureTypeId,
	    NonGIProcedureMinutesPerPoint,
	    NonGIDiagnosticCallInTime,
	    NonGIDiagnosticProcedurePoints,
	    NonGITherapeuticCallInTime,
	    NonGITherapeuticProcedurePoints,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ListConsultantId,
	    TotalMins,
	    IsTemplate,
	    GenderId
	)
	SELECT 
		Points,
	    PointMins,
	    Endoscopist,
	    ListName,
	    GIProcedure,
	    Training,
	    StartTime,
	    Suppressed,
	    OperatingHospitalId,
	    NonGIProcedureTypeId,
	    NonGIProcedureMinutesPerPoint,
	    NonGIDiagnosticCallInTime,
	    NonGIDiagnosticProcedurePoints,
	    NonGITherapeuticCallInTime,
	    NonGITherapeuticProcedurePoints,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ListConsultantId,
	    TotalMins,
	    0,
	    GenderId
	FROM dbo.ERS_SCH_ListRules WHERE ListRulesId = @ListRulesId

	--retrieve list rules id
	DECLARE @NewListRulesId INT = SCOPE_IDENTITY()

	--create copy of list slots
	INSERT INTO dbo.ERS_SCH_ListSlots
	(
	    ListRulesId,
	    SlotId,
	    ProcedureTypeId,
	    StartTime,
	    EndTime,
	    Suppressed,
	    OperatingHospitalId,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ParentListSlotId,
	    SlotMinutes,
	    Active,
	    DeactivatedDateTime,
	    Points,
	    Locked,
	    IsOverBookedSlot
	)
	SELECT 
		@NewListRulesId,
	    SlotId,
	    ProcedureTypeId,
	    StartTime,
	    EndTime,
	    Suppressed,
	    OperatingHospitalId,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ParentListSlotId,
	    SlotMinutes,
	    Active,
	    DeactivatedDateTime,
	    Points,
	    Locked,
	    IsOverBookedSlot
	FROM dbo.ERS_SCH_ListSlots
	WHERE ListRulesId = @ListRulesId AND Active = 1 AND Suppressed = 0

	IF @Add = 1 
	BEGIN
		
		
		INSERT INTO [ERS_SCH_DiaryPages] 
		([Subject], [DiaryStart], [DiaryEnd], [RoomID], [UserID], [ListRulesId], [OperatingHospitalId], [RecurrenceFrequency], [RecurrenceCount], [RecurrenceParentID], [WhenCreated], [Training], [ListConsultantId], ListGenderId, IsGI, Notes) 
		SELECT ListName, @DiaryStart, @DiaryEnd, @RoomId, @UserID, @NewListRulesId, @OperatingHospitalId, @RecurrenceFrequency, @RecurrenceCount, @RecurrenceParentID, GETDATE(), Training, @ListConsultant, @ListGenderId, @IsGI, @ListNotes  
		FROM dbo.ERS_SCH_ListRules WHERE ListRulesId = @ListRulesId
		
		DECLARE @NewDiaryId INT = (SELECT SCOPE_IDENTITY ())

		UPDATE ERS_SCH_DiaryPages
		SET DiaryStart = dateadd(year,-100, DiaryStart),
			DiaryEnd = DATEADD(year, -100, DiaryEnd),
			Suppressed = 1
		WHERE DiaryId = @DiaryId and datediff(year, diarystart, getdate())< 50

		SELECT @NewDiaryId DiaryId, @NewListRulesId ListRulesId
	END
	ELSE
	BEGIN
		UPDATE ERS_SCH_DiaryPages
		SET ListGenderId = @ListGenderId,
			Notes = @ListNotes,
			IsGI = @IsGI,
			ListRulesId = @NewListRulesId,
			Suppressed = 0,
			SuppressedFromDate = NULL
		WHERE DiaryId = @DiaryId

		SELECT @DiaryId DiaryId, @NewListRulesId ListRulesId
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

Go
Exec DropIfExist 'trg_ERS_Procedures_Update','TR'
Go

CREATE TRIGGER [dbo].[trg_ERS_Procedures_Update] ON [dbo].[ERS_Procedures] 
AFTER UPDATE
AS 
--26 Feb 2024		:		MH allowing changing PatientId but logging in
SET NOCOUNT ON; 

IF UPDATE([PatientId])
BEGIN
   --;THROW 51000, 'Update the Patient ID is forbidden', 1;  
   --Rollback transaction
   Declare @ProductVersion varchar(50), @ErrorMessage varchar(200), @ErrorReference varchar(50)
   Declare @UserId Int,@ProcedureId Int,@PatientId Int, @OldPatientId int, @OperatingHospitalId int
   Select @UserId = IsNull(WhoCreatedId,1),@ProcedureId = ProcedureId,@PatientId = PatientId,@OperatingHospitalId=OperatingHospitalID from inserted
   Select @OldPatientId = PatientId from deleted
   
   If @UserId is null Set @UserId = 1
   If @OperatingHospitalId is null 
   Begin
	Select top 1 @OperatingHospitalId = OperatingHospitalId from ERS_OperatingHospitals
   End
	Set @ErrorMessage = 'Old PatientId : ' + Convert(varchar(20),@OldPatientId) + ', New PatientId : ' + Convert(varchar(20),@PatientId)
	Set @ErrorReference = 'PATCHANGE_' + CONVERT(VARCHAR(30), getdate(), 112) + REPLACE(CONVERT(VARCHAR(30), getdate(), 108), ':', '')
			Select top 1 @ProductVersion = VersionNum from DBVersion Order by InstallDate desc			
			
			Insert into ERS_ErrorLog(ErrorReference,ErrorTimestamp,ErrorNo,ErrorMessage,ErrorDescription,ProductId,ProductVersion,UserId,ProcedureId,PatientId,HospitalId,OperatingHospitalId)
			Values(@ErrorReference,GETDATE(),Convert(varchar(30), @ProcedureId), 'PatientId is being changed.', @ErrorMessage,1, @ProductVersion, @UserId,@ProcedureId,@PatientId,@OperatingHospitalId,@OperatingHospitalId)

END

INSERT INTO [ERSAudit].[ERS_Procedures_Audit] (ProcedureId, tbl.[ProcedureType], tbl.[CreatedBy], tbl.[CreatedOn], tbl.[ModifiedOn], tbl.[PatientId], tbl.[PatientType], tbl.[PatientStatus], tbl.[Ward], tbl.[CategoryListId], tbl.[OnWaitingList], tbl.[OpenAccessProc], tbl.[EmergencyProcType], tbl.[OperatingHospitalID], tbl.[ReferralHospitalNo], tbl.[ReferralConsultantNo], tbl.[GPReferralFlag], tbl.[DiagramNumber], tbl.[ListType], tbl.[ListConsultant], tbl.[ConsultantPresent], tbl.[Endoscopist1], tbl.[Endo1Role], tbl.[Endoscopist2], tbl.[Endo2Role], tbl.[Assistant], tbl.[Nurse1], tbl.[Nurse2], tbl.[Nurse3], tbl.[Instrument1], tbl.[Instrument2], tbl.[ResectedColonNo], tbl.[IncludeProcNotes], tbl.[ProcedureNotes], tbl.[Video], tbl.[VideoNotes], tbl.[GPReportText], tbl.[TextEdited], tbl.[DiagramIncluded], tbl.[EndoscribeComments], tbl.[EndoscribePremedication], tbl.[MucosalJunctionAt], tbl.[NewCardia], tbl.[AbnoText], tbl.[PancreasDivisum], tbl.[BiliaryManometry], tbl.[PancreaticManometry], tbl.[FirstERCP], tbl.[ExportedToEPR], tbl.[ForcepType], tbl.[ForcepSerialNo], tbl.[AccountNo], tbl.[DNA], tbl.[DNACombined], tbl.[DNACreatedViaRC], tbl.[ExportFileName], tbl.[ExportProducedOn], tbl.[ReferralConsultantSpeciality], tbl.[PatientConsent], tbl.[SurgicalSafetyCheckListCompleted], tbl.[GPCode], tbl.[GPPracticeCode], tbl.[NEDEnabled], tbl.[NEDExported], tbl.[NEDProcedureId], tbl.[ScopeGuide], tbl.[FormerProcedureId], tbl.[ProcedureCompleted], tbl.[IsDirty], tbl.[IsActive], tbl.[BreathTestResult], tbl.[ImagePortId], tbl.[Transnasal], tbl.[ReportUpdated],  LastActionId, ActionDateTime, ActionUserId)
SELECT tbl.ProcedureId , tbl.[ProcedureType], tbl.[CreatedBy], tbl.[CreatedOn], tbl.[ModifiedOn], tbl.[PatientId], tbl.[PatientType], tbl.[PatientStatus], tbl.[Ward], tbl.[CategoryListId], tbl.[OnWaitingList], tbl.[OpenAccessProc], tbl.[EmergencyProcType], tbl.[OperatingHospitalID], tbl.[ReferralHospitalNo], tbl.[ReferralConsultantNo], tbl.[GPReferralFlag], tbl.[DiagramNumber], tbl.[ListType], tbl.[ListConsultant], tbl.[ConsultantPresent], tbl.[Endoscopist1], tbl.[Endo1Role], tbl.[Endoscopist2], tbl.[Endo2Role], tbl.[Assistant], tbl.[Nurse1], tbl.[Nurse2], tbl.[Nurse3], tbl.[Instrument1], tbl.[Instrument2], tbl.[ResectedColonNo], tbl.[IncludeProcNotes], tbl.[ProcedureNotes], tbl.[Video], tbl.[VideoNotes], tbl.[GPReportText], tbl.[TextEdited], tbl.[DiagramIncluded], tbl.[EndoscribeComments], tbl.[EndoscribePremedication], tbl.[MucosalJunctionAt], tbl.[NewCardia], tbl.[AbnoText], tbl.[PancreasDivisum], tbl.[BiliaryManometry], tbl.[PancreaticManometry], tbl.[FirstERCP], tbl.[ExportedToEPR], tbl.[ForcepType], tbl.[ForcepSerialNo], tbl.[AccountNo], tbl.[DNA], tbl.[DNACombined], tbl.[DNACreatedViaRC], tbl.[ExportFileName], tbl.[ExportProducedOn], tbl.[ReferralConsultantSpeciality], tbl.[PatientConsent], tbl.[SurgicalSafetyCheckListCompleted], tbl.[GPCode], tbl.[GPPracticeCode], tbl.[NEDEnabled], tbl.[NEDExported], tbl.[NEDProcedureId], tbl.[ScopeGuide], tbl.[FormerProcedureId], tbl.[ProcedureCompleted], tbl.[IsDirty], tbl.[IsActive], tbl.[BreathTestResult], tbl.[ImagePortId], tbl.[Transnasal], tbl.[ReportUpdated],  2, GETDATE(), i.WhoUpdatedId
FROM deleted tbl INNER JOIN inserted i ON tbl.ProcedureId = i.ProcedureId

------------------------------------------------------------------------------------------------------------------------
-- END OF ALTER TRIGGER 
------------------------------------------------------------------------------------------------------------------------
Go



------------------------------------------------------------------------------------------------------------------------
-- Change for scheduler transformation
------------------------------------------------------------------------------------------------------------------------


ALTER PROCEDURE [dbo].[sch_add_overbook_slot]
(		
	@DiaryId INT,
	@Points DECIMAL(18,2),
	@AppointmentId INT
)
AS
BEGIN
	DECLARE @OperatingHospitalId INT, @ListRulesId INT, @ListSlotId INT

	--get the list rules id for the diary 
	SELECT @OperatingHospitalId = OperatingHospitalId, @ListRulesId = ListRulesId FROM dbo.ERS_SCH_DiaryPages WHERE DiaryId = @DiaryId

	--insert new list slot
	INSERT INTO ERS_SCH_ListSlots (ListRulesId, SlotId, ProcedureTypeId, OperatingHospitalId, SlotMinutes, Points, IsOverBookedSlot, Suppressed)
	SELECT  @ListRulesId, PriorityiD, 0, @OperatingHospitalId, CONVERT(INT, a.AppointmentDuration), @Points, 1, 0
	FROM dbo.ERS_Appointments a WHERE a.AppointmentId = @AppointmentId

	SELECT @ListSlotId = SCOPE_IDENTITY()

	--Update Appointment
	UPDATE dbo.ERS_Appointments SET ListSlotId = @ListSlotId, DiaryId = @DiaryId WHERE AppointmentId = @AppointmentId
END






