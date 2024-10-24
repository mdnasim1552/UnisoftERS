<Serializable()>
Public Class SitePolyps
    Public Property PolypType As String
    Public Property PolypTypeId As Integer
    Public Property PolypId As String
    Public Property Size As Integer
    Public Property Excised As Boolean
    Public Property Retrieved As Boolean
    Public Property Discarded As Boolean
    Public Property Successful As Boolean
    Public Property SentToLabs As Boolean
    Public Property Removal As Integer
    Public Property RemovalDescription As String
    Public Property RemovalMethod As Integer
    Public Property RemovalMethodDescription As String
    Public Property Probably As Boolean
    Public Property TumourType As Integer
    Public Property TypeDescription As String
    Public Property Inflammatory As Boolean
    Public Property PostInflammatory As Boolean
    Public Property PitPattern As Integer
    Public Property ParisClassification As Integer
    Public Property TattooedId As Integer
    Public Property TattooMarkingTypeId As Integer
    Public Property TattooedMarkingTypeDescription As String
    Public Property Conditions As List(Of Integer)
    Public Property TattooLocationDistal As Boolean
    Public Property TattooLocationProximal As Boolean
    Public Property TattoDescription As String
    Public Property SubmucosalQuantity As Integer
    Public Property SubmucosalLargest As Integer
    Public Property FocalQuantity As Integer
    Public Property FocalLargest As Integer
    Public Property FundicGlandPolypQuantity As Integer
    Public Property FundicGlandPolypLargest As Double


    Sub New()
        Conditions = New List(Of Integer)
    End Sub
End Class
