
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

	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value IN ('True','1') AND MatrixCode  NOT IN ('ColonNormal','ColonRestNormal'))
	BEGIN
		DELETE [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode IN ('ColonNormal','ColonRestNormal')
		DELETE #tbl_ERS_Diagnoses WHERE MatrixCode IN ('ColonNormal','ColonRestNormal')
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
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'TumourScopeNotPass' AND Object_ID = Object_ID(N'ERS_UpperGIAbnoMiscellaneous'))
	ALTER TABLE dbo.ERS_UpperGIAbnoMiscellaneous ADD TumourScopeNotPass BIT NOT NULL CONSTRAINT DF_ERS_UpperGIAbnoMiscellaneous_TumourScopeNotPass DEFAULT 0
--------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-------------------------------------350 Create Trigger TR_UpperGIAbnoMiscellaneous_Insert.sql-------------------------------------
--------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_UpperGIAbnoMiscellaneous_Insert', 'TR';
GO

CREATE TRIGGER TR_UpperGIAbnoMiscellaneous_Insert
ON ERS_UpperGIAbnoMiscellaneous
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @Diverticulum VARCHAR(10), @Foreignbody VARCHAR(10), @MaloryWeissTear VARCHAR(10), 
			@MotilityDisorder VARCHAR(10), @Stricture VARCHAR(10), @StrictureBenign VARCHAR(10), @StrictureMalignant VARCHAR(10), 
			@Tumour VARCHAR(10), @TumourBenign VARCHAR(10), @TumourProbablyBenign VARCHAR(10),
			@TumourMalignant VARCHAR(10), @TumourProbablyMalignant VARCHAR(10), @Ulcer VARCHAR(10), @Web VARCHAR(10), @SchatzkiRing VARCHAR(10), 
			@ExtrinsicCompression VARCHAR(10), @PharyngealPouch VARCHAR(10), @ScopeCouldNotPass VARCHAR(10), @InletPatch VARCHAR(10)

	SELECT @site_id=SiteId, 
			@Diverticulum = (CASE WHEN Diverticulum = 1 THEN 'True' ELSE 'False' END), 
			@Foreignbody = (CASE WHEN Foreignbody = 1 THEN 'True' ELSE 'False' END),
			@MaloryWeissTear = (CASE WHEN Mallory = 1 THEN 'True' ELSE 'False' END),
			@MotilityDisorder = (CASE WHEN MotilityDisorder = 1 THEN 'True' ELSE 'False' END),
			@Stricture = (CASE WHEN (Stricture = 1 AND StrictureType = 0) THEN 'True' ELSE 'False' END),
			@StrictureBenign = (CASE WHEN (Stricture = 1 AND StrictureType = 1) THEN 'True' ELSE 'False' END),
			@StrictureMalignant = (CASE WHEN (Stricture = 1 AND StrictureType = 2) THEN 'True' ELSE 'False' END),
			@Tumour = (CASE WHEN (Tumour = 1 AND TumourType = 0) THEN 'True' ELSE 'False' END),
			@TumourBenign = (CASE WHEN (Tumour = 1 AND TumourType = 1 AND TumourProbably <> 1) THEN 'True' ELSE 'False' END),
			@TumourProbablyBenign = (CASE WHEN (Tumour = 1 AND TumourType = 1 AND TumourProbably = 1) THEN 'True' ELSE 'False' END),
			@TumourMalignant = (CASE WHEN (Tumour = 1 AND TumourType = 2 AND TumourProbably <> 1) THEN 'True' ELSE 'False' END),
			@TumourProbablyMalignant = (CASE WHEN (Tumour = 1 AND TumourType = 2 AND TumourProbably = 1) THEN 'True' ELSE 'False' END),
			@Ulcer = (CASE WHEN (Ulceration = 1) THEN 'True' ELSE 'False' END),
			@Web = (CASE WHEN (Web = 1) THEN 'True' ELSE 'False' END),
			@SchatzkiRing = (CASE WHEN (SchatzkiRing = 1) THEN 'True' ELSE 'False' END),
			@ExtrinsicCompression = (CASE WHEN (ExtrinsicCompression = 1) THEN 'True' ELSE 'False' END),
			@PharyngealPouch = (CASE WHEN (Pharyngeal = 1) THEN 'True' ELSE 'False' END),
			@ScopeCouldNotPass = (CASE WHEN (StrictureScopeNotPass = 1) OR (TumourScopeNotPass = 1) THEN 'True' ELSE 'False' END),
			@InletPatch = (CASE WHEN (InletPatch = 1) AND (InletPatchQty > 0 OR InletPatchMultiple = 1) THEN 'True' ELSE 'False' END)
	FROM INSERTED

	EXEC ogd_kpi_stricture_perforation @site_id --Update perforation text in QA for OGD KPI

	EXEC abnormalities_miscellaneous_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D32P1', @Diverticulum			-- 'Diverticulum'
	EXEC diagnoses_control_save @site_id, 'D35P1', @Foreignbody				-- 'Foreignbody'
	EXEC diagnoses_control_save @site_id, 'D24P1', @MaloryWeissTear			-- 'MaloryWeissTear'
	EXEC diagnoses_control_save @site_id, 'D28P1', @MotilityDisorder		-- 'MotilityDisorder'
	EXEC diagnoses_control_save @site_id, 'D21P1', @Stricture				-- 'Stricture'
	EXEC diagnoses_control_save @site_id, 'D72P1', @StrictureBenign			-- 'StrictureBenign'
	EXEC diagnoses_control_save @site_id, 'D73P1', @StrictureMalignant		-- 'StrictureMalignant'
	EXEC diagnoses_control_save @site_id, 'D74P1', @Tumour					-- 'Tumour'
	EXEC diagnoses_control_save @site_id, 'D25P1', @TumourBenign			-- 'TumourBenign'
	EXEC diagnoses_control_save @site_id, 'D29P1', @TumourProbablyBenign	-- 'TumourProbablyBenign'
	EXEC diagnoses_control_save @site_id, 'D34P1', @TumourMalignant			-- 'TumourMalignant'
	EXEC diagnoses_control_save @site_id, 'D37P1', @TumourProbablyMalignant	-- 'TumourProbablyMalignant'
	EXEC diagnoses_control_save @site_id, 'D26P1', @Ulcer					-- 'Ulcer'
	EXEC diagnoses_control_save @site_id, 'D38P1', @Web						-- 'Web'
	EXEC diagnoses_control_save @site_id, 'D71P1', @SchatzkiRing			-- 'SchatzkiRing'
	EXEC diagnoses_control_save @site_id, 'D67P1', @ExtrinsicCompression	-- 'ExtrinsicCompression'
	EXEC diagnoses_control_save @site_id, 'D69P1', @PharyngealPouch			-- 'Pharyngeal Pouch
	EXEC diagnoses_control_save @site_id, 'D98P1', @InletPatch				
	EXEC diagnoses_control_save @site_id, 'StomachNotEntered', @ScopeCouldNotPass			-- 'scope could not pass
	EXEC diagnoses_control_save @site_id, 'DuodenumNotEntered', @ScopeCouldNotPass			-- 'scope could not pass
GO
--------------------------------------------------------------------------------------------------------------------------------------------
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
		IF @DiagnosesMatrixCode IN ('D12P3') AND @Region in ('Rectum', 'Anal Margin')		SET @ProcedureID = NULL
		ELSE IF @DiagnosesMatrixCode IN ('D4P3') AND @Region not in ('Rectum', 'Anal Margin')		SET @ProcedureID = NULL
		ELSE IF @DiagnosesMatrixCode = 'D8P3' AND @Region in ('Rectum', 'Anal Margin')	SET @DiagnosesMatrixCode = 'D13P3' -- D8P3 for 'Malignant colonic tumour', D13P3 for Malignant rectal tumour
		ELSE IF @DiagnosesMatrixCode = 'D5P3' AND @ProcedureType = 4	SET @DiagnosesMatrixCode = 'S5P3' --Sigmo code is S5P3
		ELSE IF @DiagnosesMatrixCode = 'D1P3' AND @ProcedureType = 4	SET @DiagnosesMatrixCode = 'S1P3'
		ELSE IF @DiagnosesMatrixCode = 'D12P3' AND @ProcedureType = 4	SET @DiagnosesMatrixCode = 'S12P3' --not worrying about doing the region check as the one above would've handled and set procedure id to 0 and thins is checked below and acted on accordingly
		ELSE IF @DiagnosesMatrixCode = 'D4P3' AND @ProcedureType = 4    SET @DiagnosesMatrixCode = 'S4P3'  --not worrying about doing the region check as the one above would've handled and set procedure id to 0 and thins is checked below and acted on accordingly
		ELSE IF @DiagnosesMatrixCode = 'D8P3' AND @ProcedureType = 4	SET @DiagnosesMatrixCode = 'S8P3'  --not worrying about doing the region check as the one above would've handled and set procedure id to 0 and thins is checked below and acted on accordingly
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
--------------------------------------------------------------------------------------------------------------------------------------------

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

			IF @Removal > 0 OR @RemovalType > 0 or @Tattooed = 1
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM ERS_UpperGITherapeutics WHERE SiteId = @SiteId)
				BEGIN
					INSERT INTO ERS_UpperGITherapeutics (SiteId, Marking,	MarkingType, MarkedQuantity,	Polypectomy,	PolypectomyRemoval, PolypectomyRemovalType, CarriedOutRole, WhoCreatedId, WhenCreated) 
					VALUES (@SiteId, @Tattooed, @TattooType, @TattooedQty,	@Removal,	@Removal, @RemovalType, 1, @LoggedInUserId, GETDATE())

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
						Marking = @Tattooed,	
						MarkingType = @TattooType, 
						MarkedQuantity = @TattooedQty,
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
						Marking = @Tattooed,	
						MarkingType = @TattooType, 
						MarkedQuantity = @TattooedQty,
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
--------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'HasAbnormalities' AND Object_ID = Object_ID(N'ERS_Sites'))
	ALTER TABLE dbo.ERS_Sites ADD HasAbnormalities INT

IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ERSAudit' AND TABLE_NAME = 'ERS_Sites_Audit'))
	IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'HasAbnormalities' AND Object_ID = Object_ID(N'ERSAudit.ERS_Sites_Audit'))
		ALTER TABLE ERSAudit.ERS_Sites_Audit ADD HasAbnormalities INT
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'fnNormalProcedure','F';
GO 

CREATE FUNCTION dbo.fnNormalProcedure
(
	@ProcedureId INT
)
RETURNS BIT
AS
BEGIN
	RETURN CASE WHEN ((SELECT count(*) FROM ERS_Sites WHERE ProcedureId=@ProcedureId AND isnull(HasAbnormalities,0) = 1)  > 0 OR (SELECT count(*) FROM dbo.ERS_UpperGITherapeutics eug WHERE SiteId IN (SELECT SiteId FROM ERS_Sites WHERE ProcedureId = @ProcedureId)) >0)
		THEN 0 
		ELSE 1 
	END

END	
GO




--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_ProceduresReporting_Updated', 'TR';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER TR_ProceduresReporting_Updated
   ON  ERS_ProceduresReporting
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
		DECLARE @ProcType INT, @NormalProcedure BIT, @NormalMatrixCode VARCHAR(50), @Region VARCHAR(10), @UpdateSQL VARCHAR(MAX)
		SELECT @NormalProcedure	= dbo.fnNormalProcedure(@ProcedureId)
		SELECT @ProcType = ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureId
	
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
				IF EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode = @NormalMatrixCode AND LOWER([Value]) IN ('true','1'))
					DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND MatrixCode = @NormalMatrixCode
			END
		END 

		EXEC ogd_diagnoses_summary_update @ProcedureId
	END
END
GO
--------------------------------------------------------------------------------------------------------------------------------------------
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
		,@AbormalProcedure BIT = 0


BEGIN TRANSACTION

BEGIN TRY

	SET	@summaryAbnormalities = ''
	SET	@summarySpecimens = ''
	SET	@summaryTherapeutics = ''
	SET	@summaryAbnormalitiesWithHyperLinks = ''
	SET	@summarySpecimensWithHyperLinks = ''
	SET	@summaryTherapeuticsWithHyperLinks = ''
	SET @siteIdStr = CONVERT(VARCHAR(10),@SiteId)
	SET @AbormalProcedure = 0

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
		--Perform abno check to determine normal procedure
		IF @none = 0  and @TableName <> 'ERS_UpperGISpecimens' AND @AbormalProcedure <> 1  SET @AbormalProcedure = 1

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
--------------------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'abnormalities_miscellaneous_select','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_miscellaneous_select]
(
	@SiteId INT	
)
AS

SET NOCOUNT ON

SELECT
	SiteId,						
	[None],							
	[Web],							
	[Mallory],				
	[SchatzkiRing],					
	[FoodResidue],					
	[Foreignbody],					
	[ExtrinsicCompression],			
	[Diverticulum],					
	[DivertMultiple],				
	[DivertQty],						
	[Pharyngeal],					
	[DiffuseIntramural],				
	[TractionType],					
	[PulsionType],					
	[MotilityDisorder],				
	[ProbableAchalasia],				
	[ConfirmedAchalasia],			
	[Presbyoesophagus],				
	[MarkedTertiaryContractions],	
	[LaxLowerOesoSphincter],			
	[TortuousOesophagus],			
	[DilatedOesophagus],				
	[MotilityPoor],					
	[Ulceration],					
	[UlcerationType],				
	[UlcerationMultiple],			
	[UlcerationQty],					
	[UlcerationLength],				
	[UlcerationClotInBase],			
	[UlcerationReflux],				
	[UlcerationPostSclero],			
	[UlcerationPostBanding],			
	[Stricture],						
	[StrictureCompression],			
	[StrictureScopeNotPass],			
	[StrictureSeverity],			
	[StrictureType],					
	[StrictureProbably],				
	[StrictureBenignType],			
	[StrictureBeginning],			
	[StrictureLength],	
	[StricturePerforation],			
	[Tumour],						
	[TumourType],					
	[TumourProbably],				
	[TumourExophytic],				
	[TumourBenignType],				
	[TumourBenignTypeOther],			
	[TumourBeginning],				
	[TumourLength],					
	[TumourScopeNotPass],			
	[MiscOther],						
	[EUSproctype],
	[InletPatch],
	[InletPatchMultiple],
	[InletPatchQty],
	[Summary]
FROM
	[ERS_UpperGIAbnoMiscellaneous]
WHERE 
	SiteId = @SiteId

GO
--------------------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'abnormalities_miscellaneous_save','S';
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


EXEC DropIfExist 'fnRepOesoTumour', 'F';
GO 

CREATE FUNCTION fnRepOesoTumour (@SiteId INT)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE
		@summary VARCHAR(200),
		@temp VARCHAR(50),
		@OesoStrict BIT,
		@None BIT,
		@Web BIT,
		@Mallory BIT,
		@SchatzkiRing BIT,
		@FoodResidue BIT,
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
		@Tumour BIT,
		@TumourType TINYINT,
		@TumourProbably BIT,
		@TumourExophytic TINYINT,
		@TumourBenignType TINYINT,
		@TumourBenignTypeOther NVARCHAR(100),
		@TumourBeginning SMALLINT,
		@TumourLength SMALLINT,
		@TumourScopeNotPass BIT,
		@MiscOther NVARCHAR(150),
		@IsLAClassification BIT

	SELECT 
		@None				=	[None],
		@Web					=	Web,
		@Mallory				=	Mallory,
		@SchatzkiRing		=	SchatzkiRing,
		@FoodResidue			=	FoodResidue,
		@ExtrinsicCompression	=	ExtrinsicCompression,
		@Diverticulum		=	Diverticulum,
		@DivertMultiple		=	DivertMultiple,
		@DivertQty			=	DivertQty,
		@Pharyngeal			=	Pharyngeal,
		@DiffuseIntramural	=	DiffuseIntramural,
		@TractionType		=	TractionType,
		@PulsionType			=	PulsionType,
		@MotilityDisorder	=	MotilityDisorder,
		@ProbableAchalasia	=	ProbableAchalasia,
		@ConfirmedAchalasia	=	ConfirmedAchalasia,
		@Presbyoesophagus	=	Presbyoesophagus,
		@MarkedTertiaryContractions	=	MarkedTertiaryContractions,
		@LaxLowerOesoSphincter		=	LaxLowerOesoSphincter,
		@TortuousOesophagus		=	TortuousOesophagus,
		@DilatedOesophagus		=	DilatedOesophagus,
		@MotilityPoor			=	MotilityPoor,
		@Ulceration				=	Ulceration,
		@UlcerationType			=	UlcerationType,
		@UlcerationMultiple		=	UlcerationMultiple,
		@UlcerationQty			=	UlcerationQty,
		@UlcerationLength		=	UlcerationLength,
		@UlcerationClotInBase	=	UlcerationClotInBase,
		@UlcerationReflux		=	UlcerationReflux,
		@UlcerationPostSclero	=	UlcerationPostSclero,
		@UlcerationPostBanding	=	UlcerationPostBanding,
		@Stricture				=	Stricture,
		@StrictureCompression	=	StrictureCompression,
		@StrictureScopeNotPass	=	StrictureScopeNotPass,
		@StrictureSeverity		=	StrictureSeverity,
		@StrictureType			=	StrictureType,
		@StrictureProbably		=	StrictureProbably,
		@StrictureBenignType		=	StrictureBenignType,
		@StrictureBeginning		=	StrictureBeginning,
		@StrictureLength			=	StrictureLength,
		@Tumour					=	Tumour,
		@TumourType				=	TumourType,
		@TumourProbably			=	TumourProbably,
		@TumourExophytic			=	TumourExophytic,
		@TumourBenignType		=	TumourBenignType,
		@TumourBenignTypeOther	=	TumourBenignTypeOther,
		@TumourBeginning			=	TumourBeginning,
		@TumourLength			=	TumourLength,
		@TumourScopeNotPass		=	TumourScopeNotPass,
		@MiscOther				=	MiscOther,
		@IsLAClassification		=	ISNULL(IsLAClassification,0)
	FROM
		ERS_UpperGIAbnoMiscellaneous
	WHERE
		SiteId = @SiteId


	DECLARE @TumourText VARCHAR(100) = ''
	DECLARE @Prob VARCHAR(100) = ''

	IF ISNULL(@Tumour,0) = 0 RETURN ''

	SET @TumourText = CASE @TumourExophytic
							WHEN 1 THEN 'indeterminate'
							WHEN 2 THEN 'submucosal'
							WHEN 3 THEN 'exophytic'
							ELSE ''
						END

	SET @TumourText = @TumourText + ' tumour'

	IF @TumourProbably = 1 SET @Prob = 'probably '

	IF @TumourType = 1
	BEGIN
		SET @TumourText = CASE @TumourBenignType
							WHEN 1 THEN @TumourText + ', ' + @Prob +  'benign (type uncertain)'
							WHEN 2 THEN @TumourText + ', ' + @Prob +  'leiomyoma'
							WHEN 3 THEN @TumourText + ', ' + @Prob +  'lipoma'
							WHEN 4 THEN @TumourText + ', ' + @Prob +  'granular cell tumour'
							WHEN 5 THEN 
								(CASE WHEN @TumourBenignTypeOther <> '' THEN @TumourText + ', ' + @Prob +  'benign (' + @TumourBenignTypeOther + ') ' ELSE '' END)
							ELSE @TumourText + ', ' + @Prob +  'benign'
						END
	END
	ELSE IF @TumourType = 2
	BEGIN
		SET @TumourText = CASE @TumourBenignType
							WHEN 1 THEN @TumourText + ', ' + @Prob +  'malignant (cell type uncertain)'
							WHEN 2 THEN @TumourText + ', ' + @Prob +  'squamous carcinoma'
							WHEN 3 THEN @TumourText + ', ' + @Prob +  'adenocarcinoma'
							WHEN 4 THEN 
								CASE WHEN @TumourBenignTypeOther <> '' THEN @TumourText + ', ' + @Prob +  'malignant (' + @TumourBenignTypeOther + ') ' ELSE '' END
							ELSE @TumourText + ', ' + @Prob +  'malignant'
						END
	END

		--Only report the beginning and/or length of the tumour if it is different from the stricture beginning and/or length.
	IF ISNULL(@TumourBeginning,0) <> 0
	BEGIN
		--IF ISNULL(@StrictureBeginning,0) <> ISNULL(@TumourBeginning,0)
				SET @TumourText = @TumourText + ' beginning ' + CONVERT(VARCHAR,@TumourBeginning) + 'cm from incisors'
	END	

	IF ISNULL(@TumourLength,0) <> 0
	BEGIN
		--IF ISNULL(@StrictureLength,0) <> ISNULL(@TumourLength,0)
				SET @TumourText = @TumourText + ' length ' + CONVERT(VARCHAR,@TumourLength) + 'cm'
	END	

	IF @TumourScopeNotPass = 1 SET @TumourText = @TumourText + ', scope unable to pass'

	RETURN @TumourText
END

GO
--------------------------------------------------------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_oesophagitis_summary_update','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_oesophagitis_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON
	
		DECLARE
		@summary VARCHAR(8000),
		@temp VARCHAR(50),
		@None BIT,
		@MucosalAppearance TINYINT,
		@Reflux BIT,
		@ActiveBleeding BIT,
		@MSMGrade1 BIT,
		@MSMGrade2a BIT,
		@MSMGrade2b BIT,
		@MSMGrade3 BIT,
		@MSMGrade4 BIT,
		@MSMGrade5 BIT,
		@ShortOesophagus BIT,
		@Ulcer BIT,
		@Stricture BIT,
		@LAClassification TINYINT,
		@Other BIT,
		@SuspectedCandida BIT,
		@CausticIngestion BIT,
		@SuspectedHerpes BIT,
		@OtherTypeOther BIT,
		@OtherTypeOtherDesc VARCHAR(200),
		@SuspectedCandidaSeverity TINYINT,
		@CausticIngestionSeverity TINYINT,
		@SuspectedHerpesSeverity TINYINT

		DECLARE @nonGrade5MSMText VARCHAR(200) = '',
				--@mMSM VARCHAR(50) = '',
				@sg2common VARCHAR(50) = '',
				@sg2common1 VARCHAR(50) = '',
				@Grade VARCHAR(50) = 'grade ',
				@sg1 VARCHAR(220) = '',
				@sg2 VARCHAR(220) = '',
				@sg2a VARCHAR(320) = '',
				@sg2b VARCHAR(320) = '',
				@sg3 VARCHAR(320) = '',
				@plus VARCHAR(10) = '',
				@Grade5BarrattsText VARCHAR(200) = '',
				@RefluxBleedingOnly VARCHAR(200) = ''

	SELECT 
		@None=[None],
		@MucosalAppearance = MucosalAppearance,
		@Reflux = ISNULL(Reflux,0),
		@ActiveBleeding = ISNULL(ActiveBleeding,0),
		@MSMGrade1 = ISNULL(MSMGrade1,0),
		@MSMGrade2a = ISNULL(MSMGrade2a,0),
		@MSMGrade2b = ISNULL(MSMGrade2b,0),
		@MSMGrade3 = ISNULL(MSMGrade3,0),
		@MSMGrade4 = ISNULL(MSMGrade4,0),
		@MSMGrade5 = ISNULL(MSMGrade5,0),
		@ShortOesophagus = ISNULL(ShortOesophagus,0),
		@Ulcer = ISNULL(Ulcer,0),
		@Stricture = ISNULL(Stricture,0),
		@LAClassification = LAClassification,
		@Other = Other,
		@SuspectedCandida = SuspectedCandida,
		@CausticIngestion = CausticIngestion,
		@SuspectedHerpes = SuspectedHerpes,
		@OtherTypeOther = OtherTypeOther,
		@OtherTypeOtherDesc = (SELECT ISNULL(OtherTypeOtherDesc,'') as [text()] FOR XML PATH('')),
		@SuspectedCandidaSeverity = SuspectedCandidaSeverity,
		@CausticIngestionSeverity = CausticIngestionSeverity,
		@SuspectedHerpesSeverity = SuspectedHerpesSeverity
	FROM
		ERS_UpperGIAbnoOesophagitis
	WHERE
		SiteId = @SiteId

	SET @Summary = ''
	SET @temp = ''

	--If 'No oesophagitis' then ...
	IF @None = 1
		SET @summary = @summary + 'No oesophagitis'
	
	ELSE IF @MucosalAppearance > 0 OR @Reflux = 1 OR @Other = 1
	BEGIN
        -- There IS Oesophagitis or Barrett's so ...
        -- nonMSMOesoText contains the non-MSM oesophagitis text
		DECLARE @tmpOeso TABLE(Val VARCHAR(MAX))

		DECLARE @tmpVal VARCHAR(500) = '',
				@LAClassText VARCHAR(300) = ''
		DECLARE @SC VARCHAR(50) = '',
				@SH VARCHAR(50) = '',
				@nonMSMOesoText VARCHAR(500) = '',
				@withText VARCHAR(20) = '',
				--@MA VARCHAR(50) = '',
				@Oeso VARCHAR(150) = '',
				@mMSM VARCHAR(150) = 'Modified Savary Miller '
		DECLARE @XMLlist XML
				

		IF @Other = 1
		BEGIN
			-- Suspected candida
			IF @SuspectedCandida = 1
			BEGIN
				SET @SC = CASE @SuspectedCandidaSeverity
							WHEN 1 THEN 'mild '
							WHEN 2 THEN 'moderate '
							WHEN 3 THEN 'severe '
							ELSE ''
						END
				SET @SC = @SC + 'candida'
				INSERT INTO @tmpOeso (Val) VALUES(@SC)
			END
			--Suspected herpes
			IF @SuspectedHerpes = 1
			BEGIN
				SET @SH = ''
				SET @SH = CASE @SuspectedHerpesSeverity
							WHEN 1 THEN 'mild '
							WHEN 2 THEN 'moderate '
							WHEN 3 THEN 'severe '
							ELSE ''
						END
				SET @SH = @SH + 'herpes'
				INSERT INTO @tmpOeso (Val) VALUES(@SH)
			END

			--'If either candida or herpes then add 'suspected'
			IF @SuspectedHerpes = 1 UPDATE @tmpOeso SET VAL = VAL + ' suspected' WHERE VAL LIKE '%herpes' --  SET @SH = @SH + ' suspected'
			ELSE IF @SuspectedCandida = 1  UPDATE @tmpOeso SET VAL = VAL + ' suspected' WHERE VAL LIKE '%candida' -- SET @SC = @SC + ' suspected'

			--IF @SuspectedHerpes = 1 INSERT INTO @tmpOeso (Val) VALUES(@SH)
			--IF @SuspectedCandida = 1 INSERT INTO @tmpOeso (Val) VALUES(@SC)

			--Caustic ingestion
			IF @CausticIngestion = 1
			BEGIN
				SET @tmpVal = ''
				SET @tmpVal = CASE @CausticIngestionSeverity
							WHEN 1 THEN 'mild '
							WHEN 2 THEN 'moderate '
							WHEN 3 THEN 'severe '
							ELSE ''
						END
				SET @tmpVal = @tmpVal + 'caustic ingestion'
				INSERT INTO @tmpOeso (Val) VALUES(@tmpVal)
			END

			--Other
			If @OtherTypeOther = 1 AND LTRIM(RTRIM(@OtherTypeOtherDesc)) <> ''
			BEGIN
				SET @tmpVal = ''
				SET @tmpVal = LTRIM(RTRIM(@OtherTypeOtherDesc))
				SET @tmpVal = dbo.fnFirstLetterUpper(@tmpVal)
				INSERT INTO @tmpOeso (Val) VALUES(@tmpVal)
			END
		END  --'Of Oesophagitis other

		--Mucosal appearance
		IF @MucosalAppearance > 0
		BEGIN
			SET @tmpVal = ''
			SET @tmpVal = CASE @MucosalAppearance
						WHEN 1 THEN 'normal mucosa'
						WHEN 2 THEN 'discrete erosion '
						WHEN 3 THEN 'discrete pseudomembranes '
						WHEN 4 THEN 'confluent ulceration '
						WHEN 5 THEN 'confluent pseudomembranes '
						ELSE ''
					END
			INSERT INTO @tmpOeso (Val) VALUES(@tmpVal)
			--IF @Reflux = 1 SET @temp = @temp + 'with '
		END

		SET @XMLlist = (SELECT Val FROM @tmpOeso FOR XML  RAW, ELEMENTS, TYPE)
		SET @nonMSMOesoText = dbo.fnBuildString(@XMLlist)

		--If there's only one of the above then the sentence will be concatenated with any others using the 'with' conjunction, else it will read 'together with'
		IF ISNULL((SELECT COUNT(Val) FROM @tmpOeso WHERE NOT VAL IS NULL),0) = 1
			SET @withText = ' with '
		ELSE IF ISNULL((SELECT COUNT(Val) FROM @tmpOeso WHERE NOT VAL IS NULL),0) <> 0
			SET @withText = ' together with '

		DECLARE @OesophagitisClassification BIT
		SELECT @OesophagitisClassification = ISNULL(OesophagitisClassification,0) FROM ERS_SystemConfig 
		WHERE OperatingHospitalID = 
			(SELECT OperatingHospitalID FROM ERS_Procedures WHERE ProcedureId = 
				(SELECT ProcedureId FROM ERS_Sites WHERE SiteId = @SiteId))

		--Which Oeso Classification?
		IF @LAClassification > 0 OR @OesophagitisClassification > 0
		BEGIN
			SET @tmpVal = ''
			SET @tmpVal = CASE @LAClassification
						WHEN 1 THEN 'grade A oesophagitis (mucosal breaks confined to the mucosal fold each no longer than 5mm'
						WHEN 2 THEN 'grade B oesophagitis (at least one mucosal break longer than 5mm confined to the mucosal fold but not continuous between two folds'
						WHEN 3 THEN 'grade C oesophagitis (mucosal breaks that are continuous between the tops of mucosal folds but not circumferential'
						WHEN 4 THEN 'grade D oesophagitis (extensive mucosal breaks engaging at least 75% of the oesophageal circumference'
						ELSE ''
					END
				
			IF @ActiveBleeding = 1 SET @tmpVal = @tmpVal + ' with active bleeding'
			IF @tmpVal > '' SET @tmpVal = @tmpVal + ')'

			DELETE @tmpOeso

			--If there's Short oesophagus
			IF @ShortOesophagus = 1 INSERT INTO @tmpOeso (Val) VALUES('short oesophagus')

			--If there's Ulceration
			IF @Ulcer = 1 INSERT INTO @tmpOeso (Val) VALUES('ulcer')

			IF @Stricture = 1 INSERT INTO @tmpOeso (Val) VALUES('stricture')
				
			SET @XMLlist = (SELECT Val FROM @tmpOeso FOR XML  RAW, ELEMENTS, TYPE)

			IF (SELECT COUNT(Val) FROM @tmpOeso) > 0 SET @tmpVal = @tmpVal + ' and ' + dbo.fnBuildString(@XMLlist)

			IF @tmpVal <> '' SET @LAClassText = dbo.fnFirstLetterUpper(@tmpVal)
		END
		ELSE
		BEGIN
			SET @tmpVal = ''

			DELETE FROM @tmpOeso

			If @MSMGrade5=1 SET @nonGrade5MSMText = @mMSM + 'grade 5. '

			--If the site has both reflux grade 5 and grade 4
			If @MSMGrade5=1 AND (@MSMGrade4=1 OR @MSMGrade3=1 OR @MSMGrade2b=1 OR @MSMGrade2a=1 OR @MSMGrade1=1) 
			BEGIN
				SET @nonGrade5MSMText = @nonGrade5MSMText + 'This is associated with '
				SET @mMSM = 'grade 4 '
			END

			--If the site is not 5 but is 4 or less
			If @MSMGrade5=0 AND (@MSMGrade4=1 OR @MSMGrade3=1 OR @MSMGrade2b=1 OR @MSMGrade2a=1 OR @MSMGrade1=1) 
			BEGIN
				SET @nonGrade5MSMText = @nonGrade5MSMText + @mMSM

				IF @MSMGrade4=1
				BEGIN
					SET @nonGrade5MSMText = @nonGrade5MSMText + 'grade 4 '
					SET @Grade = ''
					SET @mMSM = ''
				END
			END

			IF @MSMGrade4=1
			BEGIN
				SET @plus = ' plus '
				IF @ShortOesophagus=0 AND @Ulcer=0 AND @Stricture=0 
					SET @nonGrade5MSMText = @nonGrade5MSMText + @mMSM + 'chronic lesions'
			END

			--If there's Grade 4 Short oesophagus
			IF @ShortOesophagus=1 INSERT INTO @tmpOeso (Val) VALUES('short oesophagus')

			--If there's Grade 4 Ulceration
			IF @Ulcer=1  INSERT INTO @tmpOeso (Val) VALUES('ulcer')

			IF @Stricture=1  INSERT INTO @tmpOeso (Val) VALUES('stricture')

			IF (SELECT COUNT(Val) FROM @tmpOeso) > 0
			BEGIN
				SET @XMLlist = (SELECT Val FROM @tmpOeso FOR XML  RAW, ELEMENTS, TYPE)
				SET @nonGrade5MSMText = RTRIM(@nonGrade5MSMText) + ' ' + @mMSM + dbo.fnBuildString(@XMLlist)
			END 

			SET @sg2common = 'multiple erosions, non-circumferential, '
			SET @sg2common1 = 'affecting more than one longitudinal fold '

			IF @Grade <> ''
			BEGIN
				SET @sg1 = @Grade + '1 '
				SET @sg2 = @Grade + '2 '
				SET @sg2a = @Grade + '2a '
				SET @sg2b = @Grade + '2b '
				SET @sg3 = @Grade + '3 '
			END

			SET @sg1 = @sg1 + 'single or isolated erosion(s), oval or linear, but affecting only one longitudinal fold '
			SET @sg2 = @sg2 + @sg2common + @sg2common1
			SET @sg2a = @sg2a + @sg2common + 'without confluence, ' + @sg2common1
			SET @sg2b = @sg2b + @sg2common + 'with confluence, ' + @sg2common1
			SET @sg3 = @sg3 + 'circumferential erosion' 
				
			--If reflux grade 3, 2b, 2a or 1 then just report the grade description.
			If @MSMGrade3=1 SET @nonGrade5MSMText = @nonGrade5MSMText + @plus + @sg3
			If @MSMGrade2b=1 SET @nonGrade5MSMText = @nonGrade5MSMText + @plus + @sg2b
			If @MSMGrade2a=1 SET @nonGrade5MSMText = @nonGrade5MSMText + @plus + @sg2a
			If @MSMGrade1=1 SET @nonGrade5MSMText = @nonGrade5MSMText + @plus + @sg1

			IF LTRIM(RTRIM(@nonGrade5MSMText)) <> ''
			BEGIN
				IF @ActiveBleeding=1 SET @nonGrade5MSMText = @nonGrade5MSMText + ' and active bleeding'
			END
		END

        --'-----------------------------------------------------------------------------------------
        --' if any non Grade 5 has been reported then "active bleeding" has been already included,
        --' if any Grade 5 has been reported then now is the time to add "active bleeding",
        --' but if neither has been reported then it's just "reflux oesophagitis"
        --' (with or without active bleeding)
        --'-----------------------------------------------------------------------------------------
			
		IF LTRIM(RTRIM(@nonGrade5MSMText)) <> ''
		BEGIN
			IF LTRIM(RTRIM(@LAClassText)) = ''
			BEGIN
				IF @Reflux=1 SET @RefluxBleedingOnly = 'Reflux oesophagitis'  --'unspecified type of reflux (no MSM grade)

				IF @ActiveBleeding=1
				BEGIN
					IF @RefluxBleedingOnly <> '' SET @RefluxBleedingOnly = @RefluxBleedingOnly + ' with active bleeding'
					ELSE SET @RefluxBleedingOnly = 'Active bleeding'
				END
			END
		END

        --'If stricture has been reported check to see if scope could pass. Note stricture can
        --'only occur on MSM Grade 4 therefore text is added to nonGrade5MSMText
		--VB6 Code - StrictureReported variable will always be false


		--'complete the unspecified reflux sentence
		SET @RefluxBleedingOnly = dbo.fnAddFullStop(@RefluxBleedingOnly)
		
		IF @nonGrade5MSMText <> ''
		BEGIN
			--If there's non-MSM Oeso text to begin with then we need to combine sentences with the conjuction
			IF @nonMSMOesoText <> ''
				SET @summary = @nonMSMOesoText + @withText + @nonGrade5MSMText
			ELSE
				SET @summary = @nonGrade5MSMText

			IF  @ActiveBleeding=1 SET @Grade5BarrattsText =  ' and active bleeding'
		END
		ELSE
		BEGIN
			--'If there's LA Classification then ...
			IF @LAClassText <> '' 
			BEGIN
				SET @summary = @nonMSMOesoText + @withText + @LAClassText
				SET @LAClassText=''
			END
			ELSE
			BEGIN
				--'But if there's only Oesophagitis other
				SET @summary = @nonMSMOesoText
			END

		END
	END

	SET @Summary = LTRIM(RTRIM(@Summary))
	IF RIGHT(@Summary,1) = '.' SET @Summary = LEFT(@Summary, LEN(@Summary) - 1)

	-- Finally update the summary in abnormalities table
	UPDATE ERS_UpperGIAbnoOesophagitis
	SET Summary = @Summary 
	WHERE SiteId = @siteId

GO
------------------------------------------------------------------------------------------------------------
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D97P1'))
	insert into [ERS_DiagnosesMatrix]
	([DisplayName] ,[NED_Name] ,[ProcedureTypeID] ,[Section] ,[Disabled] ,[OrderByNumber] ,[Code] ,[Visible])
	values ('Post-surgical', 'Gastric postoperative appearance', 1, 'Oesophagus', 1, 8, 'D97P1', 0)
GO


EXEC DropIfExist 'TR_UpperGIAbnoPostSurgery_Insert','TR';
GO

CREATE TRIGGER [dbo].[TR_UpperGIAbnoPostSurgery_Insert]
ON [dbo].[ERS_UpperGIAbnoPostSurgery]
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @PostSurgical VARCHAR(10), @Area varchar(20), @Code varchar(5)
	SELECT @site_id=SiteId,
			@PostSurgical = (CASE WHEN (PreviousSurgery=1) THEN 'True' ELSE 'False' END)
	FROM INSERTED

	Select @Area = x.area
			FROM ERS_AbnormalitiesMatrixUpperGI x
			INNER JOIN ERS_Regions r ON x.region = r.Region AND x.ProcedureType = r.ProcedureType AND x.ProcedureType =  1
			INNER JOIN ers_sites s ON r.RegionId = s.RegionId AND SiteId = @site_id

	IF @Area = 'Stomach' SET @Code = 'D45P1'
	IF @Area = 'Oesophagus' SET @Code = 'D97P1'
	IF @Area = ''  SET @Code = 'D45P1'

	EXEC abnormalities_postsurgery_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, @Code, @PostSurgical			-- 'PostSurgical'
GO

EXEC DropIfExist 'TR_UpperGIAbnoMiscellaneous_Delete', 'TR';
GO

CREATE TRIGGER TR_UpperGIAbnoMiscellaneous_Delete
ON ERS_UpperGIAbnoMiscellaneous
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
	EXEC diagnoses_control_save @site_id, 'StomachNotEntered', 'False'			-- 'scope could not pass
	EXEC diagnoses_control_save @site_id, 'DuodenumNotEntered', 'False'			-- 'scope could not pass

	EXEC sites_summary_update @site_id

GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_UpperGIExtentOfIntubation_Insert', 'TR';
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
	ELSE
	BEGIN
		--set normal where applicable
		IF EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ed WHERE MatrixCode = 'OesophagusNormal' AND Value = 'False' AND IsOtherData = 1) 
			UPDATE ERS_Diagnoses SET Value = 'True' WHERE ProcedureId = @procedure_id AND MatrixCode = 'OesophagusNormal' AND IsOtherData = 1 -- Entry would've only been put in by this SP if 'IsOtherData' is 1 so safe to undo

		IF EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ed WHERE MatrixCode = 'StomachNormal' AND Value = 'False' AND IsOtherData = 1)
			UPDATE ERS_Diagnoses SET Value = 'True' WHERE ProcedureId = @procedure_id AND MatrixCode = 'StomachNormal' AND IsOtherData = 1 -- Entry would've only been put in by this SP if 'IsOtherData' is 1 so safe to undo
			
		IF EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ed WHERE MatrixCode = 'DuodenumNormal' AND Value = 'False' AND IsOtherData = 1)
			UPDATE ERS_Diagnoses SET Value = 'True' WHERE ProcedureId = @procedure_id AND MatrixCode = 'DuodenumNormal' AND IsOtherData = 1 -- Entry would've only been put in by this SP if 'IsOtherData' is 1 so safe to undo
			
	END

	EXEC ogd_diagnoses_summary_update @procedure_id
	EXEC ogd_extentofintubation_summary_update @procedure_id
GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D74P1'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Tumour', 1, 'Oesophagus', 1, 74, 'D74P1', 0)
GO


UPDATE ERS_DiagnosesMatrix
SET NED_Name = NULL
WHERE Code = 'D21P1'

UPDATE ERS_DiagnosesMatrix
SET NED_Name = 'Oesophageal stricture - benign'
WHERE Code = 'D72P1'

UPDATE ERS_DiagnosesMatrix
SET NED_Name = 'Oesophageal stricture - malignant'
WHERE Code = 'D73P1'

UPDATE ERS_DiagnosesMatrix 
SET DisplayName = 'Diverticulosis and diverticulitis' 
WHERE Code = 'D5P3'

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D94P1'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Probable carcinoma', 1, 'Duodenum', 1, 94, 'D94P1', 0)
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D95P1'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Probable lymphoma', 1, 'Duodenum', 1, 95, 'D95P1', 0)
GO


IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D96P1'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Atrophic duodenum', 1, 'Duodenum', 1, 96, 'D96P1', 0)
GO


IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D89P1'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Bleeding from unidentified site', 1, 'Stomach', 1, 89, 'D89P1', 0)
GO


IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D9531'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Healing ulcer', 1, 'Stomach', 1, 53, 'D9531', 0)
GO


IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D9541'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Healed ulcer', 1, 'Stomach', 1, 54, 'D9541', 0)
GO


IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D9551'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Extrinsic compression', 1, 'Stomach', 1, 55, 'D9551', 0)
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D98P1'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Inlet patch', 1, 'Oesophagus', 1, 89, 'D98P1', 0)
GO

--------------------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'colon_extent_limiting_factors_summary_update','S';
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
	@Abandoned bit
	
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
	@TimeForWithdrawalSec=TimeForWithdrawalSec 
FROM
	[ERS_ColonExtentOfIntubation]
WHERE
	ProcedureID = @ProcedureID
	
DECLARE @tmpDiv TABLE(Val VARCHAR(MAX))
DECLARE @XMLlist XML	
DECLARE @temp varchar(1000)
DECLARE @ScopeType varchar(50), @summary varchar(5000) =''
DECLARE @A varchar(5000), @B VARCHAR(5000), @Rectal varchar(500), @Retro varchar(500),@InsertionPoint varchar(50), @ProcType int



SET @Rectal =''
SET @A =''
SET @Retro = ''

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

--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_CommonAbnoTumour_Insert','TR';
GO
EXEC DropIfExist 'TR_CommonAbnoTumour_Delete','TR';
GO

EXEC DropIfExist 'TR_CommonAbnoTumour','TR';
GO

CREATE TRIGGER [dbo].[TR_CommonAbnoTumour]
ON [dbo].[ERS_CommonAbnoTumour]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @DuoPolyp VARCHAR(10) = 'False', @Tumour VARCHAR(10) = 'False',
			@ERCPTumour VARCHAR(10) = 'False', @ProbableCarcinoma VARCHAR(10) = 'False', 
			@ProbableLymphoma VARCHAR(10) = 'False',
			@Action CHAR(1) = 'I',
			@DuoTumourBenign VARCHAR(10) = 'False', @DuoTumourMalignan VARCHAR(10) = 'False'

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				--@DuoPolyp = (CASE WHEN ([Type] = 1) THEN 'True' ELSE 'False' END),
				--@Tumour = (CASE WHEN ([Type] = 2) THEN 'True' ELSE 'False' END),
				--@ERCPTumour = (CASE WHEN ([Type] IN (2,3)) THEN 'True' ELSE 'False' END),
				@DuoTumourBenign = (CASE WHEN ([Type] = 1) THEN 'True' ELSE 'False' END),
				@ProbableLymphoma = (CASE WHEN [Type] = 2 THEN 'True' ELSE 'False' END),
				@ProbableCarcinoma = (CASE WHEN [Type] = 3 THEN 'True' ELSE 'False' END),
				@DuoTumourMalignan = (CASE WHEN ([Type] = 4) THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_tumour_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D58P1', @DuoPolyp			-- 'DuoPolyp'
	EXEC diagnoses_control_save @site_id, 'D55P1', @Tumour				-- 'Tumour'
	--EXEC diagnoses_control_save @site_id, 'D55P2', @ERCPTumour			-- 'ERCP Tumour'
	EXEC diagnoses_control_save @site_id, 'D92P1', @DuoTumourBenign		-- 'Tumour Benign'
	EXEC diagnoses_control_save @site_id, 'D93P1', @DuoTumourMalignan		-- 'Tumour Benign'
	EXEC diagnoses_control_save @site_id, 'D94P1', @ProbableCarcinoma		-- 'Probable lymphoma'
	EXEC diagnoses_control_save @site_id, 'D95P1', @ProbableLymphoma		-- 'Probable lymphoma'
GO
--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_CommonAbnoAtrophic_Insert', 'TR';
GO

CREATE TRIGGER TR_CommonAbnoAtrophic_Insert
ON ERS_CommonAbnoAtrophic
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @Atrophic VARCHAR(10)
	SELECT @site_id=SiteId,
	@Atrophic = (CASE WHEN [Type] > 0 THEN 'True' ELSE 'False' END)
	FROM INSERTED

	EXEC abnormalities_atrophic_summary_update @site_id
	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D96P1', @Atrophic			-- 'Atrophic'

GO


--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_UpperGIAbnoLumen_Insert', 'TR';
GO

CREATE TRIGGER TR_UpperGIAbnoLumen_Insert
ON ERS_UpperGIAbnoLumen
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @Lumen VARCHAR(50)
	SELECT @site_id=SiteId,
		   @Lumen = (CASE WHEN [NoBlood] = 0 THEN 'True' ELSE 'False' END)  
	FROM INSERTED

	EXEC abnormalities_lumen_summary_update @site_id
	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D89P1', @Lumen			-- 'Lumen'

GO

--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_UpperGIAbnoLumen_Delete', 'TR';
GO

CREATE TRIGGER TR_UpperGIAbnoLumen_Delete
ON ERS_UpperGIAbnoLumen
AFTER DELETE
AS 
	DECLARE @site_id INT
	SELECT @site_id=SiteId FROM DELETED

	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D89P1', 'False'			-- 'Lumen'


GO

--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_UpperGIAbnoGastritis_Delete', 'TR';
GO

CREATE TRIGGER TR_UpperGIAbnoGastritis_Delete
ON ERS_UpperGIAbnoGastritis
AFTER DELETE
AS 
	DECLARE @site_id INT
	SELECT @site_id=SiteId FROM DELETED
	EXEC diagnoses_control_save @site_id, 'D39P1', 'False'			-- 'Erosions'
	EXEC diagnoses_control_save @site_id, 'D49P1', 'False'			-- 'Gastritis'
	EXEC diagnoses_control_save @site_id, 'D84P1', 'False'			-- 'Non Erosive'

	EXEC sites_summary_update @site_id

GO
--------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_UpperGIAbnoGastricUlcer_Insert', 'TR';
GO

CREATE TRIGGER TR_UpperGIAbnoGastricUlcer_Insert
	ON ERS_UpperGIAbnoGastricUlcer
	AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @StomachUlcer VARCHAR(10), @MultipleUlcers VARCHAR(10), 
			@HealingUlcer VARCHAR(10), @HealedUlcer VARCHAR(10)

	SELECT @site_id=SiteId,
			@StomachUlcer = (CASE WHEN (Ulcer=1 AND (UlcerNumber=1 OR UlcerNumber is null)) THEN 'True' ELSE 'False' END),
			@MultipleUlcers = (CASE WHEN (Ulcer=1 AND UlcerNumber > 1) THEN 'True' ELSE 'False' END),
			@HealingUlcer = (CASE WHEN (HealingUlcer=1) THEN 'True' ELSE 'False' END),
			@HealedUlcer = (CASE WHEN (HealedUlcer=1) THEN 'True' ELSE 'False' END)
	FROM INSERTED

	EXEC abnormalities_gastric_ulcer_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D51P1', @StomachUlcer			-- 'StomachUlcer'
	EXEC diagnoses_control_save @site_id, 'D42P1', @MultipleUlcers			-- 'MultipleUlcers'
	EXEC diagnoses_control_save @site_id, 'D42P1', @MultipleUlcers			-- 'MultipleUlcers'
	EXEC diagnoses_control_save @site_id, 'D9531', @HealingUlcer			-- 'HealingUlcers'
	EXEC diagnoses_control_save @site_id, 'D9541', @HealedUlcer				-- 'HealedUlcers'

GO

--------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_UpperGIAbnoGastricUlcer_Delete', 'TR';
GO

CREATE TRIGGER TR_UpperGIAbnoGastricUlcer_Delete
ON ERS_UpperGIAbnoGastricUlcer
AFTER DELETE
AS 
	DECLARE @site_id INT
	SELECT @site_id=SiteId FROM DELETED
	EXEC diagnoses_control_save @site_id, 'D51P1', 'False'			-- 'StomachUlcer'
	EXEC diagnoses_control_save @site_id, 'D42P1', 'False'			-- 'MultipleUlcers'
	EXEC diagnoses_control_save @site_id, 'D42P1', 'False'			-- 'MultipleUlcers'
	EXEC diagnoses_control_save @site_id, 'D9531', 'False'			-- 'HealingUlcers'
	EXEC diagnoses_control_save @site_id, 'D9541', 'False'				-- 'HealedUlcers'

	EXEC sites_summary_update @site_id

GO


--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_UpperGIAbnoDeformity_Insert', 'TR';
GO

CREATE TRIGGER TR_UpperGIAbnoDeformity_Insert
ON ERS_UpperGIAbnoDeformity
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @PyloricStenosis VARCHAR(10), @TumorSubmucosal VARCHAR(10), @ExtrinsicCompression VARCHAR(10), @Deformity VARCHAR(10)
	SELECT @site_id=SiteId,
			@PyloricStenosis = (CASE WHEN (DeformityType=4) THEN 'True' ELSE 'False' END),
			@TumorSubmucosal = (CASE WHEN (DeformityType=6) THEN 'True' ELSE 'False' END),
			@ExtrinsicCompression = (CASE WHEN (DeformityType=1) THEN 'True' ELSE 'False' END),
			@Deformity = (CASE WHEN (DeformityType IN (2,3,5,6)) THEN 'True' ELSE 'False' END)


	FROM INSERTED

	EXEC abnormalities_deformity_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D50P1', @PyloricStenosis			-- 'PyloricStenosis'
	EXEC diagnoses_control_save @site_id, 'D88P1', @TumorSubmucosal			-- 'Tumor Submucosal'
	EXEC diagnoses_control_save @site_id, 'D9551', @ExtrinsicCompression	

GO

--------------------------------------------------------------------------------------------------------------------
-------------------------------------335 Create Trigger TR_UpperGIAbnoDeformity_Delete.sql-------------------------------------
--------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_UpperGIAbnoDeformity_Delete', 'TR';
GO

CREATE TRIGGER TR_UpperGIAbnoDeformity_Delete
ON ERS_UpperGIAbnoDeformity
AFTER DELETE
AS 
	DECLARE @site_id INT
	SELECT @site_id=SiteId FROM DELETED
	EXEC diagnoses_control_save @site_id, 'D50P1', 'False'				-- 'PyloricStenosis'
	EXEC diagnoses_control_save @site_id, 'D88P1', 'False'				-- 'Tumor Submucosal'
	EXEC diagnoses_control_save @site_id, 'D9551', 'False'		

	EXEC sites_summary_update @site_id

GO

--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_ERS_Extent_Limiting_Factors_Insert', 'TR';
GO

CREATE TRIGGER TR_ERS_Extent_Limiting_Factors_Insert
ON ERS_ColonExtentOfIntubation
AFTER INSERT, UPDATE 
AS 
	DECLARE @procedureID INT, @AbandonedProcedure VARCHAR(10), @NormalProcedure BIT
	SELECT @procedureID = procedureID,
		   @AbandonedProcedure = (CASE WHEN Abandoned = 1 OR NED_Abandoned = 1 THEN 'True' ELSE 'False' END) FROM INSERTED

	EXEC colon_extent_limiting_factors_summary_update @procedureID

	SELECT * INTO #tbl_ERS_Diagnoses FROM ERS_Diagnoses WHERE ProcedureId = @procedureID
	
	SELECT @NormalProcedure	= dbo.fnNormalProcedure(@ProcedureId)

	IF @AbandonedProcedure = 'True'
	BEGIN
		--remove normal diagnoses if exists 
		IF EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode = 'ColonNormal')
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND MatrixCode = 'ColonNormal'
		
		IF @NormalProcedure = 1
		BEGIN
			--set diagnoses
			IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode = 'ColonRestNormal')
				INSERT INTO ERS_Diagnoses (ProcedureId, Region, MatrixCode, Value, IsOtherData)
				VALUES (@ProcedureId, 'Colon', 'ColonRestNormal', 'True', 1)
			ELSE
				UPDATE ERS_Diagnoses SET Value = 'True' WHERE ProcedureId = @ProcedureId AND MatrixCode = 'ColonRestNormal' --Incase entry is there but wuith a value of false
		END

		EXEC ogd_diagnoses_summary_update @ProcedureId
	END
	ELSE IF @AbandonedProcedure = 'False'
	BEGIN
		IF EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode = 'ColonRestNormal')
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND MatrixCode = 'ColonRestNormal'

		EXEC ogd_diagnoses_summary_update @ProcedureId
	END
GO


GO
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
