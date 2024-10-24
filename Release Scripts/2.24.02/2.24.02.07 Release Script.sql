------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	
-- TFS#	
-- Description of change
-- 
------------------------------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

---------------------------------------------------------
-- Update script for release 2.24.02.07
---------------------------------------------------------
DECLARE @Version AS VARCHAR(40) = '2.24.02.07'

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
---------------------------------------------------------
GO 

--Bug fix for SP_Get_PatientReport_Info
GO
EXEC dbo.DropIfExist @ObjectName = 'Get_PatientReport_Info',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[Get_PatientReport_Info]
	@ProcedureId int,
	@OperatingHospitalId int
AS
BEGIN
	Declare @PP_PFRFollowUp nvarchar(max),@LimitationId int,@ProcedureUpperExtent int,@ProcedureLowerExtent bit,@ProcedureTypeID int,@NEDEnabled int,@procedureComplete nvarchar(100)
	Declare @Results as Table(includeText nvarchar(200) ,includes bit,result nvarchar(max))

	select @ProcedureUpperExtent=ExtentId from ERS_ProcedureUpperExtent where ProcedureId=@ProcedureId and ExtentId=(select UniqueId from ERS_Extent where Description='Abandoned')
	select @ProcedureLowerExtent=isnull(Abandoned,0) from ERS_ProcedureLowerExtent where ProcedureId=@ProcedureId	
	select @LimitationId=LimitationId from ERS_ProcedureUpperExtent where ProcedureId=@ProcedureId

	select @ProcedureTypeID= ProcedureType,@NEDEnabled=ISNULL(NEDEnabled,1) from ers_procedures where ProcedureId=@ProcedureId
	if @NEDEnabled<>1 or (@ProcedureTypeID in (3,4,5,9) and @ProcedureLowerExtent=1) or (@ProcedureTypeID in (1,6,7,8,2) and @ProcedureUpperExtent is not null)
	begin
		set @procedureComplete='No'
	end
	else if @LimitationId is not null
	begin
		set @procedureComplete='Yes (limited)'
	end
	else
	begin
		set @procedureComplete='Yes'
	end

	select Biopsy,Urease,Polypectomy into #tmpPatientReport from ERS_UpperGISpecimens where SiteId in (SELECT SiteId FROM ERS_Sites where ProcedureId=@ProcedureId)
	select @PP_PFRFollowUp=ISNULL(LTRIM(RTRIM(PP_PFRFollowUp)), '') from ERS_UpperGIFollowUp where procedureid=@ProcedureId

	insert into @Results(includeText,includes,result)
	select 'Urease',IncludeUreaseText,'<strong>&#8226;</strong>&nbsp;&nbsp;'+UreaseText from ERS_PrintOptionsPatientFriendlyReport where OperatingHospitalId=@OperatingHospitalId and EXISTS(select Urease from #tmpPatientReport where Urease=1) union all
	select 'Polypectomy',IncludePolypectomyText,'<strong>&#8226;</strong>&nbsp;&nbsp;'+PolypectomyText from ERS_PrintOptionsPatientFriendlyReport where OperatingHospitalId=@OperatingHospitalId and EXISTS(select Polypectomy from #tmpPatientReport where Polypectomy=1) union all
	select 'OtherBiopsy',IncludeOtherBiopsyText,'<strong>&#8226;</strong>&nbsp;&nbsp;'+OtherBiopsyText from ERS_PrintOptionsPatientFriendlyReport where OperatingHospitalId=@OperatingHospitalId and EXISTS(select Biopsy from #tmpPatientReport where Biopsy=1) union all
	select 'IncludeAnyOtherBiopsyText',IncludeOtherBiopsyText,'<strong>&#8226;</strong>&nbsp;&nbsp;'+AnyOtherBiopsyText from ERS_PrintOptionsPatientFriendlyReport where OperatingHospitalId=@OperatingHospitalId and EXISTS(select Biopsy from #tmpPatientReport where Biopsy=1) union all
	select 'PreceedAdviceComments',IncludePreceedAdviceComments,'<strong>&#8226;</strong>&nbsp;&nbsp;'+PreceedAdviceComments+' '+@PP_PFRFollowUp from ERS_PrintOptionsPatientFriendlyReport where OperatingHospitalId=@OperatingHospitalId and @PP_PFRFollowUp<>''	

	select procedureComplete=@procedureComplete,ProcedureType=isnull(b.ProcedureType,''),ProcedureTypeId=b.ProcedureTypeId,MedicationText=ISNULL( c.Summary,''),
	d.NoFurtherTestsRequired,d.AwaitingPathologyResults,NoFurtherFollowUp=isnull(d.NoFurtherFollowUp,0),
	ListItemText=(SELECT isnull(ListItemText,'') FROM ERS_Lists WHERE ListDescription = 'Return or referred to' AND ListItemNo=d.ReturnTo),
	ReviewText=isnull(d.ReviewText,''),d.Summary
	from ERS_Procedures a left join ERS_ProcedureTypes b on a.ProcedureType=b.ProcedureTypeId
	left join ERS_UpperGIRx c on a.ProcedureId=c.ProcedureId
	left join ERS_UpperGIFollowUp d on a.ProcedureId=d.ProcedureId
	where a.ProcedureId=@ProcedureId

	select result from @Results where includes=1
	return
END
GO

--Bug fix for Search failing with NULL PatientId in Worklist
GO
EXEC dbo.DropIfExist @ObjectName = 'get_worklist_patients',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE  [dbo].[get_worklist_patients]
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
		isnull(eapt.ProcedureTypeID,0) AS ProcedureTypeId,
		ept.ProcedureType,
		isnull((select stuff((SELECT DISTINCT ', ' + ett.Description AS [text()]
						FROM dbo.ERS_AppointmentTherapeutics eat
							INNER JOIN dbo.ERS_TherapeuticTypes ett ON eat.TherapeuticTypeID = ett.Id
						where AppointmentId=ea.AppointmentId and eat.AppointmentProcedureId=eapt.AppointmentProcedureTypeID
						FOR XML PATH('')),1,1,'')),'') AS [AppointmentSubject],--Description of change: From the worklist view the Therapeutic needs to show next to the procedure type 
		ep.PatientId,
		1 AS ERSPatient,
		--ISNULL(dp.OperatingHospitalId, ea.OperationalHospitaId) as HospitalId,
		@OperatingHospitalId as HospitalId,
		ea.StartDateTime,
		ea.TimeOfDay,
		CASE WHEN [as].HDCKEY IS NULL THEN 'Booked'
			 WHEN [as].HDCKEY = 'P' THEN 'Booked'
		ELSE [as].[Description]
		END as AppointmentStatus,
		[as].HDCKEY as AppointmentStatusHDCKEY,
		isnull(r.RoomName,rw.RoomName) as RoomName, 
		isnull(r.RoomId,rw.RoomId) as RoomId,--Description of change: select multiple procedure suggest changing them to tick boxes, room drop down
		ea.Notes as Alerts,
		ea.GeneralInformation as Notes,
		CASE WHEN ISNULL(ea.DiaryId, 0) = 0 THEN ea.EndoscopistId ELSE dp.UserID END EndoscopistId,
		eu.Title + ' ' + eu.Forename + ' ' + eu.Surname AS Endoscopist,
		CASE ISNULL(ea.TimeOfDay,'') WHEN '' THEN 0 WHEN 'AM' THEN 1 WHEN 'PM' THEN 2 WHEN 'Evening' THEN 3 END AS iTOD,
		CONVERT(varchar(5), ea.StartDateTime, 108) AS AppointmentTime,
		ISNULL(pip.ProcedureCompleted,0) AS ProcedureCompleted,
		CASE WHEN pj.PatientAdmissionTime IS NULL THEN 0 ELSE 1 END PatientArrived,
		CONVERT(varchar(5), pj.PatientAdmissionTime, 108) as ArrivedTime,
		CONVERT(varchar(5), pj.ProcedureStartTime, 108) as InProgressTime,
		CONVERT(varchar(5), pj.ProcedureEndTime, 108) as RecoveryTime,
		CONVERT(varchar(5), pj.PatientDischargeTime, 108) as DischargeTime,
		CONVERT(varchar(5), ea.DueArrivalTime, 108) as CallInTime,
		ss.Description AS Category
	FROM  ERS_Appointments ea  
		INNER JOIN dbo.ERS_Patients ep (nolock) ON ea.PatientId = ep.PatientId
		LEFT JOIN ERS_AppointmentStatus [as] (nolock) ON EA.AppointmentStatusId = [as].UniqueId 
		LEFT JOIN ERS_AppointmentProcedureTypes eapt (nolock) ON EA.AppointmentId = eapt.AppointmentID
		LEFT JOIN dbo.ERS_ProcedureTypes ept (nolock) ON eapt.ProcedureTypeID = ept.ProcedureTypeId
		LEFT JOIN ERS_SCH_DiaryPages dp (nolock) on ea.DiaryId = dp.DiaryId
		LEFT JOIN dbo.ERS_Users eu (nolock) ON eu.UserID = CASE WHEN ISNULL(ea.DiaryId,0) = 0 THEN ea.EndoscopistId ELSE dp.UserId END 
		LEFT JOIN ERS_SCH_Rooms r (nolock) on dp.RoomId = r.RoomId
		LEFT JOIN ERS_SCH_Rooms rw (nolock) on ea.RoomId = rw.RoomId
		LEFT JOIN (SELECT ep.ProcedureId, ep.ProcedureType, ep.ProcedureCompleted, ep.PatientId, ep.CreatedOn
						FROM dbo.ERS_Procedures ep (nolock)
					WHERE ep.IsActive= 1 
						AND ISNULL(ep.ProcedureCompleted,0) = 0 
						AND ep.OperatingHospitalID = @OperatingHospitalId
				  ) pip ON ea.PatientId = pip.PatientId AND ISNULL(eapt.ProcedureTypeId, pip.ProcedureType) = pip.ProcedureType
		LEFT JOIN ERS_PatientJourney pj (nolock) on pj.PatientId = ep.PatientId AND pj.AppointmentId = ea.AppointmentId
		LEFT JOIN ERS_SCH_SlotStatus ss (nolock) on ss.StatusId = ea.SlotStatusID
	WHERE ea.BookingTypeId IN (1, 2) /*1 = worklist, 2 = scheduler appointment*/
		AND ea.StartDateTime >= @StartDate 
		AND (@EndDate IS NULL OR ea.StartDateTime < @EndDate)
		AND (ea.IsDeleted IS NULL OR ea.IsDeleted = 0) and ( ea.AppointmentStatusId is null or [as].Description != 'Cancelled') --TFS--3463
		AND (@EndoscopistId IS NULL OR CASE WHEN ISNULL(ea.DiaryId,0) = 0 THEN ea.EndoscopistId ELSE dp.UserId END = @EndoscopistId)
		AND ea.OperationalHospitaId = @OperatingHospitalId
	order by ea.StartDateTime  
END

GO

--Bug fix for duplicate procedures showing after procedure has been edited
GO
EXEC dbo.DropIfExist @ObjectName = 'usp_Procedures_SelectByPatient',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)
GO

CREATE PROCEDURE [dbo].[usp_Procedures_SelectByPatient]
(
    @UserName Varchar(200),
	@PatientId INT,
	@IncludeOldProcs BIT = 1,
	@ActiveProceduresOnly BIT = 1 -- Only Select the Active Records-> IsActive=True!
)
AS

SET NOCOUNT ON

 
DECLARE @AdminIDs  VARCHAR(100)
DECLARE @Admin Bit
DECLARE @HasRole NVARCHAR(5); 
 
 
     SELECT @AdminIDs = COALESCE(@AdminIDs + ', ', '') +  CAST(RoleId AS NVARCHAR)
	 FROM ERS_Roles where RoleName in ('System Administrators','GlobalAdmin')
	  
     SELECT  @HasRole = CASE WHEN Count(T2.[Item]) > 0 THEN 'true' ELSE 'false' END FROM fnSplitString(@AdminIDs,',') AS T1
            LEFT JOIN fnSplitString((SELECT RoleID  FROM ERS_Users WHERE Username =  @UserName),',')
            AS T2 on T1.[Item] = T2.[Item] WHERE T2.[Item] is not null 

	UPDATE ERS_ProcedureEditHistory SET LockedEnd =  GetDATE()  WHERE  LockedBy = @UserName  
	--Added by rony tfs-2964 start
	DECLARE @GREENCIRCLE VARCHAR(MAX) = '<IMG SRC="../Images/NEDJAG/Mand.png" />';
	DECLARE @RedCIRCLE VARCHAR(MAX) = '<IMG SRC="../Images/NEDJAG/Red.png" />';
	--End

	SELECT * INTO #procs FROM (
		SELECT 
			p.ProcedureId AS ProcedureId,
			0 AS EpisodeNo,
			0 AS PreviousProcedureId,
			p.ProcedureType AS ProcedureType,
			CONVERT(VARCHAR(50),'') AS PatientComboId,
			p.DiagramNumber AS DiagramNumber,
			--Added by rony tfs-2964 start
			CASE WHEN p.ProcedureId = OPAPI.ProcedureId THEN 
			 @GREENCIRCLE + ' ' + CONVERT(VARCHAR(100), CONVERT(VARCHAR, p.CreatedOn, 103) + ' - ' + pt.ProcedureType)
			ELSE  
			@RedCIRCLE + ' ' + CONVERT(VARCHAR(100), CONVERT(VARCHAR, p.CreatedOn, 103) + ' - ' + pt.ProcedureType) 
			END AS DisplayName,
			--End
			1 AS ERS,
			p.CreatedOn,
			p.ModifiedOn,
            
            @HasRole AS Administrator,
			ISNULL((SELECT TOP (1) CASE WHEN LockedEnd IS NOT NULL THEN 'false' ELSE
	         CASE WHEN  DATEDIFF(minute, ISNULL(LockedAt,GETDATE()), GETDATE()) <61 then  'true' ELSE 'false' END  END
	        from ERS_ProcedureEditHistory WHERE ProcedureId=p.ProcedureId ORDER BY [EditId] DESC ), 'false')   AS procedureLocked , 

			(SELECT CASE  WHEN ISNULL((SELECT TOP (1) LockedBy FROM ERS_ProcedureEditHistory WHERE ProcedureId = p.ProcedureId), '') <> '' THEN 'true'  ELSE 'false'   END) AS hasHistory,

			ISNULL((SELECT  TOP (1) 	ISNULL( users.[Title] + ' '+users.[Forename] +' '+ users.[Surname],'')  from ERS_ProcedureEditHistory edit  LEFT JOIN ERS_Users users on
			Username = edit.LockedBy WHERE edit.ProcedureId = p.ProcedureId ),'') AS LockedUser,
		
			ISNULL((SELECT  TOP (1) format(LockedAt ,'HH:mm') from ERS_ProcedureEditHistory  WHERE ProcedureId = p.ProcedureId order by LockedAt desc),'') AS LockedAt,
			0 AS Locked,--ISNULL(pa.Locked,0), 
			0 AS LockedBy,--ISNULL(pa.LockedBy,0), 
			NULL AS LockedOn,--pa.LockedOn,
			ISNULL(CAST(SurgicalSafetyCheckListCompleted AS VARCHAR(50)),'') AS SurgicalSafetyCheckListCompleted,
			CASE s.ReportLocking 
			WHEN 1 
			THEN 0
			ELSE
				CASE 
				WHEN p.ModifiedOn <= DATEADD(DAY, 0 - s.LockingDays, DATEADD(HOUR, convert(int,left(isnull(s.LockingTime, '0'), 2)), DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))))
				THEN  CASE WHEN p.ProcedureCompleted = 1 THEN 1 ELSE 0 END
				ELSE 0
				END
			END AS isProcedureLocked
			, -1 AS  ColonType
			, CONVERT(INT,ISNULL(ProcedureCompleted,0)) AS ProcedureCompleted
			, IsNull(P.DNA,'')		AS DNA_Reason	
			, IsNull(PR.PP_DNA,'')	AS DNA_Reason_PP_Text	
			, p.BreathTestResult AS BreathTest
			, CASE WHEN pho.photoCount IS NULL THEN 0 ELSE 1 END HasPhotos
		FROM 
			ERS_Procedures p
		INNER JOIN 
			ERS_ProcedureTypes pt ON p.ProcedureType = pt.ProcedureTypeId
		INNER JOIN 
			ERS_Patients pa ON p.PatientId = pa.PatientId
		LEFT JOIN ERS_ProceduresReporting AS PR ON p.ProcedureId=PR.ProcedureId
		LEFT JOIN (SELECT count(dbo.ers_photos.PhotoId) AS photoCount, procedureid FROM ers_photos GROUP BY procedureid) as pho ON p.ProcedureId = pho.ProcedureId
		JOIN ERS_SystemConfig s on p.OperatingHospitalID = s.OperatingHospitalID 
		--Added by rony tfs-2964 start
		LEFT JOIN (select top 1 CAST('<x>' + REPLACE(Process,'|','</x><x>') + '</x>' AS XML).value('/x[4]','int') as ProcedureId from ERS_OCS_Process_Audit order by ProcessID desc) OPAPI on OPAPI.ProcedureId = p.ProcedureId
		--End
		WHERE 
			p.PatientId = @PatientId
			AND p.IsActive  = @ActiveProceduresOnly
	) AS temptemp


	INSERT INTO #procs
		SELECT 
			DISTINCT 0,
			0,
			pp.PreviousProcedureID,
			0,
			'',
			0,
			CONVERT(VARCHAR(100), CONVERT(VARCHAR, pp.ProcedureDate, 103) + 
				' - ' + 
				pp.ProcedureType),
			2,
			pp.ProcedureDate,
			pp.ProcedureDate,
			'',
			0,
			'',
			'',
			'',
			1,0,null,
			'', 1, -1, -1,
			1, '', null, CASE WHEN epi.ImageID IS NULL THEN 0 ELSE 1 END
		FROM 
			ERS_PreviousProcedures pp
			LEFT OUTER JOIN ERS_PreviousImages epi ON epi.PreviousProcedureID = pp.PreviousProcedureID
		WHERE
			pp.PatientId = @PatientId
			AND pp.IsActive = 1

	SELECT * FROM #procs ORDER BY CreatedOn DESC, ModifiedOn DESC

	DROP TABLE #procs

GO

------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 29.07.24
-- TFS#	
-- Description of change
-- Bowel prep now conditional based on colons extent
------------------------------------------------------------------------------------------------------------------------
GO


ALTER procedure [dbo].[procedure_bowel_prep_save]
(
	@ProcedureId int,
	@BowelPrepId int,
	@LeftScore int,
	@RightScore int,
	@TransverseScore int,
	@TotalScore int,
	@Quantity decimal(18,2),
	@EnemaId int,
	@EnemaOther varchar(200),
	@AdditionalInfo varchar(max),
	@LoggedInUserId int
)
AS
BEGIN
	IF @BowelPrepId >0 
	BEGIN
	    /*Check if new values been */
	    	IF ISNULL(@AdditionalInfo,'') <> ''
	    	BEGIN
	    		IF NOT EXISTS (SELECT 1 FROM ERS_BowelPrep WHERE Description = @AdditionalInfo)
	    		BEGIN
	    			/*get and set the new items order id so it appears 1 above 'other' we always want other to be last*/
	    
	    			DECLARE @OtherListOrderBy int = (SELECT ListOrderBy FROM ERS_BowelPrep WHERE Description = 'Other')
	    			INSERT INTO ERS_BowelPrep (Description, NEDTerm, ListOrderBy) VALUES (@AdditionalInfo, 'Other', @OtherListOrderBy)
	    			
	    			UPDATE dbo.ERS_BowelPrep SET ListOrderBy = @OtherListOrderBy + 1 WHERE Description = 'Other'
	    		END
	    
	    		SELECT @BowelPrepId = UniqueId FROM ERS_BowelPrep WHERE Description = @AdditionalInfo
	    	END
	    
	    	/*Check if new values been */
	    	IF ISNULL(@EnemaOther,'') <> ''
	    	BEGIN
	    		IF NOT EXISTS (SELECT 1 FROM ERS_BowelPrepEnemas WHERE Description = @EnemaOther)
	    		BEGIN
	    			/*get and set the new items order id so it appears 1 above 'other' we always want other to be last*/
	    
	    			DECLARE @EOtherListOrderBy int = (SELECT ListOrderBy FROM ERS_BowelPrepEnemas WHERE Description = 'Other')
	    			INSERT INTO ERS_BowelPrepEnemas (Description, NEDTerm, ListOrderBy) VALUES (@EnemaOther, 'Other', @EOtherListOrderBy)
	    			
	    			UPDATE dbo.ERS_BowelPrepEnemas SET ListOrderBy = @EOtherListOrderBy + 1 WHERE Description = 'Other'
	    		END
	    
	    		SELECT @EnemaId = UniqueId FROM ERS_BowelPrepEnemas WHERE Description = @EnemaOther
	    	END
	    
	    	IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureBowelPrep WHERE ProcedureId = @ProcedureId)
	    	BEGIN
	    		INSERT INTO ERS_ProcedureBowelPrep (ProcedureId, BowelPrepId, Quantity, LeftPrepScore, RightPrepScore, TransversePrepScore, TotalPrepScore, AdditionalInfo, EnemaId, WhoCreatedId, WhenCreated)
	    		VALUES (@ProcedureId, @BowelPrepId, @Quantity, NULLIF(@LeftScore, -1), NULLIF(@RightScore, -1), NULLIF(@TransverseScore,-1), NULLIF(@TotalScore, -1), '', @EnemaId, @LoggedInUserId, getdate())
	    	END
	    	ELSE
	    	BEGIN
	    		UPDATE ERS_ProcedureBowelPrep
	    		SET BowelPrepId = NULLIF(@BowelPrepId,0),
	    			Quantity = @Quantity,
	    			LeftPrepScore = NULLIF(@LeftScore, -1),
	    			RightPrepScore = NULLIF(@RightScore, -1),
	    			TransversePrepScore = NULLIF(@TransverseScore, -1),
	    			TotalPrepScore = NULLIF(@TotalScore, -1),
	    			AdditionalInfo = @AdditionalInfo,
	    			EnemaId = @EnemaId,
	    			WhoUpdatedId = @LoggedInUserId,
	    			WhenUpdated = getdate()
	    		WHERE ProcedureId = @ProcedureId
	    	END
	END
	ELSE
	BEGIN
	    DELETE FROM dbo.ERS_ProcedureBowelPrep WHERE ProcedureId =@ProcedureId
	END
	

	DECLARE @Summary VARCHAR(max), 
			@BowelPrepFormula varchar(max) = (SELECT [Description] FROM ERS_BowelPrep WHERE UniqueId = @BowelPrepId) + 
				CASE WHEN ISNULL(@EnemaId,0) > 0 THEN ' + ' + (SELECT [Description] FROM dbo.ERS_BowelPrepEnemas WHERE UniqueId = @EnemaId) ELSE '' END +
				CASE WHEN ISNULL(@Quantity,0) > 0 THEN ' (Volume ' + CONVERT(varchar(10), convert(int, @Quantity))  + ')' ELSE '' END

	
	SET @Summary = @BowelPrepFormula + '. '
	
	IF NULLIF(@TotalScore, -1) IS NOT NULL 
	BEGIN
		SET @Summary = @Summary + ' Boston Bowel Prep Total Score ' +  cast( @TotalScore as varchar(10))
	END 

	--UPDATE  [ERS_BowelPreparation] SET Summary = @Summary WHERE ProcedureID=@ProcedureId
	UPDATE [ERS_ProceduresReporting] SET [PP_Bowel_Prep] = @Summary WHERE ProcedureID=@ProcedureId
	EXEC procedure_summary_update @ProcedureId

	DECLARE @SectionId int = (SELECT UISectionId FROM UI_Sections WHERE SectionName = 'Bowel Prep')

	DELETE FROM ERS_ProcedureSummary WHERE ProcedureId = @ProcedureId AND SectionId = @SectionId
	
	--validate completion
	EXEC procedure_bowel_prep_completion_check @ProcedureId

	
END
GO


ALTER PROCEDURE dbo.procedure_bowel_prep_completion_check
(
	@ProcedureId INT,
	@BowelPrepId INT = NULL,
	@LeftScore INT = NULL,
	@RightScore INT = NULL,
	@TransverseScore INT = NULL
)
AS	
BEGIN
	IF @BowelPrepId IS NULL 
	BEGIN
	    SELECT @LeftScore = LeftPrepScore, @RightScore = RightPrepScore, @TransverseScore = TransversePrepScore, @BowelPrepId = BowelPrepId FROM dbo.ERS_ProcedureBowelPrep WHERE ProcedureId = @ProcedureId
	END

	DECLARE @Summary VARCHAR(200) = 'Bowel prep'
    DECLARE @ProcedureTypeId INT = (SELECT ProcedureType FROM dbo.ERS_Procedures WHERE ProcedureId = @ProcedureId)
	DECLARE @ExtentId INT = (SELECT MAX(pe.ExtentId) FROM dbo.ERS_ProcedureLowerExtent pe WHERE pe.ProcedureId = @ProcedureId)
	DECLARE @SplenicFlexureId INT
	DECLARE @HepaticFlexureId INT
	DECLARE @CaecumId INT
	DECLARE @TIleumId INT

	SELECT 
		@SplenicFlexureId = MAX(CASE WHEN NEDTerm = 'Splenic flexure' THEN UniqueId END),
		@HepaticFlexureId = MAX(CASE WHEN NEDTerm = 'Hepatic flexure' THEN UniqueId END), 
		@CaecumId = MAX(CASE WHEN NEDTerm = 'Caecum' THEN UniqueId END), 
		@TIleumId = MAX(CASE WHEN NEDTerm = 'Terminal ileum' THEN UniqueId END) 
	FROM 
		dbo.ERS_Extent
	WHERE 
		NEDTerm IN ('Splenic flexure', 'Hepatic flexure', 'Caecum', 'Terminal ileum');


	/*For colonoscopy and flexi sig, where the extent is ‘anastamosis’, ‘ileo-colon anastamosis’ or ‘neo-terminal ileum’, segmental BBPS scores 
	or a total BBPS score is no longer mandated.*/
	IF EXISTS (SELECT 1 FROM dbo.ERS_ProcedureLowerExtent pe WHERE pe.ProcedureId = @ProcedureId AND (ISNULL(pe.LimitationId,0) > 0 or (pe.IntubationFailed =1 OR pe.Abandoned = 1) OR pe.ExtentId IN (
		SELECT e.UniqueId FROM dbo.ERS_Extent e WHERE e.NEDTerm IN ('Ileo-colon anastomosis','Neo-terminal ileum','Terminal ileum','Anastomosis'))))
			BEGIN
				EXEC UI_update_procedure_summary   @ProcedureId, 'Bowel Prep', @Summary, 1	
			END
	ELSE
	BEGIN
		IF (@BowelPrepId = (SELECT bp.UniqueId FROM dbo.ERS_BowelPrep bp WHERE bp.NEDTerm = 'No preparation'))
			EXEC UI_update_procedure_summary   @ProcedureId, 'Bowel Prep', @Summary, 1	
		ELSE IF @ProcedureTypeId = 3 AND @LeftScore > -1
			BEGIN
				IF @RightScore > -1 AND @TransverseScore > -1 --if all scores are presant
					BEGIN
						EXEC UI_update_procedure_summary   @ProcedureId, 'Bowel Prep', @Summary, 1	
					END
				ELSE IF  (@RightScore = -1 OR @TransverseScore = -1) AND @ExtentId NOT IN (@CaecumId,@TIleumId) --if right or transverse arent provided and extent is not Caecum or Terminal ileum
				BEGIN
					EXEC UI_update_procedure_summary   @ProcedureId, 'Bowel Prep', @Summary, 1	
				END
				ELSE --might already be a completed value in there so remove it
				BEGIN
					EXEC UI_update_procedure_summary   @ProcedureId, 'Bowel Prep', @Summary, 0	
				END
			END
		ELSE IF @ProcedureTypeId = 4 AND @LeftScore > -1 
		BEGIN
			IF (@ExtentId < @HepaticFlexureId) --if extent if beyond hepatic flexure, it must have a transverse and right score
			BEGIN
				IF (ISNULL(@TransverseScore,-1) > -1 AND ISNULL(@RightScore,-1) > -1)
				BEGIN
	    			EXEC UI_update_procedure_summary   @ProcedureId, 'Bowel Prep', @Summary, 1	
				END
				ELSE IF (ISNULL(@TransverseScore,-1) = -1 OR ISNULL(@RightScore,-1) = -1)
				BEGIN
	    			EXEC UI_update_procedure_summary   @ProcedureId, 'Bowel Prep', @Summary, 0	
				END
			END
			ELSE IF (@ExtentId < @SplenicFlexureId) --if extent if beyond splenic flexure, it must have a transverse score
			BEGIN
				IF ISNULL(@TransverseScore,-1) > -1
				BEGIN
	    			EXEC UI_update_procedure_summary   @ProcedureId, 'Bowel Prep', @Summary, 1	
				END
				ELSE
				BEGIN
	    			EXEC UI_update_procedure_summary   @ProcedureId, 'Bowel Prep', @Summary, 0	
				END
			END
			ELSE
			BEGIN
				EXEC UI_update_procedure_summary   @ProcedureId, 'Bowel Prep', @Summary, 1	
			END
		END
		ELSE
			EXEC UI_update_procedure_summary   @ProcedureId, 'Bowel Prep', @Summary, 0	
	END
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
	@NoRetroflexionReason VARCHAR(150),
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
											  WhoUpdatedId, WhenUpdated,NoRetroflectionReason)
		VALUES (@ProcedureId, NULLIF(@ExtentId, 0), @AdditionalInfo, @EndoscopistId, NULLIF(@ConfirmedById,0), NULLIF(@CaecumIdentifiedById,0), NULLIF(@LimitationId,0), @LimitationOther,
				NULLIF(@DifficultyEncounteredId,0), NULLIF(@PR, -1), NULLIF(@Retroflexion, -1), NULLIF(@InsertionVia,0),
				ISNULL(@ProcedureAbandoned,CONVERT(bit,0)), 
				ISNULL(@IntubationFailed,CONVERT(bit,0)), @LoggedInUserId, getdate(),@NoRetroflexionReason)
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
			NoRetroflectionReason = @NoRetroflexionReason,
			InsertionAccessViaId = NULLIF(@InsertionVia,0),
			Abandoned = ISNULL(@ProcedureAbandoned,CONVERT(bit,0)),
			IntubationFailed = ISNULL(@IntubationFailed,CONVERT(bit,0)),
			WhoUpdatedId = @LoggedInUserId,
			WhenUpdated = getdate()
		WHERE 
			ProcedureId = @ProcedureId AND
			EndoscopistId = @EndoscopistId
	END

	EXEC procedure_lower_extent_summary_update @ProcedureId, @EndoscopistId

	DECLARE @ProcedureTypeId INT = (SELECT ProcedureType FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
	EXEC procedure_bowel_prep_completion_check @ProcedureId

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
-- Updated by	:	Andrea 29.07.24
-- TFS#	
-- Description of change
-- Condition adding when updating list end time
------------------------------------------------------------------------------------------------------------------------
GO


ALTER PROCEDURE dbo.sch_add_list_slot
(
	@ListRulesId int, 
	@SlotId int, 
	@ProcedureTypeId int, 
	@OperatingHospitalId int, 
	@LoggedInUserId int, 
	@SlotMinutes decimal(18,2), 
	@Points decimal
)
AS
BEGIN
    INSERT INTO ERS_SCH_ListSlots (ListRulesId, SlotId, ProcedureTypeId,OperatingHospitalId, WhoCreatedId, WhenCreated, SlotMinutes, Points,Locked, IsOverBookedSlot, Suppressed)
    VALUES (@ListRulesId, @SlotId, @ProcedureTypeId, @OperatingHospitalId, @LoggedInUserId, GETDATE(), @SlotMinutes, @Points, 0, 1, 0)

	DECLARE @DiaryId INT = (SELECT DiaryId FROM dbo.ERS_SCH_DiaryPages WHERE ListRulesId = @ListRulesId)
	UPDATE dbo.ERS_SCH_DiaryPages SET DiaryEnd = dbo.fnSCH_DiaryEnd(@ListRulesId, DiaryStart) WHERE DiaryId = @DiaryId
END

GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO


------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	
-- Description of change
-- Polyp spelling correction
------------------------------------------------------------------------------------------------------------------------
GO



UPDATE dbo.ERS_DiagnosesMatrix SET DisplayName = 'Polyp' WHERE DisplayName = 'poylp'
GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO


------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea
-- TFS#	
-- Description of change
-- Polyp summary correction for Focal Lesions
------------------------------------------------------------------------------------------------------------------------
GO


EXEC dbo.DropIfExist 
    @ObjectName = 'common_polpydetails_summary', 
    @ObjectTypePrefix = 'F' 
GO


CREATE FUNCTION [dbo].[common_polpydetails_summary]
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
	@RemovalBy varchar(500) = '',
	@Inflam bit,
	@PostInflam bit,
	@TattooedId int,
	@TattooMarkingTypeId int,
	@Count int,
	@Submucosal BIT,
	@SubmucosalQuantity INT,
	@SubmucosalLargest INT,
	@SubmucosalProbably BIT,
	@SubmucosalTypeId TINYINT,
	@Focal BIT,
	@FocalQuantity INT,
	@FocalLargest INT,
	@FocalProbably BIT,
	@FocalTypeId TINYINT,
	@FundicGlandPolyp BIT,
	@FundicGlandPolypQuantity INT,
	@FundicGlandPolypLargest Numeric(18,2)
	
	--saves calling the table multiple times :)
	DECLARE @TumourTypes TABLE (TypeId int, [Description] varchar(100))
	INSERT INTO @TumourTypes
	SELECT UniqueId, [Description] 
	FROM ERS_TumourTypes 
	WHERE Suppressed = 0

	SELECT 
	@Submucosal =iif(b.description='Submucosal',1,0),
	@SubmucosalTypeId = a.type,
	@SubmucosalLargest = a.SubmucosalLargest,
	@SubmucosalProbably = a.Probably,
	@SubmucosalQuantity = a.SubmucosalQuantity,
	@Focal = iif(b.description='Focal lesions',1,0),
	@FocalTypeId = a.type,
	@FocalLargest = a.FocalLargest,
	@FocalProbably = a.Probably,
	@FocalQuantity = a.FocalQuantity,
	@FundicGlandPolyp = iif(b.description='Fundic Gland Polyp',1,0),
	@FundicGlandPolypQuantity = FundicGlandPolypQuantity,
	@FundicGlandPolypLargest = FundicGlandPolypLargest
FROM
	ERS_CommonAbnoPolypDetails a left join ERS_PolypTypes b on a.PolypTypeId=b.uniqueid
WHERE
	SiteId = @SiteId and PolypDetailId = ISNULL(@PolypDetailId, PolypDetailId)


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



	------------------------------------------------------------------------------------------
	-------	SUBMUCOSAL LESION -------
	------------------------------------------------------------------------------------------
	IF @Submucosal > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		IF @SubmucosalQuantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @SubmucosalQuantity) + ' '
		ELSE SET @summary = @summary + 'A '
		
		IF @SubmucosalProbably = 1 SET @summary = @summary + 'probably '

		SELECT @summary = @summary + LOWER([Description]) + ' ' FROM @TumourTypes WHERE TypeId = @SubmucosalTypeId

		IF @SubmucosalQuantity > 1 SET @summary = @summary + 'submucosal lesions ' ELSE SET @summary = @summary + 'submucosal lesion ' 

		IF (@SubmucosalQuantity > 0 AND @SubmucosalLargest > 0) 
		BEGIN
			IF @SubmucosalQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @SubmucosalLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @SubmucosalLargest) + 'mm) '
		END
	END

	------------------------------------------------------------------------------------------
	-------	FOCAL LESIONS -------
	------------------------------------------------------------------------------------------
	IF @Focal > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		IF @FocalQuantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @FocalQuantity) + ' '
		ELSE SET @summary = @summary + 'A '
		
		IF @FocalProbably = 1 SET @summary = @summary + 'probably '

		SELECT @summary = @summary + LOWER([Description]) + ' ' FROM @TumourTypes WHERE TypeId = @FocalTypeId

		IF @FocalQuantity > 1 SET @summary = @summary + 'focal lesions ' ELSE SET @summary = @summary + 'focal lesion ' 

		IF (@FocalQuantity > 0 AND @FocalLargest > 0) 
		BEGIN
			IF @FocalQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @FocalLargest) + 'mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @FocalLargest) + 'mm) '
		END
	END
	-------------------------------------------------------------------------------------------
	-------	Fundic Gland Polyp -------
	------------------------------------------------------------------------------------------
	IF @FundicGlandPolyp > 0
	BEGIN
		IF @summary <> '' SET @summary = @summary + '##'

		IF @FundicGlandPolypQuantity > 1 SET @summary = @summary + CONVERT(VARCHAR(20), @FundicGlandPolypQuantity) + ' '
		ELSE SET @summary = @summary + 'A '
		
		IF @FundicGlandPolypQuantity > 1 SET @summary = @summary + 'Fundic Gland Polyp found ' ELSE SET @summary = @summary + 'Fundic Gland Polyp found ' --TFS-2958---

		IF (@FundicGlandPolypQuantity > 0 AND @FundicGlandPolypLargest > 0) 
		BEGIN
			IF @FundicGlandPolypQuantity > 1
				SET @summary = @summary + '(largest ' + CONVERT(VARCHAR(20), @FundicGlandPolypLargest) + ' mm) '
			ELSE
				SET @summary = @summary + '(' + CONVERT(VARCHAR(20), @FundicGlandPolypLargest) + ' mm) '
		END
	END


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

		SELECT @RemovalBy = Description
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
										  WHEN  2 THEN 'pit type II'
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

		SET @Count = @Count + 1
		FETCH NEXT FROM cur INTO @PolypDetailId, @Size, @Excised, @Retrieved, @ToLabs, @Removal, @RemovalMethod, @Probably, @TumourTypeId, @ParisClass, @PitPattern, @Inflam, @PostInflam, @TattooedId, @TattooMarkingTypeId

	END

	CLOSE cur
	DEALLOCATE cur

	RETURN @summary + '##'
END

GO
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

--Bug fix for ASA Status not being updated on Report
GO
EXEC dbo.DropIfExist @ObjectName = 'ProcedureIndicationsSummary',      -- varchar(100)
                     @ObjectTypePrefix = 'F' -- varchar(5)
GO

CREATE FUNCTION [dbo].[ProcedureIndicationsSummary]
(
	@ProcedureId int
)
RETURNS varchar(max)
AS
BEGIN

DECLARE @StageString  varchar(max),@IndicationsString  varchar(max), @ComorbidityString varchar(max), @DamagingDrugsString varchar(max), @PatientAllergiesString varchar(max), @PreviousSurgeryString varchar(max), 
		@PreviousDiseasesString varchar(max), @FamilyDiseaseHistoryString varchar(max), @ImagingString varchar(max), @ImagingOutcomeString varchar(max),
		@RetVal varchar(max), @ProcedureTypeId INT

SELECT @ProcedureTypeId = ProcedureType FROM dbo.ERS_Procedures WHERE ProcedureId = @ProcedureId

SELECT @IndicationsString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN i.AdditionalInfo = 0 THEN [Description] ELSE AdditionalInformation END + 
	CASE WHEN ISNULL(ChildIndicationId, 0) > 0 THEN '-' + (SELECT [Description] FROM ERS_Indications WHERE UniqueId = epi.ChildIndicationId) ELSE '' END + 
	CASE WHEN i.AdditionalInfo = 0 AND ISNULL(AdditionalInformation, '') <> '' THEN ' ' + AdditionalInformation ELSE '' END AS [text()] 
	FROM ERS_ProcedureIndications epi 
	INNER JOIN ERS_Indications i on i.UniqueId = epi.IndicationId
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(i.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--rockall and baltchford scoring
--changed by mostafiz 3702

SELECT @IndicationsString	= @IndicationsString + CASE WHEN CHARINDEX('melaena', @IndicationsString) > 0 OR CHARINDEX('haematemesis', @IndicationsString) > 0 THEN ' ' + dbo.fnBlatchfordRockallScores(@ProcedureId) ELSE '' END
--SELECT @IndicationsString = dbo.fnCapitalise(dbo.fnAddFullStop(@IndicationsString)) 

IF LEN(@IndicationsString) > 0
BEGIN
	IF charindex(',', reverse(@IndicationsString)) > 0
		SELECT @RetVal = STUFF(@IndicationsString, len(@IndicationsString) - charindex(' ,', reverse(@IndicationsString)) + 0, 1, ' and ')
	ELSE
		SELECT @RetVal = @IndicationsString
END
--changed by mostafiz 3702
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

--TFS 3544 Start

DECLARE @AntiCoagDrugs bit = (SELECT AntiCoagDrugs FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
IF @AntiCoagDrugs IS NOT NULL
	If @AntiCoagDrugs = 1 SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'The patient is taking anti-coagulant or anti-platelet medication.'

SELECT @DamagingDrugsString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ProcedureDamagingDrugs edd 
	INNER JOIN ERS_PotentialDamagingDrugs d on d.uniqueid = edd.DamagingDrugId AND d.AntiCoag = 1
	WHERE edd.ProcedureId=@ProcedureId
	ORDER BY ISNULL(d.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

IF LEN(@DamagingDrugsString) > 0
BEGIN
	IF charindex(',', reverse(@DamagingDrugsString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Anti-Coagulant drug(s): ' + STUFF(@DamagingDrugsString, len(@DamagingDrugsString) - charindex(' ,', reverse(@DamagingDrugsString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Anti-Coagulant drug(s): ' + @DamagingDrugsString
END


SELECT @DamagingDrugsString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ProcedureDamagingDrugs edd 
	INNER JOIN ERS_PotentialDamagingDrugs d on d.uniqueid = edd.DamagingDrugId AND d.AntiCoag = 0
	WHERE edd.ProcedureId=@ProcedureId
	ORDER BY ISNULL(d.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

IF LEN(@DamagingDrugsString) > 0
BEGIN
	IF charindex(',', reverse(@DamagingDrugsString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Potentially Significant drugs(s): ' + STUFF(@DamagingDrugsString, len(@DamagingDrugsString) - charindex(' ,', reverse(@DamagingDrugsString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Potentially Significant drugs(s): ' + @DamagingDrugsString
END

--TFS 3544 End

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
------------------- Staging
--TFS#	3866
	SELECT @StageString=
  (SELECT   CONCAT(
	  --Staging Investigations
		CASE 
          WHEN StagingInvestigations <> 0 THEN 
			 (CASE WHEN [ClinicalGrounds] = 1 THEN 'Clinical Grounds only' ELSE '' END) +
			
			 (CASE WHEN [ImagingOfThorax] = 1 THEN 
			  CASE WHEN [ClinicalGrounds] = 1 THEN ', Cross sectional imaging of thorax' ELSE 'Cross sectional imaging of thorax' END
			  ELSE '' END) +
			
			 (CASE WHEN [PleuralHistology] = 1 THEN
			 CASE WHEN [ClinicalGrounds] = 1 OR [ImagingOfThorax] = 1 THEN ', Pleural cytology / histology' ELSE 'Pleural cytology / histology' END
			 ELSE '' END) +
			 (CASE WHEN [MediastinalSampling] = 1 THEN 
			 CASE WHEN [ClinicalGrounds] = 1 OR [ImagingOfThorax] = 1 OR [PleuralHistology] = 1 THEN ', Mediastinal Sampling' ELSE 'Mediastinal Sampling' END
			 ELSE '' END) +
			 (CASE WHEN [Metastases] = 1 THEN 
			 CASE WHEN [ClinicalGrounds] = 1 OR [ImagingOfThorax] = 1 OR [PleuralHistology] = 1 OR [MediastinalSampling] = 1 THEN ', Diagnostic tests for metastases' ELSE 'Diagnostic tests for metastases' END
			 ELSE '' END) + 
			 (CASE WHEN [Bronchoscopy] = 1 THEN 
			 CASE WHEN [ClinicalGrounds] = 1 OR [ImagingOfThorax] = 1 OR [PleuralHistology] = 1 OR [MediastinalSampling] = 1 OR [Metastases] = 1 THEN ', Bronchoscopy' ELSE 'Bronchoscopy' END
			 ELSE '' END)
         ELSE ''
       END,
	   CASE WHEN ([ClinicalGrounds] = 1 OR [ImagingOfThorax] = 1 OR [PleuralHistology] = 1 OR [MediastinalSampling] = 1 OR [Metastases] = 1 OR Bronchoscopy = 1 ) AND [Stage] = 1  THEN   ' <br/> '  ELSE ''END,
		--stage
		CASE WHEN [Stage] = 1 THEN
		     CONCAT (		 
			 CASE WHEN StageLocation <> 0 then 
			 CONCAT ('Location of primary tumour - ' , CASE WHEN StageLocation = 1 THEN 'Oesophagus' 
	         WHEN StageLocation = 2 THEN 'Oesophagogastric junction' 
	         WHEN StageLocation = 3 THEN 'Stomach' 
             ELSE ''
	         END)
	    ELSE '' END,
			 	 
	 CASE WHEN StageLocation <> 0  AND (StageT <> 0 OR StageN <> 0 OR StageM <> 0 ) THEN ' and ' ELSE ''END,	 
	 CASE WHEN StageT <> 0 then
	 CONCAT ('T - ', CASE WHEN StageT = 1 THEN 'TX' 
	      WHEN StageT = 2 THEN 'T0' 
	      WHEN StageT = 3 THEN 'Tis' 
		  WHEN StageT = 4 THEN 'T1' 
		  WHEN StageT = 5 THEN 'T1a' 
		  WHEN StageT = 6 THEN 'T1b' 
		  WHEN StageT = 7 THEN 'T2' 
	      WHEN StageT = 8 THEN 'T3'
	      WHEN StageT = 9 THEN 'T4'
	      WHEN StageT = 10 THEN 'T4a'
	      WHEN StageT = 11 THEN 'T4b'
	 ELSE ''
	 END )


	 ELSE '' END,
	 CASE WHEN (StageT <> 0  )  AND StageN <> 0 THEN ', ' ELSE ''END,
	 CASE WHEN StageN <> 0 THEN 
	 CONCAT ('N - ', CASE WHEN StageN = 1 THEN 'NX' 
	      WHEN StageN = 2 THEN 'N0' 
	      WHEN StageN = 3 THEN 'N1' 
		  WHEN StageN = 4 THEN 'N2' 
		  WHEN StageN = 5 THEN 'N3' 
	 ELSE ''
	 END)
	 ELSE '' END,
	 CASE WHEN (StageN <> 0 or StageT <> 0  ) AND StageM <> 0 THEN ', ' ELSE ''END,
	 	 CASE WHEN StageM <> 0 THEN
		    CONCAT ('M - ', CASE WHEN StageM = 1 THEN 'MX' 
	        WHEN StageM = 2 THEN 'M0' 
	        WHEN StageM = 3 THEN 'M1' 
	        ELSE ''
	        END)
	    ELSE '' end
           )
	ELSE '' END,
   CASE WHEN StagingInvestigations <> 0  OR [Stage] <> 0 THEN   '<br/> Performance Status - '  ELSE 'Performance Status - 'END,
   -- Performance Status
		CASE WHEN [PerformanceStatus] = 1 THEN
		CASE
		WHEN [PerformanceStatusType] = 1 THEN 'normal activity'
		WHEN [PerformanceStatusType] = 2 THEN 'able to carry out light work'
		WHEN [PerformanceStatusType] = 3 THEN 'unable to carry out any work'
		WHEN [PerformanceStatusType] = 4 THEN 'limited self care'
		WHEN [PerformanceStatusType] = 5 THEN 'completely disabled'
		ELSE ''
		END
		ELSE NULL
		END)
	FROM [ERS_ProcedureStaging] where ProcedureId = @ProcedureId
	 )
 
	IF LEN(@StageString) > 0
	BEGIN

	SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Staging: ' + @StageString
	END


	--   End of TFS#	3866
-------------------Previous surgery

SELECT @PreviousSurgeryString =
	LTRIM(STUFF((SELECT DISTINCT ', ' + [Description] 
	--+ CASE WHEN ListItemText = 'Unknown' THEN '' ELSE ' ' + ListItemText END 
	as [text()] 
	FROM ERS_PatientPreviousSurgery h
	INNER JOIN ERS_PreviousSurgery r on r.UniqueID = h.PreviousSurgeryID
	INNER JOIN dbo.ERS_PreviousSurgeryProcedureTypes pspt ON pspt.PreviousSurgeryId = r.UniqueId AND pspt.ProcedureTypeId = @ProcedureTypeId
	--INNER JOIN ERS_Lists l on l.ListItemNo = h.PreviousSurgeryPeriod and ListDescription = 'Follow up disease Period'
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
	(SELECT TOP 1 a.[description]
	FROM ERS_PatientASAStatus pa 
		INNER JOIN ERS_ASAStatus a on a.uniqueid = pa.asastatusid
		INNER JOIN ERS_Procedures p ON p.ProcedureId = pa.ProcedureCreatedId
	WHERE p.ProcedureId = @ProcedureId
	order by isnull(pa.WhenUpdated, pa.WhenCreated))

IF LEN(@ASAStatusString) > 0 
BEGIN
	SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'ASA Status: ' + @ASAStatusString
END
-------------------Previous diseases

SELECT @PreviousDiseasesString =
	LTRIM(STUFF((SELECT DISTINCT ', ' + [Description] as [text()] 
	FROM ERS_PatientPreviousDiseases pd
	INNER JOIN ERS_PreviousDiseases d on d.UniqueID = pd.PreviousDiseaseID
	INNER JOIN dbo.ERS_PreviousDiseaseProcedureTypes ppt ON ppt.PreviousDiseaseId = d.UniqueId AND ppt.ProcedureTypeId = @ProcedureTypeId
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

IF LEN(@FamilyDiseaseHistoryString) > 0 AND @ProcedureTypeId NOT IN(10, 11) -- TFS 4061
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
-- edited by mostafiz issue 3892
SELECT @LUTSIPSSString =
    LTRIM(STUFF((SELECT ', ' + 
                        CASE 
                            WHEN SectionName <> 'Quality of life due to urinary symptoms' THEN SectionName + '(Score:' + CAST(ls.ScoreValue AS VARCHAR(10)) + ')' -- TFS 3892
                        END AS [text()]
                FROM ERS_ProcedureLUTSIPSSSymptoms a
                INNER JOIN ERS_LUTSIPSSSymptoms b ON a.LUTSIPSSSymptomId = b.UniqueId
                INNER JOIN ERS_LUTSIPSSSymptomSections s ON b.LUTSIPSSSymptomSectionId = s.LUTSIPSSSymptomSectionId
                INNER JOIN ERS_IPSSScore ls ON a.SelectedScoreId = ls.ScoreId
                WHERE ProcedureId = @ProcedureId AND SelectedScoreId > 1
                FOR XML PATH('')), 1, 1, ''))
-- edited by mostafiz issue 3892
--SELECT @LUTSIPSSString = dbo.fnCapitalise(dbo.fnAddFullStop(@LUTSIPSSString)) 

select top 1  @LUTSIPSSTotalScoreString =  'Total Score :' + cast(TotalScoreValue as varchar(10)) 
from  ERS_ProcedureLUTSIPSSSymptoms where ProcedureId=@ProcedureId
IF LEN(@LUTSIPSSString) > 0
BEGIN
	IF charindex(',', reverse(@LUTSIPSSString)) > 0
		--TFS 3892 Start
		BEGIN
			SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>LUTS\IPSS symptom score:</b>' + @LUTSIPSSString
			SET @RetVal = @RetVal + ' ' + @LUTSIPSSTotalScoreString + ' '+'<br />'
		END 
		--TFS 3892 End
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>LUTS\IPSS symptom score:</b> ' + @LUTSIPSSString

	--SELECT @RetVal = ISNULL(@RetVal + '<br />', '') +  @LUTSIPSSTotalScoreString
END

-- TFS 3892 Start

DECLARE @QualityOfLife varchar(max)

SELECT @QualityOfLife =
    LTRIM(STUFF((SELECT ', ' + 
                        CASE
                            WHEN SectionName = 'Quality of life due to urinary symptoms' THEN (SectionName + '(Score:' + CAST(ls.ScoreValue AS VARCHAR(10)) + ' - ' + (SELECT ScoreDescription FROM ERS_IPSSScoreQuality WHERE ScoreId = ls.ScoreId)+')')
                        END AS [text()]
                FROM ERS_ProcedureLUTSIPSSSymptoms a
                INNER JOIN ERS_LUTSIPSSSymptoms b ON a.LUTSIPSSSymptomId = b.UniqueId
                INNER JOIN ERS_LUTSIPSSSymptomSections s ON b.LUTSIPSSSymptomSectionId = s.LUTSIPSSSymptomSectionId
                INNER JOIN ERS_IPSSScore ls ON a.SelectedScoreId = ls.ScoreId
                WHERE ProcedureId = @ProcedureId AND SelectedScoreId >= 1
                FOR XML PATH('')), 1, 1, ''))
IF LEN(@QualityOfLife) > 0
BEGIN
	SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + @QualityOfLife
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
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Urine Dipstick And Cytology:</b>' + @UrineDipstickCytologyString --MH closed bold tag </b> here on 18 Apr 2024
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
		   @CTScanAvailable=CTScanAvailable
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

------------------------------------------------------------------------------------------------------------------------
-- TFS#	3892, 4061, 3544, 3892 Ended
------------------------------------------------------------------------------------------------------------------------

GO
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Duncan		
-- TFS#	N/A
-- Description of change
-- Add room name to the procedure details report
------------------------------------------------------------------------------------------------------------------------
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
		,ISNULL(r.RoomName, 'Unknown') as 'Procedure Room'
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
left outer join ERS_ImagePort imgp on imgp.ImagePortId = p.ImagePortId
left outer join ERS_SCH_Rooms r on r.RoomId = imgp.RoomId
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
-- Updated by	:	Steve		
-- TFS#	N/A
-- Description of change
-- Fix for Pathway Plan validation of Evidence of Cancer
------------------------------------------------------------------------------------------------------------------------

GO
dbo.DropIfExist
    @ObjectName = 'check_requiredfields',      -- varchar(100)
    @ObjectTypePrefix = 'S' -- varchar(5)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[check_requiredfields]
(
	@ProcedureId INT,
	@PageId INT,
	@LoggedInUserId INT,
	@OperatingHospitalId INT
)
AS
BEGIN
	DECLARE @ProcedureTypeId INT,@NEDEnabled int, @ProcedureDNA INT, @UISectionId INT, @SectionName VARCHAR(50), @SectionPageId INT, @SectionControl VARCHAR(50), @IncompleteSections VARCHAR(MAX) = '', @ProcedureModifiedDate DATETIME, @ProcedureCompleted BIT, @FITValue int,@ReportUpdated BIT
	SELECT @ProcedureTypeId = ProcedureType, @ProcedureDNA = ISNULL(DNA,0), @ProcedureModifiedDate = ModifiedOn, @ProcedureCompleted = ISNULL(ProcedureCompleted,0),@ReportUpdated = ReportUpdated FROM ERS_Procedures WHERE ProcedureId = @ProcedureId
	
	DECLARE @ProcedureEndoCount INT
	IF EXISTS (SELECT 1 FROM ERS_Procedures WHERE ProcedureId = @ProcedureId AND Endoscopist2 IS NOT NULL)
		SET @ProcedureEndoCount = 2
	ELSE
		SET @ProcedureEndoCount = 1

	IF @ReportUpdated = 1 AND @ProcedureModifiedDate >= (SELECT TOP 1 InstallDate
																FROM DBVersion
																WHERE SUBSTRING(VersionNum,1,1) = '2'
																ORDER BY InstallDate ASC)
	SET @NEDEnabled=(select isnull(NEDEnabled,1) from ERS_Procedures where ProcedureId=@ProcedureId) -- TFS 3911
	

	BEGIN
	IF @ProcedureTypeId NOT IN (10,11,13) 
		BEGIN
		
	
			DECLARE cur CURSOR FOR (SELECT DISTINCT us.UISectionId, SectionName, PageId, SectionControl
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
					SET @IncompleteSections =@IncompleteSections + '&bull;' + @SectionName + '<br />'
				END
		
				IF LOWER(@SectionName) = 'extent' AND CHARINDEX('extent',@IncompleteSections) = 0 /*no point validating if its not complete*/
				BEGIN
					IF (SELECT COUNT(*) FROM dbo.ERS_ProcedureSummary WHERE ProcedureId = @ProcedureId AND SectionId = @UISectionId) < @ProcedureEndoCount
					BEGIN
						SET @IncompleteSections = @IncompleteSections + '&bull;' + @SectionName + ' is incomplete. Both ensocopists must record their result<br />'
					END
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
					IF @StartTime > @EndTime OR @StartTime = @EndTime
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
					else if exists (select 1 from ERS_ProcedureSubIndications where procedureid=@ProcedureId and SubIndicationId=(select UniqueId from ERS_SubIndications where [Description]='Other') and len(AdditionalInfo)=0)--TFS 4078
					begin
						SET @IncompleteSections = @IncompleteSections + '&bull;Subindications<br />'
					end
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

			--edited by siddik #TFS 3779
			DECLARE @PacemakerId INT = (SELECT UniqueId FROM ERS_Comorbidity WHERE Description = 'Pacemaker')
			DECLARE @DiabetesMellitusId INT = (SELECT UniqueId FROM ERS_Comorbidity WHERE Description = 'Diabetes Mellitus')
			IF @PageId IN (0, 1)
			BEGIN
				IF EXISTS (SELECT 1 FROM ERS_ProcedureComorbidity WHERE ProcedureId = @ProcedureId AND ChildComorbidityId = 0 AND ComorbidityId IN (@PacemakerId, @DiabetesMellitusId))
				BEGIN
					SET @IncompleteSections = @IncompleteSections + '&bull;Comorbidity<br />'
				END
			END
	
			IF EXISTS (SELECT 1 FROM ERS_UrgencyTypes c LEFT JOIN ERS_Procedures p ON c.UniqueId = p.CategoryListId WHERE p.ProcedureId = @ProcedureId AND c.Description = 'Urgent (suspected cancer pathway)')
				AND @PageId IN (0,3)
				AND @ProcedureDNA = 0
			BEGIN
				DECLARE @QuestionId INT = (SELECT QuestionId FROM ERS_PathwayPlanQuestions WHERE Question='Evidence of cancer?' AND ProcedureType = @ProcedureTypeId AND OperatingHospital = @OperatingHospitalId)
				IF @QuestionId > 0 AND NOT EXISTS (SELECT 1 FROM ERS_ProcedurePathwayPlanAnswers WHERE ProcedureId = @ProcedureId AND QuestionId = @QuestionId)
				BEGIN
					INSERT INTO ERS_ProcedurePathwayPlanAnswers (ProcedureId, QuestionId, OptionAnswer, WhoCreatedId, WhenCreated)
					VALUES (@ProcedureId, @QuestionId, 1, @LoggedInUserId, getdate())
				END
			
				IF NOT EXISTS (SELECT 1 FROM ERS_PathwayPlanQuestions q LEFT JOIN ERS_ProcedurePathwayPlanAnswers a ON q.QuestionId = a.QuestionId WHERE a.ProcedureId = @ProcedureId AND q.Question = 'Evidence of cancer?')
				BEGIN
					SET @IncompleteSections = @IncompleteSections + '&bull;Pathway Plan<br />'
				END
			END
		END
		--Updated by	:	Muhammad Nasim
		--Add Anicoag validation for Cystoscopy
		IF @ProcedureTypeId=13
			begin
				IF (SELECT AntiCoagDrugs FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)=1
				BEGIN
					IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureSummary WHERE ProcedureId = @ProcedureId AND SectionId = @UISectionId)
					BEGIN
						SET @IncompleteSections = REVERSE(SUBSTRING(REVERSE(@IncompleteSections), CHARINDEX('<br />', REVERSE(@IncompleteSections)) + 7, LEN(@IncompleteSections))) + '<small><em> - RX drugs must be complete for patients that are taking Anti-coag or Anti-platelet Medication</em></small><br />'						
					END
				END
			end
		--End of Anicoag validation
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

--Update Terminal Ileum Ulcer(s) Matrix code if it exists, Otherwise add it.
IF EXISTS(SELECT 1 FROM ERS_DiagnosesMatrix WHERE Section = 'Colon' AND ProcedureTypeID = 3 AND CODE = 'D100P3')
	UPDATE ERS_DiagnosesMatrix SET DisplayName = 'Terminal Ileum Ulcer(s)'
	WHERE Section = 'Colon' AND ProcedureTypeID = 3 AND CODE = 'D100p3'
ELSE
	INSERT INTO ERS_DiagnosesMatrix (DisplayName, ProcedureTypeID, Section, OrderByNumber, Code)
	VALUES ('Terminal Ileum Ulcer(s)', 3, 'Colon', 32, 'D100P3')

GO
IF (SELECT DATA_TYPE 
	FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE TABLE_NAME = 'ERS_PagesByRole'
	AND COLUMN_NAME = 'AccessLevel') != 'tinyint'
		Alter table ERS_PagesByRole alter column AccessLevel tinyint 
GO

----------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Andrea 01.08.24
-- TFS#	3708
-- Description of change
-- Anti-coag drugs to accept free text
------------------------------------------------------------------------------------------------------------------------
GO



IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID('ERS_ProcedureAntiCoagDrugs'))

BEGIN
    CREATE TABLE [dbo].[ERS_ProcedureAntiCoagDrugs](
    	[ProcedureAntiCoagDrugsId] [INT] IDENTITY(1,1) NOT NULL,
    	[ProcedureId] [INT] NOT NULL,
    	[AntiCoagDrugText] [VARCHAR](MAX) NOT NULL,
    	[WhoCreatedId] [INT] NOT NULL,
    	[WhenCreated] [DATETIME] NOT NULL,
    	[WhoUpdatedId] [INT] NULL,
    	[WhenUpdated] [NCHAR](10) NULL,
     CONSTRAINT [PK_ERS_ProcedureAntiCoagDrugs] PRIMARY KEY CLUSTERED 
    (
    	[ProcedureAntiCoagDrugsId] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    
    ALTER TABLE [dbo].[ERS_ProcedureAntiCoagDrugs] ADD  CONSTRAINT [DF_ERS_ProcedureAntiCoagDrugs_WhenCreated]  DEFAULT (GETDATE()) FOR [WhenCreated]
    
    ALTER TABLE [dbo].[ERS_ProcedureAntiCoagDrugs]  WITH CHECK ADD  CONSTRAINT [FK_ERS_ProcedureAntiCoagDrugs_ERS_Procedures] FOREIGN KEY([ProcedureId])
    REFERENCES [dbo].[ERS_Procedures] ([ProcedureId])
    
    ALTER TABLE [dbo].[ERS_ProcedureAntiCoagDrugs] CHECK CONSTRAINT [FK_ERS_ProcedureAntiCoagDrugs_ERS_Procedures]
    
    ALTER TABLE [dbo].[ERS_ProcedureAntiCoagDrugs]  WITH CHECK ADD  CONSTRAINT [FK_ERS_ProcedureAntiCoagDrugs_ERS_Users_Created] FOREIGN KEY([WhoCreatedId])
    REFERENCES [dbo].[ERS_Users] ([UserID])
    
    ALTER TABLE [dbo].[ERS_ProcedureAntiCoagDrugs] CHECK CONSTRAINT [FK_ERS_ProcedureAntiCoagDrugs_ERS_Users_Created]
    
    ALTER TABLE [dbo].[ERS_ProcedureAntiCoagDrugs]  WITH CHECK ADD  CONSTRAINT [FK_ERS_ProcedureAntiCoagDrugs_ERS_Users_Updated] FOREIGN KEY([WhoUpdatedId])
    REFERENCES [dbo].[ERS_Users] ([UserID])
    
    ALTER TABLE [dbo].[ERS_ProcedureAntiCoagDrugs] CHECK CONSTRAINT [FK_ERS_ProcedureAntiCoagDrugs_ERS_Users_Updated]
    
    
    
END
GO

EXEC dbo.DropIfExist @ObjectName = 'procedure_anti_coag_drugs_save',      -- varchar(100)
                     @ObjectTypePrefix = 'S' -- varchar(5)

GO

CREATE PROCEDURE dbo.procedure_anti_coag_drugs_save
(
	@ProcedureId INT,
	@DrugText VARCHAR(MAX),
	@LoggedInUserId int
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureAntiCoagDrugs WHERE ProcedureId = @ProcedureId)
	BEGIN
	    INSERT INTO ERS_ProcedureAntiCoagDrugs (ProcedureId, AntiCoagDrugText, WhoCreatedId, WhenCreated)
		VALUES (@ProcedureId, @DrugText, @LoggedInUserId, GETDATE())
	END
	ELSE
    BEGIN
        UPDATE ERS_ProcedureAntiCoagDrugs SET AntiCoagDrugText = @DrugText WHERE ProcedureId = @ProcedureId
    END

	UPDATE ERS_ProceduresReporting 
			SET PP_Indic = dbo.ProcedureIndicationsSummary(@ProcedureId)
			WHERE ProcedureId = @ProcedureId

	IF @DrugText <> ''
	BEGIN
	    EXEC dbo.UI_update_procedure_summary @ProcedureId = @ProcedureId,  
	                                         @Section = 'Anti-coag drugs',     
	                                         @Summary = 'Anti-coag drugs',     
	                                         @ResultId = 1
	END
	ELSE	
	BEGIN
	    EXEC dbo.UI_update_procedure_summary @ProcedureId = @ProcedureId,  
	                                         @Section = 'Anti-coag drugs',     
	                                         @Summary = 'Anti-coag drugs',     
	                                         @ResultId = 0
	END

END
GO

ALTER PROCEDURE [dbo].[patient_anti_coag_drugs_select]
(
	@ProcedureId int
)
AS
BEGIN
	SELECT ISNULL(p.AntiCoagDrugs, 0) AntiCoagDrugs, ISNULL(d.AntiCoagDrugText,'') AntiCoagDrugText
	FROM ERS_Procedures p
		LEFT JOIN ERS_ProcedureAntiCoagDrugs d ON d.ProcedureId = p.ProcedureId
	WHERE p.ProcedureId = @ProcedureID 
END
GO


ALTER PROCEDURE [dbo].[patient_anti_coag_drugs_save]
(
	@ProcedureId int,
	@AntiCoagDrugs BIT
)
AS
BEGIN
	BEGIN
	    UPDATE ERS_Procedures SET AntiCoagDrugs = @AntiCoagDrugs WHERE ProcedureId = @ProcedureId
	    DECLARE  @SectionId int = (SELECT UISectionId FROM UI_Sections WHERE SectionName = 'Anti-coag drugs')
	    DECLARE @AntiCoagDrugsComplete BIT, @RXComplete BIT
        
	    DELETE FROM ERS_ProcedureSummary WHERE ProcedureId = @ProcedureId AND SectionId = @SectionId
		IF @AntiCoagDrugs = 1
		BEGIN
		    --check if any text has been entered
			IF EXISTS(SELECT 1 FROM ERS_ProcedureAntiCoagDrugs WHERE ProcedureId = @ProcedureId AND ISNULL(AntiCoagDrugText,'') <> '')
			BEGIN
			    SET @AntiCoagDrugsComplete = 1
			END
			ELSE
            BEGIN
                SET @AntiCoagDrugsComplete = 0
            END

			--check if RX is filled in 
			IF EXISTS (SELECT 1 FROM ERS_UpperGIRx WHERE ProcedureId = @ProcedureId AND Summary <> '')
			BEGIN
			    SET @RXComplete = 1
			END
			ELSE	
			BEGIN
			    SET @RXComplete = 0
			END

			exec UI_update_procedure_summary @ProcedureId, 'Anti-coag drugs', 'Anti-coag drugs', @AntiCoagDrugsComplete
			exec UI_update_procedure_summary @ProcedureId, 'RX', 'RX', @RXComplete
		END
		ELSE IF @AntiCoagDrugs = 0
        BEGIN
            DELETE FROM ERS_ProcedureAntiCoagDrugs WHERE ProcedureId = @ProcedureId

	    	exec UI_update_procedure_summary @ProcedureId, 'Anti-coag drugs', 'Anti-coag drugs', 1
			exec UI_update_procedure_summary @ProcedureId, 'RX', 'RX', 1

			UPDATE ERS_ProceduresReporting 
			SET PP_Indic = dbo.ProcedureIndicationsSummary(@ProcedureId)
			WHERE ProcedureId = @ProcedureId --edited by mostafiz 4090
        END
	END
END
GO


ALTER FUNCTION [dbo].[ProcedureIndicationsSummary]
(
	@ProcedureId INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

DECLARE @StageString  varchar(max),@IndicationsString  varchar(max), @ComorbidityString varchar(max), @AntiCoagDrugsString VARCHAR(MAX), @DamagingDrugsString varchar(max), @PatientAllergiesString varchar(max), @PreviousSurgeryString varchar(max), 
		@PreviousDiseasesString varchar(max), @FamilyDiseaseHistoryString varchar(max), @ImagingString varchar(max), @ImagingOutcomeString varchar(max),
		@RetVal varchar(max), @ProcedureTypeId INT

SELECT @ProcedureTypeId = ProcedureType FROM dbo.ERS_Procedures WHERE ProcedureId = @ProcedureId

SELECT @IndicationsString =
	LTRIM(STUFF((SELECT ', ' + CASE WHEN i.AdditionalInfo = 0 THEN [Description] ELSE AdditionalInformation END + 
	CASE WHEN ISNULL(ChildIndicationId, 0) > 0 THEN '-' + (SELECT [Description] FROM ERS_Indications WHERE UniqueId = epi.ChildIndicationId) ELSE '' END + 
	CASE WHEN i.AdditionalInfo = 0 AND ISNULL(AdditionalInformation, '') <> '' THEN ' ' + AdditionalInformation ELSE '' END AS [text()] 
	FROM ERS_ProcedureIndications epi 
	INNER JOIN ERS_Indications i on i.UniqueId = epi.IndicationId
	WHERE ProcedureId=@ProcedureId
	ORDER BY ISNULL(i.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

--rockall and baltchford scoring
--changed by mostafiz 3702

SELECT @IndicationsString	= @IndicationsString + CASE WHEN CHARINDEX('melaena', @IndicationsString) > 0 OR CHARINDEX('haematemesis', @IndicationsString) > 0 THEN ' ' + dbo.fnBlatchfordRockallScores(@ProcedureId) ELSE '' END
--SELECT @IndicationsString = dbo.fnCapitalise(dbo.fnAddFullStop(@IndicationsString)) 

IF LEN(@IndicationsString) > 0
BEGIN
	IF charindex(',', reverse(@IndicationsString)) > 0
		SELECT @RetVal = STUFF(@IndicationsString, len(@IndicationsString) - charindex(' ,', reverse(@IndicationsString)) + 0, 1, ' and ')
	ELSE
		SELECT @RetVal = @IndicationsString
END
--changed by mostafiz 3702
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

--TFS 3544 Start

DECLARE @AntiCoagDrugs bit = (SELECT AntiCoagDrugs FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
SET @AntiCoagDrugsString = ''

IF @AntiCoagDrugs IS NOT NULL
	If @AntiCoagDrugs = 1 SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'The patient is taking anti-coagulant or anti-platelet medication.'

SELECT @AntiCoagDrugsString =
	(SELECT ISNULL(AntiCoagDrugText,'') FROM dbo.ERS_ProcedureAntiCoagDrugs WHERE ProcedureId = @ProcedureId)

IF LEN(@AntiCoagDrugsString) > 0
BEGIN
	SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Anti-Coagulant drug(s): ' + @AntiCoagDrugsString
END


SELECT @DamagingDrugsString =
	LTRIM(STUFF((SELECT ', ' + [Description] AS [text()] 
	FROM ERS_ProcedureDamagingDrugs edd 
	INNER JOIN ERS_PotentialDamagingDrugs d on d.uniqueid = edd.DamagingDrugId AND d.AntiCoag = 0
	WHERE edd.ProcedureId=@ProcedureId
	ORDER BY ISNULL(d.ListOrderBy, 0)
	FOR XML PATH('')),1,1,''))

IF LEN(@DamagingDrugsString) > 0
BEGIN
	IF charindex(',', reverse(@DamagingDrugsString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Potentially Significant drugs(s): ' + STUFF(@DamagingDrugsString, len(@DamagingDrugsString) - charindex(' ,', reverse(@DamagingDrugsString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Potentially Significant drugs(s): ' + @DamagingDrugsString
END

--TFS 3544 End

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
------------------- Staging
--TFS#	3866
	SELECT @StageString=
  (SELECT   CONCAT(
	  --Staging Investigations
		CASE 
          WHEN StagingInvestigations <> 0 THEN 
			 (CASE WHEN [ClinicalGrounds] = 1 THEN 'Clinical Grounds only' ELSE '' END) +
			
			 (CASE WHEN [ImagingOfThorax] = 1 THEN 
			  CASE WHEN [ClinicalGrounds] = 1 THEN ', Cross sectional imaging of thorax' ELSE 'Cross sectional imaging of thorax' END
			  ELSE '' END) +
			
			 (CASE WHEN [PleuralHistology] = 1 THEN
			 CASE WHEN [ClinicalGrounds] = 1 OR [ImagingOfThorax] = 1 THEN ', Pleural cytology / histology' ELSE 'Pleural cytology / histology' END
			 ELSE '' END) +
			 (CASE WHEN [MediastinalSampling] = 1 THEN 
			 CASE WHEN [ClinicalGrounds] = 1 OR [ImagingOfThorax] = 1 OR [PleuralHistology] = 1 THEN ', Mediastinal Sampling' ELSE 'Mediastinal Sampling' END
			 ELSE '' END) +
			 (CASE WHEN [Metastases] = 1 THEN 
			 CASE WHEN [ClinicalGrounds] = 1 OR [ImagingOfThorax] = 1 OR [PleuralHistology] = 1 OR [MediastinalSampling] = 1 THEN ', Diagnostic tests for metastases' ELSE 'Diagnostic tests for metastases' END
			 ELSE '' END) + 
			 (CASE WHEN [Bronchoscopy] = 1 THEN 
			 CASE WHEN [ClinicalGrounds] = 1 OR [ImagingOfThorax] = 1 OR [PleuralHistology] = 1 OR [MediastinalSampling] = 1 OR [Metastases] = 1 THEN ', Bronchoscopy' ELSE 'Bronchoscopy' END
			 ELSE '' END)
         ELSE ''
       END,
	   CASE WHEN ([ClinicalGrounds] = 1 OR [ImagingOfThorax] = 1 OR [PleuralHistology] = 1 OR [MediastinalSampling] = 1 OR [Metastases] = 1 OR Bronchoscopy = 1 ) AND [Stage] = 1  THEN   ' <br/> '  ELSE ''END,
		--stage
		CASE WHEN [Stage] = 1 THEN
		     CONCAT (		 
			 CASE WHEN StageLocation <> 0 then 
			 CONCAT ('Location of primary tumour - ' , CASE WHEN StageLocation = 1 THEN 'Oesophagus' 
	         WHEN StageLocation = 2 THEN 'Oesophagogastric junction' 
	         WHEN StageLocation = 3 THEN 'Stomach' 
             ELSE ''
	         END)
	    ELSE '' END,
			 	 
	 CASE WHEN StageLocation <> 0  AND (StageT <> 0 OR StageN <> 0 OR StageM <> 0 ) THEN ' and ' ELSE ''END,	 
	 CASE WHEN StageT <> 0 then
	 CONCAT ('T - ', CASE WHEN StageT = 1 THEN 'TX' 
	      WHEN StageT = 2 THEN 'T0' 
	      WHEN StageT = 3 THEN 'Tis' 
		  WHEN StageT = 4 THEN 'T1' 
		  WHEN StageT = 5 THEN 'T1a' 
		  WHEN StageT = 6 THEN 'T1b' 
		  WHEN StageT = 7 THEN 'T2' 
	      WHEN StageT = 8 THEN 'T3'
	      WHEN StageT = 9 THEN 'T4'
	      WHEN StageT = 10 THEN 'T4a'
	      WHEN StageT = 11 THEN 'T4b'
	 ELSE ''
	 END )


	 ELSE '' END,
	 CASE WHEN (StageT <> 0  )  AND StageN <> 0 THEN ', ' ELSE ''END,
	 CASE WHEN StageN <> 0 THEN 
	 CONCAT ('N - ', CASE WHEN StageN = 1 THEN 'NX' 
	      WHEN StageN = 2 THEN 'N0' 
	      WHEN StageN = 3 THEN 'N1' 
		  WHEN StageN = 4 THEN 'N2' 
		  WHEN StageN = 5 THEN 'N3' 
	 ELSE ''
	 END)
	 ELSE '' END,
	 CASE WHEN (StageN <> 0 or StageT <> 0  ) AND StageM <> 0 THEN ', ' ELSE ''END,
	 	 CASE WHEN StageM <> 0 THEN
		    CONCAT ('M - ', CASE WHEN StageM = 1 THEN 'MX' 
	        WHEN StageM = 2 THEN 'M0' 
	        WHEN StageM = 3 THEN 'M1' 
	        ELSE ''
	        END)
	    ELSE '' end
           )
	ELSE '' END,
   CASE WHEN StagingInvestigations <> 0  OR [Stage] <> 0 THEN   '<br/> Performance Status - '  ELSE 'Performance Status - 'END,
   -- Performance Status
		CASE WHEN [PerformanceStatus] = 1 THEN
		CASE
		WHEN [PerformanceStatusType] = 1 THEN 'normal activity'
		WHEN [PerformanceStatusType] = 2 THEN 'able to carry out light work'
		WHEN [PerformanceStatusType] = 3 THEN 'unable to carry out any work'
		WHEN [PerformanceStatusType] = 4 THEN 'limited self care'
		WHEN [PerformanceStatusType] = 5 THEN 'completely disabled'
		ELSE ''
		END
		ELSE NULL
		END)
	FROM [ERS_ProcedureStaging] where ProcedureId = @ProcedureId
	 )
 
	IF LEN(@StageString) > 0
	BEGIN

	SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'Staging: ' + @StageString
	END


	--   End of TFS#	3866
-------------------Previous surgery

SELECT @PreviousSurgeryString =
	LTRIM(STUFF((SELECT DISTINCT ', ' + [Description] 
	--+ CASE WHEN ListItemText = 'Unknown' THEN '' ELSE ' ' + ListItemText END 
	as [text()] 
	FROM ERS_PatientPreviousSurgery h
	INNER JOIN ERS_PreviousSurgery r on r.UniqueID = h.PreviousSurgeryID
	INNER JOIN dbo.ERS_PreviousSurgeryProcedureTypes pspt ON pspt.PreviousSurgeryId = r.UniqueId AND pspt.ProcedureTypeId = @ProcedureTypeId
	--INNER JOIN ERS_Lists l on l.ListItemNo = h.PreviousSurgeryPeriod and ListDescription = 'Follow up disease Period'
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
	(SELECT TOP 1 [description]
	FROM ERS_PatientASAStatus pa 
		INNER JOIN ERS_ASAStatus a on a.uniqueid = pa.asastatusid
		INNER JOIN ERS_Procedures p ON p.PatientId = pa.PatientId
	WHERE ProcedureId = @ProcedureId
	order by isnull(pa.WhenUpdated, pa.WhenCreated))

IF LEN(@ASAStatusString) > 0 
BEGIN
	SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + 'ASA Status: ' + @ASAStatusString
END
-------------------Previous diseases

SELECT @PreviousDiseasesString =
	LTRIM(STUFF((SELECT DISTINCT ', ' + [Description] as [text()] 
	FROM ERS_PatientPreviousDiseases pd
	INNER JOIN ERS_PreviousDiseases d on d.UniqueID = pd.PreviousDiseaseID
	INNER JOIN dbo.ERS_PreviousDiseaseProcedureTypes ppt ON ppt.PreviousDiseaseId = d.UniqueId AND ppt.ProcedureTypeId = @ProcedureTypeId
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

IF LEN(@FamilyDiseaseHistoryString) > 0 AND @ProcedureTypeId NOT IN(10, 11) -- TFS 4061
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
-- edited by mostafiz issue 3892
SELECT @LUTSIPSSString =
    LTRIM(STUFF((SELECT ', ' + 
                        CASE 
                            WHEN SectionName <> 'Quality of life due to urinary symptoms' THEN SectionName + '(Score:' + CAST(ls.ScoreValue AS VARCHAR(10)) + ')' -- TFS 3892
                        END AS [text()]
                FROM ERS_ProcedureLUTSIPSSSymptoms a
                INNER JOIN ERS_LUTSIPSSSymptoms b ON a.LUTSIPSSSymptomId = b.UniqueId
                INNER JOIN ERS_LUTSIPSSSymptomSections s ON b.LUTSIPSSSymptomSectionId = s.LUTSIPSSSymptomSectionId
                INNER JOIN ERS_IPSSScore ls ON a.SelectedScoreId = ls.ScoreId
                WHERE ProcedureId = @ProcedureId AND SelectedScoreId > 1
                FOR XML PATH('')), 1, 1, ''))
-- edited by mostafiz issue 3892
--SELECT @LUTSIPSSString = dbo.fnCapitalise(dbo.fnAddFullStop(@LUTSIPSSString)) 

select top 1  @LUTSIPSSTotalScoreString =  'Total Score :' + cast(TotalScoreValue as varchar(10)) 
from  ERS_ProcedureLUTSIPSSSymptoms where ProcedureId=@ProcedureId
IF LEN(@LUTSIPSSString) > 0
BEGIN
	IF charindex(',', reverse(@LUTSIPSSString)) > 0
		--TFS 3892 Start
		BEGIN
			SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>LUTS\IPSS symptom score:</b>' + @LUTSIPSSString
			SET @RetVal = @RetVal + ' ' + @LUTSIPSSTotalScoreString + ' '+'<br />'
		END 
		--TFS 3892 End
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>LUTS\IPSS symptom score:</b> ' + @LUTSIPSSString

	--SELECT @RetVal = ISNULL(@RetVal + '<br />', '') +  @LUTSIPSSTotalScoreString
END

-- TFS 3892 Start

DECLARE @QualityOfLife varchar(max)

SELECT @QualityOfLife =
    LTRIM(STUFF((SELECT ', ' + 
                        CASE
                            WHEN SectionName = 'Quality of life due to urinary symptoms' THEN (SectionName + '(Score:' + CAST(ls.ScoreValue AS VARCHAR(10)) + ' - ' + (SELECT ScoreDescription FROM ERS_IPSSScoreQuality WHERE ScoreId = ls.ScoreId)+')')
                        END AS [text()]
                FROM ERS_ProcedureLUTSIPSSSymptoms a
                INNER JOIN ERS_LUTSIPSSSymptoms b ON a.LUTSIPSSSymptomId = b.UniqueId
                INNER JOIN ERS_LUTSIPSSSymptomSections s ON b.LUTSIPSSSymptomSectionId = s.LUTSIPSSSymptomSectionId
                INNER JOIN ERS_IPSSScore ls ON a.SelectedScoreId = ls.ScoreId
                WHERE ProcedureId = @ProcedureId AND SelectedScoreId >= 1
                FOR XML PATH('')), 1, 1, ''))
IF LEN(@QualityOfLife) > 0
BEGIN
	SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + @QualityOfLife
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
	FROM ERS_ProcedureUrineDipstickCytology a,ERS_UrineDipstickCytology b,ERS_UrineDipstickCytology c
	WHERE a.ProcedureId=@ProcedureId
	AND a.UrineDipstickCytologyId=b.UniqueId
	AND a.ChildUrineDipstickCytologyId=c.UniqueId
	ORDER BY b.UrineDipstickCytologySectionId,b.ListOrderBy
	FOR XML PATH('')),1,1,''))

--SELECT @UrineDipstickCytologyString = dbo.fnCapitalise(dbo.fnAddFullStop(@UrineDipstickCytologyString)) 


IF LEN(@UrineDipstickCytologyString) > 0
BEGIN
	IF CHARINDEX(',', REVERSE(@UrineDipstickCytologyString)) > 0
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Urine Dipstick And Cytology:</b>' + STUFF(@UrineDipstickCytologyString, LEN(@UrineDipstickCytologyString) - CHARINDEX(' ,', REVERSE(@UrineDipstickCytologyString)), 2, ' and ')
	ELSE
		SELECT @RetVal = ISNULL(@RetVal + '<br />', '') + '<b>Urine Dipstick And Cytology:</b>' + @UrineDipstickCytologyString --MH closed bold tag </b> here on 18 Apr 2024
END


--------------Broncs referral data
DECLARE @BroncoReferralDataString VARCHAR(MAX), @DateBronchRequested DATETIME,
		@DateOfReferral DATETIME,
		@LCaSuspectedBySpecialist BIT,
		@CTScanAvailable BIT,
		@DateOfScan DATETIME

	SELECT @DateBronchRequested=DateBronchRequested,
		   @DateOfReferral=DateOfReferral,
		   @LCaSuspectedBySpecialist=LCaSuspectedBySpecialist,
		   @CTScanAvailable=CTScanAvailable
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


SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROCEDURE [dbo].[ogd_rx_save]
(
	@ProcedureId INT,
    @ContMedication BIT,
    @ContMedicationByGP BIT,
    @ContPrescribeMedication BIT,
    @SuggestPrescribe BIT,
    @MedicationText NVARCHAR(1000),
	@IsUserModified BIT,
	@LoggedInUserId INT,
	@setComplete TINYINT

)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
			
	IF NOT EXISTS (SELECT 1 FROM ERS_UpperGIRx WHERE ProcedureId = @ProcedureId)
	BEGIN
		INSERT INTO ERS_UpperGIRx (
			ProcedureId,
			ContMedication,
			ContMedicationByGP,
			ContPrescribeMedication,
			SuggestPrescribe,
			MedicationText,
			Summary,
			WhoCreatedId,
			WhenCreated,
			IsUserModified)
		VALUES (
			@ProcedureId,
			@ContMedication,
			@ContMedicationByGP,
			@ContPrescribeMedication,
			@SuggestPrescribe,
			@MedicationText,
			@MedicationText,
			@LoggedInUserId,
			GETDATE(),
			@IsUserModified)

	END

	ELSE IF (@ContMedication=0 AND @ContMedicationByGP=0 AND @ContPrescribeMedication=0 AND @SuggestPrescribe=0)
	BEGIN
		IF @IsUserModified = 0 OR @IsUserModified IS NULL
			BEGIN
				SELECT @IsUserModified = ISNULL(IsUserModified, 0) FROM ERS_UpperGIRx WHERE ProcedureId = @ProcedureId
			END
		if @IsUserModified = 0
			BEGIN
				DELETE FROM ERS_UpperGIRx 
				WHERE ProcedureId = @ProcedureId 

				UPDATE ERS_ProceduresReporting
				SET PP_Rx = NULL
				WHERE ProcedureId = @ProcedureId
			END
		 Else
			Begin
				UPDATE 
				ERS_UpperGIRx
				SET 
					ContMedication = @ContMedication
					,ContMedicationByGP = @ContMedicationByGP
					,ContPrescribeMedication = @ContPrescribeMedication
					,SuggestPrescribe = @SuggestPrescribe
					,MedicationText = @MedicationText
					,Summary = @MedicationText
					,WhoUpdatedId = @LoggedInUserId
					,WhenUpdated = GETDATE()
					,IsUserModified = @IsUserModified
				WHERE 
					ProcedureId = @ProcedureId
			 END 
	END

	ELSE
	BEGIN
		IF @IsUserModified = 0 OR @IsUserModified IS NULL
			BEGIN
				SELECT @IsUserModified = ISNULL(IsUserModified, 0) FROM ERS_UpperGIRx WHERE ProcedureId = @ProcedureId
			END
		UPDATE 
			ERS_UpperGIRx
		SET 
			ContMedication = @ContMedication
			,ContMedicationByGP = @ContMedicationByGP
			,ContPrescribeMedication = @ContPrescribeMedication
			,SuggestPrescribe = @SuggestPrescribe
			,MedicationText = @MedicationText
			,Summary = @MedicationText
			,WhoUpdatedId = @LoggedInUserId
			,WhenUpdated = GETDATE()
			,IsUserModified = @IsUserModified
		WHERE 
			ProcedureId = @ProcedureId
	END

	--check for anti-coag vs damaging drug vs RX result and set complete if conditions met
	DECLARE @AntiCoagDrugs BIT = (SELECT AntiCoagDrugs FROM ERS_Procedures WHERE ProcedureId = @ProcedureId)
	DECLARE  @SectionId int = (SELECT UISectionId FROM UI_Sections WHERE SectionName = 'Anti-coag drugs')
	    
	IF @AntiCoagDrugs = 1 AND 
	    	((SELECT COUNT(*) FROM ERS_ProcedureAntiCoagDrugs WHERE ProcedureId = @ProcedureId AND ISNULL(AntiCoagDrugText,'') <> '') > 0 
	    AND (SELECT count(*) FROM ERS_UpperGIRx WHERE ProcedureId = @ProcedureId AND Summary <> '') > 0)
	BEGIN
	    exec UI_update_procedure_summary @ProcedureId, 'RX', 'RX', 1
	END
	ELSE IF @AntiCoagDrugs = 1 AND 
	    	((SELECT COUNT(*) FROM ERS_ProcedureAntiCoagDrugs WHERE ProcedureId = @ProcedureId AND ISNULL(AntiCoagDrugText,'') <> '') = 0 
	    OR (SELECT count(*) FROM ERS_UpperGIRx WHERE ProcedureId = @ProcedureId AND Summary <> '') =0)
	BEGIN
	    exec UI_update_procedure_summary @ProcedureId, 'RX', 'RX', 0
	END
	ELSE IF @AntiCoagDrugs = 0
	BEGIN
		exec UI_update_procedure_summary @ProcedureId, 'RX', 'RX', 1
	END

	IF @setComplete = 1 and NOT EXISTS(SELECT 1 FROM ERS_RecordCount WHERE ProcedureId = @ProcedureId AND [Identifier] = 'Rx')
	BEGIN
		INSERT INTO ERS_RecordCount (
			[ProcedureId],
			[SiteId],
			[Identifier],
			[RecordCount]
		)
		VALUES (
			@ProcedureId,
			NULL,
			'Rx',
			1)
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
-- Updated by	:	Andrea 01.08.2024
-- TFS#	3844
-- Description of change
-- previously created other limitations to be classed as a complete section when selected
------------------------------------------------------------------------------------------------------------------------
GO

ALTER  PROCEDURE [dbo].[procedure_upper_extent_save]
(
	@ProcedureId int,
	@ExtentId int,
	@AdditionalInfo varchar(max),
	@EndoscopistId int,
	@JManoeuvreId int, 
	@LimitedById int, 
	@WithdrawalMins int,
	@MucosalJunctionDistance int,
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
05.         08 Nov 2023     MS Add MucosalJunctionDistance column and related logic
06.         12 July 2024    AJ Diagnoses set based on the extent
							
*/
BEGIN
	Declare @bitHasProcedureFailed as bit
	Set @bitHasProcedureFailed = 0

	IF NOT EXISTS (SELECT 1 FROM ERS_ProcedureUpperExtent WHERE ProcedureId = @ProcedureId AND EndoscopistId = @EndoscopistId)
	BEGIN
		INSERT INTO ERS_ProcedureUpperExtent (ProcedureId, ExtentId, AdditionalInfo, EndoscopistId, JManoeuvreId, LimitationId, MucosalJunctionDistance, WhoUpdatedId, WhenUpdated, LimitationOther)
		VALUES (@ProcedureId, NULLIF(@ExtentId,0), NULLIF(@AdditionalInfo,''), @EndoscopistId, NULLIF(@JManoeuvreId,-1), NULLIF(@LimitedById,0), NULLIF(@MucosalJunctionDistance,0), @LoggedInUserId, getdate(), NULLIF(@LimitationOther,''))
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
			MucosalJunctionDistance = NULLIF(@MucosalJunctionDistance,0),
			WithdrawalMins =NULLIF(@WithdrawalMins,0), --edited by mostafiz 2830
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
	SELECT TOP 1 @ExtentDescription = ee.Description, @AdditionalInfo = epue.AdditionalInfo
								FROM dbo.ERS_ProcedureUpperExtent epue 
									INNER JOIN dbo.ERS_Extent ee ON epue.ExtentId = ee.UniqueId
								WHERE epue.ProcedureId=@ProcedureId
								ORDER BY ee.ListOrderBy DESC
	
	/*Handle failed procedures*/
	
	IF @ExtentDescription IN ('intubation failed','abandoned')
	Begin
	
		EXEC diagnoses_set_procedure_failed @ProcedureId
		Set @bitHasProcedureFailed = 1
	END
    
	IF ISNULL(@MucosalJunctionDistance,0) > 0
	BEGIN

		SET @SummaryText = 'The apparent mucosal junction: ' + Convert(varchar(50), @MucosalJunctionDistance) + ' cm ' -- edited by mostafiz 4084
	END

	IF (SELECT COUNT(*) FROM ERS_ProcedureUpperExtent WHERE ProcedureId = @ProcedureId AND NULLIF(JManoeuvreId,-1) IS NOT NULL) > 0
	BEGIN
		DECLARE @JManouvreResult varchar(100)

		/*Overall JManouvre result regardless of who done it, was it done*/
		IF EXISTS (SELECT 1 FROM ERS_ProcedureUpperExtent WHERE ProcedureId = @ProcedureId AND ISNULL(JManoeuvreId,0) = 1)
			SET @JManouvreResult = 'performed. '
		ELSE
			SET @JManouvreResult = 'not carried out. '

		SET @SummaryText = @SummaryText + 'J manoeuvre ' + @JManouvreResult
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
		DECLARE @ExtentListOrder INT
		SELECT @ExtentListOrder = ListOrderBy, @ExtentIsSuccess = IsSuccess FROM ERS_Extent WHERE UniqueId = @ExtentId
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
			IF ISNULL(@LimitationOther,'') <> '' OR (SELECT LOWER(Description) FROM dbo.ERS_Limitations WHERE UniqueId = @LimitedById) <> 'other'
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
		--check if a diagnoses is present or not (will say OverallNorml if nothing's been found)
		IF EXISTS (SELECT 1 FROM dbo.ERS_Diagnoses WHERE ProcedureID = @ProcedureId AND LOWER(MatrixCode) = 'overallnormal')
		BEGIN
		    --if its overallnormal delete it
			DELETE FROM dbo.ERS_Diagnoses WHERE ProcedureID = @ProcedureId AND LOWER(MatrixCode) = 'overallnormal'

			--add oesophagus normal
			INSERT INTO [ERS_Diagnoses] (ProcedureID, SiteID, MatrixCode, [Value], [Region]) 
			VALUES (@ProcedureID, 0, 'OesophagusNormal','true','Oesophagus') 
		END

		--Stomach region is not updated if a abnormality/diagnoses is present
		IF EXISTS (SELECT 1 FROM dbo.ERS_Diagnoses WHERE @ProcedureId = @ProcedureId AND Region = 'Stomach')
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.ERS_Diagnoses WHERE @ProcedureId = @ProcedureId AND Region = 'Stomach' AND MatrixCode = 'StomachNormal') 
			BEGIN
				DELETE FROM dbo.ERS_Diagnoses WHERE ProcedureID = @ProcedureId AND Region = 'Stomach' AND MatrixCode = 'StomachNormal'

				INSERT INTO [ERS_Diagnoses] (ProcedureID, SiteID, MatrixCode, [Value], [Region]) 
				VALUES (@ProcedureID, 0, 'StomachNotEntered','true','Stomach') 
			END
		END
		ELSE
		BEGIN
		    INSERT INTO [ERS_Diagnoses] (ProcedureID, SiteID, MatrixCode, [Value], [Region]) 
		    VALUES (@ProcedureID, 0, 'StomachNotEntered','true','Stomach') 
		END

		--Duodenum region is not updated if a abnormality/diagnoses is present
		IF EXISTS (SELECT 1 FROM dbo.ERS_Diagnoses WHERE @ProcedureId = @ProcedureId AND Region = 'Duodenum')
		BEGIN
		     IF EXISTS (SELECT 1 FROM dbo.ERS_Diagnoses WHERE @ProcedureId = @ProcedureId AND Region = 'Duodenum' AND MatrixCode = 'DuodenumNormal')
			 BEGIN
				DELETE FROM dbo.ERS_Diagnoses WHERE ProcedureID = @ProcedureId AND Region = 'Duodenum' AND MatrixCode = 'DuodenumNormal'

				INSERT INTO [ERS_Diagnoses] (ProcedureID, SiteID, MatrixCode, [Value], [Region]) 
				VALUES (@ProcedureID, 0, 'DuodenumNotEntered','true','Duodenum')
			 END
		END
		ELSE	
		BEGIN
		    INSERT INTO [ERS_Diagnoses] (ProcedureID, SiteID, MatrixCode, [Value], [Region]) 
		    VALUES (@ProcedureID, 0, 'DuodenumNotEntered','true','Duodenum')
		END

		

		EXEC dbo.ogd_diagnoses_summary_update @ProcedureId
	END
	IF LOWER(@ExtentDescription)= 'stomach'
	BEGIN
		--check if a diagnoses is present or not (will say OverallNorml if nothing's been found)
		IF EXISTS (SELECT 1 FROM dbo.ERS_Diagnoses WHERE ProcedureID = @ProcedureId AND LOWER(MatrixCode) = 'overallnormal')
		BEGIN
		    --if its overallnormal delete it
			DELETE FROM dbo.ERS_Diagnoses WHERE ProcedureID = @ProcedureId AND LOWER(MatrixCode) = 'overallnormal'

			--add oesophagus normal
			INSERT INTO [ERS_Diagnoses] (ProcedureID, SiteID, MatrixCode, [Value], [Region]) 
			VALUES (@ProcedureID, 0, 'OesophagusNormal','true','Oesophagus') 

			--add stomach normal
			INSERT INTO [ERS_Diagnoses] (ProcedureID, SiteID, MatrixCode, [Value], [Region]) 
			VALUES (@ProcedureID, 0, 'StomachNormal','true','Stomach') 
		END
		
		--Stomach region is not updated if a abnormality/diagnoses is present
		IF EXISTS (SELECT 1 FROM dbo.ERS_Diagnoses WHERE @ProcedureId = @ProcedureId AND Region = 'Oesophagus' AND MatrixCode = 'OesophagusNotEntered')
		BEGIN
			DELETE FROM dbo.ERS_Diagnoses WHERE ProcedureID = @ProcedureId AND Region = 'Oesophagus' AND MatrixCode = 'OesophagusNotEntered'
			
			--add Oesophagus normal
			INSERT INTO [ERS_Diagnoses] (ProcedureID, SiteID, MatrixCode, [Value], [Region]) 
			VALUES (@ProcedureID, 0, 'OesophagusNormal','true','Oesophagus') 
		END

		--Stomach region is not updated if a abnormality/diagnoses is present
		IF NOT EXISTS (SELECT 1 FROM dbo.ERS_Diagnoses WHERE @ProcedureId = @ProcedureId AND Region = 'Stomach')
		BEGIN
			--add stomach normal
			INSERT INTO [ERS_Diagnoses] (ProcedureID, SiteID, MatrixCode, [Value], [Region]) 
			VALUES (@ProcedureID, 0, 'StomachNormal','true','Stomach') 
		END

		--Duodenum region is not updated if a abnormality/diagnoses is present
		IF EXISTS (SELECT 1 FROM dbo.ERS_Diagnoses WHERE @ProcedureId = @ProcedureId AND Region = 'Duodenum')
		BEGIN
		     IF EXISTS (SELECT 1 FROM dbo.ERS_Diagnoses WHERE @ProcedureId = @ProcedureId AND Region = 'Duodenum' AND MatrixCode = 'DuodenumNormal')
			 BEGIN
				DELETE FROM dbo.ERS_Diagnoses WHERE ProcedureID = @ProcedureId AND Region = 'Duodenum' AND MatrixCode = 'DuodenumNormal'

				INSERT INTO [ERS_Diagnoses] (ProcedureID, SiteID, MatrixCode, [Value], [Region]) 
				VALUES (@ProcedureID, 0, 'DuodenumNotEntered','true','Duodenum')
			 END
		END
		ELSE	
		BEGIN
		    INSERT INTO [ERS_Diagnoses] (ProcedureID, SiteID, MatrixCode, [Value], [Region]) 
		    VALUES (@ProcedureID, 0, 'DuodenumNotEntered','true','Duodenum')
		END
		
		EXEC dbo.ogd_diagnoses_summary_update @ProcedureId
	END
END

GO

------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	
------------------------------------------------------------------------------------------------------------------------
GO

Go
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Mahfuz	On 08 Aug 2024
-- TFS#	## NO TFS, Ticket : 15385,15355,15370
-- Description of change
-- Returning duplicate site images fix
------------------------------------------------------------------------------------------------------------------------
Go

EXEC DropIfExist 'printreport_photos_select','S';
GO
CREATE PROCEDURE [dbo].[printreport_photos_select]
(
	@OperatingHospitalID SMALLINT,
	@ProcedureId INT,
	@EpisodeNo INT = 0,
	@PatientComboId VARCHAR(30) = NULL,
    @ProcedureType TINYINT,
    @ColonType INT = -1
)
----	Update History:
----	08 Aug 2024		:		MH fixed returning duplicate images , tickets # 15385,15355,15370
----
AS
SET NOCOUNT ON
--Dependency : sites_select

create table #Photos (RowId INT, PhotoUrl VARCHAR(max), PhotoTitle VARCHAR(MAX), SortedSiteNo INT, Region VARCHAR(max))


	INSERT INTO #Photos
	SELECT 
		ROW_NUMBER() OVER (ORDER BY a.siteid asc,a.DateTimeStamp desc) AS RowId,--tfs#3749 changed
		convert(varchar(max), REPLACE(PhotoName, '.mp4', '.bmp')) AS PhotoUrl, 
		ISNULL(b.SiteDescription, 'No site associated - ' + CAST(a.photoId AS VARCHAR) + ' (Attached to the report)') + 
		CASE 
		WHEN a.PhotoName LIKE '%.mp4' 
		THEN '  (Video)' 
		ELSE '' 
		END AS PhotoTitle ,
		0 AS SortedSiteNo,
		b.Region As Region  --ADDING REGION HERE FOR MEDIA 
		
		
		

	FROM [ERS_Photos] a 
	LEFT JOIN 
		(SELECT s.SiteId, p.PhotoId,
			'Site ' + CONVERT(VARCHAR(200), dbo.fnGetSiteTitle(SiteNo, @OperatingHospitalID	)) + ' - '+ cast(p.photoId as varchar) +
			' (' + 
			CASE AntPos WHEN 1 THEN 'Anterior' WHEN 2 THEN 'Posterior' WHEN 3 THEN '' END + 
			' ' + r.Region + 
			')' AS SiteDescription ,
			r.Region --ADDING REGION HERE FOR MEDIA 
		FROM ERS_Sites s 
		JOIN ERS_Regions r ON s.RegionId = r.RegionId 
		JOIN ERS_Photos p ON s.SiteId = p.SiteId
		WHERE s.ProcedureId = @ProcedureId) b ON a.SiteId=b.SiteId and a.PhotoId = b.PhotoId
	WHERE ProcedureId = @ProcedureId

	if @ProcedureId >= 6000000
	begin
		INSERT INTO #Photos
		Select ROW_NUMBER() OVER (ORDER BY previmg.ImageId) as RowId,
				'data:image/jpeg;base64,' + PhotoUrl,
				ImageName,
				0,
				ImageLocation 
		FROM ERS_PreviousImages previmg
		cross apply (select ImageBinary as '*' for xml path('')) T (PhotoUrl)
		WHERE PreviousProcedureID =  @ProcedureId
	end

SELECT *
FROM #Photos
WHERE RowID >= CASE 
		WHEN @EpisodeNo > 0	-- UGI
			THEN 1  
		ELSE 0				-- ERS
		END
Go
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	## NO TFS, Ticket : 15385,15355,15370 by Mahfuz
------------------------------------------------------------------------------------------------------------------------
Go


ALTER PROCEDURE [dbo].[abnormalities_barrett_save]
(
       @SiteId INT,
       @None BIT,
       @BarrettIslands BIT,
       @Proximal INT,
       @Distal INT,
       @DistanceC1 INT,
       @DistanceC2 INT,
       @DistanceC3 INT,
       @DistanceM1 INT,
       @DistanceM2 INT,
	   @FocalLesion BIT,
	   @FocalLesionQty INT,
	   @FocalLesionLargest INT,
	   @FocalLesionTumourTypeId INT,
	   @FocalLesionProbably BIT,
	   @FocalLesionParisClassificationId INT,
	   @FocalLesionPitPatternId INT,
	   @InspectionTimeMins INT,
	   @SmokerRadioButtonListId INT, --add by mostafiz 2360
	   @LoggedInUserId INT
)
AS

SET NOCOUNT ON

DECLARE @proc_id INT
DECLARE @proc_type INT

BEGIN TRANSACTION

BEGIN TRY
       SELECT 
              @proc_id = p.ProcedureId,
              @proc_type = p.ProcedureType
       FROM 
              ERS_Sites s
       JOIN 
              ERS_Procedures p ON s.ProcedureId = p.ProcedureId
       WHERE 
              SiteId = @SiteId
                     
       
       
       IF (@None=0 AND @BarrettIslands=0 AND @Proximal IS NULL AND @Distal IS NULL AND @DistanceC1 IS NULL AND @DistanceC2 IS NULL AND @DistanceC3 IS NULL AND @DistanceM1 IS NULL AND @DistanceM2 IS NULL AND @FocalLesion = NULL AND @InspectionTimeMins = NULL)
       BEGIN
              DELETE FROM ERS_UpperGIAbnoBarrett 
              WHERE SiteId = @SiteId
			  
			  DELETE FROM ERS_RecordCount 
              WHERE SiteId = @SiteId
              AND Identifier = 'Barretts'
       END
	   
       ELSE
		   BEGIN
				IF NOT EXISTS (SELECT 1 FROM ERS_UpperGIAbnoBarrett WHERE SiteId = @SiteId)
			   BEGIN
					  INSERT INTO ERS_UpperGIAbnoBarrett
									 ([SiteId]
									,[None]
									,[BarrettIslands]
									,[Proximal]
									,[Distal]
									,[DistanceC1]
									,[DistanceC2]
									,[DistanceC3]
									,[DistanceM1]
									,[DistanceM2]
									,[FocalLesions]
									,[FocalLesionQty]
									,[FocalLesionLargest]
									,[FocalLesionTumourTypeId]
									,[FocalLesionProbably]
									,[FocalLesionParisClassificationId]
									,[FocalLesionPitPatternId]
									,[InspectionTimeMins]
									,[WhoCreatedId]
									,[WhenCreated]
									,[SmokerRadioButtonListId]								
									)
							VALUES (@SiteId ,
									@None ,
									@BarrettIslands ,
									@Proximal ,
									@Distal ,
									NULLIF(@DistanceC1,0) ,
									NULLIF(@DistanceC2,0) ,
									NULLIF(@DistanceC3,0) ,
									NULLIF(@DistanceM1,0) ,
									@DistanceM2 ,
									@FocalLesion ,
									NULLIF(@FocalLesionQty,0) ,
									NULLIF(@FocalLesionLargest,0) ,
									NULLIF(@FocalLesionTumourTypeId,0) ,
									@FocalLesionProbably ,
									@FocalLesionParisClassificationId ,
									@FocalLesionPitPatternId ,
									@InspectionTimeMins ,
									@LoggedInUserId ,
									GETDATE(),
									NULLIF(@SmokerRadioButtonListId,0)) --add by mostafiz 2360	
																
					  INSERT INTO ERS_RecordCount (
							 [ProcedureId],
							 [SiteId],
							 [Identifier],
							 [RecordCount]
					  )
					  VALUES (
							 @proc_id,
							 @SiteId,
							 'Barretts',
							 1)
			   END
		   Else
			   BEGIN
				  UPDATE 
						 ERS_UpperGIAbnoBarrett
				  SET 
						[None]=@None  ,
						[BarrettIslands]=@BarrettIslands ,
						[Proximal]=@Proximal ,
						[Distal]=@Distal ,
						[DistanceC1]=NULLIF(@DistanceC1,0),
						[DistanceC2]=NULLIF(@DistanceC2,0) ,
						[DistanceC3]=NULLIF(@DistanceC3,0) ,
						[DistanceM1]= NULLIF(@DistanceM1,0) ,
						[DistanceM2]=@DistanceM2 ,
						[FocalLesions] =@FocalLesion,
						[FocalLesionQty] = NULLIF(@FocalLesionQty,0),
						[FocalLesionLargest] = NULLIF(@FocalLesionLargest,0),
						[FocalLesionTumourTypeId] =NULLIF(@FocalLesionTumourTypeId,0),
						[FocalLesionProbably] =@FocalLesionProbably,
						[FocalLesionParisClassificationId] =@FocalLesionParisClassificationId,
						[FocalLesionPitPatternId] = @FocalLesionPitPatternId,
						[InspectionTimeMins] =@InspectionTimeMins,
						[WhoUpdatedId] = @LoggedInUserId,
						[WhenUpdated] = GETDATE(),
						[SmokerRadioButtonListId]=@SmokerRadioButtonListId --add by mostafiz 2360						
				  WHERE 
						 SiteId = @SiteId 
			   END
		  EXEC abnormalities_Barrett_summary_update @SiteId
		  EXEC diagnoses_control_save @SiteId, 'N2003', @FocalLesion  --Focal Lesions

       END

	    --ADDED BY MOSTAFIZ 2360
	  EXEC sites_summary_update @SiteId
	  declare @TF varchar(10)
	  Select @TF = CASE WHEN @None = 0 THEN 'True' ELSE 'False' END
	  EXEC diagnoses_control_save @SiteId, 'D23P1', @TF  --Barretts

	    --ADDED BY MOSTAFIZ 2360
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




Go
------------------------------------------------------------------------------------------------------------------------
-- Updated by	:	Mahfuz	On 15 Sep 2024
-- TFS#	2279
-- Description of change
-- Move PDFs out of the database into file storage (Blob Storage if Azure)
------------------------------------------------------------------------------------------------------------------------
Go

-- Creating New Table ERS_DataPurgeConfig

IF  Not EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ERS_DocumentStorePDFRemovalLog]') AND type in (N'U'))
Begin
Print 'Creating New table ERS_DocumentStorePDFRemovalLog'
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

CREATE TABLE dbo.ERS_DocumentStorePDFRemovalLog
	(
	PDFRemovalLogId int NOT NULL Identity(1,1) ,
	DocumentStoreId int NULL,
	ProcedureId int NULL,
	RemovalSuccess bit null,
	SuccessMessage varchar(200) null,
	FailureMessage varchar(2000) null,
	RemovalAttemptDateTime datetime null
	)  ON [PRIMARY]

ALTER TABLE dbo.ERS_DocumentStorePDFRemovalLog ADD CONSTRAINT
	PK_ERS_DocumentStorePDFRemovalLog PRIMARY KEY CLUSTERED 
	(
	PDFRemovalLogId
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

End
Else
Begin
Print 'ERS_DocumentStorePDFRemovalLog table already exists'
End

Go

EXEC DropIfExist 'sp_LogPDFRemovalEvent','S';
GO
Create PROCEDURE [dbo].[sp_LogPDFRemovalEvent]
(
	@DocumentStoreId int,
	@ProcedureId int,
	@RemovalSuccess bit,
	@SuccessMessage varchar(200),
	@FailureMessage varchar(200)
)
AS
---------------------------------------------------------------------------------------
/*	Mahfuz created	On		12 Sep 2024 : TFS 2279 Move PDF out of database 		*/
/*			Updated On		 */
---------------------------------------------------------------------------------------
BEGIN

	--No need to set recovery mode simple here. This has been done inside console app in upper level

	Insert into ERS_DocumentStorePDFRemovalLog(DocumentStoreId,ProcedureId,RemovalSuccess,SuccessMessage,FailureMessage,RemovalAttemptDateTime)
	Values(@DocumentStoreId,@ProcedureId,@RemovalSuccess,@SuccessMessage,@FailureMessage,GETDATE())

	--DBCC Shrink Database will be executed after finishing the batch inside the console app in level

END
Go
------------------------------------------------------------------------------------------------------------------------
-- END OF TFS#	2279 by Mahfuz
------------------------------------------------------------------------------------------------------------------------
Go
