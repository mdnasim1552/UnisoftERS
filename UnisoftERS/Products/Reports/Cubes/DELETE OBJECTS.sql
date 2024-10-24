/* REMARKS */
/* Consolidated report V 2.1 */
/* There are still some scripts not compatible with SQL Server 2008 */
/* Splitting of some scripts between ERS and UGI is in progress */
/* Customized setup for ERS And/Or/Xor UGI version is still pending */
/*------------------------------Reporting Consolidated Script------------------------------*/
/*------------------------------   BEGIN OF HUSSEIN'S PART   ------------------------------*/
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
IF @@ERROR <> 0 SET NOEXEC ON
GO
BEGIN TRANSACTION
IF @@ERROR <> 0 SET NOEXEC ON
GO

Set NOCOUNT ON
/* FUNCTIONS */
If exists (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnPatientsPercentile50]')) DROP FUNCTION [dbo].[fnPatientsPercentile50]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnDrugsPercentile50]')) DROP FUNCTION [dbo].[fnDrugsPercentile50]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnPremedication]')) DROP FUNCTION [dbo].[fnPremedication]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnComplication]')) DROP FUNCTION [dbo].[fnComplication]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* STORED PROCEDURES */
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSC08]')) Drop Proc [dbo].[sp_rep_GRSC08]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSC07]')) Drop Proc [dbo].[sp_rep_GRSC07]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSC06]')) Drop Proc [dbo].[sp_rep_GRSC06]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSC05]')) Drop Proc [dbo].[sp_rep_GRSC05]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSC04]')) Drop Proc [dbo].[sp_rep_GRSC04]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSC03]')) Drop Proc [dbo].[sp_rep_GRSC03]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSC02]')) Drop Proc [dbo].[sp_rep_GRSC02]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSC01]')) Drop Proc [dbo].[sp_rep_GRSC01]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSB05]')) Drop Proc [dbo].[sp_rep_GRSB05]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSB04]')) Drop Proc [dbo].[sp_rep_GRSB04]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSB03]')) Drop Proc [dbo].[sp_rep_GRSB03]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSB02]')) Drop Proc [dbo].[sp_rep_GRSB02]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSB01]')) Drop Proc [dbo].[sp_rep_GRSB01]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSA05C]')) Drop Proc [dbo].[sp_rep_GRSA05C]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSA05A]')) Drop Proc [dbo].[sp_rep_GRSA05A]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSA04B]')) Drop Proc [dbo].[sp_rep_GRSA04B]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSA04A]')) Drop Proc [dbo].[sp_rep_GRSA04A]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSA03]')) Drop Proc [dbo].[sp_rep_GRSA03]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSA02]')) Drop Proc [dbo].[sp_rep_GRSA02]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_rep_GRSA01]')) Drop Proc [dbo].[sp_rep_GRSA01]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_ListAnalysis5]')) Drop Proc [dbo].[report_ListAnalysis5]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_ListAnalysis4]')) Drop Proc [dbo].[report_ListAnalysis4]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_ListAnalysis3]')) Drop Proc [dbo].[report_ListAnalysis3]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_ListAnalysis2]')) Drop Proc [dbo].[report_ListAnalysis2]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_ListAnalysis1]')) Drop Proc [dbo].[report_ListAnalysis1]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_JAGOGD]')) Drop Proc [dbo].[report_JAGOGD]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_JAGPEG]')) Drop Proc [dbo].[report_JAGPEG]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_JAGCOL]')) Drop Proc [dbo].[report_JAGCOL]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_JAGSIG]')) Drop Proc [dbo].[report_JAGSIG]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_JAGERC]')) Drop Proc [dbo].[report_JAGERC]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_JAGBPS]')) Drop Proc [dbo].[report_JAGBPS]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_BowelBoston]')) Drop Proc [dbo].[report_BowelBoston]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[report_Anonimize]')) Drop Proc [dbo].[report_Anonimize]
IF @@ERROR <> 0 SET NOEXEC ON
GO
--------------------------- NED Files
/* [dbo].[v_rep_NEDLog] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_NEDLog]')) Drop View [dbo].[v_rep_NEDLog]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[ERS_NedFilesLog] */
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_NedFilesLog]')) Drop Table [dbo].[ERS_NedFilesLog]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[ERS_IndicationsTypes] */
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_IndicationsTypes]')) Drop Table [dbo].[ERS_IndicationsTypes]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[ERS_ReportAdverse] */
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportAdverse]')) Drop Table [dbo].[ERS_ReportAdverse]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_Organs]')) Drop Table [dbo].[ERS_Organs]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_DiagnosisTypes]')) Drop Table [dbo].[ERS_DiagnosisTypes]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportTherapy]')) Drop Table [dbo].[ERS_ReportTherapy]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Visualization]')) Drop View [dbo].[fw_Visualization]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Visualization]')) Drop View [dbo].[fw_UGI_Visualization]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Visualization]')) Drop View [dbo].[fw_ERS_Visualization]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ColonExtentOfIntubation]')) Drop View [dbo].[fw_ColonExtentOfIntubation]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* VIEWS */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_BowelPrepGRSC05]')) Drop View [dbo].[v_rep_BowelPrepGRSC05]
IF @@ERROR <> 0 SET NOEXEC ON
GO
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_BowelPreparation]')) Drop View [dbo].[v_rep_BowelPreparation]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Complications]')) Drop View [dbo].[fw_ERS_Complications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Complications]')) Drop View [dbo].[fw_UGI_Complications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Complications]')) Drop View [dbo].[fw_Complications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Indications] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Indications]')) Drop View [dbo].[fw_Indications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_QA] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_QA]')) Drop View [dbo].[fw_ERS_QA]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_QA] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_QA]')) Drop View [dbo].[fw_UGI_QA]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_IndicationsERCP] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_IndicationsERCP]')) Drop View [dbo].[fw_IndicationsERCP]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Instruments] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Instruments]')) Drop View [dbo].[fw_Instruments]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_InstrumentTypes] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_InstrumentTypes]')) Drop View [dbo].[fw_InstrumentTypes]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Insertions] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Insertions]')) Drop View [dbo].[fw_Insertions]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* kfw_UGI_Visualization */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_UGI_Visualization') Drop Index kfw_UGI_Visualization On [dbo].[fw_UGI_Visualization]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Visualization] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Visualization]')) Drop View [dbo].[fw_UGI_Visualization]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Markings] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Markings]')) Drop View [dbo].[fw_Markings]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_Markings] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Markings]')) Drop View [dbo].[fw_ERS_Markings]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Markings] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Markings]')) Drop View [dbo].[fw_UGI_Markings]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_PathologyResults] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_PathologyResults]')) Drop View [dbo].[fw_PathologyResults]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Placements] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Placements]')) Drop View [dbo].[fw_Placements]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_Placements] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Placements]')) Drop View [dbo].[fw_ERS_Placements]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Placements] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Placements]')) Drop View [dbo].[fw_UGI_Placements]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* kfw_ReportFilter */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_ReportFilter') Drop Index kfw_ReportFilter On [dbo].[fw_ReportFilter]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ReportFilter] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ReportFilter]')) Drop View [dbo].[fw_ReportFilter]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Specimens] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Specimens]')) Drop View [dbo].[fw_Specimens]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_Specimens] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Specimens]')) Drop View [dbo].[fw_ERS_Specimens]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Specimens] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Specimens]')) Drop View [dbo].[fw_UGI_Specimens]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Therapeutic] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Therapeutic]')) Drop View [dbo].[fw_Therapeutic]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_Therapeutic] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Therapeutic]')) Drop View [dbo].[fw_ERS_Therapeutic]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Therapeutic] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Therapeutic]')) Drop View [dbo].[fw_UGI_Therapeutic]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_BowelPreparationBoston] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_BowelPreparationBoston]')) Drop View [dbo].[fw_BowelPreparationBoston]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_BowelPreparationBoston] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_BowelPreparationBoston]')) Drop View [dbo].[fw_ERS_BowelPreparationBoston]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_BowelPreparationBoston] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_BowelPreparationBoston]')) Drop View [dbo].[fw_UGI_BowelPreparationBoston]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ProceduresInstruments] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ProceduresInstruments]')) Drop View [dbo].[fw_ProceduresInstruments]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_ProceduresInstruments] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_ProceduresInstruments]')) Drop View [dbo].[fw_ERS_ProceduresInstruments]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_ProceduresInstruments] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_ProceduresInstruments]')) Drop View [dbo].[fw_UGI_ProceduresInstruments]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_TherapeuticERCP] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_TherapeuticERCP]')) Drop View [dbo].[fw_TherapeuticERCP]
IF @@ERROR <> 0 SET NOEXEC ON
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[NED_Adverse]')) Drop View [dbo].[NED_Adverse]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Therapeutic] ')) Drop View [dbo].[fw_ERS_Therapeutic] 
IF @@ERROR <> 0 SET NOEXEC ON
GO
/*XXXXXXXXXXXXXXXXXXXXX*/
/*OJO*/
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_PatientMedication]')) Drop View [dbo].[fw_PatientMedication]
IF @@ERROR <> 0 SET NOEXEC ON
GO
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ProcedureMedication]')) Drop View [dbo].[fw_ProcedureMedication]
IF @@ERROR <> 0 SET NOEXEC ON
GO
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_MedicationArray]')) Drop View [dbo].[v_rep_MedicationArray]
IF @@ERROR <> 0 SET NOEXEC ON
GO
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_GRS_Medication]')) Drop View [dbo].[v_rep_GRS_Medication]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_GRSB02]')) Drop View [dbo].[v_rep_GRSB02]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_GRSB01]')) Drop View [dbo].[v_rep_GRSB01]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_Comfort]')) Drop View [dbo].[v_rep_Comfort]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_ReversingAgent]')) Drop View [dbo].[v_rep_ReversingAgent]
IF @@ERROR <> 0 SET NOEXEC ON
GO
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_StentPositioning]')) Drop View [dbo].[v_rep_StentPositioning]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_GRSA02]')) Drop View [dbo].[v_rep_GRSA02]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Visualization]')) Drop View [dbo].[fw_Visualization]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Visualization]')) Drop View [dbo].[fw_UGI_Visualization]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Markings]')) Drop View [dbo].[fw_Markings]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Markings]')) Drop View [dbo].[fw_ERS_Markings]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Markings]')) Drop View [dbo].[fw_UGI_Markings]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_TherapeuticERCP]')) Drop View [dbo].[fw_TherapeuticERCP]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_IndicationsERCP]')) Drop View [dbo].[fw_IndicationsERCP]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Indications]')) Drop View [dbo].[fw_Indications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Indications]')) Drop View [dbo].[fw_ERS_Indications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Indications]')) Drop View [dbo].[fw_UGI_Indications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Therapeutic]')) Drop View [dbo].[fw_Therapeutic]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Therapeutic]')) Drop View [dbo].[fw_ERS_Therapeutic]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Therapeutic]')) Drop View [dbo].[fw_UGI_Therapeutic]
IF @@ERROR <> 0 SET NOEXEC ON
GO
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_BowelPreparation]')) Drop View [dbo].[v_rep_BowelPreparation]
IF @@ERROR <> 0 SET NOEXEC ON
GO
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_ERS_BowelPreparation]')) Drop View [dbo].[v_rep_ERS_BowelPreparation]
IF @@ERROR <> 0 SET NOEXEC ON
GO
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_UGI_BowelPreparation]')) Drop View [dbo].[v_rep_UGI_BowelPreparation]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_BowelPreparation] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_BowelPreparation]')) Drop View [dbo].[fw_BowelPreparation]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_BowelPreparation] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_BowelPreparation]')) Drop View [dbo].[fw_ERS_BowelPreparation]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_BowelPreparation] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_BowelPreparation]')) Drop View [dbo].[fw_UGI_BowelPreparation]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_FailuresERCP] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_FailuresERCP]')) Drop View [dbo].[fw_FailuresERCP]
/* [dbo].[fw_ERS_FailuresERCP] */
/* [dbo].[fw_UGI_FailuresERCP] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_FailuresERCP]')) Drop View [dbo].[fw_UGI_FailuresERCP]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Lesions] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Lesions]')) Drop View [dbo].[fw_Lesions]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_Lesions] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Lesions]')) Drop View [dbo].[fw_ERS_Lesions]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Lesions] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Lesions]')) Drop View [dbo].[fw_UGI_Lesions]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ColonExtentOfIntubation]')) Drop View [dbo].[fw_ColonExtentOfIntubation]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_ColonExtentOfIntubation]')) Drop View [dbo].[fw_ERS_ColonExtentOfIntubation]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_ColonExtentOfIntubation]')) Drop View [dbo].[fw_UGI_ColonExtentOfIntubation]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Insertions] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Insertions]')) Drop View [dbo].[fw_Insertions]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_Insertions] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Insertions]')) Drop View [dbo].[fw_ERS_Insertions]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Insertions] */
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Insertions]')) Drop View [dbo].[fw_UGI_Insertions]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Premedication] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Premedication]')) Drop View [dbo].[fw_Premedication]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_Premedication] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Premedication]')) Drop View [dbo].[fw_ERS_Premedication]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Premedication] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Premedication]')) Drop View [dbo].[fw_UGI_Premedication]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_RepeatOGD] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_RepeatOGD]')) Drop View [dbo].[fw_RepeatOGD]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_RepeatOGD] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_RepeatOGD]')) Drop View [dbo].[fw_ERS_RepeatOGD]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_RepeatOGD] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_RepeatOGD]')) Drop View [dbo].[fw_UGI_RepeatOGD]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_C_Placements]')) Drop View [dbo].[fw_UGI_C_Placements]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_E_Placements]')) Drop View [dbo].[fw_UGI_E_Placements]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_O_Placements]')) Drop View [dbo].[fw_UGI_O_Placements]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ProceduresConsultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ProceduresConsultants]')) Drop View [dbo].[fw_ProceduresConsultants]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_ProceduresConsultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_ProceduresConsultants]')) Drop View [dbo].[fw_ERS_ProceduresConsultants]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_ProceduresConsultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_ProceduresConsultants]')) Drop View [dbo].[fw_UGI_ProceduresConsultants]
IF @@ERROR <> 0 SET NOEXEC ON
GO
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_Consultants]')) Drop View [dbo].[v_rep_Consultants]
IF @@ERROR <> 0 SET NOEXEC ON
GO
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_ERS_Consultants]')) Drop View [dbo].[v_rep_ERS_Consultants]
IF @@ERROR <> 0 SET NOEXEC ON
GO
if exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_rep_UGI_Consultants]')) Drop View [dbo].[v_rep_UGI_Consultants]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_QA] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_QA]')) Drop View [dbo].[fw_QA]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Complications] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Complications]')) Drop View [dbo].[fw_Complications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_Complications] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Complications]')) Drop View [dbo].[fw_ERS_Complications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Complications] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Complications]')) Drop View [dbo].[fw_UGI_Complications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_E_Complications] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_E_Complications]')) Drop View [dbo].[fw_UGI_E_Complications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_C_Complications] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_C_Complications]')) Drop View [dbo].[fw_UGI_C_Complications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_O_Complications] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_O_Complications]')) Drop View [dbo].[fw_UGI_O_Complications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_Complications] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Complications]')) Drop View [dbo].[fw_ERS_Complications]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Sites] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Sites]')) Drop View [dbo].[fw_Sites]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* kfw_ERS_Sites */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_ERS_Sites') DROP INDEX kfw_ERS_Sites ON [dbo].[fw_ERS_Sites]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_Sites] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Sites]')) Drop View [dbo].[fw_ERS_Sites]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Sites] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Sites]')) Drop View [dbo].[fw_UGI_Sites]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* kfw_ReportConsultants */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_ReportConsultants') Drop Index kfw_ReportConsultants On [dbo].[fw_ReportConsultants]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ReportConsultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ReportConsultants]')) Drop View [dbo].[fw_ReportConsultants]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_ReportFilter') Drop Index kfw_ReportFilter On [dbo].[fw_ReportFilter]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ReportFilter]')) Drop View [dbo].[fw_ReportFilter]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Drugs] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Drugs]')) Drop View [dbo].[fw_Drugs]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Procedures] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Procedures]')) Drop View [dbo].[fw_Procedures]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_Procedures] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Procedures]')) Drop View [dbo].[fw_ERS_Procedures]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Procedures] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Procedures]')) Drop View [dbo].[fw_UGI_Procedures]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_C_Procedures] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_C_Procedures]')) Drop View [dbo].[fw_UGI_C_Procedures]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_E_Procedures] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_E_Procedures]')) Drop View [dbo].[fw_UGI_E_Procedures]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_O_Procedures] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_O_Procedures]')) Drop View [dbo].[fw_UGI_O_Procedures]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* istatusfw_UGI_Episode */
If exists (SELECT * FROM sys.indexes WHERE name =N'istatusfw_UGI_Episode') Drop Index istatusfw_UGI_Episode On [dbo].[fw_UGI_Episode]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* iEpisodePatientfw_UGI_Episode */
If exists (SELECT * FROM sys.indexes WHERE name =N'iEpisodePatientfw_UGI_Episode') Drop Index iEpisodePatientfw_UGI_Episode On [dbo].[fw_UGI_Episode]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* iPatientfw_UGI_Episode */
If exists (SELECT * FROM sys.indexes WHERE name =N'iPatientfw_UGI_Episode') Drop Index iPatientfw_UGI_Episode On [dbo].[fw_UGI_Episode]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* iEpisodefw_UGI_Episode */
If exists (SELECT * FROM sys.indexes WHERE name =N'iEpisodefw_UGI_Episode') Drop Index iEpisodefw_UGI_Episode On [dbo].[fw_UGI_Episode]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* kfw_UGI_Episode */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_UGI_Episode') Drop Index kfw_UGI_Episode On [dbo].[fw_UGI_Episode]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Episode] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Episode]')) Drop View [dbo].[fw_UGI_Episode]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Consultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Consultants]')) Drop View [dbo].[fw_Consultants]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ERS_Consultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ERS_Consultants]')) Drop View [dbo].[fw_ERS_Consultants]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_UGI_Consultants] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_UGI_Consultants]')) Drop View [dbo].[fw_UGI_Consultants]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_PatientsSedationScore] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_PatientsSedationScore]')) Drop View [dbo].[fw_PatientsSedationScore]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_NursesComfortScore] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_NursesComfortScore]')) Drop View [dbo].[fw_NursesComfortScore]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_NurseAssPatSedationScore] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_NurseAssPatSedationScore]')) Drop View [dbo].[fw_NurseAssPatSedationScore]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_OperatingHospitals] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_OperatingHospitals]')) Drop View [dbo].[fw_OperatingHospitals]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ConsultantTypes] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ConsultantTypes]')) Drop View [dbo].[fw_ConsultantTypes]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Priority] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Priority]')) Drop View [dbo].[fw_Priority]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_PatientStatus] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_PatientStatus]')) Drop View [dbo].[fw_PatientStatus]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_PatientType] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_PatientType]')) Drop View [dbo].[fw_PatientType]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Apps] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Apps]')) Drop View [dbo].[fw_Apps]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* kfw_ProceduresTypes */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_ProceduresTypes') Drop Index kfw_ProceduresTypes On [dbo].[fw_ProceduresTypes]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_ProceduresTypes] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_ProceduresTypes]')) Drop View [dbo].[fw_ProceduresTypes]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* kfw_Patients_ComboId */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_Patients_ComboId') Drop Index kfw_Patients_ComboId On [dbo].[fw_Patients]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* kfw_Patients_CNN */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_Patients_CNN') Drop Index kfw_Patients_CNN On [dbo].[fw_Patients]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* kfw_Patients_PatientName */
If exists (SELECT * FROM sys.indexes WHERE name =N'kfw_Patients_PatientName') Drop Index kfw_Patients_PatientName On [dbo].[fw_Patients]
IF @@ERROR <> 0 SET NOEXEC ON
GO
/* [dbo].[fw_Patients] */
If exists (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[fw_Patients]')) Drop View [dbo].[fw_Patients]
IF @@ERROR <> 0 SET NOEXEC ON
GO

If exists (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnPatientsPercentile50]')) Drop function [dbo].[fnPatientsPercentile50]
IF @@ERROR <> 0 SET NOEXEC ON
GO

--/* FW Part 3*/
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[sp_NED]')) Drop Proc [dbo].[sp_NED]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[PAS_ImportPatient]')) Drop Proc [dbo].[PAS_ImportPatient]
IF @@ERROR <> 0 SET NOEXEC ON
GO
IF exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[PAS_LinkOn]')) DROP PROC [dbo].[PAS_LinkOn]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[PAS_Replicate]')) Drop Proc [dbo].[PAS_Replicate]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.procedures WHERE object_id = OBJECT_ID(N'[dbo].[PAS_UpdatePatient]')) Drop Proc [dbo].[PAS_UpdatePatient]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportBoston3]')) Drop Table [dbo].[ERS_ReportBoston3]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportBoston2]')) Drop Table [dbo].[ERS_ReportBoston2]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportBoston1]')) Drop Table [dbo].[ERS_ReportBoston1]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportPopup]')) Drop Table [dbo].[ERS_ReportPopup]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportGroupColumn]')) Drop Table [dbo].[ERS_ReportGroupColumn]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportColumn]')) Drop Table [dbo].[ERS_ReportColumn]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportGroup]')) Drop Table [dbo].[ERS_ReportGroup]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_Report]')) Drop Table [dbo].[ERS_Report]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportCategory]')) Drop Table [dbo].[ERS_ReportCategory]
IF @@ERROR <> 0 SET NOEXEC ON
GO
If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportTarget]')) Drop Table [dbo].[ERS_ReportTarget]
IF @@ERROR <> 0 SET NOEXEC ON
GO
--If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportConsultants]')) Drop Table [dbo].[ERS_ReportConsultants]
--IF @@ERROR <> 0 SET NOEXEC ON
GO
--If exists (SELECT * FROM sys.tables WHERE object_id = OBJECT_ID(N'[dbo].[ERS_ReportFilter]')) Drop Table [dbo].[ERS_ReportFilter]
--IF @@ERROR <> 0 SET NOEXEC ON
GO

IF @@ERROR <> 0 SET NOEXEC ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
COMMIT TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
GO
