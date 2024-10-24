<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_EditUser" CodeBehind="EditUser.aspx.vb" %>

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
                $('.GMCToggleField').on('change', function () {
                    toggleGMCField();
                });

                toggleGMCField();
            });

            function toggleGMCField() {
                var reqElement = { control: $('#<%=UserDetailsFormView.FindControl("GMCCodeTextBox").ClientID%>')[0].id, fieldName: "GMC Code" };
                
                if ($('#<%=UserDetailsFormView.FindControl("ListConsultantCheckBox").ClientID%>').is(":checked") ||
                    $('#<%=UserDetailsFormView.FindControl("Endoscopist1").ClientID%>').is(":checked") ||
                    $('#<%=UserDetailsFormView.FindControl("Endoscopist2").ClientID%>').is(":checked")) {
                    if (reqFields != undefined) {
                        //make GMC code a required field
                        //reqFields.items.push(reqElement);
                        setRequiredField($('#<%=UserDetailsFormView.FindControl("GMCCodeTextBox").ClientID%>')[0].id, 'GMC Code');
                    }
                }
                else {
                    var inx = -1;
                    //reqFields.items.filter(function (item) {
                    //    if (item.control === reqElement.control) {
                    //        inx++;
                    //        return inx;
                    //    }
                    //});

                    if (reqFields.items.indexOf(reqElement.control) >= 0) {
                        inx++;
                        return;
                    }

                    if (inx > -1) {
                        //remove GMC code a required field (if exists)
                        delete reqFields.items.splice(inx, 1);
                        $('#<%=UserDetailsFormView.FindControl("GMCCodeTextBox").ClientID%>').removeClass("validation-error-field");
                    }
                    removeRequiredField($('#<%=UserDetailsFormView.FindControl("GMCCodeTextBox").ClientID%>')[0].id, 'GMC Code');
                }
            }

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

            function ConfirmReset() {
                if (!confirm("Are you sure you want to reset the password?")) {
                    eventArgs.set_cancel(true);
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
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" AutoCloseDelay="0" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="UserDetailsFormView">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="UserDetailsFormView">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="UserDetailsFormView" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="UserDetailsFormView">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ServerErrorLabel" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <%--       <telerik:AjaxSetting AjaxControlID="ResetPasswordButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ResetPasswordButton" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
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
                <asp:Parameter Name="isGIConsultant" DbType="Boolean" DefaultValue="True" />
                <asp:Parameter Name="JobTitleId" DbType="Int32" DefaultValue="0" />
                <asp:Parameter Name="RoleID" DbType="String" DefaultValue="" />
                <asp:Parameter Name="CanRunAK" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsListConsultant" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsEndoscopist1" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsEndoscopist2" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsAssistantOrTrainee" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsNurse1" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsNurse2" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="Suppressed" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="ShowTooltips" DbType="Boolean" DefaultValue="True" />
                <asp:Parameter Name="CanEditDropdowns" DbType="Boolean" DefaultValue="True" />
                <asp:Parameter Name="GMCCode" DbType="String" DefaultValue="" ConvertEmptyStringToNull="false" />
                <asp:Parameter Name="UserId" DbType="Int32" DefaultValue="0" Direction="Output" />
                <asp:Parameter Name="CanViewAllUserAudits" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="GeneralLibrary" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="CanOverbookLists" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="CanOverrideSchedule" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsTrainee" DbType="Boolean" DefaultValue="False" />
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
                <asp:Parameter Name="isGIConsultant" DbType="Boolean" DefaultValue="True" />
                <asp:Parameter Name="JobTitleId" DbType="Int32" DefaultValue="0" />
                <asp:Parameter Name="RoleID" DbType="String" DefaultValue="" />
                <asp:Parameter Name="CanRunAK" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsListConsultant" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsEndoscopist1" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsEndoscopist2" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsAssistantOrTrainee" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsNurse1" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsNurse2" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="Suppressed" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="ShowTooltips" DbType="Boolean" DefaultValue="True" />
                <asp:Parameter Name="CanEditDropdowns" DbType="Boolean" DefaultValue="True" />
                <asp:Parameter Name="CanOverbookLists" DbType="Boolean" DefaultValue="True" />
                <asp:Parameter Name="CanViewAllUserAudits" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="GeneralLibrary" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="GMCCode" DbType="String" DefaultValue="" ConvertEmptyStringToNull="false" />
                <asp:Parameter Name="CanOverrideSchedule" DbType="Boolean" DefaultValue="true" />
                <asp:Parameter Name="IsTrainee" DbType="Boolean" DefaultValue="False" />
            </UpdateParameters>
        </asp:ObjectDataSource>

        <div id="FormDiv" runat="server">
            <div style="margin-top: 5px; margin-left: 10px; margin-bottom: 10px;" class="rptText">
                <asp:FormView ID="UserDetailsFormView" runat="server"
                    DataSourceID="UserDetailsObjectDataSource" DataKeyNames="UserId" BorderStyle="None">
                    <EditItemTemplate>

                        <table id="dsa" runat="server" cellpadding="2" cellspacing="2">
                            <tr>
                                <td colspan="2">
                                    <span class="subheader">
                                        <b>User Details</b>
                                    </span>
                                </td>
                                <td runat="server" id="tdMsgPassword" colspan="4" style="color: #b300b3; text-align: right; border-bottom: 1px dashed #ffccff;" visible="false">
                                    <b>Password</b> for a new user is the same as the User Id when login for the first time.
                                </td>
                            </tr>
                            <tr>
                                <td width="70px">
                                    <asp:Label ID="TitleLabel" runat="server" Text="Title:" />
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="TitleTextBox" Text='<%# Bind("Title") %>' runat="Server" Width="50px" />
                                </td>
                                <td>
                                    <asp:Label ID="ForenameLabel" runat="server" Text="Forename:" />
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="ForenameTextBox" Text='<%# Bind("Forename") %>' runat="Server" />
                                </td>
                                <td>
                                    <asp:Label ID="SurnameLabel" runat="server" Text="Surname:" />
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="SurnameTextBox" Text='<%# Bind("Surname") %>' runat="Server" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="UserIDLabel" runat="server" Text="User Id:" />
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="UserNameTextBox" Text='<%# Bind("UserName") %>' runat="Server" />
                                </td>
                                <td>
                                    <asp:Label ID="ExpiresOnLabel" runat="server" Text="Expires On:" />
                                </td>
                                <td>
                                    <telerik:RadDatePicker ID="ExpiresOnDatePicker" SelectedDate='<%# Bind("ExpiresOn")%>' runat="server"
                                        MinDate='<%# DateTime.Now.Date() %>' MaxDate="01/01/5000" Calendar-ShowRowHeaders="false">
                                    </telerik:RadDatePicker>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    <asp:Label ID="RolesLabel" runat="server" Text="Role(s):" />
                                </td>
                                <td valign="top" colspan="3">
                                    <telerik:RadComboBox ID="PermissionsDropDownList" DataSourceID="PermissionsObjectDataSource" runat="server" CheckBoxes="true" ZIndex="9502" Skin="Windows7" Width="391" EnableCheckAllItemsCheckBox="true" DataTextField="RoleName" DataValueField="RoleID" />
                                    <asp:ObjectDataSource ID="PermissionsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetDistinctList" />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    <asp:Label ID="OperatingHospitalLabel" runat="server" Text="Operating Hospital" />
                                </td>
                                <td valign="top" colspan="3">
                                    <telerik:RadComboBox ID="OperatingHospitalsRadComboBox" CheckBoxes="true" EnableCheckAllItemsCheckBox="true" DataSourceID="OperatingHospitalsObjectDataSource" runat="server" ZIndex="9502" Skin="Windows7" Width="391" DataTextField="HospitalName" DataValueField="OperatingHospitalId" />
                                    <asp:ObjectDataSource ID="OperatingHospitalsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetAllOperatingHospitals">
                                        <SelectParameters>
                                            <asp:SessionParameter Name="selectedTrust" SessionField="TrustID" DbType="Int32" />
                                        </SelectParameters>
                                    </asp:ObjectDataSource>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top"></td>
                                <td colspan="10">
                                    <table>
                                        <tr>
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
                                <td>
                                    <asp:Label ID="StaffTitleLabel" runat="server" Text="Title:" />
                                </td>
                                <td colspan="10">
                                    <telerik:RadDropDownList ID="TitleRadDropDownList" runat="server"></telerik:RadDropDownList>
                                    <telerik:RadButton ID="AddNedwRadButton" runat="server" Text="Add New"
                                        OnClientClicked="openAddTitleWindow" AutoPostBack="false"
                                        Skin="WebBlue" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="QualificationsLabel" runat="server" Text="Qualifications:" />
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="QualificationsRadTextBox" Text='<%# Bind("Qualifications") %>' runat="Server" />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top" nowrap>
                                    <asp:Label ID="CanAppearAsLabel" runat="server" Text="Can appear as:" />
                                </td>
                                <td colspan="10">
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="ListConsultantCheckBox" runat="server" Text="List Consultant" Checked='<%# Bind("IsListConsultant") %>' AutoPostBack="false" CssClass="GMCToggleField" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="AssistantTraineeCheckBox" runat="server" Text="Nurse 1" Checked='<%# Bind("IsAssistantOrTrainee")%>' />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="Nurse2CheckBox" runat="server" Text="Assistant/Nurse 3" Checked='<%# Bind("IsNurse2")%>' />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="Endoscopist1" runat="server" Text="Endoscopist 1" Checked='<%# Bind("IsEndoscopist1") %>' AutoPostBack="false" CssClass="GMCToggleField" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="Nurse1CheckBox" runat="server" Text="Nurse 2" Checked='<%# Bind("IsNurse1")%>' />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="TraineeCheckBox" runat="server" Text="Trainee" Checked='<%# Bind("IsTrainee")%>' />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="Endoscopist2" runat="server" Text="Endoscopist 2" Checked='<%# Bind("IsEndoscopist2") %>' AutoPostBack="false" CssClass="GMCToggleField" />
                                            </td>
                                            
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="GMCCodeLabel" runat="server" Text="GMC/NMC :" />
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="GMCCodeTextBox" Text='<%# Bind("GMCCode") %>' runat="Server" />

                                </td>
                            </tr>
                            <tr>
                                <td colspan="4">
                                    <div style="float: left;">
                                        <table>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="ShowHelpToolTipsLabel" runat="server" Text="Show help tooltips:" AssociatedControlID="ShowTooltipsCheckBox" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="ShowTooltipsCheckBox" runat="server" Checked='<%# Bind("ShowTooltips")%>' />
                                                </td>
                                                <td></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="CanEditDropdownsLabel" runat="server" Text="Can edit dropdowns:" AssociatedControlID="CanEditDropdownsCheckBox" />
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="CanEditDropdownsCheckBox" runat="server" Checked='<%# Bind("CanEditDropdowns")%>' />
                                                </td>
                                                <td></td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div style="float: left">
                                        <table>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="Label1" runat="server" Text="Can view all user reports:" AssociatedControlID="CanViewAllUserAudits" /></td>
                                                <td>
                                                    <asp:CheckBox ID="CanViewAllUserAudits" runat="server" Checked='<%# Bind("CanViewAllUserAudits")%>' />
                                                </td>
                                            </tr>

                                            <tr>
                                                <td>
                                                    <asp:Label ID="Label3" runat="server" Text="Can Override scheduler points:" AssociatedControlID="CanOverrideSchedule" /></td>
                                                <td>
                                                    <asp:CheckBox ID="CanOverrideSchedule" runat="server" Checked='<%# Bind("CanOverrideSchedule")%>' />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div style="float: left;">

                                        <table>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="Label2" runat="server" Text="General Library:" AssociatedControlID="GeneralLibrary" /></td>
                                                <td>
                                                    <asp:CheckBox ID="GeneralLibrary" runat="server" Checked='<%# Bind("GeneralLibrary")%>' />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="CanOverbookListsLabel" runat="server" Text="Can overbook lists:" AssociatedControlID="CanOverbookListsCheckBox" /></td>
                                                <td>
                                                    <asp:CheckBox ID="CanOverbookListsCheckBox" runat="server" Checked='<%# Bind("CanOverbookLists")%>' />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>

                                    <div style="float: left;">
                                        <table>
                                        </table>
                                    </div>

                                </td>

                            </tr>
                        </table>
                        <br />
                        <div id="buttonsdiv" style="height: 10px; margin-left: 5px; margin-bottom: 10px; padding-top: 6px; vertical-align: central;" runat="server">
                            <table style="width: 100%;">
                                <tr>
                                    <td>
                                        <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" OnClientClicked="validatePage" Visible="false" />
                                        <telerik:RadButton ID="SaveAndCloseButton" runat="server" Text="Save & Close" Skin="Metro" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicked="validatePage" />
                                        <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" OnClientClicked="CancelEdit" Icon-PrimaryIconCssClass="telerikCancelButton"
                                            CausesValidation="false" />
                                    </td>
                                    <td style="text-align: right;">
                                        <telerik:RadButton ID="ResetPasswordButton" runat="server" Text="Reset password" Skin="Metro" OnClick="ResetPasswordButton_Click" Icon-PrimaryIconCssClass="telerikUndoButton"
                                            OnClientClicked="ConfirmReset" ToolTip="Password will be the same as the User Id after resetting." />
                                    </td>
                                </tr>
                            </table>
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
                                                OnClientClicked="closeAddTitleWindow" AutoPostBack="true" />
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
                <asp:ValidationSummary ID="SaveUserValidationSummary" runat="server" DisplayMode="BulletList"
                    EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                <asp:Label ID="ServerErrorLabel" runat="server" CssClass="aspxValidationSummary" Visible="false"></asp:Label>
            </ContentTemplate>
        </telerik:RadNotification>
    </form>
</body>
</html>
