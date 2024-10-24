<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_Scheduler_Rooms" CodeBehind="Rooms.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add/Edit Rooms</title>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });
            $(document).ready(function () {
            });

            function editRoom(RoomID) {
                if (RoomID > 0) {
                    var oWnd = radopen("EditRooms.aspx?RoomId=" + RoomID, "Edit Room", 670, 548);
                    oWnd.set_visibleStatusbar(false);
                    return false;
                }
            }

            function addRoom() {
                var oWnd = radopen("EditRooms.aspx", "Add Room", 737, 548);
                oWnd.set_visibleStatusbar(false);
                return false;
            }

            function Show() {
                if (confirm("Are you sure you want to suppress this room?")) {
                    return true;
                }
                else {
                    return false;
                }
            }

           <%-- function refreshGrid(arg) {
                if (!arg) {
                    var masterTable = $find("<%= RoomsRadGrid.ClientID %>").get_masterTableView();
                    masterTable.fireCommand("Rebind", arg);
                }
                else {
                    var masterTable = $find("<%= RoomsRadGrid.ClientID %>").get_masterTableView();
                    masterTable.fireCommand("RebindAndNavigate", arg);
                }
            }--%>

             function refreshGrid(arg) {
                if (!arg) {
                    window.location.reload();
                }
                else {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindAndNavigate");
                }
            }

        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <form id="form1" runat="server">
                <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <asp:HiddenField ID="hiddenShowSuppressedItems" runat="server" Value="0" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

         <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadWindowManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RoomsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="RoomsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RoomsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="HideSuppressButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="FormDiv" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SuppressedComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RoomsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SearchButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RoomsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="OperatingHospitalsRadComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RoomsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Add/Edit Endoscopy Rooms"></asp:Label>
        </div>

        <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <asp:ObjectDataSource ID="RoomsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetRoomsLst">
            <SelectParameters>
                <asp:ControlParameter Name="OperatingHospitalId" ControlID="OperatingHospitalsRadComboBox" PropertyName="SelectedValue" DbType="Int32" />
                <asp:ControlParameter Name="Field" ControlID="SearchComboBox" PropertyName="SelectedValue" DbType="String" />
                <asp:ControlParameter Name="FieldValue" ControlID="SearchTextBox" PropertyName="Text" DbType="String" />
                <asp:Parameter Name="Suppressed" DbType="Int32" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <div id="FormDiv" runat="server" style="margin-top: 10px;">
            <div id="HospitalFilterDiv" runat="server" class="optionsBodyText" style="margin: 10px;">
                Operating Hospital:&nbsp;<telerik:RadComboBox ID="OperatingHospitalsRadComboBox" CssClass="filterDDL" runat="server" Width="270px" AutoPostBack="true" OnSelectedIndexChanged="OperatingHospitalsRadComboBox_SelectedIndexChanged" />
            </div>

            <div id="searchBox" runat="server" class="optionsBodyText" style="margin-left: 10px; width: 556px">
                <asp:Panel ID="Panel1" runat="server" DefaultButton="SearchButton">
                    <table style="width: 100%;">
                        <tr>
                            <td style="padding-top: 10px; padding-left: 10px; width: 15%;">Search by:
                            </td>
                            <td style="padding-top: 10px; padding-left: 1px; width: 35%;">
                                <telerik:RadComboBox ID="SearchComboBox" runat="server" Skin="Metro" AutoPostBack="false"
                                    Font-Bold="False" Width="100%" CssClass="filterDDL">
                                    <Items>
                                        <telerik:RadComboBoxItem Text="All Rooms" Value="" Selected="true" />
                                    </Items>
                                </telerik:RadComboBox>
                            </td>
                            <td style="padding: 10px 10px 0px 10px;">
                                <telerik:RadTextBox ID="SearchTextBox" runat="server" Width="100%" EmptyMessage="Enter search text" Skin="Metro" CssClass="filterTxt" />
                            </td>
                            <td style="padding: 10px 10px 0px 10px;">
                                <telerik:RadButton ID="SearchButton" runat="server" Text="Search" Font-Bold="true" Skin="Metro" CssClass="filterBtn" />
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
                <div style="padding-top: 10px; padding-left: 12px;">
                    Show:
                    <telerik:RadComboBox ID="SuppressedComboBox" runat="server" Skin="Metro" AutoPostBack="true" OnSelectedIndexChanged="HideSuppressButton_Click" CssClass="filterDDL">
                        <Items>
                            <telerik:RadComboBoxItem Text="All Rooms" Value="0" Selected="true" />
                            <telerik:RadComboBoxItem Text="Suppressed Rooms" Value="1" />
                            <telerik:RadComboBoxItem Text="Unsuppressed Rooms" Value="2" />
                        </Items>
                    </telerik:RadComboBox>
                </div>
            </div>

            <div style="margin-left: 10px; margin-top: 20px;" class="rptText">
                <telerik:RadGrid ID="RoomsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                    DataSourceID="RoomsObjectDataSource" Skin="Metro" Style="margin-bottom: 10px; width: 95%; height: 490px;">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="RoomId,Suppressed" DataKeyNames="RoomId,Suppressed" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass" AllowPaging="false">
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="75px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit Room" Font-Italic="true"></asp:LinkButton>
                                    &nbsp;&nbsp;
                                    <asp:LinkButton ID="SuppressLinkButton" runat="server" Text="Suppress" ToolTip="Suppress Room"
                                        Enabled="true" OnClientClick="return Show()"
                                        CommandName="SuppressRoom" Font-Italic="true"></asp:LinkButton>
                                </ItemTemplate>
                                <HeaderTemplate>
                                    <telerik:RadButton ID="AddNewRoomButton" runat="server" Text="Add New Room" Skin="Metro" OnClientClicked="addRoom" AutoPostBack="false" />
                                </HeaderTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="RoomSortOrder" HeaderText="Room sort order" SortExpression="RoomSortOrder" HeaderStyle-Width="40px" AllowSorting="true" ShowSortIcon="true" />
                            <telerik:GridBoundColumn DataField="RoomName" HeaderText="Room name" SortExpression="RoomName" HeaderStyle-Width="160px" AllowSorting="true" ShowSortIcon="true" />
                            <telerik:GridBoundColumn DataField="Procedures" HeaderText="Procedures" SortExpression="Procedures" HeaderStyle-Width="130px" ItemStyle-Wrap="true" />
                            <telerik:GridBoundColumn DataField="HospitalName" HeaderText="Hospital" SortExpression="HospitalName" HeaderStyle-Width="150px" />
                            <telerik:GridBoundColumn DataField="Suppressed" HeaderText="Suppressed" SortExpression="Suppressed" HeaderStyle-Width="50px" />
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No rooms found.
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                    <PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Rooms {2} to {3} of {5}" AlwaysVisible="true" />
                    <ClientSettings>
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                    </ClientSettings>
                </telerik:RadGrid>
            </div>
            <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Skin="Metro" Modal="true" VisibleStatusbar="false">
                <Windows>
                </Windows>
            </telerik:RadWindowManager>
        </div>

    </form>
</body>
</html>
