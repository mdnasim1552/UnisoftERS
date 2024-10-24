<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_PatientDetails" CodeBehind="PatientDetails.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../Styles/Site.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-ui.min.js"></script>

    <style type="text/css">
        .rcbSlide {
            z-index: 999999 !important;
        }

        .rgRow td {
            border-bottom: 1px solid #ededed !important;
        }

        .rgHeaderDiv {
            margin-right: 0 !important;
            padding-right: 0px !important;
            background-color: #f9fafb !important;
        }
    </style>
</head>
<body>
    <form id="mainForm" runat="server" autocomplete="off">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <script type="text/javascript">
            function validateForm(sender, args) {
                validatePage(sender, args)
                //validate GP exists or no GP selected
                if (document.getElementById('<%= Fieldset1.ClientID%>').style.display != 'none') {
                    if ($find('<%= GPRadSearchBox.ClientID%>').get_text() != "" && $('#<%=GPIDHiddenField.ClientID%>').val() == "") {
                        $('#<%= GPRadSearchBox.ClientID%>').addClass('validation-error-field');
                        $('#masterValDiv', parent.document).html("Please use the GP search function choose the correct GP or select 'No GP' if unknown");
                        $('#ValidationNotification', parent.document).show();
                        $('.validation-modal', parent.document).show();
                        args.set_cancel(true);
                    }
                    else if ($('#<%=GPIDHiddenField.ClientID%>').val() == "" && $('#<%=NoGPCheckBox.ClientID%>').attr('checked') == false) {
                        $('#<%= GPRadSearchBox.ClientID%>').addClass('validation-error-field');
                        $('#masterValDiv', parent.document).html("GP required or select 'No GP' if unknown");
                        $('#ValidationNotification', parent.document).show();
                        $('.validation-modal', parent.document).show();
                        if (args != null)
                            args.set_cancel(true);
                    }
                }
            }

            var patValidated = false;
            function checkPatientExists() {
                var forename = $find('<%=ForenameTextBox.ClientID%>').get_textBoxValue();
                var surname = $find('<%=SurnameTextBox.ClientID%>').get_textBoxValue();
                var dob = $find('<%=DobDateInput.ClientID%>').get_textBoxValue();
                var cnn = $find('<%=CaseNoteNoTextBox.ClientID%>').get_textBoxValue();
                //var nhsNo = $find('<%=NhsNoTextBox.ClientID%>').get_textBoxValue();
                if (forename != "" && surname != "" && dob != "" && cnn != "") {

                    var obj = {
                        "forename": forename,
                        "surname": surname,
                        "dob": dob,
                        "cnn": cnn
                    };

                    $.ajax({
                        type: "POST",
                        url: webMethodLocation + "PatientExists",
                        data: JSON.stringify(obj),
                        dataType: "json",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {
                            patValidated = true;
                            if (data.d) {
                                $find('<%=ErrorRadNotification.ClientID%>').set_text("Patient already exists. Please use the search facilities to load the patients details.");
                                $find('<%=ErrorRadNotification.ClientID%>').show();
                            }
                        }
                    });
                }
            }

            function searchGP(sender, args) {
                var searchBox = $find('<%= GPRadSearchBox.ClientID%>');
                if (searchBox.get_text().length < 3) {
                    $find('<%=RadNotification1.ClientID%>').set_text("Enter a search term of more the 3 characters");
                    $find('<%=RadNotification1.ClientID%>').show();
                    arg.set_cancel(true);
                }

                var searchContext = searchBox.get_searchContext();
                var contextValue = "ALL";

                if (searchContext.get_selectedItem() != undefined)
                    contextValue = searchContext.get_selectedItem().get_text();

                if ((searchBox.get_text().trim() != "")) {
                    var url = "<%= ResolveUrl("~/Products/Common/GPList.aspx?searchstr={0}&searchval={1}")%>";
                    url = url.replace("{0}", searchBox.get_text().trim());
                    url = url.replace("{1}", contextValue);

                    var oWnd = $find("<%= SearchGPWindow.ClientID %>");
                    oWnd._navigateUrl = url
                    oWnd.set_title("Choose GP");
                    oWnd.SetSize(750, 350);

                    //Add the name of the function to be executed when RadWindow is closed.
                    oWnd.add_close(OnClientClose);
                    oWnd.show();
                }
            }

          <%--  function updateGrid(result) {

                var masterTable = $find("<%= PatientsListGrid.ClientID %>").get_masterTableView();
                masterTable.set_dataSource(result);
                masterTable.dataBind();
            }--%>

            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow;
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow;
                return oWindow;
            }

            function CloseDialog() {
                GetRadWindow().close();
            }

            function OpenGPWindow() {
                var oWnd2 = $find("<%= EditGPWindow.ClientID %>");
                oWnd2._navigateUrl = "<%= ResolveUrl("~/Products/Common/GPDetails.aspx")%>";

                //Add the name of the function to be executed when RadWindow is closed.
                oWnd2.add_close(OnClientClose);
                oWnd2.show();
            }

            function OnClientClose(oWnd, eventArgs) {
                //Remove the OnClientClose function to avoid
                //adding it for a second time when the window is shown again.
                oWnd.remove_close(OnClientClose);

                RefreshSiteSummary();
            }

            function CloseGPWindow() {
                var oWnd = $find("<%= EditGPWindow.ClientID %>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function CloseDuplicatePatientWindow() {
                var oWnd = $find("<%= ExistingPatientWindow.ClientID %>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function RefreshSiteSummary() {
                $find("<%=PatDetailsAjaxManager.ClientID%>").ajaxRequest();
            }

            function CheckForValidPage(button) {
                var valid = Page_ClientValidate("SavePatient");
                if (!valid) {
                    $find("<%=SavePatientNotification.ClientID%>").show();
                }
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

            var docURL = document.URL;
            var webMethodLocation = docURL.slice(0, docURL.indexOf("/Products/Common/")) + "/Products/Default.aspx/";
            $(document).ready(function () {
                Sys.Application.add_load(function () {
                    $('#<%=NoGPCheckBox.ClientID%>').on('change', function () {
                        toggleGPName();
                    });

                    $('#<%=NhsNoTextBox.ClientID%>').on('focusin', function () {
                        if (!patValidated)
                            checkPatientExists();
                    });

                    $('.patientchecktrigger').on('keydown', function () {
                        patValidated = false;
                    });
                });
            });

            function toggleGPName() {
                if ($('#<%=NoGPCheckBox.ClientID%>').is(":checked")) {
                    $find('<%=GPRadSearchBox.ClientID%>').set_enabled(false);
                    $find('<%=AddNewGPButton.ClientID%>').set_enabled(false);
                    //ajax call to set hidden field value to 'Not Specified' GP ID
                    $.ajax({
                        type: "POST",
                        url: webMethodLocation + "GetNOGPCode",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            if (data.d != null)
                                $('#<%=GPIDHiddenField.ClientID%>').val(data.d);
                        }
                    });

                    //remove search box from reqFields object array (if exists)

                }
                else {
                    $find('<%=GPRadSearchBox.ClientID%>').set_enabled(true);
                    $find('<%=AddNewGPButton.ClientID%>').set_enabled(true);
                    $('#<%=GPIDHiddenField.ClientID%>').val("");
                    //add search box to reqFields object array

                }
            }
            function checkText(sender, eventArgs) {
                var char = eventArgs.get_keyCharacter();
	    
                var exp = /[^a-zA-Z\u00C0-\u017F-']/g;
                if (exp.test(char)) {
                    eventArgs.set_cancel(true);
                }
            }

        </script>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="ErrorRadNotification" ShowCloseButton="true" AutoCloseDelay="0" runat="server" VisibleOnPageLoad="false" Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>" Position="Center" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>" Position="Center" />
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="760px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="480px" Scrolling="Y">
                <div id="FormDiv" runat="server" style="color: black; padding-left: 10px;">

                    <div style="margin-left: 10px; margin-top: 10px; margin-bottom: 15px; font-style: italic;">
                        <div id="LastModifiedDiv" runat="server">
                            Last modified : &nbsp;&nbsp;&nbsp;
                            <asp:Label ID="LastModifiedLabel" runat="server" Text='Not known' />
                        </div>
                    </div>

                    <fieldset id="PlannedProceduresFieldset" runat="server">
                        <legend>Patient Details</legend>
                        <table cellspacing="1" cellpadding="1" style="width: 100%;">
                            <tr style="vertical-align: top;">
                                <td style="width: 50%;">
                                    <table cellspacing="1" cellpadding="1" border="0">
                                        <tr>
                                            <td style="width: 100px;">
                                                <asp:Label ID="lblPatientTitle" runat="server" Text="Title :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="TitleTextBox" runat="server" Width="50" />
                                                <asp:RequiredFieldValidator ID="TitleRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                    ControlToValidate="TitleTextBox" EnableClientScript="true" Display="Dynamic"
                                                    ErrorMessage="Title is required" Text="*" ToolTip="This is a required field"
                                                    ValidationGroup="SavePatient">
                                                </asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientForname" runat="server" Text="Forename :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="ForenameTextBox" runat="server" Width="160" >
                                                    <ClientEvents OnKeyPress="checkText" />
                                                </telerik:RadTextBox>
                                                <asp:RequiredFieldValidator ID="ForenameRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                    ControlToValidate="ForenameTextBox" EnableClientScript="true" Display="Dynamic"
                                                    ErrorMessage="Forename is required" Text="*" ToolTip="This is a required field"
                                                    ValidationGroup="SavePatient">
                                                </asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientSurname" runat="server" Text="Surname :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="SurnameTextBox" runat="server" Width="160">
                                                    <ClientEvents OnKeyPress="checkText" />
                                                </telerik:RadTextBox>
                                                <asp:RequiredFieldValidator ID="SurnameRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                    ControlToValidate="SurnameTextBox" EnableClientScript="true" Display="Dynamic"
                                                    ErrorMessage="Surname is required" Text="*" ToolTip="This is a required field"
                                                    ValidationGroup="SavePatient">
                                                </asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientDOB" runat="server" Text="Date of birth :" /></td>
                                            <td>
                                                <telerik:RadDateInput ID="DobDateInput" runat="server" Width="80" Culture="en-GB" CssClass="patientchecktrigger" />
                                                <asp:RequiredFieldValidator ID="DobRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                    ControlToValidate="DobDateInput" EnableClientScript="true" Display="Dynamic"
                                                    ErrorMessage="Date of Birth is required" Text="*" ToolTip="This is a required field"
                                                    ValidationGroup="SavePatient">
                                                </asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientCaseNoteNo" runat="server" Text="Hospital no :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="CaseNoteNoTextBox" runat="server" Width="110" CssClass="patientchecktrigger" />
                                                <asp:RequiredFieldValidator ID="CaseNoteNoRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                    ControlToValidate="CaseNoteNoTextBox" EnableClientScript="true" Display="Dynamic"
                                                    ErrorMessage="Hospital no is required" Text="*" ToolTip="This is a required field"
                                                    ValidationGroup="SavePatient">
                                                </asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientNHSNo" runat="server" Text="NHS no :" CssClass="patientchecktrigger" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="NhsNoTextBox" runat="server" Width="110" /></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientDistrict" runat="server" Text="District :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="DistrictTextBox" runat="server" Width="160" /></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientGender" runat="server" Text="Gender :" /></td>
                                            <td>
                                                <%--                            <asp:RadioButtonList ID="GenderRadioButtonList" runat="server"
                                                    RepeatDirection="Horizontal" RepeatLayout="Table" Style="margin-left: -5px;">
                                                    <asp:ListItem Value="M" Text="Male"></asp:ListItem>
                                                    <asp:ListItem Value="F" Text="Female"></asp:ListItem>
                                                </asp:RadioButtonList>
                                                --%>
                                                <asp:RadioButtonList ID="GenderRadioButtonList" runat="server" AutoPostBack="false" Skin="Metro" RepeatDirection="Horizontal">
                                                    <asp:ListItem Text="Male" Value="M" />
                                                    <asp:ListItem Text="Female" Value="F" />
                                                </asp:RadioButtonList>
                                                <%--                        <telerik:RadButton ID="GenderRadioButtonList_M" runat="server" ToggleType="Radio" ButtonType="ToggleButton" ForeColor="Black" Style="margin-right: 15px;"
                                                    Value="M" Text="Male" GroupName="StandardButton" AutoPostBack="false" />
                                                <telerik:RadButton ID="GenderRadioButtonList_F" runat="server" ToggleType="Radio" ButtonType="ToggleButton" ForeColor="Black"
                                                    Value="F" Text="Female" GroupName="StandardButton" AutoPostBack="false" />--%>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientEthnicity" runat="server" Text="Ethnic Origin :" /></td>
                                            <td>
                                                <telerik:RadComboBox ID="EthnicOriginComboBox" runat="server" Width="160" Skin="Windows7">
                                                    <Items>
                                                        <telerik:RadComboBoxItem Text="" Value="0" />
                                                        <telerik:RadComboBoxItem Text="White" Value="1" />
                                                        <telerik:RadComboBoxItem Text="Black" Value="2" />
                                                        <telerik:RadComboBoxItem Text="Brown" Value="3" />
                                                        <telerik:RadComboBoxItem Text="Green" Value="4" />
                                                    </Items>
                                                </telerik:RadComboBox>
                                            </td>
                                        </tr>
                                        <%--Added by rony tfs-4206--%>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientEmail" runat="server" Text="Email :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="EmailTextBox" runat="server" Width="160" /></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientTelNo" runat="server" Text="Telephone no :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="TelephoneNoTextBox" runat="server" Width="160" /></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientMobileNo" runat="server" Text="Mobile no :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="MobileNoTextBox" runat="server" Width="160" /></td>
                                        </tr>
                                    </table>
                                </td>
                                <td>
                                    <table cellspacing="1" cellpadding="1">
                                        <tr style="vertical-align: top;">
                                            <td style="width: 110px;">
                                                <asp:Label ID="lblPatientAddress" runat="server" Text="Address :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="PatAddressTextBox" runat="server" Width="160" /></td>
                                        </tr>
                                        <tr style="vertical-align: top;">
                                            <td style="width: 110px;"></td>
                                            <td>
                                                <telerik:RadTextBox ID="PatAddress2TextBox" runat="server" Width="160" /></td>
                                        </tr>
                                        <tr>
                                            <td style="width: 110px;">
                                                <asp:Label ID="lblPatientAddressTown" runat="server" Text="Town :" />
                                            </td>
                                            <td>
                                                <telerik:RadTextBox ID="PatAddressTownTextBox" runat="server" Width="160" /></td>

                                        </tr>
                                        <tr>
                                            <td style="width: 110px;">
                                                <asp:Label ID="lblPatientAddressCounty" runat="server" Text="County :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="PatAddressCountyTextBox" runat="server" Width="160" />

                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientPostCode" runat="server" Text="Postcode :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="PostCodeTextBox" runat="server" Width="70" /></td>
                                        </tr>
                                        <tr>
                                            <td style="height: 20px;"></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientDHACode" runat="server" Text="DHA Code :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="DhaCodeTextBox" runat="server" Width="70" />
                                                (contracts code)
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientAdvocateRequired" runat="server" Text="Advocate required :" />
                                            </td>
                                            <td>
                                                <telerik:RadButton ID="AdvocateRequiredCheckBox" runat="server" Text="" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Black" AutoPostBack="false" Style="margin-left: -3px;"></telerik:RadButton>
                                                <%--<asp:CheckBox ID="AdvocateRequiredCheckBox" runat="server" Text="" Style="margin-left: -3px;" /> --%>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientDOD" runat="server" Text="Date of death :" /></td>
                                            <td>
                                                <telerik:RadDatePicker ID="DodDateInput" runat="server" Width="100px" Skin="Windows7" Culture="en-GB" DateInput-DateFormat="dd/MM/yyyy" DateInput-DisplayDateFormat="dd/MM/yyyy" />
                                                <%--                   <telerik:RadDateInput ID="DodDateInput" runat="server" Width="80"
                                                    Culture="en-GB" DateFormat="dd/MM/yyyy" />--%>
                                            </td>
                                        </tr>
                                        <%--Added by rony tfs-4206--%>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientKentOfKin" runat="server" Text="Next of Kin :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="KentOfKinTextBox" runat="server" Width="160" /></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label ID="lblPatientModalities" runat="server" Text="Modality :" /></td>
                                            <td>
                                                <telerik:RadTextBox ID="ModalitiesTextBox" runat="server" Width="160" /></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </fieldset>

                    <fieldset id="Fieldset1" runat="server">
                        <legend>GP Details</legend>
                        <table cellspacing="1" cellpadding="1" border="0" style="width: 100%;">
                            <tr>
                                <td style="width: 165px;">
                                    <telerik:RadSearchBox runat="server" ID="GPRadSearchBox"
                                        CssClass="searchBox" Skin="Metro"
                                        Width="370" DropDownSettings-Height="300"
                                        EmptyMessage="Search"
                                        Filter="Contains"
                                        MaxResultCount="20" EnableAutoComplete="false" OnClientSearch="searchGP">
                                        <SearchContext DropDownCssClass="contextDropDown">
                                            <Items>
                                                <telerik:SearchContextItem Text="GP Name" Key="1" Selected="true" />
                                                <telerik:SearchContextItem Text="National Code" Key="2" />
                                                <telerik:SearchContextItem Text="Practice Name" Key="3" />
                                            </Items>
                                        </SearchContext>
                                    </telerik:RadSearchBox>
                                    <asp:HiddenField ID="GPIDHiddenField" runat="server" />
                                    <asp:HiddenField ID="PracticeIDHiddenField" runat="server" />
                                </td>
                                <td>
                                    <telerik:RadButton ID="AddNewGPButton" runat="server" Text="Add GP"
                                        OnClientClicked="OpenGPWindow" AutoPostBack="false"
                                        Skin="Office2007" Visible="false" />
                                    &nbsp;<asp:CheckBox ID="NoGPCheckBox" runat="server" Text="No GP" />
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
            </telerik:RadPane>

            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
                <div style="height: 10px; margin-left: 10px; padding-top: 2px; padding-bottom: 2px; padding-left: 10px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" OnClientClicked="validateForm" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    &nbsp;&nbsp;
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20"
                        AutoPostBack="false" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>

                <telerik:RadNotification ID="SavePatientNotification" runat="server" Animation="None"
                    EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                    LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
                    AutoCloseDelay="70000">
                    <ContentTemplate>
                        <asp:ValidationSummary ID="SavePatientValidationSummary" runat="server" ValidationGroup="SavePatient" DisplayMode="BulletList"
                            EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                    </ContentTemplate>
                </telerik:RadNotification>
            </telerik:RadPane>
        </telerik:RadSplitter>

        <telerik:RadWindowManager ID="AddNewGPRadWindowManager" runat="server"
            Style="z-index: 7001" Behaviors="Close, Move" AutoSize="false" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="EditGPWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
                    Width="700px" Height="300px" Title="GP Records Maintenance" VisibleStatusbar="false"
                    NavigateUrl="~/Products/Common/GPDetails.aspx" />
                <telerik:RadWindow ID="SearchGPWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
                    Title="GP Search Results" VisibleStatusbar="false" />
                <telerik:RadWindow ID="ExistingPatientWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true"
                    Title="Existing patient found" VisibleStatusbar="false">
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>

        <telerik:RadAjaxManager ID="PatDetailsAjaxManager" runat="server" OnAjaxRequest="PatDetailsAjaxManager_AjaxRequest">
            <AjaxSettings>

                <%--This is to update on ClientClose event of GP Details rad window--%>
                <telerik:AjaxSetting AjaxControlID="PatDetailsAjaxManager">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GPRadSearchBox" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="PatDetailsAjaxManager">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GPIDHiddenField" />
                        <telerik:AjaxUpdatedControl ControlID="PracticeIDHiddenField" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <%--This is to update on ClientClose event of GP Details rad window--%>
                <telerik:AjaxSetting AjaxControlID="PatDetailsAjaxManager">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GPAddressTextBox" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
    </form>
</body>
</html>
