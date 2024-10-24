/*
	The following Scripts are inserted by Shawkat Osman;
	All the views were created by William.
*/


-- ############################################################################################################################
-- #####################		Function: fnShouldIncludeUGI							#######################################
-- ############################################################################################################################
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shawkat Osman
-- Create date: 2017-06-08
-- Description:	We will need to know in many Reports/Ecreen/StoredProc- whether to include OLD UGI data or not! 
--					Use the function rather than writing InLine queries all the time!
-- =============================================
CREATE FUNCTION dbo.fnShouldIncludeUGI
(
)
RETURNS BIT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @UnionUGI_Data AS BIT;
	select top 1 @UnionUGI_Data= IncludeUGI from ERS_SystemConfig;

	-- Return the result of the function
	RETURN @UnionUGI_Data;

END
GO
-- ----------------------------		End of Function: fnShouldIncludeUGI							-------------------------------


-- ############################################################################################################################
-- #####################		Stored Proc: usp_rep_ConsultantSelectAll							###########################
-- ############################################################################################################################
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shawkat Osman
-- Create date: 2017-06-08
-- Description:	A Common stored proc to list the Consultants- by Type- All, or either Endoscopist, List Consultant, Nurse or Traineee!!
-- =============================================
ALTER PROCEDURE usp_rep_ConsultantSelectByType
(
	@ConsultantType AS VARCHAR(20) = 'all'
)
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @Consultant VARCHAR(20) = LOWER(@ConsultantType);
    WITH AllConsultants AS(	-- This CTE will make the primary list - with Operators Only- Consultants and Nurses! On the later SELECT atatement- you can do further filer on Consulant OR Nurse!
	select -- ERS Consultants!
		  --convert(varchar(10), ERS.UserId) AS ConsultantId	--##  AS UGI has VARCHAR Data Type and ERS has INT Data type!
		  U.UserId
		, Forename + ' ' + Surname		AS Consultant		
		, U.JobTitleID					AS TitleId
		, IsNull(T.Description, '')		AS Consultant_Title
		, IsListConsultant
		, IIF( (IsNull(IsEndoscopist1,0)=1 OR IsNUll(IsEndoscopist2,0)=1), 1, 0)	AS IsEndoscopist
		, IsAssistantOrTrainee
		, IIF( (IsNull(IsNurse1,0)=1 OR IsNUll(IsNurse2,0)=1), 1, 0)	AS IsNurse
		--, IsListConsultant, IsEndoscopist1, IsEndoscopist2, IsAssistantOrTrainee, IsNurse1, IsNurse2, U.Active	-## This line is For Data Verification..; Shawkat Osman; 217-06-20
	FROM  dbo.ERS_Users AS U
		LEFT JOIN [dbo].[ERS_JobTitles] AS T ON U.JobTitleID = T.JobTitleID
		    WHERE U.IsImported  = 1
		      AND U.Active		= 1
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
			((@Consultant='endoscopist')	AND ( Con.IsEndoscopist = 1)
				OR 
			  ((@Consultant='trainee')		AND ( Con.IsAssistantOrTrainee = 1))
			  OR 
			  ((@Consultant='nurse')		AND ( Con.IsNurse = 1))
			  OR 			  
			  (@Consultant='all'			AND (1=1) 	-- Select All Endoscopist/Nurses
			))
			
	END 
GO

---####################################

-- #####################		End of Stored Proc: usp_rep_ConsultantSelectAll							###########################


--##################
USE [Stoke_Gastro_Live]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shawkat Osman
-- Create date: 2017-06-20
-- Description:	A Common stored proc to list the Tye of Consultants
-- =============================================
ALTER  PROCEDURE [dbo].[usp_rep_ConsultantTypes]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
			ListId
           ,[ListItemNo]
           ,[ListItemText] AS [Description]
	 FROM  [dbo].[ERS_Lists]
	WHERE  ListDescription = 'ConsultantType'
	  AND  Suppressed = 0;

END


--############################################
/*
	Report 1:  Diarrhoea Reports! GRSA01-  Diarrhoea Reports.sql

	Author		: Shawkat Osman
	Create date : 2017-06-08

	Description : This will get records from both UGI and ERS for all the Diarrhoea related entries!
				 UGI Records will only be included if the Flag in the Settings table is Set to TRUE!


*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[sp_rep_GRSA01]
AS
Begin
	SET NOCOUNT ON
	
	DECLARE @DateFrom AS DATETIME,
			@DateTO	  AS DATETIME;
	

	--## Report Filter values will be selected from the FrontEnd UI- values will be saved in the table.. and Now Load those selected values while populating the Data set!
		SELECT	
		@DateFrom= [FromDate], @DateTO=[ToDate] 
	From [dbo].[ERS_ReportFilter];

	DECLARE @ERS_Colonoscopy  AS INT = 3,
			@ERS_Sigmoidscopy AS INT = 4,
			@UGI_Colonoscopy  AS INT = 0,
			@UGI_Sigmoidscopy AS INT = 1,
			
			@Biopsy				AS VARCHAR(20) = '%biops%',
			@BrushCytology		AS VARCHAR(20) = '%Brush cytolog%';

	Select --##### ERS Data!
		  P.[Case note no]								As CaseNoteNo
		, cp.ProcedureType								AS [Type]
		, P.[Surname] + ', ' + P.[Forename]				As [PatientName]
		, CP.CreatedOn									As ProcedureDate		
		, (Con.Description + ', ' + JT.Description)		AS Consultant		 	
		, L.ListItemText								AS Indication
		, SUBSTRING(S.SiteSummarySpecimens, (CHARINDEX(':', S.SiteSummarySpecimens)+2), LEN(S.SiteSummarySpecimens)) AS SpecimenTaken
	From dbo.ERS_Procedures AS CP
		INNER JOIN ERS_UpperGIIndications AS GI ON CP.ProcedureId = GI.ProcedureId													
													AND ( (GI.[ColonAlterBowelHabit] IS NOT NULL) AND (GI.[ColonAlterBowelHabit]>0) ) ----## Zero means 'NOT Selected!' So- ignore it!
		INNER JOIN dbo.Patient			AS P	ON CP.PatientId				= P.[Patient No] -- OK
		LEFT JOIN [dbo].[ERS_Sites]		AS S	ON CP.ProcedureId			= S.ProcedureId AND (LOWER(CONVERT(VARCHAR(200),S.SiteSummarySpecimens)) LIKE @Biopsy 
																							 OR	 LOWER(CONVERT(VARCHAR(200),S.SiteSummarySpecimens)) LIKE @BrushCytology)
		INNER JOIN dbo.[ERS_Lists]		AS L    ON GI.ColonAlterBowelHabit  = L.ListItemNo AND L.ListDescription = 'Indications Colon Altered Bowel Habit' 
		INNER JOIN dbo.ERS_Users		AS Con  ON CP.Endoscopist1			= Con.UserID -- OK
		LEFT JOIN [dbo].[ERS_JobTitles] AS JT	ON Con.JobTitleID			= JT.JobTitleID

	where (CP.ProcedureType IN (@ERS_Colonoscopy, @ERS_Sigmoidscopy) )  --## Narrow down the search- filter records with these two types only!
			AND CP.CreatedOn BETWEEN @DateFrom AND @DateTO		--## Need this column to be INDEXED: dbo.[Colon Procedure].[Procedure date]	*******		

	UNION ALL

	Select  --##### UGI Data
		  P.[Case note no]			As CaseNoteNo
		  , CP.[Procedure type]		AS [Type]
		, P.[Surname] + ', ' + P.[Forename] As [PatientName]
		, E.[Episode date]			As ProcedureDate
		, Con.[Consultant/operator] AS Consultant
		, L.[List item text]		AS Indication
		--, CP.[Procedure type]		As PT
		, CONVERT(varchar(200),CP.TPP_SpecimenTaken)  AS SpecimenTaken -- ## [TPP_SpecimenTaken] is a [TEXT] Data Type!! Trouble Maker!!
	From dbo.Patient  AS P 
		INNER JOIN dbo.Episode				AS E	ON P.[Combo ID]				= E.[Patient No]
		INNER JOIN dbo.[Colon Procedure]	AS CP   ON ((E.[Episode No]			= CP.[Episode No])	AND (E.[Patient No]		 = CP.[Patient No]))		
		LEFT JOIN [dbo].[Colon Indications] AS CI   ON CI.[Episode No]			= CP.[Episode No]	AND CI.[Patient No]		 = CP.[Patient No]
		LEFT JOIN dbo.[Lists]				AS L	ON CI.[Altered bowel habit] = L.[List item no]	AND (L.[List description]= 'Bowel habit')
		LEFT JOIN  [Consultant/Operators]	AS Con  ON CP.Endoscopist2			= Con.[Consultant/operator ID]
	Where dbo.fnShouldIncludeUGI()=1
		AND CP.PP_Indic like '%diarrh%' 
		AND (LOWER(CONVERT(VARCHAR(200), CP.TPP_SpecimenTaken)) LIKE @Biopsy
				OR 
			 LOWER(CONVERT(VARCHAR(200),CP.TPP_SpecimenTaken)) LIKE @BrushCytology) -- Suggested by Marios//
		AND E.[Episode date] BETWEEN @DateFrom AND @DateTO
		AND CP.[Procedure type] IN (@UGI_Colonoscopy, @UGI_Sigmoidscopy);
	
END-- End of : CREATE Proc [dbo].[sp_rep_GRSA01] -----------------

--###################


GO
/*
	Report Name: GRSA02 - Haemostasis after Endoscopic therapy

*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[sp_rep_GRSA02_v2] 
	( 
	--@UserID		INT,
	  @Endoscopist1 AS INT = 1 --Default to Endoscopist 1
	, @Endoscopist2 AS INT = null
	, @OGD			AS INT = NULL
	, @COLSIG		AS INT = NULL
	, @EndoscopistIdList AS VARCHAR(2000)= ''
	, @DateFrom			DATETIME = '1990-01-01'
	, @DateTo			DATETIME = '2099-01-01'
)
As 
Begin
	SET NOCOUNT ON;
	Declare @Errors INT = 0;

	If @OGD Is NULL And @COLSIG Is Null
	Begin
		Raiserror('You must pass at least one of these parameters: @OGD or @COLSIG',11,1)
	End	

	Set @OGD	= IsNull(@OGD,0);
	Set @COLSIG = IsNull(@COLSIG,0);

	If @Errors>0
		Begin
			PRINT 'Sintax:'
			Print '	Exec sp_rep_GRSA02 @UserID=[UserID], @Endoscopist1=[TRUE/FALSE][1/0], @Endoscopist2=[TRUE/FALSE][1/0], @OGD=[TRUE/FALSE][1/0], @COLSIG=[TRUE/FALSE][1/0]'
			Print '	[UserID]: Session Value of PKUserId'
			--Set @UserID=0
			Set @Errors=@Errors+1
		End	
	Else -- if NO ERROR
		BEGIN /*	Local Variable Declraation	*/
			--DECLARE @AsEndoscopistType as int = (CASE @Endoscopist1 WHEN NULL THEN 2 ELSE 1 END); -- Read the Parameter Value.. If anything Passed for Endoscopist1 then - you know! Else you know as well!!

			DECLARE @SQL_Statment AS NVARCHAR(MAX);
			DECLARE @EndoscopistId AS NVARCHAR(100)='GIWTWU000030';
		END /*	End: Local Variable Declraation	*/

		BEGIN	/* Actual Optimizing Query will start work here!	*/
			--## UGI Data
		set @SQL_Statment='
			SELECT	
				  Patient.Surname
				, Patient.Forename
				, Patient.[Case note no]
				, Eps.[Episode date]
				, Eps.[Patient No]
				, Eps.[Episode No]
				, Eps.[Procedure catagory]
				, Eps.[Procedure ID]
				, Eps.[Age at procedure]
				, Pro.Endoscopist1
				--, Con.[Consultant/operator] ''Endoscopist1''
				, Pro.Endoscopist2
				, Pro.Assistant1
				/*-- ''## For [Haematemesis] check in [Other Indication] for the presence of the word ''MELAENA'' or ''HAEMATEMESIS''. If the field already flagged to ''-1''- then don''t check... */
				, (CASE Ind.Melaena WHEN 0 THEN  (CASE WHEN LOWER(Ind.[Other indication]) LIKE ''%mel__na%'' THEN  ''Yes'' ELSE NULL END  )
												ELSE ''Yes'' END ) AS Haematemesis_Text
				, Ind.Melaena 
				-- ## is melaena or haematemesis recorded under other indications											
				, (CASE Ind.Haematemesis		WHEN 0 THEN (CASE WHEN LOWER(Ind.[Other indication]) LIKE ''%haematemesis%'' THEN  ''Yes'' ELSE NULL END  )													
												ELSE ''Yes'' END ) AS Melaena_Text
				, (SELECT ( 
							CASE WHEN L.[List item text] LIKE ''%mel__na%'' then ''Yes''
								 WHEN L.[List item text] LIKE ''%haematemesis%'' then ''Yes'' ELSE  NULL END)
						FROM Lists L 
							WHERE L.[List description]=''Bowel habit'' AND L.[List item no]=CI.[Altered bowel habit]
										  ) AS CI_ABH_Mel_Haem --- check whether it has ''Melaena'' or ''Malaena'' or ''haematemesis'' is recorded in the ABH Link To=> [List item text]-- in "Bowel habit" Category!
				, CI.[Altered bowel habit]	AS CI_ABH_Mel_Haem_Id 
				, (CASE WHEN CI.[Other Indication] LIKE ''%mel__na%'' then ''Yes''
						WHEN CI.[Other Indication] LIKE ''%haematemesis%'' then ''Yes'' ELSE NULL END
										 )	AS CI_OtherInd	-- is melaena or haematemesis recorded under [other indications]
				, List.[List item text]		AS ''RectalBleeding'' -- is melaena or haematemesis recorded under rectal bleeding? Its already ''LEFT JOINED''
				-- From Access-> UGI: Rs("Cancer") = Choose(Sn("Cancer"), "definite cancer", "suspected cancer", "cancer exclusion")
				, CHOOSE( Ind.Cancer, ''definite cancer'', ''suspected cancer'', ''cancer exclusion'') AS CancerText
				, GI_Therap.[Leading to haemostasis] AS OGD_Therap_LeadingToHaem
				, CO_Therap.[Leading to haemostasis] AS COL_Therap_LeadingToHaem
				, Pro.TPP_Therapies					AS ''TherapeuticProcedures'' 
			FROM Patient 
	  INNER JOIN Episode				AS Eps ON Patient.[Combo ID] = Eps.[Patient No]
	  INNER JOIN [Upper GI Procedure]	AS Pro ON (Eps.[Episode No] = Pro.[Episode No]) AND (Eps.[Patient No] = Pro.[Patient No])
	  INNER JOIN [Upper GI Indications] AS Ind ON (Pro.[Episode No] = Ind.[Episode No]) AND (Pro.[Patient No] = Ind.[Patient No]) 
	   LEFT JOIN [Colon Indications]	AS CI  ON Eps.[Episode No] = CI.[Episode No]	AND Eps.[Patient No]  = CI.[Patient No]
--	   LEFT JOIN [Consultant/Operators] AS Con ON (Pro.[Endoscopist1] = Con.[Consultant/operator ID])
	   --LEFT JOIN [Consultant/Operators] AS Con ON (Pro.[Endoscopist2] = Con.[Consultant/operator ID])
	   --LEFT JOIN [Consultant/Operators] AS Con ON (Pro.[{REPLACE_ENDOSCOPIST_TYPE}] = Con.[Consultant/operator ID])
	   LEFT JOIN [Upper GI Therapeutic] AS GI_Therap ON (Eps.[Patient No] = GI_Therap.[Patient No] AND Eps.[Episode No]=GI_Therap.[Episode No] AND @OGD = 1)	-- To read- ONLY If @OGD was requested for! -''Leading to Haemostasis'' value!
	   LEFT JOIN [Colon Therapeutic]	AS CO_Therap ON (Eps.[Patient No] = CO_Therap.[Patient No] AND Eps.[Episode No]=CO_Therap.[Episode No] AND @COLSIG = 1)	-- To read- ONLY If @COLSIG was requested for!
	   LEFT JOIN [dbo].[Lists]			AS List ON CI.[Rectal bleeding] = List.[List item no] AND List.[List description] = ''Rectal bleeding''	-- 	   
		   WHERE  (Eps.[Episode date] BETWEEN @DateFrom AND @DateTo) 
			 AND (substring(Eps.[Status], 1, 1)=''1'' AND [Combined procedure]=0) 
--			 AND (Pro.Endoscopist1 IS NOT NULL AND Pro.Endoscopist1<>''GIWTWU000000'')	-- Ignore any ''(none)'' or NULL rows!
			 --AND ([REPLACE_ENDOSCOPIST_FILTER]) --## Make it enabled again...
		   ;
		   '

		IF(@Endoscopist1+@Endoscopist2 = 2) -- IF Both Params are passed- then select all Endoscopis
			SET @SQL_Statment = REPLACE(@SQL_Statment, '[REPLACE_ENDOSCOPIST_FILTER]' ,'Pro.Endoscopist1 IN (select Item from dbo.fnSplitString(@EndoscopistIdList, '','')) OR Pro.Endoscopist2 IN (select Item from dbo.fnSplitString(EndoscopistIdList, '',''))');
		ELSE IF @Endoscopist1 = 1
			SET @SQL_Statment = REPLACE(@SQL_Statment, '[REPLACE_ENDOSCOPIST_FILTER]', 'Pro.Endoscopist1 IN (select Item from dbo.fnSplitString(@EndoscopistIdList, '',''))');
		ELSE IF @Endoscopist2 = 1
			SET @SQL_Statment = REPLACE(@SQL_Statment, '[REPLACE_ENDOSCOPIST_FILTER]', 'Pro.Endoscopist2 IN (select Item from dbo.fnSplitString(@EndoscopistIdList, '',''))');


		--print @SQL_Statment; return;
		EXEC sp_executesql @SQL_Statment, N'@EndoscopistIdList VARCHAR(2000), @OGD INT, @COLSIG INT, @DateFrom	DATETIME, @DateTo			DATETIME', @EndoscopistIdList, @OGD, @COLSIG, @DateFrom, @DateTo

		END
		
		
	End /* End: Actual Optimizing Query will start work here!	*/







--## Select * from [dbo].[ERS_ReportFilter]




--######## End of Reports ###########################




/*
	View objects!
	Just use them now.. We will change all these views to Stored Proc.. then we will remove [View] objects
*/

/* ############# View 1: [fw_Consultants] */

	SET ANSI_NULLS ON;
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[fw_Consultants]
	AS
	SELECT        'U.' + CONVERT(varchar(10), CONVERT(int, SubString([Consultant/operator ID], 7, 6))) AS ConsultantId, [Consultant/operator] AS [ConsultantName], CONVERT(bit, 
							 CASE IsNull(UGI.[Suppress], 0) WHEN - 1 THEN 1 ELSE 0 END) AS [Active], CONVERT(bit, CASE UGI.[IsListConsultant] WHEN - 1 THEN 'TRUE' ELSE 'FALSE' END) 
							 AS [IsListConsultant], CONVERT(bit, CASE UGI.[IsEndoscopist1] WHEN - 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsEndoscopist1], CONVERT(bit, 
							 CASE UGI.[IsEndoscopist2] WHEN - 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsEndoscopist2], CONVERT(bit, 
							 CASE UGI.[IsAssistantTrainee] WHEN - 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsAssistantOrTrainee], CONVERT(bit, 
							 CASE UGI.[IsNurse1] WHEN - 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsNurse1], CONVERT(bit, CASE UGI.[IsNurse2] WHEN - 1 THEN 'TRUE' ELSE 'FALSE' END) 
							 AS [IsNurse2]
	FROM            [Consultant/Operators] UGI
	WHERE        CONVERT(int, SubString([Consultant/operator ID], 7, 6)) <> 0
	UNION ALL
	SELECT        'E.' + CONVERT(varchar(10), UserID) AS ConsultantId, ERS.[Title] + ' ' + ERS.[Forename] + ' ' + ERS.[Surname] AS [Consultant], CONVERT(bit, 
							 CASE IsNull(ERS.[Active], 0) WHEN 1 THEN 1 ELSE 0 END) AS [Active], CONVERT(bit, CASE ERS.[IsListConsultant] WHEN 1 THEN 'TRUE' ELSE 'FALSE' END) 
							 AS [IsListConsultant], CONVERT(bit, CASE ERS.[IsEndoscopist1] WHEN 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsEndoscopist1], CONVERT(bit, 
							 CASE ERS.[IsEndoscopist2] WHEN 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsEndoscopist2], CONVERT(bit, 
							 CASE ERS.[IsAssistantOrTrainee] WHEN 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsAssistantOrTrainee], CONVERT(bit, 
							 CASE ERS.[IsNurse1] WHEN 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsNurse1], CONVERT(bit, CASE ERS.[IsNurse2] WHEN 1 THEN 'TRUE' ELSE 'FALSE' END) 
							 AS [IsNurse2]
	FROM            [dbo].[ERS_Users] ERS
	go


--############# End of View 1: 


--############# View 2: [fw_ConsultantTypes]
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
		CREATE VIEW [dbo].[fw_ConsultantTypes]
		AS
		SELECT        ConsultantTypeId = 1, ConsultantType = 'Endoscopist 1'
		UNION
		SELECT        ConsultantTypeId = 2, ConsultantType = 'Endoscopist 2'
		UNION
		SELECT        ConsultantTypeId = 3, ConsultantType = 'Assistant'
		UNION
		SELECT        ConsultantTypeId = 4, ConsultantType = 'List Consultant'
		UNION
		SELECT        ConsultantTypeId = 5, ConsultantType = 'Nurse 1'
		UNION
		SELECT        ConsultantTypeId = 6, ConsultantType = 'Nurse 2'
		UNION
		SELECT        ConsultantTypeId = 7, ConsultantType = 'Nurse 3'
	GO

--############# End of View 3: 


--############# View 3: [fw_Patients]

	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[fw_Patients]
	AS
	SELECT        [Patient No] AS PatientId, [Case note no] AS CNN, ISNULL(Title, '') + (CASE WHEN P.Title IS NULL THEN '' ELSE ' ' END) + ISNULL(Forename, '') 
							 + (CASE WHEN P.Forename IS NULL THEN '' ELSE ' ' END) + ISNULL(Surname, '') AS PatientName, ISNULL(Forename, '') AS Forename, ISNULL(Surname, '') 
							 AS Surname, CONVERT(DateTime, [Date of birth]) AS DOB, [Date of death] AS DOD, [NHS No] AS NHSNo, ISNULL(Gender, '?') AS Gender, ISNULL([Post code], '') 
							 AS PostCode, [GP Name] AS GPName, [Phone No] AS PhoneNo
	FROM            dbo.Patient AS P

	GO

--############# End of View 3: 



--############# View 4: 

	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[fw_Procedures]
	AS
	SELECT        'U.1.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 1 AS ProcedureTypeId, 
							 'U' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, 
							 IsNull(PR.[Operating Hospital ID], 0) AS OperatingHospitalId, IsNull(PP_Priority, 'Unspecified') AS PP_Priority, 
							 CASE PP_PatStatus WHEN 'Outpatient/NHS' THEN 2 WHEN 'Inpatient/NHS' THEN 1 ELSE 0 END AS PatientStatusId, 
							 CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''), 'Outpatient/', ''), 'Inpatient/', '') = 'NHS' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
							 PR.DNA
	FROM            [Episode] E LEFT OUTER JOIN
							 [Upper GI Procedure] PR ON E.[Episode No] = PR.[Episode No] AND E.[Patient No] = PR.[Patient No]
	WHERE        SubString(E.[Status], 1, 1) = 1
	UNION ALL
	SELECT        'U.2.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ProcedureTypeId, 
							 'U' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, 
							 IsNull(PR.[Operating Hospital ID], 0) AS OperatingHospitalId, IsNull(PP_Priority, 'Unspecified') AS PP_Priority, 
							 CASE PP_PatStatus WHEN 'Outpatient/NHS' THEN 2 WHEN 'Inpatient/NHS' THEN 1 ELSE 0 END AS PatientStatusId, 
							 CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''), 'Outpatient/', ''), 'Inpatient/', '') = 'NHS' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
							 PR.DNA
	FROM            [Episode] E LEFT OUTER JOIN
							 [ERCP Procedure] PR ON E.[Episode No] = PR.[Episode No] AND E.[Patient No] = PR.[Patient No]
	WHERE        SubString(E.[Status], 2, 1) = 1
	UNION ALL
	SELECT        'U.' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + '.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0) AS ProcedureTypeId, 'U' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, 
							 CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, IsNull(PR.[Operating Hospital ID], 0) AS OperatingHospitalId, 
							 IsNull(PP_Priority, 'Unspecified') AS PP_Priority, CASE PP_PatStatus WHEN 'Outpatient/NHS' THEN 2 WHEN 'Inpatient/NHS' THEN 1 ELSE 0 END AS PatientStatusId, 
							 CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''), 'Outpatient/', ''), 'Inpatient/', '') = 'NHS' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
							 PR.DNA
	FROM            [Episode] E LEFT OUTER JOIN
							 [Colon Procedure] PR ON E.[Episode No] = PR.[Episode No] AND E.[Patient No] = PR.[Patient No]
	WHERE        SubString(E.[Status], 3, 1) = 1
	UNION ALL
	SELECT        'U.5.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ProcedureTypeId, 
							 'U' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, 
							 IsNull(PR.[Operating Hospital ID], 0) AS OperatingHospitalId, IsNull(PP_Priority, 'Unspecified') AS PP_Priority, 
							 CASE PP_PatStatus WHEN 'Outpatient/NHS' THEN 2 WHEN 'Inpatient/NHS' THEN 1 ELSE 0 END AS PatientStatusId, 
							 CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''), 'Outpatient/', ''), 'Inpatient/', '') = 'NHS' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
							 PR.DNA
	FROM            [Episode] E LEFT OUTER JOIN
							 [Colon Procedure] PR ON E.[Episode No] = PR.[Episode No] AND E.[Patient No] = PR.[Patient No]
	WHERE        SubString(E.[Status], 4, 1) = 1
	UNION ALL
	SELECT        'U.6.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ProcedureTypeId, 
							 'U' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, 
							 IsNull(PR.[Operating Hospital ID], 0) AS OperatingHospitalId, IsNull(PP_Priority, 'Unspecified') AS PP_Priority, 
							 CASE PP_PatStatus WHEN 'Outpatient/NHS' THEN 2 WHEN 'Inpatient/NHS' THEN 1 ELSE 0 END AS PatientStatusId, 
							 CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''), 'Outpatient/', ''), 'Inpatient/', '') = 'NHS' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
							 PR.DNA
	FROM            [Episode] E LEFT OUTER JOIN
							 [Upper GI Procedure] PR ON E.[Episode No] = PR.[Episode No] AND E.[Patient No] = PR.[Patient No]
	WHERE        SubString(E.[Status], 5, 1) = 1
	UNION ALL
	SELECT        'U.7.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 7 AS ProcedureTypeId, 
							 'U' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, 
							 IsNull(PR.[Operating Hospital ID], 0) AS OperatingHospitalId, IsNull(PP_Priority, 'Unspecified') AS PP_Priority, 
							 CASE PP_PatStatus WHEN 'Outpatient/NHS' THEN 2 WHEN 'Inpatient/NHS' THEN 1 ELSE 0 END AS PatientStatusId, 
							 CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''), 'Outpatient/', ''), 'Inpatient/', '') = 'NHS' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
							 PR.DNA
	FROM            [Episode] E LEFT OUTER JOIN
							 [ERCP Procedure] PR ON E.[Episode No] = PR.[Episode No] AND E.[Patient No] = PR.[Patient No]
	WHERE        SubString(E.[Status], 6, 1) = 1
	UNION ALL
	SELECT        'U.0.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 0 AS ProcedureTypeId, 
							 'U' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, 
							 0 AS OperatingHospitalId, 'Unspecified' AS PP_Priority, 0 AS PatientStatusId, 0 AS PatientTypeId, NULL AS PP_Indic, NULL AS PP_Therapies, NULL AS DNA
	FROM            [Episode] E
	WHERE        Len(Replace(SUBSTRING([Status], 1, 10), '0', '')) = 0
	UNION ALL
	SELECT        'E.' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, PR.ProcedureType AS ProcedureTypeId, 'E' AS AppId, CONVERT(Date, CreatedOn) AS CreatedOn, 
							 PR.PatientId AS PatientId, CONVERT(int, PR.CreatedOn - E.[Date of birth]) / 365 AS Age, IsNull(PR.OperatingHospitalID, 0) AS OperatingHospitalId, IsNull(PP_Priority, 
							 'Unspecified') AS PP_Priority, CASE PP_PatStatus WHEN 'Outpatient/NHS' THEN 2 WHEN 'Inpatient/NHS' THEN 1 ELSE 0 END AS PatientStatusId, 
							 CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''), 'Outpatient/', ''), 'Inpatient/', '') = 'NHS' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
							 PR.DNA
	FROM            ERS_Procedures PR, Patient E
	WHERE        PR.PatientId = E.[Patient No]

	GO

--############# End of View 4: 




--############# View 5: [fw_ProceduresConsultants]

	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[fw_ProceduresConsultants]
	AS
	/*OGD*/ SELECT 'U.1.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 
							 1 AS ConsultantTypeId, 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(UP.Endoscopist2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Upper GI Procedure] UP
	WHERE        SubString(E.[Status], 1, 1) = 1 AND E.[Episode No] = Up.[Episode No]
	UNION ALL
	SELECT        'U.1.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(UP.Endoscopist1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Upper GI Procedure] UP
	WHERE        SubString(E.[Status], 1, 1) = 1 AND E.[Episode No] = Up.[Episode No]
	UNION ALL
	SELECT        'U.1.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(UP.Assistant1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Upper GI Procedure] UP
	WHERE        SubString(E.[Status], 1, 1) = 1 AND E.[Episode No] = Up.[Episode No]
	UNION ALL
	SELECT        'U.1.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 4 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(UP.Assistant2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Upper GI Procedure] UP
	WHERE        SubString(E.[Status], 1, 1) = 1 AND E.[Episode No] = Up.[Episode No]
	UNION ALL
	SELECT        'U.1.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(UP.Nurse1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Upper GI Procedure] UP
	WHERE        SubString(E.[Status], 1, 1) = 1 AND E.[Episode No] = Up.[Episode No]
	UNION ALL
	SELECT        'U.1.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(UP.Nurse2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Upper GI Procedure] UP
	WHERE        SubString(E.[Status], 1, 1) = 1 AND E.[Episode No] = Up.[Episode No]
	/*ERCP*/ UNION ALL
	SELECT        'U.2.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 1 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(EP.Endoscopist2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [ERCP Procedure] EP
	WHERE        SubString(E.[Status], 2, 1) = 1 AND EP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.2.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(EP.Endoscopist1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [ERCP Procedure] EP
	WHERE        SubString(E.[Status], 2, 1) = 1 AND EP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.2.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(EP.Assistant1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [ERCP Procedure] EP
	WHERE        SubString(E.[Status], 2, 1) = 1 AND EP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.2.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 4 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(EP.Assistant2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [ERCP Procedure] EP
	WHERE        SubString(E.[Status], 2, 1) = 1 AND EP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.2.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(EP.Nurse1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [ERCP Procedure] EP
	WHERE        SubString(E.[Status], 2, 1) = 1 AND EP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.2.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(EP.Nurse2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [ERCP Procedure] EP
	WHERE        SubString(E.[Status], 2, 1) = 1 AND EP.[Episode No] = E.[Episode No]
	/*COL & SIG*/ UNION ALL
	SELECT        'U.' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + '.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 1 AS ConsultantTypeId, 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist2, 7, 6))) 
							 AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 3, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + '.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ConsultantTypeId, 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist1, 7, 6))) 
							 AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 3, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + '.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 AS ConsultantTypeId, 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant1, 7, 6))) 
							 AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 3, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + '.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 4 AS ConsultantTypeId, 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant2, 7, 6))) 
							 AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 3, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + '.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ConsultantTypeId, 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse1, 7, 6))) 
							 AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 3, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + '.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ConsultantTypeId, 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse2, 7, 6))) 
							 AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 3, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	/*PRO*/ UNION ALL
	SELECT        'U.5.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 1 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        'U.5.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        'U.5.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        'U.5.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 4 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        'U.5.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        'U.5.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	/*EUS OGD*/ UNION ALL
	SELECT        'U.6.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 1 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        'U.6.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        'U.6.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        'U.6.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 4 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        'U.6.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        'U.6.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	/*EUS HPB*/ UNION ALL
	SELECT        'U.7.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 1 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 6, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.7.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 6, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.7.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 6, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.7.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 4 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 6, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.7.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 6, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'U.7.' + CONVERT(varchar(10), E.[Episode no]) + '.' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ConsultantTypeId, 
							 'U.' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 6, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        'E.' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 1 AS ConsultantTypeId, 'E.' + CONVERT(varchar(10), PR.Endoscopist1) AS ConsultantId
	FROM            ERS_Procedures PR, Patient E
	WHERE        PR.PatientId = E.[Patient No] AND PR.Endoscopist1 IS NOT NULL
	UNION ALL
	SELECT        'E.' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 2 AS ConsultantTypeId, 'E.' + CONVERT(varchar(10), PR.Endoscopist2) AS ConsultantId
	FROM            ERS_Procedures PR, Patient E
	WHERE        PR.PatientId = E.[Patient No] AND PR.Endoscopist2 IS NOT NULL
	UNION ALL
	SELECT        'E.' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 3 AS ConsultantTypeId, 'E.' + CONVERT(varchar(10), PR.Assistant) AS ConsultantId
	FROM            ERS_Procedures PR, Patient E
	WHERE        PR.PatientId = E.[Patient No] AND PR.Assistant IS NOT NULL
	UNION ALL
	SELECT        'E.' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 4 AS ConsultantTypeId, 'E.' + CONVERT(varchar(10), PR.ListConsultant) AS ConsultantId
	FROM            ERS_Procedures PR, Patient E
	WHERE        PR.PatientId = E.[Patient No] AND PR.ListConsultant IS NOT NULL
	UNION ALL
	SELECT        'E.' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 5 AS ConsultantTypeId, 'E.' + CONVERT(varchar(10), PR.Nurse2) AS ConsultantId
	FROM            ERS_Procedures PR, Patient E
	WHERE        PR.PatientId = E.[Patient No] AND PR.Nurse2 IS NOT NULL
	UNION ALL
	SELECT        'E.' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 6 AS ConsultantTypeId, 'E.' + CONVERT(varchar(10), PR.Nurse2) AS ConsultantId
	FROM            ERS_Procedures PR, Patient E
	WHERE        PR.PatientId = E.[Patient No] AND PR.Nurse2 IS NOT NULL
	UNION ALL
	SELECT        'E.' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 7 AS ConsultantTypeId, 'E.' + CONVERT(varchar(10), PR.Nurse3) AS ConsultantId
	FROM            ERS_Procedures PR, Patient E
	WHERE        PR.PatientId = E.[Patient No] AND PR.Nurse3 IS NOT NULL

	GO
--############# End of View 5: 



--############# View 6: [fw_ProceduresTypes]
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[fw_ProceduresTypes]
	AS
	SELECT        ProcedureTypeId, ProcedureType
	FROM            ERS_ProcedureTypes
	UNION
	SELECT        ProcedureTypeId = 0, ProcedureType = 'Unknow'

	GO

--############# End of View 6: 




--############# View 7: [fw_ReportConsultants]

	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[fw_ReportConsultants]
	AS
	SELECT        UserID, CASE WHEN ConsultantID > 100000 THEN 'U.' + CONVERT(Varchar(10), ConsultantID - 1000000) ELSE 'E.' + CONVERT(Varchar(10), ConsultantID) 
							 END AS ConsultantId, AnonimizedID
	FROM            dbo.ERS_ReportConsultants

	GO
--############# End of View 7 



--############# View 8: [fw_ReportFilter]
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[fw_ReportFilter]
	AS
	SELECT        UserID, ReportDate, FromDate, ToDate, Anonymise, TypesOfEndoscopists, HideSuppressed
	FROM            dbo.ERS_ReportFilter

	GO

--############# End of View 8



--############# View 9: [v_rep_Consultants]

	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[v_rep_Consultants]
	AS
	SELECT        1000000 + CONVERT(int, SubString([Consultant/operator ID], 7, 6)) AS ReportID, CONVERT(int, SubString([Consultant/operator ID], 7, 6)) AS ConsultantID, UGIID = CONVERT(int, SubString([Consultant/operator ID], 7, 
							 6)), ERSID = - 1, [Consultant/operator] AS [Consultant], CONVERT(bit, CASE IsNull(UGI.[Suppress], 0) WHEN - 1 THEN 1 ELSE 0 END) AS [Active], CONVERT(bit, 
							 CASE UGI.[IsListConsultant] WHEN - 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsListConsultant], CONVERT(bit, CASE UGI.[IsEndoscopist1] WHEN - 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsEndoscopist1], 
							 CONVERT(bit, CASE UGI.[IsEndoscopist2] WHEN - 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsEndoscopist2], CONVERT(bit, CASE UGI.[IsAssistantTrainee] WHEN - 1 THEN 'TRUE' ELSE 'FALSE' END) 
							 AS [IsAssistantOrTrainee], CONVERT(bit, CASE UGI.[IsNurse1] WHEN - 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsNurse1], CONVERT(bit, CASE UGI.[IsNurse2] WHEN - 1 THEN 'TRUE' ELSE 'FALSE' END) 
							 AS [IsNurse2], 'UGI' AS Release
	FROM            [Consultant/Operators] UGI
	WHERE        CONVERT(int, SubString([Consultant/operator ID], 7, 6)) <> 0
	UNION
	SELECT        UserID AS ReportID, UserID AS ConsultantID, UGIID = - 1, ERSID = UserID, [Title] + ' ' + [Forename] + ' ' + ERS.[Surname] AS [Consultant], CONVERT(bit, CASE IsNull(ERS.[Active], 0) WHEN 1 THEN 1 ELSE 0 END) 
							 AS [Active], CONVERT(bit, CASE ERS.[IsListConsultant] WHEN 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsListConsultant], CONVERT(bit, CASE ERS.[IsEndoscopist1] WHEN 1 THEN 'TRUE' ELSE 'FALSE' END) 
							 AS [IsEndoscopist1], CONVERT(bit, CASE ERS.[IsEndoscopist2] WHEN 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsEndoscopist2], CONVERT(bit, 
							 CASE ERS.[IsAssistantOrTrainee] WHEN 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsAssistantOrTrainee], CONVERT(bit, CASE ERS.[IsNurse1] WHEN 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsNurse1], CONVERT(bit, 
							 CASE ERS.[IsNurse2] WHEN 1 THEN 'TRUE' ELSE 'FALSE' END) AS [IsNurse2], 'ERS' AS Release
	FROM            [dbo].[ERS_Users] ERS
	WHERE        Username NOT IN
								 (SELECT        Surname
								   FROM            [Consultant/Operators])


	GO
--############# End of View 9: 


--############# View 10: 


--############# End of View 10 



--############# View 11


--############# End of View 11

--############################ End of View Object Scripts #################