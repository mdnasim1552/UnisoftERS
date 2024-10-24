<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_EditConsultants" CodeBehind="EditConsultants.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Consultant Details Form</title>
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

            function showHospitals() {
                var wnd = $find("<%= HospitalRadWindow.ClientID%>");
                wnd.show();
            }

            function showGroup() {
                var wnd = $find("<%= GroupRadWindow.ClientID%>");
                wnd.show();

            }
            function showSelected() {
                var supbtn = $find("<%= SuppressRadButton.ClientID%>")
                supbtn.set_enabled(true);
                var grid = $find("<%= HospitalsRadGrid.ClientID%>").get_masterTableView().get_selectedItems()[0]
                if (grid != null) {
                    var id = grid.getDataKeyValue("Suppressed");
                    if (id == 'No') {
                        supbtn.set_text("Suppress Hospital");
                    } else {
                        supbtn.set_text("Unsuppress Hospital");
                    }
                }
            }

            function closeHospital() {
                var wnd = $find("<%= HospitalRadWindow.ClientID%>");
                wnd.close();
            }

            function closeGroup() {
                var wnd = $find("<%= GroupRadWindow.ClientID%>");
                wnd.close();
            }
            function CheckForValidPage() {
                var valid = Page_ClientValidate("SaveConsultant");
                if (!valid) {
                    $("#<%=ServerErrorLabel.ClientID%>").hide();
                    $find("<%=ValidationNotification.ClientID%>").show();
                }
            }

            function CheckForValidSpecialty() {
                var valid = Page_ClientValidate("NewSpecialty");
                if (!valid) {
                    $("#<%=ServerErrorLabel.ClientID%>").hide();
                    $find("<%=ValidationNotification.ClientID%>").show();
                }
            }

            function CloseAndRebind(args) {
                GetRadWindow().BrowserWindow.refreshGrid(args);
                GetRadWindow().close();
            }

            function CloseEditWindow(newId) {
                GetRadWindow().BrowserWindow.refreshGrid(newId);
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                return oWindow;
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
                <telerik:AjaxSetting AjaxControlID="NewHospitalRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="HospitalsRadGrid" />
                        <telerik:AjaxUpdatedControl ControlID="HospitalRadListBox" />
                        <telerik:AjaxUpdatedControl ControlID="NewHospitalTextBox" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="NewGroupRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SpecialityDropDownList" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SuppressRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="HospitalsRadGrid" />
                        <telerik:AjaxUpdatedControl ControlID="HospitalRadListBox" />
                        <telerik:AjaxUpdatedControl ControlID="SuppressRadButton" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="430px">
                <asp:ObjectDataSource ID="ConsultantSpecialityObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetSpeciality" />
                <asp:ObjectDataSource ID="ConsultantHospitalObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetHospital" />
                <asp:ObjectDataSource ID="HospitalObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetHospitals" />

                <div id="FormDiv" runat="server">
                    <div style="margin-left: 10px; padding-top: 20px" class="rptText">
                        <div style="padding-bottom: 5px">
                            <asp:Label runat="server" Text="Title" Width="120px" /><asp:TextBox ID="TitleTextBox" runat="server" Width="200" />
                            <asp:RegularExpressionValidator ID="TitleRegexValidator" runat="server" CssClass="aspxValidator"
                                ControlToValidate="TitleTextBox" EnableClientScript="true" Display="Dynamic"
                                ErrorMessage="Title must not exceed 10 characters" Text="*" ToolTip="Max character length of 10 cannot be exceeded"
                                ValidationGroup="SaveConsultant" ValidationExpression="^([\S\s]{0,10})$" />
                        </div>
                        <div style="padding-bottom: 5px">
                            <asp:Label runat="server" Text="Initial" Width="120px" /><asp:TextBox ID="InitialTextBox" runat="server" Width="200" />
                            <asp:RegularExpressionValidator ID="InitialRegexValidator" runat="server" CssClass="aspxValidator"
                                ControlToValidate="InitialTextBox" EnableClientScript="true" Display="Dynamic"
                                ErrorMessage="Initial must not exceed 5 characters" Text="*" ToolTip="Max character length of 5 cannot be exceeded"
                                ValidationGroup="SaveConsultant" ValidationExpression="^([\S\s]{0,5})$" />
                        </div>
                        <div style="padding-bottom: 5px">
                            <asp:Label runat="server" Text="Forename" Width="120px" /><asp:TextBox ID="ForenameTextBox" runat="server" Width="200" />
                            <asp:RegularExpressionValidator ID="ForenameRegexValidator" runat="server" CssClass="aspxValidator"
                                ControlToValidate="ForenameTextBox" EnableClientScript="true" Display="Dynamic"
                                ErrorMessage="Forename must not exceed 100 characters" Text="*" ToolTip="Max character length of 100 cannot be exceeded"
                                ValidationGroup="SaveConsultant" MaximumValue="100" ValidationExpression="^([\S\s]{0,100})$" />
                        </div>
                        <div style="padding-bottom: 5px">
                            <asp:Label runat="server" Text="Surname" Width="120px" /><asp:TextBox ID="SurnameTextBox" runat="server" Width="200"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="SurnameRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                ControlToValidate="SurnameTextBox" EnableClientScript="true" Display="Dynamic"
                                ErrorMessage="Surname is required" Text="*" ToolTip="This is a required field"
                                ValidationGroup="SaveConsultant">
                            </asp:RequiredFieldValidator>
                            <asp:RegularExpressionValidator ID="SurnameRegexValidator" runat="server" CssClass="aspxValidator"
                                ControlToValidate="SurnameTextBox" EnableClientScript="true" Display="Dynamic"
                                ErrorMessage="Surname must not exceed 100 characters" Text="*" ToolTip="Max character length of 100 cannot be exceeded"
                                ValidationGroup="SaveConsultant" ValidationExpression="^([\S\s]{0,100})$" />
                            <%-- <asp:RequiredFieldValidator ID="SuranmeFieldValidator" runat="server" Display="Dynamic"  ForeColor="Red"  ControlToValidate="SurnameTextBox" ErrorMessage="Surname cannot be empty!"></asp:RequiredFieldValidator>--%>
                        </div>
                        <div style="padding-bottom: 5px">
                            <asp:Label runat="server" Text="GMC Code" Width="120px" /><asp:TextBox ID="GMCCodeTextBox" runat="server" Width="200" />
                            <asp:RegularExpressionValidator ID="GMCCodeRegexValidator" runat="server" CssClass="aspxValidator"
                                ControlToValidate="GMCCodeTextBox" EnableClientScript="true" Display="Dynamic"
                                ErrorMessage="GMC Code must not exceed 25 characters" Text="*" ToolTip="Max character length of 25 cannot be exceeded"
                                ValidationGroup="SaveConsultant" ValidationExpression="^([\S\s]{0,25})$" />
                        </div>
                        <div style="padding-bottom: 5px; overflow: hidden">
                            <div style="float: left">
                                <asp:Label runat="server" Text="Speciality/Group" Width="120px" />
                            </div>
                            <div style="float: left; padding-right: 5px">
                                <telerik:RadDropDownList ID="SpecialityDropDownList" runat="server" Width="200" DataTextField="GroupName" DefaultMessage="Select a group" DataValueField="Code" DataSourceID="ConsultantSpecialityObjectDataSource" />
                            </div>
                            <div style="float: left">
                                <telerik:RadButton ID="AddSpecialityButton" runat="server" Text="Add Speciality" OnClientClicked="showGroup" AutoPostBack="false" />
                            </div>
                            <%-- <asp:RequiredFieldValidator ID="SpecialityValidator" runat="server" Display="Dynamic"   ControlToValidate="SpecialityDropDownList" ErrorMessage="Speciality cannot be empty!" ForeColor="Red"></asp:RequiredFieldValidator>--%>
                        </div>
                        
                        
                        <div style="padding-bottom: 5px">
                            <asp:Label runat="server" Text="Email" Width="120px" />
                            <%--<asp:TextBox ID="EmailAddressTextBox" runat="server" Width="200"></asp:TextBox>--%>
                            <asp:TextBox ID="EmailAddressTextBox" runat="server" TextMode="Email" MaxLength="50" ToolTip="Max character length of 50 cannot be exceeded"></asp:TextBox>
                            
                        <%--    <asp:RequiredFieldValidator ID="EmailAddressTextBoxRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                        ControlToValidate="EmailAddressTextBox" EnableClientScript="true" Display="Dynamic"
                                                        ErrorMessage="A valid email address must contain the @ symbol" Text="*" ToolTip="This is a required field"
                                                        ValidationGroup="SaveConsultant">
                            </asp:RequiredFieldValidator>
                            <asp:RegularExpressionValidator ID="RegularExpressionValidator3" runat="server" CssClass="aspxValidator"
                                                            ControlToValidate="SurnameTextBox" EnableClientScript="true" Display="Dynamic"
                                                            ErrorMessage="Email address must not exceed 50 characters" Text="*" ToolTip="Max character length of 50 cannot be exceeded"
                                                            ValidationGroup="SaveConsultant" ValidationExpression="^(. +)@(\S+){0,50}$" />--%>
                        </div>

                        

                        <div style="padding-bottom: 5px">
                            <div style="float: left">
                                <asp:Label runat="server" Text="Hospital" Width="120px" />
                            </div>
                            <div style="float: left; padding-right: 5px">
                                <telerik:RadListBox ID="HospitalRadListBox" runat="server" CheckBoxes="true" ShowCheckAll="true" Width="300" DataTextField="HospitalName" DataValueField="HospitalID" DataSourceID="ConsultantHospitalObjectDataSource" Height="230px" />
                            </div>
                            <div style="float: left">
                                <span style="padding-left: 5px">
                                    <telerik:RadButton ID="EditHospitalRadButton" runat="server" Text="Add/edit hospital" OnClientClicked="showHospitals" AutoPostBack="false" />
                                </span>
                            </div>
                        </div>
                    </div>

                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Web20" OnClick="SaveConsultant" CausesValidation="true" OnClientClicked="CheckForValidPage" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>

        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="false" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="HospitalRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="550px" Height="470px" VisibleStatusbar="false" Title="Add Hospital">
                    <ContentTemplate>
                        <table cellspacing="3" cellpadding="3">
                            <tr>
                                <td>
                                    <div>
                                        <table>
                                            <tr>
                                                <td>
                                                    <telerik:RadTextBox ID="NewHospitalTextBox" runat="server" Width="200" EmptyMessage="Enter new hospital name" Skin="Vista" />
                                                </td>
                                                <td>
                                                    <%--<asp:TextBox ID="NewHospitalTextBox" runat="server" Width="200px"/>--%>
                                                    <telerik:RadButton ID="NewHospitalRadButton" runat="server" Text="Add new hospital" Skin="WebBlue" OnClick="SaveHospital" />
                                                     </td>
                                                    <td>
                                                        <telerik:RadButton ID="SuppressRadButton" runat="server" Text="Suppress hospital" Skin="WebBlue" OnClick="SuppressHospital" Enabled="false" />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <telerik:RadGrid ID="HospitalsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" DataSourceID="HospitalObjectDataSource" Skin="Office2007" PageSize="10" Width="275px" AllowPaging="true" Style="margin-bottom: 10px;">
                                        <HeaderStyle Font-Bold="true" />
                                        <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="HospitalID,Suppressed" DataKeyNames="HospitalID,Suppressed" TableLayout="Fixed" EnableNoRecordsTemplate="true">
                                            <Columns>
                                                <telerik:GridBoundColumn DataField="HospitalName" HeaderText="Hospital Name" SortExpression="HospitalName" HeaderStyle-Width="300px" />
                                                <telerik:GridBoundColumn DataField="Suppressed" HeaderText="Suppressed" SortExpression="Suppressed" HeaderStyle-Width="150px" />
                                            </Columns>
                                            <NoRecordsTemplate>
                                                <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                                    No Hospitals found.
                                                </div>
                                            </NoRecordsTemplate>
                                        </MasterTableView>
                                        <PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Hospitals {2} to {3} of {5}" />
                                        <ClientSettings ClientEvents-OnRowSelected="showSelected">
                                            <Selecting AllowRowSelect="True" />
                                        </ClientSettings>
                                    </telerik:RadGrid>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                        <telerik:RadButton ID="SaveHospitalCancel" runat="server" Text="Close" Skin="WebBlue" AutoPostBack="false" OnClientClicked="closeHospital" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="GroupRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="450px" Height="170px" VisibleStatusbar="false" Title="Add Speciality">
                    <ContentTemplate>
                        <telerik:RadFormDecorator runat="server" Skin="Metro" DecorationZoneID="NewSpecialtyWindow" DecoratedControls="All" />
                        <div style="padding-left: 10px" id="NewSpecialtyWindow">
                            <table cellpadding="5" cellspacing="5">
                                <tr>
                                    <td>Specialty:
                                    </td>
                                    <td>
                                        <telerik:RadTextBox ID="NewGroupTextBox" runat="server" Width="200px" />
                                        <asp:RequiredFieldValidator runat="server" ControlToValidate="NewGroupTextBox" ErrorMessage="Specialty is required" Text="*" ForeColor="Red" Display="Dynamic" ValidationGroup="NewSpecialty" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Specialty Code:
                                    </td>
                                    <td>
                                        <telerik:RadTextBox ID="NewSpecialtyCodeRadTextBox" runat="server" Width="200px" />
                                        <asp:RequiredFieldValidator runat="server" ControlToValidate="NewSpecialtyCodeRadTextBox" ErrorMessage="Specialty code is required" Text="*" ForeColor="Red" Display="Dynamic" ValidationGroup="NewSpecialty" />
                                        <asp:CompareValidator ID="RegularExpressionValidator1" runat="server" CssClass="aspxValidator"
                                            ControlToValidate="NewSpecialtyCodeRadTextBox" EnableClientScript="true" Display="Dynamic"
                                            ErrorMessage="Specialty code must be a numeric value." Text="*" ToolTip="Numeric values only"
                                            ValidationGroup="NewSpecialty" Type="Integer" Operator="DataTypeCheck" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div id="groupdiv" style="height: 10px; padding-top: 10px; padding-left: 10px; vertical-align: central; text-align: center;">
                            <telerik:RadButton ID="NewGroupRadButton" runat="server" Text="Save" Skin="WebBlue" OnClick="NewGroupRadButton_Click" OnClientClicked="CheckForValidSpecialty" ValidationGroup="NewSpecialty" />
                            &nbsp;
                            <telerik:RadButton ID="groupRadButton" runat="server" Text="Close" Skin="WebBlue" AutoPostBack="false" OnClientClicked="closeGroup" CausesValidation="false" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
        <telerik:RadNotification ID="ValidationNotification" runat="server" Animation="None" Width="400"
            EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
            LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
            AutoCloseDelay="7000">
            <ContentTemplate>
                <asp:ValidationSummary ID="SaveConsultantValidationSummary" runat="server" ValidationGroup="SaveConsultant" DisplayMode="BulletList"
                    EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                <asp:ValidationSummary ID="SaveSpecialtyValidationSummary" runat="server" ValidationGroup="NewSpecialty" DisplayMode="BulletList"
                    EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                <asp:Label ID="ServerErrorLabel" runat="server" CssClass="aspxValidationSummary" Visible="false"></asp:Label>
            </ContentTemplate>
        </telerik:RadNotification>
    </form>
</body>
</html>
