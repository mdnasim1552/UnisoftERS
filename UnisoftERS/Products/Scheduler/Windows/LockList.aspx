<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="LockList.aspx.vb" Inherits="UnisoftERS.LockList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../../Scripts/global.js"></script>
    <link href="../../../Styles/Site.css" rel="stylesheet" />
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            function validateDiaryLockReason(sender, args) {
                var valid = Page_ClientValidate("saveLockReason");
            }

            function CloseAndRebind() {
                GetRadWindow().BrowserWindow.reloadDiary();
                GetRadWindow().close();
            }

            function CloseWindow() {
                GetRadWindow().close();
            }
            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                return oWindow;
            }
        </script>

        <style type="text/css">
            label, span{
                font-size:12px !important;
            }
        </style>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager runat="server" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Position="Center" Skin="Metro" />

        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="formDiv" Skin="Metro" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />
     <%--   <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="SaveLockDiaryRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SaveLockDiaryRadButton" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>--%>
        <div id="formDiv">
            <asp:HiddenField ID="LockedDiaryIdHiddenField" runat="server" />
            <table style="width: 100%;">
                <tr>
                    <td colspan="2">
                        <p>
                            <telerik:RadLabel Font-Bold="true" ForeColor="Red" ID="LockReasonDiaryDetailsLabel" runat="server" Skin="Metro" Text="List Lock Reason" />
                            </p>
                    </td>
                </tr>
                <tr>
                    <td style="text-align: right;">
                        <telerik:RadLabel runat="server" Skin="Metro">Choose a reason:</telerik:RadLabel></td>
                    <td>
                        <telerik:RadComboBox ID="LockReasonRadComboBox" runat="server" ZIndex="9999" Width="385" />
                        <asp:RequiredFieldValidator ID="LockReasonRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                            ControlToValidate="LockReasonRadComboBox" EnableClientScript="true" Display="Dynamic"
                            ErrorMessage="Lock reason is required" Text="*" ToolTip="This is a required field"
                            ValidationGroup="saveLockReason">
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>
                <tr>
                    <td valign="top" style="text-align: right;">
                        <telerik:RadLabel runat="server" Skin="Metro">
                            Please enter authorisation:
                        
                        </telerik:RadLabel>
                    </td>
                    <td valign="top">
                        <telerik:RadTextBox ID="DiaryLockAuthorisationRadTextBox" runat="server" TextMode="MultiLine" Width="385" Height="75" />
                        <asp:RequiredFieldValidator ID="DiaryLockAuthorisationRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                            ControlToValidate="DiaryLockAuthorisationRadTextBox" EnableClientScript="true" Display="Dynamic"
                            ErrorMessage="Lock authorisation is required" Text="*" ToolTip="This is a required field" ForeColor="red"
                            ValidationGroup="saveLockReason">
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>
            </table>
            <asp:CustomValidator ID="DiaryLockReasonCustomValidator" runat="server" ErrorMessage="You must enter a reason" ForeColor="Red" />
            <telerik:RadNotification ID="SaveLockReasonRadNotification" runat="server" Animation="None"
                EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
                AutoCloseDelay="70000">
                <ContentTemplate>
                    <asp:ValidationSummary ID="SaveLockReasonValidationSummary" runat="server" ValidationGroup="saveLockReason" DisplayMode="BulletList"
                        EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                </ContentTemplate>
            </telerik:RadNotification>
            <div class="buttons-div" style="margin-top: 20px;">
                <telerik:RadButton ID="SaveLockDiaryRadButton" runat="server" Text="Save" OnClick="SaveLockReasonButton_Click" OnClientClicked="validateDiaryLockReason" ValidationGroup="saveLockReason" />
                <telerik:RadButton ID="CancelLockDiaryRadButton" runat="server" Text="Cancel" OnClientClicked="CloseWindow" AutoPostBack="false" />
            </div>
        </div>
    </form>
</body>
</html>
