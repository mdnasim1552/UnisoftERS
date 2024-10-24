<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="AttachedMedia.aspx.vb" Inherits="UnisoftERS.AttachedMedia" %>

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
        .notification-modal {
            display: none;
            position: absolute;
            left: 0px;
            top: 0px;
            z-index: 9999;
            background-color: rgb(170, 170, 170);
            opacity: 0.5;
            width: 100%;
            height: 100%;
        }

        .rigItemBox {
            margin-left: 50px;
            margin-top: -30px;
            /*background-color:white;*/
            height: 400px !important;
        }

        .ImageWrapper {
            font-family: "Segoe UI", Arial, Helvetica, sans-serif;
            font-size: 12px;
            line-height: normal;
            color: black;
        }

        .ImageFooter {
            background-color: #DFE9F5;
            height: 40px;
            line-height: 40px;
            font-family: "Segoe UI", Arial, Helvetica, sans-serif;
            font-size: 14px;
            color: black;
        }

        .DescriptionBox {
            margin-left: 10px;
            max-width: 30px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .rbAdd24 {
            background-position: 0 -18px !important;
        }

        .ThumbnailSlider {
            background-color: #DFE9F5;
            border-radius: 25px;
            height: calc(90vh - 20px) !important;
        }

        #PhotoBinaryImage {
            height: calc(75vh - 20px) !important;
        }

        .cssItem {
        }

        .RadRotator {
            background-color: #DFE9F5;
        }

        .rrClipRegion {
            background-color: #DFE9F5 !important;
        }

        .rrItemsList {
            border: none !important;
            /*background-color: #DFE9F5;*/
        }

        .rrItemsList li {
            background-color: #DFE9F5 !important;
        }

        .rrItemsList img {
            opacity: 1 !important;
            border-radius: 10px;
        }

        .rrItemsList a:hover img {
            opacity: 1 !important;
        }

        .rrItem {
            margin: 4px;
            border: none;
        }

            .rrItem img {
                border-radius: 10px;
            }

        .cssSelectedItem {
        }

            .cssSelectedItem img {
                border: 3px solid #00e600;
            }

        .rmpSubtitlesButton {
            display: none;
        }

        .rmpShareButton {
            display: none;
        }

        .rmpHDButton {
            display: none;
        }

        .TextOverImage {
            position: absolute;
            color: white;
            background-color: rgb(169, 169, 169);
            background-color: rgba(169, 169, 169, 0.66);
            top: 0px;
            left: 3px;
            border-radius: 0 0 5px 0;
            cursor: default;
            width: 18%;
            text-align: center;
        }
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
                //disable the thumbnail slider buttons when there are not enough images
                var sliderRegionHeight = parseInt($(".rrClipRegion").height());
                var thumbnailImagesHeight = parseInt($(".rrItemsList").height());
                if (sliderRegionHeight > thumbnailImagesHeight) {
                    $("#UpImage, #DownImage").prop('disabled', true);
                }
                else {
                    $("#UpImage, #DownImage").prop('disabled', false);
                }
            });

            function CloseWindow() {

                $("video").each(function () { this.pause() });

                var videoplayer = $find("<%= VideoPlayer.ClientID %>");
                if (videoplayer != null) videoplayer.stop();

                var oWnd = GetRadWindow();
                oWnd.setUrl("about:blank");
                oWnd.close();
            }

            function GetRadWindow() {
                var oWindow = null; if (window.radWindow)
                    oWindow = window.radWindow; else if (window.frameElement.radWindow)
                    oWindow = window.frameElement.radWindow; return oWindow;
            }


            function OnClientCommandExecuting(imEditor, eventArgs) {
                if (eventArgs.get_commandName() == 'Save') {
                    imEditor.saveImageOnServer('', true);

                    //Prevent the built-in Save dialog to pop up
                    imEditor.setToggleState('Save', false);
                    imEditor.saveImageOnServer('', true);
                    eventArgs.set_cancel(true);
                }
            }

            var ctrlKeyPressed = false;

            //Check if Ctrl key is pressed for multiple selection
            function isKeyPressed(e) {
                if (e.ctrlKey) { ctrlKeyPressed = true; }
                else { ctrlKeyPressed = false; }
            }

            function ThumnailClicked(sender, args) {


                var currentItem = args.get_item().get_element().firstChild;
                //Ctrl key is pressed for multiple selection
                if (ctrlKeyPressed === true) {
                    if (currentItem.className == "cssSelectedItem") {
                        currentItem.className = "";
                        currentItem.parentElement.style.margin = "4px";
                    } else {
                        currentItem.className = "cssSelectedItem";
                        currentItem.parentElement.style.margin = "1px";
                    }
                    //return;
                }

                var iCnt = 0;
                var iIndex = 0;
                var photoIndexes = '';
                //Clear the css for all the items other than the selected item
                $(sender.get_items()).each(function () {

                    var myItem = this.get_element().firstChild;
                    if (ctrlKeyPressed !== true && currentItem.className != "initial-image") {
                        if (myItem == currentItem) {
                            myItem.className = "cssSelectedItem";
                            myItem.parentElement.style.margin = "1px";
                        }
                        else {
                            myItem.className = "";
                            //myItem.parentElement.style.marginLeft = "5px"; //take the values back to the ones defined in the css rrItem class
                            //myItem.parentElement.style.marginTop = "0px";
                            myItem.parentElement.style.margin = "4px";
                        }
                    }

                    if (myItem.className == "cssSelectedItem") {
                        photoIndexes = iIndex;
                        iCnt++;
                    }

                    iIndex++;
                });


            }

            function openMoveMediaWindow(sender, args) {
                var mediaId = $("#<%= SelectedPhotosHiddenField.ClientID %>").val();
                if (mediaId == undefined || mediaId == 0) {
                    alert('No image selected');
                }
                else {
                    var oWnd2 = $find("<%= MediaRadWindow.ClientID %>");
                    var url = '<%= ResolveUrl("PhotoMove.aspx?PhotoId=") %>' + mediaId + '&SiteId=<%= Request.QueryString("SiteId") %>';
                    oWnd2.SetSize(500, 200);
                    oWnd2._navigateUrl = url
                    //Add the name of the function to be executed when RadWindow is closed.
                    oWnd2.add_close(OnClientClose);
                    oWnd2.show();
                }
            }

            function openMoveVideoWindow() {
                var mediaId = $("#<%= SelectedPhotosHiddenField.ClientID %>");
                var oWnd2 = $find("<%= MediaRadWindow.ClientID %>");
                var url = "<%= ResolveUrl("PhotoMove.aspx?PhotoId={0}&IsVideo=true")%>";
                url = url.replace("{0}", mediaId);
                oWnd2.SetSize(500, 200);
                oWnd2._navigateUrl = url
                //Add the name of the function to be executed when RadWindow is closed.
                oWnd2.add_close(OnClientClose);
                oWnd2.show();
            }

            function OnClientClose(oWnd, eventArgs) {               
                oWnd.remove_close(OnClientClose);
                $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest();
            }

            function refreshSiteNode() {
                var mediaSiteId = '<%= Request.QueryString("SiteId") %>' == '' ? '0' : '<%= Request.QueryString("SiteId") %>';
                var btn = $(window.parent.document).find('#SiteDetailsBtn');
                btn.attr('data-mediaSiteId', mediaSiteId);
                btn.click();
            }

        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadButton runat="server" ID ="AttachMediaBtn" AutoPostBack="false" Text="" ClientIDMode="Static" OnClientClicking="refreshSiteNode" data-mediaSiteId="" style="display: none"></telerik:RadButton>
        <telerik:RadScriptManager ID="SiteDetailsRadScriptManager" runat="server" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" Skin="Metro" DecoratedControls="All" DecorationZoneID="FormDiv" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="notification-modal"></div>
         <div class="abnorHeader">
            Media
        </div>

        <div style="margin: 20px 15px;" class="text2" id="NoRowsDiv" runat="server" visible="false">
            <strong>
                No media attached
            </strong>
        </div>

        <div  class="text2" id="MainDiv" runat="server">
            <table style="width: 100%;">
                <tr>
                    <td colspan="5">
                    </td>
                </tr>
                <tr>
                    <td></td>
                </tr>
                <tr>
                    <td></td>
                </tr>
                <tr>
                    <td colspan="2" valign="top">
                        <table class="ThumbnailSlider">
                            <tr>
                                <td style="text-align: center; height: 35px;">
                                    <asp:ImageButton ImageUrl="~/Images/up4-64x64.png" ID="UpImage" AlternateText="up" runat="server" Height="35px" Width="70px"></asp:ImageButton>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <telerik:RadRotator ID="ThumbnailRotator" runat="server" WrapFrames="false" RotatorType="Buttons" Style="height: calc(100% - 42px);"
                                        Width="200" ScrollDirection="Up, Down" RenderMode="Lightweight" ScrollDuration="500" ItemHeight="130"
                                        PersistCurrentItemOnPostBack="false" BorderStyle="None" BorderWidth="0"
                                        OnClientItemClicked="ThumnailClicked" FrameDuration="2000" Skin="Metro">
                                        <ItemTemplate>
                                            <div id="divRadImage" style="position: relative; padding-left: 3px;" onmousedown="isKeyPressed(event)">
                                                <telerik:RadBinaryImage runat="server" ID="ThumbnailBinaryImage" ImageUrl='<%#Eval("ImageUrl")%>'
                                                    Height="130px" Width="170px" ResizeMode="Fit" />
                                                <label id="imageText" class="TextOverImage"><%#Eval("RowId")%></label>
                                            </div>
                                        </ItemTemplate>
                                   <ControlButtons UpButtonID="UpImage" DownButtonID="DownImage" />
                                    </telerik:RadRotator>
                                </td>
                            </tr>
                             
                            <tr>
                                <td style="text-align: center; height: 35px;">
                                    <asp:ImageButton ImageUrl="~/Images/down4-64x64.png" ID="DownImage" AlternateText="down" runat="server" Height="35px" Width="70px"></asp:ImageButton>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td style="vertical-align: top;">
                        <table cellpadding="0" cellspacing="0" id="PhotoTable" runat="server" style="height: 400px;">
                            <tr class="ImageFooter" style="">
                                <td colspan="10">
                                    <div style="float: left; padding-left: 10px;">
                                        <asp:Label ID="ImageDateLabel" runat="server" />
                                        <telerik:RadButton ID="MoveSiteButton" runat="server" Text="Move to another site" Skin="Web20" Icon-PrimaryIconUrl="~/Images/icons/move_site.png" OnClientClicked="openMoveMediaWindow" AutoPostBack="false" Visible="false" />
                                        <telerik:RadButton ID="DetachButton" runat="server" Text="Detach media" Skin="Web20" Icon-PrimaryIconUrl="~/Images/icons/detach.png" OnClick="DetachButton_Click" Visible="false" />

                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="ImageWrapper" colspan="10" style="height: 300px;">
                                    <telerik:RadBinaryImage runat="server" ID="PhotoBinaryImage" ResizeMode="None" ImageAlign="Middle" Width="550" Height="510" />
                                    <telerik:RadMediaPlayer runat="server" ID="VideoPlayer" Height="400px" Visible="false"></telerik:RadMediaPlayer>
                                </td>
                            </tr>
                            <tr class="ImageFooter">

                                <td style="width: 10px;"></td>
                               
                                <td class="DescriptionBox">
                                    <asp:Label ID="ImageDescriptionLabel" runat="server"></asp:Label>
                                </td>
                                 <%-- changed by mostafizur --%>
                                    
                                 <td  class="DescriptionBox" style="text-align: right; vertical-align: central;">
                           
                                      <asp:Label ID="RegionLabel" runat="server"></asp:Label>
                                 </td>
                                <td class="DescriptionBox" style="text-align: right; vertical-align: central;">
                                    <asp:Label ID="SelectedPhotosId" runat="server"></asp:Label>
                                </td>
                                <%-- changed by mostafizur --%>

                                <td style="text-align: right; vertical-align: central;"></td>
                                <td style="width: 10px;"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            <asp:HiddenField ID="SelectedPhotosHiddenField" runat="server" />
        </div>
        <div style="top: -32px; float: right; position: relative;">
        </div>
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="PatProcAjaxMgr_AjaxRequest">
            <AjaxSettings>
                <%--                    <telerik:AjaxSetting AjaxControlID="ThumbnailRotator">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ThumbnailRotator" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="PhotoTable" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="DetachButton" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
                <telerik:AjaxSetting AjaxControlID="DetachButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                        <telerik:AjaxUpdatedControl ControlID="PhotoTable" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <telerik:RadWindowManager ID="MediaRadWindowManager" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="MediaRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="950px" Height="600px" VisibleStatusbar="false" Behaviors="Move" />
            </Windows>
        </telerik:RadWindowManager>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html> 
