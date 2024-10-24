<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_UserSettings" Codebehind="UserSettings.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {

            });

            $(document).ready(function () {
            });

            function AccessParent() {
                var splitterPageWnd = window.parent;
                splitterPageWnd.AlertFromParent();
            }

            function CheckForValidPage() {
                var valid = Page_ClientValidate("ChangePassword");
                if (!valid) {
                    $("#<%=ServerErrorLabel.ClientID%>").hide();
                    $find("<%=ValidationNotification.ClientID%>").show();
                }
            }
        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
        </telerik:RadAjaxManager>
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <div class="optionsHeading">User Settings</div>

        <table class="optionsBodyText" style="margin-top: 5px;margin-left:5px;" width="820px" cellpadding="0" cellspacing="0" runat="server" id="changePasswordTable">
            <tr>
                <td>

                    <fieldset>
                        <legend><b>Change Password</b></legend>
                        <div style="margin-top: 5px;">
 
                            <div id="PasswordRulesDiv" runat="server" class="optionsHeadingNote">
                                Following are the restrictions imposed by your admin. Passwords<br />
                                <asp:Label id="PasswordRulesLabel" runat="server"></asp:Label>
                            </div>

                            <table id="tablePassword" runat="server">
                                <tr>
                                    <td style="width: 150px;">Current password:</td>
                                    <td> 
                                        <telerik:RadTextBox ID="OldPasswordTextBox" runat="server" TextMode="Password" Width="200" Skin="Windows7" />
                                        <asp:RequiredFieldValidator ID="OldPasswordRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                            ControlToValidate="OldPasswordTextBox" EnableClientScript="true" Display="Dynamic"
                                            ErrorMessage="Old password is required" Text="*" ToolTip="This is a required field"
                                            ValidationGroup="ChangePassword">
                                        </asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td>New password:</td>
                                    <td>
                                        <telerik:RadTextBox ID="NewPasswordTextBox" runat="server" TextMode="Password" Width="200" Skin="Windows7" />
                                        <asp:RequiredFieldValidator ID="NewPasswordRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                            ControlToValidate="NewPasswordTextBox" EnableClientScript="true" Display="Dynamic"
                                            ErrorMessage="New password is required" Text="*" ToolTip="This is a required field"
                                            ValidationGroup="ChangePassword">
                                        </asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Confirm new password:</td>
                                    <td>
                                        <telerik:RadTextBox ID="ConfirmPasswordTextBox" runat="server" TextMode="Password" Width="200" Skin="Windows7" />
                                        <asp:RequiredFieldValidator ID="ConfirmPasswordRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                            ControlToValidate="ConfirmPasswordTextBox" EnableClientScript="true" Display="Dynamic"
                                            ErrorMessage="Confirm password is required" Text="*" ToolTip="This is a required field"
                                            ValidationGroup="ChangePassword">
                                        </asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </fieldset>
                </td>
            </tr>
        </table>
        <table class="optionsBodyText" style="margin-top: 5px;margin-left:5px;" width="820px" cellpadding="0" cellspacing="0" runat="server" id="NoUserSettings">
            <tr>
                <td>
                    No user settings available
                </td>
            </tr>
        </table>

        <div class="divButtons" style="margin-top: 40px;">
            <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" ValidationGroup="ChangePassword"
                CausesValidation="true" OnClientClicked="CheckForValidPage" Icon-PrimaryIconCssClass="telerikSaveButton"/>
            <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20"
                CausesValidation="false" Icon-PrimaryIconCssClass="telerikCancelButton"/>
        </div>

        <telerik:RadNotification ID="ValidationNotification" runat="server" Animation="None"
            EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
            LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
            AutoCloseDelay="7000">
            <ContentTemplate>
                <asp:ValidationSummary ID="ChangePasswordValidationSummary" runat="server" ValidationGroup="ChangePassword" DisplayMode="BulletList"
                    EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                <asp:Label ID="ServerErrorLabel" runat="server" CssClass="aspxValidationSummary" Visible="false"></asp:Label>
            </ContentTemplate>
        </telerik:RadNotification>
    </form>
</body>
</html>
