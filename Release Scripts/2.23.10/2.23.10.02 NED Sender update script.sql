
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
