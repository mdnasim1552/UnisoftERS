<%@ Page Title="" Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_OtherData_OGD_Premed" Codebehind="Premed.aspx.vb" %>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>


 <%-- NOT USED!!! --%>



<asp:Content ID="Content1" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/Global.js"></script>

    <script type="text/javascript">
        $(window).on('load', function () {
            ToggleControls();
            ToggleValidator();
        });

       <%-- function ToggleControls() {
            if ($("#<%= SuccessfulRadioButton.ClientID%>").is(':checked')) {
                $find('<%= ExtentComboBox.ClientID%>').enable();
                ValidatorEnable(document.getElementById("<%= ExtentRequiredFieldValidator.ClientID%>"), true);
                ValidatorEnable(document.getElementById("<%= FailedOtherRequiredFieldValidator.ClientID%>"), false);

                $("form input:radio:checked[name*='FailedOptions']").removeAttr("checked");
                $("form input:radio[name*='FailedOptions']").attr('disabled', true);
                $("#<%= FailedOtherTextBox.ClientID%>").val('');
                $("#<%= FailedOtherTextBox.ClientID%>").attr('disabled', true);
            }
            else if ($("#<%= FailedRadioButton.ClientID%>").is(':checked')) {
                $("form input:radio[name*='FailedOptions']").attr('disabled', false);
                $("#<%= FailedOtherTextBox.ClientID%>").attr('disabled', false);

                $find('<%= ExtentComboBox.ClientID%>').clearSelection();
                $find('<%= ExtentComboBox.ClientID%>').disable();
                ValidatorEnable(document.getElementById("<%= ExtentRequiredFieldValidator.ClientID%>"), false);
            }
            else {
                $("form input:radio:checked[name*='FailedOptions']").removeAttr("checked");
                $("#<%= FailedOtherTextBox.ClientID%>").val('');
                $('#<%= ExtentComboBox.ClientID%> input:text').val('');

                $("form input:radio[name*='FailedOptions']").attr('disabled', true);
                $("#<%= FailedOtherTextBox.ClientID%>").attr('disabled', true);
                $find('<%= ExtentComboBox.ClientID%>').disable();

                ValidatorEnable(document.getElementById("<%= ExtentRequiredFieldValidator.ClientID%>"), false);
            }
        }

        function SelectParent(type) {
            if (type == 'success') {
                $("#<%= SuccessfulRadioButton.ClientID%>").prop('checked', true);
            }
            else if (type == 'fail') {
                $("#<%= FailedRadioButton.ClientID%>").prop('checked', true);
            }
            ToggleControls();
        }

        function ToggleValidator() {
            if ($("#<%= FailedOtherRadioButton.ClientID%>").is(':checked')) {
                ValidatorEnable(document.getElementById("<%= FailedOtherRequiredFieldValidator.ClientID%>"), true);
                $("#<%= FailedOtherTextBox.ClientID%>").attr('disabled', false);
            }
            else {
                $("#<%= FailedOtherTextBox.ClientID%>").val('');
                $("#<%= FailedOtherTextBox.ClientID%>").attr('disabled', true);
                ValidatorEnable(document.getElementById("<%= FailedOtherRequiredFieldValidator.ClientID%>"), false);
            }
        }--%>

    </script>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
    <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="800px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
        <telerik:RadPane ID="ControlsRadPane" runat="server" Height="505px" Scrolling="Y">
            <div id="ContentDiv">
                <div class="otherDataHeading">
                    <b>Premedication</b></div>
                    <fieldset class="otherDataFieldset" style="margin-left:15px;" >
                        <legend>Drugs administered</legend>
                        <table cellpadding="0" cellspacing="10">
                            <tr>
                                <td><telerik:RadButton ID="RadButton10" runat="server" Text="Ampicillin (IV)" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Black" AutoPostBack="false"></telerik:RadButton></td>
                                <td><telerik:RadNumericTextBox ID="txtRecordLimit" CssClass="spinAlign" runat="server" Skin="Windows7" Width="65" MinValue="0" NumberFormat-DecimalDigits="0" IncrementSettings-Step="250" />mg</td>
                            </tr>
                            <tr>
                                <td><telerik:RadButton ID="RadButton11" runat="server" Text="Atropine (sc)" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Black" AutoPostBack="false"></telerik:RadButton></td>
                                <td>
                                    <telerik:RadNumericTextBox ID="RadNumericTextBox1" CssClass="spinAlign" runat="server" Skin="Windows7" Width="65" MinValue="0.0" NumberFormat-DecimalSeparator="." >
                                        <IncrementSettings Step ="0.6" /> 
                                    </telerik:RadNumericTextBox>mg  
                                </td>
                            </tr>
                            <tr>
                                <td><telerik:RadButton ID="RadButton12" runat="server" Text="Buscopan (IV)" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Black" AutoPostBack="false"></telerik:RadButton></td>
                                <td><telerik:RadNumericTextBox ID="RadNumericTextBox2" CssClass="spinAlign" runat="server" Skin="Windows7" Width="65" MinValue="0" NumberFormat-DecimalDigits="0" IncrementSettings-Step="20" />mg</td>
                            </tr>
                            <tr>
                                <td><telerik:RadButton ID="RadButton13" runat="server" Text="Flumazenil (IV)" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Black" AutoPostBack="false"></telerik:RadButton></td>
                                <td><telerik:RadNumericTextBox ID="RadNumericTextBox3" CssClass="spinAlign" runat="server" Skin="Windows7" Width="65" MinValue="0" NumberFormat-DecimalDigits="0" IncrementSettings-Step="100" />ug</td>
                            </tr>
                            <tr>
                                <td><telerik:RadButton ID="RadButton14" runat="server" Text="Gentamycin (IV)" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Black" AutoPostBack="false"></telerik:RadButton></td>
                                <td><telerik:RadNumericTextBox ID="RadNumericTextBox4" CssClass="spinAlign" runat="server" Skin="Windows7" Width="65" MinValue="0" NumberFormat-DecimalDigits="0" IncrementSettings-Step="40" />mg</td>
                            </tr>
                            <tr>
                                <td><telerik:RadButton ID="RadButton15" runat="server" Text="Midazolam (IV)" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Black" AutoPostBack="false" ></telerik:RadButton></td>
                                <td>
                                    <telerik:RadNumericTextBox ID="RadNumericTextBox10" CssClass="spinAlign" runat="server" Skin="Windows7" Width="65" MinValue="0.0" NumberFormat-DecimalSeparator="." >
                                        <IncrementSettings Step ="0.5" /> 
                                    </telerik:RadNumericTextBox>mg  
                                </td>
                            </tr>
                            <tr>
                                <td><telerik:RadButton ID="RadButton16" runat="server" Text="Nalaxone (IV)" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Black" AutoPostBack="false"></telerik:RadButton></td>
                                <td><telerik:RadNumericTextBox ID="RadNumericTextBox6" CssClass="spinAlign" runat="server" Skin="Windows7" Width="65" MinValue="0" NumberFormat-DecimalDigits="0" IncrementSettings-Step="400" />ug</td>
                            </tr>
                            <tr>
                                <td><telerik:RadButton ID="RadButton17" runat="server" Text="Nubain (IV)" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Black" AutoPostBack="false"></telerik:RadButton></td>
                                <td>
                                    <telerik:RadNumericTextBox ID="RadNumericTextBox5" CssClass="spinAlign" runat="server" Skin="Windows7" Width="65" MinValue="0.0" NumberFormat-DecimalSeparator="." >
                                        <IncrementSettings Step ="2.5" /> 
                                    </telerik:RadNumericTextBox>mg  
                                </td>
                            </tr>
                            <tr>
                                <td><telerik:RadButton ID="RadButton18" runat="server" Text="Pethidine (IV)" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Black" AutoPostBack="false"></telerik:RadButton></td>
                                <td><telerik:RadNumericTextBox ID="RadNumericTextBox8" CssClass="spinAlign" runat="server" Skin="Windows7" Width="65" MinValue="0" NumberFormat-DecimalDigits="0" IncrementSettings-Step="10" />mg</td>
                            </tr>
                            <tr>
                                <td><telerik:RadButton ID="RadButton19" runat="server" Text="Xylocaine (Spray)" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Black" AutoPostBack="false"></telerik:RadButton></td>
                                <td><telerik:RadNumericTextBox ID="RadNumericTextBox9" CssClass="spinAlign" runat="server" Skin="Windows7" Width="65" MinValue="0" NumberFormat-DecimalDigits="0" IncrementSettings-Step="10" />mg</td>
                            </tr>
                        </table>

                        <div>
                            <telerik:RadNotification ID="SaveRadNotification" runat="server" Animation="None"
                                EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                                LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
                                AutoCloseDelay="70000">
                                <ContentTemplate>
                                    <asp:ValidationSummary ID="SaveValidationSummary" runat="server" ValidationGroup="Save" EnableClientScript="true"                                         DisplayMode="BulletList" 
                                        BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                                </ContentTemplate>
                            </telerik:RadNotification>
                        </div>
                    </fieldset>
                </div>
        </telerik:RadPane>
        <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
            <div style="height: 10px; margin-left: 10px; padding-top:2px; padding-bottom:2px">
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Web20" OnClientClicked="validatePage" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" Icon-PrimaryIconCssClass="telerikCancelButton" />
            </div>
        </telerik:RadPane>
    </telerik:RadSplitter>
</asp:Content>

