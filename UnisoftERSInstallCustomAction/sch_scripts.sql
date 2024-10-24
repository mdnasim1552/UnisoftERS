IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE name='OperatingHospitalId' AND Object_ID = Object_ID('ERS_SCH_DiaryPages'))
BEGIN
	ALTER TABLE ERS_SCH_DiaryPages ADD OperatingHospitalId INT 
	UPDATE ERS_SCH_DiaryPages SET OperatingHospitalID = 1

	ALTER TABLE ERS_SCH_DiaryPages ALTER COLUMN OperatingHospitalId INT NOT NULL 
	ALTER TABLE ERS_SCH_DiaryPages ADD CONSTRAINT [FK_SCH_DiaryPages_OperatingHospitalId] FOREIGN KEY ([OperatingHospitalId]) REFERENCES ERS_OperatingHospitals ([OperatingHospitalId])
END
----------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'StaffCancelledId' AND OBJECT_ID = OBJECT_ID(N'ERS_Appointments'))
ALTER TABLE ERS_Appointments ADD StaffCancelledId INT
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'DateCancelled' AND OBJECT_ID = OBJECT_ID(N'ERS_Appointments'))
ALTER TABLE ERS_Appointments ADD DateCancelled datetime
GO

----------------------------------------------------------------------------------------------------------------------------------------------


EXEC DropIfExist 'sch_slot_availability_search', 'S'
GO

CREATE PROCEDURE [dbo].[sch_slot_availability_search]
(
	@ProcedureTypes varchar(100) = NULL,
	@TherapeuticTypes AS varchar(100) = NULL,
	@Slots varchar(100) = NULL,
	@Endoscopist varchar(100) = NULL,
	@SearchStartDate datetime,
	@SearchEndDate datetime,
	@SlotLength int,
	@GIProcedure bit = NULL,
	@OperatingHospitalID int
)
AS
BEGIN
	IF OBJECT_ID('tmpdb..#tmpEndos') IS NOT NULL DROP TABLE #tmpEndos
	SELECT * INTO #tmpEndos FROM fnSplitString(@Endoscopist, ',')

	IF OBJECT_ID('tmpdb..#tmpProcTypes') IS NOT NULL DROP TABLE #tmpProcTypes
	SELECT * INTO #tmpProcTypes FROM fnSplitString(ISNULL(@ProcedureTypes,''), ',')

	IF OBJECT_ID('tmpdb..#tmpProcTherapTypes') IS NOT NULL DROP TABLE #tmpProcTherapTypes
	SELECT * INTO #tmpProcTherapTypes FROM fnSplitString(ISNULL(@TherapeuticTypes,''), ',')

	IF OBJECT_ID('tmpdb..#tmpSlotTypes') IS NOT NULL DROP TABLE #tmpSlotTypes
	SELECT * INTO #tmpSlotTypes FROM fnSplitString(ISNULL(@Slots,''), ',')

	SELECT  DISTINCT esdp.DiaryId, esr.RoomName, esr.RoomId, esdp.DiaryStart, DATEADD(Minute, DATEDIFF(Minute, MIN(esdp.DiaryStart), MAX(esdp.[DiaryEnd])), esdp.DiaryStart) AS [End], esdp.RecurrenceRule, esss.Description AS SlotType, eslr.ListName, ISNULL(esdp.UserID, 0) AS EndoId, ISNULL(ec.Description,'') AS Endoscopist, eslr.ListRulesId, CASE WHEN esls.ProcedureTypeID = 0 THEN '' ELSE ept.SchedulerProcName END AS ProcedureType--, MIN(esls.StartTime), MAX(esls.EndTime), DATEDIFF(Minute, MIN(esls.StartTime), MAX(esls.EndTime)) AS SlotLength--, * 
	FROM dbo.ERS_SCH_DiaryPages esdp
		INNER JOIN dbo.ERS_SCH_ListRules eslr ON esdp.ListRulesId = eslr.ListRulesId
		INNER JOIN dbo.ERS_SCH_ListSlots esls ON esls.ListRulesId = eslr.ListRulesId
		LEFT JOIN (SELECT ecpt.EndoscopistID, ecpt.ProcedureTypeID, ecpt.Diagnostic, ecpt.Therapeutic, ecpt2.TherapeuticTypeID
					FROM ERS_ConsultantProcedureTypes ecpt
						INNER JOIN ERS_ConsultantProcedureTherapeutics ecpt2 
						   ON ecpt.ConsultantProcedureId = ecpt2.ConsultantProcedureID
					WHERE ecpt.Diagnostic = 1 OR ecpt.Therapeutic = 1) cp ON cp.EndoscopistID = ISNULL(eslr.Endoscopist,cp.EndoscopistID)
		INNER JOIN dbo.ERS_SCH_Rooms esr ON esr.RoomId = esdp.RoomID
		INNER JOIN dbo.ERS_SCH_SlotStatus esss ON esss.StatusId = esls.SlotId
		LEFT JOIN dbo.ERS_Users ec ON esdp.UserID = ec.UserID
		LEFT JOIN dbo.ERS_ProcedureTypes ept ON ept.ProcedureTypeId = esls.ProcedureTypeID
	WHERE 
			esr.HospitalId	= @OperatingHospitalID
		--AND ((ISNULL(@ProcedureTypes,'') <> '' AND cp.ProcedureTypeID IN (SELECT item FROM #tmpProcTypes)) OR ((ISNULL(@ProcedureTypes,'') = '' OR ISNULL(@ProcedureTypes,'') = '0') AND 1=1 ))
		AND ((ISNULL(@ProcedureTypes,'') <> '' AND esls.ProcedureTypeID IN (SELECT item FROM #tmpProcTypes)) OR ((ISNULL(@ProcedureTypes,'') = '' OR ISNULL(@ProcedureTypes,'') = '0') AND 1=1 ))
		AND ((ISNULL(@TherapeuticTypes,'') <> '' AND cp.TherapeuticTypeID IN (SELECT item FROM #tmpProcTherapTypes)) OR (ISNULL(@TherapeuticTypes,'') = '' AND 1=1 ) OR (ISNULL(@TherapeuticTypes,'') <> '' AND eslr.Endoscopist IS NULL)) --filter on endoscopists therapeutic type ability
		AND ((((ISNULL(@Endoscopist,'') <> '' AND esdp.UserID IN (SELECT item FROM #tmpEndos)) OR (ISNULL(@Endoscopist,'') = '' AND 1=1))) OR ISNULL(esdp.UserID,'') ='')
		AND (esls.SlotId IN (SELECT item FROM #tmpSlotTypes) OR (ISNULL(@Slots,'') = '' AND 1=1)) --if Slot type specified

		AND (esdp.DiaryStart >= @SearchStartDate OR esdp.DiaryStart < @SearchEndDate)
		--AND esls.SlotLength >= @SlotLength	--(replace this with a sum based on points mapping change)
	
	GROUP BY esdp.DiaryId, esr.RoomName, esr.RoomId, esdp.DiaryStart, esdp.[DiaryEnd], esdp.RecurrenceRule, esss.Description, ListName, esdp.UserID, ec.Description, eslr.ListRulesId, ept.SchedulerProcName, esls.ProcedureTypeID
	HAVING DATEDIFF(Minute, MIN(esdp.DiaryStart), MAX(esdp.[DiaryEnd])) > @SlotLength
	
END
GO

----------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name IN (N'DiagnosticProcedure', N'TherapeuticProcedure') AND Object_ID = Object_ID(N'ERS_Waiting_List'))
BEGIN
ALTER TABLE dbo.ERS_Waiting_List ADD 
	DiagnosticProcedure BIT NOT NULL CONSTRAINT [DF_WaitingList_DiagnosticProcedure] DEFAULT 0,
	TherapeuticProcedure BIT NOT NULL CONSTRAINT [DF_WaitingList_TherapeuticProcedure] DEFAULT 0
END
----------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'sch_diary_page_add', 'S'
GO

CREATE PROCEDURE [dbo].[sch_diary_page_add]
(
	@Subject VARCHAR(500), 
	@DiaryStart datetime, 
	@DiaryEnd datetime, 
	@RoomID int, 
	@UserID int, 
	@RecurrenceRule varchar(500), 
	@RecurrenceParentID int, 
	@ListRulesId int,
	@Description varchar(500),
	@OperatingHospitalId INT,
	@LoggedInUserId int
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
	INSERT INTO [ERS_SCH_DiaryPages] 
	([Subject], [DiaryStart], [DiaryEnd], [RoomID], [UserID], [RecurrenceRule], [RecurrenceParentID], [ListRulesId], [OperatingHospitalId], [WhoCreatedId], [WhenCreated] ) VALUES 
	(@Subject, @DiaryStart, dbo.fnSCH_DiaryEnd(@ListRulesId, @DiaryStart) , @RoomID, @UserID, @RecurrenceRule, @RecurrenceParentID, @ListRulesId, @OperatingHospitalId, @LoggedInUserId, GETDATE())

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
----------------------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'sch_appointment_bookings','S';
GO

CREATE PROCEDURE [dbo].[sch_appointment_bookings]
(
	@StartDateTime datetime,
	@EndDateTime datetime
)
AS
BEGIN
	SELECT 
		convert(varchar(10), ea.StartDateTime, 103) AS AppointmentDate, 
		ea.StartDateTime AS AppointmentStart,
		dateadd(minute, convert(int, ea.AppointmentDuration	), ea.StartDateTime) AS AppointmentEnd,
		esdp.RoomID, 
		esr.RoomName,
		p.Forename1,
		ea.DiaryId
	FROM dbo.ERS_Appointments ea
	INNER JOIN dbo.ERS_SCH_DiaryPages esdp	on ea.DiaryId = esdp.DiaryId
	INNER JOIN dbo.ERS_SCH_Rooms esr ON esdp.RoomID = esr.RoomId
	INNER JOIN dbo.ERS_VW_Patients p ON p.[PatientId] = ea.PatientId
	WHERE StartDateTime >= @StartDateTime AND StartDateTime < @EndDateTime
END
GO
----------------------------------------------------------------------------------------------------------------------------------------------

ALTER PROCEDURE [dbo].[sch_diary_page_update]
(
	@Subject VARCHAR(500), 
	@DiaryStart datetime, 
	@DiaryEnd datetime, 
	@RoomID int, 
	@UserID int, 
	@RecurrenceRule varchar(500), 
	@RecurrenceParentID int, 
	@ListRulesId int,
	@DiaryId int,
	@Description varchar(500),
	@LoggedInUserId int
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY

	UPDATE [ERS_SCH_DiaryPages] 
	SET [Subject] = @Subject, 
		[DiaryStart] = @DiaryStart, 
		[DiaryEnd] = dbo.fnSCH_DiaryEnd(@ListRulesId, @DiaryStart), 
		[RoomID] = @RoomID, 
		[UserID] = @UserID, 
		[RecurrenceRule] = @RecurrenceRule, 
		[RecurrenceParentID] = @RecurrenceParentID, 
		[ListRulesId] = @ListRulesId,
		[WhoUpdatedId] = @LoggedInUserId,
		[WhenUpdated] = GETDATE()
	WHERE (DiaryId = @DiaryId)

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


----------------------------------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

EXEC DropIfExist 'sch_patient_appointments','S';
GO

CREATE PROCEDURE [dbo].[sch_patient_appointments]
(
	@DiaryId int
)
AS
BEGIN
SELECT
	ea.AppointmentId, esss.ForeColor, ea.StartDateTime, DATEADD(minute, convert(int,ea.AppointmentDuration), ea.StartDateTime) AS bookingEnd, ea.AppointmentDuration, esdp.RoomID, esdp.ListRulesId,
	esdp.UserID, esss.Description AS SlotDescription, ep.Forename1 + ' ' + ep.Surname AS PatientName, ep.HospitalNumber, ept.ProcedureType, ea.AppointmentStatusId, ISNULL(ea.Notes,'') AS Notes, ISNULL(ea.EndoscopistId, 0) AS EndoscopistId
FROM dbo.ERS_Appointments ea
	INNER JOIN dbo.ERS_SCH_DiaryPages esdp ON ea.DiaryId = esdp.DiaryId
	INNER JOIN dbo.ERS_SCH_SlotStatus esss ON ea.SlotStatusID = esss.StatusId
	INNER JOIN dbo.ERS_AppointmentProcedureTypes eapt ON ea.AppointmentId = eapt.AppointmentID
	INNER JOIN dbo.ERS_ProcedureTypes ept ON ept.ProcedureTypeID = eapt.ProcedureTypeID
	INNER JOIN dbo.ERS_Patients ep ON ea.PatientId = ep.PatientId
WHERE ea.DiaryId = @DiaryId

END
GO
----------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'sch_appointment_slots', 'S'
GO

CREATE PROCEDURE [dbo].[sch_appointment_slots]
(
	@OperatingHospitalID INT
)
AS

	SELECT DISTINCT
		DiaryId,
		d.DiaryStart, 
		d.[DiaryEnd],
		[UserID], 
		[RoomID], 
		d.ListRulesId, 
		[RecurrenceRule], 
		[RecurrenceParentID], 
		ISNULL(p.Minutes,15) as [Minutes],
		CASE WHEN ept.ProcedureType IS NULL THEN ss.Description ELSE 'Reserved for ' + ept.ProcedureType END AS [Subject],
		ss.Description ,
		ISNULL(s.ProcedureTypeID,0) AS ProcedureTypeID,
		s.ListSlotId,
		ss.ForeColor,
		ss.StatusId,
		ISNULL(p.Points, 1) AS Points,
		ISNULL(l.Endoscopist, 0) AS EndoscopistId
	FROM ERS_SCH_DiaryPages d
		INNER JOIN ERS_SCH_ListRules l ON l.ListRulesId = d.ListRulesId
		INNER JOIN ERS_SCH_ListSlots s ON d.ListRulesId = s.ListRulesId
		INNER JOIN dbo.ERS_SCH_SlotStatus ss ON ss.StatusId = s.SlotId
		LEFT JOIN ERS_SCH_PointMappings p ON p.ProcedureTypeId = s.ProcedureTypeId
		LEFT JOIN dbo.ERS_ProcedureTypes ept ON p.ProceduretypeId = ept.ProcedureTypeId
	WHERE d.OperatingHospitalId = @OperatingHospitalID AND isnull(p.OperatingHospitalId,@OperatingHospitalId) = @OperatingHospitalId

GO
----------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'sch_diary_slots', 'S'
GO

CREATE PROCEDURE [dbo].[sch_diary_slots]
(
	@DiaryId int,
	@OperatingHospitalId int
)
AS

	SELECT DISTINCT
		DiaryId,
		d.DiaryStart, 
		d.[DiaryEnd],
		[UserID], 
		[RoomID], 
		d.ListRulesId, 
		[RecurrenceRule], 
		[RecurrenceParentID], 
		ISNULL(p.Minutes,15) as [Minutes],
		CASE WHEN ept.ProcedureType IS NULL THEN ss.Description ELSE 'Reserved for ' + ept.ProcedureType END AS [Subject],
		ISNULL(ept.ProcedureType, '') AS ProcedureType,
		ss.Description,
		ISNULL(s.ProcedureTypeID, 0) AS ProcedureTypeID,
		s.ListSlotId,
		ss.ForeColor,
		ss.StatusId,
		ISNULL(p.Points, 1) AS Points,
		ISNULL(l.Endoscopist, 0) AS EndoscopistId
	FROM ERS_SCH_DiaryPages d
		INNER JOIN ERS_SCH_ListRules l ON l.ListRulesId = d.ListRulesId
		INNER JOIN ERS_SCH_ListSlots s ON d.ListRulesId = s.ListRulesId
		INNER JOIN dbo.ERS_SCH_SlotStatus ss ON ss.StatusId = s.SlotId
		LEFT JOIN ERS_SCH_PointMappings p ON p.ProcedureTypeId = s.ProcedureTypeId
		LEFT JOIN dbo.ERS_ProcedureTypes ept ON p.ProceduretypeId = ept.ProcedureTypeId
	WHERE d.DiaryId = @dIARYiD AND d.OperatingHospitalId = @OperatingHospitalId AND isnull(p.OperatingHospitalId,@OperatingHospitalId) = @OperatingHospitalId

GO

----------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'sch_todays_patient_appointments', 'S'
GO

CREATE PROCEDURE [dbo].[sch_todays_patient_appointments]
(
	@DiaryId int,
	@BookingDate datetime	
)
AS
BEGIN
	SELECT
		ea.AppointmentId, esss.ForeColor, ea.StartDateTime, DATEADD(minute, convert(int,ea.AppointmentDuration), ea.StartDateTime) AS bookingEnd, ea.AppointmentDuration, esdp.RoomID, esdp.ListRulesId,
		esdp.UserID, esss.Description AS SlotDescription, ep.Forename1 + ' ' + ep.Surname AS PatientName, ep.HospitalNumber, ept.ProcedureType, ea.AppointmentStatusId, ISNULL(ea.Notes,'') AS Notes
	FROM dbo.ERS_Appointments ea
		INNER JOIN dbo.ERS_SCH_DiaryPages esdp ON ea.DiaryId = esdp.DiaryId
		INNER JOIN dbo.ERS_SCH_SlotStatus esss ON ea.SlotStatusID = esss.StatusId
		INNER JOIN dbo.ERS_AppointmentProcedureTypes eapt ON ea.AppointmentId = eapt.AppointmentID
		INNER JOIN dbo.ERS_ProcedureTypes ept ON ept.ProcedureTypeID = eapt.ProcedureTypeID
		INNER JOIN dbo.ERS_Patients ep ON ea.PatientId = ep.PatientId
	WHERE ea.DiaryId = @DiaryId AND convert(varchar(100), ea.StartDateTime, 101) = convert(varchar(100), @BookingDate, 101)
END

GO
----------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_AppointmentStatus WHERE Description = 'Received')
	INSERT INTO dbo.ERS_AppointmentStatus (Description, IsDeleted, HDCKEY)
	VALUES ('Received', 0, 'R')
GO
----------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ProcedureTypeId' AND Object_ID = Object_ID(N'ERS_Waiting_List'))
	ALTER TABLE dbo.ERS_Waiting_List ADD ProcedureTypeId INT NULL
GO
----------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'get_waitlist_patients', 'S'
GO
CREATE PROCEDURE [dbo].[get_waitlist_patients]
(
	@OperatingHospitalId int
)
AS
BEGIN
	SELECT 
		ep.HospitalNumber,
		ewl.PatientId,
		ep.Forename1,
		ep.Surname,
		dbo.fnGender(ep.GenderId) AS Gender,
		dbo.fnFullAddress(ep.Address1, ep.Address2, ep.Address3, ep.Address4, ep.Postcode) AS Address,
		ep.DateOfBirth,
		ep.Postcode,
		ewl.WaitingListId, 
		ewl.PatientId, 
		ewl.DateEntered,
		ewl.PriorityId,
		esss.Description AS PriorityDescription, 
		ewl.DueDate, 
		DATEADD(Day, esss.BreachDays,ewl.DateRaised) AS BookBy,
		ewl.WaitingListStatusId, 
		ewl.Notes, 
		ewl.OperatingHospitalId, 
		ewl.DateRaised, 
		ewl.Duration, 
		ewl.ProcedureTypeId,
		ewl.ReferrerId,
		ec.CompleteName AS Referrer,
		ProcedureType,
		ewl.DiagnosticProcedure,
		ewl.TherapeuticProcedure,
		ewl.ProcedureTypeId
	FROM dbo.ERS_Waiting_List ewl
		INNER JOIN dbo.ERS_Patients ep ON ewl.PatientId = ep.PatientId
		INNER JOIN dbo.ERS_SCH_SlotStatus esss ON esss.StatusId = ewl.PriorityId
		INNER JOIN dbo.ERS_Consultant ec ON ec.ConsultantID = ewl.ReferrerId
		INNER JOIN dbo.ERS_ProcedureTypes ept ON ewl.ProcedureTypeId = ept.ProcedureTypeId
	WHERE ewl.OperatingHospitalId = @OperatingHospitalId
	  AND ewl.WaitingListStatusId = 10
END

GO


----------------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM SYS.FOREIGN_KEYS WHERE OBJECT_ID = OBJECT_ID(N'dbo.FK_ERS_Waiting_List_ERS_Referrers') AND parent_object_id = OBJECT_ID(N'dbo.ERS_Waiting_List'))
	ALTER TABLE dbo.ERS_Waiting_List DROP CONSTRAINT FK_ERS_Waiting_List_ERS_Referrers
GO
----------------------------------------------------------------------------------------------------------------------------------------------
--UPDATE ers_users SET ers_users.IsGIConsultant = 1 WHERE ers_users.IsEndoscopist1 = 1 OR ers_users.IsEndoscopist2=1
--GO
----------------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM SYS.FOREIGN_KEYS WHERE OBJECT_ID = OBJECT_ID(N'dbo.FK_ERS_ConsultantProcedures_ERS_Consultant') AND parent_object_id = OBJECT_ID(N'dbo.ERS_ConsultantProcedureTypes'))
	ALTER TABLE ERS_ConsultantProcedureTypes DROP CONSTRAINT FK_ERS_ConsultantProcedures_ERS_Consultant
GO
----------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO dbo.ERS_SCH_FreeSlotDefaults
(
    --FreeSlotDefaultId - this column value is auto-generated
    OperatingHospitalId,
    DayOfWeek,
    AM,
    PM,
    EVE
)
SELECT 
eoh.OperatingHospitalId,
DayOfWeek,
0,
0,
0
FROM dbo.ERS_SCH_FreeSlotDefaults esfsd, dbo.ERS_OperatingHospitals eoh
WHERE eoh.OperatingHospitalId NOT IN (SELECT OperatingHospitalId FROM dbo.ERS_SCH_FreeSlotDefaults)
----------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'sch_diary_page_select', 'S'
GO

CREATE PROCEDURE [dbo].[sch_diary_page_select]
AS
SET NOCOUNT ON

BEGIN TRANSACTION

BEGIN TRY
	SELECT DiaryId,
	 l.listname AS [Subject],
	  (CASE WHEN  ISNULL(u.Title,'') <> '' THEN u.Title + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Forename,'') <> '' THEN u.Forename + ' ' ELSE '' END +
	  CASE WHEN  ISNULL(u.Surname,'') <> '' THEN u.Surname + ' ' ELSE '' END) +
	  '  [' + CONVERT(VARCHAR(5),cast(a.DiaryStart as time)) + '-' + CONVERT(VARCHAR(5),cast(a.[DiaryEnd] as time)) + ']' +
	  CASE WHEN  ISNULL(l.Points,0) <> 0 THEN '  [' + CONVERT(VARCHAR, l.Points) + ' slots]' ELSE '' END AS [Description]
      ,a.DiaryStart
      ,a.[DiaryEnd]
	  ,a.UserID
      ,a.RoomID
      ,a.ListRulesId
      ,a.RecurrenceRule
      ,a.RecurrenceParentID
      --,a.Annotations
	  --,a.[Description] 
  FROM ERS_SCH_DiaryPages a
  INNER JOIN ERS_SCH_ListRules l ON l.ListRulesId = a.ListRulesId
  LEFT JOIN ERS_Users u ON u.UserID = l.Endoscopist

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

----------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE Object_ID = Object_ID('ERS_SCH_DayNotes'))
BEGIN
	CREATE TABLE [dbo].[ERS_SCH_DayNotes](
		[DayNoteId] [int] IDENTITY(1,1) NOT NULL,
		[NoteDate] [datetime] NOT NULL,
		[NoteTime] [char](3) NOT NULL,
		[NoteText] [varchar](500) NOT NULL,
		[RoomId] [int] NULL,
		[OperatingHospitalId] [INT] NOT NULL,
		[WhoUpdatedId]	[int]		NULL Default 0,
		[WhoCreatedId]	[int]		NULL Default 0,
		[WhenCreated]	[DATETIME]	NULL Default GetDate(),
		[WhenUpdated]	[DATETIME]	NULL Default GetDate(),
		CONSTRAINT [PK_SCH_DayNotes] PRIMARY KEY CLUSTERED ([DayNoteId]),
		CONSTRAINT [FK_SCH_DayNotes_OperatingHospitalId] FOREIGN KEY([OperatingHospitalId]) REFERENCES [dbo].[ERS_OperatingHospitals] ([OperatingHospitalId])
	) ON [PRIMARY]
END
GO
----------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'ERS_SCH_SaveDayNotes', 'S'
GO

CREATE PROCEDURE dbo.ERS_SCH_SaveDayNotes
(
	@NoteDate datetime,
	@NoteText VARCHAR(500),
	@NoteTime CHAR(3),
	@OperatingHospitalId INT,
	@RoomId INT,
	@LoggedInUserId INT

)
AS


BEGIN TRANSACTION

BEGIN TRY
	IF NOT EXISTS (SELECT 1 FROM ERS_SCH_DayNotes WHERE NoteDate = @NoteDate AND NoteTime = @NoteTime AND OperatingHospitalId = @OperatingHospitalId AND RoomId = @RoomId)
	BEGIN	
		INSERT INTO ERS_SCH_DayNotes (NoteDate, NoteTime, NoteText, RoomId, OperatingHospitalId)
							  VALUES (@NoteDate, @NoteTime, @NoteText, @RoomId, @OperatingHospitalId)
	END
	ELSE
	BEGIN
		IF @NoteText = ''
		BEGIN
			DELETE FROM ERS_SCH_DayNotes WHERE NoteDate = @NoteDate AND NoteTime = @NoteTime AND OperatingHospitalId = @OperatingHospitalID AND RoomID = @RoomID
		END
		ELSE
		BEGIN
			UPDATE ERS_SCH_DayNotes SET NoteText = @NoteText WHERE NoteDate = @NoteDate AND NoteTime = @NoteTime AND OperatingHospitalId = @OperatingHospitalID AND RoomID = @RoomID
		END	
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
----------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'ERS_SCH_GetDayNotes', 'S'
GO

CREATE PROCEDURE dbo.ERS_SCH_GetDayNotes
(
	@NoteDate datetime,
	@NoteTime CHAR(3) = NULL,
	@OperatingHospitalId INT,
	@RoomId INT

)
AS
BEGIN
	SELECT 
		[NoteTime],
		[NoteText]
	FROM ERS_SCH_DayNotes
	WHERE CONVERT(VARCHAR(10), NoteDate, 103) = CONVERT(VARCHAR(10), @NoteDate, 103) AND NoteTime = CASE WHEN @NoteTime IS NULL THEN NoteTime ELSE @NoteTime END AND OperatingHospitalId = @OperatingHospitalId AND RoomId = @RoomId
END

GO
----------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'get_waitlist_details', 'S'
GO
CREATE PROCEDURE [dbo].[get_waitlist_details]
(
	@WaitlistId int
)
AS
BEGIN
	SELECT 
		ep.HospitalNumber,
		ewl.PatientId,
		ep.Forename1,
		ep.Surname,
		dbo.fnGender(ep.GenderId) AS Gender,
		dbo.fnFullAddress(ep.Address1, ep.Address2, ep.Address3, ep.Address4, ep.Postcode) AS Address,
		ep.DateOfBirth,
		ep.Postcode,
		ep.NHSNo,
		ewl.WaitingListId, 
		ewl.PatientId, 
		ewl.DateEntered,
		ewl.PriorityId,
		esss.Description AS PriorityDescription, 
		ewl.DueDate, 
		DATEADD(Day, esss.BreachDays,ewl.DateRaised) AS BookBy,
		ewl.WaitingListStatusId, 
		ewl.Notes, 
		ewl.OperatingHospitalId, 
		ewl.DateRaised, 
		ewl.Duration, 
		ewl.ProcedureTypeId,
		ewl.ReferrerId,
		ec.CompleteName AS Referrer,
		ProcedureType,
		ewl.DiagnosticProcedure,
		ewl.TherapeuticProcedure,
		ewl.ProcedureTypeId
	FROM dbo.ERS_Waiting_List ewl
		INNER JOIN dbo.ERS_Patients ep ON ewl.PatientId = ep.PatientId
		INNER JOIN dbo.ERS_SCH_SlotStatus esss ON esss.StatusId = ewl.PriorityId
		INNER JOIN dbo.ERS_Consultant ec ON ec.ConsultantID = ewl.ReferrerId
		INNER JOIN dbo.ERS_ProcedureTypes ept ON ewl.ProcedureTypeId = ept.ProcedureTypeId
	WHERE ewl.WaitingListId = @WaitlistId
END

GO
----------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_AppointmentStatus WHERE [Description] = 'Moved')
INSERT INTO ERS_AppointmentStatus ([Description], IsDeleted, HDCKEY)
VALUES ('Moved', 0, 'M')
----------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'sch_get_cancelled_bookings', 'S'
GO

CREATE PROCEDURE dbo.[sch_get_cancelled_bookings]
(
	@BookingDate datetime,
	@DiaryId INT
)
AS
BEGIN
	SELECT ea.AppointmentId, ea.StartDateTime AS BookingDate, ept.ProcedureType, ep.HospitalNumber, LTRIM(RTRIM(ISNULL(ep.Title,'') + ' ' + ep.Forename1 + ' ' + ep.Surname)) AS PatientName, ecr.Detail AS Reason
	FROM dbo.ERS_Appointments ea
		INNER JOIN dbo.ERS_AppointmentProcedureTypes eapt ON ea.AppointmentId = eapt.AppointmentID
		INNER JOIN dbo.ERS_ProcedureTypes ept ON ept.ProcedureTypeId = eapt.ProcedureTypeID
		INNER JOIN dbo.ERS_Patients ep ON ea.PatientId = ep.PatientId
		INNER JOIN dbo.ERS_CancelReasons ecr ON ea.CancelReasonId = ecr.CancelReasonId
	WHERE
		CONVERT(VARCHAR(10), ea.StartDateTime, 103) = CONVERT(VARCHAR(10), @BookingDate, 103) AND
		ea.DiaryId = @DiaryId AND
		ea.AppointmentStatusId=4
	ORDER BY ea.StartDateTime

END
GO
----------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM ERS_Pages WHERE PageId = 317)
BEGIN
	INSERT [dbo].[ERS_Pages] ([PageId], [PageName], [AppPageName], [GroupId], [PageAlias],[PageURL]) VALUES 
	(317,'Cancelled Bookings','products_scheduler_cancelledbookings_aspx',8,'Cancelled Bookings','~/products/scheduler/cancelledbookings.aspx')

	INSERT INTO ERS_PagesByRole (RoleId, PageId, AccessLevel)
	VALUES (6, 317, 9),
		   (1, 317, 9)
END

IF NOT EXISTS (SELECT 1 FROM ERS_Pages WHERE PageId = 318)
BEGIN
	INSERT INTO [dbo].[ERS_Pages] ([PageId], [PageName], [AppPageName], [GroupId], [PageAlias],[PageURL]) VALUES 
	(318,'Search Existing Bookings','products_scheduler_bookingsearch_aspx',8,'Cancelled Bookings','~/products/scheduler/bookingsearch.aspx')

	INSERT INTO ERS_PagesByRole (RoleId, PageId, AccessLevel)
	VALUES (6, 318, 9),
		   (1, 318, 9)
END

----------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'sch_get_cancelled_booking_details', 'S'
GO

CREATE PROCEDURE dbo.[sch_get_cancelled_booking_details]
(
	@AppointmentId INT
)
AS
BEGIN
	SELECT ea.AppointmentId, ea.StartDateTime AS BookingDate, ept.ProcedureType, 
	ep.HospitalNumber, LTRIM(RTRIM(ISNULL(ep.Title,'') + ' ' + ep.Forename1 + ' ' + ep.Surname)) AS PatientName, 
	ISNULL(ep.NHSNo,''), ep.DateOfBirth, dbo.fnGender(ep.GenderId) AS Gender, 
	CASE WHEN eu.UserId IS NOT NULL THEN LTRIM(RTRIM(ISNULL(eu.Title,'') + ' ' + eu.Forename + ' ' + eu.Surname)) ELSE '' END AS Endoscopist,
	LTRIM(RTRIM(ISNULL(bu.Title,'') + ' ' + bu.Forename + ' ' + bu.Surname)) AS BookedBy,
	LTRIM(RTRIM(ISNULL(cu.Title,'') + ' ' + cu.Forename + ' ' + cu.Surname)) AS CancelledBy,
	ea.DueArrivalTime, ea.AppointmentDuration, esss.Description AS PatientSlotStatus, ISNULL(ea.Notes,'') AS Notes,
	ecr.Detail AS Reason, ISNULL(esr.RoomName, '') AS RoomName, ea.DateEntered, ea.DateCancelled
	FROM dbo.ERS_Appointments ea
		INNER JOIN dbo.ERS_AppointmentProcedureTypes eapt ON ea.AppointmentId = eapt.AppointmentID
		INNER JOIN dbo.ERS_ProcedureTypes ept ON ept.ProcedureTypeId = eapt.ProcedureTypeID
		INNER JOIN dbo.ERS_Patients ep ON ea.PatientId = ep.PatientId
		INNER JOIN dbo.ERS_CancelReasons ecr ON ea.CancelReasonId = ecr.CancelReasonId
		INNER JOIN dbo.ERS_Users bu ON ea.StaffBookedId = bu.UserID
		INNER JOIN dbo.ERS_Users cu ON ea.StaffCancelledId = cu.UserID
		LEFT JOIN dbo.ERS_Users eu ON ea.EndoscopistId = eu.UserID
		INNER JOIN dbo.ERS_SCH_SlotStatus esss ON ea.SlotStatusID = esss.StatusId
		LEFT JOIN dbo.ERS_SCH_DiaryPages esdp ON ea.DiaryId = esdp.DiaryId
		INNER JOIN dbo.ERS_SCH_Rooms esr ON esr.RoomId = esdp.RoomId
	WHERE
		ea.AppointmentId = @AppointmentId
	ORDER BY ea.StartDateTime

END
GO
----------------------------------------------------------------------------------------------------------------------------------------------
UPDATE ERS_Pages SET GroupId = 5 WHERE AppPageName='products_options_scheduler_therapeutictypes_aspx'
GO
----------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'GeneralInformation' AND OBJECT_ID = OBJECT_ID('ERS_Appointments'))
ALTER TABLE dbo.ERS_Appointments ADD GeneralInformation VARCHAR(MAX)
GO
----------------------------------------------------------------------------------------------------------------------------------------------
UPDATE ers_proceduretypes SET ers_proceduretypes.SchedulerProc = 0 WHERE ers_proceduretypes.SchedulerDiagnostic = 0 AND ers_proceduretypes.SchedulerTherapeutic = 0
GO
----------------------------------------------------------------------------------------------------------------------------------------------
EXEC DropIfExist 'sch_get_procedure_times', 'S'
GO

CREATE PROCEDURE dbo.[sch_get_procedure_times]
(
	@ProcedureTypeId INT,
	@OperatingHospital INT
)
AS
	SELECT ept.ProcedureTypeId, ept.ProcedureType, ISNULL(espm.Points, 1) AS Points, ISNULL(espm.Minutes,15) SlotPointsLength 
	FROM dbo.ERS_ProcedureTypes ept
	LEFT JOIN dbo.ERS_SCH_PointMappings espm ON ept.OperatingHospitalId = espm.OperatingHospitalId
	WHERE ept.SchedulerProc = 1 AND 
		  espm.OperatingHospitalId = @OperatingHospital AND
		  ept.ProcedureTypeId = @ProcedureTypeId

GO
----------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'ParentListSlotId' AND OBJECT_ID = OBJECT_ID('ERS_SCH_ListSlots'))
ALTER TABLE dbo.ERS_SCH_ListSlots ADD ParentListSlotId INT
GO
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
