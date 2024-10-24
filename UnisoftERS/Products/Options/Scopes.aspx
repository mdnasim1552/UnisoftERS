<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_Scopes" CodeBehind="Scopes.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add/Edit Scopes</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });
            $(document).ready(function () {
            });

            function editScope(ScopeID) {
                if (ScopeID > 0) {
                    radopen("EditScopes.aspx?ScopeId=" + ScopeID, "Edit Scope", 750, 550);
                    return false;
                }
            }

            function addScope() {
                radopen("EditScopes.aspx", "Add Scope", 750, 550);
                return false;
            }

            function Show() {
                if (confirm("Are you sure you want to suppress this scope?")) {
                    return true;
                }
                else {
                    return false;
                }
            }

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
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hiddenShowSuppressedItems" runat="server" Value="0" />
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ScopesRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="ScopesRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ScopesRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="HideSuppressButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="FormDiv" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SuppressedComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ScopesRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SearchButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ScopesRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Add/Edit Scopes"></asp:Label>
        </div>

        <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <asp:ObjectDataSource ID="ScopesObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetScopesLst">
            <SelectParameters>
                <asp:ControlParameter Name="FieldValue" ControlID="SearchTextBox" PropertyName="Text" DbType="String" />
                <asp:Parameter Name="Suppressed" DbType="Int32" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <div id="FormDiv" runat="server" style="margin-top: 10px;">
            <div id="searchBox" runat="server" class="optionsBodyText" style="margin-left: 10px; width: 556px">
                <asp:Panel ID="Panel1" runat="server" DefaultButton="SearchButton">
                    <table style="width: 100%;">
                        <tr>
                            <td style="padding-left: 10px;">Search:
                            </td>
                            <td>
                                <telerik:RadTextBox ID="SearchTextBox" runat="server" Width="150px" EmptyMessage="Enter search text" Skin="Metro" CssClass="filterTxt" />
                                <telerik:RadButton ID="SearchButton" runat="server" Text="Search" Font-Bold="true" Skin="Metro" CssClass="filterBtn" />
                            </td>
                            <td style="padding-left: 60px;">
                                Show:
                                <telerik:RadComboBox ID="SuppressedComboBox" runat="server" Skin="Metro" AutoPostBack="true" OnSelectedIndexChanged="HideSuppressButton_Click" CssClass="filterDDL">
                                    <Items>
                                        <telerik:RadComboBoxItem Text="All Scopes" Value="0" Selected="true" />
                                        <telerik:RadComboBoxItem Text="Suppressed Scopes" Value="1" />
                                        <telerik:RadComboBoxItem Text="Unsuppressed Scopes" Value="2" />
                                    </Items>
                                </telerik:RadComboBox>
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </div>

            <div style="margin-left: 10px; margin-top: 20px;" class="rptText">
                <telerik:RadGrid ID="ScopesRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                    Skin="Metro" PageSize="20" AllowPaging="true" Style="margin-bottom: 10px; width: 95%; height: 550px;" DataSourceID="ScopesObjectDataSource">
                    <HeaderStyle Font-Bold="true" />
                    <GroupingSettings CaseSensitive="false"></GroupingSettings>
                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="ScopeId,Suppressed" DataKeyNames="ScopeId,Suppressed" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass"
                        AllowFilteringByColumn="true">
                        <Columns>
                            <telerik:GridTemplateColumn ItemStyle-VerticalAlign="Top" UniqueName="TemplateColumn" HeaderStyle-Width="150px" AllowFiltering="false">
                                <ItemTemplate>
                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit Scope" Font-Italic="true"></asp:LinkButton>
                                    &nbsp;&nbsp;
                                    <asp:LinkButton ID="SuppressLinkButton" runat="server" Text="Suppress" ToolTip="Suppress Scope"
                                        Enabled="true" OnClientClick="return Show()"
                                        CommandName="SuppressScope" Font-Italic="true"></asp:LinkButton>
                                </ItemTemplate>
                                <HeaderTemplate>
                                    <telerik:RadButton ID="AddNewScopeButton" runat="server" Text="Add New Scope" Skin="Metro" OnClientClicked="addScope" AutoPostBack="false" />
                                </HeaderTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="ScopeName" HeaderText="Scope name" SortExpression="ScopeName" HeaderStyle-Width="160px" ItemStyle-VerticalAlign="Top" AllowSorting="true" ShowSortIcon="true" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" />
                            <telerik:GridBoundColumn DataField="Manufacturer" HeaderText="Manfacturer" SortExpression="Manfacturer" HeaderStyle-Width="160px" ItemStyle-VerticalAlign="Top" AllowSorting="true" ShowSortIcon="true" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" />
                            <telerik:GridBoundColumn DataField="Generation" HeaderText="Generation" SortExpression="Generation" HeaderStyle-Width="160px" ItemStyle-VerticalAlign="Top" AllowSorting="true" ShowSortIcon="true" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" />
                            <telerik:GridBoundColumn DataField="Procedures" HeaderText="Procedures" SortExpression="Procedures" HeaderStyle-Width="130px" ItemStyle-VerticalAlign="Top" ItemStyle-Wrap="true" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" />
                            <telerik:GridBoundColumn DataField="HospitalName" HeaderText="Associated Hospitals" SortExpression="HospitalName" HeaderStyle-Width="150px" ItemStyle-VerticalAlign="Top" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" />
                            <telerik:GridBoundColumn DataField="Suppressed" HeaderText="Suppressed" SortExpression="Suppressed" HeaderStyle-Width="100px" ItemStyle-VerticalAlign="Top" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" AllowFiltering="false" />
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No scope found.
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                    <PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Scopes {2} to {3} of {5}" AlwaysVisible="true" />
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
