
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
			WHEN E.ProcedureType IN (1) THEN
				CASE WHEN E.Endoscopist2 IS NULL THEN UEX.NedTerm
					 WHEN E.Endo1Role <> 1 AND NOT EXISTS (SELECT 1 FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.JManoeuvreId IS NOT NULL AND epue.ProcedureId = @ProcedureId) /*Trainee has an entry*/
										 THEN (SELECT UEX.NedTerm FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId) /*TrainEE did it so TrainER gets it too*/
					/*WHEN Endo1Role = 1 THEN*/ ELSE (SELECT UEX.NedTerm FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.ProcedureId = @ProcedureId) /*Endo is independant or TrainER did it alone */
				END
			WHEN E.ProcedureType IN (3,4) THEN
				CASE WHEN E.Endoscopist2 IS NULL THEN LEX.NEDTerm
					 WHEN E.Endo1Role <> 1 AND NOT EXISTS (SELECT 1 FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.RetroflectionPerformed IS NOT NULL AND epue.ProcedureId = @ProcedureId) 
										 THEN (SELECT LEX.NEDTerm FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId) /*TrainEE did it so TrainER gets it too*/
					/*WHEN E.Endo1Role = 1 THEN*/ ELSE (SELECT LEX.NEDTerm FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.ProcedureId = @ProcedureId) /*Endo is independant or TrainER did it alone */

				END
	 END) AS Extent
	,(SELECT
		CASE 
			WHEN E.ProcedureType IN (1) THEN
				CASE WHEN E.Endoscopist2 IS NULL THEN PUE.JManoeuvreId
					 WHEN E.Endo1Role <> 1 AND NOT EXISTS (SELECT 1 FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.JManoeuvreId IS NOT NULL AND epue.ProcedureId = @ProcedureId) /*Trainee has an entry*/
										 THEN (SELECT CONVERT(BIT, epue.JManoeuvreId) FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId) /*TrainEE did it so TrainER gets it too*/
					/*WHEN Endo1Role = 1 THEN*/ ELSE (SELECT CONVERT(BIT, epue.JManoeuvreId) FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist1 AND epue.ProcedureId = @ProcedureId) /*Endo is independant or TrainER did it alone */
				END
			WHEN E.ProcedureType IN (3,4) THEN
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
			WHEN E.ProcedureType IN (1) THEN
				CASE WHEN E.Endo2Role = 1 THEN (SELECT UEX.NEDTerm FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId)
					 WHEN E.Endo2Role <> 1 AND EXISTS (SELECT 1 FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.JManoeuvreId IS NOT NULL AND epue.ProcedureId = @ProcedureId) 
												THEN (SELECT UEX.NEDTerm FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId)  /*TrainEEs outcome*/
				END
			WHEN E.ProcedureType IN (3,4) THEN 
				CASE WHEN E.Endo2Role = 1 THEN  (SELECT LEX.NEDTerm FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId)
					 WHEN E.Endo2Role <> 1 AND EXISTS (SELECT 1 FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.RetroflectionPerformed IS NOT NULL AND epue.ProcedureId = @ProcedureId) 
											THEN (SELECT LEX.NEDTerm FROM dbo.ERS_ProcedureLowerExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId) /*TrainEEs outcome*/
				END
		END) AS Extent
	, (SELECT 
		CASE 
			WHEN E.ProcedureType IN (1) THEN
				CASE WHEN E.Endo2Role = 1 THEN (SELECT epue.JManoeuvreId FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId)
					 WHEN E.Endo2Role <> 1 AND EXISTS (SELECT 1 FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.JManoeuvreId IS NOT NULL AND epue.ProcedureId = @ProcedureId) 
												THEN (SELECT CONVERT(BIT, epue.JManoeuvreId) FROM dbo.ERS_ProcedureUpperExtent epue WHERE epue.EndoscopistId = E.Endoscopist2 AND epue.ProcedureId = @ProcedureId)  /*TrainEEs outcome*/
				END
			WHEN E.ProcedureType IN (3,4) THEN 
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

ALTER PROCEDURE [dbo].[check_requiredfields]
(
	@ProcedureId INT,
	@PageId INT
)
AS
BEGIN
	DECLARE @ProcedureTypeId INT, @ProcedureDNA INT, @UISectionId INT, @SectionName VARCHAR(50), @SectionPageId INT, @SectionControl VARCHAR(50), @IncompleteSections VARCHAR(MAX) = '', @ProcedureModifiedDate DATETIME, @ProcedureCompleted BIT
	SELECT @ProcedureTypeId = ProcedureType, @ProcedureDNA = ISNULL(DNA,0), @ProcedureModifiedDate = ModifiedOn, @ProcedureCompleted = ISNULL(ProcedureCompleted,0) FROM ERS_Procedures WHERE ProcedureId = @ProcedureId

	--checks the count of endos in a procedure
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


update ers_procedures 
set NEDEnabled = 0 where procedureid in (
SELECT l.ProcedureId FROM dbo.ERS_NedI2FilesLog l
INNER JOIN dbo.ERS_Procedures p ON p.ProcedureId = l.ProcedureID
WHERE l.ErrorDescription Like 'JManoeuvre value missing. Both endoscopists must have an entry%' AND p.ProcedureType not IN (1,3,4,6)
)
GO