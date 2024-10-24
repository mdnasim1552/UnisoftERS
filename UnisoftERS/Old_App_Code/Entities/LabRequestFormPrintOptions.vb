Imports Microsoft.VisualBasic

Public Class LabRequestFormPrintOptions
    Private _OneRequestForEverySpecimen As Boolean
    Private _GroupSpecimensByDestination As Boolean
    Private _RequestsPerA4Page As Integer
    Private _IncludeDiagram As Boolean
    Private _IncludeTimeSpecimenCollected As Boolean
    Private _IncludeHeading As Boolean
    Private _Heading As String
    Private _IncludeIndications As Boolean
    Private _IncludeProcedureNotes As Boolean
    Private _IncludeAbnormalities As Boolean
    Private _IncludeSiteNotes As Boolean
    Private _IncludeDiagnoses As Boolean
    Private _DefaultNumberOfCopies As Integer

    Public Property OneRequestForEverySpecimen() As Boolean
        Get
            Return _OneRequestForEverySpecimen
        End Get
        Set
            _OneRequestForEverySpecimen = Value
        End Set
    End Property

    Public Property GroupSpecimensByDestination() As Boolean
        Get
            Return _GroupSpecimensByDestination
        End Get
        Set
            _GroupSpecimensByDestination = Value
        End Set
    End Property

    Public Property RequestsPerA4Page() As Integer
        Get
            Return _RequestsPerA4Page
        End Get
        Set
            _RequestsPerA4Page = Value
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

    Public Property IncludeTimeSpecimenCollected() As Boolean
        Get
            Return _IncludeTimeSpecimenCollected
        End Get
        Set
            _IncludeTimeSpecimenCollected = Value
        End Set
    End Property

    Public Property IncludeHeading() As Boolean
        Get
            Return _IncludeHeading
        End Get
        Set
            _IncludeHeading = Value
        End Set
    End Property

    Public Property Heading() As String
        Get
            Return _Heading
        End Get
        Set
            _Heading = Value
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

    Public Property IncludeProcedureNotes() As Boolean
        Get
            Return _IncludeProcedureNotes
        End Get
        Set
            _IncludeProcedureNotes = Value
        End Set
    End Property

    Public Property IncludeAbnormalities() As Boolean
        Get
            Return _IncludeAbnormalities
        End Get
        Set
            _IncludeAbnormalities = Value
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

    Public Property IncludeDiagnoses() As Boolean
        Get
            Return _IncludeDiagnoses
        End Get
        Set
            _IncludeDiagnoses = Value
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
End Class
