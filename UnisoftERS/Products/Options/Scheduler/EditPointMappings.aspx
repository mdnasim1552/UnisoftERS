<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="EditPointMappings.aspx.vb" Inherits="UnisoftERS.EditPointMappings" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" />

        <telerik:RadFormDecorator ID="WindowFormDecorator" runat="server" DecorationZoneID="AddEditMappingsDiv" Skin="Metro" DecoratedControls="All" />
        <div id="AddEditMappingsDiv">
            <asp:HiddenField ID="PointsMappingIDHiddenField" runat="server" />
            <div style="margin-top: 15px; margin-left: 6px; margin-bottom: 10px; font-weight: bold;">
                Point mappings for&nbsp;<asp:Label ID="ProcedureTypeLabel" runat="server" />
            </div>
            <table cellspacing="3" cellpadding="3">
                <tr class="non-gi-procedure-tr">
                    <td>Procedure:
                    </td>
                    <td>
                        <telerik:RadTextBox ID="NonGIProcedureTypeRadTextBox" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td>Points:</td>
                    <td>
                        <telerik:RadTextBox ID="PointsRadTextBox" runat="server" Width="40" /></td>
                </tr>
                <tr>
                    <td valign="top">Minutes:</td>
                    <td>
                        <telerik:RadNumericTextBox ID="MinutesRadTextBox" runat="server"
                            IncrementSettings-InterceptMouseWheel="false"
                            IncrementSettings-Step="1"
                            Width="45px"
                            MinValue="1" MaxValue="1000">
                            <NumberFormat DecimalDigits="0" />
                        </telerik:RadNumericTextBox>
                    </td>
                </tr>
            </table>
            <div id="buttonsdiv" style="height: 10px; padding-top: 6px; text-align: center;">
                <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Save" Skin="Metro" OnClick="AddNewItemSaveRadButton_Click" />
                <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="Metro" OnClientClicked="closeAddItemWindow" />
            </div>
        </div>
    </form>
</body>
</html>
