<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_UserMaintenanceOld" Codebehind="UserMaintenanceOld.aspx.vb" %>

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

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="UsersRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="UserDetailsFormView" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="UserDetailsFormView">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <%--<asp:Panel ID="OuterPanel" runat="server">
            <asp:Panel ID="InnerPanel" runat="server" Visible="false">--%>


        <div class="optionsHeading">User Maintenance</div>

        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All"
            DecorationZoneID="FormDiv" Skin="Web20" />

        <asp:ObjectDataSource ID="UsersObjectDataSource" runat="server" SelectMethod="GetUsers" TypeName="Options">
            <SelectParameters>
                <asp:ControlParameter Name="SearchPhrase" DbType="String" ControlID="UserSearchTextBox" ConvertEmptyStringToNull="true" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <asp:ObjectDataSource ID="UserDetailsObjectDataSource" runat="server"
            TypeName="UnisoftERS.DataAccess" SelectMethod="GetUser" UpdateMethod="UpdateUser" InsertMethod="InsertUser">
            <SelectParameters>
                <asp:Parameter Name="UserId" DbType="Int32" DefaultValue="0" />
            </SelectParameters>
            <UpdateParameters>
                <asp:Parameter Name="UserId" DbType="Int32" DefaultValue="0" />
                <asp:Parameter Name="Username" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Title" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Forename" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Surname" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Initials" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Qualifications" DbType="String" DefaultValue="" />
                <asp:Parameter Name="JobTitle" DbType="String" DefaultValue="" />
                <asp:Parameter Name="AccessRights" DbType="Int32" DefaultValue="0" />
                <asp:Parameter Name="DeletePatients" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="ModifyTables" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="CanRunAK" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsListConsultant" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsEndoscopist1" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsEndoscopist2" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsAssistantOrTrainee" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsNurse1" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsNurse2" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="Active" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="Suppressed" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="ExpiresOn" DbType="Date" />
            </UpdateParameters>
            <InsertParameters>
                <asp:Parameter Name="Username" DbType="String" DefaultValue="" />
                <asp:Parameter Name="ExpiresOn" DbType="Date" />
                <asp:Parameter Name="Title" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Forename" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Surname" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Initials" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Qualifications" DbType="String" DefaultValue="" />
                <asp:Parameter Name="JobTitle" DbType="String" DefaultValue="" />
                <asp:Parameter Name="AccessRights" DbType="Int32" DefaultValue="0" />
                <asp:Parameter Name="DeletePatients" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="ModifyTables" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="CanRunAK" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsListConsultant" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsEndoscopist1" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsEndoscopist2" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsAssistantOrTrainee" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsNurse1" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsNurse2" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="Active" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="Suppressed" DbType="Boolean" DefaultValue="False" />
            </InsertParameters>
        </asp:ObjectDataSource>

        <div id="FormDiv" runat="server">

        <div style="margin-top: 5px; margin-left: 10px;" class="rptText">
            <asp:Panel ID="Panel1" runat="server" DefaultButton="UserSearchButton">
                <table id="UserSearchTable" runat="server" cellspacing="0" cellpadding="0">
                    <tr>
                        <td style="padding-right: 5px;">Search by User ID / Name:
                        </td>
                        <td style="padding-right: 10px;">
                            <telerik:RadTextBox ID="UserSearchTextBox" runat="server" Skin="Windows7" Width="200" /></td>
                        <td style="padding-right: 5px;">
                            <telerik:RadButton ID="UserSearchButton" runat="server" Text="Search" Skin="WebBlue" />
                        </td>
                        <td>
                            <telerik:RadButton ID="UserSearchClearButton" runat="server" Text="Clear" Skin="WebBlue" />
                        </td>
                    </tr>
                </table>
            </asp:Panel>

            <div style="margin-top: 5px;">
                <telerik:RadGrid ID="UsersRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                    DataSourceID="UsersObjectDataSource" MasterTableView-DataKeyNames="UserId"
                    CellSpacing="0" GridLines="None" Skin="Office2010Blue" PageSize="50" AllowPaging="true" Height="220px" Width="900px">
                    <HeaderStyle Font-Bold="true" Height="12px" />
                    <MasterTableView ShowHeadersWhenNoRecords="true">
                        <Columns>
                            <telerik:GridTemplateColumn ItemStyle-HorizontalAlign="Center" HeaderText="" HeaderStyle-Width="50px" HeaderStyle-Wrap="false">
                                <ItemTemplate>
                                    <asp:ImageButton ID="ImageButton1" runat="server" ImageUrl="~/Images/edit.png" CommandName="Delete" ToolTip="Edit user details"
                                        Width="15px" />
                                    <asp:ImageButton ID="ImageButton2" runat="server" ImageUrl="~/Images/stop.png" CommandName="Delete" ToolTip="Suppress this user"
                                        OnClientClick="javascript:if(!confirm('Are you sure you want to suppress this user?')){return false;}" Width="15px" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="UserName" HeaderText="User ID" SortExpression="UserName" HeaderStyle-Width="120px"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="Name" HeaderText="Name" SortExpression="Name" HeaderStyle-Width="200px"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="AccessRights" HeaderText="Access Rights" SortExpression="AccessRights"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="ModifyTables" HeaderText="Modify Tables" SortExpression="ModifyTables"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="DeletePatients" HeaderText="Delete Patients" SortExpression="DeletePatients"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="Suppressed" HeaderText="Suppressed" SortExpression="Suppressed"></telerik:GridBoundColumn>
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-left: 5px;">No records found</div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                    <PagerStyle Mode="NextPrev" />
                    <ClientSettings EnablePostBackOnRowClick="true">
                        <Selecting AllowRowSelect="True" />
                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                    </ClientSettings>
                </telerik:RadGrid>
            </div>

            <asp:FormView ID="UserDetailsFormView" runat="server"
                DataSourceID="UserDetailsObjectDataSource" DataKeyNames="UserId" BorderStyle="None">
                <EditItemTemplate>

                    <table id="dsa" runat="server" cellpadding="2" cellspacing="2">
                        <tr>
                            <td colspan="10">
                                <span class="subheader">
                                    <b>User Details</b>
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <td width="70px">Title:
                            </td>
                            <td>
                                <telerik:RadTextBox ID="TitleTextBox" Text='<%# Bind("Title") %>' runat="Server" Width="50px" />
                            </td>
                            <td>Forename:
                            </td>
                            <td>
                                <telerik:RadTextBox ID="ForenameTextBox" Text='<%# Bind("Forename") %>' runat="Server" />
                            </td>
                            <td>Surname:
                            </td>
                            <td>
                                <telerik:RadTextBox ID="SurnameTextBox" Text='<%# Bind("Surname") %>' runat="Server" />
                            </td>
                        </tr>
                        <tr>
                            <td>User Id:
                            </td>
                            <td>
                                <telerik:RadTextBox ID="UserIdTextBox" Text='<%# Bind("UserName") %>' runat="Server" />
                            </td>
                            <td>Expires On:
                            </td>
                            <td>
                                <telerik:RadDatePicker ID="ExpiresOnDatePicker" SelectedDate='<%# Bind("ExpiresOn") %>' runat="server"
                                    MinDate='<%# DateTime.Now.Date() %>' MaxDate="01/01/3000" Calendar-ShowRowHeaders="false">
                                </telerik:RadDatePicker>
                            </td>
                        </tr>
                        <tr>
                            <td valign="top">Permissions:
                            </td>
                            <td valign="top">
                                <telerik:RadDropDownList ID="PermissionsDropDownList" runat="server" SelectedValue='<%# Bind("AccessRights") %>'>
                                    <Items>
                                        <telerik:DropDownListItem />
                                        <telerik:DropDownListItem Text="Read Only" Value="1"></telerik:DropDownListItem>
                                        <telerik:DropDownListItem Text="Regular" Value="2"></telerik:DropDownListItem>
                                        <telerik:DropDownListItem Text="Administrator" Value="3"></telerik:DropDownListItem>
                                    </Items>
                                </telerik:RadDropDownList>
                            </td>
                            <td colspan="10">
                                <table>
                                    <tr>
                                        <td>
                                            <asp:CheckBox ID="ModifyTablesCheckBox" runat="server" Text="Can add/modify reference tables" Checked='<%# Bind("ModifyTables") %>' />
                                        </td>
                                        <td>
                                            <asp:CheckBox ID="DeletePatientsCheckBox" runat="server" Text="Can delete patients" Checked='<%# Bind("DeletePatients") %>' />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:CheckBox ID="ActiveCheckBox" runat="server" Text="Lock System Access" Checked='<%# Bind("Active")%>' />
                                        </td>
                                        <td>
                                            <asp:CheckBox ID="SuppressedCheckBox" runat="server" Text="Suppressed" Checked='<%# Bind("Suppressed") %>' />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>

                        <tr>
                            <td colspan="10">
                                <span class="subheader">
                                    <b>Staff Details</b>
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <td>Title:
                            </td>
                            <td colspan="10">
                                <telerik:RadDropDownList ID="TitleRadDropDownList" runat="server"></telerik:RadDropDownList>
                                <telerik:RadButton ID="AddNedwRadButton" runat="server" Text="Add New"
                                    OnClientClicked="openAddTitleWindow" AutoPostBack="false"
                                    Skin="WebBlue" />
                            </td>
                        </tr>
                        <tr>
                            <td>Qualifications:
                            </td>
                            <td>
                                <telerik:RadTextBox ID="QualificationsRadTextBox" Text='<%# Bind("Qualifications") %>' runat="Server" />
                            </td>
                        </tr>
                        <tr>
                            <td valign="top" nowrap>Can appear as:
                            </td>
                            <td colspan="10">
                                <table>
                                    <tr>
                                        <td>
                                            <asp:CheckBox ID="ListConsultantCheckBox" runat="server" Text="List Consultant" Checked='<%# Bind("IsListConsultant") %>' />
                                        </td>
                                        <td>
                                            <asp:CheckBox ID="AssistantTraineeCheckBox" runat="server" Text="Assistant/Trainee" Checked='<%# Bind("IsAssistantOrTrainee")%>' />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:CheckBox ID="Endoscopist1" runat="server" Text="Endoscopist 1" Checked='<%# Bind("IsEndoscopist1") %>' />
                                        </td>
                                        <td>
                                            <asp:CheckBox ID="Nurse1CheckBox" runat="server" Text="Nurse 1" Checked='<%# Bind("IsNurse1")%>' />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:CheckBox ID="Endoscopist2" runat="server" Text="Endoscopist 2" Checked='<%# Bind("IsEndoscopist2") %>' />
                                        </td>
                                        <td>
                                            <asp:CheckBox ID="Nurse2CheckBox" runat="server" Text="Nurse 2" Checked='<%# Bind("IsNurse2") %>' />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <br />
                    <div id="buttonsdiv" style="height: 10px; margin-left: 5px; padding-top: 6px; vertical-align: central;">
                        <telerik:RadButton ID="UpdateButton" runat="server" Text="Save" Skin="Web20" CommandName="Update" />
                        <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" CommandName="Cancel" />
                    </div>
                </EditItemTemplate>
            </asp:FormView>
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
                                        <telerik:RadButton ID="AddNewTitleSaveRadButton" runat="server" Text="Save" Skin="WebBlue" />
                                        <telerik:RadButton ID="AddNewTitleCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" OnClientClicked="closeAddTitleWindow" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
        <%--                </asp:Panel>
            </asp:Panel>--%>
    </div>

    </form>
</body>
</html>
