/* REMARKS */
/* Consolidated report V 2.0 */
/* There are still some scripts not compatible with SQL Server 2008 */
/* Splitting of some scripts between ERS and UGI is in progress */
/* Customized setup for ERS And/Or/Xor UGI version is still pending */
/*------------------------------Reporting Consolidated Script------------------------------*/
/*------------------------------   BEGIN OF HUSSEIN'S PART   ------------------------------*/
Set NOCOUNT ON
GO
BEGIN TRANSACTION
GO
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'GPCode' AND Object_ID = Object_ID(N'ERS_GP'))
ALTER TABLE dbo.ERS_GP ADD GPCode nvarchar(50) NULL
GO
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'GPPracticeCode' AND Object_ID = Object_ID(N'ERS_GP'))
ALTER TABLE dbo.ERS_GP ADD GPPracticeCode nvarchar(50) NULL
GO
ALTER TABLE dbo.ERS_GP SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
GO
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'GPCode' AND Object_ID = Object_ID(N'ERS_Procedures'))
ALTER TABLE dbo.ERS_Procedures ADD GPCode TINYINT NULL
GO
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'GPPracticeCode' AND Object_ID = Object_ID(N'ERS_Procedures'))
ALTER TABLE dbo.ERS_Procedures ADD GPPracticeCode TINYINT NULL
GO
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Jmanoeuvre' AND Object_ID = Object_ID(N'ERS_Procedures'))
ALTER TABLE dbo.ERS_Procedures ADD Jmanoeuvre TINYINT NULL
GO
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ListType' AND Object_ID = Object_ID(N'ERS_Procedures'))
ALTER TABLE dbo.ERS_Procedures ADD ListType TINYINT NULL
GO
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'ProcedureRole' AND Object_ID = Object_ID(N'ERS_Procedures'))
ALTER TABLE dbo.ERS_Procedures ADD ProcedureRole TINYINT NULL
GO
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'NEDEnabled' AND Object_ID = Object_ID(N'ERS_Procedures'))
ALTER TABLE dbo.ERS_Procedures ADD NEDEnabled BIT NULL
GO
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'NEDExported' AND Object_ID = Object_ID(N'ERS_Procedures'))
ALTER TABLE dbo.ERS_Procedures ADD NEDExported BIT NULL
GO
ALTER TABLE dbo.ERS_Procedures SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
Go
