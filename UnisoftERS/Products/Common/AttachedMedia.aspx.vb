Imports System.IO
Imports Telerik.Web.UI
Imports Microsoft.WindowsAzure
Imports Microsoft.WindowsAzure.Storage
Imports Microsoft.WindowsAzure.Storage.File
Imports Microsoft.WindowsAzure.Storage.Blob


Public Class AttachedMedia
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
            LoadThumbnailRotator()
        End If
    End Sub

    Private Function GetHeaderText(ByVal siteId As Integer) As String
        Dim dtSite As DataTable = DataAdapter.GetSiteDetails(siteId)
        Return dtSite.Rows(0)("Region")
    End Function

    Protected Sub LoadThumbnailRotator()
        Try
            Dim dt = GetAttachedMedia()
            Session("MediaDataTable") = dt

            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                ThumbnailRotator.DataSource = dt.DefaultView
                ThumbnailRotator.DataBind()
            Else
                MainDiv.Visible = False
                NoRowsDiv.Visible = True
            End If
        Catch ex As Exception
            Dim ref = LogManager.LogManagerInstance.LogError("Error loading attached media", ex)
            Utilities.SetErrorNotificationStyle(RadNotification1, ref, "There was an error loading attached media")
            RadNotification1.Show()
        End Try
    End Sub

    Protected Function GetAttachedMedia() As DataTable
        Dim dtProcedureMedia = DataAdapter.GetSitePhotos(SiteId, iProcedureId)


        Dim dtMedia As DataTable = Nothing

        Dim siteDescription = ""
        If SiteId > 0 Then
            siteDescription = DataAdapter.GetSiteDescription(SiteId)
        End If

        Dim iCount As Integer = 0

        For Each dr As DataRow In dtProcedureMedia.Rows

            If dtMedia Is Nothing Then
                dtMedia = dtProcedureMedia.Clone()
                dtMedia.Columns.Add("RowId", GetType(Integer))
                dtMedia.Columns.Add("CreateDate", GetType(String))
                dtMedia.Columns.Add("ImageUrl")
                dtMedia.Columns.Add("ImageThumbnailUrl")
                dtMedia.Columns.Add("SiteDescription")
                dtMedia.AcceptChanges()
            End If

            Dim drNew = dtMedia.NewRow()
            drNew("RowId") = iCount
            drNew("PhotoName") = dr("PhotoName")
            drNew("PhotoId") = dr("PhotoId")
            drNew("SiteId") = dr("SiteId")
            drNew("CreateDate") = dr("DateTimeStamp")
            If ConfigurationManager.AppSettings("IsAzure").ToLower() = "true" Then
                drNew("ImageUrl") = dr("PhotoName")
                drNew("ImageThumbnailUrl") = CStr(dr("PhotoName").Replace(".mp4", ".bmp"))
            Else
                drNew("ImageUrl") = PhotosFolderUri & "/" & dr("PhotoName")
                drNew("ImageThumbnailUrl") = CStr(PhotosFolderUri & "/" & dr("PhotoName").Replace(".mp4", ".bmp"))
            End If
            drNew("SiteDescription") = siteDescription
            dtMedia.Rows.Add(drNew)
            iCount += 1
        Next

        Return dtMedia
    End Function

    Private Sub ThumbnailRotator_ItemDataBound(sender As Object, e As RadRotatorEventArgs) Handles ThumbnailRotator.ItemDataBound
        Dim dt As DataTable = DirectCast(Session("MediaDataTable"), DataTable)
        Dim sourceUrl As String = dt.Rows(e.Item.Index)("ImageUrl")


        If (Path.GetExtension(sourceUrl) = ".mp4") Then
            Dim ThumbnailBinaryImage As RadBinaryImage = DirectCast(e.Item.FindControl("ThumbnailBinaryImage"), RadBinaryImage)
            ThumbnailBinaryImage.ImageUrl = sourceUrl.Replace(".mp4", ".bmp")
        End If
    End Sub

    Protected Sub ThumbnailRotator_DataBound(sender As Object, e As EventArgs) Handles ThumbnailRotator.DataBound
        If ThumbnailRotator.Items.Count > 0 Then
            'LoadImage()
        Else
            MainDiv.Visible = False
            NoRowsDiv.Visible = True
        End If
    End Sub

    Protected Sub ThumbnailRotator_ItemClick(sender As Object, e As RadRotatorEventArgs) Handles ThumbnailRotator.ItemClick
        LoadImage(e.Item.Index)
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

        Dim sourceUrlAndRegion As List(Of String) = DisplayImage(index) ' did changed by mostafiz
        If sourceUrlAndRegion.Count > 0 Then
            ImageDescriptionLabel.Text = String.Format("Image {0} of {1}", index + 1, ThumbnailRotator.Items.Count)
            Dim dt As DataTable = DirectCast(Session("MediaDataTable"), DataTable)

        End If
    End Sub

    Private Sub LoadFileImage(index As Integer)

        'changed by mostafizur 

        Dim sourceUrlAndRegion As List(Of String) = DisplayImage(index)
        If sourceUrlAndRegion.Count > 0 Then

            ImageDescriptionLabel.Text = String.Format("Image {0} of {1}", index + 1, ThumbnailRotator.Items.Count)

            Dim regionLabelText As String = ""
            Dim region As String = sourceUrlAndRegion(1)

            If (region.Length > 1) Then
                Dim splitRegion As String() = region.Split(New String() {" in "}, StringSplitOptions.None)
                If splitRegion.Length > 1 Then
                    regionLabelText = splitRegion(1).TrimEnd(")"c)
                End If

            End If
                RegionLabel.Text = regionLabelText

            Try
                    Dim fi As New FileInfo(sourceUrlAndRegion(0).Replace(Session(Constants.SESSION_PHOTO_URL), Session(Constants.SESSION_PHOTO_UNC) & "\")) 'cannot use URI for fileinfo
                Catch ex As Exception
                    LogManager.LogManagerInstance.LogError("Error occured while retreiving photos creation date/time from path: " + sourceUrlAndRegion(0).Replace(Session(Constants.SESSION_PHOTO_URL), Session(Constants.SESSION_PHOTO_UNC) & "\"), ex)
                End Try

            End If

            'changed by mostafizur 
            Session("SelectedImageIndex") = index
    End Sub

    Public Function DisplayImage(index As Integer) As List(Of String)
        If Session("MediaDataTable") IsNot Nothing Then
            Dim dt As DataTable = DirectCast(Session("MediaDataTable"), DataTable)
            Dim sourceUrlAndRegion As New List(Of String)

            If dt.Rows.Count > 0 Then
                Dim sourceUrl As String = dt.Rows(index)("ImageUrl")
                Dim region As String = dt.Rows(index)("SiteDescription")
                sourceUrlAndRegion.Add(sourceUrl)
                sourceUrlAndRegion.Add(region)

                If (Path.GetExtension(sourceUrl) = ".mp4") Then
                    VideoPlayer.Source = sourceUrl
                    VideoPlayer.Visible = True
                    PhotoBinaryImage.Visible = False
                    'EditPhotoButton.Visible = False
                Else
                    PhotoBinaryImage.ImageUrl = sourceUrl
                    'PhotoImageEditor.ImageUrl = sourceUrl
                    PhotoBinaryImage.Visible = True
                    VideoPlayer.Visible = False
                    'EditPhotoButton.Visible = True
                End If
                'set imageid
                SelectedPhotosHiddenField.Value = dt.Rows(index)("PhotoId")
                SelectedPhotosId.Text = dt.Rows(index)("PhotoId")
                DetachButton.Visible = True
                MoveSiteButton.Visible = True
                Return sourceUrlAndRegion
            Else
                Return New List(Of String)()
            End If
        Else
            Return New List(Of String)()
        End If
    End Function


    Private Sub detachMedia(photoId As Integer)
        Dim photoName = DataAdapter.DeletePhoto(photoId, CInt(Session(Constants.SESSION_PROCEDURE_ID)), CInt(Request.QueryString("SiteId")))

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
    End Sub

    Protected Sub DetachButton_Click(sender As Object, e As EventArgs)
        If Not String.IsNullOrWhiteSpace(SelectedPhotosHiddenField.Value) Then
            detachMedia(SelectedPhotosHiddenField.Value)
            Dim dtPhotos As DataTable = DataAdapter.GetSitePhotos(CInt(Request.QueryString("SiteId")), CInt(Session(Constants.SESSION_PROCEDURE_ID)))
            If dtPhotos.Rows.Count > 0 Then
                Response.Redirect("AttachedMedia.aspx?SiteId=" & CInt(Request.QueryString("SiteId")).ToString, False)
            Else
                ScriptManager.RegisterStartupScript(Me, Me.GetType(), "runFunction", "refreshSiteNode();", True)
            End If
        Else
            Utilities.SetNotificationStyle(RadNotification1, "No image selected", True)
            RadNotification1.Show()
        End If
    End Sub

    Protected Sub PatProcAjaxMgr_AjaxRequest(ByVal sender As Object, ByVal e As AjaxRequestEventArgs)
        Response.Redirect("AttachedMedia.aspx?SiteId=" & CInt(Request.QueryString("SiteId")).ToString, False)
    End Sub
End Class