Imports Microsoft.VisualBasic

Public Class PatientFriendlyReportPrintOptions

    Private _IncludeNoFollowup As Boolean
    Private _IncludeUreaseText As Boolean
    Private _UreaseText As String
    Private _IncludePolypectomyText As Boolean
    Private _PolypectomyText As String
    Private _IncludeOtherBiopsyText As Boolean
    Private _OtherBiopsyText As String
    Private _IncludeAnyOtherBiopsyText As Boolean
    Private _AnyOtherBiopsyText As String
    Private _IncludeAdviceComments As Boolean
    Private _IncludePreceedAdviceComments As Boolean
    Private _PreceedAdviceComments As String
    Private _IncludeFinalText As Boolean
    Private _FinalText As String
    Private _DefaultNumberOfCopies As Integer
    Private _AdditionalEntries As List(Of PatientFriendlyReportPrintOptionsAdditional)

    Public Property IncludeNoFollowup() As Boolean
        Get
            Return _IncludeNoFollowup
        End Get
        Set(value As Boolean)
            _IncludeNoFollowup = value
        End Set
    End Property

    Public Property IncludeUreaseText() As Boolean
        Get
            Return _IncludeUreaseText
        End Get
        Set(value As Boolean)
            _IncludeUreaseText = value
        End Set
    End Property

    Public Property UreaseText() As String
        Get
            Return _UreaseText
        End Get
        Set(value As String)
            _UreaseText = value
        End Set
    End Property

    Public Property IncludePolypectomyText() As Boolean
        Get
            Return _IncludePolypectomyText
        End Get
        Set(value As Boolean)
            _IncludePolypectomyText = value
        End Set
    End Property

    Public Property PolypectomyText() As String
        Get
            Return _PolypectomyText
        End Get
        Set(value As String)
            _PolypectomyText = value
        End Set
    End Property

    Public Property IncludeOtherBiopsyText() As Boolean
        Get
            Return _IncludeOtherBiopsyText
        End Get
        Set(value As Boolean)
            _IncludeOtherBiopsyText = value
        End Set
    End Property

    Public Property OtherBiopsyText() As String
        Get
            Return _OtherBiopsyText
        End Get
        Set(value As String)
            _OtherBiopsyText = value
        End Set
    End Property

    Public Property IncludeAnyOtherBiopsyText() As Boolean
        Get
            Return _IncludeAnyOtherBiopsyText
        End Get
        Set(value As Boolean)
            _IncludeAnyOtherBiopsyText = value
        End Set
    End Property

    Public Property AnyOtherBiopsyText() As String
        Get
            Return _AnyOtherBiopsyText
        End Get
        Set(value As String)
            _AnyOtherBiopsyText = value
        End Set
    End Property

    Public Property IncludeAdviceComments() As Boolean
        Get
            Return _IncludeAdviceComments
        End Get
        Set(value As Boolean)
            _IncludeAdviceComments = value
        End Set
    End Property

    Public Property IncludePreceedAdviceComments() As Boolean
        Get
            Return _IncludePreceedAdviceComments
        End Get
        Set(value As Boolean)
            _IncludePreceedAdviceComments = value
        End Set
    End Property

    Public Property PreceedAdviceComments() As String
        Get
            Return _PreceedAdviceComments
        End Get
        Set(value As String)
            _PreceedAdviceComments = value

        End Set
    End Property

    Public Property IncludeFinalText() As Boolean
        Get
            Return _IncludeFinalText
        End Get
        Set(value As Boolean)
            _IncludeFinalText = value
        End Set
    End Property

    Public Property FinalText() As String
        Get
            Return _FinalText
        End Get
        Set(value As String)
            _FinalText = value
        End Set
    End Property

    Public Property DefaultNumberOfCopies() As Integer
        Get
            Return _DefaultNumberOfCopies
        End Get
        Set(value As Integer)
            _DefaultNumberOfCopies = value
        End Set
    End Property

    Public Property AdditionalEntries() As List(Of PatientFriendlyReportPrintOptionsAdditional)
        Get
            Return _AdditionalEntries
        End Get
        Set(value As List(Of PatientFriendlyReportPrintOptionsAdditional))
            _AdditionalEntries = value
        End Set
    End Property
End Class


Public Class PatientFriendlyReportPrintOptionsAdditional

    Private _Id As Integer
    Private _IncludeAdditionalText As Boolean
    Private _AdditionalText As String

    Public Property Id() As Integer
        Get
            Return _Id
        End Get
        Set(value As Integer)
            _Id = value
        End Set
    End Property

    Public Property IncludeAdditionalText() As Boolean
        Get
            Return _IncludeAdditionalText
        End Get
        Set(value As Boolean)
            _IncludeAdditionalText = value
        End Set
    End Property

    Public Property AdditionalText() As String
        Get
            Return _AdditionalText
        End Get
        Set(value As String)
            _AdditionalText = value
        End Set
    End Property
End Class