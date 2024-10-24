
--------------------------------------------------------------------------------------------------------------------
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

	IF @siteNo = 0
		SET @site_no_ch = ''
	ELSE
	BEGIN
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
IF NOT EXISTS (SELECT 1 FROM ERS_MenuMap WHERE PageId = 253)
	INSERT INTO [dbo].[ERS_MenuMap] ([ParentID],[NodeName],[MenuCategory],[MenuUrl],[isViewer],[isDemoVersion],[PageID],[Suppressed])
	Select (SELECT MapId FROM ers_MenuMap WHERE NodeName = 'Admin Utilities'), 'Rooms', 'Configure', '~/Products/Options/Scheduler/Rooms.aspx', 1, 0, 253,0


IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'RoomId' AND Object_ID = Object_ID(N'ERS_ImagePort'))
	ALTER TABLE ERS_ImagePort ADD RoomId INT NULL 
GO

IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ERSAudit' AND TABLE_NAME = 'ERS_ImagePort_Audit'))
	IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'RoomId' AND Object_ID = Object_ID(N'ERSAudit.ERS_ImagePort_Audit'))
		ALTER TABLE ERSAudit.ERS_ImagePort_Audit ADD RoomId INT NULL 
GO

--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC DropIfExist 'procedure_summary_update','S';
GO

CREATE PROCEDURE [dbo].[procedure_summary_update]
(
	@ProcedureId INT
)
AS

SET NOCOUNT ON

DECLARE @summaryWhole VARCHAR(MAX)=''
DECLARE @summaryWholeWithHyperLinks VARCHAR(MAX)=''
DECLARE @procType INT
DECLARE @Region VARCHAR(150)
DECLARE @ResectedColonId INT
DECLARE @OperatingHospitalID TINYINT

BEGIN TRANSACTION

BEGIN TRY

	SELECT @ProcType=ProcedureType, @ResectedColonId=ResectedColonNo FROM ERS_Procedures WHERE ProcedureId = @ProcedureId
	SELECT @OperatingHospitalID = OperatingHospitalID FROM ERS_Procedures WHERE ProcedureId = @ProcedureId

	-- 'SiteNo is set to -77 for sites By Distance (Col & Sig only)
    SELECT CASE WHEN SiteNo = -77 THEN 
						CASE WHEN YCoordinate IS NULL OR YCoordinate=0 THEN 'At ' + CONVERT(VARCHAR,XCoordinate) + ' cm from anus'
						ELSE ('Starting at ' + CONVERT(VARCHAR,XCoordinate) + ' extending to ' + CONVERT(VARCHAR,YCoordinate) + ' cm from anus' ) END  + SPACE(400)
			ELSE 'Site ' + dbo.fnGetSiteTitle(SiteNo, @OperatingHospitalID) + ':'  + SPACE(400) END AS SiteName,

			CASE AntPos
				WHEN 1 THEN 'Anterior '
				WHEN 2 THEN 'Posterior '
				ELSE ''
			END +
			CASE 
				WHEN SiteNo = -77 THEN '' 
				WHEN AreaNo > 0 THEN dbo.fnSetAreaDescription(@ProcedureId, AreaNo, @ResectedColonId)
				WHEN ISNULL(@ResectedColonId,0) > 0  AND
						 EXISTS (SELECT 1 FROM ERS_Regions r 
								JOIN ERS_ResectedColonRegions rcr ON r.RegionId = rcr.RegionId
								WHERE r.RegionId = s.RegionId
								AND rcr.ResectedColonId = @ResectedColonId) THEN 'anastomosis'
				ELSE LOWER(ISNULL((SELECT CASE WHEN @ResectedColonId IN (7,6) AND LOWER(Region) = 'terminal ileum' THEN 'non-terminal ileum' WHEN @ResectedColonId = 9 AND LOWER(Region) = 'terminal ileum' THEN 'ileal pouch' ELSE Region END FROM ERS_Regions r WHERE r.RegionId = s.RegionId),''))
			END AS SiteDesc,

            CASE WHEN ISNULL(SiteSummary, '') <> '' THEN SiteSummary END AS FullSummaryAbnormalities,
            CASE WHEN ISNULL(SiteSummarySpecimens, '') <> '' THEN SiteSummarySpecimens END AS FullSummarySepcimens,
            CASE WHEN ISNULL(SiteSummaryTherapeutics, '') <> '' THEN SiteSummaryTherapeutics END AS FullSummaryTherapeutics,
            CASE WHEN ISNULL(SiteSummaryWithLinks, '') <> '' THEN SiteSummaryWithLinks END AS FullSummaryAbnormalitiesWithLinks,
            CASE WHEN ISNULL(SiteSummarySpecimensWithLinks, '') <> '' THEN SiteSummarySpecimensWithLinks END AS FullSummarySepcimensWithLinks,
            CASE WHEN ISNULL(SiteSummaryTherapeuticsWithLinks, '') <> '' THEN SiteSummaryTherapeuticsWithLinks END AS FullSummaryTherapeuticsWithLinks,
			CASE WHEN SiteNo = -77 THEN ISNULL(XCoordinate,0) + 5000 ELSE SiteNo END AS OrderBy
    INTO #Sites
    FROM ERS_Sites s
    WHERE ProcedureId = @ProcedureId 
    ORDER BY SiteNo
    --AND ISNULL(SiteSummary, '') <> ''

	UPDATE #Sites SET SiteName = '<b style="color:#606060;">' + RTRIM(SiteName) + ' ' + dbo.fnFirstLetterUpper(SiteDesc) +'</b> '
    --select * from #sites

    SELECT 
            CASE WHEN (FullSummaryAbnormalities is not null or FullSummarySepcimens is not null or FullSummaryTherapeutics is not null)
                    THEN SiteName + ISNULL(FullSummaryAbnormalities, '') + ISNULL(FullSummaryTherapeutics, '') + ISNULL(FullSummarySepcimens, '')
            END AS mysummary,
            CASE WHEN (FullSummaryAbnormalitiesWithLinks is not null or FullSummarySepcimensWithLinks is not null or FullSummaryTherapeuticsWithLinks is not null)
                    THEN SiteName + ISNULL(FullSummaryAbnormalitiesWithLinks, '') + ISNULL(FullSummaryTherapeuticsWithLinks, '') + ISNULL(FullSummarySepcimensWithLinks, '')
            END AS mysummaryWithLinks,
			OrderBy
    INTO #Sites2
    FROM #Sites

    --select * from #Sites2

    SELECT @summaryWhole = COALESCE (
                        --CASE WHEN @summaryWhole = '' THEN ISNULL(mysummary, '')
                        --ELSE 
                        @summaryWhole + CASE WHEN @summaryWhole <> '' THEN '<br />' END
                        --END
                    ,'') + mysummary,
                    @summaryWholeWithHyperLinks = COALESCE (
                        --CASE WHEN @@summaryWholeWithHyperLinks = '' THEN ISNULL(mysummaryWithLinks, '')
                        --ELSE 
                        @summaryWholeWithHyperLinks + CASE WHEN @summaryWholeWithHyperLinks <> '' THEN '<br />' END
                        --END
                    ,'') + mysummaryWithLinks
    FROM #Sites2
    where mysummary is not null
    order by OrderBy
    --SELECT @summaryWhole, @summaryWholeWithHyperLinks 

    --EXTENT OF INTUBATION
    IF @procType = 3 OR @procType = 4 
            BEGIN
            DECLARE @tSummary varchar(5000) = ''
            --DECLARE @lSummary varchar(5000) = ''
            --DECLARE @BowelPrepSettings bit
            --DECLARE @smry varchar(5000) = ''

            DECLARE @oBPrep varchar(4000) = ISNULL((SELECT ISNULL([Summary],'') FROM [ERS_BowelPreparation] WHERE [ProcedureID] = @ProcedureId AND [BowelPrepSettings]=0),'')
            DECLARE @oExtent  varchar(4000) = ISNULL((SELECT ISNULL([Summary], '') FROM  ERS_ColonExtentOfIntubation WHERE ProcedureId = @ProcedureId),'')
            DECLARE @oComplications varchar(4000) = ISNULL((SELECT ISNULL(ComplicationsSummary,'') FROM ERS_UpperGIQA WHERE ProcedureId = @ProcedureId),'')
              
            IF @oBPrep <> '' AND @oBPrep IS NOT NULL SET  @tSummary = @tSummary + @oBPrep + '</br>'
            IF @oExtent <> '' SET  @tSummary = @tSummary + @oExtent + '</br>'
            IF @oComplications <> '' SET  @tSummary = @tSummary + @oComplications + '</br>'

            SET @summaryWhole = @tSummary + @summaryWhole
            SET @summaryWholeWithHyperLinks = @tSummary + @summaryWholeWithHyperLinks

            --SELECT @BowelPrepSettings = [BowelPrepSettings], @smry = [Summary] FROM [ERS_BowelPreparation] WHERE [ProcedureID] = @ProcedureId
            --IF @BowelPrepSettings = 0 AND @smry IS NOT NULL AND @smry <> '' SET @tSummary = @tSummary + @smry + '<br/>'
            --SET @tSummary =@tSummary +  ISNULL((SELECT ISNULL([Summary], '') FROM  ERS_ColonExtentOfIntubation WHERE ProcedureId = @ProcedureId),'')
            --IF @tSummary <> '' 
            --BEGIN
            --   SET @summaryWhole = @tSummary + '</br>' + @summaryWhole
            --   SET @summaryWholeWithHyperLinks = @tSummary + '</br>' + @summaryWholeWithHyperLinks 
            --END
            END
    ELSE
            BEGIN
			DECLARE @iVisualisation varchar(5000) = ISNULL((SELECT ISNULL(summary,'') FROM ERS_Visualisation WHERE ProcedureId = @ProcedureId),'')
            DECLARE @iExtent  varchar(5000)= ISNULL((SELECT ISNULL(summary,'') FROM ERS_UpperGIExtentOfIntubation WHERE ProcedureId = @ProcedureId),'')
            DECLARE @iNormalDiag varchar(1000) = ISNULL((SELECT CASE WHEN EXISTS(SELECT 1 FROM ERS_Diagnoses WHERE ProcedureID=@ProcedureId AND MatrixCode='OverallNormal' AND Value='True') THEN 'The whole upper gastro-intestinal track was normal' ELSE '' END),'')
            DECLARE @iComplications varchar(4000) = ISNULL((SELECT ISNULL(ComplicationsSummary,'') FROM ERS_UpperGIQA WHERE ProcedureId = @ProcedureId),'')
			DECLARE @PapillaryAnatomySummary varchar(4000)  = ISNULL((SELECT Summary FROM ERS_ERCPPapillaryAnatomy WHERE ProcedureId = @ProcedureId),'')
            DECLARE @tSumm varchar(5000) = ''
			IF @iVisualisation IS NOT NULL AND @iVisualisation<>'' SET @tSumm = @tSumm + @iVisualisation +'</br>'
			IF @iExtent IS NOT NULL AND  @iExtent <> '' SET  @tSumm = @tSumm + @iExtent + '.</br>'
			IF @iNormalDiag IS NOT NULL AND @iNormalDiag <> '' SET  @tSumm = @tSumm + @iNormalDiag + '.</br>'
			IF @iComplications IS NOT NULL AND @iComplications <> '' SET  @tSumm = @tSumm + @iComplications + '.</br>'
			IF @PapillaryAnatomySummary <> '' SET  @tSumm = @tSumm + @PapillaryAnatomySummary + '.</br>'
            SET @summaryWhole = @tSumm +@summaryWhole
            SET @summaryWholeWithHyperLinks = @tSumm + @summaryWholeWithHyperLinks
    END

    UPDATE ERS_ProceduresReporting
    SET Summary = @summaryWhole,
            SummaryWithLinks = @summaryWholeWithHyperLinks
            --PP_MainReportBody = @summaryAbnormalities,
            --PP_SpecimenTaken = @summarySpecimens,
            --PP_Therapies = @summaryTherapeutics
    WHERE
            ProcedureId = @ProcedureId

    DROP TABLE #Sites
    DROP TABLE #Sites2
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

EXEC DropIfExist 'sites_summary_update','S';
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
		ELSE IF @TableName IN ('ERS_ERCPAbnoDuct', 'ERS_ERCPAbnoParenchyma', 'ERS_ERCPAbnoAppearance', 'ERS_ERCPAbnoDiverticulum') SET @fldNone = 'Normal'
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
EXEC DropIfExist 'otherdata_ogd_diagnoses_save','S';
GO

CREATE PROCEDURE [dbo].[otherdata_ogd_diagnoses_save]
(
	@ProcedureID INT,
	@OverallNormal BIT,
    @OesophagusNormal BIT,
    @OesophagusNotEntered BIT,
    @OesoList VARCHAR(1500),
    @StomachNotEntered BIT,
    @StomachNormal BIT,
    @stomachList VARCHAR(1500),
    @DuodenumNotEntered BIT,
    @Duodenum2ndPartNotEntered BIT,
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
		SELECT @ProcedureId, 'OesophagusNotEntered', CONVERT(VARCHAR(MAX),@OesophagusNotEntered), 'Oesophagus', 1 WHERE @OesophagusNotEntered = 1 
		UNION
		SELECT @ProcedureId, 'OesophagusNormal', 'True', 'Oesophagus', 1 WHERE @OesophagusNormal = 1 
		UNION
		SELECT @ProcedureId, 'OesophagusNormal', 'False', 'Oesophagus', 1 WHERE @OesophagusNormal = 0 --must set a false flag as ogd_diagnoses_summary_update will set region to normal if no entry
		--UNION
		--SELECT @ProcedureId, 'OesophagusOtherDiagnosis', CONVERT(VARCHAR(MAX),@OesophagusOtherDiagnosis), 'Oesophagus', 1 WHERE ISNULL(@OesophagusOtherDiagnosis,'') <> '' 
		UNION
		SELECT @ProcedureId, 'StomachNotEntered', 'True', 'Stomach', 1 WHERE @StomachNotEntered = 1 
		UNION
		SELECT @ProcedureId, 'StomachNormal', 'True', 'Stomach', 1 WHERE @StomachNormal = 1 
		UNION
		SELECT @ProcedureId, 'StomachNormal', 'False', 'Stomach', 1 WHERE @StomachNormal = 0 --must set a false flag as ogd_diagnoses_summary_update will set region to normal if no entry
		--UNION
		--SELECT @ProcedureId, 'StomachOtherDiagnosis', CONVERT(VARCHAR(MAX),@StomachOtherDiagnosis), 'Stomach', 1 WHERE ISNULL(@StomachOtherDiagnosis,'') <> '' 
		UNION
		SELECT @ProcedureId, 'DuodenumNotEntered', 'True', 'Duodenum', 1 WHERE @DuodenumNotEntered = 1 
		UNION
		SELECT @ProcedureId, 'DuodenumNormal', 'True', 'Duodenum', 1 WHERE @DuodenumNormal = 1 
		UNION
		SELECT @ProcedureId, 'DuodenumNormal', 'False', 'Duodenum', 1 WHERE @DuodenumNormal = 0 --must set a false flag as ogd_diagnoses_summary_update will set region to normal if no entry
		--UNION
		--SELECT @ProcedureId, 'DuodenumOtherDiagnosis', CONVERT(VARCHAR(MAX),@DuodenumOtherDiagnosis), 'Duodenum', 1 WHERE ISNULL(@DuodenumOtherDiagnosis,'') <> '' 
		UNION
		SELECT @ProcedureId, 'Duodenum2ndPartNotEntered', 'True', 'Duodenum', 1 
					WHERE ISNULL(@Duodenum2ndPartNotEntered,'') <> '' AND ISNULL(@DuodenumNotEntered,0) = 0 --AND ISNULL(@DuodenumNormal,0) = 0

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



--------------------------------------------------------------------------------------------------------------------
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

IF @ProcedureType = 1   --Gastroscopy
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
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'sites_summary_update','S';
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
		ELSE IF @TableName IN ('ERS_ERCPAbnoDuct', 'ERS_ERCPAbnoParenchyma', 'ERS_ERCPAbnoAppearance', 'ERS_ERCPAbnoDiverticulum') SET @fldNone = 'Normal'
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
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'ColonIndicationSurveillance' AND Object_ID = Object_ID(N'ERS_UpperGIIndications'))
	ALTER TABLE ERS_UpperGIIndications ADD ColonIndicationSurveillance BIT NOT NULL CONSTRAINT [DF_UpperGIIndications_Surveillance] DEFAULT 0

IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'ColonIndicationSurveillance' AND Object_ID = Object_ID(N'ERSAudit.ERS_UpperGIIndications_Audit'))
	ALTER TABLE ERSAudit.ERS_UpperGIIndications_Audit ADD ColonIndicationSurveillance BIT NOT NULL CONSTRAINT [DF_UpperGIIndications_Surveillance_Audit] DEFAULT 0

--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'NationalBowelScopeScreening' AND Object_ID = Object_ID(N'ERS_UpperGIIndications'))
	ALTER TABLE dbo.ERS_UpperGIIndications ADD NationalBowelScopeScreening BIT NOT NULL CONSTRAINT [DF_UpperGIIndications_NationalBowelScopeScreening] DEFAULT 0

IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'NationalBowelScopeScreening' AND Object_ID = Object_ID(N'ERSAudit.ERS_UpperGIIndications_Audit'))
	ALTER TABLE ERSAudit.ERS_UpperGIIndications_Audit ADD NationalBowelScopeScreening BIT NOT NULL CONSTRAINT [DF_UpperGIIndications_NationalBowelScopeScreening_Audit] DEFAULT 0

--------------------------------------------------------------------------------------------------------------------

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
	@ColonIndicationSurveillance bit,
	@ColonAlterBowelHabit int,
	@NationalBowelScopeScreening bit,
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
			ColonIndicationSurveillance,
			ColonAlterBowelHabit,
			NationalBowelScopeScreening,
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
			@ColonIndicationSurveillance,
			@ColonAlterBowelHabit,
			@NationalBowelScopeScreening,
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
			ColonIndicationSurveillance = @ColonIndicationSurveillance,
			ColonAlterBowelHabit = @ColonAlterBowelHabit,
			NationalBowelScopeScreening = @NationalBowelScopeScreening,
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

--------------------------------------------------------------------------------------------------------------------
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
		[ColonIndicationSurveillance],
		[ColonAlterBowelHabit],
		[NationalBowelScopeScreening],
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


--------------------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------------------
----Change time of procedure on Lab Request Form
---------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC dbo.DropIfExist 'printreport_patient_info_select', 'S';
GO

CREATE PROCEDURE [dbo].[printreport_patient_info_select]
(
	@ProcedureId INT,
	@EpisodeNo INT = 0,
       @PatientComboId VARCHAR(30) = NULL,
       @ProcedureType INT
)
AS

SET NOCOUNT ON

IF @ProcedureId IS NOT NULL AND @ProcedureId > 0
BEGIN

	DECLARE @PP_GPAddress VARCHAR(1000), @PP_GPName VARCHAR(1000)
	SELECT @PP_GPAddress =PP_GPAddress, @PP_GPName= PP_GPName FROM dbo.[ERS_ProceduresReporting] WHERE ProcedureId = @ProcedureId;

	SELECT 
			ISNULL(p.Title + ' ', '') + ISNULL(p.Forename1 + ' ', '') + ISNULL(p.Surname, '') AS PatientName, 
			ISNULL(p.Forename1, '') AS Forename,
			ISNULL(p.Surname, '') AS Surname,
			ISNULL(Gender, '') AS Gender,
			ISNULL(p.[DateOfBirth], '') AS DateOfBirth,
			ISNULL(p.[NHSNo],'') AS NHSNo, 
			ISNULL(p.[HospitalNumber], '') as CaseNoteNo, 
			ISNULL(p.[Address],'') AS [Address],
			ISNULL(REPLACE(R.PP_GPName, CHAR(44),'<br />'),'')  AS GPName,
			ISNULL(REPLACE(REPLACE(LTRIM(RTRIM(R.PP_GPAddress)), CHAR(13), '<br/>'), CHAR(10), '<br/>'),'<br/>') AS GPAddress,
			ISNULL(CONVERT(VARCHAR(11),pr.CreatedOn,106) + ' (' + CONVERT(VARCHAR(5),pr.WhenCreated,108) + ')','') AS ProcedureDate, 
			ISNULL(ps.ListItemText, '') AS PatientStatus, 
			ISNULL(oh.HospitalName,'') AS HospitalName,
			ISNULL(oh.ContactNumber,'') AS HospitalPhoneNumber,
			ISNULL(w.ListItemText,'') AS Ward,
			ISNULL(c.ListItemText,'') AS PatientPriority
	FROM 
			ERS_VW_Patients p 
	INNER JOIN 
			ERS_Procedures pr ON p.[PatientId] = pr.PatientId 
	INNER JOIN 
			[ERS_ProceduresReporting] AS R ON pr.ProcedureId=R.ProcedureId
	LEFT JOIN 
			ERS_Lists ps ON pr.PatientStatus = ps.ListItemNo AND ps.ListDescription = 'Patient Status'
	LEFT JOIN 
			ERS_Lists w ON pr.Ward = w.ListItemNo AND w.ListDescription = 'Ward'
	LEFT JOIN 
			ERS_Lists c ON pr.CategoryListId = c.ListItemNo AND c.ListDescription = 'Procedure Category'
	INNER JOIN 
			ERS_OperatingHospitals oh ON pr.OperatingHospitalID = oh.OperatingHospitalId
	WHERE 
			pr.ProcedureId = @ProcedureId 
END

ELSE
BEGIN

       DECLARE @TableName VARCHAR(100) = (SELECT dbo.fnGetUGI_tablename(@ProcedureType,'procedure') 
										FROM [Episode]  
										WHERE CHARINDEX('1', [Status]) BETWEEN 1 AND 12 
										AND [Patient No] = @PatientComboId 
										AND [Episode No] = @EpisodeNo)

	DECLARE @SQL NVARCHAR(MAX) = 'DECLARE @HospId INT, @PP_RepDateAndTime VARCHAR(100), @PP_PatAddress VARCHAR(100), @PP_GP VARCHAR(1000), @HospName VARCHAR(50) '
	SET @SQL = @SQL + ' SELECT @HospId = [Operating Hospital ID], @PP_RepDateAndTime = [PP_RepDateAndTime], @PP_PatAddress = [PP_PatAddress], @PP_GP= ISNULL(PP_GP ,'''') FROM '
						+ @TableName +'  WHERE [Episode No] = ' + cast(@EpisodeNo as varchar(50))  
       
	SET @SQL = @SQL + ' SELECT @HospName = Name FROM [Operating Hospital] WHERE ID = @HospId '

	SET @SQL = @sql +  N'SELECT 
			ISNULL(p.Title,'''') + '' '' + ISNULL(p.Forename, '''') + '' '' + p.Surname AS PatientName, 
			ISNULL(p.Forename, '''') AS Forename,
			ISNULL(p.Surname, '''') AS Surname,
			ISNULL(Gender, '''') AS Gender,
			ISNULL([Date of Birth], '''') AS DateOfBirth, 
			ISNULL([NHS No],'''') AS NHSNo, 
			ISNULL([Case note no], '''') AS CaseNoteNo, 
			--ISNULL(REPLACE(REPLACE(p.[Address], CHAR(13),''), CHAR(10),''<br />''), '''') +  ISNULL(REPLACE(REPLACE(p.[Post code], CHAR(13),''''), CHAR(10),''''), '''') AS [Address],
			ISNULL(@PP_PatAddress,'''') AS [Address], 
			'''' AS GPName, --ISNULL(p.[GP Name], '''') AS GPName, 
			ISNULL(@PP_GP, '''') AS GPAddress, --ISNULL(p.[GP Address], '''') AS GPAddress,
			--LEFT(CONVERT(VARCHAR(30), e.[Procedure time], 113), 17) AS ProcedureDate, 
			--FORMAT(e.[Episode date], ''dd MMMM yyyy'', ''en-GB'') + FORMAT(e.[Procedure time], '' (HH:mm:ss)'', ''en-GB'') AS ProcedureDate, 
			--CONVERT(VARCHAR(11),e.[Episode date],106) + '' ('' + CONVERT(VARCHAR(5),e.[Procedure time],108) + '')'' AS ProcedureDate, 
			ISNULL(@PP_RepDateAndTime,'''') AS ProcedureDate, 
			ISNULL(ps.[List item text], '''') AS PatientStatus, 
			--ISNULL(p.Hospitals, '''') AS HospitalName,
			ISNULL(@HospName ,'''') AS HospitalName,
			'''' AS HospitalPhoneNumber,
			ISNULL(w.[List item text], '''') AS Ward
	FROM 
			Patient p 
	INNER JOIN
			Episode e ON p.[Combo ID] = e.[Patient No]
	LEFT JOIN 
			Lists ps ON p.[Patient Status 1] = ps.[List item no] AND ps.[List description] = ''PatientStatus''
	LEFT JOIN 
			Lists w ON p.Ward = w.[List item no] AND w.[List description] = ''Ward''
	WHERE 
			p.[Combo ID] = ''' + @PatientComboId + ''' AND
			e.[Episode No] = ' + CAST(@EpisodeNo AS VARCHAR(10))

	EXEC sp_executesql @SQL
END

GO
--------------------------------------------------------------------------------------------------------------------
--SCOPE admin page
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_Pages WHERE PageId = 126)
	INSERT [dbo].[ERS_Pages] ([PageId], [PageName], [AppPageName], [GroupId], [PageAlias],[PageURL]) VALUES 
	(126,'Admin Utilities -> Scopes','products_options_scopes_aspx',3,'Scopes','~/products/options/scopes.aspx')

IF NOT EXISTS (SELECT 1 FROM ERS_Pages WHERE PageId = 127)
	INSERT [dbo].[ERS_Pages] ([PageId], [PageName], [AppPageName], [GroupId], [PageAlias],[PageURL]) VALUES 
	(127,'Admin Utilities -> Edit Scopes','products_options_editscopes_aspx',3,'Edit Scopes','~/products/options/editscopes.aspx')

IF NOT EXISTS(SELECT 1 FROM ERS_PagesByRole WHERE PageId = 126)
BEGIN
	INSERT INTO ERS_PagesByRole ([RoleId], [PageId], [AccessLevel])
	SELECT  (SELECT TOP 1 RoleID FROM ERS_Roles WHERE RoleName = 'Unisoft'), 126, 9
	UNION
	SELECT  (SELECT TOP 1 RoleID FROM ERS_Roles WHERE RoleName = 'Unisoft'), 127, 9

	--Populate table ERS_PagesByRole for 'System Administrators'
	INSERT INTO ERS_PagesByRole ([RoleId], [PageId], [AccessLevel])
	SELECT  (SELECT TOP 1 RoleID FROM ERS_Roles WHERE RoleName = 'System Administrators'), 126, 9
	UNION
	SELECT  (SELECT TOP 1 RoleID FROM ERS_Roles WHERE RoleName = 'System Administrators'), 127, 9

	INSERT INTO [dbo].[ERS_MenuMap] ([ParentID],[NodeName],[MenuCategory],[MenuUrl],[isViewer],[isDemoVersion],[PageID],[Suppressed])
	Select (SELECT MapId FROM ers_MenuMap WHERE NodeName = 'Admin Utilities'), 
		'Scopes', 'Configure', '~/Products/Options/Scopes.aspx', 1, 0, 126,0
END	
GO
--------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('ERS_Scopes') AND type = 'U')
BEGIN
	CREATE TABLE [dbo].[ERS_Scopes](
		[ScopeId] [int] IDENTITY(1,1) NOT NULL,
		[ScopeName] [nvarchar](255) NULL,
		[RoomID] [int] NULL,
		[AllProcedureTypes] [bit] NOT NULL CONSTRAINT DF_Scopes_AllProcedureTypes DEFAULT 0,
		[HospitalId] [int] NULL,
		[Suppressed] [bit] NOT NULL CONSTRAINT DF_Scopes_Suppressed DEFAULT 0,
		[SuppressDate] [datetime] NULL,
		[WhoUpdatedId] [int] NULL Default 0,
		[WhoCreatedId] [int] NULL Default 0,
		[WhenCreated] [datetime] NULL Default GetDate(),
		[WhenUpdated] [datetime] NULL Default GetDate(),
		CONSTRAINT [PK_Scopes] PRIMARY KEY CLUSTERED ([ScopeId] ASC)	
	) ON [PRIMARY]
END
GO
--------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('ERS_ScopeProcedures') AND type = 'U')
BEGIN
	CREATE TABLE [dbo].[ERS_ScopeProcedures](
		[ScopeProcId] [int] IDENTITY(1,1) NOT NULL,
		[ScopeId] [int] NULL,
		[ProcedureTypeId] [tinyint] NULL,
		[WhoUpdatedId] [int] NULL Default 0,
		[WhoCreatedId] [int] NULL Default 0,
		[WhenCreated] [datetime] NULL Default GetDate(),
		[WhenUpdated] [datetime] NULL Default GetDate(),
		CONSTRAINT [PK_ScopeProcedures] PRIMARY KEY CLUSTERED ([ScopeProcId])
	) ON [PRIMARY]
END
GO

--------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM [ERSAudit].[tblTablesToBeAudited] WHERE TableSchema='dbo' AND TableName='ERS_Scopes')
BEGIN
	INSERT INTO [ERSAudit].[tblTablesToBeAudited] SELECT 'dbo', 'ERS_Scopes'
END

IF NOT EXISTS (SELECT 1 FROM [ERSAudit].[tblTablesToBeAudited] WHERE TableSchema='dbo' AND TableName='ERS_ScopeProcedures')
BEGIN
	INSERT INTO [ERSAudit].[tblTablesToBeAudited] SELECT 'dbo', 'ERS_ScopeProcedures'
END

--------------------------------------------------------------------------------------------------------------------
------------------------------------- Create Proc scopes_select.sql-------------------------------------
--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'scopes_select','S';
GO

CREATE PROCEDURE [dbo].[scopes_select]
(
	@FieldValue VARCHAR(200)
	,@Suppressed TINYINT = -1
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
	DECLARE @SQL NVARCHAR(MAX) = ''

	IF @FieldValue IS NULL SET @FieldValue = ''
	
	SET @SQL = CASE WHEN @FieldValue <> ''
					THEN '(s.[ScopeName] LIKE (''%'		+ @FieldValue + '%'')) '
					ELSE ''
				END
	IF @Suppressed IS NOT NULL
	BEGIN
		IF @SQL <> '' SET @SQL = @SQL + ' AND '
		SET @SQL = @SQL + ' s.[Suppressed] = ' + CONVERT(VARCHAR, @Suppressed) 
	END

	IF @SQL <> '' SET @SQL = ' WHERE ' + @SQL  

	SET @SQL = '
		SELECT  ScopeId, ScopeName, AllProcedureTypes
		  ,(SELECT COUNT(ScopeProcId)
					FROM ERS_ScopeProcedures p 
					WHERE p.ScopeId = s.ScopeId) 
				AS Procedures
		  ,HospitalId
		  ,(SELECT HospitalName FROM ERS_OperatingHospitals h WHERE h.OperatingHospitalId = s.HospitalId) AS HospitalName
		  ,(CASE [Suppressed] WHEN 1 THEN ''Yes'' ELSE ''No'' END) as Suppressed, SuppressDate
	  FROM ERS_Scopes s
	' + @SQL 

	EXEC sp_executesql @sql 
	
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


--------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'fnHtmlEncode', 'F';
GO

CREATE FUNCTION fnHtmlEncode
(
    @UnEncoded as varchar(500)
)
RETURNS varchar(500)
AS
BEGIN
  DECLARE @Encoded as varchar(500)

  SELECT @Encoded = 
  Replace(
    Replace(
      Replace(@UnEncoded,'&','&amp;'),
    '<', '&lt;'),
  '>', '&gt;')

  RETURN @Encoded
END
GO
--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'set_default_values','S';
GO

CREATE PROCEDURE [dbo].[set_default_values]
(
	@fromPage		varchar(20) = '',
	@UserID			int = NULL,
	@ListConsultant	int = NULL,
	@Endoscopist1	int = NULL,
	@Endoscopist2	int = NULL,
	@Nurse1			int = NULL,
	@Nurse2			int = NULL,
	@Nurse3			int = NULL,
	@PatientType	tinyint = NULL,
	@ProductType	tinyint = NULL,
	@ProcedureType	tinyint = NULL,
	@ListType		tinyint = NULL,
	@Endo1Role		tinyint = NULL,
	@Endo2Role		tinyint = NULL,
	@Premedication	varchar(500) = NULL
	)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
			
	IF NOT EXISTS (SELECT 1 FROM [ERS_Default] WHERE UserID = @UserID)
	BEGIN
		INSERT INTO ERS_Default (
			UserID,
			ListConsultant,
			Endoscopist1,
			Endoscopist2,
			Nurse1,
			Nurse2,
			Nurse3,
			PatientType,
			ProductType,
			ProcedureType,
			ListType,
			Endo1Role,
			Endo2Role, 
			Premedication,
			WhoCreatedId,
			WhenCreated) 
		VALUES (
			@UserID,
			@ListConsultant,
			@Endoscopist1,
			@Endoscopist2,
			@Nurse1,
			@Nurse2,
			@Nurse3,
			@PatientType,
			@ProductType,
			@ProcedureType,
			@ListType,
			@Endo1Role,
			@Endo2Role,
			@Premedication,
			@UserID,
			GETDATE())
	END
	ELSE
	BEGIN
		IF @fromPage = 'Premedication'
		BEGIN
			UPDATE ERS_Default
			SET Premedication = @Premedication
			WHERE UserID = @UserID
		END
		ELSE IF @fromPage = 'CreateProcedure'
		BEGIN
			UPDATE 
				ERS_Default
			SET 
				ListConsultant = @ListConsultant,
				Endoscopist1 = @Endoscopist1,
				Endoscopist2 = @Endoscopist2,
				Nurse1 = @Nurse1,
				Nurse2 = @Nurse2,
				Nurse3 = @Nurse3,
				PatientType = @PatientType,
				ProductType = @ProductType,
				ProcedureType = @ProcedureType,
				ListType = @ListType,
				Endo1Role = @Endo1Role,
				Endo2Role = @Endo2Role,
				WhoUpdatedId = @UserID,
				WhenUpdated = GETDATE()
			WHERE 
				UserID = @UserID
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

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'sch_rooms_select','S';
GO

CREATE PROCEDURE [dbo].[sch_rooms_select]
(
	@Field VARCHAR(200)
	,@FieldValue VARCHAR(200)
	,@Suppressed TINYINT = -1
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
	DECLARE @SQL NVARCHAR(MAX) = ''

	IF @Field IS NULL SET @Field = ''
	IF @FieldValue IS NULL SET @FieldValue = ''
	
	SET @SQL = CASE WHEN @FieldValue <> '' AND @Field = ''
					THEN '(r.[RoomId]	IN ('		+ @FieldValue + ')) '
					ELSE ''
				END
	IF @Suppressed IS NOT NULL
	BEGIN
		IF @SQL <> '' SET @SQL = @SQL + ' AND '
		SET @SQL = @SQL + ' r.[Suppressed] = ' + CONVERT(VARCHAR, @Suppressed) 
	END

	IF @SQL <> '' SET @SQL = ' WHERE ' + @SQL  

	SET @SQL = '
		SELECT  RoomId, RoomName, AllProcedureTypes
		  ,(SELECT COUNT(RoomProcId)
					FROM ERS_SCH_RoomProcedures p 
					WHERE p.RoomId = r.RoomId) + (CASE OtherInvestigations WHEN 1 THEN 1 ELSE 0 END)
				AS Procedures
		  ,HospitalId
		  ,(SELECT HospitalName FROM ERS_OperatingHospitals h WHERE h.OperatingHospitalId = r.HospitalId) AS HospitalName
		  ,CASE WHEN ISNULL(Suppressed, 0) = 0
					THEN ''No''
				ELSE ''Yes''
				END AS Suppressed
		  , SuppressDate
	  FROM ERS_SCH_Rooms r

	' + @SQL 

	EXEC sp_executesql @sql 

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

ALTER TABLE		[ERSAudit].[ERS_XMLMap_Audit]
ALTER COLUMN	[FieldName] [varchar](50) NULL
GO

update [ERS_XMLMap]
set OrderID = 8 
where FieldName = 'PP_AdviceAndComments';
  
update [ERS_XMLMap]
set OrderID = 7
where FieldName = 'PP_Followup';

GO

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
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


       SELECT s.SiteNo, Case @procType WHEN 1 THEN ISNULL(m.Area,'') ELSE '' END AS RegionSection, r.Region, sp.*
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
              LOWER(RegionSection) + ' brushings for cytology from (' + LOWER(@siteTitle) + ') ' + Region
       FROM #specimens 
       WHERE SiteId = @siteId AND BrushCytology > 0
              
       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Histology', 
              CONVERT(VARCHAR, @siteId) + 'BiopsyHistology', 
              CONVERT(VARCHAR,BiopsyQtyHistology) + ' ' + LOWER(RegionSection) + CASE WHEN BiopsyQtyHistology > 1 THEN ' biopsies' ELSE ' biopsy' END + ' for histology from (' + LOWER(@siteTitle) + ') ' + Region
       FROM #specimens 
       WHERE SiteId = @siteId AND BiopsyQtyHistology > 0

       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Microbiology', 
              CONVERT(VARCHAR, @siteId) + 'BiopsyMicrobiology', 
              CONVERT(VARCHAR,BiopsyQtyMicrobiology) + ' ' + LOWER(RegionSection) + CASE WHEN BiopsyQtyMicrobiology > 1 THEN ' biopsies' ELSE ' biopsy' END + ' for microbiology from (' + LOWER(@siteTitle) + ') ' + Region
       FROM #specimens 
       WHERE SiteId = @siteId AND Biopsy = 1 AND BiopsyQtyMicrobiology > 0
              
       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Virology', 
              CONVERT(VARCHAR, @siteId) + 'BiopsyVirology', 
              CONVERT(VARCHAR,BiopsyQtyVirology) + ' ' + LOWER(RegionSection) + CASE WHEN BiopsyQtyVirology > 1 THEN ' biopsies' ELSE ' biopsy' END + ' for virology from (' + LOWER(@siteTitle) + ') ' + Region
       FROM #specimens 
       WHERE SiteId = @siteId AND Biopsy = 1 AND BiopsyQtyVirology > 0
       
       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Histology', 
              CONVERT(VARCHAR, @siteId) + 'Polypectomy', 
              CONVERT(VARCHAR,PolypectomyQty) + ' ' + LOWER(RegionSection) + CASE WHEN PolypectomyQty > 1 THEN ' polyps' ELSE ' polyp' END + ' for histology from (' + LOWER(@siteTitle) + ') ' + Region
       FROM #specimens 
       WHERE SiteId = @siteId AND Polypectomy = 1 AND PolypectomyQty > 0

       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Histology', 
              CONVERT(VARCHAR, @siteId) + 'HotBiopsy', 
              LOWER(RegionSection) + ' hot biopsy for histology from (' + LOWER(@siteTitle) + ' ) ' + Region + CASE WHEN HotBiopsyDistance > 0 THEN ' at ' + CONVERT(VARCHAR, HotBiopsyDistance) + 'cm' ELSE '' END 
       FROM #specimens 
       WHERE SiteId = @siteId AND HotBiopsy = 1
       
       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Histology', 
              CONVERT(VARCHAR, @siteId) + 'NeedleAspirateHistology', 
              LOWER(RegionSection) + ' needle aspirate for histology from (' + LOWER(@siteTitle) + ') ' + Region
       FROM #specimens 
       WHERE SiteId = @siteId AND NeedleAspirate = 1 AND NeedleAspirateHistology = 1

       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Histology', 
              CONVERT(VARCHAR, @siteId) + 'NeedleAspirateMicrobiology', 
              LOWER(RegionSection) + ' needle aspirate for microbiology from (' + LOWER(@siteTitle) + ') ' + Region
       FROM #specimens 
       WHERE SiteId = @siteId AND NeedleAspirate = 1 AND NeedleAspirateMicrobiology = 1

       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Histology', 
              CONVERT(VARCHAR, @siteId) + 'NeedleAspirateVirology', 
              LOWER(RegionSection) + ' needle aspirate for virology from (' + LOWER(@siteTitle) + ') ' + Region
       FROM #specimens 
       WHERE SiteId = @siteId AND NeedleAspirate = 1 AND NeedleAspirateVirology = 1

       INSERT INTO @SpecimensSummary
       SELECT 
              @siteId, 
              'Microbiology', 
              CONVERT(VARCHAR, @siteId) + 'GastricWashing', 
              'gastric washing for microbiology from (' + LOWER(@siteTitle) + ') ' + Region
       FROM #specimens 
       WHERE SiteId = @siteId AND GastricWashing = 1

       FETCH NEXT FROM Site_Cursor INTO @siteId, @siteNo
END
CLOSE Site_Cursor;
DEALLOCATE Site_Cursor;

IF OBJECT_ID('tempdb..#specimens') IS NOT NULL DROP TABLE #specimens 
SELECT * FROM @SpecimensSummary 

GO

----------------------------------------------------------------------------

ALTER TABLE [dbo].[ERS_ErrorLog]
ALTER COLUMN [ErrorMessage] Varchar(MAX)

ALTER TABLE [dbo].[ERS_ErrorLog]
ALTER COLUMN [ErrorDescription] Varchar(MAX)

GO

---------------------------------------------------------------------------

  Insert into ERS_Scopes (ScopeName, AllProcedureTypes, HospitalId, Suppressed)
  Select ListItemText, 0, 1, 0
  from ERS_Lists
  where ListDescription like 'Instrument%'
  and ListItemText not in (Select ScopeName from ERS_Scopes)

  insert into ERS_ScopeProcedures (ScopeID, ProcedureTypeID)
  Select s.ScopeId, PT.ProcedureTypeId
  from ERS_Scopes s,
   ERS_Lists l, 
   ERS_ProcedureTypes PT
  where PT.ProcedureType = 'Gastroscopy'
  and l.ListDescription = 'Instrument Upper GI'
  and l.ListItemText = s.ScopeName
  and s.ScopeId not in (Select ScopeID from ERS_ScopeProcedures)

  insert into ERS_ScopeProcedures (ScopeID, ProcedureTypeID)
  Select s.ScopeId, PT.ProcedureTypeId
  from ERS_Scopes s,
   ERS_Lists l, 
   ERS_ProcedureTypes PT
  where PT.ProcedureType = 'Thoracoscopy'
  and l.ListDescription = 'Instrument Thoracic'
  and l.ListItemText = s.ScopeName
  and s.ScopeId not in (Select ScopeID from ERS_ScopeProcedures)

  insert into ERS_ScopeProcedures (ScopeID, ProcedureTypeID)
  Select s.ScopeId, PT.ProcedureTypeId
  from ERS_Scopes s,
   ERS_Lists l, 
   ERS_ProcedureTypes PT
  where PT.ProcedureType = 'Ent - Retrograde'
  and l.ListDescription = 'Instrument Retrograde'
  and l.ListItemText = s.ScopeName
  and s.ScopeId not in (Select ScopeID from ERS_ScopeProcedures)

  insert into ERS_ScopeProcedures (ScopeID, ProcedureTypeID)
  Select s.ScopeId, PT.ProcedureTypeId
  from ERS_Scopes s,
   ERS_Lists l, 
   ERS_ProcedureTypes PT
  where PT.ProcedureType = 'ERCP'
  and l.ListDescription = 'Instrument ERCP'
  and l.ListItemText = s.ScopeName
  and s.ScopeId not in (Select ScopeID from ERS_ScopeProcedures)

  insert into ERS_ScopeProcedures (ScopeID, ProcedureTypeID)
  Select s.ScopeId, PT.ProcedureTypeId
  from ERS_Scopes s,
   ERS_Lists l, 
   ERS_ProcedureTypes PT
  where PT.ProcedureType = 'Sigmoidscopy'
  and l.ListDescription = 'Instrument ColonSig'
  and l.ListItemText = s.ScopeName
  and s.ScopeId not in (Select ScopeID from ERS_ScopeProcedures)

  insert into ERS_ScopeProcedures (ScopeID, ProcedureTypeID)
  Select s.ScopeId, PT.ProcedureTypeId
  from ERS_Scopes s,
   ERS_Lists l, 
   ERS_ProcedureTypes PT
  where PT.ProcedureType = 'Ent - Antegrade'
  and l.ListDescription = 'Instrument Antegrade'
  and l.ListItemText = s.ScopeName
  and s.ScopeId not in (Select ScopeID from ERS_ScopeProcedures)


  GO

  ---------------------------------------------------------------------------------
 
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
		SELECT distinct
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
			,CASE WHEN pho.PhotoId IS NULL THEN 0 ELSE 1 END HasPhotos
		FROM 
			ERS_Procedures p
		INNER JOIN 
			ERS_ProcedureTypes pt ON p.ProcedureType = pt.ProcedureTypeId
		INNER JOIN 
			ERS_VW_Patients pa ON p.PatientId = pa.PatientId
		LEFT JOIN ERS_ProceduresReporting AS PR ON p.ProcedureId=PR.ProcedureId
		LEFT JOIN ERS_Photos pho ON p.ProcedureId = pho.ProcedureId
		WHERE 
			p.PatientId = @PatientId
			AND p.IsActive  = @ActiveProceduresOnly
	) AS temptemp



	-- OLD System procedures
	IF @IncludeOldProcs = 1
	BEGIN
	
		DECLARE @PatientComboId VARCHAR(24)
		SELECT @PatientComboId = [Combo ID] FROM Patient p INNER JOIN ERS_VW_Patients v ON p.[Patient No] = v.UGIPatientId WHERE v.PatientId =  @PatientId
	
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

	SELECT * FROM #procs ORDER BY CreatedOn DESC, ModifiedOn DESC

	DROP TABLE #procs

	GO

----------------------------------------------------------------------------------------

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'FriendlyName' AND Object_ID = Object_ID(N'ERS_ImagePort'))
	ALTER TABLE dbo.ERS_ImagePort ADD FriendlyName Varchar(50)

IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ERSAudit' AND TABLE_NAME = 'ERS_ImagePort_Audit'))
	IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'FriendlyName' AND Object_ID = Object_ID(N'ERSAudit.ERS_ImagePort_Audit'))
		ALTER TABLE ERSAudit.ERS_ImagePort_Audit ADD FriendlyName Varchar(50)
GO
EXEC DropIfExist 'trg_ERS_ImagePort_Update','TR';
GO
CREATE TRIGGER [dbo].[trg_ERS_ImagePort_Update] 
							ON [dbo].[ERS_ImagePort] 
							AFTER UPDATE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_ImagePort_Audit] (ImagePortId, tbl.[OperatingHospitalId], tbl.[PortName], tbl.[MacAddress], tbl.[InstrumentId], tbl.[Static], tbl.[PCName], tbl.[IsActive], tbl.[Comments],  LastActionId, ActionDateTime, ActionUserId, FriendlyName)
							SELECT tbl.ImagePortId , tbl.[OperatingHospitalId], tbl.[PortName], tbl.[MacAddress], tbl.[InstrumentId], tbl.[Static], tbl.[PCName], tbl.[IsActive], tbl.[Comments],  2, GETDATE(), i.WhoUpdatedId, tbl.FriendlyName
							FROM deleted tbl INNER JOIN inserted i ON tbl.ImagePortId = i.ImagePortId

GO
EXEC DropIfExist 'trg_ERS_ImagePort_Delete','TR';
GO

CREATE TRIGGER [dbo].[trg_ERS_ImagePort_Delete] 
							ON [dbo].[ERS_ImagePort] 
							AFTER DELETE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_ImagePort_Audit] (ImagePortId, tbl.[OperatingHospitalId], tbl.[PortName], tbl.[MacAddress], tbl.[InstrumentId], tbl.[Static], tbl.[PCName], tbl.[IsActive], tbl.[Comments],  LastActionId, ActionDateTime, ActionUserId, FriendlyName)
							SELECT tbl.ImagePortId , tbl.[OperatingHospitalId], tbl.[PortName], tbl.[MacAddress], tbl.[InstrumentId], tbl.[Static], tbl.[PCName], tbl.[IsActive], tbl.[Comments],  3, GETDATE(), tbl.WhoUpdatedId, tbl.FriendlyName
							FROM deleted tbl

GO
EXEC DropIfExist 'trg_ERS_ImagePort_Insert','TR';
GO

CREATE TRIGGER [dbo].[trg_ERS_ImagePort_Insert] 
							ON [dbo].[ERS_ImagePort] 
							AFTER INSERT
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_ImagePort_Audit] (ImagePortId, tbl.[OperatingHospitalId], tbl.[PortName], tbl.[MacAddress], tbl.[InstrumentId], tbl.[Static], tbl.[PCName], tbl.[IsActive], tbl.[Comments],  LastActionId, ActionDateTime, ActionUserId, FriendlyName)
							SELECT tbl.ImagePortId , tbl.[OperatingHospitalId], tbl.[PortName], tbl.[MacAddress], tbl.[InstrumentId], tbl.[Static], tbl.[PCName], tbl.[IsActive], tbl.[Comments],  1, GETDATE(), tbl.WhoCreatedId, tbl.FriendlyName
							FROM inserted tbl

GO
update ERS_ImagePort
set FriendlyName = r.RoomName
from ERS_SCH_Rooms r
where r.roomid = ERS_ImagePort.RoomID
GO
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------




EXEC DropIfExist 'ogd_PatientCopyTo_save','S';
GO

CREATE PROCEDURE [dbo].[ogd_PatientCopyTo_save]
(
	@ProcedureId INT,
	@CopyToPatient TINYINT,
	@CopyToPatientText NVARCHAR(500),
	@PatientNotCopiedReason NVARCHAR(500),
	@CopyToRefCon BIT,
	@CopyToRefConText NVARCHAR(500),
	@CopyToOther BIT,
	@CopyToOtherText NVARCHAR(500),
	@Salutation NVARCHAR(200)
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
			
	IF NOT EXISTS (SELECT 1 FROM ERS_UpperGIFollowUp WHERE ProcedureId = @ProcedureId)
	BEGIN
		INSERT INTO ERS_UpperGIFollowUp (
			ProcedureId,
			CopyToPatient,
			CopyToPatientText,
			PatientNotCopiedReason,
			CopyToRefCon,
			CopyToRefConText,
			CopyToOther,
			CopyToOtherText,
			Salutation,
			WhenCreated) 
		VALUES (
			@ProcedureId,
			@CopyToPatient,
			@CopyToPatientText,
			@PatientNotCopiedReason,
			@CopyToRefCon,
			@CopyToRefConText,
			@CopyToOther,
			@CopyToOtherText,
			@Salutation,
			GETDATE())
	END
	
	ELSE
	BEGIN
		UPDATE 
			ERS_UpperGIFollowUp
		SET 
			CopyToPatient = @CopyToPatient,
			CopyToPatientText = @CopyToPatientText,
			PatientNotCopiedReason = @PatientNotCopiedReason,
			CopyToRefCon = @CopyToRefCon,
			CopyToRefConText = @CopyToRefConText,
			CopyToOther = @CopyToOther,
			CopyToOtherText = @CopyToOtherText,
			Salutation = @Salutation,
			WhenUpdated = GETDATE()
		WHERE 
			ProcedureId = @ProcedureId
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
----------------------------------------------------------------------------------------


/****** Object:  Trigger [dbo].[TR_UpperGIAbnoAchalasia_Insert]    Script Date: 19/07/2019 11:00:55 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER TRIGGER [dbo].[TR_UpperGIAbnoAchalasia_Insert]
ON [dbo].[ERS_UpperGIAbnoAchalasia]
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @Achalasia VARCHAR(10)
	SELECT @site_id=SiteId,
			@Achalasia = (CASE WHEN (Probable=1 OR Confirmed=1) THEN 'True' ELSE 'False' END)
	FROM INSERTED

	EXEC ogd_kpi_stricture_perforation @site_id --Update perforation text in QA for OGD KPI

	EXEC abnormalities_achalasia_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D66P1', @Achalasia


GO
----------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_diverticulum_save','S'
GO

CREATE PROCEDURE [dbo].[abnormalities_diverticulum_save]
(
	@SiteId INT,
	@None BIT,
	@Pseudodiverticulum BIT,
	@Congenital1stPart BIT,
	@Congenital2ndPart BIT,
	@Other BIT,
	@OtherDesc VARCHAR(150),
	@LoggedInUserId INT
)
AS

SET NOCOUNT ON

DECLARE @proc_id INT
DECLARE @proc_type INT
DECLARE @region_name VARCHAR(100)
DECLARE @identifier VARCHAR(100)

BEGIN TRANSACTION

BEGIN TRY
	SELECT 
		@proc_id = p.ProcedureId,
		@proc_type = p.ProcedureType,
		@region_name = r.Region
	FROM 
		ERS_Sites s
	JOIN 
		ERS_Procedures p ON s.ProcedureId = p.ProcedureId
	INNER JOIN ERS_Regions r ON s.RegionId = r.RegionId
	WHERE 
		SiteId = @SiteId
	
	--Abnormalities for OGD, Antegrade are "Diverticulum/Other"
	SET @identifier = CASE 
							WHEN @proc_type IN (1,8) then 'Diverticulum/Other' 
							WHEN @proc_type IN (2,7) AND LOWER(@region_name) IN ('first part','second part','third part') THEN 'Diverticulum/Other'
							ELSE 'Diverticulum' END
			
	IF NOT EXISTS (SELECT 1 FROM ERS_CommonAbnoDiverticulum WHERE SiteId = @SiteId)
	BEGIN
		INSERT INTO ERS_CommonAbnoDiverticulum (
			SiteId,
			[None],
			Pseudodiverticulum,
			Congenital1stPart,
			Congenital2ndPart,
			Other,
			OtherDesc,
			WhoCreatedId,
			WhenCreated) 
		VALUES (
			@SiteId,
			@None,
			@Pseudodiverticulum,
			@Congenital1stPart,
			@Congenital2ndPart,
			@Other,
			@OtherDesc,
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
			@identifier,
			1)
	END

	ELSE IF (@None = 0 AND @Pseudodiverticulum = 0 AND @Congenital1stPart = 0 AND @Congenital2ndPart = 0 AND @Other = 0)
	BEGIN
		DELETE FROM ERS_CommonAbnoDiverticulum 
		WHERE SiteId = @SiteId

		DELETE FROM ERS_RecordCount 
		WHERE SiteId = @SiteId
		AND Identifier = @identifier
	END
	
	ELSE
	BEGIN
		UPDATE 
			ERS_CommonAbnoDiverticulum
		SET 
			[None] = @None,
			Pseudodiverticulum = @Pseudodiverticulum,
			Congenital1stPart = @Congenital1stPart,
			Congenital2ndPart = @Congenital2ndPart,
			Other = @Other,
			OtherDesc = @OtherDesc,
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

----------------------------------------------------------------------------------------
EXEC DropIfExist 'scopes_select','S'
GO

CREATE PROCEDURE [dbo].[scopes_select]
(
	@FieldValue VARCHAR(200)
	,@Suppressed TINYINT = -1
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
	DECLARE @SQL NVARCHAR(MAX) = ''

	IF @FieldValue IS NULL SET @FieldValue = ''
	
	SET @SQL = CASE WHEN @FieldValue <> ''
					THEN '(s.[ScopeName] LIKE (''%'		+ @FieldValue + '%'')) '
					ELSE ''
				END
	IF @Suppressed IS NOT NULL
	BEGIN
		IF @SQL <> '' SET @SQL = @SQL + ' AND '
		SET @SQL = @SQL + ' s.[Suppressed] = ' + CONVERT(VARCHAR, @Suppressed) 
	END

	IF @SQL <> '' SET @SQL = ' WHERE ' + @SQL  

	SET @SQL = '
		SELECT  ScopeId, ScopeName, AllProcedureTypes
		  ,HospitalId
		  ,(SELECT HospitalName FROM ERS_OperatingHospitals h WHERE h.OperatingHospitalId = s.HospitalId) AS HospitalName
		  ,(CASE [Suppressed] WHEN 1 THEN ''Yes'' ELSE ''No'' END) as Suppressed
		  ,SuppressDate
		  ,CASE WHEN AllProcedureTypes = 1 THEN ''All Procedures'' ELSE (SELECT STUFF((SELECT '', '' + t.ProcedureType FROM ERS_ScopeProcedures ps
				LEFT JOIN ERS_ProcedureTypes t ON t.ProcedureTypeId = ps.ProcedureTypeId
			WHERE s.ScopeId = ps.ScopeId FOR XML PATH('''')), 1, 1, '''')) END AS Procedures
	  FROM ERS_Scopes s
	' + @SQL 

	EXEC sp_executesql @sql 
	
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
----------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_UpperGIAbnoBarrett_Insert','TR';
GO

CREATE TRIGGER [dbo].[TR_UpperGIAbnoBarrett_Insert]
ON [dbo].[ERS_UpperGIAbnoBarrett]
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @Barretts VARCHAR(10)
	SELECT @site_id=SiteId FROM INSERTED

	EXEC abnormalities_Barrett_summary_update @site_id
	EXEC sites_summary_update @site_id

	SELECT @Barretts = (CASE WHEN [None] = 0 THEN 'True' ELSE 'False' END) FROM ERS_UpperGIAbnoBarrett
	WHERE SiteId = @site_id

	EXEC diagnoses_control_save @site_id, 'D23P1', @Barretts  --Barretts

GO
----------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_oesophagitis_summary_update','S'
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
		@OtherTypeOtherDesc = ISNULL(OtherTypeOtherDesc,''),
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
		IF ISNULL((SELECT COUNT(Val) FROM @tmpOeso WHERE ISNULL(VAL,'') <> ''),0) = 1
			SET @withText = ' with '
		ELSE IF ISNULL((SELECT COUNT(Val) FROM @tmpOeso WHERE ISNULL(VAL,'') <> ''),0) <> 0
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
			SET @tmpVal = @tmpVal + ')'

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
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------



