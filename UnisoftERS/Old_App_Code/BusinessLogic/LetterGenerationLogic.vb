Imports System.IO
Imports DevExpress.Pdf
Imports DevExpress.XtraRichEdit

Public Class LetterGenerationLogic
    Inherits System.Web.UI.Page

    Private ReadOnly dataAccess As LetterGeneration
    Private ReadOnly documentAccess As IDocumentDataAccess

    Public Sub New()
        dataAccess = New LetterGeneration()
        Dim letterStorageOption As String = ConfigurationManager.AppSettings("LetterStorageOption")
        Select Case letterStorageOption
            Case "FileSystem"
                documentAccess = New FileSystemDocumentDataAccess()
            Case "Azure"
                documentAccess = New AzureDocumentDataAccess()
            Case Else
                documentAccess = New DatabaseDocumentDataAccess()
        End Select
    End Sub

    Private Function GetTemplateData(templateId As Long) As DataRow
        Dim datatable As DataTable = dataAccess.GetTemapletDataForTemplateId(templateId)
        If datatable.Rows.Count <> 0 Then
            Return datatable.Rows(0)
        Else
            Return Nothing
        End If
    End Function

    Private Function GetEditedLetterContent(LetterQueueId As Integer) As Byte()
        Return documentAccess.GetEditedLetterForLetterQueueId(LetterQueueId)
    End Function

    Private Function GetAdditionalDocumentForLetterQueueId(letterQueueId As Integer) As DataTable
        Dim datatable = dataAccess.GetLetterQueueForLetterQueueId(letterQueueId)
        Dim AppointmentId = datatable.Rows(0)("AppointmentId")
        Dim OperationalHospitalId = datatable.Rows(0)("OperationalHospitalId")

        Return dataAccess.GetAdditionalDocumentForAppointment(AppointmentId, OperationalHospitalId)
    End Function

    Public Function CheckLetterExistsForLetterQueue(LetterQueueId As Integer) As Boolean
        If documentAccess.CheckLetterExistsForLetterQueue(LetterQueueId) = True Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Function GetFileType(fileBytes As Byte()) As DocumentFormat
        Using documentServer As New RichEditDocumentServer()
            Using documentStream As New MemoryStream(fileBytes)
                documentServer.LoadDocument(documentStream)
                Return documentServer.Options.DocumentSaveOptions.CurrentFormat
            End Using
        End Using
    End Function

    Private Function GenerateLetter(LetterQueueId As Int64, AppointmentId As Int64, AppointmentStatusId As Int64, OperationalHospitalId As Int64) As Byte()
        Dim templateId = dataAccess.GetTemplateIdForAppontmentStatusId(AppointmentStatusId, OperationalHospitalId)
        Dim templateData As DataRow = GetTemplateData(templateId)
        Dim templateDocument As Byte() = templateData("LetterContent")
        Dim mergedDocument As Byte()
        Dim docFormat = GetFileType(templateDocument)

        Using documentServer As New RichEditDocumentServer()
            Using documentStream As New MemoryStream(templateDocument)
                documentServer.LoadDocument(documentStream, docFormat)
            End Using
            documentServer.Options.MailMerge.DataSource = dataAccess.GetMailmergeDataByletterQueueId(LetterQueueId)
            Using mergeStream As New MemoryStream()
                documentServer.MailMerge(mergeStream, docFormat)
                mergedDocument = mergeStream.ToArray
                documentServer.LoadDocument(mergeStream)
            End Using
        End Using

        Return mergedDocument
    End Function

    Public Function GetLetterForLetterQueueId(LetterQueueId As Integer) As Byte()
        If CheckLetterExistsForLetterQueue(LetterQueueId) = True Then
            Return GetEditedLetterContent(LetterQueueId)
        Else
            Dim datatable = dataAccess.GetLetterQueueForLetterQueueId(LetterQueueId)

            Dim AppointmentId = datatable.Rows(0)("AppointmentId")
            Dim AppointmentStatusId = datatable.Rows(0)("AppointmentStatusId").ToString()
            Dim OperationalHospitalId = datatable.Rows(0)("OperationalHospitalId")

            Return GenerateLetter(LetterQueueId, AppointmentId, AppointmentStatusId, OperationalHospitalId)
        End If
    End Function

    Public Function GetLetterQueueIdForAppointmentId(AppointmentId As Integer) As Integer
        Return dataAccess.GetLetterQueueIdForAppointmentId(AppointmentId)
    End Function

    Public Function GetDocumentsForPrint(LetterQueueIds As List(Of Tuple(Of Integer, Boolean))) As Byte()
        Dim returnDocument As New MemoryStream()

        Using pdfDocumentProcessor As New PdfDocumentProcessor()
            pdfDocumentProcessor.CreateEmptyDocument(returnDocument)

            For Each letterQueueId In LetterQueueIds
                Dim doc = GetLetterForLetterQueueId(letterQueueId.Item1)

                Using documentServer As New RichEditDocumentServer()
                    documentServer.LoadDocument(New MemoryStream(doc))
                    Dim docMem = New MemoryStream()
                    documentServer.ExportToPdf(docMem)
                    pdfDocumentProcessor.AppendDocument(docMem)

                    If (letterQueueId.Item2 = True) Then
                        Dim datatable As DataTable = GetAdditionalDocumentForLetterQueueId(letterQueueId.Item1)

                        For Each datarows As DataRow In datatable.Rows
                            Dim docBytes() As Byte = CType(datarows("DocumentContent"), Byte())
                            Dim additionalDocMemoryStream = New MemoryStream(docBytes)
                            pdfDocumentProcessor.AppendDocument(additionalDocMemoryStream)
                        Next
                    End If
                End Using

                'Update Print count and latest Print Date
                dataAccess.UpdateLetterQueueEdited(letterQueueId.Item1, 0, Nothing, True)
            Next
        End Using

        Return returnDocument.ToArray()

    End Function

    Public Function GetAdditionalDocument(additionalDocumentId As Integer) As Byte()
        Dim datatable As DataTable = dataAccess.GetAdditionalDocumentDataForId(additionalDocumentId)
        Dim docBytes() As Byte = CType(datatable.Rows(0)("DocumentContent"), Byte())

        Return docBytes
    End Function

    Public Sub SaveLetter(LetterQueueId As Integer, EditedLetterContent() As Byte, Optional EditLetterReasonId As Integer? = 0, Optional EditLetterReasonExtraInfo As String = Nothing)
        documentAccess.SaveEditedLetterQueue(LetterQueueId, EditedLetterContent, EditLetterReasonId, EditLetterReasonExtraInfo)
    End Sub

End Class