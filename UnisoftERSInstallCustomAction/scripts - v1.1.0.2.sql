

EXEC DropIfExist 'abnormalities_achalasia_summary_update','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_achalasia_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000),
		@None BIT,
		@Probable BIT,
		@Confirmed BIT,
		@LeadingToPerforation BIT

	SELECT 
		@None=[None],
		@Probable=Probable,
		@Confirmed=Confirmed,
		@LeadingToPerforation=DilationLeadingToPerforation
	FROM
		ERS_UpperGIAbnoAchalasia
	WHERE
		SiteId = @SiteId

	SET @Summary = ''

	IF @None = 1
		SET @summary = @summary + 'No achalasia'
	
	ELSE 
	BEGIN
		IF @Probable = 1 SET @summary = 'probable'
		ELSE IF @Confirmed = 1 SET @summary = 'confirmed'
		
		IF @LeadingToPerforation = 1 SET @summary = @summary + ' dilation leading to perforation'
	END
	--PRINT @summary
	-- Finally update the summary in abnormalities table
	UPDATE ERS_UpperGIAbnoAchalasia
	set Summary = (SELECT isnull(@summary, '') as [text()] FOR XML PATH('')) 
	WHERE SiteId = @siteId


GO


-------------------------------------------------------------------------------------------------------

GO
EXEC DropIfExist 'abnormalities_appearance_summary_update','S';
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

-------------------------------------------------------------------------------------------------------------------
GO
EXEC DropIfExist 'abnormalities_deformity_summary_update','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_deformity_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000),
		@None BIT,
		@DeformityType SMALLINT,
		@DeformityOther VARCHAR(200)

	SELECT 
		@None=[None],
		@DeformityType=DeformityType,
		@DeformityOther=DeformityOther
	FROM
		ERS_UpperGIAbnoDeformity
	WHERE
		SiteId = @SiteId

	SET @Summary = ''

	IF @None = 1
		SET @summary = @summary + 'No deformity'
	
	ELSE IF @DeformityType > 0
	BEGIN
		IF @DeformityType = 1 SET @summary = 'extrinsic compression'
		ELSE IF @DeformityType = 2 SET @summary = 'cup and spill stomach'
		ELSE IF @DeformityType = 3 SET @summary = 'hourglass stomach'
		ELSE IF @DeformityType = 4 SET @summary = 'post operative stenosis'
		ELSE IF @DeformityType = 5 SET @summary = 'J-shaped stomach'
		ELSE IF @DeformityType = 6 SET @summary = 'submucosal tumour'
		ELSE IF @DeformityType = 7 
			IF @DeformityOther <> '' SET @summary = (SELECT isnull(@DeformityOther, '') as [text()] FOR XML PATH(''))  
	END
	--PRINT @summary

	-- Finally update the summary in abnormalities table
	UPDATE ERS_UpperGIAbnoDeformity
	SET Summary = @Summary 
	WHERE SiteId = @siteId

-----------------------------------------------------------------------------------------------------------------
GO
EXEC DropIfExist 'abnormalities_diverticulum_summary_update','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_diverticulum_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON
	
		DECLARE
		@summary VARCHAR(1000),
		@temp VARCHAR(50),
		@None BIT,
		@Pseudodiverticulum BIT,
		@Congenital1stPart BIT,
		@Congenital2ndPart BIT,
		@Other BIT,
		@OtherDesc VARCHAR(150)

	SELECT 
		@None=[None],
		@Pseudodiverticulum = Pseudodiverticulum,
		@Congenital1stPart = Congenital1stPart,
		@Congenital2ndPart = Congenital2ndPart,
		@Other = Other,
		@OtherDesc = (SELECT isnull(OtherDesc, '') as [text()] FOR XML PATH(''))  
	FROM
		ERS_CommonAbnoDiverticulum
	WHERE
		SiteId = @SiteId

	SET @Summary = ''
	SET @temp = ''

	IF @None = 1
		SET @summary = @summary + 'No Diverticula'
	
	ELSE IF @Pseudodiverticulum = 1 OR @Congenital1stPart = 1 OR @Congenital2ndPart = 1 OR @Other = 1
	BEGIN

		DECLARE @tmpDiv TABLE(Val VARCHAR(MAX))
		DECLARE @XMLlist XML

		IF @Pseudodiverticulum = 1
		BEGIN
			INSERT INTO @tmpDiv (Val) VALUES('pseudodiverticulum')
		END

		IF @Congenital1stPart = 1
		BEGIN
			INSERT INTO @tmpDiv (Val) VALUES('1st part')
		END

		IF @Congenital2ndPart = 1
		BEGIN
			INSERT INTO @tmpDiv (Val) VALUES('2nd part')
		END

		IF @Other = 1
		BEGIN
			IF LTRIM(RTRIM(ISNULL(@OtherDesc,''))) = ''
				INSERT INTO @tmpDiv (Val) VALUES('other')
			ELSE
				INSERT INTO @tmpDiv (Val) VALUES(@OtherDesc)
		END
					
		IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
		BEGIN
			SET @XMLlist = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
			SET @summary = dbo.fnBuildString(@XMLlist)
		END
	END


	-- Finally update the summary in abnormalities table
	UPDATE ERS_CommonAbnoDiverticulum
	SET Summary = @Summary 
	WHERE SiteId = @siteId

---------------------------------------------------------------------------------------------------
GO
EXEC DropIfExist 'abnormalities_gastric_ulcer_summary_update','S';
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
	
	ELSE IF @None = 1
		SET @Summary = @Summary + 'No gastric ulcer'
	
	ELSE IF @Ulcer = 1 
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
			SELECT @Summary = summaryitem
			FROM @SummaryItems
		END
	END
	
	-- Finally update the summary in abnormalities table	
	UPDATE ERS_UpperGIAbnoGastricUlcer 
	SET Summary = RTRIM(@Summary)
	WHERE SiteId = @siteId

-------------------------------------------------------------------------------------------------------------
GO
EXEC DropIfExist 'abnormalities_mediastinal_summary_update','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_mediastinal_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000),
		@None BIT,
		@MediastinalType SMALLINT,
		@NodeStation VARCHAR(20)

	SELECT 
		@None=[None],
		@MediastinalType= MediastinalType,
		@NodeStation=(SELECT isnull(NodeStation, '') as [text()] FOR XML PATH(''))
	FROM
		ERS_EUSAbnoMediastinal
	WHERE
		SiteId = @SiteId

	SET @Summary = ''

	IF @None = 1
	BEGIN
		DECLARE @procType INT

		SELECT @procType = p.ProcedureType
		FROM ERS_Sites s 
		JOIN ERS_Procedures p ON s.ProcedureId = p.ProcedureId
		WHERE SiteId = @SiteId

		IF @procType = 6		SET @summary = @summary + 'Mediastinal normal'	--EUS OGD
		ELSE IF @procType = 7	SET @summary = @summary + 'Site normal'			--EUS HPB
	END



	ELSE IF @MediastinalType > 0
	BEGIN
		IF @MediastinalType = 1 SET @summary = 'mass'
		ELSE IF @MediastinalType = 2 
		BEGIN
			SET @summary = 'lymph node'
			IF ISNULL(@NodeStation,'') <> '' SET @summary = @summary + ' (station ' + @NodeStation + ')'
		END
	END
	--PRINT @summary

	-- Finally update the summary in abnormalities table
	UPDATE ERS_EUSAbnoMediastinal
	SET Summary = @Summary 
	WHERE SiteId = @siteId

---------------------------------------------------------------------------------------------------------------------
GO
EXEC DropIfExist 'abnormalities_miscellaneous_summary_update','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_miscellaneous_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@Summary VARCHAR(1200),
		@temp VARCHAR(50),
		@OesoUlcer BIT,
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
		@MiscOther NVARCHAR(150),
		@IsLAClassification BIT,
		@InletPatch BIT,
		@InletPatchMultiple BIT,
		@InletPatchQty SMALLINT

	SELECT 
		@None				=	[None],
		@Web				=	Web,
		@Mallory			=	Mallory,
		@SchatzkiRing		=	SchatzkiRing,
		@FoodResidue		=	FoodResidue,
		@Foreignbody 		= 	Foreignbody,
		@ExtrinsicCompression	=	ExtrinsicCompression,
		@Diverticulum		=	Diverticulum,
		@DivertMultiple		=	DivertMultiple,
		@DivertQty			=	DivertQty,
		@Pharyngeal			=	Pharyngeal,
		@DiffuseIntramural	=	DiffuseIntramural,
		@TractionType		=	TractionType,
		@PulsionType		=	PulsionType,
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
		@StrictureBenignType	=	StrictureBenignType,
		@StrictureBeginning		=	StrictureBeginning,
		@StrictureLength		=	StrictureLength,
		@StricturePerforation	=	StricturePerforation,
		@Tumour					=	Tumour,
		@TumourType				=	TumourType,
		@TumourProbably			=	TumourProbably,
		@TumourExophytic		=	TumourExophytic,
		@TumourBenignType		=	TumourBenignType,
		@TumourBenignTypeOther	=	(SELECT isnull(TumourBenignTypeOther, '') as [text()] FOR XML PATH('')),
		@TumourBeginning		=	TumourBeginning,
		@TumourLength			=	TumourLength,
		@MiscOther				=	MiscOther,
		@IsLAClassification		=	ISNULL(IsLAClassification,0),
		@InletPatch				=	InletPatch,
		@InletPatchMultiple		=	InletPatchMultiple,
		@InletPatchQty			=	InletPatchQty
	FROM
		ERS_UpperGIAbnoMiscellaneous
	WHERE
		SiteId = @SiteId

	SET @Summary = ''

	IF @None = 1
		SET @Summary = '' --@Summary + 'No varices'
	ELSE 
	BEGIN

		DECLARE @tmpMisc	TABLE(Val VARCHAR(MAX))
		DECLARE @tmpMiscTAR TABLE(Val VARCHAR(MAX))
		DECLARE @UlcerText VARCHAR(500)
		DECLARE @StrictText VARCHAR(500)
		DECLARE @TumourText VARCHAR(500)
		DECLARE @a VARCHAR(500) = ''
		DECLARE @XMLlist XML
		DECLARE @br VARCHAR(7) = '<br />'
		DECLARE @indent VARCHAR(10) = '&nbsp;- ';

		--This line will be ignored in funtion dbo.fnBuildString at the end
		INSERT INTO @tmpMisc (Val) VALUES('~~NoCommas~~')

		IF ISNULL(@Ulceration,0) = 1
		BEGIN
			IF @Ulceration = 1 SET @UlcerText = dbo.fnRepOesoUlcer(@SiteId)
			IF @UlcerText <> '' INSERT INTO @tmpMisc (Val) VALUES(@indent + dbo.fnFirstLetterUpper(RTRIM(LTRIM(@UlcerText))) + '.' + @br)
		END

		IF ISNULL(@Tumour,0) = 1
		BEGIN
			SET @TumourText = dbo.fnRepOesoTumour(@SiteId)
			IF @TumourText <> '' INSERT INTO @tmpMisc (Val) VALUES(@indent + dbo.fnFirstLetterUpper(RTRIM(LTRIM(@TumourText))) + '.' + @br)
		END

		IF ISNULL(@Stricture,0) = 1
		BEGIN
			SET @StrictText = dbo.fnRepOesoStricture(@SiteId)
			IF @StrictText <> '' INSERT INTO @tmpMisc (Val) VALUES(@indent + dbo.fnFirstLetterUpper(RTRIM(LTRIM(@StrictText))) + '.' + @br)
		END

		--IF ISNULL(@TumourText,'') <> '' AND ISNULL(@StrictText,'') <> '' 
		--	SET @a = @TumourText + '. <br />' + @StrictText
		--ELSE
		--SET @a = RTRIM(LTRIM(ISNULL(@TumourText,'') + ISNULL(@StrictText,'')))

		--IF @a <> '' INSERT INTO @tmpMisc (Val) VALUES(@a)

		IF @Web = 1				INSERT INTO @tmpMiscTAR (Val) VALUES('web')
		IF @Mallory = 1			INSERT INTO @tmpMiscTAR (Val) VALUES('Mallory-Weiss tear')
		IF @SchatzkiRing = 1	INSERT INTO @tmpMiscTAR (Val) VALUES('Schatzki ring')
		IF @ExtrinsicCompression = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('extrinsic compression')
		IF @FoodResidue = 1		INSERT INTO @tmpMiscTAR (Val) VALUES('food residue')
		IF @Foreignbody = 1		INSERT INTO @tmpMiscTAR (Val) VALUES('foreign body')
		IF @InletPatch = 1 
		BEGIN
			SET @a = ''
			IF @InletPatchMultiple = 1
				SET @a = 'inlet patch: multiple '
			ELSE IF ISNULL(@InletPatchQty,0) > 0
			BEGIN
				IF ISNULL(@InletPatchQty,0) = 1 SET @a='one inlet patch'
				ELSE SET @a='inlet patch: ' + CONVERT(VARCHAR, @InletPatchQty) + ' '
			END

			INSERT INTO @tmpMiscTAR(Val) VALUES	(@a)
		END

		IF (SELECT COUNT(Val) FROM @tmpMiscTAR) > 0 
		BEGIN
			SET @XMLlist = (SELECT Val FROM @tmpMiscTAR FOR XML  RAW, ELEMENTS, TYPE)
			INSERT INTO @tmpMisc (Val) VALUES(@indent + dbo.fnFirstLetterUpper(dbo.fnBuildString(@XMLlist)) + '.' + @br)
			DELETE FROM @tmpMiscTAR
		END

		IF @MotilityDisorder = 1
		BEGIN
			IF @ProbableAchalasia = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('probable achalasia')
			IF @ConfirmedAchalasia = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('confirmed achalasia')
			IF @MarkedTertiaryContractions = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('marked tertiary contractions')
			IF @Presbyoesophagus = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('presbyoesophagus')
			IF @LaxLowerOesoSphincter = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('lax lower oesophageal sphincter')
			IF @TortuousOesophagus = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('tortuous oesophagus')
			IF @DilatedOesophagus = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('dilated oesophagus')
			IF @MotilityPoor = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('poor motility')

			IF (SELECT COUNT(Val) FROM @tmpMiscTAR) > 0 
			BEGIN
				SET @XMLlist = (SELECT Val FROM @tmpMiscTAR FOR XML  RAW, ELEMENTS, TYPE)
				INSERT INTO @tmpMisc (Val) VALUES(@indent + dbo.fnFirstLetterUpper(dbo.fnBuildString(@XMLlist)) + '.' + @br)
				DELETE FROM @tmpMiscTAR
			END
			ELSE --None selected
				INSERT INTO @tmpMisc (Val) VALUES(@indent + dbo.fnFirstLetterUpper('motility disorder') + '.' + @br)
		END


		SET @a = ''

		IF @Diverticulum = 1
		BEGIN
			IF @Pharyngeal = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('pharyngeal (Zenker''s)')
			IF @TractionType = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('traction type')
			IF @PulsionType = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('pulsion type')
			IF @DiffuseIntramural = 1 INSERT INTO @tmpMiscTAR (Val) VALUES('diffuse intramural')

			IF @DivertMultiple = 1 
				SET @a = 'diverticulae: multiple '
			ELSE IF ISNULL(@DivertQty,0) > 0
			BEGIN
				IF ISNULL(@DivertQty,0) = 1 SET @a = 'one diverticulum'
				ELSE SET @a = 'diverticulae: ' + CONVERT(VARCHAR, @DivertQty) + ' '
			END
			ELSE 
				SET @a = 'diverticulum: '
			
			IF (SELECT COUNT(Val) FROM @tmpMiscTAR) > 0
			BEGIN
				IF LEFT(@a,3) = 'one' SET @a = @a + ', '
				SET @XMLlist = (SELECT Val FROM @tmpMiscTAR FOR XML  RAW, ELEMENTS, TYPE)
				SET @a =  @a + dbo.fnBuildString(@XMLlist)
			END

			IF LEN(@a) > 0 
			BEGIN
				SET @a = RTRIM(LTRIM(@a))
				IF RIGHT(@a,1) = ':' SET @a = LEFT(@a, LEN(@a) - 1)
				INSERT INTO @tmpMisc (Val) VALUES(@indent + dbo.fnFirstLetterUpper(@a) + '.' + @br)
				DELETE FROM @tmpMiscTAR
			END
		END

		IF ISNULL(@MiscOther,'') <> '' 
			INSERT INTO @tmpMisc (Val) VALUES(@indent + dbo.fnFirstLetterUpper(RTRIM(@MiscOther)) + @br)

		SET @XMLlist = (SELECT Val FROM @tmpMisc FOR XML  RAW, ELEMENTS, TYPE)
		SET @Summary = dbo.fnBuildString(@XMLlist)

		IF @Summary <> '' 
		BEGIN
			SET @Summary = LTRIM(RTRIM(@Summary))
			--Remove the first indent as this will be done in SP sites_summary_update
			IF LEFT(@Summary,8) = @indent SET @Summary = RIGHT(@Summary, LEN(@Summary) - 8)
			IF RIGHT(@Summary,6) = @br SET @Summary = LEFT(@Summary, LEN(@Summary) - 6)
			IF RIGHT(@Summary,1) = '.' SET @Summary = LEFT(@Summary, LEN(@Summary) - 1)
		END
	END

	-- Finally update the summary in abnormalities table
	UPDATE ERS_UpperGIAbnoMiscellaneous
	SET Summary = @Summary 
	WHERE SiteId = @siteId

----------------------------------------------------------------------------------------------------------------------
GO
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

------------------------------------------------------------------------------------------------------------
GO
EXEC DropIfExist 'abnormalities_postsurgery_summary_update','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_postsurgery_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(4000),
		@none BIT,
		@previousSurgery BIT,
		@surgicalProcedure SMALLINT,
		@surgicalProcedureFindings VARCHAR(1000),
		@duodenumPresent BIT,
		@jejunum BIT,
		@jejunumState TINYINT,
		@jejunumAbnormalText VARCHAR(500)

	SELECT 
		@none=[None],
		@surgicalProcedure=SurgicalProcedure,
		@surgicalProcedureFindings=(SELECT isnull(SurgicalProcedureFindings, '') as [text()] FOR XML PATH('')),
		@duodenumPresent=DuodenumPresent,
		@jejunumState=JejunumState,
		@jejunumAbnormalText=(SELECT isnull(JejunumAbnormalText, '') as [text()] FOR XML PATH(''))
	FROM
		ERS_UpperGIAbnoPostSurgery
	WHERE
		SiteId = @SiteId

	SET @Summary = ''

	IF @none = 1
		SET @summary = @summary + 'No evidence of previous surgery'
	
	ELSE 
	BEGIN
		IF @surgicalProcedure > 0
		BEGIN
			--SET @summary = @summary + 'surgical procedure - '

			SELECT @summary = @summary + [ListItemText]
			FROM ERS_Lists 
			WHERE [ListDescription] = 'Surgical procedures' 
			AND [ListItemNo] = @surgicalProcedure
		END

		IF ISNULL(@surgicalProcedureFindings, '') <> '' SET @summary = @summary + ' ' + @surgicalProcedureFindings

		IF @summary <> '' SET @summary = @summary + ', '

		IF @duodenumPresent = 1  SET @summary = @summary + 'duodenum removed'

		IF @jejunumState > 0
		BEGIN
			IF @summary <> '' SET @summary = @summary + ', '
			ELSE SET @summary = @summary + 'jejunum '

			IF @jejunumState = 1 SET @summary = @summary + 'normal'
			ELSE IF @jejunumState = 2 
			BEGIN
				SET @summary = @summary + 'abnormal'
				IF @jejunumAbnormalText <> '' SET @summary = @summary + ' - ' + @jejunumAbnormalText
			END
			
		END
	END

	SET @Summary = LTRIM(RTRIM(@Summary))
	IF RIGHT(@Summary,1) = ',' SET @Summary = LEFT(@Summary, LEN(@Summary) - 1)
	--PRINT @summary

	-- Finally update the summary in abnormalities table
	UPDATE ERS_UpperGIAbnoPostSurgery
	SET Summary = @Summary 
	WHERE SiteId = @siteId

--------------------------------------------------------------------------------------------------------------------------
GO
EXEC DropIfExist 'abnormalities_vascular_lesions_summary_update','S';
GO

CREATE PROCEDURE [dbo].[abnormalities_vascular_lesions_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE
		@summary VARCHAR(200),
		@temp VARCHAR(120),
		@None BIT,
		@Type TINYINT,
		@Multiple BIT,
		@Quantity INT,
		@Bleeding TINYINT,
		@Area  VARCHAR(50)

	SELECT 
		@None=[None],
		@Type=[Type],
		@Multiple=Multiple,
		@Quantity=Quantity,
		@Bleeding=Bleeding,
		@Area=Area
	FROM
		ERS_CommonAbnoVascularLesions
	WHERE
		SiteId = @SiteId

	SET @Summary = ''

	IF @None = 1
		SET @summary = @summary + 'No vascular lesions'
	
	ELSE IF @Type > 0
	BEGIN
		IF @Multiple > 0 SET @summary = @summary + 'multiple'
		ELSE IF @Quantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @Quantity)

		IF RIGHT(LOWER(@Area),5) = ' part' SET @Area = 'Duodenum' --For ERCP, the variable @Area has region name instead of Area and all the region in duodenum ends with ' part', so use this to generate @Summary text

		IF @Area = 'Oesophagus'
		BEGIN
			SET @temp = CASE @Type
						WHEN 1 THEN 'Telangiectasia'
					END
		END
		ELSE IF @Area = 'Stomach'
		BEGIN
			SET @temp = CASE @Type
						WHEN 1 THEN 'Telangiectasia'
						WHEN 2 THEN 'Angiodysplasia (<5mm)'
						WHEN 3 THEN 'Angiodysplasia (>5mm)'
						WHEN 4 THEN 'Angiodysplasia (large and small lesions)'
						WHEN 5 THEN 'Portal hypertensive gastropathy'
						WHEN 6 THEN 'Watermelon stomach'
					END
		END
		ELSE IF @Area = 'Duodenum'
		BEGIN
			SET @temp = CASE @Type
						WHEN 1 THEN 'Telangiectasia'
						WHEN 2 THEN 'Angiodysplasia (<5mm)'
						WHEN 3 THEN 'Angiodysplasia (>5mm)'
						WHEN 4 THEN 'Angiodysplasia (large and small lesions)'
						WHEN 5 THEN 'Varices'
					END
		END

		IF @summary <> '' SET @summary = @summary + ' ' + LOWER(@temp)
		ELSE SET @summary = @temp

		IF @Bleeding > 0 
		BEGIN
			SET @summary = @summary + ' with '


			IF @Area = 'Stomach'
			BEGIN
				SET @summary =  @summary + 
					CASE @Bleeding
						WHEN 1 THEN 'no bleeding'
						WHEN 2 THEN 'fresh clot'
						WHEN 3 THEN 'altered blood'
						WHEN 4 THEN 'active bleeding'
					END
			END
			ELSE IF @Area = 'Duodenum'
			BEGIN
				SET @summary =  @summary + 
					CASE @Bleeding
						WHEN 1 THEN 'no bleeding'
						WHEN 2 THEN 'fibrin plug'
						WHEN 3 THEN 'fresh clot'
						WHEN 4 THEN 'red sign'
						WHEN 5 THEN 'active bleeding'
					END
			END




		END
	END
	--PRINT @summary

	-- Finally update the summary in abnormalities table
	UPDATE ERS_CommonAbnoVascularLesions
	SET Summary = (SELECT isnull(@summary, '') as [text()] FOR XML PATH(''))  
	WHERE SiteId = @siteId

------------------------------------------------------------------------------------------------------------
GO
EXEC DropIfExist 'broncho_pathology_summary_update','S';
GO

CREATE PROCEDURE [dbo].[broncho_pathology_summary_update]
(
	@ProcedureId INT
)
AS
	SET NOCOUNT ON

	DECLARE 
		@summary VARCHAR(8000),
		@stagingsummary VARCHAR(2000),
		@tmpsummary VARCHAR(2000),
		@AsthmaThermoplasty BIT,
		@EmphysemaLungVolRed BIT,
		@Haemoptysis BIT,
		@HilarMediaLymphadenopathy BIT,
		@Infection BIT,
		@InfectionImmunoSuppressed BIT,
		@LungLobarCollapse BIT,
		@RadiologicalAbno BIT,
		@SuspectedLCa BIT,
		@SuspectedSarcoidosis BIT,
		@SuspectedTB BIT,
		@ClinicalDetails VARCHAR(1000),
		@AtrialFibrillation BIT,
		@ChronicKidneyDisease BIT,
		@COPD BIT,
		@EnlargedLymphNodes BIT,
		@EssentialHyperTension BIT,
		@HeartFailure BIT,
		@InterstitialLungDisease BIT,
		@IschaemicHeartDisease BIT,
		@LungCancer BIT,
		@Obesity BIT,
		@PleuralEffusion BIT,
		@Pneumonia BIT,
		@RheumatoidArthritis BIT,
		@SecondaryCancer BIT,
		@Stroke BIT,
		@Type2Diabetes BIT,
		@OtherComorb VARCHAR(1000),
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
		@PerformanceStatusType INT,
		@DateBronchRequested DATETIME,
		@DateOfReferral DATETIME,
		@LCaSuspectedBySpecialist BIT,
		@CTScanAvailable BIT,
		@DateOfScan DATETIME,
		@FEV1Result FLOAT,
		@FEV1Percentage FLOAT,
		@FVCResult FLOAT,
		@FVCPercentage FLOAT,
		@WHOPerformanceStatus INT

	DECLARE @tblsummary TABLE (summary VARCHAR(500))

	SELECT 
		@AsthmaThermoplasty=AsthmaThermoplasty,
		@EmphysemaLungVolRed=EmphysemaLungVolRed,
		@Haemoptysis=Haemoptysis,
		@HilarMediaLymphadenopathy=HilarMediaLymphadenopathy,
		@Infection=Infection,
		@InfectionImmunoSuppressed=InfectionImmunoSuppressed,
		@LungLobarCollapse=LungLobarCollapse,
		@RadiologicalAbno=RadiologicalAbno,
		@SuspectedLCa=SuspectedLCa,
		@SuspectedSarcoidosis=SuspectedSarcoidosis,
		@SuspectedTB=SuspectedTB,
		@ClinicalDetails=(SELECT isnull(ClinicalDetails, '') as [text()] FOR XML PATH('')),
		@AtrialFibrillation=AtrialFibrillation,
		@ChronicKidneyDisease=ChronicKidneyDisease,
		@COPD=COPD,
		@EnlargedLymphNodes=EnlargedLymphNodes,
		@EssentialHyperTension=EssentialHyperTension,
		@HeartFailure=HeartFailure,
		@InterstitialLungDisease=InterstitialLungDisease,
		@IschaemicHeartDisease=IschaemicHeartDisease,
		@LungCancer=LungCancer,
		@Obesity=Obesity,
		@PleuralEffusion=PleuralEffusion,
		@Pneumonia=Pneumonia,
		@RheumatoidArthritis=RheumatoidArthritis,
		@SecondaryCancer=SecondaryCancer,
		@Stroke=Stroke,
		@Type2Diabetes=Type2Diabetes,
		@OtherComorb=OtherComorb,
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
		@PerformanceStatusType=PerformanceStatusType,
		@DateBronchRequested=DateBronchRequested,
		@DateOfReferral=DateOfReferral,
		@LCaSuspectedBySpecialist=LCaSuspectedBySpecialist,
		@CTScanAvailable=CTScanAvailable,
		@DateOfScan=DateOfScan,
		@FEV1Result=FEV1Result,
		@FEV1Percentage=FEV1Percentage,
		@FVCResult=FVCResult,
		@FVCPercentage=FVCPercentage,
		@WHOPerformanceStatus=WHOPerformanceStatus
	FROM 
		ERS_BRT_BronchoPathology p
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

	SET @summary = ''
	

	-------------------------
	------ INDICATIONS ------ 
	-------------------------
	
	SET @tmpsummary = NULL

	IF @AsthmaThermoplasty = 1 INSERT INTO @tblsummary VALUES ('Asthma (thermoplasty)')
	IF @EmphysemaLungVolRed = 1 INSERT INTO @tblsummary VALUES ('Emphysema (lung volume reduction)')
	IF @Haemoptysis = 1 INSERT INTO @tblsummary VALUES ('Haemoptysis')
	IF @HilarMediaLymphadenopathy = 1 INSERT INTO @tblsummary VALUES ('Hilar/Mediastinal Lymphadenopathy')

	IF @Infection = 1 
	BEGIN
		SET @tmpsummary = 'Infection'
		IF @InfectionImmunoSuppressed = 1 SET @tmpsummary = 'Infection (immunosuppressed)'
		INSERT INTO @tblsummary VALUES (@tmpsummary)
	END

	IF @LungLobarCollapse = 1 INSERT INTO @tblsummary VALUES ('Lung/lobar collapse')
	IF @RadiologicalAbno = 1 INSERT INTO @tblsummary VALUES ('Radiological abnormality')
	IF @SuspectedLCa = 1 INSERT INTO @tblsummary VALUES ('Suspected lung cancer') 
	IF @SuspectedSarcoidosis = 1 INSERT INTO @tblsummary VALUES ('Suspected sarcoidosis')
	IF @SuspectedTB = 1 INSERT INTO @tblsummary VALUES ('Suspected TB')
	IF @ClinicalDetails <> '' INSERT INTO @tblsummary VALUES (@ClinicalDetails)

	SELECT @tmpsummary = COALESCE(@tmpsummary + ', ', '') + summary
	FROM @tblsummary

	SET @summary = @summary + @tmpsummary


	-------------------------
	------ STAGING ----------
	-------------------------

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

		IF @stagingsummary IS NOT NULL
			IF @summary <> '' SET @summary = @summary + '<br/>' + @stagingsummary
			ELSE SET @summary = @stagingsummary
	END


	------------------------------
	------ CO-MORBIDITY ----------
	------------------------------

	DELETE FROM @tblsummary
	SET @tmpsummary = NULL

	IF @AtrialFibrillation = 1 INSERT INTO @tblsummary VALUES ('Atrial fibrillation')
	IF @ChronicKidneyDisease = 1 INSERT INTO @tblsummary VALUES ('Chronic kidney disease')
	IF @COPD = 1 INSERT INTO @tblsummary VALUES ('COPD')
	IF @EnlargedLymphNodes = 1 INSERT INTO @tblsummary VALUES ('Enlarged lymph nodes')
	IF @EssentialHyperTension = 1 INSERT INTO @tblsummary VALUES ('Essential hyper tension')
	IF @HeartFailure = 1 INSERT INTO @tblsummary VALUES ('Heart failure')
	IF @InterstitialLungDisease = 1 INSERT INTO @tblsummary VALUES ('Interstitial lung disease')
	IF @IschaemicHeartDisease = 1 INSERT INTO @tblsummary VALUES ('Ischaemic heart disease')
	IF @LungCancer = 1 INSERT INTO @tblsummary VALUES ('Lung cancer')
	IF @Obesity = 1 INSERT INTO @tblsummary VALUES ('Obesity')
	IF @PleuralEffusion = 1 INSERT INTO @tblsummary VALUES ('Pleural effusion')
	IF @Pneumonia = 1 INSERT INTO @tblsummary VALUES ('Pneumonia')
	IF @RheumatoidArthritis = 1 INSERT INTO @tblsummary VALUES ('Rheumatoid arthritis')
	IF @SecondaryCancer = 1 INSERT INTO @tblsummary VALUES ('Secondary Cancer')
	IF @Stroke = 1 INSERT INTO @tblsummary VALUES ('Stroke')
	IF @Type2Diabetes = 1 INSERT INTO @tblsummary VALUES ('Type 2 Diabetes')
	IF @OtherComorb <> '' INSERT INTO @tblsummary VALUES (@OtherComorb)
	
	SELECT @tmpsummary = COALESCE(@tmpsummary + ', ', '') + summary
	FROM @tblsummary

	IF @tmpsummary IS NOT NULL SET @tmpsummary = 'Co-Morbidity (' + @tmpsummary + ')'
	ELSE SET @tmpsummary = ''

	IF @tmpsummary <> ''
		IF @summary <> '' SET @summary = @summary + '<br/>' + @tmpsummary
		ELSE SET @summary = @tmpsummary

	
	--------------------------------
	------ PULMONARY PHYSIOLOGY ----
	--------------------------------

	SET @tmpsummary = ''

	IF @FEV1Result IS NOT NULL 
	BEGIN
		SET @tmpsummary = 'FEV1 ' + CONVERT(VARCHAR, @FEV1Result) + ' litres'
		IF @FEV1Percentage IS NOT NULL SET @tmpsummary = @tmpsummary + ' (' + CONVERT(VARCHAR, @FEV1Percentage) + '% of predictive)'
	END

	IF @FVCResult IS NOT NULL 
	BEGIN
		IF @tmpsummary <> '' SET @tmpsummary = @tmpsummary + ' '
		SET @tmpsummary = @tmpsummary + ' FVCResult ' + CONVERT(VARCHAR, @FVCResult) + ' litres'
		IF @FVCPercentage IS NOT NULL SET @tmpsummary = @tmpsummary + ' (' + CONVERT(VARCHAR, @FVCPercentage) + '% of predictive)'
	END
	
	IF @WHOPerformanceStatus > 0
	BEGIN
		IF @tmpsummary <> '' SET @tmpsummary = @tmpsummary + ' '
		SET @tmpsummary = @tmpsummary + 'WHO performance status' + 
							CASE @WHOPerformanceStatus 
								WHEN 1 THEN ' (normal activity)'
								WHEN 2 THEN ' (able to carry out light work)'
								WHEN 3 THEN ' (unable to carry out any work)'
								WHEN 4 THEN ' (limited self care)'
								WHEN 5 THEN ' (completely disabled)'
								ELSE ''
							END
	END

	IF @tmpsummary <> ''
	BEGIN
		SET @tmpsummary = 'Pulmonary Physiology (' + @tmpsummary + ')'

		IF @summary <> '' SET @summary = @summary + '<br/>' + @tmpsummary
		ELSE SET @summary = @tmpsummary
	END

	--------------------------------
	------ REFERAL DATA ------------
	--------------------------------
	
	DELETE FROM @tblsummary
	SET @tmpsummary = NULL

	IF @DateBronchRequested IS NOT NULL INSERT INTO @tblsummary VALUES ('Date bronchoscopy requested ' + CONVERT(VARCHAR, @DateBronchRequested, 105))
	IF @DateOfReferral IS NOT NULL INSERT INTO @tblsummary VALUES ('Date of referral ' + CONVERT(VARCHAR, @DateOfReferral, 105))
	IF @LCaSuspectedBySpecialist = 1 INSERT INTO @tblsummary VALUES ('Lung Ca suspected by lung Ca specialist')
	IF @CTScanAvailable = 1 INSERT INTO @tblsummary VALUES ('CT scan available prior to bronchoscopy')
	IF @DateOfScan IS NOT NULL INSERT INTO @tblsummary VALUES ('Date of scan ' + CONVERT(VARCHAR, @DateOfScan, 105))
	
	SELECT @tmpsummary = COALESCE(@tmpsummary + ', ', '') + summary
	FROM @tblsummary

	IF @tmpsummary IS NOT NULL SET @tmpsummary = 'Referal Data (' + @tmpsummary + ')'
	ELSE SET @tmpsummary = ''

	IF @tmpsummary <> ''
		IF @summary <> '' SET @summary = @summary + '<br/>' + @tmpsummary
		ELSE SET @summary = @tmpsummary



	UPDATE ERS_ProceduresReporting
	SET PP_Indic = @summary
	WHERE ProcedureId = @ProcedureId

------------------------------------------------------------------------------------------------------------
GO
EXEC DropIfExist 'ogd_extentofintubation_summary_update','S';
GO

CREATE PROCEDURE [dbo].[ogd_extentofintubation_summary_update]
(
       @ProcedureId INT
)
AS
       SET NOCOUNT ON

	   DECLARE @ProcedureType INT = (SELECT ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)

       DECLARE
              @summary VARCHAR(4000),
              @CompletionStatus TINYINT,
              @Extent SMALLINT,
              @FailureReason TINYINT,
              @FailureReasonOther NVARCHAR(1000),
			  @Jmanoeuvre TINYINT,
              @TrainerCompletionStatus TINYINT,
              @TrainerExtent SMALLINT,
              @TrainerFailureReason TINYINT,
              @TrainerFailureReasonOther NVARCHAR(1000),
			  @TrainerJmanoeuvre TINYINT,
			  @ReportCompletionStatus TINYINT,
              @ReportExtent SMALLINT,
              @ReportFailureReason TINYINT,
              @ReportFailureReasonOther NVARCHAR(1000),
			  @ReportJmanoeuvre TINYINT

       SELECT 
              @CompletionStatus = CompletionStatus,
              @Extent = Extent,
              @FailureReason = FailureReason,
              @FailureReasonOther = (SELECT isnull(FailureReasonOther, '') as [text()] FOR XML PATH('')),
			  @Jmanoeuvre = Jmanoeuvre,
              @TrainerCompletionStatus = TrainerCompletionStatus,
              @TrainerExtent = TrainerExtent,
              @TrainerFailureReason = TrainerFailureReason,
              @TrainerFailureReasonOther = (SELECT isnull(TrainerFailureReasonOther, '') as [text()] FOR XML PATH('')),
			  @TrainerJmanoeuvre = TrainerJmanoeuvre
       FROM
              ERS_UpperGIExtentOfIntubation
       WHERE
              ProcedureId = @ProcedureId

       SET @Summary = ''

	   --Report either trainee or trainer, not both - based on completion status (success status should be reported first)
	   IF @CompletionStatus = 1  --Success
	   BEGIN
			SET @ReportCompletionStatus = 1
			SET @ReportExtent = @Extent
			SET @ReportFailureReason = @FailureReason
			SET @ReportFailureReasonOther = @FailureReasonOther
			SET @ReportJmanoeuvre = @Jmanoeuvre
	   END
	   ELSE IF @TrainerCompletionStatus = 1  --Success
	   BEGIN
			SET @ReportCompletionStatus = 1
			SET @ReportExtent = @TrainerExtent
			SET @ReportFailureReason = @TrainerFailureReason
			SET @ReportFailureReasonOther = @TrainerFailureReasonOther
			SET @ReportJmanoeuvre = @TrainerJmanoeuvre
	   END
	   ELSE IF @CompletionStatus = 2  --Failed
	   BEGIN
			SET @ReportCompletionStatus = 2
			SET @ReportExtent = @Extent
			SET @ReportFailureReason = @FailureReason
			SET @ReportFailureReasonOther = @FailureReasonOther
			SET @ReportJmanoeuvre = @Jmanoeuvre
	   END
	   ELSE IF @TrainerCompletionStatus = 2  --Failed
	   BEGIN
			SET @ReportCompletionStatus = 2
			SET @ReportExtent = @TrainerExtent
			SET @ReportFailureReason = @TrainerFailureReason
			SET @ReportFailureReasonOther = @TrainerFailureReasonOther
			SET @ReportJmanoeuvre = @TrainerJmanoeuvre
	   END


       
	   IF @ReportJmanoeuvre = 1 SET @summary = @summary + 'J manoeuvre not carried out'
	   ELSE IF @ReportJmanoeuvre = 2 SET @summary = @summary + 'J manoeuvre performed'

       IF @ReportCompletionStatus = 1
       BEGIN
			IF @summary <> '' SET @summary = @summary + '. '
              SET @summary = @summary + 'The procedure was completed successfully'
			  IF @ProcedureType IN (1, 8) -- Gastroscopy, Antegrade
			  BEGIN
				IF @ReportExtent = 1 SET @summary = @summary + ' to the ' + 'proximal jejunum'
				ELSE IF @ReportExtent = 2 SET @summary = @summary + ' to the ' + 'distal jejunum'
				ELSE IF @ReportExtent = 3 SET @summary = @summary + ' to the ' + 'proximal ileum'
				ELSE IF @ReportExtent = 4 SET @summary = @summary + ' to the ' + 'jejunum'
				ELSE IF @ReportExtent = 5 SET @summary = @summary + ' to the ' + 'D4'
				ELSE IF @ReportExtent = 6 SET @summary = @summary + ' to the ' + 'D3'
				ELSE IF @ReportExtent = 7 SET @summary = @summary + ' to the ' + 'D2'
				ELSE IF @ReportExtent = 8 SET @summary = @summary + ' to the ' + 'D1'
				ELSE IF @ReportExtent = 9 SET @summary = @summary + ' to the ' + 'stomach'
				ELSE IF @ReportExtent = 10 SET @summary = @summary + ' to the ' + 'distal oesophagus'
				ELSE IF @ReportExtent = 11 SET @summary = @summary + ' to the ' + 'proximal oesophagus'
			  END
       END

       ELSE IF @ReportCompletionStatus = 2
       BEGIN
			IF @summary <> '' SET @summary = @summary + '. '
              --SET @summary = @summary + 'Procedure failed'
              IF @ReportFailureReason = 1 SET @summary = @summary + 'Failed intubation'
              ELSE IF @ReportFailureReason = 2 SET @summary = @summary + 'Failed due to oesophageal stricture'
              ELSE IF @ReportFailureReason = 3 
              BEGIN
                     IF @ReportFailureReasonOther <> '' SET @summary = @summary + 'Procedure failed: ' + @ReportFailureReasonOther ELSE SET @summary = @summary + 'Procedure failed'
              END
			  ELSE IF @ReportFailureReason = 4 SET @summary = @summary + 'Procedure failed (abandoned)'
       END

	   SET @summary = LTRIM(RTRIM(@summary))
	   IF RIGHT(@summary,1) = '.' SET @summary = LEFT(@summary, LEN(@summary)-1)

	--Update the summary column in extentofintubation table
       UPDATE ERS_UpperGIExtentOfIntubation
       SET Summary = @summary 
       WHERE ProcedureId = @ProcedureId

	EXEC procedure_summary_update @ProcedureId


--------------------------------------------------------------------------------------------------------
GO
EXEC DropIfExist 'specimens_ogd_summary_update','S';
GO

CREATE PROCEDURE [dbo].[specimens_ogd_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON

	DECLARE 
		@summary VARCHAR (8000),
		@tempsummary VARCHAR(1000),
		@RegionId INT,
		@None BIT,
		@BrushCytology BIT,
		@Biopsy BIT,
		@BiopsiesTakenAtRandom BIT,
		@BiopsyQtyHistology INT,
		@BiopsyQtyMicrobiology INT,
		@BiopsyQtyVirology INT,
		@ForcepType SMALLINT,
		@ForcepSerialNo NVARCHAR(50),
		--@ForcepSerialNoDesc VARCHAR(100),
		@Urease BIT,
		@UreaseResult TINYINT,
		@Polypectomy BIT,
		@PolypectomyQty INT,
		@HotBiopsy BIT,
		@NeedleAspirate BIT,	
		@NeedleAspirateHistology BIT,
		@NeedleAspirateMicrobiology BIT, 
		@NeedleAspirateVirology BIT,
		@GastricWashing BIT,
		@Bile_PanJuice BIT,
		@Bile_PanJuiceCytology BIT,
		@Bile_PanJuiceBacteriology BIT,
		@Bile_PanJuiceAnalysis BIT,
		@EUSFNANumberOfPasses INT,
		@EUSFNANeedleGauge INT,
		@FNB BIT,
		@EUSFNBNumberOfPasses INT,
		@EUSFNBNeedleGauge INT,
		@BrushBiopsy BIT,
		@TumourMarkers BIT,
		@AmylaseLipase BIT,
		@CytologyHistology BIT,
		@FullStop VARCHAR(5) = '. '
	
	SELECT 
		@summary = '',
		@RegionId = s.RegionId,
		@None=[None],
		@BrushCytology=BrushCytology,
		@Biopsy=Biopsy,
		@BiopsiesTakenAtRandom=BiopsiesTakenAtRandom,
		@BiopsyQtyHistology=BiopsyQtyHistology,
		@BiopsyQtyMicrobiology=BiopsyQtyMicrobiology,
		@BiopsyQtyVirology=BiopsyQtyVirology,
		@ForcepType = p.ForcepType,
		@ForcepSerialNo = (SELECT isnull(p.ForcepSerialNo, '') as [text()] FOR XML PATH('')),
		--@ForcepSerialNoDesc = l.[ListItemText],
		@Urease=Urease,
		@UreaseResult=UreaseResult,
		@Polypectomy=Polypectomy,
		@PolypectomyQty=PolypectomyQty,
		@HotBiopsy=HotBiopsy,
		@NeedleAspirate=NeedleAspirate,
		@NeedleAspirateHistology=NeedleAspirateHistology,
		@NeedleAspirateMicrobiology=NeedleAspirateMicrobiology,
		@NeedleAspirateVirology=NeedleAspirateVirology,
		@GastricWashing=GastricWashing,
		@Bile_PanJuice = Bile_PanJuice,

		@EUSFNANumberOfPasses = EUSFNANumberOfPasses,
		@EUSFNANeedleGauge = EUSFNANeedleGauge,
		@FNB = FNB,
		@EUSFNBNumberOfPasses = EUSFNBNumberOfPasses,
		@EUSFNBNeedleGauge = EUSFNBNeedleGauge,
		@BrushBiopsy = BrushBiopsy,
		@TumourMarkers = TumourMarkers,
		@AmylaseLipase = AmylaseLipase,
		@CytologyHistology = CytologyHistology
		--@Bile_PanJuiceCytology = Bile_PanJuiceCytology,
		--@Bile_PanJuiceBacteriology = Bile_PanJuiceBacteriology,
		--@Bile_PanJuiceAnalysis = Bile_PanJuiceAnalysis
	FROM
		ERS_UpperGISpecimens sp
	JOIN
		ERS_Sites s ON sp.SiteId = s.SiteId
	JOIN
		ERS_Procedures p ON s.ProcedureId = p.ProcedureId
	--LEFT OUTER JOIN
	--	ERS_Lists l ON p.ForcepSerialNo = l.[ListItemNo] AND l.[ListDescription] = 'Forcep Serial Numbers'
	WHERE 
		sp.SiteId = @SiteId

	IF @None = 1
		SET @summary = @summary + 'No specimens taken'
	ELSE
	BEGIN

		IF @AmylaseLipase = 1 
		BEGIN
			IF @summary <> '' SET @summary = @summary + @FullStop
			SET @summary = @summary + 'Amylase and lipase'
		END

		IF @Bile_PanJuice = 1
		BEGIN
			DECLARE @BileTxt VARCHAR(30) = 'Bile'

			IF (SELECT 1 FROM ERS_Regions WHERE RegionId = @RegionId AND 
				Region IN ('Uncinate Process', 'Head', 'Neck', 'Body', 'Tail', 'Accessory Pancreatic Duct', 'Main Pancreatic Duct') ) = 1
					SET @BileTxt = 'Pancreatic juice'
		
			IF @summary <> '' SET @summary = @summary + @FullStop
			SET @summary = @summary + @BileTxt
		END

		IF @Biopsy = 1 
		BEGIN
			IF @summary <> '' SET @summary = @summary + @FullStop
			SET @summary = @summary + 'Biopsy'

			IF @BiopsyQtyHistology > 0 OR @BiopsyQtyMicrobiology > 0 OR @BiopsyQtyVirology > 0
			BEGIN
				SET @tempsummary = ''
				IF @BiopsiesTakenAtRandom = 1
				BEGIN
					SET @tempsummary = CONVERT(VARCHAR, ISNULL(@BiopsyQtyHistology,0) + ISNULL(@BiopsyQtyMicrobiology,0) + ISNULL(@BiopsyQtyVirology,0) )
										+ ' x random'
				END
				ELSE
				BEGIN
					IF @BiopsyQtyHistology > 0 SET @tempsummary = CONVERT(VARCHAR(10), @BiopsyQtyHistology) + ' to histology'
					IF @BiopsyQtyMicrobiology > 0
					BEGIN
						IF @tempsummary <> '' SET @tempsummary = @tempsummary + ', ' + CONVERT(VARCHAR(10), @BiopsyQtyMicrobiology) + ' to microbiology'
						ELSE SET @tempsummary = CONVERT(VARCHAR(10), @BiopsyQtyMicrobiology) + ' to microbiology'
					END
					IF @BiopsyQtyVirology > 0
					BEGIN
						IF @tempsummary <> '' SET @tempsummary = @tempsummary + ', ' + CONVERT(VARCHAR(10), @BiopsyQtyVirology) + ' to virology'
						ELSE SET @tempsummary = CONVERT(VARCHAR(10), @BiopsyQtyVirology) + ' to virology'
					END
				END
				SET @summary = @summary + ' ('
				SET @summary = @summary + @tempsummary
				SET @summary = @summary + ')'
			END
			IF @ForcepType > 0 OR ISNULL(@ForcepSerialNo,'') <> ''
			BEGIN
				IF @ForcepType = 1 
				BEGIN
					SET @summary = @summary + ' with disposable forceps'
					IF ISNULL(@ForcepSerialNo,'') <> '' SET @summary = @summary + ' (serial number: ' + @ForcepSerialNo + ')'
				END
				--ELSE IF @ForcepType = 2 
				--BEGIN
				--	SET @summary = @summary + ' (Forceps - Reusable'
				--	IF @ForcepSerialNo > 0 SET @summary = @summary + ', Serial No: ' + @ForcepSerialNoDesc
				--	SET @summary = @summary + ')'
				--END
			END

			IF @BrushCytology = 1 
			BEGIN
				IF @summary <> '' SET @summary = @summary + @FullStop
				SET @summary = @summary + 'Brush cytology'
			END
		END
		
		IF @BrushBiopsy = 1 
		BEGIN
			IF @summary <> '' SET @summary = @summary + @FullStop
			SET @summary = @summary + 'Brush biopsy'
		END

		IF @CytologyHistology = 1 
		BEGIN
			IF @summary <> '' SET @summary = @summary + @FullStop
			SET @summary = @summary + 'Cytology and histology'
		END

		--FNA
		IF @NeedleAspirate = 1 
		BEGIN
			IF @summary <> '' SET @summary = @summary + @FullStop
			SET @summary = @summary + 'Fine needle aspirate'
			
			IF @NeedleAspirateHistology = 1 OR @NeedleAspirateMicrobiology = 1 OR @NeedleAspirateVirology = 1
			BEGIN
				IF @NeedleAspirateHistology = 1 OR @NeedleAspirateMicrobiology = 1 OR @NeedleAspirateVirology = 1
				BEGIN
					SET @tempsummary = ''
					IF @NeedleAspirateHistology = 1 
						SET @tempsummary = @tempsummary + 'cytology'
					IF @NeedleAspirateMicrobiology = 1 
						IF @tempsummary = '' SET @tempsummary = @tempsummary + 'microbiology'
						ELSE SET @tempsummary = @tempsummary + ', microbiology'
					IF @NeedleAspirateVirology = 1 
						IF @tempsummary = '' SET @tempsummary = @tempsummary + 'virology'
						ELSE SET @tempsummary = @tempsummary + ', virology'
					SET @summary = @summary + ' (' + @tempsummary + ')'
				END
			END

			IF @EUSFNANumberOfPasses > 0 SET @summary = @summary + ' (' + CONVERT(VARCHAR(10), @EUSFNANumberOfPasses) + CASE WHEN @EUSFNANumberOfPasses > 1 THEN ' passes' ELSE ' pass' END
			IF @EUSFNANeedleGauge > 0 
			BEGIN
				IF @EUSFNANumberOfPasses > 0 SET @summary = @summary + ' with ' ELSE SET @summary = @summary + ' (with '
				SET @summary = @summary + CONVERT(VARCHAR(10), @EUSFNANeedleGauge) + ' needle gauge)'
			END
			ELSE
				IF @EUSFNANumberOfPasses > 0 SET @summary = @summary + ')'
		END

		--FNB
		IF @FNB = 1 
		BEGIN
			IF @summary <> '' SET @summary = @summary + @FullStop
			SET @summary = @summary + 'Fine needle biopsy'

			IF @EUSFNBNumberOfPasses > 0 SET @summary = @summary + ' (' + CONVERT(VARCHAR(10), @EUSFNBNumberOfPasses) + CASE WHEN @EUSFNBNumberOfPasses > 1 THEN ' passes' ELSE ' pass' END
			IF @EUSFNBNeedleGauge > 0 
			BEGIN
				IF @EUSFNBNumberOfPasses > 0 SET @summary = @summary + ' with ' ELSE SET @summary = @summary + ' (with '
				SET @summary = @summary + CONVERT(VARCHAR(10), @EUSFNBNeedleGauge) + ' needle gauge)'
			END
			ELSE
				IF @EUSFNBNumberOfPasses > 0 SET @summary = @summary + ')'
		END

		IF @GastricWashing = 1 
		BEGIN
			IF @summary <> '' SET @summary = @summary + @FullStop
			SET @summary = @summary + 'Gastric Washing'
		END

		IF @HotBiopsy = 1 
		BEGIN
			IF @summary <> '' SET @summary = @summary + @FullStop
			SET @summary = @summary + 'Hot biopsy'
		END
		
		IF @Polypectomy = 1 
		BEGIN
			IF @summary <> '' SET @summary = @summary + @FullStop
			SET @summary = @summary + 'Polypectomy'
			
			IF @PolypectomyQty > 0 SET @summary = @summary + ' (' + CONVERT(VARCHAR(10), @PolypectomyQty) + CASE WHEN @PolypectomyQty > 1 THEN ' biopsies)' ELSE ' biopsy)' END
		END
		
		IF @TumourMarkers = 1 
		BEGIN
			IF @summary <> '' SET @summary = @summary + @FullStop
			SET @summary = @summary + 'Tumour markers'
		END

		IF @Urease = 1 
		BEGIN
			IF @summary <> '' SET @summary = @summary + @FullStop

			IF @UreaseResult = 1 SET @summary = @summary + 'Positive urease test for H. pylori'
			ELSE IF @UreaseResult = 2 SET @summary = @summary + 'Urease test for H. pylori proved negative'
			ELSE  SET @summary = @summary + 'Urease test'
		END
	END 
		
	-- Finally, update the summary in specimens table
	UPDATE ERS_UpperGISpecimens 
	SET Summary=@summary 
	WHERE SiteId = @SiteId

-------------------------------------------------------------------------------------------------------
GO
EXEC DropIfExist 'therapeutics_ercp_summary_update','S';
GO

CREATE PROCEDURE [dbo].[therapeutics_ercp_summary_update]
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
    @BotoxInjection BIT,
    @EndoloopPlacement BIT,
    @ForeignBody BIT,
	@Injection BIT,
	@InjectionType INT,
	@InjectionVolume INT,
	@InjectionNumber INT,
	@GastrostomyInsertion BIT,
	@GastrostomyInsertionSize INT,
	@GastrostomyInsertionUnits TINYINT,
	@GastrostomyInsertionType TINYINT,
	@GastrostomyInsertionBatchNo VARCHAR(100),
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
		@EUSProcType SMALLINT;

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
				@EUSProcType				= (CASE WHEN IsNull(ER.EUSProcType, 0) = 0 THEN EE.EUSProcType ELSE ER.EUSProcType END)
			FROM eeRecord AS EE
	  INNER JOIN #tmp_ERCPTherapeutics AS ER ON EE.SiteId = ER.SiteId
		   WHERE ER.CarriedOutRole = 1; --## 1 is ER
		END	--## Selecting from Combine
	--ELSE
	--	--## 2) ELSE - THere is only ER present.. So- no need to Combine them...
	--	BEGIN
	--		--PRINT 'ONLY ER Exist- at ERS_UpperGITherapeutics';
	--		SELECT
	--			@None				=	[None],	
	--			@YAGLaser			=	YAGLaser,	
	--			@YAGLaserWatts		=	YAGLaserWatts,	
	--			@YAGLaserPulses		=	YAGLaserPulses,	
	--			@YAGLaserSecs		=	YAGLaserSecs,	
	--			@YAGLaserKJ			=	YAGLaserKJ,	
	--			@ArgonBeamDiathermy	=	ArgonBeamDiathermy,	
	--			@ArgonBeamDiathermyWatts		=	ArgonBeamDiathermyWatts,	
	--			@ArgonBeamDiathermyPulses		=	ArgonBeamDiathermyPulses,	
	--			@ArgonBeamDiathermySecs			=	ArgonBeamDiathermySecs,	
	--			@ArgonBeamDiathermyKJ			=	ArgonBeamDiathermyKJ,	
	--			@HeatProbe			=	HeatProbe,	
	--			@BicapElectro		=	BicapElectro,	
	--			@Diathermy			=	Diathermy,	
	--			@HotBiopsy			=	HotBiopsy,	
	--			@Injection			=	Injection,	
	--			@InjectionType		=	InjectionType,	
	--			@InjectionVolume	=	InjectionVolume,	
	--			@InjectionNumber	=	InjectionNumber,	
	--			@GastrostomyInsertion			=	GastrostomyInsertion,	
	--			@GastrostomyInsertionSize		=	GastrostomyInsertionSize,	
	--			@GastrostomyInsertionUnits		=	GastrostomyInsertionUnits,	
	--			@GastrostomyInsertionType		=	GastrostomyInsertionType,	
	--			@GastrostomyInsertionBatchNo	=	ISNULL(GastrostomyInsertionBatchNo,''),	
	--			@NilByMouth			=	NilByMouth,	
	--			@NilByMouthHrs		=	NilByMouthHrs,	
	--			@NilByProc			=	NilByProc,	
	--			@NilByProcHrs		=	NilByProcHrs,	
	--			@AttachmentToWard	=	AttachmentToWard,	
	--			@PyloricDilatation	=	PyloricDilatation,	
	--			@StentInsertion		=	StentInsertion,	
	--			@StentInsertionQty	=	StentInsertionQty,	
	--			@RadioactiveWirePlaced			=	RadioactiveWirePlaced,	
	--			@StentInsertionBatchNo			=	ISNULL(StentInsertionBatchNo,''),
	--			@StentRemoval					=	StentRemoval,	
	--			@StentRemovalTechnique			=	StentRemovalTechnique,	
	--			@EMR				=	EMR,	
	--			@EMRType			=	EMRType,	
	--			@EMRFluid			=	EMRFluid,	
	--			@EMRFluidVolume		=	EMRFluidVolume,	
	--			@Marking			=	Marking,	
	--			@MarkingType		=	MarkingType,	
	--			@Clip				=	Clip,	
	--			@ClipNum			=	ClipNum,	
	--			@Papillotomy		=	Papillotomy,	
	--			@Sphincterotome		=	Sphincterotome,	
	--			@PapillotomyLength	=	PapillotomyLength,	
	--			@PapillotomyAcceptBalloonSize	=	PapillotomyAcceptBalloonSize,	
	--			@ReasonForPapillotomy		=	ReasonForPapillotomy,	
	--			@PapillotomyBleeding		=	PapillotomyBleeding,	
	--			@SphincterDecompressed		=	SphincterDecompressed,	
	--			@PanOrificeSphincterotomy	=	PanOrificeSphincterotomy,	
	--			@StoneRemoval				=	StoneRemoval,	
	--			@RemovalUsing				=	RemovalUsing,	
	--			@ExtractionOutcome			=	ExtractionOutcome,	
	--			@InadequateSphincterotomy	=	InadequateSphincterotomy,	
	--			@StoneSize			=	StoneSize,	
	--			@QuantityOfStones	=	QuantityOfStones,	
	--			@ImpactedStones		=	ImpactedStones,	
	--			@OtherReason		=	OtherReason,	
	--			@OtherReasonText	=	OtherReasonText,	
	--			@StoneDecompressed	=	StoneDecompressed,	
	--			@StrictureDilatation=	StrictureDilatation,	
	--			@DilatedTo			=	DilatedTo,	
	--			@DilatationUnits	=	DilatationUnits,	
	--			@DilatorType		=	DilatorType,	
	--			@EndoscopicCystPuncture	=	EndoscopicCystPuncture,	
	--			@CystPunctureDevice		=	CystPunctureDevice,	
	--			@CystPunctureVia		=	CystPunctureVia,	
	--			@Cannulation			=	Cannulation,	
	--			@Manometry				=	Manometry,	
	--			@Haemostasis			=	Haemostasis,	
	--			@NasopancreaticDrain	=	NasopancreaticDrain,	
	--			@RendezvousProcedure	=	RendezvousProcedure,	
	--			@SnareExcision			=	SnareExcision,	
	--			@BalloonDilation		=	BalloonDilation,	
	--			@BalloonDilatedTo		=	BalloonDilatedTo,	
	--			@BalloonDilatationUnits	=	BalloonDilatationUnits,	
	--			@BalloonDilatorType		=	BalloonDilatorType,	
	--			@BalloonTrawl			=	BalloonTrawl,	
	--			@BalloonTrawlDilatorType	=	BalloonTrawlDilatorType,	
	--			@BalloonTrawlDilatorSize	=	BalloonTrawlDilatorSize,	
	--			@BalloonTrawlDilatorUnits	=	BalloonTrawlDilatorUnits,	
	--			@BalloonDecompressed		=	BalloonDecompressed,	
	--			@DiagCholangiogram			=	DiagCholangiogram,	
	--			@DiagPancreatogram			=	DiagPancreatogram,	
	--			@EndoscopistRole			=	CarriedOutRole,	
	--			@Other						=	Other,	
	--			@EUSProcType				=	EUSProcType
	--		FROM dbo.[ERS_ERCPTherapeutics]
 -- 		   WHERE Id= @TherapeuticId
	--	END --## Selecting from ERCP Therap- Only ER Row...						
	
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

			IF @DilatedTo > 0 
			BEGIN
				SET @Details = @Details + ' dilated to ' + cast(@DilatedTo as varchar(50)) + ' ' + 
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
			SET @msg =' Stent insertion'
			SET @Details = ''

			--Qty of stents used
			IF @StentInsertionQty > 0 SET @Details = @Details + '  ' + cast(@StentInsertionQty as varchar(50))

			SET @Details = @Details + dbo.ercp_stentinsertions_summary(@TherapeuticId)

			IF @RadioactiveWirePlaced > 0  SET @Details = @Details + ', radiotherapeutic wire placed' 
			IF ISNULL(@StentInsertionBatchNo,'') <> ''  SET @Details = @Details + ', batch ' + LTRIM(RTRIM(@StentInsertionBatchNo))
			
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
	WHERE SiteID = @SiteId AND CarriedOutRole=1; --Id = @TherapeuticId

	DROP TABLE #tmp_ERCPTherapeutics;

-----------------------------------------------------------------------------------------------------------
GO
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
		@EUSProcType smallint;

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
				@EUSProcType					= (CASE WHEN IsNull(ER.[EUSProcType], 0) = 0 THEN EE.[EUSProcType] ELSE ER.[EUSProcType] END) 
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



EXEC dbo.DropIfExist 'ERS_VW_PatientswithGP', 'V';
GO
CREATE VIEW [dbo].[ERS_VW_PatientswithGP]
	AS
	SELECT DISTINCT 
		ROW_NUMBER() OVER (ORDER BY p.PatientId) AS PatientRowId,
		p.PatientId AS PatientId, 
		NULL AS UGIPatientId,
		NULL as ComboId,
		1 AS ERSPatient, 
		p.Title AS Title, 
		p.Forename1 AS Forename1, 
		p.Surname AS Surname, 
		dbo.fnGender(p.GenderId) AS Gender, 
		(Select CODE from ERS_GenderTypes where GenderID = p.GenderId) As GenderCode, 
		p.Forename1 + ' ' + p.Surname AS PatientName, 
		dbo.fnFullAddress(p.Address1, p.Address2, p.Address3, p.Address4, '') AS Address, 
		p.Address1 AS Address1, 
		p.Address2 AS Address2, 
		p.Address3 AS Town, 
		p.Address4 AS County,
		p.PostCode,
		p.Telephone,
		p.DateOfBirth AS DateOfBirth, 
		p.HospitalNumber AS HospitalNumber, 
		p.NHSNo AS NHSNo, 
		p.DateAdded AS DateAdded,
		p.DateUpdated AS DateUpdated,
		p.EthnicId AS EthnicId,
		p.RegGpId as GPId,
		g.CompleteName AS GPName,
		ep.name AS PracticeName,
		dbo.fnFullAddress(ep.Address1, ep.Address2, ep.Address3, ep.Address4, ep.PostCode) AS GPAddress,
		ep.TelNo AS GPTelNo,
		p.DateOfDeath AS DateOfDeath,
		ISNULL(p.Deceased, 0) AS Deceased
	FROM ERS_Patients p 
		LEFT JOIN ERS_GPs g ON g.GPId = p.RegGpId
		LEFT JOIN dbo.ERS_Practices ep ON p.RegGpPracticeId = ep.PracticeID
GO

--------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'patient_select','S';
GO
Create PROCEDURE [dbo].[patient_select]
(
	@PatientId int
)
AS

SET NOCOUNT ON

DECLARE @GPid INT 

BEGIN TRANSACTION

BEGIN TRY

	SELECT [Title], [Forename1] AS Forename, [Surname], [Address], 
			[Postcode], CASE WHEN ISNULL(GPName,'') = '' THEN 'Not Stated' ELSE GPName END AS GPName, PracticeName,
			ISNULL(GPAddress,'') AS GPAddress, NHSNo, Gender, 
			DateOfBirth, HospitalNumber as CaseNoteNo, 
			dbo.fnEthnicity(EthnicId) AS Ethnicity,
			[DateAdded] AS CreatedOn, DateUpdated AS ModifiedOn, 
			Deceased, DateOfDeath, Address1, Address2, Town, County, GenderCode, GPId
	FROM ERS_VW_PatientswithGP 
	WHERE PatientId = @PatientId
	
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


------------------------------------------------------------------------------------------------------

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'MoveUpperGISite','S';
GO

CREATE PROCEDURE [dbo].[MoveUpperGISite]
(
	@SiteId INT,
	@PrevRegionId INT,
	@RegionId INT
)
AS

/**************************************************************************
 Author:		Duncan
 Create date:	25 Jul 2019
 Description:	Called when a GI site is moved from one region to another. 
				Some abnormalities, therapeutics and Specimens are not 
				available in the new region so need to be deleted
***************************************************************************
*****                        Change History                           *****
***************************************************************************
** Rev	Date			Author		Description 
** --	-----------		---------	---------------------------------------
** 0	25 Jul 2019		Duncan		Created
** 
**
**************************************************************************/

SET NOCOUNT ON

--------------------------------------------------------------------------
-- Create Temp Table
--------------------------------------------------------------------------
create table #UpperGI (
	[RegionID] [int],
	[Gastritis] [bit] ,
	[Gastric Ulcer] [bit] ,
	[Lumen] [bit] ,
	[Malignancy] [bit] ,
	[Post Surgery] [bit] ,
	[Deformity] [bit] ,
	[Polyps] [bit] ,
	[Varices] [bit] ,
	[Hiatus Hernia] [bit] ,
	[Achalasia] [bit] ,
	[Oesophagitis] [bit] ,
	[Barretts] [bit] ,
	[Miscellaneous] [bit] ,
	[Diverticulum/Other] [bit] ,
	[Tumour] [bit] ,
	[Duodenitis] [bit] ,
	[Pyloric Ulcer] [bit] ,
	[Duodenal Ulcer] [bit] ,
	[Scarring/Stenosis] [bit] ,
	[Vascular Lesions] [bit] ,
	[Atrophic Duodenum] [bit] ,
	[Mediastinal] [bit],
	Area Varchar(50))

insert into #UpperGI 
Select r.RegionID
	  ,[Gastritis]
      ,[Gastric Ulcer]
      ,[Lumen]
      ,[Malignancy]
      ,[Post Surgery]
      ,[Deformity]
      ,[Polyps]
      ,[Varices]
      ,[Hiatus Hernia]
      ,[Achalasia]
      ,[Oesophagitis]
      ,[Barretts]
      ,[Miscellaneous]
      ,[Diverticulum/Other]
      ,[Tumour]
      ,[Duodenitis]
      ,[Pyloric Ulcer]
      ,[Duodenal Ulcer]
      ,[Scarring/Stenosis]
      ,[Vascular Lesions]
      ,[Atrophic Duodenum]
      ,[Mediastinal] 
	  ,Area
from ERS_AbnormalitiesMatrixUpperGI a
join ERS_Regions r on a.Region = r.Region
where a.ProcedureType = 1
and r.RegionId in (@PrevRegionId, @RegionId)

--------------------------------------------------------------------------
-- Check Abnormalities
--------------------------------------------------------------------------

if (Select Gastritis from #UpperGI where RegionId = @PrevRegionId) != (Select Gastritis from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_UpperGIAbnoGastritis WHERE SiteId = @SiteId
    DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Gastritis'
END

if (Select [Gastric Ulcer] from #UpperGI where RegionId = @PrevRegionId) != (Select [Gastric Ulcer] from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_UpperGIAbnoGastricUlcer WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Gastric Ulcer'
END

if (Select Lumen from #UpperGI where RegionId = @PrevRegionId) != (Select Lumen from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_UpperGIAbnoLumen WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Lumen'
END

if (Select Malignancy from #UpperGI where RegionId = @PrevRegionId) != (Select Malignancy from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_UpperGIAbnoMalignancy WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Malignancy'
END

if (Select [Post Surgery] from #UpperGI where RegionId = @PrevRegionId) != (Select [Post Surgery] from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_UpperGIAbnoPostSurgery WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Post Surgery'
END

if (Select Deformity from #UpperGI where RegionId = @PrevRegionId) != (Select Deformity from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_UpperGIAbnoDeformity WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Deformity'
END

if (Select Polyps from #UpperGI where RegionId = @PrevRegionId) != (Select Polyps from #UpperGI where RegionId = @RegionId)
BEGIN	
	DELETE FROM ERS_UpperGIAbnoPolyps WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Polyps'
END

if (Select Varices from #UpperGI where RegionId = @PrevRegionId) != (Select Varices from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_UpperGIAbnoVarices WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Varices'
END

if (Select [Hiatus Hernia] from #UpperGI where RegionId = @PrevRegionId) != (Select [Hiatus Hernia] from #UpperGI where RegionId = @RegionId)
BEGIN	
	DELETE FROM ERS_UpperGIAbnoHiatusHernia WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Hiatus Hernia'
END

if (Select Achalasia from #UpperGI where RegionId = @PrevRegionId) != (Select Achalasia from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_UpperGIAbnoAchalasia WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Achalasia'
END

if (Select Oesophagitis from #UpperGI where RegionId = @PrevRegionId) != (Select Oesophagitis from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_UpperGIAbnoOesophagitis WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Oesophagitis'
END

if (Select Barretts from #UpperGI where RegionId = @PrevRegionId) != (Select Barretts from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_UpperGIAbnoBarrett WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Barretts'
END

if (Select Miscellaneous from #UpperGI where RegionId = @PrevRegionId) != (Select Miscellaneous from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_UpperGIAbnoMiscellaneous WHERE SiteId = @SiteId

if (Select [Diverticulum/Other] from #UpperGI where RegionId = @PrevRegionId) != (Select [Diverticulum/Other] from #UpperGI where RegionId = @RegionId)
	DELETE FROM ERS_CommonAbnoDiverticulum WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Miscellaneous'
END

if (Select Tumour from #UpperGI where RegionId = @PrevRegionId) != (Select Tumour from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_CommonAbnoTumour WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Tumour'
END

if (Select Duodenitis from #UpperGI where RegionId = @PrevRegionId) != (Select Duodenitis from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_CommonAbnoDuodenitis WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Duodenitis'
END

-- NOT USED IN UPPER GI PROCEDURES
--if (Select [Pyloric Ulcer] from #UpperGI where RegionId = @PrevRegionId) != (Select [Pyloric Ulcer] from #UpperGI where RegionId = @RegionId)
	--DELETE FROM ERS_UpperGIAbnoGastritis WHERE SiteId = @SiteId

if (Select [Duodenal Ulcer] from #UpperGI where RegionId = @PrevRegionId) != (Select [Duodenal Ulcer] from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_CommonAbnoDuodenalUlcer WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Duodenal Ulcer'
END

if (Select [Scarring/Stenosis] from #UpperGI where RegionId = @PrevRegionId) != (Select [Scarring/Stenosis] from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_CommonAbnoScaring WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Scarring/Stenosis'
END

if (Select [Vascular Lesions] from #UpperGI where RegionId = @PrevRegionId) != (Select [Vascular Lesions] from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_CommonAbnoVascularLesions WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Vascular Lesions'
END

if (Select [Atrophic Duodenum] from #UpperGI where RegionId = @PrevRegionId) != (Select [Atrophic Duodenum] from #UpperGI where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_CommonAbnoAtrophic WHERE SiteId = @SiteId
	DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'Atrophic Duodenum'
END

--Not used in Upper GI
--if (Select Mediastinal from #UpperGI where RegionId = @PrevRegionId) != (Select Mediastinal from #UpperGI where RegionId = @RegionId)
--	DELETE FROM ERS_UpperGIAbnoGastritis WHERE SiteId = @SiteId

--------------------------------------------------------------------------
-- Check Therapeutic Areas
--------------------------------------------------------------------------
IF (Select Area from #UpperGI where RegionId = @RegionId) = 'Oesophagus'
	UPDATE ERS_UpperGITherapeutics
	SET [Polypectomy] = 0
		,[PolypectomyRemoval] = 0
		,[PolypectomyRemovalType] = 0
		,[GastrostomyInsertion] = 0
		,[GastrostomyInsertionSize] = NULL
		,[GastrostomyInsertionUnits] = NULL
		,[GastrostomyInsertionType] = NULL
		,[GastrostomyInsertionBatchNo] = NULL
		,[CorrectPEGPlacement] = 0
		,[PEGPlacementFailureReason] = NULL
		,[GastrostomyPEGOutcome] = NULL
		,[GastrostomyRemoval] = 0
		,[PyloricDilatation] = 0
		,[PyloricLeadingToPerforation] = 0
	WHERE SiteId = @SiteId

IF (Select Area from #UpperGI where RegionId = @RegionId) = 'Stomach'
	UPDATE ERS_UpperGITherapeutics
	SET [OesophagealDilatation] = 0
		,[DilatedTo] = NULL
		,[DilatationUnits] = NULL
		,[DilatorType] = NULL
		,[DilatorScopePass] = 0
		,[PyloricDilatation] = 0
		,[PyloricLeadingToPerforation] = 0
		,[RFA] = 0
		,[RFAType] = 0
		,[pHProbeInsert] = 0
		,[pHProbeInsertAt] = NULL
		,[pHProbeInsertChk] = 0
		,[Haemospray] = 0
	WHERE SiteId = @SiteId

IF (Select Area from #UpperGI where RegionId = @RegionId) = 'Duodenum'
	UPDATE ERS_UpperGITherapeutics
	SET [OesophagealDilatation] = 0
		,[DilatedTo] = NULL
		,[DilatationUnits] = NULL
		,[DilatorType] = NULL
		,[DilatorScopePass] = 0
		,[Polypectomy] = 0
		,[PolypectomyRemoval] = 0
		,[PolypectomyRemovalType] = 0
		,[GastrostomyInsertion] = 0
		,[GastrostomyInsertionSize] = NULL
		,[GastrostomyInsertionUnits] = NULL
		,[GastrostomyInsertionType] = NULL
		,[GastrostomyInsertionBatchNo] = NULL
		,[CorrectPEGPlacement] = 0
		,[PEGPlacementFailureReason] = NULL
		,[GastrostomyPEGOutcome] = NULL
		,[GastrostomyRemoval] = 0
		,[VaricealSclerotherapy] = 0
		,[VaricealSclerotherapyInjectionType] = NULL
		,[VaricealSclerotherapyInjectionVol] = NULL
		,[VaricealSclerotherapyInjectionNum] = NULL
		,[VaricealBanding] = 0
		,[VaricealBandingNum] = NULL
		,[RFA] = 0
		,[RFAType] = 0
		,[pHProbeInsert] = 0
		,[pHProbeInsertAt] = NULL
		,[pHProbeInsertChk] = 0
		,[Haemospray] = 0
	WHERE SiteId = @SiteId

--------------------------------------------------------------------------
-- Check Specimens
--------------------------------------------------------------------------
IF (Select Area from #UpperGI where RegionId = @RegionId) = 'Oesophagus'
	UPDATE ERS_UpperGISpecimens
	SET [GastricWashing] = 0
		,[Urease] = 0
		,[UreaseResult] = 0
	WHERE SiteId = @SiteId

--Stomach has all specimens avalable
--IF (Select Area from #UpperGI where RegionId = @RegionId) = 'Stomach'

IF (Select Area from #UpperGI where RegionId = @RegionId) = 'Duodenum'
	UPDATE ERS_UpperGISpecimens
	SET [GastricWashing] = 0
		,[Polypectomy] = 0
		,[PolypectomyQty] = NULL
		,[HotBiopsy] = 0
		,[Urease] = 0
		,[UreaseResult] = 0
	WHERE SiteId = @SiteId

DROP table #UpperGI

GO

-----------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'MoveColonSite','S';
GO

CREATE PROCEDURE [dbo].[MoveColonSite]
(
	@SiteId INT,
	@PrevRegionId INT,
	@RegionId INT
)
AS

/**************************************************************************
 Author:		Duncan
 Create date:	25 Jul 2019
 Description:	Called when a Colonoscopy site is moved from one region to 
				another. Some abnormalities, therapeutics and Specimens are 
				not available in the new region so need to be deleted
***************************************************************************
*****                        Change History                           *****
***************************************************************************
** Rev	Date			Author		Description 
** --	-----------		---------	---------------------------------------
** 0	25 Jul 2019		Duncan		Created
** 
**
**************************************************************************/

SET NOCOUNT ON

--------------------------------------------------------------------------
-- Create Temp Table
--------------------------------------------------------------------------
create table #Colon (
	[RegionID] [int],
	[Perianal Lesions] [bit])

insert into #Colon 
Select r.RegionID
	  ,[Perianal Lesions]
from ERS_AbnormalitiesMatrixColon a
join ERS_Regions r on a.Region = r.Region
where a.ProcedureType = 3
and r.RegionId in (@PrevRegionId, @RegionId)

--------------------------------------------------------------------------
-- Check Abnormalities
--------------------------------------------------------------------------

if (Select [Perianal Lesions] from #Colon where RegionId = @PrevRegionId) != (Select [Perianal Lesions] from #Colon where RegionId = @RegionId)
BEGIN
	DELETE FROM ERS_ColonAbnoPerianalLesions WHERE SiteId = @SiteId
    DELETE FROM ERS_RecordCount WHERE SiteId = @SiteId AND Identifier = 'PerianalLesions'
END

--------------------------------------------------------------------------
-- Check Therapeutic Areas
--------------------------------------------------------------------------
IF (@RegionId = 3021)
	UPDATE ERS_UpperGITherapeutics
	SET [Sigmoidopexy] = 0
		,[SigmoidopexyQty] = NULL
		,[SigmoidopexyMake] = NULL
		,[SigmoidopexyFluids] = NULL
		,[SigmoidopexyFluidsDays] = NULL
		,[SigmoidopexyAntibiotics] = NULL
		,[SigmoidopexyAntibioticsDays] = NULL
	WHERE SiteId = @SiteId
else
	UPDATE ERS_UpperGITherapeutics
	SET BandingPiles = 0						
		,BandingNum = NULL
	WHERE SiteId = @SiteId

DROP table #Colon

GO

--------------------------------------------------------------------------

EXEC DropIfExist 'sites_update','S';
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



----------------------------------------------------------------------------

  IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ReportFooter' AND Object_ID = Object_ID(N'ERS_SystemConfig'))
	ALTER TABLE ERS_SystemConfig ADD ReportFooter Varchar(500) null
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC DropIfExist 'add_new_operating_hospital','S';
GO

CREATE PROCEDURE [dbo].[add_new_operating_hospital]
(
	@InternalHospitalID INT, 
	@NHSHospitalID VARCHAR(100), 
	@HospitalName VARCHAR(500), 
	@ContactNumber VARCHAR(50), 
	@ReportExportPath VARCHAR(1000),
	@ReportHeading VARCHAR(500),
    @ReportTrustType VARCHAR(500),
    @ReportSubHeading VARCHAR(500),
	@ReportFooter VARCHAR(500),
    @DepartmentName VARCHAR(500),
	@NEDExportPath VARCHAR(500),
	@NEDODSCode VARCHAR(50),
	@LoggedInUserId INT,
	@CopyPrintSettings BIT,
	@CopyPhraseLibrary BIT
)
AS

/**************************************************************************
 Author:		?
 Create date:	?
 Description:	Create a new operating hospital. Inserts into 
				OperatingHospital, System_Config and the print settings
***************************************************************************
*****                        Change History                           *****
***************************************************************************
** Rev	Date			Author		Description 
** --	-----------		---------	---------------------------------------
** 1	25 Jul 2019		Duncan		Added report footer to System Config
** 
**
**************************************************************************/
SET NOCOUNT ON

BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @NewOHID INT, @OperatingHospitalId INT

		SELECT TOP 1 @OperatingHospitalId = OperatingHospitalId FROM ERS_OperatingHospitals ORDER BY OperatingHospitalId

		INSERT INTO ERS_OperatingHospitals (InternalHospitalID, NHSHospitalID, HospitalName, ContactNumber, ReportExportPath)
		VALUES (@InternalHospitalID, @NHSHospitalID, @HospitalName, @ContactNumber, @ReportExportPath); 

		SET @NewOHID = SCOPE_IDENTITY()

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
			@NEDExportPath,
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

		SELECT @NewOHID
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
--------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC DropIfExist 'printreport_header_select','S';
GO

CREATE PROCEDURE [dbo].[printreport_header_select]
(
	@OperatingHospitalID SMALLINT,
	@ProcedureId INT=0,
	@EpisodeNo INT = 0,
	@PatientComboId VARCHAR(30) = NULL,
	@ProcedureType TINYINT,
	@EnableNHSType BIT = 0
)
AS
/**************************************************************************
 Author:		?
 Create date:	?
 Description:	Get report header information
***************************************************************************
*****                        Change History                           *****
***************************************************************************
** Rev	Date			Author		Description 
** --	-----------		---------	---------------------------------------
** 1	25 Jul 2019		Duncan		Added report footer from System Config
									Removed execute(@SQL) where possible
** 
**
**************************************************************************/
SET NOCOUNT ON

    DECLARE @RepHeader TABLE (ReportHeading VARCHAR(150), ReportSubHeading VARCHAR(150), ReportTrustType VARCHAR(150), OpHosp VARCHAR(150), ReportHeader varchar(500) )
    DECLARE @SQL NVARCHAR(MAX)

    IF @ProcedureId > 0
    BEGIN
		IF @EnableNHSType = 0
        BEGIN
			SELECT	ISNULL(p.PP_RepHead, '') AS ReportHeading
					,ISNULL(p.PP_RepSubHead, '') AS ReportSubHeading
					, '' as ReportFooter
					,'' AS ReportTrustType
					,ISNULL(p.PP_OpHosp, '') AS OpHosp
					,ISNULL((SELECT pt.[ReportHeader] 
							FROM ERS_ProcedureTypes AS pt 
							WHERE [ProcedureTypeId] = CONVERT(VARCHAR,@ProcedureType)),'REPORT') AS ReportHeader
			FROM	ERS_ProceduresReporting p
			WHERE	p.[ProcedureId] = CONVERT(VARCHAR,@ProcedureId )
        END
		ELSE
		BEGIN
			SELECT  ISNULL(s.[ReportHeading],o.[HospitalName]) AS ReportHeading 
					,ISNULL(s.[ReportSubHeading],'') AS ReportSubHeading
					, ISNULL(s.ReportFooter, '') as ReportFooter
					,ISNULL(s.[ReportTrustType], 'NHS Trust') AS ReportTrustType 
					,'' AS OpHosp
					, ISNULL((SELECT top(1) [ReportHeader] 
										FROM ERS_ProcedureTypes 
										WHERE [ProcedureTypeId]= CONVERT(VARCHAR,@ProcedureType)),'REPORT') AS ReportHeader
			FROM	[ERS_OperatingHospitals] o
			join	[ERS_SystemConfig] s 
							on o.OperatingHospitalID = s.OperatingHospitalID
			WHERE	o.OperatingHospitalID = CONVERT(VARCHAR,@OperatingHospitalID)
		END
    END
    ELSE
    BEGIN
        IF @EnableNHSType = 0
        BEGIN
            SET @SQL =	N'SELECT ISNULL(p.PP_RepHead,'''') AS ReportHeading
						, ISNULL(p.PP_RepSubHead,'''') AS ReportSubHeading
						, '' as ReportFooter
						, '''' AS ReportTrustType
						, ISNULL(p.PP_OpHosp,'''') AS OpHosp
						, ISNULL(p.[PP_RepType],''REPORT'') AS ReportHeader 
						FROM ' + dbo.fnGetUGI_tablename(@ProcedureType,'procedure') + ' p
						WHERE p.[Episode No] = ' + CONVERT(VARCHAR,@EpisodeNo) + 
						' AND p.[Patient No] = ''' + @PatientComboId + '''' 
			INSERT INTO @RepHeader EXECUTE (@SQL)
			SELECT * FROM @RepHeader        
		END
        ELSE
        BEGIN
            SELECT	ISNULL(s.[ReportHeading],o.[HospitalName]) AS ReportHeading 
					, ISNULL(s.[ReportSubHeading],'') AS ReportSubHeading
					, ISNULL(s.ReportFooter, '') as ReportFooter
                    , ISNULL(s.[ReportTrustType], 'NHS Trust') AS ReportTrustType 
                    , '' AS OpHosp
					, ISNULL((SELECT top(1) [ReportHeader] 
								FROM ERS_ProcedureTypes 
								WHERE [ProcedureTypeId]= CONVERT(VARCHAR,@ProcedureType)),'REPORT') AS ReportHeader
            FROM	[ERS_OperatingHospitals] o
			JOIN	[ERS_SystemConfig] s 
							on o.OperatingHospitalID = s.OperatingHospitalID
            WHERE	o.OperatingHospitalID = CONVERT(VARCHAR,@OperatingHospitalID)
        END
        --print @SQL

    END

GO

------------------------------------------------------------------------------------------------


