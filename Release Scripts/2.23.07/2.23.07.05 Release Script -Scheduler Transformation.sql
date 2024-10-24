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

