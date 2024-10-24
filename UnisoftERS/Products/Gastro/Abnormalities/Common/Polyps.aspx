<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Polyps.aspx.vb" Inherits="UnisoftERS.Polyps" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Polyp Details</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" Visible="False" />
    <link href="../../../Styles/Site.css" rel="stylesheet" />
    <script src="../../../Scripts/jquery-1.11.0.min.js"></script>
    <script src="../../../Scripts/global.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="PRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="PRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <div id="FormDiv" style="padding: 20px; width:600px; min-height:210px; font-size:12px; font-family:Segoe UI,Arial,Helvetica,sans-serif">
            <asp:Repeater ID="PolypsRepeater" runat="server" OnItemDataBound="PolypsRepeater_ItemDataBound">
                <HeaderTemplate>
                    <table>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td style="padding-top: 15px;">
                            <span><%# Container.ItemIndex + 1 %>:</span>&nbsp; 
                            type <telerik:RadComboBox ID="PolypTypeComboBox" runat="server" Skin="Metro" Width="50" MarkFirstMatch="true" />
                            &nbsp;&nbsp;&nbsp;size
                            <telerik:RadNumericTextBox ID="polypSizeNumericTextBox" runat="server" Skin="Metro"
                                ShowSpinButtons="true"
                                IncrementSettings-InterceptMouseWheel="true"
                                IncrementSettings-Step="1"
                                Width="50px"
                                MinValue="0">
                                <NumberFormat DecimalDigits="0" />
                            </telerik:RadNumericTextBox>mm
                            &nbsp;&nbsp;&nbsp;
                            <telerik:RadButton ID="excisedCheckBox" runat="server" 
                                ToggleType="CheckBox" 
                                ButtonType="ToggleButton" 
                                ForeColor="Gray" 
                                Text="excised" 
                                Skin="Web20" >
                            </telerik:RadButton>
                            &nbsp;&nbsp;&nbsp;
                            <telerik:RadButton ID="retrievedCheckBox" runat="server" 
                                ToggleType="CheckBox" 
                                ButtonType="ToggleButton" 
                                ForeColor="Gray" 
                                Text="retrieved" 
                                Skin="Web20" >
                            </telerik:RadButton>
                            &nbsp;&nbsp;&nbsp;
                            <telerik:RadButton ID="successfulCheckBox" runat="server" 
                                ToggleType="CheckBox" 
                                ButtonType="ToggleButton" 
                                ForeColor="Gray" 
                                Text="successful" 
                                Skin="Web20" >
                            </telerik:RadButton>
                            &nbsp;&nbsp;&nbsp;
                            <telerik:RadButton ID="SentToLabsCheckBox" runat="server" 
                                ToggleType="CheckBox" 
                                ButtonType="ToggleButton" 
                                ForeColor="Gray" 
                                Text="sent to labs" 
                                Skin="Web20" >
                            </telerik:RadButton>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            removal
                            &nbsp;&nbsp;&nbsp;
                            by
                            &nbsp;&nbsp;&nbsp;
                            probably
                            &nbsp;&nbsp;&nbsp;
                            benign/malignant
                        </td>
                    </tr>
                    <tr>
                        <td>
                            tattooed
                            &nbsp;&nbsp;&nbsp;
                            Yes
                            &nbsp;&nbsp;&nbsp;
                            No
                            &nbsp;&nbsp;&nbsp;
                            Previously tattooed
                            &nbsp;&nbsp;&nbsp;
                            Using
                            &nbsp;&nbsp;&nbsp;
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>
        <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; padding-bottom: 10px; margin-bottom:10px;">
            <telerik:RadButton ID="SaveButton" runat="server" Text="Ok" Skin="Metro" Icon-PrimaryIconCssClass="telerikOkButton" OnClick="SaveButton_Click" />
            <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" Icon-PrimaryIconCssClass="telerikCancelButton" OnClientClicked="CloseWindow" />
        </div>
    </form>
</body>
</html>
