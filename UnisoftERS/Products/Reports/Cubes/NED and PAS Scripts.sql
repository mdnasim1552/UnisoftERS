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
--------------------------- NED Files
If object_id('[dbo].[CompareXml]') is not null Drop Function [dbo].[CompareXml]
Go
CREATE FUNCTION [dbo].[CompareXml]
(
    @xml1 XML,
    @xml2 XML
)
RETURNS INT
AS 
BEGIN
	--Source: http://stackoverflow.com/questions/9013680/t-sql-how-can-i-compare-two-variables-of-type-xml-when-length-varcharmax
    DECLARE @ret INT
    SELECT @ret = 0

    -- -------------------------------------------------------------
    -- If one of the arguments is NULL then we assume that they are
    -- not equal. 
    -- -------------------------------------------------------------
    IF @xml1 IS NULL OR @xml2 IS NULL 
    BEGIN
        RETURN 1
    END

    -- -------------------------------------------------------------
    -- Match the name of the elements 
    -- -------------------------------------------------------------
    IF  (SELECT @xml1.value('(local-name((/*)[1]))','VARCHAR(MAX)')) 
        <> 
        (SELECT @xml2.value('(local-name((/*)[1]))','VARCHAR(MAX)'))
    BEGIN
        RETURN 1
    END

     ---------------------------------------------------------------
     --Match the value of the elements
     ---------------------------------------------------------------
    IF((@xml1.query('count(/*)').value('.','INT') = 1) AND (@xml2.query('count(/*)').value('.','INT') = 1))
    BEGIN
    DECLARE @elValue1 VARCHAR(MAX), @elValue2 VARCHAR(MAX)

    SELECT
        @elValue1 = @xml1.value('((/*)[1])','VARCHAR(MAX)'),
        @elValue2 = @xml2.value('((/*)[1])','VARCHAR(MAX)')

    IF  @elValue1 <> @elValue2
    BEGIN
        RETURN 1
    END
    END

    -- -------------------------------------------------------------
    -- Match the number of attributes 
    -- -------------------------------------------------------------
    DECLARE @attCnt1 INT, @attCnt2 INT
    SELECT
        @attCnt1 = @xml1.query('count(/*/@*)').value('.','INT'),
        @attCnt2 = @xml2.query('count(/*/@*)').value('.','INT')

    IF  @attCnt1 <> @attCnt2 BEGIN
        RETURN 1
    END

    -- -------------------------------------------------------------
    -- Match the attributes of attributes 
    -- Here we need to run a loop over each attribute in the 
    -- first XML element and see if the same attribut exists
    -- in the second element. If the attribute exists, we
    -- need to check if the value is the same.
    -- -------------------------------------------------------------
    DECLARE @cnt INT, @cnt2 INT
    DECLARE @attName VARCHAR(MAX)
    DECLARE @attValue VARCHAR(MAX)

    SELECT @cnt = 1

    WHILE @cnt <= @attCnt1 
    BEGIN
        SELECT @attName = NULL, @attValue = NULL
        SELECT
            @attName = @xml1.value(
                'local-name((/*/@*[sql:variable("@cnt")])[1])', 
                'varchar(MAX)'),
            @attValue = @xml1.value(
                '(/*/@*[sql:variable("@cnt")])[1]', 
                'varchar(MAX)')

        -- check if the attribute exists in the other XML document
        IF @xml2.exist(
                '(/*/@*[local-name()=sql:variable("@attName")])[1]'
            ) = 0
        BEGIN
            RETURN 1
        END

        IF  @xml2.value(
                '(/*/@*[local-name()=sql:variable("@attName")])[1]', 
                'varchar(MAX)')
            <>
            @attValue
        BEGIN
            RETURN 1
        END

        SELECT @cnt = @cnt + 1
    END

    -- -------------------------------------------------------------
    -- Match the number of child elements 
    -- -------------------------------------------------------------
    DECLARE @elCnt1 INT, @elCnt2 INT
    SELECT
        @elCnt1 = @xml1.query('count(/*/*)').value('.','INT'),
        @elCnt2 = @xml2.query('count(/*/*)').value('.','INT')
    IF  @elCnt1 <> @elCnt2
    BEGIN
        RETURN 1
    END

    -- -------------------------------------------------------------
    -- Start recursion for each child element
    -- -------------------------------------------------------------
    SELECT @cnt = 1
    SELECT @cnt2 = 1
    DECLARE @x1 XML, @x2 XML
    DECLARE @noMatch INT

    WHILE @cnt <= @elCnt1 
    BEGIN

        SELECT @x1 = @xml1.query('/*/*[sql:variable("@cnt")]')
    --RETURN CONVERT(VARCHAR(MAX),@x1)
    WHILE @cnt2 <= @elCnt2
    BEGIN
        SELECT @x2 = @xml2.query('/*/*[sql:variable("@cnt2")]')
        SELECT @noMatch = dbo.CompareXml( @x1, @x2 )
        IF @noMatch = 0 BREAK
        SELECT @cnt2 = @cnt2 + 1
    END

    SELECT @cnt2 = 1

        IF @noMatch = 1
        BEGIN
            RETURN 1
        END

        SELECT @cnt = @cnt + 1
    END

    RETURN @ret
END
GO
/* [dbo].[v_rep_NEDLog] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_NEDLog]')) Drop View [dbo].[v_rep_NEDLog]
GO

/* [dbo].[ERS_NedFilesLog] */
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_NedFilesLog]')) Drop Table [dbo].[ERS_NedFilesLog]
GO

/* [dbo].[ERS_TherapeuticTypes] */
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_TherapeuticTypes]')) Drop Table [dbo].[ERS_TherapeuticTypes]
GO

/* [dbo].[ERS_TherapeuticTypes] */
CREATE TABLE [dbo].[ERS_TherapeuticTypes]( [TherapeuticID] [int] IDENTITY(1,1) NOT NULL, [Therapeutic] [varchar](128) NOT NULL, [NedName] [varchar](128) NOT NULL, [Category] [varchar](128) NULL, CONSTRAINT [ERS_TherapeuticTypes.PK.TherapeuticId] PRIMARY KEY CLUSTERED ( [TherapeuticID] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY] ) ON [PRIMARY] 
GO

/* Insert Into ERS_TherapeuticTypes */
Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('None','None','None') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Argon beam diathermy','Argon beam photocoagulation','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Balloon dilatation','Balloon dilation','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Bicap electrocautery','Other','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Endoscopic mucosal resection','EMR','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Endoscopic mucosal dissection','ESD','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Heater probe coagulation','Heater probe','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Hot Biopsy','Polyp - hot biopsy','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Injection therapy','Injection therapy','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Nasojejunal tube','Other','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Oesophageal dilatation','Other','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Banding of haemorrhoid','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Clip placement','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Endoloop placement','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Foreign body removal','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Marking / tattooing','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Polyp - cold biopsy','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Polyp - EMR','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Polyp - ESD','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Polyp - snare cold','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Polyp - snare hot','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Stent change','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('PEG','PEG change','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('PEG','PEG placement','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('PEG','PEG removal','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('PEGJ/PEG','Other','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Polypectomy','Polypectomy','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Pyloric/duodenal dilatation','Other','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Radio frequency ablation','Radio frequency ablation','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Stent insertion','Stent placement','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Stent removal','Stent removal','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Variceal sclerotherapy','Variceal sclerotherapy','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Variceal banding','Other','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('YAG laser','YAG laser','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Balloon sphicteroplasty','Other','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Endoscopic cyst puncture','Other','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Nasobiliary/pancreatic drain','Nasopancreatic / bilary drain','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Balloon trawl','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Bougie dilation','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Brush cytology','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Cannulation','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Combined (rendezvous) proc','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Diagnostic cholangiogram','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Diagnostic pancreatogram','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Endoscopic cyst puncture','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Haemostasis','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Manometry','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Stone removal','Stone extraction >=10mm','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Stone removal','Stone extraction <10mm','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures (ERCP)','Other','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Pancreatic orifice sphicterotomy','Sphincterotomy','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Sphincterotomy','Sphincterotomy','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Snare excision','Polyp - snare hot','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Stent insertion','Stent placement - CBD','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Stent insertion','Stent placement - pancreas','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Stent removal','Stent removal','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Stone removal','Stone extraction >=10mm','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Stone removal','Stone extraction <10mm','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Stricture dilatation','Balloon trawl','ERCP') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Argon beam diathermy','Argon beam photocoagulation','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Balloon dilatation','Balloon dilation','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Banding of piles','Band ligation','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Bicap electrocautery','Other','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Endoscopic mucosal resection','EMR','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Endoscopic submucosal dissection','ESD','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Heater probe coagulation','Heater probe','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Hot Biopsy','Hot biopsy','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Injection therapy','Botox injection','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Other','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Polypectomy','Polypectomy','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Radio frequency ablation','Radio frequency ablation','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Stent insertion','Stent placement','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Stent removal','Stent removal','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Variceal banding','Variceal sclerotherapy','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('YAG laser','YAG laser','Col/Sig/proctoscopy') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Other','OGD') Insert Into ERS_TherapeuticTypes (Therapeutic, NedName, Category) Values ('Other therapeutic procedures','Clip placement','Col/Sig/proctoscopy') 
GO

/* [dbo].[ERS_IndicationsTypes] */
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_IndicationsTypes]')) Drop Table [dbo].[ERS_IndicationsTypes]
GO

/* [dbo].[ERS_IndicationsTypes] mmm*/
CREATE TABLE [dbo].[ERS_IndicationsTypes]( [IndicationID] INT NOT NULL IDENTITY(0,1), CONSTRAINT [ERS_IndicationsTypes.PK.IndicationId] PRIMARY KEY CLUSTERED ([IndicationID]), [Indication] [varchar](128) NOT NULL, [NedName] varchar(128) NOT NULL, [Category] VARCHAR(128), ) 
GO

/* Insert Into ERS_IndicationsTypes */
Insert Into ERS_IndicationsTypes (Indication, NedName, Category) Values ('None','None','None') ,('','Other','') ,('','Abdominal pain','') ,('','Abnormality on CT / barium','') ,('','Anaemia','') ,('','Barretts oesophagus','') ,('','Diarrhoea','') ,('','Dyspepsia','') ,('','Dysphagia','') ,('','Haematemesis','') ,('','Heartburn / reflux','') ,('','Melaena','') ,('','Nausea / vomiting','') ,('','Odynophagia','') ,('','PEG change','') ,('','PEG placement','') ,('','PEG removal','') ,('','Positive TTG / EMA','') ,('','Stent change','') ,('','Stent placement','') ,('','Stent removal','') ,('','Follow up of gastric ulcer','') ,('','Varices surveillance / screening','') ,('','Weight loss','') ,('','BCSP','') ,('','Abdominal mass','') ,('','Abnormal sigmoidoscopy','') ,('','Chronic alternating diarrhoea / constipation','') ,('','Colorectal cancer - follow up','') ,('','Constipation - acute','') ,('','Constipation - chronic','') ,('','Defaecation disorder','') ,('','Diarrhoea - acute','') ,('','Diarrhoea - chronic','') ,('','Diarrhoea - chronic with blood','') ,('','FHx of colorectal cancer','') ,('','FOB +''ve','') ,('','IBD assessment / surveillance','') ,('','Polyposis syndrome','') ,('','PR bleeding - altered blood','') ,('','PR bleeding - anorectal','') ,('','Previous / known polyps','') ,('','Tumour assessment','') ,('','Abnormal liver enzymes','') ,('','Acute pancreatitis','') ,('','Ampullary mass','') ,('','Bile duct injury','') ,('','Bile duct leak','') ,('','Cholangitis','') ,('','Chronic pancreatitis','') ,('','Gallbladder mass','') ,('','Gallbladder polyp','') ,('','Hepatobiliary mass','') ,('','Jaundice','') ,('','Pancreatic mass','') ,('','Pancreatic pseudocyst','') ,('','Pancreatobiliary pain','') ,('','Papillary dysfunction','') ,('','Pre lap choledocholithiasis','') ,('','Primary sclerosing cholangitis','') ,('','Purulent cholangitis','') ,('','Stent dysfunction','') 
GO

/* [dbo].[ERS_ReportAdverse] */
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportAdverse]')) Drop Table [dbo].[ERS_ReportAdverse]
GO

/* [dbo].[ERS_ReportAdverse] */
Create Table [dbo].[ERS_ReportAdverse] ( AdverseId INT, AdverseEvent VARCHAR(100) ) 
GO

/* Insert Into [dbo].[ERS_ReportAdverse] */
Insert Into [dbo].[ERS_ReportAdverse] (AdverseId, AdverseEvent) Values (1,'None'), (2,'Other'), (3,'Ventilation'), (4,'Perforation of lumen'), (5,'Bleeding'), (6,'O2 desaturation'), (7,'Flumazenil'), (8,'Naloxone'), (9,'Consent signed in room'), (10,'Withdrawal of consent'), (11,'Unplanned admission'), (12,'Unsupervised trainee'), (13,'Death'), (14,'Pancreatitis') 
GO

/* [dbo].[ERS_ReportTherapy] */
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportTherapy]')) Drop Table [dbo].[ERS_ReportTherapy]
GO

/* [dbo].[ERS_ReportTherapy] */
Create Table [dbo].[ERS_ReportTherapy] ( TherapyId INT, Therapy VARCHAR(100) ) 
GO

/* Insert Into [dbo].[ERS_ReportTherapy] */
Insert Into ERS_ReportTherapy (TherapyId, Therapy) VALUES (1,'Anastomosis'), (2,'Other'), (3,'Argon beam photocoagulation'), (4,'Balloon dilation'), (5,'Banding of haemorrhoid'), (6,'Clip placement'), (7,'Endoloop placement'), (8,'Foreign body removal'), (9,'Injection therapy'), (10,'Marking / tattooing'), (11,'Polyp - cold biopsy'), (12,'Polyp - EMR'), (13,'Polyp - ESD'), (14,'Polyp - hot biopsy'), (15,'Polyp - snare cold'), (16,'Polyp - snare hot'), (17,'Stent change'), (18,'Stent placement'), (19,'Stent removal'), (20,'YAG laser'), (21,'Balloon trawl'), (22,'Bougie dilation'), (23,'Brush cytology'), (24,'Cannulation'), (25,'Combined (rendezvous) proc'), (26,'Diagnostic cholangiogram'), (27,'Diagnostic pancreatogram'), (28,'Endoscopic cyst puncture'), (29,'Haemostasis'), (30,'Manometry'), (31,'Nasopancreatic / bilary drain'), (32,'Sphincterotomy'), (33,'Stent placement - CBD'), (34,'Stent placement - pancreas'), (35,'Stone extraction >=10mm'), (36,'Stone extraction <10mm'), (37,'Band ligation'), (38,'Botox injection'), (39,'EMR'), (40,'ESD'), (41,'Heater probe'), (42,'Hot biopsy'), (43,'PEG change'), (44,'PEG placement'), (45,'PEG removal'), (46,'Polypectomy'), (47,'Radio frequency ablation'), (48,'Variceal sclerotherapy') 
GO

/* [dbo].[ERS_Organs] */
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_Organs]')) Drop Table [dbo].[ERS_Organs]
GO

/* [dbo].[ERS_Organs] */
Create Table [dbo].[ERS_Organs] ( RegionId INT PRIMARY KEY CLUSTERED, Organ VARCHAR(100) ) 
GO

/* INSERT INTO ERS_Organs */
INSERT INTO ERS_Organs (RegionId,Organ) Values ( 0,'None'), ( 1,'Oesophagus'), ( 2,'Oesophagus'), ( 3,'Oesophagus'), ( 4,'Oesophagus'), ( 5,'Oesophagus'), ( 6,'Oesophagus'), ( 7,'Oesophagus'), ( 8,'Oesophagus'), ( 9,'Oesophagus'), ( 10,'Stomach'), ( 11,'Stomach'), ( 12,'Stomach'), ( 13,'Stomach'), ( 14,'Stomach'), ( 15,'Stomach'), ( 16,'Stomach'), ( 17,'Stomach'), ( 18,'Stomach'), ( 19,'Stomach'), ( 20,'Stomach'), ( 21,'Stomach'), ( 22,'Stomach'), ( 23,'Stomach'), ( 24,'D2 - 2nd part of duodenum'), ( 25,'D2 - 2nd part of duodenum'), ( 26,'D2 - 2nd part of duodenum'), ( 27,'D2 - 2nd part of duodenum'), ( 28,'D2 - 2nd part of duodenum'), ( 29,'D2 - 2nd part of duodenum'), ( 30,'Duodenal bulb'), ( 31,'Duodenal bulb'), ( 32,'Duodenal bulb'), ( 33,'D2 - 2nd part of duodenum'), ( 34,'D2 - 2nd part of duodenum'), ( 35,'D2 - 2nd part of duodenum'), ( 36,'D2 - 2nd part of duodenum'), ( 37,'D2 - 2nd part of duodenum'), ( 38,'D2 - 2nd part of duodenum'), ( 39,'D2 - 2nd part of duodenum'), ( 40,'Terminal ileum'), ( 41,'Caecum'), ( 42,'Terminal ileum'), ( 43,'Terminal ileum'), ( 44,'Ascending Colon'), ( 45,'Ascending Colon'), ( 46,'Ascending Colon'), ( 47,'Hepatic flexure'), ( 48,'Transverse Colon'), ( 49,'Transverse Colon'), ( 50,'Transverse Colon'), ( 51,'Splenic flexure'), ( 52,'Descending Colon'), ( 53,'Descending Colon'), ( 54,'Descending Colon'), ( 55,'Sigmoid Colon'), ( 56,'Sigmoid Colon'), ( 57,'Sigmoid Colon'), ( 58,'Rectum'), ( 59,'Anus'), ( 60,'Terminal ileum'), ( 61,'Caecum'), ( 62,'Terminal ileum'), ( 63,'Terminal ileum'), ( 64,'Ascending Colon'), ( 65,'Ascending Colon'), ( 66,'Ascending Colon'), ( 67,'Hepatic flexure'), ( 68,'Transverse Colon'), ( 69,'Transverse Colon'), ( 70,'Transverse Colon'), ( 71,'Splenic flexure'), ( 72,'Descending Colon'), ( 73,'Descending Colon'), ( 74,'Descending Colon'), ( 75,'Sigmoid Colon'), ( 76,'Sigmoid Colon'), ( 77,'Sigmoid Colon'), ( 78,'Rectum'), ( 79,'Anus'), ( 80,'Terminal ileum'), ( 81,'Caecum'), ( 82,'Terminal ileum'), ( 83,'Terminal ileum'), ( 84,'Ascending Colon'), ( 85,'Ascending Colon'), ( 86,'Ascending Colon'), ( 87,'Hepatic flexure'), ( 88,'Transverse Colon'), ( 89,'Transverse Colon'), ( 90,'Transverse Colon'), ( 91,'Splenic flexure'), ( 92,'Descending Colon'), ( 93,'Descending Colon'), ( 94,'Descending Colon'), ( 95,'Sigmoid Colon'), ( 96,'Sigmoid Colon'), ( 97,'Sigmoid Colon'), ( 98,'Rectum'), ( 99,'Anus'), (100,'Anastomosis') 
GO

/* [dbo].[ERS_NedFilesLog] */
CREATE TABLE [dbo].[ERS_NedFilesLog](
	[LogId] INT NOT NULL IDENTITY(1,1),
	CONSTRAINT [ERS_NedFilesLog.PK.LogId] PRIMARY KEY CLUSTERED ([LogID]),
	[ProcedureID] INT NOT NULL,
	[xmlFile] XML,
	[logDate] DateTime Default GETDATE(),
	[IsProcessed] BIT DEFAULT 'FALSE',
	[IsSchemaValid] BIT NULL,
	[IsSent] BIT DEFAULT 'FALSE',
	[IsRejected] BIT DEFAULT NULL,
	[TimesSent] INT DEFAULT 0,
	[LastUserId] INT DEFAULT 0,
	[NEDMessage] NVARCHAR(512) NULL,
)

GO
CREATE VIEW [dbo].[v_rep_NEDLog]
WITH SCHEMABINDING
As
Select 
	NL.LogId, PT.ProcedureType, P.[Case note no] As CNN, P.[NHS No] AS NHS, IsNull(P.Forename+' ','')+IsNull(UPPER(P.Surname),'') As PatientName, NL.logDate, NL.IsProcessed, NL.IsSchemaValid, NL.IsSent, NL.IsRejected, NL.TimesSent, NL.LastUserId, NL.NEDMessage
	, '~/Images/icons/notes.png' As imageURL
	, NL.xmlFile, NL.ProcedureID, PT.ProcedureTypeId
From [dbo].[ERS_NedFilesLog] NL
	INNER JOIN [dbo].[ERS_Procedures] PR ON NL.ProcedureID=PR.ProcedureId
	INNER JOIN [dbo].[Patient] P ON PR.PatientId=P.[Patient No]
	INNER JOIN [dbo].[ERS_ProcedureTypes] PT ON PR.ProcedureType=PT.ProcedureTypeId
Go

CREATE TABLE [dbo].[ERS_ReportFilter](
	[UserID] [int] NOT NULL,
	CONSTRAINT [ERS_ReportFilter.PK.UserID] PRIMARY KEY CLUSTERED ([UserID]),
	[ReportDate] [datetime] NOT NULL DEFAULT GetDate(),
	[FromDate] [date] NULL DEFAULT (CONVERT([date],getdate()-(365))),
	[ToDate] [date] NULL DEFAULT (CONVERT([date],getdate())),
	[TypesOfEndoscopists] [int] NOT NULL DEFAULT 1,
	[HideSuppressed] [bit] NULL DEFAULT 1,
	[OGD] [bit] NULL DEFAULT 1,
	[Sigmoidoscopy] [bit] NULL DEFAULT 1,
	[PEGPEJ] [bit] NULL DEFAULT 1,
	[Colonoscopy] [bit] NULL DEFAULT 1,
	[ERCP] [bit] NOT NULL DEFAULT 1,
	[Bowel] [bit] NOT NULL DEFAULT 1,
	[BowelStandard] [bit] NOT NULL DEFAULT 1,
	[BowelBoston] [bit] NOT NULL DEFAULT 0,
	[Anonymise] [bit] NOT NULL DEFAULT 0,
)
GO
CREATE TABLE [dbo].[ERS_ReportConsultants](
	[UserID] [int] NOT NULL,
	CONSTRAINT [ERS_ReportConsultants.FK.UserID] FOREIGN KEY([UserID]) REFERENCES [dbo].[ERS_ReportFilter] ([UserID]) ON DELETE CASCADE,
	[ConsultantID] [int] NOT NULL,
	CONSTRAINT [ERS_ReportConsultants.PK.UserID_ConsultantID] PRIMARY KEY CLUSTERED ([UserID],[ConsultantID]),
	[AnonimizedID] [int] NOT NULL DEFAULT 0,
)
GO
CREATE TABLE [dbo].[ERS_ReportTarget](
	[ReportTargetID] [varchar](128) NOT NULL,
	CONSTRAINT [ERS_ReportTarget.PK.ReportTarget] PRIMARY KEY CLUSTERED ([ReportTargetID]),
	[ReportTargetName] [varchar](128) NOT NULL,
	[Modal] [bit] NOT NULL DEFAULT ('TRUE'),
	[StatusBar] [bit] NOT NULL DEFAULT ('FALSE'),
	[Width] [int] NULL,
	[Height] [int] NULL,
	[Left] [int] NULL,
	[Top] [int] NULL,
)
GO
CREATE TABLE [dbo].[ERS_ReportCategory](
	[ReportCategoryID] [varchar](128) NOT NULL,
	CONSTRAINT [ERS_ERS_ReportCategory.PK.ERS_ReportCategory] PRIMARY KEY CLUSTERED ([ReportCategoryID]),
	[CategoryName] [varchar](128) NOT NULL,
	[Enabled] [bit] NOT NULL DEFAULT 'TRUE',
)
GO
CREATE TABLE [dbo].[ERS_Report](
	[ReportID] [varchar](32) NOT NULL,
	CONSTRAINT [ERS_Reports.PK.ReportID] PRIMARY KEY CLUSTERED ([ReportID]),
	[ReportName] [varchar](128) NOT NULL ,
	[ReportCategoryID] [varchar](128) NOT NULL,
	CONSTRAINT [ERS_Report.FK.ReportCategoryID] FOREIGN KEY([ReportCategoryID]) REFERENCES [dbo].[ERS_ReportCategory] ([ReportCategoryID]),
	[ReportTargetID] [varchar](128) NOT NULL,
	CONSTRAINT [ERS_Report.FK.ReportTargetID] FOREIGN KEY([ReportTargetID]) REFERENCES [dbo].[ERS_ReportTarget] ([ReportTargetID]),
	[ReportTitle] [varchar](128) NOT NULL,
	[Parameters] [varchar](255) NULL DEFAULT ('rowID, columnName'),
	[Text] [varchar](128) NOT NULL DEFAULT (''),
	[ToolTip] [varchar](128) NOT NULL DEFAULT (''),
	[BackColor] [varchar](20) NULL,
	[ForeColor] [varchar](20) NULL,
	[ImageUrl] [varchar](128) NULL,
	[SortOrder] [int] NULL DEFAULT 0,
	[Enabled] [bit] NOT NULL DEFAULT 'TRUE',
	[ReportQuery] [varchar](8000) NULL,
)
GO
CREATE TABLE [dbo].[ERS_ReportGroup](
	[ReportGroupID] [varchar](3) NOT NULL,
	CONSTRAINT [ERS_ReportGroup.PK.ReportGroupID] PRIMARY KEY CLUSTERED ([ReportGroupID]),
 	[ReportGroupName] [varchar](128) NOT NULL,
	CONSTRAINT [ERS_ReportGroup.UNIQUE.ReportGroupName] UNIQUE NONCLUSTERED ([ReportGroupName]),
	[Parameters] [varchar](255) NULL DEFAULT ('UserID'),
	[ReportID] [varchar](32) NOT NULL,
	CONSTRAINT [ERS_ReportGroup.FK.ReportID] FOREIGN KEY([ReportID]) REFERENCES [dbo].[ERS_Report] ([ReportID]),
)
GO
CREATE TABLE [dbo].[ERS_ReportColumn](
	[ReportColumnID] [int] IDENTITY(1,1) NOT NULL,
	CONSTRAINT [PK_ERS_ReportColumn] PRIMARY KEY CLUSTERED ([ReportColumnID]),
	[ReportName] [varchar](500) NULL,
	[ReportColumnGroupID] [int] NULL,
	[ReportColumnGroupName] [varchar](500) NULL,
)
GO
CREATE TABLE [dbo].[ERS_ReportGroupColumn](
	[ReportGroupColumnID] [int] IDENTITY(1,1) NOT NULL,
	CONSTRAINT [ERS_ReportGroupColumn.PK.ReportGroupColumnID] PRIMARY KEY CLUSTERED ([ReportGroupColumnID]),
	[ReportGroupID] [varchar](3) NOT NULL,
	CONSTRAINT [ERS_ReportGroupColumn.FK.ReportGroupID] FOREIGN KEY([ReportGroupID]) REFERENCES [dbo].[ERS_ReportGroup] ([ReportGroupID]),
	[ColumnPosition] [int] NOT NULL,
	CONSTRAINT [ERS_ReportGroupColumn.UNIQUE.ReportGroupID.ColumnPosition] UNIQUE NONCLUSTERED ([ReportGroupColumnID],[ColumnPosition]),
	[ColumnName] [varchar](128) NOT NULL DEFAULT (''),
	[ReportID] [varchar](32) NOT NULL,
	CONSTRAINT [ERS_ReportGroupColumn.FK.ReportID] FOREIGN KEY([ReportID]) REFERENCES [dbo].[ERS_Report] ([ReportID]),
)
GO
CREATE TABLE [dbo].[ERS_ReportPopup](
	[ReportPopupID] [int] IDENTITY(1,1) NOT NULL,
	CONSTRAINT [ERS_ReportPopup.PK.ReportPopupID] PRIMARY KEY CLUSTERED ([ReportPopupID]),
	[ReportGroupColumnID] [int] NOT NULL,
	CONSTRAINT [ERS_ReportPopup.FK.ReportGroupColumnID] FOREIGN KEY([ReportGroupColumnID]) REFERENCES [dbo].[ERS_ReportGroupColumn] ([ReportGroupColumnID]),
	[ReportID] [varchar](32) NOT NULL,
	CONSTRAINT [ERS_ReportPopup.FK.ReportID] FOREIGN KEY([ReportID]) REFERENCES [dbo].[ERS_Report] ([ReportID]),
)
GO
CREATE TABLE [dbo].[ERS_ReportBoston1]
(
	[UserID] INT NOT NULL REFERENCES [dbo].[ERS_ReportFilter] (UserID) ON DELETE CASCADE,
	[Formulation] VARCHAR(255) NOT NULL,
	[Scale] INT DEFAULT 0,
	CONSTRAINT [ERS_ReportBoston1.PK.UserID_Formulation_Scale] PRIMARY KEY CLUSTERED ([UserID], [Formulation], [Scale]),
	[Right] INT DEFAULT 0,
	[RightP] Numeric(17,2) DEFAULT 0,
	[Transverse] INT DEFAULT 0,
	[TransverseP] NUMERIC(17,2) DEFAULT 0,
	[Left] INT DEFAULT 0,
	[LeftP] NUMERIC(17,2) DEFAULT 0,
)
Go
CREATE TABLE [dbo].[ERS_ReportBoston2]
(
	[UserID] INT NOT NULL REFERENCES [dbo].[ERS_ReportFilter] (UserID) ON DELETE CASCADE,
	[Formulation] VARCHAR(255) NOT NULL,
	[Score] INT DEFAULT 0,
	CONSTRAINT [ERS_ReportBoston2.PK.UserID_Formulation_Score] PRIMARY KEY CLUSTERED ([UserID],[Formulation],[Score]),
	[Frequency] INT DEFAULT 0,
	[Fx] INT DEFAULT 0,
)
Go
CREATE TABLE [dbo].[ERS_ReportBoston3]
(
	[UserID] INT NOT NULL REFERENCES [dbo].[ERS_ReportFilter] (UserID) ON DELETE CASCADE,
	[Formulation] VARCHAR(255) NOT NULL,
	CONSTRAINT [ERS_ReportBoston3.PK.UserID_Formulation] PRIMARY KEY CLUSTERED ([UserID],[Formulation]),
	[NoOfProcs] INT DEFAULT 0,
	[MeanScore] NUMERIC(17,2) DEFAULT 0,
)
Go

--------------------------- BEGIN FRAMEWORK
/* FW Part 1 */
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_DiagnosisTypes]')) Drop Table [dbo].[ERS_DiagnosisTypes]
Go
Create Table [dbo].[ERS_DiagnosisTypes] (
	DiagnosisId INT PRIMARY KEY CLUSTERED,
	DiagnosisMatrixID INT,
	NED_Diagnosis VARCHAR(128),
	Organ VARCHAR(128),
)
Go
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (0,0,'None')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (1,0,'Normal')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (2,0,'Other')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (3,58,'Anal fissure')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (4,54,'Angiodysplasia')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (5,-1,'Colitis - ischemic')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (6,-1,'Colitis - pseudomembranous')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (7,-1,'Colitis - unspecified')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (8,59,'Colorectal cancer')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (9,60,'Crohn''s - terminal ileum')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (10,-1,'Crohn''s colitis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (11,42,'Diverticulosis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (12,61,'Fistula')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (13,25,'Foreign body')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (14,46,'Haemorrhoids')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (15,63,'Lipoma')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (16,64,'Melanosis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (17,65,'Parasites')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (18,66,'Pneumatosis coli')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (19,39,'Polyp/s')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (20,67,'Polyposis syndrome')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (21,68,'Postoperative appearance')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (22,69,'Proctitis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (23,32,'Rectal ulcer')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (24,55,'Stricture - inflammatory')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (25,56,'Stricture - malignant')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (26,57,'Stricture - postoperative')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (27,-1,'Ulcerative colitis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (28,-1,'Anastomotic stricture')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (29,-1,'Biliary fistula/leak')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (30,-1,'Biliary occlusion')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (31,-1,'Biliary stent occlusion')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (32,-1,'Biliary stone(s)')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (33,-1,'Biliary stricture')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (34,-1,'Carolis disease')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (35,-1,'Cholangiocarcinoma')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (36,-1,'Choledochal cyst')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (37,-1,'Cystic duct stones')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (38,-1,'Duodenal diverticulum')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (39,-1,'Gallbladder stone(s)')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (40,-1,'Gallbladder tumor')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (41,-1,'Hemobilia')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (42,-1,'IPMT')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (43,-1,'Mirizzi syndrome')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (44,-1,'Pancreas annulare')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (45,-1,'Pancreas divisum')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (46,-1,'Pancreatic cyst')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (47,-1,'Pancreatic duct fistula/leak')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (48,-1,'Pancreatic duct injury')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (49,-1,'Pancreatic duct stricture')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (50,-1,'Pancreatic stent occlusion')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (51,-1,'Pancreatic stone')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (52,-1,'Pancreatic tumor')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (53,-1,'Pancreatitis - acute')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (54,-1,'Pancreatitis - chronic')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (55,-1,'Papillary stenosis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (56,-1,'Papillary tumor')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (57,-1,'Primary sclerosing cholangitis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (58,-1,'Suppurative cholangitis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (59,-1,'Achalasia')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (60,4,'Barrett''s oesophagus')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (61,-1,'Dieulafoy lesion')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (62,-1,'Duodenal polyp')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (63,6,'Duodenal tumour - benign')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (64,18,'Duodenal tumour - malignant')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (65,7,'Duodenal ulcer')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (66,-1,'Duodenitis - erosive')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (67,-1,'Duodenitis - non-erosive')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (68,0,'Extrinsic compression')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (69,0,'Gastric diverticulum')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (70,0,'Gastric fistula')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (71,-1,'Gastric foreign body')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (72,0,'Gastric polyp(s)')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (73,0,'Gastric postoperative appearance')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (74,0,'Gastric tumour - benign')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (75,0,'Gastric tumour - malignant')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (76,0,'Gastric tumour - submucosal')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (77,32,'Gastric ulcer')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (78,0,'Gastric varices')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (79,0,'Gastritis - erosive')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (80,0,'Gastritis - non-erosive')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (81,0,'Gastropathy-portal hypertensive')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (82,0,'GAVE')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (83,1,'Hiatus hernia')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (84,5,'Mallory-Weiss tear')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (85,8,'Oesophageal candidiasis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (86,0,'Oesophageal diverticulum')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (87,0,'Oesophageal fistula')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (88,-1,'Oesophageal foreign body')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (89,21,'Oesophageal polyp')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (90,2,'Oesophageal stricture - benign')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (91,0,'Oesophageal stricture - malignant')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (92,0,'Oesophageal tumour - benign')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (93,0,'Oesophageal tumour - malignant')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (94,0,'Oesophageal ulcer')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (95,0,'Oesophageal varices')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (96,0,'Oesophagitis - eosinophilic')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (97,17,'Oesophagitis - reflux')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (98,0,'Pharyngeal pouch')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (99,31,'Pyloric stenosis')
INSERT INTO ERS_DiagnosisTypes (DiagnosisId, DiagnosisMatrixID, NED_Diagnosis) Values (100,22,'Scar')
Go
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_Organs]')) Drop Table [dbo].[ERS_Organs]
Go
Create Table [dbo].[ERS_Organs] (
	RegionId INT PRIMARY KEY CLUSTERED, Organ VARCHAR(100)
)
Go
INSERT INTO ERS_Organs (RegionId,Organ)
Values
(  0,'None'),
(  1,'Oesophagus'),
(  2,'Oesophagus'),
(  3,'Oesophagus'),
(  4,'Oesophagus'),
(  5,'Oesophagus'),
(  6,'Oesophagus'),
(  7,'Oesophagus'),
(  8,'Oesophagus'),
(  9,'Oesophagus'),
( 10,'Stomach'),
( 11,'Stomach'),
( 12,'Stomach'),
( 13,'Stomach'),
( 14,'Stomach'),
( 15,'Stomach'),
( 16,'Stomach'),
( 17,'Stomach'),
( 18,'Stomach'),
( 19,'Stomach'),
( 20,'Stomach'),
( 21,'Stomach'),
( 22,'Stomach'),
( 23,'Stomach'),
( 24,'D2 - 2nd part of duodenum'),
( 25,'D2 - 2nd part of duodenum'),
( 26,'D2 - 2nd part of duodenum'),
( 27,'D2 - 2nd part of duodenum'),
( 28,'D2 - 2nd part of duodenum'),
( 29,'D2 - 2nd part of duodenum'),
( 30,'Duodenal bulb'),
( 31,'Duodenal bulb'),
( 32,'Duodenal bulb'),
( 33,'D2 - 2nd part of duodenum'),
( 34,'D2 - 2nd part of duodenum'),
( 35,'D2 - 2nd part of duodenum'),
( 36,'D2 - 2nd part of duodenum'),
( 37,'D2 - 2nd part of duodenum'),
( 38,'D2 - 2nd part of duodenum'),
( 39,'D2 - 2nd part of duodenum'),
( 40,'Terminal ileum'),
( 41,'Caecum'),
( 42,'Terminal ileum'),
( 43,'Terminal ileum'),
( 44,'Ascending Colon'),
( 45,'Ascending Colon'),
( 46,'Ascending Colon'),
( 47,'Hepatic flexure'),
( 48,'Transverse Colon'),
( 49,'Transverse Colon'),
( 50,'Transverse Colon'),
( 51,'Splenic flexure'),
( 52,'Descending Colon'),
( 53,'Descending Colon'),
( 54,'Descending Colon'),
( 55,'Sigmoid Colon'),
( 56,'Sigmoid Colon'),
( 57,'Sigmoid Colon'),
( 58,'Rectum'),
( 59,'Anus'),
( 60,'Terminal ileum'),
( 61,'Caecum'),
( 62,'Terminal ileum'),
( 63,'Terminal ileum'),
( 64,'Ascending Colon'),
( 65,'Ascending Colon'),
( 66,'Ascending Colon'),
( 67,'Hepatic flexure'),
( 68,'Transverse Colon'),
( 69,'Transverse Colon'),
( 70,'Transverse Colon'),
( 71,'Splenic flexure'),
( 72,'Descending Colon'),
( 73,'Descending Colon'),
( 74,'Descending Colon'),
( 75,'Sigmoid Colon'),
( 76,'Sigmoid Colon'),
( 77,'Sigmoid Colon'),
( 78,'Rectum'),
( 79,'Anus'),
( 80,'Terminal ileum'),
( 81,'Caecum'),
( 82,'Terminal ileum'),
( 83,'Terminal ileum'),
( 84,'Ascending Colon'),
( 85,'Ascending Colon'),
( 86,'Ascending Colon'),
( 87,'Hepatic flexure'),
( 88,'Transverse Colon'),
( 89,'Transverse Colon'),
( 90,'Transverse Colon'),
( 91,'Splenic flexure'),
( 92,'Descending Colon'),
( 93,'Descending Colon'),
( 94,'Descending Colon'),
( 95,'Sigmoid Colon'),
( 96,'Sigmoid Colon'),
( 97,'Sigmoid Colon'),
( 98,'Rectum'),
( 99,'Anus'),
(100,'None')
Go
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportTherapy]')) Drop Table [dbo].[ERS_ReportTherapy]
Go
Create Table [dbo].[ERS_ReportTherapy] (
	TherapyId INT, Therapy VARCHAR(100)
)
Go
Insert Into ERS_ReportTherapy (TherapyId, Therapy)
VALUES
(1,'Anastomosis'),
(2,'Other'),
(3,'Argon beam photocoagulation'),
(4,'Balloon dilation'),
(5,'Banding of haemorrhoid'),
(6,'Clip placement'),
(7,'Endoloop placement'),
(8,'Foreign body removal'),
(9,'Injection therapy'),
(10,'Marking / tattooing'),
(11,'Polyp - cold biopsy'),
(12,'Polyp - EMR'),
(13,'Polyp - ESD'),
(14,'Polyp - hot biopsy'),
(15,'Polyp - snare cold'),
(16,'Polyp - snare hot'),
(17,'Stent change'),
(18,'Stent placement'),
(19,'Stent removal'),
(20,'YAG laser'),
(21,'Balloon trawl'),
(22,'Bougie dilation'),
(23,'Brush cytology'),
(24,'Cannulation'),
(25,'Combined (rendezvous) proc'),
(26,'Diagnostic cholangiogram'),
(27,'Diagnostic pancreatogram'),
(28,'Endoscopic cyst puncture'),
(29,'Haemostasis'),
(30,'Manometry'),
(31,'Nasopancreatic / bilary drain'),
(32,'Sphincterotomy'),
(33,'Stent placement - CBD'),
(34,'Stent placement - pancreas'),
(35,'Stone extraction &gt;=10mm'),
(36,'Stone extraction &lt;10mm'),
(37,'Band ligation'),
(38,'Botox injection'),
(39,'EMR'),
(40,'ESD'),
(41,'Heater probe'),
(42,'Hot biopsy'),
(43,'PEG change'),
(44,'PEG placement'),
(45,'PEG removal'),
(46,'Polypectomy'),
(47,'Radio frequency ablation'),
(48,'Variceal sclerotherapy')
GO
/* FW Part 2 */

/* [dbo].[fw_Visualization] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Visualization]')) Drop View [dbo].[fw_Visualization]
GO

/* [dbo].[fw_UGI_Visualization] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Visualization]')) Drop View [dbo].[fw_UGI_Visualization]
GO

/* [dbo].[fw_ERS_Visualization] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Visualization]')) Drop View [dbo].[fw_ERS_Visualization]
GO


/* [dbo].[fw_ColonExtentOfIntubation] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ColonExtentOfIntubation]')) Drop View [dbo].[fw_ColonExtentOfIntubation]
GO

/* [dbo].[fw_Drugs] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Drugs]')) Drop View [dbo].[fw_Drugs]
GO

/* [dbo].[fw_Indications] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Indications]')) Drop View [dbo].[fw_Indications]
GO

/* [dbo].[fw_QA] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_QA]')) Drop View [dbo].[fw_QA]
GO

/* [dbo].[fw_ERS_QA] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_QA]')) Drop View [dbo].[fw_ERS_QA]
GO

/* [dbo].[fw_UGI_QA] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_QA]')) Drop View [dbo].[fw_UGI_QA]
GO

/* [dbo].[fw_IndicationsERCP] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_IndicationsERCP]')) Drop View [dbo].[fw_IndicationsERCP]
GO

/* [dbo].[fw_Instruments] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Instruments]')) Drop View [dbo].[fw_Instruments]
GO

/* [dbo].[fw_InstrumentTypes] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_InstrumentTypes]')) Drop View [dbo].[fw_InstrumentTypes]
GO

/* [dbo].[fw_Insertions] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Insertions]')) Drop View [dbo].[fw_Insertions]
GO

/* kfw_UGI_Visualization */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_UGI_Visualization') Drop Index kfw_UGI_Visualization On [dbo].[fw_UGI_Visualization]
GO

/* [dbo].[fw_UGI_Visualization] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Visualization]')) Drop View [dbo].[fw_UGI_Visualization]
GO

/* [dbo].[fw_Markings] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Markings]')) Drop View [dbo].[fw_Markings]
GO

/* [dbo].[fw_ERS_Markings] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Markings]')) Drop View [dbo].[fw_ERS_Markings]
GO

/* [dbo].[fw_UGI_Markings] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Markings]')) Drop View [dbo].[fw_UGI_Markings]
GO

/* [dbo].[fw_Consultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Consultants]')) Drop View [dbo].[fw_Consultants]
GO

/* [dbo].[fw_ERS_Consultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Consultants]')) Drop View [dbo].[fw_ERS_Consultants]
GO

/* [dbo].[fw_UGI_Consultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Consultants]')) Drop View [dbo].[fw_UGI_Consultants]
GO

/* [dbo].[fw_PathologyResults] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_PathologyResults]')) Drop View [dbo].[fw_PathologyResults]
GO

/* [dbo].[fw_Placements] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Placements]')) Drop View [dbo].[fw_Placements]
GO

/* [dbo].[fw_ERS_Placements] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Placements]')) Drop View [dbo].[fw_ERS_Placements]
GO

/* [dbo].[fw_UGI_Placements] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Placements]')) Drop View [dbo].[fw_UGI_Placements]
GO

/* [dbo].[fw_Premedication] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Premedication]')) Drop View [dbo].[fw_Premedication]
GO

/* [dbo].[fw_ERS_Premedication] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Premedication]')) Drop View [dbo].[fw_ERS_Premedication]
GO

/* [dbo].[fw_UGI_Premedication] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Premedication]')) Drop View [dbo].[fw_UGI_Premedication]
GO

/* [dbo].[fw_ProceduresConsultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ProceduresConsultants]')) Drop View [dbo].[fw_ProceduresConsultants]
GO

/* [dbo].[fw_ERS_ProceduresConsultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_ProceduresConsultants]')) Drop View [dbo].[fw_ERS_ProceduresConsultants]
GO

/* [dbo].[fw_UGI_ProceduresConsultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_ProceduresConsultants]')) Drop View [dbo].[fw_UGI_ProceduresConsultants]
GO

/* [dbo].[fw_Procedures] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Procedures]')) Drop View [dbo].[fw_Procedures]
GO

/* [dbo].[fw_ReportConsultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ReportConsultants]')) Drop View [dbo].[fw_ReportConsultants]
GO

/* [dbo].[fw_Sites] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Sites]')) Drop View [dbo].[fw_Sites]
GO

/* [dbo].[fw_ERS_Sites] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Sites]')) Drop View [dbo].[fw_ERS_Sites]
GO

/* [dbo].[fw_UGI_Sites] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Sites]')) Drop View [dbo].[fw_UGI_Sites]
GO

/* [dbo].[fw_ReportFilter] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ReportFilter]')) Drop View [dbo].[fw_ReportFilter]
GO

/* [dbo].[fw_Specimens] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Specimens]')) Drop View [dbo].[fw_Specimens]
GO

/* [dbo].[fw_ERS_Specimens] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Specimens]')) Drop View [dbo].[fw_ERS_Specimens]
GO

/* [dbo].[fw_UGI_Specimens] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Specimens]')) Drop View [dbo].[fw_UGI_Specimens]
GO

/* [dbo].[fw_Therapeutic] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Therapeutic]')) Drop View [dbo].[fw_Therapeutic]
GO

/* [dbo].[fw_ERS_Therapeutic] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Therapeutic]')) Drop View [dbo].[fw_ERS_Therapeutic]
GO

/* [dbo].[fw_UGI_Therapeutic] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Therapeutic]')) Drop View [dbo].[fw_UGI_Therapeutic]
GO

/* [dbo].[fw_BowelPreparationBoston] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_BowelPreparationBoston]')) Drop View [dbo].[fw_BowelPreparationBoston]
GO

/* [dbo].[fw_ERS_BowelPreparationBoston] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_BowelPreparationBoston]')) Drop View [dbo].[fw_ERS_BowelPreparationBoston]
GO

/* [dbo].[fw_UGI_BowelPreparationBoston] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_BowelPreparationBoston]')) Drop View [dbo].[fw_UGI_BowelPreparationBoston]
GO

/* [dbo].[fw_ProceduresInstruments] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ProceduresInstruments]')) Drop View [dbo].[fw_ProceduresInstruments]
GO

/* [dbo].[fw_ERS_ProceduresInstruments] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_ProceduresInstruments]')) Drop View [dbo].[fw_ERS_ProceduresInstruments]
GO

/* [dbo].[fw_UGI_ProceduresInstruments] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_ProceduresInstruments]')) Drop View [dbo].[fw_UGI_ProceduresInstruments]
GO

/* [dbo].[fw_RepeatOGD] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_RepeatOGD]')) Drop View [dbo].[fw_RepeatOGD]
GO

/* [dbo].[fw_ERS_RepeatOGD] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_RepeatOGD]')) Drop View [dbo].[fw_ERS_RepeatOGD]
GO

/* [dbo].[fw_UGI_RepeatOGD] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_RepeatOGD]')) Drop View [dbo].[fw_UGI_RepeatOGD]
GO

/* [dbo].[fw_BowelPreparation] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_BowelPreparation]')) Drop View [dbo].[fw_BowelPreparation]
GO

/* [dbo].[fw_ERS_BowelPreparation] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_BowelPreparation]')) Drop View [dbo].[fw_ERS_BowelPreparation]
GO

/* [dbo].[fw_UGI_BowelPreparation] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_BowelPreparation]')) Drop View [dbo].[fw_UGI_BowelPreparation]
GO

/* [dbo].[fw_PatientsSedationScore] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_PatientsSedationScore]')) Drop View [dbo].[fw_PatientsSedationScore]
GO

/* [dbo].[fw_NursesComfortScore] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_NursesComfortScore]')) Drop View [dbo].[fw_NursesComfortScore]
GO

/* [dbo].[fw_NurseAssPatSedationScore] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_NurseAssPatSedationScore]')) Drop View [dbo].[fw_NurseAssPatSedationScore]
GO

/* [dbo].[fw_ConsultantTypes] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ConsultantTypes]')) Drop View [dbo].[fw_ConsultantTypes]
GO

/* [dbo].[fw_Priority] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Priority]')) Drop View [dbo].[fw_Priority]
GO

/* [dbo].[fw_OperatingHospitals] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_OperatingHospitals]')) Drop View [dbo].[fw_OperatingHospitals]
GO

/* [dbo].[fw_TherapeuticERCP] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_TherapeuticERCP]')) Drop View [dbo].[fw_TherapeuticERCP]
GO

/* [dbo].[fw_FailuresERCP] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_FailuresERCP]')) Drop View [dbo].[fw_FailuresERCP]
GO

/* kfw_ProceduresTypes */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_ProceduresTypes') Drop Index kfw_ProceduresTypes On [dbo].[fw_ProceduresTypes]
GO

/* [dbo].[fw_ProceduresTypes] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ProceduresTypes]')) Drop View [dbo].[fw_ProceduresTypes]
GO

/* [dbo].[fw_PatientType] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_PatientType]')) Drop View [dbo].[fw_PatientType]
GO

/* [dbo].[fw_PatientStatus] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_PatientStatus]')) Drop View [dbo].[fw_PatientStatus]
GO

/* istatusfw_UGI_Episode */
If exists (SELECT * FROM sys.indexes WHERE name =N'istatusfw_UGI_Episode') Drop Index istatusfw_UGI_Episode On [dbo].[fw_UGI_Episode]
GO

/* iEpisodePatientfw_UGI_Episode */
If exists (SELECT * FROM sys.indexes WHERE name =N'iEpisodePatientfw_UGI_Episode') Drop Index iEpisodePatientfw_UGI_Episode On [dbo].[fw_UGI_Episode]
GO

/* iPatientfw_UGI_Episode */
If exists (SELECT * FROM sys.indexes WHERE name =N'iPatientfw_UGI_Episode') Drop Index iPatientfw_UGI_Episode On [dbo].[fw_UGI_Episode]
GO

/* iEpisodefw_UGI_Episode */
If exists (SELECT * FROM sys.indexes WHERE name =N'iEpisodefw_UGI_Episode') Drop Index iEpisodefw_UGI_Episode On [dbo].[fw_UGI_Episode]
GO

/* kfw_UGI_Episode */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[kfw_UGI_Episode]')) Drop Index kfw_UGI_Episode On [dbo].[fw_UGI_Episode]
GO

/* [dbo].[fw_UGI_Episode] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Episode]')) Drop View [dbo].[fw_UGI_Episode]
GO

/* [dbo].[fw_UGI_Procedures] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Procedures]')) Drop View [dbo].[fw_UGI_Procedures]
GO

/* [dbo].[fw_UGI_C_Procedures] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_C_Procedures]')) Drop View [dbo].[fw_UGI_C_Procedures]
GO

/* [dbo].[fw_UGI_E_Procedures] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_E_Procedures]')) Drop View [dbo].[fw_UGI_E_Procedures]
GO

/* [dbo].[fw_UGI_O_Procedures] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_O_Procedures]')) Drop View [dbo].[fw_UGI_O_Procedures]
GO

/* [dbo].[fw_ERS_Procedures] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Procedures]')) Drop View [dbo].[fw_ERS_Procedures]
GO

/* kfw_Patients_ComboId */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_Patients_ComboId') Drop Index kfw_Patients_ComboId On [dbo].[fw_Patients]
GO

/* kfw_Patients_CNN */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_Patients_CNN') Drop Index kfw_Patients_CNN On [dbo].[fw_Patients]
GO

/* kfw_Patients_PatientName */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_Patients_PatientName') Drop Index kfw_Patients_PatientName On [dbo].[fw_Patients]
GO

/* kfw_Patients */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Patients]')) Drop View [dbo].[fw_Patients]
GO

/* [dbo].[fw_Patients] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Patients]')) Drop View [dbo].[fw_Patients]
GO

/* [dbo].[fw_Apps] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Apps]')) Drop View [dbo].[fw_Apps]
GO

/* [dbo].[fw_Lesions] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Lesions]')) Drop View [dbo].[fw_Lesions]
GO

/* [dbo].[fw_UGI_Lesions] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Lesions]')) Drop View [dbo].[fw_UGI_Lesions]
GO

/* [dbo].[fw_ERS_Lesions] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Lesions]')) Drop View [dbo].[fw_ERS_Lesions]
GO

/* FW Part 3*/

/* [dbo].[fw_UGI_Lesions] */

Create View [dbo].[fw_UGI_Lesions]
WITH SCHEMABINDING
AS
SELECT SiteId, NoLesions
, RTRIM(SUBSTRING(Data,1,16)) AS LessionType
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
	'U.'+Convert(varchar(3),Case When CHARINDEX('1', SUBSTRING(E.[Status], 1, 10))='3' Then IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) Else CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) End)+'.'+Convert(Varchar(10),E.[Episode No])+'.'+Convert(Varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+'.'+convert(varchar(10),L.[Site No]) As SiteId
    ,Case When [Lesions none]=-1 Then 1 Else 0 End As [NoLesions]
	,Case When [Sessile]=-1 Then 'Sessile         '
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
	,Case When L.Predunculated=-1 Then 'Peduncular      '
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
	,Case When L.Submucosal=-1 Then 'Submucosal      ' 
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
	,Case When L.Villous=-1 Then 'Villous         ' 
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
	,Case When L.[Ulcerative]=-1 Then 'Ulcerative      ' 
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
	,Case When L.[Stricturing]=-1 Then 'Stricturing     ' 
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
	,Case When L.[Polypoidal]=-1 Then 'Polypoidal      ' 
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
	,Case When L.[Granuloma]=-1 Then 'Granuloma       ' 
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
	,Case When L.[Dysplastic]=-1 Then 'Dysplastic      ' 
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
	,Case When L.[Pneumatosis Coli]=-1 Then 'Pneumatosis Coli' 
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
GO

/* [dbo].[fw_ERS_Lesions] */

Create View [dbo].[fw_ERS_Lesions]
WITH SCHEMABINDING
AS
SELECT SiteId, NoLesions
, RTRIM(SUBSTRING(Data,1,16)) AS LessionType
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

/* [dbo].[fw_Lesions] */

Create View [dbo].[fw_Lesions] As SELECT * FROM fw_UGI_Lesions UNION ALL SELECT * FROM fw_ERS_Lesions 

GO

/* [dbo].[fw_Apps] */

Create View [dbo].[fw_Apps] As Select 'U' As AppId, 'UGI' As AppName Union All Select 'E' As AppId, 'ERS' As AppName 

GO

/* [dbo].[fw_Patients] */

Create View [dbo].[fw_Patients] WITH SCHEMABINDING As Select P.[Patient No] As PatientId ,P.[Case note no] As CNN , IsNull(P.Title,'')+Case When P.Title Is Null Then '' Else ' ' End +IsNull(P.Forename,'')+Case When P.Forename Is Null Then '' Else ' '+IsNull(P.Surname,'') End As PatientName , IsNull(P.Forename,'') As Forename , IsNull(P.Surname,'') As Surname , Convert(Date,P.[Date of birth]) As DOB , P.[Date of death] As DOD , P.[NHS No] As NHSNo , IsNull(P.Gender,'?') As Gender , IsNull(P.[Post code],'') As PostCode , P.[GP Name] As GPName , P.[Phone No] As PhoneNo , P.[Combo ID] As ComboId From [dbo].[Patient] P 

GO

/* kfw_Patients */

CREATE UNIQUE CLUSTERED INDEX kfw_Patients ON fw_Patients (PatientId)

GO

/* kfw_Patients_PatientName */

CREATE INDEX kfw_Patients_PatientName ON fw_Patients (PatientName)

GO

/* kfw_Patients_CNN */

CREATE INDEX kfw_Patients_CNN ON fw_Patients (CNN)

GO

/* kfw_Patients_ComboId */

CREATE INDEX kfw_Patients_ComboId ON fw_Patients (ComboId)

GO

/* [dbo].[fw_ERS_Procedures] */

Create View [dbo].[fw_ERS_Procedures] As Select 'E.'+Convert(Varchar(10),PR.ProcedureId) As ProcedureId , PR.ProcedureType As ProcedureTypeId ,'E' As AppId , Convert(Date,CreatedOn) As CreatedOn , PR.PatientId As PatientId , Convert(int,PR.CreatedOn-CONVERT(DATETIME,P.DOB))/365 As Age , IsNull(PR.OperatingHospitalID,0) As OperatingHospitalId , IsNull(PP_Priority,'Unspecified') As PP_Priority , Case PP_PatStatus When 'Outpatient/NHS' Then 2 When 'Inpatient/NHS' Then 1 Else 0 End As PatientStatusId , Case When Replace(Replace(IsNull(PP_PatStatus,''),'Outpatient/',''),'Inpatient/','')='NHS' Then 1 Else 2 End As PatientTypeId , PR.PP_Indic , PR.PP_Therapies , PR.DNA From [dbo].[ERS_Procedures] PR, [dbo].[fw_Patients] P Where PR.PatientId=P.PatientId 

GO

/* [dbo].[fw_UGI_O_Procedures] */

Create View [dbo].[fw_UGI_O_Procedures] As Select 'U.1.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 1 As ProcedureTypeId , 'U' As AppId , Convert(Date,E.[Episode date]) As CreatedOn , Convert(INT,SubString(E.[Patient No],7,6)) As PatientId , E.[Age at procedure] As Age , IsNull(PR.[Operating Hospital ID],0) As OperatingHospitalId , IsNull(PP_Priority,'Unspecified') As PP_Priority , Case PP_PatStatus When 'Outpatient/NHS' Then 2 When 'Inpatient/NHS' Then 1 Else 0 End As PatientStatusId , Case When Replace(Replace(IsNull(PP_PatStatus,''),'Outpatient/',''),'Inpatient/','')='NHS' Then 1 Else 2 End As PatientTypeId , PR.PP_Indic , PR.PP_Therapies , PR.DNA From [dbo].[Episode] E LEFT OUTER JOIN [dbo].[Upper GI Procedure] PR ON E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No] Where SubString(E.[Status],1,1)=1 Union All Select 'U.6.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 6 As ProcedureTypeId , 'U' As AppId , Convert(Date,E.[Episode date]) As CreatedOn , Convert(INT,SubString(E.[Patient No],7,6)) As PatientId , E.[Age at procedure] As Age , IsNull(PR.[Operating Hospital ID],0) As OperatingHospitalId , IsNull(PP_Priority,'Unspecified') As PP_Priority , Case PP_PatStatus When 'Outpatient/NHS' Then 2 When 'Inpatient/NHS' Then 1 Else 0 End As PatientStatusId , Case When Replace(Replace(IsNull(PP_PatStatus,''),'Outpatient/',''),'Inpatient/','')='NHS' Then 1 Else 2 End As PatientTypeId , PR.PP_Indic , PR.PP_Therapies , PR.DNA From [dbo].[Episode] E LEFT OUTER JOIN [dbo].[Upper GI Procedure] PR ON E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No] Where SubString(E.[Status],5,1)=1 

GO

/* [dbo].[fw_UGI_E_Procedures] */

Create View [dbo].[fw_UGI_E_Procedures] As Select 'U.2.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 2 As ProcedureTypeId , 'U' As AppId , Convert(Date,E.[Episode date]) As CreatedOn , Convert(INT,SubString(E.[Patient No],7,6)) As PatientId , E.[Age at procedure] As Age , IsNull(PR.[Operating Hospital ID],0) As OperatingHospitalId , IsNull(PP_Priority,'Unspecified') As PP_Priority , Case PP_PatStatus When 'Outpatient/NHS' Then 2 When 'Inpatient/NHS' Then 1 Else 0 End As PatientStatusId , Case When Replace(Replace(IsNull(PP_PatStatus,''),'Outpatient/',''),'Inpatient/','')='NHS' Then 1 Else 2 End As PatientTypeId , PR.PP_Indic , PR.PP_Therapies , PR.DNA From [dbo].[Episode] E LEFT OUTER JOIN [dbo].[ERCP Procedure] PR ON E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No] Where SubString(E.[Status],2,1)=1 Union All Select 'U.7.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 7 As ProcedureTypeId , 'U' As AppId , Convert(Date,E.[Episode date]) As CreatedOn , Convert(INT,SubString(E.[Patient No],7,6)) As PatientId , E.[Age at procedure] As Age , IsNull(PR.[Operating Hospital ID],0) As OperatingHospitalId , IsNull(PP_Priority,'Unspecified') As PP_Priority , Case PP_PatStatus When 'Outpatient/NHS' Then 2 When 'Inpatient/NHS' Then 1 Else 0 End As PatientStatusId , Case When Replace(Replace(IsNull(PP_PatStatus,''),'Outpatient/',''),'Inpatient/','')='NHS' Then 1 Else 2 End As PatientTypeId , PR.PP_Indic , PR.PP_Therapies , PR.DNA From [dbo].[Episode] E LEFT OUTER JOIN [dbo].[ERCP Procedure] PR ON E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No] Where SubString(E.[Status],6,1)=1 

GO

/* [dbo].[fw_UGI_C_Procedures] */

Create View [dbo].[fw_UGI_C_Procedures] As Select 'U.'+Convert(varchar(1),3+IsNull((Select Top 1 [Procedure type] From [dbo].[Colon procedure] CP Where CP.[Episode No]=E.[Episode No] And [Procedure type]<>2),0))+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 3+IsNull((Select Top 1 [Procedure type] From [dbo].[Colon procedure] CP Where CP.[Episode No]=E.[Episode No] And [Procedure type]<>2),0) As ProcedureTypeId , 'U' As AppId , Convert(Date,E.[Episode date]) As CreatedOn , Convert(INT,SubString(E.[Patient No],7,6)) As PatientId , E.[Age at procedure] As Age , IsNull(PR.[Operating Hospital ID],0) As OperatingHospitalId , IsNull(PP_Priority,'Unspecified') As PP_Priority , Case PP_PatStatus When 'Outpatient/NHS' Then 2 When 'Inpatient/NHS' Then 1 Else 0 End As PatientStatusId , Case When Replace(Replace(IsNull(PP_PatStatus,''),'Outpatient/',''),'Inpatient/','')='NHS' Then 1 Else 2 End As PatientTypeId , PR.PP_Indic , PR.PP_Therapies , PR.DNA From [dbo].[Episode] E LEFT OUTER JOIN [dbo].[Colon Procedure] PR ON E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No] Where SubString(E.[Status],3,1)=1 Union All Select 'U.5.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 5 As ProcedureTypeId , 'U' As AppId , Convert(Date,E.[Episode date]) As CreatedOn , Convert(INT,SubString(E.[Patient No],7,6)) As PatientId , E.[Age at procedure] As Age , IsNull(PR.[Operating Hospital ID],0) As OperatingHospitalId , IsNull(PP_Priority,'Unspecified') As PP_Priority , Case PP_PatStatus When 'Outpatient/NHS' Then 2 When 'Inpatient/NHS' Then 1 Else 0 End As PatientStatusId , Case When Replace(Replace(IsNull(PP_PatStatus,''),'Outpatient/',''),'Inpatient/','')='NHS' Then 1 Else 2 End As PatientTypeId , PR.PP_Indic , PR.PP_Therapies , PR.DNA From [dbo].[Episode] E LEFT OUTER JOIN [dbo].[Colon Procedure] PR ON E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No] Where SubString(E.[Status],4,1)=1 Union All Select 'U.6.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 6 As ProcedureTypeId , 'U' As AppId , Convert(Date,E.[Episode date]) As CreatedOn , Convert(INT,SubString(E.[Patient No],7,6)) As PatientId , E.[Age at procedure] As Age , IsNull(PR.[Operating Hospital ID],0) As OperatingHospitalId , IsNull(PP_Priority,'Unspecified') As PP_Priority , Case PP_PatStatus When 'Outpatient/NHS' Then 2 When 'Inpatient/NHS' Then 1 Else 0 End As PatientStatusId , Case When Replace(Replace(IsNull(PP_PatStatus,''),'Outpatient/',''),'Inpatient/','')='NHS' Then 1 Else 2 End As PatientTypeId , PR.PP_Indic , PR.PP_Therapies , PR.DNA From [dbo].[Episode] E LEFT OUTER JOIN [dbo].[Upper GI Procedure] PR ON E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No] Where SubString(E.[Status],5,1)=1 

GO

/* [dbo].[fw_UGI_Procedures] */

Create View [dbo].[fw_UGI_Procedures] As Select * From [dbo].[fw_UGI_E_Procedures] Union All Select * From [dbo].[fw_UGI_C_Procedures] Union All Select * From [dbo].[fw_UGI_O_Procedures] 

GO

/* [dbo].[fw_UGI_Episode] ojo*/

Create View [dbo].[fw_UGI_Episode] WITH SCHEMABINDING As Select [Patient No] ,[Episode date] ,[Episode No] ,[Imported] ,[Status] ,[Combined procedure] ,[Procedure catagory] ,[On waiting list] ,[Age at procedure] ,[Open access proc] ,[Emergency proc type] ,[Status2] ,[Procedure time] ,[Procedure start time] ,[DNA procedure] ,[DNA type] ,[DNA attended but reason] ,[DNA unfit/unsuitable reason text] ,[DNA unfit/unsuitable reason ID] ,[Procedure ID] From [dbo].[Episode] 

GO

/* kfw_UGI_Episode */

CREATE UNIQUE CLUSTERED INDEX kfw_UGI_Episode ON fw_UGI_Episode ([Episode No],[Patient No],[Procedure time])

GO

/* iEpisodefw_UGI_Episode */

CREATE INDEX iEpisodefw_UGI_Episode ON fw_UGI_Episode ([Episode No])

GO

/* iPatientfw_UGI_Episode */

CREATE INDEX iPatientfw_UGI_Episode ON fw_UGI_Episode ([Patient No])

GO

/* iEpisodePatientfw_UGI_Episode */

CREATE INDEX iEpisodePatientfw_UGI_Episode ON fw_UGI_Episode ([Episode No],[Patient No])

GO

/* istatusfw_UGI_Episode */

CREATE INDEX istatusfw_UGI_Episode ON fw_UGI_Episode ([status])

GO

/* [dbo].[fw_PatientStatus] */

Create View [dbo].[fw_PatientStatus] As Select ListItemNo As PatientStatusId, ListItemText As PatientStatus From ERS_Lists Where ListDescription='Patient Status' Union Select 0 As PatientStatusId, 'Unknow' As PatientStatus 

GO

/* [dbo].[fw_PatientType] */

Create View [dbo].[fw_PatientType] As Select ListItemNo As PatientTypeId, ListItemText As PatientType From ERS_Lists Where ListDescription='Patient Type' Union Select 0 As PatientTypeId, 'Unknow' As PatientType 

GO

/* [dbo].[fw_ProceduresTypes] */

Create View [dbo].[fw_ProceduresTypes] WITH SCHEMABINDING As Select ProcedureTypeId, ProcedureType From [dbo].[ERS_ProcedureTypes] 

GO

/* kfw_ProceduresTypes */

CREATE UNIQUE CLUSTERED INDEX kfw_ProceduresTypes On [dbo].[fw_ProceduresTypes] (ProcedureTypeId)

GO

/* [dbo].[fw_FailuresERCP] */

Create View [dbo].[fw_FailuresERCP] As Select 'U.2.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+'.'+Convert(VARCHAR(10),T.[Site No]) As SiteId ,Convert(bit,Case [Procs Papill/sphincterotomy] When -1 Then Case [Papillotomy] When -1 Then 'FALSE' Else Case [Pan Orifice Sphincterotomy] When -1 Then 'FALSE' Else 'TRUE' End End Else 'FALSE' End) | Convert(bit,Case [Procs Stent removal] When -1 Then Case [Stent Removal] When -1 Then 'FALSE' Else 'TRUE' End Else 'FALSE' End) | Convert(bit,Case [Procs Stent insertion] When -1 Then Case [Stent Insertion] When -1 Then Case IsNull([Correct stent placement],1) When 1 Then 'FALSE' Else 'TRUE' End Else 'TRUE' End Else 'FALSE' End) | Convert(bit,Case [Procs stent replacement] When -1 Then Case [Stent insertion] When -1 Then Case [Correct Stent placement] When 1 Then 'FALSE' Else 'TRUE' End Else 'FALSE' End Else 'FALSE' End) | Convert(bit,Case [Procs naso drains] When -1 Then Case [Nasopancreatic Drain] When -1 Then 'FALSE' Else 'TRUE' End Else 'FALSE' End) | Convert(bit,Case [Procs cyst puncture] When -1 Then Case [Endoscopic Cyst Puncture] When -1 Then 'FALSE' Else 'TRUE' End Else 'FALSE' End) | Convert(bit,Case [Procs rendezvous] When -1 Then Case [Rendezvous procedure] When -1 Then 'FALSE' Else 'TRUE' End Else 'FALSE' End) | Convert(bit,Case [Procs stricture dilatation] When -1 Then Case [Correct stent placement] When 2 Then 'TRUE' Else 'FALSE' End Else 'FALSE' End) | Convert(bit,Case [Procs stone removal] When -1 Then Case [Stone removal] When -1 Then Case [Extraction outcome] When 1 Then 'FALSE' When 2 Then 'FALSE' When 3 Then 'TRUE' When 4 Then 'TRUE' Else Case [Balloon Trawl] When -1 Then 'FALSE' Else Case [Balloon Dilation] When -1 Then 'FALSE' Else 'TRUE' End End End Else 'FALSE' End Else 'FALSE' End) As [Fails], Case IsNull(I.[Image obstruction CBD],0) When -1 Then Case IsNull([Stent decompressed],0) When 1 Then 'TRUE' Else 'FALSE' End Else Case IsNull(I.[Clin obstruction cbd],0) When -1 Then 'TRUE' Else 'FALSE' End End As [DecompSuccess], Case IsNull(I.[Image obstruction CBD],0) When -1 Then Case IsNull([Stent decompressed],0) When 2 Then 'TRUE' Else 'FALSE' End Else Case IsNull(I.[Clin obstruction cbd],0) When -1 Then 'TRUE' Else 'FALSE' End End As [DecompUnsuccess], Case IsNull(I.[Image obstruction CBD],0) When -1 Then Case IsNull([Stent decompressed],0) When 1 Then 'FALSE' When 2 Then 'FALSE' Else 'FALSE' End Else Case IsNull(I.[Clin obstruction cbd],0) When -1 Then 'TRUE' Else 'FALSE' End End As [DecompUnknow], Case IsNull(I.[Image obstruction CBD],0) When -1 Then 'TRUE' Else 'FALSE' End As [Decomp], Case [Procs stricture dilatation] When -1 Then 1 Else 0 End As [DecompressionDuctsProcedures], Convert(bit,Case [Procs stricture dilatation] When -1 Then Case [Correct stent placement] When 2 Then 'TRUE' Else 'FALSE' End Else 'FALSE' End) As [StrictureDilatationFails] From [dbo].[ERCP Procedure] PR , [dbo].[Patient] P , [dbo].[Episode] E , [dbo].[ERCP Indications] I , [dbo].[ERCP Therapeutic] T Where P.[Patient No]=convert(int,SubString(PR.[Patient No],7,6)) And E.[Patient No]=PR.[Patient No] And E.[Episode No]=PR.[Episode No] And E.[Patient No]=I.[Patient No] And E.[Episode No]=I.[Episode No] And E.[Patient No]=T.[Patient No] And E.[Episode No]=T.[Episode No] 

GO

/* [dbo].[fw_TherapeuticERCP] ojo1 */

Create View [dbo].[fw_IndicationsERCP] As
Select
	'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId 
	, Replace(Replace(Case When I.[Image normal]=-1 Then '' Else 'Imaging revealed,' 
		+Case When I.[Image chronic pancreatitis]=-1 Then ', chronic pancreatitis' Else '' End
		+Case When I.[Image pancreatic mass]=-1 Then ', pancreatic mass' Else '' End
		+Case When I.[Image hepatic mass]=-1 Then ', hepatic mass' Else '' End
		+Case When I.[Image acute pancreatitis]=-1 Then ', acute pancreatititis' Else '' End
		+Case When I.[Image dilated pancreatic duct]=-1 Then ', dilated pancreatic duct' Else '' End
		+Case When I.[Image dilated bile ducts]=-1 Then ', dilated bile ducts' Else '' End
		+Case When I.[Image stones]=-1 Then ', stones' Else '' End
		+Case When I.[Image dilated extrahepatic ducts]=-1 Then ', dilated extrahepatic ducts' Else '' End
		+Case When I.[Image dilated intrahepatic ducts]=-1 Then ', dilated intrahepatic ducts' Else '' End
		+Case When I.[Image gall stones]=-1 Then ', gall stones' Else '' End
		+Case When I.[Image biliary leak]=-1 Then ', biliary leak' Else '' End
		+Case When I.[Image fluid collection]=-1 Then ', fluid collection' Else '' End
		+Case When I.[Image obstruction CBD]=-1 Then ', obstructed CBD/CHD' Else '' End
		+Case When IsNull(I.[Image other text],'')='' Then '' Else +', '+IsNull(I.[Image other text],'') End
		End,',,',''),'Image revealed,','') As [Image]
		,Replace(Replace('@,'
      +Case When I.[Clin abdominal pain]=-1 Then ', abdominal pain' Else '' End
      +Case When I.[Clin abnormal enzymes]=-1 Then ', abnormal enzimes' Else '' End
      +Case When I.[Clin acute pancreatitis]=-1 Then ', acute pancreatitis' Else '' End
      +Case When I.[Clin cholangitis]=-1 Then ', cholangitis' Else '' End
      +Case When I.[Clin chronic pancreatitis]=-1 Then ', chronic pancreatitis' Else '' End
      +Case When I.[Clin jaundice]=-1 Then ', jaundice' Else '' End
      +Case When I.[Clin open access]=-1 Then ', open access' Else '' End
	  +Case When I.[Clin obstruction CBD]=-1 Then ', obstruction CDB' Else '' End
      +Case When I.[Clin pre-laparoscopic cholecystectomy]=-1 Then ', pre-laparoscopic cholecystectomy' Else '' End
      +Case When I.[Clin recurrent pancreatitis]=-1 Then ', recurrent pancreatitis' Else '' End
      +Case When I.[Clin sphincter of Oddi dysfunction]=-1 Then ', sphincter of Oddi dysfunction' Else '' End
      +Case When I.[Clin stent occlusion]=-1 Then ', stent occlusion' Else '' End
      +Case When I.[Clin papillary stenosis]=-1 Then ', papillary stenosis' Else '' End
      +Case When I.[Clin biliary leak]=-1 Then ', biliary leak' Else '' End
      +Case When IsNull([Clin other text],'')<>'' Then ', '+[Clin other text] Else '' End,'@,, ',''),'@,','')
	  As Indications
	  , Case When I.[Clin obstruction CBD]=-1 Then 1 Else 0 End As ClinObstructionCBD
	  , Case When I.[Image obstruction CBD]=-1 Then 1 Else 0 End As ImageObstructionCBD
	  ,Replace(Replace('@,'
      +Case When I.[Procs papill/sphincterotomy]=-1 Then ', papill/sphincterotomy' Else '' End
      +Case When I.[Procs stent insertion]=-1 Then ', stent insertion' Else '' End
      +Case When I.[Procs stent replacement]=-1 Then ', stent replacement' Else '' End
      +Case When I.[Procs stone removal]=-1 Then ', stone removal' Else '' End
      +Case When I.[Procs naso drains]=-1 Then ', naso drains' Else '' End
      +Case When I.[Procs cyst puncture]=-1 Then ', cyst puncture' Else '' End
      +Case When I.[Procs rendezvous]=-1 Then ', rendezvous' Else '' End
      +Case When I.[Procs stricture dilatation]=-1 Then ', stricture dilatation' Else '' End
      +Case When I.[Procs manometry]=-1 Then ', manometry' Else '' End
      +Case When I.[Procs cannulate and opacify]=-1 Then ', cannulate and opacify' Else '' End
      +Case When I.[Procs stent removal]=-1 Then ', stent removal' Else '' End
	  +Case When I.[Procs other]=-1 Then ', other' Else '' End
	  ,'@,, ',''),'@,','')
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
Go

/* [dbo].[fw_TherapeuticERCP] */

Create View [dbo].[fw_TherapeuticERCP] As Select 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+'.'+CONVERT(varchar(10),T.[Site No]) As SiteId ,S.Region ,Case When IsNull(T.[Stricture Decompressed],0)=1 Or IsNull(T.[Stent Decompressed],0)=1 Or IsNull(T.[Balloon Decompressed],0)=1 Or IsNull(T.[Stone decompressed],0)=1 Then 'V' Else Case When IsNull(T.[Stricture Decompressed],0)=2 Or IsNull(T.[Stent Decompressed],0)=2 Or IsNull(T.[Balloon Decompressed],0)=2 Or IsNull(T.[Stone decompressed],0)=2 Then 'X' Else '?' End End As Result ,(Select Count(*) From fw_IndicationsERCP Where ClinObstructionCBD=1 And ProcedureId='U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))) As ObstructedCBD ,Case When IsNull(T.[Stricture Decompressed],0)=1 Or IsNull(T.[Stent Decompressed],0)=1 Or IsNull(T.[Balloon Decompressed],0)=1 Or IsNull(T.[Stone decompressed],0)=1 Then 1 Else 0 End As Decompressed ,Case When IsNull(T.[Stricture Decompressed],0)=2 Or IsNull(T.[Stent Decompressed],0)=2 Or IsNull(T.[Balloon Decompressed],0)=2 Or IsNull(T.[Stone decompressed],0)=2 Then 1 Else 0 End As Failed ,Case When (IsNull(T.[Stricture Decompressed],0)+IsNull(T.[Stent Decompressed],0)+IsNull(T.[Balloon Decompressed],0)+IsNull(T.[Stone decompressed],0)>4 And IsNull(T.[Stricture Decompressed],0)+IsNull(T.[Stent Decompressed],0)+IsNull(T.[Balloon Decompressed],0)+IsNull(T.[Stone decompressed],0)<8) Then 1 Else 0 End As Unknow ,Case When T.[Therapeutic none]=-1 Then '' Else Case When T.[Stone removal]=-1 Then 'Stone removal' Else '' End End As StoneRemoval ,Case When T.[Therapeutic none]=-1 Then '' Else Case When T.[Stricture dilatation]=-1 Then 'Stricture dilatation ' +Case When IsNull(T.[Dilated to],'')<>'' Then Convert(varchar(10), T.[Dilated to])+Case T.[Dilatation units] When 1 Then ' mm' When 2 then ' Fr' Else '' End Else '' End Else '' End End As StrictureDilatation ,Case When T.[Therapeutic none]=-1 Then '' Else Case When T.[Endoscopic cyst puncture]=-1 Then 'Endoscopic cyst puncture' +Case T.[Cyst puncture via] When 1 Then ' using papilla' When 2 Then ' using medial wall of duodenum (cyst duodenostomy)' When 3 Then ' using stomach (cyst gastrostomy)' Else '' End Else '' End End As EndoscopicCystPuncture ,Case When T.[Therapeutic none]=-1 Then '' Else Case When T.[Nasopancreatic drain]=-1 Then 'Nasopancreatic drain' Else '' End End As NasopancreaticDrain ,Case When T.[Therapeutic none]=-1 Then '' Else Case When T.[Stent insertion]=-1 Then 'Stent insertion' Else Case When IsNull(T.[Stent qty],0)<>0 Then Convert(varchar(3),T.[Stent qty])+' stent(s) inserted length '+Convert(varchar(10),T.[Stent insertion length])+' Ø '+Convert(varchar(10),T.[Stent diameter])+' '+Case T.[Stent diameter units] When 1 Then 'cm' When 0 Then 'fr' Else '' End Else 'Stent insertion' End+Case When T.[Radioactive wire placed]=-1 Then ' (Radioactive wire placed)' Else '' End End End As StentInsertion ,Case When T.[Therapeutic none]=-1 Then '' Else Case When T.[Stent removal]=-1 Then 'Stent removal' Else '' End End As StentRemoval From [ERCP Therapeutic] T, Episode E, [ERCP Sites] S Where T.[Episode No]=E.[Episode No] And T.[Patient No]=E.[Patient No] And T.[Episode No]=S.[Episode No] And T.[Patient No]=S.[Patient No] And T.[Site No]=S.[Site No] 

GO

/* [dbo].[fw_OperatingHospitals] */

Create View [dbo].[fw_OperatingHospitals] As Select OperatingHospitalId, HospitalName From ERS_OperatingHospitals Union All Select OperatingHospitalId=0, HospitalName='*** Hospital not defined ***' 

GO

/* [dbo].[fw_Priority] */

Create View [dbo].[fw_Priority] As Select 0 As PriorityId, '(none)' As [Priority] Union All Select 1 As PriorityId, 'Efective' As [Priority] Union All Select 2 As PriorityId, 'Open Access (GP referrals)' As [Priority] Union All Select 3 As PriorityId, 'Schedulled (surveillance/repeats)' As [Priority] Union All Select 4 As PriorityId, 'Emergency (unespecified)' As [Priority] Union All Select 5 As PriorityId, 'Emergency (in hrs)' As [Priority] Union All Select 6 As PriorityId, 'Emergency (out of hours)' As [Priority] Union All Select 7 As PriorityId, 'Urgent' As [Priority] Union All Select 8 As PriorityId, 'Unespecified' As [Priority] Union All Select 9 As PriorityId, '' As [Priority] 

GO

/* [dbo].[fw_ConsultantTypes] */

Create View [dbo].[fw_ConsultantTypes] As Select ConsultantTypeId=1, ConsultantType='Endoscopist 1' Union All Select ConsultantTypeId=2, ConsultantType='Endoscopist 2' Union All Select ConsultantTypeId=3, ConsultantType='Assistant' Union All Select ConsultantTypeId=4, ConsultantType='List Consultant' Union All Select ConsultantTypeId=5, ConsultantType='Nurse 1' Union All Select ConsultantTypeId=6, ConsultantType='Nurse 2' Union All Select ConsultantTypeId=7, ConsultantType='Nurse 3' 

GO

/* [dbo].[fw_NurseAssPatSedationScore] */

Create View [dbo].[fw_NurseAssPatSedationScore] As Select NurseAssPatSedationScore=0, NurseAssPatSedation='Not completed' Union All Select NurseAssPatSedationScore=1, NurseAssPatSedation='Not recorded' Union All Select NurseAssPatSedationScore=2, NurseAssPatSedation='Awake' Union All Select NurseAssPatSedationScore=3, NurseAssPatSedation='Drowsy' Union All Select NurseAssPatSedationScore=4, NurseAssPatSedation='Asleep but responding to name' Union All Select NurseAssPatSedationScore=5, NurseAssPatSedation='Asleep but responding to touch' Union All Select NurseAssPatSedationScore=6, NurseAssPatSedation='Asleep but unresponsive' 

GO

/* [dbo].[fw_NursesComfortScore] */

Create View [dbo].[fw_NursesComfortScore] As Select NursesAssPatComfortScore=0, NursesAssPatComfort='Not completed' Union All Select NursesAssPatComfortScore=1, NursesAssPatComfort='Not recorded' Union All Select NursesAssPatComfortScore=2, NursesAssPatComfort='None-resting comfortably throughout' Union All Select NursesAssPatComfortScore=3, NursesAssPatComfort='One or two episodes of mild discomfort, well tolerated' Union All Select NursesAssPatComfortScore=4, NursesAssPatComfort='Two episodes of discomfort, adequately tolerated' Union All Select NursesAssPatComfortScore=5, NursesAssPatComfort='Significant discomfort, experienced several times during procedure' Union All Select NursesAssPatComfortScore=6, NursesAssPatComfort='Extreme discomfort frequently during test' 

GO

/* [dbo].[fw_PatientsSedationScore] */

Create View [dbo].[fw_PatientsSedationScore] As Select PatientsSedationScore=0, PatAssComfort='Not completed' Union All Select PatientsSedationScore=1, PatAssComfort='Not recorded' Union All Select PatientsSedationScore=2, PatAssComfort='No' Union All Select PatientsSedationScore=3, PatAssComfort='Minimal' Union All Select PatientsSedationScore=4, PatAssComfort='Mild' Union All Select PatientsSedationScore=5, PatAssComfort='Moderate' Union All Select PatientsSedationScore=6, PatAssComfort='Severe' 

GO

/* [dbo].[fw_UGI_BowelPreparation] */

Create View [dbo].[fw_UGI_BowelPreparation] As Select 'U.'+Convert(varchar(1),3+IsNull((Select Top 1 [Procedure type] From [Colon procedure] CP Where CP.[Episode No]=E.[Episode No] And [Procedure type]<>2),0))+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(INT,SubString(E.[Patient No],7,6))) As ProcedureId ,Convert(BIT,Case When BBPScore Is Null Then 0 Else 1 End) As BowelPrepSettings, Convert(BIT,Case IsNull(I.[Bowel preparation],0) When 0 Then 1 Else 0 End) As OnNoBowelPrep, L.[List item text] As Formulation, IsNull(I.[Bowel preparation],0) As OnFormulation, IsNull(I.BBPSRight,0) As OnRight, IsNull(I.BBPSTransverse,0) As OnTransverse, IsNull(I.BBPSLeft,0) As OnLeft, IsNull(I.BBPScore,0) As OnTotalScore, Case IsNull(I.[Bowel preparation],0) When 0 Then 1 Else 0 End As OffNoBowelPrep, IsNull(I.[Bowel preparation],0) As OffFormulation, Case IsNull(I.Quality,0) When 1 Then 1 Else 0 End As OffQualityGood, Case IsNull(I.Quality,0) When 2 Then 1 Else 0 End As OffQualitySatisfactory, Case IsNull(I.Quality,0) When 3 Then 1 Else 0 End As OffQualityPoor From dbo.[Colon Indications] I , dbo.Episode E , dbo.Lists L Where I.Quality Is Not Null And I.[Episode No]=E.[Episode No] And I.[Patient No]=E.[Patient No] And IsNull(I.[Bowel preparation],0)=L.[List item no] And L.[List description]='Preparation' And UPPER(L.[List item text]) <> '(NONE SELECTED)' 

GO

/* [dbo].[fw_ERS_BowelPreparation] */

Create View [dbo].[fw_ERS_BowelPreparation] As Select 'E.'+Convert(varchar(10),BP.ProcedureID) As ProcedureId , BP.BowelPrepSettings , BP.OnNoBowelPrep , L.ListItemText As Formulation , BP.OnFormulation , BP.OnRight, BP.OnTransverse, BP.OnLeft, OnTotalScore, BP.OffNoBowelPrep, BP.OffFormulation, BP.OffQualityGood, BP.OffQualitySatisfactory, BP.OffQualityPoor From ERS_BowelPreparation BP, ERS_Lists L Where L.ListDescription='Bowel_Preparation' And L.ListItemNo=BP.OnFormulation And BP.BowelPrepSettings=1 

GO

/* [dbo].[fw_BowelPreparation] */

Create View [dbo].[fw_BowelPreparation] As Select * From [dbo].[fw_UGI_BowelPreparation] Union All Select * From [dbo].[fw_ERS_BowelPreparation] 

GO

/* [dbo].[fw_UGI_RepeatOGD] */

Create View [dbo].[fw_UGI_RepeatOGD] As SELECT 'U.1.'+Convert(Varchar(10),[AUpper GI Gastric Ulcer/Malignancy].[Episode No])+'.'+Convert(Varchar(10),Convert(Int,SubString([AUpper GI Gastric Ulcer/Malignancy].[Patient No],7,6)))+'.'+Convert(varchar(10),[AUpper GI Gastric Ulcer/Malignancy].[Site No]) As SiteId, Convert(nvarchar(10),Convert(Date,GetDate())) As [RequestedDate], Case [Ulcer number] When 0 Then 'Gastric ulcer' Else 'Ulcer '+convert(nvarchar(10),[Ulcer number]) End + Case [Ulcer type] When 1 Then ' acute' When 2 Then ' chronic' Else '' End + Case When [Ulcer largest]<>0 Then Case When [Ulcer number]>1 Then ' (largest diameter '+convert(nvarchar(10),[Ulcer largest])+' cm)' Else ' (diameter '+convert(nvarchar(10),[Ulcer largest])+' cm)' End Else '' End + Case When [Ulcer active bleeding]=0 Then ' active bleeding' Else Case [Ulcer active bleeding type] When 1 Then ' (spurting)' When 2 Then ' (oozing)' Else '' End End + Case When [Ulcer clot in base]=0 Then ' fresh clot in base' Else '' End + Case When [Ulcer visible vessel]=0 Then ' visible vessel' + Case [Ulcer visible vessel type] When 1 Then ' with adherent clot in base' When 2 Then ' with pigmented base' Else '' End Else '' End + Case When [Ulcer old blood]=0 Then ' overlying old blood' Else '' End + Case When [Ulcer malignant appearance]=0 Then ' malignant appearance' Else '' End + Case When [Ulcer perforation]=0 Then ' perforation' Else '' End + ': '+[Region]+'. ' As SummaryText, Case When [AUpper GI Gastric Ulcer/Malignancy].[Not healed]=-1 Then 'V' Else Case When GetDate()>[Procedure date]+84 Then 'X' Else '?' End End As Result, Case When (Case When [AUpper GI Gastric Ulcer/Malignancy].[Not healed]=-1 Then 'V' Else Case When GetDate()>[Procedure date]+84 Then 'X' Else '?' End End) = 'V' Then 1 Else 0 End As [SeenWithin12weeks], Case When (Case When [AUpper GI Gastric Ulcer/Malignancy].[Not healed]=-1 Then 'V' Else Case When GetDate()>[Procedure date]+84 Then 'X' Else '?' End End) = 'X' Then 1 Else 0 End As [NotSeenWithin12Weeks], Case When (Case When [AUpper GI Gastric Ulcer/Malignancy].[Not healed]=-1 Then 'V' Else Case When GetDate()>[Procedure date]+84 Then 'X' Else '?' End End) = '?' Then 1 Else 0 End As [StillToBeSeen], Case When GetDate()>[Procedure date]+84 Then 'Seen '+Convert(nvarchar(10),Convert(int,(Convert(datetime,GetDate()-[Procedure date])))/7)+' weeks ago.' Else 'To be seen by '+Convert(nvarchar(20),Datepart(dd,Convert(date,[Procedure date]+84)))+' '+Convert(nvarchar(20),datepart(mm,Convert(date,[Procedure date]+84)))+' '+Convert(nvarchar(20),Datepart(yy,Convert(date,[Procedure date]+84)))+' (Within ' +Convert(nvarchar(10), Convert(nvarchar(10), Convert(int,Convert(int,Convert(datetime,([Procedure date]+84.0)-GetDate()))/7.0) ) ) +' weeks).' End + Case When [AUpper GI Gastric Ulcer/Malignancy].[Healed ulcer]=0 Then ' Healed' Else '' End + Case When [AUpper GI Gastric Ulcer/Malignancy].[Not healed]=-1 Then ' No OGD carried out' Else '' End+ Case When [Healing Ulcer]=0 Then Case [Healing Ulcer Type] When 0 Then '' When 1 Then ' Early healing (regenerative mucosa evident)' When 2 Then ' Advanced healing (almost complete re-epithelialisation).' When 3 Then ' ''Red Scar'' stage.' When 4 Then ' Ulcer Scar Deformity.' When 5 Then ' Atypical? Early gastric cancer.' Else ' Unknow' End Else '' End + Case When ([Healing Ulcer]<>-1) And ([AUpper GI Gastric Ulcer/Malignancy].[Not healed]<>-1) And (IsNull([AUpper GI Gastric Ulcer/Malignancy].[Healed ulcer],0)<>-1) Then ' (No ulcer data recorded).' Else '' End As [HealingText] FROM [AUpper GI Gastric Ulcer/Malignancy] INNER JOIN [Upper GI Sites] ON ([AUpper GI Gastric Ulcer/Malignancy].[Site No] = [Upper GI Sites].[Site No]) AND ([AUpper GI Gastric Ulcer/Malignancy].[Episode No] = [Upper GI Sites].[Episode No]) AND ([AUpper GI Gastric Ulcer/Malignancy].[Patient No] = [Upper GI Sites].[Patient No]) INNER JOIN [Patient] ON convert(int,SubString([AUpper GI Gastric Ulcer/Malignancy].[Patient No],7,6)) = Patient.[Patient No] INNER JOIN [Upper GI Procedure] ON convert(int,SubString([Upper GI Procedure].[Patient No],7,6)) = Patient.[Patient No] AND [Upper GI Procedure].[Episode No]=[Upper GI Sites].[Episode No] And [Upper GI Procedure].[Procedure date] Is Not Null WHERE (NOT Continuous=0 OR [Continuous start]=0) and ulcer=-1 

GO

/* [dbo].[fw_ERS_RepeatOGD] */

Create View [dbo].[fw_ERS_RepeatOGD] As Select 'E.'+Convert(varchar(10),Sites.SiteId) As SiteId, Convert(nvarchar(10),Convert(Date,GetDate())) As [RequestedDate], Case When Ulcers.UlcerNumber<>0 Then 'Ulcer Number '+Convert(nvarchar(10),Ulcers.UlcerNumber) Else 'No Ulcer Number' End + Case Ulcers.UlcerType When 1 Then ' acute' When 2 Then ' chronic' Else '' End + Case When Ulcers.UlcerLargestDiameter<>1 Then Case When Ulcers.[UlcerNumber]>0 Then ' (largest diameter '+convert(nvarchar(10),Ulcers.UlcerLargestDiameter)+' cm)' Else ' (diameter '+convert(nvarchar(10),Ulcers.UlcerLargestDiameter)+' cm)' End Else '' End + Case When Ulcers.[UlcerActiveBleeding]=1 Then ' active bleeding' Else Case Ulcers.[UlcerActiveBleedingtype] When 1 Then ' (spurting)' When 2 Then ' (oozing)' Else '' End End + Case When Ulcers.[UlcerClotInBase]=1 Then ' fresh clot in base' Else '' End + Case When Ulcers.[UlcerVisibleVesselType]=1 Then ' visible vessel' + Case Ulcers.[UlcerVisibleVesselType] When 1 Then ' with adherent clot in base' When 2 Then ' with pigmented base' Else '' End Else '' End + Case When Ulcers.[UlcerOldBlood]=1 Then ' overlying old blood' Else '' End + Case When Ulcers.[UlcerMalignantAppearance]=1 Then ' malignant appearance' + Case When Ulcers.[UlcerPerforation]=1 Then ' associated with perforation' Else '' End Else Case When Ulcers.[UlcerPerforation]=1 Then ' perforation' Else '' End End + ': '+Regions.Region+'. ' As SummaryText, Case When Ulcers.[NotHealed]=1 Then 'V' Else Case When GetDate()>[CreatedOn]+84 Then 'X' Else '?' End End As Result, Case When (Case When Ulcers.[NotHealed]=1 Then 'X' Else Case When GetDate()>[CreatedOn]+84 Then 'X' Else '?' End End) = 'V' Then 1 Else 0 End As [SeenWithin12Weeks], Case When (Case When Ulcers.[NotHealed]=1 Then 'X' Else Case When GetDate()>[CreatedOn]+84 Then 'X' Else '?' End End) = 'X' Then 1 Else 0 End As [NotSeenWithin12Weeks], Case When (Case When Ulcers.[NotHealed]=1 Then 'X' Else Case When GetDate()>[CreatedOn]+84 Then 'X' Else '?' End End) = '?' Then 1 Else 0 End As [StillToBeSeen], Case When GetDate()>Procedures.[CreatedOn]+84 Then 'Seen '+Convert(nvarchar(10),Convert(int,(Convert(datetime,GetDate()-Procedures.[CreatedOn])))/7)+' weeks ago.' Else 'To be seen by '+Convert(nvarchar(20),Datepart(dd,Convert(date,Procedures.[CreatedOn]+84)))+' '+Convert(nvarchar(20),datepart(mm,Convert(date,Procedures.[CreatedOn]+84)))+' '+Convert(nvarchar(20),Datepart(yy,Convert(date,Procedures.[CreatedOn]+84)))+' (Within '+Convert(nvarchar(10),(Convert(nvarchar(10),Convert(int,(Convert(datetime,Procedures.[CreatedOn]+84-GetDate())))/7)))+' weeks).' End + Case When Ulcers.[HealedUlcer]=1 Then ' Healed' Else '' End + Case When Ulcers.[NotHealed]=1 Then ' No OGD carried out' Else '' End+ Case When Ulcers.[HealingUlcer]=1 Then Case Ulcers.[HealingUlcerType] When 0 Then '' When 1 Then ' Early healing (regenerative mucosa evident)' When 2 Then ' Advanced healing (almost complete re-epithelialisation).' When 3 Then ' ''Red Scar'' stage.' When 4 Then ' Ulcer Scar Deformity.' When 5 Then ' Atypical? Early gastric cancer.' Else ' Unknow' End Else '' End + Case When (Ulcers.[HealingUlcer]<>0) And (Ulcers.[NotHealed]<>0) And (IsNull(Ulcers.[HealedUlcer],0)<>0) Then ' (No ulcer data recorded).' Else '' End As [HealingText] From [dbo].[Patient] Patients, [dbo].[ERS_Procedures] Procedures, [dbo].[ERS_Sites] Sites, [dbo].[ERS_Regions] Regions, [dbo].[ERS_UpperGIAbnoGastricUlcer] Ulcers Where Patients.[Patient No]=Procedures.PatientId And Procedures.ProcedureId=Sites.ProcedureId And Sites.SiteId=Ulcers.SiteId And Sites.RegionId=Regions.RegionId 

GO

/* [dbo].[fw_RepeatOGD] */

Create View [dbo].[fw_RepeatOGD] As SELECT * From [dbo].[fw_UGI_RepeatOGD] Union All SELECT * From [dbo].[fw_ERS_RepeatOGD] 

GO

/* [dbo].[fw_UGI_ProceduresInstruments] */

Create View [dbo].[fw_UGI_ProceduresInstruments] As Select 'U.1.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 1 As ScopeId , 'U.1.'+Convert(varchar(10),UP.[Instrument]) As InstrumentId From [Episode] E, [Upper GI Procedure] UP Where SubString(E.[Status],1,1)=1 And E.[Episode No]=Up.[Episode No] And UP.[Instrument] Is Not Null Union All Select 'U.1.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 2 As ScopeId , 'U.1.'+Convert(varchar(10),UP.[Instrument 2]) As InstrumentId From [Episode] E, [Upper GI Procedure] UP Where SubString(E.[Status],1,1)=1 And E.[Episode No]=Up.[Episode No] And (UP.[Instrument 2] Is Not Null Or UP.Instrument<>UP.[Instrument 2]) Union All Select 'U.2.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 1 As ScopeId , 'U.2.'+Convert(varchar(10),EP.[Instrument]) As InstrumentId From [Episode] E, [ERCP Procedure] EP Where SubString(E.[Status],2,1)=1 And EP.[Episode No]=E.[Episode No] And EP.[Instrument] Is Not Null Union All Select 'U.2.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 2 As ScopeId , 'U.2.'+Convert(varchar(10),EP.[Instrument 2]) As InstrumentId From [Episode] E, [ERCP Procedure] EP Where SubString(E.[Status],2,1)=1 And EP.[Episode No]=E.[Episode No] And (EP.[Instrument 2] Is Not Null Or EP.Instrument<>EP.[Instrument 2]) Union All Select 'U.'+Convert(varchar(1),3+IsNull((Select Top 1 [Procedure type] From [Colon procedure] CP Where CP.[Episode No]=E.[Episode No] And [Procedure type]<>2),0))+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 1 As ScopeId , 'U.'+Convert(varchar(1),3+IsNull((Select Top 1 [Procedure type] From [Colon procedure] CP Where CP.[Episode No]=E.[Episode No] And [Procedure type]<>2),0))+'.'+Convert(varchar(10),CP.[Instrument 2]) As InstrumentId From [Episode] E, [Colon Procedure] CP Where SubString(E.[Status],3,1)=1 And CP.[Episode No]=E.[Episode No] And CP.[Instrument] Is Not Null Union All Select 'U.'+Convert(varchar(1),3+IsNull((Select Top 1 [Procedure type] From [Colon procedure] CP Where CP.[Episode No]=E.[Episode No] And [Procedure type]<>2),0))+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 2 As ScopeId , 'U.'+Convert(varchar(10),CP.[Instrument 2]) As InstrumentId From [Episode] E, [Colon Procedure] CP Where SubString(E.[Status],3,1)=1 And CP.[Episode No]=E.[Episode No] And (CP.[Instrument 2] Is Not Null Or CP.Instrument<>CP.[Instrument 2]) Union All Select 'U.5.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 1 As ScopeId , 'U.5.'+Convert(varchar(10),CP.[Instrument]) As InstrumentId From [Episode] E, [Colon Procedure] CP Where SubString(E.[Status],4,1)=1 And CP.[Episode No]=E.[Episode No] And CP.[Patient No]=E.[Patient No] And CP.[Instrument] Is Not Null Union All Select 'U.5.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 2 As ScopeId , 'U.5.'+Convert(varchar(10),CP.[Instrument 2]) As InstrumentId From [Episode] E, [Colon Procedure] CP Where SubString(E.[Status],4,1)=1 And CP.[Episode No]=E.[Episode No] And CP.[Patient No]=E.[Patient No] And (CP.[Instrument 2] Is Not Null Or CP.Instrument<>CP.[Instrument 2]) Union All Select 'U.6.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 1 As ScopeId , 'U.6.'+Convert(varchar(10),CP.[Instrument]) As InstrumentId From [Episode] E, [Colon Procedure] CP Where SubString(E.[Status],4,1)=1 And CP.[Episode No]=E.[Episode No] And CP.[Patient No]=E.[Patient No] And CP.[Instrument] Is Not Null Union All Select 'U.6.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 2 As ScopeId , 'U.6.'+Convert(varchar(10),CP.[Instrument 2]) As InstrumentId From [Episode] E, [Colon Procedure] CP Where SubString(E.[Status],4,1)=1 And CP.[Episode No]=E.[Episode No] And CP.[Patient No]=E.[Patient No] And (CP.[Instrument 2] Is Not Null Or CP.Instrument<>CP.[Instrument 2]) Union All Select 'U.7.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 1 As ConsultantTypeId , 'U.6.'+Convert(varchar(10),Convert(Int,SubString(CP.Endoscopist2,7,6))) As ConsultantId From [Episode] E, [Colon Procedure] CP Where SubString(E.[Status],6,1)=1 And CP.[Episode No]=E.[Episode No] And CP.[Instrument] Is Not Null Union All Select 'U.7.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 2 As ConsultantTypeId , 'U.6.'+Convert(varchar(10),Convert(Int,SubString(CP.Endoscopist1,7,6))) As ConsultantId From [Episode] E, [Colon Procedure] CP Where SubString(E.[Status],6,1)=1 And CP.[Episode No]=E.[Episode No] And (CP.[Instrument 2] Is Not Null Or CP.Instrument<>CP.[Instrument 2]) 

GO

/* [dbo].[fw_ERS_ProceduresInstruments] */

Create View [dbo].[fw_ERS_ProceduresInstruments] As Select 'E.'+Convert(Varchar(10),PR.ProcedureId) As ProcedureId ,1 As ScopeId , 'E.'+Convert(varchar(10),PR.ProcedureType)+'.'+Convert(varchar(10),PR.Instrument1) As InstrumentId From ERS_Procedures PR, Patient E Where PR.PatientId=E.[Patient No] And PR.Instrument1 Is Not Null Union All Select 'E.'+Convert(Varchar(10),PR.ProcedureId) As ProcedureId ,2 As ScopeId , 'E.'+Convert(varchar(10),PR.ProcedureType)+'.'+Convert(varchar(10),PR.Instrument2) As InstrumentId From ERS_Procedures PR, Patient E Where PR.PatientId=E.[Patient No] And PR.Instrument2 Is Not Null 

GO

/* [dbo].[fw_ProceduresInstruments] */

Create View [dbo].[fw_ProceduresInstruments] As Select * From [dbo].[fw_UGI_ProceduresInstruments] Union All Select * From [dbo].[fw_ERS_ProceduresInstruments] 

GO

/* [dbo].[fw_UGI_BowelPreparationBoston] */

Create View [dbo].[fw_UGI_BowelPreparationBoston] As Select 'U.'+Convert(varchar(3),Case When CHARINDEX('1', SUBSTRING(E.[Status], 1, 10))='3' Then IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) Else CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(Varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId, Convert(BIT,Case When BBPScore Is Null Then 0 Else 1 End) As BowelPrepSettings, Convert(BIT,Case IsNull(I.[Bowel preparation],0) When 0 Then 1 Else 0 End) As OnNoBowelPrep, Lists.[List item text] As Formulation, IsNull(I.[Bowel preparation],0) As OnFormulation, IsNull(I.BBPSRight,0) As OnRight, IsNull(I.BBPSTransverse,0) As OnTransverse, IsNull(I.BBPSLeft,0) As OnLeft, IsNull(I.BBPScore,0) As OnTotalScore, Case IsNull(I.[Bowel preparation],0) When 0 Then 1 Else 0 End As OffNoBowelPrep, IsNull(I.[Bowel preparation],0) As OffFormulation, Case IsNull(I.Quality,0) When 1 Then 1 Else 0 End As OffQualityGood, Case IsNull(I.Quality,0) When 2 Then 1 Else 0 End As OffQualitySatisfactory, Case IsNull(I.Quality,0) When 3 Then 1 Else 0 End As OffQualityPoor From dbo.[Colon Indications] I , dbo.Lists Lists , dbo.Episode E , [Colon Procedure] CP Where I.BBPScore Is Not Null And IsNull(I.[Bowel preparation],0)=Lists.[List item no] And Lists.[List description]='Preparation' And I.[Patient No]=E.[Patient No] And I.[Episode No]=E.[Episode No] And E.[Patient No]=CP.[Patient No] And E.[Episode No]=CP.[Episode No] And UPPER(Lists.[List item text]) <> '(NONE SELECTED)' 

GO

/* [dbo].[fw_ERS_BowelPreparationBoston] */

Create View [dbo].[fw_ERS_BowelPreparationBoston] As Select 'E.'+Convert(varchar(10),BP.ProcedureID) As ProcedureId , BP.BowelPrepSettings , BP.OnNoBowelPrep , L.ListItemText As Formulation , BP.OnFormulation , BP.OnRight, BP.OnTransverse, BP.OnLeft, OnTotalScore, BP.OffNoBowelPrep, BP.OffFormulation, BP.OffQualityGood, BP.OffQualitySatisfactory, BP.OffQualityPoor From ERS_BowelPreparation BP, ERS_Lists L Where L.ListDescription='Bowel_Preparation' And L.ListItemNo=BP.OnFormulation And BP.BowelPrepSettings=1 

GO

/* [dbo].[fw_BowelPreparationBoston] */

Create View [dbo].[fw_BowelPreparationBoston] As Select * From [dbo].[fw_UGI_BowelPreparationBoston] Union All Select * From [dbo].[fw_ERS_BowelPreparationBoston] 

GO

/* [dbo].[fw_UGI_Therapeutic] */

Create View [dbo].[fw_UGI_Therapeutic] As Select UP.SiteId, UP.TherapeuticID, TT.Therapeutic, TT.NedName, NULL As Organ, NULL As [role], Null As polypSize, NULL As Tattoed, NULL As Performed, NULL As Successful, NULL As Retrieved, NULL As Coment From ( Select 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+'.'+CONVERT(varchar(10),T.[Site No]) As SiteId , Case When T.[Argon beam diathermy]=-1 Then 60 End As ArgonBeamDiathermy , Case When T.[Balloon dilatation]=-1 Then 61 End As BalloonDilation , Case When T.[Bicap electro]=-1 Then 4 End As BicapElectrocautery , Case When T.[Heat probe]=-1 Then 66 End As HeaterProbe , Case When T.[Hot biopsy]=-1 Then 67 End As HotBiopsy , Case When T.Injection=-1 Then 68 End As InjectionTherapy , Case When T.EMR=-1 Then 64 End As EMR , Case When T.Diathermy=-1 Then 60 End As Diathermy , Case When T.Dilatation=-1 Then 61 End As Dilatation , Case When T.[Endoloop placement]=-1 Then 72 End As Endoloop , Case When T.[Foreign body]=-1 Then 15 End As ForeignBody , Case When T.Marking=-1 Then 16 End As Marking , Case When T.Polypectomy=-1 Then 70 End As Polypectomy , Case When T.[Polypectomy removal]=-1 Then 70 End As PolypectomyRemoval , Case When T.RFA=-1 Then 71 End As RFA , Case When T.[Stent insertion]=-1 Then 72 End As StentInsertion , Case When T.[Therapeutic none]=-1 Then 1 End As [None] , Case When T.[Variceal banding]=-1 Then 74 End As VaricealBanding , Case When T.[YAG laser]=-1 Then 75 End As YAGlaser , Case When T.Clip=-1 Then 77 End As Clip , Case When IsNull(T.Other,'')<>'' Then 50 End As Other From Episode E LEFT OUTER JOIN [Colon Therapeutic] T ON T.[Episode No]=E.[Episode No] And T.[Patient No]=E.[Patient No] LEFT OUTER JOIN [Colon Sites] S ON T.[Episode No]=S.[Episode No] And T.[Patient No]=S.[Patient No] And T.[Site No]=S.[Site No] ) As PT UNPIVOT ( TherapeuticID FOR Therapies IN (ArgonBeamDiathermy, BalloonDilation, BicapElectrocautery, HeaterProbe, HotBiopsy, InjectionTherapy, EMR, Diathermy, Dilatation, ForeignBody, Marking, Polypectomy, PolypectomyRemoval, RFA, StentInsertion, [None], VaricealBanding, YAGlaser, Clip, Other) ) As UP LEFT OUTER JOIN ERS_TherapeuticTypes TT ON UP.TherapeuticID=TT.TherapeuticID Where SiteId Is Not Null Union All Select UP.SiteId, UP.TherapeuticID, TT.Therapeutic, TT.NedName , NULL As Organ, NULL As [role], Null As polypSize, NULL As Tattoed, NULL As Performed, NULL As Successful, NULL As Retrieved, NULL As Coment From ( Select 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+'.'+CONVERT(varchar(10),T.[Site No]) As SiteId , Case When T.[Argon beam diathermy]=-1 Then 2 End As ArgonBeamDiathermy , Case When T.[Balloon dilatation]=-1 Then 3 End As BalloonDilation , Case When T.[Bicap electro]=-1 Then 4 End As BicapElectrocautery , Case When T.[Heat probe]=-1 Then 7 End As HeaterProbe , Case When T.[Hot biopsy]=-1 Then 8 End As HotBiopsy , Case When T.Injection=-1 Then 9 End As InjectionTherapy , Case When T.EMR=-1 Then 18 End As EMR , Case When T.[Band ligation]=-1 Then 12 End As BandLigation , Case When T.Diathermy=-1 Then 2 End As Diathermy , Case When T.Dilatation=-1 Then 3 End As Dilatation , Case When T.[Endoloop placement]=-1 Then 14 End As Endoloop , Case When T.[Foreign body]=-1 Then 15 End As ForeignBody , Case When T.[Gastrostomy Insertion (PEG)]=-1 Then 24 End As PEGInsertion , Case When T.[Gastrostomy Removal (PEG)]=-1 Then 25 End As PEGRemoval , Case When T.Marking=-1 Then 16 End As Marking , Case When T.[Oesophageal dilatation]=-1 Then 11 End As Oesophagealdilatation , Case When T.Polypectomy=-1 Then 27 End As Polypectomy , Case When T.[Polypectomy removal]=-1 Then 25 End As PolypectomyRemoval , Case When T.RFA=-1 Then 29 End As RFA , Case When T.[Stent insertion]=-1 Then 30 End As StentInsertion , Case When T.[Therapeutic none]=-1 Then 1 End As [None] , Case When T.[Variceal banding]=-1 Then 33 End As VaricealBanding , Case When T.[YAG laser]=-1 Then 34 End As YAGlaser , Case When IsNull(T.Other,'')<>'' Then 50 End As Other From Episode E LEFT OUTER JOIN [Upper GI Therapeutic] T ON T.[Episode No]=E.[Episode No] And T.[Patient No]=E.[Patient No] LEFT OUTER JOIN [ERCP Sites] S ON T.[Episode No]=S.[Episode No] And T.[Patient No]=S.[Patient No] And T.[Site No]=S.[Site No] ) As PT UNPIVOT ( TherapeuticID FOR Therapies IN (ArgonBeamDiathermy, BalloonDilation, BicapElectrocautery, HeaterProbe, HotBiopsy, InjectionTherapy, EMR, BandLigation, Diathermy, Dilatation, ForeignBody, PEGInsertion, PEGRemoval, Marking, Oesophagealdilatation, Polypectomy, PolypectomyRemoval, RFA, StentInsertion, [None], VaricealBanding, YAGlaser, Other) ) As UP LEFT OUTER JOIN ERS_TherapeuticTypes TT ON UP.TherapeuticID=TT.TherapeuticID Where SiteId Is Not Null 

GO

/* [dbo].[fw_ERS_Therapeutic] */

Create View [dbo].[fw_ERS_Therapeutic] As Select UP.SiteId, UP.TherapeuticID, TT.Therapeutic, TT.NedName, Organ, [role], polypSize, Tattooed, Performed, Successful, Retrieved, comment From ( Select 'E.'+Convert(varchar(3),S.SiteId) As SiteId , Organ, NULL [role] , Case When IsNull(L.SessileLargest,0)>IsNull(L.PedunculatedLargest,0) Then IsNull(L.SessileLargest,0) Else Case When IsNull(L.PedunculatedLargest,0)>IsNull(L.SubmucosalLargest,0) Then IsNull(L.PedunculatedLargest,0) Else IsNull(L.SubmucosalLargest,0) End End As polypSize , UT.Marking As Tattooed , Case When S.SiteId Is Null Then 0 Else 1 End Performed , UT.PolypectomyRemoval As Successful, UT.PolypectomyRemoval+UT.GastrostomyRemoval As Retrieved, L.Summary As comment , Case When UT.ArgonBeamDiathermy=1 Then 2 End As ArgonBeamDiathermy , Case When UT.BicapElectro=1 Then 4 End As BicapElectro , Case When UT.BandLigation=1 Then 62 End As BandLigation , Case When UT.BotoxInjection=1 Then 68 End As BotoxInjection , Case When UT.Clip=1 Then 77 End As Clip , Case When UT.CorrectPEGPlacement=1 Then 24 End As CorrectPEGPlacement , Case When UT.CorrectStentPlacement=1 Then 30 End As CorrectStentPlacement , Case When UT.Diathermy=1 Then 60 End As Diathermy , Case When UT.EMR=1 Then 64 End As EMR , Case When UT.EndoloopPlacement=1 Then 72 End As EndoloopPlacement , Case When UT.ForeignBody=1 Then 15 End As ForeignBody , Case When UT.GastrostomyInsertion=1 Then 30 End As GastrostomyInsertion , Case When UT.GastrostomyRemoval=1 Then 31 End As GastrostomyRemoval , Case When UT.HeatProbe=1 Then 7 End As HeatProbe , Case When UT.HotBiopsy=1 Then 67 End As HotBiopsy , Case When UT.Injection=1 Then 68 End As Injection , Case When UT.Marking=1 Then 16 End As Marking , Case When UT.[None]=1 Then 1 End As [None] , Case When UT.OesoDilMedicalReview=1 Then 11 End As OesoDilMedicalReview , Case When UT.Other=1 Then 76 End As Other , Case When UT.Polypectomy=1 Then 70 End As Polypectomy , Case When UT.PyloricDilatation=1 Then 28 End As PyloricDilatation , Case When UT.RFA=1 Then 71 End As RFA , Case When UT.StentInsertion=1 Then 72 End As StentInsertion , Case When UT.StentRemoval=1 Then 73 End As StentRemoval , Case When UT.VaricealBanding=1 Then 74 End As VaricealBanding , Case When UT.VaricealSclerotherapy=1 Then 74 End As VaricealSclerotherapy , Case When UT.YAGLaser=1 Then 75 End As YAGLaser , Case When T.BrushCytology='TRUE' Then 40 End As BrushCytology , Case When T.Polypectomy='TRUE' Then 27 End As Polypectomy2 , Case When T.HotBiopsy='TRUE' Then 67 End As HotBiopsy2 , Case When T.[None]='TRUE' Then 1 End As [None2] From dbo.ERS_Procedures P LEFT OUTER JOIN dbo.ERS_Sites S ON P.ProcedureId = S.ProcedureId LEFT OUTER JOIN dbo.ERS_UpperGITherapeutics UT ON S.SiteId = UT.SiteId LEFT OUTER JOIN dbo.ERS_ColonTherapeutics CT ON S.SiteId = CT.SiteId LEFT OUTER JOIN [dbo].[ERS_Organs] O ON O.RegionId=S.RegionId LEFT OUTER JOIN [dbo].[ERS_ColonAbnoLesions] L ON S.SiteId=L.SiteId LEFT OUTER JOIN [dbo].[ERS_UpperGISpecimens] T ON S.SiteId=T.SiteId ) As PT UNPIVOT ( TherapeuticID FOR Therapies IN (ArgonBeamDiathermy, BicapElectro, BandLigation, BotoxInjection, Clip, CorrectPEGPlacement, CorrectStentPlacement, EMR, EndoloopPlacement, GastrostomyInsertion, GastrostomyRemoval, Marking, [None], OesoDilMedicalReview, Other, Polypectomy, PyloricDilatation, StentInsertion, StentRemoval, VaricealBanding , BrushCytology, Polypectomy2, HotBiopsy2,[None2]) ) As UP LEFT OUTER JOIN ERS_TherapeuticTypes TT ON UP.TherapeuticID=TT.TherapeuticID Where SiteId Is Not Null And Organ Is Not Null 

GO

/* [dbo].[fw_Therapeutic] */

Create View [dbo].[fw_Therapeutic] As Select * From [dbo].[fw_UGI_Therapeutic] Union All Select * From [dbo].[fw_ERS_Therapeutic] 

GO

/* [dbo].[fw_UGI_Specimens] */

Create View [dbo].[fw_UGI_Specimens] As Select 'U.'+Convert(varchar(3),Case When CHARINDEX('1', SUBSTRING(E.[Status], 1, 10))='3' Then IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) Else CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) End)+'.'+Convert(Varchar(10),E.[Episode No])+'.'+Convert(Varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+'.'+convert(varchar(10),SP.[Site No]) As SiteId , Case When Polypectomy=-1 Then 1 Else 0 End As Polypectomy , SP.[Polypectomy qty] As PolypectomyQty From Episode E, [Colon Specimens] SP Where E.[Episode No]=SP.[Episode No] And E.[Patient No]=SP.[Patient No] And CHARINDEX('1', SUBSTRING(E.[Status], 1, 10))='3' 

GO

/* [dbo].[fw_ERS_Specimens] */

Create View [dbo].[fw_ERS_Specimens] As Select 'E.'+Convert(varchar(10),SP.SiteId) As SiteId , SP.Polypectomy , SP.PolypectomyQty From ERS_UpperGISpecimens SP 

GO

/* [dbo].[fw_Specimens] */

Create View [dbo].[fw_Specimens] As Select * From [dbo].[fw_UGI_Specimens] Union All Select * From [dbo].[fw_ERS_Specimens] 

GO

/* [dbo].[fw_ReportFilter] */

Create View [dbo].[fw_ReportFilter] WITH SCHEMABINDING As Select UserID As UserId, ReportDate, FromDate, ToDate, Anonymise, TypesOfEndoscopists, HideSuppressed From [dbo].[ERS_ReportFilter] 

GO

/* kfw_ReportFilter */

Create UNIQUE CLUSTERED INDEX kfw_ReportFilter ON fw_ReportFilter (UserID)

GO

/* [dbo].[fw_UGI_Sites] */

Create View [dbo].[fw_UGI_Sites] As Select 'U.'+Convert(varchar(2),Case QJ.SrcTable When 'C' Then Case When SubString(E.[Status],3,1)=1 Then Case QJ.[Procedure type] When 0 Then 3 When 1 Then 4 End Else 5 End When 'E' Then Case When SubString(E.[Status],6,1)=1 Then 7 Else 2 End When 'U' Then Case When SubString(E.[Status],5,1)=1 Then 6 Else 1 End Else 0 End)+'.'+Convert(varchar(10),QJ.[Episode No])+'.'+Convert(varchar(10),Convert(int,SubString(QJ.[Patient No],7,6))) As ProcedureId ,'U.'+Convert(varchar(2),Case QJ.SrcTable When 'C' Then Case When SubString(E.[Status],3,1)=1 Then Case QJ.[Procedure type] When 0 Then 3 When 1 Then 4 End Else 5 End When 'E' Then Case When SubString(E.[Status],6,1)=1 Then 7 Else 2 End When 'U' Then Case When SubString(E.[Status],5,1)=1 Then 6 Else 1 End Else 0 End)+'.'+Convert(varchar(10),QJ.[Episode No])+'.'+Convert(varchar(10),Convert(int,SubString(QJ.[Patient No],7,6)))+'.'+Convert(varchar(10),QJ.[Site No]) As SiteId ,QJ.Region, QJ.AntPostId From (Select 'E' As SrcTable, ERS.[Episode No], ERS.[Patient No], ERS.[Site No], ERS.Region, ERS.AntPost As AntPostId, ERS.[EUS proc type] As [Procedure type] From [dbo].[ERCP Sites] ERS Union All Select 'U' As SrcTable, UGS.[Episode No], UGS.[Patient No], UGS.[Site No], UGS.Region, UGS.AntPost As AntPostId, UGS.[EUS proc type] As [Procedure type] From [dbo].[Upper GI Sites] UGS Union All Select 'C' As SrcTable, CSS.[Episode No], CSS.[Patient No], CSS.[Site No], CSS.Region, 9 As AntPostId, CSS.[Procedure type] From [dbo].[Colon Sites] CSS) As QJ INNER JOIN [dbo].[Episode] E ON QJ.[Episode No]=E.[Episode No] And QJ.[Patient No]=E.[Patient No] 

GO

/* [dbo].[fw_ERS_Sites] */

Create View [dbo].[fw_ERS_Sites] WITH SCHEMABINDING As Select 'E.'+Convert(Varchar(10),EES.ProcedureId) As ProcedureId , 'E.'+Convert(Varchar(10),EES.SiteId) As SiteId , R.Region , EES.AntPos As AntPosId From [dbo].[ERS_Sites] EES, [dbo].[ERS_Procedures] EP, [dbo].[ERS_Regions] R Where EES.ProcedureId=EP.ProcedureId And R.ProcedureType=EP.ProcedureType And EES.RegionId=R.RegionId 

GO

/* [dbo].[fw_Sites] */

Create View [dbo].[fw_Sites] As Select * From [dbo].[fw_UGI_Sites] Union All Select * From [dbo].[fw_ERS_Sites] 

GO

/* [dbo].[fw_ReportConsultants] */

Create View [dbo].[fw_ReportConsultants] WITH SCHEMABINDING As Select UserId , Case When ConsultantID>100000 Then 'U.'+Convert(Varchar(10),ConsultantID-1000000) Else 'E.'+Convert(Varchar(10),ConsultantID) End As ConsultantId , AnonimizedID From [dbo].[ERS_ReportConsultants] 

GO

/* kfw_ReportConsultants */

CREATE UNIQUE CLUSTERED INDEX kfw_ReportConsultants ON fw_ReportConsultants (UserId,ConsultantId)

GO

/* [dbo].[fw_Procedures] */

Create View [dbo].[fw_Procedures] As Select * From fw_UGI_Procedures Union All Select * From fw_ERS_Procedures 

GO

/* [dbo].[fw_UGI_ProceduresConsultants] */

Create View [dbo].[fw_UGI_ProceduresConsultants] As Select GPC.ProcedureId, Convert(int,SubString(ConsultantId,1,1)) As ConsultantTypeId, GPC.AppId+'.'+SubString(ConsultantId,3,len(ConsultantId)-2) As ConsultantId From (Select UP.ProcedureId, AppId, UP.ConsultantId From (Select 'U.'+Convert(varchar(1),QK.ProcedureTypeId)+'.'+Convert(varchar(10),QK.[Episode No])+'.'+Convert(varchar(10),QK.PatientId) As ProcedureId, 'U' As AppId, QK.Endoscopist1, QK.Endoscopist2, QK.ListConsultant, QK.Assistant, QK.Nurse1, QK.Nurse2 From (Select Case QJ.SrcTable When 'C' Then Case When SubString(E.[Status],3,1)=1 Then Case QJ.[Procedure type] When 0 Then 3 When 1 Then 4 End Else 5 End When 'E' Then Case When SubString(E.[Status],6,1)=1 Then 7 Else 2 End When 'U' Then Case When SubString(E.[Status],5,1)=1 Then 6 Else 1 End Else 0 End As ProcedureTypeId ,Convert(int,SubString(QJ.[Patient No],7,6)) As PatientId,QJ.[Episode No],'1.'+Convert(varchar(10),Convert(INT,SubString(QJ.[Endoscopist1],7,6))) As Endoscopist1, '2.'+Convert(varchar(10),Convert(INT,SubString(QJ.[Endoscopist2],7,6))) As Endoscopist2, '3.'+Convert(varchar(10),Convert(INT,SubString(QJ.[Assistant1],7,6))) As ListConsultant, '4.'+Convert(varchar(10),Convert(INT,SubString(QJ.[Assistant2],7,6))) As Assistant, '5.'+Convert(varchar(10),Convert(INT,SubString(QJ.[Nurse1],7,6))) As Nurse1, '6.'+Convert(varchar(10),Convert(INT,SubString(QJ.[Nurse2],7,6))) As Nurse2 FROM ( select 'C' As SrcTable, [Patient No],[Episode No],[Procedure type],[Endoscopist1],[Endoscopist2],[Assistant1],[Assistant2], Nurse1, Nurse2 from [Colon Procedure] UNION select 'U' As SrcTable, [Patient No],[Episode No],0 as [Procedure type],[Endoscopist1],[Endoscopist2],[Assistant1],[Assistant2], Nurse1, Nurse2 from [Upper GI Procedure] UNION select 'E' As SrcTable, [Patient No],[Episode No],0 as [Procedure type],[Endoscopist1],[Endoscopist2],[Assistant1],[Assistant2], Nurse1, Nurse2 from [ERCP Procedure] ) As QJ INNER JOIN Patient P ON QJ.[Patient No]=P.[Combo ID] INNER JOIN Episode E ON QJ.[Episode No]=E.[Episode No] ) As QK Where ProcedureTypeId Is Not Null ) As PT UNPIVOT (ConsultantId For Consultants In (Endoscopist1,Endoscopist2,ListConsultant,Assistant, Nurse1, Nurse2)) As UP) As GPC 

GO

/* [dbo].[fw_ERS_ProceduresConsultants] */

Create View [dbo].[fw_ERS_ProceduresConsultants]
WITH SCHEMABINDING
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

/* [dbo].[fw_ProceduresConsultants] */

Create View [dbo].[fw_ProceduresConsultants] As Select * From [dbo].[fw_UGI_ProceduresConsultants] Union All Select * From [dbo].[fw_ERS_ProceduresConsultants] 

GO

/* [dbo].[fw_UGI_Premedication] */

Create View [dbo].[fw_UGI_Premedication] As SELECT 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId ,PM.[Drug No] As DrugId , PM.Dose , D.Units , PM.[Drug No] As OrderId , D.[Drug name] As DrugName , Case When D.[Is reversing agent]=-1 Then 1 Else 0 End As IsReversingAgent FROM Episode E, [Patient premedication] PM, [Drug list] D Where E.[Episode No]=PM.[Episode No] And PM.[Drug No]=D.[Drug no] 

GO

/* [dbo].[fw_ERS_Premedication] */

Create View [dbo].[fw_ERS_Premedication] WITH SCHEMABINDING AS Select 'E.'+Convert(varchar(10),PM.ProcedureId) As ProcedureId , PM.DrugNo As DrugId , PM.Dose , D.Units , ROW_NUMBER() Over (Order By PM.ProcedureId) As OrderId , D.DrugName, D.IsReversingAgent From [dbo].[ERS_UpperGIPremedication] PM, [dbo].[ERS_DrugList] D Where PM.DrugNo=D.DrugNo 

GO

/* [dbo].[fw_Premedication] */

Create View [dbo].[fw_Premedication] As SELECT * FROM [dbo].[fw_UGI_Premedication] UNION ALL SELECT * FROM [dbo].[fw_ERS_Premedication] 

GO

/* [dbo].[fw_UGI_Placements] */

Create View [dbo].[fw_UGI_Placements] WITH SCHEMABINDING As Select 'U.1.'+Convert(Varchar(10),GISites.[Episode No])+'.'+Convert(Varchar(10),Convert(Int,SubString(GISites.[Patient No],7,6)))+'.'+Convert(varchar(10),GISites.[Site No]) As SiteId, Case When GITherapy.[Gastrostomy Insertion (PEG)]=-1 Then 1 Else 0 End As [Placements], Case When GITherapy.[Gastrostomy Insertion (PEG)]=-1 Then Case GITherapy.[Stent insertion] When -1 Then 0. Else 1. End Else 0. End As [IncorrectPlacement], Case When GITherapy.[Gastrostomy Insertion (PEG)]=-1 Then Case GITherapy.[Stent insertion] When -1 Then 1.0 Else 0. End Else 0. End As [CorrectPlacement] From [dbo].[Upper GI Procedure] Procs , [dbo].[Upper GI sites] GISites , [dbo].[Upper GI therapeutic] GITherapy , [dbo].[Patient] Patients Where GISites.[Patient No]=Procs.[Patient No] And GISites.[Episode No]=Procs.[Episode No] And GITherapy.[Patient No]=GISites.[Patient No] And GITherapy.[Episode No]=GISites.[Episode No] And GITherapy.[Site No]=GISites.[Site No] And Patients.[Patient No]=Convert(int,SubString(IsNull(Procs.[Patient No],'000000'),7,6)) And Procs.Endoscopist1 Is Not Null And Procs.Endoscopist1 <>'' 

GO

/* [dbo].[fw_ERS_Placements] */

Create View [dbo].[fw_ERS_Placements] WITH SCHEMABINDING As Select 'E.'+Convert(varchar(10),GISites.SiteId) As SiteId, 1 As [Placements], Case When GITherapy.[StentInsertion]=1 Then 0 Else 1 End As [IncorrectPlacement], Case When GITherapy.[StentInsertion]=1 Then 1 Else 0 End As [CorrectPlacement] From [dbo].[ERS_Procedures] Procs , [dbo].[Patient] Patients , [dbo].[ERS_Sites] GISites , [dbo].[ERS_UpperGITherapeutics] GITherapy Where GISites.ProcedureId=Procs.ProcedureId And GITherapy.SiteId=GISites.SiteId And Patients.[Patient No]=Procs.PatientId And Procs.[ProcedureType]=1 

GO

/* [dbo].[fw_Placements] */

Create View [dbo].[fw_Placements] As Select * From fw_UGI_Placements Union All Select * From fw_ERS_Placements 

GO

/* [dbo].[fw_PathologyResults] */

Create View [dbo].[fw_PathologyResults] As SELECT 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId ,RE.[Adenoma confirmed] As AdenomaConfirmed ,Convert(Date,Convert(DateTime,'1900-01-01')+Convert(DateTime,RE.[Date of specimen])-2) As DateOfSpecimen ,Convert(Date,Convert(DateTime,'1900-01-01')+Convert(DateTime,RE.[Date recieved])-2) As DateReceived ,Convert(Date,Convert(DateTime,'1900-01-01')+Convert(DateTime,RE.[Date of report])-2) As DateOfReport ,RE.[Lab report no] As ReportNo ,RE.[Report text] As ReportText FROM [Pathology Results] RE, Episode E Where RE.[Episode No]=E.[Episode No] And RE.[Patient No]=E.[Patient No] 

GO

/* [dbo].[fw_UGI_Consultants] */

Create View [dbo].[fw_UGI_Consultants] WITH SCHEMABINDING As Select 'U.'+Convert(varchar(10),Convert(int,SubString([Consultant/operator ID],7,6))) As ConsultantId, [Consultant/operator] As [ConsultantName], Convert(bit,Case IsNull(UGI.[Suppress],0) When -1 Then 1 Else 0 End) As [Active], Convert(bit,Case UGI.[IsListConsultant] When -1 Then 'TRUE' Else 'FALSE' End) As [IsListConsultant], Convert(bit,Case UGI.[IsEndoscopist1] When -1 Then 'TRUE' Else 'FALSE' End) As [IsEndoscopist1], Convert(bit,Case UGI.[IsEndoscopist2] When -1 Then 'TRUE' Else 'FALSE' End) As [IsEndoscopist2], Convert(bit,Case UGI.[IsAssistantTrainee] When -1 Then 'TRUE' Else 'FALSE' End) As [IsAssistantOrTrainee], Convert(bit,Case UGI.[IsNurse1] When -1 Then 'TRUE' Else 'FALSE' End) As [IsNurse1], Convert(bit,Case UGI.[IsNurse2] When -1 Then 'TRUE' Else 'FALSE' End) As [IsNurse2] From [dbo].[Consultant/Operators] UGI Where Convert(int,SubString([Consultant/operator ID],7,6))<>0 

GO

/* [dbo].[fw_ERS_Consultants] */

Create View [dbo].[fw_ERS_Consultants] WITH SCHEMABINDING As Select 'E.'+Convert(varchar(10),UserID) As ConsultantId, ERS.[Title]+' '+ERS.[Forename]+ ' '+ERS.[Surname] As [Consultant], Convert(bit,Case IsNull(ERS.[Active],0) When 1 Then 1 Else 0 End) As [Active], Convert(bit,Case ERS.[IsListConsultant] When 1 Then 'TRUE' Else 'FALSE' End) As [IsListConsultant], Convert(bit,Case ERS.[IsEndoscopist1] When 1 Then 'TRUE' Else 'FALSE' End) As [IsEndoscopist1], Convert(bit,Case ERS.[IsEndoscopist2] When 1 Then 'TRUE' Else 'FALSE' End) As [IsEndoscopist2], Convert(bit,Case ERS.[IsAssistantOrTrainee] When 1 Then 'TRUE' Else 'FALSE' End) As [IsAssistantOrTrainee], Convert(bit,Case ERS.[IsNurse1] When 1 Then 'TRUE' Else 'FALSE' End) As [IsNurse1], Convert(bit,Case ERS.[IsNurse2] When 1 Then 'TRUE' Else 'FALSE' End) As [IsNurse2] From [dbo].[ERS_Users] ERS 

GO

/* [dbo].[fw_Consultants] */

Create View [dbo].[fw_Consultants] As Select * From fw_UGI_Consultants Union All Select * From fw_ERS_Consultants 

GO

/* [dbo].[fw_UGI_Markings] */

Create View [dbo].[fw_UGI_Markings] WITH SCHEMABINDING As Select 'U.'+Convert(varchar(3),Case When CHARINDEX('1', SUBSTRING(E.[Status], 1, 10))='3' Then IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) Else CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) End)+'.'+Convert(Varchar(10),E.[Episode No])+'.'+Convert(Varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+'.'+convert(varchar(10),CT.[Site No]) As SiteId ,Case When CT.Marking=-1 Then 1 Else 0 End As Marking ,Case CT.[Marking type] When 1 Then 'tattoo' When 2 Then 'dye spray' When 3 Then 'EMR solution' Else '(none)' End As MarkingType ,CT.[Marking number sites] As MarkingNumberSites From [dbo].[Episode] E , [dbo].[Colon Therapeutic] CT Where E.[Episode No]=CT.[Episode No] And E.[Patient No]=CT.[Patient No] /*And CT.Marking=-1 Needed for List report?*/ 

GO

/* [dbo].[fw_ERS_Markings] */

Create View [dbo].[fw_ERS_Markings] WITH SCHEMABINDING As Select 'E.'+Convert(varchar(10),T.SiteId) As SiteId ,T.Marking ,Case T.MarkingType When 1 Then 'tattoo' When 2 Then 'dye spray' When 3 Then 'EMR solution' Else '(none)' End As MarkingType , Case When T.Marking=0 Then 0 Else 1 End As MarkingNumberSites From [dbo].[ERS_UpperGITherapeutics] T 

GO

/* [dbo].[fw_Markings] */

Create View [dbo].[fw_Markings] As Select * From fw_UGI_Markings Union All Select * From fw_ERS_Markings 

GO

/* [dbo].[fw_UGI_Visualization] */

Create View [dbo].[fw_UGI_Visualization] WITH SCHEMABINDING As SELECT 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [dbo].[Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId ,Case V.[Via major to bile duct] When 1 Then 'sucessfull' When 2 Then 'partially successfull' When 3 Then 'not attempted' When 4 Then 'unsuccessfull due to '+Case IsNull([Bile duct unsuccessful due to],0) When 0 Then '(none)' Else '' End Else 'not registered' End As ViaMayorToBileDuct ,Case V.[Via major to pan duct] When 1 Then 'sucessfull' When 2 Then 'partially successfull' When 3 Then 'not attempted' When 4 Then 'unsuccessfull due to '+Case IsNull([Pan duct unsuccessful due to],0) When 0 Then '(none)' Else '' End Else 'not registered' End As ViaMayorToPancreaticDuct ,Case V.[Via minor] When 1 Then 'sucessfull' When 2 Then 'partially successfull' When 3 Then 'not attempted' When 4 Then 'unsuccessfull due to '+Case IsNull([Via minor unsuccessful due to],0) When 0 Then '(none)' Else '' End Else 'not registered' End As ViaMinor ,Case [Access via] When 0 Then 'pylorus' When 1 Then Case [Other access method] When 0 Then '(none)' Else '' End Else '' End As AccessVia ,[Hepatobiliary 1st contrast med vol ml] As Hepatobiliary1stContrastMedVolml ,[Hepatobiliary 2nd contrast med vol ml] As Hepatobiliary2ndContrastMedVolml ,[Pancreatic 1st contrast med vol ml] As Pancreatic1stContrastMedVolml ,[Pancreatic 2nd contrast med vol ml] As Pancreatic2ndContrastMedVolml FROM [dbo].[ERCP Visualisation] V, [dbo].[Episode] E Where V.[Episode No]=E.[Episode No] And V.[Patient No]=E.[Patient No] 

GO

/* [dbo].[fw_Visualization] ojo1*/

CREATE VIEW [dbo].[fw_Visualization] AS SELECT * FROM fw_UGI_Visualization 

GO

/* [dbo].[fw_Insertions] */

Create View [dbo].[fw_Insertions] As Select 'U.1.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6)))+'.'+Convert(VARCHAR(10),S.[Site No]) As SiteId, Case Therapy.[Gastrostomy Insertion (PEG)] When -1 Then 'PEG' Else '' End As [InsertionType], Case Therapy.[Correct PEG/PEJ placement] When 1 Then 1 Else 0 End [Correct_Placement], Case Therapy.[Correct PEG/PEJ placement] When 1 Then 0 Else 1 End [Incorrect_Placement] From [dbo].[Upper GI Procedure] PR , Episode E ,[dbo].[Upper GI Sites] S ,[dbo].[Upper GI Therapeutic] Therapy Where E.[Episode No]=PR.[Episode No] And E.[Patient No]=PR.[Patient No] And E.[Episode No]=S.[Episode No] And E.[Patient No]=S.[Patient No] And Therapy.[Episode No]=S.[Episode No] And Therapy.[Patient No]=S.[Patient No] And Therapy.[Site No]=S.[Site No] And [Gastrostomy Insertion (PEG)]=-1 Union All Select 'E.'+Convert(VARCHAR(10),T.SiteId) As SiteId, Case When T.GastrostomyInsertion=1 Then 'PEG' Else '' END As [InsertionType], Case When T.CorrectPEGPlacement=1 Then 1 Else 0 End As [Correct_Placement], Case When T.CorrectPEGPlacement=1 Then 0 Else 1 End As [Incorrect_Placement] From ERS_UpperGITherapeutics T Where T.GastrostomyInsertion=1 

GO

/* [dbo].[fw_InstrumentTypes] */

Create View [dbo].[fw_InstrumentTypes] As Select 'A' IntrumentTypeId, 'Antegrade' As IntrumentType Union Select 'R' IntrumentTypeId, 'Retrograde' As IntrumentType

GO

/* [dbo].[fw_Instruments] */

Create View [dbo].[fw_Instruments] As Select 'U.3.'+Convert(varchar(10),[List item no]) As InstrumendId, [List item text] As Instrument, 'R' As IntrumentTypeId From Lists Where [List description]='Instrument ColonSig' Union All Select 'U.4.'+Convert(varchar(10),[List item no]) As InstrumendId, [List item text] As Instrument, 'R' As IntrumentTypeId From Lists Where [List description]='Instrument ColonSig' Union All Select 'U.2.'+Convert(varchar(10),[List item no]) As InstrumendId, [List item text] As Instrument, 'R' As IntrumentTypeId From Lists Where [List description]='Instrument ERCP' Union All Select 'U.6.'+Convert(varchar(10),[List item no]) As InstrumendId, [List item text] As Instrument, 'R' As IntrumentTypeId From Lists Where [List description]='Instrument EUS' Union All Select 'U.7.'+Convert(varchar(10),[List item no]) As InstrumendId, [List item text] As Instrument, 'R' As IntrumentTypeId From Lists Where [List description]='Instrument HPB' Union All Select 'U.1.'+Convert(varchar(10),[List item no]) As InstrumendId, [List item text] As Instrument, 'A' As IntrumentTypeId From Lists Where [List description]='Instrument Upper GI' Union All Select 'E.1.'+Convert(varchar(10),ListItemNo) As InstrumentId, ListItemText As Instrument, 'A' As InstrumentType From ERS_Lists Where ListDescription='Instrument Upper GI' Union All Select 'E.2.'+Convert(varchar(10),ListItemNo) As InstrumentId, ListItemText As Instrument, 'R' As InstrumentType From ERS_Lists Where ListDescription='Instrument ERCP' Union All Select 'E.3.'+Convert(varchar(10),ListItemNo) As InstrumentId, ListItemText As Instrument, 'R' As InstrumentType From ERS_Lists Where ListDescription='Instrument ColonSig' Union All Select 'E.4.'+Convert(varchar(10),ListItemNo) As InstrumentId, ListItemText As Instrument, 'R' As InstrumentType From ERS_Lists Where ListDescription='Instrument ColonSig' Union All Select 'E.5.'+Convert(varchar(10),ListItemNo) As InstrumentId, ListItemText As Instrument, 'R' As InstrumentType From ERS_Lists Where ListDescription='Instrument ColonSig' 

GO

/* [dbo].[fw_UGI_QA] */

/*Create View [dbo].[fw_UGI_QA] As /*Colon UGI*/ Select 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '4' Then 5 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId ,Case When QA.[Pat sedation]=4 Then Case QA.[Pat sedation asleep but responding] When 1 Then 4 When 2 Then 5 When 3 Then 6 Else QA.[Pat sedation asleep but responding] End Else QA.[Pat sedation] End As NurseAssPatSedationScore , IsNull(QA.[Pat discomfort],0) As NursesAssPatComfortScore , IsNull(QA.[Pat ass discomfort],0) As PatientsSedationScore , IsNull(Case When QA.[Complications none]=-1 Then 'No complications' Else Replace('Complications:,'+Case When QA.[Damage to scope]=-1 Then ',Damage to scope ('+Case When QA.[Mechanical scope damage]=-1 Then 'mechanical' else 'patient initiated' End+')' +Case When QA.[Poorly tolerated]=-1 Then ', poorly tolerated' Else '' End +Case When QA.Hypoxia=-1 Then ', hypoxia' Else '' End +Case When QA.[Respiratory depression]=-1 Then ', respiratory depression' Else '' End +Case When QA.[Patient discomfort]=-1 Then ', patient discomfort' Else '' End +Case When QA.[Respiratory arrest]=-1 Then ', respiratory arrest requiring' Else '' End +Case When QA.[Patient distress]=-1 Then ', patient distress' Else '' End +Case When QA.[Gastric contents aspiration]=-1 Then ', gastric contents aspiration' Else '' End +Case When QA.[Shock/hypotension]=-1 Then ', shock/hypotension' Else '' End +Case When QA.[Cardiac arrest]=-1 Then ', cardiac arrest' Else '' End +Case When QA.[Failed intubation]=-1 Then ', failed intubation' Else '' End +Case When QA.Haemorrhage=-1 Then ', haemorrhage' Else '' End +Case When QA.[Cardiac arrythmia]=-1 Then ', cardiac arrythmia' Else '' End +Case When QA.[Difficult intubation]=-1 Then ', difficult intubation' Else '' End +Case When QA.[Significant haemorrhage]=-1 Then ', significant haemorrhage requiring transfusion' Else '' End +Case When QA.Death=-1 Then ', dead' Else '' End +Case When QA.Perforation=-1 Then ', '+IsNull(QA.[Perforation text],'') Else '' End +Case When IsNull(QA.[Technical failure],'')<>'' Then ', '+QA.[Technical failure] Else '' End End,',,','') End,'') As Complications , Replace(Replace(Replace(Replace(Replace(Case When (Select Count(*) From [Patient Premedication] PM , [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]=-1)>0 Then (Select Top 1 convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name] From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]=-1)+'(,' +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],0) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],1) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],2) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],3) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],4) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],5) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],6) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],7) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],8) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],9) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +')' Else '' End,',, ',''),'()',''),'0 ',''),', , ',''),', )',')') As ReversalAgents From [Colon Procedure] CP, [Episode] E, [Colon QA] QA Where CP.[Episode No]=E.[Episode No] And QA.[Episode No]=CP.[Episode No] And CP.DNA Is Not Null /*OGD*/ Union All Select 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '4' Then 5 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId ,Case When QA.[Pat sedation]=4 Then Case QA.[Pat sedation asleep but responding] When 1 Then 4 When 2 Then 5 When 3 Then 6 Else QA.[Pat sedation asleep but responding] End Else QA.[Pat sedation] End As NurseAssPatSedationScore , IsNull(QA.[Pat discomfort],0) As NursesAssPatComfortScore , IsNull(QA.[Pat ass discomfort],0) As PatientsSedationScore , IsNull(Case When QA.[Complications none]=-1 Then 'No complications' Else Replace('Complications:,'+Case When QA.[Damage to scope]=-1 Then ',Damage to scope ('+Case When QA.[Mechanical scope damage]=-1 Then 'mechanical' else 'patient initiated' End+')' +Case When QA.[Poorly tolerated]=-1 Then ', poorly tolerated' Else '' End +Case When QA.Hypoxia=-1 Then ', hypoxia' Else '' End +Case When QA.[Respiratory depression]=-1 Then ', respiratory depression' Else '' End +Case When QA.[Patient discomfort]=-1 Then ', patient discomfort' Else '' End +Case When QA.[Respiratory arrest]=-1 Then ', respiratory arrest requiring' Else '' End +Case When QA.[Patient distress]=-1 Then ', patient distress' Else '' End +Case When QA.[Gastric contents aspiration]=-1 Then ', gastric contents aspiration' Else '' End +Case When QA.[Shock/hypotension]=-1 Then ', shock/hypotension' Else '' End +Case When QA.[Cardiac arrest]=-1 Then ', cardiac arrest' Else '' End +Case When QA.[Failed intubation]=-1 Then ', failed intubation' Else '' End +Case When QA.Haemorrhage=-1 Then ', haemorrhage' Else '' End +Case When QA.[Cardiac arrythmia]=-1 Then ', cardiac arrythmia' Else '' End +Case When QA.[Difficult intubation]=-1 Then ', difficult intubation' Else '' End +Case When QA.[Significant haemorrhage]=-1 Then ', significant haemorrhage requiring transfusion' Else '' End +Case When QA.Death=-1 Then ', hypoxia' Else '' End +Case When QA.[Complications other]=-1 Then ', '+IsNull(QA.[Complications other text],'') Else '' End +Case When QA.[Injury to mouth/teeth]=-1 Then ', injury to mouth/teeth' Else '' End +Case When QA.Perforation=-1 Then ', '+IsNull(QA.[Perforation text],'') Else '' End +Case When IsNull(QA.[Technical failure],'')<>'' Then ', '+QA.[Technical failure] Else '' End End,',,','') End,'') As Complications , Replace(Replace(Replace(Replace(Replace(Case When (Select Count(*) From [Patient Premedication] PM , [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]=-1)>0 Then (Select Top 1 convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name] From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]=-1)+'(,' +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],0) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],1) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],2) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],3) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],4) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],5) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],6) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],7) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],8) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],9) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +')' Else '' End,',, ',''),'()',''),'0 ',''),', , ',''),', )',')') As ReversalAgents From [Episode] E , [Upper GI QA] QA Where QA.[Episode No]=E.[Episode No] /*ERCP*/ Union All Select 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '4' Then 5 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId ,Case When QA.[Pat sedation]=4 Then Case QA.[Pat sedation asleep but responding] When 1 Then 4 When 2 Then 5 When 3 Then 6 Else QA.[Pat sedation asleep but responding] End Else QA.[Pat sedation] End As NurseAssPatSedationScore , IsNull(QA.[Pat discomfort],0) As NursesAssPatComfortScore , IsNull(QA.[Pat ass discomfort],0) As PatientsSedationScore , IsNull(Case When QA.[Complications none]=-1 Then 'No complications' Else Replace('Complications:,'+Case When QA.[Damage to scope]=-1 Then ',Damage to scope ('+Case When QA.[Mechanical scope damage]=-1 Then 'mechanical' else 'patient initiated' End+')' +Case When QA.[Poorly tolerated]=-1 Then ', poorly tolerated' Else '' End +Case When QA.Hypoxia=-1 Then ', hypoxia' Else '' End +Case When QA.[Respiratory depression]=-1 Then ', respiratory depression' Else '' End +Case When QA.[Patient discomfort]=-1 Then ', patient discomfort' Else '' End +Case When QA.[Respiratory arrest]=-1 Then ', respiratory arrest requiring' Else '' End +Case When QA.[Patient distress]=-1 Then ', patient distress' Else '' End +Case When QA.[Gastric contents aspiration]=-1 Then ', gastric contents aspiration' Else '' End +Case When QA.[Shock/hypotension]=-1 Then ', shock/hypotension' Else '' End +Case When QA.[Cardiac arrest]=-1 Then ', cardiac arrest' Else '' End +Case When QA.Haemorrhage=-1 Then ', haemorrhage' Else '' End +Case When QA.[Cardiac arrythmia]=-1 Then ', cardiac arrythmia' Else '' End +Case When QA.[Difficult intubation]=-1 Then ', difficult intubation' Else '' End +Case When QA.[Significant haemorrhage]=-1 Then ', significant haemorrhage requiring transfusion' Else '' End +Case When QA.Death=-1 Then ', hypoxia' Else '' End +Case When QA.[Complications other]=-1 Then ', '+IsNull(QA.[Complications other text],'') Else '' End +Case When QA.[Injury to mouth/teeth]=-1 Then ', injury to mouth/teeth' Else '' End +Case When QA.Perforation=-1 Then ', '+IsNull(QA.[Perforation text],'') Else '' End +Case When IsNull(QA.[Technical failure],'')<>'' Then ', '+QA.[Technical failure] Else '' End +Case When QA.[Allergy to medium]=-1 Then ', allergy to medium' Else '' End +Case When QA.[Contrast extravasation]=-1 Then ', contrast extravasation' Else '' End +Case When QA.Arcinarisation=-1 Then ', acinirisation of the parenchyma' Else '' End +Case When QA.[Failed ERC/ERP]=-1 Then ', failed ERC/ERP' Else '' End +Case When QA.[Failed cannulation]=-1 Then ', failed cannulation' Else '' End +Case When QA.[Allergy to medium]=-1 Then ', allergy to medium' Else '' End +Case When QA.[Failed stent insertion]=-1 Then ', failed stent insertion' Else '' End End,',,','') End,'') As Complications , Replace(Replace(Replace(Replace(Replace(Case When (Select Count(*) From [Patient Premedication] PM , [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]=-1)>0 Then (Select Top 1 convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name] From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]=-1)+'(,' +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],0) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],1) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],2) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],3) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],4) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],5) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],6) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],7) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],8) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],9) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +')' Else '' End,',, ',''),'()',''),'0 ',''),', , ',''),', )',')') As ReversalAgents From [Episode] E , [ERCP QA] QA Where QA.[Episode No]=E.[Episode No] */

GO

/* [dbo].[fw_ERS_QA] */

/*Create View [dbo].[fw_ERS_QA] As Select 'E.'+Convert(Varchar(10),NP.ProcedureId) As ProcedureId ,Case When QA.PatSedation=4 Then Case QA.PatSedationAsleepResponseState When 1 Then 4 When 2 Then 5 When 3 Then 6 Else QA.PatSedationAsleepResponseState End Else QA.PatSedation End As NurseAssPatSedationScore , IsNull(QA.PatDiscomfort,0) As NursesAssPatComfortScore , IsNull(QA.PatSedation,0) As PatientsSedationScore , Case When QA.ComplicationsNone=1 Then 'No complications' Else Replace('Complications:' +Case When QA.DamageToScope=1 Then ',Damage to scope ('+Case When QA.DamageToScopeType=0 Then 'mechanical' else 'patient initiated' End+')' Else '' End +Case When QA.PoorlyTolerated=1 Then ', poorly tolerated' Else '' End +Case When QA.Hypoxia=1 Then ', hypoxia' Else '' End +Case When QA.RespiratoryDepression=1 Then ', respiratory depression' Else '' End +Case When QA.PatientDiscomfort=1 Then ', patient discomfort' Else '' End +Case When QA.RespiratoryArrest=1 Then ', respiratory arrest requiring' Else '' End +Case When QA.PatientDistress=1 Then ', patient distress' Else '' End +Case When QA.GastricContentsAspiration=1 Then ', gastric contents aspiration' Else '' End +Case When QA.ShockHypotension=1 Then ', shock/hypotension' Else '' End +Case When QA.CardiacArrest=1 Then ', cardiac arrest' Else '' End +Case When QA.FailedIntubation=1 Then ', failed intubation' Else '' End +Case When QA.Haemorrhage=1 Then ', haemorrhage' Else '' End +Case When QA.CardiacArrythmia=1 Then ', cardiac arrythmia' Else '' End +Case When QA.DifficultIntubation=1 Then ', difficult intubation' Else '' End +Case When QA.SignificantHaemorrhage=1 Then ', significant haemorrhage requiring transfusion' Else '' End +Case When QA.Death=1 Then ', dead' Else '' End +Case When QA.ComplicationsOther=1 Then ', '+QA.ComplicationsOtherText Else '' End +Case When QA.TechnicalFailure<>'' Then ', '+QA.TechnicalFailure Else '' End +Case When QA.Perforation=1 Then ', '+QA.PerforationText Else '' End ,':,',':') End As Complications , Replace(Replace(Replace(Replace(Replace(Case When (Select Count(*) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=1)>0 Then (Select Top 1 convert(varchar(10),PM.Dose)+' '+PM.Units+' '+PM.DrugName From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=1)+'(,' +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,0) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,1) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,2) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,3) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,4) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,5) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,6) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,7) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,8) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,9) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +')' Else '' End,',, ',''),'()',''),'0 ',''),', , ',''),', )',')') As ReversalAgents From ERS_Procedures NP, ERS_UpperGIQA QA Where QA.ProcedureId=NP.ProcedureId */

GO

/* [dbo].[fw_QA] */

/*Create View [dbo].[fw_QA] As /*Colon UGI*/ Select 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '4' Then 5 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId ,Case When QA.[Pat sedation]=4 Then Case QA.[Pat sedation asleep but responding] When 1 Then 4 When 2 Then 5 When 3 Then 6 Else QA.[Pat sedation asleep but responding] End Else QA.[Pat sedation] End As NurseAssPatSedationScore , IsNull(QA.[Pat discomfort],0) As NursesAssPatComfortScore , IsNull(QA.[Pat ass discomfort],0) As PatientsSedationScore , IsNull(Case When QA.[Complications none]=-1 Then 'No complications' Else Replace('Complications:,'+Case When QA.[Damage to scope]=-1 Then ',Damage to scope ('+Case When QA.[Mechanical scope damage]=-1 Then 'mechanical' else 'patient initiated' End+')' +Case When QA.[Poorly tolerated]=-1 Then ', poorly tolerated' Else '' End +Case When QA.Hypoxia=-1 Then ', hypoxia' Else '' End +Case When QA.[Respiratory depression]=-1 Then ', respiratory depression' Else '' End +Case When QA.[Patient discomfort]=-1 Then ', patient discomfort' Else '' End +Case When QA.[Respiratory arrest]=-1 Then ', respiratory arrest requiring' Else '' End +Case When QA.[Patient distress]=-1 Then ', patient distress' Else '' End +Case When QA.[Gastric contents aspiration]=-1 Then ', gastric contents aspiration' Else '' End +Case When QA.[Shock/hypotension]=-1 Then ', shock/hypotension' Else '' End +Case When QA.[Cardiac arrest]=-1 Then ', cardiac arrest' Else '' End +Case When QA.[Failed intubation]=-1 Then ', failed intubation' Else '' End +Case When QA.Haemorrhage=-1 Then ', haemorrhage' Else '' End +Case When QA.[Cardiac arrythmia]=-1 Then ', cardiac arrythmia' Else '' End +Case When QA.[Difficult intubation]=-1 Then ', difficult intubation' Else '' End +Case When QA.[Significant haemorrhage]=-1 Then ', significant haemorrhage requiring transfusion' Else '' End +Case When QA.Death=-1 Then ', dead' Else '' End +Case When QA.Perforation=-1 Then ', '+IsNull(QA.[Perforation text],'') Else '' End +Case When IsNull(QA.[Technical failure],'')<>'' Then ', '+QA.[Technical failure] Else '' End End,',,','') End,'') As Complications , Replace(Replace(Replace(Replace(Replace(Case When (Select Count(*) From [Patient Premedication] PM , [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]=-1)>0 Then (Select Top 1 convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name] From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]=-1)+'(,' +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],0) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],1) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],2) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],3) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],4) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],5) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],6) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],7) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],8) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],9) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +')' Else '' End,',, ',''),'()',''),'0 ',''),', , ',''),', )',')') As ReversalAgents From [Colon Procedure] CP, [Episode] E, [Colon QA] QA Where CP.[Episode No]=E.[Episode No] And QA.[Episode No]=CP.[Episode No] And CP.DNA Is Not Null /*OGD*/ Union All Select 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '4' Then 5 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId ,Case When QA.[Pat sedation]=4 Then Case QA.[Pat sedation asleep but responding] When 1 Then 4 When 2 Then 5 When 3 Then 6 Else QA.[Pat sedation asleep but responding] End Else QA.[Pat sedation] End As NurseAssPatSedationScore , IsNull(QA.[Pat discomfort],0) As NursesAssPatComfortScore , IsNull(QA.[Pat ass discomfort],0) As PatientsSedationScore , IsNull(Case When QA.[Complications none]=-1 Then 'No complications' Else Replace('Complications:,'+Case When QA.[Damage to scope]=-1 Then ',Damage to scope ('+Case When QA.[Mechanical scope damage]=-1 Then 'mechanical' else 'patient initiated' End+')' +Case When QA.[Poorly tolerated]=-1 Then ', poorly tolerated' Else '' End +Case When QA.Hypoxia=-1 Then ', hypoxia' Else '' End +Case When QA.[Respiratory depression]=-1 Then ', respiratory depression' Else '' End +Case When QA.[Patient discomfort]=-1 Then ', patient discomfort' Else '' End +Case When QA.[Respiratory arrest]=-1 Then ', respiratory arrest requiring' Else '' End +Case When QA.[Patient distress]=-1 Then ', patient distress' Else '' End +Case When QA.[Gastric contents aspiration]=-1 Then ', gastric contents aspiration' Else '' End +Case When QA.[Shock/hypotension]=-1 Then ', shock/hypotension' Else '' End +Case When QA.[Cardiac arrest]=-1 Then ', cardiac arrest' Else '' End +Case When QA.[Failed intubation]=-1 Then ', failed intubation' Else '' End +Case When QA.Haemorrhage=-1 Then ', haemorrhage' Else '' End +Case When QA.[Cardiac arrythmia]=-1 Then ', cardiac arrythmia' Else '' End +Case When QA.[Difficult intubation]=-1 Then ', difficult intubation' Else '' End +Case When QA.[Significant haemorrhage]=-1 Then ', significant haemorrhage requiring transfusion' Else '' End +Case When QA.Death=-1 Then ', hypoxia' Else '' End +Case When QA.[Complications other]=-1 Then ', '+IsNull(QA.[Complications other text],'') Else '' End +Case When QA.[Injury to mouth/teeth]=-1 Then ', injury to mouth/teeth' Else '' End +Case When QA.Perforation=-1 Then ', '+IsNull(QA.[Perforation text],'') Else '' End +Case When IsNull(QA.[Technical failure],'')<>'' Then ', '+QA.[Technical failure] Else '' End End,',,','') End,'') As Complications , Replace(Replace(Replace(Replace(Replace(Case When (Select Count(*) From [Patient Premedication] PM , [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]=-1)>0 Then (Select Top 1 convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name] From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]=-1)+'(,' +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],0) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],1) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],2) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],3) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],4) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],5) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],6) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],7) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],8) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],9) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +')' Else '' End,',, ',''),'()',''),'0 ',''),', , ',''),', )',')') As ReversalAgents From [Episode] E , [Upper GI QA] QA Where QA.[Episode No]=E.[Episode No] /*ERCP*/ Union All Select 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '4' Then 5 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId ,Case When QA.[Pat sedation]=4 Then Case QA.[Pat sedation asleep but responding] When 1 Then 4 When 2 Then 5 When 3 Then 6 Else QA.[Pat sedation asleep but responding] End Else QA.[Pat sedation] End As NurseAssPatSedationScore , IsNull(QA.[Pat discomfort],0) As NursesAssPatComfortScore , IsNull(QA.[Pat ass discomfort],0) As PatientsSedationScore , IsNull(Case When QA.[Complications none]=-1 Then 'No complications' Else Replace('Complications:,'+Case When QA.[Damage to scope]=-1 Then ',Damage to scope ('+Case When QA.[Mechanical scope damage]=-1 Then 'mechanical' else 'patient initiated' End+')' +Case When QA.[Poorly tolerated]=-1 Then ', poorly tolerated' Else '' End +Case When QA.Hypoxia=-1 Then ', hypoxia' Else '' End +Case When QA.[Respiratory depression]=-1 Then ', respiratory depression' Else '' End +Case When QA.[Patient discomfort]=-1 Then ', patient discomfort' Else '' End +Case When QA.[Respiratory arrest]=-1 Then ', respiratory arrest requiring' Else '' End +Case When QA.[Patient distress]=-1 Then ', patient distress' Else '' End +Case When QA.[Gastric contents aspiration]=-1 Then ', gastric contents aspiration' Else '' End +Case When QA.[Shock/hypotension]=-1 Then ', shock/hypotension' Else '' End +Case When QA.[Cardiac arrest]=-1 Then ', cardiac arrest' Else '' End +Case When QA.Haemorrhage=-1 Then ', haemorrhage' Else '' End +Case When QA.[Cardiac arrythmia]=-1 Then ', cardiac arrythmia' Else '' End +Case When QA.[Difficult intubation]=-1 Then ', difficult intubation' Else '' End +Case When QA.[Significant haemorrhage]=-1 Then ', significant haemorrhage requiring transfusion' Else '' End +Case When QA.Death=-1 Then ', hypoxia' Else '' End +Case When QA.[Complications other]=-1 Then ', '+IsNull(QA.[Complications other text],'') Else '' End +Case When QA.[Injury to mouth/teeth]=-1 Then ', injury to mouth/teeth' Else '' End +Case When QA.Perforation=-1 Then ', '+IsNull(QA.[Perforation text],'') Else '' End +Case When IsNull(QA.[Technical failure],'')<>'' Then ', '+QA.[Technical failure] Else '' End +Case When QA.[Allergy to medium]=-1 Then ', allergy to medium' Else '' End +Case When QA.[Contrast extravasation]=-1 Then ', contrast extravasation' Else '' End +Case When QA.Arcinarisation=-1 Then ', acinirisation of the parenchyma' Else '' End +Case When QA.[Failed ERC/ERP]=-1 Then ', failed ERC/ERP' Else '' End +Case When QA.[Failed cannulation]=-1 Then ', failed cannulation' Else '' End +Case When QA.[Allergy to medium]=-1 Then ', allergy to medium' Else '' End +Case When QA.[Failed stent insertion]=-1 Then ', failed stent insertion' Else '' End End,',,','') End,'') As Complications , Replace(Replace(Replace(Replace(Replace(Case When (Select Count(*) From [Patient Premedication] PM , [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]=-1)>0 Then (Select Top 1 convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name] From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]=-1)+'(,' +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],0) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],1) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],2) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],3) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],4) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],5) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],6) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],7) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],8) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+D.Units+' '+D.[Drug name],9) Over (Order By PM.[Episode No], PM.[Drug no]) From [Patient Premedication] PM, [Drug list] D Where PM.[Drug No]=D.[Drug No] And PM.[Episode No]=QA.[Episode No] And PM.[Patient No]=E.[Patient No] And D.[Is reversing agent]<>-1),'') +')' Else '' End,',, ',''),'()',''),'0 ',''),', , ',''),', )',')') As ReversalAgents From [Episode] E , [ERCP QA] QA Where QA.[Episode No]=E.[Episode No] Union All /*ERS*/ Select 'E.'+Convert(Varchar(10),NP.ProcedureId) As ProcedureId ,Case When QA.PatSedation=4 Then Case QA.PatSedationAsleepResponseState When 1 Then 4 When 2 Then 5 When 3 Then 6 Else QA.PatSedationAsleepResponseState End Else QA.PatSedation End As NurseAssPatSedationScore , IsNull(QA.PatDiscomfort,0) As NursesAssPatComfortScore , IsNull(QA.PatSedation,0) As PatientsSedationScore , Case When QA.ComplicationsNone=1 Then 'No complications' Else Replace('Complications:' +Case When QA.DamageToScope=1 Then ',Damage to scope ('+Case When QA.DamageToScopeType=0 Then 'mechanical' else 'patient initiated' End+')' Else '' End +Case When QA.PoorlyTolerated=1 Then ', poorly tolerated' Else '' End +Case When QA.Hypoxia=1 Then ', hypoxia' Else '' End +Case When QA.RespiratoryDepression=1 Then ', respiratory depression' Else '' End +Case When QA.PatientDiscomfort=1 Then ', patient discomfort' Else '' End +Case When QA.RespiratoryArrest=1 Then ', respiratory arrest requiring' Else '' End +Case When QA.PatientDistress=1 Then ', patient distress' Else '' End +Case When QA.GastricContentsAspiration=1 Then ', gastric contents aspiration' Else '' End +Case When QA.ShockHypotension=1 Then ', shock/hypotension' Else '' End +Case When QA.CardiacArrest=1 Then ', cardiac arrest' Else '' End +Case When QA.FailedIntubation=1 Then ', failed intubation' Else '' End +Case When QA.Haemorrhage=1 Then ', haemorrhage' Else '' End +Case When QA.CardiacArrythmia=1 Then ', cardiac arrythmia' Else '' End +Case When QA.DifficultIntubation=1 Then ', difficult intubation' Else '' End +Case When QA.SignificantHaemorrhage=1 Then ', significant haemorrhage requiring transfusion' Else '' End +Case When QA.Death=1 Then ', dead' Else '' End +Case When QA.ComplicationsOther=1 Then ', '+QA.ComplicationsOtherText Else '' End +Case When QA.TechnicalFailure<>'' Then ', '+QA.TechnicalFailure Else '' End +Case When QA.Perforation=1 Then ', '+QA.PerforationText Else '' End ,':,',':') End As Complications , Replace(Replace(Replace(Replace(Replace(Case When (Select Count(*) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=1)>0 Then (Select Top 1 convert(varchar(10),PM.Dose)+' '+PM.Units+' '+PM.DrugName From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=1)+'(,' +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,0) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,1) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,2) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,3) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,4) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,5) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,6) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,7) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,8) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +', '+IsNull((Select Top 1 Lead(convert(varchar(10),PM.Dose)+' '+PM.Units+' '+D.DrugName,9) Over (Order By PM.ProcedureId) From ERS_UpperGIPremedication PM, ERS_DrugList D Where PM.DrugNo=D.DrugNo And PM.ProcedureId=QA.ProcedureId And D.IsReversingAgent=0),'') +')' Else '' End,',, ',''),'()',''),'0 ',''),', , ',''),', )',')') As ReversalAgents From ERS_Procedures NP, ERS_UpperGIQA QA Where QA.ProcedureId=NP.ProcedureId */

GO

/* [dbo].[fw_Indications] */

Create View [dbo].[fw_Indications] As Select UP.ProcedureId, UP.IndicationID, TT.Indication, TT.NedName From ( Select 'E.'+Convert(varchar(10),P.ProcedureId) As ProcedureId , Case When UT.AbdominalPain=1 Then 2 End As AbdominalPain , Case When UT.AbnormalityOnBarium=1 Then 3 End As AbnormalityOnBarium , Case When UT.Allergy=1 Then 0 End As Allergy , Case When UT.AllergyDesc=1 Then 0 End As AllergyDesc , Case When UT.Anaemia=1 Then 4 End As Anaemia , Case When UT.Angina=1 Then 1 End As Angina , Case When UT.Asthma=1 Then 1 End As Asthma , Case When UT.BalloonInsertion=1 Then 1 End As BalloonInsertion , Case When UT.BalloonRemoval=1 Then 1 End As BalloonRemoval , Case When UT.BariatricPreAssessment=1 Then 1 End As BariatricPreAssessment , Case When UT.BarrettsOesophagus=1 Then 5 End As BarrettsOesophagus , Case When UT.BiliaryLeak=1 Then 47 End As BiliaryLeak , Case When UT.BreathTest=1 Then 1 End As BreathTest , Case When UT.Cancer=1 Then Case When P.ProcedureType IN (3,4,5) Then 28 End End As Cancer , Case When UT.ChestPain=1 Then 1 End As ChestPain , Case When UT.ChronicLiverDisease=1 Then 1 End As ChronicLiverDisease , Case When UT.CoeliacDisease=1 Then 1 End As CoeliacDisease , Case When UT.CoffeeGroundsVomit=1 Then 12 End As CoffeeGroundsVomit , Case When UT.ColonAbdominalMass=1 Then 25 End As ColonAbdominalMass , Case When UT.ColonAbdominalPain=1 Then 2 End As ColonAbdominalPain , Case When UT.ColonAbnormalBariumEnema=1 Then 1 End As ColonAbnormalBariumEnema , Case When UT.ColonAbnormalCTScan=1 Then 1 End As ColonAbnormalCTScan , Case When UT.ColonAbnormalSigmoidoscopy=1 Then 26 End As ColonAbnormalSigmoidoscopy , Case When UT.ColonAlterBowelHabit=1 Then 1 End As ColonAlterBowelHabit , Case When UT.ColonAnaemia=1 Then 1 End As ColonAnaemia , Case When UT.ColonAssessment=1 Then 1 End As ColonAssessment , Case When UT.ColonBowelCancerScreening=1 Then 1 End As ColonBowelCancerScreening , Case When UT.ColonCarcinoma=1 Then 1 End As ColonCarcinoma , Case When UT.ColonColonicObstruction=1 Then 1 End As ColonColonicObstruction , Case When UT.ColonDysplasia=1 Then 1 End As ColonDysplasia , Case When UT.ColonFamily=1 Then 1 End As ColonFamily , Case When UT.ColonPolyps=1 Then 41 End As ColonPolyps , Case When UT.ColonRectalBleeding=1 Then 40 End As ColonRectalBleeding , Case When UT.ColonSurveillance=1 Then 1 End As ColonSurveillance , Case When UT.ColonSreeningColonoscopy=1 Then 1 End As ColonSreeningColonoscopy , Case When UT.COPD=1 Then 1 End As COPD , Case When UT.DiabetesMellitus=1 Then 1 End As DiabetesMellitus , Case When UT.Dyspepsia=1 Then 7 End As Dyspepsia , Case When UT.Dysphagia=1 Then 8 End As Dysphagia , Case When UT.Epilepsy=1 Then 1 End As Epilepsy From dbo.ERS_Procedures P LEFT OUTER JOIN dbo.ERS_UpperGIIndications UT ON P.ProcedureId = UT.ProcedureId ) As PT UNPIVOT ( IndicationID FOR Therapies IN (AbdominalPain, AbnormalityOnBarium, Allergy, AllergyDesc, Anaemia, Angina, Asthma, BalloonInsertion, BalloonRemoval, BariatricPreAssessment, BarrettsOesophagus , BiliaryLeak, BreathTest, Cancer, ChestPain, ChronicLiverDisease, CoeliacDisease, CoffeeGroundsVomit, ColonAbdominalMass, ColonAbdominalPain, ColonAbnormalBariumEnema, ColonAbnormalCTScan , ColonAbnormalSigmoidoscopy, ColonAlterBowelHabit, ColonAnaemia, ColonAssessment, ColonBowelCancerScreening, ColonCarcinoma, ColonColonicObstruction, ColonDysplasia, ColonFamily , ColonPolyps, ColonRectalBleeding, ColonSurveillance, ColonSreeningColonoscopy, COPD, DiabetesMellitus, Dyspepsia, Dysphagia, Epilepsy) ) As UP LEFT OUTER JOIN ERS_IndicationsTypes TT ON UP.IndicationID=TT.IndicationID Union Select UP.ProcedureId, UP.IndicationID, TT.Indication, TT.NedName From ( Select 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , Case When T.[Abdominal mass]=-1 Then 25 End As AbdominalMass , Case When T.[Abdominal pain]=-1 Then 2 End As AbdominalPain , Case When T.[Abnormal barium enema]=-1 Then 3 End As AbnormalBariumEnema , Case When T.[Abnormal capsule study]=-1 Then 1 End As AbnormalCapsuleStudy , Case When T.[Abnormal MRI]=-1 Then 1 End As AbnormalMRI , Case When T.[Abnormal sigmoidoscopy]=-1 Then 26 End As AbnormalSigmoidoscopy , Case When T.AbnormalCTScan=-1 Then 1 End As AbnormalCTScan , Case When T.Allergy=-1 Then 1 End As Allergy , Case When T.[Altered bowel habit]=-1 Then 1 End As AlteredBowelHabit , Case When T.[Amsterdam criteria]=-1 Then 1 End As AmsterdamCriteria , Case When T.Anaemia=-1 Then 4 End As Anaemia , Case When T.Cancer=-1 Then 28 End As Cancer , Case When T.[Colitis assessment]=-1 Then 1 End As ColitisAssessment , Case When T.[Colitis surveillance]=-1 Then 1 End As ColitisSurveillance , Case When T.[Colonic obstruction]=-1 Then 1 End As ColonicObstruction , Case When T.FOBT=-1 Then 1 End As FOBT , Case When T.Melaena=-1 Then 11 End As Melaena , Case When T.[Polyposis syndrome]=-1 Then 38 End As PolyposisSindrome , Case When T.[Potentially damaging drug]=-1 Then 1 End As PotentiallyDamageDrug , Case When T.[Rectal bleeding]=-1 Then 40 End As RectalBleeding , Case When T.StentInsertion=-1 Then 19 End As StentInsertion , Case When T.StentRemoval=-1 Then 20 End As StentRemoval , Case When T.StentReplacement=-1 Then 18 End As StentReplacement , Case When T.[Tumour assessment]=-1 Then 42 End As TumourAssessment , Case When T.[Weight loss]=-1 Then 23 End As WeightLoss From Episode E LEFT OUTER JOIN [Colon Indications] T ON T.[Episode No]=E.[Episode No] And T.[Patient No]=E.[Patient No] ) As PT UNPIVOT ( IndicationID FOR Therapies IN (AbdominalMass, AbdominalPain, AbnormalBariumEnema, AbnormalCapsuleStudy, AbnormalMRI, AbnormalSigmoidoscopy, Allergy, AlteredBowelHabit , AmsterdamCriteria, Anaemia, Cancer, ColitisAssessment, ColitisSurveillance, ColonicObstruction, FOBT, Melaena, PolyposisSindrome, PotentiallyDamageDrug, RectalBleeding , StentInsertion, StentRemoval, StentReplacement, TumourAssessment, WeightLoss) ) As UP LEFT OUTER JOIN ERS_IndicationsTypes TT ON UP.IndicationID=TT.IndicationID Union Select UP.ProcedureId, UP.IndicationID, TT.Indication, TT.NedName From ( Select 'U.'+Convert(varchar(3),Case CHARINDEX('1', SUBSTRING(E.[Status], 1, 10)) When '1' Then 1 When '2' Then 2 When '5' Then 6 When '6' Then 7 Else Case IsNull((Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And X.[Procedure date] Is Not Null),0) When 0 Then (Select TOP 1 Convert(varchar(1),X.[Procedure type]+3) From [Colon Procedure] X Where X.[Episode No]=E.[Episode No] And (X.[Procedure date] Is Not Null) Or X.[Time of procedure] Is Not Null) When 3 Then 3 When 4 Then 4 When 5 Then 5 Else 0 End End)+'.'+Convert(varchar(10),E.[Episode no])+'.'+Convert(varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , Case When T.[Abnormal capsule study]=-1 Then 1 End As AbnormalCapsuleStudy , Case When T.[Abdominal pain]=-1 Then 2 End As AbdominalPain , Case When T.[Abnormal MRI]=-1 Then 1 End As AbnormalMRI , Case When T.Allergy=-1 Then 1 End As Allergy , Case When T.Aneamia=-1 Then 4 End As Anaemia , Case When T.Cancer=-1 Then 28 End As Cancer , Case When T.[Chest pain]=-1 Then 1 End As ChestPain , Case When T.[Chronic liver disease]=-1 Then 1 End As ChronicLiverDisease , Case When T.[Coeliac disease]=-1 Then 1 End As CoeliacDisease , Case When T.[Coffee grounds vomit]=-1 Then 12 End As CofeeGroundsVomit , Case When T.Melaena=-1 Then 11 End As Melaena , Case When T.Diarrhoea=-1 Then 6 End As Diarrhoea , Case When T.[Potentially damaging drug]=-1 Then 1 End As PotentiallyDamageDrug , Case When T.[Double balloon enteroscopy]=-1 Then 1 End As DoubleBalloonEnteroscopy , Case When T.StentInsertion=-1 Then 19 End As StentInsertion , Case When T.StentRemoval=-1 Then 20 End As StentRemoval , Case When T.StentReplacement=-1 Then 18 End As StentReplacement , Case When T.[Balloon Insertion]=-1 Then 1 End As BalloonInsertion , Case When T.[Weight loss]=-1 Then 23 End As WeightLoss , Case When T.[Balloon Removal]=-1 Then 1 End As BalloonRemoval , Case When T.[Bariatric pre-assessment]=-1 Then 1 End As BariatricPreAssessment , Case When T.[Barrett's oesophagus]=-1 Then 5 End As BarretsOesophagus , Case When T.[Breath test]=-1 Then 1 End As BreathTest , Case When T.[Drug trial]=-1 Then 1 End As DrugTrial , Case When T.[Previous surgery]=-1 Then 1 End As PreviousSurgery , Case When T.[Previous examination]=-1 Then 1 End As PreviousExamination , Case When T.Haematemesis=-1 Then 9 End As Haematemesis , Case When T.[Insertion of pH probe]=-1 Then 1 End As InsertionOfpHProbe , Case When T.[Jejunostomy insertion]=-1 Then 1 End As JejunostomyInsertion , Case When T.Dysphagia=-1 Then 8 End As Dysphagia , Case When T.Dyspepsia=-1 Then 7 End As Dyspepsia , Case When T.[Nasoduodenal tube]=-1 Then 1 End As NasoduodenalTube , Case When T.[Nausea and or vomiting]=-1 Then 12 End As NauseaAndOrVomiting , Case When T.Odynophagia=-1 Then 13 End As Odynophagia , Case When T.[Oeso dilatation]=-1 Then 1 End As OesoDilatation , Case When T.[Oesophageal varices]=-1 Then 1 End As OesoVarices , Case When T.Oesophagitis=-1 Then 1 End As Oesophagitis , Case When T.[PEG removal]=-1 Then 16 End As PEGRemoval , Case When T.[PEG replacement]=-1 Then 14 End As PEGReplacement , Case When T.[Post bariatric surgery assessment]=-1 Then 1 End As PostBariatricSurgeryAssessment , Case When T.[Potentially damaging drug]=-1 Then 1 End As PotentiallyDamagingDrug , Case When T.[Push enteroscopy]=-1 Then 1 End As PushEnteroscopy , Case When T.[Reflux symptoms]=-1 Then 1 End As RefluxSymptoms , Case When T.[Serology test]=-1 Then 1 End As SerologyTest , Case When T.[Single balloon enteroscopy]=-1 Then 1 End As SingleBalloonEnteroscopy , Case When T.[Small bowel biopsy]=-1 Then 1 End As SmallBowelBiopsy , Case When T.[stool antigen test]=-1 Then 1 End As StoolAntigenTest , Case When T.[Surgery follow up proc]=-1 Then 1 End As SurgeryFollowUpProc , Case When T.[Ulcer exclusion]=-1 Then 1 End As UlcerExclusion , Case When T.[Urease test]=-1 Then 1 End As UreaseTest From Episode E LEFT OUTER JOIN [Upper GI Indications] T ON T.[Episode No]=E.[Episode No] And T.[Patient No]=E.[Patient No] ) As PT UNPIVOT ( IndicationID FOR Therapies IN (AbnormalCapsuleStudy, AbdominalPain, AbnormalMRI, Allergy, Anaemia, Cancer, ChestPain, ChronicLiverDisease, CoeliacDisease, CofeeGroundsVomit , Melaena, Diarrhoea, PotentiallyDamageDrug, DoubleBalloonEnteroscopy, StentInsertion, StentRemoval, StentReplacement, BalloonInsertion, WeightLoss, BalloonRemoval , BariatricPreAssessment, BarretsOesophagus, BreathTest, DrugTrial, PreviousSurgery, PreviousExamination, InsertionOfpHProbe, JejunostomyInsertion, Dysphagia, Dyspepsia , NasoduodenalTube, NauseaAndOrVomiting, Odynophagia, OesoDilatation, OesoVarices, Oesophagitis, PEGRemoval, PEGReplacement, PostBariatricSurgeryAssessment , PotentiallyDamagingDrug, PushEnteroscopy, RefluxSymptoms, SerologyTest, SingleBalloonEnteroscopy, SmallBowelBiopsy, StoolAntigenTest, SurgeryFollowUpProc, UlcerExclusion , UreaseTest) ) As UP LEFT OUTER JOIN ERS_IndicationsTypes TT ON UP.IndicationID=TT.IndicationID 

GO

/* [dbo].[fw_Drugs] */

Create View [dbo].[fw_Drugs] As Select D.DrugNo As DrugId, D.DrugName, IsNull(D.DeliveryMethod,'') As DeliveryMethod, IsNull(D.Units,'') As Units , D.DefaultDose, D.DoseIncrement, D.IsReversingAgent From ERS_DrugList D 

GO

/* [dbo].[fw_ColonExtentOfIntubation] */

Create View [dbo].[fw_ColonExtentOfIntubation] As Select 'U.'+Convert(varchar(3),CP.[Procedure type]+3)+'.'+Convert(varchar(10),E.[Episode No])+'.'+Convert(Varchar(10),Convert(Int,SubString(E.[Patient No],7,6))) As ProcedureId , 1 As Insertion , Case EL.[Insertion complete] When -1 Then 1 Else 0 End As InsertionComplete , Case EL.[Insertion to caecum] When -1 Then 1 Else 0 End As InsertionToCaecum , Case EL.[Insertion to terminal ilium] When -1 Then 1 Else 0 End As InsertionToTerminalIleum , Case EL.[Insertion to neo-terminal ilium] When -1 Then 1 Else 0 End As InsertionToNeoTerminalIleum , Case EL.[Insertion to anastomosis] When -1 Then 1 Else 0 End As InsertionToAnastomosis , 1-Case EL.[Insertion complete] When -1 Then 1 Else 0 End-Case EL.[Insertion to caecum] When -1 Then 1 Else 0 End-Case EL.[Insertion to terminal ilium] When -1 Then 1 Else 0 End-Case EL.[Insertion to neo-terminal ilium] When -1 Then 1 Else 0 End-Case EL.[Insertion to anastomosis] When -1 Then 1 Else 0 End As InsertionFailed , Case EL.[Insertion via] When 0 Then 'anus' When 1 Then 'colostomy' When 2 Then 'loop colostomy' When 3 Then 'caecostomy' When 4 Then 'ileostomy' Else '' End As InsertionVia , Case EL.[Rectal exam (PR)] When 1 Then 'Not done' Else 'Done' End As RectalExam , Case EL.[Retroflexion in rectum] When 1 then 'Not done' Else 'Done' End As Retroflexion , Case When EL.[Specific distance]=-1 Then 'Specific distance' Else '' End +Case When EL.[Insertion not recorded]=-1 Then 'Not recorded' Else '' End +Case When EL.[Insertion complete]=-1 Then 'Complete' Else '' End +Case When EL.[Insertion to proximal sigmoid]=-1 Then 'Proximal sigmoid' Else '' End +Case When EL.[Insertion to mid transverse]=-1 Then 'Mid transverse' Else '' End +Case When EL.[Insertion to caecum]=-1 Then 'Caecum' Else '' End +Case When EL.[Insertion to distal descending]=-1 Then 'Distal descending' Else '' End +Case When EL.[Insertion to proximal transverse]=-1 Then 'Proximal transverse' Else '' End +Case When EL.[Insertion to terminal ilium]=-1 Then 'Terminal ileum' Else '' End +Case When EL.[Insertion to rectum]=-1 Then 'Rectum' Else '' End +Case When EL.[Insertion to proximal descending]=-1 Then 'Proximal descending' Else '' End +Case When EL.[Insertion to hepatic flexure]=-1 Then 'Hepatic flexure' Else '' End +Case When EL.[Insertion to terminal ilium]=-1 Then 'Neo-terminal ileum' Else '' End +Case When EL.[Insertion to recto sigmoid]=-1 Then 'Recto-sigmoid' Else '' End +Case When EL.[Insertion to splenic flexure]=-1 Then 'Splenic flexure' Else '' End +Case When EL.[Insertion to distal ascending]=-1 Then 'Distal ascending' Else '' End +Case When EL.[Insertion to distal sigmoid]=-1 Then 'Distal sigmoid' Else '' End +Case When EL.[Insertion to distal transverse]=-1 Then 'Distal transverse' Else '' End +Case When EL.[Insertion to proximal ascending]=-1 Then 'Proximal ascending' Else '' End +Case When EL.[Insertion to anastomosis]=-1 Then 'Anastomosis' Else '' End As InsertedTo , EL.[Specific distance] As EspecificDistance , Case EL.[Insertion confirmed by] When 0 Then '(none)' When 1 Then 'Photo' When 2 Then 'Anastamosis' When 3 Then 'Tri radiate fold' When 4 Then 'Ileocaecal valve' Else '' End As ConfirmedBy , Case EL.[Insertion limited by] When 0 Then '(none)' When 1 Then 'patient discomfort' When 2 Then 'inadequate bowel preparation' When 3 Then 'excess looping' When 4 Then 'bowel redundancy' When 5 Then 'instrument inadequacy' When 6 Then 'pathology encountered' When 7 Then 'excess blood' Else '' End As LimitedBy , Case EL.[Difficulties encountered] When 0 Then '(none)' When 1 Then 'Deep seated caecum' When 2 Then 'tortuous colon' Else '' End As DifficultiesEncountered From [Colon Extent/Limiting Factors] EL, Episode E, [Colon Procedure] CP Where EL.[Episode No]=E.[Episode No] And EL.[Patient No]=E.[Patient No] And E.[Episode No]=CP.[Episode No] And E.[Patient No]=CP.[Patient No] And CP.[Procedure date] Is Not Null Union All Select 'E.'+Convert(varchar(10),EI.ProcedureId) As ProcedureId , 1 As Insertion , Case When EI.InsertionTo In (6,5,9,13,15) Then 1 Else 0 End As InsertionComplete , Case When EI.InsertionTo=5 Then 1 Else 0 End As InsertionToCaecum , Case When EI.InsertionTo=9 Then 1 Else 0 End As InsertionToTerminalIleum , Case When EI.InsertionTo=13 Then 1 Else 0 End As InsertionToNeoTerminalIleum , Case When EI.InsertionTo=15 Then 1 Else 0 End As InsertionToAnastomosis , 1-Case When EI.InsertionTo=6 Then 1 Else 0 End-Case When EI.InsertionTo=5 Then 1 Else 0 End-Case When EI.InsertionTo=9 Then 1 Else 0 End-Case When EI.InsertionTo=13 Then 1 Else 0 End-Case When EI.InsertionTo=15 Then 1 Else 0 End As InsertionFailed , Case EI.InsertionVia When 1 Then 'anus' When 2 Then 'colostomy' When 3 Then 'loop colostomy' When 4 Then 'caecostomy' When 5 Then 'ileostomy' Else'' End As InsertionVia , Case EI.RectalExam When 0 Then 'Not done' Else 'Done' End As RectalExam , Case EI.Retroflexion When 0 Then 'Not done' Else 'Done' End As Retroflexion , Case EI.InsertionTo When 1 then 'Specific distance' When 2 then 'Not recorded' When 3 then 'Proximal sigmoid' When 4 then 'Mid transverse ' When 5 then 'Caecum' When 6 then 'Complete' When 7 then 'Distal descending' When 8 then 'Proximal transverse' When 9 then 'Terminal ileum' When 10 then 'Rectum' When 11 then 'Proximal descending' When 12 then 'Hepatic flexure' When 13 then 'Neo-terminal ileum' When 14 then 'Recto-sigmoid' When 15 then 'Splenic flexure' When 16 then 'Distal ascending' When 17 then 'Distal sigmoid' When 18 then 'Distal transverse' When 19 then 'Proximal ascending' When 20 then 'Anastomosis' End As InsertedTo , EI.SpecificDistanceCm As EspecificDistance , Case EI.InsertionConfirmedBy When 0 Then '(none)' Else '' End As ConfirmedBy , Case EI.InsertionLimitedBy When 0 Then '(none)' When 1 Then 'bowel redundancy' When 2 Then 'excess blood' When 3 Then 'excess looping' When 4 Then 'inadequate bowel preparation' When 5 Then 'instrument inadequacy' When 6 Then 'pathology encountered' When 7 Then 'excess blood' Else '' End AS LimitedBy , Case EI.DifficultiesEncountered When 0 Then '(none)' When 1 Then 'Deep seated caecum' When 2 Then 'tortuous colon' Else '' End As DifficultiesEncountered From ERS_ColonExtentOfIntubation EI, ERS_Procedures PR Where EI.ProcedureId=PR.ProcedureId 

GO

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

If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[NED_Adverse]')) Drop View [dbo].[NED_Adverse]
Go

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
Go

If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_NED]')) Drop Proc [dbo].[sp_NED]
Go
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
		INNER JOIN dbo.Patient P ON PR.PatientId=P.[Patient No]
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
	FROM dbo.ERS_Procedures PR INNER JOIN dbo.Patient P ON PR.PatientId=P.[Patient No]
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
		, CASE WHEN IsNull(RT.NedName,'None')<>'None' THEN Case When polypSize<10 Then 'ItemLessThan10mm' Else Case When polypSize>10 And polypSize<10 Then 'Item10to19mm' Else 'Item20OrLargermm' End End END As [therapeutic!10!polypSize]
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
	LEFT OUTER JOIN [dbo].[ERS_ColonExtentOfIntubation] L ON L.ProcedureId=PR.ProcedureId --oJo
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
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[PAS_ImportPatient]')) Drop Proc [dbo].[PAS_ImportPatient]
Go
CREATE PROCEDURE PAS_ImportPatient
	@CNN NVARCHAR(50)=NULL
	, @ServerName NVARCHAR(128)='ERS_PAS'
	, @PASDatabase NVARCHAR(128)='PASData'
	, @ProductID NVARCHAR(2)='GI'
	, @LocationID NVARCHAR(4)='_ERS'
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @sql NVARCHAR(MAX)
	IF @CNN IS NULL
	BEGIN
		RAISERROR('Error at PAS_ImportPatient. No Case note No was indicated',11,1)
	END
	ELSE
	BEGIN
		Set @sql = 'Insert Into [dbo].[Patient] ([Surname],[Date of birth],[Case note no], [Product ID],[Forename],[NHS No], [Location ID], [Just downloaded], [District], Gender, [Post code], [GP Name], [GP Address], [GP referral flag], [Address], [Record created], [Ethnic origin], [Patient status 1], [Patient status 2], [Advocate required]) Select RTRIM(LTRIM(last_name)) As [Surname], SubString(dob,7,4)+''-''+SubString(dob,4,2)+''-''+SubString(dob,1,2) As [Date of birth], RTRIM(LTRIM(main_pat_id)) As [Case note no], '''+@ProductID+''' As [Product ID], RTRIM(LTRIM(first_name)) As [Forename], RTRIM(LTRIM(nhs_number)) As [NHS No], '''+@LocationID+''' As [Location ID], -1 As [Just downloaded], pat_addr3 As [District], UPPER(SubString(gender,1,1)) As Gender, postcode As [Post code], IsNull(gp_title+'' '','''')+isnull(gp_forename+'' '','''')+isnull(gp_surname,'''') [GP Name], IsNull(gp_addr1+'' '','''')+IsNull(gp_addr2+'' '','''')+IsNull(gp_addr3+'' '','''')+IsNull(gp_addr4+'' '','''')+IsNull(gp_postcode+'' '','''') As [GP Address], 0 As [GP referral flag], IsNull(gp_addr1+'' '','''')+IsNull(gp_addr2+'' '','''')+IsNull(gp_addr3+'' '','''')+IsNull(gp_addr4+'' '','''') As [Address], GetDate () As [Record created], -1 As [Ethnic origin], 0 As [Patient status 1], 0 As [Patient status 2], 0 As [Advocate required] From '+@ServerName+'.'+@PASDatabase+'.dbo.[PAS data] Where main_pat_id='''+@CNN+''''
		BEGIN TRY
			EXEC (@SQL)
		END TRY
		BEGIN CATCH
			RAISERROR('Error at PAS_ImportPatient. The patient does exists',11,1)
		END CATCH
		Set @sql='UPDATE [dbo].[Patient] SET [Combo ID] = ''GI_ERS'' + Replicate(''0'',6-Len(CONVERT(VARCHAR(7),[Patient No])))+CONVERT(VARCHAR(7),[Patient No]) WHERE [Case note no]=''' + @CNN + ''''
		EXEC (@SQL)
		PRINT Convert(varchar(10),@@ROWCOUNT)+' rows updated'
	END
END
GO
IF exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[PAS_LinkOn]')) DROP PROC [dbo].[PAS_LinkOn]
Go
CREATE PROCEDURE [dbo].[PAS_LinkOn]
	@ServerName NVARCHAR(128)='UMPT'
	,@ServerHost NVARCHAR(128)='.'
	,@IntegratedSecurity NVARCHAR='False'
	,@PASDatabase NVARCHAR(128)='PASData'
	,@PASUser NVARCHAR(128)=''
	,@PASPassword NVARCHAR(128)=''
As
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	IF (SELECT Convert(BIT,(SELECT Count(*) AS N FROM sys.servers WHERE name=@ServerName)) AS IsLinked)=1
	BEGIN
		PRINT 'The Virtual Server is still enabled'
	END
	ELSE
	BEGIN
		IF UPPER(@IntegratedSecurity)='TRUE'
		BEGIN
			SET @sql='EXEC sp_addlinkedserver @server='''+@ServerName+''', @srvproduct='''', @provider=''sqlncli'', @datasrc='''+@ServerHost+''', @location='', @provstr='', @catalog='''+@PASDatabase+''''
			EXEC (@SQL)
			SET @sql='EXEC sp_addlinkedsrvlogin @rmtsrvname = '''+@ServerName+''', @useself = ''false'', @useself=''TRUE'''
		END
		ELSE
		BEGIN
			SET @sql='EXEC sp_addlinkedserver @server='''+@ServerName+''', @srvproduct='''', @provider=''sqlncli'', @datasrc='''+@ServerHost+''', @location='', @provstr='', @catalog='''+@PASDatabase+''''
			EXEC (@SQL)
			SET @sql='EXEC sp_addlinkedsrvlogin @rmtsrvname = '''+@ServerName+''', @useself = ''false'', @rmtuser = '''+@PASUser+''', @rmtpassword = '''+@PASPassword+''''			
		END
	END
END
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[PAS_Replicate]')) Drop Proc [dbo].[PAS_Replicate]
Go
CREATE PROCEDURE [dbo].[PAS_Replicate]
	@PatientId INT
	, @CNN NVARCHAR(50)
	, @ServerName NVARCHAR(128)='ERS_PAS'
	, @PASDatabase NVARCHAR(128)='PASData'
	, @PASTable NVARCHAR(128)='[dbo].[PAS Data]'
	, @ProductID NVARCHAR(2)='GI'
	, @LocationID NVARCHAR(4)='_ERS'
AS
BEGIN
	Declare @sql NVARCHAR(max)
	Declare @ServerDB NVARCHAR(256)
	Set @ServerDB=@ServerName+'.'+@PASDatabase+'.'+@PASTable
	Set @sql='Update Patient Set [NHS No]=Q.nhs_number From '+@ServerDB+' Q Where [Case note no]=Q.main_pat_id And [NHS No]<>Q.nhs_number And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
	Exec (@sql)
	Set @sql='Update Patient Set [Surname]=Q.last_name From '+@ServerDB+' Q Where [Case note no]=Q.main_pat_id And [Surname]<>Q.last_name And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
	Exec (@sql)
	Set @sql='Update Patient Set [Date of birth]=Convert(datetime,SubString(dob,7,4)+''-''+SubString(dob,4,2)+''-''+SubString(dob,1,2)) Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And Convert(date,[Date of birth])<>Convert(date,SubString(dob,7,4)+''-''+SubString(dob,4,2)+''-''+SubString(dob,1,2)) And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
	Exec (@sql)
	Set @sql='Update Patient Set Forename=Q.first_name Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And Forename<>Q.first_name And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
	Exec (@sql)
	Set @sql='Update Patient Set District=Q.pat_addr2 Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And District<>Q.pat_addr2 And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
	Exec (@sql)
	Set @sql='Update Patient Set Patient.Gender=UPPER(SubString(Q.gender,1,1)) Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And Patient.Gender<>UPPER(SubString(Q.gender,1,1)) And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
	Exec (@sql)
	Set @sql='Update Patient Set [Address]=Q.pat_addr1 Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And [Address]<>Q.pat_addr1 And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
	Exec (@sql)
	Set @sql='Update Patient Set [Post code]=UPPER(Q.postcode) Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And [Post code]<>UPPER(Q.postcode) And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
	Exec (@sql)
	Set @sql='Update Patient Set [GP Name]=IsNull(Q.gp_title,'''')+IsNull('' ''+Q.gp_forename,'''')+IsNull('' ''+Q.gp_surname,'''') Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And [GP Name]<>IsNull(Q.gp_title,'''')+IsNull('' ''+Q.gp_forename,'''')+IsNull('' ''+Q.gp_surname,'''') And Q.gp_surname Is Not Null And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
	Exec (@sql)
	Set @sql='Update Patient Set [Date of death]=Convert(datetime,SubString(Q.date_of_death,7,4)+''-''+SubString(Q.date_of_death,4,2)+''-''+SubString(Q.date_of_death,1,2)) Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And Convert(date,[Date of birth])<>Convert(date,SubString(Q.date_of_death,7,4)+''-''+SubString(Q.date_of_death,4,2)+''-''+SubString(Q.date_of_death,1,2)) And Q.date_of_death Is Not Null And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
	Exec (@sql)
	Set @sql='Update Patient Set [Phone No]=Q.homephone Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And [Phone No]<>Q.homephone And Q.homephone Is Not Null And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
	Exec (@sql)
	Set @sql='Update Patient Set [GP Address]=Q.gp_addr1 Q From '+@ServerDB+' Where [Case note no]=Q.main_pat_id And [GP Address]<>Q.gp_addr1 And Q.gp_addr1 Is Not Null And [Case note no]='''+@CNN+''' And [Patient No]='+CONVERT(VARCHAR(10),@PatientId)
	Exec (@sql)
END
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[PAS_UpdatePatient]')) Drop Proc [dbo].[PAS_UpdatePatient]
Go
CREATE PROCEDURE PAS_UpdatePatient
	@CNN NVARCHAR(50)
	, @PatientId NVARCHAR(50)=''
	, @ServerName NVARCHAR(128)='ERS_PAS'
	, @PASDatabase NVARCHAR(128)='PASData'
	, @ProductID NVARCHAR(2)='GI'
	, @LocationID NVARCHAR(4)='_ERS'
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @sql NVARCHAR(MAX)
	--Set @sql = 'Insert Into [dbo].[Patient] ([Surname],[Date of birth],[Case note no], [Product ID],[Forename],[NHS No], [Location ID], [Just downloaded], [District], Gender, [Post code], [GP Name], [GP Address], [GP referral flag], [Address], [Record created], [Ethnic origin], [Patient status 1], [Patient status 2], [Advocate required]) Select RTRIM(LTRIM(last_name)) As [Surname], SubString(dob,7,4)+''-''+SubString(dob,4,2)+''-''+SubString(dob,1,2) As [Date of birth], RTRIM(LTRIM(main_pat_id)) As [Case note no], '''+@ProductID+''' As [Product ID], RTRIM(LTRIM(first_name)) As [Forename], RTRIM(LTRIM(nhs_number)) As [NHS No], '''+@LocationID+''' As [Location ID], -1 As [Just downloaded], pat_addr3 As [District], UPPER(SubString(gender,1,1)) As Gender, postcode As [Post code], IsNull(gp_title+'' '','''')+isnull(gp_forename+'' '','''')+isnull(gp_surname,'''') [GP Name], IsNull(gp_addr1+'' '','''')+IsNull(gp_addr2+'' '','''')+IsNull(gp_addr3+'' '','''')+IsNull(gp_addr4+'' '','''')+IsNull(gp_postcode+'' '','''') As [GP Address], 0 As [GP referral flag], IsNull(gp_addr1+'' '','''')+IsNull(gp_addr2+'' '','''')+IsNull(gp_addr3+'' '','''')+IsNull(gp_addr4+'' '','''') As [Address], GetDate () As [Record created], -1 As [Ethnic origin], 0 As [Patient status 1], 0 As [Patient status 2], 0 As [Advocate required] From '+@ServerName+'.'+@PASDatabase+'.dbo.[PAS data] Where main_pat_id='''+@CNN+''''
	Set @sql='Update [dbo].[Patient] Set [Surname]=RTRIM(LTRIM(last_name))'
	Set @sql=@sql+' ,[Date of birth]=SubString(dob,7,4)+''-''+SubString(dob,4,2)+''-''+SubString(dob,1,2)'
	Set @sql=@sql+' ,[Forename]=RTRIM(LTRIM(first_name))'
	Set @sql=@sql+' , [District]=pat_addr3'
	Set @sql=@sql+' , Gender=IsNull(UPPER(SubString(U.gender,1,1)),'''')'
	Set @sql=@sql+' , [Post code]=postcode'
	Set @sql=@sql+' , [GP Name]=IsNull(gp_title+'' '','''')+isnull(gp_forename+'' '','''')+isnull(gp_surname,'''')'
	Set @sql=@sql+' , [GP Address]=IsNull(gp_addr1+'' '','''')+IsNull(gp_addr2+'' '','''')+IsNull(gp_addr3+'' '','''')+IsNull(gp_addr4+'' '','''')'
	Set @sql=@sql+' , [Address]=IsNull(pat_addr1+'' '','''')+IsNull(pat_addr2+'' '','''')+IsNull(pat_addr3+'' '','''')+IsNull(pat_addr4+'' '','''')'
	Set @sql=@sql+' From '+@ServerName+'.'+@PASDatabase+'.dbo.[PAS data] U Where [Case note no]=main_pat_id And main_pat_id='''+@CNN+''''
	If @PatientId<>'' Set @sql=@sql+' And [Patient No]='+@PatientId
	PRINT @sql
	BEGIN TRY
		EXEC (@sql)
	END TRY
	BEGIN CATCH
		RAISERROR('Error at PAS_UpdatePatient.',11,1)
		PRINT @sql
	END CATCH
	PRINT Convert(varchar(10),@@ROWCOUNT)+' rows updated'
END
GO
