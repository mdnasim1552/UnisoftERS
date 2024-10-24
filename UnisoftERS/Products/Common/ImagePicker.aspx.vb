Imports System.IO
Imports Microsoft.WindowsAzure
Imports Microsoft.WindowsAzure.Storage
Imports Microsoft.WindowsAzure.Storage.File
Imports Microsoft.WindowsAzure.Storage.Blob

Public Class ImagePicker
    Inherits PageBase

    'Public ReadOnly Property CacheFolderUri() As String
    '    Get
    '        If Right(Session(Constants.SESSION_PHOTO_URL), 1) = "/" Then
    '            Return Session(Constants.SESSION_PHOTO_URL) & "ERS/Photos/" & Session(Constants.SESSION_PROCEDURE_ID) & "/Temp"
    '        Else
    '            Return Session(Constants.SESSION_PHOTO_URL) & "/ERS/Photos/" & Session(Constants.SESSION_PROCEDURE_ID) & "/Temp"
    '        End If
    '        'Return Session(Constants.SESSION_PHOTO_URL) & "/ERS/Cache"
    '        'Return Session(Constants.SESSION_PHOTO_URL) & "/ERS/Photos/" & Session(Constants.SESSION_PROCEDURE_ID) & "/Temp"
    '    End Get
    'End Property

    'Public ReadOnly Property CacheFolderPath() As String
    '    Get
    '        'Return Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Cache"
    '        If Right(Session(Constants.SESSION_PHOTO_UNC), 1) = "\" Then
    '            Return Session(Constants.SESSION_PHOTO_UNC) & "ERS\Photos\" & Session(Constants.SESSION_PROCEDURE_ID) & "\Temp"
    '        Else
    '            Return Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & Session(Constants.SESSION_PROCEDURE_ID) & "\Temp"
    '        End If
    '    End Get
    'End Property

    Public ReadOnly Property ProcedureFolderUri() As String
        Get
            If Right(Session(Constants.SESSION_PHOTO_URL), 1) = "/" Then
                Return Session(Constants.SESSION_PHOTO_URL) & "ERS/Photos/" & Session(Constants.SESSION_PROCEDURE_ID)
            Else
                Return Session(Constants.SESSION_PHOTO_URL) & "/ERS/Photos/" & Session(Constants.SESSION_PROCEDURE_ID)
            End If
            'Return Session(Constants.SESSION_PHOTO_URL) & "/ERS/Cache"
            'Return Session(Constants.SESSION_PHOTO_URL) & "/ERS/Photos/" & Session(Constants.SESSION_PROCEDURE_ID) & "/Temp"
        End Get
    End Property

    Public ReadOnly Property ProcedureFolderPath() As String
        Get
            'Return Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Cache"
            If Right(Session(Constants.SESSION_PHOTO_UNC), 1) = "\" Then
                Return Session(Constants.SESSION_PHOTO_UNC) & "ERS\Photos\" & Session(Constants.SESSION_PROCEDURE_ID)
            Else
                Return Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & Session(Constants.SESSION_PROCEDURE_ID)
            End If
        End Get
    End Property

    Public ReadOnly Property control As String
        Get
            Return Request.QueryString("control")
        End Get
    End Property

    Public ReadOnly Property section As String
        Get
            Return Request.QueryString("section")
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Dim portName As String
            Dim sessionRoomId As String = Session("RoomId")

            portName = Session("PortName")

            If Not (String.IsNullOrEmpty(portName)) Then
                If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
                    Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureFileStorageAccount"))
                    Dim fileClient As CloudFileClient = storageAccount.CreateCloudFileClient()
                    Dim share As CloudFileShare = fileClient.GetShareReference("imageportshare")
                    If share.Exists() Then
                        Dim rootDir As CloudFileDirectory = share.GetRootDirectoryReference()
                        Dim sampleDir As CloudFileDirectory = rootDir.GetDirectoryReference(Session("PortName"))
                        If sampleDir.Exists() AndAlso sampleDir.ListFilesAndDirectories.Count > 0 Then
                            'ScriptManager.RegisterStartupScript(Me.Page, Me.Page.GetType, "downloaderror", "$('.notification-modal').show();", True)

                            Dim msg = "Some or all of your images were not downloaded sucessfully."
                            Utilities.SetNotificationStyle(DownloadErrorRadNotification, msg, True)
                            're-adjust size as previous function sets to 400
                            errMsg.InnerHtml = msg
                            DownloadErrorRadNotification.Width = "300"
                            DownloadErrorRadNotification.Height = "150"
                            DownloadErrorRadNotification.Show()
                            Exit Sub
                        End If
                    End If

                Else
                    Dim sourcePath = Session(Constants.SESSION_PHOTO_UNC) & "\" & portName
                    If Not Directory.Exists(sourcePath) Then
                        Dim msg = "The image port used for this procedure does not exist or could not be found."
                        Utilities.SetNotificationStyle(RadNotification1, msg, True)
                        're-adjust size as previous function sets to 400
                        errMsg.InnerHtml = msg
                        RadNotification1.Width = "300"
                        RadNotification1.Height = "150"
                        RadNotification1.Show()
                        Exit Sub
                    End If

                    Dim di As New DirectoryInfo(sourcePath)
                    If di.GetFiles().Any(Function(x) x.Extension = ".jpg") Then
                        'ScriptManager.RegisterStartupScript(Me.Page, Me.Page.GetType, "downloaderror", "$('.notification-modal').show();", True)


                        Dim msg = "Some or all of your images were not downloaded."
                        Utilities.SetNotificationStyle(DownloadErrorRadNotification, msg, True)
                        're-adjust size as previous function sets to 400
                        errMsg.InnerHtml = msg
                        DownloadErrorRadNotification.Width = "300"
                        DownloadErrorRadNotification.Height = "150"
                        DownloadErrorRadNotification.Show()
                        Exit Sub
                    End If
                End If
            End If


            LoadImages()
            End If
    End Sub

    Private Sub LoadImages()
        Try
            Dim dt As New DataTable
            dt.Columns.Add("RowId", GetType(Integer))
            dt.Columns.Add("PhotoName", GetType(String))
            dt.Columns.Add("ImageUrl", GetType(String))
            dt.Columns.Add("CreateDate", GetType(String))

            Dim iCount = 1
            Dim ImgPrefix As String = "ERS_"
            'Dim ImgPrefix_Curr As String  = 

            Dim dRow As DataRow
            Dim searchPatterns() As String = {"*.jpg", "*.bmp", "*.jpeg", "*.gif", "*.png", "*.tiff", "*.mp4", "*.mpg"}  ', "*.mov", "*.wmv", "*.flv", "*.avi", "*.mpeg"}

            Dim filesInFolder As New List(Of String)
            Dim imageFiles As New List(Of FileInfo)

            If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
                Dim blobstorageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureBlobStorageAccount"))

                Dim blobClient As CloudBlobClient
                Dim blobContainer As CloudBlobContainer

                blobClient = blobstorageAccount.CreateCloudBlobClient()
                blobContainer = blobClient.GetContainerReference("imageport")

                blobContainer.CreateIfNotExists()
                blobContainer.SetPermissions(New BlobContainerPermissions With {.PublicAccess = BlobContainerPublicAccessType.Blob})

                For Each b As CloudBlockBlob In blobContainer.ListBlobs(CStr(Session(Constants.SESSION_PROCEDURE_ID)) + "/Temp/", False)
                    dRow = dt.NewRow()
                    dRow("RowId") = iCount
                    dRow("PhotoName") = b.Name
                    dRow("ImageUrl") = b.Uri.ToString()
                    b.FetchAttributes()
                    If b.Metadata.Count > 0 Then
                        dRow("CreateDate") = b.Metadata("CreateDate")
                    End If
                    dt.Rows.Add(dRow)
                    iCount += 1
                Next
            Else
                If Directory.Exists(CacheFolderPath) Then
                    Dim di As New DirectoryInfo(CacheFolderPath)
                    For Each searchPattern As String In searchPatterns
                        Dim files = di.GetFiles(searchPattern, SearchOption.AllDirectories)
                        If files.Count > 0 Then imageFiles.AddRange(files)

                    Next
                    If imageFiles.Count > 0 Then filesInFolder.AddRange(imageFiles.OrderBy(Function(x) x.CreationTimeUtc).Select(Function(x) x.Name))


                    For Each fileName As String In filesInFolder
                        If fileName.Contains(".mp4") OrElse fileName.Contains(".mpg") Then Continue For

                        'If Not fileName.Contains(ImgPrefix) Then Continue For
                        If (Path.GetExtension(fileName) = ".bmp") Then
                            Dim sourcePath = Path.Combine(CacheFolderPath, fileName)
                            If File.Exists(Replace(sourcePath, ".bmp", ".mp4")) Then
                                fileName = Replace(fileName, ".bmp", ".mp4")
                            ElseIf File.Exists(Replace(sourcePath, ".bmp", ".mpg")) Then
                                fileName = Replace(fileName, ".bmp", ".mpg")
                            End If
                        End If

                        dRow = dt.NewRow()
                        dRow("RowId") = iCount
                        dRow("PhotoName") = fileName
                        dRow("ImageUrl") = CacheFolderUri & "/" & fileName
                        dRow("CreateDate") = New FileInfo(CacheFolderPath & "/" & fileName).CreationTime
                        dt.Rows.Add(dRow)
                        iCount += 1
                    Next
                End If
            End If

            If dt.Rows.Count > 0 Then
                ProcedureImagesRepeater.DataSource = dt
                ProcedureImagesRepeater.DataBind()
            Else
                NoImagesPanel.Visible = True
                ProductImagesPanel.Visible = False
            End If

        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading images", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading images")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub ProcedureImagesRepeater_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        If e.Item.DataItem IsNot Nothing Then
            Dim img As Image = e.Item.FindControl("ProcedureImage")
            Dim SelectImageLinkButton As LinkButton = DirectCast(e.Item.FindControl("ChooseImageRadButton"), LinkButton)
            Dim imageTimeStamp = If(CType(e.Item.DataItem, DataRowView).Row("CreateDate"), New FileInfo(img.ImageUrl).CreationTime)
            SelectImageLinkButton.Attributes("href") = "javascript:void(0);"
            SelectImageLinkButton.Attributes("onclick") = String.Format("return selectImage('{0}','{1}', '{2}');", control, section, CDate(imageTimeStamp).ToString("MM/dd/yyyy HH:mm"))
        End If
    End Sub

    Protected Sub RedownloadPhotosRadButton_Click(sender As Object, e As EventArgs)
        LoadPhotos()
        LoadImages()
    End Sub

End Class