<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_SystemSettings" CodeBehind="SystemSettings.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .sysFieldset {
            width: 550px;
        }

        /*.sysFieldset1 {
            width: 300px;
        }*/

        .sysVal {
            color: #004F9D;
        }

        .sysLabel {
            color: gray;
        }

        .rightAligned {
            text-align: right;
        }

        .validate-error-label {
            color: red !important;
        }
    </style>

    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
        <script type="text/javascript">
            var appTimeoutValue, appTimeoutChanged;

            $(document).ready(function () {
                appTimeoutValue = "<%= ApplicationTimeout %>";

                $("#ControlsTable input:text, input:radio, input:checkbox").change(function () {
                    EnableDisable();
                });
                $("#ControlsTable_ERS input:text, input:radio").change(function () {
                    EnableDisable();
                });
                $("#ProcedureTable input:text, input:radio").change(function () {
                    EnableDisable();
                });
                $("#SiteTable input:text, input:radio").change(function () {
                    EnableDisable();
                });
                $("#patientDefaultTable input:text, input:radio").change(function () {
                    EnableDisable();
                });

<%--            $("#<%= PatientStatusNoneButton.ClientID%>").click(function () {
                    $("#PatStatusRadioButtonList_0").attr('checked', false);
                    $("#PatStatusRadioButtonList_1").attr('checked', false);
                    $("#PatStatusRadioButtonList_2").attr('checked', false);
                });

                $("#<%= PatientTypeNoneButton.ClientID%>").click(function () {
                    $("#PatientTypeRadioButtonList_0").attr('checked', false);
                    $("#PatientTypeRadioButtonList_1").attr('checked', false);
                });

                $("#<%= WardNoneButton.ClientID%>").click(function () {
                    var combo = $find("<%= WardComboBox.ClientID%>");
                    combo.trackChanges();
                    combo.get_items().getItem(0).select();
                    combo.updateClientState();
                    combo.commitChanges();
                });--%>
            });

            function RemovePatientType() {
                $('#<%= PatientTypeRadioButtonList.ClientID %>').find('input[type=radio]').prop('checked', false);
            }

            function RemovePatientStatus() {
                $('#<%= PatStatusRadioButtonList.ClientID %>').find('input[type=radio]').prop('checked', false);
            }

            function RemoveWard() {
                var combo = $find("<%= WardComboBox.ClientID%>");
                if (combo) {
                    combo.clearSelection();
                }
            }

            function EnableDisable() {
                var button2 = $find("SaveButton");
                button2.set_enabled(true);
            }

            function ApplicationTimeoutValueChanged(sender, eventArgs) {
                appTimeoutChanged = appTimeoutValue != eventArgs.get_newValue();
            }

            function ConfirmSave(sender, args) {
                if (appTimeoutChanged) {
                    args.set_cancel(!window.confirm("Updating the Application Timeout will restart the ERS application. \nAre you sure you want to proceed?"));
                }
            }
            function isEditable() {
                if ($("#<%= CannotEditRadioButton.ClientID%>").is(":checked")) {
                    $("#EditableDiv").show();
                } else {
                    $("#EditableDiv").hide();
                    $find("<%= FromTimePicker.ClientID%>").get_dateInput().set_value('00:00');
                    $find("<%= DaysNumericTextBox.ClientID%>").set_value('1');
                }
            }

            function ToggleRadDatePicker() {
                if ($("#<%= rbEvidenceOfCancerOn.ClientID%>").is(":checked")) {
                    $("#EvidenceOfCancerMandatoryDateDiv").show();
                } else if ($("#<%= rbEvidenceOfCancerOff.ClientID%>").is(":checked")) {
                    $("#EvidenceOfCancerMandatoryDateDiv").hide();
                }
            };
        </script>
    </telerik:RadCodeBlock>
</head>

<body>
    <script type="text/javascript">
</script>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ControlsRadPane" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <telerik:RadAjaxManager runat="server">
            <AjaxSettings>

                <telerik:AjaxSetting AjaxControlID="SaveButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <%--  <telerik:AjaxSetting AjaxControlID="AddQuestionLinkButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="QuestionAnswerOptionCheckBox" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="FreeTextAnswerOptionCheckBox" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="AnswerMandatoryCheckBox" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="QuestionAnswerTypeValidator" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="FollowUpQuestionsRadGrid" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="FollowUpQuestionsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="FollowUpQuestionsRadGrid" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="QuestionAnswerOptionCheckBox" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="FreeTextAnswerOptionCheckBox" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="AnswerMandatoryCheckBox" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="QuestionAnswerTypeValidator" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        <div class="optionsHeading">System Configuration</div>

        <div id="HospitalFilterDiv" runat="server" class="optionsBodyText" style="margin: 10px;">
            <label for="OperatingHospitalsRadComboBox" style="display: inline-block; width: 120px;">Operating Hospital:</label>
            <telerik:RadComboBox ID="OperatingHospitalsRadComboBox" CssClass="filterDDL" runat="server" Width="270px" AutoPostBack="true" OnSelectedIndexChanged="OperatingHospitalsRadComboBox_SelectedIndexChanged" />
        </div>

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="900px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="510px">
                <div style="margin: 0px 10px;">
                    <div style="margin-top: 10px;"></div>
                    <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" ReorderTabsOnSelect="true" Skin="MetroTouch" RenderMode="Lightweight"
                        Orientation="HorizontalTop">
                        <Tabs>
                            <telerik:RadTab Text="System Settings" Value="1" Font-Bold="false" Selected="true" PageViewID="RadPageView0" />
                            <telerik:RadTab Text="Procedure Settings" Value="2" Font-Bold="false" PageViewID="RadPageView1" Visible="false" />
                            <telerik:RadTab Text="Site Settings" Value="3" Font-Bold="false" PageViewID="RadPageView2" Visible="false" />
                            <telerik:RadTab Text="Patient Status Defaults" Value="4" Font-Bold="false" PageViewID="RadPageView3" Visible="false" />
                        </Tabs>
                    </telerik:RadTabStrip>
                    <telerik:RadMultiPage ID="RadMultiPage1" runat="server">
                        <telerik:RadPageView ID="RadPageView0" runat="server" Selected="true">
                            <div style="padding-bottom: 10px;" class="ConfigureBg">
                                <table id="ControlsTable" runat="server" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                                </table>

                                <table id="ControlsTable_ERS" runat="server" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                                    <tr valign="top">
                                        <td>
                                            <table>
                                                <tr>
                                                    <td>
                                                        <fieldset class="sysFieldset">
                                                            <legend><b>OGD diagnoses</b></legend>
                                                            <table id="table2" runat="server" cellspacing="1" cellpadding="1" border="0">
                                                                <tr>
                                                                    <td class="sysLabel">When the whole upper tract is normal the Diagnosis screen is to automatically show</td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:RadioButton ID="WholeRadioButton" runat="server" GroupName="optOGDDiag" Text="Whole upper tract normal" Checked="true" Skin="Office2007" class="sysVal" />
                                                                        <br />
                                                                        <asp:RadioButton ID="IndividualRadioButton" runat="server" GroupName="optOGDDiag" Text="Individually Oesophagus normal, Stomach normal, Duodenum normal." Skin="Office2007" class="sysVal" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                </tr>



                                                <tr>
                                                    <td>
                                                        <fieldset class="sysFieldset">
                                                            <legend><b>Urease tests</b></legend>
                                                            <table id="table4" runat="server" cellspacing="1" cellpadding="0" border="0">
                                                                <tr>
                                                                    <td colspan="2" style="width: auto;" class="sysLabel">With belated urease results you can either include tick boxes for +ve and -ve on the report, which then are manually ticked by a nurse 
                                                            <br />
                                                                        OR
                                                            <br />
                                                                        you don't include the tick boxes and reprint the report after entering the result.
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td style="width: auto;">
                                                                        <asp:CheckBox ID="UreaseTestsCheckBox" runat="server" Text="Include tick boxes on the report." /></td>
                                                                    <td>&nbsp;</td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td>
                                            <table>
                                                <tr>
                                                </tr>
                                                <tr id="trConnectionNEDDetails" runat="server" visible="false">
                                                    <td>
                                                        <fieldset class="sysFieldset1">
                                                            <legend><b>Application Options</b></legend>
                                                            <table id="table16" runat="server" cellspacing="1" cellpadding="0" border="0">
                                                                <tr style="vertical-align: middle; display: none;">
                                                                    <td style="width: 110px;">Enable National Data Set&nbsp;&nbsp;</td>
                                                                    <td>
                                                                        <asp:RadioButton ID="optNEDOn" runat="server" GroupName="optNED" Text="Enabled" />&nbsp;&nbsp;</td>
                                                                    <td>
                                                                        <asp:RadioButton ID="optNEDOff" runat="server" GroupName="optNED" Text="Disabled" /></td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="3">
                                                                        <telerik:RadButton ID="NEDTest" runat="server" Text="Test National Data Set Connection" OnClick="NEDTest_Click"></telerik:RadButton>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="3">
                                                                        <asp:Label ID="lblNEDResult" runat="server" /></td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <fieldset class="sysFieldset1">
                                                            <legend><b>Minimum Patient Search Option</b></legend>
                                                            &nbsp;<br />
                                                            <telerik:RadComboBox ID="cboMinPatSearchOptions" runat="server" Width="80px" InputCssClass="rightAligned" Skin="Office2010">
                                                                <Items>
                                                                    <telerik:RadComboBoxItem runat="server" Text="1" Value="1" CssClass="rightAligned" />
                                                                    <telerik:RadComboBoxItem runat="server" Text="2" Value="2" CssClass="rightAligned" />
                                                                    <telerik:RadComboBoxItem runat="server" Text="3" Value="3" CssClass="rightAligned" />
                                                                    <telerik:RadComboBoxItem runat="server" Text="4" Value="4" CssClass="rightAligned" />
                                                                    <telerik:RadComboBoxItem runat="server" Text="5" Value="5" CssClass="rightAligned" />
                                                                    <telerik:RadComboBoxItem runat="server" Text="6" Value="6" CssClass="rightAligned" />
                                                                    <telerik:RadComboBoxItem runat="server" Text="7" Value="7" CssClass="rightAligned" />
                                                                </Items>
                                                            </telerik:RadComboBox>
                                                            <br />
                                                            &nbsp;
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageView1" runat="server">
                            <div style="padding-bottom: 10px;" class="ConfigureBg">
                                <table runat="server" id="ProcedureTable" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td>
                                            <fieldset class="sysFieldset">
                                                <legend><b>Display referring consultant drop-down list in</b></legend>
                                                <table id="table5" runat="server" cellspacing="1" cellpadding="0" border="0">
                                                    <tr>
                                                        <td style="width: auto;">
                                                            <asp:RadioButton ID="rbConsultant_Alphabetical" runat="server" GroupName="optConsultantChecklist" Text="Alphabetical order" />
                                                            &nbsp;&nbsp;
                                                            <asp:RadioButton ID="rbConsultant_MostFrequent" runat="server" GroupName="optConsultantChecklist" Text="Most frequent referring consultant" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <fieldset class="sysFieldset">
                                                <legend><b>Record if WHO surgical safety checklist completed</b></legend>
                                                <table id="table14" runat="server" cellspacing="1" cellpadding="0" border="0">
                                                    <tr>
                                                        <td style="width: auto;">
                                                            <asp:RadioButton ID="rbSurgicalChecklistOn" runat="server" GroupName="optSurgicalChecklist" Text="On" />
                                                            &nbsp;&nbsp;
                                                            <asp:RadioButton ID="rbSurgicalChecklistOff" runat="server" GroupName="optSurgicalChecklist" Text="Off" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <fieldset class="sysFieldset">
                                                <legend><b>Record if patient has given consent</b></legend>
                                                <table id="table9" runat="server" cellspacing="1" cellpadding="0" border="0">
                                                    <tr>
                                                        <td style="width: auto;">
                                                            <asp:RadioButton ID="rbPatientConsentOn" runat="server" GroupName="optPatientConsent" Text="On" />
                                                            &nbsp;&nbsp;
                                                            <asp:RadioButton ID="rbPatientConsentOff" runat="server" GroupName="optPatientConsent" Text="Off" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <fieldset class="sysFieldset">
                                                <legend><b>Record Evidence of Cancer (Mandatory)</b></legend>
                                                <table id="table1" runat="server" cellspacing="1" cellpadding="0" border="0">
                                                    <tr>
                                                        <td style="width: auto;">
                                                            <asp:RadioButton ID="rbEvidenceOfCancerOn" runat="server" GroupName="optEvidenceOfCancer" Text="On" onclick="javascript:ToggleRadDatePicker()" />
                                                            &nbsp;&nbsp;
                                                            <asp:RadioButton ID="rbEvidenceOfCancerOff" runat="server" GroupName="optEvidenceOfCancer" Text="Off" onclick="javascript:ToggleRadDatePicker()" />
                                                            &nbsp;&nbsp;
                                                        </td>
                                                        <td id="DatePickerDateApply" style="display: inline-block; position: relative;">
                                                            <div style="display: inline-block;" id="EvidenceOfCancerMandatoryDateDiv" runat="server">
                                                                <telerik:RadDatePicker ID="CancerManFlagIgnoreBeforeRadDatePicker" Style="z-index: 9999;" runat="server" Width="100px" Skin="Metro" Culture="en-GB"
                                                                    DateInput-DateFormat="dd/MM/yyyy" DateInput-DisplayDateFormat="dd/MM/yyyy" />
                                                                <asp:RequiredFieldValidator ID="CancerManDateRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                                    ControlToValidate="CancerManFlagIgnoreBeforeRadDatePicker" EnableClientScript="true" Display="Dynamic"
                                                                    ErrorMessage="A date is required" Text="*" ToolTip="This is a required field">
                                                                </asp:RequiredFieldValidator>
                                                                <label>Applies to procedures after this date</label>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <fieldset class="sysFieldset">
                                                <legend><b>Record Patient Notes Available (Mandatory)</b></legend>
                                                <table id="table7" runat="server" cellspacing="1" cellpadding="0" border="0">
                                                    <tr>
                                                        <td style="width: auto;">
                                                            <asp:RadioButton ID="rdPatientNotesAvailableOn" runat="server" GroupName="optPatientNotesAvailable" Text="On" />
                                                            &nbsp;&nbsp;
                                                            <asp:RadioButton ID="rdPatientNotesAvailableOff" runat="server" GroupName="optPatientNotesAvailable" Text="Off" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                    <tr valign="top">
                                        <td>
                                            <fieldset class="sysFieldset">
                                                <legend><b>"Locking" report options</b></legend>
                                                <table id="table15" runat="server" cellspacing="1" cellpadding="0" border="0">
                                                    <tr>
                                                        <td style="width: auto;">
                                                            <asp:RadioButton ID="CanEditRadioButton" runat="server" GroupName="lock" Text="Reports can always be edited" Checked="true" onclick="javascript:isEditable()" />
                                                            <br />
                                                            <asp:RadioButton ID="CannotEditRadioButton" runat="server" GroupName="lock" Text="Reports must be locked (made read-only)" onclick="javascript:isEditable()" />
                                                            <div id="EditableDiv" runat="server">
                                                                <fieldset>
                                                                    <table>
                                                                        <tr>
                                                                            <td style="width: 72px;">
                                                                                <label>from (time)</label>
                                                                            </td>
                                                                            <td>
                                                                                <telerik:RadTimePicker ID="FromTimePicker" runat="server" Width="80px" SelectedTime="01:00" TimeView-TimeStyle-Height="30" />
                                                                            </td>
                                                                            <td style="padding-left: 20px;">
                                                                                <telerik:RadNumericTextBox runat="server" ID="DaysNumericTextBox" IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="1"
                                                                                    Width="65px" MinValue="0" Culture="en-GB" Value="1">
                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                </telerik:RadNumericTextBox>
                                                                            </td>
                                                                            <td>
                                                                                <label>working day(s) after the report was created</label>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </fieldset>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>

                                    <tr style="display: none">
                                        <td>
                                            <fieldset class="sysFieldset">
                                                <legend><b>BRT Pulmonary Physiology</b></legend>
                                                <table id="table17" runat="server" cellspacing="1" cellpadding="0" border="0">
                                                    <tr>
                                                        <td style="width: auto;">
                                                            <asp:RadioButtonList ID="ShowPulmonaryPhysiologyRadioButtonList" runat="server">
                                                                <asp:ListItem Value="1" Text="Display"></asp:ListItem>
                                                                <asp:ListItem Value="0" Text="Hide"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>

                                    <tr valign="top">
                                        <td>
                                            <fieldset class="sysFieldset">
                                                <legend><b>Follow-up Questions</b></legend>
                                                <div style="padding: 10px 2px; font-weight: bold;">
                                                    <span>You can add a maximum of
                                                        <asp:Label ID="MaxQuestionCountLabel" runat="server" />
                                                        questions</span>
                                                </div>
                                                <%--   <asp:UpdatePanel ID="up1" runat="server">
                                                    <ContentTemplate>--%>
                                                <telerik:RadNotification ID="PathwayPlanRadNotification" runat="server" VisibleOnPageLoad="false"/>

                                                <table id="table6" runat="server" cellspacing="0" cellpadding="0" border="0" style="width: 100%; margin-bottom: 15px;">
                                                    <tr>
                                                        <td style="width: auto;">
                                                            <table style="width: 100%;">
                                                                <tr>
                                                                    <td colspan="2" >
                                                                          <table cellspacing="0" cellpadding="0" border="0" style="width: 100%;">
                                                                            <tr>
                                                                                <td>
                                                                                   Procedure Type:
                                                                                </td>
                                                                                <td>
                                                                                   <telerik:RadComboBox ID="ProcedureTypeComboBox" runat="server" AutoPostBack="true" Skin="Metro" DataTextField="ChildNode" DataValueField="ProcedureTypeId" OnSelectedIndexChanged="ProcedureTypeComboBox_SelectedIndexChanged"/>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                    <td colspan="2">
                                                                        <table cellspacing="0" cellpadding="0" border="0" style="width: 100%;">
                                                                            <tr>
                                                                                <td align="left">
                                                                                   Question:
                                                                                </td>
                                                                                <td>
                                                                                   <telerik:RadTextBox ID="FollowUpQuestionRadTextBox" Width="100%" runat="server" Skin="Metro" />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>

                                                                <tr>
                                                                    <td>
                                                                        <asp:Label ID="QuestionAnswerOptionLabel" runat="server" Text="Yes/No option?" />
                                                                        <asp:CheckBox ID="QuestionAnswerOptionCheckBox" runat="server" />
                                                                    </td>
                                                                    <td>
                                                                        <asp:Label ID="FreeTextAnswerOptionLabel" runat="server" Text="Free text?" />
                                                                        <asp:CheckBox ID="FreeTextAnswerOptionCheckBox" runat="server" />
                                                                    </td>
                                                                    <td>
                                                                        <asp:Label ID="AnswerMandatoryLabel" runat="server" Text="Mandatory?" />
                                                                        <asp:CheckBox ID="AnswerMandatoryCheckBox" runat="server" />
                                                                    </td>
                                                                    <td align="right">
                                                                        <asp:LinkButton ID="AddQuestionLinkButton" Font-Underline="true" runat="server" Text="Add Question" OnClick="AddQuestionLinkButton_Click" ValidationGroup="FollowUpQuestions"/>
                                                                        <asp:LinkButton ID="lnkClearQuestions" runat="server" Text="Clear" CssClass="validate-error-label" OnClick="lnkClearQuestions_Click" Visible="false" />
                                                                    </td>
                                                                </tr>
                                                            </table>

                                                        </td>
                                                    </tr>
                                                </table>

                                                <asp:HiddenField ID="FollowUpQuestionIdHiddenField" runat="server" />
                                                <telerik:RadGrid ID="FollowUpQuestionsRadGrid" runat="server" AutoGenerateColumns="false" Skin="Metro" Style="margin-bottom: 10px; width: 100%;" OnItemCommand="FollowUpQuestionsRadGrid_ItemCommand" OnItemDataBound="FollowUpQuestionsRadGrid_ItemDataBound">
                                                    <MasterTableView TableLayout="Fixed" CssClass="MasterClass">
                                                        <Columns>

                                                            <telerik:GridTemplateColumn HeaderText="Order">
                                                                <ItemTemplate>
                                                                    <table>
                                                                        <tr>
                                                                            <td>
                                                                                <asp:ImageButton ID="OrderUpImageButton" runat="server" ImageUrl="../../Images/up4-64x64.png" Width="15" CommandName="reorderup" CommandArgument='<%#Eval("QuestionId") %>' Visible='<%# Not Eval("Suppressed") %>' />
                                                                                <br />
                                                                                <asp:ImageButton ID="OrderDownImageButton" runat="server" ImageUrl="../../Images/down4-64x64.png" Width="15" CommandName="reorderdown" CommandArgument='<%#Eval("QuestionId") %>' Visible='<%# Not Eval("Suppressed") %>' />
                                                                            </td>
                                                                            <td>
                                                                                <%# If(Eval("Suppressed"), "", Eval("OrderById")) %>
                                                                            </td>
                                                                        </tr>
                                                                    </table>

                                                                </ItemTemplate>
                                                            </telerik:GridTemplateColumn>
                                                            <telerik:GridBoundColumn HeaderText="Question" DataField="Question" HeaderStyle-Width="160" />
                                                            <telerik:GridTemplateColumn HeaderText="Yes/No option" HeaderStyle-Width="95">
                                                                <ItemTemplate>
                                                                    <asp:CheckBox ID="QuestionAnswerOptionCheckBox" runat="server" Checked='<%#Eval("Optional") %>' Enabled="false" />
                                                                </ItemTemplate>
                                                            </telerik:GridTemplateColumn>
                                                            <telerik:GridTemplateColumn HeaderText="Free text" HeaderStyle-Width="65">
                                                                <ItemTemplate>
                                                                    <asp:CheckBox ID="FreeTextAnswerOptionCheckBox" runat="server" Checked='<%#Eval("CanFreeText") %>' Enabled="false" />
                                                                </ItemTemplate>
                                                            </telerik:GridTemplateColumn>
                                                            <telerik:GridTemplateColumn HeaderText="Mandatory" HeaderStyle-Width="70">
                                                                <ItemTemplate>
                                                                    <asp:CheckBox ID="AnswerMandatoryCheckBox" runat="server" Checked='<%#Eval("Mandatory") %>' Enabled="false" />
                                                                </ItemTemplate>
                                                            </telerik:GridTemplateColumn>
                                                            <telerik:GridTemplateColumn HeaderStyle-Width="110">
                                                                <ItemTemplate>
                                                                    <asp:LinkButton ID="EditQuestionLinkButton" runat="server" Text="Edit" CommandArgument='<%#Eval("QuestionId") %>' CommandName="editQuestion" />&nbsp;|&nbsp;
                                                                    <asp:LinkButton ID="SuppressLinkButton" runat="server" Text="Suppress" CommandArgument='<%#Eval("QuestionId") %>' CommandName="suppressquestion" />
                                                                </ItemTemplate>
                                                            </telerik:GridTemplateColumn>
                                                        </Columns>
                                                    </MasterTableView>
                                                </telerik:RadGrid>
                                                <%--</ContentTemplate>
                                                </asp:UpdatePanel>--%>
                                            </fieldset>


                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageView2" runat="server">
                            <div style="padding-bottom: 10px;" class="ConfigureBg">
                                <table runat="server" id="siteTable" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td>
                                            <fieldset class="sysFieldset">
                                                <legend><b>Diagram Settings</b></legend>
                                                <table id="table3" runat="server" cellspacing="1" cellpadding="1" border="0">
                                                    <tr>
                                                        <td colspan="2" style="width: auto;" class="sysLabel">The sites on the diagram of the anatomy can either be identified with lower case letters of the alphabet (a, b, c) <b>OR</b> by numerics (1, 2, 3).
                                                            <br />
                                                            <br />
                                                            <b>Please Note:</b> If this option is changed, existing procedure reports will remain with the previous setting until the procedure is updated.</td>
                                                    </tr>
                                                    <tr>
                                                        <td style="width: 70px;">
                                                            <asp:RadioButton ID="rbLetters" runat="server" GroupName="optSiteLabel" Text="Letters" Checked="true" />&nbsp;&nbsp;</td>
                                                        <td>
                                                            <asp:RadioButton ID="rbNumerics" runat="server" GroupName="optSiteLabel" Text="Numerics" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2" style="width: auto;" class="sysLabel">
                                                            <br />
                                                            Radius of sites on diagram : &nbsp;
                                                <telerik:RadNumericTextBox ID="SiteRadiusRadNumericTextBox" runat="server" ClientEvents-OnValueChanged="EnableDisable"
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="0.5"
                                                    Width="35px"
                                                    MinValue="2"
                                                    MaxLength="3"
                                                    MaxValue="10">
                                                    <NumberFormat DecimalDigits="1" />
                                                </telerik:RadNumericTextBox>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageView3" runat="server">
                            <div style="padding-bottom: 10px;" class="ConfigureBg">
                                <table runat="server" id="patientDefaultTable" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="98%" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td colspan="3">
                                            <fieldset>
                                                <legend><b>Please note</b></legend>
                                                <div class="sysLabel">
                                                    This window allows you to set default values for the Patient Status area so that when you are adding a new patient, these values will be there to start with.
                                                </div>
                                            </fieldset>
                                            <br />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" style="text-align: center;">
                                            <div>
                                                Enter your default values or click the "None" button to clear them.
                                            </div>
                                            <br />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 30%;">
                                            <fieldset style="height: 110px;">
                                                <legend><b>Patient Status</b></legend>
                                                <table style="width: 100%; height: 90%;">
                                                    <tr>
                                                        <td style="width: 50%; vertical-align: middle;">
                                                            <asp:RadioButtonList ID="PatStatusRadioButtonList" runat="server" Skin="Windows7" RepeatDirection="Vertical" />
                                                        </td>
                                                        <td style="text-align: center; border-left: 1px dashed #c2d2e2;">
                                                            <telerik:RadButton ID="PatientStatusNoneButton" runat="server" Text="None" Skin="Windows7" AutoPostBack="false" OnClientClicked="RemovePatientStatus" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                        <td style="width: 30%; padding-left: 10px;">
                                            <fieldset style="height: 110px;">
                                                <legend><b>Ward</b></legend>
                                                <table style="width: 100%; height: 90%;">
                                                    <tr>
                                                        <td style="width: 70%; vertical-align: middle;">
                                                            <telerik:RadComboBox ID="WardComboBox" runat="server" Skin="Windows7" Width="150" />
                                                        </td>
                                                        <td style="text-align: center; border-left: 1px dashed #c2d2e2;">
                                                            <telerik:RadButton ID="WardNoneButton" runat="server" Text="None" Skin="Windows7" AutoPostBack="false" OnClientClicked="RemoveWard" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                        <td style="width: 30%; padding-left: 10px;">
                                            <fieldset style="height: 110px;">
                                                <legend><b>Patient Type</b></legend>
                                                <table style="width: 100%; height: 90%;">
                                                    <tr>
                                                        <td style="width: 50%; vertical-align: middle;">
                                                            <asp:RadioButtonList ID="PatientTypeRadioButtonList" runat="server" Skin="Windows7" RepeatDirection="Vertical" />
                                                        </td>
                                                        <td style="text-align: center; border-left: 1px dashed #c2d2e2;">
                                                            <telerik:RadButton ID="PatientTypeNoneButton" runat="server" Text="None" Skin="Windows7" AutoPostBack="false" OnClientClicked="RemovePatientType" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </telerik:RadPageView>
                    </telerik:RadMultiPage>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="43px" CssClass="SiteDetailsButtonsPane excluded">
                <div id="cmdOtherData" style="height: 10px; margin-top: 10px; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" OnClientClicking="ConfirmSave" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20"
                        AutoPostBack="false" OnClientClicked="RefreshPage" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </form>
</body>
</html>
