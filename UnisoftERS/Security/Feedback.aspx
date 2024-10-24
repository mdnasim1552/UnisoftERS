<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Security_Feedback" CodeBehind="Feedback.aspx.vb"  %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Feedback</title>
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
                var oWnd2 = $find("<%= FeedbackWindow.ClientID%>");
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
                var oWnd = $find("<%= FeedbackWindow.ClientID%>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function CheckForValidPage(button) {
                var valid = Page_ClientValidate("Feedback");
                if (!valid) {
                    $find("<%=FeedbackNotification.ClientID%>").show();
                }
            }
        </script>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Web20" Style="z-index: 9999" />
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="500px" Height="550px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7" >
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="450px" Scrolling="None">

                <div id="FormDiv" runat="server" style="padding-left: 10px; vertical-align: top;">
                    <asp:Label class="divWelcomeMessage" ID="lblFeedback" runat="server" Text="Thank you for taking the time to let us know about your experiences with ERS!" Style="margin-left: 15px;" />

                    <table cellpadding="5">
                        <tr>
                            <td>
                                <div style="margin-left: 5px;">
                                    Your name: 
                                </div>
                            </td>
                            <td>
                                <telerik:RadTextBox ID="NameTextBox" runat="server" Skin="Windows7" Width="370" ValidationGroup="Feedback" />
                                <asp:RequiredFieldValidator ID="NameTextBoxRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                    ControlToValidate="NameTextBox" EnableClientScript="true" Display="Dynamic"
                                    ErrorMessage="Full name is required" Text="*" ToolTip="This is a required field"
                                    ValidationGroup="Feedback">
                                </asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div style="margin-left: 5px;">
                                    Email address: 
                                </div>
                            </td>
                            <td>
                                <telerik:RadTextBox ID="EmailAddressTextBox" runat="server" Skin="Windows7" Width="370" ValidationGroup="Feedback" />
                                <asp:RequiredFieldValidator ID="EmailAddressTextBoxRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                    ControlToValidate="EmailAddressTextBox" EnableClientScript="true" Display="Dynamic"
                                    ErrorMessage="Email address is required" Text="*" ToolTip="This is a required field"
                                    ValidationGroup="Feedback">
                                </asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td style="vertical-align: top;">
                                <div style="margin-left: 5px;">
                                    Feedback: 
                                </div>
                            </td>
                            <td>
                                <telerik:RadTextBox ID="FeedbackTextBox" runat="server" Skin="Windows7" Width="370" TextMode="MultiLine" Height="200" />
                                <asp:RequiredFieldValidator ID="FeedbackTextBoxRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                    ControlToValidate="FeedbackTextBox" EnableClientScript="true" Display="Dynamic"
                                    ErrorMessage="Feedback message is required" Text="*" ToolTip="This is a required field"
                                    ValidationGroup="Feedback">
                                </asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td style="vertical-align: top;">
                                <div style="margin-left: 5px;">
                                   Attachment: 
                                </div>
                            </td>
                            <td>
                                <telerik:RadAsyncUpload ID="AttachemnetAsyncUpload" EnablePermissionsCheck="true" runat="server" 
                                    AllowedFileExtensions="jpg,jpeg,png,gif,txt,pdf" MaxFileInputsCount="1" MaxFileSize="2097152" 
                                     /><%--OnFileUploaded="AttachemnetAsyncUpload_FileUploaded"--%>
                               <%-- <telerik:RadButton ID="uploadbutton" runat="server" Text="Upload attachment" />--%>
                            </td><%--PostbackTriggers="uploadbutton" --%>
                        </tr>
                        <tr>
                            <td style="height: 20px;"></td>
                            <td></td>
                        </tr>
                    </table>
                </div>
                <div id="sentDiv" runat="server" style="display:none">
                    <asp:Label class="divWelcomeMessage" ID="Label1" runat="server" Text="Your feedback has been received successfully.</br> Thank you." Style="margin-left: 15px;" />
                </div>
            </telerik:RadPane>

            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
                <div style="height: 10px; margin-left: 10px; padding-top: 6px; text-align: right;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Submit feedback" Skin="Web20" OnClientClicked="CheckForValidPage" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20"
                        AutoPostBack="false" OnClientClicked="CloseWindow" />
                </div>
                <telerik:RadNotification ID="FeedbackNotification" runat="server" Animation="None"
                    EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                    LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;" AutoCloseDelay="70000">
                    <ContentTemplate>
                        <asp:ValidationSummary ID="FeedbackValidationSummary" runat="server" ValidationGroup="Feedback" DisplayMode="BulletList"
                            EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                    </ContentTemplate>
                </telerik:RadNotification>
            </telerik:RadPane>
        </telerik:RadSplitter>

        <telerik:RadWindowManager ID="FeedbackWindowManager" runat="server"
            Style="z-index: 7001" Behaviors="Close, Move" AutoSize="false" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="FeedbackWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
                    Width="700px" Height="300px" Title="Feedback" VisibleStatusbar="false" />
            </Windows>
        </telerik:RadWindowManager>

    </form>
</body>
</html>
