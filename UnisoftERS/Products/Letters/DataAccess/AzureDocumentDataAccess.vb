Imports System.IO
Imports Microsoft.WindowsAzure.Storage
Imports Microsoft.WindowsAzure.Storage.File

Public Class AzureDocumentDataAccess
    Implements IDocumentDataAccess

    Private ReadOnly storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureFileStorageAccount"))
    Private ReadOnly letterStorageShare As String = If(Not (String.IsNullOrEmpty(ConfigurationManager.AppSettings("AzureLetterStorageShare"))), ConfigurationManager.AppSettings("AzureLetterStorageShare"), "letters")

    Public Function CheckLetterExistsForLetterQueue(LetterQueueId As Integer) As Boolean Implements IDocumentDataAccess.CheckLetterExistsForLetterQueue
        Try
            Dim fileClient As CloudFileClient = storageAccount.CreateCloudFileClient()
            Dim share As CloudFileShare = fileClient.GetShareReference(letterStorageShare)
            Dim rootDir As CloudFileDirectory = share.GetRootDirectoryReference()
            Dim file As CloudFile = rootDir.GetFileReference(LetterQueueId & ".sel")

            Return file.Exists
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError($"Error occurred while checking if letter exists on Azure File Share.  LetterQueueId : { LetterQueueId }", ex)
            Return False
        End Try
    End Function

    Public Function GetEditedLetterForLetterQueueId(LetterQueueId As Integer) As Byte() Implements IDocumentDataAccess.GetEditedLetterForLetterQueueId
        Try
            Dim fileClient As CloudFileClient = storageAccount.CreateCloudFileClient()
            Dim share As CloudFileShare = fileClient.GetShareReference(letterStorageShare)
            Dim rootDir As CloudFileDirectory = share.GetRootDirectoryReference()
            Dim file As CloudFile = rootDir.GetFileReference(LetterQueueId & ".sel")

            Dim downloadStream As New MemoryStream()
            file.DownloadToStream(downloadStream)
            Return downloadStream.ToArray()
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError($"Error occurred while retrieving letter from Azure File Share.  LetterQueueId : { LetterQueueId }", ex)
            Return Nothing
        End Try
    End Function

    Public Sub SaveEditedLetterQueue(LetterQueueId As Integer, EditedLetterContent() As Byte, Optional EditLetterReasonId As Integer? = 0, Optional EditLetterReasonExtraInfo As String = Nothing) Implements IDocumentDataAccess.SaveEditedLetterQueue
        Try
            Dim fileClient As CloudFileClient = storageAccount.CreateCloudFileClient()
            Dim share As CloudFileShare = fileClient.GetShareReference(letterStorageShare)
            share.CreateIfNotExists()
            Dim rootDir As CloudFileDirectory = share.GetRootDirectoryReference()
            Dim cloudFile As CloudFile = rootDir.GetFileReference(LetterQueueId & ".sel")

            Dim letterDoc As New MemoryStream(EditedLetterContent) With {
                .Position = 0
            }

            cloudFile.Create(letterDoc.Length)
            cloudFile.UploadFromStream(letterDoc)

            'Update database to reflect letter has been saved
            Dim lg As New LetterGeneration
            lg.UpdateLetterQueueEdited(LetterQueueId, EditLetterReasonId, EditLetterReasonExtraInfo, False)
        Catch ex As Exception
            LogManager.LogManagerInstance.LogError($"Error occurred while saving the letter on Azure File Share.  LetterQueueId : { LetterQueueId }", ex)
        End Try
    End Sub
End Class
