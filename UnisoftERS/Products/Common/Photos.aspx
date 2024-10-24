<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_Photos" CodeBehind="Photos.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Attach Photos</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
  
    <%--<script src="https://ajax.googleapis.com/ajax/libs/prototype/1.7.0.0/prototype.js" type="text/javascript"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/scriptaculous/1.9.0/scriptaculous.js" type="text/javascript"></script>--%>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />


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
            background-color: #C4D2D9;
            height: 40px;
            line-height: 40px;
            font-family: "Segoe UI", Arial, Helvetica, sans-serif;
            font-size: 14px;
            color: black;
        }

        .DescriptionBox {
            margin-left: 20px;
            /*float:left;*/
        }

        .rbAdd24 {
            background-position: 0 -18px !important;
        }

        .ThumbnailSlider {
            background-color: #C4D2D9;
            border-radius: 25px;
            height: 590px;
        }

        .cssItem {
        }

        .RadRotator {
            background-color: #C4D2D9;
        }

        .rrClipRegion {
            background-color: #C4D2D9 !important;
        }

        .rrItemsList {
            border: none !important;
            background-color: #C4D2D9;
        }

            .rrItemsList li {
                background-color: #C4D2D9 !important;
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
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="SiteDetailsRadScriptManager" runat="server" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" Skin="Metro" DecoratedControls="All" DecorationZoneID="FormDiv" />
        <div class="notification-modal"></div>

        <telerik:RadNotification ID="DownloadErrorRadNotification" runat="server" Animation="Fade"
            EnableRoundedCorners="true" EnableShadow="true" Title="Image Download Error"
            LoadContentOn="PageLoad" TitleIcon="delete" Position="Center"
            AutoCloseDelay="0" Skin="Web20" Width="500px" ShowCloseButton="false">
            <ContentTemplate>
                <div id="errMsg" runat="server" class="aspxValidationSummary"></div>
                <div style="height: 20px; margin-left: 10px; margin-bottom: 5px; text-align: center;">
                    <telerik:RadButton ID="RedownloadPhotosRadButton" runat="server" Text="Refresh Photos" OnClick="RefreshPhotosLinkButton_Click" Icon-PrimaryIconUrl="~/Images/icons/refresh.png" />
                    <telerik:RadButton ID="CancelAndCloseRadButton" runat="server" Text="Cancel and Close" Skin="Web20" AutoPostBack="false" OnClientClicked="CloseWindow" />
                </div>
            </ContentTemplate>
        </telerik:RadNotification>

        <div style="margin: 20px 15px;" class="text2" id="NoRowsDiv" runat="server" visible="false">
            No photos exist in the cache for this computer
            <telerik:RadButton ID="CloseWindowRadButton" runat="server" Text="Close" Skin="Web20" AutoPostBack="false" OnClientClicked="CloseWindow"  />
        </div>
        <div style="margin: 10px 5px;" class="text2" id="MainDiv" runat="server">
            <table style="width: 100%;">
                <tr>
                    <td colspan="5">
                        <asp:Label ID="HeaderLabel" runat="server"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td style="height: 2px;"></td>
                </tr>
                <tr style="height: 25px;">
                    <td colspan="5">
                        <table>
                            <tr style="height: 25px;">
                                <td>
                                    <asp:RadioButton ID="SiteRadioButton" runat="server" GroupName="Photo" Text="Attach to a different site" Font-Size="Smaller" />
                                </td>
                                <td style="width: 3px"></td>
                                <td style="display: none;" id="SiteComboBoxTD" runat="server">
                                    <telerik:RadComboBox ID="SiteComboBox" runat="server" Skin="Windows7" Width="300">
                                    </telerik:RadComboBox>
                                    &nbsp;
                                    <div class="rectum-final-image-confirmation" style="float: right; margin-top: 3px; display: none;">
                                        <asp:CheckBox ID="ConfirmFinalRectumImageCheckbox" runat="server" Text="Is this the final rectum image?" ToolTip="If selected this images timestamp will be used to calculate the withdrawal time" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5">
                                    <asp:RadioButton ID="ProcedureRadioButton" runat="server" GroupName="Photo" Text="Attach to the procedure" Font-Size="Smaller" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td style="height: 10px;"></td>
                </tr>
                <tr>
                    <td colspan="2" valign="top">
                        <table class="ThumbnailSlider">
                            <tr>
                                <td style="text-align: center; height:35px;">
                                    <asp:ImageButton ImageUrl="~/Images/up4-64x64.png" ID="UpImage" AlternateText="up" runat="server" Height="35px" Width="70px"></asp:ImageButton>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <telerik:RadRotator ID="ThumbnailRotator" runat="server" WrapFrames="false" RotatorType="Buttons" Style="background-color: #C4D2D9;  height: calc(100% - 42px);"
                                        Width="200" ScrollDirection="Up, Down" RenderMode="Lightweight" ScrollDuration="500" ItemHeight="130"
                                        PersistCurrentItemOnPostBack="false" BorderStyle="None" BorderWidth="0" 
                                        OnClientItemClicked="ThumnailClicked" FrameDuration="2000">
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
                                <td style="text-align: center; height:35px;">
                                    <asp:ImageButton ImageUrl="~/Images/down4-64x64.png" ID="DownImage" AlternateText="down" runat="server" Height="35px" Width="70px"></asp:ImageButton>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td style="vertical-align:top;">
                        <table cellpadding="0" cellspacing="0" id="PhotoTable" runat="server" style="height: 400px;">
                            <tr class="ImageFooter" style="">
                                <td colspan="10">
                                    <div style="float: left; padding-left: 5px;">
                                        <asp:CheckBox ID="InitialImageCheckbox" runat="server" Text="Initial entry image" TextAlign="Right" Visible="false" AutoPostBack="false" />
                                    </div>
                                    <div style="float: right; padding-right: 10px;">
                                        <asp:Label ID="ImageDateLabel" runat="server" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="ImageWrapper" colspan="10" style="height: 300px;">
                                    <telerik:RadBinaryImage runat="server" ID="PhotoBinaryImage" ResizeMode="None" ImageAlign="Middle" Width="900" Height="510" />
                                    <telerik:RadImageEditor runat="server" ID="PhotoImageEditor" Visible="false" BorderStyle="None" EnableResize="false" Height="400" Width="600"
                                        OnClientCommandExecuting="OnClientCommandExecuting" OnClientSaved="OnClientSaved" OnImageSaving="PhotoImageEditor_ImageSaving" OnImageLoading="RadImgEdt_ImageLoading">
                                    </telerik:RadImageEditor>
                                    <telerik:RadMediaPlayer runat="server" ID="VideoPlayer" Height="400px" Visible="false"></telerik:RadMediaPlayer>
                                </td>
                            </tr>
                            <tr class="ImageFooter">
                                <td style="width: 10px;"></td>
                                <td class="DescriptionBox">
                                    <asp:Label ID="ImageDescriptionLabel" runat="server"></asp:Label>
                                </td>
                                <td style="text-align: right; vertical-align: central;">
                                    <asp:Label ID="ModifiedPhotoLabel" runat="server" Style="font-size: .8em; margin-right: 5px;" Visible="false">* This is a modified photo</asp:Label>
                                    <telerik:RadButton ID="UndoChangesButton" runat="server" Text="Undo Changes" Skin="Web20" Visible="false" />
                                    <%-- <telerik:RadButton ID="EditPhotoButton" runat="server" Text="Edit Photo" Skin="Web20" Visible="false" />--%>
                                    <telerik:RadButton ID="SaveEditPhotoButton" runat="server" Text="Save Editing" Skin="Web20" Visible="false" />
                                    <telerik:RadButton ID="CancelEditPhotoButton" runat="server" Text="Stop Editing" Skin="Web20" Visible="false" />
                                </td>
                                <td style="width: 10px;"></td>
                            </tr>
                        </table>

                    </td>
                </tr>
                
            </table>
            <table style="width: 100%; margin-top: 10px;">
                <tr>
                    <td style="width:25%">
                            <telerik:RadButton ID="AttachButton" runat="server" Text="Attach Photo" Skin="Web20" OnClientClicking="ConfirmAttach" Enabled="false" />
                        
                        </td>
                    <td style="width:25%"> 
                        <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Office2007" OnClientClicking="CloseWindow" />
                            </td>
                            <td style="width:25%">
                            <telerik:RadButton ID="DeleteButton" runat="server" Text="Delete from Cache" Skin="Web20" OnClientClicking="ConfirmDelete" />
                                </td>
                                <td style="width:25%">
                                <telerik:RadButton ID="RefreshPhotosRadButton" runat="server" Text="Refresh Photos" OnClick="RefreshPhotosLinkButton_Click" Icon-PrimaryIconUrl="~/Images/icons/refresh.png" />
                                </td>
                </tr>
            </table>
            <asp:HiddenField ID="SelectedPhotosHiddenField" runat="server" />
        </div>
        <div style="top: -32px; float: right; position: relative;">
           <%-- <telerik:RadButton ID="RefreshPhotosRadButton" runat="server" Text="Refresh Photos" OnClick="RefreshPhotosLinkButton_Click" Icon-PrimaryIconUrl="~/Images/icons/refresh.png" />--%>
        </div>
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RefreshPhotosLinkButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PhotoTable" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="ThumbnailRotator" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="AttachButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                        <telerik:AjaxUpdatedControl ControlID="PhotoTable" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="ThumbnailRotator">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PhotoTable" />
                        <telerik:AjaxUpdatedControl ControlID="AttachButton" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PhotoTable" />
                        <telerik:AjaxUpdatedControl ControlID="AttachButton" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>
        <telerik:RadWindowManager ID="PhotosWindowManager" runat="server" ShowContentDuringLoad="false" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move">
            <Windows>
                <telerik:RadWindow ID="ProcedureStartImageRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="340px" Height="150px" Skin="Metro" Title="Confirm" VisibleStatusbar="false" Animation="None">
                    <ContentTemplate>
                        <p>
                            <asp:Label ID="ProcedureStartImageQuestionLabel" runat="server">
                                Was THIS the initial photo taken to signify insertion time?
                            </asp:Label>
                        </p>
                        <div id="divButtons" style="height: 10px; margin-top: 10px; margin-left: 10px; padding-top: 6px; text-align: center;">
                            <telerik:RadButton ID="ProcedureStartYesButton" runat="server" Text="Yes" Skin="Metro" OnClick="ProcedureStartYesButton_Click" />
                            <telerik:RadButton ID="ProcedureStartNoButton" runat="server" Text="No" Skin="Metro" OnClick="ProcedureStartNoButton_Click" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>

        <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
            <script type="text/javascript">
                $(document).ready(function () {
                    Sys.Application.add_load(function () {
                        $('#SiteRadioButton').click(function () {
                            ToggleTD($(this));
                        });

                        $('#<%=SiteComboBox.ClientID%>').on('change', function () {
                            ToggleSiteConfirmationDiv();
                        });

                        $('#<%=InitialImageCheckbox.ClientID%>').on('click', function () {
                            if ($(this).is(':checked')) {
                                var selectedPhotoIndex = $('#<%=SelectedPhotosHiddenField.ClientID %>').val();
                                selectedPhotoIndex = selectedPhotoIndex.substring(0, selectedPhotoIndex.length - 1);
                                if (selectedPhotoIndex == "") {
                                    alert("No photo selected!");
                                    return false;
                                }
                                else if (selectedPhotoIndex.split(",").length > 1) {
                                    alert("Please choose just one photo as you initial entry image!");
                                    return false;
                                }
                                else {
                                    var procedureId = <%=Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>;
                                    if (confirm('Mark this image as your initial entry image?')) {
                                        $.ajax({
                                            type: "POST",
                                            url: "Photos.aspx/MarkAsInitialImage",
                                            dataType: "json",
                                            data: JSON.stringify({ selectedImageIndex: parseInt(selectedPhotoIndex.replace(",", "")), procId: parseInt(procedureId) }),
                                            contentType: "application/json; charset=utf-8",
                                            success: function (data) {
                                                $('#<%=InitialImageCheckbox.ClientID%>').prop("disabled", "disabled");
                                                $find("<%=RadAjaxManager1.ClientID%>").ajaxRequest("initial-image-set");
                                            },
                                            error: function (jqXHR, textStatus, data) {
                                                alert("Unknown error occured");
                                            }
                                        });
                                    }
                                }
                            }
                        });
                    });

                });

                function ToggleSiteConfirmationDiv() {
                    //check see if selected item is rectum
                    var selectedItem = $find('<%=SiteComboBox.ClientID%>').get_text();
                    //if (selectedItem.toLowerCase().includes("rectum")) {
                    if (selectedItem.toLowerCase() == "rectum") {
                        $('.rectum-final-image-confirmation').show();
                    }
                    else {
                        $('.rectum-final-image-confirmation').hide();
                    }
                }

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

                function showInitialImageCheckWindow() {
                    var oWnd = $find("<%= ProcedureStartImageRadWindow.ClientID %>");
                    oWnd.show();
                    oWnd.moveTo(250, 10);
                }

                function initialImageCheck() {
                    var procId = <%=iProcedureId%>;
                    $.ajax({
                        type: "POST",
                        url: "Photos.aspx/InitialImageSet",
                        data: JSON.stringify({ "procedureId": parseInt(procId) }),
                        dataType: "json",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            if (data.d != null)
                                if (data.d == false) {
                                    showInitialImageCheckWindow();
                                }
                                else {
                                                $('#<%=InitialImageCheckbox.ClientID%>').prop("disabled", "disabled");

                                    $find("<%=RadAjaxManager1.ClientID%>").ajaxRequest("disable-checkbox");
                                }
                        },
                        error: function (jqXHR, textStatus, data) {
                            var notification = $find("<%=RadNotification1.ClientID%>");
                            notification.set_text(jqXHR.responseJSON.Message);
                            notification.show();
                        }
                    });
                }

                $(window).on('load', function () {
                    $('#SiteRadioButton').click(function () {
                        ToggleTD($(this));
                    });
                    $('#ProcedureRadioButton').click(function () {
                        ToggleTD($('#SiteRadioButton'));
                    });

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

                function ToggleTD(rdo) {
                    var checked = rdo.is(':checked');
                    if (checked) {
                        //$(this).show();
                        $('#SiteComboBoxTD').fadeIn();
                    }
                    else {
                        //$(this).hide();
                        $('#SiteComboBoxTD').fadeOut();
                    }

                    $find('<% =AttachButton.ClientId %>').set_enabled(true);
                }

                function onEndCrop(coords, dimensions) {
                }

                function ConfirmDelete(sender, args) {
                    args.set_cancel(!window.confirm("Are you sure you want to permanently delete selected image(s) from the cache?"));
                }

                function ConfirmAttach(sender, args) {
                    if ($find('<% =AttachButton.ClientId %>').get_text() == "Attach Photo") {
                        alert('No photos selected!');
                        args.set_cancel(true);
                    }
                }


                var ctrlKeyPressed = false;

                //Check if Ctrl key is pressed for multiple selection
                function isKeyPressed(e) {
                    if (e.ctrlKey) { ctrlKeyPressed = true; }
                    else { ctrlKeyPressed = false; }
                }

                function ThumnailClicked(sender, args) {

                    //check if editor (#PhotoImageEditor) is open.. if so, do nothing
                    var editor = $find('<%=PhotoImageEditor.ClientID%>');
                    if (editor == null) {
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
                                photoIndexes = photoIndexes.concat(iIndex + ',');
                                iCnt++;
                            }

                            iIndex++;
                            if (iCnt == 0) {
                                $find('<% =AttachButton.ClientId %>').set_text("Attach Photo");
                            } else if (iCnt == 1) {
                                $find('<% =AttachButton.ClientId %>').set_text("Attach " + iCnt + " Photo");
                            } else {
                                $find('<% =AttachButton.ClientId %>').set_text("Attach " + iCnt + " Photos");
                            }
                        });
                        document.getElementById('<%= SelectedPhotosHiddenField.ClientID %>').value = photoIndexes;
                    }
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

                function OnClientSaved(imgEditor, args) {
                    __doPostBack('<%=SaveEditPhotoButton.ClientID %>', '')
                }
            </script>
        </telerik:RadCodeBlock>
    </form>
</body>
</html>
