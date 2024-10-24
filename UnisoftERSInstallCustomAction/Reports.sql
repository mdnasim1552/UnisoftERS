Set NOCOUNT ON
GO

DECLARE @IncludeUGI BIT = 0

IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'Episode')) SET @IncludeUGI = 1

CREATE TABLE #variables (IncludeUGI BIT)
INSERT INTO #variables (IncludeUGI) 
	VALUES (@IncludeUGI)
GO

--------------------------------------------------------------------------------------------------------------------
-------------------------------------125 Create Table ERS_Reports.sql-------------------------------------
--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET NOCOUNT ON

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'ERS_Reports') AND type IN (N'U')) 
	EXEC DropIfExist 'ERS_ReportBoston1', 'T';
GO

EXEC DropIfExist 'ERS_Reports', 'T';
GO	

CREATE TABLE [dbo].[ERS_Reports](
	[ReportId] [SMALLINT] NOT NULL,
	[ReportName] [NVARCHAR] (200) NOT NULL,
	[Category] [NVARCHAR] (200) NOT NULL,
	[OrderBy] [SMALLINT] NOT NULL
) ON [PRIMARY]

GO
INSERT INTO [ERS_Reports] SELECT 1,'GRS B Repeat OGD', 'GRS', 1
GO

--================= Table: ERS_ReportFilter ===================================
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'ERS_ReportFilter') AND type IN (N'U')) 
BEGIN
	EXEC DropIfExist 'ERS_ReportBoston1', 'T';
	EXEC DropIfExist 'ERS_ReportBoston2', 'T';
	EXEC DropIfExist 'ERS_ReportBoston3', 'T';
END
GO
EXEC DropIfExist 'ERS_ReportFilter', 'T';	
GO	
CREATE TABLE [dbo].[ERS_ReportFilter](
	[UserID] [int] NOT NULL,
	[ReportDate] [datetime] NOT NULL CONSTRAINT [DF_ERS_ReportFilter_ReportDate] DEFAULT (getdate()),
	[FromDate] [date] NULL CONSTRAINT [DF_ERS_ReportFilter_FromDate] DEFAULT (CONVERT([date],getdate()-(365))),
	[ToDate] [date] NULL	CONSTRAINT [DF_ERS_ReportFilter_ToDate] DEFAULT (CONVERT([date],getdate())),
	[TypesOfEndoscopists] [int] NOT NULL CONSTRAINT [DF_ERS_ReportFilter_TypesOfEndoscopists] DEFAULT 1,
	[HideSuppressed] [bit] NULL CONSTRAINT [DF_ERS_ReportFilter_HideSuppressed] DEFAULT 1,
	[OGD] [bit] NULL			CONSTRAINT [DF_ERS_ReportFilter_OGD] DEFAULT 1,
	[Sigmoidoscopy] [bit] NULL	CONSTRAINT [DF_ERS_ReportFilter_Sigmoidoscopy] DEFAULT 1,
	[PEGPEJ] [bit] NULL			CONSTRAINT [DF_ERS_ReportFilter_PEGPEJ] DEFAULT 1,
	[Colonoscopy] [bit] NULL	CONSTRAINT [DF_ERS_ReportFilter_Colonoscopy] DEFAULT 1,
	[ERCP] [bit] NOT NULL		CONSTRAINT [DF_ERS_ReportFilter_ERCP] DEFAULT 1,
	[Bowel] [bit] NOT NULL		CONSTRAINT [DF_ERS_ReportFilter_Bowel] DEFAULT 1,
	[BowelStandard] [bit] NOT NULL CONSTRAINT [DF_ERS_ReportFilter_BowelStandard] DEFAULT 1,
	[BowelBoston] [bit] NOT NULL CONSTRAINT [DF_ERS_ReportFilter_BowelBoston] DEFAULT 0,
	[Anonymise] [bit] NOT NULL CONSTRAINT [DF_ERS_ReportFilter_Anonymise] DEFAULT 0,
	[UGI_Consultant_List] [varchar](1000) NULL,
	[ERS_Consultant_List] [varchar](1000) NULL,
 CONSTRAINT [ERS_ReportFilter.PK.UserID] PRIMARY KEY CLUSTERED 
(	[UserID] ASC) ON [PRIMARY]
) ON [PRIMARY]

GO


--================= Table: ERS_ReportConsultants ===================================
EXEC DropConstraint 'dbo.ERS_ReportConsultants', 'ERS_ReportConsultants.FK.UserID';
GO
EXEC dbo.DropIfExist 'ERS_ReportConsultants', 'T';
GO
CREATE TABLE [dbo].[ERS_ReportConsultants](
	[UserID] [int] NOT NULL,
	[ConsultantID] [int] NOT NULL,
	[AnonimizedID] [int] NOT NULL CONSTRAINT [ERS_ReportConsultants_AnonimizedID] DEFAULT 0,
 CONSTRAINT [ERS_ReportConsultants.PK.UserID_ConsultantID] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC,
	[ConsultantID] ASC
)) ON [PRIMARY]

GO
/*
ALTER TABLE [dbo].[ERS_ReportConsultants]  WITH CHECK ADD  CONSTRAINT [ERS_ReportConsultants.FK.UserID] FOREIGN KEY([UserID])REFERENCES [dbo].[ERS_ReportFilter] ([UserID])
ON DELETE CASCADE

GO
ALTER TABLE [dbo].[ERS_ReportConsultants] CHECK CONSTRAINT [ERS_ReportConsultants.FK.UserID]
GO
*/

--################## Function: fnGetTherapTypeSuccess; Scalar Function
EXEC DropIfExist 'fnNED_GetTherapTypeSuccess','F';
GO 
CREATE FUNCTION [dbo].[fnNED_GetTherapTypeSuccess]
(
	@ProcType		AS INT,
	@SiteId			AS INT,
	@EndRole		AS INT,
	@TherapName		AS VARCHAR(20)='' --## 'Stent placement' / BiCap / Injection / Marking / Clip
)
-- =============================================
-- Description:	This will try to work out the Success status of various Therapeutic Processes!
--					Most of the Theraps will be One Perform = One Success. 
--					Exception for Stent insertion. Success count will be the number of Performed or Inserted!
-- =============================================
RETURNS INT
AS
BEGIN	
	DECLARE @ResultVar INT;
	
	SELECT @ResultVar =
			(case @ProcType 
					WHEN 1 THEN							--## OGD / Gastroscopy; Only to check for Polypectomy/PEG Placement!
						(
						--## Check for PEG Placement | Gastrostomy Insertion (PEG)
						CASE WHEN LOWER(@TherapName)='peg placement'
							THEN
							(CASE 
								WHEN (UGI.StentInsertion=1 AND UGI.StentPlacementFailureReason IS NOT NULL) THEN 0	--## UT.CorrectStentPlacement Is Always Zero or False.. Bad to use as a Filer Criteria
								WHEN (UGI.GastrostomyInsertion=1 AND IsNull(UGI.CorrectPEGPlacement,0) = 0) THEN 0 
								ELSE 1 
							END)
						WHEN LOWER(@TherapName)='polypectomy' 
							THEN (
								SELECT SUM( (IsNull(SessileQty, 0) + IsNull(PedunculatedQty, 0) + IsNull(SubmucosalQty, 0)) )
									FROM dbo.ERS_UpperGIAbnoPolyps AS AB
									INNER JOIN dbo.ERS_Sites AS S ON AB.SiteId = S.SiteId
									INNER JOIN dbo.ERS_Procedures AS P ON S.ProcedureId = P.ProcedureId AND P.ProcedureId = (SELECT ProcedureId FROM dbo.ERS_Sites WHERE SiteId= @SiteId)
							)
						WHEN LOWER(@TherapName)='clip placement'	THEN (IsNull(UGI.ClipNum, 1))
						WHEN LOWER(@TherapName)='stent change'		THEN (IsNull(UGI.StentInsertionQty, 1))
						WHEN LOWER(@TherapName)='band ligation'		THEN ( CASE WHEN (IsNull(UGI.BandLigation, 0)=1 AND IsNull(UGI.VaricealBanding, 0)=1) THEN 2 ELSE 1 END ) -- '20/01/2017 - 'VaricealBanding' Now mapped to 'BandLigation'; So- COUNT() them if both Exist!
						ELSE 1  END --## Straight 1 'Success'; All exceptions handled already!
						)
					WHEN 2 THEN							--## ERCP
						(
							--## WHEN 'Stricture' was Selected in the Duct - then Was 'CorrectStentPlacement' Successful?
							CASE WHEN LOWER(@TherapName)='balloon trawl' 
									AND (Abn.Stricture=1 AND IsNull(ER.CorrectStentPlacement,0) = 0) THEN 0	
							
							--## Value 4 Referes to: 'unsuccessful due to' from 'Visualization'
							WHEN LOWER(@TherapName)='cannulation' 
									AND (V.MajorPapillaBile=4 OR V.MajorPapillaPancreatic=4 OR V.MinorPapilla=4) THEN 0 

							--## When 'Obstructed' Option(s) are selected in 'Indication'- then check the value in ERCP whether 'StentDecompressedDuct' is 1. If not - Means FAIL!
							WHEN LOWER(@TherapName) like 'stent placement%' 
									AND ( (Ind.ERSObstructed=1 OR Ind.ERSObstructedCBD=1) 
											AND 
										(StentDecompressedDuct  = 0 or SphincterDecompressed = 0 OR	
										StoneDecompressed		= 0 or StrictureDecompressed = 0 OR BalloonDecompressed = 0)) THEN 0 
							
							--## if No Obstruction found in the 'Indication' then All 'Stent Insertion' are counted as 'Success'
							WHEN LOWER(@TherapName) like 'stent placement%' 
									AND ( (Ind.ERSObstructed=0 AND Ind.ERSObstructedCBD=0) 
											AND 
										ER.StentInsertionQty> 1) THEN ER.StentInsertionQty --## If more than 1 Stent were inserted! Else- 1 success by default!							
							ELSE 1 END --## Straight 'Success', as this is nothing to do with the Passed Therapeutic Type, which is 'Don't bother' type
						)
					ELSE 1 --## For Colon/Flexi or anything else mentioned in the Where Clause
				END)
		FROM dbo.ERS_Sites						AS   S
		LEFT JOIN dbo.ERS_Procedures			AS	 P ON S.ProcedureId = P.ProcedureId
		LEFT JOIN dbo.ERS_ERCPTherapeutics		AS  ER ON S.SiteId = ER.SiteId
		LEFT JOIN dbo.ERS_UpperGITherapeutics	AS UGI ON S.SiteId = UGI.SiteId
		LEFT JOIN [dbo].[ERS_Visualisation]		AS	 V ON P.ProcedureId = V.ProcedureID
		LEFT JOIN [dbo].[ERS_ERCPAbnoDuct]		AS Abn ON S.SiteId = Abn.SiteId
		LEFT JOIN [dbo].ERS_UpperGIIndications   AS Ind ON P.ProcedureId = Ind.ProcedureId
		WHERE S.SiteId=@SiteId 
		  AND (
				( @ProcType IN (1, 3, 13, 4) AND UGI.CarriedOutRole = @EndRole ) --## carried out by- ?
				OR
				( @ProcType=2 AND ER.CarriedOutRole = @EndRole )
			);
			
		

	RETURN @ResultVar;

END
--################## END Function: fnGetTherapTypeSuccess; Scalar Function
GO

--################## Function: fnGetOtherTypeTheraps; Scalar Function
EXEC DropIfExist 'fnNED_GetOtherTypeTheraps', 'F';
GO 
CREATE FUNCTION [dbo].[fnNED_GetOtherTypeTheraps]
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
							COALESCE((CASE WHEN BicapElectro = 1		THEN 'Bicap electrocautery, '		END), '')
							+
							COALESCE((CASE WHEN Diathermy = 1			THEN 'Diathermy, '			END), '') 
							+
							COALESCE((CASE WHEN PyloricDilatation = 1	THEN 'Pyloric Dilatation, '	END), '') 							
							+
							COALESCE((CASE WHEN pHProbeInsert = 1		THEN 'pHProbe Insert'		END), '') 
							+
							COALESCE(Other, '')  )
						FROM [dbo].ERS_UpperGITherapeutics AS T
						INNER JOIN dbo.ERS_Sites AS S ON T.SiteId=S.SiteId
						WHERE T.SiteId = @SiteId
						  AND T.CarriedOutRole = @EndRole
				END
			ELSE IF @ProcType = 2 --## ERCP
				BEGIN	
					SELECT 
						@ResultVar =(
						  COALESCE(CASE WHEN IsNull(SnareExcision,0)=1 THEN 'Snare Excision, ' END, '') 
						+ 
						  COALESCE(CASE WHEN IsNull(BalloonDilation,0)=1 THEN 'Balloon Dilation, ' END, '') 
						+ 
						  COALESCE(Other, '')
						)
						FROM dbo.ERS_ERCPTherapeutics AS T
						INNER JOIN dbo.ERS_Sites AS S ON T.SiteId=S.SiteId
						WHERE T.SiteId = @SiteId AND CarriedOutRole = @EndRole
						AND (IsNUll(SnareExcision, 0)<>0 OR IsNull(BalloonDilation, 0)<>0 OR LEN(IsNull(Other, '')) >= 1)
												
					END				
			ELSE IF @ProcType = 3 OR @ProcType = 13 --## FLEXY/COLON
				BEGIN
					SELECT @ResultVar=(
							COALESCE((CASE WHEN BicapElectro = 1		THEN 'Bicap electrocautery, '		END), '')
							+
							COALESCE((CASE WHEN Diathermy = 1			THEN 'Diathermy, '			END), '') 
							+
							COALESCE((CASE WHEN HeatProbe = 1			THEN 'Heat probe, '	END), '') 
							+
							/*
							CASE WHEN IsNull(EMR, 0)=0					THEN '' ELSE (CASE EMRType WHEN 1 THEN 'EMR, ' ELSE 'ESD, ' END) END
							+
							
							COALESCE((CASE WHEN HotBiopsy = 1			THEN 'Hot biopsy, '	END), '') 
							+
							*/
							COALESCE((CASE WHEN Sigmoidopexy = 1		THEN 'Sigmoidopexy, '	END), '') 
							+
							COALESCE((CASE WHEN VaricealBanding = 1		THEN 'Variceal Banding, '	END), '') 
							+
							CASE WHEN LEN(Other)>= 1					THEN LTRIM(Other)	END)
						FROM [dbo].ERS_UpperGITherapeutics AS T
						INNER JOIN dbo.ERS_Sites AS S ON T.SiteId=S.SiteId 
						WHERE T.SiteId = @SiteId
						  AND T.CarriedOutRole = @EndRole
				END
		END
	
	SET @ResultVar = ltrim(rtrim(@ResultVar));
	--## Remove the Last ',' of the String; That's a virus! Bad for indigestion!
	SELECT @ResultVar= CASE 
						WHEN RIGHT(@ResultVar, 1)=',' THEN SUBSTRING(@ResultVar, 1, LEN(@ResultVar)-1)
						ELSE @ResultVar END;

	RETURN @ResultVar;
END

--################## END Function: fnNED_GetOtherTypeTheraps; Scalar Function

GO

--########### Table: ERS_ReportAdverse ################
EXEC DropIfExist 'ERS_ReportAdverse','T';
GO
CREATE TABLE [dbo].[ERS_ReportAdverse](
	[AdverseId] [int] NULL,
	[AdverseEvent] [varchar](100) NULL,
	[WhoUpdatedId] [int] NULL,
	[WhoCreatedId] [int] NULL,
	[WhenCreated] [datetime] NULL,
	[WhenUpdated] [datetime] NULL
) ON [PRIMARY]

INSERT INTO [dbo].[ERS_ReportAdverse]
           ([AdverseId]
           ,[AdverseEvent])
     VALUES   (1, 'None'),(2, 'Other'),(3, 'Ventilation'),(4, 'Perforation of lumen'),(5, 'Bleeding')
			, (6, 'O2 desaturation'),(7, 'Flumazenil'),(8, 'Naloxone'),(9, 'Consent signed in room')
			, (10, 'Withdrawal of consent'),(11, 'Unplanned admission'),(12, 'Unsupervised trainee'),(13, 'Death'),(14, 'Pancreatitis');

--########### END Table: ERS_ReportAdverse ################

GO

--########### Table: tvfNED_EndoscopistSelectByProcedureSite ################
EXEC DropIfExist 'tvfEndoscopistSelectByProcedureSite','F';
GO 
CREATE FUNCTION dbo.tvfEndoscopistSelectByProcedureSite
(
	@ProcedureId	AS INT = 0,
	@SiteId			AS INT = 0
)
-- =============================================
-- Description:	This will return the list of 'Consultants' for each Procedure- 
--						You can find by Procedure Id or by SiteId
-- =============================================
RETURNS TABLE 
AS
RETURN 
(
		SELECT 
			P.ProcedureId, 
			IsNull(S.SiteId, 0) AS SiteId,
			P.ListType,
			P.Endoscopist1, p.Endo1Role, (End1.Forename + ' ' + End1.Surname) As End1_Name,
			(CASE p.Endo1Role WHEN 1 THEN 'Independent (no trainer)' WHEN 2 THEN 'I observed' WHEN 3 THEN 'I assisted physically' end ) AS RoleTypeEnd1,
			IsNull((SELECT Id FROM dbo.ERS_UpperGITherapeutics	AS  UGI WHERE UGI.SiteId = S.SiteId  AND  UGI.CarriedOutRole=1), 0) AS ER_TherapRecordId,
			IsNull((SELECT Id FROM dbo.ERS_ERCPTherapeutics		AS ERCP WHERE ERCP.SiteId = S.SiteId AND ERCP.CarriedOutRole=1), 0) AS ERCP_ER_TherapRecordId,
			P.Endoscopist2 AS Endoscopist2, p.Endo2Role,
			(End2.Forename + ' ' + End2.Surname) As End2_Name,
			(CASE p.Endo2Role WHEN 1 THEN 'Independent (no trainer)' WHEN 2 THEN 'Was observed' WHEN 3 THEN 'Was assisted physically' end ) AS RoleTypeEnd2,
			IsNull((SELECT Id FROM dbo.ERS_UpperGITherapeutics AS  UGI WHERE UGI.SiteId=S.SiteId  AND  UGI.CarriedOutRole=2), 0) AS EE_TherapRecordId
			--IsNull((SELECT Id FROM dbo.ERS_ERCPTherapeutics	AS ERCP WHERE ERCP.SiteId=S.SiteId AND ERCP.CarriedOutRole=2), 0) AS ERCP_EE_TherapRecordId,
			--IsNull((SELECT Id FROM dbo.ERS_Visualisation AS  Vis WHERE Vis.ProcedureID=P.ProcedureId), 0) AS VisRecordId

		FROM dbo.ERS_Procedures AS P
   LEFT JOIN dbo.ERS_Sites AS S ON P.ProcedureId=S.ProcedureId
   LEFT JOIN dbo.ERS_Users as End1 ON P.Endoscopist1 = End1.UserID
   LEFT JOIN dbo.ERS_Users as End2 ON P.Endoscopist2 = End2.UserID
	   WHERE (@SiteId<>0 and s.SiteId=@SiteId) 
				OR
			(@ProcedureId<>0 AND P.ProcedureId=@ProcedureId)
)

GO

--################## tvfNED_ProcedureAdverseEvents
EXEC DropIfExist 'tvfNED_ProcedureAdverseEvents','F';
GO 
CREATE FUNCTION [dbo].[tvfNED_ProcedureAdverseEvents]
(
	@ProcedureId as INT
)
-- =============================================
-- Description:	This will return the list of 'Adverse Events' for each Procedure- required for NED Export!
-- =============================================
RETURNS TABLE 
AS
RETURN 
(
WITH AdverseEffectsOther AS(	--## These are other Types.. All the 'Complications' fields. we don't have any EnumList for these types.. so- Hard Code them!
	SELECT 
		DISTINCT QA.ProcedureId, 
		  (CASE WHEN AllergyToMedium=1		THEN 'Allergy to medium, ' ELSE '' END)  
		+ (CASE WHEN Arcinarisation=1		THEN 'Arcinarisation, ' ELSE '' END)  
		+ (CASE WHEN CardiacArrythmia=1		THEN 'Cardiac arrythmia, ' ELSE '' END)  		
		+ (CASE WHEN ContrastExtravasation=1 THEN 'Contrast extravasation, ' ELSE '' END)  
		+ (CASE WHEN DamageToScope=1		THEN 'Damage to scope, ' ELSE '' END)
		+ (CASE WHEN DifficultIntubation=1	THEN 'Difficult intubation, ' ELSE '' END)  		
		+ (CASE WHEN FailedIntubation=1		THEN 'Failed intubation, ' ELSE '' END)  
		+ (CASE WHEN FailedERCP=1			THEN 'Failed ERC/ERP, ' ELSE '' END)  
		+ (CASE WHEN FailedCannulation=1	THEN 'Failed cannulation, ' ELSE '' END)  
		+ (CASE WHEN FailedStentInsertion=1 THEN 'Failed stentInsertion, ' ELSE '' END)  
		+ (CASE WHEN GastricContentsAspiration=1 THEN 'Gastric contents aspiration, ' ELSE '' END)  		
		+ (CASE WHEN InjuryToMouth=1		THEN 'Injury to mouth, ' ELSE '' END)  
		+ (CASE WHEN PoorlyTolerated=1		THEN 'Poorly tolerated, ' ELSE '' END)  
		+ (CASE WHEN PatientDiscomfort=1	THEN 'Patient discomfort, ' ELSE '' END)  
		+ (CASE WHEN Perforation=1			THEN COALESCE(PerforationText + ', ', '') ELSE '' END)  
		+ (CASE WHEN RespiratoryDepression=1 THEN 'Respiratory depression, ' ELSE '' END)  		
		+ (CASE WHEN RespiratoryArrest=1	THEN 'Respiratory arrest, ' ELSE '' END)  
		+ (CASE WHEN ShockHypotension=1		THEN 'Shock/hypotension, ' ELSE '' END)  
		+ (CASE WHEN LEN(TechnicalFailure)>=1 THEN TechnicalFailure + ',' ELSE '' END) 
		+ (CASE WHEN ComplicationsOther=1	THEN IsNull(ComplicationsOtherText, '') ELSE '' END)

		AS Comment
	FROM ERS_UpperGIQA as QA
	WHERE QA.ProcedureId= @ProcedureId
)

		SELECT        ProcedureId, comment, adverseEvent
		FROM            (SELECT ProcedureId
								, NULL AS comment
								, (CASE WHEN PR.PatientConsent	= 1 THEN 10 END)						 AS PatientConsent
								, (CASE WHEN PR.PatientStatus	= 1 OR PR.PatientStatus = 4 THEN 11 END) AS PatientStatus
							FROM ERS_Procedures PR) AS Dn 
								UNPIVOT (adverseId FOR adv IN (PatientConsent, PatientStatus)) 
			AS Up INNER JOIN [dbo].[ERS_ReportAdverse] RT ON up.adverseId = RT.AdverseId
			Where Up.ProcedureId = @ProcedureId
	UNION
		SELECT up.ProcedureId
		, (CASE WHEN adverseEvent='Other' THEN (CASE WHEN RIGHT(O.Comment, 2)=', ' THEN LEFT(O.Comment, LEN(O.Comment)-2) ELSE O.Comment END) ELSE NULL END) AS Comment
		, adverseEvent
		FROM (SELECT ProcedureId
					, CASE WHEN Q.ComplicationsNone		= 1 THEN 1 END AS [None]
					--## Check whether there is Any 'Other' type of Adverse Events selected!
					, (CASE WHEN (Q.DifficultIntubation=1 OR Q.DamageToScope=1 OR Q.GastricContentsAspiration=1 OR Q.ShockHypotension=1 
						OR Q.RespiratoryDepression=1 OR Q.CardiacArrythmia=1 OR Q.CardiacArrest=1 OR Q.RespiratoryArrest=1 
						OR Q.FailedIntubation=1 OR Q.PoorlyTolerated=1 OR Q.PatientDiscomfort=1 OR Q.Perforation=1 OR Q.InjuryToMouth=1 
						OR LEN(Q.TechnicalFailure)>=1 OR Q.AllergyToMedium=1 OR Q.Arcinarisation=1 OR Q.ContrastExtravasation=1 OR Q.FailedERCP=1
						OR Q.FailedCannulation=1 OR Q.FailedStentInsertion=1 OR Q.FailedERCP=1 OR Q.ComplicationsOther=1
						)									THEN  2 END) AS Other					
					, (CASE WHEN (Q.Haemorrhage	= 1 OR SignificantHaemorrhage = 1) THEN  5 END) AS Bleeding
					, (CASE WHEN Q.ConsentSignedInRoom	= 1 THEN  9 END) AS ConsentSignedInRoom
					, (CASE WHEN Q.Death				= 1 THEN 13 END) AS Death					
					, CASE WHEN Q.RespiratoryArrest		= 1 THEN  6 END AS RespiratoryArrest
					, CASE WHEN Q.Haemorrhage			= 1 THEN  5 END AS Haemorrhage
					, CASE WHEN (Q.Hypoxia = 1 OR Q.O2Desaturation=1) THEN 6 END AS Hypoxia	--## '20/01/2017 - Now mapped to O2 desaturation
					--, CASE WHEN Q.Oxygenation			= 1 THEN  6 END AS Oxygenation
					, CASE WHEN Q.Pancreatitis			= 1 THEN 14 END AS Pancreatitis
					, CASE WHEN Q.Perforation			= 1 THEN  4 END AS Perforation
					, CASE WHEN Q.UnplannedAdmission	= 1 THEN 11 END AS UnplannedAdmission
					, CASE WHEN Q.UnsupervisedTrainee	= 1 THEN 12 END AS UnsupervisedTrainee
					, CASE WHEN Q.Ventilation			= 1 THEN  3 END AS Ventilation
					, CASE WHEN Q.WithdrawalOfConsent	= 1 THEN 10 END AS WithdrawalOfConsent
				
				FROM  ERS_UpperGIQA Q) AS cp1
							UNPIVOT (adverseId FOR adverse IN ([None], Bleeding, Other, ConsentSignedInRoom, Death, Haemorrhage, Hypoxia, Pancreatitis, 
																Perforation, RespiratoryArrest, UnplannedAdmission, UnsupervisedTrainee, Ventilation, WithdrawalOfConsent) --ComplicationsOther, Death, CardiacArrythmia, CardiacArrest, 
							) AS up 
					INNER JOIN [dbo].[ERS_ReportAdverse] RT ON up.adverseId = RT.AdverseId
					inner join AdverseEffectsOther as O ON up.ProcedureId = O.ProcedureId
					Where Up.ProcedureId = @ProcedureId
	UNION
		SELECT ProcedureId
			, NULL AS comment
			, (CASE WHEN PM.DrugName = 'Naloxone'	THEN PM.DrugName 
					WHEN PM.DrugName = 'Flumazenil'	THEN PM.DrugName END ) AS AdverseEvent
		FROM ERS_UpperGIPremedication PM
		INNER JOIN dbo.ERS_DrugList as D on PM.DrugNo=D.DrugNo AND D.DrugName IN ('Naloxone', 'Flumazenil')
		WHERE ProcedureId=@ProcedureId	
);

--################## End: tvfNED_ProcedureAdverseEvents

--################## Scaler Function: fnNED_ProcedureExtentIdToName

GO
EXEC dbo.DropIfExist 'fnNED_ProcedureExtentIdToName', 'F';
GO
CREATE FUNCTION dbo.fnNED_ProcedureExtentIdToName
(
	  @ProcedureType AS INT
	, @ExtentId AS INT			--## Is the 'Furthest Extent'.. The Caller function will pass the respective value and check whether TrainEE exist or NOT!
	, @FailureReasonId AS INT	--## when Expected ExtentId not Found- THEN Look for Failure Reason!
)
RETURNS VARCHAR(100)
AS
-- =============================================
-- Description:	This will be re-used in 'dbo.fnNED_ProcedureExtent' 3 times - to translate ExtentId to Name- for OGD/ERCP/COLON and within those for OverAll/TrainEE/TrainER.
-- =============================================
BEGIN
	DECLARE @ResultVar AS VARCHAR(100);
	
	SELECT @ResultVar = 
	(
		CASE when @ProcedureType = 1 THEN (
			CASE
				WHEN @ExtentId IN (4,6,7) THEN 'D2 - 2nd part of duodenum'	--## jejunum, D3 & D2
				WHEN @ExtentId = 8 THEN 'Duodenal bulb'						--## D1
				WHEN @ExtentId = 9 THEN 'Stomach'
				WHEN @ExtentId IN (10, 11) THEN 'Oesophagus'				--## Distal Oesophagus, Proximal Oesophagus
				ELSE --## Check in the Fail category!
					(CASE @FailureReasonId
						WHEN 4 THEN 'Abandoned' ELSE 'Intubation failed' END)  --## UGI logic: Either Abandoned.. or 'Intubation Failed'
			END
		)
			WHEN @ProcedureType = 2 THEN ('ERCP')
			WHEN @ProcedureType IN (3, 13, 4) THEN (
				CASE WHEN @FailureReasonId>0 THEN 'Abandoned'
				ELSE	
					CASE WHEN @ExtentId IN(4, 8, 18)	THEN 'Transverse Colon'			--## distal transverse / mid transverse / proximal transverse
						When @ExtentId IN(3, 14, 17)	THEN 'Sigmoid colon'			--## DistalSigmoid / RectoSigmoid / ProximalSigmoid						
						When @ExtentId = 5				THEN 'Caecum'
						When @ExtentId IN(7, 11)		THEN 'Descending Colon'			--## DistalDescending / proximal descending
						When @ExtentId = 9				THEN 'Terminal ileum'
						When @ExtentId = 10				THEN 'Rectum'
						When @ExtentId = 12				THEN 'Hepatic flexure'
						When @ExtentId = 13				THEN 'Neo-terminal ileum'
						When @ExtentId = 15				THEN 'Splenic flexure'						
						WHEN @ExtentId IN(16, 19)		THEN 'Ascending Colon'			--## distal ascending / distal ascending
						When @ExtentId = 32				THEN 'Pouch'						
						When @ExtentId IN(30, 31)		THEN 'Ileo-colon anastomosis'	--## anastomosis / Ileo-colon anastomosis	
					End
				END

			)
		END
	)

	RETURN @ResultVar;

END
GO

GO

--################## Scaler Function: fnNED_ProcedureExtent
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
						CASE WHEN ( (Vis.MajorPapillaBile_ER > 0 And Vis.MajorPapillaPancreatic_ER > 0)  -- ## TainER
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

--################## Function: tvfNED_ProcedureConsultants
EXEC DropIfExist 'tvfNED_ProcedureConsultants','F';
GO 
CREATE FUNCTION [dbo].[tvfNED_ProcedureConsultants]
(
	@ProcedureId as INT
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
		select top 1 ProcedureId AS ProcedureId, Endoscopist1, Endo1Role, RoleTypeEnd1, Endoscopist2, Endo2Role, RoleTypeEnd2, ListType from tvfEndoscopistSelectByProcedureSite(@ProcedureId,0)	
	)
	Select E.ProcedureId
	--, C.GMCCode AS professionalBodyCode
	, 'UNITrainer' AS professionalBodyCode	 --## Change it for LIVE. In TEST- we need this dummy data to pass the NED Validation check!
	, E.Endoscopist1 AS EndosId, E.Endo1Role AS EndRole, E.ListType
	, E.RoleTypeEnd1 AS procedureRole
	, (Case When (E.Endoscopist2 IS NULL OR E.Endoscopist2 = 0) Then 'Independent' Else 'Trainer' END) As endoscopistRole
	, 1 AS ConsultantTypeId
	, dbo.fnNED_ProcedureExtent(@ProcedureId, 1) AS Extent		--## TrainER Extent
	, (CASE WHEN @ProcedureType IN (1,2) THEN
		(CASE IsNull(Ex.TrainerJmanoeuvre, 1) When 1 Then 'No' WHEN 2 THEN 'Yes' End)
		 WHEN @ProcedureType IN (3, 13, 4) THEN
		 (CASE IsNull(COL.NED_Retroflexion, 0) When 0 Then 'No' WHEN 1 THEN 'Yes' End)
		END)	AS jManoeuvre
	 FROM EndoscopistSummary AS E
	 LEFT JOIN dbo.ERS_UpperGIExtentOfIntubation	AS EX  ON E.ProcedureId = EX.ProcedureId
	 LEFT JOIN dbo.ERS_ColonExtentOfIntubation		AS COL ON E.ProcedureId = COL.ProcedureId
	 LEFT JOIN dbo.ERS_Users						AS U   ON E.Endoscopist1 = U.UserId

	UNION ALL --## Now Combine the TrainEE Record!
	
	Select E.ProcedureId
	--, C.GMCCode AS professionalBodyCode
	, 'UNITrainee' AS professionalBodyCode --## Change it for LIVE. In TEST- we need this dummy data to pass the NED Validation check!
	, E.Endoscopist2 AS EndosId, E.Endo2Role  AS EndRole, E.listType
	, E.RoleTypeEnd2 AS procedureRole
	, 'Trainee' As endoscopistRole
	, 2 AS ConsultantTypeId
	, dbo.fnNED_ProcedureExtent(@ProcedureId, 2) AS Extent	--## TrainEE Extent
	, (CASE WHEN @ProcedureType IN (1,2) THEN
		(CASE IsNull(Ex.Jmanoeuvre, 1) When 1 Then 'No' WHEN 2 THEN 'Yes' End)
		 WHEN @ProcedureType IN (3, 13, 4) THEN
		 (CASE IsNull(COL.Retroflexion, 0) When 0 Then 'No' WHEN 1 THEN 'Yes' End)
		END)	AS jManoeuvre
	--, (Case Ex.Jmanoeuvre When 1 Then 'No' WHEN 2 THEN 'Yes' ELSE 'Not Specified' End) AS jManoeuvre
	from EndoscopistSummary AS E 
		LEFT JOIN dbo.ERS_UpperGIExtentOfIntubation		AS EX  ON E.ProcedureId = EX.ProcedureId
		LEFT JOIN dbo.ERS_ColonExtentOfIntubation		AS COL ON E.ProcedureId = COL.ProcedureId
		LEFT JOIN dbo.ERS_Users							AS U   ON E.Endoscopist2 = U.UserId
	Where E.Endoscopist2 IS NOT NULL
	);



GO
--################## End Function: tvfNED_ProcedureConsultants

GO

--################## Function: tvfProcedureDrugList
EXEC DropIfExist 'tvfNED_ProcedureDrugList','F';
GO 
CREATE FUNCTION [dbo].[tvfNED_ProcedureDrugList]
(	
	@ProcedureId AS INT
)
-- =============================================
-- Description:	This will return the list of the Drugs Used in the Procedures performed on each Patient!
-- =============================================
RETURNS TABLE 
AS
RETURN 
(
	Select *
	From 
		(	
			Select PM.ProcedureId, PM.DrugName, PM.Dose
			, noDrugsAdministered = (SELECT (CASE WHEN SUM(Dose)<=0 THEN 'Yes'END) FROM [dbo].[ERS_UpperGIPremedication] PM where PM.ProcedureId=@ProcedureId)
			FROM [dbo].[ERS_UpperGIPremedication] PM
			where PM.ProcedureId=@ProcedureId
			) As j
		PIVOT
		(
			SUM(j.Dose) For j.Drugname In ([pethidine],[midazolam],[fentanyl],[buscopan],[propofol],[flumazenil],[naloxone], [entonox]) -- ## '06/10/2017 Entonox is added to UGI
		) As PR	
);

--################## End Function: tvfNED_ProcedureDrugList

GO

--################## Function: [tvfNED_ProcedureLimitation]
EXEC DropIfExist 'tvfNED_ProcedureLimitation','F';
GO 
CREATE FUNCTION [dbo].[tvfNED_ProcedureLimitation]
(
	  @ProcedureType AS INT
	, @ProcedureId AS INT

)
-- =============================================
-- Description:	This will return the list of 'Limitation' for each Procedure- required for NED Export!
--			Limitations- only applicable for 'Colon/Flexi'. Not for OGD or ERCP
-- =============================================
RETURNS TABLE
AS
RETURN 
(	
	WITH cteLimitationsFound AS (
	SELECT 
		(Case --## First identify- EE or ER - who has 'FurthestDistance Inserted'- then respective EE or ER's LimitedBy value will be used!
		(CASE WHEN (L.NED_InsertionTo>= L.InsertionTo) THEN L.NED_InsertionLimitedBy ELSE L.InsertionLimitedBy END)		--## Whoever has 'HigherInsertionTo' is the Furthest Traveller!
			WHEN  0 THEN  
				(CASE P.ProcedureType WHEN 13 THEN 'clinical intention achieved' else 'Not Limited' end)
			WHEN  7 then 'inadequate bowel prep'
			WHEN  9 THEN 'patient discomfort'
			WHEN  6 THEN 'benign stricture'
			WHEN  8 THEN 'malignant stricture'
			WHEN 10 THEN 'severe colitis'
			WHEN 11 THEN 'unresolved loop'
			WHEN 12 THEN 'clinical intention achieved'
		ELSE 'Other' --## And 'other' will come in the 'Comment' field!
		END)	As Limitation
		, NULL AS Comment

		FROM [dbo].ERS_ColonExtentOfIntubation L 
		INNER JOIN dbo.ERS_Procedures AS P ON L.ProcedureId = P.ProcedureId
		where L.ProcedureId = @ProcedureId AND P.ProcedureType IN (3,13)
	)
	SELECT * FROM cteLimitationsFound
		
	UNION ALL 

	SELECT 'Other' AS Limitation
	, (SELECT top 1 L.ListItemText	--## There can be ONE 'Other' Field anyway... But - you never know- dirty data can be an evil... So 'TOP 1' is safer!
			FROM [dbo].[ERS_ColonExtentOfIntubation] AS COL 
				INNER JOIN dbo.ERS_Lists AS L ON COL.InsertionLimitedBy=L.ListItemNo AND L.ListDescription = 'Colon_Extent_Insertion_Limited_By'
				WHERE Col.ProcedureId= @ProcedureId AND 
					(CASE WHEN (COL.NED_InsertionTo>= COL.InsertionTo) THEN COL.NED_InsertionLimitedBy ELSE COL.InsertionLimitedBy END)
				NOT IN (0,6,7,8,9,10,11) --### Anything other than SPecified in the NED Valid list- goes in the 'Other' Text!
	) As Comment --## Use this field to define what “Other” is when selected. There can be ONE value ONLY
	FROM cteLimitationsFound AS Lim
	WHERE Lim.Limitation IS NULL --## What I mean- when NO record found for Main Limitation..

);

GO
--################## END Function: [tvfNED_ProcedureLimitation]




--################## Function: [fnNED_GetOtherTypeIndications]

EXEC DropIfExist 'fnNED_GetOtherTypeIndications', 'F';
GO 
CREATE FUNCTION [dbo].[fnNED_GetOtherTypeIndications]
(
	@ProcedureId	AS INT
)
-- =============================================
-- Description:	This will Concatenate the 'Other' Type of Indications which are not recognised by NED Schema.
--				So- when this function is called for a 'OTHER' indication type- it will concatenate some specific Indications,
--						like: ERSImgUltrasound, UT.ERSImgCT, UT.ERSImgMRI, UT.ERSImgMRCP=1  OR UT.ERSImgEUS, UT.ERSImgIDA, UT.ERSAcutePancreatitis and OTher Field's data itself
-- =============================================
RETURNS varchar(1000)
AS
BEGIN	
	DECLARE @ResultVar VARCHAR(1000);

		BEGIN
			SELECT @ResultVar = 
				    COALESCE(ColonColonicObstruction + ', ', '')+ COALESCE(ColonDysplasia + ', ', '')
				  + COALESCE(BalloonInsertion    + ', ', '')	+ COALESCE(BalloonRemoval + ', ', '')		+ COALESCE(BariatricPreAssessment + ', ', '')	+ COALESCE(ChestPain + ', ', '')				+ COALESCE(CIC + ', ', '') 
				  + COALESCE(ChronicLiverDisease + ', ', '')	+ COALESCE(CoeliacDisease  + ', ', '')		+ COALESCE(CoeliacDisease + ', ', '')			+ COALESCE(CoffeeGroundsVomit + ', ', '')		+ COALESCE(DiseaseFollowUpProc + ', ', '') 
				  + COALESCE(DrugTrial + ', ', '')				+ COALESCE(Dyspepsia + ', ', '')			+ COALESCE(EPlanCanunulate    + ', ', '')		+ COALESCE(EPlanEndoscopicCyst + ', ', '')		+ COALESCE(EplanManometry + ', ', '') 
				  + COALESCE(EplanNasoPancreatic + ', ', '')	+ COALESCE(EplanStoneRemoval + ', ', '')	+ COALESCE(EplanStrictureDilatation + ', ', '') + COALESCE(ERSAcutePancreatitis + ', ', '')		+ COALESCE(ERSChronicPancreatisis + ', ', '') 
				  + COALESCE(ERSDilatedDucts + ', ', '')		+ COALESCE(ERSFluidCollection + ', ', '')	+ COALESCE(ERSImgCT + ', ', '')					+ COALESCE(ERSImgEUS   + ', ', '')				+ COALESCE(ERSImgIDA + ', ', '')
				  + COALESCE(ERSImgMRCP + ', ', '') 			+ COALESCE(ERSImgMRI + ', ', '')			+ COALESCE(ERSImgUltrasound + ', ', '')			+ COALESCE(ERSObstructed + ', ', '')			+ COALESCE(ERSObstructedCBD   + ', ', '')
				  + COALESCE(ERSOpenAccess + ', ', '')			+ COALESCE(ERSPapillaryDysfunction + ', ', '')	+ COALESCE(ERSRecurrentPancreatitis   + ', ', '')	+ COALESCE(ERSSphincter   + ', ', '')		+ COALESCE(EUS + ', ', '')
				  + COALESCE(Gastritis    + ', ', '')			+ COALESCE(InsertionOfPHProbe + ', ', '')		+ COALESCE(OtherPlannedProcedure + ', ', '')		+ COALESCE(SurgeryFollowUpText + ', ', '')	+ COALESCE(Malignancy + ', ', '')
				  + COALESCE(NasoDuodenalTube + ', ', '')		+ COALESCE(OesophagealDilatation    + ', ', '') + COALESCE(OesophagealVarices    + ', ', '') + COALESCE(Oesophagitis + ', ', '')			+ COALESCE(PostBariatricSurgeryAssessment + ', ', '') 
				  + COALESCE(PreviousHPyloriTest + ', ', '')	+ COALESCE(PushEnteroscopy    + ', ', '')	+ COALESCE(SmallBowelBiopsy + ', ', '')	
				  + COALESCE(SurgeryFollowUpProc  + ', ', '')	+ COALESCE(UrgentTwoWeekReferral   + ', ', '')	+ COALESCE(ERSImgOthersTextBox + ', ', '')		+ COALESCE(EplanOthersTextBox, '') 
				  + COALESCE(OtherIndication, '') 
			FROM
			(
				SELECT 
					(CASE WHEN ColonColonicObstruction=1 THEN 'colonic obstruction' END) AS ColonColonicObstruction,
					(CASE WHEN ColonDysplasia=1 THEN 'dysplasia' END) AS ColonDysplasia,
					(CASE WHEN LEN(ClinicallyImpComments)> 0 THEN ClinicallyImpComments END) AS CIC, 
					(CASE WHEN ChestPain= 1 THEN 'Chest Pain' end) AS ChestPain,
					(CASE WHEN ChronicLiverDisease = 1 THEN 'Chronic Liver Disease' END) AS ChronicLiverDisease,
					(CASE WHEN CoeliacDisease = 1 THEN 'Coeliac Disease' END) AS CoeliacDiseaseFX,
					(CASE WHEN CoffeeGroundsVomit = 1 THEN 'Coffee grounds vomit' END) AS CoffeeGroundsVomit,
					(CASE WHEN BalloonInsertion = 1 THEN 'Balloon Insertion' END) AS BalloonInsertion,
					(CASE WHEN BalloonRemoval = 1 THEN 'Balloon Removal' END) AS BalloonRemoval,
					(CASE WHEN BariatricPreAssessment = 1 THEN 'Bariatric pre assessment' END) AS BariatricPreAssessment,
					(CASE WHEN PreviousHPyloriTest = 1 THEN 'Previous HPyloric Test' END) AS PreviousHPyloriTest,
					(CASE WHEN DrugTrial = 1 THEN 'Drug Trial' END) AS DrugTrial,
					(CASE WHEN UlcerExclusion = 1 THEN 'Ulcer Exclusion' END) AS UlcerExclusion,
					(CASE WHEN UrgentTwoWeekReferral = 1 THEN 'Urgent two week referral' END) AS UrgentTwoWeekReferral, --## Common field!
					(CASE WHEN EUS = 1 THEN 'EUS' END) AS  EUS,
					(CASE WHEN InsertionOfPHProbe = 1 THEN 'Insertion of PHProbe' END) AS  InsertionOfPHProbe,
					(CASE WHEN NasoDuodenalTube = 1 THEN 'Naso Duodenal Tube' END) AS NasoDuodenalTube,
					(CASE WHEN PostBariatricSurgeryAssessment = 1 THEN 'Post Bariatric Surgery Assessment' END) AS PostBariatricSurgeryAssessment,
					(CASE WHEN PushEnteroscopy = 1 THEN 'Push Enteroscopy' END) AS PushEnteroscopy,
					(CASE WHEN SmallBowelBiopsy = 1 THEN 'Small Bowel Biopsy' END) AS SmallBowelBiopsy,
					(CASE WHEN LEN(OtherIndication) >= 1 THEN OtherIndication END) AS OtherIndication, --## Common
					(CASE WHEN LEN(OtherPlannedProcedure) >= 1 THEN OtherPlannedProcedure END) AS OtherPlannedProcedure,
					(CASE WHEN LEN(SurgeryFollowUpText) >= 1 THEN SurgeryFollowUpText END) AS SurgeryFollowUpText,
					(CASE WHEN SurgeryFollowUpProc >= 1 THEN 'Surgery Follow Up Proc' END) AS SurgeryFollowUpProc,
					(CASE WHEN DiseaseFollowUpProc >= 1 THEN 'Disease Follow Up Proc' END) AS DiseaseFollowUpProc,
					(CASE WHEN CoeliacDisease = 1 THEN 'Coeliac Disease' END) AS CoeliacDisease,
					(CASE WHEN Dyspepsia = 1 THEN 'Dyspepsia' END) AS Dyspepsia,
					(CASE WHEN Gastritis = 1 THEN 'Gastritis' END) AS Gastritis,
					(CASE WHEN Malignancy = 1 THEN 'Malignancy' END) AS Malignancy,
					(CASE WHEN Oesophagitis = 1 THEN 'Oesophagitis' END) AS Oesophagitis,
					(CASE WHEN OesophagealDilatation = 1 THEN 'Oesophageal Dilatation' END) AS OesophagealDilatation,
					(CASE WHEN OesophagealVarices = 1 THEN 'Oesophageal Varices' END) AS OesophagealVarices,
					(CASE WHEN ERSImgUltrasound = 1 THEN 'Ultrasound' END) AS ERSImgUltrasound,
					(CASE WHEN ERSImgCT = 1 THEN 'CT' END) AS ERSImgCT,
					(CASE WHEN ERSImgMRI = 1 THEN 'MRI' END) AS ERSImgMRI,
					(CASE WHEN ERSImgMRCP = 1 THEN 'MRCP' END) AS ERSImgMRCP,
					(CASE WHEN ERSImgEUS = 1 THEN 'EUS' END) AS ERSImgEUS,
					(CASE WHEN ERSImgIDA = 1 THEN 'IDA isotope scan' END) AS ERSImgIDA,
					(CASE WHEN ERSAcutePancreatitis = 1 THEN 'Acute Pancreatitis' END) AS ERSAcutePancreatitis,
					(CASE WHEN ERSChronicPancreatisis = 1 THEN 'Chronic Pancreatisis' END) AS ERSChronicPancreatisis,
					(CASE WHEN ERSDilatedDucts = 1 THEN 'Dilated Ducts' END) AS ERSDilatedDucts,
					(CASE WHEN ERSFluidCollection = 1 THEN 'Fluid Collection' END) AS ERSFluidCollection,
					(CASE WHEN ERSRecurrentPancreatitis = 1 THEN 'Recurrent Pancreatitis' END) AS ERSRecurrentPancreatitis,
					(CASE WHEN ERSOpenAccess = 1 THEN 'Open Access' END) AS ERSOpenAccess,
					(CASE WHEN ERSPapillaryDysfunction = 1 THEN 'Papillary Dysfunction' END) AS ERSPapillaryDysfunction,
					(CASE WHEN ERSSphincter = 1 THEN 'Sphincter' END) AS ERSSphincter,
					(CASE WHEN ERSObstructedCBD = 1 THEN 'Obstructed CBD' END) AS ERSObstructedCBD,
					(CASE WHEN ERSObstructed = 1 THEN 'Obstructed' END) AS ERSObstructed,
					(CASE WHEN EPlanCanunulate = 1 THEN 'EPlan Canunulate' END) AS EPlanCanunulate,
					(CASE WHEN EPlanEndoscopicCyst = 1 THEN 'EPlan Endoscopic Cyst' END) AS EPlanEndoscopicCyst,
					(CASE WHEN EplanManometry = 1 THEN 'Eplan Manometry' END) AS EplanManometry,
					(CASE WHEN EplanNasoPancreatic = 1 THEN 'Eplan Naso Pancreatic' END) AS EplanNasoPancreatic,
					(CASE WHEN EplanStoneRemoval = 1 THEN 'Eplan Stone Removal' END) AS EplanStoneRemoval,
					(CASE WHEN EplanStrictureDilatation = 1 THEN 'Eplan Stricture Dilatation' END) AS EplanStrictureDilatation,
					(CASE WHEN LEN(ERSImgOthersTextBox) > 1 THEN ERSImgOthersTextBox END) AS ERSImgOthersTextBox,
					(CASE WHEN LEN(EplanOthersTextBox) > 1 THEN EplanOthersTextBox END) AS EplanOthersTextBox
					
				 FROM [dbo].ERS_UpperGIIndications
				WHERE ProcedureId = @ProcedureId
			) AS ReadyMixMasala

		END

	SET @ResultVar = ltrim(rtrim(@ResultVar));
	--## Remove the Last ',' of the String; That's a virus! Bad for indigestion!
	SELECT @ResultVar= CASE 
						WHEN RIGHT(@ResultVar, 1)=',' THEN SUBSTRING(@ResultVar, 1, LEN(@ResultVar)-1)
						ELSE @ResultVar END;

	RETURN @ResultVar;

END

--################## End Function: fnNED_GetOtherTypeIndications

go

--################## Function: tvfNED_ProcedureIndication
EXEC DropIfExist 'tvfNED_ProcedureIndication','F';
GO 
CREATE FUNCTION [dbo].[tvfNED_ProcedureIndication]
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
	SELECT	  UP.ProcedureId
			, IT.Indication
			, IT.NedName
			, NULL AS Comment
			, IndicationID
	FROM 
		(SELECT        P.ProcedureId, 
			CASE WHEN UT.AbdominalPain			= 1 THEN 2 END AS AbdominalPain, 
			CASE WHEN UT.AbnormalityOnBarium	= 1 THEN 3 END AS AbnormalityOnBarium, 
			CASE WHEN UT.Anaemia				= 1 THEN 4 END AS Anaemia, 
			CASE WHEN UT.BarrettsOesophagus		= 1 THEN 5 END AS BarrettsOesophagus, 
			CASE WHEN UT.Cancer					= 1 THEN 
				(CASE WHEN P.ProcedureType			IN (3, 4, 5) THEN 28 END) END AS Cancer,
			CASE WHEN UT.Diarrhoea				= 1 THEN 6 END	AS Diarrhoea,	

			/*		## Colon/Flexi Fields		*/
			CASE WHEN UT.ColonAbdominalMass		= 1 THEN 62 END		AS ColonAbdominalMass, 
			CASE WHEN UT.ColonAbdominalPain		= 1 THEN 63 END		AS ColonAbdominalPain, 
			CASE WHEN (UT.ColonAbnormalBariumEnema = 1 OR UT.ColonAbnormalCTScan	= 1 ) THEN 64 END	AS ColonAbnormalBariumEnema, 
			CASE WHEN UT.ColonAbnormalSigmoidoscopy = 1 THEN 66 END AS ColonAbnormalSigmoidoscopy,	
			CASE WHEN ColonAlterBowelHabit=2 THEN 29 END AS ConstipationAcute,				--## Constipation - acute
			CASE WHEN ColonAlterBowelHabit=3 THEN 32 END AS DiarrhoeaAcute,					--## Diarrhoea - acute
			CASE WHEN ColonAlterBowelHabit=4 THEN 27 END AS ChronicAlternatingDiarrhoea,	--## Chronic alternating diarrhoea / constipation
			CASE WHEN ColonAlterBowelHabit=5 THEN 30 END AS ConstipationChronic,			--## Constipation - chronic
			CASE WHEN (ColonAlterBowelHabit=6 AND ColonRectalBleeding=0) THEN 33 END AS DiarrhoeaChronic,		--## Diarrhoea - chronic
			CASE WHEN (ColonAlterBowelHabit=6 AND ColonRectalBleeding > 0) THEN 34 END AS DiarrhoeaChronicWithBlood,		--## Diarrhoea - chronic with blood
			CASE WHEN ColonAlterBowelHabit=7 THEN 31 END AS DefaecationDisorder,			--## Defaecation disorder

			CASE WHEN UT.ColonAnaemia			= 1			THEN 68 END		AS ColonAnaemia, 			
			CASE WHEN IsNull(UT.ColonAssessmentType, 0) >0	THEN 71 END		AS IBDType, --## 'IBD assessment/surveillance'

			CASE WHEN (UT.ColonRectalBleeding>=1 AND UT.ColonRectalBleeding= 
				(SELECT el.ListItemNo FROM dbo.ERS_Lists el WHERE LOWER(el.ListItemText) = 'altered blood [ned]'))		THEN 39 END	
																							AS ColonBleedAltered, --## 'PR bleeding altered'
																							
			CASE WHEN (UT.ColonRectalBleeding>=1 AND UT.ColonRectalBleeding= 
				(SELECT el.ListItemNo FROM dbo.ERS_Lists el WHERE LOWER(el.ListItemText) = 'anorectal bleeding [ned]'))	THEN 40 END	
																							AS ColonBleedAnorectal, --## 'PR bleeding anorectal'
			
			CASE WHEN (UT.ColonBowelCancerScreening = 1 OR UT.ColonSreeningColonoscopy = 1) THEN 74 END	AS BCSP, --## 'screening colonoscopy(family history)' / 'bowel cancer screening programme'
			CASE WHEN UT.ColonCarcinoma			= 1 THEN 75 END		AS ColonCarcinoma, --## 'Colorectal cancer - follow up'
			CASE WHEN UT.ColonFamily			= 1 THEN 78 END		AS ColonFamily,		--## 'FHx of colorectal cancer' / 'Family history taken'
			CASE WHEN UT.ColonFOBT				= 1 THEN 81 END		AS ColonFOBT,		--## FOB +'ve
			CASE WHEN UT.ColonMelaena			= 1 THEN 82 END		AS ColonMelaena,	--## ColonMelaena
			CASE WHEN UT.ColonPolyps			= 1 THEN 83 END		AS ColonPolyps,		--## Previous / known polyps
			CASE WHEN UT.ColonPolyposisSyndrome	= 1 THEN 84 END		AS ColonPolyposisSyndrome,	--## Polyposis syndrome
			CASE WHEN UT.ColonTumourAssessment	= 1 THEN 88 END		AS ColonTumourAssessment, 
			CASE WHEN UT.ColonWeightLoss		= 1 THEN 89 END		AS ColonWeightLoss, 
			--CASE WHEN UT.ColonSurveillance		= 1 THEN 1 END		AS ColonSurveillance, 
			--CASE WHEN UT.ColonSreeningColonoscopy = 1 THEN 1 END	AS ColonSreeningColonoscopy, 
			--CASE WHEN UT.COPD					= 1 THEN 1 END		AS COPD, 
			/*	End: Colon/Flexi Fields	*/

			CASE WHEN (UT.Dyspepsia=1 or UT.DyspepsiaAtypical=1 OR UT.DyspepsiaUlcerType=1) THEN 7 END		AS Dyspepsia, 
			CASE WHEN UT.Dysphagia				= 1 THEN 8 END		AS Dysphagia, 
			CASE WHEN UT.Haematemesis			= 1 THEN 9 END		AS Haematemesis, 
			CASE WHEN UT.RefluxSymptoms			= 1 THEN 10 END		AS RefluxSymptoms, --## -- Heartburn / reflux
			CASE WHEN UT.Melaena				= 1 THEN 11 END		AS Melaena,
			CASE WHEN UT.NauseaAndOrVomiting	= 1 THEN 12 END		AS NauseaAndOrVomiting,
			CASE WHEN UT.Odynophagia			= 1 THEN 13 END		AS Odynophagia, 
			CASE WHEN UT.PEGReplacement			= 1	THEN 14 END		AS PEGChange,
			--CASE WHEN ((UT.GastrostomyInsertion=1 AND UT.JejunostomyInsertion=1) OR (UT.PEGReplacement = 1) )	THEN 15 END		AS PEGPlacement, --## From UGI-> PEGChange will INSERT two elements in the <Indications>, 1) PEGChange, 2) PEGPlacement
			CASE WHEN ( UT.JejunostomyInsertion=1  OR UT.PEGReplacement = 1) 	THEN 15 END		AS PEGPlacement,
			CASE WHEN UT.PEGRemoval				= 1 THEN 16 END		AS PEGRemoval,
			CASE WHEN UT.PositiveTTG_EMA		= 1 THEN 17 END		AS PositiveTTG_EMA,
			CASE WHEN UT.StentReplacement		= 1 THEN 18 END		AS StentReplacement, --## NED Name = 'Stent change'
			CASE WHEN UT.StentInsertion			= 1 THEN 19 END		AS StentInsertion,  --## NED Name = 'Stent placement'
			CASE WHEN UT.StentRemoval			= 1 THEN 20 END		AS StentRemoval,
			CASE WHEN UT.UlcerHealing			= 1 THEN 21 END		AS UlcerHealing,
			CASE WHEN UT.OesophagealVarices		= 1 THEN 22 END		AS OesophagealVarices,
			CASE WHEN UT.WeightLoss				= 1 THEN 23 END		AS WeightLoss

			/*	ERCP Fields	*/			
			, (CASE WHEN UT.ERSAbnormalEnzymes=1		THEN 43 END) AS AbnormalLiverEnzymes
			, (CASE WHEN UT.ERSAcutePancreatitis =1		THEN 44 END) AS AcutePancreatitis
			, (CASE WHEN UT.AmpullaryMass =1			THEN 45 END) AS AmpullaryMass
			, (CASE WHEN UT.ERSBileDuctInjury=1			THEN 46 END) AS BileDuctInjury
			, (CASE WHEN UT.BiliaryLeak = 1				THEN 47 END) AS BileDuctLeak
			, (CASE WHEN UT.ERSCholangitis = 1			THEN 48 END) AS Cholangitis
			, (CASE WHEN UT.ERSChronicPancreatisis = 1  THEN 49 END) AS ChronicPancreatitis
			, (CASE WHEN UT.GallBladderMass = 1			THEN 50 END) AS GallbladderMass
			, (CASE WHEN UT.GallBladderPolyp = 1		THEN 51 END) AS GallbladderPolyp
			, (CASE WHEN UT.ERSHepaticMass = 1			THEN 52 END) AS HepatobiliaryMass
			, (CASE WHEN UT.ERSJaundice = 1				THEN 53 END) AS Jaundice
			, (CASE WHEN UT.ERSPancreaticMass = 1		THEN 54 END) AS PancreaticMass
			, (CASE WHEN UT.ERSPancreaticPseudocyst = 1 THEN 55 END) AS PancreaticPseudocyst
			, (CASE WHEN UT.ERSPancreatobiliaryPain = 1 THEN 56 END) AS PancreatobiliaryPain
			, (CASE WHEN UT.ERSPapillaryDysfunction = 1 THEN 57 END) AS PapillaryDysfunction
			, (CASE WHEN UT.ERSPrelaparoscopic = 1		THEN 58 END) AS PreLapCholedocholithiasis
			, (CASE WHEN UT.ERSPriSclerosingChol = 1	THEN 59 END) AS PrimarySclerosingCholangitis
			, (CASE WHEN UT.ERSPurulentCholangitis = 1	THEN 60 END) AS PurulentCholangitis
			, (CASE WHEN UT.ERSStentOcclusion = 1		THEN 61 END) AS StentDysfunction
			/*	End: ERCP Fields	*/
		FROM            dbo.ERS_Procedures P 
			LEFT OUTER JOIN dbo.ERS_UpperGIIndications UT ON P.ProcedureId = UT.ProcedureId
			Where UT.ProcedureId = @ProcedureId
			) 
		AS PT UNPIVOT 
		(IndicationID FOR Therapies IN (AbdominalPain, AbnormalityOnBarium,  Anaemia, BarrettsOesophagus
										, Cancer, Dyspepsia, Dysphagia, Haematemesis, RefluxSymptoms, Melaena, NauseaAndOrVomiting
										, Odynophagia, PEGChange,PEGPlacement, PEGRemoval, PositiveTTG_EMA, StentReplacement, StentInsertion, StentRemoval
										, UlcerHealing, OesophagealVarices, WeightLoss,
										ColonAbdominalMass, ColonAbdominalPain, ColonAbnormalBariumEnema, ColonAbnormalSigmoidoscopy, 
										ConstipationAcute, Diarrhoea, DiarrhoeaAcute, ChronicAlternatingDiarrhoea, ConstipationChronic, DiarrhoeaChronic, DiarrhoeaChronicWithBlood, DefaecationDisorder,
										ColonAnaemia, IBDType, BCSP,
										ColonCarcinoma, ColonBleedAnorectal, ColonBleedAltered,
										ColonFamily, ColonFOBT, ColonMelaena, ColonPolyps, ColonPolyposisSyndrome, ColonTumourAssessment, ColonWeightLoss
										/* Missing fields: 'PR bleeding - anorectal', 'PR bleeding - altered blood'	*/
										--, Epilepsy, BiliaryLeak, BreathTest,Allergy, AllergyDesc,Angina, Asthma,COPD, 
										/* ERCP FIELDS 'IBD assessment/surveillance'	*/
										, AbnormalLiverEnzymes, AcutePancreatitis, AmpullaryMass, BileDuctInjury, BileDuctLeak, Cholangitis, ChronicPancreatitis
										, GallbladderMass, GallbladderPolyp, HepatobiliaryMass, Jaundice, PancreaticMass, PancreaticPseudocyst
										, PancreatobiliaryPain, PapillaryDysfunction, PreLapCholedocholithiasis, PrimarySclerosingCholangitis
										, PurulentCholangitis, StentDysfunction
										)
		) 
		AS UP 
		LEFT OUTER JOIN	dbo.ERS_IndicationTypes IT ON UP.IndicationID = IT.Id

	UNION ALL	--## Get the 'Other' Row seperately!

	SELECT	  @ProcedureId AS ProcedureId
			, 'Other' AS Indication
			, 'Other' AS NedName
			, dbo.fnNED_GetOtherTypeIndications(@ProcedureId) AS Comment
			, 0 AS IndicationID
);

--################## END Function: tvfProcedureIndication

GO



-- ######################################### FUNCTION: fnNED_GetBiopsySiteName #########################################

EXEC DropIfExist 'fnNED_GetBiopsySiteName', 'F';
GO

CREATE FUNCTION [dbo].[fnNED_GetBiopsySiteName]
(
	  @ProcedureID AS INT
	, @RegionName AS VARCHAR(50)
)
RETURNS VARCHAR(100)
AS
-- =============================================
-- Description:	This will translate the Region name to Valid NED Site name
--				Will be used three times at least: 1) NED_Biopsy, 2) NED_Diagnoses, 3) Therapeutic Site
-- =============================================
BEGIN
	DECLARE @ResultVar VARCHAR(250);

	DECLARE @ResectedColonId int, @ProcedureType int
	SELECT @ResectedColonId	= ISNULL(ResectedColonNo,0), @ProcedureType = ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureID
	
	IF @ProcedureType=2 
		set @ResultVar = 'None' --## No BIOPSY info required for ERCP Procs! NED doesn't care!

	--## Just to avoid naming confusion, COLON, OGD may have some similar Region names!
	IF @ProcedureType=1	
		BEGIN
			IF CHARINDEX(LOWER(@RegionName), 'upper oesophagus,middle oesophagus,lower oesophagus,right upper oesophagus,left upper oesophagus,right middle oesophagus,left middle oesophagus,right lower oesophagus,left lower oesophagus,cardia')>0
				set @ResultVar = 'Oesophagus';
			ELSE IF CHARINDEX(LOWER(@RegionName), 'fundus,upper body,middle body,lower body,antrum,prepyloric region,pylorus')>0
				set @ResultVar = 'Stomach';
			ELSE IF LOWER(@RegionName)='bulb'			
				set @ResultVar = 'Duodenal bulb'
			ELSE IF LOWER(@RegionName)='second part'	
				set @ResultVar = 'D2 - 2nd part of duodenum'
		END										
	
	--## Now colon/flexi Fields
	IF @ProcedureType=3	OR @ProcedureType=13 OR @ProcedureType=4
		BEGIN
			IF (@ResectedColonId IN (6,7,9) AND LOWER(@RegionName) = 'terminal ileum')
			BEGIN
				IF(@ResectedColonId = 6 OR @ResectedColonId = 7)
					set @RegionName = 'Neo-terminal ileum';
				ELSE IF (@ResectedColonId = 9)
					set @RegionName = 'ileal pouch'; --but this isn't an enum... where had it come from? should it be just Pouch?
			END
			
			--use charindex where multiple regions result in a single value, otherwise do a direct match- correct value could result in getting overwritten otherwise eg terminal ileum vs neo-terminal ileum. both returns a charindex of >0
			IF LOWER(@RegionName) = 'terminal ileum'
				set @ResultVar = 'Terminal ileum';
			IF LOWER(@RegionName) = 'ileal pouch'
				set @ResultVar = 'Pouch';
			IF LOWER(@RegionName) = 'anastomosis'
				set @ResultVar = 'Ileo-colon anastomosis';
			IF (CHARINDEX( LOWER(@RegionName), 'distal ascending, mid ascending, proximal ascending')>0 )
				set @ResultVar = 'Ascending Colon';
			IF (CHARINDEX( LOWER(@RegionName), 'distal transverse, mid transverse, proximal transverse')>0 )
				set @ResultVar = 'Transverse Colon';
			IF (CHARINDEX( LOWER(@RegionName), 'distal descending, mid descending, proximal descending')>0 )
				set @ResultVar = 'Descending Colon';
			IF (CHARINDEX( LOWER(@RegionName), 'distal sigmoid,proximal sigmoid,rectosigmoid junction')>0 )
				set @ResultVar = 'Sigmoid Colon';
			IF (CHARINDEX( LOWER(@RegionName), 'caecum,appendiceal orifice,ileocecal valve')>0 )
				set @ResultVar = 'Caecum';
			IF LOWER(@RegionName) = 'neo-terminal ileum'
				set @ResultVar	= 'Neo-terminal ileum';
			IF LOWER(@RegionName) = 'hepatic flexure'
				set @ResultVar	= 'Hepatic flexure';
			IF (CHARINDEX( LOWER(@RegionName), 'distal transverse, mid transverse, proximal transverse')>0)
				set @ResultVar	= 'Transverse Colon';
			IF LOWER(@RegionName) = 'splenic flexure'
				set @ResultVar	= 'Splenic flexure';
			IF (CHARINDEX( LOWER(@RegionName), 'distal descending, mid descending, proximal descending')>0)
				set @ResultVar	= 'Descending Colon';
			IF (CHARINDEX( LOWER(@RegionName), 'distal sigmoid, proximal sigmoid, rectosigmoid junction')>0)
				set @ResultVar	= 'Sigmoid Colon';
			IF LOWER(@RegionName) = 'rectum'
				set @ResultVar	= @RegionName;
			IF LOWER(@RegionName) = 'anal margin'
				set @ResultVar	= 'Anus';


		END
	
				
	RETURN @ResultVar;

END
GO

--################## Function: [tvfNED_Diagnoses]
EXEC DropIfExist 'tvfNED_Diagnoses','F';
GO 
CREATE FUNCTION [dbo].[tvfNED_Diagnoses]
(	
	@ProcedureId AS INT
)
RETURNS TABLE 
AS
RETURN 
(
	   SELECT 
				'Colorectal cancer' AS Ned_Name
			  , (
					--## There can be more than 1 record!  Maybe 2 sites- one Marked Tattooed, another Marked with Platue! 'Yes' will supercede 'No';
					SELECT CASE WHEN (
								COUNT( CASE T.MarkingType WHEN 1 THEN 1 ELSE NULL end) 
								>=
								COUNT( CASE WHEN T.MarkingType>1 THEN 1 ELSE NULL end)

						) THEN 'Yes' ELSE 'No' END 
						AS Result
					from dbo.ERS_UpperGITherapeutics AS T
					INNER JOIN dbo.ERS_Sites		AS S ON T.SiteId = S.SiteID
					LEFT JOIN dbo.ERS_Procedures	AS P ON S.ProcedureId = P.ProcedureId
					WHERE P.ProcedureId= @ProcedureId AND T.Marking = 1
				)	AS tattooed	--## 'Colonic polyps or Rectal polyps' => Colon/FLexi ONLY! 
				, dbo.fnNED_GetBiopsySiteName(P.ProcedureId, R.Region) As Site		--## Location of tattoo. BiopsyEnum (Page 42, in Business Spec.doc v.1.15): The Biopsy field is procedure specific. See the BiopsyEnum table for further information.
			  , NULL AS Comment
		 FROM [dbo].[ERS_Diagnoses] D
	--LEFT JOIN [dbo].[ERS_DiagnosesMatrix]	AS M ON D.MatrixCode = M.Code
	LEFT JOIN [dbo].[ERS_Procedures]		AS P ON D.ProcedureID = P.ProcedureId
	LEFT JOIN dbo.ERS_Sites		AS S ON D.SiteId = S.SiteId
	LEFT JOIN dbo.ERS_Regions	AS R ON S.RegionId = R.RegionId
		WHERE D.ProcedureId= @ProcedureId
		  AND P.ProcedureType IN(1,3,13)	--## Only for OGD/Colon/FLEXI! NOT for ERCP!
		  AND D.MatrixCode = 'S69P3'  --## 'Colorectal cancer'
	--## Combine the ColorectalCancerTattooedSite Result, if there is ANY!
	UNION ALL					

	--## There are few Exception 'Diagnoses' Code.. Which doesn't exist int he DiagnosesMatrix.Code field. So- read them separately
		select TOP 1 --## 'Top 1' Because- it can be like: "'OverallNormal', 'DuodenumNormal', 'OesophagusNormal', 'StomachNormal'"- and we need only once to show 'Normal!'
			  'Normal' AS Ned_Name
			, NULL	AS Tattooed
			, NULL	AS site		
			, NULL	AS Comment
		FROM ERS_diagnoses AS D
			where D.ProcedureId= @ProcedureId AND MatrixCode IN ('D198P2', 'D265P2', 'D33P2', 'D51P2', 'D67P2','D138P2','ColonRestNormal','DuodenumNormal','OesophagusNormal','StomachNormal','ColonNormal','OverallNormal') --## (Duodenum, Papillae, Pancreas, Biliary, Intrahepatic, Extrahepatic)

	UNION ALL					
	select DISTINCT --## DISTINCT REQUIRED- When in Stomach- 3 sites - all has Polyps and Gastric- then they will repeat.
		  M.Ned_Name
		, NULL	AS Tattooed
		, NULL	AS site		
		, NULL	AS Comment
	FROM ERS_diagnoses AS D
	INNER JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code
	where D.ProcedureId= @ProcedureId 
		AND M.Ned_Name IS NOT NULL --## I mean select the 'NED Mapped' fields ONLY!

	UNION ALL					--## Combine 'OTHER' type of Diagnoses! Which Doesn't have a NED Name mapping!
		select top 1
		  'Other' AS DisplayName
		, NULL	AS Tattooed
		, NULL	AS site		
		, 
		(select 
			  (Section + ' ' + M.DisplayName) + ', ' 
		FROM ERS_diagnoses AS D 
		LEFT JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code
		where D.ProcedureId= @ProcedureId
			AND M.Ned_Name IS NULL --## 'NED Mapped' is Missing
			AND D.MatrixCode NOT IN ('D198P2', 'D265P2', 'D33P2', 'D51P2', 'D67P2','D138P2') --## Diagnoses thinks these Exceptions belongs to others.. Because these are not Mapped to NED seperately
			FOR XML PATH('')
		) AS Comment		--## All the fields which are not in the 'NED Restricted Lookup' list!
	FROM ERS_diagnoses AS D
	INNER JOIN [dbo].[ERS_DiagnosesMatrix] AS M ON D.MatrixCode = M.Code --## InnerJoin- to avoid keeping anything which Codes (Summary, OverallNormal) don't exist in the Matrix Table.. WIll exclude them...
	where D.ProcedureId= @ProcedureId
		AND M.Ned_Name IS NULL --## Means when 'NED Mapped' is Missing- those belong to 'Other' type
		AND D.MatrixCode NOT IN ('D198P2', 'D265P2', 'D33P2', 'D51P2', 'D67P2','D138P2') --## Secondary filter- not to populate a blank 'Other' row.. So- don't return any OTHER row at all if any NORMAL found

	UNION ALL--## Handles colotis diagnosis as the diagnoses matrix table is joined on ERS_Diagnoses 'value' column rather than the 'code' column
		SELECT 
		  ISNULL(NED_Name,'Colitis - unspecified') AS NED_Name
		, NULL	AS Tattooed
		, NULL	AS site		
		, NULL	AS Comment
		FROM ERS_Diagnoses 
			INNER JOIN dbo.ERS_DiagnosesMatrix edm	ON code=value
		WHERE dbo.ers_diagnoses.MatrixCode='ColitisType'  AND procedureid=@ProcedureId	
);


GO




--################## Function: tvfNED_PolypsDetailsView
EXEC DropIfExist 'tvfNED_PolypsDetailsView', 'F';
GO
CREATE FUNCTION dbo.tvfNED_PolypsDetailsView
(
	  @ProcType		AS INT
	, @ProcedureId	AS INT
)
RETURNS TABLE 
AS
-- =============================================
-- Description:	This will return only one Row.. Three different Values- "Detected / Size	/ Retrieved"- So- only ONE trip to the Database! Better than Scalar Function!
-- =============================================

RETURN 
(
		SELECT S.SiteId,
			Detected = CASE	WHEN @ProcType = 1 THEN SUM(IsNull(AB.SessileQty, 0)+IsNull(AB.PedunculatedQty, 0) + IsNull(AB.SubmucosalQty,0) ) 
								WHEN @ProcType IN (3, 13, 4) THEN SUM(IsNull(CL.SessileQuantity,0)+IsNull(CL.PedunculatedQuantity,0)+IsNull(CL.PseudopolypsQuantity,0)+IsNull(CL.PolypoidalQuantity,0) )
						ELSE 0 END
			, Size = CASE	WHEN @ProcType IN (1,2) THEN  MAX(CASE WHEN IsNull(AB.SessileLargest, 0) > IsNull(AB.PedunculatedLargest, 0) THEN IsNull(AB.SessileLargest, 0) 
																ELSE CASE WHEN IsNull(AB.PedunculatedLargest, 0) > IsNull(AB.SubmucosalLargest, 0) THEN IsNull(AB.PedunculatedLargest, 0) 
																ELSE IsNull(AB.SubmucosalLargest, 0) END END)
								WHEN @ProcType IN (3, 13, 4) THEN MAX(CASE WHEN IsNull(CL.SessileLargest, 0) > IsNull(CL.PedunculatedLargest, 0) THEN IsNull(CL.SessileLargest, 0) 
																ELSE CASE WHEN IsNull(CL.PedunculatedLargest, 0) > IsNull(CL.SubmucosalLargest, 0) THEN IsNull(CL.PedunculatedLargest, 0) 
																ELSE IsNull(CL.SubmucosalLargest, 0) END END)
							ELSE 0 END
			, Retrieved = CASE	WHEN @ProcType IN (1,2) THEN  SUM(IsNull(AB.SessileNumRetrieved, 0) + IsNull(AB.PedunculatedNumRetrieved, 0) + IsNull(AB.SubmucosalNumRetrieved, 0))
										WHEN @ProcType IN (3, 13, 4) THEN SUM(IsNull(CL.SessileRetrieved, 0) + IsNull(CL.PedunculatedRetrieved, 0) + IsNull(CL.PseudopolypsRetrieved, 0))
								ELSE 0 END
		FROM dbo.ERS_Sites		AS S
		LEFT JOIN  dbo.ERS_UpperGIAbnoPolyps AS AB ON	AB.SiteId = S.SiteId
		LEFT JOIN dbo.ERS_ColonAbnoLesions	AS CL ON	CL.SiteId = S.SiteId		
		INNER JOIN dbo.ERS_Procedures	AS P ON P.ProcedureID = S.ProcedureId AND P.ProcedureId=@ProcedureId
		GROUP BY S.SiteId
)
GO

--################## Function: tvfNED_ProcedureTherapeutic
EXEC DropIfExist 'tvfNED_ProcedureTherapeutic','F';
GO 
CREATE FUNCTION dbo.tvfNED_ProcedureTherapeutic
(	
	  @ProcedureType AS INT
	, @ProcedureId AS INT
	, @CarriedOutRole AS INT --## 1: ER; 2: EE; 4: Independent
)
RETURNS TABLE 
AS
RETURN 
(
--WITH polypsSummary AS( --## This will return only one Row.. Three different Values- "Detected / Size	/ Retrieved"- So- only ONE trip to the Database! Better than Scalar Function!
--	SELECT 
--		Detected, Retrieved
--		, PolypSizeText = (CASE WHEN Size IS NULL OR Size=0 THEN NULL WHEN Size<10 THEN 'ItemLessThan10mm' WHEN Size BETWEEN 10 AND 20 THEN 'Item10to19mm' ELSE 'Item20OrLargermm' END)
--	from dbo.tvfNED_PolypsDetailsView(@ProcedureType, @ProcedureId) 
--),
WITH CTE AS ( --## Just wrapping the selection in the CTE to use later for a COUNT() operation
	
	SELECT      
		  UP.ProcedureId
		, UP.ProcedureType
		, UP.SiteId
		, UP.[Site] AS Saite
		, dbo.fnNED_GetBiopsySiteName(UP.ProcedureId, UP.[Site]) As [Site]
		--, UP.TherapyTypeId
		--, TT.[Description]
		, TT.NedName
		--, UT_CarriedOutRole
		--, ERCP_CarriedOutRole
		, (CASE WHEN TT.NedName LIKE 'Polyp%' THEN UP.Tattooed ELSE NULL END) AS Tattooed
		, (CASE WHEN TT.NedName LIKE 'Stent placement%' then COALESCE(UGI_StentQty, ER_StentQty)				else 1 END) AS StentPerformed --## 'Stent Placement' for O/C/F; And 'Stent placement - pancreas/CBD' for ERCP
		--, UGI_StentQty, ER_StentQty --#############
		, dbo.fnNED_GetTherapTypeSuccess(ProcedureType, SiteId, @CarriedOutRole, NedName) AS Successful
		, (CASE WHEN UP.TherapyTypeId=2 THEN	--## Any Therap in 'Other' Category
			dbo.fnNED_GetOtherTypeTheraps(ProcedureType, UP.SiteId, @CarriedOutRole) 
			END --## ELSE Return NULL... Should only be available when 'Other' Therap is present
		  ) AS Comment
	FROM            
		(SELECT			
				P.ProcedureId,  
				P.ProcedureType,
				S.SiteId, 
				R.Region AS [Site], --## Link to [dbo.ERS_Regions] via Sites.Id
				NULL [role]
				, UT.CarriedOutRole											AS UGI_CarriedOutRole
				, ER.CarriedOutRole											AS ERCP_CarriedOutRole				
				, (CASE WHEN L.Tattooed = 1 THEN 'Yes'  WHEN L.PreviouslyTattooed = 1 THEN 'Previously Tattooed' ELSE 'No' END)		AS Tattooed
				, UT.StentInsertionQty										AS UGI_StentQty
				, ER.StentInsertionQty										AS ER_StentQty,
				CASE WHEN (UT.[None] = 1 OR T.[None] = 1) THEN 1 END AS [None], 
				CASE WHEN ( @ProcedureType=1 AND UT.BotoxInjection	= 1) THEN  8 END					AS BotoxInjection, 			
				CASE WHEN ( @ProcedureType=1 AND UT.HeatProbe		= 1) THEN 22 END					AS HeatProbe, 			
				CASE WHEN ( @ProcedureType=1 AND (UT.HotBiopsy	= 1 OR T.HotBiopsy = 1)) THEN 23 END	AS HotBiopsy,		--## OGD						
				CASE WHEN ( @ProcedureType=1 AND (UT.GastrostomyInsertion  = 1 AND UT.GastrostomyRemoval=1))	THEN 28 END	AS PEGChange,
				CASE WHEN ( @ProcedureType=1 AND UT.GastrostomyInsertion   = 1 AND UT.GastrostomyRemoval=0)		THEN 29 END	AS PEGInsertion, 	--## PEG placement; Not required to show when 'PEGRemoval' happens.. The we Will combinedly call this- 'PEGChange'
				CASE WHEN ( @ProcedureType=1 AND (UT.GastrostomyRemoval  = 1 AND UT.GastrostomyInsertion=0))	THEN 30 END	AS PEGRemoval, 		--## Same logic like- PEGInsertion
				CASE WHEN ( @ProcedureType=1 AND UT.Polypectomy		= 1)		THEN 37 END				AS Polypectomy,
				CASE WHEN ( @ProcedureType=1 AND UT.RFA				= 1)		THEN 38 END				AS RFA, 				
				--CASE WHEN ( @ProcedureType=1 AND UT.[VaricealBanding] = 1)	THEN 47 END				AS VaricealBanding, 	-- '20/01/2017 - 'VaricealBanding' Now mapped to 'BandLigation'		
				CASE WHEN ( @ProcedureType=1 AND (UT.BandLigation = 1 OR UT.VaricealBanding = 1))	THEN  6 END				AS BandLigation, 
				CASE WHEN ( @ProcedureType=1 AND UT.EMR				= 1)		THEN 
					(CASE WHEN ISNULL(UT.EMRType, 0)<> 0 THEN (CASE UT.EMRType WHEN 1 THEN 16 ELSE 19 END) END) END  --## Was [EMRType] = EMR(16) or ESD(19)?
																									AS EMR, 	--'## OGD		
				CASE WHEN ( @ProcedureType=1 AND UT.VaricealSclerotherapy = 1) THEN 47	END			AS VaricealSclerotherapy,	--### Variceal banding
			
				-- #### Common Fields to OGD/ERCP/Colon/Flexi
				(CASE WHEN UT.ArgonBeamDiathermy	= 1 THEN 3 END)						AS ArgonBeamDiathermy, --## C/F/O
				(CASE WHEN UT.ForeignBody		= 1 THEN 20 END)						AS ForeignBody,			--##  O / C / F
				(CASE WHEN UT.Marking			= 1 THEN 26 END)						AS Marking,		--##  O / C / F
				(CASE WHEN UT.BandingPiles		= 1 THEN 7 END)							AS BandingPiles,		--## O / C / F
				
				(CASE WHEN (UT.Injection	= 1 OR ER.Injection = 1)	THEN 24 END)	AS Injection,		--## ALL
				(CASE WHEN @ProcedureType IN (1,3,13,4) THEN 
					( CASE WHEN ( UT.StentRemoval = 1 AND UT.StentInsertion = 0) THEN 44 END ) 
					ELSE --## For ERCP
					( CASE WHEN (ER.StentRemoval = 1 AND ER.StentInsertion = 0) THEN 44 END ) 
				 END)																	AS StentRemoval,	--## ALL
				 (CASE WHEN @ProcedureType IN (1,3,13,4) THEN 
					( CASE WHEN ( UT.StentRemoval = 0 AND UT.StentInsertion = 1) THEN 43 END ) 
					ELSE --## For ERCP
					( CASE WHEN (ER.StentRemoval = 0 AND ER.StentInsertion = 1) THEN 43 END ) 
				 END)																	AS StentPlacement,	--## ALL
				(CASE WHEN @ProcedureType IN (1,3,13,4) THEN 
					( CASE WHEN ( UT.StentRemoval = 1 AND UT.StentInsertion = 1) THEN 40 END ) 
					ELSE --## For ERCP
					( CASE WHEN (ER.StentRemoval = 1 AND ER.StentInsertion = 1) THEN 40 END ) 
				 END)																	AS StentChange, --## Does NOT exist! Calculated Field on the fly!	--## ALL
				/*	#### End: Common fields	*/			
				CASE WHEN UT.YAGLaser				= 1 THEN 48 END AS YAGLaser,			--## O  / C / F
				CASE WHEN UT.Clip					= 1 THEN 12 END AS Clip,				--## O  / C / F		
				CASE WHEN UT.BalloonDilation		= 1 THEN  4 END AS BalloonDilation,		--## ALL: Balloon sphicteroplasty									
				CASE WHEN (
					(UT.OesophagealDilatation=1 AND UT.DilatorType=2)
						OR
					(ER.BalloonTrawlDilatorType=2 or ER.DilatorType=2) --## Need to confirm this Logic!
					)									THEN 9 END AS BougieDilation, --## O / E					
				CASE WHEN UT.EndoloopPlacement	= 1 THEN 17 END AS EndoloopPlacement,	--## O / C / F
			
				/* 
					There are many other fields in the OGD/ERCP Therap Tables, but NED isn't interested in each and every Theraps.
					The Valid/Acceptable names are given in the XSD/Documentation file. Few other Theraps are put in 
					the 'Other' Category- instructions found in the Excel file, by Steve!
				*/

				(CASE  
						WHEN P.ProcedureType = 1 THEN							--## OGD / Gastroscopy
							(CASE WHEN 
									(UT.BicapElectro = 1		OR UT.Diathermy = 1	OR UT.PyloricDilatation = 1 OR UT.pHProbeInsert = 1		OR LEN(UT.Other) > 1) THEN 2
								END)
						WHEN P.ProcedureType = 2 THEN							--## ERCP
							(CASE WHEN 
									(ER.SnareExcision = 1 OR ER.BalloonDilation = 1 OR LEN(ER.Other) > 1 ) THEN 2
							  END)
						WHEN P.ProcedureType IN (3, 13, 4) THEN					-- ## COLON / FLEXI
							(CASE WHEN 
									(UT.VaricealBanding = 1 OR UT.Sigmoidopexy = 1 OR UT.HeatProbe = 1 OR UT.Diathermy = 1 OR UT.BicapElectro = 1 OR LEN(UT.Other) > 1) THEN 2
							  END)							

				END) AS Other,

				--#### ADD the ERCP Therapeutic Fields...
				CASE WHEN ER.BalloonTrawl			= 1 THEN  5 END AS BalloonTrawl,			
				CASE WHEN (@ProcedureType=1 AND T.BrushCytology	= 1) THEN 10 END AS Brush,
				CASE WHEN ER.Cannulation			= 1 THEN 11 END AS Cannulation,
				CASE WHEN ER.RendezvousProcedure	= 1 THEN 13 END AS RendezvousProcedure,
				CASE WHEN ER.DiagCholangiogram		= 1 THEN 14 END AS DiagCholangiogram,
				CASE WHEN ER.DiagPancreatogram		= 1 THEN 15 END AS DiagPancreatogram,
				CASE WHEN ER.EndoscopicCystPuncture = 1 THEN 18 END AS Cyst,
				CASE WHEN ER.Haemostasis			= 1 THEN 21 END AS Haemostasis,

				CASE WHEN ER.Manometry					= 1 THEN 25 END AS Manometry,
				CASE WHEN ER.NasopancreaticDrain		= 1 THEN 27 END AS NasopancreaticDrain,
				CASE WHEN ER.PanOrificeSphincterotomy	= 1 THEN 39 END AS Sphincterotomy,
			

				(CASE WHEN (ER.StentInsertion = 1 AND LOWER(R.Region)='Common bile duct')  THEN 42 END )	AS StentPlacementCBD,
				(CASE WHEN (ER.StentInsertion = 1 AND LOWER(R.Region)<>'Common bile duct') THEN 43 END )	AS StentPlacementPAN,

				(CASE WHEN Abn.StonesSize>= 1 THEN 45 END) AS StoneExtractionGT10, --## Stone Size in CM!
				(CASE WHEN Abn.StonesSize < 1 THEN 46 END) AS StoneExtractionLT10,

				--## COLON/FLEXI Specific Fields
				(CASE WHEN (UT.Polypectomy=1 AND IsNull(UT.PolypectomyRemovalType, 0) > 0) THEN (
					CASE UT.PolypectomyRemovalType 
													WHEN 2 THEN 35 --## 'Polyp - snare cold'
													WHEN 3 THEN 36 --## 'Polyp - snare hot'
													WHEN 4 THEN 34 --## 'Polyp - hot biopsy'
													WHEN 5 THEN 31 --## 'Polyp - cold biopsy'
													WHEN 6 THEN 32 --## 'Polyp - EMR'
													WHEN 7 THEN 33 --## 'Polyp - ESD'
													--## Notes: EMR and ESD are already dealt above...
					END 

				) END) AS PolypRemovalType

			FROM            dbo.ERS_Procedures	AS	P	
				INNER JOIN				[dbo].ERS_Sites					AS  S ON P.ProcedureId = S.ProcedureId 
				LEFT JOIN				[dbo].ERS_Regions				AS  R ON S.RegionId = R.RegionId --## To Get SiteName
				LEFT OUTER JOIN			[dbo].ERS_ERCPTherapeutics		AS ER ON S.SiteId = ER.SiteId -- ER.CarriedOutRole  = @CarriedOutRole
				--LEFT OUTER JOIN			[dbo].ERS_ColonTherapeutics		AS CT ON S.SiteId = CT.SiteId
				LEFT OUTER JOIN				[dbo].ERS_UpperGITherapeutics	AS UT ON S.SiteId = UT.SiteId -- UT.CarriedOutRole  = @CarriedOutRole
				LEFT OUTER JOIN			[dbo].[ERS_ColonAbnoLesions]	AS  L ON S.SiteId = L.SiteId 
				LEFT OUTER JOIN			[dbo].[ERS_UpperGISpecimens]	AS  T ON S.SiteId = T .SiteId
				LEFT OUTER JOIN			[dbo].[ERS_ERCPAbnoDuct]		AS Abn ON S.SiteId = Abn.SiteId
				Where P.ProcedureId= @ProcedureId
				  --AND ( (P.ProcedureType1 AND UT.CarriedOutRole  = @CarriedOutRole) --## When OGD Procedure
				  AND ( (P.ProcedureType in (1, 3, 13,4) AND UT.CarriedOutRole  = @CarriedOutRole) --## When OGD Procedure
								OR 
						(P.ProcedureType=2 AND ER.CarriedOutRole  = @CarriedOutRole))		--## When ERCP Procedure
				) AS PT 
				UNPIVOT (TherapyTypeId FOR Therapies IN 
					([None], Other
					, ArgonBeamDiathermy, BalloonDilation, BandLigation, BotoxInjection, BougieDilation, Clip, EndoloopPlacement, EMR, BandingPiles	--, Colon Fields: (ESD,EMR)
					, ForeignBody, HeatProbe, HotBiopsy,  Marking, PEGChange, PEGInsertion, PEGRemoval, Polypectomy, RFA
					, StentRemoval, StentChange, StentPlacement, YAGLaser, Injection, PolypRemovalType
				--## Add ERCP Fields
					, BalloonTrawl,Brush, Cannulation, RendezvousProcedure, DiagCholangiogram, DiagPancreatogram
					, Cyst, Haemostasis, Manometry, Sphincterotomy, NasopancreaticDrain, StentPlacementCBD, 
					StentPlacementPAN, StoneExtractionGT10, StoneExtractionLT10, VaricealSclerotherapy
		
				)
			)  AS UP 
		LEFT JOIN dbo.ERS_TherapeuticTypes TT ON UP.TherapyTypeId = TT.Id
			WHERE 1=1
	) --## End of CTE.. Now just select the desired fields from this CTE

	SELECT ProcedureId, ProcedureType, CTE.SiteId, Saite, [Site], NedName,
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.PolypSizeText ELSE NULL END)		As polypSize,
		Tattooed,
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.Detected ELSE (CASE WHEN StentPerformed>Successful THEN StentPerformed ELSE Successful END) END)		As Performed, --### Successful and Performed should be same!
		(CASE WHEN StentPerformed>Successful THEN StentPerformed ELSE Successful END) AS Successful, --## 'CTE.StentPerformed' watches on the 'Stent placement% (CBD/PAN)' Qty' for Overall level.. better accuracy!
		(CASE WHEN NedName LIKE 'Polyp%' THEN PS.Retrieved ELSE NULL END)			As Retrieved,
		Comment 
		FROM CTE
		INNER JOIN (SELECT 
						SiteId, Detected, Retrieved
						, PolypSizeText = (CASE WHEN Size IS NULL OR Size=0 THEN NULL WHEN Size<10 THEN 'ItemLessThan10mm' WHEN Size BETWEEN 10 AND 20 THEN 'Item10to19mm' ELSE 'Item20OrLargermm' END)
					FROM dbo.tvfNED_PolypsDetailsView(@ProcedureType, @ProcedureId) )AS PS ON PS.SiteId = CTE.SiteId
	
	UNION ALL -- ## A Default Blank ROW.. ONLY when no Therap Record exist..
		SELECT TOP 1
			@ProcedureId AS ProcedureId, @ProcedureType	AS ProcedureType, NULL AS SiteId, NULL AS Saite
			, NULL AS [Site]
			, 'None' AS NedName
			, NULL AS polypSize
			, NULL AS Tattooed, 0 AS Performed, 0 AS Successful, NULL AS Retrieved, NULL  AS Comment
		WHERE (SELECT IsNull(count(*), 0) FROM CTE)<1
	--## A little story for the catch- before we didn't save any empty EE/ER TherapRecord. But now we are saving an Empty ER record when EE has done all the tasks. 
	--##		Then- problem. There is a ER record but that has no Task- T-SQL gets confused- 'Add blank record on what Logic?'
	--##		That's why I have wrapped my Result in the CTE and using for Logical analysis! Shawkat Osman; 2017-11-16

);
GO




--################## END Function: tvfNED_ProcedureTherapeutic




-- ######################################### FUNCTION: tvfNED_ProcedureBiopsy #########################################
EXEC DropIfExist 'tvfNED_ProcedureBiopsy','F';
GO 
CREATE FUNCTION [dbo].[tvfNED_ProcedureBiopsy]
(	
	    @ProcedureType AS INT
	  , @ProcedureId AS INT
)
-- =============================================
-- Description:	This will return the list of the Biopsies done on OGD/ERCP/Colon. NOT for ERCP!
-- =============================================
RETURNS TABLE 
AS
RETURN 
(
	WITH DetailedBiopsy AS (
		SELECT		R.RegionId,
			R.Region
			, CASE WHEN RC.RegionId IS NULL THEN dbo.fnNED_GetBiopsySiteName(P.ProcedureId, r.Region) ELSE 'Ileo-colon anastomosis' END As BiopsySite
			, (CASE WHEN P.ProcedureType=2 THEN 0 
				ELSE (IsNull(SP.BiopsyQtyHistology, 0) + IsNull(SP.BiopsyQtyMicrobiology, 0) + IsNull(SP.BiopsyQtyVirology,0))
				END)								As NumberPerformed
		FROM dbo.ERS_Procedures			P
			INNER JOIN dbo.ERS_Sites				S ON P.ProcedureId=S.ProcedureId
			LEFT JOIN tvfProcedureResectedColon(@ProcedureId) RC ON RC.RegionId = S.RegionId
			INNER JOIN dbo.ERS_UpperGISpecimens SP ON S.SiteId=SP.SiteId
			LEFT JOIN dbo.ERS_Regions			R ON S.RegionId=R.RegionId And P.ProcedureType=R.ProcedureType	
		WHERE P.ProcedureId = @ProcedureId
	)
	SELECT 
		  IsNull(B.BiopsySite, 'None')		AS BiopsySite
		, SUM(IsNull(B.NumberPerformed, 0)) AS NumberPerformed
	FROM DetailedBiopsy AS B
	GROUP BY B.BiopsySite
	HAVING SUM(IsNull(B.NumberPerformed, 0)) > 0 OR B.BiopsySite IS NOT NULL 
	
	UNION ALL
	
	SELECT 'None' BiopsySite, 0 AS NumberPerformed 
	where (SELECT COUNT(*) FROM DetailedBiopsy)<1		--## INSERT  Blank row- if NO BIOPSY 'checked' found for that Procedure..
);

GO

--################## END Function: tvfNED_ProcedureTherapeutic


--################## Scalar Function: fn_NED_PolypsDetails
EXEC DropIfExist 'fn_NED_PolypsDetails', 'F';
GO
CREATE FUNCTION dbo.fn_NED_PolypsDetails
(
	  @ProcType		AS INT
	, @ProcedureId	AS INT
	, @DetailsType  AS VARCHAR(10)
)
RETURNS INT
AS
-- =============================================
-- Description:	This will return the Details about Polyps per Procdeure.
--				You can get result of 1) 'Total Polyps' or the 2) 'Size Text' of the Largest Polyp Detected 
-- =============================================
BEGIN
	DECLARE @PolypsDetected int, @PolypSize AS INT, @PolypSizeText AS VARCHAR(50), @PolypsRetrieved AS INT;

	IF @ProcType = 1
	BEGIN
		SELECT 
			@PolypsDetected = (IsNull(AB.SessileQty, 0)+IsNull(AB.PedunculatedQty, 0) + IsNull(AB.SubmucosalQty,0) ) 
			, @PolypSize = CASE WHEN IsNull(AB.SessileLargest, 0) > IsNull(AB.PedunculatedLargest, 0) THEN IsNull(AB.SessileLargest, 0) 
				ELSE CASE WHEN IsNull(AB.PedunculatedLargest, 0) > IsNull(AB.SubmucosalLargest, 0) THEN IsNull(AB.PedunculatedLargest, 0) 
				ELSE IsNull(AB.SubmucosalLargest, 0) END END
			, @PolypsRetrieved = (IsNull(AB.SessileNumRetrieved, 0) + IsNull(AB.PedunculatedNumRetrieved, 0) + IsNull(AB.SubmucosalNumRetrieved, 0))
		FROM dbo.ERS_UpperGIAbnoPolyps AS AB
		INNER JOIN dbo.ERS_Sites		AS S ON	AB.SiteId = S.SiteId
		INNER JOIN dbo.ERS_Procedures	AS P ON P.ProcedureID = S.ProcedureId AND P.ProcedureId=@ProcedureId;
	END

	IF @ProcType IN (3,13)
	BEGIN
		SELECT
			@PolypsDetected = (IsNull(CL.SessileQuantity,0)+IsNull(CL.PedunculatedQuantity,0)+IsNull(CL.PseudopolypsQuantity,0)+IsNull(CL.PolypoidalQuantity,0) )
			, @PolypSize = CASE WHEN IsNull(CL.SessileLargest, 0) > IsNull(CL.PedunculatedLargest, 0) THEN IsNull(CL.SessileLargest, 0) 
				ELSE CASE WHEN IsNull(CL.PedunculatedLargest, 0) > IsNull(CL.SubmucosalLargest, 0) THEN IsNull(CL.PedunculatedLargest, 0) 
				ELSE IsNull(CL.SubmucosalLargest, 0) END END
			, @PolypsRetrieved = (IsNull(CL.SessileRetrieved, 0) + IsNull(CL.PedunculatedRetrieved, 0) + IsNull(CL.PseudopolypsRetrieved, 0))
		FROM dbo.ERS_ColonAbnoLesions AS CL 
		INNER JOIN dbo.ERS_Sites		AS S ON	CL.SiteId = S.SiteId
		INNER JOIN dbo.ERS_Procedures	AS P ON P.ProcedureID = S.ProcedureId AND P.ProcedureId=@ProcedureId;
		
	END	
	
	--SET @PolypSizeText = (CASE WHEN IsNull(@PolypSize, 0)=0 THEN NULL WHEN IsNull(@PolypSize, 0)<10 THEN 'ItemLessThan10mm' WHEN @PolypSize BETWEEN 10 AND 20 THEN 'Item10to19mm' ELSE 'Item20OrLargermm' END);
	SET @PolypSizeText = (CASE WHEN @PolypSize=0 THEN NULL WHEN @PolypSize<10 THEN 'ItemLessThan10mm' WHEN @PolypSize BETWEEN 10 AND 20 THEN 'Item10to19mm' ELSE 'Item20OrLargermm' END);

	RETURN ( CASE LOWER(@DetailsType) 
		WHEN 'detected' THEN  CAST(@PolypsDetected AS VARCHAR(5)) 
		WHEN 'retrieved' THEN  CAST(@PolypsRetrieved AS VARCHAR(5)) 
		WHEN 'size' THEN @PolypSizeText 
		ELSE 'invalid parameter: Expected-> Detected or Retrieved Or Size' END);

END
GO

-- #########################################  Stored Procedure: Generate NED xml output for export #########################################
EXEC DropIfExist 'usp_NED_Generate_Report','S';
GO
CREATE PROCEDURE [dbo].[usp_NED_Generate_Report]
(
	@ProcedureId AS INT
)
AS
BEGIN
	SET NOCOUNT ON;

/*
	<xs:schema xmlns="http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd" 
	xmlns:mstns="http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	targetNamespace="http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd" 
	elementFormDefault="qualified" 
	id="SendBatchMessageFile">		

*/
Declare @site AS VARCHAR(50);
DECLARE 
		@description	AS VARCHAR(1000),
		@uniqueid		AS VARCHAR(15),
		@previousLocalProcedureId AS VARCHAR(15),
		@PatientId		AS INT,
		@sessionType	AS VARCHAR(50),
		@operatingHospitalId AS INT,
		@ExportFolderPath AS VARCHAR(100);	--## XML Export Folder path.. Set by Admin in the [ERS_SystemConfig] Table

DECLARE @returnXML XML;

	Set @description = 'NED List';
	SELECT @operatingHospitalId = OperatingHospitalId FROM ERS_Procedures WHERE ProcedureId = @ProcedureId;
	SELECT @site = [NED_HospitalSiteCode], @ExportFolderPath=[NED_ExportPath] FROM [dbo].[ERS_SystemConfig] WHERE OperatingHospitalId = @operatingHospitalId;

	SELECT @uniqueid = RIGHT(('00000' + CAST(@ProcedureId AS VARCHAR(6))),6) --## Procedure Id
							+ RIGHT(('0' + CAST(ProcedureType AS VARCHAR(2))),2)  --## Procedure Type; ie: OGD=1/ERCP=2/COLON=3/FLEXI=13
								+ (CASE ProcedureType	WHEN  1 THEN 'o' 
														WHEN  2 THEN 'e' 
														WHEN  3 THEN 'c'
														WHEN  4 THEN 's'
														WHEN 13 THEN 'f'
									END)	--## Procedure Letter
		 , @sessionType=Case ListType	When 1 Then 'Dedicated Training List' 
										When 2 Then 'Adhoc Training List' 
											   Else 'Service List' End 
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
	, REPLACE(convert(varchar, getdate(), 106), ' ', '/')	AS '@date'	--### '10 Oct 2020' ==> '10/Oct/2020'
	, (CASE WHEN (DATEPART(hour, P.ModifiedOn))<13 THEN 'AM' ELSE 'PM' END)	AS '@time'
	, @sessionType										AS '@type'	-- SessionTypeEnum
	, @site												AS '@site'	--## Hospital Code

	/*	##### Procedure info	*/
	, (
	Select 
		  @uniqueid										AS '@localProcedureId'
		, @previousLocalProcedureId						AS '@previousLocalProcedureId'
		, (CASE P.ProcedureType WHEN 1 THEN 'OGD' WHEN 2 THEN 'ERCP' WHEN 3 THEN 'COLON' WHEN 13 THEN 'FLEXI' WHEN 4 THEN 'FLEXI' END) AS '@procedureName'

		, Case QA.PatDiscomfortEndo		When 6 Then 'Severe' When 5 Then 'Moderate' When 4 Then 'Mild' When 3 Then 'Minimal' When 2 Then 'Comfortable' Else 'Not Specified' End As '@endoscopistDiscomfort'
		, Case QA.PatDiscomfortNurse	When 6 Then 'Severe' When 5 Then 'Moderate' When 4 Then 'Mild' When 3 Then 'Minimal' When 2 Then 'Comfortable' Else 'Not Specified' End As '@nurseDiscomfort'
		, Case BP.BowelPrepQuality	When 1 Then 'inadequate' When 2 Then 'fair' When 3 Then 'good'  WHEN 4 THEN 'excellent' Else 'Not Specified' END As '@bowelPrep'
		, dbo.fnNED_ProcedureExtent(@ProcedureId, 0)					AS '@extent'	--## OverAll Extent info - EE/ER- whoever has gone Furthest distance!!
		, (CASE WHEN Drug.entonox IS NULL THEN 'No' ELSE 'Yes' END)		AS '@entonox'	--## '06/10/2017 UGI - Entonox added
		, (CASE WHEN P.ProcedureType IN (1, 3, 13) THEN (SELECT IsNull(SUM([Detected]), 0) from dbo.tvfNED_PolypsDetailsView(P.ProcedureType, @ProcedureId)) ELSE 0 END)  As '@polypsDetected' --## Applies to OGD, Colon and Flexi.
		, (CASE WHEN P.ProcedureType IN(3,13) THEN (CASE EL.RectalExam When 1 Then 'Yes' When 0 Then 'No' Else NULL End) END)  As '@digitalRectalExamination' -- ers_colon_extentOfIntubation
		, (CASE WHEN P.ProcedureType IN(3,13) THEN (CASE ScopeGuide WHEN 1 THEN 'Yes' ELSE 'No' END) END) AS '@magneticEndoscopeImagerUsed'
		, (CASE WHEN P.ProcedureType IN(3,13) THEN (ISNULL(EL.TimeForWithdrawalMin_Photo, EL.TimeForWithdrawalMin) + (Case When ISNULL(EL.TimeForWithdrawalSec_Photo, EL.TimeForWithdrawalSec) >30 Then 1 Else 0 End)) END	)  As '@scopeWithdrawalTime' --## Applies to Colon only
		/*	##### Patient Info	*/		
		, (CASE Pat.Gender WHEN 'Not Known' THEN 'Unknown' WHEN 'Not Specified' THEN 'Unknown' ELSE Pat.Gender END)		AS 'patient/@gender'
		, DateDiff(YEAR, Pat.[Dateofbirth] , GETDATE()) AS 'patient/@age'
		, (Case P.PatientType	When 1 Then 'Inpatient' 
								When 2 Then 'Outpatient' 
								When 3 Then 'Not Specified' 
			End)											AS 'patient/@admissionType'
		, (CASE P.CategoryListId	WHEN 2 THEN 'Urgent' 
									WHEN 3 THEN 'Emergency' 
									WHEN 1 THEN 'Routine' 
									WHEN 4 THEN 'Surveillance' 
									ELSE 'Not Specified' 
			END)											AS 'patient/@urgencyType'

		/*	##### Drugs	*/
		, IsNull(Drug.pethidine,0)	As 'drugs/@pethidine'	--## Required
		, IsNull(Drug.midazolam,0)	As 'drugs/@midazolam'	--## Req
		, IsNull(Drug.fentanyl,0)	As 'drugs/@fentanyl'	--## Req
		, Drug.buscopan				As 'drugs/@buscopan'	--## Optional; Let the following be NULL
		, Drug.propofol				As 'drugs/@propofol'
		, Drug.flumazenil				As 'drugs/@flumazenil'
		, Drug.noDrugsAdministered	As 'drugs/@noDrugsAdministered'
		/*	##### Staff.Members: 1 Procedure to MANY staff.. So - need a SQL Subquery- to return a RecordSet		*/
		,(
			SELECT 
			  Staff.professionalBodyCode AS '@professionalBodyCode'
			, Staff.EndoscopistRole		AS '@endoscopistRole'
			, Staff.ProcedureRole		AS '@procedureRole'	-- ProcedureRoleTypeEnum
			, Staff.Extent				AS '@extent'
			, (CASE WHEN P.ProcedureType <> 2 THEN Staff.[jManoeuvre] ELSE NULL END)		AS '@jManoeuvre'	-- Opt -- Mandatory for OGD, Colon and Flexi procedures (Rectal retroversion)
			/*	##### Therapeutic = Sesion->Procedure-> Staff.members-> Staff-> Therapeutic; 1 [Staff] to Many [Therapeutic sessions]	*/
			, (
				select 
					   T.NedName	AS '@type'	-- M	--## The type of therapeutic procedure.
					 , CASE WHEN rc.RegionId IS NULL THEN T.[Site] ELSE 'Ileo-colon anastomosis' END		AS '@site'	-- O -- BiopsyEnum  --## The location where the therapeutic procedure was performed.
					 , Staff.ProcedureRole AS '@role' -- O	-- ProcedureRoleTypeEnum
					 , T.polypSize	AS '@polypSize' -- O	-- PolypSizeEnum --## The size of polyp (if found) -> is ONLY for COLON/FLEXI
					 , T.Tattooed	AS '@tattooed'	-- O	-- TattooEnum
					 , T.Performed	AS '@performed'	-- M	-- REQUIRED; INT	-- ## Number performed
					 , T.Successful	AS '@successful' -- M	-- REQUIRED; INT -- Number of successful
					 , T.Retrieved	AS '@retrieved'	-- O	-- INT	-- ## Number of Polyp retrieved -> is ONLY for COLON/FLEXI
					 , T.comment 	AS '@comment'	-- O	--## Use this field to define what “Other” is when selected.

				FROM dbo.tvfNED_ProcedureTherapeutic(P.ProcedureType, @ProcedureId, Staff.ConsultantTypeId) AS T --## Which Consultant's Record in the Procedure?
					LEFT JOIN dbo.ERS_Sites ES ON es.SiteId = T.SiteId
					LEFT JOIN tvfProcedureResectedColon(@ProcedureId) RC ON RC.RegionId = ES.RegionId
				FOR XML PATH('therapeutic'), ROOT('therapeutics'), TYPE
			)/* End of: Therapeutic List- for a Staff Member		*/
			FROM dbo.tvfNED_ProcedureConsultants(@ProcedureId, P.ProcedureType) AS Staff
			WHERE Staff.EndosId > 0
			FOR XML PATH('Staff'), ROOT('staff.members'), TYPE
		)
			
			/*	##### Indications: -- 1 or Many	*/		
			, (
				SELECT 
					  I.NedName As '@indication'
					, i.Comment AS '@comment'
					FROM dbo.tvfNED_ProcedureIndication(@ProcedureId) AS I
					FOR XML PATH('indication'), ROOT('indications'), TYPE
			)
			/*	##### Limitations: Colon/Flexi ONLY		-- 0 or Many	*/
			,(
				Select 	
					  L.Limitation As '@limitation'
					, L.Comment As '@comment'
				from [dbo].[tvfNED_ProcedureLimitation](P.ProcedureType, @ProcedureId) AS L
					FOR XML PATH('limitation'), ROOT('limitations'), TYPE
			)	
			/*	##### Biopsy: 0 or Many		*/ --## For Colon/Flexi/OGD. Not for ERCP!
			, (	SELECT 
						  B.BiopsySite		AS '@biopsySite'
						, B.NumberPerformed AS '@numberPerformed'
					FROM [dbo].[tvfNED_ProcedureBiopsy](p.ProcedureType, @ProcedureId) AS B				
					 FOR XML PATH('Biopsy'), ROOT('biopsies'), TYPE
			)
			/*	##### Diagnoses: 1 or Many		*/ 
			, (	SELECT 
						  D.Ned_Name	AS '@diagnosis'
						, D.tattooed	AS '@tattooed'
						, D.Site		AS '@site'
						, CASE WHEN RIGHT(D.Comment,2)=', ' 
							THEN (LEFT(D.Comment, LEN(D.Comment)-1)) 
							ELSE D.Comment END
									AS '@comment'	--## Remove the extra ',' at the end!
					FROM [dbo].[tvfNED_Diagnoses](@ProcedureId) AS D
					 FOR XML PATH('Diagnose'), ROOT('diagnoses'), TYPE
			)
			/*	##### Adverse events: -- 1 or Many	*/
			,(	SELECT 
					  IsNull(AD.adverseEvent,'None')	As '@adverseEvent'
					, (CASE WHEN AD.adverseEvent = 'Other' THEN AD.Comment END) 						As '@comment'
				FROM dbo.tvfNED_ProcedureAdverseEvents(@ProcedureId)		AS AD
				FOR XML PATH('adverse.event'), ROOT('adverse.events'), TYPE			
			)
		from ERS_Procedures AS P Where P.ProcedureId=@ProcedureId
		FOR XML PATH('procedure'), ROOT('procedures'), TYPE
		)	
		FROM dbo.ERS_Procedures AS P
  INNER JOIN dbo.ERS_VW_Patients			AS Pat  ON P.PatientId=Pat.[PatientId]
   LEFT JOIN dbo.tvfNED_ProcedureDrugList(@ProcedureId)	AS Drug		ON P.ProcedureId = Drug.ProcedureId	
   LEFT JOIN dbo.ERS_UpperGIQA				AS QA   ON P.ProcedureId = QA.ProcedureId	-- Patient DIscomfort
   LEFT JOIN dbo.ERS_BowelPreparation		AS BP   ON P.ProcedureId=BP.ProcedureID	-- DIscomfort for Nurse
   LEFT JOIN dbo.ERS_Sites					AS  S	ON P.ProcedureId = S.SiteId
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
				 ' xmlns="http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd"' AS NS_Info		--## These extra info will be added to the Actual XML file in .NET while exporting;
				 , @xmlFileName AS xmlFileName
				 , IsNull(@xmlPreviousExportFileName, 'x') AS PreviousFileName;

END


--============ NED REPORTs ================

-----------## NED: Audit Log Report

GO




--============ NED REPORTs ================

-----------## NED: Audit Log Report

EXEC DropIfExist 'v_rep_NEDLog', 'V';
GO
CREATE VIEW [dbo].[v_rep_NEDLog]
As
	Select 
		  NL.LogId
		, PT.ProcedureType
		, P.[HospitalNumber] As CNN
		, P.[NHSNo] AS NHS
		, IsNull(P.Forename1+' ','')+IsNull(UPPER(P.Surname),'') As PatientName
		, NL.logDate
		, NL.IsProcessed
		, NL.IsSchemaValid
		, NL.IsSent
		, NL.IsSuccess
		, NL.TimesSent
		, NL.LastUserId
		, LEFT(NL.NEDMessage, 25) + '...' AS ShortMessage
		, NL.NEDMessage
		, '~/Images/icons/notes.png' As imageURL
		, NL.xmlFile, NL.ProcedureID, PT.ProcedureTypeId
 	  From [dbo].[ERS_NedFilesLog] NL
INNER JOIN [dbo].[ERS_Procedures]  PR ON NL.ProcedureID=PR.ProcedureId
INNER JOIN [dbo].[ERS_VW_Patients] P ON PR.PatientId=P.[PatientId]
INNER JOIN [dbo].[ERS_ProcedureTypes] PT ON PR.ProcedureType=PT.ProcedureTypeId

GO

--######## Consultants List- from UGI and ERS sources!
EXEC DropIfExist 'fw_Consultants', 'V';
GO

DECLARE @IncludeUGI BIT = 0
DECLARE @sql NVARCHAR(MAX) = N'';

IF @IncludeUGI = 1

BEGIN
 SET @sql = '
CREATE VIEW [dbo].[fw_Consultants]
AS
SELECT        ''U.'' + CONVERT(varchar(10), CONVERT(int, SubString([Consultant/operator ID], 7, 6))) AS ConsultantId, [Consultant/operator] AS [ConsultantName], 
						 CONVERT(bit, CASE UGI.[IsListConsultant] WHEN - 1 THEN ''TRUE'' ELSE ''FALSE'' END) 
                         AS [IsListConsultant], CONVERT(bit, CASE UGI.[IsEndoscopist1] WHEN - 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsEndoscopist1], CONVERT(bit, 
                         CASE UGI.[IsEndoscopist2] WHEN - 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsEndoscopist2], CONVERT(bit, 
                         CASE UGI.[IsAssistantTrainee] WHEN - 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsAssistantOrTrainee], CONVERT(bit, 
                         CASE UGI.[IsNurse1] WHEN - 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsNurse1], CONVERT(bit, CASE UGI.[IsNurse2] WHEN - 1 THEN ''TRUE'' ELSE ''FALSE'' END) 
                         AS [IsNurse2]
FROM            [Consultant/Operators] UGI
WHERE        CONVERT(int, SubString([Consultant/operator ID], 7, 6)) <> 0
UNION ALL
SELECT        ''E.'' + CONVERT(varchar(10), UserID) AS ConsultantId, ERS.[Title] + '' '' + ERS.[Forename] + '' '' + ERS.[Surname] AS [ConsultantName], 
						 CONVERT(bit, CASE ERS.[IsListConsultant] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) 
                         AS [IsListConsultant], CONVERT(bit, CASE ERS.[IsEndoscopist1] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsEndoscopist1], CONVERT(bit, 
                         CASE ERS.[IsEndoscopist2] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsEndoscopist2], CONVERT(bit, 
                         CASE ERS.[IsAssistantOrTrainee] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsAssistantOrTrainee], CONVERT(bit, 
                         CASE ERS.[IsNurse1] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsNurse1], CONVERT(bit, CASE ERS.[IsNurse2] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) 
                         AS [IsNurse2]
FROM            [dbo].[ERS_Users] ERS'
END
ELSE
BEGIN
	SET @sql = '
CREATE VIEW [dbo].[fw_Consultants]
AS
SELECT        ''E.'' + CONVERT(varchar(10), UserID) AS ConsultantId, ERS.[Title] + '' '' + ERS.[Forename] + '' '' + ERS.[Surname] AS [ConsultantName], 
						 CONVERT(bit, CASE ERS.[IsListConsultant] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) 
                         AS [IsListConsultant], CONVERT(bit, CASE ERS.[IsEndoscopist1] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsEndoscopist1], CONVERT(bit, 
                         CASE ERS.[IsEndoscopist2] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsEndoscopist2], CONVERT(bit, 
                         CASE ERS.[IsAssistantOrTrainee] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsAssistantOrTrainee], CONVERT(bit, 
                         CASE ERS.[IsNurse1] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsNurse1], CONVERT(bit, CASE ERS.[IsNurse2] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) 
                         AS [IsNurse2]
FROM            [dbo].[ERS_Users] ERS'

END
EXEC sp_executesql @sql
GO

--######## Consultants List- Just faking and making a list to be used somewhere else.. Creator: William
EXEC DropIfExist 'fw_ConsultantTypes', 'V';
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

--######## Patients List- Creator: William
EXEC DropIfExist 'fw_Patients', 'V';
GO
CREATE VIEW [dbo].[fw_Patients]
AS
SELECT        p.PatientId, p.HospitalNumber AS CNN, ISNULL(p.Title, '') + (CASE WHEN P.Title IS NULL THEN '' ELSE ' ' END) + ISNULL(p.Forename1, '') 
                         + (CASE WHEN P.Forename1 IS NULL THEN '' ELSE ' ' END) + ISNULL(p.Surname, '') AS PatientName, ISNULL(p.Forename1, '') AS Forename, ISNULL(p.Surname, '') 
                         AS Surname, CONVERT(DateTime, p.[Dateofbirth]) AS DOB, p.[Dateofdeath] AS DOD, p.[NHSNo] AS NHSNo, ISNULL(p.Gender, '?') AS Gender, ISNULL(p.[Postcode], '') 
                         AS PostCode, p.[GPName] AS GPName, p.Telephone AS PhoneNo
FROM            dbo.ERS_VW_PatientswithGP AS P

GO

--######## [Procedures List- All types of Procedures from UGI Tables and Combine with ERS [Procedures] Table Creator: William
EXEC DropIfExist 'fw_Procedures', 'V';
GO

DECLARE @IncludeUGI BIT = 0
DECLARE @sql NVARCHAR(MAX) = N'';

IF @IncludeUGI = 1
BEGIN

SET @sql ='
CREATE VIEW [dbo].[fw_Procedures]
AS
SELECT       E.[Episode no] AS ProcId, ''''U.1.'''' + CONVERT(varchar(10), E.[Episode no]) + ''''.'''' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 1 AS ProcedureTypeId, 
                         ''''U'''' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, 
                         IsNull(PR.[Operating Hospital ID], 0) AS OperatingHospitalId, IsNull(PP_Priority, ''Unspecified'') AS PP_Priority, 
                         CASE PP_PatStatus WHEN ''Outpatient/NHS'' THEN 2 WHEN ''Inpatient/NHS'' THEN 1 ELSE 0 END AS PatientStatusId, 
                         CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''''), ''Outpatient/'', ''''), ''Inpatient/'', '''') = ''NHS'' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
                         PR.DNA
FROM            [Episode] E LEFT OUTER JOIN
                         [Upper GI Procedure] PR ON E.[Episode No] = PR.[Episode No] AND E.[Patient No] = PR.[Patient No]
WHERE        SubString(E.[Status], 1, 1) = 1
UNION ALL
SELECT       E.[Episode no] AS ProcId, ''U.2.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ProcedureTypeId, 
                         ''U'' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, 
                         IsNull(PR.[Operating Hospital ID], 0) AS OperatingHospitalId, IsNull(PP_Priority, ''Unspecified'') AS PP_Priority, 
                         CASE PP_PatStatus WHEN ''Outpatient/NHS'' THEN 2 WHEN ''Inpatient/NHS'' THEN 1 ELSE 0 END AS PatientStatusId, 
                         CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''''), ''Outpatient/'', ''''), ''Inpatient/'', '''') = ''NHS'' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
                         PR.DNA
FROM            [Episode] E LEFT OUTER JOIN
                         [ERCP Procedure] PR ON E.[Episode No] = PR.[Episode No] AND E.[Patient No] = PR.[Patient No]
WHERE        SubString(E.[Status], 2, 1) = 1
UNION ALL
SELECT       E.[Episode no] AS ProcId, ''U.'' + CONVERT(varchar(1), 3 + IsNull
                             ((SELECT        TOP 1 [Procedure type]
                                 FROM            [Colon procedure] CP
                                 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + ''.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), 
                         CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 + IsNull
                             ((SELECT        TOP 1 [Procedure type]
                                 FROM            [Colon procedure] CP
                                 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0) AS ProcedureTypeId, ''U'' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, 
                         CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, IsNull(PR.[Operating Hospital ID], 0) AS OperatingHospitalId, 
                         IsNull(PP_Priority, ''Unspecified'') AS PP_Priority, CASE PP_PatStatus WHEN ''Outpatient/NHS'' THEN 2 WHEN ''Inpatient/NHS'' THEN 1 ELSE 0 END AS PatientStatusId, 
                         CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''''), ''Outpatient/'', ''''), ''Inpatient/'', '''') = ''NHS'' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
                         PR.DNA
FROM            [Episode] E LEFT OUTER JOIN
                         [Colon Procedure] PR ON E.[Episode No] = PR.[Episode No] AND E.[Patient No] = PR.[Patient No]
WHERE        SubString(E.[Status], 3, 1) = 1
UNION ALL
SELECT       E.[Episode no] AS ProcId, ''U.5.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ProcedureTypeId, 
                         ''U'' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, 
                         IsNull(PR.[Operating Hospital ID], 0) AS OperatingHospitalId, IsNull(PP_Priority, ''Unspecified'') AS PP_Priority, 
                         CASE PP_PatStatus WHEN ''Outpatient/NHS'' THEN 2 WHEN ''Inpatient/NHS'' THEN 1 ELSE 0 END AS PatientStatusId, 
                         CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''''), ''Outpatient/'', ''''), ''Inpatient/'', '''') = ''NHS'' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
                         PR.DNA
FROM            [Episode] E LEFT OUTER JOIN
                         [Colon Procedure] PR ON E.[Episode No] = PR.[Episode No] AND E.[Patient No] = PR.[Patient No]
WHERE        SubString(E.[Status], 4, 1) = 1
UNION ALL
SELECT       E.[Episode no] AS ProcId, ''U.6.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ProcedureTypeId, 
                         ''U'' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, 
                         IsNull(PR.[Operating Hospital ID], 0) AS OperatingHospitalId, IsNull(PP_Priority, ''Unspecified'') AS PP_Priority, 
                         CASE PP_PatStatus WHEN ''Outpatient/NHS'' THEN 2 WHEN ''Inpatient/NHS'' THEN 1 ELSE 0 END AS PatientStatusId, 
                         CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''''), ''Outpatient/'', ''''), ''Inpatient/'', '''') = ''NHS'' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
                         PR.DNA
FROM            [Episode] E LEFT OUTER JOIN
                         [Upper GI Procedure] PR ON E.[Episode No] = PR.[Episode No] AND E.[Patient No] = PR.[Patient No]
WHERE        SubString(E.[Status], 5, 1) = 1
UNION ALL
SELECT       E.[Episode no] AS ProcId, ''U.7.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 7 AS ProcedureTypeId, 
                         ''U'' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, 
                         IsNull(PR.[Operating Hospital ID], 0) AS OperatingHospitalId, IsNull(PP_Priority, ''Unspecified'') AS PP_Priority, 
                         CASE PP_PatStatus WHEN ''Outpatient/NHS'' THEN 2 WHEN ''Inpatient/NHS'' THEN 1 ELSE 0 END AS PatientStatusId, 
                         CASE WHEN Replace(Replace(IsNull(PP_PatStatus, ''''), ''Outpatient/'', ''''), ''Inpatient/'', '''') = ''NHS'' THEN 1 ELSE 2 END AS PatientTypeId, PR.PP_Indic, PR.PP_Therapies, 
                         PR.DNA
FROM            [Episode] E LEFT OUTER JOIN
                         [ERCP Procedure] PR ON E.[Episode No] = PR.[Episode No] AND E.[Patient No] = PR.[Patient No]
WHERE        SubString(E.[Status], 6, 1) = 1
UNION ALL
SELECT       E.[Episode no] AS ProcId, ''U.0.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 0 AS ProcedureTypeId, 
                         ''U'' AS AppId, CONVERT(Date, E.[Episode date]) AS CreatedOn, CONVERT(INT, SubString(E.[Patient No], 7, 6)) AS PatientId, E.[Age at procedure] AS Age, 
                         0 AS OperatingHospitalId, ''Unspecified'' AS PP_Priority, 0 AS PatientStatusId, 0 AS PatientTypeId, NULL AS PP_Indic, NULL AS PP_Therapies, NULL AS DNA
FROM            [Episode] E
WHERE        Len(Replace(SUBSTRING([Status], 1, 10), ''0'', '''')) = 0
UNION ALL
SELECT       PR.ProcedureId AS ProcId, ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, PR.ProcedureType AS ProcedureTypeId, ''E'' AS AppId, CONVERT(Date, DateAdded) AS CreatedOn, 
                         PR.PatientId AS PatientId, CONVERT(int, PR.CreatedOn - E.[DateOfBirth]) / 365 AS Age, IsNull(PR.OperatingHospitalID, 0) AS OperatingHospitalId, 
                         IsNull(PP.PP_Priority, ''Unspecified'') AS PP_Priority, 
                         CASE PP.PP_PatStatus WHEN ''Outpatient/NHS'' THEN 2 WHEN ''Inpatient/NHS'' THEN 1 ELSE 0 END AS PatientStatusId, 
                         CASE WHEN Replace(Replace(IsNull(PP.PP_PatStatus, ''''), ''Outpatient/'', ''''), ''Inpatient/'', '''') = ''NHS'' THEN 1 ELSE 2 END AS PatientTypeId, PP.PP_Indic, 
                         PP.PP_Therapies, PR.DNA
FROM            ERS_Procedures PR, ERS_VW_Patients E, dbo.ERS_ProceduresReporting PP
WHERE        PR.PatientId = E.[PatientId] AND PR.ProcedureId = PP.ProcedureId'

END
ELSE
BEGIN
	SET @sql ='
CREATE VIEW [dbo].[fw_Procedures]
AS
SELECT       PR.ProcedureId AS ProcId, ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, PR.ProcedureType AS ProcedureTypeId, ''E'' AS AppId, CONVERT(Date, E.DateAdded) AS CreatedOn, 
                         PR.PatientId AS PatientId, CONVERT(int, PR.CreatedOn - E.[DateOfBirth]) / 365 AS Age, IsNull(PR.OperatingHospitalID, 0) AS OperatingHospitalId, 
                         IsNull(PP.PP_Priority, ''Unspecified'') AS PP_Priority, 
                         CASE PP.PP_PatStatus WHEN ''Outpatient/NHS'' THEN 2 WHEN ''Inpatient/NHS'' THEN 1 ELSE 0 END AS PatientStatusId, 
                         CASE WHEN Replace(Replace(IsNull(PP.PP_PatStatus, ''''), ''Outpatient/'', ''''), ''Inpatient/'', '''') = ''NHS'' THEN 1 ELSE 2 END AS PatientTypeId, PP.PP_Indic, 
                         PP.PP_Therapies, PR.DNA
FROM            ERS_Procedures PR, ERS_VW_Patients E, dbo.ERS_ProceduresReporting PP
WHERE        PR.PatientId = E.[PatientId] AND PR.ProcedureId = PP.ProcedureId'
END

EXEC sp_executesql @sql
GO

--#### End of: View object-> [fw_Procedures]


--######## ProceduresConsultants List- All Consultants from UGI and Combine with ERS [Procedures] Creator: William
EXEC DropIfExist 'fw_ProceduresConsultants', 'V';
GO

DECLARE @IncludeUGI BIT = 0
DECLARE @sql NVARCHAR(MAX) = N'';

IF @IncludeUGI	= 1
BEGIN
	set @sql = 
	'CREATE VIEW [dbo].[fw_ProceduresConsultants]
	AS
	/*OGD*/ SELECT ''U.1.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 
							 1 AS ConsultantTypeId, ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(UP.Endoscopist2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Upper GI Procedure] UP
	WHERE        SubString(E.[Status], 1, 1) = 1 AND E.[Episode No] = Up.[Episode No]
	UNION ALL
	SELECT        ''U.1.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(UP.Endoscopist1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Upper GI Procedure] UP
	WHERE        SubString(E.[Status], 1, 1) = 1 AND E.[Episode No] = Up.[Episode No]
	UNION ALL
	SELECT        ''U.1.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(UP.Assistant1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Upper GI Procedure] UP
	WHERE        SubString(E.[Status], 1, 1) = 1 AND E.[Episode No] = Up.[Episode No]
	UNION ALL
	SELECT        ''U.1.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 4 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(UP.Assistant2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Upper GI Procedure] UP
	WHERE        SubString(E.[Status], 1, 1) = 1 AND E.[Episode No] = Up.[Episode No]
	UNION ALL
	SELECT        ''U.1.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(UP.Nurse1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Upper GI Procedure] UP
	WHERE        SubString(E.[Status], 1, 1) = 1 AND E.[Episode No] = Up.[Episode No]
	UNION ALL
	SELECT        ''U.1.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(UP.Nurse2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Upper GI Procedure] UP
	WHERE        SubString(E.[Status], 1, 1) = 1 AND E.[Episode No] = Up.[Episode No]
	/*ERCP*/ UNION ALL
	SELECT        ''U.2.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 1 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(EP.Endoscopist2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [ERCP Procedure] EP
	WHERE        SubString(E.[Status], 2, 1) = 1 AND EP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.2.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(EP.Endoscopist1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [ERCP Procedure] EP
	WHERE        SubString(E.[Status], 2, 1) = 1 AND EP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.2.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(EP.Assistant1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [ERCP Procedure] EP
	WHERE        SubString(E.[Status], 2, 1) = 1 AND EP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.2.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 4 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(EP.Assistant2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [ERCP Procedure] EP
	WHERE        SubString(E.[Status], 2, 1) = 1 AND EP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.2.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(EP.Nurse1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [ERCP Procedure] EP
	WHERE        SubString(E.[Status], 2, 1) = 1 AND EP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.2.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(EP.Nurse2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [ERCP Procedure] EP
	WHERE        SubString(E.[Status], 2, 1) = 1 AND EP.[Episode No] = E.[Episode No]
	/*COL & SIG*/ UNION ALL
	SELECT        ''U.'' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + ''.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 1 AS ConsultantTypeId, ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist2, 7, 6))) 
							 AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 3, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.'' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + ''.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ConsultantTypeId, ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist1, 7, 6))) 
							 AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 3, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.'' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + ''.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 AS ConsultantTypeId, ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant1, 7, 6))) 
							 AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 3, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.'' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + ''.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 4 AS ConsultantTypeId, ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant2, 7, 6))) 
							 AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 3, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.'' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + ''.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ConsultantTypeId, ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse1, 7, 6))) 
							 AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 3, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.'' + CONVERT(varchar(1), 3 + IsNull
								 ((SELECT        TOP 1 [Procedure type]
									 FROM            [Colon procedure] CP
									 WHERE        CP.[Episode No] = E.[Episode No] AND [Procedure type] <> 2), 0)) + ''.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), 
							 CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ConsultantTypeId, ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse2, 7, 6))) 
							 AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 3, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	/*PRO*/ UNION ALL
	SELECT        ''U.5.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 1 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        ''U.5.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        ''U.5.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        ''U.5.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 4 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        ''U.5.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        ''U.5.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	/*EUS OGD*/ UNION ALL
	SELECT        ''U.6.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 1 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        ''U.6.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        ''U.6.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        ''U.6.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 4 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        ''U.6.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	UNION ALL
	SELECT        ''U.6.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 4, 1) = 1 AND CP.[Episode No] = E.[Episode No] AND CP.[Patient No] = E.[Patient No]
	/*EUS HPB*/ UNION ALL
	SELECT        ''U.7.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 1 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 6, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.7.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 2 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Endoscopist1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 6, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.7.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 3 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 6, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.7.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 4 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Assistant2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 6, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.7.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 5 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse1, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 6, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''U.7.'' + CONVERT(varchar(10), E.[Episode no]) + ''.'' + CONVERT(varchar(10), CONVERT(Int, SubString(E.[Patient No], 7, 6))) AS ProcedureId, 6 AS ConsultantTypeId, 
							 ''U.'' + CONVERT(varchar(10), CONVERT(Int, SubString(CP.Nurse2, 7, 6))) AS ConsultantId
	FROM            [Episode] E, [Colon Procedure] CP
	WHERE        SubString(E.[Status], 6, 1) = 1 AND CP.[Episode No] = E.[Episode No]
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 1 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.Endoscopist1) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.Endoscopist1 IS NOT NULL
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 2 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.Endoscopist2) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.Endoscopist2 IS NOT NULL
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 3 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.Assistant) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.Assistant IS NOT NULL
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 4 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.ListConsultant) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.ListConsultant IS NOT NULL
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 5 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.Nurse2) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.Nurse2 IS NOT NULL
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 6 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.Nurse2) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.Nurse2 IS NOT NULL
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 7 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.Nurse3) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.Nurse3 IS NOT NULL'
END
ELSE
BEGIN
	SET @sql ='
	CREATE VIEW [dbo].[fw_ProceduresConsultants]
	AS
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 1 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.Endoscopist1) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.Endoscopist1 IS NOT NULL
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 2 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.Endoscopist2) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.Endoscopist2 IS NOT NULL
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 3 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.Assistant) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.Assistant IS NOT NULL
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 4 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.ListConsultant) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.ListConsultant IS NOT NULL
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 5 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.Nurse2) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.Nurse2 IS NOT NULL
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 6 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.Nurse2) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.Nurse2 IS NOT NULL
	UNION ALL
	SELECT        ''E.'' + CONVERT(Varchar(10), PR.ProcedureId) AS ProcedureId, 7 AS ConsultantTypeId, ''E.'' + CONVERT(varchar(10), PR.Nurse3) AS ConsultantId
	FROM            ERS_Procedures PR, ERS_VW_Patients E
	WHERE        PR.PatientId = E.[PatientId] AND PR.Nurse3 IS NOT NULL'
END

EXEC sp_executesql @sql
GO
--=====###  End of View object: fw_ProceduresConsultants


--######## ProceduresTypes List- NOT sure if it is in USE! I think i have removed the need of it!  Creator: William
EXEC DropIfExist 'fw_ProceduresTypes', 'V';
GO
CREATE VIEW [dbo].[fw_ProceduresTypes]
AS
SELECT        ProcedureTypeId, ProcedureType
FROM            ERS_ProcedureTypes
UNION
SELECT        ProcedureTypeId = 0, ProcedureType = 'Unknow'

GO

--####### ReportConsultants: Used in ReportAnalysis1
EXEC DropIfExist 'fw_ReportConsultants', 'V';
GO
CREATE VIEW [dbo].[fw_ReportConsultants]
AS
SELECT        UserID, CASE WHEN ConsultantID > 100000 THEN 'U.' + CONVERT(Varchar(10), ConsultantID - 1000000) ELSE 'E.' + CONVERT(Varchar(10), ConsultantID) 
                         END AS ConsultantId, AnonimizedID
FROM            dbo.ERS_ReportConsultants
GO

--####### ReportFilter: used in ReportAnalysis1
EXEC DropIfExist 'fw_ReportFilter', 'V';
GO
CREATE VIEW [dbo].[fw_ReportFilter]
AS
SELECT        UserID, ReportDate, FromDate, ToDate, Anonymise, TypesOfEndoscopists, HideSuppressed
FROM            dbo.ERS_ReportFilter

GO

--####### Therapeutic_Result: Creator: William!
EXEC DropIfExist 'fw_Therapeutic_Result', 'V';
GO
CREATE VIEW [dbo].[fw_Therapeutic_Result]
AS
SELECT        UP.SiteId, UP.TherapeuticID, TT.[Description], TT.NedName, Organ, [role], polypSize, Tattooed, Performed, Successful, Retrieved, comment
FROM            (SELECT        S.SiteId, Organ, NULL [role], CASE WHEN IsNull(L.SessileLargest, 0) > IsNull(L.PedunculatedLargest, 0) THEN IsNull(L.SessileLargest, 0) 
                                                    ELSE CASE WHEN IsNull(L.PedunculatedLargest, 0) > IsNull(L.SubmucosalLargest, 0) THEN IsNull(L.PedunculatedLargest, 0) 
                                                    ELSE IsNull(L.SubmucosalLargest, 0) END END AS polypSize, UT.Marking AS Tattooed, CASE WHEN S.SiteId IS NULL THEN 0 ELSE 1 END Performed, 
                                                    UT.PolypectomyRemoval AS Successful, UT.PolypectomyRemoval + UT.GastrostomyRemoval AS Retrieved, L.Summary AS comment, 
                                                    CASE WHEN UT.ArgonBeamDiathermy = 1 THEN 2 END AS ArgonBeamDiathermy, CASE WHEN UT.BicapElectro = 1 THEN 4 END AS BicapElectro, 
                                                    CASE WHEN UT.BandLigation = 1 THEN 62 END AS BandLigation, CASE WHEN UT.BotoxInjection = 1 THEN 68 END AS BotoxInjection, 
                                                    CASE WHEN UT.Clip = 1 THEN 77 END AS Clip, CASE WHEN UT.CorrectPEGPlacement = 1 THEN 24 END AS CorrectPEGPlacement, 
                                                    CASE WHEN UT.CorrectStentPlacement = 1 THEN 30 END AS CorrectStentPlacement, CASE WHEN UT.Diathermy = 1 THEN 60 END AS Diathermy, 
                                                    CASE WHEN UT.EMR = 1 THEN 64 END AS EMR, CASE WHEN UT.EndoloopPlacement = 1 THEN 72 END AS EndoloopPlacement, 
                                                    CASE WHEN UT.ForeignBody = 1 THEN 15 END AS ForeignBody, CASE WHEN UT.GastrostomyInsertion = 1 THEN 30 END AS GastrostomyInsertion, 
                                                    CASE WHEN UT.GastrostomyRemoval = 1 THEN 31 END AS GastrostomyRemoval, CASE WHEN UT.HeatProbe = 1 THEN 7 END AS HeatProbe, 
                                                    CASE WHEN UT.HotBiopsy = 1 THEN 67 END AS HotBiopsy, CASE WHEN UT.Injection = 1 THEN 68 END AS Injection, 
                                                    CASE WHEN UT.Marking = 1 THEN 16 END AS Marking, CASE WHEN UT.[None] = 1 THEN 1 END AS [None], 
                                                    CASE WHEN UT.OesoDilMedicalReview = 1 THEN 11 END AS OesoDilMedicalReview, CASE WHEN UT.Other = 1 THEN 76 END AS Other, 
                                                    CASE WHEN UT.Polypectomy = 1 THEN 70 END AS Polypectomy, CASE WHEN UT.PyloricDilatation = 1 THEN 28 END AS PyloricDilatation, 
                                                    CASE WHEN UT.RFA = 1 THEN 71 END AS RFA, CASE WHEN UT.StentInsertion = 1 THEN 72 END AS StentInsertion, 
                                                    CASE WHEN UT.StentRemoval = 1 THEN 73 END AS StentRemoval, CASE WHEN UT.VaricealBanding = 1 THEN 74 END AS VaricealBanding, 
                                                    CASE WHEN UT.VaricealSclerotherapy = 1 THEN 74 END AS VaricealSclerotherapy, CASE WHEN UT.YAGLaser = 1 THEN 75 END AS YAGLaser, 
                                                    CASE WHEN T .BrushCytology = 'TRUE' THEN 40 END AS BrushCytology, CASE WHEN T .Polypectomy = 'TRUE' THEN 27 END AS Polypectomy2, 
                                                    CASE WHEN T .HotBiopsy = 'TRUE' THEN 67 END AS HotBiopsy2, CASE WHEN T .[None] = 'TRUE' THEN 1 END AS [None2]
                          FROM            dbo.ERS_Procedures P LEFT OUTER JOIN
                                                    dbo.ERS_Sites S ON P.ProcedureId = S.ProcedureId LEFT OUTER JOIN
                                                    dbo.ERS_UpperGITherapeutics UT ON S.SiteId = UT.SiteId LEFT OUTER JOIN
                                                    --dbo.ERS_ColonTherapeutics CT ON S.SiteId = CT.SiteId LEFT OUTER JOIN
                                                    [dbo].[ERS_Organs] O ON O.RegionId = S.RegionId LEFT OUTER JOIN
                                                    [dbo].[ERS_ColonAbnoLesions] L ON S.SiteId = L.SiteId LEFT OUTER JOIN
                                                    [dbo].[ERS_UpperGISpecimens] T ON S.SiteId = T .SiteId) AS PT UNPIVOT (TherapeuticID FOR Therapies IN (ArgonBeamDiathermy, BicapElectro, 
                         BandLigation, BotoxInjection, Clip, CorrectPEGPlacement, CorrectStentPlacement, EMR, EndoloopPlacement, GastrostomyInsertion, GastrostomyRemoval, Marking, 
                         [None], OesoDilMedicalReview, Other, Polypectomy, PyloricDilatation, StentInsertion, StentRemoval, VaricealBanding, BrushCytology, Polypectomy2, HotBiopsy2, 
                         [None2])) AS UP LEFT OUTER JOIN
                         ERS_TherapeuticTypes TT ON UP.TherapeuticID = TT.Id

GO


--####### Consultants: List of All Consultants, from UGI and ERS tables.... Creator: William!
EXEC DropIfExist 'v_rep_Consultants', 'V';
GO

DECLARE @IncludeUGI BIT = 0
DECLARE @sql NVARCHAR(MAX) = N'';

IF @IncludeUGI = 1
BEGIN
SET @sql = '
CREATE VIEW [dbo].[v_rep_Consultants]
AS
SELECT        1000000 + CONVERT(int, SubString([Consultant/operator ID], 7, 6)) AS ReportID, CONVERT(int, SubString([Consultant/operator ID], 7, 6)) AS ConsultantID, UGIID = CONVERT(int, SubString([Consultant/operator ID], 7, 
                         6)), ERSID = - 1, [Consultant/operator] AS [Consultant], CONVERT(bit, 
                         CASE UGI.[IsListConsultant] WHEN - 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsListConsultant], CONVERT(bit, CASE UGI.[IsEndoscopist1] WHEN - 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsEndoscopist1], 
                         CONVERT(bit, CASE UGI.[IsEndoscopist2] WHEN - 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsEndoscopist2], CONVERT(bit, CASE UGI.[IsAssistantTrainee] WHEN - 1 THEN ''TRUE'' ELSE ''FALSE'' END) 
                         AS [IsAssistantOrTrainee], CONVERT(bit, CASE UGI.[IsNurse1] WHEN - 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsNurse1], CONVERT(bit, CASE UGI.[IsNurse2] WHEN - 1 THEN ''TRUE'' ELSE ''FALSE'' END) 
                         AS [IsNurse2], ''UGI'' AS Release, CASE WHEN [Suppressed] = 0 THEN 1 ELSE 0 END AS Active
FROM            [Consultant/Operators] UGI
WHERE        CONVERT(int, SubString([Consultant/operator ID], 7, 6)) <> 0
UNION
SELECT        UserID AS ReportID, UserID AS ConsultantID, UGIID = - 1, ERSID = UserID, [Title] + '' '' + [Forename] + '' '' + ERS.[Surname] AS [Consultant], CONVERT(bit, CASE ERS.[IsListConsultant] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsListConsultant], CONVERT(bit, CASE ERS.[IsEndoscopist1] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) 
                         AS [IsEndoscopist1], CONVERT(bit, CASE ERS.[IsEndoscopist2] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsEndoscopist2], CONVERT(bit, 
                         CASE ERS.[IsAssistantOrTrainee] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsAssistantOrTrainee], CONVERT(bit, CASE ERS.[IsNurse1] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsNurse1], CONVERT(bit, 
                         CASE ERS.[IsNurse2] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsNurse2], ''ERS'' AS Release, CASE WHEN [Suppressed] = 0 THEN 1 ELSE 0 END AS Active
FROM            [dbo].[ERS_Users] ERS
WHERE        Username NOT IN
                             (SELECT        Surname
                               FROM            [Consultant/Operators])'
END
ELSE
BEGIN
	SET @sql = '
CREATE VIEW [dbo].[v_rep_Consultants]
AS
SELECT        UserID AS ReportID, UserID AS ConsultantID, UGIID = - 1, ERSID = UserID, [Title] + '' '' + [Forename] + '' '' + ERS.[Surname] AS [Consultant], CONVERT(bit, CASE ERS.[IsListConsultant] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsListConsultant], CONVERT(bit, CASE ERS.[IsEndoscopist1] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) 
                         AS [IsEndoscopist1], CONVERT(bit, CASE ERS.[IsEndoscopist2] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsEndoscopist2], CONVERT(bit, 
                         CASE ERS.[IsAssistantOrTrainee] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsAssistantOrTrainee], CONVERT(bit, CASE ERS.[IsNurse1] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsNurse1], CONVERT(bit, 
                         CASE ERS.[IsNurse2] WHEN 1 THEN ''TRUE'' ELSE ''FALSE'' END) AS [IsNurse2], ''ERS'' AS Release, CASE WHEN [Suppressed] = 0 THEN 1 ELSE 0 END AS Active
FROM            [dbo].[ERS_Users] ERS'
END
	
EXEC sp_executesql @sql
GO

--############## 

--################## StoredProc: report_Anonimize-> Required in Report_Analysis1. Creator: William....
EXEC DropIfExist 'report_Anonimize','S';
go
Create Proc [dbo].[report_Anonimize] @UserID INT=NULL, @Randomize BIT=NULL As
Begin
	Declare @N int
	Declare @M int
	Declare @L int
	Declare @ConsultantID int
	If @UserID Is Null
	Begin
		Print 'Needed parameter @UserID'
	End
	Else
	Begin
		If @Randomize='TRUE'
		Begin
			Update ERS_ReportConsultants Set AnonimizedID=0 Where UserID=@UserID
			Declare cr Cursor For
				Select ConsultantID From ERS_ReportConsultants Where UserID=@UserID
			Open cr
			Select @N=Count(*) From ERS_ReportConsultants Where UserID=@UserID
			Fetch Next From cr Into @ConsultantID
			While @@FETCH_STATUS=0
			Begin
				Set @L=1
				While @L=1
				Begin
					Select @M=Convert(int,RAND()*@N)+1
					Print Convert(varchar(10),@ConsultantID)+'-'+Convert(varchar(10),@M)
					Select @L=Count(*) From ERS_ReportConsultants Where UserID=@UserID And AnonimizedID=@M
					If @L=0 Update ERS_ReportConsultants Set AnonimizedID=@M Where UserID=@UserID And ConsultantID=@ConsultantID
				End
				Fetch Next From cr Into @ConsultantID
			End
			Close cr
			Deallocate cr
		End
		Else
		Begin
			Declare cr Cursor For
				Select ConsultantID From ERS_ReportConsultants Where UserID=@UserID
			Open cr
			Select @N=Count(*) From ERS_ReportConsultants Where UserID=@UserID
			Fetch Next From cr Into @ConsultantID
			Set @L=1
			While @@FETCH_STATUS=0
			Begin
				Update ERS_ReportConsultants Set AnonimizedID=@L Where UserID=@UserID And ConsultantID=@ConsultantID
				Set @L=@L+1
				Fetch Next From cr Into @ConsultantID
			End
			Close cr
			Deallocate cr
		End
	End
End
GO

--################## StoredProc: report_ListAnalysis1
EXEC DropIfExist 'report_ListAnalysis1','S';
GO
CREATE Proc [dbo].[report_ListAnalysis1] (
	  @UserID		INT = 1
	, @FromAge		INT = NULL
	, @ToAge		INT = NULL
	, @MinDate	 AS DATE = NULL
	, @MaxDate   AS DATE = NULL
	, @IncludeTherapeutics		BIT = 1
	, @IncludeIndications		BIT = 1
	, @RadioButtonNHS			VARCHAR(3) = 'CNN'
	, @DailyTotalsConsultant	BIT = NULL --## Used for Report Grouping Row Show/Hide
	, @DailyTotals				BIT = NULL --## Used for Report Grouping Row Show/Hide
	, @GrandTotal				BIT = NULL --## Used for Report Grouping Row Show/Hide
--	, @DNA BIT=NULL
	, @OrderBy					VARCHAR(4) = 'ASC'
	, @PatientStatusId			INT = NULL
	, @PatientTypeId			INT = NULL
)  AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Anonymised		BIT,
			@Randomize		BIT,
			@Suppressed		BIT,
			@Scope			VARCHAR(255),
			@ConsultantTypeId INT,
			@FromDate		Date,
			@ToDate			Date,
			@N				INT;

	If Exists (Select * From ERS_ReportConsultants Where UserID=@UserID)
	Begin
		Select @Anonymised=Anonymise, @Randomize=Anonymise, @Suppressed=HideSuppressed
			, @ConsultantTypeId=TypesOfEndoscopists
			, @FromDate = CASE @FromDate WHEN NULL THEN FromDate ELSE @FromDate END
			, @ToDate = CASE @ToDate WHEN NULL THEN ToDate ELSE @ToDate END
		FROM ERS_ReportFilter 
		Where @UserID=@UserID;

		If @Randomize=1 Exec [dbo].[report_Anonimize] @UserID=@UserID, @Randomize=@Randomize;

		Set @Scope='Covering:'
		Set @Scope = @Scope + Case When @MinDate<@FromDate Then ' from '+Convert(varchar(2),datepart(dd,@FromDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
		Set @Scope = @Scope + Case When @MaxDate>@ToDate Then ' to '+Convert(varchar(2),datepart(dd,@ToDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
		
		PRINT '@Scope: ' + @Scope	;

		If @ConsultantTypeId=1 Select @N=Count(*) From fw_Consultants Where IsEndoscopist1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants);
		If @ConsultantTypeId=2 Select @N=Count(*) From fw_Consultants Where IsEndoscopist2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants);
		If @ConsultantTypeId=3 Select @N=Count(*) From fw_Consultants Where IsListConsultant=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants);
		If @ConsultantTypeId=4 Select @N=Count(*) From fw_Consultants Where IsAssistantOrTrainee=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants);
		If @ConsultantTypeId=5 Select @N=Count(*) From fw_Consultants Where IsNurse1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants);
		If @ConsultantTypeId=6 Select @N=Count(*) From fw_Consultants Where IsNurse2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants);

		Set @Scope=@Scope+Case When @N=0 Then ', All consultants' Else ', selected consultants' End;

		PRINT '@ConsultantTypeId: ' + cast(@ConsultantTypeId AS varchar(5));

		Set @Scope = @Scope + Case When IsNull(@FromAge,0)=0 Then '' Else ', older than '+Convert(varchar(10),@FromAge)+' years old ' End;
		
		Set @Scope = @Scope + Case When @ToAge Is Null Then '' Else Case When @ToAge<200 Then ', younger than '+Convert(varchar(10),@ToAge)+' years old ' Else '' End End;
		

		PRINT '@Scope: ' + @Scope	;
				
		Select 
			Case @OrderBy When 'ASC' Then 1.0*Convert(int,Convert(DateTime,PR.CreatedOn)) Else 1.0/Convert(int,Convert(DateTime,PR.CreatedOn)) End As OrderBy
			, PR.CreatedOn
			,DATENAME(weekday, PR.CreatedOn)+' '+Convert(varchar(2),Datepart(dd,PR.CreatedOn))+Case Datepart(dd,PR.CreatedOn) When 1 Then 'st' When 2 Then 'nd' When 3 Then 'rd' Else 'th' End+' '+DATENAME(month,PR.CreatedOn)+' '+DATENAME(year,PR.CreatedOn) As ProcDay
			, PR.ProcedureId
			, CT.ConsultantType
			--, Case When @Anonymised=1 Then 'Anonymised consultant No '+Convert(varchar(10),RC.AnonimizedID) Else C.ConsultantName End As ConsultantName Uncomment to anonymise consultants
			, LTRIM(C.ConsultantName) AS ConsultantName --Comment this line if you comment the previous line
			, Case When SubString(ConsultantType,1,11)='Endoscopist' Then
					(Select CC.ConsultantName From fw_ProceduresConsultants PCC INNER JOIN fw_Consultants CC ON PCC.ConsultantId=CC.ConsultantId And PCC.ProcedureId=PR.ProcedureId WHERE PCC.ConsultantTypeId=3)
				Else
					(Select CC.ConsultantName From fw_ProceduresConsultants PCC INNER JOIN fw_Consultants CC ON PCC.ConsultantId=CC.ConsultantId And PCC.ProcedureId=PR.ProcedureId WHERE PCC.ConsultantTypeId=1)
				End As Assistant
			, Case When 0=1 Then 'Anonymised patient' Else LTRIM(P.PatientName) END +' ('+Convert(varchar(3),PR.Age)+')' As PatientName, Case When @RadioButtonNHS='CNN' Then P.CNN Else P.NHSNo End As PatientId
			, PR.ProcedureTypeId
			, Case When @IncludeIndications=1 Then PP.PP_Indic Else '' End As PP_Indic
			, Case When @IncludeTherapeutics=1 Then PP.PP_Therapies Else '' End As PP_Therapies
			, @Scope As Scope
	From fw_Procedures PR
		INNER JOIN dbo.ERS_ProceduresReporting AS PP ON PR.ProcedureId = 'E.' + convert(varchar(10), PP.ProcedureId)
		--INNER JOIN fw_ProceduresTypes PT ON PR.ProcedureTypeId=PT.ProcedureTypeId
		INNER JOIN fw_ProceduresConsultants PC ON PR.ProcedureId=PC.ProcedureId
		INNER JOIN fw_Consultants C ON PC.ConsultantId=C.ConsultantId
		INNER JOIN fw_ConsultantTypes CT ON PC.ConsultantTypeId=CT.ConsultantTypeId
		INNER JOIN fw_Patients P ON PR.PatientId=P.PatientId
		INNER JOIN fw_ReportConsultants RC ON C.ConsultantId=RC.ConsultantId
		INNER JOIN fw_ReportFilter RF ON RC.UserId=RF.UserId

	Where 1=1
			AND PC.ConsultantTypeId= CASE WHEN RF.TypesOfEndoscopists = 0 THEN PC.ConsultantTypeId ELSE RF.TypesOfEndoscopists END
			And PR.PatientStatusId=IsNull(@PatientStatusId,PR.PatientStatusId)
			And PR.PatientTypeId=IsNull(@PatientTypeId,PR.PatientTypeId)
			And PR.ProcedureTypeId In (1,2,3,4,5,6)
			And RF.UserId=@UserID And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate And PR.Age>=IsNull(@FromAge,0) And PR.Age<=IsNull(@ToAge,200)
		Order By 1--, C.ConsultantName
	End
End

GO

--################## StoredProc: report_ListAnalysis2
EXEC DropIfExist 'report_ListAnalysis2','S';
GO
create Proc [dbo].[report_ListAnalysis2] (
	  @UserID			INT = NULL
	, @FromAge			INT = NULL
	, @ToAge			INT = NULL
	, @DiagVsThera		BIT = NULL
	, @DNA				BIT = NULL
	, @Priority			BIT = NULL
	, @PatientStatusId	INT = NULL
	, @PatientTypeId	INT = NULL
)	As
Begin
	Set NoCount On
	Declare @Anonymised BIT
	Declare @Randomize BIT
	Declare @Suppressed BIT
	Declare @Scope VARCHAR(255)
	Declare @ConsultantTypeId INT
	Declare @FromDate Date
	Declare @ToDate Date
	Declare @N INT
	If Exists (Select * From dbo.ERS_ReportConsultants Where UserID = @UserID)
		Begin
			Select @Anonymised = Anonymise, @Randomize = Anonymise, @Suppressed = HideSuppressed, @ConsultantTypeId = TypesOfEndoscopists, @FromDate = FromDate, @ToDate = ToDate FROM ERS_ReportFilter Where @UserID = @UserID
			If @Randomize = 1 Exec [dbo].[report_Anonimize] @UserID = @UserID, @Randomize = @Randomize
			Declare @MinDate Date
			Declare @MaxDate Date
			Select @MinDate = Min(CreatedOn), @MaxDate = Max(CreatedOn) From fw_Procedures
			Set @Scope = 'Covering:'
			Set @Scope = @Scope+Case When @MinDate<@FromDate Then ' from '+Convert(varchar(2),datepart(dd,@FromDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
			Set @Scope = @Scope+Case When @MaxDate>@ToDate Then ' to '+Convert(varchar(2),datepart(dd,@ToDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
			If @ConsultantTypeId = 1 Select @N = Count(*) From fw_Consultants Where IsEndoscopist1 = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
			If @ConsultantTypeId = 2 Select @N = Count(*) From fw_Consultants Where IsEndoscopist2 = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
			If @ConsultantTypeId = 3 Select @N = Count(*) From fw_Consultants Where IsListConsultant = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
			If @ConsultantTypeId = 4 Select @N = Count(*) From fw_Consultants Where IsAssistantOrTrainee = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
			If @ConsultantTypeId = 5 Select @N = Count(*) From fw_Consultants Where IsNurse1 = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
			If @ConsultantTypeId = 6 Select @N = Count(*) From fw_Consultants Where IsNurse2 = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
			Set @Scope = @Scope+Case When @N = 0 Then ', All consultants' Else ', selected consultants' End
			Set @Scope = @Scope+Case When IsNull(@FromAge,0) = 0 Then '' Else ', older than '+Convert(varchar(10),@FromAge)+' years old ' End
			Set @Scope = @Scope+Case When @ToAge Is Null Then '' Else Case When @ToAge<200 Then ', younger than '+Convert(varchar(10),@ToAge)+' years old ' Else '' End End
			--If @DiagVsThera = 1
			--Begin
																																																																																																																				Select 
			CT.ConsultantType
			--, Case When @Anonymised = 1 Then 'Anonymised consultant No '+Convert(varchar(10),RC.AnonimizedID) Else C.ConsultantName End As ConsultantName Uncomment to anonymise consultants
			--, C.ConsultantName --Comment this line if you comment the previous line
			, 'Diagnostic' As DiagVsThera
			, @Scope As Scope
			, IsNull(Sum(Case When PT.ProcedureTypeId = 1 Then 1 Else 0 End),0) As OGD
			, IsNull(Sum(Case When PT.ProcedureTypeId = 6 Then 1 Else 0 End),0) As EUS
			, IsNull(Sum(Case When PT.ProcedureTypeId = 2 Then 1 Else 0 End),0) As ERC
			, IsNull(Sum(Case When PT.ProcedureTypeId = 7 Then 1 Else 0 End),0) As HPB
			, IsNull(Sum(Case When PT.ProcedureTypeId = 3 Then 1 Else 0 End),0) As COL
			, IsNull(Sum(Case When PT.ProcedureTypeId = 4 Then 1 Else 0 End),0) As SIG
			, IsNull(Sum(Case When PT.ProcedureTypeId = 5 Then 1 Else 0 End),0) As PRO
		From fw_Procedures PR
			INNER JOIN fw_ProceduresTypes PT ON PR.ProcedureTypeId = PT.ProcedureTypeId
			INNER JOIN fw_ProceduresConsultants PC ON PR.ProcedureId = PC.ProcedureId
			INNER JOIN fw_Consultants C ON C.ConsultantId = PC.ConsultantId
			INNER JOIN fw_ConsultantTypes CT ON PC.ConsultantTypeId = CT.ConsultantTypeId
			INNER JOIN fw_ReportFilter RF ON PC.ConsultantTypeId = CASE WHEN RF.TypesOfEndoscopists = 0 THEN PC.ConsultantTypeId ELSE RF.TypesOfEndoscopists END
			INNER JOIN fw_ReportConsultants RC ON C.ConsultantId = RC.ConsultantId
			INNER JOIN fw_Patients P ON P.PatientId = PR.PatientId
		Where RF.UserId = @UserID And PR.CreatedOn> = RF.FromDate And PR.CreatedOn< = RF.ToDate And PR.Age> = IsNull(@FromAge,0) And PR.Age< = IsNull(@ToAge,200)
			And PR.ProcedureTypeId In (1,2,3,4,5,6) -- Change that line to incliude more procedure types
			And PR.PP_Indic Is Not Null
			And PR.PatientStatusId = IsNull(@PatientStatusId,PR.PatientStatusId)
			And PR.PatientTypeId = IsNull(@PatientTypeId,PR.PatientTypeId)
		Group By CT.ConsultantType--, C.ConsultantName
		Union All
		Select 
			CT.ConsultantType
			--, Case When @Anonymised = 1 Then 'Anonymised consultant No '+Convert(varchar(10),RC.AnonimizedID) Else C.ConsultantName End As ConsultantName Uncomment to anonymise consultants
			--, C.ConsultantName --Comment this line if you comment the previous line
			, 'Therapeutic' As DiagVsThera
			, @Scope As Scope
			, IsNull(Sum(Case When PT.ProcedureTypeId = 1 Then 1 Else 0 End),0) As OGD
			, IsNull(Sum(Case When PT.ProcedureTypeId = 6 Then 1 Else 0 End),0) As EUS
			, IsNull(Sum(Case When PT.ProcedureTypeId = 2 Then 1 Else 0 End),0) As ERC
			, IsNull(Sum(Case When PT.ProcedureTypeId = 7 Then 1 Else 0 End),0) As HPB
			, IsNull(Sum(Case When PT.ProcedureTypeId = 3 Then 1 Else 0 End),0) As COL
			, IsNull(Sum(Case When PT.ProcedureTypeId = 4 Then 1 Else 0 End),0) As SIG
			, IsNull(Sum(Case When PT.ProcedureTypeId = 5 Then 1 Else 0 End),0) As PRO
		From fw_Procedures PR
			INNER JOIN fw_ProceduresTypes PT ON PR.ProcedureTypeId = PT.ProcedureTypeId
			INNER JOIN fw_ProceduresConsultants PC ON PR.ProcedureId = PC.ProcedureId
			INNER JOIN fw_Consultants C ON PC.ConsultantId = C.ConsultantId
			INNER JOIN fw_ReportConsultants RC ON C.ConsultantId = RC.ConsultantId
			INNER JOIN fw_ReportFilter RF ON RF.UserId = RC.UserId
			INNER JOIN fw_ConsultantTypes CT ON PC.ConsultantTypeId = CASE WHEN RF.TypesOfEndoscopists = 0 THEN PC.ConsultantTypeId ELSE RF.TypesOfEndoscopists END
			INNER JOIN fw_Patients P ON P.PatientId = PR.PatientId
		Where PC.ConsultantTypeId = CT.ConsultantTypeId 
			And RF.UserId = @UserID And PR.CreatedOn> = RF.FromDate And PR.CreatedOn< = RF.ToDate And PR.Age> = IsNull(@FromAge,0) And PR.Age< = IsNull(@ToAge,200)
			And PR.ProcedureTypeId In (1,2,3,4,5,6) -- Change that line to incliude more procedure types
			--And PR.PP_Therapies Is Not Null /*removed as column is no longer being written to in procedure_summary_update so will always be NULL*/
			And PR.PatientStatusId = IsNull(@PatientStatusId,PR.PatientStatusId)
			And PR.PatientTypeId = IsNull(@PatientTypeId,PR.PatientTypeId)
		Group By CT.ConsultantType--, C.ConsultantName
		Order By 1--, C.ConsultantName
	End
End

GO

--################## StoredProc: report_ListAnalysis2
EXEC DropIfExist 'report_ListAnalysis3','S';
GO
CREATE Proc [dbo].[report_ListAnalysis3] 
	  @UserID INT = NULL
	, @FromAge INT = NULL
	, @ToAge INT = NULL
	, @PatientStatusId INT = NULL
	, @PatientTypeId INT = NULL
	As
Begin
	Set NoCount On
	Declare @Anonymised BIT
	Declare @Randomize BIT
	Declare @Suppressed BIT
	Declare @Scope VARCHAR(255)
	Declare @ConsultantTypeId INT
	Declare @FromDate Date
	Declare @ToDate Date
	Declare @N INT
	If Exists (Select * From ERS_ReportConsultants Where UserID = @UserID)
	Begin
	Select @Anonymised = Anonymise, @Randomize = Anonymise, @Suppressed = HideSuppressed, @ConsultantTypeId = TypesOfEndoscopists, @FromDate = FromDate, @ToDate = ToDate FROM ERS_ReportFilter Where @UserID = @UserID
	If @Randomize = 1 Exec [dbo].[report_Anonimize] @UserID = @UserID, @Randomize = @Randomize
	Declare @MinDate Date
	Declare @MaxDate Date
	Select @MinDate = Min(CreatedOn), @MaxDate = Max(CreatedOn) From fw_Procedures
	Set @Scope = 'Covering:'
	Set @Scope = @Scope+Case When @MinDate<@FromDate Then ' from '+Convert(varchar(2),datepart(dd,@FromDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
	Set @Scope = @Scope+Case When @MaxDate>@ToDate Then ' to '+Convert(varchar(2),datepart(dd,@ToDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
	If @ConsultantTypeId = 1 Select @N = Count(*) From fw_Consultants Where IsEndoscopist1 = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
	If @ConsultantTypeId = 2 Select @N = Count(*) From fw_Consultants Where IsEndoscopist2 = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
	If @ConsultantTypeId = 3 Select @N = Count(*) From fw_Consultants Where IsListConsultant = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
	If @ConsultantTypeId = 4 Select @N = Count(*) From fw_Consultants Where IsAssistantOrTrainee = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
	If @ConsultantTypeId = 5 Select @N = Count(*) From fw_Consultants Where IsNurse1 = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
	If @ConsultantTypeId = 6 Select @N = Count(*) From fw_Consultants Where IsNurse2 = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
	Set @Scope = @Scope+Case When @N = 0 Then ', All consultants' Else ', selected consultants' End
	Set @Scope = @Scope+Case When IsNull(@FromAge,0) = 0 Then '' Else ', older than '+Convert(varchar(10),@FromAge)+' years old ' End
	Set @Scope = @Scope+Case When @ToAge Is Null Then '' Else Case When @ToAge<200 Then ', younger than '+Convert(varchar(10),@ToAge)+' years old ' Else '' End End
	Select 
		PR.PP_Priority
		, CT.ConsultantType
		, @Scope As Scope
		, IsNull(Sum(Case When PT.ProcedureTypeId = 1 Then 1 Else 0 End),0) As OGD
		, IsNull(Sum(Case When PT.ProcedureTypeId = 6 Then 1 Else 0 End),0) As EUS
		, IsNull(Sum(Case When PT.ProcedureTypeId = 2 Then 1 Else 0 End),0) As ERC
		, IsNull(Sum(Case When PT.ProcedureTypeId = 7 Then 1 Else 0 End),0) As HPB
		, IsNull(Sum(Case When PT.ProcedureTypeId = 3 Then 1 Else 0 End),0) As COL
		, IsNull(Sum(Case When PT.ProcedureTypeId = 4 Then 1 Else 0 End),0) As SIG
		, IsNull(Sum(Case When PT.ProcedureTypeId = 5 Then 1 Else 0 End),0) As PRO
	From fw_Procedures PR
		INNER JOIN fw_ProceduresTypes PT ON PR.ProcedureTypeId = PT.ProcedureTypeId
		INNER JOIN fw_ProceduresConsultants PC ON PR.ProcedureId = PC.ProcedureId
		INNER JOIN fw_Consultants C ON C.ConsultantId = PC.ConsultantId
		INNER JOIN fw_ConsultantTypes CT ON PC.ConsultantTypeId = CT.ConsultantTypeId
		INNER JOIN fw_ReportConsultants RC ON C.ConsultantId = RC.ConsultantId
		INNER JOIN fw_ReportFilter RF ON PC.ConsultantTypeId = CASE WHEN RF.TypesOfEndoscopists = 0 THEN PC.ConsultantTypeId ELSE RF.TypesOfEndoscopists END
		INNER JOIN fw_Patients P ON P.PatientId = PR.PatientId
	Where RF.UserId = RC.UserId 
		And RF.UserId = @UserID And PR.CreatedOn> = RF.FromDate And PR.CreatedOn< = RF.ToDate And PR.Age> = IsNull(@FromAge,0) And PR.Age< = IsNull(@ToAge,200)
		And PR.ProcedureTypeId In (1,2,3,4,5,6) -- Change that line to incliude more procedure types
		And PR.PatientStatusId = IsNull(@PatientStatusId,PR.PatientStatusId)
		And PR.PatientTypeId = IsNull(@PatientTypeId,PR.PatientTypeId)
	Group By 
		PR.PP_Priority
		, CT.ConsultantType
	End
End
GO

--################## StoredProc: report_ListAnalysis4
EXEC DropIfExist 'report_ListAnalysis4','S';
GO
CREATE PROC [dbo].[report_ListAnalysis4](
	  @UserID			INT = NULL
	, @FromAge			INT = NULL
	, @ToAge			INT = NULL
	, @PatientStatusId	INT = NULL
	, @PatientTypeId	INT = NULL
)	AS
BEGIN
	SET NOCOUNT ON;

	Declare   @Anonymised	BIT
			, @Randomize	BIT
			, @Suppressed	BIT
			, @Scope		VARCHAR(255)
			, @ConsultantTypeId INT
			, @FromDate		Date
			, @ToDate		Date
			, @N			INT;

	IF EXISTS (Select * From ERS_ReportConsultants Where UserID = @UserID)
	BEGIN
		Select @Anonymised = Anonymise, @Randomize = Anonymise, @Suppressed = HideSuppressed, @ConsultantTypeId = TypesOfEndoscopists, @FromDate = FromDate, @ToDate = ToDate FROM ERS_ReportFilter Where @UserID = @UserID
		If @Randomize = 1 Exec [dbo].[report_Anonimize] @UserID = @UserID, @Randomize = @Randomize
		
		Declare @MinDate Date, @MaxDate Date;

		Select @MinDate = Min(CreatedOn), @MaxDate = Max(CreatedOn) From fw_Procedures		
		
		Set @Scope = 'Covering: ' + Case When @MinDate<@FromDate Then ' from '+Convert(varchar(2),datepart(dd,@FromDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
		
		Set @Scope = @Scope+Case When @MaxDate>@ToDate Then ' to '+Convert(varchar(2),datepart(dd,@ToDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
		
		If @ConsultantTypeId = 1 Select @N = Count(*) From fw_Consultants Where IsEndoscopist1 = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
		If @ConsultantTypeId = 2 Select @N = Count(*) From fw_Consultants Where IsEndoscopist2 = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
		If @ConsultantTypeId = 3 Select @N = Count(*) From fw_Consultants Where IsListConsultant = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
		If @ConsultantTypeId = 4 Select @N = Count(*) From fw_Consultants Where IsAssistantOrTrainee = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
		If @ConsultantTypeId = 5 Select @N = Count(*) From fw_Consultants Where IsNurse1 = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
		If @ConsultantTypeId = 6 Select @N = Count(*) From fw_Consultants Where IsNurse2 = 1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
		
		Set @Scope = @Scope+Case When @N = 0 Then ', All consultants' Else ', selected consultants' End
		
		Set @Scope = @Scope+Case When IsNull(@FromAge,0) = 0 Then '' Else ', older than '+Convert(varchar(10),@FromAge)+' years old ' End
		
		Set @Scope = @Scope+Case When @ToAge Is Null Then '' Else Case When @ToAge<200 Then ', younger than '+Convert(varchar(10),@ToAge)+' years old ' Else '' End End
		
		Select 
			 CT.ConsultantType
			--, C.ConsultantName
			, @Scope As Scope
			, IsNull(Sum(Case When PT.ProcedureTypeId = 1 Then 1 Else 0 End),0) As OGD
			, IsNull(Sum(Case When PT.ProcedureTypeId = 6 Then 1 Else 0 End),0) As EUS
			, IsNull(Sum(Case When PT.ProcedureTypeId = 2 Then 1 Else 0 End),0) As ERC
			, IsNull(Sum(Case When PT.ProcedureTypeId = 7 Then 1 Else 0 End),0) As HPB
			, IsNull(Sum(Case When PT.ProcedureTypeId = 3 Then 1 Else 0 End),0) As COL
			, IsNull(Sum(Case When PT.ProcedureTypeId = 4 Then 1 Else 0 End),0) As SIG
			, IsNull(Sum(Case When PT.ProcedureTypeId = 5 Then 1 Else 0 End),0) As PRO
		From fw_Procedures PR
			INNER JOIN fw_ProceduresTypes PT ON PR.ProcedureTypeId = PT.ProcedureTypeId
			INNER JOIN fw_ProceduresConsultants PC ON PR.ProcedureId = PC.ProcedureId
			INNER JOIN fw_Consultants C ON C.ConsultantId = PC.ConsultantId
			INNER JOIN fw_ConsultantTypes CT ON PC.ConsultantTypeId = CT.ConsultantTypeId
			INNER JOIN fw_ReportFilter RF ON PC.ConsultantTypeId = RF.TypesOfEndoscopists
			INNER JOIN fw_ReportConsultants RC ON C.ConsultantId = RC.ConsultantId
			INNER JOIN fw_Patients P ON P.PatientId = PR.PatientId
		Where RF.UserId = RC.UserId
			And RF.UserId = @UserID And PR.CreatedOn> = RF.FromDate And PR.CreatedOn< = RF.ToDate And PR.Age> = IsNull(@FromAge,0) And PR.Age< = IsNull(@ToAge,200)
			And PR.ProcedureTypeId In (1,2,3,4,5,6) -- Change that line to include more procedure types
			And PR.PatientStatusId = IsNull(@PatientStatusId,PR.PatientStatusId)
			And PR.PatientTypeId = IsNull(@PatientTypeId,PR.PatientTypeId)
		Group By 
			/*C.ConsultantName,*/ CT.ConsultantType
	End
End

GO

--################## StoredProc: report_ListAnalysis4
EXEC DropIfExist 'report_ListAnalysis5','S';
GO
Create Proc [dbo].[report_ListAnalysis5](
	  @UserID			INT = NULL
	, @FromAge			INT = NULL
	, @ToAge			INT = NULL
	, @PatientStatusId	INT = NULL
	, @PatientTypeId	INT = NULL
)	As
Begin
	SET NOCOUNT ON;

	Declare   @Anonymised	BIT
			, @Randomize	BIT
			, @Suppressed	BIT
			, @Scope		VARCHAR(255)
			, @ConsultantTypeId INT
			, @FromDate		Date
			, @ToDate		Date
			, @N			INT
			, @ConsultantType NVARCHAR(128);

	IF EXISTS (Select UserID From ERS_ReportConsultants Where UserID=@UserID)
	Begin
		Select @Anonymised=Anonymise, @Randomize=Anonymise, @Suppressed=HideSuppressed, @ConsultantTypeId=TypesOfEndoscopists, @FromDate=FromDate, @ToDate=ToDate FROM ERS_ReportFilter Where @UserID=@UserID
		If @Randomize=1 Exec [dbo].[report_Anonimize] @UserID=@UserID, @Randomize=@Randomize
		Declare @MinDate Date
		Declare @MaxDate Date
		Select @MinDate=Min(CreatedOn), @MaxDate=Max(CreatedOn) From fw_Procedures
		Set @Scope='Covering:'
		Set @Scope=@Scope+Case When @MinDate<@FromDate Then ' from '+Convert(varchar(2),datepart(dd,@FromDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
		Set @Scope=@Scope+Case When @MaxDate>@ToDate Then ' to '+Convert(varchar(2),datepart(dd,@ToDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
		If @ConsultantTypeId=1 Set @ConsultantType='Endoscopist 1'--Select @N=Count(*) From fw_Consultants Where IsEndoscopist1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
		If @ConsultantTypeId=2 Set @ConsultantType='Endoscopist 2'--Select @N=Count(*) From fw_Consultants Where IsEndoscopist2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
		If @ConsultantTypeId=3 Set @ConsultantType='List Consultant'--Select @N=Count(*) From fw_Consultants Where IsListConsultant=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
		If @ConsultantTypeId=4 Set @ConsultantType='Assistant'--Select @N=Count(*) From fw_Consultants Where IsAssistantOrTrainee=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
		If @ConsultantTypeId=5 Set @ConsultantType='Nurse 1'--Select @N=Count(*) From fw_Consultants Where IsNurse1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
		If @ConsultantTypeId=6 Set @ConsultantType='Nurse 2'--Select @N=Count(*) From fw_Consultants Where IsNurse2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
		Set @Scope=@Scope+Case When @N=0 Then ', All consultants' Else ', selected consultants' End
		Set @Scope=@Scope+Case When IsNull(@FromAge,0)=0 Then '' Else ', older than '+Convert(varchar(10),@FromAge)+' years old ' End
		Set @Scope=@Scope+Case When @ToAge Is Null Then '' Else Case When @ToAge<200 Then ', younger than '+Convert(varchar(10),@ToAge)+' years old ' Else '' End End
		Select 
			TT.Description
			,TT.NedName
			, @ConsultantType As ConsultantType
			, @Scope As Scope
			, IsNull(Sum(Case When PR.ProcedureTypeId In (1,2,3,4,5,6) Then
				Case When PR.PatientTypeId=IsNull(@PatientTypeId,PR.PatientTypeId) Then 
					Case When PR.PatientStatusId=IsNull(@PatientStatusId,PR.PatientStatusId) Then
						Case When PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate And PR.Age>=IsNull(@FromAge,0) And PR.Age<=IsNull(@ToAge,200) Then 1 
						Else 0 End
					Else 0 End 
				Else 0 End 
				Else 0 End
				),0) As ProcCount
		From ERS_TherapeuticTypes TT
			LEFT OUTER JOIN fw_Therapeutic T ON TT.ID=T.TherapeuticID
			LEFT OUTER JOIN fw_Sites S ON T.SiteId=S.SiteId
			LEFT OUTER JOIN fw_Procedures PR ON S.ProcedureId=PR.ProcedureId
			LEFT OUTER JOIN fw_ProceduresConsultants PC ON PC.ProcedureId=PR.ProcedureId
			LEFT OUTER JOIN fw_ConsultantTypes CT ON PC.ConsultantTypeId=CT.ConsultantTypeId
			LEFT OUTER JOIN fw_ReportConsultants RC ON PC.ConsultantId=RC.ConsultantId
			LEFT OUTER JOIN fw_ReportFilter RF ON RF.UserId=RC.UserId And RF.UserId=@UserID
		Where TT.Description <>'None' And PR.CreatedOn IS NOT NULL
		Group By 
			TT.Description, TT.NedName
		Order By 1 DESC, 2
	End
End

GO


If object_id('[dbo].[CompareXml]') is not null Drop Function [dbo].[CompareXml]
GO

EXEC DropIfExist 'CompareXml', 'F';
GO

CREATE FUNCTION [dbo].[CompareXml]
(
    @xml1 XML,
    @xml2 XML
)
RETURNS INT
AS 
BEGIN
	--Source: http://stackoverflow.com/questions/9013680/t-sql-how-can-i-compare-two-variables-of-type-xml-when-length-varcharmax
    DECLARE @ret INT
    SELECT @ret = 0

    -- -------------------------------------------------------------
    -- If one of the arguments is NULL then we assume that they are
    -- not equal. 
    -- -------------------------------------------------------------
    IF @xml1 IS NULL OR @xml2 IS NULL 
    BEGIN
        RETURN 1
    END

    -- -------------------------------------------------------------
    -- Match the name of the elements 
    -- -------------------------------------------------------------
    IF  (SELECT @xml1.value('(local-name((/*)[1]))','VARCHAR(MAX)')) 
        <> 
        (SELECT @xml2.value('(local-name((/*)[1]))','VARCHAR(MAX)'))
    BEGIN
        RETURN 1
    END

     ---------------------------------------------------------------
     --Match the value of the elements
     ---------------------------------------------------------------
    IF((@xml1.query('count(/*)').value('.','INT') = 1) AND (@xml2.query('count(/*)').value('.','INT') = 1))
    BEGIN
    DECLARE @elValue1 VARCHAR(MAX), @elValue2 VARCHAR(MAX)

    SELECT
        @elValue1 = @xml1.value('((/*)[1])','VARCHAR(MAX)'),
        @elValue2 = @xml2.value('((/*)[1])','VARCHAR(MAX)')

    IF  @elValue1 <> @elValue2
    BEGIN
        RETURN 1
    END
    END

    -- -------------------------------------------------------------
    -- Match the number of attributes 
    -- -------------------------------------------------------------
    DECLARE @attCnt1 INT, @attCnt2 INT
    SELECT
        @attCnt1 = @xml1.query('count(/*/@*)').value('.','INT'),
        @attCnt2 = @xml2.query('count(/*/@*)').value('.','INT')

    IF  @attCnt1 <> @attCnt2 BEGIN
        RETURN 1
    END

    -- -------------------------------------------------------------
    -- Match the attributes of attributes 
    -- Here we need to run a loop over each attribute in the 
    -- first XML element and see if the same attribut exists
    -- in the second element. If the attribute exists, we
    -- need to check if the value is the same.
    -- -------------------------------------------------------------
    DECLARE @cnt INT, @cnt2 INT
    DECLARE @attName VARCHAR(MAX)
    DECLARE @attValue VARCHAR(MAX)

    SELECT @cnt = 1

    WHILE @cnt <= @attCnt1 
    BEGIN
        SELECT @attName = NULL, @attValue = NULL
        SELECT
            @attName = @xml1.value(
                'local-name((/*/@*[sql:variable("@cnt")])[1])', 
                'varchar(MAX)'),
            @attValue = @xml1.value(
                '(/*/@*[sql:variable("@cnt")])[1]', 
                'varchar(MAX)')

        -- check if the attribute exists in the other XML document
        IF @xml2.exist(
                '(/*/@*[local-name()=sql:variable("@attName")])[1]'
            ) = 0
        BEGIN
            RETURN 1
        END

        IF  @xml2.value(
                '(/*/@*[local-name()=sql:variable("@attName")])[1]', 
                'varchar(MAX)')
            <>
            @attValue
        BEGIN
            RETURN 1
        END

        SELECT @cnt = @cnt + 1
    END

    -- -------------------------------------------------------------
    -- Match the number of child elements 
    -- -------------------------------------------------------------
    DECLARE @elCnt1 INT, @elCnt2 INT
    SELECT
        @elCnt1 = @xml1.query('count(/*/*)').value('.','INT'),
        @elCnt2 = @xml2.query('count(/*/*)').value('.','INT')
    IF  @elCnt1 <> @elCnt2
    BEGIN
        RETURN 1
    END

    -- -------------------------------------------------------------
    -- Start recursion for each child element
    -- -------------------------------------------------------------
    SELECT @cnt = 1
    SELECT @cnt2 = 1
    DECLARE @x1 XML, @x2 XML
    DECLARE @noMatch INT

    WHILE @cnt <= @elCnt1 
    BEGIN

        SELECT @x1 = @xml1.query('/*/*[sql:variable("@cnt")]')
    --RETURN CONVERT(VARCHAR(MAX),@x1)
    WHILE @cnt2 <= @elCnt2
    BEGIN
        SELECT @x2 = @xml2.query('/*/*[sql:variable("@cnt2")]')
        SELECT @noMatch = dbo.CompareXml( @x1, @x2 )
        IF @noMatch = 0 BREAK
        SELECT @cnt2 = @cnt2 + 1
    END

    SELECT @cnt2 = 1

        IF @noMatch = 1
        BEGIN
            RETURN 1
        END

        SELECT @cnt = @cnt + 1
    END

    RETURN @ret
END
GO

    ---------------------------------------------------------------
    -----------------fnPatientsPercentile50------------------------
    ---------------------------------------------------------------

	EXEC DropIfExist 'fnPatientsPercentile50', 'F';
GO

CREATE FUNCTION [dbo].[fnPatientsPercentile50] (@DrugName NVARCHAR(20)=NULL, @PatientId NVARCHAR(20)=NULL)
	Returns FLOAT
AS
BEGIN
	DECLARE @N INT
	DECLARE @I INT
	DECLARE @Dose NUMERIC(20,2)
	SELECT @N=Count(*) FROM [dbo].[fw_Premedication] PM 
		INNER JOIN fw_Procedures PR ON PR.ProcedureId=PM.ProcedureId
	 WHERE DrugName=@DrugName And PR.PatientId=@PatientId
	IF @DrugName IS NULL RETURN (NULL)
	IF @N=0 RETURN (0)
	IF @N=1
	BEGIN
		SELECT @Dose=PM.Dose FROM [dbo].[fw_Premedication] PM 
			INNER JOIN fw_Procedures PR ON PR.ProcedureId=PM.ProcedureId
			WHERE DrugName=@DrugName And PR.PatientId=@PatientId
		RETURN (@Dose)
	END
	ELSE
	BEGIN
		IF @N % 2=0
		BEGIN
			SET @I=@N/2
			SELECT @Dose=AVG(Dose) FROM
			(
			SELECT ROW_NUMBER() OVER (PARTITION BY PM.DrugName ORDER BY PM.Dose) As RowNo, PM.Dose FROM [dbo].[fw_Premedication] PM 
				INNER JOIN fw_Procedures PR ON PR.ProcedureId=PM.ProcedureId
			 WHERE DrugName=@DrugName And PR.PatientId=@PatientId
				) AS L1 WHERE RowNo>=@I And RowNo<=(@I+1)
		END
		ELSE
		BEGIN
			SET @I=@N/2 +1
			SELECT @Dose=Dose FROM
			(
			SELECT ROW_NUMBER() OVER (PARTITION BY DrugName ORDER BY Dose) As RowNo, Dose FROM [dbo].[fw_Premedication] PM 
				INNER JOIN fw_Procedures PR ON PR.ProcedureId=PM.ProcedureId
			 WHERE DrugName=@DrugName And PR.PatientId=@PatientId
				) AS L1 WHERE RowNo=@I
		END
	END
	RETURN (CONVERT(Numeric(20,2),@Dose))
END
GO




---------------------------------------------------------------
------------------------fnPremedication------------------------
---------------------------------------------------------------


EXEC DropIfExist 'fnPremedication', 'F';
GO

CREATE FUNCTION [dbo].[fnPremedication] (@ProcedureId NVARCHAR(20))
	Returns NVARCHAR(max)
AS
Begin
	DECLARE @XMLlist XML
	DECLARE @summary VARCHAR(MAX)
	DECLARE @ra VARCHAR(MAX)
	SELECT TOP 1 @ra=CASE WHEN Dose = 0 THEN '' ELSE CONVERT(VARCHAR,Dose)+' ' END + CASE WHEN Units = '' THEN '' ELSE Units+' ' END + Drugname FROM [dbo].[fw_Premedication] WHERE ProcedureId=@ProcedureId And IsReversingAgent=1
	IF (SELECT COUNT(*) FROM [dbo].[fw_Premedication] WHERE ProcedureId=@ProcedureId) > 0
	BEGIN
		SET @XMLlist = (SELECT CASE WHEN Dose = 0 THEN '' ELSE CONVERT(VARCHAR,Dose)+' ' END +
								CASE WHEN Units = '' THEN '' ELSE Units+' ' END + Drugname FROM [dbo].[fw_Premedication] WHERE IsReversingAgent=0 FOR XML  RAW, ELEMENTS, TYPE)
		SET @Summary = dbo.fnBuildString(@XMLlist) 
	END
	IF @ra<>'' SET @Summary=@ra+' ('+@Summary+')'
	RETURN @Summary
End
GO


---------------------------------------------------------------
------------------------fnComplication------------------------
---------------------------------------------------------------


EXEC DropIfExist 'fnComplication', 'F';
GO

CREATE FUNCTION [dbo].[fnComplication] (@ProcedureId NVARCHAR(20))
	Returns NVARCHAR(max)
AS
Begin
	DECLARE @XMLlist XML
	DECLARE @summary VARCHAR(MAX)
	IF (SELECT COUNT(*) FROM [dbo].[fw_Complications] WHERE ProcedureId=@ProcedureId) > 0
	BEGIN
		SET @XMLlist = (SELECT Complication FROM [dbo].[fw_Complications]  WHERE ProcedureId=@ProcedureId FOR XML  RAW, ELEMENTS, TYPE)
		SET @Summary = dbo.fnBuildString(@XMLlist) 
	END
	RETURN @Summary
End
GO


---------------------------------------------------------------
------------------------fnDrugsPercentile50--------------------
---------------------------------------------------------------


EXEC DropIfExist 'fnDrugsPercentile50', 'F';
GO

CREATE FUNCTION [dbo].[fnDrugsPercentile50] (@DrugName NVARCHAR(20), @ProcedureId NVARCHAR(20))
	Returns FLOAT
AS
BEGIN
	DECLARE @N INT
	DECLARE @I INT
	DECLARE @Dose NUMERIC(20,2)
	SELECT @N=Count(*) FROM [dbo].[fw_Premedication] WHERE DrugName=@DrugName And ProcedureId=@ProcedureId
	IF @N=0 RETURN (0)
	IF @N=1
	BEGIN
		SELECT @Dose=Dose FROM [dbo].[fw_Premedication] WHERE DrugName=@DrugName And ProcedureId=@ProcedureId
		RETURN (@Dose)
	END
	ELSE
	BEGIN
		IF @N % 2=0
		BEGIN
			SET @I=@N/2
			SELECT @Dose=AVG(Dose) FROM
			(
			SELECT ROW_NUMBER() OVER (PARTITION BY DrugName ORDER BY Dose) As RowNo, Dose FROM [dbo].[fw_Premedication]
				WHERE DrugName=@DrugName And ProcedureId=@ProcedureId
				) AS L1 WHERE RowNo>=@I And RowNo<=(@I+1)
		END
		ELSE
		BEGIN
			SET @I=@N/2 +1
			SELECT @Dose=Dose FROM
			(
			SELECT ROW_NUMBER() OVER (PARTITION BY DrugName ORDER BY Dose) As RowNo, Dose FROM [dbo].[fw_Premedication]
				WHERE DrugName=@DrugName --And ProcedureId=@ProcedureId
				) AS L1 WHERE RowNo=@I
		END
	END
	RETURN (CONVERT(Numeric(20,2),@Dose))
END
GO


---------------------------------------------------------------
------------------------ERS_ReportTherapy----------------------
---------------------------------------------------------------


EXEC DropIfExist 'ERS_ReportTherapy', 'T';
GO

/* [dbo].[ERS_ReportTherapy] */
CREATE TABLE [dbo].[ERS_ReportTherapy] ( TherapyId INT, Therapy VARCHAR(100) ) 
GO

/* Insert Into [dbo].[ERS_ReportTherapy] */
Insert Into ERS_ReportTherapy (TherapyId, Therapy) VALUES (1,'Anastomosis'), (2,'Other'), (3,'Argon beam photocoagulation'), (4,'Balloon dilation'), (5,'Banding of haemorrhoid'), (6,'Clip placement'), (7,'Endoloop placement'), (8,'Foreign body removal'), (9,'Injection therapy'), (10,'Marking / tattooing'), (11,'Polyp - cold biopsy'), (12,'Polyp - EMR'), (13,'Polyp - ESD'), (14,'Polyp - hot biopsy'), (15,'Polyp - snare cold'), (16,'Polyp - snare hot'), (17,'Stent change'), (18,'Stent placement'), (19,'Stent removal'), (20,'YAG laser'), (21,'Balloon trawl'), (22,'Bougie dilation'), (23,'Brush cytology'), (24,'Cannulation'), (25,'Combined (rendezvous) proc'), (26,'Diagnostic cholangiogram'), (27,'Diagnostic pancreatogram'), (28,'Endoscopic cyst puncture'), (29,'Haemostasis'), (30,'Manometry'), (31,'Nasopancreatic / bilary drain'), (32,'Sphincterotomy'), (33,'Stent placement - CBD'), (34,'Stent placement - pancreas'), (35,'Stone extraction >=10mm'), (36,'Stone extraction <10mm'), (37,'Band ligation'), (38,'Botox injection'), (39,'EMR'), (40,'ESD'), (41,'Heater probe'), (42,'Hot biopsy'), (43,'PEG change'), (44,'PEG placement'), (45,'PEG removal'), (46,'Polypectomy'), (47,'Radio frequency ablation'), (48,'Variceal sclerotherapy') 
GO

EXEC DropConstraint 'ERS_Report', 'ERS_ReportGroup.FK.ReportID';
GO
EXEC DropConstraint 'ERS_Report', 'ERS_ReportGroupColumn.FK.ReportID';
GO
EXEC DropConstraint 'ERS_Report', 'ERS_ReportPopup.FK.ReportID';
GO
EXEC DropConstraint 'ERS_ReportCategory', 'ERS_ERS_ReportCategory.PK.ERS_ReportCategory';
GO
EXEC DropConstraint 'ERS_ReportCategory', 'ERS_Report.FK.ReportCategoryID';
GO
EXEC DropConstraint 'ERS_ReportTarget', 'ERS_Report.FK.ReportTargetID';
GO
EXEC DropConstraint 'ERS_ReportGroup', 'ERS_ReportGroupColumn.FK.ReportGroupID';
GO
EXEC DropConstraint 'ERS_ReportGroupColumn', 'ERS_ReportPopup.FK.ReportGroupColumnID';
GO

EXEC DropIfExist 'ERS_ReportPopup', 'T';
GO
EXEC DropIfExist 'ERS_ReportGroupColumn', 'T';
GO
EXEC DropIfExist 'ERS_ReportColumn', 'T';
GO
EXEC DropIfExist 'ERS_ReportGroup', 'T';
GO
EXEC DropIfExist 'ERS_Report', 'T';
GO
EXEC DropIfExist 'ERS_ReportCategory', 'T';
GO
EXEC DropIfExist 'ERS_ReportTarget', 'T';
GO

---------------------------------------------------------------
------------------------ERS_ReportTarget-----------------------
---------------------------------------------------------------

CREATE TABLE [dbo].[ERS_ReportTarget](
	[ReportTargetID] [varchar](128) NOT NULL,
	CONSTRAINT [ERS_ReportTarget.PK.ReportTarget] PRIMARY KEY CLUSTERED ([ReportTargetID]),
	[ReportTargetName] [varchar](128) NOT NULL,
	[Modal] [bit] NOT NULL DEFAULT ('TRUE'),
	[StatusBar] [bit] NOT NULL DEFAULT ('FALSE'),
	[Width] [int] NULL,
	[Height] [int] NULL,
	[Left] [int] NULL,
	[Top] [int] NULL,
)
GO

---------------------------------------------------------------
------------------------ERS_ReportCategory---------------------
---------------------------------------------------------------

CREATE TABLE [dbo].[ERS_ReportCategory](
	[ReportCategoryID] [varchar](128) NOT NULL,
	CONSTRAINT [ERS_ERS_ReportCategory.PK.ERS_ReportCategory] PRIMARY KEY CLUSTERED ([ReportCategoryID]),
	[CategoryName] [varchar](128) NOT NULL,
	[Enabled] [bit] NOT NULL DEFAULT 'TRUE',
)
GO

---------------------------------------------------------------
------------------------ERS_Report-----------------------------
---------------------------------------------------------------

CREATE TABLE [dbo].[ERS_Report](
	[ReportID] [varchar](32) NOT NULL,
	CONSTRAINT [ERS_Reports.PK.ReportID] PRIMARY KEY CLUSTERED ([ReportID]),
	[ReportName] [varchar](128) NOT NULL ,
	[ReportCategoryID] [varchar](128) NOT NULL,
	CONSTRAINT [ERS_Report.FK.ReportCategoryID] FOREIGN KEY([ReportCategoryID]) REFERENCES [dbo].[ERS_ReportCategory] ([ReportCategoryID]),
	[ReportTargetID] [varchar](128) NOT NULL,
	CONSTRAINT [ERS_Report.FK.ReportTargetID] FOREIGN KEY([ReportTargetID]) REFERENCES [dbo].[ERS_ReportTarget] ([ReportTargetID]),
	[ReportTitle] [varchar](128) NOT NULL,
	[Parameters] [varchar](255) NULL DEFAULT ('rowID, columnName'),
	[Text] [varchar](128) NOT NULL DEFAULT (''),
	[ToolTip] [varchar](128) NOT NULL DEFAULT (''),
	[BackColor] [varchar](20) NULL,
	[ForeColor] [varchar](20) NULL,
	[ImageUrl] [varchar](128) NULL,
	[SortOrder] [int] NULL DEFAULT 0,
	[Enabled] [bit] NOT NULL DEFAULT 'TRUE',
	[ReportQuery] [varchar](8000) NULL,
)
GO


---------------------------------------------------------------
------------------------ERS_ReportGroup------------------------
---------------------------------------------------------------

CREATE TABLE [dbo].[ERS_ReportGroup](
	[ReportGroupID] [varchar](3) NOT NULL,
	CONSTRAINT [ERS_ReportGroup.PK.ReportGroupID] PRIMARY KEY CLUSTERED ([ReportGroupID]),
 	[ReportGroupName] [varchar](128) NOT NULL,
	CONSTRAINT [ERS_ReportGroup.UNIQUE.ReportGroupName] UNIQUE NONCLUSTERED ([ReportGroupName]),
	[Parameters] [varchar](255) NULL DEFAULT ('UserID'),
	[ReportID] [varchar](32) NOT NULL,
	CONSTRAINT [ERS_ReportGroup.FK.ReportID] FOREIGN KEY([ReportID]) REFERENCES [dbo].[ERS_Report] ([ReportID]),
)
GO


---------------------------------------------------------------
------------------------ERS_ReportColumn-----------------------
---------------------------------------------------------------

CREATE TABLE [dbo].[ERS_ReportColumn](
	[ReportColumnID] [int] IDENTITY(1,1) NOT NULL,
	CONSTRAINT [PK_ERS_ReportColumn] PRIMARY KEY CLUSTERED ([ReportColumnID]),
	[ReportName] [varchar](500) NULL,
	[ReportColumnGroupID] [int] NULL,
	[ReportColumnGroupName] [varchar](500) NULL,
)
GO

---------------------------------------------------------------
------------------------ERS_ReportGroupColumn------------------
---------------------------------------------------------------

CREATE TABLE [dbo].[ERS_ReportGroupColumn](
	[ReportGroupColumnID] [int] IDENTITY(1,1) NOT NULL,
	CONSTRAINT [ERS_ReportGroupColumn.PK.ReportGroupColumnID] PRIMARY KEY CLUSTERED ([ReportGroupColumnID]),
	[ReportGroupID] [varchar](3) NOT NULL,
	CONSTRAINT [ERS_ReportGroupColumn.FK.ReportGroupID] FOREIGN KEY([ReportGroupID]) REFERENCES [dbo].[ERS_ReportGroup] ([ReportGroupID]),
	[ColumnPosition] [int] NOT NULL,
	CONSTRAINT [ERS_ReportGroupColumn.UNIQUE.ReportGroupID.ColumnPosition] UNIQUE NONCLUSTERED ([ReportGroupColumnID],[ColumnPosition]),
	[ColumnName] [varchar](128) NOT NULL DEFAULT (''),
	[ReportID] [varchar](32) NOT NULL,
	CONSTRAINT [ERS_ReportGroupColumn.FK.ReportID] FOREIGN KEY([ReportID]) REFERENCES [dbo].[ERS_Report] ([ReportID]),
)
GO

---------------------------------------------------------------
------------------------ERS_ReportPopup------------------------
---------------------------------------------------------------

CREATE TABLE [dbo].[ERS_ReportPopup](
	[ReportPopupID] [int] IDENTITY(1,1) NOT NULL,
	CONSTRAINT [ERS_ReportPopup.PK.ReportPopupID] PRIMARY KEY CLUSTERED ([ReportPopupID]),
	[ReportGroupColumnID] [int] NOT NULL,
	CONSTRAINT [ERS_ReportPopup.FK.ReportGroupColumnID] FOREIGN KEY([ReportGroupColumnID]) REFERENCES [dbo].[ERS_ReportGroupColumn] ([ReportGroupColumnID]),
	[ReportID] [varchar](32) NOT NULL,
	CONSTRAINT [ERS_ReportPopup.FK.ReportID] FOREIGN KEY([ReportID]) REFERENCES [dbo].[ERS_Report] ([ReportID]),
)
GO



---------------------------------------------------------------
------------------------ERS_ReportBoston1----------------------
---------------------------------------------------------------

EXEC DropIfExist 'ERS_ReportBoston1', 'T';
GO

CREATE TABLE [dbo].[ERS_ReportBoston1]
(
	[UserID] INT NOT NULL REFERENCES [dbo].[ERS_ReportFilter] (UserID) ON DELETE CASCADE,
	[Formulation] VARCHAR(255) NOT NULL,
	[Scale] INT DEFAULT 0,
	CONSTRAINT [ERS_ReportBoston1.PK.UserID_Formulation_Scale] PRIMARY KEY CLUSTERED ([UserID], [Formulation], [Scale]),
	[Right] INT DEFAULT 0,
	[RightP] Numeric(17,2) DEFAULT 0,
	[Transverse] INT DEFAULT 0,
	[TransverseP] NUMERIC(17,2) DEFAULT 0,
	[Left] INT DEFAULT 0,
	[LeftP] NUMERIC(17,2) DEFAULT 0,
)
GO



---------------------------------------------------------------
------------------------ERS_ReportBoston2----------------------
---------------------------------------------------------------

EXEC DropIfExist 'ERS_ReportBoston2', 'T';
GO

CREATE TABLE [dbo].[ERS_ReportBoston2]
(
	[UserID] INT NOT NULL REFERENCES [dbo].[ERS_ReportFilter] (UserID) ON DELETE CASCADE,
	[Formulation] VARCHAR(255) NOT NULL,
	[Score] INT DEFAULT 0,
	CONSTRAINT [ERS_ReportBoston2.PK.UserID_Formulation_Score] PRIMARY KEY CLUSTERED ([UserID],[Formulation],[Score]),
	[Frequency] INT DEFAULT 0,
	[Fx] INT DEFAULT 0,
)
GO



---------------------------------------------------------------
------------------------ERS_ReportBoston3----------------------
---------------------------------------------------------------

EXEC DropIfExist 'ERS_ReportBoston3', 'T';
GO

CREATE TABLE [dbo].[ERS_ReportBoston3]
(
	[UserID] INT NOT NULL REFERENCES [dbo].[ERS_ReportFilter] (UserID) ON DELETE CASCADE,
	[Formulation] VARCHAR(255) NOT NULL,
	CONSTRAINT [ERS_ReportBoston3.PK.UserID_Formulation] PRIMARY KEY CLUSTERED ([UserID],[Formulation]),
	[NoOfProcs] INT DEFAULT 0,
	[MeanScore] NUMERIC(17,2) DEFAULT 0,
)
GO



---------------------------------------------------------------
------------------------ERS_DiagnosisTypes---------------------
---------------------------------------------------------------

EXEC DropIfExist 'ERS_DiagnosisTypes', 'T';
GO

Create Table [dbo].[ERS_DiagnosisTypes] (
	DiagnosisId INT PRIMARY KEY CLUSTERED,
	DiagnosisMatrixID INT,
	NED_Diagnosis VARCHAR(128),
	Organ VARCHAR(128),
)
GO


INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (0,0,'None')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (1,0,'Normal')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (2,0,'Other')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (3,58,'Anal fissure')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (4,54,'Angiodysplasia')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (5,-1,'Colitis - ischemic')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (6,-1,'Colitis - pseudomembranous')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (7,-1,'Colitis - unspecified')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (8,59,'Colorectal cancer')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (9,60,'Crohn''s - terminal ileum')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (10,-1,'Crohn''s colitis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (11,42,'Diverticulosis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (12,61,'Fistula')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (13,25,'Foreign body')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (14,46,'Haemorrhoids')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (15,63,'Lipoma')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (16,64,'Melanosis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (17,65,'Parasites')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (18,66,'Pneumatosis coli')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (19,39,'Polyp/s')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (20,67,'Polyposis syndrome')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (21,68,'Postoperative appearance')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (22,69,'Proctitis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (23,32,'Rectal ulcer')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (24,55,'Stricture - inflammatory')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (25,56,'Stricture - malignant')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (26,57,'Stricture - postoperative')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (27,-1,'Ulcerative colitis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (28,-1,'Anastomotic stricture')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (29,-1,'Biliary fistula/leak')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (30,-1,'Biliary occlusion')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (31,-1,'Biliary stent occlusion')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (32,-1,'Biliary stone(s)')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (33,-1,'Biliary stricture')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (34,-1,'Carolis disease')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (35,-1,'Cholangiocarcinoma')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (36,-1,'Choledochal cyst')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (37,-1,'Cystic duct stones')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (38,-1,'Duodenal diverticulum')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (39,-1,'Gallbladder stone(s)')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (40,-1,'Gallbladder tumor')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (41,-1,'Hemobilia')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (42,-1,'IPMT')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (43,-1,'Mirizzi syndrome')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (44,-1,'Pancreas annulare')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (45,-1,'Pancreas divisum')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (46,-1,'Pancreatic cyst')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (47,-1,'Pancreatic duct fistula/leak')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (48,-1,'Pancreatic duct injury')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (49,-1,'Pancreatic duct stricture')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (50,-1,'Pancreatic stent occlusion')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (51,-1,'Pancreatic stone')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (52,-1,'Pancreatic tumor')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (53,-1,'Pancreatitis - acute')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (54,-1,'Pancreatitis - chronic')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (55,-1,'Papillary stenosis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (56,-1,'Papillary tumor')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (57,-1,'Primary sclerosing cholangitis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (58,-1,'Suppurative cholangitis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (59,-1,'Achalasia')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (60,4,'Barrett''s oesophagus')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (61,-1,'Dieulafoy lesion')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (62,-1,'Duodenal polyp')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (63,6,'Duodenal tumour - benign')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (64,18,'Duodenal tumour - malignant')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (65,7,'Duodenal ulcer')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (66,-1,'Duodenitis - erosive')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (67,-1,'Duodenitis - non-erosive')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (68,0,'Extrinsic compression')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (69,0,'Gastric diverticulum')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (70,0,'Gastric fistula')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (71,-1,'Gastric foreign body')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (72,0,'Gastric polyp(s)')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (73,0,'Gastric postoperative appearance')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (74,0,'Gastric tumour - benign')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (75,0,'Gastric tumour - malignant')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (76,0,'Gastric tumour - submucosal')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (77,32,'Gastric ulcer')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (78,0,'Gastric varices')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (79,0,'Gastritis - erosive')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (80,0,'Gastritis - non-erosive')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (81,0,'Gastropathy-portal hypertensive')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (82,0,'GAVE')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (83,1,'Hiatus hernia')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (84,5,'Mallory-Weiss tear')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (85,8,'Oesophageal candidiasis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (86,0,'Oesophageal diverticulum')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (87,0,'Oesophageal fistula')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (88,-1,'Oesophageal foreign body')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (89,21,'Oesophageal polyp')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (90,2,'Oesophageal stricture - benign')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (91,0,'Oesophageal stricture - malignant')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (92,0,'Oesophageal tumour - benign')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (93,0,'Oesophageal tumour - malignant')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (94,0,'Oesophageal ulcer')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (95,0,'Oesophageal varices')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (96,0,'Oesophagitis - eosinophilic')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (97,17,'Oesophagitis - reflux')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (98,0,'Pharyngeal pouch')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (99,31,'Pyloric stenosis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (100,22,'Scar')
GO







---------------------------------------------------------------
------------------------v_rep_BowelPrepGRSC05------------------
---------------------------------------------------------------

EXEC DropIfExist 'v_rep_BowelPrepGRSC05', 'V';
GO

/* FW Part 2 */

/* [dbo].[fw_Visualization] */
/* [dbo].[fw_UGI_Lesions] */
/* VIEWS */
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
SET @sql = 'Create View [dbo].[v_rep_BowelPrepGRSC05] As
Select Case When Quality Is Null Then 1 Else 0 End As [Unspecified], Case When Quality=4 Then 1 Else 0 End As [NoBowelPrep] From [Colon Indications] 
Union All
Select 0 As Unspecified, OffNoBowelPrep As [NoBowelPrep] From [dbo].[ERS_BowelPreparation]'
END
ELSE
BEGIN
SET @sql = 'Create View [dbo].[v_rep_BowelPrepGRSC05] As
Select 0 As Unspecified, OffNoBowelPrep As [NoBowelPrep] From [dbo].[ERS_BowelPreparation]'
END
EXEC sp_executesql @sql
GO






---------------------------------------------------------------
------------------------v_rep_BowelPreparation-----------------
---------------------------------------------------------------

EXEC DropIfExist 'v_rep_BowelPreparation', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
SET @sql ='
Create View [dbo].[v_rep_BowelPreparation] As
Select 
	Patients.[Case note no],
	Patients.[Surname],
	Patients.[Forename],
	Convert(int,SubString(IsNull(Procs.Endoscopist2,''000000''),7,6)) As Endoscopist1,
	0 As Endoscopist2,
	Convert(int,SubString(IsNull(Procs.Endoscopist1,''000000''),7,6)) As Assistant1,
	0 As Assistant2,
	Case When Procs.[Consultant No]<0 Then 0 Else IsNull(Procs.[Consultant No],0) End As [ListConsultant],
	Convert(int,SubString(IsNull(Procs.Nurse1,''000000''),7,6)) As Nurse1,
	Convert(int,SubString(IsNull(Procs.Nurse2,''000000''),7,6)) As Nurse2,
	0 As Nurse3,
	0 As Instrument1,
	0 As Instrument2,
	Convert(Date,Episode.[Episode date]) As CreatedOn,
	Case Procs.[Procedure type] When 0 Then ''COL'' When 1 Then ''SIG'' Else ''Others'' End As [ProcedureType],
	Case When BBPScore Is Null Then 0 Else 1 End As BowelPrepSettings,
	Case IsNull(Indic.[Bowel preparation],0) When 0 Then 1 Else 0 End As OnNoBowelPrep, 
	Lists.[List item text] As Formulation,
	IsNull(Indic.[Bowel preparation],0) As OnFormulation, 
	IsNull(Indic.BBPSRight,0) As OnRight, 
	IsNull(Indic.BBPSTransverse,0) As OnTransverse,
	IsNull(Indic.BBPSLeft,0) As OnLeft, 
	IsNull(Indic.BBPScore,0) As OnTotalScore,
	Case IsNull(Indic.[Bowel preparation],0) When 0 Then 1 Else 0 End As OffNoBowelPrep,
	IsNull(Indic.[Bowel preparation],0) As OffFormulation, 
	Case IsNull(Indic.Quality,0) When 1 Then 1 Else 0 End As OffQualityGood,
	Case IsNull(Indic.Quality,0) When 2 Then 1 Else 0 End As OffQualitySatisfactory,
	Case IsNull(Indic.Quality,0) When 3 Then 1 Else 0 End As OffQualityPoor,
	''UGI'' As Release
From 
	dbo.[Colon Indications] Indic
	, dbo.Lists Lists
	, dbo.Episode Episode 
	, dbo.[Patient] Patients
	, dbo.[Colon Procedure] Procs
Where 
	Indic.BBPScore Is Not Null
	And IsNull(Indic.[Bowel preparation],0)=Lists.[List item no] And Lists.[List description]=''Preparation'' --And Lists.[List item no]<>0
	And indic.[Patient No]=Episode.[Patient No] And Indic.[Episode No]=Episode.[Episode No]
	And Episode.[Patient No]=procs.[Patient No] And Episode.[Episode No]=Procs.[Episode No]
	And Patients.[Patient No]=Convert(int,SubString(Procs.[Patient No],7,6))
	And UPPER(Lists.[List item text]) <> ''(NONE SELECTED)''
Union All
Select
	Patients.[HospitalNumber],
	Patients.Surname, Patients.Forename1,
	IsNull(Procs.Endoscopist1,0) As Endoscopist1,
	IsNull(Procs.Endoscopist2,0) As Endoscopist2,
	IsNull(Procs.Assistant,0) As Assistant1,
	0 As Assistant2,
	IsNull(Procs.ListConsultant,0) As ListConsultant,
	IsNull(Procs.Nurse1,0) As Nurse1,
	IsNull(Procs.Nurse2,0) As Nurse2,
	IsNull(Procs.Nurse3,0) As Nurse3,
	IsNull(Procs.Instrument2,0) As Instrument1,
	IsNull(Procs.Instrument2,0) As Instrument2,
	Convert(Date,Procs.CreatedOn) As [CreatedOn],
		Case Procs.[ProcedureType] 
		When 1 Then ''OGD''
		When 2 Then ''ERC''
		When 3 Then ''COL''
		When 4 Then ''SIG''
		When 5 Then ''PRO''
		When 6 Then ''EUS (OGD)''
		When 7 Then ''EUS (HPB)''
	End As ProcedureType,
	Bowel.BowelPrepSettings,	-- 0 Standard, 1 Boston
	Bowel.OnNoBowelPrep,
	ListERS.ListItemText As Formulation,
	Bowel.OnFormulation,
	Bowel.OnRight,
	Bowel.OnTransverse,
	Bowel.OnLeft,
	Bowel.OnTotalScore,
	Bowel.OffNoBowelPrep,
	Bowel.OffFormulation,
	CASE WHEN Bowel.BowelPrepQuality = 3 THEN 1 ELSE 0 END AS OffQualityGood,
	CASE WHEN Bowel.BowelPrepQuality = 2 THEN 1 ELSE 0 END AS OffQualitySatisfactory,
	CASE WHEN Bowel.BowelPrepQuality = 1 THEN 1 ELSE 0 END AS OffQualityPoor,
	''ERS'' As Release
From 
[dbo].[ERS_Procedures] Procs
, [dbo].[ERS_VW_Patients] Patients
, [dbo].[ERS_BowelPreparation] Bowel
, [dbo].[ERS_Lists] ListERS
Where Procs.PatientId=Patients.[PatientId] And Procs.ProcedureId=Bowel.ProcedureID And ListERS.ListDescription=''Bowel_Preparation'' And ListERS.ListItemNo=Bowel.OnFormulation And BowelPrepSettings=1'
END
ELSE
BEGIN
SET @sql='
Create View [dbo].[v_rep_BowelPreparation] As
Select
	Patients.[HospitalNumber],
	Patients.Surname, Patients.Forename1,
	IsNull(Procs.Endoscopist1,0) As Endoscopist1,
	IsNull(Procs.Endoscopist2,0) As Endoscopist2,
	IsNull(Procs.Assistant,0) As Assistant1,
	0 As Assistant2,
	IsNull(Procs.ListConsultant,0) As ListConsultant,
	IsNull(Procs.Nurse1,0) As Nurse1,
	IsNull(Procs.Nurse2,0) As Nurse2,
	IsNull(Procs.Nurse3,0) As Nurse3,
	IsNull(Procs.Instrument2,0) As Instrument1,
	IsNull(Procs.Instrument2,0) As Instrument2,
	Convert(Date,Procs.CreatedOn) As [CreatedOn],
		Case Procs.[ProcedureType] 
		When 1 Then ''OGD''
		When 2 Then ''ERC''
		When 3 Then ''COL''
		When 4 Then ''SIG''
		When 5 Then ''PRO''
		When 6 Then ''EUS (OGD)''
		When 7 Then ''EUS (HPB)''
	End As ProcedureType,
	Bowel.BowelPrepSettings,	-- 0 Standard, 1 Boston
	Bowel.OnNoBowelPrep,
	ListERS.ListItemText As Formulation,
	Bowel.OnFormulation,
	Bowel.OnRight,
	Bowel.OnTransverse,
	Bowel.OnLeft,
	Bowel.OnTotalScore,
	Bowel.OffNoBowelPrep,
	Bowel.OffFormulation,
	CASE WHEN Bowel.BowelPrepQuality = 3 THEN 1 ELSE 0 END AS OffQualityGood,
	CASE WHEN Bowel.BowelPrepQuality = 2 THEN 1 ELSE 0 END AS OffQualitySatisfactory,
	CASE WHEN Bowel.BowelPrepQuality = 1 THEN 1 ELSE 0 END AS OffQualityPoor,
	''ERS'' As Release
From 
[dbo].[ERS_Procedures] Procs
, [dbo].[ERS_VW_Patients] Patients
, [dbo].[ERS_BowelPreparation] Bowel
, [dbo].[ERS_Lists] ListERS
Where Procs.PatientId=Patients.[PatientId] And Procs.ProcedureId=Bowel.ProcedureID And ListERS.ListDescription=''Bowel_Preparation'' And ListERS.ListItemNo=Bowel.OnFormulation And BowelPrepSettings=1'

END

EXEC sp_executesql @sql
GO




---------------------------------------------------------------
-----------------------------fw_Apps---------------------------
---------------------------------------------------------------

EXEC DropIfExist 'fw_Apps', 'V';
GO

/* [dbo].[fw_Apps] */
Create View [dbo].[fw_Apps] As Select 'U' As AppId, 'UGI' As AppName Union All Select 'E' As AppId, 'ERS' As AppName 
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_NurseAssPatSedationScore', 'V';
GO

/* [dbo].[fw_NurseAssPatSedationScore] */
Create View [dbo].[fw_NurseAssPatSedationScore] As Select NurseAssPatSedationScore=0, NurseAssPatSedation='Not completed' Union All Select NurseAssPatSedationScore=1, NurseAssPatSedation='Not recorded' Union All Select NurseAssPatSedationScore=2, NurseAssPatSedation='Awake' Union All Select NurseAssPatSedationScore=3, NurseAssPatSedation='Drowsy' Union All Select NurseAssPatSedationScore=4, NurseAssPatSedation='Asleep but responding to name' Union All Select NurseAssPatSedationScore=5, NurseAssPatSedation='Asleep but responding to touch' Union All Select NurseAssPatSedationScore=6, NurseAssPatSedation='Asleep but unresponsive' 
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_Episode', 'V';
GO

/* [dbo].[fw_UGI_Episode] */
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_Episode] 
	--WITH SCHEMABINDING 
	As Select [Patient No] ,[Episode date] ,[Episode No] ,[Imported] ,[Status] ,[Combined procedure] ,[Procedure catagory] ,[On waiting list] ,[Age at procedure] ,[Open access proc] ,[Emergency proc type] ,[Status2] ,[Procedure time] ,[Procedure start time] ,[DNA procedure] ,[DNA type] ,[DNA attended but reason] ,[DNA unfit/unsuitable reason text] ,[DNA unfit/unsuitable reason ID] ,[Procedure ID] From [dbo].[Episode] 
	'
END

EXEC sp_executesql @sql
GO


---------------------------------------------------------------
--------------fw_UGI_Episode Indexs start----------------------
---------------------------------------------------------------
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
--kfw_UGI_Episode
CREATE UNIQUE CLUSTERED INDEX kfw_UGI_Episode ON fw_UGI_Episode ([Episode No],[Patient No],[Procedure time])'
END

EXEC sp_executesql @sql
GO

/* [dbo].[iEpisodefw_UGI_Episode] */
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
--iEpisodefw_UGI_Episode
CREATE INDEX iEpisodefw_UGI_Episode ON fw_UGI_Episode ([Episode No])
	'
END

EXEC sp_executesql @sql
GO

/* [dbo].[iPatientfw_UGI_Episode] */
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
--iPatientfw_UGI_Episode
CREATE INDEX iPatientfw_UGI_Episode ON fw_UGI_Episode ([Patient No])
	'
END

EXEC sp_executesql @sql
GO

/* [dbo].[iEpisodePatientfw_UGI_Episode] */
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
--iEpisodePatientfw_UGI_Episode
CREATE INDEX iEpisodePatientfw_UGI_Episode ON fw_UGI_Episode ([Episode No],[Patient No])
	'
END

EXEC sp_executesql @sql
GO


/* [dbo].[istatusfw_UGI_Episode] */
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
--istatusfw_UGI_Episode
CREATE INDEX istatusfw_UGI_Episode ON fw_UGI_Episode ([status])
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
--------------fw_UGI_Episode Indexs end------------------------
---------------------------------------------------------------







---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_Drugs', 'V';
GO

Create View [dbo].[fw_Drugs] As
Select D.DrugNo As DrugId, D.DrugName, IsNull(D.DeliveryMethod,'') As DeliveryMethod, IsNull(D.Units,'') As Units
, D.DefaultDose, D.DoseIncrement, D.IsReversingAgent
From ERS_DrugList D
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_Sites', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_Sites]
As
Select 
	''U.''+Convert(varchar(2),Case QJ.SrcTable When ''C'' Then 
	Case When SubString(E.[Status],3,1)=1 Then
			Case QJ.[Procedure type] 
			When 0 Then 3
			When 1 Then 4
			End
		Else
			5
		End
	When ''E'' Then 
		Case When SubString(E.[Status],6,1)=1 Then 7
		Else 2 End
	When ''U'' Then 
		Case When SubString(E.[Status],5,1)=1 Then 6
		Else 1 End Else 0 
	End)+''.''+Convert(varchar(10),QJ.[Episode No])+''.''+Convert(varchar(10),Convert(int,SubString(QJ.[Patient No],7,6))) As ProcedureId
	,''U.''+Convert(varchar(2),Case QJ.SrcTable When ''C'' Then 
	Case When SubString(E.[Status],3,1)=1 Then
			Case QJ.[Procedure type] 
			When 0 Then 3
			When 1 Then 4
			End
		Else
			5
		End
	When ''E'' Then 
		Case When SubString(E.[Status],6,1)=1 Then 7
		Else 2 End
	When ''U'' Then 
		Case When SubString(E.[Status],5,1)=1 Then 6
		Else 1 End Else 0 
	End)+''.''+Convert(varchar(10),QJ.[Episode No])+''.''+Convert(varchar(10),Convert(int,SubString(QJ.[Patient No],7,6)))+''.''+Convert(varchar(10),QJ.[Site No]) As SiteId
	,QJ.Region, QJ.AntPostId From 
(Select ''E'' As SrcTable, ERS.[Episode No], ERS.[Patient No], ERS.[Site No], ERS.Region, ERS.AntPost As AntPostId, ERS.[EUS proc type] As [Procedure type]
From [dbo].[ERCP Sites] ERS
Union All
Select ''U'' As SrcTable, UGS.[Episode No], UGS.[Patient No], UGS.[Site No], UGS.Region, UGS.AntPost As AntPostId, UGS.[EUS proc type] As [Procedure type]
From [dbo].[Upper GI Sites] UGS
Union All
Select ''C'' As SrcTable, CSS.[Episode No], CSS.[Patient No], CSS.[Site No], CSS.Region, 9 As AntPostId, CSS.[Procedure type]
From [dbo].[Colon Sites] CSS) As QJ
INNER JOIN [dbo].[fw_UGI_Episode] E ON QJ.[Episode No]=E.[Episode No] And QJ.[Patient No]=E.[Patient No]
GO'
END

EXEC sp_executesql @sql
GO

---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_Sites', 'V';
GO

/* [dbo].[fw_ERS_Sites] */
Create View [dbo].[fw_ERS_Sites] 
	--WITH SCHEMABINDING 
	As Select 'E.'+Convert(Varchar(10),EES.ProcedureId) As ProcedureId , 'E.'+Convert(Varchar(10),EES.SiteId) As SiteId , R.Region , EES.AntPos As AntPosId From [dbo].[ERS_Sites] EES, [dbo].[ERS_Procedures] EP, [dbo].[ERS_Regions] R Where EES.ProcedureId=EP.ProcedureId And R.ProcedureType=EP.ProcedureType And EES.RegionId=R.RegionId 
GO

--CREATE UNIQUE CLUSTERED INDEX kfw_ERS_Sites ON [dbo].[fw_ERS_Sites] (ProcedureId)
--GO

---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_Sites', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
/* [dbo].[fw_Sites] */
Create View [dbo].[fw_Sites] As Select * From [dbo].[fw_UGI_Sites] Union All Select * From [dbo].[fw_ERS_Sites] 
'
END
ELSE
BEGIN
	SET @sql = '
/* [dbo].[fw_Sites] */
Create View [dbo].[fw_Sites] As Select * From [dbo].[fw_ERS_Sites] 
'
END

EXEC sp_executesql @sql
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_Complications', 'V';
GO

/* [dbo].[fw_ERS_Complications] */
CREATE VIEW fw_ERS_Complications AS
	SELECT ProcedureId, NurseAssPatSedationScore, NursesAssPatComfortScore, PatientsSedationScore
	, RTRIM(Complication)
	+CASE WHEN RTRIM(Complication)='Damage to scope' THEN ' ('+DamageToScopeType+')' ELSE '' END 
	+CASE WHEN RTRIM(Complication)='Complications other:' THEN ' '+ComplicationsOtherText ELSE '' END
	+CASE WHEN RTRIM(Complication)='Technical Failure:' THEN ' '+TechnicalFailureText ELSE '' END
	AS Complication 
	FROM 
	(Select 
		'E.'+Convert(Varchar(10),NP.ProcedureId) As ProcedureId
		,Case When QA.PatSedation=4
			Then 
				Case QA.PatSedationAsleepResponseState
				When 1 Then 4
				When 2 Then 5
				When 3 Then 6
				Else QA.PatSedationAsleepResponseState End
			Else QA.PatSedation End As NurseAssPatSedationScore
		, IsNull(QA.PatDiscomfortNurse,0) As NursesAssPatComfortScore
		, IsNull(QA.PatSedation,0) As PatientsSedationScore
		--, QA.ComplicationsNone
		, Case When QA.DamageToScope=1             Then 'Damage to scope                              ' End AS DamageToScope
		, Case When QA.PoorlyTolerated=1           Then 'Poorly tolerated                             ' End AS PoorlyTolerated
		, Case When QA.Hypoxia=1                   Then 'Hypoxia                                      ' End AS Hypoxia
		, Case When QA.RespiratoryDepression=1     Then 'Respiratory depression                       ' End AS RespiratoryDepression
		, Case When QA.PatientDiscomfort=1         Then 'Patient discomfort                           ' End AS PatientDiscomfort
		, Case When QA.RespiratoryArrest=1         Then 'Respiratory arrest requiring                 ' End AS RespiratoryArrest
		, Case When QA.PatientDistress=1           Then 'Patient distress                             ' End AS PatientDistress
		, Case When QA.GastricContentsAspiration=1 Then 'Gastric contents aspiration                  ' End AS GastricContentsAspiration
		, Case When QA.ShockHypotension=1          Then 'Shock/hypotension                            ' End AS ShockHypotension
		, Case When QA.CardiacArrest=1             Then 'Cardiac arrest                               ' End AS CardiacArrest
		, Case When QA.FailedIntubation=1          Then 'Failed intubation                            ' End AS FailedIntubation
		, Case When QA.Haemorrhage=1               Then 'Haemorrhage                                  ' End AS Haemorrhage
		, Case When QA.CardiacArrythmia=1          Then 'Cardiac arrythmia                            ' End AS CardiacArrythmia
		, Case When QA.DifficultIntubation=1       Then 'Difficult intubation                         ' End AS DifficultIntubation
		, Case When QA.SignificantHaemorrhage=1    Then 'Significant haemorrhage requiring transfusion' End AS SignificantHaemorrhage
		, Case When QA.Death=1                     Then 'Dead                                         ' End AS Death
		, Case When QA.ComplicationsOther=1        Then 'Complications other:                         ' End AS ComplicationsOther
		, Case When ISNULL(QA.TechnicalFailure,'') <>'' Then 'Technical failure:                           ' End AS TechnicalFailure
	
		, Case When QA.DamageToScopeType=0 
			Then 'mechanical' 
			else 'patient initiated' End AS DamageToScopeType
		, QA.ComplicationsOtherText
		, QA.TechnicalFailure As TechnicalFailureText
		, Case When QA.Perforation=1               Then ', '+QA.PerforationText Else '' End AS Perforation
	From ERS_Procedures NP, ERS_UpperGIQA QA
	Where QA.ProcedureId=NP.ProcedureId
	) AS L1
	UNPIVOT (Complication FOR ComplicationId IN (DamageToScope, PoorlyTolerated, Hypoxia, RespiratoryDepression, PatientDiscomfort, RespiratoryArrest
	, PatientDistress, GastricContentsAspiration, ShockHypotension, CardiacArrest, FailedIntubation, Haemorrhage, CardiacArrythmia
	, DifficultIntubation, SignificantHaemorrhage, Death, ComplicationsOther, TechnicalFailure)) L2
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_O_Complications', 'V';
GO


/* [dbo].[fw_UGI_C_Complications] */
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '

CREATE VIEW [dbo].[fw_UGI_O_Complications]
--WITH SCHEMABINDING
AS
SELECT ProcedureId, NurseAssPatSedationScore, NursesAssPatComfortScore, PatientsSedationScore
	, RTRIM(Complication)
	+CASE WHEN RTRIM(Complication)=''Damage to scope'' THEN '' (''+DamageToScopeType+'')'' ELSE '''' END 
	+CASE WHEN RTRIM(Complication)=''Complications other:'' THEN '' ''+ISNULL(ComplicationsOtherText,'''') ELSE '''' END
	+CASE WHEN RTRIM(Complication)=''Technical Failure:'' THEN '' ''+ISNULL(TechnicalFailureText,'''') ELSE '''' END
	AS Complication 
	FROM 
(Select 
	''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''4'' Then 5 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	,Case When QA.[Pat sedation]=4
		Then 
			Case QA.[Pat sedation asleep but responding] 
			When 1 Then 4
			When 2 Then 5
			When 3 Then 6
			Else QA.[Pat sedation asleep but responding] End
		Else QA.[Pat sedation] End As NurseAssPatSedationScore
	, IsNull(QA.[Pat discomfort],0) As NursesAssPatComfortScore
	, IsNull(QA.[Pat ass discomfort],0) As PatientsSedationScore
	, Case When QA.[Poorly tolerated]=-1            Then ''Poorly tolerated                             '' End AS PoorlyTolerated
	, Case When QA.Hypoxia=-1                       Then ''Hypoxia                                      '' End AS Hypoxia
	, Case When QA.[Respiratory depression]=-1      Then ''Respiratory depression                       '' End AS RespiratoryDepression
	, Case When QA.[Patient discomfort]=-1          Then ''Patient discomfort                           '' End AS PatientDiscomfort
	, Case When QA.[Respiratory arrest]=-1          Then ''Respiratory arrest requiring                 '' End AS RespiratoryArrest
	, Case When QA.[Patient distress]=-1            Then ''Patient distress                             '' End AS PatientDistress
	, Case When QA.[Gastric contents aspiration]=-1 Then ''Gastric contents aspiration                  '' End AS GastricContentsAspiration
	, Case When QA.[Shock/hypotension]=-1           Then ''Shock/hypotension                            '' End AS ShockHypotension
	, Case When QA.[Cardiac arrest]=-1              Then ''Cardiac arrest                               '' End AS CardiacArrest
	, Case When QA.[Failed intubation]=-1           Then ''Failed intubation                            '' End AS FailedIntubation
	, Case When QA.Haemorrhage=-1                   Then ''Haemorrhage                                  '' End AS Haemorrhage
	, Case When QA.[Cardiac arrythmia]=-1           Then ''Cardiac arrythmia                            '' End AS CardiacArrythmia
	, Case When QA.[Difficult intubation]=-1        Then ''Difficult intubation                         '' End AS DifficultIntubation
	, Case When QA.[Significant haemorrhage]=-1     Then ''Significant haemorrhage requiring transfusion'' End AS SignificantHaemorrhage
	, Case When QA.Death=-1                         Then ''Dead                                         '' End AS Death
	, Case When QA.[Technical failure]<>NULL           Then ''Technical failure:                           '' End AS TechnicalFailure
	, CASE WHEN QA.[Damage to scope]=-1             THEN ''Damage to scope                              '' END AS DamageToScope
	, CASE WHEN QA.[Complications other]=-1         THEN ''Complications other:                         '' END AS ComplicationsOther
	, Case When QA.[Mechanical scope damage]=0 
			Then ''mechanical'' 
			else ''patient initiated'' End AS DamageToScopeType
	, Case When QA.Perforation=1  Then '', ''+QA.[Perforation text] Else '''' End AS Perforation
	, QA.[Complications other text] As ComplicationsOtherText
	, CONVERT(NVARCHAR(500),QA.[Technical failure]) AS TechnicalFailureText
From [dbo].[Upper GI Procedure] CP, [dbo].[fw_UGI_Episode] E, [dbo].[Upper GI QA] QA
Where CP.[Episode No]=E.[Episode No] And QA.[Episode No]=CP.[Episode No] And CP.DNA Is Not Null
) AS L1
	UNPIVOT (Complication FOR ComplicationId IN (DamageToScope, PoorlyTolerated, Hypoxia, RespiratoryDepression, PatientDiscomfort, RespiratoryArrest
	, PatientDistress, GastricContentsAspiration, ShockHypotension, CardiacArrest, FailedIntubation, Haemorrhage, CardiacArrythmia
	, DifficultIntubation, SignificantHaemorrhage, Death, ComplicationsOther, TechnicalFailure)) L2
'
END

EXEC sp_executesql @sql
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_E_Complications', 'V';
GO

/* [dbo].[fw_UGI_E_Complications] */

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
CREATE VIEW [dbo].[fw_UGI_E_Complications]
--WITH SCHEMABINDING
AS
SELECT ProcedureId, NurseAssPatSedationScore, NursesAssPatComfortScore, PatientsSedationScore
	, RTRIM(Complication)
	+CASE WHEN RTRIM(Complication)=''Damage to scope'' THEN '' (''+DamageToScopeType+'')'' ELSE '''' END 
	+CASE WHEN RTRIM(Complication)=''Complications other:'' THEN '' ''+ISNULL(ComplicationsOtherText,'''') ELSE '''' END
	+CASE WHEN RTRIM(Complication)=''Technical Failure:'' THEN '' ''+ISNULL(TechnicalFailureText,'''') ELSE '''' END
	AS Complication 
	FROM 
(Select 
	''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''4'' Then 5 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	,Case When QA.[Pat sedation]=4
		Then 
			Case QA.[Pat sedation asleep but responding]
			When 1 Then 4
			When 2 Then 5
			When 3 Then 6
			Else QA.[Pat sedation asleep but responding] End
		Else QA.[Pat sedation] End As NurseAssPatSedationScore
	, IsNull(QA.[Pat discomfort],0) As NursesAssPatComfortScore
	, IsNull(QA.[Pat ass discomfort],0) As PatientsSedationScore
	, Case When QA.[Poorly tolerated]=-1            Then ''Poorly tolerated                             '' End AS PoorlyTolerated
	, Case When QA.Hypoxia=-1                       Then ''Hypoxia                                      '' End AS Hypoxia
	, Case When QA.[Respiratory depression]=-1      Then ''Respiratory depression                       '' End AS RespiratoryDepression
	, Case When QA.[Patient discomfort]=-1          Then ''Patient discomfort                           '' End AS PatientDiscomfort
	, Case When QA.[Respiratory arrest]=-1          Then ''Respiratory arrest requiring                 '' End AS RespiratoryArrest
	, Case When QA.[Patient distress]=-1            Then ''Patient distress                             '' End AS PatientDistress
	, Case When QA.[Gastric contents aspiration]=-1 Then ''Gastric contents aspiration                  '' End AS GastricContentsAspiration
	, Case When QA.[Shock/hypotension]=-1           Then ''Shock/hypotension                            '' End AS ShockHypotension
	, Case When QA.[Cardiac arrest]=-1              Then ''Cardiac arrest                               '' End AS CardiacArrest
	, Case When QA.[Failed ERC/ERP]=-1              Then ''Failed ERC/ERP                               '' End AS FailedIntubation
	, Case When QA.Haemorrhage=-1                   Then ''Haemorrhage                                  '' End AS Haemorrhage
	, Case When QA.[Cardiac arrythmia]=-1           Then ''Cardiac arrythmia                            '' End AS CardiacArrythmia
	, Case When QA.[Difficult intubation]=-1        Then ''Difficult intubation                         '' End AS DifficultIntubation
	, Case When QA.[Significant haemorrhage]=-1     Then ''Significant haemorrhage requiring transfusion'' End AS SignificantHaemorrhage
	, Case When QA.Death=-1                         Then ''Dead                                         '' End AS Death
	, Case When QA.[Technical failure]<>NULL           Then ''Technical failure:                           '' End AS TechnicalFailure
	, CASE WHEN QA.[Damage to scope]=-1             THEN ''Damage to scope                              '' END AS DamageToScope
	, CASE WHEN QA.[Complications other]=-1         THEN ''Complications other:                         '' END AS ComplicationsOther
	, Case When QA.[Mechanical scope damage]=0 
			Then ''mechanical'' 
			else ''patient initiated'' End AS DamageToScopeType
	, Case When QA.Perforation=1  Then '', ''+QA.[Perforation text] Else '''' End AS Perforation
	, QA.[Complications other text] As ComplicationsOtherText
	, CONVERT(NVARCHAR(500),QA.[Technical failure]) AS TechnicalFailureText
From [dbo].[ERCP Procedure] CP, [dbo].[fw_UGI_Episode] E, [dbo].[ERCP QA] QA
Where CP.[Episode No]=E.[Episode No] And QA.[Episode No]=CP.[Episode No] And CP.DNA Is Not Null
) AS L1
	UNPIVOT (Complication FOR ComplicationId IN (DamageToScope, PoorlyTolerated, Hypoxia, RespiratoryDepression, PatientDiscomfort, RespiratoryArrest
	, PatientDistress, GastricContentsAspiration, ShockHypotension, CardiacArrest, FailedIntubation, Haemorrhage, CardiacArrythmia
	, DifficultIntubation, SignificantHaemorrhage, Death, ComplicationsOther, TechnicalFailure)) L2

'
END

EXEC sp_executesql @sql
GO

---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------

EXEC DropIfExist 'fw_UGI_C_Complications', 'V';
GO

/* [dbo].[fw_UGI_C_Complications] */

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
CREATE VIEW [dbo].[fw_UGI_C_Complications]
--WITH SCHEMABINDING
AS
SELECT ProcedureId, NurseAssPatSedationScore, NursesAssPatComfortScore, PatientsSedationScore
	, RTRIM(Complication)
	+CASE WHEN RTRIM(Complication)=''Damage to scope'' THEN '' (''+DamageToScopeType+'')'' ELSE '''' END 
	+CASE WHEN RTRIM(Complication)=''Complications other:'' THEN '' ''+ISNULL(ComplicationsOtherText,'''') ELSE '''' END
	+CASE WHEN RTRIM(Complication)=''Technical Failure:'' THEN '' ''+ISNULL(TechnicalFailureText,'''') ELSE '''' END
	AS Complication 
	FROM 
(Select 
	''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''4'' Then 5 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	,Case When QA.[Pat sedation]=4
		Then 
			Case QA.[Pat sedation asleep but responding] 
			When 1 Then 4
			When 2 Then 5
			When 3 Then 6
			Else QA.[Pat sedation asleep but responding] End
		Else QA.[Pat sedation] End As NurseAssPatSedationScore
	, IsNull(QA.[Pat discomfort],0) As NursesAssPatComfortScore
	, IsNull(QA.[Pat ass discomfort],0) As PatientsSedationScore
	, Case When QA.[Poorly tolerated]=-1            Then ''Poorly tolerated                             '' End AS PoorlyTolerated
	, Case When QA.Hypoxia=-1                       Then ''Hypoxia                                      '' End AS Hypoxia
	, Case When QA.[Respiratory depression]=-1      Then ''Respiratory depression                       '' End AS RespiratoryDepression
	, Case When QA.[Patient discomfort]=-1          Then ''Patient discomfort                           '' End AS PatientDiscomfort
	, Case When QA.[Respiratory arrest]=-1          Then ''Respiratory arrest requiring                 '' End AS RespiratoryArrest
	, Case When QA.[Patient distress]=-1            Then ''Patient distress                             '' End AS PatientDistress
	, Case When QA.[Gastric contents aspiration]=-1 Then ''Gastric contents aspiration                  '' End AS GastricContentsAspiration
	, Case When QA.[Shock/hypotension]=-1           Then ''Shock/hypotension                            '' End AS ShockHypotension
	, Case When QA.[Cardiac arrest]=-1              Then ''Cardiac arrest                               '' End AS CardiacArrest
	, Case When QA.[Failed intubation]=-1           Then ''Failed intubation                            '' End AS FailedIntubation
	, Case When QA.Haemorrhage=-1                   Then ''Haemorrhage                                  '' End AS Haemorrhage
	, Case When QA.[Cardiac arrythmia]=-1           Then ''Cardiac arrythmia                            '' End AS CardiacArrythmia
	, Case When QA.[Difficult intubation]=-1        Then ''Difficult intubation                         '' End AS DifficultIntubation
	, Case When QA.[Significant haemorrhage]=-1     Then ''Significant haemorrhage requiring transfusion'' End AS SignificantHaemorrhage
	, Case When QA.Death=-1                         Then ''Dead                                         '' End AS Death
	, Case When QA.[Technical failure]<>NULL           Then ''Technical failure:                           '' End AS TechnicalFailure
	, CASE WHEN QA.[Damage to scope]=-1             THEN ''Damage to scope                              '' END AS DamageToScope
	, CASE WHEN QA.[Complications other]=-1         THEN ''Complications other:                         '' END AS ComplicationsOther
	, Case When QA.[Mechanical scope damage]=0 
			Then ''mechanical'' 
			else ''patient initiated'' End AS DamageToScopeType
	, Case When QA.Perforation=1  Then '', ''+QA.[Perforation text] Else '''' End AS Perforation
	, QA.[Complications other text] As ComplicationsOtherText
	, CONVERT(NVARCHAR(500),QA.[Technical failure]) AS TechnicalFailureText
From [dbo].[Colon Procedure] CP, [dbo].[fw_UGI_Episode] E, [dbo].[Colon QA] QA
Where CP.[Episode No]=E.[Episode No] And QA.[Episode No]=CP.[Episode No] And CP.DNA Is Not Null
) AS L1
	UNPIVOT (Complication FOR ComplicationId IN (DamageToScope, PoorlyTolerated, Hypoxia, RespiratoryDepression, PatientDiscomfort, RespiratoryArrest
	, PatientDistress, GastricContentsAspiration, ShockHypotension, CardiacArrest, FailedIntubation, Haemorrhage, CardiacArrythmia
	, DifficultIntubation, SignificantHaemorrhage, Death, ComplicationsOther, TechnicalFailure)) L2
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_Complications', 'V';
GO

/* [dbo].[fw_UGI_Complications] */
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
CREATE VIEW [dbo].[fw_UGI_Complications] AS
Select * FROM [dbo].[fw_UGI_E_Complications]
UNION ALL
Select * FROM [dbo].[fw_UGI_O_Complications]
UNION ALL
Select * FROM [dbo].[fw_UGI_C_Complications]
'
END

EXEC sp_executesql @sql
GO

EXEC DropIfExist 'fw_Complications', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
/* [dbo].[fw_Complications] */
CREATE VIEW fw_Complications AS
	SELECT * FROM fw_ERS_Complications
	UNION ALL
	SELECT * FROM fw_UGI_Complications
'
END
ELSE
BEGIN
	SET @sql = '
/* [dbo].[fw_Complications] */
CREATE VIEW fw_Complications AS
	SELECT * FROM fw_ERS_Complications
'
END
EXEC sp_executesql @sql
GO


EXEC DropIfExist 'fw_QA', 'V';
GO

Create View [dbo].[fw_QA] As
SELECT 
	PR.ProcedureId
	, CO.NurseAssPatSedationScore
	, CO.NursesAssPatComfortScore
	, CO.PatientsSedationScore
	, ISNULL([dbo].[fnComplication](PR.ProcedureId),'') As Complications, ISNULL([dbo].[fnPremedication](PR.ProcedureId),'') As ReversalAgents
FROM [dbo].[fw_Procedures] PR
	INNER JOIN (
	SELECT DISTINCT ProcedureId, NurseAssPatSedationScore, NursesAssPatComfortScore, PatientsSedationScore FROM [dbo].[fw_Complications]
	) AS CO ON PR.ProcedureId=CO.ProcedureId
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'v_rep_UGI_Consultants', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[v_rep_UGI_Consultants] As
Select 1000000+Convert(int,SubString([Consultant/operator ID],7,6)) As ReportID,
0 As ERSID,
Convert(int,SubString([Consultant/operator ID],7,6)) As UGIID,
''U.''+Convert(VARCHAR(20),Convert(int,SubString([Consultant/operator ID],7,6))) As ConsultantID,
-Convert(int,SubString([Consultant/operator ID],7,6)) As EmployeeId,
[Consultant/operator] As [Consultant],
Convert(bit,Case IsNull(UGI.[Suppress],0) When -1 Then 0 Else 1 End) As [Active],
Convert(bit,Case UGI.[IsListConsultant] When -1 Then ''TRUE'' Else ''FALSE'' End) As [IsListConsultant],
Convert(bit,Case UGI.[IsEndoscopist1] When -1 Then ''TRUE'' Else ''FALSE'' End) As [IsEndoscopist1],
Convert(bit,Case UGI.[IsEndoscopist2] When -1 Then ''TRUE'' Else ''FALSE'' End) As [IsEndoscopist2], 
Convert(bit,Case UGI.[IsAssistantTrainee] When -1 Then ''TRUE'' Else ''FALSE'' End) As [IsAssistantOrTrainee],
Convert(bit,Case UGI.[IsNurse1] When -1 Then ''TRUE'' Else ''FALSE'' End) As [IsNurse1],
Convert(bit,Case UGI.[IsNurse2] When -1 Then ''TRUE'' Else ''FALSE'' End) As [IsNurse2],
''UGI'' As Release
From [Consultant/Operators] UGI
Where Convert(int,SubString([Consultant/operator ID],7,6))<>0
'
END

EXEC sp_executesql @sql

GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'v_rep_ERS_Consultants', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[v_rep_ERS_Consultants] As
Select 
	UserID As ReportID,
	UserID As ERSID,
	0 As UGIID,
	''E.''+CONVERT(VARCHAR(20),UserID) As ConsultantID,
	UserID As EmployeeId,
	[Title]+'' ''+[Forename]+ '' ''+ERS.[Surname] As [Consultant],
	Convert(bit,Case IsNull(ERS.[Suppressed],0) When 1 Then 0 Else 1 End) As [Active],
	Convert(bit,Case ERS.[IsListConsultant] When 1 Then ''TRUE'' Else ''FALSE'' End) As [IsListConsultant],
	Convert(bit,Case ERS.[IsEndoscopist1] When 1 Then ''TRUE'' Else ''FALSE'' End) As [IsEndoscopist1],
	Convert(bit,Case ERS.[IsEndoscopist2] When 1 Then ''TRUE'' Else ''FALSE'' End) As [IsEndoscopist2], 
	Convert(bit,Case ERS.[IsAssistantOrTrainee] When 1 Then ''TRUE'' Else ''FALSE'' End) As [IsAssistantOrTrainee],
	Convert(bit,Case ERS.[IsNurse1] When 1 Then ''TRUE'' Else ''FALSE'' End) As [IsNurse1],
	Convert(bit,Case ERS.[IsNurse2] When 1 Then ''TRUE'' Else ''FALSE'' End) As [IsNurse2],
	''ERS'' As Release
From [dbo].[ERS_Users] ERS
Where Username Not In (Select Surname From [Consultant/Operators])
'
END
ELSE
BEGIN
	SET @sql = '
Create View [dbo].[v_rep_ERS_Consultants] As
Select 
	UserID As ReportID,
	UserID As ERSID,
	0 As UGIID,
	''E.''+CONVERT(VARCHAR(20),UserID) As ConsultantID,
	UserID As EmployeeId,
	[Title]+'' ''+[Forename]+ '' ''+ERS.[Surname] As [Consultant],
	Convert(bit,Case IsNull(ERS.[Suppressed],0) When 1 Then 0 Else 1 End) As [Active],
	Convert(bit,Case ERS.[IsListConsultant] When 1 Then ''TRUE'' Else ''FALSE'' End) As [IsListConsultant],
	Convert(bit,Case ERS.[IsEndoscopist1] When 1 Then ''TRUE'' Else ''FALSE'' End) As [IsEndoscopist1],
	Convert(bit,Case ERS.[IsEndoscopist2] When 1 Then ''TRUE'' Else ''FALSE'' End) As [IsEndoscopist2], 
	Convert(bit,Case ERS.[IsAssistantOrTrainee] When 1 Then ''TRUE'' Else ''FALSE'' End) As [IsAssistantOrTrainee],
	Convert(bit,Case ERS.[IsNurse1] When 1 Then ''TRUE'' Else ''FALSE'' End) As [IsNurse1],
	Convert(bit,Case ERS.[IsNurse2] When 1 Then ''TRUE'' Else ''FALSE'' End) As [IsNurse2],
	''ERS'' As Release
From [dbo].[ERS_Users] ERS
Where Username Not In (Select Surname From [ERS_Consultant])
'
END

EXEC sp_executesql @sql
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_ProceduresConsultants', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_ProceduresConsultants]
As
Select GPC.ProcedureId, Convert(int,SubString(ConsultantId,1,1)) As ConsultantTypeId, GPC.AppId+''.''+SubString(ConsultantId,3,len(ConsultantId)-2) As ConsultantId From
(Select UP.ProcedureId, AppId, UP.ConsultantId From 
(Select ''U.''+Convert(varchar(1),QK.ProcedureTypeId)+''.''+Convert(varchar(10),QK.[Episode No])+''.''+Convert(varchar(10),QK.PatientId) As ProcedureId, 
''U'' As AppId,
QK.Endoscopist1, QK.Endoscopist2, QK.ListConsultant, QK.Assistant, QK.Nurse1, QK.Nurse2
From
(Select 
	Case QJ.SrcTable 
	When ''C'' Then 
	Case When SubString(E.[Status],3,1)=1 Then
			Case QJ.[Procedure type] 
			When 0 Then 3
			When 1 Then 4
			End
		Else
			5
		End
	When ''E'' Then 
		Case When SubString(E.[Status],6,1)=1 Then 7
		Else 2 End
	When ''U'' Then 
		Case When SubString(E.[Status],5,1)=1 Then 6
		Else 1 End Else 0 
	End As ProcedureTypeId
	,Convert(int,SubString(QJ.[Patient No],7,6)) As PatientId,QJ.[Episode No],''2.''+Convert(varchar(10),Convert(INT,SubString(QJ.[Endoscopist1],7,6))) As Endoscopist1, ''3.''+Convert(varchar(10),Convert(INT,SubString(QJ.[Endoscopist2],7,6))) As Endoscopist2, ''1.''+Convert(varchar(10),Convert(INT,SubString(QJ.[Assistant1],7,6))) As ListConsultant, ''4.''+Convert(varchar(10),Convert(INT,SubString(QJ.[Assistant2],7,6))) As Assistant, ''5.''+Convert(varchar(10),Convert(INT,SubString(QJ.[Nurse1],7,6))) As Nurse1, ''6.''+Convert(varchar(10),Convert(INT,SubString(QJ.[Nurse2],7,6))) As Nurse2 FROM
(
select ''C'' As SrcTable, [Patient No],[Episode No],[Procedure type],[Endoscopist1],[Endoscopist2],[Assistant1],[Assistant2], Nurse1, Nurse2
from [Colon Procedure]
UNION
select ''U'' As SrcTable, [Patient No],[Episode No],0 as [Procedure type],[Endoscopist1],[Endoscopist2],[Assistant1],[Assistant2], Nurse1, Nurse2
from [Upper GI Procedure]
UNION
select ''E'' As SrcTable, [Patient No],[Episode No],0 as [Procedure type],[Endoscopist1],[Endoscopist2],[Assistant1],[Assistant2], Nurse1, Nurse2
from [ERCP Procedure]
) As QJ
INNER JOIN ERS_VW_Patients P ON QJ.[Patient No]=P.[ComboID]
INNER JOIN Episode E ON QJ.[Episode No]=E.[Episode No]
) As QK
Where ProcedureTypeId Is Not Null
) As PT
UNPIVOT
(ConsultantId For Consultants In (Endoscopist1,Endoscopist2,ListConsultant,Assistant, Nurse1, Nurse2)) As UP) As GPC
WHERE SUBSTRING(ConsultantId,3,LEN(ConsultantId)-2)<>''0'' And ProcedureId In (SELECT ProcedureId From fw_Procedures)'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_ProceduresConsultants', 'V';
GO

Create View [dbo].[fw_ERS_ProceduresConsultants]
--WITH SCHEMABINDING
As
Select UP.ProcedureId, SUBSTRING(UP.ConsultantTypeId,1,1) As ConsultantTypeId, SUBSTRING(UP.ConsultantTypeId,2,LEN(UP.ConsultantTypeId)-1) As ConsultantId 
From
(
Select 
	'E.'+Convert(Varchar(10),PR.ProcedureId) As ProcedureId,
	'E' As AppId,
	'1E.'+Convert(varchar(10),Endoscopist1) As Endoscopist1,
	'2E.'+Convert(varchar(10),Endoscopist2) As Endoscopist2,
	'3E.'+Convert(varchar(10),ListConsultant) As ListConsultant,
	'4E.'+Convert(varchar(10),Assistant) As Assistant, 
	'5E.'+Convert(varchar(10),Nurse1) As Nurse1, 
	'6E.'+Convert(varchar(10),Nurse2) As Nurse2
From [dbo].[ERS_Procedures] PR
) As PT
UNPIVOT
(ConsultantTypeId FOR Endoscopists In (Endoscopist1,Endoscopist2,ListConsultant,Assistant, Nurse1, Nurse2)) As UP

GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_O_Placements', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
/* [dbo].[fw_UGI_O_Placements] */
Create View [dbo].[fw_UGI_O_Placements]
--WITH SCHEMABINDING
As
Select 
	''U.1.''+Convert(Varchar(10),GISites.[Episode No])+''.''+Convert(Varchar(10),Convert(Int,SubString(GISites.[Patient No],7,6)))+''.''+Convert(varchar(10),GISites.[Site No]) As SiteId,
	Case When GITherapy.[Gastrostomy Insertion (PEG)]=-1 Then 1 Else 0 End As [Placements],
	Case When GITherapy.[Gastrostomy Insertion (PEG)]=-1 Then
			Case GITherapy.[Stent insertion] When -1 Then 0. Else 1. End Else 0. End As [IncorrectPlacement],
	Case When GITherapy.[Gastrostomy Insertion (PEG)]=-1 Then
			Case GITherapy.[Stent insertion] When -1 Then 1.0 Else 0. End Else 0. End As [CorrectPlacement]
From
	[dbo].[Upper GI Procedure] Procs
	, [dbo].[Upper GI sites] GISites
	, [dbo].[Upper GI therapeutic] GITherapy
	, [dbo].[ERS_VW_Patients] Patients
Where GISites.[Patient No]=Procs.[Patient No] And GISites.[Episode No]=Procs.[Episode No]
And GITherapy.[Patient No]=GISites.[Patient No] And GITherapy.[Episode No]=GISites.[Episode No] And GITherapy.[Site No]=GISites.[Site No]
And Patients.[UGIPatientId]=Convert(int,SubString(IsNull(Procs.[Patient No],''000000''),7,6))
And Procs.Endoscopist1 Is Not Null And Procs.Endoscopist1 <>''''
'
END

EXEC sp_executesql @sql
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_Placements', 'V';
GO

/* PENDING [dbo].[fw_UGI_E_Placements] */
/* PENDING [dbo].[fw_UGI_C_Placements] */
/* [dbo].[fw_UGI_Placements] */


DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
CREATE VIEW [dbo].[fw_UGI_Placements] AS
SELECT * FROM fw_UGI_O_Placements
--UNION ALL
--SELECT * FROM fw_UGI_E_Placements
--UNION ALL
--SELECT * FROM fw_UGI_C_Placements
'
END

EXEC sp_executesql @sql
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_Placements', 'V';
GO

/* [dbo].[fw_ERS_Placements] */
Create View [dbo].[fw_ERS_Placements]
--WITH SCHEMABINDING
As
Select 
	'E.'+Convert(varchar(10),GISites.SiteId) As SiteId,
	1 As [Placements],
	Case When GITherapy.[StentInsertion]=1 Then 0 Else 1 End As [IncorrectPlacement],
	Case When GITherapy.[StentInsertion]=1 Then 1 Else 0 End As [CorrectPlacement]
From
[dbo].[ERS_Procedures] Procs
, [dbo].[ERS_VW_Patients] Patients
, [dbo].[ERS_Sites] GISites
, [dbo].[ERS_UpperGITherapeutics] GITherapy
Where GISites.ProcedureId=Procs.ProcedureId
And GITherapy.SiteId=GISites.SiteId
And Patients.[PatientId]=Procs.PatientId
And Procs.[ProcedureType]=1

GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_Placements', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
/* [dbo].[fw_Placements] */
Create View [dbo].[fw_Placements] As
Select * From fw_UGI_Placements
Union All
Select * From fw_ERS_Placements
'
END
ELSE
BEGIN
	SET @sql = '
/* [dbo].[fw_Placements] */
Create View [dbo].[fw_Placements] As
Select * From fw_ERS_Placements
'
END
EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_RepeatOGD', 'V';
GO


DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_RepeatOGD] As
		SELECT
			''U.1.''+Convert(Varchar(10),[AUpper GI Gastric Ulcer/Malignancy].[Episode No])+''.''+Convert(Varchar(10),Convert(Int,SubString([AUpper GI Gastric Ulcer/Malignancy].[Patient No],7,6)))+''.''+Convert(varchar(10),[AUpper GI Gastric Ulcer/Malignancy].[Site No]) As SiteId,
			Convert(nvarchar(10),Convert(Date,GetDate())) As [RequestedDate],
			Case [Ulcer number] When 0 Then ''Gastric ulcer'' Else ''Ulcer ''+convert(nvarchar(10),[Ulcer number]) End
			+ Case [Ulcer type] When 1 Then '' acute'' When 2 Then '' chronic'' Else '''' End 
			+ Case When [Ulcer largest]<>0 Then
					Case When [Ulcer number]>1 Then '' (largest diameter ''+convert(nvarchar(10),[Ulcer largest])+'' cm)'' Else '' (diameter ''+convert(nvarchar(10),[Ulcer largest])+'' cm)'' End
				Else '''' End
			+ Case When [Ulcer active bleeding]=0 Then '' active bleeding'' Else
					Case [Ulcer active bleeding type] When 1 Then '' (spurting)'' When 2 Then '' (oozing)'' Else '''' End
				End
			+ Case When [Ulcer clot in base]=0 Then '' fresh clot in base'' Else '''' End
			+ Case When [Ulcer visible vessel]=0 Then '' visible vessel''
					+ Case [Ulcer visible vessel type] When 1 Then '' with adherent clot in base'' When 2 Then '' with pigmented base'' Else '''' End
				Else '''' End
			+ Case When [Ulcer old blood]=0 Then '' overlying old blood'' Else '''' End
			+ Case When [Ulcer malignant appearance]=0 Then '' malignant appearance'' Else '''' End
			+ Case When [Ulcer perforation]=0 Then '' perforation'' Else '''' End
			+ '': ''+[Region]+''. ''
			As SummaryText,
			Case When [AUpper GI Gastric Ulcer/Malignancy].[Not healed]=-1 Then
				''V''
			Else
				Case When GetDate()>[Procedure date]+84 Then
					''X''
				Else
					''?''
				End
			End
			As Result,
			Case When (Case When [AUpper GI Gastric Ulcer/Malignancy].[Not healed]=-1 Then ''V'' Else Case When GetDate()>[Procedure date]+84 Then ''X'' Else ''?'' End End) = ''V'' Then 1 Else 0 End As [SeenWithin12weeks],
			Case When (Case When [AUpper GI Gastric Ulcer/Malignancy].[Not healed]=-1 Then ''V'' Else Case When GetDate()>[Procedure date]+84 Then ''X'' Else ''?'' End End) = ''X'' Then 1 Else 0 End As [NotSeenWithin12Weeks],
			Case When (Case When [AUpper GI Gastric Ulcer/Malignancy].[Not healed]=-1 Then ''V'' Else Case When GetDate()>[Procedure date]+84 Then ''X'' Else ''?'' End End) = ''?'' Then 1 Else 0 End As [StillToBeSeen],
			Case When GetDate()>[Procedure date]+84 Then
				''Seen ''+Convert(nvarchar(10),Convert(int,(Convert(datetime,GetDate()-[Procedure date])))/7)+'' weeks ago.''
			Else 
				''To be seen by ''+Convert(nvarchar(20),Datepart(dd,Convert(date,[Procedure date]+84)))+'' ''+Convert(nvarchar(20),datepart(mm,Convert(date,[Procedure date]+84)))+'' ''+Convert(nvarchar(20),Datepart(yy,Convert(date,[Procedure date]+84)))+'' (Within ''
				+Convert(nvarchar(10),
					Convert(nvarchar(10),
						Convert(int,Convert(int,Convert(datetime,([Procedure date]+84.0)-GetDate()))/7.0)
					)
				)
				+'' weeks).''
			End +
			Case When [AUpper GI Gastric Ulcer/Malignancy].[Healed ulcer]=0 Then -- Switch -1/0?
				'' Healed''
				Else ''''
			End +
			Case When [AUpper GI Gastric Ulcer/Malignancy].[Not healed]=-1 Then '' No OGD carried out'' Else '''' End+
			Case When [Healing Ulcer]=0 Then -- Switch -1/0?
				Case [Healing Ulcer Type] When 0 Then '''' When 1 Then '' Early healing (regenerative mucosa evident)'' When 2 Then '' Advanced healing (almost complete re-epithelialisation).'' When 3 Then '' ''''Red Scar'''' stage.'' When 4 Then '' Ulcer Scar Deformity.'' When 5 Then '' Atypical? Early gastric cancer.'' Else '' Unknow'' End
			Else
				''''
			End +
			Case When ([Healing Ulcer]<>-1) And ([AUpper GI Gastric Ulcer/Malignancy].[Not healed]<>-1) And (IsNull([AUpper GI Gastric Ulcer/Malignancy].[Healed ulcer],0)<>-1) Then '' (No ulcer data recorded).'' Else '''' End
			As [HealingText]
		FROM [AUpper GI Gastric Ulcer/Malignancy]
			INNER JOIN [Upper GI Sites] ON  
				([AUpper GI Gastric Ulcer/Malignancy].[Site No] = [Upper GI Sites].[Site No]) AND 
				([AUpper GI Gastric Ulcer/Malignancy].[Episode No] = [Upper GI Sites].[Episode No]) AND 
				([AUpper GI Gastric Ulcer/Malignancy].[Patient No] = [Upper GI Sites].[Patient No])
			INNER JOIN [Patient] ON 
				convert(int,SubString([AUpper GI Gastric Ulcer/Malignancy].[Patient No],7,6)) = Patient.[Patient No]
			INNER JOIN [Upper GI Procedure] ON 
				convert(int,SubString([Upper GI Procedure].[Patient No],7,6)) = Patient.[Patient No] AND
				[Upper GI Procedure].[Episode No]=[Upper GI Sites].[Episode No] And [Upper GI Procedure].[Procedure date] Is Not Null
		 WHERE (NOT Continuous=0 OR [Continuous start]=0) and ulcer=-1
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_RepeatOGD', 'V';
GO

Create View [dbo].[fw_ERS_RepeatOGD] As
Select 
	'E.'+Convert(varchar(10),Sites.SiteId) As SiteId,
	Convert(nvarchar(10),Convert(Date,GetDate())) As [RequestedDate],
	Case When Ulcers.UlcerNumber<>0 Then 'Ulcer Number '+Convert(nvarchar(10),Ulcers.UlcerNumber) Else 'No Ulcer Number' End
	+ Case Ulcers.UlcerType When 1 Then ' acute' When 2 Then ' chronic' Else '' End
	+ Case When Ulcers.UlcerLargestDiameter<>1 Then
			Case When Ulcers.[UlcerNumber]>0 Then ' (largest diameter '+convert(nvarchar(10),Ulcers.UlcerLargestDiameter)+' cm)' Else ' (diameter '+convert(nvarchar(10),Ulcers.UlcerLargestDiameter)+' cm)' End
		Else '' End
	+ Case When Ulcers.[UlcerActiveBleeding]=1 Then ' active bleeding' Else
			Case Ulcers.[UlcerActiveBleedingtype] When 1 Then ' (spurting)' When 2 Then ' (oozing)' Else '' End
		End
	+ Case When Ulcers.[UlcerClotInBase]=1 Then ' fresh clot in base' Else '' End
	+ Case When Ulcers.[UlcerVisibleVesselType]=1 Then ' visible vessel'
			+ Case Ulcers.[UlcerVisibleVesselType] When 1 Then ' with adherent clot in base' When 2 Then ' with pigmented base' Else '' End
		Else '' End
	+ Case When Ulcers.[UlcerOldBlood]=1 Then ' overlying old blood' Else '' End
	+ Case When Ulcers.[UlcerMalignantAppearance]=1 Then 
		' malignant appearance' + Case When Ulcers.[UlcerPerforation]=1 Then ' associated with perforation' Else '' End
	Else 
		Case When Ulcers.[UlcerPerforation]=1 Then ' perforation' Else '' End
	End

	+ ': '+Regions.Region+'. '
	As SummaryText,
	Case When Ulcers.[NotHealed]=1 Then
		'V'
	Else
		Case When GetDate()>[CreatedOn]+84 Then
			'X'
		Else
			'?'
		End
	End
	As Result,
	Case When (Case When Ulcers.[NotHealed]=1 Then 'X' Else Case When GetDate()>[CreatedOn]+84 Then 'X' Else '?' End End) = 'V' Then 1 Else 0 End As [SeenWithin12Weeks],
	Case When (Case When Ulcers.[NotHealed]=1 Then 'X' Else Case When GetDate()>[CreatedOn]+84 Then 'X' Else '?' End End) = 'X' Then 1 Else 0 End As [NotSeenWithin12Weeks],
	Case When (Case When Ulcers.[NotHealed]=1 Then 'X' Else Case When GetDate()>[CreatedOn]+84 Then 'X' Else '?' End End) = '?' Then 1 Else 0 End As [StillToBeSeen],
	Case When GetDate()>Procedures.[CreatedOn]+84 Then
		'Seen '+Convert(nvarchar(10),Convert(int,(Convert(datetime,GetDate()-Procedures.[CreatedOn])))/7)+' weeks ago.'
	Else 
		'To be seen by '+Convert(nvarchar(20),Datepart(dd,Convert(date,Procedures.[CreatedOn]+84)))+' '+Convert(nvarchar(20),datepart(mm,Convert(date,Procedures.[CreatedOn]+84)))+' '+Convert(nvarchar(20),Datepart(yy,Convert(date,Procedures.[CreatedOn]+84)))+' (Within '+Convert(nvarchar(10),(Convert(nvarchar(10),Convert(int,(Convert(datetime,Procedures.[CreatedOn]+84-GetDate())))/7)))+' weeks).'
	End +
	Case When Ulcers.[HealedUlcer]=1 Then ' Healed' Else '' End +
	Case When Ulcers.[NotHealed]=1 Then ' No OGD carried out' Else '' End+
	Case When Ulcers.[HealingUlcer]=1 Then 
		Case Ulcers.[HealingUlcerType] When 0 Then '' When 1 Then ' Early healing (regenerative mucosa evident)' When 2 Then ' Advanced healing (almost complete re-epithelialisation).' When 3 Then ' ''Red Scar'' stage.' When 4 Then ' Ulcer Scar Deformity.' When 5 Then ' Atypical? Early gastric cancer.' Else ' Unknow' End
	Else
		''
	End +
	Case When (Ulcers.[HealingUlcer]<>0) And (Ulcers.[NotHealed]<>0) And (IsNull(Ulcers.[HealedUlcer],0)<>0) Then ' (No ulcer data recorded).' Else '' End
	As [HealingText]
From 
[dbo].[ERS_VW_Patients] Patients,
[dbo].[ERS_Procedures] Procedures,
[dbo].[ERS_Sites] Sites,
[dbo].[ERS_Regions] Regions,
[dbo].[ERS_UpperGIAbnoGastricUlcer] Ulcers
Where
Patients.[PatientId]=Procedures.PatientId And
Procedures.ProcedureId=Sites.ProcedureId And
Sites.SiteId=Ulcers.SiteId And
Sites.RegionId=Regions.RegionId
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_RepeatOGD', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_RepeatOGD] As
SELECT * From [dbo].[fw_UGI_RepeatOGD]
Union All 
SELECT * From [dbo].[fw_ERS_RepeatOGD]
'
END
ELSE
BEGIN
	SET @sql = '
Create View [dbo].[fw_RepeatOGD] As
SELECT * From [dbo].[fw_ERS_RepeatOGD]
'
END

EXEC sp_executesql @sql
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_Premedication', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_Premedication] As
SELECT 
	''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	,PM.[Drug No] As DrugId
	, PM.Dose
	, D.Units
	, PM.[Drug No] As OrderId
	, D.[Drug name] As DrugName
	, Case When D.[Is reversing agent]=-1 Then 1 Else 0 End As IsReversingAgent
FROM Episode E, [Patient premedication] PM, [Drug list] D
Where E.[Episode No]=PM.[Episode No] And PM.[Drug No]=D.[Drug no]'
END
EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_Premedication', 'V';
GO

Create View [dbo].[fw_ERS_Premedication]
--WITH SCHEMABINDING 
AS
Select 
	'E.'+Convert(varchar(10),PM.ProcedureId) As ProcedureId
	, PM.DrugNo As DrugId
	, PM.Dose
	, D.Units
	, ROW_NUMBER() Over (Order By PM.ProcedureId) As OrderId
	, D.DrugName, D.IsReversingAgent
From [dbo].[ERS_UpperGIPremedication] PM, [dbo].[ERS_DrugList] D
Where PM.DrugNo=D.DrugNo
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_Premedication', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_Premedication] As
SELECT * FROM [dbo].[fw_UGI_Premedication]
UNION ALL
SELECT * FROM [dbo].[fw_ERS_Premedication]
'
END
ELSE
BEGIN
	SET @sql = '
Create View [dbo].[fw_Premedication] As
SELECT * FROM [dbo].[fw_ERS_Premedication]
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_Insertions', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_Insertions] As
Select 
	''U.1.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+''.''+Convert(VARCHAR(10),S.[Site No]) As SiteId,
	Case Therapy.[Gastrostomy Insertion (PEG)] When -1 Then ''PEG'' Else '''' End As [InsertionType],
	Case Therapy.[Correct PEG/PEJ placement] When 1 Then 1 Else 0 End [Correct_Placement],
	Case Therapy.[Correct PEG/PEJ placement] When 1 Then 0 Else 1 End [Incorrect_Placement]
From 
	[dbo].[Upper GI Procedure] PR
	, Episode E
	,[dbo].[Upper GI Sites] S
	,[dbo].[Upper GI Therapeutic] Therapy
Where 
	E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No]
	And E.[Episode No]=S.[Episode No] And E.[Patient No]=S.[Patient No]
	And Therapy.[Episode No]=S.[Episode No] And Therapy.[Patient No]=S.[Patient No] And Therapy.[Site No]=S.[Site No]
	And [Gastrostomy Insertion (PEG)]=-1
GO
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_Insertions', 'V';
GO

Create View [dbo].[fw_ERS_Insertions] As
Select 
	'E.'+Convert(VARCHAR(10),T.SiteId) As SiteId,
	Case When T.GastrostomyInsertion=1 Then 'PEG' Else '' END As [InsertionType], 
	Case When T.CorrectPEGPlacement=1 Then 1 Else 0 End As [Correct_Placement],
	Case When T.CorrectPEGPlacement=1 Then 0 Else 1 End As [Incorrect_Placement]
From ERS_UpperGITherapeutics T Where T.GastrostomyInsertion=1
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_Insertions', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_Insertions] As
Select * From fw_UGI_Insertions
Union All
Select * From fw_ERS_Insertions
'
END
ELSE
BEGIN
	SET @sql = '
Create View [dbo].[fw_Insertions] As
Select * From fw_ERS_Insertions
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_ColonExtentOfIntubation', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_ColonExtentOfIntubation] As
Select 
	''U.''+Convert(varchar(3),CP.[Procedure type]+3)+''.''+Convert(varchar(10),E.[Episode No])+''.''+Convert(Varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	, 1 As Insertion
	, Case EL.[Insertion complete] When -1 Then 1 Else 0 End As InsertionComplete
	, Case EL.[Insertion to caecum] When -1 Then 1 Else 0 End As InsertionToCaecum
    , Case EL.[Insertion to terminal ilium] When -1 Then 1 Else 0 End As InsertionToTerminalIleum
	, Case EL.[Insertion to neo-terminal ilium] When -1 Then 1 Else 0 End As InsertionToNeoTerminalIleum
	, Case EL.[Insertion to anastomosis] When -1 Then 1 Else 0 End As InsertionToAnastomosis
	, 1-Case EL.[Insertion complete] When -1 Then 1 Else 0 End-Case EL.[Insertion to caecum] When -1 Then 1 Else 0 End-Case EL.[Insertion to terminal ilium] When -1 Then 1 Else 0 End-Case EL.[Insertion to neo-terminal ilium] When -1 Then 1 Else 0 End-Case EL.[Insertion to anastomosis] When -1 Then 1 Else 0 End As InsertionFailed
	, Case EL.[Insertion via] When 0 Then ''anus'' When 1 Then ''colostomy'' When 2 Then ''loop colostomy'' When 3 Then ''caecostomy'' When 4 Then ''ileostomy'' Else '''' End As InsertionVia
	, Case EL.[Rectal exam (PR)] When 1 Then ''Not done'' Else ''Done'' End As RectalExam
	, Case EL.[Retroflexion in rectum] When 1 then ''Not done'' Else ''Done'' End As Retroflexion
	, Case When EL.[Specific distance]=-1 Then ''Specific distance'' Else '''' End
	+Case When EL.[Insertion not recorded]=-1 Then ''Not recorded'' Else '''' End
	+Case When EL.[Insertion complete]=-1 Then ''Complete'' Else '''' End
	+Case When EL.[Insertion to proximal sigmoid]=-1 Then ''Proximal sigmoid'' Else '''' End
	+Case When EL.[Insertion to mid transverse]=-1 Then ''Mid transverse'' Else '''' End
	+Case When EL.[Insertion to caecum]=-1 Then ''Caecum'' Else '''' End
	+Case When EL.[Insertion to distal descending]=-1 Then ''Distal descending'' Else '''' End
	+Case When EL.[Insertion to proximal transverse]=-1 Then ''Proximal transverse'' Else '''' End
	+Case When EL.[Insertion to terminal ilium]=-1 Then ''Terminal ileum'' Else '''' End
	+Case When EL.[Insertion to rectum]=-1 Then ''Rectum'' Else '''' End
	+Case When EL.[Insertion to proximal descending]=-1 Then ''Proximal descending'' Else '''' End
	+Case When EL.[Insertion to hepatic flexure]=-1 Then ''Hepatic flexure'' Else '''' End
	+Case When EL.[Insertion to terminal ilium]=-1 Then ''Neo-terminal ileum'' Else '''' End
	+Case When EL.[Insertion to recto sigmoid]=-1 Then ''Recto-sigmoid'' Else '''' End
	+Case When EL.[Insertion to splenic flexure]=-1 Then ''Splenic flexure'' Else '''' End
	+Case When EL.[Insertion to distal ascending]=-1 Then ''Distal ascending'' Else '''' End
	+Case When EL.[Insertion to distal sigmoid]=-1 Then ''Distal sigmoid'' Else '''' End
	+Case When EL.[Insertion to distal transverse]=-1 Then ''Distal transverse'' Else '''' End
	+Case When EL.[Insertion to proximal ascending]=-1 Then ''Proximal ascending'' Else '''' End
	+Case When EL.[Insertion to anastomosis]=-1 Then ''Anastomosis'' Else '''' End
	 As InsertedTo
	, EL.[Specific distance] As EspecificDistance
	, Case EL.[Insertion confirmed by]
	When 0 Then ''(none)''
	When 1 Then ''Photo''
	When 2 Then ''Anastomosis''
	When 3 Then ''Tri radiate fold''
	When 4 Then ''Ileocaecal valve''
	Else '''' End As ConfirmedBy
	, Case EL.[Insertion limited by] 
	When 0 Then ''(none)''
	When 1 Then ''patient discomfort''
	When 2 Then ''inadequate bowel preparation''
	When 3 Then ''excess looping''
	When 4 Then ''bowel redundancy''
	When 5 Then ''instrument inadequacy''
	When 6 Then ''pathology encountered''
	When 7 Then ''excess blood''
	Else '''' End As LimitedBy
	, Case EL.[Difficulties encountered]
	When 0 Then ''(none)'' 
	When 1 Then ''Deep seated caecum'' 
	When 2 Then ''tortuous colon'' 
	Else '''' End As DifficultiesEncountered
From 
	[Colon Extent/Limiting Factors] EL, Episode E, [Colon Procedure] CP
Where EL.[Episode No]=E.[Episode No] And EL.[Patient No]=E.[Patient No]
And E.[Episode No]=CP.[Episode No] And E.[Patient No]=CP.[Patient No] And CP.[Procedure date] Is Not Null
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_ColonExtentOfIntubation', 'V';
GO

Create View [dbo].[fw_ERS_ColonExtentOfIntubation] As
Select 
	'E.'+Convert(varchar(10),EI.ProcedureId) As ProcedureId
	, 1 As Insertion
	, Case When EI.InsertionTo In (6,5,9,13,15) Then 1 Else 0 End As InsertionComplete
	, Case When EI.InsertionTo=5 Then 1 Else 0 End As InsertionToCaecum
    , Case When EI.InsertionTo=9 Then 1 Else 0 End As InsertionToTerminalIleum
	, Case When EI.InsertionTo=13 Then 1 Else 0 End As InsertionToNeoTerminalIleum
	, Case When EI.InsertionTo=15 Then  1 Else 0 End As InsertionToAnastomosis
	, 1-Case When EI.InsertionTo=6 Then 1 Else 0 End-Case When EI.InsertionTo=5 Then 1 Else 0 End-Case When EI.InsertionTo=9 Then 1 Else 0 End-Case When EI.InsertionTo=13 Then 1 Else 0 End-Case When EI.InsertionTo=15 Then 1 Else 0 End As InsertionFailed
	, Case EI.InsertionVia When 1 Then 'anus' When 2 Then 'colostomy' When 3 Then 'loop colostomy' When 4 Then 'caecostomy' When 5 Then 'ileostomy' Else'' End As InsertionVia
	, Case EI.RectalExam When 0 Then 'Not done' Else 'Done' End As RectalExam
	, Case EI.Retroflexion When 0 Then 'Not done' Else 'Done' End As Retroflexion
	, Case EI.InsertionTo
	When 1 then 'Specific distance'
	When 2 then 'Not recorded'
	When 3 then 'Proximal sigmoid'
	When 4 then 'Mid transverse '
	When 5 then 'Caecum'
	When 6 then 'Complete'
	When 7 then 'Distal descending'
	When 8 then 'Proximal transverse'
	When 9 then 'Terminal ileum'
	When 10 then 'Rectum'
	When 11 then 'Proximal descending'
	When 12 then 'Hepatic flexure'
	When 13 then 'Neo-terminal ileum'
	When 14 then 'Recto-sigmoid'
	When 15 then 'Splenic flexure'
	When 16 then 'Distal ascending'
	When 17 then 'Distal sigmoid'
	When 18 then 'Distal transverse'
	When 19 then 'Proximal ascending'
	When 20 then 'Anastomosis' End As InsertedTo
	, EI.SpecificDistanceCm As EspecificDistance
	, Case EI.InsertionConfirmedBy When 0 Then '(none)' Else '' End As ConfirmedBy
	, Case EI.InsertionLimitedBy
	When 0 Then '(none)'
	When 1 Then 'bowel redundancy'
	When 2 Then 'excess blood'
	When 3 Then 'excess looping'
	When 4 Then 'inadequate bowel preparation'
	When 5 Then 'instrument inadequacy'
	When 6 Then 'pathology encountered'
	When 7 Then 'excess blood'
	Else '' End
	AS LimitedBy
	, Case EI.DifficultiesEncountered 
	When 0 Then '(none)' 
	When 1 Then 'Deep seated caecum' 
	When 2 Then 'tortuous colon' 
	Else '' End As DifficultiesEncountered
From ERS_ColonExtentOfIntubation EI, ERS_Procedures PR
	Where EI.ProcedureId=PR.ProcedureId
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ColonExtentOfIntubation', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_ColonExtentOfIntubation] As
Select * From fw_UGI_ColonExtentOfIntubation
Union All
SELECT * FROM fw_ERS_ColonExtentOfIntubation
'
END
ELSE
BEGIN
	SET @sql = '
Create View [dbo].[fw_ColonExtentOfIntubation] As
SELECT * FROM fw_ERS_ColonExtentOfIntubation
'
END

EXEC sp_executesql @sql
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------

EXEC DropIfExist 'fw_UGI_Lesions', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_Lesions]
--WITH SCHEMABINDING
AS
SELECT SiteId, NoLesions
, RTRIM(SUBSTRING(Data,1,16)) AS LesionType
, SUBSTRING(Data,17,5) AS Quantity
, SUBSTRING(Data,22,5) AS Largest
, SUBSTRING(Data,27,5) AS Excised
, SUBSTRING(Data,32,5) AS Retrieved
, SUBSTRING(Data,37,5) AS ToLabs
, SUBSTRING(Data,42,1) AS [Type]
, CASE WHEN SUBSTRING(Data,43,1)=1 THEN ''benign'' ELSE ''malignant'' END AS Probably
, CASE SUBSTRING(Data,44,1) WHEN ''1'' THEN ''lp - pedunculated''WHEN 2 THEN ''lsp - subpedunculated'' ELSE '''' END AS ParisClass
, CASE SUBSTRING(Data,45,1) WHEN 1 THEN ''Type I'' WHEN 2 THEN ''Type II'' WHEN 3 THEN ''Type III s'' WHEN 4 THEN ''Type III L'' WHEN 5 THEN ''Type IV'' WHEN 6 THEN ''Type V'' ELSE '''' END AS PitPattern
FROM 
(SELECT 
	''U.''+Convert(varchar(3),Case When CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10))=''3'' Then IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) Else CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) End)+''.''+Convert(Varchar(10),E.[Episode No])+''.''+Convert(Varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+''.''+convert(varchar(10),L.[Site No]) As SiteId
    ,Case When [Lesions none]=-1 Then 1 Else 0 End As [NoLesions]
	,Case When [Sessile]=-1 Then ''Sessile         ''
		+CONVERT(Char(5),ISNULL([Sessile quantity],0))
		+CONVERT(CHAR(5),ISNULL([Sessile largest],0))
		+CONVERT(CHAR(5),IsNull([Sessile excised],0))
		+CONVERT(CHAR(5),IsNull([Sessile retrieved],0))
		+CONVERT(CHAR(5),ISNULL([Sessile to labs],0))
		+CONVERT(CHAR(1),ISNULL([Sessile type],0))
		+CONVERT(CHAR(1),Case When ISNULL([Sessile probably],0)=-1 Then 1 Else 0 End)
		+CONVERT(CHAR(1),ISNULL([Paris class sessile],0))
		+CONVERT(CHAR(1),ISNULL([Pit pattern sessile],0))
		END As SessileData
	,Case When L.Predunculated=-1 Then ''Peduncular      ''
		+CONVERT(Char(5),ISNULL([Predunculated quantity],0))
		+CONVERT(CHAR(5),ISNULL([Predunculated largest],0))
		+CONVERT(CHAR(5),IsNull([Predunculated excised],0))
		+CONVERT(CHAR(5),IsNull([Predunculated retrieved],0))
		+CONVERT(CHAR(5),ISNULL([Predunculated to labs],0))
		+CONVERT(CHAR(1),ISNULL([Pedunculated Type],0))
		+CONVERT(CHAR(1),Case When ISNULL([Pedunculated probably],0)=-1 Then 1 Else 0 End)
		+CONVERT(CHAR(1),ISNULL([Paris class pedunculated],0))
		+CONVERT(CHAR(1),ISNULL([Pit pattern pedunculated],0))
		End As PeduncularData
	,Case When L.Submucosal=-1 Then ''Submucosal      '' 
		+CONVERT(Char(5),ISNULL([Submucosal quantity],0))
		+CONVERT(CHAR(5),ISNULL([Submucosal largest],0))
		+CONVERT(CHAR(5),IsNull([Submucosal excised],0))
		+CONVERT(CHAR(5),IsNull([Submucosal retrieved],0))
		+CONVERT(CHAR(5),ISNULL([Submucosal to labs],0))
		+CONVERT(CHAR(1),ISNULL([Submucosal type],0))
		+CONVERT(CHAR(1),Case When ISNULL([Submucosal probably],0)=-1 Then 1 Else 0 End )
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As SubmucosalData
	,Case When L.Villous=-1 Then ''Villous         '' 
		+CONVERT(Char(5),ISNULL([Villous quantity],0))
		+CONVERT(CHAR(5),ISNULL([Villous largest],0))
		+CONVERT(CHAR(5),IsNull([Villous excised],0))
		+CONVERT(CHAR(5),IsNull([Villous retrieved],0))
		+CONVERT(CHAR(5),ISNULL([Villous to labs],0))
		+CONVERT(CHAR(1),ISNULL([Villous Type],0))
		+CONVERT(CHAR(1),Case When ISNULL([Villous probably],0)=-1 Then 1 Else 0 End)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As VillousData
	,Case When L.[Ulcerative]=-1 Then ''Ulcerative      '' 
		+CONVERT(Char(5),ISNULL([Ulcerative quantity],0))
		+CONVERT(CHAR(5),ISNULL([Ulcerative largest],0))
		+CONVERT(CHAR(5),IsNull([Ulcerative excised],0))
		+CONVERT(CHAR(5),IsNull([Ulcerative retrieved],0))
		+CONVERT(CHAR(5),ISNULL([Ulcerative to labs],0))
		+CONVERT(CHAR(1),ISNULL([Ulcerative type],0))
		+CONVERT(CHAR(1),Case When ISNULL([Ulcerative probably],0)=-1 Then 1 Else 0 End)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As UlcerativeData
	,Case When L.[Stricturing]=-1 Then ''Stricturing     '' 
		+CONVERT(Char(5),ISNULL([Stricturing quantity],0))
		+CONVERT(CHAR(5),ISNULL([Stricturing largest],0))
		+CONVERT(CHAR(5),IsNull([Stricturing excised],0))
		+CONVERT(CHAR(5),IsNull([Stricturing retrieved],0))
		+CONVERT(CHAR(5),ISNULL([Stricturing to labs],0))
		+CONVERT(CHAR(1),ISNULL([Stricturing type],0))
		+CONVERT(CHAR(1),Case When ISNULL([Stricturing probably],0)=-1 Then 1 Else 0 End)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As StricturingData
	,Case When L.[Polypoidal]=-1 Then ''Polypoidal      '' 
		+CONVERT(Char(5),ISNULL([Polypoidal quantity],0))
		+CONVERT(CHAR(5),ISNULL([Polypoidal largest],0))
		+CONVERT(CHAR(5),IsNull([Polypoidal excised],0))
		+CONVERT(CHAR(5),IsNull([Polypoidal retrieved],0))
		+CONVERT(CHAR(5),ISNULL([Polypoidal to labs],0))
		+CONVERT(CHAR(1),ISNULL([Polypoidal type],0))
		+CONVERT(CHAR(1),Case When ISNULL([Polypoidal probably],0)=-1 Then 1 Else 0 End)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As PolypoidalData
	,Case When L.[Granuloma]=-1 Then ''Granuloma       '' 
		+CONVERT(Char(5),ISNULL([Granuloma quantity],0))
		+CONVERT(CHAR(5),ISNULL([Granuloma largest],0))
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As GranulomaData
	,Case When L.[Dysplastic]=-1 Then ''Dysplastic      '' 
		+CONVERT(Char(5),ISNULL([Dysplastic  quantity],0))
		+CONVERT(CHAR(5),ISNULL([Dysplastic largest],0))
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As DysplasticData
	,Case When L.[Pneumatosis Coli]=-1 Then ''Pneumatosis Coli'' 
		+CONVERT(Char(5),1)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As PneumatosisColiData
  FROM [dbo].[AColon Lesions] L, [dbo].[Episode] E
  Where L.[Episode No]=E.[Episode No] And L.[Patient No]=E.[Patient No]
) AS L1
UNPIVOT (Data FOR DataId In (SessileData, PeduncularData, SubmucosalData, VillousData, UlcerativeData, StricturingData, PolypoidalData, GranulomaData, DysplasticData, PneumatosisColiData)) AS L2
'
END

EXEC sp_executesql @sql
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------

EXEC DropIfExist 'fw_ERS_Lesions', 'V';
GO

/* [dbo].[fw_ERS_Lesions] */
Create View [dbo].[fw_ERS_Lesions]
--WITH SCHEMABINDING
AS
SELECT SiteId, NoLesions
, RTRIM(SUBSTRING(Data,1,16)) AS LesionType
, SUBSTRING(Data,17,5) AS Quantity
, SUBSTRING(Data,22,5) AS Largest
, SUBSTRING(Data,27,5) AS Excised
, SUBSTRING(Data,32,5) AS Retrieved
, SUBSTRING(Data,37,5) AS ToLabs
, SUBSTRING(Data,42,1) AS [Type]
, CASE WHEN SUBSTRING(Data,43,1)=1 THEN 'benign' ELSE 'malignant' END AS Probably
, CASE SUBSTRING(Data,44,1) WHEN '1' THEN 'lp - pedunculated'WHEN 2 THEN 'lsp - subpedunculated' ELSE '' END AS ParisClass
, CASE SUBSTRING(Data,45,1) WHEN 1 THEN 'Type I' WHEN 2 THEN 'Type II' WHEN 3 THEN 'Type III s' WHEN 4 THEN 'Type III L' WHEN 5 THEN 'Type IV' WHEN 6 THEN 'Type V' ELSE '' END AS PitPattern
FROM 
(SELECT 
	'E.'+CONVERT(NVARCHAR(10),L.SiteId) As SiteId
    ,IsNull([None],0) As [NoLesions]
	,Case When IsNull([Sessile],0)=1 Then 'Sessile         '
		+CONVERT(Char(5),ISNULL([SessileQuantity],0))
		+CONVERT(CHAR(5),ISNULL([SessileLargest],0))
		+CONVERT(CHAR(5),IsNull([SessileExcised],0))
		+CONVERT(CHAR(5),IsNull([SessileRetrieved],0))
		+CONVERT(CHAR(5),ISNULL([SessileToLabs],0))
		+CONVERT(CHAR(1),ISNULL([SessileType],0))
		+CONVERT(CHAR(1),ISNULL([SessileProbably],0))
		+CONVERT(CHAR(1),ISNULL([SessileParisClass],0))
		+CONVERT(CHAR(1),ISNULL([SessilePitPattern],0))
		END As SessileData
	,Case When L.[Pedunculated]=1 Then 'Peduncular      '
		+CONVERT(Char(5),ISNULL([PedunculatedQuantity],0))
		+CONVERT(CHAR(5),ISNULL([PedunculatedLargest],0))
		+CONVERT(CHAR(5),IsNull([PedunculatedExcised],0))
		+CONVERT(CHAR(5),IsNull([PedunculatedRetrieved],0))
		+CONVERT(CHAR(5),ISNULL([PedunculatedToLabs],0))
		+CONVERT(CHAR(1),ISNULL([PedunculatedType],0))
		+CONVERT(CHAR(1),ISNULL([PedunculatedProbably],0))
		+CONVERT(CHAR(1),ISNULL([PedunculatedParisClass],0))
		+CONVERT(CHAR(1),ISNULL([PedunculatedPitPattern],0))
		End As PeduncularData
	,Case When L.[Submucosal]=1 Then 'Submucosal      ' 
		+CONVERT(Char(5),ISNULL([SubmucosalQuantity],0))
		+CONVERT(CHAR(5),ISNULL([SubmucosalLargest],0))
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(1),ISNULL([SubmucosalType],0))
		+CONVERT(CHAR(1),ISNULL([SubmucosalProbably],0))
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As SubmucosalData
	,Case When L.[Villous]=1 Then 'Villous         ' 
		+CONVERT(Char(5),ISNULL([VillousQuantity],0))
		+CONVERT(CHAR(5),ISNULL([VillousLargest],0))
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),ISNULL([VillousProbably],0))
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As VillousData
	,Case When L.[Ulcerative]=1 Then 'Ulcerative      ' 
		+CONVERT(Char(5),ISNULL([UlcerativeQuantity],0))
		+CONVERT(CHAR(5),ISNULL([UlcerativeLargest],0))
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(1),ISNULL([UlcerativeType],0))
		+CONVERT(CHAR(1),ISNULL([UlcerativeProbably],0))
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As UlcerativeData
	,Case When L.[Stricturing]=1 Then 'Stricturing     ' 
		+CONVERT(Char(5),ISNULL([StricturingQuantity],0))
		+CONVERT(CHAR(5),ISNULL([StricturingLargest],0))
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(1),ISNULL([StricturingType],0))
		+CONVERT(CHAR(1),ISNULL([StricturingProbably],0))
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As StricturingData
	,Case When L.[Polypoidal]=1 Then 'Polypoidal      ' 
		+CONVERT(Char(5),ISNULL([PolypoidalQuantity],0))
		+CONVERT(CHAR(5),ISNULL([PolypoidalLargest],0))
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(1),ISNULL([PolypoidalType],0))
		+CONVERT(CHAR(1),ISNULL([PolypoidalProbably],0))
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As PolypoidalData
	,Case When L.[Granuloma]=1 Then 'Granuloma       ' 
		+CONVERT(Char(5),ISNULL([GranulomaQuantity],0))
		+CONVERT(CHAR(5),ISNULL([GranulomaLargest],0))
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As GranulomaData
	,Case When L.[Dysplastic]=1 Then 'Dysplastic      ' 
		+CONVERT(Char(5),ISNULL([DysplasticQuantity],0))
		+CONVERT(CHAR(5),ISNULL([DysplasticLargest],0))
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As DysplasticData
	,Case When L.[PneumatosisColi]=1 Then 'Pneumatosis Coli' 
		+CONVERT(Char(5),1)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(5),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
	End As PneumatosisColiData
	,Case When L.[Pseudopolyps]=1 Then 'Pseudopolyp     '
		+CONVERT(Char(5),ISNULL([PseudopolypsQuantity],0))
		+CONVERT(CHAR(5),ISNULL([PseudopolypsLargest],0))
		+CONVERT(CHAR(5),IsNull([PseudopolypsExcised],0))
		+CONVERT(CHAR(5),IsNull([PseudopolypsRetrieved],0))
		+CONVERT(CHAR(5),ISNULL([PseudopolypsToLabs],0))
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		+CONVERT(CHAR(1),0)
		End As PseudopolypData
  FROM [dbo].[ERS_ColonAbnoLesions] L
) AS L1
UNPIVOT (Data FOR DataId In (SessileData, PeduncularData, SubmucosalData, VillousData, UlcerativeData, StricturingData, PolypoidalData, GranulomaData, DysplasticData, PneumatosisColiData, PseudopolypData)) AS L2
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_Lesions', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
/* [dbo].[fw_Lesions] */
Create View [dbo].[fw_Lesions] As
SELECT * FROM fw_UGI_Lesions
UNION ALL
SELECT * FROM fw_ERS_Lesions 
'
END
ELSE
BEGIN
	SET @sql = '
/* [dbo].[fw_Lesions] */
Create View [dbo].[fw_Lesions] As
SELECT * FROM fw_ERS_Lesions 
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_FailuresERCP', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_FailuresERCP] As
Select 
	''U.2.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+''.''+Convert(VARCHAR(10),T.[Site No]) As SiteId
	,Convert(bit,Case [Procs Papill/sphincterotomy] When -1 Then Case [Papillotomy] When -1 Then ''FALSE'' Else Case [Pan Orifice Sphincterotomy] When -1 Then ''FALSE'' Else ''TRUE'' End End Else ''FALSE'' End)
	| Convert(bit,Case [Procs Stent removal] 
		When -1 Then Case [Stent Removal] When -1 Then ''FALSE'' Else ''TRUE'' End Else ''FALSE'' End)
	| Convert(bit,Case [Procs Stent insertion] When -1 Then
		Case [Stent Insertion] When -1 Then 
			Case IsNull([Correct stent placement],1) When 1 Then ''FALSE'' Else ''TRUE'' End
		Else ''TRUE'' End
	Else ''FALSE'' End) 
	| Convert(bit,Case [Procs stent replacement] When -1 Then 
		Case [Stent insertion] When -1 Then 
			Case [Correct Stent placement] When 1 Then ''FALSE'' Else ''TRUE'' End
		Else ''FALSE'' End
	Else ''FALSE'' End) 
	| Convert(bit,Case [Procs naso drains] When -1 Then 
		Case [Nasopancreatic Drain] When -1 Then ''FALSE'' Else ''TRUE'' End
	Else ''FALSE'' End) 
	| Convert(bit,Case [Procs cyst puncture] When -1 Then 
		Case [Endoscopic Cyst Puncture] When -1 Then ''FALSE'' Else ''TRUE'' End
	Else ''FALSE'' End) 
	| Convert(bit,Case [Procs rendezvous] When -1 Then
		Case [Rendezvous procedure] When -1 Then ''FALSE'' Else ''TRUE'' End
	Else ''FALSE'' End) 
	| Convert(bit,Case [Procs stricture dilatation] When -1 Then
		Case [Correct stent placement] When 2 Then ''TRUE'' Else ''FALSE'' End
	Else ''FALSE'' End) 
	| Convert(bit,Case [Procs stone removal] When -1 Then 
		Case [Stone removal] When -1 Then 
			Case [Extraction outcome]
			When 1 Then ''FALSE''
			When 2 Then ''FALSE''
			When 3 Then ''TRUE''
			When 4 Then ''TRUE''
			Else 
				Case [Balloon Trawl] When -1 Then ''FALSE'' Else
					Case [Balloon Dilation] When -1 Then ''FALSE'' Else ''TRUE'' End
				End
			End
		Else ''FALSE'' End
	Else ''FALSE'' End) 
	As [Fails],
	Case IsNull(I.[Image obstruction CBD],0) When -1 Then Case IsNull([Stent decompressed],0) When 1 Then ''TRUE'' Else ''FALSE'' End   Else Case IsNull(I.[Clin obstruction cbd],0) When -1 Then ''TRUE'' Else ''FALSE'' End End As [DecompSuccess],
	Case IsNull(I.[Image obstruction CBD],0) When -1 Then Case IsNull([Stent decompressed],0) When 2 Then ''TRUE'' Else ''FALSE'' End Else Case IsNull(I.[Clin obstruction cbd],0) When -1 Then ''TRUE'' Else ''FALSE'' End End As [DecompUnsuccess],
	Case IsNull(I.[Image obstruction CBD],0) When -1 Then Case IsNull([Stent decompressed],0) When 1 Then ''FALSE'' When 2 Then ''FALSE'' Else ''FALSE'' End Else Case IsNull(I.[Clin obstruction cbd],0) When -1 Then ''TRUE'' Else ''FALSE'' End End As [DecompUnknow],
	Case IsNull(I.[Image obstruction CBD],0) When -1 Then ''TRUE'' Else ''FALSE'' End As [Decomp],
	Case [Procs stricture dilatation] When -1 Then 1 Else 0 End As [DecompressionDuctsProcedures],
	Convert(bit,Case [Procs stricture dilatation] When -1 Then
		Case [Correct stent placement] When 2 Then ''TRUE'' Else ''FALSE'' End
	Else ''FALSE'' End) As [StrictureDilatationFails]
From 
	[dbo].[ERCP Procedure] PR
	, [dbo].[ERS_VW_Patients] P
	, [dbo].[Episode] E
	, [dbo].[ERCP Indications] I
	, [dbo].[ERCP Therapeutic] T
Where
	P.[UGIPatientId]=convert(int,SubString(PR.[Patient No],7,6))
	And E.[Patient No]=PR.[Patient No] And E.[Episode No]=PR.[Episode No]
	And E.[Patient No]=I.[Patient No] And E.[Episode No]=I.[Episode No]
	And E.[Patient No]=T.[Patient No] And E.[Episode No]=T.[Episode No]
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_FailuresERCP', 'V';
GO

Create View [dbo].[fw_ERS_FailuresERCP] As
SELECT
'U.2.' + Convert(varchar(10), s.SiteId) AS SiteId,
  Convert(bit, CASE ISNULL(i.EplanPapillotomy, 0) WHEN 1 THEN CASE t.Papillotomy WHEN 1 THEN 'FALSE' ELSE CASE t.PanOrificeSphincterotomy WHEN 1 THEN 'FALSE' ELSE 'TRUE' END END ELSE 'FALSE' END) 
| Convert(bit,Case ISNULL(i.EplanStentremoval, 0) When 1 Then Case t.stentremoval When 1 Then 'FALSE' Else 'TRUE' End Else 'FALSE' End)
| Convert(bit,Case ISNULL(i.EplanStentInsertion, 0) When 1 Then Case t.StentInsertion When 1 Then Case IsNull(t.CorrectStentPlacement, 1) When 1 Then 'FALSE' Else 'TRUE' End Else 'TRUE' End Else 'FALSE' End) 
| Convert(bit,CASE ISNULL(i.EplanStentReplacement, 0) When 1 Then CASE t.StentInsertion When 1 Then CASE ISNULL(t.CorrectStentPlacement, 0) When 1 Then 'FALSE' Else 'TRUE' End Else 'FALSE' End Else 'FALSE' End) 
| Convert(bit,CASE ISNULL(i.EplanNasoPancreatic, 0) When 1 Then CASE t.NasopancreaticDrain When 1 Then 'FALSE' Else 'TRUE' End Else 'FALSE' End) 
| Convert(bit,CASE ISNULL(i.EPlanEndoscopicCyst, 0) When 1 Then Case t.EndoscopicCystPuncture When 1 Then 'FALSE' Else 'TRUE' End Else 'FALSE' End) 
| Convert(bit,CASE ISNULL(i.EplanCombinedProcedure, 0) When 1 Then CASE t.RendezvousProcedure When 1 Then 'FALSE' Else 'TRUE' End Else 'FALSE' End) 
| Convert(bit,CASE ISNULL(i.EplanStrictureDilatation, 0)  When 1 Then CASE ISNULL(t.CorrectStentPlacement, 0) When 0 Then 'TRUE' Else 'FALSE' End Else 'FALSE' End)
| Convert(bit,CASE ISNULL(i.EplanStoneRemoval, 0) When 1 Then CASE t.StoneRemoval When 1 Then 
			CASE ISNULL(t.ExtractionOutcome, 0)
			When 1 Then 'FALSE'
			When 2 Then 'FALSE'
			When 3 Then 'TRUE'
			When 4 Then 'TRUE'
			Else 
				CASE t.BalloonTrawl When 1 Then 'FALSE' Else
					CASE t.BalloonDilation When 1 Then 'FALSE' Else 'TRUE' End
				End
			End
		Else 'FALSE' End
	Else 'FALSE' End) 
	As [Fails],
Case ISNULL(i.ERSObstructed, 0) When 1 Then Case IsNull(t.StentDecompressedDuct, 0) When 0 Then 'TRUE' Else 'FALSE' End Else Case ISNULL(i.ERSObstructedCBD, 0) When 1 Then 'TRUE' Else 'FALSE' End End As [DecompSuccess],
Case ISNULL(i.ERSObstructed, 0) When 1 Then Case IsNull(t.StentDecompressedDuct, 0) When 1 Then 'TRUE' Else 'FALSE' End Else Case ISNULL(I.ERSObstructedCBD, 0) When 1 Then 'TRUE' Else 'FALSE' End End As [DecompUnsuccess],
Case ISNULL(i.ERSObstructed, 0) When 1 Then Case IsNull(t.StentDecompressedDuct, 0) When 0 Then 'FALSE' When 1 Then 'FALSE' Else 'FALSE' End Else Case ISNULL(I.ERSObstructedCBD, 0) When 1 Then 'TRUE' Else 'FALSE' End End As [DecompUnknow],
Case ISNULL(i.ERSObstructed, 0) When 1 Then 'TRUE' Else 'FALSE' End As [Decomp],
ISNULL(i.EplanStrictureDilatation, 0) AS [DecompressionDuctsProcedures],
Convert(bit,CASE ISNULL(i.EplanStrictureDilatation, 0) When 1 Then CASE ISNULL(t.CorrectStentPlacement, 0) When 1 Then 'TRUE' Else 'FALSE' End Else 'FALSE' End) As [StrictureDilatationFails]
FROM ERS_ERCPTherapeutics t
INNER JOIN dbo.ERS_Sites s ON s.SiteId = t.SiteId
INNER JOIN dbo.ERS_UpperGIIndications i ON s.ProcedureId = i.ProcedureId
GO

---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_BowelPreparation', 'V';
GO
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
	/* [dbo].[fw_UGI_BowelPreparation] */
	Create View [dbo].[fw_UGI_BowelPreparation] As 
	Select ''U.''+Convert(varchar(1),3+IsNull((Select Top 1 [Procedure type] From [Colon procedure] CP Where CP.[Episode No]=E.[Episode No] And [Procedure type]<>2),0))+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(INT,SubString(E.[Patient No],7,6))) As ProcedureId ,Convert(BIT,Case When BBPScore Is Null Then 0 Else 1 End) As BowelPrepSettings, Convert(BIT,Case IsNull(I.[Bowel preparation],0) When 0 Then 1 Else 0 End) As OnNoBowelPrep, L.[List item text] As Formulation, IsNull(I.[Bowel preparation],0) As OnFormulation, IsNull(I.BBPSRight,0) As OnRight, IsNull(I.BBPSTransverse,0) As OnTransverse, IsNull(I.BBPSLeft,0) As OnLeft, IsNull(I.BBPScore,0) As OnTotalScore, Case IsNull(I.[Bowel preparation],0) When 0 Then 1 Else 0 End As OffNoBowelPrep, IsNull(I.[Bowel preparation],0) As OffFormulation, Case IsNull(I.Quality,0) When 1 Then 1 Else 0 End As OffQualityGood, Case IsNull(I.Quality,0) When 2 Then 1 Else 0 End As OffQualitySatisfactory, Case IsNull(I.Quality,0) When 3 Then 1 Else 0 End As OffQualityPoor From dbo.[Colon Indications] I , dbo.Episode E , dbo.Lists L Where I.Quality Is Not Null And I.[Episode No]=E.[Episode No] And I.[Patient No]=E.[Patient No] And IsNull(I.[Bowel preparation],0)=L.[List item no] And L.[List description]=''Preparation'' And UPPER(L.[List item text]) <> ''(NONE SELECTED)'' 
'
END

EXEC sp_executesql @sql
GO
---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_FailuresERCP', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_FailuresERCP] As
SELECT * FROM fw_UGI_FailuresERCP
UNION ALL 
SELECT * FROM fw_ERS_FailuresERCP
'
END
ELSE
BEGIN
SET @sql = '
Create View [dbo].[fw_FailuresERCP] As
SELECT * FROM fw_ERS_FailuresERCP
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_BowelPreparation', 'V';
GO


/* [dbo].[fw_ERS_BowelPreparation] */
Create View [dbo].[fw_ERS_BowelPreparation] As 
Select 
	'E.'+Convert(varchar(10),BP.ProcedureID) As ProcedureId , 
	BP.BowelPrepSettings , 
	BP.OnNoBowelPrep , 
	L.ListItemText As Formulation , 
	BP.OnFormulation , 
	BP.OnRight, 
	BP.OnTransverse, 
	BP.OnLeft, 
	OnTotalScore, 
	BP.OffNoBowelPrep, 
	BP.OffFormulation, 
	CASE WHEN BP.BowelPrepQuality = 3 THEN 1 ELSE 0 END AS OffQualityGood,
	CASE WHEN BP.BowelPrepQuality = 2 THEN 1 ELSE 0 END AS OffQualitySatisfactory,
	CASE WHEN BP.BowelPrepQuality = 1 THEN 1 ELSE 0 END AS OffQualityPoor
From ERS_BowelPreparation BP, ERS_Lists L 
Where L.ListDescription='Bowel_Preparation' 
	And L.ListItemNo=BP.OnFormulation And BP.BowelPrepSettings=1 
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_BowelPreparation', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
/* [dbo].[fw_BowelPreparation] */
Create View [dbo].[fw_BowelPreparation] As Select * From [dbo].[fw_UGI_BowelPreparation] Union All Select * From [dbo].[fw_ERS_BowelPreparation] 
'
END
ELSE
BEGIN
	SET @sql = '
/* [dbo].[fw_BowelPreparation] */
Create View [dbo].[fw_BowelPreparation] As Select * From [dbo].[fw_ERS_BowelPreparation] 
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_Therapeutic', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_Therapeutic] As
Select UP.SiteId, UP.TherapeuticID, TT.Description, TT.NedName, NULL As Organ, NULL As [role], Null As polypSize, NULL As Tattoed, NULL As Performed, NULL As Successful, NULL As Retrieved, NULL As Coment From 
(
Select
	''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+''.''+CONVERT(varchar(10),T.[Site No]) As SiteId
	, Case When T.[Argon beam diathermy]=-1 Then 60 End As ArgonBeamDiathermy
	, Case When T.[Balloon dilatation]=-1 Then 61 End As BalloonDilation
	, Case When T.[Bicap electro]=-1 Then 4 End As BicapElectrocautery
	, Case When T.[Heat probe]=-1 Then 66 End As HeaterProbe
	, Case When T.[Hot biopsy]=-1 Then 67 End As HotBiopsy
	, Case When T.Injection=-1 Then 68 End As InjectionTherapy
	, Case When T.EMR=-1 Then 64 End As EMR
	, Case When T.Diathermy=-1 Then 60 End As Diathermy
	, Case When T.Dilatation=-1 Then 61 End As Dilatation
	, Case When T.[Endoloop placement]=-1 Then 72 End As Endoloop
	, Case When T.[Foreign body]=-1 Then 15 End As ForeignBody
	, Case When T.Marking=-1 Then 16 End As Marking
	, Case When T.Polypectomy=-1 Then 70 End As Polypectomy
	, Case When T.[Polypectomy removal]=-1 Then 70 End As PolypectomyRemoval
	, Case When T.RFA=-1 Then 71 End As RFA
	, Case When T.[Stent insertion]=-1 Then 72 End As StentInsertion
	, Case When T.[Therapeutic none]=-1 Then 1 End As [None]
	, Case When T.[Variceal banding]=-1 Then 74 End As VaricealBanding
	, Case When T.[YAG laser]=-1 Then 75 End As YAGlaser
	, Case When T.Clip=-1 Then 77 End As Clip
	, Case When IsNull(T.Other,'''')<>'''' Then 50 End As Other
From Episode E
	LEFT OUTER JOIN [Colon Therapeutic] T ON T.[Episode No]=E.[Episode No] And T.[Patient No]=E.[Patient No]
	LEFT OUTER JOIN [Colon Sites] S ON T.[Episode No]=S.[Episode No] And T.[Patient No]=S.[Patient No] And T.[Site No]=S.[Site No]
) As PT
UNPIVOT (
	TherapeuticID FOR Therapies IN (ArgonBeamDiathermy, BalloonDilation, BicapElectrocautery, HeaterProbe, HotBiopsy, InjectionTherapy, EMR, Diathermy, Dilatation, ForeignBody, Marking, Polypectomy, PolypectomyRemoval, RFA, StentInsertion, [None], VaricealBanding, YAGlaser, Clip, Other)
) As UP
LEFT OUTER JOIN ERS_TherapeuticTypes TT ON UP.TherapeuticID=TT.TherapeuticID
Where SiteId Is Not Null
Union All
Select UP.SiteId, UP.TherapeuticID, TT.Description, TT.NedName , NULL As Organ, NULL As [role], Null As polypSize, NULL As Tattoed, NULL As Performed, NULL As Successful, NULL As Retrieved, NULL As Coment From 
(
Select
	''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+''.''+CONVERT(varchar(10),T.[Site No]) As SiteId
	, Case When T.[Argon beam diathermy]=-1 Then 2 End As ArgonBeamDiathermy
	, Case When T.[Balloon dilatation]=-1 Then 3 End As BalloonDilation
	, Case When T.[Bicap electro]=-1 Then 4 End As BicapElectrocautery
	, Case When T.[Heat probe]=-1 Then 7 End As HeaterProbe
	, Case When T.[Hot biopsy]=-1 Then 8 End As HotBiopsy
	, Case When T.Injection=-1 Then 9 End As InjectionTherapy
	, Case When T.EMR=-1 Then 18 End As EMR
	, Case When T.[Band ligation]=-1 Then 12 End As BandLigation
	, Case When T.Diathermy=-1 Then 2 End As Diathermy
	, Case When T.Dilatation=-1 Then 3 End As Dilatation
	, Case When T.[Endoloop placement]=-1 Then 14 End As Endoloop
	, Case When T.[Foreign body]=-1 Then 15 End As ForeignBody
	, Case When T.[Gastrostomy Insertion (PEG)]=-1 Then 24 End As PEGInsertion
	, Case When T.[Gastrostomy Removal (PEG)]=-1 Then 25 End As PEGRemoval
	, Case When T.Marking=-1 Then 16 End As Marking
	, Case When T.[Oesophageal dilatation]=-1 Then 11 End As Oesophagealdilatation
	, Case When T.Polypectomy=-1 Then 27 End As Polypectomy
	, Case When T.[Polypectomy removal]=-1 Then 25 End As PolypectomyRemoval
	, Case When T.RFA=-1 Then 29 End As RFA
	, Case When T.[Stent insertion]=-1 Then 30 End As StentInsertion
	, Case When T.[Therapeutic none]=-1 Then 1 End As [None]
	, Case When T.[Variceal banding]=-1 Then 33 End As VaricealBanding
	, Case When T.[YAG laser]=-1 Then 34 End As YAGlaser
	, Case When IsNull(T.Other,'''')<>'''' Then 50 End As Other
From Episode E
	LEFT OUTER JOIN [Upper GI Therapeutic] T ON T.[Episode No]=E.[Episode No] And T.[Patient No]=E.[Patient No]
	LEFT OUTER JOIN [ERCP Sites] S ON T.[Episode No]=S.[Episode No] And T.[Patient No]=S.[Patient No] And T.[Site No]=S.[Site No]
) As PT
UNPIVOT (
	TherapeuticID FOR Therapies IN (ArgonBeamDiathermy, BalloonDilation, BicapElectrocautery, HeaterProbe, HotBiopsy, InjectionTherapy, EMR, BandLigation, Diathermy, Dilatation, ForeignBody, PEGInsertion, PEGRemoval, Marking, Oesophagealdilatation, Polypectomy, PolypectomyRemoval, RFA, StentInsertion, [None], VaricealBanding, YAGlaser, Other)
) As UP
LEFT OUTER JOIN ERS_TherapeuticTypes TT ON UP.TherapeuticID=TT.TherapeuticID
Where SiteId Is Not Null
	'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_Therapeutic', 'V';
GO

Create View [dbo].[fw_ERS_Therapeutic] As
Select UP.SiteId, UP.TherapeuticID, TT.Description, TT.NedName, Organ, [role], polypSize, Tattooed, Performed, Successful, Retrieved, comment From 
(
Select
	'E.'+Convert(varchar(3),S.SiteId) As SiteId
	, Organ, NULL [role]
	, Case When IsNull(L.SessileLargest,0)>IsNull(L.PedunculatedLargest,0) Then IsNull(L.SessileLargest,0) Else Case When IsNull(L.PedunculatedLargest,0)>IsNull(L.SubmucosalLargest,0) Then IsNull(L.PedunculatedLargest,0) Else IsNull(L.SubmucosalLargest,0) End End As polypSize
	, UT.Marking As Tattooed
	, Case When S.SiteId Is Null Then 0 Else 1 End Performed
	, UT.PolypectomyRemoval As Successful, UT.PolypectomyRemoval+UT.GastrostomyRemoval As Retrieved, L.Summary As comment
	, Case When UT.ArgonBeamDiathermy=1 Then 2 End As ArgonBeamDiathermy
	, Case When UT.BicapElectro=1 Then 4 End As BicapElectro
	, Case When UT.BandLigation=1 Then 62 End As BandLigation
	, Case When UT.BotoxInjection=1 Then 68 End As BotoxInjection
	, Case When UT.Clip=1 Then 77 End As Clip
	, Case When UT.CorrectPEGPlacement=1 Then 24 End As CorrectPEGPlacement
	, Case When UT.CorrectStentPlacement=1 Then 30 End As CorrectStentPlacement
	, Case When UT.Diathermy=1 Then 60 End As Diathermy
	, Case When UT.EMR=1 Then 64 End As EMR
	, Case When UT.EndoloopPlacement=1 Then 72 End As EndoloopPlacement
	, Case When UT.ForeignBody=1 Then 15 End As ForeignBody
	, Case When UT.GastrostomyInsertion=1 Then 30 End As GastrostomyInsertion
	, Case When UT.GastrostomyRemoval=1 Then 31 End As GastrostomyRemoval
	, Case When UT.HeatProbe=1 Then 7 End As HeatProbe
	, Case When UT.HotBiopsy=1 Then 67 End As HotBiopsy
	, Case When UT.Injection=1 Then 68 End As Injection
	, Case When UT.Marking=1 Then 16 End As Marking
	, Case When UT.[None]=1 Then 1 End As [None]
	, Case When UT.OesoDilMedicalReview=1 Then 11 End As OesoDilMedicalReview
	, Case When UT.Other=1 Then 76 End As Other
	, Case When UT.Polypectomy=1 Then 70 End As Polypectomy
	, Case When UT.PyloricDilatation=1 Then 28 End As PyloricDilatation
	, Case When UT.RFA=1 Then 71 End As RFA
	, Case When UT.StentInsertion=1 Then 72 End As StentInsertion
	, Case When UT.StentRemoval=1 Then 73 End As StentRemoval
	, Case When UT.VaricealBanding=1 Then 74 End As VaricealBanding
	, Case When UT.VaricealSclerotherapy=1 Then 74 End As VaricealSclerotherapy
	, Case When UT.YAGLaser=1 Then 75 End As YAGLaser
	, Case When T.BrushCytology='TRUE' Then 40 End As BrushCytology
	, Case When T.Polypectomy='TRUE' Then 27 End As Polypectomy2
	, Case When T.HotBiopsy='TRUE' Then 67 End As HotBiopsy2
	, Case When T.[None]='TRUE' Then 1 End As [None2]
From dbo.ERS_Procedures P LEFT OUTER JOIN
	dbo.ERS_Sites S ON P.ProcedureId = S.ProcedureId LEFT OUTER JOIN
	dbo.ERS_UpperGITherapeutics UT ON S.SiteId = UT.SiteId 
	LEFT OUTER JOIN [dbo].[ERS_Organs] O ON O.RegionId=S.RegionId
	LEFT OUTER JOIN [dbo].[ERS_ColonAbnoLesions] L ON S.SiteId=L.SiteId
	LEFT OUTER JOIN [dbo].[ERS_UpperGISpecimens] T ON S.SiteId=T.SiteId
) As PT
UNPIVOT (
	TherapeuticID FOR Therapies IN (ArgonBeamDiathermy, BicapElectro, BandLigation, BotoxInjection, Clip, CorrectPEGPlacement, CorrectStentPlacement, EMR, EndoloopPlacement, GastrostomyInsertion, GastrostomyRemoval, Marking, [None], OesoDilMedicalReview, Other, Polypectomy, PyloricDilatation, StentInsertion, StentRemoval, VaricealBanding
	, BrushCytology, Polypectomy2, HotBiopsy2,[None2])
) As UP
LEFT OUTER JOIN ERS_TherapeuticTypes TT ON UP.TherapeuticID=TT.Id
Where SiteId Is Not Null --And Organ Is Not Null /*not being written to so column is always null so no results returned*/
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_Therapeutic', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_Therapeutic] As
Select * From [dbo].[fw_UGI_Therapeutic]
Union All
Select * From [dbo].[fw_ERS_Therapeutic]
'
END
ELSE
BEGIN
	SET @sql = '
Create View [dbo].[fw_Therapeutic] As
Select * From [dbo].[fw_ERS_Therapeutic]
'
END

EXEC sp_executesql @sql
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_Indications', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_Indications] As
Select UP.ProcedureId, UP.IndicationID, TT.Indication, TT.NedName From 
(
Select
	''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	, Case When T.[Abdominal mass]=-1 Then 25 End As AbdominalMass
	, Case When T.[Abdominal pain]=-1 Then 2 End As AbdominalPain
	, Case When T.[Abnormal barium enema]=-1 Then 3 End As AbnormalBariumEnema
	, Case When T.[Abnormal capsule study]=-1 Then 1 End As AbnormalCapsuleStudy
	, Case When T.[Abnormal MRI]=-1 Then 1 End As AbnormalMRI
	, Case When T.[Abnormal sigmoidoscopy]=-1 Then 26 End As AbnormalSigmoidoscopy
	, Case When T.AbnormalCTScan=-1 Then 1 End As AbnormalCTScan
	, Case When T.Allergy=-1 Then 1 End As Allergy
	, Case When T.[Altered bowel habit]=-1 Then 1 End As AlteredBowelHabit
	, Case When T.[Amsterdam criteria]=-1 Then 1 End As AmsterdamCriteria
	, Case When T.Anaemia=-1 Then 4 End As Anaemia
	, Case When T.Cancer=-1 Then 28 End As Cancer
	, Case When T.[Colitis assessment]=-1 Then 1 End As ColitisAssessment
	, Case When T.[Colitis surveillance]=-1 Then 1 End As ColitisSurveillance
	, Case When T.[Colonic obstruction]=-1 Then 1 End As ColonicObstruction
	, Case When T.FOBT=-1 Then 1 End As FOBT
	, Case When T.Melaena=-1 Then 11 End As Melaena
	, Case When T.[Polyposis syndrome]=-1 Then 38 End As PolyposisSindrome
	, Case When T.[Potentially damaging drug]=-1 Then 1 End As PotentiallyDamageDrug
	, Case When T.[Rectal bleeding]=-1 Then 40 End As RectalBleeding
	, Case When T.StentInsertion=-1 Then 19 End As StentInsertion
	, Case When T.StentRemoval=-1 Then 20 End As StentRemoval
	, Case When T.StentReplacement=-1 Then 18 End As StentReplacement
	, Case When T.[Tumour assessment]=-1 Then 42 End As TumourAssessment
	, Case When T.[Weight loss]=-1 Then 23 End As WeightLoss
From Episode E
	LEFT OUTER JOIN [Colon Indications] T ON T.[Episode No]=E.[Episode No] And T.[Patient No]=E.[Patient No]
) As PT
UNPIVOT (
	IndicationID FOR Therapies IN (AbdominalMass, AbdominalPain, AbnormalBariumEnema, AbnormalCapsuleStudy, AbnormalMRI, AbnormalSigmoidoscopy, Allergy, AlteredBowelHabit
	, AmsterdamCriteria, Anaemia, Cancer, ColitisAssessment, ColitisSurveillance, ColonicObstruction, FOBT, Melaena, PolyposisSindrome, PotentiallyDamageDrug, RectalBleeding
	, StentInsertion, StentRemoval, StentReplacement, TumourAssessment, WeightLoss)
) As UP
LEFT OUTER JOIN ERS_IndicationsTypes TT ON UP.IndicationID=TT.IndicationID
Union
Select UP.ProcedureId, UP.IndicationID, TT.Indication, TT.NedName From 
(
Select
	''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	, Case When T.[Abnormal capsule study]=-1 Then 1 End As AbnormalCapsuleStudy
	, Case When T.[Abdominal pain]=-1 Then 2 End As AbdominalPain
	, Case When T.[Abnormal MRI]=-1 Then 1 End As AbnormalMRI
	, Case When T.Allergy=-1 Then 1 End As Allergy
	, Case When T.Aneamia=-1 Then 4 End As Anaemia
	, Case When T.Cancer=-1 Then 28 End As Cancer
	, Case When T.[Chest pain]=-1 Then 1 End As ChestPain
	, Case When T.[Chronic liver disease]=-1 Then 1 End As ChronicLiverDisease
	, Case When T.[Coeliac disease]=-1 Then 1 End As CoeliacDisease
	, Case When T.[Coffee grounds vomit]=-1 Then 12 End As CofeeGroundsVomit
	, Case When T.Melaena=-1 Then 11 End As Melaena
	, Case When T.Diarrhoea=-1 Then 6 End As Diarrhoea
	, Case When T.[Potentially damaging drug]=-1 Then 1 End As PotentiallyDamageDrug
	, Case When T.[Double balloon enteroscopy]=-1 Then 1 End As DoubleBalloonEnteroscopy
	, Case When T.StentInsertion=-1 Then 19 End As StentInsertion
	, Case When T.StentRemoval=-1 Then 20 End As StentRemoval
	, Case When T.StentReplacement=-1 Then 18 End As StentReplacement
	, Case When T.[Balloon Insertion]=-1 Then 1 End As BalloonInsertion
	, Case When T.[Weight loss]=-1 Then 23 End As WeightLoss
	, Case When T.[Balloon Removal]=-1 Then 1 End As BalloonRemoval
	, Case When T.[Bariatric pre-assessment]=-1 Then 1 End As BariatricPreAssessment
	, Case When T.[Barrett''s oesophagus]=-1 Then 5 End As BarretsOesophagus
	, Case When T.[Breath test]=-1 Then 1 End As BreathTest
	, Case When T.[Drug trial]=-1 Then 1 End As DrugTrial
	, Case When T.[Previous surgery]=-1 Then 1 End As PreviousSurgery
	, Case When T.[Previous examination]=-1 Then 1 End As PreviousExamination
	, Case When T.Haematemesis=-1 Then 9 End As Haematemesis
	, Case When T.[Insertion of pH probe]=-1 Then 1 End As InsertionOfpHProbe
	, Case When T.[Jejunostomy insertion]=-1 Then 1 End As JejunostomyInsertion
	, Case When T.Dysphagia=-1 Then 8 End As Dysphagia
	, Case When T.Dyspepsia=-1 Then 7 End As Dyspepsia
	, Case When T.[Nasoduodenal tube]=-1 Then 1 End As NasoduodenalTube
	, Case When T.[Nausea and or vomiting]=-1 Then 12 End As NauseaAndOrVomiting
	, Case When T.Odynophagia=-1 Then 13 End As Odynophagia
	, Case When T.[Oeso dilatation]=-1 Then 1 End As OesoDilatation
	, Case When T.[Oesophageal varices]=-1 Then 1 End As OesoVarices
	, Case When T.Oesophagitis=-1 Then 1 End As Oesophagitis
	, Case When T.[PEG removal]=-1 Then 16 End As PEGRemoval
	, Case When T.[PEG replacement]=-1 Then 14 End As PEGReplacement
	, Case When T.[Post bariatric surgery assessment]=-1 Then 1 End As PostBariatricSurgeryAssessment
	, Case When T.[Potentially damaging drug]=-1 Then 1 End As PotentiallyDamagingDrug
	, Case When T.[Push enteroscopy]=-1 Then 1 End As PushEnteroscopy
	, Case When T.[Reflux symptoms]=-1 Then 1 End As RefluxSymptoms
	, Case When T.[Serology test]=-1 Then 1 End As SerologyTest
	, Case When T.[Single balloon enteroscopy]=-1 Then 1 End As SingleBalloonEnteroscopy
	, Case When T.[Small bowel biopsy]=-1 Then 1 End As SmallBowelBiopsy
	, Case When T.[stool antigen test]=-1 Then 1 End As StoolAntigenTest
	, Case When T.[Surgery follow up proc]=-1 Then 1 End As SurgeryFollowUpProc
	, Case When T.[Ulcer exclusion]=-1 Then 1 End As UlcerExclusion
	, Case When T.[Urease test]=-1 Then 1 End As UreaseTest
From [dbo].[Episode] E
	LEFT OUTER JOIN [dbo].[Upper GI Indications] T ON T.[Episode No]=E.[Episode No] And T.[Patient No]=E.[Patient No]
) As PT
UNPIVOT (
	IndicationID FOR Therapies IN (AbnormalCapsuleStudy, AbdominalPain, AbnormalMRI, Allergy, Anaemia, Cancer, ChestPain, ChronicLiverDisease, CoeliacDisease, CofeeGroundsVomit
	, Melaena, Diarrhoea, PotentiallyDamageDrug, DoubleBalloonEnteroscopy, StentInsertion, StentRemoval, StentReplacement, BalloonInsertion, WeightLoss, BalloonRemoval
	, BariatricPreAssessment, BarretsOesophagus, BreathTest, DrugTrial, PreviousSurgery, PreviousExamination, InsertionOfpHProbe, JejunostomyInsertion, Dysphagia, Dyspepsia
	, NasoduodenalTube, NauseaAndOrVomiting, Odynophagia, OesoDilatation, OesoVarices, Oesophagitis, PEGRemoval, PEGReplacement, PostBariatricSurgeryAssessment
	, PotentiallyDamagingDrug, PushEnteroscopy, RefluxSymptoms, SerologyTest, SingleBalloonEnteroscopy, SmallBowelBiopsy, StoolAntigenTest, SurgeryFollowUpProc, UlcerExclusion
	, UreaseTest)
) As UP
LEFT OUTER JOIN [dbo].[ERS_IndicationsTypes] TT ON UP.IndicationID=TT.IndicationID
'
END
EXEC sp_executesql @sql
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_Indications', 'V';
GO

Create View [dbo].[fw_ERS_Indications] As
Select UP.ProcedureId, UP.IndicationID, TT.Indication, TT.NedName From 
(
Select
	'E.'+Convert(varchar(10),P.ProcedureId) As ProcedureId
	, Case When UT.AbdominalPain=1 Then 2 End As AbdominalPain
	, Case When UT.AbnormalityOnBarium=1 Then 3 End As AbnormalityOnBarium
	, Case When UT.Allergy=1 Then 0 End As Allergy
	, Case When UT.AllergyDesc=1 Then 0 End As AllergyDesc
	, Case When UT.Anaemia=1 Then 4 End As Anaemia
	, Case When UT.Angina=1 Then 1 End As Angina
	, Case When UT.Asthma=1 Then 1 End As Asthma
	, Case When UT.BalloonInsertion=1 Then 1 End As BalloonInsertion
	, Case When UT.BalloonRemoval=1 Then 1 End As BalloonRemoval
	, Case When UT.BariatricPreAssessment=1 Then 1 End As BariatricPreAssessment
	, Case When UT.BarrettsOesophagus=1 Then 5 End As BarrettsOesophagus
	, Case When UT.BiliaryLeak=1 Then 47 End As BiliaryLeak
	, Case When UT.BreathTest=1 Then 1 End As BreathTest
	, Case When UT.Cancer=1 Then Case When P.ProcedureType IN (3,4,5) Then 28 End End As Cancer
	, Case When UT.ChestPain=1 Then 1 End As ChestPain
	, Case When UT.ChronicLiverDisease=1 Then 1 End As ChronicLiverDisease
	, Case When UT.CoeliacDisease=1 Then 1 End As CoeliacDisease
	, Case When UT.CoffeeGroundsVomit=1 Then 12 End As CoffeeGroundsVomit
	, Case When UT.ColonAbdominalMass=1 Then 25 End As ColonAbdominalMass
	, Case When UT.ColonAbdominalPain=1 Then 2 End As ColonAbdominalPain
	, Case When UT.ColonAbnormalBariumEnema=1 Then 1 End As ColonAbnormalBariumEnema
	, Case When UT.ColonAbnormalCTScan=1 Then 1 End As ColonAbnormalCTScan
	, Case When UT.ColonAbnormalSigmoidoscopy=1 Then 26 End As ColonAbnormalSigmoidoscopy
	, Case When UT.ColonAlterBowelHabit=1 Then 1 End As ColonAlterBowelHabit
	, Case When UT.ColonAnaemia=1 Then 1 End As ColonAnaemia
	, Case When UT.ColonAssessment=1 Then 1 End As ColonAssessment
	, Case When UT.ColonBowelCancerScreening=1 Then 1 End As ColonBowelCancerScreening
	, Case When UT.ColonCarcinoma=1 Then 1 End As ColonCarcinoma
	, Case When UT.ColonColonicObstruction=1 Then 1 End As ColonColonicObstruction
	, Case When UT.ColonDysplasia=1 Then 1 End As ColonDysplasia
	, Case When UT.ColonFamily=1 Then 1 End As ColonFamily
	, Case When UT.ColonPolyps=1 Then 41 End As ColonPolyps
	, Case When UT.ColonRectalBleeding=1 Then 40 End As ColonRectalBleeding
	, Case When UT.ColonSurveillance=1 Then 1 End As ColonSurveillance
	, Case When UT.ColonSreeningColonoscopy=1 Then 1 End As ColonSreeningColonoscopy
	, Case When UT.COPD=1 Then 1 End As COPD
	, Case When UT.DiabetesMellitus=1 Then 1 End As DiabetesMellitus
	, Case When UT.Dyspepsia=1 Then 7 End As Dyspepsia
	, Case When UT.Dysphagia=1 Then 8 End As Dysphagia
	, Case When UT.Epilepsy=1 Then 1 End As Epilepsy
From dbo.ERS_Procedures P LEFT OUTER JOIN
	dbo.ERS_UpperGIIndications UT ON P.ProcedureId = UT.ProcedureId
) As PT
UNPIVOT (
	IndicationID FOR Therapies IN (AbdominalPain, AbnormalityOnBarium, Allergy, AllergyDesc, Anaemia, Angina, Asthma, BalloonInsertion, BalloonRemoval, BariatricPreAssessment, BarrettsOesophagus
	, BiliaryLeak, BreathTest, Cancer, ChestPain, ChronicLiverDisease, CoeliacDisease, CoffeeGroundsVomit, ColonAbdominalMass, ColonAbdominalPain, ColonAbnormalBariumEnema, ColonAbnormalCTScan
	, ColonAbnormalSigmoidoscopy, ColonAlterBowelHabit, ColonAnaemia, ColonAssessment, ColonBowelCancerScreening, ColonCarcinoma, ColonColonicObstruction, ColonDysplasia, ColonFamily
	, ColonPolyps, ColonRectalBleeding, ColonSurveillance, ColonSreeningColonoscopy, COPD, DiabetesMellitus, Dyspepsia, Dysphagia, Epilepsy)
) As UP
LEFT OUTER JOIN ERS_IndicationTypes TT ON UP.IndicationID=TT.ID
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_Indications', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_Indications] As
Select * FROM [dbo].[fw_UGI_Indications]
UNION ALL 
Select * FROM [dbo].[fw_ERS_Indications]
'
END
ELSE
BEGIN
	SET @sql = '
Create View [dbo].[fw_Indications] As
Select * FROM [dbo].[fw_ERS_Indications]
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_IndicationsERCP', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_IndicationsERCP] As
Select
	''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId 
	, Replace(Replace(Case When I.[Image normal]=-1 Then '''' Else ''Imaging revealed,'' 
		+Case When I.[Image chronic pancreatitis]=-1 Then '', chronic pancreatitis'' Else '''' End
		+Case When I.[Image pancreatic mass]=-1 Then '', pancreatic mass'' Else '''' End
		+Case When I.[Image hepatic mass]=-1 Then '', hepatic mass'' Else '''' End
		+Case When I.[Image acute pancreatitis]=-1 Then '', acute pancreatititis'' Else '''' End
		+Case When I.[Image dilated pancreatic duct]=-1 Then '', dilated pancreatic duct'' Else '''' End
		+Case When I.[Image dilated bile ducts]=-1 Then '', dilated bile ducts'' Else '''' End
		+Case When I.[Image stones]=-1 Then '', stones'' Else '''' End
		+Case When I.[Image dilated extrahepatic ducts]=-1 Then '', dilated extrahepatic ducts'' Else '''' End
		+Case When I.[Image dilated intrahepatic ducts]=-1 Then '', dilated intrahepatic ducts'' Else '''' End
		+Case When I.[Image gall stones]=-1 Then '', gall stones'' Else '''' End
		+Case When I.[Image biliary leak]=-1 Then '', biliary leak'' Else '''' End
		+Case When I.[Image fluid collection]=-1 Then '', fluid collection'' Else '''' End
		+Case When I.[Image obstruction CBD]=-1 Then '', obstructed CBD/CHD'' Else '''' End
		+Case When IsNull(I.[Image other text],'''')='''' Then '''' Else +'', ''+IsNull(I.[Image other text],'''') End
		End,'',,'',''''),''Image revealed,'','''') As [Image]
		,Replace(Replace(''@,''
      +Case When I.[Clin abdominal pain]=-1 Then '', abdominal pain'' Else '''' End
      +Case When I.[Clin abnormal enzymes]=-1 Then '', abnormal enzimes'' Else '''' End
      +Case When I.[Clin acute pancreatitis]=-1 Then '', acute pancreatitis'' Else '''' End
      +Case When I.[Clin cholangitis]=-1 Then '', cholangitis'' Else '''' End
      +Case When I.[Clin chronic pancreatitis]=-1 Then '', chronic pancreatitis'' Else '''' End
      +Case When I.[Clin jaundice]=-1 Then '', jaundice'' Else '''' End
      +Case When I.[Clin open access]=-1 Then '', open access'' Else '''' End
	  +Case When I.[Clin obstruction CBD]=-1 Then '', obstruction CDB'' Else '''' End
      +Case When I.[Clin pre-laparoscopic cholecystectomy]=-1 Then '', pre-laparoscopic cholecystectomy'' Else '''' End
      +Case When I.[Clin recurrent pancreatitis]=-1 Then '', recurrent pancreatitis'' Else '''' End
      +Case When I.[Clin sphincter of Oddi dysfunction]=-1 Then '', sphincter of Oddi dysfunction'' Else '''' End
      +Case When I.[Clin stent occlusion]=-1 Then '', stent occlusion'' Else '''' End
      +Case When I.[Clin papillary stenosis]=-1 Then '', papillary stenosis'' Else '''' End
      +Case When I.[Clin biliary leak]=-1 Then '', biliary leak'' Else '''' End
      +Case When IsNull([Clin other text],'''')<>'''' Then '', ''+[Clin other text] Else '''' End,''@,, '',''''),''@,'','''')
	  As Indications
	  , Case When I.[Clin obstruction CBD]=-1 Then 1 Else 0 End As ClinObstructionCBD
	  , Case When I.[Image obstruction CBD]=-1 Then 1 Else 0 End As ImageObstructionCBD
	  ,Replace(Replace(''@,''
      +Case When I.[Procs papill/sphincterotomy]=-1 Then '', papill/sphincterotomy'' Else '''' End
      +Case When I.[Procs stent insertion]=-1 Then '', stent insertion'' Else '''' End
      +Case When I.[Procs stent replacement]=-1 Then '', stent replacement'' Else '''' End
      +Case When I.[Procs stone removal]=-1 Then '', stone removal'' Else '''' End
      +Case When I.[Procs naso drains]=-1 Then '', naso drains'' Else '''' End
      +Case When I.[Procs cyst puncture]=-1 Then '', cyst puncture'' Else '''' End
      +Case When I.[Procs rendezvous]=-1 Then '', rendezvous'' Else '''' End
      +Case When I.[Procs stricture dilatation]=-1 Then '', stricture dilatation'' Else '''' End
      +Case When I.[Procs manometry]=-1 Then '', manometry'' Else '''' End
      +Case When I.[Procs cannulate and opacify]=-1 Then '', cannulate and opacify'' Else '''' End
      +Case When I.[Procs stent removal]=-1 Then '', stent removal'' Else '''' End
	  +Case When I.[Procs other]=-1 Then '', other'' Else '''' End
	  ,''@,, '',''''),''@,'','''')
	  As Therapy

      , I.[Follow up prev exam]
      , I.[Follow up bile duct stones]
      , I.[Follow up malignancy]
      , I.[Follow up biliary stricture]
      , I.[Follow up stent replacement]
      , I.[Follow up disease/proc]
      , I.[Urgent two week referral]
      , I.[Cancer]
      , I.[cmNone]
      , I.[cmAngina]
      , I.[cmAsthma]
      , I.[cmCOPD]
      , I.[cmDiabetesMellitus]
      , I.[cmEpilepsy]
      , I.[cmHemiPostStroke]
      , I.[cmHT]
      , I.[cmMI]
      , I.[cmObesity]
      , I.[CIC]
      , I.[ASA Status]
      , I.[cmTIA]
      , I.[Potentially damaging drug text]
      , I.[cmOther]
      , I.[cmDiabetesMellitusType]
      , I.[EUS ref guided FNA biopsy]
      , I.[EUS guided cystogastrostomy]
      , I.[EUS guided coeliac plexus neurolysis]
      , I.[WHO status]
From [ERCP Indications] I, Episode E
Where I.[Episode No]=E.[Episode No] And I.[Patient No]=E.[Patient No]
	'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_TherapeuticERCP', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_TherapeuticERCP] As
Select
	''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+''.''+CONVERT(varchar(10),T.[Site No]) As SiteId
    ,S.Region
	,Case When IsNull(T.[Stricture Decompressed],0)=1 Or IsNull(T.[Stent Decompressed],0)=1 Or IsNull(T.[Balloon Decompressed],0)=1 Or IsNull(T.[Stone decompressed],0)=1 Then ''V'' Else Case When IsNull(T.[Stricture Decompressed],0)=2 Or IsNull(T.[Stent Decompressed],0)=2 Or IsNull(T.[Balloon Decompressed],0)=2 Or IsNull(T.[Stone decompressed],0)=2 Then ''X'' Else ''?'' End End As Result
	,(Select Count(*) From fw_IndicationsERCP Where ClinObstructionCBD=1 And ProcedureId=''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))) As ObstructedCBD
	,Case When IsNull(T.[Stricture Decompressed],0)=1 Or IsNull(T.[Stent Decompressed],0)=1 Or IsNull(T.[Balloon Decompressed],0)=1 Or IsNull(T.[Stone decompressed],0)=1 Then 1 Else 0 End As Decompressed
	,Case When IsNull(T.[Stricture Decompressed],0)=2 Or IsNull(T.[Stent Decompressed],0)=2 Or IsNull(T.[Balloon Decompressed],0)=2 Or IsNull(T.[Stone decompressed],0)=2 Then 1 Else 0 End As Failed
	,Case When (IsNull(T.[Stricture Decompressed],0)+IsNull(T.[Stent Decompressed],0)+IsNull(T.[Balloon Decompressed],0)+IsNull(T.[Stone decompressed],0)>4 And IsNull(T.[Stricture Decompressed],0)+IsNull(T.[Stent Decompressed],0)+IsNull(T.[Balloon Decompressed],0)+IsNull(T.[Stone decompressed],0)<8) Then 1 Else 0 End As Unknow
    ,Case When T.[Therapeutic none]=-1 Then '''' 
	  Else 
		Case When T.[Stone removal]=-1 Then ''Stone removal'' Else '''' End
	  End As StoneRemoval
    ,Case When T.[Therapeutic none]=-1 Then '''' 
	  Else 
		Case When T.[Stricture dilatation]=-1 Then ''Stricture dilatation ''
		+Case When IsNull(T.[Dilated to],'''')<>'''' Then Convert(varchar(10), T.[Dilated to])+Case T.[Dilatation units] When 1 Then '' mm'' When 2 then '' Fr'' Else '''' End Else '''' End
		Else '''' End
	  End As StrictureDilatation
    ,Case When T.[Therapeutic none]=-1 Then '''' 
	  Else 
		Case When T.[Endoscopic cyst puncture]=-1 Then ''Endoscopic cyst puncture''
			+Case T.[Cyst puncture via] When 1 Then '' using papilla'' When 2 Then '' using medial wall of duodenum (cyst duodenostomy)'' When 3 Then '' using stomach (cyst gastrostomy)'' Else '''' End
		Else '''' End
	  End As EndoscopicCystPuncture
	,Case When T.[Therapeutic none]=-1 Then '''' 
	Else
		Case When T.[Nasopancreatic drain]=-1 Then ''Nasopancreatic drain'' Else '''' End
	End As NasopancreaticDrain
    ,Case When T.[Therapeutic none]=-1 Then '''' 
	  Else 
		Case When T.[Stent insertion]=-1 Then ''Stent insertion'' Else Case When IsNull(T.[Stent qty],0)<>0 Then Convert(varchar(3),T.[Stent qty])+'' stent(s) inserted length ''+Convert(varchar(10),T.[Stent insertion length])+'' Ø ''+Convert(varchar(10),T.[Stent diameter])+'' ''+Case T.[Stent diameter units] When 1 Then ''cm'' When 0 Then ''fr'' Else '''' End Else ''Stent insertion'' End+Case When T.[Radioactive wire placed]=-1 Then '' (Radioactive wire placed)'' Else '''' End
	  End End As StentInsertion
    ,Case When T.[Therapeutic none]=-1 Then '''' 
	  Else 
		Case When T.[Stent removal]=-1 Then 
			''Stent removal''
		Else '''' End
	  End As StentRemoval
From [ERCP Therapeutic] T, Episode E, [ERCP Sites] S
Where T.[Episode No]=E.[Episode No] And T.[Patient No]=E.[Patient No]
And T.[Episode No]=S.[Episode No] And T.[Patient No]=S.[Patient No] And T.[Site No]=S.[Site No]
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_Markings', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_Markings]
--WITH SCHEMABINDING
As
Select 
	''U.''+Convert(varchar(3),Case When CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10))=''3'' Then IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) Else CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) End)+''.''+Convert(Varchar(10),E.[Episode No])+''.''+Convert(Varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+''.''+convert(varchar(10),CT.[Site No]) As SiteId
	,Case When CT.Marking=-1 Then 1 Else 0 End As Marking
	,Case CT.[Marking type] When 1 Then ''tattoo'' When 2 Then ''dye spray'' When 3 Then ''EMR solution'' Else ''(none)'' End As MarkingType
	,CT.[Marking number sites] As MarkingNumberSites
From [dbo].[Episode] E
, [dbo].[Colon Therapeutic] CT
Where E.[Episode No]=CT.[Episode No] And E.[Patient No]=CT.[Patient No] /*And CT.Marking=-1       Needed for List report?*/
	'
END

EXEC sp_executesql @sql

GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_Markings', 'V';
GO

Create View [dbo].[fw_ERS_Markings]
--WITH SCHEMABINDING
As
Select 
'E.'+Convert(varchar(10),T.SiteId) As SiteId
,T.Marking
,Case T.MarkingType When 1 Then 'tattoo' When 2 Then 'dye spray' When 3 Then 'EMR solution' Else '(none)' End As MarkingType
, Case When T.Marking=0 Then 0 Else 1 End As MarkingNumberSites
From [dbo].[ERS_UpperGITherapeutics] T
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_Markings', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_Markings] As
Select * From fw_UGI_Markings
Union All
Select * From fw_ERS_Markings
'
END
ELSE
BEGIN
	SET @sql = '
Create View [dbo].[fw_Markings] As
Select * From fw_ERS_Markings
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_Visualization', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_Visualization]
--WITH SCHEMABINDING
As
SELECT 
	''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(E.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	,Case V.[Via major to bile duct]
		When 1 Then ''sucessfull''
		When 2 Then ''partially successfull''
		When 3 Then ''not attempted''
		When 4 Then ''unsuccessfull due to ''+Case IsNull([Bile duct unsuccessful due to],0) When 0 Then ''(none)'' Else '''' End
		Else ''not registered'' End As ViaMayorToBileDuct
	,Case V.[Via major to pan duct]
		When 1 Then ''sucessfull''
		When 2 Then ''partially successfull''
		When 3 Then ''not attempted''
		When 4 Then ''unsuccessfull due to ''+Case IsNull([Pan duct unsuccessful due to],0) When 0 Then ''(none)'' Else '''' End
		Else ''not registered'' End As ViaMayorToPancreaticDuct
	,Case V.[Via minor]
		When 1 Then ''sucessfull''
		When 2 Then ''partially successfull''
		When 3 Then ''not attempted''
		When 4 Then ''unsuccessfull due to ''+Case IsNull([Via minor unsuccessful due to],0) When 0 Then ''(none)'' Else '''' End
		Else ''not registered'' End As ViaMinor
	  ,Case [Access via] When 0 Then ''pylorus'' When 1 Then Case [Other access method] When 0 Then ''(none)'' Else '''' End Else '''' End As AccessVia
      ,[Hepatobiliary 1st contrast med vol ml] As Hepatobiliary1stContrastMedVolml
      ,[Hepatobiliary 2nd contrast med vol ml] As Hepatobiliary2ndContrastMedVolml
      ,[Pancreatic 1st contrast med vol ml] As Pancreatic1stContrastMedVolml
      ,[Pancreatic 2nd contrast med vol ml] As Pancreatic2ndContrastMedVolml
	FROM [dbo].[ERCP Visualisation] V, [dbo].[Episode] E
	Where V.[Episode No]=E.[Episode No] And V.[Patient No]=E.[Patient No]
'
END

EXEC sp_executesql @sql
GO

---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_Visualization', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
CREATE VIEW [dbo].[fw_Visualization] AS
SELECT * FROM fw_UGI_Visualization
GO
'
END

EXEC sp_executesql @sql
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[v_rep_GRSA02] As
SELECT P.Surname, P.Forename1, P.[HospitalNumber], Procs1.CreatedOn, --Procs1.PatientId, Procs1.ProcedureId, 
	Convert(int,(Procs1.CreatedOn-P.[Dateofbirth]))/365 As Age, 
	(Select Consultant From v_rep_Consultants Where ReportID=IsNull(Procs1.Endoscopist1,0)) As Endoscopist1, 
	(Select Consultant From v_rep_Consultants Where ReportID=IsNull(Procs1.Endoscopist2,0)) As Endoscopist2, 
	Case When Ind.Haematemesis=1 Then ''Yes'' Else '''' End As Haematemesis, Case When Ind.Melaena=1 Then ''Yes'' Else '''' End As Melaena,
	Case Ind.Cancer
	When 1 Then ''definite cancer''
	When 2 Then ''suspected cancer''
	When 3 Then ''cancer exclusion''
	Else '''' End 
	As Cancer,
	Case Ind.ColonRectalBleeding
	When 1 Then ''Bright red''
	When 2 Then ''Heavy''
	When 3 Then ''Occult''
	Else '''' End
	As ColonRectalBleeding, 
	Case Procs1.ProcedureType
	When 1 Then ''Gastroscopy''
	When 3 Then ''Colonoscopy''
	When 4 Then ''Sigmoidoscopy''
	Else '''' End As ProcType, 
	epr.TPP_Therapies, 
	epr.PP_Therapies, 
	''ERS'' As Release
FROM 
	dbo.ERS_VW_Patients P
	, ERS_Procedures Procs1
	, ERS_UpperGIIndications Ind
	, dbo.ERS_ProceduresReporting epr
Where P.[PatientId]=Procs1.PatientId
AND epr.ProcedureId = Procs1.ProcedureId
And Procs1.ProcedureId=Ind.ProcedureId
And (Ind.ColonRectalBleeding<>0 Or Ind.Haematemesis<>0 Or Ind.Melaena<>0)
And Procs1.ProcedureType In (1,3,4)
Union All
SELECT 
	Patient.Surname, Patient.Forename1, Patient.[HospitalNumber], dbo.Episode.[Episode date] As CreatedOn, --dbo.Episode.[Patient No], dbo.Episode.[Episode No], 
	dbo.Episode.[Age at procedure] As Age, 
	(Select Consultant From v_rep_Consultants Where ReportID-1000000=Convert(Int,SubString(dbo.[Upper GI Procedure].Endoscopist2,7,6))) As Endoscopist1, 
	(Select Consultant From v_rep_Consultants Where ReportID-1000000=Convert(Int,SubString(dbo.[Upper GI Procedure].Assistant1,7,6))) As Endoscopist2, 
	Case When dbo.[Upper GI Indications].Haematemesis=-1 Then ''Yes'' Else '''' End As Haematemesis, 
	Case When dbo.[Upper GI Indications].Melaena=-1 Then ''Yes'' Else '''' End As Melaena, 
	Case dbo.[Upper GI Indications].Cancer 
	When 1 Then ''definite cancer''
	When 2 Then ''suspected cancer''
	When 3 Then ''cancer exclusion''
	Else '''' End
	As Cancer, 
	'''' As ColonRectalBleeding,
	''Gastroscopy'' As ProcType,
	dbo.[Upper GI Procedure].TPP_Therapies, 
	dbo.[Upper GI Procedure].PP_Therapies,
	''UGI'' As Release
FROM dbo.ERS_VW_Patients Patient INNER JOIN
	dbo.Episode ON Patient.[ComboId] = dbo.Episode.[Patient No] INNER JOIN
	dbo.[Upper GI Procedure] ON dbo.Episode.[Episode No] = dbo.[Upper GI Procedure].[Episode No] AND 
	dbo.Episode.[Patient No] = dbo.[Upper GI Procedure].[Patient No] INNER JOIN
	dbo.[Upper GI Indications] ON dbo.[Upper GI Procedure].[Episode No] = dbo.[Upper GI Indications].[Episode No] AND 
	dbo.[Upper GI Procedure].[Patient No] = dbo.[Upper GI Indications].[Patient No] AND SUBSTRING(dbo.Episode.Status, 1, 1) = ''1'' AND 
	dbo.Episode.[Combined procedure] = 0
	And (dbo.[Upper GI Indications].Haematemesis=-1 Or dbo.[Upper GI Indications].Melaena=-1)
Union All
SELECT        
	Patient.Surname, Patient.Forename1, Patient.[HospitalNumber], dbo.Episode.[Episode date] As CreatedOn, --dbo.Episode.[Patient No], dbo.Episode.[Episode No], 
	dbo.Episode.[Age at procedure] As Age, 
	(Select Consultant From v_rep_Consultants Where ReportID-1000000=Convert(Int,SubString([dbo].[Colon Procedure].Endoscopist2,7,6))) As Endoscopist1, 
	(Select Consultant From v_rep_Consultants Where ReportID-1000000=Convert(Int,SubString([dbo].[Colon Procedure].Assistant1,7,6))) As Endoscopist2, 
	'''' As Haematemesis, '''' As Melaena, 
	Case dbo.[Colon Indications].Cancer 
	When 1 Then ''definite cancer''
	When 2 Then ''suspected cancer''
	When 3 Then ''cancer exclusion''
	Else'''' End
	As Cancer, 
	Case dbo.[Colon Indications].[Rectal bleeding] 
	When 1 Then ''Bright red''
	When 2 Then ''Heavy''
	When 3 Then ''Occult''
	Else '''' End
	As ColonRectalBleeding, 
	Case dbo.[Colon Procedure].[Procedure type]
	When 0 Then ''Colonoscopy''
	When 1 Then ''Sigmoidoscopy''
	When 2 Then ''Proctoscopy''
	Else ''Unknow'' End As ProcType,
	dbo.[Colon Procedure].TPP_Therapies, dbo.[Colon Procedure].PP_Therapies, ''UGI'' As Release
FROM dbo.ERS_VW_Patients Patient INNER JOIN
dbo.Episode ON Patient.[ComboId] = dbo.Episode.[Patient No] INNER JOIN
dbo.[Colon Procedure] ON dbo.Episode.[Episode No] = dbo.[Colon Procedure].[Episode No] AND 
dbo.Episode.[Patient No] = dbo.[Colon Procedure].[Patient No] INNER JOIN
dbo.[Colon Indications] ON dbo.[Colon Procedure].[Episode No] = dbo.[Colon Indications].[Episode No] AND 
dbo.[Colon Procedure].[Patient No] = dbo.[Colon Indications].[Patient No] AND dbo.[Colon Indications].[Rectal bleeding] In (1,2,3)
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'v_rep_StentPositioning', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[v_rep_StentPositioning] As
Select C.[HospitalNumber] As CNN, C.Forename1, C.Surname, Convert(INT,SubString(S.[Patient No],7,6)) As PatientId, S.[Episode No] As ProcedureId, S.[Site No] As SiteId
, S.[Region]
, Case T.[Stent insertion] When -1 Then 1 Else 0 END As [StentInsertion]
, Case T.[Stent insertion] When -1 Then
	Case When T.[Correct stent placement]=-1 Then
		''Correctly placed''
	Else
		Case T.[Stent placement failure] 
			When 0 Then ''Failed but no reason given'' 
			When 1 Then ''Too proximal'' 
			When 2 Then ''Too distal'' 
			When 3 Then ''Failed deployment'' 
			Else ''Failed but no reason given''
		End
	End
Else
	''Placed but not recorded''
End As [Placement]
, Convert(Date,E.[Episode date]) As CreatedOn
, E.[Age at procedure] As Age
, Convert(INT,SubString(P.Endoscopist2,7,6))+1000000 As Endoscopist1Id
, Convert(INT,SubString(P.Assistant1,7,6))+1000000 As Endoscopist2Id
, 1 As ProcedureTypeId, ''OES'' As SubType, ''UGI'' As Release
 From 
	[AUpper GI Oesophagus Other] O, [Upper GI sites] S, [dbo].[Upper GI therapeutic] T, Episode E, [dbo].[Upper GI Procedure] P, ERS_VW_Patients C
Where O.[Episode No]=S.[Episode No] And O.[Site No]=S.[Site No] And O.[Patient No]=S.[Patient No]
	And S.[Site No]=T.[Site No] And S.[Episode No]=T.[Episode No]
	And ((O.Stricture)=-1) AND (IsNull(S.Continuous,0)=0)
	And S.[Episode No]=E.[Episode No] And E.[Episode No]=P.[Episode No]
	And Convert(Int,SubString(S.[Patient No],7,6))=C.[UGIPatientId]
Union All
 SELECT C.[HospitalNumber] As CNN, C.Forename1, C.Surname, Convert(Int,SubString(S.[Patient No],7,6)) As PatientId, S.[Episode No] As ProcedureId, S.[Site No] As SiteId
 , [Region] As Region
, Case T.[Stent insertion] When -1 Then 1 Else 0 END As [StentInsertion]
, Case T.[Stent insertion] When -1 Then
	Case When T.[Correct stent placement]=-1 Then
		''Correctly placed''
	Else
		Case T.[Stent placement failure] 
			When 0 Then ''Failed but no reason given'' 
			When 1 Then ''Too proximal'' 
			When 2 Then ''Too distal'' 
			When 3 Then ''Failed deployment'' 
			Else ''Failed but no reason given''
		End
	End
Else
	''Placed but not recorded''
End As [Placement]
, Convert(Date,E.[Episode date]) As CreatedOn
, E.[Age at procedure] As Age
, Convert(INT,SubString(P.Endoscopist2,7,6))+1000000 As Endoscopist1Id
, Convert(INT,SubString(P.Assistant1,7,6))+1000000 As Endoscopist2Id
, 1 As ProcedureTypeId, ''DUO'' As SubType, ''UGI'' As Release
 From [Upper GI sites] S, [dbo].[Upper GI therapeutic] T, Episode E, [dbo].[Upper GI Procedure] P, ERS_VW_Patients C
 WHERE (NOT Continuous=-1 OR [Continuous start]=-1)
 And S.[Site No]=T.[Site No] And S.[Episode No]=T.[Episode No]
 And [Stent insertion]=-1
 And S.[Episode No]=E.[Episode No] And E.[Episode No]=P.[Episode No]
 And Convert(Int,SubString(S.[Patient No],7,6))=C.[UGIPatientId]
Union All
 Select 
 C.[HospitalNumber] As CNN, C.Forename1, C.Surname,
 P.PatientId, P.ProcedureId, S.SiteId, R.Region, T.StentInsertion
 , Case T.GastrostomyInsertion 
	When 1 Then 
		Case T.CorrectPEGPlacement When 1 Then ''Correct placement''
		Else ''Failed deployent'' End
	Else 
		IsNull((Select Case When E.CompletionStatus=1 Then ''Correctly placed'' Else Case E.FailureReason When 0 Then ''Failed but no reason given'' Else ''Failed deployment'' End End From ERS_UpperGIExtentOfIntubation E Where E.ProcedureId=P.ProcedureId),''Placed but not recorded'')
	End
As [Placement]
 , Convert(Date,P.CreatedOn) As CreatedOn
 , Convert(int,P.CreatedOn-C.[Dateofbirth])/365 As Age
 , IsNull(Endoscopist1,0) As Endoscopist1Id
 , IsNull(Endoscopist2,0) As Endoscopist2Id
 ,P.ProcedureType As ProcedureTypeId
 , Case GastrostomyInsertion When 1 Then IsNull((Select Case When JejunostomyInsertion Is Null Then ''PEG'' Else ''PEJ'' End  From ERS_UpperGIIndications I Where I.ProcedureId=P.ProcedureId),''PEG'') Else Case P.ProcedureType When 3 Then ''COL'' When 4 Then ''COL'' Else 
 Case When S.RegionId Between 1 And 9 Then ''OES'' Else Case When S.RegionId Between 24 And 39 Then ''DUO'' Else ''STO'' End End
  End End As SubType
 ,''ERS'' As Release
 From ERS_UpperGITherapeutics T, ERS_Sites S, ERS_Procedures P, ERS_Regions R, ERS_VW_Patients C
 Where T.SiteId=S.SiteId And S.ProcedureId=P.ProcedureId And S.RegionId=R.RegionId And P.ProcedureType=R.ProcedureType
 And (T.StentInsertion=1 Or T.GastrostomyInsertion=1)
 And P.PatientId=C.[UGIPatientId]
Union All
 SELECT C.[HospitalNumber] As CNN, C.Forename1, C.Surname, Convert(Int,SubString(S.[Patient No],7,6)) As PatientId, S.[Episode No] As ProcedureId, S.[Site No] As SiteId
 , [Region] As Region
, Case T.[Stent insertion] When -1 Then 1 Else 0 END As [StentInsertion]
, Case T.[Gastrostomy Insertion (PEG)] When -1 Then
	Case When T.[Correct stent placement]=-1 Then
		''Correctly placed''
	Else
		Case IsNull(T.[PEG/PEJ placement failure reason],'''') When '''' Then
			''Failed but no reason given''
		Else
			''Failed deployment''
		End
	End
Else
	''Placed but not recorded''
End As [Placement]
, Convert(Date,E.[Episode date]) As CreatedOn
, E.[Age at procedure] As Age
, Convert(INT,SubString(P.Endoscopist2,7,6))+1000000 As Endoscopist1Id
, Convert(INT,SubString(P.Assistant1,7,6))+1000000 As Endoscopist2Id
, 1 As ProcedureTypeId, T.[Insertion proc] As SubType, ''UGI'' As Release
 From [Upper GI sites] S, [dbo].[Upper GI therapeutic] T, Episode E, [dbo].[Upper GI Procedure] P, ERS_VW_Patients C
 WHERE (NOT Continuous=-1 OR [Continuous start]=-1)
 And S.[Site No]=T.[Site No] And S.[Episode No]=T.[Episode No]
 And T.[Gastrostomy Insertion (PEG)]=-1 And T.[Insertion proc]=''PEG''
 And S.[Episode No]=E.[Episode No] And E.[Episode No]=P.[Episode No]
 And Convert(Int,SubString(S.[Patient No],7,6))=C.[UGIPatientId]
Union All
 SELECT C.[HospitalNumber] As CNN, C.Forename1, C.Surname, Convert(Int,SubString(S.[Patient No],7,6)) As PatientId, S.[Episode No] As ProcedureId, S.[Site No] As SiteId
 , [Region] As Region
, Case T.[Stent insertion] When -1 Then 1 Else 0 END As [StentInsertion]
, Case T.[Gastrostomy Insertion (PEG)] When -1 Then
	Case When T.[Correct stent placement]=-1 Then
		''Correctly placed''
	Else
		Case IsNull(T.[PEG/PEJ placement failure reason],'''') When '''' Then
			''Failed but no reason given''
		Else
			''Failed deployment''
		End
	End
Else
	''Placed but not recorded''
End As [Placement]
, Convert(Date,E.[Episode date]) As CreatedOn
, E.[Age at procedure] As Age
, Convert(INT,SubString(P.Endoscopist2,7,6))+1000000 As Endoscopist1Id
, Convert(INT,SubString(P.Assistant1,7,6))+1000000 As Endoscopist2Id
, 1 As ProcedureTypeId, T.[Insertion proc] As SubType, ''UGI'' As Release
 From [Upper GI sites] S, [dbo].[Upper GI therapeutic] T, Episode E, [dbo].[Upper GI Procedure] P, ERS_VW_Patients C
 WHERE (NOT Continuous=-1 OR [Continuous start]=-1)
 And S.[Site No]=T.[Site No] And S.[Episode No]=T.[Episode No]
 And T.[Gastrostomy Insertion (PEG)]=-1 And T.[Insertion proc]=''PEJ''
 And S.[Episode No]=E.[Episode No] And E.[Episode No]=P.[Episode No]
 And Convert(Int,SubString(S.[Patient No],7,6))=C.[UGIPatientId]
Union All
 Select 
 C.[HospitalNumber] As CNN, C.Forename1, C.Surname,
 P.PatientId, P.ProcedureId, S.SiteId, R.Region, T.StentInsertion
 , Case T.GastrostomyInsertion 
	When 1 Then 
		Case T.CorrectPEGPlacement When 1 Then ''Correct placement''
		Else ''Failed deployent'' End
	Else 
		IsNull((Select Case When E.CompletionStatus=1 Then ''Correctly placed'' Else Case E.FailureReason When 0 Then ''Failed but no reason given'' Else ''Failed deployment'' End End From ERS_UpperGIExtentOfIntubation E Where E.ProcedureId=P.ProcedureId),''Placed but not recorded'')
	End
As [Placement]
 , Convert(Date,P.CreatedOn) As CreatedOn
 , Convert(int,P.CreatedOn-C.[Dateofbirth])/365 As Age
 , IsNull(Endoscopist1,0) As Endoscopist1Id
 , IsNull(Endoscopist2,0) As Endoscopist2Id
 ,P.ProcedureType As ProcedureTypeId
 , Case GastrostomyInsertion When 1 Then IsNull((Select Case When JejunostomyInsertion Is Null Then ''PEG'' Else ''PEJ'' End  From ERS_UpperGIIndications I Where I.ProcedureId=P.ProcedureId),''PEG'') Else Case P.ProcedureType When 3 Then ''COL'' When 4 Then ''COL'' Else 
 Case When S.RegionId Between 1 And 9 Then ''OES'' Else Case When S.RegionId Between 24 And 39 Then ''DUO'' Else ''STO'' End End
  End End As SubType
 ,''ERS'' As Release
 From ERS_UpperGITherapeutics T, ERS_Sites S, ERS_Procedures P, ERS_Regions R, ERS_VW_Patients C
 Where T.SiteId=S.SiteId And S.ProcedureId=P.ProcedureId And S.RegionId=R.RegionId And P.ProcedureType=R.ProcedureType
 And (T.StentInsertion=1 Or T.GastrostomyInsertion=1)
 And P.PatientId=C.[PatientId]
'
END
ELSE
BEGIN
SET @sql = '
Create View [dbo].[v_rep_StentPositioning] As
 Select 
 C.[HospitalNumber] As CNN, C.Forename1, C.Surname,
 P.PatientId, P.ProcedureId, S.SiteId, R.Region, T.StentInsertion
 , Case T.GastrostomyInsertion 
	When 1 Then 
		Case T.CorrectPEGPlacement When 1 Then ''Correct placement''
		Else ''Failed deployent'' End
	Else 
		IsNull((Select Case When E.CompletionStatus=1 Then ''Correctly placed'' Else Case E.FailureReason When 0 Then ''Failed but no reason given'' Else ''Failed deployment'' End End From ERS_UpperGIExtentOfIntubation E Where E.ProcedureId=P.ProcedureId),''Placed but not recorded'')
	End
As [Placement]
 , Convert(Date,P.CreatedOn) As CreatedOn
 , Convert(int,P.CreatedOn-C.[Dateofbirth])/365 As Age
 , IsNull(Endoscopist1,0) As Endoscopist1Id
 , IsNull(Endoscopist2,0) As Endoscopist2Id
 ,P.ProcedureType As ProcedureTypeId
 , Case GastrostomyInsertion When 1 Then IsNull((Select Case When JejunostomyInsertion Is Null Then ''PEG'' Else ''PEJ'' End  From ERS_UpperGIIndications I Where I.ProcedureId=P.ProcedureId),''PEG'') Else Case P.ProcedureType When 3 Then ''COL'' When 4 Then ''COL'' Else 
 Case When S.RegionId Between 1 And 9 Then ''OES'' Else Case When S.RegionId Between 24 And 39 Then ''DUO'' Else ''STO'' End End
  End End As SubType
 ,''ERS'' As Release
 From ERS_UpperGITherapeutics T, ERS_Sites S, ERS_Procedures P, ERS_Regions R, ERS_VW_Patients C
 Where T.SiteId=S.SiteId And S.ProcedureId=P.ProcedureId And S.RegionId=R.RegionId And P.ProcedureType=R.ProcedureType
 And (T.StentInsertion=1 Or T.GastrostomyInsertion=1)
 And P.PatientId=C.[UGIPatientId]
Union All
 Select 
 C.[HospitalNumber] As CNN, C.Forename1, C.Surname,
 P.PatientId, P.ProcedureId, S.SiteId, R.Region, T.StentInsertion
 , Case T.GastrostomyInsertion 
	When 1 Then 
		Case T.CorrectPEGPlacement When 1 Then ''Correct placement''
		Else ''Failed deployent'' End
	Else 
		IsNull((Select Case When E.CompletionStatus=1 Then ''Correctly placed'' Else Case E.FailureReason When 0 Then ''Failed but no reason given'' Else ''Failed deployment'' End End From ERS_UpperGIExtentOfIntubation E Where E.ProcedureId=P.ProcedureId),''Placed but not recorded'')
	End
As [Placement]
 , Convert(Date,P.CreatedOn) As CreatedOn
 , Convert(int,P.CreatedOn-C.[Dateofbirth])/365 As Age
 , IsNull(Endoscopist1,0) As Endoscopist1Id
 , IsNull(Endoscopist2,0) As Endoscopist2Id
 ,P.ProcedureType As ProcedureTypeId
 , Case GastrostomyInsertion When 1 Then IsNull((Select Case When JejunostomyInsertion Is Null Then ''PEG'' Else ''PEJ'' End  From ERS_UpperGIIndications I Where I.ProcedureId=P.ProcedureId),''PEG'') Else Case P.ProcedureType When 3 Then ''COL'' When 4 Then ''COL'' Else 
 Case When S.RegionId Between 1 And 9 Then ''OES'' Else Case When S.RegionId Between 24 And 39 Then ''DUO'' Else ''STO'' End End
  End End As SubType
 ,''ERS'' As Release
 From ERS_UpperGITherapeutics T, ERS_Sites S, ERS_Procedures P, ERS_Regions R, ERS_VW_Patients C
 Where T.SiteId=S.SiteId And S.ProcedureId=P.ProcedureId And S.RegionId=R.RegionId And P.ProcedureType=R.ProcedureType
 And (T.StentInsertion=1 Or T.GastrostomyInsertion=1)
 And P.PatientId=C.[PatientId]
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'v_rep_ReversingAgent', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[v_rep_ReversingAgent] As
Select P.[HospitalNumber] As CNN, Convert(int,SubString(E.[Patient no],7,6)) As PatientID, IsNull(P.Surname,'''')+'' ''+IsNull(P.Forename1,'''') As PatientName, E.[Episode date] As CreatedOn, E.[Age at procedure] As Age
, PP.[Episode No] As ProcedureId, 
DL.[Drug name] As DrugName,
DL.[Drug name]+'' ''+Convert(varchar(10),Dose) +'' ''+DL.Units As Agent
, Case When (SubString(Status,1,1)=''1'' And [Combined procedure]=0) Then ''OGD'' Else 
		Case When SubString(Status,5,1)=''1'' Then ''EUS-OGD'' Else
			Case When (SubString(Status,2,1)=''1'' OR (SubString(Status, 1, 2)=''11'' AND [Combined procedure]=99)) Then ''ERCP'' Else
				Case When (SubString(Status, 6, 1)=''1'' OR (SubString(Status, 1, 6)=''100001'' AND [Combined procedure]=88)) Then ''EUS(HPB)'' Else 
					Case When SUBSTRING(Status, 32, 1)=''1'' Then 
						Case When SubString([Status],34,1)=1 Then ''COL'' Else ''SIG'' End
					Else 
						Case When SubString(Status, 6, 1)=''1'' Then ''Pro'' Else ''???'' End
					End
				End
			End
		End
	End As ProcedureType,
	''UGI'' As Release
 From ERS_VW_Patients P, Episode E, [Patient Premedication] PP, [Drug list] DL
 WHERE DL.[Is reversing agent]=-1 And P.[UGIPatientId]=Convert(INT, SubString(E.[Patient No],7,6))
 And E.[Episode No]=PP.[Episode No]
 And PP.[Drug No]=DL.[Drug no]
Union All
Select [HospitalNumber] As CNN, P.[UGIPatientId] As PatientID, IsNull(Surname,'''')+'' ''+IsNull(Forename1,'''') As PatientName, Procs.CreatedOn, 
(Convert(int,Procs.CreatedOn)-Convert(int,P.[Dateofbirth]))/365 As Age, Procs.ProcedureId, D.DrugName, D.DrugName+'' ''+Convert(varchar(10),D.DefaultDose)+'' ''+D.Units As Agent,
Case Procs.ProcedureType 
	When 1 Then ''OGD''
	When 2 Then ''ERCP''
	When 3 Then ''COL''
	When 4 Then ''SIG''
	When 5 Then ''Proctoscopy''
	When 6 Then ''EUS-OGD''
	When 7 Then ''EUS-HPB''
	When 8 Then ''Bonchoscopy''
	When 9 Then ''EBUS''
	When 10 Then ''Thorax''
	When 11 Then ''Flexi''
	When 12 Then ''Rigid''
	Else '''' End As ProcedureType,
''ERS'' As Release
From ERS_VW_Patients P, ERS_Procedures Procs, ERS_UpperGIPremedication PM, ERS_DrugList D
Where P.[PatientId]=Procs.PatientId And Procs.ProcedureId=PM.ProcedureId And PM.DrugNo=D.DrugNo And D.IsReversingAgent=1
'
END
ELSE
BEGIN
SET @sql = '
Create View [dbo].[v_rep_ReversingAgent] As
Select [HospitalNumber] As CNN, P.[UGIPatientId] As PatientID, IsNull(Surname,'''')+'' ''+IsNull(Forename1,'''') As PatientName, Procs.CreatedOn, 
(Convert(int,Procs.CreatedOn)-Convert(int,P.[Dateofbirth]))/365 As Age, Procs.ProcedureId, D.DrugName, D.DrugName+'' ''+Convert(varchar(10),D.DefaultDose)+'' ''+D.Units As Agent,
Case Procs.ProcedureType 
	When 1 Then ''OGD''
	When 2 Then ''ERCP''
	When 3 Then ''COL''
	When 4 Then ''SIG''
	When 5 Then ''Proctoscopy''
	When 6 Then ''EUS-OGD''
	When 7 Then ''EUS-HPB''
	When 8 Then ''Bonchoscopy''
	When 9 Then ''EBUS''
	When 10 Then ''Thorax''
	When 11 Then ''Flexi''
	When 12 Then ''Rigid''
	Else '''' End As ProcedureType,
''ERS'' As Release
From ERS_VW_Patients P, ERS_Procedures Procs, ERS_UpperGIPremedication PM, ERS_DrugList D
Where P.[PatientId]=Procs.PatientId And Procs.ProcedureId=PM.ProcedureId And PM.DrugNo=D.DrugNo And D.IsReversingAgent=1
'
END

EXEC sp_executesql @sql
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'v_rep_Comfort', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[v_rep_Comfort] As
Select 
	Patients.[HospitalNumber],
	Patients.[Surname],
	Patients.[Forename1],
	Patients.[PatientId] As [PatientId],
	Procs.[ProcedureId] As [ProcedureId],
	IsNull(Patients.Gender,''?'') As Gender,
	Convert(Date,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth]))) As [DOB],
	Procs.[CreatedOn],
	(Convert(int,Procs.[CreatedOn])-Convert(INT,Convert(Datetime,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth])))))/365 As Age,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Endoscopist1,0)) As Endoscopist1,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Endoscopist2,0)) As Endoscopist2,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Assistant,0)) As Assistant1,
	''E.0'' As Assistant2,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.ListConsultant,0)) As ListConsultant,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Nurse1,0)) As Nurse1,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Nurse2,0)) As Nurse2,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Instrument2,0)) As Instrument1,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Instrument2,0)) As Instrument2,
	[PatDiscomfortPatient] As [PatDiscomfortId],
	Case QA.[PatSedation]
		When 4 Then 
		Case QA.[PatSedationAsleepResponseState] 
			When 1 Then 4	--''Asleep but responding to name''
			When 2 Then 5	--''Asleep but responding to touch''
			When 3 Then 6	--''Asleep but unresponsive''
			Else 0 End
	Else QA.[PatSedation] End As [NurseAssPatientSedationId],
	IsNull(QA.[PatDiscomfortNurse],0) As [NurseAssPatientComfortId],
	IsNull([PatientDiscomfort],0) As [PatientAssComfortId],
	Case ProcedureType
		When 1 Then ''OGD''
		When 2 Then ''ERC''
		When 3 Then ''COL''
		When 4 Then ''SIG''
		When 5 Then ''PRO''
		When 6 Then ''EUS''
		When 7 Then ''HPB''
	End
	As ProcedureType, 
	''ERS'' As Release
From [dbo].[ERS_UpperGIQA] QA
	, [dbo].[ERS_Procedures] Procs
	, [ERS_VW_Patients] Patients
Where Procs.ProcedureId=QA.ProcedureId
	And Patients.[PatientId]=Procs.PatientId
Union
Select 
	Patients.[HospitalNumber],
	Patients.[Surname],
	Patients.[Forename1],
	Patients.[PatientId] As [PatientId],
	Procs.[Episode No] As [ProcedureId],
	IsNull(Patients.Gender,''?'') As Gender,
	Convert(Date,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth]))) As [DOB],
	IsNull(Procs.[Procedure date],Episode.[Episode date]) As CreatedOn,
	(Convert(int,(Procs.[Procedure date])-Convert(Datetime,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth])))))/365 As Age,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist2,''000000000000''),7,6))) As Endoscopist1,
	''U.0'' As Endoscopist2,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist1,''000000000000''),7,6))) As Assistant1,
	''U.0'' As Assistant2,
	''U.0'' As [ListConsultant],
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse1,''000000000000''),7,6))) As Nurse1,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse2,''000000000000''),7,6))) As Nurse2,
	''U.0'' As Instrument1,
	''U.0'' As Instrument2,
	IsNull(QA.[Pat discomfort],0)  As [PatDiscomfortId],
	Case QA.[Pat sedation]
		When 4 Then 
		Case QA.[Pat sedation asleep but responding] 
			When 1 Then 4	--''Asleep but responding to name''
			When 2 Then 5	--''Asleep but responding to touch''
			When 3 Then 6	--''Asleep but unresponsive''
			Else 0 End
	Else QA.[Pat sedation] End As [NurseAssPatientSedationId],
	IsNull(QA.[Pat discomfort],0) As [NurseAssPatientComfortId],
	IsNull([Pat ass discomfort],0) As [PatientAssComfortId],
	''OGD'' As ProcedureType,
	''UGI'' As Release
From 
	[dbo].[Upper GI Procedure] Procs
	, [dbo].[ERS_VW_Patients] Patients
	, [dbo].[Episode] Episode
	, [dbo].[Upper GI QA] QA
Where 
	Patients.[UGIPatientId]=convert(int,SubString(Procs.[Patient No],7,6)) 
	And Procs.[Episode No]=Episode.[Episode No] And Procs.[Patient No]=Episode.[Patient No]
	And Episode.[Episode No]=QA.[Episode No] And Convert(INT,SubString(Episode.[Patient No],7,6))=Patients.UGIPatientId
	And Procs.[Procedure date] Is Not Null
	And SubString(Episode.[Status],1,1)=1
Union
Select 
	Patients.[HospitalNumber],
	Patients.[Surname],
	Patients.[Forename1],
	Patients.[PatientId] As [PatientId],
	Procs.[Episode No] As [ProcedureId],
	IsNull(Patients.Gender,''?'') As Gender,
	Convert(Date,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth]))) As [DOB],
	IsNull(Procs.[Procedure date],Episode.[Episode date]) As CreatedOn,
	(Convert(int,(Procs.[Procedure date])-Convert(Datetime,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth])))))/365 As Age,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist2,''000000000000''),7,6))) As Endoscopist1,
	''U.''+CONVERT(NVARCHAR(20),0) As Endoscopist2,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist1,''000000000000''),7,6))) As Assistant1,
	''U.''+CONVERT(NVARCHAR(20),0) As Assistant2,
	''U.''+CONVERT(NVARCHAR(20),0) As [ListConsultant],
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse1,''000000000000''),7,6))) As Nurse1,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse2,''000000000000''),7,6))) As Nurse2,
	''U.''+CONVERT(NVARCHAR(20),0) As Instrument1,
	''U.''+CONVERT(NVARCHAR(20),0) As Instrument2,
	IsNull(QA.[Pat discomfort],0) As [PatDiscomfortId],
	Case QA.[Pat sedation]
		When 4 Then 
		Case QA.[Pat sedation asleep but responding] 
			When 1 Then 4	--''Asleep but responding to name''
			When 2 Then 5	--''Asleep but responding to touch''
			When 3 Then 6	--''Asleep but unresponsive''
			Else 0 End
	Else QA.[Pat sedation] End As [NurseAssPatientSedationId],
	IsNull(QA.[Pat discomfort],0) As [NurseAssPatientComfortId],
	IsNull([Pat ass discomfort],0) As [PatientAssComfortId],
	''EUS'' As [ProcedureType],
	''UGI'' As Release
From 
	[dbo].[EUS Procedure] Procs
	, [dbo].[ERS_VW_Patients] Patients
	, [dbo].[Episode] Episode
	, [dbo].[Upper GI QA] QA
Where 
	Patients.UGIPatientId=convert(int,SubString(Procs.[Patient No],7,6)) 
	And Procs.[Episode No]=Episode.[Episode No] And Procs.[Patient No]=Episode.[Patient No]
	And Episode.[Episode No]=QA.[Episode No] And Convert(INT,SubString(Episode.[Patient No],7,6))=Patients.UGIPatientId
	And Procs.[Procedure date] Is Not Null
	And SubString(Episode.[Status],1,5)=1
Union
Select 
	Patients.[HospitalNumber],
	Patients.[Surname],
	Patients.[Forename1],
	Patients.[PatientId] As [PatientId],
	Procs.[Episode No] As [ProcedureId],
	IsNull(Patients.Gender,''?'') As Gender,
	Convert(Date,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth]))) As [DOB],
	IsNull(Procs.[Procedure date],Episode.[Episode date]) As CreatedOn,
	(Convert(int,(Procs.[Procedure date])-Convert(Datetime,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth])))))/365 As Age,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist1,''000000000000''),7,6))) As Endoscopist1,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist2,''000000000000''),7,6))) As Endoscopist2,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Assistant1,''000000000000''),7,6))) As Assistant1,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Assistant2,''000000000000''),7,6))) As Assistant2,
	''U.''+CONVERT(NVARCHAR(20),Case When Procs.[Consultant No]<0 Then 0 Else IsNull(Procs.[Consultant No],0) End) As [ListConsultant],
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse1,''000000000000''),7,6))) As Nurse1,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse2,''000000000000''),7,6))) As Nurse2,
	''U.''+CONVERT(NVARCHAR(20),0) As Instrument1,
	''U.''+CONVERT(NVARCHAR(20),0) As Instrument2,
	IsNull(QA.[Pat discomfort],0) As [PatDiscomfortId],
	Case QA.[Pat sedation]
		When 4 Then 
		Case QA.[Pat sedation asleep but responding] 
			When 1 Then 4	--''Asleep but responding to name''
			When 2 Then 5	--''Asleep but responding to touch''
			When 3 Then 6	--''Asleep but unresponsive''
			Else 0 End
	Else QA.[Pat sedation] End As [NurseAssPatientSedationId],
	IsNull(QA.[Pat discomfort],0) As [NurseAssPatientComfortId],
	IsNull([Pat ass discomfort],0) As [PatientAssComfortId],
	''ERC'' As ProcedureType,
	''UGI'' As Release
From 
	[dbo].[ERCP Procedure] Procs
	, [dbo].[ERS_VW_Patients] Patients
	, [dbo].[Episode] Episode
	, [dbo].[ERCP QA] QA
Where 
	Patients.UGIPatientId=convert(int,SubString(Procs.[Patient No],7,6)) 
	And Procs.[Episode No]=Episode.[Episode No] And Procs.[Patient No]=Episode.[Patient No]
	And Episode.[Episode No]=QA.[Episode No] --And Episode.[Patient No]=Patients.[UGIPatientId]
Union
Select 
	Patients.[HospitalNumber],
	Patients.[Surname],
	Patients.[Forename1],
	Patients.[PatientId] As [PatientId],
	Procs.[Episode No] As [ProcedureId],
	IsNull(Patients.Gender,''?'') As Gender,
	Convert(Date,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth]))) As [DOB],
	IsNull(Procs.[Procedure date],Episode.[Episode date]) As CreatedOn,
	Episode.[Age at procedure] As Age,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist2,''000000000000''),7,6))) As Endoscopist1,
	''U.''+CONVERT(NVARCHAR(20),0) As Endoscopist2,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist1,''000000000000''),7,6))) As Assistant1,
	''U.''+CONVERT(NVARCHAR(20),0) As Assistant2,
	''U.''+CONVERT(NVARCHAR(20),0) As [ListConsultant],
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse1,''000000000000''),7,6))) As Nurse1,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse2,''000000000000''),7,6))) As Nurse2,
	''U.''+CONVERT(NVARCHAR(20),0) As Instrument1,
	''U.''+CONVERT(NVARCHAR(20),0) As Instrument2,
	IsNull(QA.[Pat discomfort],0) As [PatDiscomfortId],
	Case QA.[Pat sedation]
		When 4 Then 
		Case QA.[Pat sedation asleep but responding] 
			When 1 Then 4	--''Asleep but responding to name''
			When 2 Then 5	--''Asleep but responding to touch''
			When 3 Then 6	--''Asleep but unresponsive''
			Else 0 End
	Else QA.[Pat sedation] End As [NurseAssPatientSedationId],
	IsNull(QA.[Pat discomfort],0) As [NurseAssPatientComfortId],
	IsNull([Pat ass discomfort],0) As [PatientAssComfortId],
	Case Procs.[Procedure type]
		When 0 Then ''COL''
		When 1 Then ''SIG''
		When 2 Then ''PRO''
	End As ProcedureType,
	''UGI'' As Release
From 
	[dbo].[Colon Procedure] Procs
	, [dbo].[ERS_VW_Patients] Patients
	, [dbo].[Episode] Episode
	, [dbo].[Colon QA] QA
Where 
	Patients.[UGIPatientId]=convert(int,SubString(Procs.[Patient No],7,6)) 
	And Procs.[Episode No]=Episode.[Episode No] And Procs.[Patient No]=Episode.[Patient No]
	And Episode.[Episode No]=QA.[Episode No] --And Episode.[Patient No]=Patients.[Patient No]
	And Procs.[Procedure Type]=0
Union
Select 
	Patients.[HospitalNumber],
	Patients.[Surname],
	Patients.[Forename1],
	Patients.[PatientId] As [PatientId],
	Procs.[Episode No] As [ProcedureId],
	IsNull(Patients.Gender,''?'') As Gender,
	Convert(Date,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth]))) As [DOB],
	IsNull(Procs.[Procedure date],Episode.[Episode date]) As CreatedOn,
	Episode.[Age at procedure] As Age,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist2,''000000000000''),7,6))) As Endoscopist1,
	''U.''+CONVERT(NVARCHAR(20),0) As Endoscopist2,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist1,''000000000000''),7,6))) As Assistant1,
	''U.''+CONVERT(NVARCHAR(20),0) As Assistant2,
	''U.''+CONVERT(NVARCHAR(20),0) As [ListConsultant],
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse1,''000000000000''),7,6))) As Nurse1,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse2,''000000000000''),7,6))) As Nurse2,
	''U.''+CONVERT(NVARCHAR(20),0) As Instrument1,
	''U.''+CONVERT(NVARCHAR(20),0) As Instrument2,
	IsNull(QA.[Pat discomfort],0) As [PatDiscomfortId],
	Case QA.[Pat sedation]
		When 4 Then 
		Case QA.[Pat sedation asleep but responding] 
			When 1 Then 4	--''Asleep but responding to name''
			When 2 Then 5	--''Asleep but responding to touch''
			When 3 Then 6	--''Asleep but unresponsive''
			Else 0 End
	Else QA.[Pat sedation] End As [NurseAssPatientSedationId],
	IsNull(QA.[Pat discomfort],0) As [NurseAssPatientComfortId],
	IsNull([Pat ass discomfort],0) As [PatientAssComfortId],
	Case Procs.[Procedure type]
		When 0 Then ''COL''
		When 1 Then ''SIG''
		When 2 Then ''PRO''
	End As ProcedureType,
	''UGI'' As Version
From 
	[dbo].[Colon Procedure] Procs
	, [dbo].[ERS_VW_Patients] Patients
	, [dbo].[Episode] Episode
	, [dbo].[Colon QA] QA
Where 
	Patients.[UGIPatientId]=convert(int,SubString(Procs.[Patient No],7,6)) 
	And Procs.[Episode No]=Episode.[Episode No] And Procs.[Patient No]=Episode.[Patient No]
	And Episode.[Episode No]=QA.[Episode No] --And Episode.[Patient No]=Patients.[Patient No]
	And Procs.[Procedure Type]=1
Union
Select 
	Patients.[HospitalNumber],
	Patients.[Surname],
	Patients.[Forename1],
	Patients.[PatientId] As [PatientId],
	Procs.[Episode No] As [ProcedureId],
	IsNull(Patients.Gender,''?'') As Gender,
	Convert(Date,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth]))) As [DOB],
	IsNull(Procs.[Procedure date],Episode.[Episode date]) As CreatedOn,
	Episode.[Age at procedure] As Age,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist2,''000000000000''),7,6))) As Endoscopist1,
	''U.''+CONVERT(NVARCHAR(20),0) As Endoscopist2,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist1,''000000000000''),7,6))) As Assistant1,
	''U.''+CONVERT(NVARCHAR(20),0) As Assistant2,
	''U.''+CONVERT(NVARCHAR(20),0) As [ListConsultant],
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse1,''000000000000''),7,6))) As Nurse1,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse2,''000000000000''),7,6))) As Nurse2,
	''U.''+CONVERT(NVARCHAR(20),0) As Instrument1,
	''U.''+CONVERT(NVARCHAR(20),0) As Instrument2,
	IsNull(QA.[Pat discomfort],0) As [PatDiscomfortId],
	Case QA.[Pat sedation]
		When 4 Then 
		Case QA.[Pat sedation asleep but responding] 
			When 1 Then 4	--''Asleep but responding to name''
			When 2 Then 5	--''Asleep but responding to touch''
			When 3 Then 6	--''Asleep but unresponsive''
			Else 0 End
	Else QA.[Pat sedation] End As [NurseAssPatientSedationId],
	IsNull(QA.[Pat discomfort],0) As [NurseAssPatientComfortId],
	IsNull([Pat ass discomfort],0) As [PatientAssComfortId],
	Case Procs.[Procedure type]
		When 0 Then ''COL''
		When 1 Then ''SIG''
		When 2 Then ''PRO''
	End As ProcedureType,
	''UGI'' As Release
From 
	[dbo].[Colon Procedure] Procs
	, [dbo].[ERS_VW_Patients] Patients
	, [dbo].[Episode] Episode
	, [dbo].[Colon QA] QA
Where 
	Patients.[UGIPatientId]=convert(int,SubString(Procs.[Patient No],7,6)) 
	And Procs.[Episode No]=Episode.[Episode No] And Procs.[Patient No]=Episode.[Patient No]
	And Episode.[Episode No]=QA.[Episode No] --And Episode.[Patient No]=Patients.[Patient No]
	And Procs.[Procedure Type]=2
Union
Select 
	Patients.[HospitalNumber],
	Patients.[Surname],
	Patients.[Forename1],
	Patients.[PatientId] As [PatientId],
	Procs.[Episode No] As [ProcedureId],
	IsNull(Patients.Gender,''?'') As Gender,
	Convert(Date,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth]))) As [DOB],
	IsNull(Procs.[Procedure date],Episode.[Episode date]) As CreatedOn,
	(Convert(int,(Procs.[Procedure date])-Convert(Datetime,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth])))))/365 As Age,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist2,''000000000000''),7,6))) As Endoscopist1,
	''U.''+CONVERT(NVARCHAR(20),0) As Endoscopist2,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Endoscopist1,''000000000000''),7,6))) As Assistant1,
	''U.''+CONVERT(NVARCHAR(20),0) As Assistant2,
	''U.''+CONVERT(NVARCHAR(20),0) As [ListConsultant],
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse1,''000000000000''),7,6))) As Nurse1,
	''U.''+CONVERT(NVARCHAR(20),Convert(int,SubString(IsNull(Procs.Nurse2,''000000000000''),7,6))) As Nurse2,
	''U.''+CONVERT(NVARCHAR(20),0) As Instrument1,
	''U.''+CONVERT(NVARCHAR(20),0) As Instrument2,
	IsNull(QA.[Pat discomfort],0) As [PatDiscomfortId],
	Case QA.[Pat sedation]
		When 4 Then 
		Case QA.[Pat sedation asleep but responding] 
			When 1 Then 4	--''Asleep but responding to name''
			When 2 Then 5	--''Asleep but responding to touch''
			When 3 Then 6	--''Asleep but unresponsive''
			Else 0 End
	Else QA.[Pat sedation] End As [NurseAssPatientSedationId],
	IsNull(QA.[Pat discomfort],0) As [NurseAssPatientComfortId],
	IsNull([Pat ass discomfort],0) As [PatientAssComfortId],
	''HPB'' As [ProcedureType],
	''UGI'' As Release
From 
	[dbo].[EUS Procedure] Procs
	, [dbo].[ERS_VW_Patients] Patients
	, [dbo].[Episode] Episode
	, [dbo].[ERCP QA] QA
Where 
	Patients.[UGIPatientId]=convert(int,SubString(Procs.[Patient No],7,6)) 
	And Procs.[Episode No]=Episode.[Episode No] And Procs.[Patient No]=Episode.[Patient No]
	And Episode.[Episode No]=QA.[Episode No] And Convert(INT,SubString(Episode.[Patient No],7,6))=Patients.[UGIPatientId]
	And Procs.[Procedure date] Is Not Null
	And SubString(Episode.[Status],1,1)=4

	'
END
ELSE
BEGIN
SET @sql = '
Create View [dbo].[v_rep_Comfort] As
Select 
	Patients.[HospitalNumber],
	Patients.[Surname],
	Patients.[Forename1],
	Patients.[PatientId] As [PatientId],
	Procs.[ProcedureId] As [ProcedureId],
	IsNull(Patients.Gender,''?'') As Gender,
	Convert(Date,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth]))) As [DOB],
	Procs.[CreatedOn],
	(Convert(int,Procs.[CreatedOn])-Convert(INT,Convert(Datetime,Convert(varchar(4),DatePart(yyyy,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(mm,[Dateofbirth]))+''-''+Convert(varchar(2),DatePart(dd,[Dateofbirth])))))/365 As Age,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Endoscopist1,0)) As Endoscopist1,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Endoscopist2,0)) As Endoscopist2,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Assistant,0)) As Assistant1,
	''E.0'' As Assistant2,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.ListConsultant,0)) As ListConsultant,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Nurse1,0)) As Nurse1,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Nurse2,0)) As Nurse2,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Instrument2,0)) As Instrument1,
	''E.''+CONVERT(NVARCHAR(20),IsNull(Procs.Instrument2,0)) As Instrument2,
	[PatDiscomfortPatient] As [PatDiscomfortId],
	Case QA.[PatSedation]
		When 4 Then 
		Case QA.[PatSedationAsleepResponseState] 
			When 1 Then 4	--''Asleep but responding to name''
			When 2 Then 5	--''Asleep but responding to touch''
			When 3 Then 6	--''Asleep but unresponsive''
			Else 0 End
	Else QA.[PatSedation] End As [NurseAssPatientSedationId],
	IsNull(QA.[PatDiscomfortNurse],0) As [NurseAssPatientComfortId],
	IsNull([PatientDiscomfort],0) As [PatientAssComfortId],
	Case ProcedureType
		When 1 Then ''OGD''
		When 2 Then ''ERC''
		When 3 Then ''COL''
		When 4 Then ''SIG''
		When 5 Then ''PRO''
		When 6 Then ''EUS''
		When 7 Then ''HPB''
	End
	As ProcedureType, 
	''ERS'' As Release
From [dbo].[ERS_UpperGIQA] QA
	, [dbo].[ERS_Procedures] Procs
	, [ERS_VW_Patients] Patients
Where Procs.ProcedureId=QA.ProcedureId
	And Patients.[PatientId]=Procs.PatientId
'
END
EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSA05A', 'S';
GO

Create Proc [dbo].[sp_rep_GRSA05A] @UserID INT=NULL, @UnitAsAWhole BIT=NULL, @NoNullData BIT=NULL As
Begin
	SET NOCOUNT ON
	Declare @TypesOfEndoscopists VARCHAR(32)=NULL
	Declare @FromDate DATE
	Declare @ToDate DATE
	Declare @WholeDB BIT
	Select @FromDate=FromDate, @ToDate=ToDate, @WholeDB = 1 From ERS_ReportFilter Where UserID=@UserID
	If @UserID Is Null 
	Begin
		Raiserror('The @UserID parameter is missing a value',11,1)
		PRINT 'Sintax:'
		Print '	Exec sp_rep_GRSB05A @UserID=[UserID], @UnitAsAWhole=[Unit A a Whole]'
		Print '	[UserID]: Session Value of PKUserId'
		Print ' [Unit A a Whole]: 1/0/TRUE/FALSE'
		Set @UserID=0
	End
	Create Table #aux(
		ID INT,
		CategoryID INT,
		Constraint AuxPK PRIMARY KEY CLUSTERED (ID, CategoryID),
		Concept VARCHAR(128)
	)
	Insert Into #aux (ID, CategoryID, Concept) Values (0,1,'Not completed')
	Insert Into #aux (ID, CategoryID, Concept) Values (1,1,'Not recorded')
	Insert Into #aux (ID, CategoryID, Concept) Values (2,1,'None-resting comfortably throughout')
	Insert Into #aux (ID, CategoryID, Concept) Values (3,1,'One or two episodes of mild discomfort, well tolerated')
	Insert Into #aux (ID, CategoryID, Concept) Values (4,1,'Two episodes of discomfort, adequately tolerated')
	Insert Into #aux (ID, CategoryID, Concept) Values (5,1,'Significant discomfort, experienced several times during procedure')
	Insert Into #aux (ID, CategoryID, Concept) Values (6,1,'Extreme discomfort frequently during test')
	Insert Into #aux (ID, CategoryID, Concept) Values (0,2,'Not completed')
	Insert Into #aux (ID, CategoryID, Concept) Values (1,2,'Not recorded')
	Insert Into #aux (ID, CategoryID, Concept) Values (2,2,'Awake')
	Insert Into #aux (ID, CategoryID, Concept) Values (3,2,'Drowsy')
	Insert Into #aux (ID, CategoryID, Concept) Values (4,2,'Asleep but responding to name')
	Insert Into #aux (ID, CategoryID, Concept) Values (5,2,'Asleep but responding to touch')
	Insert Into #aux (ID, CategoryID, Concept) Values (6,2,'Asleep but unresponsive')
	Insert Into #aux (ID, CategoryID, Concept) Values (0,3,'Not completed')
	Insert Into #aux (ID, CategoryID, Concept) Values (1,3,'Not recorded')
	Insert Into #aux (ID, CategoryID, Concept) Values (2,3,'No')
	Insert Into #aux (ID, CategoryID, Concept) Values (3,3,'Minimal')
	Insert Into #aux (ID, CategoryID, Concept) Values (4,3,'Mild')
	Insert Into #aux (ID, CategoryID, Concept) Values (5,3,'Moderate')
	Insert Into #aux (ID, CategoryID, Concept) Values (6,3,'Severe')
	Declare @ID INT
	Declare @Concept VARCHAR(128)
	Create Table #GRSB05A (
		ReportID INT,
		Consultant NVARCHAR(128),
		ConsultantID INT DEFAULT 0,
		Category1 VARCHAR(128),
		CategoryID INT,
		ID INT,
		Category2 VARCHAR(128),
		OGD INT DEFAULT 0,
		EUS INT DEFAULT 0,
		ERC INT DEFAULT 0,
		HPB INT DEFAULT 0,
		COL INT DEFAULT 0,
		SIG INT DEFAULT 0,
		PRO INT DEFAULT 0,
		OGDP Numeric(17,4) DEFAULT 0,
		EUSP Numeric(17,4) DEFAULT 0,
		ERCP Numeric(17,4) DEFAULT 0,
		HPBP Numeric(17,4) DEFAULT 0,
		COLP Numeric(17,4) DEFAULT 0,
		SIGP Numeric(17,4) DEFAULT 0,
		PROP Numeric(17,4) DEFAULT 0,
		I INT IDENTITY PRIMARY KEY CLUSTERED,
	)
	Create Table #GRSB05AEND (
		ReportID INT,
		Consultant NVARCHAR(128),
		ConsultantID INT DEFAULT 0,
		ID INT,
		Category1 VARCHAR(128),
		CategoryID INT,
		Category2 VARCHAR(128),
		OGD INT DEFAULT 0,
		EUS INT DEFAULT 0,
		ERC INT DEFAULT 0,
		HPB INT DEFAULT 0,
		COL INT DEFAULT 0,
		SIG INT DEFAULT 0,
		PRO INT DEFAULT 0,
		OGDP Numeric(17,4) DEFAULT 0,
		EUSP Numeric(17,4) DEFAULT 0,
		ERCP Numeric(17,4) DEFAULT 0,
		HPBP Numeric(17,4) DEFAULT 0,
		COLP Numeric(17,4) DEFAULT 0,
		SIGP Numeric(17,4) DEFAULT 0,
		PROP Numeric(17,4) DEFAULT 0,
		I INT IDENTITY PRIMARY KEY CLUSTERED,
	)
	Create Table #GRSB05ATOT (
		ConsultantID INT,
		OGD INT DEFAULT 0,
		EUS INT DEFAULT 0,
		ERC INT DEFAULT 0,
		HPB INT DEFAULT 0,
		COL INT DEFAULT 0,
		SIG INT DEFAULT 0,
		PRO INT DEFAULT 0
	)
	DECLARE @Consultant NVARCHAR(128)
	DECLARE @UGIID INT
	DECLARE @ERSID INT
	DECLARE @OGD Numeric(17,2)
	DECLARE @EUS Numeric(17,2)
	DECLARE @ERC Numeric(17,2)
	DECLARE @HPB Numeric(17,2)
	DECLARE @COL Numeric(17,2)
	DECLARE @SIG Numeric(17,2)
	DECLARE @PRO Numeric(17,2)
	DECLARE @NurseAssPatientSedation VARCHAR(128)
	DECLARE @NurseAssPatientComfort VARCHAR(128)
	DECLARE @PatientAssComfort VARCHAR(128)
	DECLARE @Category1 VARCHAR(128)
	DECLARE @Category2 VARCHAR(128)
	If IsNull(@UnitAsAWhole,0)=1
	Begin
		Insert Into #GRSB05ATOT (ConsultantID, OGD, EUS, ERC, HPB, COL, SIG, PRO)
		Select 
			ConsultantID=0,
			OGD=IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0) ,
			EUS=IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0) ,
			ERC=IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0) ,
			HPB=IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0) ,
			COL=IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0) ,
			SIG=IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0) ,
			PRO=IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0) 
		From v_rep_Comfort Comf
		Where Comf.CreatedOn>=@FromDate And Comf.CreatedOn<=@ToDate
		OR 1 = (CASE WHEN @WholeDB = 1 THEN 1 ELSE 0 END)
	End
	Else
	Begin
		Insert Into #GRSB05ATOT (ConsultantID, OGD, EUS, ERC, HPB, COL, SIG, PRO)
		Select 
			Consultant=C.ReportID,
			OGD=IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0) ,
			EUS=IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0) ,
			ERC=IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0) ,
			HPB=IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0) ,
			COL=IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0) ,
			SIG=IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0) ,
			PRO=IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0) 
		From v_rep_Comfort Comf, v_rep_Consultants C, ERS_ReportConsultants RC
		Where 
			C.ReportID=RC.ConsultantID And
			((Comf.Endoscopist1=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Endoscopist2=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.ListConsultant=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Assistant1=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Assistant2=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Nurse1=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Nurse2=C.ConsultantID And Comf.Release=C.Release))
			And (Comf.CreatedOn>=@FromDate And Comf.CreatedOn<=@ToDate
				OR 1 = (CASE WHEN @WholeDB = 1 THEN 1 ELSE 0 END))
		Group By C.ReportID
		Order By C.ReportID
	End
	If IsNull(@UnitAsAWhole,0)=1
	Begin
		Insert Into #GRSB05A (ReportID, Consultant, ConsultantID, CategoryID, ID, Category1, Category2, OGD, EUS, ERC, HPB, COL, SIG, PRO, OGDP, EUSP, ERCP, HPBP, COLP, SIGP, PROP)
		Select 
			0 As ReportID,
			Consultant='Endoscopy unit as a Whole',
			ConsultantID=0,
			CategoryID=1,
			ID=Comf.NurseAssPatientComfortId,
			Category1='Nurse assessment of patient comfort...',
			A1.Concept As Category2, 
			OGD=IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0) ,
			EUS=IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0) ,
			ERC=IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0) ,
			HPB=IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0) ,
			COL=IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0) ,
			SIG=IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0) ,
			PRO=IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0) ,
			OGDP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(OGD),1.)<>0 Then IsNull(Sum(OGD),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			EUSP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(EUS),1.)<>0 Then IsNull(Sum(EUS),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			ERCP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(ERC),1.)<>0 Then IsNull(Sum(ERC),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			HPBP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(HPB),1.)<>0 Then IsNull(Sum(HPB),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			COLP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(COL),1.)<>0 Then IsNull(Sum(COL),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			SIGP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(SIG),1.)<>0 Then IsNull(Sum(SIG),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			PROP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(PRO),1.)<>0 Then IsNull(Sum(PRO),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0))
		From v_rep_Comfort Comf, #aux A1
		Where Comf.NurseAssPatientComfortId=A1.ID And A1.CategoryID=1
		Group By A1.Concept, A1.ID, Comf.NurseAssPatientComfortId
		Union
		Select 
			0 As ReportID,
			Consultant='Endoscopy unit as a Whole',
			ConsultantID=0,
			CategoryID=2,
			ID=Comf.NurseAssPatientSedationId,
			Category1='Nurse assessment of patient sedation...',
			A1.Concept As Category2, 
			OGD=IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0) ,
			EUS=IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0) ,
			ERC=IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0) ,
			HPB=IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0) ,
			COL=IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0) ,
			SIG=IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0) ,
			PRO=IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0) ,
			OGDP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(OGD),1.)<>0 Then IsNull(Sum(OGD),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			EUSP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(EUS),1.)<>0 Then IsNull(Sum(EUS),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			ERCP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(ERC),1.)<>0 Then IsNull(Sum(ERC),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			HPBP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(HPB),1.)<>0 Then IsNull(Sum(HPB),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			COLP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(COL),1.)<>0 Then IsNull(Sum(COL),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			SIGP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(SIG),1.)<>0 Then IsNull(Sum(SIG),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			PROP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(PRO),1.)<>0 Then IsNull(Sum(PRO),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0))
		From v_rep_Comfort Comf, #aux A1
		Where Comf.NurseAssPatientSedationId=A1.ID And A1.CategoryID=1
		Group By A1.Concept, A1.ID, Comf.NurseAssPatientSedationId
		Union
		Select 
			0 As ReportID,
			Consultant='Endoscopy unit as a Whole',
			ConsultantID=0,
			CategoryID=3,
			ID=Comf.PatDiscomfortId,
			Category1='Patient assessment of comfort...',
			A1.Concept As Category2, 
			OGD=IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0) ,
			EUS=IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0) ,
			ERC=IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0) ,
			HPB=IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0) ,
			COL=IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0) ,
			SIG=IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0) ,
			PRO=IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0) ,
			OGDP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(OGD),1.)<>0 Then IsNull(Sum(OGD),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			EUSP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(EUS),1.)<>0 Then IsNull(Sum(EUS),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			ERCP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(ERC),1.)<>0 Then IsNull(Sum(ERC),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			HPBP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(HPB),1.)<>0 Then IsNull(Sum(HPB),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			COLP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(COL),1.)<>0 Then IsNull(Sum(COL),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			SIGP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(SIG),1.)<>0 Then IsNull(Sum(SIG),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0)),
			PROP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(PRO),1.)<>0 Then IsNull(Sum(PRO),1.) Else 1.0 End From #GRSB05ATOT Where ConsultantID=0))
		From v_rep_Comfort Comf, #aux A1
		Where Comf.PatDiscomfortId=A1.ID And A1.CategoryID=1
		Group By A1.Concept, A1.ID, Comf.PatDiscomfortId
	End
	Else
	Begin
		Insert Into #GRSB05A (ReportID, Consultant, ConsultantID, CategoryID, ID, Category1, Category2, OGD, EUS, ERC, HPB, COL, SIG, PRO, OGDP, EUSP, ERCP, HPBP, COLP, SIGP, PROP)
		Select 
			C.ReportID,
			C.Consultant,
			ConsultantID=C.ReportID,
			CategoryID=1,
			ID=Comf.NurseAssPatientComfortId,
			Category1='Nurse assessment of patient comfort...',
			A1.Concept As Category2, 
			OGD=IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0) ,
			EUS=IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0) ,
			ERC=IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0) ,
			HPB=IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0) ,
			COL=IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0) ,
			SIG=IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0) ,
			PRO=IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0) ,
			OGDP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(OGD),1.)<>0 Then IsNull(Sum(OGD),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			EUSP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(EUS),1.)<>0 Then IsNull(Sum(EUS),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			ERCP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(ERC),1.)<>0 Then IsNull(Sum(ERC),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			HPBP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(HPB),1.)<>0 Then IsNull(Sum(HPB),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			COLP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(COL),1.)<>0 Then IsNull(Sum(COL),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			SIGP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(SIG),1.)<>0 Then IsNull(Sum(SIG),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			PROP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(PRO),1.)<>0 Then IsNull(Sum(PRO),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID))
		From v_rep_Comfort Comf, #aux A1, v_rep_Consultants C, ERS_ReportConsultants RC
		Where Comf.NurseAssPatientComfortId=A1.ID And A1.CategoryID=1
			And
			C.ReportID=RC.ConsultantID And
			((Comf.Endoscopist1=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Endoscopist2=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.ListConsultant=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Assistant1=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Assistant2=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Nurse1=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Nurse2=C.ConsultantID And Comf.Release=C.Release))
			And (Comf.CreatedOn>=@FromDate And Comf.CreatedOn<=@ToDate
				OR 1 = (CASE WHEN @WholeDB = 1 THEN 1 ELSE 0 END))
		Group By C.Consultant, C.ReportID, A1.ID, Comf.NurseAssPatientComfortId, A1.Concept
		Union
		Select 
			C.ReportID,
			C.Consultant,
			ConsultantID=C.ReportID,
			CategoryID=2,
			ID=Comf.NurseAssPatientSedationId,
			Category1='Nurse assessment of patient sedation...',
			A1.Concept As Category2, 
			OGD=IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0) ,
			EUS=IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0) ,
			ERC=IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0) ,
			HPB=IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0) ,
			COL=IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0) ,
			SIG=IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0) ,
			PRO=IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0) ,
			OGDP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(OGD),1.)<>0 Then IsNull(Sum(OGD),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			EUSP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(EUS),1.)<>0 Then IsNull(Sum(EUS),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			ERCP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(ERC),1.)<>0 Then IsNull(Sum(ERC),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			HPBP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(HPB),1.)<>0 Then IsNull(Sum(HPB),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			COLP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(COL),1.)<>0 Then IsNull(Sum(COL),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			SIGP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(SIG),1.)<>0 Then IsNull(Sum(SIG),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			PROP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(PRO),1.)<>0 Then IsNull(Sum(PRO),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID))
		From v_rep_Comfort Comf, #aux A1, v_rep_Consultants C, ERS_ReportConsultants RC
		Where Comf.NurseAssPatientSedationId=A1.ID And A1.CategoryID=2
			And
			C.ReportID=RC.ConsultantID And
			((Comf.Endoscopist1=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Endoscopist2=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.ListConsultant=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Assistant1=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Assistant2=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Nurse1=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Nurse2=C.ConsultantID And Comf.Release=C.Release))
			And (Comf.CreatedOn>=@FromDate And Comf.CreatedOn<=@ToDate
				OR 1 = (CASE WHEN @WholeDB = 1 THEN 1 ELSE 0 END))
		Group By C.Consultant, C.ReportID, A1.ID, Comf.NurseAssPatientSedationId, A1.Concept
		Union
		Select 
			C.ReportID,
			C.Consultant,
			ConsultantID=C.ReportID,
			CategoryID=3,
			ID=Comf.PatDiscomfortId,
			Category1='Patient assessment of comfort...',
			A1.Concept As Category2, 
			OGD=IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0) ,
			EUS=IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0) ,
			ERC=IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0) ,
			HPB=IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0) ,
			COL=IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0) ,
			SIG=IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0) ,
			PRO=IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0) ,
			OGDP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='OGD' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(OGD),1.)<>0 Then IsNull(Sum(OGD),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			EUSP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='EUS' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(EUS),1.)<>0 Then IsNull(Sum(EUS),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			ERCP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='ERC' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(ERC),1.)<>0 Then IsNull(Sum(ERC),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			HPBP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='HPB' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(HPB),1.)<>0 Then IsNull(Sum(HPB),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			COLP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='COL' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(COL),1.)<>0 Then IsNull(Sum(COL),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			SIGP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='SIG' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(SIG),1.)<>0 Then IsNull(Sum(SIG),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID)),
			PROP=Convert(Numeric(17,4),IsNull(Sum(Case When Comf.ProcedureType='PRO' Then 1 Else 0 End),.0)/(Select Case When IsNull(Avg(PRO),1.)<>0 Then IsNull(Sum(PRO),1.) Else 1.0 End From #GRSB05ATOT T Where T.ConsultantID=C.ReportID))
		From v_rep_Comfort Comf, #aux A1, v_rep_Consultants C, ERS_ReportConsultants RC
		Where Comf.PatDiscomfortId=A1.ID And A1.CategoryID=3
			And
			C.ReportID=RC.ConsultantID And
			((Comf.Endoscopist1=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Endoscopist2=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.ListConsultant=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Assistant1=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Assistant2=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Nurse1=C.ConsultantID And Comf.Release=C.Release) Or
			(Comf.Nurse2=C.ConsultantID And Comf.Release=C.Release))
			And (Comf.CreatedOn>=@FromDate And Comf.CreatedOn<=@ToDate
				OR 1 = (CASE WHEN @WholeDB = 1 THEN 1 ELSE 0 END))
		Group By C.Consultant, C.ReportID, A1.ID, Comf.PatDiscomfortId, A1.Concept
	End
	If @UnitAsAWhole=1
	Begin
		Insert Into #GRSB05AEND (ReportID, Consultant, CategoryID, ID, Category1, Category2, OGD, EUS, ERC, HPB, COL, SIG, PRO, OGDP, EUSP, ERCP, HPBP, COLP, SIGP, PROP )
		Select ReportID=0, Consultant='Endoscopy unit as a Whole', CategoryID, ID, 
		Category1=Case CategoryID 
			When 1 Then 'Nurse assessment of patient comfort...'
			When 2 then 'Nurse assessment of patient sedation...'
			When 3 Then 'Patient assessment of comfort...' Else '' End, Category2=Concept, OGD=0, EUS=0, ERC=0, HPB=0, COL=0, SIG=0, PRO=0, OGDP=0, EUSP=0, ERCP=0, HPBP=0, COLP=0, SIGP=0, PROP=0 From #aux
	End
	Else
	begin
		Insert Into #GRSB05AEND (ReportID, Consultant, CategoryID, ID, Category1, Category2, OGD, EUS, ERC, HPB, COL, SIG, PRO, OGDP, EUSP, ERCP, HPBP, COLP, SIGP, PROP )
		Select 
			C.ReportID,
			C.Consultant,
			CategoryID=A1.CategoryID,
			ID=A1.ID,
					Category1=Case CategoryID 
			When 1 Then 'Nurse assessment of patient comfort...'
			When 2 then 'Nurse assessment of patient sedation...'
			When 3 Then 'Patient assessment of comfort...' Else '' End, 
			A1.Concept As Category2, 
			OGD=0, EUS=0, ERC=0, HPB=0, COL=0, SIG=0, PRO=0, OGDP=0, EUSP=0, ERCP=0, HPBP=0, COLP=0, SIGP=0, PROP=0
		From #aux A1, v_rep_Consultants C, ERS_ReportConsultants RC
		Where C.ReportID=RC.ConsultantID 
	End
	Update #GRSB05AEND Set OGD=A.OGD, EUS=A.EUS, ERC=A.ERC, HPB=A.HPB, COL=A.COL, SIG=A.SIG, PRO=A.PRO, OGDP=A.OGDP, EUSP=A.EUSP, ERCP=A.ERCP, HPBP=A.HPBP, COLP=A.COLP, SIGP=A.SIGP, PROP=A.PROP 
	From #GRSB05A A, #GRSB05AEND B Where B.ReportID=A.ReportID And B.CategoryID=A.CategoryID And B.ID=A.ID
	Select FromDate=@FromDate, ToDate=@ToDate,* From #GRSB05AEND Order By ReportID, CategoryID, ID
	Drop Table #aux
	Drop table #GRSB05A
	Drop table #GRSB05AEND
	Drop table #GRSB05ATOT
End
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSA05C', 'S';
GO

Create Proc [dbo].[sp_rep_GRSA05C] @UserID INT=NULL As
Begin
	SET NOCOUNT ON
	Select C.ConsultantName As Consultant, P.Forename, P.Surname, P.Gender, P.DOB, P.CNN, PR.CreatedOn
	, QA.NursesAssPatComfortScore As PatDiscomfort, PA.NurseAssPatSedationScore As NurseAssPatSedation, PA.NurseAssPatSedation As PatientAssComfort
	, PT.ProcedureType
	, Case When PR.AppId='E' Then 'ERS'Else 'UGI' End As Release
	From fw_QA QA, fw_Procedures PR, fw_Patients P, fw_ProceduresConsultants PC, fw_Consultants C, fw_ReportConsultants RC , fw_NurseAssPatSedationScore PA, fw_ProceduresTypes PT
	Where PR.ProcedureId=QA.ProcedureId And P.PatientId=PR.PatientId And PR.ProcedureId=PC.ProcedureId And PC.ConsultantTypeId=1 And PA.NurseAssPatSedationScore=QA.PatientsSedationScore
	And PC.ConsultantId=C.ConsultantId And C.ConsultantId=RC.ConsultantId And RC.UserId=IsNull(@UserID,0)
	And QA.NursesAssPatComfortScore>4 And PR.ProcedureTypeId=PT.ProcedureTypeId

End
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'v_rep_GRSB01', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[v_rep_GRSB01] As
Select p.PatientId
	, P.[HospitalNumber] As CNN, P.Forename1, P.Surname
    , CP.Procedureid As ProcedureId
    , CL.SiteId As SiteId
	, R.Region As Region
	, IsNull(CP.Endoscopist1,0) As Endoscopist1
	, IsNull(CP.ListConsultant,0) As Endoscopist2
	, (Convert(int,CP.CreatedOn)-Convert(int,P.[Dateofbirth]))/365 As Age
	, Convert(Date,CP.CreatedOn) As CreatedOn
	, IsNull(CL.[Sessile],0) As [Sessile]
	, IsNull(CL.[SessileQuantity],0) As [SessileQuantity]
	, IsNull(CL.[SessileLargest],0) As [SessileLargest]
	, IsNull(CL.[SessileExcised],0) As [SessileExcised]
	, IsNull(CL.[SessileRetrieved],0) As [SessileRetrieved]
	, IsNull(CL.[SessileToLabs],0) As [SessileToLabs]
	, IsNull(CL.[Pedunculated],0) As [Pedunculated], IsNull(CL.[PedunculatedQuantity],0) As [PedunculatedQuantity], IsNull(CL.[PedunculatedLargest],0) As [PedunculatedLargest], IsNull(CL.[PedunculatedExcised],0) As [PedunculatedExcised], IsNull(CL.[PedunculatedRetrieved],0) As [PedunculatedRetrieved], IsNull(CL.[PedunculatedToLabs],0) As [PedunculatedToLabs]
	, IsNull(CL.[Pseudopolyps],0) As [Pseudopolyps], IsNull(CL.[PseudopolypsQuantity],0) As [PseudopolypsQuantity], IsNull(CL.[PseudopolypsLargest],0) As [PseudopolypsLargest], IsNull(CL.[PseudopolypsExcised],0) As [PseudopolypsExcised], IsNull(CL.[PseudopolypsRetrieved],0) As [PseudopolypsRetrieved], IsNull(CL.[PseudopolypsToLabs],0) As [PseudopolypsToLabs]
	, CP.ProcedureType
	, ''ERS'' As Release 
From ERS_ColonAbnoLesions CL, ERS_Sites CS, ERS_Procedures CP, ERS_VW_Patients P, ERS_Regions R
	Where CS.SiteId=CL.SiteId And CS.ProcedureId=CP.ProcedureId And CP.PatientId=P.[PatientID] And CP.ProcedureType=R.ProcedureType And CS.RegionId=R.RegionId
Union All
SELECT Convert(INT,SubString(CL.[Patient No],7,6)) As PatientId
	, P.[HospitalNumber] As CNN, P.Forename1, P.Surname
    , CL.[Episode No] As ProcedureId
    , CL.[Site No] As SiteId
	, CS.[Region text] As Region
	, IsNull(Convert(Int, SubString(CP.Endoscopist2,7,6)),0) As Endoscopist1, IsNull(Convert(Int,SubString(CP.Assistant1,7,6)),0) As Endoscopist2
	, E.[Age at procedure] As Age, Convert(Date,E.[Episode date]) As CreatedOn
    ,  Case IsNull(CL.[Sessile],0) When -1 Then 1 Else 0 End As [Sessile], IsNull(CL.[Sessile quantity],0) As [SessileQuantity], IsNull(CL.[Sessile largest],0) As [SessileLargest], IsNull(CL.[Sessile excised],0) As [SessileExcised], IsNull(CL.[Sessile retrieved],0) As [SessileRetrieved], IsNull(CL.[Sessile to labs],0) As [SessileToLabs]
    , Case IsNull(CL.[Predunculated],0) When -1 Then 1 Else 0 End As [Pedunculated], IsNull(CL.[Predunculated quantity],0) As [PedunculatedQuantity], IsNull(CL.[Predunculated largest],0) As [PedunculatedLargest], IsNull(CL.[Predunculated excised],0) As [PedunculatedExcised], CL.[Predunculated retrieved], CL.[Predunculated to labs]
    , Case IsNull(CL.[Pseudopolyps],0) When -1 Then 1 Else 0 End As [Pseudopolyps], IsNull(CL.[Pseudopolyps quantity],0) As [PseudopolypsQuantity], IsNull(CL.[Pseudopolyps largest],0) As [PseudopolypsLargest], IsNull(CL.[Pseudopolyps excised],0) As [PseudopolypsExcised], IsNull(CL.[Pseudopolyps retrieved],0) As [PseudopolypsRetrieved], IsNull(CL.[Pseudopolyps to labs],0) As [PseudopolypsToLabs]
    , CL.[Procedure type]+3 As ProcedureType
	, ''UGI'' As Release
  FROM [dbo].[AColon Lesions] CL, [Episode] E, [Colon Procedure] CP, [ERS_VW_Patients] P, [Colon Sites] CS
  Where CL.[Episode No]=E.[Episode No] And CL.[Patient No]=E.[Patient No]
  And CP.[Episode No]=E.[Episode No] And CP.[Patient No]=E.[Patient No]
  And Convert(Int,SubString(E.[Patient No],7,6))=P.[UGIPatientId]
  And CS.[Patient No]=CL.[Patient No] And CS.[Episode No]=CL.[Episode No] And CS.[Site No]=CL.[Site No]
  '
END
ELSE
BEGIN
SET @sql = '
Create View [dbo].[v_rep_GRSB01] As
Select p.PatientId
	, P.[HospitalNumber] As CNN, P.Forename1, P.Surname
    , CP.Procedureid As ProcedureId
    , CL.SiteId As SiteId
	, R.Region As Region
	, IsNull(CP.Endoscopist1,0) As Endoscopist1
	, IsNull(CP.ListConsultant,0) As Endoscopist2
	, (Convert(int,CP.CreatedOn)-Convert(int,P.[Dateofbirth]))/365 As Age
	, Convert(Date,CP.CreatedOn) As CreatedOn
	, IsNull(CL.[Sessile],0) As [Sessile]
	, IsNull(CL.[SessileQuantity],0) As [SessileQuantity]
	, IsNull(CL.[SessileLargest],0) As [SessileLargest]
	, IsNull(CL.[SessileExcised],0) As [SessileExcised]
	, IsNull(CL.[SessileRetrieved],0) As [SessileRetrieved]
	, IsNull(CL.[SessileToLabs],0) As [SessileToLabs]
	, IsNull(CL.[Pedunculated],0) As [Pedunculated], IsNull(CL.[PedunculatedQuantity],0) As [PedunculatedQuantity], IsNull(CL.[PedunculatedLargest],0) As [PedunculatedLargest], IsNull(CL.[PedunculatedExcised],0) As [PedunculatedExcised], IsNull(CL.[PedunculatedRetrieved],0) As [PedunculatedRetrieved], IsNull(CL.[PedunculatedToLabs],0) As [PedunculatedToLabs]
	, IsNull(CL.[Pseudopolyps],0) As [Pseudopolyps], IsNull(CL.[PseudopolypsQuantity],0) As [PseudopolypsQuantity], IsNull(CL.[PseudopolypsLargest],0) As [PseudopolypsLargest], IsNull(CL.[PseudopolypsExcised],0) As [PseudopolypsExcised], IsNull(CL.[PseudopolypsRetrieved],0) As [PseudopolypsRetrieved], IsNull(CL.[PseudopolypsToLabs],0) As [PseudopolypsToLabs]
	, CP.ProcedureType
	, ''ERS'' As Release 
From ERS_ColonAbnoLesions CL, ERS_Sites CS, ERS_Procedures CP, ERS_VW_Patients P, ERS_Regions R
	Where CS.SiteId=CL.SiteId And CS.ProcedureId=CP.ProcedureId And CP.PatientId=P.[PatientID] And CP.ProcedureType=R.ProcedureType And CS.RegionId=R.RegionId
  '
END

EXEC sp_executesql @sql
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'v_rep_GRSB02', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[v_rep_GRSB02] As
		SELECT 
			[Consultant/Operators].[Consultant/operator]
			, Patient.Surname
			,[ERCP Procedure].[Patient No]
			, [ERCP Procedure].[Episode No]
			, Episode.[Age at procedure]
			, Episode.[Episode date]
			, [ERCP Procedure].Endoscopist2
			, Patient.Forename1--, Patient.[Case note no], Patient.Surname,Patient.[Date of birth]
			, (Select Top 1 S.Region From [ERCP Sites] S, [ERCP Therapeutic] Where [ERCP Therapeutic].[Episode No]=S.[Episode No] And [ERCP Therapeutic].[Patient No]=S.[Patient No] And [ERCP Therapeutic].[Site No]=S.[Site No] Order By 1 Desc) As Region
			, (SELECT [Via major to bile duct] FROM [ERCP Visualisation] V Where [ERCP Indications].[Episode No]=V.[Episode No] And [ERCP Indications].[Patient No]=V.[Patient No]) As [Via major to bile duct]
			, (Select Top 1 T.Papillotomy From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As Papillotomy
			, (Select Top 1 T.[Pan Orifice Sphincterotomy] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Pan Orifice Sphincterotomy]
			, (Select Top 1 T.[Region No] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Region No]
			, (Select Top 1 T.[Stent removal] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Stent removal]
			, (Select Top 1 T.[Stent insertion] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Stent insertion]
			, (Select Top 1 T.[Correct stent placement] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Correct stent placement]
			, (Select Top 1 T.[Nasopancreatic Drain] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Nasopancreatic Drain]
			, (Select Top 1 T.[Endoscopic Cyst Puncture] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Endoscopic Cyst Puncture]
			, (Select Top 1 T.[Rendezvous procedure] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Rendezvous procedure]
			, (Select Top 1 T.[Stone removal] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Stone removal]
			, (Select Top 1 T.[Extraction outcome] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Extraction outcome]
			, (Select Top 1 T.[Inadequate sphincterotomy] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Inadequate sphincterotomy]
			, (Select Top 1 T.[Quantity of stones] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Quantity of stones]
			, (Select Top 1 T.[Impacted stones] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Impacted stones]
			, (Select Top 1 T.[Other reason] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Other reason]
			, (Select Top 1 T.[Balloon Trawl] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Balloon Trawl]
			, (Select Top 1 T.[Balloon Dilation] From [ERCP Therapeutic] T Where [ERCP Indications].[Episode No]=T.[Episode No] And [ERCP Indications].[Patient No]=T.[Patient No] Order By 1 Desc) As [Balloon Dilation]
			, [ERCP Indications].[Procs papill/sphincterotomy]
			, [ERCP Indications].[Procs stent removal]
			, [ERCP Indications].[Procs stent insertion]
			, [ERCP Indications].[Procs stent replacement]
			, [ERCP Indications].[Procs naso drains]
			, [ERCP Indications].[Procs cyst puncture]
			, [ERCP Indications].[Procs rendezvous]
			, [ERCP Indications].[Procs stricture dilatation]
			
			, [ERCP Indications].[Procs stone removal]
			, Case When [ERCP Indications].[Procs papill/sphincterotomy]=-1 Then 2 Else 0 End As iPapillo
			, Case When [ERCP Indications].[Procs stent removal]=-1 Then 2 Else 0 End As iStentRemoval
			, Case When [ERCP Indications].[Procs stent insertion]=-1 Then 3 Else 0 End As iStentInsert
			, Case When [ERCP Indications].[Procs stent replacement]=-1 Then 3 Else 0 End As iStentReplace
			, Case When [ERCP Indications].[Procs naso drains]=-1 Then 2 Else 0 End As iNaso
			, Case When [ERCP Indications].[Procs cyst puncture]=-1 Then 2 Else 0 End As iCyst
			, Case When [ERCP Indications].[Procs rendezvous]=-1 Then 2 Else 0 End As iRendezvous
			, Case When [ERCP Indications].[Procs stricture dilatation]=-1 Then 3 Else 0 End As iStricture
			, Case When [ERCP Indications].[Procs stone removal]=-1 Then 3 Else 0 End As iStoneRemoval
			, [ERCP Indications].[Procs cannulate And opacify]
			, [Consultant/Operators].[Consultant/operator ID]  
		FROM [Consultant/Operators] AS [Consultant/Operators_1] 
			RIGHT JOIN ([Consultant/Operators] 
			RIGHT JOIN  ([ERCP Indications] 
			RIGHT JOIN (ERS_VW_Patients Patient INNER JOIN ([ERCP Procedure] INNER JOIN Episode ON  ([ERCP Procedure].[Episode No] = Episode.[Episode No]) AND ([ERCP Procedure].[Patient No] = Episode.[Patient No]))  ON Patient.[ComboID] = [ERCP Procedure].[Patient No]) ON ([ERCP Indications].[Patient No] =  [ERCP Procedure].[Patient No]) AND ([ERCP Indications].[Episode No] = [ERCP Procedure].[Episode No]))  ON [Consultant/Operators].[Consultant/operator ID] = [ERCP Procedure].Endoscopist2) ON  [Consultant/Operators_1].[Consultant/operator ID] = [ERCP Procedure].Assistant1 
		WHERE [ERCP Procedure].[Patient No]+''.''+Convert(varchar(10),[ERCP Procedure].[Episode No]) In (Select [UGIPatientId]+''.''+Convert(varchar(10),[Episode No]) From [ERCP Sites] )

'
END

EXEC sp_executesql @sql
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'v_rep_GRS_Medication', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[v_rep_GRS_Medication] As
Select 
	P.[HospitalNumber] As [CNN],
	P.Surname+'', ''+P.Forename1 As [PatientName],
	P.[PatientId] As PatientID,
	Episode.[Episode No] As ProcedureId,
	Convert(Date,Episode.[Episode date]) As [CreatedOn],
	Episode.[Age at procedure] As [Age],
	Convert(INT,SubString(Procs.Endoscopist2,7,6)) As Endoscopist1,
	Convert(INT,SubString(Procs.Endoscopist2,7,6)) As Endoscopist2,
	Convert(INT,SubString(Procs.Assistant1,7,6)) As Assistant1,
	Convert(INT,SubString(Procs.Assistant2,7,6)) As Assistant2,
	Case When Procs.[Consultant No]<0 Then 0 Else IsNull(Procs.[Consultant No],0) End As [ListConsultant],
	Convert(INT,SubString(Procs.Nurse1,7,6)) As Nurse1,
	Convert(INT,SubString(Procs.Nurse2,7,6)) As Nurse2,
	Case When Episode.[Age at procedure]<70 Then ''LT70'' Else ''GE70'' End As [AgeLimit], 
	Drugs.[Drug name] As [DrugName], 
	Drugs.[Delivery method] As [DeliveryMethod],
	Premed.[Dose],
	Drugs.Units As [Units], 
	Case Procs.[Procedure type]
	When 0 Then ''COL''
	When 1 Then ''SIG''
	When 2 Then ''PRO''
	Else ''???'' End As ProcType,
	''UGI'' As Release
From 
	ERS_VW_Patients P
	, [dbo].[Episode] Episode
	, [Colon Procedure] Procs
	, [dbo].[Patient Premedication] Premed
	, [dbo].[Drug list] Drugs
Where P.[UGIPatientId]=Convert(INT,SubString(Episode.[Patient No],7,6))
	And Procs.[Episode No]=Episode.[Episode No] And Convert(INT,SubString(Procs.[Patient No],7,6))=P.[UGIPatientId] 
	And Procs.[Episode No]=Premed.[Episode No] And Procs.[Patient No]=Premed.[Patient No]
	And Premed.[Drug No]=Drugs.[Drug no]
	And Procs.[Procedure type]=1
Union All
Select 
	P.[HospitalNumber] As [CNN],
	P.Surname+'', ''+P.Forename1 As [PatientName],
	P.[PatientId] As PatientID,
	Episode.[Episode No] As ProcedureId,
	Convert(Date,Episode.[Episode date]) As [CreatedOn],
	Episode.[Age at procedure] As [Age],
	Convert(INT,SubString(Procs.Endoscopist2,7,6)) As Endoscopist1,
	Convert(INT,SubString(Procs.Endoscopist2,7,6)) As Endoscopist2,
	Convert(INT,SubString(Procs.Assistant1,7,6)) As Assistant1,
	Convert(INT,SubString(Procs.Assistant2,7,6)) As Assistant2,
	Case When Procs.[Consultant No]<0 Then 0 Else IsNull(Procs.[Consultant No],0) End As [ListConsultant],
	Convert(INT,SubString(Procs.Nurse1,7,6)) As Nurse1,
	Convert(INT,SubString(Procs.Nurse2,7,6)) As Nurse2,
	Case When Episode.[Age at procedure]<70 Then ''LT70'' Else ''GE70'' End As [AgeLimit], 
	Drugs.[Drug name] As [DrugName], 
	Drugs.[Delivery method] As [DeliveryMethod],
	Premed.[Dose],
	Drugs.Units As [Units], 
	Case Procs.[Procedure type]
	When 0 Then ''COL''
	When 1 Then ''SIG''
	When 2 Then ''PRO''
	Else ''???'' End As ProcType,
	''UGI'' As Release
From 
	ERS_VW_Patients P
	, [dbo].[Episode] Episode
	, [Colon Procedure] Procs
	, [dbo].[Patient Premedication] Premed
	, [dbo].[Drug list] Drugs
Where P.[PatientId]=Convert(INT,SubString(Episode.[Patient No],7,6))
	And Procs.[Episode No]=Episode.[Episode No] And Convert(INT,SubString(Procs.[Patient No],7,6))=P.[PatientId] 
	And Procs.[Episode No]=Premed.[Episode No] And Procs.[Patient No]=Premed.[Patient No]
	And Premed.[Drug No]=Drugs.[Drug no]
	And Procs.[Procedure type]=2
Union All
Select 
	P.[HospitalNumber] As [CNN],
	P.Surname+'', ''+P.Forename1 As [PatientName],
	P.[PatientId] As PatientID,
	Episode.[Episode No] As ProcedureId,
	Convert(Date,Episode.[Episode date]) As [CreatedOn],
	Episode.[Age at procedure] As [Age],
	Convert(INT,SubString(Procs.Endoscopist2,7,6)) As Endoscopist1,
	Convert(INT,SubString(Procs.Endoscopist2,7,6)) As Endoscopist2,
	Convert(INT,SubString(Procs.Assistant1,7,6)) As Assistant1,
	Convert(INT,SubString(Procs.Assistant2,7,6)) As Assistant2,
	Case When Procs.[Consultant No]<0 Then 0 Else IsNull(Procs.[Consultant No],0) End As [ListConsultant],
	Convert(INT,SubString(Procs.Nurse1,7,6)) As Nurse1,
	Convert(INT,SubString(Procs.Nurse2,7,6)) As Nurse2,
	Case When Episode.[Age at procedure]<70 Then ''LT70'' Else ''GE70'' End As [AgeLimit], 
	Drugs.[Drug name] As [DrugName], 
	Drugs.[Delivery method] As [DeliveryMethod],
	Premed.[Dose],
	Drugs.Units As [Units], 
	Case Procs.[Procedure type]
	When 0 Then ''COL''
	When 1 Then ''SIG''
	When 2 Then ''PRO''
	Else ''???'' End As ProcType,
	''UGI'' As Release
From 
	ERS_VW_Patients P
	, [dbo].[Episode] Episode
	, [Colon Procedure] Procs
	, [dbo].[Patient Premedication] Premed
	, [dbo].[Drug list] Drugs
Where P.[UGIPatientId]=Convert(INT,SubString(Episode.[Patient No],7,6))
	And Procs.[Episode No]=Episode.[Episode No] And Convert(INT,SubString(Procs.[Patient No],7,6))=P.[UGIPatientId] 
	And Procs.[Episode No]=Premed.[Episode No] And Procs.[Patient No]=Premed.[Patient No]
	And Premed.[Drug No]=Drugs.[Drug no]
	And Procs.[Procedure type]=0
Union All
Select 
	P.[HospitalNumber] As [CNN],
	P.Surname+'', ''+P.Forename1 As [PatientName],
	P.[PatientId] As PatientID,
	Episode.[Episode No] As ProcedureId,
	Convert(Date,Episode.[Episode date]) As [CreatedOn],
	Episode.[Age at procedure] As [Age],
	Convert(INT,SubString(Procs.Endoscopist2,7,6)) As Endoscopist1,
	Convert(INT,SubString(Procs.Endoscopist2,7,6)) As Endoscopist2,
	Convert(INT,SubString(Procs.Assistant1,7,6)) As Assistant1,
	Convert(INT,SubString(Procs.Assistant2,7,6)) As Assistant2,
	0 As ListConsultant,
	Convert(INT,SubString(Procs.Nurse1,7,6)) As Nurse1,
	Convert(INT,SubString(Procs.Nurse2,7,6)) As Nurse2,
	Case When Episode.[Age at procedure]<70 Then ''LT70'' Else ''GE70'' End As [AgeLimit], 
	Drugs.[Drug name] As [DrugName], 
	Drugs.[Delivery method] As [DeliveryMethod],
	Premed.[Dose],
	Drugs.Units As [Units], 
	''ERC'' As ProcType,
	''UGI'' As Release
From 
	ERS_VW_Patients P
	, [dbo].[Episode] Episode
	, [ERCP Procedure] Procs
	, [dbo].[Patient Premedication] Premed
	, [dbo].[Drug list] Drugs
Where P.[UGIPatientId]=Convert(INT,SubString(Episode.[Patient No],7,6))
	And Procs.[Episode No]=Episode.[Episode No] And Convert(INT,SubString(Procs.[Patient No],7,6))=P.[UGIPatientId] 
	And Procs.[Episode No]=Premed.[Episode No] And Procs.[Patient No]=Premed.[Patient No]
	And Premed.[Drug No]=Drugs.[Drug no]
Union All
Select 
	Patients.[HospitalNumber] As CNN,
	Patients.[Surname]+'', ''+Patients.[Forename1] As PatientName,
	Patients.[PatientId] As [PatientId],
	Procs.[Episode No] As [ProcedureId],
	Convert(Date,Procs.[Procedure date]) As CreatedOn,
	Episode.[Age at procedure] As [Age],
	Convert(int,SubString(IsNull(Procs.Endoscopist1,''000000''),7,6)) As Endoscopist1,
	Convert(int,SubString(IsNull(Procs.Endoscopist2,''000000''),7,6)) As Endoscopist2,
	Convert(int,SubString(IsNull(Procs.Endoscopist1,''000000''),7,6)) As Assistant1,
	Convert(int,SubString(IsNull(Procs.Assistant2,''000000''),7,6)) As Assistant2,
	Case When Procs.[Consultant No]<0 Then 0 Else IsNull(Procs.[Consultant No],0) End As [ListConsultant],
	Convert(int,SubString(IsNull(Procs.Nurse1,''000000''),7,6)) As Nurse1,
	Convert(int,SubString(IsNull(Procs.Nurse2,''000000''),7,6)) As Nurse2,
	Case When Episode.[Age at procedure]<70 Then ''LT70'' Else ''GE70'' End As [AgeLimit], 
	Drugs.[Drug name] As [DrugName], 
	Drugs.[Delivery method] As [DeliveryMethod],
	Premed.[Dose],
	Drugs.Units As [Units], 
	''OGD'' As ProcType,
	''UGI'' As Release
From [dbo].[Patient Premedication] Premed
	, [dbo].[Upper GI Procedure] Procs
	, [dbo].[ERS_VW_Patients] Patients
	, [dbo].[Episode] Episode
	, [dbo].[Drug list] Drugs
Where 
	Patients.[PatientId]=convert(int,SubString(Procs.[Patient No],7,6))
	And Procs.[Episode No]=Episode.[Episode No] And Procs.[Patient No]=Episode.[Patient No]
	And Premed.[Episode No]=Episode.[Episode No] And Premed.[Patient No]=Episode.[Patient No]
	And Premed.[Drug No]=Drugs.[Drug no]
	And Procs.[Procedure date] Is Not Null
	And SubString(Episode.[Status],1,1)=1
Union All
Select 
	P.[HospitalNumber] As [CNN],
	P.Surname+'', ''+P.Forename1 As [PatientName],
	P.[PatientId] As PatientID,
	Episode.[Episode No] As ProcedureId,
	Convert(Date,Episode.[Episode date]) As [CreatedOn],
	Episode.[Age at procedure] As [Age],
	Convert(INT,SubString(Procs.Endoscopist2,7,6)) As Endoscopist1,
	Convert(INT,SubString(Procs.Endoscopist2,7,6)) As Endoscopist2,
	Convert(INT,SubString(Procs.Assistant1,7,6)) As Assistant1,
	Convert(INT,SubString(Procs.Assistant2,7,6)) As Assistant2,
	0 As ListConsultant,
	Convert(INT,SubString(Procs.Nurse1,7,6)) As Nurse1,
	Convert(INT,SubString(Procs.Nurse2,7,6)) As Nurse2,
	Case When Episode.[Age at procedure]<70 Then ''LT70'' Else ''GE70'' End As [AgeLimit], 
	Drugs.[Drug name] As [DrugName], 
	Drugs.[Delivery method] As [DeliveryMethod],
	Premed.[Dose],
	Drugs.Units As [Units], 
	''ERC'' As ProcType,
	''UGI'' As Release
From 
	ERS_VW_Patients P
	, [dbo].[Episode] Episode
	, [ERCP Procedure] Procs
	, [dbo].[Patient Premedication] Premed
	, [dbo].[Drug list] Drugs
Where P.[UGIPatientId]=Convert(INT,SubString(Episode.[Patient No],7,6))
	And Procs.[Episode No]=Episode.[Episode No] And Convert(INT,SubString(Procs.[Patient No],7,6))=P.[UGIPatientId] 
	And Procs.[Episode No]=Premed.[Episode No] And Procs.[Patient No]=Premed.[Patient No]
	And Premed.[Drug No]=Drugs.[Drug no]'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'v_rep_MedicationArray', 'V';
GO

Create View [dbo].[v_rep_MedicationArray] As
Select 
	C.ConsultantName
	, CONVERT(INT,CONVERT(DATETIME,PR.CreatedOn)-CONVERT(DATETIME,P.DOB))/365 AS Age
	, C.ConsultantID
	, P.CNN
	, P.PatientName
	, PC.ConsultantTypeId
	, PM.DrugName+CASE WHEN ISNULL(DR.DeliveryMethod,'')='' THEN '' ELSE ' ('+DR.DeliveryMethod+') ' END+PM.Units As Drug, PM.Dose
	, PM.DrugName
	, PR.ProcedureId
	, CASE PR.ProcedureTypeId
		WHEN 1 THEN 'OGD' 
		WHEN 2 THEN 'ERC' 
		WHEN 3 THEN 'COL' 
		WHEN 4 THEN 'SIG' 
		WHEN 5 THEN 'PRO' 
		WHEN 6 THEN 'EUS' 
		WHEN 7 THEN 'HPB' 
		ELSE 'XXX' END As ProcType
	, [dbo].[fnDrugsPercentile50](PM.DrugName,PR.ProcedureId) As Median
From fw_Consultants C 
	INNER JOIN fw_ProceduresConsultants PC ON C.ConsultantId=PC.ConsultantId
	INNER JOIN fw_Procedures PR ON PC.ProcedureId=PR.ProcedureId
	INNER JOIN fw_Patients P ON PR.PatientId=P.PatientId
	INNER JOIN fw_Premedication PM ON PR.ProcedureId=PM.ProcedureId
	INNER JOIN fw_Drugs DR ON PM.DrugId=DR.DrugId

GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_PatientMedication', 'V';
GO

Create View [dbo].[fw_PatientMedication] As
Select 
	PR.PatientId
	, PM.DrugName+CASE WHEN ISNULL(DR.DeliveryMethod,'')='' THEN '' ELSE ' ('+DR.DeliveryMethod+') ' END+PM.Units As Drug
	, ROUND(AVG (PM.Dose) OVER (PARTITION BY PR.PatientId, PM.DrugName),2) As AvgDose
	, ROUND(SUM (PM.Dose) OVER (PARTITION BY PR.PatientId, PM.DrugName),2) As SumDose
	, MIN (PM.Dose) OVER (PARTITION BY PR.PatientId, PM.DrugName) As MinDose
	, MAX (PM.Dose) OVER (PARTITION BY PR.PatientId, PM.DrugName) As MaxDose
	, [dbo].[fnPatientsPercentile50](PM.DrugName,PR.PatientId) As Median
	, COUNT (PM.Dose) OVER (PARTITION BY PR.ProcedureId, PM.DrugName) As CountDose
	, PM.DrugName
	, CONVERT(NVARCHAR(20),PR.PatientId)+'.'+PM.DrugName As PatientMedicationId
From fw_Patients P INNER JOIN fw_Procedures PR ON P.PatientId=PR.PatientId
	INNER JOIN fw_Premedication PM ON PR.ProcedureId=PM.ProcedureId
	INNER JOIN fw_Drugs DR ON PM.DrugId=DR.DrugId

GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ProcedureMedication', 'V';
GO

Create View [dbo].[fw_ProcedureMedication] As
Select 
	PR.ProcedureId
	, PM.DrugName+CASE WHEN ISNULL(DR.DeliveryMethod,'')='' THEN '' ELSE ' ('+DR.DeliveryMethod+') ' END+PM.Units As Drug
	, ROUND(AVG (PM.Dose) OVER (PARTITION BY PR.ProcedureId, PM.DrugName),2) As AvgDose
	, ROUND(SUM (PM.Dose) OVER (PARTITION BY PR.ProcedureId, PM.DrugName),2) As SumDose
	, MIN (PM.Dose) OVER (PARTITION BY PR.ProcedureId, PM.DrugName) As MinDose
	, MAX (PM.Dose) OVER (PARTITION BY PR.ProcedureId, PM.DrugName) As MaxDose
	, [dbo].[fnDrugsPercentile50](PM.DrugName,PR.ProcedureId) As Median
	, COUNT (PM.Dose) OVER (PARTITION BY PR.ProcedureId, PM.DrugName) As CountDose
	, PM.DrugName
	,PR.ProcedureId+'.'+PM.DrugName As ProcedureMedicationId
From fw_Procedures PR 
	INNER JOIN fw_Premedication PM ON PR.ProcedureId=PM.ProcedureId
	INNER JOIN fw_Drugs DR ON PM.DrugId=DR.DrugId
GO



/*OJO*/


/* NEDxsd */
If Exists (SELECT name FROM sys.xml_schema_collections Where name='NEDxsd') DROP XML SCHEMA COLLECTION NEDxsd
GO

CREATE XML SCHEMA COLLECTION NEDxsd AS '<?xml version="1.0" encoding="utf-8"?>
<!-- Version 1.14 -->
<xs:schema xmlns="http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd" xmlns:mstns="http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd" xmlns:xs="http://www.w3.org/2001/XMLSchema" targetNamespace="http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd" elementFormDefault="qualified" id="SendBatchMessageFile">
  <!-- Root Element -->
  <xs:element name="hospital.SendBatchMessage">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="session" type="SessionType" minOccurs="1" maxOccurs="unbounded"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
  <!-- Session Element-->
  <xs:complexType name="SessionType">
    <xs:sequence>
      <xs:element name="procedures" type="ProceduresType" minOccurs="1" maxOccurs="1"/>
    </xs:sequence>
    <xs:attribute name="uniqueId" type="xs:string" use="required"/>
    <xs:attribute name="description" type="xs:string" use="required"/>
    <xs:attribute name="date" type="UKDateType" use="required"/>
    <xs:attribute name="time" type="TimeEnum" use="required"/>
    <xs:attribute name="type" type="SessionTypeEnum" use="required"/>
    <xs:attribute name="site" type="xs:string" use="required"/>
  </xs:complexType>
  <xs:complexType name="ProceduresType">
    <xs:choice minOccurs="1" maxOccurs="unbounded">
      <xs:element name="procedure" type="ProcedureType"/>
    </xs:choice>
  </xs:complexType>
  <!-- Procedure Types -->
  <xs:complexType name="ProcedureType">
    <xs:sequence>
      <xs:element name="patient" type="PatientType" minOccurs="1" maxOccurs="1"/>
      <xs:element name="drugs" type="DrugType" minOccurs="1" maxOccurs="1"/>
      <xs:element name="staff.members" type="StaffMembersType" minOccurs="1" maxOccurs="1"/>
      <xs:element name="indications" type="IndicationsType" minOccurs="1" maxOccurs="1"/>
      <xs:element name="limitations" type="LimitationsType" minOccurs="0" maxOccurs="1"/>
      <xs:element name="biopsies" type="BiopsiesType" minOccurs="1" maxOccurs="1"/>
      <xs:element name="diagnoses" type="DiagnosesType" minOccurs="1" maxOccurs="1"/>
      <xs:element name="adverse.events" type="AdverseEventsType" minOccurs="1" maxOccurs="1"/>
    </xs:sequence>
    <xs:attribute name="localProcedureId" type="xs:string" use="required"/>
    <xs:attribute name="previousLocalProcedureId" type="xs:string" use="optional"/>
    <xs:attribute name="procedureName" type="ProcedureNameEnum" use="required"/>
    <xs:attribute name="endoscopistDiscomfort" type="DiscomfortEnum" use="required"/>
    <xs:attribute name="nurseDiscomfort" type="DiscomfortEnum" use="optional"/>
    <xs:attribute name="bowelPrep" type="BowelPrepEnum" use="optional"/>
    <xs:attribute name="extent" type="ExtentTypeEnum" use="required"/>
    <xs:attribute name="entonox" type="YesNoEnum" use="optional"/>
    <xs:attribute name="antibioticGiven" type="YesNoEnum" use="optional"/>
    <xs:attribute name="generalAnaes" type="YesNoEnum" use="optional"/>
    <xs:attribute name="pharyngealAnaes" type="YesNoEnum" use="optional"/>
    <xs:attribute name="polypsDetected" type="xs:int" use="required"/>
    <xs:attribute name="digitalRectalExamination" type="YesNoEnum" use="optional"/>
    <xs:attribute name="magneticEndoscopeImagerUsed" type="YesNoEnum" use="optional"/>
    <xs:attribute name="scopeWithdrawalTime" type="xs:int" use="optional"/>
  </xs:complexType>
  <!-- Staff Types -->
  <xs:complexType name="StaffMembersType">
    <xs:sequence>
      <xs:element name="Staff" type="StaffType" minOccurs="0" maxOccurs="3"/>
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="StaffType">
    <xs:sequence>
      <xs:element name="therapeutics" type="TherapeuticsType" minOccurs="1" maxOccurs="1"/>
    </xs:sequence>
    <xs:attribute name="professionalBodyCode" type="xs:string" use="required"/>
    <xs:attribute name="endoscopistRole" type="EndoscopistRoleTypeEnum" use="required"/>
    <xs:attribute name="procedureRole" type="ProcedureRoleTypeEnum" use="required"/>
    <xs:attribute name="extent" type="ExtentTypeEnum" use="optional"/>
    <xs:attribute name="jManoeuvre" type="YesNoEnum" use="optional"/>
  </xs:complexType>
  <!-- Limitation Element -->
  <xs:complexType name="LimitationsType">
    <xs:sequence>
      <xs:element name="limitation" type="LimitationType" minOccurs="0" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="LimitationType">
    <xs:attribute name="limitation" type="LimitationsEnum" use="required"/>
    <xs:attribute name="comment" type="xs:string" use="optional"/>
  </xs:complexType>
  <!-- Indications Element -->
  <xs:complexType name="IndicationsType">
    <xs:sequence>
      <xs:element name="indication" type="IndicationType" minOccurs="1" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="IndicationType">
    <xs:attribute name="indication" type="IndicationsEnum" use="required"/>
    <xs:attribute name="comment" type="xs:string" use="optional"/>
  </xs:complexType>
  <!-- Diagnoses Element-->
  <xs:complexType name="DiagnosesType">
    <xs:sequence>
      <xs:element name="Diagnose" type="DiagnoseType" minOccurs="1" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="DiagnoseType">
    <xs:attribute name="diagnosis" type="DiagnosisLookupEnum" use="required"/>
    <xs:attribute name="tattooed" type="TattooEnum" use="optional"/>
    <xs:attribute name="site" type="BiopsyEnum" use="optional"/>
    <xs:attribute name="comment" type="xs:string" use="optional"/>
  </xs:complexType>
  <!-- Biopsies Element -->
  <xs:complexType name="BiopsiesType">
    <xs:sequence>
      <xs:element name="Biopsy" type="BiopsyType" minOccurs="0" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="BiopsyType">
    <xs:attribute name="biopsySite" type="BiopsyEnum" use="required"/>
    <xs:attribute name="numberPerformed" type="xs:int" use="required"/>
  </xs:complexType>
  <!-- Therapeutics Element -->
  <xs:complexType name="TherapeuticsType">
    <xs:sequence>
      <xs:element name="therapeutic" type="TherapeuticType" minOccurs="1" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="TherapeuticType">
    <xs:attribute name="type" type="TherapeuticLookupEnum" use="required"/>
    <xs:attribute name="site" type="BiopsyEnum" use="optional"/>
    <xs:attribute name="role" type="ProcedureRoleTypeEnum" use="optional"/>
    <xs:attribute name="polypSize" type="PolypSizeEnum" use="optional"/>
    <xs:attribute name="tattooed" type="TattooEnum" use="optional"/>
    <xs:attribute name="performed" type="xs:int" use="required"/>
    <xs:attribute name="successful" type="xs:int" use="required"/>
    <xs:attribute name="retrieved" type="xs:int" use="optional"/>
    <xs:attribute name="comment" type="xs:string" use="optional"/>
  </xs:complexType>
  <!-- Adverse Events Element -->
  <xs:complexType name="AdverseEventsType">
    <xs:sequence>
      <xs:element name="adverse.event" type="AdverseEventType" minOccurs="1" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="AdverseEventType">
    <xs:attribute name="adverseEvent" type="AdverseEventEnum" use="required"/>
    <xs:attribute name="comment" type="xs:string" use="optional"/>
  </xs:complexType>
  <!-- Patient Element-->
  <xs:complexType name="PatientType">
    <xs:attribute name="gender" type="GenderType" use="required"/>
    <xs:attribute name="age" type="xs:int" use="required"/>
    <xs:attribute name="admissionType" type="AdmissionTypeEnum" use="optional"/>
    <xs:attribute name="urgencyType" type="UrgencyEnum" use="optional"/>
  </xs:complexType>
  <!-- Lookup Types -->
  <!-- Dose Element-->
  <xs:complexType name="DrugType">
    <xs:attribute name="pethidine" type="xs:float" use="required"/>
    <xs:attribute name="midazolam" type="xs:float" use="required"/>
    <xs:attribute name="fentanyl" type="xs:float" use="required"/>
    <xs:attribute name="buscopan" type="xs:float" use="optional"/>
    <xs:attribute name="propofol" type="xs:float" use="optional"/>
    <xs:attribute name="noDrugsAdministered" type="YesNoEnum" use="optional"/>
  </xs:complexType>
  <xs:simpleType name="SessionTypeEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Dedicated Training List"/>
      <xs:enumeration value="Adhoc Training List"/>
      <xs:enumeration value="Service List"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="ExtentTypeEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Stomach"/>
      <xs:enumeration value="Oesophagus"/>
      <xs:enumeration value="Intubation failed"/>
      <xs:enumeration value="D2 - 2nd part of duodenum"/>
      <xs:enumeration value="Duodenal bulb"/>
      <xs:enumeration value="Anastomosis"/>
      <xs:enumeration value="Transverse Colon"/>
      <xs:enumeration value="Terminal ileum"/>
      <xs:enumeration value="Splenic flexure"/>
      <xs:enumeration value="Sigmoid colon"/>
      <xs:enumeration value="Rectum"/>
      <xs:enumeration value="Pouch"/>
      <xs:enumeration value="Neo-terminal ileum"/>
      <xs:enumeration value="Ileo-colon anastomosis"/>
      <xs:enumeration value="Hepatic flexure"/>
      <xs:enumeration value="Descending Colon"/>
      <xs:enumeration value="Caecum"/>
      <xs:enumeration value="Ascending Colon"/>
      <xs:enumeration value="Anus"/>
      <xs:enumeration value="Papilla"/>
      <xs:enumeration value="Pancreatic duct"/>
      <xs:enumeration value="Common bile duct"/>
      <xs:enumeration value="CBD and PD"/>
      <xs:enumeration value="Abandoned"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="LimitationsEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Other"/>
      <xs:enumeration value="Not Limited"/>
      <xs:enumeration value="benign stricture"/>
      <xs:enumeration value="inadequate bowel prep"/>
      <xs:enumeration value="malignant stricture"/>
      <xs:enumeration value="patient discomfort"/>
      <xs:enumeration value="severe colitis"/>
      <xs:enumeration value="unresolved loop"/>
      <xs:enumeration value="clinical intention achieved"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="AdmissionTypeEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Not Specified"/>
      <xs:enumeration value="Inpatient"/>
      <xs:enumeration value="Outpatient"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="UrgencyEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Not Specified"/>
      <xs:enumeration value="Routine"/>
      <xs:enumeration value="Urgent"/>
      <xs:enumeration value="Emergency"/>
      <xs:enumeration value="Surveillance"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="ProcedureRoleTypeEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Independent (no trainer)"/>
      <xs:enumeration value="Was observed"/>
      <xs:enumeration value="Was assisted physically"/>
      <xs:enumeration value="I observed"/>
      <xs:enumeration value="I assisted physically"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="EndoscopistRoleTypeEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Trainer"/>
      <xs:enumeration value="Trainee"/>
      <xs:enumeration value="Independent"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="DiscomfortEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Not Specified"/>
      <xs:enumeration value="Comfortable"/>
      <xs:enumeration value="Minimal"/>
      <xs:enumeration value="Mild"/>
      <xs:enumeration value="Moderate"/>
      <xs:enumeration value="Severe"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="IndicationsEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Other"/>
      <xs:enumeration value="Abdominal pain"/>
      <xs:enumeration value="Abnormality on CT / barium"/>
      <xs:enumeration value="Anaemia"/>
      <xs:enumeration value="Barretts oesophagus"/>
      <xs:enumeration value="Diarrhoea"/>
      <xs:enumeration value="Dyspepsia"/>
      <xs:enumeration value="Dysphagia"/>
      <xs:enumeration value="Haematemesis"/>
      <xs:enumeration value="Heartburn / reflux"/>
      <xs:enumeration value="Melaena"/>
      <xs:enumeration value="Nausea / vomiting"/>
      <xs:enumeration value="Odynophagia"/>
      <xs:enumeration value="PEG change"/>
      <xs:enumeration value="PEG placement"/>
      <xs:enumeration value="PEG removal"/>
      <xs:enumeration value="Positive TTG / EMA"/>
      <xs:enumeration value="Stent change"/>
      <xs:enumeration value="Stent placement"/>
      <xs:enumeration value="Stent removal"/>
      <xs:enumeration value="Follow up of gastric ulcer"/>
      <xs:enumeration value="Varices surveillance / screening"/>
      <xs:enumeration value="Weight loss"/>
      <xs:enumeration value="BCSP"/>
      <xs:enumeration value="Abdominal mass"/>
      <xs:enumeration value="Abnormal sigmoidoscopy"/>
      <xs:enumeration value="Chronic alternating diarrhoea / constipation"/>
      <xs:enumeration value="Colorectal cancer - follow up"/>
      <xs:enumeration value="Constipation - acute"/>
      <xs:enumeration value="Constipation - chronic"/>
      <xs:enumeration value="Defaecation disorder"/>
      <xs:enumeration value="Diarrhoea - acute"/>
      <xs:enumeration value="Diarrhoea - chronic"/>
      <xs:enumeration value="Diarrhoea - chronic with blood"/>
      <xs:enumeration value="FHx of colorectal cancer"/>
      <xs:enumeration value="FOB +''ve"/>
      <xs:enumeration value="IBD assessment / surveillance"/>
      <xs:enumeration value="Polyposis syndrome"/>
      <xs:enumeration value="PR bleeding - altered blood"/>
      <xs:enumeration value="PR bleeding - anorectal"/>
      <xs:enumeration value="Previous / known polyps"/>
      <xs:enumeration value="Tumour assessment"/>
      <xs:enumeration value="Abnormal liver enzymes"/>
      <xs:enumeration value="Acute pancreatitis"/>
      <xs:enumeration value="Ampullary mass"/>
      <xs:enumeration value="Bile duct injury"/>
      <xs:enumeration value="Bile duct leak"/>
      <xs:enumeration value="Cholangitis"/>
      <xs:enumeration value="Chronic pancreatitis"/>
      <xs:enumeration value="Gallbladder mass"/>
      <xs:enumeration value="Gallbladder polyp"/>
      <xs:enumeration value="Hepatobiliary mass"/>
      <xs:enumeration value="Jaundice"/>
      <xs:enumeration value="Pancreatic mass"/>
      <xs:enumeration value="Pancreatic pseudocyst"/>
      <xs:enumeration value="Pancreatobiliary pain"/>
      <xs:enumeration value="Papillary dysfunction"/>
      <xs:enumeration value="Pre lap choledocholithiasis"/>
      <xs:enumeration value="Primary sclerosing cholangitis"/>
      <xs:enumeration value="Purulent cholangitis"/>
      <xs:enumeration value="Stent dysfunction"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="DiagnosisLookupEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Normal"/>
      <xs:enumeration value="Other"/>
      <xs:enumeration value="Anal fissure"/>
      <xs:enumeration value="Angiodysplasia"/>
      <xs:enumeration value="Colitis - ischemic"/>
      <xs:enumeration value="Colitis - pseudomembranous"/>
      <xs:enumeration value="Colitis - unspecified"/>
      <xs:enumeration value="Colorectal cancer"/>
      <xs:enumeration value="Crohn''s - terminal ileum"/>
      <xs:enumeration value="Crohn''s colitis"/>
      <xs:enumeration value="Diverticulosis"/>
      <xs:enumeration value="Fistula"/>
      <xs:enumeration value="Foreign body"/>
      <xs:enumeration value="Haemorrhoids"/>
      <xs:enumeration value="Lipoma"/>
      <xs:enumeration value="Melanosis"/>
      <xs:enumeration value="Parasites"/>
      <xs:enumeration value="Pneumatosis coli"/>
      <xs:enumeration value="Polyp/s"/>
      <xs:enumeration value="Polyposis syndrome"/>
      <xs:enumeration value="Postoperative appearance"/>
      <xs:enumeration value="Proctitis"/>
      <xs:enumeration value="Rectal ulcer"/>
      <xs:enumeration value="Stricture - inflammatory"/>
      <xs:enumeration value="Stricture - malignant"/>
      <xs:enumeration value="Stricture - postoperative"/>
      <xs:enumeration value="Ulcerative colitis"/>
      <xs:enumeration value="Anastomotic stricture"/>
      <xs:enumeration value="Biliary fistula/leak"/>
      <xs:enumeration value="Biliary occlusion"/>
      <xs:enumeration value="Biliary stent occlusion"/>
      <xs:enumeration value="Biliary stone(s)"/>
      <xs:enumeration value="Biliary stricture"/>
      <xs:enumeration value="Carolis disease"/>
      <xs:enumeration value="Cholangiocarcinoma"/>
      <xs:enumeration value="Choledochal cyst"/>
      <xs:enumeration value="Cystic duct stones"/>
      <xs:enumeration value="Duodenal diverticulum"/>
      <xs:enumeration value="Gallbladder stone(s)"/>
      <xs:enumeration value="Gallbladder tumor"/>
      <xs:enumeration value="Hemobilia"/>
      <xs:enumeration value="IPMT"/>
      <xs:enumeration value="Mirizzi syndrome"/>
      <xs:enumeration value="Pancreas annulare"/>
      <xs:enumeration value="Pancreas divisum"/>
      <xs:enumeration value="Pancreatic cyst"/>
      <xs:enumeration value="Pancreatic duct fistula/leak"/>
      <xs:enumeration value="Pancreatic duct injury"/>
      <xs:enumeration value="Pancreatic duct stricture"/>
      <xs:enumeration value="Pancreatic stent occlusion"/>
      <xs:enumeration value="Pancreatic stone"/>
      <xs:enumeration value="Pancreatic tumor"/>
      <xs:enumeration value="Pancreatitis - acute"/>
      <xs:enumeration value="Pancreatitis - chronic"/>
      <xs:enumeration value="Papillary stenosis"/>
      <xs:enumeration value="Papillary tumor"/>
      <xs:enumeration value="Primary sclerosing cholangitis"/>
      <xs:enumeration value="Suppurative cholangitis"/>
      <xs:enumeration value="Achalasia"/>
      <xs:enumeration value="Barrett''s oesophagus"/>
      <xs:enumeration value="Dieulafoy lesion"/>
      <xs:enumeration value="Duodenal polyp"/>
      <xs:enumeration value="Duodenal tumour - benign"/>
      <xs:enumeration value="Duodenal tumour - malignant"/>
      <xs:enumeration value="Duodenal ulcer"/>
      <xs:enumeration value="Duodenitis - erosive"/>
      <xs:enumeration value="Duodenitis - non-erosive"/>
      <xs:enumeration value="Extrinsic compression"/>
      <xs:enumeration value="Gastric diverticulum"/>
      <xs:enumeration value="Gastric fistula"/>
      <xs:enumeration value="Gastric foreign body"/>
      <xs:enumeration value="Gastric polyp(s)"/>
      <xs:enumeration value="Gastric postoperative appearance"/>
      <xs:enumeration value="Gastric tumour - benign"/>
      <xs:enumeration value="Gastric tumour - malignant"/>
      <xs:enumeration value="Gastric tumour - submucosal"/>
      <xs:enumeration value="Gastric ulcer"/>
      <xs:enumeration value="Gastric varices"/>
      <xs:enumeration value="Gastritis - erosive"/>
      <xs:enumeration value="Gastritis - non-erosive"/>
      <xs:enumeration value="Gastropathy-portal hypertensive"/>
      <xs:enumeration value="GAVE"/>
      <xs:enumeration value="Hiatus hernia"/>
      <xs:enumeration value="Mallory-Weiss tear"/>
      <xs:enumeration value="Oesophageal candidiasis"/>
      <xs:enumeration value="Oesophageal diverticulum"/>
      <xs:enumeration value="Oesophageal fistula"/>
      <xs:enumeration value="Oesophageal foreign body"/>
      <xs:enumeration value="Oesophageal polyp"/>
      <xs:enumeration value="Oesophageal stricture - benign"/>
      <xs:enumeration value="Oesophageal stricture - malignant"/>
      <xs:enumeration value="Oesophageal tumour - benign"/>
      <xs:enumeration value="Oesophageal tumour - malignant"/>
      <xs:enumeration value="Oesophageal ulcer"/>
      <xs:enumeration value="Oesophageal varices"/>
      <xs:enumeration value="Oesophagitis - eosinophilic"/>
      <xs:enumeration value="Oesophagitis - reflux"/>
      <xs:enumeration value="Pharyngeal pouch"/>
      <xs:enumeration value="Pyloric stenosis"/>
      <xs:enumeration value="Scar"/>
      <xs:enumeration value="Schatzki ring"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="TherapeuticLookupEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="None"/>
      <xs:enumeration value="Other"/>
      <xs:enumeration value="Argon beam photocoagulation"/>
      <xs:enumeration value="Balloon dilation"/>
      <xs:enumeration value="Banding of haemorrhoid"/>
      <xs:enumeration value="Clip placement"/>
      <xs:enumeration value="Endoloop placement"/>
      <xs:enumeration value="Foreign body removal"/>
      <xs:enumeration value="Injection therapy"/>
      <xs:enumeration value="Marking / tattooing"/>
      <xs:enumeration value="Polyp - cold biopsy"/>
      <xs:enumeration value="Polyp - EMR"/>
      <xs:enumeration value="Polyp - ESD"/>
      <xs:enumeration value="Polyp - hot biopsy"/>
      <xs:enumeration value="Polyp - snare cold"/>
      <xs:enumeration value="Polyp - snare hot"/>
      <xs:enumeration value="Stent change"/>
      <xs:enumeration value="Stent placement"/>
      <xs:enumeration value="Stent removal"/>
      <xs:enumeration value="YAG laser"/>
      <xs:enumeration value="Balloon trawl"/>
      <xs:enumeration value="Bougie dilation"/>
      <xs:enumeration value="Brush cytology"/>
      <xs:enumeration value="Cannulation"/>
      <xs:enumeration value="Combined (rendezvous) proc"/>
      <xs:enumeration value="Diagnostic cholangiogram"/>
      <xs:enumeration value="Diagnostic pancreatogram"/>
      <xs:enumeration value="Endoscopic cyst puncture"/>
      <xs:enumeration value="Haemostasis"/>
      <xs:enumeration value="Manometry"/>
      <xs:enumeration value="Nasopancreatic / bilary drain"/>
      <xs:enumeration value="Sphincterotomy"/>
      <xs:enumeration value="Stent placement - CBD"/>
      <xs:enumeration value="Stent placement - pancreas"/>
      <xs:enumeration value="Stone extraction &gt;=10mm"/>
      <xs:enumeration value="Stone extraction &lt;10mm"/>
      <xs:enumeration value="Band ligation"/>
      <xs:enumeration value="Botox injection"/>
      <xs:enumeration value="EMR"/>
      <xs:enumeration value="ESD"/>
      <xs:enumeration value="Heater probe"/>
      <xs:enumeration value="Hot biopsy"/>
      <xs:enumeration value="PEG change"/>
      <xs:enumeration value="PEG placement"/>
      <xs:enumeration value="PEG removal"/>
      <xs:enumeration value="Polypectomy"/>
      <xs:enumeration value="Radio frequency ablation"/>
      <xs:enumeration value="Variceal sclerotherapy"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="BiopsyEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="None"/>
      <xs:enumeration value="Oesophagus"/>
      <xs:enumeration value="Stomach"/>
      <xs:enumeration value="Duodenal bulb"/>
      <xs:enumeration value="D2 - 2nd part of duodenum"/>
      <xs:enumeration value="Terminal ileum"/>
      <xs:enumeration value="Neo-terminal ileum"/>
      <xs:enumeration value="Ileo-colon anastomosis"/>
      <xs:enumeration value="Ascending Colon"/>
      <xs:enumeration value="Hepatic flexure"/>
      <xs:enumeration value="Transverse Colon"/>
      <xs:enumeration value="Splenic flexure"/>
      <xs:enumeration value="Descending Colon"/>
      <xs:enumeration value="Sigmoid Colon"/>
      <xs:enumeration value="Rectum"/>
      <xs:enumeration value="Anus"/>
      <xs:enumeration value="Pouch"/>
      <xs:enumeration value="Caecum"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="AdverseEventEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="None"/>
      <xs:enumeration value="Other"/>
      <xs:enumeration value="Ventilation"/>
      <xs:enumeration value="Perforation of lumen"/>
      <xs:enumeration value="Bleeding"/>
      <xs:enumeration value="O2 desaturation"/>
      <xs:enumeration value="Flumazenil"/>
      <xs:enumeration value="Naloxone"/>
      <xs:enumeration value="Consent signed in room"/>
      <xs:enumeration value="Withdrawal of consent"/>
      <xs:enumeration value="Unplanned admission"/>
      <xs:enumeration value="Unsupervised trainee"/>
      <xs:enumeration value="Death"/>
      <xs:enumeration value="Pancreatitis"/>
    </xs:restriction>
  </xs:simpleType>
  <!-- Standard Types -->
  <xs:simpleType name="BowelPrepEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Not Specified"/>
      <xs:enumeration value="excellent"/>
      <xs:enumeration value="good"/>
      <xs:enumeration value="fair"/>
      <xs:enumeration value="inadequate"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="ProcedureNameEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="OGD"/>
      <xs:enumeration value="FLEXI"/>
      <xs:enumeration value="ERCP"/>
      <xs:enumeration value="COLON"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="GenderType">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Male"/>
      <xs:enumeration value="Female"/>
      <xs:enumeration value="Unknown"/>
      <xs:enumeration value="Indeterminate"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="YesNoEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Not Specified"/>
      <xs:enumeration value="No"/>
      <xs:enumeration value="Yes"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="PolypSizeEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="ItemLessThan10mm"/>
      <xs:enumeration value="Item10to19mm"/>
      <xs:enumeration value="Item20OrLargermm"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="TattooEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="No"/>
      <xs:enumeration value="Yes"/>
      <xs:enumeration value="Previously Tattooed"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="TimeEnum">
    <xs:restriction base="xs:string">
      <xs:enumeration value="AM"/>
      <xs:enumeration value="PM"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="UKDateType">
    <xs:restriction base="xs:string">
      <xs:pattern value="([012]?\d|3[01])/([Jj][Aa][Nn]|[Ff][Ee][bB]|[Mm][Aa][Rr]|[Aa][Pp][Rr]|[Mm][Aa][Yy]|[Jj][Uu][Nn]|[Jj][uU][lL]|[aA][Uu][gG]|[Ss][eE][pP]|[oO][cC][tT]|[Nn][oO][Vv]|[Dd][Ee][Cc])/(19|20)\d\d"/>
    </xs:restriction>
  </xs:simpleType>
</xs:schema>
'
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'NED_Adverse', 'V';
GO

Create View [dbo].[NED_Adverse] As
SELECT ProcedureId, NULL As Comment, 'Bleeding' As adverseEvent
From ERS_UpperGIBleeds
Union
Select ProcedureId, comment, adverseEvent
From (Select ProcedureId, NULL As comment
	, Case When PR.PatientConsent=1 Then 10 END As PatientConsent
	, Case When PR.PatientStatus=1 Or PR.PatientStatus=4 Then 11 END As PatientStatus
	From ERS_Procedures PR
) As Dn
UNPIVOT (adverseId For adv In (PatientConsent, PatientStatus)
) As Up
INNER JOIN [dbo].[ERS_ReportAdverse] RT ON up.adverseId=RT.AdverseId
Union
SELECT ProcedureId, comment, adverseEvent
FROM
(
  SELECT ProcedureId, ComplicationsSummary As comment
	, Case When Q.Perforation=1 Then 4 End As Perforation
	, Case When Q.ComplicationsOther=1 Then 2 End As ComplicationsOther
	, Case When Q.Death=1 Then 2 End As Death
	, Case When Q.CardiacArrythmia=1 Then 2 End As CardiacArrythmia
	, Case When Q.CardiacArrest=1 Then 2 End As CardiacArrest
	, Case When Q.RespiratoryArrest=1 Then 6 End As RespiratoryArrest
	, Case When Q.Haemorrhage=1 Then 5 End As Haemorrhage
	, Case When Q.Hypoxia=1 Then 3 End As Hypoxia
	, Case When Q.Oxygenation=1 Then 6 End As Oxygenation
	FROM ERS_UpperGIQA Q
) AS cp1
UNPIVOT 
(
  adverseId FOR adverse IN (Perforation, ComplicationsOther, Death, CardiacArrythmia, CardiacArrest, RespiratoryArrest, Haemorrhage, Hypoxia, Oxygenation)
) AS up
INNER JOIN [dbo].[ERS_ReportAdverse] RT ON up.adverseId=RT.AdverseId
Union
Select ProcedureId, comment, adverseEvent FROM (
Select ProcedureId, NULL As comment
	, Case When PM.DrugName='Naloxone' Then 8 End As Naloxone
	, Case When PM.DrugName='Flumazenil' Then 7 End As Flumazenil
	From ERS_UpperGIPremedication PM
) As cp3
UNPIVOT (
adverseId For adv In (Naloxone, Flumazenil)
) As Up
INNER JOIN [dbo].[ERS_ReportAdverse] RT ON up.adverseId=RT.AdverseId
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_NED', 'S';
GO

Create Proc [dbo].[sp_NED]
	@ProcedureId INT
	, @UserId INT
	,@site varchar(50)=NULL
	,@reportdate datetime=NULL
	,@description varchar(50)=NULL
	,@uniqueid varchar(50)=NULL
	,@xsd varchar(128)=NULL
	,@xsi varchar(128)=NULL
	,@ns varchar(128)=NULL As
Begin
	SET NOCOUNT ON
	Declare @time varchar(50)
	Declare @date varchar(50)
	Declare @type varchar(50)
	Set @site='S314H'--??????
	Select @type=Case ListType When 1 Then 'Dedicated Training List' When 2 Then 'Adhoc Training List' Else 'Service List' End From ERS_Procedures Where ProcedureId=@ProcedureId
	If datepart(hh,@Date)>12 SET @time='PM'
	ELSE SET @time='AM'
	Set @reportdate=IsNull(@reportdate,GETDATE())
	Set @date=Convert(VARCHAR(50),Datepart(dd,@reportdate))+'/'+Convert(VARCHAR(50),Case Datepart(month,@reportdate) When 1 Then 'Jan' When 2 Then 'Feb' When 3 Then 'Mar' When 4 Then 'Apr' When 5 Then 'May' When 6 Then 'Jun' When 7 Then 'Jul' When 8 Then 'Aug' When 9 Then 'Sep' When 10 Then 'Oct' When 11 Then 'Nov' When 12 Then 'Dec' End )+'/'+Convert(VARCHAR(50),Datepart(yy,@reportdate))
	Set @description=IsNull(@description,'NED List')
	Set @uniqueid=IsNull(@uniqueid,Convert(varchar(50),NewID()))--'UNISOFTMEDICAL'+Convert(VARCHAR(10),@ProcedureId)
	Declare @x XML
	--/*-- Remove the "--" to debug
	Select @x=(Select TAG, Parent, [procedure!4!localProcedureId]
		, [procedure!4!previousLocalProcedureId]
		, [procedure!4!procedureName]
		, [procedure!4!endoscopistDiscomfort]
		, [procedure!4!nurseDiscomfort]
		, [procedure!4!polypsDetected]
		, [procedure!4!extent]
		, [procedure!4!bowelPrep]
		, [procedure!4!entonox] -- Not included to perform exactly the same as UGI I let the line here to let easy implementation in the future
		, [procedure!4!antibioticGiven] -- Not included to perform exactly the same as UGI I let the line here to let easy implementation in the future
		, [procedure!4!generalAnaes] -- Not included to perform exactly the same as UGI I let the line here to let easy implementation in the future
		, [procedure!4!pharyngealAnaes] -- Not included to perform exactly the same as UGI I let the line here to let easy implementation in the future
		, [procedure!4!digitalRectalExamination]
		, [procedure!4!magneticEndoscopeImagerUsed]
		, [procedure!4!scopeWithdrawalTime]	
		, [patient!5!gender]
		, [patient!5!age]
		, [patient!5!admissionType]
		, [patient!5!urgencyType]
		, [drugs!6!pethidine]
		, [drugs!6!midazolam]
		, [drugs!6!fentanyl]
		, [drugs!6!buscopan]
		, [drugs!6!propofol]
		, [drugs!6!noDrugsAdministered]
		, [staff.members!7]
		, [Staff!8!professionalBodyCode]
		, [Staff!8!endoscopistRole]
		, [Staff!8!procedureRole]
		, [Staff!8!extent]
		, [Staff!8!jManoeuvre]
		, [therapeutics!9]
		, [therapeutic!10!type]
		, [therapeutic!10!site]
		, [therapeutic!10!role]
		, [therapeutic!10!polypSize]
		, [therapeutic!10!tattooed]
		, [therapeutic!10!performed]
		, [therapeutic!10!successful]
		, [therapeutic!10!retrieved]
		, [therapeutic!10!comment]
		, [indications!11]
		, [indication!12]
		, [indication!12!indication]
		, [indication!12!comment]
		, [limitations!13]
		, [limitations!13!limitation]
		, [limitation!14!limitation]
		, [limitation!14!comment]
		, [biopsies!15]
		, [biopsies!15!Biopsy]
		, [Biopsy!16!biopsySite]
		, [Biopsy!16!numberPerformed]
		, [diagnoses!17]
		, [diagnoses!17!Diagnose]
		, [Diagnose!18!diagnosis]
		, [Diagnose!18!tattooed]
		, [Diagnose!18!site]
		, [Diagnose!18!comment]
		, [adverse.events!19]
		, [adverse.event!20!adverseEvent]
		, [adverse.event!20!comment]
	From (
	--*/-- Remove the "--" to debug
	SELECT 4 As Tag, 0 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		--, Convert(varchar(20),LAG(PR.ProcedureId) OVER (ORDER BY PR.PatientId)) As [procedure!4!previousLocalProcedureId]
		, (Select Top 1 Convert(varchar(20),PR.ProcedureId) From ERS_Procedures OP Where OP.ProcedureId<PR.ProcedureId Order By OP.ProcedureId Desc) As [procedure!4!previousLocalProcedureId]
		, Case PR.ProcedureType When 1 Then 'OGD' When 11 Then 'FLEXI' When 2 Then 'ERCP' ELSE 'COLON' END As [procedure!4!procedureName]
		, Case QA.PatDiscomfort When 5 Then 'Severe' When 4 Then 'Moderate' When 3 Then 'Mild' When 2 Then 'Minimal' When 1 Then 'Comfortable' Else 'Not Specified' End As [procedure!4!endoscopistDiscomfort]
		, Case QA.PatDiscomfort When 5 Then 'Severe' When 4 Then 'Moderate' When 3 Then 'Mild' When 2 Then 'Minimal' When 1 Then 'Comfortable' Else 'Not Specified' End As [procedure!4!nurseDiscomfort]
		,IsNull(CL.SessileQuantity,0)+IsNull(CL.PedunculatedQuantity,0)+IsNull(CL.PseudopolypsQuantity,0)+IsNull(CL.PolypoidalQuantity,0) As [procedure!4!polypsDetected]
		, Case PR.ProcedureType 
			When 1 Then 
				Case EX.Extent 
					When 1 Then 'D2 - 2nd part of duodenum'
					When 2 Then 'D2 - 2nd part of duodenum'
					When 3 Then 'D2 - 2nd part of duodenum'
					When 4 Then 'Stomach'
					When 5 Then 'Oesophagus'
					When 6 Then 'Oesophagus'
					When 7 Then 'Duodenal bulb'
					Else 'Intubation failed' End
			When 2 then
				Case 
					When (HL.MajorPapillaBile<=2 And HL.MajorPapillaPancreatic<=2) 
						Then 'CBD and PD'
					Else 
						Case When HL.MajorPapillaBile<=2 Then 'Pancreatic duct' Else Case When HL.MajorPapillaPancreatic<=2 Then 'Pancreatic duct' Else 
							Case When HL.MinorPapilla>=2 Then 'Abandoned' Else 'Papilla' End
						End 
					End
				End
			When 11 Then 'FLEXI####' --FLEXI
			Else -- COLON
				Case EL.InsertionTo
					When 1 then 'Intubation failed'
					When 2 then 'Intubation failed'
					When 3 then 'Sigmoid Colon'
					When 4 then 'Transverse Colon'
					When 5 then 'Caecum'
					When 6 then 'Caecum'
					When 7 then 'Descending Colon'
					When 8 then 'Transverse Colon'
					When 9 then 'Terminal ileum'
					When 10 then 'Rectum'
					When 11 then 'Descending Colon'
					When 12 then 'Hepatic flexure'
					When 13 then 'Neo-terminal ileum'
					When 14 then 'Sigmoid Colon'
					When 15 then 'Splenic flexure'
					When 16 then 'Ascending Colon'
					When 17 then 'Sigmoid Colon'
					When 18 then 'Transverse Colon'
					When 19 then 'Ascending Colon'
					When 20 then 'Anastomosis' 
					Else 'Abandoned' End
			End	As [procedure!4!extent]
		, Case When BP.OffQualityPoor=1 Then 'inadequate' Else Case When BP.OffQualityGood=1 Then 'good' Else Case When BP.OffQualitySatisfactory=1 Then 'fair' Else NULL End End End As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox] -- Not included to perform exactly the same as UGI I let the line here to let easy implementation in the future
		, NULL As [procedure!4!antibioticGiven] -- Not included to perform exactly the same as UGI I let the line here to let easy implementation in the future
		, NULL As [procedure!4!generalAnaes] -- Not included to perform exactly the same as UGI I let the line here to let easy implementation in the future
		, NULL As [procedure!4!pharyngealAnaes] -- Not included to perform exactly the same as UGI I let the line here to let easy implementation in the future
		, CASE EL.RectalExam When 1 Then 'Yes' When 0 Then 'No' Else NULL End  As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, EL.TimeForWithdrawalMin+Case When EL.TimeForWithdrawalSec>30 Then 1 Else 0 End As [procedure!4!scopeWithdrawalTime]	
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered]
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	FROM dbo.ERS_Procedures PR LEFT OUTER JOIN dbo.ERS_Sites PS ON PR.ProcedureId=PS.ProcedureId
		LEFT OUTER JOIN dbo.ERS_ColonTherapeutics CT ON PS.SiteId=CT.SiteId
		LEFT OUTER JOIN dbo.ERS_ColonExtentOfIntubation EL ON PR.ProcedureId=EL.ProcedureId
		LEFT OUTER JOIN dbo.ERS_UpperGIExtentOfIntubation EX ON PR.ProcedureId=EX.ProcedureId
		LEFT OUTER JOIN dbo.ERS_Visualisation HL ON PR.ProcedureId=HL.ProcedureId
		LEFT OUTER JOIN dbo.ERS_ColonAbnoLesions CL ON PS.SiteId = CL.SiteId
		LEFT OUTER JOIN dbo.ERS_UpperGIQA QA ON PR.ProcedureId = QA.ProcedureId
		LEFT OUTER JOIN dbo.ERS_BowelPreparation BP ON PR.ProcedureId=BP.ProcedureID
		INNER JOIN dbo.ERS_VW_Patients P ON PR.PatientId=P.[PatientId]
		Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 5 As Tag, 4 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, Case P.Gender When 'F' Then 'Female' When 'M' Then 'Male' Else 'Unknown' End As [patient!5!gender]
		, Convert(int,PR.CreatedOn-P.[Date of birth])/365 As [patient!5!age]
		, Case PR.PatientType When 1 Then 'Inpatient' When 2 Then 'Outpatient' When 3 Then 'Not Specified' End As [patient!5!admissionType]
		, NULL  As [patient!5!urgencyType] -- Not included to perform exactly the same as UGI I let the line here to let easy implementation in the future to perform use the PR.PatientStatus Field
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered]
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	FROM dbo.ERS_Procedures PR INNER JOIN dbo.ERS_VW_Patients P ON PR.PatientId=P.[PatientId]
	Where PR.ProcedureId=@ProcedureId
	Union All 
	SELECT 6 As Tag, 4 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, Convert(Numeric(10,2),IsNull(PR.pethidine,0)) As [drugs!6!pethidine]
		, Convert(Numeric(10,2),IsNull(PR.midazolam,0)) As [drugs!6!midazolam]
		, Convert(Numeric(10,2),isnull(PR.fentanyl,0)) As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, Case When (Convert(Numeric(10,2),IsNull(PR.pethidine,0))+Convert(Numeric(10,2),IsNull(PR.midazolam,0))+Convert(Numeric(10,2),isnull(PR.fentanyl,0)))=0 Then 'Yes' End As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From 
		(Select PR.ProcedureId, PM.DrugName, PM.Dose
		From ERS_Procedures PR 
			LEFT OUTER JOIN [dbo].[ERS_UpperGIPremedication] PM ON PR.ProcedureId=PM.ProcedureId) As j
		PIVOT
		(
		SUM(j.Dose) For j.Drugname In ([pethidine],[midazolam],[fentanyl])
		) As PR
		Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 7 As Tag, 4 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, '' As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From ERS_Procedures PR
	Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 8 As Tag, 7 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, '' As [staff.members!7]
		, IsNull(PR.GPPracticeCode,0) As [Staff!8!professionalBodyCode]
		, Case When @Type='Service List' Then 'Independent' Else 
			Case PC.ConsultantTypeId 
				When 1 Then 'Trainer'
				When 2 Then 'Trainee'
				Else 'Independent' End
			End As [Staff!8!endoscopistRole]
		, Case When @Type='Service List' Then 'Independent (no trainer)' Else 
			Case PC.ConsultantTypeId 
				When 1 Then Case When PR.ProcedureRole=2 Then 'I observed' Else 'I assisted physically' End
				When 2 Then Case When PR.ProcedureRole=3 Then 'Was observed' Else 'Was assisted physically' End
				Else 'Independent (no trainer)' End
			End As [Staff!8!procedureRole]
			, Case PR.ProcedureType 
			When 1 Then 
				Case EX.Extent 
					When 1 Then 'D2 - 2nd part of duodenum'
					When 2 Then 'D2 - 2nd part of duodenum'
					When 3 Then 'D2 - 2nd part of duodenum'
					When 4 Then 'Stomach'
					When 5 Then 'Oesophagus'
					When 6 Then 'Oesophagus'
					When 7 Then 'Duodenal bulb'
					Else 'Intubation failed' End
			When 2 then
				Case 
					When (HL.MajorPapillaBile<=2 And HL.MajorPapillaPancreatic<=2) 
						Then 'CBD and PD'
					Else 
						Case When HL.MajorPapillaBile<=2 Then 'Pancreatic duct' Else Case When HL.MajorPapillaPancreatic<=2 Then 'Pancreatic duct' Else 
							Case When HL.MinorPapilla>=2 Then 'Abandoned' Else 'Papilla' End
						End 
					End
				End
			When 11 Then 'FLEXI####' --FLEXI
			Else -- COLON
				Case EL.InsertionTo
					When 1 then 'Intubation failed'
					When 2 then 'Intubation failed'
					When 3 then 'Sigmoid Colon'
					When 4 then 'Transverse Colon'
					When 5 then 'Caecum'
					When 6 then 'Caecum'
					When 7 then 'Descending Colon'
					When 8 then 'Transverse Colon'
					When 9 then 'Terminal ileum'
					When 10 then 'Rectum'
					When 11 then 'Descending Colon'
					When 12 then 'Hepatic flexure'
					When 13 then 'Neo-terminal ileum'
					When 14 then 'Sigmoid Colon'
					When 15 then 'Splenic flexure'
					When 16 then 'Ascending Colon'
					When 17 then 'Sigmoid Colon'
					When 18 then 'Transverse Colon'
					When 19 then 'Ascending Colon'
					When 20 then 'Anastomosis' 
					Else 'Abandoned' End
			End	As [Staff!8!extent]
		, Case IsNull(PR.Jmanoeuvre,0) When 1 Then 'Yes' When 0 Then 'No' End As [Staff!8!jManoeuvre] -- Field not implemented in ERS at august 2016 It's optional field.
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	FROM dbo.ERS_Procedures PR LEFT OUTER JOIN dbo.ERS_Sites PS ON PR.ProcedureId=PS.ProcedureId
		LEFT OUTER JOIN dbo.ERS_ColonTherapeutics CT ON PS.SiteId=CT.SiteId
		LEFT OUTER JOIN dbo.ERS_ColonExtentOfIntubation EL ON PR.ProcedureId=EL.ProcedureId
		LEFT OUTER JOIN dbo.ERS_UpperGIExtentOfIntubation EX ON PR.ProcedureId=EX.ProcedureId
		LEFT OUTER JOIN dbo.ERS_Visualisation HL ON PR.ProcedureId=HL.ProcedureId
		LEFT OUTER JOIN dbo.ERS_ColonAbnoLesions CL ON PS.SiteId = CL.SiteId
		LEFT OUTER JOIN dbo.ERS_UpperGIQA QA ON PR.ProcedureId = QA.ProcedureId
		LEFT OUTER JOIN dbo.ERS_BowelPreparation BP ON PR.ProcedureId=BP.ProcedureID
		LEFT OUTER JOIN dbo.fw_ProceduresConsultants PC ON PR.ProcedureId=Convert(int,Replace(PC.ProcedureId,'E.',''))
		INNER JOIN dbo.Patient P ON PR.PatientId=P.[Patient No]
		Where PC.ConsultantTypeId In (1, Case When @type='Service List' Then (1) Else (2) End, Case When @type='Service List' Then (1) Else (4) End) And PC.ProcedureId Like 'E.%'
		And PR.ProcedureId=@ProcedureId
	Union All
	SELECT 9 As Tag, 8 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, '' As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From ERS_Procedures PR
	Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 10 As Tag, 9 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, '' As [therapeutics!9]
		, IsNull(RT.NedName,'None') As [therapeutic!10!type]
		, Organ As [therapeutic!10!site]--Bite1: fw_Therapeutic
		, NULL As [therapeutic!10!role]
		, Case When polypSize<10 Then 'ItemLessThan10mm' Else Case When polypSize>10 And polypSize<10 Then 'Item10to19mm' Else 'Item20OrLargermm' End End As [therapeutic!10!polypSize]
		/*, Case When Tattooed=1 Then 'Yes' Else 'No' End As [therapeutic!10!tattooed]*/
		, NULL As [therapeutic!10!tattooed]
		, IsNull(Performed,0) As [therapeutic!10!performed]
		, IsNull(Successful,0) As [therapeutic!10!successful]
		, Retrieved As [therapeutic!10!retrieved]
		/*, comment As [therapeutic!10!comment]*/
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From ERS_Procedures PR
		LEFT OUTER JOIN fw_Sites S ON Convert(varchar(10),PR.ProcedureId)=Replace(S.SiteId,'E.','')
		LEFT OUTER JOIN fw_Therapeutic RT ON S.SiteId=RT.SiteId
		Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 11 As Tag, 4 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, '' As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From ERS_Procedures PR
	Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 12 As Tag, 11 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, '' As [indications!11]
		, '' As [indication!12]
		, IsNull(I.NedName,'Other') As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From ERS_Procedures PR
		LEFT OUTER JOIN fw_Indications I ON Convert(varchar(10),PR.ProcedureId)=Replace(I.ProcedureId,'E.','')
		Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 13 As Tag, 4 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, '' As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From ERS_Procedures PR
	Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 14 As Tag, 13 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, '' As [limitations!13]
		, '' As [limitations!13!limitation]
		, Case 
			When PR.ProcedureType=11 Then 'clinical intention achieved' 
			Else 
				Case L.InsertionLimitedBy When 0 Then 'Not Limited' When 1 Then 'unresolved loop' When 2 Then 'Other' When 3 Then 'unresolved loop' When 4 Then 'inadequate bowel prep' When 5 Then 'Other' When 6 Then 'malignant stricture' When 7 Then 'patient discomfort' Else 'Other' End End As [limitation!14!limitation]
		, L.Summary As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From ERS_Procedures PR
	LEFT OUTER JOIN [dbo].[ERS_ColonExtentOfIntubation] L ON L.ProcedureId=PR.ProcedureId
	Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 15 As Tag, 4 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, '' As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From ERS_Procedures PR
	Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 16 As Tag, 15 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, '' As [biopsies!15]
		, Case When IsNull(SP.Biopsy,0)=1 Then '' Else 'None' End As [biopsies!15!Biopsy]
		, Case When IsNull(O.Organ,'None') ='Anastomosis' Then 'Pouch'
		Else 'None' End As [Biopsy!16!biopsySite]
		, IsNull(SP.BiopsyQtyHistology+SP.BiopsyQtyMicrobiology+SP.BiopsyQtyVirology,0) As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From ERS_Procedures PR
	LEFT OUTER JOIN ERS_Sites S ON PR.ProcedureId=S.ProcedureId
	LEFT OUTER JOIN ERS_Regions R ON S.RegionId=R.RegionId And PR.ProcedureType=R.ProcedureType
	LEFT OUTER JOIN [ERS_UpperGISpecimens] SP ON S.SiteId=SP.SiteId
	LEFT OUTER JOIN ERS_Organs O ON R.RegionId=O.RegionId
	Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 17 As Tag, 4 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, '' As [diagnoses!17]
		, NULL As [diagnoses!18!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From ERS_Procedures PR
	Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT Distinct 18 As Tag, 17 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15] 
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, '' As [diagnoses!17]
		, '' As [diagnoses!17!Diagnose]
		, IsNull(DT.NED_Diagnosis,'Other') As [Diagnose!18!diagnosis]
		/*, Case NT.Tattooed When 1 Then 'Yes' When 0 Then 'No' End As [Diagnose!18!tattooed]*/
		, NULL As [Diagnose!18!tattooed]
		, Case When NT.Organ=NULL Then 'None' End As [Diagnose!18!site]
		/*, NT.comment As [Diagnose!18!comment]*/
		, NULL As [Diagnose!18!comment]
		, NULL As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From ERS_Procedures PR
		LEFT OUTER JOIN ERS_Diagnoses DI ON PR.ProcedureId=DI.ProcedureID
		LEFT OUTER JOIN ERS_DiagnosesMatrix DM ON DI.DiagnosesID=DM.DiagnosesMatrixID
		LEFT OUTER JOIN ERS_DiagnosisTypes DT ON DM.DiagnosesMatrixID=DT.DiagnosisMatrixID
		LEFT OUTER JOIN fw_Sites S ON Convert(varchar(10),PR.ProcedureId)=Replace(S.ProcedureId,'E.','')
		LEFT OUTER JOIN fw_Therapeutic NT ON S.SiteId=NT.SiteId
	Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 19 As Tag, 4 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15]
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, '' As [adverse.events!19]
		, NULL As [adverse.event!20!adverseEvent]
		, NULL As [adverse.event!20!comment]
	From ERS_Procedures PR
	Where PR.ProcedureId=@ProcedureId
	Union All
	SELECT 20 As Tag, 19 As Parent
		, Convert(varchar(20),PR.ProcedureId) As [procedure!4!localProcedureId]
		, NULL As [procedure!4!previousLocalProcedureId]
		, NULL As [procedure!4!procedureName]
		, NULL As [procedure!4!endoscopistDiscomfort]
		, NULL As [procedure!4!nurseDiscomfort]
		, NULL As [procedure!4!polypsDetected]
		, NULL As [procedure!4!extent]
		, NULL As [procedure!4!bowelPrep]
		, NULL As [procedure!4!entonox]
		, NULL As [procedure!4!antibioticGiven]
		, NULL As [procedure!4!generalAnaes]
		, NULL As [procedure!4!pharyngealAnaes]
		, NULL As [procedure!4!digitalRectalExamination]
		, NULL As [procedure!4!magneticEndoscopeImagerUsed]
		, NULL As [procedure!4!scopeWithdrawalTime]
		, NULL As [patient!5!gender]
		, NULL As [patient!5!age]
		, NULL As [patient!5!admissionType]
		, NULL As [patient!5!urgencyType]
		, NULL As [drugs!6!pethidine]
		, NULL As [drugs!6!midazolam]
		, NULL As [drugs!6!fentanyl]
		, NULL As [drugs!6!buscopan]
		, NULL As [drugs!6!propofol]
		, NULL As [drugs!6!noDrugsAdministered] -- Not included to perform exactly the same as UGI. To include change the NULL to the following sentence: Case When PM.Dose= 0 Then 'Yes' End
		, NULL As [staff.members!7]
		, NULL As [Staff!8!professionalBodyCode]
		, NULL As [Staff!8!endoscopistRole]
		, NULL As [Staff!8!procedureRole]
		, NULL As [Staff!8!extent]
		, NULL As [Staff!8!jManoeuvre]
		, NULL As [therapeutics!9]
		, NULL As [therapeutic!10!type]
		, NULL As [therapeutic!10!site]
		, NULL As [therapeutic!10!role]
		, NULL As [therapeutic!10!polypSize]
		, NULL As [therapeutic!10!tattooed]
		, NULL As [therapeutic!10!performed]
		, NULL As [therapeutic!10!successful]
		, NULL As [therapeutic!10!retrieved]
		, NULL As [therapeutic!10!comment]
		, NULL As [indications!11]
		, NULL As [indication!12]
		, NULL As [indication!12!indication]
		, NULL As [indication!12!comment]
		, NULL As [limitations!13]
		, NULL As [limitations!13!limitation]
		, NULL As [limitation!14!limitation]
		, NULL As [limitation!14!comment]
		, NULL As [biopsies!15] 
		, NULL As [biopsies!15!Biopsy]
		, NULL As [Biopsy!16!biopsySite]
		, NULL As [Biopsy!16!numberPerformed]
		, NULL As [diagnoses!17]
		, NULL As [diagnoses!17!Diagnose]
		, NULL As [Diagnose!18!diagnosis]
		, NULL As [Diagnose!18!tattooed]
		, NULL As [Diagnose!18!site]
		, NULL As [Diagnose!18!comment]
		, '' As [adverse.events!19]
		, IsNull(AD.adverseEvent,'None') As [adverse.event!20!adverseEvent]
		, AD.Comment As [adverse.event!20!comment]
	From ERS_Procedures PR
	LEFT OUTER JOIN [dbo].[NED_Adverse] AD ON AD.ProcedureId=PR.ProcedureId
	Where PR.ProcedureId=@ProcedureId
	--/*-- Remove the "--" to debug
	) As A
	Order By [procedure!4!localProcedureId], TAG, Parent
	For xml EXPLICIT)
	--Select @root
	--*/-- Remove the "--" to debug
--Select @x -- Remove the "--" to debug
	Declare @root XML
	Set @root=(Select Tag, Parent, [hospital.SendBatchMessage!1!xmlns:xsd]
		,  [hospital.SendBatchMessage!1!xmlns:xsi]
		, [hospital.SendBatchMessage!1!xmlns]
		, [session!2!uniqueId]
		, [session!2!description]
		, [session!2!date]
		, [session!2!time]
		, [session!2!type]
		, [session!2!site]
		, [procedures!3]
	 From (SELECT 1 As Tag, NULL As Parent
		, IsNull(@ns,'http://www.w3.org/2001/XMLSchema') As [hospital.SendBatchMessage!1!xmlns:xsd]
		, IsNull(@xsi,'http://www.w3.org/2001/XMLSchema-instance') As [hospital.SendBatchMessage!1!xmlns:xsi]
		, IsNull(@xsd,'http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd') As [hospital.SendBatchMessage!1!xmlns]
		, NULL As [session!2!uniqueId]
		, NULL As [session!2!description]
		, NULL As [session!2!date]
		, NULL As [session!2!time]
		, NULL As [session!2!type]
		, NULL As [session!2!site]
		, '' As [procedures!3]
	Union All
	SELECT 2 As Tag, 1 As Parent
		, IsNull(@ns,'http://www.w3.org/2001/XMLSchema') As [hospital.SendBatchMessage!1!xmlns:xsd]
		, IsNull(@xsi,'http://www.w3.org/2001/XMLSchema-instance') As [hospital.SendBatchMessage!1!xmlns:xsi]
		, IsNull(@xsd,'http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd') As [hospital.SendBatchMessage!1!xmlns]
		, @uniqueid As [session!2!uniqueId]
		, @description As [session!2!description]
		, Convert(VARCHAR(50),Datepart(dd,GetDate()))+'/'+Convert(VARCHAR(50),Case Datepart(month,GetDate()) When 1 Then 'Jan' When 2 Then 'Feb' When 3 Then 'Mar' When 4 Then 'Apr' When 5 Then 'May' When 6 Then 'Jun' When 7 Then 'Jul' When 8 Then 'Aug' When 9 Then 'Sep' When 10 Then 'Oct' When 11 Then 'Nov' When 12 Then 'Dec' End )+'/'+Convert(VARCHAR(50),Datepart(yy,GetDate())) As [session!2!date]
		, RIGHT(CONVERT(VARCHAR(30), GetDate(), 9), 2) As [session!2!time]
		, @type As [session!2!type]
		, '' As [session!2!site]
		, '' As [procedures!3]
	Union All
	SELECT 3 As Tag, 2 As Parent
		, IsNull(@ns,'http://www.w3.org/2001/XMLSchema') As [hospital.SendBatchMessage!1!xmlns:xsd]
		, IsNull(@xsi,'http://www.w3.org/2001/XMLSchema-instance') As [hospital.SendBatchMessage!1!xmlns:xsi]
		, IsNull(@xsd,'http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd') As [hospital.SendBatchMessage!1!xmlns]
		, @uniqueid As [session!2!uniqueId]
		, @description As [session!2!description]
		, Convert(VARCHAR(50),Datepart(dd,GetDate()))+'/'+Convert(VARCHAR(50),Case Datepart(month,GetDate()) When 1 Then 'Jan' When 2 Then 'Feb' When 3 Then 'Mar' When 4 Then 'Apr' When 5 Then 'May' When 6 Then 'Jun' When 7 Then 'Jul' When 8 Then 'Aug' When 9 Then 'Sep' When 10 Then 'Oct' When 11 Then 'Nov' When 12 Then 'Dec' End )+'/'+Convert(VARCHAR(50),Datepart(yy,GetDate())) As [session!2!date]
		, RIGHT(CONVERT(VARCHAR(30), GetDate(), 9), 2) As [session!2!time]
		, @type As [session!2!type]
		, '' As [session!2!site]
		, '' As [procedures!3]
		) As A
	Order By 3, Tag, Parent
	For xml EXPLICIT)
	SET @root.modify('insert sql:variable("@x") as first into (/*:hospital.SendBatchMessage/*:session/*:procedures)[1]')
	SET @root=Convert(xml, Replace(convert(nvarchar(max),@root),'procedure xmlns=""', 'procedure '))
	DECLARE @PreviousNED XML=''
	Select TOP 1 @PreviousNED=xmlFile From ERS_NedFilesLog Where ProcedureID=@ProcedureId Order By LogId Desc
	DECLARE @nedfile XML(NEDxsd)
	DECLARE @xml1 XML
	DECLARE @xml2 XML
	;WITH XMLNAMESPACES('http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd' AS s,
                    'http://www.w3.org/2001/XMLSchema' AS a,
                    'http://www.w3.org/2001/XMLSchema-instance' AS fb)
	Select @xml1=@PreviousNED.query('(/s:hospital.SendBatchMessage/s:session/s:procedures)[1]')
	;WITH XMLNAMESPACES('http://weblogik.co.uk/jets/Hospital.SendBatchMessage.xsd' AS s,
                    'http://www.w3.org/2001/XMLSchema' AS a,
                    'http://www.w3.org/2001/XMLSchema-instance' AS fb)
	Select @xml2=@root.query('(/s:hospital.SendBatchMessage/s:session/s:procedures)[1]')
	If Exists (Select LogId From ERS_NedFilesLog Where ProcedureId=@ProcedureId)
	Begin
		If [dbo].[CompareXml](@xml1,@xml2)=0
		begin
			PRINT 'Both XML are equal'
		End
		Else
		Begin
			Insert Into ERS_NedFilesLog (ProcedureID, xmlFile, IsProcessed, IsSchemaValid, TimesSent, LastUserId) Values (@ProcedureId, @Root,'FALSE','TRUE', 1, @UserId)
		End
	End
	Else
	Begin
		BEGIN TRY
			Set @nedfile=@root
			Update ERS_Procedures Set NEDExported=1, NEDEnabled=1 Where ProcedureId=@ProcedureId
			Insert Into ERS_NedFilesLog (ProcedureID, xmlFile, IsProcessed, IsSchemaValid, TimesSent, LastUserId) Values (@ProcedureId, @Root,'FALSE','TRUE', 1, @UserId)
			--Insert Into ERS_NEDLogfile (NEDFile,IsSchemaValidated,IsSent,IsRejected) VALUES (@root,'TRUE','FALSE','FALSE')
			--Select @root
		END TRY
		BEGIN CATCH
			PRINT ERROR_MESSAGE()
			Update ERS_Procedures Set NEDExported=0, NEDEnabled=0 Where ProcedureId=@ProcedureId
			Insert Into ERS_NedFilesLog (ProcedureID, xmlFile, IsProcessed, IsSchemaValid) Values (@ProcedureId, @Root,'FALSE','FALSE')
		END CATCH
	End
End
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'report_BowelBoston', 'S';
GO

CREATE PROCEDURE [dbo].[report_BowelBoston]
	@UserID int=NULL As
Begin
	Declare @From Date
	Declare @To Date
	DECLARE @WholeDB BIT
	Set NoCount On
	If @UserID Is Null 
	Begin
		Raiserror('Session has been expired. You need to reconnect.',11,1)
	End
	Else
	Begin
		Select @From=FromDate, @To=ToDate, @WholeDB=1 From [dbo].[ERS_ReportFilter] Where UserID=@UserID
		Create Table #Boston0A (
			[Formulation] varchar(255),
			[Scale] numeric(20,2) Default 0,
			[Right] numeric(20,2) Default 0,
			[Transverse] numeric(20,2) Default 0,
			[Left] numeric(20,2) Default 0,
			)
		Create Table #Boston0B (
			[Formulation] varchar(255),
			[Right] numeric(20,2) Default 0,
			[Transverse] numeric(20,2) Default 0,
			[Left] numeric(20,2) Default 0,
			)
		Create Table #Boston1A (
			[Formulation] varchar(255),
			[Scale] int Default 0,
			[Right] int Default 0,
			[RightP] Numeric(20,4) Default 0,
			[Transverse] int Default 0,
			[TransverseP] Numeric(20,4) Default 0,
			[Left] int Default 0,
			[LeftP] Numeric(20,4) Default 0,
			)
		Create Table #Boston1B (
			[Formulation] varchar(255),
			[Scale] int Default 0,
			[Right] int Default 0,
			[RightP] Numeric(20,4) Default 0,
			[Transverse] int Default 0,
			[TransverseP] Numeric(20,4) Default 0,
			[Left] int Default 0,
			[LeftP] Numeric(20,4) Default 0,
			)
		Create Table #Boston2A (
			[Formulation] varchar(255),
			[Score] int,
			[Frequency] int,
			[Fx] int,
			)
		Create Table #Boston2B (
			[Formulation] varchar(255),
			[Score] int,
			[Frequency] int,
			[Fx] int,
			)
		Create Table #Boston3 (
			[Formulation] varchar(255),
			[NoOfProcs] int,
			[MeanScore] Numeric(20,4) Default 0,
			)
		Create Table #Scale (
			[Scale] int,
			)
		Insert Into #Scale ([Scale]) Values (0)
		Insert Into #Scale ([Scale]) Values (1)
		Insert Into #Scale ([Scale]) Values (2)
		Insert Into #Scale ([Scale]) Values (3)
		Insert Into #Scale ([Scale]) Values (99)
		Create Table #Score (
			[Score] int,
			)
		Insert Into #Score ([Score]) Values (0)
		Insert Into #Score ([Score]) Values (1)
		Insert Into #Score ([Score]) Values (2)
		Insert Into #Score ([Score]) Values (3)
		Insert Into #Score ([Score]) Values (4)
		Insert Into #Score ([Score]) Values (5)
		Insert Into #Score ([Score]) Values (6)
		Insert Into #Score ([Score]) Values (7)
		Insert Into #Score ([Score]) Values (8)
		Insert Into #Score ([Score]) Values (9)
		/*Fill #Boston1 with empty rows*/
		Insert Into #Boston1A ([Formulation], [Scale], [Right], [RightP], [Transverse], [TransverseP], [Left], [LeftP])
		Select 
			List.ListItemText As [Formulation], 
			[Scale]=[Scale],
			[Right]=0,
			[RightP]=0,
			[Transverse]=0,
			[TransverseP]=0,
			[Left]=0,
			[LeftP]=0
		From 
			[dbo].[ERS_Lists] List
			, #Scale
		Where list.ListDescription='Bowel_Preparation' And Suppressed=0
		Order By 1
		/*Fill #Boston0 with the real data*/
		Insert Into #Boston0A ([Formulation], [Scale],[Right], [Transverse], [Left])
			Select List.ListItemText As [Formulation], 1 As [Scale],
				IsNull(Sum(Case [OnRight] When 1 Then 1 Else 0 End),0) As [Right], 
				IsNull(Sum(Case [OnTransverse] When 1 Then 1 Else 0 End),0) As [Transverse], 
				IsNull(Sum(Case [OnLeft] When 1 Then 1 Else 0 End),0) As [Left] 
				From v_rep_BowelPreparation B, [dbo].[ERS_Lists] List
			Where List.ListItemNo=B.OnFormulation And CreatedOn>=@From And CreatedOn<=@To
			Group By List.ListItemText
		Insert Into #Boston0A ([Formulation], [Scale],[Right], [Transverse], [Left])
			Select List.ListItemText As [Formulation], 2 As [Scale],
				IsNull(Sum(Case [OnRight] When 2 Then 1 Else 0 End),0) As [Right], 
				IsNull(Sum(Case [OnTransverse] When 2 Then 1 Else 0 End),0) As [Transverse], 
				IsNull(Sum(Case [OnLeft] When 2 Then 1 Else 0 End),0) As [Left] 
				From v_rep_BowelPreparation B, [dbo].[ERS_Lists] List
			Where List.ListItemNo=B.OnFormulation And CreatedOn>=@From And CreatedOn<=@To
			Group By List.ListItemText
		Insert Into #Boston0A ([Formulation], [Scale],[Right], [Transverse], [Left])
			Select List.ListItemText As [Formulation], 3 As [Scale],
				IsNull(Sum(Case [OnRight] When 3 Then 1 Else 0 End),0) As [Right], 
				IsNull(Sum(Case [OnTransverse] When 3 Then 1 Else 0 End),0) As [Transverse], 
				IsNull(Sum(Case [OnLeft] When 3 Then 1 Else 0 End),0) As [Left] 
				From v_rep_BowelPreparation B, [dbo].[ERS_Lists] List
			Where List.ListItemNo=B.OnFormulation And CreatedOn>=@From And CreatedOn<=@To
			Group By List.ListItemText
		/*Calculating the subtotals of every scale for every position*/
		Insert Into #Boston0B ([Formulation], [Right], [Transverse], [Left])
			Select [Formulation], Sum([Transverse]) As [Right], Sum([Transverse]) As [Transverse], Sum ([Left]) As [Left] From #Boston0A
			Group By [Formulation]
		/*Normalizing figures*/
		Insert Into #Boston1B ([Formulation], [Scale], [Right], [RightP], [Transverse], [TransverseP], [Left], [LeftP])
			Select A.Formulation, A.[Scale] As [Scale]
				, A.[Right] As [Right], A.[Right]/Case B.[Right] When 0 Then 1 Else B.[Right] End As [RightP]
				, A.[Transverse] As [Transverse], A.[Transverse]/Case B.[Transverse] When 0 Then 1 Else B.[Transverse] End As [TransverseP]
				, A.[Left] As [Left], A.[Left]/Case B.[Left] When 0 Then 1 Else B.[Left] End As [LeftP]
			From #Boston0A A, #Boston0B B Where A.Formulation=B.Formulation
		/*Update #boston1A From #Boston1B*/
		/*Merging #boston1A From #Boston1B*/
		Update #Boston1A Set [Right]=B.[Right], [RightP]=B.[RightP], [Transverse]=B.[Transverse], [TransverseP]=B.[TransverseP], [Left]=B.[Left], [LeftP]=B.[LeftP] From #Boston1A A, #Boston1B B Where A.[Formulation]=B.[Formulation] And A.[Scale]=B.[Scale]
		/*Filling frecuencies table*/
		Insert Into #Boston2A (Formulation, Score, Frequency, Fx)
		Select List.ListItemText As [Formulation], S.Score, 0 As [Frequency], 0 As [Fx] From [dbo].[ERS_Lists] List, #Score S Where list.ListDescription='Bowel_Preparation' And Suppressed=0
		/*Calculating frecuencies*/
		Insert Into #Boston2B (Formulation, Score, Frequency, Fx)
		Select List.ListItemText As [Formulation],
			B.[OnRight]+B.[OnTransverse]+B.[OnLeft] As [Scale] , Count(*), (B.[OnRight]+B.[OnTransverse]+B.[OnLeft])*Count(*) As Fx
			From v_rep_BowelPreparation B, [dbo].[ERS_Lists] List
		Where List.ListItemNo=B.OnFormulation And list.ListDescription='Bowel_Preparation' And Suppressed=0 And (B.[OnRight]+B.[OnTransverse]+B.[OnLeft])>0 And CreatedOn>=@From And CreatedOn<=@To
		Group By List.ListItemText, B.[OnRight]+B.[OnTransverse]+B.[OnLeft]
		/*Merging #boston2A From #Boston2B*/
		Update #Boston2A Set Frequency=B.Frequency, Fx=B.FX From #Boston2A A, #Boston2B B Where A.[Formulation]=B.[Formulation] And A.[Score]=B.[Score]
		/*Calculating the Means of Scores*/
		Insert Into #Boston3 (Formulation, NoOfProcs, MeanScore)
			Select [Formulation],IsNull(Sum(Frequency),.0) As NoOfProcs, IsNull(Sum(Fx),.0)
			/Case When IsNull(Sum(Frequency),1.0)=0 Then 1 Else IsNull(Sum(Frequency),1.0) End As MeanScore From #Boston2A 
			Group By [Formulation]-- Having Sum(Frequency)>0
		/*Cleanning the user's data*/
		Delete ERS_ReportBoston3 Where UserID=@UserID
		Delete ERS_ReportBoston2 Where UserID=@UserID
		Delete ERS_ReportBoston1 Where UserID=@UserID
		/*Inserting results into User's tables*/
		Insert Into ERS_ReportBoston1 (UserID, Formulation, Scale, [Right], [RightP], [Transverse], [transverseP], [Left], [LeftP])
			Select UserID=@UserID, Formulation, Scale, [Right], [RightP], [Transverse], [transverseP], [Left], [LeftP] From #Boston1A
		Insert Into ERS_ReportBoston2 (UserID, Formulation, Score, Frequency, FX)
			Select UserID=@UserID, Formulation, Score, Frequency, FX From #Boston2A
		Insert Into ERS_ReportBoston3 (UserID, Formulation, NoOfProcs, MeanScore)
			Select UserID=@UserID, Formulation, NoOfProcs, MeanScore From #Boston3
	End
End
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'report_JAGBPS', 'S';
GO

Create Proc [dbo].[report_JAGBPS] @UserID INT=NULL As
Begin
	Select BP.Formulation As ListItemText, Sum(BP.OffQualityGood) As Good
	, 1.0*Sum(BP.OffQualityGood)/Sum(BP.OffQualityGood+BP.OffQualitySatisfactory+BP.OffQualityPoor) As GoodP
	, Sum(BP.OffQualitySatisfactory) As Satisfactory
	, 1.0*Sum(BP.OffQualitySatisfactory)/Sum(BP.OffQualityGood+BP.OffQualitySatisfactory+BP.OffQualityPoor) As SatisfactoryP
	, Sum(BP.OffQualityPoor) As Poor
	, 1.0*Sum(BP.OffQualityPoor)/Sum(BP.OffQualityGood+BP.OffQualitySatisfactory+BP.OffQualityPoor) As PoorP
	From fw_BowelPreparation BP, fw_Procedures PR, fw_ReportFilter RF
	Where BP.ProcedureId=PR.ProcedureId 
	And ((PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) OR 1 = (CASE WHEN 1 = 1 THEN 1 ELSE 0 END))
	And RF.UserId=IsNull(@UserId,0)
	Group By BP.Formulation
End
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'report_JAGERC', 'S';
GO

Create Proc [dbo].[report_JAGERC] @UserID INT=NULL As
Begin
	Declare @ProcedureTypeId INT
	Set @ProcedureTypeId=2
	Select 
			RC.AnonimizedID
		, '<div title=""'+C.ConsultantName+'"">'+Convert(varchar(10),RC.AnonimizedID)+'</div>' As Endoscopist1
		,	RC.ConsultantId As ReportID,C.ConsultantName As Consultant
		, ' ' As [IndependentDirectlySupervisedTraineeDistantSupervisionTrainee]
		, (Select Count(Distinct PR.ProcedureId) From fw_Procedures PR Where PR.ProcedureTypeId=@ProcedureTypeId and PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)) As [NumberOfProcedures]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Midazolam' and PM.procedureId=PR.ProcedureId And Age<=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanSedationRateLT70Years_Midazolam]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Midazolam' and PM.procedureId=PR.ProcedureId And Age>=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanSedationRateGE70Years_Midazolam]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Pethidine' and PM.procedureId=PR.ProcedureId And Age<=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanAnalgesiaRateLT70Years_Pethidine]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Pethidine' and PM.procedureId=PR.ProcedureId And Age>=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanAnalgesiaRateGE70Years_Pethidine]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Fentanyl' and PM.procedureId=PR.ProcedureId And Age<=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanAnalgesiaRateLT70Years_Fentanyl]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Fentanyl' and PM.procedureId=PR.ProcedureId And Age>=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanAnalgesiaRateGE70Years_Fentanyl]
		, ' ' As [ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN]
		, Convert(Numeric(20,4),(Select Count(*) From fw_Procedures PR, fw_QA QA Where PR.ProcedureId=QA.ProcedureId And QA.NursesAssPatComfortScore>4 And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))/((Select Count(*) From fw_Procedures PR, fw_QA QA Where PR.ProcedureId=QA.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))+0.0000001)) As [ComfortScoreGT4P]
		, IsNull((Select 1.0-1.0*Sum(Convert(INT,Fails))/Case When Count(Fails)=0 Then 1 Else Count(Fails) End From fw_FailuresERCP F, fw_Sites S, fw_Procedures PR Where F.SiteId=S.SiteId And S.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)),0) AS Completion_of_Intended_Therapeutic_ERCP_Rate_P
		, IsNull((Select 1.0-1.0*Sum(Case When F.DecompSuccess='TRUE' Then 1 Else 0 End)/Case When Count(F.DecompSuccess)=0 Then 1 Else Count(F.DecompSuccess) End From fw_FailuresERCP F, fw_Sites S , fw_Procedures PR Where F.SiteId=S.SiteId And S.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)),0) AS [Decompression_of_Obstructed_Ducts_Success_Rate_P]
		, IsNull((Select 1.0-1.0*Sum(Case When F.DecompSuccess='TRUE' Then 1 Else 0 End)/Case When Count(F.DecompUnsuccess)=0 Then 1 Else Count(F.DecompSuccess) End From fw_FailuresERCP F, fw_Sites S , fw_Procedures PR Where F.SiteId=S.SiteId And S.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)),0) AS [Decompression_of_Obstructed_Ducts_Unsuccessful_Rate_P]
		, IsNull((Select 1.0-1.0*Sum(Case When F.DecompSuccess='TRUE' Then 1 Else 0 End)/Case When Count(F.DecompUnknow)=0 Then 1 Else Count(F.DecompSuccess) End From fw_FailuresERCP F, fw_Sites S , fw_Procedures PR Where F.SiteId=S.SiteId And S.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)),0) AS [Decompression_of_Obstructed_Ducts_Unknown_Rate_P]
		, ' ' As [Comments_ActionTaken] 
	From 
		fw_Consultants C
		, fw_ReportFilter RF
		, fw_ReportConsultants RC 
	Where 
		C.ConsultantId=RC.ConsultantID And RF.UserID=RC.UserID And RF.UserID=IsNull(@UserID,0)
	Order By 1
End
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'report_JAGSIG', 'S';
GO

Create Proc [dbo].[report_JAGSIG] @UserID INT=NULL As
Begin
	Declare @ProcedureTypeId INT
	Set @ProcedureTypeId=4
	IF @UserID Is Null Set @UserID=0
	Select
		RC.AnonimizedID
		, '<div title=""'+C.ConsultantName+'"">'+Convert(varchar(10),RC.AnonimizedID)+'</div>' As Endoscopist1
		, RC.ConsultantID As ReportID
		, C.ConsultantName As Consultant
		,' ' As [IndependentDirectlySupervisedTraineeDistantSupervisionTrainee]
		, (Select Count(Distinct PR.ProcedureId) From fw_Procedures PR Where PR.ProcedureTypeId=@ProcedureTypeId and PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)) As [NumberOfProcedures]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Midazolam' and PM.procedureId=PR.ProcedureId And Age<=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanSedationRateLT70Years_Midazolam]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Midazolam' and PM.procedureId=PR.ProcedureId And Age>=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanSedationRateGE70Years_Midazolam]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Pethidine' and PM.procedureId=PR.ProcedureId And Age<=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanAnalgesiaRateLT70Years_Pethidine]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Pethidine' and PM.procedureId=PR.ProcedureId And Age>=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanAnalgesiaRateGE70Years_Pethidine]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Fentanyl' and PM.procedureId=PR.ProcedureId And Age<=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanAnalgesiaRateLT70Years_Fentanyl]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Fentanyl' and PM.procedureId=PR.ProcedureId And Age>=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanAnalgesiaRateGE70Years_Fentanyl]
		, ' ' As [ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN]
		, Convert(Numeric(20,4),(Select Count(*) From fw_Procedures PR, fw_QA QA Where PR.ProcedureId=QA.ProcedureId And QA.NursesAssPatComfortScore>4 And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))/((Select Count(*) From fw_Procedures PR, fw_QA QA Where PR.ProcedureId=QA.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))+0.0000001)) As [ComfortScoreGT4P]
		,	' ' As [Identification_and_position_of_colonic_tumours]
		, Convert(Numeric(20,4),(Select Count(*) From fw_Lesions L, fw_Sites S, fw_Procedures PR
			Where --L.LesionType IN ('Sessile','Peduncular') And
				S.SiteId=L.SiteId And PR.ProcedureId=S.ProcedureId
			 And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)
			)/((Select Count(Distinct PR.ProcedureId) From fw_Procedures PR Where PR.ProcedureTypeId=@ProcedureTypeId and PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))+0.00000001))
			As [Polyps_detection_rate_P]
		, Convert(Numeric(20,4),(Select Count(*) From fw_Lesions L, fw_Sites S, fw_Procedures PR
			Where --L.LesionType IN ('Sessile','Peduncular') And 
			L.Retrieved<>0
			And S.SiteId=L.SiteId And PR.ProcedureId=S.ProcedureId
			 And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)
			)/((Select Count(Distinct PR.ProcedureId) From fw_Procedures PR Where PR.ProcedureTypeId=@ProcedureTypeId and PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))+0.00000001))
			 As [Polyps_retrieval_rate_P]
		, ' ' As [Comments_ActionTaken] 
	From 
		fw_ReportConsultants RC, fw_Consultants C, fw_ReportFilter RF Where RF.UserId=RC.UserId And RF.UserId=IsNull(@UserId,0) And RC.ConsultantId=C.ConsultantId
	Order By 1
End
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'report_JAGCOL', 'S';
GO

Create Proc [dbo].[report_JAGCOL] @UserID INT=NULL As
Begin
	Declare @ProcedureTypeId INT
	Set @ProcedureTypeId=3
	Select
		RC.AnonimizedID
		, '<div title=""'+C.ConsultantName+'"">'+Convert(varchar(10),RC.AnonimizedID)+'</div>' As Endoscopist1
		, RC.ConsultantID As ReportID
		, C.ConsultantName As Consultant
		,' ' As [IndependentDirectlySupervisedTraineeDistantSupervisionTrainee]
		, (Select Count(Distinct PR.ProcedureId) From fw_Procedures PR Where PR.ProcedureTypeId=@ProcedureTypeId and PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)) As [NumberOfProcedures]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Midazolam' and PM.procedureId=PR.ProcedureId And Age<=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanSedationRateLT70Years_Midazolam]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Midazolam' and PM.procedureId=PR.ProcedureId And Age>=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanSedationRateGE70Years_Midazolam]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Pethidine' and PM.procedureId=PR.ProcedureId And Age<=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanAnalgesiaRateLT70Years_Pethidine]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Pethidine' and PM.procedureId=PR.ProcedureId And Age>=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanAnalgesiaRateGE70Years_Pethidine]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Fentanyl' and PM.procedureId=PR.ProcedureId And Age<=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanAnalgesiaRateLT70Years_Fentanyl]
		, (Select IsNull(Avg(Dose),0) From fw_Premedication PM, fw_Procedures PR Where PM.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) And PM.DrugName='Fentanyl' and PM.procedureId=PR.ProcedureId And Age>=70 And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate) As [MeanAnalgesiaRateGE70Years_Fentanyl]
		,	' ' As [ConcernsRegardingHighDosesOfSedationOrAnalgesiaYN]
		, Convert(Numeric(20,4),(Select Count(*) From fw_Procedures PR, fw_QA QA Where PR.ProcedureId=QA.ProcedureId And QA.NursesAssPatComfortScore>4 And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))/((Select Count(*) From fw_Procedures PR, fw_QA QA Where PR.ProcedureId=QA.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))+0.0000001)) As [ComfortScoreGT4P]
		, Convert(Numeric(20,4),(Select Count(I.Insertion) From fw_ColonExtentOfIntubation I, fw_Procedures PR
			Where I.ProcedureId=PR.ProcedureId And I.Insertion<>0 And I.InsertionFailed<>1
			And PR.ProcedureTypeId=@ProcedureTypeId and PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))/
			Case When (Select Count(I.Insertion) From fw_ColonExtentOfIntubation I, fw_Procedures PR
			Where I.ProcedureId=PR.ProcedureId And I.Insertion<>0
			And PR.ProcedureTypeId=@ProcedureTypeId and PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))=0 Then 1 Else 
			Convert(Numeric(20,4),(Select Count(I.Insertion) From fw_ColonExtentOfIntubation I, fw_Procedures PR
			Where I.ProcedureId=PR.ProcedureId And I.Insertion<>0
			And PR.ProcedureTypeId=@ProcedureTypeId and PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))) End )
		 As [Colonoscopy_Completion_Rate]
		, Convert(Numeric(20,4),(Select Count(*) From fw_Lesions L, fw_Sites S, fw_Procedures PR
			Where --L.LesionType IN ('Sessile','Peduncular') And 
				S.SiteId=L.SiteId And PR.ProcedureId=S.ProcedureId
			 And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)
			)/((Select Count(Distinct PR.ProcedureId) From fw_Procedures PR Where PR.ProcedureTypeId=@ProcedureTypeId and PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))+0.00000001))
			As [Polyps_detection_rate_P]
		, Convert(Numeric(20,4),(Select Count(*) From fw_Lesions L, fw_Sites S, fw_Procedures PR
			Where --L.LesionType IN ('Sessile','Peduncular') And 
			L.Retrieved<>0 And S.SiteId=L.SiteId And PR.ProcedureId=S.ProcedureId
			 And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)
			)/((Select Count(Distinct PR.ProcedureId) From fw_Procedures PR Where PR.ProcedureTypeId=@ProcedureTypeId and PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))+0.00000001))
			 As [Polyps_retrieval_rate_P]
		, ' ' As [Comments_ActionTaken] 
	From 
		fw_ReportConsultants RC, fw_Consultants C, fw_ReportFilter RF Where RF.UserId=RC.UserId And RF.UserId=IsNull(@UserId,0) And RC.ConsultantId=C.ConsultantId
	Order By 1
End
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'report_JAGPEG', 'S';
GO

Create Proc [dbo].[report_JAGPEG] @UserID INT=NULL As
Begin
	Declare @ProcedureTypeId INT
	Set @ProcedureTypeId=1
	Select RC.AnonimizedID
	, '<div title=""'+C.ConsultantName+'"">'+Convert(varchar(10),RC.AnonimizedID)+'</div>' As Endoscopist1
	, C.ConsultantId As ReportID
	, C.ConsultantName As Consultant
	, (Select Count(*) From fw_Insertions I, fw_Sites S, fw_Procedures PR Where S.SiteId=I.SiteId And S.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)) As [Number_of_PEG_PEJ_procedures]
	, (Case When (Select Count(*) From fw_Insertions I, fw_Sites S, fw_Procedures PR Where S.SiteId=I.SiteId And S.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))=0 Then 0 Else 1.0*(Select Sum(I.Correct_Placement) From fw_Insertions I, fw_Sites S, fw_Procedures PR Where S.SiteId=I.SiteId And S.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))/(Select Count(*) From fw_Insertions I, fw_Sites S, fw_Procedures PR Where S.SiteId=I.SiteId And S.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)) End) As [Satisfactory_placement_of_PEG_PEJ]
	, (Case When (Select Count(*) From fw_Insertions I, fw_Sites S, fw_Procedures PR Where S.SiteId=I.SiteId And S.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))=0 Then 0 Else 1.0*(Select Sum(I.Incorrect_Placement) From fw_Insertions I, fw_Sites S, fw_Procedures PR Where S.SiteId=I.SiteId And S.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate))/(Select Count(*) From fw_Insertions I, fw_Sites S, fw_Procedures PR Where S.SiteId=I.SiteId And S.ProcedureId=PR.ProcedureId And PR.ProcedureTypeId=@ProcedureTypeId And PR.ProcedureId In (Select PC.ProcedureId From fw_ProceduresConsultants PC Where PR.ProcedureId=PC.ProcedureId And PC.ConsultantId=RC.ConsultantId And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate)) End) As [Failed_PEG_PEJ_placement]
	, ' ' As [Comments_ActionTaken]
	From 
		fw_ReportConsultants RC, fw_Consultants C, fw_ReportFilter RF Where RF.UserId=IsNull(@UserId,0) And RC.ConsultantId=C.ConsultantId And RC.UserId=RF.UserId
	Order By 1
End
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'report_JAGOGD', 'S';
GO

Create Proc [dbo].[report_JAGOGD] @UserID INT=NULL As
Begin
	Declare @ProcedureTypeId INT
	Set @ProcedureTypeId=1
	Select 
		RC.AnonimizedID
		, '<div title=""'+C.ConsultantName+'"">'+Convert(varchar(10),RC.AnonimizedID)+'</div>' As Endoscopist1
		, RC.ConsultantID As ReportID
		, C.ConsultantName As Consultant
		, ' ' As [IndependentDirectlySupervisedTraineeDistantSupervisionTrainee]
		, Count(Distinct L2.ProcedureId) As [NumberOfProcedures]
		, Avg(L2.D1) As [MeanSedationRateLT70Years_Midazolam]
		, Avg(L2.D2) As [MeanSedationRateGE70Years_Midazolam]
		, Avg(L2.D3) As [MeanAnalgesiaRateLT70Years_Pethidine]
		, Avg(L2.D4) As [MeanAnalgesiaRateGE70Years_Pethidine]
		, Avg(L2.D5) As [MeanAnalgesiaRateLT70Years_Fentanyl]
		, Avg(L2.D6) As [MeanAnalgesiaRateGT70Years_Fentanyl]
		, Case When Count(Distinct L2.ProcedureId)=0 Then 0 Else Sum(L2.PatScore)*1.0/Count(Distinct L2.ProcedureId) End As PatScore
		, Case When Avg(L2.Placements)=0 Then 0 Else Avg(L2.CorrectPlacement) End As SuccesfullProcedureCompletionP
		, Case When Avg(L2.Placements)=0 Then 0 Else Avg(L2.IncorrectPlacement) End As [FailedProcedureCompletionP]
		, Avg(L2.Placements) As [Repeat12Weeks]
	 From fw_ReportConsultants RC
		INNER JOIN fw_Consultants C ON RC.ConsultantId=C.ConsultantId And RC.UserId=@UserId
		LEFT OUTER JOIN fw_ProceduresConsultants PC ON C.ConsultantId=PC.ConsultantId
		LEFT OUTER JOIN 
	 (
	 Select L1.ProcedureId
		, Avg(L1.D1) As D1
		, Avg(L1.D2) As D2
		, Avg(L1.D3) As D3
		, Avg(L1.D4) As D4
		, Avg(L1.D5) As D5
		, Avg(L1.D6) As D6
		, L1.PatScore
		, IsNull(Sum(L1.CorrectPlacement),0) As CorrectPlacement
		, IsNull(Sum(L1.IncorrectPlacement),0) As IncorrectPlacement
		, IsNull(Sum(L1.Placements),0) As Placements
		, IsNull(Sum(L1.RepeatOGD),0) As [Repeat12Weeks]
	 From 
	 (
		 Select 
			PR.ProcedureId
			, Case When PM.DrugName='Midazolam' Then Case When PR.Age<70 Then PM.Dose Else 0 End Else 0 End As D1
			, Case When PM.DrugName='Midazolam' Then Case When PR.Age>=70 Then PM.Dose Else 0 End Else 0 End As D2
			, Case When PM.DrugName='Pethidine' Then Case When PR.Age<70 Then PM.Dose Else 0 End Else 0 End As D3
			, Case When PM.DrugName='Pethidine' Then Case When PR.Age>=70 Then PM.Dose Else 0 End Else 0 End As D4
			, Case When PM.DrugName='Fentanyl' Then Case When PR.Age<70 Then PM.Dose Else 0 End Else 0 End As D5
			, Case When PM.DrugName='Fentanyl' Then Case When PR.Age>=70 Then PM.Dose Else 0 End Else 0 End As D6
			, Case When QA.NursesAssPatComfortScore>4 Then 1 Else 0 End As PatScore
			, IsNull(PL.CorrectPlacement,0) As CorrectPlacement
			, IsNull(PL.IncorrectPlacement,0) As IncorrectPlacement
			, IsNull(PL.Placements,0) As Placements
			, Case When RO.SiteId Is Not Null Then 1 Else 0 End As RepeatOGD
		 From 
		 (
 			Select 
				Distinct PR.ProcedureId, PR.Age
			From fw_ReportConsultants RC
				INNER JOIN fw_Consultants C ON RC.ConsultantId=C.ConsultantId
				INNER JOIN fw_ProceduresConsultants PC ON C.ConsultantId=PC.ConsultantId
				INNER JOIN fw_Procedures PR ON PC.ProcedureId=PC.ProcedureId
				INNER JOIN fw_ReportFilter RF ON RC.UserId=RF.UserID And RF.FromDate<=PR.CreatedOn And RF.ToDate>=PR.CreatedOn
			Where RF.UserId=@UserId And PR.ProcedureTypeId=@ProcedureTypeId
		) As PR
		LEFT OUTER JOIN fw_QA QA ON PR.ProcedureId=QA.ProcedureId
		LEFT OUTER JOIN fw_Sites S ON PR.ProcedureId=S.ProcedureId
		LEFT OUTER JOIN fw_Placements PL ON S.SiteId=PL.SiteId
		LEFT OUTER JOIN fw_RepeatOGD RO ON S.SiteId=RO.SiteId
		LEFT OUTER JOIN fw_Premedication PM ON PR.ProcedureId=PM.ProcedureId
	) As L1
	Group By L1.ProcedureId
		, L1.D1
		, L1.D2
		, L1.D3
		, L1.D4
		, L1.D5
		, L1.D6
		, L1.PatScore
	) As L2 ON PC.ProcedureId=L2.ProcedureId
	Group By 
		RC.AnonimizedID
		,C.ConsultantName
		, RC.ConsultantID
End
GO

---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSA01', 'S';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create Proc [dbo].[sp_rep_GRSA01] @UserID INT=NULL As
Begin
	SET NOCOUNT ON
	If @UserID Is Null 
	Begin
		Raiserror(''The @UserID parameter is missing a value'',11,1)
		PRINT ''Sintax:''
		Print ''	Exec sp_rep_GRSA01 1 @UserID=[UserID]''
		Print ''	[UserID]: Session Value of PKUserId''
		Set @UserID=0
	End
	Select Patient.[HospitalNumber] As CaseNoteNo, Patient.[Surname]+'', ''+Patient.[Forename1] As [PatientName], 
		Convert(date,P.[Procedure date]) As CreatedOn,
		C.Consultant,
		I.[Altered bowel habit] As ABH, 
		L.ListItemText As [DiarrhoeaIndications],
		P.[Procedure type] As PT, ''UGI'' As Release
	From [dbo].[Colon Indications] I
		, [dbo].[Colon Procedure] P
		, ERS_VW_Patients Patient
		, v_rep_Consultants C
		,[ERS_ReportFilter] F, [ERS_ReportConsultants] RC
		, ERS_Lists L
	Where I.[Episode No]=P.[Episode No] And I.[Patient No]=P.[Patient No]
		And Patient.[UGIPatientId]=Convert(int,SubString(P.[Patient No],7,6))
		And P.[Procedure date]>=F.FromDate And P.[Procedure date]<=F.ToDate
		And F.UserID=RC.UserID 
		And C.ReportID=RC.ConsultantID
		And F.UserID=@UserID
		And Convert(int,SubString(P.Endoscopist1,7,6))=C.UGIID
		And I.[Altered bowel habit]<>0
		And I.[Altered bowel habit]=L.ListItemNo
		And ListDescription=''Indications Colon Altered Bowel Habit''
	Union
	Select Patient.[HospitalNumber] As CaseNoteNo, Patient.[Surname]+'', ''+Patient.[Forename1] As [PatientName], 
		Convert(date,P.CreatedOn) As CreatedOn, 
		C.Consultant,
		I.ColonAlterBowelHabit As ABH, 
		L.ListItemText As [DiarrhoeaIndications],
		P.ProcedureType As PT, ''ERS'' As Release From [dbo].[ERS_UpperGIIndications] I
		, [dbo].[ERS_Procedures] P
		, ERS_VW_Patients Patient
		, v_rep_Consultants C
		,[ERS_ReportFilter] F, [ERS_ReportConsultants] RC
		, ERS_Lists L
	Where I.ProcedureId=P.ProcedureId
		And Patient.[PatientId]=P.PatientId
		And P.CreatedOn>=F.FromDate And P.CreatedOn<=F.ToDate
		And F.UserID=RC.UserID 
		And C.ReportID=RC.ConsultantID
		And F.UserID=@UserID
		And P.Endoscopist1=C.ERSID
		And I.ColonAlterBowelHabit<>0
		And I.ColonAlterBowelHabit=L.ListItemNo
		And ListDescription=''Indications Colon Altered Bowel Habit''
End
'
END
ELSE
BEGIN
	SET @sql = '
Create Proc [dbo].[sp_rep_GRSA01] @UserID INT=NULL As
Begin
	SET NOCOUNT ON
	If @UserID Is Null 
	Begin
		Raiserror(''The @UserID parameter is missing a value'',11,1)
		PRINT ''Sintax:''
		Print ''	Exec sp_rep_GRSA01 1 @UserID=[UserID]''
		Print ''	[UserID]: Session Value of PKUserId''
		Set @UserID=0
	End
	Select Patient.[HospitalNumber] As CaseNoteNo, Patient.[Surname]+'', ''+Patient.[Forename1] As [PatientName], 
		Convert(date,P.CreatedOn) As CreatedOn, 
		C.Consultant,
		I.ColonAlterBowelHabit As ABH, 
		L.ListItemText As [DiarrhoeaIndications],
		P.ProcedureType As PT, ''ERS'' As Release From [dbo].[ERS_UpperGIIndications] I
		, [dbo].[ERS_Procedures] P
		, ERS_VW_Patients Patient
		, v_rep_Consultants C
		,[ERS_ReportFilter] F, [ERS_ReportConsultants] RC
		, ERS_Lists L
	Where I.ProcedureId=P.ProcedureId
		And Patient.[PatientId]=P.PatientId
		And P.CreatedOn>=F.FromDate And P.CreatedOn<=F.ToDate
		And F.UserID=RC.UserID 
		And C.ReportID=RC.ConsultantID
		And F.UserID=@UserID
		And P.Endoscopist1=C.ERSID
		And I.ColonAlterBowelHabit<>0
		And I.ColonAlterBowelHabit=L.ListItemNo
		And ListDescription=''Indications Colon Altered Bowel Habit''
End
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSA02', 'S';
GO

Create Proc [dbo].[sp_rep_GRSA02] @UserID INT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @OGD BIT=NULL, @COLSIG BIT=NULL As
Begin
	SET NOCOUNT ON
	Declare @Errors INT
	Set @Errors=0
	If @UserID Is Null 
	Begin
		Raiserror('The @UserID parameter is missing a value',11,1)
		Set @UserID=0
		Set @Errors=@Errors+1
	End	
	If @Endoscopist1 Is Null And @Endoscopist2 Is Null
	Begin
		Raiserror('You must pass at least on of these parameters: @Endoscopist1 or @Endoscopist2',11,1)
		Set @UserID=0
		Set @Errors=@Errors+1
	End		
	Set @Endoscopist1=IsNull(@Endoscopist1,0)
	Set @Endoscopist2=IsNull(@Endoscopist2,0)
	If @OGD Is NULL And @COLSIG Is Null
	Begin
		Raiserror('You must pass at least on of these parameters: @OGD or @COLSIG',11,1)
	End	
	Set @OGD=IsNull(@OGD,0)
	Set @COLSIG=IsNull(@COLSIG,0)
	If @Errors>0
	Begin
		PRINT 'Sintax:'
		Print '	Exec sp_rep_GRSA02 @UserID=[UserID], @Endoscopist1=[TRUE/FALSE][1/0], @Endoscopist2=[TRUE/FALSE][1/0], @OGD=[TRUE/FALSE][1/0], @COLSIG=[TRUE/FALSE][1/0]'
		Print '	[UserID]: Session Value of PKUserId'
		Set @UserID=0
		Set @Errors=@Errors+1
	End	
	Else
	Begin
		Create Table #GRSA02(Endoscopist1 NVARCHAR(128), [Procedure name] VARCHAR(32), [Date of procedure] DATE, [Case note no] NVARCHAR(64), [Surname] NVARCHAR(128), [Forename] NVARCHAR(128), [Age at procedure] INT, [List consultant] NVARCHAR(128), [Endoscopist2] NVARCHAR(128), [Haematemesis] VARCHAR(64), [Melaena] VARCHAR(64), [Rectal bleeding] VARCHAR(64), [Cancer] VARCHAR(64), [Therapeutic procedures] NVARCHAR(4000), [Leading to haemostasis] NVARCHAR(4000))
		Insert Into #GRSA02 (Endoscopist1, [Procedure name], [Date of procedure], [Case note no], [Surname], [Forename], [Age at procedure], [List consultant], [Endoscopist2], [Haematemesis], [Melaena], [Rectal bleeding], [Cancer], [Therapeutic procedures], [Leading to haemostasis])
		Select Endoscopist1, ProcType As 'Procedure name', CreatedOn As 'Date of procedure', [Case note no], Surname, Forename, Age As 'Age at procedure', Endoscopist2 As 'List consultant', Endoscopist2, Haematemesis, Melaena, ColonRectalBleeding As 'Rectal bleeding', Cancer, TPP_Therapies As 'Therapeutic procedures', PP_Therapies As 'Leading to haemostasis' 
		From v_rep_GRSA02 R, v_rep_Consultants C, ERS_ReportConsultants RC, ERS_ReportFilter RF
		Where (R.Endoscopist1=C.Consultant or R.Endoscopist2=C.Consultant) And R.Release=C.Release
		And (RC.ConsultantID=C.ReportID)
		And RC.UserID=RF.UserID And RF.UserID=@UserID
		And R.CreatedOn>=RF.FromDate And R.CreatedOn<=RF.ToDate
		If IsNull(@Endoscopist1,0)=0 Delete #GRSA02 Where Endoscopist1 Is Null
		If IsNull(@Endoscopist2,0)=0 Delete #GRSA02 Where Endoscopist2 Is Null
		If IsNull(@OGD,0)=0 Delete #GRSA02 Where [Procedure name]='Gastroscopy'
		If IsNull(@COLSIG,0)=0 Delete #GRSA02 Where [Procedure name] In ('Colonoscopy','Sigmoidoscopy')
		Select * From #GRSA02 
		Drop Table #GRSA02 -- This line is not necessary but... Is elegant!
	End
End
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSA03', 'S';
GO

Create Proc [dbo].[sp_rep_GRSA03] @UserID INT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @FromAge INT=NULL, @ToAge INT=NULL, @CountOfProcedures BIT=NULL, @ListOfPatients BIT=NULL
	, @OesophagealStent BIT=NULL, @DuodenalStent BIT=NULL, @UnitAsAWhole BIT=NULL, @ColonicStent BIT=NULL, @PEG BIT=NULL, @PEJ BIT=NULL As
Begin
	SET NOCOUNT ON
	If @UserID Is Null 
	Begin
		Raiserror('The @UserID parameter is missing a value',11,1)
		PRINT 'Sintax:'
		Print '	Exec sp_rep_GRSA03 @UserID=[UserID], @Endoscopist1=[1/0, TRUE/FALSE], @Endoscopist2=[1/0, TRUE/FALSE], @FromAge=[Min. Age], @ToAge=[Max. Age], @CountOfProcedures=[1/0, TRUE/FALSE], '
		Print '	@ListOfPatients=[1/0, TRUE/FALSE], @OesophagealStent=[1/0, TRUE/FALSE], @DuodenalStent=[1/0, TRUE/FALSE], '
		Print '	@UnitAsAWhole=[1/0, TRUE/FALSE], @ColonicStent=[1/0, TRUE/FALSE], @PEG=[1/0, TRUE/FALSE], @PEJ=[1/0, TRUE/FALSE]'
		Print '	[UserID]: Session Value of PKUserId'
		Set @UserID=0
	End
	Else
	Begin
		Declare @From DATE
		Declare @To DATE
		If @FromAge Is Null Set @FromAge=0
		If @ToAge Is Null Set @ToAge=200
		Select @From=RF.FromDate, @To=RF.ToDate From ERS_ReportFilter RF Where UserID=@UserID
		If @FromAge Is Null Set @FromAge=0
		If @ToAge Is Null Set @ToAge=200
		If @CountOfProcedures Is Null Set @CountOfProcedures=0
		If @ListOfPatients Is Null Set @ListOfPatients=0
		If @OesophagealStent Is Null Set @OesophagealStent=0
		If @DuodenalStent Is Null Set @DuodenalStent=0
		If @UnitAsAWhole Is Null Set @UnitAsAWhole=0
		If @ColonicStent Is Null Set @ColonicStent=0
		If @PEG Is Null Set @PEG=0
		If @PEJ Is Null Set @PEJ=0
		Create Table #Placements(ID INT, Proctype VARCHAR(3), Placement VARCHAR(50))
		Insert Into #Placements (ID, Proctype, Placement) Values (  1, 'OES', 'Correctly placed')
		Insert Into #Placements (ID, Proctype, Placement) Values (  2, 'OES', 'Placed but not recorded')
		Insert Into #Placements (ID, Proctype, Placement) Values (  3, 'OES', 'Too proximal')
		Insert Into #Placements (ID, Proctype, Placement) Values (  4, 'OES', 'Too distal')
		Insert Into #Placements (ID, Proctype, Placement) Values (  5, 'OES', 'Failed deployment')
		Insert Into #Placements (ID, Proctype, Placement) Values (  6, 'OES', 'Failed but no reason given')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 11, 'DUO', 'Correctly placed')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 12, 'DUO', 'Placed but not recorded')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 13, 'DUO', 'Too proximal')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 14, 'DUO', 'Too distal')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 15, 'DUO', 'Failed deployment')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 16, 'DUO', 'Failed but no reason given')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 21, 'COL', 'Correctly placed')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 22, 'COL', 'Placed but not recorded')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 23, 'COL', 'Too proximal')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 24, 'COL', 'Too distal')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 25, 'COL', 'Failed deployment')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 26, 'COL', 'Failed but no reason given')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 31, 'PEG', 'Correctly placed')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 32, 'PEG', 'Placed but not recorded')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 35, 'PEG', 'Failed deployment')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 36, 'PEG', 'Failed but no reason given')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 41, 'PEJ', 'Correctly placed')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 42, 'PEJ', 'Placed but not recorded')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 45, 'PEJ', 'Failed deployment')
		Insert Into #Placements (ID, Proctype, Placement) Values ( 46, 'PEJ', 'Failed but no reason given')
		Create Table #Array(
			id INT Identity(1,1),
			Consultant NVARCHAR(255),
			ReportID NVARCHAR(20),
			ProcType NVARCHAR(255),
			Placement NVARCHAR(255),
			PlacementN INT,
			PlacementP Numeric(20,4),
			CNN NVARCHAR(50),
			Forename NVARCHAR(128),
			Surname NVARCHAR(128),
			CreatedOn Date,
			SubTypeSort INT,
		)
		Create Table #Data1(
			id INT Identity(1,1),
			Consultant NVARCHAR(255),
			ReportID NVARCHAR(20),
			ProcType NVARCHAR(255),
			Placement NVARCHAR(255),
			PlacementN INT,
			PlacementP Numeric(20,4),
			CNN NVARCHAR(50),
			Forename NVARCHAR(128),
			Surname NVARCHAR(128),
			CreatedOn Date,
			SubTypeSort INT,
			Release VARCHAR(3),
			ProcedureId INT,
			SiteId INT,
		)
		Create Table #Data2(
			id INT Identity(1,1),
			Consultant NVARCHAR(255),
			ReportID NVARCHAR(20),
			ProcType NVARCHAR(255),
			Placement NVARCHAR(255),
			PlacementN INT,
			PlacementP Numeric(20,4),
			CNN NVARCHAR(50),
			Forename NVARCHAR(128),
			Surname NVARCHAR(128),
			CreatedOn Date,
			SubTypeSort INT,
		)
		Create Table #SubTotals(
			id INT Identity(1,1),
			Consultant NVARCHAR(255),
			ReportID NVARCHAR(20),
			ProcType NVARCHAR(255),
			Placement NVARCHAR(255),
			PlacementT Numeric(20,2),
			SubTypeSort INT,
		)
		Declare @Consultant NVARCHAR(128)
		Declare @ProcType VARCHAR(3)
		Declare @Placement NVARCHAR(128)
		Declare @PlacementN INT
		Declare @PlacementP Numeric(20,4)
		Declare @N INT
		-- Fill #Array
		If @UnitAsAWhole=1
		begin
			Insert Into #Array(Consultant, ReportID, ProcType, Placement, PlacementN, PlacementP, SubTypeSort)
			Select Distinct 'The endoscopy unit as a whole' As Consultant, 0 As ReportID, Case PL.ProcType When 'OES' Then 'Oesophageal (following stricture)' When 'DUO' Then 'Duodenal (following stricture)' When 'COL' Then 'Colonic (following stricture)' When 'PEG' Then 'Percutaneous endoscopic gastrost' When 'PEJ' Then 'Percutaneous endoscopic jejunost' Else '' End As Proctype, Pl.Placement, (Select Count(*) From v_rep_StentPositioning SP Where Pl.Proctype=SP.SubType And Pl.Placement=SP.Placement And SP.CreatedOn>=@From And SP.CreatedOn<=@To And SP.Age>=@FromAge And SP.Age<=@ToAge) As PlacementN, Case When (Select Count(*) From v_rep_StentPositioning SP Where Pl.Proctype=SP.SubType And Pl.Placement=SP.Placement And SP.CreatedOn>=@From And SP.CreatedOn<=@To And SP.Age>=@FromAge And SP.Age<=@ToAge)=0 Then 0 Else (Select Count(*) From v_rep_StentPositioning SP Where Pl.Proctype=SP.SubType And Pl.Placement=SP.Placement And SP.CreatedOn>=@From And SP.CreatedOn<=@To And SP.Age>=@FromAge And SP.Age<=@ToAge)/Convert(Numeric(20,4),(Select Count(*) From v_rep_StentPositioning SP Where Pl.Proctype=SP.SubType And SP.CreatedOn>=@From And SP.CreatedOn<=@To And SP.Age>=@FromAge And SP.Age<=@ToAge)) End As PlacementP, PL.ID As SubTypeSort
				From ERS_ReportConsultants RC, #Placements Pl
				Where UserID=@UserID
		End
		Else
		Begin
			Insert Into #Array(Consultant, ReportID, ProcType, Placement, PlacementN, PlacementP, SubTypeSort)
			Select C.Consultant, C.ConsultantID As ReportID, Case PL.ProcType When 'OES' Then 'Oesophageal (following stricture)' When 'DUO' Then 'Duodenal (following stricture)' When 'COL' Then 'Colonic (following stricture)' When 'PEG' Then 'Percutaneous endoscopic gastrost' When 'PEJ' Then 'Percutaneous endoscopic jejunost' Else '' End As Proctype, Pl.Placement, (Select Count(*) From v_rep_StentPositioning SP Where Pl.Proctype=SP.SubType And Pl.Placement=SP.Placement And SP.CreatedOn>=@From And SP.CreatedOn<=@To And SP.Age>=@FromAge And SP.Age<=@ToAge) As PlacementN, Case When (Select Count(*) From v_rep_StentPositioning SP Where Pl.Proctype=SP.SubType And Pl.Placement=SP.Placement And SP.CreatedOn>=@From And SP.CreatedOn<=@To And SP.Age>=@FromAge And SP.Age<=@ToAge)=0 Then 0 Else (Select Count(*) From v_rep_StentPositioning SP Where Pl.Proctype=SP.SubType And Pl.Placement=SP.Placement And SP.CreatedOn>=@From And SP.CreatedOn<=@To And SP.Age>=@FromAge And SP.Age<=@ToAge)/Convert(Numeric(20,4),(Select Count(*) From v_rep_StentPositioning SP Where Pl.Proctype=SP.SubType And SP.CreatedOn>=@From And SP.CreatedOn<=@To And SP.Age>=@FromAge And SP.Age<=@ToAge)) End As PlacementP, PL.ID As SubTypeSort
				From ERS_ReportConsultants RC, #Placements Pl, v_rep_Consultants C
				Where UserID=@UserID And RC.ConsultantID=C.ReportID
		End
		-- Fill #Data1
		If @Endoscopist1=1
		Begin
			Insert Into #Data1(Consultant, ReportID, ProcType, Placement, PlacementN, PlacementP, CNN, Forename, Surname, CreatedOn, SubTypeSort, Release, ProcedureId, SiteId)
				Select C.Consultant As Consultant, C.ReportID As ReportID, ProcType=Case SP.SubType When 'OES' Then 'Oesophageal (following stricture)' When 'DUO' Then 'Duodenal (following stricture)' When 'COL' Then 'Colonic (following stricture)' When 'PEG' Then 'Percutaneous endoscopic gastrost' When 'PEJ' Then 'Percutaneous endoscopic jejunost' Else '' End, 
				SP.Placement, PlacementN=1, PlacementP=.0, SP.CNN As CNN, SP.Forename As Forename, SP.Surname As Surname, SP.CreatedOn As CreatedOn, PL.ID As SubTypeSort, SP.Release, SP.ProcedureId, SP.SiteId
				From v_rep_StentPositioning SP, v_rep_Consultants C, ERS_ReportConsultants RC, ERS_ReportFilter RF, #Placements PL
				Where C.ReportID=SP.Endoscopist1Id And SP.SubType=PL.Proctype And SP.Placement=PL.Placement
					And SP.Age>=@FromAge And SP.Age<=@ToAge And RC.UserID=RF.UserID And RC.ConsultantID=C.ReportID And SP.CreatedOn>=RF.FromDate And SP.CreatedOn<=RF.ToDate
		End
		If @Endoscopist2=1
		Begin
			Insert Into #Data1(Consultant, ReportID, ProcType, Placement, PlacementN, PlacementP, CNN, Forename, Surname, CreatedOn, SubTypeSort, Release, ProcedureId, SiteId)
				Select C.Consultant As Consultant, C.ReportID As ReportID, ProcType=Case SP.SubType When 'OES' Then 'Oesophageal (following stricture)' When 'DUO' Then 'Duodenal (following stricture)' When 'COL' Then 'Colonic (following stricture)' When 'PEG' Then 'Percutaneous endoscopic gastrost' When 'PEJ' Then 'Percutaneous endoscopic jejunost' Else '' End, 
				SP.Placement, PlacementN=1, PlacementP=.0, SP.CNN As CNN, SP.Forename As Forename, SP.Surname As Surname, SP.CreatedOn As CreatedOn, PL.ID As SubTypeSort, SP.Release, SP.ProcedureId, SP.SiteId
				From v_rep_StentPositioning SP, v_rep_Consultants C, ERS_ReportConsultants RC, ERS_ReportFilter RF, #Placements PL
				Where C.ReportID=SP.Endoscopist2Id And SP.SubType=PL.Proctype And SP.Placement=PL.Placement
					And SP.Age>=@FromAge And SP.Age<=@ToAge And RC.UserID=RF.UserID And RC.ConsultantID=C.ReportID And SP.CreatedOn>=RF.FromDate And SP.CreatedOn<=RF.ToDate
		End
		If @UnitAsAWhole=1
		Begin
			Insert Into #Data2(Consultant, ReportID, ProcType, Placement, PlacementN, PlacementP, CNN, Forename, Surname, CreatedOn, SubTypeSort)
				Select 'The endoscopy unit as a whole' As Consultant, 0 As ReportID, ProcType, Placement, PlacementN, PlacementP, CNN, Forename, Surname, CreatedOn, SubTypeSort From #Data1
				Group By ProcType, Placement, PlacementN, PlacementP, CNN, Forename, Surname, CreatedOn, SubTypeSort
		End
		Else
		Begin
			Insert Into #Data2(Consultant, ReportID, ProcType, Placement, PlacementN, PlacementP, CNN, Forename, Surname, CreatedOn, SubTypeSort)
				Select Consultant, ReportID, ProcType, Placement, PlacementN, PlacementP, CNN, Forename, Surname, CreatedOn, SubTypeSort From #Data1
		End
		Drop Table #Data1
		Insert Into #SubTotals (Consultant, ReportID, ProcType, Placement, PlacementT, SubTypeSort)
			Select Consultant, ReportID, ProcType, Placement, Count(*) As PlacementT, SubTypeSort From #Data2
				Group By Consultant, ReportID, ProcType, Placement, SubTypeSort
		Update #Array Set PlacementP=Convert(numeric(20,4),#Array.PlacementN)/B.PlacementT From #SubTotals B Where #Array.ReportID=B.ReportID And #Array.ProcType=B.ProcType
		Drop Table #SubTotals
		Insert Into #Array(Consultant, ReportID, ProcType, Placement, PlacementN, PlacementP, CNN, Forename, Surname, CreatedOn, SubTypeSort)
		Select Consultant, ReportID, ProcType, Placement, PlacementN=0, PlacementP=0, CNN, Forename, Surname, CreatedOn, SubTypeSort From #Data2
		Drop Table #Data2
		If IsNull(@OesophagealStent,0)=0
		Begin
			Delete #Array Where ProcType='Oesophageal (following stricture)'
		End
		If IsNull(@DuodenalStent,0)=0
		Begin
			Delete #Array Where ProcType='Duodenal (following stricture)'
		End
		If IsNull(@ColonicStent,0)=0
		Begin
			Delete #Array Where ProcType='Colonic (following stricture)'
		End
		If IsNull(@PEG,0)=0
		Begin
			Delete #Array Where ProcType='Percutaneous endoscopic gastrost'
		End
		If IsNull(@PEJ,0)=0
		Begin
			Delete #Array Where ProcType='Percutaneous endoscopic jejunost'
		End
		Select * From #Array Order By Consultant, ReportID, SubTypeSort
		Drop Table #Placements
		Drop Table #Array
	End
End
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSA04A', 'S';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create Proc [dbo].[sp_rep_GRSA04A] @UserID INT=NULL, @Summary BIT=NULL As
Begin
	SET NOCOUNT ON
	Declare @FromDate DATE
	Declare @ToDate DATE
	Select @FromDate=FromDate, @ToDate=ToDate From ERS_ReportFilter Where UserID=@UserID
	DECLARE @OGDT INT
	DECLARE @EUST INT
	DECLARE @ERCT INT
	DECLARE @HPBT INT
	DECLARE @SIGT INT
	DECLARE @COLT INT
	DECLARE @OGDD INT
	DECLARE @EUSD INT
	DECLARE @ERCD INT
	DECLARE @HPBD INT
	DECLARE @SIGD INT
	DECLARE @COLD INT
	Create Table #GRSA04T(DrugName VARCHAR(128), OGD INT, EUS INT, ERC INT, HPB INT, SIG INT, COL INT, i INT IDENTITY(1,1) PRIMARY KEY CLUSTERED)
	Create Table #GRSA04TT(DrugName VARCHAR(128), OGD INT, EUS INT, ERC INT, HPB INT, SIG INT, COL INT, i INT IDENTITY(1,1) PRIMARY KEY CLUSTERED)
	Create Table #GRSA04A(DrugName VARCHAR(128), OGD VARCHAR(10), EUS VARCHAR(10), ERC VARCHAR(10), HPB VARCHAR(10), SIG VARCHAR(10), COL VARCHAR(10), i INT IDENTITY(1,1) PRIMARY KEY CLUSTERED)
	If @Summary=1
	Begin
		Insert Into #GRSA04T
		Select 
			''Total procedures performed'' As DrugName,
			Convert(INT,(Select Count(*) From [Upper GI Procedure] Where [Procedure Date]>=@FromDate And [Procedure Date]<=@ToDate)+(Select Count(*) From ERS_Procedures Where ProcedureType=1 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As OGD,
			Convert(INT,(Select Count(*) From [EUS Procedure] Where [Procedure type]=12 And [Procedure Date]>=@FromDate And [Procedure Date]<=@ToDate)+(Select Count(*) From ERS_Procedures Where ProcedureType=6 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As EUS,
			Convert(INT,(Select Count(*) From [ERCP Procedure] Where [Procedure Date]>=@FromDate And [Procedure Date]<=@ToDate)+(Select Count(*) From ERS_Procedures Where ProcedureType=2 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As ERC,
			Convert(INT,(Select Count(*) From [EUS Procedure] Where [Procedure type]=13 And [Procedure Date]>=@FromDate And [Procedure Date]<=@ToDate)+(Select Count(*) From ERS_Procedures Where ProcedureType=7 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As HPB,
			Convert(INT,(Select Count(*) From [Colon Procedure] Where [Procedure type]=1 And [Procedure Date]>=@FromDate And [Procedure Date]<=@ToDate)+(Select Count(*) From ERS_Procedures Where ProcedureType=4 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As SIG,
			Convert(INT,(Select Count(*) From [Colon Procedure] Where [Procedure type]=0 And [Procedure Date]>=@FromDate And [Procedure Date]<=@ToDate)+(Select Count(*) From ERS_Procedures Where ProcedureType=3 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As COL
		Union All
		Select 
			''Total procedures performed'' As DrugName, 
			Convert(INT,(Select Count(*) From ERS_Procedures Where ProcedureType=1 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As OGD,
			Convert(INT,(Select Count(*) From ERS_Procedures Where ProcedureType=6 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As EUS,
			Convert(INT,(Select Count(*) From ERS_Procedures Where ProcedureType=2 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As ERC,
			Convert(INT,(Select Count(*) From ERS_Procedures Where ProcedureType=7 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As HPB,
			Convert(INT,(Select Count(*) From ERS_Procedures Where ProcedureType=4 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As SIG,
			Convert(INT,(Select Count(*) From ERS_Procedures Where ProcedureType=3 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As COL
		Insert Into #GRSA04TT (DrugName, OGD, EUS, ERC, HPB, SIG, COL) Select DrugName, IsNull(Sum(OGD),0) As OGD, IsNull(Sum(EUS),0) As EUS, IsNull(Sum(ERC),0) As ERC, IsNull(Sum(HPB),0) As HPV, IsNull(Sum(SIG),0) As SIG, IsNull(Sum(COL),0) As COL From #GRSA04T Group By DrugName
		Insert Into #GRSA04A (DrugName, OGD, EUS, ERC, HPB, SIG, COL) Select DrugName, Convert(varchar(10),OGD) As OHD, Convert(varchar(10),EUS) As EUS, Convert(varchar(10),ERC) As ERC, Convert(varchar(10),HPB) As HPB, Convert(varchar(10),SIG) As SIG, Convert(varchar(10),COL) As COL From #GRSA04TT
		Select @OGDT=OGD, @EUST=EUS, @ERCT=ERC, @HPBT=HPB, @SIGT=SIG, @COLT=COL From #GRSA04TT
		Insert Into #GRSA04A (DrugName, OGD, EUS, ERC, HPB, SIG, COL)
		Select DrugName, 
			Case When IsNull(Sum(Case When ProcedureType=''OGD'' Then 1 Else 0 End),0)=0 Then '''' Else Convert(varchar(10),IsNull(Sum(Case When ProcedureType=''OGD'' Then 1 Else 0 End),0))+'' (''+Convert(varchar(10),Convert(numeric(10,2),IsNull(Sum(Case When ProcedureType=''OGD'' Then 1.0 Else .0 End),0)/@OGDT*100.0))+''%)'' End As OGD,
			Case When IsNull(Sum(Case When ProcedureType=''EUS-OGD'' Then 1 Else 0 End),0)=0 Then '''' Else Convert(varchar(10),IsNull(Sum(Case When ProcedureType=''EUS-OGD'' Then 1 Else 0 End),0))+'' (''+Convert(varchar(10),Convert(numeric(10,2),IsNull(Sum(Case When ProcedureType=''EUS-OGD'' Then 1.0 Else .0 End),0)/@EUST*100.0))+''%)'' End As EUS,
			Case When IsNull(Sum(Case When ProcedureType=''ERCP'' Then 1 Else 0 End),0)=0 Then '''' Else Convert(varchar(10),IsNull(Sum(Case When ProcedureType=''ERCP'' Then 1 Else 0 End),0))+'' (''+Convert(varchar(10),Convert(numeric(10,2),IsNull(Sum(Case When ProcedureType=''ERCP'' Then 1.0 Else .0 End),0)/@ERCT*100.0))+''%)'' End As ERC,
			Case When IsNull(Sum(Case When ProcedureType=''EUS-HPB'' Then 1 Else 0 End),0)=0 Then '''' Else Convert(varchar(10),IsNull(Sum(Case When ProcedureType=''EUS-HPB'' Then 1 Else 0 End),0))+'' (''+Convert(varchar(10),Convert(numeric(10,2),IsNull(Sum(Case When ProcedureType=''EUS-HPB'' Then 1.0 Else .0 End),0)/@HPBT*100.0))+''%)'' End As HPB,
			Case When IsNull(Sum(Case When ProcedureType=''SIG'' Then 1 Else 0 End),0)=0 Then '''' Else Convert(varchar(10),IsNull(Sum(Case When ProcedureType=''SIG'' Then 1 Else 0 End),0))+'' (''+Convert(varchar(10),Convert(numeric(10,2),IsNull(Sum(Case When ProcedureType=''SIG'' Then 1.0 Else .0 End),0)/@SIGT*100.0))+''%)'' End As SIG,
			Case When IsNull(Sum(Case When ProcedureType=''COL'' Then 1 Else 0 End),0)=0 Then '''' Else Convert(varchar(10),IsNull(Sum(Case When ProcedureType=''COL'' Then 1 Else 0 End),0))+'' (''+Convert(varchar(10),Convert(numeric(10,2),IsNull(Sum(Case When ProcedureType=''COL'' Then 1.0 Else .0 End),0)/@COLT*100.0))+''%)'' End As COL
				From [dbo].[v_rep_ReversingAgent] Where CreatedOn>=@FromDate And CreatedOn<=@ToDate
		Group By DrugName
		Select * From #GRSA04A
		Drop Table #GRSA04T
		Drop Table #GRSA04TT
	End
	Else
	Begin
		Select * From #GRSA04A
		Drop Table #GRSA04T
		Drop Table #GRSA04TT
	End
	
End'
END
ELSE
BEGIN
SET @sql = '
Create Proc [dbo].[sp_rep_GRSA04A] @UserID INT=NULL, @Summary BIT=NULL As
Begin
	SET NOCOUNT ON
	Declare @FromDate DATE
	Declare @ToDate DATE
	Select @FromDate=FromDate, @ToDate=ToDate From ERS_ReportFilter Where UserID=@UserID
	DECLARE @OGDT INT
	DECLARE @EUST INT
	DECLARE @ERCT INT
	DECLARE @HPBT INT
	DECLARE @SIGT INT
	DECLARE @COLT INT
	DECLARE @OGDD INT
	DECLARE @EUSD INT
	DECLARE @ERCD INT
	DECLARE @HPBD INT
	DECLARE @SIGD INT
	DECLARE @COLD INT
	Create Table #GRSA04T(DrugName VARCHAR(128), OGD INT, EUS INT, ERC INT, HPB INT, SIG INT, COL INT, i INT IDENTITY(1,1) PRIMARY KEY CLUSTERED)
	Create Table #GRSA04TT(DrugName VARCHAR(128), OGD INT, EUS INT, ERC INT, HPB INT, SIG INT, COL INT, i INT IDENTITY(1,1) PRIMARY KEY CLUSTERED)
	Create Table #GRSA04A(DrugName VARCHAR(128), OGD VARCHAR(10), EUS VARCHAR(10), ERC VARCHAR(10), HPB VARCHAR(10), SIG VARCHAR(10), COL VARCHAR(10), i INT IDENTITY(1,1) PRIMARY KEY CLUSTERED)
	If @Summary=1
	Begin
		Insert Into #GRSA04T
		Select 
			''Total procedures performed'' As DrugName, 
			Convert(INT,(Select Count(*) From ERS_Procedures Where ProcedureType=1 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As OGD,
			Convert(INT,(Select Count(*) From ERS_Procedures Where ProcedureType=6 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As EUS,
			Convert(INT,(Select Count(*) From ERS_Procedures Where ProcedureType=2 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As ERC,
			Convert(INT,(Select Count(*) From ERS_Procedures Where ProcedureType=7 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As HPB,
			Convert(INT,(Select Count(*) From ERS_Procedures Where ProcedureType=4 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As SIG,
			Convert(INT,(Select Count(*) From ERS_Procedures Where ProcedureType=3 And CreatedOn>=@FromDate And CreatedOn<=@ToDate)) As COL
		Insert Into #GRSA04TT (DrugName, OGD, EUS, ERC, HPB, SIG, COL) Select DrugName, IsNull(Sum(OGD),0) As OGD, IsNull(Sum(EUS),0) As EUS, IsNull(Sum(ERC),0) As ERC, IsNull(Sum(HPB),0) As HPV, IsNull(Sum(SIG),0) As SIG, IsNull(Sum(COL),0) As COL From #GRSA04T Group By DrugName
		Insert Into #GRSA04A (DrugName, OGD, EUS, ERC, HPB, SIG, COL) Select DrugName, Convert(varchar(10),OGD) As OHD, Convert(varchar(10),EUS) As EUS, Convert(varchar(10),ERC) As ERC, Convert(varchar(10),HPB) As HPB, Convert(varchar(10),SIG) As SIG, Convert(varchar(10),COL) As COL From #GRSA04TT
		Select @OGDT=OGD, @EUST=EUS, @ERCT=ERC, @HPBT=HPB, @SIGT=SIG, @COLT=COL From #GRSA04TT
		Insert Into #GRSA04A (DrugName, OGD, EUS, ERC, HPB, SIG, COL)
		Select DrugName, 
			Case When IsNull(Sum(Case When ProcedureType=''OGD'' Then 1 Else 0 End),0)=0 Then '''' Else Convert(varchar(10),IsNull(Sum(Case When ProcedureType=''OGD'' Then 1 Else 0 End),0))+'' (''+Convert(varchar(10),Convert(numeric(10,2),IsNull(Sum(Case When ProcedureType=''OGD'' Then 1.0 Else .0 End),0)/@OGDT*100.0))+''%)'' End As OGD,
			Case When IsNull(Sum(Case When ProcedureType=''EUS-OGD'' Then 1 Else 0 End),0)=0 Then '''' Else Convert(varchar(10),IsNull(Sum(Case When ProcedureType=''EUS-OGD'' Then 1 Else 0 End),0))+'' (''+Convert(varchar(10),Convert(numeric(10,2),IsNull(Sum(Case When ProcedureType=''EUS-OGD'' Then 1.0 Else .0 End),0)/@EUST*100.0))+''%)'' End As EUS,
			Case When IsNull(Sum(Case When ProcedureType=''ERCP'' Then 1 Else 0 End),0)=0 Then '''' Else Convert(varchar(10),IsNull(Sum(Case When ProcedureType=''ERCP'' Then 1 Else 0 End),0))+'' (''+Convert(varchar(10),Convert(numeric(10,2),IsNull(Sum(Case When ProcedureType=''ERCP'' Then 1.0 Else .0 End),0)/@ERCT*100.0))+''%)'' End As ERC,
			Case When IsNull(Sum(Case When ProcedureType=''EUS-HPB'' Then 1 Else 0 End),0)=0 Then '''' Else Convert(varchar(10),IsNull(Sum(Case When ProcedureType=''EUS-HPB'' Then 1 Else 0 End),0))+'' (''+Convert(varchar(10),Convert(numeric(10,2),IsNull(Sum(Case When ProcedureType=''EUS-HPB'' Then 1.0 Else .0 End),0)/@HPBT*100.0))+''%)'' End As HPB,
			Case When IsNull(Sum(Case When ProcedureType=''SIG'' Then 1 Else 0 End),0)=0 Then '''' Else Convert(varchar(10),IsNull(Sum(Case When ProcedureType=''SIG'' Then 1 Else 0 End),0))+'' (''+Convert(varchar(10),Convert(numeric(10,2),IsNull(Sum(Case When ProcedureType=''SIG'' Then 1.0 Else .0 End),0)/@SIGT*100.0))+''%)'' End As SIG,
			Case When IsNull(Sum(Case When ProcedureType=''COL'' Then 1 Else 0 End),0)=0 Then '''' Else Convert(varchar(10),IsNull(Sum(Case When ProcedureType=''COL'' Then 1 Else 0 End),0))+'' (''+Convert(varchar(10),Convert(numeric(10,2),IsNull(Sum(Case When ProcedureType=''COL'' Then 1.0 Else .0 End),0)/@COLT*100.0))+''%)'' End As COL
				From [dbo].[v_rep_ReversingAgent] Where CreatedOn>=@FromDate And CreatedOn<=@ToDate
		Group By DrugName
		Select * From #GRSA04A
		Drop Table #GRSA04T
		Drop Table #GRSA04TT
	End
	Else
	Begin
		Select * From #GRSA04A
		Drop Table #GRSA04T
		Drop Table #GRSA04TT
	End
	
End'
END

EXEC sp_executesql @sql
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSA04B', 'S';
GO

Create Proc [dbo].[sp_rep_GRSA04B] @UserID INT=NULL, @Patients BIT=NULL As
Begin
	SET NOCOUNT ON
	Declare @FromDate DATE
	Declare @ToDate DATE
	Select @FromDate=FromDate, @ToDate=ToDate From ERS_ReportFilter Where UserID=@UserID
	If @Patients=1
	Begin
		Select * From [dbo].[v_rep_ReversingAgent] Where CreatedOn>=@FromDate And CreatedOn<=@ToDate
	End
	Else
	Begin
		Select * From [dbo].[v_rep_ReversingAgent] Where CreatedOn<=@FromDate And CreatedOn>=@ToDate
	End
End
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSB01', 'S';
GO

Create Proc [dbo].[sp_rep_GRSB01] @UserID INT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @Sessile BIT=NULL, @Pedunculated BIT=NULL, @Pseudopolyp BIT=NULL, @GTSessile INT=NULL, @GTPedunculated INT=NULL, @GTPseudopolyp INT=NULL, @FromAge INT=NULL, @ToAge INT=NULL As
Begin
	SET NOCOUNT ON
	Declare @Msg VARCHAR(2048)
	Set @Msg=''
	BEGIN TRY
		If @UserID Is Null 
		Begin
			Set @Msg='@UserID Has not been passed as parameter. '
			Set @UserID=0
		End
		If IsNull(@Endoscopist1,0)=0 And IsNull(@Endoscopist2,0)=0
		Begin
			Set @Msg='You must pass at least @Endoscopist1 or Endoscopist2 as valid Parameter(1). '
			Raiserror(@Msg,11,1)
		End
		If IsNull(@Sessile,0)=0 And IsNull(@Pedunculated,0)=0 And IsNull(@Pseudopolyp,0)=0
		Begin
			Set @Msg='You must pass at least @Sessile or @Pedunculated or @Pseodopolyp as valid Parameter(1). '
			--Raiserror(@Msg,11,1)
		End
		If IsNull(@GTSessile,0)<0
		Begin
			Set @Msg='@GTSessile must be a positive value. '
			Set @GTSessile=0
		End
		If IsNull(@GTPedunculated,0)<0
		Begin
			Set @Msg='@GTPedunculated must be a positive value. '
			Set @GTPedunculated=0
		End
		If IsNull(@GTPseudopolyp,0)<0
		Begin
			Set @Msg='@GTPseudopolyp must be a positive value. '
			Set @GTPseudopolyp=0
		End
		If IsNull(@FromAge,0)>IsNull(@ToAge,0)
		Begin
			Set @Msg='@FromAge must be less than @ToAge. '
			Raiserror(@Msg,11,1)
		End
		If IsNull(@FromAge,0)<0
		Begin
			Set @Msg='FromAge must be a positive value. '
			Raiserror(@Msg,11,1)
		End
		Set @FromAge=IsNull(@FromAge,0)
		Set @ToAge=IsNull(@ToAge,200)
		Set @GTSessile=IsNull(@GTSessile,0)
		Set @GTPedunculated=IsNull(@GTPedunculated,0)
		Set @Pseudopolyp=IsNull(@Pseudopolyp,0)
		If @Endoscopist1=1 And @Endoscopist2=1
		Begin
				Select C.Consultant, PT.ProcedureType, A.CNN, A.CreatedOn, A.Age, A.Forename1, A.Surname, A.Region, Case When A.Sessile=1 Then 'Sessile' Else Case When A.Pedunculated=1 Then 'Pedunculated' Else 'Pseudopolyp' End End As PolypType
					, A.SessileExcised+A.PedunculatedExcised+A.PseudopolypsLargest As Excised
					, A.SessileRetrieved+A.PedunculatedRetrieved+A.PseudopolypsRetrieved As Retrieved
					, A.SessileToLabs+A.PedunculatedToLabs+A.PseudopolypsToLabs As ToLabs
					, Case When A.Sessile=1 Then Convert(varchar(10),A.SessileQuantity)+' in ' +Region+' '+Convert(VARCHAR(10), A.SessileExcised)+' excised '+Convert(VARCHAR(10), A.SessileToLabs)+' sent to labs' Else '' End
					+Case When A.Pedunculated=1 Then Convert(varchar(10),A.PedunculatedQuantity)+' in ' +Region+' '+Convert(VARCHAR(10), A.PedunculatedExcised)+' excised '+Convert(VARCHAR(10), A.PedunculatedToLabs)+' sent to labs' Else '' End
					+Case When A.Pseudopolyps=1 Then Convert(varchar(10),A.PseudopolypsQuantity)+' in ' +Region+' '+Convert(VARCHAR(10), A.PseudopolypsExcised)+' excised '+Convert(VARCHAR(10), A.PseudopolypsToLabs)+' sent to labs' Else '' End As Text
					, A.SessileExcised, A.PedunculatedExcised, A.PseudopolypsExcised
					, A.SessileRetrieved, A.PedunculatedRetrieved, A.PseudopolypsRetrieved
					, A.SessileToLabs, A.PedunculatedToLabs, A.PseudopolypsToLabs
				From [dbo].[v_rep_GRSB01] A, v_rep_Consultants C, ERS_ReportConsultants RC, ERS_ProcedureTypes PT, ERS_ReportFilter RF
				Where A.Endoscopist1=C.ConsultantID And A.Release=C.Release
					And RC.ConsultantID=Case A.Release When 'UGI' Then C.ConsultantID Else C.ConsultantID End And RC.UserID=@UserID
					And PT.ProcedureTypeId=A.ProcedureType
					And RF.UserID=RC.UserID
					And A.CreatedOn>=RF.FromDate And A.CreatedOn<=RF.ToDate
					And A.Age>=@FromAge And A.Age<=@ToAge
					And ((A.Sessile=@Sessile And A.SessileLargest>=@GTSessile)
					Or (A.Pedunculated=@Pedunculated And A.PedunculatedLargest>=@GTPedunculated)
					Or (A.Pseudopolyps=@Pseudopolyp And A.PseudopolypsLargest>=@GTPseudopolyp))
				Union 
				Select C.Consultant, PT.ProcedureType, A.CNN, A.CreatedOn, A.Age, A.Forename1, A.Surname, A.Region, Case When A.Sessile=1 Then 'Sessile' Else Case When A.Pedunculated=1 Then 'Pedunculated' Else 'Pseudopolyp' End End As PolypType
					, A.SessileExcised+A.PedunculatedExcised+A.PseudopolypsLargest As Excised
					, A.SessileRetrieved+A.PedunculatedRetrieved+A.PseudopolypsRetrieved As Retrieved
					, A.SessileToLabs+A.PedunculatedToLabs+A.PseudopolypsToLabs As ToLabs
					, Case When A.Sessile=1 Then Convert(varchar(10),A.SessileQuantity)+' in ' +Region+' '+Convert(VARCHAR(10), A.SessileExcised)+' excised '+Convert(VARCHAR(10), A.SessileToLabs)+' sent to labs' Else '' End
					+Case When A.Pedunculated=1 Then Convert(varchar(10),A.PedunculatedQuantity)+' in ' +Region+' '+Convert(VARCHAR(10), A.PedunculatedExcised)+' excised '+Convert(VARCHAR(10), A.PedunculatedToLabs)+' sent to labs' Else '' End
					+Case When A.Pseudopolyps=1 Then Convert(varchar(10),A.PseudopolypsQuantity)+' in ' +Region+' '+Convert(VARCHAR(10), A.PseudopolypsExcised)+' excised '+Convert(VARCHAR(10), A.PseudopolypsToLabs)+' sent to labs' Else '' End As Text
					, A.SessileExcised, A.PedunculatedExcised, A.PseudopolypsExcised
					, A.SessileRetrieved, A.PedunculatedRetrieved, A.PseudopolypsRetrieved
					, A.SessileToLabs, A.PedunculatedToLabs, A.PseudopolypsToLabs
				From [dbo].[v_rep_GRSB01] A, v_rep_Consultants C, ERS_ReportConsultants RC, ERS_ProcedureTypes PT, ERS_ReportFilter RF
				Where A.Endoscopist2=C.ConsultantID And A.Release=C.Release
					And RC.ConsultantID=Case A.Release When 'UGI' Then C.ConsultantID+1000000 Else C.ConsultantID End And RC.UserID=@UserID
					And PT.ProcedureTypeId=A.ProcedureType
					And RF.UserID=RC.UserID
					And A.CreatedOn>=RF.FromDate And A.CreatedOn<=RF.ToDate
					And A.Age>=@FromAge And A.Age<=@ToAge
		End
		Else
		Begin
			If @Endoscopist1=1
			Begin
				Select C.Consultant, PT.ProcedureType, A.CNN, A.CreatedOn, A.Age, A.Forename1, A.Surname, A.Region, Case When A.Sessile=1 Then 'Sessile' Else Case When A.Pedunculated=1 Then 'Pedunculated' Else 'Pseudopolyp' End End As PolypType
					, A.SessileExcised+A.PedunculatedExcised+A.PseudopolypsLargest As Excised
					, A.SessileRetrieved+A.PedunculatedRetrieved+A.PseudopolypsRetrieved As Retrieved
					, A.SessileToLabs+A.PedunculatedToLabs+A.PseudopolypsToLabs As ToLabs
					, Case When A.Sessile=1 Then Convert(varchar(10),A.SessileQuantity)+' in ' +Region+' '+Convert(VARCHAR(10), A.SessileExcised)+' excised '+Convert(VARCHAR(10), A.SessileToLabs)+' sent to labs' Else '' End
					+Case When A.Pedunculated=1 Then Convert(varchar(10),A.PedunculatedQuantity)+' in ' +Region+' '+Convert(VARCHAR(10), A.PedunculatedExcised)+' excised '+Convert(VARCHAR(10), A.PedunculatedToLabs)+' sent to labs' Else '' End
					+Case When A.Pseudopolyps=1 Then Convert(varchar(10),A.PseudopolypsQuantity)+' in ' +Region+' '+Convert(VARCHAR(10), A.PseudopolypsExcised)+' excised '+Convert(VARCHAR(10), A.PseudopolypsToLabs)+' sent to labs' Else '' End As Text
					, A.SessileExcised, A.PedunculatedExcised, A.PseudopolypsExcised
					, A.SessileRetrieved, A.PedunculatedRetrieved, A.PseudopolypsRetrieved
					, A.SessileToLabs, A.PedunculatedToLabs, A.PseudopolypsToLabs
				From [dbo].[v_rep_GRSB01] A, v_rep_Consultants C, ERS_ReportConsultants RC, ERS_ProcedureTypes PT, ERS_ReportFilter RF
				Where A.Endoscopist1=C.ConsultantID And A.Release=C.Release
					And RC.ConsultantID=Case A.Release When 'UGI' Then C.ConsultantID+1000000 Else C.ConsultantID End And RC.UserID=@UserID
					And PT.ProcedureTypeId=A.ProcedureType
					And RF.UserID=RC.UserID
					And A.CreatedOn>=RF.FromDate And A.CreatedOn<=RF.ToDate
					And A.Age>=@FromAge And A.Age<=@ToAge
					And ((A.Sessile=@Sessile And A.SessileLargest>=@GTSessile)
					Or (A.Pedunculated=@Pedunculated And A.PedunculatedLargest>=@GTPedunculated)
					Or (A.Pseudopolyps=@Pseudopolyp And A.PseudopolypsLargest>=@GTPseudopolyp))
			End
			Else
			Begin
				Select C.Consultant, PT.ProcedureType, A.CNN, A.CreatedOn, A.Age, A.Forename1, A.Surname, A.Region, Case When A.Sessile=1 Then 'Sessile' Else Case When A.Pedunculated=1 Then 'Pedunculated' Else 'Pseudopolyp' End End As PolypType
					, A.SessileExcised+A.PedunculatedExcised+A.PseudopolypsLargest As Excised
					, A.SessileRetrieved+A.PedunculatedRetrieved+A.PseudopolypsRetrieved As Retrieved
					, A.SessileToLabs+A.PedunculatedToLabs+A.PseudopolypsToLabs As ToLabs
					, Case When A.Sessile=1 Then Convert(varchar(10),A.SessileQuantity)+' in ' +Region+' '+Convert(VARCHAR(10), A.SessileExcised)+' excised '+Convert(VARCHAR(10), A.SessileToLabs)+' sent to labs' Else '' End
					+Case When A.Pedunculated=1 Then Convert(varchar(10),A.PedunculatedQuantity)+' in ' +Region+' '+Convert(VARCHAR(10), A.PedunculatedExcised)+' excised '+Convert(VARCHAR(10), A.PedunculatedToLabs)+' sent to labs' Else '' End
					+Case When A.Pseudopolyps=1 Then Convert(varchar(10),A.PseudopolypsQuantity)+' in ' +Region+' '+Convert(VARCHAR(10), A.PseudopolypsExcised)+' excised '+Convert(VARCHAR(10), A.PseudopolypsToLabs)+' sent to labs' Else '' End As Text
					, A.SessileExcised, A.PedunculatedExcised, A.PseudopolypsExcised
					, A.SessileRetrieved, A.PedunculatedRetrieved, A.PseudopolypsRetrieved
					, A.SessileToLabs, A.PedunculatedToLabs, A.PseudopolypsToLabs
				From [dbo].[v_rep_GRSB01] A, v_rep_Consultants C, ERS_ReportConsultants RC, ERS_ProcedureTypes PT, ERS_ReportFilter RF
				Where A.Endoscopist2=C.ConsultantID And A.Release=C.Release
				And RC.ConsultantID=Case A.Release When 'UGI' Then C.ConsultantID+1000000 Else C.ConsultantID End And RC.UserID=@UserID
				And PT.ProcedureTypeId=A.ProcedureType
				And RF.UserID=RC.UserID
				And A.CreatedOn>=RF.FromDate And A.CreatedOn<=RF.ToDate
				And A.Age>=@FromAge And A.Age<=@ToAge
			End
		End
	END TRY
	BEGIN CATCH
		PRINT 'Sintax error: '+@Msg
		Print '	Exec sp_rep_GRSB01 @UserID=[UserID], @Endoscopist1=[0/1], @Endoscopist2=[0/1], @Sessile=[0/1], @Pedunculated BIT=NULL, @Pseudopolyp BIT=NULL, @GTSessile INT=NULL, @GTPedunculated INT=NULL, @GTPseudopolyp INT=NULL, @FromAge INT=NULL, @ToAge INT=NULL'
		Print '		[UserID]: Session Value of PKUserId'
		Print '		[@Endoscopist1]: [1]/[0][TRUE]/[FALSE]'
		Print '		[@Endoscopist2]: [1]/[0][TRUE]/[FALSE]'
		Print '		[@Sessile]: [1]/[0][TRUE]/[FALSE]'
		Print '		[@Pedunculated]: [1]/[0][TRUE]/[FALSE]'
		Print '		[@Pseudopolyp]: [1]/[0][TRUE]/[FALSE]'
		Print '		[@GTSessile]: Sessile Greater than [Integer value]'
		Print '		[@GTPedunculated]: Pedunculated Greater than [Integer value]'
		Print '		[@GTPseudopolyp]: Pseudopolyp Greater than [Integer value]'
		Print '		[@FromAge]: From [n] age (integer value)'
		Print '		[@ToAge]: To [n] age (integer value)'
	END CATCH
End
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSB02', 'S';
GO

Create Proc [dbo].[sp_rep_GRSB02] @UserID INT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @FromAge INT=NULL, @ToAge INT=NULL, @AppId VARCHAR(1)=NULL As
Begin
	SET NOCOUNT ON
	Declare @Msg VARCHAR(2048)
	Set @Msg=''
	BEGIN TRY
		If @UserID Is Null 
		Begin
			Set @Msg='@UserID Has not been passed as parameter. '
			Set @UserID=0
		End
		Declare @FromDate Date
		Declare @ToDate Date
		Select @FromDate=FromDate, @ToDate=ToDate From ERS_ReportFilter Where UserId=@UserID
		Set @FromAge=IsNull(@FromAge,0)
		Set @ToAge=IsNull(@ToAge,200)
		Select	
			G.[Consultant/operator] As ConsultantName
			,1 As CarriedOut
			,G.Surname
			,G.Forename1
			,G.[Episode date] As CreatedOn
			, iPapillo
			,Case When [Procs Papill/sphincterotomy]=-1 Then Case When G.Papillotomy=-1 Or G.[Pan Orifice Sphincterotomy]=-1 Then 'The planned Pan Orifice Sphincterotomy was not carried out (failed papillotomy) ' Else '' End Else '' End 
			+Case IsNull([Via major to bile duct],0) When 0 Then 'Cannulation via papilla to bile duct was unsuccessfull ' When 1 Then '' When 2 Then 'Cannulation via papilla to bile duct was unsuccessfull ' When 3 Then 'Cannulation via papilla to bile duct was unsuccessfull ' When 4 Then 'Cannulation via papilla to bile duct was unsuccessfull ' Else '' End 
			+Case When [Procs Stent removal]=-1 Then Case When G.[Stent removal]=-1 Then '' Else 'The planned Stent removal was not carried out (failed removal) ' End Else '' End
			+Case When [Procs Stent insertion]=-1 Then Case When G.[Stent insertion]=-1 And G.[Correct stent placement]=-1 Then '' Else 'The planned Stent insertion was not carried out (failed insertion) ' End Else '' End
			+Case When [Procs stent replacement]=-1 Then Case When G.[Stent insertion]=-1 And G.[Correct stent placement]=-1 Then '' Else 'The planned Stent insertion was not carried out (failed replacement) ' End Else '' End
			+Case When [Procs naso drains]=-1 Then Case When G.[Nasopancreatic Drain]=-1 Then '' Else 'Nasopancreatic Drain was not carried out (failed cannulation) ' End Else '' End
			+Case When [Procs cyst puncture]=-1 Then Case When G.[Endoscopic Cyst Puncture]=-1 Then '' Else 'Endoscopic Cyst Puncture was not carried out (failed cannulation) ' End Else '' End 
			+Case When [Procs rendezvous]=-1 Then Case When G.[Rendezvous procedure]=-1 Then '' Else 'The combined Rendezvous procedure was not carried out (failed cannulation) ' End Else '' End 
			+Case When [Procs stricture dilatation]=-1 Then Case When [Stent Insertion]=-1  And G.[Correct stent placement]=-1 Then '' Else 'Stricture dilatation procedure was not carried out (failed cannulation) ' End Else '' End 
			+Case When [Procs stone removal]=-1 Then Case When [Stone removal]=-1 Then '' Else Case When G.[Extraction outcome]=3 Or G.[Extraction outcome]=4 Then 
				Case When [Inadequate sphincterotomy]=-1 Then 'Inadequate sphincterotomy' Else '' End
			 Else '' End End Else '' End As Completion
		From [dbo].[v_rep_GRSB02] G
		WHERE 
			G.[Episode date]>=@FromDate And G.[Episode date]<=@ToDate	
			And G.[Age at procedure]>=@FromAge And G.[Age at procedure]<=@ToAge
			And 'U.'+Convert(Varchar(10),Convert(Int,SubString(G.Endoscopist2,7,6))) In (Select ConsultantId From fw_ReportConsultants Where UserId=@UserId)
			And (G.Endoscopist2 in (Select O.[Consultant/operator ID] From [Consultant/Operators] O Where O.IsEndoscopist1=-1 And O.IsEndoscopist2=-1) )
			And G.[Patient No]+'.'+Convert(varchar(10),G.[Episode No])
			In (Select [Patient No]+'.'+Convert(varchar(10),[Episode No]) From [ERCP Sites] )
		Order By 1
	END TRY
	BEGIN CATCH
		PRINT 'Sintax error: '+@Msg
		Print '	Exec sp_rep_GRSB02 @UserID=[UserID], @Endoscopist1=[0/1], @Endoscopist2=[0/1], @Sessile=[0/1], @Pedunculated BIT=NULL, @Pseudopolyp BIT=NULL, @GTSessile INT=NULL, @GTPedunculated INT=NULL, @GTPseudopolyp INT=NULL, @FromAge INT=NULL, @ToAge INT=NULL'
		Print '		[UserID]: Session Value of PKUserId'
		Print '		[@Endoscopist1]: [1]/[0][TRUE]/[FALSE]'
		Print '		[@Endoscopist2]: [1]/[0][TRUE]/[FALSE]'
		Print '		[@Sessile]: [1]/[0][TRUE]/[FALSE]'
		Print '		[@Pedunculated]: [1]/[0][TRUE]/[FALSE]'
		Print '		[@Pseudopolyp]: [1]/[0][TRUE]/[FALSE]'
		Print '		[@GTSessile]: Sessile Greater than [Integer value]'
		Print '		[@GTPedunculated]: Pedunculated Greater than [Integer value]'
		Print '		[@GTPseudopolyp]: Pseudopolyp Greater than [Integer value]'
		Print '		[@FromAge]: From [n] age (integer value)'
		Print '		[@ToAge]: To [n] age (integer value)'
	END CATCH
End
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSB03', 'S';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create Proc [dbo].[sp_rep_GRSB03] @UserID INT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @FromAge INT=NULL, @ToAge INT=NULL, @AppId VARCHAR(1)=NULL As
Begin
	SET NOCOUNT ON
	Declare @Msg VARCHAR(2048)
	Set @Msg=''''
	BEGIN TRY
		If @UserID Is Null 
		Begin
			Set @Msg=''@UserID Has not been passed as parameter. ''
			Set @UserID=0
		End
		If IsNull(@Endoscopist1,0)=0 And IsNull(@Endoscopist2,0)=0
		Begin
			Set @Msg=''You must pass at least @Endoscopist1 or Endoscopist2 as valid Parameter(1). ''
			Raiserror(@Msg,11,1)
		End
		If @AppId<>''U''
		Begin
			Select 
				PR.ProcedureId, PR.PatientId
				,CT.ConsultantType, C.ConsultantName, P.CNN
				, P.Surname, P.Forename, PR.CreatedOn
				, PR.Age, I.[Image], I.Indications, I.Therapy
				, IsNull((Select Count(I.ImageObstructionCBD) From fw_IndicationsERCP I Where I.ProcedureId=PR.ProcedureId),0) As ObstructedCBD
				, Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''V'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=PR.ProcedureId))=0 Then 0 Else 1 End As ''V''
				, Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''X'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=PR.ProcedureId))=0 Then 0 Else 1 End As ''X''
				, 1-Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''X'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=PR.ProcedureId))=0 Then 0 Else 1 End-Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''V'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=PR.ProcedureId))=0 Then 0 Else 1 End As Others
				, (Select Top 1 Result From fw_TherapeuticERCP T Where T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=S.ProcedureId)) As Result
			From 
				fw_IndicationsERCP I
				,fw_Procedures PR
				,fw_Patients P
				, fw_ProceduresConsultants PC
				, fw_Consultants C
				, fw_ConsultantTypes CT
			Where 
				PR.ProcedureId=I.ProcedureId 
				And PR.PatientId=P.PatientId
				And PR.ProcedureTypeId=2
				And (I.ClinObstructionCBD=1 Or I.ImageObstructionCBD=1)
				And PC.ProcedureId=PR.ProcedureId
				And PC.ConsultantId=C.ConsultantId
				And PC.ConsultantTypeId In (IsNull(@Endoscopist1,0),Case When IsNull(@Endoscopist2,0)=0 Then 0 Else 2 End)
				And CT.ConsultantTypeId=PC.ConsultantTypeId
				And PR.Age>=IsNull(@FromAge,0) And PR.Age<=IsNull(@ToAge,200)
				And PR.AppId In (''E'',IsNull(@AppId,''''))
			End
			Else
			Begin
				Declare @FromDate DATE
				Declare @ToDate DATE
				Select @FromDate=FromDate, @ToDate=ToDate From fw_ReportFilter Where UserId=@UserID
				SELECT 
					''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(Episode.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),Episode.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(Episode.[Patient No],7,6))) As ProcedureId
					, Convert(Int,SUBSTRING(Episode.[Patient No],7,6)) As PatientId
					, ''Endoscopist1'' As ConsultantType
					, (Select C.ConsultantName From fw_Consultants C Where C.ConsultantId=''U.''+Convert(VARCHAR(10),Convert(INT,SubString([ERCP Procedure].Endoscopist2,7,6)))) As ConsultantName
					, Patient.[Case note no] As CNN
					, Patient.Surname
					, Patient.Forename
					, Convert(Date,Episode.[Episode Date]) As CreatedOn
					, Episode.[Age at procedure] As Age
					, '''' As [Image]
					, [ERCP Procedure].PP_Indic As Indications
					, [ERCP Procedure].PP_Therapies As therapy
					, Case When [ERCP Indications].[Clin Obstruction CBD]=-1 Then 1 Else 0 End As ObstructedCBD
					, Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''V'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(Episode.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),Episode.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(Episode.[Patient No],7,6)))))=0 Then 0 Else 1 End As ''V''
					, Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''X'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(Episode.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),Episode.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(Episode.[Patient No],7,6)))))=0 Then 0 Else 1 End As ''X''
					, 1-Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''X'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(Episode.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),Episode.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(Episode.[Patient No],7,6)))))=0 Then 0 Else 1 End-Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''V'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(Episode.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),Episode.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(Episode.[Patient No],7,6)))))=0 Then 0 Else 1 End As Others
					, (Select Top 1 Result From fw_TherapeuticERCP T Where T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=S.ProcedureId)) As Result
				--, [ERCP Indications].[Image Obstruction CBD], [ERCP Procedure].Endoscopist1, [ERCP Procedure].Endoscopist2, [ERCP Procedure].Assistant1, [ERCP Procedure].Assistant2 ,Episode.[Episode No]
				FROM [ERCP Procedure] INNER JOIN ([ERCP Indications] INNER JOIN (Episode INNER JOIN Patient ON  Episode.[Patient No] = Patient.[Combo ID]) ON ([ERCP Indications].[Patient No] = Episode.[Patient No]) AND  ([ERCP Indications].[Episode No] = Episode.[Episode No])) ON ([ERCP Procedure].[Episode No] = Episode.[Episode No]) AND ([ERCP Procedure].[Patient No] = Episode.[Patient No]) WHERE (([ERCP Indications].[Clin Obstruction CBD]=-1) OR ([ERCP Indications].[Image Obstruction CBD]=-1)) 
				AND (Episode.[Episode date]>=@FromDate AND Episode.[Episode date]<=@ToDate) AND (Episode.[Age at procedure] >= IsNull(@FromAge,0) AND Episode.[Age at procedure] <= IsNull(@ToAge,200) )
				And ((''U.''+Convert(VARCHAR(10),Convert(INT,SubString([ERCP Procedure].Endoscopist2,7,6)))) In (Select ConsultantId From fw_ReportConsultants Where UserId=Case When IsNull(@Endoscopist1,0)=0 Then -1 Else @UserID End)
				Or (''U.''+Convert(VARCHAR(10),Convert(INT,SubString([ERCP Procedure].Assistant1,7,6)))) In (Select ConsultantId From fw_ReportConsultants Where UserId=Case When IsNull(@Endoscopist2,0)=0 Then -1 Else @UserID End))
			End
	END TRY
	BEGIN CATCH
		PRINT ''Sintax error: ''+@Msg
		Print ''	Exec sp_rep_GRSB03 @UserID=[UserID], @Endoscopist1=[0/1], @Endoscopist2=[0/1], @FromAge INT=NULL, @ToAge INT=NULL''
		Print ''		[UserID]: Session Value of PKUserId''
		Print ''		[@Endoscopist1]: [1]/[0][TRUE]/[FALSE]''
		Print ''		[@Endoscopist2]: [1]/[0][TRUE]/[FALSE]''
		Print ''		[@FromAge]: From [n] age (integer value)''
		Print ''		[@ToAge]: To [n] age (integer value)''
	END CATCH
End
'
END
ELSE
BEGIN
SET @sql = '
Create Proc [dbo].[sp_rep_GRSB03] @UserID INT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @FromAge INT=NULL, @ToAge INT=NULL, @AppId VARCHAR(1)=NULL As
Begin
	SET NOCOUNT ON
	Declare @Msg VARCHAR(2048)
	Set @Msg=''''
	BEGIN TRY
		If @UserID Is Null 
		Begin
			Set @Msg=''@UserID Has not been passed as parameter. ''
			Set @UserID=0
		End
		If IsNull(@Endoscopist1,0)=0 And IsNull(@Endoscopist2,0)=0
		Begin
			Set @Msg=''You must pass at least @Endoscopist1 or Endoscopist2 as valid Parameter(1). ''
			Raiserror(@Msg,11,1)
		End
		If @AppId<>''U''
		Begin
			Select 
				PR.ProcedureId, PR.PatientId
				,CT.ConsultantType, C.ConsultantName, P.CNN
				, P.Surname, P.Forename, PR.CreatedOn
				, PR.Age, I.[Image], I.Indications, I.Therapy
				, IsNull((Select Count(I.ImageObstructionCBD) From fw_IndicationsERCP I Where I.ProcedureId=PR.ProcedureId),0) As ObstructedCBD
				, Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''V'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=PR.ProcedureId))=0 Then 0 Else 1 End As ''V''
				, Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''X'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=PR.ProcedureId))=0 Then 0 Else 1 End As ''X''
				, 1-Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''X'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=PR.ProcedureId))=0 Then 0 Else 1 End-Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''V'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=PR.ProcedureId))=0 Then 0 Else 1 End As Others
				, (Select Top 1 Result From fw_TherapeuticERCP T Where T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=S.ProcedureId)) As Result
			From 
				fw_IndicationsERCP I
				,fw_Procedures PR
				,fw_Patients P
				, fw_ProceduresConsultants PC
				, fw_Consultants C
				, fw_ConsultantTypes CT
			Where 
				PR.ProcedureId=I.ProcedureId 
				And PR.PatientId=P.PatientId
				And PR.ProcedureTypeId=2
				And (I.ClinObstructionCBD=1 Or I.ImageObstructionCBD=1)
				And PC.ProcedureId=PR.ProcedureId
				And PC.ConsultantId=C.ConsultantId
				And PC.ConsultantTypeId In (IsNull(@Endoscopist1,0),Case When IsNull(@Endoscopist2,0)=0 Then 0 Else 2 End)
				And CT.ConsultantTypeId=PC.ConsultantTypeId
				And PR.Age>=IsNull(@FromAge,0) And PR.Age<=IsNull(@ToAge,200)
				And PR.AppId In (''E'',IsNull(@AppId,''''))
			End
			Else
			Begin
				Declare @FromDate DATE
				Declare @ToDate DATE
				Select @FromDate=FromDate, @ToDate=ToDate From fw_ReportFilter Where UserId=@UserID
				SELECT 
					''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(Episode.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),Episode.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(Episode.[Patient No],7,6))) As ProcedureId
					, Convert(Int,SUBSTRING(Episode.[Patient No],7,6)) As PatientId
					, ''Endoscopist1'' As ConsultantType
					, (Select C.ConsultantName From fw_Consultants C Where C.ConsultantId=''U.''+Convert(VARCHAR(10),Convert(INT,SubString([ERCP Procedure].Endoscopist2,7,6)))) As ConsultantName
					, Patient.[Case note no] As CNN
					, Patient.Surname
					, Patient.Forename
					, Convert(Date,Episode.[Episode Date]) As CreatedOn
					, Episode.[Age at procedure] As Age
					, '''' As [Image]
					, [ERCP Procedure].PP_Indic As Indications
					, [ERCP Procedure].PP_Therapies As therapy
					, Case When [ERCP Indications].[Clin Obstruction CBD]=-1 Then 1 Else 0 End As ObstructedCBD
					, Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''V'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(Episode.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),Episode.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(Episode.[Patient No],7,6)))))=0 Then 0 Else 1 End As ''V''
					, Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''X'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(Episode.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),Episode.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(Episode.[Patient No],7,6)))))=0 Then 0 Else 1 End As ''X''
					, 1-Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''X'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(Episode.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),Episode.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(Episode.[Patient No],7,6)))))=0 Then 0 Else 1 End-Case When (Select Count(Result) From fw_TherapeuticERCP T Where T.Result=''V'' And T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=''U.''+Convert(varchar(3),Case CHARINDEX(''1'', SUBSTRING(Episode.[Status], 1, 10)) When ''1'' Then 1 When ''2'' Then 2 When ''5'' Then 6 When ''6'' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=Episode.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+''.''+Convert(varchar(10),Episode.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(Episode.[Patient No],7,6)))))=0 Then 0 Else 1 End As Others
					, (Select Top 1 Result From fw_TherapeuticERCP T Where T.SiteId In (Select S.SiteId From fw_Sites S Where S.ProcedureId=S.ProcedureId)) As Result
				--, [ERCP Indications].[Image Obstruction CBD], [ERCP Procedure].Endoscopist1, [ERCP Procedure].Endoscopist2, [ERCP Procedure].Assistant1, [ERCP Procedure].Assistant2 ,Episode.[Episode No]
				FROM [ERCP Procedure] INNER JOIN ([ERCP Indications] INNER JOIN (Episode INNER JOIN Patient ON  Episode.[Patient No] = Patient.[Combo ID]) ON ([ERCP Indications].[Patient No] = Episode.[Patient No]) AND  ([ERCP Indications].[Episode No] = Episode.[Episode No])) ON ([ERCP Procedure].[Episode No] = Episode.[Episode No]) AND ([ERCP Procedure].[Patient No] = Episode.[Patient No]) WHERE (([ERCP Indications].[Clin Obstruction CBD]=-1) OR ([ERCP Indications].[Image Obstruction CBD]=-1)) 
				AND (Episode.[Episode date]>=@FromDate AND Episode.[Episode date]<=@ToDate) AND (Episode.[Age at procedure] >= IsNull(@FromAge,0) AND Episode.[Age at procedure] <= IsNull(@ToAge,200) )
				And ((''U.''+Convert(VARCHAR(10),Convert(INT,SubString([ERCP Procedure].Endoscopist2,7,6)))) In (Select ConsultantId From fw_ReportConsultants Where UserId=Case When IsNull(@Endoscopist1,0)=0 Then -1 Else @UserID End)
				Or (''U.''+Convert(VARCHAR(10),Convert(INT,SubString([ERCP Procedure].Assistant1,7,6)))) In (Select ConsultantId From fw_ReportConsultants Where UserId=Case When IsNull(@Endoscopist2,0)=0 Then -1 Else @UserID End))
			End
	END TRY
	BEGIN CATCH
		PRINT ''Sintax error: ''+@Msg
		Print ''	Exec sp_rep_GRSB03 @UserID=[UserID], @Endoscopist1=[0/1], @Endoscopist2=[0/1], @FromAge INT=NULL, @ToAge INT=NULL''
		Print ''		[UserID]: Session Value of PKUserId''
		Print ''		[@Endoscopist1]: [1]/[0][TRUE]/[FALSE]''
		Print ''		[@Endoscopist2]: [1]/[0][TRUE]/[FALSE]''
		Print ''		[@FromAge]: From [n] age (integer value)''
		Print ''		[@ToAge]: To [n] age (integer value)''
	END CATCH
End
'
END

EXEC sp_executesql @sql
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSB04', 'S';
GO

Create Proc [dbo].[sp_rep_GRSB04] @UserID INT=NULL As
Begin
	SET NOCOUNT ON
	If @UserID Is Null 
	Begin
		Raiserror('The @UserID parameter is missing a value',11,1)
		PRINT 'Sintax:'
		Print '	Exec sp_rep_GRSB04A @UserID=[UserID]'
		Print '	[UserID]: Session Value of PKUserId'
		Set @UserID=0
	End
	Select 
		P.CNN As CaseNoteNo, P.Surname, P.Forename, P.DOB,PR.PatientId, PR.ProcedureId, RO.RequestedDate, PR.CreatedOn, RO.SummaryText, RO.Result, RO.SeenWithin12weeks, RO.NotSeenWithin12Weeks, RO.StillToBeSeen, RO.HealingText 
	From 
		fw_RepeatOGD RO, fw_Sites S, fw_Procedures PR, fw_Patients P, fw_ProceduresConsultants PC, fw_Consultants C, fw_ReportConsultants RC, fw_ReportFilter RF
	Where RO.SiteId=S.SiteId And PR.ProcedureId=S.ProcedureId And PR.PatientId=P.PatientId And PC.ProcedureId=PR.ProcedureId And PC.ConsultantTypeId=1 And C.ConsultantId=PC.ConsultantId and RC.ConsultantId=C.ConsultantId 
	And RC.UserId=RF.UserId And RF.UserId=IsNull(@UserId,0) And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate
	Order By PR.PatientId, PR.CreatedOn, PR.ProcedureId
End
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSB05', 'S';
GO

Create Proc [dbo].[sp_rep_GRSB05] @UserId INT=NULL, @AppId VARCHAR(1)=NULL
, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL
, @FromAge INT=NULL, @ToAge INT=NULL
, @Sessile BIT=NULL, @SessileN INT=NULL
, @Pedunculated BIT=NULL, @PedunculatedN INT=NULL
, @Submucosal BIT=NULL, @SubmucosalN INT=NULL
, @Villous BIT=NULL, @VillousN INT=NULL
, @Ulcerative BIT=NULL, @UlcerativeN INT=NULL
, @Stricturing BIT=NULL, @StricturingN INT=NULL
, @Polypoidal BIT=NULL, @PolypoidalN INT=NULL
As
Begin
	Set NoCount On
	Begin Try
		Declare @str VARCHAR(4000)
		Set @str=''
		If @UserID Is Null
		Begin
			Raiserror('Error: @UserID is a required parameter',11,1)
		End
		Declare @ProcedureTypeId INT
		Set @ProcedureTypeId=3
		Select 
			Case When @Endoscopist1=1 And @Endoscopist2=1 Then '(for endoscopist1 and 2)' Else Case When @Endoscopist1=1 Then '(for endoscopist 1)' Else Case When @Endoscopist2=1 Then '(for endoscopist 2)' Else '' end End End 
			As Title1
			,
			'For patients '+Case When @FromAge Is Null And @ToAge Is Null Then ' of all ages at procedure' Else Case When @FromAge Is Not Null And @ToAge Is Not Null Then 'with ages at procedure between '+Convert(varchar(3),@FromAge)+' and '+Convert(varchar(3),@ToAge) Else Case When @FromAge Is Not Null Then 'older than '+Convert(varchar(3),@FromAge) Else 'younger than'+Convert(varchar(3),@ToAge) End End End
			,'For patients older than '+Convert(varchar(5),IsNull(@FromAge,0))+' and younger than '+Convert(varchar(5),IsNull(@ToAge,200))
			+Case When IsNull(@Sessile,0)=1 Then ', sessile polyps'+Case When IsNull(@SessileN,0)=0 Then ' of any size' Else ' >'+Convert(varchar(5),IsNull(@SessileN,0))+' mm' End Else '' End
			+Case When IsNull(@Pedunculated,0)=1 Then ', pedunculated polyps'+Case When IsNull(@PedunculatedN,0)=0 Then ' of any size' Else ' >'+Convert(varchar(5),IsNull(@PedunculatedN,0))+' mm' End Else '' End
			+Case When IsNull(@Submucosal,0)=1 Then ', submucosal tumours'+Case When IsNull(@SubmucosalN,0)=0 Then ' of any size' Else ' >'+Convert(varchar(5),IsNull(@SubmucosalN,0))+' mm' End Else '' End
			+Case When IsNull(@Villous,0)=1 Then ', villous tumours'+Case When IsNull(@VillousN,0)=0 Then ' of any size' Else ' >'+Convert(varchar(5),IsNull(@VillousN,0))+' mm' End Else '' End
			+Case When IsNull(@Ulcerative,0)=1 Then ', ulcerative tumours'+Case When IsNull(@UlcerativeN,0)=0 Then ' of any size' Else ' >'+Convert(varchar(5),IsNull(@UlcerativeN,0))+' mm' End Else '' End
			+Case When IsNull(@Stricturing,0)=1 Then ', stricturing tumours'+Case When IsNull(@StricturingN,0)=0 Then ' of any size' Else ' >'+Convert(varchar(5),IsNull(@StricturingN,0))+' mm' End Else '' End
			+Case When IsNull(@Polypoidal,0)=1 Then ', polypoidal tumours'+Case When IsNull(@PolypoidalN,0)=0 Then ' of any size' Else ' >'+Convert(varchar(5),IsNull(@PolypoidalN,0))+' mm' End Else '' End
			As Title2
			,'Covering: From '+Convert(varchar(2),Day(RF.FromDate))+'/'+Convert(varchar(2),Month(RF.FromDate))+'/'+Convert(varchar(4),Year(RF.FromDate))+' to '+Convert(varchar(2),Day(RF.ToDate))+'/'+Convert(varchar(2),Month(RF.ToDate))+'/'+Convert(varchar(4),Year(RF.ToDate)) As Title3
			,A.AppName, C.ConsultantName,CT.ConsultantType
			,Case L.LesionType
				When 'Sessile' then 'Sessile polyps (>'+convert(varchar(5),IsNull(@SessileN,0))+' mm)'
				When 'Pedunculated' then 'Pedunculated polyps (>'+convert(varchar(5),IsNull(@PedunculatedN,0))+' mm)'
				When 'Submucosal' then 'Submucosal tumours (>'+convert(varchar(5),IsNull(@SubmucosalN,0))+' mm)'
				When 'Villous' then 'Villous tumours (>'+convert(varchar(5),IsNull(@VillousN,0))+' mm)'
				When 'Ulcerative' then 'Ulcerative tumours (>'+convert(varchar(5),IsNull(@UlcerativeN,0))+' mm)'
				When 'Stricturing' then 'Stricturing tumours (>'+convert(varchar(5),IsNull(@StricturingN,0))+' mm)'
				When 'Polypoidal' then 'Polypoidal tumours (>'+convert(varchar(5),IsNull(@PolypoidalN,0))+' mm)'
				Else L.LesionType End As LesionType
			,PR.Age,PR.CreatedOn, P.CNN, P.PatientName, S.Region, L.Largest	As Size
			,Case When L.Quantity>0 Then ' '+convert(varchar(5),L.Quantity)+Case When L.Probably=1 Then ' probably' Else '' End+' malignant sessile '+Case When L.Quantity=1 Then 'tumour' Else 'tumours' End +' (>'+Convert(varchar(5),IsNull(@SessileN,0))+'mm).' Else '' End 
			As ReportText
			, Case When M.Marking=1 Then M.MarkingType+' ('+Convert(varchar(3),M.MarkingNumberSites)+' '+Case When M.MarkingNumberSites=1 Then 'site' Else 'sites' End+' marked)' Else '' End As MarkingDetails
		From fw_Lesions L, fw_Markings M, fw_Sites S, fw_Procedures PR, fw_Apps A, fw_Consultants C, fw_ConsultantTypes CT, fw_ProceduresConsultants PC, fw_Patients P, fw_ReportConsultants RC, fw_ReportFilter RF
		Where 
			L.SiteId=M.SiteId And M.SiteId=S.SiteId And PR.ProcedureId=S.ProcedureId And A.AppId=PR.AppId
			And C.ConsultantId=PC.ConsultantId And PC.ConsultantTypeId=CT.ConsultantTypeId 
			And PR.ProcedureId=PC.ProcedureId
			And PC.ConsultantTypeId In (IsNull(@Endoscopist1,0),Case When IsNull(@Endoscopist2,0)=1 Then 2 Else 0 End) 
			And PR.PatientId=P.PatientId 
			And PC.ConsultantId=RC.ConsultantId And RC.UserId=RF.UserId And PR.Age>=IsNull(@FromAge,0) And PR.Age<=IsNull(@ToAge,200)
		And M.Marking=1 
		And RF.UserId=@UserId 
		And A.AppId In ('E',IsNull(@AppId,'')) And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate
		And LesionType In (
			Case When IsNull(@Sessile,0)=1 Then 'Sessile' Else '' End,Case When IsNull(@Pedunculated,0)=1 Then 'Pedunculated' Else '' End
			,Case When IsNull(@Submucosal,0)=1 Then 'Submucosal' Else '' End,Case When IsNull(@Villous,0)=1 Then 'Villous' Else '' End
			,Case When IsNull(@Ulcerative,0)=1 Then 'Ulcerative' Else '' End,Case When IsNull(@Stricturing,0)=1 Then 'Stricturing' Else '' End
			,Case When IsNull(@Polypoidal,0)=1 Then 'Polypoidal' Else '' End)
		And PR.ProcedureTypeId=@ProcedureTypeId
	End Try
	Begin Catch
		Print 'Syntax error: [dbo].[sp_rep_GRSB05] @UserId INT=NULL, @App VARCHAR(1)=NULL, @FromAge INT=NULL, @ToAge INT=NULL '
		Print ', @Sessile BIT=NULL, @SessileN INT=NULL, @Pedunculated BIT=NULL, @PedunculatedN INT=NULL'
		Print ', @Submucosal BIT=NULL, @SubmucosalN INT=NULL, @Villous BIT=NULL, @VillousN INT=NULL'
		Print ', @Ulcerative BIT=NULL, @UlcerativeN INT=NULL, @Stricturing BIT=NULL, @StricturingN INT=NULL'
		Print ', @Polypoidal BIT=NULL, @PolypoidalN INT=NULL'
		Print '@UserId: ERS User ID'
		Print '@AppIs: E/U Null for All'
	End Catch
End
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------

EXEC DropIfExist 'sp_rep_GRSC01', 'S';
GO

Create Proc [dbo].[sp_rep_GRSC01] @UserId INT=NULL, @ProcType VARCHAR(3)=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @AppId VARCHAR(1)=NULL As
Begin
	Set NoCount On
	Begin Try
		Declare @str VARCHAR(4000)
		Declare @ProcedureTypeId INT
		Declare @FromDate DATE
		Declare @ToDate Date
		Set @str=''
		If @UserID Is Null
		Begin
			Raiserror('Error: @UserID is a required parameter',11,1)
		End
		Select @FromDate=FromDate, @ToDate=ToDate From ERS_ReportFilter Where UserId=@UserId
		Set @ProcedureTypeId=Case @ProcType When 'COL' Then 3 When 'SIG' Then 4 Else 0 End
		Create Table #GRSC01 (PatientId INT, CreatedOn Date, Endoscopist1 VARCHAR(10), Endoscopist2 VARCHAR(10), Consultant NVARCHAR(128), ProcedureTypeId INT, Polypectomy INT, AdenomaConfirmed INT, StillAwaiting INT, IsTattoed INT, AppId VARCHAR(1))
		Insert Into #GRSC01 (PatientId, CreatedOn, Endoscopist1, Endoscopist2, Consultant, ProcedureTypeId, Polypectomy, AdenomaConfirmed, StillAwaiting, IsTattoed, AppId)
		SELECT DISTINCT Convert(INT,SubString([Colon Procedure].[Patient No],7,6)) AS PatientId
		, [Colon Procedure].[Procedure date] As CreatedOn,
		 'U.'+Convert(varchar(10),Convert(Int,SubString([Colon Procedure].Endoscopist2,7,6))) As Endoscopist1, 'U.'+Convert(varchar(10),Convert(Int,SubString([Colon Procedure].Assistant1,7,6))) As Endoscopist2
		 , [Consultant/Operators].[Consultant/operator] As Consultant,
		 [Colon Procedure].[Procedure type]+3 As ProcedureTypeId, case When [Colon Specimens].Polypectomy=-1 Then 1 Else 0 End As Polypectomy
		 ,(SELECT Count(*)  FROM [Pathology Results] WHERE ([Patient No]=[Colon Procedure].[Patient No] AND [Episode No]=[Colon Procedure].[Episode No])) As AdenomaConfirmed
		 ,(SELECT Case When Count(*)=0 Then 1 Else 0 End  FROM [Pathology Results] WHERE ([Patient No]=[Colon Procedure].[Patient No] AND [Episode No]=[Colon Procedure].[Episode No])) As StillAwaiting
		 ,(SELECT Count(Marking) FROM [Colon Therapeutic] WHERE ([Patient No]=[Colon Procedure].[Patient No] AND [Episode No]=[Colon Procedure].[Episode No])) As IsTattoed
		 , 'U' As AppId
		FROM Episode INNER JOIN (([Colon Procedure] INNER JOIN [Colon Specimens] ON ([Colon Procedure].[Patient No] = [Colon Specimens].[Patient No]) AND ([Colon Procedure].[Episode No] = [Colon Specimens].[Episode No]))     
			INNER JOIN [Consultant/Operators] ON [Colon Procedure].Endoscopist2 = [Consultant/Operators].[Consultant/operator ID]) ON (Episode.[Episode No] = [Colon Procedure].[Episode No]) AND (Episode.[Patient No] = [Colon Procedure].[Patient No])
		WHERE Episode.[Episode date]>=@FromDate AND Episode.[Episode date]<=@ToDate AND ([Colon procedure].[Procedure type] = (@ProcedureTypeId-3) AND ([Colon Specimens].Polypectomy=-1))
		Union All
		Select PR.PatientId, CreatedOn, 'E.'+Convert(Varchar(10),IsNull(PR.Endoscopist1,0)) As Endoscopist1, 'E.'+Convert(Varchar(10),IsNull(PR.Endoscopist2,0)) As Endoscopist2, IsNull(U.Forename+' ','')+IsNull(U.Surname,'') As Consultant
		, @ProcedureTypeId As ProcedureTypeId
		, T.Polypectomy
		,0 As AdenomaConfirmed
		,0 As StillAwaiting
		,(SELECT IsNull(Sum(Marking),0) FROM fw_Markings WHERE SiteId In (Select SiteId From fw_Sites Where ProcedureId='E.'+Convert(varchar(10),PR.ProcedureId))) As IsTattoed
		, 'E' As AppId
		From ERS_Procedures PR, ERS_Users U, ERS_Sites S, ERS_UpperGITherapeutics T
		, fw_Patients P
		Where PR.Endoscopist1=U.UserID And PR.ProcedureId=S.ProcedureId And S.SiteId=T.SiteId And CreatedOn>=@FromDate And CreatedOn<=@ToDate
		And PR.ProcedureType=@ProcedureTypeId
		And T.Polypectomy=1
		And P.PatientId=PR.PatientId
		SELECT (Select ConsultantName From fw_Consultants Where ConsultantId=RC.ConsultantId) As [Consultant], G.CreatedOn, G.Endoscopist1, G.Endoscopist2, G.ProcedureTypeId
		, IsNull(G.Polypectomy,0) As Polypectomy, IsNull(G.AdenomaConfirmed,0) As AdenomaConfirmed, IsNull(G.StillAwaiting,0) As StillAwaiting, IsNull(G.Polypectomy-IsTattoed,0) As NonMarked, IsNull(G.IsTattoed,0) As IsTattoed, IsNull(Polypectomy-AdenomaConfirmed-StillAwaiting,0) As NonAdenoma, 
			G.AppId
		FROM fw_ReportConsultants RC Left Outer Join #GRSC01 G On ((IsNull(@Endoscopist1,0)=1 And RC.ConsultantId= G.Endoscopist1) Or (IsNull(@Endoscopist2,0)=1 And RC.ConsultantId= G.Endoscopist2)) And AppId In ('E',IsNull(@AppId,''))
			Inner Join fw_Consultants C On C.ConsultantId = RC.ConsultantId
	End Try
	Begin Catch
		Print @Str
		Print 'Syntax error: [dbo].[sp_rep_GRSC01] @UserId INT=NULL, @ProcType BIT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @App VARCHAR(1)=NULL'
		Print '@UserId: ERS User ID'
		Print '@ProcType: COL/SIG'
		Print '@Endoscopist1: 1/0 TRUE/FALSE'
		Print '@Endoscopist2: 1/0 TRUE/FALSE'
		Print '@AppIs: E/U Null for All'
	End Catch
End
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSC02', 'S';
GO

Create Proc [dbo].[sp_rep_GRSC02] @UserId INT=NULL, @Summary BIT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @AppId VARCHAR(1)=NULL As
Begin
	Set NoCount On
	Begin Try
		Declare @str VARCHAR(4000)
		Set @str=''
		If @UserID Is Null
		Begin
			Raiserror('Error: @UserID is a required parameter',11,1)
		End
		Declare @ProcedureTypeId INT
		Set @ProcedureTypeId=3
		Create Table #GRSC02A (ConsultantId VARCHAR(10), ConsultantName NVARCHAR(128), InsertionToCaecum INT, InsertionToTerminalIleum INT, InsertionToNeoTerminalIleum INT, InsertionToAnastomosis INT, InsertionFailed INT)
		Create Table #GRSC02B (ConsultantId VARCHAR(10), ConsultantName NVARCHAR(128), InsertionToCaecum INT, InsertionToTerminalIleum INT, InsertionToNeoTerminalIleum INT, InsertionToAnastomosis INT, InsertionFailed INT)
		Set @str=@str+'Insert Into #GRSC02A (ConsultantId, ConsultantName, InsertionToCaecum, InsertionToTerminalIleum, InsertionToNeoTerminalIleum, InsertionToAnastomosis, InsertionFailed)'
		Set @str=@str+' Select '
		Set @str=@str+'C.ConsultantId, C.ConsultantName, EI.InsertionToCaecum, EI.InsertionToTerminalIleum, EI.InsertionToNeoTerminalIleum, EI.InsertionToAnastomosis, EI.InsertionFailed'
		Set @str=@str+' From fw_Procedures P, fw_ProceduresConsultants PC, fw_Consultants C, fw_Apps A, fw_ReportConsultants RC, fw_ReportFilter RF, fw_ConsultantTypes CT, fw_ColonExtentOfIntubation EI'
		Set @str=@str+' Where P.ProcedureId=PC.ProcedureId And A.AppId=P.AppId'
		Set @str=@str+' And PC.ConsultantId=C.ConsultantId'
		Set @str=@str+' And RC.ConsultantId=C.ConsultantId'
		Set @str=@str+' And PC.ConsultantTypeId=CT.ConsultantTypeId'
		Set @str=@str+' And P.ProcedureId=EI.ProcedureId'
		Set @str=@str+' And P.CreatedOn>=RF.FromDate And P.CreatedOn<=RF.ToDate'
		Set @str=@str+' And ProcedureTypeId In ('+Convert(varchar(10),@ProcedureTypeId)+')'
		If (@Endoscopist1=1 And @Endoscopist2=1)
		Begin
			Set @Str=@Str+' And (PC.ConsultantTypeId In (1,2))'
		End
		Else
		Begin
			If @Endoscopist1=1
			Begin
				Set @Str=@Str+' And (PC.ConsultantTypeId In (1))'
			End
			If @Endoscopist2=1
			Begin
				Set @Str=@Str+' And (PC.ConsultantTypeId In (2))'
			End
		End
		If @AppId='E' Set @Str=@Str+' And P.AppId=''E'''
		Set @str=@str+' And RF.UserId='+Convert(varchar(10),@UserId)
		Print @str
		Exec (@str)
		If @Summary=1
		Begin
			Select RC.ConsultantId, C.ConsultantName
				, IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0) As Colonoscopies
				, IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis),0) As Reached
				, IsNull(Sum(A.InsertionToCaecum),0) As InsertionToCaecum
				, IsNull(Sum(A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum),0) As InsertionToNeoTI
				, IsNull(Sum(A.InsertionToAnastomosis),0) As InsertionToAnastomosis
				, IsNull(Sum(A.InsertionFailed),0) As InsertionFailed
				, Convert(Numeric(20,2),IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis),0))/Case When IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0)<>0 Then IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0) Else 1 End As ReachedP
				, Convert(Numeric(20,2),IsNull(Sum(A.InsertionFailed),0))/Case When IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0)<>0 Then IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0) Else 1 End As FailedP
			From fw_ReportConsultants RC 
				Inner Join fw_Consultants C On RC.ConsultantId=C.ConsultantId
				Left Outer Join #GRSC02A A On RC.ConsultantId=A.ConsultantId
			Group By RC.ConsultantId, C.ConsultantName
			Union All
			Select 'Z' As ConsultantId, 'Unit as a whole' As ConsultantName
				, IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0) As Colonoscopies
				, IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis),0) As Reached
				, IsNull(Sum(A.InsertionToCaecum),0) As InsertionToCaecum
				, IsNull(Sum(A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum),0) As InsertionToNeoTI
				, IsNull(Sum(A.InsertionToAnastomosis),0) As InsertionToAnastomosis
				, IsNull(Sum(A.InsertionFailed),0) As InsertionFailed
				, Convert(Numeric(20,2),IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis),0))/Case When IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0)<>0 Then IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0) Else 1 End As ReachedP
				, Convert(Numeric(20,2),IsNull(Sum(A.InsertionFailed),0))/Case When IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0)<>0 Then IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0) Else 1 End As FailedP
			From fw_ReportConsultants RC 
			Inner Join fw_Consultants C On RC.ConsultantId=C.ConsultantId
			Left Outer Join #GRSC02A A On RC.ConsultantId=A.ConsultantId
			Order By ConsultantId, ConsultantName Asc
		End
		Else
		Begin
			Select RC.ConsultantId, C.ConsultantName
				, IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0) As Colonoscopies
				, IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis),0) As Reached
				, IsNull(Sum(A.InsertionToCaecum),0) As InsertionToCaecum
				, IsNull(Sum(A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum),0) As InsertionToNeoTI
				, IsNull(Sum(A.InsertionToAnastomosis),0) As InsertionToAnastomosis
				, IsNull(Sum(A.InsertionFailed),0) As InsertionFailed
				, Convert(Numeric(20,2),IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis),0))/Case When IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0)<>0 Then IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0) Else 1 End As ReachedP
				, Convert(Numeric(20,2),IsNull(Sum(A.InsertionFailed),0))/Case When IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0)<>0 Then IsNull(Sum(A.InsertionToCaecum+A.InsertionToNeoTerminalIleum+A.InsertionToTerminalIleum+A.InsertionToAnastomosis+A.InsertionFailed),0) Else 1 End As FailedP
			From fw_ReportConsultants RC 
			Inner Join fw_Consultants C On RC.ConsultantId=C.ConsultantId
			Left Outer Join #GRSC02A A On RC.ConsultantId=A.ConsultantId
			Group By RC.ConsultantId, C.ConsultantName
			Order By ConsultantName Asc
		End
	End Try
	Begin Catch
		Print @Str
		Print 'Syntax error: [dbo].[sp_rep_GRSC02] @UserId INT=NULL, @Summary BIT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @App VARCHAR(1)=NULL'
		Print '@UserId: ERS User ID'
		Print '@Summary: 1/0 TRUE/FALSE'
		Print '@Endoscopist1: 1/0 TRUE/FALSE'
		Print '@Endoscopist2: 1/0 TRUE/FALSE'
		Print '@AppIs: E/U Null for All'
		Print '@UserId: ERS User ID'
	End Catch
End
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSC03', 'S';
GO

Create Proc [dbo].[sp_rep_GRSC03] @UserId INT=NULL, @ProcType VARCHAR(3)=NULL, @Complications BIT=NULL, @ReversalAgents BIT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @AppId VARCHAR(1)=NULL As
Begin
	Set NoCount On
	Begin Try
		Declare @str VARCHAR(4000)
		Set @str=''
		If @UserID Is Null
		Begin
			Raiserror('Error: @UserID is a required parameter',11,1)
		End
		Declare @ProcedureTypeId INT
		Set @ProcedureTypeId=0
		If @ProcType='COL' Set @ProcedureTypeId=3
		If @ProcType='SIG' Set @ProcedureTypeId=4
		If @AppId Is Null Set @AppId=''
			SELECT PR.ProcedureId, C.ConsultantName, CT.ConsultantType, fw_Patients.CNN, fw_Patients.PatientName, 1 As Colonoscopies, CE.InsertionComplete, CE.InsertionToCaecum, CE.InsertionToTerminalIleum, CE.InsertionToNeoTerminalIleum, CE.InsertionToAnastomosis, CE.InsertionFailed, CE.InsertionToTerminalIleum+CE.InsertionToNeoTerminalIleum As ILReached, CE.LimitedBy, IsNull(QA.Complications,'') As Complications, IsNull(QA.ReversalAgents,'') As ReversalAgents, A.AppName, fw_ProceduresTypes.ProcedureType, PR.CreatedOn, PR.Age, RF.ReportDate, 
				RF.FromDate, RF.ToDate, RF.UserId, CE.InsertedTo
			FROM fw_Patients INNER JOIN
				fw_Apps AS A INNER JOIN
				fw_Procedures AS PR ON A.AppId = PR.AppId INNER JOIN
				fw_ColonExtentOfIntubation AS CE ON PR.ProcedureId = CE.ProcedureId INNER JOIN
				fw_ProceduresTypes ON PR.ProcedureTypeId = fw_ProceduresTypes.ProcedureTypeId INNER JOIN
				fw_ProceduresConsultants ON PR.ProcedureId = fw_ProceduresConsultants.ProcedureId INNER JOIN
				fw_ReportConsultants RC INNER JOIN
				fw_Consultants C ON RC.ConsultantId = C.ConsultantId INNER JOIN
				fw_ReportFilter RF ON RC.UserId = RF.UserId ON fw_ProceduresConsultants.ConsultantId = C.ConsultantId INNER JOIN
				fw_ConsultantTypes CT ON fw_ProceduresConsultants.ConsultantTypeId = CT.ConsultantTypeId ON 
				fw_Patients.PatientId = PR.PatientId LEFT OUTER JOIN
				fw_QA AS QA ON PR.ProcedureId = QA.ProcedureId		
			Where RF.UserID=@UserID And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate
				And PR.ProcedureTypeId=@ProcedureTypeId
				And CT.ConsultantTypeId In (Case @Endoscopist1 When 1 Then 1 Else 0 End, Case @Endoscopist2 When 1 Then 2 Else 0 End)
				And A.AppId In ('E',@AppId)
			Order By C.ConsultantName, CT.ConsultantType, CNN
	End Try
	Begin Catch
		Print @Str
		--@ProcType VARCHAR(3)=NULL, @Complications BIT=NULL, @ReversalAgents BIT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @AppId VARCHAR(1)=NULL
		Print 'Syntax error: [dbo].[sp_rep_GRSC03] @UserId INT=NULL, @Complications BIT=NULL, @ReversalAgents BIT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @App VARCHAR(1)=NULL'
		Print '@UserId: ERS User ID'
		Print '@ProcType: COL/SIG'
		Print '@Complications: 1/0 TRUE/FALSE'
		Print '@ReversalAgents: 1/0 TRUE/FALSE'
		Print '@Endoscopist1: 1/0 TRUE/FALSE'
		Print '@Endoscopist2: 1/0 TRUE/FALSE'
		Print '@AppIs: E/U Null for All'
		Print '@UserId: ERS User ID'
	End Catch
End
GO



EXEC DropIfExist 'sp_rep_GRSC04', 'S';
GO

Create Proc [dbo].[sp_rep_GRSC04] @UserID INT=NULL, @ProcType VARCHAR(3)=NULL As
Begin
	SET NOCOUNT ON
	Declare @From Date
	Declare @To Date
	If @UserID Is Null
	Declare @Warnings INT
	Set @Warnings=0
	If @UserID Is Null 
	Begin
		Raiserror('The @UserID parameter is missing a value',11,1)
		Set @Warnings=@Warnings+1
	End
	If @ProcType IS NULL
	Begin
		Raiserror('The @ProcType parameter is missing a value',11,1)
		Set @Warnings=@Warnings+1
	End
	If @Warnings>0
	Begin
		PRINT 'Sintax:'
		Print '	Exec sp_rep_GRSC04 1 @UserID=[UserID], @ProcType=[COL]/[SIG]'
		Print ' @UserID: integer'
		Print '	[UserID]: Session Value of PKUserId'
		Print ' @ProcType: varchar(3)'
		Print '	[COL]: Colonoscopy'
		Print '	[SIG]: Sigmoidoscopy'
		--Print ' 4: Consolidated report FOR SSRS'
	End
	Else
	Begin
		Select @From=FromDate, @To=ToDate From [dbo].[ERS_ReportFilter] Where UserID=@UserID
		Create Table #Boston0A (
			[Formulation] varchar(255),
			[Scale] numeric(20,2) Default 0,
			[Right] numeric(20,2) Default 0,
			[Transverse] numeric(20,2) Default 0,
			[Left] numeric(20,2) Default 0,
			)
		Create Table #Boston0B (
			[Formulation] varchar(255),
			[Right] numeric(20,2) Default 0,
			[Transverse] numeric(20,2) Default 0,
			[Left] numeric(20,2) Default 0,
			)
		Create Table #Boston1A (
			[Formulation] varchar(255),
			[Scale] int Default 0,
			[Right] int Default 0,
			[RightP] Numeric(20,4) Default 0,
			[Transverse] int Default 0,
			[TransverseP] Numeric(20,4) Default 0,
			[Left] int Default 0,
			[LeftP] Numeric(20,4) Default 0,
			)
		Create Table #Boston1B (
			[Formulation] varchar(255),
			[Scale] int Default 0,
			[Right] int Default 0,
			[RightP] Numeric(20,4) Default 0,
			[Transverse] int Default 0,
			[TransverseP] Numeric(20,4) Default 0,
			[Left] int Default 0,
			[LeftP] Numeric(20,4) Default 0,
			)
		Create Table #Boston2A (
			[Formulation] varchar(255),
			[Score] int,
			[Frequency] int,
			[Fx] int,
			)
		Create Table #Boston2B (
			[Formulation] varchar(255),
			[Score] int,
			[Frequency] int,
			[Fx] int,
			)
		Create Table #Boston3 (
			[Formulation] varchar(255),
			[NoOfProcs] int,
			[MeanScore] Numeric(20,4) Default 0,
			)
		Create Table #Scale (
			[Scale] int,
			)
		Insert Into #Scale ([Scale]) Values (0)
		Insert Into #Scale ([Scale]) Values (1)
		Insert Into #Scale ([Scale]) Values (2)
		Insert Into #Scale ([Scale]) Values (3)
		Insert Into #Scale ([Scale]) Values (99)
		Create Table #Score (
			[Score] int,
			)
		Insert Into #Score ([Score]) Values (0)
		Insert Into #Score ([Score]) Values (1)
		Insert Into #Score ([Score]) Values (2)
		Insert Into #Score ([Score]) Values (3)
		Insert Into #Score ([Score]) Values (4)
		Insert Into #Score ([Score]) Values (5)
		Insert Into #Score ([Score]) Values (6)
		Insert Into #Score ([Score]) Values (7)
		Insert Into #Score ([Score]) Values (8)
		Insert Into #Score ([Score]) Values (9)
		Insert Into #Boston1A ([Formulation], [Scale], [Right], [RightP], [Transverse], [TransverseP], [Left], [LeftP])
		Select 
			List.ListItemText As [Formulation], 
			[Scale]=[Scale],
			[Right]=0,
			[RightP]=0,
			[Transverse]=0,
			[TransverseP]=0,
			[Left]=0,
			[LeftP]=0
		From 
			[dbo].[ERS_Lists] List
			, #Scale
		Where list.ListDescription='Bowel_Preparation' And Suppressed=0 And List.ListItemText<>'(none selected)'
		Order By 1
		Insert Into #Boston0A ([Formulation], [Scale],[Right], [Transverse], [Left])
			Select [Formulation], Scale As [Scale],
				IsNull(Sum(Case [OnRight] When Scale Then 1 Else 0 End),0) As [Right], 
				IsNull(Sum(Case [OnTransverse] When Scale Then 1 Else 0 End),0) As [Transverse], 
				IsNull(Sum(Case [OnLeft] When Scale Then 1 Else 0 End),0) As [Left] 
				From v_rep_BowelPreparation B
				,#Scale S
			Where OnNoBowelPrep=0 And CreatedOn>=@From And CreatedOn<=@To And B.OnNoBowelPrep=0 And ProcedureType=@ProcType And Formulation<>'(none selected)'
			Group By [Formulation], Scale
			Order By [Formulation], Scale
		Insert Into #Boston0B ([Formulation], [Right], [Transverse], [Left])
			Select [Formulation], Sum([Transverse]) As [Right], Sum([Transverse]) As [Transverse], Sum ([Left]) As [Left] From #Boston0A Where Formulation<>'(none selected)'
			Group By [Formulation]
		Insert Into #Boston1B ([Formulation], [Scale], [Right], [RightP], [Transverse], [TransverseP], [Left], [LeftP])
			Select A.Formulation, A.[Scale] As [Scale]
				, A.[Right] As [Right], A.[Right]/Case B.[Right] When 0 Then 1 Else B.[Right] End As [RightP]
				, A.[Transverse] As [Transverse], A.[Transverse]/Case B.[Transverse] When 0 Then 1 Else B.[Transverse] End As [TransverseP]
				, A.[Left] As [Left], A.[Left]/Case B.[Left] When 0 Then 1 Else B.[Left] End As [LeftP]
			From #Boston0A A, #Boston0B B Where A.Formulation=B.Formulation And A.Formulation<>'(none selected)'
		Update #Boston1A Set [Right]=B.[Right], [RightP]=B.[RightP], [Transverse]=B.[Transverse], [TransverseP]=B.[TransverseP], [Left]=B.[Left], [LeftP]=B.[LeftP] From #Boston1A A, #Boston1B B Where A.[Formulation]=B.[Formulation] And A.[Scale]=B.[Scale] And B.Formulation<>'(none selected)'
		Insert Into #Boston2A (Formulation, Score, Frequency, Fx)
		Select List.ListItemText As [Formulation], S.Score, 0 As [Frequency], 0 As [Fx] From [dbo].[ERS_Lists] List, #Score S Where list.ListDescription='Bowel_Preparation' And Suppressed=0  And list.ListItemText<>'(none selected)'
		/*Calculating frecuencies*/
		Insert Into #Boston2B (Formulation, Score, Frequency, Fx)
		Select [Formulation],
			B.OnTotalScore As [Scale] , Count(*), (B.OnTotalScore)*Count(*) As Fx
			From v_rep_BowelPreparation B
		Where CreatedOn>=@From And CreatedOn<=@To And OnNoBowelPrep=0 And ProcedureType=@ProcType And Formulation<>'(none selected)'
		Group By Formulation, B.OnTotalScore
		/*Merging #boston2A From #Boston2B*/
		Update #Boston2A Set Frequency=B.Frequency, Fx=B.FX From #Boston2A A, #Boston2B B Where A.[Formulation]=B.[Formulation] And A.[Score]=B.[Score] And B.Formulation<>'(none selected)'
		/*Calculating the Means of Scores*/
		Insert Into #Boston3 (Formulation, NoOfProcs, MeanScore)
			Select [Formulation],IsNull(Sum(Frequency),.0) As NoOfProcs, IsNull(Sum(Fx),.0)
			/Case When IsNull(Sum(Frequency),1.0)=0 Then 1 Else IsNull(Sum(Frequency),1.0) End As MeanScore From #Boston2A 
			Group By [Formulation]-- Having Sum(Frequency)>0
		/*Cleanning the user's data*/
		Delete ERS_ReportBoston3 Where UserID=@UserID
		Delete ERS_ReportBoston2 Where UserID=@UserID
		Delete ERS_ReportBoston1 Where UserID=@UserID
		/*Inserting results into User's tables*/
		Insert Into ERS_ReportBoston1 (UserID, Formulation, Scale, [Right], [RightP], [Transverse], [TransverseP], [Left], [LeftP])
			Select UserID=@UserID, Formulation, Scale, [Right], [RightP], [Transverse], [TransverseP], [Left], [LeftP] From #Boston1A
		Insert Into ERS_ReportBoston2 (UserID, Formulation, Score, Frequency, FX)
			Select UserID=@UserID, Formulation, Score, Frequency, FX From #Boston2A
		Insert Into ERS_ReportBoston3 (UserID, Formulation, NoOfProcs, MeanScore)
			Select UserID=@UserID, Formulation, NoOfProcs, MeanScore From #Boston3
		/*Output*/
			Select RP1.UserID, RP1.Formulation, Scale, [Right], RightP, Transverse, TransverseP, [Left], LeftP
			,(Select IsNull(Frequency,0) From ERS_ReportBoston2 RB2 Where RP1.UserID=RB2.UserID And RP1.Formulation=RB2.Formulation And Score=1) As [1]
			,(Select IsNull(Frequency,0) From ERS_ReportBoston2 RB2 Where RP1.UserID=RB2.UserID And RP1.Formulation=RB2.Formulation And Score=2) As [2]
			,(Select IsNull(Frequency,0) From ERS_ReportBoston2 RB2 Where RP1.UserID=RB2.UserID And RP1.Formulation=RB2.Formulation And Score=3) As [3]
			,(Select IsNull(Frequency,0) From ERS_ReportBoston2 RB2 Where RP1.UserID=RB2.UserID And RP1.Formulation=RB2.Formulation And Score=4) As [4]
			,(Select IsNull(Frequency,0) From ERS_ReportBoston2 RB2 Where RP1.UserID=RB2.UserID And RP1.Formulation=RB2.Formulation And Score=5) As [5]
			,(Select IsNull(Frequency,0) From ERS_ReportBoston2 RB2 Where RP1.UserID=RB2.UserID And RP1.Formulation=RB2.Formulation And Score=6) As [6]
			,(Select IsNull(Frequency,0) From ERS_ReportBoston2 RB2 Where RP1.UserID=RB2.UserID And RP1.Formulation=RB2.Formulation And Score=7) As [7]
			,(Select IsNull(Frequency,0) From ERS_ReportBoston2 RB2 Where RP1.UserID=RB2.UserID And RP1.Formulation=RB2.Formulation And Score=8) As [8]
			,(Select IsNull(Frequency,0) From ERS_ReportBoston2 RB2 Where RP1.UserID=RB2.UserID And RP1.Formulation=RB2.Formulation And Score=9) As [9]
			, RP3.NoOfProcs
			, RP3.MeanScore
			, Case @ProcType When 'COL' Then 'Colonoscopy' When 'SIG' Then 'Sigmoidoscopy' Else 'Unknow procedure type' End As ProcType
			,(Select IsNull(OnNoBowelPrep,0) From [dbo].[v_rep_BowelPreparation] Where ProcedureType=@ProcType And CreatedOn>=@From And CreatedOn<=@To) As NoBP
			, @From As [From]
			, @To As [To]
			From ERS_ReportBoston1 RP1, ERS_ReportBoston3 RP3
			Where RP3.UserID=RP1.UserID And RP3.Formulation=RP1.Formulation
			Order By RP1.Formulation, Scale
	End
End
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSC05', 'S';
GO

Create Proc [dbo].[sp_rep_GRSC05] @UserID INT=NULL, @ProcType VARCHAR(3)=NULL As
Begin
	SET NOCOUNT ON
	If @UserID Is Null
	Begin
		Raiserror('The @UserID parameter is missing a value',11,1)
		PRINT 'Sintax:'
		Print '	Exec sp_rep_GRSC05 1 @UserID=[UserID], @ProcType=[COL]/[SIG]'
		Print '	[UserID]: Session Value of PKUserId'
		Print '	[COL]: Colonoscopy'
		Print '	[SIG]: Sigmoidoscopy'
		Set @UserID=0
		Return
	End
	If @ProcType IS NULL
	Begin
		Raiserror('The @ProcType parameter is missing a value',11,1)
		PRINT 'Sintax:'
		Print '	Exec sp_rep_GRSC05 1 @UserID=[UserID], @ProcType=[COL]/[SIG]'
		Print '	[UserID]: Session Value of PKUserId'
		Print '	[COL]: Colonoscopy'
		Print '	[SIG]: Sigmoidoscopy'
		Set @ProcType=''
		Return
	End
	Select 
		ListItemText,
		(Select IsNull(Sum(OffQualityGood),0) From v_rep_BowelPreparation Where OnFormulation=ListItemNo And CreatedOn>=filter.FromDate And CreatedOn<=filter.ToDate And ProcedureType=@ProcType) As Good,
		(Select Convert(numeric(20,4),Convert(numeric(20,2),IsNull(Sum(OffQualityGood),0))/Case IsNull(Sum(OffQualityGood+OffQualitySatisfactory+OffQualityPoor),1.0) When 0 Then 1 Else IsNull(Sum(OffQualityGood+OffQualitySatisfactory+OffQualityPoor),1.0) End) From v_rep_BowelPreparation Where OnFormulation=ListItemNo And CreatedOn>=filter.FromDate And CreatedOn<=filter.ToDate And ProcedureType=@ProcType) As GoodP,
		(Select IsNull(Sum(OffQualitySatisfactory),0) From v_rep_BowelPreparation Where OnFormulation=ListItemNo And CreatedOn>=filter.FromDate And CreatedOn<=filter.ToDate And ProcedureType=@ProcType) As Satisfactory,
		(Select Convert(numeric(20,4),Convert(numeric(20,2),IsNull(Sum(OffQualitySatisfactory),0))/Case IsNull(Sum(OffQualityGood+OffQualitySatisfactory+OffQualityPoor),1.0) When 0 Then 1 Else IsNull(Sum(OffQualityGood+OffQualitySatisfactory+OffQualityPoor),1.0) End) From v_rep_BowelPreparation Where OnFormulation=ListItemNo And CreatedOn>=filter.FromDate And CreatedOn<=filter.ToDate And ProcedureType=@ProcType) As SatisfactoryP,
		(Select IsNull(Sum(OffQualityPoor),0) From v_rep_BowelPreparation Where OnFormulation=ListItemNo And CreatedOn>=filter.FromDate And CreatedOn<=filter.ToDate And ProcedureType=@ProcType) As Poor,
		(Select Convert(numeric(20,4),Convert(numeric(20,2),IsNull(Sum(OffQualityPoor),0))/Case IsNull(Sum(OffQualityGood+OffQualitySatisfactory+OffQualityPoor),1.0) When 0 Then 1 Else IsNull(Sum(OffQualityGood+OffQualitySatisfactory+OffQualityPoor),1.0) End) From v_rep_BowelPreparation Where OnFormulation=ListItemNo And CreatedOn>=filter.FromDate And CreatedOn<=filter.ToDate And ProcedureType=@ProcType) As PoorP,
		(Select IsNull(Sum(OffQualityGood+OffQualitySatisfactory+OffQualityPoor),0) From v_rep_BowelPreparation Where OnFormulation=ListItemNo And ProcedureType=@ProcType And CreatedOn>=filter.FromDate And CreatedOn<=filter.ToDate) As Total
	From [dbo].[ERS_Lists], ERS_ReportFilter filter
	Where ListDescription='Bowel_Preparation' And Suppressed=0 And filter.UserID=@UserID
End
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSC06', 'S';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create Proc [dbo].[sp_rep_GRSC06] @UserId INT=NULL, @AppId VARCHAR(1)=NULL As
Begin
	Set NoCount On
	Begin Try
		Declare @str VARCHAR(4000)
		Set @str=''''
		If @UserID Is Null
		Begin
			Raiserror(''Error: @UserID is a required parameter'',11,1)
		End
		Declare @ProcedureTypeId INT
		Set @ProcedureTypeId=3
	    CREATE TABLE #tmpBowelPreparationList1 ([ListItemText] VARCHAR(150),[ListItemNo] INT)
		CREATE TABLE #tmpBowelPreparationList2 ([ListItemText] VARCHAR(150),[ListItemNo] INT)

		If @AppId Is Null Set @AppId=''''
		Insert Into #tmpBowelPreparationList2 ([ListItemText], [ListItemNo])
			Select L.ListItemText, L.ListItemNo From ERS_Lists L Where L.ListDescription=''Bowel_Preparation''
		Insert Into #tmpBowelPreparationList1 ([ListItemText], [ListItemNo])
		SELECT DISTINCT Lists.[List item text] As [ListItemText], Lists.[List item no]  As [ListItemNo] FROM Lists WHERE (((Lists.[List description])=''Preparation''))
		SELECT Patient.Surname, Patient.Forename1, Patient.[Dateofbirth], Episode.[Patient No], Patient.[HospitalNumber], 
			Episode.[Episode No],Episode.[Episode date]
			, [Colon Procedure].Endoscopist2, (Select C.[Consultant/operator] From [Consultant/Operators] C Where C.[Consultant/operator ID]=[Colon Procedure].Endoscopist2) As Consultant
			,#tmpBowelPreparationList1.[ListItemText] AS [Bowel Prep], 
			Case [Colon Indications].Quality When 4 Then ''No bowel preparation'' When 1 Then ''Good'' When 2 Then ''Satisfactory'' When 3 Then ''Poor'' Else '''' End As Quality
			--,Count(*) As Records
		FROM [Colon Procedure] INNER JOIN ((ERS_VW_Patients Patient INNER JOIN (Episode INNER JOIN [Colon Indications] ON Episode.[Episode No] = [Colon Indications].[Episode No]) 
			ON Patient.[ComboID] = Episode.[Patient No]) INNER JOIN #tmpBowelPreparationList1 ON 
			[Colon Indications].[Bowel preparation] = #tmpBowelPreparationList1.[ListItemNo]) 
			ON [Colon Procedure].[Episode No] = Episode.[Episode No] 
			And [Colon Procedure].[Procedure type]=0
		--Group By Episode.[Patient No], Episode.[Episode No]--, [Episode date]
		--, Patient.Surname, Patient.Forename, Patient.[Date of birth], Patient.[Case note no]--,[Colon Procedure].Endoscopist2
		--, #tmpBowelPreparationList1.[ListItemText], Quality
		ORDER BY Episode.[Patient No], Episode.[Episode No], [Episode date] ASC, Endoscopist2 DESC
		Drop Table #tmpBowelPreparationList1
	End Try
	Begin Catch
		Print @Str
		--@ProcType VARCHAR(3)=NULL, @Complications BIT=NULL, @ReversalAgents BIT=NULL, @Endoscopist1 BIT=NULL, @Endoscopist2 BIT=NULL, @AppId VARCHAR(1)=NULL
		Print ''Syntax error: [dbo].[sp_rep_GRSC06] @UserId INT=NULL, @App VARCHAR(1)=NULL''
		Print ''@UserId: ERS User ID''
		Print ''@AppIs: E/U Null for All''
	End Catch
End
'
END

GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSC07', 'S';
GO

Create Proc [dbo].[sp_rep_GRSC07] @UserID INT=NULL, @ProcType VARCHAR(3)=NULL, @OutputAs VARCHAR(1)=NULL, @Check BIT=NULL, @Version VARCHAR(3)=NULL, @FromAge INT=NULL, @ToAge INT=NULL As
Begin
	SET NOCOUNT ON
	Declare @FromDate DATE
	Declare @ToDate DATE
	DECLARE @Columns As NVARCHAR(MAX)
	SELECT @Columns=COALESCE(@Columns+',','')+ Drug FROM (SELECT Distinct Drug FROM v_rep_MedicationArray WHERE ConsultantTypeId=1) AS K
	
	SELECT @Columns
	If @UserID Is Null 
	Begin
		Raiserror('The @UserID parameter is missing a value',11,1)
		Print 'Sintax:'
		Print '	Exec sp_rep_GRSC07 @UserID=[UserID], @ProcType=[Procedure Type], @OutputAs=[Output As], @Check=[Boolean], @Version=[Release], @FromAge=[Min. Age], @ToAge=[Max. Age]'
		Print ''
		Print '	[UserID]: Session Value of PKUserId'
		Print '	ProcType: Required parameter. OGD/ERC/PRO/COL/SIG/EUS/HPB'
		Print '	Output As: Required parameter. 1 (List of Patients), 2 (Mean dosage values), 3 (Median dosage values).'
		Print '	Check: TRUE or FALSE. Default value is FALSE'
		--Print '	ClosedList: If TRUE ths list will be closed, if FALSE, the drugs listed will be only the used drugs. Default value is TRUE'
		Print '	[Boolean]: TRUE / FALSE / NULL (Default value will be FALSE)'
		Print '	[Min. Age]: Min Age. By default 0'
		Print '	[Max. Age]: Max Age. By default 200'
		Print '	[Release]: UGI / ERS / NULL (Default value will be both Releases)'
		Set @UserID=0
	End
	If @ProcType Is Null Raiserror('The @ProcType parameter is missing a value',11,1)
	If @OutputAs Is Null Raiserror('The @OutputAs parameter is missing a value',11,1)
	If @Check Is Null Set @Check='FALSE'
	Select @FromDate=FromDate, @ToDate=ToDate From ERS_ReportFilter Where UserID=@UserID
	Declare @Qry VARCHAR(4000)
	DECLARE @SQL AS NVARCHAR(MAX)
	SET @Columns='['+REPLACE(@Columns,',','],[')+']'
	PRINT '1 (List of Patients)'
	SET @SQL='SELECT * FROM '
	SET @SQL=@SQL+' (SELECT ConsultantName'+CASE WHEN @OutputAs=1 Then ', PatientName' Else ''End+', Drug, '+CASE WHEN @OutputAs=2 Then 'Dose' Else 'Median' End
	SET @SQL=@SQL+' FROM v_rep_MedicationArray WHERE ConsultantTypeId=1'
	SET @SQL=@SQL+' AND Age>='+CONVERT(NVARCHAR(20),@FromAge)
	SET @SQL=@SQL+' AND Age<='+CONVERT(NVARCHAR(20),@ToAge)
	SET @SQL=@SQL+' ) AS L1'
	SET @SQL=@SQL+' PIVOT ('
	SET @SQL=@SQL+' '+CASE WHEN @OutputAs=2 Then 'AVG(Dose)' Else 'AVG(Median)' End
	SET @SQL=@SQL+' FOR [Drug] IN ('+@Columns+')'
	SET @SQL=@SQL+' ) AS PVT'
	EXEC (@SQL)
End
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'sp_rep_GRSC08', 'S';
GO

Create Proc [dbo].[sp_rep_GRSC08] @UserID INT=NULL, @UnitAsAWhole BIT=NULL, @ListPatients BIT=NULL As
Begin
	SET NOCOUNT ON
	Declare @FromDate DATE
	Declare @ToDate DATE
	If @UserID Is Null 
	Begin
		Raiserror('The @UserID parameter is missing a value',11,1)
		Print 'Sintax:'
		Print '	Exec sp_rep_GRSC08 @UserID=[UserID], @UnitAsAWhole=[Boolean], @ListPatients=[Boolean]'
		Print ''
		Print '	[UserID]: Session Value of PKUserId'
		Print '	[Boolean]: TRUE / FALSE / NULL (Default value will be FALSE)'
		Print '	[Release]: UGI / ERS / NULL (Default value will be both Releases)'
		Set @UserID=0
	End
	Select @FromDate=FromDate, @ToDate=ToDate From ERS_ReportFilter Where UserID=@UserID
	If @UnitAsAWhole IS NULL Set @UnitAsAWhole='FALSE'
	If @ListPatients IS NULL Set @ListPatients='FALSE'
	Create Table #GRSC08(Consultant NVARCHAR(150), Result VARCHAR(150), SuccessTo VARCHAR(150), CNN VARCHAR(50), PatientName VARCHAR(150), ProcedureDate Date, Age INT, FailureReason VARCHAR(150), 
		CarriedOutN Numeric(20,1) Default 1, SuccessN Numeric(20,2) Default 0, FailedN Numeric(20,2) Default 0, NotRecordedN Numeric(20,2) Default 0, SuccessP Numeric(20,4) Default 0, FailedP Numeric(20,4) Default 0, NotRecordedP Numeric(20,4) Default 0, Id INT Identity(1,1) PRIMARY KEY CLUSTERED)
	If @UnitAsAWhole=1
	Begin
		Insert Into #GRSC08 (Consultant, Result, SuccessTo, FailureReason, CNN, PatientName, ProcedureDate, Age, CarriedOutN, SuccessN, FailedN, NotRecordedN, SuccessP, FailedP, NotRecordedP)
		Select ' Unit as a Whole', Result='', SuccessTo='', FailureReason='', CNN='', PatientName='', ProcedureDate='', 0 As Age, 
		IsNull(Sum(CarriedOut),0) As CarriedOutN, 
		IsNull(Sum(OGDSuccess),0) As SuccessN, 
		IsNull(Sum(OGDFailed),0) As FailedN, 
		IsNull(Sum(CarriedOut-OGDSuccess-OGDFailed),0) As NotRecordedP,
		Convert(Numeric(20,4),IsNull(Sum(OGDSuccess),0))/Convert(Numeric(22,4),IsNull(Sum(CarriedOut),1)) As SuccessP, 
		Convert(Numeric(20,4),IsNull(Sum(OGDFailed),0))/Convert(Numeric(22,4),IsNull(Sum(CarriedOut),1)) As FailedP, 
		Convert(Numeric(20,4),IsNull(Sum(NotRecorded),0))/Convert(Numeric(22,4),IsNull(Sum(CarriedOut),1)) As notRecordedP
		From
				v_rep_GRSC08 Procs
				,v_rep_Consultants C
				,ERS_ReportConsultants RC
				,ERS_ReportFilter RF
			Where ((Procs.Release='ERS' And Endoscopist=C.ReportID) Or (Procs.Release='UGI' And Endoscopist=C.UGIID))
				And C.ReportID=RC.ConsultantID
				And RC.UserID=@UserID 
				And RC.UserID=RF.UserID
				And Procs.CreatedOn>=RF.FromDate And Procs.CreatedOn<=RF.ToDate 
	End
	Insert Into #GRSC08 (Consultant, Result, SuccessTo, FailureReason, CNN, PatientName, ProcedureDate, Age, CarriedOutN, SuccessN, FailedN, NotRecordedN, SuccessP, FailedP, NotRecordedP)
		Select Procs.Consultant, Result=Case When OGDSuccess=1 Then 'Success of intubation' Else Case When OGDFailed=1 Then 'Failed' Else 'Not recorded' End End, SuccessTo=OGDResult, FailureReason='', CNN='', 
		PatientName='', '' As CreatedOn, 0 As Age,
			IsNull(Sum(CarriedOut),0) As CarriedOutN, 
			IsNull(Sum(OGDSuccess),0) As SuccessN, 
			IsNull(Sum(OGDFailed),0) As FailedN, 
			IsNull(Sum(CarriedOut-OGDSuccess-OGDFailed),0) As NotRecordedN,
			Convert(Numeric(20,4),IsNull(Sum(OGDSuccess),0))/Convert(Numeric(22,4),IsNull(Sum(CarriedOut),1)) As SuccessP, 
			Convert(Numeric(20,4),IsNull(Sum(OGDFailed),0))/Convert(Numeric(22,4),IsNull(Sum(CarriedOut),1)) As FailedP, 
			Convert(Numeric(20,4),IsNull(Sum(NotRecorded),0))/Convert(Numeric(22,4),IsNull(Sum(CarriedOut),1)) As notRecordedP
			From
				v_rep_GRSC08 Procs
				,v_rep_Consultants C
				,ERS_ReportConsultants RC
				,ERS_ReportFilter RF
			Where ((Procs.Release='ERS' And Endoscopist=C.ERSID) Or (Procs.Release='UGI' And Endoscopist=C.UGIID))
				And C.ReportID=RC.ConsultantID
				And RC.UserID=RF.UserID
				And Procs.CreatedOn>=RF.FromDate And Procs.CreatedOn<=RF.ToDate 
				And RC.UserID=@UserID 
			Group By Procs.Consultant, Case When OGDSuccess=1 Then 'Success of intubation' Else Case When OGDFailed=1 Then 'Failed' Else 'Not recorded' End End, OGDResult
		If @ListPatients=1
		Begin
			Insert Into #GRSC08 (Consultant, Result, SuccessTo, FailureReason, CNN, PatientName, ProcedureDate, Age, CarriedOutN, SuccessN, FailedN, NotRecordedN, SuccessP, FailedP, NotRecordedP)
				Select Procs.Consultant, Result=Case When OGDSuccess=1 Then 'Success of intubation' Else Case When OGDFailed=1 Then 'Failed' Else 'Not recorded' End End, SuccessTo=OGDResult, FailureReason=ReasonForFailure, CNN, 
					PatientName=IsNull(Procs.Forename,'')+' '+IsNull(Procs.Surname,''), CreatedOn As ProcedureDate, Age, CarriedOutN=1, SuccessN=OGDSuccess, FailedN=OGDFailed, NotRecordedN=1-OGDSuccess-OGDFailed, SuccessP=0, FailedP=0, NotRecordedP=0
				From
					v_rep_GRSC08 Procs
					,v_rep_Consultants C
					,ERS_ReportConsultants RC
					,ERS_ReportFilter RF
				Where ((Procs.Release='ERS' And Endoscopist=C.ERSID) Or (Procs.Release='UGI' And Endoscopist=C.UGIID))
					And C.ReportID=RC.ConsultantID
					And RC.UserID=RF.UserID
					And Procs.CreatedOn>=RF.FromDate And Procs.CreatedOn<=RF.ToDate 
					And OGDSuccess<>1
					And RC.UserID=@UserID 
		End
	Select * From #GRSC08
End
GO




EXEC DropIfExist 'usp_rep_UpdateReportParamFilterRow', 'S'
GO
----#####################################

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shawkat Osman
-- Create date: 2017-06-20
-- Description:	This is to sanitize William's InLine SQL statements in .Net page-behind code...
--				William is entering a new Row in the ReportFilter Table- with a User ID and other Date variables- which are used in his many reports!
-- =============================================
CREATE PROCEDURE dbo.usp_rep_UpdateReportParamFilterRow
(
	  @CurrentUserID 	AS INT = 1
	, @FromDate			AS DATETIME
	, @ToDate			AS DATETIME
	, @TypesOfEndoscopists AS INT
	, @HideSuppressed	AS BIT
	, @OGD				AS BIT
	, @Sigmoidoscopy	AS BIT
	, @PEGPEJ			AS BIT
	, @Colonoscopy		AS BIT
	, @ERCP				AS BIT
	, @Bowel			AS BIT
	, @BowelStandard	AS BIT
	, @BowelBoston		AS BIT
	, @Anonymise		AS BIT
)
AS
BEGIN
	SET NOCOUNT ON;
	--## First Delete from [ERS_ReportConsultants]- whatever the User has selected before!
	BEGIN TRY
		Delete ERS_ReportConsultants Where UserID= @CurrentUserID;

		Update [dbo].[ERS_ReportFilter]	
			SET [UserID]			= @CurrentUserID
				,[ReportDate]		= GetDate()
				,[FromDate]			= @FromDate
				,[ToDate]			= @ToDate
				,[TypesOfEndoscopists] = @TypesOfEndoscopists
				,[HideSuppressed]	= @HideSuppressed
				,[OGD]				= @OGD
				,[Sigmoidoscopy]	= @Sigmoidoscopy
				,[PEGPEJ]			= @PEGPEJ
				,[Colonoscopy]		= @Colonoscopy
				,[ERCP]				= @ERCP
				,[Bowel]			= @Bowel
				,[BowelStandard]	= @BowelStandard
				,[BowelBoston]		= @BowelBoston
				,[Anonymise]		= @Anonymise
		WHERE UserID = @CurrentUserID;
	END TRY
	BEGIN CATCH
	    SELECT 
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() as ErrorState,
			ERROR_PROCEDURE() as ErrorProcedure,
			ERROR_LINE() as ErrorLine,
			ERROR_MESSAGE() as ErrorMessage;
	END CATCH

	RETURN 1;

END
GO



EXEC DropIfExist 'usp_rep_ConsultantTypes', 'S'
GO
--######################################
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shawkat Osman
-- Create date: 2017-06-20
-- Description:	A Common stored proc to list the Tye of Consultants
-- =============================================
CREATE  PROCEDURE [dbo].[usp_rep_ConsultantTypes]
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





DROP TABLE #variables
GO