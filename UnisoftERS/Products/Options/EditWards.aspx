<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="EditWards.aspx.vb" Inherits="UnisoftERS.EditWards" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Ward Details</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        
    </style>
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {

            });

            function CheckForValidPage() {
            }


            function CloseAndRebind(args) {
                GetRadWindow().BrowserWindow.refreshGrid(args);
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                return oWindow;
            }

        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <form id="form2" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />

        <asp:ObjectDataSource ID="HospitalObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetOperatingHospitals" />

        <div style="margin-left: 10px; padding-top: 15px" class="rptText">
            <asp:Label runat="server" Text="Hospital" Width="120px" />
            <telerik:RadDropDownList ID="HospitalDropDownList" runat="server" Width="200" DataTextField="HospitalName" DefaultMessage="Select a hospital" DataValueField="OperatingHospitalID" DataSourceID="HospitalObjectDataSource" Skin="Metro" />
            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" CssClass="aspxValidator"
                ControlToValidate="HospitalDropDownList" EnableClientScript="true" Display="Dynamic"
                ErrorMessage="Operating hospital is required" Text="*" ToolTip="This is a required field"
                ValidationGroup="SaveWard" />
            <br />
            <br />
            <asp:Label runat="server" Text="Ward Name" Width="120px" /><asp:TextBox ID="WardNameTextBox" runat="server" Width="200" Skin="Metro" />
            <asp:RequiredFieldValidator ID="WardNameRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                ControlToValidate="WardNameTextBox" EnableClientScript="true" Display="Dynamic"
                ErrorMessage="Ward name is required" Text="*" ToolTip="This is a required field"
                ValidationGroup="SaveWard">
            </asp:RequiredFieldValidator>
            <br />
            <br />
            <div id="cmdOtherData" style="height: 10px; margin-left: 10px;">
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Metro" OnClick="SaveWard" CausesValidation="true" OnClientClicked="CheckForValidPage" Icon-PrimaryIconCssClass="telerikSaveButton" />
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
            </div>

        </div>

    </form>
</body>
</html>
