<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_RoleMaintenance" Codebehind="Roles.aspx.vb" %>

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

            function openAddRoleWindow(roleId, roleName) {
                //Get a reference to the window.

                var oWnd = $find("<%= AddNewRoleRadWindow.ClientID%>");
                //alert(roleId + '--' + roleName);
                if (roleId > 0) {
                    document.getElementById("tdRoleTitle").innerHTML = '<b>Edit role "' + roleName + '"</b>';
                    $find('<% =AddNewRoleSaveRadButton.ClientID%>').set_text("Update");
                    oWnd.set_title('Edit Role');
                    $find("<%=AddNewRoleRadTextBox.ClientID%>").set_value(roleName);
                    $("#hiddenRoleId").val(roleId);

                } else {
                    document.getElementById("tdRoleTitle").innerHTML = '<b>Add new role</b>';
                    $find('<% =AddNewRoleSaveRadButton.ClientID%>').set_text("Save");
                    oWnd.set_title('New Role');
                    $find("<%=AddNewRoleRadTextBox.ClientID%>").set_value("");
                }

                oWnd.show();
                return false;
            }

            function closeAddRoleWindow() {
                var oWnd = $find("<%= AddNewRoleRadWindow.ClientID%>");
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

        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hiddenRoleId" runat="server" />
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RolesRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="RolesRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RolesRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">Role Maintenance</div>

        <telerik:RadFormDecorator ID="RoleMaintenanceRadFormDecorator" runat="server" DecoratedControls="All"
            DecorationZoneID="FormDiv" Skin="Web20" />

        <asp:ObjectDataSource ID="RolesObjectDataSource" runat="server"
            TypeName="UnisoftERS.DataAccess" SelectMethod="GetRoles" UpdateMethod="UpdateRoles">
            <SelectParameters>
                <asp:Parameter Name="IncludeNotEditable" DbType="Boolean" DefaultValue="True" />
            </SelectParameters>
            <UpdateParameters>
                <asp:Parameter Name="RoleId" DbType="Int32" />
                <asp:Parameter Name="RoleName" DbType="Boolean" />
            </UpdateParameters>
        </asp:ObjectDataSource>

        <div id="FormDiv" runat="server">
            <div style="margin-top: 5px; margin-left: 10px;" class="optionsBodyText">

                <div style="margin-top: 15px;">
                    <table>
                        <tr>
                            <td>
                                <%-- <telerik:RadButton ID="AddNewRoleButton" runat="server" Text="Add New Role" Skin="Windows7" 
                                    OnClientClicked="openAddRoleWindow" AutoPostBack="false" /> --%>
                            </td>
                        </tr>
                        <tr>
                            <td valign="top"  >
                                <telerik:RadGrid ID="RolesRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                                    DataSourceID="RolesObjectDataSource" PageSize="10" AllowPaging="true" AllowSorting="true" 
                                    CellSpacing="0" GridLines="None"  Skin="Metro" Width="400px">
                                    <HeaderStyle Font-Bold="true" Height="12px" />
                                    <MasterTableView ShowHeadersWhenNoRecords="true" DataKeyNames="RoleId" ClientDataKeyNames="RoleID" >
<%--                                        <EditFormSettings>
                                          <EditColumn UniqueName="EditCommandColumn" ButtonType="PushButton" >
                                          </EditColumn>
                                        </EditFormSettings>--%>
                                        <Columns>
                                            <telerik:GridTemplateColumn UniqueName="TemplateColumn" ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center" >
                                                <%--<ItemTemplate>
                                                    <asp:ImageButton ID="EditLinkButton" runat="server" ImageUrl="~/Images/edit_48.png" CommandName="Edit" ToolTip="Edit Role"
                                                        Width="16px"   />&nbsp;&nbsp;
                                                    <asp:ImageButton ID="DeleteLinkButton" runat="server" ImageUrl="~/Images/delete.png" CommandName="Delete" ToolTip="Delete Role"
                                                        OnClientClick="javascript:if(!confirm('Are you sure you want to delete this role?')){return false;}" Width="16px" />
                                                </ItemTemplate>--%>

                                                <ItemTemplate>
                                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit Role" Font-Italic="true" CommandName="Edit"  ></asp:LinkButton>
                                                    &nbsp;&nbsp;
                                                    <asp:LinkButton ID="DeleteLinkButton" runat="server" Text="Delete" ToolTip="Suppress this item"  CommandName="Delete"
                                                        Enabled="true" OnClientClick="javascript:if(!confirm('Are you sure you want to delete this role?')){return false;}"
                                                        Font-Italic="true"></asp:LinkButton>
                                                </ItemTemplate>
                                                <ItemStyle HorizontalAlign="Left" /> 
                                                <HeaderTemplate>
                                                    <telerik:RadButton ID="AddNewRoleButton" runat="server" Text="Add New Role" Skin="Metro" OnClientClicked="openAddRoleWindow" AutoPostBack="false" />
                                                </HeaderTemplate>
                                            </telerik:GridTemplateColumn>
                                            <telerik:GridBoundColumn DataField="RoleName" HeaderText="Role Name" SortExpression="RoleName" HeaderStyle-Width="350px"></telerik:GridBoundColumn>
                                        </Columns>
                                        <NoRecordsTemplate>
                                            <div style="margin-left: 5px;">No records found</div>
                                        </NoRecordsTemplate>
                                    </MasterTableView>
                                    <ItemStyle Height="30" />
                                    <AlternatingItemStyle Height="30" />
                                    <PagerStyle Mode="NumericPages"></PagerStyle>
                                    <ClientSettings>
                                        <Selecting AllowRowSelect="True" />
                                    </ClientSettings>
                                    <SelectedItemStyle BackColor="Fuchsia" BorderColor="Purple" BorderStyle="Dashed" BorderWidth="1px" />
                                </telerik:RadGrid>
                            </td>

                        </tr>
                    </table>
                </div>

                <telerik:RadWindowManager ID="RadWindowManager1" runat="server">
                    <Windows>
                        <telerik:RadWindow ID="RoleListDialog" runat="server" Title="Editing record"
                            Width="800px" Height="500px" Left="150px" ReloadOnShow="true" ShowContentDuringLoad="false"
                            Modal="true" VisibleStatusbar="false" Skin="Metro">
                        </telerik:RadWindow>
                    </Windows>
                </telerik:RadWindowManager>
            </div>

            <telerik:RadWindowManager ID="AddNewRoleRadWindowManager" runat="server" ShowContentDuringLoad="false" 
                Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
                <Windows>
                    <telerik:RadWindow ID="AddNewRoleRadWindow" runat="server" ReloadOnShow="true" Title ="New Role" 
                        KeepInScreenBounds="true" Width="400px" Height="180px">
                        <ContentTemplate>
                            <table cellspacing="3" cellpadding="3">
                                <tr>
                                    <td id="tdRoleTitle">
                                        <b>Add new role</b>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <telerik:RadTextBox ID="AddNewRoleRadTextBox" runat="Server" Width="300px" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                            <telerik:RadButton ID="AddNewRoleSaveRadButton" runat="server" Text="Save" Skin="Web20"  />
                                            <telerik:RadButton ID="AddNewRoleCancelRadButton" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="closeAddRoleWindow" />
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
