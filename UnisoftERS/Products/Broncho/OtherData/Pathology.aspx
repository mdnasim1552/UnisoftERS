<%@ Page Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Broncho_OtherData_Pathology" CodeBehind="Pathology.aspx.vb" %>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>

<asp:Content ID="IDHead" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <style type="text/css">
       
    </style>
    <script type="text/javascript">

        var stagingCheckBoxIds = "#<%= StagingInvestigationsCheckBox.ClientID %>, #<%= StageCheckBox.ClientID %>, #<%= PerformanceStatusCheckBox.ClientID %>";

        $(window).on('load', function () {
            $.each(["IndicationsDiv", "CoMorbidityDiv", "PulmonaryPhysiologyDiv", "ReferralDataDiv"], function (index, value) {
                markTab(index, value, "<%= RadTabStrip1.ClientID%>");
            });

            ToggleStaging();

            ToggleImmunoSuppressed();
        });

        $(document).ready(function () {
            $.each(["IndicationsDiv", "CoMorbidityDiv", "PulmonaryPhysiologyDiv", "ReferralDataDiv"], function (index, value) {
                triggerChange(index, value, "<%= RadTabStrip1.ClientID%>");
            });

            $('#<%= SuspectedLcaCheckBox.ClientID %>').change(function () {
                ToggleStaging();
            });

            $(stagingCheckBoxIds).change(function () {
                ToggleTRs($(this));
            });

            $('#<%= InfectionCheckBox.ClientID %>').change(function () {
                ToggleImmunoSuppressed();
            });
        });

        function ToggleTRs(chkbox) {
            var checked = chkbox.is(':checked');
            var nextRow = chkbox.closest('tr').next('tr');
            if (checked) {
                $(nextRow).show();
            }
            else {
                $(nextRow).hide();
                ClearControls($(nextRow));
            }
        }

        function ToggleStaging() {
            var checked = $('#<%= SuspectedLcaCheckBox.ClientID %>').is(':checked');
            var staging = $('#<%= StagingSection.ClientID %>');
            if (checked) {
                staging.show();
            }
            else {
                staging.hide();
                ClearControls(staging);
            }
            $(stagingCheckBoxIds).each(function () {
                ToggleTRs($(this));
            });
        }

        function ToggleImmunoSuppressed() {
            var chkbox = $('#<%= ImmunoSuppressedCheckBox.ClientID %>');
            var label = chkbox.next('label');
            if ($('#<%= InfectionCheckBox.ClientID %>').is(':checked')) {
                chkbox.show();
                label.show();
            } else {
                chkbox.hide();
                label.hide();
                chkbox.prop('checked', false);
            }
        }

        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").removeAttr("checked");
            tableCell.find("input:checkbox:checked").removeAttr("checked");
            tableCell.find("input:text").val("");
            
            if (tableCell.find("input:text[id*='StageTComboBox']").length > 0)
            {
                var stageComboBoxIds = ["<%= StageTComboBox.ClientID %>", "<%= StageNComboBox.ClientID %>", "<%= StageMComboBox.ClientID %>", "<%= StageTypeComboBox.ClientID %>"];
                stageComboBoxIds.forEach(function (id) {
                    var comboBox = $find(id);
                    if (comboBox != null) {
                        comboBox.clearSelection();
                    }
                });
            }
        }

        function RemoveZero(sender, args) {
            var tbValue = sender._textBoxElement.value;
            if (tbValue == "0")
                sender._textBoxElement.value = "";
        }
    </script>
</asp:Content>

<asp:Content ID="IDBody" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
    <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="800px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
        <telerik:RadPane ID="ControlsRadPane" runat="server" Height="505px" Scrolling="Y">
            <telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server">
                <div id="ContentDiv">
                    <div class="otherDataHeading">
                        <b>Pathology</b>
                    </div>
                    <div style="margin: 0px 10px;">
                        <div style="margin-top: 10px;"></div>
                        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" ReorderTabsOnSelect="true" Skin="WebBlue"
                            Orientation="HorizontalTop">
                            <Tabs>
                                <telerik:RadTab Value="0" Text="Indications" Font-Bold="true" />
                                <telerik:RadTab Value="1" Text="Co-Morbidity" Font-Bold="true" />
                                <telerik:RadTab Value="2" Text="Pulmonary Physiology" Font-Bold="true" Visible="false"/>
                                <telerik:RadTab Value="3" Text="Referral Data" Font-Bold="true" />
                            </Tabs>
                        </telerik:RadTabStrip>
                        <telerik:RadMultiPage ID="RadMultiPage1" runat="server" SelectedIndex="0">
                            <telerik:RadPageView ID="RadPageView0" runat="server">
                                <div id="IndicationsDiv" class="multiPageDivTab">
                                    <table cellpadding="1" cellspacing="1" style="margin-top: 10px;">
                                        <tr>
                                            <td colspan="4">
                                                <div style="float: left; width: 250px;">
                                                    <asp:CheckBox ID="AsthmaCheckBox" runat="server" Text="Asthma (thermoplasty)" /><br />
                                                    <asp:CheckBox ID="EmphysemaCheckBox" runat="server" Text="Emphysema (lung volume reduction)" /><br />
                                                    <asp:CheckBox ID="HaemoptysisCheckBox" runat="server" Text="Haemoptysis" /><br />
                                                    <asp:CheckBox ID="HilarCheckBox" runat="server" Text="Hilar/Mediastinal Lymphadenopathy" />
                                                </div>
                                                <div style="float: left; width: 200px; margin-left: 20px;">
                                                    <asp:CheckBox ID="InfectionCheckBox" runat="server" Text="Infection" />
                                                    <asp:CheckBox ID="ImmunoSuppressedCheckBox" runat="server" Text="immunosuppressed" /><br />
                                                    <asp:CheckBox ID="LungLobarCheckBox" runat="server" Text="Lung/lobar collapse" /><br />
                                                    <asp:CheckBox ID="RadiologicalCheckBox" runat="server" Text="Radiological abnormality" /><br />
                                                    <asp:CheckBox ID="SuspectedLcaCheckBox" runat="server" Text="Suspected lung cancer" />
                                                </div>
                                                <div style="float: left; width: 200px; margin-left: 20px;">
                                                    <asp:CheckBox ID="SuspectedSarcoidosisCheckBox" runat="server" Text="Suspected sarcoidosis" /><br />
                                                    <asp:CheckBox ID="SuspectedTBCheckBox" runat="server" Text="Suspected TB" />
                                                </div>
                                            </td>
                                        </tr>
                                        <tr id="StagingSection" runat="server">
                                            <td colspan="4">
                                                <fieldset id="StagingFieldset" runat="server" class="otherDataFieldset">
                                                    <legend>Staging</legend>
                                                    <table cellpadding="1" cellspacing="1" style="border-collapse: separate;">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="StagingInvestigationsCheckBox" runat="server" Text="Staging Investigations" />
                                                            </td>
                                                        </tr>
                                                        <tr style="display: none;">
                                                            <td>
                                                                <div style="margin-left: 30px;">
                                                                    <div style="float: left; width: 200px;">
                                                                        <asp:CheckBox ID="ClinicalGroundsCheckBox" runat="server" Text="Clinical grounds only" /><br />
                                                                        <asp:CheckBox ID="MediastinalSamplingCheckBox" runat="server" Text="Mediastinal sampling" />
                                                                    </div>

                                                                    <div style="float: left; width: 250px;">
                                                                        <asp:CheckBox ID="ImagingOfThoraxCheckBox" runat="server" Text="Cross sectional imaging of thorax" /><br />
                                                                        <asp:CheckBox ID="MetastasesCheckBox" runat="server" Text="Diagnostic tests for metastases" />
                                                                    </div>

                                                                    <div style="float: right;">
                                                                        <asp:CheckBox ID="PleuralHistologyCheckBox" runat="server" Text="Pleural cytology / histology" /><br />
                                                                        <asp:CheckBox ID="BronchoscopyCheckBox" runat="server" Text="Bronchoscopy" />
                                                                    </div>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="StageCheckBox" runat="server" Text="Stage" />
                                                            </td>
                                                        </tr>
                                                        <tr style="display: none;">
                                                            <td>
                                                                <div style="margin-left: 30px;">
                                                                    T
                                                                    <telerik:RadComboBox ID="StageTComboBox" runat="server" Width="70" Skin="Windows7" />
                                                                    N
                                                                    <telerik:RadComboBox ID="StageNComboBox" runat="server" Width="70" Skin="Windows7" />
                                                                    M
                                                                    <telerik:RadComboBox ID="StageMComboBox" runat="server" Width="70" Skin="Windows7" />
                                                                    <span style="margin-left: 10px; margin-right: 10px;">Or
                                                                    </span>
                                                                    Stage
                                                                    <telerik:RadComboBox ID="StageTypeComboBox" runat="server" Width="70" Skin="Windows7" />
                                                                    Date
                                                                    <telerik:RadDatePicker ID="StageDatePicker" runat="server" Width="100" Skin="Windows7" />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="PerformanceStatusCheckBox" runat="server" Text="Performance Status" /><br />
                                                            </td>
                                                        </tr>
                                                        <tr style="display: none;">
                                                            <td>
                                                                <div style="margin-left: 30px;">
                                                                    <asp:RadioButtonList ID="PerformanceStatusTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                                        RepeatLayout="Table" RepeatDirection="Horizontal" RepeatColumns="3">
                                                                        <asp:ListItem Value="1" Text="0. normal activity"></asp:ListItem>
                                                                        <asp:ListItem Value="2" Text="1. able to carry out light work"></asp:ListItem>
                                                                        <asp:ListItem Value="3" Text="2. unable to carry out any work"></asp:ListItem>
                                                                        <asp:ListItem Value="4" Text="3. limited self care"></asp:ListItem>
                                                                        <asp:ListItem Value="5" Text="4. completely disabled"></asp:ListItem>
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="height: 5px;"></td>
                                        </tr>
                                        <tr>
                                            <td colspan="3">Clinical details: (these details will be printed on the request cards)
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3">
                                                <telerik:RadTextBox ID="ClinicalDetailsTextBox" runat="server" Skin="Office2007" TextMode="MultiLine" Height="40" Width="500" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView1" runat="server">
                                <div id="CoMorbidityDiv" class="multiPageDivTab">
                                    <table cellpadding="1" cellspacing="1" style="margin-top: 10px;">
                                        <tr>
                                            <td>
                                                <div style="float: left; width: 250px;">
                                                    <asp:CheckBox ID="AtrialFibrillationCheckBox" runat="server" Text="Atrial fibrillation" /><br />
                                                    <asp:CheckBox ID="ChronicKidneyDiseaseCheckBox" runat="server" Text="Chronic kidney disease" /><br />
                                                    <asp:CheckBox ID="CopdCheckBox" runat="server" Text="COPD" /><br />
                                                    <asp:CheckBox ID="EnlargedLymphNodesCheckBox" runat="server" Text="Enlarged lymph nodes" /><br />
                                                    <asp:CheckBox ID="EssentialHyperTensionCheckBox" runat="server" Text="Essential hyper tension" /><br />
                                                    <asp:CheckBox ID="HeartFailureCheckBox" runat="server" Text="Heart failure" /><br />
                                                </div>
                                                <div style="float: left; width: 200px; margin-left: 20px;">
                                                    <asp:CheckBox ID="InterstitialLungDiseaseCheckBox" runat="server" Text="Interstitial lung disease" /><br />
                                                    <asp:CheckBox ID="IschaemicHeartDiseaseCheckBox" runat="server" Text="Ischaemic heart disease" /><br />
                                                    <asp:CheckBox ID="LungCancerCheckBox" runat="server" Text="Lung cancer" /><br />
                                                    <asp:CheckBox ID="ObesityCheckBox" runat="server" Text="Obesity" /><br />
                                                    <asp:CheckBox ID="PleuralEffusionCheckBox" runat="server" Text="Pleural effusion" /><br />
                                                </div>
                                                <div style="float: left; width: 200px; margin-left: 20px;">
                                                    <asp:CheckBox ID="PneumoniaCheckBox" runat="server" Text="Pneumonia" /><br />
                                                    <asp:CheckBox ID="RheumatoidArthritisCheckBox" runat="server" Text="Rheumatoid arthritis" /><br />
                                                    <asp:CheckBox ID="SecondaryCancerCheckBox" runat="server" Text="Secondary cancer" /><br />
                                                    <asp:CheckBox ID="StrokeCheckBox" runat="server" Text="Stroke" /><br />
                                                    <asp:CheckBox ID="Type2DiabetesCheckBox" runat="server" Text="Type 2 Diabetes" /><br />
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="height: 10px;"></td>
                                        </tr>
                                        <tr>
                                            <td>Please list any additional co-morbidities here
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <telerik:RadTextBox ID="OtherCoMorbTextBox" runat="server" Skin="Office2007" TextMode="MultiLine" Height="40" Width="500" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView2" runat="server" Visible="false">
                                <div id="PulmonaryPhysiologyDiv" class="multiPageDivTab">
                                    <table cellpadding="3" cellspacing="3" style="margin-top: 10px;">
                                        <tr>
                                            <td>FEV1
                                            </td>
                                            <td>
                                                <telerik:RadNumericTextBox ID="FEV1ResultNumericTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" MaxValue="1000">
                                                    <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                    <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                </telerik:RadNumericTextBox>
                                            </td>
                                            <td>litres (
                                            </td>
                                            <td>
                                                <telerik:RadNumericTextBox ID="FEV1PercentageNumericTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" MaxValue="100">
                                                    <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                    <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                </telerik:RadNumericTextBox>
                                            </td>
                                            <td>% of predictive) 
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>FVC
                                            </td>
                                            <td>
                                                <telerik:RadNumericTextBox ID="FVCResultNumericTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" MaxValue="1000">
                                                    <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                    <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                </telerik:RadNumericTextBox>
                                            </td>
                                            <td>litres (
                                            </td>
                                            <td>
                                                <telerik:RadNumericTextBox ID="FVCPercentageNumericTextBox" runat="server" Width="65" Skin="Windows7" MinValue="0" MaxValue="100">
                                                    <NumberFormat AllowRounding="false" DecimalDigits="2" />
                                                    <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                                </telerik:RadNumericTextBox>
                                            </td>
                                            <td>% of predictive)
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="height: 20px;"></td>
                                        </tr>
                                        <tr>
                                            <td colspan="5">WHO performance status
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="5">
                                                <asp:RadioButtonList ID="WHOPerformanceStatusRadioButtonList" runat="server" CellSpacing="2" CellPadding="3">
                                                    <asp:ListItem Value="1" Text="0. normal activity"></asp:ListItem>
                                                    <asp:ListItem Value="2" Text="1. able to carry out light work"></asp:ListItem>
                                                    <asp:ListItem Value="3" Text="2. unable to carry out any work"></asp:ListItem>
                                                    <asp:ListItem Value="4" Text="3. limited self care"></asp:ListItem>
                                                    <asp:ListItem Value="5" Text="4. completely disabled"></asp:ListItem>
                                                </asp:RadioButtonList>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView3" runat="server">
                                <div id="ReferralDataDiv" class="multiPageDivTab">
                                    <table cellpadding="3" cellspacing="3" style="margin-top: 10px;">
                                        <tr>
                                            <td>Date bronchoscopy requested
                                            </td>
                                            <td>
                                                <telerik:RadDatePicker ID="DateBronchRequestedDatePicker" runat="server" Width="100" Skin="Windows7" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Date of referral
                                            </td>
                                            <td>
                                                <telerik:RadDatePicker ID="DateOfReferralDatePicker" runat="server" Width="100" Skin="Windows7" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="height: 20px;"></td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:CheckBox ID="LCaSuspectedBySpecialistCheckBox" runat="server" Text="Lung Ca suspected by lung Ca specialist" /><br />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:CheckBox ID="CTScanAvailableCheckBox" runat="server" Text="CT scan available prior to bronchoscopy" /><br />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Date of scan
                                            </td>
                                            <td>
                                                <telerik:RadDatePicker ID="DateOfScanDatePicker" runat="server" Width="100" Skin="Windows7" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>
                    </div>
                </div>
            </telerik:RadAjaxPanel>
        </telerik:RadPane>
        <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
            <div style="height: 10px; margin-left: 10px; padding-top: 2px; padding-bottom: 2px">
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" Icon-PrimaryIconCssClass="telerikCancelButton" />
            </div>
        </telerik:RadPane>
    </telerik:RadSplitter>
</asp:Content>
