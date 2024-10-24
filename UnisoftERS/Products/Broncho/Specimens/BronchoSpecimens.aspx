<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Broncho_Specimens_BronchoSpecimens" CodeBehind="BronchoSpecimens.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />


    <script type="text/javascript">
        var bronchoSpecimensTaken = false;
        $(window).on('load', function () {
            $('input[type="checkbox"]').each(function () {
                ToggleTRs($(this));
            });

        });

        $(document).ready(function () {
            $('input[type="checkbox"]').change(function () {
                ToggleTRs($(this));
                bronchoSpecimensTaken = true;
            });

            $("#NoneCheckBox").change(function () {
                ToggleNoneCheckBox($(this).is(':checked'));
                bronchoSpecimensTaken = true;
            });

            $('input[type=text]').change(function () {
                $("#NoneCheckBox").prop('checked', false);
                bronchoSpecimensTaken = true;
            });

            $(window).on('beforeunload', function () {
                if (bronchoSpecimensTaken) { $('#SaveButton').click(); }
                valueChanged();
            });
            $(window).on('unload', function () {
                localStorage.clear();
                setRehideSummary();
            });
        });

        function valueChanged() {
            var valueToSave = false;
            $("#BronchoSpecimenTable tr td:first-child input:checkbox ,input[type=text]").each(function () {
                if ($(this).is(':checkbox') && $(this).is(':checked')) {
                    valueToSave = true;
                } else if ($(this).is('input[type=text]') && $(this).val().trim() !== "") {
                    valueToSave = true;
                }
            });
            if (!$('#NoneCheckBox').is(':checked') && !valueToSave)
                localStorage.setItem('valueChanged', 'false');
            else
                localStorage.setItem('valueChanged', 'true');
        }

        function ToggleTRs(chkbox) {
            if (chkbox[0].id != "NoneCheckBox") {
                var checked = chkbox.is(':checked');
                if (checked) {
                    $("#NoneCheckBox").attr('checked', false);
                }
            }
        }

        function ToggleNoneCheckBox(checked) {
            if (checked) {
                $('#BronchoSpecimenTable tr td:first-child input:checkbox ,input[type=text]').each(function () {
                    //$(this).find('td').each(function () {
                    //    $(this).find("input:checkbox:checked").removeAttr("checked");
                    //    $(this).find("input:checkbox").trigger("change");
                    //    $(this).find("input:text").val("");
                    //});
                    if ($(this).is(':checkbox') && $(this).is(':checked')) {
                        $(this).prop('checked', false);
                    } else if ($(this).is('input[type=text]') && $(this).val().trim() !== "") {
                        $(this).val('');
                    }
                });
            }
        }

        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").removeAttr("checked");
            tableCell.find("input:checkbox:checked").removeAttr("checked");
            tableCell.find("input:text").val("");
        }

        function CloseWindow() {
            window.parent.CloseWindow();
        }

        function RemoveZero(sender, args) {
            var tbValue = sender._textBoxElement.value;
            if (tbValue == "0")
                sender._textBoxElement.value = "";
        }
    </script>
    <style type="text/css">
        .abnor_cb1.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,
        .abnor_cb1 .rcbInputCell INPUT.rcbInput,
        .abnor_cb1 {
            color: black !important;
        }
        /*green to black*/

        .abnor_cb2.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,
        .abnor_cb2 .rcbInputCell INPUT.rcbInput,
        .abnor_cb2 {
            color: black !important;
        }
        /*orange to black*/

        .abnor_cb3.RadComboBox .rcbInputCell .rcbArrowCell .rcbFocused .rcbScroll .rcbList .rcbItem .rcbHovered .rcbDisabled .rcbNoWrap .rcbLoading .rcbMoreResults .rcbImage .rcbEmptyMessage .rcbSeparator .rcbLabel,
        .abnor_cb3 .rcbInputCell INPUT.rcbInput,
        .abnor_cb3 {
            color: black !important;
        }
        /*red to black*/

        .ContentTable th {
            height: 25px;
            width: 200px;
        }

        .ContentTable td {
            height: 28px;
        }

        .ContentTable tr:nth-child(odd) {
            /*background: #b8d1f3;*/
        }

        .ContentTable tr:nth-child(even) {
            background: #dae5f4;
        }

        .rgRow {
            background: #fafaf8;
        }
        #RAD_SPLITTER_PANE_CONTENT_ControlsRadPane{
            height: calc(90vh - 20px) !important;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="GastritisRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="GastritisRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
       
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Abnormality specimens</div>

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="410px">
                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <table id="BronchoSpecimenTable" class="rgview" cellpadding="0" cellspacing="0" width="770px">
                                <thead>
                                    <tr>
                                        <th width="138px" class="rgHeader" style="text-align: left;">
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" ForeColor="Black" />
                                        </th>
                                        <th class="rgHeader">PCP</th>
                                        <th class="rgHeader">TB bacteriology</th>
                                        <th class="rgHeader">Histology</th>
                                        <th class="rgHeader">Cytology</th>
                                        <th class="rgHeader">Bacteriology</th>
                                        <th class="rgHeader">Virology</th>
                                        <th class="rgHeader">Mycology</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="rgAltRow">
                                        <td style="font-weight: bold;">EBUS Specimen</td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                            
                                            <telerik:RadNumericTextBox ID="EbusSpecimenTBBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                            <telerik:RadNumericTextBox ID="EbusSpecimenHistologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                <telerik:RadNumericTextBox ID="EbusSpecimenCytologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                    <telerik:RadNumericTextBox ID="EbusSpecimenBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td style="font-weight: bold;">Endobronchial biopsy</td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                                   <telerik:RadNumericTextBox ID="EndobronchialBiopsyTBBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                     <telerik:RadNumericTextBox ID="EndobronchialBiopsyHistologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                                  <telerik:RadNumericTextBox ID="EndobronchialBiopsyBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                    <telerik:RadNumericTextBox ID="EndobronchialBiopsyVirologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                   <telerik:RadNumericTextBox ID="EndobronchialBiopsyMycologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td style="font-weight: bold;">Brush biopsy</td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                              <telerik:RadNumericTextBox ID="BrushBiopsyCytologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                <telerik:RadNumericTextBox ID="BrushBiopsyBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                <telerik:RadNumericTextBox ID="BrushBiopsyVirologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="BrushBiopsyMycologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td style="font-weight: bold;">Distal blind biopsy</td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="DistalBlindBiopsyTBBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="DistalBlindBiopsyHistologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="DistalBlindBiopsyBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="DistalBlindBiopsyVirologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="DistalBlindBiopsyMycologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td style="font-weight: bold;">Transbronchial biopsy</td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TransbronchialBiopsyTBBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TransbronchialBiopsyHistologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TransbronchialBiopsyBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TransbronchialBiopsyVirologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TransbronchialBiopsyMycologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td style="font-weight: bold;">Transtracheal biopsy</td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TranstrachealBiopsyHistologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TranstrachealBiopsyBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TranstrachealBiopsyVirologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TranstrachealBiopsyMycologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td style="font-weight: bold;">Trap</td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TrapPcpRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TrapTBBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TrapCytologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TrapBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TrapVirologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="TrapMycologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td rowspan="2" style="font-weight: bold;">Bronchoalveolar
                                            <br />
                                            Lavage</td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="BronchoalveolarLavagePcpRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="BronchoalveolarLavageTBBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="BronchoalveolarLavageCytologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="BronchoalveolarLavageBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="BronchoalveolarLavageVirologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="BronchoalveolarLavageMycologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td colspan="4" class="rgCell">Volume infused:
                                            <telerik:RadNumericTextBox ID="BronchoalveolarLavageVolInfusedNumericTextBox" runat="server"
                                                IncrementSettings-InterceptMouseWheel="false"
                                                Width="50px"
                                                MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="1" />
                                                <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                            </telerik:RadNumericTextBox>
                                            mls
                                        </td>
                                        <td colspan="3" class="rgCell">Volume recovered:
                                            <telerik:RadNumericTextBox ID="BronchoalveolarLavageVolRecoveredNumericTextBox" runat="server"
                                                IncrementSettings-InterceptMouseWheel="false"
                                                Width="50px"
                                                MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="1" />
                                                <ClientEvents OnBlur="RemoveZero" OnValueChanged="RemoveZero" OnLoad="RemoveZero" />
                                            </telerik:RadNumericTextBox>
                                            mls
                                        </td>
                                    </tr>
                                    <tr class="rgAltRow">
                                        <td style="font-weight: bold;">Fine needle aspirate</td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="FnaTBRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0" Visible="false">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="FnaHistologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="FnaCytologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="FnaBacteriologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="FnaVirologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="FnaMycologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td style="font-weight: bold;">Cryobiopsy</td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell">
                                                 <telerik:RadNumericTextBox ID="CryoHistologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        </td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                    </tr>
                                    <tr class="rgRow">
                                        <td style="font-weight: bold;">Fungal Culture</td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"></td>
                                        <td class="rgCell"> <telerik:RadNumericTextBox ID="FungalCultureMycologyRadNumericTextBox" runat="server" Width="35" Skin="Windows7" MinValue="0">
                                                <NumberFormat AllowRounding="false" DecimalDigits="0" />
                                            </telerik:RadNumericTextBox></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; display: none">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" Icon-PrimaryIconCssClass="telerikCancelButton" OnClientClicking="CloseWindow" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
