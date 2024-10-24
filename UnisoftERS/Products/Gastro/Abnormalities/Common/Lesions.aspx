<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Lesions.aspx.vb" Inherits="UnisoftERS.Products_Gastro_Abnormalities_Common_Lesions" %>

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

        #RAD_SPLITTER_PANE_CONTENT_ControlsRadPane {
            height: calc(90vh - 25px) !important;
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
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest('save');
            }

            var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
            var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";

            $(window).on('load', function () {
                checkAllRadControls($find("NoneCheckBox").get_checked());
                $("input[id*='_CheckBox_ClientState']").each(function () {
                    ToggleTDs($(this)[0].id.replace("_ClientState", ""));
                });
                displayTumourDetails();
            });

            $(document).ready(function () {


                $('#TumourRadioButtonList input').change(function () {
                    displayTumourDetails();
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

                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            });
            function ClearControls(tableCell) {
                tableCell.find("input[id*='CheckBox']").each(function () {
                    var elemId = $(this)[0].id.replace("_ClientState", "");
                    var chkBx = $find(elemId);
                    if (chkBx != null) {
                        chkBx.set_checked(false);
                    }
                });
                tableCell.find("input:radio:checked").prop('checked', false);
                tableCell.find("input:checkbox:checked").prop('checked', false);
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


            function ToggleTDs(sender, args) {
                $find("NoneCheckBox").set_checked(false); //changed by mostafiz issue 3647
                var chkBoxId = (args == undefined) ? sender : sender.get_element().id;
                var ticked = (args == undefined) ? $find(sender).get_checked() : args.get_checked();

                if (chkBoxId != "NoneCheckBox") {
                    if (ticked == undefined) {
                        ticked = $find(chkBoxId).get_checked();
                    }

                    //var tableId = chkBoxId.replace("_CheckBox", "Table");
                    //var table = $telerik.$("[id$='" + tableId + "']");

                    $("#" + chkBoxId).parents("td").eq(1)
                        .next('td').children('table').each(function () {
                            if (ticked) {
                                $(this).show();
                            }
                            else {
                                $(this).hide();
                            }
                        });
                    if (chkBoxId == "PreviousESDScar_CheckBox") {
                        if (!ticked && $('.polyp-details-table').length == 0) {
                            localStorage.setItem('valueChanged', 'false');
                        }
                        else localStorage.setItem('valueChanged', 'true');
                    }
                }
            }
            //changed by mostafiz issue 3900

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
                        }
                    }
                }
                $find("NoneCheckBox").set_checked(true);
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


            //function QtyChanged(diag) {
            //    if (diag == 'Pseudo') {
            //        if ($find("PseudoPolypsQtyNumericTextBox").get_value() != "") {
            //            $find("PseudoMultipleCheckBox").set_checked(false);
            //        }
            //    }
            //}

            //function MultipleChecked(sender, args) {
            //    if (sender.get_id() == 'PseudoMultipleCheckBox') {
            //        if (args.get_checked()) {
            //            $find("PseudoPolypsQtyNumericTextBox").set_value("");
            //        }
            //    }
            //}

            function displayTumourDetails() {
                //var rblSelectedValue = $('#TumourRadioButtonList input:checked').val();
                //var tumourChk = $find("Tumour_CheckBox").get_checked();
                //if (rblSelectedValue > 0 && tumourChk) {
                //    $("#trTumourDetails").show();
                //} else {
                //    $("#trTumourDetails").hide();
                //}
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
                <telerik:AjaxSetting AjaxControlID="SaveButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
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
        <%--<telerik:RadToolTipManager runat="server" AnimationDuration="300"
            ID="RadToolTipManager1" Width="480px" Height="227px" RelativeTo="Element"
            Animation="Fade" Position="BottomCenter">
        </telerik:RadToolTipManager>--%>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="abnorHeader">Lesions</div>
                <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
                    <telerik:RadPane ID="ControlsRadPane" runat="server" Width="95%">
                        <div id="ContentDiv">
                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <%--(AS: 7th/Jan/2020) bug fix for "Number retrieved" increasing "Number to labs" --%>
                                    <asp:HiddenField ID="NumberToLabsTextBoxHiddenSessile" runat="server" ClientIDMode="Static" />
                                    <asp:HiddenField ID="NumberToLabsTextBoxHiddenPedunculated" runat="server" ClientIDMode="Static" />
                                    <asp:HiddenField ID="NumberToLabsTextBoxHiddenPseudo" runat="server" ClientIDMode="Static" />



                                    <table id="LesionsTable" class="rgview" style="width: 99%; table-layout: fixed;" cellpadding="0" cellspacing="0">
                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;" colspan="1">
                                                    <telerik:RadButton ID="NoneCheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Gray" Text="None" Skin="Web20" OnClientCheckedChanged="ToggleNoneCheckBox" OnCheckedChanged="NoneCheckBox_CheckedChanged"></telerik:RadButton>

                                                </th>
                                                <th colspan="1" >
                                                    <telerik:RadButton ID="PreviousESDScar_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" ForeColor="Gray" Text="Previous ESD scar" Skin="Web20" OnClientCheckedChanged="ToggleTDs" OnCheckedChanged="PreviousESDScar_CheckBox_CheckedChanged"></telerik:RadButton>
                                                </th>
                                                <th colspan="1" align="right">
                                                    <telerik:RadButton ID="EnterDetailsRadButton" runat="server" Text="Add Polyps" Skin="Windows7" CssClass="poly-details-btn" OnClick="EnterDetailsRadButton_Click" />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>


                                            <tr id="PreviousESDScarTR" runat="server">
                                                <td style="padding: 0px; height: 40px; vertical-align: top;" colspan="3">
                                                    <div style="height: calc(75vh - 25px) !important; overflow: auto;">
                                                        <asp:Repeater ID="PolypDetailsRepeater" runat="server" OnItemCommand="PolypDetailsRepeater_ItemCommand" OnItemDataBound="PolypDetailsRepeater_ItemDataBound">
                                                           
                                                            <ItemTemplate>
                                                                <asp:HiddenField ID="PolypIdHiddenValue" runat="server" Value='<%# Eval("PolypId") %>' />
                                                                <table style="border-bottom: 1px solid #c2d2e2; padding: 3px; width: 100%;" class="polyp-details-table">
                                                                    <tr>
                                                                        <td class="rgCell" style="vertical-align: top;"><strong>
                                                                            <asp:Label ID="lblPolyp" runat="server" Text='<%#Eval("PolypType") %>' /></strong>
                                                                            <td class="rgCell" style="vertical-align: top;">(<strong>Size:&nbsp;<asp:Label ID="lblSize" runat="server" Text='<%#Eval("Size") %>' />mm</strong>)
                                                                            </td>
                                                                            <td class="rgCell">
                                                                                <span>Excised:</span><asp:CheckBox ID="ExcisedCheckBox" runat="server" Enabled="false" CssClass="polypectomy-result" />
                                                                            </td>
                                                                            <td class="rgCell">
                                                                                <span>Retrieved:</span><asp:CheckBox ID="RetrievedCheckBox" runat="server" Enabled="false" CssClass="polypectomy-result" />
                                                                            </td>
                                                                            <td class="rgCell">
                                                                                <span>Sucessful:</span><asp:CheckBox ID="SuccessfulCheckBox" runat="server" Enabled="false" CssClass="labs-cb" />
                                                                            </td>
                                                                            <td class="rgCell" style="display: none;">
                                                                                <span>To labs:</span><asp:CheckBox ID="ToLabsCheckBox" runat="server" Enabled="false" CssClass="" />
                                                                            </td>
                                                                            <td class="rgCell">
                                                                                <asp:LinkButton ID="RemoveEntryLinkButton" runat="server" Text="remove" CommandArgument='<%# Eval("PolypId") %>' CommandName="remove" OnClientClick="AddPolypDetailsRadButton_ClientClick(this)" />
                                                                            </td>
                                                                            <td class="rgCell">
                                                                                <asp:LinkButton ID="EditlinkButton" runat="server" Text="Edit" CommandArgument='<%# Eval("PolypId") %>' CommandName="Edit" />
                                                                            </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="5">
                                                                            <div>
                                                                                <span class="view-mode"><%#IIf(CBool(Eval("Probably")), "Probably ", "") %></span>
                                                                                <asp:HiddenField ID="PolypProbablyHiddenField" runat="server" />
                                                                                <asp:CheckBox ID="Probably_CheckBox" runat="server" Text="Probably" TextAlign="Right" SkinID="Metro" CssClass="edit-mode" Style="display: none;" />

                                                                                <span class=" view-mode"><%#If(String.IsNullOrEmpty(Eval("TypeDescription")), "", Eval("TypeDescription") & ".") %></span>
                                                                                <asp:HiddenField ID="PolypTypeHiddenField" runat="server" />
                                                                                <telerik:RadComboBox ID="Type_ComboBox" runat="server" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" AppendDataBoundItems="true" CssClass="tumour-type-combo edit-mode" Style="display: none;">
                                                                                    <Items>
                                                                                        <telerik:RadComboBoxItem Text="" Value="0" />
                                                                                    </Items>
                                                                                </telerik:RadComboBox>

                                                                                <span class=" view-mode"><%#If(String.IsNullOrEmpty(Eval("RemovalDescription")), "", "Removed " & Eval("RemovalDescription") & ".") %></span>
                                                                                <asp:HiddenField ID="PolypRemovalHiddenField" runat="server" />
                                                                                <telerik:RadComboBox ID="Removal_ComboBox" runat="server" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" AppendDataBoundItems="true" CssClass="removal-combo edit-mode" Style="display: none;">
                                                                                    <Items>
                                                                                        <telerik:RadComboBoxItem Text="" Value="0" />
                                                                                    </Items>
                                                                                </telerik:RadComboBox>

                                                                                <span class=" view-mode"><%#If(String.IsNullOrEmpty(Eval("RemovalMethodDescription")), "", " by " & Eval("RemovalMethodDescription") + ".") %></span>
                                                                                <asp:HiddenField ID="PolypRemovalMethodHiddenField" runat="server" />
                                                                                <telerik:RadComboBox ID="Removal_Method_ComboBox" runat="server" Skin="Metro" Style="width: 70% !important; display: none;" DataTextField="Description" DataValueField="UniqueId" AppendDataBoundItems="true" CssClass="removal-type-combo edit-mode">
                                                                                    <Items>
                                                                                        <telerik:RadComboBoxItem Text="" Value="0" />
                                                                                    </Items>
                                                                                </telerik:RadComboBox>

                                                                                <span class="view-mode"><%# Eval("TattoDescription") %></span>
                                                                                <asp:HiddenField ID="PolypTattooedHiddenField" runat="server" />
                                                                                <asp:HiddenField ID="TattooLocationDistal" runat="server" Value='<%# Eval("TattooLocationDistal") %>' />
                                                                                <asp:HiddenField ID="TattooLocationProximal" runat="server" Value='<%# Eval("TattooLocationProximal") %>' />
                                                                                <asp:RadioButtonList ID="PolypTattooedRadioButtonList" runat="server"
                                                                                    CellSpacing="25" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl tattoo_marking_type edit-mode" DataTextField="Description" DataValueField="UniqueId" Style="display: none;" />

                                                                                <span class=" view-mode"><%#If(String.IsNullOrEmpty(Eval("TattooedMarkingTypeDescription")), "", " using " & Eval("TattooedMarkingTypeDescription") & ".") %></span>
                                                                                <asp:HiddenField ID="PolypMarkingHiddenField" runat="server" />
                                                                                <telerik:RadComboBox ID="Tattoo_Marking_ComboBox" runat="server" Skin="Metro" DataTextField="Description" DataValueField="UniqueId" AppendDataBoundItems="true" CssClass="edit-mode" Style="display: none;">
                                                                                    <Items>
                                                                                        <telerik:RadComboBoxItem Value="0" Text="" />
                                                                                    </Items>
                                                                                </telerik:RadComboBox>
                                                                                <asp:Label ID="polypMorphologyLabel" runat="server" />
                                                                                <ul id="PolypConditionUL" runat="server" class="polyp-conditions view-mode" />
                                                                                <asp:HiddenField ID="PolypConditionHiddenField" runat="server" />
                                                                                <asp:CheckBoxList ID="PolypConditionsCheckBoxList" runat="server" DataTextField="Description" DataValueField="UniqueId" RepeatColumns="4" CssClass="edit-mode" Style="display: none;" />

                                                                                <asp:HiddenField ID="SubmucosalLargestNumericTextBoxRPT" runat="server" Value='<%#If(String.IsNullOrEmpty(Eval("SubmucosalLargest")), 0, CInt(Eval("SubmucosalLargest"))) %>' />
                                                                                <asp:HiddenField ID="SubmucosalQtyNumericTextBoxRPT" runat="server" Value='<%#If(String.IsNullOrEmpty(Eval("SubmucosalQuantity")), 0, CInt(Eval("SubmucosalQuantity")))%>' />
                                                                                <asp:HiddenField ID="FocalLargestNumericTextBoxRPT" runat="server" Value='<%#If(String.IsNullOrEmpty(Eval("FocalLargest")), 0, CInt(Eval("FocalLargest")))%>' />
                                                                                <asp:HiddenField ID="FocalQtyNumericTextBoxRPT" runat="server" Value='<%#If(String.IsNullOrEmpty(Eval("FocalQuantity")), 0, CInt(Eval("FocalQuantity"))) %>' />
                                                                                <asp:HiddenField ID="FundicGlandPolypLargestNumericTextBoxRPT" runat="server" Value='<%#If(String.IsNullOrEmpty(Eval("FundicGlandPolypLargest")), 0, CDbl(Eval("FundicGlandPolypLargest")))%>' />
                                                                                <asp:HiddenField ID="FundicGlandPolypQtyNumericTextBoxRPT" runat="server" Value='<%#If(String.IsNullOrEmpty(Eval("FundicGlandPolypQuantity")), 0, CInt(Eval("FundicGlandPolypQuantity")))%>' />
                                                                                <asp:HiddenField ID="PolypTypeIdRPT" runat="server" Value='<%#If(String.IsNullOrEmpty(Eval("PolypTypeId")), 0, CInt(Eval("PolypTypeId")))%>' />
                                                                                <asp:HiddenField ID="polypTypeRPT" runat="server" Value='<%#Eval("polypType")%>' />
                                                                            </div>
                                                                        </td>
                                                                    </tr>
                                                                    <tr id="pseudoPolypTR" runat="server" visible="false">
                                                                        <td>
                                                                            <asp:CheckBox ID="InflamCheckBox" runat="server" Text="inflammatory" TextAlign="Right" SkinID="Metro" AutoPostBack="false" />
                                                                        </td>
                                                                        <td>
                                                                            <asp:CheckBox ID="PostInflamCheckBox" runat="server" Text="post-inflammatory" TextAlign="Right" SkinID="Metro" AutoPostBack="false" />
                                                                        </td>
                                                                        <td colspan="3"></td>
                                                                    </tr>
                                                                </table>
                                                            </ItemTemplate>
                                                            <FooterTemplate>
                                                            </FooterTemplate>
                                                        </asp:Repeater>
                                                    </div>
                                                </td>

                                            </tr>
                                        </tbody>
                                    </table>

                                    <%--
                                    <tr>
                                        <td valign="top" style="padding: 0px;height:40px;">
                                            <table style="width: 100%;">
                                                <tr>
                                                    <td style="border: none;">
                                                        <telerik:RadButton ID="Submucosal_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton"  ForeColor="Gray" Text="Tumour: submucosal" Skin="Web20" OnClientCheckedChanged="ToggleTDs" AutoPostBack="false"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="5" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="SubmucosalTable" cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="SubmucosalQtyNumericTextBox" runat="server"
                                                            ShowSpinButtons="true"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="50px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="SubmucosalLargestNumericTextBox" runat="server"
                                                            ShowSpinButtons="true"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="50px"
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
                                                        <telerik:RadButton ID="Villous_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Tumour: villous" Skin="Web20" OnClientCheckedChanged="ToggleTDs"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="5" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="VillousTable">
                                                <tr>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="VillousQtyNumericTextBox" runat="server"
                                                            ShowSpinButtons="true"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="50px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="VillousLargestNumericTextBox" runat="server"
                                                            ShowSpinButtons="true"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="50px"
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
                                                        <telerik:RadButton ID="Ulcerative_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Tumour: ulcerative" Skin="Web20" OnClientCheckedChanged="ToggleTDs"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="5" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="UlcerativeTable">
                                                <tr>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="UlcerativeQtyNumericTextBox" runat="server"
                                                            ShowSpinButtons="true"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="50px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="UlcerativeLargestNumericTextBox" runat="server"
                                                            ShowSpinButtons="true"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="50px"
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
                                                        <telerik:RadButton ID="Stricturing_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Tumour: stricturing" Skin="Web20" OnClientCheckedChanged="ToggleTDs"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="5" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="StricturingTable">
                                                <tr>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="StricturingQtyNumericTextBox" runat="server"
                                                            ShowSpinButtons="true"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="50px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="StricturingLargestNumericTextBox" runat="server"
                                                            ShowSpinButtons="true"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="50px"
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
                                                        <telerik:RadButton ID="Polypoidal_CheckBox" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" ForeColor="Gray" Text="Tumour: polypoidal" Skin="Web20" OnClientCheckedChanged="ToggleTDs"></telerik:RadButton>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="5" style="padding: 0px;">
                                            <table width="100%" class="tableWithNoBorders" id="PolypoidalTable">
                                                <tr>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="PolypoidalQtyNumericTextBox" runat="server"
                                                            ShowSpinButtons="true"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="50px"
                                                            MinValue="0">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                    <td class="rgCell" width="85px">
                                                        <telerik:RadNumericTextBox ID="PolypoidalLargestNumericTextBox" runat="server"
                                                            ShowSpinButtons="true"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="50px"
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
                                </div>
                            </div>

                        </div>
                    </telerik:RadPane>
                    <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                        <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px;">
                            <%--<telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" OnClientClicked="SaveCheck" Icon-PrimaryIconCssClass="telerikSaveButton" />
                            <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />--%>
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

                        <telerik:RadWindow ID="SessileParisClassificationPopup" runat="server" Width="652" Height="450" ReloadOnShow="true" ShowContentDuringLoad="false" OnUnload="WinUnload" >
                            <ContentTemplate>
                                <div class="labelHeaderPopup riLabel">
                                   Paris Classification - The Morphological Appearance of a Lesion
                                </div>
                                <table id="SessileParisClassificationTable" class="tablePopup rgview">
                                    <tr>
                                        <td>Protruded type
                                        </td>
                                        <td>
                                            <telerik:RadButton ID="SessileLSRadioButton" CssClass="sessile-paris-btn" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20" />
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
                                            <telerik:RadButton ID="SessileLLARadioButton" CssClass="sessile-paris-btn" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                            </telerik:RadButton>
                                        </td>
                                        <td>
                                            <telerik:RadBinaryImage ID="imgLogo" runat="server" ImageUrl="~/Images/ParisClassification/ParisClassification_FlatElevated.png" />
                                        </td>
                                        <td>IIa - flat elevated</td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <telerik:RadButton ID="SessileLLALLCRadioButton" CssClass="sessile-paris-btn" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
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
                                            <telerik:RadButton ID="SessileLLBRadioButton" CssClass="sessile-paris-btn" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
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
                                            <telerik:RadButton ID="SessileLLCRadioButton" CssClass="sessile-paris-btn" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                            </telerik:RadButton>
                                        </td>
                                        <td>
                                            <telerik:RadBinaryImage ID="RadBinaryImage3" ImageUrl="~/Images/ParisClassification/ParisClassification_SlightlyDep.png" runat="server" />
                                        </td>
                                        <td>IIc - slightly depressed</td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <telerik:RadButton ID="SessileLLCLLARadioButton" CssClass="sessile-paris-btn" runat="server" ToggleType="Radio" ButtonType="ToggleButton" GroupName="StandardButton" AutoPostBack="false" Skin="Web20">
                                            </telerik:RadButton>
                                        </td>
                                        <td>
                                            <telerik:RadBinaryImage ID="RadBinaryImage4" ImageUrl="~/Images/ParisClassification/ParisClassification_SlightlyDep2.png" runat="server" />
                                        </td>
                                        <td>IIc + IIa slightly depressed</td>
                                    </tr>
                                    <tr>
                                        <td>Lateral
                                <br />
                                            spreading tumor
                                        </td>
                                        <td>
                                            <asp:RadioButton ID="LSTGRadioButton" CssClass="sessile-paris-btn" runat="server" GroupName="StandardButton" SkinID="Web20" />
                                        </td>
                                        <td colspan="2">
                                            <div class="LSTTypeDiv" style="display: none;">
                                                Choose one:&nbsp;
                                          <telerik:RadComboBox ID="LSTTypesDropdown" runat="server" Skin="Metro">
                                              <Items>
                                                  <telerik:RadComboBoxItem Value="10" Text="LST-G" />
                                                  <telerik:RadComboBoxItem Value="11" Text="LST-NG" />
                                                  <telerik:RadComboBoxItem Value="12" Text="LST-D" />
                                                  <telerik:RadComboBoxItem Value="13" Text="LST-M" />
                                              </Items>
                                          </telerik:RadComboBox>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                                <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                                    <telerik:RadButton ID="SessileParisClassificationRadButton" runat="server" Text="OK" Skin="Web20" OnClick="GetValues" />
                                    <telerik:RadButton ID="RadButton2" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="CloseWindow" />
                                </div>
                            </ContentTemplate>
                        </telerik:RadWindow>
                        <telerik:RadWindow ID="PedunculatedParisClassificationPopUp" runat="server" Width="652" Height="250" ReloadOnShow="true" ShowContentDuringLoad="false" OnUnload="WinUnload" >
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

                        <telerik:RadWindow ID="SessilePitPatternsPopup" runat="server" Width="652" Height="510" ReloadOnShow="true" ShowContentDuringLoad="false" OnUnload="WinUnload" >
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
                        <telerik:RadWindow ID="PedunculatedPitPatternsPopup" runat="server" Width="652" Height="510" ReloadOnShow="true" ShowContentDuringLoad="false" OnUnload="WinUnload" >
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
                        <telerik:RadWindow ID="PolypDetailsRadWindow" runat="server" ReloadOnShow="true" InitialBehaviors="Maximize" KeepInScreenBounds="true" Width="652" Height="600px" AutoSize="false" Title="Polyp details" VisibleStatusbar="false" Modal="True" Skin="Metro">
                        </telerik:RadWindow>
                    </Windows>
                </telerik:RadWindowManager>

                <%-- <telerik:RadToolTip runat="server" ID="SessileParisClassificationPopup" RelativeTo="BrowserWindow" TargetControlID="SessileParisShowButton" IsClientID="true" ShowEvent="OnClick" ManualClose="true"
            Animation="None" Position="TopRight" Skin="Office2010Blue">
            
        </telerik:RadToolTip>--%>

                <%--<telerik:RadToolTip runat="server" ID="RadToolTip1" RelativeTo="BrowserWindow" TargetControlID="PedunculatedParisShowButton" IsClientID="true" ShowEvent="OnClick" ManualClose="true"
            Animation="None" Position="TopRight" Skin="Office2010Blue">
            
        </telerik:RadToolTip>--%>

                <%-- <telerik:RadToolTip runat="server" ID="SessilePitPatternsPopup" RelativeTo="BrowserWindow" TargetControlID="SessilePitShowButton" IsClientID="true" ShowEvent="OnClick" ManualClose="true"
            Animation="None" Position="TopRight" Skin="Office2010Blue">
            
        </telerik:RadToolTip>--%>

                <%--<telerik:RadToolTip runat="server" ID="PedunculatedPitPatternsPopup" RelativeTo="BrowserWindow" TargetControlID="PedunculatedPitShowButton" IsClientID="true" ShowEvent="OnClick" ManualClose="true"
            Animation="None" Position="TopRight" Skin="Office2010Blue">
            
        </telerik:RadToolTip>--%>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
