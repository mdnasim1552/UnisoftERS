------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Adrian Schaal on 24th October, 2023
-- TFS#	n/a
-- Description of change
-- ERS_SCH_ListSlots.IsOverBookedSlot column missing in script
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Adrian Schaal on 26th October, 2023
-- TFS#	n/a
-- Description of change
-- Removed (ERS_SCH_ListSlots.IsOverBookedSlot column missing in script) as it's already in earlier script.
------------------------------------------------------------------------------------------------------------------------
GO
---------------------------------------------------------
-- Update script for release 2.23.07.05
---------------------------------------------------------
DECLARE @Version AS VARCHAR(40) = '2.23.07.05'

IF NOT EXISTS(SELECT * FROM DBversion WHERE VersionNum = @Version)
	BEGIN 
		-- First time the script has been run
		INSERT INTO DBVersion VALUES (@Version, GETDATE())
	END 
ELSE
	BEGIN 
		-- script run more than once
		DECLARE @DBVersionCount as INT 

		SELECT @DBVersionCount = COUNT(*) 
		FROM DBVersion WHERE VersionNum LIKE @Version + '%'

		INSERT INTO DBVersion VALUES (@Version + ' (' + CONVERT(VARCHAR, @DBVersionCount) + ')', GETDATE())
	END 
GO
---------------------------------------------------------
GO 

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson 19/06/23
-- TFS#	2620
-- Description of change
-- FIT Positive value added to report
------------------------------------------------------------------------------------------------------------------------
GO

UPDATE dbo.ERS_Indications SET Description = 'value (m/g)' WHERE Description = 'fit value'
GO

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
GO
ALTER FUNCTION [dbo].[ProcedureIndicationsSummary]
(
	@ProcedureId int
)
RETURNS varchar(max)
AS
BEGIN
/****************************************************
DS Fix bug 2754 12/04/2023
*****************************************************/
DECLARE @IndicationsString  varchar(max), @ComorbidityString varchar(max), @DamagingDrugsString varchar(max), @PatientAllergiesString varchar(max), @PreviousSurgeryString varchar(max), 
		@PreviousDiseasesString varchar(max), @FamilyDiseaseHistoryString varchar(max), @ImagingString varchar(max), @ImagingOutcomeString varchar(max),
		@RetVal varchar(max)

SELECT @IndicationsString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN i.AdditionalInfo = 0 THEN [Description] ELSE AdditionalInformation END + CASE WHEN ISNULL(ChildIndicationId, 0) > 0 THEN '-' + 
	(SELECT CASE WHEN AdditionalInfo = 1 THEN [Description] + epi.AdditionalInformation ELSE [Description] END FROM ERS_Indications WHERE UniqueId = epi.ChildIndicationId) ELSE '' END AS [text()] 
	FROM ERS_ProcedureIndications epi 
	INNER JOIN ERS_Indications i on i.UniqueId = epi.IndicationId
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(i.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--rockall and baltchford scoring
SELECT @IndicationsString	= @IndicationsString + CASE WHEN CHARINDEX('melaena', @IndicationsString) > -1 OR CHARINDEX('haematemesis', @IndicationsString) > -1 THEN ' ' + dbo.fnBlatchfordRockallScores(@ProcedureId) ELSE '' END
--SELECT @IndicationsString = dbo.fnCapitalise(dbo.fnAddFullStop(@IndicationsString)) 

IF LEN(@IndicationsString) > 0
BEGIN
	IF charindex(',', reverse(@IndicationsString)) > 0
		SELECT @RetVal = STUFF(@IndicationsString, len(@IndicationsString) - (charindex(' ,', reverse(@IndicationsString)) - 1), 2, ' and ')
	ELSE
		SELECT @RetVal = @IndicationsString
END
-------------------CoMorbidity


SELECT @ComorbidityString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN AdditionalInformation = '' THEN [Description] ELSE AdditionalInformation END + CASE WHEN ISNULL(ChildComorbidityId, 0) > 0 THEN '-' + (SELECT [Description] FROM ERS_CoMorbidity WHERE UniqueId = ChildComorbidityId) ELSE '' END AS [text()] 
	FROM ERS_ProcedureComorbidity epc 
	INNER JOIN ERS_Comorbidity c on c.uniqueid = CoMorbidityId
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(c.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @ComorbidityString = dbo.fnCapitalise(dbo.fnAddFullStop(@ComorbidityString)) 

IF LEN(@ComorbidityString) > 0 
BEGIN
	IF charindex(',', reverse(@ComorbidityString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Co-morbidity: ' + STUFF(@ComorbidityString, len(@ComorbidityString) - charindex(' ,', reverse(@ComorbidityString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Co-morbidity: ' + @ComorbidityString
END

-------------------Damaging drugs

SELECT @DamagingDrugsString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ProcedureDamagingDrugs edd 
	INNER JOIN ERS_PotentialDamagingDrugs d on d.uniqueid = edd.DamagingDrugId
	WHERE edd.ProcedureId=@ProcedureId
	ORDER BY ISNULL(d.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @DamagingDrugsString = dbo.fnCapitalise(dbo.fnAddFullStop(@DamagingDrugsString)) 

DECLARE @AntiCoagDrugs bit = (SELECT AntiCoagDrugs FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
IF @AntiCoagDrugs IS NOT NULL
	If @AntiCoagDrugs = 1 SET @DamagingDrugsString = @DamagingDrugsString + '<br />The patient is taking anti-coagulant or anti-platelet medication.'

IF LEN(@DamagingDrugsString) > 0
BEGIN
	IF charindex(',', reverse(@DamagingDrugsString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Potential damaging drug(s): ' + STUFF(@DamagingDrugsString, len(@DamagingDrugsString) - charindex(' ,', reverse(@DamagingDrugsString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Potential damaging drug(s): ' + @DamagingDrugsString
END
-------------------Allergies

SELECT @PatientAllergiesString =
	CASE AllergyResult 
		WHEN -1 THEN 'unknown'
		WHEN 0 THEN 'none'
		WHEN 1 THEN a.AllergyDescription 
	END
	FROM ERS_PatientAllergies a
		INNER JOIN ERS_Procedures p ON p.PatientId = a.PatientId
	WHERE p.ProcedureId = @ProcedureId

--SELECT @PatientAllergiesString = dbo.fnCapitalise(dbo.fnAddFullStop(@PatientAllergiesString)) 

IF LEN(@PatientAllergiesString) > 0
BEGIN
	IF charindex(',', reverse(@PatientAllergiesString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Allergies: ' + STUFF(@PatientAllergiesString, len(@PatientAllergiesString) - charindex(' ,', reverse(@PatientAllergiesString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Allergies: ' + @PatientAllergiesString
END
-------------------Previous surgery

SELECT @PreviousSurgeryString =
	LTRIM(STUFF((SELECT DISTINCT ', ' + [Description] + CASE WHEN ListItemText = 'Unknown' THEN '' ELSE ' ' + ListItemText END as [text()] 
	FROM ERS_PatientPreviousSurgery h
	INNER JOIN ERS_PreviousSurgery r on r.UniqueID = h.PreviousSurgeryID
	INNER JOIN ERS_Lists l on l.ListItemNo = h.PreviousSurgeryPeriod and ListDescription = 'Follow up disease Period'
	INNER JOIN ERS_Procedures p on p.patientId = h.patientId 
	WHERE p.ProcedureId = @ProcedureId
	--ORDER BY ISNULL(r.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @PreviousSurgeryString = dbo.fnCapitalise(dbo.fnAddFullStop(@PreviousSurgeryString)) 

IF LEN(@PreviousSurgeryString) > 0
BEGIN
	IF charindex(',', reverse(@PreviousSurgeryString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous surgery: ' + STUFF(@PreviousSurgeryString, len(@PreviousSurgeryString) - charindex(' ,', reverse(@PreviousSurgeryString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous surgery: ' + @PreviousSurgeryString
END

-------------------ASA Status
DECLARE @ASAStatusString varchar(max) = 
	(SELECT [description]
	FROM ERS_PatientASAStatus pa 
		INNER JOIN ERS_ASAStatus a on a.uniqueid = pa.asastatusid
		INNER JOIN ERS_Procedures p ON p.ProcedureId = pa.ProcedureCreatedId
	WHERE   pa.ProcedureCreatedId = @ProcedureId)

If (@ASAStatusString is null) 
BEGIN
	SELECT TOP 1 @ASAStatusString = [description] 
						   FROM ERS_PatientASAStatus 
						   INNER JOIN ERS_ASAStatus ON UniqueId = ASAStatusId 
						   WHERE PatientId = (SELECT PatientId FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
						   ORDER BY ProcedureCreatedId DESC
END


IF LEN(@ASAStatusString) > 0 
BEGIN
	SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'ASA Status: ' + @ASAStatusString
END
-------------------Previous diseases

SELECT @PreviousDiseasesString =
	LTRIM(STUFF((SELECT DISTINCT ', ' + [Description] as [text()] 
	FROM ERS_PatientPreviousDiseases pd
	INNER JOIN ERS_PreviousDiseases d on d.UniqueID = pd.PreviousDiseaseID
	INNER JOIN ERS_Procedures p on p.patientId = pd.patientId 
	WHERE p.ProcedureId = @ProcedureId
	--ORDER BY ISNULL(r.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @PreviousDiseasesString = dbo.fnCapitalise(dbo.fnAddFullStop(@PreviousDiseasesString)) 

IF LEN(@PreviousDiseasesString) > 0
BEGIN
	IF charindex(',', reverse(@PreviousDiseasesString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous diseases: ' + STUFF(@PreviousDiseasesString, len(@PreviousDiseasesString) - charindex(' ,', reverse(@PreviousDiseasesString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous diseases: ' + @PreviousDiseasesString
END

-------------------Family disease history

SELECT @FamilyDiseaseHistoryString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN AdditionalInformation = '' THEN [Description] ELSE AdditionalInformation END AS [text()] 
	FROM ERS_PatientFamilyDiseaseHistory epi 
	INNER JOIN ERS_FamilyDiseaseHistory i on i.UniqueId = epi.FamilyDiseaseHistoryId
	INNER JOIN ERS_Procedures p on p.patientId = epi.patientId 
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(i.ListOrderBy, 999)
	FOR XML PATH('')),1,1,''))

--SELECT @FamilyDiseaseHistoryString = dbo.fnCapitalise(dbo.fnAddFullStop(@FamilyDiseaseHistoryString)) 

IF LEN(@FamilyDiseaseHistoryString) > 0
BEGIN
	IF charindex(',', reverse(@FamilyDiseaseHistoryString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Family history: ' + STUFF(@FamilyDiseaseHistoryString, len(@FamilyDiseaseHistoryString) - charindex(' ,', reverse(@FamilyDiseaseHistoryString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Family history: ' + @FamilyDiseaseHistoryString
END


-------------------Imaging

SELECT @ImagingString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ImagingMethods im 
	INNER JOIN ERS_ProcedureImagingMethod pim on im.uniqueid = pim.ImagingMethodId
	WHERE pim.ProcedureId=@ProcedureId
	FOR XML PATH('')),1,1,''))


IF LEN(@ImagingString) > 0
BEGIN
	IF charindex(',', reverse(@ImagingString)) > 0
		SELECT @ImagingString = STUFF(@ImagingString, len(@ImagingString) - charindex(' ,', reverse(@ImagingString)), 2, ' and ')
END


SELECT @ImagingOutcomeString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ImagingOutcomes imo 
	INNER JOIN ERS_ProcedureImagingOutcome pio on imo.uniqueid = pio.ImagingOutcomeId
	WHERE pio.ProcedureId=@ProcedureId
	FOR XML PATH('')),1,1,''))

IF ISNULL(@ImagingOutcomeString,'') <> ''
BEGIN
	SELECT @ImagingString = CASE WHEN ISNULL(@ImagingString, '') <> '' THEN @ImagingString + ' revealed ' ELSE '' END  + @ImagingOutcomeString
END


--SELECT @ImagingString = dbo.fnCapitalise(dbo.fnAddFullStop(@ImagingString)) 

IF LEN(@ImagingString) > 0
BEGIN
	IF charindex(',', reverse(@ImagingString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Imaging: ' + STUFF(@ImagingString, len(@ImagingString) - charindex(' ,', reverse(@ImagingString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Imaging: ' + @ImagingString
END


DECLARE @SmokingString varchar(max)


SELECT @SmokingString=
	LTRIM(STUFF((SELECT '  ' +SmokingDescription   AS [text()] 
	FROM ERS_ProcedureSmoking epi 
	WHERE ProcedureId=@ProcedureId
	FOR XML PATH('')),1,1,''))

--SELECT @SmokingString = dbo.fnCapitalise(dbo.fnAddFullStop(@SmokingString)) 

IF LEN(@SmokingString) > 0
BEGIN
	IF charindex(',', reverse(@SmokingString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Smoking:</b> ' + @SmokingString
		--SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Smoking:</b> ' + STUFF(@SmokingString, len(@SmokingString) - charindex(' ,', reverse(@SmokingString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Smoking:</b> ' + @SmokingString
END

DECLARE @LUTSIPSSString varchar(max)
DECLARE @LUTSIPSSTotalScoreString varchar(max)

SELECT @LUTSIPSSString=
	LTRIM(STUFF((SELECT ', ' + SectionName+'(Score:'+cast(ls.ScoreValue as varchar(10)) +')'   AS [text()] 
	from  ERS_ProcedureLUTSIPSSSymptoms a ,ERS_LUTSIPSSSymptoms b,ERS_LUTSIPSSSymptomSections s,ERS_IPSSScore ls
	where ProcedureId=@ProcedureId and a.LUTSIPSSSymptomId=b.UniqueId and b.LUTSIPSSSymptomSectionId=s.LUTSIPSSSymptomSectionId and SelectedScoreId>1 and a.SelectedScoreId=ls.ScoreId
	FOR XML PATH('')),1,1,''))

--SELECT @LUTSIPSSString = dbo.fnCapitalise(dbo.fnAddFullStop(@LUTSIPSSString)) 

select top 1  @LUTSIPSSTotalScoreString =  'Total Score :' + cast(TotalScoreValue as varchar(10)) 
from  ERS_ProcedureLUTSIPSSSymptoms where ProcedureId=@ProcedureId
IF LEN(@LUTSIPSSString) > 0
BEGIN
	IF charindex(',', reverse(@LUTSIPSSString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>LUTS\IPSS symptom score:</b>' + STUFF(@LUTSIPSSString, len(@LUTSIPSSString) - charindex(' ,', reverse(@LUTSIPSSString)), 2,  ' ' + @LUTSIPSSTotalScoreString + ' '+'<br />')
	     
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>LUTS\IPSS symptom score:</b> ' + @LUTSIPSSString

	--SELECT @RetVal = ISNULL(@RetVal + '<br />', '') +  @LUTSIPSSTotalScoreString
END

DECLARE @PreviousDiseaseUrologyString varchar(max)

SELECT @PreviousDiseaseUrologyString=
	LTRIM(STUFF((SELECT ', ' +case 
       when a.Description='Other' then b.AdditionalInformation
	   else a.Description
	  end
   AS [text()] 
	from ERS_PreviousDiseasesUrology a, ERS_ProcedurePreviousDiseasesUrology b 
	where a.UniqueId=b.PreviousDiseaseId
	and b.ProcedureId=@ProcedureId
	order by PreviousDiseaseSectionId
	FOR XML PATH('')),1,1,''))

--SELECT @PreviousDiseaseUrologyString = dbo.fnCapitalise(dbo.fnAddFullStop(@PreviousDiseaseUrologyString)) 


IF LEN(@PreviousDiseaseUrologyString) > 0
BEGIN
	IF charindex(',', reverse(@PreviousDiseaseUrologyString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Past Urological Histrory:</b>' + STUFF(@PreviousDiseaseUrologyString, len(@PreviousDiseaseUrologyString) - charindex(' ,', reverse(@PreviousDiseaseUrologyString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Past Urological Histrory:</b> ' + @PreviousDiseaseUrologyString

	
END

DECLARE @UrineDipstickCytologyString varchar(max)

SELECT @UrineDipstickCytologyString=
	LTRIM(STUFF((SELECT ', ' + b.Description + ' '+c.Description 
   AS [text()] 
	from ERS_ProcedureUrineDipstickCytology a,ERS_UrineDipstickCytology b,ERS_UrineDipstickCytology c
	where a.ProcedureId=@ProcedureId
	and a.UrineDipstickCytologyId=b.UniqueId
	and a.ChildUrineDipstickCytologyId=c.UniqueId
	order by b.UrineDipstickCytologySectionId,b.ListOrderBy
	FOR XML PATH('')),1,1,''))

--SELECT @UrineDipstickCytologyString = dbo.fnCapitalise(dbo.fnAddFullStop(@UrineDipstickCytologyString)) 


IF LEN(@UrineDipstickCytologyString) > 0
BEGIN
	IF charindex(',', reverse(@UrineDipstickCytologyString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Urine Dipstick And Cytology:</b>' + STUFF(@UrineDipstickCytologyString, len(@UrineDipstickCytologyString) - charindex(' ,', reverse(@UrineDipstickCytologyString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Urine Dipstick And Cytology:</b>' + @UrineDipstickCytologyString

	
END


--------------Broncs referral data
DECLARE @BroncoReferralDataString varchar(max), @DateBronchRequested DATETIME,
		@DateOfReferral DATETIME,
		@LCaSuspectedBySpecialist BIT,
		@CTScanAvailable BIT,
		@DateOfScan DATETIME

	SELECT @DateBronchRequested=DateBronchRequested,
		   @DateOfReferral=DateOfReferral,
		   @LCaSuspectedBySpecialist=LCaSuspectedBySpecialist,
		   @CTScanAvailable=CTScanAvailable,
		   @DateOfScan=DateOfScan
	FROM ERS_ProcedureBronchoReferralData
	WHERE ProcedureId = @ProcedureId

	IF @DateBronchRequested IS NOT NULL SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Date bronchoscopy requested ' + CONVERT(VARCHAR, @DateBronchRequested, 105) + '. '
	IF @DateOfReferral IS NOT NULL SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Date of referral ' + CONVERT(VARCHAR, @DateOfReferral, 105) + '. '
	IF @LCaSuspectedBySpecialist = 1 SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Lung Ca suspected by lung Ca specialist' + '. '
	IF @CTScanAvailable = 1 SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'CT scan available prior to bronchoscopy' + '. '
	IF @DateOfScan IS NOT NULL SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Date of scan ' + CONVERT(VARCHAR, @DateOfScan, 105) + '. '
	

	IF @BroncoReferralDataString IS NOT NULL SET @BroncoReferralDataString = 'Referal Data (' + RTRIM(@BroncoReferralDataString )+ ')'
	ELSE SET @BroncoReferralDataString = ''
	
	IF LEN(@BroncoReferralDataString) > 0
	BEGIN
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + @BroncoReferralDataString
	END


RETURN @RetVal
END
GO


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 20/06/2023
-- TFS#	2774
-- Description of change
-- Perforation site added to adverse events to appear as a textbox beside the selection
------------------------------------------------------------------------------------------------------------------------
GO


IF NOT EXISTS (SELECT 1 FROM dbo.ERS_AdverseEvents WHERE Description = 'site' AND NEDTerm = 'Perforation')
BEGIN
	DECLARE @PerforationId INT = (SELECT UniqueId FROM dbo.ERS_AdverseEvents WHERE Description = 'Perforation')
	INSERT INTO ERS_AdverseEvents (Description, NEDTerm, ParentId, AdditionalInfo, Suppressed, Complication)
	VALUES ('Site', 'Perforation', @PerforationId, 1, 0, 0)
	
	DECLARE @AdverseEventId INT = SCOPE_IDENTITY()

	INSERT INTO dbo.ERS_AdverseEventsProcedureTypes
	(
	    AdverseEventsId,
	    ProcedureTypeId
	)
	SELECT @AdverseEventId, ProcedureTypeId FROM dbo.ERS_AdverseEventsProcedureTypes WHERE AdverseEventsId = @PerforationId
END

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	: Andrea 20/06/2023
-- TFS#	2451
-- Description of change
-- Polpy matrix code added for ENT Ant in the colon regions (jejunum and ileum)
------------------------------------------------------------------------------------------------------------------------
GO


IF NOT EXISTS (SELECT 1 FROM dbo.ERS_DiagnosesMatrix WHERE DisplayName = 'polyp' AND Section = 'Colon' AND Code = 'D58P8')
BEGIN
	INSERT INTO dbo.ERS_DiagnosesMatrix
	(
	    DisplayName,
	    NED_Name,
	    EndoCode,
	    ProcedureTypeID,
	    Section,
	    OrderByNumber,
	    Code,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    NED_Include
	)
	VALUES
	(   'Polyp',    -- DisplayName - varchar(50)
	    NULL,    -- NED_Name - varchar(50)
	    NULL,    -- EndoCode - varchar(50)
	    8,       -- ProcedureTypeID - int
	    'Colon',    -- Section - varchar(50)
	    27, -- OrderByNumber - int
	    'D58P8',      -- Code - varchar(50)
	    NULL,    -- WhoUpdatedId - int
	    DEFAULT, -- WhoCreatedId - int
	    DEFAULT, -- WhenCreated - datetime
	    NULL,    -- WhenUpdated - datetime
	    0     -- NED_Include - bit
	    )
END
GO


ALTER TRIGGER [dbo].[TR_CommonAbnoLesions]
ON [dbo].[ERS_CommonAbnoLesions]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @Polyp VARCHAR(10) = 'False', 
						  @BenignTumour VARCHAR(10) = 'False', 
						  @MalignantTumour VARCHAR(10) = 'False', 
						  @SubmucosalTumour VARCHAR(10) = 'False', 
						  @FocalLesions VARCHAR(10) = 'False',
						  @SubmucoaslLesion VARCHAR(10) = 'False',
						  @FundicGlandPolyp VARCHAR(10) = 'False',
			@PolypTypeId int, @Region varchar(20), @ProcedureTypeId int, @MatrixCode varchar(50)
	
	IF EXISTS(SELECT * FROM INSERTED)
	BEGIN
		SELECT @site_id=SiteId,
				@Polyp = (CASE WHEN (ISNULL(Polyp,0) = 1) THEN 'True' ELSE 'False' END),
				@FocalLesions = (CASE WHEN (ISNULL(Focal,0) = 1) THEN 'True' ELSE 'False' END),
				@SubmucoaslLesion = (CASE WHEN (ISNULL(Submucosal,0) = 1) THEN 'True' ELSE 'False' END),
				@FundicGlandPolyp = (CASE WHEN (ISNULL(FundicGlandPolyp,0) = 1) THEN 'True' ELSE 'False' END),
				@PolypTypeId = PolypTypeId
				
		FROM INSERTED

		SELECT TOP 1 @ProcedureTypeId =  p.ProcedureType FROM ERS_Sites s INNER JOIN ERS_Procedures p ON p.ProcedureId = s.ProcedureId WHERE s.SiteId = @site_id
		--check if polyps = 1
		IF @Polyp = 'True' 
		BEGIN
			--check for polyp type
			DECLARE @PolypType VARCHAR(200) = (SELECT Description FROM ERS_PolypTypes WHERE UniqueId = @PolypTypeId)

			IF LOWER(@PolypType) = 'sessile'
			BEGIN
				--sessile polyps to produce a gastric tumour outcome depending on the tumour type
				IF EXISTS (SELECT 1 FROM ERS_CommonAbnoPolypDetails WHERE SiteId = @site_id AND Type = (SELECT UniqueId FROM ERS_TumourTypes WHERE Description = 'benign'))
					SET @BenignTumour = 'True'
				ELSE 
					SET @BenignTumour = 'False'

				IF EXISTS (SELECT 1 FROM ERS_CommonAbnoPolypDetails WHERE SiteId = @site_id AND Type = (SELECT UniqueId FROM ERS_TumourTypes WHERE Description = 'malignant'))
					SET @MalignantTumour = 'True'
				ELSE
					SET @MalignantTumour = 'False'
			END
			
			IF LOWER(@PolypType) = 'submucosal'  AND LOWER(@Region) = 'stomach'
				SET @SubmucoaslLesion = 'True'
			ELSE
				SET @SubmucoaslLesion = 'False'

		END
		
		IF @ProcedureTypeId IN (1,6,8)
		BEGIN
			SELECT @Region = dbo.fnSiteRegion(@site_id)

			IF LOWER(@Region) = 'stomach'
			BEGIN
				--SELECT @Polyp = CASE WHEN @FundicGlandPolyp = 'False' AND @BenignTumour = 'False' AND @MalignantTumour = 'False' AND @SubmucosalTumour = 'False' THEN 'True' ELSE 'False' END
				SET @MatrixCode = 'D40P1'
			END
			ELSE IF LOWER(@Region) = 'oesophagus'
				SET @MatrixCode = 'N2013'
			ELSE IF LOWER(@Region) = 'duodenum'
				SET @MatrixCode = 'D58P1'
			ELSE IF LOWER(@Region) = 'colon'
				SET @MatrixCode = 'D58P1'
				
		END
		ELSE IF @ProcedureTypeId IN (3,4,9)
		BEGIN
			SELECT @Region = dbo.fnSiteRegion(@site_id)

			IF @Polyp = 'True' AND @Region IN ('Rectum', 'Anal Margin')
				SET @MatrixCode = 'D4P3'

			IF @Polyp = 'True' AND @Region NOT IN ('Rectum', 'Anal Margin')
				SET @MatrixCode = 'D12P3'
		END

	END
	ELSE
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC abnormalities_common_lesions_summary_update @site_id

	IF @site_id IS NOT NULL
	BEGIN
		EXEC sites_summary_update @site_id

		EXEC diagnoses_control_save @site_id, @MatrixCode, @Polyp		
		--EXEC diagnoses_control_save @site_id, 'D86P1', @BenignTumour	
		--EXEC diagnoses_control_save @site_id, 'D87P1', @MalignantTumour	
		EXEC diagnoses_control_save @site_id, 'N2001', @FocalLesions
		EXEC diagnoses_control_save @site_id, 'D88P1', @SubmucosalTumour
		EXEC diagnoses_control_save @site_id, 'N2002', @SubmucoaslLesion
		EXEC diagnoses_control_save @site_id, 'N2019', @FundicGlandPolyp

	END
GO

PRINT N'  Adding RefreshSummary column to [dbo].[ers_trusts]...';
GO

IF NOT EXISTS (SELECT 1 FROM SYS.COLUMNS WHERE Name = 'RefreshSummary' AND OBJECT_ID = OBJECT_ID('ERS_Trusts'))
ALTER TABLE dbo.ers_trusts
ADD RefreshSummary bit NOT NULL
DEFAULT (1)

GO

PRINT N'  Creating [dbo].[fn_ShouldRefreshSummary]...';
GO
EXEC dbo.DropIfExist @ObjectName = 'fn_ShouldRefreshSummary',      -- varchar(100)
                     @ObjectTypePrefix = 'F' -- varchar(5)

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION[dbo].[fn_ShouldRefreshSummary]
(
	@TrustId int
)
RETURNS BIT
AS
BEGIN
	RETURN
	(
		SELECT RefreshSummary
		FROM ERS_Trusts
		WHERE TrustID = @TrustId
	)
END
GO

ALTER PROCEDURE [dbo].[sites_summary_update] (@SiteId INT, @RefreshReport BIT = 1)
AS
SET NOCOUNT ON

DECLARE @TrustId int
SELECT @TrustId = oh.TrustId
FROM ERS_Procedures p
JOIN ERS_Sites s ON s.ProcedureId = p.ProcedureId AND s.SiteId = @SiteId
JOIN ERS_OperatingHospitals oh ON oh.OperatingHospitalId = p.OperatingHospitalID

DECLARE @ReportSummaryRefresh int
SELECT @ReportSummaryRefresh = CAST([dbo].[fn_ShouldRefreshSummary](@TrustId) AS INT)

IF (@ReportSummaryRefresh + CAST(@RefreshReport AS INT) > 0)
BEGIN
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
		,@AbnormalProcedure BIT = 0

	BEGIN TRANSACTION

	BEGIN TRY
		SET @summaryAbnormalities = ''
		SET @summarySpecimens = ''
		SET @summaryTherapeutics = ''
		SET @summaryAbnormalitiesWithHyperLinks = ''
		SET @summarySpecimensWithHyperLinks = ''
		SET @summaryTherapeuticsWithHyperLinks = ''
		SET @siteIdStr = CONVERT(VARCHAR(10), @SiteId)
		SET @AbnormalProcedure = 0

		DECLARE @IsLymphNode VARCHAR(10) = 'False'
	
		--INSERT INTO  
		--	ERS_ErrorLog(ErrorMessage, ErrorTimestamp, ProductId, ProductVersion, UserId, HospitalId, OperatingHospitalId) 
		--VALUES 
		--	('SiteId: ' + CAST(@SiteId AS VARCHAR), GETDATE(), 1, '1', 1, 1, 1)
	
		SELECT @procId = p.ProcedureId
			,@procType = p.ProcedureType
			,@regionID = s.RegionId
			,@SiteNo = s.SiteNo
			,@AreaNo = ISNULL(AreaNo, 0)
			,@region = CASE 
				WHEN s.SiteNo = - 77
					THEN --SiteNo is set to -77 for sites By Distance (Col & Sig only)
						CONVERT(VARCHAR, XCoordinate) + CASE 
							WHEN YCoordinate IS NULL
								OR YCoordinate = 0
								THEN ' cm'
							ELSE (' to ' + CONVERT(VARCHAR, YCoordinate) + ' cm')
							END
				ELSE (
						SELECT r.Region
						FROM ERS_Regions r
						WHERE r.RegionId = s.RegionId
						)
				END
			,@IsLymphNode = CASE WHEN s.IsLymphNode = 1 THEN 'True' ELSE 'False' END
		FROM ERS_Sites s
		INNER JOIN ERS_Procedures p ON s.ProcedureId = p.ProcedureId
		--JOIN ERS_Regions r ON s.RegionId = r.RegionId
		WHERE SiteId = @SiteId

		IF @procType = 11 AND @IsLymphNode = 'True'
		BEGIN
			SELECT 
				@region = eeln.[Name] 
			FROM 
				dbo.ERS_EBUSLymphNodes AS eeln
				INNER JOIN dbo.ERS_Sites AS es
					ON es.EBUSLymphNodeSiteId = eeln.EBUSLymphNodeId
			WHERE
				es.SiteId = @SiteId
		END	

		SET @htmlAnchorCode = '<a href="#" class="sitesummary" onclick="OpenSiteDetails(''''' + @region + ''''',' + @siteIdStr + ',''''{0}'''',''''' + CONVERT(VARCHAR, @AreaNo) + ''''');">{1}</a>'

		--{0} is the name of the menu and {1} is the summary text
		DECLARE @SQLString NVARCHAR(MAX)
			,@QryString NVARCHAR(MAX)
			,@AbnoCheck BIT
		DECLARE @ProcedureType INT
			,@TableName VARCHAR(50)
			,@AbnoNodeName VARCHAR(50)
			,@Identifier VARCHAR(50)

		CREATE TABLE #QueryDetails (
			ProcType INT
			,TableName VARCHAR(50)
			,AbnoNodeName VARCHAR(50)
			,Identifier VARCHAR(50)
			);

		--Notes to appear on the report just after the Site X heading, before the abnormalities.
		INSERT INTO #QueryDetails
		SELECT @procType
			,'ERS_Sites'
			,''
			,'Additional notes'

		IF @procType IN (
				1
				,6
				) --Gastroscopy / EUS(OGD)
		BEGIN
			INSERT INTO #QueryDetails
			VALUES (
				@procType
				,'ERS_CommonAbnoAtrophic'
				,'Atrophic duodenum'
				,'Atrophic Duodenum'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoAchalasia'
				,'Achalasia'
				,'Achalasia'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoBarrett'
				,''
				,'Barretts Epithelium'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoDeformity'
				,'Deformity'
				,'Deformity'
				)
				,(
				@procType
				,'ERS_CommonAbnoDiverticulum'
				,'Diverticulum'
				,'Diverticulum/Other'
				)
				,(
				@procType
				,'ERS_CommonAbnoDuodenalUlcer'
				,''
				,CASE 
					WHEN @region = 'Jejunum'
						THEN 'Jejunal Ulcer'
					WHEN @region = 'Ileum'
						THEN 'Ileal Ulcer'
					ELSE 'Duodenal Ulcer'
					END
				)
				,(
				@procType
				,'ERS_CommonAbnoDuodenitis'
				,''
				,CASE 
					WHEN @region = 'Jejunum'
						THEN 'Jejunitis'
					WHEN @region = 'Ileum'
						THEN 'Ileitis'
					ELSE 'Duodenitis'
					END
				)
				,(
				@procType
				,'ERS_UpperGIAbnoGastricUlcer'
				,'Gastric ulcer'
				,'Gastric Ulcer'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoGastritis'
				,'Gastritis'
				,'Gastritis'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoHiatusHernia'
				,'Hiatus hernia'
				,'Hiatus Hernia'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoLumen'
				,'Lumen'
				,'Lumen'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoMalignancy'
				,'Malignancy'
				,'Malignancy'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoMiscellaneous'
				,''
				,'Miscellaneous'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoOesophagitis'
				,'Oesophagitis'
				,'Oesophagitis'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoPolyps'
				,'Polyps'
				,'Polyps'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoPostSurgery'
				,'Post surgery'
				,'Post Surgery'
				)
				,(
				@procType
				,'ERS_CommonAbnoScaring'
				,''
				,'Scarring/Stenosis'
				)
				,(
				@procType
				,'ERS_CommonAbnoTumour'
				,'Tumour'
				,'Tumour'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoVarices'
				,CASE 
					WHEN (
							SELECT isnull(Quantity, 0)
							FROM ERS_UpperGIAbnoVarices
							WHERE SiteId = @SiteId
							) = 1
						THEN 'Varix'
					ELSE 'Varices'
					END
				,'Varices'
				)
				,(
				@procType
				,'ERS_CommonAbnoVascularLesions'
				,'Vascular lesions'
				,'Vascular Lesions'
				)
				,(
				@procType
				,'ERS_EUSAbnoMediastinal'
				,'Mediastinal'
				,'Mediastinal'
				)
				,(
				@procType
				,'ERS_UpperGITherapeutics'
				,'Therapeutic procedure(s)'
				,'Therapeutic Procedures'
				)
				,(
				@procType
				,'ERS_UpperGISpecimens'
				,'Specimens taken'
				,'Specimens Taken'
				)
		END
	------###################################-------

		ELSE IF @procType IN (
				2
				,7
				) --ERCP / / EUS(HPB)
		BEGIN
			INSERT INTO #QueryDetails
			VALUES (
				@procType
				,'ERS_ERCPAbnoAppearance'
				,'Appearance'
				,'Appearance'
				)
				,(
				@procType
				,'ERS_CommonAbnoAtrophic'
				,'Atrophic duodenum'
				,'Atrophic Duodenum'
				)
				,(
				@procType
				,'ERS_CommonAbnoDiverticulum'
				,'Diverticulum'
				,'Diverticulum/Other'
				)
				,(
				@procType
				,'ERS_ERCPAbnoDiverticulum'
				,'Diverticulum'
				,CASE 
					WHEN @region IN (
							'Major Papilla'
							,'Minor Papilla'
							)
						THEN 'Diverticulum'
					ELSE 'Diverticulum/Other'
					END
				)
				,(
				@procType
				,'ERS_ERCPAbnoDuct'
				,'Duct'
				,CASE 
					WHEN @region = 'Gall Bladder'
						THEN 'Gall Bladder'
					ELSE 'Duct'
					END
				)
				,(
				@procType
				,'ERS_CommonAbnoDuodenalUlcer'
				,''
				,CASE 
					WHEN @region = 'Jejunum'
						THEN 'Jejunal Ulcer'
					WHEN @region = 'Ileum'
						THEN 'Ileal Ulcer'
					ELSE 'Duodenal Ulcer'
					END
				)
				,(
				@procType
				,'ERS_CommonAbnoDuodenitis'
				,''
				,CASE 
					WHEN @region = 'Jejunum'
						THEN 'Jejunitis'
					WHEN @region = 'Ileum'
						THEN 'Ileitis'
					ELSE 'Duodenitis'
					END
				)
				,(
				@procType
				,'ERS_ERCPAbnoParenchyma'
				,'Parenchyma'
				,'Parenchyma'
				)
				,(
				@procType
				,'ERS_CommonAbnoScaring'
				,''
				,'Scarring/Stenosis'
				)
				,(
				@procType
				,'ERS_CommonAbnoTumour'
				,''
				,'Tumour'
				)
				,(
				@procType
				,'ERS_ERCPAbnoTumour'
				,'Tumour'
				,'Tumour'
				)
				,(
				@procType
				,'ERS_ERCPAbnoIntrahepatic'
				,'Intrahepatic'
				,'Intrahepatic'
				)
				,(
				@procType
				,'ERS_CommonAbnoVascularLesions'
				,'Vascular lesions'
				,'Vascular Lesions'
				)
				,(
				@procType
				,'ERS_EUSAbnoMediastinal'
				,'Mediastinal'
				,'Mediastinal'
				)
				,(
				@procType
				,'ERS_ERCPTherapeutics'
				,'Therapeutic procedure(s)'
				,'Therapeutic Procedures'
				)
				,(
				@procType
				,'ERS_UpperGISpecimens'
				,'Specimens taken'
				,'Specimens Taken'
				)
		END


		--------###############################-----------


		ELSE IF @procType IN (
				3
				,4
				,5
				) --Colon/Sigmo/Procto
		BEGIN
			INSERT INTO #QueryDetails
			VALUES (
				@procType
				,'ERS_ColonAbnoCalibre'
				,'Calibre'
				,'Calibre'
				)
				,(
				@procType
				,'ERS_ColonAbnoDiverticulum'
				,'Diverticulum'
				,'Diverticulum'
				)
				,(
				@procType
				,'ERS_ColonAbnoHaemorrhage'
				,'Haemorrhage'
				,'Haemorrhage'
				)
				,(
				@procType
				,'ERS_ColonAbnoLesions'
				,'Lesions'
				,'Lesions'
				)
				,(
				@procType
				,'ERS_ColonAbnoMiscellaneous'
				,''
				,'Miscellaneous'
				)
				,(
				@procType
				,'ERS_ColonAbnoMucosa'
				,'Mucosa'
				,'Mucosa'
				)
				,(
				@procType
				,'ERS_ColonAbnoperianallesions'
				,'Perianal lesions'
				,'Perianal Lesions'
				)
				,(
				@procType
				,'ERS_ColonAbnoVascularity'
				,'Vascularity'
				,'Vascularity'
				)
				,(
				@procType
				,'ERS_UpperGITherapeutics'
				,'Therapeutic procedure(s)'
				,'Therapeutic Procedures'
				)
				,(
				@procType
				,'ERS_UpperGISpecimens'
				,'Specimens taken'
				,'Specimens Taken'
				)
		END


		---------#####################-------------



		ELSE IF @procType IN (8) --Antegrade
		BEGIN
			INSERT INTO #QueryDetails
			VALUES (
				@procType
				,'ERS_UpperGIAbnoPolyps'
				,'Polyp'
				,'Polyp'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoOesophagitis'
				,'Oesophagitis'
				,'Oesophagitis'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoHiatusHernia'
				,'Hiatus Hernia'
				,'Hiatus Hernia'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoBarrett'
				,'Barretts'
				,'Barretts'
				)			
				,(
				@procType
				,'ERS_UpperGIAbnoPostSurgery'
				,'Post Surgery'
				,'Post Surgery'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoVarices'
				,CASE 
					WHEN (
							SELECT ISNULL(Quantity, 0)
							FROM ERS_UpperGIAbnoVarices
							WHERE SiteId = @SiteId
							) = 1
						THEN 'Varix'
					ELSE 'Varices'
					END
				,'Varices'
				)
				,(
				@procType
				,'ERS_CommonAbnoAtrophic'
				,'Atrophic duodenum'
				,'Atrophic Duodenum'
				)	
				,(
				@procType
				,'ERS_UpperGIAbnoMiscellaneous'
				,'Miscellaneous'
				,'Miscellaneous'
				)			
				,(
				@procType
				,'ERS_CommonAbnoDuodenalUlcer'
				,''
				,CASE 
					WHEN @region = 'Jejunum'
						THEN 'Jejunal Ulcer'
					WHEN @region = 'Ileum'
						THEN 'Ileal Ulcer'
					ELSE 'Duodenal Ulcer'
					END
				)
				,(
				@procType
				,'ERS_CommonAbnoDuodenitis'
				,''
				,CASE 
					WHEN @region = 'Jejunum'
						THEN 'Jejunitis'
					WHEN @region = 'Ileum'
						THEN 'Ileitis'
					ELSE 'Duodenitis'
					END
				)
				,(
				@procType
				,'ERS_ColonAbnoLesions'
				,'Lesions'
				,'Lesions'
				)
				,(
				@procType
				,'ERS_CommonAbnoScaring'
				,'Scarring/Stenosis'
				,'Scarring/Stenosis'
				)
				,(
				@procType
				,'ERS_CommonAbnoTumour'
				,''
				,'Tumour'
				)
				,(
				@procType
				,'ERS_CommonAbnoVascularLesions'
				,'Vascular lesions'
				,'Vascular lesions'
				)
				,(
				@procType
				,'ERS_UpperGITherapeutics'
				,'Therapeutic procedure(s)'
				,'Therapeutic Procedures'
				)
				,(
				@procType
				,'ERS_UpperGISpecimens'
				,'Specimens taken'
				,'Specimens Taken'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoLumen'
				,'Lumen'
				,'Lumen'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoMalignancy'
				,'Malignancy'
				,'Malignancy'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoDeformity'
				,'Deformity'
				,'Deformity'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoGastricUlcer'
				,'Gastric ulcer'
				,'Gastric ulcer'
				)
				,(
				@procType
				,'ERS_UpperGIAbnoGastritis'
				,'Gastritis'
				,'Gastritis'
				)	
				,(
				@procType
				,'ERS_CommonAbnoDiverticulum'
				,'Diverticulum'
				,'Diverticulum'
				)
		END

		-----------######################-------------------

		ELSE IF @procType IN (9) --Retrograde
		BEGIN
			INSERT INTO #QueryDetails
			VALUES (
				@procType
				,'ERS_ColonAbnoCalibre'
				,'Calibre'
				,'Calibre'
				)
				,(
				@procType
				,'ERS_ColonAbnoDiverticulum'
				,'Diverticulum'
				,'Diverticulum'
				)
				,(
				@procType
				,'ERS_ColonAbnoHaemorrhage'
				,'Haemorrhage'
				,'Haemorrhage'
				)
				,(
				@procType
				,'ERS_ColonAbnoLesions'
				,'Lesions'
				,'Lesions'
				)
				,(
				@procType
				,'ERS_ColonAbnoMiscellaneous'
				,''
				,'Miscellaneous'
				)
				,(
				@procType
				,'ERS_ColonAbnoMucosa'
				,'Mucosa'
				,'Mucosa'
				)
				,(
				@procType
				,'ERS_ColonAbnoperianallesions'
				,'Perianal lesions'
				,'Perianal Lesions'
				)
				,(
				@procType
				,'ERS_ColonAbnoVascularity'
				,'Vascularity'
				,'Vascularity'
				)
				,(
				@procType
				,'ERS_UpperGITherapeutics'
				,'Therapeutic procedure(s)'
				,'Therapeutic Procedures'
				)
				,(
				@procType
				,'ERS_UpperGISpecimens'
				,'Specimens taken'
				,'Specimens Taken'
				)
		END

		------##################------------


		ELSE IF @procType IN (
				10
				,12
				) --Bronchoscopy, Thoracoscopy
		BEGIN
			INSERT INTO #QueryDetails
			VALUES (
				@procType
				,'ERS_BRTSpecimens'
				,'Specimens taken'
				,'Specimens Taken'
				),
				(
				@procType
				,'ERS_UpperGITherapeutics'
				,'Therapeutic procedure(s)'
				,'Therapeutic Procedures'
				),
				(
				@procType
				,'ERS_BRTAbnoDescriptions'
				,'<strong>Abnormalities</strong>'			
				,''
				)

		END	
		ELSE IF @procType IN (
				11
				) --EBUS			
				BEGIN
					INSERT INTO #QueryDetails
					VALUES (
						@procType
						,'ERS_BRTSpecimens'
						,'Specimens taken'
						,'Specimens Taken'
						),
						(
						@procType
						,'ERS_UpperGITherapeutics'
						,'Therapeutic procedure(s)'
						,'Therapeutic Procedures'
						)
			
					IF @IsLymphNode = 'True'
					BEGIN
						INSERT INTO #QueryDetails
						VALUES 
							(
							@procType
							,'ERS_EBUSAbnoDescriptions'
							,'<strong>Abnormalities</strong>'
							,'EBUS Abnormality Descriptions'
							)
					END
					ELSE
					BEGIN
						INSERT INTO #QueryDetails
						VALUES 
							(
							@procType
							,'ERS_BRTAbnoDescriptions'
							,'<strong>Abnormalities</strong>'
							,''
							)
					END
				END

			--CREATE TABLE #QueryDetails (
			--ProcType INT
			--,TableName VARCHAR(50)
			--,AbnoNodeName VARCHAR(50)
			--,Identifier VARCHAR(50)
			--);




		DECLARE qry_cursor CURSOR
		FOR
		SELECT ProcType
			,TableName
			,AbnoNodeName
			,Identifier
		FROM #QueryDetails

		OPEN qry_cursor

		FETCH NEXT
		FROM qry_cursor
		INTO @ProcType
			,@TableName
			,@AbnoNodeName
			,@Identifier

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @summaryWhole = ''
			SET @none = NULL
			SET @opDiv = '''<table><tr><td style="padding-left:25px;padding-right:50px;" class="printFontBasic">'' + '
			SET @clDiv = ' + ''</td></tr></table>'''
			SET @indent = '&nbsp;- ';
			SET @br = '<br />'
			SET @opBold = '<b>';
			SET @clBold = '</b>'
			SET @fullStop = '.';
			SET @colon = ': '
			SET @fldNone = 'None';
			SET @emptyStr = ''

			IF @TableName = 'ERS_UpperGIAbnoLumen'
				SET @fldNone = 'NoBlood'
			ELSE IF @TableName = 'ERS_ERCPAbnoIntrahepatic'
				SET @fldNone = 'NormalIntraheptic'
			ELSE IF @TableName IN (
					'ERS_ERCPAbnoDuct'
					,'ERS_ERCPAbnoParenchyma'
					,'ERS_ERCPAbnoAppearance'
					,'ERS_ERCPAbnoDiverticulum'
					,'ERS_EBUSAbnoDescriptions'
					,'ERS_BRTAbnoDescriptions'
					)
				SET @fldNone = 'Normal'
			ELSE
				SET @fldNone = 'None'

			IF @TableName = 'ERS_BRTAbnoDescriptions' SET @fullStop = @emptyStr
			--Get Summary from respective table
			IF @TableName = 'ERS_Sites' 
			BEGIN
				SET @SQLString = 'SELECT @summaryWhole = AdditionalNotes FROM ' + @TableName + '  
								WHERE SiteId =  ' + CONVERT(VARCHAR, @SiteId) + ' AND ISNULL(AdditionalNotes,'''') <> '''' '
				SET @fullStop = @emptyStr
			END
			ELSE
			BEGIN
				SET @SQLString = 'SELECT @summaryWhole = Summary, @none = [' + @fldNone + '] FROM ' + @TableName + '  
								WHERE SiteId =  ' + CONVERT(VARCHAR, @SiteId) + ' AND ISNULL(Summary,'''') <> '''' '
			
				--SELECT 'SQLString', @SQLString
			END

			EXECUTE sp_executesql @SQLString
				,N'@summaryWhole VARCHAR(MAX) OUTPUT, @none TINYINT OUTPUT'
				,@summaryWhole OUTPUT
				,@none OUTPUT

			IF @Identifier = 'Therapeutic Procedures'
			BEGIN
				IF ISNULL(@none, 0) = 0
					AND LEN(@summaryWhole) > 0
				BEGIN
					SET @fullStop = @emptyStr
					SET @abnoTheraPresent = 1
				END
				ELSE
				BEGIN
					SET @opDiv = @emptyStr;
					SET @clDiv = @emptyStr
					SET @opBold = @emptyStr;
					SET @clBold = @emptyStr
				END
			END
			ELSE
			BEGIN
				IF @Identifier = 'Specimens Taken'
				BEGIN
					--IF therapeutics present, remove line before specimens
					IF @abnoTheraPresent = 1
						SET @br = @emptyStr
				END
				ELSE
				BEGIN
					SET @opBold = @emptyStr;
					SET @clBold = @emptyStr
				END

				SET @opDiv = @emptyStr;
				SET @clDiv = @emptyStr
			END

			IF ISNULL(@summaryWhole, '') <> ''
			BEGIN
				SET @summaryWhole = REPLACE(@summaryWhole, '''', '''''')

				--If None is clicked, prefix not required (e.g "Oesophagitis : No Oesophagitis." should be "No Oesophagitis.")
				--Prefix (@AbnoNodeName) is required for Lumen even if None (Blood free) is selected
				IF (
						ISNULL(@none, 0) = 1
						OR @AbnoNodeName = ''
						)
					AND @TableName <> 'ERS_UpperGIAbnoLumen'
				BEGIN
					SET @AbnoNodeName = '';
					SET @colon = ''
				END
				ELSE
				BEGIN
					SET @colon = ': '
				END

				--IF @summaryWhole = '<br /' SET @summaryWhole = ''
				SET @tmpSummaryAbno = ' CASE WHEN ''' + @summaryWhole + ''' IN ('''', ''' + @AbnoNodeName + ''') THEN ''' + @indent + @AbnoNodeName + '' + @fullStop + '''' + ' ELSE  ''' + @indent + @opBold + @AbnoNodeName + @clBold + @colon + ''' + ' + @opDiv + '''' + @summaryWhole + @fullStop + '''' + @clDiv + ' END'
				SET @tmpSummaryAbnoLinks = 'CASE WHEN ''' + @summaryWhole + ''' IN ('''', ''' + @AbnoNodeName + ''') THEN ''' + @indent + @AbnoNodeName + ''' + REPLACE(REPLACE(''' + @htmlAnchorCode + ''',''{0}'',''' + @Identifier + '''),''{1}'',''' + @AbnoNodeName + ''') + ''' + @fullStop + '''' + ' ELSE  ''' + @indent + @opBold + @AbnoNodeName + @clBold + @colon + ''' + REPLACE(REPLACE(''' + @htmlAnchorCode + ''',''{0}'',''' + @Identifier + '''),''{1}'',' + @opDiv + '''' + @summaryWhole + @fullStop + '''' + @clDiv + ')  ' + ' END'
				SET @SQLString = 'SELECT ' + CASE 
						WHEN @Identifier = 'Specimens Taken'
							THEN '@summarySpecimens = @summarySpecimens '
						WHEN @Identifier = 'Therapeutic Procedures'
							THEN '@summaryTherapeutics = @summaryTherapeutics '
						ELSE '@summaryAbnormalities = @summaryAbnormalities '
						END + ' + ''' + @br + ''' + ' + @tmpSummaryAbno + ', ' + CASE 
						WHEN @Identifier = 'Specimens Taken'
							THEN '@summarySpecimensWithHyperLinks = @summarySpecimensWithHyperLinks '
						WHEN @Identifier = 'Therapeutic Procedures'
							THEN '@summaryTherapeuticsWithHyperLinks = @summaryTherapeuticsWithHyperLinks '
						ELSE '@summaryAbnormalitiesWithHyperLinks = @summaryAbnormalitiesWithHyperLinks '
						END + ' + ''' + @br + ''' + ' + @tmpSummaryAbnoLinks			
				--Perform abno check to determine normal procedure
				IF @none = 0
					AND @TableName <> 'ERS_UpperGISpecimens'
					AND @AbnormalProcedure <> 1
					SET @AbnormalProcedure = 1

				IF @Identifier = 'Specimens Taken'
					EXECUTE sp_executesql @SQLString
						,N'@summarySpecimens VARCHAR(MAX) OUTPUT,@summarySpecimensWithHyperLinks VARCHAR(MAX) OUTPUT'
						,@summarySpecimens = @summarySpecimens OUTPUT
						,@summarySpecimensWithHyperLinks = @summarySpecimensWithHyperLinks OUTPUT
				ELSE IF @Identifier = 'Therapeutic Procedures'
					EXECUTE sp_executesql @SQLString
						,N'@summaryTherapeutics VARCHAR(MAX) OUTPUT,@summaryTherapeuticsWithHyperLinks VARCHAR(MAX) OUTPUT'
						,@summaryTherapeutics = @summaryTherapeutics OUTPUT
						,@summaryTherapeuticsWithHyperLinks = @summaryTherapeuticsWithHyperLinks OUTPUT
				ELSE
					EXECUTE sp_executesql @SQLString
						,N'@summaryAbnormalities VARCHAR(MAX) OUTPUT,@summaryAbnormalitiesWithHyperLinks VARCHAR(MAX) OUTPUT'
						,@summaryAbnormalities = @summaryAbnormalities OUTPUT
						,@summaryAbnormalitiesWithHyperLinks = @summaryAbnormalitiesWithHyperLinks OUTPUT
			END

			FETCH NEXT
			FROM qry_cursor
			INTO @ProcType
				,@TableName
				,@AbnoNodeName
				,@Identifier
		END

		CLOSE qry_cursor

		DEALLOCATE qry_cursor

		DROP TABLE #QueryDetails

		IF EXISTS (
				SELECT 1
				FROM ERS_CommonAbnoOther
				WHERE SiteId = @SiteId
				)
		BEGIN
			SELECT @summaryAbnormalities = isnull(@summaryAbnormalities, '') + (
					SELECT STUFF((
								SELECT ', ' + OA.Summary
								FROM ERS_OtherAbnormalities OA
								JOIN ERS_CommonAbnoOther CAO ON OA.OtherId = CAO.OtherId
								WHERE CAO.SiteId = @SiteId
								FOR XML PATH('')
								), 1, 1, '') Code
					)
				,@summaryAbnormalitiesWithHyperLinks = isnull(@summaryAbnormalitiesWithHyperLinks, '') + '<table><tr><td style="padding-right:50px;">- Other:' + REPLACE(REPLACE(REPLACE(@htmlAnchorCode, '''{0}''', 'Other'), '{1}', (
							SELECT STUFF((
										SELECT ', ' + OA.Summary
										FROM ERS_OtherAbnormalities OA
										JOIN ERS_CommonAbnoOther CAO ON OA.OtherId = CAO.OtherId
										WHERE CAO.SiteId = @SiteId
										FOR XML PATH('')
										), 1, 1, '') Code
							)), '''''', '''') + '</td></tr></table>'
		END

		-- Update the current site's summary
		UPDATE ERS_Sites
		SET SiteSummary = @summaryAbnormalities
			,SiteSummarySpecimens = @summarySpecimens
			,SiteSummaryTherapeutics = @summaryTherapeutics
			,SiteSummaryWithLinks = @summaryAbnormalitiesWithHyperLinks
			,SiteSummarySpecimensWithLinks = @summarySpecimensWithHyperLinks
			,SiteSummaryTherapeuticsWithLinks = @summaryTherapeuticsWithHyperLinks
			,HasAbnormalities = @AbnormalProcedure
		WHERE SiteId = @siteId

		if @ReportSummaryRefresh = 1 
			EXEC procedure_summary_update @procId
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE();

		RAISERROR (
				@ErrorMessage
				,@ErrorSeverity
				,@ErrorState
				);

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
	END CATCH

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
END
GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 20/06/23
-- TFS#	1707
-- Description of change
-- DNA reports to produce the correct status when printing
------------------------------------------------------------------------------------------------------------------------
GO

EXEC dbo.DropIfExist @ObjectName = 'sch_update_appointment_status',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE sch_update_appointment_status
(
	@AppointmentId INT,
	@HDCStatusKey VARCHAR(5),
	@LoggedInUserId int
)
AS
BEGIN
	
	UPDATE a
	SET a.AppointmentStatusId = s.UniqueId, a.WhoUpdatedId = @LoggedInUserId, a.WhenUpdated = GETDATE()
	FROM dbo.ERS_Appointments a
		INNER JOIN dbo.ERS_AppointmentStatus s ON a.AppointmentStatusId = s.UniqueId
	WHERE s.HDCKEY = @HDCStatusKey AND a.AppointmentId = @AppointmentId
END
GO

EXEC dbo.DropIfExist @ObjectName = 'sch_get_procedure_appointment',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE sch_get_procedure_appointment
(
	@ProcedureId INT
)
AS
BEGIN
	SELECT ea.AppointmentId, CONVERT(VARCHAR(10), ea.StartDateTime, 103), ea.DiaryId, ep.Forename1 + ' ' + ep.Surname AS PatientName, ea.StartDateTime, DATEADD(minute, convert(int, ea.AppointmentDuration), ea.StartDateTime) AS EndDateTime, ISNULL(dept.ProcedureType,'') AS ProcedureType, ISNULL(ett.Description,'') AS TherapeuticType
	FROM dbo.ERS_Appointments ea 
		INNER JOIN dbo.ERS_PatientJourney pj ON pj.AppointmentId = ea.AppointmentId
		LEFT JOIN dbo.ERS_AppointmentProcedureTypes eapt ON ea.AppointmentId = eapt.AppointmentID
		LEFT JOIN dbo.ERS_AppointmentTherapeutics eat ON ea.AppointmentId = eat.AppointmentID
		LEFT JOIN dbo.ERS_ProcedureTypes dept ON dept.ProcedureTypeId = eapt.ProcedureTypeID
		LEFT JOIN dbo.ERS_TherapeuticTypes ett ON eat.TherapeuticTypeID = ett.Id
		INNER JOIN dbo.ERS_Patients ep ON ea.PatientId = ep.PatientId
	WHERE ProcedureId = @ProcedureId
	ORDER BY StartDateTime
END

GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO


------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 26/06/23
-- TFS#	
-- Description of change
-- Added missing columns 
------------------------------------------------------------------------------------------------------------------------
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE name = 'BandLigationPerformed' AND object_id = OBJECT_ID('ERS_ERCPTherapeutics'))
ALTER TABLE dbo.ERS_ERCPTherapeutics
ADD BandLigationPerformed BIT NOT NULL CONSTRAINT [DF_ERS_ERCPTherapeutics_BandLigationPerformed] DEFAULT 0,
BandLigationSuccessful INT NOT NULL CONSTRAINT [DF_ERS_ERCPTherapeutics_BandLigationSuccessful] DEFAULT 0
GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 26/06/23
-- TFS#	2953
-- Description of change
-- Polypectomy to record specimen and abnormality entry
------------------------------------------------------------------------------------------------------------------------
GO


PRINT N'Altering [dbo].[therapeutics_ercp_summary_update]...';


GO
ALTER PROCEDURE [dbo].[therapeutics_ercp_summary_update]
(
	@TherapeuticId AS INT,
	@SiteId INT
)
AS
	SET NOCOUNT ON
	DECLARE	  @msg		VARCHAR(1000)
			, @Details	VARCHAR(1000)
			, @Summary	VARCHAR(4000)=''
			, @Area		VARCHAR(500)=''
			, @br VARCHAR(6) = '<br />';

	DECLARE
	@None BIT,
	@YAGLaser BIT,
	@YAGLaserWatts INT,
	@YAGLaserPulses INT,
	@YAGLaserSecs decimal(8,2),
	@YAGLaserKJ decimal(8,2),
	@ArgonBeamDiathermy BIT,
	@ArgonBeamDiathermyWatts INT,
	@ArgonBeamDiathermyPulses INT,
	@ArgonBeamDiathermySecs decimal(8,2),
	@ArgonBeamDiathermyKJ decimal(8,2),		
	@HeatProbe BIT,					
	@BicapElectro BIT,				
	@Diathermy BIT,						
	@HotBiopsy BIT,
	@BandLigation BIT,
    @BandLigationPerformed INT,
	@BandLigationSuccess INT,
	@BotoxInjection BIT,
    @EndoloopPlacement BIT,
    @ForeignBody BIT,
	@Injection BIT,
	@InjectionType INT,
	@InjectionVolume INT,
	@InjectionNumber INT,
	@GastrostomyInsertion BIT,
	@GastrostomyInsertionSize numeric(9,2),
	@GastrostomyInsertionUnits TINYINT,
	@GastrostomyInsertionType TINYINT,
	@GastrostomyInsertionBatchNo VARCHAR(100),
	@GastrostomyRemoval BIT,
	@NilByMouth BIT,
	@NilByMouthHrs INT,
	@NilByProc BIT,
	@NilByProcHrs INT,
	@AttachmentToWard BIT,
	@PyloricDilatation BIT,	
	@StentInsertion BIT,
	@StentInsertionQty INT,
	@RadioactiveWirePlaced BIT,	
	@StentInsertionBatchNo VARCHAR(100),
	@StentRemoval BIT,
	@StentRemovalTechnique INT,
	@EMR BIT,
	@EMRType TINYINT,
	@EMRFluid INT,
	@EMRFluidVolume INT,
	@Marking BIT,
	@MarkingType INT,
	@Clip BIT,						
	@ClipNum INT,
	@Papillotomy BIT,
	@Sphincterotome TINYINT,
	@PapillotomyLength REAL,
	@PapillotomyAcceptBalloonSize REAL,
	@ReasonForPapillotomy TINYINT,
	@PapillotomyBleeding TINYINT,
	@SphincterDecompressed TINYINT,
	@PanOrificeSphincterotomy BIT,
	@StoneRemoval BIT,
	@RemovalUsing TINYINT,
	@ExtractionOutcome TINYINT,
	@InadequateSphincterotomy BIT,
	@StoneSize BIT,
	@QuantityOfStones BIT,
	@ImpactedStones BIT,
	@OtherReason BIT,
	@OtherReasonText VARCHAR(200),
	@StoneDecompressed TINYINT,
	@StrictureDilatation BIT,
	@DilatedTo REAL,
	@DilatationUnits TINYINT,
	@DilatorType TINYINT,
	@EndoscopicCystPuncture BIT,
	@CystPunctureDevice TINYINT,
	@CystPunctureVia TINYINT,
	@Cannulation BIT,
	@Manometry BIT,
	@Haemostasis BIT,
	@NasopancreaticDrain BIT,
	@RendezvousProcedure BIT,
	@SnareExcision SMALLINT,
	@BalloonDilation BIT,
	@BalloonDilatedTo REAL,
	@BalloonDilatationUnits SMALLINT,
	@BalloonDilatorType SMALLINT,
	@BalloonTrawl BIT,
	@BalloonTrawlDilatorType SMALLINT,
	@BalloonTrawlDilatorSize REAL,
	@BalloonTrawlDilatorUnits SMALLINT,
	@BalloonDecompressed TINYINT,
	@DiagCholangiogram SMALLINT,
	@DiagPancreatogram SMALLINT,
	@EndoscopistRole SMALLINT,
	@Other VARCHAR(1000),
	@EUSProcType SMALLINT,
	@CorrectStentPlacement bit,
	@CorrectStentPlacementNoReason int,
	@BalloonDilatation bit,
	@BougieDilatation bit,
	@BougieDilation bit,
	@BrushCytology bit,
	@Cholangioscopy bit,
	@StentChange bit,
	@StentPlacement bit,
	@RadioFrequencyAblation bit,
	@FineNeedleAspiration bit,
	@FineNeedleAspirationType tinyint,
	@FineNeedleBiopsy BIT,
	@Polypectomy BIT

--BEGIN TRY

	SELECT * INTO #tmp_ERCPTherapeutics 
	FROM dbo.ERS_ERCPTherapeutics 
	WHERE (Id = @TherapeuticId OR SiteID = @SiteId)

--## 1) If 'CarriedOutRole=2 (EE)' record is found for a SiteId in [ERS_ERCPTherapeutics] means it has both EE/ER Entries...
	--IF EXISTS(SELECT 'ER' FROM dbo.ERS_ERCPTherapeutics WHERE SiteId=@SiteId AND CarriedOutRole=2)
		BEGIN
			--PRINT '[ERS_ERCPTherapeutics] has both EE/ER Entries...';
			;WITH eeRecord AS(
				SELECT * FROM #tmp_ERCPTherapeutics WHERE CarriedOutRole = (SELECT MAX(CarriedOutRole) FROM #tmp_ERCPTherapeutics) --## 2 is EE
			)
			SELECT
				@None				= (CASE WHEN IsNull(ER.[None], 0) = 0 THEN EE.[None] ELSE ER.[None] END),
				@YAGLaser			= (CASE WHEN IsNull(ER.YAGLaser, 0) = 0 THEN EE.YAGLaser ELSE ER.YAGLaser END),
				@YAGLaserWatts		= (CASE WHEN IsNull(ER.YAGLaserWatts, 0) = 0 THEN EE.YAGLaserWatts ELSE ER.YAGLaserWatts END),
				@YAGLaserPulses		= (CASE WHEN IsNull(ER.YAGLaserPulses, 0) = 0 THEN EE.YAGLaserPulses ELSE ER.YAGLaserPulses END),
				@YAGLaserSecs		= (CASE WHEN IsNull(ER.YAGLaserSecs, 0) = 0 THEN EE.YAGLaserSecs ELSE ER.YAGLaserSecs END),
				@YAGLaserKJ			= (CASE WHEN IsNull(ER.YAGLaserKJ, 0) = 0 THEN EE.YAGLaserKJ ELSE ER.YAGLaserKJ END),
				@ArgonBeamDiathermy	= (CASE WHEN IsNull(ER.ArgonBeamDiathermy, 0) = 0 THEN EE.ArgonBeamDiathermy ELSE ER.ArgonBeamDiathermy END),
				@ArgonBeamDiathermyWatts		= (CASE WHEN IsNull(ER.ArgonBeamDiathermyWatts, 0) = 0 THEN EE.ArgonBeamDiathermyWatts ELSE ER.ArgonBeamDiathermyWatts END),
				@ArgonBeamDiathermyPulses		= (CASE WHEN IsNull(ER.ArgonBeamDiathermyPulses, 0) = 0 THEN EE.ArgonBeamDiathermyPulses ELSE ER.ArgonBeamDiathermyPulses END),
				@ArgonBeamDiathermySecs			= (CASE WHEN IsNull(ER.ArgonBeamDiathermySecs, 0) = 0 THEN EE.ArgonBeamDiathermySecs ELSE ER.ArgonBeamDiathermySecs END),
				@ArgonBeamDiathermyKJ			= (CASE WHEN IsNull(ER.ArgonBeamDiathermyKJ, 0) = 0 THEN EE.ArgonBeamDiathermyKJ ELSE ER.ArgonBeamDiathermyKJ END),
				@HeatProbe			= (CASE WHEN IsNull(ER.HeatProbe, 0) = 0 THEN EE.HeatProbe ELSE ER.HeatProbe END),
				@BicapElectro		= (CASE WHEN IsNull(ER.BicapElectro, 0) = 0 THEN EE.BicapElectro ELSE ER.BicapElectro END),
				@Diathermy			= (CASE WHEN IsNull(ER.Diathermy, 0) = 0 THEN EE.Diathermy ELSE ER.Diathermy END),
				@HotBiopsy			= (CASE WHEN IsNull(ER.HotBiopsy, 0) = 0 THEN EE.HotBiopsy ELSE ER.HotBiopsy END),
				@BandLigation= (CASE WHEN IsNull(ER.BandLigation, 0) = 0 THEN EE.BandLigation ELSE ER.BandLigation END),
				@BandLigationPerformed			= (CASE WHEN ISNULL(ER.[BandLigationPerformed], 0) = 0 THEN ER.[BandLigationPerformed] ELSE EE.[BandLigationPerformed] END),
				@BandLigationSuccess			= (CASE WHEN ISNULL(ER.[BandLigationSuccessful], 0) = 0 THEN ER.[BandLigationSuccessful] ELSE EE.[BandLigationSuccessful] END),
				@BotoxInjection = (CASE WHEN IsNull(ER.BotoxInjection, 0) = 0 THEN EE.BotoxInjection ELSE ER.BotoxInjection END),
				@EndoloopPlacement = (CASE WHEN IsNull(ER.EndoloopPlacement, 0) = 0 THEN EE.EndoloopPlacement ELSE ER.EndoloopPlacement END),
				@ForeignBody= (CASE WHEN IsNull(ER.ForeignBody, 0) = 0 THEN EE.ForeignBody ELSE ER.ForeignBody END),
				@Injection			= (CASE WHEN IsNull(ER.Injection, 0) = 0 THEN EE.Injection ELSE ER.Injection END),
				@InjectionType		= (CASE WHEN IsNull(ER.InjectionType, 0) = 0 THEN EE.InjectionType ELSE ER.InjectionType END),
				@InjectionVolume	= (CASE WHEN IsNull(ER.InjectionVolume, 0) = 0 THEN EE.InjectionVolume ELSE ER.InjectionVolume END),
				@InjectionNumber	= (CASE WHEN IsNull(ER.InjectionNumber, 0) = 0 THEN EE.InjectionNumber ELSE ER.InjectionNumber END),
				@GastrostomyInsertion			= (CASE WHEN IsNull(ER.GastrostomyInsertion, 0) = 0 THEN EE.GastrostomyInsertion ELSE ER.GastrostomyInsertion END),
				@GastrostomyInsertionSize		= (CASE WHEN IsNull(ER.GastrostomyInsertionSize, 0) = 0 THEN EE.GastrostomyInsertionSize ELSE ER.GastrostomyInsertionSize END),
				@GastrostomyInsertionUnits		= (CASE WHEN ER.GastrostomyInsertionUnits IS NULL THEN EE.GastrostomyInsertionUnits ELSE ER.GastrostomyInsertionUnits END),
				@GastrostomyInsertionType		= (CASE WHEN IsNull(ER.GastrostomyInsertionType, 0) = 0 THEN EE.GastrostomyInsertionType ELSE ER.GastrostomyInsertionType END),
				@GastrostomyInsertionBatchNo	= (SELECT isnull((CASE WHEN IsNull(ER.GastrostomyInsertionBatchNo, '') = '' THEN EE.GastrostomyInsertionBatchNo ELSE ER.GastrostomyInsertionBatchNo END), '') as [text()] FOR XML PATH('')),
				@GastrostomyRemoval				= (CASE WHEN IsNull(ER.GastrostomyRemoval, 0) = 0 THEN EE.GastrostomyRemoval ELSE ER.GastrostomyRemoval END),
				@NilByMouth			= (CASE WHEN IsNull(ER.NilByMouth, 0) = 0 THEN EE.NilByMouth ELSE ER.NilByMouth END),
				@NilByMouthHrs		= (CASE WHEN IsNull(ER.NilByMouthHrs, 0) = 0 THEN EE.NilByMouthHrs ELSE ER.NilByMouthHrs END),
				@NilByProc			= (CASE WHEN IsNull(ER.NilByProc, 0) = 0 THEN EE.NilByProc ELSE ER.NilByProc END),
				@NilByProcHrs		= (CASE WHEN IsNull(ER.NilByProcHrs, 0) = 0 THEN EE.NilByProcHrs ELSE ER.NilByProcHrs END),
				@AttachmentToWard	= (CASE WHEN IsNull(ER.AttachmentToWard, 0) = 0 THEN EE.AttachmentToWard ELSE ER.AttachmentToWard END),
				@PyloricDilatation	= (CASE WHEN IsNull(ER.PyloricDilatation, 0) = 0 THEN EE.PyloricDilatation ELSE ER.PyloricDilatation END),
				@StentInsertion		= (CASE WHEN IsNull(ER.StentInsertion, 0) = 0 THEN EE.StentInsertion ELSE ER.StentInsertion END),
				@StentInsertionQty	= (CASE WHEN IsNull(ER.StentInsertionQty, 0) = 0 THEN EE.StentInsertionQty ELSE ER.StentInsertionQty END),
				@RadioactiveWirePlaced			= (CASE WHEN IsNull(ER.RadioactiveWirePlaced, 0) = 0 THEN EE.RadioactiveWirePlaced ELSE ER.RadioactiveWirePlaced END),
				@StentInsertionBatchNo			= (SELECT isnull((CASE WHEN IsNull(ER.StentInsertionBatchNo,'')= '' THEN EE.StentInsertionBatchNo ELSE ER.StentInsertionBatchNo END), '') as [text()] FOR XML PATH('')),
				@StentRemoval					= (CASE WHEN IsNull(ER.StentRemoval, 0) = 0 THEN EE.StentRemoval ELSE ER.StentRemoval END),
				@StentRemovalTechnique			= (CASE WHEN IsNull(ER.StentRemovalTechnique, 0) = 0 THEN EE.StentRemovalTechnique ELSE ER.StentRemovalTechnique END),
				@EMR				= (CASE WHEN IsNull(ER.EMR, 0) = 0 THEN EE.EMR ELSE ER.EMR END),
				@EMRType			= (CASE WHEN IsNull(ER.EMRType, 0) = 0 THEN EE.EMRType ELSE ER.EMRType END),
				@EMRFluid			= (CASE WHEN IsNull(ER.EMRFluid, 0) = 0 THEN EE.EMRFluid ELSE ER.EMRFluid END),
				@EMRFluidVolume		= (CASE WHEN IsNull(ER.EMRFluidVolume, 0) = 0 THEN EE.EMRFluidVolume ELSE ER.EMRFluidVolume END),
				@Marking			= (CASE WHEN IsNull(ER.Marking, 0) = 0 THEN EE.Marking ELSE ER.Marking END),
				@MarkingType		= (CASE WHEN IsNull(ER.MarkingType, 0) = 0 THEN EE.MarkingType ELSE ER.MarkingType END),
				@Clip				= (CASE WHEN IsNull(ER.Clip, 0) = 0 THEN EE.Clip ELSE ER.Clip END),
				@ClipNum			= (CASE WHEN IsNull(ER.ClipNum, 0) = 0 THEN EE.ClipNum ELSE ER.ClipNum END),
				@Papillotomy		= (CASE WHEN IsNull(ER.Papillotomy, 0) = 0 THEN EE.Papillotomy ELSE ER.Papillotomy END),
				@Sphincterotome		= (CASE WHEN IsNull(ER.Sphincterotome, 0) = 0 THEN EE.Sphincterotome ELSE ER.Sphincterotome END),
				@PapillotomyLength	= (CASE WHEN IsNull(ER.PapillotomyLength, 0) = 0 THEN EE.PapillotomyLength ELSE ER.PapillotomyLength END),
				@PapillotomyAcceptBalloonSize	= (CASE WHEN IsNull(ER.PapillotomyAcceptBalloonSize, 0) = 0 THEN EE.PapillotomyAcceptBalloonSize ELSE ER.PapillotomyAcceptBalloonSize END),
				@ReasonForPapillotomy		= (CASE WHEN IsNull(ER.ReasonForPapillotomy, 0) = 0 THEN EE.ReasonForPapillotomy ELSE ER.ReasonForPapillotomy END),
				@PapillotomyBleeding		= (CASE WHEN IsNull(ER.PapillotomyBleeding, 0) = 0 THEN EE.PapillotomyBleeding ELSE ER.PapillotomyBleeding END),
				@SphincterDecompressed		= (CASE WHEN IsNull(ER.SphincterDecompressed, 0) = 0 THEN EE.SphincterDecompressed ELSE ER.SphincterDecompressed END),
				@PanOrificeSphincterotomy	= (CASE WHEN IsNull(ER.PanOrificeSphincterotomy, 0) = 0 THEN EE.PanOrificeSphincterotomy ELSE ER.PanOrificeSphincterotomy END),
				@StoneRemoval				= (CASE WHEN IsNull(ER.StoneRemoval, 0) = 0 THEN EE.StoneRemoval ELSE ER.StoneRemoval END),
				@RemovalUsing				= (CASE WHEN IsNull(ER.RemovalUsing, 0) = 0 THEN EE.RemovalUsing ELSE ER.RemovalUsing END),
				@ExtractionOutcome			= (CASE WHEN IsNull(ER.ExtractionOutcome, 0) = 0 THEN EE.ExtractionOutcome ELSE ER.ExtractionOutcome END),
				@InadequateSphincterotomy	= (CASE WHEN IsNull(ER.InadequateSphincterotomy, 0) = 0 THEN EE.InadequateSphincterotomy ELSE ER.InadequateSphincterotomy END),
				@StoneSize			= (CASE WHEN IsNull(ER.StoneSize, 0) = 0 THEN EE.StoneSize ELSE ER.StoneSize END),
				@QuantityOfStones	= (CASE WHEN IsNull(ER.QuantityOfStones, 0) = 0 THEN EE.QuantityOfStones ELSE ER.QuantityOfStones END),
				@ImpactedStones		= (CASE WHEN IsNull(ER.ImpactedStones, 0) = 0 THEN EE.ImpactedStones ELSE ER.ImpactedStones END),
				@OtherReason		= (CASE WHEN IsNull(ER.OtherReason, 0) = 0 THEN EE.OtherReason ELSE ER.OtherReason END),
				@OtherReasonText	= (SELECT isnull((CASE WHEN IsNull(ER.OtherReasonText, '') = '' THEN EE.OtherReasonText ELSE ER.OtherReasonText END), '') as [text()] FOR XML PATH('')),
				@StoneDecompressed	= (CASE WHEN IsNull(ER.StoneDecompressed, 0) = 0 THEN EE.StoneDecompressed ELSE ER.StoneDecompressed END),
				@StrictureDilatation= (CASE WHEN IsNull(ER.StrictureDilatation, 0) = 0 THEN EE.StrictureDilatation ELSE ER.StrictureDilatation END),
				@DilatedTo			= (CASE WHEN IsNull(ER.DilatedTo, 0) = 0 THEN EE.DilatedTo ELSE ER.DilatedTo END),
				@DilatationUnits	= (CASE WHEN ER.DilatationUnits IS NULL THEN EE.DilatationUnits ELSE ER.DilatationUnits END),
				@DilatorType		= (CASE WHEN IsNull(ER.DilatorType, 0) = 0 THEN EE.DilatorType ELSE ER.DilatorType END),
				@EndoscopicCystPuncture	= (CASE WHEN IsNull(ER.EndoscopicCystPuncture, 0) = 0 THEN EE.EndoscopicCystPuncture ELSE ER.EndoscopicCystPuncture END),
				@CystPunctureDevice		= (CASE WHEN IsNull(ER.CystPunctureDevice, 0) = 0 THEN EE.CystPunctureDevice ELSE ER.CystPunctureDevice END),
				@CystPunctureVia		= (CASE WHEN IsNull(ER.CystPunctureVia, 0) = 0 THEN EE.CystPunctureVia ELSE ER.CystPunctureVia END),
				@Cannulation			= (CASE WHEN IsNull(ER.Cannulation, 0) = 0 THEN EE.Cannulation ELSE ER.Cannulation END),
				@Manometry				= (CASE WHEN IsNull(ER.Manometry, 0) = 0 THEN EE.Manometry ELSE ER.Manometry END),
				@Haemostasis			= (CASE WHEN IsNull(ER.Haemostasis, 0) = 0 THEN EE.Haemostasis ELSE ER.Haemostasis END),
				@NasopancreaticDrain	= (CASE WHEN IsNull(ER.NasopancreaticDrain, 0) = 0 THEN EE.NasopancreaticDrain ELSE ER.NasopancreaticDrain END),
				@RendezvousProcedure	= (CASE WHEN IsNull(ER.RendezvousProcedure, 0) = 0 THEN EE.RendezvousProcedure ELSE ER.RendezvousProcedure END),
				@SnareExcision			= (CASE WHEN IsNull(ER.SnareExcision, 0) = 0 THEN EE.SnareExcision ELSE ER.SnareExcision END),
				@BalloonDilation		= (CASE WHEN IsNull(ER.BalloonDilation, 0) = 0 THEN EE.BalloonDilation ELSE ER.BalloonDilation END),
				@BalloonDilatedTo		= (CASE WHEN IsNull(ER.BalloonDilatedTo, 0) = 0 THEN EE.BalloonDilatedTo ELSE ER.BalloonDilatedTo END),
				@BalloonDilatationUnits	= (CASE WHEN IsNull(ER.BalloonDilatationUnits, 0) = 0 THEN EE.BalloonDilatationUnits ELSE ER.BalloonDilatationUnits END),
				@BalloonDilatorType		= (CASE WHEN IsNull(ER.BalloonDilatorType, 0) = 0 THEN EE.BalloonDilatorType ELSE ER.BalloonDilatorType END),
				@BalloonTrawl			= (CASE WHEN IsNull(ER.BalloonTrawl, 0) = 0 THEN EE.BalloonTrawl ELSE ER.BalloonTrawl END),
				@BalloonTrawlDilatorType	= (CASE WHEN IsNull(ER.BalloonTrawlDilatorType, 0) = 0 THEN EE.BalloonTrawlDilatorType ELSE ER.BalloonTrawlDilatorType END),
				@BalloonTrawlDilatorSize	= (CASE WHEN IsNull(ER.BalloonTrawlDilatorSize, 0) = 0 THEN EE.BalloonTrawlDilatorSize ELSE ER.BalloonTrawlDilatorSize END),
				@BalloonTrawlDilatorUnits	= (CASE WHEN IsNull(ER.BalloonTrawlDilatorUnits, 0) = 0 THEN EE.BalloonTrawlDilatorUnits ELSE ER.BalloonTrawlDilatorUnits END),
				@BalloonDecompressed		= (CASE WHEN IsNull(ER.BalloonDecompressed, 0) = 0 THEN EE.BalloonDecompressed ELSE ER.BalloonDecompressed END),
				@DiagCholangiogram			= (CASE WHEN IsNull(ER.DiagCholangiogram, 0) = 0 THEN EE.DiagCholangiogram ELSE ER.DiagCholangiogram END),
				@DiagPancreatogram			= (CASE WHEN IsNull(ER.DiagPancreatogram, 0) = 0 THEN EE.DiagPancreatogram ELSE ER.DiagPancreatogram END),
				@EndoscopistRole			= (CASE WHEN IsNull(ER.CarriedOutRole, 0) = 0 THEN EE.CarriedOutRole ELSE ER.CarriedOutRole END),
				@Other						= (CASE WHEN IsNull(ER.Other, '') ='' THEN EE.Other ELSE ER.Other END),
				@EUSProcType				= (CASE WHEN IsNull(ER.EUSProcType, 0) = 0 THEN EE.EUSProcType ELSE ER.EUSProcType END),
				@CorrectStentPlacement		= ER.CorrectStentPlacement,
				@CorrectStentPlacementNoReason			= (CASE WHEN IsNull(ER.CorrectStentPlacementNoReason, 0) = 0 THEN EE.CorrectStentPlacementNoReason ELSE ER.CorrectStentPlacementNoReason END),
				@BalloonDilatation			= (CASE WHEN IsNull(ER.BalloonDilatation, 0) = 0 THEN EE.BalloonDilatation ELSE ER.BalloonDilatation END),
				@BougieDilatation			= (CASE WHEN IsNull(ER.BougieDilatation, 0) = 0 THEN EE.BougieDilatation ELSE ER.BougieDilatation END),
				@BougieDilation				= (CASE WHEN IsNull(ER.BougieDilation, 0) = 0 THEN EE.BougieDilation ELSE ER.BougieDilation END),
				@BrushCytology				= (CASE WHEN IsNull(ER.BrushCytology, 0) = 0 THEN EE.BrushCytology ELSE ER.BrushCytology END),
				@Cholangioscopy				= (CASE WHEN IsNull(ER.Cholangioscopy, 0) = 0 THEN EE.Cholangioscopy ELSE ER.Cholangioscopy END),
				@StentChange				= (CASE WHEN IsNull(ER.StentChange, 0) = 0 THEN EE.StentChange ELSE ER.StentChange END),
				@StentPlacement				= (CASE WHEN IsNull(ER.StentPlacement, 0) = 0 THEN EE.StentPlacement ELSE ER.StentPlacement END),
				@RadioFrequencyAblation		= (CASE WHEN IsNull(ER.RadioFrequencyAblation, 0) = 0 THEN EE.RadioFrequencyAblation ELSE ER.RadioFrequencyAblation END),
				@FineNeedleAspiration		= (CASE WHEN IsNull(ER.FineNeedleAspiration, 0) = 0 THEN EE.FineNeedleAspiration ELSE ER.FineNeedleAspiration END),
				@FineNeedleAspirationType	= (CASE WHEN IsNull(ER.FineNeedleAspirationType, 0) = 0 THEN EE.FineNeedleAspirationType ELSE ER.FineNeedleAspirationType END),
				@FineNeedleBiopsy			= (CASE WHEN IsNull(ER.FineNeedleBiopsy, 0) = 0 THEN EE.FineNeedleBiopsy ELSE ER.FineNeedleBiopsy END),
				@Polypectomy				= (CASE WHEN IsNull(ER.[Polypectomy], 0) = 0 THEN EE.[Polypectomy] ELSE ER.[Polypectomy] END)
			FROM eeRecord AS EE
	  INNER JOIN #tmp_ERCPTherapeutics AS ER ON EE.SiteId = ER.SiteId;
		END	--## Selecting from Combine
				
	
	IF @None = 1
		SET @summary = @summary + 'No specimens taken'
	ELSE
	BEGIN
		----------------------
        -- Sphincterotomy
        ----------------------
		IF @Papillotomy = 1
		BEGIN
			SET @msg =' Sphincterotomy'
			SET @Details = ''
			IF @ReasonForPapillotomy > 0 
			BEGIN
				SET @Details = @Details + ' ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'ERCP papillotomy reason' AND [ListItemNo] = @ReasonForPapillotomy)

				--Place the word 'for' in front of the reason for the papillotomy if required.
				IF LEFT(UPPER(LTRIM(@Details)),4) <> 'FOR ' SET @Details = ' for ' + @Details
				SET @msg = @msg + ' (' + @Details + ')'
				SET @Details = ''
			END
			IF @PapillotomyLength > 0 SET @Details = @Details + ' ' + CAST(@PapillotomyLength as varchar(50)) + 'mm'
			IF @Sphincterotome > 0 SET @Details = @Details + ' using ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Therapeutic ERCP sphincterotomes' AND [ListItemNo] = @Sphincterotome)
			IF @PapillotomyBleeding > 0 
			BEGIN
				If LEN(RTRIM(LTRIM(@Details))) > 0 SET @Details = @Details + ','
				SET @Details = @Details + CASE @PapillotomyBleeding
											WHEN 1 THEN ' with no bleeding'   
											WHEN 2 THEN ' with minor bleeding'  
											WHEN 3 THEN ' with major bleeding'
											ELSE '' 
										END   
			END
			IF @PapillotomyAcceptBalloonSize > 0 
			BEGIN
				If LEN(RTRIM(LTRIM(@Details))) > 0 SET @Details = @Details + ','
				SET @Details = @Details + ' incision accepted ' + cast(@PapillotomyAcceptBalloonSize as varchar(50)) + 'ml balloon'
			END
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END
		
		----------------------
        -- Pancreatic orifice sphincterotomy
        ----------------------
		IF @PanOrificeSphincterotomy = 1
		BEGIN
			SET @msg =' Pancreatic orifice sphincterotomy'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		----------------------
        -- Stone removal
        ----------------------
		IF @StoneRemoval = 1
		BEGIN
			SET @msg =' Stone removal'
			SET @Details = ''

			IF @ExtractionOutcome > 0 
			BEGIN
				SET @Details = @Details + CASE @ExtractionOutcome
											WHEN 1 THEN ' complete extraction'   
											WHEN 2 THEN ' fragmented'  
											WHEN 3 THEN ' partial extraction'
											WHEN 4 THEN ' unable to extract'
											ELSE '' 
										END   
				DECLARE @cnt bit = 0
				IF @ExtractionOutcome BETWEEN 3 AND 4
				BEGIN
					DECLARE @tmpDiv TABLE(Val VARCHAR(MAX))
					DECLARE @XMLlist XML

					IF @InadequateSphincterotomy > 0
					BEGIN
						INSERT INTO @tmpDiv (Val) VALUES('inadequate sphincterotomy')
					END

					IF @StoneSize > 0
					BEGIN
						INSERT INTO @tmpDiv (Val) VALUES('stone size')
					END

					IF @QuantityOfStones > 0
					BEGIN
						INSERT INTO @tmpDiv (Val) VALUES('quantity of stones')
					END

					IF @ImpactedStones > 0
					BEGIN
						INSERT INTO @tmpDiv (Val) VALUES('impacted stone(s)')
					END

					IF @OtherReason > 0
					BEGIN
						IF LTRIM(RTRIM(ISNULL(@OtherReasonText,''))) <> ''
						BEGIN
							INSERT INTO @tmpDiv (Val) VALUES(@OtherReasonText)
						END
					END

					IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
					BEGIN
						SET @XMLlist = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
						SET @Details = @Details + ' due to ' + dbo.fnBuildString(@XMLlist)
					END
				END
			END

			IF @RemovalUsing > 0 SET @Details = @Details + ' using ' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'ERCP stone removal method' AND [ListItemNo] = @RemovalUsing)


			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		----------------------
        -- Stricture dilatation
        ----------------------
		IF @StrictureDilatation= 1
			BEGIN
			SET @msg =' Stricture dilatation'
			SET @Details = ''

			IF @DilatedTo > 0 
			BEGIN
				SET @Details = @Details + ' dilated to ' + cast(@DilatedTo as varchar(50)) + ' ' + 
									ISNULL((SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilatation units' AND [ListItemNo] = @DilatationUnits),'')
			END

			--Dilator type
			IF @DilatorType > 0 
			BEGIN
				DECLARE @tmpDilatorType VARCHAR(100) = (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilator' AND [ListItemNo] = @DilatorType)
				IF UPPER(LEFT(LTRIM(@tmpDilatorType),5)) = 'WITH ' OR UPPER(LEFT(LTRIM(@tmpDilatorType),3)) = 'BY ' 
					SET @Details = @Details + ' ' + @tmpDilatorType
				ELSE
					SET @Details = @Details + ' with ' + @tmpDilatorType
			END	
			
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		----------------------
        -- Endoscopic cyst puncture
        ----------------------
		IF @EndoscopicCystPuncture = 1
		BEGIN
			SET @msg =' Endoscopic cyst puncture'
			SET @Details = ''
			IF @CystPunctureDevice > 0 SET @Details = @Details + ' using ' + 
															(SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'ERCP cyst punct device' AND [ListItemNo] = @CystPunctureDevice)

			SET @Details = @Details + CASE @CystPunctureVia
							WHEN 1 THEN ' via papilla'   
							WHEN 2 THEN ' via medial wall of duodenum (cyst-duodenostomy)'  
							WHEN 3 THEN ' via stomach (cyst-gastrostomy)'
							ELSE '' 
						END   

			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Nasobiliary/pancreatic drain
        -------------------------------
		IF @NasopancreaticDrain = 1
		BEGIN
			IF EXISTS ( SELECT r.Region FROM ERS_AbnormalitiesMatrixERCP m 
							LEFT JOIN ERS_Regions r ON m.Region = r.Region 
									AND r.Region IN ('Uncinate Process', 'Head', 'Neck', 'Body', 'Tail', 'Accessory Pancreatic Duct', 'Main Pancreatic Duct')
							LEFT JOIN ERS_Sites s ON r.RegionId  = s.RegionID  
							WHERE s.siteId = @SiteId)
				SET @msg =' Nasopancreatic drain'
			ELSE
				SET @msg =' Nasobiliary drain'


			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Combined procedure
        -------------------------------
		IF @RendezvousProcedure = 1
		BEGIN
			SET @msg =' Combined procedure (rendezvous)'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Snare excision
        -------------------------------
		IF @SnareExcision = 1
		BEGIN
			SET @msg =' Snare excision'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		----------------------
        -- Balloon sphincteroplasty
        ----------------------
		IF @BalloonDilation= 1
			BEGIN
			SET @msg =' Balloon sphincteroplasty'
			SET @Details = ''

			IF @BalloonDilatedTo > 0 
			BEGIN
				SET @Details = @Details + ' dilated to ' + cast(@BalloonDilatedTo as varchar(50)) + ' ' + 
									(SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilatation units' AND [ListItemNo] = @BalloonDilatationUnits)
			END

			--Balloon Dilator type
			IF @BalloonDilatorType > 0 
			BEGIN
				DECLARE @tmpBalloonDilatorType VARCHAR(100) = (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'ERCP balloon dilator' AND [ListItemNo] = @BalloonDilatorType)
				IF UPPER(LEFT(LTRIM(@tmpBalloonDilatorType),5)) = 'WITH ' OR UPPER(LEFT(LTRIM(@tmpBalloonDilatorType),3)) = 'BY ' 
					SET @Details = @Details + ' ' + @tmpBalloonDilatorType
				ELSE
					SET @Details = @Details + ' with ' + @tmpBalloonDilatorType
			END	
			
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END


		----------------------
        -- Balloon trawl
        ----------------------
		IF @BalloonTrawl = 1
			BEGIN
			SET @msg =' Balloon trawl'
			SET @Details = ''

			IF @BalloonTrawlDilatorType > 0 
			BEGIN
				DECLARE @DilType VARCHAR(100) = (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'ERCP Balloon dilator' AND [ListItemNo] = @BalloonTrawlDilatorType)
				IF LTRIM(RTRIM(@DilType)) <> ''
				BEGIN
					
					IF UPPER(LEFT(@DilType,1)) in ('A','E','I','O','U') 
						SET @Details = @Details + ' using an' 
					ELSE
						SET @Details = @Details + ' using a'

					SET @Details = @Details + ' ' + @DilType
				END
			END

			IF @BalloonTrawlDilatorUnits >= 0 
			BEGIN
				IF @BalloonTrawlDilatorSize > 0 
				BEGIN
					SET @Details = @Details + ' dilated to ' + cast(@BalloonTrawlDilatorSize as varchar(50)) + ' ' + 
									(SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilatation units' AND [ListItemNo] = @BalloonTrawlDilatorUnits)
				END
			END
			
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Cannulation
        -------------------------------
		IF @Cannulation = 1
		BEGIN
			SET @msg =' Cannulation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Manometry
        -------------------------------
		IF @Manometry = 1
		BEGIN
			SET @msg =' Manometry'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Haemostasis
        -------------------------------
		IF @Haemostasis = 1
		BEGIN
			SET @msg =' Haemostasis'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Diagnostic cholangiogram
        -------------------------------
		IF @DiagCholangiogram = 1
		BEGIN
			SET @msg =' Diagnostic cholangiogram'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		-------------------------------
        -- Diagnostic pancreatogram
        -------------------------------
		IF @DiagPancreatogram = 1
		BEGIN
			SET @msg =' Diagnostic pancreatogram'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg= @msg+'.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

	-- DUODENUM -----
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
				SET @summary = @summary + @msg + '<br/>'
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
			SET @summary = @summary + @msg + '<br/>'
			END

			
		IF @Injection= 1
			BEGIN
			SET @msg =' Injection'
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
			SET @summary = @summary + @msg + '<br/>'
		END
	
		IF @Diathermy = 1
			BEGIN
			SET @msg = ' Diathermy'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @BicapElectro = 1
			BEGIN
			SET @msg = ' Bicap electrocautery'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @HeatProbe = 1
			BEGIN
			SET @msg = ' Heater probe coagulation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END
		
		IF @HotBiopsy = 1
			BEGIN
			SET @msg = ' Hot biopsy'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @BandLigation = 1
			BEGIN
			SET @msg = ' Band ligation'
			IF @BandLigationPerformed > 0 SET @msg = @msg + ' performed ' + CAST(@BandLigationPerformed AS VARCHAR(100)) + CASE WHEN @BandLigationPerformed = 1 THEN ' procedure' ELSE ' procedures' END
			IF @BandLigationPerformed > 0 AND @BandLigationSuccess > 0 SET @msg = @msg + ' and ' + CAST(@BandLigationSuccess AS VARCHAR(100)) + CASE WHEN @BandLigationPerformed = 1 THEN ' was successful.' ELSE ' were successful.' END 
				ELSE IF @BandLigationPerformed = 0 AND @BandLigationSuccess > 0 SET @msg = @msg + ' ' + CAST(@BandLigationSuccess AS VARCHAR(100)) + CASE WHEN @BandLigationPerformed = 1 THEN ' procedure was successful.' ELSE ' procedures were successful.' END 
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @BotoxInjection = 1
			BEGIN
			SET @msg = ' Botox injection'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @EndoloopPlacement = 1
			BEGIN
			SET @msg = ' Endoloop placement'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @ForeignBody = 1
			BEGIN
			SET @msg = ' Foreign body removal'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		----------------------
        -- Stent insertion
        ----------------------
		IF @StentInsertion= 1
			BEGIN

			IF @CorrectStentPlacement IS NOT NULL
			BEGIN
				IF @CorrectStentPlacement = 1
				BEGIN
					SET @msg = ' Correct placement across stricture '
				END
				ELSE IF @CorrectStentPlacement = 0
				BEGIN
					SET @msg = ' Incorrect placement across stricture '

					IF @CorrectStentPlacementNoReason >= 0
					BEGIN
						SET @msg = @msg + '(' +   (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Correct Placement Across Stricture' AND [ListItemNo] = @CorrectStentPlacementNoReason) + ')'
					END
				END

				--Add full stop 
				SET @msg = RTrim(LTRIM(@msg))
				IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
				--------------
				SET @summary = @summary + @msg + '<br/>'
			END

			SET @msg =' Stent insertion'
			SET @Details = ''

			--Qty of stents used
			IF @StentInsertionQty > 0 SET @Details = @Details + '  ' + cast(@StentInsertionQty as varchar(50))

			IF @RadioactiveWirePlaced > 0  SET @Details = @Details + ', radiotherapeutic wire placed' 
			IF ISNULL(@StentInsertionBatchNo,'') <> ''  SET @Details = @Details + ', batch ' + LTRIM(RTRIM(@StentInsertionBatchNo))

			SET @Details = @Details + dbo.ercp_stentinsertions_summary(@TherapeuticId)
			
			If @Details<>'' SET @msg = @msg + ': ' + @Details 
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
		END

		----------------------
        -- Stent removal
        ----------------------
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
			SET @summary = @summary + @msg + '<br/>'
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
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @GastrostomyInsertion =1
		BEGIN
			DECLARE @G bit, @J bit, @N bit
			--SELECT @j = i.[JejunostomyInsertion], @G =i.[GastrostomyInsertion],@N = i.[NasoDuodenalTube] FROM [ERS_UpperGIIndications] i LEFT JOIN [ERS_Sites] s ON i.ProcedureId = s.ProcedureId WHERE s.SiteId = @SiteID
			--IF @N = 1 SET @msg =' Nasojejunal tube (NJT)' ELSE IF @J= 1 SET @msg =' Jejunostomy insertion (PEJ)' ELSE SET @msg =' Gastrostomy insertion (PEG)'
			SET @msg =' Nasojejunal tube (NJT)' -- For ERCP, it is Nasojejunal
			SET @Details = ''

			IF @GastrostomyInsertionType > 0
			BEGIN
				IF @GastrostomyInsertionSize>0
				BEGIN
					SET @Details = @Details + cast(@GastrostomyInsertionSize as varchar(50))
					--IF @J=1 
					SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG units' AND [ListItemNo] = @GastrostomyInsertionUnits)
					--ELSE IF @N =1 SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG units' AND [ListItemNo] = @GastrostomyInsertionUnits)
					--ELSE SET @Details = @Details + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Gastrostomy PEG units' AND [ListItemNo] = @GastrostomyInsertionUnits)
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
			SET @summary = @summary + @msg + '<br/>'
		END

		IF @GastrostomyRemoval = 1
			BEGIN
			SET @msg = ' Nasojejunal tube (NJT) removal'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + '<br/>'
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

		-------------------------------
        -- Pyloric/duodenal dilatation
        -------------------------------
		IF @PyloricDilatation= 1
		BEGIN
			SET @msg =' Pyloric dilatation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		-------------------------------
        -- Balloon Dilatation
        -------------------------------
		IF @BalloonDilatation= 1
		BEGIN
			SET @msg =' Balloon dilatation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		-------------------------------
        -- Bougie Dilatation
        -------------------------------
		IF @BougieDilatation= 1
		BEGIN
			SET @msg =' Bougie dilatation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		-------------------------------
        -- Bougie Dilation
        -------------------------------
		IF @BougieDilation= 1
		BEGIN
			SET @msg =' Bougie dilation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		-------------------------------
        -- Brush Cytology
        -------------------------------
		IF @BrushCytology= 1
		BEGIN
			SET @msg =' Brush cytology'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		-------------------------------
        -- Cholangioscopy
        -------------------------------
		IF @Cholangioscopy= 1
		BEGIN
			SET @msg =' Cholangioscopy'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END
		
		-------------------------------
        -- Stent Change
        -------------------------------
		IF @StentChange= 1
		BEGIN
			SET @msg =' Stent change'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END
		
		-------------------------------
        -- Stent Placement
        -------------------------------
		IF @StentPlacement= 1
		BEGIN
			SET @msg =' Stent placement'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END
		
		-------------------------------
        -- Radio Frequency Ablation
        -------------------------------
		IF @RadioFrequencyAblation= 1
		BEGIN
			SET @msg =' Radio frequency ablation'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		-------------------------------
        -- FNA
        -------------------------------
		IF @FineNeedleAspiration= 1
		BEGIN
			SET @msg =' FNA'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		-------------------------------
        -- FNB
        -------------------------------
		IF @FineNeedleBiopsy= 1
		BEGIN
			SET @msg =' FNB'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END
		
		-------------------------------
        -- Polypectomy
        -------------------------------
		IF @Polypectomy= 1
		BEGIN
			SET @msg =' Polypectomy'
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
			SET @summary =  @summary + @msg  +'<br/>'
		END

	END;

	UPDATE dbo.ERS_ERCPTherapeutics 
	SET Summary=@summary 
	WHERE SiteID = @SiteId; --Id = @TherapeuticId

	DROP TABLE #tmp_ERCPTherapeutics;
GO



PRINT N'Altering [dbo].[common_polpydetails_summary]...';


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER OFF;


GO
ALTER FUNCTION [dbo].[common_polpydetails_summary]
(
	@SiteId int,
	@PolypDetailId int = NULL
)
RETURNS VARCHAR(max)
AS
BEGIN
	DECLARE 
	@PolypType varchar(100),
	@TumourType varchar(100),
	@PolypCondition varchar(100), 
	@Tattooed varchar(100),
	@TattooMarkingType varchar(100),
	--@PolypDetailId int,
	@Quantity int,
	@summary varchar(max) = '',
	@Probably bit,
	@TumourTypeId int,
	@Size int,
	@ParisClass int,
	@PitPattern int,
	@Excised int,
	@Retrieved int,
	@ToLabs int,
	@Removal int,
	@RemovalType varchar(10) = '',
	@RemovalMethod int,
	@RemovalBy varchar(10) = '',
	@Inflam bit,
	@PostInflam bit,
	@TattooedId int,
	@TattooMarkingTypeId int,
	@Count int

	SELECT @Quantity = count(*)
	FROM ERS_CommonAbnoPolypDetails WHERE SiteId = @SiteId AND PolypDetailId = ISNULL(@PolypDetailId, PolypDetailId)

	SELECT @PolypType = LOWER([Description])
	FROM ERS_PolypTypes pt
		INNER JOIN ERS_CommonAbnoPolypDetails l ON pt.UniqueId = l.PolypTypeId
	WHERE SiteId = @SiteId


	DECLARE cur CURSOR FOR
	SELECT ecapd.PolypDetailId, ecapd.Size, ecapd.Excised, ecapd.Retreived, ecapd.Successful, ecapd.Removal, ecapd.RemovalMethod, ecapd.Probably, ecapd.Type, ecapd.ParisClass, ecapd.PitPattern, 
		ecapd.Infammatory, ecapd.PostInflammatory, ecapd.TattooedId, ecapd.TattooedMarkingTypeId
	FROM dbo.ERS_CommonAbnoPolypDetails ecapd
	WHERE SiteId = @SiteId AND PolypDetailId = ISNULL(@PolypDetailId, PolypDetailId)

	SET @summary = CASE WHEN @PolypDetailId IS NULL THEN CONVERT(VARCHAR(10), @Quantity) + ' ' + @PolypType + CASE WHEN @Quantity = 1 THEN ' polyp' ELSE ' polyps' END ELSE '' END
	SET @Count = 1
	--loop through records
	OPEN cur
	FETCH NEXT FROM cur INTO @PolypDetailId, @Size, @Excised, @Retrieved, @ToLabs, @Removal, @RemovalMethod, @Probably, @TumourTypeId, @ParisClass, @PitPattern, @Inflam, @PostInflam, @TattooedId, @TattooMarkingTypeId

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET  @Tattooed = NULL
		SET @TumourType = ''
		SET @TattooMarkingType = NULL

		--build up summary report
		SELECT @TumourType = LOWER(ISNULL([Description],''))
		FROM ERS_TumourTypes
		WHERE UniqueId = @TumourTypeId

		SELECT @Tattooed = LOWER([Description])
		FROM ERS_TattooOptions
		WHERE UniqueId = @TattooedId

		SELECT @TattooMarkingType = LOWER(ISNULL([Description],''))
		FROM ERS_MarkingTypes
		WHERE UniqueId = @TattooMarkingTypeId

		SELECT @PolypCondition = (
			SELECT STUFF((SELECT ', ' + LOWER(ISNULL([SummaryTerm],''))as [text()] 
		    FROM ERS_CommonAbnoPolypConditions cc
				INNER JOIN ERS_PolypConditions pd on cc.PolypConditionId = pd.UniqueId
			WHERE PolypDetailId = @PolypDetailId AND [Description] <> 'Hyperplastic'
			ORDER BY ISNULL(ListOrderBy,9999)
		    FOR XML PATH('')),1,1,''))
		
		SELECT @RemovalType = LOWER([Description])
		FROM ERS_PolypRemovalMethods
		WHERE UniqueId = @Removal

		SELECT @RemovalBy = LOWER([Description])
		FROM ERS_PolypRemovalTypes
		WHERE UniqueId = @RemovalMethod

		SELECT @PolypCondition = dbo.fnStringToSentance(@PolypCondition)

		DECLARE @IsHyperplastic BIT = (SELECT 1 FROM ERS_CommonAbnoPolypConditions cc
				INNER JOIN ERS_PolypConditions pd on cc.PolypConditionId = pd.UniqueId
			WHERE PolypDetailId = @PolypDetailId AND [Description] = 'Hyperplastic')

		IF @Quantity > 1 SET @summary = @summary + '<br/>Polyp ' + convert(varchar(10), @Count) + '- '
		IF ISNULL(@PolypCondition,'') <> '' OR ISNULL(@IsHyperPlastic,0) = 1
		BEGIN
		 SET @summary = @summary + CASE WHEN ISNULL(@IsHyperPlastic,0) = 1 THEN 'Hyperplastic ' ELSE '' END +  CASE WHEN ISNULL(@PolypCondition,'') <> '' THEN 'with' + @PolypCondition ELSE '' END + ': ' --ELSE SET @summary = @summary + '<br/>'
		END

		IF @PolypType = 'sessile'
			BEGIN
				IF @Probably = 1 SET @summary = @summary + 'probably '

				SET @summary = @summary + ' ' + @TumourType + ' '

				IF (@Quantity > 0 AND @Size > 0) 
				BEGIN
					SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @Size) + 'mm) '
				END

				IF @ParisClass > 0 OR @PitPattern > 0
				BEGIN
					SET @summary = @summary + '('

					IF @ParisClass > 0 
					SET @summary = @summary +
							 CASE @ParisClass
								   WHEN  1 THEN 'Paris Is'
								   WHEN  2 THEN 'Paris IIa'
								   WHEN  3 THEN 'Paris IIa + IIc'
								   WHEN  4 THEN 'Paris IIb'
								   WHEN  5 THEN 'Paris IIc'
								   WHEN  6 THEN 'Paris IIc + IIa'
								   WHEN  7 THEN 'Paris Ip'
								   WHEN  8 THEN 'Paris Isp'
								   WHEN  10 THEN 'Paris LST-G'
								   WHEN  11 THEN 'Paris LST-NG'
								   WHEN  12 THEN 'Paris LST-D'
								   WHEN  13 THEN 'Paris LST-M'
								   ELSE ''
					END

					IF @PitPattern > 0 
					BEGIN
						IF @ParisClass > 0 SET @summary = @summary + ', '
				
						SET @summary = @summary +
								   CASE @PitPattern
										  WHEN  1 THEN 'pit type I'
										  WHEN 2 THEN 'pit type II'
										  WHEN  3 THEN 'pit type IIIs'
										  WHEN  4 THEN 'pit type IIIL'
										  WHEN  5 THEN 'pit type IV'
										  WHEN  6 THEN 'pit type V'
							ELSE ''
						END
					END

					SET @summary = @summary + ')'
				END

				IF @Excised = 1 
				BEGIN
					SET @summary = @summary + '$$ '
					SET @summary = @summary + 'excised '

					IF @Removal > 0 OR @RemovalMethod > 0
					BEGIN
						SET @summary = @summary + '(removed '
				
						IF @Removal > 0 SET @summary = @summary + @RemovalBy + ' '
						IF @RemovalMethod > 0 SET @summary = @summary + @RemovalType
						
						SET @summary = @summary + ')'
					END
				END

				IF @Retrieved = 1 
				BEGIN
					SET @summary = @summary + '$$ '
					SET @summary = @summary + 'retrieved '
				END

				IF @ToLabs = 1  
				BEGIN
					SET @summary = @summary + '$$ '
					SET @summary = @summary + 'sent to labs '
				END
						

				-- Set the last occurence of $$ to "and"
				IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 3, ' and ')
				-- Replace all other occurences of $$ with commas
				SET @summary = REPLACE(@summary, '$$', ',')
			END

			------------------------------------------------------------------------------------------
			-------	PEDUNCULATED -------
			------------------------------------------------------------------------------------------
			ELSE IF @PolypType = 'pedunculated'
			BEGIN
				--IF @Quantity > 0 SET @summary = @summary + CONVERT(VARCHAR(20), @Quantity) + ' '
		
				IF @Probably = 1 SET @summary = @summary + 'probably '

				IF @TumourTypeId = 1 SET @summary = @summary + 'benign '
				ELSE IF @TumourTypeId = 2 SET @summary = @summary + 'malignant '

				IF @ParisClass = 2 
					SET @summary = @summary + 'sub pedunculated ' 
				--ELSE
				--	SET @summary = @summary + 'polyp ' 

				IF (@Quantity > 0 AND @Size > 0) 
				BEGIN
					SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @Size) + 'mm) '
				END

				IF @ParisClass > 0 OR @PitPattern > 0
				BEGIN
					SET @summary = @summary + '('

					IF @ParisClass > 0 
					SET @summary = @summary +
					CASE 
						 WHEN  @ParisClass = 7 THEN 'Paris IP'
						 WHEN  @ParisClass = 8 THEN 'Paris Isp'
						ELSE ''
					END

					IF @PitPattern > 0 
					BEGIN
						IF @ParisClass > 0 SET @summary = @summary + ', '
				
						SET @summary = @summary +
						CASE 
							WHEN @PitPattern = 1 THEN 'pit type I'
							WHEN @PitPattern = 2 THEN 'pit type II'
							WHEN @PitPattern = 3 THEN 'pit type IIIs'
							WHEN @PitPattern = 4 THEN 'pit type IIIL'
							WHEN @PitPattern = 5 THEN 'pit type IV'
							WHEN @PitPattern = 6 THEN 'pit type V'
							ELSE ''
						END
					END

					SET @summary = @summary + ')'
				END

				IF @Excised =1
				BEGIN
					SET @summary = @summary + '$$ '
					SET @summary = @summary + ' excised '

					IF @Removal > 0 OR @RemovalMethod > 0
					BEGIN
						SET @summary = @summary + '(removed '
				
						IF @Removal > 0 SET @summary = @summary + @RemovalBy + ' '
						IF @RemovalMethod = 1 SET @summary = @summary + @RemovalType
				
						SET @summary = @summary + ')'
					END
				END

				IF @Retrieved =1 
				BEGIN
					SET @summary = @summary + '$$ '
					SET @summary = @summary + 'retrieved '
				END

				IF @ToLabs =1 
				BEGIN
					SET @summary = @summary + '$$ '
					SET @summary = @summary + 'sent to labs '
				END

				SET @summary = @summary + ')'
				-- Set the last occurence of $$ to "and"
				IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 3, ' and ')
				-- Replace all other occurences of $$ with commas
				SET @summary = REPLACE(@summary, '$$', ',')
			END

			------------------------------------------------------------------------------------------
			-------	PSEUDOPOLYPS -------
			------------------------------------------------------------------------------------------
			ELSE IF @PolypType = 'pseudo'
			BEGIN
				--IF @Quantity > 0 SET @summary = @summary + CONVERT(VARCHAR(20), @Quantity) + ' '

				IF @Inflam = 1 AND @PostInflam = 0 SET @summary = @summary + 'inflammatory '
				ELSE IF @Inflam = 0 AND @PostInflam = 1 SET @summary = @summary + 'post-inflammatory '
				ELSE IF @Inflam = 1 AND @PostInflam = 1 SET @summary = @summary + 'inflammatory and post-inflammatory '
		
				--SET @summary = @summary + 'pseudopolyp ' 

				IF (@Quantity > 0 AND @Size > 0) 
				BEGIN
					SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @Size) + 'mm) '
				END

				IF @ParisClass > 0 OR @PitPattern > 0
				BEGIN
					SET @summary = @summary + '('

					IF @ParisClass > 0 
					SET @summary = @summary +
					 CASE @ParisClass
						WHEN  1 THEN 'Paris Is'
						WHEN  2 THEN 'Paris IIa'
						WHEN  3 THEN 'Paris IIa + IIc'
						WHEN  4 THEN 'Paris IIb'
						WHEN  5 THEN 'Paris IIc'
						WHEN  6 THEN 'Paris IIc + IIa'
						WHEN  7 THEN 'Paris Ip'
						WHEN  8 THEN 'Paris Isp'
						WHEN  10 THEN 'Paris LST-G'
						WHEN  11 THEN 'Paris LST-NG'
						WHEN  12 THEN 'Paris LST-D'
						WHEN  13 THEN 'Paris LST-M'
						ELSE ''
					END

					IF @PitPattern > 0 
					BEGIN
						IF @ParisClass > 0 SET @summary = @summary + ', '
				
						SET @summary = @summary +
						CASE 
							WHEN @PitPattern = 1 THEN 'pit type I'
							WHEN @PitPattern = 2 THEN 'pit type II'
							WHEN @PitPattern = 3 THEN 'pit type IIIs'
							WHEN @PitPattern = 4 THEN 'pit type IIIL'
							WHEN @PitPattern = 5 THEN 'pit type IV'
							WHEN @PitPattern = 6 THEN 'pit type V'
							ELSE ''
						END
					END

					SET @summary = @summary + ')'
				END

				IF @Excised =1 
				BEGIN
					SET @summary = @summary + '$$ '
					SET @summary = @summary + 'excised '

					IF @Removal > 0 OR @RemovalMethod > 0
					BEGIN
						SET @summary = @summary + '(removed '
				
						IF @Removal > 0 SET @summary = @summary + @RemovalBy + ' '
						IF @RemovalMethod = 1 SET @summary = @summary + @RemovalType

						
					END
				END

				IF @Retrieved =1 
				BEGIN
					SET @summary = @summary + '$$ '
					SET @summary = @summary + 'retrieved '
				END

				IF @ToLabs =1 
				BEGIN
					SET @summary = @summary + '$$ '
					SET @summary = @summary + 'sent to labs '
				END

				SET @summary = @summary + ')'

				-- Set the last occurence of $$ to "and"
				IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 3, ' and ')
				-- Replace all other occurences of $$ with commas
				SET @summary = REPLACE(@summary, '$$', ',')
			END
			------------------------------------------------------------------------------------------
			-------	SUBMUCOSAL -------
			------------------------------------------------------------------------------------------
			ELSE IF @PolypType = 'submucosal'
			BEGIN
				IF (@Quantity > 0 AND @Size > 0) 
				BEGIN
					SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @Size) + 'mm) '
				END


				-- Set the last occurence of $$ to "and"
				IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 3, ' and')
				-- Replace all other occurences of $$ with commas
				SET @summary = REPLACE(@summary, '$$', ',')
			END

			IF ISNULL(@Tattooed,'no') <> 'no'
			BEGIN
				SET @summary = @summary + '. Polyp ' + CASE WHEN @Tattooed = 'yes' THEN 'tattooed' ELSE ISNULL(@Tattooed, 'previously tattooed') END + CASE WHEN ISNULL(@TattooMarkingType,'') <> '' THEN ' using ' + @TattooMarkingType ELSE '' END
			END
		SET @Count = @Count + 1
		FETCH NEXT FROM cur INTO @PolypDetailId, @Size, @Excised, @Retrieved, @ToLabs, @Removal, @RemovalMethod, @Probably, @TumourTypeId, @ParisClass, @PitPattern, @Inflam, @PostInflam, @TattooedId, @TattooMarkingTypeId

	END

	CLOSE cur
	DEALLOCATE cur

	RETURN @summary + '##'
END
GO



PRINT N'Creating [dbo].[abnormalities_common_lesions_update]...';


GO


EXEC dbo.DropIfExist @ObjectName = 'abnormalities_common_lesions_update',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[abnormalities_common_lesions_update]
(
	@SiteId INT,
	@PolypTypeId INT,
	@LoggedInUserId int
)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM ERS_CommonAbnoLesions WHERE SiteId = @SiteId)
	BEGIN
		INSERT INTO dbo.ERS_CommonAbnoLesions
		(
		    SiteId,
		    None,
		    Polyp,
			Focal,
		    PolypTypeId,
		    WhoCreatedId,
		    WhenCreated
		)
		VALUES
		(   @SiteId,       -- SiteId - int
		    0, -- None - bit
		    1, -- Polyp - bit
			0, -- Focal - bit
		    @PolypTypeId,    -- PolypTypeId - int
		    @LoggedInUserId, -- WhoCreatedId - int
		    GETDATE()
		)

		INSERT INTO ERS_RecordCount (
			[ProcedureId],
			[SiteId],
			[Identifier],
			[RecordCount]
		)
		VALUES (
			(SELECT ProcedureId FROM ERS_Sites WHERE SiteId = @SiteId),
			@SiteId,
			'Lesions',
			1)
	END
	ELSE
	BEGIN
		UPDATE dbo.ERS_CommonAbnoLesions SET Polyp = 1, PolypTypeId = @PolypTypeId, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE SiteId = @SiteId
	END
	
END
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	
-- TFS#	2774
-- Description of change
-- Adverse events perforation additional info
------------------------------------------------------------------------------------------------------------------------
GO


PRINT N'Altering [dbo].[ProcedureAdverseEventsSummary]...';


GO

ALTER FUNCTION [dbo].[ProcedureAdverseEventsSummary]
(
	@ProcedureId int
)
RETURNS varchar(max)
AS
BEGIN

DECLARE @AdverseEventsString  varchar(max), @ComplicationsString varchar(max),
		@RetVal varchar(max)

SELECT @AdverseEventsString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN i.AdditionalInfo = 0 THEN LOWER([Description]) ELSE LOWER(AdditionalInformation) END + CASE WHEN ISNULL(ChildAdverseEventId, 0) > 0 THEN '-' + 
	(SELECT CASE WHEN i2.AdditionalInfo = 1 THEN [Description] + ': ' + epi.AdditionalInformation ELSE [Description] END FROM ERS_AdverseEvents i2 WHERE UniqueId = epi.ChildAdverseEventId) ELSE '' END AS [text()] 
	FROM ERS_ProcedureAdverseEvents epi 
	INNER JOIN ERS_AdverseEvents i ON i.UniqueId = epi.AdverseEventId
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(i.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

SELECT @AdverseEventsString = dbo.fnCapitalise(@AdverseEventsString)

IF LEN(@AdverseEventsString) > 0
BEGIN
	IF CHARINDEX(',', REVERSE(@AdverseEventsString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />','') + 'Adverse events: ' + STUFF(@AdverseEventsString, LEN(@AdverseEventsString) - CHARINDEX(' ,', REVERSE(@AdverseEventsString)), 2, ' and ') 
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />','') + 'Adverse events: ' + @AdverseEventsString
END
---------------------Complications


--SELECT @ComplicationsString =
--	LTRIM(STUFF((SELECT ', ' + CASE WHEN i.AdditionalInfo = 0 THEN LOWER([Description]) ELSE LOWER(AdditionalInformation) END + CASE WHEN ISNULL(ChildAdverseEventId, 0) > 0 THEN '-' + (SELECT [Description] FROM ERS_AdverseEvents WHERE UniqueId = epi.ChildAdverseEventId) ELSE '' END AS [text()] 
--	FROM ERS_ProcedureAdverseEvents epi 
--	INNER JOIN ERS_AdverseEvents i on i.UniqueId = epi.AdverseEventId
--	WHERE ISNULL(i.Complication,0) = 1 AND ProcedureId=@ProcedureId
--	ORDER BY ISNULL(i.ListOrderBy, 0)
--	FOR XML PATH('')),1,1,''))

--SELECT @ComplicationsString = dbo.fnCapitalise(@ComplicationsString) 

--IF LEN(@ComplicationsString) > 0 
--BEGIN
--	IF charindex(',', reverse(@ComplicationsString)) > 0
--		SELECT @RetVal = ISNULL(@RetVal + '<br />','') + 'Complications: ' + STUFF(@ComplicationsString, len(@ComplicationsString) - charindex(' ,', reverse(@ComplicationsString)), 2, ' and ')
--	ELSE
--		SELECT @RetVal = ISNULL(@RetVal + '<br />','') + 'Complications: ' + @ComplicationsString
--END


RETURN @RetVal
END
GO
PRINT N'Altering [dbo].[ProcedureIndicationsSummary]...';


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER OFF;


GO
ALTER FUNCTION [dbo].[ProcedureIndicationsSummary]
(
	@ProcedureId int
)
RETURNS varchar(max)
AS
BEGIN
/****************************************************
DS Fix bug 2754 12/04/2023
*****************************************************/
DECLARE @IndicationsString  varchar(max), @ComorbidityString varchar(max), @DamagingDrugsString varchar(max), @PatientAllergiesString varchar(max), @PreviousSurgeryString varchar(max), 
		@PreviousDiseasesString varchar(max), @FamilyDiseaseHistoryString varchar(max), @ImagingString varchar(max), @ImagingOutcomeString varchar(max),
		@RetVal varchar(max)

SELECT @IndicationsString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN i.AdditionalInfo = 0 THEN [Description] ELSE AdditionalInformation END + CASE WHEN ISNULL(ChildIndicationId, 0) > 0 THEN '-' + (SELECT [Description] FROM ERS_Indications WHERE UniqueId = epi.ChildIndicationId) ELSE '' END AS [text()] 
	FROM ERS_ProcedureIndications epi 
	INNER JOIN ERS_Indications i on i.UniqueId = epi.IndicationId
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(i.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--rockall and baltchford scoring
SELECT @IndicationsString	= @IndicationsString + CASE WHEN CHARINDEX('melaena', @IndicationsString) > -1 OR CHARINDEX('haematemesis', @IndicationsString) > -1 THEN ' ' + dbo.fnBlatchfordRockallScores(@ProcedureId) ELSE '' END
--SELECT @IndicationsString = dbo.fnCapitalise(dbo.fnAddFullStop(@IndicationsString)) 

IF LEN(@IndicationsString) > 0
BEGIN
	IF charindex(',', reverse(@IndicationsString)) > 0
		SELECT @RetVal = STUFF(@IndicationsString, len(@IndicationsString) - (charindex(' ,', reverse(@IndicationsString)) - 1), 2, ' and ')
	ELSE
		SELECT @RetVal = @IndicationsString
END
-------------------CoMorbidity


SELECT @ComorbidityString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN AdditionalInformation = '' THEN [Description] ELSE AdditionalInformation END + CASE WHEN ISNULL(ChildComorbidityId, 0) > 0 THEN '-' + (SELECT [Description] FROM ERS_CoMorbidity WHERE UniqueId = ChildComorbidityId) ELSE '' END AS [text()] 
	FROM ERS_ProcedureComorbidity epc 
	INNER JOIN ERS_Comorbidity c on c.uniqueid = CoMorbidityId
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(c.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @ComorbidityString = dbo.fnCapitalise(dbo.fnAddFullStop(@ComorbidityString)) 

IF LEN(@ComorbidityString) > 0 
BEGIN
	IF charindex(',', reverse(@ComorbidityString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Co-morbidity: ' + STUFF(@ComorbidityString, len(@ComorbidityString) - charindex(' ,', reverse(@ComorbidityString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Co-morbidity: ' + @ComorbidityString
END

-------------------Damaging drugs

SELECT @DamagingDrugsString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ProcedureDamagingDrugs edd 
	INNER JOIN ERS_PotentialDamagingDrugs d on d.uniqueid = edd.DamagingDrugId
	WHERE edd.ProcedureId=@ProcedureId
	ORDER BY ISNULL(d.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @DamagingDrugsString = dbo.fnCapitalise(dbo.fnAddFullStop(@DamagingDrugsString)) 

DECLARE @AntiCoagDrugs bit = (SELECT AntiCoagDrugs FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
IF @AntiCoagDrugs IS NOT NULL
	If @AntiCoagDrugs = 1 SET @DamagingDrugsString = @DamagingDrugsString + '<br />The patient is taking anti-coagulant or anti-platelet medication.'

IF LEN(@DamagingDrugsString) > 0
BEGIN
	IF charindex(',', reverse(@DamagingDrugsString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Potential damaging drug(s): ' + STUFF(@DamagingDrugsString, len(@DamagingDrugsString) - charindex(' ,', reverse(@DamagingDrugsString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Potential damaging drug(s): ' + @DamagingDrugsString
END
-------------------Allergies

SELECT @PatientAllergiesString =
	CASE AllergyResult 
		WHEN -1 THEN 'unknown'
		WHEN 0 THEN 'none'
		WHEN 1 THEN a.AllergyDescription 
	END
	FROM ERS_PatientAllergies a
		INNER JOIN ERS_Procedures p ON p.PatientId = a.PatientId
	WHERE p.ProcedureId = @ProcedureId

--SELECT @PatientAllergiesString = dbo.fnCapitalise(dbo.fnAddFullStop(@PatientAllergiesString)) 

IF LEN(@PatientAllergiesString) > 0
BEGIN
	IF charindex(',', reverse(@PatientAllergiesString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Allergies: ' + STUFF(@PatientAllergiesString, len(@PatientAllergiesString) - charindex(' ,', reverse(@PatientAllergiesString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Allergies: ' + @PatientAllergiesString
END
-------------------Previous surgery

SELECT @PreviousSurgeryString =
	LTRIM(STUFF((SELECT DISTINCT ', ' + [Description] + CASE WHEN ListItemText = 'Unknown' THEN '' ELSE ' ' + ListItemText END as [text()] 
	FROM ERS_PatientPreviousSurgery h
	INNER JOIN ERS_PreviousSurgery r on r.UniqueID = h.PreviousSurgeryID
	INNER JOIN ERS_Lists l on l.ListItemNo = h.PreviousSurgeryPeriod and ListDescription = 'Follow up disease Period'
	INNER JOIN ERS_Procedures p on p.patientId = h.patientId 
	WHERE p.ProcedureId = @ProcedureId
	--ORDER BY ISNULL(r.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @PreviousSurgeryString = dbo.fnCapitalise(dbo.fnAddFullStop(@PreviousSurgeryString)) 

IF LEN(@PreviousSurgeryString) > 0
BEGIN
	IF charindex(',', reverse(@PreviousSurgeryString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous surgery: ' + STUFF(@PreviousSurgeryString, len(@PreviousSurgeryString) - charindex(' ,', reverse(@PreviousSurgeryString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous surgery: ' + @PreviousSurgeryString
END

-------------------ASA Status
DECLARE @ASAStatusString varchar(max) = 
	(SELECT [description]
	FROM ERS_PatientASAStatus pa 
		INNER JOIN ERS_ASAStatus a on a.uniqueid = pa.asastatusid
		INNER JOIN ERS_Procedures p ON p.ProcedureId = pa.ProcedureCreatedId
	WHERE   pa.ProcedureCreatedId = @ProcedureId)

If (@ASAStatusString is null) 
BEGIN
	SELECT TOP 1 @ASAStatusString = [description] 
						   FROM ERS_PatientASAStatus 
						   INNER JOIN ERS_ASAStatus ON UniqueId = ASAStatusId 
						   WHERE PatientId = (SELECT PatientId FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
						   ORDER BY ProcedureCreatedId DESC
END


IF LEN(@ASAStatusString) > 0 
BEGIN
	SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'ASA Status: ' + @ASAStatusString
END
-------------------Previous diseases

SELECT @PreviousDiseasesString =
	LTRIM(STUFF((SELECT DISTINCT ', ' + [Description] as [text()] 
	FROM ERS_PatientPreviousDiseases pd
	INNER JOIN ERS_PreviousDiseases d on d.UniqueID = pd.PreviousDiseaseID
	INNER JOIN ERS_Procedures p on p.patientId = pd.patientId 
	WHERE p.ProcedureId = @ProcedureId
	--ORDER BY ISNULL(r.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @PreviousDiseasesString = dbo.fnCapitalise(dbo.fnAddFullStop(@PreviousDiseasesString)) 

IF LEN(@PreviousDiseasesString) > 0
BEGIN
	IF charindex(',', reverse(@PreviousDiseasesString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous diseases: ' + STUFF(@PreviousDiseasesString, len(@PreviousDiseasesString) - charindex(' ,', reverse(@PreviousDiseasesString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous diseases: ' + @PreviousDiseasesString
END

-------------------Family disease history

SELECT @FamilyDiseaseHistoryString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN AdditionalInformation = '' THEN [Description] ELSE AdditionalInformation END AS [text()] 
	FROM ERS_PatientFamilyDiseaseHistory epi 
	INNER JOIN ERS_FamilyDiseaseHistory i on i.UniqueId = epi.FamilyDiseaseHistoryId
	INNER JOIN ERS_Procedures p on p.patientId = epi.patientId 
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(i.ListOrderBy, 999)
	FOR XML PATH('')),1,1,''))

--SELECT @FamilyDiseaseHistoryString = dbo.fnCapitalise(dbo.fnAddFullStop(@FamilyDiseaseHistoryString)) 

IF LEN(@FamilyDiseaseHistoryString) > 0
BEGIN
	IF charindex(',', reverse(@FamilyDiseaseHistoryString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Family history: ' + STUFF(@FamilyDiseaseHistoryString, len(@FamilyDiseaseHistoryString) - charindex(' ,', reverse(@FamilyDiseaseHistoryString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Family history: ' + @FamilyDiseaseHistoryString
END


-------------------Imaging

SELECT @ImagingString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ImagingMethods im 
	INNER JOIN ERS_ProcedureImagingMethod pim on im.uniqueid = pim.ImagingMethodId
	WHERE pim.ProcedureId=@ProcedureId
	FOR XML PATH('')),1,1,''))


IF LEN(@ImagingString) > 0
BEGIN
	IF charindex(',', reverse(@ImagingString)) > 0
		SELECT @ImagingString = STUFF(@ImagingString, len(@ImagingString) - charindex(' ,', reverse(@ImagingString)), 2, ' and ')
END


SELECT @ImagingOutcomeString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ImagingOutcomes imo 
	INNER JOIN ERS_ProcedureImagingOutcome pio on imo.uniqueid = pio.ImagingOutcomeId
	WHERE pio.ProcedureId=@ProcedureId
	FOR XML PATH('')),1,1,''))

IF ISNULL(@ImagingOutcomeString,'') <> ''
BEGIN
	SELECT @ImagingString = CASE WHEN ISNULL(@ImagingString, '') <> '' THEN @ImagingString + ' revealed ' ELSE '' END  + @ImagingOutcomeString
END


--SELECT @ImagingString = dbo.fnCapitalise(dbo.fnAddFullStop(@ImagingString)) 

IF LEN(@ImagingString) > 0
BEGIN
	IF charindex(',', reverse(@ImagingString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Imaging: ' + STUFF(@ImagingString, len(@ImagingString) - charindex(' ,', reverse(@ImagingString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Imaging: ' + @ImagingString
END


DECLARE @SmokingString varchar(max)


SELECT @SmokingString=
	LTRIM(STUFF((SELECT '  ' +SmokingDescription   AS [text()] 
	FROM ERS_ProcedureSmoking epi 
	WHERE ProcedureId=@ProcedureId
	FOR XML PATH('')),1,1,''))

--SELECT @SmokingString = dbo.fnCapitalise(dbo.fnAddFullStop(@SmokingString)) 

IF LEN(@SmokingString) > 0
BEGIN
	IF charindex(',', reverse(@SmokingString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Smoking:</b> ' + @SmokingString
		--SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Smoking:</b> ' + STUFF(@SmokingString, len(@SmokingString) - charindex(' ,', reverse(@SmokingString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Smoking:</b> ' + @SmokingString
END

DECLARE @LUTSIPSSString varchar(max)
DECLARE @LUTSIPSSTotalScoreString varchar(max)

SELECT @LUTSIPSSString=
	LTRIM(STUFF((SELECT ', ' + SectionName+'(Score:'+cast(ls.ScoreValue as varchar(10)) +')'   AS [text()] 
	from  ERS_ProcedureLUTSIPSSSymptoms a ,ERS_LUTSIPSSSymptoms b,ERS_LUTSIPSSSymptomSections s,ERS_IPSSScore ls
	where ProcedureId=@ProcedureId and a.LUTSIPSSSymptomId=b.UniqueId and b.LUTSIPSSSymptomSectionId=s.LUTSIPSSSymptomSectionId and SelectedScoreId>1 and a.SelectedScoreId=ls.ScoreId
	FOR XML PATH('')),1,1,''))

--SELECT @LUTSIPSSString = dbo.fnCapitalise(dbo.fnAddFullStop(@LUTSIPSSString)) 

select top 1  @LUTSIPSSTotalScoreString =  'Total Score :' + cast(TotalScoreValue as varchar(10)) 
from  ERS_ProcedureLUTSIPSSSymptoms where ProcedureId=@ProcedureId
IF LEN(@LUTSIPSSString) > 0
BEGIN
	IF charindex(',', reverse(@LUTSIPSSString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>LUTS\IPSS symptom score:</b>' + STUFF(@LUTSIPSSString, len(@LUTSIPSSString) - charindex(' ,', reverse(@LUTSIPSSString)), 2,  ' ' + @LUTSIPSSTotalScoreString + ' '+'<br />')
	     
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>LUTS\IPSS symptom score:</b> ' + @LUTSIPSSString

	--SELECT @RetVal = ISNULL(@RetVal + '<br />', '') +  @LUTSIPSSTotalScoreString
END

DECLARE @PreviousDiseaseUrologyString varchar(max)

SELECT @PreviousDiseaseUrologyString=
	LTRIM(STUFF((SELECT ', ' +case 
       when a.Description='Other' then b.AdditionalInformation
	   else a.Description
	  end
   AS [text()] 
	from ERS_PreviousDiseasesUrology a, ERS_ProcedurePreviousDiseasesUrology b 
	where a.UniqueId=b.PreviousDiseaseId
	and b.ProcedureId=@ProcedureId
	order by PreviousDiseaseSectionId
	FOR XML PATH('')),1,1,''))

--SELECT @PreviousDiseaseUrologyString = dbo.fnCapitalise(dbo.fnAddFullStop(@PreviousDiseaseUrologyString)) 


IF LEN(@PreviousDiseaseUrologyString) > 0
BEGIN
	IF charindex(',', reverse(@PreviousDiseaseUrologyString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Past Urological Histrory:</b>' + STUFF(@PreviousDiseaseUrologyString, len(@PreviousDiseaseUrologyString) - charindex(' ,', reverse(@PreviousDiseaseUrologyString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Past Urological Histrory:</b> ' + @PreviousDiseaseUrologyString

	
END

DECLARE @UrineDipstickCytologyString varchar(max)

SELECT @UrineDipstickCytologyString=
	LTRIM(STUFF((SELECT ', ' + b.Description + ' '+c.Description 
   AS [text()] 
	from ERS_ProcedureUrineDipstickCytology a,ERS_UrineDipstickCytology b,ERS_UrineDipstickCytology c
	where a.ProcedureId=@ProcedureId
	and a.UrineDipstickCytologyId=b.UniqueId
	and a.ChildUrineDipstickCytologyId=c.UniqueId
	order by b.UrineDipstickCytologySectionId,b.ListOrderBy
	FOR XML PATH('')),1,1,''))

--SELECT @UrineDipstickCytologyString = dbo.fnCapitalise(dbo.fnAddFullStop(@UrineDipstickCytologyString)) 


IF LEN(@UrineDipstickCytologyString) > 0
BEGIN
	IF charindex(',', reverse(@UrineDipstickCytologyString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Urine Dipstick And Cytology:</b>' + STUFF(@UrineDipstickCytologyString, len(@UrineDipstickCytologyString) - charindex(' ,', reverse(@UrineDipstickCytologyString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Urine Dipstick And Cytology:</b>' + @UrineDipstickCytologyString

	
END


--------------Broncs referral data
DECLARE @BroncoReferralDataString varchar(max), @DateBronchRequested DATETIME,
		@DateOfReferral DATETIME,
		@LCaSuspectedBySpecialist BIT,
		@CTScanAvailable BIT,
		@DateOfScan DATETIME

	SELECT @DateBronchRequested=DateBronchRequested,
		   @DateOfReferral=DateOfReferral,
		   @LCaSuspectedBySpecialist=LCaSuspectedBySpecialist,
		   @CTScanAvailable=CTScanAvailable,
		   @DateOfScan=DateOfScan
	FROM ERS_ProcedureBronchoReferralData
	WHERE ProcedureId = @ProcedureId

	IF @DateBronchRequested IS NOT NULL SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Date bronchoscopy requested ' + CONVERT(VARCHAR, @DateBronchRequested, 105) + '. '
	IF @DateOfReferral IS NOT NULL SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Date of referral ' + CONVERT(VARCHAR, @DateOfReferral, 105) + '. '
	IF @LCaSuspectedBySpecialist = 1 SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Lung Ca suspected by lung Ca specialist' + '. '
	IF @CTScanAvailable = 1 SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'CT scan available prior to bronchoscopy' + '. '
	IF @DateOfScan IS NOT NULL SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Date of scan ' + CONVERT(VARCHAR, @DateOfScan, 105) + '. '
	

	IF @BroncoReferralDataString IS NOT NULL SET @BroncoReferralDataString = 'Referal Data (' + RTRIM(@BroncoReferralDataString )+ ')'
	ELSE SET @BroncoReferralDataString = ''
	
	IF LEN(@BroncoReferralDataString) > 0
	BEGIN
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + @BroncoReferralDataString
	END

--------------Broncs staging data
	DECLARE 
		@stagingsummary VARCHAR(2000),
		@tmpsummary VARCHAR(2000),
		@SuspectedLCa BIT,
		@StagingInvestigations BIT,
		@ClinicalGrounds BIT,
		@ImagingOfThorax BIT,
		@MediastinalSampling BIT,
		@Metastases BIT,
		@PleuralHistology BIT,
		@Bronchoscopy BIT,
		@Stage BIT,
		@StageT VARCHAR(20),
		@StageN VARCHAR(20),
		@StageM VARCHAR(20),
		@StageType VARCHAR(20),
		@StageDate DATETIME,
		@PerformanceStatus BIT,
		@PerformanceStatusType INT

	DECLARE @tblsummary TABLE (summary VARCHAR(500))

	SELECT 
		@SuspectedLCa = CASE 
							WHEN EXISTS (SELECT 1 FROM ERS_ProcedureIndications WHERE ProcedureId = @ProcedureId AND IndicationId = (SELECT UniqueId FROM ERS_Indications WHERE NEDTerm = 'Suspected lung cancer'))
							THEN 1
							ELSE 0
						END,
		@StagingInvestigations=StagingInvestigations,
		@ClinicalGrounds=ClinicalGrounds,
		@ImagingOfThorax=ImagingOfThorax,
		@MediastinalSampling=MediastinalSampling,
		@Metastases=Metastases,
		@PleuralHistology=PleuralHistology,
		@Bronchoscopy=Bronchoscopy,
		@Stage=Stage,
		@StageT=stageTNames.ListItemText,
		@StageN=stageNNames.ListItemText,
		@StageM=stageMNames.ListItemText,
		@StageType=stageTypes.ListItemText,
		@StageDate=StageDate,
		@PerformanceStatus=PerformanceStatus,
		@PerformanceStatusType=PerformanceStatusType
		
	FROM 
		ERS_ProcedureStaging p
	LEFT JOIN
		ERS_Lists stageTNames ON p.StageT = stageTNames.ListItemNo AND stageTNames.ListDescription = 'BronchoStageT'
	LEFT JOIN
		ERS_Lists stageNNames ON p.StageN = stageNNames.ListItemNo AND stageNNames.ListDescription = 'BronchoStageN'
	LEFT JOIN
		ERS_Lists stageMNames ON p.StageM = stageMNames.ListItemNo AND stageMNames.ListDescription = 'BronchoStageM'
	LEFT JOIN
		ERS_Lists stageTypes ON p.StageType = stageTypes.ListItemNo AND stageTypes.ListDescription = 'BronchoStageType'
	WHERE
		ProcedureId = @ProcedureId


	IF @SuspectedLCa = 1
	BEGIN
		IF @StagingInvestigations = 1 
		BEGIN
			DELETE FROM @tblsummary
			SET @tmpsummary = NULL

			IF @ClinicalGrounds = 1 INSERT INTO @tblsummary VALUES ('Clinical grounds only')
			IF @ImagingOfThorax = 1 INSERT INTO @tblsummary VALUES ('Cross sectional imaging of thorax')
			IF @MediastinalSampling = 1 INSERT INTO @tblsummary VALUES ('Mediastinal sampling')
			IF @Metastases = 1 INSERT INTO @tblsummary VALUES ('Diagnostic tests for metastases')
			IF @PleuralHistology = 1 INSERT INTO @tblsummary VALUES ('Pleural cytology / histology')
			IF @Bronchoscopy = 1 INSERT INTO @tblsummary VALUES ('Bronchoscopy')

			SELECT @tmpsummary = COALESCE(@tmpsummary + ', ', '') + summary
			FROM @tblsummary

			IF @tmpsummary IS NOT NULL SET @tmpsummary = 'Staging Investigations (' + @tmpsummary + ')'
			ELSE SET @tmpsummary = 'Staging Investigations'

			SET @stagingsummary = @tmpsummary
		END

		IF @Stage = 1
		BEGIN
			DELETE FROM @tblsummary
			SET @tmpsummary = NULL

			IF @StageT IS NOT NULL AND @StageT <> '' INSERT INTO @tblsummary VALUES (@StageT)
			IF @StageN IS NOT NULL AND @StageN <> '' INSERT INTO @tblsummary VALUES (@StageN)
			IF @StageM IS NOT NULL AND @StageM <> '' INSERT INTO @tblsummary VALUES (@StageM)
			IF @StageType IS NOT NULL AND @StageType <> '' INSERT INTO @tblsummary VALUES (@StageType)
			IF @StageDate IS NOT NULL INSERT INTO @tblsummary VALUES ('Date ' + CONVERT(VARCHAR, @StageDate, 105))

			SELECT @tmpsummary = COALESCE(@tmpsummary + ', ', '') + summary
			FROM @tblsummary

			IF @tmpsummary IS NOT NULL SET @tmpsummary = 'Stage (' + @tmpsummary + ')'
			ELSE SET @tmpsummary = 'Stage'

			IF @stagingsummary IS NOT NULL SET @stagingsummary = @stagingsummary + ' ' + @tmpsummary
			ELSE SET @stagingsummary = @tmpsummary
		END

		IF @PerformanceStatus = 1
		BEGIN
			SET @tmpsummary = 'Performance Status' + 
							CASE @PerformanceStatusType 
								WHEN 1 THEN ' (normal activity)'
								WHEN 2 THEN ' (able to carry out light work)'
								WHEN 3 THEN ' (unable to carry out any work)'
								WHEN 4 THEN ' (limited self care)'
								WHEN 5 THEN ' (completely disabled)'
								ELSE ' (none)'
							END

			IF @stagingsummary IS NOT NULL SET @stagingsummary = @stagingsummary + ' ' + @tmpsummary
			ELSE SET @stagingsummary = @tmpsummary
		END

		IF LEN(@stagingsummary) > 0
		BEGIN
			SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + @stagingsummary
		END
	END

RETURN @RetVal
END
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 27/06/23
-- TFS#	2946
-- Description of change
-- Caecum identified by to show on report
------------------------------------------------------------------------------------------------------------------------
GO


EXEC dbo.DropIfExist @ObjectName = 'procedure_lower_extent_summary_update',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE procedure_lower_extent_summary_update
(
	@ProcedureId INT
)
AS
BEGIN
	
	DECLARE 
	@ExtentId INT,
	@AdditionalInfo VARCHAR(MAX),
	@EndoscopistId INT,
	@ConfirmedById INT,
	@ConfirmedByOther VARCHAR(200),
	@CaecumIdentifiedById INT,
	@LimitationId INT,
	@DifficultyEncounteredId INT,
	@DifficultyOther VARCHAR(200),
	@PR INT,
	@Retroflexion INT,
	@InsertionVia INT,
	@LimitationOther VARCHAR(MAX),
	@ProcedureAbandoned BIT, 
	@IntubationFailed BIT,
	@LoggedInUserId INT


	DECLARE @SectionId INT, @ProceureTypeId INT, @ExtentDescription VARCHAR(200), @IsSuccess BIT, @ScopeType VARCHAR(200), @SummaryText VARCHAR(MAX), @RetroflexionDone BIT, @PRDone BIT
	SELECT @SectionID = UISectionId FROM UI_Sections WHERE SectionName = 'Extent'

	SELECT @ProceureTypeId = ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureId
	--SELECT @ExtentDescription = LOWER(Description) FROM ERS_Extent WHERE UniqueId = @ExtentId

	/*Furthest extent*/
	SELECT TOP 1 @ExtentDescription = ee.Description, 
				 @EndoscopistId = epue.EndoscopistId, 
				 @DifficultyEncounteredId = epue.DifficultiesEncounteredId,
				 @LimitationId = epue.LimitationId,
				 @LimitationOther= epue.LimitationOther,
				 @Retroflexion = epue.RetroflectionPerformed,
				 @ExtentId = epue.ExtentId,
				 @ConfirmedById = epue.ConfirmedById,
				 @InsertionVia = epue.InsertionAccessViaId,
				 @IsSuccess = ee.IsSuccess,
				 @ProcedureAbandoned = epue.Abandoned,
				 @IntubationFailed = epue.IntubationFailed
								FROM dbo.ERS_ProcedureLowerExtent epue 
									INNER JOIN dbo.ERS_Extent ee ON epue.ExtentId = ee.UniqueId
								WHERE epue.ProcedureId=@ProcedureId
								ORDER BY ee.ListOrderBy
	


	/*PR Exam*/
	IF (SELECT COUNT(*) FROM ERS_ProcedureLowerExtent eple WHERE ProcedureId = @ProcedureId AND eple.RectalExamPerformed IS NOT NULL) > 0
	BEGIN
		/*Overall PR result regardless of who done it, was it done*/
		IF EXISTS (SELECT 1 FROM ERS_ProcedureLowerExtent WHERE ProcedureId = @ProcedureId AND ISNULL(RectalExamPerformed,0) = 1)
			SET @PRDone = 1
		ELSE
			SET @PRDone = 0
	END
	
	/*Retroflexion*/
	IF (SELECT COUNT(*) FROM ERS_ProcedureLowerExtent eple WHERE ProcedureId = @ProcedureId AND eple.RetroflectionPerformed IS NOT NULL) > 0
	BEGIN
		/*Overall PR result regardless of who done it, was it done*/
		IF EXISTS (SELECT 1 FROM ERS_ProcedureLowerExtent WHERE ProcedureId = @ProcedureId AND ISNULL(RetroflectionPerformed,0) = 1)
			SET @RetroflexionDone = 1
		ELSE
			SET @RetroflexionDone = 0
	END


	DECLARE @A varchar(5000), @B VARCHAR(5000), @Rectal varchar(500), @Retro varchar(500), @ProcType int

	SET @SummaryText = ''

	IF @ProceureTypeId = 4 
	BEGIN
		SET @ScopeType = 'sigmoidoscope'
	END
	ELSE 
	BEGIN 
		SET @ScopeType = 'colonoscope'
	END

	IF @PRDone IS NOT NULL 
	BEGIN
		IF @PR = 1 
		BEGIN
			SET @SummaryText = @SummaryText + 'A digital rectal examination was performed. '
		END
	END

	ELSE 
	BEGIN
		SET @SummaryText = @SummaryText + 'A digital rectal examination was not performed. '
	END

	DECLARE @InsertionSummaryText varchar(4000) = '', @ExtentSummaryText varchar(4000) = ''

	IF ISNULL(@InsertionVia,0) > 0 
	BEGIN
		SET @InsertionSummaryText = 'The ' + @ScopeType +  ' was inserted via ' + 
		(SELECT LOWER(CASE WHEN Description = 'anus' THEN 'the ' + Description ELSE Description END) FROM ERS_ExtentInsertionRoutes WHERE UniqueId = @InsertionVia)
	END
	
	IF ISNULL(@ExtentId,0) > 0 
	BEGIN
		SET @ExtentSummaryText = CASE WHEN @InsertionSummaryText = '' THEN 'The ' + @ScopeType +  ' was inserted ' ELSE '' END + ' to the ' + @ExtentDescription + ''
	END

	SET @SummaryText = @SummaryText + @InsertionSummaryText + @ExtentSummaryText
	
	IF @ProcedureAbandoned = 1
	BEGIN
		SET @SummaryText = @SummaryText + CASE WHEN @ExtentSummaryText <> '' OR @InsertionSummaryText <> '' THEN ' but the procedure was abandoned' ELSE ' The procedure was abandoned' END
	END
	
	IF @IntubationFailed = 1
	BEGIN
		SET @SummaryText = @SummaryText + ' intubation failed '
	END

	IF EXISTS (SELECT 1 FROM ERS_ProcedureCaecumIdentifiedBy WHERE ProcedureId = @ProcedureId)
	BEGIN
		--DECLARE @IdentifiedByConfidence varchar(max) = (SELECT [Description]
		--												FROM ERS_ProcedureCaecumIdentifiedBy epi 
		--													INNER JOIN ERS_ExtentConfirmedByList i on i.UniqueId = epi.ExtentIdentifiedById
		--												WHERE ProcedureId=@ProcedureId AND EndoscopistId = @EndoscopistId)
		
		DECLARE @IdentifiedByText varchar(max) = '. The caecum was identified by '

		SET @IdentifiedByText = @IdentifiedByText + LTRIM(STUFF((SELECT ', ' + CASE WHEN ISNULL(ChildId, 0) > 0 THEN (SELECT [Description] FROM ERS_ExtentConfirmedByList WHERE UniqueId = epi.ChildId) ELSE LOWER([Description]) END AS [text()] 
		FROM ERS_ProcedureCaecumIdentifiedBy epi 
			INNER JOIN ERS_ExtentConfirmedByList i on i.UniqueId = epi.ExtentIdentifiedById
		WHERE ProcedureId=@ProcedureId and EndoscopistId = @EndoscopistId and ISNULL(ChildId, 0) = 0
		ORDER BY ISNULL(i.ListOrderBy, 0)
		FOR XML PATH('')),1,1,''))

		SELECT @IdentifiedByText = dbo.fnAddFullStop(@IdentifiedByText)

		IF LEN(@IdentifiedByText) > 0
		BEGIN
			IF charindex(',', reverse(@IdentifiedByText)) > 0
				SET @SummaryText = @SummaryText + STUFF(@IdentifiedByText, len(@IdentifiedByText) - charindex(' ,', reverse(@IdentifiedByText)), 2, ' and ')
			ELSE
				SET @SummaryText = @SummaryText +  @IdentifiedByText
		END
	END

	IF ISNULL(@ConfirmedById, 0) > 0
	BEGIN
		SET @SummaryText = @SummaryText + ', insertion confirmed by ' + (SELECT LOWER(Description) FROM ERS_ExtentConfirmedByList WHERE UniqueId = @ConfirmedById)
	END
	
	IF ISNULL(@LimitationId, 0) > 0
	BEGIN
		SET @SummaryText = @SummaryText + CASE WHEN ISNULL(@ConfirmedById, 0) > 0 THEN ' and  ' ELSE ', ' END + 'insertion limited by ' + (SELECT LOWER(Description) FROM ERS_Limitations WHERE UniqueId = @LimitationId) + '.<br />'
	END

	IF ISNULL(@DifficultyEncounteredId, 0) > 0 
	BEGIN
		SET @SummaryText = @SummaryText + ' Difficulties encountered: ' + (SELECT LOWER(Description) FROM ERS_ExtentDifficultiesEncountered WHERE UniqueId = @DifficultyEncounteredId) + '.'
	END

	IF @RetroflexionDone = 1 SET @SummaryText = @SummaryText + ' The scope was retroflexed in the rectum.'

	
	UPDATE ERS_ProcedureLowerExtent
	SET Summary = @SummaryText
	WHERE ProcedureId = @ProcedureId

	EXEC procedure_summary_update @ProcedureId
	
	--remove complete section entry incase conditions no longer apply
	EXEC UI_update_procedure_summary @ProcedureId, 'Extent', 'Extent:', 0, @EndoscopistId
	
	--set extent id to whatever necessary only for completion purposes as no extent has reached 
	IF ISNULL(@ExtentId,0) = 0 AND (@ProcedureAbandoned = 1 OR @IntubationFailed = 1)
	BEGIN
		--set record in database??????
		IF @ProcedureAbandoned = 1
		BEGIN
			SELECT @ExtentId = UniqueId, @IsSuccess = IsSuccess
			FROM ERS_Extent
			WHERE NEDTerm = 'Abandoned'
		END
		ELSE IF @IntubationFailed = 1
		BEGIN
			SELECT @ExtentId = UniqueId, @IsSuccess = IsSuccess
			FROM ERS_Extent
			WHERE NEDTerm = 'Intubation failed'
		END
	END

	--if extent is > 0 and extent.issuccess = 1 or (limitation id > 0 and (limitation id <> other or (limitationid = other and other text filled in)))
	--If Sigmoid, check if the Extent has reached or exceeded the planned extent
	IF @ExtentId > 0 AND @ProceureTypeId = 4
	BEGIN
		DECLARE @ExtentListOrder int = (SELECT ListOrderBy FROM ERS_Extent WHERE UniqueId = @ExtentId)
		DECLARE @PlannedExtentListOrder int = (SELECT e.ListOrderBy FROM ERS_ProcedurePlannedExtent ppe JOIN ERS_Extent e ON e.UniqueId = ppe.ExtentId WHERE ppe.ProcedureId = @ProcedureId)

		IF (@ExtentListOrder <= @PlannedExtentListOrder AND @ExtentListOrder > 0)
				SET @IsSuccess = 1
			ELSE
				SET @IsSuccess = 0
	END

	IF @ExtentId > 0 AND @IsSuccess = 1
		EXEC UI_update_procedure_summary @ProcedureId, 'Extent', 'Extent:', @ExtentId, @EndoscopistId
	ELSE IF @IsSuccess = 0 AND @LimitationId > 1
	BEGIN
		IF (SELECT LOWER(NEDTerm) FROM dbo.ERS_Limitations WHERE UniqueId = @LimitationId) = 'other'
		BEGIN
			SELECT @LimitationOther = Description FROM dbo.ERS_Limitations WHERE UniqueId = @LimitationId AND LOWER(Description) <> 'other' -- meaning they've entered their own description
			IF ISNULL(@LimitationOther,'') <> ''
			BEGIN
				EXEC UI_update_procedure_summary @ProcedureId, 'Extent', 'Extent:' , @ExtentId, @EndoscopistId
			END
		END
		ELSE
		BEGIN
			EXEC UI_update_procedure_summary @ProcedureId, 'Extent', 'Extent:', @ExtentId, @EndoscopistId
		END
	END

	--retroflexion
	IF @Retroflexion > -1
	BEGIN
		EXEC UI_update_procedure_summary @ProcedureId, 'Retroflexion', 'Retroflexion:', 1, @EndoscopistId
	END
	ELSE
	BEGIN
		EXEC UI_update_procedure_summary @ProcedureId, 'Retroflexion', 'Retroflexion:', 0, @EndoscopistId
	END




END
GO


ALTER PROCEDURE [dbo].[procedure_caecum_identifiedby_save]
(
	@IdentifiedById int,
	@ChildId INT,
	@ProcedureId INT,
	@EndoscopistId INT,
	@Selected BIT
)
AS
BEGIN
	IF @Selected = 1
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureCaecumIdentifiedBy WHERE ExtentIdentifiedById = @IdentifiedById AND ProcedureId = @ProcedureId AND @EndoscopistId = EndoscopistId)
		BEGIN
			INSERT INTO ERS_ProcedureCaecumIdentifiedBy (ExtentIdentifiedById, ProcedureId, EndoscopistId)
			VALUES (@IdentifiedById, @ProcedureId, @EndoscopistId)
		END
		ELSE
		BEGIN
			UPDATE ERS_ProcedureCaecumIdentifiedBy
			SET ChildId = @ChildId
			WHERE ProcedureId = @ProcedureId AND ExtentIdentifiedById = @IdentifiedById AND EndoscopistId = @EndoscopistId
		END	
	END
	ELSE
	BEGIN
		DELETE FROM ERS_ProcedureCaecumIdentifiedBy WHERE ProcedureId = @ProcedureId AND ExtentIdentifiedById = @IdentifiedById AND EndoscopistId = @EndoscopistId
	END
    
    EXEC procedure_lower_extent_summary_update @ProcedureId


END
GO




ALTER PROCEDURE [dbo].[procedure_lower_extent_save]
(
	@ProcedureId int,
	@ExtentId int,
	@AdditionalInfo varchar(max),
	@EndoscopistId int,
	@ConfirmedById int,
	@ConfirmedByOther varchar(200),
	@CaecumIdentifiedById int,
	@LimitationId int,
	@DifficultyEncounteredId int,
	@DifficultyOther varchar(200),
	@PR int,
	@Retroflexion int,
	@InsertionVia int,
	@LimitationOther varchar(max),
	@ProcedureAbandoned bit, 
	@IntubationFailed bit,
	@LoggedInUserId INT
)
AS
BEGIN TRANSACTION

BEGIN TRY
	/*Check if new values been for confirmed by*/
	IF ISNULL(@ConfirmedByOther,'') <> ''
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM dbo.ERS_ExtentConfirmedByList WHERE Description = @ConfirmedByOther)
		BEGIN
			/*get and set the new items order id so it appears 1 above 'other' we always want other to be last*/

			DECLARE @OtherListOrderBy int = (SELECT ListOrderBy FROM ERS_ExtentConfirmedByList WHERE Description = 'Other')
			INSERT INTO ERS_ExtentConfirmedByList (Description, NEDTerm, ListOrderBy, LimitationReason) VALUES (@ConfirmedByOther, 'Other', @OtherListOrderBy, 1)
			
			UPDATE dbo.ERS_ExtentConfirmedByList SET ListOrderBy = @OtherListOrderBy + 1 WHERE Description = 'Other'
		END

		SELECT @ConfirmedById = UniqueId FROM ERS_ExtentConfirmedByList WHERE Description = @ConfirmedByOther
	END

	/*Check if new values been added for limitations */
	IF ISNULL(@LimitationOther,'') <> ''
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM dbo.ERS_Limitations WHERE Description = @LimitationOther)
		BEGIN
			/*get and set the new items order id so it appears 1 above 'other' we always want other to be last*/

			DECLARE @OtherListOrderBy_l int = (SELECT ListOrderBy FROM ERS_Limitations WHERE Description = 'Other')
			INSERT INTO ERS_Limitations (Description, NEDTerm, ListOrderBy) VALUES (@LimitationOther, 'Other', @OtherListOrderBy_l)
			
			UPDATE dbo.ERS_Limitations SET ListOrderBy = @OtherListOrderBy_l + 1 WHERE Description = 'Other'
		

		SELECT @LimitationId = UniqueId FROM ERS_Limitations WHERE Description = @LimitationOther
		
		DECLARE @ProcTypeId int = (SELECT ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
		INSERT INTO ERS_LimitationProcedureTypes (ProcedureTypeId, LimitationId) VALUES (@ProcTypeId, @LimitationId)
		END
		ELSE
			SELECT @LimitationId = UniqueId FROM ERS_Limitations WHERE Description = @LimitationOther
	END 

	/*Check if new values been added for limitations */
	IF ISNULL(@DifficultyOther,'') <> ''
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM dbo.ERS_ExtentDifficultiesEncountered WHERE Description = @DifficultyOther)
		BEGIN
			/*get and set the new items order id so it appears 1 above 'other' we always want other to be last*/

			DECLARE @OtherListOrderBy_d int = (SELECT ListOrderBy FROM ERS_ExtentDifficultiesEncountered WHERE Description = 'Other')
			INSERT INTO ERS_ExtentDifficultiesEncountered (Description, NEDTerm, ListOrderBy) VALUES (@DifficultyOther, 'Other', @OtherListOrderBy_d)
			
			UPDATE dbo.ERS_ExtentDifficultiesEncountered SET ListOrderBy = @OtherListOrderBy_d + 1 WHERE Description = 'Other'
			

			SELECT @DifficultyEncounteredId = UniqueId FROM ERS_ExtentDifficultiesEncountered WHERE Description = @DifficultyOther
		END
		ELSE
		BEGIN
			SELECT @DifficultyEncounteredId = UniqueId FROM ERS_ExtentDifficultiesEncountered WHERE Description = @DifficultyOther
		END

	END

	IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureLowerExtent WHERE ProcedureId = @ProcedureId AND EndoscopistId = @EndoscopistId)
	BEGIN
		INSERT INTO ERS_ProcedureLowerExtent (ProcedureId, ExtentId, AdditionalInfo, EndoscopistId, ConfirmedById, CaecumIdentifiedById, LimitationId, LimitationOther,
											  DifficultiesEncounteredId,RectalExamPerformed, RetroflectionPerformed, InsertionAccessViaId, Abandoned, IntubationFailed,
											  WhoUpdatedId, WhenUpdated)
		VALUES (@ProcedureId, NULLIF(@ExtentId, 0), @AdditionalInfo, @EndoscopistId, NULLIF(@ConfirmedById,0), NULLIF(@CaecumIdentifiedById,0), NULLIF(@LimitationId,0), @LimitationOther,
				NULLIF(@DifficultyEncounteredId,0), NULLIF(@PR, -1), NULLIF(@Retroflexion, -1), NULLIF(@InsertionVia,0), ISNULL(@ProcedureAbandoned,CONVERT(bit,0)), ISNULL(@IntubationFailed,CONVERT(bit,0)), @LoggedInUserId, getdate())
	END
	ELSE
	BEGIN
		UPDATE ERS_ProcedureLowerExtent
		SET 
			ExtentId = NULLIF(@ExtentId,0),
			AdditionalInfo = @AdditionalInfo,
			EndoscopistId = @EndoscopistId,
			ConfirmedById = NULLIF(@ConfirmedById,0),
			CaecumIdentifiedById = NULLIF(@CaecumIdentifiedById,0),
			LimitationId = NULLIF(@LimitationId,0),
			LimitationOther = @LimitationOther,
			DifficultiesEncounteredId = NULLIF(@DifficultyEncounteredId,0),
			RectalExamPerformed = NULLIF(@PR, -1),
			RetroflectionPerformed = NULLIF(@Retroflexion, -1),
			InsertionAccessViaId = NULLIF(@InsertionVia,0),
			Abandoned = ISNULL(@ProcedureAbandoned,CONVERT(bit,0)),
			IntubationFailed = ISNULL(@IntubationFailed,CONVERT(bit,0)),
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = getdate()
		WHERE 
			ProcedureId = @ProcedureId AND
			EndoscopistId = @EndoscopistId
	END

	EXEC procedure_lower_extent_summary_update @ProcedureId

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





------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO


------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 04.07.23
-- TFS#	
-- Description of change
-- 
------------------------------------------------------------------------------------------------------------------------
GO


PRINT N'Altering [dbo].[sch_get_diary_details]...';


GO

ALTER PROCEDURE [dbo].[sch_get_diary_details]
(
	@DiaryId int
)
AS

	SELECT DISTINCT
		d.DiaryId,
		d.DiaryStart, 
		d.[DiaryEnd],
		d.[UserID], 
		d.ListConsultantId,
		d.[RoomID], 
		d.ListRulesId, 
		d.Training,
		d.Subject,
		d.UserId EndoscopistId,
		d.ListConsultantId,
		(CASE WHEN  ISNULL(u.Title,'') <> '' THEN u.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Forename,'') <> '' THEN u.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Surname,'') <> '' THEN u.Surname + ' ' ELSE '' END) as EndoscopistName,
	  (CASE WHEN  ISNULL(c.Title,'') <> '' THEN c.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(c.Forename,'') <> '' THEN c.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(c.Surname,'') <> '' THEN c.Surname + ' ' ELSE '' END) as ListConsultant,
	  ls.TotalMinutes,
	  ls.TotalPoints,
	  ls.OverBookedPoints,
	  ISNULL(d.Notes,'') Notes,
	  d.ListGenderId,
	  ISNULL(g.Title,'') ListGender,
	  IsGI,
	  d.Locked,
	  CASE WHEN (SELECT count(a.AppointmentId) FROM ERS_Appointments a LEFT JOIN dbo.ERS_AppointmentStatus s ON s.UniqueId = a.AppointmentStatusId WHERE DiaryId = @DiaryId AND ISNULL(s.HDCKEY,'') <> 'C') > 0 THEN convert(bit,1) ELSE convert(bit,0) END Appointments,
	  ISNULL((SELECT sum(pt.points) FROM ERS_AppointmentProcedureTypes pt INNER JOIN ERS_Appointments a ON a.AppointmentId = pt.AppointmentID LEFT JOIN dbo.ERS_AppointmentStatus s ON s.UniqueId = a.AppointmentStatusId WHERE DiaryId = @DiaryId AND ISNULL(s.HDCKEY,'') <> 'C'),0) AppointmentPoints,
	  CASE WHEN (SELECT count(a.AppointmentId) FROM ERS_Appointments a LEFT JOIN dbo.ERS_AppointmentStatus s ON s.UniqueId = a.AppointmentStatusId WHERE DiaryId = @DiaryId AND ISNULL(s.HDCKEY,'') = 'C') > 0 THEN convert(bit,1) ELSE convert(bit,0) END CancelledAppointments,
	  CASE WHEN ISNULL(RecurrenceParentID, 0) > 0 THEN convert(bit,1) ELSE convert(bit,0) END Recurring,
	  CASE WHEN ISNULL(RecurrenceParentID, 0) > 0 THEN 
		CASE RecurrenceFrequency WHEN 'd' THEN 'daily for ' + convert(varchar(10), RecurrenceCount) + ' day(s)'
							     WHEN 'w' THEN 'weekly for ' + convert(varchar(10), RecurrenceCount) + ' week(s)' 
								 when 'm' THEN 'montly for ' + convert(varchar(10), RecurrenceCount) + ' month(s)' 
		END 
	  END RecurrancePattern
	FROM ERS_SCH_DiaryPages d
		INNER JOIN ERS_Users u ON u.UserID = d.UserId
		LEFT JOIN ERS_Users c ON c.UserID = d.ListConsultantId
		INNER JOIN (SELECT ls.ListRulesId, (SUM(Points) - SUM(CONVERT(INT, IsOverBookedSlot))) TotalPoints, SUM(CONVERT(INT, IsOverBookedSlot)) OverBookedPoints, SUM(SlotMinutes) TotalMinutes FROM ERS_SCH_ListSlots ls WHERE ls.Active = 1 GROUP BY ListRulesId) ls ON ls.ListRulesId = d.ListRulesId
		LEFT JOIN ERS_GenderTypes g on g.GenderId = d.ListGenderId
	WHERE d.DiaryId = @DiaryId
GO
PRINT N'Altering [dbo].[sch_update_appointment_status]...';


GO

ALTER PROCEDURE sch_update_appointment_status
(
	@AppointmentId INT,
	@HDCStatusKey VARCHAR(5),
	@LoggedInUserId int
)
AS
BEGIN
	
	UPDATE ERS_Appointments 
	SET AppointmentStatusId = (SELECT UniqueId FROM dbo.ERS_AppointmentStatus WHERE HDCKEY = @HDCStatusKey), 
		WhoUpdatedId = @LoggedInUserId, 
		WhenUpdated = GETDATE()
	WHERE AppointmentId = @AppointmentId
END
GO
PRINT N'Altering [dbo].[sites_summary_update]...';


GO
PRINT N'Altering [dbo].[TR_CommonAbnoLesions]...';


GO

ALTER TRIGGER [dbo].[TR_CommonAbnoLesions]
ON [dbo].[ERS_CommonAbnoLesions]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @Polyp VARCHAR(10) = 'False', 
						  @BenignTumour VARCHAR(10) = 'False', 
						  @MalignantTumour VARCHAR(10) = 'False', 
						  @SubmucosalTumour VARCHAR(10) = 'False', 
						  @FocalLesions VARCHAR(10) = 'False',
						  @SubmucoaslLesion VARCHAR(10) = 'False',
						  @FundicGlandPolyp VARCHAR(10) = 'False',
			@PolypTypeId int, @Region varchar(20), @ProcedureTypeId int, @MatrixCode varchar(50)
	
	IF EXISTS(SELECT * FROM INSERTED)
	BEGIN
		SELECT @site_id=SiteId,
				@Polyp = (CASE WHEN (ISNULL(Polyp,0) = 1) THEN 'True' ELSE 'False' END),
				@FocalLesions = (CASE WHEN (ISNULL(Focal,0) = 1) THEN 'True' ELSE 'False' END),
				@SubmucoaslLesion = (CASE WHEN (ISNULL(Submucosal,0) = 1) THEN 'True' ELSE 'False' END),
				@FundicGlandPolyp = (CASE WHEN (ISNULL(FundicGlandPolyp,0) = 1) THEN 'True' ELSE 'False' END),
				@PolypTypeId = PolypTypeId
				
		FROM INSERTED

		SELECT TOP 1 @ProcedureTypeId =  p.ProcedureType FROM ERS_Sites s INNER JOIN ERS_Procedures p ON p.ProcedureId = s.ProcedureId WHERE s.SiteId = @site_id
		--check if polyps = 1
		IF @Polyp = 'True' 
		BEGIN
			--check for polyp type
			DECLARE @PolypType VARCHAR(200) = (SELECT Description FROM ERS_PolypTypes WHERE UniqueId = @PolypTypeId)

			IF LOWER(@PolypType) = 'sessile'
			BEGIN
				--sessile polyps to produce a gastric tumour outcome depending on the tumour type
				IF EXISTS (SELECT 1 FROM ERS_CommonAbnoPolypDetails WHERE SiteId = @site_id AND Type = (SELECT UniqueId FROM ERS_TumourTypes WHERE Description = 'benign'))
					SET @BenignTumour = 'True'
				ELSE 
					SET @BenignTumour = 'False'

				IF EXISTS (SELECT 1 FROM ERS_CommonAbnoPolypDetails WHERE SiteId = @site_id AND Type = (SELECT UniqueId FROM ERS_TumourTypes WHERE Description = 'malignant'))
					SET @MalignantTumour = 'True'
				ELSE
					SET @MalignantTumour = 'False'
			END
			
			IF LOWER(@PolypType) = 'submucosal'  AND LOWER(@Region) = 'stomach'
				SET @SubmucoaslLesion = 'True'
			ELSE
				SET @SubmucoaslLesion = 'False'

		END
		
		IF @ProcedureTypeId IN (1,6,8)
		BEGIN
			SELECT @Region = dbo.fnSiteRegion(@site_id)

			IF LOWER(@Region) = 'stomach'
			BEGIN
				--SELECT @Polyp = CASE WHEN @FundicGlandPolyp = 'False' AND @BenignTumour = 'False' AND @MalignantTumour = 'False' AND @SubmucosalTumour = 'False' THEN 'True' ELSE 'False' END
				SET @MatrixCode = 'D40P1'
			END
			ELSE IF LOWER(@Region) = 'oesophagus'
				SET @MatrixCode = 'N2013'
			ELSE IF LOWER(@Region) = 'duodenum'
				SET @MatrixCode = 'D58P1'
			ELSE IF LOWER(@Region) = 'colon'
				SET @MatrixCode = 'D58P1'
				
		END
		ELSE IF @ProcedureTypeId IN (3,4,9)
		BEGIN
			SELECT @Region = dbo.fnSiteRegion(@site_id)

			IF @Polyp = 'True' AND @Region IN ('Rectum', 'Anal Margin')
				SET @MatrixCode = 'D4P3'

			IF @Polyp = 'True' AND @Region NOT IN ('Rectum', 'Anal Margin')
				SET @MatrixCode = 'D12P3'
		END

	END
	ELSE
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC abnormalities_common_lesions_summary_update @site_id

	IF @site_id IS NOT NULL AND @ProcedureTypeId IN (1,3,4,6,8,9)
	BEGIN
		EXEC sites_summary_update @site_id

		EXEC diagnoses_control_save @site_id, @MatrixCode, @Polyp		
		--EXEC diagnoses_control_save @site_id, 'D86P1', @BenignTumour	
		--EXEC diagnoses_control_save @site_id, 'D87P1', @MalignantTumour	
		EXEC diagnoses_control_save @site_id, 'N2001', @FocalLesions
		EXEC diagnoses_control_save @site_id, 'D88P1', @SubmucosalTumour
		EXEC diagnoses_control_save @site_id, 'N2002', @SubmucoaslLesion
		EXEC diagnoses_control_save @site_id, 'N2019', @FundicGlandPolyp

	END
GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------

GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Steve 28/06/23
-- TFS#	2741
-- Description of change
-- Bronchs - the Staging section is missing on the report
--   Staging data was only being shown if "Suspected Lung Cancer" option was selected in indications
--   Change : now shows staging on the report when selected regardless of the "Suspected Lung Cancer" selection
-- EBUS - Drugs, sedation/anaesthetic, local anaesthetic - lidocaine/lignocaine and oxygen sections not showing in report summary or report
--   These details were only being added to ERS_ProceduresReporting for bronchoscopy procedures
--   Change : Details now also added for EBUS procedures on both summary and printed report
------------------------------------------------------------------------------------------------------------------------
GO
PRINT N'Begining Updates for TFS# 2741';

GO
PRINT N'  Altering [dbo].[ProcedureIndicationsSummary]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'ProcedureIndicationsSummary',      -- varchar(100)
                     @ObjectTypePrefix = 'F' -- varchar(5)

GO
/****** Object:  UserDefinedFunction [dbo].[ProcedureIndicationsSummary]    Script Date: 24/05/2023 09:31:49 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[ProcedureIndicationsSummary]
(
	@ProcedureId int
)
RETURNS varchar(max)
AS
BEGIN
/****************************************************
DS Fix bug 2754 12/04/2023
*****************************************************/
DECLARE @IndicationsString  varchar(max), @ComorbidityString varchar(max), @DamagingDrugsString varchar(max), @PatientAllergiesString varchar(max), @PreviousSurgeryString varchar(max), 
		@PreviousDiseasesString varchar(max), @FamilyDiseaseHistoryString varchar(max), @ImagingString varchar(max), @ImagingOutcomeString varchar(max),
		@RetVal varchar(max)

SELECT @IndicationsString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN i.AdditionalInfo = 0 THEN [Description] ELSE AdditionalInformation END + CASE WHEN ISNULL(ChildIndicationId, 0) > 0 THEN '-' + (SELECT [Description] FROM ERS_Indications WHERE UniqueId = epi.ChildIndicationId) ELSE '' END AS [text()] 
	FROM ERS_ProcedureIndications epi 
	INNER JOIN ERS_Indications i on i.UniqueId = epi.IndicationId
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(i.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--rockall and baltchford scoring
SELECT @IndicationsString	= @IndicationsString + CASE WHEN CHARINDEX('melaena', @IndicationsString) > -1 OR CHARINDEX('haematemesis', @IndicationsString) > -1 THEN ' ' + dbo.fnBlatchfordRockallScores(@ProcedureId) ELSE '' END
--SELECT @IndicationsString = dbo.fnCapitalise(dbo.fnAddFullStop(@IndicationsString)) 

IF LEN(@IndicationsString) > 0
BEGIN
	IF charindex(',', reverse(@IndicationsString)) > 0
		SELECT @RetVal = STUFF(@IndicationsString, len(@IndicationsString) - (charindex(' ,', reverse(@IndicationsString)) - 1), 2, ' and ')
	ELSE
		SELECT @RetVal = @IndicationsString
END
-------------------CoMorbidity


SELECT @ComorbidityString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN AdditionalInformation = '' THEN [Description] ELSE AdditionalInformation END + CASE WHEN ISNULL(ChildComorbidityId, 0) > 0 THEN '-' + (SELECT [Description] FROM ERS_CoMorbidity WHERE UniqueId = ChildComorbidityId) ELSE '' END AS [text()] 
	FROM ERS_ProcedureComorbidity epc 
	INNER JOIN ERS_Comorbidity c on c.uniqueid = CoMorbidityId
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(c.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @ComorbidityString = dbo.fnCapitalise(dbo.fnAddFullStop(@ComorbidityString)) 

IF LEN(@ComorbidityString) > 0 
BEGIN
	IF charindex(',', reverse(@ComorbidityString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Co-morbidity: ' + STUFF(@ComorbidityString, len(@ComorbidityString) - charindex(' ,', reverse(@ComorbidityString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Co-morbidity: ' + @ComorbidityString
END

-------------------Damaging drugs

SELECT @DamagingDrugsString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ProcedureDamagingDrugs edd 
	INNER JOIN ERS_PotentialDamagingDrugs d on d.uniqueid = edd.DamagingDrugId
	WHERE edd.ProcedureId=@ProcedureId
	ORDER BY ISNULL(d.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @DamagingDrugsString = dbo.fnCapitalise(dbo.fnAddFullStop(@DamagingDrugsString)) 

DECLARE @AntiCoagDrugs bit = (SELECT AntiCoagDrugs FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
IF @AntiCoagDrugs IS NOT NULL
	If @AntiCoagDrugs = 1 SET @DamagingDrugsString = @DamagingDrugsString + '<br />The patient is taking anti-coagulant or anti-platelet medication.'

IF LEN(@DamagingDrugsString) > 0
BEGIN
	IF charindex(',', reverse(@DamagingDrugsString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Potential damaging drug(s): ' + STUFF(@DamagingDrugsString, len(@DamagingDrugsString) - charindex(' ,', reverse(@DamagingDrugsString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Potential damaging drug(s): ' + @DamagingDrugsString
END
-------------------Allergies

SELECT @PatientAllergiesString =
	CASE AllergyResult 
		WHEN -1 THEN 'unknown'
		WHEN 0 THEN 'none'
		WHEN 1 THEN a.AllergyDescription 
	END
	FROM ERS_PatientAllergies a
		INNER JOIN ERS_Procedures p ON p.PatientId = a.PatientId
	WHERE p.ProcedureId = @ProcedureId

--SELECT @PatientAllergiesString = dbo.fnCapitalise(dbo.fnAddFullStop(@PatientAllergiesString)) 

IF LEN(@PatientAllergiesString) > 0
BEGIN
	IF charindex(',', reverse(@PatientAllergiesString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Allergies: ' + STUFF(@PatientAllergiesString, len(@PatientAllergiesString) - charindex(' ,', reverse(@PatientAllergiesString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Allergies: ' + @PatientAllergiesString
END
-------------------Previous surgery

SELECT @PreviousSurgeryString =
	LTRIM(STUFF((SELECT DISTINCT ', ' + [Description] + CASE WHEN ListItemText = 'Unknown' THEN '' ELSE ' ' + ListItemText END as [text()] 
	FROM ERS_PatientPreviousSurgery h
	INNER JOIN ERS_PreviousSurgery r on r.UniqueID = h.PreviousSurgeryID
	INNER JOIN ERS_Lists l on l.ListItemNo = h.PreviousSurgeryPeriod and ListDescription = 'Follow up disease Period'
	INNER JOIN ERS_Procedures p on p.patientId = h.patientId 
	WHERE p.ProcedureId = @ProcedureId
	--ORDER BY ISNULL(r.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @PreviousSurgeryString = dbo.fnCapitalise(dbo.fnAddFullStop(@PreviousSurgeryString)) 

IF LEN(@PreviousSurgeryString) > 0
BEGIN
	IF charindex(',', reverse(@PreviousSurgeryString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous surgery: ' + STUFF(@PreviousSurgeryString, len(@PreviousSurgeryString) - charindex(' ,', reverse(@PreviousSurgeryString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous surgery: ' + @PreviousSurgeryString
END

-------------------ASA Status
DECLARE @ASAStatusString varchar(max) = 
	(SELECT [description]
	FROM ERS_PatientASAStatus pa 
		INNER JOIN ERS_ASAStatus a on a.uniqueid = pa.asastatusid
		INNER JOIN ERS_Procedures p ON p.ProcedureId = pa.ProcedureCreatedId
	WHERE   pa.ProcedureCreatedId = @ProcedureId)

If (@ASAStatusString is null) 
BEGIN
	SELECT TOP 1 @ASAStatusString = [description] 
						   FROM ERS_PatientASAStatus 
						   INNER JOIN ERS_ASAStatus ON UniqueId = ASAStatusId 
						   WHERE PatientId = (SELECT PatientId FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
						   ORDER BY ProcedureCreatedId DESC
END


IF LEN(@ASAStatusString) > 0 
BEGIN
	SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'ASA Status: ' + @ASAStatusString
END
-------------------Previous diseases

SELECT @PreviousDiseasesString =
	LTRIM(STUFF((SELECT DISTINCT ', ' + [Description] as [text()] 
	FROM ERS_PatientPreviousDiseases pd
	INNER JOIN ERS_PreviousDiseases d on d.UniqueID = pd.PreviousDiseaseID
	INNER JOIN ERS_Procedures p on p.patientId = pd.patientId 
	WHERE p.ProcedureId = @ProcedureId
	--ORDER BY ISNULL(r.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @PreviousDiseasesString = dbo.fnCapitalise(dbo.fnAddFullStop(@PreviousDiseasesString)) 

IF LEN(@PreviousDiseasesString) > 0
BEGIN
	IF charindex(',', reverse(@PreviousDiseasesString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous diseases: ' + STUFF(@PreviousDiseasesString, len(@PreviousDiseasesString) - charindex(' ,', reverse(@PreviousDiseasesString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous diseases: ' + @PreviousDiseasesString
END

-------------------Family disease history

SELECT @FamilyDiseaseHistoryString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN AdditionalInformation = '' THEN [Description] ELSE AdditionalInformation END AS [text()] 
	FROM ERS_PatientFamilyDiseaseHistory epi 
	INNER JOIN ERS_FamilyDiseaseHistory i on i.UniqueId = epi.FamilyDiseaseHistoryId
	INNER JOIN ERS_Procedures p on p.patientId = epi.patientId 
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(i.ListOrderBy, 999)
	FOR XML PATH('')),1,1,''))

--SELECT @FamilyDiseaseHistoryString = dbo.fnCapitalise(dbo.fnAddFullStop(@FamilyDiseaseHistoryString)) 

IF LEN(@FamilyDiseaseHistoryString) > 0
BEGIN
	IF charindex(',', reverse(@FamilyDiseaseHistoryString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Family history: ' + STUFF(@FamilyDiseaseHistoryString, len(@FamilyDiseaseHistoryString) - charindex(' ,', reverse(@FamilyDiseaseHistoryString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Family history: ' + @FamilyDiseaseHistoryString
END


-------------------Imaging

SELECT @ImagingString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ImagingMethods im 
	INNER JOIN ERS_ProcedureImagingMethod pim on im.uniqueid = pim.ImagingMethodId
	WHERE pim.ProcedureId=@ProcedureId
	FOR XML PATH('')),1,1,''))


IF LEN(@ImagingString) > 0
BEGIN
	IF charindex(',', reverse(@ImagingString)) > 0
		SELECT @ImagingString = STUFF(@ImagingString, len(@ImagingString) - charindex(' ,', reverse(@ImagingString)), 2, ' and ')
END


SELECT @ImagingOutcomeString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ImagingOutcomes imo 
	INNER JOIN ERS_ProcedureImagingOutcome pio on imo.uniqueid = pio.ImagingOutcomeId
	WHERE pio.ProcedureId=@ProcedureId
	FOR XML PATH('')),1,1,''))

IF ISNULL(@ImagingOutcomeString,'') <> ''
BEGIN
	SELECT @ImagingString = CASE WHEN ISNULL(@ImagingString, '') <> '' THEN @ImagingString + ' revealed ' ELSE '' END  + @ImagingOutcomeString
END


--SELECT @ImagingString = dbo.fnCapitalise(dbo.fnAddFullStop(@ImagingString)) 

IF LEN(@ImagingString) > 0
BEGIN
	IF charindex(',', reverse(@ImagingString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Imaging: ' + STUFF(@ImagingString, len(@ImagingString) - charindex(' ,', reverse(@ImagingString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Imaging: ' + @ImagingString
END


DECLARE @SmokingString varchar(max)


SELECT @SmokingString=
	LTRIM(STUFF((SELECT '  ' +SmokingDescription   AS [text()] 
	FROM ERS_ProcedureSmoking epi 
	WHERE ProcedureId=@ProcedureId
	FOR XML PATH('')),1,1,''))

--SELECT @SmokingString = dbo.fnCapitalise(dbo.fnAddFullStop(@SmokingString)) 

IF LEN(@SmokingString) > 0
BEGIN
	IF charindex(',', reverse(@SmokingString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Smoking:</b> ' + @SmokingString
		--SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Smoking:</b> ' + STUFF(@SmokingString, len(@SmokingString) - charindex(' ,', reverse(@SmokingString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Smoking:</b> ' + @SmokingString
END

DECLARE @LUTSIPSSString varchar(max)
DECLARE @LUTSIPSSTotalScoreString varchar(max)

SELECT @LUTSIPSSString=
	LTRIM(STUFF((SELECT ', ' + SectionName+'(Score:'+cast(ls.ScoreValue as varchar(10)) +')'   AS [text()] 
	from  ERS_ProcedureLUTSIPSSSymptoms a ,ERS_LUTSIPSSSymptoms b,ERS_LUTSIPSSSymptomSections s,ERS_IPSSScore ls
	where ProcedureId=@ProcedureId and a.LUTSIPSSSymptomId=b.UniqueId and b.LUTSIPSSSymptomSectionId=s.LUTSIPSSSymptomSectionId and SelectedScoreId>1 and a.SelectedScoreId=ls.ScoreId
	FOR XML PATH('')),1,1,''))

--SELECT @LUTSIPSSString = dbo.fnCapitalise(dbo.fnAddFullStop(@LUTSIPSSString)) 

select top 1  @LUTSIPSSTotalScoreString =  'Total Score :' + cast(TotalScoreValue as varchar(10)) 
from  ERS_ProcedureLUTSIPSSSymptoms where ProcedureId=@ProcedureId
IF LEN(@LUTSIPSSString) > 0
BEGIN
	IF charindex(',', reverse(@LUTSIPSSString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>LUTS\IPSS symptom score:</b>' + STUFF(@LUTSIPSSString, len(@LUTSIPSSString) - charindex(' ,', reverse(@LUTSIPSSString)), 2,  ' ' + @LUTSIPSSTotalScoreString + ' '+'<br />')
	     
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>LUTS\IPSS symptom score:</b> ' + @LUTSIPSSString

	--SELECT @RetVal = ISNULL(@RetVal + '<br />', '') +  @LUTSIPSSTotalScoreString
END

DECLARE @PreviousDiseaseUrologyString varchar(max)

SELECT @PreviousDiseaseUrologyString=
	LTRIM(STUFF((SELECT ', ' +case 
       when a.Description='Other' then b.AdditionalInformation
	   else a.Description
	  end
   AS [text()] 
	from ERS_PreviousDiseasesUrology a, ERS_ProcedurePreviousDiseasesUrology b 
	where a.UniqueId=b.PreviousDiseaseId
	and b.ProcedureId=@ProcedureId
	order by PreviousDiseaseSectionId
	FOR XML PATH('')),1,1,''))

--SELECT @PreviousDiseaseUrologyString = dbo.fnCapitalise(dbo.fnAddFullStop(@PreviousDiseaseUrologyString)) 


IF LEN(@PreviousDiseaseUrologyString) > 0
BEGIN
	IF charindex(',', reverse(@PreviousDiseaseUrologyString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Past Urological Histrory:</b>' + STUFF(@PreviousDiseaseUrologyString, len(@PreviousDiseaseUrologyString) - charindex(' ,', reverse(@PreviousDiseaseUrologyString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Past Urological Histrory:</b> ' + @PreviousDiseaseUrologyString

	
END

DECLARE @UrineDipstickCytologyString varchar(max)

SELECT @UrineDipstickCytologyString=
	LTRIM(STUFF((SELECT ', ' + b.Description + ' '+c.Description 
   AS [text()] 
	from ERS_ProcedureUrineDipstickCytology a,ERS_UrineDipstickCytology b,ERS_UrineDipstickCytology c
	where a.ProcedureId=@ProcedureId
	and a.UrineDipstickCytologyId=b.UniqueId
	and a.ChildUrineDipstickCytologyId=c.UniqueId
	order by b.UrineDipstickCytologySectionId,b.ListOrderBy
	FOR XML PATH('')),1,1,''))

--SELECT @UrineDipstickCytologyString = dbo.fnCapitalise(dbo.fnAddFullStop(@UrineDipstickCytologyString)) 


IF LEN(@UrineDipstickCytologyString) > 0
BEGIN
	IF charindex(',', reverse(@UrineDipstickCytologyString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Urine Dipstick And Cytology:</b>' + STUFF(@UrineDipstickCytologyString, len(@UrineDipstickCytologyString) - charindex(' ,', reverse(@UrineDipstickCytologyString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Urine Dipstick And Cytology:</b>' + @UrineDipstickCytologyString

	
END


--------------Broncs referral data
DECLARE @BroncoReferralDataString varchar(max), @DateBronchRequested DATETIME,
		@DateOfReferral DATETIME,
		@LCaSuspectedBySpecialist BIT,
		@CTScanAvailable BIT,
		@DateOfScan DATETIME

	SELECT @DateBronchRequested=DateBronchRequested,
		   @DateOfReferral=DateOfReferral,
		   @LCaSuspectedBySpecialist=LCaSuspectedBySpecialist,
		   @CTScanAvailable=CTScanAvailable,
		   @DateOfScan=DateOfScan
	FROM ERS_ProcedureBronchoReferralData
	WHERE ProcedureId = @ProcedureId

	IF @DateBronchRequested IS NOT NULL SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Date bronchoscopy requested ' + CONVERT(VARCHAR, @DateBronchRequested, 105) + '. '
	IF @DateOfReferral IS NOT NULL SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Date of referral ' + CONVERT(VARCHAR, @DateOfReferral, 105) + '. '
	IF @LCaSuspectedBySpecialist = 1 SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Lung Ca suspected by lung Ca specialist' + '. '
	IF @CTScanAvailable = 1 SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'CT scan available prior to bronchoscopy' + '. '
	IF @DateOfScan IS NOT NULL SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Date of scan ' + CONVERT(VARCHAR, @DateOfScan, 105) + '. '
	

	IF @BroncoReferralDataString IS NOT NULL SET @BroncoReferralDataString = 'Referal Data (' + RTRIM(@BroncoReferralDataString )+ ')'
	ELSE SET @BroncoReferralDataString = ''
	
	IF LEN(@BroncoReferralDataString) > 0
	BEGIN
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + @BroncoReferralDataString
	END

--------------Broncs staging data
	DECLARE 
		@stagingsummary VARCHAR(2000),
		@tmpsummary VARCHAR(2000),
		@SuspectedLCa BIT,
		@StagingInvestigations BIT,
		@ClinicalGrounds BIT,
		@ImagingOfThorax BIT,
		@MediastinalSampling BIT,
		@Metastases BIT,
		@PleuralHistology BIT,
		@Bronchoscopy BIT,
		@Stage BIT,
		@StageT VARCHAR(20),
		@StageN VARCHAR(20),
		@StageM VARCHAR(20),
		@StageType VARCHAR(20),
		@StageDate DATETIME,
		@PerformanceStatus BIT,
		@PerformanceStatusType INT

	DECLARE @tblsummary TABLE (summary VARCHAR(500))

	SELECT 
		@SuspectedLCa = CASE 
							WHEN EXISTS (SELECT 1 FROM ERS_ProcedureIndications WHERE ProcedureId = @ProcedureId AND IndicationId = (SELECT UniqueId FROM ERS_Indications WHERE NEDTerm = 'Suspected lung cancer'))
							THEN 1
							ELSE 0
						END,
		@StagingInvestigations=StagingInvestigations,
		@ClinicalGrounds=ClinicalGrounds,
		@ImagingOfThorax=ImagingOfThorax,
		@MediastinalSampling=MediastinalSampling,
		@Metastases=Metastases,
		@PleuralHistology=PleuralHistology,
		@Bronchoscopy=Bronchoscopy,
		@Stage=Stage,
		@StageT=stageTNames.ListItemText,
		@StageN=stageNNames.ListItemText,
		@StageM=stageMNames.ListItemText,
		@StageType=stageTypes.ListItemText,
		@StageDate=StageDate,
		@PerformanceStatus=PerformanceStatus,
		@PerformanceStatusType=PerformanceStatusType
		
	FROM 
		ERS_ProcedureStaging p
	LEFT JOIN
		ERS_Lists stageTNames ON p.StageT = stageTNames.ListItemNo AND stageTNames.ListDescription = 'BronchoStageT'
	LEFT JOIN
		ERS_Lists stageNNames ON p.StageN = stageNNames.ListItemNo AND stageNNames.ListDescription = 'BronchoStageN'
	LEFT JOIN
		ERS_Lists stageMNames ON p.StageM = stageMNames.ListItemNo AND stageMNames.ListDescription = 'BronchoStageM'
	LEFT JOIN
		ERS_Lists stageTypes ON p.StageType = stageTypes.ListItemNo AND stageTypes.ListDescription = 'BronchoStageType'
	WHERE
		ProcedureId = @ProcedureId


	--IF @SuspectedLCa = 1
	--BEGIN
		IF @StagingInvestigations = 1 
		BEGIN
			DELETE FROM @tblsummary
			SET @tmpsummary = NULL

			IF @ClinicalGrounds = 1 INSERT INTO @tblsummary VALUES ('Clinical grounds only')
			IF @ImagingOfThorax = 1 INSERT INTO @tblsummary VALUES ('Cross sectional imaging of thorax')
			IF @MediastinalSampling = 1 INSERT INTO @tblsummary VALUES ('Mediastinal sampling')
			IF @Metastases = 1 INSERT INTO @tblsummary VALUES ('Diagnostic tests for metastases')
			IF @PleuralHistology = 1 INSERT INTO @tblsummary VALUES ('Pleural cytology / histology')
			IF @Bronchoscopy = 1 INSERT INTO @tblsummary VALUES ('Bronchoscopy')

			SELECT @tmpsummary = COALESCE(@tmpsummary + ', ', '') + summary
			FROM @tblsummary

			IF @tmpsummary IS NOT NULL SET @tmpsummary = 'Staging Investigations (' + @tmpsummary + ')'
			ELSE SET @tmpsummary = 'Staging Investigations'

			SET @stagingsummary = @tmpsummary
		END

		IF @Stage = 1
		BEGIN
			DELETE FROM @tblsummary
			SET @tmpsummary = NULL

			IF @StageT IS NOT NULL AND @StageT <> '' INSERT INTO @tblsummary VALUES (@StageT)
			IF @StageN IS NOT NULL AND @StageN <> '' INSERT INTO @tblsummary VALUES (@StageN)
			IF @StageM IS NOT NULL AND @StageM <> '' INSERT INTO @tblsummary VALUES (@StageM)
			IF @StageType IS NOT NULL AND @StageType <> '' INSERT INTO @tblsummary VALUES (@StageType)
			IF @StageDate IS NOT NULL INSERT INTO @tblsummary VALUES ('Date ' + CONVERT(VARCHAR, @StageDate, 105))

			SELECT @tmpsummary = COALESCE(@tmpsummary + ', ', '') + summary
			FROM @tblsummary

			IF @tmpsummary IS NOT NULL SET @tmpsummary = 'Stage (' + @tmpsummary + ')'
			ELSE SET @tmpsummary = 'Stage'

			IF @stagingsummary IS NOT NULL SET @stagingsummary = @stagingsummary + ' ' + @tmpsummary
			ELSE SET @stagingsummary = @tmpsummary
		END

		IF @PerformanceStatus = 1
		BEGIN
			SET @tmpsummary = 'Performance Status' + 
							CASE @PerformanceStatusType 
								WHEN 1 THEN ' (normal activity)'
								WHEN 2 THEN ' (able to carry out light work)'
								WHEN 3 THEN ' (unable to carry out any work)'
								WHEN 4 THEN ' (limited self care)'
								WHEN 5 THEN ' (completely disabled)'
								ELSE ' (none)'
							END

			IF @stagingsummary IS NOT NULL SET @stagingsummary = @stagingsummary + ' ' + @tmpsummary
			ELSE SET @stagingsummary = @tmpsummary
		END

		IF LEN(@stagingsummary) > 0
		BEGIN
			SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + @stagingsummary
		END
	--END

RETURN @RetVal
END

GO


PRINT N'  Altering [dbo].[ogd_premedication_summary_update]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'ogd_premedication_summary_update',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)GO
/****** Object:  StoredProcedure [dbo].[ogd_premedication_summary_update]    Script Date: 29/06/2023 08:09:18 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[ogd_premedication_summary_update]
(
	@ProcedureId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000),
		@DrugName NVARCHAR(50),
		@Dose NVARCHAR(15),
		@Units NVARCHAR(50),
		@DeliveryMethod NVARCHAR(25),
		@ProcedureTypeId INT

	SET @Summary = ''
	

	DECLARE cm CURSOR READ_ONLY FOR
	SELECT DrugName, CAST(Dose AS FLOAT), Units, DeliveryMethod  FROM ERS_UpperGIPremedication WHERE ProcedureId = @ProcedureId AND DrugNo <> 0
	OPEN cm
	FETCH NEXT FROM cm INTO @DrugName, @Dose, @Units, @DeliveryMethod
	WHILE @@fetch_status = 0 
	BEGIN	
		--SET @summary = @summary + @DrugName + ' (' + @DeliveryMethod + ') ' + @Dose + ' ' + @Units + '<br />'
		IF @DrugName IN ('NoSedation')
		BEGIN
			SET @summary = @summary + 'No sedation/premedication'
		END
		ELSE IF @DrugName IN ('GeneralAnaesthetic')
		BEGIN
			SET @summary = @summary + 'General anaesthetic'
		END
		ELSE
		BEGIN
			SET @summary = @summary + @DrugName 
			IF @DeliveryMethod IS NOT NULL SET @summary = @summary + ' (' + @DeliveryMethod + ')'
			IF ISNULL(@Dose,0) > CONVERT(DECIMAL,0) AND @Units IS NOT NULL  SET @summary= @summary + ' '+ @Dose 
			IF ISNULL(@Units, '(none)') <> '(none)'  Set @Summary = @summary + ' ' + @Units
		END
		IF @summary<>''  SET @summary= @summary + '<br />'	
		FETCH NEXT FROM cm INTO @DrugName, @Dose, @Units, @DeliveryMethod
	END
	DEALLOCATE cm

	--PRINT @summary
	IF EXISTS(SELECT 1 FROM ERS_UpperGIPremedication_Summary WHERE ProcedureId = @ProcedureId)
	BEGIN
		DELETE FROM ERS_UpperGIPremedication_Summary WHERE ProcedureId = @ProcedureId
	END

	IF @summary <> ''
	BEGIN
		INSERT INTO ERS_UpperGIPremedication_Summary (ProcedureId, Summary)
		VALUES (@ProcedureId, @summary)
	END

	SELECT @ProcedureTypeId = ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureId

	IF @ProcedureTypeId in (10, 11) --Bronchoscopy/EBUS
	BEGIN
		SELECT @summary = @summary + ISNULL(summary, '')
		FROM ERS_BRT_BronchoDrugs 
		WHERE ProcedureId = @ProcedureId
		
		SET @summary = REPLACE(@summary, '<br /><br />', '<br />')
	END

	UPDATE ERS_ProceduresReporting
	SET PP_Premed = @summary
	WHERE ProcedureId = @ProcedureId

GO


PRINT N'  Altering [dbo].[usp_PrintReport_Select]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'usp_PrintReport_Select',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO
/****** Object:  StoredProcedure [dbo].[usp_PrintReport_Select]    Script Date: 29/06/2023 10:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_PrintReport_Select]  
(  
 @ProcedureId INT,  
 @Group VARCHAR(10),  
 @EpisodeNo INT = 0,  
       @PatientComboId VARCHAR(30) = NULL,  
       @ProcedureType INT,  
       @ColonType INT  
)  
AS  
  
SET NOCOUNT ON  
  
 DECLARE @SQLString NVARCHAR(MAX),  
   @FieldName VARCHAR(150),  
   @NodeName VARCHAR(50),  
   @TableName VARCHAR(50),  
   @Condition VARCHAR(100),  
   @ReportStyle SMALLINT,  
   @ExecQuery BINARY = 0,  
   @IncludeUGI BIT = 0,
   @SummaryOrder	INT = 0;  
  
 DECLARE @Procedure_Reporting_TableJoinText VARCHAR(255);  
 select @EpisodeNo=(CASE WHEN dbo.fnShouldIncludeUGI()=1 THEN @EpisodeNo ELSE 0 END);  
  
 CREATE TABLE #Summary (NodeName VARCHAR(200), NodeSummary NVARCHAR(MAX) ,[Group] VARCHAR(10), [SummaryOrder] INT)  
 CREATE TABLE #xmlmap ([FieldName] [varchar](50), [NodeName] [varchar](50), [Group] [varchar](10), [Active] [smallint], [OrderID] [int])  
  
 --DECLARE @ProcedureTypeId INT  
 --SELECT @ProcedureTypeId = ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureId  
  
IF @Group = 'AD'  
 INSERT INTO #xmlmap  
 SELECT FieldName, NodeName, [Group], Active, OrderID  
 FROM ERS_XMLMap   
 WHERE [FieldName] IN ('PP_Site_Legend', 'PP_SpecimenTaken')  
 ORDER BY OrderID  
ELSE IF @Group='Premed'  
       INSERT INTO #xmlmap  
       SELECT FieldName, NodeName, [Group], Active, OrderID   
    FROM ERS_XMLMap WHERE [FieldName] IN ('PP_Premed', 'PP_Bowel_Prep') AND [Group]='RS'  
ELSE  
 INSERT INTO #xmlmap  
 SELECT FieldName, NodeName, [Group], Active, OrderID  
 FROM ERS_XMLMap   
 WHERE [Group] = @Group AND [FieldName] NOT IN ('PP_Site_Legend', 'PP_SpecimenTaken')  
 ORDER BY OrderID  
  
 IF @ProcedureId IS NOT NULL AND @ProcedureId > 0  
  BEGIN  
   SET @TableName = '[ERS_Procedures]'  
   SET @Procedure_Reporting_TableJoinText = '  AS P LEFT JOIN dbo.ERS_ProceduresReporting AS PR ON P.ProcedureId = PR.ProcedureId '  
   SET @Condition = 'P.ProcedureId = @ProcedureId'  
  
   IF (SELECT isnull(PP_Pathology, '') from ERS_ProceduresReporting where ProcedureID = @ProcedureId) != ''  
    AND @Group = 'RS'  
    INSERT INTO #Summary   
    Select 'Revised', 'Revised report following pathology report dated ' + isnull(convert(varchar, DateOfReport, 106), ''), 'RS', @SummaryOrder  from ERS_UpperGIPathologyResults where ProcedureId = @ProcedureId  
  END  
 ELSE IF @EpisodeNo > 0  
  BEGIN  
      SELECT TOP 1 @TableName = LTRIM(RTRIM(dbo.fnGetUGI_tablename(@ProcedureType,'procedure')))  
   FROM [Episode]   
   WHERE CHARINDEX('1', [Status]) BETWEEN 1 AND 8 AND [Patient No] = @PatientComboId AND [Episode No] = @EpisodeNo  
   SET @Condition = '[Patient No] = @PatientComboId AND [Episode No] = @EpisodeNo'  
      IF @ColonType >= 0 SET @Condition = @Condition + ' AND [Procedure type] = ' +CAST( @ColonType as varchar(50))  
  END  
  
 DECLARE report_cursor CURSOR FOR   
 SELECT FieldName FROM #xmlmap ORDER BY OrderID ASC  
  
 OPEN report_cursor   
 FETCH NEXT FROM report_cursor INTO @FieldName  
  
 WHILE @@FETCH_STATUS = 0  
 BEGIN  
  SELECT @NodeName = NodeName, @Group = [Group], @SummaryOrder = OrderID FROM #xmlmap WHERE FieldName = @FieldName
	IF (@SummaryOrder IS NULL)
	BEGIN
		SET @SummaryOrder = 0
	END
   
  IF @ProcedureId IS NOT NULL AND @ProcedureId > 0  
  BEGIN  
   IF @FieldName = 'Endoscribe comments' SET @FieldName = 'EndoscribeComments'  
   ELSE IF @FieldName = 'Procedure date' SET @FieldName = 'CreatedOn'  
   ELSE IF @FieldName = 'Time of procedure' SET @FieldName = 'CreatedOn'  
   ELSE IF @FieldName = 'PP2_CompiledOn' SET @FieldName = 'ModifiedOn'  
   ELSE IF @FieldName = 'PP2_SiteData' SET @FieldName = 'PP_Site_Legend'  
   --ELSE IF @FieldName = 'PP_MainReportBody' SET @FieldName = 'Summary'    
  END  
  
  IF @FieldName = 'PP_Premed' AND @ProcedureType in (10, 11) --Bronchoscopy or EBUS
   SET @NodeName = 'Sedation and anaesthesia'  
  
  --IF [Report Style] = 1 -> New style report, select from PP2 field  
  IF @TableName <> '[ERS_Procedures]' AND @EpisodeNo > 0 AND @FieldName = 'PP_MainReportBody'  
    SET @FieldName = 'CASE WHEN ISNULL([Report Style],0) = 0 THEN PP_MainReportBody ELSE PP2_MainReportBody END'  
  ELSE IF @FieldName = 'PP_MainReportBody' AND @ProcedureId > 0 SET @FieldName = 'PR.Summary'    
  ELSE IF @FieldName = 'Resected colon no' AND @ProcedureId > 0 SET @FieldName = 'ResectedColonNo'   

  ELSE  
   SET @FieldName = '[' + @FieldName + ']'  
   
  SET @SQLString = 'INSERT INTO #Summary ' +   
       ' SELECT ''' + @NodeName + ''', ' + @FieldName + ', ' + '''' + @Group + '''' + ', ' + CAST(@SummaryOrder AS NVARCHAR(10)) +  
       ' FROM ' + @TableName +   
       CASE WHEN @ProcedureId>0 THEN @Procedure_Reporting_TableJoinText ELSE '' END +  
       ' WHERE ' + @Condition;  
   
  --PP_Therapies (Therapeutic procedures) should be displayed for UGI old style report only, else should be part of the site  
  IF @TableName <> '[ERS_Procedures]' AND @EpisodeNo > 0   
  BEGIN  
   IF @FieldName IN ('[PP_Therapies]', '[PP_SpecimenTaken]' )  
    SET @SQLString = @SQLString + ' AND ISNULL([Report Style],0) = 0'  
   --PP2_SiteData (Site Data) should not be displayed for UGI old style report  
   ELSE IF @FieldName = '[PP2_SiteData]'  
    SET @SQLString = @SQLString + ' AND ISNULL([Report Style],0) = 1'  
  END   
  
  SET @ExecQuery =   
   CASE   
    WHEN @FieldName = '[PP_NPSAalert]' AND @TableName <> '[Upper GI Procedure]' THEN 0  
    WHEN @FieldName = '[PP_ResectedColon]' AND @EpisodeNo > 0 THEN 0  
    WHEN @FieldName = '[Resected colon no]' AND @TableName <> '[Colon Procedure]' THEN 0  
    WHEN @FieldName = '[PP_Coding]' AND @TableName <> '[ERS_Procedures]' THEN 0  
    WHEN @FieldName = '[Report style]' AND @TableName = '[ERS_Procedures]' THEN 0  
    WHEN LEFT(@FieldName,10) = '[PP2_Patho' AND @TableName = '[ERS_Procedures]' THEN 0  
    ELSE 1  
   END  
  
  --Select @ProcedureId, @EpisodeNo, @PatientComboId, @sqlstring  
  IF @ExecQuery = 1   
  BEGIN  
   EXEC sp_executesql @SQLString,  
    N'@ProcedureId INT, @EpisodeNo INT, @PatientComboId VARCHAR(30)',  
    @ProcedureId, @EpisodeNo, @PatientComboId  
  END  
  
  FETCH NEXT FROM report_cursor INTO @FieldName  
 END  
  
 CLOSE report_cursor  
 DEALLOCATE report_cursor  
  
 IF @EpisodeNo > 0 --UGI  
 BEGIN  
  UPDATE #Summary SET NodeSummary = REPLACE(NodeSummary,char(13),'<BR />') WHERE NodeName in ('Report', 'Indications', 'Advice/comments')   
  --UPDATE #Summary SET NodeSummary = REPLACE(NodeSummary,'<br><b>','<b>') WHERE NodeName in ('Site Data')  
  UPDATE #Summary SET NodeSummary = REPLACE(NodeSummary,'</b>','</b><BR />') WHERE NodeName in ('Site Data')   
  --UPDATE #Summary SET NodeSummary = REPLACE(NodeSummary,char(13),'<BR />&nbsp;&nbsp;') WHERE NodeName in ('Site Data')   
  --UPDATE #Summary SET NodeSummary = REPLACE(NodeSummary,'<BR />&nbsp;&nbsp;<b>','<BR /><b>') WHERE NodeName in ('Site Data')   
 END   
  
 IF EXISTS(SELECT TOP 1 NodeName FROM #Summary WHERE NodeName = 'InstForCare')  
 BEGIN   
  UPDATE #Summary SET NodeName = (SELECT TOP 1 NodeSummary FROM #Summary WHERE NodeName = 'InstForCareHeading')  
   ,NodeSummary = dbo.fnFirstLetterUpper(NodeSummary)  
  WHERE NodeName = 'InstForCare'  
  
  DELETE #Summary WHERE NodeName = 'InstForCareHeading'  
 END  
  
 --Append NPSA alert to end of report section  
 IF (SELECT COUNT(*) FROM #Summary WHERE NodeName = 'Report') > 0  
 BEGIN  
  DECLARE @NPSAalert NVARCHAR(MAX)   
  IF @EpisodeNo > 0  
   SELECT @NPSAalert=CONVERT(NVARCHAR(MAX),[PP_NPSAalert]) FROM  [Upper GI Procedure] WHERE [Patient No] = @PatientComboId AND [Episode No] = @EpisodeNo  
  ELSE IF @ProcedureId IS NOT NULL AND @ProcedureId > 0  
   SELECT @NPSAalert=CONVERT(NVARCHAR(MAX),[PP_NPSAalert]) FROM [ERS_ProceduresReporting] WHERE ProcedureId = @ProcedureId  
  
  IF ISNULL(@NPSAalert,'') <> ''  
   UPDATE #Summary  
   SET NodeSummary = NodeSummary + '<table style="border: 1px solid red;border-radius:10px;-moz-border-radius:10px;-webkit-border-radius:10px;width:95%;"><tr><td style="padding:10px;color:red;">' + @NPSAalert + '</td><td style="width:5%;padding:5px;"><img src="/images/icons/alert.png" style="vertical-align:middle; padding:0px 2px 0px 2px;" /></td></tr></table>'  
   WHERE NodeName = CASE WHEN @EpisodeNo > 0 THEN 'Site Data' ELSE 'Report' END  
 END  
  
	SELECT S.[NodeName], S.[NodeSummary], S.[Group]
	FROM #Summary S
	left outer join #xmlmap x on x.NodeName = S.NodeName
	WHERE S.NodeSummary IS NOT NULL
	order by S.SummaryOrder --x.OrderID 
  
 DROP TABLE #xmlmap  
 DROP TABLE #Summary

GO
PRINT N'Finished Updates for TFS# 2741';

GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	2471
------------------------------------------------------------------------------------------------------------------------

GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Steve 03/07/23
-- TFS#	2957
-- Description of change
-- (2957) Change Hospital on the Report to be Referring Hospital
--   Added Referring Hospital to ERS_ProceduresReporting at Procedure creation
------------------------------------------------------------------------------------------------------------------------
GO
PRINT N'Begining Updates for TFS# 2957';

GO
PRINT N'  Altering [dbo].[usp_Procedures_Insert]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'usp_Procedures_Insert',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)


GO
/****** Object:  StoredProcedure [dbo].[usp_Procedures_Insert]    Script Date: 04/07/2023 14:51:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Procedures_Insert]
(
	@ProcedureType		INT,
	--@PatientNo		VARCHAR(24),
	@PatientId			INT,
	@ProcedureDate		DATETIME,
	@ProcedureTime		VARCHAR(2),
	@PatientStatus		INT,
	@PatientWard		INT,
	@PatientType		INT,
	@OperatingHospitalId INT,
	@ListConsultant		INT,
	@Endoscopist1		INT,
	@Endoscopist2		INT,
	@Assistant			INT,
	@Nurse1				INT,
	@Nurse2				INT,
	@Nurse3				INT,
	@Nurse4				INT,
	@ReferralHospitalNo INT,
	@ReferralConsultantNo INT,
	@ReferralConsultantSpeciality INT,
	@PatientConsent		TINYINT,
	@DefaultCheckBox	BIT,
	@UserID				INT,
	@ProductType		TINYINT,
	@ListType			TINYINT,
	@Endo1Role			TINYINT,
	@Endo2Role			TINYINT,
	@CategoryListId		INT,
	@OnWaitingList		BIT,
	@OpenAccessProc		TINYINT,
	@EmergencyProcType	TINYINT,
	@NewProcedureId		INT OUTPUT,	-- This will return the newly created ProcedureId to the GUI! To play
	@ImagePortId		INT,
	@Points				DECIMAL,
	@ChecklistComplete	BIT,
	@ReferrerType		INT,
	@ReferrerTypeOther  VARCHAR(500),
	@ProviderId			INT,
	@ProviderOther		VARCHAR(500),
	@PatientNotes		BIT,
	@PatientReferralLetter	BIT,
	@ImageGenderID	int,
	@OrderId	int
)
AS

SET NOCOUNT ON

DECLARE @newProcId INT
DECLARE @ppEndos VARCHAR(2000), @GPName varchar(255), @GPAddress varchar(max), @Endo1 varchar(500), @Endo2 varchar(500), @RefCons varchar(50), @RefHosp varchar(50)

BEGIN TRANSACTION
--sp_help 'dbo.ERS_Procedures'
	BEGIN TRY
		INSERT INTO ERS_Procedures
			(ProcedureType,
			CreatedBy,	
			CreatedOn,			
			ModifiedOn,
			ProcedureTime,
			PatientId,
			CategoryListId,
			OnWaitingList,
			OpenAccessProc,
			EmergencyProcType,
			OperatingHospitalID,
			ListConsultant,
			Endoscopist1,
			Endoscopist2,
			Assistant,
			Nurse1,
			Nurse2,
			Nurse3,
			Nurse4,
			ReferralHospitalNo,
			ReferralConsultantNo,
			ReferralConsultantSpeciality,
			PatientStatus,
			Ward,
			PatientType,
			PatientConsent,
			ListType,
			Endo1Role,
			Endo2Role,
			ImagePortId,
			WhoCreatedId,
			WhenCreated,
			Points,
			ChecklistComplete,
			ReferrerType,
			ReferrerTypeOther,
			ProviderTypeId,
			ProviderOther,
			PatientNotes,
			PatientReferralLetter,
			ImageGenderID,
			OrderId)
		VALUES (
			@ProcedureType,
			@UserID,
			@ProcedureDate, --CASE WHEN CONVERT(DATE, GETDATE()) = @ProcedureDate THEN GETDATE() ELSE @ProcedureDate END, --Insert date and time if Procedure date is current date
			GETDATE(),
			@ProcedureTime,
			@PatientId,
			@CategoryListId,
			@OnWaitingList,
			@OpenAccessProc,
			@EmergencyProcType,
			@OperatingHospitalID,
			@ListConsultant,
			@Endoscopist1,
			@Endoscopist2,
			@Assistant,
			@Nurse1,
			@Nurse2,
			@Nurse3,
			@Nurse4,
			@ReferralHospitalNo,
			@ReferralConsultantNo,
			@ReferralConsultantSpeciality,
			@PatientStatus,
			@PatientWard,
			@PatientType,
			@PatientConsent, 
			@ListType,
			@Endo1Role,
			@Endo2Role,
			@ImagePortId,
			@UserID,
			GETDATE(),
			@Points,
			@ChecklistComplete,
			@ReferrerType,
			@ReferrerTypeOther,
			@ProviderId,
			@ProviderOther,
			@PatientNotes,
			@PatientReferralLetter,
			@ImageGenderID,
			@OrderId)

		SET @newProcId = SCOPE_IDENTITY();
	
		--## Important Work- Insert a Blank Record in the ERS_ProceduresReorting- with this Unique ID! So, you can simply Update the PP fields later..!! 
		INSERT INTO dbo.ERS_ProceduresReporting(ProcedureId)VALUES(@newProcId);

		SET @ppEndos = ''
		IF @ListConsultant > 0 SELECT @ppEndos = @ppEndos + '$$List Consultant: ' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @ListConsultant
		IF @Endoscopist1 > 0 
		BEGIN
			SELECT @Endo1 = Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Endoscopist1
			SELECT @ppEndos = @ppEndos + '$$Endoscopist No1: ' + @Endo1
		END
		IF @Endoscopist2 > 0 
		BEGIN
			SELECT @Endo2 = Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Endoscopist2
			SELECT @ppEndos = @ppEndos + '$$Endoscopist No2: ' + @Endo2
		END
		IF @Nurse1 > 0 OR @Nurse2 > 0 OR @Nurse3 > 0 OR @Nurse4 > 0 
		BEGIN
			SELECT @ppEndos = @ppEndos + '$$' + 'Nurses: '
			IF @Nurse1 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse1
			IF @Nurse2 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse2
			IF @Nurse3 > 0 SELECT @ppEndos =  @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse3
			IF @Nurse4 > 0 SELECT @ppEndos =  @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse4
		END
		IF CHARINDEX('$$', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('$$', @ppEndos), 2, ''), '$$', '<br/>')
		IF CHARINDEX('##', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('##', @ppEndos), 2, ''), '##', '<br/>')
	
		SET @RefCons=''
		SELECT @RefCons = ec.CompleteName FROM dbo.ERS_Consultant ec WHERE ec.ConsultantID = @ReferralConsultantNo
		--SELECT @GPName = p.[GP Name] , @GPAddress = p.[GP Address] FROM Patient p left join  ERS_Procedures pr ON p.[Patient No]= pr.PatientId WHERE pr.ProcedureId = @newProcId
		--SELECT @GPName = p.[GP Name] , @GPAddress = p.[GP Address] FROM ERS_Patients p WHERE p.[Patient No]= @PatientId

		SET @RefHosp = ''
		SELECT @RefHosp = rh.HospitalName FROM dbo.ERS_ReferralHospitals rh WHERE rh.HospitalID = @ReferralHospitalNo

		--Get GP practice name and address
		SELECT 	TOP 1 
			@GPName		= g.CompleteName,
			@GPAddress	= replace(dbo.fnFullAddress(ep.[Name], ep.Address1, ep.Address2, CASE WHEN ep.Address3 Is null THEN EP.Address4 ELSE ep.Address3 + ' ' + EP.Address4 END, ep.PostCode), ',', ', <br />')
		FROM ERS_Patients p 
		LEFT JOIN ERS_GPs g ON g.GPId = p.RegGpId
		LEFT JOIN dbo.ERS_Practices ep ON p.RegGpPracticeId = ep.PracticeID
		where p.PatientId = @PatientId 

		UPDATE ERS_ProceduresReporting SET PP_Endos = @ppEndos, PP_GPName = @GPName, PP_GPAddress = @GPAddress, PP_Endo1 = @Endo1, PP_Endo2 = @Endo2, PP_RefCons = @RefCons, PP_RefHosp = @RefHosp WHERE ProcedureId = @newProcId

		UPDATE ERS_Consultant SET SortOrder = ISNULL(SortOrder,0) + 1 WHERE ConsultantID = @ReferralConsultantNo

		EXEC procedure_summary_update @newProcId

		--SELECT @newProcId AS ProcedureId
		SELECT @NewProcedureId=@newProcId;

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
PRINT N'Finished Updates for TFS# 2957';

GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	2957
------------------------------------------------------------------------------------------------------------------------

GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Steve 03/07/23
-- TFS#	2802
-- Description of change
-- (2802) Report consultants title and qualification missing
--   Added Consultant Qualifications and Job Title
------------------------------------------------------------------------------------------------------------------------

GO
PRINT N'Begining Updates for TFS# 2802';

GO
PRINT N'  Altering [dbo].[usp_Procedures_Insert]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'usp_Procedures_Insert',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
					 
GO
/****** Object:  StoredProcedure [dbo].[usp_Procedures_Insert]    Script Date: 05/07/2023 13:32:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Procedures_Insert]
(
	@ProcedureType		INT,
	--@PatientNo		VARCHAR(24),
	@PatientId			INT,
	@ProcedureDate		DATETIME,
	@ProcedureTime		VARCHAR(2),
	@PatientStatus		INT,
	@PatientWard		INT,
	@PatientType		INT,
	@OperatingHospitalId INT,
	@ListConsultant		INT,
	@Endoscopist1		INT,
	@Endoscopist2		INT,
	@Assistant			INT,
	@Nurse1				INT,
	@Nurse2				INT,
	@Nurse3				INT,
	@Nurse4				INT,
	@ReferralHospitalNo INT,
	@ReferralConsultantNo INT,
	@ReferralConsultantSpeciality INT,
	@PatientConsent		TINYINT,
	@DefaultCheckBox	BIT,
	@UserID				INT,
	@ProductType		TINYINT,
	@ListType			TINYINT,
	@Endo1Role			TINYINT,
	@Endo2Role			TINYINT,
	@CategoryListId		INT,
	@OnWaitingList		BIT,
	@OpenAccessProc		TINYINT,
	@EmergencyProcType	TINYINT,
	@NewProcedureId		INT OUTPUT,	-- This will return the newly created ProcedureId to the GUI! To play
	@ImagePortId		INT,
	@Points				DECIMAL,
	@ChecklistComplete	BIT,
	@ReferrerType		INT,
	@ReferrerTypeOther  VARCHAR(500),
	@ProviderId			INT,
	@ProviderOther		VARCHAR(500),
	@PatientNotes		BIT,
	@PatientReferralLetter	BIT,
	@ImageGenderID	int,
	@OrderId	int
)
AS

SET NOCOUNT ON

DECLARE @newProcId INT
DECLARE @ppEndos VARCHAR(2000), @GPName varchar(255), @GPAddress varchar(max), @Endo1 varchar(500), @Endo2 varchar(500), @RefCons varchar(50), @RefHosp varchar(50)

BEGIN TRANSACTION
--sp_help 'dbo.ERS_Procedures'
	BEGIN TRY
		INSERT INTO ERS_Procedures
			(ProcedureType,
			CreatedBy,	
			CreatedOn,			
			ModifiedOn,
			ProcedureTime,
			PatientId,
			CategoryListId,
			OnWaitingList,
			OpenAccessProc,
			EmergencyProcType,
			OperatingHospitalID,
			ListConsultant,
			Endoscopist1,
			Endoscopist2,
			Assistant,
			Nurse1,
			Nurse2,
			Nurse3,
			Nurse4,
			ReferralHospitalNo,
			ReferralConsultantNo,
			ReferralConsultantSpeciality,
			PatientStatus,
			Ward,
			PatientType,
			PatientConsent,
			ListType,
			Endo1Role,
			Endo2Role,
			ImagePortId,
			WhoCreatedId,
			WhenCreated,
			Points,
			ChecklistComplete,
			ReferrerType,
			ReferrerTypeOther,
			ProviderTypeId,
			ProviderOther,
			PatientNotes,
			PatientReferralLetter,
			ImageGenderID,
			OrderId)
		VALUES (
			@ProcedureType,
			@UserID,
			@ProcedureDate, --CASE WHEN CONVERT(DATE, GETDATE()) = @ProcedureDate THEN GETDATE() ELSE @ProcedureDate END, --Insert date and time if Procedure date is current date
			GETDATE(),
			@ProcedureTime,
			@PatientId,
			@CategoryListId,
			@OnWaitingList,
			@OpenAccessProc,
			@EmergencyProcType,
			@OperatingHospitalID,
			@ListConsultant,
			@Endoscopist1,
			@Endoscopist2,
			@Assistant,
			@Nurse1,
			@Nurse2,
			@Nurse3,
			@Nurse4,
			@ReferralHospitalNo,
			@ReferralConsultantNo,
			@ReferralConsultantSpeciality,
			@PatientStatus,
			@PatientWard,
			@PatientType,
			@PatientConsent, 
			@ListType,
			@Endo1Role,
			@Endo2Role,
			@ImagePortId,
			@UserID,
			GETDATE(),
			@Points,
			@ChecklistComplete,
			@ReferrerType,
			@ReferrerTypeOther,
			@ProviderId,
			@ProviderOther,
			@PatientNotes,
			@PatientReferralLetter,
			@ImageGenderID,
			@OrderId)

		SET @newProcId = SCOPE_IDENTITY();
	
		--## Important Work- Insert a Blank Record in the ERS_ProceduresReorting- with this Unique ID! So, you can simply Update the PP fields later..!! 
		INSERT INTO dbo.ERS_ProceduresReporting(ProcedureId)VALUES(@newProcId);

		SET @ppEndos = ''
		IF @ListConsultant > 0 SELECT @ppEndos = @ppEndos + '$$List Consultant: ' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @ListConsultant
		IF @Endoscopist1 > 0 
		BEGIN
			SELECT @Endo1 = Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Endoscopist1
			SELECT @ppEndos = @ppEndos + '$$Endoscopist No1: ' + @Endo1
			SELECT  @Endo1 = Title + ' ' + Forename + ' ' + Surname + 
					CASE WHEN isnull(Qualifications, '') != '' THEN ', ' + Qualifications else '' END + 
					CASE WHEN isnull(u.JobTitleID, 0) > 0 THEN CHAR(13)+CHAR(10) + jt.Description ELSE '' END  
			FROM ERS_Users u
			LEFT JOIN ERS_JobTitles jt on u.JobTitleID = jt.JobTitleID 
			WHERE UserID = @Endoscopist1
		END
		IF @Endoscopist2 > 0 
		BEGIN
			SELECT @Endo2 = Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Endoscopist2
			SELECT @ppEndos = @ppEndos + '$$Endoscopist No2: ' + @Endo2
			SELECT  @Endo2 = Title + ' ' + Forename + ' ' + Surname + 
					CASE WHEN isnull(Qualifications, '') != '' THEN ', ' + Qualifications else '' END + 
					CASE WHEN isnull(u.JobTitleID, 0) > 0 THEN CHAR(13)+CHAR(10) + jt.Description ELSE '' END  
			FROM ERS_Users u
			LEFT JOIN ERS_JobTitles jt on u.JobTitleID = jt.JobTitleID 		
			WHERE UserID = @Endoscopist2
		END
		IF @Nurse1 > 0 OR @Nurse2 > 0 OR @Nurse3 > 0 OR @Nurse4 > 0 
		BEGIN
			SELECT @ppEndos = @ppEndos + '$$' + 'Nurses: '
			IF @Nurse1 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse1
			IF @Nurse2 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse2
			IF @Nurse3 > 0 SELECT @ppEndos =  @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse3
			IF @Nurse4 > 0 SELECT @ppEndos =  @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse4
		END
		IF CHARINDEX('$$', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('$$', @ppEndos), 2, ''), '$$', '<br/>')
		IF CHARINDEX('##', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('##', @ppEndos), 2, ''), '##', '<br/>')
	
		SET @RefCons=''
		SELECT @RefCons = ec.CompleteName FROM dbo.ERS_Consultant ec WHERE ec.ConsultantID = @ReferralConsultantNo
		--SELECT @GPName = p.[GP Name] , @GPAddress = p.[GP Address] FROM Patient p left join  ERS_Procedures pr ON p.[Patient No]= pr.PatientId WHERE pr.ProcedureId = @newProcId
		--SELECT @GPName = p.[GP Name] , @GPAddress = p.[GP Address] FROM ERS_Patients p WHERE p.[Patient No]= @PatientId

		SET @RefHosp = ''
		SELECT @RefHosp = rh.HospitalName FROM dbo.ERS_ReferralHospitals rh WHERE rh.HospitalID = @ReferralHospitalNo

		--Get GP practice name and address
		SELECT 	TOP 1 
			@GPName		= g.CompleteName,
			@GPAddress	= replace(dbo.fnFullAddress(ep.[Name], ep.Address1, ep.Address2, CASE WHEN ep.Address3 Is null THEN EP.Address4 ELSE ep.Address3 + ' ' + EP.Address4 END, ep.PostCode), ',', ', <br />')
		FROM ERS_Patients p 
		LEFT JOIN ERS_GPs g ON g.GPId = p.RegGpId
		LEFT JOIN dbo.ERS_Practices ep ON p.RegGpPracticeId = ep.PracticeID
		where p.PatientId = @PatientId 

		UPDATE ERS_ProceduresReporting SET PP_Endos = @ppEndos, PP_GPName = @GPName, PP_GPAddress = @GPAddress, PP_Endo1 = @Endo1, PP_Endo2 = @Endo2, PP_RefCons = @RefCons, PP_RefHosp = @RefHosp WHERE ProcedureId = @newProcId

		UPDATE ERS_Consultant SET SortOrder = ISNULL(SortOrder,0) + 1 WHERE ConsultantID = @ReferralConsultantNo

		EXEC procedure_summary_update @newProcId

		--SELECT @newProcId AS ProcedureId
		SELECT @NewProcedureId=@newProcId;

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

PRINT N'  Altering [dbo].[usp_UpdateProcedureStaff]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'usp_UpdateProcedureStaff',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
					 
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateProcedureStaff]    Script Date: 05/07/2023 13:36:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_UpdateProcedureStaff]
(
	@ProcedureID		AS INT,
	@ListType			AS INT,
	@ListConsultant		AS VARCHAR(24),
	@Endoscopist1		AS VARCHAR(24),
	@Endoscopist1Role	AS INT, 
	@Endoscopist2		AS VARCHAR(24),
	@Endoscopist2Role	AS INT,
	@Nurse1				AS VARCHAR(24),
	@Nurse2				AS VARCHAR(24),
	@Nurse3				AS VARCHAR(24),
	@Nurse4				AS VARCHAR(24),
	@OperatingHospitalId AS INT,
	@LoggedInUserId		AS INT

)
AS
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @ppEndos VARCHAR(2000), @GPName varchar(255), @GPAddress varchar(max), @Endo1 varchar(500), @Endo2 varchar(500)

	UPDATE ERS_Procedures 
		SET 
			  ListType			= @ListType
			, ListConsultant	= @ListConsultant
			, Endoscopist1		= @Endoscopist1
			, Endo1Role			= @Endoscopist1Role
			, Endoscopist2		= @Endoscopist2
			, Endo2Role			= @Endoscopist2Role
			, Nurse1			= @Nurse1
			, Nurse2			= @Nurse2
			, Nurse3			= @Nurse3 
			, Nurse4			= @Nurse4 
			, WhoUpdatedId		= @LoggedInUserId
			, WhenUpdated		= GETDATE()
	WHERE ProcedureId = @ProcedureId;

	SET @ppEndos = ''
       IF @ListConsultant > 0 SELECT @ppEndos = @ppEndos + '$$List Consultant: ' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @ListConsultant
       IF @Endoscopist1 > 0 
       BEGIN
			SELECT @Endo1 = Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Endoscopist1
			SELECT @ppEndos = @ppEndos + '$$Endoscopist No1: ' + @Endo1
			SELECT  @Endo1 = Title + ' ' + Forename + ' ' + Surname + 
					CASE WHEN isnull(Qualifications, '') != '' THEN ', ' + Qualifications else '' END + 
					CASE WHEN isnull(u.JobTitleID, 0) > 0 THEN CHAR(13)+CHAR(10) + jt.Description ELSE '' END  
			FROM ERS_Users u
			LEFT JOIN ERS_JobTitles jt on u.JobTitleID = jt.JobTitleID 
			WHERE UserID = @Endoscopist1
	   END
	   IF @Endoscopist2 > 0 
		BEGIN
			SELECT @Endo2 = Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Endoscopist2
			SELECT @ppEndos = @ppEndos + '$$Endoscopist No2: ' + @Endo2
			SELECT  @Endo2 = Title + ' ' + Forename + ' ' + Surname + 
					CASE WHEN isnull(Qualifications, '') != '' THEN ', ' + Qualifications else '' END + 
					CASE WHEN isnull(u.JobTitleID, 0) > 0 THEN CHAR(13)+CHAR(10) + jt.Description ELSE '' END  
			FROM ERS_Users u
			LEFT JOIN ERS_JobTitles jt on u.JobTitleID = jt.JobTitleID 		
			WHERE UserID = @Endoscopist2
		END
       IF @Nurse1 > 0 OR @Nurse2 > 0 OR @Nurse3 > 0 OR @Nurse4 > 0  
       BEGIN
              SELECT @ppEndos = @ppEndos + '$$' + 'Nurses: '
              IF @Nurse1 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Nurse1
              IF @Nurse2 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Nurse2
              IF @Nurse3 > 0 SELECT @ppEndos =  @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Nurse3
              IF @Nurse4 > 0 SELECT @ppEndos =  @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Nurse4
       END
       IF CHARINDEX('$$', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('$$', @ppEndos), 2, ''), '$$', '<br/>')
       IF CHARINDEX('##', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('##', @ppEndos), 2, ''), '##', '<br/>')
       
       SELECT @GPName = ISNULL(p.GPName,''), @GPAddress = ISNULL(p.GPAddress,'')
	   FROM ERS_VW_PatientswithGP p 
			LEFT JOIN  ERS_Procedures pr ON p.PatientId= pr.PatientId 
	   WHERE pr.ProcedureId = @ProcedureId;

       UPDATE ERS_ProceduresReporting SET PP_Endos = @ppEndos, PP_Endo1 = @Endo1, PP_Endo2 = @Endo2, PP_GPName = @GPName, PP_GPAddress = @GPAddress WHERE ProcedureId = @ProcedureId;

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
PRINT N'Finished Updates for TFS# 2802';

GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	2802
------------------------------------------------------------------------------------------------------------------------

GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 05.07.23
-- TFS#		2805
-- Description of change
-- Check for complete sections and completed flag update moved outside if block so it applies to all procedures outside of the filter
------------------------------------------------------------------------------------------------------------------------
GO

PRINT N'Altering [dbo].[check_requiredfields]...';


GO

ALTER PROCEDURE [dbo].[check_requiredfields]
(
	@ProcedureId INT,
	@PageId INT
)
AS
BEGIN
	DECLARE @ProcedureTypeId INT, @ProcedureDNA INT, @UISectionId INT, @SectionName VARCHAR(50), @SectionPageId INT, @SectionControl VARCHAR(50), @IncompleteSections VARCHAR(MAX) = '', @ProcedureModifiedDate DATETIME, @ProcedureCompleted BIT
	SELECT @ProcedureTypeId = ProcedureType, @ProcedureDNA = ISNULL(DNA,0), @ProcedureModifiedDate = ModifiedOn, @ProcedureCompleted = ISNULL(ProcedureCompleted,0) FROM ERS_Procedures WHERE ProcedureId = @ProcedureId

	IF NOT @ProcedureCompleted = 1 AND @ProcedureModifiedDate >= (SELECT TOP 1 InstallDate
																FROM DBVersion
																WHERE SUBSTRING(VersionNum,1,1) = '2'
																ORDER BY InstallDate ASC)
	BEGIN
	IF @ProcedureTypeId NOT IN (10,11,13) 
		BEGIN
		
	
			DECLARE cur CURSOR FOR (SELECT us.UISectionId, SectionName, PageId, SectionControl
									FROM UI_sections us
										LEFT JOIN UI_SectionProcedureTypes spt ON spt.UISectionId = us.UISectionId
									WHERE NEDRequired = 1 
									AND ISNULL(ProcedureTypeId,0) IN (0,@ProcedureTypeId) 
									AND DNAExempt = CASE WHEN @ProcedureDNA > 0 THEN 0 ELSE DNAExempt END 
									AND (PageId = @PageId OR @PageId = 0))
								
			SET @IncompleteSections = ''
			OPEN cur
			FETCH NEXT FROM cur INTO @UISectionId, @SectionName, @SectionPageId, @SectionControl

			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureSummary WHERE ProcedureId = @ProcedureId AND SectionId = @UISectionId)
				BEGIN
					SET @IncompleteSections = @IncompleteSections + '&bull;' + @SectionName + '<br />'
		--			SET @IncompleteSections = @IncompleteSections + '&bull;<a href="/' + CASE @SectionPageId WHEN 1 THEN 'PreProcedure.aspx' WHEN 2 THEN 'Procedure.aspx' WHEN 3 THEN 'PostProcedure.aspx' END  +'#' + REPLACE(@SectionName, ' ','') + '">' + @SectionName + '</a><br />'
				END
		
				IF LOWER(@SectionName) = 'procedure timing' AND CHARINDEX('',@IncompleteSections) = 0 /*no point validating if its not complete*/
				BEGIN
					DECLARE @StartTime DATETIME, @EndTime DATETIME
					SELECT @StartTime= StartDateTime, @EndTime = EndDateTime FROM ERS_Procedures WHERE ProcedureId= @ProcedureId
					IF @StartTime > @EndTime
					BEGIN
						SET @IncompleteSections = @IncompleteSections + '&bull;' + @SectionName + ' is incorrect. Check start is not after end date/time<br />'
					END
				END

				IF LOWER(@SectionName) = 'indications'
				BEGIN
					--'check sub indications'
					IF (SELECT COUNT(*) 
					FROM 
						(SELECT CASE WHEN ei.SubIndicationParent = 0 THEN 1 WHEN ei.SubIndicationParent = 1 AND EXISTS (SELECT 1 FROM dbo.ERS_ProcedureSubIndications epsi WHERE epsi.ProcedureId = ep.ProcedureId) THEN 1 ELSE 0 END AS 'Complete'
						FROM dbo.ERS_ProcedureIndications ep
							INNER JOIN dbo.ERS_Indications ei ON ei.UniqueId = ep.IndicationId
						WHERE procedureid = @ProcedureId) inds
						WHERE inds.Complete = 0) > 0
					BEGIN
						SET @IncompleteSections = @IncompleteSections + '&bull;Subindications<br />'
					END
				END

				IF LOWER(@SectionName) = 'rx'
				BEGIN
					--check if anti coag has been marked as yes.. if so perform checks 
					DECLARE @AntiCoagDrugs BIT
					SELECT @AntiCoagDrugs = AntiCoagDrugs FROM ERS_Procedures WHERE ProcedureId = @ProcedureId
					IF @AntiCoagDrugs = 1 
					BEGIN
						IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureSummary WHERE ProcedureId = @ProcedureId AND SectionId = @UISectionId)
						BEGIN
							SET @IncompleteSections = REVERSE(SUBSTRING(REVERSE(@IncompleteSections), CHARINDEX('<br />', REVERSE(@IncompleteSections)) + 7, LEN(@IncompleteSections))) + '<small><em> - RX drugs must be complete for patients that are taking Anti-coag or Anti-platelet Medication</em></small><br />'
							SELECT @IncompleteSections
						END
					END
				END

				FETCH NEXT FROM cur INTO @UISectionId, @SectionName, @SectionPageId, @SectionControl
			END

			CLOSE cur
			DEALLOCATE cur
	
			--check for RX completion if anti coag selected


			--check for any unanswered mandatory pathway plan questions
			IF (SELECT COUNT(*)
				FROM dbo.ERS_PathwayPlanQuestions eppq
					LEFT JOIN ERS_ProcedurePathwayPlanAnswers pa ON pa.QuestionId = eppq.QuestionId AND pa.ProcedureId = @ProcedureId
				WHERE eppq.Mandatory = 1 AND ProcedureQuestionAnswerId IS NULL AND eppq.OrderById <> 99999 AND Suppressed =0) > 0
				AND @PageId in (0,3)
			BEGIN
				SET @IncompleteSections = @IncompleteSections + '&bull;Pathway Plan<br />'
			END
		END

		--All required fields entered, update flag ProcedureCompleted
		IF @PageId = 0 AND @IncompleteSections	 = ''
		BEGIN
			IF (SELECT ISNULL(ProcedureCompleted,0) FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)  = 0
			BEGIN
				UPDATE ERS_Procedures SET ProcedureCompleted = 1 WHERE ProcedureId = @ProcedureId
			END
		END
		ELSE IF @IncompleteSections <> ''
		BEGIN
				UPDATE ERS_Procedures SET ProcedureCompleted = 0 WHERE ProcedureId = @ProcedureId
		END

		SELECT @IncompleteSections
	END
END
GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 10.07.23
-- TFS#	2874
-- Description of change
-- 
------------------------------------------------------------------------------------------------------------------------
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'DIPOLYPP3' AND Section = 'Colon' AND ProcedureTypeID = 3)
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, EndoCode, ProcedureTypeID, Section, OrderByNumber, Code, NED_Include)
	VALUES ('Ileum polyp(s)', 'Polyps', 'Polyp/s',3,'Colon', 0, 'DIPOLYPP3', 1),
		   ('Ileum polyp(s)', 'Polyps', 'Polyp/s',3,'Colon', 0, 'SIPOLYPP3', 1),
		   ('Ileum polyp(s)', 'Polyps', 'Polyp/s',8,'Colon', 0, 'SIPOLYPP3', 1),
		   ('Ileum polyp(s)', 'Polyps', 'Polyp/s',9,'Colon', 0, 'DIPOLYPP3', 1)
GO


PRINT N'Altering Trigger [dbo].[TR_CommonAbnoLesions]...';


GO

ALTER TRIGGER [dbo].[TR_CommonAbnoLesions]
ON [dbo].[ERS_CommonAbnoLesions]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @Polyp VARCHAR(10) = 'False', 
						  @BenignTumour VARCHAR(10) = 'False', 
						  @MalignantTumour VARCHAR(10) = 'False', 
						  @SubmucosalTumour VARCHAR(10) = 'False', 
						  @FocalLesions VARCHAR(10) = 'False',
						  @SubmucoaslLesion VARCHAR(10) = 'False',
						  @FundicGlandPolyp VARCHAR(10) = 'False',
			@PolypTypeId int, @Region varchar(20), @ProcedureTypeId int, @MatrixCode varchar(50)
	
	IF EXISTS(SELECT * FROM INSERTED)
	BEGIN
		SELECT @site_id=SiteId,
				@Polyp = (CASE WHEN (ISNULL(Polyp,0) = 1) THEN 'True' ELSE 'False' END),
				@FocalLesions = (CASE WHEN (ISNULL(Focal,0) = 1) THEN 'True' ELSE 'False' END),
				@SubmucoaslLesion = (CASE WHEN (ISNULL(Submucosal,0) = 1) THEN 'True' ELSE 'False' END),
				@FundicGlandPolyp = (CASE WHEN (ISNULL(FundicGlandPolyp,0) = 1) THEN 'True' ELSE 'False' END),
				@PolypTypeId = PolypTypeId
				
		FROM INSERTED

		SELECT TOP 1 @ProcedureTypeId =  p.ProcedureType FROM ERS_Sites s INNER JOIN ERS_Procedures p ON p.ProcedureId = s.ProcedureId WHERE s.SiteId = @site_id
		--check if polyps = 1
		IF @Polyp = 'True' 
		BEGIN
			--check for polyp type
			DECLARE @PolypType VARCHAR(200) = (SELECT Description FROM ERS_PolypTypes WHERE UniqueId = @PolypTypeId)

			IF LOWER(@PolypType) = 'sessile'
			BEGIN
				--sessile polyps to produce a gastric tumour outcome depending on the tumour type
				IF EXISTS (SELECT 1 FROM ERS_CommonAbnoPolypDetails WHERE SiteId = @site_id AND Type = (SELECT UniqueId FROM ERS_TumourTypes WHERE Description = 'benign'))
					SET @BenignTumour = 'True'
				ELSE 
					SET @BenignTumour = 'False'

				IF EXISTS (SELECT 1 FROM ERS_CommonAbnoPolypDetails WHERE SiteId = @site_id AND Type = (SELECT UniqueId FROM ERS_TumourTypes WHERE Description = 'malignant'))
					SET @MalignantTumour = 'True'
				ELSE
					SET @MalignantTumour = 'False'
			END
			
			IF LOWER(@PolypType) = 'submucosal'  AND LOWER(@Region) = 'stomach'
				SET @SubmucoaslLesion = 'True'
			ELSE
				SET @SubmucoaslLesion = 'False'

		END
		
		IF @ProcedureTypeId IN (1,6,8)
		BEGIN
			SELECT @Region = dbo.fnSiteRegion(@site_id)

			IF LOWER(@Region) = 'stomach'
			BEGIN
				--SELECT @Polyp = CASE WHEN @FundicGlandPolyp = 'False' AND @BenignTumour = 'False' AND @MalignantTumour = 'False' AND @SubmucosalTumour = 'False' THEN 'True' ELSE 'False' END
				SET @MatrixCode = 'D40P1'
			END
			ELSE IF LOWER(@Region) = 'oesophagus'
				SET @MatrixCode = 'N2013'
			ELSE IF LOWER(@Region) = 'duodenum'
				SET @MatrixCode = 'D58P1'
			ELSE IF LOWER(@Region) = 'colon'
				SET @MatrixCode = 'D58P1'
				
		END
		ELSE IF @ProcedureTypeId IN (3,4,9)
		BEGIN
			SELECT @Region = dbo.fnSiteRegion(@site_id)

			IF @Polyp = 'True' AND @Region IN ('Rectum', 'Anal Margin')
				SET @MatrixCode = 'D4P3'

			IF @Polyp = 'True' AND @Region NOT IN ('Rectum', 'Anal Margin', 'Terminal Ileum')
				SET @MatrixCode = 'D12P3'

			IF @Polyp = 'True' AND @Region IN ('Terminal Ileum', 'Neo-Terminal Ileum')
				SET @MatrixCode = 'DIPOLYPP3'
		END

	END
	ELSE
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC abnormalities_common_lesions_summary_update @site_id

	IF @site_id IS NOT NULL AND @ProcedureTypeId IN (1,3,4,6,8,9)
	BEGIN
		EXEC sites_summary_update @site_id

		EXEC diagnoses_control_save @site_id, @MatrixCode, @Polyp		
		--EXEC diagnoses_control_save @site_id, 'D86P1', @BenignTumour	
		--EXEC diagnoses_control_save @site_id, 'D87P1', @MalignantTumour	
		EXEC diagnoses_control_save @site_id, 'N2001', @FocalLesions
		EXEC diagnoses_control_save @site_id, 'D88P1', @SubmucosalTumour
		EXEC diagnoses_control_save @site_id, 'N2002', @SubmucoaslLesion
		EXEC diagnoses_control_save @site_id, 'N2019', @FundicGlandPolyp

	END
GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 18.07.23
-- TFS#	2965
-- Description of change
-- 
------------------------------------------------------------------------------------------------------------------------
GO

EXEC dbo.DropIfExist @ObjectName = 'sch_get_list_slots',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE sch_get_list_slots
(
	@ListRulesId INT,
	@OperatingHostpitalId INT
)
AS
BEGIN
	SELECT row_number() OVER 
							(ORDER BY [ListSlotId]) LstSlotId, SlotId, esls.ProcedureTypeId, esls.ListRulesId, ISNULL(esls.Points,1) as Points, 
							ISNULL(esls.Suppressed, 0) AS Suppressed, ISNULL(esls.SlotMinutes ,15) AS [Minutes], 0 AS ParentId
	FROM [dbo].[ERS_SCH_ListSlots] esls
	INNER JOIN dbo.ERS_SCH_ListRules eslr ON esls.ListRulesId = eslr.ListRulesId
	WHERE esls.OperatingHospitalId = @OperatingHostpitalId
		AND esls.ListRulesId = @ListRulesId
		AND esls.Active = 1 
		AND ISNULL(esls.IsOverBookedSlot,0) = 0
	ORDER BY ListSlotId
END
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 18/07/23
-- TFS#	3020
-- Description of change
-- Edited lists update related appointments. 
-- Worklist endo taken from diry if appointment or record if worklist entry.
------------------------------------------------------------------------------------------------------------------------
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE  [dbo].[get_worklist_patients]
(
	@OperatingHospitalId INT,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@EndoscopistId INT = NULL
)
AS
BEGIN
	IF @StartDate IS NULL
	BEGIN
		SET @StartDate = convert(date, convert(varchar(10), GETDATE(), 102))
	END
	IF @EndDate IS NOT NULL
	BEGIN
		SELECT @EndDate = convert(date, convert(varchar(10), DATEADD(Day, 1, @EndDate), 102))
	END

	SELECT DISTINCT
		ea.AppointmentId AS UniqueId, 
		ea.BookingTypeId AS BookingTypeId,
		ep.Surname, 
		ep.Forename1 as Forename, 
		convert(char(10),ep.DateOfBirth,103) AS DOB, 
		isnull(ep.Title,'') as Title,
		UPPER(SUBSTRING(dbo.fnGender(ep.GenderId),1,1)) AS Gender,
		STUFF((SELECT DISTINCT ', '+ HospitalNumber from ERS_PatientTrusts where PatientId = ep.PatientId for xml path('')), 1, 2, '') AS HospitalNumber,
		ep.NHSNo,
		dbo.fnFullAddress(ep.Address1, ep.Address2, ep.Address3, ep.Address4, '') AS Address,
		isnull(ep.Postcode,'') as Postcode, 
		convert(char(10),ea.StartDateTime,103) as [Date], 
		eapt.ProcedureTypeID AS ProcedureTypeId,
		ept.ProcedureType,
		ep.PatientId,
		1 AS ERSPatient,
		ISNULL(dp.OperatingHospitalId, ea.OperationalHospitaId) as HospitalId,
		ea.StartDateTime,
		ea.TimeOfDay,
		CASE WHEN [as].HDCKEY IS NULL THEN 'Booked'
			 WHEN [as].HDCKEY = 'P' THEN 'Booked'
		ELSE [as].[Description]
		END as AppointmentStatus,
		[as].HDCKEY as AppointmentStatusHDCKEY,
		r.RoomName as RoomName, 
		r.RoomId as RoomId,
		ea.Notes as Alerts,
		ea.GeneralInformation as Notes,
		CASE WHEN ISNULL(ea.DiaryId, 0) = 0 THEN ea.EndoscopistId ELSE dp.UserID END EndoscopistId,
		eu.Title + ' ' + eu.Forename + ' ' + eu.Surname AS Endoscopist,
		CASE ISNULL(ea.TimeOfDay,'') WHEN '' THEN 0 WHEN 'AM' THEN 1 WHEN 'PM' THEN 2 WHEN 'Evening' THEN 3 END AS iTOD,
		CASE WHEN ea.BookingTypeId = 2 THEN CONVERT(varchar(5), ea.StartDateTime, 108) ELSE '' END AS AppointmentTime,
		ISNULL(pip.ProcedureCompleted,0) AS ProcedureCompleted,
		CASE WHEN pj.PatientAdmissionTime IS NULL THEN 0 ELSE 1 END PatientArrived,
		CONVERT(varchar(5), pj.PatientAdmissionTime, 108) as ArrivedTime,
		CONVERT(varchar(5), pj.ProcedureStartTime, 108) as InProgressTime,
		CONVERT(varchar(5), pj.ProcedureEndTime, 108) as RecoveryTime,
		CONVERT(varchar(5), pj.PatientDischargeTime, 108) as DischargeTime,
		CONVERT(varchar(5), ea.DueArrivalTime, 108) as CallInTime,
		ss.Description AS Category
	FROM  ERS_Appointments ea  
		LEFT JOIN dbo.ERS_Patients ep  ON ea.PatientId = ep.PatientId
		LEFT JOIN ERS_AppointmentStatus [as] ON EA.AppointmentStatusId = [as].UniqueId 
		LEFT JOIN ERS_AppointmentProcedureTypes eapt ON EA.AppointmentId = eapt.AppointmentID
		LEFT JOIN dbo.ERS_ProcedureTypes ept ON eapt.ProcedureTypeID = ept.ProcedureTypeId
		LEFT JOIN ERS_SCH_DiaryPages dp on ea.DiaryId = dp.DiaryId
		LEFT JOIN dbo.ERS_Users eu ON eu.UserID = CASE WHEN ISNULL(ea.DiaryId,0) = 0 THEN ea.EndoscopistId ELSE dp.UserId END 
		LEFT JOIN ERS_SCH_Rooms r on dp.RoomId = r.RoomId
		LEFT JOIN (SELECT ep.ProcedureId, ep.ProcedureType, ep.ProcedureCompleted, ep.PatientId, ep.CreatedOn
						FROM dbo.ERS_Procedures ep
					WHERE ep.IsActive= 1 
						AND ISNULL(ep.ProcedureCompleted,0) = 0 
						AND ep.OperatingHospitalID = @OperatingHospitalId
				  ) pip ON ea.PatientId = pip.PatientId AND ISNULL(eapt.ProcedureTypeId, pip.ProcedureType) = pip.ProcedureType
		LEFT JOIN ERS_PatientJourney pj on pj.PatientId = ep.PatientId AND pj.AppointmentId = ea.AppointmentId
		LEFT JOIN ERS_SCH_SlotStatus ss on ss.StatusId = ea.SlotStatusID
	WHERE ea.BookingTypeId IN (1, 2) /*1 = worklist, 2 = scheduler appointment*/
		AND ea.StartDateTime >= @StartDate 
		AND (@EndDate IS NULL OR ea.StartDateTime < @EndDate)
		AND (ea.IsDeleted IS NULL OR ea.IsDeleted = 0)
		AND (@EndoscopistId IS NULL OR CASE WHEN ISNULL(ea.DiaryId,0) = 0 THEN ea.EndoscopistId ELSE dp.UserId END = @EndoscopistId)
	order by ea.StartDateTime  
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sch_diary_page_save]
(
	@DiaryId int,
	@Subject VARCHAR(500), 
	@DiaryStart datetime, 
	@DiaryEnd datetime, 
	@RoomID int, 
	@UserID int, 
	@RecurrenceFrequency varchar(500) = NULL, 
	@RecurrenceCount int = NULL, 
	@RecurrenceDay varchar(500) = NULL, 
	@RecurrencePeriod int = NULL, 
	@RecurrenceParentID int = NULL, 
	@ListRulesId int = NULL,
	@Description varchar(500) = NULL,
	@OperatingHospitalId INT = NULL,
	@LoggedInUserId int,
	@Training bit,
	@ListConsultant INT = NULL,
	@ListGenderId int,
	@IsGI bit = 1
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
	if ISNULL(@DiaryId,0) = 0
	begin
		INSERT INTO [ERS_SCH_DiaryPages] 
		([Subject], [DiaryStart], [DiaryEnd], [RoomID], [UserID], [ListRulesId], [OperatingHospitalId], [RecurrenceFrequency], [RecurrenceCount], [RecurrenceDay], [RecurrencePeriod], [RecurrenceParentID], [WhoCreatedId], [WhenCreated], [Training], [ListConsultantId], ListGenderId, IsGI) 
		SELECT @Subject, @DiaryStart, @DiaryEnd, @RoomId, @UserID, @ListRulesId, @OperatingHospitalId, @RecurrenceFrequency, @RecurrenceCount, @RecurrenceDay, @RecurrencePeriod, @RecurrenceParentID, @LoggedInUserId, GETDATE(), Training, NULLIF(@ListConsultant, 0), @ListGenderId, @IsGI  FROM ERS_SCH_ListRules WHERE ListRulesId = @ListRulesId
		
		SELECT SCOPE_IDENTITY ()
	end
	else
	begin
		update ERS_SCH_DiaryPages
		set [Subject] = @Subject,
			ListGenderId = @ListGenderId,
			UserID = @UserID,
			ListConsultantId = NULLIF(@ListConsultant,0),
			DiaryStart = @DiaryStart,
			DiaryEnd = @DiaryEnd,
			Training = @Training,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = getdate()
		where DiaryId = @DiaryId

		IF EXISTS (SELECT 1 FROM ERS_Appointments WHERE DiaryId = @DiaryId)
			UPDATE dbo.ERS_Appointments SET EndoscopistId = @UserID WHERE DiaryId = @DiaryId

		SELECT @DiaryId
	end
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

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 18.07.23
-- TFS#	2620
-- Description of change
-- FIT value display
------------------------------------------------------------------------------------------------------------------------
GO

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
GO
ALTER FUNCTION [dbo].[ProcedureIndicationsSummary]
(
	@ProcedureId int
)
RETURNS varchar(max)
AS
BEGIN
/****************************************************
DS Fix bug 2754 12/04/2023
*****************************************************/
DECLARE @IndicationsString  varchar(max), @ComorbidityString varchar(max), @DamagingDrugsString varchar(max), @PatientAllergiesString varchar(max), @PreviousSurgeryString varchar(max), 
		@PreviousDiseasesString varchar(max), @FamilyDiseaseHistoryString varchar(max), @ImagingString varchar(max), @ImagingOutcomeString varchar(max),
		@RetVal varchar(max)

SELECT @IndicationsString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN i.AdditionalInfo = 0 THEN [Description] ELSE AdditionalInformation END + CASE WHEN ISNULL(ChildIndicationId, 0) > 0 THEN '-' + 
	(SELECT CASE WHEN i2.AdditionalInfo = 1 THEN [Description] + ': ' + epi.AdditionalInformation ELSE [Description] END FROM ERS_Indications i2 WHERE UniqueId = epi.ChildIndicationId) ELSE '' END AS [text()] 
	FROM ERS_ProcedureIndications epi 
	INNER JOIN ERS_Indications i on i.UniqueId = epi.IndicationId
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(i.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--rockall and baltchford scoring
SELECT @IndicationsString	= @IndicationsString + CASE WHEN CHARINDEX('melaena', @IndicationsString) > -1 OR CHARINDEX('haematemesis', @IndicationsString) > -1 THEN ' ' + dbo.fnBlatchfordRockallScores(@ProcedureId) ELSE '' END
--SELECT @IndicationsString = dbo.fnCapitalise(dbo.fnAddFullStop(@IndicationsString)) 

IF LEN(@IndicationsString) > 0
BEGIN
	IF charindex(',', reverse(@IndicationsString)) > 0
		SELECT @RetVal = STUFF(@IndicationsString, len(@IndicationsString) - (charindex(' ,', reverse(@IndicationsString)) - 1), 2, ' and ')
	ELSE
		SELECT @RetVal = @IndicationsString
END
-------------------CoMorbidity


SELECT @ComorbidityString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN AdditionalInformation = '' THEN [Description] ELSE AdditionalInformation END + CASE WHEN ISNULL(ChildComorbidityId, 0) > 0 THEN '-' + (SELECT [Description] FROM ERS_CoMorbidity WHERE UniqueId = ChildComorbidityId) ELSE '' END AS [text()] 
	FROM ERS_ProcedureComorbidity epc 
	INNER JOIN ERS_Comorbidity c on c.uniqueid = CoMorbidityId
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(c.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @ComorbidityString = dbo.fnCapitalise(dbo.fnAddFullStop(@ComorbidityString)) 

IF LEN(@ComorbidityString) > 0 
BEGIN
	IF charindex(',', reverse(@ComorbidityString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Co-morbidity: ' + STUFF(@ComorbidityString, len(@ComorbidityString) - charindex(' ,', reverse(@ComorbidityString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Co-morbidity: ' + @ComorbidityString
END

-------------------Damaging drugs

SELECT @DamagingDrugsString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ProcedureDamagingDrugs edd 
	INNER JOIN ERS_PotentialDamagingDrugs d on d.uniqueid = edd.DamagingDrugId
	WHERE edd.ProcedureId=@ProcedureId
	ORDER BY ISNULL(d.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @DamagingDrugsString = dbo.fnCapitalise(dbo.fnAddFullStop(@DamagingDrugsString)) 

DECLARE @AntiCoagDrugs bit = (SELECT AntiCoagDrugs FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
IF @AntiCoagDrugs IS NOT NULL
	If @AntiCoagDrugs = 1 SET @DamagingDrugsString = @DamagingDrugsString + '<br />The patient is taking anti-coagulant or anti-platelet medication.'

IF LEN(@DamagingDrugsString) > 0
BEGIN
	IF charindex(',', reverse(@DamagingDrugsString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Potential damaging drug(s): ' + STUFF(@DamagingDrugsString, len(@DamagingDrugsString) - charindex(' ,', reverse(@DamagingDrugsString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Potential damaging drug(s): ' + @DamagingDrugsString
END
-------------------Allergies

SELECT @PatientAllergiesString =
	CASE AllergyResult 
		WHEN -1 THEN 'unknown'
		WHEN 0 THEN 'none'
		WHEN 1 THEN a.AllergyDescription 
	END
	FROM ERS_PatientAllergies a
		INNER JOIN ERS_Procedures p ON p.PatientId = a.PatientId
	WHERE p.ProcedureId = @ProcedureId

--SELECT @PatientAllergiesString = dbo.fnCapitalise(dbo.fnAddFullStop(@PatientAllergiesString)) 

IF LEN(@PatientAllergiesString) > 0
BEGIN
	IF charindex(',', reverse(@PatientAllergiesString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Allergies: ' + STUFF(@PatientAllergiesString, len(@PatientAllergiesString) - charindex(' ,', reverse(@PatientAllergiesString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Allergies: ' + @PatientAllergiesString
END
-------------------Previous surgery

SELECT @PreviousSurgeryString =
	LTRIM(STUFF((SELECT DISTINCT ', ' + [Description] + CASE WHEN ListItemText = 'Unknown' THEN '' ELSE ' ' + ListItemText END as [text()] 
	FROM ERS_PatientPreviousSurgery h
	INNER JOIN ERS_PreviousSurgery r on r.UniqueID = h.PreviousSurgeryID
	INNER JOIN ERS_Lists l on l.ListItemNo = h.PreviousSurgeryPeriod and ListDescription = 'Follow up disease Period'
	INNER JOIN ERS_Procedures p on p.patientId = h.patientId 
	WHERE p.ProcedureId = @ProcedureId
	--ORDER BY ISNULL(r.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @PreviousSurgeryString = dbo.fnCapitalise(dbo.fnAddFullStop(@PreviousSurgeryString)) 

IF LEN(@PreviousSurgeryString) > 0
BEGIN
	IF charindex(',', reverse(@PreviousSurgeryString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous surgery: ' + STUFF(@PreviousSurgeryString, len(@PreviousSurgeryString) - charindex(' ,', reverse(@PreviousSurgeryString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous surgery: ' + @PreviousSurgeryString
END

-------------------ASA Status
DECLARE @ASAStatusString varchar(max) = 
	(SELECT [description]
	FROM ERS_PatientASAStatus pa 
		INNER JOIN ERS_ASAStatus a on a.uniqueid = pa.asastatusid
		INNER JOIN ERS_Procedures p ON p.ProcedureId = pa.ProcedureCreatedId
	WHERE   pa.ProcedureCreatedId = @ProcedureId)

If (@ASAStatusString is null) 
BEGIN
	SELECT TOP 1 @ASAStatusString = [description] 
						   FROM ERS_PatientASAStatus 
						   INNER JOIN ERS_ASAStatus ON UniqueId = ASAStatusId 
						   WHERE PatientId = (SELECT PatientId FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
						   ORDER BY ProcedureCreatedId DESC
END


IF LEN(@ASAStatusString) > 0 
BEGIN
	SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'ASA Status: ' + @ASAStatusString
END
-------------------Previous diseases

SELECT @PreviousDiseasesString =
	LTRIM(STUFF((SELECT DISTINCT ', ' + [Description] as [text()] 
	FROM ERS_PatientPreviousDiseases pd
	INNER JOIN ERS_PreviousDiseases d on d.UniqueID = pd.PreviousDiseaseID
	INNER JOIN ERS_Procedures p on p.patientId = pd.patientId 
	WHERE p.ProcedureId = @ProcedureId
	--ORDER BY ISNULL(r.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--SELECT @PreviousDiseasesString = dbo.fnCapitalise(dbo.fnAddFullStop(@PreviousDiseasesString)) 

IF LEN(@PreviousDiseasesString) > 0
BEGIN
	IF charindex(',', reverse(@PreviousDiseasesString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous diseases: ' + STUFF(@PreviousDiseasesString, len(@PreviousDiseasesString) - charindex(' ,', reverse(@PreviousDiseasesString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Previous diseases: ' + @PreviousDiseasesString
END

-------------------Family disease history

SELECT @FamilyDiseaseHistoryString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN AdditionalInformation = '' THEN [Description] ELSE AdditionalInformation END AS [text()] 
	FROM ERS_PatientFamilyDiseaseHistory epi 
	INNER JOIN ERS_FamilyDiseaseHistory i on i.UniqueId = epi.FamilyDiseaseHistoryId
	INNER JOIN ERS_Procedures p on p.patientId = epi.patientId 
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(i.ListOrderBy, 999)
	FOR XML PATH('')),1,1,''))

--SELECT @FamilyDiseaseHistoryString = dbo.fnCapitalise(dbo.fnAddFullStop(@FamilyDiseaseHistoryString)) 

IF LEN(@FamilyDiseaseHistoryString) > 0
BEGIN
	IF charindex(',', reverse(@FamilyDiseaseHistoryString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Family history: ' + STUFF(@FamilyDiseaseHistoryString, len(@FamilyDiseaseHistoryString) - charindex(' ,', reverse(@FamilyDiseaseHistoryString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Family history: ' + @FamilyDiseaseHistoryString
END


-------------------Imaging

SELECT @ImagingString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ImagingMethods im 
	INNER JOIN ERS_ProcedureImagingMethod pim on im.uniqueid = pim.ImagingMethodId
	WHERE pim.ProcedureId=@ProcedureId
	FOR XML PATH('')),1,1,''))


IF LEN(@ImagingString) > 0
BEGIN
	IF charindex(',', reverse(@ImagingString)) > 0
		SELECT @ImagingString = STUFF(@ImagingString, len(@ImagingString) - charindex(' ,', reverse(@ImagingString)), 2, ' and ')
END


SELECT @ImagingOutcomeString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ImagingOutcomes imo 
	INNER JOIN ERS_ProcedureImagingOutcome pio on imo.uniqueid = pio.ImagingOutcomeId
	WHERE pio.ProcedureId=@ProcedureId
	FOR XML PATH('')),1,1,''))

IF ISNULL(@ImagingOutcomeString,'') <> ''
BEGIN
	SELECT @ImagingString = CASE WHEN ISNULL(@ImagingString, '') <> '' THEN @ImagingString + ' revealed ' ELSE '' END  + @ImagingOutcomeString
END


--SELECT @ImagingString = dbo.fnCapitalise(dbo.fnAddFullStop(@ImagingString)) 

IF LEN(@ImagingString) > 0
BEGIN
	IF charindex(',', reverse(@ImagingString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Imaging: ' + STUFF(@ImagingString, len(@ImagingString) - charindex(' ,', reverse(@ImagingString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Imaging: ' + @ImagingString
END


DECLARE @SmokingString varchar(max)


SELECT @SmokingString=
	LTRIM(STUFF((SELECT '  ' +SmokingDescription   AS [text()] 
	FROM ERS_ProcedureSmoking epi 
	WHERE ProcedureId=@ProcedureId
	FOR XML PATH('')),1,1,''))

--SELECT @SmokingString = dbo.fnCapitalise(dbo.fnAddFullStop(@SmokingString)) 

IF LEN(@SmokingString) > 0
BEGIN
	IF charindex(',', reverse(@SmokingString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Smoking:</b> ' + @SmokingString
		--SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Smoking:</b> ' + STUFF(@SmokingString, len(@SmokingString) - charindex(' ,', reverse(@SmokingString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Smoking:</b> ' + @SmokingString
END

DECLARE @LUTSIPSSString varchar(max)
DECLARE @LUTSIPSSTotalScoreString varchar(max)

SELECT @LUTSIPSSString=
	LTRIM(STUFF((SELECT ', ' + SectionName+'(Score:'+cast(ls.ScoreValue as varchar(10)) +')'   AS [text()] 
	from  ERS_ProcedureLUTSIPSSSymptoms a ,ERS_LUTSIPSSSymptoms b,ERS_LUTSIPSSSymptomSections s,ERS_IPSSScore ls
	where ProcedureId=@ProcedureId and a.LUTSIPSSSymptomId=b.UniqueId and b.LUTSIPSSSymptomSectionId=s.LUTSIPSSSymptomSectionId and SelectedScoreId>1 and a.SelectedScoreId=ls.ScoreId
	FOR XML PATH('')),1,1,''))

--SELECT @LUTSIPSSString = dbo.fnCapitalise(dbo.fnAddFullStop(@LUTSIPSSString)) 

select top 1  @LUTSIPSSTotalScoreString =  'Total Score :' + cast(TotalScoreValue as varchar(10)) 
from  ERS_ProcedureLUTSIPSSSymptoms where ProcedureId=@ProcedureId
IF LEN(@LUTSIPSSString) > 0
BEGIN
	IF charindex(',', reverse(@LUTSIPSSString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>LUTS\IPSS symptom score:</b>' + STUFF(@LUTSIPSSString, len(@LUTSIPSSString) - charindex(' ,', reverse(@LUTSIPSSString)), 2,  ' ' + @LUTSIPSSTotalScoreString + ' '+'<br />')
	     
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>LUTS\IPSS symptom score:</b> ' + @LUTSIPSSString

	--SELECT @RetVal = ISNULL(@RetVal + '<br />', '') +  @LUTSIPSSTotalScoreString
END

DECLARE @PreviousDiseaseUrologyString varchar(max)

SELECT @PreviousDiseaseUrologyString=
	LTRIM(STUFF((SELECT ', ' +case 
       when a.Description='Other' then b.AdditionalInformation
	   else a.Description
	  end
   AS [text()] 
	from ERS_PreviousDiseasesUrology a, ERS_ProcedurePreviousDiseasesUrology b 
	where a.UniqueId=b.PreviousDiseaseId
	and b.ProcedureId=@ProcedureId
	order by PreviousDiseaseSectionId
	FOR XML PATH('')),1,1,''))

--SELECT @PreviousDiseaseUrologyString = dbo.fnCapitalise(dbo.fnAddFullStop(@PreviousDiseaseUrologyString)) 


IF LEN(@PreviousDiseaseUrologyString) > 0
BEGIN
	IF charindex(',', reverse(@PreviousDiseaseUrologyString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Past Urological Histrory:</b>' + STUFF(@PreviousDiseaseUrologyString, len(@PreviousDiseaseUrologyString) - charindex(' ,', reverse(@PreviousDiseaseUrologyString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Past Urological Histrory:</b> ' + @PreviousDiseaseUrologyString

	
END

DECLARE @UrineDipstickCytologyString varchar(max)

SELECT @UrineDipstickCytologyString=
	LTRIM(STUFF((SELECT ', ' + b.Description + ' '+c.Description 
   AS [text()] 
	from ERS_ProcedureUrineDipstickCytology a,ERS_UrineDipstickCytology b,ERS_UrineDipstickCytology c
	where a.ProcedureId=@ProcedureId
	and a.UrineDipstickCytologyId=b.UniqueId
	and a.ChildUrineDipstickCytologyId=c.UniqueId
	order by b.UrineDipstickCytologySectionId,b.ListOrderBy
	FOR XML PATH('')),1,1,''))

--SELECT @UrineDipstickCytologyString = dbo.fnCapitalise(dbo.fnAddFullStop(@UrineDipstickCytologyString)) 


IF LEN(@UrineDipstickCytologyString) > 0
BEGIN
	IF charindex(',', reverse(@UrineDipstickCytologyString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Urine Dipstick And Cytology:</b>' + STUFF(@UrineDipstickCytologyString, len(@UrineDipstickCytologyString) - charindex(' ,', reverse(@UrineDipstickCytologyString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Urine Dipstick And Cytology:</b>' + @UrineDipstickCytologyString

	
END


--------------Broncs referral data
DECLARE @BroncoReferralDataString varchar(max), @DateBronchRequested DATETIME,
		@DateOfReferral DATETIME,
		@LCaSuspectedBySpecialist BIT,
		@CTScanAvailable BIT,
		@DateOfScan DATETIME

	SELECT @DateBronchRequested=DateBronchRequested,
		   @DateOfReferral=DateOfReferral,
		   @LCaSuspectedBySpecialist=LCaSuspectedBySpecialist,
		   @CTScanAvailable=CTScanAvailable,
		   @DateOfScan=DateOfScan
	FROM ERS_ProcedureBronchoReferralData
	WHERE ProcedureId = @ProcedureId

	IF @DateBronchRequested IS NOT NULL SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Date bronchoscopy requested ' + CONVERT(VARCHAR, @DateBronchRequested, 105) + '. '
	IF @DateOfReferral IS NOT NULL SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Date of referral ' + CONVERT(VARCHAR, @DateOfReferral, 105) + '. '
	IF @LCaSuspectedBySpecialist = 1 SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Lung Ca suspected by lung Ca specialist' + '. '
	IF @CTScanAvailable = 1 SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'CT scan available prior to bronchoscopy' + '. '
	IF @DateOfScan IS NOT NULL SET @BroncoReferralDataString  = ISNULL(@BroncoReferralDataString,'') + 'Date of scan ' + CONVERT(VARCHAR, @DateOfScan, 105) + '. '
	

	IF @BroncoReferralDataString IS NOT NULL SET @BroncoReferralDataString = 'Referal Data (' + RTRIM(@BroncoReferralDataString )+ ')'
	ELSE SET @BroncoReferralDataString = ''
	
	IF LEN(@BroncoReferralDataString) > 0
	BEGIN
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + @BroncoReferralDataString
	END

--------------Broncs staging data
	DECLARE 
		@stagingsummary VARCHAR(2000),
		@tmpsummary VARCHAR(2000),
		@SuspectedLCa BIT,
		@StagingInvestigations BIT,
		@ClinicalGrounds BIT,
		@ImagingOfThorax BIT,
		@MediastinalSampling BIT,
		@Metastases BIT,
		@PleuralHistology BIT,
		@Bronchoscopy BIT,
		@Stage BIT,
		@StageT VARCHAR(20),
		@StageN VARCHAR(20),
		@StageM VARCHAR(20),
		@StageType VARCHAR(20),
		@StageDate DATETIME,
		@PerformanceStatus BIT,
		@PerformanceStatusType INT

	DECLARE @tblsummary TABLE (summary VARCHAR(500))

	SELECT 
		@SuspectedLCa = CASE 
							WHEN EXISTS (SELECT 1 FROM ERS_ProcedureIndications WHERE ProcedureId = @ProcedureId AND IndicationId = (SELECT UniqueId FROM ERS_Indications WHERE NEDTerm = 'Suspected lung cancer'))
							THEN 1
							ELSE 0
						END,
		@StagingInvestigations=StagingInvestigations,
		@ClinicalGrounds=ClinicalGrounds,
		@ImagingOfThorax=ImagingOfThorax,
		@MediastinalSampling=MediastinalSampling,
		@Metastases=Metastases,
		@PleuralHistology=PleuralHistology,
		@Bronchoscopy=Bronchoscopy,
		@Stage=Stage,
		@StageT=stageTNames.ListItemText,
		@StageN=stageNNames.ListItemText,
		@StageM=stageMNames.ListItemText,
		@StageType=stageTypes.ListItemText,
		@StageDate=StageDate,
		@PerformanceStatus=PerformanceStatus,
		@PerformanceStatusType=PerformanceStatusType
		
	FROM 
		ERS_ProcedureStaging p
	LEFT JOIN
		ERS_Lists stageTNames ON p.StageT = stageTNames.ListItemNo AND stageTNames.ListDescription = 'BronchoStageT'
	LEFT JOIN
		ERS_Lists stageNNames ON p.StageN = stageNNames.ListItemNo AND stageNNames.ListDescription = 'BronchoStageN'
	LEFT JOIN
		ERS_Lists stageMNames ON p.StageM = stageMNames.ListItemNo AND stageMNames.ListDescription = 'BronchoStageM'
	LEFT JOIN
		ERS_Lists stageTypes ON p.StageType = stageTypes.ListItemNo AND stageTypes.ListDescription = 'BronchoStageType'
	WHERE
		ProcedureId = @ProcedureId


	--IF @SuspectedLCa = 1
	--BEGIN
		IF @StagingInvestigations = 1 
		BEGIN
			DELETE FROM @tblsummary
			SET @tmpsummary = NULL

			IF @ClinicalGrounds = 1 INSERT INTO @tblsummary VALUES ('Clinical grounds only')
			IF @ImagingOfThorax = 1 INSERT INTO @tblsummary VALUES ('Cross sectional imaging of thorax')
			IF @MediastinalSampling = 1 INSERT INTO @tblsummary VALUES ('Mediastinal sampling')
			IF @Metastases = 1 INSERT INTO @tblsummary VALUES ('Diagnostic tests for metastases')
			IF @PleuralHistology = 1 INSERT INTO @tblsummary VALUES ('Pleural cytology / histology')
			IF @Bronchoscopy = 1 INSERT INTO @tblsummary VALUES ('Bronchoscopy')

			SELECT @tmpsummary = COALESCE(@tmpsummary + ', ', '') + summary
			FROM @tblsummary

			IF @tmpsummary IS NOT NULL SET @tmpsummary = 'Staging Investigations (' + @tmpsummary + ')'
			ELSE SET @tmpsummary = 'Staging Investigations'

			SET @stagingsummary = @tmpsummary
		END

		IF @Stage = 1
		BEGIN
			DELETE FROM @tblsummary
			SET @tmpsummary = NULL

			IF @StageT IS NOT NULL AND @StageT <> '' INSERT INTO @tblsummary VALUES (@StageT)
			IF @StageN IS NOT NULL AND @StageN <> '' INSERT INTO @tblsummary VALUES (@StageN)
			IF @StageM IS NOT NULL AND @StageM <> '' INSERT INTO @tblsummary VALUES (@StageM)
			IF @StageType IS NOT NULL AND @StageType <> '' INSERT INTO @tblsummary VALUES (@StageType)
			IF @StageDate IS NOT NULL INSERT INTO @tblsummary VALUES ('Date ' + CONVERT(VARCHAR, @StageDate, 105))

			SELECT @tmpsummary = COALESCE(@tmpsummary + ', ', '') + summary
			FROM @tblsummary

			IF @tmpsummary IS NOT NULL SET @tmpsummary = 'Stage (' + @tmpsummary + ')'
			ELSE SET @tmpsummary = 'Stage'

			IF @stagingsummary IS NOT NULL SET @stagingsummary = @stagingsummary + ' ' + @tmpsummary
			ELSE SET @stagingsummary = @tmpsummary
		END

		IF @PerformanceStatus = 1
		BEGIN
			SET @tmpsummary = 'Performance Status' + 
							CASE @PerformanceStatusType 
								WHEN 1 THEN ' (normal activity)'
								WHEN 2 THEN ' (able to carry out light work)'
								WHEN 3 THEN ' (unable to carry out any work)'
								WHEN 4 THEN ' (limited self care)'
								WHEN 5 THEN ' (completely disabled)'
								ELSE ' (none)'
							END

			IF @stagingsummary IS NOT NULL SET @stagingsummary = @stagingsummary + ' ' + @tmpsummary
			ELSE SET @stagingsummary = @tmpsummary
		END

		IF LEN(@stagingsummary) > 0
		BEGIN
			SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + @stagingsummary
		END
	--END

RETURN @RetVal
END

GO


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 19.07.23
-- TFS#	3026, 3020, 3028
-- Description of change
-- End date corrected for edited apointments
-- Related appointments endo changed when editing a list
-- Operating hospital set to use hospital id from the room
------------------------------------------------------------------------------------------------------------------------
GO


/****** Object:  StoredProcedure [dbo].[sch_diary_page_save]    Script Date: 19/07/2023 16:16:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sch_diary_page_save]
(
	@DiaryId int,
	@Subject VARCHAR(500), 
	@DiaryStart datetime, 
	@DiaryEnd datetime, 
	@RoomID int, 
	@UserID int, 
	@RecurrenceFrequency varchar(500) = NULL, 
	@RecurrenceCount int = NULL, 
	@RecurrenceDay varchar(500) = NULL, 
	@RecurrencePeriod int = NULL, 
	@RecurrenceParentID int = NULL, 
	@ListRulesId int = NULL,
	@Description varchar(500) = NULL,
	@OperatingHospitalId INT = NULL,
	@LoggedInUserId int,
	@Training bit,
	@ListConsultant INT = NULL,
	@ListGenderId int,
	@IsGI bit = 1
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
	if ISNULL(@DiaryId,0) = 0
	begin
		INSERT INTO [ERS_SCH_DiaryPages] 
		([Subject], [DiaryStart], [DiaryEnd], [RoomID], [UserID], [ListRulesId], [OperatingHospitalId], [RecurrenceFrequency], [RecurrenceCount], [RecurrenceDay], [RecurrencePeriod], [RecurrenceParentID], [WhoCreatedId], [WhenCreated], [Training], [ListConsultantId], ListGenderId, IsGI) 
		SELECT @Subject, @DiaryStart, @DiaryEnd, @RoomId, @UserID, @ListRulesId, (SELECT r.HospitalId FROM ERS_SCH_Rooms r WHERE r.RoomId = @RoomID), @RecurrenceFrequency, @RecurrenceCount, @RecurrenceDay, @RecurrencePeriod, @RecurrenceParentID, @LoggedInUserId, GETDATE(), Training, NULLIF(@ListConsultant, 0), @ListGenderId, @IsGI  FROM ERS_SCH_ListRules WHERE ListRulesId = @ListRulesId
		
		SELECT SCOPE_IDENTITY ()
	end
	else
	begin
		update ERS_SCH_DiaryPages
		set [Subject] = @Subject,
			ListGenderId = @ListGenderId,
			UserID = @UserID,
			ListConsultantId = NULLIF(@ListConsultant,0),
			DiaryStart = @DiaryStart,
			DiaryEnd = dbo.fnSCH_DiaryEnd(ListRulesId, @DiaryStart),
			Training = @Training,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = getdate()
		where DiaryId = @DiaryId

		
		IF EXISTS (SELECT 1 FROM ERS_Appointments WHERE DiaryId = @DiaryId)
			UPDATE dbo.ERS_Appointments SET EndoscopistId = @UserID WHERE DiaryId = @DiaryId

		SELECT @DiaryId
	end
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

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 20.07.23
-- TFS#	2618
-- Description of change
-- removed procedure id. was only checking if the current procedure had a healed ulcer
------------------------------------------------------------------------------------------------------------------------
GO

ALTER PROCEDURE [dbo].[ogd_previous_gastric_ulcer]
(
	@ProcedureId INT,
	@DisplayAlertOnly BIT,
	@OperatingHospitalId INT
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
	DECLARE	@PatientId INT = 0
			,@returnValue VARCHAR(500) = ''
			,@procDate DATETIME
			,@FollowUp BIT = 0

	SELECT @PatientId=PatientId, @procDate=CreatedOn FROM ERS_Procedures WHERE ProcedureId = @ProcedureId


	--Check for this procedure if Ulcer or Healing Ulcer has been entered
	IF EXISTS(SELECT 1
					FROM [ERS_UpperGIAbnoGastricUlcer] g
					JOIN ERS_Sites s ON s.SiteId = g.SiteId
					JOIN ERS_Procedures p ON p.ProcedureId = s.ProcedureId AND p.PatientId = @PatientId
					WHERE (HealingUlcer=1 OR NotHealed=1 OR HealedUlcer=1) AND p.IsActive = 1)
		SET @FollowUp = 1

	--If follow-up (Not Healed, Healing or Healed) = 1 -> has already been recorded, no need to display alert again
	--but patient had previous Ulcer

	IF @DisplayAlertOnly = 1 AND @FollowUp = 1 
		SELECT '' --Return empty string not to display alert 
	ELSE
	BEGIN
		CREATE TABLE #previousProc (regionName VARCHAR(100), procDate VARCHAR(25));

		--Check if patient had gastric ulcer previously
		INSERT INTO #previousProc
		SELECT  r.Region, CONVERT(VARCHAR(11),p.CreatedOn,106 )
		FROM ERS_UpperGIAbnoGastricUlcer g
		JOIN ERS_Sites s ON g.SiteId = s.SiteId
		JOIN ERS_Regions r ON s.RegionID = r.RegionId 
		JOIN ERS_Procedures p ON s.ProcedureId = p.ProcedureId 
						AND p.PatientId = @PatientId AND p.ProcedureId <> @ProcedureId AND p.CreatedOn <= @procDate AND p.IsActive = 1
		WHERE g.Ulcer = 1
		ORDER BY p.CreatedOn DESC

		IF (SELECT IncludeUGI FROM ERS_SystemConfig WHERE OperatingHospitalId=@OperatingHospitalId) = 1 
			DECLARE @sql nvarchar = '
			INSERT INTO #previousProc
			SELECT s.Region, CONVERT(VARCHAR(11),e.[Episode date],106 ) 
			FROM [AUpper GI Gastric Ulcer/Malignancy] a 
			JOIN Episode e ON a.[Episode No] = e.[Episode No] 
			JOIN [Upper GI Sites] s ON s.[Episode No] = e.[Episode No] 
			WHERE a.[Patient No] = (SELECT [Combo ID] FROM Patient WHERE [Patient No] = @PatientId)
			AND a.Ulcer = -1
			ORDER BY e.[Episode date] DESC'
			EXEC sp_executesql @sql

		IF (SELECT COUNT(*) FROM #previousProc) > 0
		BEGIN
			SELECT @returnValue = COALESCE(@returnValue + ', ', '') + ISNULL(LOWER(regionName),'') + ' on ' + procDate
			FROM #previousProc
			WHERE procDate IS NOT NULL
		END

		SET @returnValue = LTRIM(RTRIM(@returnValue))
		IF LEFT(@returnValue,2) = ', ' SET @returnValue = RIGHT(@returnValue, LEN(@returnValue) - 2)

		DROP TABLE #previousProc

		SELECT @returnValue
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


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO
Go
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Mahfuz	On 21 Jul 2023
-- TFS#	2864, 2859,2863,2865
-- Description of change
-- Dumfries Galloway - xml document - gender in patient search etc
------------------------------------------------------------------------------------------------------------------------
Go
--Adding SCIStoreGPId column in ERS_GPS table
IF Not EXISTS(SELECT * FROM sys.columns WHERE Name = N'SCIStoreGPId' AND Object_ID = Object_ID(N'ERS_GPS'))
Begin
Print 'Adding Column SCIStoreGPId from ERS_GPS table'
ALTER TABLE [dbo].[ERS_GPS]
   Add SCIStoreGPId varchar(100) null
End
GO

----Adding SCIStoreGPId column in ERS_GPS_Audit table
IF Not EXISTS(SELECT * FROM sys.columns WHERE Name = N'SCIStoreGPId' AND Object_ID = Object_ID(N'ERSAudit.ERS_GPS_Audit'))
Begin
Print 'Adding Column SCIStoreGPId from ERS_GPS_Audit table'
ALTER TABLE [ERSAudit].[ERS_GPS_Audit]
   Add SCIStoreGPId varchar(100) null
End
GO


--Adding SCIStorePracticeId column in ERS_Practices table
IF Not EXISTS(SELECT * FROM sys.columns WHERE Name = N'SCIStorePracticeId' AND Object_ID = Object_ID(N'ERS_Practices'))
Begin
Print 'Adding Column SCIStorePracticeId from ERS_Practices table'
ALTER TABLE [dbo].[ERS_Practices]
   Add SCIStorePracticeId varchar(100) null
End
GO

----Adding SCIStorePracticeId column in ERS_Practices_Audit table
IF Not EXISTS(SELECT * FROM sys.columns WHERE Name = N'SCIStorePracticeId' AND Object_ID = Object_ID(N'ERSAudit.ERS_Practices_Audit'))
Begin
Print 'Adding Column SCIStorePracticeId from ERS_Practices_Audit table'
ALTER TABLE [ERSAudit].[ERS_Practices_Audit]
   Add SCIStorePracticeId varchar(100) null
End
GO

--Adding SortOrder column in ERS_GenderTypes table
IF Not EXISTS(SELECT * FROM sys.columns WHERE Name = N'SortOrder' AND Object_ID = Object_ID(N'ERS_GenderTypes'))
Begin
Print 'Adding Column SortOrder from ERS_GenderTypes table'
ALTER TABLE [dbo].[ERS_GenderTypes]
   Add SortOrder Int null
End
GO

----Adding SortOrder column in ERS_GenderTypes_Audit table
IF Not EXISTS(SELECT * FROM sys.columns WHERE Name = N'SortOrder' AND Object_ID = Object_ID(N'ERSAudit.ERS_GenderTypes_Audit'))
Begin
Print 'Adding Column SortOrder from ERS_GenderTypes_Audit table'
ALTER TABLE [ERSAudit].[ERS_GenderTypes_Audit]
   Add SortOrder Int null
End
GO


Update ERS_GenderTypes
Set SortOrder = Case 
	when Code = 'M' then 1 
	When Code = 'F' then 2 
	when Code = 'U' then 3 
	when Code = 'N' then 4 
End

Go
Exec DropIfExist 'trg_ERS_Practices_Insert','TR'
/****** Object:  Trigger [dbo].[trg_ERS_Practices_Insert]    Script Date: 01/06/2023 15:43:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_ERS_Practices_Insert] 
							ON [dbo].[ERS_Practices] 
							AFTER INSERT
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_Practices_Audit] (PracticeID, tbl.[Code], tbl.[NationalCode], tbl.[Name], tbl.[Address1], tbl.[Address2], tbl.[Address3], tbl.[Address4], tbl.[PostCode], tbl.[TelNo], tbl.[FaxNo], tbl.[Email], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[ExternalCode], tbl.[Primary], tbl.[Local], tbl.[CCGId], tbl.[StartDate], tbl.[SCIStorePracticeId], LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.PracticeID , tbl.[Code], tbl.[NationalCode], tbl.[Name], tbl.[Address1], tbl.[Address2], tbl.[Address3], tbl.[Address4], tbl.[PostCode], tbl.[TelNo], tbl.[FaxNo], tbl.[Email], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[ExternalCode], tbl.[Primary], tbl.[Local], tbl.[CCGId], tbl.[StartDate],  tbl.[SCIStorePracticeId],1, GETDATE(), tbl.WhoCreatedId
							FROM inserted tbl
GO

ALTER TABLE [dbo].[ERS_Practices] ENABLE TRIGGER [trg_ERS_Practices_Insert]
GO

Exec DropIfExist 'trg_ERS_Practices_Update','TR'
GO

/****** Object:  Trigger [dbo].[trg_ERS_Practices_Update]    Script Date: 01/06/2023 15:48:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_ERS_Practices_Update] 
							ON [dbo].[ERS_Practices] 
							AFTER UPDATE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_Practices_Audit] (PracticeID, tbl.[Code], tbl.[NationalCode], tbl.[Name], tbl.[Address1], tbl.[Address2], tbl.[Address3], tbl.[Address4], tbl.[PostCode], tbl.[TelNo], tbl.[FaxNo], tbl.[Email], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[ExternalCode], tbl.[Primary], tbl.[Local], tbl.[CCGId], tbl.[StartDate],tbl.[SCIStorePracticeId],  LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.PracticeID , tbl.[Code], tbl.[NationalCode], tbl.[Name], tbl.[Address1], tbl.[Address2], tbl.[Address3], tbl.[Address4], tbl.[PostCode], tbl.[TelNo], tbl.[FaxNo], tbl.[Email], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[ExternalCode], tbl.[Primary], tbl.[Local], tbl.[CCGId], tbl.[StartDate],  tbl.[SCIStorePracticeId],2, GETDATE(), i.WhoUpdatedId
							FROM deleted tbl INNER JOIN inserted i ON tbl.PracticeID = i.PracticeID
GO

ALTER TABLE [dbo].[ERS_Practices] ENABLE TRIGGER [trg_ERS_Practices_Update]
GO


Exec DropIfExist 'trg_ERS_Practices_Delete','TR'
GO

/****** Object:  Trigger [dbo].[trg_ERS_Practices_Delete]    Script Date: 01/06/2023 15:49:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_ERS_Practices_Delete] 
							ON [dbo].[ERS_Practices] 
							AFTER DELETE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_Practices_Audit] (PracticeID, tbl.[Code], tbl.[NationalCode], tbl.[Name], tbl.[Address1], tbl.[Address2], tbl.[Address3], tbl.[Address4], tbl.[PostCode], tbl.[TelNo], tbl.[FaxNo], tbl.[Email], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[ExternalCode], tbl.[Primary], tbl.[Local], tbl.[CCGId], tbl.[StartDate],tbl.[SCIStorePracticeId],  LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.PracticeID , tbl.[Code], tbl.[NationalCode], tbl.[Name], tbl.[Address1], tbl.[Address2], tbl.[Address3], tbl.[Address4], tbl.[PostCode], tbl.[TelNo], tbl.[FaxNo], tbl.[Email], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[ExternalCode], tbl.[Primary], tbl.[Local], tbl.[CCGId], tbl.[StartDate],  tbl.[SCIStorePracticeId],3, GETDATE(), tbl.WhoUpdatedId
							FROM deleted tbl
GO

ALTER TABLE [dbo].[ERS_Practices] ENABLE TRIGGER [trg_ERS_Practices_Delete]
GO

Exec DropIfExist 'trg_ERS_GPS_Delete','TR'
/****** Object:  Trigger [dbo].[trg_ERS_Practices_Insert]    Script Date: 01/06/2023 15:43:54 ******/
SET ANSI_NULLS ON
GO

/****** Object:  Trigger [dbo].[trg_ERS_GPS_Delete]    Script Date: 01/06/2023 15:53:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_ERS_GPS_Delete] 
							ON [dbo].[ERS_GPS] 
							AFTER DELETE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_GPS_Audit] (GPId, tbl.[Code], tbl.[Title], tbl.[Initial], tbl.[Name], tbl.[TelNo], tbl.[Mobile], tbl.[Page], tbl.[Email], tbl.[NationalCode], tbl.[ExternalCode], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[CompleteName], tbl.[Comment], tbl.[Forename], tbl.[DateAdded], tbl.[Device], tbl.[Local],tbl.[SCIStoreGPId],  LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.GPId , tbl.[Code], tbl.[Title], tbl.[Initial], tbl.[Name], tbl.[TelNo], tbl.[Mobile], tbl.[Page], tbl.[Email], tbl.[NationalCode], tbl.[ExternalCode], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[CompleteName], tbl.[Comment], tbl.[Forename], tbl.[DateAdded], tbl.[Device], tbl.[Local],  tbl.[SCIStoreGPId],3, GETDATE(), tbl.WhoUpdatedId
							FROM deleted tbl
GO

ALTER TABLE [dbo].[ERS_GPS] ENABLE TRIGGER [trg_ERS_GPS_Delete]
GO


Exec DropIfExist 'trg_ERS_GPS_Insert','TR'
GO

/****** Object:  Trigger [dbo].[trg_ERS_GPS_Insert]    Script Date: 01/06/2023 15:55:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_ERS_GPS_Insert] 
							ON [dbo].[ERS_GPS] 
							AFTER INSERT
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_GPS_Audit] (GPId, tbl.[Code], tbl.[Title], tbl.[Initial], tbl.[Name], tbl.[TelNo], tbl.[Mobile], tbl.[Page], tbl.[Email], tbl.[NationalCode], tbl.[ExternalCode], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[CompleteName], tbl.[Comment], tbl.[Forename], tbl.[DateAdded], tbl.[Device], tbl.[Local], tbl.[SCIStoreGPId], LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.GPId , tbl.[Code], tbl.[Title], tbl.[Initial], tbl.[Name], tbl.[TelNo], tbl.[Mobile], tbl.[Page], tbl.[Email], tbl.[NationalCode], tbl.[ExternalCode], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[CompleteName], tbl.[Comment], tbl.[Forename], tbl.[DateAdded], tbl.[Device], tbl.[Local],  tbl.[SCIStoreGPId],1, GETDATE(), tbl.WhoCreatedId
							FROM inserted tbl
GO

ALTER TABLE [dbo].[ERS_GPS] ENABLE TRIGGER [trg_ERS_GPS_Insert]
GO

Exec DropIfExist 'trg_ERS_GPS_Update','TR'
GO

/****** Object:  Trigger [dbo].[trg_ERS_GPS_Update]    Script Date: 01/06/2023 15:56:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_ERS_GPS_Update] 
							ON [dbo].[ERS_GPS] 
							AFTER UPDATE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_GPS_Audit] (GPId, tbl.[Code], tbl.[Title], tbl.[Initial], tbl.[Name], tbl.[TelNo], tbl.[Mobile], tbl.[Page], tbl.[Email], tbl.[NationalCode], tbl.[ExternalCode], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[CompleteName], tbl.[Comment], tbl.[Forename], tbl.[DateAdded], tbl.[Device], tbl.[Local], tbl.[SCIStoreGPId], LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.GPId , tbl.[Code], tbl.[Title], tbl.[Initial], tbl.[Name], tbl.[TelNo], tbl.[Mobile], tbl.[Page], tbl.[Email], tbl.[NationalCode], tbl.[ExternalCode], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[CompleteName], tbl.[Comment], tbl.[Forename], tbl.[DateAdded], tbl.[Device], tbl.[Local],  tbl.[SCIStoreGPId],2, GETDATE(), i.WhoUpdatedId
							FROM deleted tbl INNER JOIN inserted i ON tbl.GPId = i.GPId
GO

ALTER TABLE [dbo].[ERS_GPS] ENABLE TRIGGER [trg_ERS_GPS_Update]
GO

EXEC DropIfExist 'InsertOrUpdateERS_GPS_FromSCIStore','S';
GO
CREATE PROCEDURE [dbo].[InsertOrUpdateERS_GPS_FromSCIStore]
(
	@GPId INT out,
	@Title VARCHAR(10),
	@Initial VARCHAR(10),
	@ForeName VARCHAR(100),
	@GPName VARCHAR(30),
	@Email VARCHAR(500),
	@Telephone VARCHAR(20),
	@LoggedInUserId INT,
	@SCIStoreGPId varchar(100)

)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
Set @GPId = 0

Select @GPId = Max(IsNull(GPId,0)) From ERS_GPS where SCIStoreGPId = @SCIStoreGPId

	IF @GPId IS NULL OR @GPId = 0
	BEGIN
		INSERT INTO [dbo].[ERS_GPS] (
			Title,
			Initial,
			[Code],
			[Name],
			ForeName,
			Email,
			TelNo,
			SCIStoreGPId,
			WhoCreatedId,
			WhenCreated)
		VALUES (
			@Title,
			@Initial,
			@SCIStoreGPId,
			@GPName,
			@ForeName,
			@Email,
			@Telephone,
			@SCIStoreGPId,
			@LoggedInUserId,
			GETDATE())

		SET @GPId = SCOPE_IDENTITY()
	END
	
	ELSE
	BEGIN
		UPDATE 
			[dbo].[ERS_GPS]
		SET 
			Title = @Title,
			Initial = @Initial,
			[Name] = @GPName,
			ForeName = @ForeName,
			Email = @Email,
			TelNo = @Telephone,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = getdate()
		WHERE 
			GPId = @GPId
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
Go

EXEC DropIfExist 'InsertOrUpdateERS_Practices_FromSCIStore','S';
GO
CREATE PROCEDURE [dbo].[InsertOrUpdateERS_Practices_FromSCIStore]
(
	@PracticeId INT output,
	@Code VARCHAR(6),
	@NationalCode VARCHAR(10),
	@Name VARCHAR(100),
	@Address1 VARCHAR(100),
	@Address2 VARCHAR(100),
	@Address3 VARCHAR(100),
	@Address4 VARCHAR(100),
	@Postcode VARCHAR(100),
	@TelNo VARCHAR(100),
	@Email VARCHAR(500),
	@LoggedInUserId INT,
	@SCIStorePracticeId varchar(100)

)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
Set @PracticeId = 0

Select @PracticeId = Max(IsNull(PracticeId,0)) From ERS_Practices where SCIStorePracticeId = @SCIStorePracticeId

	IF @PracticeId IS NULL OR @PracticeId = 0
	BEGIN
		INSERT INTO [dbo].[ERS_Practices] (
			Code,
			NationalCode,
			[Name],
			Address1,
			Address2,
			Address3,
			Address4,
			PostCode,
			TelNo,
			Email,
			SCIStorePracticeId,
			WhoCreatedId,
			WhenCreated)
		VALUES (
			@Code,
			@NationalCode,
			@Name,
			@Address1,
			@Address2,
			@Address3,
			@Address4,
			@Postcode,
			@TelNo,
			@Email,
			@SCIStorePracticeId,
			@LoggedInUserId,
			GETDATE())

		SET @PracticeId = SCOPE_IDENTITY()
	END
	
	ELSE
	BEGIN
		UPDATE 
			[dbo].[ERS_Practices]
		SET 
			Code = @Code,
			NationalCode = @NationalCode,
			[Name] = @Name,
			Address1 = @Address1,
			Address2 = @Address2,
			Address3 = @Address3,
			Address4 = @Address4,
			PostCode = @Postcode,
			TelNo = @TelNo,
			Email = @Email,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = getdate()
		WHERE 
			PracticeId = @PracticeId
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
Go

EXEC DropIfExist 'stp_InsertUpdatePatientFromWebservice','S';
GO
-- =============================================
-- Author:		Mahfuz
-- Create date: 10 Mar 2021
-- Description:	Insert or update patient table with patient data imported by Web Service (D&G SE upgrade)
-- 25 May 2021		:		Mahfuz fixed with GPId which is not in local Database
-- 25 May 2021		:		Mahfuz added additional parameter TrustId
-- 07 Jun 2023		:		MH added extra parameter PracticeId, changed internal structure as GPId and PracticeId will be passed through after processing outside
-- =============================================

CREATE PROCEDURE [dbo].[stp_InsertUpdatePatientFromWebservice]
(
	@PatientId INT=NULL,
	@CaseNoteNo VARCHAR(100),
	@Title VARCHAR(20),
	@Forename VARCHAR(100),
	@Surname NVARCHAR(100),
	@DateOfBirth DATETIME2,
	@NHSNo VARCHAR(20),
	@Address1 NVARCHAR(500),
	@Address2 NVARCHAR(500),
	@Town NVARCHAR(500),
	@County NVARCHAR(500),
	@PostCode VARCHAR(10),
	@PhoneNo VARCHAR(20),
	@Gender VARCHAR(1),
	@EthnicOrigin VARCHAR(100)=NULL,
	@JustDownloaded BIT=NULL,
	@Notes VARCHAR(200)=NULL,
	@District VARCHAR(50)=NULL,
	@DHACode NVARCHAR(20)=NULL,
	@GPId INT=NULL,
	@PracticeId int=NULL,
	@DateOfDeath DATETIME2=NULL,
	@AdvocateRequired BIT=NULL,
	@DateLastSeenAlive DATETIME2=NULL,
	@CauseOfDeath NVARCHAR(500)=NULL,
	@CodeForCauseOfDeath VARCHAR(100)=NULL,
	@CARelatedDeath BIT=NULL,
	@DeathWithinHospital BIT=NULL,
	@Hospitals INT=NULL,
	@ExtraReferral NVARCHAR(100)=NULL,
	@ConsultantNo INT=NULL,
	@HIVRisk INT=NULL,
	@OutcomeNotes NVARCHAR(100)=NULL,
	@UniqueHospitalId INT=NULL,
	@GPReferralFlag BIT=NULL,
	@OwnedBy VARCHAR(100)=NULL,
	@HasImages BIT=NULL,
	@VerificationStatus VARCHAR(4)=NULL,
	@LoggedInUserId INT,
	@MaritalStatus varchar(100)=null,
	@TrustId INT=NULL
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
       declare @intOurPatientID as int
	   declare @intMaritalStatusId as int

	   --Mahfuz added on 25 May 2021 -
	   If IsNull(@TrustId,0) = 0 or not exists(Select * from ERS_Trusts where TrustID = @TrustId)
	   begin
		Select top 1 @TrustId = TrustID from ERS_Trusts
	   end

	   ---------- Changed on 07 Jun 2023
	   /*
	   IF ISNULL(@GPId,0) <> 0 and NOT EXISTS(Select * from ERS_GPS where GPId = @GPId)
	   begin
		Set @GPId = 0
	   end

	   IF ISNULL(@GPId,0) = 0  SELECT @GPId = GPId  FROM dbo.ERS_GPS WHERE [Code] = 'G9999998'
	   --If not found
	   IF ISNULL(@GPId,0) = 0 
	   BEGIN
			--Check if they provided GP information
			If IsNull(@RegisteredGPName,'') <> '' And IsNull(@RegisteredGPCode,'') <> '' 
			Begin
					INSERT INTO ERS_GPS (Code, Name, [NationalCode], [ExternalCode]) 
						VALUES (@RegisteredGPCode, @RegisteredGPName, @RegisteredGPCode, @RegisteredGPCode)

						SET @GPId = @@IDENTITY
			End
			Else
			Begin
				INSERT INTO ERS_GPS (Code, Name, [NationalCode], [ExternalCode]) 
						VALUES ('G9999998', 'Not Stated', 'G9999998', 'G9999998')

						SET @GPId = @@IDENTITY
			End

	   END
	   */

	   if IsNull(@GPId,0) < 1 Or NOT EXISTS(Select * from ERS_GPS where GPId = @GPId) 
	   begin
		Set @GPId = null
	   end

	   if IsNull(@PracticeId,0) < 1 Or NOT EXISTS(Select * from ERS_Practices where PracticeId = @PracticeId) 
	   begin
		Set @PracticeId = null
	   end


	   -- Handling Marital Status - SCI Store has compact less word in Marital Status - i.e SCIStore has a word 'Married' whereas we have 'Married/Civil Partner'
	   Select top 1 @intMaritalStatusId = IsNull(MaritalId,0) from dbo.ERS_Marital_Status where [Status] = @MaritalStatus 
	   if IsNull(@intMaritalStatusId,0) = 0
	   begin
		Select top 1 @intMaritalStatusId = IsNull(MaritalId,0) from dbo.ERS_Marital_Status where [Status] Like Convert(varchar(max),@MaritalStatus + '%')
	   end
	   if IsNull(@intMaritalStatusId,0) = 0
	   begin
		Select top 1 @intMaritalStatusId = IsNull(MaritalId,0) from dbo.ERS_Marital_Status where [Status] = 'Unknown'
	   end
	   if IsNull(@intMaritalStatusId,0) = 0
	   begin
		Select top 1 @intMaritalStatusId = IsNull(MaritalId,0) from dbo.ERS_Marital_Status where [Status] = 'Not disclosed'
	   end

       -- When importing from SCI Store, we have SCI Store Patient Id which we save in AccountNumber column. So, gets our PatientID
	   -- from SCI Store patient ID stored in AccountNumber field

	   --1. First check with CHI no (our NHSNo) and Full Name and Date Of Birth
	   SELECT @intOurPatientID = PatientId FROM ERS_Patients WHERE Forename1 = @Forename and Surname = @Surname and NHSNo = @NHSNo and DateOfBirth=@DateOfBirth

	   
	   --2. Secondly check with CHI no and Date of Birth
	   IF ISNULL(@intOurPatientID,0)= 0
	   begin
	   SELECT @intOurPatientID = PatientId FROM ERS_Patients WHERE NHSNo = @NHSNo and DateOfBirth=@DateOfBirth
	   end

	   --3. Thirdly check with CHI no
	   IF ISNULL(@intOurPatientID,0)= 0
	   begin
	   SELECT @intOurPatientID = PatientId FROM ERS_Patients WHERE NHSNo = @NHSNo
	   end


	   --4 . Fourthly check with SCI Store PatientID in our AccountNumber field
	   IF ISNULL(@intOurPatientID,0)= 0
	   begin
	   SELECT @intOurPatientID = PatientId FROM ERS_Patients WHERE AccountNumber = Cast(@PatientId as varchar(max))
	   end

      

	IF ISNULL(@intOurPatientID,0)= 0
	BEGIN
		INSERT INTO ERS_Patients (
			HospitalNumber
			,[Title]
			,[Forename1]
			,[Surname]
			,[Dateofbirth]
			,[NHSNo]
			,[Address1]
			,[Address2]
			,[Address3]
			,[Address4]
			,[Postcode]
			,[Telephone]
			,[GenderId]
			,[EthnicId]
			,[MaritalId]
			,[RegGpId]
			,[RegGpPracticeId]
			,[Dateofdeath]
			,[WhoCreatedId]
			,[WhenCreated]
			,[CreateUpdateMethod]
			,[AccountNumber])
		VALUES (
			@CaseNoteNo,
			@Title,
			@Forename,
			@Surname,
			@DateOfBirth,
			@NHSNo,
			@Address1,
			@Address2,
			@Town,
			@County,
			@PostCode,
			@PhoneNo,
			(SELECT GenderId FROM ERS_GenderTypes WHERE Code = @Gender),
			(SELECT EthnicOriginId FROM ERS_EthnicOrigins WHERE EthnicOrigin = @EthnicOrigin),
			@intMaritalStatusId,
			@GPId,
			@PracticeId,
			@DateOfDeath,
			@LoggedInUserId,
			GETDATE(),
			'WSIMPORT',
			Cast(@PatientId as varchar(max)))
		SET @intOurPatientID = SCOPE_IDENTITY()

		--Mahfuz added on 25th May 2021
		Insert into ERS_PatientTrusts(PatientId,TrustId,HospitalNumber)
		Values(@intOurPatientID,@TrustId,@NHSNo)
	END
	ELSE
	BEGIN
		UPDATE 
			ERS_Patients
		SET 
			Title = @Title,
			Forename1 = @Forename,
			Surname = @Surname,
			[Dateofbirth] = @DateOfBirth,
			[NHSNo] = @NHSNo,
			[Address1] = @Address1,
			[Address2] = @Address2,
			[Address3] = @Town,
			[Address4] = @County,
			[Postcode] = @PostCode,
			[Telephone] = @PhoneNo,
			GenderId = (SELECT top 1 GenderId FROM ERS_GenderTypes WHERE Code = @Gender),
			[EthnicId] = (SELECT top 1 EthnicOriginId FROM ERS_EthnicOrigins WHERE EthnicOrigin = @EthnicOrigin),
			MaritalId = @intMaritalStatusId,
			RegGPId = @GPId,
			RegGpPracticeId = @PracticeId,
			[Dateofdeath] = @DateOfDeath,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = GETDATE(),
			CreateUpdateMethod = 'WSIMPORT'
		WHERE 
			[PatientId] = @intOurPatientID

			--Mahfuz Added on 25 May 2021
			if exists(Select * from ERS_PatientTrusts where PatientId = @intOurPatientID) 
			Begin
				Update ERS_PatientTrusts
				Set HospitalNumber = @NHSNo,
				TrustId = @TrustId
				Where PatientId = @intOurPatientID
			End
			else
			Begin
				Insert into ERS_PatientTrusts(PatientId,TrustId,HospitalNumber)
				Values(@intOurPatientID,@TrustId,@NHSNo)
			End

	END

	If IsNull(@GPId,0) > 0 and IsNull(@PracticeId,0) > 0 
	Begin
		If Not Exists(Select * from ERS_Practices_Link Where GPId = @GPId and PracticeId = @PracticeId) 
		Begin
			Insert into ERS_Practices_Link(GPId,PracticeId,IsPrimary,WhoCreatedId,WhenCreated)
			Values(@GPId,@PracticeId,1,@LoggedInUserId,getdate())
		End
	End

	SELECT @intOurPatientID
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
Go

EXEC DropIfExist 'usp_get_genders','S';
GO
CREATE PROCEDURE [dbo].[usp_get_genders]
AS
--MH created on 06 Jun 2023 - TFS #2864
BEGIN
	SELECT GenderId, Code, NHSType, Title, HL7Code 
	FROM ERS_GenderTypes
	Order by SortOrder asc

END
Go

EXEC DropIfExist 'startup_select','S';
GO
CREATE PROCEDURE [dbo].[startup_select] (
	@SearchString1 VARCHAR(500)			--CaseNoteNo
	,@SearchString2 VARCHAR(500)		--NHSNo
	,@SearchString3 VARCHAR(500)		--Surname
	,@SearchString4 VARCHAR(500)		--Forename
	,@SearchString5 VARCHAR(500)		--DOB
	,@SearchString6 VARCHAR(500)		--Address
	,@SearchString7 VARCHAR(500)		--Postcode
	,@searchGender Varchar(500)			--Gender
	,@SearchTab INT = 0					
	,@Condition VARCHAR(50) = ''		
	,@SearchType VARCHAR(50)
	,@ExcludeDeceased BIT = 0			--ExcludeDeadOption
	,@UserId INT						--UserId
	,@UserName NVARCHAR(500)			--UserName
	,@TrustId int )
AS
/*	Update History		:		07 Sept 2022 MH copied from SE1 - treat single quote in name, fix duplicate NHSNo (Isminor) etc 
						:		18 Nov 2022 MH implemented Soundex (pronounced like) search on Patient Surname and Forename TFS 2446
						:		06 Jun 2023 MH added search with Gender - Parameter value will be M, F, U or T or NULL/ ''
*/
DECLARE @Statement NVARCHAR(max)
DECLARE @Statement2 NVARCHAR(max)
DECLARE @SearchCriteria INT
	,@SearchCriteriaOption INT
	,@SearchCriteriaOptionPatientCount INT
	,@SearchCriteriaOptionDate DATETIME
	,@SearchCriteriaOptionMonths INT
	,@ExcludeDeadOption BIT
	,@ExcludeUGI BIT
	,@AllProcedures BIT
	,@Gastroscopy BIT
	,@ERCP BIT
	,@Colonoscopy BIT
	,@Proctoscopy BIT
	,@OutstandingCLO BIT
	,@OrderListOptions INT


--MH replaces single ' with '' in Surname and Forename variables.
Set @SearchString3 = Replace(@SearchString3,'''','''''')
Set @SearchString4 = Replace(@SearchString4,'''','''''')

IF EXISTS (SELECT 1 FROM ERS_StartupSettings WHERE ISNULL(UserId,0) = @UserId)
	SELECT TOP (1) @SearchCriteria = [SearchCriteria]
		,@SearchCriteriaOption = [SearchCriteriaOption]
		,@SearchCriteriaOptionPatientCount = [SearchCriteriaOptionPatientCount]
		,@SearchCriteriaOptionDate = [SearchCriteriaOptionDate]
		,@SearchCriteriaOptionMonths = [SearchCriteriaOptionMonths]
		,@ExcludeDeadOption = [ExcludeDeadOption]
		,@ExcludeUGI = [ExcludeUGI]
		,@AllProcedures = [AllProcedures]
		,@Gastroscopy = [Gastroscopy]
		,@ERCP = [ERCP]
		,@Colonoscopy = [Colonoscopy]
		,@Proctoscopy = [Proctoscopy]
		,@OutstandingCLO = [OutstandingCLO]
		,@OrderListOptions = [OrderListOptions]
	FROM [ERS_StartupSettings]
	WHERE UserID = @UserId
ELSE
	SELECT TOP (1) @SearchCriteria = [SearchCriteria]
	,@SearchCriteriaOption = [SearchCriteriaOption]
	,@SearchCriteriaOptionPatientCount = [SearchCriteriaOptionPatientCount]
	,@SearchCriteriaOptionDate = [SearchCriteriaOptionDate]
	,@SearchCriteriaOptionMonths = [SearchCriteriaOptionMonths]
	,@ExcludeDeadOption = [ExcludeDeadOption]
	,@ExcludeUGI = [ExcludeUGI]
	,@AllProcedures = [AllProcedures]
	,@Gastroscopy = [Gastroscopy]
	,@ERCP = [ERCP]
	,@Colonoscopy = [Colonoscopy]
	,@Proctoscopy = [Proctoscopy]
	,@OutstandingCLO = [OutstandingCLO]
	,@OrderListOptions = [OrderListOptions]
	FROM [ERS_StartupSettings]

DECLARE @SQLString VARCHAR(max)
	,@SelectStr VARCHAR(max)
	,@FromStr VARCHAR(500)
	,@FromStr2 VARCHAR(500)
	,@WhereStr VARCHAR(1000)
	,@WhereStr2 VARCHAR(1000)
	,@OrderStr VARCHAR(1000)

SET @SelectStr = 'SELECT DISTINCT	p.PatientId, 
									p.Forename1 + '' '' + p.Surname AS PatientName, 
									dbo.fnFullAddress(p.Address1, p.Address2, p.Address3, p.Address4, '''') as Address, 
									p.DateOfBirth AS DOB, 
									UPPER(SUBSTRING(dbo.fnGender(p.GenderId),1,1)) as Gender, 
									dbo.fnEthnicity(p.EthnicId) as Ethnicity, 
									CASE WHEN EXISTS (select TOP 1 HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId and IsMinor = 0) 
									 THEN STUFF((SELECT DISTINCT '',''+HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId and IsMinor = 0 for xml path('''')), 1, 1, '''')
									 ELSE STUFF((SELECT DISTINCT '',''+HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId and IsMinor = 1 for xml path('''')), 1, 1, '''')
								    END AS CaseNoteNo, 
									p.NHSNo, 
									p.DateAdded AS CreatedOn, 
									ISNULL(Deceased,0) AS Deceased,
									--ROW_NUMBER() OVER (ORDER BY p.PatientId) AS PatientRowId,
									p.PatientId AS PatientId, 
									NULL AS UGIPatientId,
									NULL AS ComboId,
									1 AS ERSPatient, 
									p.Title AS Title, 
									p.Forename1 AS Forename1, 
									p.Surname AS Surname, 
									dbo.fnGender(p.GenderId) AS Gender, 
									p.Forename1 + '' '' + p.Surname AS PatientName, 
									dbo.fnFullAddress(p.Address1, p.Address2, p.Address3, p.Address4, '''') AS Address, 
									p.PostCode,
									p.Telephone,
									p.DateOfBirth AS DateOfBirth, 
									CASE WHEN EXISTS (select TOP 1 HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId and IsMinor = 0) 
									 THEN STUFF((SELECT DISTINCT '',''+HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId and IsMinor = 0 for xml path('''')), 1, 1, '''')
									 ELSE STUFF((SELECT DISTINCT '',''+HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId and IsMinor = 1 for xml path('''')), 1, 1, '''')
								    END AS HospitalNumber,
									p.NHSNo AS NHSNo, 
									p.DateAdded AS DateAdded,
									p.DateUpdated AS DateUpdated,
									p.EthnicId AS EthnicId,
									p.DateOfDeath AS DateOfDeath,
									ISNULL(p.Deceased,0)  AS Deceased,
									p.CreateUpdateMethod'
SET @FromStr = ' FROM ERS_Patients p inner join  ERS_PatientTrusts pt on  p.PatientId = pt.PatientId Left join ERS_GenderTypes gt on p.GenderId = gt.GenderId'
SET @FromStr2 = ' FROM ERS_Patients p JOIN ERS_MergeJournal mj on p.PatientId = mj.MasterPatientId  Left join ERS_GenderTypes gt on p.GenderId = gt.GenderId'
SET @WhereStr = ''
SET @WhereStr2 = ''
SET @OrderStr = ' ORDER BY p.DateAdded DESC, p.PatientId  DESC'

IF @SearchCriteria = 1 OR @SearchTab IN (1, 2) --(@SearchCriteria=2 AND @SearchTab <> 0)
BEGIN
print 'searchtab = ' + convert(varchar, @SearchTab)
	IF @SearchTab = 1
	BEGIN
		IF @searchString1 IS NOT NULL AND @searchString1 <> ''
		BEGIN
			SET @WhereStr = (
					SELECT CASE @Condition
							WHEN 'ALL'
								THEN ' WHERE pt.HospitalNumber = ISNULL(''' + @SearchString1 + ''','''') OR NHSNo = ISNULL(''' + @SearchString1 + ''','''') OR Surname LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' OR Forename1 LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							WHEN 'Case note no.'
								THEN ' WHERE pt.HospitalNumber LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							WHEN 'NHS No'
								THEN ' WHERE REPLACE(NHSNo, '' '','''') LIKE ''%'' + ISNULL(''' + REPLACE(@SearchString1,' ', '') + ''','''') + ''%'' '
							WHEN 'Surname'
								THEN ' WHERE Surname LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							WHEN 'Forenames'
								THEN ' WHERE Forename1 LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							END
					)
			SET @WhereStr2 = (
					SELECT CASE @Condition
							WHEN 'ALL'
								THEN ' WHERE mj.SlaveExt LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' OR NHSNo = ISNULL(''' + @SearchString1 + ''','''') OR Surname LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' OR Forename1 LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							WHEN 'Case note no.'
								THEN ' WHERE mj.SlaveExt LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							WHEN 'NHS No'
								THEN ' WHERE REPLACE(NHSNo, '' '','''') = ISNULL(''' + REPLACE(@SearchString1,' ', '') + ''','''') '
							WHEN 'Surname'
								THEN ' WHERE Surname LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							WHEN 'Forenames'
								THEN ' WHERE Forename1 LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							END
					)
			
		END
	END
	ELSE
	BEGIN
		IF @SearchString1 IS NOT NULL AND @SearchString1 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' pt.HospitalNumber = ISNULL(''' + @SearchString1 + ''','''') '
			SET @WhereStr2 = @WhereStr2 + (
					SELECT CASE @WhereStr2
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' mj.SlaveExt LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
			print @WhereStr2
		END

		IF @SearchString2 IS NOT NULL AND @SearchString2 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' REPLACE(NHSNo,'' '', '''') = ISNULL(''' + REPLACE(@SearchString2, ' ', '') + ''','''') '
		END

		IF @SearchString3 IS NOT NULL AND @SearchString3 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' ((Surname LIKE ''%'' + ISNULL(''' + @SearchString3 + ''','''') + ''%'') Or Soundex(Surname) = Soundex(''' + @SearchString3 + '%'')) '
		END

		IF @SearchString4 IS NOT NULL AND @SearchString4 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' ((Forename1 LIKE ''%'' + ISNULL(''' + @SearchString4 + ''','''') + ''%'') Or Soundex(Forename1) = Soundex(''' + @SearchString4 + '%'')) '
		END

		IF @SearchString5 IS NOT NULL AND @SearchString5 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' DateOfBirth = '''' + ISNULL(''' + @SearchString5 + ''','''') + '''' '
		END

		IF @SearchString6 IS NOT NULL AND @SearchString6 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' LTRIM(RTRIM(Address)) LIKE ''%'' + ISNULL(''' + LTRIM(RTRIM(@SearchString6)) + ''','''') + ''%'' '
		END

		IF @SearchString7 IS NOT NULL AND @SearchString7 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition	END
					) + ' REPLACE(Postcode, '' '', '''') LIKE ''%'' + ISNULL(''' + REPLACE(@SearchString7, ' ', '') + ''','''') + ''%'' '
		END

		IF @searchGender IS NOT NULL AND @searchGender <> ''
		BEGIN
			if @searchGender = 'N'
			begin
				SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition	END
					) + ' (REPLACE(gt.Code, '' '', '''') = ISNULL(''' + REPLACE(@searchGender, ' ', '') + ''','''') Or gt.Code Is Null)'
			end
			else
			begin
				SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition	END
					) + ' REPLACE(gt.Code, '' '', '''') = ISNULL(''' + REPLACE(@searchGender, ' ', '') + ''','''') '
			end

			
		END

	END
	--Added For Trust Requirement
	SET @WhereStr = @WhereStr + ' AND pt.TrustId= ' + cast(@TrustId as varchar)
	
	IF @ExcludeDeceased = 1
		BEGIN
			IF @WhereStr <> ''
				SET @WhereStr = @WhereStr + ' AND ISNULL([Deceased],0) = 0'
			ELSE
				SET @WhereStr = 'WHERE ISNULL([Deceased],0) = 0'
		END

	--SET @SelectStr = @SelectStr + @FromStr
END
ELSE IF @SearchCriteria = 2
BEGIN
	--IF @AllProcedures = 1
	--BEGIN
		--IF @SearchCriteriaOption =1 SET @SelectStr = 'SELECT DISTINCT p.[Patient No] AS PatientId, p.Forename + '' '' + p.Surname AS PatientName, p.[Case note no] AS CaseNoteNo, p.[NHS No] AS NHSNo, p.[Record created] AS CreatedOn,p.[Surname] ,p.[Case note no] ,p.[Product ID] ,p.[Location ID] ,p.[Patient No] ,  p.[Has Images] ,p.[Just downloaded] ,p.[Forename] ,p.[Record created] ,p.[Combo ID] ,p.[NHS No] ,p.[Date of death]  FROM Patient p'
		IF @SearchCriteriaOption = 2 AND @SearchCriteriaOptionPatientCount > 0
			SET @SelectStr = 'SELECT TOP(' + CAST(@SearchCriteriaOptionPatientCount AS VARCHAR(50)) + ')  p.PatientId, p.Forename1 + '' '' + p.Surname AS PatientName, p.Address1 as Address, p.DateOfBirth AS DOB, UPPER(SUBSTRING(p.Gender,1,1)) as Gender, dbo.fnEthnicity(p.EthnicId) as Ethnicity, p.HospitalNumber AS CaseNoteNo, p.NHSNo, p.DateAdded AS CreatedOn, ISNULL(Deceased,0) AS Deceased (**) '
		ELSE IF @SearchCriteriaOption = 3 AND @SearchCriteriaOptionDate IS NOT NULL
			SET @WhereStr = 'WHERE DateAdded >= ''' + cast(@SearchCriteriaOptionDate AS VARCHAR(50)) + ''' '
		ELSE IF @SearchCriteriaOption = 4 AND @SearchCriteriaOptionMonths > 0
			SET @WhereStr = 'WHERE DateAdded >= DATEADD(MM,-' + CAST(@SearchCriteriaOptionMonths AS VARCHAR(50)) + ', GETDATE())'

		IF @ExcludeDeceased = 1
		BEGIN
			IF @WhereStr <> ''
				SET @WhereStr = @WhereStr + ' AND ISNULL([Deceased],0) = 0'
			ELSE
				SET @WhereStr = 'WHERE ISNULL([Deceased],0) = 0'
		END

		--SET @SelectStr = @SelectStr + @FromStr

END

IF @OrderListOptions = 2
	SET @OrderStr = ' ORDER BY [Surname], p.PatientId  DESC'

SET @Statement = @SelectStr + @FromStr + @WhereStr + @OrderStr
SET @Statement2 = @SelectStr + @FromStr + @WhereStr + ' union ' + @SelectStr + @FromStr2 + @WhereStr2 + @OrderStr

SET @Statement = (
					SELECT CASE @SearchType
							WHEN 'EQUALTO'
								THEN REPLACE(REPLACE(REPLACE(@Statement,'LIKE','='),'''%'' +',''),'+ ''%''','')
							WHEN 'STARTSWITH'
								THEN REPLACE(@Statement,'''%'' +','')
							WHEN 'ENDSWITH'
								THEN REPLACE(@Statement,'+ ''%''','')
							WHEN 'CONTAINS'
								THEN @Statement	
							END
					)
SET @Statement2 = (
					SELECT CASE @SearchType
							WHEN 'EQUALTO'
								THEN REPLACE(REPLACE(REPLACE(@Statement2,'LIKE','='),'''%'' +',''),'+ ''%''','')
							WHEN 'STARTSWITH'
								THEN REPLACE(@Statement2,'''%'' +','')
							WHEN 'ENDSWITH'
								THEN REPLACE(@Statement2,'+ ''%''','')
							WHEN 'CONTAINS'
								THEN @Statement2	
							END
					)

print @Statement

print @Statement2
IF ISNULL(@SearchString1, '') = ''
BEGIN
	EXEC sp_executesql @Statement
END
else
BEGIN
	EXEC sp_executesql @Statement2
END


DECLARE
	@sqlStringAudit NVARCHAR(MAX) = 'Searched: '

BEGIN

	IF @Condition <> '' 
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Search Condition: ' + ISNULL(@Condition, '') + '. '
	END

	IF @SearchString1 <> '' 
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Case Note No: ' + ISNULL(@SearchString1, '') + '. '
	END
	
	IF ISNULL(@SearchString2, '') <> ''
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'NHS No: ' + ISNULL(@SearchString2, '') + '. '
	END	

	IF ISNULL(@SearchString3, '') <> ''
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Surname: ' + ISNULL(@SearchString3, '') + '. '
	END

	IF ISNULL(@SearchString4, '') <> ''
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Forename: ' + ISNULL(@SearchString4, '') + '. '
	END

	IF ISNULL(@SearchString5, '') <> ''
	BEGIN	
		SET @sqlStringAudit = @sqlStringAudit + 'Date of Birth: ' + ISNULL(@SearchString5, '') + '. '
	END

	IF ISNULL(@SearchString6, '') <> ''
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Address: ' + ISNULL(@SearchString6, '') + '. '
	END

	IF ISNULL(@SearchString7, '') <> ''
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Postcode: ' + ISNULL(@SearchString7, '') + '. '
	END

	IF ISNULL(@searchGender, '') <> ''
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Gender: ' + ISNULL(@searchGender, '') + '. '
	END

	IF @ExcludeDeceased = 1
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Exclude Deceased: True. '
	END
	ELSE
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Exclude Deceased: False. '
	END

	BEGIN
	INSERT INTO ERS_UserActivityAudit
	(
		[UserID],
		[UserName],
		[Action],
		[ActionDetails],
		[PatientId],	
		[When]	
	)
	VALUES
	(
		@UserId,
		UPPER(@UserName),
		'SEARCH',
		@sqlStringAudit,
		NULL,
		GETDATE()
	)
	END
END
Go
------------------------------------------------------------------------------------------------------------------------
-- END OF -- TFS#	2864, 2859,2863,2865 by Mahfuz
------------------------------------------------------------------------------------------------------------------------
Go
Go
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Mahfuz	On 21 Jul 2023
-- TFS#	2989
-- Description of change
-- Gateway Web Api and integrate with SE 2 for xml doc transfer - D&G
------------------------------------------------------------------------------------------------------------------------
Go
--Check if column exists in a table
Print 'Adding Column ReportDocumentExportApiUrl to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ReportDocumentExportApiUrl' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [ReportDocumentExportApiUrl] varchar(2000) NULL;

GO

--Check if column exists in a table
Print 'Adding Column DocumentExportSharedLocation to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'DocumentExportSharedLocation' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [DocumentExportSharedLocation] varchar(2000) NULL;

GO


--Check if column exists in a table
Print 'Adding Column ReportSharedDriveAccessUser to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ReportSharedDriveAccessUser' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [ReportSharedDriveAccessUser] varchar(200) NULL;

GO


--Check if column exists in a table
Print 'Adding Column SharedDriveAccessUserPassword to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'SharedDriveAccessUserPassword' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [SharedDriveAccessUserPassword] varchar(20) NULL;

GO

--Check if column exists in a table
Print 'Adding Column DirectoryNameForXmlTransferInAzure to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'DirectoryNameForXmlTransferInAzure' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [DirectoryNameForXmlTransferInAzure] varchar(100) NULL;

GO

Go
EXEC DropIfExist 'uspGetProcedureSiteImagesAndDocumentsStoreData','S';
GO
CREATE PROCEDURE [dbo].[uspGetProcedureSiteImagesAndDocumentsStoreData]
(
	@ProcedureId AS INT
)
AS
BEGIN
	SET NOCOUNT ON;

/*
	21 April 2021		:		Mahfuz		created for PAS SE Upgrade for D&G

	test :			exec uspGetProcedureSiteImagesAndDocumentsStoreData 1576
*/

Create table #tempImageDocumentsData
(
	RecId int identity(1,1),
	PhotoName varchar(max),
	PhotoBlob varbinary(max),
	DateTimeStamp datetime,
	Region varchar(200),
	FileType varchar(50),
	DocumentVersion int,
	FileSizeInBytes int,
	CompressionMethod varchar(50),
	CompressedSizeInBytes int,
	TextEncodeMethod varchar(50),
	Base64TextContent varchar(max)
)

insert into #tempImageDocumentsData(PhotoName,PhotoBlob,DateTimeStamp,Region,FileType,DocumentVersion,FileSizeInBytes,CompressionMethod,CompressedSizeInBytes,TextEncodeMethod)
Select ph.PhotoName,ph.PhotoBlob,Ph.DateTimeStamp,r.Region, 'Image' as FileType,0 as DocumentVersion,
0 as FileSizeInBytes,'None' as CompressionMethod,0 as CompressedSizeInBytes,'Base64' as TextEncodeMethod
From ERS_Photos ph 
left join ERS_Sites s on ph.SiteId=s.SiteId
left join ERS_Regions r on s.RegionId=r.RegionId
Where ph.ProcedureId = @ProcedureId


declare @docVersion as int
declare @documentName as varchar(100)
set @docVersion = (Select count(*) from ERS_DocumentStore Where ProcedureId = @ProcedureId)

set @documentName = (Select pt.ReportHeader + 'Document_Ver_' + convert(varchar(5),@docVersion) + '.pdf' from ERS_Procedures p inner join ERS_ProcedureTypes pt on p.ProcedureType=pt.ProcedureTypeId Where ProcedureId=@ProcedureId)

insert into #tempImageDocumentsData(PhotoName,PhotoBlob,DateTimeStamp,Region,FileType,DocumentVersion,FileSizeInBytes,CompressionMethod,CompressedSizeInBytes,TextEncodeMethod,Base64TextContent)
Select top 1 @documentName as PhotoName,PDF as PhotoBlob,CreateDate as DateTimeStamp,'' as Region,'PDF' as FileType,@docVersion as DocumentVersion,
Len(PDF) as FileSizeInBytes,'None' as CompressionMethod,0 as CompressedSizeInBytes,'Base64' as TextEncodeMethod,
cast('' as xml).value('xs:base64Binary(sql:column("PDF"))', 'varchar(max)') as Base64TextContent
From ERS_DocumentStore Where ProcedureId = @ProcedureId 
Order by CreateDate desc


Select * from #tempImageDocumentsData

drop table #tempImageDocumentsData
END
Go
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	2989 by Mahfuz
------------------------------------------------------------------------------------------------------------------------
Go

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	
-- TFS#	
-- Description of change
-- 
------------------------------------------------------------------------------------------------------------------------
GO

ALTER PROCEDURE [dbo].[procedure_comorbidity_save]
(
	@ProcedureId int, 
	@ComorbidityId int, 
	@ChildComorbidityId int, 
	@Selected bit,
	@AdditionalInfo varchar(max),
	@LoggedInUserId int
)
AS
BEGIN
	IF @Selected = 1
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureComorbidity WHERE ComorbidityId = @ComorbidityId AND ProcedureId = @ProcedureId)
		BEGIN
			INSERT INTO [dbo].[ERS_ProcedureComorbidity] (ProcedureId, ComorbidityId, ChildComorbidityId, AdditionalInformation, WhoCreatedId, WhenCreated)
			VALUES (@ProcedureId, @ComorbidityId, @ChildComorbidityId, @AdditionalInfo, @LoggedInUserId, getdate())

			IF @ComorbidityId = (SELECT UniqueId FROM dbo.ERS_Comorbidity WHERE Description = 'None')
				DELETE FROM dbo.ERS_ProcedureComorbidity WHERE ProcedureId = @ProcedureId AND ComorbidityId <> @ComorbidityId
		END
		ELSE
		BEGIN
			UPDATE 
				ERS_ProcedureComorbidity 
			SET 
				ComorbidityId = @ComorbidityId,
				ChildComorbidityId = @ChildComorbidityId,
				AdditionalInformation = @AdditionalInfo,
				WhenUpdated = getdate(),
				WhoUpdatedId = @LoggedInUserId
			WHERE 
				ProcedureId = @ProcedureId AND ComorbidityId = @ComorbidityId 
		END
	END
	ELSE
	BEGIN
		DELETE FROM ERS_ProcedureComorbidity WHERE ProcedureId = @ProcedureId AND ComorbidityId = @ComorbidityId 
	END
	
	DECLARE @Summary VARCHAR(max) = dbo.ProcedureIndicationsSummary(@ProcedureId),
			@ComorbidityCount int = (SELECT count(*) FROM ERS_ProcedureComorbidity WHERE ProcedureId = @ProcedureId)

	EXEC UI_update_procedure_summary @ProcedureId, 'Comorbidity', @Summary, @ComorbidityCount

	UPDATE ERS_ProceduresReporting
	SET PP_Indic = @Summary
	WHERE ProcedureId = @ProcedureId
END
GO


ALTER PROCEDURE [dbo].[procedure_adverse_events_save] 
(
	@ProcedureId int, 
	@AdverseEventId int, 
	@ChildAdverseEventId int, 
	@Selected bit,
	@AdditionalInfo varchar(max),
	@LoggedInUserId int
)
AS
BEGIN
	IF @Selected = 1
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureAdverseEvents WHERE AdverseEventId = @AdverseEventId AND ProcedureId = @ProcedureId)
		BEGIN
			INSERT INTO [dbo].[ERS_ProcedureAdverseEvents] (ProcedureId, AdverseEventId, ChildAdverseEventId, AdditionalInformation, WhoCreatedId, WhenCreated)
			VALUES (@ProcedureId, @AdverseEventId, @ChildAdverseEventId, @AdditionalInfo, @LoggedInUserId, getdate())

			IF @AdverseEventId = (SELECT UniqueId FROM dbo.ERS_AdverseEvents WHERE NEDTerm = 'None')
				DELETE FROM dbo.ERS_ProcedureAdverseEvents WHERE ProcedureId = @ProcedureId AND AdverseEventId <> @AdverseEventId
		END
		ELSE
		BEGIN
			UPDATE 
				ERS_ProcedureAdverseEvents 
			SET 
				AdverseEventId = @AdverseEventId,
				ChildAdverseEventId = @ChildAdverseEventId,
				AdditionalInformation = @AdditionalInfo,
				WhoUpdatedId = @LoggedInUserId,
				WhenUpdated = getdate()
			WHERE 
				ProcedureId = @ProcedureId AND AdverseEventId = @AdverseEventId 
		END

		exec UI_update_procedure_summary   @ProcedureId, 'Adverse events', '', 1
	END
	ELSE
	BEGIN
		DELETE FROM ERS_ProcedureAdverseEvents WHERE ProcedureId = @ProcedureId AND AdverseEventId = @AdverseEventId 
	END


	/*Check if theres any indications that require child indications to be filled out NED requirement, upload will fail otherwise*/
	DECLARE @Summary varchar(200) = 'Adverse events:'

	IF (SELECT COUNT(*) 
	FROM 
		(SELECT ep.AdverseEventId, 
				ei.ParentId, 
				CASE WHEN ep.AdverseEventId IN (SELECT ParentId FROM dbo.ERS_AdverseEvents ei2) AND ISNULL(ep.ChildAdverseEventId,0) = 0 THEN 0 
					 WHEN ep.AdverseEventId IN (SELECT UniqueId FROM dbo.ERS_AdverseEvents ei2 WHERE ei2.AdditionalInfo = 1) AND ISNULL(ep.AdditionalInformation,'') = '' THEN 0 
					 ELSE 1 END 'Complete'
		FROM dbo.ERS_ProcedureAdverseEvents ep
			INNER JOIN dbo.ERS_AdverseEvents ei ON ei.UniqueId = ep.AdverseEventId
		WHERE procedureid = @ProcedureId) inds
	WHERE inds.Complete = 0) = 0
	BEGIN
		EXEC UI_update_procedure_summary @ProcedureId, 'Adverse events', @Summary, 1
	END
	ELSE
	BEGIN
		EXEC UI_update_procedure_summary @ProcedureId, 'Adverse events', @Summary, 0
	END


    EXEC procedure_summary_update @procedureID


END
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------




PRINT N'Altering Procedure [dbo].[sch_get_overlapping_bookings]...';


GO


ALTER PROCEDURE [dbo].[sch_get_overlapping_bookings]
(
	@DiaryId int,
	@AppointmentStart datetime,
	@AppointmentEnd datetime
)
AS
BEGIN
	SELECT AppointmentId, listslotid, StartDateTime, dateadd(minute, convert(int, AppointmentDuration), startdatetime) EndDateTime,AppointmentStatusId
	FROM ERS_Appointments 
	WHERE ISNULL(AppointmentStatusId,0) not in( dbo.fnSCHAppointmentStatusId('C'), dbo.fnSCHAppointmentStatusId('H')) AND
		  DiaryId = @DiaryId   AND (
		(@AppointmentStart >= StartDateTime AND @AppointmentStart < DATEADD(MINUTE, CONVERT(INT, AppointmentDuration), StartDateTime)) --start date is between appointment time
	OR	(@AppointmentEnd > StartDateTime AND @AppointmentEnd < DATEADD(MINUTE, CONVERT(INT, AppointmentDuration), StartDateTime)) --end date is between appointment time
	OR	(StartDateTime >= @AppointmentStart AND DATEADD(MINUTE, CONVERT(INT, AppointmentDuration), StartDateTime) <= @AppointmentEnd) --appointment is in between start and end times
	)

END
GO
PRINT N'Altering Procedure [dbo].[sch_get_user_day_diary]...';


GO

ALTER PROCEDURE dbo.sch_get_user_day_diary
(
	@DiaryDate DATETIME,
	@EndoscopistId INT
)
AS
BEGIN
	SELECT * FROM dbo.ERS_SCH_DiaryPages 
	WHERE (CONVERT(VARCHAR(10), DiaryStart, 103) = CONVERT(VARCHAR(10), @DiaryDate, 103)) AND (UserID = @EndoscopistId OR ListConsultantId = @EndoscopistId)
END
GO
PRINT N'Creating Procedure [dbo].[sch_get_overlapped_diaries]...';


GO

EXEC DropIfExist 'sch_get_overlapped_diaries','S'
GO

CREATE PROCEDURE sch_get_overlapped_diaries
(
	@UserId INT,
	@DiaryStart DATETIME,
	@DiaryEnd DATETIME
)
AS
BEGIN
	SELECT DiaryId, Subject, DiaryStart, DiaryEnd, RecurrenceRule,RoomID
	FROM dbo.ERS_SCH_DiaryPages 
	WHERE UserId = @UserId   AND (
		(@DiaryStart >= DiaryStart AND @DiaryStart < DiaryEnd) --start date is between appointment time
	OR	(@DiaryEnd > DiaryEnd AND @DiaryEnd < DiaryEnd) --end date is between appointment time
	OR	(DiaryStart >= @DiaryStart AND DiaryEnd <= @DiaryEnd) --appointment is in between start and end times
	)
END
GO
PRINT N'Creating Procedure [dbo].[sch_room_proceduretypes_select]...';


GO

EXEC DropIfExist 'sch_room_proceduretypes_select','S'
GO

CREATE PROCEDURE sch_room_proceduretypes_select
(
	@RoomId int
)
AS
BEGIN
	Select p.ProcedureTypeId, p.ProcedureType, ISNULL(r.RoomProcId,0) As RoomProcId 
	FROM [dbo].[ERS_ProcedureTypes] p 
            LEFT JOIN ERS_SCH_RoomProcedures r On p.ProcedureTypeId = r.ProcedureTypeId And r.RoomId = @RoomId
    WHERE p.SchedulerProc = 1
	UNION
	Select 99,'Other investigations', OtherInvestigations FROM ERS_SCH_Rooms WHERE RoomId = @RoomId
	UNION
	SELECT 99,'Other investigations', 0 WHERE @RoomId = 0
		ORDER BY p.ProcedureTypeId 

END
GO

-- MH Copying from release script 2.22.11.11 after discussing with Steve On 04 Aug 2023
GO
PRINT N'Creating [dbo].[ERS_ProcedureStaging]...';

GO
IF NOT EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID('ERS_ProcedureStaging'))
CREATE TABLE [dbo].[ERS_ProcedureStaging](
	[UniqueId] [int] IDENTITY(1,1) NOT NULL,
	[ProcedureId] [int] NOT NULL,
	[StagingInvestigations] [bit] NOT NULL,
	[ClinicalGrounds] [bit] NOT NULL,
	[ImagingOfThorax] [bit] NOT NULL,
	[PleuralHistology] [bit] NOT NULL,
	[MediastinalSampling] [bit] NOT NULL,
	[Metastases] [bit] NOT NULL,
	[Bronchoscopy] [bit] NOT NULL,
	[Stage] [bit] NOT NULL,
	[StageT] [int] NOT NULL,
	[StageN] [int] NOT NULL,
	[StageM] [int] NOT NULL,
	[StageType] [int] NOT NULL,
	[StageDate] [datetime] NULL,
	[PerformanceStatus] [bit] NOT NULL,
	[PerformanceStatusType] [int] NULL,
	[Suppressed] [bit] NOT NULL,
	[WhoCreatedId] [int] NULL,
	[WhenCreated] [datetime] NULL,
	[WhoUpdatedId] [int] NULL,
	[WhenUpdated] [datetime] NULL
	CONSTRAINT [PK_ERS_Staging] PRIMARY KEY CLUSTERED ([UniqueId] ASC)
) 
GO

GO
PRINT N'Creating [dbo].[procedure_staging_save]...';

GO
EXEC dbo.DropIfExist
	@ObjectName = 'procedure_staging_save',
	@ObjectTypePrefix = 'S'

GO
-- Create Procedure '[procedure_staging_save]'
CREATE PROCEDURE [dbo].[procedure_staging_save]
(
	@ProcedureId INT,@StagingInvestigations BIT,
	@ClinicalGrounds BIT,
	@ImagingOfThorax BIT,
	@MediastinalSampling BIT,
	@Metastases BIT,
	@PleuralHistology BIT,
	@Bronchoscopy BIT,
	@Stage BIT,
	@StageT INT,
	@StageN INT,
	@StageM INT,
	@StageType INT,
	@StageDate DATETIME,
	@PerformanceStatus BIT,
	@PerformanceStatusType INT,
	@Suppressed BIT,
	@LoggedInUserId INT

)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
			
	IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureStaging WHERE ProcedureId = @ProcedureId)
	BEGIN
		INSERT INTO ERS_ProcedureStaging (
			ProcedureId,StagingInvestigations,
			ClinicalGrounds,
			ImagingOfThorax,
			MediastinalSampling,
			Metastases,
			PleuralHistology,
			Bronchoscopy,
			Stage,
			StageT,
			StageN,
			StageM,
			StageType,
			StageDate,
			PerformanceStatus,
			PerformanceStatusType,
			Suppressed,
			WhoCreatedId,
			WhenCreated) 
		VALUES (
			@ProcedureId,
			@StagingInvestigations,
			@ClinicalGrounds,
			@ImagingOfThorax,
			@MediastinalSampling,
			@Metastases,
			@PleuralHistology,
			@Bronchoscopy,
			@Stage,
			@StageT,
			@StageN,
			@StageM,
			@StageType,
			@StageDate,
			@PerformanceStatus,
			@PerformanceStatusType,
			@Suppressed,
			@LoggedInUserId,
			GETDATE())
		
		-- Do we need to update the RecordCount ?
		--INSERT INTO ERS_RecordCount (
		--	[ProcedureId],
		--	[SiteId],
		--	[Identifier],
		--	[RecordCount]
		--)
		--VALUES (
		--	@ProcedureId,
		--	NULL,
		--	'Pathology',
		--	1)
	END
	
	ELSE
	BEGIN
		UPDATE 
			ERS_ProcedureStaging
		SET 
			StagingInvestigations = @StagingInvestigations,
			ClinicalGrounds = @ClinicalGrounds,
			ImagingOfThorax = @ImagingOfThorax,
			MediastinalSampling = @MediastinalSampling,
			Metastases = @Metastases,
			PleuralHistology = @PleuralHistology,
			Bronchoscopy = @Bronchoscopy,
			Stage = @Stage,
			StageT = @StageT,
			StageN = @StageN,
			StageM = @StageM,
			StageType = @StageType,
			StageDate = @StageDate,
			PerformanceStatus = @PerformanceStatus,
			PerformanceStatusType = @PerformanceStatusType,
			Suppressed = @Suppressed,
			WhoUpdatedId = @LoggedInUserId,
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
PRINT N'Creating [dbo].[procedure_staging_select]...';

GO
EXEC dbo.DropIfExist
	@ObjectName = 'procedure_staging_select',
	@ObjectTypePrefix = 'S'

GO
-- Create Procedure '[procedure_staging_select]'
CREATE PROCEDURE [dbo].[procedure_staging_select]
(
	@ProcedureId int
)
AS
BEGIN
	SELECT	ProcedureId,
			StagingInvestigations,
			ClinicalGrounds,
			ImagingOfThorax,
			MediastinalSampling,
			Metastases,
			PleuralHistology,
			Bronchoscopy,
			Stage,
			StageT,
			StageN,
			StageM,
			StageType,
			StageDate,
			PerformanceStatus,
			PerformanceStatusType,
			Suppressed,
			WhoCreatedId,
			WhenCreated,
			WhoUpdatedId,
			WhenUpdated
	FROM ERS_ProcedureStaging 
	WHERE ProcedureId = @ProcedureId
	  AND Suppressed = 0
END
GO

IF NOT EXISTS(SELECT 1 FROM dbo.ERS_IndicationsProcedureTypes WHERE IndicationId IN (SELECT UniqueId FROM dbo.ERS_Indications WHERE [Description] = 'Other') AND ProcedureTypeId = 10)
INSERT INTO dbo.ERS_IndicationsProcedureTypes
(
    IndicationId,
    ProcedureTypeId
)
(
	SELECT ei.UniqueId, 10 
	FROM dbo.ERS_Indications AS ei
	WHERE ei.Description = 'Other'
)

GO
Go
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Mahfuz	On 08 Aug 2023
-- TFS#	####
-- Description of change
-- TFS Task description
------------------------------------------------------------------------------------------------------------------------
Go

EXEC DropIfExist 'sch_list_lock_reasons_select','S';
GO
CREATE procedure [dbo].[sch_list_lock_reasons_select]
(
	@ShowSuppressed bit = null
)
as
begin
	SELECT ListLockReasonId, Reason, IsLockReason, IsUnlockReason, Suppressed FROM ERS_SCH_ListLockReasons  
	WHERE Suppressed = CASE WHEN ISNULL(@ShowSuppressed,1) = 1 THEN Suppressed ELSE 0 END
end
Go
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	#### by Mahfuz
------------------------------------------------------------------------------------------------------------------------
Go
Go
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Mahfuz	On 08 Aug 2023
-- TFS#	####
-- Description of change
-- TFS Task description
------------------------------------------------------------------------------------------------------------------------
Go

EXEC DropIfExist 'report_SCH_Activity','S';
GO
CREATE PROCEDURE [dbo].[report_SCH_Activity]
    @SearchStartDate AS DATE,
    @SearchEndDate AS DATE,
    @OperatingHospitalIds VARCHAR(100),
    @RoomIds VARCHAR(1000),
	@HideSuppressedConsultants BIT,
	@HideSuppressedEndoscopists BIT
AS
/***************************************************************************************************************************
--	Update History:
1.		14 Jan 2022		MH added OperatingHospital column in output TFS# 1841
2.		06 Jul 2022		AS improved performance
3.		12 Jul 2022		AS corrected data output
4.		01 Aug 2022		AS Bug fix: increased the size of the OperatingHospitals field in temporary table #ActivityDetails 
						as test data extended past 50 characters.
****************************************************************************************************************************/
BEGIN

SET NOCOUNT ON

    IF OBJECT_ID('tempdb..#ActivityDetails') IS NOT NULL
        DROP TABLE #ActivityDetails;
    IF OBJECT_ID('tempdb..#ListSlots') IS NOT NULL
        DROP TABLE #ListSlots;
    IF OBJECT_ID('tempdb..#Appointments') IS NOT NULL
        DROP TABLE #Appointments;
    IF OBJECT_ID('tempdb..#tmpOperatingHospitals') IS NOT NULL
        DROP TABLE #tmpOperatingHospitals;
    IF OBJECT_ID('tempdb..#tmpRooms') IS NOT NULL
        DROP TABLE #tmpRooms;
	IF OBJECT_ID('tempdb..#Total_Slots') IS NOT NULL
        DROP TABLE #Total_Slots;
	IF OBJECT_ID('tempdb..#No_Of_Patients') IS NOT NULL
        DROP TABLE #No_Of_Patients;		
	IF OBJECT_ID('tempdb..#No_Of_Patient_Pts_Used') IS NOT NULL
        DROP TABLE #No_Of_Patient_Pts_Used;

	CREATE TABLE #ListSLots
	(
		[Id] INT NOT NULL IDENTITY(1, 1),
        [DiaryIdSlotOrder] INT NULL,
        [ListSlotId] INT NULL,
        [ListRulesId] INT NULL,
        [SlotMinutes] INT NULL,
        [Points] INT NULL,
        [DiaryId] INT NULL,
        [StartTime] DATE NULL,
        [EndTime] DATE NULL,
        [Duration] INT NULL,
        [ApptOverFlow] INT NULL,
        [RoomId] INT NULL
	)
	
	CREATE NONCLUSTERED INDEX [IX_ListSlots_SlotMinutes]
		ON [dbo].[#ListSlots] ([DiaryId],[StartTime])
		INCLUDE ([SlotMinutes]);
	
	CREATE TABLE #Total_Slots
	(
	    [ListRulesId] INT NULL,
		[ListCount] INT NULL
	)
	
	INSERT INTO #Total_Slots
	( 
		ListRulesId,
		ListCount
	) 
	( 
		SELECT 
			ListRulesId, 
			COALESCE(COUNT(*), 0)
		FROM 
			dbo.ERS_SCH_ListSlots (NOLOCK) 
		GROUP BY 
			ListRulesId 
	)

	CREATE TABLE #No_Of_Patients
	(
	    [DiaryId] INT NULL,
		[ListCount] INT NULL
	)

	INSERT INTO #No_Of_Patients
	(
		DiaryId,
		ListCount
	)
    (
		SELECT 
			ea.DiaryId,
			COALESCE(COUNT(*), 0) 
		FROM
			dbo.ERS_Appointments AS ea (NOLOCK)
			INNER JOIN dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
				ON esdp.DiaryId = ea.DiaryId
		WHERE
			ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
			AND ea.DiaryId IS NOT NULL
		GROUP BY
			ea.DiaryId
	)
	
	CREATE TABLE #No_Of_Patient_Pts_Used
	(
	    [DiaryId] INT NULL,
		[ListCount] INT NULL
	)
		
	INSERT INTO #No_Of_Patient_Pts_Used
	(
		DiaryId,
		ListCount
	)
	(
		SELECT
			ea2.DiaryId,
			COALESCE(SUM(eapt.Points), 0) AS listCount
		FROM
			dbo.ERS_Appointments AS ea2 (NOLOCK)
			INNER JOIN dbo.ERS_AppointmentProcedureTypes AS eapt (NOLOCK)
				ON eapt.AppointmentID = ea2.AppointmentId
		WHERE
			ea2.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery			
		GROUP BY
			ea2.DiaryId
	) 
	
	CREATE TABLE #tmpOperatingHospitals
	(
	    [Id] INT NOT NULL,
		[Item] INT NOT NULL
	)

	INSERT INTO #tmpOperatingHospitals
	(
	    Id,
	    Item
	)
	(   
		SELECT
			Id,
			Item    
		FROM
			dbo.fnSplitString(ISNULL(@OperatingHospitalIds, ''), ',')
	)

	CREATE TABLE #tmpRooms
	(
	    [Id] INT NOT NULL,
		[Item] INT NOT NULL
	)
    
	INSERT INTO #tmpRooms
	(
	    Id,
	    Item
	)	
	(   
		SELECT
			Id,
			Item		
		FROM
			dbo.fnSplitString(ISNULL(@RoomIds, ''), ',')
	)

	CREATE TABLE #Appointments
	(
	    [Id] INT NOT NULL IDENTITY (1, 1),
		[OperatingHospital] VARCHAR(150) NOT NULL,
		[DiaryId] INT NOT NULL,
		[StartTime] DATETIME NOT NULL,
		[Duration] VARCHAR(100) NULL,
		[ListSlotId] INT
	)

	INSERT INTO #Appointments
	(
	    OperatingHospital,
	    DiaryId,
	    StartTime,
	    Duration,
		ListSlotId
	)
	(  
		SELECT			
			oh.HospitalName,
			ea.DiaryId,
			ea.StartDateTime,
			ea.AppointmentDuration,
			ea.ListSlotId
		FROM
			dbo.ERS_Appointments AS ea (NOLOCK)
			INNER JOIN dbo.ERS_OperatingHospitals oh (NOLOCK)
				ON ea.OperationalHospitaId = oh.OperatingHospitalId
		WHERE
			ea.DiaryId IS NOT NULL
			AND EXISTS
			(
				SELECT Item FROM #tmpOperatingHospitals AS toh
			)
			AND ea.StartDateTime BETWEEN @SearchStartDate AND @SearchEndDate	
			AND ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
	)
	
    DECLARE @counter INT = 0;
    DECLARE @ListSlotsTempTableCount INT = 0;

    INSERT INTO #ListSlots
	(
        [DiaryIdSlotOrder],
        [ListSlotId],
        [ListRulesId],
        [SlotMinutes],
        [Points],
        [DiaryId],
        [StartTime],
        [EndTime],
        [Duration],
        [ApptOverFlow],
        [RoomId]
	)
	SELECT
        0, 
        esls.ListSlotId, 
        esls.ListRulesId, 
        esls.SlotMinutes, 
        esls.Points, 
        esdp.DiaryId, 
        esdp.DiaryStart, 
        esdp.DiaryEnd,
        0, 
        0,
        esdp.RoomID
    FROM
        dbo.ERS_SCH_ListSlots AS esls (NOLOCK)
        LEFT JOIN dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
            ON esdp.ListRulesId = esls.ListRulesId
    WHERE
        esdp.DiaryId IS NOT NULL
		AND esdp.RoomID in
        (
            SELECT Item FROM #tmpRooms AS tr
        )
        AND esdp.DiaryStart
        BETWEEN @SearchStartDate AND @SearchEndDate

    ORDER BY
        esdp.DiaryId,
        esls.ListSlotId;

    SELECT
        @ListSlotsTempTableCount = @@ROWCOUNT;
		
    DECLARE @tempDiaryId INT = 0;
    DECLARE @currentRecordDiaryId INT = 0;
    DECLARE @newDiaryRecordFlag BIT = 0;
    DECLARE @currentRecordSlotMinutes INT = 0;
    DECLARE @currentRecordStartTime DATETIME;
    DECLARE @currentRecordEndTime DATETIME;
    DECLARE @previousRecordEndTime DATETIME;
    DECLARE @diaryIdSlotOrder INT = 0;

    SET @counter = 1;

    WHILE (@counter <= @ListSlotsTempTableCount)
    BEGIN
        SELECT
            @currentRecordDiaryId = DiaryId,
            @currentRecordSlotMinutes = SlotMinutes,
            @currentRecordStartTime = StartTime
        FROM
            #ListSlots
        WHERE
            Id = @counter;

        IF @tempDiaryId = 0
           OR @tempDiaryId <> @currentRecordDiaryId
        BEGIN
            SET @tempDiaryId = @currentRecordDiaryId;
            SET @newDiaryRecordFlag = 1;
            SET @diaryIdSlotOrder = 1;
        END;
        ELSE
        BEGIN
            SET @newDiaryRecordFlag = 0;
            SET @diaryIdSlotOrder = @diaryIdSlotOrder + 1;
        END;

        IF @newDiaryRecordFlag = 1
        BEGIN
            SET @currentRecordEndTime = DATEADD(MINUTE, @currentRecordSlotMinutes, @currentRecordStartTime);

            UPDATE
                #ListSlots
            SET
                EndTime = @currentRecordEndTime,
                DiaryIdSlotOrder = @diaryIdSlotOrder
            WHERE
                Id = @counter;
        END;
        ELSE IF @newDiaryRecordFlag = 0
        BEGIN
            SET @currentRecordStartTime = @previousRecordEndTime;
            SET @currentRecordEndTime = DATEADD(MINUTE, @currentRecordSlotMinutes, @currentRecordStartTime);

            UPDATE
                #ListSlots
            SET
                StartTime = @currentRecordStartTime,
                EndTime = @currentRecordEndTime,
                DiaryIdSlotOrder = @diaryIdSlotOrder
            FROM
                #ListSlots
            WHERE
                Id = @counter;
        END;

        SET @counter = @counter + 1;

        SET @previousRecordEndTime = @currentRecordEndTime;

    END;    

    UPDATE
        ls
    SET
        ls.Duration = a.Duration,
        ls.ApptOverFlow = a.Duration - ls.SlotMinutes
    FROM
        #ListSlots ls
        INNER JOIN #Appointments AS a
            ON a.DiaryId = ls.DiaryId and a.ListSlotId = ls.ListSlotId
               AND a.StartTime = ls.StartTime;

CREATE TABLE #ActivityDetails
(
    [DiaryId] INT NOT NULL,
	[OperatingHospital] VARCHAR(500) NULL,
	[RoomId] INT NULL,
	[Day] VARCHAR(10) NULL,
	[Date] DATE NULL,
	[Room] VARCHAR(50) NULL,
	[ListConsultant] VARCHAR(50) NULL,
	[Endoscopist] VARCHAR(50) NULL,
	[TemplateName] VARCHAR(75) NULL,
	[AM/PM] VARCHAR(2) NULL,
	[NoOfPtsOnTemplate] INT NULL,
	[NoOfPtsBooked] INT NULL,
	[NoOfPtsRemaining] INT NULL,
	[NoOfPatientsAttended] INT NULL,
	[NoOfPatientPointsUsed] INT NULL,		
	[ListLocked] VARCHAR(3) NULL,	
	[ReasonsLocked] VARCHAR(100) NULL,
	[ListUnlocked] VARCHAR(3) NULL,
	[ReasonsUnlocked] VARCHAR(100) NULL
)

INSERT INTO #ActivityDetails
(
    [DiaryId],
	[OperatingHospital],
	[RoomId],
	[Day],
	[Date],
	[Room],
	[ListConsultant],
	[Endoscopist],
	[TemplateName],
	[AM/PM],
	[NoOfPtsOnTemplate],
	[NoOfPtsBooked],
	[NoOfPtsRemaining],
	[NoOfPatientsAttended],
	[NoOfPatientPointsUsed],		
	[ListLocked],	
	[ReasonsLocked],
	[ListUnlocked],
	[ReasonsUnlocked]
)			   
(
	SELECT  
        ea.DiaryId AS [DiaryId],
		eoh.HospitalName AS [OperatingHospital],
		esr.RoomId AS [RoomId],
        FORMAT(ea.StartDateTime, 'ddd') AS [Day],        
        CONVERT(DATE, ea.StartDateTime, 106) AS [Date],        
        esr.RoomName AS [Room],
        CASE
            WHEN eu.IsListConsultant = 1 THEN
                LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)
            ELSE
                ''
        END AS [ListConsultant],
        CASE
            WHEN eu.IsEndoscopist1 = 1
                 OR eu.IsEndoscopist2 = 1 THEN
                LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)
            ELSE
                ''
        END AS [Endoscopist],
        eslr.ListName AS [TemplateName],
        CASE
            WHEN DATEPART(HH, ea.StartDateTime) < 12 THEN
                'AM'
            WHEN DATEPART(HH, ea.StartDateTime) < 17 THEN
                'PM'
            ELSE
                'EV'
        END AS [AM/PM],
        COALESCE(eslr.Points, 0) AS [NoOfPtsOnTemplate],
        COALESCE(esls.Points, 0) AS [NoOfPtsBooked],
		COALESCE(eslr.Points, 0) - COALESCE(esls.Points, 0) AS [NoOfPtsRemaining],
        COALESCE(no_of_patients.ListCount, 0) AS [NoOfPatientsAttended],
        COALESCE(no_of_patient_pts_used.ListCount, 0) AS [NoOfPatientPointsUsed],		
		'' AS [ListLocked],	
		'' AS [ReasonsLocked],
		'' AS [ListUnlocked],
		'' AS [ReasonsUnlocked]		    		    
    FROM
        dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
        INNER JOIN dbo.ERS_SCH_ListRules AS eslr (NOLOCK)
            ON esdp.ListRulesId = eslr.ListRulesId
        INNER JOIN dbo.ERS_SCH_ListSlots AS esls (NOLOCK)
            ON esdp.ListRulesId = esls.ListRulesId
        INNER JOIN dbo.ERS_Appointments AS ea (NOLOCK)
            ON esdp.DiaryId = ea.DiaryId AND ea.ListSlotId = esls.ListSlotId			
			AND ea.StartDateTime >= esdp.DiaryStart AND ea.StartDateTime <= esdp.DiaryEnd
			AND ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
        INNER JOIN dbo.ERS_SCH_Rooms AS esr (NOLOCK)
            ON esdp.RoomID = esr.RoomId
        LEFT JOIN dbo.ERS_Users AS eu (NOLOCK)
            ON ea.EndoscopistId = eu.UserID
		LEFT JOIN ERS_Users elc ON esdp.ListConsultantId = elc.UserID
        LEFT JOIN dbo.ERS_SCH_LockedDiaries AS esld (NOLOCK)
            ON esld.DiaryId = esdp.DiaryId 
			AND esld.DiaryId IS NOT NULL	
        LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS esdlr (NOLOCK)
            ON esdlr.DiaryLockReasonId = esld.LockedReasonId
		LEFT JOIN #No_Of_Patients AS no_of_patients
			ON no_of_patients.DiaryId = esdp.DiaryId 
		LEFT JOIN #No_Of_Patient_Pts_Used AS no_of_patient_pts_used
            ON no_of_patient_pts_used.DiaryId = esdp.DiaryId
		LEFT JOIN dbo.ERS_OperatingHospitals AS eoh (NOLOCK)
			ON eoh.OperatingHospitalId = esr.HospitalId
    WHERE
        esdp.OperatingHospitalId in 
        (
            SELECT Item FROM #tmpOperatingHospitals
        )
        AND esdp.RoomID in 
        (
            SELECT Item FROM #tmpRooms
        )
		
		AND eu.Suppressed = CASE WHEN @HideSuppressedEndoscopists = 1 THEN 0 ELSE eu.Suppressed END
		AND elc.Suppressed = CASE WHEN @HideSuppressedConsultants = 1 THEN 0 ELSE elc.Suppressed END
    GROUP BY
        ea.DiaryId,
		eoh.HospitalName,
        ea.StartDateTime,
        CASE
            WHEN DATEPART(HH, ea.StartDateTime) < 12 THEN
                'AM'
            WHEN DATEPART(HH, ea.StartDateTime) < 17 THEN
                'PM'
            ELSE
                'EV'
        END,
		esr.RoomId,
        esr.RoomName,
        eu.IsListConsultant,
        eu.IsEndoscopist1,
        eu.IsEndoscopist2,
        LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename),
        eslr.ListName,
        eslr.Points,
        esls.Points,
        no_of_patients.listCount,
        no_of_patient_pts_used.listCount,        
        ea.EndoscopistId
);
		
	WITH appointment_details AS
	(
		SELECT 
			ea.DiaryId, 
			ea.StartDateTime, 
			esdp.DiaryStart, 
			esdp.DiaryEnd, 
			esld.Locked, 
			diaryLockReason.IsLockReason,		
			diaryLockReason.Reason AS [LockReason],
			diaryUnlockReason.IsUnlockReason,
			diaryUnlockReason.Reason AS [UnlockReason]
		FROM 
			dbo.ERS_Appointments AS ea
			INNER JOIN dbo.ERS_SCH_DiaryPages AS esdp 
				ON ea.DiaryId = esdp.DiaryId
			INNER JOIN dbo.ERS_SCH_LockedDiaries AS esld
				ON esld.DiaryId = ea.DiaryId
			LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS diaryLockReason
				ON diaryLockReason.DiaryLockReasonId = esld.LockedReasonId
			LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS diaryUnlockReason
			ON diaryUnlockReason.DiaryLockReasonId = esld.UnlockedReasonId
		WHERE 
			ea.StartDateTime >= esdp.DiaryStart AND ea.StartDateTime <= esdp.DiaryEnd
			AND ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 )		
	)

	UPDATE
		#ActivityDetails
	SET
		#ActivityDetails.ListLocked = CASE WHEN appointment_details.Locked = 1 THEN 'YES' ELSE 'NO' END,
		#ActivityDetails.ReasonsLocked = CASE WHEN appointment_details.Locked = 1 THEN appointment_details.LockReason ELSE '' END,
		#ActivityDetails.ListUnlocked = CASE WHEN appointment_details.Locked = 0 THEN 'YES' ELSE 'NO' END,
		#ActivityDetails.ReasonsUnlocked = CASE WHEN appointment_details.Locked = 0 THEN appointment_details.UnlockReason ELSE '' END
	FROM
		appointment_details 
	WHERE
		#ActivityDetails.[DiaryId] = appointment_details.[DiaryId] 	

    SELECT
        [DiaryId],
		[OperatingHospital],
        [RoomId],
        [Day],
        [Date],
        [Room],
        [ListConsultant],
        [Endoscopist],
        [TemplateName],
        [AM/PM],
        [NoOfPtsOnTemplate],
        [NoOfPtsBooked],
		[NoOfPtsRemaining],
        [NoOfPatientsAttended],
        [NoOfPatientPointsUsed],
        [ListLocked],
        [ReasonsLocked],
        [ListUnlocked],
        [ReasonsUnlocked]
    FROM
        #ActivityDetails
    WHERE
        RoomId IS NOT NULL
    GROUP BY
        [DiaryId],
		[OperatingHospital],
        [Date],
        [AM/PM],
        [RoomId],
        [Room],
        [Day],
        [ListConsultant],
        [Endoscopist],
        [TemplateName],
        [NoOfPtsOnTemplate],
		[NoOfPtsBooked],
		[NoOfPtsRemaining],
        [NoOfPatientsAttended],
		[NoOfPatientPointsUsed],
        [ListLocked],
        [ReasonsLocked],
        [ListUnlocked],
        [ReasonsUnlocked]
    ORDER BY
        [Date] DESC;

END;
Go
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	#### by Mahfuz
------------------------------------------------------------------------------------------------------------------------
Go

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Steve 15/08/23
-- TFS#	3104
-- Description of change
-- (3104) Referred By on Report
--   Updated to show GP or Other if selected instead of a referring consultant or blank
------------------------------------------------------------------------------------------------------------------------

GO
PRINT N'Begining Updates for TFS# 3104';

GO
PRINT N'  Altering [dbo].[usp_Procedures_Insert]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'usp_Procedures_Insert',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
					 
GO

/****** Object:  StoredProcedure [dbo].[usp_Procedures_Insert]    Script Date: 14/08/2023 09:21:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Procedures_Insert]
(
	@ProcedureType		INT,
	--@PatientNo		VARCHAR(24),
	@PatientId			INT,
	@ProcedureDate		DATETIME,
	@ProcedureTime		VARCHAR(2),
	@PatientStatus		INT,
	@PatientWard		INT,
	@PatientType		INT,
	@OperatingHospitalId INT,
	@ListConsultant		INT,
	@Endoscopist1		INT,
	@Endoscopist2		INT,
	@Assistant			INT,
	@Nurse1				INT,
	@Nurse2				INT,
	@Nurse3				INT,
	@Nurse4				INT,
	@ReferralHospitalNo INT,
	@ReferralConsultantNo INT,
	@ReferralConsultantSpeciality INT,
	@PatientConsent		TINYINT,
	@DefaultCheckBox	BIT,
	@UserID				INT,
	@ProductType		TINYINT,
	@ListType			TINYINT,
	@Endo1Role			TINYINT,
	@Endo2Role			TINYINT,
	@CategoryListId		INT,
	@OnWaitingList		BIT,
	@OpenAccessProc		TINYINT,
	@EmergencyProcType	TINYINT,
	@NewProcedureId		INT OUTPUT,	-- This will return the newly created ProcedureId to the GUI! To play
	@ImagePortId		INT,
	@Points				DECIMAL,
	@ChecklistComplete	BIT,
	@ReferrerType		INT,
	@ReferrerTypeOther  VARCHAR(500),
	@ProviderId			INT,
	@ProviderOther		VARCHAR(500),
	@PatientNotes		BIT,
	@PatientReferralLetter	BIT,
	@ImageGenderID	int,
	@OrderId	int
)
AS

SET NOCOUNT ON

DECLARE @newProcId INT
DECLARE @ppEndos VARCHAR(2000), @GPName varchar(255), @GPAddress varchar(max), @Endo1 varchar(500), @Endo2 varchar(500), @RefCons varchar(50), @RefHosp varchar(50)

BEGIN TRANSACTION
--sp_help 'dbo.ERS_Procedures'
	BEGIN TRY
		INSERT INTO ERS_Procedures
			(ProcedureType,
			CreatedBy,	
			CreatedOn,			
			ModifiedOn,
			ProcedureTime,
			PatientId,
			CategoryListId,
			OnWaitingList,
			OpenAccessProc,
			EmergencyProcType,
			OperatingHospitalID,
			ListConsultant,
			Endoscopist1,
			Endoscopist2,
			Assistant,
			Nurse1,
			Nurse2,
			Nurse3,
			Nurse4,
			ReferralHospitalNo,
			ReferralConsultantNo,
			ReferralConsultantSpeciality,
			PatientStatus,
			Ward,
			PatientType,
			PatientConsent,
			ListType,
			Endo1Role,
			Endo2Role,
			ImagePortId,
			WhoCreatedId,
			WhenCreated,
			Points,
			ChecklistComplete,
			ReferrerType,
			ReferrerTypeOther,
			ProviderTypeId,
			ProviderOther,
			PatientNotes,
			PatientReferralLetter,
			ImageGenderID,
			OrderId)
		VALUES (
			@ProcedureType,
			@UserID,
			@ProcedureDate, --CASE WHEN CONVERT(DATE, GETDATE()) = @ProcedureDate THEN GETDATE() ELSE @ProcedureDate END, --Insert date and time if Procedure date is current date
			GETDATE(),
			@ProcedureTime,
			@PatientId,
			@CategoryListId,
			@OnWaitingList,
			@OpenAccessProc,
			@EmergencyProcType,
			@OperatingHospitalID,
			@ListConsultant,
			@Endoscopist1,
			@Endoscopist2,
			@Assistant,
			@Nurse1,
			@Nurse2,
			@Nurse3,
			@Nurse4,
			@ReferralHospitalNo,
			@ReferralConsultantNo,
			@ReferralConsultantSpeciality,
			@PatientStatus,
			@PatientWard,
			@PatientType,
			@PatientConsent, 
			@ListType,
			@Endo1Role,
			@Endo2Role,
			@ImagePortId,
			@UserID,
			GETDATE(),
			@Points,
			@ChecklistComplete,
			@ReferrerType,
			@ReferrerTypeOther,
			@ProviderId,
			@ProviderOther,
			@PatientNotes,
			@PatientReferralLetter,
			@ImageGenderID,
			@OrderId)

		SET @newProcId = SCOPE_IDENTITY();
	
		--## Important Work- Insert a Blank Record in the ERS_ProceduresReorting- with this Unique ID! So, you can simply Update the PP fields later..!! 
		INSERT INTO dbo.ERS_ProceduresReporting(ProcedureId)VALUES(@newProcId);

		SET @ppEndos = ''
		IF @ListConsultant > 0 SELECT @ppEndos = @ppEndos + '$$List Consultant: ' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @ListConsultant
		IF @Endoscopist1 > 0 
		BEGIN
			SELECT @Endo1 = Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Endoscopist1
			SELECT @ppEndos = @ppEndos + '$$Endoscopist No1: ' + @Endo1
			SELECT  @Endo1 = Title + ' ' + Forename + ' ' + Surname + 
					CASE WHEN isnull(Qualifications, '') != '' THEN ', ' + Qualifications else '' END + 
					CASE WHEN isnull(u.JobTitleID, 0) > 0 THEN CHAR(13)+CHAR(10) + jt.Description ELSE '' END  
			FROM ERS_Users u
			LEFT JOIN ERS_JobTitles jt on u.JobTitleID = jt.JobTitleID 
			WHERE UserID = @Endoscopist1
		END
		IF @Endoscopist2 > 0 
		BEGIN
			SELECT @Endo2 = Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Endoscopist2
			SELECT @ppEndos = @ppEndos + '$$Endoscopist No2: ' + @Endo2
			SELECT  @Endo2 = Title + ' ' + Forename + ' ' + Surname + 
					CASE WHEN isnull(Qualifications, '') != '' THEN ', ' + Qualifications else '' END + 
					CASE WHEN isnull(u.JobTitleID, 0) > 0 THEN CHAR(13)+CHAR(10) + jt.Description ELSE '' END  
			FROM ERS_Users u
			LEFT JOIN ERS_JobTitles jt on u.JobTitleID = jt.JobTitleID 		
			WHERE UserID = @Endoscopist2
		END
		IF @Nurse1 > 0 OR @Nurse2 > 0 OR @Nurse3 > 0 OR @Nurse4 > 0 
		BEGIN
			SELECT @ppEndos = @ppEndos + '$$' + 'Nurses: '
			IF @Nurse1 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse1
			IF @Nurse2 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse2
			IF @Nurse3 > 0 SELECT @ppEndos =  @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse3
			IF @Nurse4 > 0 SELECT @ppEndos =  @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse4
		END
		IF CHARINDEX('$$', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('$$', @ppEndos), 2, ''), '$$', '<br/>')
		IF CHARINDEX('##', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('##', @ppEndos), 2, ''), '##', '<br/>')
	
		SET @RefCons=''
		IF @ReferrerType = 1
		BEGIN
			SET @RefCons = 'GP'
		END
		ELSE IF @ReferrerType = 5
		BEGIN
			SET @RefCons = @ReferrerTypeOther
		END
		ELSE
		BEGIN
			SELECT @RefCons = ec.CompleteName FROM dbo.ERS_Consultant ec WHERE ec.ConsultantID = @ReferralConsultantNo
		END	
		--SELECT @GPName = p.[GP Name] , @GPAddress = p.[GP Address] FROM Patient p left join  ERS_Procedures pr ON p.[Patient No]= pr.PatientId WHERE pr.ProcedureId = @newProcId
		--SELECT @GPName = p.[GP Name] , @GPAddress = p.[GP Address] FROM ERS_Patients p WHERE p.[Patient No]= @PatientId

		SET @RefHosp = ''
		SELECT @RefHosp = rh.HospitalName FROM dbo.ERS_ReferralHospitals rh WHERE rh.HospitalID = @ReferralHospitalNo

		--Get GP practice name and address
		SELECT 	TOP 1 
			@GPName		= g.CompleteName,
			@GPAddress	= replace(dbo.fnFullAddress(ep.[Name], ep.Address1, ep.Address2, CASE WHEN ep.Address3 Is null THEN EP.Address4 ELSE ep.Address3 + ' ' + EP.Address4 END, ep.PostCode), ',', ', <br />')
		FROM ERS_Patients p 
		LEFT JOIN ERS_GPs g ON g.GPId = p.RegGpId
		LEFT JOIN dbo.ERS_Practices ep ON p.RegGpPracticeId = ep.PracticeID
		where p.PatientId = @PatientId 

		UPDATE ERS_ProceduresReporting SET PP_Endos = @ppEndos, PP_GPName = @GPName, PP_GPAddress = @GPAddress, PP_Endo1 = @Endo1, PP_Endo2 = @Endo2, PP_RefCons = @RefCons, PP_RefHosp = @RefHosp WHERE ProcedureId = @newProcId

		UPDATE ERS_Consultant SET SortOrder = ISNULL(SortOrder,0) + 1 WHERE ConsultantID = @ReferralConsultantNo

		EXEC procedure_summary_update @newProcId

		--SELECT @newProcId AS ProcedureId
		SELECT @NewProcedureId=@newProcId;

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


GO
PRINT N'Finished Updates for TFS# 3104';

GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	3104
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Steve 16/08/23
-- TFS#	2618
-- Description of change
-- SEv2 New gastric ulcer when one already excises 
--   Updated to include any new ulcer deatils on summary
------------------------------------------------------------------------------------------------------------------------
GO
PRINT N'Begining Updates for TFS# 2618';

GO
PRINT N'  Altering [dbo].[abnormalities_gastric_ulcer_summary_update]...';

GO
EXEC dbo.DropIfExist @ObjectName = 'abnormalities_gastric_ulcer_summary_update',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO

/****** Object:  StoredProcedure [dbo].[abnormalities_gastric_ulcer_summary_update]    Script Date: 16/08/2023 09:35:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[abnormalities_gastric_ulcer_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON
	DECLARE
		@SummaryItems TABLE (SummaryItem VARCHAR(300))
	DECLARE
		@mysummaryitem VARCHAR(300),
		@Summary VARCHAR(4000),
		@proc_date DATETIME,
		@patiend_id INT,
		@patient_combo_id VARCHAR(30),
		@None BIT,
		@Ulcer BIT,
		@UlcerType TINYINT,
		@UlcerNumber INT,
		@UlcerLargestDiameter DECIMAL(6,2),
		@UlcerActiveBleeding BIT,
		@UlcerActiveBleedingType TINYINT,
		@UlcerClotInBase BIT,
		@UlcerVisibleVessel BIT,
		@UlcerVisibleVesselType TINYINT,
		@UlcerOldBlood BIT,
		@UlcerMalignantApp BIT,
		@UlcerPerforation BIT,
		@HealingUlcer BIT,
		@HealingUlcerType TINYINT,
		@NotHealed BIT,
		@NotHealedText VARCHAR(1000),
		@HealedUlcer BIT,
		@PreviousUlcers VARCHAR(2000) = ''

	SELECT 
		@None=[None],
		@Ulcer=Ulcer,
		@UlcerType=UlcerType,
		@UlcerNumber=UlcerNumber,
		@UlcerLargestDiameter=UlcerLargestDiameter,
		@UlcerActiveBleeding=UlcerActiveBleeding,
		@UlcerActiveBleedingtype=UlcerActiveBleedingtype,
		@UlcerClotInBase=UlcerClotInBase,
		@UlcerVisibleVessel=UlcerVisibleVessel,
		@UlcerVisibleVesselType=UlcerVisibleVesselType,
		@UlcerOldBlood=UlcerOldBlood,
		@UlcerMalignantApp=UlcerMalignantAppearance,
		@UlcerPerforation=UlcerPerforation,
		@HealingUlcer=HealingUlcer,
		@HealingUlcerType=HealingUlcerType,
		@NotHealed = NotHealed,
		@NotHealedText = (SELECT isnull(NotHealedText, '') as [text()] FOR XML PATH('')),
		@HealedUlcer = HealedUlcer 
	FROM
		ERS_UpperGIAbnoGastricUlcer
	WHERE
		SiteId = @SiteId

	SET @mysummaryitem = ''
	SET @Summary = ''

	DECLARE @tmpPreviousGastricUlcer TABLE (retVal VARCHAR(2000))
	DECLARE @ProcedureID INT, @OperatingHospitalId INT

	SELECT @ProcedureID=ProcedureID FROM ERS_Sites WHERE SiteId = @SiteId
	SELECT  @OperatingHospitalId = OperatingHospitalID FROM ERS_Procedures WHERE ProcedureId = @ProcedureID

	INSERT INTO @tmpPreviousGastricUlcer EXEC ogd_previous_gastric_ulcer @ProcedureID, 0, @OperatingHospitalId
	SELECT @PreviousUlcers = retVal from @tmpPreviousGastricUlcer

	IF @PreviousUlcers <> ''
		SET @Summary = 'recorded previously in the ' + @PreviousUlcers + '. '
	
	--Build the current Gastric Ulcer summary
	IF @HealedUlcer = 1
	BEGIN
		IF @Summary <> ''
			SET @Summary = @Summary + 'Now healed'
		ELSE
			SET @Summary = @Summary + 'now healed'
	END

	ELSE IF @NotHealed = 1
	BEGIN
		IF @Summary <> ''
			SET @Summary = @Summary + 'Not healing'
		ELSE
			SET @Summary = @Summary + 'not healing'
		IF @NotHealedText <> '' SET @Summary = @Summary + '. ' + dbo.fnFirstLetterUpper(@NotHealedText)
	END

	ELSE IF @HealingUlcer = 1 
	BEGIN
		IF @Summary <> ''
			SET @Summary = @Summary + 'Now healing'
		ELSE
			SET @Summary = @Summary + 'now healing'

		IF @HealingUlcerType = 1
			SET @Summary = @Summary + ': early healing (regenerative mucosa evident)'
		ELSE IF @HealingUlcerType = 2
			SET @Summary = @Summary + ': advanced healing (almost complete re-epithelialisation)'
		ELSE IF @HealingUlcerType = 3
			SET @Summary = @Summary + ': "red scar" stage'
		ELSE IF @HealingUlcerType = 4
			SET @Summary = @Summary + ': ulcer scar deformity'
		ELSE IF @HealingUlcerType = 5
			SET @Summary = @Summary + ': atypical? early gastric cancer'
	END
	
	IF @None = 1
		SET @Summary = @Summary + 'No gastric ulcer'
	
	IF @Ulcer = 1 
	BEGIN
		IF @UlcerNumber > 0
			SET @mysummaryitem = @mysummaryitem + CONVERT(VARCHAR(20), @UlcerNumber) + ' '

		IF @UlcerType = 1
			SET @mysummaryitem = @mysummaryitem + 'acute'
		ELSE IF @UlcerType = 2
			SET @mysummaryitem = @mysummaryitem + 'chronic'

		IF @UlcerLargestDiameter > 0
		BEGIN
			IF @UlcerNumber > 1
				SET @mysummaryitem = @mysummaryitem + ' (largest diameter ' + CONVERT(VARCHAR(20), @UlcerLargestDiameter) + ' cm)'
			ELSE
				SET @mysummaryitem = @mysummaryitem + ' (diameter ' + CONVERT(VARCHAR(20), @UlcerLargestDiameter) + ' cm)'
		END

		IF @mysummaryitem <> '' INSERT INTO @SummaryItems VALUES (@mysummaryitem)
		ELSE INSERT INTO @SummaryItems VALUES ('ulcer found')   --('gastric ulcer')

		IF @UlcerActiveBleeding = 1
		BEGIN
			IF @UlcerActiveBleedingType = 1
				INSERT INTO @SummaryItems VALUES ('associated with active bleeding (spurting)')
			ELSE IF @UlcerActiveBleedingType = 2
				INSERT INTO @SummaryItems VALUES ('associated with active bleeding (oozing)')
			ELSE
				INSERT INTO @SummaryItems VALUES ('associated with active bleeding')
		END

		IF @UlcerClotInBase = 1
			INSERT INTO @SummaryItems VALUES ('associated with fresh clot in base')
		
		IF @UlcerVisibleVessel = 1
		BEGIN
			IF @UlcerVisibleVesselType = 1
				INSERT INTO @SummaryItems VALUES ('associated with visible vessel with adherent clot in base')
			ELSE IF @UlcerVisibleVesselType = 2
				INSERT INTO @SummaryItems VALUES ('associated with visible vessel with pigmented base')
			ELSE
				INSERT INTO @SummaryItems VALUES ('associated with visible vessel')
		END

		IF @UlcerOldBlood = 1
			INSERT INTO @SummaryItems VALUES ('associated with overlying old blood')

		IF @UlcerMalignantApp = 1
			INSERT INTO @SummaryItems VALUES ('associated with malignant appearance')

		IF @UlcerPerforation = 1
			INSERT INTO @SummaryItems VALUES ('associated with perforation')

		IF (SELECT COUNT(*) FROM @SummaryItems) > 1
		BEGIN
			-- Get the concatenated string separated by a delimiter, say $$
			SELECT @Summary = 
				COALESCE (
					CASE WHEN @Summary = '' THEN summaryitem
					ELSE @Summary + '$$' + summaryitem
					END
				,'')
			FROM @SummaryItems

			--TODO: Insert comma instead of and, between the items from first column and second column

			-- Set the last occurence of $$ to "and"
			SET @Summary = STUFF(@Summary, len(@Summary) - charindex('$$', reverse(@Summary)), 2, ' and ')

			-- Replace all other occurences of $$ with commas
			SET @Summary = REPLACE(@Summary, '$$', ', ')
		END
		ELSE
		BEGIN
			-- Get the only summary string
			SELECT @Summary = @Summary + summaryitem
			FROM @SummaryItems
		END
	END
	
	-- Finally update the summary in abnormalities table	
	UPDATE ERS_UpperGIAbnoGastricUlcer 
	SET Summary = RTRIM(@Summary)
	WHERE SiteId = @siteId

-------------------------------------------------------------------------------------------------------------

GO
PRINT N'Finished Updates for TFS# 2618';

GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	2618
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Steve 17/08/23
-- TFS#	3109
-- Description of change
-- Planned Extent & Completion  
--   Updated to check if reached extent is equal to or exceeds the planned extent.
------------------------------------------------------------------------------------------------------------------------
GO
PRINT N'Begining Updates for TFS# 3109';

GO
PRINT N'  Altering [dbo].[procedure_upper_extent_save]...';

GO
EXEC dbo.DropIfExist @ObjectName = 'procedure_upper_extent_save',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO
/****** Object:  StoredProcedure [dbo].[procedure_upper_extent_save]    Script Date: 17/08/2023 08:04:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procedure_upper_extent_save]
(
	@ProcedureId int,
	@ExtentId int,
	@AdditionalInfo varchar(max),
	@EndoscopistId int,
	@JManoeuvreId int, 
	@LimitedById int, 
	@WithdrawalMins int,
	@LimitationOther varchar(max),
	@LoggedInUserId int
)
AS
/*
--	Update History
01.			04 Jan 2023		MH added Order Message Send block while saving Extent of Intubation TFS #2475
							No extra parameter required. ProcedureId will have associated OrderId and Extent Limited By value
02.			21 March 2023	AJ j manouver handled if -1 (not specified)
03.			27 March 2023	AJ Set sections as not entered based on the extent reached
04.			08 June 2023	SG Add call to ogd_diagnoses_summary_update to ensure report gets populated with Normal if no abnormalities are added
							
*/
BEGIN
	Declare @bitHasProcedureFailed as bit
	Set @bitHasProcedureFailed = 0

	IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureUpperExtent WHERE ProcedureId = @ProcedureId AND EndoscopistId = @EndoscopistId)
	BEGIN
		INSERT INTO ERS_ProcedureUpperExtent (ProcedureId, ExtentId, AdditionalInfo, EndoscopistId, JManoeuvreId, LimitationId, WhoUpdatedId, WhenUpdated, LimitationOther)
		VALUES (@ProcedureId, NULLIF(@ExtentId,0), NULLIF(@AdditionalInfo,''), @EndoscopistId, NULLIF(@JManoeuvreId,-1), NULLIF(@LimitedById,0), @LoggedInUserId, getdate(), NULLIF(@LimitationOther,''))
	END
	ELSE
	BEGIN

		/*Check if new values been added for limitations */
		IF ISNULL(@LimitationOther,'') <> ''
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM dbo.ERS_Limitations WHERE Description = @LimitationOther)
			BEGIN
				/*get and set the new items order id so it appears 1 above 'other' we always want other to be last*/

				DECLARE @OtherListOrderBy_l int = (SELECT ListOrderBy FROM ERS_Limitations WHERE Description = 'Other')
				INSERT INTO ERS_Limitations (Description, NEDTerm, ListOrderBy) VALUES (@LimitationOther, 'Other', @OtherListOrderBy_l)
			
				UPDATE dbo.ERS_Limitations SET ListOrderBy = @OtherListOrderBy_l + 1 WHERE Description = 'Other'
		

			SELECT @LimitedById = UniqueId FROM ERS_Limitations WHERE Description = @LimitationOther
		
			DECLARE @ProcTypeId int = (SELECT ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
			INSERT INTO ERS_LimitationProcedureTypes (ProcedureTypeId, LimitationId) VALUES (@ProcTypeId, @LimitedById)
			END
			ELSE
				SELECT @LimitedById = UniqueId FROM ERS_Limitations WHERE Description = @LimitationOther
		END 

		UPDATE ERS_ProcedureUpperExtent
		SET 
			ExtentId = NULLIF(@ExtentId,0),
			AdditionalInfo = NULLIF(@AdditionalInfo,''),
			EndoscopistId = @EndoscopistId,
			JManoeuvreId = NULLIF(@JManoeuvreId,-1),
			LimitationId = NULLIF(@LimitedById,0),
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = getdate(),
			LimitationOther = NULLIF(@LimitationOther,'')
		WHERE 
			ProcedureId = @ProcedureId AND
			EndoscopistId = @EndoscopistId
	END

	DECLARE @SectionId int, @ProceureTypeId int, @ExtentIsSuccess bit, @ExtentDescription varchar(200), @SummaryText varchar(max) = ''
	SELECT @SectionID = UISectionId FROM UI_Sections WHERE SectionName = 'Extent'

	SELECT @ProceureTypeId = ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureId
	
	/*Furthest extent*/
	SELECT TOP 1 @ExtentDescription = ee.Description, @AdditionalInfo = epue.AdditionalInfo, @ExtentIsSuccess = ee.IsSuccess
								FROM dbo.ERS_ProcedureUpperExtent epue 
									INNER JOIN dbo.ERS_Extent ee ON epue.ExtentId = ee.UniqueId
								WHERE epue.ProcedureId=@ProcedureId
								ORDER BY ee.ListOrderBy DESC
	
	/*Handle failed procedures*/
	IF @ExtentDescription IN ('intubation failed','abandoned')
	Begin
		EXEC diagnoses_set_procedure_failed @ProcedureId
		Set @bitHasProcedureFailed = 1
	End

	IF (SELECT COUNT(*) FROM ERS_ProcedureUpperExtent WHERE ProcedureId = @ProcedureId AND NULLIF(JManoeuvreId,-1) IS NOT NULL) > 0
	BEGIN
		DECLARE @JManouvreResult varchar(100)

		/*Overall JManouvre result regardless of who done it, was it done*/
		IF EXISTS (SELECT 1 FROM ERS_ProcedureUpperExtent WHERE ProcedureId = @ProcedureId AND ISNULL(JManoeuvreId,0) = 1)
			SET @JManouvreResult = 'performed. '
		ELSE
			SET @JManouvreResult = 'not carried out. '

		SET @SummaryText = 'J manoeuvre ' + @JManouvreResult
	END
		
	SET @SummaryText = @SummaryText +   
						CASE LOWER(@ExtentDescription )
							WHEN 'intubation failed' THEN 'Failed intubation' + CASE WHEN ISNULL(@AdditionalInfo,'') <> '' THEN ': ' + @AdditionalInfo ELSE '' END
							WHEN 'abandoned' THEN 'Procedure failed (abandoned)' + CASE WHEN ISNULL(@AdditionalInfo,'') <> '' THEN ': ' + @AdditionalInfo ELSE '' END
							WHEN 'other' THEN  'Procedure failed' + CASE WHEN ISNULL(@AdditionalInfo,'') <> '' THEN ': ' + @AdditionalInfo ELSE '' END
							ELSE 'The procedure was completed successfully to the ' + @ExtentDescription
						END
	--limited by...?
	IF ISNULL(@LimitedById, 0) > 0
	BEGIN
		SET @SummaryText = @SummaryText + ' but limited by ' + (SELECT LOWER(Description) FROM ERS_Limitations WHERE UniqueId = @LimitedById)
	END

	IF ISNULL(@SummaryText,'') <> ''
	BEGIN
		UPDATE ERS_ProcedureUpperExtent
		SET Summary = @SummaryText
		WHERE ProcedureId = @ProcedureId

		EXEC procedure_summary_update @ProcedureId
	END
	
	DECLARE @Summary VARCHAR(max) = 'Extent:'


	--remove complete section entry incase conditions no longer apply. Will get re-evaluated after
	EXEC UI_update_procedure_summary @ProcedureId, 'Extent', @Summary, 0, @EndoscopistId

	--Check if the Extent has reached or exceeded the planned extent, if so mark as success
	IF @ExtentId > 0 
	BEGIN
		DECLARE @ExtentListOrder int = (SELECT ListOrderBy FROM ERS_Extent WHERE UniqueId = @ExtentId)
		DECLARE @PlannedExtentListOrder int = (SELECT e.ListOrderBy FROM ERS_ProcedurePlannedExtent ppe JOIN ERS_Extent e ON e.UniqueId = ppe.ExtentId WHERE ppe.ProcedureId = @ProcedureId)

		IF (@ExtentListOrder >= @PlannedExtentListOrder AND @ExtentListOrder > 0)
				SET @ExtentIsSuccess = 1
	END

	IF @ExtentId > 0 AND @ExtentIsSuccess = 1
		EXEC UI_update_procedure_summary @ProcedureId, 'Extent', 'Extent:', @ExtentId, @EndoscopistId
	ELSE IF @ExtentIsSuccess = 0 AND @LimitedById > 1
	BEGIN
		IF (SELECT LOWER(NEDTerm) FROM dbo.ERS_Limitations WHERE UniqueId = @LimitedById) = 'other'
		BEGIN
			IF ISNULL(@LimitationOther,'') <> ''
			BEGIN
				EXEC UI_update_procedure_summary @ProcedureId, 'Extent', 'Extent:' , @ExtentId, @EndoscopistId
			END
		END
		ELSE
		BEGIN
			EXEC UI_update_procedure_summary @ProcedureId, 'Extent', 'Extent:', @ExtentId, @EndoscopistId
		END
	END

	IF ISNULL(@WithdrawalMins,0) > 0
	BEGIN
		EXEC UI_update_procedure_summary @ProcedureId, 'Total withdrawal time', 'Total withdrawal time:', 1, @EndoscopistId
	END

	IF @JManoeuvreId > -1
	BEGIN
		EXEC UI_update_procedure_summary @ProcedureId, 'JManoevre', 'JManoevre:', 1, @EndoscopistId
	END
	ELSE
	BEGIN
		EXEC UI_update_procedure_summary @ProcedureId, 'JManoevre', 'JManoevre:', 0 , @EndoscopistId
	END
	
	--MH Added on 04 Jan 2023 
	Exec usp_SendIntubationExtentOrderMessageByProcedureId @ProcedureId, @bitHasProcedureFailed, @LoggedInUserId

	EXEC ogd_diagnoses_summary_update @ProcedureID

	--Handle unentered sections
	DECLARE @MatrixCode VARCHAR(100)

	--based on extent reached
	IF LOWER(@ExtentDescription)= 'oesophagus'
	BEGIN
		--if Oesophagus then Stomach and Duodenum not entered
		EXEC dbo.diagnoses_control_save @SiteID = 0,               -- int
		                                @DiagnosesMatrixCode = 'StomachNotEntered', -- varchar(50)
		                                @Value = 'true'                -- varchar(50)
		
		EXEC dbo.diagnoses_control_save @SiteID = 0,               -- int
		                                @DiagnosesMatrixCode = 'DuodenumNotEntered', -- varchar(50)
		                                @Value = 'true'                -- varchar(50)
	END
	IF LOWER(@ExtentDescription)= 'stomach'
	BEGIN
		--if stomach Duodenum not entered
		EXEC dbo.diagnoses_control_save @SiteID = 0,               -- int
		                                @DiagnosesMatrixCode = 'DuodenumNotEntered', -- varchar(50)
		                                @Value = 'true'                -- varchar(50)
		
	END
END


GO
PRINT N'  Altering [dbo].[procedure_planned_extent_save]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'procedure_planned_extent_save',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO

/****** Object:  StoredProcedure [dbo].[procedure_planned_extent_save]    Script Date: 02/10/2023 14:17:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[procedure_planned_extent_save]
(
	@ProcedureId int,
	@ExtentId int,
	@LoggedInUserId int
)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM ERS_ProcedurePlannedExtent WHERE ProcedureId = @ProcedureId)
	BEGIN
		INSERT INTO ERS_ProcedurePlannedExtent (ProcedureId, ExtentId, WhoUpdatedId, WhenUpdated)
		VALUES (@ProcedureId, @ExtentId, @LoggedInUserId, getdate())
	END
	ELSE
	BEGIN
		UPDATE ERS_ProcedurePlannedExtent
		SET 
			ExtentId = @ExtentId,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = getdate()
		WHERE 
			ProcedureId = @ProcedureId
	END

	DECLARE @Summary VARCHAR(max) = 'Planned extent:'
	EXEC UI_update_procedure_summary @ProcedureId, 'Planned extent', @Summary, @ExtentId

	-- Check if reached extend entered and meets/exeeds planned extent
	DECLARE @ReachedExtentId int, 
			@LimitedById int,
			@ExtentIsSuccess bit,
			@EndoscopitsId int = null
	
	/*Furthest extent*/
	SELECT TOP 1 @ReachedExtentId = ISNULL(ExtentID, 0),
				 @LimitedById = ISNULL(LimitationId,0),
				 @ExtentIsSuccess = ISNULL(ee.IsSuccess, 0),
				 @EndoscopitsId = EndoscopistId
	FROM dbo.ERS_ProcedureUpperExtent epue 
		INNER JOIN dbo.ERS_Extent ee ON epue.ExtentId = ee.UniqueId
	WHERE epue.ProcedureId = @ProcedureId
	ORDER BY ee.ListOrderBy DESC

	IF ISNULL(@ReachedExtentId, 0) > 0
	BEGIN
		--Remove complete section entry incase conditions no longer apply. Will get re-evaluated after
		EXEC UI_update_procedure_summary @ProcedureId, 'Extent', 'Extent:', 0, @EndoscopitsId

		--Check if the Extent has reached or exceeded the planned extent, if so mark as success
		DECLARE @ExtentListOrder int = (SELECT ListOrderBy FROM ERS_Extent WHERE UniqueId = @ReachedExtentId)
		DECLARE @PlannedExtentListOrder int = (SELECT e.ListOrderBy FROM ERS_ProcedurePlannedExtent ppe JOIN ERS_Extent e ON e.UniqueId = ppe.ExtentId WHERE ppe.ProcedureId = @ProcedureId)

		IF (@ExtentListOrder >= @PlannedExtentListOrder AND @ExtentListOrder > 0)
				SET @ExtentIsSuccess = 1

		IF @ReachedExtentId > 0 AND @ExtentIsSuccess = 1
			EXEC UI_update_procedure_summary @ProcedureId, 'Extent', 'Extent:', @ReachedExtentId, @EndoscopitsId
		ELSE IF @ExtentIsSuccess = 0 AND @LimitedById > 1
		BEGIN
			EXEC UI_update_procedure_summary @ProcedureId, 'Extent', 'Extent:', @ReachedExtentId, @EndoscopitsId
		END
	END
END
GO


GO
PRINT N'Finished Updates for TFS# 3109';

GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	3109
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Steve 18/08/23
-- TFS#	3112
-- Description of change
-- DICA Score  
--   Updated to include DICA Score on Site Summary which will also include it on the Printed Report
------------------------------------------------------------------------------------------------------------------------
GO
PRINT N'Begining Updates for TFS# 3112';

GO
PRINT N'  Altering [dbo].[abnormalities_colon_diverticulum_summary_update]...';

GO
EXEC dbo.DropIfExist @ObjectName = 'abnormalities_colon_diverticulum_summary_update',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO

/****** Object:  StoredProcedure [dbo].[abnormalities_colon_diverticulum_summary_update]    Script Date: 17/08/2023 13:59:39 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[abnormalities_colon_diverticulum_summary_update]
(
	@SiteId INT
)
AS
SET NOCOUNT ON
	
DECLARE 
	@summary VARCHAR (8000),
	@tempsummary VARCHAR (1000),
	@None BIT,
	@MucosalInflammation BIT,
	@Quantity TINYINT,
	@Distribution TINYINT,
	@NarrowingTortuosity BIT,
	@Severity TINYINT,
	@CircMuscleHypertrophy BIT,
	@DICAScore INT

SET @summary = ''
SET @tempsummary = ''

SELECT 
	@None=[None],
	@MucosalInflammation=MucosalInflammation,
	@Quantity=Quantity,
	@Distribution=Distribution,
	@NarrowingTortuosity=NarrowingTortuosity,
	@Severity=Severity,
	@CircMuscleHypertrophy=CircMuscleHypertrophy
FROM
	ERS_ColonAbnoDiverticulum
WHERE
	SiteId = @SiteId
	
IF @None = 1 SET @summary = 'No diverticula'

ELSE
BEGIN
	IF @Quantity > 0 
	BEGIN
		SET @summary =	CASE @Quantity 
							WHEN 1 THEN 'a few'
							WHEN 2 THEN 'several'
							WHEN 3 THEN 'multiple'
							WHEN 4 THEN 'single'
						END

		SET @summary =	@summary + 
						CASE @Distribution 
							WHEN 0 THEN ''
							WHEN 1 THEN ' scattered'
							WHEN 2 THEN ' localised'
						END
	END

	IF @NarrowingTortuosity = 1
	BEGIN
		SET @tempsummary =	CASE @Severity
								WHEN 0 THEN ''
								WHEN 1 THEN 'mild '
								WHEN 2 THEN 'moderate '
								WHEN 3 THEN 'severe '
							END

		SET @tempsummary = @tempsummary + 'narrowing/tortuosity of the diverticular segment'

		IF @summary <> '' SET @summary = @summary + ' with ' + @tempsummary
		ELSE SET @summary = @tempsummary
	END

	
	IF @MucosalInflammation = 1
		IF @summary = ''
			SET @summary = 'mucosal inflammation'
		ELSE IF CHARINDEX('with', @summary) > 0 
			SET @summary = @summary + '$$' + 'mucosal inflammation'
		ELSE
			SET @summary = @summary + ' with ' + 'mucosal inflammation'

	
	IF @CircMuscleHypertrophy = 1 SET @summary = @summary + '$$' + 'circular muscle hypertrophy'
	
	SELECT @DICAScore = (dicaExtension.Points + dicaGrade.Points + dicaInflammatory.Points + dicaComplications.Points)
	FROM ERS_ProcedureDICAScores pds
	JOIN ERS_DICAScores dicaExtension on dicaExtension.UniqueId = pds.ExtensionId
	JOIN ERS_DICAScores dicaGrade on dicaGrade.UniqueId = pds.GradeId
	JOIN ERS_DICAScores dicaInflammatory on dicaInflammatory.UniqueId = pds.InflammatorySignsId
	JOIN ERS_DICAScores dicaComplications on dicaComplications.UniqueId = pds.ComplicationsId
	WHERE pds.SiteId = @SIteId

	IF NULLIF(@DICAScore,0) > 0
		IF @summary = ''
			SET @summary = 'DICA Score: ' + CONVERT(varchar(2), @DICAScore)
		ELSE IF CHARINDEX('with', @summary) > 0 
			SET @summary = @summary + '$$' + 'DICA Score: ' + CONVERT(varchar(2), @DICAScore)
		ELSE
			SET @summary = @summary + ' with ' + 'DICA Score: ' + CONVERT(varchar(2), @DICAScore)

	-- Set the last occurence of $$ to "and"
	IF CHARINDEX('$$', @summary) > 0 
	SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 2, ' and ')
	IF LEFT(@summary,5) = ' and ' SET @summary = RIGHT(@summary, LEN(@summary)-5)

	-- Replace all other occurences of $$ with commas
	SET @summary = REPLACE(@summary, '$$', ', ')
END

-- Finally, update the summary in Diverticulum table
UPDATE ERS_ColonAbnoDiverticulum 
SET Summary = @summary 
WHERE SiteId = @SiteId



GO
PRINT N'Finished Updates for TFS# 3112';

GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	3112
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson 3.08.23
-- TFS#	3008
-- Description of change
-- Added a filter to SP for selected diaries
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

PRINT N'Altering Procedure [dbo].[sch_get_day_diary]...';


GO


ALTER PROCEDURE [dbo].[sch_get_day_diary]
(
	@OperatingHospitalID INT,
	@DiaryDate datetime,
	@RoomIds VARCHAR(MAX)
)
AS

	IF OBJECT_ID ('tempdb..#tmpDiaryRooms') IS NOT NULL
		DROP TABLE #tmpDiaryRooms

	SELECT Item
	INTO #tmpDiaryRooms
	FROM dbo.fnSplitString(@RoomIds, ',')

	SELECT DISTINCT
		d.DiaryId,
		d.DiaryStart,
		d.[DiaryEnd],
		d.[UserID], 
		d.[RoomID], 
		d.ListRulesId, 
		s.SlotMinutes as [Minutes],
		CASE WHEN ept.ProcedureType IS NULL THEN ss.Description 
		ELSE 'Reserved for ' + ss.Description + ' '+ ept.ProcedureType END AS [Subject],
		ss.Description,
		ISNULL(s.ProcedureTypeID,0) AS ProcedureTypeID,
		s.ListSlotId,
		ss.ForeColor,
		ss.StatusId,
		ISNULL(s.Points, 1) AS Points,
		ISNULL(l.Endoscopist,0) AS EndoscopistId,
		(CASE WHEN  ISNULL(u.Title,'') <> '' THEN u.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Forename,'') <> '' THEN u.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Surname,'') <> '' THEN u.Surname + ' ' ELSE '' END) as EndoscopistName,
	  (CASE WHEN  ISNULL(c.Title,'') <> '' THEN c.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(c.Forename,'') <> '' THEN c.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(c.Surname,'') <> '' THEN c.Surname + ' ' ELSE '' END) as ListConsultant,
		l.ListName,
		(CASE WHEN  ISNULL(u.Title,'') <> '' THEN u.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Forename,'') <> '' THEN u.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Surname,'') <> '' THEN u.Surname + ' ' ELSE '' END) +
	  '  [' + CONVERT(VARCHAR(5),cast(d.DiaryStart as time)) + '-' + CONVERT(VARCHAR(5),cast(d.[DiaryEnd] as time)) + ']' +
	  CASE WHEN  ISNULL(l.Points,0) <> 0 THEN '  [' + CONVERT(VARCHAR, l.Points) + ' slots]' ELSE '' END  AS ListDescription
		,d.suppressed
		,d.SuppressedFromDate
		,d.Training
		,l.GIProcedure
		,ISNULL(apt.AppointmentId, 0) AppointmentId
		,apt.StartDateTime AppointmentStart
		,ISNULL(apt.TotalPoints,0) AppointmentPoints
		,ISNULL(apt.AppointmentDuration,0) AppointmentDuration
		,DATEADD(minute, convert(int, apt.AppointmentDuration), apt.StartDateTime) AppointmentEnd
		,ISNULL(apt.StatusCode,'') AppointmentStatusCode
		,ISNULL(apt.Notes,'') AppointmentNotes
		,p.HospitalNumber + ' - ' + p.Forename1 + ' ' + p.Surname + '<br />' + apt.Description + ' '+ STUFF(REPLACE(apt.Procs, CHAR(10), '+'), LEN(apt.procs),1,'') AS [AppointmentSubject]
		,ISNULL(apt.GeneralInformation, '') GeneralInformation
		,s.Locked
		,d.OperatingHospitalId
		,ISNULL(d.RecurrenceParentID,0)RecurrenceParentID
		,ISNULL(d.locked,0) LockedDiary
	FROM ERS_SCH_DiaryPages d
		INNER JOIN #tmpDiaryRooms r ON r.Item = d.RoomID
		INNER JOIN ERS_SCH_ListRules l ON l.ListRulesId = d.ListRulesId
		INNER JOIN ERS_SCH_ListSlots s ON d.ListRulesId = s.ListRulesId AND s.Active = 1
		INNER JOIN dbo.ERS_SCH_SlotStatus ss ON ss.StatusId = s.SlotId
		LEFT JOIN dbo.ERS_ProcedureTypes ept ON s.ProceduretypeId = ept.ProcedureTypeId
		LEFT JOIN ERS_Users u ON u.UserID = d.UserId
		LEFT JOIN ERS_Users c ON c.UserID = d.ListConsultantId
		--LEFT JOIN ERS_Appointments a ON a.DiaryId = d.DiaryId and a.ListSlotId = s.ListSlotId AND ISNULL(a.AppointmentStatusId,0) <> dbo.fnSCHAppointmentStatusId('C')
		--LEFT JOIN (SELECT apt.AppointmentID, sum(Points) TotalPoints, sum(Minutes) TotalMinutes FROM ERS_AppointmentProcedureTypes apt GROUP BY AppointmentId) apt on apt.AppointmentID = a.AppointmentId
		LEFT JOIN (SELECT ea.AppointmentId, SUM(eapt.Points) AS TotalPoints, SUM(eapt.Minutes) AS TotalMinutes, ea.ListSlotId, ea.DiaryId, MAX(aps.HDCKEY) StatusCode, ass.Description, ea.PatientId,ea.GeneralInformation, ea.Notes, ea.AppointmentDuration,ea.StartDateTime,
						(SELECT
							AppointmentProcedures + char(10) AS [text()] 
						FROM dbo.SCH_AppointmentProcedures(ea.AppointmentId)
						WHERE AppointmentId = ea.AppointmentId
						FOR XML PATH('')) AS procs
					FROM dbo.ERS_Appointments ea
						INNER JOIN dbo.ERS_AppointmentProcedureTypes eapt ON ea.AppointmentId = eapt.AppointmentID
						INNER JOIN dbo.ERS_SCH_SlotStatus ass ON ea.SlotStatusID = ass.StatusId
						LEFT JOIN ERS_AppointmentStatus aps on aps.UniqueId = ea.AppointmentStatusId
					 WHERE ISNULL(aps.HDCKEY,'') <> 'C'
					GROUP BY ea.AppointmentId, ea.ListSlotId, ea.DiaryId, ass.Description, ea.PatientId,ea.GeneralInformation, ea.Notes, ea.AppointmentDuration,ea.StartDateTime) AS apt 
											ON apt.DiaryId = d.DiaryId and  apt.ListSlotId = s.ListSlotId
		LEFT JOIN ERS_Patients p ON p.patientId = apt.PatientId
	WHERE d.OperatingHospitalId = @OperatingHospitalID AND convert(varchar(10), DiaryStart, 103) = convert(varchar(10), @DiaryDate, 103)
	ORDER BY d.DiaryId, s.ListSlotId
GO
PRINT N'Altering Procedure [dbo].[sys_ResetDiary]...';

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson
-- TFS#	
-- Description of change
-- System SP update to delete appointment during reset
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO
GO
ALTER PROCEDURE [dbo].[sys_ResetDiary]
(
	@DeleteTemplates bit = NULL,
	@DeleteAppointments BIT = NULL
)
AS
IF ISNULL(@DeleteTemplates, 0) = 1 
BEGIN
	DELETE FROM dbo.ERS_SCH_ListSlots
	DELETE FROM dbo.ERS_SCH_ListRules
END
DELETE FROM dbo.ERS_SCH_GenderList
DELETE FROM dbo.ERS_SCH_DiaryPages

IF ISNULL(@DeleteAppointments,0) = 1
BEGIN
	DELETE FROM dbo.ERS_AppointmentTherapeutics WHERE AppointmentID IN (SELECT AppointmentID FROM dbo.ERS_Appointments WHERE DiaryId IS NOT null)
	DELETE FROM dbo.ERS_AppointmentProcedureTypes WHERE AppointmentID IN (SELECT AppointmentID FROM dbo.ERS_Appointments WHERE DiaryId IS NOT null)
	DELETE FROM dbo.ERS_Appointments WHERE AppointmentID IN (SELECT AppointmentID FROM dbo.ERS_Appointments WHERE DiaryId IS NOT null)
END
GO

--MH added below script on 19 Feb 2024. It threw error at NCA Salford while updating.

if not exists(Select * from sys.tables where name = 'tblTablesToBeAudited')
Begin
CREATE TABLE [ERSAudit].[tblTablesToBeAudited](
	[TableSchema] [nvarchar](30) NOT NULL,
	[TableName] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_tblTablesToBeAudited_1] PRIMARY KEY CLUSTERED 
(
	[TableSchema] ASC,
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

End

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Steve 29/08/23
-- TFS#	
-- Description of change
-- Site Marking Optimisation
------------------------------------------------------------------------------------------------------------------------
GO
-- Disable trigger that calls Sites_Summary_Update 
PRINT N'  Disabling Trigger TR_Sites_Insert on ERS_Sites table...';
GO
DISABLE TRIGGER TR_Sites_Insert ON ERS_Sites;  
GO

--Remove ERS_Sites from tables to be audited
PRINT N'  Removing ERS_Sites from ERSAudit.tblTablesToBeAudited table...';
GO
DELETE FROM ERSAudit.tblTablesToBeAudited
WHERE TableName = 'ERS_Sites'

GO
-- Update sites_update stored procedure to call Sites_Summary_Update instead of procedure_summay_update (Sites_Summary_Update will call this anyway with the RefreshReport parameter set to 1)
PRINT N'  Altering [dbo].[sites_update]...';
GO
EXEC dbo.DropIfExist @ObjectName = 'sites_update',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO

/****** Object:  StoredProcedure [dbo].[sites_update]    Script Date: 03/08/2023 08:31:54 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[sites_update]
(
	@SiteId INT,
	@RegionId INT, 
	@XCoordinate INT, 
	@YCoordinate INT, 
	@AntPos TINYINT,
	@PositionSpecified BIT,
	@LoggedInUserId INT
)
AS
/**************************************************************************
 Author:		?
 Create date:	?
 Description:	Called when a site is updated
***************************************************************************
*****                        Change History                           *****
***************************************************************************
** Rev	Date			Author		Description 
** --	-----------		---------	---------------------------------------
** 1	25 Jul 2019		Duncan		For procedure types 1-3, a site can 
									move region and keep the data
** 
**
**************************************************************************/

SET NOCOUNT ON

DECLARE @PrevRegionId INT
DECLARE @ProcedureId INT
DECLARE @ProcedureType INT

BEGIN TRANSACTION

BEGIN TRY
	SELECT @PrevRegionId = RegionId,
			@ProcedureId = ProcedureId
	FROM ERS_Sites
	WHERE SiteId = @SiteId
	
	UPDATE 
		ERS_Sites 
	SET
		RegionId = @RegionId, 
		XCoordinate = @XCoordinate, 
		YCoordinate = @YCoordinate, 
		AntPos = @AntPos,
		PositionSpecified = @PositionSpecified,
		WhoUpdatedId = @LoggedInUserId,
		WhenUpdated = GETDATE()
	WHERE
		SiteId = @SiteId

	IF @PrevRegionId <> @RegionId
	BEGIN
		Select @ProcedureType = ProcedureType from ERS_Procedures where ProcedureId = @ProcedureId
		if @ProcedureType = 1 OR @ProcedureType = 6  OR @ProcedureType = 7 
			exec MoveUpperGISite @SiteId, @PrevRegionId, @RegionId 
		else if @ProcedureType = 2 OR @ProcedureType = 4 or @ProcedureType = 5
			exec MoveColonSite @SiteId, @PrevRegionId, @RegionId 
		else if @ProcedureType = 3
			exec MoveERCPSite @SiteId, @PrevRegionId, @RegionId 
		Else
		Begin

			DELETE FROM ERS_UpperGIAbnoGastritis WHERE SiteId = @SiteId
			DELETE FROM ERS_UpperGIAbnoAchalasia WHERE SiteId = @SiteId
			DELETE FROM ERS_UpperGIAbnoGastricUlcer	WHERE SiteId = @SiteId
			DELETE FROM ERS_UpperGIAbnoLumen WHERE SiteId = @SiteId
			DELETE FROM ERS_UpperGIAbnoMalignancy WHERE SiteId = @SiteId
			DELETE FROM ERS_UpperGIAbnoPostSurgery WHERE SiteId = @SiteId
			DELETE FROM ERS_UpperGIAbnoPolyps WHERE SiteId = @SiteId
			DELETE FROM ERS_UpperGIAbnoDeformity WHERE SiteId = @SiteId
			DELETE FROM ERS_UpperGIAbnoVarices WHERE SiteId = @SiteId
			DELETE FROM ERS_UpperGIAbnoHiatusHernia WHERE SiteId = @SiteId
			DELETE FROM ERS_UpperGIAbnoBarrett WHERE SiteId = @SiteId
			DELETE FROM ERS_UpperGIAbnoOesophagitis WHERE SiteId = @SiteId
			DELETE FROM ERS_UpperGIAbnoMiscellaneous WHERE SiteId = @SiteId
		

			DELETE FROM ERS_ColonAbnoCalibre WHERE SiteId = @SiteId
			DELETE FROM ERS_ColonAbnoMiscellaneous WHERE SiteId = @SiteId
			DELETE FROM ERS_ColonAbnoMucosa WHERE SiteId = @SiteId
			DELETE FROM ERS_ColonAbnoDiverticulum WHERE SiteId = @SiteId
			DELETE FROM ERS_ColonAbnoHaemorrhage WHERE SiteId = @SiteId
			DELETE FROM ERS_ColonAbnoVascularity WHERE SiteId = @SiteId
			DELETE FROM ERS_ColonAbnoPerianalLesions WHERE SiteId = @SiteId
			DELETE FROM ERS_ColonAbnoLesions WHERE SiteId = @SiteId

			DELETE FROM ERS_ERCPAbnoDuct WHERE SiteId = @SiteId
			DELETE FROM ERS_ERCPAbnoParenchyma WHERE SiteId = @SiteId
			DELETE FROM ERS_ERCPAbnoAppearance WHERE SiteId = @SiteId
			DELETE FROM ERS_ERCPAbnoDiverticulum WHERE SiteId = @SiteId
			DELETE FROM ERS_ERCPAbnoTumour WHERE SiteId = @SiteId

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
			DELETE FROM ERS_ERCPTherapeutics WHERE SiteId = @SiteId

			DELETE FROM ERS_Photos WHERE SiteId = @SiteId

			DELETE 
			FROM ERS_RecordCount 
			WHERE SiteId = @SiteId
			AND Identifier IN ('Gastritis',					'Gastric Ulcer',
								'Lumen',					'Malignancy',
								'Post Surgery', 			'Polyps', 
								'Deformity', 				'Varices',
								'Hiatus Hernia',			'Barretts',
								'Vascular Lesions',			'Oesophagitis',
								'Miscellaneous',			'Diverticulum',
								'Tumour',					'Duodenitis',
								'Duodenal Ulcer',			'Scarring/Stenosis',
								'Atrophic Duodenum',		'Calibre', 
								'Mucosa',					'Diverticulum',
								'Haemorrhage',				'Vascularity',
								'PerianalLesions',			'Lesions',
								'Duct', 					'Parenchyma', 
								'Appearance', 				'Diverticulum', 
								'Specimens Taken',			'Therapeutic Procedures',
								'Jejunitis',				'Jejunal Ulcer',
								'Ileitis',					'Ileal Ulcer'
								)
		END
	END

	
	EXEC sites_reorder @ProcedureId
	EXEC sites_summary_update @SiteId, @RefreshReport = 1
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

--Update sites_reorder stored procedure, removing unrequired JOIN
PRINT N'  Altering [dbo].[sites_reorder]...';
GO
EXEC dbo.DropIfExist @ObjectName = 'sites_reorder',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO

/****** Object:  StoredProcedure [dbo].[sites_reorder]    Script Date: 03/08/2023 11:40:30 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[sites_reorder]
(
	@ProcedureId INT
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	DECLARE @SiteIdentification int 

	SELECT @SiteIdentification = SiteIdentification	
	FROM ERS_Procedures p
	JOIN ERS_SystemConfig esc ON p.OperatingHospitalID = esc.OperatingHospitalID
	WHERE p.ProcedureId = @ProcedureId

	-- Select all the sites into a temp table.
	SELECT 
		SiteId, 
		SiteNo, 
		[Order] * 100 AS NewSiteNo, 
		AreaNo, 
		r.Region, 
		XCoordinate, 
		YCoordinate, 
		[Order] AS RegionOrder, 
		Direction 
	INTO 
		#temp 
	FROM 
		ERS_Sites s 
	JOIN 
		ERS_Regions r ON s.RegionId = r.RegionId
	WHERE 
		s.ProcedureId = @ProcedureId
	ORDER BY 
		RegionOrder


	-- Get rid of the sites of areas except the first one of each.
	DELETE FROM #temp 
	WHERE AreaNo > 0 
	AND SiteId NOT IN (SELECT min(siteid) FROM #temp GROUP BY AreaNo)

	-- Rank the sites within the region blocks (based on region's order and direction)
	SELECT 
		SiteId, 
		RANK() OVER (PARTITION BY RegionOrder ORDER BY 
												CASE Direction 
													WHEN 'YA' THEN YCoordinate 
													WHEN 'XA' THEN XCoordinate 
												END ASC, 
												CASE Direction 
													WHEN 'YD' THEN YCoordinate 
													WHEN 'XD' THEN XCoordinate 
												END DESC
					) AS MyRank 
	INTO 
		#temp2
	FROM 
		#temp 

	-- Update the sites with the ranks
	UPDATE t SET NewSiteNo = NewSiteNo + myrank FROM #temp t JOIN #temp2 t2 ON t.SiteId = t2.siteid

	-- Generate IDs into another temp table
	SELECT row_number() OVER (ORDER BY newsiteno) AS RowId, SiteId INTO #temp3 FROM #temp

	-- Finally update the sitenos in sites table
	UPDATE s SET SiteNo = RowId FROM ERS_Sites s JOIN #temp3 ON s.SiteId = #temp3.SiteId
	UPDATE ERS_Sites SET SiteNo = 0 WHERE AreaNo > 0 AND SiteId NOT IN (SELECT min(SiteId) FROM #temp GROUP BY AreaNo) AND ProcedureId = @ProcedureId

	DROP TABLE #temp
	DROP TABLE #temp2
	DROP TABLE #temp3

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


--Update sites_insert stored procedure:
--	Remove query to get next site number as sites are reordered after insert anyway
--	Call to Sites_Summary_Update rather than procedure_summary_update, this used to be called in a trigger (Sites_Summary_Update calls procedure_summary_update anyway) 
PRINT N'  Altering [dbo].[sites_insert]...';
GO

EXEC dbo.DropIfExist @ObjectName = 'sites_insert',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO

/****** Object:  StoredProcedure [dbo].[sites_insert]    Script Date: 03/08/2023 11:43:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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

DECLARE @site_no INT
DECLARE @newSiteId INT
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
		SET @site_no = 999
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
		SELECT CAST(@newSiteId AS VARCHAR(5))
	END
	ELSE
	BEGIN
		EXEC sites_reorder @ProcedureId

		SELECT @site_no = SiteNo FROM ERS_Sites WHERE SiteId = @newSiteId

		DECLARE @SiteIdentification TINYINT
		SELECT @SiteIdentification = ISNULL(SiteIdentification,0) FROM ERS_SystemConfig WHERE OperatingHospitalID = @OperatingHospitalID

		SELECT CAST(@newSiteId AS VARCHAR(15)) +  ';' + dbo.fnGetSiteTitle(@site_no, @SiteIdentification)
	END
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

-- Add call to Sites_Summary_Update to end of Additional_Notes_Save stored procedure.
GO
PRINT N'  Altering [dbo].[additional_notes_save]...';

GO
EXEC dbo.DropIfExist @ObjectName = 'additional_notes_save',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO

/****** Object:  StoredProcedure [dbo].[additional_notes_save]    Script Date: 29/08/2023 09:39:31 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[additional_notes_save]
(
	@SiteId INT,
	@AdditionalNotes VARCHAR(max),
	@LoggedInUserId INT

)
AS

SET NOCOUNT ON

DECLARE @proc_id INT

BEGIN TRANSACTION

BEGIN TRY

	UPDATE s
	SET s.AdditionalNotes = @AdditionalNotes,
		WhoUpdatedId = @LoggedInUserId,
		WhenUpdated = GETDATE()
	FROM ERS_Sites AS s
	JOIN 
		ERS_Procedures p ON s.ProcedureId = p.ProcedureId 
	WHERE 
		SiteId = @SiteId

	
	SELECT @proc_id = p.ProcedureId
	FROM ERS_Sites s
	JOIN ERS_Procedures p ON s.ProcedureId = p.ProcedureId
	WHERE SiteId = @SiteId

	IF ISNULL(@AdditionalNotes,'') = '' 
		DELETE FROM ERS_RecordCount 
		WHERE SiteId = @SiteId
		AND Identifier = 'Additional notes'
	ELSE
		INSERT INTO ERS_RecordCount ([ProcedureId], [SiteId], [Identifier],[RecordCount])
		VALUES (@proc_id, @SiteId, 'Additional notes', 1)

	EXEC sites_summary_update @SiteId, @RefreshReport = 1
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
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	(Site Marking Optimisation)
------------------------------------------------------------------------------------------------------------------------

GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	: Andrea Johnson 31.08.23	
-- TFS#	2996
-- Description of change
-- SP to get rooms where a procedure type is assigned 
------------------------------------------------------------------------------------------------------------------------
GO



EXEC dbo.DropIfExist @ObjectName = 'sch_get_scheduler_rooms',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE dbo.sch_get_scheduler_rooms
(
	@OperatingHospitalId int
)
AS
BEGIN
	SELECT DISTINCT r.RoomId, r.RoomName, r.HospitalId, r.Suppressed, r.RoomSortOrder, r.AllProcedureTypes, r.OtherInvestigations 
	FROM dbo.ERS_SCH_Rooms r
		INNER JOIN dbo.ERS_SCH_RoomProcedures p ON p.RoomId = r.RoomId
	WHERE r.HospitalId = @OperatingHospitalId AND r.Suppressed = 0
	ORDER BY r.RoomSortOrder
END

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson 04.09.23
-- TFS#	3125
-- Description of change
-- Worklist to save and retrieve procedure points and minutes
------------------------------------------------------------------------------------------------------------------------
GO

PRINT N'Altering Procedure [dbo].[add_to_worklist]...';


GO

ALTER PROCEDURE [dbo].[add_to_worklist](
	@PatientId INT,
	@Endoscopist INT,
	@StartDateTime DATETIME,
	@ProcedureTypeId INT = NULL,
	@OperatingHospitalId INT,
	@TimeOfDay VARCHAR(10),
	@LoggedInUserId INT
)
AS
BEGIN
BEGIN TRANSACTION
BEGIN TRY

	DECLARE @AppointmentId INT, @ProcedurePoints DECIMAL(18,2), @ProcedureMinutes INT
    
	SELECT @AppointmentId = ea.AppointmentId FROM dbo.ERS_Appointments ea WHERE ea.PatientId = @PatientId AND ea.OperationalHospitaId = @OperatingHospitalId AND ea.AppointmentStatusId = 1 AND ea.BookingTypeId = 1
	
	SELECT @ProcedureMinutes = Minutes, @ProcedurePoints = Points FROM dbo.ERS_SCH_PointMappings WHERE ProceduretypeId = @ProcedureTypeId AND Training=0 AND NonGI = 0 AND OperatingHospitalId = @OperatingHospitalId

	IF ISNULL(@AppointmentId, 0) = 0
	BEGIN
		INSERT INTO ERS_Appointments
		(
			PatientId,
			EndoscopistId,
			StartDateTime,
			OperationalHospitaId,
			AppointmentStatusId,
			BookingTypeId, 
			TimeOfDay,
			WhoCreatedId,
			WhenCreated
		)
		VALUES
		(
			@PatientId,
			@Endoscopist,
			@StartDateTime,
			@OperatingHospitalId,
			1, /*designated enum to specify a worklist booking*/
			1,
			@TimeOfDay,
			@LoggedInUserId,
			GETDATE()
		)

		IF ISNULL(@ProcedureTypeID,0) > 0 
		BEGIN
			SELECT @AppointmentId = SCOPE_IDENTITY()

			INSERT INTO dbo.ERS_AppointmentProcedureTypes
			(
				AppointmentID,
				ProcedureTypeID,
				IsTherapeutic,
				Points,
				Minutes,
				WhoCreatedId,
				WhenCreated
			)
			VALUES
			(
				@AppointmentId,
				@ProcedureTypeId,
				0,
				@ProcedurePoints,
				@ProcedureMinutes,
				@LoggedInUserId,
				GETDATE()
			)
		END
	END
	ELSE
	BEGIN
		UPDATE ERS_Appointments 
		SET
			StartDateTime = @StartDateTime,
			EndoscopistId = @Endoscopist,
			TimeOfDay = @TimeOfDay,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = GETDATE()
			WHERE AppointmentId = @AppointmentId

		IF ISNULL(@ProcedureTypeID,0) > 0 
		BEGIN
			UPDATE dbo.ERS_AppointmentProcedureTypes
			SET
				ProcedureTypeID = @ProcedureTypeId,
				Points = @ProcedurePoints,
				Minutes = @ProcedureMinutes,
				WhoUpdatedId = @LoggedInUserId,
				WhenUpdated = GETDATE()
			WHERE AppointmentID = @AppointmentId
		END
	END

	SELECT @AppointmentId


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
END
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO
PRINT N'Altering Procedure [dbo].[get_worklist_patient]...';


GO
ALTER PROCEDURE [dbo].[get_worklist_patient]
(
	@AppointmentId INT = NULL,
	@PatientId INT = NULL,
	@OperatingHospitalId INT = NULL
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

SELECT 
	ea.AppointmentId AS UniqueId, 
	ep.Surname, 
	ep.Forename1 as Forename, 
	convert(char(10),ep.DateOfBirth,103) AS DateOfBirth, 
	isnull(ep.Title,'') as Title, 
	UPPER(SUBSTRING(dbo.fnGender(ep.GenderId),1,1)) AS Gender,
	STUFF((SELECT DISTINCT ', '+ HospitalNumber from ERS_PatientTrusts where PatientId = ep.PatientId for xml path('')), 1, 2, '') AS HospitalNumber,
	dbo.fnFullAddress(ep.Address1, ep.Address2, ep.Address3, ep.Address4, '') AS Address,
	isnull(ep.Postcode,'') as Postcode,
	ea.StartDateTime as [Date], 
	ept.ProcedureType AS ProcedureType,
	eapt.ProcedureTypeID AS ProcedureTypeId,
	ep.PatientId,
	ea.StartDateTime,
	ea.TimeOfDay,
	ea.EndoscopistId,
	ISNULL(eapt.Points, 1) Points,
	ISNULL(eapt.Minutes, 15) Minutes
	FROM  ERS_Appointments ea  
		LEFT JOIN dbo.ERS_Patients ep  ON ea.PatientId = ep.PatientId
		LEFT JOIN ERS_AppointmentProcedureTypes eapt ON EA.AppointmentId = eapt.AppointmentID
		LEFT JOIN dbo.ERS_ProcedureTypes ept ON eapt.ProcedureTypeID = ept.ProcedureTypeId
		LEFT JOIN dbo.ERS_Users eu ON eu.UserID = ea.EndoscopistId
		LEFT JOIN ERS_SCH_DiaryPages dp on ea.DiaryId = dp.DiaryId
	WHERE ISNULL(@AppointmentId, ea.AppointmentId) = ea.AppointmentId 
		AND ISNULL(@PatientId, ea.PatientId) = ea.PatientId
		AND ISNULL(@OperatingHospitalId, ea.OperationalHospitaId) = ISNULL(dp.OperatingHospitalId, ea.OperationalHospitaId)

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

UPDATE dbo.ERS_Appointments
SET DiaryId = NULL,
PreviousDiaryId = DiaryId
WHERE DiaryId NOT IN (SELECT DiaryId FROM dbo.ERS_SCH_DiaryPages)
GO

IF (SELECT OBJECT_ID('FK_ERS_Appointments_DiaryId')) = NULL
BEGIN
	ALTER TABLE dbo.ERS_Appointments
	ADD CONSTRAINT FK_ERS_Appointments_DiaryId
	FOREIGN KEY (DiaryId)
	REFERENCES dbo.ERS_SCH_DiaryPages(DiaryId)
END
GO



------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO


------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson	
-- TFS#	3179
-- Description of change
-- Therapeutic types clean-up
------------------------------------------------------------------------------------------------------------------------
GO



IF EXISTS (SELECT 1 FROM ERS_ConsultantProcedureTherapeutics WHERE TherapeuticTypeID=1080)
BEGIN
	UPDATE ERS_ConsultantProcedureTherapeutics 
	SET TherapeuticTypeID = 52
	WHERE TherapeuticTypeID=1080 

END

IF EXISTS (SELECT 1 FROM dbo.ERS_AppointmentTherapeutics WHERE TherapeuticTypeID=1080)
BEGIN
	UPDATE ERS_AppointmentTherapeutics 
	SET TherapeuticTypeID = 52
	WHERE TherapeuticTypeID=1080 

END

	DELETE FROM ERS_TherapeuticTypes WHERE Id = 1080

GO

IF EXISTS (SELECT 1 FROM ERS_ConsultantProcedureTherapeutics WHERE TherapeuticTypeID=1081)
BEGIN
	UPDATE ERS_ConsultantProcedureTherapeutics 
	SET TherapeuticTypeID = 53
	WHERE TherapeuticTypeID=1081 

END

IF EXISTS (SELECT 1 FROM ERS_AppointmentTherapeutics WHERE TherapeuticTypeID=1081)
BEGIN
	UPDATE ERS_AppointmentTherapeutics 
	SET TherapeuticTypeID = 53
	WHERE TherapeuticTypeID=1081 

END
	DELETE FROM ERS_TherapeuticTypes WHERE Id = 1081
GO

IF EXISTS (SELECT 1 FROM ERS_ConsultantProcedureTherapeutics WHERE TherapeuticTypeID=1084)
BEGIN
	UPDATE ERS_ConsultantProcedureTherapeutics 
	SET TherapeuticTypeID = 13
	WHERE TherapeuticTypeID=1084 

END

IF EXISTS (SELECT 1 FROM ERS_AppointmentTherapeutics WHERE TherapeuticTypeID=1084)
BEGIN
	UPDATE ERS_AppointmentTherapeutics 
	SET TherapeuticTypeID = 13
	WHERE TherapeuticTypeID=1084 

END


	DELETE FROM ERS_TherapeuticTypes WHERE Id = 1084
GO

IF EXISTS (SELECT 1 FROM ERS_ConsultantProcedureTherapeutics WHERE TherapeuticTypeID=1089)
BEGIN
	UPDATE ERS_ConsultantProcedureTherapeutics 
	SET TherapeuticTypeID = 37
	WHERE TherapeuticTypeID=1089 

END

IF EXISTS (SELECT 1 FROM dbo.ERS_AppointmentTherapeutics WHERE TherapeuticTypeID=1089)
BEGIN
	UPDATE ERS_AppointmentTherapeutics 
	SET TherapeuticTypeID = 37
	WHERE TherapeuticTypeID=1089 

END
	DELETE FROM ERS_TherapeuticTypes WHERE Id = 1089
GO

IF EXISTS (SELECT 1 FROM ERS_ConsultantProcedureTherapeutics WHERE TherapeuticTypeID=1088)
BEGIN
	UPDATE ERS_ConsultantProcedureTherapeutics 
	SET TherapeuticTypeID = 38
	WHERE TherapeuticTypeID=1088

END

IF EXISTS (SELECT 1 FROM dbo.ERS_AppointmentTherapeutics WHERE TherapeuticTypeID=1088)
BEGIN
	UPDATE ERS_AppointmentTherapeutics 
	SET TherapeuticTypeID = 35
	WHERE TherapeuticTypeID=1088 

END
	DELETE FROM ERS_TherapeuticTypes WHERE Id = 1088
GO

UPDATE ERS_TherapeuticTypes SET OGD = 0 WHERE Id IN (1082, 1083)
GO



UPDATE ERS_TherapeuticTypes
SET Description = 'Snare excision - cold'
WHERE Description = 'Snare excision' AND NedName = 'Polyp snare - cold'
GO


UPDATE ERS_TherapeuticTypes
SET Description = 'Snare excision - hot'
WHERE Description = 'Snare excision' AND NedName = 'Polyp snare - hot'
GO


UPDATE ERS_TherapeuticTypes
SET ERCP = 0 
WHERE Description = 'Stent insertion' AND NedName = 'Stent placement'
GO

IF EXISTS (SELECT 1 FROM ERS_ConsultantProcedureTherapeutics WHERE TherapeuticTypeID=1082)
BEGIN
	UPDATE ERS_ConsultantProcedureTherapeutics 
	SET TherapeuticTypeID = 1077
	WHERE TherapeuticTypeID=1082 

END

IF EXISTS (SELECT 1 FROM dbo.ERS_AppointmentTherapeutics WHERE TherapeuticTypeID=1082)
BEGIN
	UPDATE ERS_AppointmentTherapeutics 
	SET TherapeuticTypeID = 1077
	WHERE TherapeuticTypeID=1082 

END
	DELETE FROM ERS_TherapeuticTypes WHERE Id = 1082
GO



UPDATE ERS_TherapeuticTypes
SET Description = 'Stent removal – pancreatic'
WHERE Description = 'Stent removal' AND NedName = 'Stent removal – pancreatic'
GO

IF EXISTS (SELECT 1 FROM ERS_ConsultantProcedureTherapeutics WHERE TherapeuticTypeID=1083)
BEGIN
	UPDATE ERS_ConsultantProcedureTherapeutics 
	SET TherapeuticTypeID = 1078
	WHERE TherapeuticTypeID=1083 

END

IF EXISTS (SELECT 1 FROM dbo.ERS_AppointmentTherapeutics WHERE TherapeuticTypeID=1083)
BEGIN
	UPDATE ERS_AppointmentTherapeutics 
	SET TherapeuticTypeID = 1078
	WHERE TherapeuticTypeID=1083 

END

	DELETE FROM ERS_TherapeuticTypes WHERE Id = 1083
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Duncan 04/09/23
-- TFS#	
-- Description of change
-- Store the record of the file move to the database rather than a file onthe imageport share
------------------------------------------------------------------------------------------------------------------------
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE NAME='ERS_PhotosLog' and xtype='U')
    create table ERS_PhotosLog (
		PhotoLogId int identity,
		LogDate datetime not null,
        FileSource varchar(500) not null,
		Destination varchar(500) not null
    )
GO
EXEC dbo.DropIfExist @ObjectName = 'uspLogFileMove',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE uspLogFileMove
(
	@Source varchar(500), 
	@Destination varchar(500)
)
AS
BEGIN
	INSERT INTO ERS_PhotosLog (LogDate, FileSource, Destination)
	values (GETDATE(), @Source, @Destination)
END
GO


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	Duncan 04/09/23
------------------------------------------------------------------------------------------------------------------------
GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha Kundu	On 22  August 2023
-- TFS#	
-- Description of change
-- New SP to get access level for all pages
------------------------------------------------------------------------------------------------------------------------
GO

EXEC dbo.DropIfExist @ObjectName = 'GetAllPageAccessLevel',
                     @ObjectTypePrefix = 'S'

GO
CREATE PROCEDURE [dbo].[GetAllPageAccessLevel] (
                @UserId int,
                @TrustId int,
                @IsReadOnlyOverride bit
)
AS 

BEGIN
	DECLARE @RoleID VARCHAR(70),
			@AccessLevel INT = 0,
			@CreateProcureAccessLevel INT
			
	IF @userId = 0 AND @IsReadOnlyOverride = 1
	BEGIN
		SELECT p.AppPageName , MAX(ISNULL(pr.AccessLevel, 0)) --As AccessLevel 
		FROM ERS_PagesByRole pr 
		INNER JOIN ERS_Pages p ON p.PageId = pr.PageId 
		WHERE pr.RoleId IN (SELECT RoleId 
							FROM ERS_Roles 
							WHERE RoleName = 'Read Only' 
							AND TrustId = @TrustId)
		GROUP BY p.AppPageName
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT 1
				  FROM ERS_Roles er, ERS_Users eu                                               
				  WHERE eu.UserID = @UserId
				  AND er.RoleName = 'GlobalAdmin'
				  AND (',' + RTRIM(eu.RoleID) + ',') LIKE '%,' + CAST(er.RoleId AS VARCHAR)+ ',%')
		BEGIN
			SELECT DISTINCT p.AppPageName, 
					9 As AccessLevel 
			FROM ERS_Pages p 
		END
		ELSE
		BEGIN									     
			SELECT @CreateProcureAccessLevel = MAX(epr.AccessLevel) 
			FROM ERS_Pages ep, 
				 ERS_PagesByRole epr, 
				 ERS_Users eu                                               
			WHERE ep.PageId = epr.PageId
			AND ep.AppPageName = 'create_procedure'
			AND eu.UserID = @UserId
			AND (',' + RTRIM(eu.RoleID) + ',') LIKE '%,' + CAST(epr.RoleId AS VARCHAR)+ ',%'

			Select * from (
			SELECT ep.apppagename, MAX( CASE WHEN ep.GroupId in (5, 6) THEN @CreateProcureAccessLevel 
										ELSE  epr.AccessLevel
										END ) AccessLevel
			FROM ERS_Pages ep, 
					ERS_PagesByRole epr, 
					ERS_Users eu                                               
			WHERE ep.PageId = epr.PageId
			AND eu.UserID = @UserId
			AND (',' + RTRIM(eu.RoleID) + ',') LIKE '%,' + CAST(epr.RoleId AS VARCHAR)+ ',%'
			GROUP BY apppagename
			
			union select ep.apppagename, (Select max(pbr.AccessLevel) 
										  from ERS_Pages p 
										  join ERS_PagesByRole pbr on p.PageId = pbr.PageId 
										  where p.AppPageName='create_procedure') AccessLevel
			from ERS_Pages ep, ERS_Users eu    
			where ep.GroupId in (5, 6)
			and eu.UserID = @UserId) as a
			where AccessLevel is not null
		END
	END
END
GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	Partha Kundu	On 22  August 2023
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson 08.09.23
-- TFS#	3129
-- Description of change
-- Therapeutics set for Broncs and Cysto
------------------------------------------------------------------------------------------------------------------------
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'Bronchs' AND object_id = OBJECT_ID('ERS_TherapeuticTypes'))
BEGIN
	ALTER TABLE dbo.ERS_TherapeuticTypes
	ADD Bronchs BIT NOT NULL CONSTRAINT [DF_ERS_TherapeuticTypes_Bronchs] DEFAULT 0
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'Cysto' AND object_id = OBJECT_ID('ERS_TherapeuticTypes'))
BEGIN
	ALTER TABLE dbo.ERS_TherapeuticTypes
	ADD Cysto BIT NOT NULL CONSTRAINT [DF_ERS_TherapeuticTypes_Cysto] DEFAULT 0
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'Bronch_Flexi' AND object_id = OBJECT_ID('ERS_TherapeuticTypes'))
BEGIN
	ALTER TABLE dbo.ERS_TherapeuticTypes
	ADD Bronch_Flexi BIT NOT NULL CONSTRAINT [DF_ERS_TherapeuticTypes_Bronch_Flexi] DEFAULT 0
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'Bronch_Rigid' AND object_id = OBJECT_ID('ERS_TherapeuticTypes'))
BEGIN
	ALTER TABLE dbo.ERS_TherapeuticTypes
	ADD Bronch_Rigid BIT NOT NULL CONSTRAINT [DF_ERS_TherapeuticTypes_Bronch_Rigid] DEFAULT 0
END
GO

UPDATE ERS_TherapeuticTypes
SET Bronchs = 1
WHERE Description IN ('Argon beam diathermy', 'Foreign body removal', 'Flatus tube insertion', 'Injection therapy')


IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'Cysto' AND object_id = OBJECT_ID('ERS_TherapeuticTypes'))
BEGIN
	ALTER TABLE dbo.ERS_TherapeuticTypes
	ADD Cysto BIT NOT NULL CONSTRAINT [DF_ERS_TherapeuticTypes_Cysto] DEFAULT 0
END
GO

UPDATE ERS_TherapeuticTypes
SET Cysto = 1
WHERE Description IN ('Diathermy', 'YAG Laser')
GO

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER PROCEDURE [dbo].[GetTherapeuticTypes]
	@procedureId AS int
AS



BEGIN

	DECLARE @sqlString NVARCHAR(1000)

	SELECT @sqlString = 
		'SELECT 
			[Id],
			[Description],
			[NedName],		
			[OGD],
			[ERCP],
			[Colon],
			[Flexi],
			[SchedulerTherapeutic],
			[WhoUpdatedId],
			[WhoCreatedId],
			[WhenCreated],
			[WhenUpdated],
			[Proct],
			[EUS],
			[EUS_HPB],	
			[Antegrade],
			[Retrograde],
			[Bronchs],
			[Cysto]
		FROM
			dbo.ERS_TherapeuticTypes 
		WHERE 
			[Id] NOT IN (1, 2) AND
			[SchedulerTherapeutic] = 1'
			
	IF @procedureId = 1 
		SELECT @sqlString = @sqlString + ' AND [OGD] = 1'
	ELSE IF @procedureId = 2
		SELECT @sqlString = @sqlString + ' AND [ERCP] = 1'
	ELSE IF @procedureId = 3
		SELECT @sqlString = @sqlString + ' AND [COLON] = 1'
	ELSE IF @procedureId = 4
		SELECT @sqlString = @sqlString + ' AND [FLEXI] = 1'
	ELSE IF @procedureId = 5
		SELECT @sqlString = @sqlString + ' AND [PROCT] = 1'
	ELSE IF @procedureId = 6
		SELECT @sqlString = @sqlString + ' AND [EUS] = 1'
	ELSE IF @procedureId = 7
		SELECT @sqlString = @sqlString + ' AND [EUS_HPB] = 1'
	ELSE IF @procedureId = 8
		SELECT @sqlString = @sqlString + ' AND [Antegrade] = 1'		
	ELSE IF @procedureId = 9
		SELECT @sqlString = @sqlString + ' AND [Retrograde] = 1'		
	ELSE IF @procedureId IN (10, 11)
		SELECT @sqlString = @sqlString + ' AND [Bronchs] = 1'		
	ELSE IF @procedureId IN (13,14)
		SELECT @sqlString = @sqlString + ' AND [Cysto] = 1'			
			
	SELECT @sqlString = @sqlString + ' ORDER BY [Description]'
		
	EXEC sp_executesql @sqlString
	
END
GO

PRINT N'Altering Function [dbo].[tvfNED_ProcedureTherapeutic]...';


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
				CASE WHEN (@ProcedureType IN (1,3,4,8,9) AND UT.StentRemoval = 0 AND UT.StentInsertion = 1) OR 
						  (@ProcedureType = 2 AND (ER.StentRemoval = 0 AND ER.StentInsertion = 1) AND LOWER(ERRegions.Area)<>'biliary' AND LOWER(ERRegions.Area)<>'pancreas') /**/ THEN 41 END		AS StentPlacement,
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


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO


------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Steve 03/07/23
-- TFS#	1591
-- Description of change
-- Ability to edit create procedure page after the fact
--  Add get_SelectedStaffForProcedureId to enable adding selected staff to a dropdown if they wouldn't normally show (supressed, not available for hospital etc.)
--  Add GetProcedureDetails stored Procedure, this was previously a string within the application code
--  
------------------------------------------------------------------------------------------------------------------------
GO
PRINT N'Begining Updates for TFS# 1591';

GO
PRINT N'  Altering [dbo].[get_SelectedStaffForProcedureId]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'get_SelectedStaffForProcedureId',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
					 
GO

/****** Object:  StoredProcedure [dbo].[get_SelectedStaffForProcedureId]    Script Date: 10/07/2023 09:41:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[get_SelectedStaffForProcedureId]
(
	@ConsultantType AS VARCHAR(20),
	@ProcedureID as integer
)
AS
-- =============================================
-- Author:		Mahfuz
-- Create date: 22 Mar 2022
-- Get the used Staffs in a Procedure to add in combo box if it is filtered out by Hospital
-- =============================================

BEGIN
	SET NOCOUNT ON;
	
	Declare @Consultant VARCHAR(20) = LOWER(@ConsultantType);
    WITH AllConsultants AS(	-- This CTE will make the primary list - with Operators Only- Consultants and Nurses! On the later SELECT atatement- you can do further filer on Consulant OR Nurse!
	select -- ERS Consultants!
		  distinct U.UserId
		, LTRIM(Surname) + 
				CASE WHEN ISNULL(LTRIM(Forename),'') = '' THEN '' 
						ELSE ', ' + LTRIM(Forename)	
				END	AS Consultant	
		, U.JobTitleID					AS TitleId
		, IsNull(T.Description, '')		AS Consultant_Title
		, IsListConsultant
		, IsNull(IsEndoscopist1,0)	AS IsEndoscopist1
		, IsNUll(IsEndoscopist2,0)	AS IsEndoscopist2
		, IsAssistantOrTrainee AS IsNurse1

		, IsNull(IsNurse1,0)		AS IsNurse2
		, IsNull(IsNurse2,0)		AS IsNurse3
		, IsNull(IsNurse2,0)		AS IsNurse4
	FROM  dbo.ERS_Users AS U
		 INNER JOIN dbo.ERS_UserOperatingHospitals euoh ON u.UserID = euoh.UserId 
		LEFT JOIN [dbo].[ERS_JobTitles] AS T ON	 U.JobTitleID = T.JobTitleID
		    WHERE ( ISNULL(U.IsListConsultant, 0)	= 1 OR
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
			(
			(@Consultant='all'						AND (1=1)) 	-- Select All Endoscopist/Nurses
				OR
			((@Consultant LIKE '%list%')			AND ( Con.IsListConsultant = 1) and UserId in (Select ListConsultant from ERS_Procedures Where ProcedureId = @ProcedureID))
				OR 
			((@Consultant LIKE '%endoscopist1%')	AND ( Con.IsEndoscopist1 = 1) and UserId in (Select Endoscopist1 from ERS_Procedures Where ProcedureId = @ProcedureID))
				OR 
			((@Consultant LIKE '%endoscopist2%')	AND ( Con.IsEndoscopist2 = 1) and UserId in (Select Endoscopist2 from ERS_Procedures Where ProcedureId = @ProcedureID))
				OR
			((@Consultant LIKE '%nurse1%')		AND ( Con.IsNurse1 = 1) and UserId in (Select Nurse1 from ERS_Procedures Where ProcedureId = @ProcedureID))
				OR 
			((@Consultant LIKE '%nurse2%')			AND ( Con.IsNurse2 = 1) and UserId in (Select Nurse2 from ERS_Procedures Where ProcedureId = @ProcedureID))
				OR 			  
			((@Consultant LIKE '%nurse3')			AND ( Con.IsNurse3 = 1) and UserId in (Select Nurse3 from ERS_Procedures Where ProcedureId = @ProcedureID))
				OR 			  
			((@Consultant LIKE '%nurse4')			AND ( Con.IsNurse4 = 1) and UserId in (Select Nurse4 from ERS_Procedures Where ProcedureId = @ProcedureID))
			)

	ORDER BY Consultant
	END
GO

PRINT N'  Altering [dbo].[GetProcedureDetails]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'GetProcedureDetails',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
					 
GO
/****** Object:  StoredProcedure [dbo].[GetProcedureDetails]    Script Date: 05/07/2023 13:36:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetProcedureDetails]
(
	@ProcedureID		AS INT

)
AS
BEGIN
	SELECT
		P.ListType, 
		p.[ListConsultant], 
		(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[ListConsultant]) AS ListConsultantName,
		(SELECT ISNULL(u.GMCCode, '') FROM ERS_Users u WHERE u.UserID = p.[ListConsultant]) AS ListConsultantGMCCode,
		p.[Endoscopist1], p.Endo1Role,
		(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Endoscopist1]) AS Endoscopist1Name,
		(SELECT ISNULL(u.GMCCode, '') FROM ERS_Users u WHERE u.UserID = p.[Endoscopist1]) AS Endoscopist1GMCCode,
		p.[Endoscopist2], 
		p.Endo2Role,
		(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Endoscopist2]) AS Endoscopist2Name,
		(SELECT ISNULL(u.GMCCode, '') FROM ERS_Users u WHERE u.UserID = p.[Endoscopist2]) AS Endoscopist2GMCCode,
		ISNULL(p.[Nurse1],0) AS Nurse1,(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Nurse1]) AS Nurse1Name,
		ISNULL(p.[Nurse2],0) AS Nurse2 ,(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Nurse2]) AS Nurse2Name,
		ISNULL(p.[Nurse3],0) AS Nurse3 ,(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Nurse3]) AS Nurse3Name ,
		ISNULL(p.[Nurse4],0) AS Nurse4 ,(SELECT ISNULL(u.Title, '') + ISNULL(' ' + u.Forename, '') + ' ' + u.Surname AS UserFullName FROM ERS_Users u WHERE u.UserID = p.[Nurse4]) AS Nurse4Name 
	FROM 
		ERS_Procedures p 
	WHERE
		p.ProcedureId = @ProcedureId
END

GO



GO
PRINT N'Finished Updates for TFS# 1591';

GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	1591
------------------------------------------------------------------------------------------------------------------------

GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson 11.09.23
-- TFS#	
-- Description of change
-- Missing foriegn keys an indexs
------------------------------------------------------------------------------------------------------------------------
GO


PRINT N'Dropping Foreign Key [dbo].[FK_ERS_Appointments_DiaryId]...';


GO
IF OBJECT_ID('FK_ERS_Appointments_DiaryId') IS NOT NULL	
	ALTER TABLE [dbo].[ERS_Appointments] DROP CONSTRAINT [FK_ERS_Appointments_DiaryId];


GO
PRINT N'Creating Index [dbo].[ERS_SCH_ListSlots].[IX_ERS_SCH_ListSlots_1]...';


GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ERS_SCH_ListSlots_1' AND object_id = OBJECT_ID('dbo.ERS_SCH_ListSlots'))
	CREATE NONCLUSTERED INDEX [IX_ERS_SCH_ListSlots_1]
		ON [dbo].[ERS_SCH_ListSlots]([IsOverBookedSlot] ASC);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_Appointments_ERS_Appointments]...';


GO
IF OBJECT_ID('FK_ERS_Appointments_ERS_Appointments') IS NULL
	ALTER TABLE [dbo].[ERS_Appointments] WITH NOCHECK
		ADD CONSTRAINT [FK_ERS_Appointments_ERS_Appointments] FOREIGN KEY ([AppointmentId]) REFERENCES [dbo].[ERS_Appointments] ([AppointmentId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_Appointments_ERS_SCH_DiaryPages]...';


GO

IF OBJECT_ID('FK_ERS_Appointments_ERS_SCH_DiaryPages') IS NOT NULL
	ALTER TABLE [dbo].[ERS_Appointments] 
		DROP CONSTRAINT [FK_ERS_Appointments_ERS_SCH_DiaryPages];


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_Appointments_ERS_SCH_ListSlots]...';


GO
IF OBJECT_ID('FK_ERS_Appointments_ERS_SCH_ListSlots') IS NULL
	ALTER TABLE [dbo].[ERS_Appointments] WITH NOCHECK
		ADD CONSTRAINT [FK_ERS_Appointments_ERS_SCH_ListSlots] FOREIGN KEY ([ListSlotId]) REFERENCES [dbo].[ERS_SCH_ListSlots] ([ListSlotId]);


GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson 11.09.23
-- TFS#	3204
-- Description of change
-- New SP for available slot search
------------------------------------------------------------------------------------------------------------------------
GO


PRINT N'Altering Procedure [dbo].[sch_get_day_diary]...';


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER OFF;


GO


ALTER PROCEDURE [dbo].[sch_get_day_diary]
(
	@OperatingHospitalID INT,
	@DiaryDate datetime,
	@RoomIds VARCHAR(MAX)
)
AS

	IF OBJECT_ID ('tempdb..#tmpDiaryRooms') IS NOT NULL
		DROP TABLE #tmpDiaryRooms

	SELECT Item
	INTO #tmpDiaryRooms
	FROM dbo.fnSplitString(@RoomIds, ',')

	SELECT DISTINCT
		d.DiaryId,
		d.DiaryStart,
		d.[DiaryEnd],
		d.[UserID], 
		d.[RoomID], 
		d.ListRulesId, 
		s.SlotMinutes as [Minutes],
		CASE WHEN ept.ProcedureType IS NULL THEN ss.Description 
		ELSE 'Reserved for ' + ss.Description + ' '+ ept.ProcedureType END AS [Subject],
		ss.Description,
		ISNULL(s.ProcedureTypeID,0) AS ProcedureTypeID,
		s.ListSlotId,
		ss.ForeColor,
		ss.StatusId,
		ISNULL(s.Points, 1) AS Points,
		ISNULL(l.Endoscopist,0) AS EndoscopistId,
		(CASE WHEN  ISNULL(u.Title,'') <> '' THEN u.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Forename,'') <> '' THEN u.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Surname,'') <> '' THEN u.Surname + ' ' ELSE '' END) as EndoscopistName,
	  (CASE WHEN  ISNULL(c.Title,'') <> '' THEN c.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(c.Forename,'') <> '' THEN c.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(c.Surname,'') <> '' THEN c.Surname + ' ' ELSE '' END) as ListConsultant,
		l.ListName,
		(CASE WHEN  ISNULL(u.Title,'') <> '' THEN u.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Forename,'') <> '' THEN u.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Surname,'') <> '' THEN u.Surname + ' ' ELSE '' END) +
	  '  [' + CONVERT(VARCHAR(5),cast(d.DiaryStart as time)) + '-' + CONVERT(VARCHAR(5),cast(d.[DiaryEnd] as time)) + ']' +
	  CASE WHEN  ISNULL(l.Points,0) <> 0 THEN '  [' + CONVERT(VARCHAR, l.Points) + ' slots]' ELSE '' END  AS ListDescription
		,d.suppressed
		,d.SuppressedFromDate
		,d.Training
		,l.GIProcedure
		,ISNULL(apt.AppointmentId, 0) AppointmentId
		,apt.StartDateTime AppointmentStart
		,ISNULL(apt.TotalPoints,0) AppointmentPoints
		,ISNULL(apt.AppointmentDuration,0) AppointmentDuration
		,DATEADD(minute, convert(int, apt.AppointmentDuration), apt.StartDateTime) AppointmentEnd
		,ISNULL(apt.StatusCode,'') AppointmentStatusCode
		,ISNULL(apt.Notes,'') AppointmentNotes
		,p.HospitalNumber + ' - ' + p.Forename1 + ' ' + p.Surname + '<br />' + apt.Description + ' '+ STUFF(REPLACE(apt.Procs, CHAR(10), '+'), LEN(apt.procs),1,'') AS [AppointmentSubject]
		,ISNULL(apt.GeneralInformation, '') GeneralInformation
		,s.Locked
		,d.OperatingHospitalId
		,ISNULL(d.RecurrenceParentID,0)RecurrenceParentID
		,ISNULL(d.locked,0) LockedDiary
		,r.RoomName
	FROM ERS_SCH_DiaryPages d
		INNER JOIN #tmpDiaryRooms tr ON tr.Item = d.RoomID
		INNER JOIN dbo.ERS_SCH_Rooms r ON r.RoomId = tr.Item
		INNER JOIN ERS_SCH_ListRules l ON l.ListRulesId = d.ListRulesId
		INNER JOIN ERS_SCH_ListSlots s ON d.ListRulesId = s.ListRulesId AND s.Active = 1
		INNER JOIN dbo.ERS_SCH_SlotStatus ss ON ss.StatusId = s.SlotId
		LEFT JOIN dbo.ERS_ProcedureTypes ept ON s.ProceduretypeId = ept.ProcedureTypeId
		LEFT JOIN ERS_Users u ON u.UserID = d.UserId
		LEFT JOIN ERS_Users c ON c.UserID = d.ListConsultantId
		--LEFT JOIN ERS_Appointments a ON a.DiaryId = d.DiaryId and a.ListSlotId = s.ListSlotId AND ISNULL(a.AppointmentStatusId,0) <> dbo.fnSCHAppointmentStatusId('C')
		--LEFT JOIN (SELECT apt.AppointmentID, sum(Points) TotalPoints, sum(Minutes) TotalMinutes FROM ERS_AppointmentProcedureTypes apt GROUP BY AppointmentId) apt on apt.AppointmentID = a.AppointmentId
		LEFT JOIN (SELECT ea.AppointmentId, SUM(eapt.Points) AS TotalPoints, SUM(eapt.Minutes) AS TotalMinutes, ea.ListSlotId, ea.DiaryId, MAX(aps.HDCKEY) StatusCode, ass.Description, ea.PatientId,ea.GeneralInformation, ea.Notes, ea.AppointmentDuration,ea.StartDateTime,
						(SELECT
							AppointmentProcedures + char(10) AS [text()] 
						FROM dbo.SCH_AppointmentProcedures(ea.AppointmentId)
						WHERE AppointmentId = ea.AppointmentId
						FOR XML PATH('')) AS procs
					FROM dbo.ERS_Appointments ea
						INNER JOIN dbo.ERS_AppointmentProcedureTypes eapt ON ea.AppointmentId = eapt.AppointmentID
						INNER JOIN dbo.ERS_SCH_SlotStatus ass ON ea.SlotStatusID = ass.StatusId
						LEFT JOIN ERS_AppointmentStatus aps on aps.UniqueId = ea.AppointmentStatusId
					 WHERE ISNULL(aps.HDCKEY,'') <> 'C'
					GROUP BY ea.AppointmentId, ea.ListSlotId, ea.DiaryId, ass.Description, ea.PatientId,ea.GeneralInformation, ea.Notes, ea.AppointmentDuration,ea.StartDateTime) AS apt 
											ON apt.DiaryId = d.DiaryId and  apt.ListSlotId = s.ListSlotId
		LEFT JOIN ERS_Patients p ON p.patientId = apt.PatientId
	WHERE d.OperatingHospitalId = @OperatingHospitalID AND convert(varchar(10), DiaryStart, 103) = convert(varchar(10), @DiaryDate, 103)
	ORDER BY d.DiaryId, s.ListSlotId
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON;


GO

EXEC dbo.DropIfExist @ObjectName = 'sch_search_available_slots',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
CREATE PROCEDURE dbo.sch_search_available_slots
(
	@ProcedureTypes varchar(100) = NULL,
	@TherapeuticTypes AS varchar(100) = NULL,
	@Slots varchar(100) = NULL,
	@Endoscopist varchar(100) = NULL,
	@SearchStartDate datetime,
	@OperatingHospitalIDs as varchar(100),
	@ExcludeTraining bit
)
AS



	IF OBJECT_ID('tmpdb..#tmpEndos') IS NOT NULL DROP TABLE #tmpEndos
	SELECT * INTO #tmpEndos FROM fnSplitString(@Endoscopist, ',')

	IF OBJECT_ID('tmpdb..#tmpProcTypes') IS NOT NULL DROP TABLE #tmpProcTypes
	SELECT * INTO #tmpProcTypes FROM fnSplitString(ISNULL(@ProcedureTypes,''), ',')

	IF OBJECT_ID('tmpdb..#tmpProcTherapTypes') IS NOT NULL DROP TABLE #tmpProcTherapTypes
	SELECT * INTO #tmpProcTherapTypes FROM fnSplitString(ISNULL(@TherapeuticTypes,''), ',')

	IF OBJECT_ID('tmpdb..#tmpSlotTypes') IS NOT NULL DROP TABLE #tmpSlotTypes
	SELECT * INTO #tmpSlotTypes FROM fnSplitString(ISNULL(@Slots,''), ',')

	IF OBJECT_ID('tmpdb..#tmpOperatingHospitals') IS NOT NULL DROP TABLE #tmpOperatingHospitals
	SELECT * INTO #tmpOperatingHospitals FROM fnSplitString(ISNULL(@OperatingHospitalIDs,''), ',')



	SELECT DISTINCT
		d.DiaryId,
		d.DiaryStart,
		d.[DiaryEnd],
		d.[UserID], 
		d.[RoomID], 
		d.ListRulesId, 
		s.SlotMinutes AS [Minutes],
		CASE WHEN ept.ProcedureType IS NULL THEN ss.Description 
		ELSE 'Reserved for ' + ss.Description + ' '+ ept.ProcedureType END AS [Subject],
		ss.Description,
		ISNULL(s.ProcedureTypeID,0) AS ProcedureTypeID,
		ISNULL(ept.ProcedureType, '') AS ProcedureType,
		s.ListSlotId,
		ss.ForeColor,
		ss.StatusId,
		ISNULL(s.Points, 1) AS Points,
		ISNULL(l.Endoscopist,0) AS EndoscopistId,
		(CASE WHEN  ISNULL(u.Title,'') <> '' THEN u.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Forename,'') <> '' THEN u.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Surname,'') <> '' THEN u.Surname + ' ' ELSE '' END) AS EndoscopistName,
	  (CASE WHEN  ISNULL(c.Title,'') <> '' THEN c.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(c.Forename,'') <> '' THEN c.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(c.Surname,'') <> '' THEN c.Surname + ' ' ELSE '' END) AS ListConsultant,
		l.ListName,
		(CASE WHEN  ISNULL(u.Title,'') <> '' THEN u.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Forename,'') <> '' THEN u.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Surname,'') <> '' THEN u.Surname + ' ' ELSE '' END) +
	  '  [' + CONVERT(VARCHAR(5),CAST(d.DiaryStart AS TIME)) + '-' + CONVERT(VARCHAR(5),CAST(d.[DiaryEnd] AS TIME)) + ']' +
	  CASE WHEN  ISNULL(l.Points,0) <> 0 THEN '  [' + CONVERT(VARCHAR, l.Points) + ' slots]' ELSE '' END  AS ListDescription
		,d.suppressed
		,d.SuppressedFromDate
		,d.Training
		,l.GIProcedure
		,ISNULL(apt.AppointmentId, 0) AppointmentId
		,apt.StartDateTime AppointmentStart
		,ISNULL(apt.TotalPoints,0) AppointmentPoints
		,ISNULL(apt.AppointmentDuration,0) AppointmentDuration
		,DATEADD(minute, convert(int, apt.AppointmentDuration), apt.StartDateTime) AppointmentEnd
		,ISNULL(apt.StatusCode,'') AppointmentStatusCode
		,ISNULL(apt.Notes,'') AppointmentNotes
		,p.HospitalNumber + ' - ' + p.Forename1 + ' ' + p.Surname + '<br />' + apt.Description + ' '+ STUFF(REPLACE(apt.Procs, CHAR(10), '+'), LEN(apt.procs),1,'') AS [AppointmentSubject]
		,ISNULL(apt.GeneralInformation, '') GeneralInformation
		,s.Locked
		,d.OperatingHospitalId
		,ISNULL(d.RecurrenceParentID,0)RecurrenceParentID
		,ISNULL(d.locked,0) LockedDiary
		,ISNULL(gt.Code, '') ListGender
		,RoomName
	FROM ERS_SCH_DiaryPages d
		INNER JOIN (SELECT DISTINCT r.ListRulesId--, r.Points, r.ListName, s.SlotMinutes, s.ProcedureTypeId
						FROM dbo.ERS_SCH_ListRules r
						INNER JOIN dbo.ERS_SCH_ListSlots s ON s.ListRulesId = r.ListRulesId
						WHERE s.ProcedureTypeId IN (SELECT item FROM #tmpProcTypes) AND s.Active = 1) ls ON ls.ListRulesId = d.ListRulesId
		INNER JOIN ERS_SCH_ListRules l ON l.ListRulesId = ls.ListRulesId
		INNER JOIN ERS_SCH_ListSlots s ON ls.ListRulesId = s.ListRulesId AND s.Active = 1
		INNER JOIN dbo.ERS_SCH_SlotStatus ss ON ss.StatusId = s.SlotId
		LEFT JOIN dbo.ERS_ProcedureTypes ept ON s.ProceduretypeId = ept.ProcedureTypeId
		LEFT JOIN ERS_Users u ON u.UserID = d.UserId
		LEFT JOIN ERS_Users c ON c.UserID = d.ListConsultantId
		LEFT JOIN (SELECT ea.AppointmentId, SUM(eapt.Points) AS TotalPoints, SUM(eapt.Minutes) AS TotalMinutes, ea.ListSlotId, ea.DiaryId, MAX(aps.HDCKEY) StatusCode, ass.Description, ea.PatientId,ea.GeneralInformation, ea.Notes, ea.AppointmentDuration,ea.StartDateTime,
						(SELECT
							AppointmentProcedures + char(10) AS [text()] 
						FROM dbo.SCH_AppointmentProcedures(ea.AppointmentId)
						WHERE AppointmentId = ea.AppointmentId
						FOR XML PATH('')) AS procs
					FROM dbo.ERS_Appointments ea
						INNER JOIN dbo.ERS_AppointmentProcedureTypes eapt ON ea.AppointmentId = eapt.AppointmentID
						INNER JOIN dbo.ERS_SCH_SlotStatus ass ON ea.SlotStatusID = ass.StatusId
						LEFT JOIN ERS_AppointmentStatus aps on aps.UniqueId = ea.AppointmentStatusId
					 WHERE ISNULL(aps.HDCKEY,'') <> 'C'
					GROUP BY ea.AppointmentId, ea.ListSlotId, ea.DiaryId, ass.Description, ea.PatientId,ea.GeneralInformation, ea.Notes, ea.AppointmentDuration,ea.StartDateTime) AS apt 
											ON apt.DiaryId = d.DiaryId and  apt.ListSlotId = s.ListSlotId
		LEFT JOIN ERS_Patients p ON p.patientId = apt.PatientId
		LEFT JOIN dbo.ERS_GenderTypes gt ON gt.GenderId = d.ListGenderId
		INNER JOIN ERS_SCH_Rooms r ON r.RoomId = d.RoomID
	WHERE 
	d.Suppressed = 0 AND
	(d.DiaryStart >= @SearchStartDate) AND d.OperatingHospitalId IN (SELECT item FROM #tmpOperatingHospitals)
		--AND ((s.ProcedureTypeID IN (SELECT item FROM #tmpProcTypes)) OR ((ISNULL(@ProcedureTypes,'') = '' OR ISNULL(@ProcedureTypes,'') = '0') AND 1=1 ))
		AND ((((ISNULL(@Endoscopist,'') <> '' AND d.UserID IN (SELECT item FROM #tmpEndos)) OR (ISNULL(@Endoscopist,'') = '' AND 1=1))) OR ISNULL(d.UserID,'') ='')
		AND (s.SlotId IN (SELECT item FROM #tmpSlotTypes) OR (ISNULL(@Slots,'') = '' AND 1=1)) --if Slot type specified
		AND d.Training = CASE WHEN @ExcludeTraining = 1 THEN 0 ELSE d.Training END
		AND IsNull(d.Locked, 0) = 0  
	ORDER BY d.DiaryId, s.ListSlotId
GO



------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Steve 07/09/23
-- TFS#	1806
-- Description of change
-- SE V2 letter printing
------------------------------------------------------------------------------------------------------------------------
GO
PRINT N'Starting updates for TFS# 1806...';

GO
--Adding WhoPrinted column in ERS_Practices table
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'WhoPrinted' AND Object_ID = Object_ID(N'ERS_LetterQueue'))
BEGIN
	PRINT '  Adding Column WhoPrinted to ERS_LetterQueue table'
	ALTER TABLE [dbo].[ERS_LetterQueue]
	   Add WhoPrinted varchar(100) null
	END

GO
--Adding WhoEdited column in ERS_Practices table
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'WhoEdited' AND Object_ID = Object_ID(N'ERS_LetterQueue'))
BEGIN
	PRINT '  Adding Column WhoEdited to ERS_LetterQueue table'
	ALTER TABLE [dbo].[ERS_LetterQueue]
	   Add WhoEdited varchar(100) null
	END
	
GO
--Adding PrintCount column in ERS_Practices table
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'PrintCount' AND Object_ID = Object_ID(N'ERS_LetterQueue'))
BEGIN
	PRINT '  Adding Column PrintCount to ERS_LetterQueue table'
	ALTER TABLE [dbo].[ERS_LetterQueue]
	   Add PrintCount INT NOT NULL DEFAULT 0
	END

GO
PRINT N'  Altering [dbo].[letGetQueueList]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'letGetQueueList',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO

CREATE PROCEDURE [dbo].[letGetQueueList]
(
	@StartDate DATE,
	@EndDate DATE,
	@IncludePrinted INT,
	@HospitalNumber INT,
	@HospitalIds varchar(100),
	@AppointmentStatusId INT
)
AS
BEGIN
	SELECT 
		AppointmentId,
		lq.OperationalHospitalId,
		LetterQueueId,
		STUFF((SELECT DISTINCT ', ' + HospitalNumber from ERS_PatientTrusts where PatientId = pt.PatientId for xml path('')), 1, 2, '') AS HospitalNumber,
		pt.NHSNo,
		pt.PatientId,
		lq.ProcedureId, 
		lq.AppointmentStatusId,
		pt.Forename1 AS Forname,
		pt.Surname,
		DescriptionForLetter,
		CASE WHEN Printed = 1 THEN 'Yes' ELSE 'No' END AS Printed,
		CASE WHEN Edited = 1 THEN 'Yes' ELSE '' END AS Edited,
		CASE WHEN EditedAfterPrint = 1 THEN 'Yes' ELSE '' END AS EditedAfterPrint,
		lq.whencreated,
		eu.Username AS WhoEdited,
		pu.Username AS WhoPrinted,
		lq.PrintCount
	FROM ERS_LetterQueue lq 
	JOIN ERS_Patients pt ON lq.PatientId = pt.PatientId
	JOIN ERS_AppointmentStatus apptSt ON lq.AppointmentStatusId = apptSt.UniqueId
	LEFT JOIN ERS_Users eu ON lq.WhoEdited = eu.UserID
	LEFT JOIN ERS_Users pu ON lq.WhoPrinted = pu.UserID
	JOIN ERS_LetterType lt ON lt.LetterName = apptSt.DescriptionForLetter AND lt.OperationalHospitalId = lq.OperationalHospitalId
	WHERE lq.whencreated BETWEEN @StartDate AND @EndDate
	AND (Printed = @IncludePrinted OR @IncludePrinted = 1)
	AND (pt.patientId in (Select PatientId from ERS_PatientTrusts where HospitalNumber like @HospitalNumber) OR @HospitalNumber IS NULL)
	AND lq.OperationalHospitalId in ( SELECT item FROM splitString(@HospitalIds, ',') )
	AND (lq.AppointmentStatusId = @AppointmentStatusId OR @AppointmentStatusId = 0)
	AND lt.IsActive = 1
	ORDER BY lq.whencreated DESC
END
GO
PRINT N'  Altering [dbo].[letSaveLetter]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'letSaveLetter',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO

CREATE PROCEDURE [dbo].[letSaveLetter]
(
	@LetterQueueId int,
	@UserId int,
	@LetterContent varbinary(max),
	@PrintOnly int,
	@EditLetterReasonId INT,
	@EditLetterReasonExtraInfo VARCHAR(MAX)
)
AS
BEGIN
	IF @PrintOnly = 1
		UPDATE [ERS_LetterQueue] 
		SET Printed = 1,
			PrintedDate = Getdate(),
			EditedLetterContent = @LetterContent,
			WhoPrinted = @UserId,
			PrintCount = PrintCount + 1
		WHERE LetterQueueId = @LetterQueueId
	ELSE
		UPDATE ERS_LetterQueue 
		set	Edited = 1, 
			Printed = 1 , 
			PrintedDate = Getdate(),
			EditedLetterDate = Getdate(),
			EditedLetterContent = @LetterContent,
			WhoEdited = @UserId,
			WhoPrinted = @UserId,
			PrintCount = PrintCount + 1,
		--If Edited after print
			EditedAfterPrint = CASE WHEN @EditLetterReasonId > 0 THEN 1 ELSE 0 END,
			EditAfterPrintReasonId = CASE WHEN @EditLetterReasonId > 0 THEN @EditLetterReasonId ELSE 0 END,
			EditAfterPrintReasonExtraInfo = ISNULL(@EditLetterReasonExtraInfo, EditAfterPrintReasonExtraInfo),
			EditedDateAfterPrint = Getdate() 
	WHERE LetterQueueId = @LetterQueueId
END

GO
PRINT N'Finished updates for TFS# 1806.';

GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	1806 SE V2 letter printing
------------------------------------------------------------------------------------------------------------------------
GO


------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson
-- TFS#	3251
-- Description of change
-- gets active endoscopists
------------------------------------------------------------------------------------------------------------------------
GO


PRINT N'Creating Procedure [dbo].[get_endoscopists]...';


GO
EXEC dbo.DropIfExist @ObjectName = 'get_endoscopists',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE dbo.get_endoscopists
(
	@TrustId int
)
AS
BEGIN
	Select distinct u.UserID, LTRIM(RTRIM(ISNULL(u.Title, '') + ' ' + ISNULL(u.Forename, '') + ' ' + ISNULL(u.Surname, ''))) AS EndoName, u.Description AS FullName, u.Surname
                        from ERS_USERS u 
                        join ERS_UserOperatingHospitals uoh on u.UserID = uoh.UserId 
                        join ERS_OperatingHospitals oh on uoh.OperatingHospitalId = oh.OperatingHospitalId 
                        WHERE u.Suppressed = 0 AND (IsEndoscopist1 = 1 OR IsEndoscopist2 = 1) AND ISNULL(IsGIConsultant,1) = 1 and oh.TrustId = @TrustId
                         order by u.Surname 
END
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO


------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson
-- TFS#	3246
-- Description of change
-- get active scheduler procedure types
------------------------------------------------------------------------------------------------------------------------
GO

PRINT N'Creating Procedure [dbo].[sch_get_guidelines]...';


GO

EXEC dbo.DropIfExist @ObjectName = 'sch_get_guidelines',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE dbo.sch_get_guidelines
(
	@OperatingHospitalId INT
)
AS
BEGIN
	SELECT 0 AS ProcedureTypeId, '' AS SchedulerProcName UNION SELECT ProcedureTypeId, SchedulerProcName FROM [dbo].[ERS_ProcedureTypes]
             WHERE SchedulerProc = 1 AND IsGI = 1 AND OperatingHospitalId = @OperatingHospitalId ORDER BY ProcedureTypeId
END
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson
-- TFS#	3258
-- Description of change
-- 
------------------------------------------------------------------------------------------------------------------------
GO

PRINT N'Creating Procedure [dbo].[get_hospital_rooms]...';


GO

EXEC dbo.DropIfExist @ObjectName = 'get_hospital_rooms',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[get_hospital_rooms]
(
	@OperatingHospitalIds VARCHAR(MAX)
)
AS
	SELECT RoomId, RoomName 
	FROM dbo.ERS_SCH_Rooms esr
	WHERE esr.HospitalId IN (SELECT Item FROM dbo.fnSplitString(@OperatingHospitalIds,','))
	ORDER BY esr.HospitalId, esr.RoomSortOrder
GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
-----
GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Chris Gammage 14/09/23
-- TFS#	3257
-- Description of change
-- update respitatory schedlering therapeutics
------------------------------------------------------------------------------------------------------------------------
GO

Update ERS_TherapeuticTypes
SET Bronchs = 0
WHERE Description = 'Argon Beam Diathermy'
Update ERS_TherapeuticTypes
SET Bronchs = 0
WHERE Description = 'Foreign body removal'
Update ERS_TherapeuticTypes
SET Bronchs = 0

WHERE Description = 'Injection Therapy'
INSERT INTO ERS_TherapeuticTypes (Description, NedName, SchedulerTherapeutic, Bronchs)
SELECT 'Diathermy Argon Plasma Coag (E48.8+Y10.2/Y17.1)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Diathermy Argon Plasma Coag (E48.8+Y10.2/Y17.1)'
)
UNION ALL
SELECT 'Biopsy of lesion (E49.1)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Biopsy of lesion (E49.1)'
)
UNION ALL
SELECT 'Other specified (E49.8 or E48.8)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Other specified (E49.8 or E48.8)'
)
UNION ALL
SELECT 'Other unspecified (E49.9 or E48.9)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Other unspecified (E49.9 or E48.9)'
)
UNION ALL
SELECT 'Radial EBUS (lung biopsy) (E63.2+E49.1)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Radial EBUS (lung biopsy) (E63.2+E49.1)'
)
UNION ALL
SELECT 'Radial EBUS (brushings) (E63.2+E49.3)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Radial EBUS (brushings) (E63.2+E49.3)'
)
UNION ALL
SELECT 'Cryobiopsy (E49.1+Y13.2)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Cryobiopsy (E49.1+Y13.2)'
)
UNION ALL
SELECT 'Bronchial thermoplasty (E488+Y114+Z245)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Bronchial thermoplasty (E488+Y114+Z245)'
)
UNION ALL
SELECT 'Endobronchial valve (E546+Y748+Y022)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Endobronchial valve (E546+Y748+Y022)'
)
UNION ALL
SELECT 'Research bronchoscopy (Z006)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Research bronchoscopy (Z006)'
)
UNION ALL
SELECT 'Snare resection (E48.1)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Snare resection (E48.1)'
)
UNION ALL
SELECT 'Laser destruction (E48.2)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Laser destruction (E48.2)'
)
UNION ALL
SELECT 'Destruction of lesion (E48.3)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Destruction of lesion (E48.3)'
)
UNION ALL
SELECT 'Aspiration of lower respiratory tract (E48.4)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Aspiration of lower respiratory tract (E48.4)'
)
UNION ALL
SELECT 'Removal of foreign body (E48.5)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Removal of foreign body (E48.5)'
)
UNION ALL
SELECT 'Irrigation of lower respiratory tract (E48.6)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Irrigation of lower respiratory tract (E48.6)'
)
UNION ALL
SELECT 'Single node biopsy (Intermediate HRG) (E63.2+T87.4+Y20.4/Y20.3)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Single node biopsy (Intermediate HRG) (E63.2+T87.4+Y20.4/Y20.3)'
)
UNION ALL
SELECT 'Sampling of lymph nodes (Major HRG) (E63.2+T86.5+Y20.4/Y20.3)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Sampling of lymph nodes (Major HRG) (E63.2+T86.5+Y20.4/Y20.3)'
)
UNION ALL
SELECT 'Bilateral sampling of lymph nodes (Complex HRG) (E63.2+T86.5+Z94.1+Y20.4/Y20.3)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Bilateral sampling of lymph nodes (Complex HRG) (E63.2+T86.5+Z94.1+Y20.4/Y20.3)'
)
UNION ALL
SELECT 'Bronch with Washings (E49.2)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Bronch with Washings (E49.2)'
)
UNION ALL
SELECT 'Bronch with Brushings (R49.3)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Bronch with Brushings (R49.3)'
)  
UNION ALL
SELECT 'Bronch with Brushings + Washings (E49.4)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Bronch with Brushings + Washings (E49.4)'
)   
UNION ALL
SELECT 'Bronch with Biopsy + Brushings + Washings (E49.5)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Bronch with Biopsy + Brushings + Washings (E49.5)'
)
UNION ALL
SELECT 'Bronch with Biopsy + Brushings (Y21.1)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Bronch with Biopsy + Brushings (Y21.1)'
)
UNION ALL
SELECT 'Bronch with Biopsy + Washings (Y21.8)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Bronch with Biopsy + Washings (Y21.8)'
)
UNION ALL
SELECT 'EBUS (E63.2)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'EBUS (E63.2)'
)
UNION ALL
SELECT 'EBUS - TBNA (Y20.4)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'EBUS - TBNA (Y20.4)'
)
UNION ALL
SELECT 'EUS & Biopsy (T87.4)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'EUS & Biopsy (T87.4)'
)
UNION ALL
SELECT 'Trachea (Z24.3)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Trachea (Z24.3)'
) 
UNION ALL
SELECT 'Carina (Z24.4)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Carina (Z24.4)'
) 
UNION ALL
SELECT 'Bronchus (Z24.5)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Bronchus (Z24.5)'
) 
UNION ALL
SELECT 'Lung (Z24.6)', 'None', 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Lung (Z24.6)'
) 
  INSERT INTO ERS_TherapeuticTypes (Description, NedName, SchedulerTherapeutic, OGD, ERCP, Colon, Flexi, EUS, EUS_HPB, Antegrade, Retrograde)
SELECT 'Chromoendoscopy', 'None', 1, 1, 1, 1, 1, 1, 1, 1, 1
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_TherapeuticTypes
    WHERE Description = 'Chromoendoscopy'
)
GO

UPDATE dbo.ERS_TherapeuticTypes
SET
OGD = 0,
ercp = 0,
Colon = 0,
Flexi = 0,
EUS = 0,
EUS_HPB = 0,
Antegrade = 0
WHERE OGD IS NULL
 GO

 
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER PROCEDURE [dbo].[GetTherapeuticTypes]
@procedureId AS int
AS

BEGIN

DECLARE @sqlString NVARCHAR(1000)

SELECT @sqlString =
'SELECT
[Id],
[Description],
[NedName],
[OGD],
[ERCP],
[Colon],
[Flexi],
[SchedulerTherapeutic],
[WhoUpdatedId],
[WhoCreatedId],
[WhenCreated],
[WhenUpdated],
[Proct],
[EUS],
[EUS_HPB],
[Antegrade],
[Retrograde],
[Bronchs],
[Cysto],
[Bronch_Flexi],
[Bronch_Rigid]
FROM
dbo.ERS_TherapeuticTypes
WHERE
[Id] NOT IN (1, 2) AND
[SchedulerTherapeutic] = 1'

IF @procedureId = 1
SELECT @sqlString = @sqlString + ' AND [OGD] = 1'
ELSE IF @procedureId = 2
SELECT @sqlString = @sqlString + ' AND [ERCP] = 1'
ELSE IF @procedureId = 3
SELECT @sqlString = @sqlString + ' AND [COLON] = 1'
ELSE IF @procedureId = 4
SELECT @sqlString = @sqlString + ' AND [FLEXI] = 1'
ELSE IF @procedureId = 5
SELECT @sqlString = @sqlString + ' AND [PROCT] = 1'
ELSE IF @procedureId = 6
SELECT @sqlString = @sqlString + ' AND [EUS] = 1'
ELSE IF @procedureId = 7
SELECT @sqlString = @sqlString + ' AND [EUS_HPB] = 1'
ELSE IF @procedureId = 8
SELECT @sqlString = @sqlString + ' AND [Antegrade] = 1'
ELSE IF @procedureId = 9
SELECT @sqlString = @sqlString + ' AND [Retrograde] = 1'
ELSE IF @procedureId IN (10, 11)
SELECT @sqlString = @sqlString + ' AND [Bronchs] = 1'
ELSE IF @procedureId IN (13,14)
SELECT @sqlString = @sqlString + ' AND [Cysto] = 1'
Else IF @procedureId = 89
SELECT @sqlString = @sqlString + 'AND [Bronch_Flexi] = 1'
Else IF @procedureId = 90
SELECT @sqlString = @sqlString + 'AND [Bronch_Rigid] = 1'

SELECT @sqlString = @sqlString + ' ORDER BY [Description]'

EXEC sp_executesql @sqlString

END
GO
 ------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha Kundu
-- TFS#	3151
-- Description of change Update Patient Data from NIP API
-- 
------------------------------------------------------------------------------------------------------------------------
GO
 
EXEC dbo.DropIfExist @ObjectName = 'stp_InsertUpdatePatientFromNIPAPI',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[stp_InsertUpdatePatientFromNIPAPI]
(
	@PatientId INT=NULL,
	@CaseNoteNo VARCHAR(100),
	@Title VARCHAR(20),
	@Forename VARCHAR(100),
	@Surname NVARCHAR(100),
	@DateOfBirth DATETIME2,
	@NHSNo VARCHAR(20),
	@Address1 NVARCHAR(500),
	@Address2 NVARCHAR(500),
	@Town NVARCHAR(500),
	@County NVARCHAR(500),
	@PostCode VARCHAR(10),
	@PhoneNo VARCHAR(20),
	@Gender VARCHAR(1),
	@EthnicOrigin VARCHAR(100)=NULL,
	@District VARCHAR(50)=NULL,
	@GPGMCCode NVARCHAR(20)=NULL,
	@GPPracticeCode NVARCHAR(20)=NULL,
	@DateOfDeath DATETIME2=NULL,
	@Hospitals INT=NULL,
	@UniqueHospitalId INT=NULL,
	@LoggedInUserId INT,
	@MaritalStatus varchar(100)=null,
	@SearchedNHSNo varchar(100)=null,
	@TrustId INT=NULL
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
       declare @intOurPatientID as int
	   declare @intMaritalStatusId as int

	   declare @GPId as int
	   declare @PracticeId as int

	   
	   If IsNull(@TrustId,0) = 0 or not exists(Select * from ERS_Trusts where TrustID = @TrustId)
	   begin
		Select top 1 @TrustId = TrustID from ERS_Trusts
	   end


	    IF @GPGMCCode is not null 
	   begin
		Select  @GPId = GPId from ERS_GPS where [Code] = @GPGMCCode
	   end
	   IF ISNULL(@GPId,0) = 0 
	      SELECT @GPId = GPId  FROM dbo.ERS_GPS WHERE [Code] = 'G9999998'

	IF @GPPracticeCode is not null 
	   begin
		Select  @PracticeId = PracticeID from ERS_Practices where [Code] = @GPPracticeCode
	   end
	 

	 

	   Select top 1 @intMaritalStatusId = IsNull(MaritalId,0) from dbo.ERS_Marital_Status where [Status] = @MaritalStatus 
	   if IsNull(@intMaritalStatusId,0) = 0
	   begin
		Select top 1 @intMaritalStatusId = IsNull(MaritalId,0) from dbo.ERS_Marital_Status where [Status] Like Convert(varchar(max),@MaritalStatus + '%')
	   end
	   if IsNull(@intMaritalStatusId,0) = 0
	   begin
		Select top 1 @intMaritalStatusId = IsNull(MaritalId,0) from dbo.ERS_Marital_Status where [Status] = 'Unknown'
	   end
	   if IsNull(@intMaritalStatusId,0) = 0
	   begin
		Select top 1 @intMaritalStatusId = IsNull(MaritalId,0) from dbo.ERS_Marital_Status where [Status] = 'Not disclosed'
	   end

     

	   --1. First check with CHI no (our NHSNo) and Full Name and Date Of Birth
	   SELECT @intOurPatientID = PatientId FROM ERS_Patients WHERE Forename1 = @Forename and Surname = @Surname and NHSNo = @NHSNo and DateOfBirth=@DateOfBirth

	   
	   --2. Secondly check with CHI no and Date of Birth
	   IF ISNULL(@intOurPatientID,0)= 0
	   begin
	   SELECT @intOurPatientID = PatientId FROM ERS_Patients WHERE NHSNo = @NHSNo and DateOfBirth=@DateOfBirth
	   end

	   --3. Thirdly check with CHI no
	   IF ISNULL(@intOurPatientID,0)= 0
	   begin
	   SELECT @intOurPatientID = PatientId FROM ERS_Patients WHERE NHSNo = @NHSNo
	   end


	 

      

	IF ISNULL(@intOurPatientID,0)= 0
	BEGIN
		INSERT INTO ERS_Patients (
			HospitalNumber
			,[Title]
			,[Forename1]
			,[Surname]
			,[Dateofbirth]
			,[NHSNo]
			,[Address1]
			,[Address2]
			,[Address3]
			,[Address4]
			,[Postcode]
			,[Telephone]
			,[GenderId]
			,[EthnicId]
			,[MaritalId]
			,[RegGpId]
			,[RegGpPracticeId]
			,[Dateofdeath]
			,[WhoCreatedId]
			,[WhenCreated]
			,[CreateUpdateMethod]
			,[AccountNumber])
		VALUES (
			@CaseNoteNo,
			@Title,
			@Forename,
			@Surname,
			@DateOfBirth,
			@NHSNo,
			@Address1,
			@Address2,
			@Town,
			@County,
			@PostCode,
			@PhoneNo,
			(SELECT GenderId FROM ERS_GenderTypes WHERE Code = @Gender),
			(SELECT EthnicOriginId FROM ERS_EthnicOrigins WHERE EthnicOrigin = @EthnicOrigin),
			@intMaritalStatusId,
			@GPId,
			@PracticeId,
			@DateOfDeath,
			@LoggedInUserId,
			GETDATE(),
			'NIPAPI',
			Cast(@PatientId as varchar(max)))
		SET @intOurPatientID = SCOPE_IDENTITY()

		
		Insert into ERS_PatientTrusts(PatientId,TrustId,HospitalNumber)
		Values(@intOurPatientID,@TrustId,@NHSNo)
	END
	ELSE
	BEGIN
		UPDATE 
			ERS_Patients
		SET 
			Title = @Title,
			Forename1 = @Forename,
			Surname = @Surname,
			[Dateofbirth] = @DateOfBirth,
			[NHSNo] = @NHSNo,
			[Address1] = @Address1,
			[Address2] = @Address2,
			[Address3] = @Town,
			[Address4] = @County,
			[Postcode] = @PostCode,
			[Telephone] = @PhoneNo,
			GenderId = (SELECT top 1 GenderId FROM ERS_GenderTypes WHERE Code = @Gender),
			[EthnicId] = (SELECT top 1 EthnicOriginId FROM ERS_EthnicOrigins WHERE EthnicOrigin = @EthnicOrigin),
			MaritalId = @intMaritalStatusId,
			RegGPId = @GPId,
			RegGpPracticeId = @PracticeId,
			[Dateofdeath] = @DateOfDeath,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = GETDATE(),
			CreateUpdateMethod = 'NIPAPI'
		WHERE 
			[PatientId] = @intOurPatientID

		
			if exists(Select * from ERS_PatientTrusts where PatientId = @intOurPatientID) 
			Begin
				Update ERS_PatientTrusts
				Set HospitalNumber = @NHSNo,
				TrustId = @TrustId
				Where PatientId = @intOurPatientID
			End
			else
			Begin
				Insert into ERS_PatientTrusts(PatientId,TrustId,HospitalNumber)
				Values(@intOurPatientID,@TrustId,@NHSNo)
			End

			

	END

	if ((@SearchedNHSNo is not null) and  @SearchedNHSNo != @NHSNo )
	begin
		Insert into ERS_PatientTrusts(PatientId,TrustId,HospitalNumber,IsMinor)
				Values(@intOurPatientID,@TrustId,@SearchedNHSNo,1)
	end 

	If IsNull(@GPId,0) > 0 and IsNull(@PracticeId,0) > 0 
	Begin
		If Not Exists(Select * from ERS_Practices_Link Where GPId = @GPId and PracticeId = @PracticeId) 
		Begin
			Insert into ERS_Practices_Link(GPId,PracticeId,IsPrimary,WhoCreatedId,WhenCreated)
			Values(@GPId,@PracticeId,1,@LoggedInUserId,getdate())
		End
	End

	SELECT @intOurPatientID
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
 ------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Chris Gammage 14/09/2023
-- TFS#	1830
-- Description of change; remove unneeded procedure types, add in new procedure types for scope mapping and scheding, cross mapping into Point
-- 
------------------------------------------------------------------------------------------------------------------------
GO

DELETE FROM ERS_ProcedureTypes
WHERE ProcedureType = 'BOWEL Screening';

DELETE FROM ERS_ProcedureTypes
WHERE ProcedureType = 'BOWEL Scope';

Declare @MaxTypeID as int
Declare @OperatingHospitalId as int
Declare @OtherOperatingHospitalId as int

declare @UserID as int
declare @ProcedureName as varchar(100)
declare @PointMappingProcedureTypeIdCopyFrom as int

Set @PointMappingProcedureTypeIdCopyFrom = 1 
Set @UserId = (Select UserID from ERS_Users where Username = 'Admin')
set @ProcedureName = 'Transnasal' 

Set @OperatingHospitalId = 1 

Select @MaxTypeID = Max(TypeID)+1 from ERS_ProcedureTypes


If not exists(Select * from ERS_ProcedureTypes Where ProcedureType = @ProcedureName)
begin
	SET IDENTITY_INSERT  dbo.ERS_ProcedureTypes ON;

	Insert into ERS_ProcedureTypes(TypeId,ProcedureTypeID,ProcedureType, ProductTypeId, Suppressed, NedExportRequired, SchedulerProc, SchedulerProcName, SchedulerDiagnostic, SchedulerTherapeutic, IsGI, OperatingHospitalId, HDCKey, HL7Code, WhoCreatedId,WhenCreated)
	Values(@MaxTypeID, @MaxTypeID,@ProcedureName,0,0,0,1,@ProcedureName,1,1,1,@OperatingHospitalId,Null,Null,@UserId,getdate())

	SET IDENTITY_INSERT  dbo.ERS_ProcedureTypes OFF;
End
Else
Begin
	
	Select @MaxTypeID = ProcedureTypeId from ERS_ProcedureTypes Where ProcedureType = @ProcedureName
End

		If not exists(Select * from ERS_SCH_PointMappings Where ProcedureTypeId = @MaxTypeID and OperatingHospitalId = @OperatingHospitalId)
		Begin
			Insert into ERS_SCH_PointMappings([Minutes],OperatingHospitalId,ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints)
			Select [Minutes],OperatingHospitalId,@MaxTypeID as ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints from ERS_SCH_PointMappings where ProcedureTypeId = @PointMappingProcedureTypeIdCopyFrom and OperatingHospitalId = @OperatingHospitalId

		End
		
		Declare  cursorOperatingHospitals Cursor
		For Select OperatingHospitalId from ERS_OperatingHospitals where OperatingHospitalId <> @OperatingHospitalId

		Open cursorOperatingHospitals

		Fetch Next from cursorOperatingHospitals into @OtherOperatingHospitalId

		While @@FETCH_STATUS = 0
		Begin

			If not exists(Select * from ERS_SCH_PointMappings Where ProcedureTypeId = @MaxTypeID and OperatingHospitalId = @OtherOperatingHospitalId)
			Begin
				Insert into ERS_SCH_PointMappings([Minutes],OperatingHospitalId,ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints)
				Select [Minutes],@OtherOperatingHospitalId as OperatingHospitalId,@MaxTypeID as ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints from ERS_SCH_PointMappings where ProcedureTypeId = @PointMappingProcedureTypeIdCopyFrom and OperatingHospitalId = @OperatingHospitalId

			End

			Fetch Next from cursorOperatingHospitals into @OtherOperatingHospitalId
		End
		Close cursorOperatingHospitals
		Deallocate cursorOperatingHospitals
GO

Declare @MaxTypeID as int
Declare @OperatingHospitalId as int
Declare @OtherOperatingHospitalId as int

declare @UserID as int
declare @ProcedureName as varchar(100)
declare @PointMappingProcedureTypeIdCopyFrom as int

Set @PointMappingProcedureTypeIdCopyFrom = 1 

Set @UserId = (Select UserID from ERS_Users where Username = 'Admin')
set @ProcedureName = 'Capsule' 

Set @OperatingHospitalId = 1 

Select @MaxTypeID = Max(TypeID)+1 from ERS_ProcedureTypes

If not exists(Select * from ERS_ProcedureTypes Where ProcedureType = @ProcedureName)
begin
	SET IDENTITY_INSERT  dbo.ERS_ProcedureTypes ON;

	Insert into ERS_ProcedureTypes(TypeId,ProcedureTypeID,ProcedureType, ProductTypeId, Suppressed, NedExportRequired, SchedulerProc, SchedulerProcName, SchedulerDiagnostic, SchedulerTherapeutic, IsGI, OperatingHospitalId, HDCKey, HL7Code, WhoCreatedId,WhenCreated)
	Values(@MaxTypeID, @MaxTypeID,@ProcedureName,0,0,0,1,@ProcedureName,1,1,1,@OperatingHospitalId,Null,Null,@UserId,getdate())

	SET IDENTITY_INSERT  dbo.ERS_ProcedureTypes OFF;
End
Else
Begin
		Select @MaxTypeID = ProcedureTypeId from ERS_ProcedureTypes Where ProcedureType = @ProcedureName
End

		If not exists(Select * from ERS_SCH_PointMappings Where ProcedureTypeId = @MaxTypeID and OperatingHospitalId = @OperatingHospitalId)
		Begin
			Insert into ERS_SCH_PointMappings([Minutes],OperatingHospitalId,ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints)
			Select [Minutes],OperatingHospitalId,@MaxTypeID as ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints from ERS_SCH_PointMappings where ProcedureTypeId = @PointMappingProcedureTypeIdCopyFrom and OperatingHospitalId = @OperatingHospitalId

		End
			
		Declare  cursorOperatingHospitals Cursor
		For Select OperatingHospitalId from ERS_OperatingHospitals where OperatingHospitalId <> @OperatingHospitalId

		Open cursorOperatingHospitals

		Fetch Next from cursorOperatingHospitals into @OtherOperatingHospitalId

		While @@FETCH_STATUS = 0
		Begin

			If not exists(Select * from ERS_SCH_PointMappings Where ProcedureTypeId = @MaxTypeID and OperatingHospitalId = @OtherOperatingHospitalId)
			Begin
				Insert into ERS_SCH_PointMappings([Minutes],OperatingHospitalId,ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints)
				Select [Minutes],@OtherOperatingHospitalId as OperatingHospitalId,@MaxTypeID as ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints from ERS_SCH_PointMappings where ProcedureTypeId = @PointMappingProcedureTypeIdCopyFrom and OperatingHospitalId = @OperatingHospitalId

			End

			Fetch Next from cursorOperatingHospitals into @OtherOperatingHospitalId
		End
		Close cursorOperatingHospitals
		Deallocate cursorOperatingHospitals
Go

 ------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson
-- TFS#	3129
-- Description of change
-- Missing therapeutic set to show in scheduler windows
------------------------------------------------------------------------------------------------------------------------
GO
UPDATE dbo.ERS_TherapeuticTypes
SET SchedulerTherapeutic = 1
WHERE NedName = 'Flatus tube insertion'
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Chris Gammage 14/09/2023
-- TFS#	1830
-- Description of change; remove unneeded procedure types, add in new procedure types for scope mapping and scheding, cross mapping into Point
-- 
------------------------------------------------------------------------------------------------------------------------
GO

DELETE FROM ERS_ProcedureTypes
WHERE ProcedureType = 'BOWEL Screening';

DELETE FROM ERS_ProcedureTypes
WHERE ProcedureType = 'BOWEL Scope';

Declare @MaxTypeID as int
Declare @OperatingHospitalId as int
Declare @OtherOperatingHospitalId as int

declare @UserID as int
declare @ProcedureName as varchar(100)
declare @PointMappingProcedureTypeIdCopyFrom as int

Set @PointMappingProcedureTypeIdCopyFrom = 1 
Set @UserId = (Select UserID from ERS_Users where Username = 'Admin')
set @ProcedureName = 'Transnasal' 

Set @OperatingHospitalId = 1 

Select @MaxTypeID = Max(TypeID)+1 from ERS_ProcedureTypes


If not exists(Select * from ERS_ProcedureTypes Where ProcedureType = @ProcedureName)
begin
	SET IDENTITY_INSERT  dbo.ERS_ProcedureTypes ON;

	Insert into ERS_ProcedureTypes(TypeId,ProcedureTypeID,ProcedureType, ProductTypeId, Suppressed, NedExportRequired, SchedulerProc, SchedulerProcName, SchedulerDiagnostic, SchedulerTherapeutic, IsGI, OperatingHospitalId, HDCKey, HL7Code, WhoCreatedId,WhenCreated)
	Values(@MaxTypeID, @MaxTypeID,@ProcedureName,0,0,0,1,@ProcedureName,1,1,1,@OperatingHospitalId,Null,Null,@UserId,getdate())

	SET IDENTITY_INSERT  dbo.ERS_ProcedureTypes OFF;
End
Else
Begin
	
	Select @MaxTypeID = ProcedureTypeId from ERS_ProcedureTypes Where ProcedureType = @ProcedureName
End

		If not exists(Select * from ERS_SCH_PointMappings Where ProcedureTypeId = @MaxTypeID and OperatingHospitalId = @OperatingHospitalId)
		Begin
			Insert into ERS_SCH_PointMappings([Minutes],OperatingHospitalId,ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints)
			Select [Minutes],OperatingHospitalId,@MaxTypeID as ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints from ERS_SCH_PointMappings where ProcedureTypeId = @PointMappingProcedureTypeIdCopyFrom and OperatingHospitalId = @OperatingHospitalId

		End
		
		Declare  cursorOperatingHospitals Cursor
		For Select OperatingHospitalId from ERS_OperatingHospitals where OperatingHospitalId <> @OperatingHospitalId

		Open cursorOperatingHospitals

		Fetch Next from cursorOperatingHospitals into @OtherOperatingHospitalId

		While @@FETCH_STATUS = 0
		Begin

			If not exists(Select * from ERS_SCH_PointMappings Where ProcedureTypeId = @MaxTypeID and OperatingHospitalId = @OtherOperatingHospitalId)
			Begin
				Insert into ERS_SCH_PointMappings([Minutes],OperatingHospitalId,ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints)
				Select [Minutes],@OtherOperatingHospitalId as OperatingHospitalId,@MaxTypeID as ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints from ERS_SCH_PointMappings where ProcedureTypeId = @PointMappingProcedureTypeIdCopyFrom and OperatingHospitalId = @OperatingHospitalId

			End

			Fetch Next from cursorOperatingHospitals into @OtherOperatingHospitalId
		End
		Close cursorOperatingHospitals
		Deallocate cursorOperatingHospitals
GO

Declare @MaxTypeID as int
Declare @OperatingHospitalId as int
Declare @OtherOperatingHospitalId as int

declare @UserID as int
declare @ProcedureName as varchar(100)
declare @PointMappingProcedureTypeIdCopyFrom as int

Set @PointMappingProcedureTypeIdCopyFrom = 1 

Set @UserId = (Select UserID from ERS_Users where Username = 'Admin')
set @ProcedureName = 'Capsule' 

Set @OperatingHospitalId = 1 

Select @MaxTypeID = Max(TypeID)+1 from ERS_ProcedureTypes

If not exists(Select * from ERS_ProcedureTypes Where ProcedureType = @ProcedureName)
begin
	SET IDENTITY_INSERT  dbo.ERS_ProcedureTypes ON;

	Insert into ERS_ProcedureTypes(TypeId,ProcedureTypeID,ProcedureType, ProductTypeId, Suppressed, NedExportRequired, SchedulerProc, SchedulerProcName, SchedulerDiagnostic, SchedulerTherapeutic, IsGI, OperatingHospitalId, HDCKey, HL7Code, WhoCreatedId,WhenCreated)
	Values(@MaxTypeID, @MaxTypeID,@ProcedureName,0,0,0,1,@ProcedureName,1,1,1,@OperatingHospitalId,Null,Null,@UserId,getdate())

	SET IDENTITY_INSERT  dbo.ERS_ProcedureTypes OFF;
End
Else
Begin
		Select @MaxTypeID = ProcedureTypeId from ERS_ProcedureTypes Where ProcedureType = @ProcedureName
End

		If not exists(Select * from ERS_SCH_PointMappings Where ProcedureTypeId = @MaxTypeID and OperatingHospitalId = @OperatingHospitalId)
		Begin
			Insert into ERS_SCH_PointMappings([Minutes],OperatingHospitalId,ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints)
			Select [Minutes],OperatingHospitalId,@MaxTypeID as ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints from ERS_SCH_PointMappings where ProcedureTypeId = @PointMappingProcedureTypeIdCopyFrom and OperatingHospitalId = @OperatingHospitalId

		End
			
		Declare  cursorOperatingHospitals Cursor
		For Select OperatingHospitalId from ERS_OperatingHospitals where OperatingHospitalId <> @OperatingHospitalId

		Open cursorOperatingHospitals

		Fetch Next from cursorOperatingHospitals into @OtherOperatingHospitalId

		While @@FETCH_STATUS = 0
		Begin

			If not exists(Select * from ERS_SCH_PointMappings Where ProcedureTypeId = @MaxTypeID and OperatingHospitalId = @OtherOperatingHospitalId)
			Begin
				Insert into ERS_SCH_PointMappings([Minutes],OperatingHospitalId,ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints)
				Select [Minutes],@OtherOperatingHospitalId as OperatingHospitalId,@MaxTypeID as ProceduretypeId,Points,WhoCreatedId,WhenCreated,Training,NonGI,TherapeuticMinutes,TherapeuticPoints from ERS_SCH_PointMappings where ProcedureTypeId = @PointMappingProcedureTypeIdCopyFrom and OperatingHospitalId = @OperatingHospitalId

			End

			Fetch Next from cursorOperatingHospitals into @OtherOperatingHospitalId
		End
		Close cursorOperatingHospitals
		Deallocate cursorOperatingHospitals
Go

 ------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson	
-- TFS#	3246
-- Description of change
-- Suppressed check added to where clause
------------------------------------------------------------------------------------------------------------------------
GO


ALTER PROCEDURE dbo.sch_get_guidelines
(
	@OperatingHospitalId INT
)
AS
BEGIN
	SELECT 0 AS ProcedureTypeId, '' AS SchedulerProcName UNION SELECT ProcedureTypeId, SchedulerProcName FROM [dbo].[ERS_ProcedureTypes]
             WHERE Suppressed = 0 AND SchedulerProc = 1 AND IsGI = 1 AND OperatingHospitalId = @OperatingHospitalId ORDER BY ProcedureTypeId
END
GO


ALTER PROCEDURE sch_room_proceduretypes_select
(
	@RoomId int
)
AS
BEGIN
	Select p.ProcedureTypeId, p.ProcedureType, ISNULL(r.RoomProcId,0) As RoomProcId 
	FROM [dbo].[ERS_ProcedureTypes] p 
            LEFT JOIN ERS_SCH_RoomProcedures r On p.ProcedureTypeId = r.ProcedureTypeId And r.RoomId = @RoomId
    WHERE p.Suppressed = 0 and p.SchedulerProc = 1
	UNION
	Select 99,'Other investigations', OtherInvestigations FROM ERS_SCH_Rooms WHERE RoomId = @RoomId
	UNION
	SELECT 99,'Other investigations', 0 WHERE @RoomId = 0 
		ORDER BY p.ProcedureTypeId 

END
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson
-- TFS#	3280
-- Description of change
-- UCEIS points correction
------------------------------------------------------------------------------------------------------------------------
GO


UPDATE dbo.ERS_UCEISScores
SET Points = 0
WHERE Description = 'Normal' AND Points = 1


UPDATE dbo.ERS_UCEISScores
SET Points = 1
WHERE Description = 'Patchy obliteration' AND Points = 2


UPDATE dbo.ERS_UCEISScores
SET Points = 2
WHERE Description = 'Obliterated' AND Points = 3


UPDATE dbo.ERS_UCEISScores
SET Points = 0
WHERE Description = 'None' AND Points = 1


UPDATE dbo.ERS_UCEISScores
SET Points = 1
WHERE Description = 'Mucosal' AND Points = 2


UPDATE dbo.ERS_UCEISScores
SET Points = 2
WHERE Description = 'Luminal mild' AND Points = 3


UPDATE dbo.ERS_UCEISScores
SET Points = 3
WHERE Description = 'Luminal moderate or severe' AND Points = 4


UPDATE dbo.ERS_UCEISScores
SET Points = 1
WHERE Description = 'Erosions' AND Points = 2


UPDATE dbo.ERS_UCEISScores
SET Points = 2
WHERE Description = 'Superficial ulcer' AND Points = 3


UPDATE dbo.ERS_UCEISScores
SET Points = 3
WHERE Description = 'Deep ulcer' AND Points = 4




------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Chris Gammage 19/09/2023
-- TFS#	3279
-- Description of change; Update to ASA name
-- 
------------------------------------------------------------------------------------------------------------------------
GO

 UPDATE ERS_ASAStatus
SET description = 'ASA 1 - Patient is normally healthy'
WHERE UniqueId = 1;

Go


 ------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson
-- TFS#	3182, 3183, 3283, 3186, 3281, 3287, 3284
-- Description of change
-- Calculations corrections, Timing format, Suppressed filters
------------------------------------------------------------------------------------------------------------------------
GO


PRINT N'Altering Procedure [dbo].[report_SCH_Activity]...';


GO
ALTER PROCEDURE [dbo].[report_SCH_Activity]
    @SearchStartDate AS DATE,
    @SearchEndDate AS DATE,
    @OperatingHospitalIds VARCHAR(100),
    @RoomIds VARCHAR(1000)
AS
/***************************************************************************************************************************
--	Update History:
1.		14 Jan 2022		MH added OperatingHospital column in output TFS# 1841
2.		06 Jul 2022		AS improved performance
3.		12 Jul 2022		AS corrected data output
4.		01 Aug 2022		AS Bug fix: increased the size of the OperatingHospitals field in temporary table #ActivityDetails 
						as test data extended past 50 characters.
****************************************************************************************************************************/
BEGIN

SET NOCOUNT ON

    IF OBJECT_ID('tempdb..#ActivityDetails') IS NOT NULL
        DROP TABLE #ActivityDetails;
    IF OBJECT_ID('tempdb..#ListSlots') IS NOT NULL
        DROP TABLE #ListSlots;
    IF OBJECT_ID('tempdb..#Appointments') IS NOT NULL
        DROP TABLE #Appointments;
    IF OBJECT_ID('tempdb..#tmpOperatingHospitals') IS NOT NULL
        DROP TABLE #tmpOperatingHospitals;
    IF OBJECT_ID('tempdb..#tmpRooms') IS NOT NULL
        DROP TABLE #tmpRooms;
	IF OBJECT_ID('tempdb..#Total_Slots') IS NOT NULL
        DROP TABLE #Total_Slots;
	IF OBJECT_ID('tempdb..#No_Of_Patients') IS NOT NULL
        DROP TABLE #No_Of_Patients;		
	IF OBJECT_ID('tempdb..#No_Of_Patient_Pts_Used') IS NOT NULL
        DROP TABLE #No_Of_Patient_Pts_Used;

	CREATE TABLE #ListSLots
	(
		[Id] INT NOT NULL IDENTITY(1, 1),
        [DiaryIdSlotOrder] INT NULL,
        [ListSlotId] INT NULL,
        [ListRulesId] INT NULL,
        [SlotMinutes] INT NULL,
        [Points] INT NULL,
        [DiaryId] INT NULL,
        [StartTime] DATE NULL,
        [EndTime] DATE NULL,
        [Duration] INT NULL,
        [ApptOverFlow] INT NULL,
        [RoomId] INT NULL
	)
	
	CREATE NONCLUSTERED INDEX [IX_ListSlots_SlotMinutes]
		ON [dbo].[#ListSlots] ([DiaryId],[StartTime])
		INCLUDE ([SlotMinutes]);
	
	CREATE TABLE #Total_Slots
	(
	    [ListRulesId] INT NULL,
		[ListCount] INT NULL
	)
	
	INSERT INTO #Total_Slots
	( 
		ListRulesId,
		ListCount
	) 
	( 
		SELECT 
			ListRulesId, 
			COALESCE(COUNT(*), 0)
		FROM 
			dbo.ERS_SCH_ListSlots (NOLOCK) 
		GROUP BY 
			ListRulesId 
	)

	CREATE TABLE #No_Of_Patients
	(
	    [DiaryId] INT NULL,
		[ListCount] INT NULL
	)

	INSERT INTO #No_Of_Patients
	(
		DiaryId,
		ListCount
	)
    (
		SELECT 
			ea.DiaryId,
			COALESCE(COUNT(*), 0) 
		FROM
			dbo.ERS_Appointments AS ea (NOLOCK)
			INNER JOIN dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
				ON esdp.DiaryId = ea.DiaryId
		WHERE
			ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
			AND ea.DiaryId IS NOT NULL
		GROUP BY
			ea.DiaryId
	)

	CREATE TABLE #No_Of_PointsBooked
	(
	    [DiaryId] INT NULL,
		[PointsCount] INT NULL
	)

	INSERT INTO #No_Of_PointsBooked
	(
		DiaryId,
		PointsCount
	)
    (
		SELECT 
			ea.DiaryId,
			SUM(ap.Points)
		FROM
			dbo.ERS_Appointments AS ea (NOLOCK)
			INNER JOIN dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
				ON esdp.DiaryId = ea.DiaryId
			INNER JOIN dbo.ERS_AppointmentProcedureTypes ap (NOLOCK) 
				ON ap.AppointmentID = ea.AppointmentId
		WHERE
			ISNULL(ea.AppointmentStatusId,1) <> 4 -- (4)Cancelled, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
			AND ea.DiaryId IS NOT NULL
		GROUP BY
			ea.DiaryId
	)
	
	CREATE TABLE #No_Of_Patient_Pts_Used
	(
	    [DiaryId] INT NULL,
		[ListCount] INT NULL
	)
		
	INSERT INTO #No_Of_Patient_Pts_Used
	(
		DiaryId,
		ListCount
	)
	(
		SELECT
			ea2.DiaryId,
			COALESCE(SUM(eapt.Points), 0) AS listCount
		FROM
			dbo.ERS_Appointments AS ea2 (NOLOCK)
			INNER JOIN dbo.ERS_AppointmentProcedureTypes AS eapt (NOLOCK)
				ON eapt.AppointmentID = ea2.AppointmentId
		WHERE
			ea2.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery			
		GROUP BY
			ea2.DiaryId
	) 
	
	CREATE TABLE #tmpOperatingHospitals
	(
	    [Id] INT NOT NULL,
		[Item] INT NOT NULL
	)

	INSERT INTO #tmpOperatingHospitals
	(
	    Id,
	    Item
	)
	(   
		SELECT
			Id,
			Item    
		FROM
			dbo.fnSplitString(ISNULL(@OperatingHospitalIds, ''), ',')
	)

	CREATE TABLE #tmpRooms
	(
	    [Id] INT NOT NULL,
		[Item] INT NOT NULL
	)
    
	INSERT INTO #tmpRooms
	(
	    Id,
	    Item
	)	
	(   
		SELECT
			Id,
			Item		
		FROM
			dbo.fnSplitString(ISNULL(@RoomIds, ''), ',')
	)

	CREATE TABLE #Appointments
	(
	    [Id] INT NOT NULL IDENTITY (1, 1),
		[OperatingHospital] VARCHAR(150) NOT NULL,
		[DiaryId] INT NOT NULL,
		[StartTime] DATETIME NOT NULL,
		[Duration] VARCHAR(100) NULL,
		[ListSlotId] INT
	)

	INSERT INTO #Appointments
	(
	    OperatingHospital,
	    DiaryId,
	    StartTime,
	    Duration,
		ListSlotId
	)
	(  
		SELECT			
			oh.HospitalName,
			ea.DiaryId,
			ea.StartDateTime,
			ea.AppointmentDuration,
			ea.ListSlotId
		FROM
			dbo.ERS_Appointments AS ea (NOLOCK)
			INNER JOIN dbo.ERS_OperatingHospitals oh (NOLOCK)
				ON ea.OperationalHospitaId = oh.OperatingHospitalId
		WHERE
			ea.DiaryId IS NOT NULL
			AND EXISTS
			(
				SELECT Item FROM #tmpOperatingHospitals AS toh
			)
			AND ea.StartDateTime BETWEEN @SearchStartDate AND @SearchEndDate	
			AND ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
	)
	
    DECLARE @counter INT = 0;
    DECLARE @ListSlotsTempTableCount INT = 0;

    INSERT INTO #ListSlots
	(
        [DiaryIdSlotOrder],
        [ListSlotId],
        [ListRulesId],
        [SlotMinutes],
        [Points],
        [DiaryId],
        [StartTime],
        [EndTime],
        [Duration],
        [ApptOverFlow],
        [RoomId]
	)
	SELECT
        0, 
        esls.ListSlotId, 
        esls.ListRulesId, 
        esls.SlotMinutes, 
        esls.Points, 
        esdp.DiaryId, 
        esdp.DiaryStart, 
        esdp.DiaryEnd,
        0, 
        0,
        esdp.RoomID
    FROM
        dbo.ERS_SCH_ListSlots AS esls (NOLOCK)
        LEFT JOIN dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
            ON esdp.ListRulesId = esls.ListRulesId
    WHERE
        esdp.DiaryId IS NOT NULL
		AND esdp.RoomID in
        (
            SELECT Item FROM #tmpRooms AS tr
        )
        AND esdp.DiaryStart
        BETWEEN @SearchStartDate AND @SearchEndDate

    ORDER BY
        esdp.DiaryId,
        esls.ListSlotId;

    SELECT
        @ListSlotsTempTableCount = @@ROWCOUNT;
		
    DECLARE @tempDiaryId INT = 0;
    DECLARE @currentRecordDiaryId INT = 0;
    DECLARE @newDiaryRecordFlag BIT = 0;
    DECLARE @currentRecordSlotMinutes INT = 0;
    DECLARE @currentRecordStartTime DATETIME;
    DECLARE @currentRecordEndTime DATETIME;
    DECLARE @previousRecordEndTime DATETIME;
    DECLARE @diaryIdSlotOrder INT = 0;

    SET @counter = 1;

    WHILE (@counter <= @ListSlotsTempTableCount)
    BEGIN
        SELECT
            @currentRecordDiaryId = DiaryId,
            @currentRecordSlotMinutes = SlotMinutes,
            @currentRecordStartTime = StartTime
        FROM
            #ListSlots
        WHERE
            Id = @counter;

        IF @tempDiaryId = 0
           OR @tempDiaryId <> @currentRecordDiaryId
        BEGIN
            SET @tempDiaryId = @currentRecordDiaryId;
            SET @newDiaryRecordFlag = 1;
            SET @diaryIdSlotOrder = 1;
        END;
        ELSE
        BEGIN
            SET @newDiaryRecordFlag = 0;
            SET @diaryIdSlotOrder = @diaryIdSlotOrder + 1;
        END;

        IF @newDiaryRecordFlag = 1
        BEGIN
            SET @currentRecordEndTime = DATEADD(MINUTE, @currentRecordSlotMinutes, @currentRecordStartTime);

            UPDATE
                #ListSlots
            SET
                EndTime = @currentRecordEndTime,
                DiaryIdSlotOrder = @diaryIdSlotOrder
            WHERE
                Id = @counter;
        END;
        ELSE IF @newDiaryRecordFlag = 0
        BEGIN
            SET @currentRecordStartTime = @previousRecordEndTime;
            SET @currentRecordEndTime = DATEADD(MINUTE, @currentRecordSlotMinutes, @currentRecordStartTime);

            UPDATE
                #ListSlots
            SET
                StartTime = @currentRecordStartTime,
                EndTime = @currentRecordEndTime,
                DiaryIdSlotOrder = @diaryIdSlotOrder
            FROM
                #ListSlots
            WHERE
                Id = @counter;
        END;

        SET @counter = @counter + 1;

        SET @previousRecordEndTime = @currentRecordEndTime;

    END;    

    UPDATE
        ls
    SET
        ls.Duration = a.Duration,
        ls.ApptOverFlow = a.Duration - ls.SlotMinutes
    FROM
        #ListSlots ls
        INNER JOIN #Appointments AS a
            ON a.DiaryId = ls.DiaryId and a.ListSlotId = ls.ListSlotId
               AND a.StartTime = ls.StartTime;

CREATE TABLE #ActivityDetails
(
    [DiaryId] INT NOT NULL,
	[OperatingHospital] VARCHAR(500) NULL,
	[RoomId] INT NULL,
	[Day] VARCHAR(10) NULL,
	[Date] DATE NULL,
	[Room] VARCHAR(50) NULL,
	[ListConsultant] VARCHAR(50) NULL,
	[Endoscopist] VARCHAR(50) NULL,
	[TemplateName] VARCHAR(75) NULL,
	[AM/PM] VARCHAR(2) NULL,
	[NoOfPtsOnTemplate] INT NULL,
	[NoOfPtsBooked] INT NULL,
	[NoOfPtsRemaining] INT NULL,
	[NoOfPatientsAttended] INT NULL,
	[NoOfPatientPointsUsed] INT NULL,		
	[ListLocked] VARCHAR(3) NULL,	
	[ReasonsLocked] VARCHAR(100) NULL,
	[ListUnlocked] VARCHAR(3) NULL,
	[ReasonsUnlocked] VARCHAR(100) NULL
)

INSERT INTO #ActivityDetails
(
    [DiaryId],
	[OperatingHospital],
	[RoomId],
	[Day],
	[Date],
	[Room],
	[ListConsultant],
	[Endoscopist],
	[TemplateName],
	[AM/PM],
	[NoOfPtsOnTemplate],
	[NoOfPtsBooked],
	[NoOfPtsRemaining],
	[NoOfPatientsAttended],
	[NoOfPatientPointsUsed],		
	[ListLocked],	
	[ReasonsLocked],
	[ListUnlocked],
	[ReasonsUnlocked]
)			   
(
	SELECT  
        ea.DiaryId AS [DiaryId],
		eoh.HospitalName AS [OperatingHospital],
		esr.RoomId AS [RoomId],
        FORMAT(ea.StartDateTime, 'ddd') AS [Day],        
        CONVERT(DATE, ea.StartDateTime, 106) AS [Date],        
        esr.RoomName AS [Room],
        CASE
            WHEN eu.IsListConsultant = 1 THEN
                LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)
            ELSE
                ''
        END AS [ListConsultant],
        CASE
            WHEN eu.IsEndoscopist1 = 1
                 OR eu.IsEndoscopist2 = 1 THEN
                LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)
            ELSE
                ''
        END AS [Endoscopist],
        eslr.ListName AS [TemplateName],
        CASE
            WHEN DATEPART(HH, ea.StartDateTime) < 12 THEN
                'AM'
            WHEN DATEPART(HH, ea.StartDateTime) < 17 THEN
                'PM'
            ELSE
                'EV'
        END AS [AM/PM],
        COALESCE(eslr.Points, 0) AS [NoOfPtsOnTemplate],
        COALESCE(no_of_points_booked.PointsCount, 0) AS [NoOfPtsBooked],
		COALESCE(eslr.Points, 0) - COALESCE(no_of_points_booked.PointsCount, 0) AS [NoOfPtsRemaining],
        COALESCE(no_of_patients.ListCount, 0) AS [NoOfPatientsAttended],
        COALESCE(no_of_patient_pts_used.ListCount, 0) AS [NoOfPatientPointsUsed],		
		'' AS [ListLocked],	
		'' AS [ReasonsLocked],
		'' AS [ListUnlocked],
		'' AS [ReasonsUnlocked]		    		    
    FROM
        dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
        INNER JOIN dbo.ERS_SCH_ListRules AS eslr (NOLOCK)
            ON esdp.ListRulesId = eslr.ListRulesId
        INNER JOIN dbo.ERS_SCH_ListSlots AS esls (NOLOCK)
            ON esdp.ListRulesId = esls.ListRulesId
        INNER JOIN dbo.ERS_Appointments AS ea (NOLOCK)
            ON esdp.DiaryId = ea.DiaryId AND ea.ListSlotId = esls.ListSlotId			
			AND ea.StartDateTime >= esdp.DiaryStart AND ea.StartDateTime <= esdp.DiaryEnd
			AND ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
        INNER JOIN dbo.ERS_SCH_Rooms AS esr (NOLOCK)
            ON esdp.RoomID = esr.RoomId
        LEFT JOIN dbo.ERS_Users AS eu (NOLOCK)
            ON ea.EndoscopistId = eu.UserID
        LEFT JOIN dbo.ERS_SCH_LockedDiaries AS esld (NOLOCK)
            ON esld.DiaryId = esdp.DiaryId 
			AND esld.DiaryId IS NOT NULL	
        LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS esdlr (NOLOCK)
            ON esdlr.DiaryLockReasonId = esld.LockedReasonId
		LEFT JOIN #No_Of_Patients AS no_of_patients
			ON no_of_patients.DiaryId = esdp.DiaryId 
		LEFT JOIN #No_Of_Patient_Pts_Used AS no_of_patient_pts_used
            ON no_of_patient_pts_used.DiaryId = esdp.DiaryId
		LEFT JOIN #No_Of_PointsBooked AS no_of_points_booked
			ON no_of_points_booked.DiaryId = esdp.DiaryId
		LEFT JOIN dbo.ERS_OperatingHospitals AS eoh (NOLOCK)
			ON eoh.OperatingHospitalId = esr.HospitalId
    WHERE
        esdp.OperatingHospitalId in 
        (
            SELECT Item FROM #tmpOperatingHospitals
        )
        AND esdp.RoomID in 
        (
            SELECT Item FROM #tmpRooms
        )
    GROUP BY
        ea.DiaryId,
		eoh.HospitalName,
        ea.StartDateTime,
        CASE
            WHEN DATEPART(HH, ea.StartDateTime) < 12 THEN
                'AM'
            WHEN DATEPART(HH, ea.StartDateTime) < 17 THEN
                'PM'
            ELSE
                'EV'
        END,
		esr.RoomId,
        esr.RoomName,
        eu.IsListConsultant,
        eu.IsEndoscopist1,
        eu.IsEndoscopist2,
        LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename),
        eslr.ListName,
        eslr.Points,
        esls.Points,
        no_of_patients.listCount,
        no_of_patient_pts_used.listCount,        
        ea.EndoscopistId
);
		
	WITH appointment_details AS
	(
		SELECT 
			ea.DiaryId, 
			ea.StartDateTime, 
			esdp.DiaryStart, 
			esdp.DiaryEnd, 
			esld.Locked, 
			diaryLockReason.IsLockReason,		
			diaryLockReason.Reason AS [LockReason],
			diaryUnlockReason.IsUnlockReason,
			diaryUnlockReason.Reason AS [UnlockReason]
		FROM 
			dbo.ERS_Appointments AS ea
			INNER JOIN dbo.ERS_SCH_DiaryPages AS esdp 
				ON ea.DiaryId = esdp.DiaryId
			INNER JOIN dbo.ERS_SCH_LockedDiaries AS esld
				ON esld.DiaryId = ea.DiaryId
			LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS diaryLockReason
				ON diaryLockReason.DiaryLockReasonId = esld.LockedReasonId
			LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS diaryUnlockReason
			ON diaryUnlockReason.DiaryLockReasonId = esld.UnlockedReasonId
		WHERE 
			ea.StartDateTime >= esdp.DiaryStart AND ea.StartDateTime <= esdp.DiaryEnd
			AND ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 )		
	)

	UPDATE
		#ActivityDetails
	SET
		#ActivityDetails.ListLocked = CASE WHEN appointment_details.Locked = 1 THEN 'YES' ELSE 'NO' END,
		#ActivityDetails.ReasonsLocked = CASE WHEN appointment_details.Locked = 1 THEN appointment_details.LockReason ELSE '' END,
		#ActivityDetails.ListUnlocked = CASE WHEN appointment_details.Locked = 0 THEN 'YES' ELSE 'NO' END,
		#ActivityDetails.ReasonsUnlocked = CASE WHEN appointment_details.Locked = 0 THEN appointment_details.UnlockReason ELSE '' END
	FROM
		appointment_details 
	WHERE
		#ActivityDetails.[DiaryId] = appointment_details.[DiaryId] 	

    SELECT
        [DiaryId],
		[OperatingHospital],
        [RoomId],
        [Day],
        [Date],
        [Room],
        [ListConsultant],
        [Endoscopist],
        [TemplateName],
        [AM/PM],
        [NoOfPtsOnTemplate],
        [NoOfPtsBooked],
		[NoOfPtsRemaining],
        [NoOfPatientsAttended],
        [NoOfPatientPointsUsed],
        [ListLocked],
        [ReasonsLocked],
        [ListUnlocked],
        [ReasonsUnlocked]
    FROM
        #ActivityDetails
    WHERE
        RoomId IS NOT NULL
    GROUP BY
        [DiaryId],
		[OperatingHospital],
        [Date],
        [AM/PM],
        [RoomId],
        [Room],
        [Day],
        [ListConsultant],
        [Endoscopist],
        [TemplateName],
        [NoOfPtsOnTemplate],
		[NoOfPtsBooked],
		[NoOfPtsRemaining],
        [NoOfPatientsAttended],
		[NoOfPatientPointsUsed],
        [ListLocked],
        [ReasonsLocked],
        [ListUnlocked],
        [ReasonsUnlocked]
    ORDER BY
        [Date] DESC;

END;
GO
PRINT N'Altering Procedure [dbo].[report_SCH_Cancellation]...';


GO
ALTER PROCEDURE [dbo].[report_SCH_Cancellation]
    @SearchStartDate AS DATE,
    @SearchEndDate AS DATE,
    @OperatingHospitalIds VARCHAR(100),
    @RoomIds VARCHAR(1000),
	@HideSuppressedConsultants BIT,
	@HideSuppressedEndoscopists BIT
AS
/************** */
/*	Update History		:				*/
/*	01		:		25 Jan 2022		Mahfuz added additional column OperatingHospital, Reason type (Hospital or Patient) column TFS : 1841*/
/************** */
BEGIN

    IF OBJECT_ID('tempdb..#Cancellations') IS NOT NULL
        DROP TABLE #Cancellations;

    IF OBJECT_ID('tempdb..#tmpOperatingHospitals') IS NOT NULL
        DROP TABLE #tmpOperatingHospitals;
    SELECT
        Id,
        Item
    INTO
        #tmpOperatingHospitals
    FROM
        dbo.fnSplitString(ISNULL(@OperatingHospitalIds, ''), ',');

    IF OBJECT_ID('tempdb..#tmpRooms') IS NOT NULL
        DROP TABLE #tmpRooms;
    SELECT
        Id,
        Item
    INTO
        #tmpRooms
    FROM
        dbo.fnSplitString(ISNULL(@RoomIds, ''), ',');

    SELECT
        esr.RoomId AS [RoomId],
        FORMAT(ea.StartDateTime, 'ddd') AS [Day],
        convert(varchar, ea.StartDateTime, 103) AS [Date],
        FORMAT(ea.StartDateTime, 'hh:mm') AS [Time],
        esr.RoomName AS [Room],
		OH.HospitalName as OperatingHospital,
		CASE
            WHEN eu.IsEndoscopist1 = 1
                 OR eu.IsEndoscopist2 = 1 THEN
                LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)
            ELSE
                ''
        END AS [Endoscopist],
        ep.HospitalNumber AS [CaseNoteNo],
        esls.ProcedureTypeId AS [ProcedureId],
		ept.ProcedureType AS [ProcedureName],
        ISNULL(no_of_patient_pts_used.listCount, 0) AS [NoOfPts],
        ea.DateCancelled AS [CancelledDate],
        ISNULL(ecr.Detail, '') AS [CancellationReason],
        ISNULL(DATEDIFF(DAY, ea.StartDateTime, ea.DateCancelled), 0) AS [NoOfDays],
        '' AS [Rebooked],
        '' AS [RebookedDate],
		ecr.CancelledByHospital
    INTO
        #Cancellations
    FROM
        dbo.ERS_SCH_DiaryPages (NOLOCK) esdp
        INNER JOIN dbo.ERS_SCH_ListRules (NOLOCK) eslr
            ON esdp.ListRulesId = eslr.ListRulesId
        INNER JOIN dbo.ERS_SCH_ListSlots (NOLOCK) esls
            ON esdp.ListRulesId = esls.ListRulesId
        INNER JOIN dbo.ERS_Appointments (NOLOCK) ea
            ON esdp.DiaryId = ea.DiaryId
        INNER JOIN dbo.ERS_SCH_Rooms esr (NOLOCK)
            ON esdp.RoomID = esr.RoomId
        LEFT JOIN dbo.ERS_Users eu (NOLOCK)
            ON ea.EndoscopistId = eu.UserID
		LEFT JOIN ERS_Users elc ON esdp.ListConsultantId = elc.UserID
        INNER JOIN dbo.ERS_Patients AS ep (NOLOCK)
            ON ep.PatientId = ea.PatientId
        --INNER JOIN dbo.ERS_Procedures AS ep2 (NOLOCK)
        --    ON ep2.OperatingHospitalID = esdp.OperatingHospitalId
        LEFT JOIN dbo.ERS_CancelReasons AS ecr (NOLOCK)
            ON ecr.CancelReasonId = ea.CancelReasonId
		LEFT JOIN dbo.ERS_ProcedureTypes AS ept (NOLOCK)
			ON ept.ProcedureTypeId = esls.ProcedureTypeId
		Inner join ERS_OperatingHospitals OH on esr.HospitalId = OH.OperatingHospitalId
        LEFT JOIN
        (
            SELECT
                ea2.DiaryId,
                COALESCE(COUNT(*), 0, COUNT(*)) AS listCount
            FROM
                dbo.ERS_Appointments ea2 (NOLOCK)
            WHERE
                ea2.AppointmentStatusId IN ( 3, 9, 12, 13 ) -- (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery)
            GROUP BY
                ea2.DiaryId
        ) no_of_patient_pts_used
            ON no_of_patient_pts_used.DiaryId = esdp.DiaryId
    WHERE
        esr.HospitalId IN
        (
            SELECT Item FROM #tmpOperatingHospitals
        )
        AND esr.RoomId IN
            (
                SELECT Item FROM #tmpRooms
            )
        AND ea.StartDateTime
        BETWEEN @SearchStartDate AND @SearchEndDate
        AND ea.AppointmentStatusId = 4
		AND eu.Suppressed = CASE WHEN @HideSuppressedEndoscopists = 1 THEN 0 ELSE eu.Suppressed END
		AND elc.Suppressed = CASE WHEN @HideSuppressedConsultants = 1 THEN 0 ELSE elc.Suppressed END
    GROUP BY
        ea.StartDateTime,
        esr.RoomId,
        esr.RoomName,
		OH.HospitalName,
    ep.HospitalNumber,
        esls.ProcedureTypeId,
		ept.ProcedureType,
        eu.IsEndoscopist1,
        eu.IsEndoscopist2,
        LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename),
        no_of_patient_pts_used.listCount,
        ea.DateCancelled,
        ecr.Detail,
		ecr.CancelledByHospital
    ORDER BY
		OH.HospitalName,
        ea.StartDateTime;

    SELECT
        RoomId,
        Day,
        Date,
        Time,
        Room,
		OperatingHospital,
        Endoscopist,
        CaseNoteNo,
        [ProcedureName],
        NoOfPts,
        CancelledDate,
        CancellationReason,
        NoOfDays,
        Rebooked,
        RebookedDate,
		CancelledByHospital,
		Case when CancelledByHospital = 1 then 'Hospital' else 'Patient' End as CancelledBy
    FROM
        #Cancellations;

END;
GO
PRINT N'Altering Procedure [dbo].[report_SCH_DNA]...';


GO
ALTER PROCEDURE [dbo].[report_SCH_DNA]
    @SearchStartDate AS DATE,
    @SearchEndDate AS DATE,
    @OperatingHospitalIds VARCHAR(100),
    @RoomIds VARCHAR(1000),
	@HideSuppressedConsultants BIT,
	@HideSuppressedEndoscopists BIT
AS
/************** */
/*	Update History		:				*/
/*	01		:		25 Jan 2022		Mahfuz added additional column OperatingHospital etc : 1841*/
/************** */
BEGIN

    IF OBJECT_ID('tempdb..#DNA') IS NOT NULL
        DROP TABLE #DNA;

    IF OBJECT_ID('tempdb..#tmpOperatingHospitals') IS NOT NULL
        DROP TABLE #tmpOperatingHospitals;
    SELECT
        Id,
        Item
    INTO
        #tmpOperatingHospitals
    FROM
        dbo.fnSplitString(ISNULL(@OperatingHospitalIds, ''), ',');

    IF OBJECT_ID('tempdb..#tmpRooms') IS NOT NULL
        DROP TABLE #tmpRooms;
    SELECT
        Id,
        Item
    INTO
        #tmpRooms
    FROM
        dbo.fnSplitString(ISNULL(@RoomIds, ''), ',');

    SELECT DISTINCT
        esr.RoomId AS [RoomId],
        FORMAT(ea.StartDateTime, 'ddd') AS [Day],
        ea.StartDateTime AS [Date],
        FORMAT(ea.StartDateTime, 'hh:mm') + CASE
                                                WHEN DATEPART(HH, ea.StartDateTime) <= 12 THEN
                                                    ' AM'
                                                ELSE
                                                    ' PM'
                                            END AS [Time],
        esr.RoomName AS [Room],
		OH.HospitalName as OperatingHospital,
        CASE
            WHEN eu.IsEndoscopist1 = 1
                 OR eu.IsEndoscopist2 = 1 THEN
                LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)
            ELSE
                ''
        END AS [Endoscopist],
        ep.HospitalNumber AS [CaseNoteNo],
        ProcTypes.procs AS [ProcedureName],
		SUM(CAST(no_of_patient_pts_used.Points AS decimal(18,2))) AS [NoOfPts]
    INTO
        #DNA
    FROM
        dbo.ERS_Appointments ea
        INNER JOIN dbo.ERS_SCH_DiaryPages esdp
            ON esdp.DiaryId = ea.DiaryId
        INNER JOIN dbo.ERS_Patients AS ep
            ON ep.PatientId = ea.PatientId
		Inner Join ERS_OperatingHospitals OH on OH.OperatingHospitalId = esdp.OperatingHospitalId --MH added on 25 Jan 2022
        LEFT JOIN
        (
            SELECT
                ea.AppointmentId,
                STUFF(
                (
                    SELECT
                        '+' + AppointmentProcedures AS [text()]
                    FROM
                        dbo.SCH_AppointmentProcedures(ea.AppointmentId)
                    WHERE
                        AppointmentId = ea.AppointmentId
                    FOR XML PATH('')
                ),
                1,
                1,
                ''
                     ) AS procs
            FROM
                dbo.ERS_Appointments ea
        ) AS ProcTypes
            ON ProcTypes.AppointmentId = ea.AppointmentId
        LEFT JOIN dbo.ERS_SCH_Rooms esr
            ON esdp.RoomID = esr.RoomId
        LEFT JOIN dbo.ERS_Users eu
            ON ea.EndoscopistId = eu.UserID 
		LEFT JOIN ERS_Users elc ON esdp.ListConsultantId = elc.UserID       
        LEFT JOIN dbo.ERS_AppointmentProcedureTypes AS no_of_patient_pts_used
			ON no_of_patient_pts_used.AppointmentID = ea.AppointmentId                    
    WHERE
        esr.HospitalId IN
        (
            SELECT Item FROM #tmpOperatingHospitals
        )
        AND esr.RoomId IN
            (
                SELECT Item FROM #tmpRooms
            )
        AND ea.StartDateTime
        BETWEEN @SearchStartDate AND @SearchEndDate
        AND ea.AppointmentStatusId = 6
		AND eu.Suppressed = CASE WHEN @HideSuppressedEndoscopists = 1 THEN 0 ELSE eu.Suppressed END
		AND elc.Suppressed = CASE WHEN @HideSuppressedConsultants = 1 THEN 0 ELSE elc.Suppressed END
    GROUP BY
        ea.StartDateTime,
        esr.RoomId,
        esr.RoomName,
		OH.HospitalName,
        eu.IsEndoscopist1,
        eu.IsEndoscopist2,
        LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename),
        ep.HospitalNumber,
        ProcTypes.procs,
        LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)		
    ORDER BY
        ea.StartDateTime;

    SELECT
        d.RoomId,
        d.Day,
        d.Date,
        d.Time,
        d.Room,
		d.OperatingHospital,
        d.Endoscopist,
        d.CaseNoteNo,
        d.ProcedureName,
		d.NoOfPts
    FROM
        #DNA AS d
    WHERE
        d.RoomId IN
        (
            SELECT Item FROM #tmpRooms AS tr
        )
        AND d.Date
        BETWEEN @SearchStartDate AND @SearchEndDate;

END;
GO
PRINT N'Altering Procedure [dbo].[report_SCH_PatientPathway]...';


GO
ALTER PROCEDURE [dbo].[report_SCH_PatientPathway]
    @SearchStartDate AS DATE,
    @SearchEndDate AS DATE,
    @OperatingHospitalIds VARCHAR(100),
    @RoomIds VARCHAR(1000),
	@HideSuppressedConsultants BIT,
	@HideSuppressedEndoscopists BIT
AS
/************** */
/*	Update History		:				*/
/*	01		:		26 Jan 2022		Mahfuz added additional column OperatingHospital, Patient Discharged etc : 1841*/
/************** */
BEGIN

    IF OBJECT_ID('tempdb..#PatientPathway') IS NOT NULL
        DROP TABLE #PatientPathway;

    IF OBJECT_ID('tempdb..#tmpOperatingHospitals') IS NOT NULL
        DROP TABLE #tmpOperatingHospitals;
    SELECT
        Id,
        Item
    INTO
        #tmpOperatingHospitals
    FROM
        dbo.fnSplitString(ISNULL(@OperatingHospitalIds, ''), ',');

    IF OBJECT_ID('tempdb..#tmpRooms') IS NOT NULL
        DROP TABLE #tmpRooms;
    SELECT
        Id,
        Item
    INTO
        #tmpRooms
    FROM
        dbo.fnSplitString(ISNULL(@RoomIds, ''), ',');

    SELECT
        esdp.RoomID AS [RoomId],
        FORMAT(epj.ProcedureStartTime, 'ddd') AS [Day],
        FORMAT(epj.ProcedureStartTime, 'dd-MMM-yyyy') AS [Date],
        FORMAT(epj.ProcedureStartTime, 'HH:mm') AS [BookedTime],
        esr.RoomName AS [Room],
		OH.HospitalName as OperatingHospital, --MH added on 26 Jan 2022
        ep.HospitalNumber AS [CaseNoteNo],
		ep2.ProcedureType AS [ProcedureId],
        ept.ProcedureType AS [Procedure],
        FORMAT(epj.PatientAdmissionTime, 'dd-MMM-yyyy HH:mm') AS [PatientAttended],
        FORMAT(epj.ProcedureStartTime, 'dd-MMM-yyyy HH:mm')  AS [PatientInRoom],
        FORMAT(epj.ProcedureEndTime, 'dd-MMM-yyyy HH:mm') AS [PatientLeftRoom],
        FORMAT(epj.PatientDischargeTime, 'dd-MMM-yyyy HH:mm') AS [Discharged],
		FORMAT(epj.PatientAdmissionTime, 'dd-MMM-yyyy HH:mm')AS [Admission],
     --   ISNULL(DATEDIFF(
     --               MINUTE,
					--FORMAT(epj.PatientAdmissionTime, 'dd-MMM-yyyy hh:mm'),
     --               FORMAT(epj.PatientDischargeTime, 'dd-MMM-yyyy hh:mm')                    
     --           ), 0) AS [TimeInDept],
		CASE
			WHEN ISNULL(DATEDIFF(
							MINUTE,
							FORMAT(epj.PatientAdmissionTime, 'dd-MMM-yyyy HH:mm'),
							FORMAT(epj.PatientDischargeTime, 'dd-MMM-yyyy HH:mm')                    
						), 0) > 60 
						THEN CAST(ISNULL(DATEDIFF(
							MINUTE,
							FORMAT(epj.PatientAdmissionTime, 'dd-MMM-yyyy HH:mm'),
							FORMAT(epj.PatientDischargeTime, 'dd-MMM-yyyy HH:mm')                  
						), 0) / 60 AS VARCHAR(10)) + ' hour(s), ' +
						CAST(ISNULL(DATEDIFF(
							MINUTE,
							FORMAT(epj.PatientAdmissionTime, 'dd-MMM-yyyy HH:mm'),
							FORMAT(epj.PatientDischargeTime, 'dd-MMM-yyyy HH:mm')                    
						), 0) % 60 AS VARCHAR(10)) + ' mins '
			ELSE 
				CAST(ISNULL(DATEDIFF(
					MINUTE,
					FORMAT(epj.PatientAdmissionTime, 'dd-MMM-yyyy HH:mm'),
					FORMAT(epj.PatientDischargeTime, 'dd-MMM-yyyy HH:mm')                    
				), 0) % 60 AS VARCHAR(10)) + ' mins ' 
		END AS [TimeInDept]		
    INTO
        #PatientPathway
    FROM
        dbo.ERS_Appointments ea
		INNER JOIN dbo.ERS_SCH_DiaryPages esdp
			ON esdp.DiaryId = ea.DiaryId    
		INNER JOIN dbo.ERS_PatientJourney AS epj
            ON epj.AppointmentId = ea.AppointmentId
        INNER JOIN dbo.ERS_Procedures AS ep2
            ON ep2.ProcedureId = epj.ProcedureId
		Inner join ERS_OperatingHospitals OH on esdp.OperatingHospitalId = OH.OperatingHospitalId --MH added on 26 Jan 2022
		LEFT JOIN dbo.ERS_SCH_Rooms esr
            ON esdp.RoomID = esr.RoomId              
		LEFT JOIN dbo.ERS_Patients AS ep
            ON ep.PatientId = ea.PatientId       
		LEFT JOIN dbo.ERS_ProcedureTypes AS ept
			ON ept.ProcedureTypeId = ep2.ProcedureType
		INNER JOIN ERS_Users eu ON eu.UserId = ea.EndoscopistId
		LEFT JOIN ERS_Users elc ON esdp.ListConsultantId = elc.UserID
    WHERE
        esr.HospitalId IN
        (
            SELECT Item FROM #tmpOperatingHospitals
        )
        AND esr.RoomId IN
            (
                SELECT Item FROM #tmpRooms
            )
		AND ea.StartDateTime
        BETWEEN @SearchStartDate AND @SearchEndDate
		AND eu.Suppressed = CASE WHEN @HideSuppressedEndoscopists = 1 THEN 0 ELSE eu.Suppressed END
		AND elc.Suppressed = CASE WHEN @HideSuppressedConsultants = 1 THEN 0 ELSE elc.Suppressed END
        --AND ea.AppointmentStatusId NOT IN (4, 5, 6) --MH commented out after talking with Chris on 26 Jan 2022. If needed can be uncomment later
		--AND epj.PatientAdmissionTime IS NOT NULL
		--AND epj.ProcedureStartTime IS NOT NULL
		--AND epj.ProcedureEndTime IS NOT NULL
		--AND epj.PatientDischargeTime IS NOT NULL
    GROUP BY
        epj.ProcedureStartTime,
        esdp.RoomID,
        esr.RoomName,
		OH.HospitalName,
        esdp.ListConsultantId,
        ep.HospitalNumber,
		ep2.ProcedureType,
        ept.ProcedureType,
        epj.ProcedureEndTime,
        epj.PatientDischargeTime,
		epj.PatientAdmissionTime
    ORDER BY
        epj.ProcedureStartTime;

    SELECT 
        [RoomId],
        [Day],
        [Date],
        [BookedTime],
        [Room],
		[OperatingHospital],
        [CaseNoteNo],
        [Procedure],
        [PatientAttended],
        [PatientInRoom],
        [PatientLeftRoom],
        [Discharged],
		[Admission],
		[TimeInDept]		
    FROM
        #PatientPathway
	ORDER BY 
		[Date]

END;
GO
PRINT N'Altering Procedure [dbo].[report_SCH_PatientStatus]...';


GO
ALTER PROCEDURE [dbo].[report_SCH_PatientStatus]
    @SearchStartDate AS DATE,
    @SearchEndDate AS DATE,
    @OperatingHospitalIds VARCHAR(100),
    @RoomIds VARCHAR(1000),
	@HideSuppressedConsultants BIT,
	@HideSuppressedEndoscopists BIT
AS
/************** */
/*	Update History		:				*/
/*	01		:		26 Jan 2022		Mahfuz added additional column OperatingHospital etc : 1841*/
/************** */
BEGIN

    IF OBJECT_ID('tempdb..#PatientStatus') IS NOT NULL
        DROP TABLE #PatientPathway;

    IF OBJECT_ID('tempdb..#tmpOperatingHospitals') IS NOT NULL
        DROP TABLE #tmpOperatingHospitals;
    SELECT
        Id,
        Item
    INTO
        #tmpOperatingHospitals
    FROM
        dbo.fnSplitString(ISNULL(@OperatingHospitalIds, ''), ',');

    IF OBJECT_ID('tempdb..#tmpRooms') IS NOT NULL
        DROP TABLE #tmpRooms;
    SELECT
        Id,
        Item
    INTO
        #tmpRooms
    FROM
        dbo.fnSplitString(ISNULL(@RoomIds, ''), ',');

    SELECT
        esr.RoomId AS [RoomId],
        FORMAT(ea.StartDateTime, 'ddd') AS [Day],
        CAST(FORMAT(ea.StartDateTime, 'dd-MMM-yyyy') AS DATE) AS [Date],
        esr.RoomName AS [RoomName],
		OH.HospitalName AS OperatingHospital, --MH added on 26 Jan 2022
        CASE
            WHEN eu.IsListConsultant = 1 THEN
                LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)
            ELSE
                ''
        END AS [ListConsultant],
        CASE
            WHEN eu.IsEndoscopist1 = 1
                 OR eu.IsEndoscopist2 = 1 THEN
                LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)
            ELSE
                ''
        END AS [Endoscopist],
        eslr.ListName AS [TemplateName],
        CASE 
			WHEN DATEPART(HH, ea.StartDateTime) <= 12 THEN 
				'AM'
			WHEN DATEPART(HH, ea.StartDateTime) >= 12 AND DATEPART(HH, ea.StartDateTime) <= 17 THEN
				'PM'
			ELSE
				'EVE'
        END AS [AM/PM],
        ea.PriorityiD AS [PriorityId],
		esdp.ListRulesId,
        CASE WHEN ea.PriorityiD = 1 THEN 1 ELSE 0 END AS [Routine],
		CASE WHEN ea.PriorityiD = 2 THEN 1 ELSE 0 END AS [InPatient],
		CASE WHEN ea.PriorityiD = 3 THEN 1 ELSE 0 END AS [Urgent],
		CASE WHEN ea.PriorityiD = 4 THEN 1 ELSE 0 END AS [Planned],
		CASE WHEN ea.PriorityiD = 5 THEN 1 ELSE 0 END AS [TwoWeekWait],
		CASE WHEN ea.PriorityiD = 6 THEN 1 ELSE 0 END AS [OpenAccess],
		CASE WHEN ea.PriorityiD = 7 THEN 1 ELSE 0 END AS [BowelScreening]
    INTO
        #PatientStatus
    FROM
        dbo.ERS_SCH_DiaryPages esdp
        INNER JOIN dbo.ERS_SCH_ListRules eslr
            ON esdp.ListRulesId = eslr.ListRulesId
        INNER JOIN dbo.ERS_SCH_ListSlots esls
            ON esdp.ListRulesId = esls.ListRulesId
        INNER JOIN dbo.ERS_Appointments ea
            ON esdp.DiaryId = ea.DiaryId
        INNER JOIN dbo.ERS_SCH_Rooms esr
            ON esdp.RoomID = esr.RoomId
		Inner join ERS_OperatingHospitals OH on esdp.OperatingHospitalId = OH.OperatingHospitalId --MH added on 26 Jan 2022
        LEFT JOIN dbo.ERS_Users eu
            ON ea.EndoscopistId = eu.UserID   
		LEFT JOIN ERS_Users elc ON esdp.ListConsultantId = elc.UserID    
		LEFT JOIN dbo.ERS_Priority AS ep
			ON ep.PriorityId = ea.PriorityiD
    WHERE
        ea.DiaryId IS NOT NULL
        AND ea.OperationalHospitaId IN
            (
                SELECT Item FROM #tmpOperatingHospitals AS toh
            )
		AND esr.RoomId IN
			(
                SELECT Item FROM #tmpRooms AS tr
            )
        AND ea.StartDateTime BETWEEN @SearchStartDate AND @SearchEndDate
		AND eu.Suppressed = CASE WHEN @HideSuppressedEndoscopists = 1 THEN 0 ELSE eu.Suppressed END
		AND elc.Suppressed = CASE WHEN @HideSuppressedConsultants = 1 THEN 0 ELSE elc.Suppressed END
    GROUP BY
        ea.StartDateTime,
        esr.RoomId,
        esr.RoomName,
		OH.HospitalName,
        eu.IsListConsultant,
        eu.IsEndoscopist1,
        eu.IsEndoscopist2,
		ea.PriorityiD,
        LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename),
        eslr.ListName,
		ep.[Description],
        ea.EndoscopistId,
		esdp.ListRulesId
    ORDER BY
        ea.StartDateTime;

     SELECT 
		[RoomId],
		[Day],
		CAST([Date] AS DATE) AS [Date],
		[RoomName],
		OperatingHospital,
		[ListConsultant],
		[Endoscopist],
		[TemplateName],
		[AM/PM],
		SUM([Routine]) AS [Routine],
		SUM([InPatient]) AS [InPatient],
		SUM([Urgent]) AS [Urgent],
		SUM([Planned]) AS [Planned],
		SUM([TwoWeekWait]) AS [TwoWeekWait],
		SUM([OpenAccess]) AS [OpenAccess],
		SUM([BowelScreening]) AS [BowelScreening]
    FROM
        #PatientStatus
	
	GROUP BY
		[RoomId],
		[Day],
		[Date],
		[RoomName],
		OperatingHospital,
		[ListConsultant],
		[Endoscopist],
		[TemplateName],
		[AM/PM],
		[ListRulesId];

END;
GO
PRINT N'Altering Procedure [dbo].[SCH_reports_rooms_search]...';


GO
SET ANSI_NULLS, QUOTED_IDENTIFIER OFF;


GO

ALTER PROCEDURE [dbo].[SCH_reports_rooms_search]
	@HospitalIds AS VARCHAR(MAX),
	@SearchPhrase AS VARCHAR(2000)	
AS
BEGIN

	SELECT RoomId, RoomName
	FROM dbo.ERS_SCH_Rooms
	WHERE Suppressed = 0
	AND HospitalId IN (SELECT item FROM dbo.fnSplitString(@HospitalIds, ','))
	AND RoomName LIKE '%' + COALESCE(@SearchPhrase, '', @SearchPhrase) + '%'
	
END
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Chris Gammage 20/09/2023
-- TFS#	3285
-- Description of change; update Regions Name
-- 
------------------------------------------------------------------------------------------------------------------------
GO

 update ERS_Regions
  SET Region = 'Mid Sigmoid'
  where RegionId in (3017, 4017)
GO

--MH Changed as below - throwing error if the record already exists on 22 Nov 2023. Now it will only inserts for those procedure types which does not have Mid Sigmoid
	/*

	insert into ERS_AbnormalitiesMatrixColon (ProcedureType, Region, Calibre, Mucosa, Diverticulum, Lesions, Vascularity, Haemorrhage, Miscellaneous, [Perianal Lesions])
	Select ProcedureType, 'Mid Sigmoid', Calibre, Mucosa, Diverticulum, Lesions, Vascularity, Haemorrhage, Miscellaneous, [Perianal Lesions]
	from ERS_AbnormalitiesMatrixColon where Region = 'Proximal sigmoid'
	*/
		insert into ERS_AbnormalitiesMatrixColon (ProcedureType, Region, Calibre, Mucosa, Diverticulum, Lesions, Vascularity, Haemorrhage, Miscellaneous, [Perianal Lesions])
	Select m.ProcedureType, 'Mid Sigmoid', m.Calibre, m.Mucosa, m.Diverticulum, m.Lesions, m.Vascularity, m.Haemorrhage, m.Miscellaneous, m.[Perianal Lesions]
		from ERS_AbnormalitiesMatrixColon m 
		left join ERS_AbnormalitiesMatrixColon ae on m.ProcedureType = ae.ProcedureType and ae.Region = 'Mid Sigmoid'

		where m.Region = 'Proximal sigmoid' and ae.ProcedureType is null
Go

 ------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
Go

Go
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Mahfuz	On 21 Jul 2023
-- TFS#	2864, 2859,2863,2865
-- Description of change
-- Dumfries Galloway - xml document - gender in patient search etc
------------------------------------------------------------------------------------------------------------------------
Go
--Adding SCIStoreGPId column in ERS_GPS table
IF Not EXISTS(SELECT * FROM sys.columns WHERE Name = N'SCIStoreGPId' AND Object_ID = Object_ID(N'ERS_GPS'))
Begin
Print 'Adding Column SCIStoreGPId from ERS_GPS table'
ALTER TABLE [dbo].[ERS_GPS]
   Add SCIStoreGPId varchar(100) null
End
GO

----Adding SCIStoreGPId column in ERS_GPS_Audit table
IF Not EXISTS(SELECT * FROM sys.columns WHERE Name = N'SCIStoreGPId' AND Object_ID = Object_ID(N'ERSAudit.ERS_GPS_Audit'))
Begin
Print 'Adding Column SCIStoreGPId from ERS_GPS_Audit table'
ALTER TABLE [ERSAudit].[ERS_GPS_Audit]
   Add SCIStoreGPId varchar(100) null
End
GO


--Adding SCIStorePracticeId column in ERS_Practices table
IF Not EXISTS(SELECT * FROM sys.columns WHERE Name = N'SCIStorePracticeId' AND Object_ID = Object_ID(N'ERS_Practices'))
Begin
Print 'Adding Column SCIStorePracticeId from ERS_Practices table'
ALTER TABLE [dbo].[ERS_Practices]
   Add SCIStorePracticeId varchar(100) null
End
GO

----Adding SCIStorePracticeId column in ERS_Practices_Audit table
IF Not EXISTS(SELECT * FROM sys.columns WHERE Name = N'SCIStorePracticeId' AND Object_ID = Object_ID(N'ERSAudit.ERS_Practices_Audit'))
Begin
Print 'Adding Column SCIStorePracticeId from ERS_Practices_Audit table'
ALTER TABLE [ERSAudit].[ERS_Practices_Audit]
   Add SCIStorePracticeId varchar(100) null
End
GO

--Adding SortOrder column in ERS_GenderTypes table
IF Not EXISTS(SELECT * FROM sys.columns WHERE Name = N'SortOrder' AND Object_ID = Object_ID(N'ERS_GenderTypes'))
Begin
Print 'Adding Column SortOrder from ERS_GenderTypes table'
ALTER TABLE [dbo].[ERS_GenderTypes]
   Add SortOrder Int null
End
GO

----Adding SortOrder column in ERS_GenderTypes_Audit table
IF Not EXISTS(SELECT * FROM sys.columns WHERE Name = N'SortOrder' AND Object_ID = Object_ID(N'ERSAudit.ERS_GenderTypes_Audit'))
Begin
Print 'Adding Column SortOrder from ERS_GenderTypes_Audit table'
ALTER TABLE [ERSAudit].[ERS_GenderTypes_Audit]
   Add SortOrder Int null
End
GO


Update ERS_GenderTypes
Set SortOrder = Case 
	when Code = 'M' then 1 
	When Code = 'F' then 2 
	when Code = 'U' then 3 
	when Code = 'N' then 4 
End

Go
Exec DropIfExist 'trg_ERS_Practices_Insert','TR'
/****** Object:  Trigger [dbo].[trg_ERS_Practices_Insert]    Script Date: 01/06/2023 15:43:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_ERS_Practices_Insert] 
							ON [dbo].[ERS_Practices] 
							AFTER INSERT
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_Practices_Audit] (PracticeID, tbl.[Code], tbl.[NationalCode], tbl.[Name], tbl.[Address1], tbl.[Address2], tbl.[Address3], tbl.[Address4], tbl.[PostCode], tbl.[TelNo], tbl.[FaxNo], tbl.[Email], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[ExternalCode], tbl.[Primary], tbl.[Local], tbl.[CCGId], tbl.[StartDate], tbl.[SCIStorePracticeId], LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.PracticeID , tbl.[Code], tbl.[NationalCode], tbl.[Name], tbl.[Address1], tbl.[Address2], tbl.[Address3], tbl.[Address4], tbl.[PostCode], tbl.[TelNo], tbl.[FaxNo], tbl.[Email], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[ExternalCode], tbl.[Primary], tbl.[Local], tbl.[CCGId], tbl.[StartDate],  tbl.[SCIStorePracticeId],1, GETDATE(), tbl.WhoCreatedId
							FROM inserted tbl
GO

ALTER TABLE [dbo].[ERS_Practices] ENABLE TRIGGER [trg_ERS_Practices_Insert]
GO

Exec DropIfExist 'trg_ERS_Practices_Update','TR'
GO

/****** Object:  Trigger [dbo].[trg_ERS_Practices_Update]    Script Date: 01/06/2023 15:48:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_ERS_Practices_Update] 
							ON [dbo].[ERS_Practices] 
							AFTER UPDATE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_Practices_Audit] (PracticeID, tbl.[Code], tbl.[NationalCode], tbl.[Name], tbl.[Address1], tbl.[Address2], tbl.[Address3], tbl.[Address4], tbl.[PostCode], tbl.[TelNo], tbl.[FaxNo], tbl.[Email], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[ExternalCode], tbl.[Primary], tbl.[Local], tbl.[CCGId], tbl.[StartDate],tbl.[SCIStorePracticeId],  LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.PracticeID , tbl.[Code], tbl.[NationalCode], tbl.[Name], tbl.[Address1], tbl.[Address2], tbl.[Address3], tbl.[Address4], tbl.[PostCode], tbl.[TelNo], tbl.[FaxNo], tbl.[Email], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[ExternalCode], tbl.[Primary], tbl.[Local], tbl.[CCGId], tbl.[StartDate],  tbl.[SCIStorePracticeId],2, GETDATE(), i.WhoUpdatedId
							FROM deleted tbl INNER JOIN inserted i ON tbl.PracticeID = i.PracticeID
GO

ALTER TABLE [dbo].[ERS_Practices] ENABLE TRIGGER [trg_ERS_Practices_Update]
GO


Exec DropIfExist 'trg_ERS_Practices_Delete','TR'
GO

/****** Object:  Trigger [dbo].[trg_ERS_Practices_Delete]    Script Date: 01/06/2023 15:49:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_ERS_Practices_Delete] 
							ON [dbo].[ERS_Practices] 
							AFTER DELETE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_Practices_Audit] (PracticeID, tbl.[Code], tbl.[NationalCode], tbl.[Name], tbl.[Address1], tbl.[Address2], tbl.[Address3], tbl.[Address4], tbl.[PostCode], tbl.[TelNo], tbl.[FaxNo], tbl.[Email], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[ExternalCode], tbl.[Primary], tbl.[Local], tbl.[CCGId], tbl.[StartDate],tbl.[SCIStorePracticeId],  LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.PracticeID , tbl.[Code], tbl.[NationalCode], tbl.[Name], tbl.[Address1], tbl.[Address2], tbl.[Address3], tbl.[Address4], tbl.[PostCode], tbl.[TelNo], tbl.[FaxNo], tbl.[Email], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[ExternalCode], tbl.[Primary], tbl.[Local], tbl.[CCGId], tbl.[StartDate],  tbl.[SCIStorePracticeId],3, GETDATE(), tbl.WhoUpdatedId
							FROM deleted tbl
GO

ALTER TABLE [dbo].[ERS_Practices] ENABLE TRIGGER [trg_ERS_Practices_Delete]
GO

Exec DropIfExist 'trg_ERS_GPS_Delete','TR'
/****** Object:  Trigger [dbo].[trg_ERS_Practices_Insert]    Script Date: 01/06/2023 15:43:54 ******/
SET ANSI_NULLS ON
GO

/****** Object:  Trigger [dbo].[trg_ERS_GPS_Delete]    Script Date: 01/06/2023 15:53:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_ERS_GPS_Delete] 
							ON [dbo].[ERS_GPS] 
							AFTER DELETE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_GPS_Audit] (GPId, tbl.[Code], tbl.[Title], tbl.[Initial], tbl.[Name], tbl.[TelNo], tbl.[Mobile], tbl.[Page], tbl.[Email], tbl.[NationalCode], tbl.[ExternalCode], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[CompleteName], tbl.[Comment], tbl.[Forename], tbl.[DateAdded], tbl.[Device], tbl.[Local],tbl.[SCIStoreGPId],  LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.GPId , tbl.[Code], tbl.[Title], tbl.[Initial], tbl.[Name], tbl.[TelNo], tbl.[Mobile], tbl.[Page], tbl.[Email], tbl.[NationalCode], tbl.[ExternalCode], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[CompleteName], tbl.[Comment], tbl.[Forename], tbl.[DateAdded], tbl.[Device], tbl.[Local],  tbl.[SCIStoreGPId],3, GETDATE(), tbl.WhoUpdatedId
							FROM deleted tbl
GO

ALTER TABLE [dbo].[ERS_GPS] ENABLE TRIGGER [trg_ERS_GPS_Delete]
GO


Exec DropIfExist 'trg_ERS_GPS_Insert','TR'
GO

/****** Object:  Trigger [dbo].[trg_ERS_GPS_Insert]    Script Date: 01/06/2023 15:55:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_ERS_GPS_Insert] 
							ON [dbo].[ERS_GPS] 
							AFTER INSERT
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_GPS_Audit] (GPId, tbl.[Code], tbl.[Title], tbl.[Initial], tbl.[Name], tbl.[TelNo], tbl.[Mobile], tbl.[Page], tbl.[Email], tbl.[NationalCode], tbl.[ExternalCode], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[CompleteName], tbl.[Comment], tbl.[Forename], tbl.[DateAdded], tbl.[Device], tbl.[Local], tbl.[SCIStoreGPId], LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.GPId , tbl.[Code], tbl.[Title], tbl.[Initial], tbl.[Name], tbl.[TelNo], tbl.[Mobile], tbl.[Page], tbl.[Email], tbl.[NationalCode], tbl.[ExternalCode], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[CompleteName], tbl.[Comment], tbl.[Forename], tbl.[DateAdded], tbl.[Device], tbl.[Local],  tbl.[SCIStoreGPId],1, GETDATE(), tbl.WhoCreatedId
							FROM inserted tbl
GO

ALTER TABLE [dbo].[ERS_GPS] ENABLE TRIGGER [trg_ERS_GPS_Insert]
GO

Exec DropIfExist 'trg_ERS_GPS_Update','TR'
GO

/****** Object:  Trigger [dbo].[trg_ERS_GPS_Update]    Script Date: 01/06/2023 15:56:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_ERS_GPS_Update] 
							ON [dbo].[ERS_GPS] 
							AFTER UPDATE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[ERS_GPS_Audit] (GPId, tbl.[Code], tbl.[Title], tbl.[Initial], tbl.[Name], tbl.[TelNo], tbl.[Mobile], tbl.[Page], tbl.[Email], tbl.[NationalCode], tbl.[ExternalCode], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[CompleteName], tbl.[Comment], tbl.[Forename], tbl.[DateAdded], tbl.[Device], tbl.[Local], tbl.[SCIStoreGPId], LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.GPId , tbl.[Code], tbl.[Title], tbl.[Initial], tbl.[Name], tbl.[TelNo], tbl.[Mobile], tbl.[Page], tbl.[Email], tbl.[NationalCode], tbl.[ExternalCode], tbl.[DateFrom], tbl.[DateTo], tbl.[Status], tbl.[CompleteName], tbl.[Comment], tbl.[Forename], tbl.[DateAdded], tbl.[Device], tbl.[Local],  tbl.[SCIStoreGPId],2, GETDATE(), i.WhoUpdatedId
							FROM deleted tbl INNER JOIN inserted i ON tbl.GPId = i.GPId
GO

ALTER TABLE [dbo].[ERS_GPS] ENABLE TRIGGER [trg_ERS_GPS_Update]
GO

EXEC DropIfExist 'InsertOrUpdateERS_GPS_FromSCIStore','S';
GO
CREATE PROCEDURE [dbo].[InsertOrUpdateERS_GPS_FromSCIStore]
(
	@GPId INT out,
	@Title VARCHAR(10),
	@Initial VARCHAR(10),
	@ForeName VARCHAR(100),
	@GPName VARCHAR(30),
	@Email VARCHAR(500),
	@Telephone VARCHAR(20),
	@LoggedInUserId INT,
	@SCIStoreGPId varchar(100)

)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
Set @GPId = 0

Select @GPId = Max(IsNull(GPId,0)) From ERS_GPS where SCIStoreGPId = @SCIStoreGPId

	IF @GPId IS NULL OR @GPId = 0
	BEGIN
		INSERT INTO [dbo].[ERS_GPS] (
			Title,
			Initial,
			[Code],
			[Name],
			ForeName,
			Email,
			TelNo,
			SCIStoreGPId,
			WhoCreatedId,
			WhenCreated)
		VALUES (
			@Title,
			@Initial,
			@SCIStoreGPId,
			@GPName,
			@ForeName,
			@Email,
			@Telephone,
			@SCIStoreGPId,
			@LoggedInUserId,
			GETDATE())

		SET @GPId = SCOPE_IDENTITY()
	END
	
	ELSE
	BEGIN
		UPDATE 
			[dbo].[ERS_GPS]
		SET 
			Title = @Title,
			Initial = @Initial,
			[Name] = @GPName,
			ForeName = @ForeName,
			Email = @Email,
			TelNo = @Telephone,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = getdate()
		WHERE 
			GPId = @GPId
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
Go

EXEC DropIfExist 'InsertOrUpdateERS_Practices_FromSCIStore','S';
GO
CREATE PROCEDURE [dbo].[InsertOrUpdateERS_Practices_FromSCIStore]
(
	@PracticeId INT output,
	@Code VARCHAR(6),
	@NationalCode VARCHAR(10),
	@Name VARCHAR(100),
	@Address1 VARCHAR(100),
	@Address2 VARCHAR(100),
	@Address3 VARCHAR(100),
	@Address4 VARCHAR(100),
	@Postcode VARCHAR(100),
	@TelNo VARCHAR(100),
	@Email VARCHAR(500),
	@LoggedInUserId INT,
	@SCIStorePracticeId varchar(100)

)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
Set @PracticeId = 0

Select @PracticeId = Max(IsNull(PracticeId,0)) From ERS_Practices where SCIStorePracticeId = @SCIStorePracticeId

	IF @PracticeId IS NULL OR @PracticeId = 0
	BEGIN
		INSERT INTO [dbo].[ERS_Practices] (
			Code,
			NationalCode,
			[Name],
			Address1,
			Address2,
			Address3,
			Address4,
			PostCode,
			TelNo,
			Email,
			SCIStorePracticeId,
			WhoCreatedId,
			WhenCreated)
		VALUES (
			@Code,
			@NationalCode,
			@Name,
			@Address1,
			@Address2,
			@Address3,
			@Address4,
			@Postcode,
			@TelNo,
			@Email,
			@SCIStorePracticeId,
			@LoggedInUserId,
			GETDATE())

		SET @PracticeId = SCOPE_IDENTITY()
	END
	
	ELSE
	BEGIN
		UPDATE 
			[dbo].[ERS_Practices]
		SET 
			Code = @Code,
			NationalCode = @NationalCode,
			[Name] = @Name,
			Address1 = @Address1,
			Address2 = @Address2,
			Address3 = @Address3,
			Address4 = @Address4,
			PostCode = @Postcode,
			TelNo = @TelNo,
			Email = @Email,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = getdate()
		WHERE 
			PracticeId = @PracticeId
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
Go

EXEC DropIfExist 'stp_InsertUpdatePatientFromWebservice','S';
GO
-- =============================================
-- Author:		Mahfuz
-- Create date: 10 Mar 2021
-- Description:	Insert or update patient table with patient data imported by Web Service (D&G SE upgrade)
-- 25 May 2021		:		Mahfuz fixed with GPId which is not in local Database
-- 25 May 2021		:		Mahfuz added additional parameter TrustId
-- 07 Jun 2023		:		MH added extra parameter PracticeId, changed internal structure as GPId and PracticeId will be passed through after processing outside
-- =============================================

CREATE PROCEDURE [dbo].[stp_InsertUpdatePatientFromWebservice]
(
	@PatientId INT=NULL,
	@CaseNoteNo VARCHAR(100),
	@Title VARCHAR(20),
	@Forename VARCHAR(100),
	@Surname NVARCHAR(100),
	@DateOfBirth DATETIME2,
	@NHSNo VARCHAR(20),
	@Address1 NVARCHAR(500),
	@Address2 NVARCHAR(500),
	@Town NVARCHAR(500),
	@County NVARCHAR(500),
	@PostCode VARCHAR(10),
	@PhoneNo VARCHAR(20),
	@Gender VARCHAR(1),
	@EthnicOrigin VARCHAR(100)=NULL,
	@JustDownloaded BIT=NULL,
	@Notes VARCHAR(200)=NULL,
	@District VARCHAR(50)=NULL,
	@DHACode NVARCHAR(20)=NULL,
	@GPId INT=NULL,
	@PracticeId int=NULL,
	@DateOfDeath DATETIME2=NULL,
	@AdvocateRequired BIT=NULL,
	@DateLastSeenAlive DATETIME2=NULL,
	@CauseOfDeath NVARCHAR(500)=NULL,
	@CodeForCauseOfDeath VARCHAR(100)=NULL,
	@CARelatedDeath BIT=NULL,
	@DeathWithinHospital BIT=NULL,
	@Hospitals INT=NULL,
	@ExtraReferral NVARCHAR(100)=NULL,
	@ConsultantNo INT=NULL,
	@HIVRisk INT=NULL,
	@OutcomeNotes NVARCHAR(100)=NULL,
	@UniqueHospitalId INT=NULL,
	@GPReferralFlag BIT=NULL,
	@OwnedBy VARCHAR(100)=NULL,
	@HasImages BIT=NULL,
	@VerificationStatus VARCHAR(4)=NULL,
	@LoggedInUserId INT,
	@MaritalStatus varchar(100)=null,
	@TrustId INT=NULL
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
       declare @intOurPatientID as int
	   declare @intMaritalStatusId as int

	   --Mahfuz added on 25 May 2021 -
	   If IsNull(@TrustId,0) = 0 or not exists(Select * from ERS_Trusts where TrustID = @TrustId)
	   begin
		Select top 1 @TrustId = TrustID from ERS_Trusts
	   end

	   ---------- Changed on 07 Jun 2023
	   /*
	   IF ISNULL(@GPId,0) <> 0 and NOT EXISTS(Select * from ERS_GPS where GPId = @GPId)
	   begin
		Set @GPId = 0
	   end

	   IF ISNULL(@GPId,0) = 0  SELECT @GPId = GPId  FROM dbo.ERS_GPS WHERE [Code] = 'G9999998'
	   --If not found
	   IF ISNULL(@GPId,0) = 0 
	   BEGIN
			--Check if they provided GP information
			If IsNull(@RegisteredGPName,'') <> '' And IsNull(@RegisteredGPCode,'') <> '' 
			Begin
					INSERT INTO ERS_GPS (Code, Name, [NationalCode], [ExternalCode]) 
						VALUES (@RegisteredGPCode, @RegisteredGPName, @RegisteredGPCode, @RegisteredGPCode)

						SET @GPId = @@IDENTITY
			End
			Else
			Begin
				INSERT INTO ERS_GPS (Code, Name, [NationalCode], [ExternalCode]) 
						VALUES ('G9999998', 'Not Stated', 'G9999998', 'G9999998')

						SET @GPId = @@IDENTITY
			End

	   END
	   */

	   if IsNull(@GPId,0) < 1 Or NOT EXISTS(Select * from ERS_GPS where GPId = @GPId) 
	   begin
		Set @GPId = null
	   end

	   if IsNull(@PracticeId,0) < 1 Or NOT EXISTS(Select * from ERS_Practices where PracticeId = @PracticeId) 
	   begin
		Set @PracticeId = null
	   end


	   -- Handling Marital Status - SCI Store has compact less word in Marital Status - i.e SCIStore has a word 'Married' whereas we have 'Married/Civil Partner'
	   Select top 1 @intMaritalStatusId = IsNull(MaritalId,0) from dbo.ERS_Marital_Status where [Status] = @MaritalStatus 
	   if IsNull(@intMaritalStatusId,0) = 0
	   begin
		Select top 1 @intMaritalStatusId = IsNull(MaritalId,0) from dbo.ERS_Marital_Status where [Status] Like Convert(varchar(max),@MaritalStatus + '%')
	   end
	   if IsNull(@intMaritalStatusId,0) = 0
	   begin
		Select top 1 @intMaritalStatusId = IsNull(MaritalId,0) from dbo.ERS_Marital_Status where [Status] = 'Unknown'
	   end
	   if IsNull(@intMaritalStatusId,0) = 0
	   begin
		Select top 1 @intMaritalStatusId = IsNull(MaritalId,0) from dbo.ERS_Marital_Status where [Status] = 'Not disclosed'
	   end

       -- When importing from SCI Store, we have SCI Store Patient Id which we save in AccountNumber column. So, gets our PatientID
	   -- from SCI Store patient ID stored in AccountNumber field

	   --1. First check with CHI no (our NHSNo) and Full Name and Date Of Birth
	   SELECT @intOurPatientID = PatientId FROM ERS_Patients WHERE Forename1 = @Forename and Surname = @Surname and NHSNo = @NHSNo and DateOfBirth=@DateOfBirth

	   
	   --2. Secondly check with CHI no and Date of Birth
	   IF ISNULL(@intOurPatientID,0)= 0
	   begin
	   SELECT @intOurPatientID = PatientId FROM ERS_Patients WHERE NHSNo = @NHSNo and DateOfBirth=@DateOfBirth
	   end

	   --3. Thirdly check with CHI no
	   IF ISNULL(@intOurPatientID,0)= 0
	   begin
	   SELECT @intOurPatientID = PatientId FROM ERS_Patients WHERE NHSNo = @NHSNo
	   end


	   --4 . Fourthly check with SCI Store PatientID in our AccountNumber field
	   IF ISNULL(@intOurPatientID,0)= 0
	   begin
	   SELECT @intOurPatientID = PatientId FROM ERS_Patients WHERE AccountNumber = Cast(@PatientId as varchar(max))
	   end

      

	IF ISNULL(@intOurPatientID,0)= 0
	BEGIN
		INSERT INTO ERS_Patients (
			HospitalNumber
			,[Title]
			,[Forename1]
			,[Surname]
			,[Dateofbirth]
			,[NHSNo]
			,[Address1]
			,[Address2]
			,[Address3]
			,[Address4]
			,[Postcode]
			,[Telephone]
			,[GenderId]
			,[EthnicId]
			,[MaritalId]
			,[RegGpId]
			,[RegGpPracticeId]
			,[Dateofdeath]
			,[WhoCreatedId]
			,[WhenCreated]
			,[CreateUpdateMethod]
			,[AccountNumber])
		VALUES (
			@CaseNoteNo,
			@Title,
			@Forename,
			@Surname,
			@DateOfBirth,
			@NHSNo,
			@Address1,
			@Address2,
			@Town,
			@County,
			@PostCode,
			@PhoneNo,
			(SELECT GenderId FROM ERS_GenderTypes WHERE Code = @Gender),
			(SELECT EthnicOriginId FROM ERS_EthnicOrigins WHERE EthnicOrigin = @EthnicOrigin),
			@intMaritalStatusId,
			@GPId,
			@PracticeId,
			@DateOfDeath,
			@LoggedInUserId,
			GETDATE(),
			'WSIMPORT',
			Cast(@PatientId as varchar(max)))
		SET @intOurPatientID = SCOPE_IDENTITY()

		--Mahfuz added on 25th May 2021
		Insert into ERS_PatientTrusts(PatientId,TrustId,HospitalNumber)
		Values(@intOurPatientID,@TrustId,@NHSNo)
	END
	ELSE
	BEGIN
		UPDATE 
			ERS_Patients
		SET 
			Title = @Title,
			Forename1 = @Forename,
			Surname = @Surname,
			[Dateofbirth] = @DateOfBirth,
			[NHSNo] = @NHSNo,
			[Address1] = @Address1,
			[Address2] = @Address2,
			[Address3] = @Town,
			[Address4] = @County,
			[Postcode] = @PostCode,
			[Telephone] = @PhoneNo,
			GenderId = (SELECT top 1 GenderId FROM ERS_GenderTypes WHERE Code = @Gender),
			[EthnicId] = (SELECT top 1 EthnicOriginId FROM ERS_EthnicOrigins WHERE EthnicOrigin = @EthnicOrigin),
			MaritalId = @intMaritalStatusId,
			RegGPId = @GPId,
			RegGpPracticeId = @PracticeId,
			[Dateofdeath] = @DateOfDeath,
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = GETDATE(),
			CreateUpdateMethod = 'WSIMPORT'
		WHERE 
			[PatientId] = @intOurPatientID

			--Mahfuz Added on 25 May 2021
			if exists(Select * from ERS_PatientTrusts where PatientId = @intOurPatientID) 
			Begin
				Update ERS_PatientTrusts
				Set HospitalNumber = @NHSNo,
				TrustId = @TrustId
				Where PatientId = @intOurPatientID
			End
			else
			Begin
				Insert into ERS_PatientTrusts(PatientId,TrustId,HospitalNumber)
				Values(@intOurPatientID,@TrustId,@NHSNo)
			End

	END

	If IsNull(@GPId,0) > 0 and IsNull(@PracticeId,0) > 0 
	Begin
		If Not Exists(Select * from ERS_Practices_Link Where GPId = @GPId and PracticeId = @PracticeId) 
		Begin
			Insert into ERS_Practices_Link(GPId,PracticeId,IsPrimary,WhoCreatedId,WhenCreated)
			Values(@GPId,@PracticeId,1,@LoggedInUserId,getdate())
		End
	End

	SELECT @intOurPatientID
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
Go

EXEC DropIfExist 'usp_get_genders','S';
GO
CREATE PROCEDURE [dbo].[usp_get_genders]
AS
--MH created on 06 Jun 2023 - TFS #2864
BEGIN
	SELECT GenderId, Code, NHSType, Title, HL7Code 
	FROM ERS_GenderTypes
	Order by SortOrder asc

END
Go

EXEC DropIfExist 'startup_select','S';
GO
CREATE PROCEDURE [dbo].[startup_select] (
	@SearchString1 VARCHAR(500)			--CaseNoteNo
	,@SearchString2 VARCHAR(500)		--NHSNo
	,@SearchString3 VARCHAR(500)		--Surname
	,@SearchString4 VARCHAR(500)		--Forename
	,@SearchString5 VARCHAR(500)		--DOB
	,@SearchString6 VARCHAR(500)		--Address
	,@SearchString7 VARCHAR(500)		--Postcode
	,@searchGender Varchar(500)			--Gender
	,@SearchTab INT = 0					
	,@Condition VARCHAR(50) = ''		
	,@SearchType VARCHAR(50)
	,@ExcludeDeceased BIT = 0			--ExcludeDeadOption
	,@UserId INT						--UserId
	,@UserName NVARCHAR(500)			--UserName
	,@TrustId int )
AS
/*	Update History		:		07 Sept 2022 MH copied from SE1 - treat single quote in name, fix duplicate NHSNo (Isminor) etc 
						:		18 Nov 2022 MH implemented Soundex (pronounced like) search on Patient Surname and Forename TFS 2446
						:		06 Jun 2023 MH added search with Gender - Parameter value will be M, F, U or T or NULL/ ''
*/
DECLARE @Statement NVARCHAR(max)
DECLARE @Statement2 NVARCHAR(max)
DECLARE @SearchCriteria INT
	,@SearchCriteriaOption INT
	,@SearchCriteriaOptionPatientCount INT
	,@SearchCriteriaOptionDate DATETIME
	,@SearchCriteriaOptionMonths INT
	,@ExcludeDeadOption BIT
	,@ExcludeUGI BIT
	,@AllProcedures BIT
	,@Gastroscopy BIT
	,@ERCP BIT
	,@Colonoscopy BIT
	,@Proctoscopy BIT
	,@OutstandingCLO BIT
	,@OrderListOptions INT


--MH replaces single ' with '' in Surname and Forename variables.
Set @SearchString3 = Replace(@SearchString3,'''','''''')
Set @SearchString4 = Replace(@SearchString4,'''','''''')

IF EXISTS (SELECT 1 FROM ERS_StartupSettings WHERE ISNULL(UserId,0) = @UserId)
	SELECT TOP (1) @SearchCriteria = [SearchCriteria]
		,@SearchCriteriaOption = [SearchCriteriaOption]
		,@SearchCriteriaOptionPatientCount = [SearchCriteriaOptionPatientCount]
		,@SearchCriteriaOptionDate = [SearchCriteriaOptionDate]
		,@SearchCriteriaOptionMonths = [SearchCriteriaOptionMonths]
		,@ExcludeDeadOption = [ExcludeDeadOption]
		,@ExcludeUGI = [ExcludeUGI]
		,@AllProcedures = [AllProcedures]
		,@Gastroscopy = [Gastroscopy]
		,@ERCP = [ERCP]
		,@Colonoscopy = [Colonoscopy]
		,@Proctoscopy = [Proctoscopy]
		,@OutstandingCLO = [OutstandingCLO]
		,@OrderListOptions = [OrderListOptions]
	FROM [ERS_StartupSettings]
	WHERE UserID = @UserId
ELSE
	SELECT TOP (1) @SearchCriteria = [SearchCriteria]
	,@SearchCriteriaOption = [SearchCriteriaOption]
	,@SearchCriteriaOptionPatientCount = [SearchCriteriaOptionPatientCount]
	,@SearchCriteriaOptionDate = [SearchCriteriaOptionDate]
	,@SearchCriteriaOptionMonths = [SearchCriteriaOptionMonths]
	,@ExcludeDeadOption = [ExcludeDeadOption]
	,@ExcludeUGI = [ExcludeUGI]
	,@AllProcedures = [AllProcedures]
	,@Gastroscopy = [Gastroscopy]
	,@ERCP = [ERCP]
	,@Colonoscopy = [Colonoscopy]
	,@Proctoscopy = [Proctoscopy]
	,@OutstandingCLO = [OutstandingCLO]
	,@OrderListOptions = [OrderListOptions]
	FROM [ERS_StartupSettings]

DECLARE @SQLString VARCHAR(max)
	,@SelectStr VARCHAR(max)
	,@FromStr VARCHAR(500)
	,@FromStr2 VARCHAR(500)
	,@WhereStr VARCHAR(1000)
	,@WhereStr2 VARCHAR(1000)
	,@OrderStr VARCHAR(1000)

SET @SelectStr = 'SELECT DISTINCT	p.PatientId, 
									p.Forename1 + '' '' + p.Surname AS PatientName, 
									dbo.fnFullAddress(p.Address1, p.Address2, p.Address3, p.Address4, '''') as Address, 
									p.DateOfBirth AS DOB, 
									UPPER(SUBSTRING(dbo.fnGender(p.GenderId),1,1)) as Gender, 
									dbo.fnEthnicity(p.EthnicId) as Ethnicity, 
									CASE WHEN EXISTS (select TOP 1 HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId and IsMinor = 0) 
									 THEN STUFF((SELECT DISTINCT '',''+HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId and IsMinor = 0 for xml path('''')), 1, 1, '''')
									 ELSE STUFF((SELECT DISTINCT '',''+HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId and IsMinor = 1 for xml path('''')), 1, 1, '''')
								    END AS CaseNoteNo, 
									p.NHSNo, 
									p.DateAdded AS CreatedOn, 
									ISNULL(Deceased,0) AS Deceased,
									--ROW_NUMBER() OVER (ORDER BY p.PatientId) AS PatientRowId,
									p.PatientId AS PatientId, 
									NULL AS UGIPatientId,
									NULL AS ComboId,
									1 AS ERSPatient, 
									p.Title AS Title, 
									p.Forename1 AS Forename1, 
									p.Surname AS Surname, 
									dbo.fnGender(p.GenderId) AS Gender, 
									p.Forename1 + '' '' + p.Surname AS PatientName, 
									dbo.fnFullAddress(p.Address1, p.Address2, p.Address3, p.Address4, '''') AS Address, 
									p.PostCode,
									p.Telephone,
									p.DateOfBirth AS DateOfBirth, 
									CASE WHEN EXISTS (select TOP 1 HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId and IsMinor = 0) 
									 THEN STUFF((SELECT DISTINCT '',''+HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId and IsMinor = 0 for xml path('''')), 1, 1, '''')
									 ELSE STUFF((SELECT DISTINCT '',''+HospitalNumber from ERS_PatientTrusts where PatientId = p.PatientId and IsMinor = 1 for xml path('''')), 1, 1, '''')
								    END AS HospitalNumber,
									p.NHSNo AS NHSNo, 
									p.DateAdded AS DateAdded,
									p.DateUpdated AS DateUpdated,
									p.EthnicId AS EthnicId,
									p.DateOfDeath AS DateOfDeath,
									ISNULL(p.Deceased,0)  AS Deceased,
									p.CreateUpdateMethod'
SET @FromStr = ' FROM ERS_Patients p inner join  ERS_PatientTrusts pt on  p.PatientId = pt.PatientId Left join ERS_GenderTypes gt on p.GenderId = gt.GenderId'
SET @FromStr2 = ' FROM ERS_Patients p JOIN ERS_MergeJournal mj on p.PatientId = mj.MasterPatientId  Left join ERS_GenderTypes gt on p.GenderId = gt.GenderId'
SET @WhereStr = ''
SET @WhereStr2 = ''
SET @OrderStr = ' ORDER BY p.DateAdded DESC, p.PatientId  DESC'

IF @SearchCriteria = 1 OR @SearchTab IN (1, 2) --(@SearchCriteria=2 AND @SearchTab <> 0)
BEGIN
print 'searchtab = ' + convert(varchar, @SearchTab)
	IF @SearchTab = 1
	BEGIN
		IF @searchString1 IS NOT NULL AND @searchString1 <> ''
		BEGIN
			SET @WhereStr = (
					SELECT CASE @Condition
							WHEN 'ALL'
								THEN ' WHERE pt.HospitalNumber = ISNULL(''' + @SearchString1 + ''','''') OR NHSNo = ISNULL(''' + @SearchString1 + ''','''') OR Surname LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' OR Forename1 LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							WHEN 'Case note no.'
								THEN ' WHERE pt.HospitalNumber LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							WHEN 'NHS No'
								THEN ' WHERE REPLACE(NHSNo, '' '','''') LIKE ''%'' + ISNULL(''' + REPLACE(@SearchString1,' ', '') + ''','''') + ''%'' '
							WHEN 'Surname'
								THEN ' WHERE Surname LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							WHEN 'Forenames'
								THEN ' WHERE Forename1 LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							END
					)
			SET @WhereStr2 = (
					SELECT CASE @Condition
							WHEN 'ALL'
								THEN ' WHERE mj.SlaveExt LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' OR NHSNo = ISNULL(''' + @SearchString1 + ''','''') OR Surname LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' OR Forename1 LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							WHEN 'Case note no.'
								THEN ' WHERE mj.SlaveExt LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							WHEN 'NHS No'
								THEN ' WHERE REPLACE(NHSNo, '' '','''') = ISNULL(''' + REPLACE(@SearchString1,' ', '') + ''','''') '
							WHEN 'Surname'
								THEN ' WHERE Surname LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							WHEN 'Forenames'
								THEN ' WHERE Forename1 LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
							END
					)
			
		END
	END
	ELSE
	BEGIN
		IF @SearchString1 IS NOT NULL AND @SearchString1 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' pt.HospitalNumber = ISNULL(''' + @SearchString1 + ''','''') '
			SET @WhereStr2 = @WhereStr2 + (
					SELECT CASE @WhereStr2
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' mj.SlaveExt LIKE ''%'' + ISNULL(''' + @SearchString1 + ''','''') + ''%'' '
			print @WhereStr2
		END

		IF @SearchString2 IS NOT NULL AND @SearchString2 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' REPLACE(NHSNo,'' '', '''') = ISNULL(''' + REPLACE(@SearchString2, ' ', '') + ''','''') '
		END

		IF @SearchString3 IS NOT NULL AND @SearchString3 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' ((Surname LIKE ''%'' + ISNULL(''' + @SearchString3 + ''','''') + ''%'') Or Soundex(Surname) = Soundex(''' + @SearchString3 + '%'')) '
		END

		IF @SearchString4 IS NOT NULL AND @SearchString4 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' ((Forename1 LIKE ''%'' + ISNULL(''' + @SearchString4 + ''','''') + ''%'') Or Soundex(Forename1) = Soundex(''' + @SearchString4 + '%'')) '
		END

		IF @SearchString5 IS NOT NULL AND @SearchString5 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' DateOfBirth = '''' + ISNULL(''' + @SearchString5 + ''','''') + '''' '
		END

		IF @SearchString6 IS NOT NULL AND @SearchString6 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition END
					) + ' LTRIM(RTRIM(Address)) LIKE ''%'' + ISNULL(''' + LTRIM(RTRIM(@SearchString6)) + ''','''') + ''%'' '
		END

		IF @SearchString7 IS NOT NULL AND @SearchString7 <> ''
		BEGIN
			SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition	END
					) + ' REPLACE(Postcode, '' '', '''') LIKE ''%'' + ISNULL(''' + REPLACE(@SearchString7, ' ', '') + ''','''') + ''%'' '
		END

		IF @searchGender IS NOT NULL AND @searchGender <> ''
		BEGIN
			if @searchGender = 'N'
			begin
				SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition	END
					) + ' (REPLACE(gt.Code, '' '', '''') = ISNULL(''' + REPLACE(@searchGender, ' ', '') + ''','''') Or gt.Code Is Null)'
			end
			else
			begin
				SET @WhereStr = @WhereStr + (
					SELECT CASE @WhereStr
							WHEN ''	THEN ' WHERE ' ELSE @Condition	END
					) + ' REPLACE(gt.Code, '' '', '''') = ISNULL(''' + REPLACE(@searchGender, ' ', '') + ''','''') '
			end

			
		END

	END
	--Added For Trust Requirement
	SET @WhereStr = @WhereStr + ' AND pt.TrustId= ' + cast(@TrustId as varchar)
	
	IF @ExcludeDeceased = 1
		BEGIN
			IF @WhereStr <> ''
				SET @WhereStr = @WhereStr + ' AND ISNULL([Deceased],0) = 0'
			ELSE
				SET @WhereStr = 'WHERE ISNULL([Deceased],0) = 0'
		END

	--SET @SelectStr = @SelectStr + @FromStr
END
ELSE IF @SearchCriteria = 2
BEGIN
	--IF @AllProcedures = 1
	--BEGIN
		--IF @SearchCriteriaOption =1 SET @SelectStr = 'SELECT DISTINCT p.[Patient No] AS PatientId, p.Forename + '' '' + p.Surname AS PatientName, p.[Case note no] AS CaseNoteNo, p.[NHS No] AS NHSNo, p.[Record created] AS CreatedOn,p.[Surname] ,p.[Case note no] ,p.[Product ID] ,p.[Location ID] ,p.[Patient No] ,  p.[Has Images] ,p.[Just downloaded] ,p.[Forename] ,p.[Record created] ,p.[Combo ID] ,p.[NHS No] ,p.[Date of death]  FROM Patient p'
		IF @SearchCriteriaOption = 2 AND @SearchCriteriaOptionPatientCount > 0
			SET @SelectStr = 'SELECT TOP(' + CAST(@SearchCriteriaOptionPatientCount AS VARCHAR(50)) + ')  p.PatientId, p.Forename1 + '' '' + p.Surname AS PatientName, p.Address1 as Address, p.DateOfBirth AS DOB, UPPER(SUBSTRING(p.Gender,1,1)) as Gender, dbo.fnEthnicity(p.EthnicId) as Ethnicity, p.HospitalNumber AS CaseNoteNo, p.NHSNo, p.DateAdded AS CreatedOn, ISNULL(Deceased,0) AS Deceased (**) '
		ELSE IF @SearchCriteriaOption = 3 AND @SearchCriteriaOptionDate IS NOT NULL
			SET @WhereStr = 'WHERE DateAdded >= ''' + cast(@SearchCriteriaOptionDate AS VARCHAR(50)) + ''' '
		ELSE IF @SearchCriteriaOption = 4 AND @SearchCriteriaOptionMonths > 0
			SET @WhereStr = 'WHERE DateAdded >= DATEADD(MM,-' + CAST(@SearchCriteriaOptionMonths AS VARCHAR(50)) + ', GETDATE())'

		IF @ExcludeDeceased = 1
		BEGIN
			IF @WhereStr <> ''
				SET @WhereStr = @WhereStr + ' AND ISNULL([Deceased],0) = 0'
			ELSE
				SET @WhereStr = 'WHERE ISNULL([Deceased],0) = 0'
		END

		--SET @SelectStr = @SelectStr + @FromStr

END

IF @OrderListOptions = 2
	SET @OrderStr = ' ORDER BY [Surname], p.PatientId  DESC'

SET @Statement = @SelectStr + @FromStr + @WhereStr + @OrderStr
SET @Statement2 = @SelectStr + @FromStr + @WhereStr + ' union ' + @SelectStr + @FromStr2 + @WhereStr2 + @OrderStr

SET @Statement = (
					SELECT CASE @SearchType
							WHEN 'EQUALTO'
								THEN REPLACE(REPLACE(REPLACE(@Statement,'LIKE','='),'''%'' +',''),'+ ''%''','')
							WHEN 'STARTSWITH'
								THEN REPLACE(@Statement,'''%'' +','')
							WHEN 'ENDSWITH'
								THEN REPLACE(@Statement,'+ ''%''','')
							WHEN 'CONTAINS'
								THEN @Statement	
							END
					)
SET @Statement2 = (
					SELECT CASE @SearchType
							WHEN 'EQUALTO'
								THEN REPLACE(REPLACE(REPLACE(@Statement2,'LIKE','='),'''%'' +',''),'+ ''%''','')
							WHEN 'STARTSWITH'
								THEN REPLACE(@Statement2,'''%'' +','')
							WHEN 'ENDSWITH'
								THEN REPLACE(@Statement2,'+ ''%''','')
							WHEN 'CONTAINS'
								THEN @Statement2	
							END
					)

print @Statement

print @Statement2
IF ISNULL(@SearchString1, '') = ''
BEGIN
	EXEC sp_executesql @Statement
END
else
BEGIN
	EXEC sp_executesql @Statement2
END


DECLARE
	@sqlStringAudit NVARCHAR(MAX) = 'Searched: '

BEGIN

	IF @Condition <> '' 
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Search Condition: ' + ISNULL(@Condition, '') + '. '
	END

	IF @SearchString1 <> '' 
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Case Note No: ' + ISNULL(@SearchString1, '') + '. '
	END
	
	IF ISNULL(@SearchString2, '') <> ''
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'NHS No: ' + ISNULL(@SearchString2, '') + '. '
	END	

	IF ISNULL(@SearchString3, '') <> ''
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Surname: ' + ISNULL(@SearchString3, '') + '. '
	END

	IF ISNULL(@SearchString4, '') <> ''
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Forename: ' + ISNULL(@SearchString4, '') + '. '
	END

	IF ISNULL(@SearchString5, '') <> ''
	BEGIN	
		SET @sqlStringAudit = @sqlStringAudit + 'Date of Birth: ' + ISNULL(@SearchString5, '') + '. '
	END

	IF ISNULL(@SearchString6, '') <> ''
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Address: ' + ISNULL(@SearchString6, '') + '. '
	END

	IF ISNULL(@SearchString7, '') <> ''
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Postcode: ' + ISNULL(@SearchString7, '') + '. '
	END

	IF ISNULL(@searchGender, '') <> ''
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Gender: ' + ISNULL(@searchGender, '') + '. '
	END

	IF @ExcludeDeceased = 1
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Exclude Deceased: True. '
	END
	ELSE
	BEGIN
		SET @sqlStringAudit = @sqlStringAudit + 'Exclude Deceased: False. '
	END

	BEGIN
	INSERT INTO ERS_UserActivityAudit
	(
		[UserID],
		[UserName],
		[Action],
		[ActionDetails],
		[PatientId],	
		[When]	
	)
	VALUES
	(
		@UserId,
		UPPER(@UserName),
		'SEARCH',
		@sqlStringAudit,
		NULL,
		GETDATE()
	)
	END
END
Go
------------------------------------------------------------------------------------------------------------------------
-- END OF -- TFS#	2864, 2859,2863,2865 by Mahfuz
------------------------------------------------------------------------------------------------------------------------
Go
Go
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Mahfuz	On 21 Jul 2023
-- TFS#	2989
-- Description of change
-- Gateway Web Api and integrate with SE 2 for xml doc transfer - D&G
------------------------------------------------------------------------------------------------------------------------
Go
--Check if column exists in a table
Print 'Adding Column ReportDocumentExportApiUrl to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ReportDocumentExportApiUrl' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [ReportDocumentExportApiUrl] varchar(2000) NULL;

GO

--Check if column exists in a table
Print 'Adding Column DocumentExportSharedLocation to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'DocumentExportSharedLocation' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [DocumentExportSharedLocation] varchar(2000) NULL;

GO


--Check if column exists in a table
Print 'Adding Column ReportSharedDriveAccessUser to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ReportSharedDriveAccessUser' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [ReportSharedDriveAccessUser] varchar(200) NULL;

GO


--Check if column exists in a table
Print 'Adding Column SharedDriveAccessUserPassword to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'SharedDriveAccessUserPassword' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [SharedDriveAccessUserPassword] varchar(20) NULL;

GO

--Check if column exists in a table
Print 'Adding Column DirectoryNameForXmlTransferInAzure to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'DirectoryNameForXmlTransferInAzure' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [DirectoryNameForXmlTransferInAzure] varchar(100) NULL;

GO

Go
EXEC DropIfExist 'uspGetProcedureSiteImagesAndDocumentsStoreData','S';
GO
CREATE PROCEDURE [dbo].[uspGetProcedureSiteImagesAndDocumentsStoreData]
(
	@ProcedureId AS INT
)
AS
BEGIN
	SET NOCOUNT ON;

/*
	21 April 2021		:		Mahfuz		created for PAS SE Upgrade for D&G

	test :			exec uspGetProcedureSiteImagesAndDocumentsStoreData 1576
*/

Create table #tempImageDocumentsData
(
	RecId int identity(1,1),
	PhotoName varchar(max),
	PhotoBlob varbinary(max),
	DateTimeStamp datetime,
	Region varchar(200),
	FileType varchar(50),
	DocumentVersion int,
	FileSizeInBytes int,
	CompressionMethod varchar(50),
	CompressedSizeInBytes int,
	TextEncodeMethod varchar(50),
	Base64TextContent varchar(max)
)

insert into #tempImageDocumentsData(PhotoName,PhotoBlob,DateTimeStamp,Region,FileType,DocumentVersion,FileSizeInBytes,CompressionMethod,CompressedSizeInBytes,TextEncodeMethod)
Select ph.PhotoName,ph.PhotoBlob,Ph.DateTimeStamp,r.Region, 'Image' as FileType,0 as DocumentVersion,
0 as FileSizeInBytes,'None' as CompressionMethod,0 as CompressedSizeInBytes,'Base64' as TextEncodeMethod
From ERS_Photos ph 
left join ERS_Sites s on ph.SiteId=s.SiteId
left join ERS_Regions r on s.RegionId=r.RegionId
Where ph.ProcedureId = @ProcedureId


declare @docVersion as int
declare @documentName as varchar(100)
set @docVersion = (Select count(*) from ERS_DocumentStore Where ProcedureId = @ProcedureId)

set @documentName = (Select pt.ReportHeader + 'Document_Ver_' + convert(varchar(5),@docVersion) + '.pdf' from ERS_Procedures p inner join ERS_ProcedureTypes pt on p.ProcedureType=pt.ProcedureTypeId Where ProcedureId=@ProcedureId)

insert into #tempImageDocumentsData(PhotoName,PhotoBlob,DateTimeStamp,Region,FileType,DocumentVersion,FileSizeInBytes,CompressionMethod,CompressedSizeInBytes,TextEncodeMethod,Base64TextContent)
Select top 1 @documentName as PhotoName,PDF as PhotoBlob,CreateDate as DateTimeStamp,'' as Region,'PDF' as FileType,@docVersion as DocumentVersion,
Len(PDF) as FileSizeInBytes,'None' as CompressionMethod,0 as CompressedSizeInBytes,'Base64' as TextEncodeMethod,
cast('' as xml).value('xs:base64Binary(sql:column("PDF"))', 'varchar(max)') as Base64TextContent
From ERS_DocumentStore Where ProcedureId = @ProcedureId 
Order by CreateDate desc


Select * from #tempImageDocumentsData

drop table #tempImageDocumentsData
END
Go
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	2989 by Mahfuz
------------------------------------------------------------------------------------------------------------------------
Go

--Fix for adding a new Trust not creating default hospital.
GO
PRINT N'  Altering [dbo].[add_new_operating_hospital]...';

GO

EXEC dbo.DropIfExist @ObjectName = 'add_new_operating_hospital',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO

/****** Object:  StoredProcedure [dbo].[add_new_operating_hospital]    Script Date: 20/09/2023 13:19:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------
CREATE PROCEDURE [dbo].[add_new_operating_hospital]
(
	@InternalHospitalID VARCHAR(150), 
	@NHSHospitalID VARCHAR(150), 
	@TrustId int,
	@HospitalName VARCHAR(150), 
	@ContactNumber VARCHAR(150), 
	@ReportExportPath VARCHAR(500),
	@ReportHeading VARCHAR(200), 
    @ReportTrustType VARCHAR(200),
    @ReportSubHeading VARCHAR(200),
	@ReportFooter VARCHAR(500),
    @DepartmentName VARCHAR(200),
	@NEDExportPath VARCHAR(200),
	@NEDODSCode VARCHAR(50),
	@LoggedInUserId INT,
	@CopyPrintSettings BIT,
	@CopyPhraseLibrary BIT,
	@ImportPatientByWebservice int,
	@AddExportFileForMirth bit,
	@ExportDocumentFilePrefix varchar(30),
	@SuppressMainReportPDF bit = 0,
	@TrustName varchar(200) = NULL
	
)
AS

/**************************************************************************
 Author:		?
 Create date:	?
 Description:	Create a new operating hospital. Inserts into 
				OperatingHospital, System_Config and the print settings
*****************************************************************************************
*****                        Change History											*****
*****************************************************************************************
** Rev	Date			Author		Description 
** --	-----------		---------	-------------------------------------------------------------------
** 1	25 Jul 2019		Duncan		Added report footer to System Config
** 
** 2    21 Jan 2021     Duncan      Added TrustId
**
** 3	08 Mar 2021		Mahfuz		Added ImportPatientByWebservice
** 4	19 Mar 2021		Mahfuz		updated ImportPatientByWebservice column as Int
** 5	25 May 2021		Andrea		Added new trust entry option and General room and Image port now added when creating a new OH
** 6	06 Aug 2021		Adrian		Fixed bug that when the print settings are duplicated, they miss out the defaultphotosize
** 7	05 Oct 2021		Duncan		Fixed DefaultPhotoSize in print settings so that Null is not inserted (defaults to 2)
** 8	17 Nov 2021		Mahfuz		added new parameter AddExportFileForMirth, TFS #1779
** 9	05 Jan 2022		Mahfuz		added new parameter ExportDocumentFilePrefix TFS # 1832
** 10	29 Mar 2022		Mahfuz		added new parameter SuppressMainReportPDF TFS # 1985 - Suppress PDF (Main report) from the Exported document if no required
*******************************************************************************************************/
SET NOCOUNT ON

BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @NewOHID INT, @OperatingHospitalId INT, @NewRoomId INT

		--IF @TrustName IS NOT NULL
		--BEGIN
		--	INSERT INTO ERS_Trusts (TrustName) VALUES (@TrustName)

		--	SET @TrustId = SCOPE_IDENTITY()
		--END

		SELECT TOP 1 @OperatingHospitalId = OperatingHospitalId FROM ERS_OperatingHospitals ORDER BY OperatingHospitalId

		INSERT INTO ERS_OperatingHospitals (InternalHospitalID, NHSHospitalID, HospitalName, ContactNumber, ReportExportPath, TrustId,ImportPatientByWebservice,AddExportFileForMirth,SuppressMainReportPDF,ExportDocumentFilePrefix)
		VALUES (@InternalHospitalID, @NHSHospitalID, @HospitalName, @ContactNumber, @ReportExportPath, @TrustId, @ImportPatientByWebservice,@AddExportFileForMirth,@SuppressMainReportPDF,@ExportDocumentFilePrefix); 

		SET @NewOHID = SCOPE_IDENTITY()

		--Assign Admin and logged in user (if not admin) to new hospital
		DECLARE @AdminUserId int = (SELECT UserId FROM ERS_Users WHERE UserName = 'Admin')
		INSERT INTO ERS_UserOperatingHospitals (UserId, OperatingHospitalId) VALUES (@AdminUserId, @NewOHID)
		
		IF @AdminUserId <> @LoggedInUserId
		BEGIN
			INSERT INTO ERS_UserOperatingHospitals (UserId, OperatingHospitalId) VALUES (@LoggedInUserID, @NewOHID)
		END

		--New (general) room entry
		INSERT INTO ERS_SCH_Rooms (RoomName, AllProcedureTypes, HospitalId, OtherInvestigations, Suppressed, WhoCreatedId, WhenCreated)
		VALUES ('General', 1, @NewOHID, 0, 0, @LoggedInUserId, getdate())

		SET @NewRoomId = SCOPE_IDENTITY()

		--New (none) image port entry
		INSERT INTO ERS_ImagePort (OperatingHospitalId, PortName, MacAddress, [Static], PCName, IsActive, WhoCreatedId, WhenCreated, RoomId, FriendlyName, [Default])
		VALUES (@NewOHID, 'None', NULL, 1, '', 1, @LoggedInUserId, getdate(), @NewRoomId, 'None',1)

		INSERT INTO dbo.ERS_SystemConfig
		(
			HospitalID,
			OperatingHospitalID,
			ApplicationTimeOut,
			SystemDisabled,
			ScheduledShutdown,
			PwdRuleMinLength,
			PwdRuleNoOfSpecialChars,
			PwdRuleNoSpaces,
			PwdRuleCantBeUserId,
			PwdRuleDaysToExpiration,
			PwdRuleNoOfPastPwdsToAvoid,
			SiteIdentification,
			SiteRadius,
			OGDDiagnosis,
			UreaseTestsIncludeTickBoxes,
			OesophagitisClassification,
			BostonBowelPrepScale,
			ReportHeading,
			ReportTrustType,
			ReportSubHeading,
			DepartmentName,
			PatientConsent,
			SortReferringConsultantBy,
			CompleteWHOSurgicalSafetyCheckList,
			ReportLocking,
			LockingTime,
			LockingDays,
			CountryLabel,
			NED_HospitalSiteCode,
			NED_OrganisationCode,
			NED_APIKey,
			NED_BatchId,
			NED_ExportPath,
			NEDEnabled,
			AuditLogEnabled,
			ErrorLogEnabled,
			ImGrabEnabled,
			IncludeUGI,
			DefaultPatientStatus,
			DefaultPatientType,
			DefaultWard,
			BRTPulmonaryPhysiology,
			PhotosURL,
			PhotosUNC,
			MaxWorklistDays,
			WhoCreatedId,
			WhenCreated,
			ReportFooter
		)
		SELECT 
			HospitalID,
			@NewOHID,
			ApplicationTimeOut,
			SystemDisabled,
			ScheduledShutdown,
			PwdRuleMinLength,
			PwdRuleNoOfSpecialChars,
			PwdRuleNoSpaces,
			PwdRuleCantBeUserId,
			PwdRuleDaysToExpiration,
			PwdRuleNoOfPastPwdsToAvoid,
			SiteIdentification,
			SiteRadius,
			OGDDiagnosis,
			UreaseTestsIncludeTickBoxes,
			OesophagitisClassification,
			BostonBowelPrepScale,
			@ReportHeading,
			@ReportTrustType,
			@ReportSubHeading,
			@DepartmentName,
			PatientConsent,
			SortReferringConsultantBy,
			CompleteWHOSurgicalSafetyCheckList,
			ReportLocking,
			LockingTime,
			LockingDays,
			CountryLabel,
			@NEDODSCode,
			NED_OrganisationCode,
			NED_APIKey,
			NED_BatchId,
			(SELECT TOP 1 NED_ExportPath FROM ERS_SystemConfig),
			NEDEnabled,
			AuditLogEnabled,
			ErrorLogEnabled,
			ImGrabEnabled,
			IncludeUGI,
			DefaultPatientStatus,
			DefaultPatientType,
			DefaultWard,
			BRTPulmonaryPhysiology,
			PhotosURL,
			PhotosUNC,
			MaxWorklistDays,
			@LoggedInUserId,
			GETDATE(),
			@ReportFooter
		FROM ERS_SystemConfig
		WHERE ERS_SystemConfig.OperatingHospitalID= @OperatingHospitalId

		IF @CopyPrintSettings = 1 
		BEGIN
			INSERT INTO dbo.ERS_PrintOptionsGPReport
			(
				IncludeDiagram,
				IncludeDiagramOnlyIfSitesExist,
				IncludeListConsultant,
				IncludeNurses,
				IncludeInstrument,
				IncludeMissingCaseNote,
				IncludeIndications,
				IncludeCoMorbidities,
				IncludePlannedProcedures,
				IncludePremedication,
				IncludeProcedureNotes,
				IncludeSiteNotes,
				IncludeBowelPreparation,
				IncludeExtentOfIntubation,
				IncludePreviousGastricUlcer,
				IncludeExtentAndLimitingFactors,
				IncludeCannulation,
				IncludeExtentOfVisualisation,
				IncludeContrastMediaUsed,
				IncludePapillaryAnatomy,
				IncludeDiagnoses,
				IncludeFollowUp,
				IncludeTherapeuticProcedures,
				IncludeSpecimensTaken,
				IncludePeriOperativeComplications,
				DefaultNumberOfCopies,
				DefaultNumberOfPhotos,
				DefaultPhotoSize,
				OperatingHospitalId,
				WhoCreatedId,
				WhenCreated
			)
			SELECT 
				epog.IncludeDiagram, 
				epog.IncludeDiagramOnlyIfSitesExist, 
				epog.IncludeListConsultant, 
				epog.IncludeNurses, 
				epog.IncludeInstrument, 
				epog.IncludeMissingCaseNote, 
				epog.IncludeIndications, 
				epog.IncludeCoMorbidities, 
				epog.IncludePlannedProcedures, 
				epog.IncludePremedication, 
				epog.IncludeProcedureNotes, 
				epog.IncludeSiteNotes, 
				epog.IncludeBowelPreparation, 
				epog.IncludeExtentOfIntubation, 
				epog.IncludePreviousGastricUlcer, 
				epog.IncludeExtentAndLimitingFactors, 
				epog.IncludeCannulation, 
				epog.IncludeExtentOfVisualisation, 
				epog.IncludeContrastMediaUsed, 
				epog.IncludePapillaryAnatomy, 
				epog.IncludeDiagnoses, 
				epog.IncludeFollowUp, 
				epog.IncludeTherapeuticProcedures, 
				epog.IncludeSpecimensTaken, 
				epog.IncludePeriOperativeComplications, 
				epog.DefaultNumberOfCopies, 
				epog.DefaultNumberOfPhotos, 
				isnull(epog.DefaultPhotoSize, 2),
				@NewOHID, 
				@LoggedInUserId, 
				GETDATE()
			FROM dbo.ERS_PrintOptionsGPReport epog
			WHERE epog.OperatingHospitalId =@OperatingHospitalId


			INSERT INTO dbo.ERS_PrintOptionsLabRequestReport
			(
				--RequestReportID - this column value is auto-generated
				OneRequestForEverySpecimen,
				GroupSpecimensByDestination,
				RequestsPerA4Page,
				IncludeDiagram,
				IncludeTimeSpecimenCollected,
				IncludeHeading,
				Heading,
				IncludeIndications,
				IncludeProcedureNotes,
				IncludeAbnormalities,
				IncludeSiteNotes,
				IncludeDiagnoses,
				DefaultNumberOfCopies,
				OperatingHospitalId,
				WhoCreatedId,
				WhenCreated
			)
			SELECT
				OneRequestForEverySpecimen,
				GroupSpecimensByDestination,
				RequestsPerA4Page,
				IncludeDiagram,
				IncludeTimeSpecimenCollected,
				IncludeHeading,
				Heading,
				IncludeIndications,
				IncludeProcedureNotes,
				IncludeAbnormalities,
				IncludeSiteNotes,
				IncludeDiagnoses,
				DefaultNumberOfCopies,
				@NewOHID,
				@LoggedInUserId,
				GETDATE()
			FROM ERS_PrintOptionsLabRequestReport
			WHERE OperatingHospitalId = @OperatingHospitalId


			INSERT INTO dbo.ERS_PrintOptionsPatientFriendlyReport
			(
				IncludeNoFollowup,
				IncludeUreaseText,
				UreaseText,
				IncludePolypectomyText,
				PolypectomyText,
				IncludeOtherBiopsyText,
				OtherBiopsyText,
				IncludeAnyOtherBiopsyText,
				AnyOtherBiopsyText,
				IncludeAdviceComments,
				IncludePreceedAdviceComments,
				PreceedAdviceComments,
				IncludeFinalText,
				FinalText,
				DefaultNumberOfCopies,
				OperatingHospitalId,
				WhoCreatedId,
				WhenCreated
			)
			SELECT
				IncludeNoFollowup,
				IncludeUreaseText,
				UreaseText,
				IncludePolypectomyText,
				PolypectomyText,
				IncludeOtherBiopsyText,
				OtherBiopsyText,
				IncludeAnyOtherBiopsyText,
				AnyOtherBiopsyText,
				IncludeAdviceComments,
				IncludePreceedAdviceComments,
				PreceedAdviceComments,
				IncludeFinalText,
				FinalText,
				DefaultNumberOfCopies,
				@NewOHID,
				@LoggedInUserId,
				GETDATE()
			FROM ERS_PrintOptionsPatientFriendlyReport
			WHERE OperatingHospitalId = @OperatingHospitalId


			INSERT INTO dbo.ERS_PrintOptionsPatientFriendlyReportAdditional
			(
				--Id - this column value is auto-generated
				IncludeAdditionalText,
				AdditionalText,
				OperatingHospitalId,
				WhoCreatedId,
				WhenCreated
			)
			SELECT
				IncludeAdditionalText,
				AdditionalText,
				@NewOHID,
				@LoggedInUserId,
				GETDATE()
			FROM ERS_PrintOptionsPatientFriendlyReportAdditional
			WHERE OperatingHospitalId = @OperatingHospitalId
		END

		IF @CopyPhraseLibrary = 1
		BEGIN
			INSERT INTO dbo.ERS_PhraseLibrary
			(
				--PhraseID - this column value is auto-generated
				UserID,
				PhraseCategory,
				Phrase,
				UsageCount,
				OperatingHospitalId,
				WhoCreatedId,
				WhenCreated
			)
			SELECT
				UserID,
				PhraseCategory,
				Phrase,
				UsageCount,
				OperatingHospitalId,
				WhoCreatedId,
				WhenCreated
			FROM ERS_PhraseLibrary
			WHERE OperatingHospitalId = @OperatingHospitalId
		END

		SELECT CASE WHEN @TrustName IS NULL THEN @NewOHID ELSE @TrustId END
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
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson 21.09.23
-- TFS#	
-- Description of change
-- Missing foriegn keys and indexes
------------------------------------------------------------------------------------------------------------------------
GO



IF (SELECT OBJECT_ID('FK_ERS_Appointments_PreviousDiaryId')) = NULL
BEGIN
	ALTER TABLE dbo.ERS_Appointments
	ADD CONSTRAINT FK_ERS_Appointments_PreviousDiaryId
	FOREIGN KEY (PreviousDiaryId)
	REFERENCES dbo.ERS_SCH_DiaryPages(DiaryId)
END
GO

IF (SELECT OBJECT_ID('FK_ERS_Appointments_StaffCancelledId')) = NULL
BEGIN
	ALTER TABLE dbo.ERS_Appointments
	ADD CONSTRAINT FK_ERS_Appointments_StaffCancelledId
	FOREIGN KEY (StaffCancelledId)
	REFERENCES dbo.ERS_Users(UserID)
END
GO

IF (SELECT OBJECT_ID('FK_ERS_Appointments_StaffAccessedId')) = NULL
BEGIN
	ALTER TABLE dbo.ERS_Appointments
	ADD CONSTRAINT FK_ERS_Appointments_StaffAccessedId
	FOREIGN KEY (StaffAccessedId)
	REFERENCES dbo.ERS_Users(UserID)
END
GO


IF (SELECT OBJECT_ID('FK_ERS_Appointments_EndoscopistId')) = NULL
BEGIN
	ALTER TABLE dbo.ERS_Appointments
	ADD CONSTRAINT FK_ERS_Appointments_EndoscopistId
	FOREIGN KEY (EndoscopistId)
	REFERENCES dbo.ERS_Users(UserID)
END
GO


PRINT N'Creating Index [dbo].[ERS_Appointments].[IX_ERS_Appointments_Endoscopist]...';


GO
IF NOT EXISTS (SELECT 1 FROM sys. indexes WHERE name='IX_ERS_Appointments_Endoscopist' AND object_id = OBJECT_ID('dbo.ERS_Appointments'))
CREATE NONCLUSTERED INDEX [IX_ERS_Appointments_Endoscopist]
    ON [dbo].[ERS_Appointments]([EndoscopistId] ASC);


GO
PRINT N'Creating Index [dbo].[ERS_Appointments].[IX_ERS_Appointments_StaffAccessedId]...';


GO
IF NOT EXISTS (SELECT 1 FROM sys. indexes WHERE name='IX_ERS_Appointments_StaffAccessedId' AND object_id = OBJECT_ID('dbo.ERS_Appointments'))
CREATE NONCLUSTERED INDEX [IX_ERS_Appointments_StaffAccessedId]
    ON [dbo].[ERS_Appointments]([StaffAccessedId] ASC);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_Appointments_StaffAccessedId]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_Appointments_StaffAccessedId')) = NULL
ALTER TABLE [dbo].[ERS_Appointments] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_Appointments_StaffAccessedId] FOREIGN KEY ([StaffAccessedId]) REFERENCES [dbo].[ERS_Users] ([UserID]);


GO


PRINT N'Creating Primary Key [dbo].[PK_ERS_AdverseEvents]...';


GO
IF (SELECT OBJECT_ID('PK_ERS_AdverseEvents')) = NULL
ALTER TABLE [dbo].[ERS_AdverseEvents]
    ADD CONSTRAINT [PK_ERS_AdverseEvents] PRIMARY KEY CLUSTERED ([UniqueId] ASC);


GO
PRINT N'Creating Index [dbo].[ERS_AdverseEventsProcedureTypes].[IX_ERS_AdverseEventsProcedureTypes]...';


GO
IF NOT EXISTS (SELECT 1 FROM sys. indexes WHERE name='IX_ERS_AdverseEventsProcedureTypes' AND object_id = OBJECT_ID('dbo.ERS_AdverseEventsProcedureTypes'))
CREATE NONCLUSTERED INDEX [IX_ERS_AdverseEventsProcedureTypes]
    ON [dbo].[ERS_AdverseEventsProcedureTypes]([ProcedureTypeId] ASC);


GO
PRINT N'Creating Index [dbo].[ERS_Appointments].[IX_ERS_Appointments_Endoscopist]...';


GO
IF NOT EXISTS (SELECT 1 FROM sys. indexes WHERE name='IX_ERS_Appointments_Endoscopist' AND object_id = OBJECT_ID('dbo.ERS_Appointments'))
CREATE NONCLUSTERED INDEX [IX_ERS_Appointments_Endoscopist]
    ON [dbo].[ERS_Appointments]([EndoscopistId] ASC);


GO
PRINT N'Creating Index [dbo].[ERS_Appointments].[IX_ERS_Appointments_StaffAccessedId]...';


GO
IF NOT EXISTS (SELECT 1 FROM sys. indexes WHERE name='IX_ERS_Appointments_StaffAccessedId' AND object_id = OBJECT_ID('dbo.ERS_Appointments'))
CREATE NONCLUSTERED INDEX [IX_ERS_Appointments_StaffAccessedId]
    ON [dbo].[ERS_Appointments]([StaffAccessedId] ASC);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureSubIndications_ERS_SubIndications]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureSubIndications_ERS_SubIndications')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureSubIndications] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureSubIndications_ERS_SubIndications] FOREIGN KEY ([SubIndicationId]) REFERENCES [dbo].[ERS_SubIndications] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureSubIndications_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureSubIndications_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureSubIndications] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureSubIndications_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_AdverseEventsProcedureTypes_ERS_AdverseEvents]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_AdverseEventsProcedureTypes_ERS_AdverseEvents')) = NULL
ALTER TABLE [dbo].[ERS_AdverseEventsProcedureTypes] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_AdverseEventsProcedureTypes_ERS_AdverseEvents] FOREIGN KEY ([AdverseEventsId]) REFERENCES [dbo].[ERS_AdverseEvents] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_AdverseEventsProcedureTypes_ERS_AdverseEventsProcedureTypes]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_AdverseEventsProcedureTypes_ERS_AdverseEventsProcedureTypes')) = NULL
ALTER TABLE [dbo].[ERS_AdverseEventsProcedureTypes] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_AdverseEventsProcedureTypes_ERS_AdverseEventsProcedureTypes] FOREIGN KEY ([UniqueId]) REFERENCES [dbo].[ERS_AdverseEventsProcedureTypes] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_Appointments_StaffAccessedId]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_Appointments_StaffAccessedId')) = NULL
ALTER TABLE [dbo].[ERS_Appointments] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_Appointments_StaffAccessedId] FOREIGN KEY ([StaffAccessedId]) REFERENCES [dbo].[ERS_Users] ([UserID]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_BiopsySitesProcedureTypes_ERS_BiopsySites]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_BiopsySitesProcedureTypes_ERS_BiopsySites')) = NULL
ALTER TABLE [dbo].[ERS_BiopsySitesProcedureTypes] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_BiopsySitesProcedureTypes_ERS_BiopsySites] FOREIGN KEY ([BiopsySiteId]) REFERENCES [dbo].[ERS_BiopsySites] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_BiopsySitesProcedureTypes_ERS_BiopsySitesProcedureTypes]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_BiopsySitesProcedureTypes_ERS_BiopsySitesProcedureTypes')) = NULL
ALTER TABLE [dbo].[ERS_BiopsySitesProcedureTypes] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_BiopsySitesProcedureTypes_ERS_BiopsySitesProcedureTypes] FOREIGN KEY ([BiopsySitesProcedureTypeId]) REFERENCES [dbo].[ERS_BiopsySitesProcedureTypes] ([BiopsySitesProcedureTypeId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureAdverseEvents_ERS_AdverseEvents]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureAdverseEvents_ERS_AdverseEvents')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureAdverseEvents] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureAdverseEvents_ERS_AdverseEvents] FOREIGN KEY ([AdverseEventId]) REFERENCES [dbo].[ERS_AdverseEvents] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureAdverseEvents_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureAdverseEvents_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureAdverseEvents] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureAdverseEvents_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureAISoftware_ERS_AISoftware]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureAISoftware_ERS_AISoftware')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureAISoftware] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureAISoftware_ERS_AISoftware] FOREIGN KEY ([AISoftwareId]) REFERENCES [dbo].[ERS_AISoftware] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureAISoftware_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureAISoftware_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureAISoftware] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureAISoftware_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureBowelPrep_ERS_BowelPrep]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureBowelPrep_ERS_BowelPrep')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureBowelPrep] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureBowelPrep_ERS_BowelPrep] FOREIGN KEY ([BowelPrepId]) REFERENCES [dbo].[ERS_BowelPrep] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureBronchoReferralData_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureBronchoReferralData_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureBronchoReferralData] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureBronchoReferralData_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureChromendosopy_ERS_Chromendoscopies]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureChromendosopy_ERS_Chromendoscopies')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureChromendosopy] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureChromendosopy_ERS_Chromendoscopies] FOREIGN KEY ([ChromendoscopyId]) REFERENCES [dbo].[ERS_Chromendoscopies] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureChromendosopy_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureChromendosopy_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureChromendosopy] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureChromendosopy_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureComorbidity_ERS_Comorbidity]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureComorbidity_ERS_Comorbidity')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureComorbidity] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureComorbidity_ERS_Comorbidity] FOREIGN KEY ([ComorbidityId]) REFERENCES [dbo].[ERS_Comorbidity] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureComorbidity_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureComorbidity_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureComorbidity] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureComorbidity_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureDamagingDrugs_ERS_PotentialDamagingDrugs]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureDamagingDrugs_ERS_PotentialDamagingDrugs')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureDamagingDrugs] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureDamagingDrugs_ERS_PotentialDamagingDrugs] FOREIGN KEY ([DamagingDrugId]) REFERENCES [dbo].[ERS_PotentialDamagingDrugs] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureDamagingDrugs_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureDamagingDrugs_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureDamagingDrugs] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureDamagingDrugs_ERS_Procedures] FOREIGN KEY ([ProcedureDamagingDrugsId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureDICAScores_ERS_Sites]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureDICAScores_ERS_Sites')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureDICAScores] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureDICAScores_ERS_Sites] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[ERS_Sites] ([SiteId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureDiscomfortScore_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureDiscomfortScore_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureDiscomfortScore] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureDiscomfortScore_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureDistalAttachment_ERS_DistalAttachments]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureDistalAttachment_ERS_DistalAttachments')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureDistalAttachment] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureDistalAttachment_ERS_DistalAttachments] FOREIGN KEY ([DistalAttachmentId]) REFERENCES [dbo].[ERS_DistalAttachments] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureDistalAttachment_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureDistalAttachment_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureDistalAttachment] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureDistalAttachment_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureEnteroscopyTechniques_ERS_EnteroscopyTechniques]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureEnteroscopyTechniques_ERS_EnteroscopyTechniques')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureEnteroscopyTechniques] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureEnteroscopyTechniques_ERS_EnteroscopyTechniques] FOREIGN KEY ([TechniqueId]) REFERENCES [dbo].[ERS_EnteroscopyTechniques] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureEnteroscopyTechniques_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureEnteroscopyTechniques_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureEnteroscopyTechniques] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureEnteroscopyTechniques_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureImagingMethod_ERS_ImagingMethods]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureImagingMethod_ERS_ImagingMethods')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureImagingMethod] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureImagingMethod_ERS_ImagingMethods] FOREIGN KEY ([ImagingMethodId]) REFERENCES [dbo].[ERS_ImagingMethods] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureImagingMethod_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureImagingMethod_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureImagingMethod] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureImagingMethod_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureImagingOutcome_ERS_ImagingOutcomes]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureImagingOutcome_ERS_ImagingOutcomes')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureImagingOutcome] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureImagingOutcome_ERS_ImagingOutcomes] FOREIGN KEY ([ImagingOutcomeId]) REFERENCES [dbo].[ERS_ImagingOutcomes] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureImagingOutcome_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureImagingOutcome_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureImagingOutcome] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureImagingOutcome_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureIndications_ERS_Indications]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureIndications_ERS_Indications')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureIndications] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureIndications_ERS_Indications] FOREIGN KEY ([IndicationId]) REFERENCES [dbo].[ERS_Indications] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureIndications_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureIndications_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureIndications] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureIndications_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureInsertionTechnique_ERS_InsertionTechniques]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureInsertionTechnique_ERS_InsertionTechniques')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureInsertionTechnique] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureInsertionTechnique_ERS_InsertionTechniques] FOREIGN KEY ([InsertionTechniqueId]) REFERENCES [dbo].[ERS_InsertionTechniques] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureInsertionTechnique_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureInsertionTechnique_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureInsertionTechnique] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureInsertionTechnique_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureInsufflation_ERS_Insufflation]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureInsufflation_ERS_Insufflation')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureInsufflation] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureInsufflation_ERS_Insufflation] FOREIGN KEY ([InsufflationId]) REFERENCES [dbo].[ERS_Insufflation] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureInsufflation_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureInsufflation_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureInsufflation] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureInsufflation_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);
    

GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureLevelOfComplexity_ERS_LevelOfComplexity]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureLevelOfComplexity_ERS_LevelOfComplexity')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureLevelOfComplexity] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureLevelOfComplexity_ERS_LevelOfComplexity] FOREIGN KEY ([ComplexityId]) REFERENCES [dbo].[ERS_LevelOfComplexity] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureLevelOfComplexity_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureLevelOfComplexity_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureLevelOfComplexity] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureLevelOfComplexity_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureLUTSIPSSSymptoms_ERS_LUTSIPSSSymptoms]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureLUTSIPSSSymptoms_ERS_LUTSIPSSSymptoms')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureLUTSIPSSSymptoms] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureLUTSIPSSSymptoms_ERS_LUTSIPSSSymptoms] FOREIGN KEY ([LUTSIPSSSymptomId]) REFERENCES [dbo].[ERS_LUTSIPSSSymptoms] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureLUTSIPSSSymptoms_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureLUTSIPSSSymptoms_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureLUTSIPSSSymptoms] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureLUTSIPSSSymptoms_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureManagement_ERS_Management]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureManagement_ERS_Management')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureManagement] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureManagement_ERS_Management] FOREIGN KEY ([ManagementId]) REFERENCES [dbo].[ERS_Management] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureManagement_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureManagement_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureManagement] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureManagement_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureMucosalCleaning_ERS_MucosalCleaning]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureMucosalCleaning_ERS_MucosalCleaning')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureMucosalCleaning] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureMucosalCleaning_ERS_MucosalCleaning] FOREIGN KEY ([MucosalCleaningId]) REFERENCES [dbo].[ERS_MucosalCleaning] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureMucosalCleaning_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureMucosalCleaning_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureMucosalCleaning] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureMucosalCleaning_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureMucosalVisualisation_ERS_MucosalVisualisation]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureMucosalVisualisation_ERS_MucosalVisualisation')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureMucosalVisualisation] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureMucosalVisualisation_ERS_MucosalVisualisation] FOREIGN KEY ([MucosalVisualisationId]) REFERENCES [dbo].[ERS_MucosalVisualisation] ([UniqueId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureMucosalVisualisation_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureMucosalVisualisation_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureMucosalVisualisation] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureMucosalVisualisation_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedurePathwayPlanAnswers_ERS_PathwayPlanQuestions]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedurePathwayPlanAnswers_ERS_PathwayPlanQuestions')) = NULL
ALTER TABLE [dbo].[ERS_ProcedurePathwayPlanAnswers] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedurePathwayPlanAnswers_ERS_PathwayPlanQuestions] FOREIGN KEY ([QuestionId]) REFERENCES [dbo].[ERS_PathwayPlanQuestions] ([QuestionId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureSedationScore_ERS_Procedures]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureSedationScore_ERS_Procedures')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureSedationScore] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureSedationScore_ERS_Procedures] FOREIGN KEY ([ProcedureId]) REFERENCES [dbo].[ERS_Procedures] ([ProcedureId]);


GO
PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureSedationScore_ERS_SedationScores]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureSedationScore_ERS_SedationScores')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureSedationScore] WITH NOCHECK
    ADD CONSTRAINT [FK_ERS_ProcedureSedationScore_ERS_SedationScores] FOREIGN KEY ([SedationScoreId]) REFERENCES [dbo].[ERS_SedationScores] ([UniqueId]);


GO

PRINT N'Creating Foreign Key [dbo].[FK_ERS_ProcedureSubIndications_ERS_SubIndications]...';


GO
IF (SELECT OBJECT_ID('FK_ERS_ProcedureSubIndications_ERS_SubIndications')) = NULL
ALTER TABLE [dbo].[ERS_ProcedureSubIndications] WITH NOCHECK
    ADD CONSTRAINT FK_ERS_ProcedureSubIndications_ERS_SubIndications FOREIGN KEY ([SubIndicationId]) REFERENCES [dbo].[ERS_SubIndications] ([UniqueId]);


GO


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson 21.09.23
-- TFS#	
-- Description of change
-- Changes to diary transformation process
------------------------------------------------------------------------------------------------------------------------
GO


PRINT N'Altering Procedure [dbo].[sys_update_list_appointment]...';


GO
ALTER procedure [dbo].[sys_update_list_appointment]
(
	@AppointmentId int,
	@ListSlotId int,
	@DiaryId int
)
as
update ers_appointments 
set ListSlotId = CASE WHEN AppointmentStatusId = dbo.fnSCHAppointmentStatusId('C') THEN NULL ELSE @ListSlotId END,
	DiaryId = @DiaryId,
	PreviousDiaryId = DiaryId
where AppointmentId = @AppointmentId
GO


PRINT N'Altering Procedure [dbo].[sys_transformed_diary_add]...';


GO
ALTER PROCEDURE [dbo].[sys_transformed_diary_add]
(
	@DiaryId INT,
	@Subject VARCHAR(500), 
	@DiaryStart DATETIME, 
	@DiaryEnd DATETIME, 
	@RoomID INT, 
	@UserID INT, 
	@RecurrenceFrequency VARCHAR(500), 
	@RecurrenceCount INT, 
	@RecurrenceParentID int, 
	@ListRulesId int,
	@Description varchar(500),
	@OperatingHospitalId INT,
	@Training bit,
	@ListConsultant int,
	@ListGenderId int,
	@IsGI BIT,
	@ListNotes VARCHAR(max),
	@Add BIT
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	--create copy of list rules
	INSERT INTO dbo.ERS_SCH_ListRules
	(
	    Points,
	    PointMins,
	    Endoscopist,
	    ListName,
	    GIProcedure,
	    Training,
	    StartTime,
	    Suppressed,
	    OperatingHospitalId,
	    NonGIProcedureTypeId,
	    NonGIProcedureMinutesPerPoint,
	    NonGIDiagnosticCallInTime,
	    NonGIDiagnosticProcedurePoints,
	    NonGITherapeuticCallInTime,
	    NonGITherapeuticProcedurePoints,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ListConsultantId,
	    TotalMins,
	    IsTemplate,
	    GenderId
	)
	SELECT 
		Points,
	    PointMins,
	    Endoscopist,
	    ListName,
	    GIProcedure,
	    Training,
	    StartTime,
	    Suppressed,
	    OperatingHospitalId,
	    NonGIProcedureTypeId,
	    NonGIProcedureMinutesPerPoint,
	    NonGIDiagnosticCallInTime,
	    NonGIDiagnosticProcedurePoints,
	    NonGITherapeuticCallInTime,
	    NonGITherapeuticProcedurePoints,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ListConsultantId,
	    TotalMins,
	    IsTemplate,
	    GenderId
	FROM dbo.ERS_SCH_ListRules WHERE ListRulesId = @ListRulesId

	--retrieve list rules id
	DECLARE @NewListRulesId INT = SCOPE_IDENTITY()

	--create copy of list slots
	INSERT INTO dbo.ERS_SCH_ListSlots
	(
	    ListRulesId,
	    SlotId,
	    ProcedureTypeId,
	    StartTime,
	    EndTime,
	    Suppressed,
	    OperatingHospitalId,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ParentListSlotId,
	    SlotMinutes,
	    Active,
	    DeactivatedDateTime,
	    Points,
	    Locked,
	    IsOverBookedSlot
	)
	SELECT 
		@NewListRulesId,
	    SlotId,
	    ProcedureTypeId,
	    StartTime,
	    EndTime,
	    Suppressed,
	    OperatingHospitalId,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ParentListSlotId,
	    SlotMinutes,
	    Active,
	    DeactivatedDateTime,
	    Points,
	    Locked,
	    IsOverBookedSlot
	FROM dbo.ERS_SCH_ListSlots
	WHERE ListRulesId = @ListRulesId AND Active = 1 AND Suppressed = 0

	IF @Add = 1 
	BEGIN
		
		
		INSERT INTO [ERS_SCH_DiaryPages] 
		([Subject], [DiaryStart], [DiaryEnd], [RoomID], [UserID], [ListRulesId], [OperatingHospitalId], [RecurrenceFrequency], [RecurrenceCount], [RecurrenceParentID], [WhenCreated], [Training], [ListConsultantId], ListGenderId, IsGI) 
		SELECT ListName, @DiaryStart, @DiaryEnd, @RoomId, @UserID, @NewListRulesId, @OperatingHospitalId, @RecurrenceFrequency, @RecurrenceCount, @RecurrenceParentID, GETDATE(), Training, @ListConsultant, @ListGenderId, @IsGI  FROM ERS_SCH_ListRules WHERE ListRulesId = @ListRulesId

		UPDATE ERS_SCH_DiaryPages
		SET DiaryStart = dateadd(year,-100, DiaryStart),
			DiaryEnd = DATEADD(year, -100, DiaryEnd)
		WHERE DiaryId = @DiaryId and datediff(year, diarystart, getdate())< 50

		SELECT SCOPE_IDENTITY (), @NewListRulesId
	END
	ELSE
	BEGIN
		UPDATE ERS_SCH_DiaryPages
		SET ListGenderId = @ListGenderId,
			Notes = @ListNotes,
			IsGI = @IsGI,
			ListRulesId = @NewListRulesId,
			Suppressed = 0,
			SuppressedFromDate = NULL
		WHERE DiaryId = @DiaryId

		SELECT @DiaryId, @NewListRulesId
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


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson 22.09.23
-- TFS#	
-- Description of change
-- Returns nothing if no status found
------------------------------------------------------------------------------------------------------------------------
GO


SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROCEDURE [dbo].patient_asa_status_select
(
	@PatientId int,
	@ProcedureId int
)
AS
BEGIN
	DECLARE @returnStatus VARCHAR(100)

SELECT @returnStatus = UniqueId
	FROM ERS_PatientASAStatus pa 
		INNER JOIN ERS_ASAStatus a on a.uniqueid = pa.asastatusid
		INNER JOIN ERS_Procedures p ON p.ProcedureId = pa.ProcedureCreatedId
	WHERE   pa.ProcedureCreatedId = @ProcedureId
	AND     pa.PatientId = @PatientId

If (@returnStatus is null) SELECT TOP 1 @returnStatus = UniqueId 
						   FROM ERS_PatientASAStatus 
						   INNER JOIN ERS_ASAStatus ON UniqueId = ASAStatusId 
						   WHERE PatientId = @PatientId
						   ORDER BY ProcedureCreatedId DESC

IF @returnStatus IS NOT null
	SELECT @returnStatus as ASAStatusId
END
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Chris Gammage 26/09/2023
-- TFS#	3011
-- Description of change; add item to Distial attachement
-- 
------------------------------------------------------------------------------------------------------------------------
GO

INSERT INTO ERS_DistalAttachments (Description, NEDTerm, ListOrderBy, Suppressed)
SELECT 'Balloon', 'Other', 4, 0
WHERE NOT EXISTS (
    SELECT 1
    FROM ERS_DistalAttachments
    WHERE Description = 'Balloon'
    AND NEDTerm = 'Other'
	AND ListOrderBy = 4
);
Go

 ------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson
-- TFS#	
-- Description of change
-- Change report date, casing cast for 'other' options
------------------------------------------------------------------------------------------------------------------------
GO

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
					, I.fitPositiveValue AS '@fitPositiveValue' -- When indication is FIT Positive then specify the FIT value in (micrograms/gram)
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
				SELECT ISNULL(C.NEDTerm, 'other') as '@type', 
				(CASE WHEN C.NEDTerm = 'Other' THEN PC.AdditionalInfo END) 						As '@comment'

				 FROM ERS_Chromendoscopies C 
				 join ERS_ProcedureChromendosopy PC on C.UniqueId = PC.ChromendoscopyId
				 WHERE PC.ProcedureId = @ProcedureId 
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
								FROM ERS_Procedures AS P 
									LEFT JOIN ERS_ProcedureLowerExtent LE ON LE.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_ProcedureDistalAttachment PD ON PD.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_DistalAttachments DA ON DA.UniqueId = PD.DistalAttachmentId
									LEFT JOIN ERS_ProcedureInsertionTechnique PIT ON PIT.ProcedureId = p.ProcedureId
									LEFT JOIN ERS_InsertionTechniques IT ON IT.UniqueId = PIT.InsertionTechniqueId
									LEFT JOIN ERS_ProcedureBowelPrep PB ON PB.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_BowelPrep B ON B.UniqueId = PB.BowelPrepId
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
								FROM ERS_Procedures AS P 
									LEFT JOIN (Select ProcedureId, Max(CONVERT(int,RectalExamPerformed)) as RectalExamPerformed from ERS_ProcedureLowerExtent group by ProcedureId) LE ON LE.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_ProcedureDistalAttachment PD ON PD.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_DistalAttachments DA ON DA.UniqueId = PD.DistalAttachmentId
									LEFT JOIN ERS_ProcedureInsertionTechnique PIT ON PIT.ProcedureId = p.ProcedureId
									LEFT JOIN ERS_InsertionTechniques IT ON IT.UniqueId = PIT.InsertionTechniqueId
									LEFT JOIN ERS_ProcedureBowelPrep PB ON PB.ProcedureId = P.ProcedureId
									LEFT JOIN ERS_BowelPrep B ON B.UniqueId = PB.BowelPrepId
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



------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson 27/09/23
-- TFS#	
-- Description of change
-- Contraint correction
------------------------------------------------------------------------------------------------------------------------
GO
/****** Object:  Index [UK_SCH_PointMappings]    Script Date: 27/09/2023 16:25:05 ******/
ALTER TABLE [dbo].[ERS_SCH_PointMappings] DROP CONSTRAINT [UK_SCH_PointMappings]
GO

/****** Object:  Index [UK_SCH_PointMappings]    Script Date: 27/09/2023 16:25:05 ******/
ALTER TABLE [dbo].[ERS_SCH_PointMappings] ADD  CONSTRAINT [UK_SCH_PointMappings] UNIQUE NONCLUSTERED 
(
	[ProceduretypeId] ASC,
	[Points] ASC,
	[Minutes] ASC,
	[OperatingHospitalId] ASC,
	[Training] ASC,
	[NonGI] ASC
) ON [PRIMARY]
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO


------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Shahriar 19/09/2023
-- TFS#	1685
-- Description of change
-- Adding new description for drop-down menu of Homeostasis

------------------------------------------------------------------------------------------------------------------------
GO

IF COL_LENGTH('[dbo].[ERS_UpperGITherapeutics]', 'Homeostasis') IS NULL
BEGIN
    ALTER TABLE [dbo].[ERS_UpperGITherapeutics]
    ADD [Homeostasis] [bit] NULL
END
GO

IF COL_LENGTH('[dbo].[ERS_UpperGITherapeutics]', 'HomeostasisType') IS NULL
BEGIN
    ALTER TABLE [dbo].[ERS_UpperGITherapeutics]
    ADD [HomeostasisType] [int] NULL
END
GO


IF NOT EXISTS (SELECT 1 FROM dbo.ERS_ListsMain WHERE ListDescription = 'Homeostasis')
BEGIN

	INSERT INTO dbo.ERS_ListsMain (ListDescription, AllowAddNewItem, OrderByDesc, WhoCreatedId ,WhenCreated )
	Values ('Homeostasis', 1, 1, 1, GETDATE())
	
	DECLARE @listMainId INT = SCOPE_IDENTITY()

	INSERT INTO dbo.ERS_Lists (ListDescription, ListItemNo, ListItemText, Suppressed, ReadOnly, ListMainId, WhoCreatedId, WhenCreated)
	Values ('Homeostasis', 0, '(none)', 0, 0, @listMainId, 1, GETDATE()),
	       ('Homeostasis', 1, 'EndoClot', 0, 0, @listMainId, 1, GETDATE()),
           ('Homeostasis', 2, 'Hemospray', 0, 0, @listMainId, 1, GETDATE()),
           ('Homeostasis', 3, 'Purastat', 0, 0, @listMainId, 1, GETDATE())
END

GO

ALTER PROCEDURE [dbo].[therapeutics_ogd_summary_update]
(
	@TherapeuticId AS INT,
	@SiteId INT
)
AS
	SET NOCOUNT ON
	DECLARE   @msg VARCHAR(1000)
			, @msg2 VARCHAR(1000)
			, @Details VARCHAR(1000)
			, @Summary VARCHAR(4000)=''
			, @Area VARCHAR(500)=''
			, @br VARCHAR(6) = '<br />';

	DECLARE 
		@None BIT,
		@YAGLaser BIT,
		@YAGLaserWatts INT,
		@YAGLaserPulses INT,
		@YAGLaserSecs DECIMAL(8,2),
		@YAGLaserKJ DECIMAL(8,2),
		@ArgonBeamDiathermy BIT,
		@ArgonBeamDiathermyWatts INT,
		@ArgonBeamDiathermyPulses INT,
		@ArgonBeamDiathermySecs DECIMAL(8,2),
		@ArgonBeamDiathermyKJ DECIMAL(8,2),
		@BalloonDilation BIT,
		@BandLigation BIT,
		@BandLigationPerformed INT,
		@BandLigationSuccess INT,
		@BotoxInjection BIT,
		@EndoloopPlacement BIT,
		@HeatProbe BIT,
		@BicapElectro BIT,
		@Diathermy BIT,
		@DiathermyWatt INT,	--Mahfuz added on 30 Jul 2021
		@Coil BIT,
		@CoilQty INT,
		@CoilType INT,
		@Valve BIT,
		@ValveQty INT,
		@ValveType INT,
		@Cryotherapy BIT,
		@PhotoDynamicTherapy BIT,
		@ForeignBody BIT,
		@HotBiopsy BIT,
		@Injection BIT,
		@InjectionType INT,
		@InjectionVolume INT,
		@InjectionNumber INT,
		@OesophagealDilatation BIT,
		@DilatedTo INT,
		@DilatationUnits TINYINT,
		@DilatorType TINYINT,
		@DilatorScopePass BIT,
		@OesoDilNilByMouth BIT,
		@OesoDilNilByMouthHrs INT,
		@OesoDilXRay BIT,
		@OesoDilXRayHrs INT,
		@OesoDilSoftDiet BIT,
		@OesoDilSoftDietDays INT,
		@OesoDilWarmFluids BIT,
		@OesoDilWarmFluidsHrs INT,
		@OesoDilMedicalReview BIT,
		@OesoYAGNilByMouth BIT,
		@OesoYAGNilByMouthHrs INT,
		@OesoYAGWarmFluids BIT,
		@OesoYAGWarmFluidsHrs INT,
		@OesoYAGSoftDiet BIT,
		@OesoYAGSoftDietDays INT,
		@OesoYAGMedicalReview BIT,
		@Polypectomy BIT,
		@PolypectomyRemoval TINYINT,
		@PolypectomyRemovalType TINYINT,
		@BandingPiles BIT,
		@BandingNum INT,
		@GastrostomyInsertion BIT,
		@GastrostomyInsertionSize NUMERIC(9,2),
		@GastrostomyInsertionUnits TINYINT,
		@GastrostomyInsertionType TINYINT,
		@GastrostomyInsertionBatchNo VARCHAR(100),
		@CorrectPEGPlacement TINYINT,
		@PEGPlacementFailureReason VARCHAR(500),
		@NGNJInsertion BIT,
		@NGNJTubeNostril TINYINT,
		@NGNJTubeLength NUMERIC(9,2),
		@NGNJTubeBridle BIT,
		@NGNJTubeBatch VARCHAR(20),
		@NilByMouth BIT,
		@NilByMouthHrs INT,
		@NilByProc BIT,
		@NilByProcHrs INT,
		@FlangePosition NUMERIC(9,2),
		@AttachmentToWard BIT,
		@GastrostomyRemoval BIT,
		@PyloricDilatation BIT,
		@VaricealSclerotherapy BIT,
		@VaricealSclerotherapyInjectionType SMALLINT,
		@VaricealSclerotherapyInjectionVol INT,
		@VaricealSclerotherapyInjectionNum INT,
		@VaricealBanding BIT,
		@VaricealBandingNum INT,
		@VaricealClip BIT,
		@StentInsertion BIT,
		@StentInsertionQty INT,
		@StentInsertionType SMALLINT,
		@StentInsertionLength INT,
		@StentInsertionDiameter INT,
		@StentInsertionDiameterUnits TINYINT,
		@StentInsertionBatchNo VARCHAR(100),
		@CorrectStentPlacement TINYINT,
		@StentPlacementFailureReason VARCHAR(500),
		@StentRemoval BIT,
		@StentRemovalTechnique INT,
		@EMR BIT,
		@EMRType TINYINT,
		@EMRFluid INT,
		@EMRFluidVolume INT,
		@RFA BIT,
		@RFAType TINYINT,
		@RFATreatmentFrom INT,
		@RFATreatmentTo INT,
		@RFAEnergyDel INT,
		@RFANumSegTreated INT,
		@RFANumTimesSegTreated INT,
		@pHProbeInsert BIT,
		@pHProbeInsertAt INT,
		@pHProbeInsertChk BIT,
		@pHProbeInsertChkTopTo INT,
		@Haemospray BIT,
		@Sigmoidopexy BIT,
		@SigmoidopexyQty SMALLINT,
		@SigmoidopexyMake SMALLINT,
		@SigmoidopexyFluidsDays SMALLINT,
		@SigmoidopexyAntibioticsDays SMALLINT,
		@Marking BIT,
		@MarkedQuantity SMALLINT,
		@TattooLocationDistal BIT,
		@TattooLocationProximal BIT,
		@MarkingType INT,
		@Clip BIT,
		@ClipNum INT,
		@Other VARCHAR(1000),
		@EUSProcType SMALLINT,
		@EndoClot BIT,
		@ColonicDecompression BIT,
		@FlatusTubeInsertion BIT,
		@PancolonicDyeSpray BIT,
		@BougieDilation BIT,
		@EndoscopicResection BIT,
		@FineNeedleAspiration BIT,
		@FineNeedleAspirationType TINYINT,
		@FineNeedleBiopsy BIT,
		@Homeostasis BIT,
		@HomeostasisType INT;

	IF OBJECT_ID('tempdb..#tmp_UpperGITherapeutics') IS NOT NULL
        DROP TABLE #tmp_UpperGITherapeutics;

	SELECT * INTO #tmp_UpperGITherapeutics 
	FROM dbo.[ERS_UpperGITherapeutics] 
	WHERE (Id = @TherapeuticId OR SiteID = @SiteId)

--## 1) If 'CarriedOutRole=2 (EE)' record is found for a SiteId in [ERS_UpperGITherapeutics] means it has both EE/ER Entries...
	--IF EXISTS(SELECT 'ER' FROM dbo.[ERS_UpperGITherapeutics] WHERE SiteId=@SiteId AND CarriedOutRole=2)
	--	BEGIN
			--PRINT '[ERS_UpperGITherapeutics] has both EE/ER Entries...';
			;WITH eeRecord AS (
				SELECT * FROM #tmp_UpperGITherapeutics WHERE CarriedOutRole = (SELECT MAX(CarriedOutRole) FROM #tmp_UpperGITherapeutics) --## 2 is EE
				--WHERE SiteId=@SiteId AND CarriedOutRole=2
			)
			SELECT
				@None							= (CASE WHEN ISNULL(ER.[None], 0) = 0 THEN EE.[None] ELSE ER.[None] END),
				@YAGLaser						= (CASE WHEN ISNULL(ER.[YAGLaser], 0) = 0 THEN EE.[YAGLaser] ELSE ER.[YAGLaser] END),
				@YAGLaserWatts					= (CASE WHEN ISNULL(ER.[YAGLaserWatts], 0) = 0 THEN EE.[YAGLaserWatts] ELSE ER.[YAGLaserWatts] END),
				@YAGLaserPulses					= (CASE WHEN ISNULL(ER.[YAGLaserPulses], 0) = 0 THEN EE.[YAGLaserPulses] ELSE ER.[YAGLaserPulses] END),
				@YAGLaserSecs					= (CASE WHEN ISNULL(ER.[YAGLaserSecs], 0) = 0 THEN EE.[YAGLaserSecs] ELSE ER.[YAGLaserSecs] END),
				@YAGLaserKJ						= (CASE WHEN ISNULL(ER.[YAGLaserKJ], 0) = 0 THEN EE.[YAGLaserKJ] ELSE ER.[YAGLaserKJ] END),
				@ArgonBeamDiathermy				= (CASE WHEN ISNULL(ER.[ArgonBeamDiathermy], 0) = 0 THEN EE.[ArgonBeamDiathermy] ELSE ER.[ArgonBeamDiathermy] END),
				@ArgonBeamDiathermyWatts		= (CASE WHEN ISNULL(ER.[ArgonBeamDiathermyWatts], 0) = 0 THEN EE.[ArgonBeamDiathermyWatts] ELSE ER.[ArgonBeamDiathermyWatts] END),
				@ArgonBeamDiathermyPulses		= (CASE WHEN ISNULL(ER.[ArgonBeamDiathermyPulses], 0) = 0 THEN EE.[ArgonBeamDiathermyPulses] ELSE ER.[ArgonBeamDiathermyPulses] END),
				@ArgonBeamDiathermySecs			= (CASE WHEN ISNULL(ER.[ArgonBeamDiathermySecs], 0) = 0 THEN EE.[ArgonBeamDiathermySecs] ELSE ER.[ArgonBeamDiathermySecs] END),
				@ArgonBeamDiathermyKJ			= (CASE WHEN ISNULL(ER.[ArgonBeamDiathermyKJ], 0) = 0 THEN EE.[ArgonBeamDiathermyKJ] ELSE ER.[ArgonBeamDiathermyKJ] END),
				@BalloonDilation				= (CASE WHEN ISNULL(ER.[BalloonDilation], 0) = 0 THEN EE.[BalloonDilation] ELSE ER.[BalloonDilation] END),
				@BandLigation					= (CASE WHEN ISNULL(ER.[BandLigation], 0) = 0 THEN EE.[BandLigation] ELSE ER.[BandLigation] END),
				@BandLigationPerformed			= (CASE WHEN ISNULL(ER.[BandLigationPerformed], 0) = 0 THEN EE.[BandLigationPerformed] ELSE ER.[BandLigationPerformed] END),
				@BandLigationSuccess			= (CASE WHEN ISNULL(ER.[BandLigationSuccessful], 0) = 0 THEN EE.[BandLigationSuccessful] ELSE ER.[BandLigationSuccessful] END),
				@BotoxInjection					= (CASE WHEN ISNULL(ER.[BotoxInjection], 0) = 0 THEN EE.[BotoxInjection] ELSE ER.[BotoxInjection] END),
				@EndoloopPlacement				= (CASE WHEN ISNULL(ER.[EndoloopPlacement], 0) = 0 THEN EE.[EndoloopPlacement] ELSE ER.[EndoloopPlacement] END),
				@HeatProbe						= (CASE WHEN ISNULL(ER.[HeatProbe], 0) = 0 THEN EE.[HeatProbe] ELSE ER.[HeatProbe] END),
				@BicapElectro					= (CASE WHEN ISNULL(ER.[BicapElectro], 0) = 0 THEN EE.[BicapElectro] ELSE ER.[BicapElectro] END),
				@Diathermy						= (CASE WHEN ISNULL(ER.[Diathermy], 0) = 0 THEN EE.[Diathermy] ELSE ER.[Diathermy] END),
				@DiathermyWatt					= (CASE WHEN ISNULL(ER.[DiathermyWatt], 0) = 0 THEN EE.[DiathermyWatt] ELSE ER.[DiathermyWatt] END),  
				@Coil							= (CASE WHEN ISNULL(ER.[Coil], 0) = 0 THEN EE.[Coil] ELSE ER.[Coil] END),
				@CoilQty						= (CASE WHEN ISNULL(ER.[CoilQty], 0) = 0 THEN EE.[CoilQty] ELSE ER.[CoilQty] END),
				@CoilType						= (CASE WHEN ISNULL(ER.[CoilType], 0) = 0 THEN EE.[CoilType] ELSE ER.[CoilType] END),
				@Valve							= (CASE WHEN ISNULL(ER.[Valve], 0) = 0 THEN EE.[Valve] ELSE ER.[Valve] END),
				@ValveQty						= (CASE WHEN ISNULL(ER.[ValveQty], 0) = 0 THEN EE.[ValveQty] ELSE ER.[ValveQty] END),
				@ValveType						= (CASE WHEN ISNULL(ER.[ValveType], 0) = 0 THEN EE.[ValveType] ELSE ER.[ValveType] END),
				@Cryotherapy					= (CASE WHEN ISNULL(ER.[Cryotherapy], 0) = 0 THEN EE.[Cryotherapy] ELSE ER.[Cryotherapy] END),
				@PhotoDynamicTherapy			= (CASE WHEN ISNULL(ER.[PhotoDynamicTherapy], 0) = 0 THEN EE.[PhotoDynamicTherapy] ELSE ER.[PhotoDynamicTherapy] END),
				@ForeignBody					= (CASE WHEN ISNULL(ER.[ForeignBody], 0) = 0 THEN EE.[ForeignBody] ELSE ER.[ForeignBody] END),
				@HotBiopsy						= (CASE WHEN ISNULL(ER.[HotBiopsy], 0) = 0 THEN EE.[HotBiopsy] ELSE ER.[HotBiopsy] END),
				@Injection						= (CASE WHEN ISNULL(ER.[Injection], 0) = 0 THEN EE.[Injection] ELSE ER.[Injection] END),
				@InjectionType					= (CASE WHEN ISNULL(ER.[InjectionType], 0) = 0 THEN EE.[InjectionType] ELSE ER.[InjectionType] END),
				@InjectionVolume				= (CASE WHEN ISNULL(ER.[InjectionVolume], 0) = 0 THEN EE.[InjectionVolume] ELSE ER.[InjectionVolume] END),
				@InjectionNumber				= (CASE WHEN ISNULL(ER.[InjectionNumber], 0) = 0 THEN EE.[InjectionNumber] ELSE ER.[InjectionNumber] END),
				@OesophagealDilatation			= (CASE WHEN ISNULL(ER.[OesophagealDilatation], 0) = 0 THEN EE.[OesophagealDilatation] ELSE ER.[OesophagealDilatation] END),
				@DilatedTo						= (CASE WHEN ISNULL(ER.[DilatedTo], 0) = 0 THEN EE.[DilatedTo] ELSE ER.[DilatedTo] END),
				@DilatationUnits				= (CASE WHEN ISNULL(ER.[DilatationUnits], 0) = 0 THEN EE.[DilatationUnits] ELSE ER.[DilatationUnits] END),
				@DilatorType					= (CASE WHEN ISNULL(ER.[DilatorType], 0) = 0 THEN EE.[DilatorType] ELSE ER.[DilatorType] END),
				@DilatorScopePass				= (CASE WHEN ISNULL(ER.[DilatorScopePass], 0) = 0 THEN EE.[DilatorScopePass] ELSE ER.[DilatorScopePass] END),
				@OesoDilNilByMouth				= (CASE WHEN ISNULL(ER.[OesoDilNilByMouth], 0) = 0 THEN EE.[OesoDilNilByMouth] ELSE ER.[OesoDilNilByMouth] END),
				@OesoDilNilByMouthHrs			= (CASE WHEN ISNULL(ER.[OesoDilNilByMouthHrs], 0) = 0 THEN EE.[OesoDilNilByMouthHrs] ELSE ER.[OesoDilNilByMouthHrs] END),
				@OesoDilXRay					= (CASE WHEN ISNULL(ER.[OesoDilXRay], 0) = 0 THEN EE.[OesoDilXRay] ELSE ER.[OesoDilXRay] END),
				@OesoDilXRayHrs					= (CASE WHEN ISNULL(ER.[OesoDilXRayHrs], 0) = 0 THEN EE.[OesoDilXRayHrs] ELSE ER.[OesoDilXRayHrs] END),
				@OesoDilSoftDiet				= (CASE WHEN ISNULL(ER.[OesoDilSoftDiet], 0) = 0 THEN EE.[OesoDilSoftDiet] ELSE ER.[OesoDilSoftDiet] END),
				@OesoDilSoftDietDays			= (CASE WHEN ISNULL(ER.[OesoDilSoftDietDays], 0) = 0 THEN EE.[OesoDilSoftDietDays] ELSE ER.[OesoDilSoftDietDays] END),
				@OesoDilWarmFluids				= (CASE WHEN ISNULL(ER.[OesoDilWarmFluids], 0) = 0 THEN EE.[OesoDilWarmFluids] ELSE ER.[OesoDilWarmFluids] END),
				@OesoDilWarmFluidsHrs			= (CASE WHEN ISNULL(ER.[OesoDilWarmFluidsHrs], 0) = 0 THEN EE.[OesoDilWarmFluidsHrs] ELSE ER.[OesoDilWarmFluidsHrs] END),
				@OesoDilMedicalReview			= (CASE WHEN ISNULL(ER.[OesoDilMedicalReview], 0) = 0 THEN EE.[OesoDilMedicalReview] ELSE ER.[OesoDilMedicalReview] END),
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
				@NGNJInsertion 					= (CASE WHEN IsNull(ER.NGNJTubeInsertion, 0) = 0 THEN EE.NGNJTubeInsertion ELSE ER.NGNJTubeInsertion END),
				@NGNJTubeNostril				= (CASE WHEN IsNull(ER.NGNJTubeNostril, 0) = 0 THEN EE.NGNJTubeNostril ELSE ER.NGNJTubeNostril END),
				@NGNJTubeLength					= (CASE WHEN IsNull(ER.NGNJTubeLength, 0) = 0 THEN EE.NGNJTubeLength ELSE ER.NGNJTubeLength END),
				@NGNJTubeBridle					= (CASE WHEN IsNull(ER.NGNJTubeBridle, 0) = 0 THEN EE.NGNJTubeBridle ELSE ER.NGNJTubeBridle END),
				@NGNJTubeBatch					= (CASE WHEN IsNull(ER.NGNJTubeBatch, '') = '' THEN EE.NGNJTubeBatch ELSE ER.NGNJTubeBatch END),
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
				--MH added on 19 Oct 2021
				--MH added on 19 Oct 2021 - later changed on 26 Nov 2021
				@TattooLocationDistal      = (CASE WHEN IsNull(ER.[TattooLocationDistal], 0) = 0 THEN EE.[TattooLocationDistal] ELSE ER.[TattooLocationDistal] END), 
				@TattooLocationProximal      = (CASE WHEN IsNull(ER.[TattooLocationProximal], 0) = 0 THEN EE.[TattooLocationProximal] ELSE ER.[TattooLocationProximal] END), 

				--MH added on 20 Oct 2021
				@MarkedQuantity    = (CASE WHEN IsNull(ER.[MarkedQuantity], 0) = 0 THEN EE.[MarkedQuantity] ELSE ER.[MarkedQuantity] END), 

				@MarkingType					= (CASE WHEN IsNull(ER.[MarkingType], 0) = 0 THEN EE.[MarkingType] ELSE ER.[MarkingType] END),
				@Clip							= (CASE WHEN IsNull(ER.[Clip], 0) = 0 THEN EE.[Clip] ELSE ER.[Clip] END),
				@ClipNum						= (CASE WHEN IsNull(ER.[ClipNum], 0) = 0 THEN EE.[ClipNum] ELSE ER.[ClipNum] END),
				@Other							= (SELECT isnull((CASE WHEN IsNull(ER.[Other], '') = '' THEN EE.[Other] ELSE ER.[Other] END), '') as [text()] FOR XML PATH('')),
				@EUSProcType					= (CASE WHEN IsNull(ER.[EUSProcType], 0) = 0 THEN EE.[EUSProcType] ELSE ER.[EUSProcType] END),
				@EndoClot						= (CASE WHEN IsNull(ER.[EndoClot], 0) = 0 THEN EE.[EndoClot] ELSE ER.[EndoClot] END),
				@ColonicDecompression			= (CASE WHEN IsNull(ER.[ColonicDecompression], 0) = 0 THEN EE.[ColonicDecompression] ELSE ER.[ColonicDecompression] END),
				@FlatusTubeInsertion			= (CASE WHEN IsNull(ER.[FlatusTubeInsertion], 0) = 0 THEN EE.[FlatusTubeInsertion] ELSE ER.[FlatusTubeInsertion] END),
				@PancolonicDyeSpray				= (CASE WHEN IsNull(ER.[PancolonicDyeSpray], 0) = 0 THEN EE.[PancolonicDyeSpray] ELSE ER.[PancolonicDyeSpray] END),
				@BougieDilation					= (CASE WHEN IsNull(ER.[BougieDilation], 0) = 0 THEN EE.[BougieDilation] ELSE ER.[BougieDilation] END),
				@EndoscopicResection			= (CASE WHEN IsNull(ER.[EndoscopicResection], 0) = 0 THEN EE.[EndoscopicResection] ELSE ER.[EndoscopicResection] END),
				@FineNeedleAspiration		    = (CASE WHEN IsNull(ER.FineNeedleAspiration, 0) = 0 THEN EE.FineNeedleAspiration ELSE ER.FineNeedleAspiration END),
				@FineNeedleAspirationType	    = (CASE WHEN IsNull(ER.FineNeedleAspirationType, 0) = 0 THEN EE.FineNeedleAspirationType ELSE ER.FineNeedleAspirationType END),
				@FineNeedleBiopsy			    = (CASE WHEN IsNull(ER.FineNeedleBiopsy, 0) = 0 THEN EE.FineNeedleBiopsy ELSE ER.FineNeedleBiopsy END),
				@Homeostasis					= (CASE WHEN ISNULL(ER.[Homeostasis], 0) = 0 THEN EE.[Homeostasis] ELSE ER.[Homeostasis] END),
				@HomeostasisType				= (CASE WHEN ISNULL(ER.[HomeostasisType], 0) = 0 THEN EE.[HomeostasisType] ELSE ER.[HomeostasisType] END)
			FROM eeRecord AS EE
	  INNER JOIN #tmp_UpperGITherapeutics AS ER ON EE.SiteId = ER.SiteId
	 
	SELECT @Area = m.Area FROM dbo.ERS_AbnormalitiesMatrixUpperGI m LEFT JOIN dbo.ERS_Regions r ON m.Region = r.Region LEFT JOIN dbo.ERS_Sites s ON r.RegionId  = s.RegionID  WHERE s.siteId = @SiteId;
	
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
			IF @InjectionType > 0 SET @Details = @Details + ' ' +   (SELECT [ListItemText] FROM dbo.ERS_Lists WHERE ListDescription = 'Agent Upper GI' AND [ListItemNo] = @InjectionType)
			IF @InjectionVolume> 0  AND @InjectionNumber > 0 SET @Details = @Details + ' via'
			IF @InjectionNumber >0 SET @Details = @Details + ' ' + CASE WHEN @InjectionNumber > 1 THEN cast(@InjectionNumber as varchar(50)) + ' injections' ELSE cast(@InjectionNumber as varchar(50)) + ' injection' END
			If @Details<>'' SET @msg = @msg + ': ' + @Details
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END
		
	    IF @Homeostasis = 1
			BEGIN
			SET @msg =' Homeostasis'
			SET @Details = ''
			IF @HomeostasisType > 0 SET @Details = @Details + ' ' +   (SELECT [ListItemText] FROM dbo.ERS_Lists WHERE ListDescription = 'Homeostasis' AND [ListItemNo] = @HomeostasisType)
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
			exec specimens_ogd_summary_update @SiteId
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
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg 
		--------------  
		if @DiathermyWatt <> 0 Set @msg =   ' ' + @msg + ' ' + cast(@DiathermyWatt as varchar(10)) + ' Watt.'

		SET @summary = @summary + @msg + @br  
		END  
  
	-- ## Valve
	  IF @Valve = 1  
	  BEGIN  
	   SET @msg = 'Valve'  
	   if @ValveQty <> 0 Set @msg2 = ' ' + cast(@ValveQty as varchar(10))
	   if @ValveType <> 0 Set @msg2 = @msg2 + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'BRT Valve Type' AND [ListItemNo] = @ValveType)  
	   Set @msg2 = ltrim(rtrim(@msg2))
	   if @msg2 <> '' Set @msg = @msg2 + ' Valve.' else Set @msg = 'Valve.'

	   SET @summary = @summary + @msg +  @br  
	  END

	  --- ### Cryotherapy and PhotoDynamicTherapy
	  Set @msg = ''
	  set @msg2 = ''
	  if @Cryotherapy = 1 Set @msg2 = 'Cryotherapy'
	  if @PhotoDynamicTherapy = 1 
	  Begin
		if @msg2 <> '' Set @msg = @msg2 + ' and Photodynamic Therapy have been used.' else set @msg = 'Photodynamic Therapy has been used.'
	  end
	  else
	  begin
		if @msg2 <> '' Set @msg = @msg2 + ' has been used.'
	  end
	  if @msg <> '' Set @summary = @summary + @msg + @br

		-- ## Coil
		IF @Coil = 1  
		BEGIN  
		SET @msg = 'Coil'  
		if @CoilQty <> 0 Set @msg2 = ' ' + cast(@CoilQty as varchar(10))
		if @CoilType <> 0 Set @msg2 = @msg2 + ' ' + (SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'BRT Coil Type' AND [ListItemNo] = @CoilType)  
		Set @msg2 = ltrim(rtrim(@msg2))
		if @msg2 <> '' Set @msg = @msg2 + ' Coil.' else Set @msg = 'Coil.'

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
			IF @BandLigationPerformed > 0 SET @msg = @msg + ' performed ' + CAST(@BandLigationPerformed AS VARCHAR(100)) + CASE WHEN @BandLigationPerformed = 1 THEN ' procedure' ELSE ' procedures' END
			IF @BandLigationPerformed > 0 AND @BandLigationSuccess > 0 SET @msg = @msg + ' and ' + CAST(@BandLigationSuccess AS VARCHAR(100)) + CASE WHEN @BandLigationPerformed = 1 THEN ' was successful.' ELSE ' were successful.' END 
				ELSE IF @BandLigationPerformed = 0 AND @BandLigationSuccess > 0 SET @msg = @msg + ' ' + CAST(@BandLigationSuccess AS VARCHAR(100)) + CASE WHEN @BandLigationPerformed = 1 THEN ' procedure was successful.' ELSE ' procedures were successful.' END 
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

		IF @EndoscopicResection = 1
		BEGIN
			SET @msg = ' Endoscopic resection'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		-------------------------------
        -- FNA
        -------------------------------
		IF @FineNeedleAspiration= 1
		BEGIN
			SET @msg =' FNA'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		-------------------------------
        -- FNB
        -------------------------------
		IF @FineNeedleBiopsy= 1
		BEGIN
			SET @msg =' FNB'
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
			IF @EMRType = 3
				SET @msg =' Endoscopic full thickness resection'
			ELSE IF @EMRType = 2
				SET @msg =' Endoscopic submucosal dissection'
			ELSE IF @EMRType = 1
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
				IF ISNULL(@GastrostomyInsertionBatchNo, '') <> ''  SET @Details = @Details + ' batch ' + @GastrostomyInsertionBatchNo
				
				IF @CorrectPEGPlacement = 2 SET @Details = @Details + ' incorrectly placed ' + isnull(@PEGPlacementFailureReason, '')
				    
				
				IF @Details<>'' SET @msg = @msg + ': ' + @Details
				--Add full stop 
				SET @msg = RTrim(LTRIM(@msg))
				IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
				--------------
				SET @summary = @summary + @msg + @br
				END

		IF @GastrostomyRemoval = 1
		BEGIN
			SET @msg =' Gastrostomy PEG Removal'
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

		IF @NGNJInsertion = 1 
		BEGIN
			Set @msg = ' NG/NJ tube insertion'
			IF isnull(@NGNJTubeBatch, '') <> '' 
				SET @msg = @msg + ' (batch ' + @NGNJTubeBatch + ')'
			IF isnull(@NGNJTubeLength, 0) > 0
			BEGIN
				SET @msg = @msg + '. Tube length ' + convert(varchar, @NGNJTubeLength) + 'cm'
				IF isnull(@NGNJTubeNostril, 0) > 0
				BEGIN
					SELECT @msg = @msg + CASE WHEN @NGNJTubeNostril = 1 THEN ' at the right nostril'
											  WHEN @NGNJTubeNostril = 2 THEN ' at the left nostril'
										 END
				END
			END
			ELSE
			BEGIN
				IF isnull(@NGNJTubeNostril, 0) > 0
				BEGIN
					SELECT @msg = @msg + CASE WHEN @NGNJTubeNostril = 1 THEN ' via the right nostril'
											  WHEN @NGNJTubeNostril = 2 THEN ' via the left nostril'
										 END
				END
			END
			IF isnull(@NGNJTubeBridle, 0) = 1 
				SET @msg = @msg + ', bridle used'

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
			--MH added on 19 Oct 2021
			Declare @TattoLocationMessage varchar(50)
			Declare @TattoMessage varchar(100)
			declare @MaxId int, @MinId int, @loopCounter int

			Set @TattoLocationMessage = ''
			Set @TattoMessage = ''
			If @TattooLocationDistal > 0 
			Begin
				Set @TattoLocationMessage = 'Distal'
			End

			If @TattooLocationProximal > 0 
			Begin
				if @TattoLocationMessage = ''			
					begin
						Set @TattoLocationMessage = 'Proximal'
					end
				else
					begin
						Set @TattoLocationMessage = @TattoLocationMessage + ',Proximal'
					end		
			End

			Select @MinId = Min(id),@MaxId=Max(id) from fnSplitString(@TattoLocationMessage,',') 
			Set @loopCounter = @MinId
			While @loopCounter < (@MaxId+1)
			begin
				if @loopCounter = 1
				begin
					Set @TattoMessage = (Select Item from fnSplitString(@TattoLocationMessage,',') Where Id = @loopCounter)
				end
				else
				begin
					if @loopCounter <> @MaxId 
					begin
						Set @TattoMessage = @TattoMessage + ', ' + (Select Item from fnSplitString(@TattoLocationMessage,',') Where Id = @loopCounter)
					end
					else
					begin
						Set @TattoMessage = @TattoMessage + ' and ' + (Select Item from fnSplitString(@TattoLocationMessage,',') Where Id = @loopCounter)
					end

				end

				set @loopCounter = @loopCounter + 1
			END

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

		  If @MarkedQuantity > 0
		begin
			IF @summary <> '' SET @summary = @summary
			SET @summary = @summary + 'Total volume used ' + Convert(varchar(5),@MarkedQuantity) + ' ml.' + @br
		end
		
	  --MH added on 19 Oct 2021
	  If @TattoMessage <> ''
	  BEGIN		
		SET @summary = @summary + 'Tattoo located at ' + ISNULL(@TattoMessage, '') + @br		
	  End	  
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
		
		IF @ColonicDecompression = 1
		BEGIN 
			SET @msg = 'Colonic decompression'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END
		
		IF @FlatusTubeInsertion = 1
		BEGIN 
			SET @msg = 'Flatus tube insertion'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END
		
		IF @PancolonicDyeSpray = 1
		BEGIN 
			SET @msg = 'Pancolonic dye spray'
			--Add full stop 
			SET @msg = RTrim(LTRIM(@msg))
			IF @msg <> ''  AND (@msg NOT LIKE '%.')  SET @msg = @msg + '.'
			--------------
			SET @summary = @summary + @msg + @br
		END

		IF @BougieDilation = 1
		BEGIN 
			SET @msg = 'Bougie dilation'
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

	--END
	
	-- Finally, update the summary in Therapeutics  table
	UPDATE dbo.ERS_UpperGITherapeutics 
	SET Summary=@summary 
	WHERE SiteId = @SiteId -- AND CarriedOutRole=1;	--### Summary text is Applicable only for TrainER....
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
				IF @Summary <> '' SET @Summary = @Summary + ', warm fluids only' ELSE SET @Summary = 'Warm fluids only'
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
				IF @Summary <> '' SET @Summary = @Summary + ', warm fluids only' ELSE SET @Summary = 'Warm fluids only'
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
					SET @Summary = @Summary + ' after ' + CONVERT(varchar, @OesoDilXRayHrs)
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

	IF @Summary = '' SET @SummaryHeading = ''

	-- Finally, update the summary in PP_InstForCare  table
	UPDATE p
	SET PP_InstForCare = @Summary
		, PP_InstForCareHeading = @SummaryHeading
		, PP_InstForCareWithLinks = REPLACE(REPLACE(@htmlAnchorCode, '{0}', @insertionType), '{1}', @Summary)
	FROM ERS_ProceduresReporting p
	INNER JOIN ERS_Sites s ON p.ProcedureId = s.ProcedureId
	WHERE s.SiteId = @SiteId;

	DROP TABLE #tmp_UpperGITherapeutics;
 END

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO
Go
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Mahfuz	On 24 Aug 2023
-- TFS#	2279
-- Description of change
-- Move PDFs out of the database into file storage (Blob Storage if Azure)
------------------------------------------------------------------------------------------------------------------------
Go

--Check if column exists in a table
Print 'Adding Column FileLocation to table ERS_DocumentStore'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'FileLocation' AND Object_ID = Object_ID(N'ERS_DocumentStore'))
begin
ALTER TABLE [dbo].[ERS_DocumentStore]
   ADD [FileLocation] varchar(2000) NULL;
end
GO

--Check if column exists in a table
Print 'Adding Column FileLocationDirectory to table ERS_DocumentStore'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'FileLocationDirectory' AND Object_ID = Object_ID(N'ERS_DocumentStore'))
begin
ALTER TABLE [dbo].[ERS_DocumentStore]
   ADD [FileLocationDirectory] varchar(2000) NULL;
end
GO

--Check if column exists in a table
Print 'Adding Column DocumentFileName to table ERS_DocumentStore'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'DocumentFileName' AND Object_ID = Object_ID(N'ERS_DocumentStore'))
begin
ALTER TABLE [dbo].[ERS_DocumentStore]
   ADD [DocumentFileName] varchar(500) NULL;
end
GO

--Check if column exists in a table
Print 'Adding Column Base64FileContent to table ERS_DocumentStore'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Base64FileContent' AND Object_ID = Object_ID(N'ERS_DocumentStore'))
begin
ALTER TABLE [dbo].[ERS_DocumentStore]
   ADD [Base64FileContent] varchar(max) NULL;
end
GO

--Check if column exists in a table
Print 'Adding LatestReportFileLocation to table ERS_Procedures'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'LatestReportFileLocation' AND Object_ID = Object_ID(N'ERS_Procedures'))
begin
ALTER TABLE [dbo].[ERS_Procedures]
   ADD [LatestReportFileLocation] varchar(500) NULL;
end
GO

--Check if column exists in a table
Print 'Adding OriginalPDFDocumentStoreId to table ERS_DocumentStore'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'OriginalPDFDocumentStoreId' AND Object_ID = Object_ID(N'ERS_DocumentStore'))
begin
ALTER TABLE [dbo].[ERS_DocumentStore]
   ADD [OriginalPDFDocumentStoreId] int NULL;
end
GO

--Check if column exists in a table
Print 'Adding Column ExportPDFReportInAzureStorage to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ExportPDFReportInAzureStorage' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [ExportPDFReportInAzureStorage] bit NULL;

GO

--Check if column exists in a table
Print 'Adding Column DisplayPatientWithoutCHI to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'DisplayPatientWithoutCHI' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [DisplayPatientWithoutCHI] bit NULL;

GO

--Check if column exists in a table
Print 'Adding Column PDFReportDirectoryInAzureStorage to table ERS_OperatingHospitals'
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'PDFReportDirectoryInAzureStorage' AND Object_ID = Object_ID(N'ERS_OperatingHospitals'))
ALTER TABLE [dbo].[ERS_OperatingHospitals]
    ADD [PDFReportDirectoryInAzureStorage] varchar(200) NULL;

GO

EXEC DropIfExist 'sp_Insert_FileExport_ForMirth_Record','S';
GO
CREATE PROCEDURE [dbo].[sp_Insert_FileExport_ForMirth_Record]
(
	@ProcedureId INT,
	@ProcessString varchar(max),
	@Instance as varchar(50),
	@FileContent as varbinary(max),
	@FileLocation as varchar(200),
	@FileLocationDirectory as varchar(2000),
	@DocumentFileName as varchar(500),
	@Base64FileContent as varchar(max),
	@TrustId int,
	@LoggedInUserId INT, 
	@OutputDocumentStoreId as int output
)
AS
------------------------------------------------------------
/*	Mahfuz created	On		17 Nov 2021 for TFS 1779 ICE Interface , Export File Process for Mirth 		*/
/* Mahfuz updated on		20 Feb 2023 for TFS 2279 */
/* Mahfuz updated on		22 Aug 2023	for TFS 2279 changes */
------------------------------------------------------------
BEGIN

	declare @DocumentStoreId int
	declare @FileType as varchar(10)
	Set @FileType = (Select Right(@ProcessString,CharIndex('.',Reverse(@ProcessString) + '.') -1))

	Begin transaction

	Insert into [dbo].[ERS_DocumentStore]
			( ProcedureId,	PDF,	CreateDate, FileType, FileLocation,FileLocationDirectory,DocumentFileName,Base64FileContent)
	Values	(@ProcedureId,	@FileContent,	Getdate(), @FileType, @FileLocation,@FileLocationDirectory,@DocumentFileName, @Base64FileContent)

	Set @DocumentStoreId = IDENT_CURRENT('ERS_DocumentStore')

	INSERT INTO [dbo].[ERS_Export_FileProcess]

	(
	 [Process],				[Instance],		[DocumentStoreId],	[WhoCreatedId]
    ,[WhenCreated],			[ProcedureId],	[TrustId],			HasProcessed
	)

     VALUES
    (
	  @ProcessString,		@Instance,		@DocumentStoreId,	@LoggedInUserId,
	  getDate(),			@ProcedureId,	@TrustId,			0
	)

	Set @OutputDocumentStoreId = @DocumentStoreId
	Commit Transaction

END
Go

EXEC DropIfExist 'sp_InsertBlobDataToDocumentStore','S';
GO
CREATE PROCEDURE [dbo].[sp_InsertBlobDataToDocumentStore]
(
	@ProcedureId INT,
	@bBlobStorageContent varbinary(max),
	@FileType as varchar(10),
	@FileLocation as varchar(500),
	@FileLocationDirectory as varchar(2000),
	@DocumentFilename as varchar(500),
	@Base64FileContent as varchar(max),
	@OriginalPDFDocumentStoreId int,
	@LinkDocumentStoreIds as varchar(200), --Comma separated DocumentStoreIds of other doc types. i.e : xml, html or dat
	@Output_DocumentStoreId int output
)
AS
---------------------------------------------------------------------------------------
/*	Mahfuz created	On		20 Feb 2023 : TFS 2279 Move PDF out of database 		*/
/*			Updated On		22 Aug 2023 : 2279 changes */
---------------------------------------------------------------------------------------
BEGIN

	
	Begin transaction

	Insert into [dbo].[ERS_DocumentStore]
			( ProcedureId,	PDF,	CreateDate, FileType, FileLocation,FileLocationDirectory,DocumentFileName, Base64FileContent,OriginalPDFDocumentStoreId)
	Values	(@ProcedureId,	@bBlobStorageContent,	Getdate(), @FileType,@FileLocation,@FileLocationDirectory,@DocumentFilename, @Base64FileContent,Nullif(@OriginalPDFDocumentStoreId,0))

	Set @Output_DocumentStoreId = IDENT_CURRENT('ERS_DocumentStore')
	
	Update ERS_DocumentStore
	set OriginalPDFDocumentStoreId = @Output_DocumentStoreId	
	Where DocumentStoreId in (Select convert(int,item) from fnSplitString(@LinkDocumentStoreIds,','))


	Commit Transaction

END
Go
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	2279 by Mahfuz
------------------------------------------------------------------------------------------------------------------------
Go

ALTER PROCEDURE [dbo].[report_SCH_Activity]
    @SearchStartDate AS DATE,
    @SearchEndDate AS DATE,
    @OperatingHospitalIds VARCHAR(100),
    @RoomIds VARCHAR(1000),
	@HideSuppressedConsultants BIT,
	@HideSuppressedEndoscopists BIT
AS
/***************************************************************************************************************************
--	Update History:
1.		14 Jan 2022		MH added OperatingHospital column in output TFS# 1841
2.		06 Jul 2022		AS improved performance
3.		12 Jul 2022		AS corrected data output
4.		01 Aug 2022		AS Bug fix: increased the size of the OperatingHospitals field in temporary table #ActivityDetails 
						as test data extended past 50 characters.
****************************************************************************************************************************/
BEGIN

SET NOCOUNT ON

    IF OBJECT_ID('tempdb..#ActivityDetails') IS NOT NULL
        DROP TABLE #ActivityDetails;
    IF OBJECT_ID('tempdb..#ListSlots') IS NOT NULL
        DROP TABLE #ListSlots;
    IF OBJECT_ID('tempdb..#Appointments') IS NOT NULL
        DROP TABLE #Appointments;
    IF OBJECT_ID('tempdb..#tmpOperatingHospitals') IS NOT NULL
        DROP TABLE #tmpOperatingHospitals;
    IF OBJECT_ID('tempdb..#tmpRooms') IS NOT NULL
        DROP TABLE #tmpRooms;
	IF OBJECT_ID('tempdb..#Total_Slots') IS NOT NULL
        DROP TABLE #Total_Slots;
	IF OBJECT_ID('tempdb..#No_Of_Patients') IS NOT NULL
        DROP TABLE #No_Of_Patients;		
	IF OBJECT_ID('tempdb..#No_Of_Patient_Pts_Used') IS NOT NULL
        DROP TABLE #No_Of_Patient_Pts_Used;

	CREATE TABLE #ListSLots
	(
		[Id] INT NOT NULL IDENTITY(1, 1),
        [DiaryIdSlotOrder] INT NULL,
        [ListSlotId] INT NULL,
        [ListRulesId] INT NULL,
        [SlotMinutes] INT NULL,
        [Points] INT NULL,
        [DiaryId] INT NULL,
        [StartTime] DATE NULL,
        [EndTime] DATE NULL,
        [Duration] INT NULL,
        [ApptOverFlow] INT NULL,
        [RoomId] INT NULL
	)
	
	CREATE NONCLUSTERED INDEX [IX_ListSlots_SlotMinutes]
		ON [dbo].[#ListSlots] ([DiaryId],[StartTime])
		INCLUDE ([SlotMinutes]);
	
	CREATE TABLE #Total_Slots
	(
	    [ListRulesId] INT NULL,
		[ListCount] INT NULL
	)
	
	INSERT INTO #Total_Slots
	( 
		ListRulesId,
		ListCount
	) 
	( 
		SELECT 
			ListRulesId, 
			COALESCE(COUNT(*), 0)
		FROM 
			dbo.ERS_SCH_ListSlots (NOLOCK) 
		GROUP BY 
			ListRulesId 
	)

	CREATE TABLE #No_Of_Patients
	(
	    [DiaryId] INT NULL,
		[ListCount] INT NULL
	)

	INSERT INTO #No_Of_Patients
	(
		DiaryId,
		ListCount
	)
    (
		SELECT 
			ea.DiaryId,
			COALESCE(COUNT(*), 0) 
		FROM
			dbo.ERS_Appointments AS ea (NOLOCK)
			INNER JOIN dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
				ON esdp.DiaryId = ea.DiaryId
		WHERE
			ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
			AND ea.DiaryId IS NOT NULL
		GROUP BY
			ea.DiaryId
	)
	
	CREATE TABLE #No_Of_Patient_Pts_Used
	(
	    [DiaryId] INT NULL,
		[ListCount] INT NULL
	)
		
	INSERT INTO #No_Of_Patient_Pts_Used
	(
		DiaryId,
		ListCount
	)
	(
		SELECT
			ea2.DiaryId,
			COALESCE(SUM(eapt.Points), 0) AS listCount
		FROM
			dbo.ERS_Appointments AS ea2 (NOLOCK)
			INNER JOIN dbo.ERS_AppointmentProcedureTypes AS eapt (NOLOCK)
				ON eapt.AppointmentID = ea2.AppointmentId
		WHERE
			ea2.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery			
		GROUP BY
			ea2.DiaryId
	) 
	
	CREATE TABLE #tmpOperatingHospitals
	(
	    [Id] INT NOT NULL,
		[Item] INT NOT NULL
	)

	INSERT INTO #tmpOperatingHospitals
	(
	    Id,
	    Item
	)
	(   
		SELECT
			Id,
			Item    
		FROM
			dbo.fnSplitString(ISNULL(@OperatingHospitalIds, ''), ',')
	)

	CREATE TABLE #tmpRooms
	(
	    [Id] INT NOT NULL,
		[Item] INT NOT NULL
	)
    
	INSERT INTO #tmpRooms
	(
	    Id,
	    Item
	)	
	(   
		SELECT
			Id,
			Item		
		FROM
			dbo.fnSplitString(ISNULL(@RoomIds, ''), ',')
	)

	CREATE TABLE #Appointments
	(
	    [Id] INT NOT NULL IDENTITY (1, 1),
		[OperatingHospital] VARCHAR(150) NOT NULL,
		[DiaryId] INT NOT NULL,
		[StartTime] DATETIME NOT NULL,
		[Duration] VARCHAR(100) NULL,
		[ListSlotId] INT
	)

	INSERT INTO #Appointments
	(
	    OperatingHospital,
	    DiaryId,
	    StartTime,
	    Duration,
		ListSlotId
	)
	(  
		SELECT			
			oh.HospitalName,
			ea.DiaryId,
			ea.StartDateTime,
			ea.AppointmentDuration,
			ea.ListSlotId
		FROM
			dbo.ERS_Appointments AS ea (NOLOCK)
			INNER JOIN dbo.ERS_OperatingHospitals oh (NOLOCK)
				ON ea.OperationalHospitaId = oh.OperatingHospitalId
		WHERE
			ea.DiaryId IS NOT NULL
			AND EXISTS
			(
				SELECT Item FROM #tmpOperatingHospitals AS toh
			)
			AND ea.StartDateTime BETWEEN @SearchStartDate AND @SearchEndDate	
			AND ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
	)
	
    DECLARE @counter INT = 0;
    DECLARE @ListSlotsTempTableCount INT = 0;

    INSERT INTO #ListSlots
	(
        [DiaryIdSlotOrder],
        [ListSlotId],
        [ListRulesId],
        [SlotMinutes],
        [Points],
        [DiaryId],
        [StartTime],
        [EndTime],
        [Duration],
        [ApptOverFlow],
        [RoomId]
	)
	SELECT
        0, 
        esls.ListSlotId, 
        esls.ListRulesId, 
        esls.SlotMinutes, 
        esls.Points, 
        esdp.DiaryId, 
        esdp.DiaryStart, 
        esdp.DiaryEnd,
        0, 
        0,
        esdp.RoomID
    FROM
        dbo.ERS_SCH_ListSlots AS esls (NOLOCK)
        LEFT JOIN dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
            ON esdp.ListRulesId = esls.ListRulesId
    WHERE
        esdp.DiaryId IS NOT NULL
		AND esdp.RoomID in
        (
            SELECT Item FROM #tmpRooms AS tr
        )
        AND esdp.DiaryStart
        BETWEEN @SearchStartDate AND @SearchEndDate

    ORDER BY
        esdp.DiaryId,
        esls.ListSlotId;

    SELECT
        @ListSlotsTempTableCount = @@ROWCOUNT;
		
    DECLARE @tempDiaryId INT = 0;
    DECLARE @currentRecordDiaryId INT = 0;
    DECLARE @newDiaryRecordFlag BIT = 0;
    DECLARE @currentRecordSlotMinutes INT = 0;
    DECLARE @currentRecordStartTime DATETIME;
    DECLARE @currentRecordEndTime DATETIME;
    DECLARE @previousRecordEndTime DATETIME;
    DECLARE @diaryIdSlotOrder INT = 0;

    SET @counter = 1;

    WHILE (@counter <= @ListSlotsTempTableCount)
    BEGIN
        SELECT
            @currentRecordDiaryId = DiaryId,
            @currentRecordSlotMinutes = SlotMinutes,
            @currentRecordStartTime = StartTime
        FROM
            #ListSlots
        WHERE
            Id = @counter;

        IF @tempDiaryId = 0
           OR @tempDiaryId <> @currentRecordDiaryId
        BEGIN
            SET @tempDiaryId = @currentRecordDiaryId;
            SET @newDiaryRecordFlag = 1;
            SET @diaryIdSlotOrder = 1;
        END;
        ELSE
        BEGIN
            SET @newDiaryRecordFlag = 0;
            SET @diaryIdSlotOrder = @diaryIdSlotOrder + 1;
        END;

        IF @newDiaryRecordFlag = 1
        BEGIN
            SET @currentRecordEndTime = DATEADD(MINUTE, @currentRecordSlotMinutes, @currentRecordStartTime);

            UPDATE
                #ListSlots
            SET
                EndTime = @currentRecordEndTime,
                DiaryIdSlotOrder = @diaryIdSlotOrder
            WHERE
                Id = @counter;
        END;
        ELSE IF @newDiaryRecordFlag = 0
        BEGIN
            SET @currentRecordStartTime = @previousRecordEndTime;
            SET @currentRecordEndTime = DATEADD(MINUTE, @currentRecordSlotMinutes, @currentRecordStartTime);

            UPDATE
                #ListSlots
            SET
                StartTime = @currentRecordStartTime,
                EndTime = @currentRecordEndTime,
                DiaryIdSlotOrder = @diaryIdSlotOrder
            FROM
                #ListSlots
            WHERE
                Id = @counter;
        END;

        SET @counter = @counter + 1;

        SET @previousRecordEndTime = @currentRecordEndTime;

    END;    

    UPDATE
        ls
    SET
        ls.Duration = a.Duration,
        ls.ApptOverFlow = a.Duration - ls.SlotMinutes
    FROM
        #ListSlots ls
        INNER JOIN #Appointments AS a
            ON a.DiaryId = ls.DiaryId and a.ListSlotId = ls.ListSlotId
               AND a.StartTime = ls.StartTime;

CREATE TABLE #ActivityDetails
(
    [DiaryId] INT NOT NULL,
	[OperatingHospital] VARCHAR(500) NULL,
	[RoomId] INT NULL,
	[Day] VARCHAR(10) NULL,
	[Date] DATE NULL,
	[Room] VARCHAR(50) NULL,
	[ListConsultant] VARCHAR(50) NULL,
	[Endoscopist] VARCHAR(50) NULL,
	[TemplateName] VARCHAR(75) NULL,
	[AM/PM] VARCHAR(2) NULL,
	[NoOfPtsOnTemplate] INT NULL,
	[NoOfPtsBooked] INT NULL,
	[NoOfPtsRemaining] INT NULL,
	[NoOfPatientsAttended] INT NULL,
	[NoOfPatientPointsUsed] INT NULL,		
	[ListLocked] VARCHAR(3) NULL,	
	[ReasonsLocked] VARCHAR(100) NULL,
	[ListUnlocked] VARCHAR(3) NULL,
	[ReasonsUnlocked] VARCHAR(100) NULL
)

INSERT INTO #ActivityDetails
(
    [DiaryId],
	[OperatingHospital],
	[RoomId],
	[Day],
	[Date],
	[Room],
	[ListConsultant],
	[Endoscopist],
	[TemplateName],
	[AM/PM],
	[NoOfPtsOnTemplate],
	[NoOfPtsBooked],
	[NoOfPtsRemaining],
	[NoOfPatientsAttended],
	[NoOfPatientPointsUsed],		
	[ListLocked],	
	[ReasonsLocked],
	[ListUnlocked],
	[ReasonsUnlocked]
)			   
(
	SELECT  
        ea.DiaryId AS [DiaryId],
		eoh.HospitalName AS [OperatingHospital],
		esr.RoomId AS [RoomId],
        FORMAT(ea.StartDateTime, 'ddd') AS [Day],        
        CONVERT(DATE, ea.StartDateTime, 106) AS [Date],        
        esr.RoomName AS [Room],
        CASE
            WHEN eu.IsListConsultant = 1 THEN
                LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)
            ELSE
                ''
        END AS [ListConsultant],
        CASE
            WHEN eu.IsEndoscopist1 = 1
                 OR eu.IsEndoscopist2 = 1 THEN
                LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)
            ELSE
                ''
        END AS [Endoscopist],
        eslr.ListName AS [TemplateName],
        CASE
            WHEN DATEPART(HH, ea.StartDateTime) < 12 THEN
                'AM'
            WHEN DATEPART(HH, ea.StartDateTime) < 17 THEN
                'PM'
            ELSE
                'EV'
        END AS [AM/PM],
        COALESCE(eslr.Points, 0) AS [NoOfPtsOnTemplate],
        COALESCE(esls.Points, 0) AS [NoOfPtsBooked],
		COALESCE(eslr.Points, 0) - COALESCE(esls.Points, 0) AS [NoOfPtsRemaining],
        COALESCE(no_of_patients.ListCount, 0) AS [NoOfPatientsAttended],
        COALESCE(no_of_patient_pts_used.ListCount, 0) AS [NoOfPatientPointsUsed],		
		'' AS [ListLocked],	
		'' AS [ReasonsLocked],
		'' AS [ListUnlocked],
		'' AS [ReasonsUnlocked]		    		    
    FROM
        dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
        INNER JOIN dbo.ERS_SCH_ListRules AS eslr (NOLOCK)
            ON esdp.ListRulesId = eslr.ListRulesId
        INNER JOIN dbo.ERS_SCH_ListSlots AS esls (NOLOCK)
            ON esdp.ListRulesId = esls.ListRulesId
        INNER JOIN dbo.ERS_Appointments AS ea (NOLOCK)
            ON esdp.DiaryId = ea.DiaryId AND ea.ListSlotId = esls.ListSlotId			
			AND ea.StartDateTime >= esdp.DiaryStart AND ea.StartDateTime <= esdp.DiaryEnd
			AND ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
        INNER JOIN dbo.ERS_SCH_Rooms AS esr (NOLOCK)
            ON esdp.RoomID = esr.RoomId
        LEFT JOIN dbo.ERS_Users AS eu (NOLOCK)
            ON ea.EndoscopistId = eu.UserID
		LEFT JOIN ERS_Users elc ON esdp.ListConsultantId = elc.UserID
        LEFT JOIN dbo.ERS_SCH_LockedDiaries AS esld (NOLOCK)
            ON esld.DiaryId = esdp.DiaryId 
			AND esld.DiaryId IS NOT NULL	
        LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS esdlr (NOLOCK)
            ON esdlr.DiaryLockReasonId = esld.LockedReasonId
		LEFT JOIN #No_Of_Patients AS no_of_patients
			ON no_of_patients.DiaryId = esdp.DiaryId 
		LEFT JOIN #No_Of_Patient_Pts_Used AS no_of_patient_pts_used
            ON no_of_patient_pts_used.DiaryId = esdp.DiaryId
		LEFT JOIN dbo.ERS_OperatingHospitals AS eoh (NOLOCK)
			ON eoh.OperatingHospitalId = esr.HospitalId
    WHERE
        esdp.OperatingHospitalId in 
        (
            SELECT Item FROM #tmpOperatingHospitals
        )
        AND esdp.RoomID in 
        (
            SELECT Item FROM #tmpRooms
        )
		
		AND eu.Suppressed = CASE WHEN @HideSuppressedEndoscopists = 1 THEN 0 ELSE eu.Suppressed END
		AND elc.Suppressed = CASE WHEN @HideSuppressedConsultants = 1 THEN 0 ELSE elc.Suppressed END
    GROUP BY
        ea.DiaryId,
		eoh.HospitalName,
        ea.StartDateTime,
        CASE
            WHEN DATEPART(HH, ea.StartDateTime) < 12 THEN
                'AM'
            WHEN DATEPART(HH, ea.StartDateTime) < 17 THEN
                'PM'
            ELSE
                'EV'
        END,
		esr.RoomId,
        esr.RoomName,
        eu.IsListConsultant,
        eu.IsEndoscopist1,
        eu.IsEndoscopist2,
        LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename),
        eslr.ListName,
        eslr.Points,
        esls.Points,
        no_of_patients.listCount,
        no_of_patient_pts_used.listCount,        
        ea.EndoscopistId
);
		
	WITH appointment_details AS
	(
		SELECT 
			ea.DiaryId, 
			ea.StartDateTime, 
			esdp.DiaryStart, 
			esdp.DiaryEnd, 
			esld.Locked, 
			diaryLockReason.IsLockReason,		
			diaryLockReason.Reason AS [LockReason],
			diaryUnlockReason.IsUnlockReason,
			diaryUnlockReason.Reason AS [UnlockReason]
		FROM 
			dbo.ERS_Appointments AS ea
			INNER JOIN dbo.ERS_SCH_DiaryPages AS esdp 
				ON ea.DiaryId = esdp.DiaryId
			INNER JOIN dbo.ERS_SCH_LockedDiaries AS esld
				ON esld.DiaryId = ea.DiaryId
			LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS diaryLockReason
				ON diaryLockReason.DiaryLockReasonId = esld.LockedReasonId
			LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS diaryUnlockReason
			ON diaryUnlockReason.DiaryLockReasonId = esld.UnlockedReasonId
		WHERE 
			ea.StartDateTime >= esdp.DiaryStart AND ea.StartDateTime <= esdp.DiaryEnd
			AND ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 )		
	)

	UPDATE
		#ActivityDetails
	SET
		#ActivityDetails.ListLocked = CASE WHEN appointment_details.Locked = 1 THEN 'YES' ELSE 'NO' END,
		#ActivityDetails.ReasonsLocked = CASE WHEN appointment_details.Locked = 1 THEN appointment_details.LockReason ELSE '' END,
		#ActivityDetails.ListUnlocked = CASE WHEN appointment_details.Locked = 0 THEN 'YES' ELSE 'NO' END,
		#ActivityDetails.ReasonsUnlocked = CASE WHEN appointment_details.Locked = 0 THEN appointment_details.UnlockReason ELSE '' END
	FROM
		appointment_details 
	WHERE
		#ActivityDetails.[DiaryId] = appointment_details.[DiaryId] 	

    SELECT
        [DiaryId],
		[OperatingHospital],
        [RoomId],
        [Day],
        [Date],
        [Room],
        [ListConsultant],
        [Endoscopist],
        [TemplateName],
        [AM/PM],
        [NoOfPtsOnTemplate],
        [NoOfPtsBooked],
		[NoOfPtsRemaining],
        [NoOfPatientsAttended],
        [NoOfPatientPointsUsed],
        [ListLocked],
        [ReasonsLocked],
        [ListUnlocked],
        [ReasonsUnlocked]
    FROM
        #ActivityDetails
    WHERE
        RoomId IS NOT NULL
    GROUP BY
        [DiaryId],
		[OperatingHospital],
        [Date],
        [AM/PM],
        [RoomId],
        [Room],
        [Day],
        [ListConsultant],
        [Endoscopist],
        [TemplateName],
        [NoOfPtsOnTemplate],
		[NoOfPtsBooked],
		[NoOfPtsRemaining],
        [NoOfPatientsAttended],
		[NoOfPatientPointsUsed],
        [ListLocked],
        [ReasonsLocked],
        [ListUnlocked],
        [ReasonsUnlocked]
    ORDER BY
        [Date] DESC;

END
GO

-- PEG Report
GO
ALTER PROCEDURE [dbo].[report_JAGPEG] 
	@UserID INT
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
******************************************************************************************************************/
BEGIN

	SELECT DISTINCT PR.ProcedureId as ProcId, PC.ProcedureId, RC.ConsultantId ReportConsultant,eug.EndoRole, CorrectPEGPlacement
	INTO #Procedures
	FROM fw_ProceduresConsultants PC
	INNER JOIN dbo.ERS_Procedures PR ON PC.ProcedureId = 'E.' + convert(varchar(10), PR.ProcedureId)
	INNER JOIN dbo.ERS_Sites es ON PR.ProcedureId = es.ProcedureId
	INNER JOIN dbo.ERS_UpperGITherapeutics eug ON es.SiteId = eug.SiteId
	INNER JOIN dbo.ERS_ProcedureIndications epi ON es.ProcedureId = epi.ProcedureId
	INNER JOIN ERS_Indications i ON i.UniqueId = epi.IndicationId
	INNER JOIN dbo.fw_ReportConsultants RC ON PC.ConsultantId = RC.ConsultantId,
	dbo.fw_ReportFilter RF
	WHERE RF.UserId = RC.UserId AND PR.CreatedOn >= RF.FromDate AND PR.CreatedOn <= RF.ToDate AND PC.ConsultantTypeId IN (1,2)
	AND RF.UserId = @UserID
	AND (RC.ConsultantId = 'E.' + convert(varchar(10), PR.Endoscopist1) OR (RC.ConsultantId = 'E.' + convert(varchar(10), PR.Endoscopist2) and PR.Endo2Role in (2, 3) and eug.EndoRole IN (2,3)))
	
	--AND ((RC.ConsultantId = 'E.' + convert(varchar(10), PR.Endoscopist1) AND Endo1Role = 2 AND eug.EndoRole = 1) /*trainer did it alone*/
	--	OR   (eug.EndoRole IN (2,3)) /*2 = trainer observed, 3 = trainer assisted*/
	--	OR   (Endo1Role = 1 AND eug.EndoRole IN (1,4) /*2 independant endos*/))
	AND (eug.GastrostomyInsertion = 1 AND LOWER(i.NEDTerm) != 'nasojejenal tube insertion') AND (PR.ProcedureCompleted=1 AND PR.IsActive=1)
	--MH added on 31 Mar 2022
	and IsNull(PR.DNA,0) = 0

	SELECT * 
	FROM
	(
		SELECT DISTINCT RC.AnonimizedID
			, C.ConsultantName AS Endoscopist1
			, C.ConsultantId AS ReportID
			, C.ConsultantName AS Consultant

			, (SELECT COUNT(DISTINCT ProcedureId) 
			   FROM #Procedures PR WHERE RC.ConsultantId = PR.ReportConsultant
			   ) AS [NumberOfProcedures]

			, (SELECT COUNT(DISTINCT PR.ProcedureId) 
				FROM #Procedures PR 
				WHERE Pr.CorrectPEGPlacement = 1 AND RC.ConsultantId = PR.ReportConsultant
			  ) * 1.0 /NULLIF(
			  (SELECT COUNT(DISTINCT ProcedureId) FROM #Procedures WHERE RC.ConsultantId = ReportConsultant
			  ) ,0) AS SatisfactoryPlacementOfPEGP
			
			, (SELECT COUNT(DISTINCT PR.ProcedureId) 
				FROM #Procedures PR 
				JOIN ERS_PostOperativeComplications POC ON PR.ProcId = POC.ProcedureId
				WHERE PR.ReportConsultant = RC.ConsultantId
				AND POC.AntibioticsForInfectionFollowingPEG = 1
				) * 1.0 / NULLIF(
				(SELECT COUNT(DISTINCT ProcedureId) 
				FROM  #Procedures WHERE ReportConsultant = RC.ConsultantId
				), 0) AS PostProcedureInfectionRequiringAntibioticsP
			
			, (SELECT COUNT(DISTINCT PR.ProcedureId) 
				FROM #Procedures PR 
				JOIN ERS_PostOperativeComplications POC ON PR.ProcId = POC.ProcedureId
				WHERE PR.ReportConsultant = RC.ConsultantId
				AND POC.PeritonitisFollowingPEG = 1
				) * 1.0 / NULLIF(
				(SELECT COUNT(DISTINCT ProcedureId) 
				FROM #Procedures WHERE ReportConsultant = RC.ConsultantId
				), 0) AS PostProcedurePeritonitisP
				
			, (SELECT COUNT(DISTINCT PR.ProcedureId) 
				FROM #Procedures PR 
				JOIN dbo.ERS_ProcedureAdverseEvents eug	ON PR.ProcId = eug.ProcedureId
				JOIN ERS_AdverseEvents e ON e.UniqueId = eug.AdverseEventId
				WHERE PR.ReportConsultant = RC.ConsultantId
				AND LOWER(e.NEDTerm) = 'blood transfusion'
				) * 1.0 / NULLIF(
				(SELECT COUNT(DISTINCT ProcedureId) 
				FROM #Procedures WHERE ReportConsultant = RC.ConsultantId
				), 0) AS BleedingRequiringTransfusionP

			, 'Â ' AS ClinicalLeadReviewAndActionRequired
		FROM  fw_ReportConsultants RC, fw_Consultants C, fw_ReportFilter RF, fw_ProceduresConsultants PC
		WHERE RF.UserId = RC.UserId 
			AND RF.UserId = @UserId
			AND RC.ConsultantId = PC.ConsultantId
			AND PC.ConsultantId = C.ConsultantId
			AND PC.ConsultantTypeId IN (1,2)
	) AS T
	WHERE [NumberOfProcedures] > 0
	ORDER BY AnonimizedID

	DROP TABLE #Procedures
END
GO

ALTER Procedure [dbo].[report_JAGPEG_DrillDown] 
	@UserId int,
	@AnonomizedId int
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
	02		:		01 Aug 2022		Adrian Rename NHSNo Column to match custom Health Service
******************************************************************************************************************/
BEGIN

	DECLARE @ConsultantId as int,
			@FromDate as Date,
			@ToDate as Date,
			@HealthService as varchar(max)

	Select @ConsultantId = ConsultantID 
	from ERS_ReportConsultants
	where AnonimizedID = @AnonomizedId
	and UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	SELECT  distinct
			pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			ps.PatientStatus as 'Patient Status',
			CASE WHEN ISNULL(PEGProc.CorrectPEGPlacement,0) > 0 THEN 'Yes' ELSE 'No' END AS 'Correct placement',
			CASE WHEN poc.AntibioticsForInfectionFollowingPEG = 1 THEN 'Yes' ELSE 'No' END as 'Post procedure infection requiring antibiotics',
			CASE WHEN poc.PeritonitisFollowingPEG = 1 THEN 'Yes' ELSE 'No' END as 'Post procedure peritonitis',
			CASE WHEN qa.SignificantHaemorrhage = 1 THEN 'Yes' ELSE 'No' END as 'Bleeding requiring transfusion'
	INTO ##ReportTemp
	FROM ERS_Procedures p
	join (select ListItemNo as PatientStatusId, ListItemText as PatientStatus from ERS_Lists where ListDescription = 'Patient Status') ps on p.PatientStatus = ps.PatientStatusId
		LEFT JOIN (SELECT DISTINCT ProcedureId, eug.GastrostomyInsertion, 
					 SUM(CASE WHEN eug.CorrectPEGPlacement = 1 THEN 1 ELSE 0 END) AS CorrectPEGPlacement, 
					 eug.EndoRole
					FROM dbo.ERS_UpperGITherapeutics eug
						INNER JOIN dbo.ERS_Sites es  ON es.SiteId = eug.SiteId
					WHERE eug.GastrostomyInsertion = 1
					GROUP BY ProcedureId, eug.GastrostomyInsertion, eug.EndoRole
					) AS PEGProc ON PEGProc.ProcedureId = p.ProcedureId
		join ERS_Users u on (u.UserID = p.Endoscopist1 or u.UserID = p.Endoscopist2)
		join ERS_Patients pat on pat.PatientId = p.PatientId
		INNER JOIN dbo.ERS_ProcedureIndications epi ON p.ProcedureId = epi.ProcedureId
		INNER JOIN ERS_Indications i ON i.UniqueId = epi.IndicationId
		left join ERS_UpperGIQA qa on qa.ProcedureId = p.ProcedureId
		left join ERS_PostOperativeComplications poc on poc.ProcedureId = p.ProcedureId 
	where u.UserID = @ConsultantId
		AND (PEGProc.GastrostomyInsertion = 1 and LOWER(i.NEDTerm) != 'nasojejenal tube insertion')
		and p.ProcedureCompleted = 1
		and p.IsActive = 1
		--MH added on 31 Mar 2022
		and IsNull(p.DNA,0) = 0
		and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
		AND (@ConsultantId = convert(varchar(10), P.Endoscopist1)
			OR (@ConsultantId = convert(varchar(10), p.Endoscopist2) and P.Endo2Role in (2, 3) and PEGProc.EndoRole IN (2,3))
			)
		AND (@ConsultantId = convert(varchar(10), P.Endoscopist1) OR (@ConsultantId = convert(varchar(10), p.Endoscopist2) and P.Endo2Role in (2, 3)))
	GROUP BY pat.Forename1, pat.Surname, pat.HospitalNumber,qa.PatDiscomfortEndo, pat.NHSNo, pat.GenderId,p.CreatedOn, ps.PatientStatus, PEGProc.CorrectPEGPlacement, poc.PeritonitisFollowingPEG, poc.AntibioticsForInfectionFollowingPEG, qa.SignificantHaemorrhage,
	p.ProcedureId

	declare @SQL nvarchar(1000)
	set @SQL = 'tempdb.sys.sp_rename N''##ReportTemp.NHSNo'', N''' + @HealthService + ' No'' '
	exec sp_executesql @SQL

	Select * from ##ReportTemp
	drop table ##ReportTemp

END

GO
-- END OF PEG REPORT 
GO
ALTER PROCEDURE [dbo].[brt_abno_descrip_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE 
		@summary VARCHAR(8000),
		@tmpsummary VARCHAR(2000),
		@none					BIT,
		@Normal					BIT,
		@Carinal				TINYINT,
		@Vocal					TINYINT,
		@Compression			BIT,
		@CompressionGeneral		BIT,
		@CompressionFromLeft	BIT,
		@CompressionFromRight	BIT,
		@CompressionFromAnterior	BIT,
		@CompressionFromPosterior	BIT,
		@Stenosis				TINYINT,
		@Obstruction			TINYINT,
		@Mucosal				BIT,
		@MucosalOedema			BIT,
		@MucosalErythema		BIT,
		@MucosalPits			BIT,
		@MucosalAnthracosis		BIT,
		@MucosalInfiltration	BIT,
		@MucosalIrregularity	TINYINT,
		@ExcessiveSecretions	TINYINT,
		@Bleeding				TINYINT

	DECLARE @tblsummary TABLE (summary VARCHAR(500))

	SELECT 
		@Normal = Normal,
		@Carinal = Carinal,
		@Vocal = Vocal,
		@Compression = [Compression],
		@CompressionGeneral = CompressionGeneral,
		@CompressionFromLeft = CompressionFromLeft,
		@CompressionFromRight = CompressionFromRight,
		@CompressionFromAnterior = CompressionFromAnterior,
		@CompressionFromPosterior = CompressionFromPosterior,
		@Stenosis = Stenosis,
		@Obstruction = Obstruction,
		@Mucosal = Mucosal,
		@MucosalOedema = MucosalOedema,
		@MucosalErythema = MucosalErythema,
		@MucosalPits = MucosalPits,
		@MucosalAnthracosis = MucosalAnthracosis,
		@MucosalInfiltration = MucosalInfiltration,
		@MucosalIrregularity = MucosalIrregularity,
		@ExcessiveSecretions = ExcessiveSecretions,
		@Bleeding = Bleeding
	FROM 
		ERS_BRTAbnoDescriptions p
	WHERE
		SiteId = @SiteId

	SET @summary = '<br /> '
	
	IF ISNULL(@Bleeding,0) > 0 
	BEGIN
		SET @tmpSummary = 'Bleeding: '
		IF @Bleeding = 1
			SET @tmpSummary = @tmpSummary + ' fresh'
		IF @Bleeding = 2
			SET @tmpSummary = @tmpSummary + ' old'

		SET @Summary = @Summary + @tmpSummary + '.<br /> '
	END

	IF ISNULL(@Carinal,0) > 0 
	BEGIN
		SET @tmpSummary = 'Carinal: '
		IF @Carinal = 1 
			SET @tmpSummary = @tmpSummary + ' normal'
		IF @Carinal = 2 
			SET @tmpSummary = @tmpSummary + ' widened'
		
		SET @Summary = @Summary + @tmpSummary + '.<br />'
	END

	IF @Compression	= 1 OR @CompressionFromAnterior	= 1 OR @CompressionFromLeft	= 1 OR @CompressionFromPosterior =1 OR @CompressionFromRight = 1 OR @CompressionGeneral	 = 1
	BEGIN
		SET @tmpSummary = 'Compression:'

		IF @CompressionGeneral = 1
		BEGIN
			SET @tmpsummary	= @tmpsummary + ' general,'
		END

		IF @CompressionFromAnterior = 1
		BEGIN
			SET @tmpsummary	= @tmpsummary + ' from anterior,'
		END

		IF @CompressionFromLeft = 1
		BEGIN
			SET @tmpsummary	= @tmpsummary + ' from left,'
		END

		IF @CompressionFromPosterior = 1
		BEGIN
			SET @tmpsummary	= @tmpsummary + ' from posterior,'
		END

		IF @CompressionFromRight = 1
		BEGIN
			SET @tmpsummary	= @tmpsummary + ' from right,'
		END

		--replace last , with and
		--SET @tmpsummary = STUFF(@tmpSummary, charindex(',', REVERSE(@tmpSummary),1),1,'and')
		SET @tmpSummary = REVERSE(STUFF(REVERSE(@tmpSummary),1,1,''))
		SET @Summary = @Summary + @tmpSummary + '.<br />'
	END

	IF ISNULL(@ExcessiveSecretions,0) > 0 
	BEGIN
		SET @tmpSummary = 'Excessive secretions: '
		IF @ExcessiveSecretions = 1
			SET @tmpSummary = @tmpSummary + ' Purulent'
		IF @ExcessiveSecretions = 2
			SET @tmpSummary = @tmpSummary + ' Non-purulent'

		SET @Summary = @Summary + @tmpSummary + '.<br /> '
	END

	IF @Mucosal = 1 OR @MucosalOedema = 1 OR @MucosalErythema = 1 OR @MucosalPits = 1 OR @MucosalAnthracosis = 1 OR @MucosalInfiltration =1 OR @MucosalIrregularity = 1
	BEGIN
		SET @tmpSummary = 'Mucosal: '
		IF @MucosalOedema = 1 
		BEGIN
			SET @tmpSummary = @tmpSummary + ' oedema,'
		END

		IF @MucosalErythema = 1 
		BEGIN
			SET @tmpSummary = @tmpSummary + ' erythema,'
		END
		
		IF @MucosalOedema = 1 
		BEGIN
			SET @tmpSummary = @tmpSummary + ' oedema,'
		END
		
		IF @MucosalPits = 1 
		BEGIN
			SET @tmpSummary = @tmpSummary + ' pits,'
		END
		
		IF @MucosalAnthracosis = 1 
		BEGIN
			SET @tmpSummary = @tmpSummary + ' anthracosis,'
		END
		
		IF @MucosalInfiltration = 1 
		BEGIN
			SET @tmpSummary = @tmpSummary + ' infiltration,'
		END


		SET @tmpSummary = REVERSE(STUFF(REVERSE(@tmpSummary),1,1,''))
		SET @Summary = @Summary + @tmpSummary + '.<br /> '
	END
	
	IF ISNULL(@MucosalIrregularity,0) > 0 
	BEGIN
		SET @tmpSummary = 'Mucosal irregularity: '
		IF @MucosalIrregularity = 1
			SET @tmpSummary = @tmpSummary + ' Unknown'
		IF @MucosalIrregularity = 2
			SET @tmpSummary = @tmpSummary + ' Possible tumour'
		IF @MucosalIrregularity = 3
			SET @tmpSummary = @tmpSummary + ' Definite tumour'

		SET @Summary = @Summary + @tmpSummary + '.<br /> '
	END

	IF ISNULL(@Obstruction,0) > 0 
	BEGIN
		SET @tmpSummary = 'Obstruction: '
		IF @Obstruction = 1
			SET @tmpSummary = @tmpSummary + ' Partial'
		IF @Obstruction = 2
			SET @tmpSummary = @tmpSummary + ' Complete'

		SET @Summary = @Summary + @tmpSummary + '.<br /> '
	END

	IF ISNULL(@Stenosis,0) > 0 
	BEGIN
		SET @tmpSummary = 'Stenosis: '
		IF @Stenosis = 1
			SET @tmpSummary = @tmpSummary + ' Partial'
		IF @Stenosis = 2
			SET @tmpSummary = @tmpSummary + ' Complete'

		SET @Summary = @Summary + @tmpSummary + '.<br /> '
	END

	IF ISNULL(@Vocal,0) > 0 
	BEGIN
		SET @tmpSummary = 'Vocal cord paralysis: '
		IF @Vocal = 1
			SET @tmpSummary = @tmpSummary + ' Partial'
		IF @Vocal = 2
			SET @tmpSummary = @tmpSummary + ' Complete'

		SET @Summary = @Summary + @tmpSummary + '.<br /> '
	END

	EXEC sites_summary_update @SiteId



	-- Finally update the summary in abnormalities table
	UPDATE ERS_BRTAbnoDescriptions
	SET Summary = REVERSE(STUFF(REVERSE(@Summary),1,1,'')) 
	WHERE SiteId = @siteId

GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Mahfuz	On 10 Oct 2023
-- TFS#	2279
-- Description of change
-- Move PDFs out of the database into file storage (Blob Storage if Azure)
------------------------------------------------------------------------------------------------------------------------
Go

EXEC DropIfExist 'sp_GetPDFRemovalPrimaryConfigData','S';
GO
CREATE PROCEDURE [dbo].[sp_GetPDFRemovalPrimaryConfigData]
AS
---------------------------------------------------------------------------------------
/*	Mahfuz created	On		22 Sep 2023 : TFS 2279 Move PDF out of database 		*/
/*			Updated On		 */
---------------------------------------------------------------------------------------
BEGIN


	--Table 0: List of all operating hospitals

	Select OperatingHospitalId,ReportExportPath,ReportDocumentExportApiUrl,DocumentExportSharedLocation,ReportSharedDriveAccessUser,SharedDriveAccessUserPassword,DirectoryNameForXmlTransferInAzure,PDFReportDirectoryInAzureStorage from ERS_OperatingHospitals



END
Go

EXEC DropIfExist 'sp_RemovePDFFileContentUpdateDocumentStore','S';
GO
CREATE PROCEDURE [dbo].[sp_RemovePDFFileContentUpdateDocumentStore]
(
	@DocumentStoreId int,
	@FileLocation varchar(2000),
	@FileLocationDirectory varchar(2000),
	@DocumentFileName varchar(500)
)
AS
---------------------------------------------------------------------------------------
/*	Mahfuz created	On		22 Sep 2023 : TFS 2279 Move PDF out of database 		*/
/*			Updated On		 */
---------------------------------------------------------------------------------------
BEGIN

	--No need to set recovery mode simple here. This has been done inside console app in upper level

	Update ERS_DocumentStore
	Set PDF = null,
	FileLocation = @FileLocation,
	FileLocationDirectory = @FileLocationDirectory,
	DocumentFileName = @DocumentFileName
	Where DocumentStoreId = @DocumentStoreId

	--DBCC Shrink Database will be executed after finishing the batch inside the console app in level

END
Go

EXEC DropIfExist 'sp_GetDocumentStorePDFContentForRemoval','S';
GO
CREATE PROCEDURE [dbo].[sp_GetDocumentStorePDFContentForRemoval]
(
	@OperatingHospitalId int
)
AS
---------------------------------------------------------------------------------------
/*	Mahfuz created	On		22 Sep 2023 : TFS 2279 Move PDF out of database 		*/
/*			Updated On		 */
---------------------------------------------------------------------------------------
BEGIN

--Console app will run in a batch of N number of procedures/reports (200 used here) can be set lower or higher

	Select top 100 eds.ProcedureId,PDF,CreateDate,FileType,DocumentStoreId,pr.Patientid,pat.HospitalNumber,pat.NHSNo, pt.ProcedureType,pt.ProcedureTypeId
from ERS_DocumentStore eds
Inner join ERS_Procedures pr on eds.ProcedureId = pr.ProcedureId
inner join ERS_Patients pat on pr.Patientid = pat.Patientid
inner join ERS_ProcedureTypes pt on pr.ProcedureType = pt.ProcedureTypeId
Where PDF is not null
and CreateDate < DateAdd(month,-1,getdate())
and pr.OperatingHospitalID = @OperatingHospitalId
Order by CreateDate Asc

END
Go

EXEC DropIfExist 'sp_DBCCShrinkDatabase','S';
GO
Create procedure sp_DBCCShrinkDatabase
As
/*
		21 July 2022		MH		Created for deleting old audit records - TFS 1323-Clear down audit tables to only keep 6 months of data		
*/
begin
	Declare @EachFileId int
	Declare @EachFileName varchar(500)
	Declare @EachFileLocation varchar(1000)

	

	Declare curFiles cursor
	For
	select file_id, name,physical_name from sys.database_files

	Open curFiles
	
	Fetch Next from curFiles into @EachFileId, @EachFileName, @EachFileLocation

	Alter Database current
	Set Recovery simple;

	While @@FETCH_STATUS = 0
	Begin
		Print @EachFileLocation
		DBCC SHRINKFILE (@EachFileId, 1); 
		Fetch Next from curFiles into @EachFileId, @EachFileName, @EachFileLocation
	End

	Close curFiles
	Deallocate curFiles

	ALTER DATABASE Current
	SET RECOVERY FULL; 
End
Go
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	2279 by Mahfuz
------------------------------------------------------------------------------------------------------------------------
Go

Go
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Mahfuz	On 15 Nov 2023
-- TFS#	3556
-- Description of change
-- Added Polyps details - Paris classifications etc not showing in Reports - South Tyneside V2
------------------------------------------------------------------------------------------------------------------------
Go

EXEC DropIfExist 'sites_summary_update','S';
GO
CREATE PROCEDURE [dbo].[sites_summary_update]
(
	@SiteId INT,
	@RefreshReport BIT = 1
)
AS
/*
-- Update History:
-- 10 Nov 2023		MH		replaced table reference ERS_ColonAbnoLesions with ERS_CommonAbnoLesions	TFS #3556
-- 15 Nov 2023		MH/Andrea		after finding the sp could updated from older version - the script has been taken from release 2_23_05_03 and then added some required refreshsummary works done by Steve, Polyp details are fixed here for Colon,Gastro etc
--							
*/
SET NOCOUNT ON

DECLARE @TrustId int
SELECT @TrustId = oh.TrustId
FROM ERS_Procedures p
JOIN ERS_Sites s ON s.ProcedureId = p.ProcedureId AND s.SiteId = @SiteId
JOIN ERS_OperatingHospitals oh ON oh.OperatingHospitalId = p.OperatingHospitalID

DECLARE @ReportSummaryRefresh int
SELECT @ReportSummaryRefresh = CAST([dbo].[fn_ShouldRefreshSummary](@TrustId) AS INT)

IF (@ReportSummaryRefresh + CAST(@RefreshReport AS INT) > 0)
BEGIN
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
			,@AbnormalProcedure BIT = 0


	BEGIN TRANSACTION

	BEGIN TRY

		SET	@summaryAbnormalities = ''
		SET	@summarySpecimens = ''
		SET	@summaryTherapeutics = ''
		SET	@summaryAbnormalitiesWithHyperLinks = ''
		SET	@summarySpecimensWithHyperLinks = ''
		SET	@summaryTherapeuticsWithHyperLinks = ''
		SET @siteIdStr = CONVERT(VARCHAR(10),@SiteId)
		SET @AbnormalProcedure = 0

		DECLARE @IsLymphNode VARCHAR(10) = 'False'

		SELECT @procId = p.ProcedureId,@procType = p.ProcedureType, @regionID = s.RegionId, @SiteNo = s.SiteNo, @AreaNo = ISNULL(AreaNo,0),
				@region = CASE WHEN s.SiteNo = -77 THEN						--SiteNo is set to -77 for sites By Distance (Col & Sig only)
							CONVERT(VARCHAR,XCoordinate) +  
								CASE WHEN YCoordinate IS NULL OR YCoordinate=0 THEN ' cm' 
								ELSE (' to ' + CONVERT(VARCHAR,YCoordinate) + ' cm' ) 
								END
						ELSE (SELECT r.Region FROM ERS_Regions r WHERE r.RegionId = s.RegionId)
						END
				,@IsLymphNode = CASE WHEN s.IsLymphNode = 1 THEN 'True' ELSE 'False' END
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
			,(@procType,	'ERS_CommonAbnoLesions',		'Lesions',			'Lesions')
			,(@procType,	'ERS_UpperGIAbnoPostSurgery',	'Post surgery',		'Post Surgery')
			,(@procType,	'ERS_CommonAbnoScaring',		'',					'Scarring/Stenosis')
			,(@procType,	'ERS_CommonAbnoTumour',			'',					'Tumour')
			,(@procType,	'ERS_UpperGIAbnoVarices',		CASE WHEN (Select isnull(Quantity, 0) from ERS_UpperGIAbnoVarices where SiteId = @SiteId) = 1 then 'Varix' ELSE 'Varices' END ,			'Varices')
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
			,(@procType,	'ERS_CommonAbnoLesions',			'Lesions',			'Lesions')
			,(@procType,	'ERS_ColonAbnoTumour',			'Tumour',			'Tumour')
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
			(@procType,		'ERS_UpperGIAbnoAchalasia',		'Achalasia',		'Achalasia')
			,(@procType,	'ERS_UpperGIAbnoBarrett',		'',					'Barretts Epithelium')
			,(@procType,	'ERS_UpperGIAbnoDeformity',		'Deformity',		'Deformity')
			,(@procType,	'ERS_CommonAbnoAtrophic',		'Atrophic duodenum','Atrophic Duodenum')
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
			,(@procType,	'ERS_UpperGIAbnoGastricUlcer',	'Gastric ulcer',	'Gastric Ulcer')
			,(@procType,	'ERS_UpperGIAbnoVarices',		CASE WHEN (Select isnull(Quantity, 0) from ERS_UpperGIAbnoVarices where SiteId = @SiteId) = 1 then 'Varix' ELSE 'Varices' END ,			'Varices')
			,(@procType,	'ERS_UpperGIAbnoGastritis',		'Gastritis',		'Gastritis')
			,(@procType,	'ERS_UpperGIAbnoHiatusHernia',	'Hiatus hernia',	'Hiatus Hernia')
			,(@procType,	'ERS_UpperGIAbnoLumen',			'Lumen',			'Lumen')
			,(@procType,	'ERS_UpperGIAbnoMalignancy',	'Malignancy',		'Malignancy')
			,(@procType,	'ERS_UpperGIAbnoMiscellaneous',	'',					'Miscellaneous')
			,(@procType,	'ERS_UpperGIAbnoOesophagitis',	'Oesophagitis',		'Oesophagitis')
			,(@procType,	'ERS_UpperGIAbnoPostSurgery',	'Post surgery',		'Post Surgery')
			,(@procType,	'ERS_CommonAbnoLesions',		'Lesions',			'Lesions')
		END
		ELSE IF @procType IN (9) --Retrograde
		BEGIN
			INSERT INTO #QueryDetails VALUES
			(@procType,		'ERS_ColonAbnoCalibre',			'Calibre',			'Calibre')
			,(@procType,	'ERS_ColonAbnoDiverticulum',	'Diverticulum',		'Diverticulum')
			,(@procType,	'ERS_ColonAbnoHaemorrhage',		'Haemorrhage',		'Haemorrhage')
			,(@procType,	'ERS_CommonAbnoLesions',			'Lesions',			'Lesions')
			,(@procType,	'ERS_ColonAbnoTumour',			'Tumour',			'Tumour')
			,(@procType,	'ERS_ColonAbnoMiscellaneous',	'',					'Miscellaneous')
			,(@procType,	'ERS_ColonAbnoMucosa',			'Mucosa',			'Mucosa')
			,(@procType,	'ERS_ColonAbnoperianallesions',	'Perianal lesions',	'Perianal Lesions')
			,(@procType,	'ERS_ColonAbnoVascularity',		'Vascularity',		'Vascularity')
			,(@procType,	'ERS_CommonAbnoDuodenalUlcer',	'',					CASE WHEN @region = 'Jejunum' THEN 'Jejunal Ulcer' WHEN @region = 'Ileum' THEN 'Ileal Ulcer' ELSE 'Duodenal Ulcer' END)
			,(@procType,	'ERS_CommonAbnoDuodenitis',		'',					CASE WHEN @region = 'Jejunum' THEN 'Jejunitis' WHEN @region = 'Ileum' THEN 'Ileitis' ELSE 'Duodenitis' END)
			,(@procType,	'ERS_CommonAbnoScaring',		'',					'Scarring/Stenosis')
			,(@procType,	'ERS_UpperGITherapeutics',			'Therapeutic procedure(s)',	'Therapeutic Procedures')
			,(@procType,	'ERS_UpperGISpecimens',			'Specimens taken',	'Specimens Taken')
		END
		ELSE IF @procType IN (13) --Cystoscopy
		BEGIN
			INSERT INTO #QueryDetails VALUES
			(@procType,		'ERS_CystoscopyAbnoBladder',	'Bladder',			'Bladder')
			,(@procType,	'ERS_CystoscopyAbnoProstate',	'Prostate',		    'Prostate')
			,(@procType,	'ERS_CystoscopyAbnoUrethra',	'Urethra',		    'Urethra')
			,(@procType,	'ERS_CystoscopyTherapeutics',	'Therapeutic procedure(s)',	'Therapeutic Procedures')
			,(@procType,	'ERS_CystoscopySpecimens',		'Specimens taken',	'Specimens Taken')
		END
		ELSE IF @procType IN (10,12) --Bronchoscopy, Thoracoscopy
		BEGIN
			INSERT INTO #QueryDetails
			VALUES (
				@procType
				,'ERS_BRTSpecimens'
				,'Specimens taken'
				,'Specimens Taken'
				),
				(
				@procType
				,'ERS_UpperGITherapeutics'
				,'Therapeutic procedure(s)'
				,'Therapeutic Procedures'
				),
				(
				@procType
				,'ERS_BRTAbnoDescriptions'
				,'<strong>Abnormalities</strong>'			
				,''
				)

		END	
		ELSE IF @procType IN (
				11
				) --EBUS			
				BEGIN
					INSERT INTO #QueryDetails
					VALUES (
						@procType
						,'ERS_BRTSpecimens'
						,'Specimens taken'
						,'Specimens Taken'
						),
						(
						@procType
						,'ERS_UpperGITherapeutics'
						,'Therapeutic procedure(s)'
						,'Therapeutic Procedures'
						)
			
					IF @IsLymphNode = 'True'
					BEGIN
						INSERT INTO #QueryDetails
						VALUES 
							(
							@procType
							,'ERS_EBUSAbnoDescriptions'
							,'<strong>Abnormalities</strong>'
							,'EBUS Abnormality Descriptions'
							)
					END
					ELSE
					BEGIN
						INSERT INTO #QueryDetails
						VALUES 
							(
							@procType
							,'ERS_BRTAbnoDescriptions'
							,'<strong>Abnormalities</strong>'
							,''
							)
					END
				END


		DECLARE qry_cursor CURSOR FOR 
		SELECT ProcType, TableName, AbnoNodeName, Identifier FROM #QueryDetails

		OPEN qry_cursor 
		FETCH NEXT FROM qry_cursor INTO @ProcType, @TableName, @AbnoNodeName, @Identifier

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @summaryWhole = ''
			SET @none = NULL
			SET @opDiv = '''<table><tr><td style="padding-left:25px;padding-right:50px; font-size:12px;"><span>'' + ' 
			SET @clDiv = ' + ''</span></td></tr></table>'''
			SET @indent = '&nbsp;- ';		SET @br = '<br />'
			SET @opBold = '<b>';			SET @clBold = '</b>'
			SET @fullStop = '.';			SET @colon = ': '
			SET @fldNone = 'None';			SET @emptyStr = ''
		
			IF @TableName = 'ERS_UpperGIAbnoLumen' SET @fldNone = 'NoBlood'
			ELSE IF @TableName = 'ERS_ERCPAbnoIntrahepatic' SET @fldNone = 'NormalIntraheptic'
			ELSE IF @TableName IN ('ERS_ERCPAbnoDuct', 'ERS_ERCPAbnoParenchyma', 'ERS_ERCPAbnoAppearance', 'ERS_ERCPAbnoDiverticulum','ERS_CystoscopyAbnoBladder','ERS_CystoscopyAbnoProstate','ERS_CystoscopyAbnoUrethra','ERS_EBUSAbnoDescriptions') SET @fldNone = 'Normal'
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
			IF @none = 0  and @TableName <> 'ERS_UpperGISpecimens' AND @AbnormalProcedure <> 1  SET @AbnormalProcedure = 1

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

		if exists(select 1 from ERS_CommonAbnoOther where SiteId = @SiteId)
		BEGIN
			SELECT @summaryAbnormalities = isnull(@summaryAbnormalities, '') + (SELECT STUFF((
																					SELECT ', ' + OA.Summary 
																					FROM ERS_OtherAbnormalities OA
																					JOIN ERS_CommonAbnoOther CAO ON OA.OtherId = CAO.OtherId
																					WHERE CAO.SiteId = @SiteId
																					FOR XML PATH('')), 1, 1, '') Code ),
				 @summaryAbnormalitiesWithHyperLinks = isnull(@summaryAbnormalitiesWithHyperLinks, '') + '<table><tr><td style="padding-right:50px;">- Other:' +
				 REPLACE(REPLACE(REPLACE(@htmlAnchorCode,'''{0}''','Other'),'{1}',
																					(SELECT STUFF((
																					SELECT ', ' + OA.Summary 
																					FROM ERS_OtherAbnormalities OA
																					JOIN ERS_CommonAbnoOther CAO ON OA.OtherId = CAO.OtherId
																					WHERE CAO.SiteId = @SiteId
																					FOR XML PATH('')), 1, 1, '') Code )), '''''', '''')
														+ '</td></tr></table>'
		END
		-- Update the current site's summary
		UPDATE ERS_Sites 
		SET	
			SiteSummary = @summaryAbnormalities,
			SiteSummarySpecimens = @summarySpecimens,
			SiteSummaryTherapeutics = @summaryTherapeutics,
			SiteSummaryWithLinks = @summaryAbnormalitiesWithHyperLinks,
			SiteSummarySpecimensWithLinks = @summarySpecimensWithHyperLinks,
			SiteSummaryTherapeuticsWithLinks = @summaryTherapeuticsWithHyperLinks,
			HasAbnormalities = @AbnormalProcedure
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
END
Go
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	3556 by Mahfuz
------------------------------------------------------------------------------------------------------------------------
Go
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 20.11023
-- TFS#	n/a
-- Description of change
-- Missing SP added
------------------------------------------------------------------------------------------------------------------------
GO


ALTER PROCEDURE [dbo].[ogd_PatientCopyTo_save]
(
	@ProcedureId INT,
	@CopyToPatient TINYINT,
	@CopyToPatientText NVARCHAR(500),
	@PatientNotCopiedReason NVARCHAR(500),
	@CopyToRefCon BIT,
	@CopyToRefConText NVARCHAR(500),
	@CopyToOther BIT,
	@CopyToOtherText NVARCHAR(500),
	@Salutation NVARCHAR(200),
	@CopyToGPEmailAddress BIT,
	@CopyToGPEmailAddressText VARCHAR(50) 
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
			CopyToGPEmailAddress,
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
			@CopyToGPEmailAddress,
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
			CopyToGPEmailAddress = @CopyToGPEmailAddress,
			WhenUpdated = GETDATE()
		WHERE 
			ProcedureId = @ProcedureId
	END

	------------------------------------------------
	--UPDATE GP/Practice combination email address--
	------------------------------------------------
	UPDATE pracLink
	SET
		pracLink.EmailAddress = @CopyToGPEmailAddressText		
	FROM
		dbo.ERS_Procedures AS procs
		INNER JOIN dbo.ERS_Patients AS pats
			ON pats.PatientId = procs.PatientId
		INNER JOIN dbo.ERS_Practices_Link AS pracLink
			ON praclink.GPId = pats.RegGpId AND praclink.PracticeId = pats.RegGpPracticeId
	WHERE
		procs.ProcedureId = @ProcedureId		

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




------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------

GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 08.12.23
-- TFS#	n/a
-- Description of change
-- scheduler transformation 
------------------------------------------------------------------------------------------------------------------------
GO

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER procedure [dbo].[sys_get_list_slots]
(
	@ListRulesId INT
)    
as
select * from ERS_SCH_ListSlots
where ListRulesId = @ListRulesId AND Active = 1
GO

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROCEDURE [dbo].[sys_transformed_diary_add]
(
	@DiaryId INT,
	@Subject VARCHAR(500), 
	@DiaryStart DATETIME, 
	@DiaryEnd DATETIME, 
	@RoomID INT, 
	@UserID INT, 
	@RecurrenceFrequency VARCHAR(500), 
	@RecurrenceCount INT, 
	@RecurrenceParentID int, 
	@ListRulesId int,
	@Description varchar(500),
	@OperatingHospitalId INT,
	@Training bit,
	@ListConsultant int,
	@ListGenderId int,
	@IsGI BIT,
	@ListNotes VARCHAR(max),
	@Add BIT
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	--create copy of list rules
	INSERT INTO dbo.ERS_SCH_ListRules
	(
	    Points,
	    PointMins,
	    Endoscopist,
	    ListName,
	    GIProcedure,
	    Training,
	    StartTime,
	    Suppressed,
	    OperatingHospitalId,
	    NonGIProcedureTypeId,
	    NonGIProcedureMinutesPerPoint,
	    NonGIDiagnosticCallInTime,
	    NonGIDiagnosticProcedurePoints,
	    NonGITherapeuticCallInTime,
	    NonGITherapeuticProcedurePoints,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ListConsultantId,
	    TotalMins,
	    IsTemplate,
	    GenderId
	)
	SELECT 
		Points,
	    PointMins,
	    Endoscopist,
	    ListName,
	    GIProcedure,
	    Training,
	    StartTime,
	    Suppressed,
	    OperatingHospitalId,
	    NonGIProcedureTypeId,
	    NonGIProcedureMinutesPerPoint,
	    NonGIDiagnosticCallInTime,
	    NonGIDiagnosticProcedurePoints,
	    NonGITherapeuticCallInTime,
	    NonGITherapeuticProcedurePoints,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ListConsultantId,
	    TotalMins,
	    IsTemplate,
	    GenderId
	FROM dbo.ERS_SCH_ListRules WHERE ListRulesId = @ListRulesId

	--retrieve list rules id
	DECLARE @NewListRulesId INT = SCOPE_IDENTITY()

	--create copy of list slots
	INSERT INTO dbo.ERS_SCH_ListSlots
	(
	    ListRulesId,
	    SlotId,
	    ProcedureTypeId,
	    StartTime,
	    EndTime,
	    Suppressed,
	    OperatingHospitalId,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ParentListSlotId,
	    SlotMinutes,
	    Active,
	    DeactivatedDateTime,
	    Points,
	    Locked,
	    IsOverBookedSlot
	)
	SELECT 
		@NewListRulesId,
	    SlotId,
	    ProcedureTypeId,
	    StartTime,
	    EndTime,
	    Suppressed,
	    OperatingHospitalId,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ParentListSlotId,
	    SlotMinutes,
	    Active,
	    DeactivatedDateTime,
	    Points,
	    Locked,
	    IsOverBookedSlot
	FROM dbo.ERS_SCH_ListSlots
	WHERE ListRulesId = @ListRulesId AND Active = 1 AND Suppressed = 0

	IF @Add = 1 
	BEGIN
		
		
		INSERT INTO [ERS_SCH_DiaryPages] 
		([Subject], [DiaryStart], [DiaryEnd], [RoomID], [UserID], [ListRulesId], [OperatingHospitalId], [RecurrenceFrequency], [RecurrenceCount], [RecurrenceParentID], [WhenCreated], [Training], [ListConsultantId], ListGenderId, IsGI, Notes) 
		SELECT ListName, @DiaryStart, @DiaryEnd, @RoomId, @UserID, @NewListRulesId, @OperatingHospitalId, @RecurrenceFrequency, @RecurrenceCount, @RecurrenceParentID, GETDATE(), Training, @ListConsultant, @ListGenderId, @IsGI, @ListNotes  
		FROM dbo.ERS_SCH_ListRules WHERE ListRulesId = @ListRulesId
		
		DECLARE @NewDiaryId INT = (SELECT SCOPE_IDENTITY ())

		UPDATE ERS_SCH_DiaryPages
		SET DiaryStart = dateadd(year,-100, DiaryStart),
			DiaryEnd = DATEADD(year, -100, DiaryEnd)
		WHERE DiaryId = @DiaryId and datediff(year, diarystart, getdate())< 50

		SELECT @NewDiaryId DiaryId, @NewListRulesId ListRulesId
	END
	ELSE
	BEGIN
		UPDATE ERS_SCH_DiaryPages
		SET ListGenderId = @ListGenderId,
			Notes = @ListNotes,
			IsGI = @IsGI,
			ListRulesId = @NewListRulesId,
			Suppressed = 0,
			SuppressedFromDate = NULL
		WHERE DiaryId = @DiaryId

		SELECT @DiaryId DiaryId, @NewListRulesId ListRulesId
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

EXEC dbo.DropIfExist @ObjectName = 'sys_get_all_diaries',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE procedure sys_get_all_diaries
as
begin
	select * from ERS_SCH_DiaryPages WHERE DiaryStart > dateadd(year,-50, GETDATE())
end
GO



EXEC dbo.DropIfExist @ObjectName = 'sys_get_diary',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[sys_get_diary]
(
	@DiaryId int
)
AS
BEGIN
	SELECT * FROM ERS_SCH_DiaryPages WHERE DiaryId = @DiaryId
END
GO



ALTER PROCEDURE [dbo].[sch_add_overbook_slot]
(		
	@DiaryId INT,
	@Points DECIMAL(18,2),
	@AppointmentId INT
)
AS
BEGIN
	DECLARE @OperatingHospitalId INT, @ListRulesId INT, @ListSlotId INT

	--get the list rules id for the diary 
	SELECT @OperatingHospitalId = OperatingHospitalId, @ListRulesId = ListRulesId FROM dbo.ERS_SCH_DiaryPages WHERE DiaryId = @DiaryId

	--insert new list slot
	INSERT INTO ERS_SCH_ListSlots (ListRulesId, SlotId, ProcedureTypeId, OperatingHospitalId, SlotMinutes, Points, IsOverBookedSlot)
	SELECT  @ListRulesId, PriorityiD, 0, @OperatingHospitalId, CONVERT(INT, a.AppointmentDuration), @Points, 1
	FROM dbo.ERS_Appointments a WHERE a.AppointmentId = @AppointmentId

	SELECT @ListSlotId = SCOPE_IDENTITY()

	--Update Appointment
	UPDATE dbo.ERS_Appointments SET ListSlotId = @ListSlotId WHERE AppointmentId = @AppointmentId
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[sch_add_overbook_slot]
(		
	@DiaryId INT,
	@Points DECIMAL(18,2),
	@AppointmentId INT
)
AS
BEGIN
	DECLARE @OperatingHospitalId INT, @ListRulesId INT, @ListSlotId INT

	--get the list rules id for the diary 
	SELECT @OperatingHospitalId = OperatingHospitalId, @ListRulesId = ListRulesId FROM dbo.ERS_SCH_DiaryPages WHERE DiaryId = @DiaryId

	--insert new list slot
	INSERT INTO ERS_SCH_ListSlots (ListRulesId, SlotId, ProcedureTypeId, OperatingHospitalId, SlotMinutes, Points, IsOverBookedSlot)
	SELECT  @ListRulesId, PriorityiD, 0, @OperatingHospitalId, CONVERT(INT, a.AppointmentDuration), @Points, 1
	FROM dbo.ERS_Appointments a WHERE a.AppointmentId = @AppointmentId

	SELECT @ListSlotId = SCOPE_IDENTITY()

	--Update Appointment
	UPDATE dbo.ERS_Appointments SET ListSlotId = @ListSlotId, @DiaryId = @DiaryId WHERE AppointmentId = @AppointmentId
END






GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------

GO


------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea Johnson 01.11.23
-- TFS#	
-- Description of change
-- Validation check to ensure all endoscopists on a procedure enter a ja manouver and extent result
------------------------------------------------------------------------------------------------------------------------
GO

ALTER PROCEDURE [dbo].[check_requiredfields]
(
	@ProcedureId INT,
	@PageId INT
)
AS
BEGIN
	DECLARE @ProcedureTypeId INT, @ProcedureDNA INT, @UISectionId INT, @SectionName VARCHAR(50), @SectionPageId INT, @SectionControl VARCHAR(50), @IncompleteSections VARCHAR(MAX) = '', @ProcedureModifiedDate DATETIME, @ProcedureCompleted BIT
	SELECT @ProcedureTypeId = ProcedureType, @ProcedureDNA = ISNULL(DNA,0), @ProcedureModifiedDate = ModifiedOn, @ProcedureCompleted = ISNULL(ProcedureCompleted,0) FROM ERS_Procedures WHERE ProcedureId = @ProcedureId

	DECLARE @ProcedureEndoCount INT
	IF EXISTS (SELECT 1 FROM ERS_Procedures WHERE ProcedureId = @ProcedureId AND Endoscopist2 IS NOT NULL)
		SET @ProcedureEndoCount = 2
	ELSE
		SET @ProcedureEndoCount = 1

	IF NOT @ProcedureCompleted = 1 AND @ProcedureModifiedDate >= (SELECT TOP 1 InstallDate
																FROM DBVersion
																WHERE SUBSTRING(VersionNum,1,1) = '2'
																ORDER BY InstallDate ASC)

	

	BEGIN
	IF @ProcedureTypeId NOT IN (10,11,13) 
		BEGIN
		
	
			DECLARE cur CURSOR FOR (SELECT us.UISectionId, SectionName, PageId, SectionControl
									FROM UI_sections us
										LEFT JOIN UI_SectionProcedureTypes spt ON spt.UISectionId = us.UISectionId
									WHERE NEDRequired = 1 
									AND ISNULL(ProcedureTypeId,0) IN (0,@ProcedureTypeId) 
									AND DNAExempt = CASE WHEN @ProcedureDNA > 0 THEN 0 ELSE DNAExempt END 
									AND (PageId = @PageId OR @PageId = 0))
								
			SET @IncompleteSections = ''
			OPEN cur
			FETCH NEXT FROM cur INTO @UISectionId, @SectionName, @SectionPageId, @SectionControl

			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM dbo.ERS_ProcedureSummary WHERE ProcedureId = @ProcedureId AND SectionId = @UISectionId)
				BEGIN
					SET @IncompleteSections = @IncompleteSections + '&bull;' + @SectionName + '<br />'
		--			SET @IncompleteSections = @IncompleteSections + '&bull;<a href="/' + CASE @SectionPageId WHEN 1 THEN 'PreProcedure.aspx' WHEN 2 THEN 'Procedure.aspx' WHEN 3 THEN 'PostProcedure.aspx' END  +'#' + REPLACE(@SectionName, ' ','') + '">' + @SectionName + '</a><br />'
				END
		
				
				IF LOWER(@SectionName) = 'jmanoevre' AND CHARINDEX('jmanoevre',@IncompleteSections) = 0 /*no point validating if its not complete*/
				BEGIN
					IF (SELECT COUNT(*) FROM dbo.ERS_ProcedureSummary WHERE ProcedureId = @ProcedureId AND SectionId = @UISectionId) < @ProcedureEndoCount
					BEGIN
						SET @IncompleteSections = @IncompleteSections + '&bull;' + @SectionName + ' is incomplete. Both ensocopists must record their result<br />'
					END
				END

				IF LOWER(@SectionName) = 'procedure timing' AND CHARINDEX('',@IncompleteSections) = 0 /*no point validating if its not complete*/
				BEGIN
					DECLARE @StartTime DATETIME, @EndTime DATETIME
					SELECT @StartTime= StartDateTime, @EndTime = EndDateTime FROM ERS_Procedures WHERE ProcedureId= @ProcedureId
					IF @StartTime > @EndTime
					BEGIN
						SET @IncompleteSections = @IncompleteSections + '&bull;' + @SectionName + ' is incorrect. Check start is not after end date/time<br />'
					END
				END

				IF LOWER(@SectionName) = 'indications'
				BEGIN
					--'check sub indications'
					IF (SELECT COUNT(*) 
					FROM 
						(SELECT CASE WHEN ei.SubIndicationParent = 0 THEN 1 WHEN ei.SubIndicationParent = 1 AND EXISTS (SELECT 1 FROM dbo.ERS_ProcedureSubIndications epsi WHERE epsi.ProcedureId = ep.ProcedureId) THEN 1 ELSE 0 END AS 'Complete'
						FROM dbo.ERS_ProcedureIndications ep
							INNER JOIN dbo.ERS_Indications ei ON ei.UniqueId = ep.IndicationId
						WHERE procedureid = @ProcedureId) inds
						WHERE inds.Complete = 0) > 0
					BEGIN
						SET @IncompleteSections = @IncompleteSections + '&bull;Subindications<br />'
					END
				END

				IF LOWER(@SectionName) = 'rx'
				BEGIN
					--check if anti coag has been marked as yes.. if so perform checks 
					DECLARE @AntiCoagDrugs BIT
					SELECT @AntiCoagDrugs = AntiCoagDrugs FROM ERS_Procedures WHERE ProcedureId = @ProcedureId
					IF @AntiCoagDrugs = 1 
					BEGIN
						IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureSummary WHERE ProcedureId = @ProcedureId AND SectionId = @UISectionId)
						BEGIN
							SET @IncompleteSections = REVERSE(SUBSTRING(REVERSE(@IncompleteSections), CHARINDEX('<br />', REVERSE(@IncompleteSections)) + 7, LEN(@IncompleteSections))) + '<small><em> - RX drugs must be complete for patients that are taking Anti-coag or Anti-platelet Medication</em></small><br />'
							SELECT @IncompleteSections
						END
					END
				END

				FETCH NEXT FROM cur INTO @UISectionId, @SectionName, @SectionPageId, @SectionControl
			END

			CLOSE cur
			DEALLOCATE cur
	
			--check for RX completion if anti coag selected


			--check for any unanswered mandatory pathway plan questions
			IF (SELECT COUNT(*)
				FROM dbo.ERS_PathwayPlanQuestions eppq
					LEFT JOIN ERS_ProcedurePathwayPlanAnswers pa ON pa.QuestionId = eppq.QuestionId AND pa.ProcedureId = @ProcedureId
				WHERE eppq.Mandatory = 1 AND ProcedureQuestionAnswerId IS NULL AND eppq.OrderById <> 99999 AND Suppressed =0) > 0
				AND @PageId IN (0,3)
			BEGIN
				SET @IncompleteSections = @IncompleteSections + '&bull;Pathway Plan<br />'
			END
		END

		--All required fields entered, update flag ProcedureCompleted
		IF @PageId = 0 AND @IncompleteSections	 = ''
		BEGIN
			IF (SELECT ISNULL(ProcedureCompleted,0) FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)  = 0
			BEGIN
				UPDATE ERS_Procedures SET ProcedureCompleted = 1 WHERE ProcedureId = @ProcedureId
			END
		END
		ELSE IF @IncompleteSections <> ''
		BEGIN
				UPDATE ERS_Procedures SET ProcedureCompleted = 0 WHERE ProcedureId = @ProcedureId
		END

		SELECT @IncompleteSections
	END
END
GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 11.01.24
-- TFS#	
-- Description of change
-- Changes so NED sender only gets V2 reports
------------------------------------------------------------------------------------------------------------------------
GO


ALTER PROCEDURE [dbo].[usp_NEDI2_Get_Unsent_Procedures]
AS
BEGIN
	select prc.ProcedureId, prc.operatingHospitalId, ISNULL((SELECT TOP 1 ISNULL(ServiceId,'') FROM dbo.ERS_NedI2FilesLog enil WHERE enil.ProcedureID = prc.ProcedureId AND [Status] = 5),'') AS ServiceId
	From dbo.ERS_Procedures prc 
	INNER JOIN ERS_ProcedureTypes pt ON pt.ProcedureTypeId = prc.ProcedureType, ERS_SystemConfig cnfg 
		--LEFT JOIN (SELECT enil.ProcedureId, ServiceId FROM dbo.ERS_NedI2FilesLog enil WHERE [STATUS] = 5) fp ON fp.ProcedureId = ProcedureId
	WHERE prc.CreatedOn !< (SELECT TOP 1 v.InstallDate FROM dbo.DBVersion v WHERE v.VersionNum LIKE '2.%') AND (ProcedureCompleted = 1 and cnfg.NEDEnabled = 1 and prc.operatingHospitalId = cnfg.operatingHospitalId AND pt.NedExportRequired = 1 AND ISNULL(prc.NEDExported,0) = 0)

END

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO



ALTER procedure [dbo].[sys_get_list_slots]
(
	@ListRulesId INT
)    
as
select * from ERS_SCH_ListSlots
where ListRulesId = @ListRulesId AND Active = 1
GO

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROCEDURE [dbo].[sys_transformed_diary_add]
(
	@DiaryId INT,
	@Subject VARCHAR(500), 
	@DiaryStart DATETIME, 
	@DiaryEnd DATETIME, 
	@RoomID INT, 
	@UserID INT, 
	@RecurrenceFrequency VARCHAR(500), 
	@RecurrenceCount INT, 
	@RecurrenceParentID int, 
	@ListRulesId int,
	@Description varchar(500),
	@OperatingHospitalId INT,
	@Training bit,
	@ListConsultant int,
	@ListGenderId int,
	@IsGI BIT,
	@ListNotes VARCHAR(max),
	@Add BIT
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	--create copy of list rules
	INSERT INTO dbo.ERS_SCH_ListRules
	(
	    Points,
	    PointMins,
	    Endoscopist,
	    ListName,
	    GIProcedure,
	    Training,
	    StartTime,
	    Suppressed,
	    OperatingHospitalId,
	    NonGIProcedureTypeId,
	    NonGIProcedureMinutesPerPoint,
	    NonGIDiagnosticCallInTime,
	    NonGIDiagnosticProcedurePoints,
	    NonGITherapeuticCallInTime,
	    NonGITherapeuticProcedurePoints,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ListConsultantId,
	    TotalMins,
	    IsTemplate,
	    GenderId
	)
	SELECT 
		Points,
	    PointMins,
	    Endoscopist,
	    ListName,
	    GIProcedure,
	    Training,
	    StartTime,
	    Suppressed,
	    OperatingHospitalId,
	    NonGIProcedureTypeId,
	    NonGIProcedureMinutesPerPoint,
	    NonGIDiagnosticCallInTime,
	    NonGIDiagnosticProcedurePoints,
	    NonGITherapeuticCallInTime,
	    NonGITherapeuticProcedurePoints,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ListConsultantId,
	    TotalMins,
	    IsTemplate,
	    GenderId
	FROM dbo.ERS_SCH_ListRules WHERE ListRulesId = @ListRulesId

	--retrieve list rules id
	DECLARE @NewListRulesId INT = SCOPE_IDENTITY()

	--create copy of list slots
	INSERT INTO dbo.ERS_SCH_ListSlots
	(
	    ListRulesId,
	    SlotId,
	    ProcedureTypeId,
	    StartTime,
	    EndTime,
	    Suppressed,
	    OperatingHospitalId,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ParentListSlotId,
	    SlotMinutes,
	    Active,
	    DeactivatedDateTime,
	    Points,
	    Locked,
	    IsOverBookedSlot
	)
	SELECT 
		@NewListRulesId,
	    SlotId,
	    ProcedureTypeId,
	    StartTime,
	    EndTime,
	    Suppressed,
	    OperatingHospitalId,
	    WhoUpdatedId,
	    WhoCreatedId,
	    WhenCreated,
	    WhenUpdated,
	    ParentListSlotId,
	    SlotMinutes,
	    Active,
	    DeactivatedDateTime,
	    Points,
	    Locked,
	    IsOverBookedSlot
	FROM dbo.ERS_SCH_ListSlots
	WHERE ListRulesId = @ListRulesId AND Active = 1 AND Suppressed = 0

	IF @Add = 1 
	BEGIN
		
		
		INSERT INTO [ERS_SCH_DiaryPages] 
		([Subject], [DiaryStart], [DiaryEnd], [RoomID], [UserID], [ListRulesId], [OperatingHospitalId], [RecurrenceFrequency], [RecurrenceCount], [RecurrenceParentID], [WhenCreated], [Training], [ListConsultantId], ListGenderId, IsGI, Notes) 
		SELECT ListName, @DiaryStart, @DiaryEnd, @RoomId, @UserID, @NewListRulesId, @OperatingHospitalId, @RecurrenceFrequency, @RecurrenceCount, @RecurrenceParentID, GETDATE(), Training, @ListConsultant, @ListGenderId, @IsGI, @ListNotes  
		FROM dbo.ERS_SCH_ListRules WHERE ListRulesId = @ListRulesId
		
		DECLARE @NewDiaryId INT = (SELECT SCOPE_IDENTITY ())

		UPDATE ERS_SCH_DiaryPages
		SET DiaryStart = dateadd(year,-100, DiaryStart),
			DiaryEnd = DATEADD(year, -100, DiaryEnd)
		WHERE DiaryId = @DiaryId and datediff(year, diarystart, getdate())< 50

		SELECT @NewDiaryId DiaryId, @NewListRulesId ListRulesId
	END
	ELSE
	BEGIN
		UPDATE ERS_SCH_DiaryPages
		SET ListGenderId = @ListGenderId,
			Notes = @ListNotes,
			IsGI = @IsGI,
			ListRulesId = @NewListRulesId,
			Suppressed = 0,
			SuppressedFromDate = NULL
		WHERE DiaryId = @DiaryId

		SELECT @DiaryId DiaryId, @NewListRulesId ListRulesId
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

EXEC dbo.DropIfExist @ObjectName = 'sys_get_all_diaries',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE procedure sys_get_all_diaries
as
begin
	select * from ERS_SCH_DiaryPages WHERE DiaryStart > dateadd(year,-50, GETDATE())
end
GO



EXEC dbo.DropIfExist @ObjectName = 'sys_get_diary',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[sys_get_diary]
(
	@DiaryId int
)
AS
BEGIN
	SELECT * FROM ERS_SCH_DiaryPages WHERE DiaryId = @DiaryId
END
GO



ALTER PROCEDURE [dbo].[sch_add_overbook_slot]
(		
	@DiaryId INT,
	@Points DECIMAL(18,2),
	@AppointmentId INT
)
AS
BEGIN
	DECLARE @OperatingHospitalId INT, @ListRulesId INT, @ListSlotId INT

	--get the list rules id for the diary 
	SELECT @OperatingHospitalId = OperatingHospitalId, @ListRulesId = ListRulesId FROM dbo.ERS_SCH_DiaryPages WHERE DiaryId = @DiaryId

	--insert new list slot
	INSERT INTO ERS_SCH_ListSlots (ListRulesId, SlotId, ProcedureTypeId, OperatingHospitalId, SlotMinutes, Points, IsOverBookedSlot)
	SELECT  @ListRulesId, PriorityiD, 0, @OperatingHospitalId, CONVERT(INT, a.AppointmentDuration), @Points, 1
	FROM dbo.ERS_Appointments a WHERE a.AppointmentId = @AppointmentId

	SELECT @ListSlotId = SCOPE_IDENTITY()

	--Update Appointment
	UPDATE dbo.ERS_Appointments SET ListSlotId = @ListSlotId WHERE AppointmentId = @AppointmentId
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[sch_add_overbook_slot]
(		
	@DiaryId INT,
	@Points DECIMAL(18,2),
	@AppointmentId INT
)
AS
BEGIN
	DECLARE @OperatingHospitalId INT, @ListRulesId INT, @ListSlotId INT

	--get the list rules id for the diary 
	SELECT @OperatingHospitalId = OperatingHospitalId, @ListRulesId = ListRulesId FROM dbo.ERS_SCH_DiaryPages WHERE DiaryId = @DiaryId

	--insert new list slot
	INSERT INTO ERS_SCH_ListSlots (ListRulesId, SlotId, ProcedureTypeId, OperatingHospitalId, SlotMinutes, Points, IsOverBookedSlot)
	SELECT  @ListRulesId, PriorityiD, 0, @OperatingHospitalId, CONVERT(INT, a.AppointmentDuration), @Points, 1
	FROM dbo.ERS_Appointments a WHERE a.AppointmentId = @AppointmentId

	SELECT @ListSlotId = SCOPE_IDENTITY()

	--Update Appointment
	UPDATE dbo.ERS_Appointments SET ListSlotId = @ListSlotId, @DiaryId = @DiaryId WHERE AppointmentId = @AppointmentId
END

