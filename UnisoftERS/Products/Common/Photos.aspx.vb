Imports System.IO
Imports Telerik.Web.UI
Imports Microsoft.WindowsAzure
Imports Microsoft.WindowsAzure.Storage
Imports Microsoft.WindowsAzure.Storage.File
Imports Microsoft.WindowsAzure.Storage.Blob
Imports Hl7.Fhir.Model



Partial Class Products_Common_Photos
    Inherits PageBase

    Private returnMessage As String = ""

    Protected ReadOnly Property iProcedureId As Integer
        Get
            Return CInt(Session(Constants.SESSION_PROCEDURE_ID))
        End Get
    End Property

    Protected Sub Page_PreRender() Handles Me.PreRender
        If Not Page.IsPostBack Then
            If Not DataAdapter.IsProcedurePrinted(iProcedureId) Then
                Dim portId As Int32
                Dim portName As String
                Dim sessionRoomId As String = Session("RoomId")

                portName = Session("PortName")
                portId = Session("portId")
                'Using db As New ERS.Data.GastroDbEntities
                '    Dim dbImagePort = db.ERS_ImagePort.First(Function(x) x.RoomId = CInt(sessionRoomId))
                '    portName = dbImagePort.PortName
                '    portId = dbImagePort.ImagePortId
                'End Using

                If Not (String.IsNullOrEmpty(portName)) Then
                    If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
                        Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureFileStorageAccount"))
                        Dim fileClient As CloudFileClient = storageAccount.CreateCloudFileClient()
                        Dim share As CloudFileShare = fileClient.GetShareReference("imageportshare")
                        If share.Exists() Then
                            Dim rootDir As CloudFileDirectory = share.GetRootDirectoryReference()
                            Dim sampleDir As CloudFileDirectory = rootDir.GetDirectoryReference(Session("PortName"))
                            If sampleDir.Exists() AndAlso sampleDir.ListFilesAndDirectories.Count > 0 Then
                                ScriptManager.RegisterStartupScript(Me.Page, Me.Page.GetType, "downloaderror", "$('.notification-modal').show();", True)

                                Dim msg = "Some or all of your images were not downloaded sucessfully. Please refresh photos or contact your administrator."
                                Utilities.SetNotificationStyle(DownloadErrorRadNotification, msg, True)
                                're-adjust size as previous function sets to 400
                                errMsg.InnerHtml = msg
                                DownloadErrorRadNotification.Width = "500"
                                DownloadErrorRadNotification.Height = "150"
                                DownloadErrorRadNotification.Show()
                            End If
                        End If

                    Else
                        '07 Apr 2021 - Mahfuz fixed double backslash in middle, before portName

                        Dim sourcePath = ""
                        If Session(Constants.SESSION_PHOTO_UNC).ToString().EndsWith("\") Then
                            sourcePath = Session(Constants.SESSION_PHOTO_UNC) & portName
                        Else
                            sourcePath = Session(Constants.SESSION_PHOTO_UNC) & "\" & portName
                        End If ' & "\" & portName


                        If Not Directory.Exists(sourcePath) Then Exit Sub

                        Dim di As New DirectoryInfo(sourcePath)
                        Dim searchPatterns() As String = {".jpg", ".bmp", ".jpeg", ".gif", ".png", ".tiff", ".mp4", ".mpg"} ', "*.mov", "*.wmv", "*.flv", "*.avi", "*.mpeg"}
                        If di.GetFiles().Any(Function(x) searchPatterns.Contains(x.Extension)) Then
                            ScriptManager.RegisterStartupScript(Me.Page, Me.Page.GetType, "downloaderror", "$('.notification-modal').show();", True)

                            Dim msg = "Some or all of your images were not downloaded sucessfully. Please refresh photos or contact your administrator."
                            Utilities.SetNotificationStyle(DownloadErrorRadNotification, msg, True)
                            're-adjust size as previous function sets to 400
                            errMsg.InnerHtml = msg
                            DownloadErrorRadNotification.Width = "500"
                            DownloadErrorRadNotification.Height = "150"
                            DownloadErrorRadNotification.Show()
                        End If
                    End If


                End If
            End If
        End If
    End Sub

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadSites()
            LoadThumbnailRotator()

            'check for images
            If CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Colonoscopy Or CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Sigmoidscopy Then
                InitialImageCheckbox.Visible = False
            End If


            If Not String.IsNullOrEmpty(Request.QueryString("SiteId")) Then
                Dim sid As Integer = CInt(Request.QueryString("SiteId"))
                HeaderLabel.Text = GetHeaderText(sid)
                ProcedureRadioButton.Checked = False
                SiteRadioButton.Checked = False
                'SiteComboBox.FindItemByValue(sid).Selected = True
            Else
                HeaderLabel.Text = "Attach photo(s) to the Report"
                SiteRadioButton.Text = "Attach to a site"
            End If
            If Not String.IsNullOrEmpty(Request.QueryString("message")) Then

                Utilities.SetNotificationStyle(RadNotification1, Request.QueryString("message"))
                RadNotification1.Show()
            End If
        End If
    End Sub

    Protected Sub LoadThumbnailRotator()
        Try
            If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" OrElse Directory.Exists(CacheFolderPath) Then
                Dim dt = GetImages()
                Session("CacheDataTable") = dt

                ThumbnailRotator.DataSource = dt.DefaultView
                ThumbnailRotator.DataBind()

            Else
                MainDiv.Visible = False
                NoRowsDiv.Visible = True
            End If
        Catch ex As Exception
            MainDiv.Visible = False
            NoRowsDiv.Visible = True
            NoRowsDiv.InnerHtml = "Cache folder: invalid path or access denied."
        End Try
    End Sub

    Private Function GetImages() As DataTable
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

        'Prefix filenames of Images
        For i = 0 To searchPatterns.Count - 1
            searchPatterns(i) = Replace(searchPatterns(i), "*.", ImgPrefix & "*.")
            'If iFormerProcedureId > 0 Then
            '    searchPatterns = append
            '    searchPatterns.add.add(Replace(searchPatterns(i), "*.", ImgPrefix_Former & "*."))
            'End If
        Next

        Dim filesToSkip As New List(Of String)
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

            Dim di As New DirectoryInfo(CacheFolderPath)
            For Each searchPattern As String In searchPatterns
                imageFiles.AddRange(di.GetFiles(searchPattern, SearchOption.AllDirectories))
            Next

            filesInFolder.AddRange(imageFiles.OrderBy(Function(x) x.CreationTimeUtc).Select(Function(x) x.Name))

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
                dt.Rows.Add(dRow)
                iCount += 1
            Next
        End If

        Return dt
    End Function

    Private Sub ThumbnailRotator_ItemDataBound(sender As Object, e As RadRotatorEventArgs) Handles ThumbnailRotator.ItemDataBound
        Dim dt As DataTable = DirectCast(Session("CacheDataTable"), DataTable)
        Dim sourceUrl As String = dt.Rows(e.Item.Index)("ImageUrl")

        If CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Colonoscopy Or CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Sigmoidscopy Then
            If sourceUrl.ToLower.Contains("initial_entry_image") Then
                e.Item.CssClass = "initial-image"
                InitialImageCheckbox.Checked = True
            Else
                InitialImageCheckbox.Checked = False
            End If
        End If

        If (Path.GetExtension(sourceUrl) = ".mp4") Then
            Dim ThumbnailBinaryImage As RadBinaryImage = DirectCast(e.Item.FindControl("ThumbnailBinaryImage"), RadBinaryImage)
            ThumbnailBinaryImage.ImageUrl = sourceUrl.Replace(".mp4", ".bmp")
        End If
    End Sub

    Protected Sub ThumbnailRotator_DataBound(sender As Object, e As EventArgs) Handles ThumbnailRotator.DataBound
        If ThumbnailRotator.Items.Count > 0 Then
            LoadImage()
        Else
            MainDiv.Visible = False
            NoRowsDiv.Visible = True
        End If
    End Sub

    Protected Sub ThumbnailRotator_ItemClick(sender As Object, e As RadRotatorEventArgs) Handles ThumbnailRotator.ItemClick
        If Not PhotoImageEditor.Visible Then LoadImage(e.Item.Index)
    End Sub

    Private Sub LoadImage(Optional index As Integer = 0)
        If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
            LoadAzureImage(index)
        Else
            LoadFileImage(index)
        End If
    End Sub

    Private Sub LoadAzureImage(index As Integer)
        Dim blobstorageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureBlobStorageAccount"))

        Dim blobClient As CloudBlobClient
        Dim blobContainer As CloudBlobContainer

        blobClient = blobstorageAccount.CreateCloudBlobClient()
        blobContainer = blobClient.GetContainerReference("imageport")

        blobContainer.CreateIfNotExists()
        blobContainer.SetPermissions(New BlobContainerPermissions With {.PublicAccess = BlobContainerPublicAccessType.Blob})
        Dim procPrefix As String = CStr(Session(Constants.SESSION_PROCEDURE_ID)) + "/"

        If CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Colonoscopy Or CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Sigmoidscopy Then
            If blobContainer.ListBlobs(procPrefix + "\initial_entry_image", False).Count > 0 Then
                InitialImageCheckbox.Enabled = False
            End If
        End If
        Dim sourceURL As String = DisplayImage(index)
        If sourceURL.Length > 0 Then
            ImageDescriptionLabel.Text = String.Format("Image {0} of {1}", index + 1, ThumbnailRotator.Items.Count)
            Dim dt As DataTable = DirectCast(Session("CacheDataTable"), DataTable)
            If dt.Rows.Count > 0 Then
                ImageDateLabel.Text = dt.Rows(index)("CreateDate")
            Else
                ImageDateLabel.Text = "Unknown"
            End If

        End If

        If CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Colonoscopy Or CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Sigmoidscopy Then
            If sourceURL.ToLower.Contains("initial_entry_image") Then
                AttachButton.Enabled = False
                InitialImageCheckbox.Checked = True
            Else
                AttachButton.Enabled = True
                InitialImageCheckbox.Checked = False
            End If
        End If

    End Sub

    Private Sub LoadFileImage(index As Integer)

        If CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Colonoscopy Or CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Sigmoidscopy Then
            Dim di As New DirectoryInfo(CacheFolderPath)

            If di.GetFiles().Any(Function(x) x.Name.ToLower.Contains("initial_entry_image")) Then
                InitialImageCheckbox.Enabled = False
            End If
        End If

        Dim sourceURL As String = DisplayImage(index)
        If sourceURL.Length > 0 Then

            ImageDescriptionLabel.Text = String.Format("Image {0} of {1}", index + 1, ThumbnailRotator.Items.Count)
            Try
                Dim fi As New FileInfo(sourceURL.Replace(Session(Constants.SESSION_PHOTO_URL), Session(Constants.SESSION_PHOTO_UNC) & "\")) 'cannot use URI for fileinfo
                ImageDateLabel.Text = fi.CreationTime.ToString("dd/MM/yyyy HH:mm:ss")
            Catch ex As Exception
                LogManager.LogManagerInstance.LogError("Error occured while retreiving photos creation date/time from path: " + sourceURL.Replace(Session(Constants.SESSION_PHOTO_URL), Session(Constants.SESSION_PHOTO_UNC) & "\"), ex)
            End Try

            If CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Colonoscopy Or CInt(Session(Constants.SESSION_PROCEDURE_TYPE)) = ProcedureType.Sigmoidscopy Then
                If sourceURL.ToLower.Contains("initial_entry_image") Then
                    AttachButton.Enabled = False
                    InitialImageCheckbox.Checked = True
                Else
                    AttachButton.Enabled = True
                    InitialImageCheckbox.Checked = False
                End If
            End If
        End If
        Session("SelectedImageIndex") = index
    End Sub

    Public Function DisplayImage(index As Integer) As String
        If Session("CacheDataTable") IsNot Nothing Then
            Dim dt As DataTable = DirectCast(Session("CacheDataTable"), DataTable)
            If dt.Rows.Count > 0 Then
                Dim sourceUrl As String = dt.Rows(index)("ImageUrl")

                If (Path.GetExtension(sourceUrl) = ".mp4") Then
                    VideoPlayer.Source = sourceUrl
                    VideoPlayer.Visible = True
                    PhotoBinaryImage.Visible = False
                    'EditPhotoButton.Visible = False

                Else
                    PhotoBinaryImage.ImageUrl = sourceUrl
                    PhotoImageEditor.ImageUrl = sourceUrl
                    PhotoBinaryImage.Visible = True
                    VideoPlayer.Visible = False
                    'EditPhotoButton.Visible = True

                    If dt.Rows(index)("PhotoName").ToString().Contains("-modified") Then
                        ModifiedPhotoLabel.Visible = True
                        UndoChangesButton.Visible = True
                    Else
                        ModifiedPhotoLabel.Visible = False
                        UndoChangesButton.Visible = False
                    End If
                End If
                Return sourceUrl
            Else
                Return String.Empty
            End If
        Else
            Return String.Empty
        End If
    End Function

#Region "Editor"
    Protected Sub PhotoImageEditor_ImageSaving(sender As Object, e As ImageEditorSavingEventArgs) 'Handles PhotoImageEditor.ImageSaving
        'always overwrite the "-modified" file if exists
        Try
            Dim originalFileName = e.FileName '.Replace("-modified", "")

            Dim filePath As String = Directory.GetFiles(CacheFolderPath, originalFileName & ".*", SearchOption.AllDirectories)(0)

            Dim newFileName As String = String.Format("{0}-modified{1}", Path.GetFileNameWithoutExtension(filePath), Path.GetExtension(filePath))

            Dim img As ImageEditor.EditableImage = e.Image
            img.Image.Save(Path.Combine(CacheFolderPath, newFileName))

            If Not Directory.Exists(TempPhotosFolderPath) Then Directory.CreateDirectory(TempPhotosFolderPath)

            File.Move(Path.Combine(CacheFolderPath, originalFileName & Path.GetExtension(filePath)), Path.Combine(TempPhotosFolderPath, originalFileName & Path.GetExtension(filePath)))

            'CancelEditPhotoButton_Click(CancelEditPhotoButton, New EventArgs)

            e.Argument = "Image saved"
            e.Cancel = True
        Catch ex As Exception

        End Try
    End Sub

    Protected Sub RadImgEdt_ImageLoading(sender As Object, args As ImageEditorLoadingEventArgs)
        Dim img As New ImageEditor.EditableImage(PhotoBinaryImage.ImageUrl.Replace(CacheFolderUri, CacheFolderPath))
        args.Image = img
        args.Cancel = True
    End Sub

    'Protected Sub EditPhotoButton_Click(sender As Object, e As EventArgs) Handles EditPhotoButton.Click
    '    PhotoBinaryImage.Visible = False
    '    PhotoImageEditor.Visible = True
    '    EditPhotoButton.Visible = False
    '    CancelEditPhotoButton.Visible = True
    'End Sub

    'Protected Sub SaveEditPhotoButton_Click(sender As Object, e As EventArgs) Handles SaveEditPhotoButton.Click
    '    PhotoBinaryImage.Visible = True
    '    PhotoImageEditor.Visible = False
    '    EditPhotoButton.Visible = True
    '    CancelEditPhotoButton.Visible = False

    '    LoadThumbnailRotator()

    '    Dim selectedImageIndex = ThumbnailRotator.Items.Count
    '    LoadImage((ThumbnailRotator.Items.Count - 1))

    'End Sub

    'Protected Sub CancelEditPhotoButton_Click(sender As Object, e As EventArgs) Handles CancelEditPhotoButton.Click
    '    PhotoBinaryImage.Visible = True
    '    PhotoImageEditor.Visible = False
    '    EditPhotoButton.Visible = True
    '    CancelEditPhotoButton.Visible = False

    '    If Session("SelectedImageIndex") IsNot Nothing Then
    '        LoadImage(CInt(Session("SelectedImageIndex")))
    '    End If

    'End Sub

    Private Sub UndoChangesButton_Click(sender As Object, e As EventArgs) Handles UndoChangesButton.Click
        If Session("SelectedImageIndex") IsNot Nothing AndAlso Session("CacheDataTable") IsNot Nothing Then
            Dim dt As DataTable = DirectCast(Session("CacheDataTable"), DataTable)
            Dim selectedImageIndex = CInt(Session("SelectedImageIndex"))

            File.Delete(Path.Combine(CacheFolderPath, CStr(dt.Rows(selectedImageIndex)("PhotoName"))))

            Utilities.SetNotificationStyle(RadNotification1, "Photo reverted to original.")
            RadNotification1.Show()

            LoadThumbnailRotator()
        End If
    End Sub
#End Region
    Protected Sub AttachButton_Click(sender As Object, e As EventArgs) Handles AttachButton.Click
        CheckSelectedPhotos("Attach")
        AttachButton.Text = "Attach Photo"
    End Sub

    Private Sub CheckSelectedPhotos(src As String)
        If Session("CacheDataTable") Is Nothing Then Exit Sub
        Dim selectedPhotos As String = SelectedPhotosHiddenField.Value

        Dim arrSelectedPhotos() As String
        Dim siteId = Request.QueryString("SiteId")

        arrSelectedPhotos = selectedPhotos.Split(",")

        For Each PhotoIndex As String In arrSelectedPhotos
            If PhotoIndex.Trim <> "" Then
                If src = "Attach" Then
                    AttachPhotos(CInt(PhotoIndex))
                ElseIf src = "Delete" Then
                    DeletePhotos(CInt(PhotoIndex))
                End If
            End If
        Next
        ProcedureRadioButton.Checked = False
        SiteRadioButton.Checked = False
        LoadThumbnailRotator()
        If returnMessage <> "" Then
            If Request.RawUrl.Contains("?") Then
                If Request.RawUrl.IndexOf("message=") > 0 Then
                    Response.Redirect(Request.RawUrl.Remove(Request.RawUrl.IndexOf("message=") - 1, Request.RawUrl.Length() - Request.RawUrl.IndexOf("message=") + 1) + "&message=" + returnMessage, False)
                Else
                    Response.Redirect(Request.RawUrl + "&message=" + returnMessage, False)
                End If

            Else
                If Request.RawUrl.IndexOf("message=") > 0 Then
                    Response.Redirect(Request.RawUrl.Remove(Request.RawUrl.IndexOf("message=") - 1, Request.RawUrl.Length() - Request.RawUrl.IndexOf("message=") + 1) + "?message=" + returnMessage, False)
                Else
                    Response.Redirect(Request.RawUrl + "?message=" + returnMessage, False)
                End If
            End If
        Else
            Response.Redirect(Request.RawUrl, False)
        End If
    End Sub

    Private Sub AttachPhotos(selectedImageIndex As Integer)


        'If Session("SelectedImageIndex") IsNot Nothing AndAlso Session("CacheDataTable") IsNot Nothing Then
        Try
            If ProcedureRadioButton.Checked Or (SiteRadioButton.Checked And Not SiteComboBox.SelectedValue = "") Or Not String.IsNullOrEmpty(Request.QueryString("SiteId")) Then

                Dim dt As DataTable = DirectCast(Session("CacheDataTable"), DataTable)
                ' Dim selectedImageIndex = CInt(Session("SelectedImageIndex"))
                Dim siteId As Nullable(Of Integer)
                If ProcedureRadioButton.Checked Then
                    siteId = Nothing
                ElseIf SiteRadioButton.Checked Then
                    siteId = SiteComboBox.SelectedValue
                ElseIf Not String.IsNullOrEmpty(Request.QueryString("SiteId")) Then
                    siteId = CInt(Request.QueryString("SiteId"))
                Else
                    'Utilities.SetNotificationStyle(RadNotification1, "Please choose where to add photo to from the options at the top of the page.", True)
                    'RadNotification1.Show()
                    returnMessage = "Please choose where to add photo to from the options at the top of the page."
                    Exit Sub
                End If
                If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
                    AttachAzurePhoto(dt.Rows(selectedImageIndex), siteId)
                Else
                    AttachFilePhoto(dt.Rows(selectedImageIndex), siteId)
                End If

                'Utilities.SetNotificationStyle(RadNotification1, "Photo added successfully.")
                'RadNotification1.Show()
                returnMessage = "Photo added successfully."

            Else
                'Utilities.SetNotificationStyle(RadNotification1, "Please choose where to add photo to from the options at the top of the page.", True)
                'RadNotification1.Show()
                returnMessage = "Please choose where to add photo to from the options at the top of the page."
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured while attaching photo(s) to the report!!", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There was a problem attaching photo(s) to the report.")
            RadNotification1.Show()
        End Try
        'End If
    End Sub

    Private Sub AttachFilePhoto(dr As DataRow, siteId As Nullable(Of Integer))
        Dim sourcePath = Path.Combine(CacheFolderPath, CStr(dr("PhotoName")))
        Dim fi As New FileInfo(sourcePath)
        Dim destinationPath = Path.Combine(PhotosFolderPath, fi.Name)

        If Not Directory.Exists(PhotosFolderPath) Then Directory.CreateDirectory(PhotosFolderPath)

        Dim originalCreationTime = File.GetCreationTimeUtc(sourcePath)
        If File.Exists(sourcePath) And Not File.Exists(destinationPath) Then
            Try
                File.Copy(sourcePath, destinationPath)
                File.SetCreationTimeUtc(destinationPath, originalCreationTime) 'need to keep the time stamp incase needed for the TTC and WT details
            Catch ex As Exception
                LogManager.LogManagerInstance.LogError("Error occured while attaching the timestamp to photo" & CStr(dr("PhotoName")), ex)
            End Try

        End If

        'copy thumbnail too in case if videos
        If (Path.GetExtension(sourcePath) = ".mp4") Then
            If File.Exists(sourcePath.Replace(".mp4", ".bmp")) And Not File.Exists(destinationPath.Replace(".mp4", ".bmp")) Then
                File.Copy(sourcePath.Replace(".mp4", ".bmp"), destinationPath.Replace(".mp4", ".bmp"), overwrite:=True)
            End If
        End If

        DataAdapter.SavePhoto(fi.Name,
                                        iProcedureId,
                                        siteId,
                                        fi.CreationTimeUtc)


        If Not Directory.Exists(TempPhotosFolderPath) Then Directory.CreateDirectory(TempPhotosFolderPath)
        Dim tempPath = Path.Combine(TempPhotosFolderPath, fi.Name)

        If File.Exists(tempPath) Then File.Delete(tempPath) 'in case file already exists in tempPath
        File.Move(sourcePath, tempPath) 'move/photo to temp to avoid reading to another site (only after successful save incase of any DB complications 
        If (Path.GetExtension(sourcePath) = ".mp4") Then
            File.Delete(tempPath.Replace(".mp4", ".bmp")) 'in case file already exists in tempPath
            File.Move(sourcePath.Replace(".mp4", ".bmp"), tempPath.Replace(".mp4", ".bmp")) 'move video bmp
        End If


        File.SetCreationTimeUtc(tempPath, originalCreationTime)
        Using lm As New AuditLogManager
            If IsNothing(siteId) Then
                lm.WriteActivityLog(EVENT_TYPE.Insert, "Photo added: " & destinationPath & " to procedure: " & iProcedureId)
            Else
                lm.WriteActivityLog(EVENT_TYPE.Insert, "Photo added: " & destinationPath & " to site: " & CStr(siteId))
            End If
        End Using
    End Sub

    Private Sub AttachAzurePhoto(dr As DataRow, siteId As Nullable(Of Integer))
        Dim photoName = CStr(dr("PhotoName"))
        Dim blobstorageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureBlobStorageAccount"))

        Dim blobClient As CloudBlobClient
        Dim blobContainer As CloudBlobContainer

        blobClient = blobstorageAccount.CreateCloudBlobClient()
        blobContainer = blobClient.GetContainerReference("imageport")

        blobContainer.CreateIfNotExists()
        blobContainer.SetPermissions(New BlobContainerPermissions With {.PublicAccess = BlobContainerPublicAccessType.Blob})
        ' move photo/change blob name 
        Dim imageBlob As CloudBlockBlob = blobContainer.GetBlockBlobReference(photoName)
        Dim newImageBlob As CloudBlockBlob = blobContainer.GetBlockBlobReference(photoName.Replace("/Temp", ""))
        newImageBlob.StartCopy(imageBlob)
        While newImageBlob.CopyState.Status = CopyStatus.Pending
            Threading.Thread.Sleep(100)
        End While

        If newImageBlob.CopyState.Status = CopyStatus.Success Then
            DataAdapter.SavePhoto(newImageBlob.Uri.ToString(),
                                    iProcedureId,
                                    siteId,
                                    dr("CreateDate"))
            imageBlob.FetchAttributes()
            If imageBlob.Metadata.Count > 0 Then
                newImageBlob.Metadata.Add("CreateDate", imageBlob.Metadata("CreateDate"))
                newImageBlob.SetMetadata()
            End If


            imageBlob.Delete()
        End If

    End Sub

    Private Sub LoadSites()
        Dim dtSites = DataAdapter.GetSitesWithDescription(iProcedureId)

        If Not String.IsNullOrWhiteSpace(Request.QueryString("SiteId")) Then
            Dim siteId As Integer = CInt(Request.QueryString("SiteId"))
            For Each dr As DataRow In dtSites.Rows
                If CInt(dr("SiteId")) = siteId Then
                    dtSites.Rows.Remove(dr)
                    Exit For
                End If
            Next
        End If

        If dtSites.Rows.Count > 0 Then
            With SiteComboBox
                .Items.Clear()
                .DataSource = dtSites
                .DataTextField = "SiteDescription"
                .DataValueField = "SiteId"
                .DataBind()
            End With
        Else
            ProcedureRadioButton.Checked = True
            SiteRadioButton.Enabled = False
        End If
    End Sub

    Private Function GetHeaderText(ByVal siteId As Integer) As String
        Dim dtSite As DataTable = DataAdapter.GetSiteDetails(siteId)
        Return "Attach photo(s) to the <b>" + dtSite.Rows(0)("AntPosDescription") + "</b> site in <b>" + dtSite.Rows(0)("Region") + "</b> region"
    End Function

    Protected Sub DeleteButton_Click(sender As Object, e As EventArgs) Handles DeleteButton.Click
        CheckSelectedPhotos("Delete")

    End Sub

    Private Sub DeletePhotos(selectedImageIndex As Integer)
        ' If Session("SelectedImageIndex") IsNot Nothing AndAlso Session("CacheDataTable") IsNot Nothing Then
        Dim dt As DataTable = DirectCast(Session("CacheDataTable"), DataTable)
        'Dim selectedImageIndex = CInt(Session("SelectedImageIndex"))

        If Not Directory.Exists(TempPhotosFolderPath) Then Directory.CreateDirectory(TempPhotosFolderPath)
        Dim destPath As String = Path.Combine(TempPhotosFolderPath, CStr(dt.Rows(selectedImageIndex)("PhotoName")))

        If File.Exists(destPath) Then File.Delete(destPath) 'in case file already exists in destPath
        File.Move(Path.Combine(CacheFolderPath, CStr(dt.Rows(selectedImageIndex)("PhotoName"))), destPath)

        'Utilities.SetNotificationStyle(RadNotification1, "Photo(s) deleted from cache successfully.")
        'RadNotification1.Show()
        returnMessage = "Photo(s) deleted from cache successfully."
        'LoadThumbnailRotator()
        'End If
    End Sub

    Protected Sub ProcedureStartYesButton_Click(sender As Object, e As EventArgs)

        MarkAsInitialImage(Session("SelectedImageIndex"), Session(Constants.SESSION_PROCEDURE_ID))
        InitialImageCheckbox.Enabled = False
        LoadThumbnailRotator()
    End Sub

    Protected Sub ProcedureStartNoButton_Click(sender As Object, e As EventArgs)
        SaveIntubationStartDateTime(CDate("01/01/1901"))
    End Sub

    Sub SaveIntubationStartDateTime(startDate As Date)
        Using db As New ERS.Data.GastroDbEntities
            Dim record = db.ERS_ColonExtentOfIntubation.Where(Function(x) x.ProcedureId = iProcedureId).FirstOrDefault()
            If record Is Nothing Then record = New ERS.Data.ERS_ColonExtentOfIntubation()
            record.IntubationStartDateTime = startDate

            If record.ExtId = 0 Then
                record.ProcedureId = iProcedureId
                db.ERS_ColonExtentOfIntubation.Add(record)
            Else
                db.ERS_ColonExtentOfIntubation.Attach(record)
                db.Entry(record).State = Entity.EntityState.Modified
            End If

            db.SaveChanges()
            Dim da As DataAccess = New DataAccess()
            da.Update_ERS_Extent_Limiting_Factors(iProcedureId)
        End Using
    End Sub

#Region "Webmethods"
    <Services.WebMethod()>
    Public Shared Function InitialImageSet(procedureId As Integer)
        Using db As New ERS.Data.GastroDbEntities
            If (From p In db.ERS_Procedures Where p.ProcedureId = procedureId Select p.ProcedureType).FirstOrDefault() = CInt(ProcedureType.Colonoscopy) Then 'for colon only
                If db.ERS_ColonExtentOfIntubation.Any(Function(x) x.ProcedureId = procedureId And x.IntubationStartDateTime IsNot Nothing) Then
                    Return True 'has been set regardless of value as both yes or no marks an entry
                Else
                    Return False 'not logged
                End If
            Else
                Return Nothing
            End If
        End Using
    End Function

    Private Shared Function ImageDT() As DataTable
        Dim dt As New DataTable
        dt.Columns.Add("RowId", GetType(Integer))
        dt.Columns.Add("PhotoName", GetType(String))
        dt.Columns.Add("ImageUrl", GetType(String))

        Dim iCount = 1
        Dim ImgPrefix As String = "ERS_"
        'Dim ImgPrefix_Curr As String  = 

        Dim dRow As DataRow
        Dim searchPatterns() As String = {"*.jpg", "*.bmp", "*.jpeg", "*.gif", "*.png", "*.tiff", "*.mp4", "*.mpg"}  ', "*.mov", "*.wmv", "*.flv", "*.avi", "*.mpeg"}

        'Prefix filenames of Images
        For i = 0 To searchPatterns.Count - 1
            searchPatterns(i) = Replace(searchPatterns(i), "*.", ImgPrefix & "*.")
        Next

        Dim filesToSkip As New List(Of String)
        Dim filesInFolder As New List(Of String)
        Dim imageFiles As New List(Of FileInfo)

        Dim cfp = HttpContext.Current.Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID) & "\Temp"
        Dim di As New DirectoryInfo(cfp)
        For Each searchPattern As String In searchPatterns
            imageFiles.AddRange(di.GetFiles(searchPattern, SearchOption.AllDirectories))
        Next

        filesInFolder.AddRange(imageFiles.OrderBy(Function(x) x.CreationTimeUtc).Select(Function(x) x.Name))

        For Each fileName As String In filesInFolder
            If fileName.Contains(".mp4") OrElse fileName.Contains(".mpg") Then Continue For

            'If Not fileName.Contains(ImgPrefix) Then Continue For
            If (Path.GetExtension(fileName) = ".bmp") Then
                Dim sourcePath = Path.Combine(cfp, fileName)
                If File.Exists(Replace(sourcePath, ".bmp", ".mp4")) Then
                    fileName = Replace(fileName, ".bmp", ".mp4")
                ElseIf File.Exists(Replace(sourcePath, ".bmp", ".mpg")) Then
                    fileName = Replace(fileName, ".bmp", ".mpg")
                End If
            End If

            dRow = dt.NewRow()
            dRow("RowId") = iCount
            dRow("PhotoName") = fileName
            dRow("ImageUrl") = fileName
            dt.Rows.Add(dRow)
            iCount += 1
        Next

        Return dt
    End Function

    <Services.WebMethod()>
    Public Shared Sub MarkAsInitialImage(selectedImageIndex As Integer, procId As Integer)
        'Dim dt = ImageDT()
        If HttpContext.Current.Session("CacheDataTable") IsNot Nothing Then
            Dim dt As DataTable = DirectCast(HttpContext.Current.Session("CacheDataTable"), DataTable)

            Dim fileDateTimeStamp
            Dim sourcePath As String
            Dim fi As FileInfo
            If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
                fileDateTimeStamp = dt.Rows(selectedImageIndex)("CreateDate")
            Else
                Dim CacheFolderPath = HttpContext.Current.Session(Constants.SESSION_PHOTO_UNC) & "\ERS\Photos\" & HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID) & "\Temp"
                sourcePath = Path.Combine(CacheFolderPath, CStr(dt.Rows(selectedImageIndex)("PhotoName")))
                fi = New FileInfo(sourcePath)
                fileDateTimeStamp = fi.CreationTimeUtc
            End If
            HttpContext.Current.Session(Constants.SESSION_EXAMINATION_START_TIME) = fileDateTimeStamp
            'save to DB (incase session is lost ie browser closes unexpectedly)
            Using db As New ERS.Data.GastroDbEntities
                Dim record = db.ERS_ColonExtentOfIntubation.Where(Function(x) x.ProcedureId = procId).FirstOrDefault()
                If record Is Nothing Then record = New ERS.Data.ERS_ColonExtentOfIntubation()
                record.IntubationStartDateTime = CDate(fileDateTimeStamp)

                If record.ExtId = 0 Then
                    record.ProcedureId = procId
                    db.ERS_ColonExtentOfIntubation.Add(record)
                Else
                    db.ERS_ColonExtentOfIntubation.Attach(record)
                    db.Entry(record).State = Entity.EntityState.Modified
                End If

                db.SaveChanges()
                Dim da As DataAccess = New DataAccess()
                da.Update_ERS_Extent_Limiting_Factors(procId)
            End Using

            If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
                Dim initialImage As String = CStr(HttpContext.Current.Session(Constants.SESSION_PROCEDURE_ID)) + "\_initial_entry_image.jpg"
                Dim blobstorageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureBlobStorageAccount"))

                Dim blobClient As CloudBlobClient
                Dim blobContainer As CloudBlobContainer

                blobClient = blobstorageAccount.CreateCloudBlobClient()
                blobContainer = blobClient.GetContainerReference("imageport")

                blobContainer.CreateIfNotExists()
                blobContainer.SetPermissions(New BlobContainerPermissions With {.PublicAccess = BlobContainerPublicAccessType.Blob})
                ' move photo/change blob name 
                Dim imageBlob As CloudBlockBlob = blobContainer.GetBlockBlobReference(dt.Rows(selectedImageIndex)("PhotoName"))
                Dim newImageBlob As CloudBlockBlob = blobContainer.GetBlockBlobReference(initialImage)
                newImageBlob.StartCopy(imageBlob)
                While newImageBlob.CopyState.Status = CopyStatus.Pending
                    Threading.Thread.Sleep(100)
                End While

                If newImageBlob.CopyState.Status = CopyStatus.Success Then
                    imageBlob.FetchAttributes()
                    If imageBlob.Metadata.Count > 0 Then
                        newImageBlob.Metadata.Add("CreateDate", imageBlob.Metadata("CreateDate"))
                        newImageBlob.SetMetadata()
                    End If
                    imageBlob.Delete()
                End If
            Else
                'rename file and keep in folder 
                Dim initialImage = sourcePath.Replace(fi.Extension, "") & "_initial_entry_image" & fi.Extension
                File.Move(sourcePath, initialImage)
                Try
                    Dim fi2 As New FileInfo(initialImage)
                    fi2.CreationTimeUtc = fileDateTimeStamp
                Catch ex As Exception

                End Try
            End If
        End If
    End Sub

    Protected Sub RefreshPhotosLinkButton_Click(sender As Object, e As EventArgs)
        Try
            LoadPhotos()
            LoadThumbnailRotator()

            If ThumbnailRotator.Items.Count > 0 Then
                MainDiv.Visible = True
                NoRowsDiv.Visible = False
            ElseIf Session("SelectedImageIndex") IsNot Nothing Then
                LoadImage(CInt(Session("SelectedImageIndex")))
            End If
        Catch ex As Exception
            Dim errorLogRef As String
            errorLogRef = LogManager.LogManagerInstance.LogError("Error occured refreshing photos!!", ex)

            Utilities.SetErrorNotificationStyle(RadNotification1, errorLogRef, "There was a problem refreshing photos.")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Sub RadAjaxManager1_AjaxRequest(sender As Object, e As AjaxRequestEventArgs)

        If e.Argument.ToLower = "initial-image-set" Then
            LoadThumbnailRotator()

            If ThumbnailRotator.Items.Count > 0 Then
                MainDiv.Visible = True
                NoRowsDiv.Visible = False
            ElseIf Session("SelectedImageIndex") IsNot Nothing Then
                LoadImage(CInt(Session("SelectedImageIndex")))
            End If
        ElseIf e.Argument.ToLower = "disable-checkbox" Then
            InitialImageCheckbox.Enabled = False
        End If
    End Sub
#End Region
End Class
