Public Enum ExceptionType
    custom
    system_generated
End Enum

Public Class AutoCalculationException
    Inherits Exception
    '
    ' Summary:
    '     Initializes a new instance of the System.Exception class with a specified error
    '     message.
    '
    ' Parameters:
    '   message:
    '     The message that describes the error.
    Public Sub New(message As String, errorLogRef As String)
        MyBase.New(message)
        _errorRef = errorLogRef
    End Sub

    Private _errorRef As String
    Public Property ErrorRef() As String
        Get
            Return _errorRef
        End Get
        Set(ByVal value As String)
            _errorRef = value
        End Set
    End Property

    Public ReadOnly Property exType As ExceptionType
        Get
            Return ExceptionType.custom
        End Get
    End Property
End Class
