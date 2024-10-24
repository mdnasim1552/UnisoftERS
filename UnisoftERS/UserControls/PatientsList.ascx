<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="PatientsList.ascx.vb" Inherits="UnisoftERS.PatientsList" %>
<telerik:RadScriptBlock ID="rad1" runat="server">

    <style type="text/css">
        .tblSearchBy td {
            padding-top: 7px;
        }

        /*RadRadioButton - Choose between AND/OR filter*/
        .RadRadioButton span.rbText {
            margin-left: -23px;
            color: #8c8c8c !important;
        }

        .RadPatientButton span.rbPrimaryIcon {
            border-left: 2px solid #7eb3bc;
            background-color: #e7e7e7;
            margin: -2px 0 0 -14px;
            width: 20px;
            padding: 5px 17px 4px 7px;
            background-position: center;
        }
    </style>

    <script type="text/javascript">

        $(document).ready(function () {
        });

        function clearSearchFields() {
            //$('.tblSearchBy input[type="text"]').val(''); //sets textbox to empty, does not put placeholders back in place

            var cnn = $find('<%= CaseNoteNoTextBox.ClientID%>');
            if (cnn)
                cnn.clear(); //clears text and puts placeholders back in place

            var countryOfOriginHealthServiceNo = $find('<%= CountryOfOriginHealthServiceNoRadTextBox.ClientID%>');
            if (countryOfOriginHealthServiceNo)
                countryOfOriginHealthServiceNo.clear();

            var surname = $find('<%= SurnameTextBox.ClientID%>');
            if (surname)
                surname.clear();

            var forename = $find('<%= ForenameTextBox.ClientID%>');
            if (forename)
                forename.clear();

            var dob = $find('<%= DOBTextBox.ClientID%>');
            if (dob)
                dob.clear();

            var gender = $find('<%= GenderCombobox.ClientID%>')
            if (gender)
                gender.clear();

            var incDeceased = $('#<%= IncludeDeceasedCheckbox.ClientID%>')
            if (incDeceased)
                incDeceased.prop("checked", false);

            <%--var globalSearch = $find('<%= RadSearchBox1.ClientID%>');
            if (globalSearch && globalSearch.get_text() != "")
                globalSearch.set_emptyMessage("Search");--%>

            clearPatientList();
        }

      <%--  function validateSearchField(sender, args) {
            sender._element.control._postBackOnSearch = true; //set here as default incase set to false previoulsy due to invalid search attempt

            var searchBox = $find('<%= RadSearchBox1.ClientID%>');

            if ((searchBox.get_text().trim() == "")) {
                var notification = $find("<%= SearchFieldsRadNotification.ClientID %>");
                notification.set_title("Search Error");
                notification.show();

                sender._element.control._postBackOnSearch = false;
            }
        }--%>

        function validateSearchFields(sender, args) {
            
            var cnn = $find('<%= CaseNoteNoTextBox.ClientID%>');
            var countryOfOriginHealthServiceNo = $find('<%= CountryOfOriginHealthServiceNoRadTextBox.ClientID%>');
            var surname = $find('<%= SurnameTextBox.ClientID%>');
            var forename = $find('<%= ForenameTextBox.ClientID%>');
            var dob = $find('<%= DOBTextBox.ClientID%>');
            var gender = $find('<%= GenderCombobox.ClientID%>');         
            
           

            //Mahfuz added Minimum search criteria taken from System Config database  - for D&G Scotland
            var minoptionsprovided = 0;
            var minSearchOptionRequired = <%= intMinSearchOptionRequired%>;

            if (cnn.get_textBoxValue() != cnn.get_emptyMessage() && cnn.get_textBoxValue().trim().length > 2) minoptionsprovided = minoptionsprovided + minSearchOptionRequired;
            if (countryOfOriginHealthServiceNo.get_textBoxValue() != countryOfOriginHealthServiceNo.get_emptyMessage() && countryOfOriginHealthServiceNo.get_textBoxValue().trim().length > 2) minoptionsprovided = minoptionsprovided + minSearchOptionRequired;
            if (surname.get_textBoxValue() != surname.get_emptyMessage() && surname.get_textBoxValue().trim().length > 2) minoptionsprovided++;
            if (forename.get_textBoxValue() != forename.get_emptyMessage() && forename.get_textBoxValue().trim().length > 2) minoptionsprovided++;
            if (dob.get_dateInput().get_value() != null && dob.get_dateInput().get_value().trim() != "") minoptionsprovided++;
            if (gender.get_value() != null && gender.get_value().trim() != "") minoptionsprovided++;
            //if (address.get_textBoxValue() != address.get_emptyMessage() && address.get_textBoxValue().trim().length > 2) minoptionsprovided++;                 
            //if (postcode.get_textBoxValue() != postcode.get_emptyMessage() && postcode.get_textBoxValue().trim().length > 2) minoptionsprovided++;
           

                      
            //alert(minoptionsprovided);

            if ((cnn.get_textBoxValue() == cnn.get_emptyMessage() || cnn.get_textBoxValue().trim() == "") &&
                (countryOfOriginHealthServiceNo.get_textBoxValue() == countryOfOriginHealthServiceNo.get_emptyMessage() || countryOfOriginHealthServiceNo.get_textBoxValue().trim() == "") &&
                (surname.get_textBoxValue() == surname.get_emptyMessage() || surname.get_textBoxValue().trim() == "") &&
                (forename.get_textBoxValue() == forename.get_emptyMessage() || forename.get_textBoxValue().trim() == "") &&
                (dob.get_dateInput().get_value().trim() == "") &&
                (gender.get_value().trim() == "")){
                //(address.get_textBoxValue() == address.get_emptyMessage() || address.get_textBoxValue().trim() == "") &&
                //(postcode.get_textBoxValue() == postcode.get_emptyMessage() || postcode.get_textBoxValue().trim() == "")) {
            
                var notification = $find("<%= SearchFieldsRadNotification.ClientID %>");
                //notification.set_title("Search Error");
                notification.set_text("Please enter a search term using " + minSearchOptionRequired.toString() + " or more of the fields provided");
                notification.show();

                args.set_cancel(true);
             }
            else if (cnn.get_textBoxValue().trim().length < 3 || countryOfOriginHealthServiceNo.get_textBoxValue().trim().length < 3 ||
                surname.get_textBoxValue().trim().length < 3 || forename.get_textBoxValue().trim().length < 3) {
                //address.get_textBoxValue().trim().length < 3 || postcode.get_textBoxValue().trim().lenght < 3) {

                var notification = $find("<%= SearchFieldsRadNotification.ClientID %>");
                //notification.set_title("Search Error");
                notification.set_text("Enter a search term of more than 3 characters");
                notification.show();

                arg.set_cancel(true);          
            }


            else if (minoptionsprovided < minSearchOptionRequired) {
                //alert(minoptionsprovided);
                var notification = $find("<%= SearchFieldsRadNotification.ClientID %>");
                //notification.set_title("Search Error");
                notification.set_text("Provide at least " + minSearchOptionRequired.toString() + " search criteria options");
                notification.show();

                arg.set_cancel(true);
            }
        }

        function refreshGrid(arg) {
            window.location.reload();
        }
    </script>

</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
<telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="MainContainer" Skin="Metro" />
<telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

<div id="MainContainer">
    <table style="margin-left: 3px;">
        <tr>
            <td>

                <div style="background-color: white; color: #4888a2; font-size: 1.2em;">
                    Patient Search
                </div>

                <div class="lblText" style="margin-bottom: 8px; height: 1px; background: #a9b6c7; background: -webkit-gradient(linear, 0 0, 100% 0, from(white), to(white), color-stop(0%, #a9b6c7));">
                </div>

                <div id="divSearchFields" runat="server" class="divSearchBox" style="margin-top: 15px;">
                    <telerik:RadNotification ID="SearchFieldsRadNotification" runat="server" Animation="None"
                        EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                        LoadContentOn="PageLoad"  Position="Center"
                        Skin="Silk" Width="500px" />
                       <%-- <ContentTemplate>
                            <div style="padding: 10px;">
                                <p>
                                    Please enter a search term using one or more of the fields provided
                                </p>
                            </div>
                        </ContentTemplate>
                    </telerik:RadNotification>--%>

                    <div class="lblText" style="margin: 5px 6px; color: #0072c6;">
                        <i>Search by</i>&nbsp;&nbsp;
                        <div style="float: right; padding-right: 5px;">
                            <asp:RadioButtonList  runat="server" ID="RblSearch" RepeatDirection="Horizontal" ToolTip="Filter for textboxes below.">
                                <asp:ListItem Text="And" Selected="true" />
                                <asp:ListItem Text="Or" />
                            </asp:RadioButtonList>
                        </div>

                        <%--<div style="float: right; padding-right: 5px;">
                            <span style="font-size:12px;">Filter:</span>&nbsp;
                            <telerik:RadComboBox runat="server" ID="radCBSearchType" Width="100" BorderWidth="0" BorderStyle="None" ToolTip="Filter for all the available textboxes.">
                                <Items>
                                    <telerik:RadComboBoxItem Text="EqualTo" />
                                    <telerik:RadComboBoxItem Text="Contains" />
                                    <telerik:RadComboBoxItem Text="StartsWith" />
                                    <telerik:RadComboBoxItem Text="EndsWith" />
                                </Items>
                            </telerik:RadComboBox>

                        </div>--%>
                    </div>
                    <div class="lblText" style="margin: 5px 6px; color: #0072c6; background-image: url(../Images/foot-bg.jpg); background-repeat: repeat-x; height: 1px;">
                    </div>

                    <%--      <div class="lblText" style="margin: 5px 6px; height: 0px;">
                    </div>--%>

                    <%--     <asp:Panel ID="pnlSearchBox" runat="server" DefaultButton="SearchButton">
                        <div class="lblText" style="margin: 15px 6px; color: #ffffff;">
                            <telerik:RadSearchBox runat="server" ID="RadSearchBox1"
                                CssClass="searchBox" Skin="Silk"
                                Width="262" DropDownSettings-Height="300"
                                EmptyMessage="Search"
                                Filter="StartsWith"
                                OnSearch="RadSearchBox1_Search"
                                MaxResultCount="20" EnableAutoComplete="false" OnClientSearch="validateSearchField">
                                <SearchContext DropDownCssClass="contextDropDown">
                                    <Items>
                                        <telerik:SearchContextItem Text="Case note no" Key="1" />
                                        <telerik:SearchContextItem Text="NHS No" Key="2" />
                                        <telerik:SearchContextItem Text="Surname" Key="3" />
                                        <telerik:SearchContextItem Text="Forename" Key="4" />
                                    </Items>
                                </SearchContext>
                            </telerik:RadSearchBox>
                        </div>
                    </asp:Panel>--%>
                    <asp:Panel ID="pnlSearchFields" runat="server" DefaultButton="SearchButton">
                        <table style="width: 268px; padding-left: 10px;" class="tblSearchBy">
                            <tr>
                                <td align="right">
                                    <telerik:RadTextBox ID="CaseNoteNoTextBox" runat="server" Width="255px" EmptyMessage="Enter [Hospital No]" Skin="Vista" MaxLength="30" Label="Hospital No.:" LabelWidth="90" LabelCssClass="txtLabelStyle" />
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <telerik:RadTextBox ID="CountryOfOriginHealthServiceNoRadTextBox" runat="server" Width="255px" EmptyMessage="Enter [HS no]" Skin="Vista" MaxLength="30" Label="HS no.:" LabelWidth="90" LabelCssClass="txtLabelStyle" />
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <telerik:RadTextBox ID="SurnameTextBox" runat="server" Width="255px" EmptyMessage="Enter [Surname]" Skin="Vista" MaxLength="30" Label="Surname:" LabelWidth="90" LabelCssClass="txtLabelStyle" />
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <telerik:RadTextBox ID="ForenameTextBox" runat="server" Width="255px" EmptyMessage="Enter [Forename]" Skin="Vista" MaxLength="30" Label="Forename:" LabelWidth="90" LabelCssClass="txtLabelStyle" />
                                </td>
                            </tr>
                            <tr>
                                <td align="left">
                                    <label class="riLabel txtLabelStyle riSingle RadInput RadInput_Metro" style="width: 87px;">Date of birth:</label>
                                    <telerik:RadDatePicker ID="DOBTextBox" runat="server" Skin="Vista" DateInput-EmptyMessage="Enter [DD/MM/YYYY]" FocusedDate="01/01/1990" MinDate="01/01/1900" DateInput-DateFormat="dd/MM/yyyy" />
                                </td>
                            </tr>
                             <tr>
                                 <td align="right">
                                     <telerik:RadTextBox  ID="PostCodeTextBox" Visible="false" runat="server" Width="255px" EmptyMessage="Enter [Postcode]" Skin="Vista" MaxLength="30" Label="Postcode:" LabelWidth="90" LabelCssClass="txtLabelStyle" />
                                 </td>
                             </tr>
                            <tr>
                                <td align="left">
                                    <label class="riLabel txtLabelStyle riSingle RadInput RadInput_Metro" style="width: 87px;">Gender:</label>
                                    <telerik:RadComboBox ID="GenderCombobox" runat="server" Width="150px" EmptyMessage="Enter Gender" Skin="Vista" MaxLength="30" Label="" LabelWidth="90" LabelCssClass="txtLabelStyle">
                                        <Items>
                                            <telerik:RadComboBoxItem runat="server" Text="" Value="" />
                                            <telerik:RadComboBoxItem runat="server" Text="Male" Value="M" />
                                            <telerik:RadComboBoxItem runat="server" Text="Female" Value="F" />
                                        </Items>
                                    </telerik:RadComboBox>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    <telerik:RadTextBox Visible="false" ID="AddressTextBox" runat="server" Width="255px" EmptyMessage="Enter [Address]" Skin="Vista" MaxLength="30" Label="Address line 1:" LabelWidth="90" LabelCssClass="txtLabelStyle" />
                                </td>
                            </tr>                           
                            <tr>
                                <td align="left" valign="top">
                                    <asp:CheckBox ID="IncludeDeceasedCheckbox" runat="server" Text=" Include deceased:" TextAlign="Left" skin="Metro" />
                                </td>
                            </tr>
                        </table>
                        <div id="searchButtons" style="padding: 15px 7px 6px 0px; text-align: right;">
                            <telerik:RadButton ID="SearchButton" runat="server" Text="Search" Font-Bold="true" Skin="Metro" OnClientClicking="validateSearchFields"
                                CssClass="rbPrimaryButton" RenderMode="Lightweight" />
                            <telerik:RadButton ID="ResetButton" runat="server" Text="Clear" Skin="Metro" OnClientClicked="clearSearchFields" RenderMode="Lightweight" BorderStyle="Solid" BorderColor="#cccccc"
                                Width="40px" AutoPostBack="false" />
                        </div>
                        <div class="SearchValidationError">
                            <asp:Label runat="server"></asp:Label>
                        </div>
                    </asp:Panel>
                </div>
            </td>
        </tr>
        <tr>
            <td align="center">
                <div runat="server" visible="false">
                    <telerik:RadButton ID="PASDownloadButton" runat="server" Text="Download from PAS" Skin="Office2007" AutoPostBack="false" Icon-PrimaryIconUrl="~/Images/icons/Download.png" Width="275" />
                </div>
                <div style="padding-top: 15px;">
                    <telerik:RadButton ID="AddPatientButton" runat="server" Text="Add patient manually" Skin="Metro" AutoPostBack="false"
                        Height="25" CssClass="RadPatientButton" Icon-PrimaryIconUrl="~/Images/icons/add_patient.png" Width="273" />
                </div>
            </td>
        </tr>
    </table>
</div>
