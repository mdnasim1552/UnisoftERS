<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERSViewer.Security_Support" Codebehind="Support.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="../Styles/Site.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../Scripts/Global.js"></script>
    <style type="text/css">
        .rcbSlide {
            z-index: 999999 !important;
        }
    </style>
</head>
<body>
    <form id="mainForm" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <script type="text/javascript">
            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow;
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow;
                return oWindow;
            }

            function CloseDialog() {
                GetRadWindow().close();
            }

            function OnClientClose(oWnd, eventArgs) {
                //Remove the OnClientClose function to avoid
                //adding it for a second time when the window is shown again.
                oWnd.remove_close(OnClientClose);

                RefreshSiteSummary();
            }

            function CheckForValidPage(button) {
                var valid = Page_ClientValidate("Support");
                if (!valid) {
                    $find("<%=SupportNotification.ClientID%>").show();
                }
            }
        </script>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20"  />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Web20" />
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="550"  Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7" >
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="400px" >

                <br/>
                <div id="FormDiv" runat="server" style="padding-left:22px; "  >
                        <table>
                            <tr>
                                <td>
                                      Please paste text here :
                                    <telerik:RadTextBox runat="server" ID="RadTextBox1" Width="500" height="350"></telerik:RadTextBox>
                                </td>
                            </tr>
                        </table>
                  </div>
            </telerik:RadPane>

            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
                <div style="padding-top: 6px; padding-right:22px;  text-align:right;   ">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" OnClientClicked="CheckForValidPage" Width="100"  />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" 
                        AutoPostBack="false" OnClientClicked="CloseWindow" />
                </div>

                <telerik:RadNotification ID="SupportNotification" runat="server" Animation="None"
                    EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                    LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;" AutoCloseDelay="70000">
                    <ContentTemplate>
                        <asp:ValidationSummary ID="SupportValidationSummary" runat="server" ValidationGroup="Support" DisplayMode="BulletList"
                            EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                    </ContentTemplate>
                </telerik:RadNotification>
            </telerik:RadPane>
        </telerik:RadSplitter>

        <telerik:RadWindowManager ID="SupportWindowManager" runat="server" 
            Style="z-index: 7001" Behaviors="Close, Move" AutoSize="false" Skin="Office2007" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="SupportWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" 
                    Width="700px" Height="300px" Title="Support" VisibleStatusbar="false" />
            </Windows>
        </telerik:RadWindowManager>

    </form>
</body>
</html>
