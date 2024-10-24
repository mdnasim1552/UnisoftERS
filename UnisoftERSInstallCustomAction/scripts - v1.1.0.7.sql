ALTER TABLE ERS_UpperGITherapeutics ALTER COLUMN [CorrectStentPlacement] tinyint NULL
GO
----------------------------------------------------------------------------------------------------------
UPDATE ERS_UpperGITherapeutics SET CorrectStentPlacement = NULL WHERE StentPlacementFailureReason IS NULL

----------------------------------------------------------------------------------------------------------
ALTER TABLE [dbo].[ERS_SCH_ListSlots] ALTER COLUMN ProcedureTypeId INT NULL
GO

----------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_ListsMain WHERE ListDescription = 'Stent Placement Failure Reasons')
BEGIN
	DECLARE @ListMainId INT
	INSERT INTO ERS_ListsMain (ListDescription, AllowAddNewItem, OrderByDesc, FirstItemText)
	VALUES ('Stent Placement Failure Reasons', 0, 0, '')

	SET @ListMainId = Scope_Identity()

	INSERT INTO ERS_Lists (ListDescription, ListItemNo,ListItemText, Suppressed, ReadOnly, ListMainId)
	VALUES ('Stent Placement Failure Reasons', 1, 'Too proximal',0,0,@ListMainId),
	('Stent Placement Failure Reasons', 2, 'Too distal',0,0,@ListMainId),
	('Stent Placement Failure Reasons', 3, 'Failed deployment',0,0,@ListMainId)
END
GO
----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'ERS_VW_Patient_Procedures', 'V'
GO

CREATE VIEW [dbo].[ERS_VW_Patient_Procedures]
AS
SELECT 
	pat.HospitalNumber, 
	pat.Forename1, 
	pat.Forename2, 
	pat.Surname, 
	pat.DateOfBirth,
	ept.ProcedureType AS [Procedure],
	pr.* 
FROM dbo.ERS_Procedures pr
	INNER JOIN dbo.ERS_ProcedureTypes ept ON pr.ProcedureType = ept.ProcedureTypeId
	INNER JOIN dbo.ERS_Patients pat on pat.PatientId = pr.PatientId
GO
----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'fnGetAge', 'F'
GO

CREATE FUNCTION dbo.fnGetAge
(
	@DOB datetime
)
RETURNS INT
AS
BEGIN
	DECLARE @Age INT

	SET @Age = YEAR(GETDATE()) - YEAR(@DOB)
	IF @DOB > DATEADD(YEAR, -@Age, GETDATE())
		SET @Age = @Age - 1
	
	RETURN @Age
END

GO
----------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'fnJAGGRSB_Poly_Report_Summary', 'F'
GO

CREATE FUNCTION dbo.fnJAGGRSB_Poly_Report_Summary
(
	@SiteId INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE  
		@Sessile BIT,
		@SessileQuantity INT,
		@SessileLargest INT,
		@SessileExcised INT,
		@SessileRetrieved INT,
		@SessileToLabs INT,
		@SessileRemoval TINYINT,
		@SessileRemovalMethod TINYINT,
		@SessileProbably BIT,
		@SessileType TINYINT,
		@SessileParisClass TINYINT,
		@SessilePitPattern TINYINT,
		@Pedunculated BIT,
		@PedunculatedQuantity INT,
		@PedunculatedLargest INT,
		@PedunculatedExcised INT,
		@PedunculatedRetrieved INT,
		@PedunculatedToLabs INT,
		@PedunculatedRemoval TINYINT,
		@PedunculatedRemovalMethod TINYINT,
		@PedunculatedProbably BIT,
		@PedunculatedType TINYINT,
		@PedunculatedParisClass TINYINT,
		@PedunculatedPitPattern TINYINT,
		@Pseudopolyps BIT,
		@PseudopolypsMultiple BIT,
		@PseudopolypsQuantity INT,
		@PseudopolypsLargest INT,
		@PseudopolypsExcised INT,
		@PseudopolypsRetrieved INT,
		@PseudopolypsToLabs INT,
		@PseudopolypsInflam BIT,
		@PseudopolypsPostInflam BIT,
		@PseudopolypsRemoval TINYINT,
		@PseudopolypsRemovalMethod TINYINT,
		@summary VARCHAR(MAX),
		@SiteDesc VARCHAR(MAX)

	SELECT 
		@Sessile=Sessile,
		@SessileQuantity=SessileQuantity,
		@SessileLargest=SessileLargest,
		@SessileExcised=SessileExcised,
		@SessileRetrieved=SessileRetrieved,
		@SessileToLabs=SessileToLabs, 
		@Pedunculated = Pedunculated, 
		@PedunculatedQuantity=PedunculatedQuantity,
		@PedunculatedLargest=PedunculatedLargest,
		@PedunculatedExcised=PedunculatedExcised,
		@Pseudopolyps = Pseudopolyps,
		@PseudopolypsMultiple=PseudopolypsMultiple,
		@PseudopolypsQuantity=PseudopolypsQuantity,
		@PseudopolypsExcised=PseudopolypsExcised,
		@PseudopolypsRetrieved=PseudopolypsRetrieved,
		@PseudopolypsToLabs=PseudopolypsToLabs
	FROM ERS_ColonAbnoLesions 
	WHERE Siteid= @SiteId

	SELECT @SiteDesc = CASE WHEN AreaNo = 0 THEN er.Region ELSE dbo.fnSetAreaDescription(es.ProcedureId, es.AreaNo, 0) END 
	FROM ERS_Sites es
		INNER JOIN dbo.ERS_Regions er ON es.RegionId = er.RegionId
	WHERE SiteId = @SiteId

	IF @Sessile = 1
	BEGIN
		SET @summary = CONVERT(VARCHAR(10), @SessileQuantity) + ' in ' + dbo.fnFirstLetterLower(@SiteDesc)
	
		IF @SessileExcised > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @SessileExcised <> @SessileQuantity SET @summary = @summary + CONVERT(VARCHAR(20), @SessileExcised) + ' '
			SET @summary = @summary + 'excised'
		END

		IF @SessileRetrieved > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @SessileRetrieved <> @SessileExcised SET @summary = @summary + CONVERT(VARCHAR(20), @SessileRetrieved) + ' '
			SET @summary = @summary + 'retrieved'
		END

		IF @SessileToLabs > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @SessileToLabs <> @SessileRetrieved SET @summary = @summary + CONVERT(VARCHAR(20), @SessileToLabs) + ' '
			SET @summary = @summary + 'sent to labs'
		END

		-- Set the last occurence of $$ to "and"
		IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 3, ' and ')
		-- Replace all other occurences of $$ with commas
		SET @summary = REPLACE(@summary, '$$', ',')
	END
	ELSE IF @Pedunculated = 1
	BEGIN
		SET @summary = CONVERT(VARCHAR(10), @PedunculatedQuantity) + ' in ' + dbo.fnFirstLetterLower(@SiteDesc)
	
		IF @PedunculatedExcised > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @PedunculatedExcised <> @PedunculatedQuantity SET @summary = @summary + CONVERT(VARCHAR(20), @PedunculatedExcised) + ' '
			SET @summary = @summary + 'excised'
		END

		IF @PedunculatedRetrieved > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @PedunculatedRetrieved <> @PedunculatedExcised SET @summary = @summary + CONVERT(VARCHAR(20), @PedunculatedRetrieved) + ' '
			SET @summary = @summary + 'retrieved'
		END

		IF @PedunculatedToLabs > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @PedunculatedToLabs <> @PedunculatedRetrieved SET @summary = @summary + CONVERT(VARCHAR(20), @PedunculatedToLabs) + ' '
			SET @summary = @summary + 'sent to labs'
		END

		-- Set the last occurence of $$ to "and"
		IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 3, ' and ')
		-- Replace all other occurences of $$ with commas
		SET @summary = REPLACE(@summary, '$$', ',')
	END
	ELSE IF @Pseudopolyps = 1
	BEGIN
		SET @summary = CONVERT(VARCHAR(10), @PseudopolypsQuantity) + ' in ' + dbo.fnFirstLetterLower(@SiteDesc)
	
		IF @PseudopolypsExcised > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @PseudopolypsExcised <> @PseudopolypsQuantity SET @summary = @summary + CONVERT(VARCHAR(20), @PseudopolypsExcised) + ' '
			SET @summary = @summary + 'excised'
		END

		IF @PseudopolypsRetrieved > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @PseudopolypsRetrieved <> @PseudopolypsExcised SET @summary = @summary + CONVERT(VARCHAR(20), @PseudopolypsRetrieved) + ' '
			SET @summary = @summary + 'retrieved'
		END

		IF @PseudopolypsToLabs > 0 
		BEGIN
			SET @summary = @summary + '$$ '
			IF @PseudopolypsToLabs <> @PseudopolypsRetrieved SET @summary = @summary + CONVERT(VARCHAR(20), @PseudopolypsToLabs) + ' '
			SET @summary = @summary + 'sent to labs'
		END

		-- Set the last occurence of $$ to "and"
		IF CHARINDEX('$$', @summary) > 0 SET @summary = STUFF(@summary, len(@summary) - charindex('$$', reverse(@summary)), 3, ' and ')
		-- Replace all other occurences of $$ with commas
		SET @summary = REPLACE(@summary, '$$', ',')
	END

	RETURN @Summary
END

GO
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
