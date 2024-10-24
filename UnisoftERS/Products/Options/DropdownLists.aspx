<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_ListItem" CodeBehind="DropdownLists.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .suppressChkBox {
            float: right;
            direction: rtl;
        }
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {
            });

            function openAddItemWindow(itemId, itemName) {
                var oWnd = $find("<%= AddNewItemRadWindow.ClientID%>");
                if (itemId > 0) {
                    document.getElementById("tdItemTitle").innerHTML = '<b>Edit item "' + itemName + '"</b>';
                    $find('<% =AddNewItemSaveRadButton.ClientID%>').set_text("Update");
                    oWnd.set_title('Edit Item');
                    $find("<%=AddNewItemRadTextBox.ClientID%>").set_value(itemName);
                    $("#<%=hiddenItemId.ClientID%>").val(itemId);
                } else {
                    document.getElementById("tdItemTitle").innerHTML = '<b>Add new item</b>';
                    $find('<% =AddNewItemSaveRadButton.ClientID%>').set_text("Save");
                    oWnd.set_title('New Item');
                    $find("<%=AddNewItemRadTextBox.ClientID%>").set_value("");
                }
                oWnd.show();
                return false;
            }

            function closeAddItemWindow() {
                var oWnd = $find("<%= AddNewItemRadWindow.ClientID%>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function refreshGrid(arg) {
                if (!arg) {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind");
                }
                else {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindAndNavigate");
                }
            }

            function Show() {
                if (confirm("Are you sure you want to suppress this item?")) {
                    return true;
                }
                else {
                    return false;
                }
            }

            function showSuppressedItems(sender, args) {
                document.getElementById('hiddenShowSuppressedItems').value = args.get_checked();
                var masterTable = $find("<%= ListsRadGrid.ClientID%>").get_masterTableView();
                masterTable.rebind();
            }
        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <script type="text/javascript">
</script>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hiddenItemId" runat="server" />
        <asp:HiddenField ID="hiddenShowSuppressedItems" runat="server" Value="0" />
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ListsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="ListsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ListsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="FilterByComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ListsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                 <telerik:AjaxSetting AjaxControlID="SuppressedComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ListsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">List Maintenance</div>

        <telerik:RadFormDecorator ID="ListItemRadFormDecorator" runat="server" DecoratedControls="All"
            DecorationZoneID="FormDiv" Skin="Web20" />

        <asp:ObjectDataSource ID="UsersObjectDataSource" runat="server" SelectMethod="GetListMaintenance" TypeName="UnisoftERS.Options">
            <SelectParameters>
                <asp:ControlParameter Name="listDescription" DbType="String" ControlID="FilterByComboBox" ConvertEmptyStringToNull="true" />
                <asp:Parameter Name="showSuppressed" DbType="string" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <div id="FormDiv" runat="server">
            <div style="margin-top: 5px; margin-left: 10px;" class="optionsBodyText">
                <div style="margin-top: 15px;">
                    <table>
                        <tr>
                            <td>Select list :
                                <telerik:RadComboBox ID="FilterByComboBox" runat="server" Skin="Windows7" Width="270px" AutoPostBack="true" MaxHeight="460px" CssClass="filterDDL" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div style="padding-top: 10px; padding-left: 12px;">
                                    Show:
                                    <telerik:RadComboBox ID="SuppressedComboBox" runat="server" Skin="Windows7" AutoPostBack="true" OnSelectedIndexChanged="HideSuppressButton_Click" CssClass="filterDDL">
                                        <Items>
                                            <telerik:RadComboBoxItem Text="All Items" Value="0" Selected="true" />
                                            <telerik:RadComboBoxItem Text="Suppressed items" Value="1" />
                                            <telerik:RadComboBoxItem Text="Unsuppressed items" Value="2" />
                                        </Items>
                                    </telerik:RadComboBox>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-top: 20px;">
                                <div class="optionsSubHeading" style="padding-bottom: 5px;">Items</div>
                                <telerik:RadGrid ID="ListsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                                    DataSourceID="UsersObjectDataSource" PageSize="10" AllowPaging="true" AllowSorting="true"
                                    CellSpacing="0" GridLines="None" Skin="Metro" Width="700px">
                                    <HeaderStyle Font-Bold="true" Height="25" />
                                    <MasterTableView ShowHeadersWhenNoRecords="true" DataKeyNames="ListId" ClientDataKeyNames="ListId">

                                        <Columns>
                                            <telerik:GridTemplateColumn UniqueName="TemplateColumn">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit this item" Font-Italic="true"></asp:LinkButton>
                                                    &nbsp;&nbsp;
                                                    <asp:LinkButton ID="SuppressLinkButton" runat="server" Text="Suppress" ToolTip="Suppress this item"
                                                        Enabled="true" OnClientClick="return Show()"
                                                        CommandName="SuppressItem" Font-Italic="true"></asp:LinkButton>
                                                </ItemTemplate>
                                                <HeaderTemplate>
                                                    <telerik:RadButton ID="AddNewItemButton" runat="server" Text="Add new item" Skin="Windows7" OnClientClicked="openAddItemWindow" AutoPostBack="false" />
                                                </HeaderTemplate>
                                            </telerik:GridTemplateColumn>
                                            <telerik:GridBoundColumn DataField="ListItemText" UniqueName="ListItemText" HeaderText="Item Name" SortExpression="ListItemText" HeaderStyle-Width="570px">
                                            </telerik:GridBoundColumn>
                                        </Columns>
                                        <NoRecordsTemplate>
                                            <div style="margin-left: 5px;">No records found</div>
                                        </NoRecordsTemplate>

                                    </MasterTableView>
                                    <ItemStyle Height="30" />
                                    <AlternatingItemStyle Height="30" />
                                    <PagerStyle Mode="NumericPages"></PagerStyle>
                                </telerik:RadGrid>
                            </td>
                        </tr>
                    </table>
                </div>

                <telerik:RadWindowManager ID="RadWindowManager1" runat="server">
                    <Windows>
                        <telerik:RadWindow ID="ItemListDialog" runat="server" Title="Editing record"
                            Width="800px" Height="500px" Left="150px" ReloadOnShow="true" ShowContentDuringLoad="false"
                            Modal="true" VisibleStatusbar="false" Skin="Metro">
                        </telerik:RadWindow>
                    </Windows>
                </telerik:RadWindowManager>
            </div>

            <telerik:RadWindowManager ID="AddNewItemRadWindowManager" runat="server" ShowContentDuringLoad="false"
                Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
                <Windows>
                    <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" Title="New Item"
                        KeepInScreenBounds="true" Width="400px" Height="180px">
                        <ContentTemplate>
                            <table cellspacing="3" cellpadding="3">
                                <tr>
                                    <td id="tdItemTitle">
                                        <b>Add new item</b>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <telerik:RadTextBox ID="AddNewItemRadTextBox" runat="Server" Width="300px" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                            <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Save" Skin="Web20" />
                                            <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="closeAddItemWindow" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </telerik:RadWindow>
                </Windows>
            </telerik:RadWindowManager>
        </div>
    </form>
</body>
</html>
