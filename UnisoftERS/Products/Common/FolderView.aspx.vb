Imports System.IO
Imports System.Net
Imports Microsoft.WindowsAzure.Storage
Imports Microsoft.WindowsAzure.Storage.File
Imports Microsoft.WindowsAzure.Storage.Blob

Public Class FolderView
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
            fileview.Visible = False
            Repeater1.DataSource = GetAzureImages()
            Repeater1.DataBind()
        Else
            Azureimage.Visible = False
            FileRepeater.DataSource = GetImageNames()
            FileRepeater.DataBind()
        End If
    End Sub

    Public Function GetAzureImages() As List(Of String)
        Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureFileStorageAccount"))
        Dim fileClient As CloudFileClient = storageAccount.CreateCloudFileClient()
        Dim share As CloudFileShare = fileClient.GetShareReference("imageportshare")
        Dim images As List(Of String) = New List(Of String)
        If share.Exists() Then
            Dim rootDir As CloudFileDirectory = share.GetRootDirectoryReference()
            Dim sampleDir As CloudFileDirectory = rootDir.GetDirectoryReference(Session("PortName"))
            If sampleDir.Exists() AndAlso sampleDir.ListFilesAndDirectories.Count > 0 Then
                For Each c As CloudFile In sampleDir.ListFilesAndDirectories
                    Dim stream As MemoryStream = New MemoryStream()
                    c.DownloadToStream(stream)
                    Dim imgBytes As Byte() = stream.ToArray()
                    Dim b64img As String = Convert.ToBase64String(imgBytes)
                    images.Add("data:image/jpeg;base64," + b64img)
                Next
                'Dim list = sampleDir.ListFilesAndDirectories.ToList()
                '' Now we have the images on the file storage, we need to move them over to the blob storage
                'For Each item In list
                '    images.Add(item.StorageUri.ToString())
                'Next
                Return images
            End If
        End If
    End Function

    Public Function GetImageNames() As List(Of String)
        'Get the imageport for the room
        Dim sessionRoomId As String = Session("RoomId")
        Dim sourcePath As String
        Dim sourceURL As String
        Dim portName As String
        Dim images As List(Of String) = New List(Of String)

        If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
            Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureFileStorageAccount"))
            Dim fileClient As CloudFileClient = storageAccount.CreateCloudFileClient()
            Dim share As CloudFileShare = fileClient.GetShareReference("imageportshare")
            If share.Exists() Then
                Dim rootDir As CloudFileDirectory = share.GetRootDirectoryReference()
                Dim sampleDir As CloudFileDirectory = rootDir.GetDirectoryReference(Session("PortName"))
                If sampleDir.Exists() AndAlso sampleDir.ListFilesAndDirectories.Count > 0 Then
                    Dim list = sampleDir.ListFilesAndDirectories.ToList()
                    For Each item In list
                        images.Add(item.StorageUri.ToString())
                    Next
                    Return images
                End If
            End If

        Else
            Try
                portName = Session("PortName")
                'Using db As New ERS.Data.GastroDbEntities
                '    Dim dbImagePort = db.ERS_ImagePort.First(Function(x) x.RoomId = sessionRoomId)
                '    portName = dbImagePort.PortName
                'End Using
                sourcePath = Session(Constants.SESSION_PHOTO_UNC) & "\" & portName
                If Right(Session(Constants.SESSION_PHOTO_URL), 1) = "/" Then
                    sourceURL = Session(Constants.SESSION_PHOTO_URL) & portName
                Else
                    sourceURL = Session(Constants.SESSION_PHOTO_URL) & "/" & portName
                End If
                'sourceURL = Session(Constants.SESSION_PHOTO_URL) & "/" & portName
            Catch ex As Exception
                LogManager.LogManagerInstance.LogError("Error getting Imageport - FolderView.aspx.vb GetImageNames", ex)
                fileLocation.Text = "Unable to get imageport"
                Return Nothing
            End Try


            Try
                ' First try to get the files from the URL, if it fails, try to get the files from the UNC path
                'sourceURL = "http://localhost/ERSPhotos/imageport_214b6e"
                Dim request As HttpWebRequest = CType(WebRequest.Create(sourceURL), HttpWebRequest)
                Dim response As HttpWebResponse = CType(request.GetResponse(), HttpWebResponse)
                'fileLocation.Text = sourceURL
                Using response
                    Dim reader = New StreamReader(response.GetResponseStream())
                    Using reader
                        Dim html As String = reader.ReadToEnd()
                        Dim regex As New Regex("\""([^""]*)\""")
                        Dim matches As MatchCollection = regex.Matches(html)
                        For Each match As Match In matches
                            Dim resolvedurl As String
                            resolvedurl = request.RequestUri.GetLeftPart(UriPartial.Authority) & Replace(match.ToString(), """", "")
                            If Right(resolvedurl, 4).ToLower() = ".jpg" OrElse Right(resolvedurl, 4).ToLower() = ".bmp" Then
                                images.Add(resolvedurl)
                            End If
                        Next
                    End Using
                End Using
                fileLocation.Text = images.Count() & " images on ImagePort " & portName
                Return images
            Catch ex As Exception
                ' URL failed, try to display via UNC
                LogManager.LogManagerInstance.LogError("Failed to get photos", ex)
                Try
                    'sourcePath = "\\ers\ImagePortShare\ImagePort_214b6e"
                    'fileLocation.Text = sourcePath
                    Dim directoryInfo As DirectoryInfo = New DirectoryInfo(sourcePath)
                    Dim fileInfo As FileInfo() = directoryInfo.GetFiles()

                    For Each file As FileInfo In fileInfo
                        If file.Extension.ToLower() = ".jpg" Or file.Extension.ToLower() = ".bmp" Then
                            images.Add(file.FullName)
                        End If
                    Next
                    fileLocation.Text = images.Count() & " images on ImagePort " & portName
                    Return images
                Catch ex1 As Exception
                    fileLocation.Text = "Failed to get photos"
                    LogManager.LogManagerInstance.LogError("Failed to get photos", ex)
                    Return Nothing
                End Try
                Return Nothing
            End Try
        End If
    End Function



End Class