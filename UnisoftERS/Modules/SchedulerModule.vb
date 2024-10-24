Module SchedulerModule
    Public PriorityColours As List(Of clsPriorityColors) = New List(Of clsPriorityColors)()
    Public TypeOfNameSearchFilter As String = ""
    Public SurnameFilter As String = ""
    Public ForenameFilter As String = ""

    Public Function GetPriorityID(InString As String) As VariantType
        Dim filterOne As List(Of clsPriorityColors) = PriorityColours.FindAll(Function(p As clsPriorityColors) p.PriorityName = InString)
        If filterOne.Count <> 0 Then
            Return filterOne.Item(0).PriorityId
        Else
            Return 0
        End If
    End Function
    Public Function GetPriorityNameById(InId As Long) As String
        Dim filterOne As List(Of clsPriorityColors) = PriorityColours.FindAll(Function(p As clsPriorityColors) p.PriorityId = InId)
        If filterOne.Count <> 0 Then
            Return filterOne.Item(0).PriorityName
        Else
            Return 0
        End If
    End Function
    Public Function GetPriorityColorByName(InString As String) As String
        Dim filterOne As List(Of clsPriorityColors) = PriorityColours.FindAll(Function(p As clsPriorityColors) p.PriorityName = InString)
        If filterOne.Count <> 0 Then
            Return filterOne.Item(0).PriorityColor
        Else
            Return ""
        End If
    End Function
    Public Function GetPriorityColorById(InId As Long) As String
        Dim filterOne As List(Of clsPriorityColors) = PriorityColours.FindAll(Function(p As clsPriorityColors) p.PriorityId = InId)
        If filterOne.Count <> 0 Then
            Return filterOne.Item(0).PriorityColor
        Else
            Return ""
        End If
    End Function
End Module
