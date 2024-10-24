------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	
-- TFS#	
-- Description of change
-- 
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

---------------------------------------------------------
-- Update script for release 2.23.10.03
---------------------------------------------------------
DECLARE @Version AS VARCHAR(40) = '2.23.10.03'

IF NOT EXISTS(SELECT * FROM DBversion WHERE VersionNum = @Version)
	BEGIN 
		-- First time the script has been run
		INSERT INTO DBVersion VALUES (@Version, GETDATE())
	END 
ELSE
	BEGIN 
		-- script run more than once
		DECLARE @DBVersionCount AS INT 

		SELECT @DBVersionCount = COUNT(*) 
		FROM DBVersion WHERE VersionNum = @Version

		INSERT INTO DBVersion VALUES (@Version + ' (' + CONVERT(VARCHAR, @DBVersionCount) + ')', GETDATE())
	END 
GO
---------------------------------------------------------
GO 
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	3822
-- Description of change
-- DICA Score retrieval to handle conditional
------------------------------------------------------------------------------------------------------------------------
GO

PRINT N'Altering Function [dbo].[tvfNED_Diagnoses]...';


GO

ALTER FUNCTION [dbo].[tvfNED_Diagnoses]
(	
	 @ProcedureType AS INT
	, @ProcedureId AS INT
)
RETURNS @Diagnoses TABLE (
	Ned_Name VARCHAR(200),
	Tattooed VARCHAR(3),
	[site] VARCHAR(100),
	Comment  VARCHAR(1000),
	barrettsLengthCircumferential INT,
	barrettsLengthMaximum INT,
	barretsInspectionTime INT,
	gastricInspectiontime INT,
	oesophagitisLaClassification VARCHAR(2),
	DICAScore INT,
	UCEIS INT,
	mayoScore INT,
	rutgeertsScore VARCHAR(2),
	CDEIS INT
)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND MatrixCode NOT IN ('Summary','D138P2','D33P2', 'D51P2','D67P2'))
	BEGIN
		INSERT INTO @Diagnoses
		--## There are few Exception 'Diagnoses' Code.. Which doesn't exist int he DiagnosesMatrix.Code field. So- read them separately
			SELECT TOP 1 --## 'Top 1' Because- it can be like: "'OverallNormal', 'DuodenumNormal', 'OesophagusNormal', 'StomachNormal'"- and we need only once to show 'Normal!'
				  'Normal' AS Ned_Name
				, NULL	AS Tattooed
				, 'None' AS site		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL AS oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
	END
	ELSE IF EXISTS (SELECT 1 FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND MatrixCode = 'OverallNormal')
	BEGIN
		INSERT INTO @Diagnoses
		--## There are few Exception 'Diagnoses' Code.. Which doesn't exist int he DiagnosesMatrix.Code field. So- read them separately
			SELECT TOP 1 --## 'Top 1' Because- it can be like: "'OverallNormal', 'DuodenumNormal', 'OesophagusNormal', 'StomachNormal'"- and we need only once to show 'Normal!'
				  'Normal' AS Ned_Name
				, NULL	AS Tattooed
				, 'None' AS site		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL AS oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
	END
	ELSE IF EXISTS (SELECT 1 FROM ERS_Diagnoses WHERE ProcedureId = @ProcedureId AND MatrixCode = 'ColonNormal')
	BEGIN
		INSERT INTO @Diagnoses
		--## There are few Exception 'Diagnoses' Code.. Which doesn't exist int he DiagnosesMatrix.Code field. So- read them separately
			SELECT TOP 1 --## 'Top 1' Because- it can be like: "'OverallNormal', 'DuodenumNormal', 'OesophagusNormal', 'StomachNormal'"- and we need only once to show 'Normal!'
				  'Normal' AS Ned_Name
				, NULL	AS Tattooed
				, 'None' AS site		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL AS oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
	END
	ELSE
	BEGIN
		INSERT INTO @Diagnoses
		   SELECT 'Colorectal cancer' AS Ned_Name
				, CASE WHEN ISNULL(T.TattooedId, 0) = 1 THEN 'No' WHEN ISNULL(T.TattooedId, 0) = 2 THEN 'Yes' END AS tattooed	--## 'Colonic polyps or Rectal polyps' => Colon/FLexi ONLY! 
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END AS [Site]
				, NULL AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL AS oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
			 FROM [dbo].[ERS_Diagnoses] D
		--LEFT JOIN [dbo].[ERS_DiagnosesMatrix]	AS M ON D.MatrixCode = M.Code
		LEFT JOIN [dbo].[ERS_Procedures]		AS P ON D.ProcedureID = P.ProcedureId
		LEFT JOIN dbo.ERS_Sites		AS S ON D.SiteId = S.SiteId
		LEFT JOIN dbo.ERS_Regions	AS R ON S.RegionId = R.RegionId
		LEFT JOIN dbo.ERS_ColonAbnoTumour T ON T.SiteId = S.SiteID
			WHERE D.ProcedureId= @ProcedureId
			  AND P.ProcedureType IN(3,4,9)	--## Only for OGD/Colon/FLEXI! NOT for ERCP! - NO, Colon and Flexi only. How can you get colon cancer in an OGD procedure? - Don't forget ENT procedures, but really, we don't need this line as it should be taken care of by the matrix code on the next line
			  AND D.MatrixCode IN ('S69P3', 'D69P3')  --## 'Colorectal cancer'

		UNION ALL
		SELECT 'Barrett''s oesophagus' AS Ned_Name
				, NULL AS tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END AS [Site]
				, NULL AS Comment
				, B.DistanceM2 AS barrettsLengthCircumferential
				, B.DistanceM1 AS barrettsLengthMaximum
				, B.InspectionTimeMins AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
			 FROM [dbo].[ERS_Diagnoses] D
		LEFT JOIN [dbo].[ERS_Procedures]		AS P ON D.ProcedureID = P.ProcedureId
		LEFT JOIN dbo.ERS_Sites		AS S ON D.SiteId = S.SiteId
		LEFT JOIN ERS_Regions		AS R ON R.RegionId = S.RegionId
		left join dbo.ERS_UpperGIAbnoBarrett AS B on B.SiteId = S.SiteId 
			WHERE D.ProcedureId= @ProcedureId 
			  AND P.ProcedureType IN(1, 2, 6, 8)	--## Only for upper procedures
			  AND D.MatrixCode IN ('D23P1')  --## Barrett's oesophagus

		UNION ALL
		SELECT 'Gastric atrophy' AS Ned_Name
				, NULL AS tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]	
				, NULL AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, datediff(minute, G.GastricInspectionStartDateTime, G.GastricInspectionEndDateTime) AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
			 FROM [dbo].[ERS_Diagnoses] D
		--LEFT JOIN [dbo].[ERS_DiagnosesMatrix]	AS M ON D.MatrixCode = M.Code
		LEFT JOIN [dbo].[ERS_Procedures]		AS P ON D.ProcedureID = P.ProcedureId
		LEFT JOIN dbo.ERS_Sites		AS S ON D.SiteId = S.SiteId
		LEFT JOIN ERS_Regions		AS R ON R.RegionId = S.RegionId
		left join dbo.ERS_UpperGIAbnoGastritis AS G on G.SiteId = S.SiteId 
			WHERE D.ProcedureId= @ProcedureId
			  AND P.ProcedureType IN(1, 2, 6, 8)	--## Only for upper procedures
			  AND D.MatrixCode IN ('N2006')

		UNION ALL
		SELECT top 1 M.NED_Name
				, NULL AS tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]
				, NULL AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, CASE O.LAClassification 
					WHEN 1 THEN 'A'
					WHEN 2 THEN 'B'
					WHEN 3 THEN 'C'
					WHEN 4 THEN 'D'
				  END as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
			 FROM [dbo].[ERS_Diagnoses] D
		LEFT JOIN [dbo].[ERS_DiagnosesMatrix]	AS M ON D.MatrixCode = M.Code
		LEFT JOIN [dbo].[ERS_Procedures]		AS P ON D.ProcedureID = P.ProcedureId
		LEFT JOIN dbo.ERS_Sites		AS S ON D.SiteId = S.SiteId
		LEFT JOIN ERS_Regions		AS R ON R.RegionId = S.RegionId
		left join dbo.ERS_UpperGIAbnoOesophagitis AS O on O.SiteId = S.SiteId 
			WHERE D.ProcedureId= @ProcedureId
			  AND P.ProcedureType IN(1, 2, 6, 8)	--## Only for upper procedures
			  AND D.MatrixCode IN ('D36P1') --Oesophagitis - reflux

		UNION ALL	
		select DISTINCT --## DISTINCT REQUIRED- When in Stomach- 3 sites - all has Polyps and Gastric- then they will repeat.
				  'Other'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]		
				, eugm.MiscOther AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
		FROM ERS_diagnoses AS D
		INNER JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code
		INNER JOIN ERS_Sites S ON D.SiteId = S.SiteId
			INNER JOIN ERS_Regions R ON s.RegionId = R.RegionId
			INNER JOIN dbo.ERS_UpperGIAbnoMiscellaneous eugm ON S.SiteId = eugm.SiteId
		where D.ProcedureId= @ProcedureId 
			AND M.NED_Include = 1
			AND M.ProcedureTypeID = @ProcedureType
			AND M.DisplayName = 'Other'
		
		UNION ALL	-- dbo.fnNED_GetBiopsySiteName(P.ProcedureId, R.Region)
		select DISTINCT --## DISTINCT REQUIRED- When in Stomach- 3 sites - all has Polyps and Gastric- then they will repeat.
				  'Other'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]		
				, eugm.OtherDesc AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
		FROM ERS_diagnoses AS D
		INNER JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code
		INNER JOIN ERS_Sites S ON D.SiteId = S.SiteId
			INNER JOIN ERS_Regions R ON s.RegionId = R.RegionId
			INNER JOIN dbo.ERS_CommonAbnoDiverticulum eugm ON S.SiteId = eugm.SiteId
		where D.ProcedureId= @ProcedureId 
			AND M.NED_Include = 1
			AND M.ProcedureTypeID = @ProcedureType
			AND M.DisplayName = 'Other'
		UNION ALL
		select DISTINCT --## DISTINCT REQUIRED- When in Stomach- 3 sites - all has Polyps and Gastric- then they will repeat.
				  'Other'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]		
				, eugm.Other AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
		FROM ERS_diagnoses AS D
		INNER JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code
		INNER JOIN ERS_Sites S ON D.SiteId = S.SiteId
			INNER JOIN ERS_Regions R ON s.RegionId = R.RegionId
			INNER JOIN dbo.ERS_ERCPAbnoDiverticulum eugm ON S.SiteId = eugm.SiteId
		where D.ProcedureId= @ProcedureId 
			AND M.NED_Include = 1
			AND M.ProcedureTypeID = @ProcedureType
			AND M.DisplayName = 'Other'
		UNION ALL
		select DISTINCT --## DISTINCT REQUIRED- When in Stomach- 3 sites - all has Polyps and Gastric- then they will repeat.
				  'Other'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE dbo.fnNED_GetBiopsySiteName(S.ProcedureId, R.Region) END As [Site]		
				, eugm.Other AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
		FROM ERS_diagnoses AS D
		INNER JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code
		INNER JOIN ERS_Sites S ON D.SiteId = S.SiteId
			INNER JOIN ERS_Regions R ON s.RegionId = R.RegionId
			INNER JOIN dbo.ERS_ColonAbnoMiscellaneous eugm ON S.SiteId = eugm.SiteId
		where D.ProcedureId= @ProcedureId 
			AND M.NED_Include = 1
			AND M.ProcedureTypeID = @ProcedureType
			AND M.DisplayName = 'Other'
		UNION ALL				
		select DISTINCT --## DISTINCT REQUIRED- When in Stomach- 3 sites - all has Polyps and Gastric- then they will repeat.
				  M.Ned_Name
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
		FROM ERS_diagnoses AS D
		INNER JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code
		INNER JOIN ERS_Sites S ON D.SiteId = S.SiteId
			INNER JOIN ERS_Regions R ON s.RegionId = R.RegionId
		where D.ProcedureId= @ProcedureId 
			AND M.Ned_Name IS NOT NULL --## I mean select the 'NED Mapped' fields ONLY!
			AND M.NED_Include = 1
			AND M.ProcedureTypeID = @ProcedureType
			AND D.MatrixCode NOT IN ('D70P3', 'S69P3', 'D69P3', 'D23P1', 'N2006', 'D36P1', 'D86P3', 'D96P3', 'S96P3', 'D1P3', 'N2015','S1P3','D1P3','P1P3','D1P9') -- don't include Colorectal cancer, barretts, Gastric atrophy, Oesophagitis, Diverticulosis - reflux or proctitus, they are already done 
			AND M.DisplayName <> 'Other'

		UNION ALL					--## Combine 'OTHER' type of Diagnoses! Which Doesn't have a NED Name mapping!
			select top 1
			  'Other' AS DisplayName
			, NULL	AS Tattooed
			, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]				
		
			, 
			(select 
				  (/*Section + ' ' +*/ M.DisplayName) + ', ' 
			FROM ERS_diagnoses AS D 
			LEFT JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code
			where D.ProcedureId= @ProcedureId
				AND M.Ned_Name IS NULL --## 'NED Mapped' is Missing
				--AND D.MatrixCode NOT IN ('D198P2', 'D265P2', 'D32P2', 'D33P2', 'D51P2', 'D67P2','D138P2') --## Diagnoses thinks these Exceptions belongs to others.. Because these are not Mapped to NED seperately
				AND D.MatrixCode not in ('N257P1', 'D70P3', 'D21P3', 'S21P3', 'D100P1','N2016', 'SN2016', 'N100P2') -- Could be NED field for Chrones, need to work that out, see next select
				AND M.NED_Include = 1
				AND D.SiteId = S.SiteId
				AND M.ProcedureTypeID = @ProcedureType
				FOR XML PATH('')
			) AS Comment		--## All the fields which are not in the 'NED Restricted Lookup' list!
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
		FROM ERS_diagnoses AS D
		INNER JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code --## InnerJoin- to avoid keeping anything which Codes (Summary, OverallNormal) don't exist in the Matrix Table.. WIll exclude them...
		INNER JOIN ERS_Sites S ON D.SiteId = S.SiteId
			INNER JOIN ERS_Regions R ON s.RegionId = R.RegionId
			where D.ProcedureId= @ProcedureId
			AND M.Ned_Name IS NULL --## Means when 'NED Mapped' is Missing- those belong to 'Other' type 
			AND D.MatrixCode not in ('N257P1', 'D21P3', 'S21P3', 'D100P1','N2016', 'SN2016', 'N100P2')
			AND M.NED_Include = 1
			AND M.ProcedureTypeID = @ProcedureType
		UNION ALL
			Select top 1 'Crohn''s - terminal ileum'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE dbo.fnNED_GetBiopsySiteName(S.ProcedureId, R.Region) END As [Site]		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, CASE WHEN dbo.fnNED_ProcedureExtent(@ProcedureId, 0) = 'Neo-terminal ileum' THEN rs.NEDTerm ELSE NULL END AS rutgeertsScore
				, CDEISScore AS CDEIS
			FROM ERS_ColonAbnoMucosa C
			join ERS_Sites S on S.SiteId = C.SiteId
			INNER JOIN ERS_Regions R ON S.RegionId = R.RegionId
			LEFT JOIN ERS_RutgeertsScores rs ON rs.UniqueId = C.RutgeertsScore
			where C.InflammatoryIleitis	 = 1 AND c.InflammatoryDisorder = 2
			AND S.ProcedureId = @ProcedureId 
		UNION ALL
			Select top 1 'Crohn''s colitis'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE dbo.fnNED_GetBiopsySiteName(S.ProcedureId, R.Region) END As [Site]		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, CASE WHEN dbo.fnNED_ProcedureExtent(@ProcedureId, 0) = 'Neo-terminal ileum' THEN rs.NEDTerm ELSE NULL END AS rutgeertsScore
				, CDEISScore AS CDEIS
			FROM ERS_ColonAbnoMucosa C
			join ERS_Sites S on S.SiteId = C.SiteId
			INNER JOIN ERS_Regions R ON S.RegionId = R.RegionId
			LEFT JOIN ERS_RutgeertsScores rs ON rs.UniqueId = C.RutgeertsScore
			where C.InflammatoryColitis = 1 AND c.InflammatoryDisorder = 2
			AND S.ProcedureId = @ProcedureId 

		UNION ALL
			Select top 1 'Proctitis'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
			FROM ERS_ColonAbnoMucosa C
			join ERS_Sites S on S.SiteId = C.SiteId
			INNER JOIN ERS_Regions R ON S.RegionId = R.RegionId
			where C.InflammatoryProctitis = 1
			AND S.ProcedureId = @ProcedureId 
	
	
		UNION ALL
			Select top 1 'Colitis - unspecified'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
			FROM ERS_ColonAbnoMucosa C
			join ERS_Sites S on S.SiteId = C.SiteId
			INNER JOIN ERS_Regions R ON S.RegionId = R.RegionId
			where C.InflammatoryDisorder = 1
			AND S.ProcedureId = @ProcedureId 

		UNION ALL
			Select top 1 'Colitis - pseudomembranous'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
			FROM ERS_ColonAbnoMucosa C
			join ERS_Sites S on S.SiteId = C.SiteId
			INNER JOIN ERS_Regions R ON S.RegionId = R.RegionId
			where C.InflammatoryDisorder = 10
			AND S.ProcedureId = @ProcedureId 

		UNION ALL
			Select top 1 'Colitis - ischemic'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
			FROM ERS_ColonAbnoMucosa C
			join ERS_Sites S on S.SiteId = C.SiteId
			INNER JOIN ERS_Regions R ON S.RegionId = R.RegionId
			where C.InflammatoryDisorder = 8
			AND S.ProcedureId = @ProcedureId 

		UNION ALL
			Select top 1 'Diverticulosis'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, isnull(ePoints.Points, 0) + isnull(GPoints.Points, 0) + isnull(IPoints.points, 0) + isnull(CPoints.Points, 0) AS DICAScore -- THIS IS NEEDED HERE
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
			FROM ERS_ColonAbnoMucosa C
			INNER JOIN ERS_Sites S on S.SiteId = C.SiteId
			INNER JOIN ERS_Regions R ON S.RegionId = R.RegionId
			INNER JOIN ERS_ProcedureDICAScores D on S.SiteId = D.SiteId 
			INNER join ERS_DICAScores ePoints on D.ExtensionId = ePoints.UniqueId
			INNER join ERS_DICAScores GPoints on D.GradeId = gPoints.UniqueId
			left join ERS_DICAScores iPoints on D.InflammatorySignsId = iPoints.UniqueId
			left join ERS_DICAScores CPoints on D.ComplicationsId = cPoints.UniqueId
			where C.InflammatoryDisorder = 4
			AND S.ProcedureId = @ProcedureId 
		
		UNION ALL
			Select top 1 'Diverticulosis'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, isnull(ePoints.Points, 0) + isnull(GPoints.Points, 0) + isnull(IPoints.points, 0) + isnull(CPoints.Points, 0) AS DICAScore -- THIS IS NEEDED HERE
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
			FROM ERS_ColonAbnoDiverticulum C
				INNER join ERS_Sites S on S.SiteId = C.SiteId
				INNER JOIN ERS_Regions R ON S.RegionId = R.RegionId
				INNER JOIN ERS_ProcedureDICAScores D on S.SiteId = D.SiteId 
				INNER join ERS_DICAScores ePoints on D.ExtensionId = ePoints.UniqueId
				INNER join ERS_DICAScores GPoints on D.GradeId = gPoints.UniqueId
				LEFT join ERS_DICAScores iPoints on D.InflammatorySignsId = iPoints.UniqueId
				LEFT join ERS_DICAScores CPoints on D.ComplicationsId = cPoints.UniqueId
			WHERE S.ProcedureId = @ProcedureId 
		UNION ALL
			Select top 1 'Ulcerative colitis'
				, NULL	AS Tattooed
				, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE isnull(R.NED_Term, 'Colon') END As [Site]		
				, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, (Select sum(points) from ERS_UCEISScores where UniqueId in (VascularPatternUCEISScore, BleedingUCEISScore, ErosionsUCEISScore)) AS UCEIS
				, InflammatoryMayoScore AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
			FROM ERS_ColonAbnoMucosa C
			join ERS_Sites S on S.SiteId = C.SiteId
			Left JOIN ERS_Regions R ON s.RegionId = R.RegionId
			where C.InflammatoryDisorder = 12
			AND S.ProcedureId = @ProcedureId 

		

		UNION ALL--## Handles colotis diagnosis as the diagnoses matrix table is joined on ERS_Diagnoses 'value' column rather than the 'code' column
			SELECT 
			  ISNULL(NED_Name,'Colitis - unspecified') AS NED_Name
			, NULL	AS Tattooed
			, CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site]		
			, NULL	AS Comment
				, NULL AS barrettsLengthCircumferential
				, NULL AS barrettsLengthMaximum
				, NULL AS barretsInspectionTime
				, NULL AS gastricInspectiontime
				, NULL as oesophagitisLaClassification
				, NULL AS DICAScore
				, NULL AS UCEIS
				, NULL AS mayoScore
				, NULL AS rutgeertsScore
				, NULL AS CDEIS
			FROM ERS_Diagnoses d
				INNER JOIN dbo.ERS_DiagnosesMatrix edm	ON code=value
			INNER JOIN ERS_Sites S ON S.SiteId = d.SiteId
			INNER JOIN ERS_Regions R ON S.RegionId = R.RegionId
			WHERE d.MatrixCode='ColitisType'  AND d.procedureid=@ProcedureId	
			AND edm.ProcedureTypeID = @ProcedureType

		UNION ALL
		SELECT DISTINCT --## DISTINCT REQUIRED- When in Stomach- 3 sites - all has Polyps and Gastric- then they will repeat.
					  M.Ned_Name
					, NULL AS tattooed	--## 'Colonic polyps or Rectal polyps' => Colon/FLexi ONLY! 
					, 'Colon' As [Site]		
					, NULL	AS Comment
					, NULL AS barrettsLengthCircumferential
					, NULL AS barrettsLengthMaximum
					, NULL AS barretsInspectionTime
					, NULL AS gastricInspectiontime
					, NULL as oesophagitisLaClassification
					, NULL AS DICAScore
					, NULL AS UCEIS
					, NULL AS mayoScore
					, NULL AS rutgeertsScore
					, NULL AS CDEIS
			FROM ERS_diagnoses AS D
			INNER JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code
			INNER JOIN ERS_Sites S ON D.SiteId = S.SiteId
			where D.ProcedureId= @ProcedureId 
				AND M.Ned_Name IS NOT NULL --## I mean select the 'NED Mapped' fields ONLY!
				AND M.NED_Include = 1
				AND M.ProcedureTypeID = @ProcedureType
				AND SiteNo = -77 --site by distance diagnoses
				and M.Ned_Name <> 'Ulcerative Colitis'
	
	END
	If (Select 1 from @Diagnoses where Ned_Name = 'Gastric atrophy') > 0
		Delete from @Diagnoses where Ned_Name = 'Gastritis - non-erosive'

	RETURN ;
END

/* columns returned
   ----------------
    Ned_Name
    Tattooed
    Comment
	barrettsLengthCircumferential	--Required for diagnosis of Barretts
	barrettsLengthMaximum			--Required for diagnosis of Barretts
	barretsInspectionTime			--Required for diagnosis of Barretts
	gastricInspectiontime			--Required if diagnosis of gastric atrophy OR gastric intestinal metaplasia
	oesophagitisLaClassification	--Required if diagnosis of Oesophagitis - reflux
	DICAScore						--required if diagnosis of Diverticulosis
	UCEIS							--If diagnosis is ‘Ulcerative Colitis’ both UCEIS and Mayo scores must be provided
	mayoScore						--If diagnosis is ‘Ulcerative Colitis’ both UCEIS and Mayo scores must be provided
	site							--If diagnosis is ‘Crohns Colitis’ or ‘Crohn`s- terminal ileum’ and [ExtentLookup]= ‘Neo-terminal ileum’
	rutgeertsScore					--If diagnosis is ‘Crohns Colitis’ or ‘Crohn`s- terminal ileum’ and [ExtentLookup]= ‘Neo-terminal ileum’
	CDEIS							--If diagnosis is ‘Crohns Colitis’ or ‘Crohn`s- terminal ileum’
*/
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	3821
-- Description of change
-- Exclude DNA procedures from sending to NED
------------------------------------------------------------------------------------------------------------------------
GO


PRINT N'Altering Procedure [dbo].[usp_NEDI2_Get_Unsent_Procedures]...';


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
	where ( ProcedureCompleted = 1 
			and IsActive = 1 
			AND prc.DNA IS NULL 
			and cnfg.NEDEnabled = 1 
			and prc.operatingHospitalId = cnfg.operatingHospitalId 
			AND pt.NedExportRequired = 1 
			AND ISNULL(prc.NEDExported,0) = 0) 
		and prc.CreatedOn >= (select min(InstallDate) from DBVersion where VersionNum like '2%') 
		AND prc.CreatedOn > DATEADD(Month, -11, GETDATE())
END
GO


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	3826/3823
-- Description of change
-- Invalid NED definitions
------------------------------------------------------------------------------------------------------------------------
GO

UPDATE ERS_DiagnosesMatrix SET NED_Name = 'Duodenal tumour - malignant' WHERE DisplayName = 'Tumour, malignant' AND Section = 'Duodenum' AND Code = 'D93P1'
GO

UPDATE dbo.ERS_DiagnosesMatrix SET NED_Include = 1 WHERE DisplayName IN ('Angiodysplasia','Fundic gland polyp','Radiation proctitis')
GO

UPDATE dbo.ERS_DiagnosesMatrix SET NED_Name = 'Gallbladder stones' WHERE NED_Name = 'gallbladder stone(s)'
GO

IF EXISTS (SELECT 1 FROM dbo.ERS_TherapeuticTypes WHERE NedName = 'Balloon dilatation')
BEGIN
    UPDATE dbo.ERS_TherapeuticTypes SET NEDRequired = 0 WHERE NedName = 'Balloon dilatation'
END
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	3880
-- Description of change
-- reset planned extent to required field
------------------------------------------------------------------------------------------------------------------------
GO

UPDATE dbo.UI_Sections SET NEDRequired = 1 WHERE SectionName='Planned extent' AND NEDRequired = 0
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	3827
-- Description of change
-- Indication type other text retrieval
------------------------------------------------------------------------------------------------------------------------
GO

ALTER FUNCTION [dbo].[tvfNED_ProcedureIndication]
(
	@ProcedureId AS INT
)
-- =============================================
-- Description:	This will return the list of 'Indication' for each Procedure- required for NED Export!
-- =============================================
RETURNS TABLE 
AS
RETURN 
(
Select procedureindicationid,ISNULL(NULLIF(dbo.HTMLDecode(EI.NEDTerm),''), 'Other') NEDTerm --any entry that does not have a NED term in the lookup table is to be treated as other
		, CASE WHEN EI.NEDTerm = 'Other' then EPI.[AdditionalInformation] ELSE NULL END AS Comment --where the NED term is blank, the description should be included in the other field
		, CASE WHEN EI.NEDTerm = 'FIT Positive' then CONVERT(decimal(18,2), EPI.AdditionalInformation) ELSE NULL END AS fitPositiveValue
		, CASE WHEN EI.NEDTerm = 'Elevated calprotectin' then EPI.AdditionalInformation ELSE NULL END AS elevatedCalprotectinValue
  from ERS_ProcedureIndications EPI
  join ERS_Indications EI on ISNULL(NULLIF(EPI.ChildIndicationId,0), EPI.IndicationId) = EI.UniqueId
  WHERE EPI.ProcedureId = @ProcedureId
);

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	
-- Description of change
-- Invalid NED Definitions
------------------------------------------------------------------------------------------------------------------------
GO


UPDATE dbo.ERS_AdverseEvents SET NEDTerm = 'O2 desaturation sats < 85%' WHERE NEDTerm = 'O2 desaturation Sats < 85%'
GO


UPDATE ERS_TherapeuticTypes SET RecordId = 400 WHERE NedName = 'Balloon dilatation' AND RecordId = 4
GO

UPDATE ERS_DiagnosesMatrix SET NED_Name = 'Polyp' WHERE NED_Name = 'Polyps' and DisplayName = 'Ileum polyp(s)'
GO

UPDATE ERS_DiagnosesMatrix SET NED_Name = NULL WHERE NED_Name = 'Duodenitis , erosive'
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
			, CASE WHEN @ProcedureTypeId IN (1,3,4) THEN CASE Staff.[jManoeuvre] WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE NULL END END	AS '@jManoeuvre'	-- Opt -- Mandatory for OGD, Colon and Flexi procedures (Rectal retroversion)
			/*	##### Therapeutic = Sesion->Procedure-> Staff.members-> Staff-> Therapeutic; 1 [Staff] to Many [Therapeutic sessions]	*/
			, (
				Select * from (select 
					   T.NedName	AS '@type'	-- M	--## The type of therapeutic procedure.
					 , CASE WHEN rc.RegionId IS NULL THEN T.[Site] ELSE 'Anastomosis' END		AS '@site'	-- O -- BiopsyEnum  --## The location where the therapeutic procedure was performed.
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
						CASE WHEN rc.RegionId IS NULL THEN T.[Site] ELSE 'Anastomosis' END,
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


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

EXEC dbo.DropIfExist @ObjectName = 'usp_NEDi2_Get_Failed_Validation_Procedures',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE dbo.usp_NEDi2_Get_Failed_Validation_Procedures
AS
BEGIN
	SELECT l.ProcedureID 
	FROM dbo.ERS_NedI2FilesLog l 
		INNER JOIN dbo.ERS_Procedures p ON p.ProcedureId = l.ProcedureID
	WHERE (p.CreatedOn >= (select min(InstallDate) from DBVersion where VersionNum like '2%') 
		AND p.CreatedOn > DATEADD(YEAR, -1, GETDATE())) AND (l.Status = 2 AND l.ProcedureID NOT IN (SELECT l2.ProcedureID FROM dbo.ERS_NedI2FilesLog l2 WHERE l2.Status IN (5,6)))
END
GO

EXEC dbo.DropIfExist @ObjectName = 'usp_NEDi2_Procedure_Diagnoses',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO


SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
CREATE PROCEDURE dbo.usp_NEDi2_Procedure_Diagnoses
(
	@ProcedureId int
)
AS
BEGIN

	SELECT DISTINCT m.DisplayName, r.Region, d.Value
	FROM dbo.ERS_Procedures p 
		INNER JOIN dbo.ERS_Diagnoses d ON d.ProcedureID = p.ProcedureID	
		INNER JOIN dbo.ERS_DiagnosesMatrix m ON d.MatrixCode = m.Code
		INNER JOIN dbo.ERS_Sites s ON s.SiteId = d.SiteId
		INNER JOIN dbo.ERS_Regions r ON r.RegionId = s.RegionId
	WHERE m.NED_Name NOT IN (SELECT Ned_Name FROM dbo.tvfNED_Diagnoses(p.ProcedureType, p.ProcedureID))
		AND p.ProcedureId = @ProcedureId
END
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 10.4.24
-- TFS#	
-- Description of change
-- Extent returned for all procedure types
------------------------------------------------------------------------------------------------------------------------
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[tvfNED_ProcedureConsultants]
(
	@ProcedureId AS INT
	, @ProcedureType AS INT
)
-- =============================================
-- Description:	This will return the list of 'Consultants' for each Procedure- required for NED Export!
-- =============================================
RETURNS TABLE 
AS
RETURN 
(
	WITH EndoscopistSummary AS(
		select top 1 ProcedureId AS ProcedureId, ProcedureType, End1_GMCCode, Endoscopist1, Endo1Role, RoleTypeEnd1, End2_GMCCode, Endoscopist2, Endo2Role, RoleTypeEnd2, ListType from tvfEndoscopistSelectByProcedureSite(@ProcedureId,0)	
	)
	Select DISTINCT E.ProcedureId
	--, C.GMCCode AS professionalBodyCode
	--, 'UNITrainer' AS professionalBodyCode	 --## Change it for LIVE. In TEST- we need this dummy data to pass the NED Validation check!
	, LTRIM(RTRIM(E.End1_GMCCode)) AS professionalBodyCode
	, E.Endoscopist1 AS EndosId 
	, E.Endo1Role AS EndRole, E.ListType
	, E.RoleTypeEnd1 AS procedureRole
	, (Case E.Endo1Role When 1 Then 'Independent' Else 'Trainer' END) As endoscopistRole
	, 1 AS ConsultantTypeId
	,(SELECT
		CASE 
			WHEN E.ProcedureType IN (1,2,6,7,8) THEN
				CASE WHEN E.Endoscopist2 IS NULL THEN UEX.NedTerm
					 WHEN E.Endo1Role <> 1 AND NOT EXISTS (SELECT 1 FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.JManoeuvreId IS NOT NULL AND epue.ProcedureId = @ProcedureId) /*Trainee has an entry*/
										 THEN (SELECT UEX.NedTerm FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId) /*TrainEE did it so TrainER gets it too*/
					/*WHEN Endo1Role = 1 THEN*/ ELSE (SELECT UEX.NedTerm FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.ProcedureId = @ProcedureId) /*Endo is independant or TrainER did it alone */
				END
			WHEN E.ProcedureType IN (3,4,9) THEN
				CASE WHEN E.Endoscopist2 IS NULL THEN LEX.NEDTerm
					 WHEN E.Endo1Role <> 1 AND NOT EXISTS (SELECT 1 FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.RetroflectionPerformed IS NOT NULL AND epue.ProcedureId = @ProcedureId) 
										 THEN (SELECT LEX.NEDTerm FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId) /*TrainEE did it so TrainER gets it too*/
					/*WHEN E.Endo1Role = 1 THEN*/ ELSE (SELECT LEX.NEDTerm FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.ProcedureId = @ProcedureId) /*Endo is independant or TrainER did it alone */

				END
	 END) AS Extent
	,(SELECT
		CASE 
			WHEN E.ProcedureType IN (1,2,6,7,8) THEN
				CASE WHEN E.Endoscopist2 IS NULL THEN PUE.JManoeuvreId
					 WHEN E.Endo1Role <> 1 AND NOT EXISTS (SELECT 1 FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.JManoeuvreId IS NOT NULL AND epue.ProcedureId = @ProcedureId) /*Trainee has an entry*/
										 THEN (SELECT CONVERT(BIT, epue.JManoeuvreId) FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId) /*TrainEE did it so TrainER gets it too*/
					/*WHEN Endo1Role = 1 THEN*/ ELSE (SELECT CONVERT(BIT, epue.JManoeuvreId) FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.ProcedureId = @ProcedureId) /*Endo is independant or TrainER did it alone */
				END
			WHEN E.ProcedureType IN (3,4,9) THEN
				CASE WHEN E.Endoscopist2 IS NULL THEN PLE.RetroflectionPerformed
					 WHEN E.Endo1Role <> 1 AND NOT EXISTS (SELECT 1 FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.RetroflectionPerformed IS NOT NULL AND epue.ProcedureId = @ProcedureId) 
										 THEN (SELECT epue.RetroflectionPerformed FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId) /*TrainEE did it so TrainER gets it too*/
					/*WHEN E.Endo1Role = 1 THEN*/ ELSE (SELECT epue.RetroflectionPerformed FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.ProcedureId = @ProcedureId) /*Endo is independant or TrainER did it alone */

				END
		END) AS jManoeuvre
	 FROM EndoscopistSummary AS E
	 LEFT JOIN ERS_ProcedureLowerExtent				AS PLE ON PLE.ProcedureId = E.ProcedureId AND PLE.EndoscopistId = E.Endoscopist1
	 LEFT JOIN ERS_Extent							AS LEX  ON LEX.UniqueId = PLE.ExtentId
	 LEFT JOIN ERS_ProcedureUpperExtent				AS PUE ON PUE.ProcedureId = E.ProcedureId AND PUE.EndoscopistId = E.Endoscopist1
	 LEFT JOIN ERS_Extent							AS UEX  ON UEX.UniqueId = PUE.ExtentId
	 LEFT JOIN dbo.ERS_Users						AS U   ON E.Endoscopist1 = U.UserId

	UNION ALL --## Now Combine the TrainEE Record!
	
	Select DISTINCT E.ProcedureId
	--, C.GMCCode AS professionalBodyCode
	--, 'UNITrainee' AS professionalBodyCode --## Change it for LIVE. In TEST- we need this dummy data to pass the NED Validation check!
	, LTRIM(RTRIM(E.End2_GMCCode)) AS professionalBodyCode
	, E.Endoscopist2 AS EndosId, E.Endo2Role  AS EndRole, E.listType
	, E.RoleTypeEnd2 AS procedureRole
	, (Case E.Endo2Role When 1 Then 'Independent' Else 'Trainee' END) As endoscopistRole
	, 2 AS ConsultantTypeId
	, (SELECT 
		CASE 
			WHEN E.ProcedureType IN (1,2,6,7,8) THEN
				CASE WHEN E.Endo2Role = 1 THEN (SELECT UEX.NEDTerm FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId)
					 WHEN E.Endo2Role <> 1 AND EXISTS (SELECT 1 FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.JManoeuvreId IS NOT NULL AND epue.ProcedureId = @ProcedureId) 
												THEN (SELECT UEX.NEDTerm FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId)  /*TrainEEs outcome*/
				END
			WHEN E.ProcedureType IN (3,4,9) THEN 
				CASE WHEN E.Endo2Role = 1 THEN  (SELECT LEX.NEDTerm FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId)
					 WHEN E.Endo2Role <> 1 AND EXISTS (SELECT 1 FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.RetroflectionPerformed IS NOT NULL AND epue.ProcedureId = @ProcedureId) 
											THEN (SELECT LEX.NEDTerm FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId) /*TrainEEs outcome*/
				END
		END) AS Extent
	, (SELECT 
		CASE 
			WHEN E.ProcedureType IN (1,2,6,7,8) THEN
				CASE WHEN E.Endo2Role = 1 THEN (SELECT epue.JManoeuvreId FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId)
					 WHEN E.Endo2Role <> 1 AND EXISTS (SELECT 1 FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.JManoeuvreId IS NOT NULL AND epue.ProcedureId = @ProcedureId) 
												THEN (SELECT CONVERT(BIT, epue.JManoeuvreId) FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId)  /*TrainEEs outcome*/
				END
			WHEN E.ProcedureType IN (3,4,9) THEN 
				CASE WHEN E.Endo2Role = 1 THEN  (SELECT epue.RetroflectionPerformed FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId)
					 WHEN E.Endo2Role <> 1 AND EXISTS (SELECT 1 FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.RetroflectionPerformed IS NOT NULL AND epue.ProcedureId = @ProcedureId) 
											THEN (SELECT epue.RetroflectionPerformed FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId) /*TrainEEs outcome*/
				END
		END) AS jManoeuvre	
	from EndoscopistSummary AS E 
		LEFT JOIN ERS_ProcedureLowerExtent				AS PLE ON PLE.ProcedureId = E.ProcedureId AND PLE.EndoscopistId = E.Endoscopist2
		 LEFT JOIN ERS_Extent							AS LEX  ON LEX.UniqueId = PLE.ExtentId
		 LEFT JOIN ERS_ProcedureUpperExtent				AS PUE ON PUE.ProcedureId = E.ProcedureId AND PUE.EndoscopistId = E.Endoscopist2
		 LEFT JOIN ERS_Extent							AS UEX  ON UEX.UniqueId = PUE.ExtentId
		LEFT JOIN dbo.ERS_Users							AS U   ON E.Endoscopist2 = U.UserId
	Where E.Endoscopist2 IS NOT NULL
	);
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 10.04.24
-- TFS#	
-- Description of change
-- Removed stent placement from appearing for ERCP procedures
------------------------------------------------------------------------------------------------------------------------
GO
ALTER FUNCTION [dbo].[tvfNED_ProcedureTherapeutic]
(	
	  @ProcedureType AS INT
	, @ProcedureId AS INT
	, @CarriedOutRole AS INT --## 1: Endo1; 2: Endo2
)
RETURNS TABLE 
AS
RETURN 
(

WITH CTE AS ( --## Just wrapping the selection in the CTE to use later for a COUNT() operation
	
	SELECT      DISTINCT
		  UP.ProcedureId
		, UP.ProcedureType
		, UP.SiteId
		, CASE WHEN UP.SiteNo = -77 THEN 'Colon' ELSE UP.[Site] END AS Saite
		, CASE WHEN UP.SiteNo = -77 THEN 'Colon' ELSE UP.[Site] END As [Site]
		--, UP.TherapyTypeId
		--, TT.[Description]
		, TT.NedName
		, UP.EndoRole 
		,UP.EndoRoleId
		--, UT_CarriedOutRole
		--, ERCP_CarriedOutRole
		, (CASE WHEN TT.NedName LIKE 'Polyp%' THEN (SELECT TOP 1 Tattooed FROM ERS_CommonAbnoPolypDetails WHERE SiteId = UP.SiteId) ELSE NULL END) AS Tattooed
		, (CASE WHEN TT.NedName LIKE 'Stent placement%' then COALESCE(UGI_StentQty, ER_StentQty)				else 1 END) AS StentPerformed --## 'Stent Placement' for O/C/F; And 'Stent placement - pancreas/CBD' for ERCP
		--, UGI_StentQty, ER_StentQty --#############
		, ISNULL(dbo.fnNED_GetTherapTypeSuccess(ProcedureType, SiteId, UP.EndoRoleId, @CarriedOutRole, NedName),0) AS Successful
		, (CASE WHEN UP.TherapyTypeId=2 THEN	--## Any Therap in 'Other' Category
			dbo.fnNED_GetOtherTypeTheraps(ProcedureType, UP.SiteId, @CarriedOutRole) 
			END --## ELSE Return NULL... Should only be available when 'Other' Therap is present
		  ) AS Comment
	FROM            
		(SELECT			
				P.ProcedureId,  
				P.ProcedureType,
				S.SiteId, 
				S.SiteNo,
				CASE WHEN EXISTS (SELECT 1 FROM ERS_Sites WHERE ProcedureId = s.ProcedureId AND s.SiteId = SiteId AND AreaNo > 0) THEN dbo.fnNED_GetMarkedArea(S.ProcedureId, s.SiteId) ELSE R.NED_Term END As [Site],			
				--R.NED_Term AS [Site], --## Link to [dbo.ERS_Regions] via Sites.Id
				NULL [role]
				, UT.CarriedOutRole											AS UGI_CarriedOutRole
				, ER.CarriedOutRole											AS ERCP_CarriedOutRole				
				, CASE WHEN PD.Size <20 THEN NULL ELSE pt.NEDTerm	END	AS Tattooed
				, UT.StentInsertionQty										AS UGI_StentQty
				, ER.StentInsertionQty										AS ER_StentQty,
				CASE WHEN (UT.[None] = 1 OR T.[None] = 1) THEN 1 END AS [None], 
				CASE WHEN @ProcedureType IN (1,3,4,8,9) AND UT.ArgonBeamDiathermy = 1 THEN 3 END								AS ArgonBeamDiathermy, --## C/F/O
				CASE WHEN (@ProcedureType IN (1,3,9,8,4) AND UT.BalloonDilation = 1) OR 
						  (@ProcedureType IN (2,7) AND ER.BalloonDilation = 1) THEN 4 END	AS BalloonDilation,		--## ALL: Balloon sphicteroplasty	
				--CASE WHEN @ProcedureType = 2 AND (ER.BalloonDilation = 1) THEN  91 END	AS Sphincteroplasty,		--## ALL: Balloon sphicteroplasty	
				CASE WHEN @ProcedureType = 2 AND ER.BalloonTrawl = 1 THEN 5 END												AS BalloonTrawl,
				CASE WHEN @ProcedureType = 1 AND (UT.BandLigation = 1 OR UT.VaricealBanding = 1) THEN  6 END					AS BandLigation, 
				CASE WHEN @ProcedureType IN (3,9,4) AND UT.BandingPiles = 1 THEN 7 END										AS BandingPiles,		--## O / C / F
				CASE WHEN @ProcedureType = 1 AND UT.BotoxInjection	= 1 THEN  8 END											AS BotoxInjection,
				CASE WHEN @ProcedureType IN (1,9) and ((UT.BougieDilation = 1 OR UT.OesophagealDilatation=1 AND UT.DilatorType=2)
														OR (ER.BalloonTrawlDilatorType=2 or ER.DilatorType=2)) --## Need to confirm this Logic!
														THEN 9 END															AS BougieDilation, --## O / E	
				CASE WHEN @ProcedureType=2 AND ER.BrushCytology = 1 THEN 10 END												AS Brush,
				CASE WHEN @ProcedureType=2 AND ER.Cannulation = 1 THEN 11 END												AS Cannulation,
				CASE WHEN @ProcedureType IN (1,3,4,8,9) AND UT.Clip = 1 THEN 12 END											AS Clip,
				CASE WHEN @ProcedureType=2 AND ER.RendezvousProcedure = 1 THEN 13 END										AS RendezvousProcedure,
				CASE WHEN @ProcedureType=2 AND ER.DiagCholangiogram	= 1 THEN 14 END											AS DiagCholangiogram,
				CASE WHEN @ProcedureType=2 AND ER.DiagPancreatogram		= 1 THEN 15 END										AS DiagPancreatogram,
				CASE WHEN @ProcedureType IN (1,8,9) AND UT.EMR = 1 THEN 
														(CASE WHEN ISNULL(UT.EMRType, 0)<> 0 THEN 
															(CASE UT.EMRType WHEN 1 THEN 16 ELSE 19 END) 
														END) END															AS EMR,
				CASE WHEN @ProcedureType IN (3,9,4) AND UT.EndoloopPlacement = 1 THEN 17 END								AS EndoloopPlacement,
				CASE WHEN @ProcedureType=2 AND ER.EndoscopicCystPuncture = 1 THEN 18 END									AS Cyst,
				CASE WHEN @ProcedureType IN (1,3,9,4) AND UT.ForeignBody = 1 THEN 20 END									AS ForeignBody,
				CASE WHEN @ProcedureType=2 AND ER.Haemostasis = 1 THEN 21 END												AS Haemostasis,
				CASE WHEN @ProcedureType IN (1,9) AND UT.HeatProbe = 1 THEN 22 END											AS HeatProbe, 
				CASE WHEN @ProcedureType IN (1,9) AND (UT.HotBiopsy = 1 OR T.HotBiopsy = 1) THEN 23 END						AS HotBiopsy,
				CASE WHEN @ProcedureType NOT IN (6,7) AND UT.Injection = 1 OR ER.Injection = 1	THEN 24 END					AS Injection,
				CASE WHEN @ProcedureType=2 AND ER.Manometry = 1 THEN 25 END													AS Manometry,
				CASE WHEN @ProcedureType NOT IN (2,6,7) AND UT.Marking = 1 THEN 26 END										AS Marking,
				CASE WHEN @ProcedureType=2 AND ER.NasopancreaticDrain = 1 THEN 27 END										AS NasopancreaticDrain,
				CASE WHEN @ProcedureType IN (1,9) AND UT.GastrostomyInsertion = 1 AND UT.GastrostomyRemoval = 1 THEN 28 END		AS PEGChange,
				CASE WHEN @ProcedureType IN (1,9) AND UT.GastrostomyInsertion = 1 AND UT.GastrostomyRemoval = 0 THEN 29 END		AS PEGInsertion,
				CASE WHEN @ProcedureType IN (1,9) AND UT.GastrostomyInsertion = 0 AND UT.GastrostomyRemoval = 1 THEN 30 END		AS PEGRemoval,
				CASE WHEN (UT.Polypectomy = 1 OR ER.Polypectomy = 1) AND (ISNULL(PD.SiteId,0)) > 0 THEN 
					CASE PD.NedTerm 
													WHEN 'Polyp snare - cold' THEN 35 --## 'Polyp - snare cold'
													WHEN 'Polyp snare - hot' THEN 36 --## 'Polyp - snare hot'
													WHEN 'Polyp - hot biopsy' THEN 34 --## 'Polyp - hot biopsy'
													WHEN 'Polyp - cold biopsy polypectomy' THEN 31 --## 'Polyp - cold biopsy POLYPECTOMY'
													WHEN 'Polyp - EMR' THEN 32 --## 'Polyp - EMR'
													WHEN 'Polyp - ESD' THEN 33 --## 'Polyp - ESD'
													WHEN 'Polyp - cold biopsy sampling' THEN 75 --## 'Polyp - cold biopsy sampling'
													WHEN 'Polyp - FTR' THEN 76 --## 'Polyp - FTR'
													WHEN 'Polyp - not removed' THEN 77 --## 'Polyp - FTR'
					END 
				END																											AS PolypRemovalType, 			
				CASE WHEN @ProcedureType=1 AND ((UT.Polypectomy = 1 OR ER.Polypectomy = 1) AND PD.SiteId is null) THEN 37 END					AS Polypectomy,			
				CASE WHEN @ProcedureType=1 AND UT.RFA = 1 THEN 38 END														AS RFA, 
				CASE WHEN @ProcedureType=2 AND (ER.PanOrificeSphincterotomy = 1 OR ER.Papillotomy = 1) THEN 39 END			AS Sphincterotomy,
				CASE WHEN (@ProcedureType IN (1,3,8,9,4) AND (UT.StentRemoval = 1 AND UT.StentInsertion = 1))  OR 
						  (@ProcedureType = 2 AND (ER.StentRemoval = 1 AND ER.StentInsertion = 1) AND LOWER(ERRegions.Area)<>'biliary' AND LOWER(ERRegions.Area)<>'pancreas') THEN 40 END  AS StentChange,
				CASE WHEN (@ProcedureType IN (1,3,4,8,9) AND UT.StentRemoval = 0 AND UT.StentInsertion = 1)  THEN 41 END		AS StentPlacement,
				CASE WHEN (@ProcedureType IN (1,3,4,8,9) AND (UT.StentRemoval = 1 AND UT.StentInsertion = 0)) OR
						  (@ProcedureType = 2 AND (ER.StentRemoval = 1 AND ER.StentInsertion = 0)AND LOWER(ERRegions.Area)<>'biliary' AND LOWER(ERRegions.Area)<>'pancreas') /**/  THEN 44 END	AS StentRemoval,
				CASE WHEN @ProcedureType=2 AND (ER.StoneRemoval = 1 AND Abn.StonesSize>= 10) THEN 45 END												AS StoneExtractionGT10, --## Stone Size in mm
				CASE WHEN @ProcedureType=2 AND (ER.StoneRemoval = 1 AND Abn.StonesSize < 10) THEN 46 END												AS StoneExtractionLT10,
				CASE WHEN @ProcedureType=1 AND UT.VaricealSclerotherapy = 1 THEN 47 END										AS VaricealSclerotherapy,
				CASE WHEN @ProcedureType IN (1,3,4,8,9) AND UT.YAGLaser = 1 THEN 48 END										AS YAGLaser,
				--CASE WHEN UT.Diathermy = 1 THEN 50	END																		AS Diathermy,
				--CASE WHEN UT.EndoscopicResection = 1 THEN 98 END
				CASE WHEN UT.EMR = 1 AND ISNULL(UT.EMRType, 0) = 3 THEN 98 END												AS EndoscopicResection,
				CASE WHEN @ProcedureType=3 AND UT.PancolonicDyeSpray = 1 THEN 66 END										AS PancolonicDyeSpray,
				CASE WHEN @ProcedureType IN (3,4,9) AND UT.ColonicDecompression = 1 THEN 84 END								AS ColonicDecompression,
				CASE WHEN @ProcedureType IN (3,4,9) AND UT.FlatusTubeInsertion = 1 THEN 1069 END								AS FlatusTubeInsertion,
				CASE WHEN @ProcedureType = 2 AND ER.Cholangioscopy = 1 and er.CholangioscopyType = 1 THEN 82 END									AS LesionAssessment,
				CASE WHEN @ProcedureType = 2 AND ER.Cholangioscopy = 1 and er.CholangioscopyType = 2 THEN 83 END									AS StoneTherapy,
				CASE WHEN @ProcedureType = 2 AND (ER.StentRemoval = 1 AND ER.StentInsertion = 1) 
															AND LOWER(ERRegions.Area)='biliary'
														AND LOWER(R.Region) <>'common bile duct'  THEN 68 END					AS StentChangeBiliary,
				CASE WHEN @ProcedureType = 2 AND (ER.StentRemoval = 1 AND ER.StentInsertion = 1) 
															AND LOWER(ERRegions.Area)='pancreas' THEN 79 END				AS StentChangePancreatic,
				CASE WHEN @ProcedureType = 2 AND (ER.StentRemoval = 0 AND ER.StentInsertion = 1) 
															AND LOWER(R.Region)='common bile duct' THEN 42 END				AS StentPlacementCBD,
				CASE WHEN @ProcedureType = 2 AND (ER.StentRemoval = 0 AND ER.StentInsertion = 1 
															AND LOWER(ERRegions.Area)='biliary')
														AND LOWER(R.Region) <>'common bile duct'  THEN 69 END				AS StentPlacementBiliary,
				CASE WHEN @ProcedureType = 2 AND (ER.StentRemoval = 0 AND ER.StentInsertion = 1 
															AND LOWER(ERRegions.Area)='pancreas') THEN 95 END				AS StentPlacementPancreatic,
				CASE WHEN @ProcedureType = 2 AND (ER.StentInsertion = 0 AND ER.StentRemoval = 1) 
															AND LOWER(ERRegions.Area)='biliary' THEN 96 END					AS StentRemovalBiliary,
				CASE WHEN @ProcedureType = 2 AND (ER.StentInsertion = 0 AND ER.StentRemoval = 1) 
															AND LOWER(ERRegions.Area)='pancreas' THEN 97 END				AS StentRemovalPancreatic,
				CASE WHEN @ProcedureType=1 AND UT.NGNJTubeInsertion = 1 AND	LOWER(OGDRegions.Area) = 'stomach' THEN 52 END			AS NGTInsertion,
				CASE WHEN @ProcedureType=1 AND UT.NGNJTubeInsertion = 1 AND	LOWER(OGDRegions.Area) = 'duodenum' THEN 53 END			AS NJTInsertion,
				CASE WHEN (@ProcedureType=7 AND ER.FineNeedleAspiration = 1 AND 
																		er.FineNeedleAspirationType = 1) OR
						  (@ProcedureType=6 AND UT.FineNeedleAspiration = 1 AND 
																		UT.FineNeedleAspirationType = 1) THEN 73 END			AS FNACysticLesion,
				CASE WHEN (@ProcedureType=7 AND ER.FineNeedleAspiration = 1 AND 
																		er.FineNeedleAspirationType = 2) OR
						  (@ProcedureType=6 AND UT.FineNeedleAspiration = 1 AND 
																		UT.FineNeedleAspirationType = 2) THEN 78 END			AS FNASolidLesion,
				CASE WHEN (@ProcedureType=7 AND ER.FineNeedleBiopsy = 1) OR
						  (@ProcedureType=6 AND UT.FineNeedleBiopsy = 1)	THEN 74 END											AS FNBSolidLesion,
				
				/* 
					There are many other fields in the OGD/ERCP Therap Tables, but NED isn't interested in each and every Theraps.
					The Valid/Acceptable names are given in the XSD/Documentation file. Few other Theraps are put in 
					the 'Other' Category- instructions found in the Excel file, by Steve!
				*/

				(CASE  
						WHEN P.ProcedureType = 1 THEN							--## OGD / Gastroscopy
							(CASE WHEN 
									(UT.BicapElectro = 1  OR UT.PyloricDilatation = 1 OR
									UT.pHProbeInsert = 1 OR UT.EndoClot = 1 OR 
									UT.Diathermy = 1 OR
									UT.Haemospray = 1 OR LEN(UT.Other) > 1) THEN 2
								END)
						WHEN P.ProcedureType = 2 THEN							--## ERCP
							(CASE WHEN 
									(ER.SnareExcision = 1 OR 
									ER.YAGLaser = 1 OR ER.ArgonBeamDiathermy = 1 OR
									ER.BandLigation = 1 OR ER.BotoxInjection = 1 OR
									ER.EndoloopPlacement = 1 OR ER.HeatProbe = 1 OR
									ER.BicapElectro = 1 OR
									ER.ForeignBody = 1 OR ER.HotBiopsy = 1 OR
									ER.EMR = 1 OR ER.Marking = 1 OR
									ER.Clip = 1 OR ER.PyloricDilatation = 1 OR
									ER.StrictureDilatation = 1 OR ER.GastrostomyInsertion = 1 OR -- GastrostomyInsertion = Nasojejunal tube (NJT) 
									((ER.StentRemoval = 0 AND ER.StentInsertion = 1) AND (LOWER(ERRegions.Area)<>'biliary' AND LOWER(ERRegions.Area)<>'pancreas')) OR
									ER.GastrostomyRemoval = 1 OR LEN(ER.Other) > 1  --GastrostomyRemoval = Nasojejunal Removal (NJT) 
									) THEN 2
							  END)
						WHEN P.ProcedureType IN (3, 13, 4) THEN					-- ## COLON / FLEXI
							(CASE WHEN 
									(UT.BandLigation = 1 OR UT.VaricealBanding = 1 OR 
									UT.BotoxInjection = 1 OR UT.HeatProbe = 1 OR
									UT.BicapElectro = 1 OR
									UT.HotBiopsy = 1 OR UT.EMR = 1 OR
									UT.Diathermy = 1 OR
									UT.Sigmoidopexy = 1 OR UT.EndoClot = 1 OR
									LEN(UT.Other) > 1) THEN 2
							  END)
						 ELSE
							(CASE WHEN 
									(LEN(UT.Other) > 1) THEN 2
							  END)
				END) AS Other,
				CASE isnull(UT.EndoRole, ER.EndoRole) 
					when 1 then 'Independent (no trainer)'
					when 4 then 'Independent (no trainer)'
					when 2 then (case when @CarriedOutRole = 1 then 'I observed' else 'Was observed' END)
					when 3 then (case when @CarriedOutRole = 1 then 'I assisted physically' else 'Was assisted physically' END)
					when 5 then (case when @CarriedOutRole = 1 then 'I assisted physically' else 'Was assisted physically' END)
				END	AS EndoRole,
				isnull(UT.EndoRole, ER.EndoRole) AS EndoRoleId
			FROM            dbo.ERS_Procedures	AS	P	
				INNER JOIN				[dbo].ERS_Sites					AS  S ON P.ProcedureId = S.ProcedureId  
				LEFT JOIN				[dbo].ERS_Regions				AS  R ON S.RegionId = R.RegionId --## To Get SiteName
				LEFT JOIN ERS_AbnormalitiesMatrixERCP AS ERRegions ON ERRegions.Region = r.Region
				LEFT JOIN ERS_AbnormalitiesMatrixUpperGI AS OGDRegions ON OGDRegions.Region = r.Region
				LEFT OUTER JOIN			[dbo].ERS_ERCPTherapeutics		AS ER ON S.SiteId = ER.SiteId -- ER.CarriedOutRole  = @CarriedOutRole
				--LEFT OUTER JOIN			[dbo].ERS_ColonTherapeutics		AS CT ON S.SiteId = CT.SiteId
				LEFT OUTER JOIN				[dbo].ERS_UpperGITherapeutics	AS UT ON S.SiteId = UT.SiteId -- UT.CarriedOutRole  = @CarriedOutRole
				--LEFT OUTER JOIN			[dbo].[ERS_ColonAbnoLesions]	AS  L ON S.SiteId = L.SiteId 
				LEFT OUTER JOIN			[dbo].[ERS_UpperGISpecimens]	AS  T ON S.SiteId = T .SiteId
				LEFT OUTER JOIN			[dbo].[ERS_ERCPAbnoDuct]		AS Abn ON S.SiteId = Abn.SiteId
				LEFT OUTER JOIN			(SELECT d.PolypDetailId, d.TattooedId, d.SiteId, d.RemovalMethod, r.NEDTerm, d.Size FROM [dbo].[ERS_CommonAbnoPolypDetails] d LEFT JOIN ERS_PolypRemovalTypes r ON r.UniqueId = d.RemovalMethod WHERE d.SiteId IN (SELECT SiteId FROM ERS_Sites WHERE ProcedureId = @ProcedureId)) AS PD ON PD.SiteId = S.SiteId
				LEFT OUTER JOIN			ERS_TattooOptions pt ON pt.UniqueId = PD.TattooedId
				Where P.ProcedureId= @ProcedureId
				AND (((UT.EndoRole in (1, 2, 3, 5) AND @CarriedOutRole = 1)
				     OR
					 (UT.EndoRole in (2, 3, 4, 5) AND @CarriedOutRole = 2))
					OR
					((ER.EndoRole in (1, 2, 3, 5) AND @CarriedOutRole = 1)
				     OR
					 (ER.EndoRole in (2, 3, 4, 5) AND @CarriedOutRole = 2)))
		) AS PT 
				UNPIVOT (TherapyTypeId FOR Therapies IN 
												([None], Other
												, ArgonBeamDiathermy, BalloonDilation, /*Sphincteroplasty,*/ BandLigation, BotoxInjection, BougieDilation, Clip, EndoloopPlacement, EMR, BandingPiles	--, Colon Fields: (ESD,EMR)
												, ForeignBody, HeatProbe, HotBiopsy,  Marking, PEGChange, PEGInsertion, PEGRemoval, Polypectomy, RFA
												, StentRemoval, StentChange, StentPlacement, YAGLaser, Injection, PolypRemovalType
											--## Add ERCP Fields
												, BalloonTrawl,Brush, Cannulation, RendezvousProcedure, DiagCholangiogram, DiagPancreatogram
												, Cyst, Haemostasis, Manometry, Sphincterotomy, NasopancreaticDrain, StentPlacementCBD, 
												StoneExtractionGT10, StoneExtractionLT10, VaricealSclerotherapy, EndoscopicResection,PancolonicDyeSpray,
												ColonicDecompression,FlatusTubeInsertion, LesionAssessment,StoneTherapy,StentChangeBiliary,StentChangePancreatic,
												StentPlacementBiliary,StentPlacementPancreatic,StentRemovalBiliary,StentRemovalPancreatic,NGTInsertion,NJTInsertion,FNACysticLesion,
												FNASolidLesion,FNBSolidLesion)
						)  AS UP 
		LEFT JOIN dbo.ERS_TherapeuticTypes TT ON UP.TherapyTypeId = TT.RecordId
			WHERE 1=1
	) --## End of CTE.. Now just select the desired fields from this CTE

	SELECT ProcedureId, ProcedureType, CTE.SiteId, Saite, [Site], NedName, EndoRole,
		(CASE WHEN NedName LIKE '%not removed' THEN PS.PolypSizeText ELSE NULL END)		As polypSize,
		(CASE WHEN NedName LIKE 'Polyp%' AND NEDName <> 'polyp - not removed' THEN PolypSizeInt ELSE NULL END) AS PolypSizeInt,
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.Morphology ELSE NULL END) AS Morphology,
		Tattooed,
		CASE WHEN NedName = 'Polyp - not removed' then PS.Detected ELSE NULL END Detected,
		(CASE 
			WHEN NedName LIKE 'Polyp%' THEN 
				CASE WHEN NedName = 'Polyp - not removed' then 0 ELSE PS.Detected END
			WHEN NedName like 'Clip%' THEN
				(Select T.ClipNum from ERS_UpperGITherapeutics T where T.SiteId = CTE.SiteId)
			--WHEN NedName LIKE '%injection%' THEN
			--	(SELECT T.InjectionNumber FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId)
			WHEN NedName LIKE '%argon beam%' THEN
				(SELECT T.ArgonBeamDiathermyPulses FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId)
			WHEN NedName LIKE '%FNA%' THEN
				CASE WHEN ProcedureType IN (2,7) THEN (SELECT FNAPerformed FROM ERS_ERCPTherapeutics T WHERE T.SiteId = CTE.SiteId)
				ELSE (SELECT FNAPerformed FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId) END
			WHEN NedName LIKE '%FNB%' THEN
				CASE WHEN ProcedureType IN (2,7) THEN (SELECT FNBPerformed FROM ERS_ERCPTherapeutics T WHERE T.SiteId = CTE.SiteId)
				ELSE (SELECT FNBPerformed FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId) END
			WHEN NedName = 'Band ligation' THEN	
				(SELECT T.BandLigationPerformed FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId)
			WHEN NedName = 'Marking / tattooing' THEN	
				(SELECT T.MarkedQuantity FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId)
			ELSE 
				(CASE 
					WHEN StentPerformed>CTE.Successful THEN 
						StentPerformed 
					ELSE CTE.Successful 
				END) 
			END)		As Performed, --### Successful and Performed should be same!
		(CASE 
			WHEN NedName LIKE 'Polyp%' THEN 
				CASE WHEN CTE.EndoRoleId = 5 AND @CarriedOutRole = 1 THEN PS.Successful 
				     WHEN CTE.EndoRoleId = 5 AND @CarriedOutRole <> 1 THEN 0 ELSE
				PS.Successful END
			--WHEN NedName like 'Clip%' THEN 
			--	(Select T.ClipNumSuccess from ERS_UpperGITherapeutics T where T.SiteId = CTE.SiteId)
			--WHEN NedName LIKE '%injection%' THEN
			--	(SELECT T.InjectionNumber FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId)
			WHEN NedName LIKE '%argon beam%' THEN
				(SELECT T.ArgonBeamDiathermyPulses FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId)
			--WHEN NedName LIKE '%FNA%' THEN
			--	CASE WHEN ProcedureType IN (2,7) THEN (SELECT FNASuccessful FROM ERS_ERCPTherapeutics T WHERE T.SiteId = CTE.SiteId)
			--	ELSE (SELECT FNASuccessful FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId) END
			--WHEN NedName LIKE '%FNB%' THEN
			--	CASE WHEN ProcedureType IN (2,7) THEN (SELECT FNBSuccessful FROM ERS_ERCPTherapeutics T WHERE T.SiteId = CTE.SiteId)
			--	ELSE (SELECT FNBSuccessful FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId) END
			WHEN NedName = 'Marking / tattooing' THEN	
				(SELECT T.MarkedQuantity FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId)
			--WHEN NedName = 'Band ligation' THEN	
			--	(SELECT T.BandLigationSuccessful FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId)
			ELSE CTE.Successful
		END) AS Successful, --## 'CTE.StentPerformed' watches on the 'Stent placement% (CBD/PAN)' Qty' for Overall level.. better accuracy!
		(CASE 
			WHEN NedName LIKE 'Polyp%' THEN 
				PS.Retrieved
			WHEN NedName LIKE '%FNA%' THEN
				CASE WHEN ProcedureType IN (2,7) THEN (SELECT FNARetreived FROM ERS_ERCPTherapeutics T WHERE T.SiteId = CTE.SiteId)
				ELSE (SELECT FNARetreived FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId) END
			WHEN NedName LIKE '%FNB%' THEN
				CASE WHEN ProcedureType IN (2,7) THEN (SELECT FNBRetreived FROM ERS_ERCPTherapeutics T WHERE T.SiteId = CTE.SiteId)
				ELSE (SELECT FNBRetreived FROM ERS_UpperGITherapeutics T WHERE T.SiteId = CTE.SiteId) END 
			ELSE 
				0
		END)			As Retrieved,
		Comment 
		FROM CTE
		INNER JOIN (SELECT 
						SiteId, SUM(Detected) AS Detected, sum(Retrieved) AS Retrieved, SUM(Successful) AS Successful
						, PolypSizeText = (CASE WHEN Size IS NULL OR Size=0 THEN NULL WHEN Size<10 THEN 'ItemLessThan10mm' WHEN Size BETWEEN 10 AND 19 THEN 'Item10to19mm' ELSE 'Item20OrLargermm' END)
						, PolypSizeInt = Size
						, Morphology
					FROM dbo.tvfNED_PolypsDetailsView(@ProcedureType, @ProcedureId)
					GROUP BY SiteId, Retrieved, Successful, size,Morphology	)AS PS ON PS.SiteId = CTE.SiteId
	UNION ALL -- ## A Default Blank ROW.. ONLY when no Therap Record exist..
		SELECT TOP 1
			@ProcedureId AS ProcedureId, @ProcedureType	AS ProcedureType, NULL AS SiteId, NULL AS Saite
			, 'None' AS [Site]
			, 'None' AS NedName
			, NULL AS EndoRole	
			, NULL AS polypSize
			, NULL as PolypSizeInt
			, NULL AS Morphology
			, NULL AS Tattooed
			, NULL AS Detected
			, 0 AS Performed
			, 0 AS Successful
			, 0 AS Retrieved
			, NULL  AS Comment
		WHERE (SELECT IsNull(count(*), 0) FROM CTE)<1


);
GO


ALTER FUNCTION [dbo].[fnNED_GetOtherTypeTheraps]
(
	@ProcType		AS INT,
	@SiteId			AS INT,
	@EndRole		AS INT
)
RETURNS varchar(250)
AS
-- =============================================
-- Description:	This will Concatenate the 'Other' Type of TherapProcs which are not recognised by NED Schema.
--				So- when only 'OTHER' is passed as parameter- it will concatenate some specific theraps,
--						like: Bicap, Diathermy, Snare Excision and OTher Field's data itself
-- =============================================
BEGIN	
	DECLARE @ResultVar VARCHAR(250);

--	IF Lower(@TherapName) = 'other'
		BEGIN
			IF @ProcType=1		--## OGD / Gastroscopy
				BEGIN
					SELECT @ResultVar=(
							COALESCE((CASE WHEN T.BicapElectro = 1		THEN 'Bicap electrocautery, '		END), '') +
							COALESCE((CASE WHEN T.Diathermy = 1			THEN 'Diathermy, '			END), '') +
							COALESCE((CASE WHEN T.PyloricDilatation = 1	THEN 'Pyloric Dilatation, '	END), '') +
							COALESCE((CASE WHEN T.pHProbeInsert = 1		THEN 'pHProbe Insert, '		END), '') +
							COALESCE((CASE WHEN T.EndoClot = 1 		THEN 'Endoclot, '		END), '') +
							COALESCE((CASE WHEN T.Haemospray = 1 		THEN 'Haemospray, '		END), '') +
							COALESCE(T.Other, '')  )
						FROM [dbo].ERS_UpperGITherapeutics AS T
						INNER JOIN dbo.ERS_Sites AS S ON T.SiteId=S.SiteId
						WHERE T.SiteId = @SiteId
						  AND T.CarriedOutRole = @EndRole
						  AND ((IsNUll(BicapElectro, 0)<>0 OR IsNull(Diathermy, 0)<>0 OR 
							IsNUll(PyloricDilatation, 0)<>0 OR IsNull(pHProbeInsert, 0)<>0 OR 
							IsNUll(EndoClot, 0)<>0 OR IsNull(Haemospray, 0)<>0) OR 
							LEN(IsNull(Other, '')) >= 1)
				END
			ELSE IF @ProcType = 2 --## ERCP
				BEGIN	
					SELECT 
						@ResultVar =(
						  COALESCE(CASE WHEN SnareExcision = 1 THEN 'Snare Excision, ' END, '') +
						  COALESCE(CASE WHEN YAGLaser = 1 THEN 'YAG laser, ' END, '') +
						  COALESCE(CASE WHEN ArgonBeamDiathermy = 1 THEN 'Argon beam photocoagulation, ' END, '') +
						  COALESCE(CASE WHEN BandLigation = 1 THEN 'Band ligation, ' END, '') +
						  COALESCE(CASE WHEN BotoxInjection = 1 THEN 'Botox injection, ' END, '') +
						  COALESCE(CASE WHEN EndoloopPlacement = 1 THEN 'Endoloop placement, ' END, '') +
						  COALESCE(CASE WHEN HeatProbe = 1 THEN 'Heater probe, ' END, '') +
						  COALESCE(CASE WHEN BicapElectro = 1 THEN 'Bicap electrocautery, ' END, '') +
						  COALESCE(CASE WHEN Diathermy = 1 THEN 'Diathermy , ' END, '') +
						  COALESCE(CASE WHEN ForeignBody = 1 THEN 'Foreign body removal, ' END, '') +
						  COALESCE(CASE WHEN HotBiopsy = 1 THEN 'Hot biopsy, ' END, '') +
						  COALESCE(CASE WHEN EMR = 1 THEN 'EMR, ' END, '') +
						  COALESCE(CASE WHEN Marking = 1 THEN 'Marking / tattooing, ' END, '') +
						  COALESCE(CASE WHEN Clip = 1 THEN 'Clip placement, ' END, '') +
						  COALESCE(CASE WHEN PyloricDilatation = 1 THEN 'Pyloric/duodenal dilatation, ' END, '') +
						  COALESCE(CASE WHEN StrictureDilatation = 1 THEN 'Stricture dilatation, ' END, '') +
						  COALESCE(CASE WHEN GastrostomyInsertion = 1 THEN 'Nasojejunal tube (NJT), ' END, '') +
						  COALESCE(CASE WHEN GastrostomyRemoval = 1 THEN 'Nasojejunal removal (NJT), ' END, '') +
						  COALESCE(CASE WHEN (StentRemoval = 0 AND StentInsertion = 1) and (LOWER(ERRegions.Area)<>'biliary' AND LOWER(ERRegions.Area)<>'pancreas') THEN 'Stent placement, ' END, '') +
						  COALESCE(Other, '')
						)

						FROM dbo.ERS_ERCPTherapeutics AS T
						INNER JOIN dbo.ERS_Sites AS S ON T.SiteId=S.SiteId
						INNER JOIN [dbo].ERS_Regions AS  R ON S.RegionId = R.RegionId --## To Get SiteName
						LEFT JOIN ERS_AbnormalitiesMatrixERCP AS ERRegions ON ERRegions.Region = r.Region
						WHERE T.SiteId = @SiteId AND CarriedOutRole = @EndRole
						AND ((IsNUll(SnareExcision, 0)<>0 OR IsNull(YAGLaser, 0)<>0 OR 
							IsNUll(ArgonBeamDiathermy, 0)<>0 OR IsNull(BandLigation, 0)<>0 OR 
							IsNUll(BotoxInjection, 0)<>0 OR IsNull(EndoloopPlacement, 0)<>0 OR 
							IsNUll(HeatProbe, 0)<>0 OR IsNull(BicapElectro, 0)<>0 OR 
							IsNUll(Diathermy, 0)<>0 OR IsNull(ForeignBody, 0)<>0 OR 
							IsNUll(HotBiopsy, 0)<>0 OR IsNull(EMR, 0)<>0 OR 
							IsNUll(Marking, 0)<>0 OR IsNull(Clip, 0)<>0 OR 
							IsNUll(PyloricDilatation, 0)<>0 OR IsNull(GastrostomyInsertion, 0)<>0 OR 
							IsNUll(GastrostomyRemoval, 0)<>0 OR IsNull(StrictureDilatation, 0)<>0) OR 
							ISNULL(StentInsertion,0) <> 0 OR
							LEN(IsNull(Other, '')) >= 1)
												
					END				
			ELSE IF @ProcType = 3 OR @ProcType = 13 OR @ProcType = 4 --## FLEXY/COLON
				BEGIN
					SELECT @ResultVar=(
							COALESCE((CASE WHEN T.BandLigation = 1 OR T.VaricealBanding = 1	THEN 'Band ligation, '		END), '') +
							COALESCE((CASE WHEN T.BotoxInjection = 1		THEN 'Botox injection, '		END), '') +
							COALESCE((CASE WHEN T.HeatProbe = 1		THEN 'Heater probe, '		END), '') +
							COALESCE((CASE WHEN T.BicapElectro = 1		THEN 'Bicap electrocautery, '		END), '') +
							COALESCE((CASE WHEN T.Diathermy = 1		THEN 'Diathermy, '		END), '') +
							COALESCE((CASE WHEN T.HotBiopsy = 1		THEN 'Hot biopsy, '		END), '') +
							COALESCE((CASE WHEN T.EMR = 1		THEN 'EMR, '		END), '') +
							COALESCE((CASE WHEN T.EndoClot = 1		THEN 'Endoclot, '		END), '') +
							COALESCE((CASE WHEN T.Sigmoidopexy = 1		THEN 'Sigmoidopexy, '		END), '') +
							COALESCE(T.Other, '')  )
						FROM [dbo].ERS_UpperGITherapeutics AS T
						INNER JOIN dbo.ERS_Sites AS S ON T.SiteId=S.SiteId 
						WHERE T.SiteId = @SiteId
						  AND T.CarriedOutRole = @EndRole
						  AND ((IsNUll(BandLigation, 0)<>0 OR IsNull(VaricealBanding, 0)<>0 OR 
							IsNUll(BotoxInjection, 0)<>0 OR IsNull(HeatProbe, 0)<>0 OR 
							IsNUll(BicapElectro, 0)<>0 OR IsNull(Diathermy, 0)<>0 OR 
							IsNUll(HotBiopsy, 0)<>0 OR IsNull(EMR, 0)<>0 OR 
							IsNUll(EndoClot, 0)<>0 OR IsNull(Sigmoidopexy, 0)<>0) OR 
							LEN(IsNull(Other, '')) >= 1)
				END
			ELSE IF @ProcType = 8 OR @ProcType = 9 --## FLEXY/COLON
				BEGIN	
					SELECT @ResultVar=(
							COALESCE(T.Other, '')  )
						FROM [dbo].ERS_UpperGITherapeutics AS T
						INNER JOIN dbo.ERS_Sites AS S ON T.SiteId=S.SiteId 
						WHERE T.SiteId = @SiteId
						  AND T.CarriedOutRole = @EndRole
						  AND (LEN(IsNull(Other, '')) >= 1)				
				END
		END
	
	SET @ResultVar = ltrim(rtrim(@ResultVar));
	--## Remove the Last ',' of the String; That's a virus! Bad for indigestion!
	SELECT @ResultVar= CASE 
						WHEN RIGHT(@ResultVar, 1)=',' THEN SUBSTRING(@ResultVar, 1, LEN(@ResultVar)-1)
						ELSE @ResultVar END;

	RETURN @ResultVar;
END
GO


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	
-- Description of change
-- other indications grouped where multiple are selected
------------------------------------------------------------------------------------------------------------------------
GO

ALTER FUNCTION [dbo].[tvfNED_ProcedureIndication]
(
	@ProcedureId AS INT
)
-- =============================================
-- Description:	This will return the list of 'Indication' for each Procedure- required for NED Export!
-- =============================================
RETURNS TABLE 
AS
RETURN 
(
  Select 
		 ISNULL(NULLIF(dbo.HTMLDecode(EI.NEDTerm),''), 'Other') NEDTerm --any entry that does not have a NED term in the lookup table is to be treated as other
		, CASE WHEN EI.NEDTerm = 'Other' THEN EPI.AdditionalInformation ELSE NULL END AS Comment --where the NED term is blank, the description should be included in the other field
		, CASE WHEN EI.NEDTerm = 'FIT Positive' then CONVERT(decimal(18,2), EPI.AdditionalInformation) ELSE NULL END AS fitPositiveValue
		, CASE WHEN EI.NEDTerm = 'Elevated calprotectin' then EPI.AdditionalInformation ELSE NULL END AS elevatedCalprotectinValue
  from ERS_ProcedureIndications EPI
  join ERS_Indications EI on ISNULL(NULLIF(EPI.ChildIndicationId,0), EPI.IndicationId) = EI.UniqueId
  WHERE EPI.ProcedureId = @ProcedureId AND NEDTerm <> 'Other'
UNION ALL /*Below groups all 'Other' types into a single entry*/
 Select DISTINCT
		 'Other' NEDTerm 
		, (SELECT 
			 LTRIM(substring((SELECT ', ' + CASE WHEN EI.Description = 'Obstructed CBD/CHD' THEN 'Obstructed CBD/CHD' ELSE AdditionalInformation END
						 from ERS_ProcedureIndications EPI
						  inner join  ERS_Indications  EI on ISNULL(NULLIF(EPI.ChildIndicationId,0), EPI.IndicationId) = EI.UniqueId
						  WHERE EPI	.ProcedureId = @ProcedureId	
						  and NEDTerm = 'other' 
						 FOR XML PATH('')),2,4000))) AS Comment --where the NED term is blank, the description should be included in the other field
		, CASE WHEN EI.NEDTerm = 'FIT Positive' then CONVERT(decimal(18,2), EPI.AdditionalInformation) ELSE NULL END AS fitPositiveValue
		, CASE WHEN EI.NEDTerm = 'Elevated calprotectin' then EPI.AdditionalInformation ELSE NULL END AS elevatedCalprotectinValue
  from ERS_ProcedureIndications EPI
  join ERS_Indications EI on ISNULL(NULLIF(EPI.ChildIndicationId,0), EPI.IndicationId) = EI.UniqueId
  WHERE EPI.ProcedureId = @ProcedureId AND NEDTerm = 'Other'


);
GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO



EXEC dbo.DropIfExist @ObjectName = 'usp_NEDi2_Procedure_Scopes',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[usp_NEDi2_Procedure_Scopes]
(
	@ProcedureId int
)
AS
BEGIN

	SELECT DISTINCT s.ScopeName
	FROM dbo.ERS_Procedures p 
		INNER JOIN dbo.ERS_Scopes s ON s.ScopeId = p.Instrument1
	WHERE p.ProcedureId = @ProcedureId
END
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 22.4.24
-- TFS#	
-- Description of change
-- NED Terms were NULL and failing at NED
------------------------------------------------------------------------------------------------------------------------
GO


UPDATE ERS_Regions SET NED_Term = 'Sigmoid' WHERE Region = 'Mid Sigmoid' AND NED_Term IS NULL
GO
UPDATE ERS_Regions SET NED_Term = 'Gastro-oesophageal junction' WHERE Region = 'GOJ' AND NED_Term IS NULL
GO




------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO
