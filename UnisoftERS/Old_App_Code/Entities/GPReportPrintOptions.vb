Imports Microsoft.VisualBasic

Public Class GPReportPrintOptions
    Private _IncludeDiagram As Boolean
    Private _IncludeDiagramOnlyIfSitesExist As Boolean
    Private _IncludeListConsultant As Boolean
    Private _IncludeNurses As Boolean
    Private _IncludeInstrument As Boolean
    Private _IncludeMissingCaseNote As Boolean
    Private _IncludeIndications As Boolean
    Private _IncludeCoMorbidities As Boolean
    Private _IncludePlannedProcedures As Boolean
    Private _IncludePremedication As Boolean
    Private _IncludeProcedureNotes As Boolean
    Private _IncludeSiteNotes As Boolean
    Private _IncludeBowelPreparation As Boolean
    Private _IncludeExtentOfIntubation As Boolean
    Private _IncludePreviousGastricUlcer As Boolean
    Private _IncludeExtentAndLimitingFactors As Boolean
    Private _IncludeCannulation As Boolean
    Private _IncludeExtentOfVisualisation As Boolean
    Private _IncludeContrastMediaUsed As Boolean
    Private _IncludePapillaryAnatomy As Boolean
    Private _IncludeDiagnoses As Boolean
    Private _IncludeFollowUp As Boolean
    Private _IncludeTherapeuticProcedures As Boolean
    Private _IncludeSpecimensTaken As Boolean
    Private _IncludePeriOperativeComplications As Boolean
    Private _DefaultNumberOfCopies As Integer
    Private _DefaultNumberOfPhotos As Integer
    Private _DefaultPhotoSize As Integer
    Private _DefaultDoubleSided As Boolean
    Private _DefaultPrintOnExport As Boolean
    Private _PrintType As Integer

    Public Property PrintType() As Integer
        Get
            Return _PrintType
        End Get
        Set
            _PrintType = Value
        End Set
    End Property
    Public Property DefaultExportImage() As Boolean
        Get
            Return _DefaultPrintOnExport
        End Get
        Set(ByVal value As Boolean)
            _DefaultPrintOnExport = value
        End Set
    End Property

    Public Property PrintDoubleSided() As Boolean
        Get
            Return _DefaultDoubleSided
        End Get
        Set(ByVal value As Boolean)
            _DefaultDoubleSided = value
        End Set
    End Property

    Public Property IncludeDiagram() As Boolean
        Get
            Return _IncludeDiagram
        End Get
        Set
            _IncludeDiagram = Value
        End Set
    End Property

    Public Property IncludeDiagramOnlyIfSitesExist() As Boolean
        Get
            Return _IncludeDiagramOnlyIfSitesExist
        End Get
        Set
            _IncludeDiagramOnlyIfSitesExist = Value
        End Set
    End Property

    Public Property IncludeListConsultant() As Boolean
        Get
            Return _IncludeListConsultant
        End Get
        Set
            _IncludeListConsultant = Value
        End Set
    End Property

    Public Property IncludeNurses() As Boolean
        Get
            Return _IncludeNurses
        End Get
        Set
            _IncludeNurses = Value
        End Set
    End Property

    Public Property IncludeInstrument() As Boolean
        Get
            Return _IncludeInstrument
        End Get
        Set
            _IncludeInstrument = Value
        End Set
    End Property

    Public Property IncludeMissingCaseNote() As Boolean
        Get
            Return _IncludeMissingCaseNote
        End Get
        Set
            _IncludeMissingCaseNote = Value
        End Set
    End Property

    Public Property IncludeIndications() As Boolean
        Get
            Return _IncludeIndications
        End Get
        Set
            _IncludeIndications = Value
        End Set
    End Property

    Public Property IncludeCoMorbidities() As Boolean
        Get
            Return _IncludeCoMorbidities
        End Get
        Set
            _IncludeCoMorbidities = Value
        End Set
    End Property

    Public Property IncludePlannedProcedures() As Boolean
        Get
            Return _IncludePlannedProcedures
        End Get
        Set
            _IncludePlannedProcedures = Value
        End Set
    End Property

    Public Property IncludePremedication() As Boolean
        Get
            Return _IncludePremedication
        End Get
        Set
            _IncludePremedication = Value
        End Set
    End Property

    Public Property IncludeProcedureNotes() As Boolean
        Get
            Return _IncludeProcedureNotes
        End Get
        Set
            _IncludeProcedureNotes = Value
        End Set
    End Property

    Public Property IncludeSiteNotes() As Boolean
        Get
            Return _IncludeSiteNotes
        End Get
        Set
            _IncludeSiteNotes = Value
        End Set
    End Property

    Public Property IncludeBowelPreparation() As Boolean
        Get
            Return _IncludeBowelPreparation
        End Get
        Set
            _IncludeBowelPreparation = Value
        End Set
    End Property

    Public Property IncludeExtentOfIntubation() As Boolean
        Get
            Return _IncludeExtentOfIntubation
        End Get
        Set
            _IncludeExtentOfIntubation = Value
        End Set
    End Property

    Public Property IncludePreviousGastricUlcer() As Boolean
        Get
            Return _IncludePreviousGastricUlcer
        End Get
        Set
            _IncludePreviousGastricUlcer = Value
        End Set
    End Property

    Public Property IncludeExtentAndLimitingFactors() As Boolean
        Get
            Return _IncludeExtentAndLimitingFactors
        End Get
        Set
            _IncludeExtentAndLimitingFactors = Value
        End Set
    End Property

    Public Property IncludeCannulation() As Boolean
        Get
            Return _IncludeCannulation
        End Get
        Set
            _IncludeCannulation = Value
        End Set
    End Property

    Public Property IncludeExtentOfVisualisation() As Boolean
        Get
            Return _IncludeExtentOfVisualisation
        End Get
        Set
            _IncludeExtentOfVisualisation = Value
        End Set
    End Property

    Public Property IncludeContrastMediaUsed() As Boolean
        Get
            Return _IncludeContrastMediaUsed
        End Get
        Set
            _IncludeContrastMediaUsed = Value
        End Set
    End Property

    Public Property IncludePapillaryAnatomy() As Boolean
        Get
            Return _IncludePapillaryAnatomy
        End Get
        Set
            _IncludePapillaryAnatomy = Value
        End Set
    End Property

    Public Property IncludeDiagnoses() As Boolean
        Get
            Return _IncludeDiagnoses
        End Get
        Set
            _IncludeDiagnoses = Value
        End Set
    End Property

    Public Property IncludeFollowUp() As Boolean
        Get
            Return _IncludeFollowUp
        End Get
        Set
            _IncludeFollowUp = Value
        End Set
    End Property

    Public Property IncludeTherapeuticProcedures() As Boolean
        Get
            Return _IncludeTherapeuticProcedures
        End Get
        Set
            _IncludeTherapeuticProcedures = Value
        End Set
    End Property

    Public Property IncludeSpecimensTaken() As Boolean
        Get
            Return _IncludeSpecimensTaken
        End Get
        Set
            _IncludeSpecimensTaken = Value
        End Set
    End Property

    Public Property IncludePeriOperativeComplications() As Boolean
        Get
            Return _IncludePeriOperativeComplications
        End Get
        Set
            _IncludePeriOperativeComplications = Value
        End Set
    End Property

    Public Property DefaultNumberOfCopies() As Integer
        Get
            Return _DefaultNumberOfCopies
        End Get
        Set
            _DefaultNumberOfCopies = Value
        End Set
    End Property

    Public Property DefaultNumberOfPhotos() As Integer
        Get
            Return _DefaultNumberOfPhotos
        End Get
        Set
            _DefaultNumberOfPhotos = Value
        End Set
    End Property


    Public Property DefaultPhotoSize() As Integer
        Get
            Return _DefaultPhotoSize
        End Get
        Set(ByVal value As Integer)
            _DefaultPhotoSize = value
        End Set
    End Property

End Class
