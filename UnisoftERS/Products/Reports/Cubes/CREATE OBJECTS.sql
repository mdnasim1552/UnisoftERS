
/* REMARKS */
/* Consolidated report V 2.0 */
/* There are still some scripts not compatible with SQL Server 2008 */
/* Splitting of some scripts between ERS and UGI is in progress */
/* Customized setup for ERS And/Or/Xor UGI version is still pending */
/*------------------------------Reporting Consolidated Script------------------------------*/
/*------------------------------   BEGIN OF HUSSEIN'S PART   ------------------------------*/
Set NOCOUNT ON
GO

DECLARE @IncludeUGI BIT = 0

IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'Episode')) SET @IncludeUGI = 1

CREATE TABLE #variables (IncludeUGI BIT)
INSERT INTO #variables (IncludeUGI) 
	VALUES (@IncludeUGI)



/* FUNCTIONS */









---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_PatientType', 'V';
GO

/* [dbo].[fw_PatientType] */
Create View [dbo].[fw_PatientType] As Select ListItemNo As PatientTypeId, ListItemText As PatientType From ERS_Lists Where ListDescription='Patient Type' Union Select 0 As PatientTypeId, 'Unknow' As PatientType 
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_PatientStatus', 'V';
GO

/* [dbo].[fw_PatientStatus] */
Create View [dbo].[fw_PatientStatus] As Select ListItemNo As PatientStatusId, ListItemText As PatientStatus From ERS_Lists Where ListDescription='Patient Status' Union Select 0 As PatientStatusId, 'Unknow' As PatientStatus 
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_Priority', 'V';
GO

Create View [dbo].[fw_Priority] As
	Select 0 As PriorityId, '(none)' As [Priority] Union All
	Select 1 As PriorityId, 'Efective' As [Priority] Union All
	Select 2 As PriorityId, 'Open Access (GP referrals)' As [Priority] Union All
	Select 3 As PriorityId, 'Schedulled (surveillance/repeats)' As [Priority] Union All
	Select 4 As PriorityId, 'Emergency (unespecified)' As [Priority] Union All
	Select 5 As PriorityId, 'Emergency (in hrs)' As [Priority] Union All
	Select 6 As PriorityId, 'Emergency (out of hours)' As [Priority] Union All
	Select 7 As PriorityId, 'Urgent' As [Priority] Union All
	Select 8 As PriorityId, 'Unespecified' As [Priority] Union All
	Select 9 As PriorityId, '' As [Priority]
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_OperatingHospitals', 'V';
GO

Create View [dbo].[fw_OperatingHospitals] As
	Select OperatingHospitalId, HospitalName From ERS_OperatingHospitals
	Union All 
	Select OperatingHospitalId=0, HospitalName='*** Hospital not defined ***'
GO



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_NursesComfortScore', 'V';
GO

/* [dbo].[fw_NursesComfortScore] */
Create View [dbo].[fw_NursesComfortScore] As Select NursesAssPatComfortScore=0, NursesAssPatComfort='Not completed' Union All Select NursesAssPatComfortScore=1, NursesAssPatComfort='Not recorded' Union All Select NursesAssPatComfortScore=2, NursesAssPatComfort='None-resting comfortably throughout' Union All Select NursesAssPatComfortScore=3, NursesAssPatComfort='One or two episodes of mild discomfort, well tolerated' Union All Select NursesAssPatComfortScore=4, NursesAssPatComfort='Two episodes of discomfort, adequately tolerated' Union All Select NursesAssPatComfortScore=5, NursesAssPatComfort='Significant discomfort, experienced several times during procedure' Union All Select NursesAssPatComfortScore=6, NursesAssPatComfort='Extreme discomfort frequently during test' 
GO


---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_PatientsSedationScore', 'V';
GO

/* [dbo].[fw_PatientsSedationScore] */
Create View [dbo].[fw_PatientsSedationScore] As Select PatientsSedationScore=0, PatAssComfort='Not completed' Union All Select PatientsSedationScore=1, PatAssComfort='Not recorded' Union All Select PatientsSedationScore=2, PatAssComfort='No' Union All Select PatientsSedationScore=3, PatAssComfort='Minimal' Union All Select PatientsSedationScore=4, PatAssComfort='Mild' Union All Select PatientsSedationScore=5, PatAssComfort='Moderate' Union All Select PatientsSedationScore=6, PatAssComfort='Severe' 
GO


/* [dbo].[fw_Consultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Consultants]')) Drop View [dbo].[fw_Consultants]
GO




/* [dbo].[kfw_UGI_Episode] */





---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_E_Procedures', 'V';
GO

/* [dbo].[fw_UGI_E_Procedures] */
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_E_Procedures] As
Select 
	''U.2.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	, 2 As ProcedureTypeId
	, ''U'' As AppId
	, Convert(Date,E.[Episode date]) As CreatedOn
	, Convert(INT,SubString(E.[Patient No],7,6)) As PatientId
	, E.[Age at procedure] As Age
	, IsNull(PR.[Operating Hospital ID],0) As OperatingHospitalId
	, IsNull(PP_Priority,''Unspecified'') As PP_Priority
	, Case PP_PatStatus When ''Outpatient/NHS'' Then 2 When ''Inpatient/NHS'' Then 1 Else 0 End As PatientStatusId
	, Case When Replace(Replace(IsNull(PP_PatStatus,''''),''Outpatient/'',''''),''Inpatient/'','''')=''NHS'' Then 1 Else 2 End As PatientTypeId
	, PR.PP_Indic
	, PR.PP_Therapies
	, PR.DNA
From [dbo].[fw_UGI_Episode] E
LEFT OUTER JOIN [dbo].[ERCP Procedure] PR ON E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No]
Where SubString(E.[Status],2,1)=1
Union All
Select 
	''U.7.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	, 7 As ProcedureTypeId
	, ''U'' As AppId
	, Convert(Date,E.[Episode date]) As CreatedOn
	, Convert(INT,SubString(E.[Patient No],7,6)) As PatientId
	, E.[Age at procedure] As Age
	, IsNull(PR.[Operating Hospital ID],0) As OperatingHospitalId
	, IsNull(PP_Priority,''Unspecified'') As PP_Priority
	, Case PP_PatStatus When ''Outpatient/NHS'' Then 2 When ''Inpatient/NHS'' Then 1 Else 0 End As PatientStatusId
	, Case When Replace(Replace(IsNull(PP_PatStatus,''''),''Outpatient/'',''''),''Inpatient/'','''')=''NHS'' Then 1 Else 2 End As PatientTypeId
	, PR.PP_Indic
	, PR.PP_Therapies
	, PR.DNA
From [dbo].[fw_UGI_Episode] E
LEFT OUTER JOIN [dbo].[ERCP Procedure] PR ON E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No]
Where SubString(E.[Status],6,1)=1'
END

EXEC sp_executesql @sql
GO

---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_C_Procedures', 'V';
GO

/* [dbo].[fw_UGI_C_Procedures] */
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_C_Procedures] As
Select 
	''U.''+Convert(varchar(1),3+IsNull((Select Top 1 [Procedure type] From [dbo].[Colon procedure] CP Where CP.[Episode No]=E.[Episode No] And [Procedure type]<>2),0))+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	, 3+IsNull((Select Top 1 [Procedure type] From [dbo].[Colon procedure] CP Where CP.[Episode No]=E.[Episode No] And [Procedure type]<>2),0) As ProcedureTypeId
	, ''U'' As AppId
	, Convert(Date,E.[Episode date]) As CreatedOn
	, Convert(INT,SubString(E.[Patient No],7,6)) As PatientId
	, E.[Age at procedure] As Age
	, IsNull(PR.[Operating Hospital ID],0) As OperatingHospitalId
	, IsNull(PP_Priority,''Unspecified'') As PP_Priority
	, Case PP_PatStatus When ''Outpatient/NHS'' Then 2 When ''Inpatient/NHS'' Then 1 Else 0 End As PatientStatusId
	, Case When Replace(Replace(IsNull(PP_PatStatus,''''),''Outpatient/'',''''),''Inpatient/'','''')=''NHS'' Then 1 Else 2 End As PatientTypeId
	, PR.PP_Indic
	, PR.PP_Therapies
	, PR.DNA
From [dbo].[fw_UGI_Episode] E
LEFT OUTER JOIN [dbo].[Colon Procedure] PR ON E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No]
Where SubString(E.[Status],3,1)=1 And PR.[Procedure type]<>2
Union All 
Select 
	''U.5.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	, 5 As ProcedureTypeId
	, ''U'' As AppId
	, Convert(Date,E.[Episode date]) As CreatedOn
	, Convert(INT,SubString(E.[Patient No],7,6)) As PatientId
	, E.[Age at procedure] As Age
	, IsNull(PR.[Operating Hospital ID],0) As OperatingHospitalId
	, IsNull(PP_Priority,''Unspecified'') As PP_Priority
	, Case PP_PatStatus When ''Outpatient/NHS'' Then 2 When ''Inpatient/NHS'' Then 1 Else 0 End As PatientStatusId
	, Case When Replace(Replace(IsNull(PP_PatStatus,''''),''Outpatient/'',''''),''Inpatient/'','''')=''NHS'' Then 1 Else 2 End As PatientTypeId
	, PR.PP_Indic
	, PR.PP_Therapies
	, PR.DNA
From [dbo].[fw_UGI_Episode] E
LEFT OUTER JOIN [dbo].[Colon Procedure] PR ON E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No]
Where SubString(E.[Status],4,1)=1 And PR.[Procedure type]=2
Union All
Select 
	''U.6.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId
	, 6 As ProcedureTypeId
	, ''U'' As AppId
	, Convert(Date,E.[Episode date]) As CreatedOn
	, Convert(INT,SubString(E.[Patient No],7,6)) As PatientId
	, E.[Age at procedure] As Age
	, IsNull(PR.[Operating Hospital ID],0) As OperatingHospitalId
	, IsNull(PP_Priority,''Unspecified'') As PP_Priority
	, Case PP_PatStatus When ''Outpatient/NHS'' Then 2 When ''Inpatient/NHS'' Then 1 Else 0 End As PatientStatusId
	, Case When Replace(Replace(IsNull(PP_PatStatus,''''),''Outpatient/'',''''),''Inpatient/'','''')=''NHS'' Then 1 Else 2 End As PatientTypeId
	, PR.PP_Indic
	, PR.PP_Therapies
	, PR.DNA
From [dbo].[fw_UGI_Episode] E
LEFT OUTER JOIN [dbo].[Upper GI Procedure] PR ON E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No]
Where SubString(E.[Status],5,1)=1
'
END

EXEC sp_executesql @sql
GO




---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_UGI_Procedures', 'V';
GO


/* [dbo].[fw_UGI_Procedures] */
DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_UGI_Procedures] As Select * From [dbo].[fw_UGI_E_Procedures] Union All Select * From [dbo].[fw_UGI_C_Procedures] Union All Select * From [dbo].[fw_UGI_O_Procedures] 
'

EXEC sp_executesql @sql

END



---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
EXEC DropIfExist 'fw_ERS_Procedures', 'V';
GO


/* [dbo].[fw_ERS_Procedures] */
Create View [dbo].[fw_ERS_Procedures] As 
	Select 'E.'+Convert(Varchar(10),PR.ProcedureId) As ProcedureId , 
		   PR.ProcedureType As ProcedureTypeId ,
		   'E' As AppId , 
		   Convert(Date,CreatedOn) As CreatedOn , 
		   PR.PatientId As PatientId , 
		   Convert(int,PR.CreatedOn-CONVERT(DATETIME,P.DOB))/365 As Age , 
		   IsNull(PR.OperatingHospitalID,0) As OperatingHospitalId , 
		   IsNull(PP_Priority,'Unspecified') As PP_Priority , 
		   Case PP_PatStatus When 'Outpatient/NHS' Then 2 When 'Inpatient/NHS' Then 1 Else 0 End As PatientStatusId , 
		   Case When Replace(Replace(IsNull(PP_PatStatus,''),'Outpatient/',''),'Inpatient/','')='NHS' Then 1 Else 2 End As PatientTypeId , 
		   R.PP_Indic , 
		   R.PP_Therapies , 
		   PR.DNA 
From [dbo].[ERS_Procedures] PR, [dbo].[fw_Patients] P, [dbo].[ERS_ProceduresReporting] R
Where PR.PatientId=P.PatientId AND R.ProcedureId = PR.ProcedureId
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
EXEC DropIfExist 'fw_FailuresERCP', 'V';
GO

DECLARE @sql NVARCHAR(MAX) = ''
IF EXISTS(SELECT 1 FROM #variables v WHERE v.IncludeUGI = 1)
BEGIN
	SET @sql = '
Create View [dbo].[fw_FailuresERCP] As
SELECT * FROM fw_UGI_FailuresERCP
--UNION ALL 
--SELECT * FROM fw_ERS_FailuresERCP



/* [dbo].[fw_UGI_BowelPreparation] */
Create View [dbo].[fw_UGI_BowelPreparation] As Select ''U.''+Convert(varchar(1),3+IsNull((Select Top 1 [Procedure type] From [Colon procedure] CP Where CP.[Episode No]=E.[Episode No] And [Procedure type]<>2),0))+''.''+Convert(varchar(10),E.[Episode no])+''.''+Convert(varchar(10),Convert(INT,SubString(E.[Patient No],7,6))) As ProcedureId ,Convert(BIT,Case When BBPScore Is Null Then 0 Else 1 End) As BowelPrepSettings, Convert(BIT,Case IsNull(I.[Bowel preparation],0) When 0 Then 1 Else 0 End) As OnNoBowelPrep, L.[List item text] As Formulation, IsNull(I.[Bowel preparation],0) As OnFormulation, IsNull(I.BBPSRight,0) As OnRight, IsNull(I.BBPSTransverse,0) As OnTransverse, IsNull(I.BBPSLeft,0) As OnLeft, IsNull(I.BBPScore,0) As OnTotalScore, Case IsNull(I.[Bowel preparation],0) When 0 Then 1 Else 0 End As OffNoBowelPrep, IsNull(I.[Bowel preparation],0) As OffFormulation, Case IsNull(I.Quality,0) When 1 Then 1 Else 0 End As OffQualityGood, Case IsNull(I.Quality,0) When 2 Then 1 Else 0 End As OffQualitySatisfactory, Case IsNull(I.Quality,0) When 3 Then 1 Else 0 End As OffQualityPoor From dbo.[Colon Indications] I , dbo.Episode E , dbo.Lists L Where I.Quality Is Not Null And I.[Episode No]=E.[Episode No] And I.[Patient No]=E.[Patient No] And IsNull(I.[Bowel preparation],0)=L.[List item no] And L.[List description]=''Preparation'' And UPPER(L.[List item text]) <> ''(NONE SELECTED)'' 
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


--EXEC DropIfExist 'PAS_ImportPatient', 'S';
--GO

--CREATE PROCEDURE PAS_ImportPatient
--	@CNN NVARCHAR(50)=NULL
--	, @ServerName NVARCHAR(128)='ERS_PAS'
--	, @PASDatabase NVARCHAR(128)='PASData'
--	, @ProductID NVARCHAR(2)='GI'
--	, @LocationID NVARCHAR(4)='_ERS'
--AS
--BEGIN
--	SET NOCOUNT ON
--	DECLARE @sql NVARCHAR(MAX)
--	IF @CNN IS NULL
--	BEGIN
--		RAISERROR('Error at PAS_ImportPatient. No Case note No was indicated',11,1)
--	END
--	ELSE
--	BEGIN
--		Set @sql = 'Insert Into [dbo].[Patient] ([Surname],[Date of birth],[Case note no], [Product ID],[Forename],[NHS No], [Location ID], [Just downloaded], [District], Gender, [Post code], [GP Name], [GP Address], [GP referral flag], [Address], [Record created], [Ethnic origin], [Patient status 1], [Patient status 2], [Advocate required]) Select RTRIM(LTRIM(last_name)) As [Surname], SubString(dob,7,4)+''-''+SubString(dob,4,2)+''-''+SubString(dob,1,2) As [Date of birth], RTRIM(LTRIM(main_pat_id)) As [Case note no], '''+@ProductID+''' As [Product ID], RTRIM(LTRIM(first_name)) As [Forename], RTRIM(LTRIM(nhs_number)) As [NHS No], '''+@LocationID+''' As [Location ID], -1 As [Just downloaded], pat_addr3 As [District], UPPER(SubString(gender,1,1)) As Gender, postcode As [Post code], IsNull(gp_title+'' '','''')+isnull(gp_forename+'' '','''')+isnull(gp_surname,'''') [GP Name], IsNull(gp_addr1+'' '','''')+IsNull(gp_addr2+'' '','''')+IsNull(gp_addr3+'' '','''')+IsNull(gp_addr4+'' '','''')+IsNull(gp_postcode+'' '','''') As [GP Address], 0 As [GP referral flag], IsNull(gp_addr1+'' '','''')+IsNull(gp_addr2+'' '','''')+IsNull(gp_addr3+'' '','''')+IsNull(gp_addr4+'' '','''') As [Address], GetDate () As [Record created], -1 As [Ethnic origin], 0 As [Patient status 1], 0 As [Patient status 2], 0 As [Advocate required] From '+@ServerName+'.'+@PASDatabase+'.dbo.[PAS data] Where main_pat_id='''+@CNN+''''
--		BEGIN TRY
--			EXEC (@SQL)
--		END TRY
--		BEGIN CATCH
--			RAISERROR('Error at PAS_ImportPatient. The patient does exists',11,1)
--		END CATCH
--		Set @sql='UPDATE [dbo].[Patient] SET [Combo ID] = ''GI_ERS'' + Replicate(''0'',6-Len(CONVERT(VARCHAR(7),[Patient No])))+CONVERT(VARCHAR(7),[Patient No]) WHERE [Case note no]=''' + @CNN + ''''
--		EXEC (@SQL)
--		PRINT Convert(varchar(10),@@ROWCOUNT)+' rows updated'
--	END
--END
--GO
--IF @@ERROR <> 0 SET NOEXEC ON
--GO
--CREATE PROCEDURE [dbo].[PAS_LinkOn]
--	@ServerName NVARCHAR(128)='UMPT'
--	,@ServerHost NVARCHAR(128)='.'
--	,@IntegratedSecurity NVARCHAR='False'
--	,@PASDatabase NVARCHAR(128)='PASData'
--	,@PASUser NVARCHAR(128)=''
--	,@PASPassword NVARCHAR(128)=''
--As
--BEGIN
--	DECLARE @sql NVARCHAR(MAX)
--	IF (SELECT Convert(BIT,(SELECT Count(*) AS N FROM sys.servers WHERE name=@ServerName)) AS IsLinked)=1
--	BEGIN
--		PRINT 'The Virtual Server is still enabled'
--	END
--	ELSE
--	BEGIN
--		IF UPPER(@IntegratedSecurity)='TRUE'
--		BEGIN
--			SET @sql='EXEC sp_addlinkedserver @server='''+@ServerName+''', @srvproduct='''', @provider=''sqlncli'', @datasrc='''+@ServerHost+''', @location='', @provstr='', @catalog='''+@PASDatabase+''''
--			EXEC (@SQL)
--			SET @sql='EXEC sp_addlinkedsrvlogin @rmtsrvname = '''+@ServerName+''', @useself = ''false'', @useself=''TRUE'''
--		END
--		ELSE
--		BEGIN
--			SET @sql='EXEC sp_addlinkedserver @server='''+@ServerName+''', @srvproduct='''', @provider=''sqlncli'', @datasrc='''+@ServerHost+''', @location='', @provstr='', @catalog='''+@PASDatabase+''''
--			EXEC (@SQL)
--			SET @sql='EXEC sp_addlinkedsrvlogin @rmtsrvname = '''+@ServerName+''', @useself = ''false'', @rmtuser = '''+@PASUser+''', @rmtpassword = '''+@PASPassword+''''			
--		END
--	END
--END
--GO
--IF @@ERROR <> 0 SET NOEXEC ON
--GO
--CREATE PROCEDURE [dbo].[PAS_Replicate]
--	@PatientId INT
--	, @CNN NVARCHAR(50)
--	, @ServerName NVARCHAR(128)='ERS_PAS'
--	, @PASDatabase NVARCHAR(128)='PASData'
--	, @PASTable NVARCHAR(128)='[dbo].[PAS Data]'
--	, @ProductID NVARCHAR(2)='GI'
--	, @LocationID NVARCHAR(4)='_ERS'
--AS
--BEGIN
--	Declare @sql NVARCHAR(max)
--	Declare @ServerDB NVARCHAR(256)
--	Set @ServerDB=@ServerName+'.'+@PASDatabase+'.'+@PASTable
--	Set @sql='Update Patient Set [NHS No]=Q.nhs_number From '+@ServerDB+' Q Where [Case note no]=Q.main_pat_id And [NHS No]<>Q.nhs_number And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
--	Exec (@sql)
--	Set @sql='Update Patient Set [Surname]=Q.last_name From '+@ServerDB+' Q Where [Case note no]=Q.main_pat_id And [Surname]<>Q.last_name And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
--	Exec (@sql)
--	Set @sql='Update Patient Set [Date of birth]=Convert(datetime,SubString(dob,7,4)+''-''+SubString(dob,4,2)+''-''+SubString(dob,1,2)) Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And Convert(date,[Date of birth])<>Convert(date,SubString(dob,7,4)+''-''+SubString(dob,4,2)+''-''+SubString(dob,1,2)) And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
--	Exec (@sql)
--	Set @sql='Update Patient Set Forename=Q.first_name Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And Forename<>Q.first_name And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
--	Exec (@sql)
--	Set @sql='Update Patient Set District=Q.pat_addr2 Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And District<>Q.pat_addr2 And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
--	Exec (@sql)
--	Set @sql='Update Patient Set Patient.Gender=UPPER(SubString(Q.gender,1,1)) Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And Patient.Gender<>UPPER(SubString(Q.gender,1,1)) And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
--	Exec (@sql)
--	Set @sql='Update Patient Set [Address]=Q.pat_addr1 Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And [Address]<>Q.pat_addr1 And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
--	Exec (@sql)
--	Set @sql='Update Patient Set [Post code]=UPPER(Q.postcode) Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And [Post code]<>UPPER(Q.postcode) And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
--	Exec (@sql)
--	Set @sql='Update Patient Set [GP Name]=IsNull(Q.gp_title,'''')+IsNull('' ''+Q.gp_forename,'''')+IsNull('' ''+Q.gp_surname,'''') Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And [GP Name]<>IsNull(Q.gp_title,'''')+IsNull('' ''+Q.gp_forename,'''')+IsNull('' ''+Q.gp_surname,'''') And Q.gp_surname Is Not Null And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
--	Exec (@sql)
--	Set @sql='Update Patient Set [Date of death]=Convert(datetime,SubString(Q.date_of_death,7,4)+''-''+SubString(Q.date_of_death,4,2)+''-''+SubString(Q.date_of_death,1,2)) Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And Convert(date,[Date of birth])<>Convert(date,SubString(Q.date_of_death,7,4)+''-''+SubString(Q.date_of_death,4,2)+''-''+SubString(Q.date_of_death,1,2)) And Q.date_of_death Is Not Null And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
--	Exec (@sql)
--	Set @sql='Update Patient Set [Phone No]=Q.homephone Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And [Phone No]<>Q.homephone And Q.homephone Is Not Null And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
--	Exec (@sql)
--	Set @sql='Update Patient Set [GP Address]=Q.gp_addr1 Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And [GP Address]<>Q.gp_addr1 And Q.gp_addr1 Is Not Null And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
--	Exec (@sql)
--END
--GO
--IF @@ERROR <> 0 SET NOEXEC ON
--GO
--CREATE PROCEDURE PAS_UpdatePatient
--	@CNN NVARCHAR(50)
--	, @PatientId NVARCHAR(50)=''
--	, @ServerName NVARCHAR(128)='ERS_PAS'
--	, @PASDatabase NVARCHAR(128)='PASData'
--	, @ProductID NVARCHAR(2)='GI'
--	, @LocationID NVARCHAR(4)='_ERS'
--AS
--BEGIN
--	SET NOCOUNT ON
--	DECLARE @sql NVARCHAR(MAX)
--	--Set @sql = 'Insert Into [dbo].[Patient] ([Surname],[Date of birth],[Case note no], [Product ID],[Forename],[NHS No], [Location ID], [Just downloaded], [District], Gender, [Post code], [GP Name], [GP Address], [GP referral flag], [Address], [Record created], [Ethnic origin], [Patient status 1], [Patient status 2], [Advocate required]) Select RTRIM(LTRIM(last_name)) As [Surname], SubString(dob,7,4)+''-''+SubString(dob,4,2)+''-''+SubString(dob,1,2) As [Date of birth], RTRIM(LTRIM(main_pat_id)) As [Case note no], '''+@ProductID+''' As [Product ID], RTRIM(LTRIM(first_name)) As [Forename], RTRIM(LTRIM(nhs_number)) As [NHS No], '''+@LocationID+''' As [Location ID], -1 As [Just downloaded], pat_addr3 As [District], UPPER(SubString(gender,1,1)) As Gender, postcode As [Post code], IsNull(gp_title+'' '','''')+isnull(gp_forename+'' '','''')+isnull(gp_surname,'''') [GP Name], IsNull(gp_addr1+'' '','''')+IsNull(gp_addr2+'' '','''')+IsNull(gp_addr3+'' '','''')+IsNull(gp_addr4+'' '','''')+IsNull(gp_postcode+'' '','''') As [GP Address], 0 As [GP referral flag], IsNull(gp_addr1+'' '','''')+IsNull(gp_addr2+'' '','''')+IsNull(gp_addr3+'' '','''')+IsNull(gp_addr4+'' '','''') As [Address], GetDate () As [Record created], -1 As [Ethnic origin], 0 As [Patient status 1], 0 As [Patient status 2], 0 As [Advocate required] From '+@ServerName+'.'+@PASDatabase+'.dbo.[PAS data] Where main_pat_id='''+@CNN+''''
--	Set @sql='Update [dbo].[Patient] Set [Surname]=RTRIM(LTRIM(last_name))'
--	Set @sql=@sql+' ,[Date of birth]=SubString(dob,7,4)+''-''+SubString(dob,4,2)+''-''+SubString(dob,1,2)'
--	Set @sql=@sql+' ,[Forename]=RTRIM(LTRIM(first_name))'
--	Set @sql=@sql+' , [District]=pat_addr3'
--	Set @sql=@sql+' , Gender=IsNull(UPPER(SubString(U.gender,1,1)),'''')'
--	Set @sql=@sql+' , [Post code]=postcode'
--	Set @sql=@sql+' , [GP Name]=IsNull(gp_title+'' '','''')+isnull(gp_forename+'' '','''')+isnull(gp_surname,'''')'
--	Set @sql=@sql+' , [GP Address]=IsNull(gp_addr1+'' '','''')+IsNull(gp_addr2+'' '','''')+IsNull(gp_addr3+'' '','''')+IsNull(gp_addr4+'' '','''')'
--	Set @sql=@sql+' , [Address]=IsNull(pat_addr1+'' '','''')+IsNull(pat_addr2+'' '','''')+IsNull(pat_addr3+'' '','''')+IsNull(pat_addr4+'' '','''')'
--	Set @sql=@sql+' From '+@ServerName+'.'+@PASDatabase+'.dbo.[PAS data] U Where [Case note no]=main_pat_id And main_pat_id='''+@CNN+''''
--	If @PatientId<>'' Set @sql=@sql+' And [Patient No]='+@PatientId
--	PRINT @sql
--	BEGIN TRY
--		EXEC (@sql)
--	END TRY
--	BEGIN CATCH
--		RAISERROR('Error at PAS_UpdatePatient.',11,1)
--		PRINT @sql
--	END CATCH
--	PRINT Convert(varchar(10),@@ROWCOUNT)+' rows updated'
--END
--GO
--IF @@ERROR <> 0 SET NOEXEC ON
--
--GO




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

--EXEC DropIfExist 'report_ListAnalysis1', 'S';
--GO

--Create Proc [dbo].[report_ListAnalysis1] 
--	@UserID INT=NULL
--	, @FromAge INT=NULL
--	, @ToAge INT=NULL
--	, @IncludeTherapeutics BIT=NULL
--	, @IncludeIndications BIT=NULL
--	, @RadioButtonNHS VARCHAR(3)=NULL
--	, @DailyTotalsConsultant BIT=NULL
--	, @DailyTotals BIT=NULL
--	, @GrandTotal BIT=NULL
--	--, @DNA BIT=NULL
--	, @OrderBy VARCHAR(4)='ASC'
--	, @PatientStatusId INT=NULL
--	, @PatientTypeId INT=NULL
--	As
--Begin
--	Set NoCount On
--	Declare @Anonymised BIT
--	Declare @Randomize BIT
--	Declare @Suppressed BIT
--	Declare @Scope VARCHAR(255)
--	Declare @ConsultantTypeId INT
--	Declare @FromDate Date
--	Declare @ToDate Date
--	Declare @N INT
--	If Exists (Select * From ERS_ReportConsultants Where UserID=@UserID)
--	Begin
--		Select @Anonymised=Anonymise, @Randomize=Anonymise, @Suppressed=HideSuppressed, @ConsultantTypeId=TypesOfEndoscopists, @FromDate=FromDate, @ToDate=ToDate FROM ERS_ReportFilter Where @UserID=@UserID
--		If @Randomize=1 Exec [dbo].[report_Anonimize] @UserID=@UserID, @Randomize=@Randomize
--		Declare @MinDate Date
--		Declare @MaxDate Date
--		Select @MinDate=Min(CreatedOn), @MaxDate=Max(CreatedOn) From fw_Procedures
--		Set @Scope='Covering:'
--		Set @Scope=@Scope+Case When @MinDate<@FromDate Then ' from '+Convert(varchar(2),datepart(dd,@FromDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
--		Set @Scope=@Scope+Case When @MaxDate>@ToDate Then ' to '+Convert(varchar(2),datepart(dd,@ToDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
--		If @ConsultantTypeId=1 Select @N=Count(*) From fw_Consultants Where IsEndoscopist1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--		If @ConsultantTypeId=2 Select @N=Count(*) From fw_Consultants Where IsEndoscopist2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--		If @ConsultantTypeId=3 Select @N=Count(*) From fw_Consultants Where IsListConsultant=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--		If @ConsultantTypeId=4 Select @N=Count(*) From fw_Consultants Where IsAssistantOrTrainee=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--		If @ConsultantTypeId=5 Select @N=Count(*) From fw_Consultants Where IsNurse1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--		If @ConsultantTypeId=6 Select @N=Count(*) From fw_Consultants Where IsNurse2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--		Set @Scope=@Scope+Case When @N=0 Then ', All consultants' Else ', selected consultants' End
--		Set @Scope=@Scope+Case When IsNull(@FromAge,0)=0 Then '' Else ', older than '+Convert(varchar(10),@FromAge)+' years old ' End
--		Set @Scope=@Scope+Case When @ToAge Is Null Then '' Else Case When @ToAge<200 Then ', younger than '+Convert(varchar(10),@ToAge)+' years old ' Else '' End End
--		Select 
--			Case @OrderBy When 'ASC' Then 1.0*Convert(int,Convert(DateTime,PR.CreatedOn)) Else 1.0/Convert(int,Convert(DateTime,PR.CreatedOn)) End As OrderBy
--			,DATENAME(weekday, PR.CreatedOn)+' '+Convert(varchar(2),Datepart(dd,PR.CreatedOn))+Case Datepart(dd,PR.CreatedOn) When 1 Then 'rd' When 2 Then 'nd' When 3 Then 'rd' Else 'th' End+' '+DATENAME(month,PR.CreatedOn)+' '+DATENAME(year,PR.CreatedOn) As ProcDay
--			, PR.ProcedureId
--			, CT.ConsultantType
--			--, Case When @Anonymised=1 Then 'Anonymised consultant No '+Convert(varchar(10),RC.AnonimizedID) Else C.ConsultantName End As ConsultantName Uncomment to anonymise consultants
--			, C.ConsultantName --Comment this line if you comment the previous line
--			, Case When SubString(ConsultantType,1,11)='Endoscopist' Then
--					(Select CC.ConsultantName From fw_ProceduresConsultants PCC INNER JOIN fw_Consultants CC ON PCC.ConsultantId=CC.ConsultantId And PCC.ProcedureId=PR.ProcedureId WHERE PCC.ConsultantTypeId=3)
--				Else
--					(Select CC.ConsultantName From fw_ProceduresConsultants PCC INNER JOIN fw_Consultants CC ON PCC.ConsultantId=CC.ConsultantId And PCC.ProcedureId=PR.ProcedureId WHERE PCC.ConsultantTypeId=1)
--				End As Assistant
--			, Case When @Anonymised=1 Then 'Anonymised patient' Else P.PatientName End+' ('+Convert(varchar(3),PR.Age)+')' As PatientName, Case When @RadioButtonNHS='CNN' Then P.CNN Else P.NHSNo End As PatientId
--			, Case When PT.ProcedureTypeId=1 Then 1 Else 0 End As OGD
--			, Case When PT.ProcedureTypeId=6 Then 1 Else 0 End As EUS
--			, Case When PT.ProcedureTypeId=2 Then 1 Else 0 End As ERC
--			, Case When PT.ProcedureTypeId=7 Then 1 Else 0 End As HPB
--			, Case When PT.ProcedureTypeId=3 Then 1 Else 0 End As COL
--			, Case When PT.ProcedureTypeId=4 Then 1 Else 0 End As SIG
--			, Case When PT.ProcedureTypeId=5 Then 1 Else 0 End As PRO
--			, Case When @IncludeIndications=1 Then PR.PP_Indic Else '' End As PP_Indic
--			, Case When @IncludeTherapeutics=1 Then PR.PP_Therapies Else '' End As PP_Therapies
--			, @Scope As Scope
--	From fw_Procedures PR
--		INNER JOIN fw_ProceduresTypes PT ON PR.ProcedureTypeId=PT.ProcedureTypeId
--		INNER JOIN fw_ProceduresConsultants PC ON PR.ProcedureId=PC.ProcedureId
--		INNER JOIN fw_Consultants C ON PC.ConsultantId=C.ConsultantId
--		INNER JOIN fw_ConsultantTypes CT ON PC.ConsultantTypeId=CT.ConsultantTypeId
--		INNER JOIN fw_Patients P ON PR.PatientId=P.PatientId
--		INNER JOIN fw_ReportConsultants RC ON C.ConsultantId=RC.ConsultantId
--		INNER JOIN fw_ReportFilter RF ON RC.UserId=RF.UserId
--	Where PC.ConsultantTypeId=RF.TypesOfEndoscopists 
--			And PR.PatientStatusId=IsNull(@PatientStatusId,PR.PatientStatusId)
--			And PR.PatientTypeId=IsNull(@PatientTypeId,PR.PatientTypeId)
--			And PR.ProcedureTypeId In (1,2,3,4,5,6) -- Change that line to incliude more procedure types
--			And RF.UserId=@UserID And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate And PR.Age>=IsNull(@FromAge,0) And PR.Age<=IsNull(@ToAge,200)
--		Order By 1, C.ConsultantName
--	End
--End
--GO


--EXEC DropIfExist 'report_ListAnalysis2', 'S';
--GO

--Create Proc [dbo].[report_ListAnalysis2] 
--	@UserID INT=NULL
--	, @FromAge INT=NULL
--	, @ToAge INT=NULL
--	, @DiagVsThera BIT=NULL
--	, @DNA BIT=NULL
--	, @Priority BIT=NULL
--	, @PatientStatusId INT=NULL
--	, @PatientTypeId INT=NULL
--	As
--Begin
--	Set NoCount On
--	Declare @Anonymised BIT
--	Declare @Randomize BIT
--	Declare @Suppressed BIT
--	Declare @Scope VARCHAR(255)
--	Declare @ConsultantTypeId INT
--	Declare @FromDate Date
--	Declare @ToDate Date
--	Declare @N INT
--	If Exists (Select * From ERS_ReportConsultants Where UserID=@UserID)
--	Begin
--	Select @Anonymised=Anonymise, @Randomize=Anonymise, @Suppressed=HideSuppressed, @ConsultantTypeId=TypesOfEndoscopists, @FromDate=FromDate, @ToDate=ToDate FROM ERS_ReportFilter Where @UserID=@UserID
--	If @Randomize=1 Exec [dbo].[report_Anonimize] @UserID=@UserID, @Randomize=@Randomize
--	Declare @MinDate Date
--	Declare @MaxDate Date
--	Select @MinDate=Min(CreatedOn), @MaxDate=Max(CreatedOn) From fw_Procedures
--	Set @Scope='Covering:'
--	Set @Scope=@Scope+Case When @MinDate<@FromDate Then ' from '+Convert(varchar(2),datepart(dd,@FromDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
--	Set @Scope=@Scope+Case When @MaxDate>@ToDate Then ' to '+Convert(varchar(2),datepart(dd,@ToDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
--	If @ConsultantTypeId=1 Select @N=Count(*) From fw_Consultants Where IsEndoscopist1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=2 Select @N=Count(*) From fw_Consultants Where IsEndoscopist2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=3 Select @N=Count(*) From fw_Consultants Where IsListConsultant=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=4 Select @N=Count(*) From fw_Consultants Where IsAssistantOrTrainee=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=5 Select @N=Count(*) From fw_Consultants Where IsNurse1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=6 Select @N=Count(*) From fw_Consultants Where IsNurse2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	Set @Scope=@Scope+Case When @N=0 Then ', All consultants' Else ', selected consultants' End
--	Set @Scope=@Scope+Case When IsNull(@FromAge,0)=0 Then '' Else ', older than '+Convert(varchar(10),@FromAge)+' years old ' End
--	Set @Scope=@Scope+Case When @ToAge Is Null Then '' Else Case When @ToAge<200 Then ', younger than '+Convert(varchar(10),@ToAge)+' years old ' Else '' End End
--	--If @DiagVsThera=1
--	--Begin
--		Select 
--			CT.ConsultantType
--			--, Case When @Anonymised=1 Then 'Anonymised consultant No '+Convert(varchar(10),RC.AnonimizedID) Else C.ConsultantName End As ConsultantName Uncomment to anonymise consultants
--			, C.ConsultantName --Comment this line if you comment the previous line
--			, 'Diagnostic' As DiagVsThera
--			, @Scope As Scope
--			, IsNull(Sum(Case When PT.ProcedureTypeId=1 Then 1 Else 0 End),0) As OGD
--			, IsNull(Sum(Case When PT.ProcedureTypeId=6 Then 1 Else 0 End),0) As EUS
--			, IsNull(Sum(Case When PT.ProcedureTypeId=2 Then 1 Else 0 End),0) As ERC
--			, IsNull(Sum(Case When PT.ProcedureTypeId=7 Then 1 Else 0 End),0) As HPB
--			, IsNull(Sum(Case When PT.ProcedureTypeId=3 Then 1 Else 0 End),0) As COL
--			, IsNull(Sum(Case When PT.ProcedureTypeId=4 Then 1 Else 0 End),0) As SIG
--			, IsNull(Sum(Case When PT.ProcedureTypeId=5 Then 1 Else 0 End),0) As PRO
--		From fw_Procedures PR
--			INNER JOIN fw_ProceduresTypes PT ON PR.ProcedureTypeId=PT.ProcedureTypeId
--			INNER JOIN fw_ProceduresConsultants PC ON PR.ProcedureId=PC.ProcedureId
--			INNER JOIN fw_Consultants C ON C.ConsultantId=PC.ConsultantId
--			INNER JOIN fw_ConsultantTypes CT ON PC.ConsultantTypeId=CT.ConsultantTypeId
--			INNER JOIN fw_ReportFilter RF ON PC.ConsultantTypeId=RF.TypesOfEndoscopists
--			INNER JOIN fw_ReportConsultants RC ON C.ConsultantId=RC.ConsultantId
--			INNER JOIN fw_Patients P ON P.PatientId=PR.PatientId
--		Where RF.UserId=@UserID And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate And PR.Age>=IsNull(@FromAge,0) And PR.Age<=IsNull(@ToAge,200)
--			And PR.ProcedureTypeId In (1,2,3,4,5,6) -- Change that line to incliude more procedure types
--			And PR.PP_Indic Is Not Null
--			And PR.PatientStatusId=IsNull(@PatientStatusId,PR.PatientStatusId)
--			And PR.PatientTypeId=IsNull(@PatientTypeId,PR.PatientTypeId)
--		Group By CT.ConsultantType, C.ConsultantName
--		Union All
--		Select 
--			CT.ConsultantType
--			--, Case When @Anonymised=1 Then 'Anonymised consultant No '+Convert(varchar(10),RC.AnonimizedID) Else C.ConsultantName End As ConsultantName Uncomment to anonymise consultants
--			, C.ConsultantName --Comment this line if you comment the previous line
--			, 'Therapeutic' As DiagVsThera
--			, @Scope As Scope
--			, IsNull(Sum(Case When PT.ProcedureTypeId=1 Then 1 Else 0 End),0) As OGD
--			, IsNull(Sum(Case When PT.ProcedureTypeId=6 Then 1 Else 0 End),0) As EUS
--			, IsNull(Sum(Case When PT.ProcedureTypeId=2 Then 1 Else 0 End),0) As ERC
--			, IsNull(Sum(Case When PT.ProcedureTypeId=7 Then 1 Else 0 End),0) As HPB
--			, IsNull(Sum(Case When PT.ProcedureTypeId=3 Then 1 Else 0 End),0) As COL
--			, IsNull(Sum(Case When PT.ProcedureTypeId=4 Then 1 Else 0 End),0) As SIG
--			, IsNull(Sum(Case When PT.ProcedureTypeId=5 Then 1 Else 0 End),0) As PRO
--		From fw_Procedures PR
--			INNER JOIN fw_ProceduresTypes PT ON PR.ProcedureTypeId=PT.ProcedureTypeId
--			INNER JOIN fw_ProceduresConsultants PC ON PR.ProcedureId=PC.ProcedureId
--			INNER JOIN fw_Consultants C ON PC.ConsultantId=C.ConsultantId
--			INNER JOIN fw_ReportConsultants RC ON C.ConsultantId=RC.ConsultantId
--			INNER JOIN fw_ReportFilter RF ON RF.UserId=RC.UserId
--			INNER JOIN fw_ConsultantTypes CT ON PC.ConsultantTypeId=RF.TypesOfEndoscopists
--			INNER JOIN fw_Patients P ON P.PatientId=PR.PatientId
--		Where PC.ConsultantTypeId=CT.ConsultantTypeId 
--			And RF.UserId=@UserID And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate And PR.Age>=IsNull(@FromAge,0) And PR.Age<=IsNull(@ToAge,200)
--			And PR.ProcedureTypeId In (1,2,3,4,5,6) -- Change that line to incliude more procedure types
--			And PR.PP_Therapies Is Not Null
--			And PR.PatientStatusId=IsNull(@PatientStatusId,PR.PatientStatusId)
--			And PR.PatientTypeId=IsNull(@PatientTypeId,PR.PatientTypeId)
--		Group By CT.ConsultantType, C.ConsultantName
--		Order By 1, C.ConsultantName
--	End
--End
--GO


--EXEC DropIfExist 'report_ListAnalysis3', 'S';
--GO

--Create Proc [dbo].[report_ListAnalysis3] 
--	@UserID INT=NULL
--	, @FromAge INT=NULL
--	, @ToAge INT=NULL
--	, @PatientStatusId INT=NULL
--	, @PatientTypeId INT=NULL
--	As
--Begin
--	Set NoCount On
--	Declare @Anonymised BIT
--	Declare @Randomize BIT
--	Declare @Suppressed BIT
--	Declare @Scope VARCHAR(255)
--	Declare @ConsultantTypeId INT
--	Declare @FromDate Date
--	Declare @ToDate Date
--	Declare @N INT
--	If Exists (Select * From ERS_ReportConsultants Where UserID=@UserID)
--	Begin
--	Select @Anonymised=Anonymise, @Randomize=Anonymise, @Suppressed=HideSuppressed, @ConsultantTypeId=TypesOfEndoscopists, @FromDate=FromDate, @ToDate=ToDate FROM ERS_ReportFilter Where @UserID=@UserID
--	If @Randomize=1 Exec [dbo].[report_Anonimize] @UserID=@UserID, @Randomize=@Randomize
--	Declare @MinDate Date
--	Declare @MaxDate Date
--	Select @MinDate=Min(CreatedOn), @MaxDate=Max(CreatedOn) From fw_Procedures
--	Set @Scope='Covering:'
--	Set @Scope=@Scope+Case When @MinDate<@FromDate Then ' from '+Convert(varchar(2),datepart(dd,@FromDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
--	Set @Scope=@Scope+Case When @MaxDate>@ToDate Then ' to '+Convert(varchar(2),datepart(dd,@ToDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
--	If @ConsultantTypeId=1 Select @N=Count(*) From fw_Consultants Where IsEndoscopist1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=2 Select @N=Count(*) From fw_Consultants Where IsEndoscopist2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=3 Select @N=Count(*) From fw_Consultants Where IsListConsultant=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=4 Select @N=Count(*) From fw_Consultants Where IsAssistantOrTrainee=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=5 Select @N=Count(*) From fw_Consultants Where IsNurse1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=6 Select @N=Count(*) From fw_Consultants Where IsNurse2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	Set @Scope=@Scope+Case When @N=0 Then ', All consultants' Else ', selected consultants' End
--	Set @Scope=@Scope+Case When IsNull(@FromAge,0)=0 Then '' Else ', older than '+Convert(varchar(10),@FromAge)+' years old ' End
--	Set @Scope=@Scope+Case When @ToAge Is Null Then '' Else Case When @ToAge<200 Then ', younger than '+Convert(varchar(10),@ToAge)+' years old ' Else '' End End
--	Select 
--		PR.PP_Priority
--		, CT.ConsultantType
--		, @Scope As Scope
--		, IsNull(Sum(Case When PT.ProcedureTypeId=1 Then 1 Else 0 End),0) As OGD
--		, IsNull(Sum(Case When PT.ProcedureTypeId=6 Then 1 Else 0 End),0) As EUS
--		, IsNull(Sum(Case When PT.ProcedureTypeId=2 Then 1 Else 0 End),0) As ERC
--		, IsNull(Sum(Case When PT.ProcedureTypeId=7 Then 1 Else 0 End),0) As HPB
--		, IsNull(Sum(Case When PT.ProcedureTypeId=3 Then 1 Else 0 End),0) As COL
--		, IsNull(Sum(Case When PT.ProcedureTypeId=4 Then 1 Else 0 End),0) As SIG
--		, IsNull(Sum(Case When PT.ProcedureTypeId=5 Then 1 Else 0 End),0) As PRO
--	From fw_Procedures PR
--		INNER JOIN fw_ProceduresTypes PT ON PR.ProcedureTypeId=PT.ProcedureTypeId
--		INNER JOIN fw_ProceduresConsultants PC ON PR.ProcedureId=PC.ProcedureId
--		INNER JOIN fw_Consultants C ON C.ConsultantId=PC.ConsultantId
--		INNER JOIN fw_ConsultantTypes CT ON PC.ConsultantTypeId=CT.ConsultantTypeId
--		INNER JOIN fw_ReportConsultants RC ON C.ConsultantId=RC.ConsultantId
--		INNER JOIN fw_ReportFilter RF ON PC.ConsultantTypeId=RF.TypesOfEndoscopists
--		INNER JOIN fw_Patients P ON P.PatientId=PR.PatientId
--	Where RF.UserId=RC.UserId 
--		And RF.UserId=@UserID And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate And PR.Age>=IsNull(@FromAge,0) And PR.Age<=IsNull(@ToAge,200)
--		And PR.ProcedureTypeId In (1,2,3,4,5,6) -- Change that line to incliude more procedure types
--		And PR.PatientStatusId=IsNull(@PatientStatusId,PR.PatientStatusId)
--		And PR.PatientTypeId=IsNull(@PatientTypeId,PR.PatientTypeId)
--	Group By 
--		PR.PP_Priority
--		, CT.ConsultantType
--	End
--End
--GO


--EXEC DropIfExist 'report_ListAnalysis4', 'S';
--GO

--Create Proc [dbo].[report_ListAnalysis4]
--	@UserID INT=NULL
--	, @FromAge INT=NULL
--	, @ToAge INT=NULL
--	, @PatientStatusId INT=NULL
--	, @PatientTypeId INT=NULL
--	As
--Begin
--	Set NoCount On
--	Declare @Anonymised BIT
--	Declare @Randomize BIT
--	Declare @Suppressed BIT
--	Declare @Scope VARCHAR(255)
--	Declare @ConsultantTypeId INT
--	Declare @FromDate Date
--	Declare @ToDate Date
--	Declare @N INT
--	If Exists (Select * From ERS_ReportConsultants Where UserID=@UserID)
--	Begin
--	Select @Anonymised=Anonymise, @Randomize=Anonymise, @Suppressed=HideSuppressed, @ConsultantTypeId=TypesOfEndoscopists, @FromDate=FromDate, @ToDate=ToDate FROM ERS_ReportFilter Where @UserID=@UserID
--	If @Randomize=1 Exec [dbo].[report_Anonimize] @UserID=@UserID, @Randomize=@Randomize
--	Declare @MinDate Date
--	Declare @MaxDate Date
--	Select @MinDate=Min(CreatedOn), @MaxDate=Max(CreatedOn) From fw_Procedures
--	Set @Scope='Covering:'
--	Set @Scope=@Scope+Case When @MinDate<@FromDate Then ' from '+Convert(varchar(2),datepart(dd,@FromDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
--	Set @Scope=@Scope+Case When @MaxDate>@ToDate Then ' to '+Convert(varchar(2),datepart(dd,@ToDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
--	If @ConsultantTypeId=1 Select @N=Count(*) From fw_Consultants Where IsEndoscopist1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=2 Select @N=Count(*) From fw_Consultants Where IsEndoscopist2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=3 Select @N=Count(*) From fw_Consultants Where IsListConsultant=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=4 Select @N=Count(*) From fw_Consultants Where IsAssistantOrTrainee=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=5 Select @N=Count(*) From fw_Consultants Where IsNurse1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=6 Select @N=Count(*) From fw_Consultants Where IsNurse2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	Set @Scope=@Scope+Case When @N=0 Then ', All consultants' Else ', selected consultants' End
--	Set @Scope=@Scope+Case When IsNull(@FromAge,0)=0 Then '' Else ', older than '+Convert(varchar(10),@FromAge)+' years old ' End
--	Set @Scope=@Scope+Case When @ToAge Is Null Then '' Else Case When @ToAge<200 Then ', younger than '+Convert(varchar(10),@ToAge)+' years old ' Else '' End End
--	Select 
--		 CT.ConsultantType
--		, C.ConsultantName
--		, @Scope As Scope
--		, IsNull(Sum(Case When PT.ProcedureTypeId=1 Then 1 Else 0 End),0) As OGD
--		, IsNull(Sum(Case When PT.ProcedureTypeId=6 Then 1 Else 0 End),0) As EUS
--		, IsNull(Sum(Case When PT.ProcedureTypeId=2 Then 1 Else 0 End),0) As ERC
--		, IsNull(Sum(Case When PT.ProcedureTypeId=7 Then 1 Else 0 End),0) As HPB
--		, IsNull(Sum(Case When PT.ProcedureTypeId=3 Then 1 Else 0 End),0) As COL
--		, IsNull(Sum(Case When PT.ProcedureTypeId=4 Then 1 Else 0 End),0) As SIG
--		, IsNull(Sum(Case When PT.ProcedureTypeId=5 Then 1 Else 0 End),0) As PRO
--	From fw_Procedures PR
--		INNER JOIN fw_ProceduresTypes PT ON PR.ProcedureTypeId=PT.ProcedureTypeId
--		INNER JOIN fw_ProceduresConsultants PC ON PR.ProcedureId=PC.ProcedureId
--		INNER JOIN fw_Consultants C ON C.ConsultantId=PC.ConsultantId
--		INNER JOIN fw_ConsultantTypes CT ON PC.ConsultantTypeId=CT.ConsultantTypeId
--		INNER JOIN fw_ReportFilter RF ON PC.ConsultantTypeId=RF.TypesOfEndoscopists
--		INNER JOIN fw_ReportConsultants RC ON C.ConsultantId=RC.ConsultantId
--		INNER JOIN fw_Patients P ON P.PatientId=PR.PatientId
--	Where RF.UserId=RC.UserId
--		And RF.UserId=@UserID And PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate And PR.Age>=IsNull(@FromAge,0) And PR.Age<=IsNull(@ToAge,200)
--		And PR.ProcedureTypeId In (1,2,3,4,5,6) -- Change that line to include more procedure types
--		And PR.PatientStatusId=IsNull(@PatientStatusId,PR.PatientStatusId)
--		And PR.PatientTypeId=IsNull(@PatientTypeId,PR.PatientTypeId)
--	Group By 
--		C.ConsultantName
--		, CT.ConsultantType
--	End
--End
--GO



--EXEC DropIfExist 'report_ListAnalysis5', 'P';
--GO

--Create Proc [dbo].[report_ListAnalysis5]
--	@UserID INT=NULL
--	, @FromAge INT=NULL
--	, @ToAge INT=NULL
--	, @PatientStatusId INT=NULL
--	, @PatientTypeId INT=NULL
--	As
--Begin
--	Set NoCount On
--	Declare @Anonymised BIT
--	Declare @Randomize BIT
--	Declare @Suppressed BIT
--	Declare @Scope VARCHAR(255)
--	Declare @ConsultantTypeId INT
--	Declare @FromDate Date
--	Declare @ToDate Date
--	Declare @N INT
--	Declare @ConsultantType NVARCHAR(128)
--	If Exists (Select UserID From ERS_ReportConsultants Where UserID=@UserID)
--	Begin
--	Select @Anonymised=Anonymise, @Randomize=Anonymise, @Suppressed=HideSuppressed, @ConsultantTypeId=TypesOfEndoscopists, @FromDate=FromDate, @ToDate=ToDate FROM ERS_ReportFilter Where @UserID=@UserID
--	If @Randomize=1 Exec [dbo].[report_Anonimize] @UserID=@UserID, @Randomize=@Randomize
--	Declare @MinDate Date
--	Declare @MaxDate Date
--	Select @MinDate=Min(CreatedOn), @MaxDate=Max(CreatedOn) From fw_Procedures
--	Set @Scope='Covering:'
--	Set @Scope=@Scope+Case When @MinDate<@FromDate Then ' from '+Convert(varchar(2),datepart(dd,@FromDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
--	Set @Scope=@Scope+Case When @MaxDate>@ToDate Then ' to '+Convert(varchar(2),datepart(dd,@ToDate))+'/'+Convert(varchar(2),datepart(mm,@FromDate))+'/'+Convert(varchar(4),datepart(yy,@FromDate)) Else '' End
--	If @ConsultantTypeId=1 Set @ConsultantType='Endoscopist 1'--Select @N=Count(*) From fw_Consultants Where IsEndoscopist1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=2 Set @ConsultantType='Endoscopist 2'--Select @N=Count(*) From fw_Consultants Where IsEndoscopist2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=3 Set @ConsultantType='List Consultant'--Select @N=Count(*) From fw_Consultants Where IsListConsultant=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=4 Set @ConsultantType='Assistant'--Select @N=Count(*) From fw_Consultants Where IsAssistantOrTrainee=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=5 Set @ConsultantType='Nurse 1'--Select @N=Count(*) From fw_Consultants Where IsNurse1=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	If @ConsultantTypeId=6 Set @ConsultantType='Nurse 2'--Select @N=Count(*) From fw_Consultants Where IsNurse2=1 And ConsultantId Not In (Select ConsultantId From fw_ReportConsultants)
--	Set @Scope=@Scope+Case When @N=0 Then ', All consultants' Else ', selected consultants' End
--	Set @Scope=@Scope+Case When IsNull(@FromAge,0)=0 Then '' Else ', older than '+Convert(varchar(10),@FromAge)+' years old ' End
--	Set @Scope=@Scope+Case When @ToAge Is Null Then '' Else Case When @ToAge<200 Then ', younger than '+Convert(varchar(10),@ToAge)+' years old ' Else '' End End
--	Select 
--		TT.Category
--		,TT.Therapeutic
--		, @ConsultantType As ConsultantType
--		, @Scope As Scope
--		, IsNull(Sum(Case When PR.ProcedureTypeId In (1,2,3,4,5,6) Then
--			Case When PR.PatientTypeId=IsNull(@PatientTypeId,PR.PatientTypeId) Then 
--				Case When PR.PatientStatusId=IsNull(@PatientStatusId,PR.PatientStatusId) Then
--					Case When PR.CreatedOn>=RF.FromDate And PR.CreatedOn<=RF.ToDate And PR.Age>=IsNull(@FromAge,0) And PR.Age<=IsNull(@ToAge,200) Then 1 
--					Else 0 End
--				Else 0 End 
--			Else 0 End 
--			Else 0 End
--			),0) As ProcCount
--	From ERS_TherapeuticTypes TT
--		LEFT OUTER JOIN fw_Therapeutic T ON TT.ID=T.TherapeuticID
--		LEFT OUTER JOIN fw_Sites S ON T.SiteId=S.SiteId
--		LEFT OUTER JOIN fw_Procedures PR ON S.ProcedureId=PR.ProcedureId
--		LEFT OUTER JOIN fw_ProceduresConsultants PC ON PC.ProcedureId=PR.ProcedureId
--		LEFT OUTER JOIN fw_ConsultantTypes CT ON PC.ConsultantTypeId=CT.ConsultantTypeId
--		LEFT OUTER JOIN fw_ReportConsultants RC ON PC.ConsultantId=RC.ConsultantId
--		LEFT OUTER JOIN fw_ReportFilter RF ON RF.UserId=RC.UserId And RF.UserId=@UserID
--	Where TT.Category<>'None' And PR.CreatedOn IS NOT NULL
--	Group By 
--		TT.Category, TT.Therapeutic
--	Order By 1 DESC, 2
--	End
--End
--GO



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

DROP TABLE #variables
GO
