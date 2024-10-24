Imports Microsoft.VisualBasic

Public Class PrintOptions
    Private _ProcedureId As Integer
    Private _ProcedureTypeId As Integer
    Private _EpisodeNo As Integer
    Private _PatientComboId As String
    Private _ColonType As Integer
    Private _DiagramNumber As Integer

    Private _IncludeGPReport As Boolean
    Private _IncludePhotosReport As Boolean
    Private _IncludePatientCopyReport As Boolean
    Private _IncludeLabRequestReport As Boolean
    Private _PreviewOnly As Boolean
    Private _DeleteMedia As Boolean


    Private _GPReportPrintOptions As GPReportPrintOptions
    Private _LabRequestFormPrintOptions As LabRequestFormPrintOptions
    Private _PatientFriendlyReportPrintOptions As PatientFriendlyReportPrintOptions

    Private _Endo1Sig As Boolean = True
    Private _Endo2Sig As Boolean = False
    Private _PrintDoubleSided As Boolean
    Public Property PhotosOnGpReport As Boolean

    Public Property DiagramNumber() As Integer
        Get
            Return _DiagramNumber
        End Get
        Set
            _DiagramNumber = Value
        End Set
    End Property

    Public Property ProcedureId() As Integer
        Get
            Return _ProcedureId
        End Get
        Set
            _ProcedureId = Value
        End Set
    End Property

    Public Property ProcedureTypeId() As Integer
        Get
            Return _ProcedureTypeId
        End Get
        Set(value As Integer)
            _ProcedureTypeId = value
        End Set
    End Property

    Public Property EpisodeNo() As Integer
        Get
            Return _EpisodeNo
        End Get
        Set
            _EpisodeNo = Value
        End Set
    End Property

    Public Property ColonType() As Integer
        Get
            Return _ColonType
        End Get
        Set(value As Integer)
            _ColonType = value
        End Set
    End Property

    Public Property PatientComboId() As String
        Get
            Return _PatientComboId
        End Get
        Set
            _PatientComboId = Value
        End Set
    End Property

    Public Property IncludeGPReport() As Boolean
        Get
            Return _IncludeGPReport
        End Get
        Set
            _IncludeGPReport = Value
        End Set
    End Property

    Public Property IncludePhotosReport() As Boolean
        Get
            Return _IncludePhotosReport
        End Get
        Set
            _IncludePhotosReport = Value
        End Set
    End Property

    Public Property IncludePatientCopyReport() As Boolean
        Get
            Return _IncludePatientCopyReport
        End Get
        Set
            _IncludePatientCopyReport = Value
        End Set
    End Property

    Public Property IncludeLabRequestReport() As Boolean
        Get
            Return _IncludeLabRequestReport
        End Get
        Set
            _IncludeLabRequestReport = Value
        End Set
    End Property

    Public Property PreviewOnly() As Boolean
        Get
            Return _PreviewOnly
        End Get
        Set(value As Boolean)
            _PreviewOnly = value
        End Set
    End Property

    Public Property DeleteMedia() As Boolean
        Get
            Return _DeleteMedia
        End Get
        Set(value As Boolean)
            _DeleteMedia = value
        End Set
    End Property

    Public Property GPReportPrintOptions() As GPReportPrintOptions
        Get
            Return _GPReportPrintOptions
        End Get
        Set
            _GPReportPrintOptions = Value
        End Set
    End Property

    Public Property LabRequestFormPrintOptions() As LabRequestFormPrintOptions
        Get
            Return _LabRequestFormPrintOptions
        End Get
        Set
            _LabRequestFormPrintOptions = Value
        End Set
    End Property

    Public Property PatientFriendlyReportPrintOptions() As PatientFriendlyReportPrintOptions
        Get
            Return _PatientFriendlyReportPrintOptions
        End Get
        Set
            _PatientFriendlyReportPrintOptions = Value
        End Set
    End Property

    Public Property Endo1Sig() As Boolean
        Get
            Return _Endo1Sig
        End Get
        Set(ByVal value As Boolean)
            _Endo1Sig = value
        End Set
    End Property

    Public Property Endo2Sig() As Boolean
        Get
            Return _Endo2Sig
        End Get
        Set(ByVal value As Boolean)
            _Endo2Sig = value
        End Set
    End Property
    Public Property PrintDoubleSided() As Boolean
        Get
            Return _PrintDoubleSided
        End Get
        Set(ByVal value As Boolean)
            _PrintDoubleSided = value
        End Set
    End Property

End Class
