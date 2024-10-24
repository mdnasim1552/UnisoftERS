---------------------------------------------------------
-- Update script for release 2.24.02.xx.Report
---------------------------------------------------------
DECLARE @Version AS VARCHAR(40) = '2.24.02.Report'

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
		FROM DBVersion WHERE VersionNum = @Version

		INSERT INTO DBVersion VALUES (@Version + ' (' + CONVERT(VARCHAR, @DBVersionCount) + ')', GETDATE())
	END 
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	3981 4080 4042
-- Description of change
-- Add OperatingHospitalList in this [fw_ReportFilter] view 
------------------------------------------------------------------------------------------------------------------------
GO
ALTER VIEW [dbo].[fw_ReportFilter]
AS
SELECT        UserID, ReportDate, FromDate, ToDate, Anonymise, TypesOfEndoscopists, HideSuppressed, TrustId ,OperatingHospitalList

FROM            dbo.ERS_ReportFilter

GO
GO

GO
EXEC dbo.DropIfExist @ObjectName = 'CalcAnalgesiaGT70_New',      -- varchar(100)
                     @ObjectTypePrefix = 'F' -- varchar(5)
GO

CREATE function [dbo].[CalcAnalgesiaGT70_New] (@ConsultantId INT, @DrugName as varchar(20), @DoseMin as decimal(8,2), @DoseMax as decimal(8,2), @ProcedureTypeId int, @FromDate DateTime, @ToDate DateTime,	@OperatingHospitalList  varchar(100))
RETURNS numeric(8,2)
AS
BEGIN
/*****************************************************************************************************************
Update History:
	01     :       17/05/2024     Partha  Filter by Hospital TFS1811
******************************************************************************************************************/

	DECLARE @PreMed TABLE (Dose numeric(8,2))

	IF @ProcedureTypeId = 6 
	BEGIN
		INSERT INTO @PreMed (Dose)
		SELECT Dose
		FROM ERS_UpperGIPremedication pm
			INNER JOIN ERS_Procedures p ON pm.ProcedureId = p.ProcedureId
			INNER JOIN ERS_Patients pat ON p.PatientId = pat.PatientId
		WHERE p.ProcedureType in (6, 7) AND (Endoscopist1 = @ConsultantID OR (Endoscopist2 = @ConsultantID and Endo2Role in (2, 3)))
			AND (IsActive = 1 AND ProcedureCompleted = 1)
			AND (DrugName =@DrugName AND (Dose >= @DoseMin AND Dose <=@DoseMax))
			AND (CONVERT(int, P.CreatedOn - pat.DateOfBirth) / 365) >= 70 
			AND P.CreatedOn >= @FromDate AND P.CreatedOn <= @ToDate
			AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
			--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	END
	ELSE
	BEGIN
		INSERT INTO @PreMed (Dose)
		SELECT Dose
		FROM ERS_UpperGIPremedication pm
			INNER JOIN ERS_Procedures p ON pm.ProcedureId = p.ProcedureId
			INNER JOIN ERS_Patients pat ON p.PatientId = pat.PatientId
		WHERE p.ProcedureType = @ProcedureTypeId AND (Endoscopist1 = @ConsultantID OR (Endoscopist2 = @ConsultantID and Endo2Role in (2, 3)))
			AND (IsActive = 1 AND ProcedureCompleted = 1)
			AND (DrugName =@DrugName AND (Dose >= @DoseMin AND Dose <=@DoseMax))
			AND (CONVERT(int, P.CreatedOn - pat.DateOfBirth) / 365) >= 70 
			AND P.CreatedOn >= @FromDate AND P.CreatedOn <= @ToDate
			AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
			--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	END

	Declare @LT70 as BigInt = (SELECT count(*) 
								FROM @PreMed)

	DECLARE @RetVal as numeric(8,2)

	SELECT @RetVal = 0.00 + AVG(1.00 * Dose)
	FROM (
		SELECT ISNULL(Dose, 0.00) AS Dose
		FROM @PreMed 
		 ORDER BY Dose
		 OFFSET (@LT70 - 1) / 2 ROWS
		 FETCH NEXT 1 + (1 - @LT70 % 2) ROWS ONLY
	) AS x

	RETURN @RetVal
END

GO
EXEC dbo.DropIfExist @ObjectName = 'CalcAnalgesiaLT70_New',      -- varchar(100)
                     @ObjectTypePrefix = 'F' -- varchar(5)
GO

CREATE function [dbo].[CalcAnalgesiaLT70_New] (@ConsultantId INT, @DrugName as varchar(20), @DoseMin as decimal(8,2), @DoseMax as decimal(8,2), @ProcedureTypeId int, @FromDate DateTime, @ToDate DateTime, @OperatingHospitalList  varchar(100))
RETURNS numeric(8,2)
AS
BEGIN
/*****************************************************************************************************************
Update History:
	01     :       17/05/2024     Partha  Filter by Hospital TFS1811
******************************************************************************************************************/

	DECLARE @PreMed TABLE (Dose numeric(8,2))

	IF @ProcedureTypeId = 6
	BEGIN
		INSERT INTO @PreMed (Dose)
		SELECT Dose
		FROM ERS_UpperGIPremedication pm
			INNER JOIN ERS_Procedures p ON pm.ProcedureId = p.ProcedureId
			INNER JOIN ERS_Patients pat ON p.PatientId = pat.PatientId
		WHERE p.ProcedureType in (6, 7) AND (Endoscopist1 = @ConsultantID OR (Endoscopist2 = @ConsultantID and Endo2Role in (2, 3)))
			AND (IsActive = 1 AND ProcedureCompleted = 1)
			AND (DrugName =@DrugName AND (Dose >= @DoseMin AND Dose <=@DoseMax))
			AND (CONVERT(int, P.CreatedOn - pat.DateOfBirth) / 365) < 70 
			AND P.CreatedOn >= @FromDate AND P.CreatedOn <= @ToDate
			AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
			--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	END
	ELSE
	BEGIN
		INSERT INTO @PreMed (Dose)
		SELECT Dose
		FROM ERS_UpperGIPremedication pm
			INNER JOIN ERS_Procedures p ON pm.ProcedureId = p.ProcedureId
			INNER JOIN ERS_Patients pat ON p.PatientId = pat.PatientId
		WHERE p.ProcedureType = @ProcedureTypeId AND (Endoscopist1 = @ConsultantID OR (Endoscopist2 = @ConsultantID and Endo2Role in (2, 3)))
			AND (IsActive = 1 AND ProcedureCompleted = 1)
			AND (DrugName =@DrugName AND (Dose >= @DoseMin AND Dose <=@DoseMax))
			AND (CONVERT(int, P.CreatedOn - pat.DateOfBirth) / 365) < 70 
			AND P.CreatedOn >= @FromDate AND P.CreatedOn <= @ToDate
			AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
			--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	END

	Declare @LT70 as BigInt = (SELECT count(*) 
								FROM @PreMed)

	DECLARE @RetVal as numeric(8,2)

	SELECT @RetVal = 0.00 + AVG(1.00 * Dose)
	FROM (
		SELECT ISNULL(Dose, 0.00) as Dose
		FROM @PreMed
		 ORDER BY Dose
		 OFFSET (@LT70 - 1) / 2 ROWS
		 FETCH NEXT 1 + (1 - @LT70 % 2) ROWS ONLY
	) AS x

	RETURN @RetVal
END


GO
EXEC dbo.DropIfExist @ObjectName = 'report_JAGCOL',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
CREATE PROCEDURE [dbo].[report_JAGCOL] 
	@UserID INT
AS
/* Update History		:		08 Dec 2021		MH added filter out to elimiate Cancelled (DNA ) Procedures-
				:       17/05/2024     Partha  Filter by Hospital TFS1811

*/


BEGIN
	DECLARE @ProcedureTypeId INT
	SET @ProcedureTypeId = 3

	DECLARE @FromDate as Date,
		@ToDate as Date,
		@ConsultantId as int,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)



	SELECT rc.ConsultantID , con.Title + ' ' + con.Forename + ' ' + con.Surname AS Endoscopist, rc.AnonimizedID
	INTO #Consultants
	FROM ERS_ReportConsultants rc
	JOIN ERS_Users con on rc.ConsultantID = con.UserID 
	WHERE rc.UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT  con.AnonimizedID AS AnonimizedID
				, con.Endoscopist as Endoscopist1
				, con.ConsultantId AS ReportID
				, con.Endoscopist AS Consultant
				, COUNT(DISTINCT p.ProcedureId) AS NumberOfProcedures
				, COUNT(DISTINCT CASE WHEN ISNULL(ple.RectalExamPerformed, 0) = 1 THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS DigiRectalExaminationP
				, COUNT(DISTINCT CASE WHEN ISNULL(ple.RetroflectionPerformed, 0) = 1 THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS RectalRetoversionRateP
				, COUNT(DISTINCT CASE WHEN eds.NEDTerm IN ('Moderate','Severe') THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS ComfortLevelModerateSevereDiscomfort
				, COUNT(DISTINCT CASE WHEN eds.NEDTerm IN ('Moderate','Severe') THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS ComfortLevelModerateSevereDiscomfortNurse
				, (SUM(DISTINCT ple.WithdrawalMins)/COUNT(DISTINCT p.ProcedureId)) AS MeanWithdrawalTime
				, ISNULL(COUNT(DISTINCT CASE WHEN e.ListOrderBy <= 90 THEN s.SiteId END) * 1.0 / NULLIF(COUNT(CASE WHEN e.ListOrderBy <= 90 THEN s.SiteId END), 0),0) AS PolypDetectionRate
				, COUNT(DISTINCT CASE WHEN e.ListOrderby <= 90 THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS UnadjustedCaecalIntubationRate
				, COUNT(DISTINCT CASE WHEN e.ListOrderby IN (60,70) THEN p.ProcedureId END)* 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS TerminalIlealIntubationRate
				, COUNT(DISTINCT dbo.DiarroheaBiopsies(p.ProcedureId)) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS DiagnosticRectalBiopsiesForUnexplainedDiarrohea
				, COUNT(DISTINCT CASE WHEN tl.Region NOT IN ('Rectum', 'Caecum') AND tl.TattooedId IN (2,3) THEN tl.RowId END)  * 1.0 / NULLIF(COUNT(DISTINCT tl.RowId),0) AS TattooingOfAllLesionsP
				, SUM(CASE WHEN pd.Retreived <> 0 AND pd.Successful <> 0 THEN convert(int,pd.Successful) END) * 1.0 / NULLIF(COUNT(pd.PolypDetailId),0) AS PolypRetrievalRateP
				, COUNT(CASE WHEN eds.NEDTerm IN ('Moderate','Severe') THEN '' END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS ComfortLevelModerateSevereDiscomfort
				, COUNT(CASE WHEN eds.NEDTerm IN ('Moderate','Severe') THEN '' END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS ComfortLevelModerateSevereDiscomfortNurse
				, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Midazolam', 0.5, 10.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianSedationRateLT70Years_Midazolam
				, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Pethidine', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateLT70Years_Pethidine
				, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Fentanyl', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateLT70Years_Fentanyl
				, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Midazolam', 0.5, 10.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianSedationRateGE70Years_Midazolam
				, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Pethidine', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateGE70Years_Pethidine
				, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Fentanyl', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateGE70Years_Fentanyl
				/*NO SEDATION*/
				, COUNT(distinct prof.ProcedureId) * 1.0 / NULLIF(COUNT( distinct p.procedureId), 0) as PropofolP
							, COUNT(DISTINCT CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null THEN P.ProcedureId END) 
				* 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN dru.GeneralAnaesthetic is null then P.ProcedureId END), 0) AS NoSedationP		
				--/* GTRecommededDose */
				, COUNT(DISTINCT CASE 
									WHEN (
											(P.Endoscopist1 = con.ConsultantId OR P.Endoscopist2 = con.ConsultantId) AND 
											(
												((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 < 70 AND (
													(	(dru.Pethidine > 50) OR
														(dru.midazolam > 5) OR
														(dru.Fentanyl > 100))
													)
												) OR 
												(	
													((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 >= 70 AND (
														(dru.Pethidine > 25) OR
														(dru.midazolam > 2.5) OR
														(dru.Fentanyl > 50))
													)	
												)
											)
										) THEN P.ProcedureId
								END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS GTRecommededDose
	FROM #Consultants con
	JOIN ERS_Procedures p ON (con.ConsultantId = p.Endoscopist1 or (con.ConsultantId = p.Endoscopist2 and P.Endo2Role in (2, 3)))
	JOIN ERS_Patients pat on p.PatientId = pat.PatientId
	LEFT JOIN ERS_UpperGIPremedication prof on p.ProcedureId = prof.ProcedureId AND prof.DrugName = 'propofol' AND prof.Dose > 0
	LEFT JOIN ERS_UpperGIPremedication midazolam on p.ProcedureId = midazolam.ProcedureId AND midazolam.DrugName = 'midazolam'
	LEFT JOIN fw_ERS_Drugs as dru on P.ProcedureID = dru.ProcId
	LEFT JOIN ERS_ProcedureLowerExtent ple ON ple.ProcedureId = p.ProcedureId AND ple.EndoscopistId = CASE WHEN p.Endoscopist2 = con.ConsultantId AND p.Endo2Role IN (2,3) THEN con.ConsultantId ELSE ple.EndoscopistId END
	LEFT JOIN ERS_Extent e ON e.UniqueId = ple.ExtentId
	LEFT JOIN ERS_ExtentProcedureTypes ept ON ept.ExtentId = e.UniqueId AND ept.ProcedureTypeId = 3
	LEFT JOIN dbo.ERS_ProcedureDiscomfortScore epds ON p.ProcedureId = epds.ProcedureId
	LEFT JOIN dbo.ERS_DiscomfortScores eds ON epds.DiscomfortScoreId = eds.UniqueId
	LEFT JOIN ERS_ProcedureIndications pri ON pri.ProcedureId = p.ProcedureId
	LEFT JOIN ERS_Indications i ON i.UniqueId = pri.IndicationId
	LEFT JOIN ERS_Sites s ON s.ProcedureId = p.ProcedureId
	LEFT JOIN (SELECT S.ProcedureId, PolypDetailId, Retreived, Successful, Size, TattooedId, r.Region, s.SiteId
				FROM ERS_CommonAbnoPolypDetails pd 
					INNER JOIN ERS_Sites s ON pd.SiteId = s.SiteId 
					INNER JOIN ERS_PolypTypes pt ON pt.UniqueId = pd.PolypTypeId 
					INNER JOIN ERS_Regions r ON r.RegionId = s.RegionId
				WHERE LOWER(pt.[Description]) IN ('sessile','pedunculated','pseudo')) pd ON pd.ProcedureId = p.ProcedureId
	LEFT JOIN dbo.fw_TattooedLesions tl ON tl.SiteId = s.SiteId
	WHERE p.ProcedureType = @ProcedureTypeId
		and p.ProcedureCompleted = 1
		and p.IsActive = 1
		and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
		--MH added on 08 Dec 2021
		and IsNull(p.DNA,0) = 0
		AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
		--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	GROUP BY con.Endoscopist, con.ConsultantId, con.AnonimizedID--, p.ProcedureId
	ORDER BY con.AnonimizedID 
END

GO
EXEC dbo.DropIfExist @ObjectName = 'report_JAGENTR_DrillDown',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[report_JAGENTR_DrillDown] 
	@UserId int,
	@AnonomizedId int
AS
BEGIN
/*****************************************************************************************************************
17 May 2022		:		Mahfuz created TFS 2056 : SE V1 audit ENT hyperlink
:       17/05/2024     Partha  Filter by Hospital TFS1811
:       10/06/2024     Partha  Show Endo1 and Endo2 TFS2176
******************************************************************************************************************/
DECLARE @ConsultantId as int,
		@FromDate as Date,
		@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)


Select @ConsultantId = ConsultantID 
from ERS_ReportConsultants
where AnonimizedID = @AnonomizedId
and UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

Select  p.ProcedureId,
		case when p.Endoscopist2 = u.UserID and p.Endo2Role in (2, 3) then eoi.Extent
		else case when (case when eoi.TrainerExtent = 0 then 99 else eoi.TrainerExtent end) > (case when eoi.Extent = 0 then 99 else eoi.Extent end) then eoi.Extent else eoi.TrainerExtent end
		end as extent,
		convert(varchar(50), '') as extentDescription,
		CASE WHEN (CASE WHEN p.Endoscopist2 = u.UserID and p.Endo2Role in (2, 3) then eoi.Jmanoeuvre
			ELSE CASE WHEN eoi.Jmanoeuvre >1 OR eoi.TrainerJmanoeuvre >1 THEN 2 ELSE 0 END
		END) > 1 THEN 'Yes' ELSE 'No' END as jMan,
		eoi.Jmanoeuvre as eejman,
		eoi.TrainerJmanoeuvre as erjman
into #extent
from ERS_UpperGIExtentOfIntubation eoi
join ERS_Procedures p on p.ProcedureId = eoi.ProcedureId 
join ERS_Users u on (u.UserID = p.Endoscopist1 or(u.UserID = p.Endoscopist2 and p.Endo2Role in (2, 3)))
where u.UserID = @ConsultantId
and p.ProcedureCompleted = 1
and p.IsActive = 1
and p.ProcedureType = 9
	--MH added on 31 Mar 2022
		and IsNull(p.DNA,0) = 0

update e
set extentDescription = l.ListItemText
from #extent e
join ERS_Lists l on l.ListItemNo = e.extent
where l.ListDescription = 'Extent of Intubation OGD'



Select  
		pat.Surname + ', '+ pat.Forename1 as Patient, 
		pat.HospitalNumber as 'Case No.',
		pat.NHSNo, 
		dbo.fnGender(pat.GenderId) as Gender, 
		convert(varchar, p.CreatedOn, 106) as ProcedureDate, 
		ps.PatientStatus as 'Patient Status',
		u1.Surname + ', '+ u1.Forename as 'Endoscopist 1',
		u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
		ex.ExtentDescription,
		ex.jMan as 'J Manoeuvre',
		CASE qa.PatDiscomfortEndo		
			When 6 Then 'Severe' 
			When 5 Then 'Moderate' 
			When 4 Then 'Mild' 
			When 3 Then 'Minimal'
			When 2 Then 'Comfortable' 
			Else 'Not Specified' 
		End As 'Comfort Rate',
		dru.midazolam As 'Midazolam Dose',
		dru.pethidine As 'Pethidine Dose',
		dru.fentanyl As 'Fentanyl Dose',
		case when dru.GeneralAnaesthetic is null then 'No' else 'Yes' end as 'General Anaesthetic',
		CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null then 'No' ELSE 'Yes' END as 'Sedation Used'
FROM ERS_Procedures p
join (select ListItemNo as PatientStatusId, ListItemText as PatientStatus from ERS_Lists where ListDescription = 'Patient Status') ps on p.PatientStatus = ps.PatientStatusId
join ERS_Users u on (u.UserID = p.Endoscopist1 or (u.UserID = p.Endoscopist2 and p.Endo2Role in (2, 3)))
join ERS_Patients pat on pat.PatientId = p.PatientId
Left join ERS_Users u1 (NOLOCK) on u1.UserID = p.Endoscopist1
left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
left join #extent ex on ex.ProcedureId = p.ProcedureId 
left join ERS_UpperGIQA qa on qa.ProcedureId = p.ProcedureId
--left join ERS_UpperGIPremedication midazolam on p.ProcedureId = midazolam.ProcedureId and midazolam.DrugName = 'Midazolam'
--left join ERS_UpperGIPremedication pethidine on p.ProcedureId = pethidine.ProcedureId and pethidine.DrugName = 'Pethidine'
--left join ERS_UpperGIPremedication fentanyl on p.ProcedureId = fentanyl.ProcedureId and fentanyl.DrugName = 'Fentanyl'
--left join ERS_UpperGIPremedication noSed on p.ProcedureId = noSed.ProcedureId and noSed.DrugName = 'NoSedation'
LEFT JOIN fw_ERS_Drugs as dru on p.ProcedureID = dru.ProcId
where u.UserID = @ConsultantId
and p.ProcedureCompleted = 1
and p.IsActive = 1
and p.ProcedureType = 9
and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	--MH added on 31 Mar 2022
		and IsNull(p.DNA,0) = 0
order by p.ProcedureId


drop table #extent
END

GO
EXEC dbo.DropIfExist @ObjectName = 'report_JAGERC',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO


CREATE PROCEDURE [dbo].[report_JAGERC] 
	@UserID INT
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
	02		:       17/05/2024     Partha  Filter by Hospital TFS1811
******************************************************************************************************************/
BEGIN
	DECLARE @FromDate as Date,
		@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)



SELECT rc.ConsultantID , con.Surname + ', ' + con.Forename AS Endoscopist, rc.AnonimizedID
INTO #Consultants
FROM ERS_ReportConsultants rc
JOIN ERS_Users con on rc.ConsultantID = con.UserID 
WHERE rc.UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId


Select con.AnonimizedID AS AnonimizedID
			, con.Endoscopist as Endoscopist1
			, con.ConsultantId AS ReportID
			, con.Endoscopist AS Consultant
			, count(DISTINCT p.ProcedureId) AS NumberOfProcedures
			,COUNT(DISTINCT CASE 
				WHEN p.Endoscopist2 = con.ConsultantId AND p.Endo2Role > 1 AND 
					((v.IntendedBileDuct=1 AND v.MajorPapillaBile=1) OR 
					(v.IntendedPancreaticDuct=1 AND v.MajorPapillaPancreatic=1)) 
					AND p.FirstERCP = 1
						THEN p.procedureId -- Trainee
				WHEN (p.Endoscopist1 = con.ConsultantId) AND
					((v.IntendedBileDuct=1 AND v.MajorPapillaBile=1) OR (v.IntendedBileDuct_ER=1 AND v.MajorPapillaBile_ER=1) OR
					(v.IntendedPancreaticDuct=1 AND v.MajorPapillaPancreatic=1) OR (v.IntendedPancreaticDuct_ER=1 AND v.MajorPapillaPancreatic_ER=1)) 
					AND p.FirstERCP = 1
						THEN p.procedureId -- Independent
				END) * 1.0 / NULLIF(COUNT(DISTINCT case when p.FirstERCP = 1 then p.ProcedureId end), 0) as CannulationOfIntendedDuctAtFirstERCP
			,COUNT(DISTINCT CASE 
				WHEN (p.Endoscopist2 = con.ConsultantId AND the.EndoRole in (2,3)) THEN the.ProcedureId
				WHEN p.Endoscopist1 = con.ConsultantID THEN the.ProcedureId
				END) * 1.0 / NULLIF(COUNT(DISTINCT case when p.FirstERCP = 1 then p.ProcedureId end), 0) as CommonBileDuctStoneCclearanceAtFirstERCP 
			,COUNT(DISTINCT CASE 
				WHEN (p.Endoscopist2 = con.ConsultantId AND ehs.EndoRole in (2,3)) AND p.FirstERCP = 1 THEN ehs.ProcedureId
				WHEN p.Endoscopist1 = con.ConsultantID AND p.FirstERCP = 1 and ehs.ProcedureId is not null THEN ehs.ProcedureId
				END) * 1.0 / NULLIF(COUNT(DISTINCT case when p.FirstERCP = 1 then p.ProcedureId end), 0) as ExtraHepaticStrictureStentSiting 

			, COUNT(DISTINCT CASE 
				WHEN qa.PatDiscomfortEndo = 5 OR qa.PatDiscomfortEndo = 6 then p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT p.procedureId), 0) as ComfortLevelModerateSevereDiscomfort	
			, COUNT(DISTINCT CASE 
				WHEN qa.PatDiscomfortNurse = 5 OR qa.PatDiscomfortNurse = 6 then p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT p.procedureId), 0) as ComfortLevelModerateSevereDiscomfortNurse					
			
			, dbo.CalcAnalgesiaLT70(con.ConsultantID, 'Midazolam', 0.5, 10.0, 2, @FromDate, @ToDate) AS MedianSedationRateLT70Years_Midazolam
			, dbo.CalcAnalgesiaLT70(con.ConsultantID, 'Pethidine', 12.5, 200.0, 2, @FromDate, @ToDate) AS MedianAnalgesiaRateLT70Years_Pethidine
			, dbo.CalcAnalgesiaLT70(con.ConsultantID, 'Fentanyl', 12.5, 200.0, 2, @FromDate, @ToDate) AS MedianAnalgesiaRateLT70Years_Fentanyl
			, dbo.CalcAnalgesiaGT70(con.ConsultantID, 'Midazolam', 0.5, 10.0, 2, @FromDate, @ToDate) AS MedianSedationRateGE70Years_Midazolam
			, dbo.CalcAnalgesiaGT70(con.ConsultantID, 'Pethidine', 12.5, 200.0, 2, @FromDate, @ToDate) AS MedianAnalgesiaRateGE70Years_Pethidine
			, dbo.CalcAnalgesiaGT70(con.ConsultantID, 'Fentanyl', 12.5, 200.0, 2, @FromDate, @ToDate) AS MedianAnalgesiaRateGE70Years_Fentanyl
			, COUNT(distinct prof.ProcedureId) * 1.0 / NULLIF(COUNT( distinct p.procedureId), 0) as PropofolP
						, COUNT(DISTINCT CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null THEN P.ProcedureId END) 
			* 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN dru.GeneralAnaesthetic is null then P.ProcedureId END), 0) AS NoSedationP		
			--/* GTRecommededDose */
			, COUNT(DISTINCT CASE 
								WHEN (
										(P.Endoscopist1 = con.ConsultantId OR P.Endoscopist2 = con.ConsultantId) AND 
										(
											((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 < 70 AND (
												(	(dru.Pethidine > 50) OR
													(dru.midazolam > 5) OR
													(dru.Fentanyl > 100))
												)
											) OR 
											(	
												((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 >= 70 AND (
													(dru.Pethidine > 25) OR
													(dru.midazolam > 2.5) OR
													(dru.Fentanyl > 50))
												)	
											)
										)
									) THEN P.ProcedureId
							END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS GTRecommededDose
FROM #Consultants con
JOIN ERS_Procedures p ON (con.ConsultantId = p.Endoscopist1 or (con.ConsultantId = p.Endoscopist2 and P.Endo2Role in (2, 3)))
JOIN ERS_Patients pat on p.PatientId = pat.PatientId
LEFT JOIN dbo.ERS_Visualisation v on v.ProcedureID = p.ProcedureId 
LEFT JOIN (Select DISTINCT p.ProcedureId, isnull(t.EndoRole, 3) as EndoRole
			from ERS_Procedures p
			LEFT JOIN ERS_UpperGIIndications i on p.ProcedureId = i.ProcedureId 
			LEFT JOIN (Select max(convert(int,stones)) Stones, sit.ProcedureId from ERS_Sites sit join ERS_ERCPAbnoDuct eed on sit.SiteId = eed.siteId group by sit.ProcedureId) eed ON p.ProcedureId = eed.ProcedureId 
			LEFT JOIN (Select max(convert(int,th.StoneRemoval)) StoneRemoval, max(th.ExtractionOutcome) ExtractionOutcome, s.ProcedureId, th.EndoRole 
					FROM ERS_Sites s
					LEFT JOIN ERS_ERCPTherapeutics th on s.SiteId = th.SiteId 
					where th.StoneRemoval = 1
					and s.RegionId in (Select RegionId from ERS_Regions where ProcedureType = 2 and  Region = 'Common Bile Duct')
					group by s.ProcedureId, th.EndoRole) t on t.ProcedureId = p.ProcedureId  
			LEFT JOIN ERS_Visualisation v on p.ProcedureId = v.ProcedureID 
			LEFT JOIN #Consultants c on (c.ConsultantId = p.Endoscopist1 or (c.ConsultantId = p.Endoscopist2 and P.Endo2Role in (2, 3)))
			WHERE	p.FirstERCP = 1
			AND		CASE WHEN p.Endoscopist1 = c.ConsultantId and v.IntendedBileDuct_ER = 1 and isnull(v.MajorPapillaBile_ER, 3) > 1 THEN 0
						 WHEN (c.ConsultantId = p.Endoscopist2 and P.Endo2Role in (2, 3)) and ((v.IntendedBileDuct = 1 or v.IntendedBileDuct_ER = 1) and (isnull(v.MajorPapillaBile, 3) > 1 and isnull(v.MajorPapillaBile_ER, 3) > 1)) then 0
						 WHEN t.StoneRemoval = 1 and t.ExtractionOutcome IN (3,4) then 0
						 WHEN t.StoneRemoval = 1 and t.ExtractionOutcome NOT IN (3,4) then 1
						 WHEN eed.Stones = 1 then 0
						 WHEN i.ERSCBDStones = 1 or i.ERSGallBladder = 1 then 1
						 ELSE 0
					END = 1) as the on p.ProcedureId = the.ProcedureId 
LEFT JOIN (Select DISTINCT pro.ProcedureId, thera.EndoRole 
			from ERS_Procedures pro
			join ERS_Sites sit on pro.ProcedureId = sit.ProcedureId 
			join ERS_ERCPAbnoDuct ad on sit.SiteId = ad.SiteId 
			join ERS_UpperGISpecimens spec on sit.SiteId = spec.SiteId 
			join ERS_ERCPTherapeutics thera on sit.SiteId = thera.SiteId 
			where ad.Stricture = 1
			and (spec.BiopsyQtyHistology > 0 OR spec.BrushCytology = 1 OR spec.CytologyHistology = 1 OR spec.Bile_PanJuiceCytology = 1 OR spec.NeedleAspirateHistology = 1)
			and sit.RegionId in (Select RegionId from ERS_Regions where ProcedureType = 2 and Region in ('Common Hepatic Duct', 'Common Bile Duct'))
			and thera.StentInsertion = 1) as ehs on ehs.ProcedureId = p.ProcedureId
LEFT JOIN ERS_UpperGIQA  qa on p.ProcedureId = qa.ProcedureId 
LEFT JOIN ERS_UpperGIPremedication prof on p.ProcedureId = prof.ProcedureId AND prof.DrugName = 'propofol' AND prof.Dose > 0
LEFT JOIN ERS_UpperGIPremedication midazolam on p.ProcedureId = midazolam.ProcedureId AND midazolam.DrugName = 'midazolam'
LEFT JOIN fw_ERS_Drugs as dru on P.ProcedureID = dru.ProcId

WHERE p.ProcedureType = 2 
and p.ProcedureCompleted = 1
and p.IsActive = 1
--MH added on 31 Mar 2022
and IsNull(p.DNA,0) = 0
and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
GROUP BY con.Endoscopist, con.ConsultantId, con.AnonimizedID
ORDER BY con.Endoscopist 

drop table #Consultants

END

GO
EXEC dbo.DropIfExist @ObjectName = 'report_JAGEUS',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[report_JAGEUS] 
	@UserID INT
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
	02		:       17/05/2024     Partha  Filter by Hospital TFS1811
******************************************************************************************************************/
BEGIN

	DECLARE @FromDate as Date,
		@ToDate as Date,
		@ConsultantId as int,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)



	SELECT rc.ConsultantID , con.Title + ' ' + con.Forename + ' ' + con.Surname AS Endoscopist, rc.AnonimizedID
	INTO #Consultants
	FROM ERS_ReportConsultants rc
	JOIN ERS_Users con on rc.ConsultantID = con.UserID 
	WHERE rc.UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

			
			
			SELECT  con.AnonimizedID AS AnonimizedID
				, con.Endoscopist as Endoscopist1
				, con.ConsultantId AS ReportID
				, con.Endoscopist AS Consultant
				, COUNT(DISTINCT p.ProcedureId) AS NumberOfProcedures
				, COUNT(DISTINCT CASE WHEN eds.NEDTerm IN ('Moderate','Severe') THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS ComfortLevelModerateSevereDiscomfort
				, COUNT(DISTINCT CASE WHEN eds.NEDTerm IN ('Moderate','Severe') THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS ComfortLevelModerateSevereDiscomfortNurse
				, COUNT(CASE WHEN eds.NEDTerm IN ('Moderate','Severe') THEN '' END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS ComfortLevelModerateSevereDiscomfort
				, COUNT(CASE WHEN eds.NEDTerm IN ('Moderate','Severe') THEN '' END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS ComfortLevelModerateSevereDiscomfortNurse
				, COUNT(DISTINCT CASE WHEN us.NeedleAspirate = 1 THEN p.ProcedureId END)  * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) FNABiopsyP
				, COUNT(DISTINCT CASE WHEN dru.propofol IS NOT NULL THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) PropofolP
				, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Midazolam', 0.5, 10.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianSedationRateLT70Years_Midazolam
				, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Pethidine', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateLT70Years_Pethidine
				, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Fentanyl', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @TrustId) AS MedianAnalgesiaRateLT70Years_Fentanyl
				, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Midazolam', 0.5, 10.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianSedationRateGE70Years_Midazolam
				, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Pethidine', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateGE70Years_Pethidine
				, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Fentanyl', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateGE70Years_Fentanyl
				/*NO SEDATION*/
				, COUNT(distinct prof.ProcedureId) * 1.0 / NULLIF(COUNT( distinct p.procedureId), 0) as PropofolP
							, COUNT(DISTINCT CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null THEN P.ProcedureId END) 
				* 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN dru.GeneralAnaesthetic is null then P.ProcedureId END), 0) AS NoSedationP		
				--/* GTRecommededDose */
				, COUNT(DISTINCT CASE 
									WHEN (
											(P.Endoscopist1 = con.ConsultantId OR P.Endoscopist2 = con.ConsultantId) AND 
											(
												((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 < 70 AND (
													(	(dru.Pethidine > 50) OR
														(dru.midazolam > 5) OR
														(dru.Fentanyl > 100))
													)
												) OR 
												(	
													((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 >= 70 AND (
														(dru.Pethidine > 25) OR
														(dru.midazolam > 2.5) OR
														(dru.Fentanyl > 50))
													)	
												)
											)
										) THEN P.ProcedureId
								END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS GTRecommededDose
		FROM #Consultants con
	JOIN ERS_Procedures p ON (con.ConsultantId = p.Endoscopist1 or (con.ConsultantId = p.Endoscopist2 and P.Endo2Role in (2, 3)))
	JOIN ERS_Patients pat on p.PatientId = pat.PatientId
	LEFT JOIN ERS_UpperGIPremedication prof on p.ProcedureId = prof.ProcedureId AND prof.DrugName = 'propofol' AND prof.Dose > 0
	LEFT JOIN ERS_UpperGIPremedication midazolam on p.ProcedureId = midazolam.ProcedureId AND midazolam.DrugName = 'midazolam'
	LEFT JOIN fw_ERS_Drugs as dru on P.ProcedureID = dru.ProcId
	LEFT JOIN dbo.ERS_ProcedureDiscomfortScore epds ON p.ProcedureId = epds.ProcedureId
	LEFT JOIN dbo.ERS_DiscomfortScores eds ON epds.DiscomfortScoreId = eds.UniqueId
	LEFT JOIN ERS_Sites s ON s.ProcedureId = p.ProcedureId
	LEFT JOIN ERS_UpperGISpecimens us ON us.SiteId = s.SiteId
	WHERE p.ProcedureType IN (6,7)
		and p.ProcedureCompleted = 1
		and p.IsActive = 1
		and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
		AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
		--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
		--MH added on 31 Mar 2022
		and IsNull(p.DNA,0) = 0
	GROUP BY con.Endoscopist, con.ConsultantId, con.AnonimizedID
	ORDER BY con.AnonimizedID 
END

GO
EXEC dbo.DropIfExist @ObjectName = 'report_JAGOGD',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[report_JAGOGD] 
	@UserID INT
AS
BEGIN
/*****************************************************************************************************************
Update History:	
	01		:       17/05/2024     Partha  Filter by Hospital TFS1811
******************************************************************************************************************/

	DECLARE @ProcedureTypeId INT
	SET @ProcedureTypeId = 1

	DECLARE @FromDate as Date,
			@ToDate as Date,
			@ConsultantId as int,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)



	SELECT rc.ConsultantID , con.Title + ' ' + con.Forename + ' ' + con.Surname AS Endoscopist, rc.AnonimizedID
	INTO #Consultants
	FROM ERS_ReportConsultants rc
	JOIN ERS_Users con on rc.ConsultantID = con.UserID 
	WHERE rc.UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	
	Select con.AnonimizedID AS AnonimizedID
				, con.Endoscopist as Endoscopist1
				, con.ConsultantId AS ReportID
				, con.Endoscopist AS Consultant
				, count(DISTINCT p.ProcedureId) AS NumberOfProcedures
				, COUNT(DISTINCT CASE WHEN e.IsSuccess = 1 THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS SuccessOfIntubationP
				, COUNT(DISTINCT CASE WHEN ISNULL(ue.JManoeuvreId,0) = 1 THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS JManoeuvreRate
				, COUNT(DISTINCT CASE WHEN e.NEDTerm IN ('Duodenum 2nd Part', 'Duodenum 3rd Part', 'Duodenum 4th Part', 'Jejunum') THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS CompletenessOfProcedureP
					/*Comfort score*/
				, COUNT(CASE WHEN eds.NEDTerm IN ('Moderate','Severe') THEN '' END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS ComfortLevelModerateSevereDiscomfort
				, COUNT(CASE WHEN eds.NEDTerm IN ('Moderate','Severe') THEN '' END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS ComfortLevelModerateSevereDiscomfortNurse
				, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Midazolam', 0.5, 10.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianSedationRateLT70Years_Midazolam
				, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Pethidine', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateLT70Years_Pethidine
				, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Fentanyl', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateLT70Years_Fentanyl
				, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Midazolam', 0.5, 10.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianSedationRateGE70Years_Midazolam
				, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Pethidine', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateGE70Years_Pethidine
				, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Fentanyl', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateGE70Years_Fentanyl
				/*NO SEDATION*/
				, COUNT(distinct prof.ProcedureId) * 1.0 / NULLIF(COUNT( distinct p.procedureId), 0) as PropofolP
							, COUNT(DISTINCT CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null THEN P.ProcedureId END) 
				* 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN dru.GeneralAnaesthetic is null then P.ProcedureId END), 0) AS NoSedationP		
				--/* GTRecommededDose */
				, COUNT(DISTINCT CASE 
									WHEN (
											(P.Endoscopist1 = con.ConsultantId OR P.Endoscopist2 = con.ConsultantId) AND 
											(
												((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 < 70 AND (
													(	(dru.Pethidine > 50) OR
														(dru.midazolam > 5) OR
														(dru.Fentanyl > 100))
													)
												) OR 
												(	
													((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 >= 70 AND (
														(dru.Pethidine > 25) OR
														(dru.midazolam > 2.5) OR
														(dru.Fentanyl > 50))
													)	
												)
											)
										) THEN P.ProcedureId
								END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS GTRecommededDose
	FROM #Consultants con
		JOIN ERS_Procedures p ON (con.ConsultantId = p.Endoscopist1 or (con.ConsultantId = p.Endoscopist2 and P.Endo2Role in (2, 3)))
		JOIN ERS_Patients pat on p.PatientId = pat.PatientId
		LEFT JOIN ERS_UpperGIQA  UGIQA on p.ProcedureId = UGIQA.ProcedureId 
		LEFT JOIN ERS_UpperGIPremedication prof on p.ProcedureId = prof.ProcedureId AND prof.DrugName = 'propofol' AND prof.Dose > 0
		LEFT JOIN ERS_UpperGIPremedication midazolam on p.ProcedureId = midazolam.ProcedureId AND midazolam.DrugName = 'midazolam'
		LEFT JOIN fw_ERS_Drugs as dru on P.ProcedureID = dru.ProcId
		LEFT JOIN ERS_UpperGIExtentOfIntubation as ei ON ei.ProcedureId = p.ProcedureId
		LEFT JOIN ERS_ProcedureUpperExtent ue ON ue.ProcedureId = p.ProcedureId AND ue.EndoscopistId = CASE WHEN p.Endoscopist2 = con.ConsultantId AND p.Endo2Role IN (2,3) THEN con.ConsultantId ELSE ue.EndoscopistId END
		LEFT JOIN ERS_Extent e ON e.UniqueId = ue.ExtentId
		LEFT JOIN dbo.ERS_ProcedureDiscomfortScore epds ON p.ProcedureId = epds.ProcedureId
		LEFT JOIN dbo.ERS_DiscomfortScores eds ON epds.DiscomfortScoreId = eds.UniqueId
	WHERE p.ProcedureType = 1 
		and p.ProcedureCompleted = 1
		and p.IsActive = 1
		and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
		AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
		--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
		--MH added on 31 Mar 2022
		and IsNull(p.DNA,0) = 0
	GROUP BY con.Endoscopist, con.ConsultantId, con.AnonimizedID
	ORDER BY con.AnonimizedID 
END

GO
EXEC dbo.DropIfExist @ObjectName = 'report_JAGPEG',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[report_JAGPEG] 
	@UserID INT
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
	02      :       17/05/2024     Partha  Filter by Hospital TFS1811
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
	AND PR.OperatingHospitalID IN (SELECT * FROM dbo.splitString(RF.OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
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

			, ' ' AS ClinicalLeadReviewAndActionRequired
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
EXEC dbo.DropIfExist @ObjectName = 'report_JAGPEG_DrillDown',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[report_JAGPEG_DrillDown] 
	@UserId int,
	@AnonomizedId int
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
	02		:		01 Aug 2022		Adrian Rename NHSNo Column to match custom Health Service
	03      :       17/05/2024     Partha  Filter by Hospital TFS1811
	04      :		29/05/2024     Partha   PEG procedure & Audit update TFS 2798
	05      :       10/06/2024     Partha  Show Endo1 and Endo2 TFS2176
******************************************************************************************************************/
BEGIN

	DECLARE @ConsultantId as int,
			@FromDate as Date,
			@ToDate as Date,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)


	Select @ConsultantId = ConsultantID 
	from ERS_ReportConsultants
	where AnonimizedID = @AnonomizedId
	and UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'
	
	SELECT  distinct p.ProcedureId,p.Endoscopist1,p.Endoscopist2,
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
		and P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
		AND (@ConsultantId = convert(varchar(10), P.Endoscopist1)
			OR (@ConsultantId = convert(varchar(10), p.Endoscopist2) and P.Endo2Role in (2, 3) and PEGProc.EndoRole IN (2,3))
			)
		AND (@ConsultantId = convert(varchar(10), P.Endoscopist1) OR (@ConsultantId = convert(varchar(10), p.Endoscopist2) and P.Endo2Role in (2, 3)))
	GROUP BY pat.Forename1, pat.Surname, pat.HospitalNumber,qa.PatDiscomfortEndo, pat.NHSNo, pat.GenderId,p.CreatedOn, ps.PatientStatus, PEGProc.CorrectPEGPlacement, poc.PeritonitisFollowingPEG, poc.AntibioticsForInfectionFollowingPEG, qa.SignificantHaemorrhage,
	p.ProcedureId,p.Endoscopist1,p.Endoscopist2


	Select Patient, [Case No.],Gender,ProcedureDate,NHSNO,[Patient Status],[Correct placement],
					[Post procedure infection requiring antibiotics],
					[Post procedure peritonitis],
					[Bleeding requiring transfusion],
						u.Surname + ', '+ u.Forename as 'Endoscopist 1',
					u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
				STUFF(( select ';'+ ' InsertionSize- ' +convert(varchar,GastrostomyInsertionSize)+ ' ' +
				lmunit.ListItemText+ ' InsertionType- ' +  lmType.ListItemText +  ' Batch No- ' +GastrostomyInsertionBatchNo+ ' CorrectPEGPlacement- ' + case CorrectPEGPlacement when 1 then 'Yes' else 'No' end 
				from ERS_UpperGITherapeutics eug
				INNER JOIN dbo.ERS_Sites es  ON es.SiteId = eug.SiteId
				left join ers_lists lmunit on  lmunit.ListItemNo=GastrostomyInsertionUnits
				left join ers_lists lmType on  lmType.ListItemNo=GastrostomyInsertionUnits
				where  lmunit.listdescription in ('Gastrostomy PEG units')
				and lmType.ListDescription in('Gastrostomy PEG type')
				and  es.ProcedureId=tm.ProcedureId
				for XML PATH('')
				),1,1,'') as 'Insertion Details'
				into ##ReportTempWithHealthServiceField
	from ##ReportTemp tm
	join ERS_Users u (NOLOCK) on u.UserID = tm.Endoscopist1
	left join ERS_Users u2 (NOLOCK) on u2.UserID = tm.Endoscopist2

	declare @SQL nvarchar(1000)
	set @SQL = 'tempdb.sys.sp_rename N''##ReportTempWithHealthServiceField.NHSNo'', N''' + @HealthService + ' No'' '
	exec sp_executesql @SQL

		
	select * from ##ReportTempWithHealthServiceField

	drop table ##ReportTemp
	drop table ##ReportTempWithHealthServiceField

END


GO
EXEC dbo.DropIfExist @ObjectName = 'report_JAGSIG',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[report_JAGSIG] 
	@UserID INT
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
	02      ::       17/05/2024     Partha  Filter by Hospital TFS1811
******************************************************************************************************************/
BEGIN
	DECLARE @ProcedureTypeId INT
	SET @ProcedureTypeId = 4

	DECLARE @FromDate as Date,
		@ToDate as Date,
		@ConsultantId as int,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)



	SELECT rc.ConsultantID , con.Title + ' ' + con.Forename + ' ' + con.Surname AS Endoscopist, rc.AnonimizedID
	INTO #Consultants
	FROM ERS_ReportConsultants rc
	JOIN ERS_Users con on rc.ConsultantID = con.UserID 
	WHERE rc.UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT  con.AnonimizedID AS AnonimizedID
				, con.Endoscopist as Endoscopist1
				, con.ConsultantId AS ReportID
				, con.Endoscopist AS Consultant
				, COUNT(DISTINCT p.ProcedureId) AS NumberOfProcedures

			, ISNULL(COUNT(DISTINCT CASE WHEN e.ListOrderBy <= 90 THEN s.SiteId END) * 1.0 / NULLIF(COUNT(CASE WHEN e.ListOrderBy <= 90 THEN s.SiteId END), 0),0) AS PolypDetectionRate
			, SUM(CASE WHEN pd.Retreived <> 0 AND pd.Successful <> 0 THEN convert(int,pd.Successful) END) * 1.0 / NULLIF(COUNT(pd.PolypDetailId),0) AS PolypRetrievalRateP
			, (SUM(ple.WithdrawalMins)/COUNT(p.ProcedureId)) AS MeanWithdrawalTime
			,COUNT(DISTINCT CASE WHEN ISNULL(ple.RetroflectionPerformed, 0) = 1 THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS RectalRetoversionRateP				
			,COUNT(DISTINCT CASE WHEN ISNULL(ple.RectalExamPerformed, 0) = 1 THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS DigiRectalExaminationP
			, COUNT(DISTINCT CASE WHEN LOWER(e.NedTerm) = 'splenic flexure' THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT p.ProcedureId), 0) AS SplenicFlexureIntubationRate
			, COUNT(DISTINCT CASE WHEN LOWER(e.NedTerm) = 'descending' THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT p.ProcedureId), 0) AS DescendingIntubationRate 
			, COUNT(DISTINCT CASE WHEN eds.NEDTerm IN ('Moderate','Severe') THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS ComfortLevelModerateSevereDiscomfort
			, COUNT(DISTINCT CASE WHEN eds.NEDTerm IN ('Moderate','Severe') THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS ComfortLevelModerateSevereDiscomfortNurse
			, COUNT(DISTINCT CASE WHEN tl.Region NOT IN ('Rectum', 'Caecum') AND tl.TattooedId IN (2,3) THEN tl.RowId END)  * 1.0 / NULLIF(COUNT(DISTINCT tl.RowId),0) AS TattooingOfAllLesionsP
			, COUNT(DISTINCT dbo.DiarroheaBiopsies(p.ProcedureId)) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS DiagnosticRectalBiopsiesForUnexplainedDiarrohea
			, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Midazolam', 0.5, 10.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianSedationRateLT70Years_Midazolam
			, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Pethidine', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateLT70Years_Pethidine
			, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Fentanyl', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateLT70Years_Fentanyl
			, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Midazolam', 0.5, 10.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianSedationRateGE70Years_Midazolam
			, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Pethidine', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateGE70Years_Pethidine
			, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Fentanyl', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS MedianAnalgesiaRateGE70Years_Fentanyl
			/*NO SEDATION*/
			, COUNT(distinct prof.ProcedureId) * 1.0 / NULLIF(COUNT( distinct p.procedureId), 0) as PropofolP
						, COUNT(DISTINCT CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null THEN P.ProcedureId END) 
			* 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN dru.GeneralAnaesthetic is null then P.ProcedureId END), 0) AS NoSedationP		
			--/* GTRecommededDose */
			, COUNT(DISTINCT CASE 
									WHEN (
											(P.Endoscopist1 = con.ConsultantId OR P.Endoscopist2 = con.ConsultantId) AND 
											(
												((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 < 70 AND (
													(	(dru.Pethidine > 50) OR
														(dru.midazolam > 5) OR
														(dru.Fentanyl > 100))
													)
												) OR 
												(	
													((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 >= 70 AND (
														(dru.Pethidine > 25) OR
														(dru.midazolam > 2.5) OR
														(dru.Fentanyl > 50))
													)	
												)
											)
										) THEN P.ProcedureId
								END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0) AS GTRecommededDose

			

	FROM #Consultants con
	JOIN ERS_Procedures p ON (con.ConsultantId = p.Endoscopist1 or (con.ConsultantId = p.Endoscopist2 and P.Endo2Role in (2, 3)))
	JOIN ERS_Patients pat on p.PatientId = pat.PatientId
	LEFT JOIN ERS_UpperGIPremedication prof on p.ProcedureId = prof.ProcedureId AND prof.DrugName = 'propofol' AND prof.Dose > 0
	LEFT JOIN ERS_UpperGIPremedication midazolam on p.ProcedureId = midazolam.ProcedureId AND midazolam.DrugName = 'midazolam'
	LEFT JOIN fw_ERS_Drugs as dru on P.ProcedureID = dru.ProcId
	LEFT JOIN ERS_ProcedureLowerExtent ple ON ple.ProcedureId = p.ProcedureId AND ple.EndoscopistId = CASE WHEN p.Endoscopist2 = con.ConsultantId AND p.Endo2Role IN (2,3) THEN con.ConsultantId ELSE ple.EndoscopistId END
	LEFT JOIN ERS_Extent e ON e.UniqueId = ple.ExtentId
	LEFT JOIN ERS_ExtentProcedureTypes ept ON ept.ExtentId = e.UniqueId AND ept.ProcedureTypeId = 3
	LEFT JOIN dbo.ERS_ProcedureDiscomfortScore epds ON p.ProcedureId = epds.ProcedureId
	LEFT JOIN dbo.ERS_DiscomfortScores eds ON epds.DiscomfortScoreId = eds.UniqueId
	LEFT JOIN ERS_ProcedureIndications pri ON pri.ProcedureId = p.ProcedureId
	LEFT JOIN ERS_Indications i ON i.UniqueId = pri.IndicationId
	LEFT JOIN ERS_Sites s ON s.ProcedureId = p.ProcedureId
	LEFT JOIN (SELECT S.ProcedureId, PolypDetailId, Retreived, Successful, Size, TattooedId, r.Region, s.SiteId
				FROM ERS_CommonAbnoPolypDetails pd 
					INNER JOIN ERS_Sites s ON pd.SiteId = s.SiteId 
					INNER JOIN ERS_PolypTypes pt ON pt.UniqueId = pd.PolypTypeId 
					INNER JOIN ERS_Regions r ON r.RegionId = s.RegionId
				WHERE LOWER(pt.[Description]) IN ('sessile','pedunculated','pseudo')) pd ON pd.ProcedureId = p.ProcedureId
	LEFT JOIN dbo.fw_TattooedLesions tl ON tl.SiteId = s.SiteId
	WHERE p.ProcedureType = @ProcedureTypeId
		and p.ProcedureCompleted = 1
		and p.IsActive = 1
		and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
		AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
		--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
		--MH added on 31 Mar 2022
		and IsNull(p.DNA,0) = 0
	GROUP BY con.Endoscopist, con.ConsultantId, con.AnonimizedID--, p.ProcedureId
	HAVING COUNT(DISTINCT p.ProcedureId) >= 0
	ORDER BY con.AnonimizedID
END

GO


------
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	3981 4080 4042
-- Description of change
-- Add OperatingHospitalList in this [fw_ReportFilter] view 
------------------------------------------------------------------------------------------------------------------------
GO
ALTER VIEW [dbo].[fw_ReportFilter]
AS
SELECT        UserID, ReportDate, FromDate, ToDate, Anonymise, TypesOfEndoscopists, HideSuppressed, TrustId ,OperatingHospitalList

FROM            dbo.ERS_ReportFilter

GO
GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	3981 4080 4042
-- Description of change
-- Add Refferer/Service Provider/Category
-- Add Procedure Satrt time and DOB in dd/mm/yyyy format 
------------------------------------------------------------------------------------------------------------------------
GO

EXEC dbo.DropIfExist @ObjectName = 'fnGetProviderName',      -- varchar(100)
                     @ObjectTypePrefix = 'F' -- varchar(5)
GO
Create FUNCTION [dbo].[fnGetProviderName]
(
	-- Add the parameters for the function here
	@ProviderId INT
)
RETURNS NVARCHAR(255)
AS
BEGIN

RETURN (SELECT P.Description FROM  dbo.ERS_ProviderOrganisation P
WHERE uniqueId = @ProviderId)
END


GO
EXEC dbo.DropIfExist @ObjectName = 'fnGetRefferNameName',      -- varchar(100)
                     @ObjectTypePrefix = 'F' -- varchar(5)
GO
Create FUNCTION [dbo].[fnGetRefferNameName]
(
	-- Add the parameters for the function here
	@RefferTypeIDId INT
)
RETURNS NVARCHAR(255)
AS
BEGIN

RETURN (SELECT R.Description FROM  dbo.ERS_ReferrerTypes R
WHERE uniqueId = @RefferTypeIDId)
END
GO
EXEC dbo.DropIfExist @ObjectName = 'fnGetCategoryName',      -- varchar(100)
                     @ObjectTypePrefix = 'F' -- varchar(5)
GO
Create FUNCTION [dbo].[fnGetCategoryName]
(
	-- Add the parameters for the function here
	@CategoryId INT
)
RETURNS NVARCHAR(255)
AS
BEGIN

RETURN (SELECT U.Description FROM  dbo.ERS_UrgencyTypes U
WHERE uniqueId = @CategoryId)
END

GO

EXEC dbo.DropIfExist @ObjectName = 'AuditProcedureDetails',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
Create Procedure [dbo].[AuditProcedureDetails]
	@UserId int
AS
/*
--	Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
						:		11 May 2022 SG added Health Service Number formatting
						:		16 Jun 2022 MH removed inner join with ERS_UpperGIIndications, used left outer instead TFS 2173
						:		29 Jun 2022	MH added additional Therapeutic carried out, Complications, Adverse Events columns
						:		01 MAY 2024  Add Refferer/Service Provider/Category TFS item 3981/4080
						:		01 MAY 2024  Add Procedure Satrt time and DOB in dd/mm/yyyy format  TFS item 3981/4082
						:       17/05/2024     Partha  Filter by Hospital TFS1811
						:       30/05/2024   Partha Add Procedure End Time TFS 3470/TFS 4042
						
*/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

Declare @tableVarTherapeutics Table(
ProcedureId Int Not null,
TherapeuticProcedures varchar(4000) null
)
Insert into @tableVarTherapeutics(ProcedureId,TherapeuticProcedures)
select S.ProcedureId,
TherapeuticProcedures = R.Region + ':' + Case When TP.[None] = '1' then 'None'
Else
	Case when Len(Ltrim(Rtrim(Case when TP.YAGLaser = '1' then 'YAG Laser, ' else '' end
	+
	Case When TP.ArgonBeamDiathermy = '1' then 'Argon beam diathermy, ' else '' end
	+
	Case When TP.BalloonDilation = '1' then 'Balloon dilation, ' else '' end
	+ 
	Case When TP.BotoxInjection = '1' then 'Botox injection, ' else '' end
	+
	Case When TP.EndoloopPlacement = '1' then 'Endoloop placement, ' else '' end
	+
	Case when TP.HeatProbe = '1' then 'Heater probe coagulation, ' else '' end
	+
	Case when TP.BicapElectro = '1' then 'Bicap electrocautery, ' else '' end
	+
	Case when TP.Diathermy = '1' then 'Diathermy, ' else '' end
	+
	Case when TP.HotBiopsy = '1' then 'Hot biopsy, ' else '' end
	+
	Case when TP.ForeignBody = '1' then 'Foreign body removal, ' else '' end
	+
	Case when TP.Injection = '1' then 'Injection therapy, ' else '' end
	+
	Case when TP.Polypectomy = '1' then 'Polypectomy, ' else '' end
	+
	Case when TP.GastrostomyInsertion = '1' then 'Gastrostomy insertion (PEG), ' else '' end
	+
	Case when TP.GastrostomyRemoval = '1' then 'Gastrostomy removal (PEG), ' else '' end
	+
	Case when TP.NGNJTubeInsertion = '1' then 'NG/NJ tube insertion, ' else '' end
	+
	Case when TP.VaricealSclerotherapy = '1' then 'Variceal sclerotherapy, ' else '' end
	+
	Case when TP.VaricealBanding = '1' then 'Variceal banding, ' else '' end
	+
	Case when TP.StentInsertion = '1' then 'Stent insertion, ' else '' end
	+
	Case when TP.StentRemoval = '1' then 'Stent removal, ' else '' end
	+
	Case when TP.Marking = '1' then 'Marking, ' else '' end
	+
	Case when TP.Clip = '1' then 'Clip, ' else '' end
	+
	Case when TP.EndoClot = '1' then 'Endo clot, ' else '' end
	))) > 1 then
	Left(Ltrim(Rtrim(Case when TP.YAGLaser = '1' then 'YAG Laser, ' else '' end
	+
	Case When TP.ArgonBeamDiathermy = '1' then 'Argon beam diathermy, ' else '' end
	+
	Case When TP.BalloonDilation = '1' then 'Balloon dilation, ' else '' end
	+ 
	Case When TP.BotoxInjection = '1' then 'Botox injection, ' else '' end
	+
	Case When TP.EndoloopPlacement = '1' then 'Endoloop placement, ' else '' end
	+
	Case when TP.HeatProbe = '1' then 'Heater probe coagulation, ' else '' end
	+
	Case when TP.BicapElectro = '1' then 'Bicap electrocautery, ' else '' end
	+
	Case when TP.Diathermy = '1' then 'Diathermy, ' else '' end
	+
	Case when TP.HotBiopsy = '1' then 'Hot biopsy, ' else '' end
	+
	Case when TP.ForeignBody = '1' then 'Foreign body removal, ' else '' end
	+
	Case when TP.Injection = '1' then 'Injection therapy, ' else '' end
	+
	Case when TP.Polypectomy = '1' then 'Polypectomy, ' else '' end
	+
	Case when TP.GastrostomyInsertion = '1' then 'Gastrostomy insertion (PEG), ' else '' end
	+
	Case when TP.GastrostomyRemoval = '1' then 'Gastrostomy removal (PEG), ' else '' end
	+
	Case when TP.NGNJTubeInsertion = '1' then 'NG/NJ tube insertion, ' else '' end
	+
	Case when TP.VaricealSclerotherapy = '1' then 'Variceal sclerotherapy, ' else '' end
	+
	Case when TP.VaricealBanding = '1' then 'Variceal banding, ' else '' end
	+
	Case when TP.StentInsertion = '1' then 'Stent insertion, ' else '' end
	+
	Case when TP.StentRemoval = '1' then 'Stent removal, ' else '' end
	+
	Case when TP.Marking = '1' then 'Marking, ' else '' end
	+
	Case when TP.Clip = '1' then 'Clip, ' else '' end
	+
	Case when TP.EndoClot = '1' then 'Endo clot, ' else '' end
	)),Len(Ltrim(Rtrim(Case when TP.YAGLaser = '1' then 'YAG Laser, ' else '' end
	+
	Case When TP.ArgonBeamDiathermy = '1' then 'Argon beam diathermy, ' else '' end
	+
	Case When TP.BalloonDilation = '1' then 'Balloon dilation, ' else '' end
	+ 
	Case When TP.BotoxInjection = '1' then 'Botox injection, ' else '' end
	+
	Case When TP.EndoloopPlacement = '1' then 'Endoloop placement, ' else '' end
	+
	Case when TP.HeatProbe = '1' then 'Heater probe coagulation, ' else '' end
	+
	Case when TP.BicapElectro = '1' then 'Bicap electrocautery, ' else '' end
	+
	Case when TP.Diathermy = '1' then 'Diathermy, ' else '' end
	+
	Case when TP.HotBiopsy = '1' then 'Hot biopsy, ' else '' end
	+
	Case when TP.ForeignBody = '1' then 'Foreign body removal, ' else '' end
	+
	Case when TP.Injection = '1' then 'Injection therapy, ' else '' end
	+
	Case when TP.Polypectomy = '1' then 'Polypectomy, ' else '' end
	+
	Case when TP.GastrostomyInsertion = '1' then 'Gastrostomy insertion (PEG), ' else '' end
	+
	Case when TP.GastrostomyRemoval = '1' then 'Gastrostomy removal (PEG), ' else '' end
	+
	Case when TP.NGNJTubeInsertion = '1' then 'NG/NJ tube insertion, ' else '' end
	+
	Case when TP.VaricealSclerotherapy = '1' then 'Variceal sclerotherapy, ' else '' end
	+
	Case when TP.VaricealBanding = '1' then 'Variceal banding, ' else '' end
	+
	Case when TP.StentInsertion = '1' then 'Stent insertion, ' else '' end
	+
	Case when TP.StentRemoval = '1' then 'Stent removal, ' else '' end
	+
	Case when TP.Marking = '1' then 'Marking, ' else '' end
	+
	Case when TP.Clip = '1' then 'Clip, ' else '' end
	+
	Case when TP.EndoClot = '1' then 'Endo clot, ' else '' end
	)))-1)
	else '' end
end
from
	ERS_UpperGITherapeutics TP
	inner join ERS_Sites S on TP.SiteId = S.SiteId
	Inner Join ERS_Regions R on S.RegionId = R.RegionId

Select p.ProcedureId 
		, pat.Forename1 as Forename
		, pat.Surname as Surname
		, dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHS number'
		, pat.HospitalNumber as 'Case note number'
		, convert(varchar(14),pat.DateOfBirth,106) as DOB
		, oh.HospitalName as 'Operating hospital'
		, gt.Title as Sex
		, pat.Postcode as 'Patients postcode'
		, pt.ProcedureType as 'Procedure name'
		,case when p.providerTypeId =1 then dbo.fnGetProviderName(p.providerTypeId) else p.ProviderOther end as 'Provider'
		,case when p.ReferrerType =1 then dbo.fnGetRefferNameName(p.ReferrerType) else p.ReferrerTypeOther end as 'Referrer'
		,dbo.fnGetCategoryName(p.CategoryListId ) as 'Category'
		,ISNULL(p.StartDateTime, p.ModifiedOn)  as 'Procedure start time'
		,p.ENDDateTime  as 'Procedure End time'
		, case when thera.procedureId is null then 'Diagnostic' else 'Therapeutic' end as 'Therapeutic or diagnostic'
		, dbo.fnGetAgeAtDate(pat.DateOfBirth, p.CreatedOn) as 'Age at procedure'
		, case when p.PatientStatus = (Select ListItemNo from ERS_Lists where ListDescription = 'Patient Status' and ListItemText = 'Inpatient') then 1 else null end as 'In patient'
		, case when p.PatientStatus = (Select ListItemNo from ERS_Lists where ListDescription = 'Patient Status' and ListItemText = 'Outpatient') then 1 else null end as 'Out patient'
		, case when p.PatientStatus = (Select ListItemNo from ERS_Lists where ListDescription = 'Patient Status' and ListItemText = 'Day Patient') then 1 else null end as 'Day patient'
		, case when p.PatientType = (Select ListItemNo from ERS_Lists where ListDescription = 'Patient Type' and ListItemText = 'NHS') then 1 else null end as 'NHS'
		, case when p.PatientType = (Select ListItemNo from ERS_Lists where ListDescription = 'Patient Type' and ListItemText = 'Private') then 1 else null end as 'Private'
		, ListCons.Surname + ', ' + ListCons.Forename as 'List consultant'
		, Endo1.Surname + ', ' + Endo1.Forename as 'Endoscopist 1'
		, Endo2.Surname + ', ' + Endo2.Forename as 'Endoscopist 2'
		, pr.PP_Indic as Indications
		, ind.ASAStatus as 'ASA status'
		, case fu.EvidenceOfCancerIdentified when 1 then 'Yes' 
											 When 2 then 'No'
											 When 3 then 'Unknown'
											 else '' end as 'Evidence of cancer'
		, DrugList as Drugs
		, d.SessileExcised as 'Sessile ployps excised'
		, d.SessileToLabs as 'Sessile ployps sent to lab'
		, d.PedunculatedExcised as 'Pedunculated ployps excised'
		, d.PedunculatedToLabs as 'Pedunculated ployps sent to lab'
		, d.SubmucosalExcised as 'Submucosal ployps excised'
		, d.SubmucosalToLabs as 'Submucosal ployps sent to lab'
		, d.PseudopolypsExcised as 'Pseudo ployps excised'
		, d.PseudopolypsToLabs as 'Pseudo ployps sent to lab'
		, d.BiopsyQtyHistology as 'Bx to histology'
		, CASE WHEN ISNULL(CEOI.NED_TimeToCaecumMin, 0) = 0 
			THEN CASE WHEN ISNULL(CEOI.TimeToCaecumMin, 0) = 0 
				THEN CASE WHEN ISNULL(CEOI.TimeToCaecumMin_Photo, 0) = 0 
					THEN 0
					ELSE CEOI.TimeToCaecumMin_Photo + CASE WHEN ISNULL(CEOI.TimeToCaecumSec_Photo, 0) >= 30 THEN 1 ELSE 0 END
					END
				ELSE 	CEOI.TimeToCaecumMin + CASE WHEN ISNULL(CEOI.TimeToCaecumSec, 0) >= 30 THEN 1 ELSE 0 END
				END
			ELSE	CEOI.NED_TimeToCaecumMin + CASE WHEN ISNULL(CEOI.NED_TimeToCaecumSec, 0) >= 30 THEN 1 ELSE 0 END
		   END as 'Time to caecum (lower only)'		
		 , CASE WHEN ISNULL(CEOI.NED_TimeForWithdrawalMin, 0) = 0 
			THEN CASE WHEN ISNULL(CEOI.TimeForWithdrawalMin, 0) = 0 
				THEN CASE WHEN ISNULL(CEOI.TimeForWithdrawalMin_Photo, 0) = 0 
					THEN 0
					ELSE CEOI.TimeForWithdrawalMin_Photo + CASE WHEN ISNULL(CEOI.TimeForWithdrawalSec_Photo, 0) >= 30 THEN 1 ELSE 0 END
					END
				ELSE 	CEOI.TimeForWithdrawalMin + CASE WHEN ISNULL(CEOI.TimeForWithdrawalSec, 0) >= 30 THEN 1 ELSE 0 END
				END
			ELSE	CEOI.NED_TimeForWithdrawalMin + CASE WHEN ISNULL(CEOI.NED_TimeForWithdrawalSec, 0) >= 30 THEN 1 ELSE 0 END
		  END as 'Time for withdrawal (lower only)'
	    , qa.PatDiscomfortEndo as 'Endoscopists patient comfort score'
	    , qa.PatDiscomfortNurse as 'Nurse patient comfort score'
	    , qa.PatDiscomfortPatient as 'patients own comfort score'
		, case qa.PatSedation	when 0 then 'Not completed' 
								when 1 then 'Not recorded' 
								when 2 then 'Awake' 
								when 3 then 'Drowsy' 
								when 4 then 'Asleep but responding to name' 
								when 5 then 'Asleep but responding to touch' 
								when 6 then 'Asleep but unresponsive' 
								else 'Unknown' end as 'Patient sedation'
		, '"'+pr.pp_AdviceAndComments+'"'  as 'Advice and comments'
		, pr.PP_Followup as 'Follow up'
		, pr.PP_Diagnoses as Diagnoses
		,UPQA.AdverseEvents
		,UPQA.Complications
		,Therap.TherapeuticProcedures
from ERS_Procedures p (nolock)
join ERS_ReportConsultants rc (nolock) on p.Endoscopist1 = rc.ConsultantID 
join ERS_Patients pat (nolock) on p.PatientId = pat.PatientId 
join ERS_OperatingHospitals (nolock) oh on p.OperatingHospitalID = oh.OperatingHospitalId 
left outer join ERS_GenderTypes (nolock) gt on pat.GenderId = gt.GenderId 
join ERS_ProcedureTypes (nolock) pt on P.ProcedureType = pt.ProcedureTypeId 
left outer join (Select distinct s.ProcedureId 
			from ERS_Sites (nolock) s  
			left join ERS_UpperGITherapeutics (nolock) t on s.siteId = t.SiteId
			left join ERS_ERCPTherapeutics (nolock) ercpt on s.siteId = ercpt.SiteId
			where t.siteid is not null or ercpt.siteid is not null) thera on p.ProcedureId = thera.ProcedureId
join ERS_Users ListCons (nolock) on p.ListConsultant = ListCons.UserID
join ERS_Users Endo1 (nolock) on p.Endoscopist1 = Endo1.UserID
left outer join ERS_Users Endo2 (nolock) on p.Endoscopist2 = Endo2.UserID
join ERS_ProceduresReporting pr (nolock) on p.ProcedureId = pr.ProcedureId 
left outer join ERS_UpperGIIndications ind (nolock) on p.ProcedureId = ind.ProcedureId 
left outer join ERS_UpperGIFollowUp fu (nolock) on p.ProcedureId = fu.ProcedureId 
left outer join 
(
Select distinct d.ProcedureId, STUFF(( Select ', ' + drugconcat.DrugName + ' - ' + convert(varchar, drugconcat.Dose) + drugconcat.Units
                FROM ERS_UpperGIPremedication drugconcat
				where drugconcat.ProcedureId = d.ProcedureId
              FOR
                XML PATH('')
              ), 1, 1, '') AS DrugList
from ERS_UpperGIPremedication d) Drugs on Drugs.ProcedureId = p.ProcedureId
Left outer join (Select s.ProcedureId 
					, isnull(sum(l.SessileExcised), 0) + isnull(SUM(ap.SessileNumExcised), 0) as SessileExcised
					, isnull(sum(l.SessileToLabs), 0) + isnull(SUM(ap.SessileNumToLabs), 0) as SessileToLabs
					, isnull(sum(l.PedunculatedExcised), 0) + isnull(SUM(ap.PedunculatedNumExcised), 0) as PedunculatedExcised
					, isnull(sum(l.PedunculatedToLabs), 0) + isnull(SUM(ap.PedunculatedNumToLabs), 0) as PedunculatedToLabs
					, isnull(SUM(ap.SubmucosalNumExcised), 0) as SubmucosalExcised
					, isnull(SUM(ap.SubmucosalNumToLabs), 0) as SubmucosalToLabs
					, isnull(SUM(l.PseudopolypsExcised), 0) as PseudopolypsExcised
					, isnull(SUM(l.PseudopolypsToLabs), 0) as PseudopolypsToLabs
					, ISNULL(max(convert(int, sp.BrushCytology)), 0) as BrushCytology
					, ISNULL(sum(sp.BiopsyQtyHistology), 0) as BiopsyQtyHistology
					, ISNULL(sum(sp.BiopsyQtyMicrobiology), 0) as BiopsyQtyMicrobiology
					, ISNULL(sum(sp.BiopsyQtyVirology), 0) as BiopsyQtyVirology
					, ISNULL(max(convert(int, sp.HotBiopsy)), 0) as HotBiopsy
				from ERS_Sites s  (nolock)
				left outer join ERS_ColonAbnoLesions l (nolock) on s.SiteId = l.SiteId 
				left outer join ERS_UpperGIAbnoPolyps ap (nolock) on s.SiteId = ap.SiteId 
				left outer join ERS_UpperGISpecimens sp (nolock) on s.SiteId = sp.SiteId 
				Group by s.ProcedureId ) d on p.ProcedureId = d.ProcedureId 
left outer join ERS_ColonExtentOfIntubation CEOI (nolock) on p.ProcedureId = CEOI.ProcedureId 
left outer join ERS_UpperGIQA (nolock) qa on p.ProcedureId = qa.ProcedureId 
Left outer Join (select 
ProcedureId, AdverseEvents = Case When AdverseEventsNone = '1' then 'None'
Else
	Case when Len(Ltrim(Rtrim(Case when ConsentSignedInRoom = '1' then 'Consent signed in room, ' else '' end
	+
	Case When UnplannedAdmission = '1' then 'Unplanned Admisison, ' else '' end
	+
	Case When O2Desaturation = '1' then 'O2 Desaturation, ' else '' end
	+ 
	Case When WithdrawalOfConsent = '1' then 'Withdrawal of consent, ' else '' end
	+
	Case When UnsupervisedTrainee = '1' then 'Unsupervised Trainee, ' else '' end
	+
	Case when Ventilation = '1' then 'Ventilation, ' else '' end
	))) > 1 then
	Left(Ltrim(Rtrim(Case when ConsentSignedInRoom = '1' then 'Consent signed in room, ' else '' end
	+
	Case When UnplannedAdmission = '1' then 'Unplanned Admisison, ' else '' end
	+
	Case When O2Desaturation = '1' then 'O2 Desaturation, ' else '' end
	+ 
	Case When WithdrawalOfConsent = '1' then 'Withdrawal of consent, ' else '' end
	+
	Case When UnsupervisedTrainee = '1' then 'Unsupervised Trainee, ' else '' end
	+
	Case when Ventilation = '1' then 'Ventilation, ' else '' end
	)),Len(Ltrim(Rtrim(Case when ConsentSignedInRoom = '1' then 'Consent signed in room, ' else '' end
	+
	Case When UnplannedAdmission = '1' then 'Unplanned Admisison, ' else '' end
	+
	Case When O2Desaturation = '1' then 'O2 Desaturation, ' else '' end
	+ 
	Case When WithdrawalOfConsent = '1' then 'Withdrawal of consent, ' else '' end
	+
	Case When UnsupervisedTrainee = '1' then 'Unsupervised Trainee, ' else '' end
	+
	Case when Ventilation = '1' then 'Ventilation, ' else '' end
	)))-1)
	else '' end
end
,
Complications = Case When ComplicationsNone = '1' then 'None'
Else
	Case when Len(Ltrim(Rtrim(Case when PoorlyTolerated = '1' then 'Poorly tolerated, ' else '' end
	+
	Case When PatientDiscomfort = '1' then 'Patient discomfort, ' else '' end
	+
	Case When PatientDistress = '1' then 'Patient distress, ' else '' end
	+ 
	Case When InjuryToMouth = '1' then 'Injury to mouth/teeth, ' else '' end
	+
	Case When DifficultIntubation = '1' then 'Difficult intubation, ' else '' end
	+
	Case when Death = '1' then 'Death, ' else '' end
	+
	Case when Perforation = '1' then 'Perforation : '+ IsNull(PerforationText,'') + ', ' else '' end
	+
	Case when DamageToScope = '1' then 'Damaged to scope, ' else '' end
	+
	Case when GastricContentsAspiration = '1' then 'Gastric contents aspiration, ' else '' end
	+
	Case when ShockHypotension = '1' then 'Shock/hypotension, ' else '' end
	+
	Case when Haemorrhage = '1' then 'Haemorrhage, ' else '' end
	+
	Case when SignificantHaemorrhage = '1' then 'Significant Haemorrhage, ' else '' end
	+
	Case when Hypoxia = '1' then 'Hypoxia, ' else '' end
	+
	Case when RespiratoryDepression = '1' then 'Respiratory depression, ' else '' end
	+
	Case when RespiratoryArrest = '1' then 'Respiratory arrest requiring immediate action, ' else '' end
	+
	Case when CardiacArrest = '1' then 'Cardiac arrest, ' else '' end
	+
	Case when CardiacArrythmia = '1' then 'Cardiac arrhythmia, ' else '' end
	+
	Case when Len(IsNull(ComplicationsOtherText,'')) > 1 then 'Other complications:' + ComplicationsOtherText else '' end
	+
	Case when Len(IsNull(TechnicalFailure,'')) > 1 then 'Technical failure:' + TechnicalFailure else '' end
	))) > 1 then
	Left(Ltrim(Rtrim(Case when PoorlyTolerated = '1' then 'Poorly tolerated, ' else '' end
	+
	Case When PatientDiscomfort = '1' then 'Patient discomfort, ' else '' end
	+
	Case When PatientDistress = '1' then 'Patient distress, ' else '' end
	+ 
	Case When InjuryToMouth = '1' then 'Injury to mouth/teeth, ' else '' end
	+
	Case When DifficultIntubation = '1' then 'Difficult intubation, ' else '' end
	+
	Case when Death = '1' then 'Death, ' else '' end
	+
	Case when Perforation = '1' then 'Perforation : '+ IsNull(PerforationText,'') + ', ' else '' end
	+
	Case when DamageToScope = '1' then 'Damaged to scope, ' else '' end
	+
	Case when GastricContentsAspiration = '1' then 'Gastric contents aspiration, ' else '' end
	+
	Case when ShockHypotension = '1' then 'Shock/hypotension, ' else '' end
	+
	Case when Haemorrhage = '1' then 'Haemorrhage, ' else '' end
	+
	Case when SignificantHaemorrhage = '1' then 'Significant Haemorrhage, ' else '' end
	+
	Case when Hypoxia = '1' then 'Hypoxia, ' else '' end
	+
	Case when RespiratoryDepression = '1' then 'Respiratory depression, ' else '' end
	+
	Case when RespiratoryArrest = '1' then 'Respiratory arrest requiring immediate action, ' else '' end
	+
	Case when CardiacArrest = '1' then 'Cardiac arrest, ' else '' end
	+
	Case when CardiacArrythmia = '1' then 'Cardiac arrhythmia, ' else '' end
	+
	Case when Len(IsNull(ComplicationsOtherText,'')) > 1 then 'Other complications:' + ComplicationsOtherText else '' end
	+
	Case when Len(IsNull(TechnicalFailure,'')) > 1 then 'Technical failure:' + TechnicalFailure else '' end
	)),Len(Ltrim(Rtrim(Case when PoorlyTolerated = '1' then 'Poorly tolerated, ' else '' end
	+
	Case When PatientDiscomfort = '1' then 'Patient discomfort, ' else '' end
	+
	Case When PatientDistress = '1' then 'Patient distress, ' else '' end
	+ 
	Case When InjuryToMouth = '1' then 'Injury to mouth/teeth, ' else '' end
	+
	Case When DifficultIntubation = '1' then 'Difficult intubation, ' else '' end
	+
	Case when Death = '1' then 'Death, ' else '' end
	+
	Case when Perforation = '1' then 'Perforation : '+ IsNull(PerforationText,'') + ', ' else '' end
	+
	Case when DamageToScope = '1' then 'Damaged to scope, ' else '' end
	+
	Case when GastricContentsAspiration = '1' then 'Gastric contents aspiration, ' else '' end
	+
	Case when ShockHypotension = '1' then 'Shock/hypotension, ' else '' end
	+
	Case when Haemorrhage = '1' then 'Haemorrhage, ' else '' end
	+
	Case when SignificantHaemorrhage = '1' then 'Significant Haemorrhage, ' else '' end
	+
	Case when Hypoxia = '1' then 'Hypoxia, ' else '' end
	+
	Case when RespiratoryDepression = '1' then 'Respiratory depression, ' else '' end
	+
	Case when RespiratoryArrest = '1' then 'Respiratory arrest requiring immediate action, ' else '' end
	+
	Case when CardiacArrest = '1' then 'Cardiac arrest, ' else '' end
	+
	Case when CardiacArrythmia = '1' then 'Cardiac arrhythmia, ' else '' end
	+
	Case when Len(IsNull(ComplicationsOtherText,'')) > 1 then 'Other complications:' + ComplicationsOtherText else '' end
	+
	Case when Len(IsNull(TechnicalFailure,'')) > 1 then 'Technical failure:' + TechnicalFailure else '' end
	)))-1)
	else '' end
end
from ERS_UpperGIQA) UPQA on UPQA.ProcedureId = P.ProcedureId
left outer join 
(
Select distinct d.ProcedureId, STUFF(( Select '; ' + therapconcat.TherapeuticProcedures
                FROM @tableVarTherapeutics therapconcat
				where therapconcat.ProcedureId = d.ProcedureId
              FOR
                XML PATH('')
              ), 1, 1, '') AS TherapeuticProcedures
from @tableVarTherapeutics d) Therap on Therap.ProcedureId = p.ProcedureId

where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	--MH added on 10 Mar 2022
	and IsNull(p.DNA,0) = 0
order by pt.ProcedureType, p.CreatedOn 

end



GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	3847 2070 
-- Description of change
--Fix duplicate row and Add Date of Birts and Age
------------------------------------------------------------------------------------------------------------------------
GO

/****** Object:  StoredProcedure [dbo].[report_JAGSIG_DrillDown]    Script Date: 24/04/2024 12:33:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
EXEC dbo.DropIfExist @ObjectName = 'report_JAGSIG_DrillDown',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
CREATE  Procedure [dbo].[report_JAGSIG_DrillDown] 
	@UserId int,
	@AnonomizedId int
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
	02		:		01 Aug 2022		Adrian Rename NHSNo Column to match custom Health Service
    03		:		24 Apr 2024		Partha fix duplicate row issue  TFS 3847
	04		:		26 APR 2024		Partha Add Date of Birth and Age TFS2070
	05      :       17/05/2024     Partha  Filter by Hospital TFS1811
	06      :       10/06/2024     Partha  Show Endo1 and Endo2 TFS2176
******************************************************************************************************************/
BEGIN

	DECLARE @ConsultantId as int,
			@FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select @ConsultantId = ConsultantID 
	from ERS_ReportConsultants
	where AnonimizedID = @AnonomizedId
	and UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Forename1 + ' '+ pat.Surname as Patient, 
			pat.HospitalNumber as 'Case No.',
			convert(varchar(14),pat.DateOfBirth,106) as 'DOB.',
			datediff(year,pat.DateOfBirth,getdate()) as 'Age',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			ps.PatientStatus as 'Patient Status',
			u1.Surname + ', '+ u1.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			CASE ple.RectalExamPerformed WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' END AS 'Digital rectal examination',
			CASE ple.RetroflectionPerformed WHEN 1 THEN 'Yes' WHEN 0 THEN '0' END AS 'Retroflection',
			e.NEDTerm as 'Extent of Intubation',
			convert(varchar, CASE WHEN LOWER(pd.PolypDescription) = 'pedunculated' THEN pd.Size END)  + ' mm' as 'Largest Pedunculated Polyp',
			convert(varchar, CASE WHEN LOWER(pd.PolypDescription) = 'submucosal' THEN pd.Size END)  + ' mm' as 'Largest Submucosal Polyp',
			convert(varchar, CASE WHEN LOWER(pd.PolypDescription) = 'sessile' THEN pd.Size END)  + ' mm' as 'Largest Sessile Polyp',
			convert(varchar, CASE WHEN LOWER(pd.PolypDescription) = 'pseudo' THEN pd.Size END)  + ' mm' as 'Largest Pseudopolyps',
			ple.WithdrawalMins as 'Withdrawal Time',
			eds.NEDTerm AS 'Comfort Rate',
			ISNULL(dru.midazolam, 0) As 'Midazolam Dose',
			ISNULL(dru.pethidine, 0) As 'Pethidine Dose',
			ISNULL(dru.fentanyl, 0) As 'Fentanyl Dose',
			case when dru.GeneralAnaesthetic is null then 'No' else 'Yes' end  as 'General Anaesthetic',
			CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null then 'No' ELSE 'Yes' END as 'Sedation Used'
	INTO ##ReportTemp
	FROM ERS_Procedures p
		join (select ListItemNo as PatientStatusId, ListItemText as PatientStatus from ERS_Lists where ListDescription = 'Patient Status') ps on p.PatientStatus = ps.PatientStatusId
		join ERS_Users u on (u.UserID = p.Endoscopist1 or (u.UserID = p.Endoscopist2 and P.Endo2Role in (2, 3)))
		join ERS_Patients pat on pat.PatientId = p.PatientId
		Left join ERS_Users u1 (NOLOCK) on u.UserID = p.Endoscopist1
		left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
		LEFT JOIN fw_ERS_Drugs as dru on P.ProcedureId = dru.ProcId
		LEFT JOIN ERS_ProcedureLowerExtent ple ON ple.ProcedureId = p.ProcedureId  AND ple.EndoscopistId = CASE WHEN p.Endoscopist2 = @ConsultantId AND p.Endo2Role IN (2,3) THEN @ConsultantId ELSE ple.EndoscopistId END
		LEFT JOIN ERS_Extent e ON e.UniqueId = ple.ExtentId
		LEFT JOIN ERS_ExtentProcedureTypes ept ON ept.ExtentId = e.UniqueId AND ept.ProcedureTypeId = 3
		LEFT JOIN dbo.ERS_ProcedureDiscomfortScore epds ON p.ProcedureId = epds.ProcedureId
		LEFT JOIN dbo.ERS_DiscomfortScores eds ON epds.DiscomfortScoreId = eds.UniqueId
		--LEFT JOIN ERS_ProcedureIndications pri ON pri.ProcedureId = p.ProcedureId
		--LEFT JOIN ERS_Indications i ON i.UniqueId = pri.IndicationId
		--LEFT JOIN ERS_Sites s ON s.ProcedureId = p.ProcedureId
		LEFT JOIN (SELECT S.ProcedureId, MAX(Size) as Size, s.SiteId, pt.[Description] as PolypDescription
					FROM ERS_CommonAbnoPolypDetails pd 
						INNER JOIN ERS_Sites s ON pd.SiteId = s.SiteId 
						INNER JOIN ERS_PolypTypes pt ON pt.UniqueId = pd.PolypTypeId 
						INNER JOIN ERS_Regions r ON r.RegionId = s.RegionId
					WHERE LOWER(pt.[Description]) IN ('sessile','pedunculated','pseudo', 'submucosal')
					GROUP BY s.ProcedureId, s.SiteId, pt.[Description]) pd ON pd.ProcedureId = p.ProcedureId
				
		--LEFT JOIN dbo.fw_TattooedLesions tl ON tl.SiteId = s.SiteId
	where u.UserID = @ConsultantId
	and p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType = 4
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	--MH added on 31 Mar 2022
	and IsNull(p.DNA,0) = 0
	order by p.ProcedureId
	
	declare @SQL nvarchar(1000)
	set @SQL = 'tempdb.sys.sp_rename N''##ReportTemp.NHSNo'', N''' + @HealthService + ' No'' '
	exec sp_executesql @SQL

	Select * from ##ReportTemp
	drop table ##ReportTemp
END


GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	3475
-- Description of change
--Show Total  and Fiter By Hospital
------------------------------------------------------------------------------------------------------------------------
GO
delete ERS_AuditReports  where AuditReportStoredProcedure= 'auditAdenomaPolypDetectionRateDetail'
GO
if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='auditAdenomaPolypDetectionRateDetail')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure) values ('GRS C Adenoma / Polyp Detection Rate Detail', 'auditAdenomaPolypDetectionRateDetail')
GO
EXEC dbo.DropIfExist @ObjectName = 'auditAdenomaPolypDetectionRateDetail',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
Create  Procedure [dbo].[auditAdenomaPolypDetectionRateDetail]
	@UserId int
AS
/*
--	Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
						:		11 May 2022 SG added Health Service Number formatting
						:       07 May 2024 TFS 3475 Show Total
					    :       17/05/2024     Partha  Filter by Hospital TFS1811
*/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@adenomatous int,
			@NonAdenomatous int,
			@resultAwait int,
			@resultTotal int,
			@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHS number', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as 'Procedure date',
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at procedure',
			pt.ProcedureType as 'Procedure type',
			u.Surname + ', '+ u.Forename as 'Endoscopist',
			count(p.procedureId) as 'Polyps samples taken',
			sum(CASE WHEN pr.AdenomaConfirmedHistologically = 1 THEN 1 ELSE 0 END) as 'Polyp samples confirmed as adenomatous',
			SUM(CASE WHEN pr.AdenomaConfirmedHistologically = 0 THEN 1 ELSE 0 END) as 'Polyp samples confirmed as non adenomatous',
			SUM(CASE WHEN pr.AdenomaConfirmedHistologically IS NULL THEN 1 ELSE 0 END) as 'Polyp samples awaiting results'
	into #PlolypSummaryTemp
	FROM ERS_Procedures p
	join ERS_ProcedureTypes pt on p.ProcedureType = pt.ProcedureTypeId 
	join ERS_Patients pat on pat.PatientId = p.PatientId
	join ERS_Users u on u.UserID = p.Endoscopist1
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	left join ERS_UpperGIPathologyResults pr on p.ProcedureId = pr.ProcedureId
	join ERS_Sites s on s.ProcedureId = p.ProcedureId 
	join ERS_UpperGISpecimens  sp on s.SiteId = sp.SiteId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	and rc.UserID = @UserId
	and sp.Polypectomy = 1
	--MH added on 10 Mar 2022
		and IsNull(p.DNA,0) = 0
	Group By  p.procedureId, pat.Surname + ', '+ pat.Forename1, 
			pat.HospitalNumber,
			pat.NHSNo, 
			dbo.fnGender(pat.GenderId), 
			convert(varchar, p.CreatedOn, 106), p.CreatedOn,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000,
			pt.ProcedureType,
			u.Surname + ', '+ u.Forename
	order by p.CreatedOn, pat.Surname + ', '+ pat.Forename1

	
	select 
		@resultTotal=sum(isnull([Polyps samples taken],0)),
		@resultAwait=sum([Polyp samples awaiting results]),
		@adenomatous=sum([Polyp samples confirmed as adenomatous]),
		@NonAdenomatous= sum([Polyp samples confirmed as non adenomatous]) 
	from #PlolypSummaryTemp

	insert into #PlolypSummaryTemp([Procedure type],[Endoscopist],[Polyps samples taken],
	[Polyp samples awaiting results],
	[Polyp samples confirmed as adenomatous],
	[Polyp samples confirmed as non adenomatous])
	Values('',' Department Totals==> ',@resultTotal,@resultAwait,@adenomatous,@NonAdenomatous)

	select * from  #PlolypSummaryTemp
	order by CONVERT(datetime, [Procedure date], 103) ,Patient

	drop table  #PlolypSummaryTemp
END




GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	3474 3145
-- Description of change
--New Report for Failure Report
------------------------------------------------------------------------------------------------------------------------
GO
EXEC dbo.DropIfExist @ObjectName = 'auditOGDDetailedFailure',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

Create  Procedure [dbo].[auditOGDDetailedFailure]
@UserId INT
AS
--/***************************************************************************************/
---- Author				:		Partha created on 25/04/2024 - New Report TFS 3474
-----							Partha 17/05/2024       Filter by Hospital TFS1811

--/**************************************************************************************/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

		Select pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			'Gastroscopy' as 'Procedure Type',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
		  lim.NEDTerm as 'Insertion Limited By',
			 ee.Description 'Failure Reason'
	FROM ERS_Procedures p (NOLOCK)
	join ERS_Users u (NOLOCK) on u.UserID = p.Endoscopist1
	left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
	join ERS_Patients pat (NOLOCK) on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc (NOLOCK) on u.UserID = rc.ConsultantID
	join dbo.ERS_ProcedureUpperExtent ext (NOLOCK) on p.ProcedureId = ext.ProcedureId
	JOIN dbo.ERS_Extent ee ON ext.ExtentId = ee.UniqueId
	LEFT JOIN dbo.ERS_Limitations AS lim (NOLOCK) ON lim.UniqueId = ext.LimitationId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and (ISNULL(lim.NEDTerm, '') != '' or ISNULL(lim.[Description], '') != '')
	and P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	and IsNull(p.DNA,0) = 0
	AND ee.Description in ('intubation failed','abandoned')
	--AND (ext.Abandoned <> 0 OR ext.IntubationFailed <> 0)
	Order By p.CreatedOn

	
END
go

EXEC dbo.DropIfExist @ObjectName = 'auditEUSDetailedFailure',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

Create  Procedure [dbo].[auditEUSDetailedFailure]
@UserId INT
AS
--/***************************************************************************************/
---- Author				:		Partha created on 25/04/2024 - New Report TFS 3145
-----							Partha 17/05/2024       Filter by Hospital TFS1811

--/**************************************************************************************/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			CASE WHEN p.ProcedureType = 6 THEN 'EUS (OGD)' ELSE 'EUS (HPB)' END as 'Procedure Type',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			lim.NEDTerm as 'Insertion Limited By',
			CASE 
				WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 1 THEN 'Abandoned & Intubation failed'
				ELSE 
				CASE 
					WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 0 THEN 'Abandoned' 
					ELSE 
					CASE 
						WHEN ext.Abandoned = 0 AND ext.IntubationFailed = 1 THEN 'Intubation failed'
						ELSE ''
					END
				END
			END AS 'Failure Reason'
	FROM ERS_Procedures p (NOLOCK)
	join ERS_Users u (NOLOCK) on u.UserID = p.Endoscopist1
	left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
	join ERS_Patients pat (NOLOCK) on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc (NOLOCK) on u.UserID = rc.ConsultantID
	join dbo.ERS_ProcedureLowerExtent ext (NOLOCK) on p.ProcedureId = ext.ProcedureId
	LEFT JOIN dbo.ERS_Limitations AS lim (NOLOCK) ON lim.UniqueId = ext.LimitationId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType in (6,7)
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and (ISNULL(lim.NEDTerm, '') != '' or ISNULL(lim.[Description], '') != '')
	and P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	and IsNull(p.DNA,0) = 0
	AND (ext.Abandoned <> 0 OR ext.IntubationFailed <> 0)
	Order By p.CreatedOn
END
go

EXEC dbo.DropIfExist @ObjectName = 'auditERCPDetailedFailure',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

Create  Procedure [dbo].[auditERCPDetailedFailure]
@UserId INT
AS
--/***************************************************************************************/
---- Author				:		Partha created on 25/04/2024 - New Report TFS 3474
-----							Partha 17/05/2024       Filter by Hospital TFS1811

--/**************************************************************************************/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			'ERCP' as 'Procedure Type',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			lim.NEDTerm as 'Insertion Limited By',
			CASE 
				WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 1 THEN 'Abandoned & Intubation failed'
				ELSE 
				CASE 
					WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 0 THEN 'Abandoned' 
					ELSE 
					CASE 
						WHEN ext.Abandoned = 0 AND ext.IntubationFailed = 1 THEN 'Intubation failed'
						ELSE ''
					END
				END
			END AS 'Failure Reason'
	FROM ERS_Procedures p (NOLOCK)
	join ERS_Users u (NOLOCK) on u.UserID = p.Endoscopist1
	left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
	join ERS_Patients pat (NOLOCK) on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc (NOLOCK) on u.UserID = rc.ConsultantID
	join dbo.ERS_ProcedureLowerExtent ext (NOLOCK) on p.ProcedureId = ext.ProcedureId
	LEFT JOIN dbo.ERS_Limitations AS lim (NOLOCK) ON lim.UniqueId = ext.LimitationId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType = 2
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and (ISNULL(lim.NEDTerm, '') != '' or ISNULL(lim.[Description], '') != '')
	and P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	and IsNull(p.DNA,0) = 0
	AND (ext.Abandoned <> 0 OR ext.IntubationFailed <> 0)
	Order By p.CreatedOn
END
go

EXEC dbo.DropIfExist @ObjectName = 'auditCystoscopyDetailedFailure',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

Create  Procedure [dbo].[auditCystoscopyDetailedFailure]
@UserId INT
AS
--/***************************************************************************************/
---- Author				:		Partha created on 25/04/2024 - New Report TFS 3474
-----							Partha 17/05/2024       Filter by Hospital TFS1811

--/**************************************************************************************/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			'Cystoscopy' as 'Procedure Type',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			lim.NEDTerm as 'Insertion Limited By',
			CASE 
				WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 1 THEN 'Abandoned & Intubation failed'
				ELSE 
				CASE 
					WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 0 THEN 'Abandoned' 
					ELSE 
					CASE 
						WHEN ext.Abandoned = 0 AND ext.IntubationFailed = 1 THEN 'Intubation failed'
						ELSE ''
					END
				END
			END AS 'Failure Reason'
	FROM ERS_Procedures p (NOLOCK)
	join ERS_Users u (NOLOCK) on u.UserID = p.Endoscopist1
	left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
	join ERS_Patients pat (NOLOCK) on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc (NOLOCK) on u.UserID = rc.ConsultantID
	join dbo.ERS_ProcedureLowerExtent ext (NOLOCK) on p.ProcedureId = ext.ProcedureId
	LEFT JOIN dbo.ERS_Limitations AS lim (NOLOCK) ON lim.UniqueId = ext.LimitationId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType = 13
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and (ISNULL(lim.NEDTerm, '') != '' or ISNULL(lim.[Description], '') != '')
	and P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	and IsNull(p.DNA,0) = 0
	AND (ext.Abandoned <> 0 OR ext.IntubationFailed <> 0)
	Order By p.CreatedOn
END
go

EXEC dbo.DropIfExist @ObjectName = 'auditEBUSDetailedFailure',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

Create  Procedure [dbo].[auditEBUSDetailedFailure]
@UserId INT
AS
--/***************************************************************************************/
---- Author				:		Partha created on 25/04/2024 - New Report TFS 3474
-----							Partha 17/05/2024       Filter by Hospital TFS1811

--/**************************************************************************************/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			'EBUS' as 'Procedure Type',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			lim.NEDTerm as 'Insertion Limited By',
			CASE 
				WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 1 THEN 'Abandoned & Intubation failed'
				ELSE 
				CASE 
					WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 0 THEN 'Abandoned' 
					ELSE 
					CASE 
						WHEN ext.Abandoned = 0 AND ext.IntubationFailed = 1 THEN 'Intubation failed'
						ELSE ''
					END
				END
			END AS 'Failure Reason'
	FROM ERS_Procedures p (NOLOCK)
	join ERS_Users u (NOLOCK) on u.UserID = p.Endoscopist1
	left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
	join ERS_Patients pat (NOLOCK) on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc (NOLOCK) on u.UserID = rc.ConsultantID
	join dbo.ERS_ProcedureLowerExtent ext (NOLOCK) on p.ProcedureId = ext.ProcedureId
	LEFT JOIN dbo.ERS_Limitations AS lim (NOLOCK) ON lim.UniqueId = ext.LimitationId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType = 11
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and (ISNULL(lim.NEDTerm, '') != '' or ISNULL(lim.[Description], '') != '')
	and P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811	
	and IsNull(p.DNA,0) = 0
	AND (ext.Abandoned <> 0 OR ext.IntubationFailed <> 0)
	Order By p.CreatedOn
END
go

EXEC dbo.DropIfExist @ObjectName = 'auditENTDetailedFailure',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

Create  Procedure [dbo].[auditENTDetailedFailure]
@UserId INT
AS
--/***************************************************************************************/
---- Author				:		Partha created on 25/04/2024 - New Report TFS 3474
-----							Partha 17/05/2024       Filter by Hospital TFS1811

--/**************************************************************************************/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			CASE WHEN p.ProcedureType = 8 THEN 'Ent - Antegrade' ELSE 'Ent - Retrograde' END as 'Procedure Type',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			lim.NEDTerm as 'Insertion Limited By',
			CASE 
				WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 1 THEN 'Abandoned & Intubation failed'
				ELSE 
				CASE 
					WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 0 THEN 'Abandoned' 
					ELSE 
					CASE 
						WHEN ext.Abandoned = 0 AND ext.IntubationFailed = 1 THEN 'Intubation failed'
						ELSE ''
					END
				END
			END AS 'Failure Reason'
	FROM ERS_Procedures p (NOLOCK)
	join ERS_Users u (NOLOCK) on u.UserID = p.Endoscopist1
	left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
	join ERS_Patients pat (NOLOCK) on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc (NOLOCK) on u.UserID = rc.ConsultantID
	join dbo.ERS_ProcedureLowerExtent ext (NOLOCK) on p.ProcedureId = ext.ProcedureId
	LEFT JOIN dbo.ERS_Limitations AS lim (NOLOCK) ON lim.UniqueId = ext.LimitationId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType in (8,9)
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and (ISNULL(lim.NEDTerm, '') != '' or ISNULL(lim.[Description], '') != '')
	and P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	and IsNull(p.DNA,0) = 0
	AND (ext.Abandoned <> 0 OR ext.IntubationFailed <> 0)
	Order By p.CreatedOn
END
go

EXEC dbo.DropIfExist @ObjectName = 'auditBronchDetailedFailure',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

Create  Procedure [dbo].[auditBronchDetailedFailure]
@UserId INT
AS
--/***************************************************************************************/
---- Author				:		Partha created on 25/04/2024 - New Report TFS 3474
-----							Partha 17/05/2024       Filter by Hospital TFS1811

--/**************************************************************************************/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			'Bronchoscopy' as 'Procedure Type',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			lim.NEDTerm as 'Insertion Limited By',
			CASE 
				WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 1 THEN 'Abandoned & Intubation failed'
				ELSE 
				CASE 
					WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 0 THEN 'Abandoned' 
					ELSE 
					CASE 
						WHEN ext.Abandoned = 0 AND ext.IntubationFailed = 1 THEN 'Intubation failed'
						ELSE ''
					END
				END
			END AS 'Failure Reason'
	FROM ERS_Procedures p (NOLOCK)
	join ERS_Users u (NOLOCK) on u.UserID = p.Endoscopist1
	left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
	join ERS_Patients pat (NOLOCK) on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc (NOLOCK) on u.UserID = rc.ConsultantID
	join dbo.ERS_ProcedureLowerExtent ext (NOLOCK) on p.ProcedureId = ext.ProcedureId
	LEFT JOIN dbo.ERS_Limitations AS lim (NOLOCK) ON lim.UniqueId = ext.LimitationId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType = 10
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and (ISNULL(lim.NEDTerm, '') != '' or ISNULL(lim.[Description], '') != '')
	and P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	and IsNull(p.DNA,0) = 0
	AND (ext.Abandoned <> 0 OR ext.IntubationFailed <> 0)
	Order By p.CreatedOn
END
go



if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='auditOGDDetailedFailure')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('OGD Detailed Failure', 'auditOGDDetailedFailure')
go

if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='auditEUSDetailedFailure')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('EUS Detailed Failure', 'auditEUSDetailedFailure')
go

if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='auditERCPDetailedFailure')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('ERCP Detailed Failure', 'auditERCPDetailedFailure')
go

if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='auditCystoscopyDetailedFailure')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Cystoscopy Detailed Failure', 'auditCystoscopyDetailedFailure')
go

if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='auditEBUSDetailedFailure')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('EBUS Detailed Failure', 'auditEBUSDetailedFailure')
go

if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='auditBronchDetailedFailure')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Bronch Detailed Failure', 'auditBronchDetailedFailure')
go

if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='auditENTDetailedFailure')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('ENT Detailed Failure', 'auditENTDetailedFailure')
go




GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	2877 2552
-- Description of change
--New Report for Modified Report
------------------------------------------------------------------------------------------------------------------------
GO

EXEC dbo.DropIfExist @ObjectName = 'audit_report_Modified',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
create  PROCEDURE [dbo].[audit_report_Modified] 
	@UserID INT
AS
BEGIN

	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)


	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT rc.ConsultantID , con.Surname + ', ' + con.Forename AS Endoscopist, rc.AnonimizedID
	INTO #Consultants
	FROM ERS_ReportConsultants rc
	JOIN ERS_Users con on rc.ConsultantID = con.UserID 
	WHERE rc.UserID = @UserId

	SELECT  P.ProcedureId ,prt.ProcedureType , 
	pat.Forename1 + ' '+ pat.Surname as Patient, 
	pat.HospitalNumber as 'Hospital Number.',
	Replace(pr.pp_Endos,'<br>',CHAR(13)) as 'Endos',
	pr.pp_Endo1 as 'Endo1',pr.pp_Endo2 as 'Endo2',eop.whenCreated as 'Report Created Date',[dbo].[fnGetUserName](eop.WhocreatedID) as 'Report Created By', p.whenUpdated as 'Procedure Updated Date', [dbo].[fnGetUserName](P.WhoUpdatedId) as 'Procedure Updated By',
	eop.whenUpdated as 'Report Updated Date',[dbo].[fnGetUserName](eop.WhoUpdatedId) as 'Report Updated By',
	case isnull(eop.isdeletion,0) when 1 then 'Yes' else 'No'end  as 'Deleted' 
	from #Consultants con
	JOIN ERS_Procedures p ON con.ConsultantId = p.Endoscopist1
	JOIN ERS_ProceduresReporting PR ON PR.ProcedureId = P.ProcedureId
	JOIN ERS_OCS_Process eop ON PR.ProcedureId =eop.procedureId
	left join ERS_Patients pat on pat.PatientId = p.PatientId
	left join ERS_ProcedureTypes prt on p.ProcedureType=prt.ProcedureTypeId
    WHERE (P.reportUpdated =1 or (P.reportUpdated =0 and eop.WhenUpdated is not null))
	and IsNull(p.DNA,0) = 0
	and p.IsActive = 1
	AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	and cast(isnull(eop.WhenUpdated,eop.WhenCreated) as date) between @FromDate and @ToDate
	order by p.CreatedOn

End 
	

GO

	
	
	if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='audit_report_Modified')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Report Modified', 'audit_report_Modified')

GO



GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	2809
-- Description of change
--Fixed for Suppressed Consultant
------------------------------------------------------------------------------------------------------------------------
GO


ALTER PROCEDURE [dbo].[usp_rep_ConsultantSelectByType]
(
	@ConsultantType AS VARCHAR(20) = 'all'
	, @HideInactiveConsultants AS BIT = 0	-- ## Initially Show all, unless reqested!
	,@operatingHospitalsIds varchar(100)
	,@searchText varchar(100)=''
)
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @Consultant VARCHAR(20) = LOWER(@ConsultantType);
	Declare @searchTextLower VARCHAR(100) = LOWER(isnull(@searchText,''));
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
		    WHERE ((@HideInactiveConsultants= 0 AND 1=1) OR (@HideInactiveConsultants=1 AND U.Suppressed = 0) )
			   and ','+ @operatingHospitalsIds+',' LIKE '%,'+CAST(euoh.OperatingHospitalId AS varchar)+',%'
			  AND ( ISNULL(U.IsListConsultant, 0)	= 1 OR
					ISNULL(U.IsEndoscopist1, 0)		= 1 OR
					ISNULL(U.IsEndoscopist2, 0)		= 1 OR
					ISNULL(U.IsAssistantOrTrainee, 0)=1 OR
					ISNULL(U.IsNurse1, 0)			= 1 OR
					ISNULL(U.IsNurse2, 0)			= 1 
					)
					--And IsNull(U.Suppressed,0) = 0 --MH added on 31 Aug 2022 --Partha Removed 08 May TFS 2809
	)

	Select * 
	from AllConsultants AS Con
	Where 1=1
		AND 
			(
			(@Consultant='all'						AND (1=1)) 	-- Select All Endoscopist/Nurses
				OR
			((@Consultant LIKE '%list%')			AND ( Con.IsListConsultant = 1))
				OR 
			((@Consultant LIKE '%endoscopist1%')	AND ( Con.IsEndoscopist1 = 1))
				OR 
			((@Consultant LIKE '%endoscopist2%')	AND ( Con.IsEndoscopist2 = 1))
				OR
			((@Consultant LIKE '%nurse1%')		AND ( Con.IsNurse1 = 1))
				OR 
			((@Consultant LIKE '%nurse2%')			AND ( Con.IsNurse2 = 1))
				OR 			  
			((@Consultant LIKE '%nurse3')			AND ( Con.IsNurse3 = 1))	
				OR 			  
			((@Consultant LIKE '%nurse4')			AND ( Con.IsNurse4 = 1))	
			)
		  AND ((@searchTextLower ='' and 1=1)  OR (@searchTextLower !='' AND lower(Consultant) like '%'+@searchTextLower+'%'))
	ORDER BY Consultant
	END


GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	2655
-- Description of change
-- NEW report Trainee ENDO
------------------------------------------------------------------------------------------------------------------------
GO

if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='report_TraineeEndoscopist')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Trainee Endoscopist', 'report_TraineeEndoscopist')
GO

EXEC dbo.DropIfExist @ObjectName = 'report_TraineeEndoscopist',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
CREATE PROCEDURE [dbo].[report_TraineeEndoscopist] 
	@UserID INT
AS
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'


		Select  p.ProcedureId 
				, pat.Forename1 as Forename
				, pat.Surname as Surname
				, pat.HospitalNumber as 'Case note number'
				, convert(varchar(14),pat.DateOfBirth,106) as DOB
				, oh.HospitalName as 'Operating hospital'
				, pt.ProcedureType as 'Procedure Type',
				p.NEDExported,
				ISNULL(p.StartDateTime, p.ModifiedOn)  as 'Procedure start time'
				,p.ENDDateTime  as 'Procedure End time'
				, Endo1.Surname + ', ' + Endo1.Forename as 'Endoscopist 1',
				 case p.endo1Role when 2 then 'trainer observed'
								  When 3 Then 'trainer assisted'
								  else ''
								  End as 'Endo1Role'
				, Endo2.Surname + ', ' + Endo2.Forename as 'Endoscopist 2',
				 case p.endo2Role when 2 then 'trainer observed'
								  When 3 Then 'trainer assisted'
								  else ''
								  End as 'Endo1Role',

			  STUFF((SELECT '<br>Submited Date :' + QUOTENAME(Logdate)  + ' Response Date :'+QUOTENAME(NEDWebserviceQueueResponseDate) +' Status '+ QUOTENAME(Status)
							FROM ERS_NEDI2FilesLog el1
							where el1.ProcedureID=p.ProcedureId
							and Status in (4,5,6)
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') 
				,1,1,'') as 'NED Status'
		from ERS_Procedures p (nolock)
		join ERS_ReportConsultants rc (nolock) on p.ListConsultant = rc.ConsultantID 
		join ERS_Patients pat (nolock) on p.PatientId = pat.PatientId 
		join ERS_OperatingHospitals (nolock) oh on p.OperatingHospitalID = oh.OperatingHospitalId 
		join ERS_ProcedureTypes (nolock) pt on P.ProcedureType = pt.ProcedureTypeId 
		join ERS_Users Endo1 (nolock) on p.Endoscopist1 = Endo1.UserID
		left outer join ERS_Users Endo2 (nolock) on p.Endoscopist2 = Endo2.UserID

		where p.ProcedureCompleted = 1
			and p.IsActive = 1
			and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
			and rc.UserID = @UserId
			AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
			and IsNull(p.DNA,0) = 0
			and  (p.Endo1Role  in (2,3) or p.Endo2Role in (2,3))
		order by p.CreatedOn 

END 
GO

GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	2655
-- Description of change
-- NEW report Main ENDO
------------------------------------------------------------------------------------------------------------------------
GO




if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='report_JAGOGDEndo1')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Main Endoscopist OGD', 'report_JAGOGDEndo1')
GO
if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='report_JAGCOLEndo1')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Main Endoscopist Colon', 'report_JAGCOLEndo1')
GO
if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='report_JAGERCEndo1')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Main Endoscopist ERCP', 'report_JAGERCEndo1')

GO
if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='report_JAGSIGEndo1')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Main Endoscopist Sigmoidoscopy', 'report_JAGSIGEndo1')

GO
if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='report_JAGEUSEndo1')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Main Endoscopist EUS', 'report_JAGEUSEndo1')

GO
if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='report_JAGPEGEndo1')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Main Endoscopist PEG', 'report_JAGPEGEndo1')

GO

EXEC dbo.DropIfExist @ObjectName = 'report_JAGOGDEndo1',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE  PROCEDURE [dbo].[report_JAGOGDEndo1] 
	@UserID INT
AS
BEGIN
	DECLARE @ProcedureTypeId INT
	SET @ProcedureTypeId = 1

	DECLARE @FromDate as Date,
		@ToDate as Date,
		@ConsultantId as int,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)


	SELECT rc.ConsultantID , con.Title + ' ' + con.Forename + ' ' + con.Surname AS Endoscopist, rc.AnonimizedID
	INTO #Consultants
	FROM ERS_ReportConsultants rc
	JOIN ERS_Users con on rc.ConsultantID = con.UserID 
	WHERE rc.UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT ListItemNo, ListItemText
		INTO #ExtentSuccessIds
		FROM ERS_Lists 
		WHERE ListDescription = 'Extent of Intubation OGD' AND ListItemText IN ('D2','D3','Jejunum')


	DECLARE @D2ExtentId int, @D3ExtentId int, @JejunumEntentId int

	SELECT @D2ExtentId = (SELECT ListItemNo FROM #ExtentSuccessIds WHERE ListItemText = 'D2')
	SELECT @D3ExtentId = (SELECT ListItemNo FROM #ExtentSuccessIds WHERE ListItemText = 'D3')
	SELECT @JejunumEntentId = (SELECT ListItemNo FROM #ExtentSuccessIds WHERE ListItemText = 'Jejunum')

	Select  con.Endoscopist AS 'Endoscopist name'
				, count(DISTINCT p.ProcedureId) AS 'Total gastroscopies'
				, convert(varchar, convert(int, round((count (DISTINCT CASE
									WHEN ei.CompletionStatus = 1 or ei.TrainerCompletionStatus = 1 THEN p.ProcedureId END)
						* 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0)) * 100, 0))) + '%' AS 'Success of intubation'
				, convert(varchar, convert(int, round((count (DISTINCT CASE
									WHEN ei.Extent IN (@D2ExtentId, @D3ExtentId, @JejunumEntentId) or ei.TrainerExtent IN (@D2ExtentId, @D3ExtentId, @JejunumEntentId) THEN p.ProcedureId END)
						* 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0)) * 100, 0))) + '%' AS 'D2 intubation rate'
				, convert(varchar, convert(int, round((count (DISTINCT CASE
									WHEN ei.Jmanoeuvre = 2 or ei.TrainerJmanoeuvre = 2 THEN p.ProcedureId END)
						* 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0)) * 100, 0))) + '%' AS 'J manoeuvre rate'
					/*Comfort score*/
				, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN UGIQA.PatDiscomfortEndo = 5 OR UGIQA.PatDiscomfortEndo = 6 THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT p.ProcedureId), 0)) * 100, 0))) + '%' AS 'Endoscopist comfort rate % moderate or severe discomfort'
				, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN UGIQA.PatDiscomfortNurse = 5 OR UGIQA.PatDiscomfortNurse = 6 THEN p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT p.ProcedureId), 0)) * 100, 0))) + '%' AS 'Nurse comfort rate % moderate or severe discomfort'
				, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Midazolam', 0.5, 10.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS 'Median dose (Age <70) Midazolam'
				, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Pethidine', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS 'Median dose (Age <70) Pethidine'
				, dbo.CalcAnalgesiaLT70_New(con.ConsultantId, 'Fentanyl', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS 'Median dose (Age <70) Fentanyl'
				, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Midazolam', 0.5, 10.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS 'Median dose (Age >70) Midazolam'
				, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Pethidine', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS 'Median dose (Age >70) Pethidine'
				, dbo.CalcAnalgesiaGT70_New(con.ConsultantId, 'Fentanyl', 12.5, 200.0, 1, min(@FromDate), max(@ToDate), @OperatingHospitalList) AS 'Median dose (Age >70) Fentanyl'
				--/* GTRecommededDose */
				, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
									WHEN (
											(P.Endoscopist1 = con.ConsultantId) AND 
											(
												((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 < 70 AND (
													(	(dru.Pethidine > 50) OR
														(dru.midazolam > 5) OR
														(dru.Fentanyl > 100))
													)
												) OR 
												(	
													((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 >= 70 AND (
														(dru.Pethidine > 25) OR
														(dru.midazolam > 2.5) OR
														(dru.Fentanyl > 50))
													)	
												)
											)
										) THEN P.ProcedureId
								END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0)) * 100, 0))) + '%' AS 'Greater than recommended dose of sedation'
				/*NO SEDATION*/
				--, COUNT(distinct prof.ProcedureId) * 1.0 / NULLIF(COUNT( distinct p.procedureId), 0) as PropofolP
							, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null THEN P.ProcedureId END) 
				* 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN dru.GeneralAnaesthetic is null then P.ProcedureId END), 0)) * 100, 0))) + '%' AS 'Unsedated procedures in %'		
	FROM #Consultants con
	JOIN ERS_Procedures p ON con.ConsultantId = p.Endoscopist1
	JOIN ERS_Patients pat on p.PatientId = pat.PatientId
	LEFT JOIN ERS_UpperGIQA  UGIQA on p.ProcedureId = UGIQA.ProcedureId 
	LEFT JOIN ERS_UpperGIPremedication prof on p.ProcedureId = prof.ProcedureId AND prof.DrugName = 'propofol' AND prof.Dose > 0
	LEFT JOIN ERS_UpperGIPremedication midazolam on p.ProcedureId = midazolam.ProcedureId AND midazolam.DrugName = 'midazolam'
	LEFT JOIN fw_ERS_Drugs as dru on P.ProcedureID = dru.ProcId
	LEFT JOIN ERS_UpperGIExtentOfIntubation as ei ON ei.ProcedureId = p.ProcedureId
	WHERE p.ProcedureType = 1 
	and p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	--MH added on 31 Mar 2022
		and IsNull(p.DNA,0) = 0
	GROUP BY con.Endoscopist, con.ConsultantId, con.AnonimizedID
	ORDER BY con.AnonimizedID 
END

GO

EXEC dbo.DropIfExist @ObjectName = 'report_JAGCOLEndo1',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[report_JAGCOLEndo1] 
	@UserID INT
AS
/* Update History		:		08 Dec 2021		MH added filter out to elimiate Cancelled (DNA ) Procedures- */
BEGIN
	DECLARE @ProcedureTypeId INT
	SET @ProcedureTypeId = 3

	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@DiahhoreaId INT,
			@OperatingHospitalList as varchar(100)

	SELECT @DiahhoreaId = ListItemNo FROM ERS_Lists WHERE ListDescription = 'Indications Colon Altered Bowel Habit' AND ListItemText = 'chronic diarrhoea'

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT  C.ConsultantName AS 'Endoscopist name'
			, COUNT(DISTINCT PR.ProcId) AS 'Total colonoscopies'
			/*Digirectal examination*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
								WHEN CEOI.RectalExam = 1 OR CEOI.NED_RectalExam = 1 THEN PR.ProcId ELSE null
								END
								) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%'  AS 'Digital rectal examination'

			/*Caecal intubation rate*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN (CE.OrderBy >= 14 OR CE_NED.OrderBy >= 14) 
								THEN PR.ProcId 
								ELSE null
								END
								) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%'  AS 'Unadjusted caecal intubation rate'

			/*Terminal ileal intubation*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN (CEOI.InsertionTo > 0 AND CE.OrderBy in (15, 16)) or (CEOI.NED_InsertionTo > 0 AND CE_NED.OrderBy in (15, 16)) THEN PR.ProcId ELSE null END 						
								) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%'  AS 'Terminal ileal intubation rate in %'

			/*Polyp detection rate*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
								WHEN L.LesionType in ('Sessile', 'Peduncular', 'Pseudopolyp') 
											AND (CE.OrderBy >= 14 OR CE_NED.OrderBy >= 14) 
											and L.SiteId IS NOT NULL 
											AND (CAL.Sessile > 0 OR CAL.Pedunculated > 0 OR CAL.Pseudopolyps > 0) THEN PR.ProcId ELSE NULL
			END			
			) * 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN (CE.OrderBy >= 14 OR CE_NED.OrderBy >= 14) THEN PR.ProcId END), 0)) * 100, 0))) + '%'  AS 'Polyp detection rate**'
		
			/*Polyp retreival rate*/
			, convert(varchar, convert(int, round((sum(CASE WHEN L.LesionType in ('Sessile', 'Peduncular', 'Pseudopolyp') AND L.SiteId IS NOT NULL AND L.Retrieved <> 0 and L.Successful <> 0 THEN CASE WHEN convert(int, L.Retrieved) > convert(int, L.Successful) THEN convert(int, L.Successful) ELSE convert(int, L.Retrieved) END END) 
			* 1.0 / NULLIF(sum( CASE WHEN L.LesionType in ('Sessile', 'Peduncular', 'Pseudopolyp') AND L.SiteId IS NOT NULL THEN convert(int, L.Successful) END), 0)) * 100, 0))) + '%' AS 'Polyp retrieval rate'
			
			/*withdrawal times*/
			, dbo.CalcMeanWithdrawalTime(PC.ConsultantId, @ProcedureTypeId, MIN(RF.FromDate), MAX(RF.ToDate), @TrustId) AS 'Withdrawal time'

			/*Retroversion rate*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN CEOI.Retroflexion = 1 OR CEOI.NED_Retroflexion = 1 THEN PR.ProcId ELSE null END
								) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%' AS 'Rectal retroversion rate'
		
		
			/*Comfort score*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN UGIQA.PatDiscomfortEndo = 5 OR UGIQA.PatDiscomfortEndo = 6 THEN PR.ProcId END) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%' AS 'Endoscopist comfort rate % moderate or severe discomfort'
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN UGIQA.PatDiscomfortNurse = 5 OR UGIQA.PatDiscomfortNurse = 6 THEN PR.ProcId END) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%' AS 'Nurse comfort rate % moderate or severe discomfort'
		
			--/*Drug dosages*/
			, dbo.CalcAnalgesiaLT70_New(PC.ConsultantId, 'Midazolam', 0.5, 10.0, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), @OperatingHospitalList) AS 'Median dose (Age <70) Midazolam'
			, dbo.CalcAnalgesiaLT70_New(PC.ConsultantId, 'Pethidine', 12.5, 200.0, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), @OperatingHospitalList) AS 'Median dose (Age <70) Pethidine'
			, dbo.CalcAnalgesiaLT70_New(PC.ConsultantId, 'Fentanyl', 12.5, 200.0, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), @OperatingHospitalList) AS 'Median dose (Age <70) Fentanyl'
			, dbo.CalcAnalgesiaGT70_New(PC.ConsultantId, 'Midazolam', 0.5, 10.0, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), @OperatingHospitalList) AS 'Median dose (Age >70) Midazolam'
			, dbo.CalcAnalgesiaGT70_New(PC.ConsultantId, 'Pethidine', 12.5, 200.0, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), @OperatingHospitalList) AS 'Median dose (Age >70) Pethidine'
			, dbo.CalcAnalgesiaGT70_New(PC.ConsultantId, 'Fentanyl', 12.5, 200.0, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), @OperatingHospitalList) AS 'Median dose (Age >70) Fentanyl'
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
								WHEN (
										(PR.Endoscopist1 = RC.ConsultantId) AND 
										(
											(PR.Age < 70 AND (
												(	(dru.Pethidine > 50) OR
													(dru.midazolam > 5) OR
													(dru.Fentanyl > 100))
												)
											) OR 
											(	
												(PR.Age >= 70 AND (
													(dru.Pethidine > 25) OR
													(dru.midazolam > 2.5) OR
													(dru.Fentanyl > 50))
												)	
											)
										)
									) THEN PR.ProcId
							END) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%' AS 'Greater than recommended dose of sedation'
			/*NO SEDATION*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null THEN PR.ProcId END) 
			* 1.0 / NULLIF(COUNT(DISTINCT case when dru.GeneralAnaesthetic is null then PR.ProcId END), 0)) * 100, 0))) + '%' AS 'Unsedated procedures in %'
			/*biopsys for diarrhoea*/
			, convert(varchar, convert(int, round((dbo.GetNumDiagnosticRectalBiopsiesForUnexplainedDiarrohea(PC.ConsultantId, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), @TrustId) 
			* 1.0 / NULLIF(COUNT(DISTINCT (CASE WHEN ind.ColonAlterBowelHabit = @DiahhoreaId THEN PR.ProcId END)), 0)) * 100, 0))) + '%' AS 'Diagnostic R & L colon biopsies for diarrhoea'
			
--			/*Tattooed lesions*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN L.Largest >= 20 AND (L.IsTattooed = 1 OR L.PreviouslyTattooed = 1) AND S.Region NOT IN ('Rectum', 'Caecum') AND L.LesionType NOT IN ('Granuloma', 'Dysplastic', 'Pneumatosis Coli') THEN S.SiteId END) * 1.0 
					/ NULLIF(COUNT(DISTINCT CASE WHEN L.Largest >= 20 AND S.Region NOT IN ('Rectum', 'Caecum') AND L.LesionType NOT IN ('Granuloma', 'Dysplastic', 'Pneumatosis Coli') THEN S.SiteId END), 0) 
					) * 100, 0))) + '%'AS 'Tattooing all lesions ≥20mm and/or suspicious of cancer outside of rectum and caecum'

	FROM fw_ReportFilter RF
		LEFT JOIN fw_ReportConsultants_New RC ON RF.UserId = RC.UserId
		LEFT JOIN fw_ProceduresConsultants_New PC ON RC.ConsultantId = PC.ConsultantId
		LEFT JOIN fw_Procedures_New PR ON PC.ProcedureID = PR.ProcId
		LEFT JOIN fw_Consultants_New C ON PC.ConsultantId = C.ConsultantId 
		LEFT JOIN fw_Sites_New S ON S.ProcedureId = PR.ProcId
		LEFT JOIN fw_Lesions_New L ON S.SiteId = L.SiteId 
		LEFT JOIN ERS_Patients pat on PR.PatientId = pat.PatientId 
		LEFT JOIN ERS_ColonExtentOfIntubation AS CEOI ON PR.ProcId = CEOI.ProcedureId
		LEFT JOIN ERS_ColonExtent AS CE ON CEOI.InsertionTo = CE.ExtentID
		LEFT JOIN ERS_ColonExtent AS CE_NED ON CEOI.NED_InsertionTo = CE_NED.ExtentID
		LEFT JOIN ERS_UpperGIQA UGIQA ON UGIQA.ProcedureId = PR.ProcId
		LEFT JOIN ERS_UpperGITherapeutics UGIT ON S.SiteId = UGIT.SiteId
		LEFT JOIN ERS_ColonAbnoLesions CAL ON CAL.SiteId = S.SiteId
		LEFT JOIN ERS_UpperGISpecimens AS UGIS ON UGIS.SiteId = S.SiteId
		LEFT JOIN fw_ERS_Drugs as dru on PC.ProcedureID = dru.ProcId
		LEFT JOIN ERS_UpperGIIndications ind on PR.ProcId = ind.ProcedureId
	WHERE RF.UserId = @UserID AND PR.ProcedureTypeId = @ProcedureTypeId AND PC.ConsultantTypeId IN (1,2)
		and PR.CreatedOn >= @FromDate AND PR.CreatedOn <= @ToDate
		and PR.Endoscopist1 = RC.ConsultantId
		--MH added on 08 Dec 2021
		and IsNull(PR.DNA,0) = 0
		AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	GROUP BY C.ConsultantName, PC.ConsultantID, RC.AnonimizedID
	HAVING COUNT(DISTINCT PR.ProcId) >= 0
	ORDER BY RC.AnonimizedID
END

GO

EXEC dbo.DropIfExist @ObjectName = 'report_JAGERCEndo1',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[report_JAGERCEndo1] 
	@UserID INT
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
******************************************************************************************************************/
BEGIN
	DECLARE @FromDate as Date,
		@ToDate as Date,
		@TrustId as int,
		@OperatingHospitalList as varchar(100)



SELECT rc.ConsultantID , con.Surname + ', ' + con.Forename AS Endoscopist, rc.AnonimizedID
INTO #Consultants
FROM ERS_ReportConsultants rc
JOIN ERS_Users con on rc.ConsultantID = con.UserID 
WHERE rc.UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId


Select con.Endoscopist AS 'Endoscopist name'
			, count(DISTINCT p.ProcedureId) AS 'Total ERCP procedures'
			,convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
				WHEN ((v.IntendedBileDuct=1 OR v.IntendedBileDuct_ER=1) AND (v.MajorPapillaBile=1 OR v.MajorPapillaBile_ER=1)) OR
					((v.IntendedPancreaticDuct=1 OR v.IntendedPancreaticDuct_ER=1) AND (v.MajorPapillaPancreatic=1 OR v.MajorPapillaPancreatic_ER=1)) 
					AND p.FirstERCP = 1
						THEN p.procedureId -- Independent
				END) * 1.0 / NULLIF(COUNT(DISTINCT case when p.FirstERCP = 1 then p.ProcedureId end), 0)) * 100, 0))) + '%' as 'Successful cannulation of clinically relevant duct at 1st ever ERCP'
			,convert(varchar, convert(int, round((COUNT(DISTINCT the.ProcedureId) * 1.0 / NULLIF(COUNT(DISTINCT case when p.FirstERCP = 1 then p.ProcedureId end), 0)) * 100, 0))) + '%' as 'CBD Stone clearance 1st ever ERCP' 
			,convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
				WHEN p.FirstERCP = 1 and ehs.ProcedureId is not null THEN ehs.ProcedureId
				END) * 1.0 / NULLIF(COUNT(DISTINCT case when p.FirstERCP = 1 then p.ProcedureId end), 0)) * 100, 0))) + '%' as 'Extra-hepatic stricture cytology/histology and stent placement at first ever ERCP' 

			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
				WHEN qa.PatDiscomfortEndo = 5 OR qa.PatDiscomfortEndo = 6 then p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT p.procedureId), 0)) * 100, 0))) + '%' as 'Endoscopist comfort rate % moderate or severe discomfort'	
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
				WHEN qa.PatDiscomfortNurse = 5 OR qa.PatDiscomfortNurse = 6 then p.ProcedureId END) * 1.0 / NULLIF(COUNT(DISTINCT p.procedureId), 0)) * 100, 0))) + '%' as 'Nurse Comfort rate % moderate or severe discomfort'					
			
			, dbo.CalcAnalgesiaLT70(con.ConsultantID, 'Midazolam', 0.5, 10.0, 2, @FromDate, @ToDate) AS 'Median dose (Age <70) Midazolam'
			, dbo.CalcAnalgesiaLT70(con.ConsultantID, 'Pethidine', 12.5, 200.0, 2, @FromDate, @ToDate) AS 'Median dose (Age <70) Pethidine'
			, dbo.CalcAnalgesiaLT70(con.ConsultantID, 'Fentanyl', 12.5, 200.0, 2, @FromDate, @ToDate) AS 'Median dose (Age <70) Fentanyl'
			, dbo.CalcAnalgesiaGT70(con.ConsultantID, 'Midazolam', 0.5, 10.0, 2, @FromDate, @ToDate) AS 'Median dose (Age >70) Midazolam'
			, dbo.CalcAnalgesiaGT70(con.ConsultantID, 'Pethidine', 12.5, 200.0, 2, @FromDate, @ToDate) AS 'Median dose (Age >70) Pethidine'
			, dbo.CalcAnalgesiaGT70(con.ConsultantID, 'Fentanyl', 12.5, 200.0, 2, @FromDate, @ToDate) AS 'Median dose (Age >70) Fentanyl'
			, convert(varchar, convert(int, round((COUNT(distinct prof.ProcedureId) * 1.0 / NULLIF(COUNT( distinct p.procedureId), 0)) * 100, 0))) + '%' as '% of procedures performed with propofol'
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null THEN P.ProcedureId END) 
			* 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN dru.GeneralAnaesthetic is null then P.ProcedureId END), 0)) * 100, 0))) + '%' AS 'Unsedated procedures in %'			
			--/* GTRecommededDose */
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
								WHEN (
										(P.Endoscopist1 = con.ConsultantId) AND 
										(
											((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 < 70 AND (
												(	(dru.Pethidine > 50) OR
													(dru.midazolam > 5) OR
													(dru.Fentanyl > 100))
												)
											) OR 
											(	
												((CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 >= 70 AND (
													(dru.Pethidine > 25) OR
													(dru.midazolam > 2.5) OR
													(dru.Fentanyl > 50))
												)	
											)
										)
									) THEN P.ProcedureId
							END) * 1.0 / NULLIF(COUNT(DISTINCT P.ProcedureId), 0)) * 100, 0))) + '%' AS 'Greater than recommended dose of sedation'
FROM #Consultants con
JOIN ERS_Procedures p ON con.ConsultantId = p.Endoscopist1
JOIN ERS_Patients pat on p.PatientId = pat.PatientId
LEFT JOIN dbo.ERS_Visualisation v on v.ProcedureID = p.ProcedureId 
LEFT JOIN (Select DISTINCT p.ProcedureId, isnull(t.EndoRole, 3) as EndoRole
			from ERS_Procedures p
			LEFT JOIN ERS_UpperGIIndications i on p.ProcedureId = i.ProcedureId 
			LEFT JOIN (Select max(convert(int,stones)) Stones, sit.ProcedureId from ERS_Sites sit join ERS_ERCPAbnoDuct eed on sit.SiteId = eed.siteId group by sit.ProcedureId) eed ON p.ProcedureId = eed.ProcedureId 
			LEFT JOIN (Select max(convert(int,th.StoneRemoval)) StoneRemoval, max(th.ExtractionOutcome) ExtractionOutcome, s.ProcedureId, th.EndoRole 
					FROM ERS_Sites s
					LEFT JOIN ERS_ERCPTherapeutics th on s.SiteId = th.SiteId 
					where th.StoneRemoval = 1
					and s.RegionId in (Select RegionId from ERS_Regions where ProcedureType = 2 and  Region = 'Common Bile Duct')
					group by s.ProcedureId, th.EndoRole) t on t.ProcedureId = p.ProcedureId  
			LEFT JOIN ERS_Visualisation v on p.ProcedureId = v.ProcedureID 
			LEFT JOIN #Consultants c on (c.ConsultantId = p.Endoscopist1 or (c.ConsultantId = p.Endoscopist2 and P.Endo2Role in (2, 3)))
			WHERE	p.FirstERCP = 1
			AND		CASE WHEN p.Endoscopist1 = c.ConsultantId and v.IntendedBileDuct_ER = 1 and isnull(v.MajorPapillaBile_ER, 3) > 1 THEN 0
						 WHEN (c.ConsultantId = p.Endoscopist2 and P.Endo2Role in (2, 3)) and ((v.IntendedBileDuct = 1 or v.IntendedBileDuct_ER = 1) and (isnull(v.MajorPapillaBile, 3) > 1 and isnull(v.MajorPapillaBile_ER, 3) > 1)) then 0
						 WHEN t.StoneRemoval = 1 and t.ExtractionOutcome IN (3,4) then 0
						 WHEN t.StoneRemoval = 1 and t.ExtractionOutcome NOT IN (3,4) then 1
						 WHEN eed.Stones = 1 then 0
						 WHEN i.ERSCBDStones = 1 or i.ERSGallBladder = 1 then 1
						 ELSE 0
					END = 1) as the on p.ProcedureId = the.ProcedureId 
LEFT JOIN (Select DISTINCT pro.ProcedureId, thera.EndoRole 
			from ERS_Procedures pro
			join ERS_Sites sit on pro.ProcedureId = sit.ProcedureId 
			join ERS_ERCPAbnoDuct ad on sit.SiteId = ad.SiteId 
			join ERS_UpperGISpecimens spec on sit.SiteId = spec.SiteId 
			join ERS_ERCPTherapeutics thera on sit.SiteId = thera.SiteId 
			where ad.Stricture = 1
			and (spec.BiopsyQtyHistology > 0 OR spec.BrushCytology = 1 OR spec.CytologyHistology = 1 OR spec.Bile_PanJuiceCytology = 1 OR spec.NeedleAspirateHistology = 1)
			and sit.RegionId in (Select RegionId from ERS_Regions where ProcedureType = 2 and Region in ('Common Hepatic Duct', 'Common Bile Duct'))
			and thera.StentInsertion = 1) as ehs on ehs.ProcedureId = p.ProcedureId
LEFT JOIN ERS_UpperGIQA  qa on p.ProcedureId = qa.ProcedureId 
LEFT JOIN ERS_UpperGIPremedication prof on p.ProcedureId = prof.ProcedureId AND prof.DrugName = 'propofol' AND prof.Dose > 0
LEFT JOIN ERS_UpperGIPremedication midazolam on p.ProcedureId = midazolam.ProcedureId AND midazolam.DrugName = 'midazolam'
LEFT JOIN fw_ERS_Drugs as dru on P.ProcedureID = dru.ProcId

WHERE p.ProcedureType = 2 
and p.ProcedureCompleted = 1
and p.IsActive = 1
	--MH added on 31 Mar 2022
		and IsNull(p.DNA,0) = 0
AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
GROUP BY con.Endoscopist, con.ConsultantId, con.AnonimizedID
ORDER BY con.Endoscopist 


drop table #Consultants


	
END
GO

EXEC dbo.DropIfExist @ObjectName = 'report_JAGSIGEndo1',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[report_JAGSIGEndo1] 
	@UserID INT
AS
BEGIN
	
	DECLARE @ProcedureTypeId INT, @DiahhoreaId int
	SET @ProcedureTypeId = 4

	SELECT @DiahhoreaId = ListItemNo FROM ERS_Lists WHERE ListDescription = 'Indications Colon Altered Bowel Habit' AND ListItemText = 'chronic diarrhoea'

	SELECT  C.ConsultantName AS 'Endoscopist name'
			, COUNT(DISTINCT PR.ProcId) AS 'Total sigmoidoscopies'
			/*Digirectal examination*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
								WHEN PR.Endoscopist2 = RC.ConsultantId AND PR.Endo2Role	IN (2, 3) THEN CASE WHEN CEOI.RectalExam = 1 THEN PR.ProcId ELSE null END   -- Trainee
									ELSE CASE WHEN CEOI.RectalExam = 1 OR CEOI.NED_RectalExam = 1 THEN PR.ProcId ELSE null END 
								END
								) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%' AS 'Digital rectal examination'
--			/*Splenic flexture intubation*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
								--WHEN CEOI.InsertionTo > 0 AND CE.OrderBy = 7 AND (ISNULL(PR.Endoscopist2, 0) = 0 OR (ISNULL(PR.Endoscopist2, 0) = RC.ConsultantId AND (PR.Endo2Role IN (2,3) OR PR.Endo2Role = 1))) THEN PR.ProcId
								--WHEN CEOI.NED_InsertionTo > 0 AND CE.OrderBy = 7 AND ISNULL(PR.Endoscopist2, 0) <> 0 AND PR.Endoscopist1 = RC.ConsultantId AND (PR.Endo1Role IN (2,3) OR PR.Endo1Role = 1) THEN PR.ProcId
								WHEN CASE WHEN (CEOI.InsertionTo > 0 OR CEOI.NED_InsertionTo > 0) THEN 1 ELSE 0 END = 1  AND (CE.OrderBy >= 7 OR CE_NED.OrderBy >= 7) THEN PR.ProcId
							END) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%' AS 'Extent of procedure – splenic flexure in %'
--			/*decending colon intubation*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
								--WHEN CEOI.InsertionTo > 0 AND CE.OrderBy IN (5,6) AND (ISNULL(PR.Endoscopist2, 0) = 0 OR (ISNULL(PR.Endoscopist2, 0) = RC.ConsultantId AND (PR.Endo2Role IN (2,3) OR PR.Endo2Role = 1))) THEN PR.ProcId
								--WHEN CEOI.NED_InsertionTo > 0 AND CE.OrderBy IN (5,6) AND ISNULL(PR.Endoscopist2, 0) <> 0 AND PR.Endoscopist1 = RC.ConsultantId AND (PR.Endo1Role IN (2,3) OR PR.Endo1Role = 1) THEN PR.ProcId
								WHEN CASE WHEN PR.Endoscopist1 = RC.ConsultantId AND (CEOI.InsertionTo > 0 OR CEOI.NED_InsertionTo > 0) THEN 1 ELSE 0 END = 1  AND (CE.OrderBy >= 5 OR CE_NED.OrderBy >= 5) THEN PR.ProcId
							END) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%' AS 'Extent of procedure – descending colon in %'

			/*Polyp detection rate*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
								WHEN L.LesionType in ('Sessile', 'Peduncular', 'Pseudopolyp') 
											AND L.SiteId IS NOT NULL 
											AND (CAL.Sessile > 0 OR CAL.Pedunculated > 0 OR CAL.Pseudopolyps > 0) THEN PR.ProcId ELSE NULL
			END			
			) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%' AS 'Polyp detection rate**'

		
			/*Polyp retreival rate*/
			, convert(varchar, convert(int, round((sum(CASE WHEN L.LesionType in ('Sessile', 'Peduncular', 'Pseudopolyp') AND L.SiteId IS NOT NULL AND L.Retrieved <> 0 and L.Successful <> 0 THEN  CASE WHEN convert(int, L.Retrieved) > convert(int, L.Successful) THEN convert(int, L.Successful) ELSE convert(int, L.Retrieved) END END) 
			* 1.0 / NULLIF(sum( CASE WHEN L.LesionType in ('Sessile', 'Peduncular', 'Pseudopolyp') AND L.SiteId IS NOT NULL THEN convert(int, L.Successful) END), 0)) * 100, 0))) + '%' AS 'Polyp retrieval rate'
			/*Retroversion rate*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
								WHEN PR.Endoscopist2 = RC.ConsultantId AND PR.Endo2Role	IN (2, 3) THEN CASE WHEN CEOI.Retroflexion = 1 THEN PR.ProcId ELSE null END   -- Trainee
									ELSE CASE WHEN CEOI.Retroflexion = 1 OR CEOI.NED_Retroflexion = 1 THEN PR.ProcId ELSE null END 									
								END
								) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%' AS 'Rectal retroversion rate'
			/*Comfort score*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN UGIQA.PatDiscomfortEndo = 5 OR UGIQA.PatDiscomfortEndo = 6 THEN PR.ProcId END) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%' AS 'Endoscopist comfort rate % moderate or severe discomfort'
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN UGIQA.PatDiscomfortNurse = 5 OR UGIQA.PatDiscomfortNurse = 6 THEN PR.ProcId END) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%' AS 'Nurse comfort rate % moderate or severe discomfort'
		
			/*Drug dosages*/
			, dbo.CalcAnalgesiaLT70_New(PC.ConsultantId, 'Midazolam', 0.5, 10.0, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), RF.OperatingHospitalList) AS 'Median dose (Age <70) Midazolam'
			, dbo.CalcAnalgesiaLT70_New(PC.ConsultantId, 'Pethidine', 12.5, 200.0, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), RF.OperatingHospitalList) AS 'Median dose (Age <70) Pethidine'
			, dbo.CalcAnalgesiaLT70_New(PC.ConsultantId, 'Fentanyl', 12.5, 200.0, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), RF.OperatingHospitalList) AS 'Median dose (Age <70) Fentanyl'
			, dbo.CalcAnalgesiaGT70_New(PC.ConsultantId, 'Midazolam', 0.5, 10.0, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), RF.OperatingHospitalList) AS 'Median dose (Age >70) Midazolam'
			, dbo.CalcAnalgesiaGT70_New(PC.ConsultantId, 'Pethidine', 12.5, 200.0, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), RF.OperatingHospitalList) AS 'Median dose (Age >70) Pethidine'
			, dbo.CalcAnalgesiaGT70_New(PC.ConsultantId, 'Fentanyl', 12.5, 200.0, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), RF.OperatingHospitalList) AS 'Median dose (Age >70) Fentanyl'
			--/*GTRecommededDose*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE 
								WHEN (
										(PR.Endoscopist1 = RC.ConsultantId) AND 
										(
											(PR.Age < 70 AND (
												(	(dru.Pethidine > 50) OR
													(dru.midazolam > 5) OR
													(dru.Fentanyl > 100))
												)
											) OR 
											(	
												(PR.Age >= 70 AND (
													(dru.Pethidine > 25) OR
													(dru.midazolam > 2.5) OR
													(dru.Fentanyl > 50))
												)	
											)
										)
									) THEN PR.ProcId
							END) * 1.0 / NULLIF(COUNT(DISTINCT PR.ProcId), 0)) * 100, 0))) + '%' AS 'Greater than recommended dose of sedation'
			/*NO SEDATION*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null THEN PR.ProcId END) 
			* 1.0 / NULLIF(COUNT(DISTINCT case when dru.GeneralAnaesthetic is null then PR.ProcId END), 0)) * 100, 0))) + '%' AS 'Unsedated procedures in %'
		
--			/*Tattooed lesions*/
			, convert(varchar, convert(int, round((COUNT(DISTINCT CASE WHEN L.Largest >= 20 AND (L.IsTattooed = 1 OR L.PreviouslyTattooed = 1) AND S.Region NOT IN ('Rectum', 'Caecum') AND L.LesionType NOT IN ('Granuloma', 'Dysplastic', 'Pneumatosis Coli') THEN S.SiteId END) * 1.0 
					/ NULLIF(COUNT(DISTINCT CASE WHEN L.Largest >= 20 AND S.Region NOT IN ('Rectum', 'Caecum') AND L.LesionType NOT IN ('Granuloma', 'Dysplastic', 'Pneumatosis Coli') THEN S.SiteId END), 0) ) * 100, 0))) + '%'
					AS 'Tattooing all lesions ≥20mm and/or suspicious of cancer outside of rectum and caecum'

			/*biopsys for diarrhoea*/
			--, dbo.GetNumDiagnosticRectalBiopsiesForUnexplainedDiarrohea(PC.ConsultantId, @ProcedureTypeId, min(RF.FromDate), max(RF.ToDate), RF.TrustId) 
			--* 1.0 / NULLIF(COUNT(DISTINCT (CASE WHEN ColonAlterBowelHabit = @DiahhoreaId THEN PR.ProcId END)), 0) AS DiagnosticRectalBiopsiesForUnexplainedDiarrohea

		

	FROM fw_ReportFilter RF
		LEFT JOIN fw_ReportConsultants_New RC ON RF.UserId = RC.UserId
		LEFT JOIN fw_ProceduresConsultants_New PC ON RC.ConsultantId = PC.ConsultantId
		LEFT JOIN fw_Procedures_New PR ON PC.ProcedureID = PR.ProcId
		LEFT JOIN ERS_PatientTrusts pt on PR.PatientId = pt.PatientId and RF.TrustId = pt.TrustId
		LEFT JOIN fw_Consultants_New C ON PC.ConsultantId = C.ConsultantId 
		LEFT JOIN fw_Sites_New S ON S.ProcedureId = PR.ProcId
		LEFT JOIN fw_Lesions_New L ON S.SiteId = L.SiteId 
		LEFT JOIN ERS_ColonAbnoLesions CAL ON CAL.SiteId = S.SiteId
		LEFT JOIN ERS_ColonExtentOfIntubation AS CEOI ON PR.ProcId = CEOI.ProcedureId
		LEFT JOIN ERS_ColonExtent AS CE ON CEOI.InsertionTo = CE.ExtentID
		LEFT JOIN ERS_ColonExtent AS CE_NED ON CEOI.NED_InsertionTo = CE_NED.ExtentID
		LEFT JOIN ERS_UpperGIQA UGIQA ON UGIQA.ProcedureId = PR.ProcId
		LEFT JOIN fw_ERS_Drugs as dru on PC.ProcedureID = dru.ProcId
		LEFT JOIN ERS_UpperGIIndications AS UGII ON PR.ProcId = UGII.ProcedureId
	WHERE RF.UserId = @UserID 
	AND PR.ProcedureTypeId = @ProcedureTypeId
	AND PC.ConsultantTypeId IN (1)
	AND PR.CreatedOn >= RF.FromDate 
	AND PR.CreatedOn <= RF.ToDate
	AND PR.Endoscopist1 = RC.ConsultantId
	--MH added on 31 Mar 2022
	and IsNull(PR.DNA,0) = 0
	AND PR.OperatingHospitalID IN (SELECT * FROM dbo.splitString(RF.OperatingHospitalList,',') )
	GROUP BY C.ConsultantName, PC.ConsultantID, RC.AnonimizedID, RF.OperatingHospitalList
	HAVING COUNT(DISTINCT PR.ProcId) >= 0
	ORDER BY RC.AnonimizedID
END
GO


EXEC dbo.DropIfExist @ObjectName = 'report_JAGEUSEndo1',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[report_JAGEUSEndo1] 
	@UserID INT
AS
BEGIN
	
	DECLARE @FromDate as Date,
		@ToDate as Date,
		@ConsultantId as int,
		@TrustId as int,
		@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT DISTINCT PR.ProcedureId, PR.ProcId, PR.ProcedureTypeId, EP.Endoscopist1, EP.Endo1Role, EP.Endoscopist2, EP.Endo2Role, PR.FirstERCP, pr.Age AS PatientAge
	INTO #EUSProcedures
	FROM dbo.ERS_Procedures EP
		INNER JOIN ERS_Patients pat on ep.PatientId = pat.PatientId 
		INNER JOIN dbo.fw_Procedures PR ON EP.ProcedureId = PR.ProcId
		INNER JOIN fw_ProceduresConsultants PC ON PC.ProcedureID = PR.ProcedureId
		INNER JOIN dbo.fw_ReportConsultants RC ON PC.ConsultantId = RC.ConsultantId,
	dbo.fw_ReportFilter RF
	WHERE RF.UserId = RC.UserId AND PR.CreatedOn >= RF.FromDate AND PR.CreatedOn <= RF.ToDate AND PC.ConsultantTypeId IN (1)
	AND PR.OperatingHospitalID IN (SELECT * FROM dbo.splitString(RF.OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = RF.TrustId)
	AND RF.UserId = @UserID AND PR.ProcedureTypeId IN (6,7)
		--MH added on 31 Mar 2022
		and IsNull(EP.DNA,0) = 0
		AND PR.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
	
	SELECT * 
	INTO #Sites
	FROM FW_Sites 
	WHERE ProcedureId IN 
		(SELECT ProcedureId FROM #EUSProcedures)

	SELECT *
	INTO #Lesions
	FROM FW_ERS_Lesions 
	WHERE SiteId IN 
		(SELECT SiteId FROM #Sites)

	SELECT *
	INTO #EUSSpecimens
	FROM ERS_UpperGISpecimens
	WHERE 'E.' + CONVERT(VARCHAR(100), SiteId) IN 
		(SELECT SiteId FROM #Sites)

	SELECT p.ProcId as ProcedureId
	INTO #NonSedatedProcedures
	FROM #EUSProcedures p
	left join fw_ERS_Drugs dru on p.ProcId = dru.ProcId 
	WHERE dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null
	  AND dru.ProcId IN
		(SELECT ProcId FROM #EUSProcedures)

	SELECT * 
	INTO #EUSQA
	FROM ERS_UpperGIQA
	WHERE ProcedureId IN 
		(SELECT ProcId FROM #EUSProcedures)

	SELECT p.ProcedureId, pre.DrugName, pre.Dose
	INTO #PreMed
	FROM #EUSProcedures p
	LEFT JOIN fw_ERS_Premedication pre on pre.ProcedureId = p.ProcedureId


	SELECT * 
	FROM
	(
		SELECT DISTINCT C.ConsultantName AS 'Endoscopist name'
			, (SELECT COUNT(DISTINCT PR.ProcedureId) FROM #EUSProcedures PR 
				WHERE ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId)) AS 'Number of cases per year'
			/*Drug dosages*/
			, (isnull(dbo.CalcAnalgesiaLT70_New(REPLACE(RC.ConsultantId, 'E.',''), 'Midazolam', 0.5, 10.0, 6, RF.FromDate, RF.ToDate, @OperatingHospitalList), 0) ) AS 'Median dose (Age <70) Midazolam'
			, (isnull(dbo.CalcAnalgesiaLT70_New(REPLACE(RC.ConsultantId, 'E.',''), 'Pethidine', 12.5, 200.0, 6, RF.FromDate, RF.ToDate, @OperatingHospitalList), 0) )AS 'Median dose (Age <70) Pethidine'
			, (isnull(dbo.CalcAnalgesiaLT70_New(REPLACE(RC.ConsultantId, 'E.',''), 'Fentanyl', 12.5, 200.0, 6, RF.FromDate, RF.ToDate, @OperatingHospitalList), 0) ) AS 'Median dose (Age <70) Fentanyl'
			, (isnull(dbo.CalcAnalgesiaGT70_New(REPLACE(RC.ConsultantId, 'E.',''), 'Midazolam', 0.5, 10.0, 6, RF.FromDate, RF.ToDate, @OperatingHospitalList), 0) ) AS 'Median dose (Age >70) Midazolam'
			, (isnull(dbo.CalcAnalgesiaGT70_New(REPLACE(RC.ConsultantId, 'E.',''), 'Pethidine', 12.5, 200.0, 6, RF.FromDate, RF.ToDate, @OperatingHospitalList), 0) ) AS 'Median dose (Age >70) Pethidine'
			, (isnull(dbo.CalcAnalgesiaGT70_New(REPLACE(RC.ConsultantId, 'E.',''), 'Fentanyl', 12.5, 200.0, 6, RF.FromDate, RF.ToDate, @OperatingHospitalList), 0) ) AS 'Median dose (Age >70) Fentanyl'
			/*PROPOFOL USAGE*/
			, convert(varchar, convert(int, round((((SELECT COUNT(PR.ProcedureId)
				FROM #EUSProcedures PR
					INNER JOIN #PreMed pm ON PR.ProcedureId = pm.ProcedureId
				WHERE (LOWER(pm.DrugName) = 'propofol' AND pm.Dose > 0) 
				AND ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId))
				 * 1.0 / NULLIF(
				(SELECT COUNT(DISTINCT PR.ProcedureId) 
					FROM #EUSProcedures PR 
					WHERE ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId)
				), 0))) * 100, 0))) + '%' AS '% of procedures performed with propofol'
			, convert(varchar, convert(int, round(((SELECT COUNT(DISTINCT PR.ProcedureId) 
			FROM #EUSQA UGIQA 
				INNER JOIN #EUSProcedures PR ON UGIQA.ProcedureId = PR.ProcId
			WHERE ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId)
				AND (UGIQA.PatDiscomfortEndo = 5 OR UGIQA.PatDiscomfortEndo = 6))  
				* 1.0 / NULLIF(
						(SELECT COUNT(DISTINCT PR.ProcedureId) 
							FROM #EUSProcedures PR
							WHERE ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId)
						), 0)) * 100, 0))) + '%'
				AS 'Endoscopist comfort rate % moderate or severe discomfort'
			, convert(varchar, convert(int, round(((SELECT COUNT(DISTINCT PR.ProcedureId) 
			FROM #EUSQA UGIQA 
				INNER JOIN #EUSProcedures PR ON UGIQA.ProcedureId = PR.ProcId
			WHERE ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId)
				AND (UGIQA.PatDiscomfortNurse = 5 OR UGIQA.PatDiscomfortNurse = 6))  
				* 1.0 / NULLIF(
						(SELECT COUNT(DISTINCT PR.ProcedureId) 
							FROM #EUSProcedures PR
							WHERE ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId)
						), 0)) * 100, 0))) + '%'
				AS 'Nurse comfort rate % moderate or severe discomfort'
			,convert(varchar, convert(int, round(((SELECT COUNT(DISTINCT PR.ProcedureID)
			 FROM #EUSProcedures PR
				INNER JOIN #PreMed pm ON PR.ProcedureId = pm.ProcedureId
			 WHERE  ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId) AND ((PR.PatientAge < 70 AND 
						((LOWER(pm.DrugName) = 'pethidine' AND pm.Dose > 50) OR
						(LOWER(pm.DrugName) = 'midazolam' AND pm.Dose > 5) OR
						(LOWER(pm.DrugName) = 'fentanyl' AND pm.Dose > 100))
					) /*under 70*/ 
			     OR (PR.PatientAge >= 70 AND 
						((LOWER(pm.DrugName) = 'pethidine' AND pm.Dose > 25) OR
						(LOWER(pm.DrugName) = 'midazolam' AND pm.Dose > 2.5) OR
						(LOWER(pm.DrugName) = 'fentanyl' AND pm.Dose > 50))
					)) AND ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId)
				)* 1.0 / NULLIF(
						(SELECT COUNT(DISTINCT PR.ProcedureId) 
							FROM #EUSProcedures PR
								INNER JOIN #PreMed pm ON PR.ProcedureId = pm.ProcedureId
							WHERE --(LOWER(pm.DrugName) = 'pethidine' OR
								   --LOWER(pm.DrugName) = 'midazolam' OR
								   --LOWER(pm.DrugName) = 'fentanyl') AND 
								   ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId)
						), 0)) * 100, 0))) + '%' AS 'Greater than recommended dose of sedation'
			/*NO SEDATION*/
			 ,convert(varchar, convert(int, round((((SELECT COUNT(PR.ProcedureId)
				FROM #NonSedatedProcedures NP
					INNER JOIN #EUSProcedures PR ON PR.ProcId = NP.ProcedureId
				WHERE ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId))
				 * 1.0 / NULLIF(
				(SELECT COUNT(DISTINCT PR.ProcedureId) 
					FROM #EUSProcedures PR 
					left outer join ERS_UpperGIPremedication p on PR.ProcId = p.ProcedureId and p.DrugName = 'GeneralAnaesthetic'
					WHERE ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId)
					and p.DrugName is null
				), 0))) * 100, 0))) + '%' AS 'Unsedated procedures in %'

			--, ((SELECT COUNT(DISTINCT PR.ProcedureId)
			--	FROM #EUSProcedures PR 
			--		INNER JOIN #Sites es ON PR.ProcedureId = es.ProcedureId
			--		--INNER JOIN #Lesions l ON pr.ProcedureId = l.SiteId
			--		INNER JOIN #EUSSpecimens eug ON REPLACE(es.SiteId, 'E.', '') = eug.SiteId
			--	WHERE (eug.NeedleAspirate = 1)
			--	AND ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId)
			--	) * 1.0 / NULLIF(
			--	(SELECT COUNT(DISTINCT PR.ProcedureId) 
			--		FROM #EUSProcedures PR 
			--		WHERE ('E.' + CONVERT(VARCHAR, PR.Endoscopist1) = RC.ConsultantId)
			--	), 0)) AS FNABiopsyP

		FROM fw_Consultants C
			, fw_ReportFilter RF
			, fw_ReportConsultants RC 
			, fw_ProceduresConsultants PC
		WHERE C.ConsultantId = RC.ConsultantID 
				AND RF.UserID = RC.UserID 
				AND RF.UserID = @UserID
				AND PC.ConsultantId = C.ConsultantId
				AND PC.ConsultantTypeId IN (1,2)
	) AS T
	WHERE [Number of cases per year] > 0
END
GO

EXEC dbo.DropIfExist @ObjectName = 'report_JAGPEGEndo1',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[report_JAGPEGEndo1] 
	@UserID INT
AS
BEGIN

	SELECT DISTINCT PR.ProcedureId as ProcId, PC.ProcedureId, RC.ConsultantId ReportConsultant,eug.EndoRole, CorrectPEGPlacement
	INTO #Procedures
	FROM fw_ProceduresConsultants PC
	INNER JOIN dbo.ERS_Procedures PR ON PC.ProcedureId = 'E.' + convert(varchar(10), PR.ProcedureId)
	INNER JOIN dbo.ERS_Sites es ON PR.ProcedureId = es.ProcedureId
	INNER JOIN dbo.ERS_UpperGITherapeutics eug ON es.SiteId = eug.SiteId
	INNER JOIN dbo.ERS_UpperGIIndications eugi ON es.ProcedureId = eugi.ProcedureId
	INNER JOIN dbo.fw_ReportConsultants RC ON PC.ConsultantId = RC.ConsultantId,
	dbo.fw_ReportFilter RF
	WHERE RF.UserId = RC.UserId AND PR.CreatedOn >= RF.FromDate AND PR.CreatedOn <= RF.ToDate AND PC.ConsultantTypeId IN (1)
	AND RF.UserId = @UserID
	AND (RC.ConsultantId = 'E.' + convert(varchar(10), PR.Endoscopist1))
	
	--AND ((RC.ConsultantId = 'E.' + convert(varchar(10), PR.Endoscopist1) AND Endo1Role = 2 AND eug.EndoRole = 1) /*trainer did it alone*/
	--	OR   (eug.EndoRole IN (2,3)) /*2 = trainer observed, 3 = trainer assisted*/
	--	OR   (Endo1Role = 1 AND eug.EndoRole IN (1,4) /*2 independant endos*/))
	AND (eug.GastrostomyInsertion = 1 AND eugi.NasoDuodenalTube = 0) AND (PR.ProcedureCompleted=1 AND PR.IsActive=1)
		--MH added on 31 Mar 2022
		and IsNull(PR.DNA,0) = 0
	AND PR.OperatingHospitalID IN (SELECT * FROM dbo.splitString(RF.OperatingHospitalList,',') )

	SELECT * 
	FROM
	(
		SELECT DISTINCT C.ConsultantName AS 'Endoscopist name'

			, (SELECT COUNT(DISTINCT ProcedureId) 
			   FROM #Procedures PR WHERE RC.ConsultantId = PR.ReportConsultant
			   ) AS [TotalPEGProcedures]

			, convert(varchar, convert(int, round(((SELECT COUNT(DISTINCT PR.ProcedureId) 
				FROM #Procedures PR 
				WHERE Pr.CorrectPEGPlacement = 1 AND RC.ConsultantId = PR.ReportConsultant
			  ) * 1.0 /NULLIF(
			  (SELECT COUNT(DISTINCT ProcedureId) FROM #Procedures WHERE RC.ConsultantId = ReportConsultant
			  ) ,0)) * 100, 0))) + '%' AS SatisfactoryPlacementOfPEGP
			
			, convert(varchar, convert(int, round(((SELECT COUNT(DISTINCT PR.ProcedureId) 
				FROM #Procedures PR 
				JOIN ERS_PostOperativeComplications POC ON PR.ProcId = POC.ProcedureId
				WHERE PR.ReportConsultant = RC.ConsultantId
				AND POC.AntibioticsForInfectionFollowingPEG = 1
				) * 1.0 / NULLIF(
				(SELECT COUNT(DISTINCT ProcedureId) 
				FROM  #Procedures WHERE ReportConsultant = RC.ConsultantId
				), 0)) * 100, 0))) + '%' AS PostProcedureInfectionRequiringAntibioticsP
			
			, convert(varchar, convert(int, round(((SELECT COUNT(DISTINCT PR.ProcedureId) 
				FROM #Procedures PR 
				JOIN ERS_PostOperativeComplications POC ON PR.ProcId = POC.ProcedureId
				WHERE PR.ReportConsultant = RC.ConsultantId
				AND POC.PeritonitisFollowingPEG = 1
				) * 1.0 / NULLIF(
				(SELECT COUNT(DISTINCT ProcedureId) 
				FROM #Procedures WHERE ReportConsultant = RC.ConsultantId
				), 0)) * 100, 0))) + '%' AS PostProcedurePeritonitisP

			, convert(varchar, convert(int, round(((SELECT COUNT(DISTINCT PR.ProcedureId) 
				FROM #Procedures PR 
				JOIN dbo.ERS_UpperGIQA eug	ON PR.ProcId = eug.ProcedureId
				WHERE PR.ReportConsultant = RC.ConsultantId
				AND eug.SignificantHaemorrhage = 1
				) * 1.0 / NULLIF(
				(SELECT COUNT(DISTINCT ProcedureId) 
				FROM #Procedures WHERE ReportConsultant = RC.ConsultantId
				), 0)) * 100, 0))) + '%' AS BleedingRequiringTransfusionP

		FROM  fw_ReportConsultants RC, fw_Consultants C, fw_ReportFilter RF, fw_ProceduresConsultants PC
		WHERE RF.UserId = RC.UserId 
			AND RF.UserId = @UserId
			AND RC.ConsultantId = PC.ConsultantId
			AND PC.ConsultantId = C.ConsultantId
			AND PC.ConsultantTypeId IN (1)
	) AS T
	WHERE TotalPEGProcedures > 0

	DROP TABLE #Procedures
END



GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	2435
-- Description of change
-- NEW report for FNA
------------------------------------------------------------------------------------------------------------------------
GO
if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='report_Fine_Needle_Sampling')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Fine Needle Sampling Report', 'report_Fine_Needle_Sampling')

GO
EXEC dbo.DropIfExist @ObjectName = 'report_Fine_Needle_Sampling',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
Create Procedure report_Fine_Needle_Sampling
  @UserID INT
AS
BEGIN

	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)


			Select	@FromDate = FromDate,
					@ToDate = ToDate,
					@TrustId = TrustId,
					@OperatingHospitalList=OperatingHospitalList
			FROM	ERS_ReportFilter
			where	UserID = @UserId

	
			select  pat.Surname + ', '+ pat.Forename1 as 'Patient', 
			pat.HospitalNumber as 'Hospital No.',
			convert(varchar(14),pat.DateOfBirth,106) as 'DOB.',
			dbo.fnGetAGE(pat.DateOfBirth) as 'Age',
			 prt.ProcedureType ,
			 dbo.fnGetSiteTitle(sites.SiteNo, pr.OperatingHospitalID) AS SiteTitle,
			 spc.NeedleAspirate,
			 spc.NeedleAspirateHistology as 'Needle Aspirate Histology',
			spc.NeedleAspirateMicrobiology as 'Needle Aspirate Microbiology',
			spc.NeedleAspirateVirology as 'Needle Aspirate Virology',
			spc.EUSFNANumberOfPasses as 'EUS FNA Number Of Passes',
			spc.EUSFNANeedleGauge as 'EUS FNA Needle Gauge',
			spc.FNASampleAssessedAtProcedure as 'FNA Sample Assessed',
			spc.AdequateFNA as 'Adequate FNA',
			spc.FNB,
			spc.NeedleBiopsyHistology as 'Needle Biopsy Histology',
			spc.NeedleBiopsyCytology as 'Needle Biopsy Cytology',	
			spc.NeedleBiopsyMicrobiology as 'Needle Biopsy Microbiology',
			spc.NeedleBiopsyVirology as 'Needle Biopsy Virology',
			spc.FNBSampleAssessedAtProcedure as 'FNB Sample Assessed',
			spc.EUSFNBNumberOfPasses as 'EUS FNB Number Of Passes',
			spc.EUSFNBNeedleGauge as 'EUS FNB Needle Gauge',
			spc.FNBSampleAssessedAtProcedure as 'FNB Sample Assessed',
			spc.AdequateFNB as 'Adequate FNB'
			 from ERS_UpperGISpecimens spc
			 left join ERS_Sites sites on sites.siteId= spc.siteId
			 left join ers_procedures pr on  pr.ProcedureId=sites.ProcedureId  
			  left join  ERS_Patients pat on pr.PatientId = pat.PatientId
			 left join ERS_ProcedureTypes prt on pr.ProcedureType=prt.ProcedureTypeId
			 where ( spc.NeedleAspirate=1 or spc.FNB=1)
 				AND pr.OperatingHospitalID  IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) 
				and pr.CreatedOn >= @FromDate AND pr.CreatedOn <= @ToDate 
				and pr.IsActive = 1
				and IsNull(pr.DNA,0) = 0
			order by 1

			

END
GO
GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	2313
-- Description of change
-- NED report Filter By Hospital and Do not show  Error from ERS_errorlog 
------------------------------------------------------------------------------------------------------------------------
GO

ALTER Procedure [dbo].[auditNEDFailedProcedures]
	@UserId int
AS
/****** 24 Dec 2021		:		Mahfuz created for NED Validation JAG Audit report ******/
/****** 03 May 2024		:		Partha Kundu , Do not show  Error from ERS_errorlog TFS 2313 ******/
/****	17/05/2024      :        Partha  Filter by Hospital TFS1811 */
/*		Update History	:		*/
BEGIN


	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'
	
	Declare @NedFailedProcedures Table 
	(
		AutoRowId int identity(1,1) not null,
		ProcedureID int not null,
		ApplicationError varchar(max) Null,
		NEDError varchar(max) null
	);

	Select nl.ProcedureId,nl.ErrorDescription into #tempTableNEDError 
	from ERS_NEDI2FilesLog nl
		INNER JOIN ERS_NEDI2Status en ON nl.[Status] = en.id
		inner join ERS_Procedures p on nl.ProcedureID = p.ProcedureId
		inner join (
				Select ProcedureId,Max(LogID) as MaxLogID 
				from ERS_NEDI2FilesLog 
				Group by ProcedureID) mxl on nl.ProcedureID = mxl.ProcedureID and nl.LogId = mxl.MaxLogID
		Where en.IsError = 1
		--MH added on 10 Mar 2022
		and IsNull(p.DNA,0) = 0
		and p.ModifiedOn between @FromDate and @ToDate
		--17/05/2024     Partha  Filter by Hospital TFS1811
		AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) 
		
	--Select el.ProcedureId,el.ErrorMessage + '. ' + el.ErrorDescription as AppErrorMessage into #tempTableAppError from ERS_ErrorLog el
	--	inner join ERS_Procedures p on el.ProcedureID = p.ProcedureId
	--		inner join (
	--			Select ProcedureId,Max(ErrorLogId) as MaxLogID from ERS_ErrorLog Group by ProcedureID) mxl on el.ProcedureID = mxl.ProcedureID and el.ErrorLogId = mxl.MaxLogID
				
	--			Where p.ModifiedOn between  @FromDate and @ToDate
	--			--MH added on 10 Mar 2022
	--			and IsNull(p.DNA,0) = 0


	-- 1 : Currently NED failed and not sorted or exported
	Insert into @NedFailedProcedures(ProcedureID,ApplicationError,NEDError)
	Select p.ProcedureId
	    --,aep.AppErrorMessage
		,Null
		, nem.ErrorDescription
		from ers_procedures p
		inner join ers_procedureTypes pt on p.ProcedureType = pt.ProcedureTypeId
		left join #tempTableNEDError nem on p.ProcedureId = nem.ProcedureID
		--left join #tempTableAppError aep on p.ProcedureId = aep.ProcedureId
	Where pt.NedExportRequired = 1 
		and p.ProcedureCompleted = 1 
		and p.NEDEnabled = 1
		and IsNull(p.DNA,0) not in (1,2,3)
		and p.NEDExported <> 1
		--MH added on 10 Mar 2022
		and IsNull(p.DNA,0) = 0
		--17/05/2024     Partha  Filter by Hospital TFS1811
		AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) 


		-- 2 : Current NEDexported Successfully but once had NED error (had record in ERS_NEDI2FilesLog
	Insert into @NedFailedProcedures(ProcedureID,NEDError)
	Select p.ProcedureId, nem.ErrorDescription
		from ers_procedures p
		inner join ers_procedureTypes pt on p.ProcedureType = pt.ProcedureTypeId
		left join #tempTableNEDError nem on p.ProcedureId = nem.ProcedureID
	Where pt.NedExportRequired = 1 
		and p.ProcedureCompleted = 1 
		--and p.NEDEnabled = 1
		and IsNull(p.DNA,0) not in (1,2,3)
		and p.NEDExported = 1
		and (IsNull(nem.ErrorDescription,'') <> '')
		--MH added on 10 Mar 2022
		and IsNull(p.DNA,0) = 0
		--17/05/2024     Partha  Filter by Hospital TFS1811
		AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )



	Select distinct
		oh.HospitalName, 
		pat.Surname + ', '+ pat.Forename1 as Patient, 
		pat.HospitalNumber as 'Case No.',
		dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHS number',
		convert(varchar, p.ModifiedOn, 106) as ProcedureDate,
		format(p.ModifiedOn,'hh:mm tt') as ProcedureTime,
		pt.ProcedureType as 'Procedure',
		ltrim(rtrim(lc.Forename + ' ' + lc.Surname)) as ListConsultant,
		e1.Surname + ', '+ e1.Forename as 'Endoscopist 1',
		e2.Surname + ', '+ e2.Forename as 'Endoscopist 2',
		case when p.Endo2Role = 1 or p.Endoscopist2 is null then 'Independent' else '' END as Independant,
		NedFailReport.NEDError
	from ers_procedures p
	inner join @NedFailedProcedures NedFailReport on p.ProcedureId = NedFailReport.ProcedureID
	join (select ListItemNo as PatientStatusId, ListItemText as PatientStatus from ERS_Lists where ListDescription = 'Patient Status') ps on p.PatientStatus = ps.PatientStatusId
	join ERS_Patients pat on p.PatientId = pat.PatientId
	join ERS_OperatingHospitals oh on p.OperatingHospitalID = oh.OperatingHospitalId
	join ERS_ProcedureTypes pt on p.ProcedureType = pt.ProcedureTypeId
	join ERS_Users e1 on p.Endoscopist1 = e1.UserID
	left join ERS_Users e2 on p.Endoscopist2 = e2.UserID
	left join ERS_Users lc on p.ListConsultant = lc.UserID
	join ERS_ReportConsultants rc on rc.ConsultantID = e1.UserID or rc.ConsultantID = e2.UserID
	where p.IsActive = 1 
		and p.ProcedureCompleted = 1
		and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
		and rc.UserID = CASE WHEN @UserId = 1 THEN rc.UserId ELSE @UserId END
		--17/05/2024     Partha  Filter by Hospital TFS1811
		AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
		--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
		--MH added on 10 Mar 2022
		and IsNull(p.DNA,0) = 0
	--order by p.CreatedOn, pt.ProcedureType, e1.Surname
END

GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	2269
-- Description of change
-- New Report Scope Patient
------------------------------------------------------------------------------------------------------------------------
GO

EXEC dbo.DropIfExist @ObjectName = 'auditScopeWithPatientAndProcedureDetails',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
CREATE Procedure [dbo].[auditScopeWithPatientAndProcedureDetails]
	@UserId int
AS
/*
--	Author, Date Created		:		Partha created on 26 Aprr 2024
										17/05/2024     Partha  Filter by Hospital TFS1811
--	Update History				:		
*/
Begin


	DECLARE @FromDate as Date,
		@ToDate as Date,
		@ConsultantId as int,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)


	SELECT rc.ConsultantID , con.Title + ' ' + con.Forename + ' ' + con.Surname AS Endoscopist, rc.AnonimizedID
	INTO #Consultants
	FROM ERS_ReportConsultants rc
	JOIN ERS_Users con on rc.ConsultantID = con.UserID 
	WHERE rc.UserID = @UserId


	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	Select Distinct
	 pat.Forename1 + ' '+ pat.Surname as Patient,
		 pat.HospitalNumber,
		  Convert(varchar(14),Pat.DateofBirth,106) as 'DateofBirth',
	     pt.ProcedureType as 'Procedure',	
		 Convert(varchar(14),P.CreatedOn,106) as 'Procedure Date',
		  'Scope1' as 'Scope',
		 sc.ScopeName
		from ERS_Scopes SC
		 join ERS_Procedures P on P.Instrument1 = Sc.ScopeId
		 join ERS_ProcedureTypes PT on P.ProcedureType = PT.ProcedureTypeId
		 join ERS_Patients PAT on P.PatientId = PAT.PatientId
	   where  p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	   	and p.ProcedureCompleted = 1
		and p.IsActive = 1
		and IsNull(p.DNA,0) = 0
		AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )

		union
		Select Distinct
	 pat.Forename1 + ' '+ pat.Surname as Patient,
		 pat.HospitalNumber,
		  Convert(varchar(14),Pat.DateofBirth,106) as 'DateofBirth',
	     pt.ProcedureType as 'Procedure',
		 
		 Convert(varchar(14),P.CreatedOn,106) as 'Procedure Date',
		  'Scope2' as 'Scope',
		 sc.ScopeName
		from ERS_Scopes SC
		 join ERS_Procedures P on P.Instrument2 = Sc.ScopeId
		 join ERS_ProcedureTypes PT on P.ProcedureType = PT.ProcedureTypeId
		 join ERS_Patients PAT on P.PatientId = PAT.PatientId
       where  p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	   and p.ProcedureCompleted = 1
		and p.IsActive = 1
		and IsNull(p.DNA,0) = 0
	   AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
		Order by 'Procedure Date', sc.ScopeName



End
GO

if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='auditScopeWithPatientAndProcedureDetails')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Scope Patient Procedure Audit', 'auditScopeWithPatientAndProcedureDetails')
GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	2070
-- Description of change
-- Drilldown report add Age and DOB and Filter by Hospital
------------------------------------------------------------------------------------------------------------------------
GO
EXEC dbo.DropIfExist @ObjectName = 'report_JAGOGD_DrillDown',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
CREATE Procedure [dbo].[report_JAGOGD_DrillDown] 
	@UserId int,
	@AnonomizedId int
AS
BEGIN
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
	02		:		01 Aug 2022		Adrian Rename NHSNo Column to match custom Health Service
	03		:		26 APR 2024		Partha Add Date of Birth and Age TFS2070
	04      :       17/05/2024     Partha  Filter by Hospital TFS1811
	05      :       10/06/2024     Partha  Show Endo1 and Endo2 TFS2176
******************************************************************************************************************/
	DECLARE @ConsultantId as int,
			@FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)


	SELECT @ConsultantId = ConsultantID 
	FROM ERS_ReportConsultants
	WHERE AnonimizedID = @AnonomizedId
	AND UserID = @UserId

	SELECT	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	WHERE	UserID = @UserId

	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	SELECT 
			p.ProcedureId,pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			convert(varchar(14),pat.DateOfBirth,106) as 'DOB.',
			dbo.fnGetAGE(pat.DateOfBirth) as 'Age',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate, 
			ps.PatientStatus as 'Patient Status',
			u1.Surname + ', '+ u1.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			e.NEDTerm ExtentDescription,
			(SELECT CASE ue.JManoeuvreId WHEN 1 THEN 'Yes' ELSE 'No' END) AS 'J Manoeuvre',
			eds.Description AS 'Comfort Rate',
			dru.midazolam As 'Midazolam Dose',
			dru.pethidine As 'Pethidine Dose',
			dru.fentanyl As 'Fentanyl Dose',
			case when dru.GeneralAnaesthetic is null then 'No' else 'Yes' end as 'General Anaesthetic',
			CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null then 'No' ELSE 'Yes' END as 'Sedation Used'
	INTO ##ReportTemp
	FROM ERS_Procedures p
		JOIN ERS_Patients pat on p.PatientId = pat.PatientId
		JOIN (select ListItemNo as PatientStatusId, ListItemText as PatientStatus from ERS_Lists where ListDescription = 'Patient Status') ps on p.PatientStatus = ps.PatientStatusId
		JOIN ERS_Users u on (u.UserID = p.Endoscopist1 or (u.UserID = p.Endoscopist2 and p.Endo2Role in (2, 3)))
		Left join ERS_Users u1 (NOLOCK) on u1.UserID = p.Endoscopist1
		left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
		LEFT JOIN dbo.ERS_ProcedureDiscomfortScore epds ON p.ProcedureId = epds.ProcedureId
		LEFT JOIN dbo.ERS_DiscomfortScores eds ON epds.DiscomfortScoreId = eds.UniqueId
		LEFT JOIN ERS_UpperGIPremedication prof on p.ProcedureId = prof.ProcedureId AND prof.DrugName = 'propofol' AND prof.Dose > 0
		LEFT JOIN ERS_UpperGIPremedication midazolam on p.ProcedureId = midazolam.ProcedureId AND midazolam.DrugName = 'midazolam'
		LEFT JOIN fw_ERS_Drugs as dru on P.ProcedureId = dru.ProcId
		LEFT JOIN ERS_ProcedureUpperExtent ue ON ue.ProcedureId = p.ProcedureId AND ue.EndoscopistId = CASE WHEN p.Endoscopist2 = @ConsultantId AND p.Endo2Role IN (2,3) THEN @ConsultantId ELSE ue.EndoscopistId END
		LEFT JOIN ERS_Extent e ON e.UniqueId = ue.ExtentId
		LEFT JOIN (
						SELECT  NEDTerm, procedureid, EndoscopistId 
						FROM ers_procedureupperextent pe
							inner join ers_extent e on e.uniqueid=pe.extentid
							where EndoscopistId = @Consultantid
					) te on te.ProcedureId = p.ProcedureId  
		WHERE u.UserID = @ConsultantId
			AND p.ProcedureCompleted = 1
			AND p.IsActive = 1
			AND p.ProcedureType = 1
			AND p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
			AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
			--AND pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
			--MH added on 31 Mar 2022
			AND IsNull(p.DNA,0) = 0
		ORDER BY p.ProcedureId
	
	declare @SQL nvarchar(1000)
	set @SQL = 'tempdb.sys.sp_rename N''##ReportTemp.NHSNo'', N''' + @HealthService + ' No'' '
	exec sp_executesql @SQL

	Select * from ##ReportTemp
	drop table ##ReportTemp
END

GO

EXEC dbo.DropIfExist @ObjectName = 'report_JAGEUS_DrillDown',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
CREATE Procedure [dbo].[report_JAGEUS_DrillDown] 
	@UserId int,
	@AnonomizedId int
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
	02		:		01 Aug 2022		Adrian Rename NHSNo Column to match custom Health Service
	03		:		26 APR 2024		Partha Add Date of Birth and Age TFS2070
	04      :       17/05/2024     Partha  Filter by Hospital TFS1811
	05      :       10/06/2024     Partha  Show Endo1 and Endo2 TFS2176
******************************************************************************************************************/
BEGIN

	DECLARE @ConsultantId as int,
			@FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select @ConsultantId = ConsultantID 
	from ERS_ReportConsultants
	where AnonimizedID = @AnonomizedId
	and UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select pat.Surname + ', '+ pat.Forename1 as Patient, 
		pat.HospitalNumber as 'Case No.',
		convert(varchar(14),pat.DateOfBirth,106) as 'DOB.',
		dbo.fnGetAGE(pat.DateOfBirth) as 'Age',
		dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
		dbo.fnGender(pat.GenderId) as Gender, 
		convert(varchar, p.CreatedOn, 106) as ProcedureDate,
		ps.PatientStatus as 'Patient Status',
		u1.Surname + ', '+ u1.Forename as 'Endoscopist 1',
		u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',

		--CASE WHEN (CASE 
		--	WHEN p.Endoscopist2 = u.UserID AND p.Endo2Role > 1 THEN CEOI.Retroflexion -- Trainee 
		--	WHEN (p.Endoscopist2 = u.UserID AND p.Endo2Role = 1) OR p.Endoscopist1 = u.UserID THEN CASE 
		--																								WHEN CEOI.Retroflexion = 1 OR CEOI.NED_Retroflexion = 1 
		--																								THEN 1
		--																								ELSE 0
		--																							END -- independent
		--	ELSE 0
		--END) >= 1 THEN 'Yes' ELSE 'No' END as 'Retroflection',
		CASE qa.PatDiscomfortEndo		
			When 6 Then 'Severe' 
			When 5 Then 'Moderate' 
			When 4 Then 'Mild' 
			When 3 Then 'Minimal'
			When 2 Then 'Comfortable' 
			Else 'Not Specified' 
		End As 'Comfort Rate',
		dru.midazolam As 'Midazolam Dose',
		dru.pethidine As 'Pethidine Dose',
		dru.fentanyl As 'Fentanyl Dose',
		dru.propofol as 'Propofol Dose',
		case when dru.GeneralAnaesthetic is null then 'No' else 'Yes' end  as 'General Anaesthetic',
		CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null then 'No' ELSE 'Yes' END as 'Sedation Used'
	INTO ##ReportTemp
	FROM ERS_Procedures p
	join (select ListItemNo as PatientStatusId, ListItemText as PatientStatus from ERS_Lists where ListDescription = 'Patient Status') ps on p.PatientStatus = ps.PatientStatusId
	join ERS_Users u on (u.UserID = p.Endoscopist1 or (u.UserID = p.Endoscopist2 and p.Endo2Role in (2, 3)))
	join ERS_Patients pat on pat.PatientId = p.PatientId
	Left join ERS_Users u1 (NOLOCK) on u1.UserID = p.Endoscopist1
	left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
	left join ERS_UpperGIQA qa on qa.ProcedureId = p.ProcedureId
	--left join ERS_UpperGIPremedication midazolam on p.ProcedureId = midazolam.ProcedureId and midazolam.DrugName = 'Midazolam'
	--left join ERS_UpperGIPremedication pethidine on p.ProcedureId = pethidine.ProcedureId and pethidine.DrugName = 'Pethidine'
	--left join ERS_UpperGIPremedication fentanyl on p.ProcedureId = fentanyl.ProcedureId and fentanyl.DrugName = 'Fentanyl'
	--left join ERS_UpperGIPremedication propofol on p.ProcedureId = propofol.ProcedureId and propofol.DrugName = 'propofol'
	--left join ERS_UpperGIPremedication noSed on p.ProcedureId = noSed.ProcedureId and noSed.DrugName = 'NoSedation'
	LEFT JOIN fw_ERS_Drugs as dru on p.ProcedureID = dru.ProcId
	LEFT JOIN ERS_ColonExtentOfIntubation AS CEOI ON p.ProcedureId = CEOI.ProcedureId
	LEFT JOIN ERS_ColonExtent AS CE ON CEOI.InsertionTo = CE.ExtentID
	LEFT JOIN ERS_ColonExtent AS CE_NED ON CEOI.NED_InsertionTo = CE_NED.ExtentID

	where u.UserID = @ConsultantId
	and p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType in (6,7)
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	--MH added on 31 Mar 2022
	and IsNull(p.DNA,0) = 0
	order by p.ProcedureId

	declare @SQL nvarchar(1000)
	set @SQL = 'tempdb.sys.sp_rename N''##ReportTemp.NHSNo'', N''' + @HealthService + ' No'' '
	exec sp_executesql @SQL

	Select * from ##ReportTemp
	drop table ##ReportTemp

END

GO

EXEC dbo.DropIfExist @ObjectName = 'report_JAGERC_DrillDown',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
CREATE Procedure [dbo].[report_JAGERC_DrillDown] 
	@UserId int,
	@AnonomizedId int
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
	02		:		01 Aug 2022		Adrian Rename NHSNo Column to match custom Health Service
	03		:		26 APR 2024		Partha Add Date of Birth and Age TFS2070
	04      :       17/05/2024     Partha  Filter by Hospital TFS1811
	05      :       10/06/2024     Partha  Show Endo1 and Endo2 TFS2176
******************************************************************************************************************/
BEGIN

	DECLARE @ConsultantId as int,
			@FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select @ConsultantId = ConsultantID 
	from ERS_ReportConsultants
	where AnonimizedID = @AnonomizedId
	and UserID = @UserId

		Select	@FromDate = FromDate,
				@ToDate = ToDate,
				@TrustId = TrustId,
				@OperatingHospitalList=OperatingHospitalList
		FROM	ERS_ReportFilter
		where	UserID = @UserId

		SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			convert(varchar(14),pat.DateOfBirth,106) as 'DOB.',
		   dbo.fnGetAGE(pat.DateOfBirth) as 'Age',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo',
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			ps.PatientStatus as 'Patient Status',
			u1.Surname + ', '+ u1.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			CASE WHEN p.FirstERCP = 1 THEN 'Yes' ELSE 'No' END as 'First ERCP',
			CASE WHEN u.UserID = p.Endoscopist1 THEN
			CASE WHEN ((v.IntendedBileDuct=1 AND v.MajorPapillaBile=1) OR (v.IntendedBileDuct_ER=1 AND v.MajorPapillaBile_ER=1) OR
						(v.IntendedPancreaticDuct=1 AND v.MajorPapillaPancreatic=1) OR (v.IntendedPancreaticDuct_ER=1 AND v.MajorPapillaPancreatic_ER=1))
						AND p.FirstERCP = 1 THEN 'Yes' ELSE 'No' END 
			ELSE
			CASE WHEN ((v.IntendedBileDuct=1 AND v.MajorPapillaBile=1) OR
						(v.IntendedPancreaticDuct=1 AND v.MajorPapillaPancreatic=1))
						AND p.FirstERCP = 1 THEN 'Yes' ELSE 'No' END 
			END
						as 'Successful cannulation of clinically relevant duct at 1st ever ERCP',
			CASE WHEN SR.ProcedureId is not null THEN 'Yes' ELSE 'No' END as 'Stone Removal at first ERCP',
			CASE WHEN ehs.ProcedureId IS NOT NULL and  p.FirstERCP = 1 THEN 'Yes' ELSE 'No' END as 'Extra-hepatic stricture cytology/histology and stent placement at first ERCP',
			CASE qa.PatDiscomfortEndo		
				When 6 Then 'Severe' 
				When 5 Then 'Moderate' 
				When 4 Then 'Mild' 
				When 3 Then 'Minimal'
				When 2 Then 'Comfortable' 
				Else 'Not Specified' 
			End As 'Comfort Rate',
			dru.midazolam As 'Midazolam Dose',
			dru.pethidine As 'Pethidine Dose',
			dru.fentanyl As 'Fentanyl Dose',
			dru.propofol As 'Propofol Dose',
			case when dru.GeneralAnaesthetic is null then 'No' else 'Yes' end  as 'General Anaesthetic',
			CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null then 'No' ELSE 'Yes' END as 'Sedation Used'
	INTO ##ReportTemp
	FROM ERS_Procedures p
	join (select ListItemNo as PatientStatusId, ListItemText as PatientStatus from ERS_Lists where ListDescription = 'Patient Status') ps on p.PatientStatus = ps.PatientStatusId
	join ERS_Users u on (u.UserID = p.Endoscopist1 or (u.UserID = p.Endoscopist2 and p.Endo2Role in (2, 3)))
	join ERS_Patients pat on pat.PatientId = p.PatientId
	Left join ERS_Users u1 (NOLOCK) on u1.UserID = p.Endoscopist1
	left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
	left join (Select DISTINCT p.ProcedureId
				from ERS_Procedures p
				LEFT JOIN ERS_UpperGIIndications i on p.ProcedureId = i.ProcedureId 
				LEFT JOIN (Select max(convert(int,stones)) Stones, sit.ProcedureId from ERS_Sites sit join ERS_ERCPAbnoDuct eed on sit.SiteId = eed.siteId group by sit.ProcedureId) eed ON p.ProcedureId = eed.ProcedureId 
				LEFT JOIN (Select max(convert(int,th.StoneRemoval)) StoneRemoval, max(th.ExtractionOutcome) ExtractionOutcome, s.ProcedureId, th.EndoRole 
						FROM ERS_Sites s
						LEFT JOIN ERS_ERCPTherapeutics th on s.SiteId = th.SiteId 
						where th.StoneRemoval = 1
						and s.RegionId in (Select RegionId from ERS_Regions where ProcedureType = 2 and  Region = 'Common Bile Duct')
						group by s.ProcedureId, th.EndoRole) t on t.ProcedureId = p.ProcedureId  
				LEFT JOIN ERS_Visualisation v on p.ProcedureId = v.ProcedureID 
				WHERE	p.FirstERCP = 1
				AND		CASE WHEN (v.IntendedBileDuct = 1 or v.IntendedBileDuct_ER = 1) and (isnull(v.MajorPapillaBile, 3) > 1 and isnull(v.MajorPapillaBile_ER, 3) > 1) then 0
							 WHEN t.StoneRemoval = 1 and t.ExtractionOutcome IN (3,4) then 0
							 WHEN t.StoneRemoval = 1 and t.ExtractionOutcome NOT IN (3,4) then 1
							 WHEN eed.Stones = 1 then 0
							 WHEN i.ERSCBDStones = 1 or i.ERSGallBladder = 1 then 1
							 ELSE 0
						END = 1
				and (@ConsultantId = p.Endoscopist1 or (@ConsultantId = p.Endoscopist2 and t.EndoRole in (2,3)))) as SR on SR.ProcedureId = p.ProcedureId
	LEFT JOIN (Select DISTINCT pro.ProcedureId
				from ERS_Procedures pro
				join ERS_Sites sit on pro.ProcedureId = sit.ProcedureId 
				join ERS_ERCPAbnoDuct ad on sit.SiteId = ad.SiteId 
				join ERS_UpperGISpecimens spec on sit.SiteId = spec.SiteId 
				join ERS_ERCPTherapeutics thera on sit.SiteId = thera.SiteId 
				where (@ConsultantId = pro.Endoscopist1 or (@ConsultantId = pro.Endoscopist2 and EndoRole in (2,3))) and ad.Stricture = 1
				and (spec.BiopsyQtyHistology > 0 OR spec.BrushCytology = 1 OR spec.CytologyHistology = 1 OR spec.Bile_PanJuiceCytology = 1 OR spec.NeedleAspirateHistology = 1)
				and sit.RegionId in (Select RegionId from ERS_Regions where ProcedureType = 2 and Region in ('Common Hepatic Duct', 'Common Bile Duct'))
				and thera.StentInsertion = 1) as ehs on ehs.ProcedureId = p.ProcedureId
	left join ERS_UpperGIQA qa on qa.ProcedureId = p.ProcedureId
	LEFT JOIN fw_ERS_Drugs as dru on p.ProcedureID = dru.ProcId
	LEFT JOIN dbo.ERS_Visualisation v on v.ProcedureID = p.ProcedureId
	where u.UserID = @ConsultantId
	and p.ProcedureCompleted = 1
	and p.IsActive = 1
	--MH added on 31 Mar 2022
	and IsNull(p.DNA,0) = 0
	and p.ProcedureType = 2
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	order by p.ProcedureId

	declare @SQL nvarchar(1000)
	set @SQL = 'tempdb.sys.sp_rename N''##ReportTemp.NHSNo'', N''' + @HealthService + ' No'' '
	exec sp_executesql @SQL

	Select * from ##ReportTemp
	drop table ##ReportTemp

END

GO
EXEC dbo.DropIfExist @ObjectName = 'report_JAGCOL_DrillDown',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[report_JAGCOL_DrillDown] 
	@UserId int,
	@AnonomizedId int
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
	02		:		01 Aug 2022		Adrian Rename NHSNo Column to match custom Health Service
	03		:		26 APR 2024		Partha Add Date of Birth and Age TFS2070
	04      :       17/05/2024     Partha  Filter by Hospital TFS1811
	05      :       10/06/2024     Partha  Show Endo1 and Endo2 TFS2176
******************************************************************************************************************/
BEGIN

	DECLARE @ConsultantId as int,
			@FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select @ConsultantId = ConsultantID 
	from ERS_ReportConsultants
	where AnonimizedID = @AnonomizedId
	and UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  DISTINCT
			pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			convert(varchar(14),pat.DateOfBirth,106) as 'DOB.',
			dbo.fnGetAGE(pat.DateOfBirth) as 'Age',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			ps.PatientStatus as 'Patient Status',
			u1.Surname + ', '+ u1.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			CASE ple.RectalExamPerformed WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' END AS 'Digital rectal examination',
			CASE ple.RetroflectionPerformed WHEN 1 THEN 'Yes' WHEN 0 THEN '0' END AS 'Retroflection',
			e.NEDTerm as 'Extent of Intubation',
			convert(varchar, CASE WHEN LOWER(pd.PolypDescription) = 'pedunculated' THEN pd.Size END)  + ' mm' as 'Largest Pedunculated Polyp',
			convert(varchar, CASE WHEN LOWER(pd.PolypDescription) = 'submucosal' THEN pd.Size END)  + ' mm' as 'Largest Submucosal Polyp',
			convert(varchar, CASE WHEN LOWER(pd.PolypDescription) = 'sessile' THEN pd.Size END)  + ' mm' as 'Largest Sessile Polyp',
			convert(varchar, CASE WHEN LOWER(pd.PolypDescription) = 'pseudo' THEN pd.Size END)  + ' mm' as 'Largest Pseudopolyps',
			ple.WithdrawalMins as 'Withdrawal Time',
			eds.NEDTerm AS 'Comfort Rate',
			ISNULL(dru.midazolam, 0) As 'Midazolam Dose',
			ISNULL(dru.pethidine, 0) As 'Pethidine Dose',
			ISNULL(dru.fentanyl, 0) As 'Fentanyl Dose',
			case when dru.GeneralAnaesthetic is null then 'No' else 'Yes' end  as 'General Anaesthetic',
			CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null then 'No' ELSE 'Yes' END as 'Sedation Used'
	INTO ##ReportTemp
	FROM ERS_Procedures p
		join (select ListItemNo as PatientStatusId, ListItemText as PatientStatus from ERS_Lists where ListDescription = 'Patient Status') ps on p.PatientStatus = ps.PatientStatusId
		join ERS_Users u on (u.UserID = p.Endoscopist1 or (u.UserID = p.Endoscopist2 and P.Endo2Role in (2, 3)))
		join ERS_Patients pat on pat.PatientId = p.PatientId
		Left join ERS_Users u1 (NOLOCK) on u1.UserID = p.Endoscopist1
		left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
		LEFT JOIN fw_ERS_Drugs as dru on P.ProcedureId = dru.ProcId
		LEFT JOIN ERS_ProcedureLowerExtent ple ON ple.ProcedureId = p.ProcedureId  AND ple.EndoscopistId = CASE WHEN p.Endoscopist2 = @ConsultantId AND p.Endo2Role IN (2,3) THEN @ConsultantId ELSE ple.EndoscopistId END
		LEFT JOIN ERS_Extent e ON e.UniqueId = ple.ExtentId
		LEFT JOIN ERS_ExtentProcedureTypes ept ON ept.ExtentId = e.UniqueId AND ept.ProcedureTypeId = 3
		LEFT JOIN dbo.ERS_ProcedureDiscomfortScore epds ON p.ProcedureId = epds.ProcedureId
		LEFT JOIN dbo.ERS_DiscomfortScores eds ON epds.DiscomfortScoreId = eds.UniqueId
		LEFT JOIN ERS_ProcedureIndications pri ON pri.ProcedureId = p.ProcedureId
		LEFT JOIN ERS_Indications i ON i.UniqueId = pri.IndicationId
		LEFT JOIN ERS_Sites s ON s.ProcedureId = p.ProcedureId
		LEFT JOIN (SELECT S.ProcedureId, MAX(Size) as Size, s.SiteId, pt.[Description] as PolypDescription
					FROM ERS_CommonAbnoPolypDetails pd 
						INNER JOIN ERS_Sites s ON pd.SiteId = s.SiteId 
						INNER JOIN ERS_PolypTypes pt ON pt.UniqueId = pd.PolypTypeId 
						INNER JOIN ERS_Regions r ON r.RegionId = s.RegionId
					WHERE LOWER(pt.[Description]) IN ('sessile','pedunculated','pseudo', 'submucosal')
					GROUP BY s.ProcedureId, s.SiteId, pt.[Description]) pd ON pd.ProcedureId = p.ProcedureId
				
		LEFT JOIN dbo.fw_TattooedLesions tl ON tl.SiteId = s.SiteId
	where u.UserID = @ConsultantId
		and p.ProcedureCompleted = 1
		--MH added on 31 Mar 2022
		and IsNull(p.DNA,0) = 0
		and p.IsActive = 1
		and p.ProcedureType = 3
		and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
		AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
		--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	order by convert(varchar, p.CreatedOn, 106)

	declare @SQL nvarchar(1000)
	set @SQL = 'tempdb.sys.sp_rename N''##ReportTemp.NHSNo'', N''' + @HealthService + ' No'' '
	exec sp_executesql @SQL

	Select * from ##ReportTemp
	drop table ##ReportTemp
END

GO
EXEC dbo.DropIfExist @ObjectName = 'report_JAGSIG_DrillDown',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
Create  Procedure [dbo].[report_JAGSIG_DrillDown] 
	@UserId int,
	@AnonomizedId int
AS
/*****************************************************************************************************************
Update History:
	01		:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
	02		:		01 Aug 2022		Adrian Rename NHSNo Column to match custom Health Service
    03		:		24 Apr 2024		Partha fix duplicate row issue  TFS 3847
	04		:		26 APR 2024		Partha Add Date of Birth and Age TFS2070
	05      :       17/05/2024     Partha  Filter by Hospital TFS1811
	06      :       10/06/2024     Partha  Show Endo1 and Endo2 TFS2176
******************************************************************************************************************/
BEGIN

	DECLARE @ConsultantId as int,
			@FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select @ConsultantId = ConsultantID 
	from ERS_ReportConsultants
	where AnonimizedID = @AnonomizedId
	and UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Forename1 + ' '+ pat.Surname as Patient, 
			pat.HospitalNumber as 'Case No.',
			convert(varchar(14),pat.DateOfBirth,106) as 'DOB.',
			dbo.fnGetAGE(pat.DateOfBirth) as 'Age',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			ps.PatientStatus as 'Patient Status',
			u1.Surname + ', '+ u1.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			CASE ple.RectalExamPerformed WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' END AS 'Digital rectal examination',
			CASE ple.RetroflectionPerformed WHEN 1 THEN 'Yes' WHEN 0 THEN '0' END AS 'Retroflection',
			e.NEDTerm as 'Extent of Intubation',
			convert(varchar, CASE WHEN LOWER(pd.PolypDescription) = 'pedunculated' THEN pd.Size END)  + ' mm' as 'Largest Pedunculated Polyp',
			convert(varchar, CASE WHEN LOWER(pd.PolypDescription) = 'submucosal' THEN pd.Size END)  + ' mm' as 'Largest Submucosal Polyp',
			convert(varchar, CASE WHEN LOWER(pd.PolypDescription) = 'sessile' THEN pd.Size END)  + ' mm' as 'Largest Sessile Polyp',
			convert(varchar, CASE WHEN LOWER(pd.PolypDescription) = 'pseudo' THEN pd.Size END)  + ' mm' as 'Largest Pseudopolyps',
			ple.WithdrawalMins as 'Withdrawal Time',
			eds.NEDTerm AS 'Comfort Rate',
			ISNULL(dru.midazolam, 0) As 'Midazolam Dose',
			ISNULL(dru.pethidine, 0) As 'Pethidine Dose',
			ISNULL(dru.fentanyl, 0) As 'Fentanyl Dose',
			case when dru.GeneralAnaesthetic is null then 'No' else 'Yes' end  as 'General Anaesthetic',
			CASE WHEN dru.Pethidine is null and dru.midazolam is null and dru.Fentanyl is null and dru.GeneralAnaesthetic is null then 'No' ELSE 'Yes' END as 'Sedation Used'
	INTO ##ReportTemp
	FROM ERS_Procedures p
		join (select ListItemNo as PatientStatusId, ListItemText as PatientStatus from ERS_Lists where ListDescription = 'Patient Status') ps on p.PatientStatus = ps.PatientStatusId
		join ERS_Users u on (u.UserID = p.Endoscopist1 or (u.UserID = p.Endoscopist2 and P.Endo2Role in (2, 3)))
		join ERS_Patients pat on pat.PatientId = p.PatientId
		Left join ERS_Users u1 (NOLOCK) on u1.UserID = p.Endoscopist1
		left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
		LEFT JOIN fw_ERS_Drugs as dru on P.ProcedureId = dru.ProcId
		LEFT JOIN ERS_ProcedureLowerExtent ple ON ple.ProcedureId = p.ProcedureId  AND ple.EndoscopistId = CASE WHEN p.Endoscopist2 = @ConsultantId AND p.Endo2Role IN (2,3) THEN @ConsultantId ELSE ple.EndoscopistId END
		LEFT JOIN ERS_Extent e ON e.UniqueId = ple.ExtentId
		LEFT JOIN ERS_ExtentProcedureTypes ept ON ept.ExtentId = e.UniqueId AND ept.ProcedureTypeId = 3
		LEFT JOIN dbo.ERS_ProcedureDiscomfortScore epds ON p.ProcedureId = epds.ProcedureId
		LEFT JOIN dbo.ERS_DiscomfortScores eds ON epds.DiscomfortScoreId = eds.UniqueId
		--LEFT JOIN ERS_ProcedureIndications pri ON pri.ProcedureId = p.ProcedureId
		--LEFT JOIN ERS_Indications i ON i.UniqueId = pri.IndicationId
		--LEFT JOIN ERS_Sites s ON s.ProcedureId = p.ProcedureId
		LEFT JOIN (SELECT S.ProcedureId, MAX(Size) as Size, s.SiteId, pt.[Description] as PolypDescription
					FROM ERS_CommonAbnoPolypDetails pd 
						INNER JOIN ERS_Sites s ON pd.SiteId = s.SiteId 
						INNER JOIN ERS_PolypTypes pt ON pt.UniqueId = pd.PolypTypeId 
						INNER JOIN ERS_Regions r ON r.RegionId = s.RegionId
					WHERE LOWER(pt.[Description]) IN ('sessile','pedunculated','pseudo', 'submucosal')
					GROUP BY s.ProcedureId, s.SiteId, pt.[Description]) pd ON pd.ProcedureId = p.ProcedureId
				
		--LEFT JOIN dbo.fw_TattooedLesions tl ON tl.SiteId = s.SiteId
	where u.UserID = @ConsultantId
	and p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType = 4
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )--Partha , 17/05/2024 TFS1811
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	--MH added on 31 Mar 2022
	and IsNull(p.DNA,0) = 0
	order by p.ProcedureId
	
	declare @SQL nvarchar(1000)
	set @SQL = 'tempdb.sys.sp_rename N''##ReportTemp.NHSNo'', N''' + @HealthService + ' No'' '
	exec sp_executesql @SQL

	Select * from ##ReportTemp
	drop table ##ReportTemp
END
GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha 17.05.24
-- TFS#	1862
-- Description of change
-- New Reports For Nurse
------------------------------------------------------------------------------------------------------------------------
GO

EXEC dbo.DropIfExist @ObjectName = 'report_Nurse_procedure',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO
Create Procedure report_Nurse_procedure
  @UserID INT
AS
BEGIN

	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)

			Select	@FromDate = FromDate,
					@ToDate = ToDate,
					@TrustId = TrustId,
					@OperatingHospitalList=OperatingHospitalList
			FROM	ERS_ReportFilter
			where	UserID = @UserId

			

			select  dbo.fnGetUserName(UserID) as 'Nurse', 'Nurse1' as 'Nurse Type', dbo.fngetUserName(Endoscopist1) as 'Consultant',rm.RoomName, prt.ProcedureType 
			 from ERS_Users usr
			 left join ers_procedures pr on  pr.Nurse1=usr.userId  
			 left join ERS_ProcedureTypes prt on pr.ProcedureType=prt.ProcedureTypeId
			 left join ERS_ImagePort imgp on imgp.ImagePortId= pr.ImagePortId
			 left join ERS_SCH_Rooms rm on rm.RoomId=imgp.RoomId
			 where (usr.IsNurse1=1 or usr.IsNurse2=1)
				and pr.IsActive = 1
				and IsNull(pr.DNA,0) = 0
				AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
 				--AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString((SELECT OperatingHospitalList FROM ERS_ReportFilter WHERE UserID = @UserId),','))
				and pr.CreatedOn >= @FromDate AND pr.CreatedOn <= @ToDate 

 
			 union
			  select  dbo.fnGetUserName(UserID) as 'Nurse', 'Nurse2' as 'Working Nurse Type',  dbo.fngetUserName(Endoscopist1) as 'Consultant',rm.RoomName, prt.ProcedureType 
			 from ERS_Users usr
			 left join ers_procedures pr on  pr.Nurse2=usr.userId  
			 left join ERS_ProcedureTypes prt on pr.ProcedureType=prt.ProcedureTypeId
			 left join ERS_ImagePort imgp on imgp.ImagePortId= pr.ImagePortId
			 left join ERS_SCH_Rooms rm on rm.RoomId=imgp.RoomId
			 where (usr.IsNurse1=1 or usr.IsNurse2=1)
			 and pr.IsActive = 1
			and IsNull(pr.DNA,0) = 0
			AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
			 --AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString((SELECT OperatingHospitalList FROM ERS_ReportFilter WHERE UserID = @UserId),','))
				and pr.CreatedOn >= @FromDate AND pr.CreatedOn <= @ToDate 

			  union
			  select  dbo.fnGetUserName(UserID) as 'Nurse', 'Nurse3' as 'Working Nurse Type',  dbo.fngetUserName(Endoscopist1) as 'Consultant',rm.RoomName, prt.ProcedureType 
			 from ERS_Users usr
			 left join ers_procedures pr on  pr.Nurse3=usr.userId  
			 left join ERS_ProcedureTypes prt on pr.ProcedureType=prt.ProcedureTypeId
			 left join ERS_ImagePort imgp on imgp.ImagePortId= pr.ImagePortId
			 left join ERS_SCH_Rooms rm on rm.RoomId=imgp.RoomId
			 where (usr.IsNurse1=1 or usr.IsNurse2=1)
			 and pr.IsActive = 1
			and IsNull(pr.DNA,0) = 0
			AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
			-- AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString((SELECT OperatingHospitalList FROM ERS_ReportFilter WHERE UserID = @UserId),','))
				and pr.CreatedOn >= @FromDate AND pr.CreatedOn <= @ToDate 

			  union
			  select  dbo.fnGetUserName(UserID) as 'Nurse', 'Nurse4' as 'Working Nurse Type',  dbo.fngetUserName(Endoscopist1) as 'Consultant',rm.RoomName, prt.ProcedureType
			 from ERS_Users usr
			 left join ers_procedures pr on  pr.Nurse4=usr.userId  
			 left join ERS_ProcedureTypes prt on pr.ProcedureType=prt.ProcedureTypeId
			 left join ERS_ImagePort imgp on imgp.ImagePortId= pr.ImagePortId
			 left join ERS_SCH_Rooms rm on rm.RoomId=imgp.RoomId
			 where (usr.IsNurse1=1 or usr.IsNurse2=1)
			 and pr.IsActive = 1
			and IsNull(pr.DNA,0) = 0
			AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
			 --AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString((SELECT OperatingHospitalList FROM ERS_ReportFilter WHERE UserID = @UserId),','))
				and pr.CreatedOn >= @FromDate AND pr.CreatedOn <= @ToDate 
 Order By 1,2

END
GO
if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='report_Nurse_procedure')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Report Nurse', 'report_Nurse_procedure')

GO





------------------------------------------------------------------------------------------------------------------------
--added by mostafiz in this file
------------------------------------------------------------------------------------------------------------------------

EXEC dbo.DropIfExist @ObjectName = 'auditERCPDecompressedDucts',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditERCPDecompressedDucts]
	@UserId int
AS
/*
--	Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
						:		11 May 2022 SG added Health Service Number formatting
						:       21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
*/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100) --added by mostafiz 5/21/24 Filter by Hospital TFS1811

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			CASE WHEN decomp.StoneDecompressed IS NULL AND 
								decomp.StrictureDecompressed IS NULL AND
								decomp.StentDecompressed IS NULL AND
								decomp.BalloonDecompressed IS NULL THEN '?'
						WHEN	ISNULL(decomp.StoneDecompressed, 0) = 0 AND 
								ISNULL(decomp.StrictureDecompressed, 0) = 0 AND
								ISNULL(decomp.StentDecompressed, 0) = 0 AND
								ISNULL(decomp.BalloonDecompressed, 0) = 0 THEN 'No'
						ELSE 'Yes'
					END as 'Successful Decompression',
					STUFF((
						SELECT ', ' + CAST(summary AS VARCHAR(MAX))
						FROM ERS_ERCPTherapeutics t
						join ERS_Sites s on t.SiteId = s.SiteId WHERE (s.ProcedureId  = decomp.ProcedureId) 
						FOR XML PATH(''),TYPE 
						 /* Use .value to uncomment XML entities e.g. &gt; &lt; etc*/
						).value('.','VARCHAR(MAX)') 
					  ,1,2,'') as 'Therapeutic Text',
		  PP_Indic as 'Indication Text'

	FROM ERS_Procedures p
	join ERS_Users u on u.UserID = p.Endoscopist1
	left join ERS_Users u2 on u2.UserID = p.Endoscopist2
	join ERS_Patients pat on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	Left join (	Select	s.ProcedureId,
				sum(convert(int,StoneDecompressed)) StoneDecompressed,
				sum(convert(int,StrictureDecompressed)) StrictureDecompressed,
				sum(convert(int,StentDecompressedDuct)) StentDecompressed,
				sum(convert(int,BalloonDecompressed)) BalloonDecompressed
		from ERS_ERCPTherapeutics t
		join ERS_Sites s on t.SiteId = s.SiteId
		Group by s.ProcedureId) as decomp on decomp.ProcedureId = p.ProcedureId 
	join ERS_ProceduresReporting pp on p.ProcedureId = pp.ProcedureId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType = 2
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	--MH added on 10 Mar 2022
		and IsNull(p.DNA,0) = 0
	Order By p.CreatedOn
END

Go

EXEC dbo.DropIfExist @ObjectName = 'auditERCcompletionOfIntended',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditERCcompletionOfIntended]
	@UserId int
AS
/*
--	Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
						:		11 May 2022 SG added Health Service Number formatting
						:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
*/
BEGIN

	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100), --added by mostafiz 5/21/24 Filter by Hospital TFS1811
			@HealthService as varchar(max)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			CASE WHEN ind.EPlanCanunulate = 1 and thera.Cannulation > 0 THEN 'Yes' 
				 WHEN ind.EPlanCanunulate = 1 and thera.Cannulation = 0 THEN 'Planned but not carried out'
				 WHEN ind.EPlanCanunulate = 0 and thera.Cannulation > 0 THEN 'Carried out but not planned' ELSE '' END as Cannulation,
			CASE WHEN ind.EplanCombinedProcedure  = 1 and thera.RendezvousProcedure > 0 THEN 'Yes' 
				 WHEN ind.EplanCombinedProcedure = 1 and thera.RendezvousProcedure = 0 THEN 'Planned but not carried out'
				 WHEN ind.EplanCombinedProcedure = 0 and thera.RendezvousProcedure > 0 THEN 'Carried out but not planned' ELSE '' END as 'Combined Procedure',
	CASE WHEN ind.EPlanEndoscopicCyst = 1 and thera.EndoscopicCystPuncture > 0 THEN 'Yes' 
				 WHEN ind.EPlanEndoscopicCyst = 1 and thera.EndoscopicCystPuncture = 0 THEN 'Planned but not carried out'
				 WHEN ind.EPlanEndoscopicCyst = 0 and thera.EndoscopicCystPuncture > 0 THEN 'Carried out but not planned' ELSE '' END as 'Endoscopic Cyst Puncture',
	CASE WHEN ind.EMR = 1 and thera.EMR > 0 THEN 'Yes' 
				 WHEN ind.EMR = 1 and thera.EMR = 0 THEN 'Planned but not carried out'
				 WHEN ind.EMR = 0 and thera.EMR > 0 THEN 'Carried out but not planned' ELSE '' END as 'EMR',
	CASE WHEN ind.EplanManometry = 1 and thera.Manometry > 0 THEN 'Yes' 
				 WHEN ind.EplanManometry = 1 and thera.Manometry = 0 THEN 'Planned but not carried out'
				 WHEN ind.EplanManometry = 0 and thera.Manometry > 0 THEN 'Carried out but not planned' ELSE '' END as 'Manometry',
	CASE WHEN ind.EplanNasoPancreatic = 1 and thera.NasopancreaticDrain > 0 THEN 'Yes' 
				 WHEN ind.EplanNasoPancreatic = 1 and thera.NasopancreaticDrain = 0 THEN 'Planned but not carried out'
				 WHEN ind.EplanNasoPancreatic = 0 and thera.NasopancreaticDrain > 0 THEN 'Carried out but not planned' ELSE '' END as 'Naso-pancreatic/biliary drains',
	CASE WHEN ind.EplanStentInsertion = 1 and thera.StentInsertion > 0 THEN 'Yes' 
				 WHEN ind.EplanStentInsertion = 1 and thera.StentInsertion = 0 THEN 'Planned but not carried out'
				 WHEN ind.EplanStentInsertion = 0 and thera.StentInsertion > 0 THEN 'Carried out but not planned' ELSE '' END as 'Stent Insertion',	
	CASE WHEN ind.EplanStentremoval = 1 and thera.StentRemoval > 0 THEN 'Yes' 
				 WHEN ind.EplanStentremoval = 1 and thera.StentRemoval = 0 THEN 'Planned but not carried out'
				 WHEN ind.EplanStentremoval = 0 and thera.StentRemoval > 0 THEN 'Carried out but not planned' ELSE '' END as 'Stent Removal',
	CASE WHEN ind.EplanStentReplacement = 1 and (thera.StentRemoval > 0 AND thera.StentInsertion > 0) THEN 'Yes' 
				 WHEN ind.EplanStentReplacement = 1 and (thera.StentInsertion = 0 OR thera.StentRemoval = 0) THEN 'Planned but not carried out'
				 WHEN ind.EplanStentremoval = 0 and (thera.StentInsertion > 0 AND thera.StentRemoval > 0) THEN 'Carried out but not planned' ELSE '' END as 'Stent Replacement',
	CASE WHEN ind.EplanStoneRemoval = 1 and thera.StoneRemoval > 0 THEN 'Yes' 
				 WHEN ind.EplanStoneRemoval = 1 and thera.StoneRemoval = 0 THEN 'Planned but not carried out'
				 WHEN ind.EplanStoneRemoval = 0 and thera.StoneRemoval > 0 THEN 'Carried out but not planned' ELSE '' END as 'Stone Removal',
	CASE WHEN ind.EplanStrictureDilatation = 1 and thera.StrictureDilatation > 0 THEN 'Yes' 
				 WHEN ind.EplanStrictureDilatation = 1 and thera.StrictureDilatation = 0 THEN 'Planned but not carried out'
				 WHEN ind.EplanStrictureDilatation = 0 and thera.StrictureDilatation > 0 THEN 'Carried out but not planned' ELSE '' END as 'Stricture Dilatation'
	FROM ERS_Procedures p
	join ERS_Users u on u.UserID = p.Endoscopist1
	left join ERS_Users u2 on u2.UserID = p.Endoscopist2
	join ERS_Patients pat on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	left join ( Select s.ProcedureId, 
						sum(cast(t.Cannulation as Int)) as Cannulation
						, sum(cast(t.RendezvousProcedure as Int)) as RendezvousProcedure
						, sum(cast(t.EndoscopicCystPuncture as Int)) as EndoscopicCystPuncture
						, sum(CASE WHEN t.EMRType = 1 then 1 else 0 end) as EMR
						, sum(cast(t.Manometry as Int)) as Manometry
						, sum(cast(t.NasopancreaticDrain as Int)) as NasopancreaticDrain
						, sum(cast(t.StentInsertion as Int)) as StentInsertion
						, sum(cast(t.StentRemoval as Int)) as StentRemoval
						, sum(cast(t.StrictureDilatation  as Int)) as StrictureDilatation
						, sum(CASE WHEN t.ExtractionOutcome in (1, 2) then 1 else 0 end) as StoneRemoval
				FROM ERS_Sites s 
				JOIN ERS_ERCPTherapeutics t on s.SiteId = t.SiteId 
				group by s.ProcedureId) as thera on thera.ProcedureId = p.ProcedureId
	Left Join ERS_UpperGIIndications ind on p.ProcedureId = ind.ProcedureId 
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType = 2
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	--MH added on 10 Mar 2022
		and IsNull(p.DNA,0) = 0
	Order By p.CreatedOn

END

-- Drop Procedure if it already exists
GO

EXEC dbo.DropIfExist @ObjectName = 'auditColonPolyps',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditColonPolyps]
	@UserId int
AS
BEGIN

	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100),
			@HealthService as varchar(max)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			CASE WHEN p.ProcedureType = 3 then 'Colonoscopy' else 'Sigmiodoscopy' end as 'Procedure Type',
			r.Region, 
			dbo.common_polpydetails_summary(s.SiteId, NULL) as 'Details'
	FROM ERS_Procedures p
	join ERS_Users u on u.UserID = p.Endoscopist1
	left join ERS_Users u2 on u2.UserID = p.Endoscopist2
	join ERS_Patients pat on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	join ERS_Sites s on s.ProcedureId = p.ProcedureId 
	join ERS_Regions r on s.RegionId = r.RegionId
	JOIN (SELECT S.ProcedureId, PolypDetailId, Retreived, Successful, Size, TattooedId, r.Region, s.SiteId
				FROM ERS_CommonAbnoPolypDetails pd 
					INNER JOIN ERS_Sites s ON pd.SiteId = s.SiteId 
					INNER JOIN ERS_PolypTypes pt ON pt.UniqueId = pd.PolypTypeId 
					INNER JOIN ERS_Regions r ON r.RegionId = s.RegionId
				WHERE LOWER(pt.[Description]) IN ('sessile','pedunculated','pseudo')) pd ON pd.ProcedureId = p.ProcedureId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType in (3, 4)
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	and ISNULL(p.DNA, 0) = 0
	Order By p.CreatedOn

END
GO

EXEC dbo.DropIfExist @ObjectName = 'auditNurseDiscomfortDetail',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditNurseDiscomfortDetail]
	@UserId int
AS

/*****************************************************************************************************************
Update History:
	01		  :		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
******************************************************************************************************************/

BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100),  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
			@HealthService as varchar(max)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			pt.ProcedureType as 'Procedure',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			eds.[Description] as 'Discomfort Score'
	FROM ERS_Procedures p
	join ERS_ProcedureTypes pt on p.ProcedureType = pt.ProcedureTypeId
	join ERS_Users u on u.UserID = p.Endoscopist1
	left join ERS_Users u2 on u2.UserID = p.Endoscopist2
	join ERS_Patients pat on pat.PatientId = p.PatientId
	INNER JOIN dbo.ERS_ProcedureDiscomfortScore epds ON p.ProcedureId = epds.ProcedureId
	INNER JOIN dbo.ERS_DiscomfortScores eds ON epds.DiscomfortScoreId = eds.UniqueId
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and eds.ListOrderBy >= 3
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	and ISNULL(p.DNA, 0) = 0
END


-- Drop Procedure if it already exists
GO

EXEC dbo.DropIfExist @ObjectName = 'auditTotalProcedures',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditTotalProcedures]
	@UserId int
AS
/*
--	Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
						:		11 May 2022 SG added Health Service Number formatting
*/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100),
			@HealthService as varchar(max)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'
	
Select 
	oh.HospitalName, 
	pat.Surname + ', '+ pat.Forename1 as Patient, 
	pat.HospitalNumber as 'Case No.',
	dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
	dbo.fnGender(pat.GenderId) as Gender, 
	convert(varchar, p.CreatedOn, 106) as ProcedureDate,
	(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
	ps.PatientStatus as 'Patient Status',
	pt.ProcedureType as 'Procedure',
	e1.Surname + ', '+ e1.Forename as 'Endoscopist 1',
	e2.Surname + ', '+ e2.Forename as 'Endoscopist 2',
	case when p.Endo2Role = 1 or p.Endoscopist2 is null then 'Independent' else '' END as Independant
from ers_procedures p
join (select ListItemNo as PatientStatusId, ListItemText as PatientStatus from ERS_Lists where ListDescription = 'Patient Status') ps on p.PatientStatus = ps.PatientStatusId
join ERS_Patients pat on p.PatientId = pat.PatientId
join ERS_OperatingHospitals oh on p.OperatingHospitalID = oh.OperatingHospitalId
join ERS_ProcedureTypes pt on p.ProcedureType = pt.ProcedureTypeId
join ERS_Users e1 on p.Endoscopist1 = e1.UserID
left join ERS_Users e2 on p.Endoscopist2 = e2.UserID
join ERS_ReportConsultants rc on rc.ConsultantID = e1.UserID or rc.ConsultantID = e2.UserID
where p.IsActive = 1 
	and p.ProcedureCompleted = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	--MH added on 10 Mar 2022
		and IsNull(p.DNA,0) = 0
order by p.CreatedOn, pt.ProcedureType, e1.Surname

END

GO


EXEC dbo.DropIfExist @ObjectName = 'auditNoAbnormalFindingsDetail',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE	[dbo].[auditNoAbnormalFindingsDetail]
	@UserId INT
AS
/*
--	Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
						:		11 May 2022 SG added Health Service Number formatting
						:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
*/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100),  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
			@HealthService as varchar(max)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	SELECT  
		DISTINCT pat.Surname + ', '+ pat.Forename1 as Patient, 
		pat.HospitalNumber as 'Case No.',
		dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
		dbo.fnGender(pat.GenderId) as Gender, 
		convert(varchar, p.CreatedOn, 106) as ProcedureDate,
		(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
		u.Surname + ', '+ u.Forename as 'Endoscopist 1',
		u2.Surname + ', '+ u2.Forename as 'Endoscopist 2'
	FROM 
		ERS_Procedures p
		join ERS_Users u on u.UserID = p.Endoscopist1
		left join ERS_Users u2 on u2.UserID = p.Endoscopist2
		join ERS_Patients pat on pat.PatientId = p.PatientId
		join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	WHERE 
		p.ProcedureCompleted = 1
		and p.IsActive = 1
		and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
		and rc.UserID = @UserId
		--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
		AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
		--MH added on 10 Mar 2022
		and IsNull(p.DNA,0) = 0
END

-- Drop Procedure if it already exists
GO

EXEC dbo.DropIfExist @ObjectName = 'auditBowelPrepSummary',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditBowelPrepSummary]
	@UserId int
AS

/*****************************************************************************************************************
Update History:
	01		:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
******************************************************************************************************************/

BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId

Select u.Surname + ', '+ u.Forename as 'Endoscopist',
	case p.ProcedureType when 3 then 'Colonoscopy'
						 when 4 then 'Sigmoidoscopy'
						 else 'unknown' end as 'Procedure Type',
	sum(bpq.Inadequate) as Inadequate,
	sum(bpq.Fair) as Fair,
	sum(bpq.Good) as Good,
	sum(bpq.Excellent) as Excellent,
	sum(bpq.NoBowelPrep) as 'No Bowel Preparation'
	FROM ERS_Procedures p
	join ERS_Users u on u.UserID = p.Endoscopist1
	join ERS_Patients pat on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	join 	(Select ProcedureID, 
				case when isnull(BowelPrepQuality, 0) = 0 then 1 else 0  end as NoBowelPrep  ,
				case when isnull(BowelPrepQuality, 0) = 1 then 1 else 0  end as Inadequate  ,
				case when isnull(BowelPrepQuality, 0) = 2 then 1 else 0  end as Fair  ,
				case when isnull(BowelPrepQuality, 0) = 3 then 1 else 0  end as Good  ,
				case when isnull(BowelPrepQuality, 0) = 4 then 1 else 0  end as Excellent  
			from ERS_BowelPreparation) bpq on p.ProcedureId = bpq.ProcedureID 
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and p.ProcedureType in (3, 4) -- Just want colon and sig reports
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	group by u.Surname + ', '+ u.Forename, p.ProcedureType
	order by u.Surname + ', '+ u.Forename, p.ProcedureType
END
GO

EXEC dbo.DropIfExist @ObjectName = 'auditProcedureSummary',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[auditProcedureSummary] 
	@UserID INT 
AS
/*****************************************************************************************************************
Update History:
	01		:		21 May 2024		Partha TFS1811: Filter by Operating Hospital 
******************************************************************************************************************/
BEGIN
Select Endoscopist1 AS Endoscopist,
	sum(OGD) TotalOGD, sum(EUS) TotalEUS, sum(ERCP) TotalERCP, 
	Sum(Sig) TotalSIG, sum(Colon) TotalCOL, sum(EntAnte) TotalEntAntegrade, sum(EntRetro) TotalEntRetrograde, sum(Proct) TotalProctoscopy
from (Select RC.AnonimizedID
			, C.ConsultantName AS Endoscopist1
			, RC.ConsultantId AS ReportID
			, C.ConsultantName AS Consultant,
			case when ProcedureType =1 then 1 else 0 end as OGD,
			case when ProcedureType in (6, 7) then 1 else 0 end as EUS,
			case when ProcedureType =2 then 1 else 0 end as ERCP,
			case when ProcedureType =3 then 1 else 0 end as Colon,
			case when ProcedureType =4 then 1 else 0 end as Sig,
			case when ProcedureType =5 then 1 else 0 end as Proct,
			case when ProcedureType =8 then 1 else 0 end as EntAnte,
			case when ProcedureType =9 then 1 else 0 end as EntRetro
from ERS_Procedures P
INNER JOIN fw_ReportConsultants RC ON (('E.' + CONVERT(varchar(10), P.Endoscopist2) = RC.ConsultantId AND P.Endo2Role IN (2, 3)) or 'E.' + CONVERT(varchar(10), P.Endoscopist1) = RC.ConsultantId)
INNER JOIN fw_Consultants C ON c.ConsultantId = RC.ConsultantId
INNER JOIN fw_ReportFilter RF ON RF.UserID = RC.UserID
WHERE  RF.UserID = @UserID
and P.IsActive = 1 and p.ProcedureCompleted = 1
AND P.CreatedOn >= RF.FromDate AND P.CreatedOn <= RF.ToDate
--added by Partha 5/21/24 Filter by Hospital TFS1811
AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(RF.OperatingHospitalList,',') )  ) as t
group by AnonimizedID, Endoscopist1, ReportID, Consultant
	ORDER BY Endoscopist1
END
GO

EXEC dbo.DropIfExist @ObjectName = 'auditPolypsGt20mm',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[auditPolypsGt20mm]
	@UserId INT
AS
/*
--	Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
						:		11 May 2022 SG added Health Service Number formatting
*/
BEGIN

	DECLARE @FromDate as Date,
			@ToDate AS DATE,
			@TrustId AS INT,
			@HealthService AS VARCHAR(MAX)

	SELECT	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId
	FROM	dbo.ERS_ReportFilter
	WHERE	UserID = @UserId
	
	SELECT  @HealthService = CustomText FROM dbo.ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	DECLARE @polypSessile AS INT;
	DECLARE @polypPedunculated AS INT;
	DECLARE @polypPseudo AS INT;
	DECLARE @polypSubmucosal AS INT;
	DECLARE @TattooedId AS INT;

	SELECT @polypSessile = UniqueId FROM dbo.ERS_PolypTypes WHERE [Description] = 'Sessile'
	SELECT @polypPedunculated = UniqueId FROM dbo.ERS_PolypTypes WHERE [Description] = 'Pedunculated'
	SELECT @polypPseudo = UniqueId FROM dbo.ERS_PolypTypes WHERE [Description] = 'Pseudo'
	SELECT @polypSubmucosal = UniqueId FROM dbo.ERS_PolypTypes WHERE [Description] = 'Submucosal'
	SELECT @TattooedId = UniqueId FROM dbo.ERS_TattooOptions WHERE [NEDTerm] = 'Yes'

	SELECT  pat.Surname + ', '+ pat.Forename1 AS Patient, 
			pat.HospitalNumber AS [Case No.],
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) AS [NHSNo], 
			dbo.fnGender(pat.GenderId) AS Gender, 
			CONVERT(VARCHAR, p.CreatedOn, 106) AS ProcedureDate,
			(CONVERT(INT,CONVERT(CHAR(8),p.CreatedOn,112))-CONVERT(CHAR(8),pat.DateOfBirth,112))/10000 AS [Age at Procedure],
			u.Surname + ', '+ u.Forename AS [Endoscopist],
			pt.ProcedureType AS [Procedure Type],
			REVERSE(STUFF(REVERSE(A.query('/Type').value('/', 'varchar(max)')), 2, 1, '')) AS [Type],
			CASE WHEN A.query('/Tattoed').value('/', 'varchar(max)') LIKE '%-No%' AND A.query('/Tattoed').value('/', 'varchar(max)') LIKE '%-Yes%' THEN 'Some'
				WHEN A.query('/Tattoed').value('/', 'varchar(max)') LIKE '%-No%' THEN 'No'
				WHEN A.query('/Tattoed').value('/', 'varchar(max)') LIKE '%-Yes%' THEN 'Yes' END AS Tattooed,
			REVERSE(STUFF(REVERSE(A.query('/Tattoed').value('/', 'varchar(max)')), 2, 1, '')) AS [Tattoo Detail],
			REVERSE(STUFF(REVERSE(A.query('/summary').value('/', 'varchar(max)')), 2, 1, '')) AS Summary
	FROM ERS_Procedures (NOLOCK) p 
	JOIN ERS_ProcedureTypes (NOLOCK) pt ON p.ProcedureType = pt.ProcedureTypeId 
	JOIN ERS_Users (NOLOCK) u ON u.UserID = p.Endoscopist1
	JOIN ERS_Patients (NOLOCK) pat ON pat.PatientId = p.PatientId 
	JOIN ERS_ReportConsultants (NOLOCK) rc ON u.UserID = rc.ConsultantID
	OUTER APPLY (SELECT (
						SELECT r.Region + ' - ' + cal1.Summary + ', ' AS [summary],
							   r.Region + '-' + CASE WHEN cal1.Tattooed = 1 OR capd.TattooedId = @TattooedId THEN 'Yes' ELSE 'No' END + ', ' AS Tattoed,
							   --r.Region + '-' + reverse(stuff(reverse(CASE WHEN cal1.Sessile = 1 then 'Sessile polyp(s), ' ELSE '' END +
							   r.Region + '-' + REVERSE(STUFF(REVERSE(CASE WHEN cal1.PolypTypeId = 1 THEN 'Sessile polyp(s), ' ELSE '' END +
												--CASE WHEN cal1.Pedunculated = 1 then 'Pedunculated polyp(s), ' ELSE '' END +
												CASE WHEN cal1.PolypTypeId = 2 THEN 'Pedunculated polyp(s), ' ELSE '' END +
												--CASE WHEN cal1.Pseudopolyps = 1 then 'Pseudopolyps polyp(s), ' ELSE '' END +
												CASE WHEN cal1.PolypTypeId = 3 THEN 'Pseudopolyps polyp(s), ' ELSE '' END +
												--CASE WHEN cal1.Submucosal = 1 then 'Submucosal tumour(s), ' ELSE '' END +
												CASE WHEN coat.TumourExophytic = 2 THEN 'Submucosal tumour(s), ' ELSE '' END +
												CASE WHEN cat.Villous = 1 THEN 'Villous tumour(s), ' ELSE '' END +												
												CASE WHEN cat.Ulcerative = 1 THEN 'Ulcerative tumour(s), ' ELSE '' END +
												CASE WHEN cat.Stricturing = 1 THEN 'Stricturing tumour(s), ' ELSE '' END +
												CASE WHEN cat.Polypoidal = 1 THEN 'Polypoidal tumour(s), ' ELSE '' END ), 2, 1, '')) + ', ' AS [Type]
						FROM dbo.ERS_Sites (NOLOCK) s1
						JOIN dbo.ERS_CommonAbnoLesions (NOLOCK) AS cal1 ON s1.SiteId = cal1.SiteId
						LEFT JOIN dbo.ERS_CommonAbnoPolypDetails (NOLOCK) AS capd ON capd.PolypTypeId = cal1.PolypTypeId
						LEFT JOIN dbo.ERS_PolypTypes (NOLOCK) AS pt ON pt.UniqueId = cal1.PolypTypeId 
						LEFT JOIN dbo.ERS_ColonAbnoTumour (NOLOCK) AS cat ON cat.SiteId = s1.SiteId						
						LEFT JOIN dbo.ERS_CommonAbnoTumour (NOLOCK) AS coat ON coat.SiteId = s1.SiteId
						JOIN dbo.ERS_Regions (NOLOCK) r ON s1.RegionId = r.RegionId
						WHERE s1.ProcedureId = p.ProcedureId 
						AND (
								--(
								--	capd.PolypTypeId = @polypSessile OR
								--	capd.PolypTypeId = @polypPedunculated OR
								--	capd.PolypTypeId = @polypPseudo OR
								--	capd.PolypTypeId = @polypSubmucosal
								--)
							capd.Size >= 20 							
							OR (cat.Submucosal = 1 AND cat.SubmucosalLargest > 20 AND cat.SubmucosalType IN (1,2))
							OR (cat.Villous = 1 AND cat.VillousLargest > 20 AND cat.VillousType IN (1,2))
							OR (cat.Ulcerative = 1 AND cat.UlcerativeLargest > 20 AND cat.UlcerativeType IN (1,2))
							OR (cat.Stricturing = 1 AND cat.StricturingLargest > 20 AND cat.StricturingType IN (1,2))
							OR (cat.Polypoidal = 1 AND cat.PolypoidalLargest > 20 AND cat.PolypoidalType IN (1,2))
							)
						FOR XML PATH(''), TYPE
						) AS A
				) A
	WHERE p.ProcedureCompleted = 1
	AND p.IsActive = 1
	AND p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	AND rc.UserID = @UserId
	AND pat.PatientId IN (SELECT patientId FROM ERS_PatientTrusts WHERE TrustId = @TrustId)
	AND A.query('/summary').value('/', 'varchar(max)') != ''	
	AND ISNULL(p.DNA, 0) = 0
	ORDER BY p.CreatedOn

END
GO

EXEC dbo.DropIfExist @ObjectName = 'auditSummaryByQuarter',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditSummaryByQuarter]
	@UserId int
AS

/*****************************************************************************************************************
Update History:
	01		:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
******************************************************************************************************************/

BEGIN

	DECLARE @FromDate as Date,
			@ToDate as Date,
			@ConsultantId as int,
			@columns NVARCHAR(MAX) = '', 
			@sql     NVARCHAR(MAX) = '',
			@TrustId as int,
			@OperatingHospitalList as varchar(100)  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

	SELECT rc.ConsultantID , con.Title + ' ' + con.Forename + ' ' + con.Surname AS Endoscopist, rc.AnonimizedID
	INTO #Consultants
	FROM ERS_ReportConsultants rc
	JOIN ERS_Users con on rc.ConsultantID = con.UserID 
	WHERE rc.UserID = @UserId

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	Create table #ByQuarterReport (ProcedureType varchar(20), quarterDate datetime, ProcedureCount int)

	insert into #ByQuarterReport 
	select pt.ProcedureType, DATEADD(quarter,DATEDIFF(quarter,0,p.CreatedOn),0) , COUNT(1)
	from ERS_Procedures p
	join	ERS_Patients pat on p.PatientId = pat.PatientId
	join #Consultants con ON con.ConsultantId = p.Endoscopist1
	join ERS_ProcedureTypes pt on pt.ProcedureTypeId = p.ProcedureType 
	where p.IsActive = 1 and p.ProcedureCompleted = 1
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	group by pt.ProcedureType, DATEADD(quarter,DATEDIFF(quarter,0,CreatedOn),0)

	SELECT 
		@columns+=QUOTENAME(ProcedureType) + ','
	FROM 
		ERS_ProcedureTypes
	where ProcedureType in (Select distinct ProcedureType from #ByQuarterReport)
	ORDER BY 
		ProcedureType;

	-- remove the last comma
	if isnull(@columns, '') != ''
	BEGIN
		SET @columns = LEFT(@columns, LEN(@columns) - 1);

		set @sql = '
			Select * from 
			(Select ProcedureType, 
				convert(varchar, DATEPART(year,quarterDate)) + '' Q'' +
				convert(varchar, DATEPART(quarter,quarterDate)) as Quarter,
				   ProcedureCount
				   from #ByQuarterReport
			union 
				select ProcedureType, convert(varchar, DATEPART(year,quarterDate)) + '' Total'', SUM(ProcedureCount)
			from #ByQuarterReport
			group by ProcedureType, convert(varchar, DATEPART(year,quarterDate)) + '' Total''
			union 
				select ProcedureType, ''Total'', SUM(ProcedureCount)
			from #ByQuarterReport
			group by ProcedureType
			) q
			PIVOT (sum(ProcedureCount)
				for ProcedureType IN (' + @columns + ')
				)
				as pt'

		EXECUTE sp_executesql @sql;

	END	
	ELSE
		Select 'No data to display'

	drop table #ByQuarterReport
	drop table #Consultants
END

GO

EXEC dbo.DropIfExist @ObjectName = 'report_JAGEUSHPBOutcome',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[report_JAGEUSHPBOutcome] 
	@UserID INT 
AS
/*
--	Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
--						:		31 Mar 2022		Mahfuz excluded DNA/Cancelled procedures
						:		21 May 2024		Partha TFS1811: Filter by Operating Hospital 
*/

BEGIN
Select --AnonimizedID, 

Endoscopist1, 

--ReportID,

Consultant, 
	count(Consultant) [IndependentDirectlySupervisedTraineeDistantSupervisionTrainee],
		sum(EUS) [Total EUS (HPB)],
		sum(EUSCompleted) as [Total EUS (HPB) Completed],
		Format(sum(EUSCompleted) * 1.0 / IsNull(Nullif(sum(EUS),0),1), 'P2') [EUS (HPB) Completion (>90%)],

		Sum(NonPancreaticFNABiopsy) as TotalNonPancreaticFNABiopsy,
		Sum(NonPancreaticFNABiopsyCompleted) as TotalNonPancreaticFNABiopsyCompleted,
		Format(Sum(NonPancreaticFNABiopsy) * 1.0 / IsNull(NullIf(Sum(NonPancreaticFNABiopsyCompleted),0),1),'P2') [Non Pancreatic FNA Biopsy Completion (>90%)],

		Sum(PancreaticFNABiopsy) as TotalPancreaticFNABiopsy,
		Sum(PancreaticFNABiopsyCompleted) as TotalPancreaticFNABiopsyCompleted,
		Format(Sum(PancreaticFNABiopsy) * 1.0 / IsNull(NullIf(Sum(PancreaticFNABiopsyCompleted),0),1),'P2') [Pancreatic FNA Biopsy Completion (>75%)],		

		Sum(MajorComplications) as TotalMajorComplications,
		Format(Sum(MajorComplications) * 1.0 / IsNull(Nullif(sum(EUS),0),1),'P2') as [Major Complications Percent (<1%)]

from (Select RC.AnonimizedID
			, C.ConsultantName AS Endoscopist1
			, RC.ConsultantId AS ReportID
			, C.ConsultantName AS Consultant,
			case when IsNull(P.ProcedureId,0) > 0 then 1 else 0 end as EUS,
			case when IsNull(P.ProcedureId,0) > 0 and P.ProcedureCompleted = 1 then 1 else 0 end as EUSCompleted,
			case when IsNull(PancreaticProcedure.ProcedureId,0) > 0 then 1 else 0 end as PancreaticFNABiopsy,
			case when IsNull(PancreaticProcedure.ProcedureId,0) > 0 and ProcedureCompleted = 1 then 1 else 0 end as PancreaticFNABiopsyCompleted,
			case when IsNull(NonPancreaticProcedure.ProcedureId,0) > 0 then 1 else 0 end as NonPancreaticFNABiopsy,
			case when IsNull(NonPancreaticProcedure.ProcedureId,0) > 0 and ProcedureCompleted = 1 then 1 else 0 end as NonPancreaticFNABiopsyCompleted,
			case when IsNull(MajorComplicaitons.ProcedureId,0) > 0 then 1 else 0 end as MajorComplications

from ERS_Procedures P
INNER JOIN fw_ReportConsultants RC ON (('E.' + CONVERT(varchar(10), P.Endoscopist2) = RC.ConsultantId AND P.Endo2Role IN (2, 3)) or 'E.' + CONVERT(varchar(10), P.Endoscopist1) = RC.ConsultantId)
INNER JOIN fw_Consultants C ON c.ConsultantId = RC.ConsultantId
INNER JOIN fw_ReportFilter RF ON RF.UserID = RC.UserID
Left join (
Select Distinct P.ProcedureId 
	from ERS_Procedures p
	inner join ERS_Sites s on p.ProcedureId = s.ProcedureId
	inner join ERS_Regions rg on s.RegionId = rg.RegionId and rg.ProcedureType = p.ProcedureType
	inner join ERS_UpperGISpecimens UGS on UGS.SiteId = s.SiteId

Where
	rg.Region in ('Tail','Body','Main Pancreatic Duct','Head','Neck','Uncinate Process','Accessory pancreatic duct','Common bile duct','Major Papilla','Minor Papilla','Medial Wall First Part','Medial Wall Second Part','Medial Wall Third Part')
	And p.ProcedureType = 7
	--MH added on 31 Mar 2022
	and IsNull(p.DNA,0) = 0
and (IsNull(UGS.Biopsy,0) = 1 or IsNull(UGS.NeedleAspirate,0) = 1)) PancreaticProcedure on P.ProcedureId = PancreaticProcedure.ProcedureId

Left join (
		Select Distinct P.ProcedureId 
			from ERS_Procedures p
			inner join ERS_Sites s on p.ProcedureId = s.ProcedureId
			inner join ERS_Regions rg on s.RegionId = rg.RegionId and rg.ProcedureType = p.ProcedureType
			inner join ERS_UpperGISpecimens UGS on UGS.SiteId = s.SiteId

		Where
			rg.Region Not in ('Tail','Body','Main Pancreatic Duct','Head','Neck','Uncinate Process','Accessory pancreatic duct','Common bile duct','Major Papilla','Minor Papilla','Medial Wall First Part','Medial Wall Second Part','Medial Wall Third Part')
		And p.ProcedureType = 7
		and (IsNull(UGS.Biopsy,0) = 1 or IsNull(UGS.NeedleAspirate,0) = 1)) NonPancreaticProcedure on P.ProcedureId = NonPancreaticProcedure.ProcedureId
		--MH added on 31 Mar 2022
		and IsNull(p.DNA,0) = 0
Left Join ERS_ProcedureAdverseEvents MajorComplicaitons
Left Join ERS_AdverseEvents e ON e.UniqueId = MajorComplicaitons.AdverseEventId
	On P.ProcedureId = MajorComplicaitons.ProcedureId
	and e.NEDTerm NOT IN ('None', 'Other')
WHERE  RF.UserID = @UserID
and p.ProcedureType = 7
and P.IsActive = 1 --and p.ProcedureCompleted = 1
AND P.CreatedOn >= RF.FromDate AND P.CreatedOn <= RF.ToDate
--added by Partha 5/21/24 Filter by Hospital TFS1811
AND P.OperatingHospitalID IN (SELECT * FROM dbo.splitString(RF.OperatingHospitalList,',') ) 

--MH added on 10 Mar 2022
and IsNull(p.DNA,0) = 0) as t
group by AnonimizedID, Endoscopist1, ReportID, Consultant
	ORDER BY Endoscopist1
END
GO

EXEC dbo.DropIfExist @ObjectName = 'auditUsersDetails',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditUsersDetails]
	@UserId int
AS
/*
--	Author				:		Duncan Stanyon
--	Update History		:		29 Mar 2022 Mahfuz changed to procedure and new audit report
*/
Begin

DECLARE @cols AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX)

CREATE TABLE #Testdata
(
    UserID INT,
    RoleId VARCHAR(MAX)
);

CREATE TABLE #UserRoles
(
    UserID INT,
	RoleName VARCHAR(MAX)
);

INSERT into #Testdata SELECT UserId, RoleId from ERS_Users;

WITH tmp(UserID, DataItem, RoleId) AS
(
    SELECT
        UserID,
        LEFT(RoleId, CHARINDEX(',', RoleId + ',') - 1),
        STUFF(RoleId, 1, CHARINDEX(',', RoleId + ','), '')
    FROM #Testdata
    UNION all

    SELECT
        UserID,
        LEFT(RoleId, CHARINDEX(',', RoleId + ',') - 1),
        STUFF(RoleId, 1, CHARINDEX(',', RoleId + ','), '')
    FROM tmp
    WHERE
        RoleId > ''
)
insert into #UserRoles 
SELECT distinct
    UserID,
	RoleName
FROM tmp
join ERS_Roles r on tmp.DataItem = r.RoleId 


select @cols = STUFF((SELECT ',' + QUOTENAME(RoleName) 
                    FROM (select distinct RoleName from #UserRoles) a
                    group by RoleName
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')


set @query = N'SELECT * into ##RolesPivot from 
             (
                select UserID, userId as usrid,  RoleName
                FROM #UserRoles
            ) x
            pivot 
            (
                count(usrid)
                for RoleName in (' + @cols + N')
            ) p '
exec sp_executesql @query;

set @query = N'Select	u.Title, 
		u.Forename, 
		u.Surname,
		u.Username as LoginName,
		u.Suppressed, 
		convert(varchar, u.ExpiresOn, 106) ExpiresOn, 
		convert(varchar, u.PasswordExpiresOn, 106) PasswordExpitesOn , 
		convert(varchar, u.LastLoggedIn, 106) LastLoggedIn, 
		convert(varchar, u.WhenCreated, 106) CreatedOn, 
		isnull(cb.Forename, '''') + '' '' + ISNULL(cb.Surname, '''') AS CreatedBy,
		convert(varchar, u.WhenUpdated, 106) UpdatedOn, 
		isnull(mb.Forename, '''') + '' '' + ISNULL(mb.Surname, '''') AS ModifiedBy,
		u.IsListConsultant, 
		u.IsEndoscopist1, 
		u.IsEndoscopist2, 
		u.IsAssistantOrTrainee as IsNurse1, 
		u.IsNurse1 as IsNurse2, 
		u.IsNurse2 as IsNurse3, 
		' + @cols + '
from ERS_Users u
left outer join ERS_Users cb on cb.UserID = u.WhoCreatedId 
left outer join ERS_Users mb on mb.UserID = u.WhoUpdatedId 
join ##RolesPivot rp on u.UserID = rp.UserId
order by u.Surname'

exec sp_executesql @query;


drop table ##RolesPivot
drop table #Testdata
drop table #UserRoles

End

GO

EXEC dbo.DropIfExist @ObjectName = 'auditScopeDetails',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditScopeDetails]
	@UserId int
AS
/*
--	Author, Date Created		:		Mahfuz created on 30 Mar 2022
--	Update History				:		
*/
Begin

SELECT ScopeId,  
	HospitalNames=STUFF  
	(  
		(  
		  SELECT DISTINCT ', '+ CAST(e.HospitalName AS VARCHAR(MAX))  
		  FROM ERS_ScopeOperatingHospitals g, ERS_OperatingHospitals e
		  Where g.OperatingHospitalId = e.OperatingHospitalId and g.ScopeId = t1.ScopeId
		  FOR XMl PATH('')  
		),1,1,''  
	) 
	into #scopeHospital
	FROM ERS_Scopes t1  
	GROUP BY ScopeId 


	SELECT ScopeId,  
	ProcedureTypes=STUFF  
	(  
		(  
		  SELECT DISTINCT ', '+ CAST(e.ProcedureType AS VARCHAR(MAX))  
		  FROM ERS_ScopeProcedures g, ERS_ProcedureTypes e
		  Where g.ProcedureTypeId = e.ProcedureTypeId and g.ScopeId = t1.ScopeId
		  FOR XMl PATH('')  
		),1,1,''  
	) 
	into #scopeProcedures
	FROM ERS_Scopes t1  
	GROUP BY ScopeId 

	
	
	Select
		SC.ScopeId
		,Convert(varchar,SC.WhenCreated,106) as CreationDate 
		,(U1.Forename + ' ' + U1.Surname) as CreatedBy
		,Convert(varchar,SC.WhenUpdated,106) as ModifiedDate
		,(U2.Forename + ' ' + U2.Surname) as ModifiedBy
		,SC.ScopeName as ModelAndSerialNo
		,SC.Suppressed
		,Convert(varchar,SC.SuppressDate,106) as SuppressedDate
		,Case when SC.AllProcedureTypes = 1 then 'All Procedures' Else SP.ProcedureTypes End as UsedInAssociatedProcedures
		,SH.HospitalNames as AssociatedHospitals
		from ERS_Scopes SC
		Left Join ERS_Users U1 on SC.WhoCreatedId = U1.UserID
		Left join ERS_Users U2 on SC.WhoUpdatedId = U2.userId
		Left join #scopeProcedures SP on SC.ScopeId = SP.ScopeId
		Left join #scopeHospital SH on SC.ScopeId = SH.ScopeId
		Order by SC.ScopeName


	Drop table #scopeHospital
	Drop table #scopeProcedures

End
GO


EXEC dbo.DropIfExist @ObjectName = 'auditReferringConsultantDetails',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditReferringConsultantDetails]
	@UserId int
AS
/*
--	Author				:		Duncan Stanyon
--	Update History		:		29 Mar 2022 Mahfuz changed to procedure and new audit report
*/
Begin

	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId
	FROM	ERS_ReportFilter
	where	UserID = @UserId


	SELECT ConsultantId,  
	HospitalNames=STUFF  
	(  
		(  
		  SELECT DISTINCT ', '+ CAST(e.HospitalName AS VARCHAR(MAX))  
		  FROM ERS_ConsultantsHospital g, ERS_ReferralHospitals e
		  Where g.HospitalId = e.HospitalID and g.ConsultantID = t1.ConsultantId
		  FOR XMl PATH('')  
		),1,1,''  
	) 
	into #ConsultantHospital
	FROM ERS_Consultant t1  
	GROUP BY ConsultantId 


	SELECT
		IsNull(UC.Username,'Batch Import') as CreatedBy
		,Convert(varchar(30),C.WhenCreated,106) as CreationDate
		,UU.UserName as LastUpdatedBy
		,Convert(varchar(30),C.WhenUpdated,106) as ModifiedDate
		,c.[ConsultantID]
		,	CASE WHEN c.Forename IS NULL AND c.Initial IS NOT NULL 
					THEN LTRIM(RTRIM((SELECT ISNULL(c.[Title], '') + ' ' + ISNULL(c.[Initial], ''))))
					ELSE LTRIM(RTRIM((SELECT ISNULL(c.[Title], '') + ' ' + ISNULL(c.[Forename], ''))))
			END AS NAME
		,	CASE WHEN c.Forename IS NULL AND c.Initial IS NOT NULL 
					THEN LTRIM(RTRIM((SELECT ISNULL(c.[Title], '') + ' ' + ISNULL(c.[Initial], '') + ' ' + ISNULL(c.[Surname], ''))))
					ELSE LTRIM(RTRIM((SELECT ISNULL(c.[Title], '') + ' ' + ISNULL(c.[Forename], '') + ' ' + ISNULL(c.[Surname], ''))))
			END AS FULLNAME
		,c.[Surname]
		,g.[GroupName] as ConsultantSpecialityGroup
		,g.[Code] as SpecilityCode
		,C.EmailAddress
		,C.GMCCode
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
					WHEN - 1 THEN '(All hospitals)'
                     WHEN 0 THEN '(Unspecified)'
					WHEN 1 THEN (
								SELECT h.[HospitalName]
								FROM [ERS_ReferralHospitals] h
								LEFT JOIN ERS_ConsultantsHospital ch ON h.[HospitalID] = ch.[HospitalID]
								WHERE ch.ConsultantID = c.ConsultantID
								)
                     ELSE CH.HospitalNames
                     END
			) AS AssociatedHospitals
		,CASE WHEN ISNULL(c.[Suppressed], 0) = 0
					THEN 'No'
				ELSE 'Yes'
				END AS Suppressed
                     FROM [ERS_Consultant] c  
	LEFT JOIN [ERS_ConsultantGroup] g ON c.[GroupID] = g.[Code]
	Left Join #ConsultantHospital CH on CH.ConsultantID = c.ConsultantID
	Left join ERS_Users UC on C.WhoCreatedId = UC.UserID
	Left Join ERS_Users UU on C.WhoUpdatedId = UU.UserID
	WHERE c.TrustId = @TrustId
	 AND  c.[Suppressed] = 0
			

End
GO

EXEC dbo.DropIfExist @ObjectName = 'auditEndoscopistWiseAssessmentOfComfortSummary',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[auditEndoscopistWiseAssessmentOfComfortSummary]
	@UserId int
AS
/*
--	Author		:		Mahfuz created on 05 May 2022 - Endoscopist wise Sedation comfort level scores
--	Update History:
				01	-	
				:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
*/
BEGIN

 DECLARE @FromDate as Date,  
   @ToDate as Date,  
   @TrustId as int,
   @OperatingHospitalList as varchar(100)  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

  
 Declare @OGDTotal as decimal,  
   @ERCPTotal as decimal,  
   @ColTotal as decimal,  
   @SigTotal as decimal,  
   @ProctTotal as decimal,  
   @EUSOGDTotal as decimal,  
   @EUSHPBTotal as decimal,  
   @ENTTotal as decimal  
  
  
 Select @FromDate = FromDate,  
   @ToDate = ToDate,  
   @TrustId = TrustId,
   @OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
 FROM ERS_ReportFilter  
 where UserID = @UserId  
  
SELECT rc.ConsultantID , con.Title + ' ' + con.Forename + ' ' + con.Surname AS Endoscopist, rc.AnonimizedID
	INTO #Consultants
	FROM ERS_ReportConsultants rc
	JOIN ERS_Users con on rc.ConsultantID = con.UserID 
	WHERE rc.UserID = @UserId

Declare @EachConsultantId int, @EachConsultantName varchar(100)

Create table #comfortSummary ( 
  AutoRowId int identity(1,1),
  ConsultantId int,
  ConsultantName varchar(100),
  OrderBy int,  
  ComfortScore varchar(100),  
  
  OGD varchar(50),  
  --OGDPercent varchar(25),  
  
  ERCP varchar(50),  
  --ERCPPercent varchar(25),  
  
  Col varchar(50),  
  --ColPercent varchar(25),  
  
  Sig varchar(50),  
  --SigPercent  varchar(25),  
  
  Proct varchar(50),  
  --ProctPercent varchar(25),  
  
  EUSOGD varchar(50),  
  --EUSOGDPercent varchar(25),  
  
  EUSHPB varchar(50),  
  --EUSHPBPercent varchar(25),  
  
  ENT varchar(50)--,  
  --ENTPercent varchar(25)  
  )  
  

declare  curEndoscopists cursor
For Select ConsultantId,Endoscopist from #Consultants order by Endoscopist

Open curEndoscopists
Fetch next from curEndoscopists into @EachConsultantId, @EachConsultantName

While @@FETCH_STATUS = 0
Begin 

 --***** LOOP OVER CURSOR FOR EACH ENDOSCOPIST/CONSULTANT HERE -

 -- Get Group Summary Total for Endoscopists Assessment Scores  
 Select   
   @OGDTotal = SUM(CASE WHEN p.ProcedureType = 1 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @ERCPTotal = SUM(CASE WHEN p.ProcedureType = 2 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @ColTotal = SUM(CASE WHEN p.ProcedureType = 3 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @SigTotal = SUM(CASE WHEN p.ProcedureType = 4 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @ProctTotal = SUM(CASE WHEN p.ProcedureType = 5 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @EUSOGDTotal = SUM(CASE WHEN p.ProcedureType  = 6 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @EUSHPBTotal = SUM(CASE WHEN p.ProcedureType  = 7 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @ENTTotal = SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.NotRecorded = 1 THEN 1 ELSE 0 END)  
 FROM ERS_Procedures p  
 join ERS_Patients pat on p.PatientId = pat.PatientId   
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select pds.ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId between 1 and 6 then 1 else 0 END as NotRecorded   
   from dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1  
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 --and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)   --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
 
  
 INSERT INTO #comfortSummary (ConsultantId,ConsultantName, orderBy, ComfortScore,OGD,ERCP,Col,Sig,Proct,EUSOGD,EUSHPB,ENT)  
 values (@EachConsultantId,@EachConsultantName, 0, '<b>Endoscopists Assessment Scores</b>','<b>' + Cast(@OGDTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@ERCPTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@ColTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@SigTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@ProctTotal as varchar(10)) + '</b>', 
 '<b>' + Cast(@EUSOGDTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@EUSHPBTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@ENTTotal as varchar(10)) + '</b>')  
  
   
  
 Set @OGDTotal = NULLIF(@OGDTotal,0)  
 Set @ERCPTotal = NULLIF(@ERCPTotal,0)  
 Set @ColTotal = NULLIF(@ColTotal,0)  
 Set @SigTotal = NULLIF(@SigTotal,0)  
 Set @ProctTotal = NULLIF(@ProctTotal,0)  
 Set @EUSOGDTotal = NULLIF(@EUSOGDTotal,0)  
 Set @EUSHPBTotal = NULLIF(@EUSHPBTotal,0)  
 Set @ENTTotal = NULLIF(@ENTTotal,0)  
  
 INSERT INTO #comfortSummary (ConsultantId,ConsultantName, orderBy, ComfortScore,OGD,ERCP,Col,Sig,Proct,EUSOGD,EUSHPB,ENT)
 Select @EachConsultantId,@EachConsultantName, 1, 'Not Recorded',  
   Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType  = 6 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType  = 7 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
  
 FROM ERS_Procedures p  
 --join ERS_Patients pat on p.PatientId = pat.PatientId   
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId = 1 then 1 else 0 END as NotRecorded   
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)   --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
  
 UNION  
 Select @EachConsultantId,@EachConsultantName, 2, 'None - resting comfortably throughout',  
   cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType  = 6 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType  = 7 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
  
 FROM ERS_Procedures p  
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId = 2 then 1 else 0 END as RestingComfort   
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1 
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)   --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

 UNION  

 Select @EachConsultantId,@EachConsultantName, 3, 'One or two episodes of mild discomfort, well tolerated',  
   cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType  = 6 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType  = 7 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
  
 FROM ERS_Procedures p  
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId = 3 then 1 else 0 END as OneOrTwo   
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1  
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
-- and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

 UNION  

 Select @EachConsultantId,@EachConsultantName, 4, 'More than two episodes of discomfort, adequately tolerated',  
   cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25))+ ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType  = 6 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType  = 7 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
  
 FROM ERS_Procedures p  
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId = 4 then 1 else 0 END as MoreThanTwo  
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1  
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

 UNION  

 Select @EachConsultantId,@EachConsultantName, 5, 'Significant discomfort, experienced several times during procedure',  
   Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25))+ ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.Significant = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.Significant = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.Significant = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.Significant = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.Significant = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType  = 6 and qa.Significant = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType  = 7 and qa.Significant = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.Significant = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
  
 FROM ERS_Procedures p  
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId = 5 then 1 else 0 END as Significant  
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1   and p.IsActive = 1 
 and rc.ConsultantID = @EachConsultantId
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)   --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811

 UNION  

 Select @EachConsultantId,@EachConsultantName, 6, 'Extreme discomfort frequently during test' as 'Comfort Score',  
   Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25))+ ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType  = 6 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType  = 7 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
   Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.Extreme = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
  
 FROM ERS_Procedures p  
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId = 6 then 1 else 0 END as Extreme   
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
  
 -- 2nd part Nurse Assessment Scores  
 -- Get Group Summary Total for Endoscopists Assessment Scores  
 Select   
   @OGDTotal = SUM(CASE WHEN p.ProcedureType = 1 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @ERCPTotal = SUM(CASE WHEN p.ProcedureType = 2 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @ColTotal = SUM(CASE WHEN p.ProcedureType = 3 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @SigTotal = SUM(CASE WHEN p.ProcedureType = 4 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @ProctTotal = SUM(CASE WHEN p.ProcedureType = 5 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @EUSOGDTotal = SUM(CASE WHEN p.ProcedureType  = 6 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @EUSHPBTotal = SUM(CASE WHEN p.ProcedureType  = 7 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @ENTTotal = SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.NotRecorded = 1 THEN 1 ELSE 0 END)  
 FROM ERS_Procedures p  
 --join ERS_Patients pat on p.PatientId = pat.PatientId   
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId between 1 and 6 then 1 else 0 END as NotRecorded   
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1  
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
-- and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)   --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
  
 IF (SELECT COUNT(1) FROM ERS_ReportConsultants where UserID = @UserId) > 1    
 BEGIN  
  --Display nurses score  
  INSERT INTO #comfortSummary (ConsultantId,ConsultantName, orderBy, ComfortScore,OGD,ERCP,Col,Sig,Proct,EUSOGD,EUSHPB,ENT) 
  values (@EachConsultantId,@EachConsultantName, 10, '<b>Nurse Assessment Scores</b>','<b>' + Cast(@OGDTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@ERCPTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@ColTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@SigTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@ProctTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@EUSOGDTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@EUSHPBTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@ENTTotal as varchar(10)) + '</b>')  
  
 Set @OGDTotal = NULLIF(@OGDTotal,0)  
 Set @ERCPTotal = NULLIF(@ERCPTotal,0)  
 Set @ColTotal = NULLIF(@ColTotal,0)  
 Set @SigTotal = NULLIF(@SigTotal,0)  
 Set @ProctTotal = NULLIF(@ProctTotal,0)  
 Set @EUSOGDTotal = NULLIF(@EUSOGDTotal,0)  
 Set @EUSHPBTotal = NULLIF(@EUSHPBTotal,0)  
 Set @ENTTotal = NULLIF(@ENTTotal,0)  
  
  INSERT INTO #comfortSummary  (ConsultantId,ConsultantName, orderBy, ComfortScore,OGD,ERCP,Col,Sig,Proct,EUSOGD,EUSHPB,ENT)
  Select @EachConsultantId,@EachConsultantName, 11, 'Not Recorded',  
    Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 6 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 7 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8,9) and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
  
  FROM ERS_Procedures p  
  join ERS_Users u on u.UserID = p.Endoscopist1  
  join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
  join ( Select  ProcedureId,  
     CASE WHEN pds.DiscomfortScoreId = 1 then 1 else 0 END as NotRecorded   
     FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
  where p.ProcedureCompleted = 1  
  and rc.ConsultantID = @EachConsultantId
  and p.IsActive = 1  
  and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
  and rc.UserID = @UserId  
  --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)   --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
  AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

  UNION  

  Select @EachConsultantId,@EachConsultantName, 12, 'None - resting comfortably throughout',  
    Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 6 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 7 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8,9) and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
  FROM ERS_Procedures p  
  join ERS_Users u on u.UserID = p.Endoscopist1  
  join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
  join ( Select  ProcedureId,  
     CASE WHEN pds.DiscomfortScoreId = 2 then 1 else 0 END as RestingComfort   
     FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
  where p.ProcedureCompleted = 1  
  and rc.ConsultantID = @EachConsultantId
  and p.IsActive = 1  
  and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
  and rc.UserID = @UserId  
  --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)   --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
  AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

  UNION  

  Select @EachConsultantId,@EachConsultantName, 13, 'One or two episodes of mild discomfort, well tolerated',  
    Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 6 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 7 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8,9) and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
  FROM ERS_Procedures p  
  join ERS_Users u on u.UserID = p.Endoscopist1  
  join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
  join ( Select  ProcedureId,  
     CASE WHEN pds.DiscomfortScoreId = 3 then 1 else 0 END as OneOrTwo   
     FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
  where p.ProcedureCompleted = 1  
  and rc.ConsultantID = @EachConsultantId
  and p.IsActive = 1  
  and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
  and rc.UserID = @UserId  
  --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)   --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
  AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

  UNION 
  
  Select @EachConsultantId,@EachConsultantName, 14, 'More than two episodes of discomfort, adequately tolerated',  
    Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 6 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 7 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8,9) and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
  FROM ERS_Procedures p  
  join ERS_Users u on u.UserID = p.Endoscopist1  
  join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
  join ( Select  ProcedureId,  
     CASE WHEN pds.DiscomfortScoreId = 4 then 1 else 0 END as MoreThanTwo  
     FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
  where p.ProcedureCompleted = 1 
  and rc.ConsultantID = @EachConsultantId
  and p.IsActive = 1  
  and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
  and rc.UserID = @UserId  
 -- and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)   --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

  UNION  

  Select @EachConsultantId,@EachConsultantName, 15, 'Significant discomfort, experienced several times during procedure',  
    Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.Significant = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.Significant = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.Significant = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.Significant = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.Significant = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 6 and qa.Significant = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 7 and qa.Significant = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8,9) and qa.Significant = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
  FROM ERS_Procedures p  
  join ERS_Users u on u.UserID = p.Endoscopist1  
  join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
  join ( Select  ProcedureId,  
     CASE WHEN pds.DiscomfortScoreId = 5 then 1 else 0 END as Significant  
     FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
  where p.ProcedureCompleted = 1  
  and rc.ConsultantID = @EachConsultantId
  and p.IsActive = 1  
  and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
  and rc.UserID = @UserId  
 -- and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

  UNION  

  Select @EachConsultantId,@EachConsultantName, 16, 'Extreme discomfort frequently during test' as 'Comfort Score',  
    Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 6 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 7 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8,9) and qa.Extreme = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
  FROM ERS_Procedures p  
  join ERS_Users u on u.UserID = p.Endoscopist1  
  join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
  join ( Select  ProcedureId,  
     CASE WHEN pds.DiscomfortScoreId = 6 then 1 else 0 END as Extreme   
     FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
  where p.ProcedureCompleted = 1  
  and rc.ConsultantID = @EachConsultantId
  and p.IsActive = 1  
  and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
  and rc.UserID = @UserId  
 -- and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24  Filter by Hospital TFS1811
 END  
  
 --Third section - Patient Assessment Score  
  
 -- Get Group Summary Total for Patient Assessment Scores  
 Select   
   @OGDTotal = SUM(CASE WHEN p.ProcedureType = 1 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @ERCPTotal = SUM(CASE WHEN p.ProcedureType = 2 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @ColTotal = SUM(CASE WHEN p.ProcedureType = 3 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @SigTotal = SUM(CASE WHEN p.ProcedureType = 4 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @ProctTotal = SUM(CASE WHEN p.ProcedureType = 5 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @EUSOGDTotal = SUM(CASE WHEN p.ProcedureType  = 6 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @EUSHPBTotal = SUM(CASE WHEN p.ProcedureType  = 7 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) ,  
   @ENTTotal = SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.NotRecorded = 1 THEN 1 ELSE 0 END)  
 FROM ERS_Procedures p  
 --join ERS_Patients pat on p.PatientId = pat.PatientId   
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId between 1 and 6 then 1 else 0 END as NotRecorded   
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1  
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)   --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24  Filter by Hospital TFS1811
  
 Set @OGDTotal = NULLIF(@OGDTotal,0)  
 Set @ERCPTotal = NULLIF(@ERCPTotal,0)  
 Set @ColTotal = NULLIF(@ColTotal,0)  
 Set @SigTotal = NULLIF(@SigTotal,0)  
 Set @ProctTotal = NULLIF(@ProctTotal,0)  
 Set @EUSOGDTotal = NULLIF(@EUSOGDTotal,0)  
 Set @EUSHPBTotal = NULLIF(@EUSHPBTotal,0)  
 Set @ENTTotal = NULLIF(@ENTTotal,0)  
  
 INSERT INTO #comfortSummary (ConsultantId,ConsultantName, orderBy, ComfortScore,OGD,ERCP,Col,Sig,Proct,EUSOGD,EUSHPB,ENT)  
 values (@EachConsultantId,@EachConsultantName, 20, '<b>Patient Assessment Scores</b>','<b>' + Cast(@OGDTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@ERCPTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@ColTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@SigTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@ProctTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@EUSOGDTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@EUSHPBTotal as varchar(10)) + '</b>',  
 '<b>' + Cast(@ENTTotal as varchar(10)) + '</b>')  
  
 INSERT INTO #comfortSummary  (ConsultantId,ConsultantName, orderBy, ComfortScore,OGD,ERCP,Col,Sig,Proct,EUSOGD,EUSHPB,ENT)
 Select @EachConsultantId,@EachConsultantName, 21, 'Not Recorded',  
   Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 6 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 7 and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.NotRecorded = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8,9) and qa.NotRecorded = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
 FROM ERS_Procedures p  
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId = 1 then 1 else 0 END as NotRecorded   
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1  
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811

 UNION  

 Select @EachConsultantId,@EachConsultantName, 22, 'None - resting comfortably throughout',  
   Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  

    Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 6 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 7 and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.RestingComfort = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8,9) and qa.RestingComfort = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
 FROM ERS_Procedures p  
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId = 2 then 1 else 0 END as RestingComfort   
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1  
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811

 UNION  

 Select @EachConsultantId,@EachConsultantName, 23, 'One or two episodes of mild discomfort, well tolerated',  
   Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 6 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 7 and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8,9) and qa.OneOrTwo = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
 FROM ERS_Procedures p  
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId = 3 then 1 else 0 END as OneOrTwo   
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1  
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

 UNION  

 Select @EachConsultantId,@EachConsultantName, 24, 'More than two episodes of discomfort, adequately tolerated',  
   Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 6 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 7 and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8,9) and qa.MoreThanTwo = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
 FROM ERS_Procedures p  
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId = 4 then 1 else 0 END as MoreThanTwo  
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1  
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 -- and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811

 UNION  

 Select @EachConsultantId,@EachConsultantName, 25, 'Significant discomfort, experienced several times during procedure',  
   Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.Significant = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.Significant = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.Significant = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.Significant = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.Significant = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 6 and qa.Significant = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 7 and qa.Significant = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.Significant = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8,9) and qa.Significant = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
 FROM ERS_Procedures p  
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId = 5 then 1 else 0 END as Significant  
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1  
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811

 UNION  

 Select @EachConsultantId,@EachConsultantName, 26, 'Extreme discomfort frequently during test' as 'Comfort Score',  
   Cast(SUM(CASE WHEN p.ProcedureType = 1 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 1 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @OGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 2 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 2 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @ERCPTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 3 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 3 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @ColTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 4 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 4 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @SigTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType = 5 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 5 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @ProctTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 6 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 6 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @EUSOGDTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType  = 7 and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType = 7 and qa.Extreme = 1 THEN 1 ELSE 0 END) / @EUSHPBTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)',  
  
    Cast(SUM(CASE WHEN p.ProcedureType in (8, 9) and qa.Extreme = 1 THEN 1 ELSE 0 END) as varchar(25)) + ' - (' +  
    CAST(CAST(ROUND((SUM(CASE WHEN p.ProcedureType in (8,9) and qa.Extreme = 1 THEN 1 ELSE 0 END) / @ENTTotal)*100,2) as NUMERIC(5,2)) as varchar(20))+'%)'  
 FROM ERS_Procedures p  
 join ERS_Users u on u.UserID = p.Endoscopist1  
 join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID   
 join ( Select  ProcedureId,  
    CASE WHEN pds.DiscomfortScoreId = 6 then 1 else 0 END as Extreme   
    FROM dbo.ERS_ProcedureDiscomfortScore AS pds) as qa on p.ProcedureId = qa.ProcedureId  
 where p.ProcedureCompleted = 1  
 and rc.ConsultantID = @EachConsultantId
 and p.IsActive = 1  
 and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate  
 and rc.UserID = @UserId  
 --and p.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
 AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
  

 --***** LOOP OVER CURSOR FOR EACH ENDOSCOPIST/CONSULTANT FINISHES HERE -

	Fetch next from curEndoscopists into @EachConsultantId, @EachConsultantName

 	End
Close curEndoscopists
Deallocate curEndoscopists

 select
  --ConsultantId,
  ConsultantName,
  ComfortScore,  
  OGD,  
  ERCP,  
  Col,  
  Sig,  
  Proct,  
  EUSOGD,  
  EUSHPB,  
  ENT from #comfortSummary order by ConsultantName,orderBy  
  
  Drop table #comfortSummary
  Drop table #Consultants

End
GO

EXEC dbo.DropIfExist @ObjectName = 'auditBronchEbusDetails',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[auditBronchEbusDetails] @UserId INT
AS
/*
--	Author		:		Mahfuz created on On 11 May 2022 - Bronchoscopy & Ebus details JAG GRS report
--	Update History:
				  :		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
				
*/
BEGIN

DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

Declare @tblBroncData as Table
(
	AutoId Int Identity(1,1),
	ProcedureId int not null,
	PatientName varchar(100) not null,
	PatientDOB varchar(30) null,
	CaseNoteNo varchar(50) null,
	NHSNo varchar(50) null,
	Gender varchar(20) null,
	ProcedureDate varchar(30) not null,
	ReferralDate varchar(30) null,
	BronchRequestedDate varchar(30) null,
	AgeAtProcedure int not null,
	ProcedureType varchar(50) not null,
	Endoscopist varchar(100) null,
	ListConsultant varchar(100) null,
	AccessVia varchar(100) null,
	WasChestCTTakenPriorBronc varchar(5) null,
	IsCASuspected varchar(5) null,
	WasTumourSeen	varchar(10) null,
	WasBiopsyTaken	varchar(5) null,
	BiopsyCytopathologyResult varchar(max) null,
	WasMolecularProfileSent	varchar(5) null,
	WasProfileSuccessful	varchar(5) null,
	WasPatientConsentDocumented	varchar(5) null,
	ConsentPerformedBy varchar(100) null,
	WasRisksDocumented varchar(5) null,
	WasWHOChecklistCompleted varchar(50) null,
	WasInfoLeafletProvided varchar(5) null,
	WasSedationUsed varchar(10) null,
	NameOfSedationUsed varchar(500) null,
	WasSedationMonitored varchar(5) null,
	WasReversalAgentUsed varchar(5) null,
	ReversalAgentUsedName varchar(500) null,
	WasEvidenceOfDecontamination varchar(5) null,
	Was62DayTargetAchieved varchar(5) null
)
	--select * from dbo.ERS_ReportFilter Where UserId = @UserId
	
	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	dbo.ERS_ReportFilter
	where	UserID = @UserId

	Insert into @tblBroncData(ProcedureId,PatientName,PatientDOB,CaseNoteNo,NHSNo,Gender,ProcedureDate,AgeAtProcedure,ProcedureType,Endoscopist,ListConsultant,WasWHOChecklistCompleted)
	Select  
			P.ProcedureId,
			pat.Surname + ', '+ pat.Forename1 as Patient, 
			Convert(varchar,pat.DateOfBirth,106) as PatientDOB,
			pat.HospitalNumber as 'Case No.',
			pat.NHSNo as 'NHS number', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as 'Procedure date',
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at procedure',
			pt.ProcedureType as 'Procedure type',
			u.Surname + ', '+ u.Forename as 'Endoscopist',
			ListCons.Surname + ', '+ ListCons.Forename as 'ListConsultant',
			Case When SurgicalSafetyCheckListCompleted = 1 then 'Yes' else 'No' end 
	FROM dbo.ERS_Procedures p
	join dbo.ERS_ProcedureTypes pt on p.ProcedureType = pt.ProcedureTypeId
	join dbo.ERS_Patients pat on pat.PatientId = p.PatientId
	join dbo.ERS_Users u on u.UserID = p.Endoscopist1
	join dbo.ERS_ReportConsultants rc on u.UserID = rc.ConsultantID
	Left Join dbo.ERS_Users ListCons on ListCons.UserId = P.ListConsultant
	
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and P.ProcedureType in (10,11) --Bronchoscopy, Ebus
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
		and IsNull(p.DNA,0) = 0
	--and pat.PatientId in (Select patientId from dbo.ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	
	order by P.ProcedureId,p.CreatedOn, pat.Surname + ', '+ pat.Forename1


	----Do all updates here


	--Patient Consent, CA suspected, CT Scan available
	Update RD
	Set RD.WasPatientConsentDocumented = (Case P.PatientConsent When 1 then 'No' When 2 then 'Yes' else '' end),
	RD.ConsentPerformedBy = Ltrim(Rtrim(U.Title + ' ' + U.Forename + ' ' + U.Surname)),
	RD.WasChestCTTakenPriorBronc = (Case BRCPath.CTScanAvailable When 1 then 'Yes' else 'No' end),
	RD.IsCASuspected = (Case BRCPath.LCaSuspectedBySpecialist When 1 then 'Yes' else 'No' end),
	RD.AccessVia = AV.ListItemText,
	RD.BronchRequestedDate = (Case When (BRCPath.DateBronchRequested is not null) then Convert(varchar,BRCPath.DateBronchRequested,106) else '' end),
	RD.ReferralDate = (Case When (BRCPath.DateOfReferral is not null) then Convert(varchar,BRCPath.DateOfReferral,106) else '' end),
	RD.Was62DayTargetAchieved = (Case When (BRCPath.DateOfReferral is null) Then '' When (DateDiff(day,BRCPath.DateOfReferral,P.CreatedOn) > 62) then 'No' else 'Yes' end)

	From @tblBroncData RD
	Left Join dbo.ERS_Procedures P on RD.ProcedureId = P.ProcedureId
	Left Join dbo.ERS_BRT_BronchoPathology BRCPath on P.ProcedureId = BRCPath.ProcedureId
	Left Join dbo.ERS_Users U on P.WhoCreatedId = U.UserId
	Left join 
		(Select ListItemNo,ListItemText from dbo.ERS_Lists Where ListDescription = 'AccessMethod Thoracic') AV on P.Instrument2 = AV.ListItemNo
	
	-- Select * from ERS_BRT_BronchoPathology

	--Reversal agent / Sedation
	Update RD
	Set RD.WasReversalAgentUsed = (Case  When (RA.ReversingAgentUsed <> '') Then 'Yes' else 'No' end),
	RD.ReversalAgentUsedName = RA.ReversingAgentUsed,
	RD.WasSedationUsed = (Case When NOSED.ProcedureId is NOT null Then 'No' When IsNull(SED.ProcedureId,'') <> '' Then 'Yes' Else 'Unknown' end),
	RD.NameOfSedationUsed = SEDUSED.SedationUsed
	From @tblBroncData RD
		Left Join (Select ProcedureId,Stuff((Select ', ' + AgentUsed
	From (Select PM.ProcedureId,D.DrugName + ' ' + Cast(PM.Dose as varchar(10))  + ' ' + IsNull(PM.Units,'') + ' via ' + PM.DeliveryMethod as AgentUsed
	from dbo.ERS_UpperGIPremedication PM
	Inner join dbo.ERS_DrugList D on PM.DrugNo = D.DrugNo
	Where D.IsReversingAgent = 1 and PM.DrugNo is not null) x
	Where ProcedureId = UGPM.ProcedureId
	For XML Path ('')), 1, 1, '') as ReversingAgentUsed
	From dbo.ERS_UpperGIPremedication UGPM
	Group by UGPM.ProcedureId) RA On RD.ProcedureId = RA.ProcedureId
	Left join (Select Distinct PM.ProcedureId
		from dbo.ERS_UpperGIPremedication PM
		Where (PM.DrugNo = -2 or PM.DrugNo > -1) and PM.DrugNo is not null) SED On RD.ProcedureId = SED.ProcedureId
	Left join (Select Distinct PM.ProcedureId
		from dbo.ERS_UpperGIPremedication PM
		Where PM.DrugNo = -1 ) NOSED On RD.ProcedureId = NOSED.ProcedureId
	Left Join (Select ProcedureId,Stuff((Select ', ' + AgentUsed
	From (Select PM.ProcedureId,D.DrugName + ' ' + Cast(PM.Dose as varchar(10))  + ' ' + IsNull(PM.Units,'') + ' via ' + PM.DeliveryMethod as AgentUsed
	from dbo.ERS_UpperGIPremedication PM
	Inner join dbo.ERS_DrugList D on PM.DrugNo = D.DrugNo
	Where D.IsReversingAgent <> 1 and PM.DrugNo is not null) x
	Where ProcedureId = UGPM.ProcedureId
	For XML Path ('')), 1, 1, '') as SedationUsed
	From dbo.ERS_UpperGIPremedication UGPM
	Group by UGPM.ProcedureId) SEDUSED On RD.ProcedureId = SEDUSED.ProcedureId


	--Tumour / Biopsy
	Update RD
	Set RD.WasTumourSeen= (Case When (DEFTM.ProcedureId Is not null) then 'Yes' When (POSTM.ProcedureId is not null) then 'Possible' When (NOTM.ProcedureId Is not null) then 'No' else 'Not known' end),
		RD.WasBiopsyTaken = (Case When (Biopsy.ProcedureId Is not null) then 'Yes' else 'No' end),
		RD.BiopsyCytopathologyResult = PathlogyResult.PP_Pathology
	From @tblBroncData RD
	Left join (
		Select Distinct S.ProcedureID	
			from dbo.ERS_BRTAbnoDescriptions  BRTABN 
			Inner join dbo.ERS_Sites S on BRTABN.SiteId = S.SiteId 
			Where BRTABN.MucosalIrregularity = 3) DEFTM on DEFTM.ProcedureId = RD.ProcedureID
	Left join (
		Select Distinct S.ProcedureID	
			from dbo.ERS_BRTAbnoDescriptions  BRTABN 
			Inner join dbo.ERS_Sites S on BRTABN.SiteId = S.SiteId 
			Where BRTABN.MucosalIrregularity = 2) POSTM on POSTM.ProcedureId = RD.ProcedureID
	Left join (
		Select Distinct S.ProcedureID	
			from dbo.ERS_BRTAbnoDescriptions  BRTABN 
			Inner join dbo.ERS_Sites S on BRTABN.SiteId = S.SiteId 
			Where BRTABN.MucosalIrregularity = 0) NOTM on NOTM.ProcedureId = RD.ProcedureID
	Left Join (		
			Select Distinct ProcedureID 
			From dbo.ERS_BRTSpecimens BRTSP 
			inner join dbo.ERS_Sites S on BRTSP.SiteID = S.SiteID
			Where 1 = 1 and
			 (
				IsNull(EndobronchialTB,0) > 0
				Or IsNull(EndobronchialHistology,0) > 0
				Or IsNull(EndobronchialBacteriology,0) > 0
				Or IsNull(EndobronchialVirology,0) > 0
				Or IsNull(EndobronchialMycology,0) > 0
				Or IsNull(BrushCytology,0) > 0
				Or IsNull(BrushBacteriology,0) > 0
				Or IsNull(BrushVirology,0) > 0
				Or IsNull(BrushMycology,0) > 0
				Or IsNull(DistalBlindTB,0) > 0
				Or IsNull(DistalBlindHistology,0) > 0
				Or IsNull(DistalBlindBacteriology,0) > 0
				Or IsNull(DistalBlindVirology,0) > 0
				Or IsNull(DistalBlindMycology,0) > 0
				Or IsNull(TransbronchialTB,0) > 0
				Or IsNull(TransbronchialHistology,0) > 0
				Or IsNull(TransbronchialBacteriology,0) > 0
				Or IsNull(TransbronchialVirology,0) > 0
				Or IsNull(TransbronchialMycology,0) > 0
				Or IsNull(TranstrachealHistology,0) > 0
				Or IsNull(TranstrachealBacteriology,0) > 0
				Or IsNull(TranstrachealVirology,0) > 0
				Or IsNull(TranstrachealMycology,0) > 0
				Or IsNull(CryoHistology,0) > 0
			)) Biopsy On RD.ProcedureId = Biopsy.ProcedureId

	Left Join dbo.ERS_ProceduresReporting PathlogyResult on RD.ProcedureId = PathlogyResult.ProcedureId


	--- EBUS Molecular profile
	Update RD
	Set RD.WasMolecularProfileSent = (Case When (EBS.ProcedureId Is Not null) then 'Yes' Else 'No' end),
		RD.WasProfileSuccessful = (Case When (EBS.ProcedureId Is not null and IsNull(RD.BiopsyCytopathologyResult,'') <> '') then 'Yes' else '' end),
		RD.WasSedationMonitored = (Case When (QA.ManagementNone = 1) then 'No' When (IsNull(QA.PulseOximetry,0) > 0 Or IsNull(QA.IVAccess,0) > 0 Or IsNull(QA.IVAntibiotics,0) > 0 or IsNull(QA.Oxygenation,0) > 0
			Or IsNull(QA.OxygenationMethod,0) > 0 Or IsNull(QA.OxygenationFlowRate,0) > 0 Or IsNull(QA.ContinuousECG,0) > 0
			Or IsNull(QA.BP,0) > 0 Or IsNull(QA.ManagementOther,0) > 0) then 'Yes' else '' end),

		RD.WasRisksDocumented = (Case When (QA.ComplicationsNone = 1) Then 'No' When (IsNull(QA.Bleeding,0) > 0 or IsNull(QA.Pneumothorax,0) > 0 or IsNull(QA.CardiacArrythmia,0) > 0 
			Or IsNull(QA.Hospitalisation, 0) > 0 Or IsNull(QA.MyocardInfarction,0) > 0
			or IsNull(QA.ComplicationsOther,0) > 0 or IsNull(QA.Death,0) > 0
			or IsNull(QA.AdmissionToICU,0) > 0 
			Or IsNull(QA.Oversedation,0) > 0 ) Then 'Yes' else '' end)
	From @tblBroncData RD
	Left join (
		Select Distinct S.ProcedureID	
			from dbo.ERS_EBUSAbnoDescriptions  EBSABN 
			Inner join dbo.ERS_Sites S on EBSABN.SiteId = S.SiteId 
			Where IsNull(EBSABN.NoBxTaken,0) > 0) EBS on EBS.ProcedureId = RD.ProcedureID
	LEFT JOIN dbo.ERS_UpperGIQA QA on QA.ProcedureId = RD.ProcedureId
	LEFT JOIN dbo.ERS_ProcedureAdverseEvents AS pae ON RD.ProcedureId = pae.ProcedureId
	LEFT JOIN dbo.ERS_AdverseEvents AS advev ON advev.UniqueId = pae.AdverseEventId AND advev.NEDTerm IN 
		('Cardiovascular dysrhythmia, cardiac arrest, MI, cerebrovascular event', 'Haemorrhage', 'Significant haemorrhage requiring transfusion', 'Perforation')	


	--- Return Data

	Select
		PatientName as [Patient]
		,PatientDOB as [Date of Birth]
		,CaseNoteNo as [Case No.]
		,NHSNo as [NHS Number]
		,Gender as [Gender]
		,ProcedureType as [Procedure Type]
		,ProcedureDate as [Procedure date]
		,ReferralDate as [Referral Date]
		,BronchRequestedDate as [Bronch Requested Date]
		,AgeAtProcedure as [Age at procedure]
		,Endoscopist as [Endoscopist]
		,ListConsultant as [List Consultant]
		,AccessVia as [Access Via]
		,WasChestCTTakenPriorBronc as [Was a chest CT undertaken prior to bronchoscopy?]
		,IsCASuspected as [CA Suspected?]
		,WasTumourSeen as [Was a tumour seen?]
		,WasBiopsyTaken as [Was a biopsy taken?]
		,BiopsyCytopathologyResult as [If biopsy taken - what was the cytopathology result?]
		,WasMolecularProfileSent as [Was a molecular profile sent?]
		,WasProfileSuccessful as [Was the profile successful?]
		,WasPatientConsentDocumented as [Was patient consent documented in the notes?]
		,ConsentPerformedBy as [Who was consent performed by]
		,WasRisksDocumented as [Is there a record of risks documented in the notes?]
		,WasWHOChecklistCompleted as [Is there evidence of a WHO or equivalent safety checklist completed prior to procedure?]
		,WasInfoLeafletProvided as [Was an information leaflet provided?]
		,WasSedationUsed as [Was sedation used?]
		,NameOfSedationUsed as [Sedation used]
		,WasSedationMonitored as [Was sedation monitored?]
		,WasReversalAgentUsed as [Was a reversing agent used?]
		,ReversalAgentUsedName as [Reversal Agent Used]
		,WasEvidenceOfDecontamination as [Is there documentary evidence of decontamination record for procedure?]
		,Was62DayTargetAchieved as [Was the 62 day target achieved?]
	From
	@tblBroncData
	Order by PatientName

End
GO

EXEC dbo.DropIfExist @ObjectName = 'auditStentDetailsReport',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditStentDetailsReport]
	@UserId INT
AS

/*****************************************************************************************************************
Update History:
	01		:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
******************************************************************************************************************/

BEGIN
	DECLARE @FromDate AS DATE,
			@ToDate AS DATE
	DECLARE @TrustId AS INT,
			@OperatingHospitalList as varchar(100)  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

 SELECT @FromDate = FromDate,  
   @ToDate = ToDate,  
   @TrustId = TrustId,
   @OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
 FROM ERS_ReportFilter  
 where UserID = @UserId  

Select 
	pat.Forename1 as Forename
		, pat.Surname as Surname
		, pat.NHSNo as 'NHS number'
		, pat.HospitalNumber as 'Case note number'
		, Convert(varchar(12),pat.DateOfBirth,106) as DOB
		, oh.HospitalName as 'Operating hospital'
		, gt.Title as Sex
		, UPPER(pat.Postcode) as 'Patients postcode'
		, pt.ProcedureType as 'Procedure name'
		, Convert(varchar(12),p.CreatedOn,106) as 'Procedure Date'
		, Convert(varchar(30),p.ModifiedOn,100) as 'Procedure Date Time'		
		, dbo.fnGetAgeAtDate(pat.DateOfBirth, p.CreatedOn) as 'Age at procedure'	
		, ListCons.Surname + ', ' + ListCons.Forename as 'List consultant'
		, Endo1.Surname + ', ' + Endo1.Forename as 'Endoscopist 1'
		, Endo2.Surname + ', ' + Endo2.Forename as 'Endoscopist 2'
		, pas.ASAStatusId 'ASA status'
		, TOS.TotalStent AS 'Total Stent'
		, OPST.Stent AS 'Stent Details'

FROM ERS_Procedures p (NOLOCK)
JOIN ERS_Patients pat (NOLOCK) ON p.PatientId = pat.PatientId 
JOIN ERS_OperatingHospitals (NOLOCK) oh ON p.OperatingHospitalID = oh.OperatingHospitalId
LEFT OUTER JOIN ERS_GenderTypes (NOLOCK) gt ON pat.GenderId = gt.GenderId 
JOIN ERS_ProcedureTypes (NOLOCK) pt ON P.ProcedureType = pt.ProcedureTypeId 
INNER JOIN (SELECT DISTINCT s.ProcedureId 
			FROM ERS_Sites (NOLOCK) s  
			LEFT JOIN ERS_UpperGITherapeutics (NOLOCK) t ON s.siteId = t.SiteId
			WHERE t.siteid IS NOT NULL AND (t.StentInsertion = 1 OR t.StentRemoval = 1)) thera ON p.ProcedureId = thera.ProcedureId
JOIN ERS_Users ListCons (NOLOCK) ON p.ListConsultant = ListCons.UserID
JOIN ERS_Users Endo1 (NOLOCK) ON p.Endoscopist1 = Endo1.UserID
JOIN ERS_ReportConsultants RC ON RC.ConsultantID = ListCons.UserID AND RC.UserID = @UserId
LEFT OUTER JOIN ERS_Users Endo2 (NOLOCK) ON p.Endoscopist2 = Endo2.UserID
--join ERS_UpperGIIndications ind (NOLOCK) on p.ProcedureId = ind.ProcedureId 
LEFT JOIN dbo.ERS_ProcedureIndications AS prin (NOLOCK) ON p.ProcedureId = prin.ProcedureId 
LEFT JOIN dbo.ERS_Indications AS ind (NOLOCK) ON ind.UniqueId = prin.IndicationId
LEFT JOIN dbo.ERS_PatientASAStatus AS pas (NOLOCK) ON pas.PatientId = p.PatientId 
LEFT JOIN	(	
				SELECT PatientId, CASE WHEN MAX(ISNULL(WhenUpdated, 0)) > 0 THEN WhenUpdated ELSE WhenCreated END AS ASAStatDate
				FROM dbo.ERS_PatientASAStatus
				GROUP BY PatientId, WhenUpdated, WhenCreated 
			) AS statusId ON statusId.ASAStatDate = CASE WHEN ISNULL(pas.WhenUpdated, 0) > 0 THEN pas.WhenUpdated ELSE pas.WhenCreated END
LEFT OUTER JOIN ERS_UpperGIFollowUp fu (NOLOCK) ON p.ProcedureId = fu.ProcedureId 
LEFT JOIN (SELECT S.ProcedureId,SUM(ISNULL(UIT.StentInsertionQty,0)) TotalStent
FROM ERS_UpperGITherapeutics UIT (NOLOCK)
INNER JOIN ERS_Sites S (NOLOCK) on UIT.SiteId = S.SiteId
inner join ERS_Regions R (NOLOCK) on S.RegionId = R.RegionId
WHERE 1 = 1 

Group by S.ProcedureId) TOS on p.ProcedureId = TOS.ProcedureId
left outer join (
Select Distinct UT.ProcedureId,Stuff(( Select ', ' + Replace(Replace(Summary,'Stent insertion',R.Region),'<br />',' - ')
from ERS_UpperGITherapeutics UGIT (NOLOCK)
Inner join ERS_Sites S (NOLOCK) on UGIT.SiteId = S.SiteId
inner join ERS_Regions R (NOLOCK) on S.RegionId = R.RegionId
Where 1 = 1 
	and S.ProcedureId = UT.ProcedureId
	For Xml path('')),1,1,'') as Stent
From dbo.ERS_Sites UT (NOLOCK) ) OPST On OPST.ProcedureId = P.ProcedureId

where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate	
		and IsNull(p.DNA,0) = 0
	and IsNull(OPST.Stent,'') <> ''
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
order by pt.ProcedureType, p.CreatedOn 
End

GO

EXEC dbo.DropIfExist @ObjectName = 'auditGIBleedingReport',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[auditGIBleedingReport] @UserId INT
AS
/*
--	Author		:		Mahfuz created on 19 May 2022 - GI Bleeding Audit Report TFS # 2115
--	Author		:		Partha  on 29 May 2024 - Filter By Operating Hospital TFS1811
--	Update History:
					
*/
BEGIN
    DECLARE
        @FromDate AS DATE,
        @ToDate AS DATE;
    DECLARE @TrustId AS INT;
	DECLARE @OperatingHospitalList as varchar(100);

    DECLARE @indHaematemesisId AS INT;
    DECLARE @indMelaenaId AS INT;
    DECLARE @indHaemorrhageId AS INT;
    DECLARE @indSignificantHaemorrhageId AS INT;

    SELECT
        @FromDate = FromDate,
        @ToDate = ToDate,
        @TrustId = TrustId,
		@OperatingHospitalList=OperatingHospitalList
    FROM
        ERS_ReportFilter
    WHERE
        UserID = @UserId;


    DECLARE @UGBleedType AS TABLE
    (
        Bleeding INT,
        BleedingType VARCHAR(100)
    );

    SELECT @indHaematemesisId = CASE WHEN [NEDTerm] = 'Haematemesis' THEN UniqueId ELSE 0 END FROM dbo.ERS_Indications
    SELECT @indMelaenaId = CASE WHEN [NEDTerm] = 'Melaena' THEN UniqueId ELSE 0 END FROM dbo.ERS_Indications
    SELECT @indHaemorrhageId = CASE WHEN [NEDTerm] = 'Haemorrhage' THEN UniqueId ELSE 0 END FROM dbo.ERS_Indications
    SELECT @indSignificantHaemorrhageId = CASE WHEN [NEDTerm] = 'Significant haemorrhage requiring transfusion' THEN UniqueId ELSE 0 END FROM dbo.ERS_Indications
    
    --These data are hard coded inside SE App
    INSERT INTO
        @UGBleedType
    (
        Bleeding,
        BleedingType
    )
    VALUES
    (0, '');
    INSERT INTO
        @UGBleedType
    (
        Bleeding,
        BleedingType
    )
    VALUES
    (1, 'None');
    INSERT INTO
        @UGBleedType
    (
        Bleeding,
        BleedingType
    )
    VALUES
    (2, 'Luminal blood');
    INSERT INTO
        @UGBleedType
    (
        Bleeding,
        BleedingType
    )
    VALUES
    (3, 'Adherent clot');
    INSERT INTO
        @UGBleedType
    (
        Bleeding,
        BleedingType
    )
    VALUES
    (4, 'Visible vessel');


    SELECT
        pat.HospitalNumber AS CaseNoteNo,
        ISNULL(pat.NHSNo, '') AS NHSNo,
        pat.Surname + ' ' + pat.Forename1 AS [Patient Name],
        ISNULL(gt.Title, 'Unknown') AS Sex,
        FORMAT(pat.DateOfBirth, 'dd MMM yyyy') AS [Date of Birth],
        FORMAT(p.CreatedOn, 'dd MMM yyyy') AS [Procedure Date],
        dbo.fnGetAgeAtDate(pat.DateOfBirth, p.CreatedOn) AS [Age at procedure],
        ListCons.Surname + ', ' + ListCons.Forename AS 'List consultant',
        u1.Surname + ' ' + u1.Forename AS [Endoscopist 1],
        ISNULL(u2.Surname + ' ' + u2.Forename, '') AS [Endoscopist 2],
        pt.ProcedureType AS [Procedure],
        CASE
            WHEN Haem.ProcedureId IS NULL THEN
                'No'
            ELSE
                'Yes'
        END AS Haemorrhage,
        CASE
            WHEN SigHaem.ProcedureId IS NULL THEN
                'No'
            ELSE
                'Yes'
        END AS [Significant Haemorrhage requiring Transfusion],
        ISNULL(bt.BleedingType, '') AS [Bleeding Type],
        CASE
            WHEN Hae.ProcedureId IS NULL THEN
                'No'
            ELSE
                'Yes'
        END AS Haematemesis,
        CASE
            WHEN Mel.ProcedureId IS NULL THEN
                'No'
            ELSE
                'Yes'
        END AS Melaena,
        ISNULL(GiB.BlatchfordScore, 0) AS [Blatchford Score],
        ISNULL(GiB.RockallScore, 0) AS [Rockall Score]
    FROM
        ERS_Procedures (NOLOCK) p
        INNER JOIN ERS_ProcedureTypes pt
            ON p.ProcedureType = pt.ProcedureTypeId
        INNER JOIN ERS_Patients pat
            ON p.PatientId = pat.PatientId
        LEFT JOIN ERS_GenderTypes gt
            ON gt.GenderId = pat.GenderId
        JOIN ERS_Users ListCons (NOLOCK)
            ON p.ListConsultant = ListCons.UserID
        JOIN ERS_ReportConsultants RC
            ON RC.ConsultantID = ListCons.UserID
               AND RC.UserID = @UserId
        LEFT JOIN ERS_Users u1
            ON u1.UserID = p.Endoscopist1
        LEFT JOIN ERS_Users u2
            ON u2.UserID = p.Endoscopist2
        LEFT JOIN
        (
            SELECT DISTINCT
                   ProcedureId
            FROM
                dbo.ERS_ProcedureIndications AS pri
            WHERE
                pri.IndicationId = @indHaematemesisId
        ) Hae
            ON p.ProcedureId = Hae.ProcedureId
        LEFT JOIN
        (
            SELECT DISTINCT
                   ProcedureId
            FROM
                dbo.ERS_ProcedureIndications AS pri
            WHERE
                pri.IndicationId = @indMelaenaId
        ) Mel
            ON p.ProcedureId = Mel.ProcedureId
        LEFT JOIN
        (
            SELECT DISTINCT
                   ProcedureId
            FROM
                dbo.ERS_ProcedureAdverseEvents AS pae
            WHERE
                pae.AdverseEventId = @indHaemorrhageId
        ) Haem
            ON p.ProcedureId = Haem.ProcedureId
        LEFT JOIN
        (
            SELECT DISTINCT
                   ProcedureId
            FROM
                dbo.ERS_ProcedureAdverseEvents AS pae
            WHERE
                pae.AdverseEventId = @indSignificantHaemorrhageId
        ) SigHaem
            ON p.ProcedureId = SigHaem.ProcedureId
        LEFT JOIN dbo.ERS_UpperGIBleeds GiB
            ON GiB.ProcedureId = p.ProcedureId
        LEFT JOIN @UGBleedType bt
            ON GiB.Bleeding = bt.Bleeding
    WHERE
        1 = 1
        AND p.ProcedureCompleted = 1
        AND ISNULL(p.DNA, 0) = 0
        AND p.IsActive = 1
        --and p.ProcedureType in (1)
        AND p.CreatedOn >= @FromDate
        AND p.CreatedOn <= @ToDate
		AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
        AND
        (
            Hae.ProcedureId IS NOT NULL
            OR Mel.ProcedureId IS NOT NULL
            OR Haem.ProcedureId IS NOT NULL
            OR GiB.ProcedureId IS NOT NULL
        );

END

GO

EXEC dbo.DropIfExist @ObjectName = 'auditBarrettOesophaggealPerforationReport',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[auditBarrettOesophaggealPerforationReport] @UserId INT

AS
/*
--	Author		:		Mahfuz created on 20 May 2022 - Barrets Oesophageal Perforation Clinical significant bleeding etc report TFS 2069
--	Author		:		Partha  on 29 May 2024 - Filter By Operating Hospital TFS1811
--	Author		:		Partha  on 29 May 2024 - Show Indication  TFS 4116
--	Update History:
					
*/
BEGIN
    DECLARE
        @FromDate AS DATE,
        @ToDate AS DATE,
		@TrustId AS INT;

	DECLARE @cardiacArrestId AS INT;
	DECLARE @haemorrhageId AS INT;
	DECLARE @significantHaemorrhageId AS INT;
	DECLARE @advEvPerforationId AS INT;
	DECLARE @advEvPerforationSiteId AS INT
	DECLARE @advEvPerforationAdditionalInfo AS BIT;
	DECLARE @advEvDyspepsiaAtypicalId AS INT;
	DECLARE @advEvDyspepsiaUlcerTypeId AS INT;
	DECLARE @indDysphagiaId AS INT;	
	DECLARE @indBarrOespSurv AS INT;
	declare @OperatingHospitalList as Varchar(100)
	
    SELECT
        @FromDate = FromDate,
        @ToDate = ToDate,
        @TrustId = TrustId,
		@OperatingHospitalList=OperatingHospitalList
    FROM
        dbo.ERS_ReportFilter
    WHERE
        UserID = @UserId;

	SELECT @cardiacArrestId = CASE WHEN [NEDTerm] = 'Cardiovascular dysrhythmia, cardiac arrest, MI, cerebrovascular event' THEN UniqueId ELSE 0 END FROM dbo.ERS_AdverseEvents WHERE NEDTerm = 'Cardiovascular dysrhythmia, cardiac arrest, MI, cerebrovascular event'		
	SELECT @haemorrhageId = CASE WHEN [NEDTerm] = 'Haemorrhage' THEN UniqueId ELSE 0 END FROM dbo.ERS_AdverseEvents WHERE [NEDTerm] = 'Haemorrhage'
	SELECT @significantHaemorrhageId = CASE WHEN [NEDTerm] = 'Significant haemorrhage requiring transfusion' THEN UniqueId ELSE 0 END FROM dbo.ERS_AdverseEvents WHERE [NEDTerm] = 'Significant haemorrhage requiring transfusion'
	SELECT @advEvPerforationId = CASE WHEN [NEDTerm] = 'Perforation' THEN UniqueId ELSE 0 END FROM dbo.ERS_AdverseEvents WHERE [NEDTerm] = 'Perforation'
	SELECT @advEvPerforationAdditionalInfo = CASE WHEN [AdditionalInfo] = 1 THEN 1 ELSE 0 END FROM dbo.ERS_AdverseEvents WHERE [NEDTerm] = 'Perforation'

	SELECT @indDysphagiaId = CASE WHEN [NEDTerm] = 'Dysphagia' THEN UniqueId ELSE 0 END FROM dbo.ERS_Indications WHERE [NEDTerm] = 'Dysphagia'
	SELECT @advEvDyspepsiaAtypicalId = CASE WHEN [NEDTerm] = 'Dyspepsia' AND [Description] = LTRIM('Dyspepsia - Atypical') THEN UniqueId ELSE 0 END FROM dbo.ERS_Indications WHERE [NEDTerm] = 'Dyspepsia' AND [Description] = LTRIM('Dyspepsia - Atypical')
	SELECT @advEvDyspepsiaUlcerTypeId = CASE WHEN [NEDTerm] = 'Dyspepsia' AND [Description] = LTRIM('Dyspepsia - UlcerType') THEN UniqueId ELSE 0 END FROM dbo.ERS_Indications WHERE [NEDTerm] = 'Dyspepsia' AND [Description] = LTRIM('Dyspepsia - UlcerType')
	SELECT @indBarrOespSurv = CASE WHEN [NEDTerm] = 'Barretts oesophagus surveillance' THEN UniqueId ELSE 0 END FROM dbo.ERS_Indications WHERE [NEDTerm] = 'Barretts oesophagus surveillance'
	
    SELECT DISTINCT
        pat.Forename1 + ' ' + pat.Surname AS Patient,        
        pat.NHSNo AS 'NHS number',
        pat.HospitalNumber AS 'Case note number',
        CONVERT(VARCHAR(12), pat.DateOfBirth, 106) AS DOB,
        dbo.fnGetAgeAtDate(pat.DateOfBirth, p.CreatedOn) AS 'Age at procedure',
        oh.HospitalName AS 'Operating hospital',
        gt.Title AS Sex,
        UPPER(pat.Postcode) AS 'Patients postcode',
        ListCons.Surname + ', ' + ListCons.Forename AS 'List consultant',
        Endo1.Surname + ', ' + Endo1.Forename AS 'Endoscopist 1',
        Endo2.Surname + ', ' + Endo2.Forename AS 'Endoscopist 2',
        pt.ProcedureType AS 'Procedure name',
        CONVERT(VARCHAR(30), p.ModifiedOn, 100) AS 'Procedure Date Time',
        CONVERT(VARCHAR(12), p.CreatedOn, 106) AS 'Endoscopy Result Date',
        CASE
            WHEN
            (
                ISNULL(procInd.IndicationId, 0) = @indBarrOespSurv
                OR ISNULL(barrt.ProcedureId, 0) > 0
            ) THEN
                CONVERT(VARCHAR(12), p.CreatedOn, 106)
            ELSE
                NULL
        END 
		AS [Date of diagnosis of Barrett's Oesophagus],
        CASE
            WHEN (ISNULL(OesophagCancer.ProcedureId, 0) > 0) THEN
                'Yes'
            ELSE
                'No'
        END AS [Oesophageal Cancer diagnosed],
        CASE
            WHEN (ISNULL(OesophagCancer.ProcedureId, 0) > 0) THEN
                CONVERT(VARCHAR(12), p.CreatedOn, 106)
            ELSE
                NULL
        END AS [Date of Oesophageal Cancer diagnosis],
        CASE
            WHEN
            (
                ISNULL(barrt.ProcedureId, 0) > 0
                AND ISNULL(TOS.ProcedureId, 0) > 0
            ) THEN
                CONVERT(VARCHAR(12), p.CreatedOn, 106)
            ELSE
                NULL
        END AS [Start Date of Barret's Oesophagus Treatment],
        CASE
            WHEN (ISNULL(poc.Perforation, 0) = 1) THEN
                'Yes'
            ELSE
                'No'
        END AS Perforation,
        CASE 
			WHEN
				procInd.IndicationId = @advEvPerforationAdditionalInfo
			THEN 
				ISNULL(pae.AdditionalInformation, '')
			ELSE
				''
			END AS [Perforation Site],
        CASE 
			WHEN 
				ISNULL(pae.AdverseEventId, 0) = ISNULL(adev.UniqueId, 0) OR ISNULL(adev.NEDTerm, '') = 'Significant haemorrhage requiring transfusion' 
			THEN 
				'Yes' 
			ELSE 
				'No' 
		END AS [Clinically significant bleeding],		
        LTRIM(RTRIM(   CASE
                           WHEN (SUBSTRING(   (CASE
                                                   WHEN
														ISNULL(pae.AdverseEventId, 0) = @cardiacArrestId
												   THEN
                                                       'Cardiac Arrest'
                                                   ELSE
                                                       ''
                                               END + CASE
                                                         WHEN 
															(ISNULL(poc.Arrythmia, 0) = 1) THEN
                                                             ', Cardiac Arrythmia'
                                                         ELSE
                                                             ''
                                                     END
                                              ),
                                              1,
                                              1
                                          ) = ','
                                ) THEN
                               SUBSTRING(   (CASE
                                                WHEN 
													ISNULL(pae.AdverseEventId, 0) = @cardiacArrestId 
												THEN
                                                       'Cardiac Arrest'
                                                ELSE
                                                     ''
                                             END + CASE
                                                       WHEN (ISNULL(poc.Arrythmia, 0) = 1) THEN
                                                           ', Cardiac Arrythmia'
                                                       ELSE
                                                           ''
                                                   END
                                            ),
                                            2,
                                            20
                                        )
                           ELSE
                               SUBSTRING(   (CASE
                                                 WHEN
													ISNULL(pae.AdverseEventId, 0) = @cardiacArrestId
												 THEN
                                                    'Cardiac Arrest'
                                                 ELSE
                                                     ''
                                             END + CASE
                                                       WHEN (ISNULL(poc.Arrythmia, 0) = 1) THEN
                                                           ', Cardiac Arrythmia'
                                                       ELSE
                                                           ''
                                                   END
                                            ),
                                            1,
                                            33
                                        )
                       END
                   )
             ) AS [Cardiopulmonary adverse events],
        CASE
            WHEN procInd.IndicationId = @indDysphagiaId THEN 
                'Yes'
            ELSE
                'No'
        END AS Dysphagia,
        CASE
            WHEN procInd.IndicationId = @advEvDyspepsiaAtypicalId OR procInd.IndicationId = @advEvDyspepsiaUlcerTypeId THEN                                           
                'Yes'
            ELSE
                'No'
        END AS Dyspepsia,
        pas.ASAStatusId AS 'ASA status',
        TOS.TotalStent AS 'Total Stent',
        OPST.TherapSummary AS 'Therapeutic treatments received' ,
		IND.Inications AS 'Indications' 
    FROM
        dbo.ERS_Procedures p (NOLOCK)
        INNER JOIN dbo.ERS_Patients pat (NOLOCK)
            ON p.PatientId = pat.PatientId
        LEFT JOIN dbo.ERS_OperatingHospitals (NOLOCK) oh
            ON p.OperatingHospitalID = oh.OperatingHospitalId
		LEFT JOIN dbo.ERS_PatientTrusts AS patr
			ON patr.PatientId = pat.PatientId
        LEFT OUTER JOIN dbo.ERS_GenderTypes (NOLOCK) gt
            ON pat.GenderId = gt.GenderId
        LEFT JOIN dbo.ERS_ProcedureTypes (NOLOCK) pt
            ON p.ProcedureType = pt.ProcedureTypeId
        LEFT JOIN
        (
            SELECT DISTINCT
                   s.ProcedureId
            FROM
                dbo.ERS_Sites (NOLOCK) s
                LEFT JOIN dbo.ERS_UpperGITherapeutics (NOLOCK) t
                    ON s.SiteId = t.SiteId
            WHERE
                t.SiteId IS NOT NULL
                AND
                (
                    t.StentInsertion = 1
                    OR t.StentRemoval = 1
                )
        ) thera
            ON p.ProcedureId = thera.ProcedureId
        LEFT JOIN
        (
            SELECT DISTINCT
                   s.ProcedureId
            FROM
                dbo.ERS_UpperGIAbnoBarrett barrt (NOLOCK)
                INNER JOIN dbo.ERS_Sites s (NOLOCK)
                    ON barrt.SiteId = s.SiteId
                INNER JOIN dbo.ERS_Regions r (NOLOCK)
                    ON s.RegionId = r.RegionId
            WHERE
                ISNULL(barrt.None, 0) <> 1
                AND r.Region LIKE '%Oesophag%'
        ) barrt
            ON barrt.ProcedureId = p.ProcedureId

        -- Oesophageal Cancer
        LEFT JOIN
        (
            SELECT DISTINCT
                   P.ProcedureId
            FROM
                dbo.ERS_Procedures P (NOLOCK)
                INNER JOIN dbo.ERS_Sites s (NOLOCK)
                    ON P.ProcedureId = s.ProcedureId
                INNER JOIN dbo.ERS_Regions r (NOLOCK)
                    ON s.RegionId = r.RegionId
                INNER JOIN dbo.ERS_CommonAbnoTumour T (NOLOCK)
                    ON T.SiteId = s.SiteId
            WHERE
                r.Region LIKE '%Oesophag%'
                AND T.Tumour = 1
                AND T.Type = 2 --Type = 2 is malignant (cancerous)
        ) OesophagCancer
            ON p.ProcedureId = OesophagCancer.ProcedureId
        INNER JOIN dbo.ERS_Users ListCons (NOLOCK)
            ON p.ListConsultant = ListCons.UserID
        INNER JOIN dbo.ERS_Users Endo1 (NOLOCK)
            ON p.Endoscopist1 = Endo1.UserID
        INNER JOIN dbo.ERS_ReportConsultants RC (NOLOCK)
            ON RC.ConsultantID = ListCons.UserID
               AND RC.UserID = @UserId
        LEFT OUTER JOIN dbo.ERS_Users Endo2 (NOLOCK)
            ON p.Endoscopist2 = Endo2.UserID
        LEFT JOIN dbo.ERS_ProcedureIndications procInd (NOLOCK)
            ON p.ProcedureId = procInd.ProcedureId
		LEFT JOIN (SELECT UniqueId, NEDTerm, AdditionalInfo FROM dbo.ERS_Indications (NOLOCK) WHERE NEDTerm IN ('Barretts oesophagus surveillance', 'Dysphagia', 'Dyspepsia')) AS indic
			ON indic.UniqueId = procInd.IndicationId
        LEFT JOIN dbo.ERS_PostOperativeComplications poc (NOLOCK)
            ON poc.ProcedureId = p.ProcedureId
		LEFT JOIN dbo.ERS_ProcedureAdverseEvents AS pae (NOLOCK)
			ON pae.ProcedureId = p.ProcedureId
		LEFT JOIN (SELECT UniqueId, NEDTerm, AdditionalInfo FROM dbo.ERS_AdverseEvents (NOLOCK) WHERE NEDTerm IN ('Cardiovascular dysrhythmia, cardiac arrest, MI, cerebrovascular event', 'Haemorrhage', 'Significant haemorrhage requiring transfusion', 'Perforation')) AS adev
			ON adev.UniqueId = pae.AdverseEventId
		LEFT JOIN dbo.ERS_PatientASAStatus AS pas (NOLOCK)
			ON pas.PatientId = p.PatientId
		LEFT JOIN dbo.ERS_ASAStatus AS asas (NOLOCK)
			ON asas.UniqueId = pas.ASAStatusId
        LEFT OUTER JOIN dbo.ERS_UpperGIFollowUp fu (NOLOCK)
            ON p.ProcedureId = fu.ProcedureId
        LEFT JOIN
        (
            SELECT
                S.ProcedureId,
                SUM(ISNULL(UIT.StentInsertionQty, 0)) TotalStent
            FROM
                dbo.ERS_UpperGITherapeutics UIT (NOLOCK)
                INNER JOIN dbo.ERS_Sites S (NOLOCK)
                    ON UIT.SiteId = S.SiteId 
                INNER JOIN dbo.ERS_Regions R (NOLOCK)
                    ON S.RegionId = R.RegionId
            WHERE
                1 = 1
            --and R.Region like '%Oesophagus%'
            --and R.ProcedureType = 1
            GROUP BY
                S.ProcedureId
        ) TOS
            ON p.ProcedureId = TOS.ProcedureId
        LEFT OUTER JOIN
        (
            SELECT DISTINCT
                   UT.ProcedureId,
                   STUFF(
                   (
                       SELECT
                           ', ' + REPLACE(REPLACE(Summary, 'Stent insertion', R.Region), '<br />', ' - ')
                       FROM
                           dbo.ERS_UpperGITherapeutics UGIT (NOLOCK)
                           INNER JOIN dbo.ERS_Sites S (NOLOCK)
                               ON UGIT.SiteId = S.SiteId
                           INNER JOIN dbo.ERS_Regions R (NOLOCK)
                               ON S.RegionId = R.RegionId
                       WHERE
                           1 = 1
                           --and S.ProcedureId = 5546
                           --and R.Region like '%Oesophagus%'
                           --and R.ProcedureType = 1
                           AND S.ProcedureId = UT.ProcedureId
                       FOR XML PATH('')
                   ),
                   1,
                   1,
                   ''
                        ) AS TherapSummary
            FROM
                dbo.ERS_Sites UT
        ) OPST
            ON OPST.ProcedureId = p.ProcedureId		
		  LEFT OUTER JOIN
        (
              SELECT DISTINCT
                   PIND1.ProcedureId,
                   STUFF(
                   (
                       SELECT
                           ', ' +  IND.Description
                       FROM
                           dbo.ERS_Indications ind (NOLOCK)
                           INNER JOIN dbo.ERS_ProcedureIndications pind (NOLOCK)
                               ON ind.UniqueId=pind.IndicationId
                        
                       WHERE  PIND.ProcedureId=PIND1.ProcedureId
                       FOR XML PATH('')
                   ),
                   1,
                   1,
                   ''
                        ) AS Inications
            FROM
                dbo.ERS_ProcedureIndications PIND1
        ) IND
            ON IND.ProcedureId = p.ProcedureId		
    WHERE
        p.ProcedureCompleted = 1
        AND p.IsActive = 1
        --and p.ProcedureType=1
        AND p.CreatedOn >= @FromDate
        AND p.CreatedOn <= @ToDate
		AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
        --MH added on 10 Mar 2022
        AND ISNULL(p.DNA, 0) = 0
        --and IsNull(Stent,'') <> ''
        AND ISNULL(barrt.ProcedureId, 0) > 0
    ORDER BY
        --pt.ProcedureType,
        --p.CreatedOn,
		Patient,
		[NHS number],
		[Case note number],
		DOB,
		[Age at procedure],
		[Operating hospital],
		Sex,
		[Patients postcode],
		[List consultant],
		[Procedure name],
		[Procedure Date Time],
		[Endoscopy Result Date],
		[Date of diagnosis of Barrett's Oesophagus],
		[Oesophageal Cancer diagnosed],
		[Date of Oesophageal Cancer diagnosis],
		[Start Date of Barret's Oesophagus Treatment],
		Perforation,
		[Perforation Site],
		[Clinically significant bleeding],
		[Cardiopulmonary adverse events],
		Dysphagia,
		Dyspepsia,
		[ASA status],
		[Total Stent],
		[Therapeutic treatments received],
		[Indications]
END;
GO

EXEC dbo.DropIfExist @ObjectName = 'auditVaricesOesophagusSurveillance',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditVaricesOesophagusSurveillance]
@UserId int
As
/*
	29 Jun 2022		:		MH created for new audit report TFS : 2172

	testing :
	exec auditVaricesOesophagusSurveillance 32
					:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
*/
Begin

	DECLARE @FromDate as Date,
				@ToDate as Date,
	   @TrustId as int,
	   @OperatingHospitalList as varchar(100)  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
  
	 Select @FromDate = FromDate,  
	   @ToDate = ToDate,  
	   @TrustId = TrustId,
	   @OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	 FROM ERS_ReportFilter  
	 where UserID = @UserId  
  
	SELECT rc.ConsultantID , con.Title + ' ' + con.Forename + ' ' + con.Surname AS Endoscopist, rc.AnonimizedID
		INTO #Consultants
		FROM ERS_ReportConsultants rc
		JOIN ERS_Users con on rc.ConsultantID = con.UserID 
		WHERE rc.UserID = @UserId



	Select --p.ProcedureId,
		 
			pat.Forename1 as Forename
			, pat.Surname as Surname
			, pat.NHSNo as 'NHS number'
			, pat.HospitalNumber as 'Case note number'
			, Convert(varchar(12),pat.DateOfBirth,106) as DOB
			, oh.HospitalName as 'Operating hospital'
			, gt.Title as Sex
			, pat.Postcode as 'Patients postcode'
			, pt.ProcedureType as 'Procedure name'
			, Convert(varchar(12),p.CreatedOn,106) as 'Procedure Date'
			, Convert(varchar(30),p.ModifiedOn,100) as 'Procedure Date Time'
			, dbo.fnGetAgeAtDate(pat.DateOfBirth, p.CreatedOn) as 'Age at procedure'
			, ListCons.Surname + ', ' + ListCons.Forename as 'List consultant'
			, Endo1.Surname + ', ' + Endo1.Forename as 'Endoscopist 1'
			, Endo2.Surname + ', ' + Endo2.Forename as 'Endoscopist 2'
			, ind.ASAStatus as 'ASA status'
			,Case When (IsNull(ind.OesophagealVarices,0) <> 0) then 'Yes' else 'No' end as OesophagealVarices
			,Case When (IsNull(ind.ChronicLiverDisease,0) <> 0) then 'Yes' else 'No' end as ChronicLiverDisease
			,Case When (IsNull(ind.BarrettsSurveillance,0) <> 0) then 'Yes' else 'No' end as BarrettsSurveillance
			,Case When (IsNull(ind.BarrettsOesophagus,0) <> 0) then 'Yes' else 'No' end as BarrettsOesophagus
			,VARC.VaricesSummary
	from ERS_Procedures p (nolock)
	join ERS_Patients pat (nolock) on p.PatientId = pat.PatientId 
	join ERS_OperatingHospitals (nolock) oh on p.OperatingHospitalID = oh.OperatingHospitalId 
	left outer join ERS_GenderTypes (nolock) gt on pat.GenderId = gt.GenderId 
	join ERS_ProcedureTypes (nolock) pt on P.ProcedureType = pt.ProcedureTypeId 
	left join (Select distinct s.ProcedureId 
				from ERS_Sites (nolock) s  
				left join ERS_UpperGITherapeutics (nolock) t on s.siteId = t.SiteId
				where t.siteid is not null and (t.StentInsertion = 1 or t.StentRemoval = 1)) thera on p.ProcedureId = thera.ProcedureId
	join ERS_Users ListCons (nolock) on p.ListConsultant = ListCons.UserID
	join ERS_Users Endo1 (nolock) on p.Endoscopist1 = Endo1.UserID
	left outer join ERS_Users Endo2 (nolock) on p.Endoscopist2 = Endo2.UserID
	join ERS_ReportConsultants rc on Endo1.UserID = rc.ConsultantID and rc.UserID = @UserId 
	join ERS_UpperGIIndications ind (nolock) on p.ProcedureId = ind.ProcedureId 
	left outer join ERS_UpperGIFollowUp fu (nolock) on p.ProcedureId = fu.ProcedureId 
	Left join (Select S.ProcedureId,Sum(IsNull(UIT.StentInsertionQty,0)) TotalOesophagealStent
	from ERS_UpperGITherapeutics UIT
	Inner join ERS_Sites S on UIT.SiteId = S.SiteId
	inner join ERS_Regions R on S.RegionId = R.RegionId
	Where R.Region like '%Oesophagus%'
		and R.ProcedureType = 1
	Group by S.ProcedureId) TOS on p.ProcedureId = TOS.ProcedureId
	left outer join (
	Select Distinct UT.ProcedureId,Stuff(( Select ', ' + Replace(Replace(Summary,'Stent insertion',R.Region),'-',' - ')
	from ERS_UpperGIAbnoVarices UGV
	Inner join ERS_Sites S on UGV.SiteId = S.SiteId
	inner join ERS_Regions R on S.RegionId = R.RegionId
	Where 1 = 1 
		--and S.ProcedureId = 5546
		--and R.Region like '%Oesophagus%'
		and R.ProcedureType = 1
		and S.ProcedureId = UT.ProcedureId
		For Xml path('')),1,1,'') as VaricesSummary
	From ERS_Sites UT ) VARC On VARC.ProcedureId = P.ProcedureId

	where p.ProcedureCompleted = 1
		and p.IsActive = 1
		and p.ProcedureType=1
		and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
			and IsNull(p.DNA,0) = 0
		--and IsNull(OesophagealStent,'') <> ''
		and (
			IsNull(ind.OesophagealVarices,0) <> 0 
			or IsNull(ind.ChronicLiverDisease,0) <> 0
			Or IsNull(ind.BarrettsSurveillance,0) <> 0
			Or IsNull(ind.BarrettsOesophagus,0) <> 0
			Or IsNull(VARC.VaricesSummary,'') <> ''
		)
		AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	order by pt.ProcedureType, p.CreatedOn 
End

GO

EXEC dbo.DropIfExist @ObjectName = 'auditFollowUpRepeatProcedures',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditFollowUpRepeatProcedures]
	@UserId int
AS
/*
	Update History		:
	01	:	07 Mar 2022			Mahfuz added additional two extra columns of Due in Weeks and Due Date 
													(Please ignore ugly text scanning code. It can be improved later when system will save numbers of days,weeks etc instead of free text)
	02	:	10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures

	03	:	29 Mar 2022 MH added Operating Hospital
	04  :	11 May 2022 SG added Health Service Number formatting
	05	:	21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 

--	
*/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100),  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
			@HealthService as varchar(max)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId, 
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	declare @ProceduresWithFollowUp as Table
	(
	AutoRowID int identity(1,1),
	PatientId int,
	ProcedureId int,
	ModifiedOn datetime,
	CreatedOn datetime,
	InTimeWord varchar(10),
	InTimeDaysNumber integer,
	FurtherProcedureText varchar(max)
	)

	declare @ProceduresAfterFollowUp as table
	(
	AutoRowID int identity(1,1),
	PatientId int,
	ProcedureId int,
	ModifiedOn datetime
	)

	Insert into @ProceduresWithFollowUp(PatientId,ProcedureId,ModifiedOn,CreatedOn,FurtherProcedureText)
	Select pr.PatientId,pr.ProcedureID,Pr.ModifiedOn,Pr.CreatedOn,ugfu.FurtherProcedureText from ERS_Procedures pr 
	inner join ERS_UpperGIFollowUp ugfu on pr.ProcedureId = ugfu.ProcedureId
	join ERS_ReportConsultants rc on (pr.Endoscopist1 = rc.ConsultantID OR pr.Endoscopist2 = rc.ConsultantID)
	Where IsNull(ugfu.FurtherProcedureText,'') <> '' and pr.CreatedOn >= @FromDate AND pr.CreatedOn <= @ToDate
	--MH added on 10 Mar 2022
	and IsNull(pr.DNA,0) = 0
	--and pr.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	and rc.UserID = @UserId

		Begin Try
			Update @ProceduresWithFollowUp
				Set InTimeWord = 'D',
					InTimeDaysNumber = Cast(ltrim(rtrim(Substring(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1,charindex ('day',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1)))),(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1,charindex ('day',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1,charindex ('day',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1))))))+1),(Len(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1,charindex ('day',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1)))))-(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1,charindex ('day',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1,charindex ('day',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1))))))))))) as Integer) * 1

				Where FurtherProcedureText like '%day%' and IsNull(InTimeWord,'') = ''
		End Try
		Begin Catch
		End Catch
	Begin Try
		Update @ProceduresWithFollowUp
			Set InTimeWord = 'W',
				InTimeDaysNumber = Cast(ltrim(rtrim(Substring(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1,charindex ('week',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1)))),(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1,charindex ('week',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1,charindex ('week',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1))))))+1),(Len(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1,charindex ('week',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1)))))-(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1,charindex ('week',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1,charindex ('week',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1))))))))))) as Integer) * 7	
			Where FurtherProcedureText like '%week%' and IsNull(InTimeWord,'') = ''
		End Try
		Begin Catch
		End Catch

	Begin Try
		Update @ProceduresWithFollowUp
			Set InTimeWord = 'M',
				InTimeDaysNumber = Cast(ltrim(rtrim(Substring(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1,charindex ('month',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1)))),(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1,charindex ('month',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1,charindex ('month',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1))))))+1),(Len(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1,charindex ('month',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1)))))-(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1,charindex ('month',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1,charindex ('month',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1))))))))))) as Integer) * 30
		
			Where FurtherProcedureText like '%month%' and IsNull(InTimeWord,'') = ''
	End Try
	Begin Catch
	End Catch

	Begin Try

	Update @ProceduresWithFollowUp
		Set InTimeWord = 'Y',
			InTimeDaysNumber = Cast(ltrim(rtrim(Substring(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1,charindex ('year',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1)))),(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1,charindex ('year',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1,charindex ('year',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1))))))+1),(Len(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1,charindex ('year',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1)))))-(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1,charindex ('year',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1,charindex ('year',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1))))))))))) as Integer) * 365
		
		Where FurtherProcedureText like '%year%' and IsNull(InTimeWord,'') = ''

	End Try
	Begin Catch
	End Catch

	Insert into @ProceduresAfterFollowUp(PatientId,ProcedureId,ModifiedOn)
	Select Distinct pr.PatientId,pr.ProcedureID,Pr.ModifiedOn
	from ERS_Procedures pr 
	left join @ProceduresWithFollowUp pfu on pr.Patientid = pfu.PatientId --and pr.ModifiedOn < pfu.ModifiedOn
	join ERS_ReportConsultants rc on (pr.Endoscopist1 = rc.ConsultantID OR pr.Endoscopist2 = rc.ConsultantID)
	Where pr.ModifiedOn > pfu.ModifiedOn
	and pr.PatientId in (Select PatientID from @ProceduresWithFollowUp)
	--MH added on 10 Mar 2022
	and IsNull(pr.DNA,0) = 0
	--and pr.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	and rc.UserID = @UserId


	--Select * from @ProceduresWithFollowUp order by patientid,ModifiedOn
	--Select * from @ProceduresAfterFollowUp order by patientid,ModifiedOn

	--Select  p.Forename1 + ' ' + p.Surname as PatientName, p.DateOfBirth,p.NHSNo,p.HospitalNumber,

	-- pt.ProcedureType,pr.ModifiedOn as ProcedureDate,
	-- ugfu.FurtherProcedureText

	-- from ERS_Procedures pr
	-- inner join ERS_Patients p on pr.PatientID = p.PatientID
	-- inner join ERS_ProcedureTypes pt on pr.ProcedureType=pt.ProcedureTypeId
	-- left join ERS_UpperGIFollowUp ugfu on pr.ProcedureId = ugfu.ProcedureId
	-- Left join @ProceduresWithFollowUp fup on pr.ProcedureId = fup.ProcedureId
	-- --Where IsNull(ugfu.FurtherProcedureText,'') <> '' or fup.ModifiedOn > pr.ModifiedOn
	-- Order by p.Forename1 + ' ' + p.Surname,pr.ModifiedOn asc

	Select 
	Oh.HospitalName as OperatingHospital
	,p.Forename1 + ' ' + p.Surname as PatientName
	,dbo.fnGender(p.GenderId) as Gender
	,Format(p.DateOfBirth,'dd MMM yyyy') as DateOfBirth
	,dbo.fn_FormatHealthServiceNumber(p.NHSNo, @HealthService) as 'NHSNo'
	,p.HospitalNumber
	,pt.ProcedureType
	,Format(pr.ModifiedOn,'dd MMM yyyy hh:mm tt') as ProcedureDate
	,PS.ListItemText as PatientStatus
	,PatT.ListItemText as PatientType
	,lic.ListItemText as PatientPathway
	,ugfu.FurtherProcedureText as FollowUpProcedure
	,E1.Forename + ' ' + E1.Surname as RequestedByEndoscopist1
	,Format((fup.InTimeDaysNumber / 7.00),'##.##') DueInWeeks
	,Format(DateAdd(Day,fup.InTimeDaysNumber,pr.CreatedOn),'dd MMM yyyy') DueOn

	from ERS_Procedures pr
	inner join ERS_Patients p on pr.PatientID = p.PatientID
	inner join ERS_ProcedureTypes pt on pr.ProcedureType=pt.ProcedureTypeId
	inner join ERS_OperatingHospitals OH on pr.OperatingHospitalID = OH.OperatingHospitalId
	inner join (Select ListItemNo,ListItemText from ERS_Lists where ListDescription = 'Patient Status') PS on pr.PatientStatus = ps.ListItemNo
	inner join (Select ListItemNo,ListItemText from ERS_Lists where ListDescription = 'Patient Type') PatT on pr.PatientType = patt.ListItemNo
	left join ERS_UpperGIFollowUp ugfu on pr.ProcedureId = ugfu.ProcedureId
	left join @ProceduresWithFollowUp fup on pr.ProcedureId = fup.ProcedureId
	left join @ProceduresAfterFollowUp afup on pr.ProcedureId = afup.ProcedureId
	Left join ERS_Users E1 on pr.Endoscopist1 = E1.UserID
	inner join (Select ListItemNo,ListItemText from ERS_Lists where ListDescription = 'Procedure Category') lic on pr.CategoryListId = lic.ListItemNo
	--Where IsNull(ugfu.FurtherProcedureText,'') <> '' or fup.ModifiedOn > pr.ModifiedOn
	Where fup.ProcedureId is not null or afup.ProcedureId is not null
	--MH added on 10 Mar 2022
		and IsNull(pr.DNA,0) = 0
	Order by p.Forename1 + ' ' + p.Surname,pr.ModifiedOn asc
END

GO

EXEC dbo.DropIfExist @ObjectName = 'auditDiagBiopForDiarrhoea',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditDiagBiopForDiarrhoea]
	@UserId int
AS
/*
--	Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
						:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
*/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100),  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
			@HealthService as varchar(max)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			i.NEDTerm as 'Diarrhoea indications',
			biop.Biopsy as 'Specimens Taken'
	FROM ERS_Procedures p
	join ERS_Users u on u.UserID = p.Endoscopist1
	left join ERS_Users u2 on u2.UserID = p.Endoscopist2
	join ERS_Patients pat on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	join ERS_ProcedureIndications pli ON pli.ProcedureId = p.ProcedureId
	join ERS_Indications i ON i.UniqueId = pli.IndicationId AND i.NEDTerm IN ('Looser or more frequent stool - chronic (&gt;6w)', 'Looser or more frequent stool - acute (&lt;6w)')
	join (Select s.ProcedureId, STUFF(CASE WHEN SUM(convert(int, BiopsyQtyHistology)) > 0 then ', ' + convert(varchar, SUM(convert(int, BiopsyQtyHistology))) + ' Biopsy(s) to Histology' ELSE '' END + 
		CASE WHEN SUM(convert(int, BiopsyQtyMicrobiology)) > 0 then ', ' + convert(varchar, SUM(convert(int, BiopsyQtyMicrobiology))) + ' Biopsy(s) to MicroBiology' ELSE '' END + 
		CASE WHEN SUM(convert(int, BiopsyQtyVirology)) > 0 then ', ' + convert(varchar, SUM(convert(int, BiopsyQtyVirology))) + ' Biopsy(s) to Virology' ELSE '' END + 
		CASE WHEN SUM(convert(int, Polypectomy)) > 0 then ', ' + convert(varchar, SUM(convert(int, Polypectomy))) + ' Polypectomy(s)' ELSE '' END , 1, 2, '') as Biopsy
		from ERS_UpperGISpecimens spec
		join ERS_Sites s on spec.SiteId = s.SiteId
		group by s.ProcedureId) biop on biop.ProcedureId = p.ProcedureId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	--MH added on 10 Mar 2022
		and IsNull(p.DNA,0) = 0
END

GO

EXEC dbo.DropIfExist @ObjectName = 'auditHaemostasisAfterEndo',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[auditHaemostasisAfterEndo]
	@UserId int
AS
/*
--	Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
						:		11 May 2022 SG added Health Service Number formatting
						:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
*/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100), --added by mostafiz 5/21/24 Filter by Hospital TFS1811
			@HealthService as varchar(max)

	DECLARE @indHaematemesisId AS INT;
    DECLARE @indMelaenaId AS INT;

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	SELECT @indHaematemesisId = CASE WHEN [NEDTerm] = 'Haematemesis' THEN UniqueId ELSE 0 END FROM dbo.ERS_Indications WHERE [NEDTerm] = 'Haematemesis'
	SELECT @indMelaenaId = CASE WHEN [NEDTerm] = 'Melaena' THEN UniqueId ELSE 0 END FROM dbo.ERS_Indications WHERE [NEDTerm] = 'Melaena'

	Select pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			pt.ProcedureType as 'Procedure',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			CASE WHEN pri.IndicationId = @indHaematemesisId then 'Yes' ELSE 'No' END as Haematemesis,
			CASE WHEN pri.IndicationId = @indMelaenaId then 'Yes' ELSE 'No' END as Melaena
	FROM ERS_Procedures p
	join ERS_ProcedureTypes pt on p.ProcedureType = pt.ProcedureTypeId 
	join ERS_Users u on u.UserID = p.Endoscopist1
	left join ERS_Users u2 on u2.UserID = p.Endoscopist2
	join ERS_Patients pat on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	--join ERS_UpperGIIndications ind on p.ProcedureId = ind.ProcedureId 
	LEFT JOIN dbo.ERS_ProcedureIndications AS pri ON pri.ProcedureId = p.ProcedureId
	LEFT JOIN dbo.ERS_Indications AS ind ON ind.UniqueId = pri.IndicationId 
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and pri.IndicationId = @indHaematemesisId or pri.IndicationId = @indMelaenaId
	--and pat.PatientId IN (Select PatientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	--MH added on 10 Mar 2022
	and IsNull(p.DNA,0) = 0
END

GO

EXEC dbo.DropIfExist @ObjectName = 'report_JAGBowel',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[report_JAGBowel] 
	@UserID INT 
AS
/*	Update History	:	04 Apr 2022		:		Mahfuz made changes for TFS # 2016 - Changed source tables, columns etc 
					:	21 May 2024		:		Mostafiz TFS1811: Filter by Operating Hospital 

*/
BEGIN


	DECLARE @FromDate as Date,
			@ToDate as Date,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Forename1 + ' '+ pat.Surname as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo',
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			CASE WHEN p.ProcedureType = 3 THEN 'Colonoscopy' ELSE 'Sigmoidoscopy' END as 'Procedure Type',
			u.Forename + ' ' + u.Surname as 'Endoscopist 1',
			u2.Forename + ' ' + u2.Surname as 'Endoscopist 2',
			BP.Description as 'BowelPrepFormulation',
			PBP.LeftPrepScore,
			PBP.RightPrepScore,
			PBP.TransversePrepScore,
			PBP.TotalPrepScore as 'BostonBowelPrepTotalScore'
	FROM ERS_Procedures p
	join ERS_Users u on u.UserID = p.Endoscopist1
	left join ERS_Users u2 on u2.UserID = p.Endoscopist2
	join ERS_Patients pat on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	Left join ERS_ProcedureBowelPrep PBP on p.ProcedureId = PBP.ProcedureID 
	Left Join ERS_BowelPrep BP on PBP.BowelPrepId = BP.UniqueId

	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType in (3, 4)
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and ISNULL(p.DNA, 0) = 0
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	Order By p.CreatedOn

END

-- Drop Procedure if it already exists
GO

EXEC dbo.DropIfExist @ObjectName = 'auditUseOfReversingAgent',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditUseOfReversingAgent]
	@UserId int
AS
/*
--	Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
						:		11 May 2022 SG added Health Service Number formatting
						:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
*/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100),  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
			@HealthService as varchar(max)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			d.DrugName + ' - ' + convert(varchar, pm.Dose) + CASE WHEN pm.Units = '(none)' then '' else isnull(pm.Units, '') END as 'Reversing Agent'
	FROM ERS_Procedures p
	join ERS_Users u on u.UserID = p.Endoscopist1
	left join ERS_Users u2 on u2.UserID = p.Endoscopist2
	join ERS_Patients pat on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	join ERS_UpperGIPremedication pm on p.ProcedureId = pm.ProcedureId
	join ERS_DrugList d on pm.DrugNo = d.DrugNo
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and d.IsReversingAgent = 1
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	--MH added on 10 Mar 2022
		and IsNull(p.DNA,0) = 0
END

-- Drop Procedure if it already exists
GO

EXEC dbo.DropIfExist @ObjectName = 'auditAssessmentOfComfortSummary',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditAssessmentOfComfortSummary]
	@UserId int
AS

/*****************************************************************************************************************
Update History:
	01		:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
******************************************************************************************************************/

BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	Create table #comfortSummary (
		orderBy int,
		ComfortScore varchar(100),
		OGD int,
		ERCP int,
		Col int,
		Sig int,
		Proct int,
		EUSOGD int,
		EUSHPB int,
		ENT int)

	INSERT INTO #comfortSummary (orderBy, ComfortScore)
	values (0, '<b>Assessment Scores</b>')
	
	INSERT INTO #comfortSummary
	SELECT eds.ListOrderBy,
	eds.[Description] 'Comfort Score',
	COUNT(CASE WHEN ep.ProcedureType = 1 THEN ep.ProcedureId END) AS OGD,
	COUNT(CASE WHEN ep.ProcedureType = 2 THEN ep.ProcedureId END) AS ERCP,
	COUNT(CASE WHEN ep.ProcedureType = 3 THEN ep.ProcedureId END) AS Col,
	COUNT(CASE WHEN ep.ProcedureType = 4 THEN ep.ProcedureId END) AS Sig,
	COUNT(CASE WHEN ep.ProcedureType = 5 THEN ep.ProcedureId END) AS Proct,
	COUNT(CASE WHEN ep.ProcedureType = 6 THEN ep.ProcedureId END) AS EUSOGD,
	COUNT(CASE WHEN ep.ProcedureType = 7 THEN ep.ProcedureId END) AS EUDHPB,
	COUNT(CASE WHEN ep.ProcedureType IN (8,9) THEN ep.ProcedureId END) AS ENT
	  FROM dbo.ERS_Procedures ep
	join	ERS_Patients pat on ep.PatientId = pat.PatientId 
	INNER JOIN dbo.ERS_ProcedureDiscomfortScore epds ON ep.ProcedureId = epds.ProcedureId
	INNER JOIN dbo.ERS_DiscomfortScores eds ON epds.DiscomfortScoreId = eds.UniqueId
	join ERS_Users u on u.UserID = ep.Endoscopist1
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	where ep.ProcedureCompleted = 1
	and ep.IsActive = 1
	and ep.CreatedOn >= @FromDate AND ep.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND ep.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	GROUP BY eds.[Description], eds.ListOrderBy
	ORDER BY eds.ListOrderBy

	select ComfortScore,
		OGD,
		ERCP,
		Col,
		Sig,
		Proct,
		EUSOGD,
		EUSHPB,
		ENT from #comfortSummary order by orderBy

END

GO

EXEC dbo.DropIfExist @ObjectName = 'auditGastricUlcerWithin12Weeks',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[auditGastricUlcerWithin12Weeks]
	@UserId int
AS
/*
--	Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
						:		11 May 2022 SG added Health Service Number formatting
						:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
*/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100),  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
			@HealthService as varchar(max)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  distinct pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			convert(varchar, DATEADD(week, 12, p.CreatedOn), 106) as 'Followup Due Date', 
			case when (Select count(procedureId) 
					   from ERS_Procedures 
					   where PatientId = p.PatientId 
					   and CreatedOn > p.CreatedOn 
					   AND CreatedOn <= DATEADD(week, 12, p.CreatedOn)
					   and IsActive = 1 
					   and ProcedureCompleted = 1 
					   and ProcedureType = 1) > 0
				 then 'Yes'
				 else case when DATEADD(week, 12, p.CreatedOn) < getdate()
						   then 'No'
						   else '?'
					  end
			end as 'follow on Procedure carried out within 12 weeks?'
	FROM ERS_Procedures p
	join ERS_Users u on u.UserID = p.Endoscopist1
	left join ERS_Users u2 on u2.UserID = p.Endoscopist2
	join ERS_Patients pat on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	join ERS_Sites s on p.ProcedureId = s.ProcedureId 
	join dbo.ERS_CommonAbnoDuodenalUlcer ulc  on ulc.SiteId = s.SiteId 
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType = 1
	and ulc.Ulcer = 1	
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	--MH added on 10 Mar 2022
		and IsNull(p.DNA,0) = 0
END

GO

EXEC dbo.DropIfExist @ObjectName = 'auditTattooSmallTumours',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditTattooSmallTumours]
	@UserId INT
AS

BEGIN

	SET NOCOUNT ON

	IF OBJECT_ID('tempdb..#TattooedPolyps') IS NOT NULL
        DROP TABLE #TattooedPolyps;
		
	DECLARE @FromDate AS DATE,
			@ToDate AS DATE,
			@TrustId AS INT,
			@HealthService AS VARCHAR(MAX)	

	SELECT	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId
	FROM	dbo.ERS_ReportFilter
	WHERE	UserID = @UserId
	
	SELECT  @HealthService = CustomText FROM dbo.ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	DECLARE @TattooedId AS INT;
	SELECT @TattooedId = UniqueId FROM dbo.ERS_TattooOptions WHERE NEDTerm = 'Yes'

	CREATE TABLE #TattooedPolyps
	(
		[Id] INT NOT NULL IDENTITY(1, 1),
		[ProcedureId] INT NOT NULL,
		[PolypDetailId] INT NOT NULL,
		[PolypTypeId] INT NOT NULL,
        [PolypType] VARCHAR(500) NOT NULL,
		[PolypQuantity] INT NOT NULL,
		[PolypSize] INT NOT NULL,
		[VillousQuantity] INT NULL,
		[VillousLargest] INT NULL,
		[SubmucosalQuantity] INT NULL,
		[SubmucosalLargest] INT NULL,
		[UlcerativeQuantity] INT NULL,
		[UlcerativeLargest] INT NULL,
		[StricturingQuantity] INT NULL,
		[StricturingLargest] INT NULL,
		[PolypoidalQuantity] INT NULL,
		[PolypoidalLargest] INT NULL
	)

	INSERT INTO #TattooedPolyps
	(
	    [ProcedureId],
		[PolypDetailId],
		[PolypTypeId],
		[PolypType],
	    [PolypQuantity],
	    [PolypSize],
		[VillousQuantity],
		[VillousLargest],
		[SubmucosalQuantity],
		[SubmucosalLargest],
		[UlcerativeQuantity],
		[UlcerativeLargest],
		[StricturingQuantity],
		[StricturingLargest],
		[PolypoidalQuantity],
		[PolypoidalLargest] 
	)
		SELECT 
			s.ProcedureId,
			capd.PolypDetailId,
			capd.PolypTypeId,			
			ISNULL([pt].[Description], ''),
			1,
			ISNULL(capd.Size, 0) AS [PolypSize],
			ISNULL(cat.VillousQuantity, 0),
			ISNULL(cat.VillousLargest, 0),
			ISNULL(cat.SubmucosalQuantity, 0),
			ISNULL(cat.SubmucosalLargest, 0),
			ISNULL(cat.UlcerativeQuantity, 0),
			ISNULL(cat.UlcerativeLargest, 0),
			ISNULL(cat.StricturingQuantity, 0),
			ISNULL(cat.StricturingLargest, 0),
			ISNULL(cat.PolypoidalQuantity, 0),
			ISNULL(cat.PolypoidalLargest, 0)			
		FROM 
			dbo.ERS_Procedures (NOLOCK) AS pro
			LEFT JOIN dbo.ERS_Sites (NOLOCK) s ON s.ProcedureId = pro.ProcedureId
			LEFT JOIN dbo.ERS_CommonAbnoPolypDetails (NOLOCK) AS capd ON capd.SiteId = s.SiteId
			LEFT JOIN dbo.ERS_CommonAbnoLesions (NOLOCK) AS cal ON cal.SiteId = s.SiteId
			LEFT JOIN dbo.ERS_TattooOptions (NOLOCK) AS eto ON eto.UniqueId = capd.TattooedId
			LEFT JOIN dbo.ERS_PolypTypes (NOLOCK) AS pt ON pt.UniqueId = capd.PolypTypeId	
			LEFT JOIN dbo.ERS_ColonAbnoTumour (NOLOCK) AS cat ON cat.SiteId = s.SiteId
		WHERE 
			(ISNULL(cal.[None], 0) = 0 OR ISNULL(cat.[None], 0) = 0)
			AND (ISNULL(capd.TattooedId, 0) = @TattooedId OR ISNULL(cal.Tattooed, 0) = 1 OR ISNULL(cat.TattooedId, 0) = @TattooedId)			
			AND (capd.Type = 2 OR cat.SubmucosalType = 2 OR cat.VillousType = 2 OR cat.UlcerativeType = 2 OR cat.StricturingType = 2 OR cat.PolypoidalType = 2)
			AND pro.ProcedureCompleted = 1	
	   
	   SELECT  p.ProcedureId,
			pat.Surname + ', '+ pat.Forename1 AS Patient, 
			pat.HospitalNumber AS [Case No.],
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) AS [NHS No], 
			dbo.fnGender(pat.GenderId) AS Gender, 
			CONVERT(VARCHAR(100), p.CreatedOn, 106) AS [Procedure Date] ,
			(CONVERT(INT,CONVERT(CHAR(8),p.CreatedOn,112))-CONVERT(CHAR(8),pat.DateOfBirth,112))/10000 AS [Age at Procedure],
			u.Surname + ', '+ u.Forename AS [Endoscopist 1],
			u2.Surname + ', '+ u2.Forename AS [Endoscopist 2],
			CASE WHEN tum.PolypType = 'Sessile' THEN SUM(tum.PolypQuantity) ELSE 0 END AS [Sessile Quantity],
			CASE WHEN tum.PolypType = 'Sessile' THEN MAX(tum.PolypSize) ELSE 0 END AS [Sessile Largest],
			CASE WHEN tum.PolypType = 'Pedunculated' THEN SUM(tum.PolypQuantity) ELSE 0 END AS [Pedunculated Quantity],
			CASE WHEN tum.PolypType = 'Pedunculated' THEN MAX(tum.PolypSize) ELSE 0 END AS [Pedunculated Largest],
			CASE WHEN tum.PolypType = 'Pseudo' THEN SUM(tum.PolypQuantity) ELSE 0 END AS [Pseudo Quantity],
			CASE WHEN tum.PolypType = 'Pseudo' THEN MAX(tum.PolypSize) ELSE 0 END AS [Pseudo Largest],
			CASE WHEN tum.PolypType = 'Submucosal' THEN SUM(tum.PolypQuantity) ELSE 0 END AS [Submucosal Quantity],
			CASE WHEN tum.PolypType = 'Submucosal' THEN MAX(tum.PolypSize) ELSE 0 END AS [Submucosal Largest],
			SUM(tum.VillousQuantity) AS [Villous Quantity],
			MAX(tum.VillousLargest) AS [Villous Largest],
			SUM(tum.SubmucosalQuantity) AS [Submucosal Quantity],
			MAX(tum.SubmucosalLargest) AS [Submucosal Largest],
			SUM(tum.UlcerativeQuantity) AS [Ulcerative Quantity],
			MAX(tum.UlcerativeLargest) AS [Ulcerative Largest],
			SUM(tum.StricturingQuantity) AS [Stricturing Quantity],
			MAX(tum.StricturingLargest) AS [Stricturing Largest],
			SUM(tum.PolypoidalQuantity) AS [Polypoidal Quantity],
			MAX(tum.PolypoidalLargest) AS [Polypoidal Largest],
			SUM(tum.PolypQuantity) + SUM(tum.VillousQuantity) + SUM(tum.SubmucosalQuantity) + SUM(tum.UlcerativeQuantity) + SUM(tum.StricturingQuantity) + SUM(tum.PolypoidalQuantity)  AS [Number Tattooed]
	FROM dbo.ERS_Procedures (NOLOCK) p
	INNER JOIN #TattooedPolyps AS tum ON tum.ProcedureId = p.ProcedureId
	LEFT JOIN dbo.ERS_Users (NOLOCK) u on u.UserID = p.Endoscopist1
	LEFT JOIN dbo.ERS_Users (NOLOCK) u2 on u2.UserID = p.Endoscopist2
	LEFT JOIN dbo.ERS_Patients (NOLOCK) pat on pat.PatientId = p.PatientId
	LEFT JOIN dbo.ERS_ReportConsultants (NOLOCK) rc on u.UserID = rc.ConsultantID 
	WHERE p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and pat.PatientId in (SELECT patientId FROM dbo.ERS_PatientTrusts WHERE TrustId = @TrustId)
	and ISNULL(p.DNA, 0) = 0
	GROUP BY p.ProcedureId, tum.PolypType, pat.Surname, pat.Forename1, pat.HospitalNumber, pat.NHSNo, pat.GenderId, p.CreatedOn, pat.DateOfBirth, u.Surname, u.Forename, u2.Surname, u2.Forename 
END

GO

EXEC dbo.DropIfExist @ObjectName = 'auditAdenomaPolypDetectionRate',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditAdenomaPolypDetectionRate]
	@UserId int
AS

/*****************************************************************************************************************
Update History:
	01		:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
******************************************************************************************************************/

BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId

	Select  u.Surname + ', '+ u.Forename as 'Endoscopist',
			sum(CASE WHEN pr.AdenomaConfirmedHistologically = 1 THEN 1 ELSE 0 END) as 'Total polyps confirmed as adenomatous',
			SUM(CASE WHEN pr.AdenomaConfirmedHistologically = 0 THEN 1 ELSE 0 END) as 'Total polyps confirmed as non adenomatous',
			SUM(CASE WHEN pr.AdenomaConfirmedHistologically IS NULL THEN 1 ELSE 0 END) as 'Total polyps awaiting results'
	FROM ERS_Procedures p
	join	ERS_Patients pat on p.PatientId = pat.PatientId 
	join ERS_Users u on u.UserID = p.Endoscopist1
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	left join ERS_UpperGIPathologyResults pr on p.ProcedureId = pr.ProcedureId
	join ERS_Sites s on s.ProcedureId = p.ProcedureId 
	join ERS_UpperGISpecimens  sp on s.SiteId = sp.SiteId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and sp.Polypectomy = 1
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	Group By u.Surname + ', '+ u.Forename
END

GO

EXEC dbo.DropIfExist @ObjectName = 'auditColonDetailedFailure',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditColonDetailedFailure]
	@UserId int
AS

/*****************************************************************************************************************
Update History:
	01		:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
******************************************************************************************************************/

BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100),  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
			@HealthService as varchar(max)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHS number',
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			CASE WHEN p.ProcedureType = 3 THEN 'Colonoscopy' ELSE 'Sigmoidoscopy' END as 'Procedure Type',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			l.[Description] as 'Insertion Limited By'
	FROM ERS_Procedures p
	join ERS_Users u on u.UserID = p.Endoscopist1
	left join ERS_Users u2 on u2.UserID = p.Endoscopist2
	join ERS_Patients pat on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
	join ERS_ProcedureLowerExtent ple on ple.ProcedureId = p.ProcedureId AND ple.EndoscopistId = p.Endoscopist1
	join ERS_Limitations l on l.UniqueId = ple.LimitationId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType =3
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and ISNULL(ple.LimitationId, 0) > 0
	and ISNULL(l.NEDTerm,'') <> 'Not limited'
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)  --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	and ISNULL(p.DNA, 0) = 0
	Order By p.CreatedOn
END

-- Drop Procedure if it already exists
GO

EXEC dbo.DropIfExist @ObjectName = 'auditNQAIS',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditNQAIS] @UserId int
AS

/*****************************************************************************************************************
Update History:
	01		:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
******************************************************************************************************************/

BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100)  --added by mostafiz 5/21/24 Filter by Hospital TFS1811

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM ERS_ReportFilter
	where UserID = @UserId

Select distinct
	(Select top 1 NED_HospitalSiteCode From ERS_SystemConfig) as [Hospital ID],
	p. ProcedureId as [Case ID],
	pt.HospitalNumber as [Patient ID],
	Case pat.GenderId when 2 then 'M' When 3 then 'F' else '' end as [Patient Gender],
	dbo.fnGetAgeAtDate(pat. DateOfBirth, p. CreatedOn) as [Patient Age],
	'' as [Reserved Field 1],
	'' as [Reserved Field 2],
	'' as [Reserved Field 3],
	convert (varchar, p. Createdon, 23) as [Procedure Date],
	endo1.GMCCode as [Endoscopist ID],
	ISNULL(endo2. GMCCode, '') as [Endoscopist 2 ID],
	Case p.ProcedureType When 1 then 'OGD' When 2 then 'ERCP' When 3 then 'COL' When 4 then 'FSIG' END as [Procedure ID], 
	dbo.fnNQAIS_ProcedureExtent (p.ProcedureId) as [Intubate To ID], 
	case when dbo.fnNQAIS_ProcedureExtent (p.ProcedureId) = 'NONE' then 'No' else 'Yes' END as [Successful Intubation],
	Case
		When fentanyl is not null then 'FE' else''
	end as [Sedative 1 ID],
	Case
		When fentanyl is not null then fentanyl else null 
	end as [Sedative 1 Quantity],
	Case
		When Pethidine is not null then 'P' else ''
	end as [Sedative 2 ID],
	Case
		When Pethidine is not null then Pethidine else null
	end as [Sedative 2 Quantity],
	Case
		When Midazolam is not null then 'M' else ''
	end as [Sedative 3 ID],
	Case
		When Midazolam is not null then Midazolam else null
	end as [Sedative 3 Quantity],
	Case
		When Diazepam is not null then 'D' else ''
	end as [Sedative 4 ID],
	Case
		When Diazepam is not null then Diazepam else null
	end as [Sedative 4 Quantity],
	Case
		When Alfentanil is not null then 'A' else ''
	end as [Sedative 5 ID],
	Case
		When Alfentanil is not null then Alfentanil else null
	end as [Sedative 5 Quantity],
	Case
		When Tramadol is not null then 'T' else ''
	end as [Sedative 6 ID],
	Case
		When Tramadol is not null then Tramadol else null
	end as [Sedative 6 Quantity],
	Case
		When Flumazenil is not null then 'FL' else ''
	end as [Reversal Agent 1 ID],
	Case
		When Naloxone is not null then 'N' else ''
	end as [Reversal Agent 2 ID],
	Case when CEOI.Retroflexion = 1 or CEOI.NED_Retroflexion = 1 or OEOI.Jmanoeuvre = 2 or OEOI.TrainerJmanoeuvre = 2 then 'Yes' else 'No' End as Retroflexion,
	case when isnull(ulc.Ulcer, 0) = 1 then 'Yes' else 'No' end as [Gastric Ulcer],
	case when rep.ProcedureId Is Null then 'No' else 'Yes' end as [Repeat Request],
	QA.PatDiscomfortEndo as [Comfort Score],
	case when ISNULL(MPT.ProcedureId, 0) = 0 then 'No' else 'Yes' end as [Suspect MPT],
	Case When MPT.Tattooing = 1 then 'Yes' Else 'No' END as [Tattooing],
	Case when isnull(MPT.Quantity, 0) = 0 then 'No' else convert(varchar, MPT.Quantity) end as [Polyps Detected],
	ISNULL(MPT.Excised, 0) as [Polyps Excised],
	ISNULL (MPT.Retrieved, 0) as [Polyps Retrieved],
	case isnull(BowelPrepQuality, 0) When 1 then 4 When 2 then 3 when 3 then 2 when 4 then 1 else null end as [Bowel Prep Score], ------------------------------------------------------------------
	Case when ind.Diarrhoea = 1 then 'P' else 'N' end as [Diarrhoea Level],
	case when ISNULL(spec.ProcedureId, 0) = 0 then 'No' else 'Yes' End as [Mucosal Biopsy],
	case When isnull(QA.Perforation, 8) = 1 and p.ProcedureType in (3, 4) then 'Yes' else 'No' end as [Colonic Perforation],
	case when ISNULL(MPT.Excised, 0) > 0 then 'Yes' else 'No' end as [Poly Performed],
	case When ISNULL (poc.Perforation, 0) =1 and ISNULL(MPT.Excised, 0) > 0 then 'Yes' else 'No' end as [Post Poly Perforation],
	case when isnull(poc.BleedingFollowingPolypectomy, 0) = 1 then 'Yes' else 'No' end as [Post Poly Bleeding],
	'' as [Reserved Field 4],
	'' as [Reserved Field 5],
	'' as [Reserved Field 6],
	'' as [Reserved Field 7],
	'' as [Reserved Field 8],
	'' as [Reserved Field 9],
	'1' as [Extract Version]
FROM ERS_Procedures p
join ERS_Patients pat on p.PatientId = pat.PatientId
join ERS_PatientTrusts pt on pat.PatientId = pt.PatientId
join ERS_Users endo1 on p.Endoscopist1 = endo1.UserID
left join ERS_Users endo2 on isnull(p.Endoscopist2, -1) = endo2.UserID
left Join (select * from (
			Select ProcedureId, DrugName, Dose from ERS_UpperGIPremedication
			) t
			PIVOT (
				sum(Dose)
				FOR DrugName in ([Fentanyl], [Pethidine], [Midazolam], [Diazepam], [Alfentanil], [Tramadol], [Flumazenil], [Naloxone])
			) as a) as Sed on Sed.ProcedureId = p.ProcedureId
LEFT JOIN ERS_ColonExtentOfIntubation AS CEOI ON p.ProcedureId = CEOI.ProcedureId
LEFT JOIN ERS_UpperGIExtentOfIntubation AS OEOI on p.ProcedureId = OEOI.ProcedureId
LEFT JOIN (select distinct s.ProcedureId, agu.Ulcer from ERS_Sites s
			join ERS_UpperGIAbnoGastriculcer agu on agu.SiteId = s.SiteId
			where agu.Ulcer = 1) AS ulc on p.ProcedureId = ulc.ProcedureId
LEFT JOIN (Select distinct ProcedureId
			from [ERS_UpperGIFollowup]
			where isnull (FurtherProcedureText, '') like '%Week(s)%'
			or isnull(FurtherProcedureText, '') like '%1 month(s)%'
			or isnull(FurtherProcedureText, '') like '%2 month(s)%'
			or isnull(FurtherProcedureText, '') like '%3 month(s)%') rep on rep.ProcedureId = p.ProcedureId
LEFT JOIN ERS_UpperGIQA QA on p.ProcedureId = QA.ProcedureId
LEFT JOIN (Select distinct s.ProcedureId, max (isnull (case when ut.MarkingType is null then cp.Tattooed else ut.MarkingType end, 0)) as Tattooing,
				sum(ISNULL (cp.SessileQuantity, 0)) + sum(ISNULL(cp.PedunculatedQuantity, 0)) + sum(ISNULL(cp.PseudopolypsQuantity, 0)) +
				sum(ISNULL (up.SessileQty, 0)) + sum(ISNULL(up.PedunculatedQty, 0)) + sum(ISNULL(up.SubmucosalQty, 0))as Quantity,
				sum(ISNULL (cp.SessileExcised, 0)) + sum(ISNULL (cp.PedunculatedExcised, 0)) + sum(ISNULL(cp.PseudopolypsExcised, 0)) +
				sum(ISNULL (up.SessileNumExcised, 0)) + sum(ISNULL(up.PedunculatedNumExcised, 0)) + sum(ISNULL(up.SubmucosalNumExcised, 0)) as Excised,
				sum(ISNULL (cp.SessileRetrieved, 0)) + sum(ISNULL(cp.PedunculatedRetrieved, 0)) + sum(ISNULL(cp.PseudopolypsRetrieved, 0)) +
				sum(ISNULL (up.SessileNumRetrieved, 0)) + sum(ISNULL(up.PedunculatedNumRetrieved, 0)) + sum(ISNULL (up.SubmucosalNumRetrieved, 0)) as Retrieved
			from ERS_Sites s
			left join ERS_ColonAbnoLesions cp on s.SiteId = cp.SiteId
			left join ERS_UpperGIAbnoPolyps up on s.SiteId = up.SiteId
			left join ERS_UpperGITherapeutics ut on s.SiteId = ut.SiteId and ut.Marking = 1 and ut.MarkingType = 1
			where	((cp.Sessile = 1 or cp.Pedunculated = 1 or cp.Pseudopolyps = 1) or
					(up. Sessile = 1 or up.Pedunculated = 1 or up.Submucosal = 1))
			Group by s.ProcedureId) MPT on p.ProcedureId = MPT.ProcedureId
LEFT JOIN (	Select ebp.ProcedureId,
			case when BowelPrepSettings = 0 
			then 
				case when isnull(BowelPrepQuality, 0) = 0 then 1 else BowelPrepQuality end
			else
				Case OnNoBowelPrep when 1 then 
					1
				else
					case
					when ext.Orderby < 8
						then ebp.onLeft
					When ext.OrderBy > 7 and ext.OrderBy < 12
						then (ebp.OnLeft + ebp.OnTransverse) / 2
					When ext.OrderBy > 11 and ext.OrderBy < 19
						then (ebp.OnLeft + ebp.OnTransverse + ebp.OnRight) / 3
					else 0
					end + 1
				end 
			end		
				as BowelPrepQuality
			from ERS_BowelPreparation ebp
			join ERS_ColonExtentOfIntubation cext on ebp.ProcedureID = cext.ProcedureId
			join ERS_ColonExtent ext on cext.InsertionTo = ext.ExtentID) bp on p.ProcedureId = bp.ProcedureId
LEFT JOIN ERS_UpperGIIndications ind on p.ProcedureId = ind.ProcedureId
LEFT Join (select distinct s.procedureId
			from ERS_Sites s
			join ERS_UpperGISpecimens spec on s.SiteId = spec.SiteId
			where spec.Biopsy = 1) spec on p.ProcedureId = spec.ProcedureId
LEFT JOIN ERS_PostOperativeComplications poc on p.ProcedureId = poc.ProcedureId
join ERS_ReportConsultants rc on p.Endoscopist1 = rc.ConsultantID
WHERE p.IsActive = 1
and p.ProcedureCompleted = 1
and p.ProcedureType in (1, 2, 3, 4)
and p.Createdon >= @FromDate AND p.Createdon <= @ToDate
and p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
and rc.UserID = @UserId
END

GO

EXEC dbo.DropIfExist @ObjectName = 'AuditTransnasalOGDReports',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[AuditTransnasalOGDReports]
@UserId INT
AS

/*****************************************************************************************************************
Update History:
	01		:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
******************************************************************************************************************/

BEGIN
	DECLARE @FromDate AS DATE,
			@ToDate AS DATE,
			@TrustId AS INT,
			@OperatingHospitalList as varchar(100),  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
			@HealthService AS VARCHAR(MAX)

	--Polyp Types
	DECLARE @polypSessile AS INT;
	DECLARE @polypPedunculated AS INT;
	DECLARE @polypPseudo AS INT;
	DECLARE @polypSubmucosal AS INT;
	
	--Adverse Events
	DECLARE @advEvNone AS INT;

	SELECT	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	WHERE	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	--Poly Types
	SELECT @polypSessile = UniqueId FROM dbo.ERS_PolypTypes WHERE [Description] = 'Sessile'
	SELECT @polypPedunculated = UniqueId FROM dbo.ERS_PolypTypes WHERE [Description] = 'Pedunculated'
	SELECT @polypPseudo = UniqueId FROM dbo.ERS_PolypTypes WHERE [Description] = 'Pseudo'
	SELECT @polypSubmucosal = UniqueId FROM dbo.ERS_PolypTypes WHERE [Description] = 'Submucosal'

	--Adverse Events
	SELECT @advEvNone = UniqueId FROM dbo.ERS_AdverseEvents WHERE NEDTerm = 'None' OR [Description] = 'None'

DECLARE @tableVarTherapeutics TABLE(
ProcedureId INT NOT NULL,
TherapeuticProcedures VARCHAR(4000) NULL
)
INSERT INTO @tableVarTherapeutics(ProcedureId,TherapeuticProcedures)
SELECT S.ProcedureId,
TherapeuticProcedures = R.Region + ':' + CASE WHEN TP.[None] = '1' THEN 'None'
ELSE
	CASE WHEN LEN(LTRIM(RTRIM(CASE WHEN TP.YAGLaser = '1' THEN 'YAG Laser, ' ELSE '' END
	+
	CASE WHEN TP.ArgonBeamDiathermy = '1' THEN 'Argon beam diathermy, ' ELSE '' END
	+
	CASE WHEN TP.BalloonDilation = '1' THEN 'Balloon dilation, ' ELSE '' END
	+ 
	CASE WHEN TP.BandLigation = '1' THEN 'Band ligation, ' ELSE '' END
	+
	CASE WHEN TP.BotoxInjection = '1' THEN 'Botox injection, ' ELSE '' END
	+
	CASE WHEN TP.EndoloopPlacement = '1' THEN 'Endoloop placement, ' ELSE '' END
	+
	CASE WHEN TP.EndoscopicResection = '1' THEN 'Endoscopic resection, ' ELSE '' END
	+
	CASE WHEN TP.HeatProbe = '1' THEN 'Heater probe coagulation, ' ELSE '' END
	+
	CASE WHEN TP.BicapElectro = '1' THEN 'Bicap electrocautery, ' ELSE '' END
	+
	CASE WHEN TP.Diathermy = '1' THEN 'Diathermy, ' ELSE '' END
	+
	CASE WHEN TP.Haemospray = '1' THEN 'Haemospray, ' ELSE '' END
	+
	CASE WHEN TP.HotBiopsy = '1' THEN 'Hot biopsy, ' ELSE '' END
	+
	CASE WHEN TP.FlatusTubeInsertion = '1' THEN 'Flatus tube insertion, ' ELSE '' END
	+
	CASE WHEN TP.ForeignBody = '1' THEN 'Foreign body removal, ' ELSE '' END
	+
	CASE WHEN TP.Injection = '1' THEN 'Injection therapy, ' ELSE '' END
	+
	CASE WHEN TP.Polypectomy = '1' THEN 'Polypectomy, ' ELSE '' END
	+
	CASE WHEN TP.PyloricDilatation = '1' THEN 'Pyloric/duodenal dilatation, ' ELSE '' END
	+
	CASE WHEN TP.GastrostomyInsertion = '1' THEN 'Gastrostomy insertion (PEG), ' ELSE '' END
	+
	CASE WHEN TP.GastrostomyRemoval = '1' THEN 'Gastrostomy removal (PEG), ' ELSE '' END
	+
	CASE WHEN TP.NGNJTubeInsertion = '1' THEN 'NG/NJ tube insertion, ' ELSE '' END
	+
	CASE WHEN TP.VaricealSclerotherapy = '1' THEN 'Variceal sclerotherapy, ' ELSE '' END
	+
	CASE WHEN TP.VaricealBanding = '1' THEN 'Variceal banding, ' ELSE '' END
	+
	CASE WHEN TP.StentInsertion = '1' THEN 'Stent insertion, ' ELSE '' END
	+
	CASE WHEN TP.StentRemoval = '1' THEN 'Stent removal, ' ELSE '' END
	+
	CASE WHEN TP.Marking = '1' THEN 'Marking, ' ELSE '' END
	+
	CASE WHEN TP.Clip = '1' THEN 'Clip, ' ELSE '' END
	+
	CASE WHEN TP.EndoClot = '1' THEN 'Endo clot, ' ELSE '' END
	))) > 1 THEN
	LEFT(Ltrim(Rtrim(CASE WHEN TP.YAGLaser = '1' THEN 'YAG Laser, ' ELSE '' END
	+
	CASE WHEN TP.ArgonBeamDiathermy = '1' THEN 'Argon beam diathermy, ' ELSE '' END
	+
	CASE WHEN TP.BalloonDilation = '1' THEN 'Balloon dilation, ' ELSE '' END
	+ 
	CASE WHEN TP.BandLigation = '1' THEN 'Band ligation, ' ELSE '' END
	+
	CASE WHEN TP.BotoxInjection = '1' THEN 'Botox injection, ' ELSE '' END
	+
	CASE WHEN TP.EndoloopPlacement = '1' THEN 'Endoloop placement, ' ELSE '' END
	+
	CASE WHEN TP.EndoscopicResection = '1' THEN 'Endoscopic resection, ' ELSE '' END
	+
	CASE WHEN TP.HeatProbe = '1' THEN 'Heater probe coagulation, ' ELSE '' END
	+
	CASE WHEN TP.BicapElectro = '1' THEN 'Bicap electrocautery, ' ELSE '' END
	+
	CASE WHEN TP.Diathermy = '1' THEN 'Diathermy, ' ELSE '' END
	+
	CASE WHEN TP.Haemospray = '1' THEN 'Haemospray, ' ELSE '' END
	+
	CASE WHEN TP.HotBiopsy = '1' THEN 'Hot biopsy, ' ELSE '' END
	+
	CASE WHEN TP.FlatusTubeInsertion = '1' THEN 'Flatus tube insertion, ' ELSE '' END
	+
	CASE WHEN TP.ForeignBody = '1' THEN 'Foreign body removal, ' ELSE '' END
	+
	CASE WHEN TP.Injection = '1' THEN 'Injection therapy, ' ELSE '' END
	+
	CASE WHEN TP.Polypectomy = '1' THEN 'Polypectomy, ' ELSE '' END
	+
	CASE WHEN TP.PyloricDilatation = '1' THEN 'Pyloric/duodenal dilatation, ' ELSE '' END
	+
	CASE WHEN TP.GastrostomyInsertion = '1' THEN 'Gastrostomy insertion (PEG), ' ELSE '' END
	+
	CASE WHEN TP.GastrostomyRemoval = '1' THEN 'Gastrostomy removal (PEG), ' ELSE '' END
	+
	CASE WHEN TP.NGNJTubeInsertion = '1' THEN 'NG/NJ tube insertion, ' ELSE '' END
	+
	CASE WHEN TP.VaricealSclerotherapy = '1' THEN 'Variceal sclerotherapy, ' ELSE '' END
	+
	CASE WHEN TP.VaricealBanding = '1' THEN 'Variceal banding, ' ELSE '' END
	+
	CASE WHEN TP.StentInsertion = '1' THEN 'Stent insertion, ' ELSE '' END
	+
	CASE WHEN TP.StentRemoval = '1' THEN 'Stent removal, ' ELSE '' END
	+
	CASE WHEN TP.Marking = '1' THEN 'Marking, ' ELSE '' END
	+
	CASE WHEN TP.Clip = '1' THEN 'Clip, ' ELSE '' END
	+
	CASE WHEN TP.EndoClot = '1' THEN 'Endo clot, ' ELSE '' END
	)),Len(Ltrim(Rtrim(CASE WHEN TP.YAGLaser = '1' THEN 'YAG Laser, ' ELSE '' END
	+
	CASE WHEN TP.ArgonBeamDiathermy = '1' THEN 'Argon beam diathermy, ' ELSE '' END
	+
	CASE WHEN TP.BalloonDilation = '1' THEN 'Balloon dilation, ' ELSE '' END
	+ 
	CASE WHEN TP.BandLigation = '1' THEN 'Band ligation, ' ELSE '' END
	+
	CASE WHEN TP.BotoxInjection = '1' THEN 'Botox injection, ' ELSE '' END
	+
	CASE WHEN TP.EndoloopPlacement = '1' THEN 'Endoloop placement, ' ELSE '' END
	+
	CASE WHEN TP.EndoscopicResection = '1' THEN 'Endoscopic resection, ' ELSE '' END
	+
	CASE WHEN TP.HeatProbe = '1' THEN 'Heater probe coagulation, ' ELSE '' END
	+
	CASE WHEN TP.BicapElectro = '1' THEN 'Bicap electrocautery, ' ELSE '' END
	+
	CASE WHEN TP.Diathermy = '1' THEN 'Diathermy, ' ELSE '' END
	+
	CASE WHEN TP.Haemospray = '1' THEN 'Haemospray, ' ELSE '' END
	+
	CASE WHEN TP.HotBiopsy = '1' THEN 'Hot biopsy, ' ELSE '' END
	+
	CASE WHEN TP.FlatusTubeInsertion = '1' THEN 'Flatus tube insertion, ' ELSE '' END
	+
	CASE WHEN TP.ForeignBody = '1' THEN 'Foreign body removal, ' ELSE '' END
	+
	CASE WHEN TP.Injection = '1' THEN 'Injection therapy, ' ELSE '' END
	+
	CASE WHEN TP.Polypectomy = '1' THEN 'Polypectomy, ' ELSE '' END
	+
	CASE WHEN TP.PyloricDilatation = '1' THEN 'Pyloric/duodenal dilatation, ' ELSE '' END
	+
	CASE WHEN TP.GastrostomyInsertion = '1' THEN 'Gastrostomy insertion (PEG), ' ELSE '' END
	+
	CASE WHEN TP.GastrostomyRemoval = '1' THEN 'Gastrostomy removal (PEG), ' ELSE '' END
	+
	CASE WHEN TP.NGNJTubeInsertion = '1' THEN 'NG/NJ tube insertion, ' ELSE '' END
	+
	CASE WHEN TP.VaricealSclerotherapy = '1' THEN 'Variceal sclerotherapy, ' ELSE '' END
	+
	CASE WHEN TP.VaricealBanding = '1' THEN 'Variceal banding, ' ELSE '' END
	+
	CASE WHEN TP.StentInsertion = '1' THEN 'Stent insertion, ' ELSE '' END
	+
	CASE WHEN TP.StentRemoval = '1' THEN 'Stent removal, ' ELSE '' END
	+
	CASE WHEN TP.Marking = '1' THEN 'Marking, ' ELSE '' END
	+
	CASE WHEN TP.Clip = '1' THEN 'Clip, ' ELSE '' END
	+
	CASE WHEN TP.EndoClot = '1' THEN 'Endo clot, ' ELSE '' END
	)))-1)
	ELSE '' END
END
FROM
	ERS_UpperGITherapeutics TP
	INNER JOIN ERS_Sites S ON TP.SiteId = S.SiteId
	INNER JOIN ERS_Regions R ON S.RegionId = R.RegionId

DECLARE @tableAdverseEvents TABLE(
	ProcedureId INT NOT NULL,
	AdverseProcedures VARCHAR(4000) NULL
)

--Adding Adverse Events to table variable
INSERT INTO @tableAdverseEvents
(
    ProcedureId,
    AdverseProcedures
)
SELECT 
	ProcedureId = pae.ProcedureId,
	AdverseProcedures = ae.NEDTerm
FROM
	dbo.ERS_ProcedureAdverseEvents AS pae
	INNER JOIN dbo.ERS_AdverseEvents AS ae ON ae.UniqueId = pae.AdverseEventId

SELECT DISTINCT --p.ProcedureId 
		pat.Forename1 AS Forename
		, pat.Surname AS Surname
		, dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) AS 'NHS number'
		, pat.HospitalNumber AS 'Case note number'
		, pat.DateOfBirth AS DOB
		, oh.HospitalName AS 'Operating hospital'
		, gt.Title AS Sex
		, pat.Postcode AS 'Patients postcode'
		, pt.ProcedureType AS 'Procedure name'
		, p.CreatedOn AS 'Procedure start time'
		, CASE WHEN thera.procedureId is null THEN 'Diagnostic' ELSE 'Therapeutic' END AS 'Therapeutic or diagnostic'
		, dbo.fnGetAgeAtDate(pat.DateOfBirth, p.CreatedOn) AS 'Age at procedure'
		, CASE WHEN p.PatientStatus = (SELECT ListItemNo FROM ERS_Lists WHERE ListDescription = 'Patient Status' AND ListItemText = 'Inpatient') THEN 1 ELSE null END AS 'In patient'
		, CASE WHEN p.PatientStatus = (SELECT ListItemNo FROM ERS_Lists WHERE ListDescription = 'Patient Status' AND ListItemText = 'Outpatient') THEN 1 ELSE null END AS 'Out patient'
		, CASE WHEN p.PatientStatus = (SELECT ListItemNo FROM ERS_Lists WHERE ListDescription = 'Patient Status' AND ListItemText = 'Day Patient') THEN 1 ELSE null END AS 'Day patient'
		, CASE WHEN p.PatientType = (SELECT ListItemNo FROM ERS_Lists WHERE ListDescription = 'Patient Type' AND ListItemText = 'NHS') THEN 1 ELSE null END AS 'NHS'
		, CASE WHEN p.PatientType = (SELECT ListItemNo FROM ERS_Lists WHERE ListDescription = 'Patient Type' AND ListItemText = 'Private') THEN 1 ELSE null END AS 'Private'
		, ListCons.Surname + ', ' + ListCons.Forename AS 'List consultant'
		, Endo1.Surname + ', ' + Endo1.Forename AS 'Endoscopist 1'
		, Endo2.Surname + ', ' + Endo2.Forename AS 'Endoscopist 2'
		, pr.PP_Indic AS Indications
		, pas.ASAStatusId AS 'ASA status'
		, CASE fu.EvidenceOfCancerIdentified WHEN 1 THEN 'Yes' 
											 WHEN 2 THEN 'No'
											 WHEN 3 THEN 'Unknown'
											 ELSE '' END AS 'Evidence of cancer'
		, DrugList AS Drugs
		, d.SessileExcised AS 'Sessile polyps excised'
		, d.SessileToLabs AS 'Sessile polyps sent to lab'
		, d.PedunculatedExcised AS 'Pedunculated polyps excised'
		, d.PedunculatedToLabs AS 'Pedunculated polyps sent to lab'
		, d.SubmucosalExcised AS 'Submucosal polyps excised'
		, d.SubmucosalToLabs AS 'Submucosal polyps sent to lab'
		, d.PseudopolypsExcised AS 'Pseudo polyps excised'
		, d.PseudopolypsToLabs AS 'Pseudo polyps sent to lab'
		, d.BiopsyQtyHistology AS 'Bx to histology'
		, CASE WHEN ISNULL(CEOI.NED_TimeToCaecumMin, 0) = 0 
			THEN CASE WHEN ISNULL(CEOI.TimeToCaecumMin, 0) = 0 
				THEN CASE WHEN ISNULL(CEOI.TimeToCaecumMin_Photo, 0) = 0 
					THEN 0
					ELSE CEOI.TimeToCaecumMin_Photo + CASE WHEN ISNULL(CEOI.TimeToCaecumSec_Photo, 0) >= 30 THEN 1 ELSE 0 END
					END
				ELSE 	CEOI.TimeToCaecumMin + CASE WHEN ISNULL(CEOI.TimeToCaecumSec, 0) >= 30 THEN 1 ELSE 0 END
				END
			ELSE	CEOI.NED_TimeToCaecumMin + CASE WHEN ISNULL(CEOI.NED_TimeToCaecumSec, 0) >= 30 THEN 1 ELSE 0 END
		   END AS 'Time to caecum (lower only)'		
		 , CASE WHEN ISNULL(CEOI.NED_TimeForWithdrawalMin, 0) = 0 
			THEN CASE WHEN ISNULL(CEOI.TimeForWithdrawalMin, 0) = 0 
				THEN CASE WHEN ISNULL(CEOI.TimeForWithdrawalMin_Photo, 0) = 0 
					THEN 0
					ELSE CEOI.TimeForWithdrawalMin_Photo + CASE WHEN ISNULL(CEOI.TimeForWithdrawalSec_Photo, 0) >= 30 THEN 1 ELSE 0 END
					END
				ELSE 	CEOI.TimeForWithdrawalMin + CASE WHEN ISNULL(CEOI.TimeForWithdrawalSec, 0) >= 30 THEN 1 ELSE 0 END
				END
			ELSE	CEOI.NED_TimeForWithdrawalMin + CASE WHEN ISNULL(CEOI.NED_TimeForWithdrawalSec, 0) >= 30 THEN 1 ELSE 0 END
		  END AS 'Time for withdrawal (lower only)'
	    , qa.PatDiscomfortEndo AS 'Endoscopists patient comfort score'
	    , qa.PatDiscomfortNurse AS 'Nurse patient comfort score'
	    , qa.PatDiscomfortPatient AS 'patients own comfort score'
		, CASE qa.PatSedation	WHEN 0 THEN 'Not completed' 
								WHEN 1 THEN 'Not recorded' 
								WHEN 2 THEN 'Awake' 
								WHEN 3 THEN 'Drowsy' 
								WHEN 4 THEN 'Asleep but responding to name' 
								WHEN 5 THEN 'Asleep but responding to touch' 
								WHEN 6 THEN 'Asleep but unresponsive' 
								ELSE 'Unknown' END AS 'Patient sedation'
		, '"'+pr.PP_AdviceAndComments+'"'  AS 'Advice and comments'
		, pr.PP_Followup AS 'Follow up'
		, pr.PP_Diagnoses AS Diagnoses
		, p.ProcedureId
		, AdvEv.ProcedureId
		, AdvEv.AdverseEventProcedures
		, Therap.TherapeuticProcedures
FROM ERS_Procedures p (NOLOCK)
JOIN ERS_ReportConsultants rc (NOLOCK) ON p.Endoscopist1 = rc.ConsultantID 
JOIN ERS_Patients pat (NOLOCK) ON p.PatientId = pat.PatientId 
JOIN ERS_OperatingHospitals (NOLOCK) oh ON p.OperatingHospitalID = oh.OperatingHospitalId 
LEFT OUTER JOIN ERS_GenderTypes (NOLOCK) gt ON pat.GenderId = gt.GenderId 
JOIN ERS_ProcedureTypes (NOLOCK) pt ON P.ProcedureType = pt.ProcedureTypeId 
LEFT OUTER JOIN (SELECT distinct s.ProcedureId 
			FROM ERS_Sites (NOLOCK) s  
			LEFT JOIN ERS_UpperGITherapeutics (NOLOCK) t ON s.siteId = t.SiteId
			LEFT JOIN ERS_ERCPTherapeutics (NOLOCK) ercpt ON s.siteId = ercpt.SiteId
			WHERE t.siteid is not null or ercpt.siteid is not null) thera ON p.ProcedureId = thera.ProcedureId
JOIN ERS_Users ListCons (NOLOCK) ON p.ListConsultant = ListCons.UserID
JOIN ERS_Users Endo1 (NOLOCK) ON p.Endoscopist1 = Endo1.UserID
LEFT OUTER JOIN ERS_Users Endo2 (NOLOCK) ON p.Endoscopist2 = Endo2.UserID
JOIN ERS_ProceduresReporting pr (NOLOCK) ON p.ProcedureId = pr.ProcedureId 
LEFT JOIN dbo.ERS_ProcedureIndications procInd (NOLOCK)
    ON p.ProcedureId = procInd.ProcedureId
LEFT JOIN dbo.ERS_PatientASAStatus AS pas (NOLOCK)
	ON pas.PatientId = p.PatientId
LEFT OUTER JOIN ERS_UpperGIFollowUp fu (NOLOCK) ON p.ProcedureId = fu.ProcedureId 
LEFT OUTER JOIN 
(
SELECT distinct d.ProcedureId, STUFF(( SELECT ', ' + drugconcat.DrugName + ' - ' + CONVERT(VARCHAR, drugconcat.Dose) + drugconcat.Units
                FROM ERS_UpperGIPremedication drugconcat
				WHERE drugconcat.ProcedureId = d.ProcedureId
              FOR
                XML PATH('')
              ), 1, 1, '') AS DrugList
FROM ERS_UpperGIPremedication d) Drugs ON Drugs.ProcedureId = p.ProcedureId
LEFT OUTER JOIN (SELECT s.ProcedureId 
					, SUM(CASE WHEN l.Polyp = 1 AND ap.PolypTypeId = @polypSessile AND ISNULL(ap.Excised, 0) = 1 THEN 1 ELSE 0 END) AS SessileExcised
					, SUM(CASE WHEN l.Polyp = 1 AND ap.PolypTypeId = @polypSessile AND ISNULL(ap.Labs, 0) = 1 THEN 1 ELSE 0 END) AS SessileToLabs
					, SUM(CASE WHEN l.Polyp = 1 AND ap.PolypTypeId = @polypPedunculated AND ISNULL(ap.Excised, 0) = 1 THEN 1 ELSE 0 END) AS PedunculatedExcised
					, SUM(CASE WHEN l.Polyp = 1 AND ap.PolypTypeId = @polypPedunculated AND ISNULL(ap.Labs, 0) = 1 THEN 1 ELSE 0 END) AS PedunculatedToLabs
					, SUM(CASE WHEN l.Polyp = 1 AND ap.PolypTypeId = @polypSubmucosal AND ISNULL(ap.Excised, 0) = 1 THEN 1 ELSE 0 END) AS SubmucosalExcised
					, SUM(CASE WHEN l.Polyp = 1 AND ap.PolypTypeId = @polypSubmucosal AND ISNULL(ap.Labs, 0) = 1 THEN 1 ELSE 0 END) AS SubmucosalToLabs
					, SUM(CASE WHEN l.Polyp = 1 AND ap.PolypTypeId = @polypPseudo AND ISNULL(ap.Excised, 0) = 1 THEN 1 ELSE 0 END) AS PseudopolypsExcised
					, SUM(CASE WHEN l.Polyp = 1 AND ap.PolypTypeId = @polypPseudo AND ISNULL(ap.Labs, 0) = 1 THEN 1 ELSE 0 END) AS PseudopolypsToLabs
					, ISNULL(MAX(CONVERT(int, sp.BrushCytology)), 0) AS BrushCytology
					, ISNULL(SUM(sp.BiopsyQtyHistology), 0) AS BiopsyQtyHistology
					, ISNULL(SUM(sp.BiopsyQtyMicrobiology), 0) AS BiopsyQtyMicrobiology
					, ISNULL(SUM(sp.BiopsyQtyVirology), 0) AS BiopsyQtyVirology
					, ISNULL(MAX(CONVERT(int, sp.HotBiopsy)), 0) AS HotBiopsy
				FROM ERS_Sites AS s (NOLOCK)
				--LEFT OUTER JOIN ERS_ColonAbnoLesions l (NOLOCK) ON s.SiteId = l.SiteId 
				LEFT JOIN dbo.ERS_CommonAbnoLesions (NOLOCK) AS l ON s.SiteId = l.SiteId
				--LEFT OUTER JOIN ERS_UpperGIAbnoPolyps ap (NOLOCK) ON s.SiteId = ap.SiteId 
				LEFT JOIN dbo.ERS_CommonAbnoPolypDetails (NOLOCK) AS ap ON s.SiteId = ap.SiteId
				LEFT JOIN dbo.ERS_PolypTypes AS ept ON ept.UniqueId = ap.PolypTypeId
				LEFT OUTER JOIN ERS_UpperGISpecimens sp (NOLOCK) ON s.SiteId = sp.SiteId 
				Group by s.ProcedureId ) d ON p.ProcedureId = d.ProcedureId 
LEFT OUTER JOIN ERS_ColonExtentOfIntubation CEOI (NOLOCK) ON p.ProcedureId = CEOI.ProcedureId 
LEFT OUTER JOIN ERS_UpperGIQA (NOLOCK) qa ON p.ProcedureId = qa.ProcedureId 
LEFT OUTER JOIN (
		SELECT DISTINCT 
			ae.ProcedureId, STUFF((SELECT ', ' + tae.AdverseProcedures
			FROM @tableAdverseEvents AS tae	
			WHERE tae.ProcedureId = ae.ProcedureId
			FOR
			XML PATH('')
			), 1, 1, '') AS AdverseEventProcedures
		FROM @tableAdverseEvents ae) AS AdvEv ON AdvEv.ProcedureId = p.ProcedureId		
LEFT OUTER JOIN  
(
SELECT distinct d.ProcedureId, STUFF(( SELECT '; ' + therapconcat.TherapeuticProcedures
                FROM @tableVarTherapeutics therapconcat
				WHERE therapconcat.ProcedureId = d.ProcedureId
              FOR
                XML PATH('')
              ), 1, 1, '') AS TherapeuticProcedures
FROM @tableVarTherapeutics d) Therap ON Therap.ProcedureId = p.ProcedureId
WHERE p.ProcedureCompleted = 1
	AND p.IsActive = 1
	AND p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	AND rc.UserID = @UserId
	AND pat.PatientId in (SELECT patientId FROM ERS_PatientTrusts WHERE TrustId = @TrustId)	
		AND ISNULL(p.DNA,0) = 0
	AND ISNULL(p.Transnasal, 0) = 1
	AND P.ProcedureType = 1 --OGD
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --added by mostafiz 5/21/24 Filter by Hospital TFS1811
ORDER BY pt.ProcedureType, p.CreatedOn 

END

GO
 update ERS_AuditReports set AuditReportDescription= 'GRS C Sigmoidoscopy Detail Failure'
	 where  AuditReportDescription='GRS Sigmoidoscopy detail failure'
GO
EXEC dbo.DropIfExist @ObjectName = 'auditSigmoidDetailedFailure',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditSigmoidDetailedFailure]
@UserId INT
AS
--/***************************************************************************************/
---- Author				:		Mahfuz created on 2 Feb 2022 - New Report TFS 1888
---- Update History		:		10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures
----						:		11 May 2022 SG added Health Service Number formatting
--						:		21 May 2024		Mostafiz TFS1811: Filter by Operating Hospital 
--/**************************************************************************************/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@OperatingHospitalList as varchar(100),  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
			@HealthService as varchar(max)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	Select  pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			dbo.fn_FormatHealthServiceNumber(pat.NHSNo, @HealthService) as 'NHSNo', 
			dbo.fnGender(pat.GenderId) as Gender, 
			convert(varchar, p.CreatedOn, 106) as ProcedureDate,
			(CONVERT(int,CONVERT(char(8),p.CreatedOn,112))-CONVERT(char(8),pat.DateOfBirth,112))/10000 as 'Age at Procedure',
			CASE WHEN p.ProcedureType = 3 THEN 'Colonoscopy' ELSE 'Sigmoidoscopy' END as 'Procedure Type',
			u.Surname + ', '+ u.Forename as 'Endoscopist 1',
			u2.Surname + ', '+ u2.Forename as 'Endoscopist 2',
			lim.NEDTerm as 'Insertion Limited By',
			CASE 
				WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 1 THEN 'Abandoned & Intubation failed'
				ELSE 
				CASE 
					WHEN ext.Abandoned = 1 AND ext.IntubationFailed = 0 THEN 'Abandoned' 
					ELSE 
					CASE 
						WHEN ext.Abandoned = 0 AND ext.IntubationFailed = 1 THEN 'Intubation failed'
						ELSE ''
					END
				END
			END AS 'Failure Reason'
	FROM ERS_Procedures p (NOLOCK)
	join ERS_Users u (NOLOCK) on u.UserID = p.Endoscopist1
	left join ERS_Users u2 (NOLOCK) on u2.UserID = p.Endoscopist2
	join ERS_Patients pat (NOLOCK) on pat.PatientId = p.PatientId
	join ERS_ReportConsultants rc (NOLOCK) on u.UserID = rc.ConsultantID
	join dbo.ERS_ProcedureLowerExtent ext (NOLOCK) on p.ProcedureId = ext.ProcedureId
	LEFT JOIN dbo.ERS_Limitations AS lim (NOLOCK) ON lim.UniqueId = ext.LimitationId
	where p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.ProcedureType = 4 --in (3, 4) MH changed on 2 Feb 2022
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and (ISNULL(lim.NEDTerm, '') != '' or ISNULL(lim.[Description], '') != '')
	--and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)	 --omited by mostafiz 5/21/24 Filter by Hospital TFS1811
	AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )  --added by mostafiz 5/21/24 Filter by Hospital TFS1811
	and IsNull(p.DNA,0) = 0
	AND (ext.Abandoned <> 0 OR ext.IntubationFailed <> 0)
	Order By p.CreatedOn
END

GO

------------------------------------------------------------------------------------------------------------------------
--added by mostafiz in this file
------------------------------------------------------------------------------------------------------------------------


GO
IF NOT EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'ERS_Procedures' AND COLUMN_NAME ='ImagesTaken'
)

BEGIN
ALTER TABLE ERS_Procedures ADD ImagesTaken INT NULL
END


GO
EXEC dbo.DropIfExist @ObjectName = 'addImageCount',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[addImageCount]
	@imageCount int,
	@ProcedureId int
AS
BEGIN

DECLARE @ImageCnt int

SELECT @ImageCnt = ImagesTaken FROM ERS_Procedures WHERE ProcedureId = @ProcedureID;
 UPDATE ERS_Procedures SET ImagesTaken = CASE when @ImageCnt <> 0 then  ImagesTaken + @imageCount ELSE @imageCount END WHERE ProcedureId = @ProcedureID;
END

GO
EXEC dbo.DropIfExist @ObjectName = 'auditImage',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

Create Procedure [dbo].[auditImage]
	@UserId int
AS
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)
	SELECT	@FromDate = FromDate,
			@ToDate = ToDate, 
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	WHERE	UserID = @UserId

	 SELECT
	 Convert(varchar,ModifiedOn,106) as 'Procedure Date',
	 procType.ProcedureType  AS 'Type',
	 ISNULL((SELECT patient.Surname + ' ' +  patient.Forename1 + ' ' + patient.Forename2 ),'') AS 'Patient Name',
	 list.ListDescription   AS 'Category' , 
	 patient.NHSNo AS 'NHS Number',
	 STUFF((SELECT DISTINCT ',' + HospitalNumber from ERS_PatientTrusts WHERE PatientId = proce.PatientId and IsMinor = 0 for xml path('')), 1, 1, '')
	 AS 'Hospital Number',
	 (u.Title + ' ' + u.Forename+ ' ' +u.Surname) AS Endoscopist,

     CASE WHEN  proce.ProcedureType = 10 THEN 'boipsy :'+   (SELECT  cast(
	  sum(ISNULL(EndobronchialTB, 0)+
	  ISNULL(EndobronchialHistology, 0)+
      ISNULL(EndobronchialBacteriology, 0)+
      ISNULL(EndobronchialVirology, 0)+
      ISNULL(EndobronchialMycology, 0)+
      ISNULL(BrushCytology, 0) +
      ISNULL(BrushBacteriology, 0) +
      ISNULL(BrushVirology, 0) +
      ISNULL(BrushMycology, 0) +
      ISNULL(DistalBlindTB, 0)+
      ISNULL(DistalBlindHistology, 0)+
      ISNULL(DistalBlindBacteriology, 0)+
      ISNULL(DistalBlindVirology, 0)+
      ISNULL(DistalBlindMycology, 0)+
      ISNULL(TransbronchialTB, 0)+ 
      ISNULL(TransbronchialHistology, 0)+
      ISNULL(TransbronchialBacteriology, 0)+
      ISNULL(TransbronchialVirology, 0)+
      ISNULL(TransbronchialMycology, 0)+
      ISNULL(TranstrachealHistology, 0)+
      ISNULL(TranstrachealBacteriology, 0)+
      ISNULL(TranstrachealVirology, 0)+
      ISNULL(TranstrachealMycology, 0)) AS VARCHAR(10))  FROM ERS_BRTSpecimens brons  JOIN [ERS_Sites] si ON brons.SiteId = si.SiteId  
     WHERE si.ProcedureId = proce.ProcedureId) ELSE
	  ( SELECT 
     CASE 
        WHEN SUM(ISNULL(BiopsyQtyHistology, 0) + ISNULL(BiopsyQtyMicrobiology, 0) + ISNULL(BiopsyQtyVirology, 0)) > 0 
		THEN 'biopsy :'  + CAST(SUM(ISNULL(BiopsyQtyHistology, 0) + ISNULL(BiopsyQtyMicrobiology, 0) + ISNULL(BiopsyQtyVirology, 0)) 
		AS VARCHAR(10))
        ELSE '' 
     END + 
     CASE 
        WHEN SUM(ISNULL(PolypectomyQty, 0)) > 0 THEN 
            CASE 
                WHEN SUM(ISNULL(BiopsyQtyHistology, 0) + ISNULL(BiopsyQtyMicrobiology, 0) + ISNULL(BiopsyQtyVirology, 0)) > 0 
				THEN ', polyp ' + CAST(SUM(ISNULL(PolypectomyQty, 0)) AS VARCHAR(10))
                ELSE 'polyp: ' + CAST(SUM(ISNULL(PolypectomyQty, 0)) AS VARCHAR(10))
            END
        ELSE '' 
     END 
     FROM [ERS_UpperGISpecimens] Gi 
     JOIN [ERS_Sites] si ON Gi.SiteId = si.SiteId  
     WHERE si.ProcedureId = proce.ProcedureId)
	 END AS 'Biopsy Taken' ,

	 CASE WHEN  proce.ImagesTaken IS NULL THEN  (SELECT count(*) FROM ERS_Photos WHERE ProcedureId = proce.ProcedureId) ELSE
	 proce.ImagesTaken END AS 'Image within Procedure' ,
	 	 (SELECT count(*) FROM  ERS_Photos WHERE ProcedureId = proce.ProcedureId) AS 'Images within Report'
	 
	 FROM  ERS_Procedures proce 
	 JOIN ERS_ProcedureTypes  procType ON proce.ProcedureType = procType.ProcedureTypeId
	 JOIN ERS_Lists list  ON proce.CategoryListId = list.ListId
	 JOIN ERS_Users u ON proce.Endoscopist1 = u.UserID
	 JOIN ERS_Patients patient ON patient.PatientId = proce.PatientId
	 JOIN ERS_ReportConsultants reportCon ON u.UserID = reportCon.ConsultantID 
	 WHERE proce.ProcedureCompleted = 1 AND ISNULL(DNA, 0) = 0 AND proce.IsActive= 1
	 AND proce.CreatedOn >= @FromDate AND proce.CreatedOn <= @ToDate
	 AND proce.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
	 AND reportCon.UserID = @UserId
	 ORDER BY proce.CreatedOn
END

GO
if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='auditImage')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Audit Image', 'auditImage')
GO


------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	3048
-- Description of change
-- Non scheduling DNA / Cancelled Reports Audit Report 
------------------------------------------------------------------------------------------------------------------------
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ERS_AuditReports WHERE AuditReportStoredProcedure = 'auditDNACancelledProcedures' AND AuditReportDescription = 'DNA/Cancelled procedures')
BEGIN
	INSERT INTO ERS_AuditReports(AuditReportDescription, AuditReportStoredProcedure)
	VALUES ('DNA/Cancelled procedures','auditDNACancelledProcedures')
END
GO


SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

EXEC dbo.DropIfExist @ObjectName = 'auditDNACancelledProcedures',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO


CREATE PROCEDURE [dbo].[auditDNACancelledProcedures] 
	@UserID INT 
AS
BEGIN
SELECT 
	tbl.Endoscopist1,
	tbl.ProcedureType [Procedure type],
	SUM(tbl.NoOfProcedures) [No of procedures],
	SUM(tbl.DNA) [DNA],
	SUM(tbl.Cancelled) [Cancelled]
FROM 
	(SELECT
		C.ConsultantName AS Consultant,
		RC.AnonimizedID,
		C.ConsultantName AS Endoscopist1,
		RC.ConsultantId AS ReportID,
		COUNT(p.ProcedureId) NoOfProcedures,
		CASE WHEN p.DNA = 1 THEN COUNT(p.ProcedureId) ELSE 0 END DNA,
		CASE WHEN p.DNA > 1 THEN COUNT(p.ProcedureId) ELSE 0 END Cancelled,
		Pt.ProcedureType
	FROM dbo.ERS_Procedures p
		INNER JOIN dbo.ERS_ProcedureTypes pt ON p.ProcedureType = pt.ProcedureTypeId
		INNER JOIN fw_ReportConsultants RC ON (('E.' + CONVERT(varchar(10), p.Endoscopist2) = RC.ConsultantId AND p.Endo2Role IN (2, 3)) or 'E.' + CONVERT(varchar(10), p.Endoscopist1) = RC.ConsultantId)
		INNER JOIN fw_Consultants C ON c.ConsultantId = RC.ConsultantId
		INNER JOIN fw_ReportFilter RF ON RF.UserID = RC.UserID
	WHERE p.DNA IS NOT NULL AND (RF.UserID = @UserID
and P.IsActive = 1 and p.ProcedureCompleted = 1
AND P.CreatedOn >= RF.FromDate AND P.CreatedOn <= RF.ToDate)
AND p.OperatingHospitalID IN (SELECT * FROM dbo.splitString(RF.OperatingHospitalList,',') )
	GROUP BY pt.ProcedureType, p.DNA, p.Endoscopist1,p.Endoscopist2,
		p.Endo2Role, C.ConsultantName, RC.AnonimizedID
			, C.ConsultantName 
			, RC.ConsultantId) tbl
	
GROUP BY ProcedureType, AnonimizedID, Endoscopist1, ReportID, Consultant
ORDER BY Endoscopist1
END
GO


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO


------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	2101
-- Description of change
-- Followup procedures report into v2 format 
------------------------------------------------------------------------------------------------------------------------
GO

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER Procedure [dbo].[auditFollowUpRepeatProcedures]
	@UserId int
AS
/*
	Update History		:
	01	:	07 Mar 2022			Mahfuz added additional two extra columns of Due in Weeks and Due Date 
													(Please ignore ugly text scanning code. It can be improved later when system will save numbers of days,weeks etc instead of free text)
	02	:	10 Mar 2022 MH added filter to eliminate Cancelled/DNA procedures

	03	:	29 Mar 2022 MH added Operating Hospital
	04  :	11 May 2022 SG added Health Service Number formatting
	05  :	15 May 2024 AJ transformed into V2 format

--	
*/
BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	SELECT @HealthService = CustomText FROM ERS_Custom_Text WHERE CustomTextId = 'CountryOfOriginHealthService'

	declare @ProceduresWithFollowUp as Table
	(
	AutoRowID int identity(1,1),
	PatientId int,
	ProcedureId int,
	ModifiedOn datetime,
	CreatedOn datetime,
	InTimeWord varchar(10),
	InTimeDaysNumber integer,
	FurtherProcedureText varchar(max)
	)

	declare @ProceduresAfterFollowUp as table
	(
	AutoRowID int identity(1,1),
	PatientId int,
	ProcedureId int,
	ModifiedOn datetime
	)

	Insert into @ProceduresWithFollowUp(PatientId,ProcedureId,ModifiedOn,CreatedOn,FurtherProcedureText)
	Select pr.PatientId,pr.ProcedureID,Pr.ModifiedOn,Pr.CreatedOn,ugfu.FurtherProcedureText from ERS_Procedures pr 
	inner join ERS_UpperGIFollowUp ugfu on pr.ProcedureId = ugfu.ProcedureId
	join ERS_ReportConsultants rc on (pr.Endoscopist1 = rc.ConsultantID OR pr.Endoscopist2 = rc.ConsultantID)
	Where IsNull(ugfu.FurtherProcedureText,'') <> '' --and pr.CreatedOn >= @FromDate AND pr.CreatedOn <= @ToDate
	--MH added on 10 Mar 2022
	and IsNull(pr.DNA,0) = 0
	--and pr.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') )
	and rc.UserID = @UserId

		Begin Try
			Update @ProceduresWithFollowUp
				Set InTimeWord = 'D',
					InTimeDaysNumber = Cast(ltrim(rtrim(Substring(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1,charindex ('day',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1)))),(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1,charindex ('day',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1,charindex ('day',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1))))))+1),(Len(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1,charindex ('day',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1)))))-(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1,charindex ('day',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1,charindex ('day',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('day',FurtherProcedureText,0))))+1))))))))))) as Integer) * 1

				Where FurtherProcedureText like '%day%' and IsNull(InTimeWord,'') = ''
		End Try
		Begin Catch
		End Catch
	Begin Try
		Update @ProceduresWithFollowUp
			Set InTimeWord = 'W',
				InTimeDaysNumber = Cast(ltrim(rtrim(Substring(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1,charindex ('week',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1)))),(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1,charindex ('week',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1,charindex ('week',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1))))))+1),(Len(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1,charindex ('week',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1)))))-(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1,charindex ('week',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1,charindex ('week',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('week',FurtherProcedureText,0))))+1))))))))))) as Integer) * 7	
			Where FurtherProcedureText like '%week%' and IsNull(InTimeWord,'') = ''
		End Try
		Begin Catch
		End Catch

	Begin Try
		Update @ProceduresWithFollowUp
			Set InTimeWord = 'M',
				InTimeDaysNumber = Cast(ltrim(rtrim(Substring(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1,charindex ('month',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1)))),(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1,charindex ('month',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1,charindex ('month',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1))))))+1),(Len(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1,charindex ('month',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1)))))-(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1,charindex ('month',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1,charindex ('month',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('month',FurtherProcedureText,0))))+1))))))))))) as Integer) * 30
		
			Where FurtherProcedureText like '%month%' and IsNull(InTimeWord,'') = ''
	End Try
	Begin Catch
	End Catch

	Begin Try

	Update @ProceduresWithFollowUp
		Set InTimeWord = 'Y',
			InTimeDaysNumber = Cast(ltrim(rtrim(Substring(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1,charindex ('year',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1)))),(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1,charindex ('year',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1,charindex ('year',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1))))))+1),(Len(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1,charindex ('year',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1)))))-(LEN(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1,charindex ('year',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1))))) - CHARINDEX(' ',REVERSE(Ltrim(Rtrim(Substring(FurtherProcedureText,charindex(' ',rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1,charindex ('year',FurtherProcedureText,0)-(charindex(' ',Rtrim(substring(FurtherProcedureText,0,charindex ('year',FurtherProcedureText,0))))+1))))))))))) as Integer) * 365
		
		Where FurtherProcedureText like '%year%' and IsNull(InTimeWord,'') = ''

	End Try
	Begin Catch
	End Catch

	Insert into @ProceduresAfterFollowUp(PatientId,ProcedureId,ModifiedOn)
	Select Distinct pr.PatientId,pr.ProcedureID,Pr.ModifiedOn
	from ERS_Procedures pr 
	left join @ProceduresWithFollowUp pfu on pr.Patientid = pfu.PatientId --and pr.ModifiedOn < pfu.ModifiedOn
	join ERS_ReportConsultants rc on (pr.Endoscopist1 = rc.ConsultantID OR pr.Endoscopist2 = rc.ConsultantID)
	Where pr.ModifiedOn > pfu.ModifiedOn
	and pr.PatientId in (Select PatientID from @ProceduresWithFollowUp)
	--MH added on 10 Mar 2022
	and IsNull(pr.DNA,0) = 0
	--and pr.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)
	AND pr.OperatingHospitalID IN (SELECT * FROM dbo.splitString(@OperatingHospitalList,',') ) --TFS2811
	and rc.UserID = @UserId


	Select 
	Oh.HospitalName as OperatingHospital
	,p.Forename1 + ' ' + p.Surname as PatientName
	,dbo.fnGender(p.GenderId) as Gender
	,Format(p.DateOfBirth,'dd MMM yyyy') as DateOfBirth
	,dbo.fn_FormatHealthServiceNumber(p.NHSNo, @HealthService) as 'NHSNo'
	,p.HospitalNumber
	,pt.ProcedureType
	,Format(pr.ModifiedOn,'dd MMM yyyy hh:mm tt') as ProcedureDate
	,PS.ListItemText as PatientStatus
	,ISNULL(PatT.[Description], PatT1.ListItemText) as PatientType
	,ISNULL(lic.[Description], REPLACE(lic1.ListItemText, '[NED]','')) as PatientPathway
	,ugfu.FurtherProcedureText as FollowUpProcedure
	,E1.Forename + ' ' + E1.Surname as RequestedByEndoscopist1
	,Format((fup.InTimeDaysNumber / 7.00),'##.##') DueInWeeks
	,Format(DateAdd(Day,fup.InTimeDaysNumber,pr.CreatedOn),'dd MMM yyyy') DueOn

	from @ProceduresWithFollowUp fup
	INNER JOIN ERS_Procedures pr ON fup.ProcedureId = pr.ProcedureId
	inner join ERS_Patients p on pr.PatientID = p.PatientID
	inner join ERS_ProcedureTypes pt on pr.ProcedureType=pt.ProcedureTypeId
	inner join ERS_OperatingHospitals OH on pr.OperatingHospitalID = OH.OperatingHospitalId
	inner join (Select ListItemNo,ListItemText from ERS_Lists where ListDescription = 'Patient Status') PS on pr.PatientStatus = ps.ListItemNo
	left join (Select ListItemNo,ListItemText from ERS_Lists where ListDescription = 'Patient Type') PatT1 on pr.PatientType = PatT1.ListItemNo
	left join (Select ListItemNo,ListItemText from ERS_Lists where ListDescription = 'Procedure Category') lic1 on pr.CategoryListId = lic1.ListItemNo
	inner join ERS_ProviderSectors PatT on pr.PatientType = patt.UniqueId
	left join ERS_UpperGIFollowUp ugfu on pr.ProcedureId = ugfu.ProcedureId
	--left join @ProceduresWithFollowUp fup on pr.ProcedureId = fup.ProcedureId
	left join @ProceduresAfterFollowUp afup on pr.ProcedureId = afup.ProcedureId
	Left join ERS_Users E1 on pr.Endoscopist1 = E1.UserID
	left join dbo.ERS_UrgencyTypes lic on pr.CategoryListId = lic.UniqueId
	--Where IsNull(ugfu.FurtherProcedureText,'') <> '' or fup.ModifiedOn > pr.ModifiedOn
	Where fup.ProcedureId is not null or afup.ProcedureId is not null
	--MH added on 10 Mar 2022
		and IsNull(pr.DNA,0) = 0
	Order by p.Forename1 + ' ' + p.Surname,pr.ModifiedOn asc
END
GO


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	2651/2820
-- Description of change
-- Additional report to show staff booking from scheduler (Time & motion) option for a weekly and daily - how many bookings each staff member has made
------------------------------------------------------------------------------------------------------------------------
GO




IF NOT EXISTS (SELECT 1 FROM dbo.ERS_AuditReports WHERE AuditReportDescription = 'Number of Appointment Bookings by Day' AND AuditReportStoredProcedure='auditNumberOfBookingsByDay')
BEGIN
    INSERT INTO ERS_AuditReports(AuditReportDescription, AuditReportStoredProcedure)
	VALUES ('Number of Appointment Bookings by Day','auditNumberOfBookingsByDay') 
END
GO


SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

EXEC dbo.DropIfExist @ObjectName = 'auditNumberOfBookingsByDay',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[auditNumberOfBookingsByDay]
    @UserId AS INT
AS

BEGIN

	DECLARE @FromDate AS DATE;
	DECLARE @ToDate AS DATE;
	DECLARE @TrustId AS INT;

	SELECT
		@FromDate = FromDate,
		@ToDate = ToDate,
		@TrustId = TrustId
	FROM
		dbo.ERS_ReportFilter
	WHERE
		UserID = @UserId		

	SELECT 
		FORMAT(ea.DateRaised, 'ddd') AS [Day Of Week], COUNT(eu.UserID) AS [No. Of Bookings], eu.Surname, eu.Forename, eu.Title  
	FROM
		dbo.ERS_Appointments AS ea
		INNER JOIN dbo.ERS_Users AS eu
			ON eu.UserID = ea.StaffBookedId
	WHERE
		ea.DateRaised BETWEEN @FromDate AND @ToDate			
		AND EXISTS (SELECT PatientId FROM dbo.ERS_PatientTrusts WHERE TrustId = @TrustId)
	GROUP BY 
		ea.DateRaised, eu.Surname, eu.Forename, eu.Title
	ORDER BY
		ea.DateRaised, LTRIM(eu.Surname), LTRIM(eu.Forename)
    
END

GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	2651/2820
-- Description of change
-- Additional report to show staff booking from scheduler (Time & motion) option for a weekly and daily - how many bookings each staff member has made
------------------------------------------------------------------------------------------------------------------------
GO


IF NOT EXISTS (SELECT 1 FROM dbo.ERS_AuditReports WHERE AuditReportDescription = 'Number of Appointment Bookings' AND AuditReportStoredProcedure='auditNumberOfBookings')
BEGIN
    INSERT INTO ERS_AuditReports(AuditReportDescription, AuditReportStoredProcedure)
	VALUES ('Number of Appointment Bookings','auditNumberOfBookings') 
END
GO


SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

EXEC dbo.DropIfExist @ObjectName = 'auditNumberOfBookings',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[auditNumberOfBookings]
    @UserId AS INT
AS

BEGIN

	DECLARE @FromDate AS DATE;
	DECLARE @ToDate AS DATE;
	DECLARE @TrustId AS INT;

	SELECT
		@FromDate = FromDate,
		@ToDate = ToDate,
		@TrustId = TrustId
	FROM
		dbo.ERS_ReportFilter
	WHERE
		UserID = @UserId		

	SELECT COUNT(eu.UserID) AS [No. Of Bookings], eu.Surname, eu.Forename, eu.Title  
	FROM
		dbo.ERS_Appointments AS ea
		INNER JOIN dbo.ERS_Users AS eu
			ON eu.UserID = ea.StaffBookedId
	WHERE
		ea.DateRaised BETWEEN @FromDate AND @ToDate			
		AND EXISTS (SELECT PatientId FROM dbo.ERS_PatientTrusts WHERE TrustId = @TrustId)
	GROUP BY 
		eu.Surname, eu.Forename, eu.Title
	ORDER BY
		LTRIM(eu.Surname), LTRIM(eu.Forename)
    
END

GO


------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO
EXEC dbo.DropIfExist @ObjectName = 'usp_rep_GetListPatientReport',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[usp_rep_GetListPatientReport]
(@UserId INT)
AS
/*
	Update History		:
	01	:	30 May 2024			Partha , Not  showing all the record for which do not have Indication so made Left join than simply join , TFS 4128 
*/
BEGIN
Declare @PatientType varchar(20),
		@PatientStatus varchar(20),
		@Therapeutic bit,
		@Indications bit,
		@FromDate as Date,
		@ToDate as Date,
		@OperatingHospitals varchar(20),
		@Anonymise bit,
		@DateOrder varchar(4),
			@TrustId as int


Select  @PatientStatus = convert(varchar, PatientStatus) ,
		@PatientType = convert(varchar, NHSStatus),
		@Therapeutic = IncludeTherapeutics,
		@Indications = IncludeIndications,
		@FromDate = FromDate,
		@ToDate = ToDate,
		@OperatingHospitals = OperatingHospitalList ,
		@DateOrder = DateOrder,
		@Anonymise = Anonymise,
		@TrustId = TrustId
from ERS_ReportFilter where UserID = @UserId

if @PatientStatus = '0' set @PatientStatus = '1, 2, 3'
if @PatientType = '0' set @PatientType = '1,2'

Select distinct UP.ProcedureId, UP.Therapies  
into #ProcedureTherapy
From 
(
Select
	S.ProcedureId  As ProcedureId,
				CASE WHEN UT.ArgonBeamDiathermy = 1 OR ER.ArgonBeamDiathermy = 1 THEN 3 END																AS ArgonBeamDiathermy, --## C/F/O
				CASE WHEN (UT.BalloonDilation = 1 OR ER.BalloonDilation = 1) THEN  4 END									AS BalloonDilation,		--## ALL: Balloon sphicteroplasty	
				CASE WHEN ER.BalloonTrawl = 1 THEN 5 END																	AS BalloonTrawl,
				CASE WHEN (UT.BandLigation = 1 OR UT.VaricealBanding = 1) THEN  6 END										AS BandLigation, 
				CASE WHEN UT.BandingPiles = 1 THEN 7 END																	AS BandingPiles,		--## O / C / F
				CASE WHEN UT.BicapElectro = 1 OR ER.BicapElectro = 1 THEN 7 END																	AS BicapElectrocautery,		--## O / C / F
				CASE WHEN UT.BotoxInjection	= 1 OR ER.BotoxInjection = 1 THEN  8 END																	AS BotoxInjection,
				CASE WHEN  ((UT.OesophagealDilatation=1 AND UT.DilatorType=2)
							OR (ER.BalloonTrawlDilatorType=2 or ER.DilatorType=2)) --## Need to confirm this Logic!
							THEN 9 END																						AS BougieDilation, --## O / E	
				CASE WHEN T.BrushCytology = 1 THEN 10 END												AS Brush,
				CASE WHEN ER.Cannulation = 1 THEN 11 END												AS Cannulation,
				CASE WHEN UT.Clip = 1 OR ER.Clip = 1 THEN 12 END											AS Clip,
				CASE WHEN ER.RendezvousProcedure = 1 THEN 13 END										AS RendezvousProcedure,
				CASE WHEN ER.DiagCholangiogram	= 1 THEN 14 END											AS DiagCholangiogram,
				CASE WHEN ER.DiagPancreatogram		= 1 THEN 15 END										AS DiagPancreatogram,
				CASE WHEN UT.Diathermy = 1 OR ER.Diathermy = 1 THEN 15 END													AS Diathermy,
				CASE WHEN UT.EndoClot = 1 THEN 15 END													AS EndoClot,
				CASE WHEN UT.EMR = 1 THEN 16 END															AS EMR,
				CASE WHEN UT.EndoloopPlacement = 1 OR ER.EndoloopPlacement = 1 THEN 17 END								AS EndoloopPlacement,
				CASE WHEN UT.ForeignBody = 1 OR ER.ForeignBody = 1 THEN 20 END									AS ForeignBody,
				CASE WHEN ER.Haemostasis = 1 THEN 21 END												AS Haemostasis,
				CASE WHEN UT.HeatProbe = 1 THEN 22 END													AS HeatProbe, 
				CASE WHEN (UT.HotBiopsy = 1 OR T.HotBiopsy = 1) THEN 23 END							AS HotBiopsy,
				CASE WHEN UT.Haemospray  = 1 THEN 22 END													AS Haemospray, 
				CASE WHEN UT.Injection = 1 OR ER.Injection = 1	THEN 24 END													AS Injection,
				CASE WHEN ER.Manometry = 1 THEN 25 END													AS Manometry,
				CASE WHEN UT.Marking = 1 THEN 26 END										AS Marking,
				CASE WHEN ER.Marking = 1 THEN 26 END 								AS AbnormalityMarked,
				CASE WHEN ER.NasopancreaticDrain = 1 THEN 27 END										AS NasopancreaticDrain,
				CASE WHEN UT.NGNJTubeInsertion = 1 or ER.GastrostomyInsertion = 1 THEN 26 END										AS NasojejunalTube,
				CASE WHEN ER.GastrostomyRemoval = 1 then 26 End									AS NasojejunalTubeRemoval,
				CASE WHEN UT.OesophagealDilatation = 1 THEN 26 END										AS OesophagealDilatation,
				CASE WHEN UT.pHProbeInsert = 1 THEN 26 END										AS pHProbeInsertion,
				CASE WHEN UT.PyloricDilatation = 1 OR ER.PyloricDilatation = 1 THEN 26 END										AS PyloricDuodenalDilation,
				CASE WHEN UT.GastrostomyInsertion = 1 AND UT.GastrostomyRemoval = 1 THEN 28 END		AS PEGChange,
				CASE WHEN UT.GastrostomyInsertion = 1 AND UT.GastrostomyRemoval = 0 THEN 29 END		AS PEGInsertion,
				CASE WHEN UT.GastrostomyInsertion = 0 AND UT.GastrostomyRemoval = 1 THEN 30 END		AS PEGRemoval,
		
				CASE WHEN UT.Polypectomy = 1 THEN 37 END												AS Polypectomy,			
				CASE WHEN UT.RFA = 1 THEN 38 END														AS RFA, 
				CASE WHEN (ER.PanOrificeSphincterotomy = 1 OR ER.Papillotomy = 1) THEN 39 END			AS Sphincterotomy,
				CASE WHEN ((UT.StentRemoval = 1 AND UT.StentInsertion = 1) OR
															  (ER.StentRemoval = 1 AND ER.StentInsertion = 1)) THEN 40 END  AS StentChange,
				CASE WHEN (UT.StentRemoval = 0 AND UT.StentInsertion = 1) OR
															  (ER.StentRemoval = 0 AND ER.StentInsertion = 1) THEN 41 END		AS StentPlacement,
				CASE WHEN ((UT.StentRemoval = 1 AND UT.StentInsertion = 0) OR
															  (ER.StentRemoval = 1 AND ER.StentInsertion = 0)) THEN 44 END	AS StentRemoval,
				CASE WHEN UT.Sigmoidopexy  = 1 THEN 37 END												AS Sigmoidopexy,		
				CASE WHEN ER.SnareExcision  = 1 THEN 25 END													AS SnareExcision,		
				CASE WHEN ER.StoneRemoval  = 1 THEN 25 END													AS StoneRemoval,		
				CASE WHEN ER.StrictureDilatation  = 1 THEN 25 END													AS StrictureDilatation,	
				CASE WHEN ER.EndoscopicCystPuncture   = 1 THEN 25 END													AS EndoscopicCystPuncture,	
				CASE WHEN UT.VaricealSclerotherapy = 1 THEN 47 END										AS VaricealSclerotherapy,
				CASE WHEN UT.YAGLaser = 1 or ER.YAGLaser = 1 THEN 48 END										AS YAGLaser

From dbo.ERS_Sites S 
	LEFT OUTER JOIN	dbo.ERS_UpperGITherapeutics UT ON S.SiteId = UT.SiteId 
	LEFT OUTER JOIN	[dbo].ERS_ERCPTherapeutics	AS ER ON S.SiteId = ER.SiteId
	LEFT JOIN				[dbo].ERS_Regions				AS  R ON S.RegionId = R.RegionId
	LEFT OUTER JOIN			[dbo].[ERS_ERCPAbnoDuct]		AS Abn ON S.SiteId = Abn.SiteId
	LEFT OUTER JOIN			[dbo].[ERS_UpperGISpecimens]	AS  T ON S.SiteId = T .SiteId
) As PT
UNPIVOT (
	TherapeuticID FOR Therapies IN (
									AbnormalityMarked,
									ArgonBeamDiathermy,
									BalloonDilation,
									BalloonTrawl,
									BandingPiles,
									BandLigation ,
									BicapElectrocautery,
									BotoxInjection,
									BougieDilation,
									Brush,
									Cannulation,
									Clip,
									DiagCholangiogram,
									DiagPancreatogram,
									Diathermy,
									EMR,
									EndoClot,
									EndoloopPlacement,
									EndoscopicCystPuncture,
									ForeignBody,
									Haemospray ,
									Haemostasis,
									HeatProbe ,
									HotBiopsy,
									Injection,
									Manometry,
									Marking,
									NasojejunalTube,
									NasojejunalTubeRemoval,
									NasopancreaticDrain,
									OesophagealDilatation,
									PEGChange,
									PEGInsertion,
									PEGRemoval,
									pHProbeInsertion,
									Polypectomy,
									PyloricDuodenalDilation,
									RendezvousProcedure,
									RFA ,
									Sigmoidopexy,
									SnareExcision,
									Sphincterotomy,
									StentChange,
									StentPlacement,
									StentRemoval,
									StoneRemoval,
									StrictureDilatation,
									VaricealSclerotherapy,
									YAGLaser
	)
) As UP

SELECT DISTINCT T2.ProcedureId, 
    SUBSTRING(
        (
            SELECT ', '+T1.Therapies  AS [text()]
            FROM #ProcedureTherapy T1
            WHERE T1.ProcedureId = T2.ProcedureId
            ORDER BY T1.ProcedureId
            FOR XML PATH ('')
        ), 3, 1000) Therapies
Into #TherapyList
FROM #ProcedureTherapy T2

Create Table #ProcedureList (
	Endoscopist varchar(80),
	ProcedureDate varchar(20),
	orderDate date,
	PatientName varchar(80),
	HospitalNumber varchar(20),
	Indications varchar(Max),
	Therapeutic varchar(max),
	ProcedureType varchar(20)
)

insert into #ProcedureList
Select  u.Surname + ', ' + u.Forename,
		convert(varchar, p.CreatedOn, 106),
		p.CreatedOn,
		pat.Surname + ', '+ pat.Forename1, 
		pat.HospitalNumber,
		ind.Summary,
		tl.Therapies,
		pt.ProcedureType
From	ERS_Procedures p
join	ERS_ProcedureTypes pt on p.ProcedureType = pt.ProcedureTypeId 
join	ERS_Users u on p.Endoscopist1 = u.UserId
join	ERS_Patients pat on p.PatientId = pat.PatientId
left join	ERS_UpperGIIndications ind on p.ProcedureId = ind.ProcedureId --add Left join instead of Join, TFS 4128
Left join #TherapyList tl on p.ProcedureId = tl.ProcedureId
join	ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
where	p.ProcedureCompleted = 1
	and p.IsActive = 1
	and p.PatientStatus in (Select Item from dbo.splitString(@PatientStatus, ','))
	and PatientType  in (Select Item from dbo.splitString(@PatientType, ','))
	and p.OperatingHospitalID in (Select Item from dbo.splitString(@OperatingHospitals, ','))
	and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
	and rc.UserID = @UserId
	and pat.PatientId in (Select patientId from ERS_PatientTrusts where TrustId = @TrustId)

If @Anonymise = 1
	Update #ProcedureList
	Set PatientName = 'Patient' + convert(varchar, DAY(DateOfBirth)) + convert(varchar, PatientId) + convert(varchar, MONTH(DateOfBirth)),
	HospitalNumber = 'XXXXXXXX'
	from ERS_Patients 
	where #ProcedureList.HospitalNumber = ERS_Patients.HospitalNumber 

DECLARE @sql NVARCHAR(MAX);
 
  SET @sql = 'Select	Endoscopist,
			ProcedureDate,
			PatientName,
			HospitalNumber, '
If @Indications = 1
	SET @sql = @sql + 'Indications, '
If @Therapeutic = 1
	SET @sql = @sql + 'Therapeutic, '

SET @sql = @sql + 'ProcedureType
	From	#ProcedureList
	Order By Endoscopist, orderDate ' + @DateOrder

EXEC sp_executesql @sql

drop table #ProcedureList
Drop table #TherapyList
Drop Table #ProcedureTherapy
END
GO



------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha
-- TFS#	3572
-- Description of change
-- Therapeutic Procedure Audit 
------------------------------------------------------------------------------------------------------------------------
GO



if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='auditTherapeuticProcedure')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Audit Therapeutic Procedure', 'auditTherapeuticProcedure')
GO
EXEC dbo.DropIfExist @ObjectName = 'auditTherapeuticProcedure',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE Procedure [dbo].[auditTherapeuticProcedure]
	@UserId int
AS

BEGIN
	DECLARE @FromDate as Date,
			@ToDate as Date,
			@TrustId as int,
			@HealthService as varchar(max),
			@OperatingHospitalList as varchar(100) 

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList  
	FROM	ERS_ReportFilter
	where	UserID = @UserId
	
	



	Select distinct UP.ProcedureId, UP.Therapies  
		into #ProcedureTherapy
		From 
		(
		Select
			S.ProcedureId  As ProcedureId,
						CASE WHEN UT.ArgonBeamDiathermy = 1 OR ER.ArgonBeamDiathermy = 1 THEN 3 END																AS ArgonBeamDiathermy, --## C/F/O
						CASE WHEN (UT.BalloonDilation = 1 OR ER.BalloonDilation = 1) THEN  4 END									AS BalloonDilation,		--## ALL: Balloon sphicteroplasty	
						CASE WHEN ER.BalloonTrawl = 1 THEN 5 END																	AS BalloonTrawl,
						CASE WHEN (UT.BandLigation = 1 OR UT.VaricealBanding = 1) THEN  6 END										AS BandLigation, 
						CASE WHEN UT.BandingPiles = 1 THEN 7 END																	AS BandingPiles,		--## O / C / F
						CASE WHEN UT.BicapElectro = 1 OR ER.BicapElectro = 1 THEN 7 END																	AS BicapElectrocautery,		--## O / C / F
						CASE WHEN UT.BotoxInjection	= 1 OR ER.BotoxInjection = 1 THEN  8 END																	AS BotoxInjection,
						CASE WHEN  ((UT.OesophagealDilatation=1 AND UT.DilatorType=2)
									OR (ER.BalloonTrawlDilatorType=2 or ER.DilatorType=2)) --## Need to confirm this Logic!
									THEN 9 END																						AS BougieDilation, --## O / E	
						CASE WHEN T.BrushCytology = 1 THEN 10 END												AS Brush,
						CASE WHEN ER.Cannulation = 1 THEN 11 END												AS Cannulation,
						CASE WHEN UT.Clip = 1 OR ER.Clip = 1 THEN 12 END											AS Clip,
						CASE WHEN ER.RendezvousProcedure = 1 THEN 13 END										AS RendezvousProcedure,
						CASE WHEN ER.DiagCholangiogram	= 1 THEN 14 END											AS DiagCholangiogram,
						CASE WHEN ER.DiagPancreatogram		= 1 THEN 15 END										AS DiagPancreatogram,
						CASE WHEN UT.Diathermy = 1 OR ER.Diathermy = 1 THEN 15 END													AS Diathermy,
						CASE WHEN UT.EndoClot = 1 THEN 15 END													AS EndoClot,
						CASE WHEN UT.EMR = 1 THEN 16 END															AS EMR,
						CASE WHEN UT.EndoloopPlacement = 1 OR ER.EndoloopPlacement = 1 THEN 17 END								AS EndoloopPlacement,
						CASE WHEN UT.ForeignBody = 1 OR ER.ForeignBody = 1 THEN 20 END									AS ForeignBody,
						CASE WHEN ER.Haemostasis = 1 THEN 21 END												AS Haemostasis,
						CASE WHEN UT.HeatProbe = 1 THEN 22 END													AS HeatProbe, 
						CASE WHEN (UT.HotBiopsy = 1 OR T.HotBiopsy = 1) THEN 23 END							AS HotBiopsy,
						CASE WHEN UT.Haemospray  = 1 THEN 22 END													AS Haemospray, 
						CASE WHEN UT.Injection = 1 OR ER.Injection = 1	THEN 24 END													AS Injection,
						CASE WHEN ER.Manometry = 1 THEN 25 END													AS Manometry,
						CASE WHEN UT.Marking = 1 THEN 26 END										AS Marking,
						CASE WHEN ER.Marking = 1 THEN 26 END 								AS AbnormalityMarked,
						CASE WHEN ER.NasopancreaticDrain = 1 THEN 27 END										AS NasopancreaticDrain,
						CASE WHEN UT.NGNJTubeInsertion = 1 or ER.GastrostomyInsertion = 1 THEN 26 END										AS NasojejunalTube,
						CASE WHEN ER.GastrostomyRemoval = 1 then 26 End									AS NasojejunalTubeRemoval,
						CASE WHEN UT.OesophagealDilatation = 1 THEN 26 END										AS OesophagealDilatation,
						CASE WHEN UT.pHProbeInsert = 1 THEN 26 END										AS pHProbeInsertion,
						CASE WHEN UT.PyloricDilatation = 1 OR ER.PyloricDilatation = 1 THEN 26 END										AS PyloricDuodenalDilation,
						CASE WHEN UT.GastrostomyInsertion = 1 AND UT.GastrostomyRemoval = 1 THEN 28 END		AS PEGChange,
						CASE WHEN UT.GastrostomyInsertion = 1 AND UT.GastrostomyRemoval = 0 THEN 29 END		AS PEGInsertion,
						CASE WHEN UT.GastrostomyInsertion = 0 AND UT.GastrostomyRemoval = 1 THEN 30 END		AS PEGRemoval,
		
						CASE WHEN UT.Polypectomy = 1 THEN 37 END												AS Polypectomy,			
						CASE WHEN UT.RFA = 1 THEN 38 END														AS RFA, 
						CASE WHEN (ER.PanOrificeSphincterotomy = 1 OR ER.Papillotomy = 1) THEN 39 END			AS Sphincterotomy,
						CASE WHEN ((UT.StentRemoval = 1 AND UT.StentInsertion = 1) OR
																	  (ER.StentRemoval = 1 AND ER.StentInsertion = 1)) THEN 40 END  AS StentChange,
						CASE WHEN (UT.StentRemoval = 0 AND UT.StentInsertion = 1) OR
																	  (ER.StentRemoval = 0 AND ER.StentInsertion = 1) THEN 41 END		AS StentPlacement,
						CASE WHEN ((UT.StentRemoval = 1 AND UT.StentInsertion = 0) OR
																	  (ER.StentRemoval = 1 AND ER.StentInsertion = 0)) THEN 44 END	AS StentRemoval,
						CASE WHEN UT.Sigmoidopexy  = 1 THEN 37 END												AS Sigmoidopexy,		
						CASE WHEN ER.SnareExcision  = 1 THEN 25 END													AS SnareExcision,		
						CASE WHEN ER.StoneRemoval  = 1 THEN 25 END													AS StoneRemoval,		
						CASE WHEN ER.StrictureDilatation  = 1 THEN 25 END													AS StrictureDilatation,	
						CASE WHEN ER.EndoscopicCystPuncture   = 1 THEN 25 END													AS EndoscopicCystPuncture,	
						CASE WHEN UT.VaricealSclerotherapy = 1 THEN 47 END										AS VaricealSclerotherapy,
						CASE WHEN UT.YAGLaser = 1 or ER.YAGLaser = 1 THEN 48 END										AS YAGLaser

		From dbo.ERS_Sites S 
			 join ERS_Procedures p on p.ProcedureId=S.ProcedureId
			LEFT OUTER JOIN	dbo.ERS_UpperGITherapeutics UT ON S.SiteId = UT.SiteId 
			LEFT OUTER JOIN	[dbo].ERS_ERCPTherapeutics	AS ER ON S.SiteId = ER.SiteId
			LEFT JOIN				[dbo].ERS_Regions				AS  R ON S.RegionId = R.RegionId
			LEFT OUTER JOIN			[dbo].[ERS_ERCPAbnoDuct]		AS Abn ON S.SiteId = Abn.SiteId
			LEFT OUTER JOIN			[dbo].[ERS_UpperGISpecimens]	AS  T ON S.SiteId = T .SiteId
			where p.ProcedureCompleted = 1
			and p.IsActive = 1
			and IsNull(p.DNA,0) = 0
			and p.OperatingHospitalID in (Select Item from dbo.splitString(@OperatingHospitalList, ','))
			and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
		) As PT
		UNPIVOT (
			TherapeuticID FOR Therapies IN (
											AbnormalityMarked,
											ArgonBeamDiathermy,
											BalloonDilation,
											BalloonTrawl,
											BandingPiles,
											BandLigation ,
											BicapElectrocautery,
											BotoxInjection,
											BougieDilation,
											Brush,
											Cannulation,
											Clip,
											DiagCholangiogram,
											DiagPancreatogram,
											Diathermy,
											EMR,
											EndoClot,
											EndoloopPlacement,
											EndoscopicCystPuncture,
											ForeignBody,
											Haemospray ,
											Haemostasis,
											HeatProbe ,
											HotBiopsy,
											Injection,
											Manometry,
											Marking,
											NasojejunalTube,
											NasojejunalTubeRemoval,
											NasopancreaticDrain,
											OesophagealDilatation,
											PEGChange,
											PEGInsertion,
											PEGRemoval,
											pHProbeInsertion,
											Polypectomy,
											PyloricDuodenalDilation,
											RendezvousProcedure,
											RFA ,
											Sigmoidopexy,
											SnareExcision,
											Sphincterotomy,
											StentChange,
											StentPlacement,
											StentRemoval,
											StoneRemoval,
											StrictureDilatation,
											VaricealSclerotherapy,
											YAGLaser
			)
		) As UP

		SELECT DISTINCT T2.ProcedureId, 
			SUBSTRING(
				(
					SELECT ', '+T1.Therapies  AS [text()]
					FROM #ProcedureTherapy T1
					WHERE T1.ProcedureId = T2.ProcedureId
					ORDER BY T1.ProcedureId
					FOR XML PATH ('')
				), 3, 1000) Therapies
		Into #TherapyList
		FROM #ProcedureTherapy T2



		Select  u.Surname + ', ' + u.Forename as 'Endoscopist1',
				u2.Surname + ', ' + u2.Forename as 'Endoscopist2',
				convert(varchar, p.CreatedOn, 106) as 'ProcedureDate',
				pat.Surname + ', '+ pat.Forename1 as 'Patient',
				pat.HospitalNumber,
				tl.Therapies,
				pt.ProcedureType
		From	ERS_Procedures p
		join	ERS_ProcedureTypes pt on p.ProcedureType = pt.ProcedureTypeId 
		join	ERS_Users u on p.Endoscopist1 = u.UserId
		left join ERS_Users u2 on u2.UserID = p.Endoscopist2
		join	ERS_Patients pat on p.PatientId = pat.PatientId
		join #TherapyList tl on p.ProcedureId = tl.ProcedureId
		join	ERS_ReportConsultants rc on u.UserID = rc.ConsultantID 
		where	p.ProcedureCompleted = 1
			and p.IsActive = 1
			and IsNull(p.DNA,0) = 0
			and p.OperatingHospitalID in (Select Item from dbo.splitString(@OperatingHospitalList, ','))
			and p.CreatedOn >= @FromDate AND p.CreatedOn <= @ToDate
			and rc.UserID = @UserId
END

Go


ALTER  PROCEDURE [dbo].[report_SCH_Activity]
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

5.      05 June 2024   Make the calculation correct and show the future date. TFS 3547
****************************************************************************************************************************/
BEGIN

SET NOCOUNT ON

	  SELECT d.DiaryId as [DiaryId],
	  eoh.HospitalName AS [OperatingHospital],
	  d.RoomID as [RoomId],FORMAT(d.DiaryStart, 'ddd') AS [Day],        
        CONVERT(DATE, d.DiaryStart, 106) AS [Date], r.RoomName as Room,  

		c.Title + ' ' + c.Title + ' ' + c.Forename + ' ' + c.Surname as [List Consultant],
		e.Title + ' ' + e.Forename + ' ' + e.Surname as Endoscopist,
		l.ListName AS [TemplateName],
		CASE
            WHEN DATEPART(HH, d.DiaryStart) < 12 THEN
                'AM'
            WHEN DATEPART(HH,d.DiaryStart) < 17 THEN
                'PM'
            ELSE
                'EV'
        END AS [AM/PM],
	 -- l.TotalMins, 
	  l.Points  [NoOfPtsOnTemplate], 
	  l.Points  -	ISNULL((SELECT sum(apt.Points)
							FROM ERS_Appointments a 
							INNER JOIN ERS_AppointmentProcedureTypes apt on apt.AppointmentID = a.AppointmentId 
							LEFT JOIN dbo.ERS_AppointmentStatus aps ON aps.UniqueId = a.AppointmentStatusId
							WHERE DiaryId = d.DiaryId AND ISNULL(aps.HDCKEY,'') <> 'C'),0)
							AS NoOfPtsRemaining,
	ISNULL((SELECT sum(apt.Points) 
			FROM ERS_Appointments a 
			INNER JOIN ERS_AppointmentProcedureTypes apt on apt.AppointmentID = a.AppointmentId
			LEFT JOIN dbo.ERS_AppointmentStatus aps ON aps.UniqueId = a.AppointmentStatusId
			WHERE DiaryId = d.DiaryId AND ISNULL(aps.HDCKEY,'') <> 'C'),0) 
			AS NoOfPtsBooked,
		ISNULL((SELECT count(*)
			FROM ERS_Appointments a
			INNER JOIN ERS_AppointmentProcedureTypes apt on apt.AppointmentID = a.AppointmentId
			LEFT JOIN dbo.ERS_AppointmentStatus aps ON aps.UniqueId = a.AppointmentStatusId
			WHERE DiaryId = d.DiaryId AND ISNULL(aps.HDCKEY,'') in ('A','BA','IP','DC','RC')),0) 
			AS [NoOfPatientsAttended],
	ISNULL((SELECT SUM(apt.Points)
			FROM ERS_Appointments a
			INNER JOIN ERS_AppointmentProcedureTypes apt on apt.AppointmentID = a.AppointmentId
			LEFT JOIN dbo.ERS_AppointmentStatus aps ON aps.UniqueId = a.AppointmentStatusId
			WHERE DiaryId = d.DiaryId AND ISNULL(aps.HDCKEY,'') in ('A','BA','IP','DC','RC')),0) 
			AS [NoOfPatientPointsUsed],
	ISNULL((SELECT SUM(ls.Points) FROM dbo.ERS_SCH_ListSlots ls WHERE ls.Locked = 1 AND ls.ListRulesId = d.ListRulesId),0) BlockedPoints,
		case when d.Locked = 1 THEN 'YES' ELSE 'NO' END as [ListLocked],
		diaryLockReason.Reason AS [ReasonsLocked],
		case when d.Locked = 0 THEN 'YES' ELSE 'NO' END as [ListUnLocked],
		diaryUnlockReason.Reason AS [ReasonsUnlocked],
		STUFF((
		SELECT ', ' + CAST(ss.Description +CAST(Sum(ISNULL(s.Points, 1)) AS varchar) AS VARCHAR(MAX))
		FROM ERS_SCH_ListSlots s 
		INNER JOIN dbo.ERS_SCH_SlotStatus ss ON ss.StatusId = s.SlotId
		WHERE (d.ListRulesId = s.ListRulesId AND s.Active = 1) 
		group by ss.Description
		FOR XML PATH(''),TYPE 
		).value('.','VARCHAR(MAX)') 
,1,2,'') as 'SlotStatus'

		--d.Locked,
	 --   l.GIProcedure,
	 --   d.Training
  FROM ERS_SCH_DiaryPages d
		INNER JOIN ERS_SCH_Rooms r ON r.RoomId = d.RoomID
	  INNER JOIN ERS_SCH_ListRules l ON l.ListRulesId = d.ListRulesId
	  LEFT JOIN ERS_Users e ON e.UserID = d.UserId
	  LEFT JOIN ERS_Users c ON c.UserID = d.ListConsultantId
	  LEFT JOIN dbo.ERS_OperatingHospitals AS eoh (NOLOCK)
			ON eoh.OperatingHospitalId = r.HospitalId
	Left JOIN dbo.ERS_SCH_LockedDiaries AS esld
				ON esld.DiaryId = d.DiaryId
			LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS diaryLockReason
				ON diaryLockReason.DiaryLockReasonId = esld.LockedReasonId
			LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS diaryUnlockReason
			ON diaryUnlockReason.DiaryLockReasonId = esld.UnlockedReasonId
  WHERE  cast(d.DiaryStart as date) between @SearchStartDate and  @SearchEndDate
 and d.RoomID in (select  item from dbo.fnSplitString(@RoomIds, ','))
 and d.OperatingHospitalId in (select item  from dbo.fnSplitString(ISNULL(@OperatingHospitalIds, ''), ','))
 	AND e.Suppressed = CASE WHEN @HideSuppressedEndoscopists = 1 THEN 0 ELSE e.Suppressed END
	AND c.Suppressed = CASE WHEN @HideSuppressedConsultants = 1 THEN 0 ELSE c.Suppressed END
  ORDER BY d.DiaryStart


--    IF OBJECT_ID('tempdb..#ActivityDetails') IS NOT NULL
--        DROP TABLE #ActivityDetails;
--    IF OBJECT_ID('tempdb..#ListSlots') IS NOT NULL
--        DROP TABLE #ListSlots;
--    IF OBJECT_ID('tempdb..#Appointments') IS NOT NULL
--        DROP TABLE #Appointments;
--    IF OBJECT_ID('tempdb..#tmpOperatingHospitals') IS NOT NULL
--        DROP TABLE #tmpOperatingHospitals;
--    IF OBJECT_ID('tempdb..#tmpRooms') IS NOT NULL
--        DROP TABLE #tmpRooms;
--	IF OBJECT_ID('tempdb..#Total_Slots') IS NOT NULL
--        DROP TABLE #Total_Slots;
--	IF OBJECT_ID('tempdb..#No_Of_Patients') IS NOT NULL
--        DROP TABLE #No_Of_Patients;		
--	IF OBJECT_ID('tempdb..#No_Of_Patient_Pts_Used') IS NOT NULL
--        DROP TABLE #No_Of_Patient_Pts_Used;

--	CREATE TABLE #ListSLots
--	(
--		[Id] INT NOT NULL IDENTITY(1, 1),
--        [DiaryIdSlotOrder] INT NULL,
--        [ListSlotId] INT NULL,
--        [ListRulesId] INT NULL,
--        [SlotMinutes] INT NULL,
--        [Points] INT NULL,
--        [DiaryId] INT NULL,
--        [StartTime] DATE NULL,
--        [EndTime] DATE NULL,
--        [Duration] INT NULL,
--        [ApptOverFlow] INT NULL,
--        [RoomId] INT NULL
--	)
	
--	CREATE NONCLUSTERED INDEX [IX_ListSlots_SlotMinutes]
--		ON [dbo].[#ListSlots] ([DiaryId],[StartTime])
--		INCLUDE ([SlotMinutes]);
	
--	CREATE TABLE #Total_Slots
--	(
--	    [ListRulesId] INT NULL,
--		[ListCount] INT NULL
--	)
	
--	INSERT INTO #Total_Slots
--	( 
--		ListRulesId,
--		ListCount
--	) 
--	( 
--		SELECT 
--			ListRulesId, 
--			COALESCE(COUNT(*), 0)
--		FROM 
--			dbo.ERS_SCH_ListSlots (NOLOCK) 
--		GROUP BY 
--			ListRulesId 
--	)

--	CREATE TABLE #No_Of_Patients
--	(
--	    [DiaryId] INT NULL,
--		[ListCount] INT NULL
--	)

--	INSERT INTO #No_Of_Patients
--	(
--		DiaryId,
--		ListCount
--	)
--    (
--		SELECT 
--			ea.DiaryId,
--			COALESCE(COUNT(*), 0) 
--		FROM
--			dbo.ERS_Appointments AS ea (NOLOCK)
--			INNER JOIN dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
--				ON esdp.DiaryId = ea.DiaryId
--		WHERE
--			ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
--			AND ea.DiaryId IS NOT NULL
--		GROUP BY
--			ea.DiaryId
--	)
	
--	CREATE TABLE #No_Of_Patient_Pts_Used
--	(
--	    [DiaryId] INT NULL,
--		[ListCount] INT NULL
--	)
		
--	INSERT INTO #No_Of_Patient_Pts_Used
--	(
--		DiaryId,
--		ListCount
--	)
--	(
--		SELECT
--			ea2.DiaryId,
--			COALESCE(SUM(eapt.Points), 0) AS listCount
--		FROM
--			dbo.ERS_Appointments AS ea2 (NOLOCK)
--			INNER JOIN dbo.ERS_AppointmentProcedureTypes AS eapt (NOLOCK)
--				ON eapt.AppointmentID = ea2.AppointmentId
--		WHERE
--			ea2.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery			
--		GROUP BY
--			ea2.DiaryId
--	) 
	
--	CREATE TABLE #tmpOperatingHospitals
--	(
--	    [Id] INT NOT NULL,
--		[Item] INT NOT NULL
--	)

--	INSERT INTO #tmpOperatingHospitals
--	(
--	    Id,
--	    Item
--	)
--	(   
--		SELECT
--			Id,
--			Item    
--		FROM
--			dbo.fnSplitString(ISNULL(@OperatingHospitalIds, ''), ',')
--	)

--	CREATE TABLE #tmpRooms
--	(
--	    [Id] INT NOT NULL,
--		[Item] INT NOT NULL
--	)
    
--	INSERT INTO #tmpRooms
--	(
--	    Id,
--	    Item
--	)	
--	(   
--		SELECT
--			Id,
--			Item		
--		FROM
--			dbo.fnSplitString(ISNULL(@RoomIds, ''), ',')
--	)

--	CREATE TABLE #Appointments
--	(
--	    [Id] INT NOT NULL IDENTITY (1, 1),
--		[OperatingHospital] VARCHAR(150) NOT NULL,
--		[DiaryId] INT NOT NULL,
--		[StartTime] DATETIME NOT NULL,
--		[Duration] VARCHAR(100) NULL,
--		[ListSlotId] INT
--	)

--	INSERT INTO #Appointments
--	(
--	    OperatingHospital,
--	    DiaryId,
--	    StartTime,
--	    Duration,
--		ListSlotId
--	)
--	(  
--		SELECT			
--			oh.HospitalName,
--			ea.DiaryId,
--			ea.StartDateTime,
--			ea.AppointmentDuration,
--			ea.ListSlotId
--		FROM
--			dbo.ERS_Appointments AS ea (NOLOCK)
--			INNER JOIN dbo.ERS_OperatingHospitals oh (NOLOCK)
--				ON ea.OperationalHospitaId = oh.OperatingHospitalId
--		WHERE
--			ea.DiaryId IS NOT NULL
--			AND EXISTS
--			(
--				SELECT Item FROM #tmpOperatingHospitals AS toh
--			)
--			AND ea.StartDateTime BETWEEN @SearchStartDate AND @SearchEndDate	
--			AND ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
--	)
	
--    DECLARE @counter INT = 0;
--    DECLARE @ListSlotsTempTableCount INT = 0;

--    INSERT INTO #ListSlots
--	(
--        [DiaryIdSlotOrder],
--        [ListSlotId],
--        [ListRulesId],
--        [SlotMinutes],
--        [Points],
--        [DiaryId],
--        [StartTime],
--        [EndTime],
--        [Duration],
--        [ApptOverFlow],
--        [RoomId]
--	)
--	SELECT
--        0, 
--        esls.ListSlotId, 
--        esls.ListRulesId, 
--        esls.SlotMinutes, 
--        esls.Points, 
--        esdp.DiaryId, 
--        esdp.DiaryStart, 
--        esdp.DiaryEnd,
--        0, 
--        0,
--        esdp.RoomID
--    FROM
--        dbo.ERS_SCH_ListSlots AS esls (NOLOCK)
--        LEFT JOIN dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
--            ON esdp.ListRulesId = esls.ListRulesId
--    WHERE
--        esdp.DiaryId IS NOT NULL
--		AND esdp.RoomID in
--        (
--            SELECT Item FROM #tmpRooms AS tr
--        )
--        AND esdp.DiaryStart
--        BETWEEN @SearchStartDate AND @SearchEndDate

--    ORDER BY
--        esdp.DiaryId,
--        esls.ListSlotId;

--    SELECT
--        @ListSlotsTempTableCount = @@ROWCOUNT;
		
--    DECLARE @tempDiaryId INT = 0;
--    DECLARE @currentRecordDiaryId INT = 0;
--    DECLARE @newDiaryRecordFlag BIT = 0;
--    DECLARE @currentRecordSlotMinutes INT = 0;
--    DECLARE @currentRecordStartTime DATETIME;
--    DECLARE @currentRecordEndTime DATETIME;
--    DECLARE @previousRecordEndTime DATETIME;
--    DECLARE @diaryIdSlotOrder INT = 0;

--    SET @counter = 1;

--    WHILE (@counter <= @ListSlotsTempTableCount)
--    BEGIN
--        SELECT
--            @currentRecordDiaryId = DiaryId,
--            @currentRecordSlotMinutes = SlotMinutes,
--            @currentRecordStartTime = StartTime
--        FROM
--            #ListSlots
--        WHERE
--            Id = @counter;

--        IF @tempDiaryId = 0
--           OR @tempDiaryId <> @currentRecordDiaryId
--        BEGIN
--            SET @tempDiaryId = @currentRecordDiaryId;
--            SET @newDiaryRecordFlag = 1;
--            SET @diaryIdSlotOrder = 1;
--        END;
--        ELSE
--        BEGIN
--            SET @newDiaryRecordFlag = 0;
--            SET @diaryIdSlotOrder = @diaryIdSlotOrder + 1;
--        END;

--        IF @newDiaryRecordFlag = 1
--        BEGIN
--            SET @currentRecordEndTime = DATEADD(MINUTE, @currentRecordSlotMinutes, @currentRecordStartTime);

--            UPDATE
--                #ListSlots
--            SET
--                EndTime = @currentRecordEndTime,
--                DiaryIdSlotOrder = @diaryIdSlotOrder
--            WHERE
--                Id = @counter;
--        END;
--        ELSE IF @newDiaryRecordFlag = 0
--        BEGIN
--            SET @currentRecordStartTime = @previousRecordEndTime;
--            SET @currentRecordEndTime = DATEADD(MINUTE, @currentRecordSlotMinutes, @currentRecordStartTime);

--            UPDATE
--                #ListSlots
--            SET
--                StartTime = @currentRecordStartTime,
--                EndTime = @currentRecordEndTime,
--                DiaryIdSlotOrder = @diaryIdSlotOrder
--            FROM
--                #ListSlots
--            WHERE
--                Id = @counter;
--        END;

--        SET @counter = @counter + 1;

--        SET @previousRecordEndTime = @currentRecordEndTime;

--    END;    

--    UPDATE
--        ls
--    SET
--        ls.Duration = a.Duration,
--        ls.ApptOverFlow = a.Duration - ls.SlotMinutes
--    FROM
--        #ListSlots ls
--        INNER JOIN #Appointments AS a
--            ON a.DiaryId = ls.DiaryId and a.ListSlotId = ls.ListSlotId
--               AND a.StartTime = ls.StartTime;

--CREATE TABLE #ActivityDetails
--(
--    [DiaryId] INT NOT NULL,
--	[OperatingHospital] VARCHAR(500) NULL,
--	[RoomId] INT NULL,
--	[Day] VARCHAR(10) NULL,
--	[Date] DATE NULL,
--	[Room] VARCHAR(50) NULL,
--	[ListConsultant] VARCHAR(50) NULL,
--	[Endoscopist] VARCHAR(50) NULL,
--	[TemplateName] VARCHAR(75) NULL,
--	[AM/PM] VARCHAR(2) NULL,
--	[NoOfPtsOnTemplate] INT NULL,
--	[NoOfPtsBooked] INT NULL,
--	[NoOfPtsRemaining] INT NULL,
--	[NoOfPatientsAttended] INT NULL,
--	[NoOfPatientPointsUsed] INT NULL,		
--	[ListLocked] VARCHAR(3) NULL,	
--	[ReasonsLocked] VARCHAR(100) NULL,
--	[ListUnlocked] VARCHAR(3) NULL,
--	[ReasonsUnlocked] VARCHAR(100) NULL
--)

--INSERT INTO #ActivityDetails
--(
--    [DiaryId],
--	[OperatingHospital],
--	[RoomId],
--	[Day],
--	[Date],
--	[Room],
--	[ListConsultant],
--	[Endoscopist],
--	[TemplateName],
--	[AM/PM],
--	[NoOfPtsOnTemplate],
--	[NoOfPtsBooked],
--	[NoOfPtsRemaining],
--	[NoOfPatientsAttended],
--	[NoOfPatientPointsUsed],		
--	[ListLocked],	
--	[ReasonsLocked],
--	[ListUnlocked],
--	[ReasonsUnlocked]
--)			   
--(
--	SELECT  
--        ea.DiaryId AS [DiaryId],
--		eoh.HospitalName AS [OperatingHospital],
--		esr.RoomId AS [RoomId],
--        FORMAT(ea.StartDateTime, 'ddd') AS [Day],        
--        CONVERT(DATE, ea.StartDateTime, 106) AS [Date],        
--        esr.RoomName AS [Room],
--        CASE
--            WHEN eu.IsListConsultant = 1 THEN
--                LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)
--            ELSE
--                ''
--        END AS [ListConsultant],
--        CASE
--            WHEN eu.IsEndoscopist1 = 1
--                 OR eu.IsEndoscopist2 = 1 THEN
--                LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename)
--            ELSE
--                ''
--        END AS [Endoscopist],
--        eslr.ListName AS [TemplateName],
--        CASE
--            WHEN DATEPART(HH, ea.StartDateTime) < 12 THEN
--                'AM'
--            WHEN DATEPART(HH, ea.StartDateTime) < 17 THEN
--                'PM'
--            ELSE
--                'EV'
--        END AS [AM/PM],
--        COALESCE(eslr.Points, 0) AS [NoOfPtsOnTemplate],
--        COALESCE(esls.Points, 0) AS [NoOfPtsBooked],
--		COALESCE(eslr.Points, 0) - COALESCE(esls.Points, 0) AS [NoOfPtsRemaining],
--        COALESCE(no_of_patients.ListCount, 0) AS [NoOfPatientsAttended],
--        COALESCE(no_of_patient_pts_used.ListCount, 0) AS [NoOfPatientPointsUsed],		
--		'' AS [ListLocked],	
--		'' AS [ReasonsLocked],
--		'' AS [ListUnlocked],
--		'' AS [ReasonsUnlocked]		    		    
--    FROM
--        dbo.ERS_SCH_DiaryPages AS esdp (NOLOCK)
--        INNER JOIN dbo.ERS_SCH_ListRules AS eslr (NOLOCK)
--            ON esdp.ListRulesId = eslr.ListRulesId
--        INNER JOIN dbo.ERS_SCH_ListSlots AS esls (NOLOCK)
--            ON esdp.ListRulesId = esls.ListRulesId
--        INNER JOIN dbo.ERS_Appointments AS ea (NOLOCK)
--            ON esdp.DiaryId = ea.DiaryId AND ea.ListSlotId = esls.ListSlotId			
--			AND ea.StartDateTime >= esdp.DiaryStart AND ea.StartDateTime <= esdp.DiaryEnd
--			AND ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 ) -- (2)Attended, (3)Arrived, (9)In Progress, (12)Discharged, (13)Recovery
--        INNER JOIN dbo.ERS_SCH_Rooms AS esr (NOLOCK)
--            ON esdp.RoomID = esr.RoomId
--        LEFT JOIN dbo.ERS_Users AS eu (NOLOCK)
--            ON ea.EndoscopistId = eu.UserID
--		LEFT JOIN ERS_Users elc ON esdp.ListConsultantId = elc.UserID
--        LEFT JOIN dbo.ERS_SCH_LockedDiaries AS esld (NOLOCK)
--            ON esld.DiaryId = esdp.DiaryId 
--			AND esld.DiaryId IS NOT NULL	
--        LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS esdlr (NOLOCK)
--            ON esdlr.DiaryLockReasonId = esld.LockedReasonId
--		LEFT JOIN #No_Of_Patients AS no_of_patients
--			ON no_of_patients.DiaryId = esdp.DiaryId 
--		LEFT JOIN #No_Of_Patient_Pts_Used AS no_of_patient_pts_used
--            ON no_of_patient_pts_used.DiaryId = esdp.DiaryId
--		LEFT JOIN dbo.ERS_OperatingHospitals AS eoh (NOLOCK)
--			ON eoh.OperatingHospitalId = esr.HospitalId
--    WHERE
--        esdp.OperatingHospitalId in 
--        (
--            SELECT Item FROM #tmpOperatingHospitals
--        )
--        AND esdp.RoomID in 
--        (
--            SELECT Item FROM #tmpRooms
--        )
		
--		AND eu.Suppressed = CASE WHEN @HideSuppressedEndoscopists = 1 THEN 0 ELSE eu.Suppressed END
--		AND elc.Suppressed = CASE WHEN @HideSuppressedConsultants = 1 THEN 0 ELSE elc.Suppressed END
--    GROUP BY
--        ea.DiaryId,
--		eoh.HospitalName,
--        ea.StartDateTime,
--        CASE
--            WHEN DATEPART(HH, ea.StartDateTime) < 12 THEN
--                'AM'
--            WHEN DATEPART(HH, ea.StartDateTime) < 17 THEN
--                'PM'
--            ELSE
--                'EV'
--        END,
--		esr.RoomId,
--        esr.RoomName,
--        eu.IsListConsultant,
--        eu.IsEndoscopist1,
--        eu.IsEndoscopist2,
--        LTRIM(eu.Surname) + ', ' + LTRIM(eu.Forename),
--        eslr.ListName,
--        eslr.Points,
--        esls.Points,
--        no_of_patients.listCount,
--        no_of_patient_pts_used.listCount,        
--        ea.EndoscopistId
--);
		
--	WITH appointment_details AS
--	(
--		SELECT 
--			ea.DiaryId, 
--			ea.StartDateTime, 
--			esdp.DiaryStart, 
--			esdp.DiaryEnd, 
--			esld.Locked, 
--			diaryLockReason.IsLockReason,		
--			diaryLockReason.Reason AS [LockReason],
--			diaryUnlockReason.IsUnlockReason,
--			diaryUnlockReason.Reason AS [UnlockReason]
--		FROM 
--			dbo.ERS_Appointments AS ea
--			INNER JOIN dbo.ERS_SCH_DiaryPages AS esdp 
--				ON ea.DiaryId = esdp.DiaryId
--			INNER JOIN dbo.ERS_SCH_LockedDiaries AS esld
--				ON esld.DiaryId = ea.DiaryId
--			LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS diaryLockReason
--				ON diaryLockReason.DiaryLockReasonId = esld.LockedReasonId
--			LEFT JOIN dbo.ERS_SCH_DiaryLockReasons AS diaryUnlockReason
--			ON diaryUnlockReason.DiaryLockReasonId = esld.UnlockedReasonId
--		WHERE 
--			ea.StartDateTime >= esdp.DiaryStart AND ea.StartDateTime <= esdp.DiaryEnd
--			AND ea.AppointmentStatusId IN ( 2, 3, 9, 12, 13 )		
--	)

--	UPDATE
--		#ActivityDetails
--	SET
--		#ActivityDetails.ListLocked = CASE WHEN appointment_details.Locked = 1 THEN 'YES' ELSE 'NO' END,
--		#ActivityDetails.ReasonsLocked = CASE WHEN appointment_details.Locked = 1 THEN appointment_details.LockReason ELSE '' END,
--		#ActivityDetails.ListUnlocked = CASE WHEN appointment_details.Locked = 0 THEN 'YES' ELSE 'NO' END,
--		#ActivityDetails.ReasonsUnlocked = CASE WHEN appointment_details.Locked = 0 THEN appointment_details.UnlockReason ELSE '' END
--	FROM
--		appointment_details 
--	WHERE
--		#ActivityDetails.[DiaryId] = appointment_details.[DiaryId] 	

--    SELECT
--        [DiaryId],
--		[OperatingHospital],
--        [RoomId],
--        [Day],
--        [Date],
--        [Room],
--        [ListConsultant],
--        [Endoscopist],
--        [TemplateName],
--        [AM/PM],
--        [NoOfPtsOnTemplate],
--        [NoOfPtsBooked],
--		[NoOfPtsRemaining],
--        [NoOfPatientsAttended],
--        [NoOfPatientPointsUsed],
--        [ListLocked],
--        [ReasonsLocked],
--        [ListUnlocked],
--        [ReasonsUnlocked]
--    FROM
--        #ActivityDetails
--    WHERE
--        RoomId IS NOT NULL
--    GROUP BY
--        [DiaryId],
--		[OperatingHospital],
--        [Date],
--        [AM/PM],
--        [RoomId],
--        [Room],
--        [Day],
--        [ListConsultant],
--        [Endoscopist],
--        [TemplateName],
--        [NoOfPtsOnTemplate],
--		[NoOfPtsBooked],
--		[NoOfPtsRemaining],
--        [NoOfPatientsAttended],
--		[NoOfPatientPointsUsed],
--        [ListLocked],
--        [ReasonsLocked],
--        [ListUnlocked],
--        [ReasonsUnlocked]
--    ORDER BY
--        [Date] DESC;

END
GO
GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Partha
-- TFS#	3572
-- Description of change
-- Additional report to show Therapeutic Procedure Audit 
------------------------------------------------------------------------------------------------------------------------
GO

 EXEC dbo.DropIfExist @ObjectName = 'AuditAppointmentTherapeutic',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
	GO
Create  PROCEDURE [dbo].[AuditAppointmentTherapeutic]
(
	@UserId INT
)
AS
BEGIN
DECLARE @FromDate as Date,
	@ToDate as Date,
	@TrustId as int,
	@OperatingHospitalList as varchar(100)

	Select	@FromDate = FromDate,
			@ToDate = ToDate,
			@TrustId = TrustId,
			@OperatingHospitalList=OperatingHospitalList
	FROM	ERS_ReportFilter
	where	UserID = @UserId

		  SELECT    distinct    
			CONVERT(varchar(14), d.DiaryStart, 106) AS [AppointmentDate], 
			eoh.HospitalName,
			r.RoomName as Room,
			pat.Surname + ', '+ pat.Forename1 as Patient, 
			pat.HospitalNumber as 'Case No.',
			pat.NHSNo, 
			e.Title + ' ' + e.Forename + ' ' + e.Surname as Endoscopist,
			c.Title + ' ' + c.Title + ' ' + c.Forename + ' ' + c.Surname as ListConsultant,
			pt.ProcedureType,
			STUFF((
					SELECT ', ' + CAST(Description AS VARCHAR(MAX))
					FROM ERS_TherapeuticTypes t
					JOIN ERS_AppointmentTherapeutics ats on ats.TherapeuticTypeID=t.Id
					WHERE (ats.AppointmentID=a.AppointmentId) 
					FOR XML PATH(''),TYPE 
					).value('.','VARCHAR(MAX)') 
	  ,1,2,'') as 'Therapeutic',d.DiaryStart
 
	  FROM ERS_Appointments a
		INNER JOIN ERS_AppointmentProcedureTypes apt on apt.AppointmentID = a.AppointmentId
		 Join ERS_ProcedureTypes pt on apt.ProcedureTypeID=pt.ProcedureTypeID
		INNER Join ERS_AppointmentTherapeutics ats on ats.AppointmentID= a.AppointmentId
		JOIN ERS_SCH_DiaryPages d on d.DiaryId=a.diaryid 
		LEFT JOIN ERS_SCH_Rooms r ON r.RoomId = d.RoomID
		JOIN ERS_Patients pat on pat.PatientId=a.PatientId	
		  INNER JOIN ERS_SCH_ListRules l ON l.ListRulesId = d.ListRulesId
		  LEFT JOIN ERS_Users e ON e.UserID = d.UserId
		  LEFT JOIN ERS_Users c ON c.UserID = d.ListConsultantId
		  INNER JOIN dbo.ERS_SCH_Rooms AS esr (NOLOCK)
            ON d.RoomID = esr.RoomId
		  	LEFT JOIN dbo.ERS_OperatingHospitals AS eoh (NOLOCK)
     		ON eoh.OperatingHospitalId = esr.HospitalId
	  WHERE  d.DiaryStart between @FromDate and  @ToDate
	 --and d.RoomID in (select  item from dbo.fnSplitString(@RoomIds, ','))
	 --and d.OperatingHospitalId in (select item  from dbo.fnSplitString(ISNULL(@OperatingHospitalIds, ''), ','))
	  ORDER BY d.DiaryStart desc

 END 
 GO
 

 
  if not  exists(select 1 from ERS_AuditReports where AuditReportStoredProcedure='AuditAppointmentTherapeutic')
     insert into ERS_AuditReports(AuditReportDescription,AuditReportStoredProcedure)  values ('Audit Appointment Therapeutic', 'AuditAppointmentTherapeutic')

GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Ferdowsi On 10 june 2024
-- TFS#	No TFS - Item 3248
-- Description of change  
--  V2 Scheduler Cancellation List Audit 
------------------------------------------------------------------------------------------------------------------------


EXEC dbo.DropIfExist @ObjectName = 'report_SCH_Schedule_list_Cancellation',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[report_SCH_Schedule_list_Cancellation]
(
	@SearchStartDate AS datetime,
    @SearchEndDate AS datetime,
    @OperatingHospitalIds VARCHAR(100),
    @RoomIds VARCHAR(1000),
	@HideSuppressedConsultants BIT,
	@HideSuppressedEndoscopists BIT
)
AS

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
		d.DiaryId,
		Convert(varchar,d.DiaryStart,106) AS Date,
		FORMAT(d.DiaryStart, 'ddd') AS [Day],
		d.DiaryStart,
		(CASE WHEN  ISNULL(us.Title,'') <> '' THEN us.Title + ' ' ELSE '' END +
	    CASE WHEN  ISNULL(us.Forename,'') <> '' THEN us.Forename + ' ' ELSE '' END +
	    CASE WHEN  ISNULL(us.Surname,'') <> '' THEN us.Surname + ' ' ELSE '' END) as CancelledBy,
		(CASE WHEN  ISNULL(u.Title,'') <> '' THEN u.Title + ' ' ELSE '' END +
	    CASE WHEN  ISNULL(u.Forename,'') <> '' THEN u.Forename + ' ' ELSE '' END +
	    CASE WHEN  ISNULL(u.Surname,'') <> '' THEN u.Surname + ' ' ELSE '' END) as Endoscopist,
	    (CASE WHEN  ISNULL(c.Title,'') <> '' THEN c.Title + ' ' ELSE '' END +
	    CASE WHEN  ISNULL(c.Forename,'') <> '' THEN c.Forename + ' ' ELSE '' END +
	    CASE WHEN  ISNULL(c.Surname,'') <> '' THEN c.Surname + ' ' ELSE '' END) as ListConsultant,
		l.ListName As List
		,d.suppressed
		,LEFT(CONVERT(VARCHAR, DiaryStart, 108),5) +' - '+ LEFT(CONVERT(VARCHAR, DiaryEnd, 108),5) AS TimeSlot
		,(Convert(varchar,d.SuppressedFromDate,106) +' ' +  LEFT(CONVERT(VARCHAR, d.SuppressedFromDate, 108),5)) AS  CancelledDate 
		,hos.HospitalName  AS OperatingHospital
	 
	 	,( CASE WHEN   reason.Detail <> 'other' THEN reason.Detail  ELSE d.CancelComment END)  As CancellationReason 
		,r.RoomName AS Room
		, (SELECT  SUM(s.Points) FROM ERS_SCH_ListSlots s WHERE d.ListRulesId = s.ListRulesId AND s.Active = 1) AS Points
     	FROM ERS_SCH_DiaryPages d
		INNER JOIN dbo.ERS_SCH_Rooms r ON r.RoomId =  d.RoomID
		INNER JOIN ERS_SCH_ListRules l ON l.ListRulesId = d.ListRulesId
		LEFT JOIN ERS_Users u ON u.UserID = d.UserId
		LEFT JOIN ERS_Users c ON c.UserID = d.ListConsultantId
	    LEFT JOIN ERS_Users us ON us.UserID = d.SuppressedBy
		LEFT JOIN ERS_OperatingHospitals hos ON hos.OperatingHospitalId = d.OperatingHospitalId
		LEFT JOIN ERS_ListCancelReasons reason ON reason.ListCancelReasonId = d.CancelReasonId

	WHERE
	 
	CAST(d.SuppressedFromDate AS DATE) >= @SearchStartDate AND CAST(d.SuppressedFromDate AS DATE) <= @SearchEndDate
     AND  d.OperatingHospitalId IN
        (
            SELECT Item FROM #tmpOperatingHospitals
        )
        AND  d.RoomID IN
            (
                SELECT Item FROM #tmpRooms
            )
	    AND u.Suppressed = CASE WHEN @HideSuppressedEndoscopists = 1 THEN 0 ELSE u.Suppressed END
		AND c.Suppressed = CASE WHEN @HideSuppressedConsultants = 1 THEN 0 ELSE c.Suppressed END	
		AND d.suppressed = 1

	ORDER BY  CONVERT(DATETIME, d.SuppressedFromDate, 100) DESC

GO

------------------------------------------------------------------------------------------------------------------------
-- END TFS#	No TFS - Item 3248
------------------------------------------------------------------------------------------------------------------------

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
/*	02		:		03 July 2024	Partha , date comparision issue, just cast the date field as date*/
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
        AND cast(ea.StartDateTime as Date)
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
        AND cast(d.Date as date)
        BETWEEN @SearchStartDate AND @SearchEndDate;

END;