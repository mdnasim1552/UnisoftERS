Imports System.IO

Module LetterGenerationModule
    Public Sub CheckCreateAndClearDirectory(directoryName As String)

        If Directory.Exists(directoryName) Then
            ClearWorkDirectory(directoryName)
        Else
            Directory.CreateDirectory(directoryName)
        End If
    End Sub

    Public Sub ClearWorkDirectory(directoryName As String)

        For Each deleteFile In Directory.GetFiles(directoryName, "*.*", SearchOption.TopDirectoryOnly)
            File.Delete(deleteFile)
        Next
    End Sub

    Public Function GetWorkdirectoryForPrint(appDataPath As String, userid As String) As String
        Dim workingDirectory = appDataPath + "\WorkDirectory\" + userid + "\Print\"
        If Not Directory.Exists(workingDirectory) Then
            Directory.CreateDirectory(workingDirectory)
        End If
        Return workingDirectory
    End Function

    Public Function GetWorkdirectory(appDataPath As String, userid As String) As String
        Dim workingDirectory = appDataPath + "\WorkDirectory\" + userid + "\"
        If Not Directory.Exists(workingDirectory) Then
            Directory.CreateDirectory(workingDirectory)
        End If
        Return workingDirectory
    End Function



    Public Function GetPDFPath(WorkDirectoryPath As String) As String
        CheckCreateAndClearDirectory(WorkDirectoryPath + "PDF\")
        Return WorkDirectoryPath + "PDF\"
    End Function
    Public Function GetTemplatePath(WorkDirectoryPath As String) As String
        CheckCreateAndClearDirectory(WorkDirectoryPath + "Template\")
        Return WorkDirectoryPath + "Template\"
    End Function
    Public Function GetAditionalDocumentPath(WorkDirectoryPath As String) As String
        CheckCreateAndClearDirectory(WorkDirectoryPath + "AdditionalDocument\")
        Return WorkDirectoryPath + "AdditionalDocument\"
    End Function
    Public Function GetMergedDocumentPath(WorkDirectoryPath As String) As String
        CheckCreateAndClearDirectory(WorkDirectoryPath + "Merged\")
        Return WorkDirectoryPath + "Merged\"
    End Function
    Public Function GetPrintPath(WorkDirectoryPath As String) As String
        CheckCreateAndClearDirectory(WorkDirectoryPath + "Print\")
        Return WorkDirectoryPath + "Print\"
    End Function
    Public Function GetEditPath(WorkDirectoryPath As String) As String
        CheckCreateAndClearDirectory(WorkDirectoryPath + "Edit\")
        Return WorkDirectoryPath + "Edit\"
    End Function
    Public Function GetEditDownloadPath(WorkDirectoryPath As String) As String
        CheckCreateAndClearDirectory(WorkDirectoryPath + "Edit\Download\")
        Return WorkDirectoryPath + "Edit\Download\"
    End Function
    Public Function GetAdditionalDocumentDownloadPath(WorkDirectoryPath As String) As String
        CheckCreateAndClearDirectory(WorkDirectoryPath + "Download\")
        Return WorkDirectoryPath + "Download\"
    End Function
End Module
