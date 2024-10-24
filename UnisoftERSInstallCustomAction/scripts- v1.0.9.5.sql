--Version 1.0.9.5

DECLARE @ImportConsultants BIT = 1		--[set to 1 if text file Consultants.txt is available]

CREATE TABLE #variables (ImportConsultants BIT)
INSERT INTO #variables (ImportConsultants) 
	VALUES (@ImportConsultants)
GO
----------------------------------------------------------------------------------------------------------------------------
--------------------------------------------ercp_stentinsertions_summary----------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'ercp_stentinsertions_summary', 'F';
GO

CREATE FUNCTION [dbo].[ercp_stentinsertions_summary]
(
	@TherapeuticId INT
)
RETURNS varchar(max)
AS
BEGIN

	DECLARE
			@site_id int,
			@StentInsertion INT,
			@StentInsertionQty INT,
			@StentInsertionType INT, 
			@StentInsertionLength INT,
			@StentInsertionDiameter INT,
			@StentInsertionDiameterUnits INT,
			@RadioactiveWirePlaced BIT,
			@StentInsertionBatchNo VARCHAR(50),
			@summary varchar(max)

	--get values from inserted therap record
	SELECT @site_id = ee.SiteId, @StentInsertion = ee.StentInsertion, @StentInsertionQty = ee.StentInsertionQty, @summary = ee.Summary, @RadioactiveWirePlaced = ee.RadioactiveWirePlaced, @StentInsertionBatchNo = ee.StentInsertionBatchNo FROM dbo.ERS_ERCPTherapeutics ee WHERE Id = @TherapeuticId

	DECLARE @Details varchar(max), @Count int
	
	SET @Details = ''
	SET @Count = 1
	
	DECLARE si_cursor CURSOR FOR 

	--get insertion details (loop through each record for the therap record in question)
	(SELECT
		si.TherapeuticId, si.StentInsertionType, si.StentInsertionLength, si.StentInsertionDiameter, si.StentInsertionDiameterUnits  
	FROM dbo.ERS_ERCPTherapeuticStentInsertions si 
	WHERE si.TherapeuticId = @TherapeuticId)

	OPEN si_cursor
	FETCH NEXT FROM si_cursor INTO @TherapeuticId, @StentInsertionType, @StentInsertionLength, @StentInsertionDiameter, @StentInsertionDiameterUnits

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Stent type
		IF @StentInsertionType > 0 
		BEGIN
			SET @Details = @Details + CASE WHEN @StentInsertionQty > 1 THEN '<br /> &emsp; Insertion - ' +  CONVERT(varchar(10), @Count) ELSE '' END  + ' ' + ISNULL((SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Therapeutic Stomach Stent Insertion Types' AND [ListItemNo] = @StentInsertionType),'')
		END	

		--Recorded length & diameter of stent(s) used
		IF @StentInsertionLength > 0 OR @StentInsertionDiameter > 0 
		BEGIN
			IF @StentInsertionType = 0 --theres a chance the user may have chosen other values but no insertion type... handling this or the summary output will look a mess
				SET @Details = @Details + CASE WHEN @StentInsertionQty > 1 THEN '<br /> &emsp; Insertion - ' +  CONVERT(varchar(10), @Count) ELSE '' END

			SET @Details = @Details + ' (' 
			IF @StentInsertionLength > 0 SET @Details = @Details + 'length ' + cast(@StentInsertionLength as varchar(50)) + 'cm'
			IF @StentInsertionDiameter > 0 AND @StentInsertionLength > 0 SET @Details = @Details + ', ' 
			IF @StentInsertionDiameter > 0 SET @Details = @Details + 'diameter ' + cast(@StentInsertionDiameter as varchar(50))
			----What units were used?
			IF @StentInsertionDiameter > 0 AND @StentInsertionDiameterUnits >= 0 
					SET @Details = @Details+ ' ' + ISNULL((SELECT [ListItemText] FROM ERS_Lists WHERE ListDescription = 'Oesophageal dilatation units' AND [ListItemNo] = @StentInsertionDiameterUnits),'')
			SET @Details = LTRIM(@Details) + ')' 
		END
		IF @RadioactiveWirePlaced > 0  SET @Details = @Details + ', radiotherapeutic wire placed' 
		IF ISNULL(@StentInsertionBatchNo,'') <> ''  SET @Details = @Details + ', batch ' + LTRIM(RTRIM(@StentInsertionBatchNo))

		SET @Details = @Details
		--------------
		SET @Count = @Count +1
		FETCH NEXT FROM si_cursor INTO @TherapeuticId, @StentInsertionType, @StentInsertionLength, @StentInsertionDiameter, @StentInsertionDiameterUnits
	END

	CLOSE si_cursor
	DEALLOCATE si_cursor

	RETURN @Details
END	

GO

----------------------------------------------------------------------------------------------------------------------------
--------------------------------------ERS_ERCPTherapeuticStentInsertions----------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('ERS_ERCPTherapeuticStentInsertions') AND type = 'U')
BEGIN
	CREATE TABLE ERS_ERCPTherapeuticStentInsertions(
		Id [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_ERS_ERCPTherapeuticStentInsertions] PRIMARY KEY CLUSTERED ([Id]),
		TherapeuticId [int] NOT NULL,
		StentInsertionType [smallint] NOT NULL, 
		StentInsertionLength [int] NULL, 
		StentInsertionDiameter [int] NULL, 
		StentInsertionDiameterUnits [tinyint] NULL, 
		CONSTRAINT [FK_ERS_ERCPTherapeuticStentInsertions_TherapeuticId] FOREIGN KEY (TherapeuticId) REFERENCES ERS_ERCPTherapeutics(Id),
	)
END
GO

--------------------------------------------------------------------------------------------------------------------
-------------------------------------317 Create Trigger TR_ERCP_Therapeutic_Insert.sql-------------------------------------
--------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'TR_ERCP_Therapeutic_Insert', 'TR';
GO

CREATE TRIGGER TR_ERCP_Therapeutic_Insert
ON ERS_ERCPTherapeutics
AFTER INSERT, UPDATE 
AS 
	
	DECLARE @site_id INT,
			@TherapeuticId as INT

	SELECT @TherapeuticId=id, @site_id=SiteId FROM INSERTED

	EXEC ogd_kpi_stricture_perforation @site_id --Update perforation text in QA for OGD KPI

	EXEC therapeutics_ercp_summary_update @TherapeuticId, @site_id
	EXEC sites_summary_update @site_id
GO

----------------------------------------------------------------------------------------------------------------------------
-----------------------------------TR_ERCP_StentInsertion_Details_Trigger---------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ERCP_StentInsertion_Details_Trigger', 'TR';
GO

CREATE TRIGGER TR_ERCP_StentInsertion_Details_Trigger
   ON  dbo.ERS_ERCPTherapeuticStentInsertions
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DECLARE @site_id INT,
				@TherapeuticId as INT

	SELECT @TherapeuticId=i.TherapeuticId, @site_id=ee.SiteId FROM INSERTED i
		INNER JOIN dbo.ERS_ERCPTherapeutics ee ON ee.Id = i.TherapeuticId

	--Call this again as theres now a stent insertion record to create the summary from
	EXEC therapeutics_ercp_summary_update @TherapeuticId, @site_id
	EXEC sites_summary_update @site_id

END
GO

------------------------------------------------------------------------------------------------
----------------------------------usp_TherapeuticRecordDelete-----------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
EXEC DropIfExist 'usp_TherapeuticRecordDelete', 'S';
GO
CREATE PROCEDURE dbo.usp_TherapeuticRecordDelete
(
	  @TherapType AS VARCHAR(20)
	, @RecordId AS INTEGER
	, @SiteId	AS INTEGER
)
AS
-- =============================================
-- Description:	This will Delete Therapeutc Record. Applicable for ERCP and UGI.
--				This also DELETEs record from the dbo.ERS_RecordCount Table- if applicable.
-- =============================================
BEGIN TRY
	BEGIN TRANSACTION
		
	--### ERCP Record
	IF LOWER(@TherapType) = 'ercp'
	BEGIN
		--## First Delete from the Therapeutic Table
		DELETE FROM dbo.ERS_ERCPTherapeutics WHERE id=@RecordId;

		--## Now check whether anymore Therapeutic Record left after this DELETE? If NO then DELETE the 'counter record' in dbo.ERS_RecordCount
		IF NOT EXISTS(SELECT 1 FROM dbo.ERS_ERCPTherapeutics WHERE SiteId=@SiteId)
			DELETE FROM dbo.ERS_RecordCount WHERE SiteId=@SiteId AND Identifier='Therapeutic Procedures';

		IF EXISTS (SELECT 1 FROM dbo.ERS_ERCPTherapeuticStentInsertions WHERE TherapeuticId = @RecordId)
			DELETE FROM ERS_ERCPTherapeuticStentInsertions WHERE TherapeuticId = @RecordId

	END
	--### OGD Record	
	IF LOWER(@TherapType) = 'ogd'		
	BEGIN
		DELETE FROM dbo.ERS_UpperGITherapeutics WHERE id= @RecordId;			
		IF NOT EXISTS(SELECT 1 FROM dbo.ERS_UpperGITherapeutics WHERE SiteId=@SiteId)
			DELETE FROM dbo.ERS_RecordCount WHERE SiteId=@SiteId AND Identifier='Therapeutic Procedures';
	END

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH

GO

------------------------------------------------------------------------------------
IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'StentInsertionType' AND Object_ID = Object_ID(N'ERS_ERCPTherapeutics'))
	ALTER TABLE dbo.ERS_ERCPTherapeutics DROP COLUMN StentInsertionType	

IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'StentInsertionLength' AND Object_ID = Object_ID(N'ERS_ERCPTherapeutics'))
	ALTER TABLE dbo.ERS_ERCPTherapeutics DROP COLUMN StentInsertionLength		

IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'StentInsertionDiameter' AND Object_ID = Object_ID(N'ERS_ERCPTherapeutics'))
	ALTER TABLE dbo.ERS_ERCPTherapeutics DROP COLUMN StentInsertionDiameter	

IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'StentInsertionDiameterUnits' AND Object_ID = Object_ID(N'ERS_ERCPTherapeutics'))
	ALTER TABLE dbo.ERS_ERCPTherapeutics DROP COLUMN StentInsertionDiameterUnits
GO

------------------------------------------------------------------------------------
IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ERSAudit' AND TABLE_NAME = 'ERS_ERCPTherapeutics_Audit'))
BEGIN
	IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'StentInsertionType' AND Object_ID = Object_ID(N'ERS_ERCPTherapeutics_Audit'))
		ALTER TABLE ERSAudit.ERS_ERCPTherapeutics_Audit DROP COLUMN StentInsertionType	

	IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'StentInsertionLength' AND Object_ID = Object_ID(N'ERS_ERCPTherapeutics_Audit'))
		ALTER TABLE ERSAudit.ERS_ERCPTherapeutics_Audit DROP COLUMN StentInsertionLength		

	IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'StentInsertionDiameter' AND Object_ID = Object_ID(N'ERS_ERCPTherapeutics_Audit'))
		ALTER TABLE ERSAudit.ERS_ERCPTherapeutics_Audit DROP COLUMN StentInsertionDiameter	

	IF EXISTS(SELECT * FROM sys.columns WHERE Name = N'StentInsertionDiameterUnits' AND Object_ID = Object_ID(N'ERS_ERCPTherapeutics_Audit'))
		ALTER TABLE ERSAudit.ERS_ERCPTherapeutics_Audit DROP COLUMN StentInsertionDiameterUnits
END
GO
------------------------------------------------------------------------------------

EXEC DropIfExist 'trg_ERS_ERCPTherapeutics_Delete', 'TR';
GO

CREATE TRIGGER [dbo].[trg_ERS_ERCPTherapeutics_Delete] 
ON [dbo].[ERS_ERCPTherapeutics] 
	AFTER DELETE
AS 
	SET NOCOUNT ON; 
	INSERT INTO [ERSAudit].[ERS_ERCPTherapeutics_Audit] (Id, tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[GastrostomyRemoval], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[AttachmentToWard], tbl.[PyloricDilatation], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[RadioactiveWirePlaced], tbl.[StentInsertionBatchNo], tbl.[StentDecompressedDuct], tbl.[CorrectStentPlacement], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Marking], tbl.[MarkingType], tbl.[Clip], tbl.[ClipNum], tbl.[Papillotomy], tbl.[Sphincterotome], tbl.[PapillotomyLength], tbl.[PapillotomyAcceptBalloonSize], tbl.[ReasonForPapillotomy], tbl.[PapillotomyBleeding], tbl.[SphincterDecompressed], tbl.[PanOrificeSphincterotomy], tbl.[StoneRemoval], tbl.[RemovalUsing], tbl.[ExtractionOutcome], tbl.[InadequateSphincterotomy], tbl.[StoneSize], tbl.[QuantityOfStones], tbl.[ImpactedStones], tbl.[OtherReason], tbl.[OtherReasonText], tbl.[StoneDecompressed], tbl.[StrictureDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[StrictureDecompressed], tbl.[EndoscopicCystPuncture], tbl.[CystPunctureDevice], tbl.[CystPunctureVia], tbl.[Cannulation], tbl.[Manometry], tbl.[Haemostasis], tbl.[NasopancreaticDrain], tbl.[RendezvousProcedure], tbl.[SnareExcision], tbl.[BalloonDilation], tbl.[BalloonDilatedTo], tbl.[BalloonDilatationUnits], tbl.[BalloonDilatorType], tbl.[BalloonTrawl], tbl.[BalloonTrawlDilatorType], tbl.[BalloonTrawlDilatorSize], tbl.[BalloonTrawlDilatorUnits], tbl.[BalloonDecompressed], tbl.[DiagCholangiogram], tbl.[DiagPancreatogram], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  LastActionId, ActionDateTime, ActionUserId)
	SELECT tbl.Id , tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[GastrostomyRemoval], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[AttachmentToWard], tbl.[PyloricDilatation], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[RadioactiveWirePlaced], tbl.[StentInsertionBatchNo], tbl.[StentDecompressedDuct], tbl.[CorrectStentPlacement], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Marking], tbl.[MarkingType], tbl.[Clip], tbl.[ClipNum], tbl.[Papillotomy], tbl.[Sphincterotome], tbl.[PapillotomyLength], tbl.[PapillotomyAcceptBalloonSize], tbl.[ReasonForPapillotomy], tbl.[PapillotomyBleeding], tbl.[SphincterDecompressed], tbl.[PanOrificeSphincterotomy], tbl.[StoneRemoval], tbl.[RemovalUsing], tbl.[ExtractionOutcome], tbl.[InadequateSphincterotomy], tbl.[StoneSize], tbl.[QuantityOfStones], tbl.[ImpactedStones], tbl.[OtherReason], tbl.[OtherReasonText], tbl.[StoneDecompressed], tbl.[StrictureDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[StrictureDecompressed], tbl.[EndoscopicCystPuncture], tbl.[CystPunctureDevice], tbl.[CystPunctureVia], tbl.[Cannulation], tbl.[Manometry], tbl.[Haemostasis], tbl.[NasopancreaticDrain], tbl.[RendezvousProcedure], tbl.[SnareExcision], tbl.[BalloonDilation], tbl.[BalloonDilatedTo], tbl.[BalloonDilatationUnits], tbl.[BalloonDilatorType], tbl.[BalloonTrawl], tbl.[BalloonTrawlDilatorType], tbl.[BalloonTrawlDilatorSize], tbl.[BalloonTrawlDilatorUnits], tbl.[BalloonDecompressed], tbl.[DiagCholangiogram], tbl.[DiagPancreatogram], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  3, GETDATE(), tbl.WhoUpdatedId
	FROM deleted tbl
GO

------------------------------------------------------------------------------------
EXEC DropIfExist 'trg_ERS_ERCPTherapeutics_Insert', 'TR';
GO

CREATE TRIGGER [dbo].[trg_ERS_ERCPTherapeutics_Insert] 
	ON [dbo].[ERS_ERCPTherapeutics] 
	AFTER INSERT
AS 
	SET NOCOUNT ON; 
	INSERT INTO [ERSAudit].[ERS_ERCPTherapeutics_Audit] (Id, tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[GastrostomyRemoval], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[AttachmentToWard], tbl.[PyloricDilatation], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[RadioactiveWirePlaced], tbl.[StentInsertionBatchNo], tbl.[StentDecompressedDuct], tbl.[CorrectStentPlacement], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Marking], tbl.[MarkingType], tbl.[Clip], tbl.[ClipNum], tbl.[Papillotomy], tbl.[Sphincterotome], tbl.[PapillotomyLength], tbl.[PapillotomyAcceptBalloonSize], tbl.[ReasonForPapillotomy], tbl.[PapillotomyBleeding], tbl.[SphincterDecompressed], tbl.[PanOrificeSphincterotomy], tbl.[StoneRemoval], tbl.[RemovalUsing], tbl.[ExtractionOutcome], tbl.[InadequateSphincterotomy], tbl.[StoneSize], tbl.[QuantityOfStones], tbl.[ImpactedStones], tbl.[OtherReason], tbl.[OtherReasonText], tbl.[StoneDecompressed], tbl.[StrictureDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[StrictureDecompressed], tbl.[EndoscopicCystPuncture], tbl.[CystPunctureDevice], tbl.[CystPunctureVia], tbl.[Cannulation], tbl.[Manometry], tbl.[Haemostasis], tbl.[NasopancreaticDrain], tbl.[RendezvousProcedure], tbl.[SnareExcision], tbl.[BalloonDilation], tbl.[BalloonDilatedTo], tbl.[BalloonDilatationUnits], tbl.[BalloonDilatorType], tbl.[BalloonTrawl], tbl.[BalloonTrawlDilatorType], tbl.[BalloonTrawlDilatorSize], tbl.[BalloonTrawlDilatorUnits], tbl.[BalloonDecompressed], tbl.[DiagCholangiogram], tbl.[DiagPancreatogram], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  LastActionId, ActionDateTime, ActionUserId)
	SELECT tbl.Id , tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[GastrostomyRemoval], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[AttachmentToWard], tbl.[PyloricDilatation], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[RadioactiveWirePlaced], tbl.[StentInsertionBatchNo], tbl.[StentDecompressedDuct], tbl.[CorrectStentPlacement], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Marking], tbl.[MarkingType], tbl.[Clip], tbl.[ClipNum], tbl.[Papillotomy], tbl.[Sphincterotome], tbl.[PapillotomyLength], tbl.[PapillotomyAcceptBalloonSize], tbl.[ReasonForPapillotomy], tbl.[PapillotomyBleeding], tbl.[SphincterDecompressed], tbl.[PanOrificeSphincterotomy], tbl.[StoneRemoval], tbl.[RemovalUsing], tbl.[ExtractionOutcome], tbl.[InadequateSphincterotomy], tbl.[StoneSize], tbl.[QuantityOfStones], tbl.[ImpactedStones], tbl.[OtherReason], tbl.[OtherReasonText], tbl.[StoneDecompressed], tbl.[StrictureDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[StrictureDecompressed], tbl.[EndoscopicCystPuncture], tbl.[CystPunctureDevice], tbl.[CystPunctureVia], tbl.[Cannulation], tbl.[Manometry], tbl.[Haemostasis], tbl.[NasopancreaticDrain], tbl.[RendezvousProcedure], tbl.[SnareExcision], tbl.[BalloonDilation], tbl.[BalloonDilatedTo], tbl.[BalloonDilatationUnits], tbl.[BalloonDilatorType], tbl.[BalloonTrawl], tbl.[BalloonTrawlDilatorType], tbl.[BalloonTrawlDilatorSize], tbl.[BalloonTrawlDilatorUnits], tbl.[BalloonDecompressed], tbl.[DiagCholangiogram], tbl.[DiagPancreatogram], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  1, GETDATE(), tbl.WhoCreatedId
	FROM inserted tbl
GO

------------------------------------------------------------------------------------

EXEC DropIfExist 'trg_ERS_ERCPTherapeutics_Update', 'TR';
GO

CREATE TRIGGER [dbo].[trg_ERS_ERCPTherapeutics_Update] 
	ON [dbo].[ERS_ERCPTherapeutics] 
	AFTER UPDATE
AS 
	SET NOCOUNT ON; 
	IF NOT UPDATE(Summary)
	BEGIN
		INSERT INTO [ERSAudit].[ERS_ERCPTherapeutics_Audit] (Id, tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[GastrostomyRemoval], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[AttachmentToWard], tbl.[PyloricDilatation], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[RadioactiveWirePlaced], tbl.[StentInsertionBatchNo], tbl.[StentDecompressedDuct], tbl.[CorrectStentPlacement], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Marking], tbl.[MarkingType], tbl.[Clip], tbl.[ClipNum], tbl.[Papillotomy], tbl.[Sphincterotome], tbl.[PapillotomyLength], tbl.[PapillotomyAcceptBalloonSize], tbl.[ReasonForPapillotomy], tbl.[PapillotomyBleeding], tbl.[SphincterDecompressed], tbl.[PanOrificeSphincterotomy], tbl.[StoneRemoval], tbl.[RemovalUsing], tbl.[ExtractionOutcome], tbl.[InadequateSphincterotomy], tbl.[StoneSize], tbl.[QuantityOfStones], tbl.[ImpactedStones], tbl.[OtherReason], tbl.[OtherReasonText], tbl.[StoneDecompressed], tbl.[StrictureDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[StrictureDecompressed], tbl.[EndoscopicCystPuncture], tbl.[CystPunctureDevice], tbl.[CystPunctureVia], tbl.[Cannulation], tbl.[Manometry], tbl.[Haemostasis], tbl.[NasopancreaticDrain], tbl.[RendezvousProcedure], tbl.[SnareExcision], tbl.[BalloonDilation], tbl.[BalloonDilatedTo], tbl.[BalloonDilatationUnits], tbl.[BalloonDilatorType], tbl.[BalloonTrawl], tbl.[BalloonTrawlDilatorType], tbl.[BalloonTrawlDilatorSize], tbl.[BalloonTrawlDilatorUnits], tbl.[BalloonDecompressed], tbl.[DiagCholangiogram], tbl.[DiagPancreatogram], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  LastActionId, ActionDateTime, ActionUserId)
		SELECT tbl.Id , tbl.[SiteId], tbl.[None], tbl.[YAGLaser], tbl.[YAGLaserWatts], tbl.[YAGLaserPulses], tbl.[YAGLaserSecs], tbl.[YAGLaserKJ], tbl.[ArgonBeamDiathermy], tbl.[ArgonBeamDiathermyWatts], tbl.[ArgonBeamDiathermyPulses], tbl.[ArgonBeamDiathermySecs], tbl.[ArgonBeamDiathermyKJ], tbl.[BandLigation], tbl.[BotoxInjection], tbl.[EndoloopPlacement], tbl.[HeatProbe], tbl.[BicapElectro], tbl.[Diathermy], tbl.[ForeignBody], tbl.[HotBiopsy], tbl.[Injection], tbl.[InjectionType], tbl.[InjectionVolume], tbl.[InjectionNumber], tbl.[GastrostomyInsertion], tbl.[GastrostomyInsertionSize], tbl.[GastrostomyInsertionUnits], tbl.[GastrostomyInsertionType], tbl.[GastrostomyInsertionBatchNo], tbl.[GastrostomyRemoval], tbl.[NilByMouth], tbl.[NilByMouthHrs], tbl.[NilByProc], tbl.[NilByProcHrs], tbl.[AttachmentToWard], tbl.[PyloricDilatation], tbl.[StentInsertion], tbl.[StentInsertionQty], tbl.[RadioactiveWirePlaced], tbl.[StentInsertionBatchNo], tbl.[StentDecompressedDuct], tbl.[CorrectStentPlacement], tbl.[StentRemoval], tbl.[StentRemovalTechnique], tbl.[EMR], tbl.[EMRType], tbl.[EMRFluid], tbl.[EMRFluidVolume], tbl.[Marking], tbl.[MarkingType], tbl.[Clip], tbl.[ClipNum], tbl.[Papillotomy], tbl.[Sphincterotome], tbl.[PapillotomyLength], tbl.[PapillotomyAcceptBalloonSize], tbl.[ReasonForPapillotomy], tbl.[PapillotomyBleeding], tbl.[SphincterDecompressed], tbl.[PanOrificeSphincterotomy], tbl.[StoneRemoval], tbl.[RemovalUsing], tbl.[ExtractionOutcome], tbl.[InadequateSphincterotomy], tbl.[StoneSize], tbl.[QuantityOfStones], tbl.[ImpactedStones], tbl.[OtherReason], tbl.[OtherReasonText], tbl.[StoneDecompressed], tbl.[StrictureDilatation], tbl.[DilatedTo], tbl.[DilatationUnits], tbl.[DilatorType], tbl.[StrictureDecompressed], tbl.[EndoscopicCystPuncture], tbl.[CystPunctureDevice], tbl.[CystPunctureVia], tbl.[Cannulation], tbl.[Manometry], tbl.[Haemostasis], tbl.[NasopancreaticDrain], tbl.[RendezvousProcedure], tbl.[SnareExcision], tbl.[BalloonDilation], tbl.[BalloonDilatedTo], tbl.[BalloonDilatationUnits], tbl.[BalloonDilatorType], tbl.[BalloonTrawl], tbl.[BalloonTrawlDilatorType], tbl.[BalloonTrawlDilatorSize], tbl.[BalloonTrawlDilatorUnits], tbl.[BalloonDecompressed], tbl.[DiagCholangiogram], tbl.[DiagPancreatogram], tbl.[Other], tbl.[EUSProcType], tbl.[CarriedOutRole], tbl.[Summary],  2, GETDATE(), i.WhoUpdatedId
		FROM deleted tbl INNER JOIN inserted i ON tbl.Id = i.Id
	END
GO

------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('ERS_UserOperatingHospitals') AND type = 'U')
BEGIN
	CREATE TABLE dbo.ERS_UserOperatingHospitals(
		[UniqueId] [int]  IDENTITY(1,1) NOT NULL CONSTRAINT [ERS_ERS_UserOperatingHospitals] PRIMARY KEY CLUSTERED ([UniqueId] ASC) ON [PRIMARY],
		[UserId] [int] NOT NULL CONSTRAINT FK_UserOperatingHospital_UserId FOREIGN KEY REFERENCES ERS_Users (UserId),
		[OperatingHospitalId] [int] NOT NULL CONSTRAINT FK_UserOperatingHospital_OperatingHospitalId FOREIGN KEY REFERENCES ERS_OperatingHospitals (OperatingHospitalId)
	)
END
GO

--BULK INSERT FOR ANY EXISTING USERS TO ADD THEM TO THE INITIAL OPERATING HOSPITAL 
INSERT INTO dbo.ERS_UserOperatingHospitals
(
    --UniqueId - this column value is auto-generated
    UserId,
    OperatingHospitalId
)
SELECT UserId, oh.OperatingHospitalId FROM ERS_Users, ERS_OperatingHospitals oh WHERE userid NOT IN (SELECT userID FROM dbo.ERS_UserOperatingHospitals euoh)
GO
------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM SYS.FOREIGN_KEYS WHERE OBJECT_ID = OBJECT_ID('UQ_UserName') AND parent_object_id = OBJECT_ID('ERS_Users'))
	ALTER TABLE [dbo].[ERS_Users] DROP CONSTRAINT [UQ_UserName]
GO
------------------------------------------------------------------------------------

EXEC DropIfExist 'tvfUsersByOperatingHospital', 'F'
GO

CREATE FUNCTION tvfUsersByOperatingHospital
(	
	-- Add the parameters for the function here
	@operatingHospitalId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT eu.* FROM dbo.ERS_Users eu 
		INNER JOIN dbo.ERS_UserOperatingHospitals euoh ON eu.UserID = euoh.UserId
	WHERE euoh.OperatingHospitalId  = @OperatingHospitalId
)
GO

------------------------------------------------------------------------------------


SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'usp_Procedures_Insert','S';
GO

CREATE PROCEDURE [dbo].[usp_Procedures_Insert]
(
	@ProcedureType		INT,
	--@PatientNo		VARCHAR(24),
	@PatientId			INT,
	@ProcedureDate		DATETIME,
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
	@CategoryListId	INT,
	@OnWaitingList		BIT,
	@OpenAccessProc		TINYINT,
	@EmergencyProcType	TINYINT,
	@NewProcedureId		INT OUTPUT,	-- This will return the newly created ProcedureId to the GUI! To play
	@ImagePortId		INT
)
AS

SET NOCOUNT ON

DECLARE @newProcId INT
DECLARE @ppEndos VARCHAR(2000), @GPName varchar(255), @GPAddress varchar(max), @Endo1 varchar(500)

BEGIN TRANSACTION
--sp_help 'dbo.ERS_Procedures'
	BEGIN TRY
		INSERT INTO ERS_Procedures
			(ProcedureType,
			CreatedBy,	
			CreatedOn,
			ModifiedOn,
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
			WhenCreated)
		VALUES (
			@ProcedureType,
			@UserID,
			@ProcedureDate, --CASE WHEN CONVERT(DATE, GETDATE()) = @ProcedureDate THEN GETDATE() ELSE @ProcedureDate END, --Insert date and time if Procedure date is current date
			GETDATE(),
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
			GETDATE())

		SET @newProcId = SCOPE_IDENTITY();
	
		--## Important Work- Insert a Blank Record in the ERS_ProceduresReorting- with this Unique ID! So, you can simply Update the PP fields later..!! 
		INSERT INTO dbo.ERS_ProceduresReporting(ProcedureId)VALUES(@newProcId);

		SET @ppEndos = ''
		IF @ListConsultant > 0 SELECT @ppEndos = @ppEndos + '$$' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @ListConsultant
		IF @Endoscopist1 > 0 
		BEGIN
			SELECT @Endo1 = Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Endoscopist1
			SELECT @ppEndos = @ppEndos + '$$' + @Endo1
		END
		IF @Endoscopist2 > 0 SELECT @ppEndos = @ppEndos + '$$' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Endoscopist2
		IF @Nurse1 > 0 OR @Nurse2 > 0 OR @Nurse3 > 0 
		BEGIN
			SELECT @ppEndos = @ppEndos + '$$' + 'Nurses: '
			IF @Nurse1 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Nurse1
			IF @Nurse2 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Nurse2
			IF @Nurse3 > 0 SELECT @ppEndos =  @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE UserID = @Nurse3
		END
		IF CHARINDEX('$$', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('$$', @ppEndos), 2, ''), '$$', '<br/>')
		IF CHARINDEX('##', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('##', @ppEndos), 2, ''), '##', '<br/>')
	
		--SELECT @GPName = p.[GP Name] , @GPAddress = p.[GP Address] FROM Patient p left join  ERS_Procedures pr ON p.[Patient No]= pr.PatientId WHERE pr.ProcedureId = @newProcId
		--SELECT @GPName = p.[GP Name] , @GPAddress = p.[GP Address] FROM ERS_Patients p WHERE p.[Patient No]= @PatientId

		--Get GP practice name and address
		SELECT 	TOP 1 
				@GPName		= p.[GPName],
				@GPAddress	= p.GPAddress
		FROM ERS_VW_PatientswithGP p 
		WHERE p.PatientId = @PatientId

		UPDATE ERS_ProceduresReporting SET PP_Endos = @ppEndos, PP_GPName = @GPName, PP_GPAddress = @GPAddress, PP_Endo1 = @Endo1 WHERE ProcedureId = @newProcId

		UPDATE ERS_Consultant SET SortOrder = ISNULL(SortOrder,0) + 1 WHERE ConsultantID = @ReferralConsultantNo

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

--------------------------------------------------------------------------------------------------------

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'common_select_menu','S';
GO

CREATE Procedure [dbo].[common_select_menu]
(
	@UserID int,
	@isViewer bit,
	@isDemoVersion bit,
	@MenuCategory varchar(50),
	@OperatingHospitalId int
)
AS 

DECLARE @RoleID VARCHAR(70) 
SELECT @RoleID=RoleID FROM tvfUsersByOperatingHospital(@OperatingHospitalId) where UserID = @UserID

SELECT [item] INTO #tmpRole FROM dbo.fnSplitString(@RoleID,',') 

SELECT [MapID],[ParentID],[NodeName],[MenuCategory],ISNULL([MenuUrl],'') AS MenuUrl ,[isViewer],[isDemoVersion],ISNULL([MenuIcon],'') AS MenuIcon, ISNULL([MenuTooltip],'') AS MenuTooltip , Suppressed
INTO #Menu
FROM [ERS_MenuMap] m LEFT JOIN ERS_Pages ep ON m.PageID = ep.PageID
WHERE MenuCategory = @MenuCategory AND (isViewer = @isViewer OR isViewer=1) AND (isDemoVersion = @isDemoVersion OR isDemoVersion=0) 
AND (m.PageID=0 
	OR 0 <> CASE @UserID   --AccessLevel should be 1(Read-Only) or 9(Full Access) for user to have access. 0 is No Access.
				WHEN -9999 THEN --User Unisoft
					ISNULL((SELECT MAX(AccessLevel) 
							FROM ERS_PagesByRole pr 
							INNER JOIN ERS_Pages p ON p.PageId = pr.PageId 
							WHERE  p.PageId = m.PageID  
							AND pr.RoleID = (SELECT TOP 1 RoleId FROM ERS_Roles WHERE RoleName = 'Unisoft') ),0)
				ELSE
					ISNULL((SELECT MAX(AccessLevel) 
							FROM ERS_PagesByRole pr 
							INNER JOIN  tvfUsersByOperatingHospital(@OperatingHospitalId) u ON pr.RoleId IN (SELECT [item] FROM #tmpRole)
								AND u.UserId =@UserID  
							INNER JOIN ERS_Pages p ON p.PageId = pr.PageId 
							WHERE  p.PageId = m.PageID) ,0)
			END)

DELETE FROM #Menu WHERE Suppressed=1 OR MenuUrl =''

SELECT [MapID],[ParentID],[NodeName],[MenuCategory],ISNULL([MenuUrl],'') AS MenuUrl ,[isViewer],[isDemoVersion],ISNULL([MenuIcon],'') AS MenuIcon, ISNULL([MenuTooltip],'') AS MenuTooltip, Suppressed
INTO #Menus
FROM [ERS_MenuMap] m
WHERE m.MapID IN (SELECT DISTINCT ParentID FROM #Menu WHERE ParentID IS NOT NULL) 
UNION 
SELECT * FROM  #Menu

SELECT * from #Menus 

DROP TABLE #Menu
DROP TABLE #Menus

GO

--------------------------------------------------------------------------------------------------------


SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'common_phraselibrary_save','S';
GO

CREATE PROCEDURE [dbo].[common_phraselibrary_save]
(
	@UserName varchar(50),
	@PhraseCategory varchar(50),
	@Phrase varchar(8000),
	@OperatingHospitalId INT,
	@LoggedInUserId INT
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
DECLARE @UserID int
SELECT @UserID = UserID FROM tvfUsersByOperatingHospital(@OperatingHospitalId) WHERE Username = @UserName
SET @UserID = ISNULL(@UserID,0)

IF NOT EXISTS(SELECT 1 FROM [ERS_PhraseLibrary] WHERE UserID = @UserID  AND PhraseCategory = @PhraseCategory AND Phrase = @Phrase) --AND @User IS NOT NUll
	BEGIN
	INSERT INTO [ERS_PhraseLibrary] (UserID,PhraseCategory,Phrase,OperatingHospitalId,WhoCreatedId,WhenCreated) VALUES (@UserID, @PhraseCategory, @Phrase,@OperatingHOspitalId,@LoggedInUserId,GETDATE());
	SELECT @@IDENTITY AS 'Identity';
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



--------------------------------------------------------------------------------------------------------




--------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------

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
		From ERS_Procedures PR, tvfUsersByOperatingHospital(PR.OperatingHospitalId) U, ERS_Sites S, ERS_UpperGITherapeutics T
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




--------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name IN (N'Initial',N'Type',N'CompleteName') AND Object_ID = (Object_ID(N'ERS_Consultant')))
BEGIN
	ALTER TABLE ERS_Consultant ADD 
		[Initial] nvarchar(5),
		[Type] nvarchar(3),
		[CompleteName] AS ([DBO].[fnFormatCompleteName]([Title],[Initial],[Surname]))
END
GO

ALTER TABLE ERS_Consultant ALTER COLUMN GMCCode varchar(25)
GO
IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ERSAudit' AND TABLE_NAME = 'ERS_Consultant_Audit'))
	ALTER TABLE ERSAudit.ERS_Consultant_Audit ALTER COLUMN GMCCode varchar(25)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.objects WHERE OBJECT_ID = OBJECT_ID('UK_Consultant') AND parent_object_id = OBJECT_ID('ERS_Consultant'))
	ALTER TABLE dbo.ERS_Consultant ADD CONSTRAINT [UK_Consultant] UNIQUE ([Forename], [Surname], [GMCCode])
GO
--------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Code' AND Object_ID = Object_ID(N'ERS_ConsultantGroup'))
	ALTER TABLE ERS_ConsultantGroup ADD Code varchar(5)
GO

IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ERSAudit' AND TABLE_NAME = 'ERS_ConsultantGroup_Audit'))
	IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Code' AND Object_ID = Object_ID(N'ERSAudit.ERS_ConsultantGroup_Audit'))
		ALTER TABLE ERSAudit.ERS_ConsultantGroup_Audit ADD Code varchar(5)
GO

IF NOT EXISTS (SELECT 1 FROM SYS.objects WHERE OBJECT_ID = OBJECT_ID('UK_ConsultantGroupName') AND parent_object_id = OBJECT_ID('ERS_ConsultantGroup'))
	ALTER TABLE ERS_ConsultantGroup ADD CONSTRAINT [UK_ConsultantGroupName] UNIQUE ([GroupName])
GO

IF NOT EXISTS (SELECT 1 FROM SYS.objects WHERE OBJECT_ID = OBJECT_ID('UK_ConsultantGroupCode') AND parent_object_id = OBJECT_ID('ERS_ConsultantGroup'))
	ALTER TABLE ERS_ConsultantGroup ADD CONSTRAINT [UK_ConsultantGroupCode] UNIQUE ([GroupName])
GO

--------------------------------------------------------------------------------------------------------

TRUNCATE TABLE [ERS_ConsultantGroup]
GO

INSERT INTO [dbo].[ERS_ConsultantGroup](Code, GroupName)
VALUES ('99', 'DUMMY LINE'),							('100', 'GENERAL SURGERY')
	,('101', 'UROLOGY'),								('110', 'TRAUMA & ORTHOPAEDICS')
	,('120', 'ENT'),									('130', 'OPHTHALMOLOGY')
	,('140', 'ORAL SURGERY'),							('141', 'RESTORATIVE DENTISTRY')
	,('142', 'PAEDIATRIC DENTISTRY'),					('143', 'ORTHODONTICS')
	,('145', 'ORAL & MAXILLO FACIAL SURGERY'),			('146', 'ENDODONTICS')
	,('147', 'PERIODONTICS'),							('148', 'PROSTHODONTICS')
	,('149', 'SURGICAL DENTISTRY'),						('150', 'NEUROSURGERY')
	,('160', 'PLASTIC SURGERY'),						('170', 'CARDIOTHORACIC SURGERY')
	,('171', 'PAEDIATRIC SURGERY'),						('180', 'ACCIDENT & EMERGENCY')
	,('190', 'ANAESTHETICS'),							('192', 'CRITICAL CARE MEDICINE')
	,('199', 'Non-UK provider; specialty function not known treatment mainly surgical')
	,('300', 'GENERAL MEDICINE'),						('301', 'GASTROENTEROLOGY')
	,('302', 'ENDOCRINOLOGY'),							('303', 'CLINICAL HAEMATOLOGY')
	,('304', 'CLINICAL PHYSIOLOGY'),					('305', 'CLINICAL PHARMACOLOGY')
	,('310', 'AUDIOLOGICAL MEDICINE'),					('311', 'CLINICAL GENETICS')
	,('312', 'CLINICAL CYTOGENETICS and MOLECULAR GENETICS'),('313', 'CLINICAL IMMUNOLOGY and ALLERGY')
	,('314', 'REHABILITATION'),							('315', 'PALLIATIVE MEDICINE')
	,('320', 'CARDIOLOGY'),								('321', 'PAEDIATRIC CARDIOLOGY')
	,('325', 'SPORTS AND EXERCISE MEDICINE'),			('326', 'ACUTE INTERNAL MEDICINE')
	,('330', 'DERMATOLOGY'),							('340', 'RESPIRATORY MEDICINE')
	,('341', 'RESPIRATORY PHYSIOLOGY'),					('342', 'PROGRAMMED PULMONARY REHABILITATION')
	,('343', 'ADULT CYSTIC FIBROSIS SERVICE'),			('344', 'COMPLEX SPECIALISED REHABILITATION SERVICE')
	,('345', 'SPECIALIST REHABILITATION SERVICE'),		('346', 'LOCAL SPECIALIST REHABILITATION SERVICE')
	,('350', 'INFECTIOUS DISEASES'),					('352', 'TROPICAL MEDICINE')
	,('360', 'GENITOURINARY MEDICINE'),					('361', 'NEPHROLOGY')
	,('370', 'MEDICAL ONCOLOGY'),						('371', 'NUCLEAR MEDICINE')
	,('400', 'NEUROLOGY'),								('401', 'CLINICAL NEURO-PHYSIOLOGY')
	,('410', 'RHEUMATOLOGY'),							('420', 'PAEDIATRICS')
	,('421', 'PAEDIATRIC NEUROLOGY'),					('430', 'GERIATRIC MEDICINE')
	,('450', 'DENTAL MEDICINE SPECIALTIES'),			('451', 'SPECIAL CARE DENTISTRY')
	,('460', 'MEDICAL OPHTHALMOLOGY'),					('499', 'Non-UK provider; specialty function not known  treatment mainly medical')
	,('500', 'OBSTETRICS and GYNAECOLOGY'),				('501', 'OBSTETRICS')
	,('502', 'GYNAECOLOGY'),							('504', 'COMMUNITY SEXUAL AND REPRODUCTIVE HEALTH')
	,('560', 'MIDWIFE EPISODE'),						('600', 'GENERAL MEDICAL PRACTICE')
	,('601', 'GENERAL DENTAL PRACTICE'),				('700', 'LEARNING DISABILITY')
	,('710', 'ADULT MENTAL ILLNESS'),					('711', 'CHILD and ADOLESCENT PSYCHIATRY')
	,('712', 'FORENSIC PSYCHIATRY'),					('713', 'PSYCHOTHERAPY')
	,('715', 'OLD AGE PSYCHIATRY'),						('800', 'CLINICAL ONCOLOGY')
	,('810', 'RADIOLOGY'),								('820', 'GENERAL PATHOLOGY')
	,('821', 'BLOOD TRANSFUSION'),						('822', 'CHEMICAL PATHOLOGY')
	,('823', 'HAEMATOLOGY'),							('824', 'HISTOPATHOLOGY')
	,('830', 'IMMUNOPATHOLOGY'),						('831', 'MEDICAL MICROBIOLOGY AND VIROLOGY')
	,('833', 'MEDICAL MICROBIOLOGY'),					('834', 'MEDICAL VIROLOGY')
	,('900', 'COMMUNITY MEDICINE'),						('901', 'OCCUPATIONAL MEDICINE')
	,('902', 'COMMUNITY HEALTH SERVICES DENTAL'),		('903', 'PUBLIC HEALTH MEDICINE')
	,('904', 'PUBLIC HEALTH DENTAL'),					('950', 'NURSING EPISODE')
	,('960', 'ALLIED HEALTH PROFESSIONAL EPISODE');

GO
--------------------------------------------------------------------------------------------------------

IF (SELECT ImportConsultants FROM #variables) = 1
BEGIN
	IF OBJECT_ID('tempdb..#TempConsultants') IS NOT NULL DROP TABLE #TempConsultants

	Create Table #TempConsultants ( SURNAME varchar(50), initial varchar(50),Title varchar(50),Forename varchar(50),GMCCODE varchar(50),
	LocalCode varchar(50),SpecialtyCode varchar(50),Telephone varchar(50), Mobile varchar(50),Pager varchar(50),Email varchar(50))
								BULK INSERT #TempConsultants  from 
								'C:\ERS\Consultants.txt'   WITH ( FIELDTERMINATOR ='|' , ROWTERMINATOR ='\n',  FIRSTROW = 2 )



	update #TempConsultants set initial = left(forename,1)

	insert into ERS_Consultant (Type, [Surname],Title, Initial, [Forename] , [GMCCode] , [GroupId])
	select 'CO',SURNAME, Title, initial ,Forename ,GMCCODE,SpecialtyCode from #TempConsultants

	--Added due to Sandwell having specialties outside the NHS standards

	IF OBJECT_ID('tempdb..#TempSpecialties') IS NOT NULL DROP TABLE #TempSpecialties

	Create Table #TempSpecialties ( code varchar(10), name varchar(50))
	BULK INSERT #TempSpecialties from  'C:\ERS\SpecTopUp.txt'   WITH ( FIELDTERMINATOR =',' , ROWTERMINATOR ='\n',  FIRSTROW = 1 )

	insert into ERS_ConsultantGroup(code,groupname) select code,name from #TempSpecialties
END
GO
--------------------------------------------------------------------------------------------------------

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'common_consultant_select','S';
GO

CREATE PROCEDURE [dbo].[common_consultant_select]
(
	@OperatingHospitalId INT
	,@Field VARCHAR(200)
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
					THEN '(c.[Surname]	LIKE ''%'		+ @FieldValue + '%'' 
						OR c.[Forename] LIKE ''%'	+ @FieldValue + '%'' 
						OR c.[Title]	LIKE ''%'		+ @FieldValue + '%'' 
						OR g.[GroupName] LIKE ''%'	+ @FieldValue + '%'') '
					WHEN @Field = 'SURNAME' AND @FieldValue <> '' THEN 'c.[Surname]		LIKE ''%'	+ @FieldValue + '%'' '
					WHEN @Field = 'NAME'	AND @FieldValue <> '' THEN 'c.[Forename]	LIKE ''%'	+ @FieldValue + '%'' '
					WHEN @Field = 'TITLE'	AND @FieldValue <> '' THEN 'c.[Title]		LIKE ''%'	+ @FieldValue + '%'' '
					WHEN @Field = 'GROUP'	AND @FieldValue <> '' THEN 'g.[GroupName]	LIKE ''%'	+ @FieldValue + '%'' ' 
					WHEN @Field = 'GROUPID'	AND @FieldValue <> '' THEN 'g.[Code]		= '''		+ @FieldValue + ''' ' 
					ELSE ''
				END
	IF @Suppressed IS NOT NULL
	BEGIN
		IF @SQL <> '' SET @SQL = @SQL + ' AND '
		SET @SQL = @SQL + ' c.[Suppressed] = ' + CONVERT(VARCHAR, @Suppressed) 
	END

	IF @SQL <> '' SET @SQL = ' WHERE ' + @SQL  

	SET @SQL = '
	SELECT c.[ConsultantID]
		,LTRIM(RTRIM((SELECT ISNULL(c.[Title], '''') + '' '' + ISNULL(c.[Forename], '''')))) AS NAME
		,LTRIM(RTRIM((SELECT ISNULL(c.[Title], '''') + '' '' + ISNULL(c.[Forename], '''') + '' '' + ISNULL(c.[Surname], '''')))) AS FULLNAME
		,c.[Surname]
		,g.[GroupName]
		,(SELECT CASE (
						SELECT CASE (SELECT AllHospitals
									FROM [ERS_Consultant]
									WHERE [ConsultantID] = c.ConsultantID)
								WHEN 1 THEN -1
								ELSE COUNT(ConsultantsHospitalID)
                     END
						FROM ERS_ConsultantsHospital
						WHERE [ConsultantID] = c.[ConsultantID]
						)
					WHEN - 1 THEN ''(All hospitals)''
                     WHEN 0 THEN ''(Unspecified)''
					WHEN 1 THEN (
								SELECT h.[HospitalName]
								FROM [ERS_ReferralHospitals] h
								LEFT JOIN ERS_ConsultantsHospital ch ON h.[HospitalID] = ch.[HospitalID]
								WHERE ch.ConsultantID = c.ConsultantID
								)
                     ELSE ''(Multiple hospitals)''
                     END
			) AS Hospital
		,CASE WHEN ISNULL(c.[Suppressed], 0) = 0
					THEN ''No''
				ELSE ''Yes''
				END AS Suppressed
                     FROM [ERS_Consultant] c  
	LEFT JOIN [ERS_ConsultantGroup] g ON c.[GroupID] = g.[Code]
	' + @SQL + '
	ORDER BY 
			CASE WHEN ((SELECT TOP 1 SortReferringConsultantBy FROM ERS_SystemConfig WHERE OperatingHospitalId = ' + convert(nvarchar,@OperatingHospitalId) + ') = 1) THEN c.SortOrder END DESC,
			c.Surname'

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

--------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'common_consultant_suppress_select','S';
GO

CREATE PROCEDURE [dbo].[common_consultant_suppress_select]
(
	@Field varchar(200),
	@FieldValue varchar(200)
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
       IF @Field is not null AND @FieldValue is not null AND @Field <> '' AND @FieldValue<>''
              BEGIN
              IF @Field='SURNAME' 
                     BEGIN
                     SELECT c.[ConsultantID] , 
                  LTRIM(RTRIM((SELECT ISNULL(c.[Title],'') + ' ' + ISNULL(c.[Forename] , '')))) as  Name,
                     c.[Surname], 
                     g.[GroupName],    
                     (SELECT CASE (SELECT CASE(SELECT AllHospitals FROM [ERS_Consultant] WHERE [ConsultantID] = c.ConsultantID) WHEN 1 THEN -1 ELSE COUNT(ConsultantsHospitalID) END FROM  ERS_ConsultantsHospital WHERE [ConsultantID]= c.[ConsultantID])
                     WHEN -1 THEN '(All hospitals)'
                     WHEN 0 THEN '(Unspecified)'
                     WHEN 1 THEN (SELECT h.[HospitalName] FROM  [ERS_ReferralHospitals] h LEFT JOIN ERS_ConsultantsHospital ch ON h.[HospitalID] = ch.[HospitalID] WHERE ch.ConsultantID=c.ConsultantID)
                     ELSE '(Multiple hospitals)'
                 END) AS Hospital,
                     CASE WHEN c.[Suppressed]=0 OR c.[Suppressed] IS NULL THEN 'No' ELSE 'Yes' END AS Suppressed 
                     FROM [ERS_Consultant] c  
                     LEFT JOIN [ERS_ConsultantGroup] g 
                     ON c.[GroupID] = g.[Code] WHERE c.[Surname] LIKE '%' + @FieldValue + '%' AND  c.[Suppressed]=0 OR c.[Suppressed] IS NULL
                     END
                     IF @Field='NAME' 
                     BEGIN
                     SELECT c.[ConsultantID] , 
                  LTRIM(RTRIM((SELECT ISNULL(c.[Title],'') + ' ' + ISNULL(c.[Forename] , '')))) as  Name,
                     c.[Surname], 
                     g.[GroupName],    
                     (SELECT CASE (SELECT CASE(SELECT AllHospitals FROM [ERS_Consultant] WHERE [ConsultantID] = c.ConsultantID) WHEN 1 THEN -1 ELSE COUNT(ConsultantsHospitalID) END FROM  ERS_ConsultantsHospital WHERE [ConsultantID]= c.[ConsultantID])
                     WHEN -1 THEN '(All hospitals)'
                     WHEN 0 THEN '(Unspecified)'
                     WHEN 1 THEN (SELECT h.[HospitalName] FROM  [ERS_ReferralHospitals] h LEFT JOIN ERS_ConsultantsHospital ch ON h.[HospitalID] = ch.[HospitalID] WHERE ch.ConsultantID=c.ConsultantID)
                     ELSE '(Multiple hospitals)'
                 END) AS Hospital,
                     CASE WHEN c.[Suppressed]=0 OR c.[Suppressed] IS NULL THEN 'No' ELSE 'Yes' END AS Suppressed 
                     FROM [ERS_Consultant] c  
                     LEFT JOIN [ERS_ConsultantGroup] g 
                     ON c.[GroupID] = g.[Code] WHERE  LTRIM(RTRIM((SELECT ISNULL(c.[Title],'') + ' ' + ISNULL(c.[Forename] , '')))) LIKE '%' + @FieldValue + '%' AND  c.[Suppressed]=0 OR c.[Suppressed] IS NULL
                     END
                     IF @Field='GROUP' 
                     BEGIN
                     SELECT c.[ConsultantID] , 
                  LTRIM(RTRIM((SELECT ISNULL(c.[Title],'') + ' ' + ISNULL(c.[Forename] , '')))) as  Name,
                     c.[Surname], 
                     g.[GroupName],   
                     (SELECT CASE (SELECT CASE(SELECT AllHospitals FROM [ERS_Consultant] WHERE [ConsultantID] = c.ConsultantID) WHEN 1 THEN -1 ELSE COUNT(ConsultantsHospitalID) END FROM  ERS_ConsultantsHospital WHERE [ConsultantID]= c.[ConsultantID])
                     WHEN -1 THEN '(All hospitals)'
                     WHEN 0 THEN '(Unspecified)'
                     WHEN 1 THEN (SELECT h.[HospitalName] FROM  [ERS_ReferralHospitals] h LEFT JOIN ERS_ConsultantsHospital ch ON h.[HospitalID] = ch.[HospitalID] WHERE ch.ConsultantID=c.ConsultantID)
                     ELSE '(Multiple hospitals)'
                 END) AS Hospital,
                     CASE WHEN c.[Suppressed]=0 OR c.[Suppressed] IS NULL THEN 'No' ELSE 'Yes' END AS Suppressed 
                     FROM [ERS_Consultant] c  
                     LEFT JOIN [ERS_ConsultantGroup] g 
                     ON c.[GroupID] = g.[Code] WHERE g.[GroupName]LIKE '%' + @FieldValue + '%' AND  c.[Suppressed]=0 OR c.[Suppressed] IS NULL
                     END
              END
       ELSE
              BEGIN
              SELECT c.[ConsultantID] , 
          LTRIM(RTRIM((SELECT ISNULL(c.[Title],'') + ' ' + ISNULL(c.[Forename] , '')))) as  Name,
              c.[Surname], 
              g.[GroupName],   
                     (SELECT CASE (SELECT CASE(SELECT AllHospitals FROM [ERS_Consultant] WHERE [ConsultantID] = c.ConsultantID) WHEN 1 THEN -1 ELSE COUNT(ConsultantsHospitalID) END FROM  ERS_ConsultantsHospital WHERE [ConsultantID]= c.[ConsultantID])
                     WHEN -1 THEN '(All hospitals)'
                     WHEN 0 THEN '(Unspecified)'
                     WHEN 1 THEN (SELECT h.[HospitalName] FROM  [ERS_ReferralHospitals] h LEFT JOIN ERS_ConsultantsHospital ch ON h.[HospitalID] = ch.[HospitalID] WHERE ch.ConsultantID=c.ConsultantID)
                     ELSE '(Multiple hospitals)'
                 END) AS Hospital,
              CASE WHEN c.[Suppressed]=0 OR c.[Suppressed] IS NULL THEN 'No' ELSE 'Yes' END AS Suppressed 
              FROM [ERS_Consultant] c  
              LEFT JOIN [ERS_ConsultantGroup] g 
              ON c.[GroupId] = g.[Code] WHERE c.[Suppressed]=0 OR c.[Suppressed] IS NULL
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

--------------------------------------------------------------------------------------------------------

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'common_speciality_save','S';
GO

CREATE PROCEDURE [dbo].[common_speciality_save]
(
	@GroupName varchar(100),
	@GroupCode varchar(100)
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	INSERT INTO [ERS_ConsultantGroup] ([GroupName], [Code]) VALUES (@GroupName, @GroupCode)

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

--------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT 1 FROM ERS_Pages WHERE PageId = 124)
	INSERT [dbo].[ERS_Pages] ([PageId], [PageName], [AppPageName], [GroupId], [PageAlias],[PageURL]) VALUES 
	(124,'Admin Utilities -> Referring Hospitals','products_options_referringhospitals_aspx',3,'Referring Hospitals','~/products/options/referringhospitals.aspx')
GO

IF NOT EXISTS(SELECT 1 FROM ERS_PagesByRole WHERE PageId = 124)
BEGIN
	INSERT INTO ERS_PagesByRole ([RoleId], [PageId], [AccessLevel])
	SELECT  (SELECT TOP 1 RoleID FROM ERS_Roles WHERE RoleName = 'Unisoft')
			,124
			, 9

	--Populate table ERS_PagesByRole for 'System Administrators'
	INSERT INTO ERS_PagesByRole ([RoleId], [PageId], [AccessLevel])
	SELECT  (SELECT TOP 1 RoleID FROM ERS_Roles WHERE RoleName = 'System Administrators')
			,124
			, 9
END	
GO

IF NOT EXISTS(SELECT 1 FROM ERS_MenuMap WHERE PageId = 124)
BEGIN
	DECLARE @MapID int

	SELECT TOP 1 @MapID = MapID FROM ERS_MenuMap WHERE NodeName = 'Admin Utilities' AND MenuCategory = 'Configure'
	INSERT [dbo].[ERS_MenuMap] ([ParentID], [NodeName], [MenuCategory], [MenuUrl], [isViewer], [isDemoVersion], [PageID], [MenuIcon], [MenuTooltip], [Suppressed]) VALUES 
	(@MapID, N'Referring Hospitals', N'Configure', N'~/Products/Options/ReferringHospitals.aspx', 0, 0, 124, NULL, NULL, 0)
END
GO


--------------------------------------------------------------------------------------------------------

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'common_consultant_save','S';
GO

CREATE PROCEDURE [dbo].[common_consultant_save]
(
	@ConsultantID INT,
	@Title varchar(10),
	@Initial varchar(10),
	@Forename varchar(100),
	@Surname varchar(100),
	@GroupID int,
	@AllHospitals tinyint,
	@GMCCode varchar(10),
	@HospitalList varchar(100),
	@LoggedInUserId int
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	Declare @Hospital varchar(20) = null
	IF @ConsultantID IS NULL OR @ConsultantID=0
		BEGIN
		INSERT INTO [ERS_Consultant]([Title],[Initial],[Forename],[Surname],[GroupID],[AllHospitals],[GMCCode],WhoCreatedId, WhenCreated) VALUES(@Title,@Initial,@Forename,@Surname,@GroupID,@AllHospitals,@GMCCode,@LoggedInUserId,GETDATE())
		SET @ConsultantID = (SELECT SCOPE_IDENTITY())
		IF @AllHospitals = 0 AND @HospitalList is not null
			BEGIN			    
			WHILE LEN(@HospitalList) > 0
				BEGIN
				IF PATINDEX('%|%',@HospitalList) > 0
					BEGIN
					SET @Hospital = SUBSTRING(@HospitalList, 0, PATINDEX('%|%',@HospitalList))
					IF  @Hospital IS NOT NULL AND NOT EXISTS(SELECT 1 FROM [ERS_ConsultantsHospital] WHERE [HospitalID] = @Hospital AND [ConsultantID] = @ConsultantID )
						BEGIN
						INSERT INTO [ERS_ConsultantsHospital] ([ConsultantID],[HospitalID], WhoCreatedId, WhenCreated) VALUES(@consultantid,@Hospital,@LoggedInUserId, GETDATE())
						END
					SET @HospitalList = SUBSTRING(@HospitalList, LEN(@Hospital + '|') + 1, LEN(@HospitalList))
					END
				ELSE
					BEGIN
					SET @Hospital = @HospitalList
					SET @HospitalList = NULL
					IF  @Hospital IS NOT NULL AND NOT EXISTS(SELECT 1 FROM [ERS_ConsultantsHospital] WHERE [HospitalID] = @Hospital AND [ConsultantID] = @ConsultantID )
						BEGIN
						INSERT INTO [ERS_ConsultantsHospital] ([ConsultantID],[HospitalID], WhoCreatedId, WhenCreated) VALUES(@consultantid,@Hospital,@LoggedInUserId, GETDATE())
						END
					END
				END
			END
		END
	ELSE
		BEGIN
		UPDATE [ERS_Consultant] SET Title = @Title,Initial = @Initial, Forename = @Forename,Surname = @Surname, GroupID = @GroupID, AllHospitals = @AllHospitals,GMCCode = @GMCCode, WhoUpdatedId = @LoggedInUserId, WhenUpdated = GETDATE() WHERE ConsultantID = @ConsultantID
		DELETE FROM [ERS_ConsultantsHospital] WHERE ConsultantID   = @ConsultantID
		IF @AllHospitals = 0 AND @HospitalList is not null
			BEGIN			
		   	WHILE LEN(@HospitalList) > 0
				BEGIN
				IF PATINDEX('%|%',@HospitalList) > 0
					BEGIN
					SET @Hospital = SUBSTRING(@HospitalList, 0, PATINDEX('%|%',@HospitalList))
					IF  @Hospital IS NOT NULL AND NOT EXISTS(SELECT 1 FROM [ERS_ConsultantsHospital] WHERE [HospitalID] = @Hospital AND [ConsultantID] = @ConsultantID )
						BEGIN
						INSERT INTO [ERS_ConsultantsHospital] ([ConsultantID],[HospitalID],WhoCreatedId,WhenCreated) VALUES(@consultantid,@Hospital,@LoggedInUSerId,GETDATE())
						END
					SET @HospitalList = SUBSTRING(@HospitalList, LEN(@Hospital + '|') + 1, LEN(@HospitalList))
					END
				ELSE
					BEGIN
					SET @Hospital = @HospitalList
					SET @HospitalList = NULL
					IF  @Hospital IS NOT NULL AND NOT EXISTS(SELECT 1 FROM [ERS_ConsultantsHospital] WHERE [HospitalID] = @Hospital AND [ConsultantID] = @ConsultantID )
						BEGIN
						INSERT INTO [ERS_ConsultantsHospital] ([ConsultantID],[HospitalID],WhoCreatedId,WhenCreated) VALUES(@consultantid,@Hospital,@LoggedInUserId,GETDATE())
						END
					END
				END
			END
		END
		SELECT @ConsultantID
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

--------------------------------------------------------------------------------------------------------
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
			ISNULL(CONVERT(VARCHAR(11),pr.CreatedOn,106) + ' (' + CONVERT(VARCHAR(5),pr.CreatedOn,108) + ')','') AS ProcedureDate, 
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

--------------------------------------------------------------------------------------------------------

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'usp_Procedures_Insert','S';
GO

CREATE PROCEDURE [dbo].[usp_Procedures_Insert]
(
	@ProcedureType		INT,
	--@PatientNo		VARCHAR(24),
	@PatientId			INT,
	@ProcedureDate		DATETIME,
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
	@CategoryListId	INT,
	@OnWaitingList		BIT,
	@OpenAccessProc		TINYINT,
	@EmergencyProcType	TINYINT,
	@NewProcedureId		INT OUTPUT,	-- This will return the newly created ProcedureId to the GUI! To play
	@ImagePortId		INT
)
AS

SET NOCOUNT ON

DECLARE @newProcId INT
DECLARE @ppEndos VARCHAR(2000), @GPName varchar(255), @GPAddress varchar(max), @Endo1 varchar(500), @RefCons varchar(50)

BEGIN TRANSACTION
--sp_help 'dbo.ERS_Procedures'
	BEGIN TRY
		INSERT INTO ERS_Procedures
			(ProcedureType,
			CreatedBy,	
			CreatedOn,
			ModifiedOn,
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
			WhenCreated)
		VALUES (
			@ProcedureType,
			@UserID,
			@ProcedureDate, --CASE WHEN CONVERT(DATE, GETDATE()) = @ProcedureDate THEN GETDATE() ELSE @ProcedureDate END, --Insert date and time if Procedure date is current date
			GETDATE(),
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
			GETDATE())

		SET @newProcId = SCOPE_IDENTITY();
	
		--## Important Work- Insert a Blank Record in the ERS_ProceduresReorting- with this Unique ID! So, you can simply Update the PP fields later..!! 
		INSERT INTO dbo.ERS_ProceduresReporting(ProcedureId)VALUES(@newProcId);

		SET @ppEndos = ''
		IF @ListConsultant > 0 SELECT @ppEndos = @ppEndos + '$$' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @ListConsultant
		IF @Endoscopist1 > 0 
		BEGIN
			SELECT @Endo1 = Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Endoscopist1
			SELECT @ppEndos = @ppEndos + '$$' + @Endo1
		END
		IF @Endoscopist2 > 0 SELECT @ppEndos = @ppEndos + '$$' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Endoscopist2
		IF @Nurse1 > 0 OR @Nurse2 > 0 OR @Nurse3 > 0 
		BEGIN
			SELECT @ppEndos = @ppEndos + '$$' + 'Nurses: '
			IF @Nurse1 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse1
			IF @Nurse2 > 0 SELECT @ppEndos = @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse2
			IF @Nurse3 > 0 SELECT @ppEndos =  @ppEndos + '##' + Title + ' ' + Forename + ' ' + Surname FROM ERS_Users WHERE UserID = @Nurse3
		END
		IF CHARINDEX('$$', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('$$', @ppEndos), 2, ''), '$$', '<br/>')
		IF CHARINDEX('##', @ppEndos) > 0 SET @ppEndos = REPLACE(STUFF(@ppEndos, charindex('##', @ppEndos), 2, ''), '##', '<br/>')
	
		SET @RefCons=''
		SELECT @RefCons = ec.CompleteName FROM dbo.ERS_Consultant ec WHERE ec.ConsultantID = @ReferralConsultantNo
		--SELECT @GPName = p.[GP Name] , @GPAddress = p.[GP Address] FROM Patient p left join  ERS_Procedures pr ON p.[Patient No]= pr.PatientId WHERE pr.ProcedureId = @newProcId
		--SELECT @GPName = p.[GP Name] , @GPAddress = p.[GP Address] FROM ERS_Patients p WHERE p.[Patient No]= @PatientId

		--Get GP practice name and address
		SELECT 	TOP 1 
				@GPName		= p.[GPName],
				@GPAddress	= p.GPAddress
		FROM ERS_VW_PatientswithGP p 
		WHERE p.PatientId = @PatientId

		UPDATE ERS_ProceduresReporting SET PP_Endos = @ppEndos, PP_GPName = @GPName, PP_GPAddress = @GPAddress, PP_Endo1 = @Endo1, PP_RefCons = @RefCons WHERE ProcedureId = @newProcId

		UPDATE ERS_Consultant SET SortOrder = ISNULL(SortOrder,0) + 1 WHERE ConsultantID = @ReferralConsultantNo

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
--------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'usp_Ward_Insert','S';
GO

CREATE PROCEDURE dbo.usp_Ward_Insert
	@WardName as VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
        DECLARE @listItemNo INT, @listMainId INT;
        SELECT @listItemNo = MAX(ListItemNo) FROM ERS_Lists WHERE ListDescription = 'Ward';
        SELECT @listMainId = ListMainId FROM ERS_ListsMain WHERE ListDescription = 'Ward';

        INSERT INTO		
				ERS_Lists (ListDescription, ListItemNo,	ListMainId, ListItemText, Suppressed)
					VALUES ('Ward', @listItemNo + 1, @listMainId, @WardName, 0)
END
GO


--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
-------------------------------------216c Create Proc common_pagebyrole_select.sql----------------------------------
--------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC DropIfExist 'common_pagebyrole_select', 'S';
GO

CREATE Procedure [dbo].[common_pagebyrole_select]
(
	@RoleID int,
	@GroupID int
)
AS
IF @GroupID =1 
BEGIN
	SELECT p.*, ISNULL(AccessLevel,0) as AccessLevel, pg.GroupName 
	FROM ERS_Pages p 
		LEFT JOIN ERS_PagesByRole pr ON pr.PageId = p.PageId AND pr.RoleId = @RoleId  
		LEFT JOIN ERS_PageGroups pg ON pg.GroupId = p.GroupId
	WHERE p.GroupId IS NOT NULL AND p.GroupId NOT IN (5,6) -- excludes abnormality and other data pages
	ORDER BY pg.GroupName, p.PageName
END
ELSE
BEGIN
	SELECT p.*, ISNULL(AccessLevel,0) as AccessLevel, pg.GroupName
	FROM ERS_Pages p 
		LEFT JOIN ERS_PagesByRole pr ON pr.PageId = p.PageId AND pr.RoleId = @RoleId 
		LEFT JOIN ERS_PageGroups pg ON pg.GroupId = p.GroupId
	WHERE p.GroupID =@GroupID ORDER BY p.PageName
END

GO

--------------------------------------------------------------------------------------------------------

UPDATE ers_pages SET GroupId = 9 WHERE ers_pages.AppPageName IN (
	'products_options_scheduler_templates_aspx',
	'products_options_scheduler_edittemplates_aspx',
	'products_options_scheduler_diarypages_aspx',
	'products_options_scheduler_rooms_aspx',
	'products_options_scheduler_editrooms_aspx',
	'products_options_scheduler_bookingbreachstatus_aspx',
	'products_options_scheduler_endoscopistsrules_aspx',
	'products_options_scheduler_pointmappings_aspx',
	'products_scheduler_patientbooking_aspx',
	'products_options_scheduler_pointmappings_aspx',
	'products_options_scheduler_genderlist_aspx',
	'products_options_scheduler_therapeutictypes_aspx',
	'products_options_scheduler_freeslotdefaults_aspx')

UPDATE ers_pages SET GroupId = NULL WHERE ers_pages.AppPageName IN (
	'products_options_optionsmain_aspx',
	'products_pas_pasdownload_aspx',
	'products_sitedetailserror_aspx',
	'edit_procedure')

UPDATE ers_pages SET GroupId = 3 WHERE ers_pages.AppPageName IN (
	'products_options_editdiagnoses_aspx',
	'products_options_editdrugs_aspx',
	'products_options_editconsultants_aspx')

UPDATE ers_pages SET GroupId = 5 WHERE ers_pages.AppPageName IN (
	'products_patientprocedure_aspx')

UPDATE ers_pages SET PageAlias = 'Create/Edit Procedure' WHERE AppPageName = 'create_procedure'
UPDATE ERS_Pages SET PageAlias = 'Role Assignment' WHERE AppPageName = 'products_options_menuroleassignment_aspx'

GO

--------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('ERS_PageGroups') AND type = 'U')
BEGIN
	CREATE TABLE dbo.ERS_PageGroups (
		[PageGroupId] [int] IDENTITY(1,1) NOT NULL CONSTRAINT [PK_ERS_PageGroups] PRIMARY KEY CLUSTERED ([PageGroupId]),
		[GroupId] [int],
		[GroupName] [varchar](200)
	)

	INSERT INTO ERS_PageGroups ([GroupId], [GroupName])
	VALUES 
	 (2,'Settings')
	,(3,'Admin Utilities')
	,(4,'User Maintenance')
	,(5,'Other Data')
	,(6,'Abnormalities')
	,(8,'Homepage')
	,(9,'Scheduler')
END	
GO
--------------------------------------------------------------------------------------------------------

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name IN (N'WhoUpdatedId',N'WhoCreatedId',N'WhenCreated',N'WhenUpdated') AND Object_ID = (Object_ID(N'ERS_UserOperatingHospitals')))
BEGIN
ALTER TABLE ERS_UserOperatingHospitals ADD 		
	[WhoUpdatedId]				[int]		NULL Default 0,
	[WhoCreatedId]				[int]		NULL Default 0,
	[WhenCreated]				[DATETIME]	NULL Default GetDate(),
	[WhenUpdated]				[DATETIME]	NULL Default GetDate()
END
GO

IF NOT EXISTS(SELECT 1 FROM ERSAudit.tblTablesToBeAudited WHERE TableName = 'ERS_UserOperatingHospitals')
	INSERT INTO ERSAudit.tblTablesToBeAudited
	(
		TableSchema,
		TableName
	)
	VALUES
	(
		N'dbo', -- TableSchema - nvarchar
		N'ERS_UserOperatingHospitals' -- TableName - nvarchar
	)

--------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC DropIfExist 'therapeutics_ercp_summary_update', 'S';
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
				@GastrostomyInsertionBatchNo	= (CASE WHEN IsNull(ER.GastrostomyInsertionBatchNo, '') = '' THEN EE.GastrostomyInsertionBatchNo ELSE ER.GastrostomyInsertionBatchNo END),
				@NilByMouth			= (CASE WHEN IsNull(ER.NilByMouth, 0) = 0 THEN EE.NilByMouth ELSE ER.NilByMouth END),
				@NilByMouthHrs		= (CASE WHEN IsNull(ER.NilByMouthHrs, 0) = 0 THEN EE.NilByMouthHrs ELSE ER.NilByMouthHrs END),
				@NilByProc			= (CASE WHEN IsNull(ER.NilByProc, 0) = 0 THEN EE.NilByProc ELSE ER.NilByProc END),
				@NilByProcHrs		= (CASE WHEN IsNull(ER.NilByProcHrs, 0) = 0 THEN EE.NilByProcHrs ELSE ER.NilByProcHrs END),
				@AttachmentToWard	= (CASE WHEN IsNull(ER.AttachmentToWard, 0) = 0 THEN EE.AttachmentToWard ELSE ER.AttachmentToWard END),
				@PyloricDilatation	= (CASE WHEN IsNull(ER.PyloricDilatation, 0) = 0 THEN EE.PyloricDilatation ELSE ER.PyloricDilatation END),
				@StentInsertion		= (CASE WHEN IsNull(ER.StentInsertion, 0) = 0 THEN EE.StentInsertion ELSE ER.StentInsertion END),
				@StentInsertionQty	= (CASE WHEN IsNull(ER.StentInsertionQty, 0) = 0 THEN EE.StentInsertionQty ELSE ER.StentInsertionQty END),
				@RadioactiveWirePlaced			= (CASE WHEN IsNull(ER.RadioactiveWirePlaced, 0) = 0 THEN EE.RadioactiveWirePlaced ELSE ER.RadioactiveWirePlaced END),
				@StentInsertionBatchNo			= (CASE WHEN IsNull(ER.StentInsertionBatchNo,'')= '' THEN EE.StentInsertionBatchNo ELSE ER.StentInsertionBatchNo END),
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
				@OtherReasonText	= (CASE WHEN IsNull(ER.OtherReasonText, '') = '' THEN EE.OtherReasonText ELSE ER.OtherReasonText END),
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

GO
--------------------------------------------------------------------------------------------------------

IF object_id('UK_ERS_Consultants_GMCCode') IS NOT NULL
	ALTER TABLE ERS_Consultant ADD CONSTRAINT [UK_ERS_Consultants_GMCCode] UNIQUE ([GMCCode])
GO

--------------------------------------------------------------------------------------------------------
IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'ERS_Consultant'))
	ALTER TABLE ers_consultant ALTER COLUMN GroupId varchar(5)

IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ERSAudit' AND TABLE_NAME = 'ERS_Consultant_Audit'))
	ALTER TABLE ERSAudit.ERS_Consultant_Audit ALTER COLUMN GroupId varchar(5)
--------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM ERS_Pages WHERE PageId = 125)
	INSERT [dbo].[ERS_Pages] ([PageId], [PageName], [AppPageName], [GroupId], [PageAlias],[PageURL]) VALUES 
	(125,'Admin Utilities -> NEDExport','products_options_nedexportconfig_aspx',3,'NED Export','~/products/options/nedexportconfig.aspx')

	IF NOT EXISTS(SELECT 1 FROM ERS_PagesByRole WHERE PageId = 125)
BEGIN
	INSERT INTO ERS_PagesByRole ([RoleId], [PageId], [AccessLevel])
	SELECT  (SELECT TOP 1 RoleID FROM ERS_Roles WHERE RoleName = 'Unisoft')
			,125
			, 9

	--Populate table ERS_PagesByRole for 'System Administrators'
	INSERT INTO ERS_PagesByRole ([RoleId], [PageId], [AccessLevel])
	SELECT  (SELECT TOP 1 RoleID FROM ERS_Roles WHERE RoleName = 'System Administrators')
			,125
			, 9
END	
GO
--------------------------------------------------------------------------------------------------------

ALTER TABLE ERS_SCH_ListSlots ALTER COLUMN ProcedureTypeId int
--------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'HasAbnormalities' AND Object_ID = Object_ID(N'ERS_Sites'))
	ALTER TABLE dbo.ERS_Sites ADD HasAbnormalities INT

IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ERSAudit' AND TABLE_NAME = 'ERS_Sites_Audit'))
	IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'HasAbnormalities' AND Object_ID = Object_ID(N'ERSAudit.ERS_Sites_Audit'))
		ALTER TABLE ERSAudit.ERS_Sites_Audit ADD HasAbnormalities INT
GO
--------------------------------------------------------------------------------------------------------


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

		--Perform abno check to determine normal procedure
		IF @none = 0  and @TableName <> 'ERS_UpperGISpecimens' AND @AbormalProcedure <> 1  SET @AbormalProcedure = 1

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
		SiteSummaryTherapeuticsWithLinks = @summaryTherapeuticsWithHyperLinks,
		HasAbnormalities = @AbormalProcedure
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

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
-- Field ColonFIT added to table ERS_UpperGIIndications-------------------------------------
--------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ColonFIT' AND Object_ID = Object_ID(N'ERS_UpperGIIndications'))
		ALTER TABLE ERS_UpperGIIndications ADD ColonFIT [bit]		NOT NULL CONSTRAINT DF_ERS_UpperGIIndications_ColonFIT  DEFAULT 0;
GO

IF (EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ERSAudit' AND TABLE_NAME = 'ERS_UpperGIIndications_Audit'))
	IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ColonFIT' AND Object_ID = Object_ID(N'ERSAudit.ERS_UpperGIIndications_Audit'))
		ALTER TABLE ERSAudit.ERS_UpperGIIndications_Audit ADD ColonFIT [bit]
GO
--------------------------------------------------------------------------------------------------------------------
-- Field ColonFIT added to table ERS_UpperGIIndications-------------------------------------
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
			ColonAlterBowelHabit,
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
			@ColonAlterBowelHabit,
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
			ColonAlterBowelHabit = @ColonAlterBowelHabit,
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
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = GETDATE()
		WHERE 
			ProcedureId = @ProcedureId;

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
---Field ColonFIT added to table ERS_UpperGIIndications ------------------------------------
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
		[ColonAlterBowelHabit],
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
		EMR
	FROM
		ERS_UpperGIIndications
	WHERE 
		ProcedureId = @ProcedureId;

GO
--------------------------------------------------------------------------------------------------------------------
---Include PracticeName for GP Address ------------------------------------
--------------------------------------------------------------------------------------------------------------------

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'patient_select','S';
GO

CREATE PROCEDURE [dbo].[patient_select]
(
	@PatientId int
)
AS

SET NOCOUNT ON

DECLARE @GPid INT 

BEGIN TRANSACTION

BEGIN TRY

	SELECT [Title], [Forename1] AS Forename, [Surname], [Address], [Postcode], CASE WHEN ISNULL(GPName,'') = '' THEN 'Not Stated' ELSE GPName END AS GPName, PracticeName,
			ISNULL(GPAddress,'') AS GPAddress, NHSNo, Gender, DateOfBirth, HospitalNumber as CaseNoteNo, dbo.fnEthnicity(EthnicId) AS Ethnicity,
			[DateAdded] AS CreatedOn, DateUpdated AS ModifiedOn, Deceased
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

--------------------------------------------------------------------------------------------------------------------
---Include PracticeName for GP Address ------------------------------------
--------------------------------------------------------------------------------------------------------------------
EXEC dbo.DropIfExist 'ERS_VW_PatientswithGP', 'V';
GO     

DECLARE @sql nvarchar(max), @IncludeUGI bit = 0


IF @IncludeUGI = 1
BEGIN
SET @sql='
	CREATE VIEW ERS_VW_PatientswithGP
	AS
	SELECT DISTINCT 
		ROW_NUMBER() OVER (ORDER BY ugip.[Patient No]) AS PatientRowId,
		CASE WHEN p.PatientId IS NULL THEN ugip.[Patient No] ELSE p.PatientId END AS PatientId, 
		ugip.[Patient No] AS UGIPatientId,
		ugip.[Combo ID] AS ComboId,
		CASE WHEN p.PatientId IS NULL THEN 0 ELSE 1 END AS ERSPatient, 
		CASE WHEN p.PatientId IS NOT NULL THEN p.Title ELSE ugip.Title END AS Title, 
		CASE WHEN p.PatientId IS NOT NULL THEN p.Forename1 ELSE ugip.Forename END AS Forename1, 
		CASE WHEN p.PatientId IS NOT NULL THEN p.Surname ELSE ugip.Surname END AS Surname, 
		CASE WHEN p.PatientId IS NOT NULL THEN dbo.fnGender(p.GenderId) ELSE dbo.fnGenderFromCode(ugip.Gender) END AS Gender, 
		CASE WHEN p.PatientId IS NOT NULL THEN p.Forename1 + '' '' + p.Surname ELSE ugip.Forename + '' '' + ugip.Surname END AS PatientName, 
		CASE WHEN p.PatientId IS NOT NULL THEN dbo.fnFullAddress(p.Address1, p.Address2, p.Address3, p.Address4, '' '') ELSE ugip.Address END as Address, 
		CASE WHEN p.PatientId IS NOT NULL THEN p.Postcode ELSE ugip.[Post code] END AS Postcode,
		CASE WHEN p.PatientId IS NOT NULL THEN p.Telephone ELSE ugip.[Phone No] END AS Telephone,
		CASE WHEN p.PatientId IS NOT NULL THEN p.DateOfBirth ELSE ugip.[Date of birth] END AS DateOfBirth, 
		CASE WHEN p.PatientId IS NOT NULL THEN p.HospitalNumber ELSE ugip.[Case note no] END AS HospitalNumber, 
		CASE WHEN p.PatientId IS NOT NULL THEN p.NHSNo ELSE ugip.[NHS No] END AS NHSNo, 
		CASE WHEN p.PatientId IS NOT NULL THEN p.DateAdded ELSE ugip.[Record created] END AS DateAdded,
		CASE WHEN p.PatientId IS NOT NULL THEN p.DateUpdated ELSE ugip.[Last Modified] END AS DateUpdated,
		CASE WHEN p.PatientId IS NOT NULL THEN p.EthnicId ELSE ugip.[Ethnic origin] END AS EthnicId,
		CASE WHEN p.PatientId IS NOT NULL THEN g.CompleteName ELSE ugip.[GP Name] END AS GPName,
		CASE WHEN p.PatientId IS NOT NULL THEN ep.name ELSE '''' END AS PracticeName,
		CASE WHEN p.PatientId IS NOT NULL THEN dbo.fnFullAddress(ep.Address1, ep.Address2, ep.Address3, ep.Address4, ep.PostCode) ELSE ugip.[GP Address] END AS GPAddress,
		CASE WHEN p.PatientId IS NOT NULL THEN ep.TelNo ELSE '''' END AS GPTelNo,
		CASE WHEN p.PatientId IS NOT NULL THEN p.DateOfDeath ELSE ugip.[Date of death] END AS DateOfDeath,
		CASE WHEN p.PatientId IS NOT NULL THEN ISNULL(p.Deceased,0) ELSE Deceased END AS Deceased
	FROM  ERS_Patients p
		LEFT JOIN Patient ugip ON ugip.Patient_ID = p.PatientId
		LEFT JOIN ERS_GPs g ON g.GPId = p.RegGpId
		LEFT JOIN dbo.ERS_Practices ep ON p.RegGpPracticeId = ep.PracticeID
	UNION ALL
	SELECT  
		ROW_NUMBER() OVER (ORDER BY ugip.[Patient No]) AS PatientRowId,
		ugip.[Patient No] AS PatientId,
		ugip.[Patient No] AS UGIPatientId,
		ugip.[Combo ID] AS ComboId,
		0  AS ERSPatient, 
		ugip.Title  AS Title, 
		ugip.Forename  AS Forename1, 
		ugip.Surname  AS Surname, 
		dbo.fnGenderFromCode(ugip.Gender)  AS Gender, 
		ugip.Forename + '' '' + ugip.Surname  AS PatientName, 
		ugip.Address  as Address, 
		ugip.[Post code]  AS Postcode,
		ugip.[Phone No]  AS Telephone,
		ugip.[Date of birth]  AS DateOfBirth, 
		ugip.[Case note no]  AS HospitalNumber, 
		ugip.[NHS No]  AS NHSNo, 
		ugip.[Record created]  AS DateAdded,
		ugip.[Last Modified]  AS DateUpdated,
		ugip.[Ethnic origin]  AS EthnicId,
		ugip.[GP Name]  AS GPName,
		'''' AS PracticeName,
		ugip.[GP Address]  AS GPAddress,
		''''  AS GPTelNo,
		ugip.[Date of death]  AS DateOfDeath,
		ugip.Deceased
	FROM  Patient ugip
	WHERE ugip.Patient_id IS NULL'
END
ELSE
BEGIN
SET @sql = '
	CREATE VIEW ERS_VW_PatientswithGP
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
		p.Forename1 + '' '' + p.Surname AS PatientName, 
		dbo.fnFullAddress(p.Address1, p.Address2, p.Address3, p.Address4, '''') AS Address, 
		p.PostCode,
		p.Telephone,
		p.DateOfBirth AS DateOfBirth, 
		p.HospitalNumber AS HospitalNumber, 
		p.NHSNo AS NHSNo, 
		p.DateAdded AS DateAdded,
		p.DateUpdated AS DateUpdated,
		p.EthnicId AS EthnicId,
		g.CompleteName AS GPName,
		ep.name AS PracticeName,
		dbo.fnFullAddress(ep.Address1, ep.Address2, ep.Address3, ep.Address4, ep.PostCode) AS GPAddress,
		ep.TelNo AS GPTelNo,
		p.DateOfDeath AS DateOfDeath,
		ISNULL(p.Deceased, 0) AS Deceased
	FROM ERS_Patients p 
		LEFT JOIN ERS_GPs g ON g.GPId = p.RegGpId
		LEFT JOIN dbo.ERS_Practices ep ON p.RegGpPracticeId = ep.PracticeID'
END
	
EXEC sp_executesql @sql
GO


--------------------------------------------------------------------------------------------------------------------
-- Add more fields to ERS_Procedures for double procedure, when replicating-------------------------------------
--------------------------------------------------------------------------------------------------------------------
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


----------------------------------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'otherdata_ogd_diagnoses_save','S';
GO

CREATE PROCEDURE [dbo].[otherdata_ogd_diagnoses_save]
(
	@ProcedureID INT,
	@OverallNormal BIT,
    --@OesophagusNormal BIT,
    @OesophagusNotEntered BIT,
    @OesoList VARCHAR(1500),
    @StomachNotEntered BIT,
    --@StomachNormal BIT,
    @stomachList VARCHAR(1500),
    @DuodenumNotEntered BIT,
    @Duodenum2ndPartNotEntered BIT,
    --@DuodenumNormal BIT,
    @DuoList VARCHAR(1500)
    --@OesophagusOtherDiagnosis VARCHAR(MAX),
    --@StomachOtherDiagnosis VARCHAR(MAX),
    --@DuodenumOtherDiagnosis VARCHAR(MAX)
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
		--UNION
		--SELECT @ProcedureId, 'OesophagusNormal', CONVERT(VARCHAR(MAX),@OesophagusNormal), 'Oesophagus', 1 WHERE @OesophagusNormal = 1 
		--UNION
		--SELECT @ProcedureId, 'OesophagusOtherDiagnosis', CONVERT(VARCHAR(MAX),@OesophagusOtherDiagnosis), 'Oesophagus', 1 WHERE ISNULL(@OesophagusOtherDiagnosis,'') <> '' 
		UNION
		SELECT @ProcedureId, 'StomachNotEntered', CONVERT(VARCHAR(MAX),@StomachNotEntered), 'Stomach', 1 WHERE @StomachNotEntered = 1 
		--UNION
		--SELECT @ProcedureId, 'StomachNormal', CONVERT(VARCHAR(MAX),@StomachNormal), 'Stomach', 1 WHERE @StomachNormal = 1 
		--UNION
		--SELECT @ProcedureId, 'StomachOtherDiagnosis', CONVERT(VARCHAR(MAX),@StomachOtherDiagnosis), 'Stomach', 1 WHERE ISNULL(@StomachOtherDiagnosis,'') <> '' 
		UNION
		SELECT @ProcedureId, 'DuodenumNotEntered', CONVERT(VARCHAR(MAX),@DuodenumNotEntered), 'Duodenum', 1 WHERE @DuodenumNotEntered = 1 
		--UNION
		--SELECT @ProcedureId, 'DuodenumNormal', CONVERT(VARCHAR(MAX),@DuodenumNormal), 'Duodenum', 1 WHERE @DuodenumNormal = 1 
		--UNION
		--SELECT @ProcedureId, 'DuodenumOtherDiagnosis', CONVERT(VARCHAR(MAX),@DuodenumOtherDiagnosis), 'Duodenum', 1 WHERE ISNULL(@DuodenumOtherDiagnosis,'') <> '' 
		UNION
		SELECT @ProcedureId, 'Duodenum2ndPartNotEntered', CONVERT(VARCHAR(MAX),@Duodenum2ndPartNotEntered), 'Duodenum', 1 
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

----------------------------------------------------------------------------------------------------------------

EXEC DropIfExist 'otherdata_colon_diagnoses_save','S';
GO

CREATE PROCEDURE [dbo].[otherdata_colon_diagnoses_save]
(
	@ProcedureID INT,
	@ColonNormal BIT,
	@ColonRestNormal BIT,
	--@Colitis BIT,
	--@Ileitis BIT,
	--@Proctitis BIT,
	@ColitisType VARCHAR(15),
	--@ColitisExtent VARCHAR(15),
	@ColonList VARCHAR(1500),
	--@ColonOtherDiagnosis VARCHAR(MAX),
	--@MayoScore VARCHAR(15),
	--@SEScore VARCHAR(15),
	@LoggedInUserId INT
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	DELETE
	FROM [ERS_Diagnoses]
	WHERE ProcedureID = @ProcedureID AND IsOtherData = 1

	INSERT INTO [ERS_Diagnoses] (ProcedureID, MatrixCode, Value, Region, IsOtherData, WhoCreatedId, WhenCreated)
	SELECT @ProcedureId, [item], CONVERT(VARCHAR(MAX),'True'), 'Colon', 1, @LoggedInUserId, GETDATE() FROM dbo.fnSplitString(@ColonList,',')
	UNION
	SELECT @ProcedureId, 'ColonNormal', CONVERT(VARCHAR(MAX),@ColonNormal), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColonNormal = 1 
	UNION
	SELECT @ProcedureId, 'ColonRestNormal', CONVERT(VARCHAR(MAX),@ColonRestNormal), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColonRestNormal = 1 
	UNION
	--SELECT @ProcedureId, 'Colitis', CONVERT(VARCHAR(MAX),@Colitis), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @Colitis = 1 
	--UNION
	--SELECT @ProcedureId, 'Ileitis', CONVERT(VARCHAR(MAX),@Ileitis), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @Ileitis = 1 
	--UNION
	--SELECT @ProcedureId, 'Proctitis', CONVERT(VARCHAR(MAX),@Proctitis), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @Proctitis = 1 
	--UNION
	SELECT @ProcedureId, 'ColitisType', CONVERT(VARCHAR(MAX),@ColitisType), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColitisType <> '' 
	--UNION
	--SELECT @ProcedureId, 'ColitisExtent', CONVERT(VARCHAR(MAX),@ColitisExtent), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColitisExtent <> '' AND @ColitisExtent <> '0'
	--UNION
	--SELECT @ProcedureId, 'ColonOtherDiagnosis', CONVERT(VARCHAR(MAX),@ColonOtherDiagnosis), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColonOtherDiagnosis <> '' 
	--UNION
	--SELECT @ProcedureId, 'MayoScore', CONVERT(VARCHAR(MAX),@MayoScore), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @MayoScore <> ''  AND @MayoScore <> '0'
	--UNION
	--SELECT @ProcedureId, 'SEScore', CONVERT(VARCHAR(MAX),@SEScore), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @SEScore <> '' AND @SEScore <> '0'

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

---------------------------------------------------------------------------------------------------------------------------------------------


EXEC DropIfExist 'infer_mucosa_diagnoses','S';
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

	select * from ers_sites
	
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


	INSERT INTO [ERS_Diagnoses] (ProcedureID, MatrixCode, Value, Region, IsOtherData, WhoCreatedId, WhenCreated)
	--SELECT @ProcedureId, [item], CONVERT(VARCHAR(MAX),'True'), 'Colon', 1, @LoggedInUserId, GETDATE() FROM dbo.fnSplitString(@ColonList,',')
	--UNION
	SELECT @ProcedureId, 'ColonNormal', CONVERT(VARCHAR(MAX),@ColonNormal), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColonNormal = 1 
	UNION
	SELECT @ProcedureId, 'ColonRestNormal', CONVERT(VARCHAR(MAX),@ColonRestNormal), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColonRestNormal = 1 
	UNION
	SELECT @ProcedureId, 'Colitis', CONVERT(VARCHAR(MAX),@Colitis), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @Colitis = 1 
	UNION
	SELECT @ProcedureId, 'Ileitis', CONVERT(VARCHAR(MAX),@Ileitis), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @Ileitis = 1 
	UNION
	SELECT @ProcedureId, 'Proctitis', CONVERT(VARCHAR(MAX),@Proctitis), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @Proctitis = 1 
	UNION
	SELECT @ProcedureId, 'ColitisType', CONVERT(VARCHAR(MAX),@ColitisType), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColitisType <> '' 
	UNION
	SELECT @ProcedureId, 'ColitisExtent', CONVERT(VARCHAR(MAX),@ColitisExtent), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColitisExtent <> '' AND @ColitisExtent <> '0'
	UNION
	--SELECT @ProcedureId, 'ColonOtherDiagnosis', CONVERT(VARCHAR(MAX),@ColonOtherDiagnosis), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @ColonOtherDiagnosis <> '' 
	--UNION
	SELECT @ProcedureId, 'MayoScore', CONVERT(VARCHAR(MAX),@MayoScore), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @MayoScore <> ''  AND @MayoScore <> '0'
	UNION
	SELECT @ProcedureId, 'SEScore', CONVERT(VARCHAR(MAX),@SEScore), 'Colon', 1, @LoggedInUserId, GETDATE() WHERE @SEScore <> '' AND @SEScore <> '0'

	--EXEC ogd_diagnoses_summary_update @ProcedureId;

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

-----------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'TR_ColonAbnoMucosa_Insert', 'TR';
GO

CREATE TRIGGER TR_ColonAbnoMucosa_Insert
ON ERS_ColonAbnoMucosa
AFTER INSERT, UPDATE 
AS 
	DECLARE @site_id INT, @RedundantRectal VARCHAR(10), @HasUlcer VARCHAR(10), @UserID as int
	SELECT @site_id=SiteId, 
		@RedundantRectal = (CASE WHEN (RedundantRectal=1) THEN 'True' ELSE 'False' END),
		@HasUlcer = (CASE WHEN (SmallUlcers=1 OR LargeUlcers=1 OR PleomorphicUlcers=1 OR SerpiginousUlcers=1 
								OR AphthousUlcers=1 OR ConfluentUlceration=1 OR DeepUlceration=1 OR SolitaryUlcer=1)
								THEN 'True' ELSE 'False' END),
		@UserID = (CASE WHEN ISNULL(WhoUpdatedId,0) = 0 THEN WhoCreatedId ELSE WhoUpdatedId END)
	FROM INSERTED

	EXEC abnormalities_mucosa_summary_update @site_id
	EXEC sites_summary_update @site_id

	EXEC infer_mucosa_diagnoses @site_id, @UserID

	EXEC diagnoses_control_save @site_id, 'D15P3', @RedundantRectal		-- 'Redundant anterior rectal mucosa'
	EXEC diagnoses_control_save @site_id, 'D80P3', @HasUlcer			-- 'Rectal ulcer(s)', D83P3 for 'Colonic ulcer(s)'
GO

-----------------------------------------------------------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


-----ALL SCRIPT SHOULD GO ABOVE THIS LINE -------------------
DROP TABLE #variables
GO