<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="PolypDetails.aspx.vb" Inherits="UnisoftERS.PolypDetails" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../../Styles/Site.css" rel="stylesheet" />
    <script src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../../../Scripts/global.js"></script>
    <style type="text/css">
        .inner-table td {
            border: none;
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
            <script type="text/javascript">

                function savePage() {
                    $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
                }

                $(document).ready(function () {
                    $('.labs-cb input').on('change', function () {
                        if ($(this).is(':checked')) {
                            $(this).closest('tr').find('.polypectomy-result input').prop("checked", true);
                        }
                    });
                });

                function showSessileParisPopup(polypId, value) {
                    $('#<%=SessileLSRadioButton.ClientID%>').attr('checked', (value == 1));
                    $('#<%=SessileLLARadioButton.ClientID%>').attr('checked', (value == 2));
                    $('#<%=SessileLLALLCRadioButton.ClientID%>').attr('checked', (value == 3));
                    $('#<%=SessileLLBRadioButton.ClientID%>').attr('checked', (value == 4));
                    $('#<%=SessileLLCRadioButton.ClientID%>').attr('checked', (value == 5));
                    $('#<%=SessileLLCLLARadioButton.ClientID%>').attr('checked', (value == 6));

                    $find('<%=SessileParisClassificationRadButton.ClientID%>').set_commandArgument(polypId);
                    var oWnd = $find('<%=SessileParisClassificationPopup.ClientID%>');
                    oWnd.show();
                    return false;
                }

                function showPedunculatedParisPopup(polypId, value) {
                    $('#<%=ProtrudedRadioButton.ClientID%>').attr('checked', (value == 1));
                    $('#<%=PedunculatedRadioButton.ClientID%>').attr('checked', (value == 2));

                    $find('<%=PedunculatedParisClassificationRadButton.ClientID%>').set_commandArgument(polypId);
                    var oWnd = $find('<%=PedunculatedParisClassificationPopUp.ClientID%>');
                    oWnd.show();
                    return false;
                }

                function showSessilePitPatternsPopup(polypId, value) {
                    $('#<%=SessileNormalRoundPitsRadioButton.ClientID%>').attr('checked', (value == 1));
                    $('#<%=SessileStellarRadioButton.ClientID%>').attr('checked', (value == 2));
                    $('#<%=SessileTubularRoundPitsRadioButton.ClientID%>').attr('checked', (value == 3));
                    $('#<%=SessileTubularRadioButton.ClientID%>').attr('checked', (value == 4));
                    $('#<%=SessileSulcusRadioButton.ClientID%>').attr('checked', (value == 5));
                    $('#<%=SessileLossRadioButton.ClientID%>').attr('checked', (value == 6));

                    $find('<%=SessilePitPatternsRadButton.ClientID%>').set_commandArgument(polypId);
                    var oWnd = $find('<%=SessilePitPatternsPopup.ClientID%>');
                    oWnd.show();
                    return false;
                }

                function showPedunculatedPitPatternsPopup(polypId, value) {
                    $('#<%=PedunculatedNormalRoundPitsRadioButton.ClientID%>').attr('checked', (value == 1));
                    $('#<%=PedunculatedStellarRadioButton.ClientID%>').attr('checked', (value == 2));
                    $('#<%=PedunculatedTubularRoundPitsRadioButton.ClientID%>').attr('checked', (value == 3));
                    $('#<%=PedunculatedTubularRadioButton.ClientID %>').attr('checked', (value == 4));
                    $('#<%=PedunculatedSulcusRadioButton.ClientID %>').attr('checked', (value == 5));
                    $('#<%=PedunculatedLossRadioButton.ClientID %>').attr('checked', (value == 6));

                    $find('<%=PedunculatedPitPatternsRadButton.ClientID%>').set_commandArgument(polypId);
                    var oWnd = $find('<%=PedunculatedPitPatternsPopup.ClientID%>');
                    oWnd.show();
                    return false;
                }

                function ClosePopup() {
                    var oManager = GetRadWindowManager();
                    //Call GetActiveWindow to get the active window 
                    var oActive = oManager.getActiveWindow();
                    if (oActive == null) { window.parent.CloseWindow(); } else { oActive.close(null); return false; }
                    // return false;
                }
            </script>
        </telerik:RadScriptBlock>

        <telerik:RadScriptManager ID="RadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">


            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">

                <div id="FormDiv" style="padding: 20px; width: 600px; min-height: 210px; font-size: 12px; font-family: Segoe UI,Arial,Helvetica,sans-serif">
                    <asp:Repeater ID="PolypDetailsRepeater" runat="server" OnItemDataBound="PolypDetailsRepeater_ItemDataBound">
                        <HeaderTemplate>
                            <table class="rgview" style="width: 90%;" cellpadding="0" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th>&nbsp;</th>
                                        <th class="rgHeader">Size (mm)</th>
                                        <th class="rgHeader">Excised</th>
                                        <th class="rgHeader">Retrieved</th>
                                        <th class="rgHeader">Successful</th>
                                        <th class="rgHeader" style="color: #FF33FF;">To labs<img src="../../../../Images/NEDJAG/JAGNED.png" /></th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td style="padding-top: 15px;">
                                    <span>Polyp <%# Container.ItemIndex + 1 %>:</span>&nbsp;
                                </td>
                                <td class="rgCell">
                                    <telerik:RadNumericTextBox ID="PolypSizeNumericTextBox" runat="server"
                                        
                                        IncrementSettings-InterceptMouseWheel="false"
                                        IncrementSettings-Step="1"
                                        Width="35px"
                                        MinValue="0">
                                        <NumberFormat DecimalDigits="0" />
                                    </telerik:RadNumericTextBox>
                                    <asp:RequiredFieldValidator ID="PolpySizeRequiredFieldValidator" runat="server" ControlToValidate="PolypSizeNumericTextBox" InitialValue="0" ErrorMessage="*" ForeColor="Red" ValidationGroup="polypsize" />
                                    <asp:RequiredFieldValidator ID="PolpySizeRequiredFieldValidator2" runat="server" ControlToValidate="PolypSizeNumericTextBox" InitialValue="" ErrorMessage="*" ForeColor="Red" ValidationGroup="polypsize" />
                                </td>
                                <td class="rgCell">
                                    <asp:CheckBox ID="ExcisedCheckBox" runat="server" CssClass="polypectomy-result" />
                                    <telerik:RadNumericTextBox ID="ExcisedNumericTextBox" runat="server" Visible="false"
                                        
                                        IncrementSettings-InterceptMouseWheel="false"
                                        IncrementSettings-Step="1"
                                        Width="35px"
                                        MinValue="0">
                                        <NumberFormat DecimalDigits="0" />
                                    </telerik:RadNumericTextBox>
                                </td>
                                <td class="rgCell">
                                    <asp:CheckBox ID="RetrievedCheckBox" runat="server" CssClass="polypectomy-result" />
                                    <telerik:RadNumericTextBox ID="RetrievedNumericTextBox" runat="server" Visible="false"
                                        
                                        IncrementSettings-InterceptMouseWheel="false"
                                        IncrementSettings-Step="1"
                                        Width="35px"
                                        MinValue="0">
                                        <NumberFormat DecimalDigits="0" />
                                    </telerik:RadNumericTextBox>
                                </td>
                                <td class="rgCell">
                                    <asp:CheckBox ID="SuccessfulCheckBox" runat="server" CssClass="polypectomy-result" />
                                    <telerik:RadNumericTextBox ID="SuccessfulNumericTextBox" runat="server" Visible="false"
                                        
                                        IncrementSettings-InterceptMouseWheel="false"
                                        IncrementSettings-Step="1"
                                        Width="35px"
                                        MinValue="0">
                                        <NumberFormat DecimalDigits="0" />
                                    </telerik:RadNumericTextBox>
                                </td>
                                <td class="rgCell">
                                    <asp:CheckBox ID="ToLabsCheckBox" runat="server" CssClass="labs-cb" />
                                    <telerik:RadNumericTextBox ID="ToLabsNumericTextBox" runat="server" Visible="false"
                                        
                                        IncrementSettings-InterceptMouseWheel="false"
                                        IncrementSettings-Step="1"
                                        Width="35px"
                                        MinValue="0">
                                        <NumberFormat DecimalDigits="0" />
                                    </telerik:RadNumericTextBox>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="6">
                                    <table class="inner-table" style="width: 100%;">
                                        <tr>
                                            <td align="right">Removal</td>
                                            <td>
                                                <telerik:RadComboBox ID="Removal_ComboBox" runat="server" Skin="Metro"></telerik:RadComboBox>
                                            </td>
                                            <td align="right" style="width: 100px;">By</td>
                                            <td>
                                                <telerik:RadComboBox ID="Removal_Method_ComboBox" runat="server" Skin="Metro" Style="width: 70% !important;"></telerik:RadComboBox>
                                            </td>
                                        </tr>
                                        <tr id="polypTypeDetails" runat="server">
                                            <td class="rgCell">
                                                <asp:CheckBox ID="Probably_CheckBox" runat="server" Text="Probably" TextAlign="Right" SkinID="Metro" />
                                            </td>
                                            <td>
                                                <telerik:RadComboBox ID="Type_ComboBox" runat="server" Skin="Metro"></telerik:RadComboBox>
                                            </td>
                                            <td colspan="2">
                                                <telerik:RadButton ID="ParisShowButton" runat="server" Text="Paris classification..." Skin="Metro" AutoPostBack="false"></telerik:RadButton>
                                                &nbsp;
                                        <telerik:RadButton ID="PitShowButton" runat="server" Text="Pit patterns..." Skin="Metro" AutoPostBack="false"></telerik:RadButton>
                                            </td>
                                        </tr>
                                        <tr id="pseudoPolypTR" runat="server" visible="false">
                                            <td></td>
                                            <td>
                                                <asp:CheckBox ID="InflamCheckBox" runat="server" Text="inflammatory" TextAlign="Right" SkinID="Metro" AutoPostBack="false" />
                                            </td>
                                            <td colspan="2">
                                                <asp:CheckBox ID="PostInflamCheckBox" runat="server" Text="post-inflammatory" TextAlign="Right" SkinID="Metro" AutoPostBack="false" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            </tbody></table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>
            </telerik:RadPane>


            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; padding-bottom: 10px; margin-bottom: 10px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Ok" Skin="Metro" Icon-PrimaryIconCssClass="telerikOkButton" OnClick="SaveButton_Click" CausesValidation="true" ValidationGroup="polypsize" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" Icon-PrimaryIconCssClass="telerikCancelButton" OnClientClicked="CloseWindow" />
                </div>

            </telerik:RadPane>
        </telerik:RadSplitter>
        <telerik:RadWindowManager ID="RadMan" runat="server" Modal="true" Animation="Fade" KeepInScreenBounds="true" Behaviors="Close" Skin="Metro" VisibleStatusbar="false" VisibleOnPageLoad="false">
            <Windows>
                <telerik:RadWindow ID="SessileParisClassificationPopup" runat="server" Width="652" Height="450" ReloadOnShow="true" ShowContentDuringLoad="false">
                    <ContentTemplate>
                        <div class="labelHeaderPopup riLabel">
                            Paris Classification - The Morphological Appearance of a Lesion
                        </div>
                        <table id="SessileParisClassificationTable" class="tablePopup rgview">
                            <tr>
                                <td>Protruded type
                                </td>
                                <td>
                                    <asp:RadioButton ID="SessileLSRadioButton" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="testImg" ImageUrl="~/Images/ParisClassification/ParisClassification_Sessile.png" runat="server" />
                                </td>
                                <td>Is - sessile</td>
                            </tr>
                            <tr>
                                <td rowspan="2">Superficial
                                <br />
                                    elevated type
                                </td>
                                <td>
                                    <asp:RadioButton ID="SessileLLARadioButton" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="imgLogo" runat="server" ImageUrl="~/Images/ParisClassification/ParisClassification_FlatElevated.png" />
                                </td>
                                <td>IIa - flat elevated</td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:RadioButton ID="SessileLLALLCRadioButton" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage1" ImageUrl="~/Images/ParisClassification/ParisClassification_FlatElevatedDep.png" runat="server" />
                                </td>
                                <td>IIa + IIc - flat elevated with depression</td>
                            </tr>
                            <tr>
                                <td>Flat type
                                </td>
                                <td>
                                    <asp:RadioButton ID="SessileLLBRadioButton" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage2" ImageUrl="~/Images/ParisClassification/ParisClassification_Flat.png" runat="server" />
                                </td>
                                <td>IIb - flat</td>
                            </tr>
                            <tr>
                                <td rowspan="2">Depressed type
                                </td>
                                <td>
                                    <asp:RadioButton ID="SessileLLCRadioButton" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage3" ImageUrl="~/Images/ParisClassification/ParisClassification_SlightlyDep.png" runat="server" />
                                </td>
                                <td>IIc - slightly depressed</td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:RadioButton ID="SessileLLCLLARadioButton" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage4" ImageUrl="~/Images/ParisClassification/ParisClassification_SlightlyDep2.png" runat="server" />
                                </td>
                                <td>IIc + IIa slightly depressed</td>
                            </tr>
                        </table>
                        <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                            <telerik:RadButton ID="SessileParisClassificationRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" />
                            <telerik:RadButton ID="RadButton2" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="ClosePopup" AutoPostBack="false" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="PedunculatedParisClassificationPopUp" runat="server" Width="652" Height="250" ReloadOnShow="true" ShowContentDuringLoad="false">
                    <ContentTemplate>
                        <div class="labelHeaderPopup riLabel">
                            Paris Classification - The Morphological Appearance of a Lesion
                        </div>
                        <table id="PedunculatedParisClassificationTable" class="tablePopup rgview">
                            <tr>
                                <td rowspan="2">Protruded type
                                </td>
                                <td>
                                    <asp:RadioButton ID="ProtrudedRadioButton" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage11" ImageUrl="~/Images/ParisClassification/ParisClassification_Pedunculated.png" runat="server" />
                                </td>
                                <td>Ip - Pedunculated</td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:RadioButton ID="PedunculatedRadioButton" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage12" runat="server" ImageUrl="~/Images/ParisClassification/ParisClassification_SubPedunculated.png" />
                                </td>
                                <td>Isp - sub pedunculated</td>
                            </tr>
                        </table>
                        <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                            <telerik:RadButton ID="PedunculatedParisClassificationRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" />
                            <telerik:RadButton ID="RadButton4" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="ClosePopup" AutoPostBack="false" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="SessilePitPatternsPopup" runat="server" Width="652" Height="510" ReloadOnShow="true" ShowContentDuringLoad="false">
                    <ContentTemplate>
                        <div class="labelHeaderPopup riLabel">
                            Pit Patterns - The Surface Appearance of a Lesion
                        </div>
                        <table class="tablePopup rgview" id="SessilePitPatternsTable">
                            <tbody>
                                <tr style="font-weight: bold;">
                                    <td width="20px"></td>
                                    <td width="50px">Pit Type
                                    </td>
                                    <td width="150px">Characteristics
                                    </td>
                                    <td width="80px">Appearance
                            <br />
                                        using HMCC
                                    </td>
                                    <td width="80px">Pit Size</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="SessileNormalRoundPitsRadioButton" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>I
                                    </td>
                                    <td>Normal round pits
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="SessileRadBinaryImage5" ImageUrl="~/Images/PitPatterns/PitPattern1.png" runat="server" />
                                    </td>
                                    <td>0.07 +/- 0.02</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="SessileStellarRadioButton" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>II
                                    </td>
                                    <td>Stellar or papillary typical of hyperplastic polyps
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage6" ImageUrl="~/Images/PitPatterns/PitPattern2.png" runat="server" />
                                    </td>
                                    <td>0.03 +/- 0.01</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="SessileTubularRoundPitsRadioButton" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>III s
                                    </td>
                                    <td>Tubular/round pits smaller than pit type I typical of adenomas
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage7" ImageUrl="~/Images/PitPatterns/PitPattern3.png" runat="server" />
                                    </td>
                                    <td>0.07 +/- 0.02</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="SessileTubularRadioButton" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>III L
                                    </td>
                                    <td>Tubular/large typical of adenomas
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage8" ImageUrl="~/Images/PitPatterns/PitPattern4.png" runat="server" />
                                    </td>
                                    <td>0.22 +/- 0.09</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="SessileSulcusRadioButton" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>IV
                                    </td>
                                    <td>Sulcus/gyrus brain like typical of tubulovillous adenomas
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage9" ImageUrl="~/Images/PitPatterns/PitPattern5.png" runat="server" />
                                    </td>
                                    <td>0.93 +/- 0.32</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="SessileLossRadioButton" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>V
                                    </td>
                                    <td>Loss of architecture typical of invasion or high grade dysplasia
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage10" ImageUrl="~/Images/PitPatterns/PitPattern6.png" runat="server" />
                                    </td>
                                    <td>N/A</td>
                                </tr>
                            </tbody>
                        </table>
                        <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                            <telerik:RadButton ID="SessilePitPatternsRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" />
                            <telerik:RadButton ID="RadButton6" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="ClosePopup" AutoPostBack="false" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="PedunculatedPitPatternsPopup" runat="server" Width="652" Height="510" ReloadOnShow="true" ShowContentDuringLoad="false">
                    <ContentTemplate>
                        <div class="labelHeaderPopup riLabel">
                            Pit Patterns - The Surface Appearance of a Lesion
                        </div>
                        <table class="tablePopup rgview" id="PedunculatedPitPatternsTable">
                            <tbody>
                                <tr style="font-weight: bold;">
                                    <td width="20px"></td>
                                    <td width="30px">Pit Type
                                    </td>
                                    <td width="150px">Characteristics
                                    </td>
                                    <td width="80px">Appearance
                            <br />
                                        using HMCC
                                    </td>
                                    <td width="80px">Pit Size</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="PedunculatedNormalRoundPitsRadioButton" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>I
                                    </td>
                                    <td>Normal round pits
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="PedunculatedRadBinaryImage5" ImageUrl="~/Images/PitPatterns/PitPattern1.png" runat="server" />
                                    </td>
                                    <td>0.07 +/- 0.02</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="PedunculatedStellarRadioButton" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>II
                                    </td>
                                    <td>Stellar or papillary typical of hyperplastic polyps
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage5" ImageUrl="~/Images/PitPatterns/PitPattern2.png" runat="server" />
                                    </td>
                                    <td>0.03 +/- 0.01</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="PedunculatedTubularRoundPitsRadioButton" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>III s
                                    </td>
                                    <td>Tubular/round pits smaller than pit type I typical of adenomas
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage13" ImageUrl="~/Images/PitPatterns/PitPattern3.png" runat="server" />
                                    </td>
                                    <td>0.07 +/- 0.02</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="PedunculatedTubularRadioButton" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>III L
                                    </td>
                                    <td>Tubular/large typical of adenomas
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage14" ImageUrl="~/Images/PitPatterns/PitPattern4.png" runat="server" />
                                    </td>
                                    <td>0.22 +/- 0.09</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="PedunculatedSulcusRadioButton" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>IV
                                    </td>
                                    <td>Sulcus/gyrus brain like typical of tubulovillous adenomas
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage15" ImageUrl="~/Images/PitPatterns/PitPattern5.png" runat="server" />
                                    </td>
                                    <td>0.93 +/- 0.32</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="PedunculatedLossRadioButton" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>V
                                    </td>
                                    <td>Loss of architecture typical of invasion or high grade dysplasia
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage16" ImageUrl="~/Images/PitPatterns/PitPattern6.png" runat="server" />
                                    </td>
                                    <td>N/A</td>
                                </tr>
                            </tbody>
                        </table>
                        <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                            <telerik:RadButton ID="PedunculatedPitPatternsRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" />
                            <telerik:RadButton ID="RadButton8" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="ClosePopup" AutoPostBack="false" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
    </form>
</body>
</html>
