<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="PolypDetails.aspx.vb" Inherits="UnisoftERS.CommonPolypDetails" %>

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

        .rgHeader {
            padding: 0px !important;
        }

        .TattooTR, .TattooedWithTR {
            display: none;
        }

        .edit-mode {
            display: none;
        }

        .add-polyp.rgview td {
            padding: 6px;
        }

        .polyp-conditions {
            padding: 0px !important;
        }

            .polyp-conditions li {
                list-style-type: none;
                float: left;
                margin-right: 10px;
            }

        .polyp-details-table:nth-of-type(2n-1) {
            background-color: #f3f3f4;
        }

        #RAD_SPLITTER_PANE_CONTENT_ControlsRadPane {
            overflow: hidden !important;
            height: 500px !important;
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
            <script type="text/javascript">
                function editPolyp(polypId) {
                    $('.view-mode').hide();
                    $('.edit-mode').show();

                    return false;
                }

                function showHideTattooTR(sender, args) {

                    toggleTattooTR(sender._clientID, args.get_newValue());
                }

                function toggleTattooTR(ctrl, value) {
                    var tattooTR = $('#' + ctrl).closest('tr').next().find('.TattooTR');

                    if (value >= 20) {


                        $('.TattooTR').show();
                    }
                    else {

                        $('.TattooTR').hide();
                    }

                    var validator = $(tattooTR).find('.tattoo-validator');
                    if (validator.length > 0)
                        $(validator).prop('enabled', (value >= 20));

                }

                function toggleTattooedWithTR(ctrl, value) {
                    var tattooedWithTR = $('#' + ctrl).closest('tr').next();

                    if (value.toLowerCase() == 'yes') {
                        $(tattooedWithTR).show();
                    }
                    else {
                        $(tattooedWithTR).hide();
                    }
                }


                function savePage() {
                    $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
                }

                function SaveAndClose() {
                    GetRadWindow().BrowserWindow.savePage();
                    GetRadWindow().close();
                }




                $(document).ready(function () {
                    var polypSize = $('#PolypSizeNumericTextBox')
                    toggleTattooTR(polypSize._clientID, polypSize.val())

                    $('.polypectomy-result input').on('change', function () {
                        var ctrl = $(this)[0].id;
                        
                        switch (ctrl) {
                            case 'ExcisedCheckBox':
                                if ($(this).is(':checked')) {
                                    <%--$('#<%=RetrievedCheckBox.ClientID%>').prop('checked', true);--%>
                                }
                                else {
                                    $(this).closest('tr').find('.polypectomy-result input').prop("checked", false);
                                };
                                break;
                            case 'RetrievedCheckBox':
                                if ($(this).is(':checked')) {
                                    $('#<%=ExcisedCheckBox.ClientID%>').prop('checked', true);
                                    $('#<%=DiscardedCheckBox.ClientID%>').prop('checked', false);
                                }
                                else {
                                    $('#<%=DiscardedCheckBox.ClientID%>').prop('checked', true);
                                    $('#<%=SuccessfulCheckBox.ClientID%>').prop('checked', false);
                                };
                                break;
                            case 'DiscardedCheckBox':
                                if ($(this).is(':checked')) {
                                    $('#<%=ExcisedCheckBox.ClientID%>').prop('checked', true);
                                    $('#<%=RetrievedCheckBox.ClientID%>').prop('checked', false);
                                    $('#<%=SuccessfulCheckBox.ClientID%>').prop('checked', false);
                                }
                                else {
                                    $('#<%=RetrievedCheckBox.ClientID%>').prop('checked', true);
                                };
                                break;
                            case 'SuccessfulCheckBox':
                                if ($(this).is(':checked')) {
                                    $('#<%=ExcisedCheckBox.ClientID%>').prop('checked', true);
                                    $('#<%=RetrievedCheckBox.ClientID%>').prop('checked', true);
                                    $('#<%=DiscardedCheckBox.ClientID%>').prop('checked', false);
                                };
                                break;
                        }
                    });

                    $('.tattoo_marking_type input').on('change', function () {
                        var ctrl = $(this)[0].id;
                        var selectedValue = $(this).next().html();

                        toggleTattooedWithTR(ctrl, selectedValue);
                    });

                    $('.sessile-paris-btn').on('change', function () {

                        if ($('#<%=LSTGRadioButton.ClientID%>').is(':checked')) {
                            $('.LSTTypeDiv').show();
                        }
                        else {
                            $('.LSTTypeDiv').hide();
                        }
                    });

                    $('.paris-btn').on('change', function () {
                        if ($('#<%=LSTGRadioButton.ClientID%>').is(':checked')) {
                            var parisDescription = $('#<%=LSTTypesDropdown.ClientID%>').val();
                            $('#newPolypParisDescription').val(parisDescription);
                        }
                        else {
                            var parisDescription = $(this).closest('tr').find('.parisDescription').text();
                            $('#newPolypParisDescription').val(parisDescription);
                        }
                    })

                    $('.pit-btn').on('change', function () {
                        var pitDescription = $(this).closest('tr').find('.pitDescription').text();
                        $('#newPolypPitDescription').val(pitDescription);
                    })
                });

                function showSessileParisPopup(polypId, value) {
                    $('#<%=SessileLSRadioButton.ClientID%>').attr('checked', (value == 1));
                    $('#<%=SessileLLARadioButton.ClientID%>').attr('checked', (value == 2));
                    $('#<%=SessileLLALLCRadioButton.ClientID%>').attr('checked', (value == 3));
                    $('#<%=SessileLLBRadioButton.ClientID%>').attr('checked', (value == 4));
                    $('#<%=SessileLLCRadioButton.ClientID%>').attr('checked', (value == 5));
                    $('#<%=SessileLLCLLARadioButton.ClientID%>').attr('checked', (value == 6));

                    if ((value == 7) || (value == 8) || (value == 9) || (value == 10) || (value == 11)) {
                        $('#<%=LSTGRadioButton.ClientID%>').attr('checked', true);
                        $find('<%=LSTTypesDropdown.ClientID%>').set_value(value);
                    }
                    else {
                        $('#<%=LSTGRadioButton.ClientID%>').attr('checked', false);
                        $find('<%=LSTTypesDropdown.ClientID%>').set_value(0);
                    }

                    $find('<%=SessileParisClassificationRadButton.ClientID%>').set_commandArgument(polypId);
                    $('#newPolypParisDescription').val($("#polypParisLabel").val());
                    $('#newPolypPitDescription').val($("#polypPitLabel").val());
                    var oWnd = $find('<%=SessileParisClassificationPopup.ClientID%>');
                    oWnd.show();
                    return false;
                }

                function closeSessileParisPopup() {
                    var oWnd = $find('<%=SessileParisClassificationPopup.ClientID%>');
                    oWnd.close();
                }

                function showPedunculatedParisPopup(polypId, value) {
                    $('#<%=ProtrudedRadioButton.ClientID%>').attr('checked', (value == 7));
                    $('#<%=PedunculatedRadioButton.ClientID%>').attr('checked', (value == 8));

                    $find('<%=PedunculatedParisClassificationRadButton.ClientID%>').set_commandArgument(polypId);
                    var oWnd = $find('<%=PedunculatedParisClassificationPopUp.ClientID%>');
                    oWnd.show();
                    return false;
                }

                function closePedunculatedParisPopup() {
                    var oWnd = $find('<%=PedunculatedParisClassificationPopUp.ClientID%>');
                    oWnd.close();
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

                function closeSessilePitPatternsPopup() {
                    var oWnd = $find('<%=SessilePitPatternsPopup.ClientID%>');
                    oWnd.close();
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

                function closePedunculatedPitPatternsPopup() {
                    var oWnd = $find('<%=PedunculatedPitPatternsPopup.ClientID%>');
                    oWnd.close();
                }


                function ClosePopup() {
                    var oManager = GetRadWindowManager();
                    //Call GetActiveWindow to get the active window 
                    var oActive = oManager.getActiveWindow();
                    if (oActive == null) { window.parent.CloseWindow(); } else { oActive.close(null); return false; }
                    // return false;
                }

                function showAddNewWindow() {
                    var oWnd = $find("<%= NewPolypRadWindow.ClientID%>");
                    if (oWnd != null) {

                        $find('<%=PolypQtyRadNumericTextBox.ClientID%>').set_value();
                        $find('<%=PolypSizeNumericTextBox.ClientID%>').set_value();
                        $('#<%=ExcisedCheckBox.ClientID%>').prop('checked', false);
                        $('#<%=SuccessfulCheckBox.ClientID%>').prop('checked', false);

                        if ($find('<%=Removal_ComboBox.ClientID%>') != null)
                            $find('<%=Removal_ComboBox.ClientID%>').get_items().getItem(0).select();

                        if ($find('<%=Removal_Method_ComboBox.ClientID%>') != null)
                            $find('<%=Removal_Method_ComboBox.ClientID%>').get_items().getItem(0).select();

                        if ($find('<%=Type_ComboBox.ClientID%>') != null) {
                            $find('<%=Type_ComboBox.ClientID%>').get_items().getItem(0).select();
                            $('#<%=Probably_CheckBox.ClientID%>').prop('checked', false);
                        }

                        if ($('#<%=InflamCheckBox.ClientID%>')[0] != null) {
                            $('#<%=InflamCheckBox.ClientID%>').prop('checked', false);
                        }

                        if ($('#<%=PostInflamCheckBox.ClientID%>')[0] != null) {
                            $('#<%=PostInflamCheckBox.ClientID%>').prop('checked', false);
                        }

                        $('#<%=PolypConditionsCheckBoxList.ClientID%> input').each(function (idx, itm) {
                            $(itm).prop('checked', false);
                        });
                        oWnd.show();
                    }
                }

                function closeAddNewWindow() {
                    var oWnd = $find("<%= NewPolypRadWindow.ClientID%>");
                    if (oWnd != null) {
                        oWnd.close();
                    }
                }

                function UpdateParisLabel() {
                    $('#polypParisLabel').val($("#newPolypParisDescription").val());
                }

                function UpdatePitLabel() {
                    $('#polypPitLabel').val($("#newPolypPitDescription").val());
                }

            </script>
        </telerik:RadScriptBlock>

        <telerik:RadScriptManager ID="RadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <%--   <telerik:AjaxSetting AjaxControlID="AddPolypDetailsRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PolypDetailsRepeater" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
                <telerik:AjaxSetting AjaxControlID="ParisShowButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SessileParisClassificationPopup" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="PedunculatedParisClassificationPopUp" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="PitShowButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SessilePitPatternsPopup" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="PedunculatedPitPatternsPopup" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SessileParisClassificationRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ParisShowButton" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="SessileParisClassificationRadButton" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="SessileParisClassificationPopup" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="PedunculatedParisClassificationRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ParisShowButton" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="PedunculatedParisClassificationRadButton" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="PedunculatedParisClassificationPopUp" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SessilePitPatternsRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PitShowButton" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="SessilePitPatternsRadButton" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="SessilePitPatternsPopup" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="PedunculatedPitPatternsRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PitShowButton" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="PedunculatedPitPatternsRadButton" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="PedunculatedPitPatternsPopup" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="CancelSessileParisClassificationRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SessileParisClassificationPopup" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="CancelPedunculatedParisClassificationRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PedunculatedParisClassificationPopUp" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="CancelSessilePitPatternsRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SessilePitPatternsPopup" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="CancelPedunculatedPitPatternsRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PedunculatedPitPatternsPopup" UpdatePanelRenderMode="Inline" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>


        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">

            <telerik:RadPane ID="ControlsRadPane" runat="server" Width="99%">

                <div id="FormDiv" style="padding: 20px; width: 700px; font-size: 12px; font-family: Segoe UI,Arial,Helvetica,sans-serif">

                    <div class="add-polyp" style="margin-bottom: 15px;" id="NewPolypDiv" runat="server">
                        <table cellpadding="0" cellspacing="0" class="rgview">
                            <tbody>
                                <tr id="removeTypeandQtyTR" runat="server">
                                    <td style="width: 20%; border-right: none">Type</td>
                                    <td style="border-right: none; border-left: none;">
                                        <telerik:RadComboBox ID="PolypTypeRadComboBox" runat="server" Skin="Metro" AutoPostBack="true" OnSelectedIndexChanged="PolypTypeRadComboBox_SelectedIndexChanged">
                                            <Items>
                                                <telerik:RadComboBoxItem Text="Sessile" Value="1" />
                                                <telerik:RadComboBoxItem Text="Pedunculated" Value="2" />
                                                <telerik:RadComboBoxItem Text="Pseudo" Value="3" />
                                                <telerik:RadComboBoxItem Text="Submucosal" Value="4" />
                                                <telerik:RadComboBoxItem Text="Focal lesions" Value="5" />
                                                <telerik:RadComboBoxItem Text="Fundic Gland Polyp" Value="6" />
                                            </Items>
                                        </telerik:RadComboBox>
                                    </td>
                                    <td style="border-right: none;">Qty
                                    </td>
                                    <td style="border-left: none;">
                                        <telerik:RadNumericTextBox ID="PolypQtyRadNumericTextBox" runat="server"
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1"
                                            Width="35px"
                                            MinValue="1"
                                            Style="margin-right: 3px;">
                                            <NumberFormat DecimalDigits="0" />
                                        </telerik:RadNumericTextBox>
                                        <asp:RequiredFieldValidator ID="PolypQtyRequiredFieldValidator" runat="server" ErrorMessage="*" InitialValue="" ForeColor="Red" ControlToValidate="PolypQtyRadNumericTextBox" ValidationGroup="polypdetails" />
                                        <asp:RequiredFieldValidator ID="PolypQtyRequiredFieldValidator2" runat="server" ErrorMessage="*" InitialValue="0" ForeColor="Red" ControlToValidate="PolypQtyRadNumericTextBox" ValidationGroup="polypdetails" />
                                    </td>
                                </tr>
                                <%-- written by mostafiz--%>

                                <%--<tr id="SubmucosalPolypTR" runat="server" visible="false">
                                    <td style="border-right: none;" colspan="2">Submucosal Quantity:&nbsp;
                                                         <telerik:RadNumericTextBox ID="SubmucosalQtyNumericTextBox" runat="server"
                                                             ShowSpinButtons="true"
                                                             IncrementSettings-InterceptMouseWheel="false"
                                                             IncrementSettings-Step="1"
                                                             Width="50px"
                                                             MinValue="0">
                                                             <NumberFormat DecimalDigits="0" />
                                                         </telerik:RadNumericTextBox>
                                    </td>
                                    <td style="border-left: none;" colspan="2">Submucosal Size of largest:&nbsp;
                                                         <telerik:RadNumericTextBox ID="SubmucosalLargestNumericTextBox" runat="server"
                                                             ShowSpinButtons="true"
                                                             IncrementSettings-InterceptMouseWheel="false"
                                                             IncrementSettings-Step="1"
                                                             Width="50px"
                                                             MinValue="0">
                                                             <NumberFormat DecimalDigits="0" />
                                                         </telerik:RadNumericTextBox>
                                    </td>

                                </tr>


                                <tr id="FocalPolypTR" runat="server" visible="false">
                                    <td style="border-right: none;" colspan="2">Focal Quantity:&nbsp;
                                                 <telerik:RadNumericTextBox ID="FocalQtyNumericTextBox" runat="server"
                                                     ShowSpinButtons="true"
                                                     IncrementSettings-InterceptMouseWheel="false"
                                                     IncrementSettings-Step="1"
                                                     Width="50px"
                                                     MinValue="0">
                                                     <NumberFormat DecimalDigits="0" />
                                                 </telerik:RadNumericTextBox>
                                    </td>
                                    <td style="border: none;" colspan="2">Focal Size of largest:&nbsp;
                                                 <telerik:RadNumericTextBox ID="FocalLargestNumericTextBox" runat="server"
                                                     ShowSpinButtons="true"
                                                     IncrementSettings-InterceptMouseWheel="false"
                                                     IncrementSettings-Step="1"
                                                     Width="50px"
                                                     MinValue="0">
                                                     <NumberFormat DecimalDigits="0" />
                                                 </telerik:RadNumericTextBox>
                                    </td>


                                </tr>


                                <tr id="FundicGlandPolypTR" runat="server" visible="false">
                                    <td style="border-right: none;" colspan="2">Fundic Gland Quantity:&nbsp;
                                                     <telerik:RadNumericTextBox ID="FundicGlandPolypQtyNumericTextBox" runat="server"
                                                         ShowSpinButtons="true"
                                                         IncrementSettings-InterceptMouseWheel="false"
                                                         IncrementSettings-Step="1"
                                                         Width="50px"
                                                         MinValue="0">
                                                         <NumberFormat DecimalDigits="0" />
                                                     </telerik:RadNumericTextBox>
                                    </td>
                                    <td style="border: none;" colspan="2">Fundic Gland Size of largest:&nbsp;
                                                     <telerik:RadNumericTextBox ID="FundicGlandPolypLargestNumericTextBox" runat="server"
                                                         ShowSpinButtons="true"
                                                         IncrementSettings-InterceptMouseWheel="false"
                                                         IncrementSettings-Step=".50"
                                                         Width="60px"
                                                         MinValue="0">
                                                         <NumberFormat DecimalDigits="2" />
                                                     </telerik:RadNumericTextBox>
                                    </td>

                                </tr>--%>



                                <%-- written by mostafiz--%>



                                <tr>
                                    <td style="border-right: none;">Size
                                    </td>
                                    <td style="border-left: none;" colspan="3">
                                        <telerik:RadNumericTextBox ID="PolypSizeNumericTextBox" runat="server"
                                            IncrementSettings-InterceptMouseWheel="false"
                                            IncrementSettings-Step="1"
                                            Width="35px"
                                            MinValue="1"
                                            Style="margin-right: 3px;">
                                            <NumberFormat DecimalDigits="0" />
                                            <ClientEvents OnValueChanged="showHideTattooTR" />
                                        </telerik:RadNumericTextBox>mm
                                        <asp:RequiredFieldValidator ID="PolpySizeRequiredFieldValidator" runat="server" ControlToValidate="PolypSizeNumericTextBox" InitialValue="0" ErrorMessage="*" ForeColor="Red" ValidationGroup="polypdetails" />
                                        <asp:RequiredFieldValidator ID="PolpySizeRequiredFieldValidator2" runat="server" ControlToValidate="PolypSizeNumericTextBox" InitialValue="" ErrorMessage="*" ForeColor="Red" ValidationGroup="polypdetails" />
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding: 0; border: none;"colspan="4">
                                        <table style="table-layout:fixed; width:100% ; ">
                                            <tr>
                                                
                                                <td style="border-right: none;">
                                                    Excised:&nbsp;<asp:CheckBox ID="ExcisedCheckBox" runat="server" CssClass="polypectomy-result" />
                                                </td>

                                                <td class="rgCell">Retrieved:&nbsp;
                                                    <asp:CheckBox ID="RetrievedCheckBox" runat="server" CssClass="polypectomy-result" />
                                                </td>
                                                <td class="rgCell">Discarded:&nbsp;
                                                    <asp:CheckBox ID="DiscardedCheckBox" runat="server" CssClass="polypectomy-result" />
                                                </td>
                                               
                                                <td style="border-left: none;">
                                                   Successful / Sent to Lab &nbsp;<asp:CheckBox ID="SuccessfulCheckBox" runat="server" CssClass="polypectomy-result" />
                                                </td>
                                            </tr>
                                        </table>
                                    </td>

                                </tr>


                                <tr>
                                    <td style="border-right: none;">Removal
                                    </td>
                                    <td style="border-right: none; border-left: none;">
                                        <telerik:RadComboBox ID="Removal_ComboBox" runat="server" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" AppendDataBoundItems="true" Width="85px">
                                            <Items>
                                                <telerik:RadComboBoxItem Text="" Value="0" />
                                            </Items>
                                        </telerik:RadComboBox>
                                    </td>
                                    <td style="border-right: none;">By
                                    </td>
                                    <td style="border-left: none;">
                                        <telerik:RadComboBox ID="Removal_Method_ComboBox" runat="server" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" AppendDataBoundItems="true">
                                            <Items>
                                                <telerik:RadComboBoxItem Text="" Value="0" />
                                            </Items>
                                        </telerik:RadComboBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="border-right: none;">Tumor
                                    </td>
                                    <td style="border-left: none;" colspan="3">
                                        <telerik:RadComboBox ID="Type_ComboBox" runat="server" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" AppendDataBoundItems="true" Width="90px">
                                            <Items>
                                                <telerik:RadComboBoxItem Text="" Value="0" />
                                            </Items>
                                        </telerik:RadComboBox>
                                        <asp:CheckBox ID="Probably_CheckBox" runat="server" Text="Probably" TextAlign="Right" SkinID="Metro" />
                                    </td>
                                </tr>
                                <tr id="parisTR" runat="server">
                                    <td style="border-right: none;">
                                        <telerik:RadButton ID="ParisShowButton" runat="server" Text="Paris classification..." Skin="Metro" AutoPostBack="false"></telerik:RadButton>
                                    </td>
                                    <td style="border-left: none;" colspan="3">
                                        <asp:TextBox ID="polypParisLabel" runat="server" Enabled="false" BorderStyle="None" /><%--This will show the paris classification selected--%>
                                        <asp:HiddenField ID="newPolypParisDescription" runat="server" />
                                        <asp:RequiredFieldValidator ID="PolypParisRequiredFieldValidator" runat="server" ErrorMessage="* Paris Classifcation required" InitialValue="" ForeColor="Red" ControlToValidate="polypParisLabel" ValidationGroup="polypdetails" />
                                    </td>
                                </tr>
                                <tr id="pitTR" runat="server">
                                    <td style="border-right: none;">
                                        <telerik:RadButton ID="PitShowButton" runat="server" Text="Pit patterns..." Skin="Metro" AutoPostBack="false"></telerik:RadButton>
                                    </td>
                                    <td style="border-left: none;" colspan="3">
                                        <asp:TextBox ID="polypPitLabel" runat="server" Enabled="false" BorderStyle="None"/><%--This will show the pit patterns--%>
                                        <asp:HiddenField ID="newPolypPitDescription" runat="server" />
                                        <asp:RequiredFieldValidator ID="PolypPitRequiredFieldValidator" runat="server" ErrorMessage="* Pit pattern required" InitialValue="" ForeColor="Red" ControlToValidate="polypPitLabel" ValidationGroup="polypdetails" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <table class="inner-table" cellpadding="5" cellspacing="5">

                                            <tr id="pseudoPolypTR" runat="server" visible="false">
                                                <td colspan="4">
                                                    <asp:CheckBox ID="InflamCheckBox" runat="server" Text="inflammatory" TextAlign="Right" SkinID="Metro" AutoPostBack="false" />&nbsp;
                                            <asp:CheckBox ID="PostInflamCheckBox" runat="server" Text="post-inflammatory" TextAlign="Right" SkinID="Metro" AutoPostBack="false" />
                                                </td>
                                            </tr>
                                            <tr id="PolypConditionTR" runat="server" visible="false">
                                                <td colspan="4" style="padding-left: 0px;">
                                                    <asp:CheckBoxList ID="PolypConditionsCheckBoxList" runat="server" DataTextField="Description" DataValueField="UniqueId" RepeatColumns="4" />
                                                </td>
                                            </tr>

                                            <tr class="TattooTR">
                                                <td style="border: none;" colspan="3">Was the cancer/polyp tattooed?
                                                    <asp:RadioButtonList ID="PolypTattooedRadioButtonList" runat="server"
                                                        CellSpacing="25" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl tattoo_marking_type" DataTextField="Description" DataValueField="UniqueId" />

                                                    <asp:RequiredFieldValidator ID="PolypTattooRequiredFieldValidator" runat="server" Enabled="false" SetFocusOnError="true" Display="Dynamic" ControlToValidate="PolypTattooedRadioButtonList" CssClass="tattoo-validator" ValidationGroup="polypdetails" InitialValue="" ErrorMessage="You must specify tattoo details for polyps of 20mm or more" ForeColor="Red" />
                                                </td>
                                            </tr>
                                            <tr class="TattooedWithTR">
                                                <td colspan="1">Using&nbsp;<telerik:RadComboBox ID="Tattoo_Marking_ComboBox" runat="server" Skin="Metro" AppendDataBoundItems="true" DataTextField="Description" DataValueField="UniqueId">
                                                    <Items>
                                                        <telerik:RadComboBoxItem Value="0" Text="" />
                                                    </Items>
                                                </telerik:RadComboBox>
                                                </td>
                                                <td style="border: none;" colspan="3">
                                                    <span>Location:</span>
                                                    <span>
                                                        <asp:CheckBox ID="TattooLocationDistalCheckBox" runat="server" Text="Distal" TabIndex="78" />&nbsp;
                                                    </span>
                                                    <span>
                                                        <asp:CheckBox ID="TattooLocationProximalCheckBox" runat="server" Text="Proximal" TabIndex="78" />&nbsp;
                                                    </span>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>

                            </tbody>
                        </table>
                        <br />
                        <telerik:RadButton ID="AddPolypDetailsRadButton" runat="server" Text="Add polyps" OnClick="AddPolypDetailsRadButton_Click" ValidationGroup="polypdetails" OnClientClicked="AddPolypDetailsRadButton_ClientClick" />
                    </div>

                </div>

            </telerik:RadPane>



        </telerik:RadSplitter>
        <telerik:RadWindowManager ID="RadMan" runat="server" Modal="true" Animation="Fade" KeepInScreenBounds="true" Behaviors="Close" Skin="Metro" VisibleStatusbar="false" VisibleOnPageLoad="false">
            <Windows>
                <telerik:RadWindow ID="NewPolypRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" AutoSize="false" Width="700px" Height="400px" Title="Add new polyp(s)" VisibleStatusbar="false" Modal="True">
                    <ContentTemplate>
                        <div style="margin-top: 25px;">

                            <br />

                            <telerik:RadButton ID="CancelAddPolypDetailsRadButton" runat="server" Text="Cancel and Close" OnClientClicked="closeAddNewWindow" AutoPostBack="false" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="SessileParisClassificationPopup" runat="server" Width="652" Height="450" ReloadOnShow="true" ShowContentDuringLoad="false" Title=" Paris Classification - The Morphological Appearance of a Lesion">
                    <ContentTemplate>
                        <div class="labelHeaderPopup riLabel">
                        </div>
                        <table id="SessileParisClassificationTable" class="tablePopup rgview">
                            <tr>
                                <td>Protruded type
                                </td>
                                <td>
                                    <asp:RadioButton ID="SessileLSRadioButton" CssClass="sessile-paris-btn, paris-btn" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="testImg" ImageUrl="~/Images/ParisClassification/ParisClassification_Sessile.png" runat="server" />
                                </td>
                                <td class="parisDescription">Is - sessile</td>
                            </tr>
                            <tr>
                                <td rowspan="2">Superficial
                                <br />
                                    elevated type
                                </td>
                                <td>
                                    <asp:RadioButton ID="SessileLLARadioButton" CssClass="sessile-paris-btn, paris-btn" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="imgLogo" runat="server" ImageUrl="~/Images/ParisClassification/ParisClassification_FlatElevated.png" />
                                </td>
                                <td class="parisDescription">IIa - flat elevated</td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:RadioButton ID="SessileLLALLCRadioButton" CssClass="sessile-paris-btn, paris-btn" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage1" ImageUrl="~/Images/ParisClassification/ParisClassification_FlatElevatedDep.png" runat="server" />
                                </td>
                                <td class="parisDescription">IIa + IIc - flat elevated with depression</td>
                            </tr>
                            <tr>
                                <td>Flat type
                                </td>
                                <td>
                                    <asp:RadioButton ID="SessileLLBRadioButton" CssClass="sessile-paris-btn, paris-btn" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage2" ImageUrl="~/Images/ParisClassification/ParisClassification_Flat.png" runat="server" />
                                </td>
                                <td class="parisDescription">IIb - flat</td>
                            </tr>
                            <tr>
                                <td rowspan="2">Depressed type
                                </td>
                                <td>
                                    <asp:RadioButton ID="SessileLLCRadioButton" CssClass="sessile-paris-btn, paris-btn" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage3" ImageUrl="~/Images/ParisClassification/ParisClassification_SlightlyDep.png" runat="server" />
                                </td>
                                <td class="parisDescription">IIc - slightly depressed</td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:RadioButton ID="SessileLLCLLARadioButton" CssClass="sessile-paris-btn, paris-btn" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage4" ImageUrl="~/Images/ParisClassification/ParisClassification_SlightlyDep2.png" runat="server" />
                                </td>
                                <td class="parisDescription">IIc + IIa slightly depressed</td>
                            </tr>
                            <tr>
                                <td>Lateral
                                <br />
                                    spreading tumor
                                </td>
                                <td>
                                    <asp:RadioButton ID="LSTGRadioButton" CssClass="sessile-paris-btn, paris-btn" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td colspan="2">
                                    <div class="LSTTypeDiv">
                                        Choose one:&nbsp;
                                          <telerik:RadComboBox ID="LSTTypesDropdown" CssClass="sessile-paris-btn, paris-btn" runat="server" Skin="Metro" AutoPostBack="false" DataTextField="Description" DataValueField="UniqueId" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                        <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                            <telerik:RadButton ID="SessileParisClassificationRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" OnClientClicked="UpdateParisLabel" />
                            <telerik:RadButton ID="CancelSessileParisClassificationRadButton" runat="server" Text="Cancel" Skin="Web20" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="PedunculatedParisClassificationPopUp" runat="server" Width="652" Height="250" ReloadOnShow="true" ShowContentDuringLoad="false" Title=" Paris Classification - The Morphological Appearance of a Lesion">
                    <ContentTemplate>
                        <div class="labelHeaderPopup riLabel">
                        </div>
                        <table id="PedunculatedParisClassificationTable" class="tablePopup rgview">
                            <tr>
                                <td rowspan="2">Protruded type
                                </td>
                                <td>
                                    <asp:RadioButton ID="ProtrudedRadioButton" CssClass="paris-btn" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage11" ImageUrl="~/Images/ParisClassification/ParisClassification_Pedunculated.png" runat="server" />
                                </td>
                                <td class="parisDescription">Ip - Pedunculated</td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:RadioButton ID="PedunculatedRadioButton" CssClass="paris-btn" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage12" runat="server" ImageUrl="~/Images/ParisClassification/ParisClassification_SubPedunculated.png" />
                                </td>
                                <td class="parisDescription">Isp - sub pedunculated</td>
                            </tr>
                        </table>
                        <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                            <telerik:RadButton ID="PedunculatedParisClassificationRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" OnClientClicked="UpdateParisLabel" />
                            <telerik:RadButton ID="CancelPedunculatedParisClassificationRadButton" runat="server" Text="Cancel" Skin="Web20" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>

                <telerik:RadWindow ID="SessilePitPatternsPopup" runat="server" Width="652" Height="510" ReloadOnShow="true" ShowContentDuringLoad="false" Title=" Pit Patterns - The Surface Appearance of a Lesion">
                    <ContentTemplate>
                        <div class="labelHeaderPopup riLabel">
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
                                        <asp:RadioButton ID="SessileNormalRoundPitsRadioButton" CssClass="pit-btn" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>I
                                    </td>
                                    <td class="pitDescription">Normal round pits
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="SessileRadBinaryImage5" ImageUrl="~/Images/PitPatterns/PitPattern1.png" runat="server" />
                                    </td>
                                    <td>0.07 +/- 0.02</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="SessileStellarRadioButton" CssClass="pit-btn" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>II
                                    </td>
                                    <td class="pitDescription">Stellar or papillary typical of hyperplastic polyps
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage6" ImageUrl="~/Images/PitPatterns/PitPattern2.png" runat="server" />
                                    </td>
                                    <td>0.03 +/- 0.01</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="SessileTubularRoundPitsRadioButton" CssClass="pit-btn" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>III s
                                    </td>
                                    <td class="pitDescription">Tubular/round pits smaller than pit type I typical of adenomas
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage7" ImageUrl="~/Images/PitPatterns/PitPattern3.png" runat="server" />
                                    </td>
                                    <td>0.07 +/- 0.02</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="SessileTubularRadioButton" CssClass="pit-btn" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>III L
                                    </td>
                                    <td class="pitDescription">Tubular/large typical of adenomas
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage8" ImageUrl="~/Images/PitPatterns/PitPattern4.png" runat="server" />
                                    </td>
                                    <td>0.22 +/- 0.09</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="SessileSulcusRadioButton" CssClass="pit-btn" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>IV
                                    </td>
                                    <td class="pitDescription">Sulcus/gyrus brain like typical of tubulovillous adenomas
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage9" ImageUrl="~/Images/PitPatterns/PitPattern5.png" runat="server" />
                                    </td>
                                    <td>0.93 +/- 0.32</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="SessileLossRadioButton" CssClass="pit-btn" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>V
                                    </td>
                                    <td class="pitDescription">Loss of architecture typical of invasion or high grade dysplasia
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage10" ImageUrl="~/Images/PitPatterns/PitPattern6.png" runat="server" />
                                    </td>
                                    <td>N/A</td>
                                </tr>
                            </tbody>
                        </table>
                        <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                            <telerik:RadButton ID="SessilePitPatternsRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" OnClientClicked="UpdatePitLabel" />
                            <telerik:RadButton ID="CancelSessilePitPatternsRadButton" runat="server" Text="Cancel" Skin="Web20" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="PedunculatedPitPatternsPopup" runat="server" Width="652" Height="510" ReloadOnShow="true" ShowContentDuringLoad="false" Title=" Pit Patterns - The Surface Appearance of a Lesion">
                    <ContentTemplate>
                        <div class="labelHeaderPopup riLabel">
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
                                        <asp:RadioButton ID="PedunculatedNormalRoundPitsRadioButton" CssClass="pit-btn" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>I
                                    </td>
                                    <td class="pitDescription">Normal round pits
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="PedunculatedRadBinaryImage5" ImageUrl="~/Images/PitPatterns/PitPattern1.png" runat="server" />
                                    </td>
                                    <td>0.07 +/- 0.02</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="PedunculatedStellarRadioButton" CssClass="pit-btn" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>II
                                    </td>
                                    <td class="pitDescription">Stellar or papillary typical of hyperplastic polyps
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage5" ImageUrl="~/Images/PitPatterns/PitPattern2.png" runat="server" />
                                    </td>
                                    <td>0.03 +/- 0.01</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="PedunculatedTubularRoundPitsRadioButton" CssClass="pit-btn" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>III s
                                    </td>
                                    <td class="pitDescription">Tubular/round pits smaller than pit type I typical of adenomas
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage13" ImageUrl="~/Images/PitPatterns/PitPattern3.png" runat="server" />
                                    </td>
                                    <td>0.07 +/- 0.02</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="PedunculatedTubularRadioButton" CssClass="pit-btn" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>III L
                                    </td>
                                    <td class="pitDescription">Tubular/large typical of adenomas
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage14" ImageUrl="~/Images/PitPatterns/PitPattern4.png" runat="server" />
                                    </td>
                                    <td>0.22 +/- 0.09</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="PedunculatedSulcusRadioButton" CssClass="pit-btn" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>IV
                                    </td>
                                    <td class="pitDescription">Sulcus/gyrus brain like typical of tubulovillous adenomas
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage15" ImageUrl="~/Images/PitPatterns/PitPattern5.png" runat="server" />
                                    </td>
                                    <td>0.93 +/- 0.32</td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="PedunculatedLossRadioButton" CssClass="pit-btn" runat="server" GroupName="PitTypeRadioGroup" SkinID="Web20" />
                                    </td>
                                    <td>V
                                    </td>
                                    <td class="pitDescription">Loss of architecture typical of invasion or high grade dysplasia
                                    </td>
                                    <td>
                                        <telerik:RadBinaryImage ID="RadBinaryImage16" ImageUrl="~/Images/PitPatterns/PitPattern6.png" runat="server" />
                                    </td>
                                    <td>N/A</td>
                                </tr>
                            </tbody>
                        </table>
                        <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                            <telerik:RadButton ID="PedunculatedPitPatternsRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" OnClientClicked="UpdatePitLabel" />
                            <telerik:RadButton ID="CancelPedunculatedPitPatternsRadButton" runat="server" Text="Cancel" Skin="Web20" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
    </form>
</body>
</html>
