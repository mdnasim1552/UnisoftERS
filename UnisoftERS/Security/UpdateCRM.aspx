<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Security_UpdateCRM" Codebehind="UpdateCRM.aspx.vb" %>

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

            function OpenGPWindow() {
                var oWnd2 = $find("<%= UpdateCRMWindow.ClientID%>");
                //Add the name of the function to be executed when RadWindow is closed.
                oWnd2.add_close(OnClientClose);
                oWnd2.show();
            }

            function OnClientClose(oWnd, eventArgs) {
                //Remove the OnClientClose function to avoid
                //adding it for a second time when the window is shown again.
                oWnd.remove_close(OnClientClose);

                RefreshSiteSummary();
            }

            function CloseGPWindow() {
                var oWnd = $find("<%= UpdateCRMWindow.ClientID%>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function CheckForValidPage(button) {
                var valid = Page_ClientValidate("UpdateCRM");
                if (!valid) {
                    $find("<%=UpdateCRMNotification.ClientID%>").show();
                }
            }
        </script>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20"  />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Web20" />
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="340px" Height="50px"  Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7" >
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="250px" >

                <br/>
                <div id="FormDiv" runat="server" style="padding-left:10px; "  >

                    <fieldset id="PlannedProceduresFieldset" runat="server">
 
                        <table>
                            <tr>
                                <td style="width:170px; height:50px; ">
                                    <label runat="server" id="Label2" >Maintenance Expiration Date:</label>
                                </td>
                                <td>
                                    <telerik:RadDatePicker ID="ExpiresOnDatePicker" MinDate="2009/1/1" runat="server"  Width="110px" Skin="Default" DatePopupButton-Visible="false" DateInput-BackColor="#e6e6e6" DateInput-Culture="en-GB" Enabled="false"    >
                                    </telerik:RadDatePicker>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <label runat="server" id="Label3">Maintenance Renewal Date:</label>
                                    <asp:RequiredFieldValidator ID="RenewalDateRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="RenewalDatePicker" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Renewal Date is required" Text="*" ToolTip="This is a required field"
                                        ValidationGroup="UpdateCRM" ForeColor="Red">
                                    </asp:RequiredFieldValidator>
                                </td>
                                <td>
                                    <telerik:RadDatePicker ID="RenewalDatePicker" MinDate="2009/1/1" runat="server" Width="110px" Skin="Windows7" DateInput-Culture="en-GB" />
                                </td>
                            </tr>
                            <tr>
                                <td style="height:20px;">
                                </td>
                                <td>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
            </telerik:RadPane>

            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
                <div style="height: 10px; margin-left: 10px; padding-top: 6px; text-align:right;   ">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" OnClientClicked="CheckForValidPage" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" 
                        AutoPostBack="false" OnClientClicked="CloseWindow" />
                </div>

                <telerik:RadNotification ID="UpdateCRMNotification" runat="server" Animation="None"
                    EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                    LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;" AutoCloseDelay="70000">
                    <ContentTemplate>
                        <asp:ValidationSummary ID="UpdateCRMValidationSummary" runat="server" ValidationGroup="UpdateCRM" DisplayMode="BulletList"
                            EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                    </ContentTemplate>
                </telerik:RadNotification>
            </telerik:RadPane>
        </telerik:RadSplitter>

        <telerik:RadWindowManager ID="UpdateCRMWindowManager" runat="server" 
            Style="z-index: 7001" Behaviors="Close, Move" AutoSize="false" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="UpdateCRMWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" 
                    Width="700px" Height="300px" Title="Update CRM" VisibleStatusbar="false" />
            </Windows>
        </telerik:RadWindowManager>

    </form>
</body>
</html>
