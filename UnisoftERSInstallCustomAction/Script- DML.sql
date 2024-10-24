begin transaction
	--###########################################################################
	--############## Import Consultant in ERS.Users Table #######################
	--###########################################################################
	--BEGIN	/* Add new fields in 	[ERS_Users]	*/

	  ALTER TABLE
	  [Stoke_Gastro_Live].[dbo].[ERS_Users]
	  ADD 
		  [MedicineTitle]		VARCHAR(100) NULL -- MBBS, FRCPS, BLA BLA BLA!
		, [IsImported]			BIt
		, [UGI_ConsultantId]	VARCHAR(12);
		
		go
		ALTER TABLE [dbo].[ERS_Users] ADD  CONSTRAINT [DF_ERS_Users_RecordCreated]		DEFAULT (getdate()) FOR [RecordCreated];
		ALTER TABLE [dbo].[ERS_Users] ADD  CONSTRAINT [DF_ERS_Users_LastUpdated]		DEFAULT (getdate()) FOR [LastUpdated];
		ALTER TABLE [dbo].[ERS_Users] ADD  CONSTRAINT [DF_ERS_Users_ExpiresOn]			DEFAULT (dateadd(year,(5),getdate())) FOR [ExpiresOn];

	--END
	
	GO

	BEGIN
		DECLARE @NewSeedValue AS INT;
		select @NewSeedValue=COUNT(*)+1 FROM [dbo].[ERS_Users];
		DBCC CHECKIDENT( [ERS_Users], RESEED, @NewSeedValue  );

		INSERT INTO [dbo].[ERS_Users]
			   (
				[Forename]		-- WIll get the full name initially!
			   ,[Surname]
			   ,[JobTitleID]	
			   ,[Description]
			   ,[IsListConsultant]      ,[IsEndoscopist1]           ,[IsEndoscopist2]           ,[IsAssistantOrTrainee]
			   ,[IsNurse1]				,[IsNurse2]
			   ,[Active]				,[Suppressed]
			   --,[UGI_UserID]	-- Note: Everyone will get a new user name/id! their email address.. password stays the same...
			   , [MedicineTitle],		[IsImported]				,[UGI_ConsultantId]
			   , [Username], [Password], [Title],		  [AccessID], [AccessRights], [RoleID], [DeletePatients], [ModifyTables], [CanRunAK], [HideStartUpCharts], [ResetPassword], [ShowTooltips])    
		select 
		   (case when CHARINDEX(',', CON.[Consultant/Operator])>0 then 
						(LEFT(CON.[Consultant/Operator], CHARINDEX(',', CON.[Consultant/Operator])-1))
						ELSE (CON.[Consultant/Operator]) END) AS Forename
		  ,Con.[Surname] 
		  ,Con.[Consultant/Operator title]
		  ,Con.[Consultant/operator]	-- Goes in ERS_USers.Description
      
		  ,Con.[IsListConsultant]      ,Con.[IsEndoscopist1]      ,Con.[IsEndoscopist2]      ,Con.[IsAssistantTrainee]
		  ,Con.[IsNurse1]      ,Con.[IsNurse2]
		  ,Con.[Suppress]	,Con.[Suppress]-- goes in [Suppressed]
		  , (case when CHARINDEX(',', CON.[Consultant/Operator])>0 then 
						(RIGHT(CON.[Consultant/Operator], LEN(CON.[Consultant/Operator])- CHARINDEX(',', CON.[Consultant/Operator])-1))
						ELSE ('') END) AS MedicineTitle
		  , 1 -- Imported Flag
		  , Con.[Consultant/operator ID]	-- as [UGI_ConsultantId]
		  , Con.[Consultant/operator ID] -- as UserName- we need to provide a new User Name.. maybw with their Email idS!
		  , -1	-- [Password] - 
		  , (CASE LEFT(CON.[Consultant/Operator], 3) WHEN 'Mr ' then 'Mr' WHEN 'Mrs' then 'Mrs' WHEN 'Dr ' then 'Dr' else '' end) -- AS Title
		  , 1 -- [AccessID]
		  , 1	-- [AccessRights]
		  , 5	-- [RoleID]
		  , 0	-- [DeletePatients]
		  , 0	-- [ModifyTables]
		  , 0	-- [CanRunAK]
		  , 0	-- [HideStartUpCharts]
		  , 0	-- [ResetPassword]
		  , 0	-- [ShowTooltips]
		from dbo.[Consultant/Operators] as Con
		where ([IsListConsultant]+[IsEndoscopist1]+[IsEndoscopist2]+[IsAssistantTrainee]+[IsNurse1]+[IsNurse2])<>0 -- Also Include the Suppressed Records.. Bring them all.. as long as - "Consultant"
			AND LOWER(Con.[Consultant/operator])<>'(none)';



		--#### Now Update the ForeName. Remove the Mr/Mrs/Dr Titles. Remove the Last Name from the ForeName!
		--BEGIN TRAN
		UPDATE dbo.ERS_Users
			SET Forename = REPLACE(Forename, Title, '');	--### Remove the 'Dr', 'Mr/Mrs' from teh First Name..
		UPDATE dbo.ERS_Users
			SET Forename = REPLACE(Forename, Surname, '')	--### Remove the Surname, its already in a seperate column
		UPDATE dbo.ERS_Users
			SET Forename = REPLACE(Forename, ' ', '');		--### Remove any extra white spaces!
	END


	GO

		--###### Import the Job Titles from UGI.Lists -> [dbo].[ERS_JobTitles]
		--## First add a new field to hold to [List Item No] from UGI.Lists
		ALTER TABLE [dbo].[ERS_JobTitles]
				ADD [ListItemNo] INT NULL;
	GO	
	--DECLARE @NewSeedValue AS INT;
		 --select @NewSeedValue=COUNT(*)+1 FROM [dbo].[ERS_JobTitles];

		--## Make the existing Dummy Data- Suppressed- should not appear on Live System!
		UPDATE [Stoke_Gastro_Live].[dbo].[ERS_JobTitles]
		   SET Suppressed=1;
		DBCC CHECKIDENT( [ERS_JobTitles], RESEED,@NewSeedValue  );

		-- ## Now Import all the [Consultant/operator title] From dbo.Lists
	   INSERT INTO [dbo].[ERS_JobTitles]([Description], [ListItemNo])
			SELECT L.[List item text], L.[List item no] from dbo.Lists AS L
 			 WHERE [List description]= 'Consultant/operator title' AND [List item no]<>0
		  ORDER BY [List item text];
	GO
		--### Now Update the [ERS_Users].JobTitleId = [dbo].[ERS_JobTitles].JobTitleId WHERE [ListItemNo]=
		UPDATE U
			SET U.JobTitleId = JT.JobTitleId 
				FROM [dbo].[ERS_Users] AS U
				INNER JOIN [dbo].[ERS_JobTitles] AS JT ON U.JobTitleId = JT.ListItemNo;
	
	commit transaction


BEGIN--#### Enter Consultant Type in the ERS_List table..
-- But before that- Insert the Parent Key in the ListMain Table;

	INSERT INTO [dbo].[ERS_ListsMain]
           ([ListDescription]
           ,[AllowAddNewItem]
           --,[HtmlId]
		   )
     VALUES
           ('ConsultantType', 1
		   --,  'ComboConsultants'
		   );


	--## Now in the Child Table!
	INSERT INTO [dbo].[ERS_Lists]
           ([ListDescription]
           ,[ListItemNo]
           ,[ListItemText])
     VALUES
           ('ConsultantType', 1, 'Assistant / trainee'), 
		   ('ConsultantType', 2, 'Endoscopist 1'), 
		   ('ConsultantType', 3, 'Endoscopist 2'), 
		   ('ConsultantType', 4, 'List Consultant'), 
		   ('ConsultantType', 5, 'Nurse 1'), 
		   ('ConsultantType', 6, 'Nurse 2'), 
		   ('ConsultantType', 7, 'Nurse 3')

END

--########### List all the Users matching: ERS with UGI, AND Update them on ERS- from UGI Table!
BEGIN

	;WITH stageRecordToJoinUGIAndERS_Users AS(
	select Con.UGI_ConsultantId, Surname, Con.UserID
		, (SELECT top 1 U.[User_ID] FROM dbo.users AS U where U.[01] like ('%' + Con.Surname)) AS UGI_LoginID --### For [Con.UGI_UserID]
		from dbo.ERS_Users_Imported AS Con 
		where Con.IsImported=1
	)
	UPDATE ERS
	SET ERS.UGI_UserID = UGI.UGI_LoginID
	FROM dbo.ERS_Users_Imported AS ERS
	INnER JOIN stageRecordToJoinUGIAndERS_Users AS UGI ON ERS.UserID=UGI.UserID

END