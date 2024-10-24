Public Interface IDocumentDataAccess
    Function CheckLetterExistsForLetterQueue(LetterQueueId As Integer) As Boolean

    Function GetEditedLetterForLetterQueueId(LetterQueueId As Integer) As Byte()

    Sub SaveEditedLetterQueue(LetterQueueId As Integer, EditedLetterContent() As Byte, Optional EditLetterReasonId As Integer? = 0, Optional EditLetterReasonExtraInfo As String = Nothing)
End Interface
