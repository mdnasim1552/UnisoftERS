<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Specimens_OGDSpecimensTaken" CodeBehind="OGDSpecimensTaken.aspx.vb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />

    <telerik:RadScriptBlock runat="server" ID="RadCodeBlock">
        <script type="text/javascript">
            var OGDSpecimensTakenValueChanged = false;
            var validationMessage = '';
            $(window).on('load', function () {
                $('input[type="checkbox"]').each(function () {
                    ToggleTRs($(this));
                });
                ToggleSerialNoCombo();
                ToggleBiopsySites();
                ToggleFNASampleAssessedAtProcedure();
                ToggleFNBSampleAssessedAtProcedure();
            });

            $(document).ready(function () {
                //$('input[type="checkbox"]').change(function () {
                $("#OGDSpecimensFormView_SpecimensTable tr td:first-child input:checkbox").change(function () {
                    ToggleTRs($(this));
                    ogdSpecimenChangedLocalStorage();
                });

                $("#OGDSpecimensFormView_NoneCheckBox").change(function () {
                    ToggleNoneCheckBox($(this).is(':checked'));
                    setTimeout(function () {
                        ogdSpecimenChangedLocalStorage();
                    }, 1);
                });

                $("#OGDSpecimensFormView_SpecimensTable tr td:first-child input:text").change(function () {
                    setTimeout(function () {
                        ogdSpecimenChangedLocalStorage();
                    }, 1);
                });

                $("#OGDSpecimensFormView_FnaCheckBox,  #OGDSpecimensFormView_FnbCheckBox, #OGDSpecimensFormView_PolypsCheckBox").each(function () {
                    ToggleTRs($(this));
                });

                $("#OGDSpecimensFormView_SpecimensTable tr td:first-child input:radio").change(function () {
                    ogdSpecimenChangedLocalStorage();
                });

                $(window).on('beforeunload', function () {
                    if (OGDSpecimensTakenValueChanged) {
                        $('#<%=SaveButton.ClientID%>').click();
                    }
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            });

            function ogdSpecimenChangedLocalStorage() {
                OGDSpecimensTakenValueChanged = true;
                valueChanged();
                if (!validateSpecimens()) {
                    localStorage.setItem('validationRequired', 'true');
                    if (validationMessage !== "") localStorage.setItem('validationRequiredMessage', validationMessage);
                } else {
                    localStorage.setItem('validationRequired', 'false');
                    if (validationMessage !== "") localStorage.setItem('validationRequiredMessage', '');
                }
            }

            function valueChanged() {
                setTimeout(function () {
                    var valueToSave = false;
                    $("#OGDSpecimensFormView_SpecimensTable tr td:first-child").each(function () {
                        if ($(this).find("input:checkbox").is(':checked') && validateSpecimens()) valueToSave = true;
                    });
                    if (!$('#OGDSpecimensFormView_NoneCheckBox').is(':checked') && !valueToSave)
                        localStorage.setItem('valueChanged', 'false');
                    else
                        localStorage.setItem('valueChanged', 'true');

                }, 10);
            }

            function CloseWindow() {
                window.parent.CloseWindow();
            }

            function ToggleTRs(chkbox) {
                if (chkbox[0].id != "OGDSpecimensFormView_NoneCheckBox") {
                    var checked = chkbox.is(':checked');
                    if (checked) {
                        $("#OGDSpecimensFormView_NoneCheckBox").prop('checked', false);
                    }
                    chkbox.closest('td')
                        .nextUntil('tr').each(function () {
                            if (checked) {
                                $(this).show();
                                //$(this).fadeIn();
                            }
                            else {
                                $(this).hide();
                                //$(this).fadeOut();
                                ClearControls($(this));
                            }
                        });
                    if (chkbox[0] != null) {
                        if (chkbox[0].id == "OGDSpecimensFormView_BiopsyCheckBox") {
                            if (checked) {
                                var hideTR;

                                chkbox.closest('tr').next().show();
                                //chkbox.closest('tr').next().fadeIn();                                
                                var regionName = '<%=regionName.ToString()%>';
                                var OesophagusSiteAreas = 'Oesophagus'; //'First Part, Second Part, Third Part, Medial Wall First Part, Lateral Wall First Part, Lateral Wall Second Part, Medial Wall Second Part, Lateral Wall Third Part, Medial Wall Third Part';
                                console.log("regionName: " + regionName);
                                var n = OesophagusSiteAreas.indexOf(regionName);
                                console.log("OesophagusSiteAreas.indexOf(regionName): " + n);

                                if (OesophagusSiteAreas.indexOf(regionName) < 0)
                                    hideTR = true;
                                else if (parseInt(<%=areaNo%>) > 0)
                                    hideTR = false;
                                else
                                    hideTR = true;

                                if (hideTR) { $("#OGDSpecimensFormView_BiopsyOesophagusTR").hide(); console.log("hiding the [BiopsyOesophagusTR], this is not an [Oesophagus] site"); }

                            }
                            else {
                                chkbox.closest('tr').next().hide();
                                //chkbox.closest('tr').next().fadeOut();
                                ClearControls(chkbox.closest('tr').next());
                            }
                        }
                    }
                }
            }

            function ToggleNoneCheckBox(checked) {
                if (checked) {
                    //$("#OGDSpecimensFormView_SpecimensTable tr td:first-child").each(function () {
                    //    $(this).find("input:checkbox:checked").removeAttr("checked");
                    //    $(this).find("input:checkbox").trigger("change");
                    //});
                    $("#OGDSpecimensFormView_SpecimensTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked, input:radio:checked").prop('checked', false);
                        $(this).find("input:text").val("");
                        ToggleTRs($(this));
                    });
                }
            }

            function ToggleSerialNoCombo() {
                var selectedVal = $('#OGDSpecimensFormView_ForcepTypeCheckBox').is(':checked');
                if (selectedVal) {
                    $("#OGDSpecimensFormView_SerialNoLabel").show();
                    $("#OGDSpecimensFormView_SerialNoTextBox").show();
                }
                else {
                    $("#OGDSpecimensFormView_SerialNoTextBox").hide();
                    $("#OGDSpecimensFormView_SerialNoLabel").hide();
                }
            }

            function ToggleFna() {
                var cyto, micro, viro;
                cyto = $('#OGDSpecimensFormView_CytologyCheckBox').is(':checked');
                micro = $('#OGDSpecimensFormView_MicrobiologyCheckBox').is(':checked');
                viro = $('#OGDSpecimensFormView_VirologyCheckBox').is(':checked');
                if (!cyto && !micro && !viro) {
                    $('#OGDSpecimensFormView_FnaCheckBox').attr('checked', false);
                    $("#OGDSpecimensFormView_FnaCheckboxesTD").hide();
                }
            }

            function ClearControls(tableCell) {
                tableCell.find("input:radio:checked").removeAttr("checked");
                tableCell.find("input:checkbox:checked").removeAttr("checked");
                tableCell.find("input:text").val("");
                ToggleSerialNoCombo();
            }

            function ToggleBiopsySites() {
                var multibiopsysites = $('#OGDSpecimensFormView_BiopsiesTakenAtSitesCheckBox').is(':checked');
                if (multibiopsysites) {
                    $("#OGDSpecimensFormView_AddBiopsySitesRadButton").show();
                    $("#OGDSpecimensFormView_HistologyQtyNumericTextBox").prop('disabled', true);
                    //$find("OGDSpecimensFormView_HistologyQtyNumericTextBox").disable();
                }
                else {
                    $("#OGDSpecimensFormView_AddBiopsySitesRadButton").hide();
                    $("#OGDSpecimensFormView_HistologyQtyNumericTextBox").prop('disabled', false);
                    //$find("OGDSpecimensFormView_HistologyQtyNumericTextBox").enable();
                }
            }

            //MH Added on 24 Aug 2021
            function ToggleFNASampleAssessedAtProcedure() {


                var fnaSampleAssessed = $('#OGDSpecimensFormView_FNASampleAssessedAtProcedure').is(':checked');
                if (fnaSampleAssessed) {

                    document.getElementById('divFnaAdequacy').hidden = false;
                }
                else {
                    document.getElementById('divFnaAdequacy').hidden = true;
                }
            }

            function ToggleFNBSampleAssessedAtProcedure() {
                var fnbSampleAssessed = $('#OGDSpecimensFormView_FNBSampleAssessedAtProcedure').is(':checked');
                if (fnbSampleAssessed) {
                    document.getElementById('divFnbAdequacy').hidden = false;
                }
                else {
                    document.getElementById('divFnbAdequacy').hidden = true;
                }
            }

            function showBiopsySitesWindow(sender, args) {
                var url = "<%= ResolveUrl("~/Products/Gastro/Specimens/BiopsySites.aspx?siteid={0}")%>";
                url = url.replace("{0}", "<%=siteId%>");

                var oWnd = $find("<%= BiopsySitesDetailsRadWindow.ClientID %>");
                oWnd._navigateUrl = url
                oWnd.set_title("Biopsy Sites");

                //Add the name of the function to be executed when RadWindow is closed.
                oWnd.add_close(OnBiopsyClientClose);
                oWnd.show();

                args.set_cancel(true);
            }

            function OnBiopsyClientClose() {
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest('biopsy_save');
            }

            function populateBXQty(totalQty) {
                $('#OGDSpecimensFormView_HistologyQtyNumericTextBox').val(totalQty);
                //$find('#OGDSpecimensFormView_HistologyQtyNumericTextBox').set_value(totalQty);
                ToggleBiopsySites();
                ogdSpecimenChangedLocalStorage();
            }

            function validateSpecimens(sender, args) {
                var valMsg = '';
                var validated = true;
                //check biopsy
                if ($('#OGDSpecimensFormView_BiopsyCheckBox').is(':checked')) {
                    if (($('#OGDSpecimensFormView_HistologyQtyNumericTextBox').val() == 0 || $('#OGDSpecimensFormView_HistologyQtyNumericTextBox').val() == '') &&
                        ($('#OGDSpecimensFormView_MicrobiologyQtyNumericTextBox').val() == 0 || $('#OGDSpecimensFormView_MicrobiologyQtyNumericTextBox').val() == '') &&
                        ($('#OGDSpecimensFormView_VirologyQtyNumericTextBox').val() == 0 || $('#OGDSpecimensFormView_VirologyQtyNumericTextBox').val() == '')) {
                        valMsg = valMsg + '<br>' + 'Please enter a biopsy qty';
                        if ($('#OGDSpecimensFormView_HistologyQtyNumericTextBox').val() == 0 || $('#OGDSpecimensFormView_HistologyQtyNumericTextBox').val() == '') {
                            $("#OGDSpecimensFormView_HistologyQtyNumericTextBox").css("border-color", "#ff0000");
                        }
                        if ($('#OGDSpecimensFormView_MicrobiologyQtyNumericTextBox').val() == 0 || $('#OGDSpecimensFormView_MicrobiologyQtyNumericTextBox').val() == '') {
                            $("#OGDSpecimensFormView_MicrobiologyQtyNumericTextBox").css("border-color", "#ff0000");
                        }
                        if ($('#OGDSpecimensFormView_VirologyQtyNumericTextBox').val() == 0 || $('#OGDSpecimensFormView_VirologyQtyNumericTextBox').val() == '') {
                            $("#OGDSpecimensFormView_VirologyQtyNumericTextBox").css("border-color", "#ff0000");
                        }
                    }
                }

                //FNA
                if ($('#OGDSpecimensFormView_FnaCheckBox').is(':checked')) {
                    if (!$('#OGDSpecimensFormView_CytologyCheckBox').is(':checked') && !$('#OGDSpecimensFormView_MicrobiologyCheckBox').is(':checked') && !$('#OGDSpecimensFormView_VirologyCheckBox').is(':checked')) {
                        valMsg = valMsg + '<br>' + 'Please select where FNA specimen was sent to';
                    }

                    if (($find('OGDSpecimensFormView_NumberOfPassesNumericTextBox').get_value() == 0 || $find('OGDSpecimensFormView_NumberOfPassesNumericTextBox').get_value() == '')) {
                        valMsg = valMsg + '<br>' + 'Please enter number of FNA passes';
                        $("#OGDSpecimensFormView_NumberOfPassesNumericTextBox").css("border-color", "#ff0000");
                    }
                }

                //FNB
                if ($('#OGDSpecimensFormView_FnbCheckBox').is(':checked')) {
                    if (($find('OGDSpecimensFormView_FnbNumberOfPassesNumericTextBox').get_value() == 0 || $find('OGDSpecimensFormView_FnbNumberOfPassesNumericTextBox').get_value() == '')) {
                        valMsg = valMsg + '<br>' + 'Please enter number of FNB passes';
                        $("#OGDSpecimensFormView_FnbNumberOfPassesNumericTextBox").css("border-color", "#ff0000");
                    }
                }

                //Polyps
                if ($('#OGDSpecimensFormView_PolypsCheckBox').is(':checked')) {
                    if (($find('OGDSpecimensFormView_PolypsQtyNumericTextBox').get_value() == 0 || $find('OGDSpecimensFormView_PolypsQtyNumericTextBox').get_value() == '')) {
                        valMsg = valMsg + '<br>' + 'Please enter the qty of polyp specimens taken';
                        $("#OGDSpecimensFormView_PolypsQtyNumericTextBox").css("border-color", "#ff0000");
                    }
                }

                //Urease
                if ($('#OGDSpecimensFormView_UreaseTestCheckBox').is(':checked')) {
                    if ($('#OGDSpecimensFormView_UreaseTestRadioButtonList input:checked').length == 0) {
                        valMsg = valMsg + '<br>' + 'Please enter a urease test result';
                    }
                }

                if (valMsg != '') {
                    validated = false;
                    validationMessage = valMsg;
                    //alert('Please correct the following:' + '\n' + valMsg);
                    <%---$find('<%=RadNotification1.ClientID%>').set_text('Please correct the following:' + '<br>' + valMsg);
                    $find('<%=RadNotification1.ClientID%>').set_position(Telerik.Web.UI.NotificationPosition.Center);
                    $find('<%=RadNotification1.ClientID%>').show()--%>;
                    if (args !== undefined && args !== null) args.set_cancel(true);
                }
                return validated;
            }

            
        </script>
    </telerik:RadScriptBlock>

    <style type="text/css">
        .SiteDetailsForm {
            /*font: 12px / 18px "segoe ui", arial, sans-serif;
            color: #000;*/
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            color: black;
        }

            .SiteDetailsForm td {
                padding-bottom: 10px;
            }

        .AutoHeight {
            height: auto !important;
        }

        .rbl label {
            margin-right: 20px;
        }
    </style>
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
        <telerik:RadScriptManager ID="OGDSpecimensRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" AutoCloseDelay="0" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Specimens Taken</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">

                <asp:ObjectDataSource ID="OGDSpecimensObjectDataSource" runat="server"
                    TypeName="UnisoftERS.SpecimensTaken" SelectMethod="GetOgdSpecimensData" UpdateMethod="SaveOgdSpecimensData" InsertMethod="SaveOgdSpecimensData">
                    <SelectParameters>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="siteId" Type="Int32" />
                        <asp:Parameter Name="none" Type="Boolean" />
                        <asp:Parameter Name="brushCytology" Type="Boolean" />
                        <asp:Parameter Name="biopsy" Type="Boolean" />
                        <asp:Parameter Name="biopsiesTakenAtRandom" Type="Boolean" />
                        <asp:Parameter Name="biopsiesTakenAtSites" Type="Boolean" />
                        <asp:Parameter Name="biopsyQtyHistology" Type="Double" />
                        <asp:Parameter Name="biopsyQtyMicrobiology" Type="Double" />
                        <asp:Parameter Name="biopsyQtyVirology" Type="Double" />
                        <asp:Parameter Name="BiopsyDistance" Type="Double" />
                        <asp:Parameter Name="forcepType" Type="Int32" />
                        <asp:Parameter Name="forcepSerialNo" ConvertEmptyStringToNull="true" Type="String" />
                        <asp:Parameter Name="urease" Type="Boolean" />
                        <asp:Parameter Name="ureaseResult" ConvertEmptyStringToNull="true" Type="Int32" />
                        <asp:Parameter Name="polypectomy" Type="Boolean" />
                        <asp:Parameter Name="polypectomyQty" Type="Double" />
                        <asp:Parameter Name="hotBiopsy" Type="Boolean" />
                        <asp:Parameter Name="needleAspirate" Type="Boolean" />
                        <asp:Parameter Name="needleAspirateHistology" Type="Boolean" />
                        <asp:Parameter Name="needleAspirateMicrobiology" Type="Boolean" />
                        <asp:Parameter Name="needleAspirateVirology" Type="Boolean" />
                        <asp:Parameter Name="gastricWashing" Type="Boolean" />
                        <asp:Parameter Name="bile_PanJuice" Type="Boolean" />
                        <asp:Parameter Name="bile_PanJuiceCytology" Type="Boolean" />
                        <asp:Parameter Name="bile_PanJuiceBacteriology" Type="Boolean" />
                        <asp:Parameter Name="bile_PanJuiceAnalysis" Type="Boolean" />
                        <asp:Parameter Name="EUSFNANumberOfPasses" Type="Int16" />
                        <asp:Parameter Name="EUSFNANeedleGauge" Type="Int16" />
                        <asp:Parameter Name="FNB" Type="Boolean" />
                        <asp:Parameter Name="EUSFNBNumberOfPasses" Type="Int16" />
                        <asp:Parameter Name="EUSFNBNeedleGauge" Type="Int16" />
                        <asp:Parameter Name="BrushBiopsy" Type="Boolean" />
                        <asp:Parameter Name="TumourMarkers" Type="Boolean" />
                        <asp:Parameter Name="AmylaseLipase" Type="Boolean" />
                        <asp:Parameter Name="CytologyHistology" Type="Boolean" />
                        <asp:Parameter Name="FNASampleAssessedAtProcedure" Type="Boolean" />
                        <asp:Parameter Name="AdequateFNA" Type="Boolean" />
                        <asp:Parameter Name="FNBSampleAssessedAtProcedure" Type="Boolean" />
                        <asp:Parameter Name="AdequateFNB" Type="Boolean" />
                        <asp:Parameter Name="needleBiopsyHistology" Type="Boolean" />
                        <asp:Parameter Name="needleBiopsyCytology" Type="Boolean" />
                        <asp:Parameter Name="needleBiopsyMicrobiology" Type="Boolean" />
                        <asp:Parameter Name="needleBiopsyVirology" Type="Boolean" />
                    </UpdateParameters>
                </asp:ObjectDataSource>

                <asp:FormView ID="OGDSpecimensFormView" runat="server" DefaultMode="Edit"
                    DataSourceID="OGDSpecimensObjectDataSource" DataKeyNames="SiteId">
                    <EditItemTemplate>

                        <div id="ContentDiv">
                            <div class="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">
                                    <table id="SpecimensTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 780px;">
                                        <%-- <table id="SpecimensTable" class="rgview" cellpadding="0" cellspacing="0">--%>
                                        <colgroup>
                                            <col>
                                            <col>
                                            <col>
                                        </colgroup>
                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;">
                                                    <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" ForeColor="Black" Checked='<%# Bind("None")%>' />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>

                                            <tr id="AmylaseLipaseTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="AmylaseLipaseCheckBox" runat="server" Checked='<%# Bind("AmylaseLipase")%>' Text="Amylase / lipase test" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="BileTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="Bile_PanJuiceCheckBox" runat="server" Checked='<%# Bind("Bile_PanJuice")%>' Text="Bile" />
                                                            </td>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="Bile_PanJuiceCytologyCheckBox" runat="server" Checked='<%# Bind("Bile_PanJuiceCytology")%>' Text="Cytology" Style="margin-right: 20px;" />
                                                                <asp:CheckBox ID="Bile_PanJuiceBacteriologyCheckBox" runat="server" Checked='<%# Bind("Bile_PanJuiceBacteriology")%>' Text="Microbiology" Style="margin-right: 20px;" />
                                                                <asp:CheckBox ID="Bile_PanJuiceAnalysisCheckBox" runat="server" Checked='<%# Bind("Bile_PanJuiceAnalysis")%>' Text="Analysis" Style="margin-right: 20px;" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="BiopsyTR" runat="server" visible="false">
                                                <%--If gProcNo = ERCP Then SHOW--%>
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none; vertical-align: top;">
                                                                <asp:CheckBox ID="BiopsyCheckBox" runat="server" Checked='<%# Bind("Biopsy")%>' Text="Biopsy" />
                                                            </td>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="BiopsiesTakenAtRandomCheckBox" runat="server" Checked='<%# Bind("biopsiesTakenAtRandom")%>' Text="Random" Style="padding-right: 30px;" Visible="false" />

                                                                <asp:CheckBox ID="BiopsiesTakenAtSitesCheckBox" runat="server" Checked='<%# Bind("biopsiesTakenAtSites")%>' Text="Sites" Style="padding-right: 30px;" Visible="false" OnClick="populateBXQty(0);" onchange="ToggleBiopsySites();" />
                                                                <telerik:RadButton ID="AddBiopsySitesRadButton" runat="server" Text="Add/edit biopsy sites..." Skin="Metro" Style="display: none;" OnClientClicking="showBiopsySitesWindow" />
                                                                <br />
                                                                <br />
                                                                Quantity:
                                                                            <telerik:RadNumericTextBox ID="HistologyQtyNumericTextBox" runat="server" DbValue='<%# Bind("BiopsyQtyHistology")%>'
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                to histology
                                                                            &nbsp;&nbsp;

                                                                            <telerik:RadNumericTextBox ID="MicrobiologyQtyNumericTextBox" runat="server" DbValue='<%# Bind("BiopsyQtyMicrobiology")%>'
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                to microbiology
                                                                            &nbsp;&nbsp;

                                                                            <telerik:RadNumericTextBox ID="VirologyQtyNumericTextBox" runat="server" DbValue='<%# Bind("BiopsyQtyVirology")%>'
                                                                                IncrementSettings-InterceptMouseWheel="false"
                                                                                IncrementSettings-Step="1"
                                                                                Width="35px"
                                                                                MinValue="0">
                                                                                <NumberFormat DecimalDigits="0" />
                                                                            </telerik:RadNumericTextBox>
                                                                to virology
                                                            </td>
                                                        </tr>
                                                        <tr id="BiopsyOesophagusTR" runat="server">
                                                            <td style="border: none;"></td>
                                                            <td style="border: none;">
                                                                <div id="BiopsyDistanceDiv" style="border: none; padding-left: 4px; margin-bottom: 5px;">
                                                                    distance <%--'--%>
                                                                    <telerik:RadNumericTextBox ID="BiopsyDistanceNumericText" runat="server" DbValue='<%# Bind("BiopsyDistance")%>'
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    cm (optional)
                                                                </div>

                                                                <div id="ForcepTypeDiv" style="border: none; padding-left: 4px;">
                                                                    Forceps:
                                                                <asp:CheckBox ID="ForcepTypeCheckBox" runat="server" Checked='<%# Bind("forcepType")%>' Text="Disposable"
                                                                    onchange="ToggleSerialNoCombo();" />
                                                                    <%--   <asp:RadioButtonList ID="ForcepsRadioButtonList" runat="server" 
                                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="rbl"
                                                                    onchange="ToggleSerialNoCombo();">
                                                                    <asp:ListItem Value="1" Text="Disposable"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="Reusable"></asp:ListItem>
                                                                </asp:RadioButtonList>--%>

                                                                    <asp:Label ID="SerialNoLabel" runat="server" Style="padding-left: 30px;">Serial Number:</asp:Label>
                                                                    <telerik:RadTextBox ID="SerialNoTextBox" runat="server" Width="200px" Text='<%# Bind("forcepSerialNo")%>' TextMode="SingleLine" Resize="None" />
                                                                    <%--<telerik:RadComboBox ID="SerialNoComboBox" runat="server" Skin="Windows7" Width="100"  />--%>
                                                                </div>
                                                            </td>
                                                        </tr>


                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="BrushBiopsyTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="BrushBiopsyCheckBox" runat="server" Checked='<%# Bind("BrushBiopsy")%>' Text="Brush biopsy" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="BrushCytologyTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="BrushCytologyCheckBox" runat="server" Checked='<%# Bind("BrushCytology")%>' Text="Brush cytology" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="CytologyHistologyTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="CytologyHistologyCheckBox" runat="server" Checked='<%# Bind("CytologyHistology")%>' Text="Cytology / histology" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="FnaTR" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none; width: 150px; vertical-align: top;">
                                                                <asp:CheckBox ID="FnaCheckBox" runat="server" Checked='<%# Bind("NeedleAspirate")%>' Text="FNA" />
                                                            </td>
                                                            <td style="border: none;">
                                                                <div runat="server" id="divFnaLogy" style="padding-bottom: 15px;">
                                                                    <asp:CheckBox ID="CytologyCheckBox" runat="server" Checked='<%# Bind("NeedleAspirateHistology")%>' Text="Cytology" Style="margin-right: 20px;" />
                                                                    <asp:CheckBox ID="MicrobiologyCheckBox" runat="server" Checked='<%# Bind("NeedleAspirateMicrobiology")%>' Text="Microbiology" Style="margin-right: 20px;" />
                                                                    <asp:CheckBox ID="VirologyCheckBox" runat="server" Checked='<%# Bind("NeedleAspirateVirology")%>' Text="Virology" Style="margin-right: 20px;" />
                                                                    <span id="fnaCheckBoxChildren" style="color: red">*</span>
                                                                </div>
                                                                <div runat="server" id="divFnaPasses" style="padding-left: 16px;">
                                                                    Passes
                                                                    <telerik:RadNumericTextBox ID="NumberOfPassesNumericTextBox" runat="server" DbValue='<%# Bind("EUSFNANumberOfPasses")%>'
                                                                        DataType="System.Int32"
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    &nbsp;&nbsp;&nbsp;&nbsp;
                                                                    Size of needle gauge
                                                                    <telerik:RadNumericTextBox ID="NeedleGaugeNumericTextBox" runat="server" DbValue='<%# Bind("EUSFNANeedleGauge")%>'
                                                                        DataType="System.Int32"
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                </div>
                                                                <div style="padding-top: 10px;">
                                                                    <asp:CheckBox ID="FNASampleAssessedAtProcedure" runat="server" Text="Assessed at procedure" Checked='<%# Bind("FNASampleAssessedAtProcedure") %>' onchange="ToggleFNASampleAssessedAtProcedure();" />
                                                                </div>
                                                                <div id="divFnaAdequacy" hidden="hidden" style="padding-top: 10px;">
                                                                    <asp:CheckBox ID="FnaAdequacy" runat="server" Text="Adequate sample retreived" Checked='<%# Bind("AdequateFNA") %>' />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="FnbTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none; width: 150px; vertical-align:top;">
                                                                <asp:CheckBox ID="FnbCheckBox" runat="server" Checked='<%# Bind("FNB")%>' Text="FNB" />
                                                            </td>
                                                            <td style="border: none;">
                                                                <div runat="server" id="divFnbLogy" style="padding-bottom: 15px;">
                                                                    <asp:CheckBox ID="BiopsyHistologyCheckBox" runat="server" Checked='<%# Bind("NeedleBiopsyHistology")%>' Text="Histology" Style="margin-right: 20px;" />
                                                                    <asp:CheckBox ID="BiopsyCytologyCheckBox" runat="server" Checked='<%# Bind("NeedleBiopsyCytology")%>' Text="Cytology" Style="margin-right: 20px;" />
                                                                    <asp:CheckBox ID="BiopsyMicrobiologyCheckBox" runat="server" Checked='<%# Bind("NeedleBiopsyMicrobiology")%>' Text="Microbiology" Style="margin-right: 20px;" />
                                                                    <asp:CheckBox ID="BiopsyVirologyCheckBox" runat="server" Checked='<%# Bind("NeedleBiopsyVirology")%>' Text="Virology" Style="margin-right: 20px;" />
                                                                </div>
                                                                <div style="padding-left: 16px;">
                                                                    Passes
                                                                <telerik:RadNumericTextBox ID="FnbNumberOfPassesNumericTextBox" runat="server" DbValue='<%# Bind("EUSFNBNumberOfPasses")%>'
                                                                    DataType="System.Int32"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                    &nbsp;&nbsp;&nbsp;&nbsp;
                                                                Size of needle gauge
                                                                <telerik:RadNumericTextBox ID="FnbNeedleGaugeNumericTextBox" runat="server" DbValue='<%# Bind("EUSFNBNeedleGauge")%>'
                                                                    DataType="System.Int32"
                                                                    IncrementSettings-InterceptMouseWheel="false"
                                                                    IncrementSettings-Step="1"
                                                                    Width="35px"
                                                                    MinValue="0">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                </div>
                                                                <div style="padding-top: 10px;">
                                                                    <asp:CheckBox ID="FNBSampleAssessedAtProcedure" runat="server" Text="Assessed at procedure" Checked='<%# Bind("FNBSampleAssessedAtProcedure") %>' onchange="ToggleFNBSampleAssessedAtProcedure();" />
                                                                </div>
                                                                <div id="divFnbAdequacy" hidden="hidden" style="padding-top: 10px;">
                                                                    <asp:CheckBox ID="FnbAdequacy" runat="server" Text="Adequate sample retrieved" Checked='<%# Bind("AdequateFNB") %>' />
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="GastricWashingTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="GastricWashingCheckBox" runat="server" Checked='<%# Bind("GastricWashing")%>' Text="Gastric washing for microbiology" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="HotBiopsyTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="HotBiopsyCheckBox" runat="server" Checked='<%# Bind("HotBiopsy")%>' Text="Hot Biopsy" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="PolypsTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="PolypsCheckBox" runat="server" Checked='<%# Bind("Polypectomy")%>' Text='<%# IIf(Eval("AbnoPolyps") <> "", "Polyps: " + Eval("AbnoPolyps"), "Polyps")%>' />
                                                            </td>
                                                            <td style="border: none;">
                                                                <div runat="server" style="display: <% IIf(Eval('AbnoPolyps') <> '', 'none', 'block')%>">
                                                                    Quantity: 
                                                                    <telerik:RadNumericTextBox ID="PolypsQtyNumericTextBox" runat="server" DbValue='<%# Bind("PolypectomyQty")%>'
                                                                        IncrementSettings-InterceptMouseWheel="false"
                                                                        IncrementSettings-Step="1"
                                                                        Width="35px"
                                                                        MinValue="0">
                                                                        <NumberFormat DecimalDigits="0" />
                                                                    </telerik:RadNumericTextBox>
                                                                    &nbsp;

                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="TumourMarkersTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none;">
                                                                <asp:CheckBox ID="TumourMarkersCheckBox" runat="server" Checked='<%# Bind("TumourMarkers")%>' Text="Tumour markers" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>

                                            <tr id="UreaseTestTR" runat="server" visible="false">
                                                <td style="padding: 0px 0px 0px 6px;">
                                                    <table style="width: 100%;">
                                                        <tr>
                                                            <td style="border: none; width: 150px;">
                                                                <asp:CheckBox ID="UreaseTestCheckBox" runat="server" Checked='<%# Bind("Urease")%>' Text="Urease test" />
                                                            </td>
                                                            <td style="border: none;">Result: 
                                                                <asp:RadioButtonList ID="UreaseTestRadioButtonList" runat="server" CssClass="rbl"
                                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" RepeatLayout="Flow">
                                                                    <asp:ListItem Value="0" Text="Unknown"></asp:ListItem>
                                                                    <asp:ListItem Value="1" Text="Positive"></asp:ListItem>
                                                                    <asp:ListItem Value="2" Text="Negative"></asp:ListItem>
                                                                </asp:RadioButtonList>
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

                    </EditItemTemplate>
                </asp:FormView>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; display:none">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" OnClientClicking="validateSpecimens" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        <div>
        </div>
        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move" ReloadOnShow="True">
            <Windows>
                <telerik:RadWindow ID="BiopsySitesDetailsRadWindow" runat="server" ReloadOnShow="true" InitialBehaviors="Maximize" KeepInScreenBounds="true" Width="652" Height="600px" AutoSize="false" Title="Polyp details" VisibleStatusbar="false" Modal="True" Skin="Metro">
                </telerik:RadWindow>
                <telerik:RadWindow ID="radwindow1" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="652" Height="600px" AutoSize="false" Title="Biopsy sites" VisibleStatusbar="false" Behaviors="None" Modal="True" Skin="Metro">
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
