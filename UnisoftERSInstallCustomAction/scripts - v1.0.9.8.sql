
EXEC DropIfExist 'otherdata_ogd_diagnoses_save','S';
GO

CREATE PROCEDURE [dbo].[otherdata_ogd_diagnoses_save]
(
	@ProcedureID INT,
	@OverallNormal BIT,
    @OesophagusNormal BIT,
    --@OesophagusNotEntered BIT,
    @OesoList VARCHAR(1500),
    --@StomachNotEntered BIT,
    @StomachNormal BIT,
    @stomachList VARCHAR(1500),
    --@DuodenumNotEntered BIT,
    --@Duodenum2ndPartNotEntered BIT,
    @DuodenumNormal BIT,
    @DuoList VARCHAR(1500)
    --@OesophagusOtherDiagnosis VARCHAR(MAX),
    --@StomachOtherDiagnosis VARCHAR(MAX),
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	DELETE
	FROM [ERS_Diagnoses]
	WHERE ProcedureID = @ProcedureID AND IsOtherData = 1

	IF (ISNULL(@OverallNormal,0) = 1) --Whole upper gastro-intestinal tract normal 
	BEGIN
		INSERT INTO [ERS_Diagnoses] (ProcedureID, MatrixCode, Value, Region, IsOtherData)
		SELECT @ProcedureId, 'OverallNormal', CONVERT(VARCHAR(MAX),@OverallNormal), '', 1 
	END
	ELSE
	BEGIN
		INSERT INTO [ERS_Diagnoses] (ProcedureID, MatrixCode, Value, Region, IsOtherData)
		--SELECT @ProcedureId, [item], CONVERT(VARCHAR(MAX),'True'), 'Oesophagus', 1 FROM dbo.fnSplitString(@OesoList,',')
		--		WHERE ISNULL(@OesophagusNotEntered,0) = 0 AND ISNULL(@OesophagusNormal,0) = 0
		--UNION
		--SELECT @ProcedureId, [item], CONVERT(VARCHAR(MAX),'True'), 'Stomach', 1 FROM dbo.fnSplitString(@stomachList,',')
		--		WHERE ISNULL(@StomachNotEntered,0) = 0 AND ISNULL(@StomachNormal,0) = 0
		--UNION
		--SELECT @ProcedureId, [item], CONVERT(VARCHAR(MAX),'True'), 'Duodenum', 1 FROM dbo.fnSplitString(@DuoList,',')
		--		WHERE ISNULL(@DuodenumNotEntered,0) = 0 AND ISNULL(@DuodenumNormal,0) = 0
		--UNION
		--SELECT @ProcedureId, 'OesophagusNotEntered', CONVERT(VARCHAR(MAX),@OesophagusNotEntered), 'Oesophagus', 1 WHERE @OesophagusNotEntered = 1 
		--UNION
		SELECT @ProcedureId, 'OesophagusNormal', 'True', 'Oesophagus', 1 WHERE @OesophagusNormal = 1 
		--UNION
		--SELECT @ProcedureId, 'OesophagusOtherDiagnosis', CONVERT(VARCHAR(MAX),@OesophagusOtherDiagnosis), 'Oesophagus', 1 WHERE ISNULL(@OesophagusOtherDiagnosis,'') <> '' 
		UNION
		SELECT @ProcedureId, 'OesophagusNormal', 'False', 'Oesophagus', 1 WHERE @OesophagusNormal = 0 
		UNION
		--SELECT @ProcedureId, 'StomachNotEntered', CONVERT(VARCHAR(MAX),@StomachNotEntered), 'Stomach', 1 WHERE @StomachNotEntered = 1 
		--UNION
		SELECT @ProcedureId, 'StomachNormal', 'True', 'Stomach', 1 WHERE @StomachNormal = 1 
		--UNION
		--SELECT @ProcedureId, 'StomachOtherDiagnosis', CONVERT(VARCHAR(MAX),@StomachOtherDiagnosis), 'Stomach', 1 WHERE ISNULL(@StomachOtherDiagnosis,'') <> '' 
		UNION
		SELECT @ProcedureId, 'StomachNormal', 'False', 'Stomach', 1 WHERE @StomachNormal = 0 
		UNION
		--SELECT @ProcedureId, 'DuodenumNotEntered', CONVERT(VARCHAR(MAX),@DuodenumNotEntered), 'Duodenum', 1 WHERE @DuodenumNotEntered = 1 
		--UNION
		SELECT @ProcedureId, 'DuodenumNormal', 'True', 'Duodenum', 1 WHERE @DuodenumNormal = 1 
		UNION
		SELECT @ProcedureId, 'DuodenumNormal', 'False', 'Duodenum', 1 WHERE @DuodenumNormal = 0
		--UNION
		--SELECT @ProcedureId, 'DuodenumOtherDiagnosis', CONVERT(VARCHAR(MAX),@DuodenumOtherDiagnosis), 'Duodenum', 1 WHERE ISNULL(@DuodenumOtherDiagnosis,'') <> '' 
		--UNION
		--SELECT @ProcedureId, 'Duodenum2ndPartNotEntered', CONVERT(VARCHAR(MAX),@Duodenum2ndPartNotEntered), 'Duodenum', 1 
		--			WHERE ISNULL(@Duodenum2ndPartNotEntered,'') <> '' AND ISNULL(@DuodenumNotEntered,0) = 0 --AND ISNULL(@DuodenumNormal,0) = 0

	END

	EXEC ogd_diagnoses_summary_update @ProcedureId;

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

EXEC DropIfExist 'TR_UpperGIAbnoOesophagitis_Insert', 'TR';
GO

CREATE TRIGGER TR_UpperGIAbnoOesophagitis_Insert
ON ERS_UpperGIAbnoOesophagitis
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @SuspectedCandida VARCHAR(10), @OesophagitisOther VARCHAR(10), @OesophagitisReflux VARCHAR(10)
	SELECT @site_id=SiteId, 
			@SuspectedCandida	= (CASE WHEN SuspectedCandida = 1 THEN 'True' ELSE 'False' END),
			@OesophagitisOther	= (CASE WHEN (MucosalAppearance > 1 OR Other = 1) THEN 'True' ELSE 'False' END),
			@OesophagitisReflux	= (CASE WHEN (Reflux = 1) THEN 'True' ELSE 'False' END)
	FROM INSERTED

	EXEC abnormalities_oesophagitis_summary_update @site_id
	EXEC diagnoses_control_save @site_id , 'D27P1', @SuspectedCandida		-- 'Candida'
	EXEC diagnoses_control_save @site_id , 'D33P1', @OesophagitisOther		-- 'OesophagitisOther'
	EXEC diagnoses_control_save @site_id , 'D36P1', @OesophagitisReflux		-- 'OesophagitisReflux'
	EXEC sites_summary_update @site_id
GO
----------------------------------------------------------------------------------------------------------------------------------------------------

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
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

IF @ProcedureType=1   --Gastroscopy
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
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Oesophagus' AND Value = 'True' AND MatrixCode <>'OesophagusNormal' )
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OesophagusNormal') UPDATE [ERS_Diagnoses] SET Value ='False' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OesophagusNormal'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal') UPDATE [ERS_Diagnoses] SET Value ='False' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Oesophagus' AND Value = 'False' AND MatrixCode = 'OesophagusNormal')
			UPDATE [ERS_Diagnoses] SET Value ='True' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OesophagusNormal'
		ELSE IF NOT EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Oesophagus' AND MatrixCode = 'OesophagusNormal')
			INSERT INTO [ERS_Diagnoses] (ProcedureId, MatrixCode, Value, Region) VALUES (@ProcedureID, 'OesophagusNormal', 'True', 'Oesophagus')
	END


	/*STOMACH REGION*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Stomach' AND Value ='True' AND MatrixCode <>'StomachNormal' )
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'StomachNormal')  UPDATE [ERS_Diagnoses] SET Value ='False' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'StomachNormal'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal')  UPDATE [ERS_Diagnoses] SET Value ='False' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Stomach' AND Value = 'False' AND MatrixCode = 'StomachNormal')
			UPDATE [ERS_Diagnoses] SET Value ='True' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'StomachNormal'
		ELSE IF NOT EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Stomach' AND MatrixCode = 'StomachNormal')
			INSERT INTO [ERS_Diagnoses] (ProcedureId, MatrixCode, Value, Region) VALUES (@ProcedureID, 'StomachNormal', 'True', 'Stomach')
	END


	/*DUODENUM REGION*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND Value ='True' AND MatrixCode <>'DuodenumNormal' )
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'DuodenumNormal')  UPDATE [ERS_Diagnoses] SET Value ='False' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'DuodenumNormal'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal')   UPDATE [ERS_Diagnoses] SET Value ='False' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND Value = 'False' AND MatrixCode = 'DuodenumNormal')
			UPDATE [ERS_Diagnoses] SET Value ='True' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'DuodenumNormal'
		ELSE IF NOT EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND MatrixCode = 'DuodenumNormal')
			INSERT INTO [ERS_Diagnoses] (ProcedureId, MatrixCode, Value, Region) VALUES (@ProcedureID, 'DuodenumNormal', 'True', 'Duodenum')
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
----------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_PAges WHERE AppPageName = 'products_gastro_otherdata_ogd_postprocedualdata_aspx')
BEGIN	


INSERT INTO dbo.ERS_Pages
(
    PageId,
    PageName,
    PageAlias,
    AppPageName,
    GroupId,
    PageURL
)
VALUES
(
    316, -- PageId - smallint
    N'PostProcedualData', -- PageName - nvarchar
    N'', -- PageAlias - nvarchar
    N'products_gastro_otherdata_ogd_postprocedualdata_aspx', -- AppPageName - nvarchar
    5, -- GroupId - tinyint
    N''
)
END
ELSE
BEGIN
UPDATE ERS_Pages SET groupid = 5 where AppPageName = 'products_gastro_otherdata_ogd_postprocedualdata_aspx'
END	
----------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'AdverseEventsNone' AND Object_ID = Object_ID(N'ERS_UpperGIQA'))
	ALTER TABLE ERS_UpperGIQA ADD AdverseEventsNone BIT NOT NULL CONSTRAINT [DF_UpperGIQA_AdverseEventsNone] DEFAULT 0

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'AdverseEventsNone' AND Object_ID = Object_ID(N'ERSAudit.ERS_UpperGIQA_Audit'))
	ALTER TABLE ERSAudit.ERS_UpperGIQA_Audit ADD AdverseEventsNone BIT NOT NULL CONSTRAINT [DF_UpperGIQA_Audit_AdverseEventsNone] DEFAULT 0
----------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name IN( N'EPlanNGTubeInsertion',N'EPlanNGTubeRemoval') AND Object_ID = Object_ID(N'ERS_UpperGIIndications'))
	ALTER TABLE dbo.ERS_UpperGIIndications ADD EPlanNGTubeInsertion BIT, EPlanNGTubeRemoval BIT

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name IN( N'EPlanNGTubeInsertion',N'EPlanNGTubeRemoval') AND Object_ID = Object_ID(N'ERSAudit.ERS_UpperGIIndications_Audit'))
	ALTER TABLE ERSAudit.ERS_UpperGIIndications_Audit ADD EPlanNGTubeInsertion BIT, EPlanNGTubeRemoval BIT

----------------------------------------------------------------------------------------------------------------------------------------------------


SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'ogd_indications_save', 'S';
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
			ColonAlterBowelHabit,
			ColonRectalBleeding,
			ColonAnaemia,
			ColonAnaemiaType,	
			ColonAbnormalCTScan,
			ColonAbnormalSigmoidoscopy,
			ColonAbnormalBariumEnema,
			ColonAbdominalMass,
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
			@ColonAlterBowelHabit,
			@ColonRectalBleeding,
			@ColonAnaemia,
			@ColonAnaemiaType,
			@ColonAbnormalCTScan,
			@ColonAbnormalSigmoidoscopy,
			@ColonAbnormalBariumEnema,
			@ColonAbdominalMass,
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
			ColonAlterBowelHabit = @ColonAlterBowelHabit,
			ColonRectalBleeding = @ColonRectalBleeding,
			ColonAnaemia = @ColonAnaemia,
			ColonAnaemiaType = @ColonAnaemiaType,
			ColonAbnormalCTScan = @ColonAbnormalCTScan,
			ColonAbnormalSigmoidoscopy = @ColonAbnormalSigmoidoscopy,
			ColonAbnormalBariumEnema  = @ColonAbnormalBariumEnema,
			ColonAbdominalMass = @ColonAbdominalMass,
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
----------------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'OGD_Indications_Select', 'S';
GO

CREATE PROCEDURE [dbo].[OGD_Indications_Select]
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
		[ColonAlterBowelHabit],
		[ColonRectalBleeding],
		[ColonAnaemia],
		[ColonAnaemiaType],
		[ColonAbnormalCTScan],
		[ColonAbnormalSigmoidoscopy],
		[ColonAbnormalBariumEnema],
		[ColonAbdominalMass],
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

----------------------------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
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
			  @EPlanNGTubeRemoval bit

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
			  @EPlanNGTubeRemoval = EPlanNGTubeRemoval
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
              IF @summary <> '' SET @summary = @summary + '. <br />Following up surgery: ' + @SurgeryFollowUpText
              ELSE SET @summary = @summary + 'Following up surgery: ' + @SurgeryFollowUpText


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
              ELSE SET @summary = @summary + '. <br />Following up disease/procedure: ' + @summaryTemp
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

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
