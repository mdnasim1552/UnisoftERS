<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ImagePicker.aspx.vb" Inherits="UnisoftERS.ImagePicker" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

    <title></title>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .images-list li {
            float: left;
            list-style-type: none;
            padding: 3px;
        }
    </style>
    <script type="text/javascript">
        function resizeImage(imgToResize) {
            if (imgToResize.height = 100) {

                imgToResize.style.height = (imgToResize.naturalHeight / 2) + "px";
                imgToResize.style.width = (imgToResize.naturalWidth / 2) + "px";
            }
        }

        function selectImage(control, section, selectedImageTimeStamp) {
            if (control == 'timings') {
                GetRadWindow().BrowserWindow.startTimingsImageSelected(section, selectedImageTimeStamp);
                GetRadWindow().close();

            }
            else if (control == 'caecum') {
                GetRadWindow().BrowserWindow.startCaecumImageSelected(section, selectedImageTimeStamp);
                GetRadWindow().close();
            }
            else if (control == 'gastritis') {
                GetRadWindow().BrowserWindow.startGastritisImageSelected(section, selectedImageTimeStamp);
                GetRadWindow().close();
            }

        }

        function GetRadWindow() {
            var oWindow = null;
            if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
            else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

            return oWindow;
        }

        function CloseWindow() {
            var oWnd = GetRadWindow();
            oWnd.setUrl("about:blank");
            oWnd.close();
        }

    </script>
</head>
<body>
    <form runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" />
        <telerik:RadNotification ID="DownloadErrorRadNotification" runat="server" Animation="Fade"
            EnableRoundedCorners="true" EnableShadow="true" Title="Image Download Error"
            LoadContentOn="PageLoad" TitleIcon="delete" Position="Center"
            AutoCloseDelay="0" Skin="Web20" Width="500px" ShowCloseButton="false">
            <ContentTemplate>
                <div id="errMsg" runat="server" class="aspxValidationSummary"></div>
                <div style="height: 20px; margin-left: 10px; margin-bottom: 5px; text-align: center;">
                    <telerik:RadButton ID="RedownloadPhotosRadButton" runat="server" Text="Re-download photos" OnClick="RedownloadPhotosRadButton_Click" Icon-PrimaryIconUrl="~/Images/icons/refresh.png" />
                    <telerik:RadButton ID="CancelAndCloseRadButton" runat="server" Text="Cancel and Close" Skin="Web20" AutoPostBack="false" OnClientClicked="CloseWindow" />
                </div>
            </ContentTemplate>
        </telerik:RadNotification>
        <div id="controls" style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; font-size: 12px;">
            <asp:Panel ID="ProductImagesPanel" runat="server">
                <asp:Repeater ID="ProcedureImagesRepeater" runat="server" OnItemDataBound="ProcedureImagesRepeater_ItemDataBound">
                    <HeaderTemplate>
                        <ul class="images-list">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <li>
                            <asp:Image ID="ProcedureImage" Style="height: 100px; width: 100px" ImageUrl='<%#Eval("ImageUrl") %>' runat="server" onclick="resizeImage(this);" /><br />
                            <asp:Label runat="server" Text='<%#CDate(Eval("CreateDate")).TimeOfDay %>' /><br />
                            <asp:LinkButton ID="ChooseImageRadButton" runat="server" Text="Choose image" />
                        </li>
                    </ItemTemplate>
                    <FooterTemplate>
                        </ul>
                    </FooterTemplate>
                </asp:Repeater>
            </asp:Panel>
            <asp:Panel ID="NoImagesPanel" runat="server" Visible="false">
                <span>There are no images available</span>
            </asp:Panel>
        </div>
    </form>
</body>
</html>
