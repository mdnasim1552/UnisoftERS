<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_UserMaintenance" Codebehind="UserMaintenance.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {
            });

            function openAddTitleWindow() {
                //Get a reference to the window.
                var oWnd = $find("<%= AddNewTitleRadWindow.ClientID %>");

                ////Add the name of the function to be executed when RadWindow is closed.
                //oWnd.add_close(OnClientClose);

                oWnd.show();

                //window.radopen(null, "AddNewTitleRadWindow");

                return false;
            }

            function closeAddTitleWindow() {
                var oWnd = $find("<%= AddNewTitleRadWindow.ClientID %>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function ShowEditForm(id, sRoles, rowIndex) {
                var grid = $find("<%= UsersRadGrid.ClientID%>");

                var rowControl = grid.get_masterTableView().get_dataItems()[rowIndex].get_element();
                grid.get_masterTableView().selectItem(rowControl, true);

                window.radopen("EditUser.aspx?UserID=" + id + "&RoleID=" + sRoles, "UserListDialog", 800,600);
                return false;
            }
            function ShowInsertForm() {
                window.radopen("EditUser.aspx", "UserListDialog",800,600);
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
            function RowDblClick(sender, eventArgs) {
                window.radopen("EditForm_vbasic.aspx?EmployeeID=" + eventArgs.getDataKeyValue("EmployeeID"), "UserListDialog");
            }

            function Show() {
                if (confirm("Are you sure you want to suppress this user?")) {
                    return true;
                }
                else {
                    return false;
                }
            }
        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <%--<telerik:AjaxSetting AjaxControlID="UsersRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="UserDetailsFormView" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="UserDetailsFormView">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="UsersRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="UsersRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="UsersRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="FilterByComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="UsersRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">User Maintenance</div>

        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All"
            DecorationZoneID="FormDiv" Skin="Web20" />

        <asp:ObjectDataSource ID="UsersObjectDataSource" runat="server" SelectMethod="GetUsers" TypeName="UnisoftERS.Options">
            <SelectParameters>
                <asp:ControlParameter Name="SearchPhrase" DbType="String" ControlID="UserSearchTextBox" ConvertEmptyStringToNull="true" />
                <asp:ControlParameter Name="filterBy" DbType="String" ControlID="FilterByComboBox" ConvertEmptyStringToNull="true" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <div id="FormDiv" runat="server">
            <div style="margin-top: 15px; margin-left: 15px;" class="optionsBodyText">
               <%-- <asp:Panel ID="Panel1" runat="server" DefaultButton="UserSearchButton">
                    <table id="UserSearchTable" runat="server" cellspacing="0" cellpadding="0">
                        <tr>
                            <td style="padding-right: 5px;">Search by User ID / Name
                            </td>
                            <td style="padding-right: 5px;">
                                <telerik:RadTextBox ID="UserSearchTextBox" runat="server" Skin="Windows7" Width="200" /></td>
                            <td>
                                <telerik:RadButton ID="UserSearchButton" runat="server" Text="Search" Skin="Office2007" />
                            </td>
                        </tr>
                    </table>
                </asp:Panel>--%>

                <div style="margin-top: 15px;">
                    <%--<asp:HyperLink ID="AddNewLink" runat="server" Text="Add New User" onclick="return ShowInsertForm();"></asp:HyperLink>
                    <a href="#" onclick="return ShowInsertForm();">Add New User</a>--%>

                    <table>
                        <tr>
                            <td>
                                <%--<telerik:RadButton ID="AddNewUserButton" runat="server" Text="Add New User" Skin="Web20" 
                                    OnClientClicked="ShowInsertForm" AutoPostBack="false" />--%>
                                Search by User ID / Name :
                                <telerik:RadTextBox ID="UserSearchTextBox" runat="server" Skin="Windows7" Width="188" CssClass="filterTxt" />
                                <telerik:RadButton ID="UserSearchButton" runat="server" Text="Search" Skin="Office2007" CssClass="filterBtn" />
                                <span style="margin-left:20px;margin-right:20px;color:lightgray;  "></span>
                            </td>
                            <td align="right">
                                Filter by :
                                <telerik:RadComboBox ID="FilterByComboBox" runat="server" Skin="Windows7" Width="180px" AutoPostBack="true" CssClass="filterDDL">
                                    <Items>
                                        <telerik:RadComboBoxItem Text="All users" Value="" />
                                        <telerik:RadComboBoxItem Text="Hide suppressed users" Value="0" Selected="true"  />
                                        <telerik:RadComboBoxItem Text="Show suppressed users only" Value="1" />
                                    </Items>
                                </telerik:RadComboBox>
                               <span style="margin-left:20px;margin-right:20px;color:lightgray;  "></span>
                                Items per page:
                                <telerik:RadTextBox ID="ItemsTextBox" runat="server" Skin="Windows7" Width="30" MaxLength="2" CssClass="filterTxt" />
                                <telerik:RadButton ID="ItemsButton" runat="server" Text="Go" Skin="Office2007" CssClass="filterBtn" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <telerik:RadGrid ID="UsersRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                                    DataSourceID="UsersObjectDataSource" PageSize="10" AllowPaging="true" AllowSorting="true"  
                                    CellSpacing="0" GridLines="None" Skin="Metro" Width="900px">
                                    <HeaderStyle Font-Bold="true" Height="25" />
                                    <MasterTableView ShowHeadersWhenNoRecords="true" DataKeyNames="UserId, RoleID" ClientDataKeyNames="UserID, RoleID">

                                        <Columns>
                                            <%--<telerik:GridTemplateColumn ItemStyle-HorizontalAlign="Center" HeaderText="" HeaderStyle-Width="60px" HeaderStyle-Wrap="false">
                                                <ItemTemplate>
                                                    <asp:ImageButton ID="EditLinkButton" runat="server" ImageUrl="~/Images/edit_48.png" CommandName="Edit" ToolTip="Edit this user"
                                                        Width="16px" />&nbsp;&nbsp;
                                                    <asp:ImageButton ID="SuppressLinkButton" runat="server" ImageUrl="~/Images/suppress.png" CommandName="SuppressUser" ToolTip="Suppress this user"
                                                        OnClientClick="javascript:if(!confirm('Are you sure you want to suppress this user?')){return false;}" Width="16px" />
                                                </ItemTemplate>
                                            </telerik:GridTemplateColumn>--%>

                                            <telerik:GridTemplateColumn UniqueName="TemplateColumn" ItemStyle-Width="125">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit this user" Font-Italic="true"  ></asp:LinkButton>
                                                    &nbsp;&nbsp;
                                                    <asp:LinkButton ID="SuppressLinkButton" runat="server" Text="Suppress" ToolTip="Suppress this user" 
                                                        Enabled="true" OnClientClick="return Show()"
                                                        CommandName="SuppressUser" Font-Italic="true"></asp:LinkButton>
                                                </ItemTemplate>
                                                <HeaderTemplate>
                                                    <telerik:RadButton ID="AddNewUserButton" runat="server" Text="Add New User" Skin="Metro" OnClientClicked="ShowInsertForm" AutoPostBack="false" />
                                                </HeaderTemplate> 
                                            </telerik:GridTemplateColumn>
                                            <telerik:GridBoundColumn UniqueName="UserName"  DataField="UserName" HeaderText="User ID" SortExpression="UserName" HeaderStyle-Width="120px"></telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="Name" HeaderText="Name" SortExpression="Name" HeaderStyle-Width="200px"></telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="RoleName" HeaderText="User Role(s)" SortExpression="RoleName" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" >
                                                <FilterTemplate></FilterTemplate> 
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="LastLoggedIn" HeaderText="Last Logon" SortExpression="LastLoggedIn" HeaderStyle-Width="200px"></telerik:GridBoundColumn>
                                            <%--<telerik:GridBoundColumn DataField="Suppressed" HeaderText="Suppressed" SortExpression="Suppressed"></telerik:GridBoundColumn>--%>
                                        </Columns>
                                        <NoRecordsTemplate>
                                            <div style="margin-left: 5px;">No records found</div>
                                        </NoRecordsTemplate>
                                         
                                    </MasterTableView>
                                    <ItemStyle Height="30" />
                                    <AlternatingItemStyle Height="30" />
                                    <PagerStyle Mode="NumericPages">
                                    </PagerStyle>
                                </telerik:RadGrid>
                            </td>
                        </tr>
                    </table>
                </div>

                <telerik:RadWindowManager ID="RadWindowManager1" runat="server">
                    <Windows>
                        <telerik:RadWindow ID="UserListDialog" runat="server" Title="Editing record"
                            Width="800px" Height="700px" Left="150px" ReloadOnShow="true" ShowContentDuringLoad="false"
                            Modal="true" VisibleStatusbar="false" Skin="Metro">
                        </telerik:RadWindow>
                    </Windows>
                </telerik:RadWindowManager>
            </div>

            <telerik:RadWindowManager ID="AddNewTitleRadWindowManager" runat="server" ShowContentDuringLoad="false"
                Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
                <Windows>
                    <telerik:RadWindow ID="AddNewTitleRadWindow" runat="server" ReloadOnShow="true"
                        KeepInScreenBounds="true" Width="400px" Height="180px">
                        <ContentTemplate>
                            <table cellspacing="3" cellpadding="3">
                                <tr>
                                    <td>
                                        <b>Add new title</b>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <telerik:RadTextBox ID="AddNewTitleRadTextBox" runat="Server" Width="300px" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                            <telerik:RadButton ID="AddNewTitleSaveRadButton" runat="server" Text="Save" Skin="WebBlue" Icon-PrimaryIconCssClass="telerikOkButton"/>
                                            <telerik:RadButton ID="AddNewTitleCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" OnClientClicked="closeAddTitleWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
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
