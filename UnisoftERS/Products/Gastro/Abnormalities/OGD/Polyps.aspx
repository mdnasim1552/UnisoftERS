<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_OGD_Polyps" CodeBehind="Polyps.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .RadSplitterNoBorders {
            border-style: none !important;
        }

        .SiteDetailsButtonsPane {
            /*border-top-style: solid;
            border-top-width: 1px;
            border-top-color: ActiveBorder;*/
        }

        .rbl label {
            margin-right: 20px;
        }

        /*tabstrip selected table styling*/
        /*.rtsSelected, .rtsSelected span {
            background: url(../../../../Images/cat_back.gif) repeat-x 0 100% !important;
            background-color: red !important;
            text-align: center;
            color:#9933FF; 
            font-weight: bold !important; 
        }*/
        .rblType {}
        .auto-style1 {
            width: 127px;
        }
        .auto-style2 {
            width: 125px;
        }
    </style>
    <telerik:RadCodeBlock ID="RadCodeBlock2" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
                ToggleNoneCheckBox();
                ToggleDiv("SubmucosalCheckBox", "SubmucosalPageView");
                ToggleDiv("PedunculatedCheckBox", "PedunculatedPageView");
                ToggleDiv("SessileCheckBox", "SessilePageView");
                ToggleBenignRadioList('Sessile');
                ToggleBenignRadioList('Pedunculated');
                ToggleBenignRadioList('Submucosal');
                ToggleMultipleCheckBox('Sessile');
                ToggleMultipleCheckBox('Pedunculated');
                ToggleMultipleCheckBox('Submucosal');
            });

            $(document).ready(function () {
                $("#MainCheckBoxesDiv input:checkbox").change(function () {
                    if ($(this).is(':checked')) {
                        var elemId = $(this).attr("id");
                        if (elemId.indexOf("NoneCheckBox") > -1) {
                            ClearAll();
                        }
                        else {
                            $("#NoneCheckBox").prop('checked', false);
                        }
                    }
                });

                $("#NoneCheckBox").change(function () {
                    if (!$(this).is(':checked')) {
                        ClearControls("SessilePageView");
                        ClearControls("PedunculatedPageView");
                        ClearControls("SubmucosalPageView");
                    }
                    ToggleNoneCheckBox();
                });

                $("#SessileCheckBox").change(function () {
                    if (!$(this).is(':checked')) {
                        ClearControls("SessilePageView");
                    } else { $("#NoneCheckBox").removeAttr("checked"); }
                    ToggleDiv("SessileCheckBox", "SessilePageView");
                });

                $("#PedunculatedCheckBox").change(function () {
                    if (!$(this).is(':checked')) {
                        ClearControls("PedunculatedPageView");
                    } else { $("#NoneCheckBox").removeAttr("checked"); }
                    ToggleDiv("PedunculatedCheckBox", "PedunculatedPageView");
                });

                $("#SubmucosalCheckBox").change(function () {
                    if (!$(this).is(':checked')) {
                        ClearControls("SubmucosalPageView");
                    } else { $("#NoneCheckBox").removeAttr("checked"); }
                    ToggleDiv("SubmucosalCheckBox", "SubmucosalPageView");
                });

                $("#SubmucosalCheckBox").change(function () {
                    if (!$(this).is(':checked')) {
                        ClearControls("SubmucosalPageView");
                    } else { $("#NoneCheckBox").removeAttr("checked"); }
                    ToggleDiv("SubmucosalCheckBox", "SubmucosalPageView");
                });

                // (AS: 7th/Jan/2020) bug fix for "Number retrieved" increasing "Number to labs"
                // Sessile Polyps
                var numberToLabsSessile = $('#SessileNumToLabsNumericTextBox').val();
                $('#NumberToLabsTextBoxHiddenSessile').val(numberToLabsSessile);

                // Pedunculated Polyps
                var numberToLabsPedunculated = $('#PedunculatedNumToLabsNumericTextBox').val();
                $('#NumberToLabsTextBoxHiddenPedunculated').val(numberToLabsPedunculated);

                //Submucosal Polyps
                var numberToLabsSubmucosal = $('#SubmucosalNumToLabsNumericTextBox').val();
                $('#NumberToLabsTextBoxHiddenSubmucosal').val(numberToLabsSubmucosal);
            });

            function ToggleDiv(chkboxId, divId) {
                var isChecked = $("#" + chkboxId).is(':checked');

                if (isChecked) {
                    $("#" + divId).show();
                } else {
                    $("#" + divId).hide();
                }

                var tabStripText;
                switch (chkboxId) {
                    case "SessileCheckBox":
                        tabStripText = "Sessile";
                        break;
                    case "PedunculatedCheckBox":
                        tabStripText = "Pedunculated";
                        break;
                    case "SubmucosalCheckBox":
                        tabStripText = "Submucosal (? Leiomyoma)";
                        break;
                }
                var tabStrip = $find("<%=PolypsTabStrip.ClientID%>");
            var tab = tabStrip.findTabByText(tabStripText);

            if (isChecked) {
                if (tab) {
                    tab.set_visible(true);
                    tab.select();
                    ToggleTheraDiv(tabStripText);
                }
            } else {
                if (tab) {
                    tab.set_visible(false);
                    var tabStrip = $find("<%=PolypsTabStrip.ClientID%>");
                        var tabs = tabStrip.get_tabs();
                        for (var i = 0; i < tabs.get_count(); i++) {
                            var tab = tabStrip.findTabByText(tabs.getTab(i).get_text());
                            if (tab.get_visible()) { tab.select(); }
                        }
                    }
                }
            }

            function ToggleNoneCheckBox() {
                if ($("#NoneCheckBox").is(':checked')) {
                    ClearAll();
                    //$("#SessileCheckBox").attr("disabled", "disabled");
                    $("#SessileCheckBox").removeAttr("checked");
                    $("#SessilePageView").hide();

                    //$("#PedunculatedCheckBox").attr("disabled", "disabled");
                    $("#PedunculatedCheckBox").removeAttr("checked");
                    $("#PedunculatedPageView").hide();

                    //$("#SubmucosalCheckBox").attr("disabled", "disabled");
                    $("#SubmucosalCheckBox").removeAttr("checked");
                    $("#SubmucosalPageView").hide();

                    var tabStrip = $find("<%=PolypsTabStrip.ClientID%>");
                    var tabs = tabStrip.get_tabs();
                    for (var i = 0; i < tabs.get_count(); i++) {
                        var tab = tabStrip.findTabByText(tabs.getTab(i).get_text());
                        if (tab) { tab.set_visible(false); }
                    }
                } else {
                    $("#SessileCheckBox").removeAttr("disabled");
                    $("#PedunculatedCheckBox").removeAttr("disabled");
                    $("#SubmucosalCheckBox").removeAttr("disabled");
                }
            }

            function ToggleTheraDiv(tabStripText) {
                //Not required for Submucosal, so exit function
                if (tabStripText.toLowerCase().indexOf("Submucosal".toLowerCase()) >= 0) { return; }
                if ($find(tabStripText + "NumExcisedNumericTextBox").get_value() > 0) {
                    $("#divThera" + tabStripText).show();
                } else {
                    $("#divThera" + tabStripText).hide();
                }
            }

            function ClearAll() {
                ClearControls("siteDetailsContentDiv");
                $('*[id*=Fieldset]').hide();
            }

            function ClearControls(parentCtrlId) {
                $("#" + parentCtrlId + " input:checkbox:checked").not("[id*='NoneCheckBox']").removeAttr("checked");
                $("#" + parentCtrlId + " input:radio:checked").removeAttr("checked");
                $("#" + parentCtrlId + " input:text").val('');
                $("#" + parentCtrlId + " textarea").val('');
            }

            function ToggleBenignRadioList(name) {
                var selectedVal = $("#" + name + "TypeRadioButtonList input:checked").val();
                if (selectedVal == 1) {
                    $("#" + name + "BenignTypeRadioButtonList").show();
                }
                else {
                    $("#" + name + "BenignTypeRadioButtonList").hide();
                    $("#" + name + "BenignTypeRadioButtonList input:radio:checked").removeAttr("checked");
                    $("#" + name + "MultipleSpan").hide();
                    $("#" + name + "MultipleSpan input:checkbox:checked").removeAttr("checked");
                }
            }

            function ToggleMultipleCheckBox(name) {
                var selectedVal = $("#" + name + "BenignTypeRadioButtonList input:checked").val();
                if (selectedVal == 1) {
                    $("#" + name + "MultipleSpan").show();
                }
                else {
                    $("#" + name + "MultipleSpan").hide();
                    $("#" + name + "MultipleSpan input:checkbox:checked").removeAttr("checked");
                }
            }

            function ToggleQtyBox(name) {
                if ($("#" + name + "MultipleCheckBox").is(':checked')) {
                    $find(name + "QtyNumericTextBox").set_value("");
                }
            }

            function UncheckMultipleCheckBox(name) {
                if ($find(name + "QtyNumericTextBox").get_value() != "") {
                    $("#" + name + "MultipleSpan input:checkbox:checked").removeAttr("checked");
                }
            }
            function valueChanged(sender) {
                var contrlID = sender.get_id();
                var bx; var px;
                if (contrlID.toLowerCase().indexOf("QtyNumericTextBox".toLowerCase()) >= 0) {
                    bx = 'QtyNumericTextBox';
                } else if (contrlID.toLowerCase().indexOf("NumExcisedNumericTextBox".toLowerCase()) >= 0) {
                    bx = 'NumExcisedNumericTextBox';
                } else if (contrlID.toLowerCase().indexOf("NumRetrievedNumericTextBox".toLowerCase()) >= 0) {
                    bx = 'NumRetrievedNumericTextBox';
                } else if (contrlID.toLowerCase().indexOf("NumToLabsNumericTextBox".toLowerCase()) >= 0) {
                    bx = 'NumToLabsNumericTextBox';
                }
                px = contrlID.substr(0, contrlID.toLowerCase().indexOf(bx.toLowerCase()));
                var QNx = $find(px + 'QtyNumericTextBox');
                var NEx = $find(px + 'NumExcisedNumericTextBox');
                var NRx = $find(px + 'NumRetrievedNumericTextBox');
                var NTx = $find(px + 'NumToLabsNumericTextBox');
                if (bx == 'QtyNumericTextBox') {
                    if (NEx.get_value() == '') { NEx.set_value(0); }
                    if (NRx.get_value() == '') { NRx.set_value(0); }
                    if (NTx.get_value() == '') { NTx.set_value(0); }
                } else if (bx == 'NumExcisedNumericTextBox') {
                    if (QNx.get_value() < NEx.get_value()) { QNx.set_value(NEx.get_value()); }
                    if (NRx.get_value() == '') { NRx.set_value(0); }
                    if (NTx.get_value() == '') { NTx.set_value(0); }
                    if (px != "Submucosal") { ToggleTheraDiv(px); }
                } else if (bx == 'NumRetrievedNumericTextBox') {
                    if (QNx.get_value() < NRx.get_value()) { QNx.set_value(NRx.get_value()); }
                    if (NEx.get_value() < NRx.get_value()) { NEx.set_value(NRx.get_value()); }
                    if (NTx.get_value() == '') { NTx.set_value(0); }
                    // (AS: 7th/Jan/2020) bug fix for "Number retrieved" increasing "Number to labs"
                    if (NRx.get_value() < NTx.get_value()) { NTx.set_value(NRx.get_value()); }
                } else if (bx == 'NumToLabsNumericTextBox') {
                    if (QNx.get_value() < NTx.get_value()) { QNx.set_value(NTx.get_value()); }
                    if (NEx.get_value() < NTx.get_value()) { NEx.set_value(NTx.get_value()); }
                    if (NRx.get_value() < NTx.get_value()) { NRx.set_value(NTx.get_value()); }
                }                
            }
        </script>
    </telerik:RadCodeBlock>
    <script type="text/javascript">
        // (AS: 7th/Jan/2020) bug fix for "Number retrieved" increasing "Number to labs"                                
            function SaveCheck() {
                var numberToLabsSessile = $('#SessileNumToLabsNumericTextBox').val();
                var numberToLabsOriginalSessile = $('#NumberToLabsTextBoxHiddenSessile').val();

                var numberToLabsPedunculated = $('#PedunculatedNumToLabsNumericTextBox').val();
                var numberToLabsOriginalPedunculated = $('#NumberToLabsTextBoxHiddenPedunculated').val();

                var numberToLabsSubmucosal = $('#SubmucosalNumToLabsNumericTextBox').val();
                var numberToLabsOriginalSubmucosal = $('#NumberToLabsTextBoxHiddenSubmucosal').val();

                // if the new number of specimens sent to lab is zero and
                // original value of specimens sent to lab was greater than
                // zero, then display message.
                if ((numberToLabsSessile == 0 && numberToLabsOriginalSessile > 0) ||
                   (numberToLabsPedunculated == 0 && numberToLabsOriginalPedunculated > 0) || 
                   (numberToLabsSubmucosal == 0 && numberToLabsOriginalSubmucosal > 0))
                {
                    alert("The number to Labs has changed, please check specimens taken.");
                }                

                // update value of original value to new value
                $('#NumberToLabsTextBoxHiddenSessile').val(numberToLabsSessile);
                $('#NumberToLabsTextBoxHiddenPedunculated').val(numberToLabsPedunculated);
                $('#NumberToLabsTextBoxHiddenSubmucosal').val(numberToLabsSubmucosal);
            }

        function CloseWindow() {
            window.parent.CloseWindow();
        }
    </script>

</head>
<body>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            function savePage() {
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
            }            

        </script>
    </telerik:RadScriptBlock>  
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="PolypsRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="PolypsRadFormDecorator" runat="server" DecoratedControls="All" ControlsToSkip="Fieldset" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Polyps</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                <div id="FormDiv" runat="server">

                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgPolyps" runat="server" style="padding-bottom: 20px;">
                            <table id="PolypsTable" class="rgview" cellpadding="0" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th class="rgHeader" width="540px" style="text-align: left;">
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" Style="margin-right: 10px;" />
                                            <asp:CheckBox ID="SessileCheckBox" runat="server" Text="Sessile" Style="margin-right: 10px;" />
                                            <asp:CheckBox ID="PedunculatedCheckBox" runat="server" Text="Pedunculated" Style="margin-right: 10px;" />
                                            <asp:CheckBox ID="SubmucosalCheckBox" runat="server" Text="Submucosal (? Leiomyoma)" Style="margin-right: 10px;" />
                                            <%--(AS: 7th/Jan/2020) bug fix for "Number retrieved" increasing "Number to labs" --%>                               
                                            <asp:HiddenField ID="NumberToLabsTextBoxHiddenSessile" runat="server" ClientIDMode="Static"/>
                                            <asp:HiddenField ID="NumberToLabsTextBoxHiddenPedunculated" runat="server" ClientIDMode="Static"/>
                                            <asp:HiddenField ID="NumberToLabsTextBoxHiddenSubmucosal" runat="server" ClientIDMode="Static"/>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>

                        <telerik:RadTabStrip runat="server" ID="PolypsTabStrip" MultiPageID="PolypsMultiPage" SelectedIndex="1" ShowBaseLine="False">
                            <Tabs>
                                <telerik:RadTab Text="Sessile" Width="185px" PageViewID="SessileTab"></telerik:RadTab>
                                <telerik:RadTab Text="Pedunculated" Width="185px" PageViewID="PedunculatedTab" Selected="True"></telerik:RadTab>
                                <telerik:RadTab Text="Submucosal (? Leiomyoma)" Width="185px" PageViewID="SubmucosalTab" Selected="True"></telerik:RadTab>
                            </Tabs>
                        </telerik:RadTabStrip>
                        <telerik:RadMultiPage ID="PolypsMultiPage" runat="server" SelectedIndex="0">
                            <telerik:RadPageView ID="SessilePageView" runat="server">
                                <div id="divSessile" style="border: 1px solid #828282; width: 525px; padding: 15px 15px;" runat="server">
                                    <table>
                                        <tr>
                                            <td class="auto-style1">Quantity: </td>
                                            <td colspan="2" class="rfdAspLabel" style="height: 23px;">
                                                <telerik:RadNumericTextBox ID="SessileQtyNumericTextBox" runat="server" ClientEvents-OnValueChanged="valueChanged"
                                                    
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0"
                                                    onchange="UncheckMultipleCheckBox('Sessile');">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                                &nbsp;&nbsp;&nbsp;
                                            <span id="SessileMultipleSpan" runat="server">
                                                <i>OR</i>
                                                &nbsp;&nbsp;&nbsp;
                                                <asp:CheckBox ID="SessileMultipleCheckBox" runat="server" Text="Multiple" onchange="ToggleQtyBox('Sessile');" />
                                            </span>
                                            </td>
                                        </tr>
                                        <tr class="rfdAspLabel">
                                            <td class="auto-style1">Largest:</td>
                                            <td>
                                                <telerik:RadNumericTextBox ID="SessileLargestNumericTextBox" runat="server"
                                                    
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0">
                                                    <NumberFormat DecimalDigits="1" />
                                                </telerik:RadNumericTextBox>
                                                <span style="margin-left: -5px;">mm</span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style1">Number:
                                            </td>
                                            <td colspan="2" valign="bottom" class="rfdAspLabel">
                                                <telerik:RadNumericTextBox ID="SessileNumExcisedNumericTextBox" runat="server" ClientEvents-OnValueChanged="valueChanged"
                                                    
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                                <span style="margin-left: -5px;">excised</span>

                                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                            <telerik:RadNumericTextBox ID="SessileNumRetrievedNumericTextBox" runat="server" ClientEvents-OnValueChanged="valueChanged"
                                                
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                                <span style="margin-left: -5px;">retrieved</span>

                                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                            <telerik:RadNumericTextBox ID="SessileNumToLabsNumericTextBox" runat="server" ClientEvents-OnValueChanged="valueChanged"
                                                
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                                <span style="margin-left: -5px;">to labs</span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3">
                                                <div runat="server" id="divTheraSessile">
                                                    <table style="width: 90%;">
                                                        <tr>
                                                            <td style="border: 1pt dashed #B8CBDE; padding: 0px 10px;">
                                                                <asp:RadioButtonList ID="SessilePolyRemovalRadioButtonList" runat="server" TabIndex="32"
                                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Table" CssClass="rblType">
                                                                    <asp:ListItem Value="1" Text="entire"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="piecemeal"></asp:ListItem>
                                                                </asp:RadioButtonList>
                                                            </td>
                                                            <td style="width: 15px;"></td>
                                                            <td style="border: 1pt dashed #B8CBDE; padding: 0px 10px;">
                                                                <asp:RadioButtonList ID="SessilePolypRemovalTypeRadioButtonList" runat="server" TabIndex="33"
                                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Table" CssClass="rblType" RepeatColumns="3" Width="360px">
                                                                    <asp:ListItem Value="1" Text="partial snare"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="cold snare"></asp:ListItem>
                                                                    <asp:ListItem Value="3" Text="hot snare cauterisation"></asp:ListItem>
                                                                    <asp:ListItem Value="4" Text="hox bx"></asp:ListItem>
                                                                    <asp:ListItem Value="5" Text="cold bx"></asp:ListItem>
                                                                </asp:RadioButtonList>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="bottom" class="auto-style1">
                                                <asp:CheckBox ID="SessileErodedCheckBox" runat="server" Text="Eroded" Style="margin-right: 10px;" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="SessileUlceratedCheckBox" runat="server" Text="Ulcerated" Style="margin-right: 10px;" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="SessileOverlyingClotCheckBox" runat="server" Text="Overlying clot" Style="margin-right: 10px;" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="bottom" class="auto-style1">
                                                <asp:CheckBox ID="SessileActiveBleedingCheckBox" runat="server" Text="Active bleeding" Style="margin-right: 10px;" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="SessileOverlyingOldBloodCheckBox" runat="server" Text="Overlying old blood" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="SessileHyperplastic" runat="server" Text="Hyperplastic" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" style="height: 10px;" valign="bottom"></td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="auto-style1">Tumour:</td>
                                            <td>
                                                <asp:RadioButtonList ID="SessileTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                    onchange="ToggleBenignRadioList('Sessile');">
                                                    <asp:ListItem Value="1" Text="Benign"></asp:ListItem>
                                                    <asp:ListItem Value="2" Text="Malignant"></asp:ListItem>
                                                </asp:RadioButtonList>
                                            </td>
                                            <td>
                                                <asp:RadioButtonList ID="SessileBenignTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                    RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl"
                                                    onchange="ToggleMultipleCheckBox('Sessile');">
                                                    <asp:ListItem Value="2" Text="Adenomatous"></asp:ListItem>
                                                    <asp:ListItem Value="3" Text="Uncertain"></asp:ListItem>
                                                </asp:RadioButtonList>
                                            </td>
                                        </tr>
                                    </table>
                                    
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="PedunculatedPageView" runat="server">
                                <div id="divPedunculated" style="border: 1px solid #828282; width: 525px; padding: 15px 15px;" runat="server">
                                    <table>
                                        <tr>
                                            <td class="auto-style2">Quantity: </td>
                                            <td colspan="2" class="rfdAspLabel" style="height: 23px;">
                                                <telerik:RadNumericTextBox ID="PedunculatedQtyNumericTextBox" runat="server" ClientEvents-OnValueChanged="valueChanged"
                                                    
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0"
                                                    onchange="UncheckMultipleCheckBox('Pedunculated');">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                                &nbsp;&nbsp;&nbsp;
                                            <span id="PedunculatedMultipleSpan" runat="server">
                                                <i>OR</i>
                                                &nbsp;&nbsp;&nbsp;
                                                <asp:CheckBox ID="PedunculatedMultipleCheckBox" runat="server" Text="Multiple" onchange="ToggleQtyBox('Pedunculated');" />
                                            </span>
                                            </td>
                                        </tr>
                                        <tr class="rfdAspLabel">
                                            <td class="auto-style2">Largest:</td>
                                            <td>
                                                <telerik:RadNumericTextBox ID="PedunculatedLargestNumericTextBox" runat="server"
                                                    
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0">
                                                    <NumberFormat DecimalDigits="1" />
                                                </telerik:RadNumericTextBox>
                                                <span style="margin-left: -5px;">mm</span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="auto-style2">Number:
                                            </td>
                                            <td colspan="2" valign="bottom" class="rfdAspLabel" align="left">
                                                <telerik:RadNumericTextBox ID="PedunculatedNumExcisedNumericTextBox" runat="server" ClientEvents-OnValueChanged="valueChanged"
                                                    
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                                <span style="margin-left: -5px;">excised</span>

                                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                            <telerik:RadNumericTextBox ID="PedunculatedNumRetrievedNumericTextBox" runat="server" ClientEvents-OnValueChanged="valueChanged"
                                                
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                                <span style="margin-left: -5px;">retrieved</span>

                                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                            <telerik:RadNumericTextBox ID="PedunculatedNumToLabsNumericTextBox" runat="server" ClientEvents-OnValueChanged="valueChanged"
                                                
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                                <span style="margin-left: -5px;">to labs</span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3">
                                            <div runat="server" id="divTheraPedunculated">
                                                <table style="width: 90%;">
                                                    <tr>
                                                        <td style="border: 1pt dashed #B8CBDE; padding: 0px 10px;">
                                                            <asp:RadioButtonList ID="PedunculatedPolyRemovalRadioButtonList" runat="server" TabIndex="32"
                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Table" CssClass="rblType">
                                                                <asp:ListItem Value="1" Text="entire"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="piecemeal"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </td>
                                                        <td style="width: 15px;"></td>
                                                        <td style="border: 1pt dashed #B8CBDE; padding: 0px 10px;">
                                                            <asp:RadioButtonList ID="PedunculatedPolypRemovalTypeRadioButtonList" runat="server" TabIndex="33"
                                                                CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Table" CssClass="rblType" RepeatColumns="3"  Width="360px">
                                                                <asp:ListItem Value="1" Text="partial snare"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="cold snare"></asp:ListItem>
                                                                <asp:ListItem Value="3" Text="hot snare cauterisation"></asp:ListItem>
                                                                <asp:ListItem Value="4" Text="hox bx"></asp:ListItem>
                                                                <asp:ListItem Value="5" Text="cold bx"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="bottom" class="auto-style2">
                                                <asp:CheckBox ID="PedunculatedErodedCheckBox" runat="server" Text="Eroded" Style="margin-right: 10px;" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="PedunculatedUlceratedCheckBox" runat="server" Text="Ulcerated" Style="margin-right: 10px;" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="PedunculatedOverlyingClotCheckBox" runat="server" Text="Overlying clot" Style="margin-right: 10px;" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="bottom" class="auto-style2">
                                                <asp:CheckBox ID="PedunculatedActiveBleedingCheckBox" runat="server" Text="Active bleeding" Style="margin-right: 10px;" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="PedunculatedOverlyingOldBloodCheckBox" runat="server" Text="Overlying old blood" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="PedunculatedHyperplastic" runat="server" Text="Hyperplastic" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" style="height: 10px;" valign="bottom"></td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="auto-style2">Tumour:</td>
                                            <td>
                                                <asp:RadioButtonList ID="PedunculatedTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                    onchange="ToggleBenignRadioList('Pedunculated');">
                                                    <asp:ListItem Value="1" Text="Benign"></asp:ListItem>
                                                    <asp:ListItem Value="2" Text="Malignant"></asp:ListItem>
                                                </asp:RadioButtonList>
                                            </td>
                                            <td>
                                                <asp:RadioButtonList ID="PedunculatedBenignTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                    RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl"
                                                    onchange="ToggleMultipleCheckBox('Pedunculated');">
                                                    <asp:ListItem Value="2" Text="Adenomatous"></asp:ListItem>
                                                    <asp:ListItem Value="3" Text="Uncertain"></asp:ListItem>
                                                </asp:RadioButtonList>
                                            </td>
                                        </tr>
                                    </table>

                                </div>
                            </telerik:RadPageView>

                            <telerik:RadPageView ID="SubmucosalPageView" runat="server">
                                <div id="divSubmucosal" style="border: 1px solid #828282; width: 525px; padding: 15px 15px;" runat="server">
                                    <table>
                                        <tr>
                                            <td class="rfdAspLabel">Quantity: </td>
                                            <td colspan="2" class="rfdAspLabel" style="height: 23px;">
                                                <telerik:RadNumericTextBox ID="SubmucosalQtyNumericTextBox" runat="server" ClientEvents-OnValueChanged="valueChanged"
                                                    
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0"
                                                    onchange="UncheckMultipleCheckBox('Submucosal');">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                                &nbsp;&nbsp;&nbsp;
                                            <span id="SubmucosalMultipleSpan" runat="server">
                                                <i>OR</i>
                                                &nbsp;&nbsp;&nbsp;
                                                <asp:CheckBox ID="SubmucosalMultipleCheckBox" runat="server" Text="Multiple" onchange="ToggleQtyBox('Submucosal');" />
                                            </span>
                                            </td>
                                        </tr>
                                        <tr class="rfdAspLabel">
                                            <td>Largest:</td>
                                            <td>
                                                <telerik:RadNumericTextBox ID="SubmucosalLargestNumericTextBox" runat="server"
                                                    
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0">
                                                    <NumberFormat DecimalDigits="1" />
                                                </telerik:RadNumericTextBox>
                                                <span style="margin-left: -5px;">mm</span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="rfdAspLabel">Number:
                                            </td>
                                            <td colspan="2" valign="bottom" class="rfdAspLabel">
                                                <telerik:RadNumericTextBox ID="SubmucosalNumExcisedNumericTextBox" runat="server" ClientEvents-OnValueChanged="valueChanged"
                                                    
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                                <span style="margin-left: -5px;">excised</span>

                                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                            <telerik:RadNumericTextBox ID="SubmucosalNumRetrievedNumericTextBox" runat="server" ClientEvents-OnValueChanged="valueChanged"
                                                
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                                <span style="margin-left: -5px;">retrieved</span>

                                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                            <telerik:RadNumericTextBox ID="SubmucosalNumToLabsNumericTextBox" runat="server" ClientEvents-OnValueChanged="valueChanged"
                                                
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                                <span style="margin-left: -5px;">to labs</span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="bottom">
                                                <asp:CheckBox ID="SubmucosalErodedCheckBox" runat="server" Text="Eroded" Style="margin-right: 10px;" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="SubmucosalUlceratedCheckBox" runat="server" Text="Ulcerated" Style="margin-right: 10px;" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="SubmucosalOverlyingClotCheckBox" runat="server" Text="Overlying clot" Style="margin-right: 10px;" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="bottom">
                                                <asp:CheckBox ID="SubmucosalActiveBleedingCheckBox" runat="server" Text="Active bleeding" Style="margin-right: 10px;" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="SubmucosalOverlyingOldBloodCheckBox" runat="server" Text="Overlying old blood" />
                                            </td>
                                            <td>
                                                <asp:CheckBox ID="SubmucosalHyperplastic" runat="server" Text="Hyperplastic" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" style="height: 10px;" valign="bottom"></td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="rfdAspLabel">Tumour:</td>
                                            <td>
                                                <asp:RadioButtonList ID="SubmucosalTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                    onchange="ToggleBenignRadioList('Submucosal');">
                                                    <asp:ListItem Value="1" Text="Benign"></asp:ListItem>
                                                    <asp:ListItem Value="2" Text="Malignant"></asp:ListItem>
                                                </asp:RadioButtonList>
                                            </td>
                                            <td>
                                                <asp:RadioButtonList ID="SubmucosalBenignTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                                    RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl"
                                                    onchange="ToggleMultipleCheckBox('Submucosal');">
                                                    <asp:ListItem Value="2" Text="Adenomatous"></asp:ListItem>
                                                    <asp:ListItem Value="3" Text="Uncertain"></asp:ListItem>
                                                </asp:RadioButtonList>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>

                    </div>

                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" OnClientClicked="SaveCheck" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
