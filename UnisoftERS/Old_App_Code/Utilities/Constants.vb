Imports Microsoft.VisualBasic

Public Class Constants

    Public Const SESSION_PAGE_INDEX As String = "PageIndex"
    Public Const SESSION_PATIENT_SEARCH_FIELDS As String = "PatientSearchFields"
    'Public Const SESSION_PATIENT_ID As String = "PatientId"
    Public Const SESSION_PATIENT_WORKLIST_ID As String = "PatientWorklistId"
    Public Const SESSION_IS_ERS_PATIENT As String = "IsERSPatient"
    Public Const SESSION_IS_PREVIOUS_PROCEDURE As String = "IsPreviousProcedure"
    Public Const SESSION_CASE_NOTE_NO As String = "CaseNoteNo"
    Public Const SESSION_APPOINTMENT_ID As String = "AppointmentId"
    Public Const SESSION_WORKLIST_PROCEDURE_TYPE_ID As String = "WorklistProcedureTypeId"
    Public Const SESSION_PATIENT_NO As String = "PatientNo"
    Public Const SESSION_PATIENT_COMBO_ID As String = "PatientComboId"
    Public Const SESSION_PROCEDURE_TYPE As String = "ProcNo"
    Public Const SESSION_NEXT_PROCEDURE_TYPE As String = "NextProcNo"
    Public Const SESSION_PROCEDURE_COLONTYPE As String = "ColonType"
    Public Const SESSION_PROCEDURE_DATE As String = "ProcDate"
    Public Const SESSION_PROCEDURE_ID As String = "ProcId"
    Public Const SESSION_EPISODE_NO As String = "EpisodeNo"
    Public Const SESSION_LISTCON As String = "ListCon"
    Public Const SESSION_ENDO1 As String = "Endo1"
    Public Const SESSION_ENDO2 As String = "Endo2"
    Public Const SESSION_NURSE1 As String = "Nurse1"
    Public Const SESSION_NURSE2 As String = "Nurse2"
    Public Const SESSION_NURSE3 As String = "Nurse3"
    Public Const SESSION_NURSE4 As String = "Nurse4"
    Public Const SESSION_LISTCON_TEXT As String = "PPListCon"
    Public Const SESSION_ENDO1_TEXT As String = "PPEndo1"
    Public Const SESSION_ENDO2_TEXT As String = "PPEndo2"
    Public Const SESSION_NURSE1_TEXT As String = "PPNurse1"
    Public Const SESSION_NURSE2_TEXT As String = "PPNurse2"
    Public Const SESSION_NURSE3_TEXT As String = "PPNurse3"
    Public Const SESSION_NURSE4_TEXT As String = "PPNurse4"
    Public Const SESSION_PHOTO_URL As String = "PhotosUrl"
    Public Const SESSION_PHOTO_UNC As String = "PhotosUnc"
    Public Const SESSION_IMPORT_PATIENT_BY_WEBSERVICE As String = "ImportPatientByWebService" '08 Mar 2021 added by Mahfuz
    Public Const SESSION_ADD_EXPORT_FILE_FOR_MIRTH As String = "AddExportFileForMirth" 'MH added on 01 Aug 2022
    Public Const SESSION_SUPPRESS_MAIN_REPORT_PDF As String = "SuppressMainReportPDF" 'MH added on 01 Aug 2022
    Public Const SESSION_STAFF_LIST_SAVE_DEFAULTS As String = "PPStaffListSaveDefaults"
    Public Const SESSION_LISTTYPE_TEXT_DEFAULT As String = "PPListTypeDefault"
    Public Const SESSION_LISTCON_TEXT_DEFAULT As String = "PPListConDefault"
    Public Const SESSION_LISTCON_GMC_DEFAULT As String = "PPListConDefaultGMCCode"
    Public Const SESSION_ENDO1_TEXT_DEFAULT As String = "PPEndo1Default"
    Public Const SESSION_ENDO1_GMC_DEFAULT As String = "PPEndo1DefaultGMCCode"
    Public Const SESSION_ENDO1ROLE_TEXT_DEFAULT As String = "PPEndo1RoleDefault"
    Public Const SESSION_ENDO2_TEXT_DEFAULT As String = "PPEndo2Default"
    Public Const SESSION_ENDO2_GMC_DEFAULT As String = "PPEndo2DefaultGMCCode"
    Public Const SESSION_ENDO2ROLE_TEXT_DEFAULT As String = "PPEndo2RoleDefault"
    Public Const SESSION_NURSE1_TEXT_DEFAULT As String = "PPNurse1Default"
    Public Const SESSION_NURSE2_TEXT_DEFAULT As String = "PPNurse2Default"
    Public Const SESSION_NURSE3_TEXT_DEFAULT As String = "PPNurse3Default"
    Public Const SESSION_NURSE4_TEXT_DEFAULT As String = "PPNurse4Default"
    Public Const SESSION_SEARCH_TAB As String = "0"
    Public Const SESSION_APPVERSION As String = "v1.02"
    Public Const SESSION_DIAGRAM_NUMBER As String = "DiagramNumber"
    Public Const SESSION_MASTER_AUDIT_LOGID As String = "MasterAuditLogId"
    Public Const SESSION_EXAMINATION_START_TIME As String = "ExaminationStartTime"
    Public Const SESSION_IS_LYMPH_NODE_SITE As String = "IsLymphNode"
    Public Const SESSION_HEALTH_SERVICE_NAME As String = "CountryOfOriginHealthService"

    Public Const SESSION_QA_MANAGEMENT As String = "QAManagement"
    Public Const SESSION_QA_MANAGEMENT_NONE As String = "ManagementNone"
    Public Const SESSION_QA_MANAGEMENT_PULSE_OXIMETRY As String = "ManagementPulseOximetry"
    Public Const SESSION_QA_MANAGEMENT_IV_ACCESS As String = "ManagementIvAccess"
    Public Const SESSION_QA_MANAGEMENT_IV_ANTIBIOTICS As String = "ManagementIvAntibiotics"
    Public Const SESSION_QA_MANAGEMENT_OXYGENATION As String = "ManagementOxygenation"
    Public Const SESSION_QA_MANAGEMENT_OXYGENATION_METHOD As String = "ManagementOxygenationMethod"
    Public Const SESSION_QA_MANAGEMENT_OXYGENATION_FLOW_RATE As String = "ManagementOxygenationFlowRate"
    Public Const SESSION_QA_MANAGEMENT_CONTINOUS_FLOW_RATE As String = "ManagementContinousFlowRate"
    Public Const SESSION_QA_MANAGEMENT_CONTINOUS_ECG As String = "ManagementContinousECG"
    Public Const SESSION_QA_MANAGEMENT_BP As String = "ManagementBp"
    Public Const SESSION_QA_MANAGEMENT_SYSTOLIC_BP As String = "ManagementSystolicBo"
    Public Const SESSION_QA_MANAGEMENT_DIASTOLIC_BP As String = "ManagementDiastolicBp"
    Public Const SESSION_QA_MANAGEMENT_OTHER As String = "ManagementOther"
    Public Const SESSION_QA_MANAGEMENT_OTHER_TEXT As String = "ManagementOtherText"
    Public Const SESSION_SITE_ID As String = "SiteId"
    Public Const SESSION_PROCEDURE_GENDER_SPECIFIC As String = "GenderSpecific"
    Public Const SESSION_IMAGE_GENDERID As String = "ImageGenderId"
    Public Const SESSION_IMPORT_PATIENT_BY_NSSAPI As String = "NSSAPI" '10 Aug 2023 added by Partha
    Public Const SESSION_IMPORT_PATIENT_BY_NHSSPINEAPI As String = "Nhs Spine API" '13 November 2023 added by Partha
    Public Const SESSION_IS_PRE_ASSESSMENT As String = "IsPreAssessment"
    Public Const SESSION_PRE_ASSESSMENT_Id As String = "PreAssessmentId"
    Public Const SESSION_IS_Nurse_Module As String = "IsPreAssessment"
    Public Const SESSION_Nurse_Module_Id As String = "NurseModuleId"
    Public Const SESSION_PROCEDURE_TYPES As String = "ProcTypes"
    Public Const SESSION_TREE_GROUP_TYPE As String = "GroupType"
End Class

Public Enum ProcedureType
    Gastroscopy = 1
    ERCP = 2
    Colonoscopy = 3
    Sigmoidscopy = 4
    Proctoscopy = 5
    EUS_OGD = 6
    EUS_HPB = 7
    Antegrade = 8
    Retrograde = 9
    Bronchoscopy = 10
    EBUS = 11
    Thoracoscopy = 12
    Flexi = 13
    Rigid = 14
    Capsule = 15
    Transnasal = 91
End Enum
Public Enum ProcedureEditTabs
    Main = 1
    ShowHideReport = 2
    PreProcedure = 3
    Procedure = 4
    PostProcedure = 5
    ReviewAndPrint = 6
    Indications = 7
    Others = 0
End Enum

Public Enum Staff
    ListConsultant = 1
    EndoScopist1 = 2
    EndoScopist2 = 3
    Nurse1 = 4
    Nurse2 = 5
    Nurse3 = 6
    Nurse4 = 7
End Enum

'Event types
Public Enum EVENT_TYPE
    Insert = 1
    Update = 2
    Delete = 3
    Search = 4
    Download = 5 'Download from PAS
    Reports = 6 'Supporting reports
    SelectRecord = 7
    ConfigUpdate = 8 'Changing configuration
    Print = 9
    LogIn = 10
    LogOut = 11
    DataExport = 12
    Database = 13
End Enum

'Application ID's
Public Enum APP_ID_ENUM
    AppGI = 1
    AppBroncho = 2
    AppCRT = 3
    AppScheduler = 4
    AppExport = 5
    AppPAS = 6
    AppAuditLog = 7
    AppAK = 8
End Enum

Public Enum AntPos
    Anterior = 1
    Posterior = 2
    BothOrEither = 3
End Enum

Public Enum BronchoCodeSection
    Diagnosis = 1
    Therapeutic = 2
    EbusLymphNodes = 3
End Enum

Public Enum ListAnalysisReportOptions
    HideSuppressed = 0
    ListOfPatients = 1
    Anonymise = 2
    IncludeTherapeutics = 3
    IncludeIndications = 4
    DailyTotalsPerConsultant = 5
    DailyTotals = 6
    GrandTotalForPeriod = 7
    SummaryForPeriod = 8
    ShowDiagnosisVsTherapeutics = 9
End Enum

'Mahfuz added on 19 Mar 2021
Public Enum ImportPatientByWebserviceOptions
    Default_HL7 = 0
    Webservice = 1
    FileDataExport = 2
    XML_and_HTML = 3 'Mahfuz added on 18 June 2021 for North Midlan (Stoke)
    FlatFile_Practice_Plus_Group_SO = 4 'Mahfuz added on 27 Oct 2021 for Southampton PPG
    Main_PDF_Supporting_XML = 5 'Mahfuz added on 26 Jan 2022 for Warwickshire Supporting XML doc export with PDF
    XML_and_Main_PDF = 6 'MH added on 18 May 2023 - Stoke's requirement
    NSSAPI = 7 ' Partha for NHS scotland data retrieval
    NHSSPINEAPI = 8 ' Partha for NHS Spine data retrieval
End Enum

Public Enum InsertionTechnique
    GasInsufflation = 0
    WaterAssistedTechnique = 1
    GasAndWaterCombined = 2
End Enum


Public Class StaffColumnName
    Private Key As String

    Public Shared ReadOnly ListConsultant As StaffColumnName = New StaffColumnName("List Consultant")
    Public Shared ReadOnly EndoScopist1 As StaffColumnName = New StaffColumnName("EndoScopist1")
    Public Shared ReadOnly EndoScopist2 As StaffColumnName = New StaffColumnName("EndoScopist2")
    Public Shared ReadOnly Nurse1 As StaffColumnName = New StaffColumnName("Nurse1")
    Public Shared ReadOnly Nurse2 As StaffColumnName = New StaffColumnName("Nurse2")
    Public Shared ReadOnly Nurse3 As StaffColumnName = New StaffColumnName("Nurse3")
    Public Shared ReadOnly Nurse4 As StaffColumnName = New StaffColumnName("Nurse4")

    Private Sub New(key As String)
        Me.Key = key
    End Sub

    Public Overrides Function ToString() As String
        Return Me.Key
    End Function
End Class

Public Class EthnicOriginsUsedIn
    Private Key As String

    Public Shared ReadOnly AllOthers As EthnicOriginsUsedIn = New EthnicOriginsUsedIn("")
    Public Shared ReadOnly Australia As EthnicOriginsUsedIn = New EthnicOriginsUsedIn("Australia")
    Public Shared ReadOnly Bolton As EthnicOriginsUsedIn = New EthnicOriginsUsedIn("Bolton")
    Public Shared ReadOnly NHSDataDictionary As EthnicOriginsUsedIn = New EthnicOriginsUsedIn("NHS Data Dictionary")

    Private Sub New(ByVal key As String)
        Me.Key = key
    End Sub

    Public Overrides Function ToString() As String
        Return Me.Key
    End Function
End Class
