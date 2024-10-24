------------------------------------------Audit table scripts------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

--** Drop all tables prefixed by 'ERS_' for Schema ERSAudit
DECLARE @sql nvarchar(max)
 SET @sql = '';

SELECT @sql += N' EXEC dbo.DropIfExist ' + TABLE_NAME + ',' + 
			CASE TABLE_TYPE WHEN 'VIEW' THEN 'V' ELSE 'Ta' END + '; '
FROM INFORMATION_SCHEMA.TABLES 
WHERE LEFT(TABLE_NAME,4) = 'ERS_' AND TABLE_TYPE IN ('BASE TABLE', 'VIEW')
	AND TABLE_SCHEMA = 'ERSAudit'
EXEC sp_executesql @sql;

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ERSAudit')
BEGIN
EXEC('CREATE SCHEMA ERSAudit')
END
GO


-- ############### Create WHO and WHEN Audit fields for every ERS table

EXEC sp_MSforeachtable '
if left(object_name(object_id(''?'')),4)  = ''ERS_'' 
       and not exists (select * from sys.columns 
               where object_id = object_id(''?'')
               and name = ''WhoUpdatedId'') 
begin
    ALTER TABLE ? ADD WhoUpdatedId INT NULL;
end

if left(object_name(object_id(''?'')),4)  = ''ERS_'' 
       and not exists (select * from sys.columns 
               where object_id = object_id(''?'')
               and name = ''WhoCreatedId'') 
begin
   ALTER TABLE ? ADD WhoCreatedId INT NULL Default 0;
end

if left(object_name(object_id(''?'')),4)  = ''ERS_'' 
       and not exists (select * from sys.columns 
               where object_id = object_id(''?'')
               and name = ''WhenCreated'') 
begin
    ALTER TABLE ? ADD WhenCreated DATETIME NULL Default GetDate();
end

if left(object_name(object_id(''?'')),4)  = ''ERS_'' 
       and not exists (select * from sys.columns 
               where object_id = object_id(''?'')
               and name = ''WhenUpdated'') 
begin
    ALTER TABLE ? ADD WhenUpdated DATETIME NULL;
end
';


/****** Object:  StoredProcedure [ERSAudit].[UpdateAuditTables]    Script Date: 06/02/2019 04:23:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Object:  Table [SolusAudit].[tblAuditActions]    Script Date: 07/02/2019 08:14:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'ERSAudit' 
                 AND  TABLE_NAME = 'tblAuditActions'))
BEGIN
    --Do Stuff
	drop Table [ERSAudit].[tblAuditActions]
END


CREATE TABLE [ERSAudit].[tblAuditActions](
	[UniqueId] [int] IDENTITY(1,1) NOT NULL,
	[Action] [nvarchar](50) NOT NULL,
	CONSTRAINT [PK_AuditActions] PRIMARY KEY CLUSTERED 
(
	[UniqueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	CONSTRAINT [Unique_AuditActions] UNIQUE NONCLUSTERED 
(
	[Action] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

-- nEED INSERT

	INSERT INTO [ERSAudit].[tblAuditActions] VALUES ('Delete')
	INSERT INTO [ERSAudit].[tblAuditActions] VALUES ('Insert')
	INSERT INTO [ERSAudit].[tblAuditActions] VALUES ('Update')

-- ****Section End*************************************************************

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'UpdateAuditTables')
DROP PROCEDURE [ERSAudit].[UpdateAuditTables]
GO

CREATE PROCEDURE [ERSAudit].[UpdateAuditTables]
	@Schema nvarchar(255),
	@Table nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN TRY
		DECLARE @TableName nvarchar(255), @TableSchema nvarchar(255),
			@ColumnName nvarchar(255), @ColumnType nvarchar(255), 
			@ColumnMaxLength nvarchar(255), @ColumnNumericPrecision nvarchar(255), 
			@ColumnNumericScale nvarchar(255), @AuditTableName nvarchar(255), 
			@ColumnsForAuditTable varchar(MAX), @ColumnsForTrigger varchar(MAX),
			@ExecSQL NVARCHAR(MAX), 
			@UniqueIdentifier VARCHAR(100);

		IF (@Schema IS NOT NULL AND @Table IS NOT NULL)
		BEGIN
			BEGIN TRANSACTION
				IF (@Schema = '')
					RAISERROR('Schema name missing', 16, 1);
				ELSE IF (@Table = '')
					RAISERROR('Table name missing', 16, 1)

				DECLARE column_cursor CURSOR FOR
				SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_SCHEMA = @Schema AND TABLE_NAME = @Table

				SET @AuditTableName = @Table + '_Audit';
				SET @ColumnsForAuditTable = '';
				SET @ColumnsForTrigger = '';
				SELECT @UniqueIdentifier = COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME = @Table AND TABLE_schema =  @Schema AND CONSTRAINT_NAME LIKE 'PK%'
				OPEN column_cursor
				FETCH NEXT FROM column_cursor INTO @ColumnName, @ColumnType, @ColumnMaxLength, @ColumnNumericPrecision, @ColumnNumericScale

				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF (@ColumnName <> @UniqueIdentifier AND @ColumnName <> 'WhenCreated' AND @ColumnName <> 'WhoCreatedId' AND @ColumnName <> 'WhenUpdated' AND @ColumnName <> 'WhoUpdatedId')
					BEGIN
						SET @ColumnName = '[' + @ColumnName + ']'
						SET @ColumnsForTrigger = @ColumnsForTrigger + 'tbl.' + @ColumnName + ', ';
						
						IF (@ColumnType = 'nvarchar' OR @ColumnType = 'varchar' OR @ColumnType = 'nchar')
						BEGIN
							IF (@ColumnMaxLength = '-1')
								SET @ColumnsForAuditTable = @ColumnsForAuditTable + @ColumnName + ' ' + @ColumnType + '(MAX) NULL,';
							ELSE
								SET @ColumnsForAuditTable = @ColumnsForAuditTable + @ColumnName + ' ' + @ColumnType + '(' + @ColumnMaxLength + ') NULL,';
						END
						ELSE IF (@ColumnType = 'decimal')
							SET @ColumnsForAuditTable = @ColumnsForAuditTable + @ColumnName + ' ' + @ColumnType + ' (' + @ColumnNumericPrecision + ',' + @ColumnNumericScale + ') NULL,';
						ELSE
							SET @ColumnsForAuditTable = @ColumnsForAuditTable + @ColumnName + ' ' + @ColumnType + ' NULL,';
					END

					FETCH NEXT FROM column_cursor INTO @ColumnName, @ColumnType, @ColumnMaxLength, @ColumnNumericPrecision, @ColumnNumericScale
				END

				CLOSE column_cursor
				DEALLOCATE column_cursor

				IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ERSAudit' AND TABLE_NAME = @AuditTableName))
				BEGIN
					PRINT '====== [ERSAudit].[' + @AuditTableName + '] already exists ======'
				END 
				ELSE 
				BEGIN
					--PRINT '====== Creating table [ERSAudit].[' + @AuditTableName + '] ======';
					
					SET @ExecSQL = 'CREATE TABLE [ERSAudit].[' + @AuditTableName + '](
						[AuditedRecordUniqueId] [int] IDENTITY(1,1) NOT NULL,
						'+ @UniqueIdentifier +' [int] NOT NULL,'
						+ @ColumnsForAuditTable + '
						[LastActionId] [int] NOT NULL,
						[ActionUserId] [int] NULL,
						[ActionDateTime] [datetime] NULL
						CONSTRAINT [PK_' + @AuditTableName + '] PRIMARY KEY CLUSTERED 
						(
							[AuditedRecordUniqueId]  ASC
						)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
						) ON [PRIMARY]
						ALTER TABLE [ERSAudit].[' + @AuditTableName + ']  WITH CHECK ADD  CONSTRAINT [FK_' + @AuditTableName + '_tblAuditActions] FOREIGN KEY([LastActionId])
						REFERENCES [ERSAudit].[tblAuditActions] ([UniqueId])
						ALTER TABLE [ERSAudit].[' + @AuditTableName + '] CHECK CONSTRAINT [FK_' + @AuditTableName + '_tblAuditActions]';
						--PRINT ''====== Created table [ERSAudit].[' + @AuditTableName + '] ======''';
					EXECUTE sp_executeSQL @ExecSQL

					IF (EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_' + @Table + '_Insert'))
					BEGIN
						SET @ExecSQL = 'DROP TRIGGER [' + @Schema + '].[trg_' + @Table + '_Insert]';
						EXECUTE sp_executeSQL @ExecSQL
					END

					SET @ExecSQL = 'CREATE TRIGGER [' + @Schema + '].[trg_' + @Table + '_Insert] 
							ON [' + @Schema + '].[' + @Table + '] 
							AFTER INSERT
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[' + @AuditTableName + '] ('+ @UniqueIdentifier +', ' + @ColumnsForTrigger + ' LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.'+ @UniqueIdentifier +' , ' + @ColumnsForTrigger + ' 1, GETDATE(), tbl.WhoCreatedId
							FROM inserted tbl';

					EXECUTE sp_executeSQL @ExecSQL
					--PRINT '====== Created trigger trg_' + @Table + '_Insert ======'

					IF (EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_' + @Table + '_Update'))
					BEGIN
						SET @ExecSQL = 'DROP TRIGGER [' + @Schema + '].[trg_' + @Table + '_Update]';
						EXECUTE sp_executeSQL @ExecSQL
					END

					IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'Summary' AND Object_ID = Object_ID(N'dbo.' + @Table))
					BEGIN
						SET @ExecSQL = 'CREATE TRIGGER [' + @Schema + '].[trg_' + @Table + '_Update] 
								ON [' + @Schema + '].[' + @Table + '] 
								AFTER UPDATE
							AS 
								SET NOCOUNT ON; 
								IF NOT UPDATE(Summary)
								BEGIN
									INSERT INTO [ERSAudit].[' + @AuditTableName + '] ('+ @UniqueIdentifier +', ' + @ColumnsForTrigger + ' LastActionId, ActionDateTime, ActionUserId)
									SELECT tbl.'+ @UniqueIdentifier +' , ' + @ColumnsForTrigger + ' 2, GETDATE(), i.WhoUpdatedId
									FROM deleted tbl INNER JOIN inserted i ON tbl.'+ @UniqueIdentifier +' = i.'+ @UniqueIdentifier + '
								END';
					END
					ELSE
					BEGIN
						SET @ExecSQL = 'CREATE TRIGGER [' + @Schema + '].[trg_' + @Table + '_Update] 
							ON [' + @Schema + '].[' + @Table + '] 
							AFTER UPDATE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[' + @AuditTableName + '] ('+ @UniqueIdentifier +', ' + @ColumnsForTrigger + ' LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.'+ @UniqueIdentifier +' , ' + @ColumnsForTrigger + ' 2, GETDATE(), i.WhoUpdatedId
							FROM deleted tbl INNER JOIN inserted i ON tbl.'+ @UniqueIdentifier +' = i.'+ @UniqueIdentifier;
					END
					
					EXECUTE sp_executeSQL @ExecSQL
					--PRINT '====== Created trigger trg_' + @Table + '_Update ======'

					IF (EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_' + @Table + '_Delete'))
					BEGIN
						SET @ExecSQL = 'DROP TRIGGER [' + @Schema + '].[trg_' + @Table + '_Delete]';
						EXECUTE sp_executeSQL @ExecSQL
					END

					SET @ExecSQL = 'CREATE TRIGGER [' + @Schema + '].[trg_' + @Table + '_Delete] 
							ON [' + @Schema + '].[' + @Table + '] 
							AFTER DELETE
						AS 
							SET NOCOUNT ON; 
							INSERT INTO [ERSAudit].[' + @AuditTableName + '] ('+ @UniqueIdentifier +', ' + @ColumnsForTrigger + ' LastActionId, ActionDateTime, ActionUserId)
							SELECT tbl.'+ @UniqueIdentifier +' , ' + @ColumnsForTrigger + ' 3, GETDATE(), tbl.WhoUpdatedId
							FROM deleted tbl';
					EXECUTE sp_executeSQL @ExecSQL
					--PRINT '====== Created trigger trg_' + @Table + '_Delete ======'
				END
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				DECLARE audit_cursor CURSOR FOR 
				SELECT TableSchema, TableName
				FROM ERSAudit.tblTablesToBeAudited;

				OPEN audit_cursor

				FETCH NEXT FROM audit_cursor 
				INTO @TableSchema, @TableName

				WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE column_cursor CURSOR FOR
					SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_SCHEMA = @TableSchema AND TABLE_NAME = @TableName

					SET @AuditTableName = @TableName + '_Audit';
					SET @ColumnsForAuditTable = '';
					SET @ColumnsForTrigger = '';

					OPEN column_cursor
					FETCH NEXT FROM column_cursor INTO @ColumnName, @ColumnType, @ColumnMaxLength, @ColumnNumericPrecision, @ColumnNumericScale

					WHILE @@FETCH_STATUS = 0
					BEGIN
						IF (@ColumnName <> @UniqueIdentifier AND @ColumnName <> 'WhenCreated' AND @ColumnName <> 'WhoCreatedId' AND @ColumnName <> 'WhenUpdated' AND @ColumnName <> 'WhoUpdatedId')
						BEGIN
							SET @ColumnsForTrigger = @ColumnsForTrigger + 'tbl.' + @ColumnName + ', ';

							IF (@ColumnType = 'nvarchar' OR @ColumnType = 'varchar' OR @ColumnType = 'nchar')
							BEGIN
								IF (@ColumnMaxLength = '-1')
									SET @ColumnsForAuditTable = @ColumnsForAuditTable + @ColumnName + ' ' + @ColumnType + '(MAX) NULL,';
								ELSE
									SET @ColumnsForAuditTable = @ColumnsForAuditTable + @ColumnName + ' ' + @ColumnType + '(' + @ColumnMaxLength + ') NULL,';
							END
							ELSE IF (@ColumnType = 'decimal')
								SET @ColumnsForAuditTable = @ColumnsForAuditTable + @ColumnName + ' ' + @ColumnType + ' (' + @ColumnNumericPrecision + ',' + @ColumnNumericScale + ') NULL,';
							ELSE
								SET @ColumnsForAuditTable = @ColumnsForAuditTable + @ColumnName + ' ' + @ColumnType + ' NULL,';
						END

						FETCH NEXT FROM column_cursor INTO @ColumnName, @ColumnType, @ColumnMaxLength, @ColumnNumericPrecision, @ColumnNumericScale
					END

					CLOSE column_cursor
					DEALLOCATE column_cursor

					IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ERSAudit' AND TABLE_NAME = @AuditTableName))
						PRINT '====== [ERSAudit].[' + @AuditTableName + '] already exists ======'
					ELSE 
					BEGIN
						--PRINT '====== Creating table [ERAAudit].[' + @AuditTableName + '] ======';
						SET @ExecSQL = 'CREATE TABLE [ERSAudit].[' + @AuditTableName + '](
								[AuditedRecordUniqueId] [int] IDENTITY(1,1) NOT NULL,
							'+ @UniqueIdentifier +' [int] NOT NULL,'
							+ @ColumnsForAuditTable + '
							[LastActionId] [int] NOT NULL,
							[ActionUserId] [int] NOT NULL,
							[ActionDateTime] [datetime] NOT NULL
							CONSTRAINT [PK_' + @AuditTableName + '] PRIMARY KEY CLUSTERED 
							(
								[AuditedRecordUniqueId] ASC
							)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
							) ON [PRIMARY]
							ALTER TABLE [ERSAudit].[' + @AuditTableName + ']  WITH CHECK ADD  CONSTRAINT [FK_' + @AuditTableName + '_tblAuditActions] FOREIGN KEY([LastActionId])
							REFERENCES [ERSAudit].[tblAuditActions] ([UniqueId])
							ALTER TABLE [ERSAudit].[' + @AuditTableName + '] CHECK CONSTRAINT [FK_' + @AuditTableName + '_tblAuditActions]';
							---PRINT ''====== Created table [ERSAudit].[' + @AuditTableName + '] ======''';
						EXECUTE sp_executeSQL @ExecSQL

						IF (EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_' + @TableName + '_Insert'))
						BEGIN
							SET @ExecSQL = 'DROP TRIGGER [' + @TableSchema + '].[trg_' + @TableName + '_Insert]';
							EXECUTE sp_executeSQL @ExecSQL
						END

						SET @ExecSQL = 'CREATE TRIGGER [' + @TableSchema + '].[trg_' + @TableName + '_Insert] 
								ON [' + @TableSchema + '].[' + @TableName + '] 
								AFTER INSERT
							AS 
								SET NOCOUNT ON; 
								INSERT INTO [ERSAudit].[' + @AuditTableName + '] ('+ @UniqueIdentifier +', ' + @ColumnsForTrigger + ' LastActionId, ActionDateTime, ActionUserId)
								SELECT tbl.'+ @UniqueIdentifier +' , ' + @ColumnsForTrigger + ' 1, tbl.WhenUpdated, tbl.WhoCreatedId
								FROM inserted tbl';
						EXECUTE sp_executeSQL @ExecSQL
						--PRINT '====== Created trigger trg_' + @TableName + '_Insert ======'

						IF (EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_' + @TableName + '_Update'))
						BEGIN
							SET @ExecSQL = 'DROP TRIGGER [' + @TableSchema + '].[trg_' + @TableName + '_Update]';
							EXECUTE sp_executeSQL @ExecSQL
						END

						IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'Summary' AND Object_ID = Object_ID(N'dbo.' + @TableName))
						BEGIN
							SET @ExecSQL = 'CREATE TRIGGER [' + @TableSchema + '].[trg_' + @TableName + '_Update] 
									ON [' + @TableSchema + '].[' + @TableName + '] 
									AFTER UPDATE
								AS 
									SET NOCOUNT ON; 
									IF NOT UPDATE(Summary)
									BEGIN
										INSERT INTO [ERSAudit].[' + @AuditTableName + '] ('+ @UniqueIdentifier +', ' + @ColumnsForTrigger + ' LastActionId, ActionDateTime, ActionUserId)
										SELECT tbl.'+ @UniqueIdentifier +' , ' + @ColumnsForTrigger + ' 2, GETDATE(), i.WhoUpdatedId
										FROM deleted tbl INNER JOIN inserted i ON tbl.'+ @UniqueIdentifier +' = i.'+ @UniqueIdentifier + '
									END';
						END
						ELSE
						BEGIN
							SET @ExecSQL = 'CREATE TRIGGER [' + @TableSchema + '].[trg_' + @TableName + '_Update] 
								ON [' + @TableSchema + '].[' + @TableName + '] 
								AFTER UPDATE
							AS 
								SET NOCOUNT ON; 
								INSERT INTO [ERSAudit].[' + @AuditTableName + '] ('+ @UniqueIdentifier +', ' + @ColumnsForTrigger + ' LastActionId, ActionDateTime, ActionUserId)
								SELECT tbl.'+ @UniqueIdentifier +' , ' + @ColumnsForTrigger + ' 2, GETDATE(), i.WhoUpdatedId
								FROM deleted tbl INNER JOIN inserted i ON tbl.'+ @UniqueIdentifier +' = i.'+ @UniqueIdentifier;
						END


						EXECUTE sp_executeSQL @ExecSQL
						--PRINT '====== Created trigger trg_' + @TableName + '_Update ======'

						IF (EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_' + @TableName + '_Delete'))
						BEGIN
							SET @ExecSQL = 'DROP TRIGGER [' + @TableSchema + '].[trg_' + @TableName + '_Delete]';
							EXECUTE sp_executeSQL @ExecSQL
						END

						SET @ExecSQL = 'CREATE TRIGGER [' + @TableSchema + '].[trg_' + @TableName + '_Delete] 
								ON [' + @TableSchema + '].[' + @TableName + '] 
								AFTER DELETE
							AS 
								SET NOCOUNT ON; 
								INSERT INTO [ERSAudit].[' + @AuditTableName + '] ('+ @UniqueIdentifier +', ' + @ColumnsForTrigger + ' LastActionId, ActionDateTime, ActionUserId)
								SELECT tbl'+ @UniqueIdentifier +' , ' + @ColumnsForTrigger + ' 3, tbl.WhenUpdated, tbl.WhoUpdatedId
								FROM deleted tbl';
						EXECUTE sp_executeSQL @ExecSQL
						--PRINT '====== Created trigger trg_' + @TableName + '_Delete ======'
					END

					FETCH NEXT FROM audit_cursor 
					INTO @TableSchema, @TableName
				END
				CLOSE audit_cursor;
				DEALLOCATE audit_cursor;
			COMMIT TRANSACTION
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH;
END
GO





/****** Object:  Table [ERSAudit].[tblTablesToBeAudited]    Script Date: 06/02/2019 02:48:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'ERSAudit' 
                 AND  TABLE_NAME = 'tblTablesToBeAudited'))
BEGIN
    --Do Stuff
	DROP Table [ERSAudit].[tblTablesToBeAudited]
END

CREATE TABLE [ERSAudit].[tblTablesToBeAudited](
	[TableSchema] [nvarchar](30) NOT NULL,
	[TableName] [nvarchar](100) NOT NULL,
	CONSTRAINT [PK_tblTablesToBeAudited_1] PRIMARY KEY CLUSTERED 
(
	[TableSchema] ASC,
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Trigger [ERSAudit].[trg_tblTablesToBeAudited_Delete]    Script Date: 06/02/2019 02:48:19 PM ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [ERSAudit].[trg_tblTablesToBeAudited_Delete] 
		ON [ERSAudit].[tblTablesToBeAudited]
		AFTER DELETE
		AS 
		BEGIN
			-- SET NOCOUNT ON added to prevent extra result sets from
			-- interfering with SELECT statements.
			SET NOCOUNT ON;

			DECLARE @TableSchema nvarchar(255), @TableName nvarchar(255);
			DECLARE @ExecSQL NVARCHAR(2000);

			SELECT @TableSchema = TableSchema, @TableName = TableName
			FROM deleted;

			SET @ExecSQL = 'IF (EXISTS (SELECT * FROM sys.triggers WHERE name = ''trg_' + @TableName + '_Insert''))
				DROP TRIGGER [' + @TableSchema + '].[trg_' + @TableName + '_Insert];
				IF (EXISTS (SELECT * FROM sys.triggers WHERE name = ''trg_' + @TableName + '_Update''))
				DROP TRIGGER [' + @TableSchema + '].[trg_' + @TableName + '_Update];
				IF (EXISTS (SELECT * FROM sys.triggers WHERE name = ''trg_' + @TableName + '_Delete''))
				DROP TRIGGER [' + @TableSchema + '].[trg_' + @TableName + '_Delete];';
			EXECUTE sp_executeSQL @ExecSQL;
		END
GO

ALTER TABLE [ERSAudit].[tblTablesToBeAudited] ENABLE TRIGGER [trg_tblTablesToBeAudited_Delete]
GO

/****** Object:  Trigger [ERSAudit].[trg_tblTablesToBeAudited_Insert]    Script Date: 06/02/2019 02:48:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [ERSAudit].[trg_tblTablesToBeAudited_Insert] 
		ON [ERSAudit].[tblTablesToBeAudited]
		AFTER INSERT
		AS 
		BEGIN
			-- SET NOCOUNT ON added to prevent extra result sets from
			-- interfering with SELECT statements.
			SET NOCOUNT ON;

			DECLARE @Schema nvarchar(255), @Table nvarchar(255);

			SELECT @Schema = TableSchema, @Table = TableName
			FROM INSERTED;

			EXEC [ERSAudit].[UpdateAuditTables] @Schema = @Schema, @Table = @Table;
		END
GO

ALTER TABLE [ERSAudit].[tblTablesToBeAudited] ENABLE TRIGGER [trg_tblTablesToBeAudited_Insert]
GO
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- INSERT audited tablename in [ERSAudit].[tblTablesToBeAudited]
--------------------------------------------------------------------------------------------------------

	SELECT  TABLE_NAME  AS tblName
	INTO #tmp_Audit_tables
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE LEFT(TABLE_NAME,4) = 'ERS_' AND TABLE_TYPE IN ('BASE TABLE') 
	AND LEFT(TABLE_NAME,7) <> 'ERS_OCS' 
	AND TABLE_NAME NOT IN ('ERS_AuditLog', 'ERS_AuditLog_Details', 'ERS_DemographicHL7', 'ERS_ErrorLog', 'ERS_Feedback', 'ERS_RecordCount', 'ERS_ProceduresReporting')



	DECLARE @tbl_name as VARCHAR(200) = ''

	WHILE (SELECT Count(*) From #tmp_Audit_tables) > 0
	BEGIN
		Select Top 1 @tbl_name = tblName From #tmp_Audit_tables

		IF ISNULL(@tbl_name,'') <> ''
		BEGIN
			DECLARE @sql_Audit_tables AS VARCHAR(500) = ''
			SET @sql_Audit_tables =	'INSERT INTO [ERSAudit].[tblTablesToBeAudited] (TableSchema, TableName) SELECT ''dbo'', '''
								+ @tbl_name + ''''

			EXEC (@sql_Audit_tables)
		END

		Delete #tmp_Audit_tables Where tblName = @tbl_name
	END
	DROP TABLE #tmp_Audit_tables

GO

----***** 'SET NOEXEC OFF' statement is excuted to reset 'NOEXEC ON' for the current session . 
--SET NOEXEC OFF
----------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
---- DO NOT ADD SCRIPT AFTER THIS LINE - 
---- ALL SCRIPT SHOULD GO ABOVE AUDIT  (SEE above, Audit table scripts)