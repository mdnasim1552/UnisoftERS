<%@ Page Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_OtherData_OGD_QA" CodeBehind="QA.aspx.vb" ValidateRequest="false" %>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>

<asp:Content ID="IDHead" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/Global.js"></script>
    <style type="text/css">
        .checkboxesTable td {
            padding-right: 10px;
            padding-bottom: 3px;
        }

        .left {
            float: left;
        }

        .tblDiscomfort {
            border-collapse: collapse;
            border: 1px solid #ddd;
            margin: 10px;
        }

            .tblDiscomfort th {
                padding: 5px 0px 5px 0px;
                border: 1px solid #ddd;
            }

            .tblDiscomfort td {
                border-left: 1px solid #ddd;
            }

            .tblDiscomfort table td {
                border-left: none;
            }

        .FailureComplicationsItem {
            width: 200px;
            float: left;
        }
    </style>
    <script type="text/javascript">

        window.onbeforeunload = function (event) {
            document.getElementById("<%= SaveOnly.ClientID %>").click();
        }

        $(window).on('load', function () {
            Toggle($("#<%= OxygenationCheckBox.ClientID%>").is(':checked'), 'OxygenationMethodTD');
            Toggle($("#<%= ManagementOtherCheckBox.ClientID%>").is(':checked'), 'ManagementOtherTD');
            Toggle($("#<%= BPCheckBox.ClientID%>").is(':checked'), 'BPDetailsDiv');
            Toggle($("#<%= PerforationCheckBox.ClientID%>").is(':checked'), 'PerforationTextBoxDiv');
            Toggle($("#<%= ComplicationsOtherCheckBox.ClientID%>").is(':checked'), 'ComplicationsOtherTextDiv');
            Toggle($("#<%= AbandonedOtherCheckBox.ClientID%>").is(':checked'), 'AbandonedOtherTextDiv');
            Toggle($("#<%= DamageToScopeCheckBox.ClientID%>").is(':checked'), 'DamageToScopeTypeTD');
            Toggle($("#<%= PneumothoraxCheckBox.ClientID%>").is(':checked'), 'PneumothoraxCheckBoxDetailsDiv');
            Toggle($("#<%= ComplicationsBronchoscopyOtherCheckBox.ClientID%>").is(':checked'), 'ComplicationsBronchoscopyOtherTextDiv');
            ToggleReferral();
            ManagementTab();
            AssessmentTab();
            AdverseEventsTab();
            ComplicationsTab();
            ComplicationsBronchoscopyTab();
            ToggleBleeding();
        });

        function ManagementTab() {
            var apply = false;
            $("#multiPageDivTab").find("input[type=text], select, textarea").each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
            });
            if ($("#multiPageDivTab input:checkbox:checked").length > 0) { apply = true; }
            if ($("#multiPageDivTab input:radio:checked").length > 0) { apply = true; }
            setImage("0", apply);
        }
        function AssessmentTab() {
            var apply = false;
            $("#multiPageDivTab1").find("input[type=text], select, textarea").each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
            });
            if ($("#multiPageDivTab1 input:checkbox:checked").length > 0) { apply = true; }
            if ($("#multiPageDivTab1 input:radio:checked").length > 0) { apply = true; }
            setImage("1", apply);
        }
        function AdverseEventsTab() {
            var apply = false;
            $("#multiPageDivTabAdvEvents").find("input[type=text], select, textarea").each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
            });
            if ($("#multiPageDivTabAdvEvents input:checkbox:checked").length > 0) { apply = true; }
            if ($("#multiPageDivTabAdvEvents input:radio:checked").length > 0) { apply = true; }
            setImage("2", apply);
        }
        function ComplicationsTab() {
            var apply = false;
            $("#multiPageDivTab2").find("input[type=text], select, textarea").each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
            });
            if ($("#multiPageDivTab2 input:checkbox:checked").length > 0) { apply = true; }
            if ($("#multiPageDivTab2 input:radio:checked").length > 0) { apply = true; }
            setImage("3", apply);
        }
        function ComplicationsBronchoscopyTab() {
            var apply = false;
            $("#multiPageDivComplicationsBronchoscopy").find("input[type=text], select, textarea").each(function () {
                if ($(this).val() != null && $(this).val() != '' && $(this).val() != '(none selected)') { apply = true; return false; }
            });
            if ($("#multiPageDivComplicationsBronchoscopy input:checkbox:checked").length > 0) { apply = true; }
            if ($("#multiPageDivComplicationsBronchoscopy input:radio:checked").length > 0) { apply = true; }
            setImage("4", apply);
        }
        function ToggleBleeding() {
            var checked = $("#<%= BleedingCheckBox.ClientID%>").is(':checked');
            if (checked) {
                $('*[id*=BleedingSeverityComboBoxDiv]').show();
                $('*[id*=BleedingActionTakenTR]').show();
            }
            else {
                $('*[id*=BleedingSeverityComboBoxDiv]').hide();
                $('*[id*=BleedingActionTakenTR]').hide();

                var comboBox = $find("<%= BleedingSeverityComboBox.ClientID %>");
                if (comboBox != null) {
                    comboBox.clearSelection();
                }
                ClearControlsInternal($('#<%= BleedingActionTakenTR.ClientID %>'));
            }
        }
        function setImage(ind, state) {
            var tabS = $find("<%= RadTabStrip1.ClientID%>");
            if (ind != undefined) {
                var tab = tabS.findTabByValue(ind);
                if (tab != null) {
                    if (state) {
                        //tab.set_imageUrl('../../../../Images/Ok.png');
                        tab.get_textElement().style.fontWeight = 'bold';

                    } else {
                        tab.get_textElement().style.fontWeight = 'normal'
                        //tab.set_imageUrl("../../../../Images/none.png");
                    }
                }
            }
        }
        $(document).ready(function () {
            <% '----------------Highlight label when hoovering mouse----------%>
            $("#<%= PatDiscomfortEndoRadioButtonList.ClientID%> input:radio").mouseenter(function () {
                var pID = $(this).attr("id");
                var lID = pID.replace("PatDiscomfortEndoRadioButtonList", "PatDiscomfortNurseRadioButtonList");
                $("#" + lID).next().css("background-color", "#d4ebf2");
            });
            $("#<%= PatDiscomfortEndoRadioButtonList.ClientID%> input:radio").mouseleave(function () {
                var pID = $(this).attr("id");
                var lID = pID.replace("PatDiscomfortEndoRadioButtonList", "PatDiscomfortNurseRadioButtonList");
                $("#" + lID).next().css("background-color", "white");
            });
            $("#<%= PatDiscomfortNurseRadioButtonList.ClientID%> input:radio").mouseenter(function () {
                $(this).next().css("background-color", "#d4ebf2");
            });
            $("#<%= PatDiscomfortNurseRadioButtonList.ClientID%> input:radio").mouseleave(function () {
                $(this).next().css("background-color", "white");
            });
            <% '--------------------------------------------------------------%>

            $("#multiPageDivTab").find("input[type=text],input:checkbox, input:radio, select, textarea").change(function () {
                ManagementTab();
            });
            $("#multiPageDivTab1").find("input[type=text],input:checkbox, input:radio, select, textarea").change(function () {
                AssessmentTab();
            });
            $("#multiPageDivTabAdvEvents").find("input[type=text],input:checkbox, input:radio, select, textarea").change(function () {
                AdverseEventsTab();
            });
            $("#multiPageDivTab2").find("input[type=text],input:checkbox, input:radio, select, textarea").change(function () {
                ComplicationsTab();
            });
            $("#multiPageDivComplicationsBronchoscopy").find("input[type=text],input:checkbox, input:radio, select, textarea").change(function () {
                ComplicationsBronchoscopyTab();
            });

            $("#" + "<%= ManagementTable.ClientID%>" + " input:checkbox").change(function () {
                if ($(this).is(':checked')) {
                    var chkBoxId = $(this).attr("id");
                    if (chkBoxId.indexOf("ManagementNoneCheckBox") > -1) {
                        ClearControls("<%= ManagementTable.ClientID%>", chkBoxId);
                        $('*[id*=OxygenationMethodTD]').hide();
                        $('*[id*=ManagementOtherTD]').hide();
                        ClearControls("<%= BPDetailsDiv.ClientID%>", chkBoxId);
                        $('*[id*=BPDetailsDiv]').hide();
                    }
                    else {
                        $("#<%= ManagementNoneCheckBox.ClientID%>").prop('checked', false);
                    }
                }
            });

            $("#" + "<%= ComplicationsTable.ClientID%>" + " input:checkbox").change(function () {
                if ($(this).is(':checked')) {
                    var chkBoxId = $(this).attr("id");
                    if (chkBoxId.indexOf("ComplicationsNoneCheckBox") > -1) {
                        ClearControls("<%= ComplicationsTable.ClientID%>", chkBoxId);
                        $('*[id*=PerforationTextBoxDiv]').hide();
                        $('*[id*=ComplicationsOtherTextDiv]').hide();
                        $('*[id*=AbandonedOtherTextDiv]').hide();
                        $('*[id*=DamageToScopeTypeTD]').hide();
                    }
                    else {
                        $("#<%= ComplicationsNoneCheckBox.ClientID%>").prop('checked', false);
                    }
                }
            });

            $("#" + "<%= ComplicationsBronchoscopyTable.ClientID%>" + " input:checkbox").change(function () {
                if ($(this).is(':checked')) {
                    var chkBoxId = $(this).attr("id");
                    if (chkBoxId.indexOf("ComplicationsBronchoscopyNoneCheckBox") > -1) {
                        ClearControls("<%= ComplicationsBronchoscopyTable.ClientID%>", chkBoxId);
                        ToggleBleeding();
                        Toggle(false, 'PneumothoraxCheckBoxDetailsDiv');
                        Toggle(false, 'ComplicationsBronchoscopyOtherTextDiv');
                    }
                    else {
                        $("#<%= ComplicationsBronchoscopyNoneCheckBox.ClientID%>").prop('checked', false);
                    }
                }
            });

            $("#" + "<%= AdvEventsTable.ClientID%>" + " input:checkbox").change(function () {
                if ($(this).is(':checked')) {
                    var chkBoxId = $(this).attr("id");
                    if (chkBoxId.indexOf("chkNoAdverseEvents") > -1) {
                        ClearControls("<%= AdvEventsTable.ClientID%>", chkBoxId);
                    }
                    else {
                        $("#<%= chkNoAdverseEvents.ClientID%>").prop('checked', false);
                    }
                }
            });
        });

        function ClearControls(parentCtrlId, noneChkBoxId) {
            $("#" + parentCtrlId + " input:checkbox:checked").not("[id*='" + noneChkBoxId + "']").removeAttr("checked");
            $("#" + parentCtrlId + " input:radio:checked").removeAttr("checked");
            $("#" + parentCtrlId + " input:text").val('');
            $("#" + parentCtrlId + " textarea").val('');
        }

        function ClearControlsInternal(tableCell) {
            tableCell.find("input:radio:checked").removeAttr("checked");
            tableCell.find("input:checkbox:checked").removeAttr("checked");
            tableCell.find("input:text").val("");
        }

        function TogglePatSedationComboBox() {
            var valu = $('#<%=PatSedationRadioButton.ClientID%> input[type=radio]:checked').val();
            if (valu == '4') {
                $("#<%= PatSedationAsleepResponseStateComboBox.ClientID%>").show();
            }
            else {
                $("#<%= PatSedationAsleepResponseStateComboBox.ClientID%>").hide();
                $('#<%= PatSedationAsleepResponseStateComboBox.ClientID%>').val("");
            }
        }

        function ToggleReferral() {
            if ($("#<%= NoNotesCheckBox.ClientID%>").is(':checked')) {
                $("#<%= ReferralLetterTD.ClientID%>").show();
            }
            else {
                $("#<%= ReferralLetterTD.ClientID%>").hide();
                $("#<%= ReferralLetterCheckBox.ClientID%>").prop('checked', false);
            }
        }

        function CheckForValidPage() {
            var valid = Page_ClientValidate("Nurse");
            if (!valid) {
                $find("<%=CreateProcRadNotification.ClientID%>").show();
            }
            else {
                validatePage();
            }
        }
        function openGuidelinesPopUp() {
            var own = radopen("../../../Broncho/OtherData/GuidelinesForBleeding.aspx", "Guidelines For Bleeding", '800px', '450px');
            own.set_visibleStatusbar(false);
        }
    </script>
</asp:Content>
<asp:Content ID="IDBody" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
    <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="800px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
        <telerik:RadPane ID="ControlsRadPane" runat="server" Height="505px" Scrolling="Y">
            <div id="ContentDiv">
                <div class="otherDataHeading">
                    <b>Quality Assurance</b>
                </div>
                <div style="margin: 5px 10px;">
                    <div style="margin-top: 10px; margin-bottom: 20px;">
                        <fieldset id="DocumentationFieldset" runat="server" class="otherDataFieldset">
                            <legend>Documentation</legend>
                            <table id="DocumentationTable" runat="server" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td style="width: 180px;">
                                        <asp:CheckBox ID="NoNotesCheckBox" runat="server" Text="Patient notes NOT available"
                                            onchange="ToggleReferral();" /></td>
                                    <td id="ReferralLetterTD" runat="server">
                                        <asp:CheckBox ID="ReferralLetterCheckBox" runat="server"
                                            Text="But referral letter/documentation WAS available" />
                                    </td>
                                </tr>
                            </table>
                            <table style="width:100%;">
                                <tr>
                                    <td>
                                        <div class="left" style="padding-top: 4px; padding-left: 4px;">
                                            <asp:Label ID="WHOChecklistLabel" Text="WHO surgical safety checklist completed?" runat="server" Style="vertical-align: auto; font-weight:bold"></asp:Label>
                                        </div>
                                        <div class="left">
                                            <asp:RadioButtonList ID="WHOChecklistRadioButtonList" runat="server" Style="display: inline;" Skin="Windows7" RepeatDirection="Horizontal" RepeatColumns="2">
                                                <asp:ListItem Text="No" Value="0" />
                                                <asp:ListItem Text="Yes" Value="1" />
                                            </asp:RadioButtonList>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>

                    <div style="margin-left: 20px; width: 800px;">
                        <div>
                            <telerik:RadNotification ID="CreateProcRadNotification" runat="server" Animation="None"
                                EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                                LoadContentOn="PageLoad" TitleIcon="delete" Position="Center"
                                AutoCloseDelay="7000">
                                <ContentTemplate>
                                    <asp:ValidationSummary ID="ValidationSummary" runat="server" ValidationGroup="Nurse" DisplayMode="BulletList"
                                        EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                                </ContentTemplate>
                            </telerik:RadNotification>
                        </div>
                        <%--<asp:ValidationSummary runat="server" ValidationGroup="Nurse" DisplayMode="BulletList" ForeColor="Yellow" />--%>
                        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" Skin="Metro"
                            Orientation="HorizontalTop" RenderMode="Lightweight">
                            <Tabs>
                                <telerik:RadTab Text="Management" Font-Bold="true" Value="0" />
                                <telerik:RadTab Text="Sedation / Comfort score" Value="1" ImageUrl="../../../../Images/NEDJAG/JAGNEDMand.png" />
                                <telerik:RadTab Text="Adverse Events (National Data Set)" Value="2" ImageUrl="../../../../Images/NEDJAG/NEDMand.png" />
                                <telerik:RadTab Text="Complications" Value="3" ImageUrl="../../../../Images/NEDJAG/Mand.png" />
                                <telerik:RadTab Text="Complications" Value="4" Visible="false" />
                            </Tabs>
                        </telerik:RadTabStrip>



                        <telerik:RadMultiPage ID="RadMultiPage1" runat="server" SelectedIndex="0">
                            <%-- ALL Procedures --%>
                            <telerik:RadPageView ID="RadPageView0" runat="server">
                                <div id="multiPageDivTab" class="multiPageDivTab">
                                    <table id="ManagementTable" runat="server" cellspacing="0" cellpadding="0" class="checkboxesTable" style="table-layout: fixed;">
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="ManagementNoneCheckBox" runat="server" Text="None" />
                                            </td>
                                        </tr>
                                        <tr style="height: 15px;">
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td style="width: 150px; height: 23px;">
                                                <asp:CheckBox ID="PulseOximetryCheckBox" runat="server" Text="Pulse oximetry" /></td>
                                            <td>
                                                <asp:CheckBox ID="OxygenationCheckBox" runat="server" Text="Oxygenation"
                                                    onchange="ToggleDetails('OxygenationMethodTD');" />
                                            </td>
                                            <td id="OxygenationMethodTD" runat="server" style="vertical-align: bottom; display: none;">
                                                <asp:RadioButtonList ID="OxygenationMethodRadioButtonList" runat="server"
                                                    CellSpacing="1" CellPadding="1" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                    <asp:ListItem Value="1" Text="Cannulae"></asp:ListItem>
                                                    <asp:ListItem Value="2" Text="Mask"></asp:ListItem>
                                                </asp:RadioButtonList>
                                                &nbsp;&nbsp;&nbsp;
                                                <telerik:RadTextBox ID="OxygenationFlowRateTextBox" runat="server" Skin="Windows7" Width="50" />
                                                l/min
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="IVAccessCheckBox" runat="server" Text="IV access" /></td>
                                            <td>
                                                <asp:CheckBox ID="ContinuousECGCheckBox" runat="server" Text="Continuous ECG" /></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="IVAntibioticsCheckBox" runat="server" Text="IV antibiotics" /></td>
                                            <td style="height: 23px;">
                                                <asp:CheckBox ID="ManagementOtherCheckBox" runat="server" Text="Other"
                                                    onchange="ToggleDetails('ManagementOtherTD');" /></td>
                                            <td id="ManagementOtherTD" runat="server" style="display: none;" rowspan="3" colspan="3">
                                                <telerik:RadTextBox ID="ManagementOtherTextBox" runat="server" Skin="Windows7" Width="400" Height="45" TextMode="MultiLine" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="BPCheckBox" runat="server" Text="Blood pressure" onchange="ToggleDetails('BPDetailsDiv');" />
                                            </td>
                                        </tr>
                                    </table>
                                    <div id="BPDetailsDiv" runat="server" style="color: black; margin-left: 20px; display: none;">
                                        <table style="color: black; margin-left: 20px;">
                                            <tr>
                                                <td>Systolic</td>
                                                <td style="vertical-align: bottom;">
                                                    <telerik:RadTextBox ID="BPSysTextBox" runat="server" Skin="Windows7" Width="50" />&nbsp;mm</td>
                                            </tr>
                                            <tr>
                                                <td>Diastolic</td>
                                                <td style="vertical-align: bottom;">
                                                    <telerik:RadTextBox ID="BPDiaTextBox" runat="server" Skin="Windows7" Width="50" />&nbsp;mm</td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div>
                                        <telerik:RadButton ID="DefaultRadButton" runat="server" Text="Save as default" Skin="Windows7" OnClick="SaveDefault" />
                                    </div>
                                </div>
                            </telerik:RadPageView>
                            <%-- ALL Procedures --%>
                            <telerik:RadPageView ID="RadPageView1" runat="server">
                                <div id="multiPageDivTab1" class="multiPageDivTab">
                                    <table id="PatientSedationTable" runat="server" cellspacing="0" cellpadding="0" class="checkboxesTable" style="color: black;">
                                        <tr>
                                            <td>
                                                <fieldset id="Fieldset1" runat="server" class="otherDataFieldset">
                                                    <legend>Patient Sedation</legend>
                                                    <table>
                                                        <tr>
                                                            <td>
                                                                <asp:RadioButtonList ID="PatSedationRadioButton" runat="server" CellSpacing="1" CellPadding="1" RepeatDirection="Horizontal" RepeatLayout="Table" onchange="TogglePatSedationComboBox();">
                                                                    <%--<asp:ListItem Value="1" Text="Not Recorded" />--%>
                                                                    <asp:ListItem Value="2" Text="Awake" />
                                                                    <asp:ListItem Value="3" Text="Drowsy" />
                                                                    <asp:ListItem Value="4" Text="Asleep but" />
                                                                </asp:RadioButtonList>
                                                            </td>
                                                            <td valign="bottom">
                                                                <div style="float: left">
                                                                    <telerik:RadComboBox ID="PatSedationAsleepResponseStateComboBox" runat="server" Skin="Office2007" Width="150px">
                                                                        <Items>
                                                                            <telerik:RadComboBoxItem Value="0" Text="" />
                                                                            <telerik:RadComboBoxItem Value="1" Text="responding to name" />
                                                                            <telerik:RadComboBoxItem Value="2" Text="responding to touch" />
                                                                            <telerik:RadComboBoxItem Value="3" Text="unresponsive" />
                                                                        </Items>
                                                                    </telerik:RadComboBox>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>


                                                    <asp:RequiredFieldValidator runat="server" ID="SedationOptionsRequiredFieldValidator" ControlToValidate="PatSedationRadioButton" Display="None" ErrorMessage="Select patient sedation" ValidationGroup="Nurse" />
                                                    <%-- <table cellspacing="1" cellpadding="1" style="color: black;">
                                                        <tr>
                                                            <td>
                                                                <asp:RadioButton ID="PatSedationNotRecordedRadioButton" runat="server" Text="Not Recorded" GroupName="SedationOptions"
                                                                    onchange="TogglePatSedationComboBox();" />&nbsp;
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:RadioButton ID="PatSedationAwakeRadioButton" runat="server" Text="Awake" GroupName="SedationOptions"
                                                                    onchange="TogglePatSedationComboBox();" />&nbsp;
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:RadioButton ID="PatSedationDrowsyRadioButton" runat="server" Text="Drowsy" GroupName="SedationOptions"
                                                                    onchange="TogglePatSedationComboBox();" />&nbsp;
                                                            </td>
                                                        </tr>
                                                        <tr style="height: 27px;">
                                                            <td>
                                                                <asp:RadioButton ID="PatSedationAsleepRadioButton" runat="server" Text="Asleep but" GroupName="SedationOptions"
                                                                    onchange="TogglePatSedationComboBox();" />&nbsp;&nbsp;
                                                            </td>
                                                            <td></td>
                                                        </tr>
                                                    </table>--%>
                                                </fieldset>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <fieldset id="Fieldset2" runat="server" class="otherDataFieldset">
                                                    <legend>Patient Discomfort</legend>
                                                    <table class="tblDiscomfort">
                                                        <tr>
                                                            <th>Endoscopist</th>
                                                            <th style="text-align: left; padding-left: 8px;">Nurse</th>
                                                            <%--<th style="text-align:left;padding-left:18px;">Discomfort</th>--%>
                                                        </tr>
                                                        <tr>
                                                            <td style="text-align: center; width: 70px; padding-left: 50px;">
                                                                <asp:RadioButtonList ID="PatDiscomfortEndoRadioButtonList" runat="server"
                                                                    RepeatDirection="Vertical" RepeatLayout="Table">
                                                                    <asp:ListItem Value="1" Text=""></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text=""></asp:ListItem>
                                                                    <asp:ListItem Value="3" Text=""></asp:ListItem>
                                                                    <asp:ListItem Value="4" Text=""></asp:ListItem>
                                                                    <asp:ListItem Value="5" Text=""></asp:ListItem>
                                                                    <asp:ListItem Value="6" Text=""></asp:ListItem>
                                                                </asp:RadioButtonList>
                                                            </td>
                                                            <td style="text-align: left; width: 500px; padding-left: 10px;">
                                                                <asp:RadioButtonList ID="PatDiscomfortNurseRadioButtonList" runat="server"
                                                                    RepeatDirection="Vertical" RepeatLayout="Table">
                                                                    <asp:ListItem Value="1" Text="<span style='padding-left:30px;'></span>Not recorded"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="<span style='padding-left:30px;'></span>None - resting comfortably throughout"></asp:ListItem>
                                                                    <asp:ListItem Value="3" Text="<span style='padding-left:30px;'></span>One or two episodes of mild discomfort, well tolerated"></asp:ListItem>
                                                                    <asp:ListItem Value="4" Text="<span style='padding-left:30px;'></span>More than two episodes of discomfort, adequately tolerated"></asp:ListItem>
                                                                    <asp:ListItem Value="5" Text="<span style='padding-left:30px;'></span>Significant discomfort,  experienced several times during procedure"></asp:ListItem>
                                                                    <asp:ListItem Value="6" Text="<span style='padding-left:30px;'></span>Extreme discomfort frequently during test"></asp:ListItem>
                                                                </asp:RadioButtonList>
                                                            </td>
                                                            <%--<td>--%>
                                                            <%--<table class="tblLabel" style="vertical-align:top;">
                                                                    <tr><td><label id="lblDis0">None - resting comfortably throughout</label></td></tr>
                                                                    <tr><td><label id="lblDis1">One or two episode of mild discomfort, well tolerated</label></td></tr>
                                                                    <tr><td><label id="lblDis2">More than two episodes of discomfort, adequately tolerated</label></td></tr>
                                                                    <tr><td><label id="lblDis3">Significant discomfort,  experienced several times during procedure</label></td></tr>
                                                                    <tr><td><label id="lblDis4">Extreme discomfort frequently during test</label></td></tr>
                                                                </table>--%>
                                                            <%--<asp:RadioButtonList ID="PatDisLabelRadioButtonList" runat="server"
                                                                    CellSpacing="1" CellPadding="1" RepeatDirection="Vertical" RepeatLayout="Table" CssClass="rblLabel">
                                                                    <asp:ListItem Value="1" Text="Not recorded"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="None-resting comfortably throughout"></asp:ListItem>
                                                                    <asp:ListItem Value="3" Text="One or two episode of mild discomfort, well tolerated"></asp:ListItem>
                                                                    <asp:ListItem Value="4" Text="More than two episodes of discomfort, adequately tolerated"></asp:ListItem>
                                                                    <asp:ListItem Value="5" Text="Significant discomfort,  experienced several times during procedure"></asp:ListItem>
                                                                    <asp:ListItem Value="6" Text="Extreme discomfort frequently during test"></asp:ListItem>
                                                                </asp:RadioButtonList>--%>


                                                            <%--</td>--%>
                                                        </tr>
                                                    </table>
                                                    <asp:RequiredFieldValidator runat="server" ID="PatDiscomfortRequiredFieldValidator" ControlToValidate="PatDiscomfortNurseRadioButtonList" Display="None" ErrorMessage="Select patient discomfort" ValidationGroup="Nurse" />
                                                </fieldset>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>

                            <%--Adverse Events (NED) all but 10,11,12--%>
                            <telerik:RadPageView ID="RadPageView3" runat="server">
                                <div id="multiPageDivTabAdvEvents" class="multiPageDivTab">
                                    <table id="AdvEventsTable" runat="server" cellspacing="0" cellpadding="0" class="checkboxesTable" style="color: black;">
                                        <tr>
                                            <td colspan="2">
                                                <asp:CheckBox ID="chkNoAdverseEvents" runat="server" Text="None" CssClass="chkNone" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="chkConsentSignedInRoom" runat="server" Text="Consent signed in room" CssClass="adverse-events" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="chkUnplannedAdmission" runat="server" Text="Unplanned admission" CssClass="adverse-events" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="chkO2Desaturation" runat="server" Text="O2 desaturation" CssClass="adverse-events" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="chkWithdrawalOfConsent" runat="server" Text="Withdrawal of consent" CssClass="adverse-events" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="chkUnsupervisedTrainee" runat="server" Text="Unsupervised trainee" CssClass="adverse-events" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="chkVentilation" runat="server" Text="Ventilation" CssClass="adverse-events" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>

                            <%--All but 10,11,12--%>
                            <telerik:RadPageView ID="RadPageView2" runat="server">
                                <div id="multiPageDivTab2" class="multiPageDivTab">
                                    <table id="ComplicationsTable" runat="server" cellspacing="0" cellpadding="0" class="checkboxesTable" style="color: black;">
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="ComplicationsNoneCheckBox" runat="server" Text="None" />
                                            </td>
                                        </tr>
                                        <tr style="height: 15px;">
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td style="width: 180px; vertical-align: top;">
                                                <asp:CheckBox ID="PoorlyToleratedCheckBox" runat="server" Text="Poorly tolerated" />
                                            </td>
                                            <td style="width: 255px;">
                                                <table cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td style="vertical-align: top;">
                                                            <asp:CheckBox ID="DamageToScopeCheckBox" runat="server" Text="Damage to 'scope"
                                                                onchange="ToggleDetails('DamageToScopeTypeTD');" />
                                                            &nbsp;
                                                        </td>
                                                        <td id="DamageToScopeTypeTD" runat="server" style="vertical-align: top; background-color: #f0f5f5; border: 1px solid #e0ebeb;">

                                                            <asp:CheckBox ID="MechanicalCheckBox" runat="server" Text="mechanical" />
                                                            <br />
                                                            <asp:CheckBox ID="PatientInitiatedCheckBox" runat="server" Text="patient initiated" />
                                                            <%--<telerik:RadComboBox ID="DamageToScopeTypeComboBox" runat="server" Skin="Office2007" Width="110px" CheckBoxes="true" NoWrap="true">
                                                                <Items>
                                                                    <telerik:RadComboBoxItem Value="1" Text="mechanical" />
                                                                    <telerik:RadComboBoxItem Value="2" Text="patient initiated" />
                                                                </Items>
                                                            </telerik:RadComboBox>--%>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td style="vertical-align: top;">
                                                <asp:CheckBox ID="HypoxiaCheckBox" runat="server" Text="Hypoxia" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="PatientDiscomfortCheckBox" runat="server" Text="Patient discomfort" /></td>
                                            <td>
                                                <asp:CheckBox ID="GastricContentsAspirationCheckBox" runat="server" Text="Gastric contents aspiration" /></td>
                                            <td>
                                                <asp:CheckBox ID="RespiratoryDepressionCheckBox" runat="server" Text="Respiratory depression" /></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="PatientDistressCheckBox" runat="server" Text="Patient distress" /></td>
                                            <td>
                                                <asp:CheckBox ID="ShockHypotensionCheckBox" runat="server" Text="Shock/hypotension" /></td>
                                            <td>
                                                <asp:CheckBox ID="RespiratoryArrestCheckBox" runat="server" Text="Respiratory arrest requiring immediate action" /></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="InjuryToMouthCheckBox" runat="server" Text="Injury to mouth/teeth" /></td>
                                            <td>
                                                <asp:CheckBox ID="HaemorrhageCheckBox" runat="server" Text="Haemorrhage" /></td>
                                            <td>
                                                <asp:CheckBox ID="CardiacArrestCheckBox" runat="server" Text="Cardiac arrest" /></td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="DifficultIntubationCheckBox" runat="server" Text="Difficult intubation" />
                                                <!--<asp:CheckBox ID="FailedIntubationCheckBox" runat="server" Text="Failed intubation" /> -->
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="SignificantHaemorrhageCheckBox" runat="server" Text="Significant haemorrhage" /></td>
                                            <td>
                                                <asp:CheckBox ID="CardiacArrythmiaCheckBox" runat="server" Text="Cardiac arrhythmia" /></td>
                                        </tr>
                                        <tr>
                                            <td><asp:CheckBox ID="DeathCheckBox" runat="server" Text="Death" />
                                                </td>
                                            <td style="vertical-align: top;">
                                                <div style="margin-left: 20px; margin-top: -5px">requiring transfusion</div>
                                            </td>
                                            <td> &nbsp;
                                                </td>
                                        </tr>
                                        <tr style="height: 10px;">
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td colspan="3">
                                                <div style="margin-left: 5px; float: left; width: 198px;">Technical Failure: </div>
                                                <div style="float: left;">
                                                    <telerik:RadTextBox ID="TechnicalFailureTextBox" runat="server" Skin="Windows7" Width="500" />
                                                </div>
                                                <br />
                                                <div id="FailureComplicationsDiv" style="clear: both;" runat="server" visible="false">
                                                    <asp:CheckBox ID="chkAllergyToContrast" runat="server" Text="Allergy to contrast medium" CssClass="FailureComplicationsItem" />
                                                    <asp:CheckBox ID="chkContrast" runat="server" Text="Contrast extravasation" CssClass="FailureComplicationsItem" />
                                                    <asp:CheckBox ID="chkArcinarisation" runat="server" Text="Arcinarisation of the parenchyma" CssClass="FailureComplicationsItem" />
                                                    <br style="clear: both;" />
                                                    <asp:CheckBox ID="chkFailedERCP" runat="server" Text="Failed ERC/ERP" CssClass="FailureComplicationsItem" />
                                                    <asp:CheckBox ID="chkFailedCannulation" runat="server" Text="Failed cannulation" CssClass="FailureComplicationsItem" />
                                                    <asp:CheckBox ID="chkFailedStentInsertion" runat="server" Text="Failed stent insertion" CssClass="FailureComplicationsItem" />
                                                    <asp:CheckBox ID="chkPancreatitis" runat="server" Text="Pancreatitis" CssClass="FailureComplicationsItem" Style="width: 100px;" />
                                                </div>
                                                <div id="PerforationDiv" style="display: block; height: 30px; margin-top: 10px;">
                                                    <span style="float: left; width: 177px;">
                                                        <asp:CheckBox ID="PerforationCheckBox" runat="server" Text="Perforation" onchange="ToggleDetails('PerforationTextBoxDiv');" />
                                                    </span>
                                                    <div id="PerforationTextBoxDiv" style="float: left;" runat="server">
                                                        Site: 
                                                        <telerik:RadTextBox ID="PerforationTextBox" runat="server" Skin="Windows7" Width="500" />
                                                    </div>
                                                </div>
                                                <br />
                                                <div style="clear: both; height: 30px;">
                                                    <span style="float: left; width: 204px;">
                                                        <asp:CheckBox ID="ComplicationsOtherCheckBox" runat="server" Text="Other complication" onchange="ToggleDetails('ComplicationsOtherTextDiv');" />
                                                    </span>
                                                    <div id="ComplicationsOtherTextDiv" style="float: left;" runat="server">
                                                        <telerik:RadTextBox ID="ComplicationsOtherTextBox" runat="server" Skin="Windows7" Width="400" />
                                                    </div>
                                                </div>




                                            </td>

                        
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>

                            <%--Proc types 10,11,12--%>
                            <telerik:RadPageView ID="RadPageView4" runat="server">
                                <div id="multiPageDivComplicationsBronchoscopy" class="multiPageDivTab">
                                    <table id="ComplicationsBronchoscopyTable" runat="server" cellspacing="0" cellpadding="0" class="checkboxesTable" style="color: black;">
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="ComplicationsBronchoscopyNoneCheckBox" runat="server" Text="None" />
                                            </td>
                                        </tr>
                                        <tr style="height: 15px;">
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:CheckBox ID="BleedingCheckBox" runat="server" Text="Bleeding" onchange="ToggleBleeding();" />
                                                <div id="BleedingSeverityComboBoxDiv" runat="server" style="margin-left: 10px; display: inline">
                                                    <telerik:RadComboBox ID="BleedingSeverityComboBox" runat="server" Skin="Windows7" Width="100px">
                                                        <Items>
                                                            <telerik:RadComboBoxItem Value="1" Text="Mild" />
                                                            <telerik:RadComboBoxItem Value="2" Text="Moderate" />
                                                            <telerik:RadComboBoxItem Value="3" Text="Severe" />
                                                        </Items>
                                                    </telerik:RadComboBox>
                                                    <div style="margin-left: 10px; display: inline">
                                                        <telerik:RadButton ID="GuidelinesButton" runat="server" Text="Guidelines for Bleeding" OnClientClicked="openGuidelinesPopUp" Skin="Windows7" Icon-PrimaryIconCssClass="rbHelp" AutoPostBack="false" />
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr id="BleedingActionTakenTR" runat="server">
                                            <td colspan="2">
                                                <fieldset id="ActionTakenFieldset" runat="server" class="otherDataFieldset">
                                                    <legend>Action taken</legend>
                                                    <asp:CheckBox ID="BleedingColdSalineUsedCheckbox" runat="server" Text="Cold saline" />
                                                    <br />
                                                    <asp:CheckBox ID="BleedingAdrenalineUsedCheckbox" runat="server" Text="Adrenaline 1 in 10,000" />
                                                    <telerik:RadNumericTextBox ID="BleedingAdrenalineAmountNumericTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0">
                                                        <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                    </telerik:RadNumericTextBox>
                                                    ml injected
                                                    <br />
                                                    <asp:CheckBox ID="BleedingBlockingDeviceUsedCheckbox" runat="server" Text="Blocking device" />
                                                </fieldset>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:CheckBox ID="PneumothoraxCheckBox" runat="server" Text="Pneumothorax" onchange="ToggleDetails('PneumothoraxCheckBoxDetailsDiv');" />
                                                <div id="PneumothoraxCheckBoxDetailsDiv" runat="server" style="display: inline">
                                                    <asp:CheckBox ID="PneumothoraxAspirChestDrainCheckBox" runat="server" Text="required aspiration/chest drain" />
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="CardiacArrythmiaBronchoscopyCheckBox" runat="server" Text="Cardiac arrhythmia" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="DeathBronchoscopyCheckBox" runat="server" Text="Death" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="HospitalisationCheckBox" runat="server" Text="Hospitalisation" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="AdmissionToIcuCheckBox" runat="server" Text="Admission to ICU" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="MyocardInfarctionCheckbox" runat="server" Text="Myocardial infarction/pulmonary oedema" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="OversedationCheckbox" runat="server" Text="Oversedation requiring ventilatory support or reversal" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="1">
                                                <asp:CheckBox ID="ComplicationsBronchoscopyOtherCheckBox" runat="server" Text="Other complication" onchange="ToggleDetails('ComplicationsBronchoscopyOtherTextDiv');" />
                                                <div id="ComplicationsBronchoscopyOtherTextDiv" runat="server" style="display: inline">
                                                    <telerik:RadTextBox ID="ComplicationsBronchoscopyOtherTextBox" runat="server" Skin="Windows7" Width="400" />
                                                </div>
                                            </td>
                                            <td>
                                                   <asp:CheckBox ID="AbandonedOtherCheckbox" runat="server" Text="Procedure Abandoned" onchange="ToggleDetails('AbandonedOtherTextDiv');" />
                                                <div id="AbandonedOtherTextDiv" runat="server" style="display: inline">
                                                    <telerik:RadTextBox ID="AbandonedOtherTextBox" runat="server" Skin="Windows7" Width="400" />
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>

                    </div>
                </div>
            </div>
        </telerik:RadPane>
        <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
            <div style="height: 10px; margin-left: 10px; padding-top: 2px; padding-bottom: 2px">
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Web20" ValidationGroup="Nurse" OnClientClicking="validatePage" Icon-PrimaryIconCssClass="telerikSaveButton" />
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" Icon-PrimaryIconCssClass="telerikCancelButton" />
            </div>
            <div style="height:0px; display:none">
                <telerik:RadButton ID="SaveOnly" runat="server" Text="Save" Skin="Web20" OnClick="SaveOnly_Click" style="height:1px; width:1px" />
            </div>        
        </telerik:RadPane>
    </telerik:RadSplitter>

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
    </telerik:RadAjaxLoadingPanel>
</asp:Content>

