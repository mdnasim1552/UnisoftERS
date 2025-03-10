'------------------------------------------------------------------------------
' <auto-generated>
'     This code was generated from a template.
'
'     Manual changes to this file may cause unexpected behavior in your application.
'     Manual changes to this file will be overwritten if the code is regenerated.
' </auto-generated>
'------------------------------------------------------------------------------

Imports System
Imports System.Collections.Generic

Partial Public Class ERS_SystemConfig
    Public Property SystemConfigID As Integer
    Public Property HospitalID As Integer
    Public Property OperatingHospitalID As Integer
    Public Property ApplicationTimeOut As Integer
    Public Property SystemDisabled As Nullable(Of Boolean)
    Public Property ScheduledShutdown As Nullable(Of Date)
    Public Property PwdRuleMinLength As Nullable(Of Integer)
    Public Property PwdRuleNoOfSpecialChars As Nullable(Of Integer)
    Public Property PwdRuleNoSpaces As Nullable(Of Boolean)
    Public Property PwdRuleCantBeUserId As Nullable(Of Boolean)
    Public Property PwdRuleDaysToExpiration As Nullable(Of Integer)
    Public Property PwdRuleNoOfPastPwdsToAvoid As Nullable(Of Integer)
    Public Property SiteIdentification As Nullable(Of Byte)
    Public Property SiteRadius As Nullable(Of Decimal)
    Public Property OGDDiagnosis As Nullable(Of Boolean)
    Public Property UreaseTestsIncludeTickBoxes As Nullable(Of Boolean)
    Public Property OesophagitisClassification As Nullable(Of Boolean)
    Public Property BostonBowelPrepScale As Boolean
    Public Property ReportHeading As String
    Public Property ReportTrustType As String
    Public Property ReportSubHeading As String
    Public Property DepartmentName As String
    Public Property PatientConsent As Nullable(Of Byte)
    Public Property SortReferringConsultantBy As Nullable(Of Boolean)
    Public Property CompleteWHOSurgicalSafetyCheckList As Nullable(Of Boolean)
    Public Property ReportLocking As Nullable(Of Byte)
    Public Property LockingTime As String
    Public Property LockingDays As Nullable(Of Integer)
    Public Property CountryLabel As Byte
    Public Property NED_HospitalSiteCode As String
    Public Property NED_OrganisationCode As String
    Public Property NED_APIKey As String
    Public Property NED_BatchId As String
    Public Property NED_ExportPath As String
    Public Property NEDEnabled As Nullable(Of Boolean)
    Public Property AuditLogEnabled As Boolean
    Public Property ErrorLogEnabled As Boolean
    Public Property ImGrabEnabled As Boolean
    Public Property IncludeUGI As Nullable(Of Boolean)
    Public Property DefaultPatientStatus As Nullable(Of Byte)
    Public Property DefaultPatientType As Nullable(Of Byte)
    Public Property DefaultWard As Nullable(Of Byte)
    Public Property BRTPulmonaryPhysiology As Boolean
    Public Property PhotosURL As String
    Public Property PhotosUNC As String
    Public Property MaxWorklistDays As Nullable(Of Byte)
    Public Property WhoUpdatedId As Nullable(Of Integer)
    Public Property WhoCreatedId As Nullable(Of Integer)
    Public Property WhenCreated As Nullable(Of Date)
    Public Property WhenUpdated As Nullable(Of Date)
    Public Property ReportFooter As String
    Public Property LockingHours As Nullable(Of Integer)
    Public Property LeftLogo As String
    Public Property IsEvidenceOfCancerMandatory As Nullable(Of Byte)
    Public Property MinimumPatientSearchOption As Nullable(Of Integer)
    Public Property PathwayPlanMaxQuestions As Integer
    Public Property EvidenceOfCancerMandatoryFlagLastActivatedDate As Nullable(Of Date)
    Public Property EvidenceOfCancerMandatoryFlagLastDeactivatedDate As Nullable(Of Date)
    Public Property EvidenceOfCancerMandatoryFlagIgnoreBeforeDate As Nullable(Of Date)
    Public Property IsPrintReportPopupActive As Nullable(Of Boolean)
    Public Property PrintReportPopupMessage As String
    Public Property IsPatientNotesAvailableMandatory As Nullable(Of Boolean)

End Class
