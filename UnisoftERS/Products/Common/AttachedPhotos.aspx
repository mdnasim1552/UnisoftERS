<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="AttachedPhotos.aspx.vb" Inherits="UnisoftERS.Products_Common_AttachedPhotos" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    <script type="text/javascript" src="../../Scripts/raphael-min.js"></script>
    <script type="text/javascript" src="../../Scripts/contextmenu.js"></script>
    <script type="text/javascript" src="../../Scripts/raphael.export.js"></script>

    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <link type="text/css" href="../../Styles/contextmenu.css" rel="stylesheet" />


    <style type="text/css">
        .contextMenu {
            display: none;
        }

        .diagram-buttons {
            color: #050;
            font: bold 84% 'trebuchet ms',helvetica,sans-serif;
            /*font: bold 84% 'trebuchet ms',helvetica,sans-serif;*/
            /*font-family: Georgia;*/
            font-size: 8pt;
            background-color: #fed;
            border: 1px solid;
            border-color: #696 #363 #363 #696;
        }

        a.sitesummary {
            color: inherit;
        }

            a.sitesummary:link {
                text-decoration: none;
                color: inherit;
            }

            a.sitesummary:hover {
                text-decoration: underline;
                color: blue;
            }

        .rigThumbnailsList {
            background-color: white !important;
        }

            .rigThumbnailsList li {
                background-color: none !important;
            }

            .rigThumbnailsList img {
                opacity: 1 !important;
                border-radius: 10px;
            }

            .rigThumbnailsList a:hover img {
                opacity: 1 !important;
            }

            .rigThumbnailsList .rigThumbnailActive a img {
                opacity: 1 !important;
            }

        .rltbDescription {
            display: none;
        }

        .rltbActiveImage {
            height: 400px !important;
        }

        .txtSiteHighlight {
            padding-left: 5px;
            padding-right: 5px;
            background-color: #ffff99;
            box-shadow: 0 0 7px #cccc00;
        }

        .imageWrapper {
            font: 13px "Segoe UI", Arial,Helvetica, sans-serif;
            color: #666;
            float: left;
            width: 194px;
            height: 150px;
            padding: 10px;
            cursor: pointer;
        }

        .playIcon {
            background: url('../../Images/hover_video_thumb.png') no-repeat;
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            display: none;
        }

        .imageWrapper:hover {
            background: white;
            color: #000;
            box-shadow: 0 0 5px rgba(0, 0, 0, 0.2);
        }

            .thumbnailHolder img,
            .imageWrapper:hover .playIcon {
                display: block;
            }

        .thumbnailHolder {
            display: block;
            position: relative;
            margin-bottom: 5px;
        }

        .timeLabel {
            background-color: rgba(0,0,0,0.7);
            filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#B3000000', endColorstr='#B3000000',GradientType=0 );
            font: bold 10px/14px "Segoe UI", Arial,Helvetica, sans-serif;
            color: white;
            bottom: 2px;
            right: 1px;
            width: 30px;
            text-align: center;
            position: absolute;
        }

        .RadMediaPlayer,
        div.rltbDescriptionBox {
            margin-left: 50px;
            width: 600px;
        }

        .rltbItemTemplate {
            height: 336px;
        }

        .rmpFullscreen {
            margin-left: 0px;
        }

        div.RadLightBox .rltbWrapper {
            z-index: auto;
        }

        .RadLightBox .rltbToolbar {
            display: none;
        }

        .rltbOverlay {
            z-index: 350000 !important;
        }

        .RadLightBox {
            z-index: 360000 !important;
        }

        .size-custom {
            max-width: 642px;
        }

        /* PatientDetails.ascx=> Styles */
        .lefthide {
            float: left;
            display: none;
            color: red;
            font-weight: bold;
        }

        .UGI_Procedure {
            color: red;
        }

        .LockedProcedure {
            color: #990033;
        }

        .ProcedureIncomplete {
            color: #1E90FF;
        }

        .divProcDNA {
            float: right;
            text-align: right;
            margin-left: 10px;
        }

            .divProcDNA a {
                font-size: 10px;
                margin-left: 0px;
            }
    </style>
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">

            $(document).ready(function () {
                SetPhotoContextMenu();
                SetVideoContextMenu();

            });

            function SetPhotoContextMenu() {
                $(".rigThumbnailsBox img").PhotoContextMenu({
                    menu: 'PhotoRightClickMenu',
                    onShow: onPhotoContextMenuShow,
                    onSelect: onPhotoContextMenuItemSelect
                });
            }

            function SetVideoContextMenu() {
                $(".imageWrapper").VideoContextMenu({
                    menu: 'VideoRightClickMenu',
                    onShow: onVideoContextMenuShow,
                    onSelect: onVideoContextMenuItemSelect
                });
            }


            function DetachPhoto(photo) {
                var reqArgument = "DetachPhoto" + "#" + GetPhotoId(photo);
                $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest(reqArgument);
            }

            function DetachVideo(video) {
                var reqArgument = "DetachPhoto" + "#" + GetVideoId(video);
                $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest(reqArgument);
            }

            function GetPhotoId(photo) {
                var ImageClientId = photo.attr("id");
                var ImageLIElement = photo.closest("li");

                var ImageGalleryClientId = photo.closest('div[class^="RadImageGallery RadImageGallery_Default"]')[0].id;
                var photoIndex = $("#" + ImageGalleryClientId + " li").index(ImageLIElement);

                var items = $find(ImageGalleryClientId).get_items();
                var photoId = items.getItem(photoIndex).get_description();
                return photoId;

                var reqArgument = "DetachPhoto" + "#" + photoId;
            }

            function GetVideoId(video) {
                var photoId = video.find("span[id$='PhotoIdLabel']").text();
                return photoId;
            }

            function RefreshPhotos() {
                $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("photo");
                //SetPhotoContextMenu();
            }

            function openMovePhotoWindow(photo) {
                var oWnd2 = $find("<%= SiteDetailsRadWindow.ClientID %>");
                var url = "<%= ResolveUrl("PhotoMove.aspx?PhotoId={0}&IsVideo=false")%>";
                url = url.replace("{0}", GetPhotoId(photo));
                oWnd2.SetSize(500, 200);
                oWnd2._navigateUrl = url
                //Add the name of the function to be executed when RadWindow is closed.
                oWnd2.add_close(OnClientClose);
                oWnd2.show();
            }

            function openMoveVideoWindow(video) {
                var oWnd2 = $find("<%= SiteDetailsRadWindow.ClientID %>");
                var url = "<%= ResolveUrl("PhotoMove.aspx?PhotoId={0}&IsVideo=true")%>";
                url = url.replace("{0}", GetVideoId(video));
                oWnd2.SetSize(500, 200);
                oWnd2._navigateUrl = url
                //Add the name of the function to be executed when RadWindow is closed.
                oWnd2.add_close(OnClientClose);
                oWnd2.show();
            }

            function OnClientClose(oWnd, eventArgs) {
                //Remove the OnClientClose function to avoid
                //adding it for a second time when the window is shown again.
                oWnd.remove_close(OnClientClose);


                $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest();

                //refresh diagram
                //parent.location.href = parent.location.href

                SetPhotoContextMenu();
            }

            var lightBox;
            function lightBoxLoad(sender, args) {
                lightBox = sender;
            }

            function loadVideoPlayer(index) {
              <%--  var oWnd2 = $find("<%= VideoPlayerRadWindow.ClientID %>");
                oWnd2.show();--%>
                $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest('load_video|' + index);
                showLightBox(index);
            }

            function showLightBox(index) {
                lightBox.set_currentItemIndex(index);
                lightBox.show();
            }

            function lightBoxShowed(sender, args) {
                args.set_cancel(true);
            }

            function closeLightBox(sender, args) {
                $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest('close_lightbox');
            }

        </script>
    </telerik:RadScriptBlock>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server" />

         <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>

        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="PatProcAjaxMgr_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="VideosListView" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="VideosListView">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="VideosLightBox" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        <div class="abnorHeader">
            Media
        </div>

                <div>
                    <div id="NoMediaDiv" runat="server" visible="false" style="padding-left: 15px;">
                        <h2>No media attached</h2>
                    </div>
                    <asp:ObjectDataSource ID="SitePhotosObjectDataSource" runat="server" SelectMethod="GetSitePhotos" TypeName="UnisoftERS.DataAccess"></asp:ObjectDataSource>

                    <telerik:RadImageGallery ID="PhotosImageGallery" runat="server" ZIndex="100000" Style="background-color: none;"
                        DataImageField="ImageUrl" DataThumbnailField="ImageThumbnailUrl" DataTitleField="SiteDescription"
                        BackColor="Transparent" DisplayAreaMode="LightBox"
                        OnItemDataBound="PhotosImageGallery_OnItemDataBound" Width="600">
                        <ImageAreaSettings Height="400px" ResizeMode="Fit" />
                        <ThumbnailsAreaSettings ThumbnailsSpacing="4px" ThumbnailHeight="70" ThumbnailWidth="90"
                            Width="474" Height="78" ShowScrollButtons="true" />

                    </telerik:RadImageGallery>

                    <div class="demo-container size-custom">
                        <telerik:RadListView ID="VideosListView" runat="server" OnNeedDataSource="VideosListView_NeedDataSource">
                            <LayoutTemplate>
                                <div class="rptSummaryText12" style="color: #0072c6"><b></b></div>
                                <table id="itemPlaceholderContainer" runat="server" border="0" cellspacing="0" cellpadding="0" class="rptSummaryText12">
                                    <tr id="itemPlaceholder" runat="server">
                                    </tr>
                                </table>
                            </LayoutTemplate>
                            <ItemTemplate>
                                <tr runat="server">
                                    <td style="padding-left: 5px;" runat="server">
                                        <div class="imageWrapper" onclick='<%# "showLightBox(" & Container.DisplayIndex & ");" %>'>
                                            <span class="thumbnailHolder">
                                                <asp:Image ID="ThumbnailImage" runat="server" Height="109px" Width="194px" AlternateText="Video Thumbnail" ImageUrl='<%# Eval("ImageThumbnailUrl") %>' />
                                                <span class="playIcon"></span>
                                            </span>
                                            <asp:Label ID="SiteDescriptionLabel" runat="server" Text='<%#  Eval("SiteDescription") %>'></asp:Label>
                                            <asp:Label ID="PhotoIdLabel" runat="server" Text='<%#  Eval("PhotoId") %>' Style="display: none;"></asp:Label>
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </telerik:RadListView>

                        <div id="VideosDiv" runat="server">
                            <telerik:RadMediaPlayer runat="server" ID="AttachedVideoPlayer" Height="400px" Visible="true" ></telerik:RadMediaPlayer>
                            
                        </div>
                        <telerik:RadLightBox RenderMode="Lightweight" ID="VideosLightBox" runat="server" Modal="true" LoopItems="true" ZIndex="100000"
                            ItemsCounterFormatString="Video {0} of {1}" Width="720px" Height="340px" >
                             <ClientSettings>
                                    <ClientEvents OnLoad="lightBoxLoad" />
                                </ClientSettings>
                        </telerik:RadLightBox>

                    </div>

                </div>

        <ul id="PhotoRightClickMenu" class="contextMenu">
            <li id="liMovePhotos" runat="server"><a href="" style="background-image: url(/Images/icons/move_site.png)">Move photo to a different site </a></li>
            <li><a href="" style="background-image: url(/Images/icons/detach.png)">Detach photo</a></li>
        </ul>

        <ul id="VideoRightClickMenu" class="contextMenu">
            <li id="liMoveVidoes" runat="server"><a href="" style="background-image: url(../Images/icons/move_site.png)">Move video to a different site </a></li>
            <li><a href="" style="background-image: url(../Images/icons/detach.png)">Detach video</a></li>
        </ul>

        <telerik:RadWindowManager ID="PatientProcedureRadWindowManager" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="radWindow" runat="server" />
                <telerik:RadWindow ID="VideoPlayerRadWindow" runat="server" Modal="true" AutoSize="true">
                    <ContentTemplate>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
            <Windows>
                <telerik:RadWindow ID="SiteDetailsRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="950px" Height="600px" VisibleStatusbar="false" Behaviors="Move" />
            </Windows>
        </telerik:RadWindowManager>
    </form>
</body>
</html>
