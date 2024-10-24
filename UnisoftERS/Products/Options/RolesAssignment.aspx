<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_RolesAssignment" CodeBehind="RolesAssignment.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .node-full-access {
            color: green;
            font-weight: bold;
        }

        .node-read-only {
            color: orange;
            font-weight: bold;
        }

        .node-no-access {
            color: red;
            font-weight: bold;
        }
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {
            });


            function CheckForValidPage() {
                var valid = Page_ClientValidate("PagesByRole");
            }

            function ConfirmAccessLevelChange(sender, args) {
                var accessLevel = args.get_item().get_text();
                if (accessLevel != "") {
                    if (!confirm('This will change the access level of EVERY page displayed in the list to ' + accessLevel + '. Continue?')) {
                        args.set_cancel(true);
                    }
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
        <telerik:RadNotification ID="PagesByRoleNotification" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RolesComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RolesComboBox"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="GroupDropDownList"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="PageGroupSectionsTreeView" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="hiddenRoleId"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="GroupDropDownList">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GroupDropDownList"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="PageGroupSectionsTreeView" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="hiddenRoleId"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="MainContextMenu">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PageGroupSectionsTreeView" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="AccessLevelCombobx">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PageGroupSectionsTreeView" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">Roles Assignment</div>

        <telerik:RadFormDecorator ID="RoleMaintenanceRadFormDecorator" runat="server" DecoratedControls="All"
            DecorationZoneID="FormDiv" Skin="Web20" />

        <div id="FormDiv" runat="server">
            <div style="margin-top: 5px; margin-left: 10px;" class="optionsBodyText">

                <div style="margin-top: 15px;">
                    <table>
                        <tr>
                            <td style="width: 80px;">Select group:
                            </td>
                            <td>
                                <telerik:RadComboBox ID="RolesComboBox" runat="server" Skin="Windows7" Width="200" AutoPostBack="true">
                                    <Items>
                                        <telerik:RadComboBoxItem Text="Select..." Selected="true" />
                                    </Items>
                                </telerik:RadComboBox>
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                        </tr>
                        <tr style="padding-top: 10px">
                            <td style="width:150px;">
                                <div class="optionsSubHeading">Pages</div>
                            </td>
                            <td style="text-align:right; ">

                                   <%-- <div style="text-align:right;  background-color:greenyellow;">
                                        <div class="bigModule">
                                            <div class="bigModuleBottom">--%>
                                                <ul style="margin-top: 0; list-style: none">
                                                    <li style="float: left; margin-right: 30px;"><span style="width: 8px; height:8px; margin-top:4px; margin-right: 5px; background-color: green; display: block; border: solid 1px #5c5c5c; float: left">&nbsp;</span>
                                                        Full Access
                                                    </li>
                                                    <li style="float: left; margin-right: 30px;"><span style="width: 8px; height:8px; margin-top:4px; margin-right: 5px; background-color: orange; display: block; border: solid 1px #5c5c5c; float: left">&nbsp;</span>
                                                        Read Only
                                                    </li>
                                                    <li style="float: left; margin-right: 30px;"><span style="width: 8px; height:8px; margin-top:4px; background-color: red; display: block; margin-right: 5px; border: solid 1px #5c5c5c; float: left">&nbsp;</span> No Access
                                                    </li>
                                                </ul>
                                           <%-- </div>
                                        </div>
                                    </div>--%>


                            </td>
                        </tr>
                        <tr>
                            <td valign="top" colspan="2"> <div style="height: 30px; width: 500px; padding-top: 7px;" class="groupHeader">
                                        <span style="float: left; padding: 2px 7px 0px 6px;">Filter : </span>
                                        <span style="float: left; padding-right: 7px">
                                            <telerik:RadDropDownList runat="server" ID="GroupDropDownList" CssClass="filterDDL" OnSelectedIndexChanged="GroupDropDownList_SelectedIndexChanged" Skin="Windows7" Width="200" AutoPostBack="true">
                                                <Items>
                                                    <telerik:DropDownListItem Value="1" Text="All Pages" />
                                                    <telerik:DropDownListItem Value="8" Text="Home Page" />
                                                    <telerik:DropDownListItem Value="2" Text="Settings" />
                                                    <telerik:DropDownListItem Value="3" Text="Admin Utilities Menu" />
                                                    <telerik:DropDownListItem Value="4" Text="User Maintenance Menu" />
                                                    <telerik:DropDownListItem Value="9" Text="Scheduler Menu" />
                                                </Items>
                                            </telerik:RadDropDownList>
                                        </span>
                                        <span style="float: left; padding: 2px 7px 0px 20px;">Grant Access Level : </span>
                                        <span style="float: left; padding-right: 7px">
                                            <telerik:RadComboBox ID="AccessLevelCombobx" runat="server" Skin="Windows7" Width="100" CssClass="filterDDL" OnClientSelectedIndexChanging="ConfirmAccessLevelChange" OnSelectedIndexChanged="ApplyClick" AutoPostBack="true">
                                                <Items>
                                                    <telerik:RadComboBoxItem Text="" Value="" Selected="true" />
                                                    <telerik:RadComboBoxItem Text="No Access" Value="0" ForeColor="Red" />
                                                    <telerik:RadComboBoxItem Text="Read Only" Value="1" ForeColor="Orange" />
                                                    <telerik:RadComboBoxItem Text="Full Access" Value="9" ForeColor="Green" />
                                                </Items>
                                            </telerik:RadComboBox>
                                        </span>
                                    </div>



                                <div style="height: 490px; width: 500px; display: block; overflow: auto; border:1px solid #dce6ef; background-color:#f2f9fc;   ">
                                   
                                    <telerik:RadTreeView RenderMode="Lightweight" runat="server" ID="PageGroupSectionsTreeView" Skin="Metro" OnContextMenuItemClick="PageGroupSectionsTreeView_ContextMenuItemClick">
                                        <ContextMenus>
                                            <telerik:RadTreeViewContextMenu ID="MainContextMenu" runat="server">
                                                <Items>
                                                    <telerik:RadMenuItem Value="9" Text="Full Access" ForeColor="Green" Font-Bold="true">
                                                    </telerik:RadMenuItem>
                                                    <telerik:RadMenuItem Value="1" Text="Read Only" ForeColor="Orange" Font-Bold="true">
                                                    </telerik:RadMenuItem>
                                                    <telerik:RadMenuItem Value="0" Text="No Access" ForeColor="Red" Font-Bold="true">
                                                    </telerik:RadMenuItem>
                                                </Items>
                                                <CollapseAnimation Type="none"></CollapseAnimation>
                                            </telerik:RadTreeViewContextMenu>
                                        </ContextMenus>
                                        <Nodes>
                                            <telerik:RadTreeNode Text="System Settings" Value="0" Expanded="true" Font-Bold="true" EnableContextMenu="false" />
                                            <telerik:RadTreeNode Text="Homepage" Value="1" Expanded="true" Font-Bold="true" EnableContextMenu="true" />
                                        </Nodes>
                                    </telerik:RadTreeView>
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
