<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="EditTrust.aspx.vb" Inherits="UnisoftERS.EditTrust" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add/Edit Trust</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />


    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
    <script type="text/javascript">

        function CloseAndRebind() {
            var oWnd = GetRadWindow();
            oWnd.BrowserWindow.refreshGrid();
            oWnd.close();
        }

        function GetRadWindow() {
            var oWindow = null;
            if (window.radWindow)
                oWindow = window.radWindow;
            else if (window.frameElement.radWindow)
            oWindow = window.frameElement.radWindow;
            return oWindow;
        }
        
        function CheckForValidPage() {
            var valid = Page_ClientValidate("SaveTrust");
            if (!valid) {
                $find("<%=ValidationNotification.ClientID%>").show();
            }
        }

    </script>
    </telerik:RadScriptBlock>

</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <div id="FormDiv">
            <asp:HiddenField ID="TrustId" runat="server" />
            <table>

                <tr>
                    <td>
                        <telerik:RadTextBox ID="TrustTextBox" runat="server" Width="400" MaxLength="200" Label="Trust Name:" />
                        <asp:RequiredFieldValidator ID="DiagnosisRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                            ControlToValidate="TrustTextBox" EnableClientScript="true" Display="Dynamic"
                            ErrorMessage="Trust name is required" Text="*" ToolTip="This is a required field"
                            ValidationGroup="SaveTrust">
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <telerik:RadButton ID="saveButton" runat="server" Text="Save & Close" Skin="Metro" OnClick="saveButton_Click" CausesValidation="true" OnClientClicked="CheckForValidPage" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    </td>
                </tr>
            </table>
        </div>

        <telerik:RadNotification ID="ValidationNotification" runat="server" Animation="None" Width="400"
            EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
            LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
            AutoCloseDelay="7000">
            <ContentTemplate>
                <asp:ValidationSummary ID="SaveValidationSummary" runat="server" ValidationGroup="SaveAbnormality" DisplayMode="BulletList"
                    EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                <asp:Label ID="ServerErrorLabel" runat="server" CssClass="aspxValidationSummary" Visible="false"></asp:Label>
            </ContentTemplate>
        </telerik:RadNotification>

    </form>
</body>
</html>
