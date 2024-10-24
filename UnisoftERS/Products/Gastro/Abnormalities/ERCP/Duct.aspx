<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_ERCP_Duct" CodeBehind="Duct.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .SiteDetailsForm {
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            color: black;
        }

            .SiteDetailsForm td {
                padding-bottom: 10px;
            }

        .rblType td {
            border: none;
            padding-left: 0px;
        }

        .rblType label {
            margin-right: 20px;
        }

        div.RadToolBar_Horizontal .rtbSeparator {
            width: 20px;
            background: none;
            border: none;
        }

        .divChildControl {
            float: left;
            margin-left: 30px;
        }
        #RAD_SPLITTER_PANE_CONTENT_ControlsRadPane{
            height: calc(90vh - 20px) !important;
        }
    </style>
    <telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var ductValueChanged = false;

        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));
            });
            ToggleStrictureType();
            ToggleProbably();
            ToggleCystType();

            ToggleMassType();
        });

        $(document).ready(function () {
            $("#DuctTable tr td:first-child input:checkbox").change(function () {
                ToggleTRs($(this));
                ductValueChanged = true;
            });

            $("#NormalCheckBox").change(function () {
                ToggleNormalCheckBox($(this).is(':checked'));
                ductValueChanged = true;
            });

            $("#CystsTypeCell input:checkbox").change(function () {
                ToggleCystType();
            });
            //Added by rony tfs-4166;
            $(window).on('beforeunload', function () {
                if (ductValueChanged) {
                    $('#<%=SaveButton.ClientID%>').click();  
                    valueChanged();
                }
            });
            $(window).on('unload', function () {
                localStorage.clear();
                setRehideSummary();
            });
        });

        function valueChanged() {
            var valueToSave = false;
            $("#DuctTable tr td:first-child").each(function () {
                if ($(this).find("input:checkbox").is(':checked')) valueToSave = true;
            });
            if (!$('#NormalCheckBox').is(':checked') && !valueToSave)
                localStorage.setItem('valueChanged', 'false');
            else
                localStorage.setItem('valueChanged', 'true');
        }

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        function ToggleTRs(chkbox) {
            if (chkbox[0].id != "NormalCheckBox") {
                var checked = chkbox.is(':checked');
                if (checked) {
                    $("#NormalCheckBox").prop('checked', false);
                }
                chkbox.closest('td')
                    .nextUntil('tr').each(function () {
                        if (checked) {
                            $(this).show();
                        }
                        else {
                            $(this).hide();
                            ClearControls($(this));
                        }
                    });
                var subRows = chkbox.closest('td').closest('tr').attr('hasChildRows');
                if (typeof subRows !== typeof undefined && subRows == "1") {
                    chkbox.closest('tr').nextUntil('tr [headRow="1"]').each(function () {
                        if (checked) {
                            $(this).show();
                        }
                        else {
                            $(this).hide();
                            ClearControls($(this));
                        }
                    });
                }

                if (chkbox[0].id == "StrictureCheckBox") {
                    ToggleStrictureType();
                    ToggleProbably();
                }

                if (chkbox[0].id == "CystsCheckBox") {
                    ToggleCystType();
                }

                if (chkbox[0].id == "MassDistortingAnatomyCheckBox") {
                    ToggleMassType();
                }
            }
        }
         //changed by mostafiz issue 3647
        function ToggleNormalCheckBox(checked) {
            if (checked) {
                $("#DuctTable tr td:first-child").each(function () {
                    $(this).find("input:checkbox:checked").prop('checked', false);
                    $(this).find("input:checkbox").trigger("change");
                });
            }
        }

        function ToggleStrictureType() {
            var selectedVal = $('#StrictureTypeRadioButtonList input:checked').val();

            if (selectedVal == undefined) {
                $("#ProbablyDiv").hide();
                $("#ProbablyCheckBox").prop("checked", false);
                $("#StrictureTypeMalignantRow").hide();
                ClearControls($("#StrictureTypeMalignantCell"));
            }

            if (selectedVal > 0) {
                $("#ProbablyDiv").show();
                if (selectedVal == 1) {
                    $("#StrictureTypeMalignantRow").hide();
                    ClearControls($("#StrictureTypeMalignantCell"));
                }
                else if (selectedVal == 2) {
                    $("#StrictureTypeMalignantRow").show();
                }
            }
        }

        function ToggleProbably() {
            var checked = $('#ProbablyCheckBox').is(':checked');
            if (checked) {
                $("label[for='CholangiocarcinomaCheckBox']").text("probable cholangiocarcinoma");
                //$("#CholangiocarcinomaCheckBox").val("probably cholangiocarcinoma");
            }
            else {
                $("label[for='CholangiocarcinomaCheckBox']").text("cholangiocarcinoma");
                //$("#CholangiocarcinomaCheckBox").val("cholangiocarcinoma");
            }
        }

        function ToggleCystType() {
            if ($("#CystsTypeCell input:checkbox:checked").length > 0) {
                $("#CystsCommunicatingRow").show();
                $("#CystsSuspectedRow").show();
            }
            else {
                $("#CystsCommunicatingRow").hide();
                $("#CystsSuspectedRow").hide();
                ClearControls($("#CystsCommunicatingCell"));
                ClearControls($("#CystsSuspectedCell"));
            }
        }
        function ToggleMassType() {
            var selectedVal = $('#MassTypeRadioButtonList input:checked').val();

            if (selectedVal == undefined) {
                $("#ProbablyDiv").hide();
                $("#ProbablyCheckBox").prop("checked", false);
            }

            if (selectedVal > 0) {
                $("#ProbablyDiv").show();
            }
        }
        function ClearMultipleCheckBox(sender, args) {
            if (args.get_newValue() != "") {
                var chkBoxId = "";
                if (sender._clientID == "StonesQtyNumericTextBox") {
                    chkBoxId = "StonesMultipleCheckBox";
                }
                else if (sender._clientID == "CystsQtyNumericTextBox") {
                    chkBoxId = "CystsMultipleCheckBox";
                }
                //$("#" + chkBoxId + " input:checkbox:checked").removeAttr("checked");
                $("#" + chkBoxId).prop("checked", false);
            }
        }

        function ClearQtyTextBox() {
            if ($('#StonesMultipleCheckBox').is(':checked')) {
                $find("StonesQtyNumericTextBox").set_value("");
            }
            else if ($('#CystsMultipleCheckBox').is(':checked')) {
                $find("CystsQtyNumericTextBox").set_value("");
            }
        }
         //changed by mostafiz issue 3647
        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").prop('checked', false);
            tableCell.find("input:checkbox:checked").prop('checked', false);
            tableCell.find("input:text").val("");
        }
    </script>
        </telerik:RadScriptBlock>
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
        <telerik:RadScriptManager ID="DuctRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="DuctRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">
            <asp:Label ID="HeadingLabel" runat="server" Text="Duct"></asp:Label>
        </div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <table id="DuctTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
                                <colgroup>
                                    <col>
                                    <col>
                                    <col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th width="260px" class="rgHeader" style="text-align: left;">
                                            <asp:CheckBox ID="NormalCheckBox" runat="server" Text="Normal" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1" haschildrows="1">
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="DilatedCheckBox" runat="server" Text="Dilated" />
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;">
                                                        <div class="divChildControl">
                                                            <label>to</label>
                                                            <telerik:RadNumericTextBox ID="DilatedLengthNumericTextBox" runat="server"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="2"
                                                                Width="35px"
                                                                MinValue="0">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                            <label>mm</label>
                                                        </div>
                                                        <div class="divChildControl" style="margin-top: -5px;">
                                                            <asp:RadioButtonList ID="DilatedTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" CssClass="rblType">
                                                                <asp:ListItem Value="1" Text="No obvious cause"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="Post cholecystectomy"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1" haschildrows="1">
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="StrictureCheckBox" runat="server" Text="Stricture" />
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;">
                                                        <div class="divChildControl">
                                                            <label>length</label>
                                                            <telerik:RadNumericTextBox ID="StrictureLengthNumericTextBox" runat="server"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="0.5"
                                                                Width="35px"
                                                                MinValue="0.5">
                                                                <NumberFormat DecimalDigits="1" />
                                                            </telerik:RadNumericTextBox>
                                                            <label>mm</label>
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="UpstreamDilatationCheckBox" runat="server" Text="with upstream dilatation" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CompleteBlockCheckBox" runat="server" Text="complete block" />
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;">
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="SmoothCheckBox" runat="server" Text="smooth" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="IrregularCheckBox" runat="server" Text="irregular" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="ShoulderedCheckBox" runat="server" Text="shouldered" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="TortuousCheckBox" runat="server" Text="tortuous" />
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none">
                                                        <div class="divChildControl" style="margin-top: -5px;">
                                                            <asp:RadioButtonList ID="StrictureTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" CssClass="rblType"
                                                                onchange="ToggleStrictureType();">
                                                                <asp:ListItem Value="1" Text="benign"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="malignant"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </div>
                                                        <div id="ProbablyDiv" class="divChildControl">
                                                            <asp:CheckBox ID="ProbablyCheckBox" runat="server" Text="probably" onchange="ToggleProbably();" />
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr childrow="1" id="StrictureTypeMalignantRow" runat="server">
                                                    <td id="StrictureTypeMalignantCell" style="border: none;">
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CholangiocarcinomaCheckBox" runat="server" Text="cholangiocarcinoma" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="ExternalCompressionCheckBox" runat="server" Text="external compression (metastases)" />
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1" haschildrows="1">
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="FistulaCheckBox" runat="server" Text="Fistula" />
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;">
                                                        <div class="divChildControl">
                                                            <label>qty</label>
                                                            <telerik:RadNumericTextBox ID="FistulaQtyNumericTextBox" runat="server"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="35px"
                                                                MinValue="0">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="VisceralCheckBox" runat="server" Text="visceral" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CutaneousCheckBox" runat="server" Text="cutaneous" />
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;">
                                                        <div class="divChildControl">
                                                            <label>comments:</label>
                                                            <telerik:RadTextBox ID="CommentsTextBox" runat="server" Width="300px"
                                                                TextMode="SingleLine">
                                                            </telerik:RadTextBox>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1" haschildrows="1">
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="StonesCheckBox" runat="server" Text="Stones" />
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;">
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="StonesMultipleCheckBox" runat="server" Text="multiple" onchange="ClearQtyTextBox();" />
                                                        </div>
                                                        <div class="divChildControl" style="margin-left: 15px; margin-top: 3px;">
                                                            <label><i>OR</i></label>
                                                        </div>
                                                        <div class="divChildControl" style="margin-left: 15px">
                                                            <label>qty</label>
                                                            <telerik:RadNumericTextBox ID="StonesQtyNumericTextBox" runat="server"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="35px"
                                                                MinValue="0"
                                                                ClientEvents-OnValueChanged="ClearMultipleCheckBox">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                        </div>
                                                        <div class="divChildControl">
                                                            <label>size of largest</label>
                                                            <telerik:RadNumericTextBox ID="StonesSizeNumericTextBox" runat="server"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="0.5"
                                                                Width="35px"
                                                                MinValue="0">
                                                                <NumberFormat DecimalDigits="1" />
                                                            </telerik:RadNumericTextBox>
                                                            <label>mm</label>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <tr id="trCysts" runat="server">
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1" haschildrows="1">
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="CystsCheckBox" runat="server" Text="Cystic Lesion" /><%--Mahfuz renamed Cysts to Cystic Lesion on 11 May 2021--%>
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;">
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CystsMultipleCheckBox" runat="server" Text="multiple" onchange="ClearQtyTextBox();" />
                                                        </div>
                                                        <div class="divChildControl" style="margin-left: 15px; margin-top: 3px;">
                                                            <label><i>OR</i></label>
                                                        </div>
                                                        <div class="divChildControl" style="margin-left: 15px">
                                                            <label>qty</label>
                                                            <telerik:RadNumericTextBox ID="CystsQtyNumericTextBox" runat="server"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="1"
                                                                Width="35px"
                                                                MinValue="0"
                                                                ClientEvents-OnValueChanged="ClearMultipleCheckBox">
                                                                <NumberFormat DecimalDigits="0" />
                                                            </telerik:RadNumericTextBox>
                                                        </div>
                                                        <div class="divChildControl">
                                                            <label>diameter of largest</label>
                                                            <telerik:RadNumericTextBox ID="CystsDiameterNumericTextBox" runat="server"
                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                IncrementSettings-Step="0.5"
                                                                Width="35px"
                                                                MinValue="0">
                                                                <NumberFormat DecimalDigits="1" />
                                                            </telerik:RadNumericTextBox>
                                                            <label>mm</label>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr childrow="1">
                                                    <td style="border: none;" id="CystsTypeCell">
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CystsSimpleCheckBox" runat="server" Text="simple" onchange="ToggleCystType()" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CystsRegularCheckBox" runat="server" Text="regular" onchange="ToggleCystType()" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CystsIrregularCheckBox" runat="server" Text="irregular" onchange="ToggleCystType()" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CystsLoculatedCheckBox" runat="server" Text="loculated" onchange="ToggleCystType()" />
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr childrow="1" id="CystsCommunicatingRow">
                                                    <td id="CystsCommunicatingCell" style="border: none;">
                                                        <div class="divChildControl" id="CystsCholedochalDiv" runat="server">
                                                            <asp:CheckBox ID="CystsCholedochalCheckBox" runat="server" Text="choledochal cyst" />
                                                        </div>
                                                        <div class="divChildControl">
                                                            <asp:CheckBox ID="CystsCommunicatingCheckBox" runat="server" Text="communicating with biliary duct" />
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr childrow="1" id="CystsSuspectedRow" runat="server">
                                                    <td id="CystsSuspectedCell" style="border: none;">
                                                        <div class="divChildControl" style="margin-top: -5px;">
                                                            <asp:RadioButtonList ID="CystsSuspectedTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" CssClass="rblType">
                                                                <asp:ListItem Value="1" Text="suspected polycystic disease"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="suspected hydatid cyst"></asp:ListItem>
                                                                <asp:ListItem Value="3" Text="suspected liver abscess"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="DuctInjuryCheckBox" runat="server" Text="Duct Injury" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="StentOcclusionCheckBox" runat="server" Text="Stent Occlusion" />
                                        </td>
                                    </tr>
                                    <tr childrow="1" id="GallBladderTumorRow" runat="server" visible="false">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="GallBladderTumorCheckBox" runat="server" Text="Gall Bladder Tumour" />
                                        </td>
                                    </tr>
                                    <tr childrow="1" id="DiverticulumRow" runat="server" visible="false">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="DiverticulumCheckBox" runat="server" Text="Diverticulum" />
                                        </td>
                                    </tr>
                                    <tr childrow="1" id="AnastomicStrictureRow" runat="server">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="AnastomicStrictureCheckbox" runat="server" Text="Anastomic stricture" />
                                        </td>
                                    </tr>
                                    <tr childrow="1" id="MirizziSyndromeRow" runat="server">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="MirizziSyndromeCheckbox" runat="server" Text="Mirizzi Syndrome" />
                                        </td>
                                    </tr>
                                    <tr childrow="1" id="SclerosingCholangitisRow" runat="server">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="SclerosingCholangitisCheckBox" runat="server" Text="Sclerosing Cholangitis" />
                                        </td>
                                    </tr>
                                    <tr childrow="1" id="CalculousObstructionRow" runat="server" visible="false">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="CalculousObstructionCheckBox" runat="server" Text="Calculous Obstruction" />
                                        </td>
                                    </tr>
                                    <tr childrow="1" id="OcclusionRow" runat="server">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="OcclusionCheckBox" runat="server" Text="Occlusion" />
                                        </td>
                                    </tr>
                                    <tr childrow="1" id="BiliaryLeakRow" runat="server">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="BiliaryLeakCheckBox" runat="server" Text="Biliary Leak" />
                                        </td>
                                    </tr>
                                    <tr childrow="1" id="PreviousSurgeryRow" runat="server">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="PreviousSurgeryCheckBox" runat="server" Text="Previous Surgery" />
                                        </td>
                                    </tr>
                                        <tr childrow="1" id="PancreaticTumourRow" runat="server" visible="false">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="PancreaticTumourCheckBox" runat="server" Text="Pancreatic Tumour" />
                                        </td>
                                    </tr>
                                    <tr childrow="1" id="IPMNRow" runat="server" visible="false">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="IPMNCheckBox" runat="server" Text="IPMN" />
                                        </td>
                                    </tr>
                                     <tr childrow="1" id="MigratedStentRow" runat="server">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="MigratedStentCheckBox" runat="server" Text="Proximally migrated stent" />
                                        </td>
                                    </tr>
                                     <tr childrow="1" id="HemobiliaRow" runat="server">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="HemobiliaCheckBox" runat="server" Text="Hemobilia" />
                                        </td>
                                    </tr>
                                     <tr childrow="1" id="CholangiopathyRow" runat="server">
                                        <td style="padding-left: 12px;">
                                            <asp:CheckBox ID="CholangiopathyCheckBox" runat="server" Text="Cholangiopathy" />
                                        </td>
                                    </tr>
<tr>
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr headrow="1" haschildrows="1">
                                                    <td style="border: none;">
                                                        
                                                        <asp:CheckBox ID="MassDistortingAnatomyCheckBox" runat="server" Text="Mass" />
                                                    </td>
                                                </tr>
                                                <tr childrow="1" id="MassDistortingAnatomyChildRow" runat="server">
                                                    <td style="border: none;">
                                                        <div class="divChildControl" style="margin-top:-5px;">
                                                            <asp:RadioButtonList ID="MassTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" CssClass="rblType"
                                                                onchange="ToggleMassType();">
                                                                <asp:ListItem Value="1" Text="hepatoma"></asp:ListItem>
                                                                <asp:ListItem Value="2" Text="metastases"></asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </div>
                                                        <div id="ProbablyDiv" class="divChildControl">
                                                            <asp:CheckBox ID="CheckBox1" runat="server" Text="probably" />
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr runat="server" visible="false">
                                        <td style="padding: 0px 0px 0px 6px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <asp:CheckBox ID="OtherCheckBox" runat="server" Text="Other" />
                                                    </td>
                                                    <td style="border: none;">
                                                        <telerik:RadTextBox ID="OtherTextBox" runat="server" Width="500px" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>

                        </div>
                    </div>
                </div>

            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;display:none;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="WebBlue" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="WebBlue" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        <div>
        </div>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
