<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="EditOtherAbnormality.aspx.vb" Inherits="UnisoftERS.EditOtherAbnormality" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add/Edit Other Abnormality</title>
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
            var valid = Page_ClientValidate("SaveAbnormality");
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
            <asp:HiddenField ID="AbnormalityId" runat="server" />
            <table>
                <tr>
                    <td>
                        <telerik:RadTextBox ID="AbnormalityTextBox" runat="server" Width="400" MaxLength="200" Label="Abnormality :" />
                        <asp:RequiredFieldValidator ID="AbnormalityRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                            ControlToValidate="AbnormalityTextBox" EnableClientScript="true" Display="Dynamic"
                            ErrorMessage="Abnormality is required" Text="*" ToolTip="This is a required field"
                            ValidationGroup="SaveAbnormality">
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>
                <tr>
                    <td>
                        <telerik:RadTextBox ID="SummaryTextBox" runat="server" Width="400" MaxLength="200" Label="Summary :" />
                        <asp:RequiredFieldValidator ID="SummaryRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                            ControlToValidate="SummaryTextBox" EnableClientScript="true" Display="Dynamic"
                            ErrorMessage="Summary is required" Text="*" ToolTip="This is a required field"
                            ValidationGroup="SaveAbnormality">
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>
                <tr>
                    <td>
                        <telerik:RadTextBox ID="DiagnosisTextBox" runat="server" Width="400" MaxLength="200" Label="Diagnosis :" />
                        <asp:RequiredFieldValidator ID="DiagnosisRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                            ControlToValidate="DiagnosisTextBox" EnableClientScript="true" Display="Dynamic"
                            ErrorMessage="Diagnoses is required" Text="*" ToolTip="This is a required field"
                            ValidationGroup="SaveAbnormality">
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>
                <tr>
                    <td>
                        <telerik:RadComboBox ID="ProcedureTypeRadComboBox" runat="server" Width="270px"  AutoPostBack="true" OnSelectedIndexChanged="ProcedureTypeRadComboBox_SelectedIndexChanged" label="Procedure Type :" skin="Metro" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <fieldset>
                            <legend>&nbsp;Regions&nbsp;</legend>
                            <div style="padding: 10px">
                                <asp:CheckBoxList ID="RegionsCheckboxes" runat="server" CellSpacing="0" CellPadding="0"
                                    RepeatLayout="Table" RepeatDirection="Horizontal" RepeatColumns="2" />
                            </div>
                        </fieldset>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:CheckBox ID="ActiveCheckBox" Text="Active :" runat="server" TextAlign="Left" />
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
