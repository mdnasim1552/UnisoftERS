<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="BiopsySites.aspx.vb" Inherits="UnisoftERS.BiopsySites" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../Styles/Site.css" rel="stylesheet" />
    <script src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../../Scripts/global.js"></script>
    <script type="text/javascript">
        function CloseAndRebind() {
            GetRadWindow().close();
        }

        function GetRadWindow() {
            var oWindow = null;
            if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
            else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

            return oWindow;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadFormDecorator ID="SIRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" />
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">


                <div id="FormDiv" style="padding: 20px; width: 600px; min-height: 210px; font-size: 12px; font-family: Segoe UI,Arial,Helvetica,sans-serif">
                    <div id="newBiopsySiteDiv">
                        <span style="font-weight: bold;">Add new</span>
                        <table>
                            <tr>
                                <td>Site:
                                    <asp:RequiredFieldValidator ID="BiopsySiteRequiredFieldValidator" runat="server" ControlToValidate="BiopsySiteRadComboBox" ErrorMessage="*" ForeColor="Red" ValidationGroup="newbiopsysite" />
                                    <telerik:RadComboBox ID="BiopsySiteRadComboBox" runat="server" Skin="Metro" Width="160" MarkFirstMatch="true" DataSourceID="BiopsySitesObjectDataSource" DataTextField="Description" DataValueField="UniqueId" Filter="Contains" AppendDataBoundItems="true">
                                        <Items>
                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                        </Items>
                                    </telerik:RadComboBox>


                                </td>
                                <td><span>Distance:</span><asp:RequiredFieldValidator ID="BiopsyDistanceRequiredFieldValidator" runat="server" ControlToValidate="DistanceNumericTextBox" ErrorMessage="*" ForeColor="Red" ValidationGroup="newbiopsysite" />
                                    <telerik:RadNumericTextBox ID="DistanceNumericTextBox" runat="server" Skin="Metro"
                                        IncrementSettings-InterceptMouseWheel="false"
                                        IncrementSettings-Step="1"
                                        Width="35px"
                                        MinValue="0">
                                        <NumberFormat DecimalDigits="0" />
                                    </telerik:RadNumericTextBox>cm
                                    

                                </td>
                                <td>No Bx:<asp:RequiredFieldValidator ID="BiopsyQtyRequiredFieldValidator" runat="server" ControlToValidate="QtyRadNumericTextBox" ErrorMessage="*" ForeColor="Red" ValidationGroup="newbiopsysite" />
                        <telerik:RadNumericTextBox ID="QtyRadNumericTextBox" runat="server" Skin="Metro"
                            IncrementSettings-InterceptMouseWheel="false"
                            IncrementSettings-Step="1"
                            Width="35px"
                            MinValue="1">
                            <NumberFormat DecimalDigits="0" />
                        </telerik:RadNumericTextBox>
                                    
                                </td>
                                <td>
                                    <telerik:RadButton ID="AddBiopsySiteRadButton" runat="server" Text="Add" Skin="Metro" OnClick="AddBiopsySiteRadButton_Click" ValidationGroup="newbiopsysite" CausesValidation="true" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="biopsySites" style="margin-top: 20px;">
                        <asp:Repeater ID="BiospySiteDetailsRepeater" runat="server" OnItemDataBound="BiospySiteDetailsRepeater_ItemDataBound" OnItemCommand="BiospySiteDetailsRepeater_ItemCommand">
                            <HeaderTemplate>
                                <table>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td>Site:                       
                        <telerik:RadComboBox ID="BiopsySiteRadComboBox" runat="server" Skin="Metro" Width="160" MarkFirstMatch="true" DataSourceID="BiopsySitesObjectDataSource" DataTextField="Description" DataValueField="UniqueId" />
                                    </td>
                                    <td>Distance:
                        <telerik:RadNumericTextBox ID="DistanceNumericTextBox" runat="server" Skin="Metro"
                            IncrementSettings-InterceptMouseWheel="false"
                            IncrementSettings-Step="1"
                            Width="35px"
                            MinValue="0">
                            <NumberFormat DecimalDigits="0" />
                        </telerik:RadNumericTextBox>cm
                                    </td>
                                    <td>No Bx:
                        <telerik:RadNumericTextBox ID="QtyRadNumericTextBox" runat="server" Skin="Metro"
                            IncrementSettings-InterceptMouseWheel="false"
                            IncrementSettings-Step="1"
                            Width="35px"
                            MinValue="1">
                            <NumberFormat DecimalDigits="0" />
                        </telerik:RadNumericTextBox>
                                    </td>
                                    <td>
                                        <asp:LinkButton ID="lnkUpdateBiopsySite" runat="server" Text="Update" CommandName="updateBiopsy" CommandArgument='<%#Eval("SiteSpecimenId") %>' />|
                                <asp:LinkButton ID="lnkDeleteBiopsySite" runat="server" Text="Delete" CommandName="deleteBiopsy" CommandArgument='<%#Eval("SiteSpecimenId") %>' OnClientClick="return javascript:confirm('are you sure you want to delete this entry?');" />
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                </div>


            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; padding-bottom: 10px; margin-bottom: 10px;">
                    <telerik:RadButton ID="bntClose" runat="server" Text="Save and Close" OnClientClicked="CloseAndRebind" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        <asp:ObjectDataSource ID="BiopsySitesObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="LoadBiopsySites"></asp:ObjectDataSource>
    </form>
</body>
</html>
