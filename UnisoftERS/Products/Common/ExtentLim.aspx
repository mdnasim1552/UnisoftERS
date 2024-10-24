<%@ Page Title="" Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_ExtentLim" CodeBehind="ExtentLim.aspx.vb" %>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>
<%@ Register Src="~/UserControls/PatientDetails.ascx" TagPrefix="uc1" TagName="PatientDetails" %>
<%@ Register Src="~/UserControls/procedurefooter.ascx" TagPrefix="uc1" TagName="procedurefooter" %>

<asp:Content ID="ELHead" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>

    <style type="text/css">
        .tableInsertionTo td {
            padding-right: 50px;
            padding-bottom: 3px;
        }

        .border_bottom {
            border-bottom: 1pt dashed #B8CBDE;
        }
        .border_left {
            border-left: 1pt dashed #B8CBDE;
        }
    </style>
</asp:Content>
<asp:Content ID="ELBody" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="cmdOtherData" Skin="Web20" />
    <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
        <telerik:RadPane ID="ControlsRadPane" runat="server" Height="505px" Scrolling="Y">
            <div>
                <telerik:RadNotification ID="CreateProcRadNotification" runat="server" Animation="None"
                    EnableRoundedCorners="true" EnableShadow="true" Title="Please correct the following"
                    LoadContentOn="PageLoad" TitleIcon="delete" Position="Center"
                    AutoCloseDelay="7000" Skin="Web20">
                    <ContentTemplate>
                        <div id="valDiv" class="aspxValidationSummary">
                        </div>
                    </ContentTemplate>
                </telerik:RadNotification>
            </div>
            <div class="otherDataHeading">
                <b>Extent/Limiting factors</b>
            </div>
            <div id="cmdOtherData" style="margin: 5px 10px;">
                <div class="rptSummaryText10">
                    <div id="ColonDiv" runat="server" style="padding-left: 10px;">
                        <div id="divInsertionVia" class="multiPageDivTab">
                            <table id="table4" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin-bottom: 3px;">
                                <tr style="vertical-align: top;">
                                    <td>
                                        <fieldset style="margin: 0px 5px; width: 720px;">
                                            <legend><b>Insertion via</b></legend>
                                            <table id="tableVia" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                <tr>
                                                    <td style="padding-right: 25px;">
                                                        <asp:RadioButton ID="InsertionAnusRadioButton" runat="server" Text="anus" GroupName="optInsertVia" Checked="true" />
                                                    </td>
                                                    <td style="padding-right: 25px;">
                                                        <asp:RadioButton ID="InsertionColostomyRadioButton" runat="server" Text="colostomy" GroupName="optInsertVia" />
                                                    </td>
                                                    <td style="padding-right: 25px;">
                                                        <asp:RadioButton ID="InsertionLoopColostomyRadioButton" runat="server" Text="loop colostomy" GroupName="optInsertVia" />
                                                    </td>
                                                    <td style="padding-right: 25px;">
                                                        <asp:RadioButton ID="InsertionCaecostomyRadioButton" runat="server" Text="caecostomy" GroupName="optInsertVia" />
                                                    </td>
                                                    <td>
                                                        <asp:RadioButton ID="InsertionIleostomyRadioButton" runat="server" Text="ileostomy" GroupName="optInsertVia" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div style="height: 10px;">
                        </div>
                        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" ReorderTabsOnSelect="true" Skin="Metro"
                            Orientation="HorizontalTop" RenderMode="Lightweight">
                            <Tabs>
                                <telerik:RadTab Text="" Font-Bold="true" Value="0" />
                                <telerik:RadTab Text="" Font-Bold="true" Value="1" />
                            </Tabs>
                        </telerik:RadTabStrip>
                        <telerik:RadMultiPage ID="RadMultiPage1" runat="server" SelectedIndex="0">
                            <telerik:RadPageView ID="RadPageView0" runat="server">
                                <div id="multiPageDivTab" class="multiPageDivTab">
                                    <table id="table1" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin-bottom: 15px;">
                                        <tr style="vertical-align: top;">
                                            <td>
                                                <fieldset style="margin: 0px 5px; width: 220px;">
                                                    <legend><b>Rectal exam (PR)</b></legend>
                                                    <table id="tableRectal" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="RectalExamNotDoneRadioButton" runat="server" Text="Not done" GroupName="optREPR" />
                                                            </td>
                                                            <td>
                                                                <asp:RadioButton ID="RectalExamDoneRadioButton" runat="server" Text="Done" GroupName="optREPR" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                            <td>
                                                <fieldset style="margin: 0px 5px; width: 220px;">
                                                    <legend><b>Retroflexion in rectum</b></legend>
                                                    <table id="tableRetroflexion" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="RetroflexionNotDoneRadioButton" runat="server" Text="Not done" GroupName="optRIR" />
                                                            </td>
                                                            <td>
                                                                <asp:RadioButton ID="RetroflexionDoneRadioButton" runat="server" Text="Done" GroupName="optRIR" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                            <td>
                                                <fieldset style="margin: 0px 5px; width: 220px;">
                                                    <legend>Abandoned</legend>
                                                    <table id="table2" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="AbandonedCheckBox" runat="server" Text="Procedure abandoned" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                        </tr>
                                    </table>
                                    <table id="tableInsertionTo" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin-bottom: 15px;">
                                        <tr style="vertical-align: top;">
                                            <td>
                                                <fieldset style="margin: 0px 5px; width: 720px;">
                                                    <legend><b>Insertion to</b><img src="../../Images/NEDJAG/JAGNED.png" /></legend>
                                                    <table id="tableInsertion" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                        <tr>
                                                            <td colspan="4">
                                                                <asp:RadioButton ID="InsertionSpecificCheckBox" runat="server" Text="Specific distance" GroupName="extlim" Enabled="false" />
                                                                &nbsp;&nbsp;<div id="InsertionSpecificDiv" style="display: none" runat="server">
                                                                    <telerik:RadNumericTextBox ID="InsertionSpecificCheckRadNumericTextBox" runat="server"
                                                                        
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="45px"
                                                                        MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px" Value="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    cm
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4" style="padding-left: 15px;"><b>--Or--</b></td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="NotRecordedCheckBox" runat="server" Text="Not recorded" GroupName="extlim" Enabled="false" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="ProximalSigmoidCheckBox" runat="server" Text="Proximal sigmoid" GroupName="extlim" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="MidTransverseCheckBox" runat="server" Text="Mid transverse" GroupName="extlim" />
                                                            </td>
                                                            <td>
                                                                <asp:RadioButton ID="CaecumCheckBox" runat="server" Text="Caecum" GroupName="extlim" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="CompleteCheckBox" runat="server" Text="Complete" GroupName="extlim" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="DistalDescendingCheckBox" runat="server" Text="Distal descending" GroupName="extlim" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="ProximalTransverseCheckBox" runat="server" Text="Proximal transverse" GroupName="extlim" />
                                                            </td>
                                                            <td>
                                                                <asp:RadioButton ID="TerminalIleumCheckBox" runat="server" Text="Terminal ileum" GroupName="extlim" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="RectumCheckBox" runat="server" Text="Rectum" GroupName="extlim" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="ProximalDescendingCheckBox" runat="server" Text="Proximal descending" GroupName="extlim" />
                                                            </td>
                                                            <td>
                                                                <asp:RadioButton ID="HepaticFlexureCheckBox" runat="server" Text="Hepatic flexure" GroupName="extlim" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="NeoTerminalCheckBox" runat="server" Text="Neo-terminal ileum" GroupName="extlim" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="RectoSigmoidCheckBox" runat="server" Text="Recto-sigmoid" GroupName="extlim" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="SplenicFlexureCheckBox" runat="server" Text="Splenic flexure" GroupName="extlim" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="DistalAscendingCheckBox" runat="server" Text="Distal ascending" GroupName="extlim" />
                                                            </td>
                                                            <td></td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="DistalSigmoidCheckBox" runat="server" Text="Distal sigmoid" GroupName="extlim" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="DistalTransverseCheckBox" runat="server" Text="Distal transverse" GroupName="extlim" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="ProximalAscendingCheckBox" runat="server" Text="Proximal ascending" GroupName="extlim" />
                                                            </td>
                                                            <td></td>
                                                        </tr>
                                                        <tr runat="server" id="trResection" visible="false">
                                                            <td colspan="4" style="padding-left: 15px;"><b>--Resection--</b></td>
                                                        </tr>
                                                        <tr runat="server" id="trResectionDetails" visible="false">
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="AnastomosisCheckBox" runat="server" Text="Anastomosis" GroupName="extlim" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="IleoColonCheckBox" runat="server" Text="Ileo-colon anastomosis" GroupName="extlim" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="PouchCheckBox" runat="server" Text="Pouch" GroupName="extlim" />
                                                            </td>
                                                            <td></td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4" style="height: 7px;"></td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4">
                                                                <table id="InsertionTable" runat="server" cellspacing="2" cellpadding="0" border="0">
                                                                    <tr class="InsertionConfirmedTr" id="InsertionConfirmedTrID" runat="server">
                                                                        <td style="width: 2px;"></td>
                                                                        <td style="width: 150px;"><b>
                                                                            <asp:Label runat="server" ID="InsertionByLabel" Text="Insertion confirmed by" /> <img src="../../Images/NEDJAG/JAG.png" />
                                                                        </b></td>
                                                                        <td>
                                                                            <telerik:RadComboBox ID="InsertionComfirmedRadComboBox" runat="server" Skin="Windows7" Width="350" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr class="InsertionLimitedTr" id="InsertionLimitedTrID" runat="server">
                                                                        <td></td>
                                                                        <td><b>
                                                                            <asp:Label runat="server" ID="InsertionlimitedLabel" Text="Insertion limited by" /><img src="../../Images/NEDJAG/JAGNED.png" />
                                                                        </b></td>
                                                                        <td>
                                                                            <telerik:RadComboBox ID="InsertionLimitedRadComboBox" runat="server" Skin="Windows7" Width="350" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr id="DifficultiesEncounteredTr" runat="server">
                                                                        <td></td>
                                                                        <td><b>
                                                                            <asp:Label runat="server" ID="DifficultiesLabel" Text="Difficulties encountered" /><img src="../../Images/NEDJAG/JAG.png" />
                                                                        </b></td>
                                                                        <td>
                                                                            <telerik:RadComboBox ID="DifficultiesEncounteredRadComboBox" runat="server" Skin="Windows7" Width="350" />
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                        </tr>
                                    </table>
                                    <table id="tableCaecumIdentifiedBy" runat="server" cellspacing="0" cellpadding="0" border="0">
                                        <tr style="vertical-align: top;">
                                            <td>
                                                <fieldset style="margin: 0px 5px; width: 720px;">
                                                    <legend><b>Caecum identified by</b><img src="../../Images/NEDJAG/JAGNED.png" /></legend>
                                                    <table id="table9" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="IleocecalValveCheckBox" runat="server" Text="ileocecal valve" Width="240px" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="TransIlluminationCheckBox" runat="server" Text="transillumination" Width="240px" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="IlealIntubationCheckBox" runat="server" Text="ileal intubation" Width="240px" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="AppendicularOrificeCheckBox" runat="server" Text="appendicular orifice" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="TriRadiateCheckBox" runat="server" Text="tri-radiate caecal fold" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="DigitalPressureCheckBox" runat="server" Text="digital pressure" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="ConfidenceDegreeCheckBox" runat="server" Text="degree of confidence" />
                                                                &nbsp;&nbsp;</td>
                                                            <td colspan="2">
                                                                <asp:RadioButton ID="PositivelyRadioButton" runat="server" Text="positively" GroupName="optCaecum" />
                                                                &nbsp;&nbsp;<asp:RadioButton ID="WithReasonableConfidenceRadioButton" runat="server" Text="with reasonable confidence" GroupName="optCaecum" />
                                                            </td>
                                                        </tr>
                                                        <tr class="CaecumTimeTr" id="CaecumTimeTrID" runat="server">
                                                            <td colspan="3">
                                                                <table  style="border-collapse:separate;border-spacing:0 5px;">
                                                                    <tr>
                                                                        <td>
                                                                            <asp:Label runat="server" ID="TimetocaecumLabel" Text="Time to caecum" Width="150px" />
                                                                            <telerik:RadNumericTextBox ID="TimeToCaecumMinRadNumericTextBox" runat="server"
                                                                                
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="45px"
                                                                                MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                            <asp:Label runat="server" ID="MinLabel1" Text="min" />
                                                                            <telerik:RadNumericTextBox ID="TimeToCaecumSecRadNumericTextBox" runat="server"
                                                                                
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="45px"
                                                                                MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                            <asp:Label runat="server" ID="SecLabel" Text="sec" />
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                    </table>
                                    <fieldset style="margin: 0px 5px; width: 720px;">
                                        <legend><b>Withdrawal Time&nbsp;</b><img src="../../Images/NEDJAG/JAGNED.png" /></legend>
                                        <table id="table7" runat="server" cellspacing="0" cellpadding="0" border="0">
                                            <tr style="vertical-align: top;">
                                                <td>
                                                    <asp:Label runat="server" ID="TimeforwithdrawalLabel" Text="Time for withdrawal" Width="150px" />
                                                    <telerik:RadNumericTextBox ID="TimeForWithdrawalMinRadNumericTextBox" runat="server"
                                                        
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="45px"
                                                        MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>
                                                    <asp:Label runat="server" ID="Label1" Text="min" />
                                                    <telerik:RadNumericTextBox ID="TimeForWithdrawalSecRadNumericTextBox" runat="server"
                                                        
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="45px"
                                                        MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>
                                                    <asp:Label runat="server" ID="SecLabel2" Text="sec" />
                                                    </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView1" runat="server">
                                <div id="multiPageTrainerDivTab" class="multiPageDivTab">
                                    <table id="table6" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin-bottom: 15px;">
                                        <tr style="vertical-align: top;">
                                            <td>
                                                <fieldset style="margin: 0px 5px; width: 220px;">
                                                    <legend><b>Rectal exam (PR)</b></legend>
                                                    <table id="tableRectal_NED" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="RectalExamNotDoneRadioButton_NED" runat="server" Text="Not done" GroupName="optREPR_NED" />
                                                            </td>
                                                            <td>
                                                                <asp:RadioButton ID="RectalExamDoneRadioButton_NED" runat="server" Text="Done" GroupName="optREPR_NED" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                            <td>
                                                <fieldset style="margin: 0px 5px; width: 220px;">
                                                    <legend><b>Retroflexion in rectum</b></legend>
                                                    <table id="tableRetroflexion_NED" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="RetroflexionNotDoneRadioButton_NED" runat="server" Text="Not done" GroupName="optRIR_NED" />
                                                            </td>
                                                            <td>
                                                                <asp:RadioButton ID="RetroflexionDoneRadioButton_NED" runat="server" Text="Done" GroupName="optRIR_NED" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                            <td>
                                                <fieldset style="margin: 0px 5px; width: 220px;">
                                                    <legend>Abandoned</legend>
                                                    <table id="table10" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="AbandonedCheckBox_NED" runat="server" Text="Procedure abandoned" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                        </tr>
                                    </table>
                                    <table id="tableInsertionTo_NED" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin-bottom: 15px;">
                                        <tr style="vertical-align: top;">
                                            <td>
                                                <fieldset style="margin: 0px 5px; width: 720px;">
                                                    <legend><b>Insertion to</b><img src="../../Images/NEDJAG/JAGNED.png" /></legend>
                                                    <table id="tableInsertion_NED" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                        <tr>
                                                            <td colspan="4">
                                                                <asp:RadioButton ID="InsertionSpecificCheckBox_NED" runat="server" Text="Specific distance" GroupName="extlim_NED" Enabled="false" />
                                                                &nbsp;&nbsp;<div id="InsertionSpecificDiv_NED" style="display: none" runat="server">
                                                                    <telerik:RadNumericTextBox ID="InsertionSpecificCheckRadNumericTextBox_NED" runat="server"
                                                                        
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="45px"
                                                                        MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px" Value="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    cm
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4" style="padding-left: 15px;"><b>--Or--</b></td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="NotRecordedCheckBox_NED" runat="server" Text="Not recorded" GroupName="extlim_NED" Enabled="false" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="ProximalSigmoidCheckBox_NED" runat="server" Text="Proximal sigmoid" GroupName="extlim_NED" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="MidTransverseCheckBox_NED" runat="server" Text="Mid transverse" GroupName="extlim_NED" />
                                                            </td>
                                                            <td>
                                                                <asp:RadioButton ID="CaecumCheckBox_NED" runat="server" Text="Caecum" GroupName="extlim_NED" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="CompleteCheckBox_NED" runat="server" Text="Complete" GroupName="extlim_NED" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="DistalDescendingCheckBox_NED" runat="server" Text="Distal descending" GroupName="extlim_NED" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="ProximalTransverseCheckBox_NED" runat="server" Text="Proximal transverse" GroupName="extlim_NED" />
                                                            </td>
                                                            <td>
                                                                <asp:RadioButton ID="TerminalIleumCheckBox_NED" runat="server" Text="Terminal ileum" GroupName="extlim_NED" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="RectumCheckBox_NED" runat="server" Text="Rectum" GroupName="extlim_NED" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="ProximalDescendingCheckBox_NED" runat="server" Text="Proximal descending" GroupName="extlim_NED" />
                                                            </td>
                                                            <td>
                                                                <asp:RadioButton ID="HepaticFlexureCheckBox_NED" runat="server" Text="Hepatic flexure" GroupName="extlim_NED" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="NeoTerminalCheckBox_NED" runat="server" Text="Neo-terminal ileum" GroupName="extlim_NED" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="RectoSigmoidCheckBox_NED" runat="server" Text="Recto-sigmoid" GroupName="extlim_NED" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="SplenicFlexureCheckBox_NED" runat="server" Text="Splenic flexure" GroupName="extlim_NED" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="DistalAscendingCheckBox_NED" runat="server" Text="Distal ascending" GroupName="extlim_NED" />
                                                            </td>
                                                            <td></td>
                                                        </tr>
                                                        <tr>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="DistalSigmoidCheckBox_NED" runat="server" Text="Distal sigmoid" GroupName="extlim_NED" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="DistalTransverseCheckBox_NED" runat="server" Text="Distal transverse" GroupName="extlim_NED" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="ProximalAscendingCheckBox_NED" runat="server" Text="Proximal ascending" GroupName="extlim_NED" />
                                                            </td>
                                                            <td></td>
                                                        </tr>
                                                        <tr runat="server" id="trResection_NED" visible="false">
                                                            <td colspan="4" style="padding-left: 15px;"><b>--Resection--</b></td>
                                                        </tr>
                                                        <tr runat="server" id="trResectionDetails_NED" visible="false">
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="AnastomosisCheckBox_NED" runat="server" Text="Anastomosis" GroupName="extlim_NED" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="IleoColonCheckBox_NED" runat="server" Text="Ileo-colon anastomosis" GroupName="extlim_NED" />
                                                            </td>
                                                            <td style="padding-right: 25px;">
                                                                <asp:RadioButton ID="PouchCheckBox_NED" runat="server" Text="Pouch" GroupName="extlim_NED" />
                                                            </td>
                                                            <td></td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4" style="height: 7px;"></td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4">
                                                                <table id="InsertionTable_NED" runat="server" cellspacing="2" cellpadding="0" border="0">
                                                                    <tr class="InsertionConfirmedTr" id="InsertionConfirmedTrID_NED" runat="server">
                                                                        <td style="width: 2px;"></td>
                                                                        <td style="width: 150px;"><b>
                                                                            <asp:Label runat="server" ID="InsertionByLabel_NED" Text="Insertion confirmed by" /><img src="../../Images/NEDJAG/JAG.png" />
                                                                        </b></td>
                                                                        <td>
                                                                            <telerik:RadComboBox ID="InsertionComfirmedRadComboBox_NED" runat="server" Skin="Windows7" Width="350" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr class="InsertionLimitedTr" id="InsertionLimitedTrID_NED" runat="server">
                                                                        <td></td>
                                                                        <td><b>
                                                                            
                                                                            <asp:Label runat="server" ID="InsertionlimitedLabel_NED" Text="Insertion limited by" /><img src="../../Images/NEDJAG/JAGNED.png" />
                                                                        </b></td>
                                                                        <td>
                                                                            <telerik:RadComboBox ID="InsertionLimitedRadComboBox_NED" runat="server" Skin="Windows7" Width="350" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr id="DifficultiesEncounteredTr_NED" runat="server">
                                                                        <td></td>
                                                                        <td><b>
                                                                            <asp:Label runat="server" ID="DifficultiesLabel_NED" Text="Difficulties encountered" /><img src="../../Images/NEDJAG/JAG.png" />
                                                                        </b></td>
                                                                        <td>
                                                                            <telerik:RadComboBox ID="DifficultiesEncounteredRadComboBox_NED" runat="server" Skin="Windows7" Width="350" />
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </fieldset>
                                            </td>
                                        </tr>
                                    </table>
                                    <table id="tableCaecumIdentifiedBy_NED" runat="server" cellspacing="0" cellpadding="0" border="0">
                                        <tr style="vertical-align: top;">
                                            <td>
                                                <fieldset style="margin: 0px 5px; width: 720px;">
                                                    <legend><b>Caecum identified by</b><img src="../../Images/NEDJAG/JAGNED.png" /></legend>
                                                    <table id="table15" runat="server" cellspacing="0" cellpadding="0" border="0">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="IleocecalValveCheckBox_NED" runat="server" Text="ileocecal valve" Width="240px" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="TransIlluminationCheckBox_NED" runat="server" Text="transillumination" Width="240px" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="IlealIntubationCheckBox_NED" runat="server" Text="ileal intubation" Width="240px" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="AppendicularOrificeCheckBox_NED" runat="server" Text="appendicular orifice" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="TriRadiateCheckBox_NED" runat="server" Text="tri-radiate caecal fold" />
                                                            </td>
                                                            <td>
                                                                <asp:CheckBox ID="DigitalPressureCheckBox_NED" runat="server" Text="digital pressure" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox ID="ConfidenceDegreeCheckBox_NED" runat="server" Text="degree of confidence" />
                                                            </td>
                                                            <td colspan="2">
                                                                <asp:RadioButton ID="PositivelyRadioButton_NED" runat="server" Text="positively" GroupName="optCaecum_NED" />
                                                                &nbsp;&nbsp;<asp:RadioButton ID="WithReasonableConfidenceRadioButton_NED" runat="server" Text="with reasonable confidence" GroupName="optCaecum_NED" />
                                                            </td>
                                                        </tr>

                                                        <tr class="CaecumTimeTr" id="CaecumTimeTrID_NED" runat="server">
                                                            <td colspan="3">
                                                                <table>
                                                                    <tr>
                                                                        <td>
                                                                            <asp:Label runat="server" ID="TimetocaecumLabel_NED" Text="Time to caecum" Width="150px" />
                                                                            <telerik:RadNumericTextBox ID="TimeToCaecumMinRadNumericTextBox_NED" runat="server"
                                                                                
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="45px"
                                                                                MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px" Value="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                            <asp:Label runat="server" ID="MinLabel1_NED" Text="min" />
                                                                            <telerik:RadNumericTextBox ID="TimeToCaecumSecRadNumericTextBox_NED" runat="server"
                                                                                
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="45px"
                                                                                MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px" Value="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                            <asp:Label runat="server" ID="SecLabel_NED" Text="sec" />
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>

                                                </fieldset>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                        </tr>
                                    </table>
                                    <fieldset style="margin: 0px 5px; width: 720px;">
                                        <legend><b>Withdrawal Time&nbsp;</b><img src="../../Images/NEDJAG/JAGNED.png" /></legend>
                                        <table id="table8" runat="server" cellspacing="0" cellpadding="0" border="0">
                                            <tr style="vertical-align: top;">
                                                <td>
                                                    <asp:Label runat="server" ID="TimeforwithdrawalLabel_NED" Text="Time for withdrawal" Width="150px" />
                                                    <telerik:RadNumericTextBox ID="TimeForWithdrawalMinRadNumericTextBox_NED" runat="server"
                                                        
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="45px"
                                                        MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px" Value="0">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>
                                                    <asp:Label runat="server" ID="MinLabel2_NED" Text="min" />
                                                    <telerik:RadNumericTextBox ID="TimeForWithdrawalSecRadNumericTextBox_NED" runat="server"
                                                        
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="45px"
                                                        MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px" Value="0">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>
                                                    <asp:Label runat="server" ID="SecLabel2_NED" Text="sec" />
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>
                    </div>
                    <div id="RetrogradeDiv" runat="server" class="multiPageDivTab" style="margin-left: 10px;">
                        <table id="RetrogradeTable" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin-bottom: 5px;">
                            <tr style="vertical-align: top;">
                                <td>
                                    <fieldset style="margin: 0px 5px; width: 720px;">
                                        <legend><b>Insertion via</b></legend>
                                        <table id="table5" runat="server" cellspacing="0" cellpadding="0" border="0">
                                            <tr>
                                                <td style="padding-right: 25px;">
                                                    <asp:RadioButton ID="InsertionViaDuoRadioButton" runat="server" Text="duodenum" GroupName="optInsertVia" />
                                                </td>
                                                <td style="padding-right: 25px;">
                                                    <asp:RadioButton ID="InsertionViaColRadioButton" runat="server" Text="colon" GroupName="optInsertVia" />
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                            <tr>
                                <td style="height: 10px;"></td>
                            </tr>
                            <tr style="vertical-align: top;">
                                <td>
                                    <fieldset style="margin: 0px 5px; width: 720px;">
                                        <table id="table3" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin-top: 10px;">
                                            <tr>
                                                <td style="padding-right: 25px;">Distance from ICV
                                                </td>
                                                <td style="">
                                                    <telerik:RadNumericTextBox ID="DistanceFromICVNumericTextBox" runat="server"
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="50px"
                                                        MinValue="0">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>
                                                    cm
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="height: 10px;"></td>
                                            </tr>
                                            <tr>
                                                <td style="padding-right: 25px;">No of loops
                                                </td>
                                                <td style="">
                                                    <telerik:RadNumericTextBox ID="NoOfLoopsNumericTextBox" runat="server"
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="50px"
                                                        MinValue="0">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </telerik:RadPane>
        <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
            <div style="height: 10px; margin-left: 10px; padding-top: 2px; padding-bottom: 2px">
                <telerik:RadButton ID="cmdAccept" runat="server" Text="Save & Close" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                <telerik:RadButton ID="cmdCancel" runat="server" Text="Cancel" Skin="Web20" OnClick="cancelRecord" Icon-PrimaryIconCssClass="telerikCancelButton" />
            </div>
            <div style="height:0px; display:none">
                <telerik:RadButton ID="SaveOnly" runat="server" Text="Save" Skin="Web20" OnClick="SaveOnly_Click" style="height:1px; width:1px" />
            </div>       
        </telerik:RadPane>
    </telerik:RadSplitter>

    <telerik:RadScriptBlock ID="RadScriptBlock11" runat="server">
        <script type="text/javascript">
            window.onbeforeunload = function (event) {
                document.getElementById("<%= SaveOnly.ClientID %>").click();
            }

            $(document).ready(function () {
                $(window).on('load', function () {
                    var showInsertionTable = false;
                    var showInsertionTable_NED = false;
                    $("#<%= tableInsertion.ClientID%> tr td input:radio").each(function () {
                        if ($(this).is(":checked")) {
                            showInsertionTable = true;
                            return;
                        }
                    });
                    $("#<%= tableInsertion_NED.ClientID%> tr td input:radio").each(function () {
                        if ($(this).is(":checked")) {
                            showInsertionTable_NED = true;
                            return;
                        }
                    });
                    ToggleTRs(showInsertionTable);
                    ToggleTRs_NED(showInsertionTable_NED);
                });

                $("#<%= tableInsertion.ClientID%> tr td input:radio").change(function () {
                    ToggleTRs(true);
                });

                $("#<%= tableInsertion_NED.ClientID%> tr td input:radio").change(function () {
                    ToggleTRs_NED(true);
                });

                $("#<%= ConfidenceDegreeCheckBox.ClientID%>").change(function () {
                    if ($("#<%= ConfidenceDegreeCheckBox.ClientID%>").is(":checked")) {
                        $("#<%= PositivelyRadioButton.ClientID%>").prop("checked", true);
                    } else {
                        $("#<%= PositivelyRadioButton.ClientID%>").prop("checked", false);
                        $("#<%= WithReasonableConfidenceRadioButton.ClientID%>").prop("checked", false);
                    }
                });
                $("#<%= PositivelyRadioButton.ClientID%>").change(function () {
                    if ($("#<%= PositivelyRadioButton.ClientID%>").is(":checked")) {
                        $("#<%= ConfidenceDegreeCheckBox.ClientID%>").prop("checked", true);
                    }
                });
                $("#<%= WithReasonableConfidenceRadioButton.ClientID%>").change(function () {
                    if ($("#<%= WithReasonableConfidenceRadioButton.ClientID%>").is(":checked")) {
                        $("#<%= ConfidenceDegreeCheckBox.ClientID%>").prop("checked", true);
                    }
                });

                $("#<%= ConfidenceDegreeCheckBox_NED.ClientID%>").change(function () {
                    if ($("#<%= ConfidenceDegreeCheckBox_NED.ClientID%>").is(":checked")) {
                        $("#<%= PositivelyRadioButton_NED.ClientID%>").prop("checked", true);
                    } else {
                        $("#<%= PositivelyRadioButton_NED.ClientID%>").prop("checked", false);
                        $("#<%= WithReasonableConfidenceRadioButton_NED.ClientID%>").prop("checked", false);
                    }
                });
                $("#<%= PositivelyRadioButton_NED.ClientID%>").change(function () {
                    if ($("#<%= PositivelyRadioButton_NED.ClientID%>").is(":checked")) {
                        $("#<%= ConfidenceDegreeCheckBox_NED.ClientID%>").prop("checked", true);
                    }
                });
                $("#<%= WithReasonableConfidenceRadioButton_NED.ClientID%>").change(function () {
                    if ($("#<%= WithReasonableConfidenceRadioButton_NED.ClientID%>").is(":checked")) {
                        $("#<%= ConfidenceDegreeCheckBox_NED.ClientID%>").prop("checked", true);
                    }
                });
            });


            function ToggleTRs(showInsertionTable) {
                var ckbox = $find("<%= InsertionLimitedRadComboBox.ClientID%>");
                var ckbox1 = $find("<%= InsertionComfirmedRadComboBox.ClientID%>");
                var ckbox2 = $find("<%= DifficultiesEncounteredRadComboBox.ClientID%>");

                if ($("#<%= InsertionSpecificCheckBox.ClientID%>").is(":checked")) {
                    $("#<%= InsertionSpecificDiv.ClientID%>").css('display', 'inline-block');
                } else {
                    $("#<%= InsertionSpecificDiv.ClientID%>").css('display', 'none');
                    $("#<%= InsertionSpecificCheckRadNumericTextBox.ClientID%>").val("0");
                }

                $("#<%= InsertionTable.ClientID%>").hide();
                $("#<%= tableCaecumIdentifiedBy.ClientID%>").hide();

                if ($("#<%= NotRecordedCheckBox.ClientID%>").is(":checked") || $("#<%= InsertionSpecificCheckBox.ClientID%>").is(":checked")) {
                    ckbox.clearSelection();
                    ckbox1.clearSelection();
                    ckbox2.clearSelection();
                    ClearControls($("#<%= tableCaecumIdentifiedBy.ClientID%>"));
                }
                else if ($("#<%= CaecumCheckBox.ClientID%>").is(":checked") || $("#<%= TerminalIleumCheckBox.ClientID%>").is(":checked")
                    || $("#<%= AnastomosisCheckBox.ClientID%>").is(":checked")) {
                    ckbox.clearSelection();
                    ckbox1.clearSelection();
                    ckbox2.clearSelection();
                    $("#<%= tableCaecumIdentifiedBy.ClientID%>").show();
                }
                else if (showInsertionTable == true) {
                    $("#<%= InsertionTable.ClientID%>").show();
                    if ($("#<%= NeoTerminalCheckBox.ClientID%>").is(":checked")) {
                        $("#<%= InsertionLimitedTrID.ClientID%>").hide();
                        $("#<%= DifficultiesEncounteredTr.ClientID%>").hide();
                        var insertionLimit = $find('<%= InsertionLimitedRadComboBox.ClientID %>');
                        insertionLimit.clearSelection();
                        var difficultiesEncountered = $find('<%= DifficultiesEncounteredRadComboBox.ClientID %>');
                        difficultiesEncountered.clearSelection();
                    }
                    else {
                        $("#<%= InsertionLimitedTrID.ClientID%>").show();
                        $("#<%= DifficultiesEncounteredTr.ClientID%>").show();
                    }
                    ClearControls($("#<%= tableCaecumIdentifiedBy.ClientID%>"));
                }
            }

            function ToggleTRs_NED(showInsertionTable) {
                var ckbox = $find("<%= InsertionLimitedRadComboBox_NED.ClientID%>");
                var ckbox1 = $find("<%= InsertionComfirmedRadComboBox_NED.ClientID%>");
                var ckbox2 = $find("<%= DifficultiesEncounteredRadComboBox_NED.ClientID%>");

                if ($("#<%= InsertionSpecificCheckBox_NED.ClientID%>").is(":checked")) {
                    $("#<%= InsertionSpecificDiv_NED.ClientID%>").css('display', 'inline-block');
                } else {
                    $("#<%= InsertionSpecificDiv_NED.ClientID%>").css('display', 'none');
                    $("#<%= InsertionSpecificCheckRadNumericTextBox_NED.ClientID%>").val("0");
                }

                $("#<%= InsertionTable_NED.ClientID%>").hide();
                $("#<%= tableCaecumIdentifiedBy_NED.ClientID%>").hide();

                if ($("#<%= NotRecordedCheckBox_NED.ClientID%>").is(":checked") || $("#<%= InsertionSpecificCheckBox_NED.ClientID%>").is(":checked")) {
                    ckbox.clearSelection();
                    ckbox1.clearSelection();
                    ckbox2.clearSelection();
                    ClearControls($("#<%= tableCaecumIdentifiedBy_NED.ClientID%>"));
                }
                else if ($("#<%= CaecumCheckBox_NED.ClientID%>").is(":checked") || $("#<%= TerminalIleumCheckBox_NED.ClientID%>").is(":checked")
                    || $("#<%= AnastomosisCheckBox_NED.ClientID%>").is(":checked")) {
                    ckbox.clearSelection();
                    ckbox1.clearSelection();
                    ckbox2.clearSelection();

                    $("#<%= tableCaecumIdentifiedBy_NED.ClientID%>").show();
                }
                else if (showInsertionTable == true) {
                    $("#<%= InsertionTable_NED.ClientID%>").show();
                    if ($("#<%= NeoTerminalCheckBox_NED.ClientID%>").is(":checked")) {
                        $("#<%= InsertionLimitedTrID_NED.ClientID%>").hide();
                        $("#<%= DifficultiesEncounteredTr_NED.ClientID%>").hide();
                        var insertionLimit = $find('<%= InsertionLimitedRadComboBox_NED.ClientID %>');
                        insertionLimit.clearSelection();
                        var difficultiesEncountered = $find('<%= DifficultiesEncounteredRadComboBox_NED.ClientID %>');
                        difficultiesEncountered.clearSelection();
                    }
                    else {
                        $("#<%= InsertionLimitedTrID_NED.ClientID%>").show();
                        $("#<%= DifficultiesEncounteredTr_NED.ClientID%>").show();
                    }

                    ClearControls($("#<%= tableCaecumIdentifiedBy_NED.ClientID%>"));
                }
            }

            function ClearControls(tableCell) {
                tableCell.find("input:radio:checked").removeAttr("checked");
                tableCell.find("input:checkbox:checked").removeAttr("checked");
                tableCell.find("input:text").val("");
            }

            function Validate(sender, args) {
                var jstr = <%= ValidatorString%>
                    document.getElementById("valDiv").innerHTML = '';
                if (jstr["validateRectal"] == true) { validateRectal(sender, args); }
                //if (jstr["validateRetroflexion"] == true) { validateRetroflexion(sender, args); }
                if (jstr["validateVia"] == true) { validateVia(sender, args); }
                //if (jstr["validateInsertto"] == true) { validateInsertto(sender, args); }
                //if (jstr["validateLimitedby"] == true) { validateLimitedby(sender, args); }         
            }
            function validateVia(sender, args) {
                var validate = false;
                $("#<%= tableVia.ClientID%> input:radio").each(function () {
                    if ($(this).is(':checked')) { validate = true; return false; }
                });
                if (validate == true) { return; }
                else {
                    args.set_cancel(true);
                    var msg = document.getElementById("valDiv").innerHTML;
                    if (msg == null || msg == '') {
                        document.getElementById("valDiv").innerHTML = "* You must record extent and limiting factors (Insertion via) for this procedure.";
                    } else {
                        document.getElementById("valDiv").innerHTML = msg + "<br/> * You must record extent and limiting factors (Insertion via) for this procedure.";
                    }

                    $find("<%=CreateProcRadNotification.ClientID%>").show();
                }
            }
            function validateLimitedby(sender, args) {
                var validate = false;
                if ($find("<%= InsertionLimitedRadComboBox.ClientID%>").get_text() != '(none)' && $find("<%= InsertionLimitedRadComboBox.ClientID%>").get_text() != '') {
                    validate = true;
                }
                if (!$("#<%= InsertionTable.ClientID%>").is(":visible")) { validate = true; return false; }
                if (validate == true) { return; }
                else {
                    args.set_cancel(true);
                    var msg = document.getElementById("valDiv").innerHTML;
                    if (msg == null || msg == '') {
                        document.getElementById("valDiv").innerHTML = "* You must record extent and limiting factors (Insertion limited by) for this procedure.";
                    } else {
                        document.getElementById("valDiv").innerHTML = msg + "<br/> * You must record extent and limiting factors (Insertion limited by) for this procedure.";
                    }

                    $find("<%=CreateProcRadNotification.ClientID%>").show();
                }
            }
            function validateInsertto(sender, args) {
                var validate = false;
                $("#<%= tableInsertion.ClientID%> input:radio").each(function () {
                    if ($(this).is(':checked')) { validate = true; return false; }
                });
                if (validate == true) { return; }
                else {
                    args.set_cancel(true);
                    var msg = document.getElementById("valDiv").innerHTML;
                    if (msg == null || msg == '') {
                        document.getElementById("valDiv").innerHTML = "* You must record extent and limiting factors (Insertion to) for this procedure.";
                    } else {
                        document.getElementById("valDiv").innerHTML = msg + "<br/> * You must record extent and limiting factors (Insertion to) for this procedure.";
                    }

                    $find("<%=CreateProcRadNotification.ClientID%>").show();
                }
            }

            function validateRetroflexion(sender, args) {
                var validate = false;
                $("#<%= tableRetroflexion.ClientID%> input:radio").each(function () {
                    if ($(this).is(':checked')) { validate = true; return false; }
                });
                if (validate == true) { return; }
                else {
                    args.set_cancel(true);
                    var msg = document.getElementById("valDiv").innerHTML;
                    if (msg == null || msg == '') {
                        document.getElementById("valDiv").innerHTML = "* You must record extent and limiting factors (Retroflexion in rectum) for this procedure.";
                    } else {
                        document.getElementById("valDiv").innerHTML = msg + "<br/> * You must record extent and limiting factors (Retroflexion in rectum) for this procedure.";
                    }

                    $find("<%=CreateProcRadNotification.ClientID%>").show();
                }
            }
            function validateRectal(sender, args) {
                var validate = false;
                $("#<%= tableRectal.ClientID%> input:radio").each(function () {
                    if ($(this).is(':checked')) { validate = true; return false; }
                });
                if (validate == true) { return; }
                else {
                    args.set_cancel(true);
                    var msg = document.getElementById("valDiv").innerHTML;
                    if (msg == null || msg == '') {
                        document.getElementById("valDiv").innerHTML = "* You must record extent and limiting factors (Rectal exam (PR)) for this procedure.";
                    } else {
                        document.getElementById("valDiv").innerHTML = msg + "<br/> * You must record extent and limiting factors (Rectal exam (PR)) for this procedure.";
                    }

                    $find("<%=CreateProcRadNotification.ClientID%>").show();
                }
            }
        </script>
    </telerik:RadScriptBlock>

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
    </telerik:RadAjaxLoadingPanel>
</asp:Content>
