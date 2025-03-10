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

Partial Public Class ERS_PrintOptionsGPReport
    Public Property GPReportID As Integer
    Public Property IncludeDiagram As Boolean
    Public Property IncludeDiagramOnlyIfSitesExist As Boolean
    Public Property IncludeListConsultant As Boolean
    Public Property IncludeNurses As Boolean
    Public Property IncludeInstrument As Boolean
    Public Property IncludeMissingCaseNote As Boolean
    Public Property IncludeIndications As Boolean
    Public Property IncludeCoMorbidities As Boolean
    Public Property IncludePlannedProcedures As Boolean
    Public Property IncludePremedication As Boolean
    Public Property IncludeProcedureNotes As Boolean
    Public Property IncludeSiteNotes As Boolean
    Public Property IncludeBowelPreparation As Boolean
    Public Property IncludeExtentOfIntubation As Boolean
    Public Property IncludePreviousGastricUlcer As Boolean
    Public Property IncludeExtentAndLimitingFactors As Boolean
    Public Property IncludeCannulation As Boolean
    Public Property IncludeExtentOfVisualisation As Boolean
    Public Property IncludeContrastMediaUsed As Boolean
    Public Property IncludePapillaryAnatomy As Boolean
    Public Property IncludeDiagnoses As Boolean
    Public Property IncludeFollowUp As Boolean
    Public Property IncludeTherapeuticProcedures As Boolean
    Public Property IncludeSpecimensTaken As Boolean
    Public Property IncludePeriOperativeComplications As Boolean
    Public Property DefaultNumberOfCopies As Integer
    Public Property DefaultNumberOfPhotos As Integer
    Public Property OperatingHospitalId As Integer
    Public Property WhoUpdatedId As Nullable(Of Integer)
    Public Property WhoCreatedId As Nullable(Of Integer)
    Public Property WhenCreated As Nullable(Of Date)
    Public Property WhenUpdated As Nullable(Of Date)
    Public Property DefaultPhotoSize As Nullable(Of Integer)
    Public Property DefaultPrintImageOnGp As Nullable(Of Boolean)
    Public Property PrintDoubleSided As Boolean
    Public Property PrintOnExport As Boolean
    Public Property PrintType As Nullable(Of Short)

    Public Overridable Property ERS_OperatingHospitals As ERS_OperatingHospitals

End Class
