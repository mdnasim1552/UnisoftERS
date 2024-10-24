<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Colon_Lesions" CodeBehind="Lesions.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />

    <style type="text/css">
        .tableWithNoBorders {
            border: none;
            margin-top: 5px;
            display: none;
        }

            .tableWithNoBorders td {
                border: none;
                height: 15px;
                /*text-align:center;*/
            }

        .grayout {
            opacity: 0.3; /* Real browsers */
            filter: alpha(opacity = 30); /* MSIE */
        }

        .labelHeaderPopup {
            margin: 10px;
            font-weight: bold;
            text-align: center;
        }

        .tablePopup {
            /*border: 1px solid red;*/
            margin: 30px 20px 20px 20px;
        }

            .tablePopup td {
                /*border: 1px solid red;*/
            }

        #NoneCheckBox {
            color: #384e76;
        }

        .tableLes {
            /*border:1px solid red !important;*/
            border-collapse: collapse;
        }

            .tableLes tbody tr {
                /*border:1px solid red !important;*/
                /*height:35px;*/
            }

            .tableLes td:first-child {
                /*border-right:none;*/
                height: 35px;
                /*border:none;*/
            }

        .rbl label {
            margin-right: 15px;
        }
    </style>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            function savePage() {
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
            }

            var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
            var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";
            var selectedPolypType;

            $(window).on('load', function () {
                checkAllRadControls($find("NoneCheckBox").get_checked());
                $("input[id*='_CheckBox_ClientState']").each(function () {
                    ToggleRow($(this)[0].id.replace("_ClientState", ""));
                });
                displayTumourDetails();
                displayPolypTattooDetails();
            });

            $(document).ready(function () {
                $('.poly-details-btn').on('click', function () {
                    var txtQty = $(this).closest('tr').find('.polyp-qty').val();

                    if (txtQty == "" || txtQty == 0) {
                        alert("Please enter a quantity of 1 or more");
                    }
                    else {
                        var url = "<%= ResolveUrl("PolypDetails.aspx?qty={0}&type={1}&siteid={2}")%>";
                        url = url.replace("{0}", txtQty);
                        url = url.replace("{1}", selectedPolypType);
                        url = url.replace("{2}", <%=siteId%>);

                        var oWnd = $find("<%= PolypDetailsRadWindow.ClientID %>");
                        oWnd._navigateUrl = url
                        oWnd.set_title("Polyp details");
                        oWnd.show();
                    }
                });

                $('#TumourRadioButtonList input').change(function () {
                    displayTumourDetails();
                });

                $('#PolypTattooedRadioButtonList input').change(function () {
                    displayPolypTattooDetails();
                });

                // (AS: 7th/Jan/2020) bug fix for "Number retrieved" increasing "Number to labs"
                // Sessile Polyps
                var numberToLabsSessile = $('#SessileToLabsNumericTextBox').val();
                $('#NumberToLabsTextBoxHiddenSessile').val(numberToLabsSessile);

                // Pedunculated Polyps
                var numberToLabsPedunculated = $('#PedunculatedToLabsNumericTextBox').val();
                $('#NumberToLabsTextBoxHiddenPedunculated').val(numberToLabsPedunculated);

                //Pseudo Polyps
                var numberToLabsPseudo = $('#PseudoToLabsNumericTextBox').val();
                $('#NumberToLabsTextBoxHiddenPseudo').val(numberToLabsPseudo);

            });

            function ChangeText(sender, eventArgs) {
                var elemID = sender.get_element().id;
                updateNumericBox(elemID);
            }

            function updateNumericBox(elemID) {
                var ArrNames, iPos, updateElem;
                switch (elemID.substr(0, 6)) {
                    case 'Sessil':
                        ArrNames = ["SessileQtyNumericTextBox", "SessileExcisedNumericTextBox", "SessileSuccessfulNumericTextBox", "SessileRetrievedNumericTextBox", "SessileToLabsNumericTextBox"]; break;
                    case 'Pedunc':
                        ArrNames = ["PedunculatedPolypsQtyNumericTextBox", "PedunculatedExcisedNumericTextBox", "PedunculatedSuccessfulNumericTextBox", "PedunculatedRetrievedNumericTextBox", "PedunculatedToLabsNumericTextBox"]; break;
                    case 'Pseudo':
                        if ($find("PseudoMultipleCheckBox").get_checked()) {
                            ArrNames = ["PseudoExcisedNumericTextBox", "PseudoSuccessfulNumericTextBox", "PseudoRetrievedNumericTextBox", "PseudoToLabsNumericTextBox"];
                        } else {
                            ArrNames = ["PseudoPolypsQtyNumericTextBox", "PseudoExcisedNumericTextBox", "PseudoSuccessfulNumericTextBox", "PseudoRetrievedNumericTextBox", "PseudoToLabsNumericTextBox"];
                        }
                        break;
                }

                iPos = jQuery.inArray(elemID, ArrNames); //Get position in array
                var iChangedTo = $('input[name="' + ArrNames[iPos] + '"]').val();

                for (i = 0; i < iPos; i++) {
                    updateElem = $('input[name="' + ArrNames[i] + '"]');
                    if (updateElem.val() == '') { updateElem.val(0); }
                    if (parseInt(updateElem.val()) < iChangedTo) {
                        updateElem.val(iChangedTo);
                    }
                }

                // (AS: 7th/Jan/2020) bug fix for "Number retrieved" increasing "Number to labs"                                
                var currentNumberToLabs = $('input[name="' + ArrNames[4] + '"]');
                var newNumberRetrieved = $('input[name="' + ArrNames[3] + '"]').val();

                if (iPos == 3) {
                    if (newNumberRetrieved < currentNumberToLabs.val()) currentNumberToLabs.val(newNumberRetrieved);
                }
            }


            function ClearControls(tableCell) {
                tableCell.find("input[id*='CheckBox']").each(function () {
                    var elemId = $(this)[0].id.replace("_ClientState", "");
                    var chkBx = $find(elemId);
                    if (chkBx != null) {
                        chkBx.set_checked(false);
                    }
                });
                tableCell.find("input:radio:checked").removeAttr("checked");
                tableCell.find("input:checkbox:checked").removeAttr("checked");
                tableCell.find("input:text").val("");

                elemId = tableCell[0].id.replace("PolypsTable", "ParisClassificationTable");
                var parisclasstable = $("#" + elemId);
                if (parisclasstable != null) {
                    parisclasstable.find("input[id*='RadioButton']").each(function () {
                        var elemId = $(this)[0].id.replace("_ClientState", "");
                        var chkBx = $find(elemId);
                        if (chkBx != null) {
                            chkBx.set_checked(false);
                        }
                    });
                }

                elemId = tableCell[0].id.replace("PolypsTable", "PitPatternsTable");
                var parisclasstable = $("#" + elemId);
                if (parisclasstable != null) {
                    parisclasstable.find("input[id*='RadioButton']").each(function () {
                        var elemId = $(this)[0].id.replace("_ClientState", "");
                        var chkBx = $find(elemId);
                        if (chkBx != null) {
                            chkBx.set_checked(false);
                        }
                    });
                }
            }

            function ToggleTRs(sender, args) {
                ToggleRow(sender.get_element().id, args.get_checked());
            }

            function ToggleRow(chkBoxId, ticked) {
                if (chkBoxId != "NoneCheckBox") {
                    if (ticked == undefined) {
                        ticked = $find(chkBoxId).get_checked();
                    }
                    var tableId = chkBoxId.replace("_CheckBox", "Table");
                    var table = $telerik.$("[id$='" + tableId + "']");

                    $("#" + chkBoxId).parents("td").eq(1)
                        .next('td').children('table').each(function () {
                            if (ticked) {
                                $(this).show();
                                if (chkBoxId == "Sessile_CheckBox") {
                                    selectedPolypType = "sessile";
                                    $find("PedunculatedPolyps_CheckBox").set_checked(false);
                                    $find("PseudoPolyps_CheckBox").set_checked(false);
                                }
                                else if (chkBoxId == "PedunculatedPolyps_CheckBox") {
                                    selectedPolypType = "pedunculated";
                                    $find("Sessile_CheckBox").set_checked(false);
                                    $find("PseudoPolyps_CheckBox").set_checked(false);
                                }
                                else if (chkBoxId == "PseudoPolyps_CheckBox") {
                                    selectedPolypType = "pseudo";
                                    $find("Sessile_CheckBox").set_checked(false);
                                    $find("PedunculatedPolyps_CheckBox").set_checked(false);
                                }
                            }
                            else {
                                $(this).hide();
                                ClearControls($(this));
                            }
                        });

                    if (chkBoxId = "Tumour_CheckBox") { displayTumourDetails(); }

                    if (ticked) {
                        $find("NoneCheckBox").set_checked(false);
                        $('#LesionsSpotsTattooedFieldset').show();
                    }
                    else {
                        //Check if any other checkboxes are ticked. If not, hide NED Fieldset
                        var anyChecked = false;
                        var allRadControls = $telerik.radControls;
                        for (var i = 0; i < allRadControls.length; i++) {
                            var element = allRadControls[i];
                            var elemId = element.get_element().id;
                            if ((elemId != "NoneCheckBox") && elemId.indexOf("_CheckBox") > 0) {
                                if (element.get_checked()) {
                                    anyChecked = true;
                                    return;
                                }
                            }
                        }

                        if (!anyChecked) {
                            $('#LesionsSpotsTattooedFieldset').hide();
                        }
                    }
                }
            }

            function ToggleNoneCheckBox(sender, args) {
                //check if none is checked, if so hide lesions fieldset
                checkAllRadControls(args.get_checked());
            }

            function checkAllRadControls(noneChecked) {
                if (!noneChecked) { return; }

                var allRadControls = $telerik.radControls;
                for (var i = 0; i < allRadControls.length; i++) {

                    var element = allRadControls[i];
                    if (Telerik.Web.UI.RadButton && Telerik.Web.UI.RadButton.isInstanceOfType(element)) {
                        var elemId = element.get_element().id;
                        if ((elemId != "NoneCheckBox") && elemId.indexOf("_CheckBox") > 0) {
                            element.set_checked(false);
                            $('#LesionsSpotsTattooedFieldset').hide();
                        }
                    }
                }
            }

            // (AS: 7th/Jan/2020) bug fix for "Number retrieved" increasing "Number to labs"                                
            function SaveCheck() {
                //var numberToLabsSessile = $('#SessileToLabsNumericTextBox').val();
                //var numberToLabsOriginalSessile = $('#NumberToLabsTextBoxHiddenSessile').val();

                //var numberToLabsPedunculated = $('#PedunculatedToLabsNumericTextBox').val();
                //var numberToLabsOriginalPedunculated = $('#NumberToLabsTextBoxHiddenPedunculated').val();

                //var numberToLabsPseudo = $('#PseudoToLabsNumericTextBox').val();
                //var numberToLabsOriginalPseudo = $('#NumberToLabsTextBoxHiddenPseudo').val();

                //// if the new number of specimens sent to lab is zero and
                //// original value of specimens sent to lab was greater than
                //// zero, then display message.
                //if ((numberToLabsSessile == 0 && numberToLabsOriginalSessile > 0) ||
                //    (numberToLabsPedunculated == 0 && numberToLabsOriginalPedunculated > 0) ||
                //    (numberToLabsPseudo == 0 && numberToLabsOriginalPseudo > 0)) {
                //    alert("The number to Labs has changed, please check specimens taken.");
                //}

                //// update value of original value to new value
                //$('#NumberToLabsTextBoxHiddenSessile').val(numberToLabsSessile);
                //$('#NumberToLabsTextBoxHiddenPedunculated').val(numberToLabsPedunculated);
                //$('#NumberToLabsTextBoxHiddenPseudo').val(numberToLabsPseudo);
            }

            function CloseWindow() {
                var oManager = GetRadWindowManager();
                //Call GetActiveWindow to get the active window 
                var oActive = oManager.getActiveWindow();
                if (oActive == null) { window.parent.CloseWindow(); } else { oActive.close(null); return false; }
                // return false;
            }

            function showModalSessileParisClassification() {
                var oWnd = $find("<%=SessileParisClassificationPopup.ClientID%>");
                oWnd.show();
            }

            function showModalSessilePitPatterns() {
                var oWnd = $find("<%=SessilePitPatternsPopup.ClientID%>");
                oWnd.show();
            }

            function showModalPedunculatedParisClassification() {
                var oWnd = $find("<%=PedunculatedParisClassificationPopUp.ClientID%>");
                oWnd.show();
            }

            function showModalPedunculatedPitPatterns() {
                var oWnd = $find("<%=PedunculatedPitPatternsPopup.ClientID%>");
                oWnd.show();
            }


            function QtyChanged(diag) {
                if (diag == 'Pseudo') {
                    if ($find("PseudoPolypsQtyNumericTextBox").get_value() != "") {
                        $find("PseudoMultipleCheckBox").set_checked(false);
                    }
                }
            }

            function MultipleChecked(sender, args) {
                if (sender.get_id() == 'PseudoMultipleCheckBox') {
                    if (args.get_checked()) {
                        $find("PseudoPolypsQtyNumericTextBox").set_value("");
                    }
                }
            }

            function displayTumourDetails() {
                var rblSelectedValue = $('#TumourRadioButtonList input:checked').val();
                var tumourChk = $find("Tumour_CheckBox").get_checked();
                if (rblSelectedValue > 0 && tumourChk) {
                    $("#trTumourDetails").show();
                } else {
                    $("#trTumourDetails").hide();
                }
            }

            function displayPolypTattooDetails() {
                var rblSelectedValue = $('#PolypTattooedRadioButtonList input:checked').val();
                if (rblSelectedValue == '1') {
                    $('#trTattooMarkingDetails').show();
                    $('#<%=trTattooedBy.ClientID%>').show();
                }
                else {
                    $('#trTattooMarkingDetails').hide();
                    $('#<%=trTattooedBy.ClientID%>').hide();
                }
            }
        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="LesionsRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="PedunculatedPolyps_CheckBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SessileParisClassificationPopup" />
                        <telerik:AjaxUpdatedControl ControlID="SessilePitPatternsPopup" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="Sessile_CheckBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="PedunculatedParisClassificationPopUp" />
                        <telerik:AjaxUpdatedControl ControlID="PedunculatedPitPatternsPopup" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Lesions</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y">
                <div id="ContentDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">
                            <telerik:RadButton ID="NoneCheckBox" runat="server" Text="None" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" Skin="Web20" OnClientCheckedChanged="ToggleNoneCheckBox" Font-Bold="true"></telerik:RadButton>
                            <%--(AS: 7th/Jan/2020) bug fix for "Number retrieved" increasing "Number to labs" --%>
                            <asp:HiddenField ID="NumberToLabsTextBoxHiddenSessile" runat="server" ClientIDMode="Static" />
                            <asp:HiddenField ID="NumberToLabsTextBoxHiddenPedunculated" runat="server" ClientIDMode="Static" />
                            <asp:HiddenField ID="NumberToLabsTextBoxHiddenPseudo" runat="server" ClientIDMode="Static" />
                            <br />
                            <br />

                            <table id="LesionsTable" cellpadding="3" cellspacing="3" class="rgview" style="width: 500px; table-layout: fixed;">
                                <thead>
                                    <tr>
                                        <th width="130px" height="30px" class="rgHeader" style="text-align: left;"></th>
                                        <th width="70px" class="rgHeader">Quantity</th>
                                        <th width="70px" class="rgHeader">Size of
                                            <br />
                                            largest (mm)</th>
                                        <th width="70px" class="rgHeader"></th>
                                        <th width="70px" class="rgHeader"></th>
                                        <th width="70px" class="rgHeader"></th>
                                        <th width="70px" class="rgHeader"></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td valign="top" style="padding: 0px; height: 40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td width="130px" style="border: none;">
                                                        <telerik:RadButton ID="Sessile_CheckBox" data-polyptype="sessile" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Gray" Text="Sessile Polyps" Skin="Web20" OnClientCheckedChanged="ToggleTRs" OnClick="ClearState"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="6" style="padding: 0px;">
                                            <table style="width: 100%;" class="tableWithNoBorders" id="SessilePolypsTable">
                                                <tr>
                                                    <td class="rgCell" width="70px">
                                                        <telerik:RadNumericTextBox ID="SessileQtyNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText" CssClass="polyp-qty"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" style="text-align: left;">
                                                        <telerik:RadButton ID="SessileEnterDetailsRadButton" runat="server" Text="Size and retrieval details..." Skin="Windows7" CssClass="poly-details-btn" AutoPostBack="false" />
                                                    </td>
                                                    <td colspan="2" align="right">
                                                        <telerik:RadButton ID="SessileParisShowButton" Visible="false" runat="server" Text="Paris classification..." Skin="Windows7" OnClick="ShowRadWindow" />

                                                        <telerik:RadButton ID="SessilePitShowButton" Visible="false" runat="server" Text="Pit patterns..." Skin="Windows7" OnClick="ShowRadWindow" />
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="SessileLargestNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="SessileExcisedNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="SessileRetrievedNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="SessileSuccessfulNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="SessileToLabsNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                </tr>
                                                <tr runat="server" visible="false">
                                                    <td align="center">Removal
                                                    </td>
                                                    <td colspan="2">
                                                        <telerik:RadComboBox ID="Sessile_Removal_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                    <td colspan="2">
                                                        <telerik:RadComboBox ID="Sessile_Removal_Method_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td align="center" runat="server" visible="false">
                                                        <telerik:RadButton ID="SessileProbablyCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Probably" Skin="Web20"></telerik:RadButton>
                                                    </td>
                                                    <td colspan="2" runat="server" visible="false">
                                                        <telerik:RadComboBox ID="Sessile_Type_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>

                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top" style="padding: 0px; height: 40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="PedunculatedPolyps_CheckBox" data-polyptype="pedunculated" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Gray" Text="Pedunculated Polyps" Skin="Web20" OnClientCheckedChanged="ToggleTRs" OnClick="ClearState"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="6" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="PedunculatedPolypsTable">
                                                <tr>
                                                    <td class="rgCell" width="70px">
                                                        <telerik:RadNumericTextBox ID="PedunculatedPolypsQtyNumericTextBox" runat="server" CssClass="polyp-qty" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" style="text-align: left;">
                                                        <telerik:RadButton ID="PedunculatedEnterDetailsRadButton" runat="server" Text="Size and retrieval details..." Skin="Windows7" CssClass="poly-details-btn" AutoPostBack="false" />
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="PedunculatedLargestNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="PedunculatedExcisedNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="PedunculatedRetrievedNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="PedunculatedSuccessfulNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="PedunculatedToLabsNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                </tr>
                                                <tr runat="server" visible="false">
                                                    <td align="center">Removal
                                                    </td>
                                                    <td colspan="2">
                                                        <telerik:RadComboBox ID="Pedunculated_Removal_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                    <td colspan="2">
                                                        <telerik:RadComboBox ID="Pedunculated_Removal_Method_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                                <tr runat="server" visible="false">
                                                    <td align="center">
                                                        <telerik:RadButton ID="PedunculatedProbablyCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Probably" Skin="Web20"></telerik:RadButton>
                                                    </td>
                                                    <td colspan="2">
                                                        <telerik:RadComboBox ID="Pedunculated_Type_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                    <td colspan="3" align="right">
                                                        <telerik:RadButton ID="PedunculatedParisShowButton" runat="server" Text="Paris classification..." Skin="Windows7" OnClick="ShowRadWindow" />

                                                        <telerik:RadButton ID="PedunculatedPitShowButton" runat="server" Text="Pit patterns..." Skin="Windows7" OnClick="ShowRadWindow" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top" style="padding: 0px; height: 40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="PseudoPolyps_CheckBox" data-polyptype="pseudo" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Gray" Text="Pseudo Polyps" Skin="Web20" OnClientCheckedChanged="ToggleTRs" AutoPostBack="false"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="6" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="PseudoPolypsTable">
                                                <tr>
                                                    <td class="rgCell" width="70px">
                                                        <telerik:RadNumericTextBox ID="PseudoPolypsQtyNumericTextBox" runat="server" CssClass="polyp-qty" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" style="text-align: left;">
                                                        <telerik:RadButton ID="PseudoEnterDetailsRadButton" runat="server" Text="Size and retrieval details..." Skin="Windows7" CssClass="poly-details-btn" AutoPostBack="false" />
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="PseudoLargestNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="PseudoExcisedNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="PseudoRetrievedNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="PseudoSuccessfulNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px" runat="server" visible="false">
                                                        <telerik:RadNumericTextBox ID="PseudoToLabsNumericTextBox" runat="server" ClientEvents-OnValueChanged="ChangeText"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                </tr>
                                                <tr runat="server" visible="false">
                                                    <td align="center">
                                                        <telerik:RadButton ID="PseudoMultipleCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Multiple" Skin="Web20" OnClientCheckedChanged="MultipleChecked"></telerik:RadButton>
                                                    </td>
                                                    <td></td>
                                                    <td>
                                                        <telerik:RadButton ID="PseudoInflamCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="inflammatory" Skin="Web20"></telerik:RadButton>
                                                    </td>
                                                    <td colspan="2">
                                                        <telerik:RadButton ID="PseudoPostInflamCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="post-inflammatory" Skin="Web20"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                                <tr runat="server" visible="false">
                                                    <td align="center">Removal
                                                    </td>
                                                    <td colspan="2">
                                                        <telerik:RadComboBox ID="Pseudo_Removal_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                    <td colspan="2">
                                                        <telerik:RadComboBox ID="Pseudo_Removal_Method_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                    <%--
                                    <tr>
                                        <td valign="top" style="padding: 0px;height:40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="Submucosal_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton"  ForeColor="Gray" Text="Tumour: submucosal" Skin="Web20" OnClientCheckedChanged="ToggleTRs" AutoPostBack="false"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="5" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="SubmucosalTable" cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="SubmucosalQtyNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="SubmucosalLargestNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td align="right">
                                                        <telerik:RadButton ID="SubmucosalProbablyCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Probably" Skin="Web20"></telerik:RadButton>
                                                    </td>
                                                    <td align="left">
                                                        <telerik:RadComboBox ID="Submucosal_Type_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top" style="padding: 0px;height:40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="Villous_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Tumour: villous" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="5" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="VillousTable">
                                                <tr>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="VillousQtyNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="VillousLargestNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td align="right">
                                                        <telerik:RadButton ID="VillousProbablyCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Probably" Skin="Web20"></telerik:RadButton>
                                                    </td>
                                                    <td align="left">
                                                        <telerik:RadComboBox ID="Villous_Type_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top" style="padding: 0px;height:40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="Ulcerative_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Tumour: ulcerative" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="5" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="UlcerativeTable">
                                                <tr>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="UlcerativeQtyNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="UlcerativeLargestNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td align="right">
                                                        <telerik:RadButton ID="UlcerativeProbablyCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Probably" Skin="Web20"></telerik:RadButton>
                                                    </td>
                                                    <td align="left">
                                                        <telerik:RadComboBox ID="Ulcerative_Type_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top" style="padding: 0px;height:40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="Stricturing_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Tumour: stricturing" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="5" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="StricturingTable">
                                                <tr>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="StricturingQtyNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="StricturingLargestNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td align="right">
                                                        <telerik:RadButton ID="StricturingProbablyCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Probably" Skin="Web20"></telerik:RadButton>
                                                    </td>
                                                    <td align="left">
                                                        <telerik:RadComboBox ID="Stricturing_Type_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top" style="padding: 0px;height:40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="Polypoidal_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Tumour: polypoidal" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="5" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="PolypoidalTable">
                                                <tr>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="PolypoidalQtyNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="PolypoidalLargestNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td align="right">
                                                        <telerik:RadButton ID="PolypoidalProbablyCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Probably" Skin="Web20"></telerik:RadButton>
                                                    </td>
                                                    <td align="left">
                                                        <telerik:RadComboBox ID="Polypoidal_Type_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>   --%>
                                    <tr>
                                        <td style="padding: 0px; height: 40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="Granuloma_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Suture granuloma" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="6" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="GranulomaTable">
                                                <tr>
                                                    <td class="rgCell" width="70px">
                                                        <telerik:RadNumericTextBox ID="GranulomaQtyNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px">
                                                        <telerik:RadNumericTextBox ID="GranulomaLargestNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td align="right"></td>
                                                    <td align="left"></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 0px; height: 40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="Dysplastic_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Dysplastic lesion" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="6" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="DysplasticTable">
                                                <tr>
                                                    <td class="rgCell" width="70px">
                                                        <telerik:RadNumericTextBox ID="DysplasticQtyNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="70px">
                                                        <telerik:RadNumericTextBox ID="DysplasticLargestNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td></td>
                                                    <td></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 0px; height: 40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="Pneumatosis_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Pneumatosis coli" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="6" style="padding: 0px;"></td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 0px; height: 40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="FundicGlandPolyp_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Fundic Gland Polyp" Skin="Web20" OnClientCheckedChanged="ToggleTRs"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="6" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="FundicGlandPolypTable">
                                                <tr>
                                                    <td class="rgCell" width="70px">
                                                        <telerik:RadNumericTextBox ID="FundicGlandPolypQtyNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="80px">
                                                        <telerik:RadNumericTextBox ID="FundicGlandPolypLargestNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step=".50"
                                                            Width="45px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="2" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td align="right"></td>
                                                    <td align="left"></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 0px; height: 40px;">
                                            <table style="width: 100%;" id="TumourTable">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="Tumour_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Gray" Text="Tumour" Skin="Web20" OnClientCheckedChanged="ToggleTRs" AutoPostBack="false"></telerik:RadButton>
                                                        <img src="../../../../Images/NEDJAG/JAGNED.png" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="6" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="SubTumourTable">
                                                <tr>
                                                    <td width="85px" colspan="4" style="vertical-align: top;">
                                                        <asp:RadioButtonList ID="TumourRadioButtonList" runat="server"
                                                            CellSpacing="25" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl">
                                                            <asp:ListItem Value="1" Text="Submucosal"></asp:ListItem>
                                                            <asp:ListItem Value="2" Text="Villous"></asp:ListItem>
                                                            <asp:ListItem Value="3" Text="Ulcerative"></asp:ListItem>
                                                            <asp:ListItem Value="4" Text="Stricturing"></asp:ListItem>
                                                            <asp:ListItem Value="5" Text="Polypoidal"></asp:ListItem>
                                                        </asp:RadioButtonList>

                                                    </td>
                                                </tr>
                                                <tr id="trTumourDetails">
                                                    <td class="rgCell" width="70px">
                                                        <telerik:RadNumericTextBox ID="TumourQtyNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="80px">
                                                        <telerik:RadNumericTextBox ID="TumourLargestNumericTextBox" runat="server"
                                                            
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td align="right">
                                                        <%--<telerik:RadButton ID="TumourProbablyCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" Text="Probably" Skin="Web20"></telerik:RadButton>--%>
                                                        <asp:CheckBox ID="TumourProbablyCheckBox" runat="server" Text="Probably" TextAlign="Right" SkinID="Metro" />
                                                    </td>
                                                    <td align="left">
                                                        <telerik:RadComboBox ID="Tumour_Type_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>

                            <fieldset id="LesionsSpotsTattooedFieldset" runat="server">
                                <legend>National Data Set Requirement
                                    <img src="../../../../Images/NEDJAG/NED.png" /></legend>
                                <table width="100%" style="padding: 0px;">
                                    <tr>
                                        <td style="border: none; width: 35%;">Was the polyp/cancer tattooed?</td>
                                        <td style="border: none;">
                                            <asp:RadioButtonList ID="PolypTattooedRadioButtonList" runat="server"
                                                CellSpacing="25" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl">
                                                <asp:ListItem Value="0">No</asp:ListItem>
                                                <asp:ListItem Value="1">Yes</asp:ListItem>
                                                <asp:ListItem Value="2">Previously tattooed</asp:ListItem>
                                            </asp:RadioButtonList>
                                        </td>

                                    </tr>
                                    <tr id="trTattooMarkingDetails">
                                        <td style="border: none; width: 30%;">Using&nbsp;
                                            <telerik:RadComboBox ID="Tattoo_Marking_ComboBox" runat="server" Skin="Windows7"></telerik:RadComboBox>
                                        </td>
                                        <td style="border: none;">Total volume used (ml)&nbsp;
                                            <telerik:RadNumericTextBox ID="TattooedQtyNumericTextBox" runat="server"
                                                
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="35px"
                                                MinValue="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                        <%--</td>
                                        <td style="border: none; width: 350px;">--%>
                                            <br />
                                            <span>Location:</span>
                                            <span>
                                                <asp:CheckBox ID="chkTattooLocationTop" runat="server" Text="Top" TabIndex="78" />&nbsp;
                                            </span>
                                            <span>
                                                <asp:CheckBox ID="chkTattooLocationLeft" runat="server" Text="Left" TabIndex="78" />&nbsp;
                                            </span>
                                            <span>
                                                <asp:CheckBox ID="chkTattooLocationRight" runat="server" Text="Right" TabIndex="78" />&nbsp;
                                            </span>
                                            <span>
                                                <asp:CheckBox ID="chkTattooLocationBottom" runat="server" Text="Bottom" TabIndex="78" />&nbsp;
                                            </span>
                                        </td>
                                    </tr>
                                    <tr id="trTattooedBy" runat="server" visible="false">
                                        <td style="border: none;" colspan="2">Marking carried out by:&nbsp;
                                            <asp:RadioButtonList ID="TattooedByRadioButtonList" runat="server"
                                                CellSpacing="25" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl" />
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                    </div>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" OnClientClicked="SaveCheck" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        <telerik:RadWindowManager ID="RadMan" runat="server" Modal="true" Animation="Fade" KeepInScreenBounds="true" Behaviors="Close" Skin="Metro" VisibleStatusbar="false" VisibleOnPageLoad="false">
            <Windows>
                <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new Item"
                    KeepInScreenBounds="true" Width="400px" Height="150px" OnClientClose="AddNewItemWindowClientClose">
                    <ContentTemplate>
                        <table cellspacing="3" cellpadding="3" style="width: 100%">
                            <tr>
                                <td>
                                    <br />
                                    <div class="left">
                                        <telerik:RadTextBox ID="AddNewItemRadTextBox" runat="Server" Width="250px" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="buttonsdiv" style="height: 10px; padding-top: 16px;">
                                        <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Add" Skin="WebBlue" AutoPostBack="false" OnClientClicked="AddNewItem" ButtonType="SkinnedButton" />
                                        &nbsp;&nbsp;
                                        <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="CancelAddNewItem" ButtonType="SkinnedButton" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="SessileParisClassificationPopup" runat="server" Width="652" Height="450" ReloadOnShow="true" ShowContentDuringLoad="false" OnUnload="WinUnload">
                    <ContentTemplate>
                        <div class="labelHeaderPopup riLabel">
                            Paris Classification - The Morphological Appearance of a Lesion
                        </div>
                        <table id="SessileParisClassificationTable" class="tablePopup rgview">
                            <tr>
                                <td>Protruded type
                                </td>
                                <td>
                                    <telerik:RadButton ID="SessileLSRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20" />
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
                                    <telerik:RadButton ID="SessileLLARadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                    </telerik:RadButton>
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="imgLogo" runat="server" ImageUrl="~/Images/ParisClassification/ParisClassification_FlatElevated.png" />
                                </td>
                                <td>IIa - flat elevated</td>
                            </tr>
                            <tr>
                                <td>
                                    <telerik:RadButton ID="SessileLLALLCRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                    </telerik:RadButton>
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
                                    <telerik:RadButton ID="SessileLLBRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                    </telerik:RadButton>
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
                                    <telerik:RadButton ID="SessileLLCRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                    </telerik:RadButton>
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage3" ImageUrl="~/Images/ParisClassification/ParisClassification_SlightlyDep.png" runat="server" />
                                </td>
                                <td>IIc - slightly depressed</td>
                            </tr>
                            <tr>
                                <td>
                                    <telerik:RadButton ID="SessileLLCLLARadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                    </telerik:RadButton>
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage4" ImageUrl="~/Images/ParisClassification/ParisClassification_SlightlyDep2.png" runat="server" />
                                </td>
                                <td>IIc + IIa slightly depressed</td>
                            </tr>
                        </table>
                        <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                            <telerik:RadButton ID="SessileParisClassificationRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" />
                            <telerik:RadButton ID="RadButton2" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="CloseWindow" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="PedunculatedParisClassificationPopUp" runat="server" Width="652" Height="250" ReloadOnShow="true" ShowContentDuringLoad="false" OnUnload="WinUnload">
                    <ContentTemplate>
                        <div class="labelHeaderPopup riLabel">
                            Paris Classification - The Morphological Appearance of a Lesion
                        </div>
                        <table id="PedunculatedParisClassificationTable" class="tablePopup rgview">
                            <tr>
                                <td rowspan="2">Protruded type
                                </td>
                                <td>
                                    <telerik:RadButton ID="ProtrudedRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                    </telerik:RadButton>
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage11" ImageUrl="~/Images/ParisClassification/ParisClassification_Pedunculated.png" runat="server" />
                                </td>
                                <td>Ip - Pedunculated</td>
                            </tr>
                            <tr>
                                <td>
                                    <telerik:RadButton ID="PedunculatedRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                    </telerik:RadButton>
                                </td>
                                <td>
                                    <telerik:RadBinaryImage ID="RadBinaryImage12" runat="server" ImageUrl="~/Images/ParisClassification/ParisClassification_SubPedunculated.png" />
                                </td>
                                <td>Isp - sub pedunculated</td>
                            </tr>
                        </table>
                        <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                            <telerik:RadButton ID="PedunculatedParisClassificationRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" />
                            <telerik:RadButton ID="RadButton4" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="CloseWindow" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="SessilePitPatternsPopup" runat="server" Width="652" Height="510" ReloadOnShow="true" ShowContentDuringLoad="false" OnUnload="WinUnload">
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
                                        <telerik:RadButton ID="SessileNormalRoundPitsRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                        </telerik:RadButton>
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
                                        <telerik:RadButton ID="SessileStellarRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                        </telerik:RadButton>
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
                                        <telerik:RadButton ID="SessileTubularRoundPitsRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                        </telerik:RadButton>
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
                                        <telerik:RadButton ID="SessileTubularRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                        </telerik:RadButton>
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
                                        <telerik:RadButton ID="SessileSulcusRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                        </telerik:RadButton>
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
                                        <telerik:RadButton ID="SessileLossRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                        </telerik:RadButton>
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
                            <telerik:RadButton ID="RadButton6" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="CloseWindow" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="PedunculatedPitPatternsPopup" runat="server" Width="652" Height="510" ReloadOnShow="true" ShowContentDuringLoad="false" OnUnload="WinUnload">
                    <ContentTemplate>
                        <div class="labelHeaderPopup riLabel">
                            Pit Patterns - The Surface Appearance of a Lesion
                        </div>
                        <table class="tablePopup rgview" id="PedunculatedPitPatternsTable">
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
                                        <telerik:RadButton ID="PedunculatedNormalRoundPitsRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                        </telerik:RadButton>
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
                                        <telerik:RadButton ID="PedunculatedStellarRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                        </telerik:RadButton>
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
                                        <telerik:RadButton ID="PedunculatedTubularRoundPitsRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                        </telerik:RadButton>
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
                                        <telerik:RadButton ID="PedunculatedTubularRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                        </telerik:RadButton>
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
                                        <telerik:RadButton ID="PedunculatedSulcusRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                        </telerik:RadButton>
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
                                        <telerik:RadButton ID="PedunculatedLossRadioButton" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="PitTypeRadioGroup" AutoPostBack="false" Skin="Web20">
                                        </telerik:RadButton>
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
                            <telerik:RadButton ID="RadButton8" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="CloseWindow" />
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="PolypDetailsRadWindow" runat="server" ReloadOnShow="true"  KeepInScreenBounds="true" Width="652" Height="600px" AutoSize="false" Title="Polyp details" VisibleStatusbar="false" Modal="True" Skin="Metro" Behaviors="None">
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
