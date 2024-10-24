<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="StentInsertionDetails.aspx.vb" Inherits="UnisoftERS.StentInsertionDetails" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Stent Insertion Details</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" Visible="False" />
    <link href="../../../Styles/Site.css" rel="stylesheet" />
    <script src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../../Scripts/global.js"></script>

</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="SIRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="SIRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">


                <div id="FormDiv" style="padding: 20px; width: 600px; min-height: 210px; font-size: 12px; font-family: Segoe UI,Arial,Helvetica,sans-serif">
                    <asp:Repeater ID="StentTypesRepeater" runat="server" OnItemDataBound="StentTypesRepeater_ItemDataBound">
                        <HeaderTemplate>
                            <table cellpadding="5" cellspacing="0" class="rgview">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td style="padding-top: 15px;">
                                    <span>Insertion <%# Container.ItemIndex + 1 %>:</span>&nbsp;
                                    type
                                    <telerik:RadComboBox ID="StentInsertionTypeComboBox" runat="server" Skin="Metro" Width="100" MarkFirstMatch="true" />

                                    &nbsp;&nbsp;&nbsp;length
                                    <telerik:RadNumericTextBox ID="StentInsertionLengthNumericTextBox" runat="server" Skin="Metro"
                                        IncrementSettings-InterceptMouseWheel="false"
                                        IncrementSettings-Step="1"
                                        Width="35px"
                                        MinValue="0">
                                        <NumberFormat DecimalDigits="0" />
                                    </telerik:RadNumericTextBox>
                                    cm

                                    &nbsp;&nbsp;&nbsp;dia.
                                    <telerik:RadNumericTextBox ID="StentInsertionDiaNumericTextBox" runat="server" Skin="Metro"
                                        IncrementSettings-InterceptMouseWheel="false"
                                        IncrementSettings-Step="1"
                                        Width="35px"
                                        MinValue="0">
                                        <NumberFormat DecimalDigits="0" />
                                    </telerik:RadNumericTextBox>
                                    <telerik:RadComboBox ID="StentInsertionDiaUnitsComboBox" runat="server" Skin="Metro" Width="50px" MarkFirstMatch="true" />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; padding-bottom: 10px; margin-bottom: 10px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Ok" Skin="Metro" Icon-PrimaryIconCssClass="telerikOkButton" OnClick="SaveButton_Click" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" Icon-PrimaryIconCssClass="telerikCancelButton" OnClientClicked="CloseWindow" />

                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        <telerik:RadWindowManager ID="RadWindowManager2" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move" ReloadOnShow="True">
            <Windows>
                <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new entry"
                    KeepInScreenBounds="true" Width="400px" Height="150px" OnClientClose="AddNewItemWindowClientClose">
                    <ContentTemplate>
                        <table cellspacing="3" cellpadding="3" style="width: 100%">
                            <tr>
                                <td>
                                    <br />
                                    <div class="left">
                                        <telerik:RadTextBox ID="AddNewItemRadTextBox" runat="Server" Width="250px" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="buttonsdiv" style="height: 10px; padding-top: 16px;">
                                        <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Add" Skin="WebBlue" AutoPostBack="false" OnClientClicked="AddNewItem" ButtonType="SkinnedButton" />
                                        &nbsp;&nbsp;
                                        <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="CancelAddNewItem" ButtonType="SkinnedButton" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
        <script type="text/javascript">

            var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
            var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";
        </script>

    </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>
