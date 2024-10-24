<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_PreMedEditDrugs" Codebehind="PreMedEditDrugs.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Details Form</title>
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

            function CloseAndRebind(args) {
                GetRadWindow().BrowserWindow.refreshGrid(args);
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                return oWindow;
            }

            function CancelEdit() {
                GetRadWindow().BrowserWindow.refreshGrid();
                GetRadWindow().close();
            }

            function CheckForValidPage() {
                var valid = Page_ClientValidate("SaveUser");
                if (!valid) {
                    $("#<%=ServerErrorLabel.ClientID%>").hide();
                    $find("<%=ValidationNotification.ClientID%>").show();
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

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="UserDetailsFormView">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="UserDetailsFormView">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ServerErrorLabel" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Edit User"></asp:Label>
        </div>

        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All"
            DecorationZoneID="FormDiv" Skin="Web20" />

        <asp:ObjectDataSource ID="UserDetailsObjectDataSource" runat="server"
            TypeName="UnisoftERS.DataAccess" SelectMethod="GetUser" UpdateMethod="UpdateUser" InsertMethod="InsertUser">
            <SelectParameters>
                <asp:Parameter Name="UserId" DbType="Int32" DefaultValue="0" />
            </SelectParameters>
            <InsertParameters>
                <asp:Parameter Name="Username" DbType="String" DefaultValue="" />
                <asp:Parameter Name="ExpiresOn" DbType="Date" />
                <asp:Parameter Name="Title" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Forename" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Surname" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Initials" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Qualifications" DbType="String" DefaultValue="" />
                <asp:Parameter Name="JobTitleId" DbType="Int32" DefaultValue="0" />
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
            <UpdateParameters>
                <asp:Parameter Name="UserId" DbType="Int32" DefaultValue="0" />
                <asp:Parameter Name="Username" DbType="String" DefaultValue="" />
                <asp:Parameter Name="ExpiresOn" DbType="Date" />
                <asp:Parameter Name="Title" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Forename" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Surname" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Initials" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Qualifications" DbType="String" DefaultValue="" />
                <asp:Parameter Name="JobTitleId" DbType="Int32" DefaultValue="0" />
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
            </UpdateParameters>
        </asp:ObjectDataSource>

        <div id="FormDiv" runat="server">
            <div style="margin-top: 5px; margin-left: 10px;" class="rptText">
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
                                    <asp:RequiredFieldValidator ID="TitleRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="TitleTextBox" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Title is required" Text="*" ToolTip="This is a required field"
                                        ValidationGroup="SaveUser">
                                    </asp:RequiredFieldValidator>
                                </td>
                                <td>Forename:
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="ForenameTextBox" Text='<%# Bind("Forename") %>' runat="Server" />
                                    <asp:RequiredFieldValidator ID="ForenameRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="ForenameTextBox" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Forename is required" Text="*" ToolTip="This is a required field"
                                        ValidationGroup="SaveUser">
                                    </asp:RequiredFieldValidator>
                                </td>
                                <td>Surname:
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="SurnameTextBox" Text='<%# Bind("Surname") %>' runat="Server" />
                                    <asp:RequiredFieldValidator ID="SurnameRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="SurnameTextBox" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Surname is required" Text="*" ToolTip="This is a required field"
                                        ValidationGroup="SaveUser">
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td>User Id:
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="UserNameTextBox" Text='<%# Bind("UserName") %>' runat="Server" />
                                    <asp:RequiredFieldValidator ID="UserNameRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="UserNameTextBox" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="User Id is required" Text="*" ToolTip="This is a required field"
                                        ValidationGroup="SaveUser">
                                    </asp:RequiredFieldValidator>
                                </td>
                                <td>Expires On:
                                </td>
                                <td>
                                    <telerik:RadDatePicker ID="ExpiresOnDatePicker" SelectedDate='<%# Bind("ExpiresOn") %>' runat="server"
                                        MinDate='<%# DateTime.Now.Date() %>' MaxDate="01/01/3000" Calendar-ShowRowHeaders="false">
                                    </telerik:RadDatePicker>
                                    <asp:RequiredFieldValidator ID="ExpiresOnRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="ExpiresOnDatePicker" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Expires On is required" Text="*" ToolTip="This is a required field"
                                        ValidationGroup="SaveUser">
                                    </asp:RequiredFieldValidator>
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
                                    <asp:RequiredFieldValidator ID="PermissionsRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="PermissionsDropDownList" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Permissions is required" Text="*" ToolTip="This is a required field"
                                        ValidationGroup="SaveUser">
                                    </asp:RequiredFieldValidator>
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
                                                <asp:CheckBox ID="Nurse2CheckBox" runat="server" Text="Nurse 2" Checked='<%# Bind("IsNurse2")%>' />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <br />
                        <div id="buttonsdiv" style="height: 10px; margin-left: 5px; padding-top: 6px; vertical-align: central;">
                            <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" ValidationGroup="ChangePassword"
                                CausesValidation="true" OnClientClicked="CheckForValidPage" />
                            <telerik:RadButton ID="SaveAndCloseButton" runat="server" Text="Save & Close" Skin="Web20" ValidationGroup="ChangePassword"  Icon-PrimaryIconCssClass="telerikSaveButton"
                                CausesValidation="true" OnClientClicked="CheckForValidPage" />
                            <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" AutoPostBack="false" OnClientClicked="CancelEdit" Icon-PrimaryIconCssClass="telerikCancelButton"
                                CausesValidation="false" />
                        </div>
                    </EditItemTemplate>
                </asp:FormView>
            </div>
            <telerik:RadWindowManager ID="AddNewTitleRadWindowManager" runat="server" ShowContentDuringLoad="false"
                Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
                <Windows>
                    <telerik:RadWindow ID="AddNewTitleRadWindow" runat="server" ReloadOnShow="true"
                        KeepInScreenBounds="true" Width="400px" Height="160px" VisibleStatusbar="false">
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
                                            <telerik:RadButton ID="AddNewTitleCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" 
                                                OnClientClicked="closeAddTitleWindow" AutoPostBack="true"/>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </telerik:RadWindow>
                </Windows>
            </telerik:RadWindowManager>
        </div>

        <telerik:RadNotification ID="ValidationNotification" runat="server" Animation="None"
            EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
            LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
            AutoCloseDelay="7000">
            <ContentTemplate>
                <asp:ValidationSummary ID="SaveUserValidationSummary" runat="server" ValidationGroup="SaveUser" DisplayMode="BulletList"
                    EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                <asp:Label ID="ServerErrorLabel" runat="server" CssClass="aspxValidationSummary" Visible="false"></asp:Label>
            </ContentTemplate>
        </telerik:RadNotification>
    </form>
</body>
</html>
