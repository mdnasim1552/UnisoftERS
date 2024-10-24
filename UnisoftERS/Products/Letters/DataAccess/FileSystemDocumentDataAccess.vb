Imports System.IO

Public Class FileSystemDocumentDataAccess
    Inherits Page
    Implements IDocumentDataAccess

    Private ReadOnly letterStorageUNC As String = If(Not (String.IsNullOrEmpty(ConfigurationManager.AppSettings("LetterStorageUNC"))), ConfigurationManager.AppSettings("LetterStorageUNC"), Server.MapPath("~/App_Data/Letters"))

    Public Function CheckLetterExistsForLetterQueue(LetterQueueId As Integer) As Boolean Implements IDocumentDataAccess.CheckLetterExistsForLetterQueue
        Try
            Return File.Exists(letterStorageUNC & "/" & LetterQueueId & ".sel")
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError($"Error occurred while checking if letter exists on filesystem.  LetterQueueId : { LetterQueueId }", ex)
            Return False
        End Try
    End Function

    Public Function GetEditedLetterForLetterQueueId(LetterQueueId As Integer) As Byte() Implements IDocumentDataAccess.GetEditedLetterForLetterQueueId
        Dim filename As String = letterStorageUNC & "/" & LetterQueueId & ".sel"

        Try
            Dim fileStream As New MemoryStream(File.ReadAllBytes(filename))
            Return fileStream.ToArray()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError($"Error occurred reading file from filesystem : { filename }", ex)
            Return Nothing
        End Try
    End Function

    Public Sub SaveEditedLetterQueue(LetterQueueId As Integer, EditedLetterContent() As Byte, Optional EditLetterReasonId As Integer? = 0, Optional EditLetterReasonExtraInfo As String = Nothing) Implements IDocumentDataAccess.SaveEditedLetterQueue
        Dim filename As String = letterStorageUNC & "/" & LetterQueueId & ".sel"

        Try
            Dim memoryStream As New MemoryStream(EditedLetterContent)
            Dim fileStream As New FileStream(filename, FileMode.OpenOrCreate, FileAccess.ReadWrite)
            memoryStream.WriteTo(fileStream)
            fileStream.Close()

            'Update database to reflect letter has been saved
            Dim lg As New LetterGeneration
            lg.UpdateLetterQueueEdited(LetterQueueId, EditLetterReasonId, EditLetterReasonExtraInfo, False)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError($"Error occurred saving letter to filesystem : { LetterQueueId }", ex)
        End Try
    End Sub
End Class
