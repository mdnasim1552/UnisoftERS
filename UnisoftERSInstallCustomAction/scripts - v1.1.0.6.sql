IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D99P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Food Residue', 1, 'Oesophagus', 1, 99, 'D99P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Food Residue', 6, 'Oesophagus', 1, 99, 'D99P1', 0)
END
GO
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D100P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Other', 1, 'Oesophagus', 1, 99, 'D100P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Other', 6, 'Oesophagus', 1, 99, 'D100P1', 0)
END
GO
-----------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_UpperGIAbnoMiscellaneous_Insert', 'TR';
GO

CREATE TRIGGER [dbo].[TR_UpperGIAbnoMiscellaneous_Insert]
ON [dbo].[ERS_UpperGIAbnoMiscellaneous]
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @Diverticulum VARCHAR(10), @Foreignbody VARCHAR(10), @MaloryWeissTear VARCHAR(10), 
			@MotilityDisorder VARCHAR(10), @Stricture VARCHAR(10), @StrictureBenign VARCHAR(10), @StrictureMalignant VARCHAR(10), 
			@Tumour VARCHAR(10), @TumourBenign VARCHAR(10), @TumourProbablyBenign VARCHAR(10),
			@TumourMalignant VARCHAR(10), @TumourProbablyMalignant VARCHAR(10), @Ulcer VARCHAR(10), @Web VARCHAR(10), @SchatzkiRing VARCHAR(10), 
			@ExtrinsicCompression VARCHAR(10), @PharyngealPouch VARCHAR(10), @ScopeCouldNotPass VARCHAR(10), @InletPatch VARCHAR(10),
			@Other VARCHAR(10), @FoodResidue VARCHAR(10)

	SELECT @site_id=SiteId, 
			@Diverticulum = (CASE WHEN Diverticulum = 1 THEN 'True' ELSE 'False' END), 
			@Foreignbody = (CASE WHEN Foreignbody = 1 THEN 'True' ELSE 'False' END),
			@MaloryWeissTear = (CASE WHEN Mallory = 1 THEN 'True' ELSE 'False' END),
			@MotilityDisorder = (CASE WHEN MotilityDisorder = 1 THEN 'True' ELSE 'False' END),
			@Stricture = (CASE WHEN (Stricture = 1 AND StrictureType = 0) THEN 'True' ELSE 'False' END),
			@StrictureBenign = (CASE WHEN (Stricture = 1 AND StrictureType = 1) THEN 'True' ELSE 'False' END),
			@StrictureMalignant = (CASE WHEN (Stricture = 1 AND StrictureType = 2) THEN 'True' ELSE 'False' END),
			@Tumour = (CASE WHEN (Tumour = 1 AND TumourType = 0) THEN 'True' ELSE 'False' END),
			@TumourBenign = (CASE WHEN (Tumour = 1 AND TumourType = 1 AND TumourProbably <> 1) THEN 'True' ELSE 'False' END),
			@TumourProbablyBenign = (CASE WHEN (Tumour = 1 AND TumourType = 1 AND TumourProbably = 1) THEN 'True' ELSE 'False' END),
			@TumourMalignant = (CASE WHEN (Tumour = 1 AND TumourType = 2 AND TumourProbably <> 1) THEN 'True' ELSE 'False' END),
			@TumourProbablyMalignant = (CASE WHEN (Tumour = 1 AND TumourType = 2 AND TumourProbably = 1) THEN 'True' ELSE 'False' END),
			@Ulcer = (CASE WHEN (Ulceration = 1) THEN 'True' ELSE 'False' END),
			@Web = (CASE WHEN (Web = 1) THEN 'True' ELSE 'False' END),
			@SchatzkiRing = (CASE WHEN (SchatzkiRing = 1) THEN 'True' ELSE 'False' END),
			@ExtrinsicCompression = (CASE WHEN (ExtrinsicCompression = 1) THEN 'True' ELSE 'False' END),
			@PharyngealPouch = (CASE WHEN (Pharyngeal = 1) THEN 'True' ELSE 'False' END),
			@ScopeCouldNotPass = (CASE WHEN (StrictureScopeNotPass = 1) OR (TumourScopeNotPass = 1) THEN 'True' ELSE 'False' END),
			@InletPatch = (CASE WHEN (InletPatch = 1) AND (InletPatchQty > 0 OR InletPatchMultiple = 1) THEN 'True' ELSE 'False' END),
			@Other = (CASE WHEN (MiscOther != '') THEN 'True' ELSE 'False' END),
			@FoodResidue = (CASE WHEN (FoodResidue = 1) THEN 'True' ELSE 'False' END)
	FROM INSERTED

	EXEC ogd_kpi_stricture_perforation @site_id --Update perforation text in QA for OGD KPI

	EXEC abnormalities_miscellaneous_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D32P1', @Diverticulum			-- 'Diverticulum'
	EXEC diagnoses_control_save @site_id, 'D35P1', @Foreignbody				-- 'Foreignbody'
	EXEC diagnoses_control_save @site_id, 'D24P1', @MaloryWeissTear			-- 'MaloryWeissTear'
	EXEC diagnoses_control_save @site_id, 'D28P1', @MotilityDisorder		-- 'MotilityDisorder'
	EXEC diagnoses_control_save @site_id, 'D21P1', @Stricture				-- 'Stricture'
	EXEC diagnoses_control_save @site_id, 'D72P1', @StrictureBenign			-- 'StrictureBenign'
	EXEC diagnoses_control_save @site_id, 'D73P1', @StrictureMalignant		-- 'StrictureMalignant'
	EXEC diagnoses_control_save @site_id, 'D74P1', @Tumour					-- 'Tumour'
	EXEC diagnoses_control_save @site_id, 'D25P1', @TumourBenign			-- 'TumourBenign'
	EXEC diagnoses_control_save @site_id, 'D29P1', @TumourProbablyBenign	-- 'TumourProbablyBenign'
	EXEC diagnoses_control_save @site_id, 'D34P1', @TumourMalignant			-- 'TumourMalignant'
	EXEC diagnoses_control_save @site_id, 'D37P1', @TumourProbablyMalignant	-- 'TumourProbablyMalignant'
	EXEC diagnoses_control_save @site_id, 'D26P1', @Ulcer					-- 'Ulcer'
	EXEC diagnoses_control_save @site_id, 'D38P1', @Web						-- 'Web'
	EXEC diagnoses_control_save @site_id, 'D71P1', @SchatzkiRing			-- 'SchatzkiRing'
	EXEC diagnoses_control_save @site_id, 'D67P1', @ExtrinsicCompression	-- 'ExtrinsicCompression'
	EXEC diagnoses_control_save @site_id, 'D69P1', @PharyngealPouch			-- 'Pharyngeal Pouch
	EXEC diagnoses_control_save @site_id, 'D98P1', @InletPatch				
	EXEC diagnoses_control_save @site_id, 'D99P1', @FoodResidue				
	EXEC diagnoses_control_save @site_id, 'D100P1', @Other				
	EXEC diagnoses_control_save @site_id, 'StomachNotEntered', @ScopeCouldNotPass			-- 'scope could not pass
	EXEC diagnoses_control_save @site_id, 'DuodenumNotEntered', @ScopeCouldNotPass			-- 'scope could not pass
GO
-----------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_UpperGIAbnoMiscellaneous_Delete', 'TR';
GO

CREATE TRIGGER [dbo].[TR_UpperGIAbnoMiscellaneous_Delete]
ON [dbo].[ERS_UpperGIAbnoMiscellaneous]
AFTER DELETE
AS 
	DECLARE @site_id INT
	SELECT @site_id=SiteId FROM DELETED

	EXEC ogd_kpi_stricture_perforation @site_id --Update perforation text in QA for OGD KPI

	EXEC diagnoses_control_save @site_id, 'D32P1', 'False'		-- 'Diverticulum'
	EXEC diagnoses_control_save @site_id, 'D35P1', 'False'		-- 'Foreignbody'
	EXEC diagnoses_control_save @site_id, 'D24P1', 'False'		-- 'MaloryWeissTear'
	EXEC diagnoses_control_save @site_id, 'D28P1', 'False'		-- 'MotilityDisorder'
	EXEC diagnoses_control_save @site_id, 'D21P1', 'False'		-- 'Stricture'
	EXEC diagnoses_control_save @site_id, 'D72P1', 'False'		-- 'StrictureBenign'
	EXEC diagnoses_control_save @site_id, 'D73P1', 'False'		-- 'StrictureMalignant'
	EXEC diagnoses_control_save @site_id, 'D74P1', 'False'		-- 'Tumour'
	EXEC diagnoses_control_save @site_id, 'D25P1', 'False'		-- 'TumourBenign'
	EXEC diagnoses_control_save @site_id, 'D29P1', 'False'		-- 'TumourProbablyBenign'
	EXEC diagnoses_control_save @site_id, 'D34P1', 'False'		-- 'TumourMalignant'
	EXEC diagnoses_control_save @site_id, 'D37P1', 'False'		-- 'TumourProbablyMalignant'
	EXEC diagnoses_control_save @site_id, 'D26P1', 'False'		-- 'Ulcer'
	EXEC diagnoses_control_save @site_id, 'D38P1', 'False'		-- 'Web'
	EXEC diagnoses_control_save @site_id, 'D71P1', 'False'		-- 'SchatzkiRing'
	EXEC diagnoses_control_save @site_id, 'D67P1', 'False'		-- 'ExtrinsicCompression'
	EXEC diagnoses_control_save @site_id, 'D69P1', 'False'		-- 'Pharyngeal Pouch'
	EXEC diagnoses_control_save @site_id, 'D98P1', 'False'		-- 'Inlet Patch'				
	EXEC diagnoses_control_save @site_id, 'D99P1', 'False'		-- 'Food Residue'		
	EXEC diagnoses_control_save @site_id, 'D100P1', 'False'		-- 'Other'
	EXEC diagnoses_control_save @site_id, 'StomachNotEntered', 'False'			-- 'scope could not pass
	EXEC diagnoses_control_save @site_id, 'DuodenumNotEntered', 'False'			-- 'scope could not pass

	EXEC sites_summary_update @site_id
GO

-----------------------------------------------------------------------------------------------------------

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D101P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Other Deformity', 1, 'Stomach', 1, 99, 'D101P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Other Deformity', 6, 'Stomach', 1, 99, 'D101P1', 0)
END
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D102P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Cup and spill stomach', 1, 'Stomach', 1, 99, 'D102P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Cup and spill stomach', 6, 'Stomach', 1, 99, 'D102P1', 0)
END
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D103P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Hourglass stomach', 1, 'Stomach', 1, 99, 'D103P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Hourglass stomach', 6, 'Stomach', 1, 99, 'D103P1', 0)
END
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D104P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Post operative stenosis ', 1, 'Stomach', 1, 99, 'D104P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Post operative stenosis ', 6, 'Stomach', 1, 99, 'D104P1', 0)
END
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D105P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('J-shaped stomach', 1, 'Stomach', 1, 99, 'D105P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('J-shaped stomach', 6, 'Stomach', 1, 99, 'D105P1', 0)
END
GO

-----------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_UpperGIAbnoDeformity_Insert', 'TR';
GO
EXEC DropIfExist 'TR_UpperGIAbnoDeformity_Delete', 'TR';
GO
EXEC DropIfExist 'TR_UpperGIAbnoDeformity', 'TR';
GO

CREATE TRIGGER [dbo].[TR_UpperGIAbnoDeformity]
ON [dbo].[ERS_UpperGIAbnoDeformity]
AFTER INSERT, UPDATE, DELETE 
AS 
	DECLARE @site_id INT, 
			@Action CHAR(1) = 'I',
			@PyloricStenosis VARCHAR(10) = 'False', 
			@TumorSubmucosal VARCHAR(10) = 'False', 
			@ExtrinsicCompression VARCHAR(10) = 'False', 
			@Deformity VARCHAR(10) = 'False',
			@CupAndSpill VARCHAR(10) = 'False', 
			@Hourglass VARCHAR(10) = 'False', 
			@PostOpStenosis VARCHAR(10) = 'False', 
			@JShaped VARCHAR(10) = 'False', 
			@Other VARCHAR(10) = 'False'

	IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@ExtrinsicCompression = (CASE WHEN (DeformityType=1) THEN 'True' ELSE 'False' END),
				@CupAndSpill = (CASE WHEN (DeformityType=2) THEN 'True' ELSE 'False' END),
				@Hourglass = (CASE WHEN (DeformityType=3) THEN 'True' ELSE 'False' END),
				@PostOpStenosis = (CASE WHEN (DeformityType=4) THEN 'True' ELSE 'False' END),
				@JShaped = (CASE WHEN (DeformityType=5) THEN 'True' ELSE 'False' END),
				@TumorSubmucosal = (CASE WHEN (DeformityType=6) THEN 'True' ELSE 'False' END),
				@Other = (CASE WHEN (DeformityType=7) THEN 'True' ELSE 'False' END)
				--@Deformity = (CASE WHEN (DeformityType IN (2,3,5,6)) THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_deformity_summary_update @site_id
	END
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D88P1', @TumorSubmucosal			-- 'Tumor Submucosal'
	EXEC diagnoses_control_save @site_id, 'D9551', @ExtrinsicCompression	
	EXEC diagnoses_control_save @site_id, 'D102P1', @CupAndSpill	
	EXEC diagnoses_control_save @site_id, 'D103P1', @Hourglass	
	EXEC diagnoses_control_save @site_id, 'D104P1', @PostOpStenosis	
	EXEC diagnoses_control_save @site_id, 'D101P1', @Other	
	EXEC diagnoses_control_save @site_id, 'D105P1', @JShaped	
GO

-----------------------------------------------------------------------------------------------------------

  update ERS_SiteDetailsMenuUrls 
  set  NavigateUrl = '~/Products/Gastro/Abnormalities/Common/DuodenalUlcer.aspx'
  where Menu = 'Pyloric Ulcer'
GO

-----------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'abnormalities_duodenal_ulcer_summary_update', 'S';
GO
-----------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[abnormalities_duodenal_ulcer_summary_update]
(
	@SiteId INT
)
AS
	SET NOCOUNT ON
	DECLARE
		@Summary VARCHAR(4000),
		@None BIT,
		@Ulcer BIT,
		@UlcerType TINYINT, 
		@Quantity SMALLINT, 
		@Largest SMALLINT, 
		@VisibleVessel BIT, 
		@VisibleVesselType TINYINT, 
		@FreshClot BIT, 
		@ActiveBleeding BIT, 
		@ActiveBleedingType TINYINT, 
		@OldClot BIT, 
		@Perforation BIT

	SELECT 
		@None=[None],
		@Ulcer=Ulcer,
		@UlcerType=UlcerType,
		@Quantity = Quantity, 
		@Largest = Largest, 
		@VisibleVessel = VisibleVessel, 
		@VisibleVesselType = VisibleVesselType, 
		@FreshClot = FreshClot, 
		@ActiveBleeding = ActiveBleeding, 
		@ActiveBleedingType = ActiveBleedingType, 
		@OldClot = OldClot, 
		@Perforation = Perforation
	FROM
		ERS_CommonAbnoDuodenalUlcer
	WHERE
		SiteId = @SiteId

		DECLARE @Region VARCHAR(50), @RegionIdentifier VARCHAR(50)
		SELECT @Region =Region FROM dbo.ERS_Sites es
			INNER JOIN dbo.ERS_Regions er ON es.RegionId = er.RegionId
		WHERE es.SiteId = @SiteId

	SET @Summary = ''
	
	IF @None = 1
	BEGIN
		IF (@Region = 'Jejunum')
			SET @Summary = 'No jejunal ulcer'
		ELSE IF @Region = 'Ileum'
			SET @Summary = 'No ileal ulcer'
		ELSE IF @Region in ('Pylorus', 'Superior Pylorus', 'Inferior Pylorus')
			SET @Summary = 'No pyloric ulcer'
		ELSE
			SET @Summary = 'No duodenal ulcer'

	END
	ELSE IF @Ulcer = 1 
	BEGIN
		DECLARE @tmpDiv TABLE(Val VARCHAR(MAX))
		DECLARE @XMLlist XML
		DECLARE @b VARCHAR(200) = ''

		IF (@Region = 'Jejunum')
			SET @Summary = 'Jejunal ulcer:'
		ELSE IF @Region = 'Ileum'
			SET @Summary = 'Ileal ulcer:'
		ELSE IF @Region in ('Pylorus', 'Superior Pylorus', 'Inferior Pylorus')
			SET @Summary = 'Pyloric ulcer'
		ELSE
			SET @Summary = 'Duodenal ulcer:'


		IF ISNULL(@Quantity,0) > 0 SET @Summary = @Summary + ' ' + CONVERT(VARCHAR(20),@Quantity)

		IF @UlcerType = 1
		BEGIN
			SET @Summary = @Summary + ' acute' 
		END
		ELSE IF @UlcerType = 2
		BEGIN
			SET @Summary = @Summary + ' chronic' 
		END
		
		--IF @Largest > 0
		--BEGIN
			IF ISNULL(@Largest,0) > 0 SET @Summary = @Summary + ' (largest diameter ' + CONVERT(VARCHAR(20),@Largest) + 'cm)'
            --ELSE SET @Summary = @Summary + ' (diameter ' + CONVERT(VARCHAR(20),@Largest) + 'cm)'
		--END
		
		IF @VisibleVessel = 1
		BEGIN
            SET @b = 'visible vessel'
			IF @VisibleVesselType = 1		SET @b = @b + ' (adherent clot in base)'
			ELSE IF @VisibleVesselType = 2	SET @b = @b + ' (pigmented base)'

			INSERT INTO @tmpDiv (Val) VALUES(@b)
		END

		IF @ActiveBleeding = 1
		BEGIN
            SET @b = 'active bleeding'
			IF @ActiveBleedingType = 1		SET @b = @b + ' (spurting)'
			ELSE IF @ActiveBleedingType = 2	SET @b = @b + ' (oozing)'

			INSERT INTO @tmpDiv (Val) VALUES(@b)
		END

		IF @FreshClot = 1 INSERT INTO @tmpDiv (Val) VALUES('fresh clotting')

		IF @OldClot = 1 INSERT INTO @tmpDiv (Val) VALUES('old clotting')

		IF @Perforation = 1 INSERT INTO @tmpDiv (Val) VALUES('perforation')

		IF (SELECT COUNT(Val) FROM @tmpDiv) > 0 
		BEGIN
			SET @XMLlist = (SELECT Val FROM @tmpDiv FOR XML  RAW, ELEMENTS, TYPE)
			SET @summary = @Summary + ' with ' +  dbo.fnBuildString(@XMLlist)
		END


		IF RIGHT(@Summary,1) = ':' SET @summary = REPLACE(@summary,':','')
	END

	-- Finally update the summary in abnormalities table
	UPDATE ERS_CommonAbnoDuodenalUlcer
	SET Summary = @Summary 
	WHERE SiteId = @siteId

GO

-----------------------------------------------------------------------------------------------------------
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D106P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Varices', 1, 'Duodenum', 1, 99, 'D106P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Varices', 6, 'Duodenum', 1, 99, 'D106P1', 0)
END
GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_CommonAbnoVascularLesions', 'TR';
GO
EXEC DropIfExist 'TR_CommonAbnoVascularLesions_Delete', 'TR';
GO

CREATE TRIGGER [dbo].[TR_CommonAbnoVascularLesions]
ON [dbo].[ERS_CommonAbnoVascularLesions]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @Telangiectasia VARCHAR(10) = 'False', @Angioma VARCHAR(10) = 'False', 
			@StomachTelangiectasia VARCHAR(10) = 'False', @PortalHypertensiveGastropathy VARCHAR(10) = 'False', 
			@TelangiectasiaAngioma VARCHAR(10) = 'False', @Angiodysplasia VARCHAR(10) = 'False', 
			@Action CHAR(1) = 'I' , @DieulafoyLesion VARCHAR(10) = 'False', @DuodenumVarices VARCHAR(10) = 'False'

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Telangiectasia = (CASE WHEN ([Type] = 1 AND [Area] = 'Oesophagus') THEN 'True' ELSE 'False' END),
				@Angioma = (CASE WHEN (Area='Stomach' AND ([Type] = 2 OR [Type] = 3 OR [Type] = 4)) THEN 'True' ELSE 'False' END),
				@StomachTelangiectasia = (CASE WHEN ([Type]=1 AND [Area]='Stomach') THEN 'True' ELSE 'False' END),
				@PortalHypertensiveGastropathy = (CASE WHEN (Area='Stomach' AND [Type]=5) THEN 'True' ELSE 'False' END),
				@DuodenumVarices = (CASE WHEN (Area='Duodenum' AND [Type]=5) THEN 'True' ELSE 'False' END),
				@TelangiectasiaAngioma = (CASE WHEN ( Area='Duodenum' AND ([Type] = 1 OR [Type] = 2 OR [Type] = 3 OR [Type] = 4)) THEN 'True' ELSE 'False' END),
				@Angiodysplasia = (CASE WHEN ([Type] BETWEEN 2 AND 5) THEN 'True' ELSE 'False' END),
				@DieulafoyLesion = (CASE WHEN [Type] > 0 AND [Area] = 'Stomach' THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_vascular_lesions_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	IF ISNULL((SELECT p.ProcedureType FROM ers_sites s 
		INNER JOIN ers_procedures p ON s.ProcedureId = p.ProcedureId 
		WHERE SiteId = @site_id),0) = 2   --Check If ERCP (2), else proceed with OGD
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D64P2', @Angiodysplasia					-- 'Angiodysplasia'
	END
	ELSE
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D22P1', @Telangiectasia					-- 'Telangiectasia'
		EXEC diagnoses_control_save @site_id, 'D43P1', @Angioma							-- 'Angioma'
		EXEC diagnoses_control_save @site_id, 'D46P1', @StomachTelangiectasia			-- 'StomachTelangiectasia'
		EXEC diagnoses_control_save @site_id, 'D52P1', @PortalHypertensiveGastropathy	-- 'PortalHypertensiveGastropathy'
		EXEC diagnoses_control_save @site_id, 'D59P1', @TelangiectasiaAngioma			-- 'TelangiectasiaAngioma'
		EXEC diagnoses_control_save @site_id, 'D80P1', @DieulafoyLesion					-- 'Dieulafoy Lesion'
		EXEC diagnoses_control_save @site_id, 'D106P1', @DuodenumVarices
	END
GO


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


-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_UpperGIAbnoAchalasia_Insert', 'TR';
GO

CREATE TRIGGER [dbo].[TR_UpperGIAbnoAchalasia_Insert]
ON [dbo].[ERS_UpperGIAbnoAchalasia]
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @Achalasia VARCHAR(10)
	SELECT @site_id=SiteId,
			@Achalasia = (CASE WHEN ([None]=1) THEN 'False' ELSE 'True' END)
	FROM INSERTED

	EXEC ogd_kpi_stricture_perforation @site_id --Update perforation text in QA for OGD KPI

	EXEC abnormalities_achalasia_summary_update @site_id
	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D66P1', @Achalasia
GO
-----------------------------------------------------------------------------------------------------------
update ERS_DiagnosesMatrix
set DisplayName = 'Oesophagitis/candida'
where Code = 'D27P1'
GO
-----------------------------------------------------------------------------------------------------------
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D107P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Normal mucosa', 1, 'Oesophagus', 1, 99, 'D107P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Normal mucosa', 6, 'Oesophagus', 1, 99, 'D107P1', 0)
END
GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_UpperGIAbnoOesophagitis_Insert', 'TR';
GO
EXEC DropIfExist 'TR_UpperGIAbnoOesophagitis_Delete', 'TR';
GO
EXEC DropIfExist 'TR_UpperGIAbnoOesophagitis', 'TR';
GO

CREATE TRIGGER [dbo].[TR_UpperGIAbnoOesophagitis]
ON [dbo].[ERS_UpperGIAbnoOesophagitis]
AFTER INSERT, UPDATE, DELETE 
AS 
	DECLARE @site_id INT, 
			@Action CHAR(1) = 'I', 
			@SuspectedCandida VARCHAR(10) = 'False', 
			@OesophagitisOther VARCHAR(10) = 'False', 
			@OesophagitisReflux VARCHAR(10) = 'False', 
			@NormalMuscosa VARCHAR(10) = 'False'

	IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId, 
				@SuspectedCandida	= (CASE WHEN SuspectedCandida = 1 THEN 'True' ELSE 'False' END),
				@NormalMuscosa	= (CASE WHEN (MucosalAppearance = 1) THEN 'True' ELSE 'False' END),
				@OesophagitisOther	= (CASE WHEN (MucosalAppearance > 1 OR (Other = 1 AND SuspectedCandida != 1)) THEN 'True' ELSE 'False' END),
				@OesophagitisReflux	= (CASE WHEN (Reflux = 1) THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_oesophagitis_summary_update @site_id
	END
	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC diagnoses_control_save @site_id , 'D27P1', @SuspectedCandida		-- 'Candida'
	EXEC diagnoses_control_save @site_id , 'D33P1', @OesophagitisOther		-- 'OesophagitisOther'
	EXEC diagnoses_control_save @site_id , 'D36P1', @OesophagitisReflux		-- 'OesophagitisReflux'
	EXEC diagnoses_control_save @site_id , 'D107P1', @NormalMuscosa		-- 'Normal Muscosa'
	EXEC sites_summary_update @site_id
GO
-----------------------------------------------------------------------------------------------------------
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D108P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Duodenum previously removed', 1, 'Duodenum', 1, 99, 'D108P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Duodenum previously removed', 6, 'Duodenum', 1, 99, 'D108P1', 0)
END
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D109P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Gastroenterostomy ', 1, 'Duodenum', 1, 99, 'D109P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Gastroenterostomy ', 6, 'Duodenum', 1, 99, 'D109P1', 0)
END
GO

EXEC DropIfExist 'TR_UpperGIAbnoPostSurgery_Insert', 'TR';
GO
EXEC DropIfExist 'TR_UpperGIAbnoPostSurgery_Delete', 'TR';
GO
EXEC DropIfExist 'TR_UpperGIAbnoPostSurgery', 'TR';
GO


CREATE TRIGGER [dbo].[TR_UpperGIAbnoPostSurgery]
ON [dbo].[ERS_UpperGIAbnoPostSurgery]
AFTER INSERT, UPDATE, DELETE 
AS 
	DECLARE @site_id INT, 
			@Action CHAR(1) = 'I', 
			@PostSurgicalStomach VARCHAR(10) = 'False', 
			@PostSurgicalOesoph VARCHAR(10) = 'False',
			@DuodenumNotPresent VARCHAR(10) = 'False',
			@Jejunum  VARCHAR(10) = 'False',
			@Area varchar(20), 
			@Code varchar(5)

	IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	IF @Action IN ('I', 'U') 
	BEGIN

		SELECT @site_id=SiteId FROM inserted

		Select @Area = x.area
		FROM ERS_AbnormalitiesMatrixUpperGI x
		INNER JOIN ERS_Regions r ON x.region = r.Region AND x.ProcedureType = r.ProcedureType  
		INNER JOIN ers_sites s ON r.RegionId = s.RegionId 
		where s.SiteId = @site_id
		AND x.ProcedureType =  1

		IF @Area = 'Stomach'
		BEGIN
			SELECT	@site_id=SiteId,
					@PostSurgicalStomach = (CASE WHEN (PreviousSurgery=1) THEN 'True' ELSE 'False' END),
					@DuodenumNotPresent = (CASE WHEN (DuodenumPresent=1) THEN 'True' ELSE 'False' END),
					@Jejunum = (CASE WHEN (JejunumState>0) THEN 'True' ELSE 'False' END)
			FROM INSERTED
		END

		IF @Area = 'Oesophagus' 
		BEGIN
		SELECT	@site_id=SiteId,
					@PostSurgicalOesoph = (CASE WHEN (PreviousSurgery=1) THEN 'True' ELSE 'False' END)
			FROM INSERTED
		END

		EXEC abnormalities_postsurgery_summary_update @site_id
	END

	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D45P1', @PostSurgicalStomach			
	EXEC diagnoses_control_save @site_id, 'D97P1', @PostSurgicalOesoph			
	EXEC diagnoses_control_save @site_id, 'D108P1', @DuodenumNotPresent			
	EXEC diagnoses_control_save @site_id, 'D109P1', @Jejunum			
GO
-----------------------------------------------------------------------------------------------------------
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D110P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Varices with bleeding', 'Gastric varices', 1, 'Stomach', 1, 99, 'D110P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, NED_Name, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Varices with bleeding', 'Gastric varices', 6, 'Stomach', 1, 99, 'D110P1', 0)
END
GO


EXEC DropIfExist 'TR_UpperGIAbnoVarices_Insert', 'TR';
GO
EXEC DropIfExist 'TR_UpperGIAbnoVarices_Delete', 'TR';
GO
EXEC DropIfExist 'TR_UpperGIAbnoVarices', 'TR';
GO


CREATE TRIGGER [dbo].[TR_UpperGIAbnoVarices]
ON [dbo].[ERS_UpperGIAbnoVarices]
AFTER INSERT, UPDATE, DELETE 
AS 
	DECLARE @site_id INT, 
			@Action CHAR(1) = 'I', 
			@Area varchar(20),
			@Varices VARCHAR(10) = 'False', 
			@VaricesBleeding VARCHAR(10) = 'False', 
			@StomachVarices VARCHAR(10) = 'False',
			@StomachVaricesBleeding VARCHAR(10) = 'False'

	IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId FROM inserted

		Select @Area = x.area
		FROM ERS_AbnormalitiesMatrixUpperGI x
		INNER JOIN ERS_Regions r ON x.region = r.Region AND x.ProcedureType = r.ProcedureType  
		INNER JOIN ers_sites s ON r.RegionId = s.RegionId 
		where s.SiteId = @site_id
		AND x.ProcedureType =  1

		IF @Area = 'Stomach'
		BEGIN
			SELECT  @StomachVarices = (CASE WHEN Grading > 0 AND ISNULL(Bleeding,0) <= 1 THEN 'True' ELSE 'False' END),
					@StomachVaricesBleeding = (CASE WHEN Grading > 0 AND Bleeding > 1 THEN 'True' ELSE 'False' END)
			FROM INSERTED
		END
		IF @Area = 'Oesophagus' 
		BEGIN
			SELECT  @Varices = (CASE WHEN Grading > 0 AND ISNULL(Bleeding,0) <= 1 THEN 'True' ELSE 'False' END),
					@VaricesBleeding = (CASE WHEN Grading > 0 AND Bleeding > 1 THEN 'True' ELSE 'False' END)
			FROM INSERTED
		END
		EXEC abnormalities_varices_summary_update @site_id
	END

	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D30P1', @Varices				-- 'Varices'
	EXEC diagnoses_control_save @site_id, 'D31P1', @VaricesBleeding		-- 'VaricesBleeding'
	EXEC diagnoses_control_save @site_id, 'D47P1', @StomachVarices		-- 'StomachVarices'
	EXEC diagnoses_control_save @site_id, 'D110P1', @StomachVaricesBleeding		-- 'StomachVaricesBleeding'
GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_UpperGIAbnoGastritis_Insert', 'TR';
GO
EXEC DropIfExist 'TR_UpperGIAbnoGastritis_Delete', 'TR';
GO
EXEC DropIfExist 'TR_UpperGIAbnoGastritis', 'TR';
GO


CREATE TRIGGER [dbo].[TR_UpperGIAbnoGastritis]
ON [dbo].[ERS_UpperGIAbnoGastritis]
AFTER INSERT, UPDATE, DELETE 
AS 
	DECLARE @site_id INT, 
			@Action CHAR(1) = 'I',
			@Erosive VARCHAR(10) = 'False', 
			@Gastritis VARCHAR(10) = 'False', 
			@NonErosive VARCHAR(10) = 'False'

	IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT	@site_id=SiteId,
				@NonErosive = (CASE WHEN Atrophic=1 OR Erythematous=1 OR Haemorrhagic=1 OR Reflux=1 OR RugalHyperplastic=1 OR PromAreaeGastricae=1 OR Vomiting=1 THEN 'True' ELSE 'False' END),
				@Erosive = (CASE WHEN (FlatErosive=1 OR RaisedErosive=1) THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_gastritis_summary_update @site_id
	END
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	
	EXEC diagnoses_control_save @site_id, 'D39P1', @Erosive				-- 'Erosive'
	EXEC diagnoses_control_save @site_id, 'D84P1', @NonErosive			-- 'Non Erosive'
GO
-----------------------------------------------------------------------------------------------------------
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D111P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Duodenal stenosis', 1, 'Duodenum', 1, 99, 'D111P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Duodenal stenosis', 6, 'Duodenum', 1, 99, 'D111P1', 0)
END
GO
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D112P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Pseudodiverticulum', 1, 'Duodenum', 1, 99, 'D112P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Pseudodiverticulum', 6, 'Duodenum', 1, 99, 'D112P1', 0)
END
GO

IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D113P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Deformity', 1, 'Duodenum', 1, 99, 'D113P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Deformity', 6, 'Duodenum', 1, 99, 'D113P1', 0)
END
GO
IF (NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix where Code = 'D114P1'))
BEGIN
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Pyloric deformity', 1, 'Stomach', 1, 99, 'D114P1', 0)	
	
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Pyloric deformity', 6, 'Stomach', 1, 99, 'D114P1', 0)
END
GO




EXEC DropIfExist 'TR_CommonAbnoScaring_Insert', 'TR';
GO
EXEC DropIfExist 'TR_CommonAbnoScaring_Delete', 'TR';
GO
EXEC DropIfExist 'TR_CommonAbnoScaring', 'TR';
GO


CREATE TRIGGER [dbo].[TR_CommonAbnoScaring]
ON [dbo].[ERS_CommonAbnoScaring]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, 
			@Action CHAR(1) = 'I',
			@Scar VARCHAR(10) = 'False', 
			@PylorusStenosis VARCHAR(10) = 'False',
			@DuodStenosis VARCHAR(10) = 'False',
			@DuodPsudodivert VARCHAR(10) = 'False',
			@PylorusDeform VARCHAR(10) = 'False',
			@DuodDeform VARCHAR(10) = 'False'
			

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Scar = (CASE WHEN (DuodUlcerScar = 1) OR (PylorusScar = 1) THEN 'True' ELSE 'False' END),
				@PylorusStenosis = (CASE WHEN (PyloricStenosis = 1) THEN 'True' ELSE 'False' END),
				@DuodStenosis = (CASE WHEN (DuodStenosis = 1) THEN 'True' ELSE 'False' END),
				@DuodPsudodivert = (CASE WHEN (DuodPsudodivert = 1) THEN 'True' ELSE 'False' END),
				@PylorusDeform = (CASE WHEN (PylorusDeformity = 1) THEN 'True' ELSE 'False' END),
				@DuodDeform = (CASE WHEN (DuodDeformity = 1) THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_scaring_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D54P1', @Scar				-- 'Scar'
	EXEC diagnoses_control_save @site_id, 'D50P1', @PylorusStenosis		-- 'Pylorus Stenosis'
	EXEC diagnoses_control_save @site_id, 'D111P1', @DuodStenosis		-- 'Duodenal Stenosis'
	EXEC diagnoses_control_save @site_id, 'D112P1', @DuodPsudodivert	-- 'Duodenal pseudodiverticulum'
	EXEC diagnoses_control_save @site_id, 'D113P1', @DuodDeform			-- 'Duodenal deformity.'
	EXEC diagnoses_control_save @site_id, 'D114P1', @PylorusDeform		-- 'Pylorus deformity.'
GO

-----------------------------------------------------------------------------------------------------------
update [ERS_FieldLabels] 
set LabelName = 'Indistinct',
	Hint = 'Indistinct (option)'
where LabelName = 'Indistict'
GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ColonAbnoVascularity_Insert', 'TR';
GO
EXEC DropIfExist 'TR_ColonAbnoVascularity_Delete', 'TR';
GO
EXEC DropIfExist 'TR_ColonAbnoVascularity', 'TR';
GO



CREATE TRIGGER [dbo].[TR_ColonAbnoVascularity]
ON [dbo].[ERS_ColonAbnoVascularity]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, 
			@Action CHAR(1) = 'I',
			@Angiodysplasia VARCHAR(10) = 'False', 
			@ColonTelangiectasia VARCHAR(10) = 'False',
			@Indistinct VARCHAR(10) = 'False',
			@Exaggerated VARCHAR(10) = 'False',
			@Attenuated VARCHAR(10) = 'False'

	IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Indistinct = (CASE WHEN (Indistinct=1) THEN 'True' ELSE 'False' END),
				@Exaggerated = (CASE WHEN (Exaggerated=1) THEN 'True' ELSE 'False' END),
				@Attenuated = (CASE WHEN (Attenuated=1) THEN 'True' ELSE 'False' END),
				@Angiodysplasia = (CASE WHEN (Angiodysplasia=1) THEN 'True' ELSE 'False' END),
				@ColonTelangiectasia = (CASE WHEN (Telangeiectasia=1) THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_colon_vascularity_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D64P3', @Angiodysplasia			-- 'Angiodysplasia'
	EXEC diagnoses_control_save @site_id, 'D14P3', @ColonTelangiectasia		-- 'ColonTelangiectasia'
	EXEC diagnoses_control_save @site_id, 'D22P3', @Indistinct		-- 'Indistinct'
	EXEC diagnoses_control_save @site_id, 'D23P3', @Exaggerated		-- 'Exaggerated'
	EXEC diagnoses_control_save @site_id, 'D24P3', @Attenuated		-- 'Attenuated'
GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ColonAbnoMiscellaneous_Insert', 'TR';
GO
EXEC DropIfExist 'TR_ColonAbnoMiscellaneous_Delete', 'TR';
GO
EXEC DropIfExist 'TR_ColonAbnoMiscellaneous', 'TR';
GO

CREATE TRIGGER [dbo].[TR_ColonAbnoMiscellaneous]
ON [dbo].[ERS_ColonAbnoMiscellaneous]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, 
			@Action CHAR(1) = 'I',
			@Crohns VARCHAR(10) = 'False',
			@Fistula VARCHAR(10) = 'False',
			@ForeignBody VARCHAR(10) = 'False',
			@Lipoma VARCHAR(10) = 'False',
			@Melanosis VARCHAR(10) = 'False',
			@Parasites VARCHAR(10) = 'False',
			@PneuColi VARCHAR(10) = 'False',
			@PolypSyndrome VARCHAR(10) = 'False',
			@PostOp VARCHAR(10) = 'False',
			@PseudoObstruction VARCHAR(10) = 'False'

	IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Crohns = (CASE WHEN (Crohn=1) THEN 'True' ELSE 'False' END),
				@Fistula = (CASE WHEN (Fistula=1) THEN 'True' ELSE 'False' END),
				@ForeignBody = (CASE WHEN (ForeignBody=1) THEN 'True' ELSE 'False' END),
				@Lipoma = (CASE WHEN (Lipoma=1) THEN 'True' ELSE 'False' END),
				@Melanosis = (CASE WHEN (Melanosis=1) THEN 'True' ELSE 'False' END),
				@Parasites = (CASE WHEN (Parasites=1) THEN 'True' ELSE 'False' END),
				@PneuColi = (CASE WHEN (PneumatosisColi=1) THEN 'True' ELSE 'False' END),
				@PolypSyndrome = (CASE WHEN (PolyposisSyndrome=1) THEN 'True' ELSE 'False' END),
				@PostOp = (CASE WHEN (PostoperativeAppearance=1) THEN 'True' ELSE 'False' END),
				@PseudoObstruction = (CASE WHEN (PseudoObstruction=1) THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_colon_miscellaneous_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id
	EXEC diagnoses_control_save @site_id, 'D86P3', @Crohns			
	EXEC diagnoses_control_save @site_id, 'D71P3', @Fistula			
	EXEC diagnoses_control_save @site_id, 'D72P3', @ForeignBody			
	EXEC diagnoses_control_save @site_id, 'D73P3', @Lipoma			
	EXEC diagnoses_control_save @site_id, 'D74P3', @Melanosis			
	EXEC diagnoses_control_save @site_id, 'D75P3', @Parasites			
	EXEC diagnoses_control_save @site_id, 'D76P3', @PneuColi			
	EXEC diagnoses_control_save @site_id, 'D77P3', @PolypSyndrome			
	EXEC diagnoses_control_save @site_id, 'D78P3', @PostOp			
	EXEC diagnoses_control_save @site_id, 'D9P3', @PseudoObstruction			
GO

-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_CommonAbnoTumour', 'TR';
GO

CREATE TRIGGER [dbo].[TR_CommonAbnoTumour]
ON [dbo].[ERS_CommonAbnoTumour]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @DuoPolyp VARCHAR(10) = 'False', @Tumour VARCHAR(10) = 'False',
			@ERCPTumour VARCHAR(10) = 'False', @ProbableCarcinoma VARCHAR(10) = 'False', 
			@ProbableLymphoma VARCHAR(10) = 'False',
			@Action CHAR(1) = 'I',
			@DuoTumourBenign VARCHAR(10) = 'False', @DuoTumourMalignan VARCHAR(10) = 'False'

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@DuoPolyp = (CASE WHEN ([Type] = 1) THEN 'True' ELSE 'False' END),
				--@Tumour = (CASE WHEN ([Type] = 2) THEN 'True' ELSE 'False' END),
				--@ERCPTumour = (CASE WHEN ([Type] IN (2,3)) THEN 'True' ELSE 'False' END),
				@DuoTumourBenign = (CASE WHEN ([Type] = 1) THEN 'True' ELSE 'False' END),
				@ProbableLymphoma = (CASE WHEN [Type] = 2 THEN 'True' ELSE 'False' END),
				@ProbableCarcinoma = (CASE WHEN [Type] = 3 THEN 'True' ELSE 'False' END),
				@DuoTumourMalignan = (CASE WHEN ([Type] = 4) THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_tumour_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	EXEC diagnoses_control_save @site_id, 'D58P1', @DuoPolyp			-- 'DuoPolyp'
	EXEC diagnoses_control_save @site_id, 'D55P1', @Tumour				-- 'Tumour'
	--EXEC diagnoses_control_save @site_id, 'D55P2', @ERCPTumour			-- 'ERCP Tumour'
	EXEC diagnoses_control_save @site_id, 'D92P1', @DuoTumourBenign		-- 'Tumour Benign'
	EXEC diagnoses_control_save @site_id, 'D93P1', @DuoTumourMalignan		-- 'Tumour Benign'
	EXEC diagnoses_control_save @site_id, 'D94P1', @ProbableCarcinoma		-- 'Probable lymphoma'
	EXEC diagnoses_control_save @site_id, 'D95P1', @ProbableLymphoma		-- 'Probable lymphoma'
GO-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'abnormalities_intrahepatic_summary_update', 'S'
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
				IF @tmpSummary = '' SET @tmpSummary = @tmpSummary + ' tumour'
				ELSE SET @tmpSummary = @tmpSummary + '$$ tumour'
			END

			IF @Summary = '' SET @Summary = @Summary + ' stones'
			ELSE SET @summary = @summary + @tmpSummary

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
-----------------------------------------------------------------------------------------------------------
UPDATE ERS_DiagnosesMatrix SET DisplayName = 'Mirizzi syndrome', NED_Name = 'Mirizzi syndrome' WHERE Code = 'D160P2'
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'diagnoses_control_save', 'S'
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
	IF @ProcedureType IN (2,7) AND RIGHT(@DiagnosesMatrixCode,2) <> 'P2'
	BEGIN 
		SET @DiagnosesMatrixCode = STUFF(@DiagnosesMatrixCode, LEN(@DiagnosesMatrixCode) - 1, 2, 'P2')
	END

	
	IF @ProcedureType IN (3,4,5)   ---------- Colonoscopy, Sigmoidscopy, Proctoscopy ----------------------
	BEGIN
		SET @Region=(select x.Region from [ERS_AbnormalitiesMatrixColon] x inner join ERS_Regions r on x.region = r.Region AND r.ProcedureType= x.ProcedureType inner join ers_sites s on r.RegionId = s.RegionId where s.SiteId = @siteID )
		SET @MatrixSection= 'Colon'

		--ColonicPolyp (D12P3) should not be in region 'Rectum'
		--RectalPolyp (D4P3) should be in region 'Rectum'
		IF @DiagnosesMatrixCode IN ('D12P3') AND @Region in ('Rectum', 'Anal Margin')		SET @ProcedureID = NULL
		ELSE IF @DiagnosesMatrixCode IN ('D4P3') AND @Region not in ('Rectum', 'Anal Margin')		SET @ProcedureID = NULL
		ELSE IF @DiagnosesMatrixCode = 'D8P3' AND @Region in ('Rectum', 'Anal Margin')	SET @DiagnosesMatrixCode = 'D13P3' -- D8P3 for 'Malignant colonic tumour', D13P3 for Malignant rectal tumour
		ELSE IF @DiagnosesMatrixCode = 'D5P3' AND @ProcedureType = 4	SET @DiagnosesMatrixCode = 'S5P3' --Sigmo code is S5P3
		ELSE IF @DiagnosesMatrixCode = 'D1P3' AND @ProcedureType = 4	SET @DiagnosesMatrixCode = 'S1P3'
		ELSE IF @DiagnosesMatrixCode = 'D12P3' AND @ProcedureType = 4	SET @DiagnosesMatrixCode = 'S12P3' --not worrying about doing the region check as the one above would've handled and set procedure id to 0 and thins is checked below and acted on accordingly
		ELSE IF @DiagnosesMatrixCode = 'D4P3' AND @ProcedureType = 4    SET @DiagnosesMatrixCode = 'S4P3'  --not worrying about doing the region check as the one above would've handled and set procedure id to 0 and thins is checked below and acted on accordingly
		ELSE IF @DiagnosesMatrixCode = 'D8P3' AND @ProcedureType = 4	SET @DiagnosesMatrixCode = 'S8P3'  --not worrying about doing the region check as the one above would've handled and set procedure id to 0 and thins is checked below and acted on accordingly
		ELSE IF @DiagnosesMatrixCode IN ('D6P3') 
			BEGIN
				IF @SiteNo = -77	AND @XCoordinate >= 17		SET @DiagnosesMatrixCode = 'D11P3' -- D6P3 for 'Benign colonic tumour', D11P3 for Benign rectal tumour
				ELSE IF @SiteNo > 0 AND @Region in ('Rectum', 'Anal Margin')		SET @DiagnosesMatrixCode = 'D11P3' -- D6P3 for 'Benign colonic tumour', D11P3 for Benign rectal tumour
			END
		ELSE IF @DiagnosesMatrixCode IN ('D15P3') 
			BEGIN
				IF @SiteNo = -77	AND @XCoordinate >= 17		SET @ProcedureID = NULL -- By distance, "Redundant anterior rectal mucosa" should be in region 'Rectum' and rectal is if the site is < 17 cm
				ELSE IF @SiteNo > 0 AND @Region not in ('Rectum', 'Anal Margin')		SET @ProcedureID = NULL -- Redundant anterior rectal mucosa (D15P3) should be in region 'Rectum'
			END
		ELSE IF @DiagnosesMatrixCode IN ('D80P3') 
			BEGIN
				IF @SiteNo = -77	AND @XCoordinate >= 17		SET @DiagnosesMatrixCode = 'D83P3' -- By distance, D80P3 for 'Rectal ulcer(s)', D83P3 for 'Colonic ulcer(s)'
				ELSE IF @SiteNo > 0 AND @Region not in ('Rectum', 'Anal Margin')	SET @DiagnosesMatrixCode = 'D83P3'   --D80P3 for 'Rectal ulcer(s)', D83P3 for 'Colonic ulcer(s)'
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
	IF CHARINDEX('notentered',LOWER(@DiagnosesMatrixCode)) = 0 AND NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE ProcedureTypeID = @ProcedureType AND Code = @DiagnosesMatrixCode) GOTO RETURN_NULL

	--Set correct region for not entered codes
	IF CHARINDEX('notentered',LOWER(@DiagnosesMatrixCode)) > 0
	BEGIN
		SET @siteid = NULL
		SELECT @MatrixSection = 
		CASE LOWER(@DiagnosesMatrixCode)
			WHEN 'stomachnotentered' THEN 'Stomach'
			WHEN 'duodenumnotentered' THEN 'Duodenum'
		END
	END

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

-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ERCPAbnoDiverticulum', 'TR'
GO

CREATE TRIGGER [dbo].[TR_ERCPAbnoDiverticulum]
ON [dbo].[ERS_ERCPAbnoDiverticulum]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @Proximity VARCHAR(10) = 'False', @BiliaryLeak VARCHAR(10) = 'False',
	@Occlusion VARCHAR(10), @PreviousSurgery VARCHAR(10), @Diverticula VARCHAR(10) = 'False',
			@Action CHAR(1) = 'I'

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
			@Diverticula = (CASE WHEN Proximity = 1 THEN 'True' ELSE 'False' END),   --if Proximity is "ampulla at edge" or "ampulla within diverticulum"7
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
	EXEC diagnoses_control_save @site_id, 'D395P2', @Diverticula		-- 'Periampullary diverticula'


GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_CommonAbnoVascularLesions', 'TR'
GO

CREATE TRIGGER [dbo].[TR_CommonAbnoVascularLesions]
ON [dbo].[ERS_CommonAbnoVascularLesions]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @Telangiectasia VARCHAR(10) = 'False', @Angioma VARCHAR(10) = 'False', 
			@StomachTelangiectasia VARCHAR(10) = 'False', @PortalHypertensiveGastropathy VARCHAR(10) = 'False', 
			@TelangiectasiaAngioma VARCHAR(10) = 'False', @Angiodysplasia VARCHAR(10) = 'False', 
			@Action CHAR(1) = 'I' , @DieulafoyLesion VARCHAR(10) = 'False', @DuodenumVarices VARCHAR(10) = 'False'

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Telangiectasia = (CASE WHEN ([Type] = 1 AND [Area] = 'Oesophagus') THEN 'True' ELSE 'False' END),
				@Telangiectasia = (CASE WHEN ([Type] = 1 AND [Area] = 'Duodeneum') THEN 'True' ELSE 'False' END),
				@Angioma = (CASE WHEN (Area='Stomach' AND ([Type] = 2 OR [Type] = 3 OR [Type] = 4)) THEN 'True' ELSE 'False' END),
				@StomachTelangiectasia = (CASE WHEN ([Type]=1 AND [Area]='Stomach') THEN 'True' ELSE 'False' END),
				@PortalHypertensiveGastropathy = (CASE WHEN (Area='Stomach' AND [Type]=5) THEN 'True' ELSE 'False' END),
				@DuodenumVarices = (CASE WHEN (Area='Duodenum' AND [Type]=5) THEN 'True' ELSE 'False' END),
				@TelangiectasiaAngioma = (CASE WHEN ( Area='Duodenum' AND ([Type] = 1 OR [Type] = 2 OR [Type] = 3 OR [Type] = 4)) THEN 'True' ELSE 'False' END),
				@Angiodysplasia = (CASE WHEN ([Type] BETWEEN 2 AND 5) THEN 'True' ELSE 'False' END),
				@DieulafoyLesion = (CASE WHEN [Type] > 0 AND [Area] = 'Stomach' THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_vascular_lesions_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	IF ISNULL((SELECT p.ProcedureType FROM ers_sites s 
		INNER JOIN ers_procedures p ON s.ProcedureId = p.ProcedureId 
		WHERE SiteId = @site_id),0) = 2   --Check If ERCP (2), else proceed with OGD
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D64P2', @Angiodysplasia					-- 'Angiodysplasia'
		EXEC diagnoses_control_save @site_id, 'D396P2', @Telangiectasia					-- 'Telangiectasia'

	END
	ELSE
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D22P1', @Telangiectasia					-- 'Telangiectasia'
		EXEC diagnoses_control_save @site_id, 'D43P1', @Angioma							-- 'Angioma'
		EXEC diagnoses_control_save @site_id, 'D46P1', @StomachTelangiectasia			-- 'StomachTelangiectasia'
		EXEC diagnoses_control_save @site_id, 'D52P1', @PortalHypertensiveGastropathy	-- 'PortalHypertensiveGastropathy'
		EXEC diagnoses_control_save @site_id, 'D59P1', @TelangiectasiaAngioma			-- 'TelangiectasiaAngioma'
		EXEC diagnoses_control_save @site_id, 'D80P1', @DieulafoyLesion					-- 'Dieulafoy Lesion'
		EXEC diagnoses_control_save @site_id, 'D106P1', @DuodenumVarices
	END
GO
-----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_CommonAbnoVascularLesions', 'TR'
GO

CREATE TRIGGER [dbo].[TR_CommonAbnoVascularLesions]
ON [dbo].[ERS_CommonAbnoVascularLesions]
AFTER INSERT, UPDATE, DELETE
AS 
	DECLARE @site_id INT, @Telangiectasia VARCHAR(10) = 'False', @Angioma VARCHAR(10) = 'False', 
			@StomachTelangiectasia VARCHAR(10) = 'False', @PortalHypertensiveGastropathy VARCHAR(10) = 'False', 
			@TelangiectasiaAngioma VARCHAR(10) = 'False', @Angiodysplasia VARCHAR(10) = 'False', 
			@Action CHAR(1) = 'I' , @DieulafoyLesion VARCHAR(10) = 'False', @DuodenumVarices VARCHAR(10) = 'False',
			@DuoTelangiectasia VARCHAR(10)

    IF EXISTS(SELECT * FROM DELETED) SET @Action = CASE WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' ELSE 'D' END

	-- INSERTED OR UPDATED
	IF @Action IN ('I', 'U') 
	BEGIN
		SELECT @site_id=SiteId,
				@Telangiectasia = (CASE WHEN ([Type] = 1 AND [Area] = 'Oesophagus') THEN 'True' ELSE 'False' END),
				@DuoTelangiectasia = (CASE WHEN ([Type] = 1 AND [Area] = 'Duodenum') THEN 'True' ELSE 'False' END),
				@Angioma = (CASE WHEN (Area='Stomach' AND ([Type] = 2 OR [Type] = 3 OR [Type] = 4)) THEN 'True' ELSE 'False' END),
				@StomachTelangiectasia = (CASE WHEN ([Type]=1 AND [Area]='Stomach') THEN 'True' ELSE 'False' END),
				@PortalHypertensiveGastropathy = (CASE WHEN (Area='Stomach' AND [Type]=5) THEN 'True' ELSE 'False' END),
				@DuodenumVarices = (CASE WHEN (Area='Duodenum' AND [Type]=5) THEN 'True' ELSE 'False' END),
				@TelangiectasiaAngioma = (CASE WHEN ( Area='Duodenum' AND ([Type] = 1 OR [Type] = 2 OR [Type] = 3 OR [Type] = 4)) THEN 'True' ELSE 'False' END),
				@Angiodysplasia = (CASE WHEN ([Type] BETWEEN 2 AND 5) THEN 'True' ELSE 'False' END),
				@DieulafoyLesion = (CASE WHEN [Type] > 0 AND [Area] = 'Stomach' THEN 'True' ELSE 'False' END)
		FROM INSERTED

		EXEC abnormalities_vascular_lesions_summary_update @site_id
	END

	-- DELETED
	IF @Action = 'D'
	BEGIN
		SELECT @site_id=SiteId FROM DELETED
	END

	EXEC sites_summary_update @site_id

	IF ISNULL((SELECT p.ProcedureType FROM ers_sites s 
		INNER JOIN ers_procedures p ON s.ProcedureId = p.ProcedureId 
		WHERE SiteId = @site_id),0) IN (2, 7)   --Check If ERCP (2), else proceed with OGD
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D64P2', @Angiodysplasia					-- 'Angiodysplasia'
		EXEC diagnoses_control_save @site_id, 'D396P2', @DuoTelangiectasia					-- 'Telangiectasia'

	END
	ELSE
	BEGIN
		EXEC diagnoses_control_save @site_id, 'D22P1', @Telangiectasia					-- 'Telangiectasia'
		EXEC diagnoses_control_save @site_id, 'D43P1', @Angioma							-- 'Angioma'
		EXEC diagnoses_control_save @site_id, 'D46P1', @StomachTelangiectasia			-- 'StomachTelangiectasia'
		EXEC diagnoses_control_save @site_id, 'D52P1', @PortalHypertensiveGastropathy	-- 'PortalHypertensiveGastropathy'
		EXEC diagnoses_control_save @site_id, 'D59P1', @TelangiectasiaAngioma			-- 'TelangiectasiaAngioma'
		EXEC diagnoses_control_save @site_id, 'D80P1', @DieulafoyLesion					-- 'Dieulafoy Lesion'
		EXEC diagnoses_control_save @site_id, 'D106P1', @DuodenumVarices
	END
GO
-----------------------------------------------------------------------------------------------------------

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
			@MultipleStrictures VARCHAR(10) = 'False', @StretchedDuctules VARCHAR(10) = 'False',
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
				@Mass = (CASE WHEN Mass = 1 AND MassType = 0 THEN 'True' ELSE 'False' END),
				@MultipleStrictures = (CASE WHEN MultiStrictures = 1 AND ISNULL(MultiStricturesSuspection,0) = 0 THEN 'True' ELSE 'False' END),
				@StretchedDuctules = (CASE WHEN SpideryDuctules = 1 AND SpiderySuspection = 0 THEN 'True' ELSE 'False' END)

		FROM INSERTED i

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
	EXEC diagnoses_control_save @site_id, 'D397P2', @MultipleStrictures			--Caroli's disease
	EXEC diagnoses_control_save @site_id, 'D398P2', @StretchedDuctules			--Caroli's disease


	
	
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
-----------------------------------------------------------------------------------------------------------
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
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('Multiple stricture/dilation'))		INSERT INTO @tmpDiv (Val) VALUES('Multiple stricture/dilation')
		IF EXISTS (SELECT 1 FROM @tmpRegionDiv WHERE Val IN ('Spidery stretched ductules'))		INSERT INTO @tmpDiv (Val) VALUES('Spidery stretched ductules')

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
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D377P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Mass', 2, 'Pancreas', 0, 377, 'D377P2', 1),
		   ('Mass', 7, 'Pancreas', 0, 377, 'D395P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D395P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Diverticula', 2, 'Papillae', 0, 395, 'D395P2', 1),
		   ('Diverticula', 7, 'Papillae', 0, 395, 'D395P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D396P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Telangiectasia', 2, 'Duodenum', 0, 396, 'D396P2', 1),
		   ('Telangiectasia', 7, 'Duodenum', 0, 396, 'D396P2', 1)
GO

IF NOT EXISTS (SELECT * FROM ERS_DiagnosesMatrix WHERE Code = 'D396P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Pseudodiverticulum', 2, 'Duodenum', 0, 22, 'D396P2', 1),
		   ('Pseudodiverticulum', 7, 'Duodenum', 0, 22, 'D396P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D397P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Multiple stricture/dilation', 2, 'Biliary', 0, 397, 'D397P2', 1),
		   ('Multiple stricture/dilation', 7, 'Biliary', 0, 397, 'D397P2', 1)
GO

IF NOT EXISTS (SELECT 1 FROM ERS_DiagnosesMatrix WHERE Code = 'D398P2')
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeId, Section, [Disabled], OrderbyNumber, Code, Visible)
	VALUES ('Spidery stretched ductules', 2, 'Biliary', 0, 398, 'D398P2', 1),
		   ('Spidery stretched ductules', 7, 'Biliary', 0, 398, 'D398P2', 1)
GO

