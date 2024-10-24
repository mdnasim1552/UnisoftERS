Public Class clsPriorityColors
    Public Sub New(ByVal Id As Long, Priority As String, Color As String)
        'PriorityId, Description, Backcolor
        PriorityName = Priority
        PriorityId = Id
        PriorityColor = Color
    End Sub
    Private Priority_Color As String = String.Empty
    Private Priority_Id As Long = 0
    Private Priority_Name As String = String.Empty

    Public Property PriorityColor() As String
        Get
            Return Priority_Color
        End Get
        Set(ByVal value As String)
            Priority_Color = value
        End Set
    End Property
    Public Property PriorityId() As Long
        Get
            Return Priority_Id
        End Get
        Set(ByVal value As Long)
            Priority_Id = value
        End Set
    End Property
    Public Property PriorityName() As String
        Get
            Return Priority_Name
        End Get
        Set(ByVal value As String)
            Priority_Name = value
        End Set
    End Property
End Class
