Imports System.IO
Imports Microsoft.Azure.Storage
Imports Microsoft.WindowsAzure.Storage.Blob
Imports Telerik.Web.UI

Public Class Products_Common_AttachedPhotos
    Inherits PageBase

    Protected ReadOnly Property SiteId As Integer
        Get
            If Not String.IsNullOrWhiteSpace(Request.QueryString("siteid")) Then
                Return CInt(Request.QueryString("siteid"))
            Else
                Return 0
            End If
        End Get
    End Property

    Protected ReadOnly Property Region As String
        Get
            If Not String.IsNullOrWhiteSpace(Request.QueryString("reg")) Then
                Return Request.QueryString("reg")
            Else
                Return ""
            End If
        End Get
    End Property

    Protected ReadOnly Property iProcedureId As Integer
        Get
            Return CInt(Session(Constants.SESSION_PROCEDURE_ID))
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then

            loadPhotosList()
            LoadVideos()

            'media check and hise/show panel accordingly

            Dim videoCount = VideosListView.Items.Count
            Dim imageCount = PhotosImageGallery.Items.Count

            If VideosListView.Visible = False And PhotosImageGallery.Visible = False Then
                NoMediaDiv.Visible = True
            Else
                NoMediaDiv.Visible = False
            End If
        End If
    End Sub

    Private Sub loadPhotosList()
        Dim dt = DataAdapter.GetSitePhotos(SiteId, iProcedureId).AsEnumerable.Where(Function(x) Not Path.GetExtension(CStr(x("PhotoName"))) = ".mp4")
        Dim dtSitePhotos As New DataTable
        If dt.Count > 0 Then
            dtSitePhotos = dt.CopyToDataTable
        End If

        If dtSitePhotos IsNot Nothing AndAlso dtSitePhotos.Rows.Count > 0 Then
            'PhotosListView.DataSource = dt
            'PhotosListView.DataBind()
            Dim siteDescription As String = DataAdapter.GetSiteDescription(SiteId)


            If dtSitePhotos.Rows.Count > 0 Then
                dtSitePhotos.Columns.Add("ImageUrl")
                dtSitePhotos.Columns.Add("ImageThumbnailUrl")
                dtSitePhotos.Columns.Add("SiteDescription")
                dtSitePhotos.AcceptChanges()

                For Each dr As DataRow In dtSitePhotos.Rows
                    If Path.GetExtension(CStr(dr("PhotoName"))) = ".mp4" Then
                        Continue For
                    End If
                    Dim photoURL As String
                    If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
                        photoURL = dr("PhotoName")
                    Else
                        If CBool(Session("IsERSViewer")) Then 'displaying the 'image not avaiable' should not apply to ERS Viewer
                            photoURL = PhotosFolderUri & "/" & dr("PhotoName")
                        Else
                            If File.Exists(PhotosFolderPath & "/" & dr("PhotoName")) Then
                                photoURL = PhotosFolderUri & "/" & dr("PhotoName")
                            Else
                                photoURL = Page.Request.Url.GetLeftPart(UriPartial.Authority) & "/" & Request.ApplicationPath & "/Images/image-not-found.jpg"
                            End If
                        End If
                    End If

                    dr("ImageUrl") = photoURL
                    dr("ImageThumbnailUrl") = photoURL
                    dr("SiteDescription") = siteDescription

                    'If (Path.GetExtension(CStr(dr("ImageUrl"))) = ".mp4") Then
                    '    dr("ImageThumbnailUrl") = CStr(dr("ImageUrl")).Replace(".mp4", ".bmp")
                    'End If
                Next
                PhotosImageGallery.DataSource = dtSitePhotos
                PhotosImageGallery.DataKeyNames = {"PhotoId"}
            Else
                PhotosImageGallery.Visible = False
            End If


            'liMovePhotos.Visible = SiteId > 0
        Else
            PhotosImageGallery.Visible = False
            'NoImagesDiv.Visible = True
        End If


    End Sub

    Private Sub LoadVideos()
        Dim dtSitesVideos As DataTable = GetSitesVideos()

        If dtSitesVideos IsNot Nothing Then
            For Each dr In dtSitesVideos.Rows
                If (Path.GetExtension(CStr(dr("ImageUrl"))) = ".mp4") Then
                    Dim item As New RadLightBoxItem()
                    item.Title = CStr(dr("SiteDescription"))
                    item.Description = CStr(dr("SiteDescription"))
                    item.ItemTemplate = New LightBoxMediaTemplate(CStr(dr("ImageUrl")), CInt(dr("PhotoId")))
                End If
            Next

            'where procedure has no sites, disable/hide this
            'liMoveVidoes.Visible = SiteId > 0
        End If
    End Sub

    Protected Sub SitesWithPhotosObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SitePhotosObjectDataSource.Selecting
        e.InputParameters("siteId") = SiteId
        e.InputParameters("procedureId") = SiteId
    End Sub

    Protected Sub PhotosImageGallery_NeedDataSource(ByVal sender As Object, ByVal e As ImageGalleryNeedDataSourceEventArgs)

        'Dim PhotosImageGallery As RadImageGallery = DirectCast(sender, RadImageGallery)
        'Dim lvItem As ListViewDataItem = DirectCast(DirectCast(sender, RadImageGallery).NamingContainer, ListViewDataItem)
        'Dim siteIdObj = PhotosListView.DataKeys(lvItem.DataItemIndex).Values("SiteId")
        'Dim sId As Integer = If(Not IsDBNull(siteIdObj), CInt(siteIdObj), 0)

        'Dim siteDescription As String = DataAdapter.GetSiteDescription(sId)

        ''Dim drItem As DataRow = DirectCast(lvItem.DataItem, DataRowView).Row
        ''PhotosImageGallery.DataSource = DataAdapter.GetSitePhotos(If(Not IsDBNull(drItem("SiteId")), CInt(drItem("SiteId")), 0), CInt(Session(Constants.SESSION_PROCEDURE_ID)))
        'Dim dtSitePhotos = DataAdapter.GetSitePhotos(sId, CInt(Session(Constants.SESSION_PROCEDURE_ID)))

        'For i As Integer = dtSitePhotos.Rows.Count - 1 To 0 Step -1
        '    If Path.GetExtension(CStr(dtSitePhotos.Rows(i)("PhotoName"))) = ".mp4" Then
        '        dtSitePhotos.Rows.Remove(dtSitePhotos.Rows(i))
        '    End If
        'Next

        'If dtSitePhotos.Rows.Count > 0 Then
        '    dtSitePhotos.Columns.Add("ImageUrl")
        '    dtSitePhotos.Columns.Add("ImageThumbnailUrl")
        '    dtSitePhotos.Columns.Add("SiteDescription")
        '    dtSitePhotos.AcceptChanges()

        '    For Each dr As DataRow In dtSitePhotos.Rows
        '        Dim photoURL As String
        '        If ConfigurationManager.AppSettings("IsAzure") = "true" Then
        '            photoURL = dr("PhotoName")
        '        Else
        '            If CBool(Session("IsERSViewer")) Then 'displaying the 'image not avaiable' should not apply to ERS Viewer
        '                photoURL = PhotosFolderUri & "/" & dr("PhotoName")
        '            Else
        '                If File.Exists(PhotosFolderPath & "/" & dr("PhotoName")) Then
        '                    photoURL = PhotosFolderUri & "/" & dr("PhotoName")
        '                Else
        '                    photoURL = Page.Request.Url.GetLeftPart(UriPartial.Authority) & "/" & Request.ApplicationPath & "/Images/image-not-found.jpg"
        '                End If
        '            End If
        '        End If

        '        dr("ImageUrl") = photoURL
        '        dr("ImageThumbnailUrl") = photoURL
        '        dr("SiteDescription") = siteDescription

        '        If (Path.GetExtension(CStr(dr("ImageUrl"))) = ".mp4") Then
        '            dr("ImageThumbnailUrl") = CStr(dr("ImageUrl")).Replace(".mp4", ".bmp")
        '        End If
        '    Next
        '    PhotosImageGallery.DataSource = dtSitePhotos
        '    PhotosImageGallery.DataKeyNames = {"PhotoId"}
        'End If
    End Sub

    Protected Sub PhotosImageGallery_OnItemDataBound(ByVal sender As Object, ByVal e As ImageGalleryItemEventArgs)
        Dim drItem As DataRow = DirectCast(e.ListViewItem.DataItem, System.Data.DataRowView).Row
        If drItem("SiteDescription") IsNot Nothing Then
            DirectCast(e.Item, ImageGalleryItem).Title = Convert.ToString(drItem("SiteDescription"))
        End If
        ' this is used in Detach Photo function
        If drItem("PhotoId") IsNot Nothing Then
            DirectCast(e.Item, ImageGalleryItem).Description = Convert.ToInt32(drItem("PhotoId"))
        End If
    End Sub

    Protected Sub PatProcAjaxMgr_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs)
        If e.Argument.ToLower.StartsWith("dna") Then
            Response.Redirect("Gastro/OtherData/OGD/Indications.aspx", False)
        ElseIf e.Argument.ToLower.StartsWith("load_video") Then
            Dim videoIndex = e.Argument.ToString.Split("|")(1)
            Dim videoURL = CType(VideosListView.Items(videoIndex).FindControl("ThumbnailImage"), Image).ImageUrl.Replace(".bmp", ".mp4")
            AttachedVideoPlayer.Source = videoURL
            '"RadMediaPlayer" & CStr(procedureId)
            Dim vidPlayer = CType(VideosLightBox.FindControl("RadMediaPlayer" & CStr(iProcedureId)), RadMediaPlayer)
            If vidPlayer IsNot Nothing Then
                vidPlayer.Source = videoURL

            End If
        Else
            If e.Argument.StartsWith("DetachPhoto") Then
                Dim photoId As Integer = CInt(e.Argument.Split("#")(1))
                Dim siteId = CInt(Request.QueryString("SiteId"))
                Dim photoName = DataAdapter.DeletePhoto(photoId, CInt(Session(Constants.SESSION_PROCEDURE_ID)), siteId)

                If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
                    Dim blobstorageAccount As CloudStorageAccount = CloudStorageAccount.Parse(ConfigurationManager.AppSettings("AzureBlobStorageAccount"))

                    Dim blobClient As CloudBlobClient
                    Dim blobContainer As CloudBlobContainer

                    'blobClient = blobstorageAccount.CreateCloudBlobClient()
                    'blobContainer = blobClient.GetContainerReference("imageport")

                    blobContainer.CreateIfNotExists()
                    blobContainer.SetPermissions(New BlobContainerPermissions With {.PublicAccess = BlobContainerPublicAccessType.Blob})
                    ' move photo/change blob name 
                    Dim oldPhotoName = Right(photoName, photoName.Length - InStr(photoName, "/" + CStr(Session(Constants.SESSION_PROCEDURE_ID)) + "/"))
                    Dim newPhotoName = CStr(Session(Constants.SESSION_PROCEDURE_ID)) + "/Temp/" + Right(photoName, photoName.Length - photoName.LastIndexOf("/") - 1)
                    Dim imageBlob As CloudBlockBlob = blobContainer.GetBlockBlobReference(oldPhotoName)
                    Dim newImageBlob As CloudBlockBlob = blobContainer.GetBlockBlobReference(newPhotoName)
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
                    'remove from folder
                    Dim sourcePath = Path.Combine(PhotosFolderPath, photoName)
                    Dim destPath = Path.Combine(CacheFolderPath, photoName)



                    If File.Exists(destPath) Then File.Delete(destPath) 'in case file already exists in destPath
                    Dim originalCreationTime = File.GetCreationTimeUtc(sourcePath)
                    File.Move(sourcePath, destPath)
                    File.SetCreationTimeUtc(destPath, originalCreationTime) 'need to keep the time stamp incase needed for the TTC and WT details

                    'video bmp 1st
                    If File.Exists(sourcePath.Replace(".mp4", ".bmp")) Then
                        If File.Exists(destPath.Replace(".mp4", ".bmp")) Then File.Delete(destPath.Replace(".mp4", ".bmp")) 'in case file already exists in destPath
                        File.Move(sourcePath.Replace(".mp4", ".bmp"), destPath.Replace(".mp4", ".bmp"))
                        File.SetCreationTimeUtc(destPath, File.GetCreationTimeUtc(sourcePath)) 'need to keep the time stamp incase needed for the TTC and WT details
                    End If
                End If

            End If
            Response.Redirect("AttachedPhotos.aspx?" & "?" & Request.QueryString.ToString, False)

            'The JS method SetPhotoContextMenu() is called from here because it needs to be called AFTER the PatProcAjaxMgr_AjaxRequest completes.
            ScriptManager.RegisterStartupScript(Page, GetType(Page), "myscript", "SetPhotoContextMenu();SetVideoContextMenu();", True)

        End If
    End Sub

    Protected Function GetSitesVideos() As DataTable
        Dim dtProcedureMedia = DataAdapter.GetSitePhotos(SiteId, iProcedureId) '.AsEnumerable.Where(Function(x) Path.GetExtension(CStr(x("PhotoName"))) = ".mp4")


        Dim dtSiteVideos As DataTable = Nothing
        Dim bVideoPresent As Boolean = False

        Dim siteDescription = ""
        If SiteId > 0 Then
            siteDescription = DataAdapter.GetSiteDescription(SiteId)
        End If

        For Each dr As DataRow In dtProcedureMedia.Rows
            'check file type. mp4 only
            If Path.GetExtension(dr("PhotoName")) = ".mp4" Then

                If dtSiteVideos Is Nothing Then
                    dtSiteVideos = dtProcedureMedia.Clone()
                    dtSiteVideos.Columns.Add("ImageUrl")
                    dtSiteVideos.Columns.Add("ImageThumbnailUrl")
                    dtSiteVideos.Columns.Add("SiteDescription")
                    dtSiteVideos.AcceptChanges()
                End If

                Dim drNew = dtSiteVideos.NewRow()
                drNew("PhotoId") = dr("PhotoId")
                drNew("SiteId") = dr("SiteId")
                drNew("ImageUrl") = PhotosFolderUri & "/" & dr("PhotoName")
                drNew("SiteDescription") = siteDescription
                drNew("ImageThumbnailUrl") = CStr(PhotosFolderUri & "/" & dr("PhotoName").Replace(".mp4", ".bmp"))
                dtSiteVideos.Rows.Add(drNew)
                bVideoPresent = True

            End If
        Next

        If Not bVideoPresent Then VideosListView.Visible = False
        Return dtSiteVideos
    End Function

    Protected Sub VideosListView_NeedDataSource(sender As Object, e As RadListViewNeedDataSourceEventArgs)
        VideosListView.DataSource = GetSitesVideos()
    End Sub

    Private Class LightBoxMediaTemplate
        Implements ITemplate

        Public player As RadMediaPlayer
        Private source As String
        Private photoId As Integer
        Private procedureId As Integer

        Public Sub New(source As String, photoId As Integer)
            Me.source = source
            Me.photoId = photoId
        End Sub

        Public Sub InstantiateIn(container As Control) Implements ITemplate.InstantiateIn
            player = New RadMediaPlayer()
            player.ID = "RadMediaPlayer" & CStr(procedureId)
            player.RenderMode = RenderMode.Lightweight
            player.ToolBar.FullScreenButton.Style("display") = "none"
            player.Source = source
            player.Height = Unit.Pixel(336)
            player.Width = Unit.Pixel(600)
            player.TitleBar.ShareButton.Visible = False
            player.TitleBar.Visible = False
            player.ToolBar.SubtitlesButton.Visible = False
            player.ToolBar.HDButton.Visible = False
            player.AutoPlay = True
            container.Controls.Add(player)
        End Sub

    End Class

End Class

