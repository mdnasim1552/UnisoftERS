
EXEC DropIfExist 'ogd_diagnoses_summary_update','S';
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

	/*OESOPHGAS REGION*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Oesophagus' AND Value = 'True' AND MatrixCode <>'OesophagusNormal')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OesophagusNormal') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OesophagusNormal' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
	END
	ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Oesophagus')
		INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'OesophagusNormal', 'True', 'Oesophagus', 1)
	
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Oesophagus' AND Value = 'True' AND MatrixCode <>'OesophagusNotEntered')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OesophagusNotEntered') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OesophagusNotEntered' AND Value = 'True'
	END

	/*STOMACH REGION*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Stomach' AND Value ='True' AND MatrixCode <>'StomachNormal')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'StomachNormal')  DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'StomachNormal' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal')  DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
	END
	ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Stomach')
		INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'StomachNormal', 'True', 'Stomach', 1)

	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Stomach' AND Value ='True' AND MatrixCode <>'StomachNotEntered')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'StomachNotEntered')  DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'StomachNotEntered' AND Value = 'True'
	END

	/*DUODENUM REGION*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND Value = 'True' AND MatrixCode <>'DuodenumNormal')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'DuodenumNormal')  DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'DuodenumNormal' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal')   DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
	END
	ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Duodenum')
		INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'DuodenumNormal', 'True', 'Duodenum', 1)

	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND Value = 'True' AND MatrixCode NOT IN ('DuodenumNotEntered','Duodenum2ndPartNotEntered'))
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'DuodenumNotEntered')  DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'DuodenumNotEntered' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'Duodenum2ndPartNotEntered')  DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'Duodenum2ndPartNotEntered' AND Value = 'True'
	END


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
		SELECT 0, (CASE WHEN CHARINDEX('barrett',DisplayName) > 0 OR CHARINDEX('mallory-weiss',DisplayName) > 0 
						THEN DisplayName ELSE LOWER(DisplayName) END) 
				FROM #Oesophagus WHERE SiteId > 0 --Abnormalities for each sites 
	
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

	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode <> 'ColonNormal' )
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

--------------------------------------------------------------------------------------------------------------------
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
       DECLARE @Instr1 int, @Instr2 int
       SELECT   @Instr1 = [Instrument1], @Instr2 = [Instrument2] FROM ERS_Procedures WHERE       ProcedureId = @ProcedureId
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
	END


	IF @ProcedureType =1 --Or @ProcedureType = 6 --only applies to upper GI
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

--------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'otherdata_ercp_diagnoses_save','S';
GO

CREATE PROCEDURE [dbo].[otherdata_ercp_diagnoses_save]
(
	@ProcedureID INT,
	@DuodenumNotEntered BIT,
    @DuodenumNormal BIT,
    @Duodenum2ndPartNotEntered BIT,
	@WholePancreatic BIT,
	@PapillaeNormal BIT,
	@Stenosed BIT,
	@ERCP_TumourBenign BIT,
	@ERCP_TumourMalignant BIT,
	@PancreasNormal BIT,
	@PancreasNotEntered BIT,
	@Annulare BIT,
	@DuctInjury BIT,
	@PanStentOcclusion BIT,
	@IPMT BIT,
	@PancreaticAndBiliaryOther VARCHAR(MAX),
	@BiliaryNormal BIT,
	@AnastomicStricture BIT,
	@Haemobilia BIT,
	@Cholelithiasis BIT,
	@FistulaLeak BIT,
	@Mirizzi BIT,
	@CalculousObstruction BIT,
	@Occlusion BIT,
	@GallBladderTumour BIT,
	@StentOcclusion BIT,
	@NormalDucts BIT,
	@Suppurative BIT,
	@BiliaryLeakSite BIT,
	@BiliaryLeakSiteVal VARCHAR(MAX),
	@IntrahepaticTumourProbable BIT,
	@IntrahepaticTumourPossible BIT,
	@ExtrahepaticNormal BIT,
	@ExtrahepaticLeakSite BIT,
	@ExtrahepaticLeakSiteVal VARCHAR(MAX),
	@BeningPancreatitis BIT,
	@BeningPseudocyst BIT,
	@BeningPrevious BIT,
	@BeningSclerosing BIT,
	@BeningProbable BIT,
	@MalignantGallbladder BIT,
	@MalignantMetastatic BIT,
	@MalignantCholangiocarcinoma BIT,
	@MalignantPancreatic BIT,
	@MalignantProbable BIT,
	@BiliaryOther VARCHAR(MAX),
	@WholeOther VARCHAR(MAX)
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	DELETE
	FROM [ERS_Diagnoses]
	WHERE ProcedureID = @ProcedureID AND IsOtherData = 1

	IF (ISNULL(@WholePancreatic,0) = 1) --Whole pancreatic and biliary system normal 
	BEGIN
		INSERT INTO [ERS_Diagnoses] (ProcedureID, MatrixCode, Value, Region, IsOtherData)
		SELECT @ProcedureId, 'D32P2', CONVERT(VARCHAR(MAX),@WholePancreatic), 'Pancreas', 1
		UNION
		SELECT @ProcedureId, 'D50P2', CONVERT(VARCHAR(MAX),@DuodenumNotEntered), 'Duodenum', 1 WHERE @DuodenumNotEntered = 1 
		UNION
		SELECT @ProcedureId, 'D51P2', CONVERT(VARCHAR(MAX),@DuodenumNormal), 'Duodenum', 1 WHERE @DuodenumNormal = 1 
		UNION
		SELECT @ProcedureId, 'D52P2', CONVERT(VARCHAR(MAX),@Duodenum2ndPartNotEntered), 'Duodenum', 1 WHERE @Duodenum2ndPartNotEntered = 1 
	END
	ELSE
	BEGIN
		INSERT INTO [ERS_Diagnoses] (ProcedureID, MatrixCode, Value, Region, IsOtherData)
		SELECT @ProcedureId, 'D50P2', CONVERT(VARCHAR(MAX),@DuodenumNotEntered), 'Duodenum', 1 WHERE @DuodenumNotEntered = 1 
		UNION
		SELECT @ProcedureId, 'D51P2', CONVERT(VARCHAR(MAX),@DuodenumNormal), 'Duodenum', 1 WHERE @DuodenumNormal = 1 
		UNION
		SELECT @ProcedureId, 'D52P2', CONVERT(VARCHAR(MAX),@Duodenum2ndPartNotEntered), 'Duodenum', 1 WHERE @Duodenum2ndPartNotEntered = 1 
		UNION
		SELECT @ProcedureId, 'D32P2', CONVERT(VARCHAR(MAX),@WholePancreatic), 'Pancreatic', 1 WHERE @WholePancreatic = 1
		UNION	
		SELECT @ProcedureId, 'D33P2', CONVERT(VARCHAR(MAX),@PapillaeNormal), 'Papillae', 1 WHERE @PapillaeNormal = 1
		UNION	
		SELECT @ProcedureId, 'D41P2', CONVERT(VARCHAR(MAX),@Stenosed), 'Papillae', 1 WHERE @Stenosed = 1
		UNION	
		SELECT @ProcedureId, 'D45P2', CONVERT(VARCHAR(MAX),@ERCP_TumourBenign), 'Papillae', 1 WHERE @ERCP_TumourBenign = 1
		UNION	
		SELECT @ProcedureId, 'D65P2', CONVERT(VARCHAR(MAX),@ERCP_TumourMalignant), 'Papillae', 1 WHERE @ERCP_TumourMalignant = 1
		UNION	
		SELECT @ProcedureId, 'D67P2', CONVERT(VARCHAR(MAX),@PancreasNormal), 'Pancreas', 1 WHERE @PancreasNormal = 1
		UNION	
		SELECT @ProcedureId, 'D66P2', CONVERT(VARCHAR(MAX),@PancreasNormal), 'Pancreas', 1 WHERE @PancreasNotEntered = 1
		UNION	
		SELECT @ProcedureId, 'D68P2', CONVERT(VARCHAR(MAX),@Annulare), 'Pancreas', 1 WHERE @Annulare = 1
		UNION	
		SELECT @ProcedureId, 'D69P2', CONVERT(VARCHAR(MAX),@DuctInjury), 'Pancreas', 1 WHERE @DuctInjury = 1
		UNION	
		SELECT @ProcedureId, 'D74P2', CONVERT(VARCHAR(MAX),@PanStentOcclusion), 'Pancreas', 1 WHERE @PanStentOcclusion = 1
		UNION	
		SELECT @ProcedureId, 'D75P2', CONVERT(VARCHAR(MAX),@IPMT), 'Pancreas', 1 WHERE @IPMT = 1
		UNION	
		SELECT @ProcedureId, 'PancreaticOther', CONVERT(VARCHAR(MAX),@PancreaticAndBiliaryOther), 'Pancreas', 1 WHERE ISNULL(@PancreaticAndBiliaryOther,'') <> ''
		UNION	
		SELECT @ProcedureId, 'D138P2', CONVERT(VARCHAR(MAX),@BiliaryNormal), 'Biliary', 1 WHERE @BiliaryNormal = 1
		UNION	
		SELECT @ProcedureId, 'D140P2', CONVERT(VARCHAR(MAX),@AnastomicStricture), 'Biliary', 1 WHERE @AnastomicStricture = 1
		--UNION	
		--SELECT @ProcedureId, 'D155P2', CONVERT(VARCHAR(MAX),@CysticDuct), 'Biliary', 1 WHERE @CysticDuct = 1
		UNION	
		SELECT @ProcedureId, 'D170P2', CONVERT(VARCHAR(MAX),@Haemobilia), 'Biliary', 1 WHERE @Haemobilia = 1
		UNION	
		SELECT @ProcedureId, 'D185P2', CONVERT(VARCHAR(MAX),@Cholelithiasis), 'Biliary', 1 WHERE @Cholelithiasis = 1
		UNION	
		SELECT @ProcedureId, 'D145P2', CONVERT(VARCHAR(MAX),@FistulaLeak), 'Biliary', 1 WHERE @FistulaLeak = 1
		UNION	
		SELECT @ProcedureId, 'D160P2', CONVERT(VARCHAR(MAX),@Mirizzi), 'Biliary', 1 WHERE @Mirizzi = 1
		UNION	
		SELECT @ProcedureId, 'D175P2', CONVERT(VARCHAR(MAX),@CalculousObstruction), 'Biliary', 1 WHERE @CalculousObstruction = 1
		--UNION	
		--SELECT @ProcedureId, 'D190P2', CONVERT(VARCHAR(MAX),@GallBladder), 'Biliary', 1 WHERE @GallBladder = 1
		UNION	
		SELECT @ProcedureId, 'D150P2', CONVERT(VARCHAR(MAX),@Occlusion), 'Biliary', 1 WHERE @Occlusion = 1
		--UNION	
		--SELECT @ProcedureId, 'D165P2', CONVERT(VARCHAR(MAX),@CommonDuct), 'Biliary', 1 WHERE @CommonDuct = 1
		UNION	
		SELECT @ProcedureId, 'D180P2', CONVERT(VARCHAR(MAX),@GallBladderTumour), 'Biliary', 1 WHERE @GallBladderTumour = 1
		UNION	
		SELECT @ProcedureId, 'D195P2', CONVERT(VARCHAR(MAX),@StentOcclusion), 'Biliary', 1 WHERE @StentOcclusion = 1
		UNION	
		SELECT @ProcedureId, 'D198P2', CONVERT(VARCHAR(MAX),@NormalDucts), 'Intrahepatic', 1 WHERE @NormalDucts = 1
		UNION	
		SELECT @ProcedureId, 'D210P2', CONVERT(VARCHAR(MAX),@Suppurative), 'Intrahepatic', 1 WHERE @Suppurative = 1
		UNION	
		SELECT @ProcedureId, 'D220P2', CONVERT(VARCHAR(MAX),@BiliaryLeakSite), 'Intrahepatic', 1 WHERE @BiliaryLeakSite = 1
		UNION	
		SELECT @ProcedureId, 'BiliaryLeakSiteVal', CONVERT(VARCHAR(MAX),@BiliaryLeakSiteVal), 'Intrahepatic', 1 WHERE ISNULL(@BiliaryLeakSiteVal,'') <> ''
		UNION	
		SELECT @ProcedureId, 'D242P2', CONVERT(VARCHAR(MAX),@IntrahepaticTumourProbable), 'Intrahepatic', 1 WHERE @IntrahepaticTumourProbable = 1
		UNION	
		SELECT @ProcedureId, 'D243P2', CONVERT(VARCHAR(MAX),@IntrahepaticTumourPossible), 'Intrahepatic', 1 WHERE @IntrahepaticTumourPossible = 1
		UNION	
		SELECT @ProcedureId, 'D265P2', CONVERT(VARCHAR(MAX),@ExtrahepaticNormal), 'Extrahepatic', 1 WHERE @ExtrahepaticNormal = 1
		UNION	
		SELECT @ProcedureId, 'D280P2', CONVERT(VARCHAR(MAX),@ExtrahepaticLeakSite), 'Extrahepatic', 1 WHERE @ExtrahepaticLeakSite = 1
		UNION	
		SELECT @ProcedureId, 'ExtrahepaticLeakSiteVal', CONVERT(VARCHAR(MAX),@ExtrahepaticLeakSiteVal), 'Extrahepatic', 1 WHERE ISNULL(@ExtrahepaticLeakSiteVal,'') <> ''
		UNION	
		SELECT @ProcedureId, 'D305P2', CONVERT(VARCHAR(MAX),@BeningPancreatitis), 'Extrahepatic', 1 WHERE @BeningPancreatitis = 1
		UNION	
		SELECT @ProcedureId, 'D310P2', CONVERT(VARCHAR(MAX),@BeningPseudocyst), 'Extrahepatic', 1 WHERE @BeningPseudocyst = 1
		UNION	
		SELECT @ProcedureId, 'D315P2', CONVERT(VARCHAR(MAX),@BeningPrevious), 'Extrahepatic', 1 WHERE @BeningPrevious = 1
		UNION	
		SELECT @ProcedureId, 'D320P2', CONVERT(VARCHAR(MAX),@BeningSclerosing), 'Extrahepatic', 1 WHERE @BeningSclerosing = 1
		UNION	
		SELECT @ProcedureId, 'D330P2', CONVERT(VARCHAR(MAX),@BeningProbable), 'Extrahepatic', 1 WHERE @BeningProbable = 1
		UNION	
		SELECT @ProcedureId, 'D340P2', CONVERT(VARCHAR(MAX),@MalignantGallbladder), 'Extrahepatic', 1 WHERE @MalignantGallbladder = 1
		UNION	
		SELECT @ProcedureId, 'D345P2', CONVERT(VARCHAR(MAX),@MalignantMetastatic), 'Extrahepatic', 1 WHERE @MalignantMetastatic = 1
		UNION	
		SELECT @ProcedureId, 'D350P2', CONVERT(VARCHAR(MAX),@MalignantCholangiocarcinoma), 'Extrahepatic', 1 WHERE @MalignantCholangiocarcinoma = 1
		UNION	
		SELECT @ProcedureId, 'D355P2', CONVERT(VARCHAR(MAX),@MalignantPancreatic), 'Extrahepatic', 1 WHERE @MalignantPancreatic = 1
		UNION	
		SELECT @ProcedureId, 'D335P2', CONVERT(VARCHAR(MAX),@MalignantProbable), 'Extrahepatic', 1 WHERE @MalignantProbable = 1
		UNION	
		SELECT @ProcedureId, 'BiliaryOther', CONVERT(VARCHAR(MAX),@BiliaryOther), 'Biliary', 1 WHERE ISNULL(@BiliaryOther,'') <> ''
		UNION	
		SELECT @ProcedureId, 'WholeOther', CONVERT(VARCHAR(MAX),@WholeOther), 'ERCP_Diagnoses', 1 WHERE ISNULL(@WholeOther,'') <> ''

	END

	EXEC ercp_diagnoses_summary_update @ProcedureId;

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
IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code='D66P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeID, Section, Disabled, OrderByNumber, Code, Visible)
	VALUES ('Not Entered',NULL,2,'Pancreas',0,66, 'D66P2',0)
GO

--------------------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'DuctInjury' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE ERS_ERCPAbnoDuct ADD DuctInjury BIT NOT NULL CONSTRAINT [DF_ERCPAbnoDuct_DuctInjury] DEFAULT 0

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'DuctInjury' AND Object_ID = Object_ID(N'ERSAudit.ERS_ERCPAbnoDuct_Audit'))
	ALTER TABLE ERSAudit.ERS_ERCPAbnoDuct_Audit ADD DuctInjury BIT NOT NULL CONSTRAINT [DF_ERCPAbnoDuct_DuctInjury_Audit] DEFAULT 0

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'StentOcclusion' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE ERS_ERCPAbnoDuct ADD StentOcclusion BIT NOT NULL CONSTRAINT [DF_ERCPAbnoDuct_StentOcclusion] DEFAULT 0

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'StentOcclusion' AND Object_ID = Object_ID(N'ERSAudit.ERS_ERCPAbnoDuct_Audit'))
	ALTER TABLE ERSAudit.ERS_ERCPAbnoDuct_Audit ADD StentOcclusion BIT NOT NULL CONSTRAINT [DF_ERCPAbnoDuct_StentOcclusion_Audit] DEFAULT 0

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'GallBladderTumor' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE ERS_ERCPAbnoDuct ADD GallBladderTumor BIT NOT NULL CONSTRAINT [DF_ERCPAbnoDuct_GallBladderTumor] DEFAULT 0

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'GallBladderTumor' AND Object_ID = Object_ID(N'ERSAudit.ERS_ERCPAbnoDuct_Audit'))
	ALTER TABLE ERSAudit.ERS_ERCPAbnoDuct_Audit ADD GallBladderTumor BIT NOT NULL CONSTRAINT [DF_ERCPAbnoDuct_GallBladderTumor_Audit] DEFAULT 0
--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'abnormalities_duct_save','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_duct_save]
(
	@SiteId INT,
	@Normal BIT,
	@Dilated BIT,
	@DilatedLength INT,
	@DilatedType TINYINT,
	@Stricture BIT,
	@StrictureLen DECIMAL(6,1),
	@UpstreamDilatation BIT,
	@CompleteBlock BIT,
	@Smooth BIT,
	@Irregular BIT,
	@Shouldered BIT,
	@Tortuous BIT,
	@StrictureType TINYINT,
	@StrictureProbably BIT,
	@Cholangiocarcinoma BIT,
	@ExternalCompression BIT,
	@Fistula BIT,
	@FistulaQty INT,
	@Visceral BIT,
	@Cutaneous BIT,
	@FistulaComments NVARCHAR(500),
	@Stones BIT,
	@StonesMultiple BIT,
	@StonesQty INT,
	@StonesSize DECIMAL(6,1),
	@Cysts BIT,
	@CystsMultiple BIT,
	@CystsQty INT,
	@CystsDiameter DECIMAL(6,1),
	@CystsSimple BIT,
	@CystsRegular BIT,
	@CystsIrregular BIT,
	@CystsLoculated BIT,
	@CystsCommunicating BIT,
	@CystsCholedochal BIT,
	@CystsSuspectedType TINYINT,
	@DuctInjury BIT,
	@StentOcclusion BIT,
	@GallBladderTumor BIT,
	@LoggedInUserId INT
)
AS

SET NOCOUNT ON

DECLARE @proc_id INT
DECLARE @proc_type INT
DECLARE @region VARCHAR(200)

BEGIN TRANSACTION

BEGIN TRY
	SELECT 
		@proc_id = p.ProcedureId,
		@proc_type = p.ProcedureType,
		@region = r.Region
	FROM 
		ERS_Sites s
	JOIN 
		ERS_Procedures p ON s.ProcedureId = p.ProcedureId
	JOIN
		ERS_Regions r ON s.RegionId = r.RegionId
	WHERE 
		SiteId = @SiteId
	
	
	IF (@Normal=0 AND @Dilated=0 AND @Stricture=0 AND @Fistula=0 AND @Stones=0 AND @Cysts=0 AND @DuctInjury=0 AND @StentOcclusion=0 AND @GallBladderTumor = 0)
	BEGIN
		DELETE FROM ERS_ERCPAbnoDuct 
		WHERE SiteId = @SiteId

		DELETE FROM ERS_RecordCount 
		WHERE SiteId = @SiteId
		AND Identifier = CASE WHEN @region = 'Gall Bladder' THEN 'Gall Bladder'
							 ELSE 'Duct'
						END
	END		

	ELSE IF NOT EXISTS (SELECT 1 FROM ERS_ERCPAbnoDuct WHERE SiteId = @SiteId)
	BEGIN
		INSERT INTO ERS_ERCPAbnoDuct (
			[SiteId]
           ,[Normal]
           ,[Dilated]
           ,[DilatedLength]
           ,[DilatedType]
           ,[Stricture]
           ,[StrictureLen]
           ,[UpstreamDilatation]
           ,[CompleteBlock]
           ,[Smooth]
           ,[Irregular]
           ,[Shouldered]
           ,[Tortuous]
           ,[StrictureType]
		   ,[StrictureProbably]
           ,[Cholangiocarcinoma]
           ,[ExternalCompression]
           ,[Fistula]
           ,[FistulaQty]
           ,[Visceral]
           ,[Cutaneous]
           ,[FistulaComments]
           ,[Stones]
           ,[StonesMultiple]
           ,[StonesQty]
           ,[StonesSize]
           ,[Cysts]
           ,[CystsMultiple]
           ,[CystsQty]
           ,[CystsDiameter]
           ,[CystsSimple]
           ,[CystsRegular]
           ,[CystsIrregular]
           ,[CystsLoculated]
           ,[CystsCommunicating]
		   ,[CystsCholedochal]
           ,[CystsSuspectedType]
		   ,[DuctInjury]
		   ,[StentOcclusion]
		   ,[GallBladderTumor]
		   ,[WhoCreatedId]
		   ,[WhenCreated]) 
		VALUES (
			@SiteId,
			@Normal,
			@Dilated,
			@DilatedLength,
			@DilatedType,
			@Stricture,
			@StrictureLen,
			@UpstreamDilatation,
			@CompleteBlock,
			@Smooth,
			@Irregular,
			@Shouldered,
			@Tortuous,
			@StrictureType,
			@StrictureProbably,
			@Cholangiocarcinoma,
			@ExternalCompression,
			@Fistula,
			@FistulaQty,
			@Visceral,
			@Cutaneous,
			@FistulaComments,
			@Stones,
			@StonesMultiple,
			@StonesQty,
			@StonesSize,
			@Cysts,
			@CystsMultiple,
			@CystsQty,
			@CystsDiameter,
			@CystsSimple,
			@CystsRegular,
			@CystsIrregular,
			@CystsLoculated,
			@CystsCommunicating,
			@CystsCholedochal,
			@CystsSuspectedType,
			@DuctInjury,
			@StentOcclusion,
			@GallBladderTumor,
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
			CASE WHEN @region = 'Gall Bladder' THEN 'Gall Bladder'
							 ELSE 'Duct'
						END,
			1)
	END

	ELSE
	BEGIN
		UPDATE 
			ERS_ERCPAbnoDuct
		SET 
			Normal = @Normal,
			Dilated = @Dilated,
			DilatedLength = @DilatedLength,
			DilatedType = @DilatedType,
			Stricture = @Stricture,
			StrictureLen = @StrictureLen,
			UpstreamDilatation = @UpstreamDilatation,
			CompleteBlock = @CompleteBlock,
			Smooth = @Smooth,
			Irregular = @Irregular,
			Shouldered = @Shouldered,
			Tortuous = @Tortuous,
			StrictureType = @StrictureType,
			StrictureProbably = @StrictureProbably,
			Cholangiocarcinoma = @Cholangiocarcinoma,
			ExternalCompression = @ExternalCompression,
			Fistula = @Fistula,
			FistulaQty = @FistulaQty,
			Visceral = @Visceral,
			Cutaneous = @Cutaneous,
			FistulaComments = @FistulaComments,
			Stones = @Stones,
			StonesMultiple = @StonesMultiple,
			StonesQty = @StonesQty,
			StonesSize = @StonesSize,
			Cysts = @Cysts,
			CystsMultiple = @CystsMultiple,
			CystsQty = @CystsQty,
			CystsDiameter = @CystsDiameter,
			CystsSimple = @CystsSimple,
			CystsRegular = @CystsRegular,
			CystsIrregular = @CystsIrregular,
			CystsLoculated = @CystsLoculated,
			CystsCommunicating = @CystsCommunicating,
			CystsCholedochal = @CystsCholedochal,
			CystsSuspectedType = @CystsSuspectedType,
			DuctInjury = @DuctInjury,
			StentOcclusion = @StentOcclusion,
			GallBladderTumor = @GallBladderTumor,
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

--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'abnormalities_duct_select','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_duct_select]
(
	@SiteId INT	
)
AS

SET NOCOUNT ON

SELECT
	[SiteId]
    ,[Normal]
    ,[Dilated]
    ,[DilatedLength]
    ,[DilatedType]
    ,[Stricture]
    ,[StrictureLen]
    ,[UpstreamDilatation]
    ,[CompleteBlock]
    ,[Smooth]
    ,[Irregular]
    ,[Shouldered]
    ,[Tortuous]
    ,[StrictureType]
	,[StrictureProbably]
    ,[Cholangiocarcinoma]
    ,[ExternalCompression]
    ,[Fistula]
    ,[FistulaQty]
    ,[Visceral]
    ,[Cutaneous]
    ,[FistulaComments]
    ,[Stones]
    ,[StonesMultiple]
    ,[StonesQty]
    ,[StonesSize]
    ,[Cysts]
    ,[CystsMultiple]
    ,[CystsQty]
    ,[CystsDiameter]
    ,[CystsSimple]
    ,[CystsRegular]
    ,[CystsIrregular]
    ,[CystsLoculated]
    ,[CystsCommunicating]
	,[CystsCholedochal]
    ,[CystsSuspectedType]
    ,[EUSProcType]
	,[DuctInjury]
	,[StentOcclusion]
	,[GallBladderTumor]
    ,[Summary]
FROM
	ERS_ERCPAbnoDuct
WHERE 
	SiteId = @SiteId

GO
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code='D193P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeID, Section, Disabled, OrderByNumber, Code, Visible)
	VALUES ('Bile duct injury',NULL,2,'Biliary',0,193, 'D193P2',0)
GO
--------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_ERCPAbnoDuct_Insert','TR';
GO
EXEC DropIfExist 'TR_ERCPAbnoDuct_Delete','TR';
GO

EXEC DropIfExist 'TR_ERCPAbnoDuct','TR';
GO

CREATE TRIGGER [dbo].[TR_ERCPAbnoDuct]
ON [dbo].[ERS_ERCPAbnoDuct]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, 
			@Dilated VARCHAR(10) = 'False', 
			@DilatedType VARCHAR(10) = 'False', @Stricture VARCHAR(10) = 'False', 
			@Fistula VARCHAR(10) = 'False', @Stones VARCHAR(10) = 'False',
			@Cysts VARCHAR(10) = 'False', 
			@CystsCommunicating VARCHAR(10) = 'False', @CystsNonCommunicating VARCHAR(10) = 'False',
			@CystsCholedochal VARCHAR(10) = 'False',
			@TumourCystadenoma VARCHAR(10) = 'False', @TumourProbablyMalignant VARCHAR(10) = 'False',
			@Cholangiocarcinoma VARCHAR(10) = 'False', @ExternalCompression VARCHAR(10) = 'False',
			@Polycystic VARCHAR(10) = 'False', @HydatidCyst VARCHAR(10) = 'False',
			@LiverAbscess VARCHAR(10) = 'False', @PostCholecystectomy VARCHAR(10) = 'False',
			@StrictureProbablyBenign VARCHAR(10) = 'False', @StrictureProbably VARCHAR(10) = 'False',
			@DuctInjury VARCHAR(10) = 'False', @StentOcclusion VARCHAR(10) = 'False',
			@Action CHAR(1) = 'I', @Area varchar(50), @Region varchar(50)

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Dilated = (CASE WHEN Dilated = 1 THEN 'True' ELSE 'False' END),
				@DilatedType = (CASE WHEN DilatedType = 1 THEN 'True' ELSE 'False' END),   --DilatedType -> No obvious cause
				@PostCholecystectomy = (CASE WHEN DilatedType = 2 THEN 'True' ELSE 'False' END),   --DilatedType -> Post cholecystectomy
				@Stricture = (CASE WHEN Stricture = 1 THEN 'True' ELSE 'False' END),
				@Fistula = (CASE WHEN Fistula = 1 THEN 'True' ELSE 'False' END),
				@Stones = (CASE WHEN Stones = 1 THEN 'True' ELSE 'False' END),
				@Cysts = (CASE WHEN Cysts = 1 THEN 'True' ELSE 'False' END),
				@CystsCommunicating = (CASE WHEN Cysts = 1 AND CystsCommunicating = 1 THEN 'True' ELSE 'False' END),
				@CystsNonCommunicating = (CASE WHEN Cysts = 1 AND CystsCommunicating = 0 THEN 'True' ELSE 'False' END),
				@CystsCholedochal = (CASE WHEN Cysts = 1 AND CystsCholedochal = 1 THEN 'True' ELSE 'False' END),
				@TumourCystadenoma = (CASE WHEN CystsSimple = 1 OR CystsRegular = 1 OR CystsIrregular = 1 OR CystsLoculated = 1 THEN 'True' ELSE 'False' END), --'Diagnosis cystadenoma 
				@TumourProbablyMalignant = (CASE WHEN Stricture = 1 AND StrictureType = 2 THEN 'True' ELSE 'False' END),
				@StrictureProbablyBenign = (CASE WHEN Stricture = 1 AND StrictureType = 1 THEN 'True' ELSE 'False' END),
				@StrictureProbably = (CASE WHEN Stricture = 1 AND StrictureProbably = 1 THEN 'True' ELSE 'False' END),
				@Cholangiocarcinoma = (CASE WHEN Cholangiocarcinoma = 1 THEN 'True' ELSE 'False' END),
				@ExternalCompression = (CASE WHEN ExternalCompression = 1 THEN 'True' ELSE 'False' END),
				@Polycystic = (CASE WHEN ISNULL(CystsSuspectedType,0) = 1 THEN 'True' ELSE 'False' END),
				@HydatidCyst = (CASE WHEN ISNULL(CystsSuspectedType,0) = 2 THEN 'True' ELSE 'False' END),
				@LiverAbscess = (CASE WHEN ISNULL(CystsSuspectedType,0) = 3 THEN 'True' ELSE 'False' END),
				@DuctInjury = (CASE WHEN DuctInjury = 1 THEN 'True' ELSE 'False' END),
				@StentOcclusion = (CASE WHEN StentOcclusion = 1 THEN 'True' ELSE 'False' END)

		FROM INSERTED

		EXEC abnormalities_duct_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	select @Area = x.area, @Region = x.Region from ERS_AbnormalitiesMatrixERCP x inner join ERS_Regions r on x.region = r.Region inner join ers_sites s on r.RegionId = s.RegionId where SiteId =@site_id

	    --Dim Hepatic() As String        = {"Left Hepatic Ducts", "Right Hepatic Ducts", "Left intra-hepatic ducts", "Right intra-hepatic ducts", "Right Hepatic Lobe", "Left Hepatic Lobe"}
        --Dim GallBladderReg() As String = {"Gall Bladder", "Common Bile Duct", "Common Hepatic Duct", "Cystic Duct", "Bifurcation"}

	IF (LOWER(@Area) = 'pancreas') --'Pancreas Regions
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D70P2',	@Fistula			-- 'Fistula'

		IF @Dilated = 'True' AND @DilatedType = 'False' -- If "Dilated" is checked, diagnoses are "Chronic" and 'Dilatation'
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D85P2', @Dilated				-- 'Chronic'   
			EXEC diagnoses_control_save @site_id, 'D110P2', @Dilated			-- 'Dilatation'   
			EXEC diagnoses_control_save @site_id, 'D115P2', 'False'				-- 'No obvious cause' 
		END
		ELSE IF @Dilated = 'True' AND @DilatedType = 'True'
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D85P2', 'False'				-- 'Chronic'   
			EXEC diagnoses_control_save @site_id, 'D110P2', @Dilated			-- 'Dilatation'   
			EXEC diagnoses_control_save @site_id, 'D115P2', @DilatedType		-- 'No obvious cause' 
		END
		ELSE
		BEGIN --both @Dilated and @DilatedType false
			EXEC diagnoses_control_save @site_id, 'D85P2', 'False'				-- 'Chronic'   
			EXEC diagnoses_control_save @site_id, 'D110P2', 'False'				-- 'Dilatation'   
			EXEC diagnoses_control_save @site_id, 'D115P2', 'False'				-- 'No obvious cause' 
		END
			
		EXEC diagnoses_control_save @site_id, 'D120P2', @Stricture				-- 'Stricture'
		
		EXEC diagnoses_control_save @site_id, 'D95P2', @CystsCommunicating		-- Communicating
		EXEC diagnoses_control_save @site_id, 'D100P2', @CystsNonCommunicating	-- NonCommunicating
		EXEC diagnoses_control_save @site_id, 'D105P2', @CystsCholedochal		-- Pseudocyst
		EXEC diagnoses_control_save @site_id, 'D72P2',	@Stones					-- 'Pancreatic stone'
		EXEC diagnoses_control_save @site_id, 'D130P2',	@TumourCystadenoma		-- 'Cystadenoma'
		EXEC diagnoses_control_save @site_id, 'D125P2',	@TumourProbablyMalignant-- 'Probably malignant'
		EXEC diagnoses_control_save @site_id, 'D69P2',	@DuctInjury				-- 'Duct injury'
		EXEC diagnoses_control_save @site_id, 'D74P2',	@StentOcclusion			-- 'Stent occlusion'

	END
------ DIAGNOSES FOR INTRAHEPATIC SITES i.e above the bifurcation --------------------------------------------------
	ELSE IF LOWER(@Region) IN ('right intra-hepatic ducts', 'right hepatic ducts', 'left intra-hepatic ducts', 'left hepatic ducts', 'right hepatic lobe', 'left hepatic lobe')
	BEGIN
		--Diagnosis probable tumour of type cholangiocarcinoma if patient has stricture that is probably malignant and is probably cholangiocarcinoma
		--Diagnosis probable tumour of type external compression (metastases) if patient has stricture that is probably malignant and is exibiting external compression (metastases)
		IF @Cholangiocarcinoma = 'True' OR @ExternalCompression = 'True'
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D225P2', 'True'				-- 'Tumour'
			EXEC diagnoses_control_save @site_id, 'D242P2', 'True'				-- 'Probable'
			EXEC diagnoses_control_save @site_id, 'D245P2', @Cholangiocarcinoma	--Cholangiocarcinoma
			EXEC diagnoses_control_save @site_id, 'D255P2', @ExternalCompression--External compression
		END
		ELSE
		BEGIN --Both Cholangiocarcinoma & External compression not set
			EXEC diagnoses_control_save @site_id, 'D225P2', 'False'				-- 'Tumour'
			EXEC diagnoses_control_save @site_id, 'D242P2', 'False'				-- 'Probable'
			EXEC diagnoses_control_save @site_id, 'D245P2', 'False'				--Cholangiocarcinoma
			EXEC diagnoses_control_save @site_id, 'D255P2', 'False'				--External compression
		END

		EXEC diagnoses_control_save @site_id, 'D193P2', @DuctInjury					-- 'Duct injury'
		EXEC diagnoses_control_save @site_id, 'D195P2', @StentOcclusion				-- 'Stent occlusion'

		EXEC diagnoses_control_save @site_id, 'D145P2',	@Fistula				-- 'Fistula'

		--Diagnosis polycystic liver disease if patient has suspected polycystic liver disease set in duct abnos...
		EXEC diagnoses_control_save @site_id, 'D200P2', @Polycystic				--Polycystic liver disease

		EXEC diagnoses_control_save @site_id, 'D235P2', @HydatidCyst			--Hydatid Cyst
		EXEC diagnoses_control_save @site_id, 'D240P2', @LiverAbscess			--Liver abscess
	END
------ DIAGNOSES FOR EXTRAHEPATIC SITES i.e below the bifurcation --------------------------------------------------
	ELSE IF LOWER(@Region) IN ('gall bladder', 'common bile duct', 'common hepatic duct', 'cystic duct', 'bifurcation') --'GallBladder and the regions close to it
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D275P2', @Dilated				-- 'Dilated duct'
		EXEC diagnoses_control_save @site_id, 'D270P2', @CystsCholedochal		-- 'Choledochal cyst'
		EXEC diagnoses_control_save @site_id, 'D300P2', @PostCholecystectomy	-- 'Post cholecystectomy'
		EXEC diagnoses_control_save @site_id, 'D290P2', @Stricture				-- 'Stricture'
		
		EXEC diagnoses_control_save @site_id, 'D330P2', @StrictureProbablyBenign	-- 'Benign'
		EXEC diagnoses_control_save @site_id, 'D335P2', @TumourProbablyMalignant	-- 'Malignant'
		EXEC diagnoses_control_save @site_id, 'D325P2', @StrictureProbably			-- 'Extrahepatic probable'
		EXEC diagnoses_control_save @site_id, 'D193P2', @DuctInjury					-- 'Duct injury'
		EXEC diagnoses_control_save @site_id, 'D195P2', @StentOcclusion				-- 'Stent occlusion'

		EXEC diagnoses_control_save @site_id, 'D145P2',	@Fistula				-- 'Fistula'
	END

	--Biliary : stone abnormalities
	IF LOWER(@Region) IN ('gall bladder') --Stones in Gall Bladder
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D189P2', @Stones		-- Diagnosis : Stones in Gall Bladder
	END 
	ELSE IF LOWER(@Region) IN ('common bile duct', 'cystic duct')	-- Stones in cystic duct and/or common bile duct
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D191P2', @Stones		-- Diagnosis : Stones in the bile duct		
	END
	ELSE IF LOWER(@Region) IN ('common hepatic duct', 'bifurcation', 'right intra-hepatic ducts', 'right hepatic ducts', 
								'left intra-hepatic ducts', 'left hepatic ducts') --'Stones in the common hepatic duct and/or bifurcation and/or left hepatic duct and/or left intra hepatic duct and/or right hepatic duct and/or right intra hepatic duct
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D192P2', @Stones		-- Diagnosis : Stones in the hepatic duct	
	END
GO

--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'abnormalities_duct_summary_update','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_duct_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000),
		@tempsummary VARCHAR(1000),
		@tempsummary2 VARCHAR(1000),
		@Normal BIT,
		@Dilated BIT,
		@DilatedLength INT,
		@DilatedType TINYINT,
		@Stricture BIT,
		@StrictureLen DECIMAL(6,1),
		@UpstreamDilatation BIT,
		@CompleteBlock BIT,
		@Smooth BIT,
		@Irregular BIT,
		@Shouldered BIT,
		@Tortuous BIT,
		@StrictureType TINYINT,
		@StrictureProbably BIT,
		@Cholangiocarcinoma BIT,
		@ExternalCompression BIT,
		@Fistula BIT,
		@FistulaQty INT,
		@Visceral BIT,
		@Cutaneous BIT,
		@FistulaComments NVARCHAR(500),
		@Stones BIT,
		@StonesMultiple BIT,
		@StonesQty INT,
		@StonesSize DECIMAL(6,1),
		@Cysts BIT,
		@CystsMultiple BIT,
		@CystsQty INT,
		@CystsDiameter DECIMAL(6,1),
		@CystsSimple BIT,
		@CystsRegular BIT,
		@CystsIrregular BIT,
		@CystsLoculated BIT,
		@CystsCommunicating BIT,
		@CystsCholedochal BIT,
		@CystsSuspectedType TINYINT,
		@DuctInjury BIT,
		@StentOcclusion BIT

	SELECT 
		@Normal=Normal,
		@Dilated=Dilated,
		@DilatedLength=DilatedLength,
		@DilatedType = DilatedType,
		@Stricture=Stricture,
		@StrictureLen=StrictureLen,
		@UpstreamDilatation=UpstreamDilatation,
		@CompleteBlock=CompleteBlock,
		@Smooth=Smooth,
		@Irregular=Irregular,
		@Shouldered=Shouldered,
		@Tortuous=Tortuous,
		@StrictureType=StrictureType,
		@StrictureProbably = StrictureProbably,
		@Cholangiocarcinoma=Cholangiocarcinoma,
		@ExternalCompression=ExternalCompression,
		@Fistula=Fistula,
		@FistulaQty=FistulaQty,
		@Visceral=Visceral,
		@Cutaneous=Cutaneous,
		@FistulaComments=FistulaComments,
		@Stones=Stones,
		@StonesMultiple=StonesMultiple,
		@StonesQty=StonesQty,
		@StonesSize=StonesSize,
		@Cysts=Cysts,
		@CystsMultiple=CystsMultiple,
		@CystsQty=CystsQty,
		@CystsDiameter=CystsDiameter,
		@CystsSimple=CystsSimple,
		@CystsRegular=CystsRegular,
		@CystsIrregular=CystsIrregular,
		@CystsLoculated=CystsLoculated,
		@CystsCommunicating=CystsCommunicating,
		@CystsCholedochal=CystsCholedochal,
		@CystsSuspectedType=CystsSuspectedType,
		@DuctInjury = DuctInjury,
		@StentOcclusion = StentOcclusion
	FROM
		ERS_ERCPAbnoDuct
	WHERE
		SiteId = @SiteId

	SET @Summary = ''

	IF @Normal = 1
		SET @summary = @summary + 'normal'
	
	ELSE 
	BEGIN
		IF @Dilated = 1
		BEGIN
			IF ISNULL(@DilatedLength,0) > 0
				SET @summary = @summary + 'dilated to ' + CONVERT(VARCHAR(5), @DilatedLength) + 'mm'
			ELSE
				SET @summary = @summary + 'dilated ducts'

			IF @DilatedType = 1
				SELECT @summary = @summary + ' with no obvious cause'
			ELSE IF @DilatedType = 2
				SELECT @summary = @summary + ' due to post cholecystectomy'
		END

		IF @Stricture = 1 
		BEGIN
			SET @tempsummary = ''
			
			IF @StrictureType = 1
				SET @tempsummary = 'benign'
			ELSE IF @StrictureType = 2
			BEGIN
				IF @Cholangiocarcinoma = 1
					SET @tempsummary = 'cholangiocarcinoma'
				IF @ExternalCompression = 1
					IF @tempsummary = '' SET @tempsummary = 'external compression (metastases)'
					ELSE SET @tempsummary = @tempsummary + ' and external compression (metastases)'
				IF @Cholangiocarcinoma = 0 AND @ExternalCompression = 0
					SET @tempsummary = 'malignant'
			END
			IF @StrictureProbably = 1
				SET @tempsummary = 'probably ' + @tempsummary

			IF ISNULL(@StrictureLen, 0) > 0
				IF @tempsummary = '' SET @tempsummary = 'length ' + dbo.fnRemoveDecTrailingZeroes(@StrictureLen) + 'cm'
				ELSE SET @tempsummary = @tempsummary + ' length ' + dbo.fnRemoveDecTrailingZeroes(@StrictureLen) + 'cm'
			IF @Smooth = 1
				IF @tempsummary = '' SET @tempsummary = 'smooth'
				ELSE SET @tempsummary = @tempsummary + '$$ smooth'
			IF @Irregular = 1
				IF @tempsummary = '' SET @tempsummary = 'irregular'
				ELSE SET @tempsummary = @tempsummary + '$$ irregular'
			IF @Shouldered = 1
				IF @tempsummary = '' SET @tempsummary = 'shouldered'
				ELSE SET @tempsummary = @tempsummary + '$$ shouldered'
			IF @Tortuous = 1
				IF @tempsummary = '' SET @tempsummary = 'tortuous'
				ELSE SET @tempsummary = @tempsummary + '$$ tortuous'
			IF @CompleteBlock = 1
				IF @tempsummary = '' SET @tempsummary = 'complete block'
				ELSE SET @tempsummary = @tempsummary + '$$ complete block'
			IF @UpstreamDilatation = 1
				IF @tempsummary = '' SET @tempsummary = 'with upstream dilatation'
				ELSE SET @tempsummary = @tempsummary + '$$ with upstream dilatation'

			IF CHARINDEX('$$', @tempsummary) > 0 SET @tempsummary = STUFF(@tempsummary, len(@tempsummary) - charindex('$$', reverse(@tempsummary)), 2, ' and')
			SET @tempsummary = REPLACE(@tempsummary, '$$', ',')

			IF @tempsummary = '' SET @tempsummary = 'Stricture'
			ELSE SET @tempsummary = 'Stricture: ' + @tempsummary

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @Fistula = 1
		BEGIN
			SET @tempsummary = ''
			IF @Visceral = 1
				IF @tempsummary = '' SET @tempsummary = 'visceral'
				ELSE SET @tempsummary = @tempsummary + '$$ visceral'
			IF @Cutaneous = 1
				IF @tempsummary = '' SET @tempsummary = 'cutaneous'
				ELSE SET @tempsummary = @tempsummary + '$$ cutaneous'
			IF @FistulaComments <> ''
				IF @tempsummary = '' SET @tempsummary = @FistulaComments
				ELSE SET @tempsummary = @tempsummary + '$$ ' + @FistulaComments

			IF CHARINDEX('$$', @tempsummary) > 0 SET @tempsummary = STUFF(@tempsummary, len(@tempsummary) - charindex('$$', reverse(@tempsummary)), 2, ' and')
			SET @tempsummary = REPLACE(@tempsummary, '$$', ',')
			
			IF @FistulaQty > 0
				SET @tempsummary = CONVERT(VARCHAR, @FistulaQty) + ' ' + @tempsummary

			IF @tempsummary = '' SET @tempsummary = 'Fistula'
			ELSE SET @tempsummary = 'Fistula: ' + @tempsummary

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END
		
		IF @Stones = 1
		BEGIN
			SET @tempsummary = ''
			IF @StonesQty = 1
			BEGIN
				SET @tempsummary = 'One $$stone'
				IF @StonesSize > 0
					SET @tempsummary = REPLACE(@tempsummary, '$$', CONVERT(VARCHAR, @StonesSize) + 'cm ')
				ELSE
					SET @tempsummary = REPLACE(@tempsummary, '$$', '')
			END

			ELSE
			BEGIN
				IF @StonesMultiple = 1
				SET @tempsummary = 'Multiple stones'
			ELSE IF @StonesQty > 1
				SET @tempsummary = CONVERT(VARCHAR, @StonesQty) + ' stones'
			ELSE 
				SET @tempsummary = 'Stones'
			
			IF @StonesSize > 0
				SET @tempsummary = @tempsummary + ' (largest ' + dbo.fnRemoveDecTrailingZeroes(@StonesSize) + 'cm)'
			END
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @Cysts = 1
		BEGIN
			SET @tempsummary = ''
			IF @CystsMultiple = 1
				SET @tempsummary = @tempsummary + ' multiple'
			ELSE IF @CystsQty > 0
				IF @CystsQty = 1
					SET @tempsummary = @tempsummary + ' one'
				ELSE
					SET @tempsummary = @tempsummary + ' ' + CONVERT(VARCHAR, @CystsQty)
			
			SET @tempsummary2 = ''
			IF @CystsSimple = 1
				SET @tempsummary2 = 'simple'
			IF @CystsRegular = 1
				IF @tempsummary2 = '' SET @tempsummary2 = 'regular'
				ELSE SET @tempsummary2 = @tempsummary2 + '$$ regular'
			IF @CystsIrregular = 1
				IF @tempsummary2 = '' SET @tempsummary2 = 'irregular'
				ELSE SET @tempsummary2 = @tempsummary2 + '$$ irregular'
			IF @CystsLoculated = 1
				IF @tempsummary2 = '' SET @tempsummary2 = 'loculated'
				ELSE SET @tempsummary2 = @tempsummary2 + '$$ loculated'
			IF CHARINDEX('$$', @tempsummary2) > 0 SET @tempsummary2 = STUFF(@tempsummary2, len(@tempsummary2) - charindex('$$', reverse(@tempsummary2)), 2, ' and')
			SET @tempsummary2 = REPLACE(@tempsummary2, '$$', ',')
			
			IF @tempsummary2 <> ''
				SET @tempsummary = @tempsummary + ' ' + @tempsummary2
				
			IF @CystsDiameter > 0
				IF @CystsQty = 1
					SET @tempsummary = @tempsummary + ' ' + dbo.fnRemoveDecTrailingZeroes(@CystsDiameter) + 'cm'
				ELSE
					SET @tempsummary = @tempsummary + ' (largest ' + dbo.fnRemoveDecTrailingZeroes(@CystsDiameter) + 'cm)'
			
			IF @CystsSuspectedType = 1 SET @tempsummary = @tempsummary + ' with suspected polycystic disease'
			ELSE IF @CystsSuspectedType = 2 SET @tempsummary = @tempsummary + ' with suspected hydatid cyst'
			ELSE IF @CystsSuspectedType = 3 SET @tempsummary = @tempsummary + ' with suspected liver abscess'

			IF @CystsCommunicating = 1
				SET @tempsummary = @tempsummary + ' and communicating with biliary duct'

			IF @CystsCholedochal = 1
				SET @tempsummary = @tempsummary + ' choledochal'
				
			IF @tempsummary = '' SET @tempsummary = 'Cysts'
			ELSE SET @tempsummary = 'Cysts:' + @tempsummary

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @DuctInjury = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' duct injury'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @StentOcclusion = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' stent occlusion'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END
	END

	--PRINT @summary

	-- Finally update the summary in abnormalities table
	UPDATE ERS_ERCPAbnoDuct
	SET Summary = @Summary 
	WHERE SiteId = @siteId

GO

--------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'ercp_diagnoses_summary_update','S';
GO

CREATE PROCEDURE [dbo].[ercp_diagnoses_summary_update]
(
@ProcedureID int
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	SELECT ProcedureID, SiteID, MatrixCode, Region, CONVERT(VARCHAR(100),'') AS DisplayName,
			CASE WHEN LOWER(Value) IN ('true','1') THEN '1' ELSE Value END AS VALUE
	INTO #tbl_ERS_Diagnoses FROM dbo.[ERS_Diagnoses]
	WHERE ProcedureId=@ProcedureId --AND RIGHT(MatrixCode,2) = 'P2'

	DELETE #tbl_ERS_Diagnoses WHERE LOWER(Value) IN ('false','0','') AND MatrixCode<>'Summary'

	--Get the display name for the corresponding matrix code
	UPDATE D
	SET D.DisplayName = M.DisplayName
	FROM #tbl_ERS_Diagnoses AS D
	INNER JOIN ERS_DiagnosesMatrix AS M ON M.ProcedureTypeID = 2 AND M.Code = D.MatrixCode 
	WHERE RIGHT(D.MatrixCode,2) = 'P2'

	DECLARE @tmpRegionDiv TABLE(Val VARCHAR(MAX), Region VARCHAR(MAX))
    DECLARE @tmpDiv TABLE(Val VARCHAR(MAX))
	DECLARE @A varchar(MAX)=''


-----Normal procedure marking---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

	
	--/*Papillae REGION*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Papillae' AND Value = '1' AND DisplayName <>'Normal')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D33P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D33P2' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D32P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D32P2'
	END
	ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Papillae')
		INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'D33P2', 'True', 'Papillae', 1)
	
	--/*Pancreas REGION*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Pancreas' AND Value = '1' AND DisplayName <>'Normal')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D67P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D67P2' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D32P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D32P2'
	END
	ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Pancreas')
		INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'D67P2', 'True', 'Pancreas', 1)
	
	/*Not entered*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Pancreas' AND Value = '1' AND MatrixCode <>'D66P2')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D66P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D66P2' AND Value = 'True'
	END

	/*Biliary REGION*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Biliary' AND Value = '1' AND DisplayName <>'Normal')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D138P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D138P2' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D32P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D32P2'
	END
	ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Biliary')
		INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'D138P2', 'True', 'Biliary', 1)
	
	--/*Duodenum REGION*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND Value = '1' AND DisplayName <>'Normal')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D51P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D51P2' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D32P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D32P2'
	END
	ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Duodenum')
		INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'D67P2', 'True', 'Duodenum', 1)
	
	/*Not entered*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND Value = '1' AND MatrixCode NOT IN ('D51P2','D52P2'))
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D50P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D50P2' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D52P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D52P2' AND Value = 'True'
	END


------ PAPILLAE ------------------------------------------------------------------------
        
	INSERT INTO @tmpDiv (Val)
    SELECT LOWER(DisplayName) FROM #tbl_ERS_Diagnoses WHERE Region = 'Papillae'

	UPDATE @tmpDiv SET Val = Val + ' tumour' WHERE Val IN ('probably benign', 'probably malignant')
	IF @@ROWCOUNT > 0 DELETE FROM @tmpDiv WHERE Val = 'tumour'

    IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
    BEGIN
		DECLARE @XMLlist XML
        SET @XMLlist = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
        SET @A = dbo.fnBuildString(@XMLlist)
    END 

    IF @A <> '' SET @A = '<b>Ampulla: </b>' + @A + '.' + '</br>'
            
------ PANCREAS ------------------------------------------------------------------------

	DELETE FROM @tmpRegionDiv                      
    DELETE FROM @tmpDiv
	
	INSERT INTO @tmpRegionDiv (Val, Region)
	SELECT DISTINCT 
		CASE WHEN LOWER(DisplayName) = 'fistula' THEN 'pancreatic fistula'
		ELSE LOWER(DisplayName) END, Region
	FROM #tbl_ERS_Diagnoses WHERE Region IN ('Pancreas', 'Pancreatitis', 'Cyst', 'Ducts', 'Tumour')

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'normal')				INSERT INTO @tmpDiv (Val) VALUES('normal') 
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'not entered')			INSERT INTO @tmpDiv (Val) VALUES('not entered') 
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'pancreatic stone')		INSERT INTO @tmpDiv (Val) VALUES('pancreatic stone') 
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'pancreatic fistula')	INSERT INTO @tmpDiv (Val) VALUES('pancreatic fistula') 
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'annulare')				INSERT INTO @tmpDiv (Val) VALUES('annulare')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'duct injury')			INSERT INTO @tmpDiv (Val) VALUES('duct injury')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'stent occlusion')		INSERT INTO @tmpDiv (Val) VALUES('stent occlusion')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'ipmt')					INSERT INTO @tmpDiv (Val) VALUES('IPMT')

    DECLARE @B varchar(MAX)=''
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'acute') SET @B='acute '	

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'chronic') 
    BEGIN
		IF @B<>'' SET @B = @B +'and chronic ' ELSE SET @B= @B +'chronic '
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'minimal change') SET @B= @B +'(minimal change) '
    END

	IF @B <> '' INSERT INTO @tmpDiv (Val) VALUES(@B + 'pancreatitis')

    SET @B =''
    DECLARE @C varchar(MAX)=''

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('communicating', 'noncommunicating', 'pseudocyst'))
	BEGIN
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('pseudocyst'))  SET @B= 'pseudocyst ' ELSE SET @B='cyst '
	END

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('communicating')) SET @C='communicating '

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('noncommunicating'))
	BEGIN
		IF @C= ''  SET @C ='noncommunicating '
		ELSE SET @C= @C + 'and noncommunicating '
	END

    IF @C <>'' SET @C = @C + 'with the pancreatic duct'
    SET @B = @B + @C

	IF @B <> '' INSERT INTO @tmpDiv (Val) VALUES(@B)

                                  
    SET @B='' 
    SET @C= ''

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('stricture')) SET @B='stricture '

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('dilatation')) 
    BEGIN
		IF @B='' SET @B= 'dilatation ' ELSE SET @B='and dilatation '
    END

    IF @B<> ''
    BEGIN
		SET @B= 'ductal '+@B
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('no obvious cause'))  SET @B = @B + 'with no obvious cause'
    END
		
    IF @B <> '' INSERT INTO @tmpDiv (Val) VALUES(@B)
                                  
    SET @B=''
    SET @C= ''

    DECLARE @A1 varchar(50)='' , @A2 varchar(50) ='', @A3 varchar(50) ='', @Other VARCHAR(3000) = ''

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('probably malignant')) SET @A1 = 'probably malignant tumour'
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('cystadenoma'))		SET @A2 = 'cystadenoma'

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('other'))		
	BEGIN
		SET @Other = ISNULL((SELECT LTRIM(RTRIM(Value)) FROM #tbl_ERS_Diagnoses WHERE MatrixCode IN ('TumourOtherText') AND LTRIM(RTRIM(Value)) <> ''),'')
		IF @Other <> '' SET @A3 = @Other
	END

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('other'))	AND @A3<>''
	BEGIN
		IF @A1 = '' AND @A2 = '' SET @B= 'tumour ('+ @A3+ ') '
		ELSE
		BEGIN
            IF @A1 <> '' AND @A2 = '' SET @B = @A1 + ' (' +@A3+ ') '
			ELSE
            BEGIN
				DECLARE @XMLlist1 XML                                               
				SELECT * INTO #T FROM (select Val=@A1 union select Val=@A2 union select Val=@A3) AS TA
				SET @XMLlist1 = (SELECT Val FROM #T FOR XML  RAW, ELEMENTS, TYPE)
				SET @B = dbo.fnBuildString(@XMLlist1)                                             
				DROP TABLE #T
            END
		END
	END
	ELSE
    BEGIN
		IF @A1 <> '' AND @A2 = '' SET @B=@A1
		IF @A1 =  '' AND @A2 <> '' SET @B= @A2
		IF @A1 <> '' AND @A2 <> '' SET @B = @A1 + ' and ' + @A2
	END


	IF @B <> '' INSERT INTO @tmpDiv (Val) VALUES(@B)

	SET @Other = ISNULL((SELECT TOP 1 LTRIM(RTRIM(Value)) FROM #tbl_ERS_Diagnoses WHERE MatrixCode IN ('PancreaticOther') AND LTRIM(RTRIM(Value)) <> ''),'')

    IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
    BEGIN
		DECLARE @XMLlist2 XML
		SET @XMLlist2 = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
		SET @B = dbo.fnBuildString(@XMLlist2)
		DELETE FROM @tmpDiv                                     
                                           
		--SET @B =dbo.fnFirstLetterUpper(@B)
		SET @A = @A + '<b>Pancreas: </b>' + @B +'.'
		SET @B = @Other
		IF @B <>  '' SET @A = @A + ' ' + dbo.fnFirstLetterUpper(@B) + '.'
		SET @A = @A + '<br/>'
    END  
    ELSE
    BEGIN
		SET @B = @Other
        IF @B <> '' SET @A = @A + '<b>Pancreas: </b>' + @B + '. <br/>'
    END

------ BILIARY ------------------------------------------------------------------------

	DELETE FROM @tmpRegionDiv                      
    DELETE FROM @tmpDiv
	SET @B = ''
		
	INSERT INTO @tmpRegionDiv (Val, Region)
	SELECT DISTINCT LOWER(DisplayName) , Region
	FROM #tbl_ERS_Diagnoses WHERE Region IN ('Biliary', 'Intrahepatic', 'Extrahepatic')


	DECLARE @BilStr Varchar(1000) = ''

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('normal'))	
	BEGIN
		SET @BilStr= 'Normal'
		--IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('post cholecystectomy')) SET @BilStr = @BilStr + ' (post cholecystectomy)'
	END
	ELSE 
    BEGIN

		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('anastomic stricture'))		INSERT INTO @tmpDiv (Val) VALUES('anastomic stricture')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('cystic duct stones'))		INSERT INTO @tmpDiv (Val) VALUES('cystic duct stones')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('haemobilia'))		INSERT INTO @tmpDiv (Val) VALUES('haemobilia')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('cholelithiasis'))		INSERT INTO @tmpDiv (Val) VALUES('cholelithiasis')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('fistula/leak'))		INSERT INTO @tmpDiv (Val) VALUES('fistula')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('mirizzi syndrome'))		INSERT INTO @tmpDiv (Val) VALUES('Mirizzi syndrome')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE LEFT(Val,21) IN ('calculous obstruction'))		INSERT INTO @tmpDiv (Val) VALUES('calculous obstruction of cystic duct')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('gall bladder stones'))		INSERT INTO @tmpDiv (Val) VALUES('gall bladder stone(s)')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('occlusion'))		INSERT INTO @tmpDiv (Val) VALUES('occlusion')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE LEFT(Val,11) IN ('common duct'))		INSERT INTO @tmpDiv (Val) VALUES('common duct stone(s)')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('gall bladder tumour'))		INSERT INTO @tmpDiv (Val) VALUES('gall bladder tumour')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('stent occlusion'))		INSERT INTO @tmpDiv (Val) VALUES('stent occlusion')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('duct injury'))		INSERT INTO @tmpDiv (Val) VALUES('duct injury')

		--Check for stones in either gall bladder, bile duct or hepatic duct - and strung them up
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE LEFT(Val,9) IN ('stones in'))
		BEGIN
			DECLARE @XMLStones XML
			SET @XMLStones = (SELECT REPLACE(Val,'stones in ','') AS Val FROM @tmpRegionDiv
								WHERE LEFT(Val,9) IN ('stones in')
							 FOR XML  RAW, ELEMENTS, TYPE)
			SET @B = dbo.fnBuildString(@XMLStones)	
			INSERT INTO @tmpDiv (Val) VALUES('stones (in ' + @B + ')')
			SET @B = ''
		END	
	END

	IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
    BEGIN
		DECLARE @XMLlist3 XML
        SET @XMLlist3 = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
        SET @B = dbo.fnBuildString(@XMLlist3)
    END 
    DELETE FROM @tmpDiv
	IF LTRIM(RTRIM(@B)) <> '' SET @BilStr= dbo.fnFirstLetterUpper(@B) + '. ' 
		   
------- Intrahepatic -------------------------------------------------------			

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('normal ducts') AND Region = 'Intrahepatic') 
		INSERT INTO @tmpDiv (Val) VALUES(@BilStr +'Normal intrahepatic ducts. ')     
	ELSE
    BEGIN
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('cirrhosis')) INSERT INTO @tmpDiv (Val) VALUES('cirrhosis')      
        IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('hydatid cyst')) INSERT INTO @tmpDiv (Val) VALUES('hydatid cyst')     
        IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('liver abscess')) INSERT INTO @tmpDiv (Val) VALUES('liver abscess')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('suppurative cholangitis')) INSERT INTO @tmpDiv (Val) VALUES('suppurative cholangitis')
		
        IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE LEFT(Val,12) IN ('biliary leak') AND Region = 'Intrahepatic') 
        BEGIN
			SET @Other = ISNULL((SELECT TOP 1 LTRIM(RTRIM(Value)) FROM #tbl_ERS_Diagnoses WHERE MatrixCode IN ('IntrahepaticLeakSiteType') AND LTRIM(RTRIM(Value)) <> ''),'')

			IF @Other<> '' INSERT INTO @tmpDiv (Val) VALUES('biliary leak' + ' (' +(select ISNULL(ListItemText,'') from ERS_Lists where ListDescription='Intrahepatic biliary leak site' AND  ListItemNo = ISNULL(@Other,0)) + ')')
			ELSE INSERT INTO @tmpDiv (Val) VALUES('intrahepatic biliary leak')
        END    
                     
        IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('polycystic liver disease'))	INSERT INTO @tmpDiv (Val) VALUES('polycystic liver disease')     
        IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('sclerosing cholangitis') AND Region = 'Intrahepatic')		INSERT INTO @tmpDiv (Val) VALUES('sclerosing cholangitis')
        IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('caroli''s disease'))			INSERT INTO @tmpDiv (Val) VALUES('Caroli''s disease')
        IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('tumour') AND Region = 'Intrahepatic') 
        BEGIN
            DECLARE @tTable TABLE (Val varchar(500))
			DECLARE @IntrahepaticTumourType VARCHAR(2) = ''
            SET @A2=''
            SET @B=''
			--SET @IntrahepaticTumourType = ISNULL((SELECT TOP 1  LTRIM(RTRIM(Value)) FROM #tbl_ERS_Diagnoses WHERE MatrixCode IN ('TumourType') AND Region = 'Intrahepatic' AND LTRIM(RTRIM(Value)) <> ''),'')
            --IF ISNULL(@IntrahepaticTumourType,'') = '1' SET @B='probable '
            --ELSE IF ISNULL(@IntrahepaticTumourType,'') = '2' SET @B='possible '

			IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('probable')) SET @B='probable '
			ELSE IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('possible')) SET @B='possible '

            IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('cholangiocarcinoma'))				INSERT INTO @tTable (Val) VALUES('cholangiocarcinoma')
            IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('metastatic intrahepatic'))		INSERT INTO @tTable (Val) VALUES('metastatic intrahepatic')
            IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('external compression (metastases)')) INSERT INTO @tTable (Val) VALUES('external compression (metastases)')
            IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('hepatocellular carcinoma'))		INSERT INTO @tTable (Val) VALUES('hepatocellular carcinoma')	
                           
            IF (SELECT COUNT(Val) FROM @tTable) > 0 
            BEGIN
				DECLARE @XMLlist4 XML
                SET @XMLlist4 = (SELECT Val FROM @tTable FOR XML  RAW, ELEMENTS, TYPE)
                SET @B = @B +  dbo.fnBuildString(@XMLlist4)
                DELETE FROM @tTable
            END 
            ELSE SET @B= @B + 'tumour'

            INSERT INTO @tmpDiv (Val) VALUES(@B)
            DELETE FROM @tTable
        END
        IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
        BEGIN
			DECLARE @XMLlist5 XML= (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE) 
			IF RIGHT(RTRIM(@BilStr),1) <> '.' AND LEN(LTRIM(RTRIM(@BilStr))) > 2 SET @BilStr = @BilStr + '. '                                        
			SET @BilStr = @BilStr + 'Intrahepatic: ' + dbo.fnBuildString(@XMLlist5)                                                     
        END 
        DELETE FROM @tmpDiv
    END     

------- Extrahepatic -------------------------------------------------------			      
    IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('normal ducts') AND Region = 'Extrahepatic') 
    BEGIN
		SET @BilStr = @BilStr + 'Extrahepatic ducts normal'
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('post cholecystectomy')) SET @BilStr = @BilStr + ' (post cholecystectomy). '
		ELSE SET @BilStr = @BilStr + '. '
    END           
    ELSE
    BEGIN
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('post cholecystectomy'))	INSERT INTO @tmpDiv (Val) VALUES('post cholecystectomy')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('choledochal cyst'))		INSERT INTO @tmpDiv (Val) VALUES('choledochal cyst')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('dilated duct'))			INSERT INTO @tmpDiv (Val) VALUES('dilated duct')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE LEFT(Val,12) IN ('biliary leak') AND Region = 'Extrahepatic') 
		BEGIN
			SET @Other = ISNULL((SELECT TOP 1 LTRIM(RTRIM(Value)) FROM #tbl_ERS_Diagnoses WHERE MatrixCode IN ('ExtrahepaticLeakSiteType') AND LTRIM(RTRIM(Value)) <> ''),'')

			IF @Other<> '' INSERT INTO @tmpDiv (Val) VALUES('biliary leak' + ' (' +(select ISNULL(ListItemText,'') from ERS_Lists where ListDescription='Extrahepatic biliary leak site' AND  ListItemNo = ISNULL(@Other,0)) + ')')
			ELSE INSERT INTO @tmpDiv (Val) VALUES('extrahepatic biliary leak')
		END
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('Stricture') AND Region = 'Extrahepatic') 
        BEGIN
			DECLARE @iTable TABLE (Val varchar(500))
			DECLARE @ExtrahepaticStrictureType VARCHAR(2) = ''
			DECLARE @ExtrahepaticProbable BIT = 0, @BenignProbable BIT = 0, @MalignantProbable BIT = 0
            SET @B=''

			SET @ExtrahepaticProbable = ISNULL((SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('extrahepatic probable')),0)
			SET @BenignProbable = ISNULL((SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('benign probable')),0)
			SET @MalignantProbable = ISNULL((SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('malignant probable')),0)

			--SET @ExtrahepaticStrictureType = ISNULL((SELECT TOP 1 CASE WHEN MatrixCode='D330P2' THEN 1 WHEN MatrixCode='D335P2' THEN 2 END
			--		FROM #tbl_ERS_Diagnoses WHERE MatrixCode IN ('D330P2','D335P2') AND Region = 'Extrahepatic' AND LTRIM(RTRIM(Value)) <> ''),'')

            IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('benign') AND Region = 'Extrahepatic') 
            BEGIN
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('pancreatitis')) INSERT INTO @iTable (Val) VALUES('pancreatitis')
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('a pseudocyst')) INSERT INTO @iTable (Val) VALUES('a pseudocyst')
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('previous surgery')) INSERT INTO @iTable (Val) VALUES('previous surgery')
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('sclerosing cholangitis') AND Region = 'Extrahepatic') INSERT INTO @iTable (Val) VALUES('sclerosing cholangitis')
				DECLARE @istr varchar(1000), @iCount int
				SET @iCount = (SELECT COUNT(Val) FROM @iTable)
				IF @iCount > 0 
				BEGIN
					DECLARE @XMLlist6 XML= (SELECT Val FROM @iTable FOR XML  RAW, ELEMENTS, TYPE)                                     
					SET @istr = dbo.fnBuildString(@XMLlist6)                                                 
				END 
				DELETE FROM @iTable
				IF ISNULL(@ExtrahepaticProbable,0) <> 1 AND ISNULL(@BenignProbable,0) <> 1
                BEGIN
					IF @iCount >1 SET @B = 'stricture due to ' + @istr
					ELSE SET @B = 'benign stricture'
                END
                ELSE IF ISNULL(@ExtrahepaticProbable,0) = 1 AND ISNULL(@BenignProbable,0) <> 1
                BEGIN
					SET @B= 'stricture: probably benign'
					IF @iCount > 1 SET @B = @B + ', ' + @istr
                END
                ELSE IF ISNULL(@ExtrahepaticProbable,0) <> 1 AND ISNULL(@BenignProbable,0) = 1
                BEGIN
					SET @B= 'benign stricture '
					IF @iCount > 1 SET @B = @B + ', probably ' + @istr
                END
                ELSE IF ISNULL(@ExtrahepaticProbable,0) = 1 AND ISNULL(@BenignProbable,0) = 1
                BEGIN
					SET @B= 'stricture: probably benign'
					IF @iCount > 1 SET @B = @B + ', probably ' + @istr
                END
            END
            ELSE IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('malignant') AND Region = 'Extrahepatic') 
            BEGIN
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('gallbladder carcinoma')) INSERT INTO @iTable (Val) VALUES('gallbladder carcinoma')
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('metastatic carcinoma')) INSERT INTO @iTable (Val) VALUES('metastatic carcinoma')
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('cholangiocarcinoma')) INSERT INTO @iTable (Val) VALUES('cholangiocarcinoma')
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('pancreatic carcinoma')) INSERT INTO @iTable (Val) VALUES('pancreatic carcinoma')
				DECLARE @oStr varchar(1000), @oCount int
				SET @oCount = (SELECT COUNT(Val) FROM @iTable)
				IF @oCount > 0 
                BEGIN
                    DECLARE @XMLlist7 XML= (SELECT Val FROM @iTable FOR XML  RAW, ELEMENTS, TYPE)                                     
                    SET @ostr = dbo.fnBuildString(@XMLlist7)                                                 
                END 
                DELETE FROM @iTable
                IF ISNULL(@ExtrahepaticProbable,0) <> 1 AND ISNULL(@MalignantProbable,0) <> 1
                BEGIN
					IF @oCount > 1 SET @B = 'stricture due to ' + @ostr
					ELSE SET @B ='malignant stricture'
                END
                ELSE IF ISNULL(@ExtrahepaticProbable,0) = 1 AND ISNULL(@MalignantProbable,0) <> 1
                BEGIN
					SET @B= 'stricture: probably malignant'
					IF @oCount > 1 SET @B = @B + ', ' + @ostr                                   
                END
                ELSE IF ISNULL(@ExtrahepaticProbable,0) <> 1 AND ISNULL(@MalignantProbable,0) = 1
                BEGIN
					SET @B= 'stricture: malignant'
					IF @oCount > 1 SET @B = @B + ', probably ' + @ostr                                       
                END
                ELSE IF ISNULL(@ExtrahepaticProbable,0) = 1 AND ISNULL(@MalignantProbable,0) = 1
                BEGIN
					SET @B= 'stricture: probably malignant'
					IF @oCount > 1 SET @B = @B + ', probably ' + @ostr                                       
                END
            END 
            ELSE SET @B ='stricture'

            INSERT INTO @tmpDiv (Val) VALUES(@B)
        END

        IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
        BEGIN
			DECLARE @XMLlist8 XML= (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)    
			IF RIGHT(RTRIM(@BilStr),1) <> '.' AND LEN(LTRIM(RTRIM(@BilStr))) > 2 SET @BilStr = @BilStr + '. '                                     
			SET @BilStr = @BilStr + 'Extrahepatic: ' + dbo.fnBuildString(@XMLlist8)                                                    
        END 
        DELETE FROM @tmpDiv
    END         
		
	SET @Other = ISNULL((SELECT TOP 1 LTRIM(RTRIM(Value)) FROM #tbl_ERS_Diagnoses WHERE MatrixCode IN ('BiliaryOther') AND LTRIM(RTRIM(Value)) <> ''),'')
  
	IF @BilStr <>'' AND  @BilStr <>'.'
    BEGIN
		SET @A = @A + '<b>Biliary: </b>' + dbo.fnFirstLetterLower(@BilStr)
		SET @B= ISNULL(@Other,'')
		IF @B <> '' 
		BEGIN 
			SET @B = dbo.fnFirstLetterUpper(@B)
			SET @A = @A + ' ' + @B  + '.'
		END
		SET @A = @A + '<br/>'
    END
	ELSE
    BEGIN
		SET @B= ISNULL(@Other,'')
		IF @B<>''
        BEGIN
			SET @B = dbo.fnFirstLetterLower(@B)
			SET @A = @A + '<b>Biliary: </b>' + @B  + '.' + '<br/>'
        END
    END

------ DUODENUM ------------------------------------------------------------------------

	DELETE FROM @tmpRegionDiv                      
    DELETE FROM @tmpDiv
		
	INSERT INTO @tmpRegionDiv (Val, Region)
	SELECT DISTINCT LOWER(DisplayName) , Region
	FROM #tbl_ERS_Diagnoses WHERE Region IN ('Duodenum')

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('not entered')) INSERT INTO @tmpDiv (Val) VALUES('normal')
	ELSE IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('normal')) INSERT INTO @tmpDiv (Val) VALUES('normal')
	ELSE IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('2nd part not entered')) INSERT INTO @tmpDiv (Val) VALUES('normal')
	ELSE
	BEGIN
		--IF @DuodenumNormal = 1 INSERT INTO @tmpDiv (Val) VALUES('normal')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('angiodysplasia')) INSERT INTO @tmpDiv (Val) VALUES('angiodysplasia')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('tumour')) INSERT INTO @tmpDiv (Val) VALUES('tumour')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('diverticulum')) INSERT INTO @tmpDiv (Val) VALUES('diverticulum')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('duodenitis')) INSERT INTO @tmpDiv (Val) VALUES('duodenitis')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('polyp')) INSERT INTO @tmpDiv (Val) VALUES('polyp')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('ulcer')) INSERT INTO @tmpDiv (Val) VALUES('ulcer')
	END
              
	IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
	BEGIN
		DECLARE @XMLlist9 XML= (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)                                       
		SET @B =  dbo.fnBuildString(@XMLlist9)      
		SET @A = @A + '<b>Duodenum: </b>' + @B + '.'    + '<br/>'                         
	END 
	DELETE FROM @tmpDiv  

	SET @Other = ISNULL((SELECT TOP 1 LTRIM(RTRIM(Value)) FROM #tbl_ERS_Diagnoses WHERE MatrixCode IN ('WholeOther') AND LTRIM(RTRIM(Value)) <> ''),'')
	IF @Other <> ''
	BEGIN
		SET @B= LTRIM(RTRIM((select ISNULL(ListItemText,'') from ERS_Lists where ListDescription='ERCP other diagnoses' AND  ListItemNo = ISNULL(@Other,0))))
		SET @B = dbo.fnAddFullStop(dbo.fnFirstLetterUpper(@B)) + '<br/>'
		SET @A = @A +@B
	END  

	IF @A <> '' UPDATE ERS_ERCPDiagnoses SET Summary = @A
	UPDATE ERS_ProceduresReporting  SET PP_Diagnoses = @A WHERE ProcedureId = @ProcedureId
	


	IF EXISTS(SELECT 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode='Summary') 
		UPDATE [ERS_Diagnoses] SET [Value] = @A WHERE Procedureid=@ProcedureID AND MatrixCode='Summary'
	ELSE INSERT INTO [ERS_Diagnoses] (ProcedureID,MatrixCode,[Value]) VALUES (@ProcedureID,'Summary', @A)

	UPDATE ERS_ProceduresReporting SET PP_Diagnoses = @A WHERE ProcedureId = @ProcedureId

	IF ISNULL(@A,'') = '' AND NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE [Value]<>0 AND ISNULL([Value],'')<>'' AND MatrixCode <>'Summary')
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

--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Annulare' AND Object_ID = Object_ID(N'ERS_ERCPAbnoParenchyma'))
	ALTER TABLE dbo.ERS_ERCPAbnoParenchyma ADD Annulare BIT NOT NULL CONSTRAINT [DF_ERCPAbnoAnnulare_Annulare] DEFAULT 0
GO
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Annulare' AND Object_ID = Object_ID(N'ERSAudit.ERS_ERCPAbnoParenchyma_Audit'))
	ALTER TABLE ERSAudit.ERS_ERCPAbnoParenchyma_Audit ADD Annulare BIT NOT NULL CONSTRAINT [DF_ERCPAbnoAnnulare_Annulare_Audit] DEFAULT 0
GO
--------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_parenchyma_select','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_parenchyma_select]
(
	@SiteId INT	
)
AS

SET NOCOUNT ON

SELECT
	Normal,
	Irregular,
	Dilated,
	SmallLakes,
	Strictures,
	Mass,
	MassType,
	MassProbably,
	Stones,
	SpideryDuctules,
	SpiderySuspection,
	MultiStrictures,
	MultiStricturesSuspection,
	EUSProcType,
	Annulare,
	Summary
FROM
	ERS_ERCPAbnoParenchyma
WHERE 
	SiteId = @SiteId

GO

--------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_parenchyma_save','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_parenchyma_save]
(
	@SiteId INT,
	@Normal BIT,
	@Irregular BIT,
	@Dilated BIT,
	@SmallLakes BIT,
	@Strictures BIT,
	@Mass BIT,
	@MassType TINYINT,
	@MassProbably BIT,
	@Stones BIT,
	@SpideryDuctules BIT,
	@SpiderySuspection TINYINT,
	@MultiStrictures BIT,
	@MultiStricturesSuspection TINYINT,
	@Annulare BIT,
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
	
	
	IF (@Normal=0 AND @Irregular=0 AND @Dilated=0 AND @SmallLakes=0 AND @Strictures=0 AND @Mass=0 AND @Stones=0 AND @SpideryDuctules=0 AND @MultiStrictures=0 AND @Annulare = 0)
	BEGIN
		DELETE FROM ERS_ERCPAbnoParenchyma 
		WHERE SiteId = @SiteId

		DELETE FROM ERS_RecordCount 
		WHERE SiteId = @SiteId
		AND Identifier = 'Parenchyma'
	END		

	ELSE IF NOT EXISTS (SELECT 1 FROM ERS_ERCPAbnoParenchyma WHERE SiteId = @SiteId)
	BEGIN
		INSERT INTO ERS_ERCPAbnoParenchyma (
			SiteId,
			Normal,
			Irregular,
			Dilated,
			SmallLakes,
			Strictures,
			Mass,
			MassType,
			MassProbably,
			Stones,
			SpideryDuctules,
			SpiderySuspection,
			MultiStrictures,
			MultiStricturesSuspection,
			Annulare,
			WhoCreatedId,
			WhenCreated) 
		VALUES (
			@SiteId,
			@Normal,
			@Irregular,
			@Dilated,
			@SmallLakes,
			@Strictures,
			@Mass,
			@MassType,
			@MassProbably,
			@Stones,
			@SpideryDuctules,
			@SpiderySuspection,
			@MultiStrictures,
			@MultiStricturesSuspection,
			@Annulare,
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
			'Parenchyma',
			1)
	END

	ELSE
	BEGIN
		UPDATE 
			ERS_ERCPAbnoParenchyma
		SET 
			Normal = @Normal,
			Irregular = @Irregular,
			Dilated = @Dilated,
			SmallLakes = @SmallLakes,
			Strictures = @Strictures,
			Mass = @Mass,
			MassType = @MassType,
			MassProbably = @MassProbably,
			Stones = @Stones,
			SpideryDuctules = @SpideryDuctules,
			SpiderySuspection = @SpiderySuspection,
			MultiStrictures = @MultiStrictures,
			MultiStricturesSuspection = @MultiStricturesSuspection,
			Annulare = @Annulare,
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
--------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_parenchyma_summary_update','S'
GO

CREATE PROCEDURE [dbo].[abnormalities_parenchyma_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000),
		@Normal BIT,
		@Irregular BIT,
		@Dilated BIT,
		@SmallLakes BIT,
		@Strictures BIT,
		@Mass BIT,
		@MassType TINYINT,
		@MassProbably BIT,
		@Stones BIT,
		@SpideryDuctules BIT,
		@SpiderySuspection TINYINT,
		@MultiStrictures BIT,
		@MultiStricturesSuspection TINYINT,
		@Annulare BIT

	SELECT 
		@Normal=Normal,
		@Irregular=Irregular,
		@Dilated=Dilated,
		@SmallLakes=SmallLakes,
		@Strictures=Strictures,
		@Mass=Mass,
		@MassType=MassType,
		@MassProbably=MassProbably,
		@Stones=Stones,
		@SpideryDuctules=SpideryDuctules,
		@SpiderySuspection=SpiderySuspection,
		@MultiStrictures=MultiStrictures,
		@MultiStricturesSuspection=MultiStricturesSuspection,
		@Annulare=Annulare
	FROM
		ERS_ERCPAbnoParenchyma
	WHERE
		SiteId = @SiteId

	SET @Summary = ''

	IF @Normal = 1
		SET @summary = @summary + 'normal'
	
	ELSE 
	BEGIN
		IF @Irregular = 1
			IF @summary = '' SET @summary = 'irregular ductules'
			ELSE SET @summary = @summary + '$$ irregular ductules'
		IF @Dilated = 1
			IF @summary = '' SET @summary = 'dilated ductules'
			ELSE SET @summary = @summary + '$$ dilated ductules'
		IF @SmallLakes = 1
			IF @summary = '' SET @summary = 'small lakes'
			ELSE SET @summary = @summary + '$$ small lakes'
		IF @Strictures = 1
			IF @summary = '' SET @summary = 'strictures'
			ELSE SET @summary = @summary + '$$ strictures'
		IF @Annulare = 1
			IF @summary = '' SET @summary = 'annulare'
			ELSE SET @summary = @summary + '$$ annulare'

		IF @Mass = 1
		BEGIN
			IF @MassType = 1
				IF @MassProbably = 1
					IF @summary = '' SET @summary = 'probable hepatoma'
					ELSE SET @summary = @summary + '$$ probable hepatoma'
				ELSE
					IF @summary = '' SET @summary = 'hepatoma'
					ELSE SET @summary = @summary + '$$ hepatoma'
			ELSE IF @MassType = 2
				IF @MassProbably = 1
					IF @summary = '' SET @summary = 'probable metastases'
					ELSE SET @summary = @summary + '$$ probable metastases'
				ELSE
					IF @summary = '' SET @summary = 'metastases'
					ELSE SET @summary = @summary + '$$ metastases'
			ELSE
				IF @summary = '' SET @summary = 'mass distorting anatomy'
				ELSE SET @summary = @summary + '$$ mass distorting anatomy'
		END
			
		IF @Stones = 1
			IF @summary = '' SET @summary = 'intrahepatic stones'
			ELSE SET @summary = @summary + '$$ intrahepatic stones'

		IF @SpideryDuctules = 1
			IF @SpiderySuspection = 1
				IF @summary = '' SET @summary = 'suspected cirrhosis'
				ELSE SET @summary = @summary + '$$ suspected cirrhosis'
			ELSE IF @SpiderySuspection = 2
				IF @summary = '' SET @summary = 'suspected polycystic liver disease'
				ELSE SET @summary = @summary + '$$ suspected polycystic liver disease'
			ELSE
				IF @summary = '' SET @summary = 'spidery stretched ductules'
				ELSE SET @summary = @summary + '$$ spidery stretched ductules'

		IF @MultiStrictures = 1
			IF @MultiStricturesSuspection = 1
				IF @summary = '' SET @summary = 'suspected sclerosing cholangitis'
				ELSE SET @summary = @summary + '$$ suspected sclerosing cholangitis'
			ELSE IF @MultiStricturesSuspection = 2
				IF @summary = '' SET @summary = 'suspected Caroli''s disease'
				ELSE SET @summary = @summary + '$$ suspected Caroli''s disease'
			ELSE
				IF @summary = '' SET @summary = 'multiple strictures/dilation'
				ELSE SET @summary = @summary + '$$ multiple strictures/dilation'
	

		IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 2, ' and')
		SET @summary = REPLACE(@summary, '$$', ',')
	END

	--PRINT @summary

	-- Finally update the summary in abnormalities table
	UPDATE ERS_ERCPAbnoParenchyma
	SET Summary = @Summary 
	WHERE SiteId = @siteId

GO
--------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'site_details_menu_select','S'
GO

CREATE PROCEDURE [dbo].[site_details_menu_select]
(
	@SiteId INT	
)
AS

SET NOCOUNT ON

DECLARE	@ProcedureType INT
DECLARE @Region VARCHAR (500)
DECLARE	@Area VARCHAR (50)
DECLARE	@ProcedureId INT

CREATE TABLE #Menus (
	[SiteId] INT,
	[ProcedureType] INT,
	[Region] VARCHAR(500),	
	[ParentMenu] VARCHAR (500),
	[Menu] VARCHAR (500),
	[NavigateUrl] VARCHAR (4000),
	[SortOrder] TINYINT
)

DECLARE @SiteNo INT = NULL

SELECT @SiteNo = SiteNo FROM ERS_Sites WHERE SiteId = @SiteId

IF @SiteNo = 0
	SET @SiteId = dbo.fnGetPrimeSiteId(@SiteId)
ELSE IF @SiteNo = -77   --'SiteNo is set to -77 for sites By Distance (Col & Sig only)
	SELECT @ProcedureType = 3, @Region = 'Anus'
ELSE
	SELECT @ProcedureType = p.ProcedureType, @Region = r.Region, @ProcedureId = p.ProcedureId
	FROM ERS_Sites s
	JOIN ERS_Procedures p ON s.ProcedureId = p.ProcedureId
	JOIN ERS_Regions r ON s.RegionId = r.RegionId
	WHERE SiteId = @SiteId

IF @ProcedureType IN (1,6) --Gastroscopy / EUS(OGD)
BEGIN

	SELECT TOP 1 @Area = [Area] 
	FROM ERS_AbnormalitiesMatrixUpperGI
	WHERE [ProcedureType] = @ProcedureType 
	AND [Region] = @Region

	INSERT INTO #Menus ([SiteId], [ProcedureType], [Region], [ParentMenu], [Menu])
	SELECT 
		@SiteId,
		[ProcedureType], 
		[Region], 
		'Abnormalities' AS [ParentMenu], 
		[Menu]
	FROM 
	(
		SELECT * 
		FROM [ERS_AbnormalitiesMatrixUpperGI] 
		WHERE [ProcedureType] = @ProcedureType 
		AND [Region] = @Region
	) a
	UNPIVOT
	(
		[Display] 
		FOR [Menu] IN ([Gastritis], [Gastric Ulcer], [Lumen], [Malignancy], [Post Surgery], 
						[Deformity], [Polyps], [Varices], [Hiatus Hernia], [Achalasia], 
						[Oesophagitis], [Barretts], [Miscellaneous], [Diverticulum/Other], [Tumour], 
						[Duodenitis], [Pyloric Ulcer], [Duodenal Ulcer], [Scarring/Stenosis], [Vascular Lesions],
						[Atrophic Duodenum], [Mediastinal])
	) b
	WHERE [Display] = 1

	INSERT INTO #Menus ([SiteId], [ProcedureType], [Region], [ParentMenu], [Menu], [NavigateUrl], [SortOrder])
	SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/TherapeuticProcedures/OGDTherapeuticProcedures.aspx', 1
	--SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/Abnormalities/OGD/Lumen.aspx'
	UNION ALL
	SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Gastro/Specimens/OGDSpecimensTaken.aspx', 2
	UNION ALL
	SELECT @SiteId, @ProcedureType, @Region, 'Additional notes', '', '~/Products/Gastro/Notes/Notes.aspx', 3
	--SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Gastro/Abnormalities/OGD/Lumen.aspx'
END

ELSE IF @ProcedureType IN (2,7) --ERCP / EUS(HPB)
BEGIN
	INSERT INTO #Menus ([SiteId], [ProcedureType], [Region], [ParentMenu], [Menu])
	SELECT 
		@SiteId,
		[ProcedureType], 
		[Region], 
		'Abnormalities' AS [ParentMenu], 
		[Menu]
	FROM 
	(
		SELECT * 
		FROM [ERS_AbnormalitiesMatrixERCP] 
		WHERE [ProcedureType] = @ProcedureType 
		AND [Region] = @Region
	) a
	UNPIVOT
	(
		[Display] 
		FOR [Menu] IN ([Gall Bladder], [Duct], [Parenchyma], [Appearance], [Diverticulum], [Tumour], [Diverticulum/Other], 
						[TumourCommon],[Duodenitis],[Duodenal Ulcer],[Scarring/Stenosis],[Vascular Lesions],[Atrophic Duodenum],[Biliary],[Site])
	) b
	WHERE [Display] = 1

	INSERT INTO #Menus ([SiteId], [ProcedureType], [Region], [ParentMenu], [Menu], [NavigateUrl], [SortOrder])
	--SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/TherapeuticProcedures/ERCPTherapeuticProcedures.aspx'
	--SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/Abnormalities/OGD/Lumen.aspx'
	SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/TherapeuticProcedures/ERCPTherapeuticProcedures.aspx', 1
	UNION ALL
	--SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Gastro/Specimens/ERCPSpecimensTaken.aspx'
	--SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Gastro/Abnormalities/OGD/Lumen.aspx'
	SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Gastro/Specimens/OGDSpecimensTaken.aspx', 2
	UNION ALL
	SELECT @SiteId, @ProcedureType, @Region, 'Additional notes', '', '~/Products/Gastro/Notes/Notes.aspx', 3
	
END

ELSE IF @ProcedureType IN (3,4,5) --Colonoscopy / Proctoscopy / Sigmoidoscopy
BEGIN
	INSERT INTO #Menus ([SiteId], [ProcedureType], [Region], [ParentMenu], [Menu])
	SELECT 
		@SiteId,
		[ProcedureType], 
		[Region], 
		'Abnormalities' AS [ParentMenu], 
		[Menu]
	FROM 
	(
		SELECT * 
		FROM [ERS_AbnormalitiesMatrixColon] 
		WHERE [ProcedureType] = @ProcedureType 
		AND [Region] = @Region
	) a
	UNPIVOT
	(
		[Display] 
		FOR [Menu] IN ([Calibre],[Mucosa], [Diverticulum], [Lesions], [Vascularity], [Haemorrhage], [Miscellaneous], [Perianal Lesions])
	) b
	WHERE [Display] = 1

	INSERT INTO #Menus ([SiteId], [ProcedureType], [Region], [ParentMenu], [Menu], [NavigateUrl], [SortOrder])
	--SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/TherapeuticProcedures/ColonTherapeuticProcedures.aspx'
	--SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/Abnormalities/OGD/Lumen.aspx'
	SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/TherapeuticProcedures/OGDTherapeuticProcedures.aspx', 1
	UNION ALL
	--SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Gastro/Specimens/ColonSpecimensTaken.aspx'
	--SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Gastro/Abnormalities/OGD/Lumen.aspx'
	SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Gastro/Specimens/OGDSpecimensTaken.aspx', 2
	UNION ALL
	SELECT @SiteId, @ProcedureType, @Region, 'Additional notes', '', '~/Products/Gastro/Notes/Notes.aspx', 3
END

ELSE IF @ProcedureType IN (8) --Antegrade
BEGIN
	SELECT TOP 1 @Area = [Area] 
	FROM [ERS_AbnormalitiesMatrixAntegrade]
	WHERE [ProcedureType] = @ProcedureType 
	AND [Region] = @Region

	INSERT INTO #Menus ([SiteId], [ProcedureType], [Region], [ParentMenu], [Menu])
	SELECT 
		@SiteId,
		[ProcedureType], 
		[Region], 
		'Abnormalities' AS [ParentMenu], 
		CASE WHEN region = 'Jejunum' AND [Menu] = 'Diverticulum/Other' THEN 'Diverticulum' ELSE [Menu] END AS Menu
	FROM 
	(
		SELECT * 
		FROM [ERS_AbnormalitiesMatrixAntegrade] 
		WHERE [ProcedureType] = @ProcedureType 
		AND [Region] = @Region
	) a
	UNPIVOT
	(
		[Display] 
		FOR [Menu] IN ([Gastritis], [Gastric Ulcer], [Lumen], [Malignancy], [Post Surgery], 
						[Deformity], [Polyps], [Varices], [Hiatus Hernia], [Achalasia], 
						[Oesophagitis], [Barretts], [Miscellaneous], [Diverticulum/Other], [Tumour], 
						[Duodenitis], [Pyloric Ulcer], [Duodenal Ulcer], 
						[Lesions],[Jejunitis],[Jejunal Ulcer],[Ileitis],[Ileal Ulcer],
						[Scarring/Stenosis], [Vascular Lesions],
						[Atrophic Duodenum])
	) b
	WHERE [Display] = 1

	INSERT INTO #Menus ([SiteId], [ProcedureType], [Region], [ParentMenu], [Menu], [NavigateUrl], [SortOrder])
	SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/TherapeuticProcedures/OGDTherapeuticProcedures.aspx', 1
	UNION ALL
	SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Gastro/Specimens/OGDSpecimensTaken.aspx', 2
	UNION ALL
	SELECT @SiteId, @ProcedureType, @Region, 'Additional notes', '', '~/Products/Gastro/Notes/Notes.aspx', 3
END

ELSE IF @ProcedureType IN (9) --Retrograde
BEGIN
	INSERT INTO #Menus ([SiteId], [ProcedureType], [Region], [ParentMenu], [Menu])
	SELECT 
		@SiteId,
		[ProcedureType], 
		[Region], 
		'Abnormalities' AS [ParentMenu], 
		[Menu]
	FROM 
	(
		SELECT * 
		FROM [ERS_AbnormalitiesMatrixRetrograde] 
		WHERE [ProcedureType] = @ProcedureType 
		AND [Region] = @Region
	) a
	UNPIVOT
	(
		[Display] 
		FOR [Menu] IN ([Calibre],[Mucosa], [Diverticulum], [Lesions], [Vascularity], [Haemorrhage])
	) b
	WHERE [Display] = 1

	INSERT INTO #Menus ([SiteId], [ProcedureType], [Region], [ParentMenu], [Menu], [NavigateUrl], [SortOrder])
	--SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/TherapeuticProcedures/ColonTherapeuticProcedures.aspx'
	--SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/Abnormalities/OGD/Lumen.aspx'
	SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/TherapeuticProcedures/OGDTherapeuticProcedures.aspx', 1
	UNION ALL
	--SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Gastro/Specimens/ColonSpecimensTaken.aspx'
	--SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Gastro/Abnormalities/OGD/Lumen.aspx'
	SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Gastro/Specimens/OGDSpecimensTaken.aspx', 2
	UNION ALL
	SELECT @SiteId, @ProcedureType, @Region, 'Additional notes', '', '~/Products/Gastro/Notes/Notes.aspx', 3
END

ELSE IF @ProcedureType IN (10,11) -- Bronchoscopy / EBUS
BEGIN
	INSERT INTO #Menus ([SiteId], [ProcedureType], [Region], [ParentMenu], [Menu])
	SELECT 
		@SiteId,
		[ProcedureType], 
		[Region], 
		'Abnormalities' AS [ParentMenu], 
		[Menu]
	FROM 
	(
		SELECT * 
		FROM [ERS_AbnormalitiesMatrixBRT] 
		WHERE [ProcedureType] = @ProcedureType 
		--AND [Region] = @Region      -- Abnormality is the same for all BRT regions 
	) a
	UNPIVOT
	(
		[Display] 
		FOR [Menu] IN ([Abnormality Descriptions], [EBUS Abnormality Descriptions])
	) b
	WHERE [Display] = 1

	INSERT INTO #Menus ([SiteId], [ProcedureType], [Region], [ParentMenu], [Menu], [NavigateUrl], [SortOrder])
	SELECT @SiteId, @ProcedureType, @Region, 'Therapeutic Procedures', '', '~/Products/Gastro/TherapeuticProcedures/OGDTherapeuticProcedures.aspx', 1
	UNION ALL
	SELECT @SiteId, @ProcedureType, @Region, 'Specimens Taken', '', '~/Products/Broncho/Specimens/BronchoSpecimens.aspx', 2
	UNION ALL
	SELECT @SiteId, @ProcedureType, @Region, 'Additional notes', '', '~/Products/Gastro/Notes/Notes.aspx', 3
END

UPDATE a
SET NavigateUrl = b.NavigateUrl
FROM #Menus a
LEFT JOIN ERS_SiteDetailsMenuUrls b ON a.Menu = b.Menu
WHERE b.ProcedureType = @ProcedureType

UPDATE #Menus SET Menu = 'Tumour' WHERE Menu = 'TumourCommon'

SELECT 
	m.ProcedureType,
	m.Region,
	m.ParentMenu, 
	m.Menu,
	m.NavigateUrl, 
	CASE WHEN r.RecordCountId IS NULL THEN 0 ELSE 1 END AS RecordExists,
	ISNULL(@Area,ISNULL(@Region,'')) AS Area
FROM 
	#Menus m
LEFT OUTER JOIN
	ERS_RecordCount r ON 
		(m.SiteId = r.SiteId OR
			(@ProcedureType IN (2,7) AND r.ProcedureId = @ProcedureId AND r.Identifier = 'Diagnoses')) --These conditions for Diagnoses only (for the whole procedure unlike the other items which are per site)
		AND (m.Menu = r.Identifier OR m.ParentMenu = r.Identifier)
				--OR LEFT(m.Menu,12) = 'Diverticulum') -- embolden 'Diverticulum/Other' when its attributes have been set.
ORDER BY m.SortOrder, m.Menu

DROP TABLE #Menus
GO

--------------------------------------------------------------------------------------------------------------------


EXEC DropIfExist 'TR_ERCPAbnoDuct_Insert','TR';
GO
EXEC DropIfExist 'TR_ERCPAbnoDuct_Delete','TR';
GO

EXEC DropIfExist 'TR_ERCPAbnoDuct','TR';
GO

CREATE TRIGGER [dbo].[TR_ERCPAbnoDuct]
ON [dbo].[ERS_ERCPAbnoDuct]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, 
			@Dilated VARCHAR(10) = 'False', 
			@DilatedType VARCHAR(10) = 'False', @Stricture VARCHAR(10) = 'False', 
			@Fistula VARCHAR(10) = 'False', @Stones VARCHAR(10) = 'False',
			@Cysts VARCHAR(10) = 'False', 
			@CystsCommunicating VARCHAR(10) = 'False', @CystsNonCommunicating VARCHAR(10) = 'False',
			@CystsCholedochal VARCHAR(10) = 'False',
			@TumourCystadenoma VARCHAR(10) = 'False', @TumourProbablyMalignant VARCHAR(10) = 'False',
			@Cholangiocarcinoma VARCHAR(10) = 'False', @ExternalCompression VARCHAR(10) = 'False',
			@Polycystic VARCHAR(10) = 'False', @HydatidCyst VARCHAR(10) = 'False',
			@LiverAbscess VARCHAR(10) = 'False', @PostCholecystectomy VARCHAR(10) = 'False',
			@StrictureProbablyBenign VARCHAR(10) = 'False', @StrictureProbably VARCHAR(10) = 'False',
			@DuctInjury VARCHAR(10) = 'False', @StentOcclusion VARCHAR(10) = 'False',
			@GallBladderTumor VARCHAR(10) = 'False',
			@Action CHAR(1) = 'I', @Area varchar(50), @Region varchar(50)

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Dilated = (CASE WHEN Dilated = 1 THEN 'True' ELSE 'False' END),
				@DilatedType = (CASE WHEN DilatedType = 1 THEN 'True' ELSE 'False' END),   --DilatedType -> No obvious cause
				@PostCholecystectomy = (CASE WHEN DilatedType = 2 THEN 'True' ELSE 'False' END),   --DilatedType -> Post cholecystectomy
				@Stricture = (CASE WHEN Stricture = 1 THEN 'True' ELSE 'False' END),
				@Fistula = (CASE WHEN Fistula = 1 THEN 'True' ELSE 'False' END),
				@Stones = (CASE WHEN Stones = 1 THEN 'True' ELSE 'False' END),
				@Cysts = (CASE WHEN Cysts = 1 THEN 'True' ELSE 'False' END),
				@CystsCommunicating = (CASE WHEN Cysts = 1 AND CystsCommunicating = 1 THEN 'True' ELSE 'False' END),
				@CystsNonCommunicating = (CASE WHEN Cysts = 1 AND CystsCommunicating = 0 THEN 'True' ELSE 'False' END),
				@CystsCholedochal = (CASE WHEN Cysts = 1 AND CystsCholedochal = 1 THEN 'True' ELSE 'False' END),
				@TumourCystadenoma = (CASE WHEN CystsSimple = 1 OR CystsRegular = 1 OR CystsIrregular = 1 OR CystsLoculated = 1 THEN 'True' ELSE 'False' END), --'Diagnosis cystadenoma 
				@TumourProbablyMalignant = (CASE WHEN Stricture = 1 AND StrictureType = 2 THEN 'True' ELSE 'False' END),
				@StrictureProbablyBenign = (CASE WHEN Stricture = 1 AND StrictureType = 1 THEN 'True' ELSE 'False' END),
				@StrictureProbably = (CASE WHEN Stricture = 1 AND StrictureProbably = 1 THEN 'True' ELSE 'False' END),
				@Cholangiocarcinoma = (CASE WHEN Cholangiocarcinoma = 1 THEN 'True' ELSE 'False' END),
				@ExternalCompression = (CASE WHEN ExternalCompression = 1 THEN 'True' ELSE 'False' END),
				@Polycystic = (CASE WHEN ISNULL(CystsSuspectedType,0) = 1 THEN 'True' ELSE 'False' END),
				@HydatidCyst = (CASE WHEN ISNULL(CystsSuspectedType,0) = 2 THEN 'True' ELSE 'False' END),
				@LiverAbscess = (CASE WHEN ISNULL(CystsSuspectedType,0) = 3 THEN 'True' ELSE 'False' END),
				@DuctInjury = (CASE WHEN DuctInjury = 1 THEN 'True' ELSE 'False' END),
				@StentOcclusion = (CASE WHEN StentOcclusion = 1 THEN 'True' ELSE 'False' END),
				@GallBladderTumor = (CASE WHEN GallBladderTumor = 1 THEN 'True' ELSE 'False' END)


		FROM INSERTED

		EXEC abnormalities_duct_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	select @Area = x.area, @Region = x.Region from ERS_AbnormalitiesMatrixERCP x inner join ERS_Regions r on x.region = r.Region inner join ers_sites s on r.RegionId = s.RegionId where SiteId =@site_id

	    --Dim Hepatic() As String        = {"Left Hepatic Ducts", "Right Hepatic Ducts", "Left intra-hepatic ducts", "Right intra-hepatic ducts", "Right Hepatic Lobe", "Left Hepatic Lobe"}
        --Dim GallBladderReg() As String = {"Gall Bladder", "Common Bile Duct", "Common Hepatic Duct", "Cystic Duct", "Bifurcation"}

	IF (LOWER(@Area) = 'pancreas') --'Pancreas Regions
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D70P2',	@Fistula			-- 'Fistula'

		IF @Dilated = 'True' AND @DilatedType = 'False' -- If "Dilated" is checked, diagnoses are "Chronic" and 'Dilatation'
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D85P2', @Dilated				-- 'Chronic'   
			EXEC diagnoses_control_save @site_id, 'D110P2', @Dilated			-- 'Dilatation'   
			EXEC diagnoses_control_save @site_id, 'D115P2', 'False'				-- 'No obvious cause' 
		END
		ELSE IF @Dilated = 'True' AND @DilatedType = 'True'
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D85P2', 'False'				-- 'Chronic'   
			EXEC diagnoses_control_save @site_id, 'D110P2', @Dilated			-- 'Dilatation'   
			EXEC diagnoses_control_save @site_id, 'D115P2', @DilatedType		-- 'No obvious cause' 
		END
		ELSE
		BEGIN --both @Dilated and @DilatedType false
			EXEC diagnoses_control_save @site_id, 'D85P2', 'False'				-- 'Chronic'   
			EXEC diagnoses_control_save @site_id, 'D110P2', 'False'				-- 'Dilatation'   
			EXEC diagnoses_control_save @site_id, 'D115P2', 'False'				-- 'No obvious cause' 
		END
			
		EXEC diagnoses_control_save @site_id, 'D120P2', @Stricture				-- 'Stricture'
		
		EXEC diagnoses_control_save @site_id, 'D95P2', @CystsCommunicating		-- Communicating
		EXEC diagnoses_control_save @site_id, 'D100P2', @CystsNonCommunicating	-- NonCommunicating
		EXEC diagnoses_control_save @site_id, 'D105P2', @CystsCholedochal		-- Pseudocyst
		EXEC diagnoses_control_save @site_id, 'D72P2',	@Stones					-- 'Pancreatic stone'
		EXEC diagnoses_control_save @site_id, 'D130P2',	@TumourCystadenoma		-- 'Cystadenoma'
		EXEC diagnoses_control_save @site_id, 'D125P2',	@TumourProbablyMalignant-- 'Probably malignant'
		EXEC diagnoses_control_save @site_id, 'D69P2',	@DuctInjury				-- 'Duct injury'
		EXEC diagnoses_control_save @site_id, 'D74P2',	@StentOcclusion			-- 'Stent occlusion'

	END
------ DIAGNOSES FOR INTRAHEPATIC SITES i.e above the bifurcation --------------------------------------------------
	ELSE IF LOWER(@Region) IN ('right intra-hepatic ducts', 'right hepatic ducts', 'left intra-hepatic ducts', 'left hepatic ducts', 'right hepatic lobe', 'left hepatic lobe')
	BEGIN
		--Diagnosis probable tumour of type cholangiocarcinoma if patient has stricture that is probably malignant and is probably cholangiocarcinoma
		--Diagnosis probable tumour of type external compression (metastases) if patient has stricture that is probably malignant and is exibiting external compression (metastases)
		IF @Cholangiocarcinoma = 'True' OR @ExternalCompression = 'True'
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D225P2', 'True'				-- 'Tumour'
			EXEC diagnoses_control_save @site_id, 'D242P2', 'True'				-- 'Probable'
			EXEC diagnoses_control_save @site_id, 'D245P2', @Cholangiocarcinoma	--Cholangiocarcinoma
			EXEC diagnoses_control_save @site_id, 'D255P2', @ExternalCompression--External compression
		END
		ELSE
		BEGIN --Both Cholangiocarcinoma & External compression not set
			EXEC diagnoses_control_save @site_id, 'D225P2', 'False'				-- 'Tumour'
			EXEC diagnoses_control_save @site_id, 'D242P2', 'False'				-- 'Probable'
			EXEC diagnoses_control_save @site_id, 'D245P2', 'False'				--Cholangiocarcinoma
			EXEC diagnoses_control_save @site_id, 'D255P2', 'False'				--External compression
		END

		EXEC diagnoses_control_save @site_id, 'D193P2', @DuctInjury					-- 'Duct injury'
		EXEC diagnoses_control_save @site_id, 'D195P2', @StentOcclusion				-- 'Stent occlusion'

		EXEC diagnoses_control_save @site_id, 'D145P2',	@Fistula				-- 'Fistula'

		--Diagnosis polycystic liver disease if patient has suspected polycystic liver disease set in duct abnos...
		EXEC diagnoses_control_save @site_id, 'D200P2', @Polycystic				--Polycystic liver disease

		EXEC diagnoses_control_save @site_id, 'D235P2', @HydatidCyst			--Hydatid Cyst
		EXEC diagnoses_control_save @site_id, 'D240P2', @LiverAbscess			--Liver abscess
	END
------ DIAGNOSES FOR EXTRAHEPATIC SITES i.e below the bifurcation --------------------------------------------------
	ELSE IF LOWER(@Region) IN ('gall bladder', 'common bile duct', 'common hepatic duct', 'cystic duct', 'bifurcation') --'GallBladder and the regions close to it
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D275P2', @Dilated				-- 'Dilated duct'
		EXEC diagnoses_control_save @site_id, 'D270P2', @CystsCholedochal		-- 'Choledochal cyst'
		EXEC diagnoses_control_save @site_id, 'D300P2', @PostCholecystectomy	-- 'Post cholecystectomy'
		EXEC diagnoses_control_save @site_id, 'D290P2', @Stricture				-- 'Stricture'
		
		EXEC diagnoses_control_save @site_id, 'D330P2', @StrictureProbablyBenign	-- 'Benign'
		EXEC diagnoses_control_save @site_id, 'D335P2', @TumourProbablyMalignant	-- 'Malignant'
		EXEC diagnoses_control_save @site_id, 'D325P2', @StrictureProbably			-- 'Extrahepatic probable'
		EXEC diagnoses_control_save @site_id, 'D193P2', @DuctInjury					-- 'Duct injury'
		EXEC diagnoses_control_save @site_id, 'D195P2', @StentOcclusion				-- 'Stent occlusion'

		EXEC diagnoses_control_save @site_id, 'D145P2',	@Fistula					-- 'Fistula'
	END

	--Biliary : stone abnormalities
	IF LOWER(@Region) IN ('gall bladder') --Stones in Gall Bladder
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D180P2',	@GallBladderTumor			-- 'Gall bladder tumor'
		EXEC diagnoses_control_save @site_id, 'D189P2', @Stones		-- Diagnosis : Stones in Gall Bladder
	END 
	ELSE IF LOWER(@Region) IN ('common bile duct', 'cystic duct')	-- Stones in cystic duct and/or common bile duct
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D191P2', @Stones		-- Diagnosis : Stones in the bile duct		
	END
	ELSE IF LOWER(@Region) IN ('common hepatic duct', 'bifurcation', 'right intra-hepatic ducts', 'right hepatic ducts', 
								'left intra-hepatic ducts', 'left hepatic ducts') --'Stones in the common hepatic duct and/or bifurcation and/or left hepatic duct and/or left intra hepatic duct and/or right hepatic duct and/or right intra hepatic duct
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D192P2', @Stones		-- Diagnosis : Stones in the hepatic duct	
	END
GO
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Biliary' AND Object_ID = Object_ID(N'ERS_AbnormalitiesMatrixERCP'))
	ALTER TABLE ERS_AbnormalitiesMatrixERCP ADD Biliary BIT

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Biliary' AND Object_ID = Object_ID(N'ERSAudit.ERS_AbnormalitiesMatrixERCP_Audit'))
	ALTER TABLE ERSAudit.ERS_AbnormalitiesMatrixERCP_Audit ADD Biliary BIT
GO

UPDATE [ERS_AbnormalitiesMatrixERCP] SET Biliary = 1
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_Pages WHERE PageId = 463 OR PageName = 'Bilary')
	INSERT INTO ERS_Pages (PageId, PageName, PageAlias, AppPageName, GroupId, PageURL)
	VALUES (463, 'Biliary', 'Biliary', 'products_gastro_abnormalities_ercp_biliary_aspx', 6, '~/products/gastro/abnormalities/ercp/duct.aspx')
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_SiteDetailsMenuUrls WHERE Menu = 'Biliary')
	INSERT INTO ERS_SiteDetailsMenuUrls (ProcedureType, Menu, NavigateUrl)
	VALUES (2,'Biliary', '~/Products/Gastro/Abnormalities/ERCP/Biliary.aspx'),
		   (7,'Biliary', '~/Products/Gastro/Abnormalities/ERCP/Biliary.aspx')
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.ERS_ERCPAbnoBiliary'))
BEGIN
	CREATE TABLE [dbo].[ERS_ERCPAbnoBiliary](
		[AbnoBiliaryId]					[int]		IDENTITY(1,1) NOT NULL,
		[SiteId]						[int]		NOT NULL CONSTRAINT UQ_ERCPAbnoBiliary_SiteId UNIQUE(SiteId),
		[Normal]						[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_Normal DEFAULT 0,
		[AnastomicStricture]			[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_AnastomicStricture DEFAULT 0,
		[CalculousObstruction]			[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_CalculousObstruction DEFAULT 0,
		[Cholelithiasis]				[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_Cholelithiasis DEFAULT 0,
		[GallBladderTumour]				[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_GallBladderTumour DEFAULT 0,
		[Haemobilia]					[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_MirizziSyndrome DEFAULT 0,
		[MirizziSyndrome]				[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_Haemobilia DEFAULT 0,
		[Occlusion]						[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_Occlusion DEFAULT 0,
		[StentOcclusion]				[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_StentOcclusion DEFAULT 0,
		[NormalIntraheptic]				[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_NormalIntraheptic DEFAULT 0,
		[SuppurativeCholangitis]		[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_SuppurativeCholangitis DEFAULT 0,
		[IntrahepticBiliaryLeak]		[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_IntrahepticBiliaryLeak DEFAULT 0,
		[IntrahepticBiliaryLeakSite]	[tinyint]	NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_IntrahepticBiliaryLeakSite DEFAULT 0,
		[IntrahepticTumourProbable]		[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_IntrahepticTumourProbable DEFAULT 0,
		[IntrahepticTumourPossible]		[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_IntrahepticTumourPossible DEFAULT 0,
		[ExtrahepticNormal]				[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_ExtrahepticNormal DEFAULT 0,
		[ExtrahepticBiliaryLeak]		[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_ExtrahepticBiliaryLeak DEFAULT 0,
		[ExtrahepticBiliaryLeakSite]	[tinyint]	NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_ExtrahepticBiliaryLeakSite DEFAULT 0,
		[Stricture]						[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoBiliary_Stricture DEFAULT 0,
		[Summary]						[nvarchar](4000) NULL,
		[WhoUpdatedId]					[int]		NULL,
		[WhoCreatedId]					[int]		NULL Default 0,
		[WhenCreated]					[DATETIME]	NULL Default GetDate(),
		[WhenUpdated]					[DATETIME]	NULL,
		CONSTRAINT [FK_ERCPAbnoBiliary_Sites] FOREIGN KEY ([SiteId]) REFERENCES ERS_Sites([SiteId]),
		CONSTRAINT [PK_AbnoBiliaryId] PRIMARY KEY CLUSTERED ([AbnoBiliaryId] ASC)
	) ON [PRIMARY]
END
GO


--------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_biliary_save', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_biliary_save]
(
	@SiteId INT,
	@Normal BIT,
	@AnastomicStricture bit,
	@CalculousObstruction bit,	
	@Cholelithiasis bit,		
	@GallBladderTumour bit,		
	@Haemobilia bit,		
	@MirizziSyndrome bit,		
	@Occlusion bit,		
	@StentOcclusion bit,		
	@NormalIntraheptic bit,		
	@SuppurativeCholangitis bit,		
	@IntrahepticBiliaryLeak bit,		
	@IntrahepticBiliaryLeakSite	tinyint,
	@TumourProbable bit,
	@TumourPossible bit,
	@ExtrahepticNormal bit,		
	@ExtrahepticBiliaryLeak bit,		
	@ExtrahepticBiliaryLeakSite	tinyint,
	@Stricture bit,		
	@LoggedInUserId INT
)
AS

SET NOCOUNT ON

DECLARE @proc_id INT
DECLARE @proc_type INT
DECLARE @region VARCHAR(200)

BEGIN TRANSACTION

BEGIN TRY
	SELECT 
		@proc_id = p.ProcedureId,
		@proc_type = p.ProcedureType,
		@region = r.Region
	FROM 
		ERS_Sites s
	JOIN 
		ERS_Procedures p ON s.ProcedureId = p.ProcedureId
	JOIN
		ERS_Regions r ON s.RegionId = r.RegionId
	WHERE 
		SiteId = @SiteId
	
	
	IF (@Normal=0 AND @AnastomicStricture=0 AND @CalculousObstruction=0 AND @Cholelithiasis=0 AND @GallBladderTumour=0 AND @MirizziSyndrome=0 AND @Occlusion=0 AND @StentOcclusion=0 AND @NormalIntraheptic = 0 AND
		@SuppurativeCholangitis=0 AND @IntrahepticBiliaryLeak=0 AND @IntrahepticBiliaryLeakSite=0 AND @ExtrahepticNormal=0 AND @ExtrahepticBiliaryLeak=0 AND @ExtrahepticBiliaryLeakSite = 0 AND @ExtrahepticNormal=0 AND 
		@ExtrahepticBiliaryLeak=0 AND @ExtrahepticBiliaryLeakSite = 0 AND @Stricture=0 AND @TumourProbable=0 AND @TumourPossible=0 ANd @Haemobilia=0)
	BEGIN
		DELETE FROM ERS_ERCPAbnoBiliary 
		WHERE SiteId = @SiteId

		DELETE FROM ERS_RecordCount 
		WHERE SiteId = @SiteId
		AND Identifier = 'Biliary'
	END		

	ELSE IF NOT EXISTS (SELECT 1 FROM ERS_ERCPAbnoBiliary WHERE SiteId = @SiteId)
	BEGIN
		INSERT INTO ERS_ERCPAbnoBiliary (
			 [SiteId]					
			,[Normal]					
			,[AnastomicStricture]		
			,[CalculousObstruction]		
			,[Cholelithiasis]			
			,[GallBladderTumour]
			,[Haemobilia]
			,[MirizziSyndrome]			
			,[Occlusion]					
			,[StentOcclusion]			
			,[NormalIntraheptic]			
			,[SuppurativeCholangitis]	
			,[IntrahepticBiliaryLeak]	
			,[IntrahepticBiliaryLeakSite]
			,[IntrahepticTumourProbable]
			,[IntrahepticTumourPossible]
			,[ExtrahepticNormal]			
			,[ExtrahepticBiliaryLeak]	
			,[ExtrahepticBiliaryLeakSite]
			,[Stricture]					
			,[WhoUpdatedId]				
			,[WhenCreated]) 
		VALUES (
			 @SiteId					
			,@Normal					
			,@AnastomicStricture		
			,@CalculousObstruction		
			,@Cholelithiasis			
			,@GallBladderTumour		
			,@Haemobilia
			,@MirizziSyndrome			
			,@Occlusion					
			,@StentOcclusion			
			,@NormalIntraheptic			
			,@SuppurativeCholangitis	
			,@IntrahepticBiliaryLeak	
			,@IntrahepticBiliaryLeakSite
			,@TumourProbable
			,@TumourPossible
			,@ExtrahepticNormal			
			,@ExtrahepticBiliaryLeak	
			,@ExtrahepticBiliaryLeakSite
			,@Stricture					
			,@LoggedInUserId,
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
			'Biliary',
			1)
	END

	ELSE
	BEGIN
		UPDATE 
			ERS_ERCPAbnoBiliary
		SET 
			 Normal=@Normal					
			,AnastomicStricture=@AnastomicStricture		
			,CalculousObstruction=@CalculousObstruction		
			,Cholelithiasis=@Cholelithiasis			
			,GallBladderTumour=@GallBladderTumour	
			,Haemobilia = @Haemobilia
			,MirizziSyndrome=@MirizziSyndrome			
			,Occlusion=@Occlusion					
			,StentOcclusion=@StentOcclusion			
			,NormalIntraheptic=@NormalIntraheptic			
			,SuppurativeCholangitis=@SuppurativeCholangitis	
			,IntrahepticBiliaryLeak=@IntrahepticBiliaryLeak	
			,IntrahepticBiliaryLeakSite=@IntrahepticBiliaryLeakSite
			,IntrahepticTumourProbable=@TumourProbable
			,IntrahepticTumourPossible=@TumourPossible
			,ExtrahepticNormal=@ExtrahepticNormal			
			,ExtrahepticBiliaryLeak=@ExtrahepticBiliaryLeak	
			,ExtrahepticBiliaryLeakSite=@ExtrahepticBiliaryLeakSite
			,Stricture=@Stricture		
			,WhoUpdatedId = @LoggedInUserId,
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



--------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_ERCPAbnoBiliary_Insert','TR';
GO
EXEC DropIfExist 'TR_ERCPAbnoBiliary_Delete','TR';
GO

EXEC DropIfExist 'TR_ERCPAbnoBiliary','TR';
GO

CREATE TRIGGER [dbo].[TR_ERCPAbnoBiliary]
ON [dbo].[ERS_ERCPAbnoBiliary]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, 
			@Normal VARCHAR(10) = 'False', 
			@AnastomicStricture VARCHAR(10) = 'False', 
			@CalculousObstruction VARCHAR(10) = 'False', 
			@Cholelithiasis VARCHAR(10) = 'False', 
			@GallBladderTumour VARCHAR(10) = 'False',
			@Haemobilia VARCHAR(10) = 'False',
			@MirizziSyndrome VARCHAR(10) = 'False', 
			@Occlusion VARCHAR(10) = 'False', 
			@StentOcclusion VARCHAR(10) = 'False',
			@SuppurativeCholangitis VARCHAR(10) = 'False', 
			@NormalIntraheptic VARCHAR(10) = 'False',
			@IntrahepticBiliaryLeak VARCHAR(10) = 'False',
			@IntrahepticBiliaryLeakSite INT,
			@Tumour BIT = 'False',
			@ExtrahepticNormal VARCHAR(10) = 'False', 
			@ExtrahepticBiliaryLeak VARCHAR(10) = 'False',
			@ExtrahepticBiliaryLeakSite INT,
			@Stricture VARCHAR(10) = 'False', 
			@Action CHAR(1) = 'I', @Area varchar(50), @Region varchar(50)

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Normal = (CASE WHEN Normal = 1 THEN 'True' ELSE 'False' END),
				@AnastomicStricture = (CASE WHEN AnastomicStricture = 1 THEN 'True' ELSE 'False' END),   --DilatedType -> No obvious cause
				@CalculousObstruction = (CASE WHEN CalculousObstruction = 1 THEN 'True' ELSE 'False' END),   --DilatedType -> Post cholecystectomy
				@Cholelithiasis = (CASE WHEN Cholelithiasis = 1 THEN 'True' ELSE 'False' END),
				@GallBladderTumour = (CASE WHEN GallBladderTumour = 1 THEN 'True' ELSE 'False' END),
				@Haemobilia = (CASE WHEN Haemobilia = 1 THEN 'True' ELSE 'False' END),
				@MirizziSyndrome = (CASE WHEN MirizziSyndrome = 1 THEN 'True' ELSE 'False' END),
				@Occlusion = (CASE WHEN Occlusion = 1 THEN 'True' ELSE 'False' END),
				@StentOcclusion = (CASE WHEN StentOcclusion = 1 THEN 'True' ELSE 'False' END),
				@SuppurativeCholangitis = (CASE WHEN SuppurativeCholangitis = 1 THEN 'True' ELSE 'False' END),
				@NormalIntraheptic = (CASE WHEN NormalIntraheptic = 1 THEN 'True' ELSE 'False' END),
				@IntrahepticBiliaryLeak = (CASE WHEN IntrahepticBiliaryLeak = 1 THEN 'True' ELSE 'False' END), 
				@IntrahepticBiliaryLeakSite = ISNULL(IntrahepticBiliaryLeakSite,0),
				@Tumour = (CASE WHEN IntrahepticTumourProbable = 1 OR IntrahepticTumourPossible = 1 THEN 'True' ELSE 'False' END), 
				@ExtrahepticNormal = (CASE WHEN ExtrahepticNormal = 1 THEN 'True' ELSE 'False' END),
				@ExtrahepticBiliaryLeak = ISNULL(ExtrahepticBiliaryLeakSite,0),
				@Stricture = (CASE WHEN Stricture = 1 THEN 'True' ELSE 'False' END)


		FROM INSERTED

		EXEC abnormalities_biliary_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	select @Area = x.area, @Region = x.Region from ERS_AbnormalitiesMatrixERCP x inner join ERS_Regions r on x.region = r.Region inner join ers_sites s on r.RegionId = s.RegionId where SiteId =@site_id
	
	EXEC diagnoses_control_save @site_id, 'D138P2',	@Normal			-- 'Fistula'
	EXEC diagnoses_control_save @site_id, 'D140P2', @AnastomicStricture				-- 'Stricture'
	EXEC diagnoses_control_save @site_id, 'D175P2', @CalculousObstruction		-- Communicating
	EXEC diagnoses_control_save @site_id, 'D185P2', @Cholelithiasis	-- NonCommunicating
	EXEC diagnoses_control_save @site_id, 'D180P2', @GallBladderTumour		-- Pseudocyst
	EXEC diagnoses_control_save @site_id, 'D170P2', @Haemobilia		-- Pseudocyst
	EXEC diagnoses_control_save @site_id, 'D160P2',	@MirizziSyndrome					-- 'Pancreatic stone'
	EXEC diagnoses_control_save @site_id, 'D150P2',	@Occlusion		-- 'Cystadenoma'
	EXEC diagnoses_control_save @site_id, 'D195P2',	@StentOcclusion-- 'Probably malignant'
	EXEC diagnoses_control_save @site_id, 'D210P2',	@SuppurativeCholangitis				-- 'Duct injury'
	EXEC diagnoses_control_save @site_id, 'D198P2',	@NormalIntraheptic			-- 'Stent occlusion'
	EXEC diagnoses_control_save @site_id, 'D220P2',	@IntrahepticBiliaryLeak			-- 'Stent occlusion'
	EXEC diagnoses_control_save @site_id, 'BiliaryLeakSiteVal',	@IntrahepticBiliaryLeakSite			-- 'Stent occlusion'
	EXEC diagnoses_control_save @site_id, 'D265P2',	@ExtrahepticNormal			-- 'Stent occlusion'
	EXEC diagnoses_control_save @site_id, 'D280P2',	@ExtrahepticBiliaryLeak			-- 'Stent occlusion'
	EXEC diagnoses_control_save @site_id, 'ExtrahepaticLeakSiteVal',	@ExtrahepticBiliaryLeakSite			-- 'Stent occlusion'
	EXEC diagnoses_control_save @site_id, 'D74P2',	@Stricture			-- 'Stent occlusion'
	EXEC diagnoses_control_save @site_id, 'D225P2',	@Tumour			-- 'Stent occlusion'

GO	

	
--------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'otherdata_ercp_diagnoses_save','S'
GO

CREATE PROCEDURE [dbo].[otherdata_ercp_diagnoses_save]
(
	@ProcedureID INT,
	@DuodenumNotEntered BIT,
    @DuodenumNormal BIT,
    @Duodenum2ndPartNotEntered BIT,
	@WholePancreatic BIT,
	@PapillaeNormal BIT,
	--@Stenosed BIT,
	--@ERCP_TumourBenign BIT,
	--@ERCP_TumourMalignant BIT,
	@PancreasNormal BIT,
	@PancreasNotEntered BIT--,
	--@Annulare BIT,
	--@DuctInjury BIT,
	--@PanStentOcclusion BIT,
	--@IPMT BIT,
	--@PancreaticAndBiliaryOther VARCHAR(MAX),
	--@BiliaryNormal BIT,
	--@AnastomicStricture BIT,
	--@Haemobilia BIT,
	--@Cholelithiasis BIT,
	--@FistulaLeak BIT,
	--@Mirizzi BIT,
	--@CalculousObstruction BIT,
	--@Occlusion BIT,
	--@GallBladderTumour BIT,
	--@StentOcclusion BIT,
	--@NormalDucts BIT,
	--@Suppurative BIT,
	--@BiliaryLeakSite BIT,
	--@BiliaryLeakSiteVal VARCHAR(MAX),
	--@IntrahepaticTumourProbable BIT,
	--@IntrahepaticTumourPossible BIT,
	--@ExtrahepaticNormal BIT,
	--@ExtrahepaticLeakSite BIT,
	--@ExtrahepaticLeakSiteVal VARCHAR(MAX),
	--@BeningPancreatitis BIT,
	--@BeningPseudocyst BIT,
	--@BeningPrevious BIT,
	--@BeningSclerosing BIT,
	--@BeningProbable BIT,
	--@MalignantGallbladder BIT,
	--@MalignantMetastatic BIT,
	--@MalignantCholangiocarcinoma BIT,
	--@MalignantPancreatic BIT,
	--@MalignantProbable BIT,
	--@BiliaryOther VARCHAR(MAX),
	--@WholeOther VARCHAR(MAX)
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	DELETE
	FROM [ERS_Diagnoses]
	WHERE ProcedureID = @ProcedureID AND IsOtherData = 1

	IF (ISNULL(@WholePancreatic,0) = 1) --Whole pancreatic and biliary system normal 
	BEGIN
		INSERT INTO [ERS_Diagnoses] (ProcedureID, MatrixCode, Value, Region, IsOtherData)
		SELECT @ProcedureId, 'D32P2', CONVERT(VARCHAR(MAX),@WholePancreatic), 'Pancreas', 1
		UNION
		SELECT @ProcedureId, 'D50P2', CONVERT(VARCHAR(MAX),@DuodenumNotEntered), 'Duodenum', 1 WHERE @DuodenumNotEntered = 1 
		UNION
		SELECT @ProcedureId, 'D51P2', CONVERT(VARCHAR(MAX),@DuodenumNormal), 'Duodenum', 1 WHERE @DuodenumNormal = 1 
		UNION
		SELECT @ProcedureId, 'D52P2', CONVERT(VARCHAR(MAX),@Duodenum2ndPartNotEntered), 'Duodenum', 1 WHERE @Duodenum2ndPartNotEntered = 1 
	END
	ELSE
	BEGIN
		INSERT INTO [ERS_Diagnoses] (ProcedureID, MatrixCode, Value, Region, IsOtherData)
		SELECT @ProcedureId, 'D50P2', CONVERT(VARCHAR(MAX),@DuodenumNotEntered), 'Duodenum', 1 WHERE @DuodenumNotEntered = 1 
		UNION
		SELECT @ProcedureId, 'D51P2', CONVERT(VARCHAR(MAX),@DuodenumNormal), 'Duodenum', 1 WHERE @DuodenumNormal = 1 
		UNION
		SELECT @ProcedureId, 'D52P2', CONVERT(VARCHAR(MAX),@Duodenum2ndPartNotEntered), 'Duodenum', 1 WHERE @Duodenum2ndPartNotEntered = 1 
		UNION
		SELECT @ProcedureId, 'D32P2', CONVERT(VARCHAR(MAX),@WholePancreatic), 'Pancreatic', 1 WHERE @WholePancreatic = 1
		UNION	
		SELECT @ProcedureId, 'D33P2', CONVERT(VARCHAR(MAX),@PapillaeNormal), 'Papillae', 1 WHERE @PapillaeNormal = 1
		--UNION	
		--SELECT @ProcedureId, 'D41P2', CONVERT(VARCHAR(MAX),@Stenosed), 'Papillae', 1 WHERE @Stenosed = 1
		--UNION	
		--SELECT @ProcedureId, 'D45P2', CONVERT(VARCHAR(MAX),@ERCP_TumourBenign), 'Papillae', 1 WHERE @ERCP_TumourBenign = 1
		--UNION	
		--SELECT @ProcedureId, 'D65P2', CONVERT(VARCHAR(MAX),@ERCP_TumourMalignant), 'Papillae', 1 WHERE @ERCP_TumourMalignant = 1
		UNION	
		SELECT @ProcedureId, 'D67P2', CONVERT(VARCHAR(MAX),@PancreasNormal), 'Pancreas', 1 WHERE @PancreasNormal = 1
		UNION	
		SELECT @ProcedureId, 'D66P2', CONVERT(VARCHAR(MAX),@PancreasNotEntered), 'Pancreas', 1 WHERE @PancreasNotEntered = 1
		--UNION	
		--SELECT @ProcedureId, 'D68P2', CONVERT(VARCHAR(MAX),@Annulare), 'Pancreas', 1 WHERE @Annulare = 1
		--UNION	
		--SELECT @ProcedureId, 'D69P2', CONVERT(VARCHAR(MAX),@DuctInjury), 'Pancreas', 1 WHERE @DuctInjury = 1
		--UNION	
		--SELECT @ProcedureId, 'D74P2', CONVERT(VARCHAR(MAX),@PanStentOcclusion), 'Pancreas', 1 WHERE @PanStentOcclusion = 1
		--UNION	
		--SELECT @ProcedureId, 'D75P2', CONVERT(VARCHAR(MAX),@IPMT), 'Pancreas', 1 WHERE @IPMT = 1
		--UNION	
		--SELECT @ProcedureId, 'PancreaticOther', CONVERT(VARCHAR(MAX),@PancreaticAndBiliaryOther), 'Pancreas', 1 WHERE ISNULL(@PancreaticAndBiliaryOther,'') <> ''
		--UNION	
		--SELECT @ProcedureId, 'D138P2', CONVERT(VARCHAR(MAX),@BiliaryNormal), 'Biliary', 1 WHERE @BiliaryNormal = 1
		--UNION	
		--SELECT @ProcedureId, 'D140P2', CONVERT(VARCHAR(MAX),@AnastomicStricture), 'Biliary', 1 WHERE @AnastomicStricture = 1
		----UNION	
		----SELECT @ProcedureId, 'D155P2', CONVERT(VARCHAR(MAX),@CysticDuct), 'Biliary', 1 WHERE @CysticDuct = 1
		--UNION	
		--SELECT @ProcedureId, 'D170P2', CONVERT(VARCHAR(MAX),@Haemobilia), 'Biliary', 1 WHERE @Haemobilia = 1
		--UNION	
		--SELECT @ProcedureId, 'D185P2', CONVERT(VARCHAR(MAX),@Cholelithiasis), 'Biliary', 1 WHERE @Cholelithiasis = 1
		--UNION	
		--SELECT @ProcedureId, 'D145P2', CONVERT(VARCHAR(MAX),@FistulaLeak), 'Biliary', 1 WHERE @FistulaLeak = 1
		--UNION	
		--SELECT @ProcedureId, 'D160P2', CONVERT(VARCHAR(MAX),@Mirizzi), 'Biliary', 1 WHERE @Mirizzi = 1
		--UNION	
		--SELECT @ProcedureId, 'D175P2', CONVERT(VARCHAR(MAX),@CalculousObstruction), 'Biliary', 1 WHERE @CalculousObstruction = 1
		----UNION	
		----SELECT @ProcedureId, 'D190P2', CONVERT(VARCHAR(MAX),@GallBladder), 'Biliary', 1 WHERE @GallBladder = 1
		--UNION	
		--SELECT @ProcedureId, 'D150P2', CONVERT(VARCHAR(MAX),@Occlusion), 'Biliary', 1 WHERE @Occlusion = 1
		----UNION	
		----SELECT @ProcedureId, 'D165P2', CONVERT(VARCHAR(MAX),@CommonDuct), 'Biliary', 1 WHERE @CommonDuct = 1
		--UNION	
		--SELECT @ProcedureId, 'D180P2', CONVERT(VARCHAR(MAX),@GallBladderTumour), 'Biliary', 1 WHERE @GallBladderTumour = 1
		--UNION	
		--SELECT @ProcedureId, 'D195P2', CONVERT(VARCHAR(MAX),@StentOcclusion), 'Biliary', 1 WHERE @StentOcclusion = 1
		--UNION	
		--SELECT @ProcedureId, 'D198P2', CONVERT(VARCHAR(MAX),@NormalDucts), 'Intrahepatic', 1 WHERE @NormalDucts = 1
		--UNION	
		--SELECT @ProcedureId, 'D210P2', CONVERT(VARCHAR(MAX),@Suppurative), 'Intrahepatic', 1 WHERE @Suppurative = 1
		--UNION	
		--SELECT @ProcedureId, 'D220P2', CONVERT(VARCHAR(MAX),@BiliaryLeakSite), 'Intrahepatic', 1 WHERE @BiliaryLeakSite = 1
		--UNION	
		--SELECT @ProcedureId, 'BiliaryLeakSiteVal', CONVERT(VARCHAR(MAX),@BiliaryLeakSiteVal), 'Intrahepatic', 1 WHERE ISNULL(@BiliaryLeakSiteVal,'') <> ''
		--UNION	
		--SELECT @ProcedureId, 'D242P2', CONVERT(VARCHAR(MAX),@IntrahepaticTumourProbable), 'Intrahepatic', 1 WHERE @IntrahepaticTumourProbable = 1
		--UNION	
		--SELECT @ProcedureId, 'D243P2', CONVERT(VARCHAR(MAX),@IntrahepaticTumourPossible), 'Intrahepatic', 1 WHERE @IntrahepaticTumourPossible = 1
		--UNION	
		--SELECT @ProcedureId, 'D265P2', CONVERT(VARCHAR(MAX),@ExtrahepaticNormal), 'Extrahepatic', 1 WHERE @ExtrahepaticNormal = 1
		--UNION	
		--SELECT @ProcedureId, 'D280P2', CONVERT(VARCHAR(MAX),@ExtrahepaticLeakSite), 'Extrahepatic', 1 WHERE @ExtrahepaticLeakSite = 1
		--UNION	
		--SELECT @ProcedureId, 'ExtrahepaticLeakSiteVal', CONVERT(VARCHAR(MAX),@ExtrahepaticLeakSiteVal), 'Extrahepatic', 1 WHERE ISNULL(@ExtrahepaticLeakSiteVal,'') <> ''
		--UNION	
		--SELECT @ProcedureId, 'D305P2', CONVERT(VARCHAR(MAX),@BeningPancreatitis), 'Extrahepatic', 1 WHERE @BeningPancreatitis = 1
		--UNION	
		--SELECT @ProcedureId, 'D310P2', CONVERT(VARCHAR(MAX),@BeningPseudocyst), 'Extrahepatic', 1 WHERE @BeningPseudocyst = 1
		--UNION	
		--SELECT @ProcedureId, 'D315P2', CONVERT(VARCHAR(MAX),@BeningPrevious), 'Extrahepatic', 1 WHERE @BeningPrevious = 1
		--UNION	
		--SELECT @ProcedureId, 'D320P2', CONVERT(VARCHAR(MAX),@BeningSclerosing), 'Extrahepatic', 1 WHERE @BeningSclerosing = 1
		--UNION	
		--SELECT @ProcedureId, 'D330P2', CONVERT(VARCHAR(MAX),@BeningProbable), 'Extrahepatic', 1 WHERE @BeningProbable = 1
		--UNION	
		--SELECT @ProcedureId, 'D340P2', CONVERT(VARCHAR(MAX),@MalignantGallbladder), 'Extrahepatic', 1 WHERE @MalignantGallbladder = 1
		--UNION	
		--SELECT @ProcedureId, 'D345P2', CONVERT(VARCHAR(MAX),@MalignantMetastatic), 'Extrahepatic', 1 WHERE @MalignantMetastatic = 1
		--UNION	
		--SELECT @ProcedureId, 'D350P2', CONVERT(VARCHAR(MAX),@MalignantCholangiocarcinoma), 'Extrahepatic', 1 WHERE @MalignantCholangiocarcinoma = 1
		--UNION	
		--SELECT @ProcedureId, 'D355P2', CONVERT(VARCHAR(MAX),@MalignantPancreatic), 'Extrahepatic', 1 WHERE @MalignantPancreatic = 1
		--UNION	
		--SELECT @ProcedureId, 'D335P2', CONVERT(VARCHAR(MAX),@MalignantProbable), 'Extrahepatic', 1 WHERE @MalignantProbable = 1
		--UNION	
		--SELECT @ProcedureId, 'BiliaryOther', CONVERT(VARCHAR(MAX),@BiliaryOther), 'Biliary', 1 WHERE ISNULL(@BiliaryOther,'') <> ''
		--UNION	
		--SELECT @ProcedureId, 'WholeOther', CONVERT(VARCHAR(MAX),@WholeOther), 'ERCP_Diagnoses', 1 WHERE ISNULL(@WholeOther,'') <> ''

	END

	EXEC ercp_diagnoses_summary_update @ProcedureId;

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
EXEC DropIfExist 'abnormalities_biliary_summary_update','S'
GO

CREATE PROCEDURE [dbo].[abnormalities_biliary_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000),
		@tempsummary VARCHAR(1000),
		@tempsummary2 VARCHAR(1000),
		@Normal VARCHAR(10), 
		@AnastomicStricture VARCHAR(10),
		@CalculousObstruction VARCHAR(10),
		@Cholelithiasis VARCHAR(10),
		@GallBladderTumour VARCHAR(10),
		@Haemobilia varchar(10),
		@MirizziSyndrome VARCHAR(10),
		@Occlusion VARCHAR(10),
		@StentOcclusion VARCHAR(10),
		@SuppurativeCholangitis VARCHAR(10),
		@NormalIntraheptic VARCHAR(10),
		@IntrahepticBiliaryLeak VARCHAR(10),
		@IntrahepticBiliaryLeakSite INT,
		@TumourProbable BIT,
		@TumourPossible BIT,
		@ExtrahepticNormal VARCHAR(10),
		@ExtrahepticBiliaryLeak VARCHAR(10),
		@ExtrahepticBiliaryLeakSite INT,
		@Stricture VARCHAR(10)

	SELECT 
		@Normal=Normal,
		@AnastomicStricture=AnastomicStricture,
		@CalculousObstruction=CalculousObstruction,
		@Cholelithiasis=Cholelithiasis,
		@GallBladderTumour=GallBladderTumour,
		@Haemobilia = Haemobilia,
		@MirizziSyndrome=MirizziSyndrome,
		@Occlusion=Occlusion,
		@StentOcclusion=StentOcclusion,
		@SuppurativeCholangitis=SuppurativeCholangitis,
		@NormalIntraheptic=NormalIntraheptic,
		@IntrahepticBiliaryLeak=IntrahepticBiliaryLeak,
		@IntrahepticBiliaryLeakSite =IntrahepticBiliaryLeakSite,
		@TumourProbable =IntrahepticTumourProbable,
		@TumourPossible =IntrahepticTumourPossible,
		@ExtrahepticNormal=ExtrahepticNormal,
		@ExtrahepticBiliaryLeak=ExtrahepticBiliaryLeak,
		@ExtrahepticBiliaryLeakSite=ExtrahepticBiliaryLeakSite,
		@Stricture=Stricture
	FROM
		ERS_ERCPAbnoBiliary
	WHERE
		SiteId = @SiteId

	SET @Summary = ''

	IF @Normal = 1
		SET @summary = @summary + 'normal'
	
	ELSE 
	BEGIN
		IF @AnastomicStricture = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' anastomic stricture'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @CalculousObstruction = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' calculous obstruction of cystic duct'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @Cholelithiasis = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' cholelithiasis'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @GallBladderTumour = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' gall bladder tumour'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @Haemobilia = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' haemobilia'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @MirizziSyndrome = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' mirizzi syndrome'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @Occlusion = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' occlusion'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @StentOcclusion = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' stent occlusion'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @SuppurativeCholangitis = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' suppurative cholangitis'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @Stricture = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' stricture'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @NormalIntraheptic = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' Normal intrahepatic ducts'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @IntrahepticBiliaryLeak = 1
		BEGIN
			IF @IntrahepticBiliaryLeakSite=1
			BEGIN
				SET @tempsummary = ''
				SET @tempsummary = @tempsummary + 'biliary leak' + ' (' +(select ISNULL(ListItemText,'') from ERS_Lists where ListDescription='Intrahepatic biliary leak site' AND  ListItemNo = ISNULL(@IntrahepticBiliaryLeakSite,0)) + ')'
			END
			ELSE
			BEGIN
				SET @tempsummary = ''
				SET @tempsummary = @tempsummary + ' intrahepatic biliary leak'
			END
			

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @TumourProbable = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' probable tumour'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @TumourPossible = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' possible tumour'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @ExtrahepticNormal = 1
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' Extrahepatic ducts normal'

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @ExtrahepticBiliaryLeak = 1
		BEGIN
			IF @ExtrahepticBiliaryLeakSite=1
			BEGIN
				SET @tempsummary = ''
				SET @tempsummary = @tempsummary + 'biliary leak' + ' (' +(select ISNULL(ListItemText,'') from ERS_Lists where ListDescription='Extrahepatic biliary leak site' AND  ListItemNo = ISNULL(@ExtrahepticBiliaryLeakSite,0)) + ')'
			END
			ELSE
			BEGIN
				SET @tempsummary = ''
				SET @tempsummary = @tempsummary + ' extrahepatic biliary leak'
			END

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

	END

	-- Finally update the summary in abnormalities table
	UPDATE ERS_ERCPAbnoBiliary
	SET Summary = @Summary 
	WHERE SiteId = @siteId

GO
--------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_biliary_select','S'
GO

CREATE PROCEDURE abnormalities_biliary_select
(
	@siteId INT
)
AS
BEGIN
	SELECT 
		   [SiteId]
		  ,[Normal]
		  ,[AnastomicStricture]
		  ,[CalculousObstruction]
		  ,[Cholelithiasis]
		  ,[GallBladderTumour]
		  ,[Haemobilia]
		  ,[MirizziSyndrome]
		  ,[Occlusion]
		  ,[StentOcclusion]
		  ,[NormalIntraheptic]
		  ,[SuppurativeCholangitis]
		  ,[IntrahepticBiliaryLeak]
		  ,[IntrahepticBiliaryLeakSite]
		  ,[ExtrahepticNormal]
		  ,[ExtrahepticBiliaryLeak]
		  ,[ExtrahepticBiliaryLeakSite]
		  ,[Stricture]
		  ,[Summary]
		  ,[WhoUpdatedId]
		  ,[WhoCreatedId]
		  ,[WhenCreated]
		  ,[WhenUpdated]
		  ,[IntrahepticTumourProbable]
		  ,[IntrahepticTumourPossible]
	  FROM 
			[ERS_ERCPAbnoBiliary]
	  WHERE 
			SiteId = @siteId
  END
GO
--------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'sites_summary_update','S'
GO

CREATE PROCEDURE [dbo].[sites_summary_update]
(
	@SiteId INT
)
AS

SET NOCOUNT ON

DECLARE @summaryAbnormalities VARCHAR(MAX)
		,@summarySpecimens VARCHAR(MAX)
		,@summaryTherapeutics VARCHAR(MAX)
		,@summaryWhole VARCHAR(MAX)
		,@summaryAbnormalitiesWithHyperLinks VARCHAR(MAX)
		,@summarySpecimensWithHyperLinks VARCHAR(MAX)
		,@summaryTherapeuticsWithHyperLinks VARCHAR(MAX)
		,@procType INT
		,@procId INT
		,@none TINYINT
		,@region VARCHAR(500)
		,@htmlAnchorCode VARCHAR(500)
		,@siteIdStr VARCHAR(15)
		,@indent VARCHAR(15) 
		,@br VARCHAR(10)
		,@opDiv VARCHAR(150)
		,@clDiv VARCHAR(50)
		,@opBold VARCHAR(5)
		,@clBold VARCHAR(5)
		,@fullStop VARCHAR(1)
		,@colon VARCHAR(2)
		,@fldNone VARCHAR(15)
		,@emptyStr VARCHAR(1)
		,@abnoTheraPresent BIT = 0
		,@tmpSummaryAbno VARCHAR(MAX)
		,@tmpSummaryAbnoLinks VARCHAR(MAX)
		,@SiteNo INT
		,@regionID INT
		,@AreaNo INT

BEGIN TRANSACTION

BEGIN TRY

	SET	@summaryAbnormalities = ''
	SET	@summarySpecimens = ''
	SET	@summaryTherapeutics = ''
	SET	@summaryAbnormalitiesWithHyperLinks = ''
	SET	@summarySpecimensWithHyperLinks = ''
	SET	@summaryTherapeuticsWithHyperLinks = ''
	SET @siteIdStr = CONVERT(VARCHAR(10),@SiteId)

	SELECT @procId = p.ProcedureId,@procType = p.ProcedureType, @regionID = s.RegionId, @SiteNo = s.SiteNo, @AreaNo = ISNULL(AreaNo,0),
			@region = CASE WHEN s.SiteNo = -77 THEN						--SiteNo is set to -77 for sites By Distance (Col & Sig only)
						CONVERT(VARCHAR,XCoordinate) +  
							CASE WHEN YCoordinate IS NULL OR YCoordinate=0 THEN ' cm' 
							ELSE (' to ' + CONVERT(VARCHAR,YCoordinate) + ' cm' ) 
							END
					ELSE (SELECT r.Region FROM ERS_Regions r WHERE r.RegionId = s.RegionId)
					END
	FROM ERS_Sites s
	JOIN ERS_Procedures p ON s.ProcedureId = p.ProcedureId
	--JOIN ERS_Regions r ON s.RegionId = r.RegionId
	WHERE SiteId = @SiteId

	--SELECT @region = Region FROM ERS_Regions WHERE RegionId = @regionID

	SET @htmlAnchorCode = '<a href="#" class="sitesummary" onclick="OpenSiteDetails(''''' + @region + ''''',' + @siteIdStr + ',''''{0}'''',''''' + CONVERT(VARCHAR,@AreaNo) + ''''');">{1}</a>'
	--{0} is the name of the menu and {1} is the summary text

	
	DECLARE @SQLString NVARCHAR(MAX), @QryString NVARCHAR(MAX), @AbnoCheck BIT
	DECLARE @ProcedureType INT, @TableName VARCHAR(50), @AbnoNodeName VARCHAR(50), @Identifier VARCHAR(50)

	CREATE TABLE #QueryDetails (ProcType INT, TableName VARCHAR(50), AbnoNodeName VARCHAR(50), Identifier VARCHAR(50));

	--Notes to appear on the report just after the Site X heading, before the abnormalities.
	INSERT INTO #QueryDetails SELECT @procType,	'ERS_Sites',		'',		'Additional notes'

	IF @procType IN (1,6) --Gastroscopy / EUS(OGD)
	BEGIN
		INSERT INTO #QueryDetails VALUES 
		(@procType,	'ERS_CommonAbnoAtrophic',			'Atrophic duodenum','Atrophic Duodenum')
		,(@procType,	'ERS_UpperGIAbnoAchalasia',		'Achalasia',		'Achalasia')
		,(@procType,	'ERS_UpperGIAbnoBarrett',		'',					'Barretts Epithelium')
		,(@procType,	'ERS_UpperGIAbnoDeformity',		'Deformity',		'Deformity')
		,(@procType,	'ERS_CommonAbnoDiverticulum',	'Diverticulum',		'Diverticulum/Other')
		,(@procType,	'ERS_CommonAbnoDuodenalUlcer',	'',					CASE WHEN @region = 'Jejunum' THEN 'Jejunal Ulcer' WHEN @region = 'Ileum' THEN 'Ileal Ulcer' ELSE 'Duodenal Ulcer' END)
		,(@procType,	'ERS_CommonAbnoDuodenitis',		'',					CASE WHEN @region = 'Jejunum' THEN 'Jejunitis' WHEN @region = 'Ileum' THEN 'Ileitis' ELSE 'Duodenitis' END)
		,(@procType,	'ERS_UpperGIAbnoGastricUlcer',	'Gastric ulcer',	'Gastric Ulcer')
		,(@procType,	'ERS_UpperGIAbnoGastritis',		'Gastritis',		'Gastritis')
		,(@procType,	'ERS_UpperGIAbnoHiatusHernia',	'Hiatus hernia',	'Hiatus Hernia')
		,(@procType,	'ERS_UpperGIAbnoLumen',			'Lumen',			'Lumen')
		,(@procType,	'ERS_UpperGIAbnoMalignancy',	'Malignancy',		'Malignancy')
		,(@procType,	'ERS_UpperGIAbnoMiscellaneous',	'',					'Miscellaneous')
		,(@procType,	'ERS_UpperGIAbnoOesophagitis',	'Oesophagitis',		'Oesophagitis')
		,(@procType,	'ERS_UpperGIAbnoPolyps',		'Polyps',			'Polyps')
		,(@procType,	'ERS_UpperGIAbnoPostSurgery',	'Post surgery',		'Post Surgery')
		,(@procType,	'ERS_CommonAbnoScaring',		'',					'Scarring/Stenosis')
		,(@procType,	'ERS_CommonAbnoTumour',			'',					'Tumour')
		,(@procType,	'ERS_UpperGIAbnoVarices',		'Varices',			'Varices')
		,(@procType,	'ERS_CommonAbnoVascularLesions','Vascular lesions',	'Vascular Lesions')
		,(@procType,	'ERS_EUSAbnoMediastinal',		'Mediastinal',		'Mediastinal')
		,(@procType,	'ERS_UpperGITherapeutics',		'Therapeutic procedure(s)',	'Therapeutic Procedures')
		,(@procType,	'ERS_UpperGISpecimens',			'Specimens taken',	'Specimens Taken')
	END
	ELSE IF @procType IN (2,7) --ERCP / / EUS(HPB)
	BEGIN
		INSERT INTO #QueryDetails VALUES 
		(@procType,		'ERS_ERCPAbnoAppearance',		'Appearance',		'Appearance')
		,(@procType,	'ERS_CommonAbnoAtrophic',		'Atrophic duodenum','Atrophic Duodenum')
		,(@procType,	'ERS_CommonAbnoDiverticulum',	'Diverticulum',		'Diverticulum/Other')
		,(@procType,	'ERS_ERCPAbnoDiverticulum',		'Diverticulum',		'Diverticulum/Other')
		,(@procType,	'ERS_ERCPAbnoDuct',				'Duct',				'Duct')
		,(@procType,	'ERS_ERCPAbnoBiliary',			'Biliary',			'Biliary')
		,(@procType,	'ERS_CommonAbnoDuodenalUlcer',	'',					CASE WHEN @region = 'Jejunum' THEN 'Jejunal Ulcer' WHEN @region = 'Ileum' THEN 'Ileal Ulcer' ELSE 'Duodenal Ulcer' END)
		,(@procType,	'ERS_CommonAbnoDuodenitis',		'',					CASE WHEN @region = 'Jejunum' THEN 'Jejunitis' WHEN @region = 'Ileum' THEN 'Ileitis' ELSE 'Duodenitis' END)
		,(@procType,	'ERS_ERCPAbnoParenchyma',		'Parenchyma',		'Parenchyma')
		,(@procType,	'ERS_CommonAbnoScaring',		'',					'Scarring/Stenosis')
		,(@procType,	'ERS_CommonAbnoTumour',			'',					'Tumour')
		,(@procType,	'ERS_ERCPAbnoTumour',			'Tumour',			'Tumour')
		,(@procType,	'ERS_CommonAbnoVascularLesions','Vascular lesions',	'Vascular Lesions')
		,(@procType,	'ERS_EUSAbnoMediastinal',		'Mediastinal',		'Mediastinal')
		,(@procType,	'ERS_ERCPTherapeutics',			'Therapeutic procedure(s)',	'Therapeutic Procedures')
		,(@procType,	'ERS_UpperGISpecimens',			'Specimens taken',	'Specimens Taken')
	END
	ELSE IF @procType IN (3,4,5) --Colon/Sigmo/Procto
	BEGIN
		INSERT INTO #QueryDetails VALUES
		(@procType,		'ERS_ColonAbnoCalibre',			'Calibre',			'Calibre')
		,(@procType,	'ERS_ColonAbnoDiverticulum',	'Diverticulum',		'Diverticulum')
		,(@procType,	'ERS_ColonAbnoHaemorrhage',		'Haemorrhage',		'Haemorrhage')
		,(@procType,	'ERS_ColonAbnoLesions',			'Lesions',			'Lesions')
		,(@procType,	'ERS_ColonAbnoMiscellaneous',	'',					'Miscellaneous')
		,(@procType,	'ERS_ColonAbnoMucosa',			'Mucosa',			'Mucosa')
		,(@procType,	'ERS_ColonAbnoperianallesions',	'Perianal lesions',	'Perianal Lesions')
		,(@procType,	'ERS_ColonAbnoVascularity',		'Vascularity',		'Vascularity')
		,(@procType,	'ERS_UpperGITherapeutics',		'Therapeutic procedure(s)',	'Therapeutic Procedures')
		,(@procType,	'ERS_UpperGISpecimens',			'Specimens taken',	'Specimens Taken')
	END
	ELSE IF @procType IN (8) --Antegrade
	BEGIN
		INSERT INTO #QueryDetails VALUES 
		(@procType,		'ERS_CommonAbnoAtrophic',		'Atrophic duodenum','Atrophic Duodenum')
		,(@procType,	'ERS_CommonAbnoDiverticulum',	'Diverticulum',		'Diverticulum/Other')
		,(@procType,	'ERS_ColonAbnoDiverticulum',	'Diverticulum',		'Diverticulum')
		,(@procType,	'ERS_CommonAbnoDuodenalUlcer',	'',					CASE WHEN @region = 'Jejunum' THEN 'Jejunal Ulcer' WHEN @region = 'Ileum' THEN 'Ileal Ulcer' ELSE 'Duodenal Ulcer' END)
		,(@procType,	'ERS_CommonAbnoDuodenitis',		'',					CASE WHEN @region = 'Jejunum' THEN 'Jejunitis' WHEN @region = 'Ileum' THEN 'Ileitis' ELSE 'Duodenitis' END)
		,(@procType,	'ERS_ColonAbnoLesions',			'Lesions',			'Lesions')
		,(@procType,	'ERS_CommonAbnoScaring',		'',					'Scarring/Stenosis')
		,(@procType,	'ERS_CommonAbnoTumour',			'',					'Tumour')
		,(@procType,	'ERS_CommonAbnoVascularLesions','Vascular lesions',	'Vascular Lesions')
		,(@procType,	'ERS_UpperGITherapeutics',		'Therapeutic procedure(s)',	'Therapeutic Procedures')
		,(@procType,	'ERS_UpperGISpecimens',			'Specimens taken',	'Specimens Taken')
	END
	ELSE IF @procType IN (9) --Retrograde
	BEGIN
		INSERT INTO #QueryDetails VALUES
		(@procType,		'ERS_ColonAbnoCalibre',			'Calibre',			'Calibre')
		,(@procType,	'ERS_ColonAbnoDiverticulum',	'Diverticulum',		'Diverticulum')
		,(@procType,	'ERS_ColonAbnoHaemorrhage',		'Haemorrhage',		'Haemorrhage')
		,(@procType,	'ERS_ColonAbnoLesions',			'Lesions',			'Lesions')
		,(@procType,	'ERS_ColonAbnoMiscellaneous',	'',					'Miscellaneous')
		,(@procType,	'ERS_ColonAbnoMucosa',			'Mucosa',			'Mucosa')
		,(@procType,	'ERS_ColonAbnoperianallesions',	'Perianal lesions',	'Perianal Lesions')
		,(@procType,	'ERS_ColonAbnoVascularity',		'Vascularity',		'Vascularity')
		,(@procType,	'ERS_ERCPTherapeutics',			'Therapeutic procedure(s)',	'Therapeutic Procedures')
		,(@procType,	'ERS_UpperGISpecimens',			'Specimens taken',	'Specimens Taken')
	END
	ELSE IF @procType IN (10, 11, 12) --Bronchoscopy, EBUS, Thoracoscopy
	BEGIN
		INSERT INTO #QueryDetails VALUES
		(@procType,	'ERS_BRTSpecimens',			'Specimens taken',			'Specimens Taken')
	END

	DECLARE qry_cursor CURSOR FOR 
	SELECT ProcType, TableName, AbnoNodeName, Identifier FROM #QueryDetails

	OPEN qry_cursor 
    FETCH NEXT FROM qry_cursor INTO @ProcType, @TableName, @AbnoNodeName, @Identifier

    WHILE @@FETCH_STATUS = 0
    BEGIN
		SET @summaryWhole = ''
		SET @none = NULL
		SET @opDiv = '''<table><tr><td style="padding-left:25px;padding-right:50px;">'' + ' 
		SET @clDiv = ' + ''</td></tr></table>'''
		SET @indent = '&nbsp;- ';		SET @br = '<br />'
		SET @opBold = '<b>';			SET @clBold = '</b>'
		SET @fullStop = '.';			SET @colon = ': '
		SET @fldNone = 'None';			SET @emptyStr = ''
		
		IF @TableName = 'ERS_UpperGIAbnoLumen' SET @fldNone = 'NoBlood'
		ELSE IF @TableName IN ('ERS_ERCPAbnoDuct', 'ERS_ERCPAbnoBiliary', 'ERS_ERCPAbnoParenchyma', 'ERS_ERCPAbnoAppearance', 'ERS_ERCPAbnoDiverticulum') SET @fldNone = 'Normal'
		ELSE SET @fldNone = 'None'

		--Get Summary from respective table
		IF @TableName = 'ERS_Sites'
			BEGIN
				SET @SQLString = 'SELECT @summaryWhole = AdditionalNotes FROM ' + @TableName + '  
							WHERE SiteId =  ' + CONVERT(VARCHAR,@SiteId) + ' AND ISNULL(AdditionalNotes,'''') <> '''' '
				SET @fullStop = @emptyStr
			END
		ELSE
			BEGIN
				SET @SQLString = 'SELECT @summaryWhole = Summary, @none = [' + @fldNone + '] FROM ' + @TableName + '  
							WHERE SiteId =  ' + CONVERT(VARCHAR,@SiteId) + ' AND ISNULL(Summary,'''') <> '''' '
			END

		EXECUTE sp_executesql @SQLString, N'@summaryWhole VARCHAR(MAX) OUTPUT, @none TINYINT OUTPUT', @summaryWhole OUTPUT, @none OUTPUT

		IF @Identifier = 'Therapeutic Procedures' 
		BEGIN
			IF ISNULL(@none,0) = 0 AND LEN(@summaryWhole) > 0
			BEGIN
				SET @fullStop = @emptyStr
				SET @abnoTheraPresent = 1
		END
		ELSE 
		BEGIN
				SET @opDiv = @emptyStr;		SET @clDiv = @emptyStr
				SET @opBold = @emptyStr;	SET @clBold = @emptyStr
		END
		END
		ELSE 
		BEGIN
			IF @Identifier = 'Specimens Taken' 
			BEGIN
				--IF therapeutics present, remove line before specimens
				IF @abnoTheraPresent = 1 SET @br = @emptyStr
			END
			ELSE 
			BEGIN
				SET @opBold = @emptyStr;	SET @clBold = @emptyStr
			END
			SET @opDiv = @emptyStr ;		SET @clDiv = @emptyStr
		END

		IF ISNULL(@summaryWhole,'') <> ''
		BEGIN
			SET @summaryWhole = REPLACE(@summaryWhole,'''','''''')

			--If None is clicked, prefix not required (e.g "Oesophagitis : No Oesophagitis." should be "No Oesophagitis.")
			--Prefix (@AbnoNodeName) is required for Lumen even if None (Blood free) is selected
			IF (ISNULL(@none,0) = 1 OR @AbnoNodeName = '') AND @TableName <> 'ERS_UpperGIAbnoLumen'
			BEGIN	
				SET @AbnoNodeName = '';		SET @colon = ''
			END
			ELSE
			BEGIN
				SET @colon = ': '
			END
		
			SET @tmpSummaryAbno = ' CASE WHEN ''' + @summaryWhole + ''' IN ('''', ''' + @AbnoNodeName + ''') THEN ''' +  @indent + @AbnoNodeName + '' + @fullStop + '''' +
									' ELSE  ''' + @indent + @opBold + @AbnoNodeName + @clBold + @colon + ''' + ' + @opDiv + '''' + @summaryWhole + @fullStop + '''' + @clDiv +
								' END'

			SET @tmpSummaryAbnoLinks = 'CASE WHEN ''' + @summaryWhole + ''' IN ('''', ''' + @AbnoNodeName + ''') THEN ''' +  @indent + @AbnoNodeName + ''' + REPLACE(REPLACE(''' + @htmlAnchorCode + ''',''{0}'',''' + @Identifier + '''),''{1}'',''' + @AbnoNodeName + ''') + ''' + @fullStop + '''' +
										' ELSE  ''' +  @indent + @opBold + @AbnoNodeName + @clBold + @colon + ''' + REPLACE(REPLACE(''' + @htmlAnchorCode + ''',''{0}'',''' + @Identifier + '''),''{1}'',' +  @opDiv + '''' + @summaryWhole + @fullStop + '''' +	 @clDiv +')  ' +
									' END'

		SET @SQLString = 'SELECT ' +
							CASE WHEN @Identifier = 'Specimens Taken'			THEN '@summarySpecimens = @summarySpecimens '
								 WHEN @Identifier = 'Therapeutic Procedures'	THEN '@summaryTherapeutics = @summaryTherapeutics '
								 ELSE '@summaryAbnormalities = @summaryAbnormalities ' END +
										' + ''' + @br  + ''' + '  + @tmpSummaryAbno + ', ' +

							CASE WHEN @Identifier = 'Specimens Taken'			THEN '@summarySpecimensWithHyperLinks = @summarySpecimensWithHyperLinks '
								 WHEN @Identifier = 'Therapeutic Procedures'	THEN '@summaryTherapeuticsWithHyperLinks = @summaryTherapeuticsWithHyperLinks '
								 ELSE '@summaryAbnormalitiesWithHyperLinks = @summaryAbnormalitiesWithHyperLinks ' END +
											' + ''' + @br  + ''' + '  + @tmpSummaryAbnoLinks 						

		IF @Identifier = 'Specimens Taken'
			EXECUTE sp_executesql @SQLString, N'@summarySpecimens VARCHAR(MAX) OUTPUT,@summarySpecimensWithHyperLinks VARCHAR(MAX) OUTPUT', 
						@summarySpecimens = @summarySpecimens OUTPUT, @summarySpecimensWithHyperLinks=@summarySpecimensWithHyperLinks OUTPUT
		ELSE IF @Identifier = 'Therapeutic Procedures'
			EXECUTE sp_executesql @SQLString, N'@summaryTherapeutics VARCHAR(MAX) OUTPUT,@summaryTherapeuticsWithHyperLinks VARCHAR(MAX) OUTPUT', 
						@summaryTherapeutics = @summaryTherapeutics OUTPUT, @summaryTherapeuticsWithHyperLinks=@summaryTherapeuticsWithHyperLinks OUTPUT
		ELSE
			EXECUTE sp_executesql @SQLString, N'@summaryAbnormalities VARCHAR(MAX) OUTPUT,@summaryAbnormalitiesWithHyperLinks VARCHAR(MAX) OUTPUT', 
						@summaryAbnormalities = @summaryAbnormalities OUTPUT, @summaryAbnormalitiesWithHyperLinks=@summaryAbnormalitiesWithHyperLinks OUTPUT
		END

		FETCH NEXT FROM qry_cursor INTO @ProcType, @TableName, @AbnoNodeName, @Identifier
	END

	CLOSE qry_cursor
    DEALLOCATE qry_cursor

	DROP TABLE #QueryDetails


	-- Update the current site's summary
	UPDATE ERS_Sites 
	SET	
		SiteSummary = @summaryAbnormalities,
		SiteSummarySpecimens = @summarySpecimens,
		SiteSummaryTherapeutics = @summaryTherapeutics,
		SiteSummaryWithLinks = @summaryAbnormalitiesWithHyperLinks,
		SiteSummarySpecimensWithLinks = @summarySpecimensWithHyperLinks,
		SiteSummaryTherapeuticsWithLinks = @summaryTherapeuticsWithHyperLinks
	WHERE 
		SiteId = @siteId

	-- Update the summary of the procedure (all the sites)
	EXEC procedure_summary_update @procId

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
IF NOT EXISTS (SELECT 1 FROM ERS_ListsMain WHERE ListDescription = 'Intrahepatic biliary leak site')
BEGIN
	INSERT INTO dbo.ERS_ListsMain (ListDescription, AllowAddNewItem, OrderByDesc, FirstItemText)
	VALUES( 'Intrahepatic biliary leak site', 1, 0,  '')
END
GO

IF NOT EXISTS (SELECT 1 FROM ERS_ListsMain WHERE ListDescription = 'Extrahepatic biliary leak site')
BEGIN
	INSERT INTO dbo.ERS_ListsMain (ListDescription, AllowAddNewItem, OrderByDesc, FirstItemText)
	VALUES( 'Extrahepatic biliary leak site', 1, 0,  '')
END
GO
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_SCH_Rooms)
	INSERT INTO dbo.ERS_SCH_Rooms (RoomName, AllProcedureTypes, HospitalId)
	SELECT N'General', 0, OperatingHospitalId FROM dbo.ERS_OperatingHospitals eoh

IF NOT EXISTS (SELECT 1 FROM ERS_ImagePort WHERE RoomId IS NOT NULL)
	INSERT INTO dbo.ERS_ImagePort (OperatingHospitalId, PortName, RoomId)
	SELECT OperatingHospitalId, 'None', RoomId FROM dbo.ERS_OperatingHospitals eoh
		INNER JOIN dbo.ERS_SCH_Rooms esr ON eoh.OperatingHospitalId = esr.HospitalId WHERE esr.RoomName = 'General'
GO
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ProcedureId' AND Object_ID = Object_ID(N'ERS_OCS_Process'))
	ALTER TABLE ERS_OCS_Process ADD ProcedureId INT
GO
--------------------------------------------------------------------------------------------------------------------

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
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE ProcedureTypeId = 7)
	INSERT INTO ers_diagnosesmatrix (DisplayName, NED_Name, EnProcedureTypeIddoCode, ProcedureTypeId, Section, Disabled, OrderByNumber, Code, Visible )
	SELECT DisplayName, NED_Name, EndoCode, 7, Section, Disabled, OrderByNumber, Code, Visible 
	FROM ers_diagnosesmatrix WHERE dbo.ers_diagnosesmatrix.ProcedureTypeID=2

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE ProcedureTypeId = 6)
	INSERT INTO ers_diagnosesmatrix (DisplayName, NED_Name, EndoCode, ProcedureTypeID, Section, Disabled, OrderByNumber, Code, Visible )
	SELECT edm.DisplayName, edm.NED_Name, edm.EndoCode, 6, edm.Section, edm.Disabled, edm.OrderByNumber, edm.Code, edm.Visible 
	FROM dbo.ERS_DiagnosesMatrix edm WHERE edm.ProcedureTypeID=1

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
