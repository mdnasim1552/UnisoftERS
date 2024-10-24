--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'LockingHours' AND Object_ID = Object_ID(N'ERS_SystemConfig'))
	ALTER TABLE dbo.ERS_SystemConfig ADD LockingHours INT
GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'PancreaticTumour' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE ERS_ERCPAbnoDuct ADD PancreaticTumour BIT NOT NULL CONSTRAINT DF_ERCPAbnoDuct_PancreaticTumour DEFAULT 0
GO
--------------------------------------------------------------------------------------------------------------------------------------------

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
								CASE WHEN  CAST(CONVERT(DATE,DATEADD(hour,s.LockingHours, p.CreatedOn)) as varchar(50)) <= GETDATE() THEN 1 ELSE 0 END
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
--------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'DuctInjury' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD DuctInjury VARCHAR(500)
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'StentOcclusion' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD StentOcclusion VARCHAR(500)
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Other' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD Other VARCHAR(500)
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Diverticulum' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD Diverticulum VARCHAR(500) NOT NULL CONSTRAINT [DF_ERCPAbnoDuct_Diverticulum] DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'GallBladderTumor' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD GallBladderTumor VARCHAR(500) NOT NULL CONSTRAINT [DF_ERCPAbnoDuct_GallBladderTumor] DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'CalculousObstruction' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD CalculousObstruction BIT NOT NULL CONSTRAINT DF_ERCPAbnoDuct_CalculousObstruction DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'AnastomicStricture' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD AnastomicStricture BIT NOT NULL CONSTRAINT DF_ERCPAbnoDuct_AnastomicStricture DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'MirizziSyndrome' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD MirizziSyndrome BIT NOT NULL CONSTRAINT DF_ERCPAbnoDuct_MirizziSyndrome DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'SclerosingCholangitis' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD SclerosingCholangitis BIT NOT NULL CONSTRAINT DF_ERCPAbnoDuct_SclerosingCholangitis DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Occlusion' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD Occlusion BIT NOT NULL CONSTRAINT DF_ERCPAbnoDuct_Occlusion DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'BiliaryLeak' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD BiliaryLeak BIT NOT NULL CONSTRAINT DF_ERCPAbnoDuct_BiliaryLeak DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'PreviousSurgery' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD PreviousSurgery BIT NOT NULL CONSTRAINT DF_ERCPAbnoDuct_PreviousSurgery DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Pseudocyst' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDuct'))
	ALTER TABLE dbo.ERS_ERCPAbnoDuct ADD Pseudocyst VARCHAR(500) NOT NULL CONSTRAINT [DF_ERCPAbnoDuct_Pseudocyst] DEFAULT 0
GO

IF EXISTS(SELECT * FROM sys.columns WHERE Object_ID = Object_ID(N'ERSAudit.ERS_ERCPAbnoDuct_Audit'))
	DROP TABLE ERSAudit.ERS_ERCPAbnoDuct_Audit
GO

IF EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoDuct')
	DELETE FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoDuct'
GO

IF NOT EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoDuct')
	INSERT INTO ERSAudit.tblTablesToBeAudited (TableSchema, TableName) VALUES ('dbo', 'ERS_ERCPAbnoDuct')
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ERCPAbnoDuct', 'TR'
GO

CREATE TRIGGER [dbo].[TR_ERCPAbnoDuct]
ON [dbo].[ERS_ERCPAbnoDuct]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, 
			@Dilated VARCHAR(10) = 'False', 
			@DilatedType VARCHAR(10) = 'False', 
			@Fistula VARCHAR(10) = 'False', @Stones VARCHAR(10) = 'False',
			@Cysts VARCHAR(10) = 'False', @Scelerosing VARCHAR(10) = 'False',
			@CystsCommunicating VARCHAR(10) = 'False', @CystsNonCommunicating VARCHAR(10) = 'False',
			@CystsCholedochal VARCHAR(10) = 'False',
			@TumourCystadenoma VARCHAR(10) = 'False', @TumourProbablyMalignant VARCHAR(10) = 'False',
			@Cholangiocarcinoma VARCHAR(10) = 'False', @ExternalCompression VARCHAR(10) = 'False',
			@Polycystic VARCHAR(10) = 'False', @HydatidCyst VARCHAR(10) = 'False',
			@LiverAbscess VARCHAR(10) = 'False', @PostCholecystectomy VARCHAR(10) = 'False',
			@Stricture VARCHAR(10) = 'False', @StrictureProbably VARCHAR(10) = 'False',
			@StrictureProbablyBenign VARCHAR(10) = 'False', @StrictureMalignant VARCHAR(10) = 'False', 
			@DuctInjury VARCHAR(10) = 'False', @StentOcclusion VARCHAR(10) = 'False',
			@GallBladderTumor VARCHAR(10) = 'False', @Mirizzi VARCHAR(10) = 'False',
			@AnastomicStricture VARCHAR(10) = 'False', @PancreaticTumour VARCHAR(10) = 'False',
			@Occlusion VARCHAR(10) = 'False', @PreviousSurgery VARCHAR(10) = 'False',
			@BiliaryLeak VARCHAR(10) = 'False', @CalculousObstruction VARCHAR(10) = 'False',
			@Tumour VARCHAR(10) = 'False', @Diverticulum VARCHAR(10) = 'False',
			@Action CHAR(1) = 'I', @Area varchar(50), @Region varchar(50)

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Dilated = (CASE WHEN Dilated = 1 THEN 'True' ELSE 'False' END),
				@DilatedType = (CASE WHEN DilatedType = 1 THEN 'True' ELSE 'False' END),   --DilatedType -> No obvious cause
				@PostCholecystectomy = (CASE WHEN DilatedType = 2 THEN 'True' ELSE 'False' END),   --DilatedType -> Post cholecystectomy
				@Stricture = (CASE WHEN Stricture = 1  THEN 'True' ELSE 'False' END),
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
				@GallBladderTumor = (CASE WHEN GallBladderTumor = 1 THEN 'True' ELSE 'False' END),
				@AnastomicStricture = (CASE WHEN AnastomicStricture = 1 THEN 'True' ELSE 'False' END),
				@Occlusion = (CASE WHEN Occlusion = 1 THEN 'True' ELSE 'False' END),
				@Mirizzi = (CASE WHEN MirizziSyndrome = 1 THEN 'True' ELSE 'False' END),
				@PancreaticTumour = (CASE WHEN PancreaticTumour = 1 THEN 'True' ELSE 'False' END),
				@BiliaryLeak = (CASE WHEN BiliaryLeak = 1 THEN 'True' ELSE 'False' END),
				@PreviousSurgery = (CASE WHEN PreviousSurgery = 1 THEN 'True' ELSE 'False' END),
				@Diverticulum = (CASE WHEN Diverticulum = 1 THEN 'True' ELSE 'False' END),
				@CalculousObstruction = (CASE WHEN CalculousObstruction = 1 THEN 'True' ELSE 'False' END),
				@Scelerosing = (CASE WHEN SclerosingCholangitis = 1 THEN 'True' ELSE 'False' END)




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
			
		EXEC diagnoses_control_save @site_id, 'D101P2', @CystsCommunicating		-- Communicating
		EXEC diagnoses_control_save @site_id, 'D100P2', @CystsNonCommunicating	-- NonCommunicating
		EXEC diagnoses_control_save @site_id, 'D105P2', @CystsCholedochal		-- Pseudocyst
		EXEC diagnoses_control_save @site_id, 'D72P2',	@Stones					-- 'Pancreatic stone'
		EXEC diagnoses_control_save @site_id, 'D130P2',	@TumourCystadenoma		-- 'Cystadenoma'

		EXEC diagnoses_control_save @site_id, 'D125P2',	@TumourProbablyMalignant-- 'Probably malignant'
		EXEC diagnoses_control_save @site_id, 'D390P2', @StrictureProbably			-- 'Extrahepatic probable'
		EXEC diagnoses_control_save @site_id, 'D391P2', @StrictureProbablyBenign	-- 'Benign'


		EXEC diagnoses_control_save @site_id, 'D69P2',	@DuctInjury				-- 'Duct injury'
		EXEC diagnoses_control_save @site_id, 'D74P2',	@StentOcclusion			-- 'Stent occlusion'D140P2
		EXEC diagnoses_control_save @site_id, 'D91P2',	@PancreaticTumour

		EXEC diagnoses_control_save @site_id, 'D373P2',	@BiliaryLeak
		EXEC diagnoses_control_save @site_id, 'D374P2',	@Occlusion
		EXEC diagnoses_control_save @site_id, 'D375P2',	@PreviousSurgery

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


		EXEC diagnoses_control_save @site_id, 'D276P2', @Dilated			-- 'Dilatation'   

		EXEC diagnoses_control_save @site_id, 'D193P2', @DuctInjury					-- 'Duct injury'
		EXEC diagnoses_control_save @site_id, 'D195P2', @StentOcclusion				-- 'Stent occlusion'

		EXEC diagnoses_control_save @site_id, 'D145P2',	@Fistula				-- 'Fistula'

		--Diagnosis polycystic liver disease if patient has suspected polycystic liver disease set in duct abnos...
		EXEC diagnoses_control_save @site_id, 'D200P2', @Polycystic				--Polycystic liver disease

		EXEC diagnoses_control_save @site_id, 'D235P2', @HydatidCyst			--Hydatid Cyst
		EXEC diagnoses_control_save @site_id, 'D240P2', @LiverAbscess			--Liver abscess
		EXEC diagnoses_control_save @site_id, 'D140P2',	@AnastomicStricture		-- 'Stent occlusion'
		EXEC diagnoses_control_save @site_id, 'D150P2',	@Occlusion				-- 'Occlusion'
		EXEC diagnoses_control_save @site_id, 'D121P2',	@Stricture				-- 'Intrahepatic stricture'
		EXEC diagnoses_control_save @site_id, 'D364P2',	@Cysts				-- 'Intrahepatic stricture'
		EXEC diagnoses_control_save @site_id, 'D365P2',	@PreviousSurgery

		EXEC diagnoses_control_save @site_id, 'D225P2', @Tumour	
		EXEC diagnoses_control_save @site_id, 'D367P2', @StrictureProbablyBenign	-- 'Benign'
		EXEC diagnoses_control_save @site_id, 'D366P2', @TumourProbablyMalignant	-- 'Malignant'
		EXEC diagnoses_control_save @site_id, 'D368P2', @StrictureProbably			-- 'Extrahepatic probable'

		IF LOWER(@Region) NOT IN ('right hepatic lobe', 'left hepatic lobe')
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D160P2',	@Mirizzi		
		END
		
		IF LOWER(@Region) NOT IN ('right hepatic ducts', 'left hepatic ducts')
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D192P2',	@Stones				-- 'Intrahepatic stricture'
			EXEC diagnoses_control_save @site_id, 'D205P2',	@Scelerosing				-- 'Intrahepatic stricture'

		END

		IF LOWER(@Region) IN ('right hepatic ducts', 'left hepatic ducts')
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D205P2',	@Scelerosing				-- 'Intrahepatic stricture'
			EXEC diagnoses_control_save @site_id, 'D372P2',	@BiliaryLeak
			
		END
	END

------ DIAGNOSES FOR EXTRAHEPATIC SITES i.e below the bifurcation --------------------------------------------------
	ELSE IF LOWER(@Region) IN ('gall bladder', 'common bile duct', 'common hepatic duct', 'cystic duct', 'bifurcation') --'GallBladder and the regions close to it
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D275P2', @Dilated				-- 'Dilated duct'
		EXEC diagnoses_control_save @site_id, 'D270P2', @CystsCholedochal		-- 'Choledochal cyst'
		EXEC diagnoses_control_save @site_id, 'D300P2', @PostCholecystectomy	-- 'Post cholecystectomy'
		EXEC diagnoses_control_save @site_id, 'D290P2', @Stricture				-- 'Stricture'
		
		EXEC diagnoses_control_save @site_id, 'D378P2', @Tumour	
		EXEC diagnoses_control_save @site_id, 'D330P2', @StrictureProbablyBenign	-- 'Benign'
		EXEC diagnoses_control_save @site_id, 'D335P2', @TumourProbablyMalignant	-- 'Malignant'
		EXEC diagnoses_control_save @site_id, 'D325P2', @StrictureProbably			-- 'Extrahepatic probable'
		EXEC diagnoses_control_save @site_id, 'D193P2', @DuctInjury					-- 'Duct injury'
		EXEC diagnoses_control_save @site_id, 'D195P2', @StentOcclusion				-- 'Stent occlusion'

		EXEC diagnoses_control_save @site_id, 'D145P2',	@Fistula					-- 'Fistula'
		EXEC diagnoses_control_save @site_id, 'D140P2',	@AnastomicStricture		-- 'Stent occlusion'
		EXEC diagnoses_control_save @site_id, 'D150P2',	@Occlusion				-- 'Occlusion'
		EXEC diagnoses_control_save @site_id, 'D364P2',	@Cysts				-- 'Intrahepatic stricture'
		EXEC diagnoses_control_save @site_id, 'D365P2',	@PreviousSurgery


		
		IF LOWER(@Region) IN ('common bile duct', 'common hepatic duct', 'bifurcation')
			EXEC diagnoses_control_save @site_id, 'D160P2',	@Mirizzi		
			EXEC diagnoses_control_save @site_id, 'D372P2',	@BiliaryLeak

	END


	--Biliary : stone abnormalities
	IF LOWER(@Region) IN ('gall bladder') --Stones in Gall Bladder
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D180P2',	@GallBladderTumor			-- 'Gall bladder tumor'
		EXEC diagnoses_control_save @site_id, 'D189P2', @Stones		-- Diagnosis : Stones in Gall Bladder
		EXEC diagnoses_control_save @site_id, 'D382P2', @Diverticulum		-- Diagnosis : Stones in Gall Bladder
	END 
	ELSE IF LOWER(@Region) IN ('common bile duct', 'cystic duct')	-- Stones in cystic duct and/or common bile duct
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D191P2', @Stones		-- Diagnosis : Stones in the bile duct		

		--EXEC diagnoses_control_save @site_id, 'D378P2', @Tumour	
		--EXEC diagnoses_control_save @site_id, 'D121P2',	@Stricture				-- 'Intrahepatic stricture'
		--EXEC diagnoses_control_save @site_id, 'D330P2', @StrictureProbablyBenign	-- 'Benign'
		--EXEC diagnoses_control_save @site_id, 'D335P2', @TumourProbablyMalignant	-- 'Malignant'
		--EXEC diagnoses_control_save @site_id, 'D325P2', @StrictureProbably			-- 'Extrahepatic probable'
	END
	ELSE IF LOWER(@Region) IN ('common hepatic duct', 'bifurcation', 'right intra-hepatic ducts', 'right hepatic ducts', 
								'left intra-hepatic ducts', 'left hepatic ducts') --'Stones in the common hepatic duct and/or bifurcation and/or left hepatic duct and/or left intra hepatic duct and/or right hepatic duct and/or right intra hepatic duct
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D192P2', @Stones		-- Diagnosis : Stones in the hepatic duct	
	END

	IF LOWER(@Region) IN ('cystic duct')
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D175P2',	@CalculousObstruction
	END	

GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_duct_save', 'S'
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
	@Diverticulum BIT,
	@AnastomicStricture BIT,
	@MirizziSyndrome BIT,
	@SclerosingCholangitis BIT,
	@CalculousObstruction BIT,
	@Occlusion BIT,
	@BiliaryLeak BIT,
	@PreviousSurgery BIT,
	@PancreaticTumour BIT,
	@Other VARCHAR(500),
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
	
	
	IF (@Normal=0 AND @Dilated=0 AND @Stricture=0 AND @Fistula=0 AND @Stones=0 AND @Cysts=0 AND @DuctInjury=0 AND @StentOcclusion=0 AND @GallBladderTumor = 0 AND @Diverticulum = 0 AND @AnastomicStricture = 0 AND 
	@MirizziSyndrome = 0 AND @SclerosingCholangitis = 0 AND @CalculousObstruction = 0 AND @Occlusion = 0 AND @BiliaryLeak = 0 AND @PreviousSurgery = 0 AND @PancreaticTumour = 0 AND ISNULL(@Other,'') = '')
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
		   ,[Diverticulum]
		   ,[AnastomicStricture]
		   ,[MirizziSyndrome]
		   ,[SclerosingCholangitis]
		   ,[CalculousObstruction]
		   ,[Occlusion]
		   ,[BiliaryLeak]
		   ,[PreviousSurgery]
		   ,[PancreaticTumour]
		   ,[Other]
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
			@Diverticulum,
			@AnastomicStricture,
			@MirizziSyndrome,
			@SclerosingCholangitis,
			@CalculousObstruction,
			@Occlusion,
			@BiliaryLeak,
			@PreviousSurgery,
			@PancreaticTumour,
			@Other,
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
			Diverticulum = @Diverticulum,
			AnastomicStricture = @AnastomicStricture,
			MirizziSyndrome = @MirizziSyndrome,
			SclerosingCholangitis = @SclerosingCholangitis,
			CalculousObstruction = @CalculousObstruction,
			Occlusion = @Occlusion,
			BiliaryLeak = @BiliaryLeak,
			PreviousSurgery = @PreviousSurgery,
			PancreaticTumour = @PancreaticTumour,
			Other = @Other,
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
EXEC DropIfExist 'abnormalities_duct_select', 'S'
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
	,[Diverticulum]
	,[AnastomicStricture]
	,[MirizziSyndrome]
	,[SclerosingCholangitis]
	,[CalculousObstruction]
	,[Occlusion]
	,[BiliaryLeak]
	,[PreviousSurgery]
	,[PancreaticTumour]
	,[Other]
    ,[Summary]
FROM
	ERS_ERCPAbnoDuct
WHERE 
	SiteId = @SiteId

GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_duct_summary_update', 'S'
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
		@StentOcclusion BIT,
		@GallBladderTumor BIT,
		@Diverticulum BIT,
		@AnastomicStricture BIT,
		@MirizziSyndrome BIT,
		@SclerosingCholangitis BIT,
		@CalculousObstruction BIT,
		@Occlusion BIT,
		@BiliaryLeak BIT,
		@PreviousSurgery BIT,
		@PancreaticTumour BIT,
		@Other VARCHAR(MAX)

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
		@StentOcclusion = StentOcclusion,
		@GallBladderTumor = GallBladderTumor,
		@Diverticulum = Diverticulum,
		@AnastomicStricture = AnastomicStricture,
		@MirizziSyndrome= MirizziSyndrome,
		@SclerosingCholangitis = SclerosingCholangitis,
		@CalculousObstruction = CalculousObstruction,
		@Occlusion = Occlusion,
		@BiliaryLeak = BiliaryLeak,
		@PreviousSurgery = PreviousSurgery,
		@PancreaticTumour = PancreaticTumour,
		@Other = Other
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
				IF @tempsummary = '' SET @tempsummary = 'length ' + dbo.fnRemoveDecTrailingZeroes(@StrictureLen) + 'mm'
				ELSE SET @tempsummary = @tempsummary + ' length ' + dbo.fnRemoveDecTrailingZeroes(@StrictureLen) + 'mm'
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
					SET @tempsummary = REPLACE(@tempsummary, '$$', CONVERT(VARCHAR, @StonesSize) + 'mm ')
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
				SET @tempsummary = @tempsummary + ' (largest ' + dbo.fnRemoveDecTrailingZeroes(@StonesSize) + 'mm)'
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
			
			
			
			IF @tempsummary2 <> ''
				SET @tempsummary = @tempsummary + ' ' + @tempsummary2
				
			IF @CystsDiameter > 0
				IF @CystsQty = 1
					SET @tempsummary = @tempsummary + ' ' + dbo.fnRemoveDecTrailingZeroes(@CystsDiameter) + 'mm'
				ELSE
					SET @tempsummary = @tempsummary + ' (largest ' + dbo.fnRemoveDecTrailingZeroes(@CystsDiameter) + 'mm)'
			
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
			SET @tempsummary = @tempsummary + ' Duct injury'
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @StentOcclusion = 1
		BEGIN
			SET @tempsummary = '' 
			SET @tempsummary = @tempsummary + ' Stent occlusion'
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @Diverticulum = 1 
		BEGIN
			SET @tempsummary = '' 
			SET @tempsummary = @tempsummary + ' Diverticulum'
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @GallBladderTumor = 1 
		BEGIN
			SET @tempsummary = '' 
			SET @tempsummary = @tempsummary + ' Gall bladder tumour'
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @AnastomicStricture = 1 
		BEGIN
			SET @tempsummary = '' 
			SET @tempsummary = @tempsummary + ' Anastomic stricture'
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary

		END

		IF @MirizziSyndrome = 1
		BEGIN
			SET @tempsummary = '' 
			SET @tempsummary = @tempsummary + ' Mirizzi syndrome'
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		If @SclerosingCholangitis  = 1
		BEGIN
			SET @tempsummary = '' 
			SET @tempsummary = @tempsummary + ' Sclerosing cholangitis'
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @CalculousObstruction = 1
		BEGIN
			SET @tempsummary = '' 
			SET @tempsummary = @tempsummary + ' Calculous obstruction of cystic duct'
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @Occlusion = 1
		BEGIN
			SET @tempsummary = '' 
			SET @tempsummary = @tempsummary + ' Occlusion'
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @BiliaryLeak = 1
		BEGIN
			SET @tempsummary = '' 
			SET @tempsummary = @tempsummary + ' Biliary leak'
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @PreviousSurgery = 1
		BEGIN
			SET @tempsummary = '' 
			SET @tempsummary = @tempsummary + ' Previous surgery'
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF @PancreaticTumour = 1
		BEGIN
			SET @tempsummary = '' 
			SET @tempsummary = @tempsummary + ' Pancreatic tumour'
			
			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		IF ISNULL(@Other,'') <> ''
		BEGIN
			SET @tempsummary = ''
			SET @tempsummary = @tempsummary + ' ' + @Other

			IF @summary = '' SET @summary = @tempsummary
			ELSE SET @summary = @summary + '. ' + @tempsummary
		END

		

	END

	IF CHARINDEX('$$', @Summary) > 0 SET @Summary = STUFF(@Summary, len(@Summary) - charindex('$$', reverse(@Summary)), 2, ' and')
			SET @Summary = REPLACE(@Summary, '$$', ',')
	--PRINT @summary

	-- Finally update the summary in abnormalities table
	UPDATE ERS_ERCPAbnoDuct
	SET Summary = @Summary 
	WHERE SiteId = @siteId


GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Annulare' AND Object_ID = Object_ID(N'ERS_ERCPAbnoParenchyma'))
	ALTER TABLE dbo.ERS_ERCPAbnoParenchyma ADD Annulare VARCHAR(500)
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Other' AND Object_ID = Object_ID(N'ERS_ERCPAbnoParenchyma'))
	ALTER TABLE dbo.ERS_ERCPAbnoParenchyma ADD Other VARCHAR(500)
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Occlusion' AND Object_ID = Object_ID(N'ERS_ERCPAbnoParenchyma'))
	ALTER TABLE dbo.ERS_ERCPAbnoParenchyma ADD Occlusion BIT NOT NULL CONSTRAINT DF_ERCPAbnoParenchyma_Occlusion DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'BiliaryLeak' AND Object_ID = Object_ID(N'ERS_ERCPAbnoParenchyma'))
	ALTER TABLE dbo.ERS_ERCPAbnoParenchyma ADD BiliaryLeak BIT NOT NULL CONSTRAINT DF_ERCPAbnoParenchyma_BiliaryLeak DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'PreviousSurgery' AND Object_ID = Object_ID(N'ERS_ERCPAbnoParenchyma'))
	ALTER TABLE dbo.ERS_ERCPAbnoParenchyma ADD PreviousSurgery BIT NOT NULL CONSTRAINT DF_ERCPAbnoParenchyma_PreviousSurgery DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Pancreatitis' AND Object_ID = Object_ID(N'ERS_ERCPAbnoParenchyma'))
	ALTER TABLE dbo.ERS_ERCPAbnoParenchyma ADD Pancreatitis  BIT NOT NULL CONSTRAINT DF_ERCPAbnoParenchyma_Pancreatitis DEFAULT 0
GO

IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'Stones' AND Object_ID = Object_ID(N'ERS_ERCPAbnoParenchyma'))
BEGIN	
	ALTER TABLE dbo.ERS_ERCPAbnoParenchyma DROP CONSTRAINT DF_ERCPAbnoParenchyma_Stones
	ALTER TABLE dbo.ERS_ERCPAbnoParenchyma DROP COLUMN Stones  
END
GO

IF EXISTS(SELECT * FROM sys.columns WHERE Object_ID = Object_ID(N'ERSAudit.ERS_ERCPAbnoParenchyma_Audit'))
	DROP TABLE ERSAudit.ERS_ERCPAbnoParenchyma_Audit
GO

IF EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoParenchyma')
	DELETE FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoParenchyma'
GO

IF NOT EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoParenchyma')
	INSERT INTO ERSAudit.tblTablesToBeAudited (TableSchema, TableName) VALUES ('dbo', 'ERS_ERCPAbnoParenchyma')
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ERCPAbnoParenchyma', 'TR'
GO

CREATE TRIGGER [dbo].[TR_ERCPAbnoParenchyma]
ON [dbo].[ERS_ERCPAbnoParenchyma]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @Chronic VARCHAR(10) = 'False', @Polycystic VARCHAR(10) = 'False',
			@Sclerosing VARCHAR(10) = 'False', @Caroli VARCHAR(10) = 'False',
			@Cirrhosis VARCHAR(10) = 'False', @Hepatocellular VARCHAR(10) = 'False', 
			@Metastatic VARCHAR(10) = 'False', @MassProbably VARCHAR(10) = 'False', 
			@Annulare VARCHAR(10) = 'False', @SmallLakes VARCHAR(10) = 'False',
			@Strictures VARCHAR(10) = 'False', @Occlusion VARCHAR(10) = 'False',
			@BiliaryLeak VARCHAR(10) = 'False', @PreviousSurgery VARCHAR(10) = 'False',
			@IrregularDucts VARCHAR(10) = 'False', @DilatedDucts VARCHAR(10) = 'False',
			@Pancreatitis VARCHAR(10) = 'False', @Mass VARCHAR(10) = 'False',
			@Action CHAR(1) = 'I', @Area varchar(50), @Region varchar(50)

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Chronic = (CASE WHEN Irregular = 1 OR Dilated = 1 THEN 'True' ELSE 'False' END),
				@IrregularDucts = (CASE WHEN Irregular = 1 THEN 'True' ELSE 'False' END),
				@DilatedDucts = (CASE WHEN Dilated = 1 THEN 'True' ELSE 'False' END),
				@Polycystic = (CASE WHEN SpiderySuspection = 2 THEN 'True' ELSE 'False' END),
				@Cirrhosis = (CASE WHEN SpiderySuspection = 1 THEN 'True' ELSE 'False' END),
				@Sclerosing = (CASE WHEN ISNULL(MultiStricturesSuspection,0) = 1 THEN 'True' ELSE 'False' END),
				@Caroli =  (CASE WHEN ISNULL(MultiStricturesSuspection,0) = 2 THEN 'True' ELSE 'False' END),
				@Hepatocellular =  (CASE WHEN ISNULL(MassType,0) = 1 THEN 'True' ELSE 'False' END),
				@Metastatic =  (CASE WHEN ISNULL(MassType,0) = 2 THEN 'True' ELSE 'False' END),
				@MassProbably =  (CASE WHEN ISNULL(MassProbably,0) = 1 THEN 'True' ELSE 'False' END),
				@Annulare =  (CASE WHEN ISNULL(Annulare,0) = 1 THEN 'True' ELSE 'False' END),
				@SmallLakes =  (CASE WHEN ISNULL(SmallLakes,0) = 1 THEN 'True' ELSE 'False' END),
				@Strictures =  (CASE WHEN ISNULL(Strictures,0) = 1 THEN 'True' ELSE 'False' END),
				@Pancreatitis =  (CASE WHEN ISNULL(Pancreatitis,0) = 1 THEN 'True' ELSE 'False' END),
				@Occlusion = (CASE WHEN Occlusion = 1 THEN 'True' ELSE 'False' END),
				@BiliaryLeak = (CASE WHEN BiliaryLeak = 1 THEN 'True' ELSE 'False' END),
				@PreviousSurgery = (CASE WHEN PreviousSurgery = 1 THEN 'True' ELSE 'False' END),
				@Mass = (CASE WHEN Mass = 1 AND MassType = 0 THEN 'True' ELSE 'False' END)

		FROM INSERTED

		EXEC abnormalities_parenchyma_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	select @Area = x.area, @Region = x.Region from ERS_AbnormalitiesMatrixERCP x inner join ERS_Regions r on x.region = r.Region inner join ers_sites s on r.RegionId = s.RegionId where SiteId =@site_id



	--has suspected polycystic liver disease set 
	EXEC diagnoses_control_save @site_id, 'D200P2', @Polycystic		--Polycystic liver disease
	EXEC diagnoses_control_save @site_id, 'D230P2', @Cirrhosis		--Cirrhosis
	EXEC diagnoses_control_save @site_id, 'D205P2', @Sclerosing		--Sclerosing cholangitis
	EXEC diagnoses_control_save @site_id, 'D215P2', @Caroli			--Caroli's disease


	
	
	IF LOWER(@Area) IN ('pancreas')
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D68P2', @Annulare
		
		--If EITHER of Irregular or Dilated are checked in the Parenchyma abnormalities, both Chronic and Minimal Change should appear
		EXEC diagnoses_control_save @site_id, 'D85P2', @Chronic			-- 'Chronic'
		EXEC diagnoses_control_save @site_id, 'D387P2', @Chronic			-- 'Minimal change'		
		EXEC diagnoses_control_save @site_id, 'D305P2', @Pancreatitis	

		EXEC diagnoses_control_save @site_id, 'D374P2',	@Occlusion				-- 'Occlusion'
		EXEC diagnoses_control_save @site_id, 'D373P2',	@BiliaryLeak				-- 'Occlusion'
		EXEC diagnoses_control_save @site_id, 'D375P2',	@PreviousSurgery				-- 'Occlusion'
		EXEC diagnoses_control_save @site_id, 'D377P2',	@Mass				-- 'Occlusion'
		EXEC diagnoses_control_save @site_id, 'D388P2', @SmallLakes
		EXEC diagnoses_control_save @site_id, 'D389P2', @Strictures
	END
	ELSE
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D362P2', @DilatedDucts			-- 'Dilated ducts'
		EXEC diagnoses_control_save @site_id, 'D361P2', @IrregularDucts			-- 'Irregular ducts'		

		EXEC diagnoses_control_save @site_id, 'D363P2', @Annulare

		EXEC diagnoses_control_save @site_id, 'D150P2',	@Occlusion				-- 'Occlusion'
		EXEC diagnoses_control_save @site_id, 'D372P2',	@BiliaryLeak				-- 'Occlusion'
		EXEC diagnoses_control_save @site_id, 'D365P2',	@PreviousSurgery				-- 'Occlusion'
		EXEC diagnoses_control_save @site_id, 'D376P2',	@Mass				-- 'Occlusion'
		EXEC diagnoses_control_save @site_id, 'D197P2', @SmallLakes
		EXEC diagnoses_control_save @site_id, 'D356P2', @Strictures


	END
	 
	--Diagnosis hepatocellular carcinoma if probable hepatoma
	--Diagnosis metastatic intrahepatic if probable metastases
	IF @Hepatocellular = 'True' OR @Metastatic = 'True'
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D225P2', 'True'				-- 'Tumour'
		EXEC diagnoses_control_save @site_id, 'D242P2', @MassProbably		-- 'Probable'

		IF @MassProbably <> 'True'
			EXEC diagnoses_control_save @site_id, 'D243P2', 'True'			-- 'Possible'	
		ELSE
			EXEC diagnoses_control_save @site_id, 'D243P2', False			-- 'Possible'

		EXEC diagnoses_control_save @site_id, 'D260P2', @Hepatocellular		--hepatocellular carcinoma
		EXEC diagnoses_control_save @site_id, 'D250P2', @Metastatic			--metastatic intrahepatic
	END
	ELSE
	BEGIN --Both hepatocellular carcinoma & metastatic not set
		EXEC diagnoses_control_save @site_id, 'D225P2', 'False'				-- 'Tumour'
		EXEC diagnoses_control_save @site_id, 'D242P2', 'False'				-- 'Probable'
		EXEC diagnoses_control_save @site_id, 'D243P2', 'False'				-- 'Possible'
		EXEC diagnoses_control_save @site_id, 'D260P2', 'False'				--hepatocellular carcinoma
		EXEC diagnoses_control_save @site_id, 'D250P2', 'False'				--metastatic intrahepatic
	END
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_parenchyma_save', 'S'
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
	@SpideryDuctules BIT,
	@SpiderySuspection TINYINT,
	@MultiStrictures BIT,
	@MultiStricturesSuspection TINYINT,
	@Annulare BIT,
	@Pancreatitis BIT,
	@Occlusion BIT,
	@BiliaryLeak BIT,
	@PreviousSurgery BIT,
	@Other VARCHAR(500),
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
	
	
	IF (@Normal=0 AND @Irregular=0 AND @Dilated=0 AND @SmallLakes=0 AND @Strictures=0 AND @Mass=0 AND @SpideryDuctules=0 AND @MultiStrictures=0 AND @Annulare = 0 
		AND @Occlusion = 0 AND @BiliaryLeak = 0 AND @PreviousSurgery = 0 AND @Pancreatitis = 0 AND ISNULL(@Other,'') = '')
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
			SpideryDuctules,
			SpiderySuspection,
			MultiStrictures,
			MultiStricturesSuspection,
			Annulare,
			Occlusion,
			BiliaryLeak,
			PreviousSurgery,
			Pancreatitis,
			Other,
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
			@SpideryDuctules,
			@SpiderySuspection,
			@MultiStrictures,
			@MultiStricturesSuspection,
			@Annulare,
			@Occlusion,
			@BiliaryLeak,
			@PreviousSurgery,
			@Pancreatitis,
			@Other,
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
			SpideryDuctules = @SpideryDuctules,
			SpiderySuspection = @SpiderySuspection,
			MultiStrictures = @MultiStrictures,
			MultiStricturesSuspection = @MultiStricturesSuspection,
			Annulare = @Annulare,
			Occlusion = @Occlusion,
			BiliaryLeak = @BiliaryLeak,
			PreviousSurgery = @PreviousSurgery,
			Pancreatitis = @Pancreatitis,
			Other = @Other,
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
EXEC DropIfExist 'abnormalities_parenchyma_select', 'S'
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
	SpideryDuctules,
	SpiderySuspection,
	MultiStrictures,
	MultiStricturesSuspection,
	EUSProcType,
	Annulare,
	Occlusion,
	BiliaryLeak,
	PreviousSurgery,
	Pancreatitis,
	Other,
	Summary
FROM
	ERS_ERCPAbnoParenchyma
WHERE 
	SiteId = @SiteId

GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_parenchyma_summary_update', 'S'
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
		@SpideryDuctules BIT,
		@SpiderySuspection TINYINT,
		@MultiStrictures BIT,
		@MultiStricturesSuspection TINYINT,
		@Annulare BIT,
		@Occlusion BIT,
		@BiliaryLeak BIT,
		@PreviousSurgery BIT,
		@Pancreatitis BIT,
		@Other VARCHAR(500)

	SELECT 
		@Normal=Normal,
		@Irregular=Irregular,
		@Dilated=Dilated,
		@SmallLakes=SmallLakes,
		@Strictures=Strictures,
		@Mass=Mass,
		@MassType=MassType,
		@MassProbably=MassProbably,
		@SpideryDuctules=SpideryDuctules,
		@SpiderySuspection=SpiderySuspection,
		@MultiStrictures=MultiStrictures,
		@MultiStricturesSuspection=MultiStricturesSuspection,
		@Annulare=Annulare,
		@Occlusion = Occlusion,
		@BiliaryLeak = BiliaryLeak,
		@PreviousSurgery = PreviousSurgery,
		@Pancreatitis = Pancreatitis,
		@Other=Other
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
		IF @Occlusion = 1
		BEGIN
			IF @summary = '' SET @summary = 'occlusion'
			ELSE SET @summary = @summary + '$$ occlusion'
		END

		IF @BiliaryLeak = 1
		BEGIN
			IF @summary = '' SET @summary = 'biliary leak'
			ELSE SET @summary = @summary + '$$ biliary leak'
		END

		IF @PreviousSurgery = 1
		BEGIN
			IF @summary = '' SET @summary = 'previous surgery'
			ELSE SET @summary = @summary + '$$ previous surgery'
		END

		IF @Pancreatitis = 1
		BEGIN
			IF @summary = '' SET @summary = 'pancreatitis'
			ELSE SET @summary = @summary + '$$ pancreatitis'
		END

		IF ISNULL(@Other,'') <> ''
			IF @summary = '' SET @summary = @Other
			ELSE SET @summary = @summary + '$$ ' + @Other

		IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 2, ' and')
		SET @summary = REPLACE(@summary, '$$', ',')
	END

	--PRINT @summary

	-- Finally update the summary in abnormalities table
	UPDATE ERS_ERCPAbnoParenchyma
	SET Summary = @Summary 
	WHERE SiteId = @siteId


GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'sites_summary_update', 'S'
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
		,@fldNone VARCHAR(20)
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
		,(@procType,	'ERS_ERCPAbnoDiverticulum',		'Diverticulum',		CASE WHEN @region IN ('Major Papilla', 'Minor Papilla') THEN 'Diverticulum' ELSE 'Diverticulum/Other' END)
		,(@procType,	'ERS_ERCPAbnoDuct',				'Duct',				CASE WHEN @region = 'Gall Bladder' THEN 'Gall Bladder' ELSE 'Duct' END)
		,(@procType,	'ERS_CommonAbnoDuodenalUlcer',	'',					CASE WHEN @region = 'Jejunum' THEN 'Jejunal Ulcer' WHEN @region = 'Ileum' THEN 'Ileal Ulcer' ELSE 'Duodenal Ulcer' END)
		,(@procType,	'ERS_CommonAbnoDuodenitis',		'',					CASE WHEN @region = 'Jejunum' THEN 'Jejunitis' WHEN @region = 'Ileum' THEN 'Ileitis' ELSE 'Duodenitis' END)
		,(@procType,	'ERS_ERCPAbnoParenchyma',		'Parenchyma',		'Parenchyma')
		,(@procType,	'ERS_CommonAbnoScaring',		'',					'Scarring/Stenosis')
		,(@procType,	'ERS_CommonAbnoTumour',			'',					'Tumour')
		,(@procType,	'ERS_ERCPAbnoTumour',			'Tumour',			'Tumour')
		,(@procType,	'ERS_ERCPAbnoIntrahepatic',		'Intrahepatic',		'Intrahepatic')
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
		ELSE IF @TableName = 'ERS_ERCPAbnoIntrahepatic' SET @fldNone = 'NormalIntraheptic'
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

GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'sites_delete', 'S'
GO

CREATE PROCEDURE [dbo].[sites_delete]
(
	@SiteId INT
)
AS

SET NOCOUNT ON

DECLARE @ProcedureId INT, @AreaNo INT, @SiteNo INT, @ProcedureType INT

BEGIN TRANSACTION

BEGIN TRY
	SELECT @ProcedureId = s.ProcedureId, @AreaNo = s.AreaNo, @SiteNo = s.SiteNo, @ProcedureType = p.ProcedureType
	FROM ERS_Procedures p
	INNER JOIN ERS_Sites s ON p.ProcedureId = s.ProcedureId
	WHERE s.SiteId = @SiteId

	IF @ProcedureType IN (1, 6) --Gastroscopy, EUS_OGD
	BEGIN
		DELETE FROM ERS_UpperGIAbnoDeformity WHERE SiteId = @SiteId
		DELETE FROM ERS_UpperGIAbnoAchalasia WHERE SiteId = @SiteId
		DELETE FROM ERS_UpperGIAbnoGastricUlcer WHERE SiteId = @SiteId
		DELETE FROM ERS_UpperGIAbnoGastritis WHERE SiteId = @SiteId
		DELETE FROM ERS_UpperGIAbnoLumen WHERE SiteId = @SiteId
		DELETE FROM ERS_UpperGIAbnoMalignancy WHERE SiteId = @SiteId
		DELETE FROM ERS_UpperGIAbnoPolyps WHERE SiteId = @SiteId
		DELETE FROM ERS_UpperGIAbnoPostSurgery WHERE SiteId = @SiteId
		DELETE FROM ERS_UpperGIAbnoVarices WHERE SiteId = @SiteId
		DELETE FROM ERS_UpperGIAbnoHiatusHernia WHERE SiteId = @SiteId
		DELETE FROM ERS_UpperGIAbnoOesophagitis WHERE SiteId = @SiteId
		DELETE FROM ERS_UpperGIAbnoBarrett WHERE SiteId = @SiteId
		DELETE FROM ERS_UpperGIAbnoMiscellaneous WHERE SiteId = @SiteId
	END
	ELSE IF @ProcedureType IN (2, 7)   --ERCP, EUS_HPB
	BEGIN
		DELETE FROM ERS_ERCPAbnoDuct WHERE SiteId = @SiteId
		DELETE FROM ERS_ERCPAbnoParenchyma WHERE SiteId = @SiteId
		DELETE FROM ERS_ERCPAbnoAppearance WHERE SiteId = @SiteId
		DELETE FROM ERS_ERCPAbnoDiverticulum WHERE SiteId = @SiteId
		DELETE FROM ERS_ERCPAbnoTumour WHERE SiteId = @SiteId
		DELETE FROM ERS_ERCPAbnoIntrahepatic WHERE SiteId = @SiteId
		DELETE FROM ERS_ERCPTherapeutics WHERE SiteId = @SiteId
	END
	ELSE IF @ProcedureType IN (3,4,5)   --Colonoscopy, Sigmoidscopy, Proctoscopy
	BEGIN
		DELETE FROM ERS_ColonAbnoMucosa WHERE SiteId = @SiteId
		DELETE FROM ERS_ColonAbnoVascularity WHERE SiteId = @SiteId
		DELETE FROM ERS_ColonAbnoLesions WHERE SiteId = @SiteId
		DELETE FROM ERS_ColonAbnoDiverticulum WHERE SiteId = @SiteId
		DELETE FROM ERS_ColonAbnoHaemorrhage WHERE SiteId = @SiteId
		DELETE FROM ERS_ColonAbnoPerianalLesions WHERE SiteId = @SiteId
		DELETE FROM ERS_ColonAbnoCalibre WHERE SiteId = @SiteId
		DELETE FROM ERS_ColonAbnoMiscellaneous WHERE SiteId = @SiteId
	END

	DELETE FROM ERS_CommonAbnoDiverticulum WHERE SiteId = @SiteId	
	DELETE FROM ERS_CommonAbnoTumour WHERE SiteId = @SiteId		
	DELETE FROM ERS_CommonAbnoDuodenitis WHERE SiteId = @SiteId	
	DELETE FROM ERS_CommonAbnoDuodenalUlcer WHERE SiteId = @SiteId
	DELETE FROM ERS_CommonAbnoScaring WHERE SiteId = @SiteId	
	DELETE FROM ERS_CommonAbnoVascularLesions WHERE SiteId = @SiteId	
	DELETE FROM ERS_CommonAbnoAtrophic WHERE SiteId = @SiteId

	DELETE FROM ERS_UpperGISpecimens WHERE SiteId = @SiteId
	DELETE FROM ERS_BRTSpecimens WHERE SiteId = @SiteId
	DELETE FROM ERS_UpperGITherapeutics WHERE SiteId = @SiteId		

	DELETE FROM ERS_Photos WHERE SiteId = @SiteId

	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId	

	IF @AreaNo > 0 AND @SiteNo > 0 --Main Site of an Area
		DELETE FROM ERS_Sites WHERE ProcedureId = @ProcedureId AND AreaNo = @AreaNo 
	ELSE
		DELETE FROM ERS_Sites WHERE SiteId = @SiteId

	IF EXISTS (SELECT 1 FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND SiteId = @SiteId)
	BEGIN
		DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND SiteId = @SiteId
		EXEC ogd_diagnoses_summary_update @ProcedureID
	END

	EXEC sites_reorder @ProcedureId
	EXEC procedure_summary_update @ProcedureId
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
EXEC DropIfExist 'abnormalities_tumour_ercp_save', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_tumour_ercp_save]
(
	@SiteId INT,
	@None BIT,
	@Firm BIT,
	@Friable BIT,
	@Ulcerated BIT,
	@Villous BIT,
	@Polypoid BIT,
	@SubMucosal BIT,
	@Size DECIMAL(6,1),
	@Occlusion BIT,
	@BiliaryLeak BIT,
	@PreviousSurgery BIT,
	@Other VARCHAR(500),
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
	
	
	IF (@None=0 AND @Firm=0 AND @Friable=0 AND @Ulcerated=0 AND @Villous=0 AND @Polypoid=0 AND @SubMucosal=0
		AND @Occlusion = 0 AND @BiliaryLeak = 0 AND @PreviousSurgery = 0 AND ISNULL(@Other,'') = '')
	BEGIN
		DELETE FROM ERS_ERCPAbnoTumour 
		WHERE SiteId = @SiteId

		DELETE FROM ERS_RecordCount 
		WHERE SiteId = @SiteId
		AND Identifier = 'Tumour'
	END		

	ELSE IF NOT EXISTS (SELECT 1 FROM ERS_ERCPAbnoTumour WHERE SiteId = @SiteId)
	BEGIN
		INSERT INTO ERS_ERCPAbnoTumour (
			SiteId,
			[None],
			Firm,
			Friable,
			Ulcerated,
			Villous,
			Polypoid,
			SubMucosal,
			Size,
			Occlusion,
			BiliaryLeak,
			PreviousSurgery,
			Other,
			WhoCreatedId,
			WhenCreated) 
		VALUES (
			@SiteId,
			@None,
			@Firm,
			@Friable,
			@Ulcerated,
			@Villous,
			@Polypoid,
			@SubMucosal,
			@Size,
			@Occlusion,
			@BiliaryLeak,
			@PreviousSurgery,
			@Other,
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
			'Tumour',
			1)
	END

	ELSE
	BEGIN
		UPDATE 
			ERS_ERCPAbnoTumour
		SET 
			[None] = @None,
			Firm = @Firm,
			Friable = @Friable,
			Ulcerated = @Ulcerated,
			Villous = @Villous,
			Polypoid = @Polypoid,
			SubMucosal = @SubMucosal,
			Size = @Size,
			Occlusion = @Occlusion,
			BiliaryLeak = @BiliaryLeak,
			PreviousSurgery = @PreviousSurgery,
			Other = @Other,
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
EXEC DropIfExist 'abnormalities_tumour_ercp_select', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_tumour_ercp_select]
(
	@SiteId INT	
)
AS

SET NOCOUNT ON

SELECT
	[None],
	Firm,
	Friable,
	Ulcerated,
	Villous,
	Polypoid,
	SubMucosal,
	Size,
	Occlusion,
	BiliaryLeak,
	PreviousSurgery,
	Other
FROM
	ERS_ERCPAbnoTumour
WHERE 
	SiteId = @SiteId
GO

--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_tumour_summary_ercp_update', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_tumour_summary_ercp_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000),
		--@Region VARCHAR(500),
		@None BIT,
		@Firm BIT,
		@Friable BIT,
		@Ulcerated BIT,
		@Villous BIT,
		@Polypoid BIT,
		@SubMucosal BIT,
		@Size DECIMAL(6,1),
		@Occlusion BIT,
		@BiliaryLeak BIT,
		@PreviousSurgery BIT,
		@Other VARCHAR(500)

	SELECT 
		@None=[None],
		@Firm=Firm,
		@Friable=Friable,
		@Ulcerated=Ulcerated,
		@Villous=Villous,
		@Polypoid=Polypoid,
		@SubMucosal=SubMucosal,
		@Size=Size,
		@Occlusion = Occlusion,
		@BiliaryLeak = BiliaryLeak,
		@PreviousSurgery = PreviousSurgery,
		@Other = Other
	FROM
		ERS_ERCPAbnoTumour
	WHERE
		SiteId = @SiteId

	SET @Summary = ''

	--SELECT 
	--	@Region = CASE 
	--				WHEN Region LIKE '%Major%' THEN 'Major'
	--				WHEN Region LIKE '%Minor%' THEN 'Minor'
	--			  END
	--FROM ERS_Sites s 
	--JOIN ERS_Regions r ON s.RegionId = r.RegionId 
	--WHERE SiteId = @SiteId

	IF @None = 1
		SET @summary = @summary + 'No tumour'
	
	ELSE 
	BEGIN
		IF @Firm = 1
			IF @summary = '' SET @summary = 'firm'
			ELSE SET @summary = @summary + '$$ firm'

		IF @Friable = 1
			IF @summary = '' SET @summary = 'friable'
			ELSE SET @summary = @summary + '$$ friable'

		IF @Ulcerated = 1
			IF @summary = '' SET @summary = 'ulcerated'
			ELSE SET @summary = @summary + '$$ ulcerated'

		IF @Villous = 1
			IF @summary = '' SET @summary = 'villous'
			ELSE SET @summary = @summary + '$$ villous'

		IF @Polypoid = 1
			IF @summary = '' SET @summary = 'polypoid'
			ELSE SET @summary = @summary + '$$ polypoid'

		IF @SubMucosal = 1
			IF @summary = '' SET @summary = 'sub mucosal'
			ELSE SET @summary = @summary + '$$ sub mucosal'

		IF ISNULL(@Size,0) > 0
			SET @Summary = @Summary + ' (size ' + CONVERT(VARCHAR,CAST(@Size AS FLOAT)) + 'mm)'	
		
		IF @Occlusion = 1
			IF @summary = '' SET @summary = 'occlusion'
			ELSE SET @summary = @summary + '$$ occlusion'
			
		IF @BiliaryLeak = 1
			IF @summary = '' SET @summary = 'biliary leak'
			ELSE SET @summary = @summary + '$$ biliary leak'
			
		IF @PreviousSurgery = 1
			IF @summary = '' SET @summary = 'previous surgery'
			ELSE SET @summary = @summary + '$$ previous surgery'
				
		IF ISNULL(@Other,'') <> ''
			IF @summary = '' SET @summary = @Other
			ELSE SET @summary = @summary + '$$ ' + @Other

		IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 2, ' and')
		SET @summary = REPLACE(@summary, '$$', ',')
	END

	--IF @summary <> '' SET @summary = @Region + ': ' + @summary

	-- Finally update the summary in abnormalities table
	UPDATE ERS_ERCPAbnoTumour
	SET Summary = @Summary 
	WHERE SiteId = @siteId



GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Other' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDiverticulum'))
	ALTER TABLE ERS_ERCPAbnoDiverticulum ADD Other VARCHAR(500) 
GO

IF EXISTS(SELECT * FROM sys.columns WHERE Object_ID = Object_ID(N'ERSAudit.ERS_ERCPAbnoDiverticulum_Audit'))
	DROP TABLE ERSAudit.ERS_ERCPAbnoDiverticulum_Audit
GO

IF EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoDiverticulum')
	DELETE FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoDiverticulum'
GO

IF NOT EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoDiverticulum')
	INSERT INTO ERSAudit.tblTablesToBeAudited (TableSchema, TableName) VALUES ('dbo', 'ERS_ERCPAbnoDiverticulum')
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_diverticulum_ercp_save', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_diverticulum_ercp_save]
(
	@SiteId INT,
	@Normal BIT,
	@Quantity INT,
	@SizeOfLargest DECIMAL,
	@Proximity TINYINT,
	@Occlusion BIT,
	@BiliaryLeak BIT,
	@PreviousSurgery BIT,
	@Other VARCHAR(500),
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
	
	
	IF (ISNULL(@Normal,0)=0 AND ISNULL(@Quantity,0)=0 AND ISNULL(@SizeOfLargest,0)=0 AND ISNULL(@Proximity,0)=0 AND @Occlusion = 0 AND @BiliaryLeak = 0 AND @PreviousSurgery = 0 AND ISNULL(@Other,'') = '')
	BEGIN
		DELETE FROM ERS_ERCPAbnoDiverticulum 
		WHERE SiteId = @SiteId

		DELETE FROM ERS_RecordCount 
		WHERE SiteId = @SiteId
		AND Identifier = 'Diverticulum'
	END		

	ELSE IF NOT EXISTS (SELECT 1 FROM ERS_ERCPAbnoDiverticulum WHERE SiteId = @SiteId)
	BEGIN
		INSERT INTO ERS_ERCPAbnoDiverticulum (
			SiteId,
			Normal,
			Quantity,
			SizeOfLargest,
			Proximity,
			Occlusion,
			BiliaryLeak,
			PreviousSurgery,
			Other,
			WhoCreatedId,
			WhenCreated) 
		VALUES (
			@SiteId,
			@Normal,
			@Quantity,
			@SizeOfLargest,
			@Proximity,
			@Occlusion,
			@BiliaryLeak,
			@PreviousSurgery,
			@Other,
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
			'Diverticulum',
			1)
	END

	ELSE
	BEGIN
		UPDATE 
			ERS_ERCPAbnoDiverticulum
		SET 
			Normal = @Normal,
			Quantity = @Quantity,
			SizeOfLargest = @SizeOfLargest,
			Proximity = @Proximity,
			Occlusion = @Occlusion,
			BiliaryLeak = @BiliaryLeak,
			PreviousSurgery = @PreviousSurgery,
			Other = @Other,
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
EXEC DropIfExist 'abnormalities_diverticulum_ercp_select', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_diverticulum_ercp_select]
(
	@SiteId INT	
)
AS

SET NOCOUNT ON

SELECT
	Normal,
	Quantity,
	SizeOfLargest,
	Proximity,
	Occlusion,
	BiliaryLeak,
	PreviousSurgery,
	Other
FROM
	ERS_ERCPAbnoDiverticulum
WHERE 
	SiteId = @SiteId

GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_diverticulum_summary_ercp_update', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_diverticulum_summary_ercp_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000),
		--@Region VARCHAR(500),
		@Normal BIT,
		@Quantity INT,
		@SizeOfLargest DECIMAL,
		@Proximity TINYINT,
		@Occlusion BIT,
		@BiliaryLeak BIT,
		@PreviousSurgery BIT,
		@Other VARCHAR(500)

	SELECT 
		@Normal=Normal,
		@Quantity=Quantity,
		@SizeOfLargest=SizeOfLargest,
		@Proximity=Proximity,
		@Occlusion = Occlusion,
		@BiliaryLeak = BiliaryLeak,
		@PreviousSurgery = PreviousSurgery,
		@Other = Other
	FROM
		ERS_ERCPAbnoDiverticulum
	WHERE
		SiteId = @SiteId

	SET @Summary = ''

	--SELECT 
	--	@Region = CASE 
	--				WHEN Region LIKE '%Major%' THEN 'Major'
	--				WHEN Region LIKE '%Minor%' THEN 'Minor'
	--			  END
	--FROM ERS_Sites s 
	--JOIN ERS_Regions r ON s.RegionId = r.RegionId 
	--WHERE SiteId = @SiteId

	IF @Normal = 1
		SET @summary = @summary + 'No diverticula'
	
	ELSE 
	BEGIN
		IF ISNULL(@Quantity,0) = 0 AND ISNULL(@SizeOfLargest,0) > 0
			SET @Summary = 'diverticula (largest ' + CONVERT(VARCHAR, @SizeOfLargest) + 'mm)'

		ELSE IF ISNULL(@Quantity,0) = 1 AND ISNULL(@SizeOfLargest,0) = 0
			SET @Summary = 'one diverticulum '

		ELSE IF ISNULL(@Quantity,0) = 1 AND ISNULL(@SizeOfLargest,0) > 0
			SET @Summary = 'one ' + CONVERT(VARCHAR, @SizeOfLargest) + 'mm' + ' diverticulum'
     
		ELSE IF ISNULL(@Quantity,0) > 1 AND ISNULL(@SizeOfLargest,0) = 0
			SET @Summary = CONVERT(VARCHAR, @Quantity) + ' diverticula'
   
		ELSE IF ISNULL(@Quantity,0) > 1 AND ISNULL(@SizeOfLargest,0) > 0
			SET @Summary = CONVERT(VARCHAR, @Quantity) + ' diverticula (largest ' + CONVERT(VARCHAR, @SizeOfLargest) + 'mm)'

		IF @Proximity > 0
			IF @summary = '' SET @summary = ' diverticulum '
			ELSE SET @summary = @summary + ' '

		IF @Proximity = 1 SET @summary = @summary + ' greater than 5mm from the ampulla'
		ELSE IF @Proximity = 2 SET @summary = @summary + 'touching the ampulla'
		ELSE IF @Proximity = 3 SET @summary = @summary + 'with the ampulla within'

		IF @Occlusion = 1
		BEGIN
			IF @summary = '' SET @summary = ' occlusion'
			ELSE SET @summary = @summary + '$$ occlusion'
		END

		
		IF @BiliaryLeak = 1
		BEGIN
			IF @summary = '' SET @summary = ' biliary leak'
			ELSE SET @summary = @summary + '$$ biliary leak'
		END

	
		IF @PreviousSurgery = 1
		BEGIN
			IF @summary = '' SET @summary = ' previous surgery'
			ELSE SET @summary = @summary + '$$ previous surgery'
		END

		IF ISNULL(@Other,'') <> ''
			SET @summary = @summary + '$$ ' +@Other

		IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 2, ' and')
			SET @summary = REPLACE(@summary, '$$', ',')
	END

	--IF @summary <> '' SET @summary = @Region + ': ' + @summary

	-- Finally update the summary in abnormalities table
	UPDATE ERS_ERCPAbnoDiverticulum
	SET Summary = @Summary 
	WHERE SiteId = @siteId
GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Intrahepatic' AND Object_ID = Object_ID(N'ERS_AbnormalitiesMatrixERCP'))
	ALTER TABLE ERS_AbnormalitiesMatrixERCP ADD Intrahepatic BIT

IF EXISTS(SELECT * FROM sys.columns WHERE Object_ID = Object_ID(N'ERSAudit.ERS_AbnormalitiesMatrixERCP_Audit'))
	DROP TABLE ERSAudit.ERS_AbnormalitiesMatrixERCP_Audit
GO

IF EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_AbnormalitiesMatrixERCP')
	DELETE FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_AbnormalitiesMatrixERCP'
GO

IF NOT EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_AbnormalitiesMatrixERCP')
	INSERT INTO ERSAudit.tblTablesToBeAudited (TableSchema, TableName) VALUES ('dbo', 'ERS_AbnormalitiesMatrixERCP')
GO

UPDATE [ERS_AbnormalitiesMatrixERCP] SET Intrahepatic = 1 WHERE Region IN ('Left intra-hepatic Ducts', 'Right intra-hepatic Ducts')
GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_Pages WHERE PageId = 463 OR PageName = 'Intrahepatic')
	INSERT INTO ERS_Pages (PageId, PageName, PageAlias, AppPageName, GroupId, PageURL)
	VALUES (463, 'Intrahepatic', 'Intrahepatic', 'products_gastro_abnormalities_ercp_intrahepatic_aspx', 6, '~/products/gastro/abnormalities/ercp/intrahepatic.aspx')
GO
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_SiteDetailsMenuUrls WHERE Menu = 'Intrahepatic')
	INSERT INTO ERS_SiteDetailsMenuUrls (ProcedureType, Menu, NavigateUrl)
	VALUES (2,'Intrahepatic', '~/Products/Gastro/Abnormalities/ERCP/Intrahepatic.aspx'),
		   (7,'Intrahepatic', '~/Products/Gastro/Abnormalities/ERCP/Intrahepatic.aspx')
GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.ERS_ERCPAbnoIntrahepatic'))
BEGIN
	CREATE TABLE [dbo].[ERS_ERCPAbnoIntrahepatic](
		[AbnoIntrahepaticId]				[int]		IDENTITY(1,1) NOT NULL,
		[SiteId]							[int]		NOT NULL CONSTRAINT UQ_ERCPAbnoIntrahepatic_SiteId UNIQUE(SiteId),
		[NormalIntraheptic]					[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoIntrahepatic_NormalIntraheptic DEFAULT 0,
		[SuppurativeCholangitis]			[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoIntrahepatic_SuppurativeCholangitis DEFAULT 0,
		[IntrahepticBiliaryLeak]		[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoIntrahepatic_IntrahepticBiliaryLeak DEFAULT 0,
		[IntrahepticTumourProbable]			[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoIntrahepatic_IntrahepticTumourProbable DEFAULT 0,
		[IntrahepticTumourPossible]			[bit]		NOT NULL CONSTRAINT DF_ERCPAbnoIntrahepatic_IntrahepticTumourPossible DEFAULT 0,
		[Summary]							[nvarchar](4000) NULL,
		[WhoUpdatedId]						[int]		NULL,
		[WhoCreatedId]						[int]		NULL Default 0,
		[WhenCreated]						[DATETIME]	NULL Default GetDate(),
		[WhenUpdated]						[DATETIME]	NULL,
		CONSTRAINT [FK_ERCPAbnoIntrahepatic_Sites] FOREIGN KEY ([SiteId]) REFERENCES ERS_Sites([SiteId]),
		CONSTRAINT [PK_AbnoIntrahepaticId] PRIMARY KEY CLUSTERED ([AbnoIntrahepaticId] ASC)
	) ON [PRIMARY]
END
GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'Stones' AND Object_ID = Object_ID(N'ERS_ERCPAbnoIntrahepatic'))
	ALTER TABLE dbo.ERS_ERCPAbnoIntrahepatic ADD Stones BIT NOT NULL CONSTRAINT DF_ERCPAbnoIntrahepatic_Stones DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Other' AND Object_ID = Object_ID(N'ERS_ERCPAbnoIntrahepatic'))
	ALTER TABLE dbo.ERS_ERCPAbnoIntrahepatic ADD Other VARCHAR(MAX)
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Tumour' AND Object_ID = Object_ID(N'ERS_ERCPAbnoIntrahepatic'))
	ALTER TABLE dbo.ERS_ERCPAbnoIntrahepatic ADD Tumour BIT NOT NULL CONSTRAINT [DF_ERCPIntrahepatic_Tumour] DEFAULT 0
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_intrahepatic_save', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_intrahepatic_save]
(
	@SiteId INT,
	@NormalIntraheptic bit,		
	@SuppurativeCholangitis bit,		
	@IntrahepticBiliaryLeak bit,		
	@Tumour bit,
	@TumourProbable bit,
	@TumourPossible bit,
	@Stones bit,
	@Other varchar(max),
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
	
	
	IF (@NormalIntraheptic = 0 AND
		@SuppurativeCholangitis=0 AND @IntrahepticBiliaryLeak=0 AND @Stones = 0 AND @Tumour = 0 AND ISNULL(@Other,'') = '')
	BEGIN
		DELETE FROM ERS_ERCPAbnointrahepatic 
		WHERE SiteId = @SiteId

		DELETE FROM ERS_RecordCount 
		WHERE SiteId = @SiteId
		AND Identifier = 'Intrahepatic'
	END		

	ELSE IF NOT EXISTS (SELECT 1 FROM ERS_ERCPAbnointrahepatic WHERE SiteId = @SiteId)
	BEGIN
		INSERT INTO ERS_ERCPAbnointrahepatic (
			 [SiteId]					
			,[NormalIntraheptic]			
			,[SuppurativeCholangitis]	
			,[IntrahepticBiliaryLeak]	
			,[Tumour]
			,[IntrahepticTumourProbable]
			,[IntrahepticTumourPossible]
			,[Stones]
			,[Other]
			,[WhoUpdatedId]				
			,[WhenCreated]) 
		VALUES (
			 @SiteId					
			,@NormalIntraheptic			
			,@SuppurativeCholangitis	
			,@IntrahepticBiliaryLeak
			,@Tumour	
			,@TumourProbable
			,@TumourPossible
			,@Stones
			,@Other
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
			'Intrahepatic',
			1)
	END

	ELSE
	BEGIN
		UPDATE 
			ERS_ERCPAbnoIntrahepatic
		SET 
			 NormalIntraheptic=@NormalIntraheptic			
			,SuppurativeCholangitis=@SuppurativeCholangitis	
			,IntrahepticBiliaryLeak=@IntrahepticBiliaryLeak	
			,Tumour = @Tumour
			,IntrahepticTumourProbable=@TumourProbable
			,IntrahepticTumourPossible=@TumourPossible
			,Stones = @Stones
			,Other = @Other
			,WhoUpdatedId = @LoggedInUserId
			,WhenUpdated = GETDATE()
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
EXEC DropIfExist 'abnormalities_intrahepatic_select','S'
GO

CREATE PROCEDURE abnormalities_intrahepatic_select
(
	@siteId INT
)
AS
BEGIN
	SELECT 
		   [SiteId]
		  ,[NormalIntraheptic]
		  ,[SuppurativeCholangitis]
		  ,[IntrahepticBiliaryLeak]
		  ,[Summary]
		  ,[Tumour]
		  ,[IntrahepticTumourProbable]
		  ,[IntrahepticTumourPossible]
		  ,[Stones]
		  ,[Other]
	  FROM 
			[ERS_ERCPAbnoIntrahepatic]
	  WHERE 
			SiteId = @siteId
  END
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_intrahepatic_summary_update','S'
GO

CREATE PROCEDURE [dbo].[abnormalities_intrahepatic_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000),
		@tempsummary VARCHAR(1000),
		@tempsummary2 VARCHAR(1000),
		@SuppurativeCholangitis VARCHAR(10),
		@NormalIntraheptic VARCHAR(10),
		@IntrahepticBiliaryLeak VARCHAR(10),
		@Tumour BIT,
		@TumourProbable BIT,
		@TumourPossible BIT,
		@Stones BIT,
		@Other VARCHAR(500)

	SELECT 
		@SuppurativeCholangitis=SuppurativeCholangitis,
		@NormalIntraheptic=NormalIntraheptic,
		@IntrahepticBiliaryLeak=IntrahepticBiliaryLeak,
		@Tumour = Tumour,
		@TumourProbable =IntrahepticTumourProbable,
		@TumourPossible =IntrahepticTumourPossible,
		@Stones = Stones,
		@Other = Other
	FROM
		ERS_ERCPAbnoIntrahepatic
	WHERE
		SiteId = @SiteId

	SET @Summary = ''

	IF @NormalIntraheptic = 1
		SET @summary = @summary + 'normal ducts'
	
	ELSE 
	BEGIN
		
		IF @SuppurativeCholangitis = 1
		BEGIN
			IF @Summary = '' SET @Summary = @Summary + ' suppurative cholangitis'
			ELSE SET @summary = @summary + '$$ suppurative cholangitis'

			
		END

		IF @NormalIntraheptic = 1
		BEGIN
			IF @Summary = '' SET @Summary = @Summary + ' Normal intrahepatic ducts'
			ELSE SET @summary = @summary + '$$ Normal intrahepatic ducts'

		END

		IF @IntrahepticBiliaryLeak = 1
		BEGIN
			IF @Summary = '' SET @Summary = @Summary + ' biliary leak'
			ELSE SET @summary = @summary + '$$ biliary leak'
			
		END

		IF @Stones = 1
		BEGIN
			IF @Summary = '' SET @Summary = @Summary + ' stones'
			ELSE SET @summary = @summary + '$$ stones'

		END

		IF @Tumour = 1
		BEGIN
			DECLARE @tmpSummary VARCHAR(max) = ''
			
			IF @TumourPossible = 1
			BEGIN
				IF @tmpSummary = '' SET @tmpSummary = @tmpSummary + ' tumour possible'
				ELSE SET @tmpSummary = @tmpSummary + '$$ tumour possible'
			END
			
			IF @TumourProbable = 1
			BEGIN
				IF @tmpSummary = '' SET @tmpSummary = @tmpSummary + ' tumour probable'
				ELSE SET @tmpSummary = @tmpSummary + '$$ tumour probable'
			END

			IF @TumourPossible = 0 AND @TumourProbable = 0
			BEGIN
				IF @Summary = '' SET @Summary = @Summary + ' tumour'
				ELSE SET @summary = @summary + '$$ tumour'
			END
			ELSE
			BEGIN
				IF @Summary = '' SET @Summary = @Summary + @tmpSummary
			END
		END

		IF ISNULL(@Other,'') <> ''
		BEGIN
			IF @Summary = '' SET @Summary = @Summary + ' ' + @Other
			ELSE SET @summary = @summary + '$$ ' +@Other

		END

		IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 2, ' and')
		SET @summary = REPLACE(@summary, '$$', ',')
	END

	-- Finally update the summary in abnormalities table
	UPDATE ERS_ERCPAbnoIntrahepatic
	SET Summary = @Summary 
	WHERE SiteId = @siteId

GO

--------------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_ERCPAbnoIntrahepatic_Insert','TR';
GO
EXEC DropIfExist 'TR_ERCPAbnoIntrahepatic_Delete','TR';
GO

EXEC DropIfExist 'TR_ERCPAbnoIntrahepatic','TR';
GO

CREATE TRIGGER [dbo].[TR_ERCPAbnoIntrahepatic]
ON [dbo].[ERS_ERCPAbnoIntrahepatic]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, 
			@SuppurativeCholangitis VARCHAR(10) = 'False', 
			@NormalIntraheptic VARCHAR(10) = 'False',
			@IntrahepticBiliaryLeak VARCHAR(10) = 'False',
			@Tumour BIT = 'False',
			@ExtrahepticNormal VARCHAR(10) = 'False', 
			@ExtrahepticIntrahepaticLeak VARCHAR(10) = 'False',
			@ExtrahepticIntrahepaticLeakSite INT,
			@IntrahepaticStones VARCHAR(10) = 'False',
			@Stricture VARCHAR(10) = 'False',  
			@Action CHAR(1) = 'I', @Area varchar(50), @Region varchar(50)

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@SuppurativeCholangitis = (CASE WHEN SuppurativeCholangitis = 1 THEN 'True' ELSE 'False' END),
				@NormalIntraheptic = (CASE WHEN NormalIntraheptic = 1 THEN 'True' ELSE 'False' END),
				@IntrahepticBiliaryLeak = (CASE WHEN IntrahepticBiliaryLeak = 1 THEN 'True' ELSE 'False' END), 
				@IntrahepaticStones =  (CASE WHEN ISNULL(Stones,0) = 1 THEN 'True' ELSE 'False' END),
				@Tumour = (CASE WHEN Tumour = 1 THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_intrahepatic_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	select @Area = x.area, @Region = x.Region from ERS_AbnormalitiesMatrixERCP x inner join ERS_Regions r on x.region = r.Region inner join ers_sites s on r.RegionId = s.RegionId where SiteId =@site_id
	
	EXEC diagnoses_control_save @site_id, 'D357P2', @IntrahepaticStones
	EXEC diagnoses_control_save @site_id, 'D210P2',	@SuppurativeCholangitis				-- 'Duct injury'
	EXEC diagnoses_control_save @site_id, 'D198P2',	@NormalIntraheptic			-- 'Stent occlusion'
	EXEC diagnoses_control_save @site_id, 'D220P2',	@IntrahepticBiliaryLeak			-- 'Stent occlusion'
	EXEC diagnoses_control_save @site_id, 'D225P2', @Tumour			-- 'Stent occlusion'

GO	
--------------------------------------------------------------------------------------------------------------------------------------------
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

	SELECT TOP 1 @Area = [Area] 
	FROM ERS_AbnormalitiesMatrixERCP
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
		FROM [ERS_AbnormalitiesMatrixERCP] 
		WHERE [ProcedureType] = @ProcedureType 
		AND [Region] = @Region
	) a
	UNPIVOT
	(
		[Display] 
		FOR [Menu] IN ([Gall Bladder], [Duct], [Parenchyma], [Appearance], [Diverticulum], [Tumour], [Diverticulum/Other], 
						[TumourCommon],[Duodenitis],[Duodenal Ulcer],[Scarring/Stenosis],[Vascular Lesions],[Atrophic Duodenum],[Intrahepatic],[Site])
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
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_ListsMain WHERE ListDescription = 'Intrahepatic biliary leak site')
BEGIN
	INSERT INTO dbo.ERS_ListsMain (ListDescription, AllowAddNewItem, OrderByDesc, FirstItemText)
	VALUES( 'Intrahepatic biliary leak site', 1, 0,  '')
END
GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Occlusion' AND Object_ID = Object_ID(N'ERS_ERCPAbnoAppearance'))
	ALTER TABLE dbo.ERS_ERCPAbnoAppearance ADD Occlusion BIT NOT NULL CONSTRAINT DF_ERCPAbnoAppearance_Occlusion DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'BiliaryLeak' AND Object_ID = Object_ID(N'ERS_ERCPAbnoAppearance'))
	ALTER TABLE dbo.ERS_ERCPAbnoAppearance ADD BiliaryLeak BIT NOT NULL CONSTRAINT DF_ERCPAbnoAppearance_BiliaryLeak DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'PreviousSurgery' AND Object_ID = Object_ID(N'ERS_ERCPAbnoAppearance'))
	ALTER TABLE dbo.ERS_ERCPAbnoAppearance ADD PreviousSurgery BIT NOT NULL CONSTRAINT DF_ERCPAbnoAppearance_PreviousSurgery DEFAULT 0
GO

IF EXISTS(SELECT * FROM sys.columns WHERE Object_ID = Object_ID(N'ERSAudit.ERS_ERCPAbnoAppearance_Audit'))
	DROP TABLE ERSAudit.ERS_ERCPAbnoAppearance_Audit
GO

IF EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoAppearance')
	DELETE FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoAppearance'
GO

IF NOT EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoAppearance')
	INSERT INTO ERSAudit.tblTablesToBeAudited (TableSchema, TableName) VALUES ('dbo', 'ERS_ERCPAbnoAppearance')
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_appearance_save', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_appearance_save]
(
	@SiteId INT,
	@Normal BIT,
	@Bleeding BIT,
	@Suprapapillary BIT,
	@ImpactedStone BIT,
	@Patulous BIT,
	@Inflamed BIT,
	@Oedematous BIT,
	@PusExuding BIT,
	@Reddened BIT,
	@Tumour BIT,
	@Occlusion BIT,
	@BiliaryLeak BIT,
	@PreviousSurgery BIT,
	@Other BIT,
	@OtherText NVARCHAR(500),
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
	
	
	IF (@Normal=0 AND @Bleeding=0 AND @Suprapapillary=0 AND @ImpactedStone=0 AND @Patulous=0 AND @Inflamed=0 AND @Oedematous=0 AND @PusExuding=0 AND @Reddened=0 AND @Tumour=0
				  AND @Occlusion = 0 AND @BiliaryLeak = 0 AND @PreviousSurgery = 0 AND @Other=0)
	BEGIN
		DELETE FROM ERS_ERCPAbnoAppearance 
		WHERE SiteId = @SiteId

		DELETE FROM ERS_RecordCount 
		WHERE SiteId = @SiteId
		AND Identifier = 'Appearance'
	END		

	ELSE IF NOT EXISTS (SELECT 1 FROM ERS_ERCPAbnoAppearance WHERE SiteId = @SiteId)
	BEGIN
		INSERT INTO ERS_ERCPAbnoAppearance (
			SiteId,
			Normal,
			Bleeding,
			Suprapapillary,
			ImpactedStone,
			Patulous,
			Inflamed,
			Oedematous,
			PusExuding,
			Reddened,
			Tumour,
			Occlusion,
			BiliaryLeak,
			PreviousSurgery,
			Other,
			OtherText,
			WhoCreatedId,
			WhenCreated) 
		VALUES (
			@SiteId,
			@Normal,
			@Bleeding,
			@Suprapapillary,
			@ImpactedStone,
			@Patulous,
			@Inflamed,
			@Oedematous,
			@PusExuding,
			@Reddened,
			@Tumour,
			@Occlusion,
			@BiliaryLeak,
			@PreviousSurgery,
			@Other,
			@OtherText,
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
			'Appearance',
			1)
	END

	ELSE
	BEGIN
		UPDATE 
			ERS_ERCPAbnoAppearance
		SET 
			Normal = @Normal,
			Bleeding = @Bleeding,
			Suprapapillary = @Suprapapillary,
			ImpactedStone = @ImpactedStone,
			Patulous = @Patulous,
			Inflamed = @Inflamed,
			Oedematous = @Oedematous,
			PusExuding = @PusExuding,
			Reddened = @Reddened,
			Tumour = @Tumour,
			Occlusion = @Occlusion,
			BiliaryLeak = @BiliaryLeak,
			PreviousSurgery = @PreviousSurgery,
			Other = @Other,
			OtherText = @OtherText,
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
EXEC DropIfExist 'abnormalities_appearance_select', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_appearance_select]
(
	@SiteId INT	
)
AS

SET NOCOUNT ON

SELECT
	Normal,
	Bleeding,
	Suprapapillary,
	ImpactedStone,
	Patulous,
	Inflamed,
	Oedematous,
	PusExuding,
	Reddened,
	Tumour,
	Occlusion,
	BiliaryLeak,
	PreviousSurgery,
	Other,
	OtherText
FROM
	ERS_ERCPAbnoAppearance
WHERE 
	SiteId = @SiteId

GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_appearance_summary_update', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_appearance_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000),
		--@Region VARCHAR(500),
		@Normal BIT,
		@Bleeding BIT,
		@Suprapapillary BIT,
		@ImpactedStone BIT,
		@Patulous BIT,
		@Inflamed BIT,
		@Oedematous BIT,
		@PusExuding BIT,
		@Reddened BIT,
		@Tumour BIT,
		@Occlusion BIT,
		@BiliaryLeak BIT,
		@PreviousSurgery BIT,
		@Other BIT,
		@OtherText NVARCHAR(500)

	SELECT 
		@Normal=Normal,
		@Bleeding=Bleeding,
		@Suprapapillary=Suprapapillary,
		@ImpactedStone=ImpactedStone,
		@Patulous=Patulous,
		@Inflamed=Inflamed,
		@Oedematous=Oedematous,
		@PusExuding=PusExuding,
		@Reddened=Reddened,
		@Tumour=Tumour,
		@Occlusion = Occlusion,
		@BiliaryLeak = BiliaryLeak,
		@PreviousSurgery = PreviousSurgery,
		@Other=Other,
		@OtherText=OtherText
	FROM
		ERS_ERCPAbnoAppearance
	WHERE
		SiteId = @SiteId

	SET @Summary = ''
	
	--SELECT 
	--	@Region = CASE 
	--				WHEN Region LIKE '%Major%' THEN 'Major'
	--				WHEN Region LIKE '%Minor%' THEN 'Minor'
	--			  END
	--FROM ERS_Sites s 
	--JOIN ERS_Regions r ON s.RegionId = r.RegionId 
	--WHERE SiteId = @SiteId


	IF @Normal = 1
		SET @summary = @summary + 'normal'
	
	ELSE 
	BEGIN
		IF @Bleeding = 1
			IF @summary = '' SET @summary = 'bleeding'
			ELSE SET @summary = @summary + '$$ bleeding'
		IF @Suprapapillary = 1
			IF @summary = '' SET @summary = 'bulging suprapapillary bile duct'
			ELSE SET @summary = @summary + '$$ bulging suprapapillary bile duct'
		IF @ImpactedStone = 1
			IF @summary = '' SET @summary = 'impacted stone'
			ELSE SET @summary = @summary + '$$ impacted stone'
		IF @Patulous = 1
			IF @summary = '' SET @summary = 'patulous'
			ELSE SET @summary = @summary + '$$ patulous'
		IF @Inflamed = 1
			IF @summary = '' SET @summary = 'inflamed'
			ELSE SET @summary = @summary + '$$ inflamed'
		IF @Oedematous = 1
			IF @summary = '' SET @summary = 'oedematous'
			ELSE SET @summary = @summary + '$$ oedematous'
		IF @PusExuding = 1
			IF @summary = '' SET @summary = 'pus exuding'
			ELSE SET @summary = @summary + '$$ pus exuding'
		IF @Reddened = 1
			IF @summary = '' SET @summary = 'reddened'
			ELSE SET @summary = @summary + '$$ reddened'
		IF @Tumour = 1
		BEGIN
            --If tumour data is filled in Tumour screen, don't report tumour in Appearance screen
			--IF NOT EXISTS(SELECT 1 FROM ERS_ERCPAbnoTumour WHERE )
				IF @summary = '' SET @summary = 'tumour'
				ELSE SET @summary = @summary + '$$ tumour'
		END
		IF @Occlusion = 1
		BEGIN
			IF @summary = '' SET @summary = 'occlusion'
			ELSE SET @summary = @summary + '$$ occlusion'
		END

		IF @BiliaryLeak = 1
		BEGIN
			IF @summary = '' SET @summary = 'biliary leak'
			ELSE SET @summary = @summary + '$$ biliary leak'
		END

		IF @PreviousSurgery = 1
		BEGIN
			IF @summary = '' SET @summary = 'previous surgery'
			ELSE SET @summary = @summary + '$$ previous surgery'
		END

		IF @Other = 1
			IF @OtherText <> ''
				IF @summary = '' SET @summary = @OtherText
				ELSE SET @summary = @summary + '$$ ' + @OtherText
			ELSE
				IF @summary = '' SET @summary = 'other'
				ELSE SET @summary = @summary + '$$ other'

		IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 2, ' and')
		SET @summary = REPLACE(@summary, '$$', ',')
	END

	--IF @summary <> '' SET @summary = @Region + ': ' + @summary

	--PRINT @summary

	-- Finally update the summary in abnormalities table
	UPDATE ERS_ERCPAbnoAppearance
	SET Summary = (SELECT isnull(@summary, '') as [text()] FOR XML PATH(''))  
	WHERE SiteId = @siteId
GO

--------------------------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Occlusion' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDiverticulum'))
	ALTER TABLE dbo.ERS_ERCPAbnoDiverticulum ADD Occlusion BIT NOT NULL CONSTRAINT DF_ERCPAbnoDiverticulum_Occlusion DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'BiliaryLeak' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDiverticulum'))
	ALTER TABLE dbo.ERS_ERCPAbnoDiverticulum ADD BiliaryLeak BIT NOT NULL CONSTRAINT DF_ERCPAbnoDiverticulum_BiliaryLeak DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'PreviousSurgery' AND Object_ID = Object_ID(N'ERS_ERCPAbnoDiverticulum'))
	ALTER TABLE dbo.ERS_ERCPAbnoDiverticulum ADD PreviousSurgery BIT NOT NULL CONSTRAINT DF_ERCPAbnoDiverticulum_PreviousSurgery DEFAULT 0
GO

IF EXISTS(SELECT * FROM sys.columns WHERE Object_ID = Object_ID(N'ERSAudit.ERS_ERCPAbnoDiverticulum_Audit'))
	DROP TABLE ERSAudit.ERS_ERCPAbnoDiverticulum_Audit
GO

IF EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoDiverticulum')
	DELETE FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoDiverticulum'
GO

IF NOT EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoDiverticulum')
	INSERT INTO ERSAudit.tblTablesToBeAudited (TableSchema, TableName) VALUES ('dbo', 'ERS_ERCPAbnoDiverticulum')
GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Other' AND Object_ID = Object_ID(N'ERS_ERCPAbnoTumour'))
	ALTER TABLE ERS_ERCPAbnoTumour ADD Other VARCHAR(500) 
GO

IF EXISTS(SELECT * FROM sys.columns WHERE Object_ID = Object_ID(N'ERSAudit.ERS_ERCPAbnoTumour_Audit'))
	DROP TABLE ERSAudit.ERS_ERCPAbnoTumour_Audit
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Occlusion' AND Object_ID = Object_ID(N'ERS_ERCPAbnoTumour'))
	ALTER TABLE dbo.ERS_ERCPAbnoTumour ADD Occlusion BIT NOT NULL CONSTRAINT DF_ERCPAbnoTumour_Occlusion DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'BiliaryLeak' AND Object_ID = Object_ID(N'ERS_ERCPAbnoTumour'))
	ALTER TABLE dbo.ERS_ERCPAbnoTumour ADD BiliaryLeak BIT NOT NULL CONSTRAINT DF_ERCPAbnoTumour_BiliaryLeak DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'PreviousSurgery' AND Object_ID = Object_ID(N'ERS_ERCPAbnoTumour'))
	ALTER TABLE dbo.ERS_ERCPAbnoTumour ADD PreviousSurgery BIT NOT NULL CONSTRAINT DF_ERCPAbnoTumour_PreviousSurgery DEFAULT 0
GO

IF EXISTS(SELECT * FROM sys.columns WHERE Object_ID = Object_ID(N'ERSAudit.ERS_ERCPAbnoTumour_Audit'))
	DROP TABLE ERSAudit.ERS_ERCPAbnoTumour_Audit
GO

IF EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoTumour')
	DELETE FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoTumour'
GO

IF NOT EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_ERCPAbnoTumour')
	INSERT INTO ERSAudit.tblTablesToBeAudited (TableSchema, TableName) VALUES ('dbo', 'ERS_ERCPAbnoTumour')
GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'DuodenumNormal' AND Object_ID = Object_ID(N'ERS_Visualisation'))
	ALTER TABLE dbo.ERS_Visualisation ADD DuodenumNormal BIT NOT NULL CONSTRAINT [DF_Visualisation_DuodenumNormal] DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'DuodenumNotEntered' AND Object_ID = Object_ID(N'ERS_Visualisation'))
	ALTER TABLE dbo.ERS_Visualisation ADD DuodenumNotEntered BIT NOT NULL CONSTRAINT [DF_Visualisation_DuodenumNotEntered] DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Duodenum2ndPartNotEntered' AND Object_ID = Object_ID(N'ERS_Visualisation'))
	ALTER TABLE dbo.ERS_Visualisation ADD Duodenum2ndPartNotEntered BIT NOT NULL CONSTRAINT [DF_Visualisation_Duodenum2ndPartNotEntered] DEFAULT 0
GO

IF EXISTS(SELECT * FROM sys.columns WHERE Object_ID = Object_ID(N'ERSAudit.ERS_Visualisation_Audit'))
	DROP TABLE ERSAudit.ERS_Visualisation_Audit
GO

IF EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_Visualisation')
	DELETE FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_Visualisation'
GO

IF NOT EXISTS (SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_Visualisation')
	INSERT INTO ERSAudit.tblTablesToBeAudited (TableSchema, TableName) VALUES ('dbo', 'ERS_Visualisation')
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'Otherdata_Visualisation_Summary_Update', 'S'
GO

CREATE PROCEDURE [dbo].[Otherdata_Visualisation_Summary_Update]
(
	@ProcedureID	AS INT
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	DECLARE
		@AccessVia					int,
		@AccessViaOtherText			varchar(500),
		@MajorPapillaBile			smallint ,
		@MajorPapillaBileReason		varchar(50) ,
		@MajorPapillaPancreatic		smallint ,
		@MajorPapillaPancreaticReason varchar(50) ,
		@MinorPapilla				smallint ,
		@MinorPapillaReason			varchar(50) ,
		@HepatobiliaryNotVisualised bit ,
		@HepatobiliaryWholeBiliary	bit ,
		@ExceptBileDuct				bit ,
		@ExceptGallBladder			bit ,
		@ExceptCommonHepaticDuct	bit ,
		@ExceptRightHepaticDuct		bit ,
		@ExceptLeftHepaticDuct		bit ,
		@HepatobiliaryAcinarFilling bit ,
		@HepatobiliaryLimitedBy		smallint ,
		@HepatobiliaryLimitedByOtherText varchar(500) ,
		@PancreaticNotVisualised	bit ,
		@PancreaticDivisum			bit ,
		@PancreaticWhole			bit ,
		@ExceptAccesoryPancreatic	bit ,
		@ExceptMainPancreatic		bit ,
		@ExceptUncinate				bit ,
		@ExceptHead					bit ,
		@ExceptNeck					bit ,
		@ExceptBody					bit ,
		@ExceptTail					bit ,
		@PancreaticAcinar			bit ,
		@PancreaticLimitedBy		smallint ,
		@PancreaticLimitedByOtherText varchar(500) ,
		@HepatobiliaryFirst			smallint ,
		@HepatobiliaryFirstML		varchar(50) ,
		@HepatobiliarySecond		smallint ,
		@HepatobiliarySecondML		varchar(50) ,
		@HepatobiliaryBalloon		bit ,
		@PancreaticFirst			smallint ,
		@PancreaticFirstML			varchar(50) ,
		@PancreaticSecond			smallint ,
		@PancreaticSecondML			varchar(50) ,
		@PancreaticBalloon			bit,
		@DuodenumNormal				bit,
		@DuodenumNotEntered			bit,
		@Duodenum2ndPartNotEntered	bit;

		SELECT 
			@AccessVia						= AccessVia,
			@AccessViaOtherText				= AccessViaOtherText,
			@MajorPapillaBile				= COALESCE(MajorPapillaBile_ER, MajorPapillaBile),
			@MajorPapillaBileReason			= COALESCE(MajorPapillaBileReason_ER, MajorPapillaBileReason),
			@MajorPapillaPancreatic			= COALESCE(MajorPapillaPancreatic_ER, MajorPapillaPancreatic),
			@MajorPapillaPancreaticReason	= COALESCE(MajorPapillaPancreaticReason_ER, MajorPapillaPancreaticReason),
			@MinorPapilla					= COALESCE(MinorPapilla_ER, MinorPapilla),
			@MinorPapillaReason				= COALESCE(MinorPapillaReason_ER, MinorPapillaReason),
			@HepatobiliaryNotVisualised		= HepatobiliaryNotVisualised,
			@HepatobiliaryWholeBiliary		= HepatobiliaryWholeBiliary,
			@ExceptBileDuct					= ExceptBileDuct,
			@ExceptGallBladder				= ExceptGallBladder,
			@ExceptCommonHepaticDuct		= ExceptCommonHepaticDuct,
			@ExceptRightHepaticDuct			= ExceptRightHepaticDuct,
			@ExceptLeftHepaticDuct			= ExceptLeftHepaticDuct,
			@HepatobiliaryAcinarFilling		= HepatobiliaryAcinarFilling,
			@HepatobiliaryLimitedBy			= HepatobiliaryLimitedBy,
			@HepatobiliaryLimitedByOtherText = HepatobiliaryLimitedByOtherText,
			@PancreaticNotVisualised		= PancreaticNotVisualised,
			@PancreaticDivisum				= PancreaticDivisum,
			@PancreaticWhole				= PancreaticWhole,
			@ExceptAccesoryPancreatic		= ExceptAccesoryPancreatic,
			@ExceptMainPancreatic			= ExceptMainPancreatic,
			@ExceptUncinate					= ExceptUncinate,
			@ExceptHead						= ExceptHead,
			@ExceptNeck						= ExceptNeck,
			@ExceptBody						= ExceptBody,
			@ExceptTail						= ExceptTail,
			@PancreaticAcinar				= PancreaticAcinar,
			@PancreaticLimitedBy			= PancreaticLimitedBy,
			@PancreaticLimitedByOtherText	= PancreaticLimitedByOtherText,
			@HepatobiliaryFirst				= HepatobiliaryFirst,
			@HepatobiliaryFirstML			= HepatobiliaryFirstML,
			@HepatobiliarySecond			= HepatobiliarySecond,
			@HepatobiliarySecondML			= HepatobiliarySecondML,
			@HepatobiliaryBalloon			=HepatobiliaryBalloon,
			@PancreaticFirst				= PancreaticFirst,
			@PancreaticFirstML				= PancreaticFirstML,
			@PancreaticSecond				= PancreaticSecond,
			@PancreaticSecondML				= PancreaticSecondML,
			@PancreaticBalloon				= PancreaticBalloon,
			@DuodenumNormal					= DuodenumNormal,
			@DuodenumNotEntered				= DuodenumNotEntered,
			@Duodenum2ndPartNotEntered		= Duodenum2ndPartNotEntered


		FROM [ERS_Visualisation] 
		WHERE ProcedureID = @ProcedureId;

        DECLARE @A varchar(2000)='', @B varchar(2000)='' , @C varchar(2000)='', @AR1 varchar(2000)='', @AR2 varchar(2000)=''
        DECLARE @C1 varchar(500) =''
        DECLARE @Reasons1 varchar(2000)='', @Reasons2 varchar(2000) ='', @Reasons3 varchar(2000), @Reasons4 varchar(2000)
        DECLARE @tmp1 TABLE(Val VARCHAR(MAX))
        DECLARE @tmp2 TABLE(Val VARCHAR(MAX))
        DECLARE @NoHepExcept bit=0,  @NoPanExcept bit =0

        IF @AccessVia > 0 
            BEGIN
            IF ISNULL(@AccessViaOtherText,0) > 0 SET @A = ISNULL((SELECT ListItemText + '. ' FROM ERS_Lists where ListDescription='ERCP other access point' AND  ListItemNo = ISNULL(@AccessViaOtherText,0)  AND LOWER(ListItemText) <> '(none)'),'') 
            END
        SET @B='Cannulation via the major papilla to the bile and pancreatic ducts was unsuccessful '

        IF @MajorPapillaBile =1 AND @MajorPapillaPancreatic =1
        BEGIN
            SET @A = @A + 'Cannulation via the major papilla to the bile and pancreatic ducts was successful '
            SET @B= ''    
            DECLARE @CannDev VARCHAR(50) = ''               
            IF ISNULL(@MajorPapillaBileReason,'')<>'' SET @B = ISNULL((SELECT ISNULL(ListItemText,'') FROM ERS_Lists where ListDescription='ERCP via major to bile successful using' AND  ListItemNo = ISNULL(@MajorPapillaBileReason,0) AND LOWER(ListItemText) <> '(none)'),'')
            IF @B <> '' IF LEFT(@B, 1) IN ('a','e','i','o','u') SET @B= 'an ' + @B ELSE SET @B= 'a '+ @B
            IF LEN(LTRIM(RTRIM(@B)))  > 0 SET @CannDev = 'using ' + @B
            DECLARE @B1 varchar(50) =''

            IF ISNULL(@MajorPapillaPancreaticReason,'')<>'' SET @B1 = ISNULL((SELECT ISNULL(ListItemText,'') FROM ERS_Lists where ListDescription='ERCP via major to pancreatic successful using' AND  ListItemNo = ISNULL(@MajorPapillaPancreaticReason,0) AND LOWER(ListItemText) <> '(none)'),'')
            IF @B1 <> '' IF LEFT(@B1, 1) IN ('a','e','i','o','u') SET @B1= 'an ' + @B1 ELSE SET @B1= 'a '+ @B1
            IF LEN(LTRIM(RTRIM(@B1)))  > 0
                    BEGIN
                    IF LEN(@CannDev)>0
                            BEGIN 
                            IF LTRIM(RTRIM(@B)) <> LTRIM(RTRIM(@B1)) SET @CannDev = @CannDev + ' and  ' + @B1
                            END
                    ELSE IF @B1 <> '' SET @CannDev = 'using '+ @B1
                    END
            IF LEN(LTRIM(RTRIM(@CannDev)))>0 SET @A = @A + @CannDev + '. '
            ELSE SET @A = LTRIM(RTRIM(@A)) + '. '
        END
        ELSE IF @MajorPapillaBile =3 AND @MajorPapillaPancreatic =3
        BEGIN
            SET @A = @A + 'Cannulation via the major papilla to the bile and pancreatic ducts was not attempted. '
        END
        ELSE
        BEGIN
            SET @Reasons1 = ISNULL((SELECT ISNULL(ListItemText,'') FROM ERS_Lists where ListDescription='ERCP via major to bile successful using' AND  ListItemNo = ISNULL(@MajorPapillaBileReason,0) AND LOWER(ListItemText) <> '(none)'),'')
            SET @Reasons2 = ISNULL((SELECT ISNULL(ListItemText,'') FROM ERS_Lists where ListDescription='ERCP via major to pancreatic successful using' AND  ListItemNo = ISNULL(@MajorPapillaPancreaticReason,0) AND LOWER(ListItemText) <> '(none)'),'')
            IF @MajorPapillaBile =4 AND @MajorPapillaPancreatic =4 AND @Reasons1 = @Reasons2 
                    BEGIN
                    IF ISNULL(@MajorPapillaBileReason,0)=0 AND ISNULL(@MajorPapillaBileReason,0)=0 SET @A = @A + @B
                    ELSE SET @A = @A + LTRIM(RTRIM(@B)) + ', limited by ' + @Reasons1
                    SET @A = LTRIM(RTRIM(@A) ) + '. '
                    END
            ELSE
                    BEGIN
                    DECLARE @CAN varchar(1000)='', @AndBut varchar(50)=''
                    SET @B= 'Cannulation via the major papilla to the bile duct was '
                    SET @C= ''
                    SET @AndBut='and'
                    IF (@MajorPapillaBile=1 AND (@MajorPapillaPancreatic=4 OR @MajorPapillaPancreatic=2 )) OR ( @MajorPapillaPancreatic=1 AND (@MajorPapillaBile=4 OR @MajorPapillaBile=2)) SET @AndBut='but'
                    IF @MajorPapillaBile =1
                            BEGIN
                            SET @C= @B + 'successful'
                            SET @B=''
                            SET @B= ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to bile successful using' AND  ListItemNo = ISNULL(@MajorPapillaBileReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                            IF @B<>'' IF LEFT(@B, 1) IN ('a','e','i','o','u') SET @C= @C + ' using an ' + @B ELSE SET @C= @C + ' using a ' + @B
                            END
                    ELSE IF @MajorPapillaBile =3 SET @C= @B + 'not attempted'
                    ELSE IF @MajorPapillaBile =4
                            BEGIN
                            SET @Reasons1=ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to bile unsuccessful due to' AND  ListItemNo = ISNULL(@MajorPapillaBileReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                            IF @Reasons1='' SET @C = @B + 'unsuccessful'
                            ELSE 
                                BEGIN 
                                SET @C= @B + 'unsuccessful due to ' + @Reasons1
                                SET @CAN = ' cannulation '
                                END
                            END
                    ELSE IF @MajorPapillaBile =2
                            BEGIN
                            SET @Reasons1=ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to bile partially successful reason' AND  ListItemNo = ISNULL(@MajorPapillaBileReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                            IF @Reasons1='' SET @C = @B + 'partially successful'
                            ELSE 
                                BEGIN 
                                SET @C= @B + 'partially successful due to ' + @Reasons1
                                SET @CAN = ' cannulation '
                                END
                            END

                            DECLARE @Comma varchar(50)=''
                            IF @C ='' SET @B = 'cannulation via the major papilla to pancreatic duct was '
                            ELSE 
                                BEGIN
                                SET @Reasons1 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to bile unsuccessful due to' AND  ListItemNo = ISNULL(@MajorPapillaBileReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                                SET @Reasons2 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to pancreatic unsuccessful due to' AND  ListItemNo = ISNULL(@MajorPapillaPancreatic,0) AND LOWER(ListItemText) <> '(none)'),'')
                                IF (@MajorPapillaBile=1 AND @MajorPapillaPancreatic=1) AND (@Reasons1 <>'' AND @Reasons2 <> '') SET @CAN = ' also ' + @CAN
                                SET @B = @AndBut + @CAN + ' to the pancreatic duct was '
                                SET @Comma = ', '
                                END
                    IF @MajorPapillaPancreatic=1
                            BEGIN
                            SET @C= @C + @Comma + @B + 'successful '
                            SET @B = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to pancreatic successful using' AND  ListItemNo = ISNULL(@MajorPapillaPancreaticReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                            IF ISNULL(@MajorPapillaBileReason,0) >0  IF LEFT(@B, 1) IN ('a','e','i','o','u') SET @C= @C + ' using an ' + @B + ' ' ELSE SET @C= @C + ' using a ' + @B + ' '
                            END
                    ELSE IF @MajorPapillaPancreatic=3 SET @C= @C + @Comma + @B + 'not attempted '
                    ELSE IF @MajorPapillaPancreatic=3
                            BEGIN
                            SET @Reasons1 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to pancreatic unsuccessful due to' AND  ListItemNo = ISNULL(@MajorPapillaPancreaticReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                            IF @Reasons1 <>'' SET @C= @C + @Comma + @B + 'unsuccessful '
                            ELSE SET @C= @C + @Comma + @B + 'unsuccessful due to ' + @Reasons1
                            END
                    ELSE IF @MajorPapillaPancreatic=2
                            BEGIN
                            SET @Reasons1 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to pancreatic partially successful reason' AND  ListItemNo = ISNULL(@MajorPapillaPancreaticReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                            IF @Reasons1 ='' SET @C = @C + @Comma + @B + 'partially successful'
                            ELSE 
                                BEGIN
                                SET @C = @C + @Comma + @B + 'partially successful due to ' + @Reasons1
                                SET @CAN = ' cannulation '
                                END
                            END
                            IF @C<>'' SET @A = @A + LTRIM(RTRIM(@C)) + '. '
                    END    
        END

		--PRINT 'Value of @A before @MinorPapilla: ' + @A;	--## Debugger!

        IF @MinorPapilla=1
        BEGIN
			SET @A = @A + 'Cannulation via the minor papilla was successful '
			SET @B =  ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via minor successful using to' AND  ListItemNo = ISNULL(@MinorPapillaReason,0) AND LOWER(ListItemText) <> '(none)'),'')
			IF @B <> '' IF LEFT(@B, 1) IN ('a','e','i','o','u') SET @A= @A + ' using an ' + @B  ELSE SET @A= @A + ' using a ' + @B 
			SET @A = LTRIM(RTRIM(@A)) + '.'
        END
        ELSE IF @MinorPapilla=4
        BEGIN
            SET @B ='Cannulation via the minor papilla was unsuccessful ' 
            SET @Reasons1 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via minor unsuccessful due to' AND  ListItemNo = ISNULL(@MinorPapillaReason,0) AND LOWER(ListItemText) <> '(none)'),'')
            IF @Reasons1 = '' SET @A = @A + @B
            ELSE SET @A = @A + @B + 'due to ' + @Reasons1
            SET @A = LTRIM(RTRIM(@A)) + '.'
        END
        ELSE IF @MinorPapilla=2
        BEGIN
            SET @B = 'Cannulation via the minor papilla was partially successful '
            SET @Reasons1 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via minor partially successful reason' AND  ListItemNo = ISNULL(@MinorPapillaReason,0) AND LOWER(ListItemText) <> '(none)'),'')
            IF @Reasons1 = '' SET @A = @A + @B
            ELSE SET @A = @A + @B + 'due to ' + @Reasons1
            SET @A = LTRIM(RTRIM(@A)) + '.'
        END

		IF @A <> '' SET @A = dbo.fnFirstLetterUpper(@A)
		IF @ExceptBileDuct = 1 INSERT INTO @tmp1 (Val) VALUES('common bile duct')
		IF @ExceptGallBladder= 1 INSERT INTO @tmp1 (Val) VALUES('gall bladder')
		IF @ExceptCommonHepaticDuct = 1 INSERT INTO @tmp1 (Val) VALUES('common hepatic duct')
		IF @ExceptRightHepaticDuct = 1 INSERT INTO @tmp1 (Val) VALUES('right hepatic duct')
		IF @ExceptLeftHepaticDuct = 1 INSERT INTO @tmp1 (Val) VALUES('left hepatic duct')

		IF @ExceptAccesoryPancreatic = 1 INSERT INTO @tmp2 (Val) VALUES('accessory pancreatic duct')
		IF @ExceptMainPancreatic = 1 INSERT INTO @tmp2 (Val) VALUES('main pancreatic duct')
		IF @ExceptUncinate = 1 INSERT INTO @tmp2 (Val) VALUES('uncinate process')
		IF @ExceptHead  = 1 INSERT INTO @tmp2 (Val) VALUES('head')
		IF @ExceptNeck  = 1 INSERT INTO @tmp2 (Val) VALUES('neck')
		IF @ExceptBody  = 1 INSERT INTO @tmp2 (Val) VALUES('body')
		IF @ExceptTail  = 1 INSERT INTO @tmp2 (Val) VALUES('tail')

		IF (SELECT COUNT(Val) FROM @tmp1)=0 SET @NoHepExcept = 1
		IF (SELECT COUNT(Val) FROM @tmp1)=0 SET @NoPanExcept = 1

		SET @Reasons1 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP extent of visualisation limited by other' AND  ListItemNo = ISNULL(@HepatobiliaryLimitedByOtherText,0) AND LOWER(ListItemText) <> '(none)'),'')
		SET @Reasons2 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP extent of visualisation limited by other' AND  ListItemNo = ISNULL(@PancreaticLimitedByOtherText,0) AND LOWER(ListItemText) <> '(none)'),'')

		SET @AndBut = 'and '

		DECLARE @XMLlist1 XML, @XMLlist2 XML
		SET @XMLlist1 = (SELECT Val FROM @tmp1 FOR XML  RAW, ELEMENTS, TYPE)
		SET @AR1 =     dbo.fnBuildString(@XMLlist1)
       
		SET @XMLlist2 = (SELECT Val FROM @tmp2 FOR XML  RAW, ELEMENTS, TYPE)
		SET @AR2 = dbo.fnBuildString(@XMLlist2) 

		IF @HepatobiliaryNotVisualised = 1 AND @PancreaticNotVisualised= 1
        BEGIN
            SEt @B = 'Neither the biliary nor pancreatic systems were visualised '
            IF @HepatobiliaryLimitedBy = 1 AND @PancreaticLimitedBy= 1 SET @A = @A + @B + 'due to insufficient contrast. '
            ELSE IF (@HepatobiliaryLimitedBy = 2 AND @PancreaticLimitedBy= 2) AND  (@Reasons1 = @Reasons2)
                    BEGIN
                    IF @Reasons1='' SET @A = @A + @B + '. '
                    ELSE SET @A = @A + @B + 'due to ' + @Reasons1 + '. '
                    END
            ELSE IF @HepatobiliaryLimitedBy<> @PancreaticLimitedBy
            BEGIN
            SET @A = @A + 'The biliary system was not visualised '
            IF @HepatobiliaryLimitedBy= 1 SET @A = @A + 'due to insufficient contrast '
            IF @HepatobiliaryLimitedBy= 2 AND @Reasons1<>'' SET @A = @A + 'due to ' + @Reasons1 + ' '
            SET @A = @A + 'nor was the pancreatic system visualised '
            IF @PancreaticLimitedBy = 1 SET @A = @A + 'due to insufficient contrast '
            IF @PancreaticLimitedBy = 2 AND @Reasons2<>'' SET @A = @A + ' due to ' + @Reasons2 + ' '
            SET @A = @A   + '. '
            END
            ELSE IF ISNULL(@HepatobiliaryLimitedBy,0)=0 AND ISNULL(@PancreaticLimitedBy,0)=0 SET @A = @A + LTRIM(RTRIM(@B)) + '. '
		END
		ELSE IF ISNULL(@HepatobiliaryNotVisualised,0) <>1 AND @PancreaticNotVisualised= 1
        BEGIN
            SET @B=''
            IF @HepatobiliaryWholeBiliary=1
                    BEGIN
                    SET @B = '<br/>Visualisation: The whole biliary system '
                    IF @NoHepExcept=1 SET @A = @A + @B
                    ELSE 
                        BEGIN            
							SET @A = @A + @B + 'except the ' + @AR1
							IF @HepatobiliaryLimitedBy =1 SET @A = @A + ', limited by insufficient contrast '
							IF @HepatobiliaryLimitedBy =2 SET @A = @A + ', limited by ' + @Reasons1 + ' '
                        END
                    END
                    IF @B <> ''
                        BEGIN
                        SET @B='but not the pancreatic system '
                        SET @Comma = ', '
                        END
                    ELSE
                        BEGIN
                        SET @B= '<br/>Visualisation: The pancreatic system was not visualised '
                        SET @Comma = ''
                        END
            IF @PancreaticLimitedBy= 1 SET @B = @B + 'due to insufficient contrast '
            IF @PancreaticLimitedBy= 2 AND @Reasons2<>'' SET @B = @B + ' due to ' + @Reasons2 + ' '
            SET @A = LTRIM(RTRIM(@A)) + @Comma + LTRIM(RTRIM(@B)) + '. '
        END
              
		ELSE IF ISNULL(@HepatobiliaryNotVisualised,0) =1 AND ISNULL(@PancreaticNotVisualised,0)<>1
        BEGIN
            DECLARE @Vis varchar(50)=''
            SET @B = 'the biliary system was not visualised '
            SET @AndBut ='but '
            IF @HepatobiliaryLimitedBy = 1
                    BEGIN
                    SET @B = @B + 'due to insufficient contrast '
                    SET @Vis = '<br/>Visualisation: '
                    END
            IF @HepatobiliaryLimitedBy = 2 AND @Reasons1 <> ''
                    BEGIN
                    SET @B = @B + 'due to ' + @Reasons1 + ' '
                    SET @Vis = '<br/>Visualisation: '
                    END
            SET @C = @AndBut + 'the whole pancreatic system '      
            SET @C1 = @AndBut + 'the pancreas divisum '
            IF @PancreaticWhole=1 OR @PancreaticDivisum=1
                    BEGIN
                    IF @PancreaticDivisum= 1 SET @C = @C1
                    IF @NoPanExcept= 1 SET @C = @C + 'was '
                    ELSE
                        BEGIN
                        SET @Vis = '<br/>Visualisation: '

                        SET @C = @C + @B + 'except the ' + @AR2 + ' was'
                        IF @PancreaticLimitedBy = 1 SET @C = @C + ', limited by insufficient contrast '
                        IF @PancreaticLimitedBy =2 AND @Reasons2<>'' SET @C = @C + ', limited by '+ @Reasons2 + ' '
                        END
                    END
            IF @Vis ='' SET @B = dbo.fnFirstLetterUpper(@B)
            SET @A = @A + @Vis + @B + @C + '.'
        END
		ELSE IF ISNULL(@HepatobiliaryNotVisualised,0) <>1 AND ISNULL(@PancreaticNotVisualised,0)<>1
        BEGIN
            SET @B= 'the whole biliary system '
            SET @C = 'the whole pancreatic system '
            SET @C1 = 'the pancreas divisum '
            IF ISNULL(@HepatobiliaryWholeBiliary,0)=1 AND (ISNULL(@PancreaticWhole,0)=1 OR ISNULL(@PancreaticDivisum,0)=1)
            BEGIN
                IF @PancreaticDivisum=1 SET @C = @C1
                IF ISNULL(@NoHepExcept,0) = 1 AND ISNULL(@NoPanExcept,0)=1
                BEGIN
                    IF @PancreaticWhole = 1 SET @A = @A + 'The complete biliary and pancreatic systems were visualised '
                    ELSE SET @A = @A + 'The complete biliary and pancreas divisum were visualised '
                END
                ELSE IF ISNULL(@NoHepExcept,0) = 1 AND ISNULL(@NoPanExcept,0)<>1
                BEGIN
                    SET @A = @A + '<br/>Visualisation: ' + @B + 'and ' + @C + 'except the ' + @AR2 + ' was visualised'
                    IF @PancreaticLimitedBy=1 SET @A = @A + ', limited by insufficient contrast '
                    IF @PancreaticLimitedBy=2 AND @Reasons2 <>'' SET @A = @A + ', limited by ' + @Reasons2+ ' '
                END
                ELSE IF ISNULL(@NoHepExcept,0) <>1 AND ISNULL(@NoPanExcept,0)=1
                BEGIN
					SET @A= @A + '<br/>Visualisation: ' + @B +'except the '+ @AR1 + ' '
					IF @HepatobiliaryLimitedBy=1 SET @A = LTRIM(RTRIM(@A)) + ', limited by insufficient contrast'
					IF @HepatobiliaryLimitedBy=2 AND @Reasons1 <>'' SET @A = LTRIM(RTRIM(@A)) + ', limited by ' + @Reasons1
					SET @A = LTRIM(RTRIM(@A)) + ', and '+ @C
				END
                ELSE IF ISNULL(@NoHepExcept,0) <>1 AND ISNULL(@NoPanExcept,0)<>1
                BEGIN
                    SET @A = @A + '<br/>Visualisation: ' + @B + 'except the '+ @AR1 + ' '
                    IF @HepatobiliaryLimitedBy=1 SET @A = LTRIM(RTRIM(@A)) + ', limited by insufficient contrast'
                    IF @HepatobiliaryLimitedBy=2 AND @Reasons1 <>'' SET @A = LTRIM(RTRIM(@A)) + ', limited by ' + @Reasons1+ ' '
                    SET @A = LTRIM(RTRIM(@A)) + ', and '+ @C + 'except the '+ @AR2
                    IF @PancreaticLimitedBy=1 SET @A = @A + ', limited by insufficient contrast '
                    IF @PancreaticLimitedBy=2 AND @Reasons2 <>'' SET @A = @A + ', limited by ' + @Reasons2
                END
                SET @A = LTRIM(RTRIM(@A)) + '. '
			END
            ELSE IF ISNULL(@HepatobiliaryWholeBiliary,0)=1 AND ISNULL(@PancreaticWhole,0)<>1 AND ISNULL(@PancreaticDivisum,0)<>1
            BEGIN
				SET @A = @A + '<br/>Visualisation: ' + @B
				IF @NoHepExcept=1 SET @A = @A + ' '
				ELSE 
				BEGIN
					SET @A = @A + 'except the '+ @AR1 + ' '
					IF @HepatobiliaryLimitedBy=1 SET @A = @A + ', limited by insufficient contrast, '
					IF @HepatobiliaryLimitedBy=2 AND @Reasons1<>'' SET @A = @A + ', limited by ' + @Reasons1 + ', '                         
				END
				SET @A = @A + 'but not the pancreatic system. '
            END
            ELSE IF ISNULL(@HepatobiliaryWholeBiliary,0)<>1 AND (ISNULL(@PancreaticWhole,0)=1 OR ISNULL(@PancreaticDivisum,0)=1)
            BEGIN
				SET @A = @A + '<br/>Visualisation: The biliary system was not visualised '
				IF @NoPanExcept=1 SET @A = @A + 'but ' + @c + 'was '
				ELSE 
				BEGIN
					SET @A = @A +'but ' + @c +' except the ' + @AR2 + ' was'
					IF @PancreaticLimitedBy=1 SET @A = @A + ', limited by insufficient contrast '
					IF @PancreaticLimitedBy=2 AND @Reasons2 <>'' SET @A = @A + ', limited by ' + @Reasons2
				END
				SET @A = LTRIM(RTRIM(@A)) + '. '
			END
            --ELSE IF ISNULL(@HepatobiliaryWholeBiliary,0)<>1 AND ISNULL(@PancreaticWhole,0)<>1 AND ISNULL(@PancreaticDivisum,0)<>1
                    --BEGIN
                    --SET @A = @A + 'Neither the biliary nor the pancreatic systems were visualised.'
            --END
        END
                     
		IF @HepatobiliaryAcinarFilling    = 1 AND @PancreaticAcinar=1  SET @A = @A + 'There was evidence of acinar filling of the liver and the pancreas. '
		ELSE IF @HepatobiliaryAcinarFilling      = 1 AND @PancreaticAcinar<>1 SET @A = @A + 'There was evidence of acinar filling of the liver. '
		ELSE IF @HepatobiliaryAcinarFilling      <> 1 AND @PancreaticAcinar=1 SET @A = @A  +'There was evidence of acinar filling of the pancreas. '
       
		DELETE FROM @tmp1
		DELETE FROM @tmp2
		SET @AR1= ''
		SET @AR2 = ''
		DECLARE @Vol varchar(500)='', @CM varchar(500)=''

		IF ISNULL(@HepatobiliaryFirstML,0) > 0 SET @Vol = ISNULL(@HepatobiliaryFirstML,0) + ' ml'
		IF ISNULL(@HepatobiliaryFirst,0) > 0 SET @CM = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP contrast media used' AND  ListItemNo = ISNULL(@HepatobiliaryFirst,0) AND LOWER(ListItemText) <> '(none)'),'')
		IF @CM <>'' OR ISNULL(@HepatobiliaryFirstML,'')<>'' INSERT INTO @tmp1 (VAl) VALUES (@Vol+ (CASE WHEN (@Vol)<>'' THEN ' ' + @CM ELSE @CM END ))

		SET @Vol='' ; SET @CM= ''

		IF ISNULL(@HepatobiliarySecondML,0) > 0 SET @Vol = ISNULL(@HepatobiliarySecondML,0) + ' ml'
		IF ISNULL(@HepatobiliarySecond,0) > 0 SET @CM = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP contrast media used' AND  ListItemNo = ISNULL(@HepatobiliarySecond,0) AND LOWER(ListItemText) <> '(none)'),'')
		IF @CM <>'' OR ISNULL(@HepatobiliarySecondML,'')<>'' INSERT INTO @tmp1 (VAl) VALUES (@Vol+ (CASE WHEN (@Vol)<>'' THEN ' ' + @CM ELSE @CM END ))

		SET @Vol='' ; SET @CM= ''


		IF ISNULL(@PancreaticFirstML,0) > 0 SET @Vol = ISNULL(@PancreaticFirstML,0) + ' ml'
		IF ISNULL(@PancreaticFirst,0) > 0 SET @CM = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP contrast media used' AND  ListItemNo = ISNULL(@PancreaticFirst,0) AND LOWER(ListItemText) <> '(none)'),'')
		IF @CM <>'' OR ISNULL(@PancreaticFirstML,'')<>'' INSERT INTO @tmp2 (VAl) VALUES (@Vol+ (CASE WHEN (@Vol)<>'' THEN ' ' + @CM ELSE @CM END ))

		SET @Vol='' ; SET @CM= ''

		IF ISNULL(@PancreaticSecondML,0) > 0 SET @Vol = ISNULL(@PancreaticSecondML,0) + ' ml'
		IF ISNULL(@PancreaticSecond,0) > 0 SET @CM = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP contrast media used' AND  ListItemNo = ISNULL(@PancreaticSecond,0) AND LOWER(ListItemText) <> '(none)'),'')
		IF @CM <>'' OR ISNULL(@PancreaticSecondML,'')<>'' INSERT INTO @tmp2 (VAl) VALUES (@Vol+ (CASE WHEN (@Vol)<>'' THEN ' ' + @CM ELSE @CM END ))

		SET @B=''
		SET @C = ''

		
		IF @HepatobiliaryBalloon= 1 SET @B = '(occlusion cholangiography) '
		IF     @PancreaticBalloon = 1 SET @C = '(occlusion pancreatography) '

		SET @A = LTRIM(RTRIM(@A))

		DECLARE @XMLlist01 XML, @ic1 int=0
		SET @ic1 = ISNULL((SELECT Count(Val) FROM @tmp1 WHERE LTRIM(RTRIM(Val))<> ''),0)
		SET @XMLlist01 = (SELECT Val FROM @tmp1 FOR XML  RAW, ELEMENTS, TYPE)
		SET @AR1 = dbo.fnBuildString(@XMLlist01)
       

		DECLARE @XMLlist02 XML, @ic2 int=0
		SET @ic2 = ISNULL((SELECT Count(Val) FROM @tmp2 WHERE LTRIM(RTRIM(Val))<> ''),0)
		SET @XMLlist02 = (SELECT Val FROM @tmp2 FOR XML  RAW, ELEMENTS, TYPE)
		SET @AR2 = dbo.fnBuildString(@XMLlist02)
       
		IF @ic1> 0 AND @ic2>0
        BEGIN
			SET @A = @A  + ' Contrast media used: hepatobiliary; ' + @AR1 + ' ' + @B
			SET @A = LTRIM(RTRIM(@A)) + ': pancreatic; ' + @AR2 + ' ' + @C
			SET @A = LTRIM(RTRIM(@A)) + '. '
        END    
		ELSE IF @ic1> 0 AND @ic2=0
        BEGIN
            SET @A = @A  + ' Contrast media used: hepatobiliary; ' + @AR1 + ' ' + @B
            SET @A = LTRIM(RTRIM(@A)) + '. '
        END
		ELSE IF @ic1= 0 AND @ic2>0
        BEGIN
            SET @A = @A + ' Contrast media used: pancreatic; ' + @AR2 + ' ' + @C
            SET @A = LTRIM(RTRIM(@A)) + '. '
        END


		IF @DuodenumNormal = 1 SET @A = @A + ' Duodenum normal. '
		ELSE IF @DuodenumNotEntered = 1 SET @A = @A + ' Duodenum not entered. '
		ELSE IF @Duodenum2ndPartNotEntered = 1 SET @A = @A  +' Duodenum 2nd part not entered. '
		SET @A = LTRIM(RTRIM(@A))

	 UPDATE  [ERS_Visualisation] SET Summary = @A WHERE ProcedureID=@ProcedureID;
	 EXEC [procedure_summary_update] @ProcedureID;
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
EXEC DropIfExist 'ercp_diagnoses_summary_update', 'S'
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
			CASE WHEN LOWER(Value) IN ('true','1') THEN '1' ELSE Value END AS VALUE, IsOtherData
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
	DECLARE @A varchar(MAX)='', @B varchar(MAX)=''


-----Normal procedure marking---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

	
	--/*Papillae REGION*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Papillae' AND Value = '1' AND DisplayName <>'Normal')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D33P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D33P2' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D32P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D32P2'
	END
	ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Papillae')
	BEGIN
		INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'D33P2', 'True', 'Papillae', 1)
	END	
	
	/*Pancreas REGION*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Pancreas' AND Value = '1' AND DisplayName <>'Normal')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D67P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D67P2' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D32P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D32P2'
	END
	ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Pancreas')
	BEGIN
		INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'D67P2', 'True', 'Pancreas', 1)
	END
	
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
	BEGIN
		INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'D138P2', 'True', 'Biliary', 1)
	END
	
	--/*Duodenum REGION*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND Value = '1' AND DisplayName <>'Normal')
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D51P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D51P2' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D32P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D32P2'
	END
	ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Duodenum')
	BEGIN
		INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'D51P2', 'True', 'Duodenum', 1)
	END
	
	/*Not entered*/
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND Value = '1' AND MatrixCode NOT IN ('D51P2','D52P2'))
	BEGIN
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D50P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D50P2' AND Value = 'True'
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='1' AND MatrixCode = 'D52P2') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'D52P2' AND Value = 'True'
	END

	DELETE FROM #tbl_ERS_Diagnoses

	
	
	INSERT INTO #tbl_ERS_Diagnoses (ProcedureID, SiteID, MatrixCode, Region, DisplayName, VALUE, IsOtherData)
	SELECT ProcedureID, SiteID, MatrixCode, Region, CONVERT(VARCHAR(100),'') AS DisplayName,
			CASE WHEN LOWER(Value) IN ('true','1') THEN '1' ELSE Value END AS VALUE, IsOtherData
	FROM dbo.[ERS_Diagnoses]
	WHERE ProcedureId=@ProcedureId --AND RIGHT(MatrixCode,2) = 'P2'

	DELETE #tbl_ERS_Diagnoses WHERE LOWER(Value) IN ('false','0','') AND MatrixCode<>'Summary'

	--Get the display name for the corresponding matrix code
	UPDATE D
	SET D.DisplayName = M.DisplayName
	FROM #tbl_ERS_Diagnoses AS D
	INNER JOIN ERS_DiagnosesMatrix AS M ON M.ProcedureTypeID = 2 AND M.Code = D.MatrixCode 
	WHERE RIGHT(D.MatrixCode,2) = 'P2'
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
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'bleeding')				INSERT INTO @tmpDiv (Val) VALUES('bleeding')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'patulous')				INSERT INTO @tmpDiv (Val) VALUES('patulous')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'bulging suprapapillary bile duct')	INSERT INTO @tmpDiv (Val) VALUES('bulging suprapapillary bile duct')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'pancreatitis')	INSERT INTO @tmpDiv (Val) VALUES('pancreatitis')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'tumour')	INSERT INTO @tmpDiv (Val) VALUES('tumour')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'biliary leak')	INSERT INTO @tmpDiv (Val) VALUES('biliary leak')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'occlusion')	INSERT INTO @tmpDiv (Val) VALUES('occlusion')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'small lakes')	INSERT INTO @tmpDiv (Val) VALUES('small lakes')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'stricture(s)')	INSERT INTO @tmpDiv (Val) VALUES('stricture(s)')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'previous surgery')	INSERT INTO @tmpDiv (Val) VALUES('previous surgery')
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'mass')	INSERT INTO @tmpDiv (Val) VALUES('mass')

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
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('malignant')) 
	BEGIN
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('probably'))
			SET @A1 = 'probably malignant tumour'
		ELSE
			SET @A1 = 'malignant tumour'
	END

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('benign')) 
	BEGIN
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('probably'))
			SET @A1 = 'probably benign tumour'
		ELSE
			SET @A1 = 'benign tumour'
	END
	
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
		IF (SELECT COUNT(Val) FROM @tmpDiv WHERE Val <> 'normal') > 0 	
			DELETE FROM @tmpDiv WHERE Val = 'normal'

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
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val = 'annulare')				INSERT INTO @tmpDiv (Val) VALUES('annulare')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('stent occlusion'))		INSERT INTO @tmpDiv (Val) VALUES('stent occlusion')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('duct injury'))		INSERT INTO @tmpDiv (Val) VALUES('duct injury')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('dilatation'))		INSERT INTO @tmpDiv (Val) VALUES('dilatation')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('small lakes'))		INSERT INTO @tmpDiv (Val) VALUES('small lakes')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('stricture(s)'))		INSERT INTO @tmpDiv (Val) VALUES('stricture(s)')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('stones'))		INSERT INTO @tmpDiv (Val) VALUES('stones')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('irregular ducts'))		INSERT INTO @tmpDiv (Val) VALUES('irregular ducts')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('dilated ducts'))		INSERT INTO @tmpDiv (Val) VALUES('dilated ducts')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('previous surgery'))		INSERT INTO @tmpDiv (Val) VALUES('previous surgery')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('biliary leak'))		INSERT INTO @tmpDiv (Val) VALUES('biliary leak')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('diverticulum'))		INSERT INTO @tmpDiv (Val) VALUES('diverticulum')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('mass'))		INSERT INTO @tmpDiv (Val) VALUES('mass')

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

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('cyst(s)'))
	BEGIN		

		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('communicating', 'noncommunicating', 'pseudocyst'))
		BEGIN
			IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('pseudocyst'))  SET @B= 'pseudocyst ' ELSE SET @B='cyst '
		

			IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('communicating')) SET @C='communicating '

			IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('noncommunicating'))
			BEGIN
				IF @C= ''  SET @C ='noncommunicating '
				ELSE SET @C= @C + 'and noncommunicating '
			END
		
			IF @C <>'' SET @C = @C + 'with biliary duct'
			SET @B = @B + @C

			IF @B <> '' INSERT INTO @tmpDiv (Val) VALUES(@B)

                                  
			SET @B='' 
			SET @C= ''
		END
		ELSE
			INSERT INTO @tmpDiv (Val) VALUES('cyst(s)')
	END

	IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
    BEGIN
		DECLARE @XMLlist3 XML
        SET @XMLlist3 = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
        SET @B = dbo.fnBuildString(@XMLlist3)
		SET @BilStr = ''
    END 
    DELETE FROM @tmpDiv
	IF LTRIM(RTRIM(@B)) <> '' SET @BilStr= dbo.fnFirstLetterUpper(@B) + '. ' 
		   
------- Intrahepatic -------------------------------------------------------			

	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('normal ducts') AND Region = 'Intrahepatic') 
		INSERT INTO @tmpDiv (Val) VALUES(@BilStr +'Normal intrahepatic ducts. ')     
	ELSE
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Region = 'Intrahepatic')
    BEGIN
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('cirrhosis')) INSERT INTO @tmpDiv (Val) VALUES('cirrhosis')      
        IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('hydatid cyst')) INSERT INTO @tmpDiv (Val) VALUES('hydatid cyst')     
        IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('liver abscess')) INSERT INTO @tmpDiv (Val) VALUES('liver abscess')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('suppurative cholangitis')) INSERT INTO @tmpDiv (Val) VALUES('suppurative cholangitis')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('intrahepatic stones')) INSERT INTO @tmpDiv (Val) VALUES('stones')
		
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('dilated duct') AND Region = 'Intrahepatic')
		BEGIN
			IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('post cholecystectomy') AND Region = 'Intrahepatic')	
				INSERT INTO @tmpDiv (Val) VALUES('post cholecystectomy')
			ELSE
				INSERT INTO @tmpDiv (Val) VALUES('dilated duct')
		END		

		
        IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE LEFT(Val,12) IN ('biliary leak') AND Region = 'Intrahepatic') 
        BEGIN
			DECLARE @IntrahepaticSite VARCHAR(500)
			SELECT @IntrahepaticSite = er.Region 
			FROM dbo.ERS_Regions er 
				INNER JOIN dbo.ERS_Sites es ON er.RegionId = es.RegionId 
				INNER JOIN #tbl_ERS_Diagnoses ted ON ted.SiteID = es.SiteId
			WHERE LOWER(LEFT(ted.DisplayName,12)) IN ('biliary leak') AND LOWER(ted.Region) = 'intrahepatic'

			--SET @Other = ISNULL((SELECT TOP 1 LTRIM(RTRIM(Value)) FROM #tbl_ERS_Diagnoses WHERE MatrixCode IN ('IntrahepaticLeakSiteType') AND LTRIM(RTRIM(Value)) <> ''),'')

			--IF @Other<> '' 
			INSERT INTO @tmpDiv (Val) VALUES('biliary leak' + ' (' + @IntrahepaticSite + ')')
			--ELSE INSERT INTO @tmpDiv (Val) VALUES('intrahepatic biliary leak')
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

		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE RIGHT(Val, 9) IN ('stricture') AND Region = 'Intrahepatic') 
        BEGIN
			DECLARE @iTable TABLE (Val varchar(500))
			DECLARE @IntrahepaticStrictureType VARCHAR(2) = ''
			DECLARE @IntrahepaticProbable BIT = 0, @BenignProbable BIT = 0, @MalignantProbable BIT = 0
            SET @B=''

			SET @IntrahepaticProbable = ISNULL((SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('intrahepatic probable')),0)
			SET @BenignProbable = ISNULL((SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('benign probable')),0)
			SET @MalignantProbable = ISNULL((SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('malignant probable')),0)

			--SET @IntrahepaticStrictureType = ISNULL((SELECT TOP 1 CASE WHEN MatrixCode='D330P2' THEN 1 WHEN MatrixCode='D335P2' THEN 2 END
			--		FROM #tbl_ERS_Diagnoses WHERE MatrixCode IN ('D330P2','D335P2') AND Region = 'Intrahepatic' AND LTRIM(RTRIM(Value)) <> ''),'')

            IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('benign') AND Region = 'Intrahepatic') 
            BEGIN
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('pancreatitis')) INSERT INTO @iTable (Val) VALUES('pancreatitis')
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('a pseudocyst')) INSERT INTO @iTable (Val) VALUES('a pseudocyst')
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('previous surgery')) INSERT INTO @iTable (Val) VALUES('previous surgery')
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('sclerosing cholangitis') AND Region = 'Intrahepatic') INSERT INTO @iTable (Val) VALUES('sclerosing cholangitis')
				DECLARE @istr varchar(1000), @iCount int
				SET @iCount = (SELECT COUNT(Val) FROM @iTable)
				IF @iCount > 0 
				BEGIN
					DECLARE @XMLlist6 XML= (SELECT Val FROM @iTable FOR XML  RAW, ELEMENTS, TYPE)                                     
					SET @istr = dbo.fnBuildString(@XMLlist6)                                                 
				END 
				DELETE FROM @iTable
				IF ISNULL(@IntrahepaticProbable,0) <> 1 AND ISNULL(@BenignProbable,0) <> 1
                BEGIN
					IF @iCount >1 SET @B = 'stricture due to ' + @istr
					ELSE SET @B = 'benign stricture'
                END
                ELSE IF ISNULL(@IntrahepaticProbable,0) = 1 AND ISNULL(@BenignProbable,0) <> 1
                BEGIN
					SET @B= 'stricture, probably benign'
					IF @iCount > 1 SET @B = @B + ', ' + @istr
                END
                ELSE IF ISNULL(@IntrahepaticProbable,0) <> 1 AND ISNULL(@BenignProbable,0) = 1
                BEGIN
					SET @B= 'benign stricture '
					IF @iCount > 1 SET @B = @B + ', probably ' + @istr
                END
                ELSE IF ISNULL(@IntrahepaticProbable,0) = 1 AND ISNULL(@BenignProbable,0) = 1
                BEGIN
					SET @B= 'stricture, probably benign'
					IF @iCount > 1 SET @B = @B + ', probably ' + @istr
                END
            END
            ELSE IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('malignant') AND Region = 'Intrahepatic') 
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
                IF ISNULL(@IntrahepaticProbable,0) <> 1 AND ISNULL(@MalignantProbable,0) <> 1
                BEGIN
					IF @oCount > 1 SET @B = 'stricture due to ' + @ostr
					ELSE SET @B ='malignant stricture'
                END
                ELSE IF ISNULL(@IntrahepaticProbable,0) = 1 AND ISNULL(@MalignantProbable,0) <> 1
                BEGIN
					SET @B= 'stricture, probably malignant'
					IF @oCount > 1 SET @B = @B + ', ' + @ostr                                   
                END
                ELSE IF ISNULL(@IntrahepaticProbable,0) <> 1 AND ISNULL(@MalignantProbable,0) = 1
                BEGIN
					SET @B= 'stricture, malignant'
					IF @oCount > 1 SET @B = @B + ', probably ' + @ostr                                       
                END
                ELSE IF ISNULL(@IntrahepaticProbable,0) = 1 AND ISNULL(@MalignantProbable,0) = 1
                BEGIN
					SET @B= 'stricture, probably malignant'
					IF @oCount > 1 SET @B = @B + ', probably ' + @ostr                                       
                END
            END 
            ELSE SET @B ='stricture'

            INSERT INTO @tmpDiv (Val) VALUES(@B)
        END

        IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
        BEGIN
			DECLARE @XMLlist5 XML= (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE) 
			SET @BilStr = REPLACE(LOWER(@BilStr), 'normal','')
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
	IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Region = 'Extrahepatic') 
    BEGIN
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('choledochal cyst'))		INSERT INTO @tmpDiv (Val) VALUES('choledochal cyst')

		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('dilated duct') AND Region = 'Extrahepatic')
		BEGIN
			IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('post cholecystectomy') AND Region = 'Extrahepatic')	
				INSERT INTO @tmpDiv (Val) VALUES('post cholecystectomy')
			ELSE
				INSERT INTO @tmpDiv (Val) VALUES('dilated duct')
		END		
			
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE LEFT(Val,12) IN ('biliary leak') AND Region = 'Extrahepatic') 
		BEGIN
			SET @Other = ISNULL((SELECT TOP 1 LTRIM(RTRIM(Value)) FROM #tbl_ERS_Diagnoses WHERE MatrixCode IN ('ExtrahepaticLeakSiteType') AND LTRIM(RTRIM(Value)) <> ''),'')

			IF @Other<> '' INSERT INTO @tmpDiv (Val) VALUES('biliary leak' + ' (' +(select ISNULL(ListItemText,'') from ERS_Lists where ListDescription='Extrahepatic biliary leak site' AND  ListItemNo = ISNULL(@Other,0)) + ')')
			ELSE INSERT INTO @tmpDiv (Val) VALUES('extrahepatic biliary leak')
		END
		
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('tumour') AND Region = 'Extrahepatic') 
        BEGIN
            DECLARE @tTable2 TABLE (Val varchar(500))
			SET @IntrahepaticTumourType = ''
            SET @A2=''
            SET @B=''
			--SET @IntrahepaticTumourType = ISNULL((SELECT TOP 1  LTRIM(RTRIM(Value)) FROM #tbl_ERS_Diagnoses WHERE MatrixCode IN ('TumourType') AND Region = 'Intrahepatic' AND LTRIM(RTRIM(Value)) <> ''),'')
            --IF ISNULL(@IntrahepaticTumourType,'') = '1' SET @B='probable '
            --ELSE IF ISNULL(@IntrahepaticTumourType,'') = '2' SET @B='possible '

			IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('probable')) SET @B='probable '
			ELSE IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('possible')) SET @B='possible '

            IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('cholangiocarcinoma'))				INSERT INTO @tTable2 (Val) VALUES('cholangiocarcinoma')
            IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('metastatic intrahepatic'))		INSERT INTO @tTable2 (Val) VALUES('metastatic intrahepatic')
            IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('external compression (metastases)')) INSERT INTO @tTable2 (Val) VALUES('external compression (metastases)')
            IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('hepatocellular carcinoma'))		INSERT INTO @tTable2 (Val) VALUES('hepatocellular carcinoma')	
                           
            IF (SELECT COUNT(Val) FROM @tTable2) > 0 
            BEGIN
                SET @XMLlist4 = (SELECT Val FROM @tTable FOR XML  RAW, ELEMENTS, TYPE)
                SET @B = @B +  dbo.fnBuildString(@XMLlist4)
                DELETE FROM @tTable
            END 
            ELSE SET @B= @B + 'tumour'

            INSERT INTO @tmpDiv (Val) VALUES(@B)
            DELETE FROM @tTable2
        END

		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE RIGHT(Val, 9) IN ('Stricture') AND Region = 'Extrahepatic') 
        BEGIN
			DELETE FROM @iTable 
			DECLARE @ExtrahepaticStrictureType VARCHAR(2) = ''
			DECLARE @ExtrahepaticProbable BIT = 0
			SET @BenignProbable = 0
			SET @MalignantProbable = 0
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
				SET @istr =''
				SET @iCount =0
				SET @iCount = (SELECT COUNT(Val) FROM @iTable)
				IF @iCount > 0 
				BEGIN
					SET @XMLlist6 = (SELECT Val FROM @iTable FOR XML  RAW, ELEMENTS, TYPE)                                     
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
					SET @B= 'stricture, probably benign'
					IF @iCount > 1 SET @B = @B + ', ' + @istr
                END
                ELSE IF ISNULL(@ExtrahepaticProbable,0) <> 1 AND ISNULL(@BenignProbable,0) = 1
                BEGIN
					SET @B= 'benign stricture '
					IF @iCount > 1 SET @B = @B + ', probably ' + @istr
                END
                ELSE IF ISNULL(@ExtrahepaticProbable,0) = 1 AND ISNULL(@BenignProbable,0) = 1
                BEGIN
					SET @B= 'stricture, probably benign'
					IF @iCount > 1 SET @B = @B + ', probably ' + @istr
                END
            END
            ELSE IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('malignant') AND Region = 'Extrahepatic') 
            BEGIN
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('gallbladder carcinoma')) INSERT INTO @iTable (Val) VALUES('gallbladder carcinoma')
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('metastatic carcinoma')) INSERT INTO @iTable (Val) VALUES('metastatic carcinoma')
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('cholangiocarcinoma')) INSERT INTO @iTable (Val) VALUES('cholangiocarcinoma')
				IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('pancreatic carcinoma')) INSERT INTO @iTable (Val) VALUES('pancreatic carcinoma')
				SET @oStr =''
				SET @oCount =0
				SET @oCount = (SELECT COUNT(Val) FROM @iTable)
				IF @oCount > 0 
                BEGIN
                    set @XMLlist7 = (SELECT Val FROM @iTable FOR XML  RAW, ELEMENTS, TYPE)                                     
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
					SET @B= 'stricture, probably malignant'
					IF @oCount > 1 SET @B = @B + ', ' + @ostr                                   
                END
                ELSE IF ISNULL(@ExtrahepaticProbable,0) <> 1 AND ISNULL(@MalignantProbable,0) = 1
                BEGIN
					SET @B= 'stricture, malignant'
					IF @oCount > 1 SET @B = @B + ', probably ' + @ostr                                       
                END
                ELSE IF ISNULL(@ExtrahepaticProbable,0) = 1 AND ISNULL(@MalignantProbable,0) = 1
                BEGIN
					SET @B= 'stricture, probably malignant'
					IF @oCount > 1 SET @B = @B + ', probably ' + @ostr                                       
                END
            END 
            ELSE SET @B ='stricture'

            INSERT INTO @tmpDiv (Val) VALUES(@B)
        END

        IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
        BEGIN
			DECLARE @XMLlist8 XML= (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)    
			SET @BilStr = REPLACE(LOWER(@BilStr), 'normal','')
			IF RIGHT(RTRIM(@BilStr),1) <> '.' AND LEN(LTRIM(RTRIM(@BilStr))) > 2 SET @BilStr = @BilStr + '. '                                     
			SET @BilStr = @BilStr + 'extrahepatic: ' + dbo.fnBuildString(@XMLlist8)                                                    
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
	SET @B = ''		

	INSERT INTO @tmpDiv (val)
	SELECT DISTINCT  
	CASE WHEN LOWER(DisplayName) = 'not entered' THEN 'normal' 
		 WHEN LOWER(DisplayName) = '2nd part not entered' THEN 'normal' 
		 WHEN LOWER(DisplayName) = 'scar' THEN 'healed duodenal ulcer - scarring' 
		 WHEN LOWER(DisplayName) = 'stenosis' THEN 'duodenal stenosis' 
		 WHEN LOWER(DisplayName) = 'deformity' THEN 'duodenal deformity' 
		 WHEN LOWER(DisplayName) = 'pseudodiverticulum' THEN 'duodenal pseudodiverticulum' 
	ELSE LOWER(DisplayName) END
	FROM #tbl_ERS_Diagnoses WHERE Region IN ('Duodenum')

	-- Don't repeat diagnoses
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode in ('D39P2', 'D84P2')) DELETE FROM #tbl_ERS_Diagnoses WHERE MatrixCode = 'D49P2'
	IF EXISTS(SELECT TOP(1) 1 FROM ERS_Diagnoses WHERE MatrixCode in ('D39P2', 'D84P2')) DELETE FROM ERS_Diagnoses WHERE MatrixCode = 'D49P2'

	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode in ('D90P2', 'D91P2')) DELETE FROM #tbl_ERS_Diagnoses WHERE MatrixCode = 'D53P2'
	IF EXISTS(SELECT TOP(1) 1 FROM ERS_Diagnoses WHERE MatrixCode in ('D90P2', 'D91P2')) DELETE FROM ERS_Diagnoses WHERE MatrixCode = 'D53P2'

	--IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('not entered')) INSERT INTO @tmpDiv (Val) VALUES('normal')
	--ELSE IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('normal')) INSERT INTO @tmpDiv (Val) VALUES('normal')
	--ELSE IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('2nd part not entered')) INSERT INTO @tmpDiv (Val) VALUES('normal')
	--ELSE
	--BEGIN
	--	INSERT INTO @tmpDiv (Val)
	--	SELECT DISTINCT LOWER(DisplayName)
	--	FROM #tbl_ERS_Diagnoses WHERE Region IN ('Duodenum')

	--	--IF @DuodenumNormal = 1 INSERT INTO @tmpDiv (Val) VALUES('normal')
	--	--IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('angiodysplasia')) INSERT INTO @tmpDiv (Val) VALUES('angiodysplasia')
	--	--IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('tumour')) INSERT INTO @tmpDiv (Val) VALUES('tumour')
	--	--IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('diverticulum')) INSERT INTO @tmpDiv (Val) VALUES('diverticulum')
	--	--IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('duodenitis')) INSERT INTO @tmpDiv (Val) VALUES('duodenitis')
	--	--IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('polyp')) INSERT INTO @tmpDiv (Val) VALUES('polyp')
	--	--IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('ulcer')) INSERT INTO @tmpDiv (Val) VALUES('ulcer')
	--	--IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('scar')) INSERT INTO @tmpDiv (Val) VALUES('scar')
	--	--IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('multiple ulcers')) INSERT INTO @tmpDiv (Val) VALUES('multiple ulcers')
	--	--IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('atrophic duodenum')) INSERT INTO @tmpDiv (Val) VALUES('atrophic duodenum')
	--END
              
	IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
	BEGIN
		DECLARE @XMLlist9 XML= (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)                                       
		SET @B =  dbo.fnBuildString(@XMLlist9)      
		
		SET @A = @A + '<b>Duodenum: </b>'
		IF @B <>  '' SET @A = @A + ' ' + dbo.fnFirstLetterLower(@B) + '.'
		SET @A = @A + '<br/>'                       
	END 


------ OTHER ------------------------------------------------------------------------
	DELETE FROM @tmpRegionDiv                      
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
--------------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D290P2')
	UPDATE ERS_DiagnosesMatrix SET NED_Name = 'Biliary stricture' WHERE Code = 'D290P2'
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

DECLARE @ProcedureType Int = (SELECT ProcedureType FROM ERS_Procedures WHERE ProcedureId=@ProcedureId)
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
		INSERT INTO ERS_Diagnoses (ProcedureID, MatrixCode, [Value], IsOtherData)
		VALUES (@ProcedureId, 'OverallNormal', '1', 1)
	END
	ELSE
	BEGIN
		/*OESOPHGAS REGION*/
		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Oesophagus' AND Value = 'True' AND MatrixCode <>'OesophagusNormal')
		BEGIN
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OesophagusNormal') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OesophagusNormal' AND Value = 'True'
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'OverallNormal') DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'OverallNormal'
		END
		ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Oesophagus' OR MatrixCode = 'OverallNormal')
			INSERT INTO [ERS_Diagnoses] (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'OesophagusNormal', 'True', 'Oesophagus', 1)
	
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
		ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Stomach' OR MatrixCode = 'OverallNormal')
			INSERT INTO [ERS_Diagnoses] (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'StomachNormal', 'True', 'Stomach', 1)

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
		ELSE IF NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses WHERE Region = 'Duodenum' OR MatrixCode = 'OverallNormal')
			INSERT INTO [ERS_Diagnoses] (ProcedureId, MatrixCode, Value, Region, IsOtherData) VALUES (@ProcedureId, 'DuodenumNormal', 'True', 'Duodenum', 1)

		IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Region='Duodenum' AND Value = 'True' AND MatrixCode NOT IN ('DuodenumNotEntered','Duodenum2ndPartNotEntered'))
		BEGIN
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'DuodenumNotEntered')  DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'DuodenumNotEntered' AND Value = 'True'
			IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE Value ='True' AND MatrixCode = 'Duodenum2ndPartNotEntered')  DELETE FROM [ERS_Diagnoses] WHERE ProcedureID = @ProcedureID AND MatrixCode = 'Duodenum2ndPartNotEntered' AND Value = 'True'
		END
	END

	IF EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ted WHERE Region = 'Oesophagus' AND MatrixCode = 'OesophagusNormal' AND ted.[Value] = 'True') AND
			EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ted WHERE Region = 'Stomach' AND MatrixCode = 'StomachNormal' AND ted.[Value] = 'True') AND
			EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ted WHERE Region = 'Duodenum' AND MatrixCode = 'DuodenumNormal' AND ted.[Value] = 'True') AND
			NOT EXISTS (SELECT 1 FROM #tbl_ERS_Diagnoses ted WHERE MatrixCode <> 'Summary' AND MatrixCode NOT IN ('OesophagusNormal','StomachNormal','DuodenumNormal'))
	BEGIN
		DELETE FROM ERS_Diagnoses WHERE MatrixCode IN ('OesophagusNormal','StomachNormal','DuodenumNormal')

		INSERT INTO ERS_Diagnoses (ProcedureID, MatrixCode, [Value], IsOtherData)
		VALUES (@ProcedureId, 'OverallNormal', '1', 1)
	END

	-- Don't repeat diagnoses
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode in ('D39P1', 'D84P1')) DELETE FROM ERS_Diagnoses WHERE MatrixCode = 'D49P1'
	IF EXISTS(SELECT TOP(1) 1 FROM #tbl_ERS_Diagnoses WHERE MatrixCode in ('D90P1', 'D91P1')) DELETE FROM ERS_Diagnoses WHERE MatrixCode = 'D53P1'


	INSERT INTO #tbl_ERS_Diagnoses
	(
	    ProcedureID,
	    SiteId,
	    MatrixCode,
	    [Value],
	    Region,
	    IsOtherData
	)
	SELECT  
	    ProcedureID,
	    SiteId,
	    MatrixCode,
	    [Value],
	    Region,
	    IsOtherData 
	FROM ERS_Diagnoses WHERE ProcedureId=@ProcedureId 



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
IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D196P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Dilation', 2, 'Biliary', 0, 196, 'D196P2', 1)
GO

 IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D197P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Small lakes', 2, 'Biliary', 0, 197, 'D197P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D356P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Stricture(s)', 2, 'Biliary', 1, 356, 'D356P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D357P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('intrahepatic stones', 2, 'Biliary', 1, 357, 'D357P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D96P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Atrophic duodenum', 2, 'Duodenum', 1, 96, 'D96P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D60P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Ulcer', 2, 'Duodenum', 1, 60, 'D60P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D56P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Multiple ulcers', 2, 'Duodenum', 1, 56, 'D56P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D360P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('stenosis', 2, 'Duodenum', 1, 360, 'D360P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D92P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Tumour, benign', 'Duodenal tumour - benign', 2, 'Duodenum', 1, 92, 'D92P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D93P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Tumour , malignant', 'Duodenal tumour - malignant', 2, 'Duodenum', 1, 93, 'D93P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D94P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Probable carcinoma', NULL, 2, 'Duodenum', 1, 94, 'D94P2', 0)
GO


IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D95P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Probable lymphoma', NULL, 2, 'Duodenum', 1, 95, 'D95P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D76P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Bleeding', NULL, 2, 'Pancreas', 1, 76, 'D76P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D77P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Bulging suprapapillary bile duct', NULL, 2, 'Pancreas', 1, 77, 'D77P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D78P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Patulous', NULL, 2, 'Pancreas', 1, 78, 'D78P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D361P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Irregular ducts', 2, 'Biliary', 1, 361, 'D361P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D362P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Dilated ducts', 2, 'Biliary', 1, 362, 'D362P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D363P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Annulare', NULL, 2, 'Biliary', 1, 363, 'D363P2', 0)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D121P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Stricture', 'Biliary stricture', 2, 'Intrahepatic', 0, 121, 'D121P2', 1)
GO


--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_CommonAbnoAtrophic_Delete', 'TR'
GO

EXEC DropIfExist 'TR_CommonAbnoAtrophic_Insert', 'TR'
GO

EXEC DropIfExist 'TR_CommonAbnoAtrophic', 'TR'
GO

CREATE TRIGGER [dbo].[TR_CommonAbnoAtrophic]
ON [dbo].[ERS_CommonAbnoAtrophic]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @Atrophic VARCHAR(10) = 'False',
	@Action CHAR(1) = 'I'

	IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
		@Atrophic = (CASE WHEN [Type] > 0 THEN 'True' ELSE 'False' END)
		FROM INSERTED
		
		EXEC abnormalities_atrophic_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D96P1', @Atrophic			-- 'Atrophic'
GO

--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ERCPAbnoAppearance', 'TR'
GO

CREATE TRIGGER [dbo].[TR_ERCPAbnoAppearance]
ON [dbo].[ERS_ERCPAbnoAppearance]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @ImpactedStone VARCHAR(10) = 'False', 
			@Inflamed VARCHAR(10) = 'False', @Tumour VARCHAR(10) = 'False', 
			@Bleeding VARCHAR(10), @BulgingSuprapapillary VARCHAR(10) = 'False',
			@Patulous VARCHAR(10), @Occlusion VARCHAR(10) = 'False',
			@BiliaryLeak VARCHAR(10) = 'False', @PreviousSurgery VARCHAR(10) = 'False',
			@Action CHAR(1) = 'I'

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@ImpactedStone = (CASE WHEN ImpactedStone=1 THEN 'True' ELSE 'False' END),
				--Ampulla inflamed if... appearance is Inflamed, reddened, oedenmatous or has pus exuding
				@Inflamed = (CASE WHEN Inflamed=1 OR PusExuding=1 OR Oedematous=1 OR Reddened=1 THEN 'True' ELSE 'False' END),
				@Tumour = (CASE WHEN Tumour=1 THEN 'True' ELSE 'False' END),
				@Bleeding = (CASE WHEN Bleeding=1 THEN 'True' ELSE 'False' END),
				@BulgingSuprapapillary = (CASE WHEN Suprapapillary=1 THEN 'True' ELSE 'False' END),
				@Patulous = (CASE WHEN Patulous=1 THEN 'True' ELSE 'False' END),
				@Occlusion = (CASE WHEN Occlusion=1 THEN 'True' ELSE 'False' END),
				@BiliaryLeak = (CASE WHEN BiliaryLeak=1 THEN 'True' ELSE 'False' END),
				@PreviousSurgery = (CASE WHEN PreviousSurgery=1 THEN 'True' ELSE 'False' END)

		FROM INSERTED 

		EXEC abnormalities_appearance_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D35P2', @ImpactedStone		-- 'Impacted stone'
	EXEC diagnoses_control_save @site_id, 'D37P2', @Inflamed			-- 'Inflamed'
	EXEC diagnoses_control_save @site_id, 'D43P2', @Tumour				-- 'Tumour'
	EXEC diagnoses_control_save @site_id, 'D76P2', @Bleeding				
	EXEC diagnoses_control_save @site_id, 'D77P2', @BulgingSuprapapillary				
	EXEC diagnoses_control_save @site_id, 'D78P2', @Patulous				
	EXEC diagnoses_control_save @site_id, 'D380P2', @Occlusion				
	EXEC diagnoses_control_save @site_id, 'D379P2', @BiliaryLeak				
	EXEC diagnoses_control_save @site_id, 'D381P2', @PreviousSurgery				

GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'ercp_papillaryanatomy_summary_update', 'S'
GO

CREATE PROCEDURE [dbo].[ercp_papillaryanatomy_summary_update]
(
	@ProcedureId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000) = '',
		@summarymajor VARCHAR(4000) = '',
		@summaryminor VARCHAR(4000) = '',
		@summarytemp VARCHAR(4000) = '',
		@MajorSiteLocation TINYINT,
		@MajorSize TINYINT,
		@MajorNoOfOpenings TINYINT,
		@MajorFloppy BIT,
		@MajorStenosed BIT,
		@MajorSurgeryNone BIT,
		@MajorEndoscopic BIT,
		@MajorEndoscopicSize DECIMAL,
		@MajorOperative BIT,
		@MajorOperativeSize DECIMAL,
		@MajorSphincteroplasty BIT,
		@MajorSphincteroplastySize DECIMAL,
		@MajorCholedochoduodenostomy BIT,
		@MinorSiteLocation TINYINT,
		@MinorSize TINYINT,
		@MinorStenosed BIT,
		@MinorSurgeryNone BIT,
		@MinorEndoscopic BIT,
		@MinorEndoscopicSize DECIMAL,
		@MinorOperative BIT,
		@MinorOperativeSize DECIMAL

	SELECT 
		@MajorSiteLocation=MajorSiteLocation,
		@MajorSize=MajorSize,
		@MajorNoOfOpenings=MajorNoOfOpenings,
		@MajorFloppy=MajorFloppy,
		@MajorStenosed=MajorStenosed,
		@MajorSurgeryNone=MajorSurgeryNone,
		@MajorEndoscopic=MajorEndoscopic,
		@MajorEndoscopicSize=MajorEndoscopicSize,
		@MajorOperative=MajorOperative,
		@MajorOperativeSize=MajorOperativeSize,
		@MajorSphincteroplasty=MajorSphincteroplasty,
		@MajorSphincteroplastySize=MajorSphincteroplastySize,
		@MajorCholedochoduodenostomy=MajorCholedochoduodenostomy,
		@MinorSiteLocation=MinorSiteLocation,
		@MinorSize=MinorSize,
		@MinorStenosed=MinorStenosed,
		@MinorSurgeryNone=MinorSurgeryNone,
		@MinorEndoscopic=MinorEndoscopic,
		@MinorEndoscopicSize=MinorEndoscopicSize,
		@MinorOperative=MinorOperative,
		@MinorOperativeSize=MinorOperativeSize
	FROM
		ERS_ERCPPapillaryAnatomy
	WHERE
		ProcedureId = @ProcedureId

	--IF @MajorSize = 1
	--	SET @summarymajor = 'normal'
	--ELSE 
	IF @MajorSize = 2
		SET @summarymajor = 'small'
	ELSE IF @MajorSize = 3
		SET @summarymajor = 'large'

	IF @MajorFloppy = 1
		IF @summarymajor <> '' SET @summarymajor = @summarymajor + '$$ floppy' ELSE SET @summarymajor = 'floppy'
	IF @MajorStenosed = 1
		IF @summarymajor <> '' SET @summarymajor = @summarymajor + '$$ stenosed' ELSE SET @summarymajor = 'stenosed'
	
	IF CHARINDEX('$$', @summarymajor) > 0 SET @summarymajor = STUFF(@summarymajor, len(@summarymajor) - charindex('$$', reverse(@summarymajor)), 2, ' and')
		SET @summarymajor = REPLACE(@summarymajor, '$$', ',')

	IF ISNULL(@MajorNoOfOpenings,0) = 2
		IF @summarymajor <> '' SET @summarymajor = @summarymajor + ' with two openings' ELSE SET @summarymajor = 'two openings'

	IF @MajorSiteLocation = 1
		IF @summarymajor <> '' SET @summarymajor = @summarymajor + ' in the 1st part of the duodenum' ELSE SET @summarymajor = 'in the 1st part of the duodenum'
	ELSE IF @MajorSiteLocation = 3
		IF @summarymajor <> '' SET @summarymajor = @summarymajor + ' in the 3rd part of the duodenum' ELSE SET @summarymajor = 'in the 3rd part of the duodenum'


	IF @MajorSurgeryNone = 1
		SET @summarytemp = 'no previous surgery'
	ELSE
	BEGIN 
		SET @summarytemp = ''

		IF @MajorEndoscopic = 1
		BEGIN
			SET @summarytemp = 'endoscopic sphincterotomy'
			IF ISNULL(@MajorEndoscopicSize,0) > 0 SET @summarytemp = @summarytemp + ' (' + CONVERT(varchar, @MajorEndoscopicSize) + ' mm)'
		END

		IF @MajorOperative = 1
		BEGIN
			IF @summarytemp <> '' SET @summarytemp = @summarytemp + '$$ operative sphincterotomy' ELSE SET @summarytemp = 'operative sphincterotomy'
			IF ISNULL(@MajorOperativeSize,0) > 0 SET @summarytemp = @summarytemp + ' (' + CONVERT(varchar, @MajorOperativeSize) + ' mm)'
		END

		IF @MajorSphincteroplasty = 1
		BEGIN
			IF @summarytemp <> '' SET @summarytemp = @summarytemp + '$$ sphincteroplasty' ELSE SET @summarytemp = 'sphincteroplasty'
			IF ISNULL(@MajorSphincteroplastySize,0) > 0 SET @summarytemp = @summarytemp + ' (' + CONVERT(varchar, @MajorSphincteroplastySize) + ' mm)'
		END

		IF @MajorCholedochoduodenostomy = 1
		BEGIN
			IF @summarytemp <> '' SET @summarytemp = @summarytemp + '$$ choledochoduodenostomy' ELSE SET @summarytemp = 'choledochoduodenostomy'
		END

		IF CHARINDEX('$$', @summarytemp) > 0 SET @summarytemp = STUFF(@summarytemp, len(@summarytemp) - charindex('$$', reverse(@summarytemp)), 2, ' and')
		SET @summarytemp = REPLACE(@summarytemp, '$$', ',')

		IF @summarytemp <> '' SET @summarytemp = 'previous ' + @summarytemp
	END
	
	
	
	IF @summarymajor <> '' AND @summarytemp <> ''
		SET @summarymajor = @summarymajor +  ', with ' + @summarytemp
	ELSE
		SET @summarymajor = @summarymajor + @summarytemp
	
	IF @summarymajor <> '' 
		SET @summarymajor = 'major; ' + @summarymajor


		
    IF @MinorSize = 2
		SET @summaryminor = 'small'
	ELSE IF @MinorSize = 3
		SET @summaryminor = 'large'


    IF @MinorStenosed = 1
		IF @summaryminor <> '' SET @summaryminor = @summaryminor + ' stenosed' ELSE SET @summaryminor = 'stenosed'
	
	IF @MinorSiteLocation = 1
		IF @summaryminor <> '' SET @summaryminor = @summaryminor + ' not present' ELSE SET @summaryminor = 'not present'
	ELSE IF @MinorSiteLocation = 2
		IF @summaryminor <> '' SET @summaryminor = @summaryminor + ' no attempt to visualise' ELSE SET @summaryminor = 'no attempt to visualise'
	ELSE IF @MinorSiteLocation = 3
		IF @summaryminor <> '' SET @summaryminor = @summaryminor + ' in the 1st part of the duodenum' ELSE SET @summaryminor = 'in the 1st part of the duodenum'
	--ELSE IF @MinorSiteLocation = 4
	--	IF @summaryminor <> '' SET @summaryminor = @summaryminor + ' in the 2nd part of the duodenum' ELSE SET @summaryminor = 'in the 2nd part of the duodenum'
	ELSE IF @MinorSiteLocation = 5
		IF @summaryminor <> '' SET @summaryminor = @summaryminor + ' in the 3rd part of the duodenum' ELSE SET @summaryminor = 'in the 3rd part of the duodenum'

    IF @MinorSurgeryNone = 1
		SET @summarytemp = 'no previous surgery'
	ELSE
	BEGIN 
		SET @summarytemp = ''

		IF @MinorEndoscopic = 1
		BEGIN
			SET @summarytemp = 'endoscopic sphincterotomy'
			IF ISNULL(@MinorEndoscopicSize,0) > 0 SET @summarytemp = @summarytemp + ' (' + CONVERT(varchar, @MinorEndoscopicSize) + ' mm)'
		END

		IF @MinorOperative = 1
		BEGIN
			IF @summarytemp <> '' SET @summarytemp = @summarytemp + ' and operative sphincterotomy' ELSE SET @summarytemp = 'operative sphincterotomy'
			IF ISNULL(@MinorOperativeSize,0) > 0 SET @summarytemp = @summarytemp + ' (' + CONVERT(varchar, @MinorOperativeSize) + ' mm)'
		END

		IF @summarytemp <> '' SET @summarytemp = 'previous ' + @summarytemp
	END
            
    IF @summarytemp <> '' and @summaryminor <> ''
		SET @summaryminor = @summaryminor +  ', with ' + @summarytemp
	ELSE
		SET @summaryminor = @summaryminor + @summarytemp
	
	IF @summaryminor <> '' 
		SET @summaryminor = 'minor; ' + @summaryminor


	IF @summarymajor <> '' And @summaryminor <> '' And UPPER(@summarymajor) = UPPER(@summaryminor)
        SET @summary = 'major and minor papilla ' + @summarymajor + '.'
    ELSE
        If @summarymajor <> '' And @summaryminor = ''
            SET @summary = @summarymajor --+ '.'
        Else If @summarymajor = '' And @summaryminor <> ''
            SET @summary = @summaryminor --+ '.'
        Else If @summarymajor <> '' And @summaryminor <> ''
            SET @summary = RTRIM(@summarymajor) + ': ' + @summaryminor --+ '.'
	
	IF @summary <> '' 
		SET @summary = 'Papillary anatomy: ' + @summary
	
	-- Finally update the summary in abnormalities table
	UPDATE ERS_ERCPPapillaryAnatomy
	SET Summary = @summary 
	WHERE ProcedureId = @ProcedureId

GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Occlusion' AND Object_ID = Object_ID(N'ERS_CommonAbnoDiverticulum'))
	ALTER TABLE dbo.ERS_CommonAbnoDiverticulum ADD Occlusion BIT NOT NULL CONSTRAINT DF_AbnoCommonDiverticulum_Occlusion DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'BiliaryLeak' AND Object_ID = Object_ID(N'ERS_CommonAbnoDiverticulum'))
	ALTER TABLE dbo.ERS_CommonAbnoDiverticulum ADD BiliaryLeak BIT NOT NULL CONSTRAINT DF_AbnoCommonDiverticulum_BiliaryLeak DEFAULT 0
GO

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'PreviousSurgery' AND Object_ID = Object_ID(N'ERS_CommonAbnoDiverticulum'))
	ALTER TABLE dbo.ERS_CommonAbnoDiverticulum ADD PreviousSurgery BIT NOT NULL CONSTRAINT DF_AbnoCommonDiverticulum_PreviousSurgery DEFAULT 0
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_diverticulum_save', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_diverticulum_save]
(
	@SiteId INT,
	@None BIT,
	@Pseudodiverticulum BIT,
	@Congenital1stPart BIT,
	@Congenital2ndPart BIT,
	--@Occlusion BIT,
	--@BiliaryLeak BIT,
	--@PreviousSurgery BIT,
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
			--Occlusion,
			--BiliaryLeak,
			--PreviousSurgery,
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
			--@Occlusion,
			--@BiliaryLeak,
			--@PreviousSurgery,
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

	ELSE IF (@None = 0 AND @Pseudodiverticulum = 0 AND @Congenital1stPart = 0 AND @Congenital2ndPart = 0 /*AND @Occlusion = 0 AND @BiliaryLeak = 0 AND @PreviousSurgery = 0*/ AND @Other = 0)
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
			--Occlusion = @Occlusion,
			--BiliaryLeak = @BiliaryLeak,
			--PreviousSurgery = @PreviousSurgery,
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
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_diverticulum_select', 'S'
GO

CREATE PROCEDURE [dbo].[abnormalities_diverticulum_select]
(
	@SiteId INT	
)
AS

SET NOCOUNT ON

SELECT [SiteId]
      ,[None]
      ,[Pseudodiverticulum]
      ,[Congenital1stPart]
      ,[Congenital2ndPart]
	  ,[Occlusion]
	  ,[BiliaryLeak]
	  ,[PreviousSurgery]
      ,[Other]
      ,[OtherDesc]
      ,[EUSProcType]
      ,[Summary]
  FROM 
	[ERS_CommonAbnoDiverticulum]
  WHERE 
	SiteId = @SiteId

GO
--------------------------------------------------------------------------------------------------------------------------------------------
UPDATE ERS_DiagnosesMatrix SET Section = 'Pancreas' WHERE Section = 'Pancreatitis'
UPDATE ERS_DiagnosesMatrix SET Section = 'Pancreas' WHERE Code='D305P2'
UPDATE ERS_DiagnosesMatrix SET Section = 'Intrahepatic' WHERE Code = 'D357P2'
GO

--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_UpperGIAbnoPolyps_Insert', 'TR'
GO

CREATE TRIGGER [dbo].[TR_UpperGIAbnoPolyps_Insert]
ON [dbo].[ERS_UpperGIAbnoPolyps]
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @Polyp VARCHAR(10), @TumorBenign VARCHAR(10), @TumorMalignant VARCHAR(10)
	SELECT @site_id=SiteId,
			@Polyp = (CASE WHEN (Sessile=1 OR Pedunculated=1 OR Submucosal=1) THEN 'True' ELSE 'False' END),
			@TumorBenign = (CASE WHEN (Sessile=1 OR Pedunculated=1 OR Submucosal=1) AND SessileType =1 THEN 'True' ELSE 'False' END),
			@TumorMalignant = (CASE WHEN (Sessile=1 OR Pedunculated=1 OR Submucosal=1) AND SessileType =2 THEN 'True' ELSE 'False' END)
	FROM INSERTED

	EXEC abnormalities_polyps_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D40P1', @Polyp			-- 'Polyp'
	EXEC diagnoses_control_save @site_id, 'D86P1', @TumorBenign		-- 'Tumor Benign'
	EXEC diagnoses_control_save @site_id, 'D87P1', @TumorMalignant	-- 'Tumor Malignant'

GO
--------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO ers_diagnosesmatrix (DisplayName, NED_Name, ProcedureTypeId, Section, Disabled, OrderByNumber, Code, Visible)
SELECT DisplayName, NED_Name, 7, Section, Disabled, OrderByNumber, Code, Visible FROM ERS_DiagnosesMatrix WHERE PRocedureTypeId = 2 AND 
Code NOT IN (SELECT code FROM ERS_Diagnosesmatrix WHERE proceduretypeid=7)

--------------------------------------------------------------------------------------------------------------------------------------------

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D394P2'))
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Tumour', 'Pancreatic tumor', 2, 'Pancreas', 1, 394, 'D394P2', 0)
GO

UPDATE ERS_DiagnosesMatrix SET DisplayName = 'Duodenitis , non-erosive', NED_Name = 'Duodenitis - non-erosive', Section='Duodenum' WHERE Code = 'D91P2'

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D97P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Pancreas divisum', 'Pancreas divisum', 2, 'Pancreas', 0, 97, 'D97P2', 1)
GO

--------------------------------------------------------------------------------------------------------------------------------------------
UPDATE ERS_DiagnosesMatrix SET DisplayName = 'Extrahepatic stricture' WHERE Code = 'D290P2'
UPDATE ERS_DiagnosesMatrix SET DisplayName = 'Intrahepatic stricture' WHERE Code = 'D121P2'
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_Procedure_Updated', 'TR'
GO

CREATE TRIGGER [dbo].[TR_Procedure_Updated]
   ON  [dbo].[ERS_Procedures]
   AFTER INSERT, UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @ReportUpdated bit, @ProcedureId int, @PatientId int, @ProcedureType tinyint, @pancreasDivisum VARCHAR(10) = 'False'
	SELECT @ReportUpdated = ReportUpdated, @ProcedureId = ProcedureId, 
			@PatientId = PatientId, @ProcedureType = ProcedureType,  
			@pancreasDivisum = (CASE WHEN pancreasDivisum = 1 THEN 'True' ELSE 'False' END)
	FROM INSERTED

	IF ISNULL(@ReportUpdated,0) <> 0
	BEGIN
		UPDATE ERS_Procedures SET ReportUpdated = 1 WHERE ProcedureID = @ProcedureID AND ISNULL(ReportUpdated, 0) <> 1
	END

	-- check expected patients for match on patientid, procedure type and date
	IF EXISTS(SELECT 1 FROM dbo.ERS_ExpectedPatients eep 
				WHERE PatientId = @PatientId 
					AND (eep.ProcedureType IS NULL OR eep.ProcedureType = @ProcedureType) 
					AND CONVERT(varchar(10),eep.ExpectedDateTime, 103) = CONVERT(varchar(10),GETDATE(), 103)
					AND ISNULL(eep.STATUS, 0) = 0)
	BEGIN
		UPDATE ERS_ExpectedPatients
		SET [Status] = 1
		WHERE PatientId = @PatientId 
				AND (ProcedureType IS NULL OR ProcedureType = @ProcedureType) 
				AND CONVERT(varchar(10),ExpectedDateTime, 103) = CONVERT(varchar(10),GETDATE(), 103)
	END

	IF @ProcedureType IN (2,7)
	BEGIN
		IF @pancreasDivisum = 'True'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND MatrixCode = 'D97P2' AND Value = 'True')
				INSERT INTO ERS_Diagnoses (ProcedureId, MatrixCode, Value, Region) VALUES (@ProcedureId, 'D97P2', 'True', 'Pancreas')
			ELSE
				UPDATE ERS_Diagnoses SET Value = 'True' WHERE MatrixCode = 'D97P2' --incase code exists  but with a value of false
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND MatrixCode = 'D97P2')
				DELETE FROM ERS_Diagnoses WHERE MatrixCode = 'D97P2' --incase code exists  but with a value of false
		END
	END
	
END
GO
--------------------------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D364P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Cyst(s)', 2, 'Biliary', 0, 364, 'D364P2', 1),
		   ('Cyst(s)', 7, 'Biliary', 0, 364, 'D364P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D193P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Duct injury', 2, 'Biliary', 0, 193, 'D193P2', 1),
		   ('Duct injury', 7, 'Biliary', 0, 193, 'D193P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D365P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Previous surgery', 2, 'Biliary', 0, 365, 'D365P2', 1),
		   ('Previous surgery', 7, 'Biliary', 0, 365, 'D365P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D276P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Dilated duct', 2, 'Intrahepatic', 0, 276, 'D276P2', 1),
		   ('Dilated duct', 7, 'Intrahepatic', 0, 276, 'D276P2', 1)
GO


IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D366P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Malignant', 2, 'Intrahepatic', 0, 366, 'D366P2', 1),
		   ('Malignant', 7, 'Intrahepatic', 0, 366, 'D366P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D367P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Benign', 2, 'Intrahepatic', 0, 367, 'D367P2', 1),
		   ('Benign', 7, 'Intrahepatic', 0, 367, 'D367P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D370P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('stricture', 2, 'Intrahepatic', 0, 370, 'D370P2', 1),
		   ('stricture', 7, 'Intrahepatic', 0, 367, 'D370P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D371P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('stricture', 2, 'Extrahepatic', 0, 371, 'D371P2', 1),
		   ('stricture', 7, 'Extrahepatic', 0, 374, 'D371P2', 1)
GO

--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ColonAbnoHaemorrhage_Insert', 'TR'
GO

CREATE TRIGGER [dbo].[TR_ColonAbnoHaemorrhage_Insert]
ON [dbo].[ERS_ColonAbnoHaemorrhage]
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @haemorrhage VARCHAR(10)
	SELECT @site_id=SiteId,
		@haemorrhage = (CASE WHEN (Artificial=1 OR Lesions=1 OR Melaena=1 OR Mucosal=1 OR Purpura=1 OR Transported = 1) THEN 'True' ELSE 'False' END)
	FROM INSERTED

	EXEC abnormalities_colon_haemorrhage_summary_update @site_id
	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D84P3', @haemorrhage			-- 'Haemorrhage'
GO
--------------------------------------------------------------------------------------------------------------------------------------------
UPDATE dbo.ERS_DiagnosesMatrix
SET SEction = 'Papillae' WHERE Code IN ('D76P2','D77P2','D78P2')


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
IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D372P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Biliary leak', 2, 'Biliary', 0, 372, 'D372P2', 1),
	('Biliary leak', 7, 'Biliary', 0, 372, 'D372P2', 1)
GO
--------------------------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D373P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Biliary leak', 2, 'Pancreas', 0, 373, 'D373P2', 1),
	('Biliary leak', 7, 'Pancreas', 0, 373, 'D373P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D374P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Occlusion', 2, 'Pancreas', 0, 374, 'D374P2', 1),
	('Occlusion', 7, 'Pancreas', 0, 374, 'D374P2', 1)
GO


IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D375P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Previous surgery', 2, 'Pancreas', 0, 374, 'D375P2', 1),
	('Previous surgery', 7, 'Pancreas', 0, 374, 'D375P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D376P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Mass', 2, 'Biliary', 0, 376, 'D376P2', 1),
	('Mass', 7, 'Biliary', 0, 376, 'D376P2', 1)
GO


IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D379P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Biliary leak', 2, 'Papillae', 0, 373, 'D379P2', 1),
	('Biliary leak', 7, 'Papillae', 0, 379, 'D379P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D380P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Occlusion', 2, 'Papillae', 0, 380, 'D380P2', 1),
	('Occlusion', 7, 'Papillae', 0, 380, 'D380P2', 1)
GO


IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D381P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Previous surgery', 2, 'Papillae', 0, 381, 'D381P2', 1),
	('Previous surgery', 7, 'Papillae', 0, 381, 'D381P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D382P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Diverticulum', 2, 'Biliary', 0, 382, 'D382P2', 1),
	('Diverticulum', 7, 'Biliary', 0, 382, 'D382P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D55P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Tumour', 2, 'Duodenum', 0, 55, 'D55P2', 1),
	('Tumour', 7, 'Duodenum', 0, 55, 'D55P2', 1)
GO
--------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO ers_diagnosesmatrix (DisplayName, NED_Name, ProcedureTypeId, Section, Disabled, OrderByNumber, Code, Visible)
SELECT DisplayName, NED_Name, 7, Section, Disabled, OrderByNumber, Code, Visible FROM ERS_DiagnosesMatrix WHERE PRocedureTypeId = 2 AND 
Code NOT IN (SELECT code FROM ERS_Diagnosesmatrix WHERE proceduretypeid=7)
--------------------------------------------------------------------------------------------------------------------------------------------


IF EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE DisplayName = 'Communicating' AND NED_Name = 'Pancreatic cyst' AND Code = 'D95P2')
BEGIN
	UPDATE ERS_DiagnosesMatrix SET Code = 'D100P2' WHERE DisplayName = 'Communicating' AND NED_Name = 'Pancreatic cyst' AND Code = 'D95P2'
END

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE DisplayName = 'Communicating' AND NED_Name = 'Pancreatic cyst')
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Communicating', 2, 'Cyst', 0, 381, 'D101P2', 1),
	       ('Communicating', 7, 'Cyst', 0, 381, 'D101P2', 1)
END
--------------------------------------------------------------------------------------------------------------------------------------------


EXEC DropIfExist 'TR_ERCPAbnoDuct', 'TR'
GO

CREATE TRIGGER [dbo].[TR_ERCPAbnoDuct]
ON [dbo].[ERS_ERCPAbnoDuct]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, 
			@Dilated VARCHAR(10) = 'False', 
			@DilatedType VARCHAR(10) = 'False', 
			@Fistula VARCHAR(10) = 'False', @Stones VARCHAR(10) = 'False',
			@Cysts VARCHAR(10) = 'False', @Scelerosing VARCHAR(10) = 'False',
			@CystsCommunicating VARCHAR(10) = 'False', @CystsNonCommunicating VARCHAR(10) = 'False',
			@CystsCholedochal VARCHAR(10) = 'False',
			@TumourCystadenoma VARCHAR(10) = 'False', @TumourProbablyMalignant VARCHAR(10) = 'False',
			@Cholangiocarcinoma VARCHAR(10) = 'False', @ExternalCompression VARCHAR(10) = 'False',
			@Polycystic VARCHAR(10) = 'False', @HydatidCyst VARCHAR(10) = 'False',
			@LiverAbscess VARCHAR(10) = 'False', @PostCholecystectomy VARCHAR(10) = 'False',
			@Stricture VARCHAR(10) = 'False', @StrictureProbably VARCHAR(10) = 'False',
			@StrictureProbablyBenign VARCHAR(10) = 'False', @StrictureMalignant VARCHAR(10) = 'False', 
			@DuctInjury VARCHAR(10) = 'False', @StentOcclusion VARCHAR(10) = 'False',
			@GallBladderTumor VARCHAR(10) = 'False', @Mirizzi VARCHAR(10) = 'False',
			@AnastomicStricture VARCHAR(10) = 'False', @PancreaticTumour VARCHAR(10) = 'False',
			@Occlusion VARCHAR(10) = 'False', @PreviousSurgery VARCHAR(10) = 'False',
			@BiliaryLeak VARCHAR(10) = 'False', @CalculousObstruction VARCHAR(10) = 'False',
			@Tumour VARCHAR(10) = 'False', @Diverticulum VARCHAR(10) = 'False',
			@Action CHAR(1) = 'I', @Area varchar(50), @Region varchar(50)

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Dilated = (CASE WHEN Dilated = 1 THEN 'True' ELSE 'False' END),
				@DilatedType = (CASE WHEN DilatedType = 1 THEN 'True' ELSE 'False' END),   --DilatedType -> No obvious cause
				@PostCholecystectomy = (CASE WHEN DilatedType = 2 THEN 'True' ELSE 'False' END),   --DilatedType -> Post cholecystectomy
				@Stricture = (CASE WHEN Stricture = 1  THEN 'True' ELSE 'False' END),
				@Fistula = (CASE WHEN Fistula = 1 THEN 'True' ELSE 'False' END),
				@Stones = (CASE WHEN Stones = 1 THEN 'True' ELSE 'False' END),
				@Cysts = (CASE WHEN Cysts = 1 THEN 'True' ELSE 'False' END),
				@CystsCommunicating = (CASE WHEN Cysts = 1 AND CystsCommunicating = 1 THEN 'True' ELSE 'False' END),
				@CystsNonCommunicating = (CASE WHEN Cysts = 1 AND CystsCommunicating = 0 AND (CystsSimple = 0 AND CystsRegular = 0 AND CystsIrregular = 0 AND CystsLoculated = 0) THEN 'True' ELSE 'False' END),
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
				@GallBladderTumor = (CASE WHEN GallBladderTumor = 1 THEN 'True' ELSE 'False' END),
				@AnastomicStricture = (CASE WHEN AnastomicStricture = 1 THEN 'True' ELSE 'False' END),
				@Occlusion = (CASE WHEN Occlusion = 1 THEN 'True' ELSE 'False' END),
				@Mirizzi = (CASE WHEN MirizziSyndrome = 1 THEN 'True' ELSE 'False' END),
				@PancreaticTumour = (CASE WHEN PancreaticTumour = 1 THEN 'True' ELSE 'False' END),
				@BiliaryLeak = (CASE WHEN BiliaryLeak = 1 THEN 'True' ELSE 'False' END),
				@PreviousSurgery = (CASE WHEN PreviousSurgery = 1 THEN 'True' ELSE 'False' END),
				@Diverticulum = (CASE WHEN Diverticulum = 1 THEN 'True' ELSE 'False' END),
				@CalculousObstruction = (CASE WHEN CalculousObstruction = 1 THEN 'True' ELSE 'False' END),
				@Scelerosing = (CASE WHEN SclerosingCholangitis = 1 THEN 'True' ELSE 'False' END)




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
			
		EXEC diagnoses_control_save @site_id, 'D101P2', @CystsCommunicating		-- Communicating
		EXEC diagnoses_control_save @site_id, 'D100P2', @CystsNonCommunicating	-- NonCommunicating
		EXEC diagnoses_control_save @site_id, 'D105P2', @CystsCholedochal		-- Pseudocyst
		EXEC diagnoses_control_save @site_id, 'D72P2',	@Stones					-- 'Pancreatic stone'
		EXEC diagnoses_control_save @site_id, 'D130P2',	@TumourCystadenoma		-- 'Cystadenoma'

		EXEC diagnoses_control_save @site_id, 'D125P2',	@TumourProbablyMalignant-- 'Probably malignant'
		EXEC diagnoses_control_save @site_id, 'D390P2', @StrictureProbably			-- 'Extrahepatic probable'
		EXEC diagnoses_control_save @site_id, 'D391P2', @StrictureProbablyBenign	-- 'Benign'

		IF @Stricture = 'True' AND (@TumourProbablyMalignant = 'False' AND @StrictureProbablyBenign = 'False')
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D120P2', @Stricture	-- 'Benign'
		END

		EXEC diagnoses_control_save @site_id, 'D69P2',	@DuctInjury				-- 'Duct injury'
		EXEC diagnoses_control_save @site_id, 'D74P2',	@StentOcclusion			-- 'Stent occlusion'D140P2
		EXEC diagnoses_control_save @site_id, 'D91P2',	@PancreaticTumour

		EXEC diagnoses_control_save @site_id, 'D373P2',	@BiliaryLeak
		EXEC diagnoses_control_save @site_id, 'D374P2',	@Occlusion
		EXEC diagnoses_control_save @site_id, 'D375P2',	@PreviousSurgery

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


		EXEC diagnoses_control_save @site_id, 'D276P2', @Dilated			-- 'Dilatation'   
		EXEC diagnoses_control_save @site_id, 'D393P2', @PostCholecystectomy	-- 'Post cholecystectomy'


		EXEC diagnoses_control_save @site_id, 'D193P2', @DuctInjury					-- 'Duct injury'
		EXEC diagnoses_control_save @site_id, 'D195P2', @StentOcclusion				-- 'Stent occlusion'

		EXEC diagnoses_control_save @site_id, 'D145P2',	@Fistula				-- 'Fistula'

		--Diagnosis polycystic liver disease if patient has suspected polycystic liver disease set in duct abnos...
		EXEC diagnoses_control_save @site_id, 'D200P2', @Polycystic				--Polycystic liver disease

		EXEC diagnoses_control_save @site_id, 'D235P2', @HydatidCyst			--Hydatid Cyst
		EXEC diagnoses_control_save @site_id, 'D240P2', @LiverAbscess			--Liver abscess
		EXEC diagnoses_control_save @site_id, 'D140P2',	@AnastomicStricture		-- 'Stent occlusion'
		EXEC diagnoses_control_save @site_id, 'D150P2',	@Occlusion				-- 'Occlusion'
		EXEC diagnoses_control_save @site_id, 'D121P2',	@Stricture				-- 'Intrahepatic stricture'
		EXEC diagnoses_control_save @site_id, 'D364P2',	@Cysts				-- 'Intrahepatic stricture'
		EXEC diagnoses_control_save @site_id, 'D392P2', @CystsCommunicating		-- Communicating
		EXEC diagnoses_control_save @site_id, 'D365P2',	@PreviousSurgery

		EXEC diagnoses_control_save @site_id, 'D225P2', @Tumour	
		EXEC diagnoses_control_save @site_id, 'D367P2', @StrictureProbablyBenign	-- 'Benign'
		EXEC diagnoses_control_save @site_id, 'D366P2', @TumourProbablyMalignant	-- 'Malignant'
		EXEC diagnoses_control_save @site_id, 'D368P2', @StrictureProbably			-- 'Extrahepatic probable'

		IF LOWER(@Region) NOT IN ('right hepatic lobe', 'left hepatic lobe')
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D160P2',	@Mirizzi		
		END
		
		IF LOWER(@Region) NOT IN ('right hepatic ducts', 'left hepatic ducts')
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D192P2',	@Stones				-- 'Intrahepatic stricture'
			EXEC diagnoses_control_save @site_id, 'D205P2',	@Scelerosing				-- 'Intrahepatic stricture'

		END

		IF LOWER(@Region) IN ('right hepatic ducts', 'left hepatic ducts')
		BEGIN
			EXEC diagnoses_control_save @site_id, 'D205P2',	@Scelerosing				-- 'Intrahepatic stricture'
			EXEC diagnoses_control_save @site_id, 'D372P2',	@BiliaryLeak
			
		END
	END

------ DIAGNOSES FOR EXTRAHEPATIC SITES i.e below the bifurcation --------------------------------------------------
	ELSE IF LOWER(@Region) IN ('gall bladder', 'common bile duct', 'common hepatic duct', 'cystic duct', 'bifurcation') --'GallBladder and the regions close to it
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D275P2', @Dilated				-- 'Dilated duct'
		EXEC diagnoses_control_save @site_id, 'D270P2', @CystsCholedochal		-- 'Choledochal cyst'
		EXEC diagnoses_control_save @site_id, 'D300P2', @PostCholecystectomy	-- 'Post cholecystectomy'
		EXEC diagnoses_control_save @site_id, 'D290P2', @Stricture				-- 'Stricture'
		
		EXEC diagnoses_control_save @site_id, 'D378P2', @Tumour	
		EXEC diagnoses_control_save @site_id, 'D330P2', @StrictureProbablyBenign	-- 'Benign'
		EXEC diagnoses_control_save @site_id, 'D335P2', @TumourProbablyMalignant	-- 'Malignant'
		EXEC diagnoses_control_save @site_id, 'D325P2', @StrictureProbably			-- 'Extrahepatic probable'
		EXEC diagnoses_control_save @site_id, 'D193P2', @DuctInjury					-- 'Duct injury'
		EXEC diagnoses_control_save @site_id, 'D195P2', @StentOcclusion				-- 'Stent occlusion'

		EXEC diagnoses_control_save @site_id, 'D145P2',	@Fistula					-- 'Fistula'
		EXEC diagnoses_control_save @site_id, 'D140P2',	@AnastomicStricture		-- 'Stent occlusion'
		EXEC diagnoses_control_save @site_id, 'D150P2',	@Occlusion				-- 'Occlusion'
		EXEC diagnoses_control_save @site_id, 'D364P2',	@Cysts				-- 'Intrahepatic stricture'
		EXEC diagnoses_control_save @site_id, 'D392P2', @CystsCommunicating		-- Communicating

		EXEC diagnoses_control_save @site_id, 'D365P2',	@PreviousSurgery


		
		IF LOWER(@Region) IN ('common bile duct', 'common hepatic duct', 'bifurcation')
			EXEC diagnoses_control_save @site_id, 'D160P2',	@Mirizzi		
			EXEC diagnoses_control_save @site_id, 'D372P2',	@BiliaryLeak

	END


	--Biliary : stone abnormalities
	IF LOWER(@Region) IN ('gall bladder') --Stones in Gall Bladder
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D180P2',	@GallBladderTumor			-- 'Gall bladder tumor'
		EXEC diagnoses_control_save @site_id, 'D189P2', @Stones		-- Diagnosis : Stones in Gall Bladder
		EXEC diagnoses_control_save @site_id, 'D382P2', @Diverticulum		-- Diagnosis : Stones in Gall Bladder
	END 
	ELSE IF LOWER(@Region) IN ('common bile duct', 'cystic duct')	-- Stones in cystic duct and/or common bile duct
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D191P2', @Stones		-- Diagnosis : Stones in the bile duct		

		--EXEC diagnoses_control_save @site_id, 'D378P2', @Tumour	
		--EXEC diagnoses_control_save @site_id, 'D121P2',	@Stricture				-- 'Intrahepatic stricture'
		--EXEC diagnoses_control_save @site_id, 'D330P2', @StrictureProbablyBenign	-- 'Benign'
		--EXEC diagnoses_control_save @site_id, 'D335P2', @TumourProbablyMalignant	-- 'Malignant'
		--EXEC diagnoses_control_save @site_id, 'D325P2', @StrictureProbably			-- 'Extrahepatic probable'
	END
	ELSE IF LOWER(@Region) IN ('common hepatic duct', 'bifurcation', 'right intra-hepatic ducts', 'right hepatic ducts', 
								'left intra-hepatic ducts', 'left hepatic ducts') --'Stones in the common hepatic duct and/or bifurcation and/or left hepatic duct and/or left intra hepatic duct and/or right hepatic duct and/or right intra hepatic duct
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D192P2', @Stones		-- Diagnosis : Stones in the hepatic duct	
	END

	IF LOWER(@Region) IN ('cystic duct')
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D175P2',	@CalculousObstruction
	END	
GO
--------------------------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D95P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Probable lymphoma', NULL, 2, 'Duodenum', 1, 95, 'D95P2', 0)
GO

--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D10P3')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Colonic tumour', 3, 'Colon', 0, 10, 'D10P3', 1)
GO
--------------------------------------------------------------------------------------------------------------------------------------------


EXEC DropIfExist 'TR_ColonAbnoLesions_Delete', 'TR'
GO

EXEC DropIfExist 'TR_ColonAbnoLesions_Insert', 'TR'
GO

EXEC DropIfExist 'TR_ColonAbnoLesions', 'TR'
GO

CREATE TRIGGER [dbo].[TR_ColonAbnoLesions]
ON [dbo].[ERS_ColonAbnoLesions]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @ColonicPolyp VARCHAR(10), @RectalPolyp VARCHAR(10), @ColorectalCancer VARCHAR(10), @BenignTumour VARCHAR(10),
			 @ProbablyMalignantTumour VARCHAR(10), @Tumour VARCHAR(10), @Action CHAR(1) ='I'

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	IF @Action IN ('I', 'U') 
	BEGIN
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
					OR (Granuloma = 1 AND GranulomaQuantity > 0)) THEN 'True' ELSE 'False' END),
				@Tumour = (CASE WHEN ((Submucosal=1 AND SubmucosalType=0) OR (Villous=1 AND VillousType=0) OR 
					(Ulcerative=1 AND UlcerativeType=0) Or (Stricturing=1 AND StricturingType=0) 
					OR (Polypoidal=1 AND PolypoidalType=0) OR (PneumatosisColi = 1) OR (Dysplastic = 1 AND DysplasticQuantity >0) 
					OR (Granuloma = 1 AND GranulomaQuantity > 0)) THEN 'True' ELSE 'False' END)
		FROM INSERTED
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC abnormalities_colon_lesions_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D12P3', @ColonicPolyp			-- 'ColonicPolyp'
	EXEC diagnoses_control_save @site_id, 'D4P3', @RectalPolyp				-- 'RectalPolyp'
	EXEC diagnoses_control_save @site_id, 'D69P3', @ColorectalCancer		-- 'Colorectal cancer'
	EXEC diagnoses_control_save @site_id, 'D6P3', @BenignTumour				-- 'Benign colonic tumour'
	EXEC diagnoses_control_save @site_id, 'D8P3', @ProbablyMalignantTumour	-- 'Malignant colonic tumour'
	EXEC diagnoses_control_save @site_id, 'D10P3', @Tumour	-- 'Malignant colonic tumour'

GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D25P3')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Ulcerative mucosa', 3, 'Colon', 0, 25, 'D25P3', 1)

GO
--------------------------------------------------------------------------------------------------------------------------------------------


EXEC DropIfExist 'TR_ColonAbnoMucosa_Delete','TR'
GO

EXEC DropIfExist 'TR_ColonAbnoMucosa_Insert','TR'
GO

EXEC DropIfExist 'TR_ColonAbnoMucosa','TR'
GO

CREATE TRIGGER [dbo].[TR_ColonAbnoMucosa]
ON [dbo].[ERS_ColonAbnoMucosa]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @RedundantRectal VARCHAR(10), @HasUlcer VARCHAR(10), @UserID as int, @Mucosa VARCHAR(10), @UlcerativeMucosa VARCHAR(10), @Action CHAR(1) ='I'

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId, 
			@RedundantRectal = (CASE WHEN (RedundantRectal=1) THEN 'True' ELSE 'False' END),
			@HasUlcer = (CASE WHEN (SmallUlcers=1 OR LargeUlcers=1 OR PleomorphicUlcers=1 OR SerpiginousUlcers=1 
									OR AphthousUlcers=1 OR ConfluentUlceration=1 OR DeepUlceration=1 OR SolitaryUlcer=1)
									THEN 'True' ELSE 'False' END),
			@UserID = (CASE WHEN ISNULL(WhoUpdatedId,0) = 0 THEN WhoCreatedId ELSE WhoUpdatedId END),
			@Mucosa = (CASE WHEN ([None] = 0 AND Ulcerative = 0) THEN 'True' ELSE 'False' END),
			@UlcerativeMucosa = (CASE WHEN (CobblestoneMucosa = 0) THEN 'True' ELSE 'False' END)


		FROM INSERTED
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC abnormalities_mucosa_summary_update @site_id
	EXEC sites_summary_update @site_id

	EXEC infer_mucosa_diagnoses @site_id, @UserID

	EXEC diagnoses_control_save @site_id, 'D15P3', @RedundantRectal		-- 'Redundant anterior rectal mucosa'
	EXEC diagnoses_control_save @site_id, 'D80P3', @HasUlcer			-- 'Rectal ulcer(s)', D83P3 for 'Colonic ulcer(s)'
	EXEC diagnoses_control_save @site_id, 'D21P3', @Mucosa
	EXEC diagnoses_control_save @site_id, 'D25P3', @UlcerativeMucosa
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
	
	
	IF EXISTS(SELECT 1 FROM ERS_Sites WHERE SiteId = @SiteId)
	BEGIN
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


		IF @ColonNormal = 0 
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureID AND (MatrixCode = 'ColonNormal')

		IF @ColonRestNormal = 0
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureID AND (MatrixCode = 'ColonRestNormal')

		IF  @Colitis = 0
		BEGIN
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureID AND (MatrixCode = 'Colitis')
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureID AND (MatrixCode = 'ColitisType')
		END

		IF  @Ileitis = 0
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureID AND (MatrixCode = 'Ileitis')

		IF @Proctitis = 0
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureID AND (MatrixCode = 'Proctitis')

		IF @ColitisType = '' OR @ColitisType = 0
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureID AND (MatrixCode = 'ColitisType')

		IF @ColitisExtent = '' OR @ColitisExtent =0
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureID AND (MatrixCode = 'ColitisExtent')

		IF @MayoScore = '' OR @MayoScore = 0
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureID AND (MatrixCode = 'MayoScore')

		IF @SEScore = '' OR @SEScore = 0
			DELETE FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureID AND (MatrixCode = 'SEScore')
		--EXEC ogd_diagnoses_summary_update @ProcedureId;
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
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D112P2'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Pseudodiverticulum', 2, 'Duodenum', 1, 112, 'D112P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Pseudodiverticulum', 7, 'Duodenum', 1, 112, 'D112P1', 0)
END
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D111P2'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Duodenal stenosis', 2, 'Duodenum', 1, 111, 'D111P2', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Duodenal stenosis', 7, 'Duodenum', 1, 111, 'D111P2', 0)
END
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D113P2'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Deformity', 2, 'Duodenum', 1, 113, 'D113P2', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Deformity', 7, 'Duodenum', 1, 113, 'D113P2', 0)
END
GO
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D114P2'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Pyloric deformity', 2, 'Stomach', 1, 114, 'D114P2', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Pyloric deformity', 7, 'Stomach', 1, 114, 'D114P2', 0)
END
GO


IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D383P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Biliary leak', 2, 'Papillae', 0, 383, 'D383P2', 1),
	('Biliary leak', 7, 'Papillae', 0, 383, 'D383P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D384P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Occlusion', 2, 'Papillae', 0, 384, 'D384P2', 1),
	('Occlusion', 7, 'Papillae', 0, 384, 'D384P2', 1)
GO


IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D385P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Previous surgery', 2, 'Papillae', 0, 385, 'D385P2', 1),
	('Previous surgery', 7, 'Papillae', 0, 385, 'D385P2', 1)
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ERCPAbnoDiverticulum','TR'
GO

CREATE TRIGGER [dbo].[TR_ERCPAbnoDiverticulum]
ON [dbo].[ERS_ERCPAbnoDiverticulum]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @Proximity VARCHAR(10) = 'False', @BiliaryLeak VARCHAR(10) = 'False',
	@Occlusion VARCHAR(10), @PreviousSurgery VARCHAR(10),
			@Action CHAR(1) = 'I'

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
			@Proximity = (CASE WHEN Proximity IN (2,3) THEN 'True' ELSE 'False' END),   --if Proximity is "ampulla at edge" or "ampulla within diverticulum"7
			@BiliaryLeak = (CASE WHEN BiliaryLeak = 1 THEN 'True' ELSE 'False' END),
			@PreviousSurgery = (CASE WHEN PreviousSurgery = 1 THEN 'True' ELSE 'False' END),
			@Occlusion = (CASE WHEN Occlusion = 1 THEN 'True' ELSE 'False' END)

		FROM INSERTED

		EXEC abnormalities_diverticulum_summary_ercp_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D39P2', @Proximity		-- 'Periampullary diverticula'
	EXEC diagnoses_control_save @site_id, 'D383P2', @BiliaryLeak		-- 'Periampullary diverticula'
	EXEC diagnoses_control_save @site_id, 'D385P2', @PreviousSurgery		-- 'Periampullary diverticula'
	EXEC diagnoses_control_save @site_id, 'D384P2', @Occlusion		-- 'Periampullary diverticula'


GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ERCPAbnoTumour', 'TR'
GO


CREATE TRIGGER [dbo].[TR_ERCPAbnoTumour]
ON [dbo].[ERS_ERCPAbnoTumour]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @Tumour VARCHAR(10) = 'False', @BiliaryLeak VARCHAR(10) = 'False',
	@Occlusion VARCHAR(10), @PreviousSurgery VARCHAR(10),  
			@Action CHAR(1) = 'I'

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Tumour = (CASE WHEN Firm=1 OR Friable=1 OR Ulcerated=1 OR Villous=1 
										OR Polypoid=1 OR SubMucosal=1 OR ISNULL(Other,'') <> '' THEN 'True' ELSE 'False' END),
				@BiliaryLeak = (CASE WHEN BiliaryLeak = 1 THEN 'True' ELSE 'False' END),
				@PreviousSurgery = (CASE WHEN PreviousSurgery = 1 THEN 'True' ELSE 'False' END),
				@Occlusion = (CASE WHEN Occlusion = 1 THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_tumour_summary_ercp_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D43P2', @Tumour				-- 'Tumour'
		EXEC diagnoses_control_save @site_id, 'D383P2', @BiliaryLeak		-- 'Periampullary diverticula'
	EXEC diagnoses_control_save @site_id, 'D385P2', @PreviousSurgery		-- 'Periampullary diverticula'
	EXEC diagnoses_control_save @site_id, 'D384P2', @Occlusion		-- 'Periampullary diverticula'
GO
--------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'Otherdata_Visualisation_Summary_Update','S'
GO

CREATE PROCEDURE [dbo].[Otherdata_Visualisation_Summary_Update]
(
	@ProcedureID	AS INT
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	DECLARE
		@AccessVia					int,
		@AccessViaOtherText			varchar(500),
		@MajorPapillaBile			smallint ,
		@MajorPapillaBileReason		varchar(50) ,
		@MajorPapillaPancreatic		smallint ,
		@MajorPapillaPancreaticReason varchar(50) ,
		@MinorPapilla				smallint ,
		@MinorPapillaReason			varchar(50) ,
		@HepatobiliaryNotVisualised bit ,
		@HepatobiliaryWholeBiliary	bit ,
		@ExceptBileDuct				bit ,
		@ExceptGallBladder			bit ,
		@ExceptCommonHepaticDuct	bit ,
		@ExceptRightHepaticDuct		bit ,
		@ExceptLeftHepaticDuct		bit ,
		@HepatobiliaryAcinarFilling bit ,
		@HepatobiliaryLimitedBy		smallint ,
		@HepatobiliaryLimitedByOtherText varchar(500) ,
		@PancreaticNotVisualised	bit ,
		@PancreaticDivisum			bit ,
		@PancreaticWhole			bit ,
		@ExceptAccesoryPancreatic	bit ,
		@ExceptMainPancreatic		bit ,
		@ExceptUncinate				bit ,
		@ExceptHead					bit ,
		@ExceptNeck					bit ,
		@ExceptBody					bit ,
		@ExceptTail					bit ,
		@PancreaticAcinar			bit ,
		@PancreaticLimitedBy		smallint ,
		@PancreaticLimitedByOtherText varchar(500) ,
		@HepatobiliaryFirst			smallint ,
		@HepatobiliaryFirstML		varchar(50) ,
		@HepatobiliarySecond		smallint ,
		@HepatobiliarySecondML		varchar(50) ,
		@HepatobiliaryBalloon		bit ,
		@PancreaticFirst			smallint ,
		@PancreaticFirstML			varchar(50) ,
		@PancreaticSecond			smallint ,
		@PancreaticSecondML			varchar(50) ,
		@PancreaticBalloon			bit,
		@DuodenumNormal				bit,
		@DuodenumNotEntered			bit,
		@Duodenum2ndPartNotEntered	bit;

		SELECT 
			@AccessVia						= AccessVia,
			@AccessViaOtherText				= AccessViaOtherText,
			@MajorPapillaBile				= COALESCE(MajorPapillaBile_ER, MajorPapillaBile),
			@MajorPapillaBileReason			= COALESCE(MajorPapillaBileReason_ER, MajorPapillaBileReason),
			@MajorPapillaPancreatic			= COALESCE(MajorPapillaPancreatic_ER, MajorPapillaPancreatic),
			@MajorPapillaPancreaticReason	= COALESCE(MajorPapillaPancreaticReason_ER, MajorPapillaPancreaticReason),
			@MinorPapilla					= COALESCE(MinorPapilla_ER, MinorPapilla),
			@MinorPapillaReason				= COALESCE(MinorPapillaReason_ER, MinorPapillaReason),
			@HepatobiliaryNotVisualised		= HepatobiliaryNotVisualised,
			@HepatobiliaryWholeBiliary		= HepatobiliaryWholeBiliary,
			@ExceptBileDuct					= ExceptBileDuct,
			@ExceptGallBladder				= ExceptGallBladder,
			@ExceptCommonHepaticDuct		= ExceptCommonHepaticDuct,
			@ExceptRightHepaticDuct			= ExceptRightHepaticDuct,
			@ExceptLeftHepaticDuct			= ExceptLeftHepaticDuct,
			@HepatobiliaryAcinarFilling		= HepatobiliaryAcinarFilling,
			@HepatobiliaryLimitedBy			= HepatobiliaryLimitedBy,
			@HepatobiliaryLimitedByOtherText = HepatobiliaryLimitedByOtherText,
			@PancreaticNotVisualised		= PancreaticNotVisualised,
			@PancreaticDivisum				= PancreaticDivisum,
			@PancreaticWhole				= PancreaticWhole,
			@ExceptAccesoryPancreatic		= ExceptAccesoryPancreatic,
			@ExceptMainPancreatic			= ExceptMainPancreatic,
			@ExceptUncinate					= ExceptUncinate,
			@ExceptHead						= ExceptHead,
			@ExceptNeck						= ExceptNeck,
			@ExceptBody						= ExceptBody,
			@ExceptTail						= ExceptTail,
			@PancreaticAcinar				= PancreaticAcinar,
			@PancreaticLimitedBy			= PancreaticLimitedBy,
			@PancreaticLimitedByOtherText	= PancreaticLimitedByOtherText,
			@HepatobiliaryFirst				= HepatobiliaryFirst,
			@HepatobiliaryFirstML			= HepatobiliaryFirstML,
			@HepatobiliarySecond			= HepatobiliarySecond,
			@HepatobiliarySecondML			= HepatobiliarySecondML,
			@HepatobiliaryBalloon			=HepatobiliaryBalloon,
			@PancreaticFirst				= PancreaticFirst,
			@PancreaticFirstML				= PancreaticFirstML,
			@PancreaticSecond				= PancreaticSecond,
			@PancreaticSecondML				= PancreaticSecondML,
			@PancreaticBalloon				= PancreaticBalloon,
			@DuodenumNormal					= DuodenumNormal,
			@DuodenumNotEntered				= DuodenumNotEntered,
			@Duodenum2ndPartNotEntered		= Duodenum2ndPartNotEntered


		FROM [ERS_Visualisation] 
		WHERE ProcedureID = @ProcedureId;

        DECLARE @A varchar(2000)='', @B varchar(2000)='' , @C varchar(2000)='', @AR1 varchar(2000)='', @AR2 varchar(2000)=''
        DECLARE @C1 varchar(500) =''
        DECLARE @Reasons1 varchar(2000)='', @Reasons2 varchar(2000) ='', @Reasons3 varchar(2000), @Reasons4 varchar(2000)
        DECLARE @tmp1 TABLE(Val VARCHAR(MAX))
        DECLARE @tmp2 TABLE(Val VARCHAR(MAX))
        DECLARE @NoHepExcept bit=0,  @NoPanExcept bit =0

        IF @AccessVia > 0 
            BEGIN
            IF ISNULL(@AccessViaOtherText,0) > 0 SET @A = ISNULL((SELECT ListItemText + '. ' FROM ERS_Lists where ListDescription='ERCP other access point' AND  ListItemNo = ISNULL(@AccessViaOtherText,0)  AND LOWER(ListItemText) <> '(none)'),'') 
            END
        SET @B='Cannulation via the major papilla to the bile and pancreatic ducts was unsuccessful '

        IF @MajorPapillaBile =1 AND @MajorPapillaPancreatic =1
        BEGIN
            SET @A = @A + 'Cannulation via the major papilla to the bile and pancreatic ducts was successful '
            SET @B= ''    
            DECLARE @CannDev VARCHAR(50) = ''               
            IF ISNULL(@MajorPapillaBileReason,'')<>'' SET @B = ISNULL((SELECT ISNULL(ListItemText,'') FROM ERS_Lists where ListDescription='ERCP via major to bile successful using' AND  ListItemNo = ISNULL(@MajorPapillaBileReason,0) AND LOWER(ListItemText) <> '(none)'),'')
            IF @B <> '' IF LEFT(@B, 1) IN ('a','e','i','o','u') SET @B= 'an ' + @B ELSE SET @B= 'a '+ @B
            IF LEN(LTRIM(RTRIM(@B)))  > 0 SET @CannDev = 'using ' + @B
            DECLARE @B1 varchar(50) =''

            IF ISNULL(@MajorPapillaPancreaticReason,'')<>'' SET @B1 = ISNULL((SELECT ISNULL(ListItemText,'') FROM ERS_Lists where ListDescription='ERCP via major to pancreatic successful using' AND  ListItemNo = ISNULL(@MajorPapillaPancreaticReason,0) AND LOWER(ListItemText) <> '(none)'),'')
            IF @B1 <> '' IF LEFT(@B1, 1) IN ('a','e','i','o','u') SET @B1= 'an ' + @B1 ELSE SET @B1= 'a '+ @B1
            IF LEN(LTRIM(RTRIM(@B1)))  > 0
                    BEGIN
                    IF LEN(@CannDev)>0
                            BEGIN 
                            IF LTRIM(RTRIM(@B)) <> LTRIM(RTRIM(@B1)) SET @CannDev = @CannDev + ' and  ' + @B1
                            END
                    ELSE IF @B1 <> '' SET @CannDev = 'using '+ @B1
                    END
            IF LEN(LTRIM(RTRIM(@CannDev)))>0 SET @A = @A + @CannDev + '. '
            ELSE SET @A = LTRIM(RTRIM(@A)) + '. '
        END
        ELSE IF @MajorPapillaBile =3 AND @MajorPapillaPancreatic =3
        BEGIN
            SET @A = @A + 'Cannulation via the major papilla to the bile and pancreatic ducts was not attempted. '
        END
        ELSE
        BEGIN
            SET @Reasons1 = ISNULL((SELECT ISNULL(ListItemText,'') FROM ERS_Lists where ListDescription='ERCP via major to bile successful using' AND  ListItemNo = ISNULL(@MajorPapillaBileReason,0) AND LOWER(ListItemText) <> '(none)'),'')
            SET @Reasons2 = ISNULL((SELECT ISNULL(ListItemText,'') FROM ERS_Lists where ListDescription='ERCP via major to pancreatic successful using' AND  ListItemNo = ISNULL(@MajorPapillaPancreaticReason,0) AND LOWER(ListItemText) <> '(none)'),'')
            IF @MajorPapillaBile =4 AND @MajorPapillaPancreatic =4 AND @Reasons1 = @Reasons2 
                    BEGIN
                    IF ISNULL(@MajorPapillaBileReason,0)=0 AND ISNULL(@MajorPapillaBileReason,0)=0 SET @A = @A + @B
                    ELSE SET @A = @A + LTRIM(RTRIM(@B)) + ', limited by ' + @Reasons1
                    SET @A = LTRIM(RTRIM(@A) ) + '. '
                    END
            ELSE
                    BEGIN
                    DECLARE @CAN varchar(1000)='', @AndBut varchar(50)=''
                    SET @B= 'Cannulation via the major papilla to the bile duct was '
                    SET @C= ''
                    SET @AndBut='and'
                    IF (@MajorPapillaBile=1 AND (@MajorPapillaPancreatic=4 OR @MajorPapillaPancreatic=2 )) OR ( @MajorPapillaPancreatic=1 AND (@MajorPapillaBile=4 OR @MajorPapillaBile=2)) SET @AndBut='but'
                    IF @MajorPapillaBile =1
                            BEGIN
                            SET @C= @B + 'successful'
                            SET @B=''
                            SET @B= ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to bile successful using' AND  ListItemNo = ISNULL(@MajorPapillaBileReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                            IF @B<>'' IF LEFT(@B, 1) IN ('a','e','i','o','u') SET @C= @C + ' using an ' + @B ELSE SET @C= @C + ' using a ' + @B
                            END
                    ELSE IF @MajorPapillaBile =3 SET @C= @B + 'not attempted'
                    ELSE IF @MajorPapillaBile =4
                            BEGIN
                            SET @Reasons1=ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to bile unsuccessful due to' AND  ListItemNo = ISNULL(@MajorPapillaBileReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                            IF @Reasons1='' SET @C = @B + 'unsuccessful'
                            ELSE 
                                BEGIN 
                                SET @C= @B + 'unsuccessful due to ' + @Reasons1
                                SET @CAN = ' cannulation '
                                END
                            END
                    ELSE IF @MajorPapillaBile =2
                            BEGIN
                            SET @Reasons1=ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to bile partially successful reason' AND  ListItemNo = ISNULL(@MajorPapillaBileReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                            IF @Reasons1='' SET @C = @B + 'partially successful'
                            ELSE 
                                BEGIN 
                                SET @C= @B + 'partially successful due to ' + @Reasons1
                                SET @CAN = ' cannulation '
                                END
                            END

                            DECLARE @Comma varchar(50)=''
                            IF @C ='' SET @B = 'cannulation via the major papilla to pancreatic duct was '
                            ELSE 
                                BEGIN
                                SET @Reasons1 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to bile unsuccessful due to' AND  ListItemNo = ISNULL(@MajorPapillaBileReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                                SET @Reasons2 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to pancreatic unsuccessful due to' AND  ListItemNo = ISNULL(@MajorPapillaPancreatic,0) AND LOWER(ListItemText) <> '(none)'),'')
                                IF (@MajorPapillaBile=1 AND @MajorPapillaPancreatic=1) AND (@Reasons1 <>'' AND @Reasons2 <> '') SET @CAN = ' also ' + @CAN
                                SET @B = @AndBut + @CAN + ' to the pancreatic duct was '
                                SET @Comma = ', '
                                END
                    IF @MajorPapillaPancreatic=1
                            BEGIN
                            SET @C= @C + @Comma + @B + 'successful '
                            SET @B = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to pancreatic successful using' AND  ListItemNo = ISNULL(@MajorPapillaPancreaticReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                            IF ISNULL(@MajorPapillaBileReason,0) >0  IF LEFT(@B, 1) IN ('a','e','i','o','u') SET @C= @C + ' using an ' + @B + ' ' ELSE SET @C= @C + ' using a ' + @B + ' '
                            END
                    ELSE IF @MajorPapillaPancreatic=3 SET @C= @C + @Comma + @B + 'not attempted '
                    ELSE IF @MajorPapillaPancreatic=3
                            BEGIN
                            SET @Reasons1 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to pancreatic unsuccessful due to' AND  ListItemNo = ISNULL(@MajorPapillaPancreaticReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                            IF @Reasons1 <>'' SET @C= @C + @Comma + @B + 'unsuccessful '
                            ELSE SET @C= @C + @Comma + @B + 'unsuccessful due to ' + @Reasons1
                            END
                    ELSE IF @MajorPapillaPancreatic=2
                            BEGIN
                            SET @Reasons1 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via major to pancreatic partially successful reason' AND  ListItemNo = ISNULL(@MajorPapillaPancreaticReason,0) AND LOWER(ListItemText) <> '(none)'),'')
                            IF @Reasons1 ='' SET @C = @C + @Comma + @B + 'partially successful'
                            ELSE 
                                BEGIN
                                SET @C = @C + @Comma + @B + 'partially successful due to ' + @Reasons1
                                SET @CAN = ' cannulation '
                                END
                            END
                            IF @C<>'' SET @A = @A + LTRIM(RTRIM(@C)) + '. '
                    END    
        END

		--PRINT 'Value of @A before @MinorPapilla: ' + @A;	--## Debugger!

        IF @MinorPapilla=1
        BEGIN
			SET @A = @A + 'Cannulation via the minor papilla was successful '
			SET @B =  ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via minor successful using to' AND  ListItemNo = ISNULL(@MinorPapillaReason,0) AND LOWER(ListItemText) <> '(none)'),'')
			IF @B <> '' IF LEFT(@B, 1) IN ('a','e','i','o','u') SET @A= @A + ' using an ' + @B  ELSE SET @A= @A + ' using a ' + @B 
			SET @A = LTRIM(RTRIM(@A)) + '.'
        END
        ELSE IF @MinorPapilla=4
        BEGIN
            SET @B ='Cannulation via the minor papilla was unsuccessful ' 
            SET @Reasons1 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via minor unsuccessful due to' AND  ListItemNo = ISNULL(@MinorPapillaReason,0) AND LOWER(ListItemText) <> '(none)'),'')
            IF @Reasons1 = '' SET @A = @A + @B
            ELSE SET @A = @A + @B + 'due to ' + @Reasons1
            SET @A = LTRIM(RTRIM(@A)) + '.'
        END
        ELSE IF @MinorPapilla=2
        BEGIN
            SET @B = 'Cannulation via the minor papilla was partially successful '
            SET @Reasons1 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP via minor partially successful reason' AND  ListItemNo = ISNULL(@MinorPapillaReason,0) AND LOWER(ListItemText) <> '(none)'),'')
            IF @Reasons1 = '' SET @A = @A + @B
            ELSE SET @A = @A + @B + 'due to ' + @Reasons1
            SET @A = LTRIM(RTRIM(@A)) + '.'
        END

		IF @A <> '' SET @A = dbo.fnFirstLetterUpper(@A)
		IF @ExceptBileDuct = 1 INSERT INTO @tmp1 (Val) VALUES('common bile duct')
		IF @ExceptGallBladder= 1 INSERT INTO @tmp1 (Val) VALUES('gall bladder')
		IF @ExceptCommonHepaticDuct = 1 INSERT INTO @tmp1 (Val) VALUES('common hepatic duct')
		IF @ExceptRightHepaticDuct = 1 INSERT INTO @tmp1 (Val) VALUES('right hepatic duct')
		IF @ExceptLeftHepaticDuct = 1 INSERT INTO @tmp1 (Val) VALUES('left hepatic duct')

		IF @ExceptAccesoryPancreatic = 1 INSERT INTO @tmp2 (Val) VALUES('accessory pancreatic duct')
		IF @ExceptMainPancreatic = 1 INSERT INTO @tmp2 (Val) VALUES('main pancreatic duct')
		IF @ExceptUncinate = 1 INSERT INTO @tmp2 (Val) VALUES('uncinate process')
		IF @ExceptHead  = 1 INSERT INTO @tmp2 (Val) VALUES('head')
		IF @ExceptNeck  = 1 INSERT INTO @tmp2 (Val) VALUES('neck')
		IF @ExceptBody  = 1 INSERT INTO @tmp2 (Val) VALUES('body')
		IF @ExceptTail  = 1 INSERT INTO @tmp2 (Val) VALUES('tail')

		IF (SELECT COUNT(Val) FROM @tmp1)=0 SET @NoHepExcept = 1
		IF (SELECT COUNT(Val) FROM @tmp2)=0 SET @NoPanExcept = 1

		SET @Reasons1 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP extent of visualisation limited by other' AND  ListItemNo = ISNULL(@HepatobiliaryLimitedByOtherText,0) AND LOWER(ListItemText) <> '(none)'),'')
		SET @Reasons2 = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP extent of visualisation limited by other' AND  ListItemNo = ISNULL(@PancreaticLimitedByOtherText,0) AND LOWER(ListItemText) <> '(none)'),'')

		SET @AndBut = 'and '

		DECLARE @XMLlist1 XML, @XMLlist2 XML
		SET @XMLlist1 = (SELECT Val FROM @tmp1 FOR XML  RAW, ELEMENTS, TYPE)
		SET @AR1 =     dbo.fnBuildString(@XMLlist1)
       
		SET @XMLlist2 = (SELECT Val FROM @tmp2 FOR XML  RAW, ELEMENTS, TYPE)
		SET @AR2 = dbo.fnBuildString(@XMLlist2) 

		IF @HepatobiliaryNotVisualised = 1 AND @PancreaticNotVisualised= 1
        BEGIN
            SEt @B = 'Neither the biliary nor pancreatic systems were visualised '
            IF @HepatobiliaryLimitedBy = 1 AND @PancreaticLimitedBy= 1 SET @A = @A + @B + 'due to insufficient contrast. '
            ELSE IF (@HepatobiliaryLimitedBy = 2 AND @PancreaticLimitedBy= 2) AND  (@Reasons1 = @Reasons2)
                    BEGIN
                    IF @Reasons1='' SET @A = @A + @B + '. '
                    ELSE SET @A = @A + @B + 'due to ' + @Reasons1 + '. '
                    END
            ELSE IF @HepatobiliaryLimitedBy<> @PancreaticLimitedBy
            BEGIN
            SET @A = @A + 'The biliary system was not visualised '
            IF @HepatobiliaryLimitedBy= 1 SET @A = @A + 'due to insufficient contrast '
            IF @HepatobiliaryLimitedBy= 2 AND @Reasons1<>'' SET @A = @A + 'due to ' + @Reasons1 + ' '
            SET @A = @A + 'nor was the pancreatic system visualised '
            IF @PancreaticLimitedBy = 1 SET @A = @A + 'due to insufficient contrast '
            IF @PancreaticLimitedBy = 2 AND @Reasons2<>'' SET @A = @A + ' due to ' + @Reasons2 + ' '
            SET @A = @A   + '. '
            END
            ELSE IF ISNULL(@HepatobiliaryLimitedBy,0)=0 AND ISNULL(@PancreaticLimitedBy,0)=0 SET @A = @A + LTRIM(RTRIM(@B)) + '. '
		END
		ELSE IF ISNULL(@HepatobiliaryNotVisualised,0) <>1 AND @PancreaticNotVisualised= 1
        BEGIN
            SET @B=''
            IF @HepatobiliaryWholeBiliary=1
                    BEGIN
                    SET @B = '<br/>Visualisation: The whole biliary system '
                    IF @NoHepExcept=1 SET @A = @A + @B
                    ELSE 
                        BEGIN            
							SET @A = @A + @B + 'except the ' + @AR1
							IF @HepatobiliaryLimitedBy =1 SET @A = @A + ', limited by insufficient contrast '
							IF @HepatobiliaryLimitedBy =2 SET @A = @A + ', limited by ' + @Reasons1 + ' '
                        END
                    END
                    IF @B <> ''
                        BEGIN
                        SET @B='but not the pancreatic system '
                        SET @Comma = ', '
                        END
                    ELSE
                        BEGIN
                        SET @B= '<br/>Visualisation: The pancreatic system was not visualised '
                        SET @Comma = ''
                        END
            IF @PancreaticLimitedBy= 1 SET @B = @B + 'due to insufficient contrast '
            IF @PancreaticLimitedBy= 2 AND @Reasons2<>'' SET @B = @B + ' due to ' + @Reasons2 + ' '
            SET @A = LTRIM(RTRIM(@A)) + @Comma + LTRIM(RTRIM(@B)) + '. '
        END
              
		ELSE IF ISNULL(@HepatobiliaryNotVisualised,0) =1 AND ISNULL(@PancreaticNotVisualised,0)<>1
        BEGIN
            DECLARE @Vis varchar(50)=''
            SET @B = 'the biliary system was not visualised '
            SET @AndBut ='but '
            IF @HepatobiliaryLimitedBy = 1
                    BEGIN
                    SET @B = @B + 'due to insufficient contrast '
                    SET @Vis = '<br/>Visualisation: '
                    END
            IF @HepatobiliaryLimitedBy = 2 AND @Reasons1 <> ''
                    BEGIN
                    SET @B = @B + 'due to ' + @Reasons1 + ' '
                    SET @Vis = '<br/>Visualisation: '
                    END
            SET @C = @AndBut + 'the whole pancreatic system '      
            SET @C1 = @AndBut + 'the pancreas divisum '
            IF @PancreaticWhole=1 OR @PancreaticDivisum=1
                    BEGIN
                    IF @PancreaticDivisum= 1 SET @C = @C1
                    IF @NoPanExcept= 1 SET @C = @C + 'was '
                    ELSE
                        BEGIN
                        SET @Vis = '<br/>Visualisation: '

                        SET @C = @C  + 'except the ' + @AR2 + ' was'
                        IF @PancreaticLimitedBy = 1 SET @C = @C + ', limited by insufficient contrast '
                        IF @PancreaticLimitedBy =2 AND @Reasons2<>'' SET @C = @C + ', limited by '+ @Reasons2 + ' '
                        END
                    END
            IF @Vis ='' SET @B = dbo.fnFirstLetterUpper(@B)
            SET @A = @A + @Vis + @B + @C + '.'
        END
		ELSE IF ISNULL(@HepatobiliaryNotVisualised,0) <>1 AND ISNULL(@PancreaticNotVisualised,0)<>1
        BEGIN
            SET @B= 'the whole biliary system '
            SET @C = 'the whole pancreatic system '
            SET @C1 = 'the pancreas divisum '
            IF ISNULL(@HepatobiliaryWholeBiliary,0)=1 AND (ISNULL(@PancreaticWhole,0)=1 OR ISNULL(@PancreaticDivisum,0)=1)
            BEGIN
                IF @PancreaticDivisum=1 SET @C = @C1
                IF ISNULL(@NoHepExcept,0) = 1 AND ISNULL(@NoPanExcept,0)=1
                BEGIN
                    IF @PancreaticWhole = 1 SET @A = @A + 'The complete biliary and pancreatic systems were visualised '
                    ELSE SET @A = @A + 'The complete biliary and pancreas divisum were visualised '
                END
                ELSE IF ISNULL(@NoHepExcept,0) = 1 AND ISNULL(@NoPanExcept,0)<>1
                BEGIN
                    SET @A = @A + '<br/>Visualisation: ' + @B + 'and ' + @C + 'except the ' + @AR2 + ' was visualised'
                    IF @PancreaticLimitedBy=1 SET @A = @A + ', limited by insufficient contrast '
                    IF @PancreaticLimitedBy=2 AND @Reasons2 <>'' SET @A = @A + ', limited by ' + @Reasons2+ ' '
                END
                ELSE IF ISNULL(@NoHepExcept,0) <>1 AND ISNULL(@NoPanExcept,0)=1
                BEGIN
					SET @A= @A + '<br/>Visualisation: ' + @B +'except the '+ @AR1 + ' '
					IF @HepatobiliaryLimitedBy=1 SET @A = LTRIM(RTRIM(@A)) + ', limited by insufficient contrast'
					IF @HepatobiliaryLimitedBy=2 AND @Reasons1 <>'' SET @A = LTRIM(RTRIM(@A)) + ', limited by ' + @Reasons1
					SET @A = LTRIM(RTRIM(@A)) + ', and '+ @C
				END
                ELSE IF ISNULL(@NoHepExcept,0) <>1 AND ISNULL(@NoPanExcept,0)<>1
                BEGIN
                    SET @A = @A + '<br/>Visualisation: ' + @B + 'except the '+ @AR1 + ' '
                    IF @HepatobiliaryLimitedBy=1 SET @A = LTRIM(RTRIM(@A)) + ', limited by insufficient contrast'
                    IF @HepatobiliaryLimitedBy=2 AND @Reasons1 <>'' SET @A = LTRIM(RTRIM(@A)) + ', limited by ' + @Reasons1+ ' '
                    SET @A = LTRIM(RTRIM(@A)) + ', and '+ @C + 'except the '+ @AR2
                    IF @PancreaticLimitedBy=1 SET @A = @A + ', limited by insufficient contrast '
                    IF @PancreaticLimitedBy=2 AND @Reasons2 <>'' SET @A = @A + ', limited by ' + @Reasons2
                END
                SET @A = LTRIM(RTRIM(@A)) + '. '
			END
            ELSE IF ISNULL(@HepatobiliaryWholeBiliary,0)=1 AND ISNULL(@PancreaticWhole,0)<>1 AND ISNULL(@PancreaticDivisum,0)<>1
            BEGIN
				SET @A = @A + '<br/>Visualisation: ' + @B
				IF @NoHepExcept=1 SET @A = @A + ' '
				ELSE 
				BEGIN
					SET @A = @A + 'except the '+ @AR1 + ' '
					IF @HepatobiliaryLimitedBy=1 SET @A = @A + ', limited by insufficient contrast, '
					IF @HepatobiliaryLimitedBy=2 AND @Reasons1<>'' SET @A = @A + ', limited by ' + @Reasons1 + ', '                         
				END
				SET @A = @A + 'but not the pancreatic system. '
            END
            ELSE IF ISNULL(@HepatobiliaryWholeBiliary,0)<>1 AND (ISNULL(@PancreaticWhole,0)=1 OR ISNULL(@PancreaticDivisum,0)=1)
            BEGIN
				SET @A = @A + '<br/>Visualisation: The biliary system was not visualised '
				IF @NoPanExcept=1 SET @A = @A + 'but ' + @c + 'was '
				ELSE 
				BEGIN
					SET @A = @A +'but ' + @c +' except the ' + @AR2 + ' was'
					IF @PancreaticLimitedBy=1 SET @A = @A + ', limited by insufficient contrast '
					IF @PancreaticLimitedBy=2 AND @Reasons2 <>'' SET @A = @A + ', limited by ' + @Reasons2
				END
				SET @A = LTRIM(RTRIM(@A)) + '. '
			END
            --ELSE IF ISNULL(@HepatobiliaryWholeBiliary,0)<>1 AND ISNULL(@PancreaticWhole,0)<>1 AND ISNULL(@PancreaticDivisum,0)<>1
                    --BEGIN
                    --SET @A = @A + 'Neither the biliary nor the pancreatic systems were visualised.'
            --END
        END
                     
		IF @HepatobiliaryAcinarFilling    = 1 AND @PancreaticAcinar=1  SET @A = @A + 'There was evidence of acinar filling of the liver and the pancreas. '
		ELSE IF @HepatobiliaryAcinarFilling      = 1 AND @PancreaticAcinar<>1 SET @A = @A + 'There was evidence of acinar filling of the liver. '
		ELSE IF @HepatobiliaryAcinarFilling      <> 1 AND @PancreaticAcinar=1 SET @A = @A  +'There was evidence of acinar filling of the pancreas. '
       
		DELETE FROM @tmp1
		DELETE FROM @tmp2
		SET @AR1= ''
		SET @AR2 = ''
		DECLARE @Vol varchar(500)='', @CM varchar(500)=''

		IF ISNULL(@HepatobiliaryFirstML,0) > 0 SET @Vol = ISNULL(@HepatobiliaryFirstML,0) + ' ml'
		IF ISNULL(@HepatobiliaryFirst,0) > 0 SET @CM = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP contrast media used' AND  ListItemNo = ISNULL(@HepatobiliaryFirst,0) AND LOWER(ListItemText) <> '(none)'),'')
		IF @CM <>'' OR ISNULL(@HepatobiliaryFirstML,'')<>'' INSERT INTO @tmp1 (VAl) VALUES (@Vol+ (CASE WHEN (@Vol)<>'' THEN ' ' + @CM ELSE @CM END ))

		SET @Vol='' ; SET @CM= ''

		IF ISNULL(@HepatobiliarySecondML,0) > 0 SET @Vol = ISNULL(@HepatobiliarySecondML,0) + ' ml'
		IF ISNULL(@HepatobiliarySecond,0) > 0 SET @CM = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP contrast media used' AND  ListItemNo = ISNULL(@HepatobiliarySecond,0) AND LOWER(ListItemText) <> '(none)'),'')
		IF @CM <>'' OR ISNULL(@HepatobiliarySecondML,'')<>'' INSERT INTO @tmp1 (VAl) VALUES (@Vol+ (CASE WHEN (@Vol)<>'' THEN ' ' + @CM ELSE @CM END ))

		SET @Vol='' ; SET @CM= ''


		IF ISNULL(@PancreaticFirstML,0) > 0 SET @Vol = ISNULL(@PancreaticFirstML,0) + ' ml'
		IF ISNULL(@PancreaticFirst,0) > 0 SET @CM = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP contrast media used' AND  ListItemNo = ISNULL(@PancreaticFirst,0) AND LOWER(ListItemText) <> '(none)'),'')
		IF @CM <>'' OR ISNULL(@PancreaticFirstML,'')<>'' INSERT INTO @tmp2 (VAl) VALUES (@Vol+ (CASE WHEN (@Vol)<>'' THEN ' ' + @CM ELSE @CM END ))

		SET @Vol='' ; SET @CM= ''

		IF ISNULL(@PancreaticSecondML,0) > 0 SET @Vol = ISNULL(@PancreaticSecondML,0) + ' ml'
		IF ISNULL(@PancreaticSecond,0) > 0 SET @CM = ISNULL((SELECT ListItemText FROM ERS_Lists where ListDescription='ERCP contrast media used' AND  ListItemNo = ISNULL(@PancreaticSecond,0) AND LOWER(ListItemText) <> '(none)'),'')
		IF @CM <>'' OR ISNULL(@PancreaticSecondML,'')<>'' INSERT INTO @tmp2 (VAl) VALUES (@Vol+ (CASE WHEN (@Vol)<>'' THEN ' ' + @CM ELSE @CM END ))

		SET @B=''
		SET @C = ''

		
		IF @HepatobiliaryBalloon= 1 SET @B = '(occlusion cholangiography) '
		IF     @PancreaticBalloon = 1 SET @C = '(occlusion pancreatography) '

		SET @A = LTRIM(RTRIM(@A))

		DECLARE @XMLlist01 XML, @ic1 int=0
		SET @ic1 = ISNULL((SELECT Count(Val) FROM @tmp1 WHERE LTRIM(RTRIM(Val))<> ''),0)
		SET @XMLlist01 = (SELECT Val FROM @tmp1 FOR XML  RAW, ELEMENTS, TYPE)
		SET @AR1 = dbo.fnBuildString(@XMLlist01)
       

		DECLARE @XMLlist02 XML, @ic2 int=0
		SET @ic2 = ISNULL((SELECT Count(Val) FROM @tmp2 WHERE LTRIM(RTRIM(Val))<> ''),0)
		SET @XMLlist02 = (SELECT Val FROM @tmp2 FOR XML  RAW, ELEMENTS, TYPE)
		SET @AR2 = dbo.fnBuildString(@XMLlist02)
       
		IF @ic1> 0 AND @ic2>0
        BEGIN
			SET @A = @A  + ' Contrast media used: hepatobiliary; ' + @AR1 + ' ' + @B
			SET @A = LTRIM(RTRIM(@A)) + ': pancreatic; ' + @AR2 + ' ' + @C
			SET @A = LTRIM(RTRIM(@A)) + '. '
        END    
		ELSE IF @ic1> 0 AND @ic2=0
        BEGIN
            SET @A = @A  + ' Contrast media used: hepatobiliary; ' + @AR1 + ' ' + @B
            SET @A = LTRIM(RTRIM(@A)) + '. '
        END
		ELSE IF @ic1= 0 AND @ic2>0
        BEGIN
            SET @A = @A + ' Contrast media used: pancreatic; ' + @AR2 + ' ' + @C
            SET @A = LTRIM(RTRIM(@A)) + '. '
        END


		IF @DuodenumNormal = 1 SET @A = @A + ' Duodenum normal. '
		ELSE IF @DuodenumNotEntered = 1 SET @A = @A + ' Duodenum not entered. '
		ELSE IF @Duodenum2ndPartNotEntered = 1 SET @A = @A  +' Duodenum 2nd part not entered. '
		SET @A = LTRIM(RTRIM(@A))

	 UPDATE  [ERS_Visualisation] SET Summary = @A WHERE ProcedureID=@ProcedureID;
	 EXEC [procedure_summary_update] @ProcedureID;
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
UPDATE dbo.ERS_DiagnosesMatrix
SET DisplayName = 'Minizzi syndrome', 
	NED_Name = 'Minizzi syndrome'
WHERE Code = 'D160P2'

DELETE FROM ers_diagnosesmatrix WHERE code = 'D320P2'

UPDATE ERS_DiagnosesMatrix SET DisplayNAme = 'Malignant' WHERE Code = 'D125P2'
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D386P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Sclerosing cholangitis', 'Primary sclerosing cholangitis', 2, 'Extrahepatic', 0, 386, 'D386P2', 1),
	('Sclerosing cholangitis', 'Primary sclerosing cholangitis', 7, 'Extrahepatic', 0, 386, 'D386P2', 1)
GO
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D387P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Minimal change', NULL, 2, 'Pancreas', 0, 387, 'D387P2', 1),
	('Minimal change', NULL, 7, 'Pancreas', 0, 387, 'D387P2', 1)
GO

--------------------------------------------------------------------------------------------------------------------------------------------
UPDATE ERS_DiagnosesMatrix SET DisplayName = 'Duodenitis , erosive', NED_Name='Duodenitis , erosive', Section ='Duodenum' WHERE Code = 'D90P2'
--------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D388P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Small lakes', 2, 'Pancreas', 0, 388, 'D388P2', 1),
	('Small lakes', 7, 'Pancreas', 0, 384, 'D388P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D389P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Stricture(s)', 2, 'Pancreas', 0, 389, 'D389P2', 1),
	('Stricture(s)', 7, 'Pancreas', 0, 389, 'D389P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D390P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Probably', 2, 'Tumour', 0, 383, 'D390P2', 1),
	('Probably', 7, 'Tumour', 0, 383, 'D390P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D391P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Benign', 2, 'Tumour', 0, 391, 'D391P2', 1),
	('Benign', 7, 'Tumour', 0, 391, 'D391P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D392P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Communicating', 2, 'Biliary', 0, 392, 'D392P2', 1),
		   ('Communicating', 7, 'Biliary', 0, 392, 'D392P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D393P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Post cholecystectomy', 2, 'Intrahepatic', 0, 393, 'D393P2', 1),
		   ('Post cholecystectomy', 7, 'Intrahepatic', 0, 393, 'D393P2', 1)
GO
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------

