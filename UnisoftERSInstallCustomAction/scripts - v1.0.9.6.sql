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
---------------------------------------------------------------------------------------------------------------------------------

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

	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Oesophagus' AND Value ='True' AND MatrixCode <>'OesophagusNormal' )
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OesophagusNormal') UPDATE [ERS_Diagnoses] SET Value ='False' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OesophagusNormal'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal') UPDATE [ERS_Diagnoses] SET Value ='False' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
	END
	ELSE
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode = 'OesophagusNormal')
			INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region) 
			VALUES (@ProcedureId, 'OesophagusNormal', 'True', 'Oesophagus')
	END

	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Stomach' AND Value ='True' AND MatrixCode <>'StomachNormal' )
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'StomachNormal')  UPDATE [ERS_Diagnoses] SET Value ='False' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'StomachNormal'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal')  UPDATE [ERS_Diagnoses] SET Value ='False' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
	END
	ELSE
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode = 'StomachNormal')
			INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region) 
			VALUES (@ProcedureId, 'StomachNormal', 'True', 'Stomach')
	END

	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND Value ='True' AND MatrixCode <>'DuodenumNormal' )
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'DuodenumNormal')  UPDATE [ERS_Diagnoses] SET Value ='False' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'DuodenumNormal'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal')   UPDATE [ERS_Diagnoses] SET Value ='False' WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
	END
    ELSE
	BEGIN
		IF NOT EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode = 'DuodenumNormal')
			INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region) 
			VALUES (@ProcedureId, 'DuodenumNormal', 'True', 'Duodenum')
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
---------------------------------------------------------------------------------------------------------------------------------
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

			--,[ResectedColonNo]					,[IncludeProcNotes]
			--,[ProcedureNotes]						,[Video]						,[VideoNotes]					,[GPReportText]
			--,[TextEdited]							,[DiagramIncluded]				,[EndoscribeComments]			,[EndoscribePremedication]
			--,[MucosalJunctionAt]					,[NewCardia]					,[AbnoText]						,[PancreasDivisum]
			--,[BiliaryManometry]					,[PancreaticManometry]			,[ExportedToEPR]				,[ForcepType]
			--,[ForcepSerialNo]						,[ConsultantPresent]			,[AccountNo]					,[DNA]
			--,[DNACombined]						,[DNACreatedViaRC]				,[IsDirty]						,[ExportFileName]
			--,[ExportProducedOn]					,[Summary]						,[SummaryWithLinks]				,[PP_Therapies]
			--,[PP_SpecimenTaken]					,[PP_Rx]						,[PP_Followup]					,[PP_AdviceAndComments]
			--,[PP_EndoComments]					,[PP_InstForCareHeading]		,[PP_InstForCare]				,[TPP_MainReportBody]
			--,[TPP_Therapies]						,[TPP_SpecimenTaken]			,[PP_DNA]						,[PP_NPSAalert]
			--,[PP_BBPS]							,[PP_Site_Legend]				,[PP_AdviceAndComments_Initial]	,[PP_Followup_Initial]				
			--,[SurgicalSafetyCheckListCompleted]	,[NEDEnabled]					,[NEDExported]					,[PP_Bowel_Prep]									

	INSERT INTO [dbo].[ERS_Procedures]
           ([ProcedureType]							,[CreatedBy]					,[CreatedOn]					,[ModifiedOn]
			,[PatientId]					        ,[OperatingHospitalID]	        ,[DiagramNumber]				,[ListConsultant]
			,[Endoscopist1]							,[Endoscopist2]					,[Assistant]					,[Nurse1]
			,[Nurse2]								,[Nurse3]						,[Instrument1]					,[Instrument2]
			,[ReferralHospitalNo]					,[ReferralConsultantNo]			,[GPReferralFlag]				,[PatientStatus]
			,[Ward]									,[PatientType]					,[ReferralConsultantSpeciality]	
			,[PatientConsent]						,[GPCode]						,[CategoryListId]				,[EmergencyProcType]				
			,[GPPracticeCode]						,[ListType]						,[Endo1Role]					,[Endo2Role]					
			,[FormerProcedureId]					,[ImagePortId]					,[WhoCreatedId])
		SElECT 
			@ProcedureType							,p.[CreatedBy]					,p.[CreatedOn]					,GETDATE()
			,p.[PatientId]					        ,p.[OperatingHospitalID]	    ,p.[DiagramNumber]				,p.[ListConsultant]
			,p.[Endoscopist1]						,p.[Endoscopist2]				,p.[Assistant]					,p.[Nurse1]
			,p.[Nurse2]								,p.[Nurse3]						,p.[Instrument1]				,p.[Instrument2]
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
			,[PP_RefCons]							,[PP_Endos]						,[PP_Instrument]				,[PP_Premed]
			,[PP_Indic]								,[PP_MainReportBody]			,[PP_Diagnoses]					,[PP_Endo1]						
			,[PP_CCRefCons]							,[PP_CCOther]					,[PP_CCPatient]					,[PP_RepHead]					
			,[PP_RepSubHead]						,[PP_OpHosp]					,[PP_Room_ID]					,[PP_Priority]					
			,[PP_GPName]							,[PP_GPAddress]
			,ProcedureId)
		SElECT 	
			 pr.[PP_PatAddress]						,pr.[PP_RefHosp]				,pr.[PP_CNN]					,pr.[PP_RepDateAndTime]
			,pr.[PP_RepType]						,pr.[PP_GP]						,pr.[PP_PatStatus]				,pr.[PP_Ward]
			,pr.[PP_RefCons]						,pr.[PP_Endos]					,pr.[PP_Instrument]				,pr.[PP_Premed]
			,pr.[PP_Indic]							,pr.[PP_MainReportBody]			,pr.[PP_Diagnoses]				,pr.[PP_Endo1]						
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
		INSERT INTO ERS_RecordCount ([ProcedureId], [SiteId], [Identifier], [RecordCount])
		VALUES (@newProcId, NULL, 'Premed', 1)

		EXEC ogd_premedication_summary_update @newProcId
	END 

	--Copy QA (Management & Sedation/Comfort score)
	INSERT INTO ERS_UpperGIQA (
		[ProcedureId]			,[NoNotes]			,[ReferralLetter]					,[ManagementNone]		,[PulseOximetry]
		,[IVAccess]				,[IVAntibiotics]	,[Oxygenation]						,[OxygenationMethod]	,[OxygenationFlowRate]
		,[ContinuousECG]		,[BP]				,[BPSystolic]						,[BPDiastolic]			,[ManagementOther]
		,[ManagementOtherText]	,[PatSedation]      ,[PatSedationAsleepResponseState]   ,[PatDiscomfortNurse]	,[PatDiscomfortEndo])
	SELECT 
		@newProcId				,[NoNotes]			,[ReferralLetter]					,[ManagementNone]		,[PulseOximetry]
		,[IVAccess]				,[IVAntibiotics]	,[Oxygenation]						,[OxygenationMethod]	,[OxygenationFlowRate]
		,[ContinuousECG]		,[BP]				,[BPSystolic]						,[BPDiastolic]			,[ManagementOther]
		,[ManagementOtherText]	,[PatSedation]      ,[PatSedationAsleepResponseState]   ,[PatDiscomfortNurse]	,[PatDiscomfortEndo]
	FROM ERS_UpperGIQA
	WHERE ProcedureId = @ProcedureID

	--Copy Indications
	INSERT INTO ERS_UpperGIIndications (ProcedureId,Anaemia, AnaemiaType, AbdominalPain, AbnormalCapsuleStudy, AbnormalMRI, AbnormalityOnBarium, ChestPain, ChronicLiverDisease, 
										CoffeeGroundsVomit, Diarrhoea, DrugTrial, Dyspepsia, DyspepsiaAtypical, DyspepsiaUlcerType, Dysphagia, Haematemesis, Melaena, NauseaAndOrVomiting, 
										Odynophagia, PositiveTTG_EMA, RefluxSymptoms, UlcerExclusion, WeightLoss, PreviousHPyloriTest, SerologyTest, SerologyTestResult, BreathTest, BreathTestResult, 
										UreaseTest, UreaseTestResult, StoolAntigenTest, StoolAntigenTestResult, OpenAccess, OtherIndication, ClinicallyImpComments, UrgentTwoWeekReferral, Cancer, 
										WHOStatus, BariatricPreAssessment, BalloonInsertion, BalloonRemoval, SingleBalloonEnteroscopy, DoubleBalloonEnteroscopy, PostBariatricSurgeryAssessment, 
										EUS, GastrostomyInsertion, InsertionOfPHProbe, JejunostomyInsertion, NasoDuodenalTube, OesophagealDilatation, PEGRemoval, PEGReplacement, PushEnteroscopy, 
										SmallBowelBiopsy, StentRemoval, StentInsertion, StentReplacement, EUSRefGuidedFNABiopsy, EUSOesophagealStricture, EUSAssessmentOfSubmucosalLesion, EUSTumourStagingOesophageal, 
										EUSTumourStagingGastric, EUSTumourStagingDuodenal, OtherPlannedProcedure, CoMorbidityNone, Angina, Asthma, COPD, DiabetesMellitus, DiabetesMellitusType, Epilepsy, HemiPostStroke, 
										Hypertension, MI, Obesity, TIA, OtherCoMorbidity, ASAStatus, PotentiallyDamagingDrug, Allergy, AllergyDesc, CurrentMedication, IncludeCurrentRxInReport, SurgeryFollowUpProc, 
										SurgeryFollowUpProcPeriod, SurgeryFollowUpText, DiseaseFollowUpProc, DiseaseFollowUpProcPeriod, BarrettsOesophagus, CoeliacDisease, Dysplasia, Gastritis, Malignancy, OesophagealDilatationFollowUp, 
										OesophagealVarices, Oesophagitis, UlcerHealing, ColonSreeningColonoscopy, ColonBowelCancerScreening, ColonFOBT, ColonAlterBowelHabit, ColonRectalBleeding, ColonAnaemia, ColonAnaemiaType, 
										ColonAbnormalCTScan, ColonAbnormalSigmoidoscopy, ColonAbnormalBariumEnema, ColonAbdominalMass, ColonColonicObstruction, ColonAbdominalPain, ColonAssessment, ColonAssessmentType, ColonSurveillance, 
										ColonFamily, ColonFamilyType, ColonFamilyAdditionalText, ColonCarcinoma, ColonPolyps, ColonDysplasia, ColonMelaena, ColonPolyposisSyndrome, ColonRaisedFaecalCalprotectin, ColonTumourAssessment, ColonWeightLoss)

	SELECT @newProcId,Anaemia, AnaemiaType, AbdominalPain, AbnormalCapsuleStudy, AbnormalMRI, AbnormalityOnBarium, ChestPain, ChronicLiverDisease, 
										CoffeeGroundsVomit, Diarrhoea, DrugTrial, Dyspepsia, DyspepsiaAtypical, DyspepsiaUlcerType, Dysphagia, Haematemesis, Melaena, NauseaAndOrVomiting, 
										Odynophagia, PositiveTTG_EMA, RefluxSymptoms, UlcerExclusion, WeightLoss, PreviousHPyloriTest, SerologyTest, SerologyTestResult, BreathTest, BreathTestResult, 
										UreaseTest, UreaseTestResult, StoolAntigenTest, StoolAntigenTestResult, OpenAccess, OtherIndication, ClinicallyImpComments, UrgentTwoWeekReferral, Cancer, 
										WHOStatus, BariatricPreAssessment, BalloonInsertion, BalloonRemoval, SingleBalloonEnteroscopy, DoubleBalloonEnteroscopy, PostBariatricSurgeryAssessment, 
										EUS, GastrostomyInsertion, InsertionOfPHProbe, JejunostomyInsertion, NasoDuodenalTube, OesophagealDilatation, PEGRemoval, PEGReplacement, PushEnteroscopy, 
										SmallBowelBiopsy, StentRemoval, StentInsertion, StentReplacement, EUSRefGuidedFNABiopsy, EUSOesophagealStricture, EUSAssessmentOfSubmucosalLesion, EUSTumourStagingOesophageal, 
										EUSTumourStagingGastric, EUSTumourStagingDuodenal, OtherPlannedProcedure, CoMorbidityNone, Angina, Asthma, COPD, DiabetesMellitus, DiabetesMellitusType, Epilepsy, HemiPostStroke, 
										Hypertension, MI, Obesity, TIA, OtherCoMorbidity, ASAStatus, PotentiallyDamagingDrug, Allergy, AllergyDesc, CurrentMedication, IncludeCurrentRxInReport, SurgeryFollowUpProc, 
										SurgeryFollowUpProcPeriod, SurgeryFollowUpText, DiseaseFollowUpProc, DiseaseFollowUpProcPeriod, BarrettsOesophagus, CoeliacDisease, Dysplasia, Gastritis, Malignancy, OesophagealDilatationFollowUp, 
										OesophagealVarices, Oesophagitis, UlcerHealing, ColonSreeningColonoscopy, ColonBowelCancerScreening, ColonFOBT, ColonAlterBowelHabit, ColonRectalBleeding, ColonAnaemia, ColonAnaemiaType, 
										ColonAbnormalCTScan, ColonAbnormalSigmoidoscopy, ColonAbnormalBariumEnema, ColonAbdominalMass, ColonColonicObstruction, ColonAbdominalPain, ColonAssessment, ColonAssessmentType, ColonSurveillance, 
										ColonFamily, ColonFamilyType, ColonFamilyAdditionalText, ColonCarcinoma, ColonPolyps, ColonDysplasia, ColonMelaena, ColonPolyposisSyndrome, ColonRaisedFaecalCalprotectin, ColonTumourAssessment, ColonWeightLoss
	FROM ERS_UpperGIIndications
	WHERE ProcedureId = @ProcedureID

	IF @@ROWCOUNT > 0
	BEGIN
		INSERT INTO ERS_RecordCount ([ProcedureId], [SiteId], [Identifier], [RecordCount])
		VALUES (@newProcId, NULL, 'QA', 1)

		EXEC ogd_qa_summary_update @newProcId
	END 

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

---------------------------------------------------------------------------------------------------------------------------------
UPDATE ERS_Lists SET ListItemText = 'Inadequate' WHERE ListItemText = 'Poor' AND ListDescription = 'Bowel_Preperation_Quality'
GO

---------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT 1 FROM ERS_Lists WHERE ListDescription = 'Bowel_Preperation_Quality' AND ListItemText = 'No Bowel Preperation')
	INSERT INTO ERS_Lists (ListDescription, ListItemNo, ListItemText, ListMainId)
	VALUES ('Bowel_Preperation_Quality', 0, 'No Bowel Preperation', 4)
GO
---------------------------------------------------------------------------------------------------------------------------------

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
		--SELECT @ProcedureId, 'StomachNotEntered', CONVERT(VARCHAR(MAX),@StomachNotEntered), 'Stomach', 1 WHERE @StomachNotEntered = 1 
		--UNION
		SELECT @ProcedureId, 'StomachNormal', 'True', 'Stomach', 1 WHERE @StomachNormal = 1 
		--UNION
		--SELECT @ProcedureId, 'StomachOtherDiagnosis', CONVERT(VARCHAR(MAX),@StomachOtherDiagnosis), 'Stomach', 1 WHERE ISNULL(@StomachOtherDiagnosis,'') <> '' 
		UNION
		--SELECT @ProcedureId, 'DuodenumNotEntered', CONVERT(VARCHAR(MAX),@DuodenumNotEntered), 'Duodenum', 1 WHERE @DuodenumNotEntered = 1 
		--UNION
		SELECT @ProcedureId, 'DuodenumNormal', 'True', 'Duodenum', 1 WHERE @DuodenumNormal = 1 
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

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
